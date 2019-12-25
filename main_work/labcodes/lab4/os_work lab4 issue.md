# Lab4:内核线程管理

**实验目的**

- **了解内核线程创建/执行的管理过程**
- **了解内核线程的切换和基本调度过程**

**实验内容**
**实验2/3完成了物理和虚拟内存管理,这给创建内核线程(内核线程是一种特殊的进程)打下**
**了提供内存管理的基础。当一个程序加载到内存中运行时,首先通过ucore OS的内存管理子**
**系统分配合适的空间,然后就需要考虑如何分时使用CPU来“并发”执行多个程序,让每个运行**
**的程序(这里用线程或进程表示)“感到”它们各自拥有“自己”的CPU。**

**本次实验将首先接触的是内核线程的管理。内核线程是一种特殊的进程,内核线程与用户进**
**程的区别有两个:**

- **内核线程只运行在内核态**
- **用户进程会在在用户态和内核态交替运行**
- **所有内核线程共用ucore内核内存空间,不需为每个内核线程维护单独的内存空间**
- **而用户进程需要维护各自的用户内存空间**

## 练习0:填写已有实验

```
vmm.c 
trap.c 
default_pmm.c 
pmm.c 
swap_fifo.c
kdebug.c
```

make qemu:

```
use SLOB allocator
kmalloc_init() succeeded!
check_vma_struct() succeeded!
page fault at 0x00000100: K/W [no page found].
check_pgfault() succeeded!
check_vmm() succeeded.
kernel panic at kern/process/proc.c:353:
    create init_main failed.
```

## 练习1：分配并初始化一个进程控制块（需要编码）

**alloc_proc函数(位于kern/process/proc.c中)负责分配并返回一个新的struct proc_struct结**
**构,用于存储新建立的内核线程的管理信息。ucore需要对这个结构进行最基本的初始化,你**
**需要完成这个初始化过程。**

```
在alloc_proc函数的实现中,需要初始化的proc_struct结构中的成员变量至少包括:
state/pid/runs/kstack/need_resched/parent/mm/context/tf/cr3/flags/name。
```

**请说明`proc_struct`中`struct context context`和`struct trapframe *tf`成员变量含义和在**
**本实验中的作用是啥?(提示通过看代码和编程调试可以判断出来)**

内核线程是特殊进程

内核线程与用户进程的区别：

- 内核线程只运行在内核态而用户进程会在用户态和内核态交替运行；

- 所有内核线程直接使用共同的ucore内核内存空间，不需为每个内核线程维护单独的内存空间。而用户进程需要维护各自的用户内存空间

### 1.1 `proc_struct`   即 TCB  thread  ctrl box 线程控制块

```c
struct proc_struct {
    enum proc_state state;            // Process state
    int pid;                          // Process ID
    int runs;                         // the running times of Proces
    uintptr_t kstack;                 // Process kernel stack
    volatile bool need_resched;       // bool value: need to be rescheduled to release CPU?
    struct proc_struct *parent;       // the parent process
    struct mm_struct *mm;             // Process's memory management field
    struct context context;           // Switch here to run process
    struct trapframe *tf;             // Trap frame for current interrupt
    uintptr_t cr3;                // CR3 register: the base addr of Page Directroy Table(PDT)
    uint32_t flags;                   // Process flag
    char name[PROC_NAME_LEN + 1];     // Process name
    list_entry_t list_link;           // Process link list 
    list_entry_t hash_link;           // Process hash list
};
```

- id 信息：

  pid：进程`id`   name: 进程名  适合`memset`初始化

- 运行调度管理信息：动态运行相关

  state: 进程状态  就绪 运行 等待    随线程运行，状态变化              runs    flags ：运行细节   need_resched 是否调度

- 内存管理信息：

  kstack: 内核线程的内核堆栈   cr3: 保存页表的物理地址 内核线程对应进程这里就是ucore os  所以初始化boot_cr3

  mm : 进程合法内存空间    vma : 合法内存空间的系列内存块   OS中，内核线程常驻内存，so 在lab4中，内核线程的`proc_struct`的成员变量`*mm=0`

- 中断信息

  context : 上下文，表示运行状态，本质就是一堆寄存器 切换上下文即切换寄存器      `kern/process/switch.S switch_to`

  trap_frame : 保存被中断异常打断的进程线程状态           tf :中断帧的指针,永远指向内核某位置

    {esp ss 特权级变换时需要压栈的信息（来自网课）}

  - others 两个link

  `parent`：用户进程的父进程。在所有进程中，只有`idleproc`没有父进程。

  两个list: list_link 就是进线程list  hash_list 是为了加快查找速度建的依据`pid`哈希List

### 1.2 init     `alloc_proc`函数

```c
		proc->state = PROC_UNINIT;//设置进程为未初始化状态
        proc->pid = -1; //未初始化的的进程id为-1
        proc->runs = 0;//初始化时间片
        proc->kstack = 0; //内存栈的地址
        proc->need_resched = 0;//不需要调度
        proc->parent = NULL;  //父节点null
        proc->mm = NULL;      //内核线程常驻内存
        memset(&(proc->context), 0, sizeof(struct context));//上下文初始化0
        proc->tf = NULL; //中断帧指针null
        proc->cr3 = boot_cr3;//页目录设为内核页目录表的基址
        proc->flags = 0;//标志位0
        memset(proc->name, 0, PROC_NAME_LEN);//进程名设为0
```

### 1.3  请说明`proc_struct`中`struct context context`和`struct trapframe *tf`成员变量含义和在本实验中的作用是啥？

#### `struct context `

ucore中所有进程在内核中是相对独立的。

context 保存寄存器状态，方便在内核态中能够进行上下文切换

```c
// Saved registers for kernel context switches.
// Don't need to save all the %fs etc. segment registers,
// because they are constant across kernel contexts.
// Save all the regular registers so we don't need to care
// which are caller save, but not the return register %eax.
// (Not saving %eax just simplifies the switching code.)
// The layout of context must match code in switch.S.
struct context {
    uint32_t eip;//low addr
    uint32_t esp;
    uint32_t ebx;
    uint32_t ecx;
    uint32_t edx;
    uint32_t esi;
    uint32_t edi;
    uint32_t ebp;// high addr
};//除了eax所有通用寄存器  && eip
```

`kern/process/switch.S`    

EIP是不能忽略的一项

保存从low->high 恢复反过来 然后：eip 会直接被放在栈顶，这样 ret 就使能下个进程

```
switch_to:                      # switch_to(from, to)
	# save from's registers
    movl 4(%esp), %eax          # eax points to from
    popl 0(%eax)                # save eip !popl
    movl %esp, 4(%eax)          # save esp::context of from
    movl %ebx, 8(%eax)          # save ebx::context of from
    movl %ecx, 12(%eax)         # save ecx::context of from
    movl %edx, 16(%eax)         # save edx::context of from
    movl %esi, 20(%eax)         # save esi::context of from
    movl %edi, 24(%eax)         # save edi::context of from
    movl %ebp, 28(%eax)         # save ebp::context of from
    # restore to's registers
    movl 4(%esp), %eax          # not 8(%esp): popped return address already
                                # eax now points to to
    movl 28(%eax), %ebp         # restore ebp::context of to
    movl 24(%eax), %edi         # restore edi::context of to
    movl 20(%eax), %esi         # restore esi::context of to
    movl 16(%eax), %edx         # restore edx::context of to
    movl 12(%eax), %ecx         # restore ecx::context of to
    movl 8(%eax), %ebx          # restore ebx::context of to
    movl 4(%eax), %esp          # restore esp::context of to
    pushl 0(%eax)               # push eip
    ret
```

#### `struct trapframe *tf`

`kern/trap/trap.h`

更详细的中断信息记录，作用比context更复杂(内容更多)  `tf`：中断帧的指针

包含`context`的信息，还保存有段寄存器、中断号、错误码和状态寄存器等信息

```c
uintptr_t tf_esp;
uint16_t tf_ss;
uint16_t tf_padding5;
```

**特权级的转换**

```c
struct trapframe {
    struct pushregs tf_regs;
    uint16_t tf_gs;
    uint16_t tf_padding0;
    uint16_t tf_fs;
    uint16_t tf_padding1;
    uint16_t tf_es;
    uint16_t tf_padding2;
    uint16_t tf_ds;
    uint16_t tf_padding3;
    uint32_t tf_trapno;
    /* below here defined by x86 hardware */
    uint32_t tf_err;
    uintptr_t tf_eip;
    uint16_t tf_cs;
    uint16_t tf_padding4;
    uint32_t tf_eflags;
    /* below here only when crossing rings, such as from user to kernel */
    uintptr_t tf_esp;
    uint16_t tf_ss;
    uint16_t tf_padding5;
} __attribute__((packed));
```

#### `effect`:

都是用来切换进线程。tf 能做到内核态的切换（但是lab4不涉及用户态呐）

## 练习2：为新创建的内核线程分配资源（需要编码）

**创建一个内核线程需要分配和设置好很多资源。kernel_thread函数通过调用do_fork函数完成**
**具体内核线程的创建工作。do_kernel函数会调用alloc_proc函数来分配并初始化一个进程控**
**制块,但alloc_proc只是找到了一小块内存用以记录进程的必要信息,并没有实际分配这些资**
**源。**

**ucore一般通过do_fork实际创建新的内核线程。do_fork的作用是,创建当前内核线程的**
**一个副本,它们的执行上下文、代码、数据都一样,但是存储位置不同。在这个过程中,需**
**要给新内核线程分配资源,并且复制原进程的状态。你需要完成在kern/process/proc.c中的**
**do_fork函数中的处理过程。它的大致执行步骤包括:**
			**1）调用alloc_proc,首先获得一块用户信息块。2）为进程分配一个内核栈。	3）复制原进程的内存管理信息到新进程,但内核线程不必做此事   4）复制原进程上下文到新进程  5)将新进程添加到进程列表  6)唤醒新进程   7)返回新进程号**

**请在实验报告中简要说明你的设计实现过程。请回答如下问题:**
**请说明ucore是否做到给每个新fork的线程一个唯一的id?请说明你的分析和理由。**



### 2.1 fullfill function    do_fork()

`proc.c`

````c
   MACROs or Functions:
       alloc_proc:   create a proc struct and init fields (lab4:exercise1)
       setup_kstack: alloc pages with size KSTACKPAGE as process kernel stack
       copy_mm:      process "proc" duplicate OR share process "current"'s mm according clone_flags  if clone_flags & CLONE_VM, then "share" ; else "duplicate"
       copy_thread:  setup the trapframe on the  process's kernel stack top and setup the kernel entry point and stack of process
       hash_proc:    add proc into proc hash_list
       get_pid:      alloc a unique pid for process
       wakeup_proc:  set proc->state = PROC_RUNNABLE
     VARIABLES:
       proc_list:    the process set's list
       nr_process:   the number of process set
    //    1. call alloc_proc to allocate a proc_struct
    //    2. call setup_kstack to allocate a kernel stack for child process
    //    3. call copy_mm to dup OR share mm according clone_flag
    //    4. call copy_thread to setup tf & context in proc_struct
    //    5. insert proc_struct into hash_list && proc_list
    //    6. call wakeup_proc to make the new child process RUNNABLE
    //    7. set ret vaule using child proc's pid
````

```c
	if ((proc = alloc_proc()) == NULL) {//调用 alloc_proc() 函数申请内存块
        goto fork_out;
    }
	proc = alloc_proc(); // 分配tcb的内存块
    if (proc == NULL) goto fork_out; // 判断是否分配到内存空间
	proc->parent = current;//将子进程的父节点设置为当前进程
    assert(setup_kstack(proc) == 0);  // 为新的线程设置栈
    assert(copy_mm(clone_flags, proc) == 0); //复制父进程的内存信息到子进程
//根据clone_flags 判断是否共享地址空间 lab5 
    copy_thread(proc, stack, tf); // 复制父进程的中断帧和上下文信息
    proc->pid = get_pid(); // 为新的线程创建pid
    hash_proc(proc); //建立 hash 映射
	// 将线程放入使用hash组织的链表中，便于加速以后对某个指定的线程的查找
    nr_process ++; // 全局线程的数目+1
    list_add(&proc_list, &proc->list_link); 
	//将线程加入到所有线程的链表中
    wakeup_proc(proc); // 唤醒该线程
    ret = proc->pid; // 返回新线程的pid
```

make qemu:

```
check_swap() succeeded!
++ setup timer interrupts
this initproc, pid = 1, name = "init"
To U: "Hello world!!".
To U: "en.., Bye, Bye. :)"
kernel panic at kern/process/proc.c:341:
    process exit!!.
```

```
cyhor@cyhor-911Air:~/ccccc/dddd/labcodes/lab4$ make grade
Check VMM:               (3.2s)
  -check pmm:                                OK
  -check page table:                         OK
  -check vmm:                                OK
  -check swap page fault:                    OK
  -check ticks:                              OK
  -check initproc:                           OK
Total Score: 90/90
```

### 2.2 **请说明ucore是否做到给每个新fork的线程一个唯一的id?请说明你的分析和理由。**

是的 分析 `proc.c get_pid()`

```c
static int
get_pid(void) {
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
    //两个静态变量last_pid以及next_safe
    //last_pid变量保存上一次分配的PID，而next_safe和last_pid一起表示一段可以使用的PID取值范围(last_pid,next_safe)
    static int next_safe = MAX_PID, last_pid = MAX_PID;

    if (++ last_pid >= MAX_PID) {//如果lastpid+1超出最大值，置为1
        last_pid = 1;      //要求PID的取值范围为[1,MAX_PID]
        goto inside;  //更新nextsafe
    }
	
    
    //如果last_pid < next_safe，则last_pid是有效的
    if (last_pid >= next_safe) {//无效时：
    inside:
        next_safe = MAX_PID;//初始化next_safe为最大值，后续需要计算最小值
    repeat:
        le = list;
        //PID 的确定过程中会检查所有进程的 PID，来确保 PID 是唯一的
        while ((le = list_next(le)) != list) {
            proc = le2proc(le, list_link);
            if (proc->pid == last_pid) {//确保了不存在任何进程的pid与last_pid重合
                if (++ last_pid >= next_safe) {
                    if (last_pid >= MAX_PID) {
                        last_pid = 1;
                    }
                    next_safe = MAX_PID;
                    goto repeat;
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {
                next_safe = proc->pid;
            //pid满足：last_pid<pid<next_safe，这样就确保了最后能够找到这么一个满足条件的区间，获得合法的pid；
            }
        }
    }
    return last_pid;
}
```

## 练习3：阅读代码，理解`proc_run`函数和它调用的函数如何完成进程切换的。（无编码工作）

**请在实验报告中简要说明你对`proc_run`函数的分析。并回答如下问题：**

* **在本实验的执行过程中，创建且运行了几个内核线程？**
* **语句`local_intr_save(intr_flag);....local_intr_restore(intr_flag);`在这里有何作用?请说明理由**

### 3.1 `proc_run`

```c
void
proc_run(struct proc_struct *proc) {
    // 要运行的线程没有运行
    if (proc != current) {
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
        //关闭中断，避免在进程切换过程中出现中断
        local_intr_save(intr_flag);
        {
            //将当前进程换为要切换到的进程
            current = proc;
            //设置任务状态段tss中的特权级0下的esp0指针为next内核线程的内核栈的栈顶
            load_esp0(next->kstack + KSTACKSIZE);
            //重新加载cr3寄存器(页目录表基址) 进行进程间的页表切换
            //修改当前的cr3寄存器成需要运行线程（进程）的页目录表
            lcr3(next->cr3);
        }
            //调用switch_to进行上下文的保存与切换，切换到新的线程
            switch_to(&(prev->context), &(next->context));
        }
        //恢复中断
        local_intr_restore(intr_flag);
    }
}
```

### 3.2 问题在本实验的执行过程中，创建且运行了几个内核线程？：2

* 第 0 个内核线程 idleproc：在完成新的内核线程的创建以及各种初始化工作之后，用于调度其他进程或线程。
* 第 1 个内核线程 initproc：只用来打印字符串。

### 3.3 语句`local_intr_save(intr_flag);....local_intr_restore(intr_flag);`在这里有何作用?请说明理由

在进行进程切换的时候，需要避免出现中断干扰这个过程，所以需要在上下文切换期间清除`intr_flag`位屏蔽中断，并且在进程恢复执行后恢复`intr_flag`位。实现操作的原子性，有效保证程序正确运行。

