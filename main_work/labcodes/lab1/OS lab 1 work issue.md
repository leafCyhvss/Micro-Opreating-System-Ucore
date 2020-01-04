# OS lab 1 work issue: OS启动、中断与设备管理

# 1    练习1: 通过make生成执行文件的过程

## 1.1  操作系统镜像文件ucore.img是如何一步一步生成的？

ISR中断服务例程

(Makefile中每一条相关命令和-命令参数的含义及结果)

Makefile通过一系列命令(gcc, ld)生成了bootblock和kernel这两个elf文件，之后通过dd命令将bootblock放到第一个sector，将kernel放到第二个sector开始的区域。bootblock就是引导区即bootloader，kernel是ucore os内核。

### make V= 输出的编译过程分析：

#### **gcc编译 .c  .S  生成 .o**   

下面截取的是编译 init.c 生成 init.o     编译stdio.c生成stdio.o 

```makefile
cyhor@cyhor-911Air:~/ucore_os_lab-master/labcodes/lab1$ make V=
+ cc kern/init/init.c
gcc -Ikern/init/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/init/init.c -o obj/kern/init/init.o

+ cc kern/libs/stdio.c
gcc -Ikern/libs/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/libs/stdio.c -o obj/kern/libs/stdio.o
```

**一共生成了：**

```
init.o/readline.o/stdio.o/kdebug.o/kmonitor.o/panic.o/clock.o/console.o/intr.o/picirq.o/trap.o/trapentry.o/vectors.o/pmm.o/string.o/printfmt.o
```



#### **ld 转换.o文件成为可执行文件：**

`bin/kernel`  ` bin/bootblock` `bin/sign` `ucore.img`

```makefile
# 链接生成的所有目标文件，生成 kernel 
+ ld bin/kernel
ld -m    elf_i386 -nostdlib -T tools/kernel.ld -o bin/kernel  obj/kern/init/init.o obj/kern/libs/stdio.o obj/kern/libs/readline.o obj/kern/debug/panic.o obj/kern/debug/kdebug.o obj/kern/debug/kmonitor.o obj/kern/driver/clock.o obj/kern/driver/console.o obj/kern/driver/picirq.o obj/kern/driver/intr.o obj/kern/trap/trap.o obj/kern/trap/vectors.o obj/kern/trap/trapentry.o obj/kern/mm/pmm.o  obj/libs/string.o obj/libs/printfmt.o

# 编译 bootasm.S / bootmain.c / sign.c  # 生成 sign 文件
+ cc boot/bootasm.S
gcc -Iboot/ -fno-builtin -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Os -nostdinc -c boot/bootasm.S -o obj/boot/bootasm.o
+ cc boot/bootmain.c
gcc -Iboot/ -fno-builtin -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Os -nostdinc -c boot/bootmain.c -o obj/boot/bootmain.o
+ cc tools/sign.c
gcc -Itools/ -g -Wall -O2 -c tools/sign.c -o obj/sign/tools/sign.o

gcc -g -Wall -O2 obj/sign/tools/sign.o -o bin/sign

# 链接生成 bootblock 
+ ld bin/bootblock
ld -m    elf_i386 -nostdlib -N -e start -Ttext 0x7C00 obj/boot/bootasm.o obj/boot/bootmain.o -o obj/bootblock.o
'obj/bootblock.out' size: 472 bytes
build 512 bytes boot sector: 'bin/bootblock' success!
```



####   **dd 把bootblock 和  kernel 放到虚拟硬盘ucore.img里**

```
dd if=/dev/zero of=bin/ucore.img count=10000
10000+0 records in
10000+0 records out
5120000 bytes (5.1 MB, 4.9 MiB) copied, 0.0162382 s, 315 MB/s
dd if=bin/bootblock of=bin/ucore.img conv=notrunc
1+0 records in
1+0 records out
512 bytes copied, 5.8741e-05 s, 8.7 MB/s
dd if=bin/kernel of=bin/ucore.img seek=1 conv=notrunc
146+1 records in
146+1 records out
74812 bytes (75 kB, 73 KiB) copied, 0.000347705 s, 215 MB/s
```

#### 命令参数含义：

**GCC:**

```
-I<dir>  添加搜索头文件的路径
-fno-builtin  只识别以 __builtin_为前缀的 GCC 內建函数,不接受非“__”开头的内建函数
-Wall	显示警告信息
-ggdb	生成可供gdb使用的调试信息
-m32	生成 32位机器代码
-gstabs	产生 stabs 格式的调试信息,monitor可以显示出便于开发者阅读的函数调用栈信息
-nostdinc	不在标准库目录中搜索头文件
-fno-stack-protector	禁用堆栈保护机制,不生成用于检测缓冲区溢出的代码
-Os  为减小代码大小而进行优化。
```

**LD**

```
-m <emulation>  模拟为i386上的连接器
-N  设置代码段和数据段均可读写
-nostdlib    不使用标准库，只搜索命令行中显示制定的库目录
-Ttext    指定在输出文件中的开始位置，绝对地址
```

**DD**

```
if = 文件名：输入文件名，缺省为标准输入。
of = 文件名：输出文件名，缺省为标准输出。
skip = blocks：从输入文件开头跳过blocks个块后再开始复制。
seek = blocks：从输出文件开头跳过blocks个块后再开始复制。
count = blocks：仅拷贝blocks个块，块大小等于ibs指定的字节数。
```

### Makefile 如下：

#### **批量编译**

**call的用法：**

```
$(call <expression>,<parm1>,<parm2>,<parm3>...)
```

call可将多个参数传给指定函数。因为call是可以带任意数量的参数的，所以其实可以粗糙地理解能用它实现批处理。

从1-139行都是解决环境问题，设置环境变量和编译选项

其中，对应上述编译输出信息中的第一步的117和136行：

```
117 $(call add_files_cc,$(call listf_cc,$(LIBDIR)),libs,)
```

是把libs目录下的所有`.c（和.S）`文件编译产生`.o`文件放在`obj/libs`目录下

```
136 $(call add_files_cc,$(call listf_cc,$(KSRCDIR)),kernel,$(KCFLAGS))
```

把`kern`目录下的所有`.c（和.S）`文件编译产生`.o`文件放在`obj/kern/**`目录下

#### 生成kernel：

指定`bin/kernel`<sup>1</sup>，链接`kernel.ld`（已有）<sup>2</sup>，把`kern`内的`.c`源代码编译为`.o`文件<sup>3</sup>，链接`.o`文件得到可执行文件`kernel`  <sup>4</sup>

```
140 # create kernel target
141 kernel = $(call totarget,kernel)  1
142 
143 $(kernel): tools/kernel.ld  2
144 
145 $(kernel): $(KOBJS)                  3
146         @echo + ld $@
147         $(V)$(LD) $(LDFLAGS) -T tools/kernel.ld -o $@ $(KOBJS)
148         @$(OBJDUMP) -S $@ > $(call asmfile,kernel)
149         @$(OBJDUMP) -t $@ | $(SED) '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > $(call       	 symfile,kernel)
150 #可重定位的二进制目标文件
151 $(call create_target,kernel)         4
152 
153 # -------------------------------------------------------------------
```

#### 生成`bootblock`：

指定`bin/bootblock`，把boot内的`.c/.S`文件编译生成`.o`文件<sup>1</sup>，链接所有`.o`文件得到`bootblock.o`<sup>2</sup>，生成`.out`文件，可执行文件`bootblock`<sup>3</sup>

```
153 # -------------------------------------------------------------------
154 
155 # create bootblock
156 bootfiles = $(call listf_cc,boot)   1
157 $(foreach f,$(bootfiles),$(call cc_compile,$(f),$(CC),$(CFLAGS) -Os -nostdinc))
158 
159 bootblock = $(call totarget,bootblock)      2
160 
161 $(bootblock): $(call toobj,$(bootfiles)) | $(call totarget,sign)
162         @echo + ld $@
163         $(V)$(LD) $(LDFLAGS) -N -e start -Ttext 0x7C00 $^ -o $(call toobj,bootblock)
164         @$(OBJDUMP) -S $(call objfile,bootblock) > $(call asmfile,bootblock)
165         @$(OBJCOPY) -S -O binary $(call objfile,bootblock) $(call outfile,bootblock)
166         @$(call totarget,sign) $(call outfile,bootblock) $(bootblock)
167 
168 $(call create_target,bootblock) 3
169 
170 # -------------------------------------------------------------------
```

#### 生成sign工具：

为将输入文件拷贝到输出，控制输出文件大小。将`bootloader`对齐到一个扇区的大小（512B）  (见`sign.c`)

````
170 # -------------------------------------------------------------------
171 
172 # create 'sign' tools
173 $(call add_files_host,tools/sign.c,sign,sign)
174 $(call create_target_host,sign,sign)
175 
176 # -------------------------------------------------------------------
````

#### 生成`ucore.img`：

用0填充，生成一个10000字节的块，然后将`bootloader`和`kernel`拷贝过去

```
176 # -------------------------------------------------------------------
177 
178 # create ucore.img
179 UCOREIMG        := $(call totarget,ucore.img)
180 
181 $(UCOREIMG): $(kernel) $(bootblock)
182         $(V)dd if=/dev/zero of=$@ count=10000
183         $(V)dd if=$(bootblock) of=$@ conv=notrunc
184         $(V)dd if=$(kernel) of=$@ seek=1 conv=notrunc
185 
186 $(call create_target,ucore.img)
187 
188 #
```



## 1.2一个被系统认为是符合规范的硬盘主引导扇区的特征是什么？

依据`tools/sign.c` 文件：

### 大小为512字节

```
char buf[512];
if (size != 512) {
    fprintf(stderr, "write '%s' error, size is %d.\n", argv[2], size);
    return -1;
}
```

### 最后两个字节为0x55AA

```
buf[510] = 0x55;    buf[511] = 0xAA;
```

# 2 练习2：使用qemu执行并调试lab1中的软件

## 2.1 从CPU加电后执行的第一条指令开始,单步跟踪BIOS的执行

查看`tools/gdbinit`

```
file bin/kernel        #加载bin/kernel 
target remote :1234    #与qemu连接
set architecture i8086 #设置当前调试的CPU是8086
break kern_init        #第一步就是对kern/init/init.c 编译
continue            
```

(来自实验指导书):  结合练习2第3小问，在makefile 的debug中添加`-d in_asm -D q.log`参数，将运行的汇编指令保存在q.log中。

修改前的Makefile 如下：

```
debug: $(UCOREIMG)
	$(V)$(QEMU) -S -s -parallel stdio -hda $< -serial null &
	$(V)sleep 2
	$(V)$(TERMINAL) -e "gdb -q -tui -x tools/gdbinit"
```

修改后的Makefile 如下：

```
debug: $(UCOREIMG)
		$(V)$(TERMINAL) -e "$(QEMU) -S -s -d in_asm -D $(BINDIR)/q.log -parallel stdio -hda $< -serial null"
		$(V)sleep 2
		$(V)$(TERMINAL) -e "gdb -q -tui -x tools/gdbinit"
```

之后，执行make debug，开始gdb调试：

```
Breakpoint 1, kern_init () at kern/init/init.c:17
(gdb) x/i $pc
=> 0x100000 <kern_init>:        push   %ebp
(gdb) 
```

输入`si` 单步调试

## 2.2 在初始化位置0x7c00设置实地址断点,测试断点正常

设置断点

```
(gdb) b *0x7c00    
Breakpoint 2 at 0x7c00
```

输入continue两次回到断点2

```
Breakpoint 2, 0x00007c00 in ?? ()
(gdb) 
```

显示EIP接下来10条指令`x/10i $pc`测试断点正常

```
=> 0x7c00:      cli
   0x7c01:      cld
   0x7c02:      xor    %eax,%eax
   0x7c04:      mov    %eax,%ds
   0x7c06:      mov    %eax,%es
   0x7c08:      mov    %eax,%ss
   0x7c0a:      in     $0x64,%al
  ---Type <return> to continue, or q <return> to quit---
   0x7c0a:      in     $0x64,%al
   0x7c0c:      test   $0x2,%al
   0x7c0e:      jne    0x7c0a
   0x7c10:      mov    $0xd1,%al
```

## 2.3 从0x7c00开始跟踪代码运行,将单步跟踪反汇编得到的代码与bootasm.S和 bootblock.asm进行比较

`tools/gdbinit` 末尾添加

```
b *0x7c00
continue
x /10i $pc
```

结合第一小问就加进去的

```
$(QEMU) -S -s -d in_asm -D $(BINDIR)/q.log -parallel stdio -hda $< -serial null
```

生成q.log 文件

`boot/bootasm.S` 中

```
  	cli                                             # Disable interrupts
    cld                                             # String operations increment
    # Set up the important data segment registers (DS, ES, SS).
    xorw %ax, %ax                                   # Segment number zero
    movw %ax, %ds                                   # -> Data Segment
    movw %ax, %es                                   # -> Extra Segment
    movw %ax, %ss                                   # -> Stack Segment
```

单步跟踪反汇编得到的代码和这些几乎没有差别： movw->mov   

## 2.4 自己找一个bootloader或内核中的代码位置，设置断点并进行测试

设置断点`b *0x7c08`

```
Breakpoint 7, 0x00007c08 in ?? ()
(gdb) x/6i $pc
=> 0x7c08:      mov    %eax,%ss
   0x7c0a:      in     $0x64,%al
   0x7c0c:      test   $0x2,%al
   0x7c0e:      jne    0x7c0a
   0x7c10:      mov    $0xd1,%al
   0x7c12:      out    %al,$0x64
(gdb)quit
```

# 3 练习3：分析bootloader进入保护模式的过程

## 1 宏定义

宏定义：内核代码段，内核数据段，保护模式使能标志

```
.set PROT_MODE_CSEG,        0x8                     # kernel code segment selector
.set PROT_MODE_DSEG,        0x10                    # kernel data segment selector
.set CR0_PE_ON,             0x1                     # protected mode enable flag
```

## 2 清理环境

进入`0x7c00`后

屏蔽中断

flag置0

数据段寄存器置0

附加段寄存器置0

堆栈段寄存器置0

```
start:
.code16                                             # Assemble for 16-bit mode
    cli                                             # Disable interrupts
    cld                                             # String operations increment
    # Set up the important data segment registers (DS, ES, SS).
    xorw %ax, %ax                                   # Segment number zero
    movw %ax, %ds                                   # -> Data Segment
    movw %ax, %es                                   # -> Extra Segment
    movw %ax, %ss                                   # -> Stack Segment
```

## 3 开启A20：

初始状态，A20地址线控制是置0的

先读0x64端口的第2位，如果 input buffer 是空的，seta20.1是往端口0x64写数据0xd1，oxd1指的是要往8042芯片的P2端口写数据。 input buffer 为空时，seta20.2是往端口0x60写数据0xdf，从而将8042芯片的P2端口对应字节的第2位置1

原先20位只能访问1M，开启后32条地址线可访问4G

```
inb 从I/O端口读取一个字节(BYTE, HALF-WORD) ;
outb 向I/O端口写入一个字节（BYTE, HALF-WORD） ;
testb: means if 
jnz:  jump
```

```
seta20.1:
    inb $0x64, %al                           # Wait for not busy(8042 input buffer empty).
    testb $0x2, %al
    jnz seta20.1

    movb $0xd1, %al                          # 0xd1 -> port 0x64
    outb %al, $0x64                          # 0xd1 means: write data to 8042's P2 port

seta20.2:
    inb $0x64, %al                           # Wait for not busy(8042 input buffer empty).
    testb $0x2, %al
    jnz seta20.2

    movb $0xdf, %al                          # 0xdf -> port 0x60
    outb %al, $0x60                 # 0xdf = 11011111, means set P2's A20 bit(the 1 bit) to 1
```

## 4 加载GDT进入保护模式：

`CR0_PE_ON`恒为1，`cr0`置0实模式，`cr0`置1保护模式，跳转指令进入保护模式，更新cs的基地址

```
lgdt gdtdesc
movl %cr0, %eax
orl $CR0_PE_ON, %eax
movl %eax, %cr0

ljmp $PROT_MODE_CSEG, $protcseg
```

`GDT`表由三个全局描述符组成，空段       代码段描述符       数据段描述符

```
77 # Bootstrap GDT
78 .p2align 2                                          # force 4 byte alignment
79 gdt:
80     SEG_NULLASM                                     # null seg
81     SEG_ASM(STA_X|STA_R, 0x0, 0xffffffff)           # code seg for bootloader and kernel
82     SEG_ASM(STA_W, 0x0, 0xffffffff)                 # data seg for bootloader and kernel
83 
84 gdtdesc:
85     .word 0x17                                      # sizeof(gdt) - 1
86     .long gdt                                       # address gdt
```

## 5 设置段寄存器  建立堆栈空间  进入bootmain

```
.code32                                             # Assemble for 32-bit mode
protcseg:
    # Set up the protected-mode data segment registers
    movw $PROT_MODE_DSEG, %ax                       # Our data segment selector
    movw %ax, %ds                                   # -> DS: Data Segment
    movw %ax, %es                                   # -> ES: Extra Segment
    movw %ax, %fs                                   # -> FS
    movw %ax, %gs                                   # -> GS
    movw %ax, %ss                                   # -> SS: Stack Segment

    # Set up the stack pointer and call into C. The stack region is from 0--start(0x7c00)
    movl $0x0, %ebp
    movl $start, %esp
    call bootmain
```

# 4 练习4：分析bootloader加载ELF格式的OS的过程

## 4.1 bootloader如何读取硬盘扇区的？

bootloader的访问硬盘都是通过CPU访问硬盘的IO地址寄存器完成.

访问第一个硬盘的扇区可设置IO地址寄存器0x1f0-0x1f7实现的

```
0x1F0：0号硬盘数据寄存器
0x1F1：错误寄存器
0x1F2：数据扇区计数
0x1F3：扇区数
0x1F4：柱面（低字节）
0x1F5：柱面（高字节）
0x1F6：驱动器/磁头寄存器
0x1F7：状态寄存器（读），命令寄存器（写）
```

 **boot/bootmain.c**

### **`readsect`函数:**

读取磁盘扇区，将`secno`对应的扇区拷贝到指针`dst`处<sup>1</sup>；`waitdisk`函数等待地址0x1F7给出指令读磁盘<sup>2</sup>；读取扇区数为1，`secno`的0-7，8-15，16-23，24-27表偏移量(一共有28)，28位0表示访问disk0，29-31位1；最后0x1F7输出0x20，把磁盘扇区数据读到指定`dst`位置

```
/* readsect - read a single sector at @secno into @dst */
static void
readsect(void *dst, uint32_t secno) {               1
    // wait for disk to be ready
    waitdisk();                                     2

    outb(0x1F2, 1);                                #只读一个扇区
    outb(0x1F3, secno & 0xFF);
    outb(0x1F4, (secno >> 8) & 0xFF);
    outb(0x1F5, (secno >> 16) & 0xFF);
    outb(0x1F6, ((secno >> 24) & 0xF) | 0xE0);
    
    outb(0x1F7, 0x20);                         // cmd 0x20 - read sectors

    // wait for disk to be ready
    waitdisk();                                     2

    // read a sector
    insl(0x1F0, dst, SECTSIZE / 4);
}
```

### `readseg`函数：

包装readsect，在offset处读取count个字节从内核到虚拟内存va，实现可以读取任意长度的内容。

**`secno`加1因为0扇区被引导占用，`elf`从1扇区开始<sup>1</sup>**

````
static void
readseg(uintptr_t va, uint32_t count, uint32_t offset) {
    uintptr_t end_va = va + count;

    // round down to sector boundary
    va -= offset % SECTSIZE;

    // translate from bytes to sectors; kernel starts at sector 1
    uint32_t secno = (offset / SECTSIZE) + 1;---------------------------0被占用
    
    <sup>1<sup>
    
    // If this is too slow, we could read lots of sectors at a time.
    // We'd write more to memory than asked, but it doesn't matter --
    // we load in increasing order.
    for (; va < end_va; va += SECTSIZE, secno ++) {
        readsect((void *)va, secno);
    }
}
````

## 4.2 bootloader是如何加载ELF格式的OS？

根据`header`判断是不是elf文件

**在c语言中，把直接使用的常数叫做幻数。**

### kernel 是elf执行文件  

```
$ file kernel 
kernel: ELF 32-bit LSB executable, Intel 80386, version 1 (SYSV), statically linked, not stripped
```

 **libs/elf.h**

```c
struct elfhdr {
    uint32_t e_magic;     // must equal ELF_MAGIC
```

### boot/bootmain.c中：

step1：通过`e_magic`判断是否为合法的elf；

step2：从磁盘中加载OS，`ph`表示`ELF`段表首地址，描述ELF文件应加载到内存什么位置，`eph`表示段表末地址；

根据ELF的`e_entry`，找到内核的入口

```c
 ((void (*)(void))(ELFHDR->e_entry & 0xFFFFFF))();
```



```c
/* bootmain - the entry of bootloader */
void
bootmain(void) {
    // read the 1st page off disk
    readseg((uintptr_t)ELFHDR, SECTSIZE * 8, 0);

    // is this a valid ELF?
    if (ELFHDR->e_magic != ELF_MAGIC) {
        goto bad;
    }

    struct proghdr *ph, *eph;

    // load each program segment (ignores ph flags)
    ph = (struct proghdr *)((uintptr_t)ELFHDR + ELFHDR->e_phoff);
    eph = ph + ELFHDR->e_phnum;
    for (; ph < eph; ph ++) {
        readseg(ph->p_va & 0xFFFFFF, ph->p_memsz, ph->p_offset);
    }

    // call the entry point from the ELF header
    // note: does not return
    ((void (*)(void))(ELFHDR->e_entry & 0xFFFFFF))();

bad:
    outw(0x8A00, 0x8A00);
    outw(0x8A00, 0x8E00);

    /* do nothing */
    while (1);
}
```

# 5  练习5：实现函数调用堆栈跟踪函数

## 代码补全  kern/debug/kdebug.c

```c
void
print_stackframe(void) {
     /* LAB1 YOUR CODE : STEP 1 */
     /* (1) call read_ebp() to get the value of ebp. the type is (uint32_t);
      * (2) call read_eip() to get the value of eip. the type is (uint32_t);
      * (3) from 0 .. STACKFRAME_DEPTH
      *    (3.1) printf value of ebp, eip
      *    (3.2) (uint32_t)calling arguments [0..4] = the contents in address (uint32_t)ebp +2 [0..4]
      *    (3.3) cprintf("\n");
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp=read_ebp(),eip=read_eip();
	int i;//这里在for循环里定义好像不行的样子就拿出来了
	for(i=0;ebp!=0&&i<STACKFRAME_DEPTH;i++)
    {
		cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
		uint32_t *args = (uint32_t *)ebp + 2;       //ebp+8指向参数，+4指向返回值
		cprintf("arg :0x%08x 0x%08x 0x%08x 0x%08x\n",*(args+0),*(args+1),*(args+2),*(args+3));
        //依次打印调用函数的参数1 2 3 4
		cprintf("\n");
		print_debuginfo(eip - 1);//eip指向的是下一条指令，所以这里减1  指针占4
		eip = ((uint32_t *)ebp)[1]; //此时eip指向返回地址
		ebp = ((uint32_t *)ebp)[0];//ebp存的是调用者ebp，所以这里就复原了调用前ebp值
	}
}
```

```
1. +|栈底方向| 高位地址
2. | ... |
3. | ... |
4. | 参数3 |
5. | 参数2 |
6. | 参数1 |
7. | 返回地址 |
8. | 上一层[ebp]    | <-------- [ebp]
9. | 局部变量|      |低位地址
```

eip/ebp/esp  next       base<sub>bottem&high</sub>          stack<sup>top&low</sup>    

这里题目给的注释写的非常清楚

从高址栈底到低址栈顶：arg(参数)->eip->ebp->var(变量)->esp

## 执行make qemu:

```
Kernel executable memory footprint: 64KB
ebp:0x00007b08 eip:0x00100a74 args:arg :0x00010094 0x00000000 0x00007b38 0x00100092

    kern/debug/kdebug.c:305: print_stackframe+22
ebp:0x00007b18 eip:0x00100d6c args:arg :0x00000000 0x00000000 0x00000000 0x00007b88
 1函数参数入栈      2函数栈顶作为当前函数栈底
    kern/debug/kmonitor.c:125: mon_backtrace+10
ebp:0x00007b38 eip:0x00100092 args:arg :0x00000000 0x00007b60 0xffff0000 0x00007b64

    kern/init/init.c:48: grade_backtrace2+33
ebp:0x00007b58 eip:0x001000bb args:arg :0x00000000 0xffff0000 0x00007b84 0x00000029

    kern/init/init.c:53: grade_backtrace1+38
ebp:0x00007b78 eip:0x001000d9 args:arg :0x00000000 0x00100000 0xffff0000 0x0000001d

    kern/init/init.c:58: grade_backtrace0+23
ebp:0x00007b98 eip:0x001000fe args:arg :0x001032fc 0x001032e0 0x0000130a 0x00000000

    kern/init/init.c:63: grade_backtrace+34
ebp:0x00007bc8 eip:0x00100055 args:arg :0x00000000 0x00000000 0x00000000 0x00010094

    kern/init/init.c:28: kern_init+84
ebp:0x00007bf8 eip:0x00007d68 args:arg :0xc031fcfa 0xc08ed88e 0x64e4d08e 0xfa7502a8

    <unknow>: -- 0x00007d67 --
++ setup timer interrupts
```

### 其中最后一行：

```
 kern/init/init.c:28: kern_init+84
ebp:0x00007bf8 eip:0x00007d68 args:arg :0xc031fcfa 0xc08ed88e 0x64e4d08e 0xfa7502a8

    <unknow>: -- 0x00007d67 --
```

#### ebp   0x00007bf8:

进入保护模式之后，`call bootmain`，`bootmain`是第一个使用堆栈的函数，调用`kern_init`

而通过练习2，bootmain 从`0x7c00`开始，`call`指令压栈，所以`0x7c00-0x0008`=`0x7bf8`    1Byte=8bit

#### eip   0x00007d68:

`bootmain`函数调用`kern_init`的指令的下一条指令的地址

查看`obj/bootblock.asm`，对应输出结果

```asm
static inline void
outw(uint16_t port, uint16_t data) {
    asm volatile ("outw %0, %1" :: "a" (data), "d" (port));
    7d68:	ba 00 8a ff ff       	mov    $0xffff8a00,%edx
    7d6d:	89 d0                	mov    %edx,%eax
    7d6f:	66 ef                	out    %ax,(%dx)
    7d71:	b8 00 8e ff ff       	mov    $0xffff8e00,%eax
    7d76:	66 ef                	out    %ax,(%dx)
    7d78:	eb fe                	jmp    7d78 <bootmain+0xa7>
```

#### `args`:`arg `: 0xc031fcfa 0xc08ed88e 0x64e4d08e 0xfa7502a8

`bootmain`函数调用`kern_init`并没传递任何输入参数，所以这里好像就保留edp往栈顶方向的4-20字节

```asm
start:
.code16                                             # Assemble for 16-bit mode
    cli                                             # Disable interrupts
    7c00:	fa                   	cli    
    cld                                             # String operations increment
    7c01:	fc                   	cld    

    # Set up the important data segment registers (DS, ES, SS).
    xorw %ax, %ax                                   # Segment number zero
    7c02:	31 c0                	xor    %eax,%eax
    movw %ax, %ds                                   # -> Data Segment
    7c04:	8e d8                	mov    %eax,%ds
    movw %ax, %es                                   # -> Extra Segment
    7c06:	8e c0                	mov    %eax,%es
    movw %ax, %ss                                   # -> Stack Segment
    7c08:	8e d0                	mov    %eax,%ss

00007c0a <seta20.1>:
    # Enable A20:
    #  For backwards compatibility with the earliest PCs, physical
    #  address line 20 is tied low, so that addresses higher than
    #  1MB wrap around to zero by default. This code undoes this.
seta20.1:
    inb $0x64, %al                                  # Wait for not busy(8042 input buffer empty).
    7c0a:	e4 64                	in     $0x64,%al
    testb $0x2, %al
    7c0c:	a8 02                	test   $0x2,%al
    jnz seta20.1
    7c0e:	75 fa                	jne    7c0a <seta20.1>

```

# 6 练习六：完善中断初始化和处理



## 6.1 中断描述符表（也可简称为保护模式下的中断向量表）中一个表项占多少字节？其中哪几位代表中断处理代码的入口？

**IDT是一个8字节，64bit的描述符数组**

**0-1、6-7字节是offset**   最低16位和最高16位

**2-3字节是段选择子，通过段选择子得到段基址**    16-31位

**段基址加上offset即得到中断处理代码的入口**

**查看 `kern/mm/mmu.h`**

```c
/* Gate descriptors for interrupts and traps */
struct gatedesc {
    unsigned gd_off_15_0 : 16;        // low 16 bits of offset in segment
    unsigned gd_ss : 16;            // segment selector
    unsigned gd_args : 5;            // # args, 0 for interrupt/trap gates
    unsigned gd_rsv1 : 3;            // reserved(should be zero I guess)
    unsigned gd_type : 4;            // type(STS_{TG,IG32,TG32})
    unsigned gd_s : 1;                // must be 0 (system)
    unsigned gd_dpl : 2;            // descriptor(meaning new) privilege level
    unsigned gd_p : 1;                // Present
    unsigned gd_off_31_16 : 16;        // high bits of offset in segment
};
```

## 6.2 编程完善kern/trap/trap.c中对中断向量表进行初始化的函数`idt_init`

#### **查看 `kern/mm/mmu.h`**

```c
#define SETGATE(gate, istrap, sel, off, dpl) {            \
    (gate).gd_off_15_0 = (uint32_t)(off) & 0xffff;        \
    (gate).gd_ss = (sel);                                \
    (gate).gd_args = 0;                                    \
    (gate).gd_rsv1 = 0;                                    \
    (gate).gd_type = (istrap) ? STS_TG32 : STS_IG32;    \
    (gate).gd_s = 0;                                    \
    (gate).gd_dpl = (dpl);                                \
    (gate).gd_p = 1;                                    \
    (gate).gd_off_31_16 = (uint32_t)(off) >> 16;        \
}
```

SETGATE宏定义：4字节的IDT，

`off`是中断服务例程偏移量，`sel`段选择子，`istrap`判断中断0系统调用1，`dpl`是访问权限

#### kern/trap/trap.c

```c
void
idt_init(void) {
     /* LAB1 YOUR CODE : STEP 2 */
     /* (1) ----Where are the entry addrs of each Interrupt Service Routine (ISR)?
      *     ----All ISR's entry addrs are stored in __vectors. 
            --where is uintptr_t __vectors[] ?
      *     --__vectors[] is in kern/trap/vector.S which is produced by tools/vector.c
      *     (try "make" command in lab1, then you will find vector.S in kern/trap DIR)
      *     You can use  "extern uintptr_t __vectors[];" to define this extern variable which will be used later.
      * (2) Now you should setup the entries of ISR in Interrupt Description Table (IDT).
      *     Can you see idt[256] in this file?
            Yes, it's IDT! you can use SETGATE macro to setup each item of IDT
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    
    extern uintptr_t __vectors[]; 
    //保存在vectors.S中的256个中断处理例程的入口地址数组
    int i;
    //使用SETGATE宏，初始化IDT每个表项
    for (i = 0; i < 256; i ++) 
    { 
    //在中断门描述符表中建立中断门描述符，其中存储了中断处理例程的代码段GD_KTEXT和偏移量__vectors[i]
    //特权级为DPL_KERNEL, 通过查询idt[i]就可定位到中断服务例程的起始地址。
     SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
    }
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT,__vectors[T_SWITCH_TOK], DPL_USER);
     //指令lidt把中断门描述符表的起始地址装入IDTR寄存器
    lidt(&idt_pd);
}
```



## 6.3 编程完善trap.c中的中断处理函数trap

#### kern/trap/trap.c

按照注释，只要ticks++，到达TICK_NUM打印清零就好

```c
case IRQ_OFFSET + IRQ_TIMER:
        /* LAB1 YOUR CODE : STEP 3 */
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
	    if (((++ticks) % TICK_NUM) == 0) {
		print_ticks();
		ticks = 0;
        }
        break;
```

最后结果：

执行make qemu:

```
    kern/init/init.c:28: kern_init+84
ebp:0x00007bf8 eip:0x00007d68 args:arg :0xc031fcfa 0xc08ed88e 0x64e4d08e 0xfa7502a8

    <unknow>: -- 0x00007d67 --
++ setup timer interrupts
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
```



`basic knowledge`

```
cs 为代码段寄存器，一般用于存放代码；

 通常和IP 使用用于处理下一条执行的代码

cs:IP

基地址：偏移地址

cs地址对应的数据 相当于c语言中的代码语句

cs需要左移4位以达到20位



ds 为数据段寄存器，一般用于存放数据；

ds地址对应的数据 相当于c语言中的全局变量

ss 为栈段寄存器，一般作为栈使用和sp搭档；

ss地址对应的数据 相当于c语言中的局部变量
ss相当于堆栈段的首地址  sp相当于堆栈段的偏移地址

es 为扩展段寄存器；

寄存器前加e:表示从16位拓展到32位的寄存器

```

cs ds ss es 作用：在实模式下就是分段作用

​								在保护模式下成为GDT的段

# 7 Challenge 1

**扩展proj4,增加syscall功能,即增加一用户态函数(可执行一特定系统调用:获得时钟计数值),当内核初始完毕**
**后,可从内核态返回到用户态的函数,而用户态的函数又通过系统调用得到内核态的服务(通过网络查询所需信息,**
**可找老师咨询。如果完成,且有兴趣做代替考试的实验,可找老师商量)。需写出详细的设计和分析报告。完成出色**
**的可获得适当加分。**

`kern/trap/vector.S`

```
vector10:
  pushl $10
  jmp __alltraps
```

`__alltraps`:`kern/trap/trapentry.S`

```
 # push registers to build a trap frame
 # therefore make the stack look like a struct trapframe
```

本质就是将寄存器压栈，然后调用`trap.c`中的`trap()` ->`trap`调用`trap_dispatch(tf);`

所以需要完善的部分：

1 中断描述符对应的代码

```C
#define T_SWITCH_TOU                120    // user/kernel switch
#define T_SWITCH_TOK                121    // user/kernel switch
```

2 软中断函数trap()->trap_dispatch

## 7.1 switch_to_u / k


调用中断需要保证堆栈对齐。中断切换tf的时候是要取&存ss esp的。但是kernel一开始就是运行在内核态下的，因此使用int指令产生软中断的时候，硬件保存在stack上的信息中并不会包含原先的esp和ss寄存器的值。从用户切换回来的时候需要压esp ss 所以留好位置。

```c
static void
lab1_switch_to_user(void) {
    //LAB1 CHALLENGE 1 : TODO
    asm volatile (
    //调用 T_SWITCH_TOU 中断
    "sub $0x8, %%esp;" //下移8
    "int %0;"
    "movl %%ebp, %%esp" //恢复栈指针
    :
    : "i"(T_SWITCH_TOU)
    );
}

static void
lab1_switch_to_kernel(void) {
    //LAB1 CHALLENGE 1 :  TODO
    asm volatile (
    //调用 T_SWITCH_TOU 中断
    "int %0;"
    "movl %%ebp, %%esp" //恢复栈指针
    :
    : "i"(T_SWITCH_TOK)
    );
}
```

## 7.2 `trap_dispatch`:

```c
case T_SWITCH_TOU:
        if (tf->tf_cs!=USER_CS){
            tf->tf_eflags |= FL_IOPL_MASK;//修改I/O特权级  FL_IOPL_MASK实际与FL_IOPL_3效果相同
            tf->tf_ss = USER_DS;
            tf->tf_cs = USER_CS;
            tf->tf_ds = USER_DS;
            tf->tf_es = USER_DS;
            tf->tf_fs = USER_DS;
            tf->tf_gs = USER_DS;
        }
        break;
    case T_SWITCH_TOK:
        tf->tf_cs = KERNEL_CS;
        tf->tf_ds = KERNEL_DS;
        tf->tf_es = KERNEL_DS;
        tf->tf_gs = KERNEL_DS;
        tf->tf_ss = KERNEL_DS;
        tf->tf_fs = KERNEL_DS;
		tf->tf_eflags&=~FL_IOPL_MASK;
        break;
```

# 8 Challenge 2

**用键盘实现用户模式内核模式切换。具体目标是:“键盘输入3时切换到用户模式,键盘输入0时切换到内核模式”。**
**基本思路是借鉴软中断(syscall功能)的代码,并且把trap.c中软中断处理的设置语句拿过来。**

```c
case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
        cprintf("kbd [%03d] %c\n", c, c);
        if(c=='3')
        {
            tf->tf_eflags|=FL_IOPL_MASK;
            tf->tf_ss = USER_DS;
            tf->tf_cs = USER_CS;
            tf->tf_ds = USER_DS;
            tf->tf_es = USER_DS;
            tf->tf_fs = USER_DS;
            tf->tf_gs = USER_DS;
            print_trapframe(tf);
            cprintf("--------kernel to user--------\n");
        }
        else if(c=='0')
        {
            tf->tf_cs = KERNEL_CS;
            tf->tf_ds = KERNEL_DS;
            tf->tf_es = KERNEL_DS;
            tf->tf_gs = KERNEL_DS;
            tf->tf_ss = KERNEL_DS;
            tf->tf_fs = KERNEL_DS;
            tf->tf_eflags&=~FL_IOPL_MASK;
            print_trapframe(tf);
            cprintf("--------user to kernel--------\n");
        }
        break;
```



























