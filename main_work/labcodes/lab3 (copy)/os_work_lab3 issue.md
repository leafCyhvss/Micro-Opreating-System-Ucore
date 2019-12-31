# Lab3:虚拟内存管理

**实验目的**

- 了解虚拟内存的Page Fault异常处理实现
- 了解页替换算法在操作系统中的实现

**实验内容**
本次实验是在实验二的基础上,借助于页表机制和实验一中涉及的中断异常处理机制,完成
Page Fault异常处理和FIFO页替换算法的实现,结合磁盘提供的缓存空间,从而能够支持虚
存管理,提供一个比实际物理内存空间“更大”的虚拟内存空间给系统使用。这个实验与实际操
作系统中的实现比较起来要简单,不过需要了解实验一和实验二的具体实现。实际操作系统
系统中的虚拟内存管理设计与实现是相当复杂的,涉及到与进程管理系统、文件系统等的交
叉访问。如果大家有余力,可以尝试完成扩展练习,实现extended clock页替换算法。

## 练习0:填写已有实验

本实验依赖实验1/2。请把你做的实验1/2的代码填入本实验中代码中有“LAB1”,“LAB2”的注释
相应部分。

```makefile
kdebug.c
trap.c
pmm.c 
default_pmm.c
```

执行make qemu

```
page fault at 0x00000100: K/W [no page found].
page fault at 0x00000100: K/W [no page found].
page fault at 0x00000100: K/W [no page found].
page fault at 0x00000100: K/W [no page found].
page fault at 0x00000100: K/W [no page found].
page fault at 0x00000100: K/W [no page found].
page fault at 0x00000100: K/W [no page found].
page fault at 0x00000100: K/W [no page found].
```

## 练习1：给未被映射的地址映射上物理页（需要编程）

**完成do_pgfault(mm/vmm.c)函数,给未被映射的地址映射上物理页。设置访问权限 的时候**
**要参考页面所在 VMA 的权限,同时需要注意映射物理页时需要操作内存控制 结构所指定**
**的页表,而不是内核的页表。“check_pgfault() succeeded!”的输出,表示练习1基本正确**
**请在实验报告中简要说明你的设计实现过程。请回答如下问题:**

- **请描述页目录项(Pag Director Entry)和页表(Page Table Entry)中组成部分对ucore**
  **实现页替换算法的潜在用处。**
- **如果ucore的缺页服务例程在执行过程中访问内存,出现了页访问异常,请问硬件要做哪**
  **些事情?**

### 1.1关键数据结构 `mm_struct `& `vma_struct`

<img src="/home/cyhor/.config/Typora/typora-user-images/image-20191217170859153.png" alt="image-20191217170859153" style="zoom:25%;" />

`kern\mm\vmm.h`

`mm_struct`:  整个进程的虚拟地址空间

`mm_struct`中: 每个`vma_struct`表示一段地址连续虚拟空间

mm : 进程合法内存空间 vma : 合法内存空间的系列内存块   

####  `vma_struct`

描述应用所使用的虚拟内存空间

```c
struct vma_struct {
    struct mm_struct *vm_mm; // the set of vma using the same PDT 
    uintptr_t vm_start;      // start addr of vma      
    uintptr_t vm_end;        // end addr of vma, not include the vm_end itself
    uint32_t vm_flags;       // flags of vma
    list_entry_t list_link;  // linear list link which sorted by start addr of vma
};
#define VM_READ 0x00000001  //只读
#define VM_WRITE 0x00000002 //可读写
#define VM_EXEC 0x00000004  //可执行
```

* `vm_start`,`vm_end`描述一个连续地址的虚拟内存空间的起始/结束位置，`vm_start < vm_end`合法，左闭右开
* `list_link`：双向链表，按从小到大的顺序链接一群`vma_struct`表示的虚拟内存空间
* `vm_flags`：该虚拟内存空间的属性，分只读，可读写，可执行
* `vm_mm`是指向`mm_struct`的指针

在函数`check_pgfault`中涉及的`vma`

```
vma_create
insert_vma_struct
find_vma
```

####  `mm_struct`

```c
struct mm_struct {
    list_entry_t mmap_list;        // linear list link which sorted by start addr of vma
    struct vma_struct *mmap_cache; // current accessed vma, used for speed purpose
    pde_t *pgdir;                  // the PDT of these vma
    int map_count;                 // the count of these vma
    void *sm_priv;                 // the private data for swap manager
};
```

* `mmap_list`：双向链表`list_link`表头的链表，链接了所有属于同一页目录表的虚拟内存空间

* `mmap_cache`是指向当前正在使用的虚拟内存空间

  ​		由于操作系统的局部性，正在使用的虚拟内存空间，在接下来的操作中可能还会用。直接使用此指针就可找到要用到的虚拟内存空间

* `pgdir`所指向的就是`mm_struct`数据结构所维护的页表，通过访问`pgdir`可以查找某虚拟地址对应的页表项是否存在以及页表项的属性等

* `map_count`记录`mmap_list`里面链接的`vma_struct`的个数

* `sm_priv`指向用来链接记录页访问情况的链表头，涉及`mm_struct`和`swap_manager`

### 1.2 补全`do_pgfault`函数

调用关系：被`kern/trap/trap.c`中`pgfault_handler`调用

```c
static int
pgfault_handler(struct trapframe *tf) {
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
        return do_pgfault(check_mm_struct, tf->tf_err, rcr2());
    }
    panic("unhandled page fault.\n");
}
```

`check_mm_struct, tf->tf_err, rcr2()`三个传入的参数

已有的部分：

从CR2寄存器中获取页访问异常的物理地址，根据errorCode的错误类型来查找此地址是否在某个VMA的地址范围内(line72-97 vmm.c)，是否满足正确的读写权限。如果在此范围内并且权限也正确，这认为这是一次合法访问，但没有建立虚实对应关系。

```c
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
    int ret = -E_INVAL;
    //try to find a vma which include addr  查询vma
    struct vma_struct *vma = find_vma(mm, addr);
    pgfault_num++;
    
    //If the addr is in the range of a mm's vma? 不在范围内
    if (vma == NULL || vma->vm_start > addr) {
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
        goto failed;
    }
    //check the error_code
    switch (error_code & 3) {
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
            goto failed;
        }
        break;
    case 1: /* error code flag : (W/R=0, P=1): read, present */
        cprintf("do_pgfault failed: error code flag = read AND present\n");
        goto failed;
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
            goto failed;
        }
    }
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
        perm |= PTE_W;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
    ret = -E_NO_MEM;
    pte_t *ptep=NULL;
```

补全：

分配一个空闲的内存页，并修改页表完成虚地址到物理地址的映射，刷新TLB，调用iret中断，返回到产生页访问异常的指令处重新执行此指令。

```
swap_in(mm, addr, &page) : 
	alloc a memory page, then according to the swap entry in PTE for addr, find the addr of 	disk page, read the content of disk page into this memroy page 将硬盘中的内容换入至page中
page_insert ：        build the map of phy addr of an Page with the linear addr la
swap_map_swappable ： set the page swappable
get_pte :
	get an pte and return the kernel virtual address of this pte for la,if the PT contians this pte didn't exist, alloc a page for PT (notice the 3th parameter '1')
```

```c
    //try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
	//检查页表中是否有相应的应用程序需要的表项，有就获取指向这个表项的指针
	if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
	//然后检查这个表项是否为空(是否被映射)，如果为空，pgdir_alloc_page分配一个新的物理页
    if (*ptep == 0) {  
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
            goto failed;
        }
    }
 //如果这个页表项非空，那么说明这一页已经映射过了但是被保存在磁盘中，需要将这一页内存交换出来
// if this pte is a swap entry, then load data from disk to a page with phy addr and call page_insert to map the phy addr with logical addr
    else {   
        if(swap_init_ok) {
            //如果可以交换
            struct Page *page=NULL; 
            //根据mm结构和addr地址，尝试将硬盘中的内容换入至page中
            //load the content of right disk page into the memory which page managed.
            if ((ret = swap_in(mm, addr, &page)) != 0) {
                cprintf("swap_in in do_pgfault failed\n");
                goto failed;
            }    
            page_insert(mm->pgdir, page, addr, perm); 
            //建立虚拟地址和物理地址之间的对应关系 According to the mm, addr AND page, setup the map of phy addr <---> logical addr
            swap_map_swappable(mm, addr, page, 1); 
            //将此页面设置为可交换的 make the page swappable.  
            page->pra_vaddr = addr;
        }
        else {
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
            goto failed;
        }
   }
   ret = 0;
failed:
    return ret;
}
```

执行 make qemu

```
check_vma_struct() succeeded!
page fault at 0x00000100: K/W [no page found].
check_pgfault() succeeded!              ------------------成功
check_vmm() succeeded.
ide 0:      10000(sectors), 'QEMU HARDDISK'.
ide 1:     262144(sectors), 'QEMU HARDDISK'.
SWAP: manager = fifo swap manager
```

### 1.3 请描述页目录项（Pag Director Entry）和页表（Page Table Entry）中组成部分对ucore实现页替换算法的潜在用处。

#### flags

```
/* page table/directory entry flags */
#define PTE_P           0x001       // Present 对应物理页面是否存在
#define PTE_W           0x002       // Writeable 是否可写
#define PTE_U           0x004       // User   用户态是否可以访问
#define PTE_PWT         0x008       // Write-Through 写入时是否写透，直写回内存
#define PTE_PCD         0x010       // Cache-Disable 是否能被放入cache
#define PTE_A           0x020       // Accessed   物理页面是否被访问
#define PTE_D           0x040       // Dirty    页面是否被写入
#define PTE_PS          0x080       // Page Size   页面大小
#define PTE_MBZ         0x180       // Bits must be zero  必须为零的部分
#define PTE_AVAIL       0xE00       // Available for software use 可自定义
	
#define PTE_USER        (PTE_U | PTE_W | PTE_P)
```

PDE高20位是页表地址，剩下的12位都为标志位

从0位到11位：`PTE_P,PTE_W,PTE_U,PTE_PWT,PTE_PCD,PTE_A,PTE_MBZ=0,PTE_PS,PTE_AVAIL`

![img](https://img-blog.csdnimg.cn/20191018190508763.png)

PTE高20位是物理页地址

0-11：`PTE_P,PTE_W,PTE_U,PTE_PWT,PTE_PCD,PTE_A,PTE_D,PTE_MBZ=0,Global,PTE_AVAIL`。

![PTE属性](https://img-blog.csdnimg.cn/20191018190528760.png)

#### usage

- LFU：`AVAIL`3位能表示0-7，可以用来储存页表的访问次数
- Clock：需要`PTE_A`(是否访问)，跳过了访问位为1的页
- Enhanced Clock ：需要`PTE_A`和`PTE_D`，优先淘汰未被引用也未被修改的页。

### 1.4  如果ucore的缺页服务例程在执行过程中访问内存，出现了页访问异常，请问硬件要做哪些事情？

CPU把引起页访问异常的线性地址装到寄存器CR2中，并给出了出错码errorCode，说明了页访问异常的类型。

## 练习2：补充完成基于FIFO的页面替换算法（需要编程）

**完成`vmm.c`中的`do_pgfault`函数，并且在实现FIFO算法的`swap_fifo.c`中完成`map_swappable`和`swap_out_vistim`函数。通过对`swap`的测试。如果通过check_swap函数的测试后,会有“check_swap() succeeded!”的输出,**

请在实验报告中回答如下问题:
如果要在ucore上实现"extended clock页替换算法"请给你的设计方案,现有的`swap_manager`框架是否足以支持在ucore中实现此算法?如果是,请给你的设计方案。如果不是,请给出你的新的扩展和基此扩展的设计方案。并需要回答如下问题

- 需要被换出的页的特征是什么?
- 在ucore中如何判断具有这样特征的页?
- 何时进行换入和换出操作?

### 2.1 页面换入

已在上述`do_pgfault`中实现。

### 2.2 页面换出

主要由`_fifo_swap_out_victim`实现：

#### `swap_manager`

```c
struct swap_manager
{
     const char *name;
     /* Global initialization for the swap manager */
     int (*init)            (void);
     /* Initialize the priv data inside mm_struct */
     int (*init_mm)         (struct mm_struct *mm);
     /* Called when tick interrupt occured */
     int (*tick_event)      (struct mm_struct *mm);
     /* Called when map a swappable page into the mm_struct */
     int (*map_swappable)   (struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in);
     /* When a page is marked as shared, this routine is called to
      * delete the addr entry from the swap manager *///共享不换出
     int (*set_unswappable) (struct mm_struct *mm, uintptr_t addr);
     /* Try to swap out a page, return then victim */
     int (*swap_out_victim) (struct mm_struct *mm, struct Page **ptr_page, int in_tick);
     /* check the page relpacement algorithm */
     int (*check_swap)(void);     
};
```

* `map_swappable`函数用于记录页访问情况相关属性
* `swap_out_vistim`函数用于挑选需要换出的页

#### `_fifo_map_swappable`函数

```c
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
    list_entry_t *entry=&(page->pra_page_link);
 
    assert(entry != NULL && head != NULL);
    //record the page access situlation
    /*LAB3 EXERCISE 2: YOUR CODE*/ 
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
    //将最近用的页插入到可换出物理页链表的末尾(双链表)
    list_add(head, entry);
    return 0;
}
```

#### `_fifo_swap_out_victim`函数

```c
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
         assert(head != NULL);
     assert(in_tick==0);
     /* Select the victim */
     /*LAB3 EXERCISE 2: YOUR CODE*/ 
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  set the addr of addr of this page to ptr_page
    
     //需要被换出的页:
     list_entry_t *le = head->prev;
     assert(head!=le);
     //获得对应page的指针p
     struct Page *p = le2page(le, pra_page_link);
     //将最早的页面从队列中删除
     list_del(le);
     assert(p !=NULL);
     //将这一页的地址存储在ptr_page中
     *ptr_page = p;
     return 0;
}
```

#### 执行qemu

```
swap_out: i 0, store page in vaddr 0x1000 to disk swap entry 2
swap_in: load disk swap entry 6 with swap_page in vadr 0x5000
write Virt Page a in fifo_check_swap
page fault at 0x00001000: K/R [no page found].
swap_out: i 0, store page in vaddr 0x2000 to disk swap entry 3
swap_in: load disk swap entry 2 with swap_page in vadr 0x1000
count is 7, total is 7
check_swap() succeeded!------------------------成功
++ setup timer interrupts
100 ticks
100 ticks
100 ticks
```

### 可以支持`extended clock`页替换算法

页表项的`PTE_A`表示访问与否，`PTE_D`为1表示修改与否

所以一共四种情况(A,D)

- (0,0)表示最近未被引用也未被修改,首先替换；
- (0,1)最近未被使用但被修改,其次选择
- (1,0)最近使用而未修改，很少替换
- (1,1)最近使用且修改,基本不换

设计方案：

重载`_fifo_swap_out_victim`

判断每个物理页对应的虚拟页的(A,D)，根据以上四种情况计数。

有多个虚拟页对应一个物理页时，相加，和最小的优先替换。

## Challenge 1:   实现识别dirty bit的 extended clock页替换算法(需要编程)

### basic knowledge

```
1. 时钟页替换算法把各个页面组织成环形链表。然后把当前指针指向最先进来的页面。
2. 算法在页表项（PTE）中的访问位 A 和  写(xiu)入(gai)位D(dirty bit)。
3. 当该页被访问时，MMU:PTE_A->“1”。被修改：PTE_D->1;
4. 具体替换流程：
```

| A,D  | 置换与否 |
| :--: | :------: |
| 0,0  |   置换   |
| 0,1  |   0,0    |
| 1,0  |   0,0    |
| 1,1  |   0,1    |

修改`swap_manager`对应代码：

### 1 `_fifo_map_swappable()`

```c
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
    list_entry_t *entry=&(page->pra_page_link);

    assert(entry != NULL && head != NULL);
    list_add(head -> prev, entry);//换入页的在链表中的位置并不影响
    
    // 新插入的页A,D标记为0.
    struct Page *ptr = le2page(entry, pra_page_link);
    pte_t *pte = get_pte(mm -> pgdir, ptr -> pra_vaddr, 0);
    *pte&=~PTE_D;
    *pte&=~PTE_A;
    return 0;
}
```

### 2 `_fifo_swap_out_victim()`

```c
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
    //Challenge2  code:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
    assert(head != NULL);
    assert(in_tick==0);
	//select victim----
    list_entry_t *le = head;
    while (1) {
        le = list_next(le);
        if (le == head) {
            le = list_next(le);
        }
        struct Page *ptr = le2page(le, pra_page_link);
        pte_t *pte = get_pte(mm -> pgdir, ptr -> pra_vaddr, 0);
         //获取页表项
        if((*pte & PTE_A)==0){
            if ((*pte & PTE_D) == 0) {//直接换出
             	list_del(le);
                *ptr_page = ptr;
                break;//终止循环节省开销
            }
            else {
            *pte &= ~PTE_D;//Ucore貌似不用加入写回的事情
            }//A为0 D为1，D改为0
        }
        else {*pte &= ~PTE_A;}//A为1，D为0或1都只是需要修改A为0
		//le = list_next(le);//如果在当前页没有跳出循环，那么取下一页
    }
    return 0;
}
```

直接用上述代码替换原本位置代码。（原来的函数函数名后添加了个2）

提交的代码中，还是用`fifo`的函数。即`exclock`的函数名有2

### 执行make qemu 

```
kernel panic at kern/mm/swap_fifo.c:203:
    assertion failed: pgfault_num==6
```

缺页次数没有那么多：

问了一下其他写过该拓展的同学，貌似check_swap的断言得去掉……

执行make qemu:

```
count is 7, total is 7
check_swap() succeeded!
++ setup timer interrupts
100 ticks
100 ticks
```

