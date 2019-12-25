# 实验五:用户进程管理

**实验目的**

- **了解第一个用户进程创建过程**
- **了解系统调用框架的实现机制**
- **了解ucore如何实现系统调用sys_fork/sys_exec/sys_exit/sys_wait来进行进程管理**

**实验内容**
**实验4完成了内核线程,但到目前为止,所有的运行都在内核态执行。实验5将创建用户进**
**程,让用户进程在用户态执行,且在需要ucore支持时,可通过系统调用来让ucore提供服**
**务。为此需要构造出第一个用户进程,并通过系统调用sys_fork/sys_exec/sys_exit/sys_wait**
**来支持运行不同的应用程序,完成对用户进程的执行过程的基本管理。相关原理介绍可看附**
**录B。**

## 练习0:填写已有实验

### 0.1 `meld `

```
lab1:trap.c  kdebug.c
lab2:pmm.c default_pmm.c 
lab3:swap_fifo.c vmm.c 
lab4:proc.c
```

make qemu

```
write Virt Page1 e in fifo_check_swap
page fault at 0x00005000: K/W [no page found].
swap_out: i 0, store page in vaddr 0x1000 to disk swap entry 2
swap_in: load disk swap entry 6 with swap_page in vadr 0x5000
write Virt Page a in fifo_check_swap
page fault at 0x00001000: K/R [no page found].
swap_out: i 0, store page in vaddr 0x2000 to disk swap entry 3
swap_in: load disk swap entry 2 with swap_page in vadr 0x1000
count is 5, total is 5
check_swap() succeeded!
++ setup timer interrupts
100 ticks
100 ticks
```

### 0.2 `update`

根据写在代码里的`update`提示：

`idt_init()`:

```c
/* LAB5 YOUR CODE */
    //so you should setup the syscall interrupt gate in here
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
    }
    SETGATE(idt[T_SYSCALL], 1, GD_KTEXT, __vectors[T_SYSCALL], DPL_USER);
    lidt(&idt_pd);
```

特殊的中断描述符：`idt[T_SYSCALL]`：特权级为`DPL_USER`，中断向量处理地址在`__vectors[T_SYSCALL]`. 因为特权级是用户，所以可被用户进程调用，CPU就会从用户态切换到内核态，保存相关寄存器，并跳转到`__vectors[T_SYSCALL]`处开始执行。

`trap_dispatch()`:

```c
//Every TICK_NUM cycle, you should set current process's current->need_resched = 1
ticks ++;
        if (ticks % TICK_NUM == 0) {
            assert(current != NULL);
            current->need_resched = 1;
        }
```

`alloc_proc()`

```c
//LAB5 YOUR CODE : (update LAB4 steps)
     /* below fields(add in LAB5) in proc_struct need to be initialized	
     * uint32_t wait_state;                        // waiting state
     * struct proc_struct *cptr, *yptr, *optr;     // relations between processes*/
     proc->wait_state = 0;//初始化进程等待状态
	 proc->cptr = proc->optr = proc->yptr = NULL;//指针初始化孩,旧兄弟,新兄弟
```

`do_fork()`

```c
//LAB5 YOUR CODE : (update LAB4 steps)
   /*set_links:  set the relation links of process.  ALSO SEE: remove_links:  lean the relation links of process 
    * ------------------
	*update step 1: set child proc's parent to current process, make sure current process's wait_state is 0
	*update step 5: insert proc_struct into hash_list && proc_list, set the relation links of process */
```

```c
assert(current->wait_state == 0);//确保等待
```

```c
set_links(proc);//插入进程表哈希表时，设置链接
```

`set_links()`

```c
// set_links - set the relation links of process
static void
set_links(struct proc_struct *proc) {
    list_add(&proc_list, &(proc->list_link));//把进程加入进程链表
    proc->yptr = NULL;//当前进程的新兄弟指针指向null
    if ((proc->optr = proc->parent->cptr) != NULL) {
        proc->optr->yptr = proc;//当前进程的旧兄弟的新兄弟就是当前进程
    }
    proc->parent->cptr = proc;//父进程的子进程是当前进程
    nr_process ++;//进程数+1
}
```

## 练习1: 加载应用程序并执行（需要编码）

**`do_execv`函数调用`load_icode`（位于`kern/process/proc.c`中）来加载并解析一个处于内存中的ELF执行文件格式的应用程序，建立相应的用户内存空间来放置应用程序的代码段、数据段等，且要设置好`proc_struct`结构中的成员变量trapframe中的内容，确保在执行此进程后，能够从应用程序设定的起始执行地址开始执行。需设置正确的trapframe内容。请在实验报告中简要说明你的设计实现过程。**

**请在实验报告中描述当创建一个用户态进程并加载了应用程序后，CPU是如何让这个应用程序最终在用户态执行起来的。即这个用户态进程被ucore选择占用CPU执行（RUNNING态）到具体执行应用程序第一条指令的整个经过。**

### 1.1 function `do_execve`：执行`elf`格式二进制代码

`proc.c`

```c
 call exit_mmap(mm)&put_pgdir(mm) to reclaim memory space of current process
 //回收当前进程的内存空间
 call load_icode to setup new memory space accroding binary prog.
 //创建新代码段空间
 //倒空瓶->填新酒
```

```c
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
    struct mm_struct *mm = current->mm;//获取当前进程的内存地址
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
        return -E_INVAL;
    }
    if (len > PROC_NAME_LEN) {
        len = PROC_NAME_LEN;
    }
    char local_name[PROC_NAME_LEN + 1];
    memset(local_name, 0, sizeof(local_name));
    memcpy(local_name, name, len);//开始准备用户态的内存空间
    if (mm != NULL) {
        lcr3(boot_cr3); //设置页表基址指向内核页表
        if (mm_count_dec(mm) == 0) {//没有进程需该内存空间
            exit_mmap(mm);//退出mmap 清空页表  清空内存管理区域
            put_pgdir(mm);
            mm_destroy(mm);
        }
        current->mm = NULL;//把当前进程的 mm 内存管理指针为空
    }
    int ret;
    //加载应用程序执行码到当前进程的新创建的用户态虚拟空间中
    //load_icode完成上述整个工作
    if ((ret = load_icode(binary, size)) != 0) {
        goto execve_exit;
    }
    set_proc_name(current, local_name);
    return 0;

execve_exit:
    do_exit(ret);
    panic("already exit: %e.\n", ret);
}
```

准备空间->清空原进程页表，mm(只留下空壳)-> 加载用户进程 ->重新分配mm,段页表->分配物理页，根据elf文件申请vma，构建完整映射(&页表起始空间从内核换回)->中断帧设置完成特权转换

### 1.2   function `load_icode`： 加载应用程序执行码

`kern/process/proc.c`

已有代码:

```c
static int
load_icode(unsigned char *binary, size_t size) {
    if (current->mm != NULL) {   //当前进程的内存为空
        panic("load_icode: current->mm must be empty.\n");
    }
    int ret = -E_NO_MEM;//未分配
    struct mm_struct *mm;
    //(1) create a new mm for current process 分配mem manager空间
    if ((mm = mm_create()) == NULL) {
        goto bad_mm;
    }
    //(2) create a new PDT, and mm->pgdir= kernel virtual addr of PDT
    if (setup_pgdir(mm) != 0) {  //建立新的页表
        goto bad_pgdir_cleanup_mm;
    }
    //(3) copy TEXT/DATA section, build BSS parts in binary to memory space of process
    //bootloader 加载ucore时一并加载进内存(毕竟还没有文件系统嘛)
    //只要找到hello内存起始地址，解析elf 就能找到代码段数据段
    
     struct Page *page;
    //(3.1) get the file header of the bianry program (ELF format)
    struct elfhdr *elf = (struct elfhdr *)binary;
    //(3.2) get the entry of the program section headers of the bianry program (ELF format)  获取段头部表的地址
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
    //(3.3) This program is valid? //读取的 ELF 文件不合法
   	if (elf->e_magic != ELF_MAGIC) {
        ret = -E_INVAL_ELF;
        goto bad_elf_cleanup_pgdir;
    }
    uint32_t vm_flags, perm;
    struct proghdr *ph_end = ph + elf->e_phnum;    //段入口数目
    for (; ph < ph_end; ph ++) { //(3.4) find every program section headers
        if (ph->p_type != ELF_PT_LOAD) {//当前段不能被加载
            continue ;
        }
        if (ph->p_filesz > ph->p_memsz) {//虚拟地址空间大小大于分配的物理地址空间
            ret = -E_INVAL_ELF;
            goto bad_cleanup_mmap;
        }
        if (ph->p_filesz == 0) {  //当前段大小为 0
            continue ;
        }
         //(3.5) call mm_map fun to setup the new vma ( ph->p_va, ph->p_memsz)
        //mm_map函数根据ELF给出代码段、数据段、BSS段等的起始位置和大小建立对应的vma结构合法空间
        vm_flags = 0, perm = PTE_U;
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;//code 可执行
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;//data可读可写
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
        if (vm_flags & VM_WRITE) perm |= PTE_W;
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) 		{
            goto bad_cleanup_mmap;
        }
        unsigned char *from = binary + ph->p_offset;
        size_t off, size;
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
        ret = -E_NO_MEM;
		//(3.6) alloc memory, and  copy the contents of every program section (from, from+end) to process's memory (la, la+end)
     //分配物理内存空间，拷贝到内核虚拟地址
        end = ph->p_va + ph->p_filesz;
        while (start < end) {  //(3.6.1) copy TEXT/DATA section of bianry program
            //分配新的物理页
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
            if (end < la) {
                size -= la - end;
            }
            memcpy(page2kva(page) + off, from, size);//拷进来
            start += size, from += size;
        }
 //(3.6.2) build BSS section of binary program  建立BSS段(清空)  all zero mem
        end = ph->p_va + ph->p_memsz;
        if (start < la) {
            /* ph->p_memsz == ph->p_filesz */
            if (start == end) {
                continue ;
            }
            off = start + PGSIZE - la, size = PGSIZE - off;
            if (end < la) {
                size -= la - end;
            }
            memset(page2kva(page) + off, 0, size);
            start += size;
            assert((end < la && start == end) || (end >= la && start == la));
        }
        while (start < end) {
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
            if (end < la) {
                size -= la - end;
            }
            memset(page2kva(page) + off, 0, size);
            start += size;
        }
    }
    //(4) build user stack memory  给用户进程设置用户栈，
    //mm_map建立用户栈vma
    vm_flags = VM_READ | VM_WRITE | VM_STACK;
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {//user stack
        goto bad_cleanup_mmap;
    }
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);//新的页表映射关系
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
    
    //至此内存空间初始化基本完成
    //最后把页表的起始地址从内核换回来，换到新建的mm->pgfir
    
    //(5) set current process's mm, sr3, and set CR3 reg = physical addr of Page Directory
    mm_count_inc(mm);
    current->mm = mm;
    current->cr3 = PADDR(mm->pgdir);
    lcr3(PADDR(mm->pgdir));
    //至此用户空间初始化完成
    //lcr3的时间比修改tf 久的多所以进程切换比线程切换消耗性能更大
```

补全代码：

最后一部分：set up `tf` 实现用户态内核态转换 特权级转变

goal : the user level process can return to USER MODE from kernel         能回到用户态

```c
//(6) setup trapframe for user environment
    struct trapframe *tf = current->tf;
    memset(tf, 0, sizeof(struct trapframe));
    /* LAB5:EXERCISE1 YOUR CODE
     * should set tf_cs,tf_ds,tf_es,tf_ss,tf_esp,tf_eip,tf_eflags
     * NOTICE: If we set trapframe correctly, then the user level process can return to USER MODE from kernel. So
     *          tf_cs should be USER_CS segment (see memlayout.h)
     *          tf_ds=tf_es=tf_ss should be USER_DS segment
     *          tf_esp should be the top addr of user stack (USTACKTOP)
     *          tf_eip should be the entry point of this binary program (elf->e_entry)
     *          tf_eflags should be set to enable computer to produce Interrupt
     */
    //将段寄存器初始化为用户态的代码段、数据段、堆栈段
    tf->tf_cs = USER_CS;
    tf->tf_ds = tf->tf_es = tf->tf_ss = USER_DS;
    tf->tf_esp = USTACKTOP;//esp指向用户栈的栈顶
    tf->tf_eip = elf->e_entry;//eip指向elf可执行文件加载到内存后的入口处
   	tf->tf_eflags = FL_IF;//eflags初始化为中断使能
    ret = 0;
```

### 1.3 描述当创建一个用户态进程并加载了应用程序后，CPU是如何让这个应用程序最终在用户态执行起来的。

即这个用户态进程被ucore选择占用CPU执行（RUNNING态）到具体执行应用程序第一条指令的整个经过。

1. 执行宏`KERNEL_EXECVE`，调用`kernel_execve`函数产生`exec`系统调用

2. 中断：把相关寄存器内容保存到中断帧`trapframe`中，开启系统调用服务；`syscall`->`sys_exec`

3. `sys_exec`->`do_execve`完成用户进程的创建工作

4. `load_icode`初始化整个用户线程内存空间，加载hello 的 ELF，修改当前系统调用的`trapframe`使最终中断返回的时候能够切换到用户态
5. 返回，中断处理例程的栈上面的eip已经被修改成了应用程序的入口处，而cs上的CPL是用户态。所以执行用户态程序

## 练习2: 父进程复制自己的内存空间给子进程(需要编码)

**创建子进程的函数do_fork在执行中将拷贝当前进程(即父进程)的用户内存地址空间中的合**
**法内容到新进程中(子进程),完成内存资源的复制。具体是通过copy_range函数(位于**
**kern/mm/pmm.c中)实现的,请补充copy_range的实现,确保能够正确执行。**
**请在实验报告中简要说明如何设计实现”Copy on Write 机制“,给出概要设计,鼓励给出详细**
**设计。**

### 2.1 函数调用

注释中：call graph:`do_fork()-->copy_mm()-->dup_mmap()-->copy_range()`

在lab 4中 `copy_mm()`在 `do_fork()`的调用：

```c
assert(copy_mm(clone_flags, proc) == 0); //复制父进程的内存信息到子进程
```

`copy_mm()`： 设置共享or复制      调用 `dup_mmap()`：复制

```c
// copy_mm - process "proc" duplicate OR share process "current"'s mm according clone_flags 根据clone_flags 判断是否共享地址空间
//if clone_flags & CLONE_VM, then "share" ; else "duplicate"
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
    struct mm_struct *mm, *oldmm = current->mm;
    /* current is a kernel thread */
    if (oldmm == NULL) {
        return 0;
    }
    if (clone_flags & CLONE_VM) {  //可共享地址空间
        mm = oldmm;
        goto good_mm;
    }
    int ret = -E_NO_MEM;
    if ((mm = mm_create()) == NULL) {goto bad_mm;}//创建mem manager
    if (setup_pgdir(mm) != 0) {goto bad_pgdir_cleanup_mm;}//申请页目录表
    lock_mm(oldmm);//设置锁
    {ret = dup_mmap(mm, oldmm);}//dup_mmap()
    unlock_mm(oldmm);//解锁
    if (ret != 0) {goto bad_dup_cleanup_mmap;}

good_mm:
    mm_count_inc(mm);//进程数+1
    proc->mm = mm;//复制空间  地址
    proc->cr3 = PADDR(mm->pgdir);//复制页表地址
    return 0;
bad_dup_cleanup_mmap:
    exit_mmap(mm);
    put_pgdir(mm);
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
bad_mm:
    return ret;
}
```

`vmm.c` :`dup_mmap()`: 复制：为新进程创建合法`vma`

```c
int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
    assert(to != NULL && from != NULL); //mmap_list为虚拟地址空间的首地址
    list_entry_t *list = &(from->mmap_list), *le = list; //获取虚拟空间地址
    while ((le = list_prev(le)) != list) {    //遍历所有段
        struct vma_struct *vma, *nvma;
        vma = le2vma(le, list_link);      //新建合法vma
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }
        insert_vma_struct(to, nvma);  //向新进程插入新的段
        bool share = 0;//设置不共享
        //调用copy_range函数
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
            return -E_NO_MEM;
        }
    }
    return 0;
}
```

所以x实际上可以看出`copy_range()`负责的是具体内容的拷贝

复制过程：`(new tcb & tf & others-->mm-->pgdir-->vma-->content)`

​       						   fork                      mm               dup         range

### 2.2 补全 `copy_range()`

`pmm.c`:

```c
/* copy_range - copy content of memory (start, end) of one process A to another process B
 * @to:    the addr of process B's Page Directory
 * @from:  the addr of process A's Page Directory
 * @share: flags to indicate to dup OR share. We just use dup method, so it didn't be used.
 *
 * CALL GRAPH: copy_mm-->dup_mmap-->copy_range
 */
int
copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end, bool share) {
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
    assert(USER_ACCESS(start, end));// encure input correct
    // copy content by page unit.
    do {
 		//call get_pte to find process A's pte according to the addr start
        pte_t *ptep = get_pte(from, start, 0), *nptep;
        if (ptep == NULL) {//如果二级页表不存在分配新的
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
            continue ;
        }
        //call get_pte to find process B's pte according to the addr start. If pte is NULL, just alloc a PT
        if (*ptep & PTE_P) {
            if ((nptep = get_pte(to, start, 1)) == NULL) {
                return -E_NO_MEM;
            }
        uint32_t perm = (*ptep & PTE_USER);
        //get page from ptep
        struct Page *page = pte2page(*ptep);
        // alloc a page for process B
        struct Page *npage=alloc_page();
        assert(page!=NULL);
        assert(npage!=NULL);
        int ret=0;
        /* LAB5:EXERCISE2 YOUR CODE
         * replicate content of page to npage, build the map of phy addr of nage with the linear addr start
         *
         * Some Useful MACROs and DEFINEs, you can use them in below implementation.
         * MACROs or Functions:
         *    page2kva(struct Page *page): return the kernel vritual addr of memory which page managed (SEE pmm.h)
         *    page_insert: build the map of phy addr of an Page with the linear addr la
         *    memcpy: typical memory copy function
         *
         * (1) find src_kvaddr: the kernel virtual address of page
         * (2) find dst_kvaddr: the kernel virtual address of npage
         * (3) memory copy from src_kvaddr to dst_kvaddr, size is PGSIZE
         * (4) build the map of phy addr of  nage with the linear addr start
         */
        void * kva_src = page2kva(page);//找到应复制的物理页在内核的虚拟地址
        void * kva_dst = page2kva(npage);//找到接收内容的子进程的内核虚拟地址
    
        memcpy(kva_dst, kva_src, PGSIZE);//复制

        ret = page_insert(to, npage, start, perm);//建立虚拟页&物理页映射
        assert(ret == 0);
        }
        start += PGSIZE;
    } while (start != 0 && start < end);
    return 0;
}
```

### 2.3 `Copy on Write ` 

#### 题目：

Copy-on-write(简称COW)的基本概念是指如果有多个使用者对一个资源A(比如内存
块)进行读操作,则每个使用者只需获得一个指向同一个资源A的指针,就可以该资源
了。若某使用者需要对这个资源A进行写操作,系统会对该资源进行拷贝操作,从而使得
该“写操作”使用者获得一个该资源A的“私有”拷贝—资源B,可对资源B进行写操作。该“写
操作”使用者对资源B的改变对于其他的使用者而言是不可见的,因为其他使用者看到的
还是资源A。

简要说明如何设计实现”Copy on Write 机制“,给出概要设计,鼓励给出详细设计。

#### 简要设计：

1. 修改do_fork，取消直接复制内存，而是让子进程虚拟页也绑定上父进程的物理页
2. 设置该物理页为不可写状态，如果被写入，产生page_fault，并且给page_fault()传递触发COW机制的信息（设个标志位？flag？）如果想并发写入，阻塞。
3. page_fault() 处理这个有特殊标志位的缺页时，申请新物理页，duplicate it. 引起缺页异常的进程构建起新的映射，然后写入。完成后，再复制回去。

### 2.4 result：

执行make grade: 所有的check result 都是wrong  看起来是进程创建出了错。（去答案文件夹make grade 得91分……但是它的output都是错的，而我result 都是错的）

```
  -check output:                             OK
Total Score: 45/150
Makefile:314: recipe for target 'grade' failed
make: *** [grade] Error 1
```

对比了网上下载的别人的源码，发现自己很多地方的代码都不一样……不知道是不是中间什么时候不小心错删了一些代码

对lab 4执行 make grade:

```
Check VMM:               (3.4s)
  -check pmm:                                OK
  -check page table:                         OK
  -check vmm:                                OK
  -check swap page fault:                    OK
  -check ticks:                              OK
  -check initproc:                           OK
Total Score: 90/90
```

然后计划用一份新的lab 5再试一次：（lab 5 copy)  可能做完整个作业之后把不需要的文件夹全清除了吧

#### `meld diff`:

（一直没push)

![image-20191218223257984](/home/cyhor/.config/Typora/typora-user-images/image-20191218223257984.png)

修改完上面的文件加入lab 5的代码之后：

make grade:

```
exit:                    (1.3s)
  -check result:                             OK
  -check output:                             OK
spin:                    (4.2s)
  -check result:                             OK
  -check output:                             OK
waitkill:                (13.1s)
  -check result:                             OK
  -check output:                             OK
forktest:                (1.2s)
  -check result:                             OK
  -check output:                             OK
forktree:                (1.2s)
  -check result:                             OK
  -check output:                             OK
Total Score: 150/150
```

估计可能是之前手动meld的时候哪里文件不小心删多了……（发现能确定至少pmm.c少了……）

## 练习3: 阅读分析源代码，理解进程执行 fork/exec/wait/exit 的实现，以及系统调用的实现（不需要编码）

**请在实验报告中简要说明你对 fork/exec/wait/exit函数的分析。并回答如下问题：**

**请分析fork/exec/wait/exit在实现中是如何影响进程的执行状态的？**
**请给出ucore中一个用户态进程的执行状态生命周期图（包执行状态，执行状态之间的变换关系，以及产生变换的事件或函数调用）。（字符方式画即可）**

### 3.1 `fork/exec/wait/exit`&分析

#### fork:

lab 4 中完成了`do_fork()`,主要功能是完成内核线程创建。在lab 5中加入 wait_state设置。创建完子进程后调用wakeup_proc(proc) 唤醒。

#### exec:

lab5: 加载可执行文件.  一般先 fork 在加载新的代码数据等。本实验中，完成了用户进程创建

#### walit:

完成回收当前进程的子进程内核栈和TCB内存空间的工作

`kern/process/proc.c`

```c
// do_wait - wait one OR any children with PROC_ZOMBIE state, and free memory space of kernel stack
//- proc struct of this child.
// NOTE: only after do_wait function, all resources of the child proces are free.
int
do_wait(int pid, int *code_store) {
    struct mm_struct *mm = current->mm;
    if (code_store != NULL) {
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
            return -E_INVAL;
        }
    }
    struct proc_struct *proc;
    bool intr_flag, haskid;
repeat:
    haskid = 0;
    if (pid != 0) {    //如果pid 不为0且子进程state=zombie就开始回收
        proc = find_proc(pid);
        if (proc != NULL && proc->parent == current) {
            haskid = 1;    //进程为当前进程子进程
            if (proc->state == PROC_ZOMBIE) {
                goto found;
            }
        }
    }
    else {   //如果pid为0，那就随便找个zombie
        proc = current->cptr;
        for (; proc != NULL; proc = proc->optr) {
            haskid = 1;
            if (proc->state == PROC_ZOMBIE) {
                goto found;
            }
        }
    }
    if (haskid) {//不是zombie：子进程没有退出，那么设置当前进程为睡眠
        current->state = PROC_SLEEPING;
        current->wait_state = WT_CHILD;  //睡眠：等待子进程
        schedule();//选择新的进程执行
        if (current->flags & PF_EXITING) {
            do_exit(-E_KILLED);
        }
        goto repeat;
    }
    return -E_BAD_PROC;

found://回收
    if (proc == idleproc || proc == initproc) {
        panic("wait idleproc or initproc.\n");
    }
    if (code_store != NULL) {
        *code_store = proc->exit_code;
    }
    local_intr_save(intr_flag);
    {
        unhash_proc(proc);
        remove_links(proc);//从链表和哈希表删除
    }
    local_intr_restore(intr_flag);
    put_kstack(proc);//释放空间
    kfree(proc);
    return 0;
}
```

#### exit:

```c
// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int
do_exit(int error_code) {
    if (current == idleproc) {
        panic("idleproc exit.\n");
    }
    if (current == initproc) {
        panic("initproc exit.\n");
    }
    
    struct mm_struct *mm = current->mm;
    if (mm != NULL) {  //用户进程
        lcr3(boot_cr3);//换回内核态页表
        if (mm_count_dec(mm) == 0) {//没有进程共享此空间
            exit_mmap(mm);//release places discribed by vma including mem & pte & pde
            put_pgdir(mm);//release pde of current process
            mm_destroy(mm);//release vma&mm 
        }
        current->mm = NULL;//(virtual) release finished
    }
    current->state = PROC_ZOMBIE;//set state = zombie 
    current->exit_code = error_code;//set exit_code
    //no further schedule
    
    //further release
    bool intr_flag;
    struct proc_struct *proc;
    local_intr_save(intr_flag);
    {
        proc = current->parent;
        if (proc->wait_state == WT_CHILD) {//如果父进程(proc)已经被设置为等子进程（curr)
            wakeup_proc(proc);
        }
        while (current->cptr != NULL) {//如果当前proc还有子进程
            proc = current->cptr;
            current->cptr = proc->optr;
    
            proc->yptr = NULL;//新孩子空
            //所有子进程交给initproc
            if ((proc->optr = initproc->cptr) != NULL) {
                initproc->cptr->yptr = proc;
            }
            proc->parent = initproc;
            initproc->cptr = proc;
            if (proc->state == PROC_ZOMBIE) {  //zombie 则回收
                if (initproc->wait_state == WT_CHILD) {
                    wakeup_proc(initproc);
                }
            }
        }
    }
    local_intr_restore(intr_flag);
    schedule();//选择新的受害者
    panic("do_exit will not return!! %d.\n", current->pid);
}
```

#### 分析：

1. fork创建新进程，父进程不受影响，子进程从uninit 到runnable
2. exec 加载程序 完成用户进程创建
3. wait 回收当前进程的zombie子进程 。如果需要等子进程结束，变成sleeping
4. exit 回收进程

### 3.2 生命周期图：

![](https://tva1.sinaimg.cn/large/006tNbRwly1g9wn73j7kaj30fu09rq3j.jpg)

