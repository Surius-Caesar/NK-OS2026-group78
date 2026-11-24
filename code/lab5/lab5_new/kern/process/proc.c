#include <proc.h>
#include <kmalloc.h>
#include <string.h>
#include <sync.h>
#include <pmm.h>
#include <error.h>
#include <sched.h>
#include <elf.h>
#include <vmm.h>
#include <trap.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <unistd.h>

/* ------------- process/thread mechanism design&implementation -------------
(an simplified Linux process/thread mechanism )
introduction:
  ucore implements a simple process/thread mechanism. process contains the independent memory sapce, at least one threads
for execution, the kernel data(for management), processor state (for context switch), files(in lab6), etc. ucore needs to
manage all these details efficiently. In ucore, a thread is just a special kind of process(share process's memory).
------------------------------
process state       :     meaning               -- reason
    PROC_UNINIT     :   uninitialized           -- alloc_proc
    PROC_SLEEPING   :   sleeping                -- try_free_pages, do_wait, do_sleep
    PROC_RUNNABLE   :   runnable(maybe running) -- proc_init, wakeup_proc,
    PROC_ZOMBIE     :   almost dead             -- do_exit

-----------------------------
process state changing:

  alloc_proc                                 RUNNING
      +                                   +--<----<--+
      +                                   + proc_run +
      V                                   +-->---->--+
PROC_UNINIT -- proc_init/wakeup_proc --> PROC_RUNNABLE -- try_free_pages/do_wait/do_sleep --> PROC_SLEEPING --
                                           A      +                                                           +
                                           |      +--- do_exit --> PROC_ZOMBIE                                +
                                           +                                                                  +
                                           -----------------------wakeup_proc----------------------------------
-----------------------------
process relations
parent:           proc->parent  (proc is children)
children:         proc->cptr    (proc is parent)
older sibling:    proc->optr    (proc is younger sibling)
younger sibling:  proc->yptr    (proc is older sibling)
-----------------------------
related syscall for process:
SYS_exit        : process exit,                           -->do_exit
SYS_fork        : create child process, dup mm            -->do_fork-->wakeup_proc
SYS_wait        : wait process                            -->do_wait
SYS_exec        : after fork, process execute a program   -->load a program and refresh the mm
SYS_clone       : create child thread                     -->do_fork-->wakeup_proc
SYS_yield       : process flag itself need resecheduling, -- proc->need_sched=1, then scheduler will rescheule this process
SYS_sleep       : process sleep                           -->do_sleep
SYS_kill        : kill process                            -->do_kill-->proc->flags |= PF_EXITING
                                                                 -->wakeup_proc-->do_wait-->do_exit
SYS_getpid      : get the process's pid

*/

// the process set's list
list_entry_t proc_list;

#define HASH_SHIFT 10
#define HASH_LIST_SIZE (1 << HASH_SHIFT)
#define pid_hashfn(x) (hash32(x, HASH_SHIFT))

// has list for process set based on pid
static list_entry_t hash_list[HASH_LIST_SIZE];

// idle proc
struct proc_struct *idleproc = NULL;
// init proc
struct proc_struct *initproc = NULL;
// current proc
struct proc_struct *current = NULL;

static int nr_process = 0;

void kernel_thread_entry(void);
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

//lab4 请补充你在lab4中的代码
// 本文件中稍后出现的函数可能被前面的函数引用，先做静态声明。
static struct proc_struct *alloc_proc(void);
static void copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf);
static int copy_mm(uint32_t clone_flags, struct proc_struct *proc);
static int init_main(void *arg);

//lab5 function2 MY CODE:2413340 更新 alloc_proc
// alloc_proc - 分配并初始化一个 PCB，所有字段先置于安全初值。
static struct proc_struct *
alloc_proc(void)
{
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
    if (proc != NULL)
    {
        memset(proc, 0, sizeof(struct proc_struct));
        proc->state = PROC_UNINIT;
        proc->pid = -1;
        proc->runs = 0;
        proc->kstack = 0;
        proc->need_resched = 0;
        proc->parent = NULL;
        proc->mm = NULL;
        // 内核线程共享内核地址空间，因此初始页表指向内核页表。
        proc->pgdir = boot_pgdir_pa;
        proc->tf = NULL;
        proc->flags = 0;
        proc->exit_code = 0;
        proc->wait_state = 0;
        proc->cptr = proc->optr = proc->yptr = NULL;
        proc->context.ra = 0;
        proc->context.sp = 0;
    }
    return proc;
}

// proc_init - 初始化进程管理结构，建立 idleproc 与 initproc。
void proc_init(void)
{
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i++)
    {
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL)
    {
        panic("cannot alloc idleproc.\n");
    }

    // 当前执行现场直接作为 idleproc，复用启动栈。
    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
    idleproc->kstack = (uintptr_t)bootstack;
    idleproc->need_resched = 1;
    set_proc_name(idleproc, "idle");
    current = idleproc;
    nr_process++;

    int pid = kernel_thread(init_main, "Hello world!!", 0);
    if (pid <= 0)
    {
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
    if (initproc == NULL)
    {
        panic("cannot find initproc.\n");
    }
    set_proc_name(initproc, "init");

    cprintf("proc_init() succeeded!\n");
}


// set_proc_name - set the name of proc
char *
set_proc_name(struct proc_struct *proc, const char *name)
{
    memset(proc->name, 0, sizeof(proc->name));
    return memcpy(proc->name, name, PROC_NAME_LEN);
}

// get_proc_name - get the name of proc
char *
get_proc_name(struct proc_struct *proc)
{
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
    return memcpy(name, proc->name, PROC_NAME_LEN);
}

// set_links - set the relation links of process
static void
set_links(struct proc_struct *proc)
{
    list_add(&proc_list, &(proc->list_link));
    proc->yptr = NULL;
    if ((proc->optr = proc->parent->cptr) != NULL)
    {
        proc->optr->yptr = proc;
    }
    proc->parent->cptr = proc;
    nr_process++;
}

// remove_links - clean the relation links of process
static void
remove_links(struct proc_struct *proc)
{
    list_del(&(proc->list_link));
    if (proc->optr != NULL)
    {
        proc->optr->yptr = proc->yptr;
    }
    if (proc->yptr != NULL)
    {
        proc->yptr->optr = proc->optr;
    }
    else
    {
        proc->parent->cptr = proc->optr;
    }
    nr_process--;
}

// get_pid - alloc a unique pid for process
static int
get_pid(void)
{
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++last_pid >= MAX_PID)
    {
        last_pid = 1;
        goto inside;
    }
    if (last_pid >= next_safe)
    {
    inside:
        next_safe = MAX_PID;
    repeat:
        le = list;
        while ((le = list_next(le)) != list)
        {
            proc = le2proc(le, list_link);
            if (proc->pid == last_pid)
            {
                if (++last_pid >= next_safe)
                {
                    if (last_pid >= MAX_PID)
                    {
                        last_pid = 1;
                    }
                    next_safe = MAX_PID;
                    goto repeat;
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid)
            {
                next_safe = proc->pid;
            }
        }
    }
    return last_pid;
}






// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void)
{
    forkrets(current->tf);
}

// hash_proc - add proc into proc hash_list
static void
hash_proc(struct proc_struct *proc)
{
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
}

// unhash_proc - delete proc from proc hash_list
static void
unhash_proc(struct proc_struct *proc)
{
    list_del(&(proc->hash_link));
}

// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid)
{
    if (0 < pid && pid < MAX_PID)
    {
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
        while ((le = list_next(le)) != list)
        {
            struct proc_struct *proc = le2proc(le, hash_link);
            if (proc->pid == pid)
            {
                return proc;
            }
        }
    }
    return NULL;
}

//lab5 function2 MY CODE:2413340 更新 kernel_thread
// kernel_thread - 创建入口为 fn(arg) 的内核线程。
int kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags)
{
    struct trapframe tf;

    memset(&tf, 0, sizeof(struct trapframe));
    // kernel_thread_entry 把 s1 移入 a0 后跳转 s0，因此两个参数放在 s0/s1。
    tf.gpr.s0 = (uintptr_t)fn;
    tf.gpr.s1 = (uintptr_t)arg;
    // 首次 sret 返回内核态并开中断；构造线程期间保持关中断。
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
    tf.epc = (uintptr_t)kernel_thread_entry;

    return do_fork(clone_flags | CLONE_VM, 0, &tf);
}


// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
static int
setup_kstack(struct proc_struct *proc)
{
    struct Page *page = alloc_pages(KSTACKPAGE);
    if (page != NULL)
    {
        proc->kstack = (uintptr_t)page2kva(page);
        return 0;
    }
    return -E_NO_MEM;
}

// put_kstack - free the memory space of process kernel stack
static void
put_kstack(struct proc_struct *proc)
{
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
}

// setup_pgdir - alloc one page as PDT
static int
setup_pgdir(struct mm_struct *mm)
{
    struct Page *page;
    if ((page = alloc_page()) == NULL)
    {
        return -E_NO_MEM;
    }
    pde_t *pgdir = page2kva(page);
    memcpy(pgdir, boot_pgdir_va, PGSIZE);

    mm->pgdir = pgdir;
    return 0;
}

// put_pgdir - free the memory space of PDT
static void
put_pgdir(struct mm_struct *mm)
{
    free_page(kva2page(mm->pgdir));
}

//lab5 function3 MY CODE:2413340 更新 copy_mm
// copy_mm - 根据 clone_flags 决定共享还是复制父进程的地址空间。
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc)
{
    struct mm_struct *mm, *oldmm = current->mm;

    // 当前是内核线程，没有用户地址空间需要处理。
    if (oldmm == NULL)
    {
        return 0;
    }

    if (clone_flags & CLONE_VM)
    {
        // 线程共享同一地址空间，只增加 mm 引用计数。
        mm = oldmm;
        mm_count_inc(mm);
        proc->mm = mm;
        proc->pgdir = PADDR(mm->pgdir);
        return 0;
    }

    // 普通 fork：创建新的 mm 并逐页复制父进程的用户地址空间。
    if ((mm = mm_create()) == NULL)
    {
        return -E_NO_MEM;
    }
    if (setup_pgdir(mm) != 0)
    {
        mm_destroy(mm);
        return -E_NO_MEM;
    }

    lock_mm(oldmm);
    int ret = dup_mmap(mm, oldmm);
    unlock_mm(oldmm);
    if (ret != 0)
    {
        goto bad_free_mm;
    }

    set_mm_count(mm, 1);
    proc->mm = mm;
    proc->pgdir = PADDR(mm->pgdir);
    return 0;

bad_free_mm:
    exit_mmap(mm);
    put_pgdir(mm);
    mm_destroy(mm);
    return ret;
}


//lab5 function2 MY CODE:2413340
// copy_thread - 把 trapframe 和首次运行上下文放到新进程的内核栈上。
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf)
{
    // trapframe 放在内核栈顶部，避免覆盖正在使用的栈内容。
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
    *(proc->tf) = *tf;

    // 子进程的 fork 返回值为 0。
    proc->tf->gpr.a0 = 0;
    // 内核线程从 trapframe 下方开始使用内核栈；用户进程沿用父进程的用户栈指针。
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;

    // 首次运行链路：switch_to -> forkret -> forkrets -> __trapret。
    proc->context.ra = (uintptr_t)forkret;
    proc->context.sp = (uintptr_t)proc->tf;
}


//lab5 function3 MY CODE:2413340
// do_fork - 基于当前进程创建新进程/线程。
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf)
{
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;

    if (nr_process >= MAX_PROCESS)
    {
        goto fork_out;
    }

    ret = -E_NO_MEM;
    if ((proc = alloc_proc()) == NULL)
    {
        goto fork_out;
    }
    proc->parent = current;
    assert(current->wait_state == 0);

    if (setup_kstack(proc) != 0)
    {
        goto bad_fork_cleanup_proc;
    }
    if (copy_mm(clone_flags, proc) != 0)
    {
        goto bad_fork_cleanup_kstack;
    }
    copy_thread(proc, stack, tf);

    // 在关中断临界区内完成 PID 分配与进程树挂接，避免暴露中间状态。
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        proc->pid = get_pid();
        hash_proc(proc);
        set_links(proc);
        // 子进程完整接入进程表后，才允许调度器选中它。
        wakeup_proc(proc);
    }
    local_intr_restore(intr_flag);

    ret = proc->pid;

fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}


//lab5 function4 YOUR CODE
// do_exit - 结束当前进程：释放用户地址空间，转为僵尸态并通知父进程。
int do_exit(int error_code)
{
    if (current == idleproc)
    {
        panic("idleproc exit.\n");
    }
    if (current == initproc)
    {
        panic("initproc exit.\n");
    }

    struct mm_struct *mm = current->mm;
    if (mm != NULL)
    {
        // 先切回内核页表，再销毁用户地址空间。
        write_csr(satp, ((uint64_t)SATP_MODE_SV39 << 60) |
                            (boot_pgdir_pa >> RISCV_PGSHIFT));
        flush_tlb();
        if (mm_count_dec(mm) == 0)
        {
            exit_mmap(mm);
            put_pgdir(mm);
            mm_destroy(mm);
        }
        current->mm = NULL;
    }
    current->pgdir = boot_pgdir_pa;
    current->state = PROC_ZOMBIE;
    current->exit_code = error_code;

    bool intr_flag;
    struct proc_struct *proc;
    local_intr_save(intr_flag);
    {
        // 唤醒正在等待子进程的父进程。
        proc = current->parent;
        if (proc->wait_state == WT_CHILD)
        {
            wakeup_proc(proc);
        }
        // 把当前进程的子进程过继给 initproc，避免进程树出现无人管理的分支。
        while (current->cptr != NULL)
        {
            proc = current->cptr;
            current->cptr = proc->optr;

            proc->yptr = NULL;
            if ((proc->optr = initproc->cptr) != NULL)
            {
                initproc->cptr->yptr = proc;
            }
            proc->parent = initproc;
            initproc->cptr = proc;
            if (proc->state == PROC_ZOMBIE)
            {
                if (initproc->wait_state == WT_CHILD)
                {
                    wakeup_proc(initproc);
                }
            }
        }
    }
    local_intr_restore(intr_flag);

    schedule();
    panic("do_exit will not return!! %d.\n", current->pid);
}

// do_yield - 主动让出 CPU，请求调度器重新选择进程。
int do_yield(void)
{
    current->need_resched = 1;
    return 0;
}

// do_kill - 向目标进程发送退出意图。
int do_kill(int pid)
{
    struct proc_struct *proc;
    if ((proc = find_proc(pid)) != NULL)
    {
        if (!(proc->flags & PF_EXITING))
        {
            proc->flags |= PF_EXITING;
            if (proc->wait_state & WT_INTERRUPTED)
            {
                wakeup_proc(proc);
            }
            return 0;
        }
        return -E_KILLED;
    }
    return -E_INVAL;
}


#define __KERNEL_EXECVE(name, binary, size) ({           \
    cprintf("kernel_execve: pid = %d, name = \"%s\".\n", \
            current->pid, name);                         \
    kernel_execve(name, binary, (size_t)(size));         \
})

#define KERNEL_EXECVE(x) ({                                    \
    extern unsigned char _binary_obj___user_##x##_out_start[], \
        _binary_obj___user_##x##_out_size[];                   \
    __KERNEL_EXECVE(#x, _binary_obj___user_##x##_out_start,    \
                    _binary_obj___user_##x##_out_size);        \
})

#define __KERNEL_EXECVE2(x, xstart, xsize) ({   \
    extern unsigned char xstart[], xsize[];     \
    __KERNEL_EXECVE(#x, xstart, (size_t)xsize); \
})

#define KERNEL_EXECVE2(x, xstart, xsize) __KERNEL_EXECVE2(x, xstart, xsize)


//lab5 function2 MY CODE:2413340
// load_icode - 解析 ELF、建立新的用户地址空间并配置好用户态入口与栈。
static int
load_icode(unsigned char *binary, size_t size)
{
    if (current->mm != NULL)
    {
        panic("load_icode: current->mm must be empty.\n");
    }

    // 读取 ELF 元数据和程序段前，先确认它们没有超出二进制映像的范围。
    if (binary == NULL || size < sizeof(struct elfhdr))
    {
        return -E_INVAL_ELF;
    }
    struct elfhdr *elf = (struct elfhdr *)binary;
    if (elf->e_magic != ELF_MAGIC ||
        elf->e_phentsize != sizeof(struct proghdr) ||
        elf->e_phoff > size ||
        elf->e_phnum > (size - elf->e_phoff) / sizeof(struct proghdr) ||
        !USER_ACCESS(elf->e_entry, elf->e_entry + 1))
    {
        return -E_INVAL_ELF;
    }

    int ret = -E_NO_MEM;
    struct mm_struct *mm;
    if ((mm = mm_create()) == NULL)
    {
        goto bad_mm;
    }
    if (setup_pgdir(mm) != 0)
    {
        goto bad_pgdir_cleanup_mm;
    }

    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);

    for (int i = 0; i < elf->e_phnum; i++, ph++)
    {
        if (ph->p_type != ELF_PT_LOAD)
        {
            continue;
        }
        if (ph->p_filesz > ph->p_memsz || ph->p_offset > size ||
            ph->p_filesz > size - ph->p_offset || ph->p_memsz == 0 ||
            ph->p_va > USERTOP || ph->p_memsz > USERTOP - ph->p_va ||
            !USER_ACCESS(ph->p_va, ph->p_va + ph->p_memsz))
        {
            ret = -E_INVAL_ELF;
            goto bad_cleanup_mmap;
        }

        // 由段权限位推导 vma 标志。
        uint32_t vm_flags = 0;
        if (ph->p_flags & ELF_PF_X)
            vm_flags |= VM_EXEC;
        if (ph->p_flags & ELF_PF_W)
            vm_flags |= VM_WRITE;
        if (ph->p_flags & ELF_PF_R)
            vm_flags |= VM_READ;
        if (vm_flags & VM_WRITE)
            vm_flags |= VM_READ;
        if (vm_flags == 0)
        {
            ret = -E_INVAL_ELF;
            goto bad_cleanup_mmap;
        }

        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0)
        {
            goto bad_cleanup_mmap;
        }

        // RISC-V 要求可写页面同时具有读权限。
        uint32_t perm = PTE_U;
        if (vm_flags & VM_READ) perm |= PTE_R;
        if (vm_flags & VM_WRITE) perm |= PTE_W;
        if (vm_flags & VM_EXEC) perm |= PTE_X;

        // 逐页建立映射，新页先清零（同时覆盖 bss 部分）。
        uintptr_t seg_end = ph->p_va + ph->p_memsz;
        for (uintptr_t va = ROUNDDOWN(ph->p_va, PGSIZE); va < seg_end; va += PGSIZE)
        {
            if (get_page(mm->pgdir, va, NULL) == NULL)
            {
                struct Page *page = pgdir_alloc_page(mm->pgdir, va, perm);
                if (page == NULL)
                {
                    ret = -E_NO_MEM;
                    goto bad_cleanup_mmap;
                }
                memset(page2kva(page), 0, PGSIZE);
            }
        }

        // 把文件中的段内容拷贝到刚建立的映射中。
        uintptr_t src = (uintptr_t)binary + ph->p_offset;
        uintptr_t dst = ph->p_va;
        size_t left = ph->p_filesz;
        while (left > 0)
        {
            struct Page *page = get_page(mm->pgdir, dst, NULL);
            assert(page != NULL);
            size_t off = dst % PGSIZE;
            size_t n = (PGSIZE - off) < left ? (PGSIZE - off) : left;
            memcpy((void *)((uintptr_t)page2kva(page) + off), (void *)src, n);
            src += n;
            dst += n;
            left -= n;
        }
    }

    // 建立用户栈 vma，并预先映射全部栈页（本实验没有按需分页）。
    uintptr_t ustack_top = USERTOP;
    if ((ret = mm_map(mm, ustack_top - USTACKSIZE, USTACKSIZE,
                      VM_READ | VM_WRITE | VM_STACK, NULL)) != 0)
    {
        goto bad_cleanup_mmap;
    }
    for (uintptr_t va = ustack_top - USTACKSIZE; va < ustack_top; va += PGSIZE)
    {
        struct Page *page = pgdir_alloc_page(mm->pgdir, va, PTE_U | PTE_R | PTE_W);
        if (page == NULL)
        {
            ret = -E_NO_MEM;
            goto bad_cleanup_mmap;
        }
        memset(page2kva(page), 0, PGSIZE);
    }

    // 切换到新的用户地址空间。
    current->mm = mm;
    current->pgdir = PADDR(mm->pgdir);
    set_mm_count(mm, 1);
    write_csr(satp, ((uint64_t)SATP_MODE_SV39 << 60) |
                        (current->pgdir >> RISCV_PGSHIFT));
    flush_tlb();

    // 配置从用户态开始执行所需的 trapframe。
    current->tf->gpr.sp = ustack_top;
    current->tf->epc = elf->e_entry;
    // 清除 SPP 使 sret 返回用户态，置 SPIE 使用户态中断打开。
    current->tf->status = (read_csr(sstatus) & ~SSTATUS_SPP) | SSTATUS_SPIE;
    return 0;

bad_cleanup_mmap:
    exit_mmap(mm);
    put_pgdir(mm);
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
bad_mm:
    return ret;
}

// do_execve - 回收当前进程的旧地址空间并装载新程序映像。
int do_execve(const char *name, size_t len, unsigned char *binary, size_t size)
{
    struct mm_struct *mm = current->mm;

    // name 在首次内核线程启动时位于内核空间，之后可能来自用户空间。
    if (name == NULL || len == 0 || len > PROC_NAME_LEN ||
        !user_mem_check(mm, (uintptr_t)name, len, 0))
    {
        return -E_INVAL;
    }
    char local_name[PROC_NAME_LEN + 1];
    memset(local_name, 0, sizeof(local_name));
    memcpy(local_name, name, len);

    if (mm != NULL)
    {
        // 释放旧的用户地址空间，先切回内核页表。
        write_csr(satp, ((uint64_t)SATP_MODE_SV39 << 60) |
                            (boot_pgdir_pa >> RISCV_PGSHIFT));
        flush_tlb();
        if (mm_count_dec(mm) == 0)
        {
            exit_mmap(mm);
            put_pgdir(mm);
            mm_destroy(mm);
        }
        current->mm = NULL;
    }

    int ret;
    if ((ret = load_icode(binary, size)) != 0)
    {
        goto execve_exit;
    }
    set_proc_name(current, local_name);
    return 0;

execve_exit:
    do_exit(ret);
    panic("already exit: %e.\n", ret);
}

// kernel_execve - 内核线程调用 exec，并借助 trap 返回路径第一次进入用户态。
static int
kernel_execve(const char *name, unsigned char *binary, size_t size)
{
    int64_t ret = 0, len = strlen(name);

    // do_execve 负责准备好新映像和 trapframe。
    ret = do_execve(name, len, binary, size);
    if (ret < 0)
    {
        return ret;
    }

    // 直接跳到通用中断返回路径：以 current->tf 为栈顶恢复寄存器后 sret。
    extern void __trapret(void);
    asm volatile(
        "mv sp, %0\n"
        "j __trapret\n"
        :
        : "r"(current->tf)
        : "memory");
    return ret;
}

// user_main - 过渡内核线程，把自己 exec 成镜像中的用户程序。
static int
user_main(void *arg)
{
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
}

// do_wait - 等待指定子进程（pid 为 0 时等待任一子进程）并回收其资源。
int do_wait(int pid, int *code_store)
{
    struct mm_struct *mm = current->mm;
    if (code_store != NULL)
    {
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1))
        {
            return -E_INVAL;
        }
    }

    struct proc_struct *proc;
    bool intr_flag, haskid;
repeat:
    haskid = 0;
    // 将扫描子进程和进入睡眠状态放在同一临界区，避免错过 do_exit 的唤醒。
    local_intr_save(intr_flag);
    if (pid != 0)
    {
        proc = find_proc(pid);
        if (proc != NULL && proc->parent == current)
        {
            haskid = 1;
            if (proc->state == PROC_ZOMBIE)
            {
                goto found;
            }
        }
    }
    else
    {
        proc = current->cptr;
        for (; proc != NULL; proc = proc->optr)
        {
            haskid = 1;
            if (proc->state == PROC_ZOMBIE)
            {
                goto found;
            }
        }
    }

    if (haskid)
    {
        // 有子进程但尚未退出：睡眠等待，被唤醒后重新检查。
        current->state = PROC_SLEEPING;
        current->wait_state = WT_CHILD;
        schedule();
        local_intr_restore(intr_flag);
        if (current->flags & PF_EXITING)
        {
            do_exit(-E_KILLED);
        }
        goto repeat;
    }
    local_intr_restore(intr_flag);
    return -E_BAD_PROC;

found:
    local_intr_restore(intr_flag);
    if (proc == idleproc || proc == initproc)
    {
        panic("wait idleproc or initproc.\n");
    }
    if (code_store != NULL)
    {
        *code_store = proc->exit_code;
    }
    local_intr_save(intr_flag);
    {
        unhash_proc(proc);
        remove_links(proc);
    }
    local_intr_restore(intr_flag);
    put_kstack(proc);
    kfree(proc);
    return 0;
}

// init_main - 启动用户进程，并在其退出后完成启动阶段收尾。
static int
init_main(void *arg)
{
    int pid;
    if ((pid = kernel_thread(user_main, NULL, 0)) <= 0)
    {
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0)
    {
        schedule();
    }

    cprintf("all user-mode processes have quit.\n");
    // 输出初始化阶段的内存检查结果。
    cprintf("init check memory pass.\n");
    // initproc 需持续运行，以便接管并回收后续出现的孤儿进程。
    for (;;)
    {
        schedule();
    }
}

// 进程调度与切换（Lab4 遗留代码，在 Lab5 中继续使用）。
void proc_run(struct proc_struct *proc)
{
    if (proc == current)
    {
        return;
    }

    bool intr_flag;
    local_intr_save(intr_flag);

    struct proc_struct *prev = current;
    current = proc;

    uint64_t satp = ((uint64_t)SATP_MODE_SV39 << 60) |
                    (proc->pgdir >> RISCV_PGSHIFT);
    write_csr(satp, satp);
    flush_tlb();
    switch_to(&prev->context, &proc->context);

    local_intr_restore(intr_flag);
}

void cpu_idle(void)
{
    for (;;)
    {
        if (current->need_resched)
        {
            schedule();
        }
    }
}

