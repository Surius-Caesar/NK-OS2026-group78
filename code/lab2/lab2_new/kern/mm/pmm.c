#include <default_pmm.h>
#include <best_fit_pmm.h>
#include <defs.h>
#include <error.h>
#include <memlayout.h>
#include <mmu.h>
#include <pmm.h>
#include <sbi.h>
#include <stdio.h>
#include <string.h>
#include <riscv.h>
#include <dtb.h>

// virtual address of physical page array
struct Page *pages;
// amount of physical memory (in pages)
size_t npage = 0;
// the kernel image is mapped at VA=KERNBASE and PA=info.base
uint64_t va_pa_offset;
// memory starts at 0x80000000 in RISC-V
// DRAM_BASE defined in riscv.h as 0x80000000
const size_t nbase = DRAM_BASE / PGSIZE;

// virtual address of boot-time page directory
uintptr_t *satp_virtual = NULL;
// physical address of boot-time page directory
uintptr_t satp_physical;

// physical memory management
const struct pmm_manager *pmm_manager;


static void check_alloc_page(void);

// init_pmm_manager - initialize a pmm_manager instance
static void init_pmm_manager(void) {
    pmm_manager = &default_pmm_manager;
    cprintf("memory management: %s\n", pmm_manager->name);
    pmm_manager->init();
}

// init_memmap - call pmm->init_memmap to build Page struct for free memory
static void init_memmap(struct Page *base, size_t n) {
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
    return pmm_manager->alloc_pages(n);
}

// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    pmm_manager->free_pages(base, n);
}

// nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE)
// of current free memory
size_t nr_free_pages(void) {
    return pmm_manager->nr_free_pages();
}

//lab2 function1 2413410

/* page_init - detect physical memory and build the Page descriptor array */
static void page_init(void) {
    extern char end[];

    // get the physical memory range reported by the device tree
    uint64_t mem_base = get_memory_base();
    uint64_t mem_size = get_memory_size();
    if (mem_base == 0 || mem_size == 0 || mem_base != DRAM_BASE) {
        panic("page_init: invalid physical memory info (base = 0x%lx, size = 0x%lx)",
              mem_base, mem_size);
    }
    uint64_t mem_end = mem_base + mem_size;

    // set the kernel virtual/physical offset before any PADDR() is used
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;

    // npage is the exclusive upper bound of manageable page numbers. It must
    // follow the memory end reported by the device tree and must NOT be
    // truncated by PHYSICAL_MEMORY_END.
    npage = PPN(mem_end);
    if (npage <= nbase) {
        panic("page_init: no manageable physical page");
    }

    // the descriptor array starts at the page-aligned end of the kernel image
    pages = (struct Page *)ROUNDUP((uintptr_t)end, PGSIZE);
    size_t nr_pages = npage - nbase;

    // the area after `end` is not zeroed by kern_init(), so clear the array
    // explicitly and mark every page frame as reserved
    memset(pages, 0, nr_pages * sizeof(struct Page));
    for (size_t i = 0; i < nr_pages; i ++) {
        SetPageReserved(&pages[i]);
    }

    // compute the free page range in physical address space: it starts after
    // the descriptor array and ends at the page-aligned memory end, but never
    // beyond the physical memory limit of the framework
    uintptr_t pages_end_pa =
        PADDR((uintptr_t)pages + nr_pages * sizeof(struct Page));
    uintptr_t free_start_pa = ROUNDUP(pages_end_pa, PGSIZE);
    uintptr_t free_end_pa = ROUNDDOWN((uintptr_t)mem_end, PGSIZE);
    if (free_end_pa > PHYSICAL_MEMORY_END) {
        free_end_pa = PHYSICAL_MEMORY_END;
    }

    // only hand over complete free pages; an empty range is legal
    if (free_end_pa > free_start_pa) {
        struct Page *base = pa2page(free_start_pa);
        size_t n = (free_end_pa - free_start_pa) >> PGSHIFT;
        init_memmap(base, n);
    }

    cprintf("physical memory map:\n");
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_base,
            mem_base + mem_size - 1);
}


/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
    // We need to alloc/free the physical memory (granularity is 4KB or other size).
    // So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    // First we should init a physical memory manager(pmm) based on the framework.
    // Then pmm can alloc/free the physical memory.
    // Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();

    // use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();

    extern char boot_page_table_sv39[];
    satp_virtual = (pte_t*)boot_page_table_sv39;
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
    cprintf("check_alloc_page() succeeded!\n");
}
