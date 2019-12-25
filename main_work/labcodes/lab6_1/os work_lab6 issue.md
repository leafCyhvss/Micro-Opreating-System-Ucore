# 实验六: 调度器

**实验目的**

- **理解操作系统的调度管理机制**
- **熟悉 ucore 的系统调度器框架,以及缺省的Round-Robin 调度算法**
- **基于调度器框架实现一个(Stride Scheduling)调度算法来替换缺省的调度算法**

**实验内容**

**实验五完成了用户进程的管理,可在用户态运行多个进程。但到目前为止,采用的调度策略**
**是很简单的FIFO调度策略。本次实验,主要是熟悉ucore的系统调度器框架,以及基于此框架**
**的Round-Robin(RR) 调度算法。然后参考RR调度算法的实现,完成Stride Scheduling调度**
**算法。**

## 练习0:填写已有实验

**本实验依赖实验1/2/3/4/5。请把你做的实验2/3/4/5的代码填入本实验中代码中**
**有“LAB1”/“LAB2”/“LAB3”/“LAB4”“LAB5”的注释相应部分。并确保编译通过。注意:为了能够**
**正确执行lab6的测试应用程序,可能需对已完成的实验1/2/3/4/5的代码进行进一步改进。**

### `meld`

```
lab1:trap.c  kdebug.c
lab2:pmm.c default_pmm.c 
lab3:swap_fifo.c vmm.c 
lab4:proc.c
lab5:proc.c pmm.c trap.c
```

这次尝试用命令行diff patch lab5_2是完成的lab5 ; lab5_1是原题目   

```
cyhor@cyhor-911Air:~/ccccc/dddd/labcodes$ diff -r -u -P lab5_2 lab5_1 > lab5.patch
cyhor@cyhor-911Air:~/ccccc/dddd/labcodes$ cd lab6_1/
cyhor@cyhor-911Air:~/ccccc/dddd/labcodes/lab6_1$ patch -p1 -u < ../lab5.patch
patching file kern/debug/kdebug.c
patching file kern/mm/default_pmm.c
patching file kern/mm/pmm.c
patching file kern/mm/swap_fifo.c
patching file kern/mm/vmm.c
patching file kern/process/proc.c
Hunk #1 FAILED at 109.
Hunk #2 FAILED at 396.
Hunk #3 FAILED at 407.
Hunk #4 FAILED at 416.
Hunk #5 FAILED at 642.
Hunk #6 FAILED at 660.
Hunk #7 FAILED at 847.
7 out of 7 hunks FAILED -- saving rejects to file kern/process/proc.c.rej
patching file kern/trap/trap.c
Hunk #1 succeeded at 57 (offset 1 line).
Hunk #2 FAILED at 223.
1 out of 2 hunks FAILED -- saving rejects to file kern/trap/trap.c.rej
```

看起来需要手动修改：                                        

小吐槽（越改越多）回去手动meld

### `Update`

#### `alloc_proc`

```c
//LAB6 YOUR CODE : (update LAB5 steps)
    // below fields(add in LAB6) in proc_struct need to be initialized
          struct run_queue *rq;   // running queue contains Process
          list_entry_t run_link; // the entry linked in run queue 进程的调度链表
          int time_slice;       // time slice for occupying the CPU,只针对当前进程
          skew_heap_entry_t lab6_run_pool;      
     // FOR LAB6 ONLY: the entry in the run pool  进程在优先队列中的节点
          uint32_t lab6_stride;                 
     // FOR LAB6 ONLY: the current stride of the process  该进程的调度步长值
          uint32_t lab6_priority;               
     // FOR LAB6 ONLY: the priority of process, set by lab6_set_priority(uint32_t) 该进程的调度优先级
```

属于新的`proc_struct`

因而初始化：

```c
        proc->rq = NULL; //初始化运行队列为空
        list_init(&(proc->run_link)); 
        proc->time_slice = 0; //初始化时间片
        //初始化指针为空
        proc->lab6_run_pool.left = proc->lab6_run_pool.right = proc->lab6_run_pool.parent = NULL;
        proc->lab6_stride = 0;    //设置步长为0
        proc->lab6_priority = 0;  //设置优先级为0
```

#### `trap.c`

```c
/* LAB6 YOUR CODE */
        /* you should upate you lab5 code
         * IMPORTANT FUNCTIONS:
	     * sched_class_proc_tick
         */
    	ticks ++;  
        assert(current != NULL);
        sched_class_proc_tick(current);//在下文介绍
```

### `make grade`:

确实只有 `priority` 出错

```
forktree:                (1.3s)
  -check result:                             OK
  -check output:                             OK
matrix:                  (7.8s)
  -check result:                             OK
  -check output:                             OK
priority:                (11.2s)
  -check result:                             WRONG
   -e !! error: missing 'sched class: stride_scheduler'
   !! error: missing 'stride sched correct result: 1 2 3 4 5'

  -check output:                             OK
Total Score: 163/170
Makefile:314: recipe for target 'grade' failed
make: *** [grade] Error 1
```

## 练习1: 使用 Round Robin 调度算法(不需要编码)

**完成练习0后,建议大家比较一下(可用kdiff3等文件比较软件)个人完成的lab5和练习0完成**
**后的刚修改的lab6之间的区别,分析了解lab6采用RR调度算法后的执行过程。执行make**
**grade,大部分测试用例应该通过。但执行priority.c应该过不去。**
**请在实验报告中完成:**

- **请理解并分析sched_calss中各个函数指针的用法,并接合Round Robin 调度算法描**
  **ucore的调度执行过程**
- **请在实验报告中简要说明如何设计实现”多级反馈队列调度算法“,给出概要设计,鼓励给**
  **出详细设计**



有趣的小东西：

```
操作系统中睡眠、阻塞、挂起的区别形象解释：

首先这些术语都是对于线程来说的。对线程的控制就好比你控制了一个雇工为你干活。你对雇工的控制是通过编程来实现的。
     挂起线程的意思就是你对主动对雇工说：“你睡觉去吧，用着你的时候我主动去叫你，然后接着干活”。
     使线程睡眠的意思就是你主动对雇工说：“你睡觉去吧，某时某刻过来报到，然后接着干活”。
     线程阻塞的意思就是，你突然发现，你的雇工不知道在什么时候没经过你允许，自己睡觉呢，但是你不能怪雇工，肯定你  这个雇主没注意，本来你让雇工扫地，结果扫帚被偷了或被邻居家借去了，你又没让雇工继续干别的活，他就只好睡觉了。至于扫帚回来后，雇工会不会知道，会不会继续干活，你不用担心，雇工一旦发现扫帚回来了，他就会自己去干活的。因为雇工受过良好的培训。这个培训机构就是操作系统。
```

### 1.1 调度算法支撑框架

通过将不同的算法绑定 `sched_class`结构实现调度框架（此类提供接口，不同算法带进去）

```c
struct sched_class {
    // the name of sched_class
    const char *name;
    // Init the run queue
    void (*init)(struct run_queue *rq);
    // put the proc into runqueue, and this function must be called with rq_lock
    void (*enqueue)(struct run_queue *rq, struct proc_struct *proc);
    // get the proc out runqueue, and this function must be called with rq_lock
    void (*dequeue)(struct run_queue *rq, struct proc_struct *proc);
    // choose the next runnable task
    struct proc_struct *(*pick_next)(struct run_queue *rq);
    // dealer of the time-tick
    void (*proc_tick)(struct run_queue *rq, struct proc_struct *proc);
```

声明并选取默认调度类，`ucore`实现切换调度算法就是通过更换`default_sched.c`完成的

`default_shed.h`: 

```c
extern struct sched_class default_sched_class;
```

`shed.c`:

```c
void
sched_init(void) {
    list_init(&timer_list);

    sched_class = &default_sched_class;//指向默认调度类

    rq = &__rq;
    rq->max_time_slice = MAX_TIME_SLICE;
    sched_class->init(rq);

    cprintf("sched class: %s\n", sched_class->name);
}
```

例如：`default_sched.c`：RR算法：

```c
struct sched_class default_sched_class = {
    .name = "RR_scheduler",
    .init = RR_init,
    .enqueue = RR_enqueue,//进入就绪队列
    .dequeue = RR_dequeue,//离开就绪队列
    .pick_next = RR_pick_next,//选取下个执行进程：调度算法的核心
    .proc_tick = RR_proc_tick,//响应时钟中断，让调度算法调整参数如时间片大小
};
//切换 switch_to
```

`shed`的核心函数，通过下列函数被调用：  （`wakeup_proc`其实也有）

`schedule()`  

```c
void
schedule(void) {
    bool intr_flag;
    struct proc_struct *next;
    local_intr_save(intr_flag);//关中断
    {
        current->need_resched = 0;
        if (current->state == PROC_RUNNABLE) {
            sched_class_enqueue(current);//就绪态进入就绪队列
        }
        if ((next = sched_class_pick_next()) != NULL) {//选择新进程
            sched_class_dequeue(next);//选出，从就绪队列出队
        }
        if (next == NULL) {//如果选不出来，调用idleproc循环寻找就绪进程
            next = idleproc;
        }
        next->runs ++;
        if (next != current) {//如果选出来，交换
            proc_run(next);//这个函数调switch_to完成切换
        }
    }
    local_intr_restore(intr_flag);
}
```

### 1.2 `Round Robin` 调度算法   时间片轮转的过程  各个函数指针的用法

#### 1.2.1 `RR_init`初始化

```c
static void
RR_init(struct run_queue *rq) {
    list_init(&(rq->run_list)); //清空就绪队列
    rq->proc_num = 0;           //初始化进程数为0
}


前提数据结构：
struct run_queue {  
    list_entry_t run_list;  //就绪队列
    unsigned int proc_num; //就绪态进程个数
    int max_time_slice;  //每个进程一轮占用的最多时间片
    // For LAB6 ONLY
    skew_heap_entry_t *lab6_run_pool;  //进程容器  斜堆实现
};

struct skew_heap_entry {
     //树形结构的进程容器
     struct skew_heap_entry *parent, *left, *right;
};
typedef struct skew_heap_entry skew_heap_entry_t;
```

#### 1.2.2 `RR_proc_tick`

产生时钟中断时被调用。涉及时间片变化。

```c
static void
RR_proc_tick(struct run_queue *rq, struct proc_struct *proc) {
    if (proc->time_slice > 0) { //时间片-1
        proc->time_slice --;
    }
    if (proc->time_slice == 0) {//如果时间片没了就接受调度，不可占用cpu
        proc->need_resched = 1;
    }
}
```

#### 1.2.3  `RR_enqueue`->`RR_pick_next` ->`RR_dequeue`

**入队与出队只是抽象概念，可以其他数据结构实现**

```c
static void
RR_enqueue(struct run_queue *rq, struct proc_struct *proc) {
    assert(list_empty(&(proc->run_link)));
    //就绪队列是双向链表，进队列时插入队列头
    list_add_before(&(rq->run_list), &(proc->run_link));
    if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
        proc->time_slice = rq->max_time_slice;//如果之前没有时间片值，初始化时间片
    }
    proc->rq = rq;
    rq->proc_num ++;  //就绪进程数+1
}

static struct proc_struct *
RR_pick_next(struct run_queue *rq) {//从队列的尾挑出一个进程去占用cpu
    list_entry_t *le = list_next(&(rq->run_list));
    if (le != &(rq->run_list)) {
        return le2proc(le, run_link);//返回进程控制块指针
    }
    return NULL;//如果选的的le成了空，那么说明没有就绪进程，这个时候用该调用idleproc
    //这个NULL是配和schedule()
}
//pick只是选择，没有取出来
static void
RR_dequeue(struct run_queue *rq, struct proc_struct *proc) {
    assert(!list_empty(&(proc->run_link)) && proc->rq == rq);
    list_del_init(&(proc->run_link));//删除就绪队列的元素
    rq->proc_num --;
}
```

#### 1.2.4 `proc_run` 切换进程（这个函数调用swith_to)

```c
void
proc_run(struct proc_struct *proc) {
    if (proc != current) {
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
        local_intr_save(intr_flag);
        {
            // load  base addr of "proc"'s new PDT
            current = proc;
            load_esp0(next->kstack + KSTACKSIZE);//加载内核堆栈
            lcr3(next->cr3);//切换页目录基址
            switch_to(&(prev->context), &(next->context));
        }
        local_intr_restore(intr_flag);
    }
}
```

### 1.3 设计实现”多级反馈队列调度算法“

1. `proc_struct`添加优先级属性(`int`)。
2. 修改就就绪进程的双向链表结构为两级双向链表。其中第一级每一节点表示一个优先级初始化时，时间片长插入优先级低链表，短插入高链表。
3. 同优先级之间RR。同一优先级内，如果时间片用完还没结束，该进程移至下一优先级的链表。
4. 优先执行高优先级进程。
5. 每间隔一定时间，挑选某高优先级链表降一级，某低优先级升一级。（防止饥饿）

## 练习2: 实现 Stride Scheduling 调度算法(需要编码)

**首先需要换掉RR调度器的实现,即用default_sched_stride_c覆盖default_sched.c。然后根据**
**此文件和后续文档对Stride度器的相关描述,完成Stride调度算法的实现。**
**后面的实验文档部分给出了Stride调度算法的大体描述。**

**执行:make grade。如果所显示的应用程序检测都输出ok,则基本正确。如果只是priority.c**
**过不去,可执行 make run-priority 命令来单独调试它。大致执行结果可看附录。( 使用的是**
**qemu-1.0.1 )。**

### 1.3.1`stride` 算法学习笔记

步长 stride  (已经走完的)    pass步进：一步走多远   

步长小的调度时先执行。步进越小，被调度越多

优先级和步进成反比  调度选择是确定的，不是随机选择

#### `Approach`：

1. 为每个runnable的进程设置一个当前状态stride，表示该进程当前的调度权。另外定义其对应的pass值，表示对应进程在调度后，stride 需要进行的累加值。
2. 每次需要调度时，从当前 runnable 态的进程中选择 stride最小的进程调度。
3. 对于获得调度的进程P，将对应的stride加上其对应的步长pass（只与进程的优先权有关系）。
4. 在一段固定的时间之后，回到 2.步骤，重新调度当前stride最小的进程。
   可以证明，如果令 P.pass =BigStride / P.priority 其中 P.priority 表示进程的优先权（大于 1），而 BigStride 表示一个预先定义的大常数，则该调度方案为每个进程分配的时间将与其优先级成正比。

#### `skew_heap`斜堆实现优先队列：

```c
//proc_struct
	skew_heap_entry_t lab6_run_pool;      
     // the entry in the run pool  进程在优先队列中的节点
          uint32_t lab6_stride;                 
     // F the current stride of the process  该进程的调度步长值
          uint32_t lab6_priority;  //优先级与步进值pass成反比 pass越小调度越多

struct run_queue {
    list_entry_t run_list;
    unsigned int proc_num;
    int max_time_slice;
    // For LAB6 ONLY
    skew_heap_entry_t *lab6_run_pool;
}；
```

`skew_heap.h` 斜堆维护的优先队列:

```c
1   // 优先队列节点的结构
2   typedef struct skew_heap_entry  skew_heap_entry_t;
3   // 初始化一个队列节点
4   void skew_heap_init(skew_heap_entry_t *a);
5   // 将节点 b 插入至以节点 a 为队列头的队列中去，返回插入后的队列
6   skew_heap_entry_t  *skew_heap_insert(skew_heap_entry_t  *a,
7                                        skew_heap_entry_t  *b,
8                                        compare_f comp);
9   // 将节点 b 插入从以节点 a 为队列头的队列中去，返回删除后的队列
10      skew_heap_entry_t  *skew_heap_remove(skew_heap_entry_t  *a,
11                                           skew_heap_entry_t  *b,
12                                           compare_f comp);
```



#### `pass` 与`priority`：

`pass = BIG_VALUE / lab6_priority` 并且优先级设置为大于1

  `big_value`最大取值：2<sup>31</sup>-1  （来自实验指导书）  0x7FFFFFFF  

因为`stride`是无符号的32位整数

`STRIDE_MAX – STRIDE_MIN <= PASS_MAX`  &&  `BIG_VALUE=pass * priority`  &&  `priority>1`

推导出：`STRIDE_MAX – STRIDE_MIN <= `BIG_VALUE`

#### `stride` 溢出：

- STRIDE_MAX – STRIDE_MIN <= PASS_MAX

- stride pass是无符号整数，而比较的时候是有符号整数表示  `proc_stride_comp_f()`

  ```c
  int32_t c = p->lab6_stride - q->lab6_stride;
  ```

  防止溢出之后无法判断大小

### 1.3.2 `stride`实现

![Selection_009](/home/cyhor/Desktop/Selection_009.png)

```c
static int proc_stride_comp_f(void *a, void *b)//实现步长比较a>b:1,a==b:0,a<b:-1
```

#### `stride_init`

```c
static void
stride_init(struct run_queue *rq) {
      /* LAB6: YOUR CODE 
        (1) init the ready process list: rq->run_list
      * (2) init the run pool: rq->lab6_run_pool
      * (3) set number of process: rq->proc_num to 0  
      */
     list_init(&(rq->run_list)); //初始化双向链表(用斜堆就不用它但还是要初始化)
     rq->lab6_run_pool = NULL; //初始化当前进程运行的优先队列为空
     rq->proc_num = 0; //设置运行队列为空
    //max_time_slice会被调度的函数初始化（shed.c)
}
```

#### `stride_enqueue`

```c
static void
stride_enqueue(struct run_queue *rq, struct proc_struct *proc) {
     /* LAB6: YOUR CODE 
      * (1) insert the proc into rq correctly
      * NOTICE: you can use skew_heap or list. Important functions
      *         skew_heap_insert: insert a entry into skew_heap
      *         list_add_before: insert  a entry into the last of list   
      * (2) recalculate proc->time_slice
      * (3) set proc->rq pointer to rq
      * (4) increase rq->proc_num
      */
    rq->lab6_run_pool = skew_heap_insert(rq->lab6_run_pool, &(proc->lab6_run_pool), proc_stride_comp_f);
    //斜堆将进程插入就绪队列
    if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
          proc->time_slice = rq->max_time_slice;//重新指定时间片
     }
     proc->rq = rq;//更新就绪队列
     rq->proc_num ++;//就绪队列中进程数+1
}
```

#### `stride_pick_next`

```c
static struct proc_struct *
stride_pick_next(struct run_queue *rq) {
     /* LAB6: YOUR CODE 
      * (1) get a  proc_struct pointer p  with the minimum value of stride
             (1.1) If using skew_heap, we can use le2proc get the p from rq->lab6_run_poll
             (1.2) If using list, we have to search list to find the p with minimum stride value
      * (2) update p;s stride value: p->lab6_stride
      * (3) return p
      */
    if (rq->lab6_run_pool == NULL) return NULL; 
	struct proc_struct *p = le2proc(rq->lab6_run_pool, lab6_run_pool); // 选择stride值最小的进程-----根节点最小
    //这个判断挺重要的
	if (p->lab6_priority == 0){         //   防止异常   优先级为0  
        p->lab6_stride += BIG_STRIDE;}  //就设步长为最大值
    else  p->lab6_stride += BIG_STRIDE / p->lab6_priority;
    return p;
}
```



#### `stride_dequeue`

```c
static void
stride_dequeue(struct run_queue *rq, struct proc_struct *proc) {
     /* LAB6: YOUR CODE 
      * (1) remove the proc from rq correctly
      * NOTICE: you can use skew_heap or list. Important functions
      *         skew_heap_remove: remove a entry from skew_heap
      *         list_del_init: remove a entry from the  list
      */
    rq->lab6_run_pool =skew_heap_remove(rq->lab6_run_pool, &(proc->lab6_run_pool), proc_stride_comp_f);//移除堆
     rq->proc_num --;//就绪队列数目-1
}
```

#### `stride_proc_tick`

```c
static void
stride_proc_tick(struct run_queue *rq, struct proc_struct *proc) {
     /* LAB6: YOUR CODE */
    //与之前一样，不需要修改
    if (proc->time_slice > 0) {
          proc->time_slice --;
     }
     if (proc->time_slice == 0) {
          proc->need_resched = 1;
     }
}
```

### 1.3.2 `make grade`

```
matrix:                  (7.8s)
  -check result:                             OK
  -check output:                             OK
priority:                (11.3s)
  -check result:                             OK
  -check output:                             OK
Total Score: 170/170
```

make qemu:

```
swap_out: i 0, store page in vaddr 0x2000 to disk swap entry 3
swap_in: load disk swap entry 2 with swap_page in vadr 0x1000
count is 5, total is 5
check_swap() succeeded!
++ setup timer interrupts
kernel_execve: pid = 2, name = "priority".
main: fork ok,now need to wait pids.
```





```c
//回顾一下怎么关闭中断保护的
static inline bool
__intr_save(void) {
    if (read_eflags() & FL_IF) {
        intr_disable();
        return 1;
    }
    return 0;
}

static inline void
__intr_restore(bool flag) {
    if (flag) {
        intr_enable();
    }
}

#define local_intr_save(x)      do { x = __intr_save(); } while (0)
#define local_intr_restore(x)   __intr_restore(x);
```









