#include <unistd.h>
#include <proc.h>
#include <syscall.h>
#include <trap.h>
#include <stdio.h>
#include <pmm.h>
#include <assert.h>
#include <error.h>

// 系统调用分发表需要先看到各处理函数的声明。
static int sys_exit(uint64_t arg[]);
static int sys_fork(uint64_t arg[]);
static int sys_wait(uint64_t arg[]);
static int sys_exec(uint64_t arg[]);
static int sys_yield(uint64_t arg[]);
static int sys_kill(uint64_t arg[]);
static int sys_getpid(uint64_t arg[]);
static int sys_putc(uint64_t arg[]);
static int sys_pgdir(uint64_t arg[]);

static int (*syscalls[])(uint64_t arg[]) = {
    [SYS_exit]              sys_exit,
    [SYS_fork]              sys_fork,
    [SYS_wait]              sys_wait,
    [SYS_exec]              sys_exec,
    [SYS_yield]             sys_yield,
    [SYS_kill]              sys_kill,
    [SYS_getpid]            sys_getpid,
    [SYS_putc]              sys_putc,
    [SYS_pgdir]             sys_pgdir,
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

//lab5 function1 YOUR CODE
static int sys_exit(uint64_t arg[])
{
    int error_code = (int)arg[0];
    return do_exit(error_code);
}

static int sys_fork(uint64_t arg[])
{
    // 子进程从父进程当前的中断现场和用户栈开始运行。
    struct trapframe *tf = current->tf;
    uintptr_t stack = tf->gpr.sp;
    return do_fork(0, stack, tf);
}

static int sys_wait(uint64_t arg[])
{
    int pid = (int)arg[0];
    int *store = (int *)arg[1];
    return do_wait(pid, store);
}

static int sys_exec(uint64_t arg[])
{
    const char *name = (const char *)arg[0];
    size_t len = (size_t)arg[1];
    unsigned char *binary = (unsigned char *)arg[2];
    size_t size = (size_t)arg[3];
    return do_execve(name, len, binary, size);
}

static int sys_yield(uint64_t arg[])
{
    return do_yield();
}

static int sys_kill(uint64_t arg[])
{
    int pid = (int)arg[0];
    return do_kill(pid);
}

static int sys_getpid(uint64_t arg[])
{
    return current->pid;
}

static int sys_putc(uint64_t arg[])
{
    int c = (int)arg[0];
    cputchar(c);
    return 0;
}

static int sys_pgdir(uint64_t arg[])
{
    print_pgdir();
    return 0;
}

// syscall - 从当前进程的 trapframe 取出系统调用号和参数并分发。
void syscall(void)
{
    struct trapframe *tf = current->tf;
    uint64_t arg[5];
    int num = tf->gpr.a0;

    if (num >= 0 && num < NUM_SYSCALLS && syscalls[num] != NULL)
    {
        arg[0] = tf->gpr.a1;
        arg[1] = tf->gpr.a2;
        arg[2] = tf->gpr.a3;
        arg[3] = tf->gpr.a4;
        arg[4] = tf->gpr.a5;
        // 返回值写回 a0，异常返回后用户程序从 a0 读取结果。
        tf->gpr.a0 = syscalls[num](arg);
        return;
    }
    // 非法或未实现的系统调用号统一返回 -E_INVAL。
    tf->gpr.a0 = -E_INVAL;
}
