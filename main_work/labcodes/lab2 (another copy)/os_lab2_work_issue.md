# Lab2:物理内存管理

## 练习0：填写已有实验

**本实验依赖实验1。请把你做的实验1的代码填入本实验中代码中有“LAB1”的注释相应部分。提示：可采用`diff`和`patch`工具进行半自动的合并（merge），也可用一些图形化的比较`/merge`工具来手动合并，比如`meld`，`eclipse`中的`diff/merge`工具，`understand`中的`diff/merge`工具等。**

### 在文件目录下键入meld

```makefile
cyhor@cyhor-911Air:~/ccccc/dddd/labcodes$ meld
```

<img src="/home/cyhor/Pictures/Selection_004.png" alt="Selection_004" style="zoom:50" />

(这里我担心损坏lab1已有的文件所以复制了一份`lab1copy`）

<img src="/home/cyhor/Pictures/Selection_005.png" alt="Selection_005" style="zoom:50%;" />

其实很多文件时有出入的。lab1中改过文件：

```
kern/debug/kdebug.c
kern/trap/trap.c
```

以`kern/debug/kdebug.c`为例：

![Selection_006](/home/cyhor/Pictures/Selection_006.png)

### 全部修改完后执行make qemu:

```
  kern/mm/default_pmm.c:277: default_check+1151
ebp:0xc0116f88 eip:0xc010345f args:arg :0x00000000 0xffff0000 0xc0116fb4 0x0000002a

    kern/mm/pmm.c:458: check_alloc_page+15
ebp:0xc0116fc8 eip:0xc0103203 args:arg :0xc0105dfc 0xc0105de0 0x00000f28 0x00000000

    kern/mm/pmm.c:292: pmm_init+85
ebp:0xc0116ff8 eip:0xc0100090 args:arg :0xc0105ff4 0xc0105ffc 0xc0100d28 0xc010601b

    kern/init/init.c:31: kern_init+89
Welcome to the kernel debug monitor!!
Type 'help' for a list of commands.
K>
```

## 练习1：实现 first-fit 连续物理内存分配算法（需要编程）

**在实现`first fit`内存分配算法的回收函数时，要考虑地址连续的空闲块之间的合并操作。提示:在建立空闲页块链表时，需要按照空闲页块起始地址来排序，形成一个有序的链表。可能会修改`default_pmm.c`中的`default_init`，`default_init_memmap`，`default_alloc_pages`， `default_free_pages`等相关函数。请仔细查看和理解`default_pmm.c`中的注释。请在实验报告中简要说明你的设计实现过程。请回答如下问题：你的`first fit`算法是否有进一步的改进空间**



**`first_fit`分配算法需要维护一个查找有序(地址按从小到大排列)空闲块    (以页为最小单位的连续地址空间)**   

### 1.1 `default_pmm.c`-> Preparation:

`kern/mm/memlayout.h`

```c
struct Page {
    int ref;           // page frame's reference counter   ref是指向到该物理页的虚拟页计数器  
    uint32_t flags;    // array of flags that describe the status of the page frame
    //物理页的状态标记 
    unsigned int property;          // the num of free block, used in first fit pm manager
    list_entry_t page_link;         // free list link
};

/* Flags describing the status of a page frame */
#define PG_reserved                 0       
#define PG_property                 1       
```

`property`记录在此块内的空闲页的个数    `page_link`链接连续内存空闲块

`Head Page`: 这个连续内存空闲块地址最小的一页

PG_reserved (0 bit )表示此页是否被保留(reserved), 如果是被保留的页，则为1，不能被放到空闲页链表中，不能动态分配与释放。

PG_property (1bit)表示此页是否free，如果为1，表示free，页是可用内存块的首页，可以被分配；如果设置为0，表示：如果页是可用内存块的首页，那么这页已经被分配出去了，不能被再二次分配，或者就不是head page.

#### (1) `default_init`:

`free_area_t`

```c
typedef struct {
    list_entry_t free_list;         // the list header
    unsigned int nr_free;           // # of free pages in this free list
} free_area_t;
```

```
`free_list` is used to record the free memory blocks.
 * `nr_free` is the total number of the free memory blocks.
```

`free_list`：`list_entry_t`结构的双向链表指针，指针指向了空闲的物理页

`nr_free`记录当前空闲页的个数

`default_pmm.c`

```c
static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
}
```

无需修改

#### (2) `default_init_memmap`:

需要修改：

```c
static void
default_init_memmap(struct Page *base, size_t n) {
	assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
        //初始化n块物理页
        assert(PageReserved(p));
        p->flags = 0;
        SetPageProperty(p);//用来判断该页是否为保留页。
        p->property = 0;
        set_page_ref(p, 0);//虚拟页0
        list_add_before(&free_list, &(p->page_link));//加入空闲页队首
    }
    nr_free += n;
    base->property = n;
}
```

函数根据每个物理页帧的情况来建立空闲页链表。`for `循环把空闲物理页对应的`Page`结构中的`flags`和引用计数`ref`清零，因为现在`p`是自由的，没有引用。循环结束后`Head Page base property`为n，记录此块内的空闲页的个数。

#### (3) `default_alloc_pages`:

为分配指定页数的连续空闲物理空间，并且将第一页的Page结构的指针作为结果返回

需要修改：

```c
static struct Page *
default_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > nr_free) {
        return NULL;
    }
    //如果所有空闲块的空闲页总数都没有n个,直接return null
    list_entry_t *le, *le_next;  //free_list指针和它的下一个
    le = &free_list;
    //从头开始遍历保存空闲物理内存块的链表(按照物理地址的从小到大顺序)
    while((le=list_next(le)) != &free_list) {
    //通过宏le2page(memlayout.h)得指向Page的指针p
      struct Page *p = le2page(le, page_link);
      if(p->property >= n){
        //p->property表示空闲块的大小，大于n则进下一步
        int i;
        //for初始化空闲块中每一个页
        for(i=0;i<n;i++){
          le_next = list_next(le);
          struct Page *p2 = le2page(le, page_link);
          SetPageReserved(p2);//flags bit0 置1，表示已经被分配
          ClearPageProperty(p2);//falgs bit1 置0，表示已被分配
          list_del(le);//从free_list删除
          le = le_next;//指针后移
        }
        //如果选中的块大于n,需要修改剩下的块的head page的property
        if(p->property>n){
          (le2page(le,page_link))->property = p->property - n;
        }
        ClearPageProperty(p);
        SetPageReserved(p);
        nr_free -= n;
        return p;
      }
    }
    return NULL;//防止出错
}
```

#### (4) `default_free_pages`:

释放指定的某一物理页开始的若干个连续物理页，按照地址从小到大插入后和旁边的空闲块地址连续，考虑合并问题。

```
(5) `default_free_pages`:
 *  re-link the pages into the free list, and may merge small free blocks into the big ones.
 *  (5.1)    According to the base address of the withdrawed blocks, search the free list for its correct position (with address from low to high), and insert  the pages. (May use `list_next`, `le2page`, `list_add_before`)
 *  (5.2)  Reset the fields of the pages, such as `p->ref` and `p->flags` (PageProperty)
 *  (5.3)  Try to merge blocks at lower or higher addresses. Notice: This should  change some pages' `p->property` correctly.
```

```c
static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    //assert(PageReserved(base) && PageProperty(base));
    assert(PageReserved(base))
    //检查需要释放的页块是否已经被分配,只要看bit 0 reserve就好了
    list_entry_t *le = &free_list;
    struct Page * p;
    while((le=list_next(le)) != &free_list) {
      p = le2page(le, page_link);
      if(p>base){break;}
    }
    //将每一空闲页插入空闲链表中
    for(p=base;p<base+n;p++){
      list_add_before(le, &(p->page_link));
    }
    //修改页的各个属性置0
    base->flags = 0;
    set_page_ref(base, 0);
    ClearPageProperty(base);
    SetPageProperty(base);
    base->property = n;//有n空闲页
    p = le2page(le,page_link) ;
    //和高位方向的下一个内存块的地址连续，向高位合并
    if( base+n == p ){
      base->property += p->property;
      p->property = 0;
    }
    //如果是低位,向低地址合并
    //把le指针指向前一个内存块
    le = list_prev(&(base->page_link));  //previous
    p = le2page(le, page_link);
    if(le!=&free_list && p==base-1){
      while(le!=&free_list){
        if(p->property){
          p->property += base->property;
          base->property = 0;
          break;
        }
        le = list_prev(le);
        p = le2page(le,page_link);
      }
    }
   //更新总空闲页数
    nr_free += n;
    return ;
}
```

### 1.2 你的`first fit`算法是否有进一步的改进空间

时间复杂度高：每次查询第一块符合条件的空闲内存块时，最坏情况需要找遍整个链表，时间复杂度是O(n)

改进：用树结构来取代链表。可以用二叉树，O(<sub>log<sup>(n)</sup></sub>)

## 练习2：实现寻找虚拟地址对应的页表项（需要编程）

**通过设置页表和对应的页表项,可建立虚拟内存地址和物理内存地址的对应关系。其中的**
**get_pte函数是设置页表项环节中的一个重要步骤。此函数找到一个虚地址对应的二级页表项**
**的内核虚地址,如果此二级页表项不存在,则分配一个包含此项的二级页表。本练习需要补**
**全get_pte函数 in kern/mm/pmm.c,实现其功能。请仔细查看和理解get_pte函数中的注释。**
**get_pte函数的调用关系图如下所示:**

<img src="/home/cyhor/.config/Typora/typora-user-images/image-20191216193548087.png" alt="image-20191216193548087" style="zoom:72%;" />

**请在实验报告中简要说明你的设计实现过程。请回答如下问题：**

* **请描述页目录项`（Pag Director Entry）`和页表`（Page Table Entry）`中每个组成部分的含义和以及对`ucore`而言的潜在用处。**
* **如果`ucore`执行过程中访问内存，出现了页访问异常，请问硬件要做哪些事情？**

### 2.1 补全 get_pte

#### 预备知识

` kern/mm/pmm.c`

```
逻辑地址(虚地址):la  线性地址    物理地址pa
段式管理前一个实验已经讨论过。在ucore中段式管理只起到了一个过渡作用,它将逻辑地
址不加转换直接映射成线性地址,所以我们在下面的讨论中可以对这两个地址不加区分(目
前的 OS 实现也是不加区分的)  ---实验指导书
```

![img](https://img-blog.csdn.net/20171227160918632?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvdGFuZ3l1YW56b25n/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

相关宏(`pmm.h`)   

```c
#define alloc_page() alloc_pages(1) 

#define free_page(page) free_pages(page, 1)

```

`alloc_page()`分配的页的地址不是真正的页分配的地址，而是`Page`这个结构体所在的地址，需要通过`page2pa()`将`Page`结构体的地址转换为物理页地址的线性地址

```c
  LAB2 EXERCISE 2: YOUR CODE
     * MACROs or Functions:
     *PDX(la) = the index of page directory entry of VIRTUAL ADDRESS la.
        //返回地址la的页目录索引，即一级页表项的入口地址
     *KADDR(pa) : takes a physical address and returns the corresponding kernel virtual address.//get物理地址pa的虚拟地址
     *set_page_ref(page,1) : means the page be referenced by one time
        //设置此页被指向一次
     *page2pa(page): get the physical address of memory which this (struct Page *) page  manages//得到page结构体对应的物理地址
     *struct Page * alloc_page() : allocation a page  //分配一页
     *memset(void *s, char c, size_t n) : sets the first n bytes of the memory area pointed by s to the specified value c. //设置s指向地址的前面n个字节为字节‘c’
     *DEFINEs:
//填写页目录项的内容为：页目录项内容 = (页表起始物理地址 &0x0FFF) | PTE_U | PTE_W |PTE_P 
     *   PTE_P    0x001    // page table/directory entry flags bit : Present 存在 
     *   PTE_W    0x002    // page table/directory entry flags bit : Writeable 可写入
     *   PTE_U    0x004    // page table/directory entry flags bit : User can access用户能访问
```

#### 补全代码

`get_pte`给定一个虚拟地址，找出这个虚拟地址在二级页表中对应的项，如果此二级页表项不存在，则分配一个包含此项的二级页表。

```c
//get_pte - get pte and return the kernel virtual address of this pte for la 
//        - if the PT contians this pte didn't exist, alloc a page for PT
// parameter:
	//  pgdir:  the kernel virtual base address of PDT
	//  la:     the linear address need to map
	//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
```

```c
pte_t  *get_pte (pde_t *pgdir,  uintptr_t la, bool  create)
```

`pde_t`：一级页表的表项。

`pte_t`：二级页表的表项。

`uintptr_t` la：线性地址，由于段式管理只做直接映射，所以它也是逻辑地址。

`create`:   二级页表不存在: 

- if create == 0，get_pte返回NULL；

- if create != 0，get_pte申请一个新的物理页（alloc_page）在一级页表中添加页目录项指向表示二级页表的新物理页。新申请的页 所代表的虚拟地址都没有被映射，必须全部设定为零。

目前只有`boot_pgdir`一个页表，引入进程的概念之后每个进程都会有自己的页表。

`pmm.c`

````c
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    pde_t *pdep = &pgdir[PDX(la)];
    //获取一级页表项对应的入口地址
    if (!(*pdep & PTE_P)) {
        //物理页不存在, create==0, null
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {//分配失败
            return NULL;
        }
        //引用次数+1
        set_page_ref(page, 1);
        //物理地址
        uintptr_t pa = page2pa(page);
        ///物理地址转虚拟地址，并初始化,把新申请的   数目为pgsize个的页   全写为0	
        memset(KADDR(pa), 0, PGSIZE);
        //设置控制位
        *pdep = pa | PTE_U | PTE_W | PTE_P;
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
    //页目录项地址-->>页表物理地址-->>虚拟地址-->>页表项索引
    //PTX(la)：返回虚拟地址la的页表项索引
    //返回la对应的页表项入口地址
}
````

### 2.2描述页目录项PDE和页表PTE中每个组成部分的含义和以及对`ucore`而言的潜在用处

当PDE或PTE中有一个的属性`PTE_P=0`时，物理页就是无效的

- PTE可以指向一个物理页，也可以不指向物理页

- 多个PTE可以指向同一个物理页

- 一个PTE只能指向一个物理页

#### 2.2.1 PDE

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

#### 2.2.2 PTE

PTE高20位是物理页地址

0-11：`PTE_P,PTE_W,PTE_U,PTE_PWT,PTE_PCD,PTE_A,PTE_D,PTE_MBZ=0,Global,PTE_AVAIL`。

![PTE属性](https://img-blog.csdnimg.cn/20191018190528760.png)

#### 2.2.3 潜在用处

`AVAIL`位的设置 3位能表示0-7，可以用来储存页表的访问次数实现LFU等

### 2.3 如果`ucore`执行过程中访问内存，出现了页访问异常，请问硬件要做哪些事情？

1. 把引起页访问异常的线性地址放到CR2寄存器中  
2. CPU将错误代码压入堆栈，因为错误代码必须由异常处理程序进行分析，以确定如何处理异常
3. 中断服务例程会调用页访问异常处理函数do_pgfault进行具体处理

## 练习3：释放某虚地址所在的页并取消对应二级页表项的映射（需要编程）

**当释放一个包含某虚地址的物理内存页时，需要让对应此物理内存页的管理数据结构Page做相关的清除处理，使得此物理内存页成为空闲；另外还需把表示虚地址与物理地址对应关系的二级页表项清除。请仔细查看和理解page_remove_pte函数中的注释。为此，需要补全在 kern/mm/pmm.c中的page_remove_pte函数。page_remove_pte函数的调用关系图如下所示：**

**<img src="https://tva1.sinaimg.cn/large/006y8mN6ly1g8mkb63r1aj309o023q34.jpg" style="zoom:150%;" />**

**请在实验报告中简要说明你的设计实现过程。请回答如下问题：**

* **数据结构Page的全局变量（其实是一个数组）的每一项与页表中的页目录项和页表项有无对应关系？如果有，其对应关系是啥？**
* **如果希望虚拟地址与物理地址相等，则需要如何修改lab2，完成此事？ 鼓励通过编程来具体完成这个问题**

### 3.1 `page_remove_pte`函数

`pmm.c`

```
tlb_invalidate(pde_t *pgdir, uintptr_t la) : 
Invalidate a TLB entry, but only if the page tables being edited are the ones currently in use by the processor.//只去掉当前处理的PTE
```

```c
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
    if (*ptep & PTE_P) {
        //判断页表中该表项是否存在
        struct Page *page = pte2page(*ptep);//获得相应的page
        if (page_ref_dec(page) == 0) {
            ////除了当前进程，没有别的进程引用
            free_page(page);
        }
        *ptep &= (~PTE_P); 
        // 将PTE的存在位设置为0，表示该映射关系无效
        tlb_invalidate(pgdir, la);
         //刷新TLB
    }
}
```

执行qemu

报错如下：

```
memory management: default_pmm_manager
e820map:
  memory: 0009fc00, [00000000, 0009fbff], type = 1.
  memory: 00000400, [0009fc00, 0009ffff], type = 2.
  memory: 00010000, [000f0000, 000fffff], type = 2.
  memory: 07ee0000, [00100000, 07fdffff], type = 1.
  memory: 00020000, [07fe0000, 07ffffff], type = 2.
  memory: 00040000, [fffc0000, ffffffff], type = 2.
kernel panic at kern/mm/default_pmm.c:218:
    assertion failed: (p1 = alloc_page()) != NULL
stack trackback:
```

一开始以为是meld哪里出错了，然后又感觉应该是是初始化出错

最后发现自己忘记保存default_init_memmap()的修改……

再执行：

```
memory management: default_pmm_manager
e820map:
  memory: 0009fc00, [00000000, 0009fbff], type = 1.
  memory: 00000400, [0009fc00, 0009ffff], type = 2.
  memory: 00010000, [000f0000, 000fffff], type = 2.
  memory: 07ee0000, [00100000, 07fdffff], type = 1.
  memory: 00020000, [07fe0000, 07ffffff], type = 2.
  memory: 00040000, [fffc0000, ffffffff], type = 2.
check_alloc_page() succeeded!
check_pgdir() succeeded!
check_boot_pgdir() succeeded!
-------------------- BEGIN --------------------
PDE(0e0) c0000000-f8000000 38000000 urw
  |-- PTE(38000) c0000000-f8000000 38000000 -rw
PDE(001) fac00000-fb000000 00400000 -rw
  |-- PTE(000e0) faf00000-fafe0000 000e0000 urw
  |-- PTE(00001) fafeb000-fafec000 00001000 -rw
--------------------- END ---------------------
++ setup timer interrupts
100 ticks
100 ticks
```

### 3.2 数据结构Page的全局变量（其实是一个数组）的每一项与页表中的页目录项和页表项有无对应关系？如果有，其对应关系是啥？

有

`kern/mm/mmu.h`	

```c
// A linear address 'la' has a three-part structure as follows:
//
// +--------10------+-------10-------+---------12----------+
// | Page Directory |   Page Table   | Offset within Page  |
// |      Index     |     Index      |                     |
// +----------------+----------------+---------------------+
//  \--- PDX(la) --/ \--- PTX(la) --/ \---- PGOFF(la) ----/
//  \----------- PPN(la) -----------/
//
// The PDX, PTX, PGOFF, and PPN macros decompose linear addresses as shown.
// To construct a linear address la from PDX(la), PTX(la), and PGOFF(la),
// use PGADDR(PDX(la), PTX(la), PGOFF(la)).
线性地址的高20位是页目录项索引PDX与页表项索引PTX的组合PPN。
```

![image-20191225112401660](/home/cyhor/.config/Typora/typora-user-images/image-20191225112401660.png)

数组中每一个Page对应物理内存中的一个页

线性地址高20位可以唯一对应对应page中的一项。

### 3.3 如果希望虚拟地址与物理地址相等，则需要如何修改lab2，完成此事？ 鼓励通过编程来具体完成这个问题

思路：ucore执行时，va=la=pa+0xc0000000，所以应该可以去除0xc0000000的偏移来解决问题  直接去掉它

编程实现：失败

- 第一阶段 bootloader 阶段

从bootasm.S的start到entry.S的kern_entry前，这个阶段很简单， 和lab1一样

(这时的GDT中每个段的起始地址都是0x00000000并且此时kernel还没有载入)。

```
va=la=pa
```

- 第二阶段

这个阶段就是从entry.S的kern_entry到pmm.c的enable_paging()。 

再次更新了段映射,还没有启动页映射机制

`bootmain.c`  调用bootmain 在第一阶段没进kernel时 

```
#define ELFHDR ((struct elfhdr *)0x10000)
```

由此可知`kernel`被放在物理地址为0x100000的内存空间

原本的对应关系：

```
virt addr - 0xC0000000 = linear addr = phy addr
```

`kernel.ld` 

```
OUTPUT_FORMAT("elf32-i386", "elf32-i386", "elf32-i386")
OUTPUT_ARCH(i386)
ENTRY(kern_entry)

SECTIONS {
    /* Load the kernel at this address: "." means the current address */
    . = 0xC0100000;
```

可知`kernel`的虚拟地址是`0xC0100000`.

所以尝试直接修改链接地址为：`0x100000` 然后去掉`0xC0000000`

分别在 `kernel.ld`  `memlayout.h`

```
 /* Load the kernel at this address: "." means the current address */
    . = 0x100000;
 /* All physical memory mapped at this address */
#define KERNBASE            0x00000000
#define KMEMSIZE            0x38000000    
```

- 第三阶段

kmm.c的enable_paging()到kmm.c的gdt_init()。 启动了页映射机制,但没有第三次更新段映射

并且在boot_map_segment()中将线性地址按照如下规则进行映射：

原本：

```
virt addr - 0xC0000000 = linear addr = phy addr + 0xC0000000 # 线性地址在0~4MB之外的三者映射关系
virt addr - 0xC0000000 = linear addr = phy addr # 线性地址在0~4MB之内的三者映射关系
```

- 第四阶段  

开始于gdt_init()。gdt_init()重新设置GDT。三次更新了段映射,形成了新的段页式映射机制,并且取消了临时映射关系,即
执行语句`boot_pgdir[0] =0;`把`boot_pgdir[0]`的第一个页目录表项(0~4MB)清零来取消临时的页映射关系。

```
virt addr = linear addr = phy addr + 0xC0000000
```



执行qemu:

```
WARNING: Image format was not specified for 'bin/ucore.img' and probing guessed raw.
         Automatically detecting the format is dangerous for raw images, write operations on block 0 will be restricted.
         Specify the 'raw' format explicitly to remove the restrictions.
```

