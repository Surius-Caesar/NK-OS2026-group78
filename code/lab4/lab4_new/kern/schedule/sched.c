#include <list.h>
#include <sync.h>
#include <proc.h>
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
    proc->state = PROC_RUNNABLE;
}

//LAB4 function3 2413993
void
schedule(void)
{
    bool intr_flag;
    local_intr_save(intr_flag);

    struct proc_struct *prev = current;
    prev->need_resched = 0;

    list_entry_t *head = &proc_list;
    list_entry_t *start = (prev == idleproc) ? head : &prev->list_link;
    list_entry_t *le = start;
    struct proc_struct *next = idleproc;

    while ((le = list_next(le)) != start)
    {
        if (le == head)
        {
            continue;
        }
        struct proc_struct *proc = le2proc(le, list_link);
        if (proc->state == PROC_RUNNABLE)
        {
            next = proc;
            break;
        }
    }

    next->runs++;
    if (next != prev)
    {
        proc_run(next);
    }

    local_intr_restore(intr_flag);
}


