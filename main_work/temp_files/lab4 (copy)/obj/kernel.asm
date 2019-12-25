
bin/kernel:     file format elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 50 12 00       	mov    $0x125000,%eax
    movl %eax, %cr3
c0100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
c0100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
c010000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
c0100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
c0100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
c0100016:	8d 05 1e 00 10 c0    	lea    0xc010001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
c010001c:	ff e0                	jmp    *%eax

c010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
c010001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
c0100020:	a3 00 50 12 c0       	mov    %eax,0xc0125000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 40 12 c0       	mov    $0xc0124000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c010002f:	e8 02 00 00 00       	call   c0100036 <kern_init>

c0100034 <spin>:

# should never get here
spin:
    jmp spin
c0100034:	eb fe                	jmp    c0100034 <spin>

c0100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
c0100036:	55                   	push   %ebp
c0100037:	89 e5                	mov    %esp,%ebp
c0100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c010003c:	ba 64 a1 12 c0       	mov    $0xc012a164,%edx
c0100041:	b8 00 70 12 c0       	mov    $0xc0127000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 70 12 c0 	movl   $0xc0127000,(%esp)
c010005d:	e8 f6 94 00 00       	call   c0109558 <memset>

    cons_init();                // init the console
c0100062:	e8 18 1e 00 00       	call   c0101e7f <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 60 9e 10 c0 	movl   $0xc0109e60,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 7c 9e 10 c0 	movl   $0xc0109e7c,(%esp)
c010007c:	e8 28 02 00 00       	call   c01002a9 <cprintf>

    print_kerninfo();
c0100081:	e8 da 08 00 00       	call   c0100960 <print_kerninfo>

    grade_backtrace();
c0100086:	e8 9d 00 00 00       	call   c0100128 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 0b 72 00 00       	call   c010729b <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 47 1f 00 00       	call   c0101fdc <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 cb 20 00 00       	call   c0102165 <idt_init>

    vmm_init();                 // init virtual memory management
c010009a:	e8 08 36 00 00       	call   c01036a7 <vmm_init>
    proc_init();                // init process table
c010009f:	e8 5f 8e 00 00       	call   c0108f03 <proc_init>
    
    ide_init();                 // init ide devices
c01000a4:	e8 71 0d 00 00       	call   c0100e1a <ide_init>
    swap_init();                // init swap
c01000a9:	e8 3a 4c 00 00       	call   c0104ce8 <swap_init>

    clock_init();               // init clock interrupt
c01000ae:	e8 82 15 00 00       	call   c0101635 <clock_init>
    intr_enable();              // enable irq interrupt
c01000b3:	e8 5f 20 00 00       	call   c0102117 <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();
    
    cpu_idle();                 // run idle process
c01000b8:	e8 05 90 00 00       	call   c01090c2 <cpu_idle>

c01000bd <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000bd:	55                   	push   %ebp
c01000be:	89 e5                	mov    %esp,%ebp
c01000c0:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000c3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000ca:	00 
c01000cb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000d2:	00 
c01000d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000da:	e8 cf 0c 00 00       	call   c0100dae <mon_backtrace>
}
c01000df:	c9                   	leave  
c01000e0:	c3                   	ret    

c01000e1 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000e1:	55                   	push   %ebp
c01000e2:	89 e5                	mov    %esp,%ebp
c01000e4:	53                   	push   %ebx
c01000e5:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000e8:	8d 5d 0c             	lea    0xc(%ebp),%ebx
c01000eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c01000ee:	8d 55 08             	lea    0x8(%ebp),%edx
c01000f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01000f4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01000f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01000fc:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100100:	89 04 24             	mov    %eax,(%esp)
c0100103:	e8 b5 ff ff ff       	call   c01000bd <grade_backtrace2>
}
c0100108:	83 c4 14             	add    $0x14,%esp
c010010b:	5b                   	pop    %ebx
c010010c:	5d                   	pop    %ebp
c010010d:	c3                   	ret    

c010010e <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c010010e:	55                   	push   %ebp
c010010f:	89 e5                	mov    %esp,%ebp
c0100111:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c0100114:	8b 45 10             	mov    0x10(%ebp),%eax
c0100117:	89 44 24 04          	mov    %eax,0x4(%esp)
c010011b:	8b 45 08             	mov    0x8(%ebp),%eax
c010011e:	89 04 24             	mov    %eax,(%esp)
c0100121:	e8 bb ff ff ff       	call   c01000e1 <grade_backtrace1>
}
c0100126:	c9                   	leave  
c0100127:	c3                   	ret    

c0100128 <grade_backtrace>:

void
grade_backtrace(void) {
c0100128:	55                   	push   %ebp
c0100129:	89 e5                	mov    %esp,%ebp
c010012b:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c010012e:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c0100133:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c010013a:	ff 
c010013b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010013f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100146:	e8 c3 ff ff ff       	call   c010010e <grade_backtrace0>
}
c010014b:	c9                   	leave  
c010014c:	c3                   	ret    

c010014d <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c010014d:	55                   	push   %ebp
c010014e:	89 e5                	mov    %esp,%ebp
c0100150:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100153:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c0100156:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100159:	8c 45 f2             	mov    %es,-0xe(%ebp)
c010015c:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c010015f:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100163:	0f b7 c0             	movzwl %ax,%eax
c0100166:	83 e0 03             	and    $0x3,%eax
c0100169:	89 c2                	mov    %eax,%edx
c010016b:	a1 00 70 12 c0       	mov    0xc0127000,%eax
c0100170:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100174:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100178:	c7 04 24 81 9e 10 c0 	movl   $0xc0109e81,(%esp)
c010017f:	e8 25 01 00 00       	call   c01002a9 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c0100184:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100188:	0f b7 d0             	movzwl %ax,%edx
c010018b:	a1 00 70 12 c0       	mov    0xc0127000,%eax
c0100190:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100194:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100198:	c7 04 24 8f 9e 10 c0 	movl   $0xc0109e8f,(%esp)
c010019f:	e8 05 01 00 00       	call   c01002a9 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c01001a4:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c01001a8:	0f b7 d0             	movzwl %ax,%edx
c01001ab:	a1 00 70 12 c0       	mov    0xc0127000,%eax
c01001b0:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001b4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001b8:	c7 04 24 9d 9e 10 c0 	movl   $0xc0109e9d,(%esp)
c01001bf:	e8 e5 00 00 00       	call   c01002a9 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001c4:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001c8:	0f b7 d0             	movzwl %ax,%edx
c01001cb:	a1 00 70 12 c0       	mov    0xc0127000,%eax
c01001d0:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001d4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001d8:	c7 04 24 ab 9e 10 c0 	movl   $0xc0109eab,(%esp)
c01001df:	e8 c5 00 00 00       	call   c01002a9 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001e4:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001e8:	0f b7 d0             	movzwl %ax,%edx
c01001eb:	a1 00 70 12 c0       	mov    0xc0127000,%eax
c01001f0:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001f4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001f8:	c7 04 24 b9 9e 10 c0 	movl   $0xc0109eb9,(%esp)
c01001ff:	e8 a5 00 00 00       	call   c01002a9 <cprintf>
    round ++;
c0100204:	a1 00 70 12 c0       	mov    0xc0127000,%eax
c0100209:	83 c0 01             	add    $0x1,%eax
c010020c:	a3 00 70 12 c0       	mov    %eax,0xc0127000
}
c0100211:	c9                   	leave  
c0100212:	c3                   	ret    

c0100213 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c0100213:	55                   	push   %ebp
c0100214:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c0100216:	5d                   	pop    %ebp
c0100217:	c3                   	ret    

c0100218 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c0100218:	55                   	push   %ebp
c0100219:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c010021b:	5d                   	pop    %ebp
c010021c:	c3                   	ret    

c010021d <lab1_switch_test>:

static void
lab1_switch_test(void) {
c010021d:	55                   	push   %ebp
c010021e:	89 e5                	mov    %esp,%ebp
c0100220:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c0100223:	e8 25 ff ff ff       	call   c010014d <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c0100228:	c7 04 24 c8 9e 10 c0 	movl   $0xc0109ec8,(%esp)
c010022f:	e8 75 00 00 00       	call   c01002a9 <cprintf>
    lab1_switch_to_user();
c0100234:	e8 da ff ff ff       	call   c0100213 <lab1_switch_to_user>
    lab1_print_cur_status();
c0100239:	e8 0f ff ff ff       	call   c010014d <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c010023e:	c7 04 24 e8 9e 10 c0 	movl   $0xc0109ee8,(%esp)
c0100245:	e8 5f 00 00 00       	call   c01002a9 <cprintf>
    lab1_switch_to_kernel();
c010024a:	e8 c9 ff ff ff       	call   c0100218 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c010024f:	e8 f9 fe ff ff       	call   c010014d <lab1_print_cur_status>
}
c0100254:	c9                   	leave  
c0100255:	c3                   	ret    

c0100256 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c0100256:	55                   	push   %ebp
c0100257:	89 e5                	mov    %esp,%ebp
c0100259:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c010025c:	8b 45 08             	mov    0x8(%ebp),%eax
c010025f:	89 04 24             	mov    %eax,(%esp)
c0100262:	e8 44 1c 00 00       	call   c0101eab <cons_putc>
    (*cnt) ++;
c0100267:	8b 45 0c             	mov    0xc(%ebp),%eax
c010026a:	8b 00                	mov    (%eax),%eax
c010026c:	8d 50 01             	lea    0x1(%eax),%edx
c010026f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100272:	89 10                	mov    %edx,(%eax)
}
c0100274:	c9                   	leave  
c0100275:	c3                   	ret    

c0100276 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100276:	55                   	push   %ebp
c0100277:	89 e5                	mov    %esp,%ebp
c0100279:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c010027c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c0100283:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100286:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010028a:	8b 45 08             	mov    0x8(%ebp),%eax
c010028d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100291:	8d 45 f4             	lea    -0xc(%ebp),%eax
c0100294:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100298:	c7 04 24 56 02 10 c0 	movl   $0xc0100256,(%esp)
c010029f:	e8 06 96 00 00       	call   c01098aa <vprintfmt>
    return cnt;
c01002a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002a7:	c9                   	leave  
c01002a8:	c3                   	ret    

c01002a9 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c01002a9:	55                   	push   %ebp
c01002aa:	89 e5                	mov    %esp,%ebp
c01002ac:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c01002af:	8d 45 0c             	lea    0xc(%ebp),%eax
c01002b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c01002b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002b8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01002bc:	8b 45 08             	mov    0x8(%ebp),%eax
c01002bf:	89 04 24             	mov    %eax,(%esp)
c01002c2:	e8 af ff ff ff       	call   c0100276 <vcprintf>
c01002c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c01002ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002cd:	c9                   	leave  
c01002ce:	c3                   	ret    

c01002cf <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c01002cf:	55                   	push   %ebp
c01002d0:	89 e5                	mov    %esp,%ebp
c01002d2:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c01002d5:	8b 45 08             	mov    0x8(%ebp),%eax
c01002d8:	89 04 24             	mov    %eax,(%esp)
c01002db:	e8 cb 1b 00 00       	call   c0101eab <cons_putc>
}
c01002e0:	c9                   	leave  
c01002e1:	c3                   	ret    

c01002e2 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c01002e2:	55                   	push   %ebp
c01002e3:	89 e5                	mov    %esp,%ebp
c01002e5:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c01002e8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01002ef:	eb 13                	jmp    c0100304 <cputs+0x22>
        cputch(c, &cnt);
c01002f1:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01002f5:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01002f8:	89 54 24 04          	mov    %edx,0x4(%esp)
c01002fc:	89 04 24             	mov    %eax,(%esp)
c01002ff:	e8 52 ff ff ff       	call   c0100256 <cputch>
    while ((c = *str ++) != '\0') {
c0100304:	8b 45 08             	mov    0x8(%ebp),%eax
c0100307:	8d 50 01             	lea    0x1(%eax),%edx
c010030a:	89 55 08             	mov    %edx,0x8(%ebp)
c010030d:	0f b6 00             	movzbl (%eax),%eax
c0100310:	88 45 f7             	mov    %al,-0x9(%ebp)
c0100313:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c0100317:	75 d8                	jne    c01002f1 <cputs+0xf>
    }
    cputch('\n', &cnt);
c0100319:	8d 45 f0             	lea    -0x10(%ebp),%eax
c010031c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100320:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c0100327:	e8 2a ff ff ff       	call   c0100256 <cputch>
    return cnt;
c010032c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c010032f:	c9                   	leave  
c0100330:	c3                   	ret    

c0100331 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c0100331:	55                   	push   %ebp
c0100332:	89 e5                	mov    %esp,%ebp
c0100334:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c0100337:	e8 ab 1b 00 00       	call   c0101ee7 <cons_getc>
c010033c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010033f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100343:	74 f2                	je     c0100337 <getchar+0x6>
        /* do nothing */;
    return c;
c0100345:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100348:	c9                   	leave  
c0100349:	c3                   	ret    

c010034a <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c010034a:	55                   	push   %ebp
c010034b:	89 e5                	mov    %esp,%ebp
c010034d:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c0100350:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100354:	74 13                	je     c0100369 <readline+0x1f>
        cprintf("%s", prompt);
c0100356:	8b 45 08             	mov    0x8(%ebp),%eax
c0100359:	89 44 24 04          	mov    %eax,0x4(%esp)
c010035d:	c7 04 24 07 9f 10 c0 	movl   $0xc0109f07,(%esp)
c0100364:	e8 40 ff ff ff       	call   c01002a9 <cprintf>
    }
    int i = 0, c;
c0100369:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c0100370:	e8 bc ff ff ff       	call   c0100331 <getchar>
c0100375:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c0100378:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010037c:	79 07                	jns    c0100385 <readline+0x3b>
            return NULL;
c010037e:	b8 00 00 00 00       	mov    $0x0,%eax
c0100383:	eb 79                	jmp    c01003fe <readline+0xb4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c0100385:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c0100389:	7e 28                	jle    c01003b3 <readline+0x69>
c010038b:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c0100392:	7f 1f                	jg     c01003b3 <readline+0x69>
            cputchar(c);
c0100394:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100397:	89 04 24             	mov    %eax,(%esp)
c010039a:	e8 30 ff ff ff       	call   c01002cf <cputchar>
            buf[i ++] = c;
c010039f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01003a2:	8d 50 01             	lea    0x1(%eax),%edx
c01003a5:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01003a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01003ab:	88 90 20 70 12 c0    	mov    %dl,-0x3fed8fe0(%eax)
c01003b1:	eb 46                	jmp    c01003f9 <readline+0xaf>
        }
        else if (c == '\b' && i > 0) {
c01003b3:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01003b7:	75 17                	jne    c01003d0 <readline+0x86>
c01003b9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003bd:	7e 11                	jle    c01003d0 <readline+0x86>
            cputchar(c);
c01003bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003c2:	89 04 24             	mov    %eax,(%esp)
c01003c5:	e8 05 ff ff ff       	call   c01002cf <cputchar>
            i --;
c01003ca:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01003ce:	eb 29                	jmp    c01003f9 <readline+0xaf>
        }
        else if (c == '\n' || c == '\r') {
c01003d0:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01003d4:	74 06                	je     c01003dc <readline+0x92>
c01003d6:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01003da:	75 1d                	jne    c01003f9 <readline+0xaf>
            cputchar(c);
c01003dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003df:	89 04 24             	mov    %eax,(%esp)
c01003e2:	e8 e8 fe ff ff       	call   c01002cf <cputchar>
            buf[i] = '\0';
c01003e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01003ea:	05 20 70 12 c0       	add    $0xc0127020,%eax
c01003ef:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01003f2:	b8 20 70 12 c0       	mov    $0xc0127020,%eax
c01003f7:	eb 05                	jmp    c01003fe <readline+0xb4>
        }
    }
c01003f9:	e9 72 ff ff ff       	jmp    c0100370 <readline+0x26>
}
c01003fe:	c9                   	leave  
c01003ff:	c3                   	ret    

c0100400 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100400:	55                   	push   %ebp
c0100401:	89 e5                	mov    %esp,%ebp
c0100403:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0100406:	a1 20 74 12 c0       	mov    0xc0127420,%eax
c010040b:	85 c0                	test   %eax,%eax
c010040d:	74 02                	je     c0100411 <__panic+0x11>
        goto panic_dead;
c010040f:	eb 59                	jmp    c010046a <__panic+0x6a>
    }
    is_panic = 1;
c0100411:	c7 05 20 74 12 c0 01 	movl   $0x1,0xc0127420
c0100418:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c010041b:	8d 45 14             	lea    0x14(%ebp),%eax
c010041e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100421:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100424:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100428:	8b 45 08             	mov    0x8(%ebp),%eax
c010042b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010042f:	c7 04 24 0a 9f 10 c0 	movl   $0xc0109f0a,(%esp)
c0100436:	e8 6e fe ff ff       	call   c01002a9 <cprintf>
    vcprintf(fmt, ap);
c010043b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010043e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100442:	8b 45 10             	mov    0x10(%ebp),%eax
c0100445:	89 04 24             	mov    %eax,(%esp)
c0100448:	e8 29 fe ff ff       	call   c0100276 <vcprintf>
    cprintf("\n");
c010044d:	c7 04 24 26 9f 10 c0 	movl   $0xc0109f26,(%esp)
c0100454:	e8 50 fe ff ff       	call   c01002a9 <cprintf>
    
    cprintf("stack trackback:\n");
c0100459:	c7 04 24 28 9f 10 c0 	movl   $0xc0109f28,(%esp)
c0100460:	e8 44 fe ff ff       	call   c01002a9 <cprintf>
    print_stackframe();
c0100465:	e8 40 06 00 00       	call   c0100aaa <print_stackframe>
    
    va_end(ap);

panic_dead:
    intr_disable();
c010046a:	e8 ae 1c 00 00       	call   c010211d <intr_disable>
    while (1) {
        kmonitor(NULL);
c010046f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100476:	e8 64 08 00 00       	call   c0100cdf <kmonitor>
    }
c010047b:	eb f2                	jmp    c010046f <__panic+0x6f>

c010047d <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c010047d:	55                   	push   %ebp
c010047e:	89 e5                	mov    %esp,%ebp
c0100480:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100483:	8d 45 14             	lea    0x14(%ebp),%eax
c0100486:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100489:	8b 45 0c             	mov    0xc(%ebp),%eax
c010048c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100490:	8b 45 08             	mov    0x8(%ebp),%eax
c0100493:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100497:	c7 04 24 3a 9f 10 c0 	movl   $0xc0109f3a,(%esp)
c010049e:	e8 06 fe ff ff       	call   c01002a9 <cprintf>
    vcprintf(fmt, ap);
c01004a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01004a6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01004aa:	8b 45 10             	mov    0x10(%ebp),%eax
c01004ad:	89 04 24             	mov    %eax,(%esp)
c01004b0:	e8 c1 fd ff ff       	call   c0100276 <vcprintf>
    cprintf("\n");
c01004b5:	c7 04 24 26 9f 10 c0 	movl   $0xc0109f26,(%esp)
c01004bc:	e8 e8 fd ff ff       	call   c01002a9 <cprintf>
    va_end(ap);
}
c01004c1:	c9                   	leave  
c01004c2:	c3                   	ret    

c01004c3 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c01004c3:	55                   	push   %ebp
c01004c4:	89 e5                	mov    %esp,%ebp
    return is_panic;
c01004c6:	a1 20 74 12 c0       	mov    0xc0127420,%eax
}
c01004cb:	5d                   	pop    %ebp
c01004cc:	c3                   	ret    

c01004cd <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c01004cd:	55                   	push   %ebp
c01004ce:	89 e5                	mov    %esp,%ebp
c01004d0:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c01004d3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004d6:	8b 00                	mov    (%eax),%eax
c01004d8:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004db:	8b 45 10             	mov    0x10(%ebp),%eax
c01004de:	8b 00                	mov    (%eax),%eax
c01004e0:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c01004ea:	e9 d2 00 00 00       	jmp    c01005c1 <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
c01004ef:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01004f2:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01004f5:	01 d0                	add    %edx,%eax
c01004f7:	89 c2                	mov    %eax,%edx
c01004f9:	c1 ea 1f             	shr    $0x1f,%edx
c01004fc:	01 d0                	add    %edx,%eax
c01004fe:	d1 f8                	sar    %eax
c0100500:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0100503:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100506:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100509:	eb 04                	jmp    c010050f <stab_binsearch+0x42>
            m --;
c010050b:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
c010050f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100512:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100515:	7c 1f                	jl     c0100536 <stab_binsearch+0x69>
c0100517:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010051a:	89 d0                	mov    %edx,%eax
c010051c:	01 c0                	add    %eax,%eax
c010051e:	01 d0                	add    %edx,%eax
c0100520:	c1 e0 02             	shl    $0x2,%eax
c0100523:	89 c2                	mov    %eax,%edx
c0100525:	8b 45 08             	mov    0x8(%ebp),%eax
c0100528:	01 d0                	add    %edx,%eax
c010052a:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010052e:	0f b6 c0             	movzbl %al,%eax
c0100531:	3b 45 14             	cmp    0x14(%ebp),%eax
c0100534:	75 d5                	jne    c010050b <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
c0100536:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100539:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010053c:	7d 0b                	jge    c0100549 <stab_binsearch+0x7c>
            l = true_m + 1;
c010053e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100541:	83 c0 01             	add    $0x1,%eax
c0100544:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c0100547:	eb 78                	jmp    c01005c1 <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
c0100549:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0100550:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100553:	89 d0                	mov    %edx,%eax
c0100555:	01 c0                	add    %eax,%eax
c0100557:	01 d0                	add    %edx,%eax
c0100559:	c1 e0 02             	shl    $0x2,%eax
c010055c:	89 c2                	mov    %eax,%edx
c010055e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100561:	01 d0                	add    %edx,%eax
c0100563:	8b 40 08             	mov    0x8(%eax),%eax
c0100566:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100569:	73 13                	jae    c010057e <stab_binsearch+0xb1>
            *region_left = m;
c010056b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010056e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100571:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c0100573:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100576:	83 c0 01             	add    $0x1,%eax
c0100579:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010057c:	eb 43                	jmp    c01005c1 <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
c010057e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100581:	89 d0                	mov    %edx,%eax
c0100583:	01 c0                	add    %eax,%eax
c0100585:	01 d0                	add    %edx,%eax
c0100587:	c1 e0 02             	shl    $0x2,%eax
c010058a:	89 c2                	mov    %eax,%edx
c010058c:	8b 45 08             	mov    0x8(%ebp),%eax
c010058f:	01 d0                	add    %edx,%eax
c0100591:	8b 40 08             	mov    0x8(%eax),%eax
c0100594:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100597:	76 16                	jbe    c01005af <stab_binsearch+0xe2>
            *region_right = m - 1;
c0100599:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010059c:	8d 50 ff             	lea    -0x1(%eax),%edx
c010059f:	8b 45 10             	mov    0x10(%ebp),%eax
c01005a2:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01005a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005a7:	83 e8 01             	sub    $0x1,%eax
c01005aa:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01005ad:	eb 12                	jmp    c01005c1 <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01005af:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005b2:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005b5:	89 10                	mov    %edx,(%eax)
            l = m;
c01005b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005ba:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01005bd:	83 45 18 01          	addl   $0x1,0x18(%ebp)
    while (l <= r) {
c01005c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01005c4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01005c7:	0f 8e 22 ff ff ff    	jle    c01004ef <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
c01005cd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01005d1:	75 0f                	jne    c01005e2 <stab_binsearch+0x115>
        *region_right = *region_left - 1;
c01005d3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005d6:	8b 00                	mov    (%eax),%eax
c01005d8:	8d 50 ff             	lea    -0x1(%eax),%edx
c01005db:	8b 45 10             	mov    0x10(%ebp),%eax
c01005de:	89 10                	mov    %edx,(%eax)
c01005e0:	eb 3f                	jmp    c0100621 <stab_binsearch+0x154>
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
c01005e2:	8b 45 10             	mov    0x10(%ebp),%eax
c01005e5:	8b 00                	mov    (%eax),%eax
c01005e7:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c01005ea:	eb 04                	jmp    c01005f0 <stab_binsearch+0x123>
c01005ec:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
c01005f0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005f3:	8b 00                	mov    (%eax),%eax
c01005f5:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01005f8:	7d 1f                	jge    c0100619 <stab_binsearch+0x14c>
c01005fa:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01005fd:	89 d0                	mov    %edx,%eax
c01005ff:	01 c0                	add    %eax,%eax
c0100601:	01 d0                	add    %edx,%eax
c0100603:	c1 e0 02             	shl    $0x2,%eax
c0100606:	89 c2                	mov    %eax,%edx
c0100608:	8b 45 08             	mov    0x8(%ebp),%eax
c010060b:	01 d0                	add    %edx,%eax
c010060d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100611:	0f b6 c0             	movzbl %al,%eax
c0100614:	3b 45 14             	cmp    0x14(%ebp),%eax
c0100617:	75 d3                	jne    c01005ec <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
c0100619:	8b 45 0c             	mov    0xc(%ebp),%eax
c010061c:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010061f:	89 10                	mov    %edx,(%eax)
    }
}
c0100621:	c9                   	leave  
c0100622:	c3                   	ret    

c0100623 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c0100623:	55                   	push   %ebp
c0100624:	89 e5                	mov    %esp,%ebp
c0100626:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0100629:	8b 45 0c             	mov    0xc(%ebp),%eax
c010062c:	c7 00 58 9f 10 c0    	movl   $0xc0109f58,(%eax)
    info->eip_line = 0;
c0100632:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100635:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c010063c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010063f:	c7 40 08 58 9f 10 c0 	movl   $0xc0109f58,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100646:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100649:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c0100650:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100653:	8b 55 08             	mov    0x8(%ebp),%edx
c0100656:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0100659:	8b 45 0c             	mov    0xc(%ebp),%eax
c010065c:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c0100663:	c7 45 f4 84 c1 10 c0 	movl   $0xc010c184,-0xc(%ebp)
    stab_end = __STAB_END__;
c010066a:	c7 45 f0 40 d4 11 c0 	movl   $0xc011d440,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c0100671:	c7 45 ec 41 d4 11 c0 	movl   $0xc011d441,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c0100678:	c7 45 e8 08 1c 12 c0 	movl   $0xc0121c08,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c010067f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100682:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0100685:	76 0d                	jbe    c0100694 <debuginfo_eip+0x71>
c0100687:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010068a:	83 e8 01             	sub    $0x1,%eax
c010068d:	0f b6 00             	movzbl (%eax),%eax
c0100690:	84 c0                	test   %al,%al
c0100692:	74 0a                	je     c010069e <debuginfo_eip+0x7b>
        return -1;
c0100694:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100699:	e9 c0 02 00 00       	jmp    c010095e <debuginfo_eip+0x33b>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c010069e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c01006a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01006a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006ab:	29 c2                	sub    %eax,%edx
c01006ad:	89 d0                	mov    %edx,%eax
c01006af:	c1 f8 02             	sar    $0x2,%eax
c01006b2:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01006b8:	83 e8 01             	sub    $0x1,%eax
c01006bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01006be:	8b 45 08             	mov    0x8(%ebp),%eax
c01006c1:	89 44 24 10          	mov    %eax,0x10(%esp)
c01006c5:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01006cc:	00 
c01006cd:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01006d0:	89 44 24 08          	mov    %eax,0x8(%esp)
c01006d4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c01006d7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01006db:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006de:	89 04 24             	mov    %eax,(%esp)
c01006e1:	e8 e7 fd ff ff       	call   c01004cd <stab_binsearch>
    if (lfile == 0)
c01006e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006e9:	85 c0                	test   %eax,%eax
c01006eb:	75 0a                	jne    c01006f7 <debuginfo_eip+0xd4>
        return -1;
c01006ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006f2:	e9 67 02 00 00       	jmp    c010095e <debuginfo_eip+0x33b>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c01006f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006fa:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01006fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100700:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c0100703:	8b 45 08             	mov    0x8(%ebp),%eax
c0100706:	89 44 24 10          	mov    %eax,0x10(%esp)
c010070a:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c0100711:	00 
c0100712:	8d 45 d8             	lea    -0x28(%ebp),%eax
c0100715:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100719:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010071c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100720:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100723:	89 04 24             	mov    %eax,(%esp)
c0100726:	e8 a2 fd ff ff       	call   c01004cd <stab_binsearch>

    if (lfun <= rfun) {
c010072b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010072e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100731:	39 c2                	cmp    %eax,%edx
c0100733:	7f 7c                	jg     c01007b1 <debuginfo_eip+0x18e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0100735:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100738:	89 c2                	mov    %eax,%edx
c010073a:	89 d0                	mov    %edx,%eax
c010073c:	01 c0                	add    %eax,%eax
c010073e:	01 d0                	add    %edx,%eax
c0100740:	c1 e0 02             	shl    $0x2,%eax
c0100743:	89 c2                	mov    %eax,%edx
c0100745:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100748:	01 d0                	add    %edx,%eax
c010074a:	8b 10                	mov    (%eax),%edx
c010074c:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010074f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100752:	29 c1                	sub    %eax,%ecx
c0100754:	89 c8                	mov    %ecx,%eax
c0100756:	39 c2                	cmp    %eax,%edx
c0100758:	73 22                	jae    c010077c <debuginfo_eip+0x159>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c010075a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010075d:	89 c2                	mov    %eax,%edx
c010075f:	89 d0                	mov    %edx,%eax
c0100761:	01 c0                	add    %eax,%eax
c0100763:	01 d0                	add    %edx,%eax
c0100765:	c1 e0 02             	shl    $0x2,%eax
c0100768:	89 c2                	mov    %eax,%edx
c010076a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010076d:	01 d0                	add    %edx,%eax
c010076f:	8b 10                	mov    (%eax),%edx
c0100771:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100774:	01 c2                	add    %eax,%edx
c0100776:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100779:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c010077c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010077f:	89 c2                	mov    %eax,%edx
c0100781:	89 d0                	mov    %edx,%eax
c0100783:	01 c0                	add    %eax,%eax
c0100785:	01 d0                	add    %edx,%eax
c0100787:	c1 e0 02             	shl    $0x2,%eax
c010078a:	89 c2                	mov    %eax,%edx
c010078c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010078f:	01 d0                	add    %edx,%eax
c0100791:	8b 50 08             	mov    0x8(%eax),%edx
c0100794:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100797:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c010079a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010079d:	8b 40 10             	mov    0x10(%eax),%eax
c01007a0:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c01007a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01007a6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c01007a9:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01007ac:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01007af:	eb 15                	jmp    c01007c6 <debuginfo_eip+0x1a3>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01007b1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007b4:	8b 55 08             	mov    0x8(%ebp),%edx
c01007b7:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01007ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01007bd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c01007c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01007c3:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01007c6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007c9:	8b 40 08             	mov    0x8(%eax),%eax
c01007cc:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01007d3:	00 
c01007d4:	89 04 24             	mov    %eax,(%esp)
c01007d7:	e8 f0 8b 00 00       	call   c01093cc <strfind>
c01007dc:	89 c2                	mov    %eax,%edx
c01007de:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007e1:	8b 40 08             	mov    0x8(%eax),%eax
c01007e4:	29 c2                	sub    %eax,%edx
c01007e6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007e9:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c01007ec:	8b 45 08             	mov    0x8(%ebp),%eax
c01007ef:	89 44 24 10          	mov    %eax,0x10(%esp)
c01007f3:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c01007fa:	00 
c01007fb:	8d 45 d0             	lea    -0x30(%ebp),%eax
c01007fe:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100802:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c0100805:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100809:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010080c:	89 04 24             	mov    %eax,(%esp)
c010080f:	e8 b9 fc ff ff       	call   c01004cd <stab_binsearch>
    if (lline <= rline) {
c0100814:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100817:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010081a:	39 c2                	cmp    %eax,%edx
c010081c:	7f 24                	jg     c0100842 <debuginfo_eip+0x21f>
        info->eip_line = stabs[rline].n_desc;
c010081e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100821:	89 c2                	mov    %eax,%edx
c0100823:	89 d0                	mov    %edx,%eax
c0100825:	01 c0                	add    %eax,%eax
c0100827:	01 d0                	add    %edx,%eax
c0100829:	c1 e0 02             	shl    $0x2,%eax
c010082c:	89 c2                	mov    %eax,%edx
c010082e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100831:	01 d0                	add    %edx,%eax
c0100833:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100837:	0f b7 d0             	movzwl %ax,%edx
c010083a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010083d:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100840:	eb 13                	jmp    c0100855 <debuginfo_eip+0x232>
        return -1;
c0100842:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100847:	e9 12 01 00 00       	jmp    c010095e <debuginfo_eip+0x33b>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c010084c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010084f:	83 e8 01             	sub    $0x1,%eax
c0100852:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
c0100855:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100858:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010085b:	39 c2                	cmp    %eax,%edx
c010085d:	7c 56                	jl     c01008b5 <debuginfo_eip+0x292>
           && stabs[lline].n_type != N_SOL
c010085f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100862:	89 c2                	mov    %eax,%edx
c0100864:	89 d0                	mov    %edx,%eax
c0100866:	01 c0                	add    %eax,%eax
c0100868:	01 d0                	add    %edx,%eax
c010086a:	c1 e0 02             	shl    $0x2,%eax
c010086d:	89 c2                	mov    %eax,%edx
c010086f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100872:	01 d0                	add    %edx,%eax
c0100874:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100878:	3c 84                	cmp    $0x84,%al
c010087a:	74 39                	je     c01008b5 <debuginfo_eip+0x292>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c010087c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010087f:	89 c2                	mov    %eax,%edx
c0100881:	89 d0                	mov    %edx,%eax
c0100883:	01 c0                	add    %eax,%eax
c0100885:	01 d0                	add    %edx,%eax
c0100887:	c1 e0 02             	shl    $0x2,%eax
c010088a:	89 c2                	mov    %eax,%edx
c010088c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010088f:	01 d0                	add    %edx,%eax
c0100891:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100895:	3c 64                	cmp    $0x64,%al
c0100897:	75 b3                	jne    c010084c <debuginfo_eip+0x229>
c0100899:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010089c:	89 c2                	mov    %eax,%edx
c010089e:	89 d0                	mov    %edx,%eax
c01008a0:	01 c0                	add    %eax,%eax
c01008a2:	01 d0                	add    %edx,%eax
c01008a4:	c1 e0 02             	shl    $0x2,%eax
c01008a7:	89 c2                	mov    %eax,%edx
c01008a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008ac:	01 d0                	add    %edx,%eax
c01008ae:	8b 40 08             	mov    0x8(%eax),%eax
c01008b1:	85 c0                	test   %eax,%eax
c01008b3:	74 97                	je     c010084c <debuginfo_eip+0x229>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01008b5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01008b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01008bb:	39 c2                	cmp    %eax,%edx
c01008bd:	7c 46                	jl     c0100905 <debuginfo_eip+0x2e2>
c01008bf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008c2:	89 c2                	mov    %eax,%edx
c01008c4:	89 d0                	mov    %edx,%eax
c01008c6:	01 c0                	add    %eax,%eax
c01008c8:	01 d0                	add    %edx,%eax
c01008ca:	c1 e0 02             	shl    $0x2,%eax
c01008cd:	89 c2                	mov    %eax,%edx
c01008cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008d2:	01 d0                	add    %edx,%eax
c01008d4:	8b 10                	mov    (%eax),%edx
c01008d6:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c01008d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01008dc:	29 c1                	sub    %eax,%ecx
c01008de:	89 c8                	mov    %ecx,%eax
c01008e0:	39 c2                	cmp    %eax,%edx
c01008e2:	73 21                	jae    c0100905 <debuginfo_eip+0x2e2>
        info->eip_file = stabstr + stabs[lline].n_strx;
c01008e4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008e7:	89 c2                	mov    %eax,%edx
c01008e9:	89 d0                	mov    %edx,%eax
c01008eb:	01 c0                	add    %eax,%eax
c01008ed:	01 d0                	add    %edx,%eax
c01008ef:	c1 e0 02             	shl    $0x2,%eax
c01008f2:	89 c2                	mov    %eax,%edx
c01008f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008f7:	01 d0                	add    %edx,%eax
c01008f9:	8b 10                	mov    (%eax),%edx
c01008fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01008fe:	01 c2                	add    %eax,%edx
c0100900:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100903:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c0100905:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100908:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010090b:	39 c2                	cmp    %eax,%edx
c010090d:	7d 4a                	jge    c0100959 <debuginfo_eip+0x336>
        for (lline = lfun + 1;
c010090f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100912:	83 c0 01             	add    $0x1,%eax
c0100915:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100918:	eb 18                	jmp    c0100932 <debuginfo_eip+0x30f>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c010091a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010091d:	8b 40 14             	mov    0x14(%eax),%eax
c0100920:	8d 50 01             	lea    0x1(%eax),%edx
c0100923:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100926:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
c0100929:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010092c:	83 c0 01             	add    $0x1,%eax
c010092f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100932:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100935:	8b 45 d8             	mov    -0x28(%ebp),%eax
        for (lline = lfun + 1;
c0100938:	39 c2                	cmp    %eax,%edx
c010093a:	7d 1d                	jge    c0100959 <debuginfo_eip+0x336>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c010093c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010093f:	89 c2                	mov    %eax,%edx
c0100941:	89 d0                	mov    %edx,%eax
c0100943:	01 c0                	add    %eax,%eax
c0100945:	01 d0                	add    %edx,%eax
c0100947:	c1 e0 02             	shl    $0x2,%eax
c010094a:	89 c2                	mov    %eax,%edx
c010094c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010094f:	01 d0                	add    %edx,%eax
c0100951:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100955:	3c a0                	cmp    $0xa0,%al
c0100957:	74 c1                	je     c010091a <debuginfo_eip+0x2f7>
        }
    }
    return 0;
c0100959:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010095e:	c9                   	leave  
c010095f:	c3                   	ret    

c0100960 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0100960:	55                   	push   %ebp
c0100961:	89 e5                	mov    %esp,%ebp
c0100963:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0100966:	c7 04 24 62 9f 10 c0 	movl   $0xc0109f62,(%esp)
c010096d:	e8 37 f9 ff ff       	call   c01002a9 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c0100972:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c0100979:	c0 
c010097a:	c7 04 24 7b 9f 10 c0 	movl   $0xc0109f7b,(%esp)
c0100981:	e8 23 f9 ff ff       	call   c01002a9 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c0100986:	c7 44 24 04 5f 9e 10 	movl   $0xc0109e5f,0x4(%esp)
c010098d:	c0 
c010098e:	c7 04 24 93 9f 10 c0 	movl   $0xc0109f93,(%esp)
c0100995:	e8 0f f9 ff ff       	call   c01002a9 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c010099a:	c7 44 24 04 00 70 12 	movl   $0xc0127000,0x4(%esp)
c01009a1:	c0 
c01009a2:	c7 04 24 ab 9f 10 c0 	movl   $0xc0109fab,(%esp)
c01009a9:	e8 fb f8 ff ff       	call   c01002a9 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c01009ae:	c7 44 24 04 64 a1 12 	movl   $0xc012a164,0x4(%esp)
c01009b5:	c0 
c01009b6:	c7 04 24 c3 9f 10 c0 	movl   $0xc0109fc3,(%esp)
c01009bd:	e8 e7 f8 ff ff       	call   c01002a9 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01009c2:	b8 64 a1 12 c0       	mov    $0xc012a164,%eax
c01009c7:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009cd:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c01009d2:	29 c2                	sub    %eax,%edx
c01009d4:	89 d0                	mov    %edx,%eax
c01009d6:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009dc:	85 c0                	test   %eax,%eax
c01009de:	0f 48 c2             	cmovs  %edx,%eax
c01009e1:	c1 f8 0a             	sar    $0xa,%eax
c01009e4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009e8:	c7 04 24 dc 9f 10 c0 	movl   $0xc0109fdc,(%esp)
c01009ef:	e8 b5 f8 ff ff       	call   c01002a9 <cprintf>
}
c01009f4:	c9                   	leave  
c01009f5:	c3                   	ret    

c01009f6 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c01009f6:	55                   	push   %ebp
c01009f7:	89 e5                	mov    %esp,%ebp
c01009f9:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c01009ff:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100a02:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a06:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a09:	89 04 24             	mov    %eax,(%esp)
c0100a0c:	e8 12 fc ff ff       	call   c0100623 <debuginfo_eip>
c0100a11:	85 c0                	test   %eax,%eax
c0100a13:	74 15                	je     c0100a2a <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c0100a15:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a18:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a1c:	c7 04 24 06 a0 10 c0 	movl   $0xc010a006,(%esp)
c0100a23:	e8 81 f8 ff ff       	call   c01002a9 <cprintf>
c0100a28:	eb 6d                	jmp    c0100a97 <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a2a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100a31:	eb 1c                	jmp    c0100a4f <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
c0100a33:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a39:	01 d0                	add    %edx,%eax
c0100a3b:	0f b6 00             	movzbl (%eax),%eax
c0100a3e:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a44:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100a47:	01 ca                	add    %ecx,%edx
c0100a49:	88 02                	mov    %al,(%edx)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a4b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100a4f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a52:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100a55:	7f dc                	jg     c0100a33 <print_debuginfo+0x3d>
        }
        fnname[j] = '\0';
c0100a57:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a60:	01 d0                	add    %edx,%eax
c0100a62:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c0100a65:	8b 45 ec             	mov    -0x14(%ebp),%eax
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100a68:	8b 55 08             	mov    0x8(%ebp),%edx
c0100a6b:	89 d1                	mov    %edx,%ecx
c0100a6d:	29 c1                	sub    %eax,%ecx
c0100a6f:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100a72:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100a75:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100a79:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a7f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100a83:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100a87:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a8b:	c7 04 24 22 a0 10 c0 	movl   $0xc010a022,(%esp)
c0100a92:	e8 12 f8 ff ff       	call   c01002a9 <cprintf>
    }
}
c0100a97:	c9                   	leave  
c0100a98:	c3                   	ret    

c0100a99 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0100a99:	55                   	push   %ebp
c0100a9a:	89 e5                	mov    %esp,%ebp
c0100a9c:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0100a9f:	8b 45 04             	mov    0x4(%ebp),%eax
c0100aa2:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0100aa5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100aa8:	c9                   	leave  
c0100aa9:	c3                   	ret    

c0100aaa <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0100aaa:	55                   	push   %ebp
c0100aab:	89 e5                	mov    %esp,%ebp
c0100aad:	53                   	push   %ebx
c0100aae:	83 ec 44             	sub    $0x44,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0100ab1:	89 e8                	mov    %ebp,%eax
c0100ab3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return ebp;
c0100ab6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp=read_ebp(),eip=read_eip();
c0100ab9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100abc:	e8 d8 ff ff ff       	call   c0100a99 <read_eip>
c0100ac1:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int i;//这里在for循环里定义好像不行的样子就拿出来了
	for(i=0;ebp!=0&&i<STACKFRAME_DEPTH;i++)
c0100ac4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100acb:	e9 8d 00 00 00       	jmp    c0100b5d <print_stackframe+0xb3>
    {   
		cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c0100ad0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100ad3:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ada:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ade:	c7 04 24 34 a0 10 c0 	movl   $0xc010a034,(%esp)
c0100ae5:	e8 bf f7 ff ff       	call   c01002a9 <cprintf>
		uint32_t *args = (uint32_t *)ebp + 2;       //ebp+8指向参数，+4指向返回值
c0100aea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100aed:	83 c0 08             	add    $0x8,%eax
c0100af0:	89 45 e8             	mov    %eax,-0x18(%ebp)
		cprintf("arg :0x%08x 0x%08x 0x%08x 0x%08x\n",*(args+0),*(args+1),*(args+2),*(args+3));
c0100af3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100af6:	83 c0 0c             	add    $0xc,%eax
c0100af9:	8b 18                	mov    (%eax),%ebx
c0100afb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100afe:	83 c0 08             	add    $0x8,%eax
c0100b01:	8b 08                	mov    (%eax),%ecx
c0100b03:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100b06:	83 c0 04             	add    $0x4,%eax
c0100b09:	8b 10                	mov    (%eax),%edx
c0100b0b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100b0e:	8b 00                	mov    (%eax),%eax
c0100b10:	89 5c 24 10          	mov    %ebx,0x10(%esp)
c0100b14:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100b18:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100b1c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b20:	c7 04 24 50 a0 10 c0 	movl   $0xc010a050,(%esp)
c0100b27:	e8 7d f7 ff ff       	call   c01002a9 <cprintf>
        //依次打印调用函数的参数1 2 3 4
		cprintf("\n");
c0100b2c:	c7 04 24 72 a0 10 c0 	movl   $0xc010a072,(%esp)
c0100b33:	e8 71 f7 ff ff       	call   c01002a9 <cprintf>
		print_debuginfo(eip - 1);//eip指向的是下一条指令，所以这里减1  指针占4
c0100b38:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b3b:	83 e8 01             	sub    $0x1,%eax
c0100b3e:	89 04 24             	mov    %eax,(%esp)
c0100b41:	e8 b0 fe ff ff       	call   c01009f6 <print_debuginfo>
		eip = ((uint32_t *)ebp)[1]; //此时eip指向返回地址
c0100b46:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b49:	83 c0 04             	add    $0x4,%eax
c0100b4c:	8b 00                	mov    (%eax),%eax
c0100b4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
		ebp = ((uint32_t *)ebp)[0];//ebp存的是调用者edp，所以这里就复原了调用前edp值
c0100b51:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b54:	8b 00                	mov    (%eax),%eax
c0100b56:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for(i=0;ebp!=0&&i<STACKFRAME_DEPTH;i++)
c0100b59:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0100b5d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100b61:	74 0a                	je     c0100b6d <print_stackframe+0xc3>
c0100b63:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100b67:	0f 8e 63 ff ff ff    	jle    c0100ad0 <print_stackframe+0x26>
	}
}
c0100b6d:	83 c4 44             	add    $0x44,%esp
c0100b70:	5b                   	pop    %ebx
c0100b71:	5d                   	pop    %ebp
c0100b72:	c3                   	ret    

c0100b73 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100b73:	55                   	push   %ebp
c0100b74:	89 e5                	mov    %esp,%ebp
c0100b76:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100b79:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b80:	eb 0c                	jmp    c0100b8e <parse+0x1b>
            *buf ++ = '\0';
c0100b82:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b85:	8d 50 01             	lea    0x1(%eax),%edx
c0100b88:	89 55 08             	mov    %edx,0x8(%ebp)
c0100b8b:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b8e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b91:	0f b6 00             	movzbl (%eax),%eax
c0100b94:	84 c0                	test   %al,%al
c0100b96:	74 1d                	je     c0100bb5 <parse+0x42>
c0100b98:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b9b:	0f b6 00             	movzbl (%eax),%eax
c0100b9e:	0f be c0             	movsbl %al,%eax
c0100ba1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ba5:	c7 04 24 f4 a0 10 c0 	movl   $0xc010a0f4,(%esp)
c0100bac:	e8 e8 87 00 00       	call   c0109399 <strchr>
c0100bb1:	85 c0                	test   %eax,%eax
c0100bb3:	75 cd                	jne    c0100b82 <parse+0xf>
        }
        if (*buf == '\0') {
c0100bb5:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bb8:	0f b6 00             	movzbl (%eax),%eax
c0100bbb:	84 c0                	test   %al,%al
c0100bbd:	75 02                	jne    c0100bc1 <parse+0x4e>
            break;
c0100bbf:	eb 67                	jmp    c0100c28 <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100bc1:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100bc5:	75 14                	jne    c0100bdb <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100bc7:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100bce:	00 
c0100bcf:	c7 04 24 f9 a0 10 c0 	movl   $0xc010a0f9,(%esp)
c0100bd6:	e8 ce f6 ff ff       	call   c01002a9 <cprintf>
        }
        argv[argc ++] = buf;
c0100bdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bde:	8d 50 01             	lea    0x1(%eax),%edx
c0100be1:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100be4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100beb:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100bee:	01 c2                	add    %eax,%edx
c0100bf0:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bf3:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100bf5:	eb 04                	jmp    c0100bfb <parse+0x88>
            buf ++;
c0100bf7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100bfb:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bfe:	0f b6 00             	movzbl (%eax),%eax
c0100c01:	84 c0                	test   %al,%al
c0100c03:	74 1d                	je     c0100c22 <parse+0xaf>
c0100c05:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c08:	0f b6 00             	movzbl (%eax),%eax
c0100c0b:	0f be c0             	movsbl %al,%eax
c0100c0e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c12:	c7 04 24 f4 a0 10 c0 	movl   $0xc010a0f4,(%esp)
c0100c19:	e8 7b 87 00 00       	call   c0109399 <strchr>
c0100c1e:	85 c0                	test   %eax,%eax
c0100c20:	74 d5                	je     c0100bf7 <parse+0x84>
        }
    }
c0100c22:	90                   	nop
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100c23:	e9 66 ff ff ff       	jmp    c0100b8e <parse+0x1b>
    return argc;
c0100c28:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100c2b:	c9                   	leave  
c0100c2c:	c3                   	ret    

c0100c2d <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100c2d:	55                   	push   %ebp
c0100c2e:	89 e5                	mov    %esp,%ebp
c0100c30:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100c33:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c36:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c3a:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c3d:	89 04 24             	mov    %eax,(%esp)
c0100c40:	e8 2e ff ff ff       	call   c0100b73 <parse>
c0100c45:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100c48:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100c4c:	75 0a                	jne    c0100c58 <runcmd+0x2b>
        return 0;
c0100c4e:	b8 00 00 00 00       	mov    $0x0,%eax
c0100c53:	e9 85 00 00 00       	jmp    c0100cdd <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c58:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c5f:	eb 5c                	jmp    c0100cbd <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100c61:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100c64:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c67:	89 d0                	mov    %edx,%eax
c0100c69:	01 c0                	add    %eax,%eax
c0100c6b:	01 d0                	add    %edx,%eax
c0100c6d:	c1 e0 02             	shl    $0x2,%eax
c0100c70:	05 00 40 12 c0       	add    $0xc0124000,%eax
c0100c75:	8b 00                	mov    (%eax),%eax
c0100c77:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100c7b:	89 04 24             	mov    %eax,(%esp)
c0100c7e:	e8 77 86 00 00       	call   c01092fa <strcmp>
c0100c83:	85 c0                	test   %eax,%eax
c0100c85:	75 32                	jne    c0100cb9 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100c87:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c8a:	89 d0                	mov    %edx,%eax
c0100c8c:	01 c0                	add    %eax,%eax
c0100c8e:	01 d0                	add    %edx,%eax
c0100c90:	c1 e0 02             	shl    $0x2,%eax
c0100c93:	05 00 40 12 c0       	add    $0xc0124000,%eax
c0100c98:	8b 40 08             	mov    0x8(%eax),%eax
c0100c9b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100c9e:	8d 4a ff             	lea    -0x1(%edx),%ecx
c0100ca1:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100ca4:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100ca8:	8d 55 b0             	lea    -0x50(%ebp),%edx
c0100cab:	83 c2 04             	add    $0x4,%edx
c0100cae:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100cb2:	89 0c 24             	mov    %ecx,(%esp)
c0100cb5:	ff d0                	call   *%eax
c0100cb7:	eb 24                	jmp    c0100cdd <runcmd+0xb0>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100cb9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100cbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cc0:	83 f8 02             	cmp    $0x2,%eax
c0100cc3:	76 9c                	jbe    c0100c61 <runcmd+0x34>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100cc5:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100cc8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ccc:	c7 04 24 17 a1 10 c0 	movl   $0xc010a117,(%esp)
c0100cd3:	e8 d1 f5 ff ff       	call   c01002a9 <cprintf>
    return 0;
c0100cd8:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cdd:	c9                   	leave  
c0100cde:	c3                   	ret    

c0100cdf <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100cdf:	55                   	push   %ebp
c0100ce0:	89 e5                	mov    %esp,%ebp
c0100ce2:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100ce5:	c7 04 24 30 a1 10 c0 	movl   $0xc010a130,(%esp)
c0100cec:	e8 b8 f5 ff ff       	call   c01002a9 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100cf1:	c7 04 24 58 a1 10 c0 	movl   $0xc010a158,(%esp)
c0100cf8:	e8 ac f5 ff ff       	call   c01002a9 <cprintf>

    if (tf != NULL) {
c0100cfd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100d01:	74 0b                	je     c0100d0e <kmonitor+0x2f>
        print_trapframe(tf);
c0100d03:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d06:	89 04 24             	mov    %eax,(%esp)
c0100d09:	e8 0e 16 00 00       	call   c010231c <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100d0e:	c7 04 24 7d a1 10 c0 	movl   $0xc010a17d,(%esp)
c0100d15:	e8 30 f6 ff ff       	call   c010034a <readline>
c0100d1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100d1d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100d21:	74 18                	je     c0100d3b <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
c0100d23:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d26:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d2d:	89 04 24             	mov    %eax,(%esp)
c0100d30:	e8 f8 fe ff ff       	call   c0100c2d <runcmd>
c0100d35:	85 c0                	test   %eax,%eax
c0100d37:	79 02                	jns    c0100d3b <kmonitor+0x5c>
                break;
c0100d39:	eb 02                	jmp    c0100d3d <kmonitor+0x5e>
            }
        }
    }
c0100d3b:	eb d1                	jmp    c0100d0e <kmonitor+0x2f>
}
c0100d3d:	c9                   	leave  
c0100d3e:	c3                   	ret    

c0100d3f <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100d3f:	55                   	push   %ebp
c0100d40:	89 e5                	mov    %esp,%ebp
c0100d42:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d45:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100d4c:	eb 3f                	jmp    c0100d8d <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100d4e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d51:	89 d0                	mov    %edx,%eax
c0100d53:	01 c0                	add    %eax,%eax
c0100d55:	01 d0                	add    %edx,%eax
c0100d57:	c1 e0 02             	shl    $0x2,%eax
c0100d5a:	05 00 40 12 c0       	add    $0xc0124000,%eax
c0100d5f:	8b 48 04             	mov    0x4(%eax),%ecx
c0100d62:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d65:	89 d0                	mov    %edx,%eax
c0100d67:	01 c0                	add    %eax,%eax
c0100d69:	01 d0                	add    %edx,%eax
c0100d6b:	c1 e0 02             	shl    $0x2,%eax
c0100d6e:	05 00 40 12 c0       	add    $0xc0124000,%eax
c0100d73:	8b 00                	mov    (%eax),%eax
c0100d75:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100d79:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d7d:	c7 04 24 81 a1 10 c0 	movl   $0xc010a181,(%esp)
c0100d84:	e8 20 f5 ff ff       	call   c01002a9 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d89:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100d8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d90:	83 f8 02             	cmp    $0x2,%eax
c0100d93:	76 b9                	jbe    c0100d4e <mon_help+0xf>
    }
    return 0;
c0100d95:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d9a:	c9                   	leave  
c0100d9b:	c3                   	ret    

c0100d9c <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100d9c:	55                   	push   %ebp
c0100d9d:	89 e5                	mov    %esp,%ebp
c0100d9f:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100da2:	e8 b9 fb ff ff       	call   c0100960 <print_kerninfo>
    return 0;
c0100da7:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100dac:	c9                   	leave  
c0100dad:	c3                   	ret    

c0100dae <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100dae:	55                   	push   %ebp
c0100daf:	89 e5                	mov    %esp,%ebp
c0100db1:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100db4:	e8 f1 fc ff ff       	call   c0100aaa <print_stackframe>
    return 0;
c0100db9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100dbe:	c9                   	leave  
c0100dbf:	c3                   	ret    

c0100dc0 <ide_wait_ready>:
    unsigned int size;          // Size in Sectors
    unsigned char model[41];    // Model in String
} ide_devices[MAX_IDE];

static int
ide_wait_ready(unsigned short iobase, bool check_error) {
c0100dc0:	55                   	push   %ebp
c0100dc1:	89 e5                	mov    %esp,%ebp
c0100dc3:	83 ec 14             	sub    $0x14,%esp
c0100dc6:	8b 45 08             	mov    0x8(%ebp),%eax
c0100dc9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    int r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c0100dcd:	90                   	nop
c0100dce:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0100dd2:	83 c0 07             	add    $0x7,%eax
c0100dd5:	0f b7 c0             	movzwl %ax,%eax
c0100dd8:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100ddc:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100de0:	89 c2                	mov    %eax,%edx
c0100de2:	ec                   	in     (%dx),%al
c0100de3:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0100de6:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0100dea:	0f b6 c0             	movzbl %al,%eax
c0100ded:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100df0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100df3:	25 80 00 00 00       	and    $0x80,%eax
c0100df8:	85 c0                	test   %eax,%eax
c0100dfa:	75 d2                	jne    c0100dce <ide_wait_ready+0xe>
        /* nothing */;
    if (check_error && (r & (IDE_DF | IDE_ERR)) != 0) {
c0100dfc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0100e00:	74 11                	je     c0100e13 <ide_wait_ready+0x53>
c0100e02:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e05:	83 e0 21             	and    $0x21,%eax
c0100e08:	85 c0                	test   %eax,%eax
c0100e0a:	74 07                	je     c0100e13 <ide_wait_ready+0x53>
        return -1;
c0100e0c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100e11:	eb 05                	jmp    c0100e18 <ide_wait_ready+0x58>
    }
    return 0;
c0100e13:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e18:	c9                   	leave  
c0100e19:	c3                   	ret    

c0100e1a <ide_init>:

void
ide_init(void) {
c0100e1a:	55                   	push   %ebp
c0100e1b:	89 e5                	mov    %esp,%ebp
c0100e1d:	57                   	push   %edi
c0100e1e:	53                   	push   %ebx
c0100e1f:	81 ec 50 02 00 00    	sub    $0x250,%esp
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0100e25:	66 c7 45 f6 00 00    	movw   $0x0,-0xa(%ebp)
c0100e2b:	e9 d6 02 00 00       	jmp    c0101106 <ide_init+0x2ec>
        /* assume that no device here */
        ide_devices[ideno].valid = 0;
c0100e30:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e34:	c1 e0 03             	shl    $0x3,%eax
c0100e37:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0100e3e:	29 c2                	sub    %eax,%edx
c0100e40:	8d 82 40 74 12 c0    	lea    -0x3fed8bc0(%edx),%eax
c0100e46:	c6 00 00             	movb   $0x0,(%eax)

        iobase = IO_BASE(ideno);
c0100e49:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e4d:	66 d1 e8             	shr    %ax
c0100e50:	0f b7 c0             	movzwl %ax,%eax
c0100e53:	0f b7 04 85 8c a1 10 	movzwl -0x3fef5e74(,%eax,4),%eax
c0100e5a:	c0 
c0100e5b:	66 89 45 ea          	mov    %ax,-0x16(%ebp)

        /* wait device ready */
        ide_wait_ready(iobase, 0);
c0100e5f:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100e63:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100e6a:	00 
c0100e6b:	89 04 24             	mov    %eax,(%esp)
c0100e6e:	e8 4d ff ff ff       	call   c0100dc0 <ide_wait_ready>

        /* step1: select drive */
        outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4));
c0100e73:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e77:	83 e0 01             	and    $0x1,%eax
c0100e7a:	c1 e0 04             	shl    $0x4,%eax
c0100e7d:	83 c8 e0             	or     $0xffffffe0,%eax
c0100e80:	0f b6 c0             	movzbl %al,%eax
c0100e83:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100e87:	83 c2 06             	add    $0x6,%edx
c0100e8a:	0f b7 d2             	movzwl %dx,%edx
c0100e8d:	66 89 55 d2          	mov    %dx,-0x2e(%ebp)
c0100e91:	88 45 d1             	mov    %al,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e94:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0100e98:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0100e9c:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c0100e9d:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100ea1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100ea8:	00 
c0100ea9:	89 04 24             	mov    %eax,(%esp)
c0100eac:	e8 0f ff ff ff       	call   c0100dc0 <ide_wait_ready>

        /* step2: send ATA identify command */
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
c0100eb1:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100eb5:	83 c0 07             	add    $0x7,%eax
c0100eb8:	0f b7 c0             	movzwl %ax,%eax
c0100ebb:	66 89 45 ce          	mov    %ax,-0x32(%ebp)
c0100ebf:	c6 45 cd ec          	movb   $0xec,-0x33(%ebp)
c0100ec3:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0100ec7:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0100ecb:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c0100ecc:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100ed0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100ed7:	00 
c0100ed8:	89 04 24             	mov    %eax,(%esp)
c0100edb:	e8 e0 fe ff ff       	call   c0100dc0 <ide_wait_ready>

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
c0100ee0:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100ee4:	83 c0 07             	add    $0x7,%eax
c0100ee7:	0f b7 c0             	movzwl %ax,%eax
c0100eea:	66 89 45 ca          	mov    %ax,-0x36(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100eee:	0f b7 45 ca          	movzwl -0x36(%ebp),%eax
c0100ef2:	89 c2                	mov    %eax,%edx
c0100ef4:	ec                   	in     (%dx),%al
c0100ef5:	88 45 c9             	mov    %al,-0x37(%ebp)
    return data;
c0100ef8:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0100efc:	84 c0                	test   %al,%al
c0100efe:	0f 84 f7 01 00 00    	je     c01010fb <ide_init+0x2e1>
c0100f04:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100f08:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0100f0f:	00 
c0100f10:	89 04 24             	mov    %eax,(%esp)
c0100f13:	e8 a8 fe ff ff       	call   c0100dc0 <ide_wait_ready>
c0100f18:	85 c0                	test   %eax,%eax
c0100f1a:	0f 85 db 01 00 00    	jne    c01010fb <ide_init+0x2e1>
            continue ;
        }

        /* device is ok */
        ide_devices[ideno].valid = 1;
c0100f20:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100f24:	c1 e0 03             	shl    $0x3,%eax
c0100f27:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0100f2e:	29 c2                	sub    %eax,%edx
c0100f30:	8d 82 40 74 12 c0    	lea    -0x3fed8bc0(%edx),%eax
c0100f36:	c6 00 01             	movb   $0x1,(%eax)

        /* read identification space of the device */
        unsigned int buffer[128];
        insl(iobase + ISA_DATA, buffer, sizeof(buffer) / sizeof(unsigned int));
c0100f39:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100f3d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0100f40:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0100f46:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0100f49:	c7 45 bc 80 00 00 00 	movl   $0x80,-0x44(%ebp)
    asm volatile (
c0100f50:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0100f53:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c0100f56:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0100f59:	89 cb                	mov    %ecx,%ebx
c0100f5b:	89 df                	mov    %ebx,%edi
c0100f5d:	89 c1                	mov    %eax,%ecx
c0100f5f:	fc                   	cld    
c0100f60:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0100f62:	89 c8                	mov    %ecx,%eax
c0100f64:	89 fb                	mov    %edi,%ebx
c0100f66:	89 5d c0             	mov    %ebx,-0x40(%ebp)
c0100f69:	89 45 bc             	mov    %eax,-0x44(%ebp)

        unsigned char *ident = (unsigned char *)buffer;
c0100f6c:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0100f72:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        unsigned int sectors;
        unsigned int cmdsets = *(unsigned int *)(ident + IDE_IDENT_CMDSETS);
c0100f75:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100f78:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
c0100f7e:	89 45 e0             	mov    %eax,-0x20(%ebp)
        /* device use 48-bits or 28-bits addressing */
        if (cmdsets & (1 << 26)) {
c0100f81:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100f84:	25 00 00 00 04       	and    $0x4000000,%eax
c0100f89:	85 c0                	test   %eax,%eax
c0100f8b:	74 0e                	je     c0100f9b <ide_init+0x181>
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA_EXT);
c0100f8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100f90:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
c0100f96:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100f99:	eb 09                	jmp    c0100fa4 <ide_init+0x18a>
        }
        else {
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA);
c0100f9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100f9e:	8b 40 78             	mov    0x78(%eax),%eax
c0100fa1:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        ide_devices[ideno].sets = cmdsets;
c0100fa4:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100fa8:	c1 e0 03             	shl    $0x3,%eax
c0100fab:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0100fb2:	29 c2                	sub    %eax,%edx
c0100fb4:	81 c2 40 74 12 c0    	add    $0xc0127440,%edx
c0100fba:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100fbd:	89 42 04             	mov    %eax,0x4(%edx)
        ide_devices[ideno].size = sectors;
c0100fc0:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100fc4:	c1 e0 03             	shl    $0x3,%eax
c0100fc7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0100fce:	29 c2                	sub    %eax,%edx
c0100fd0:	81 c2 40 74 12 c0    	add    $0xc0127440,%edx
c0100fd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100fd9:	89 42 08             	mov    %eax,0x8(%edx)

        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c0100fdc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100fdf:	83 c0 62             	add    $0x62,%eax
c0100fe2:	0f b7 00             	movzwl (%eax),%eax
c0100fe5:	0f b7 c0             	movzwl %ax,%eax
c0100fe8:	25 00 02 00 00       	and    $0x200,%eax
c0100fed:	85 c0                	test   %eax,%eax
c0100fef:	75 24                	jne    c0101015 <ide_init+0x1fb>
c0100ff1:	c7 44 24 0c 94 a1 10 	movl   $0xc010a194,0xc(%esp)
c0100ff8:	c0 
c0100ff9:	c7 44 24 08 d7 a1 10 	movl   $0xc010a1d7,0x8(%esp)
c0101000:	c0 
c0101001:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c0101008:	00 
c0101009:	c7 04 24 ec a1 10 c0 	movl   $0xc010a1ec,(%esp)
c0101010:	e8 eb f3 ff ff       	call   c0100400 <__panic>

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
c0101015:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101019:	c1 e0 03             	shl    $0x3,%eax
c010101c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101023:	29 c2                	sub    %eax,%edx
c0101025:	8d 82 40 74 12 c0    	lea    -0x3fed8bc0(%edx),%eax
c010102b:	83 c0 0c             	add    $0xc,%eax
c010102e:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0101031:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101034:	83 c0 36             	add    $0x36,%eax
c0101037:	89 45 d8             	mov    %eax,-0x28(%ebp)
        unsigned int i, length = 40;
c010103a:	c7 45 d4 28 00 00 00 	movl   $0x28,-0x2c(%ebp)
        for (i = 0; i < length; i += 2) {
c0101041:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0101048:	eb 34                	jmp    c010107e <ide_init+0x264>
            model[i] = data[i + 1], model[i + 1] = data[i];
c010104a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010104d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101050:	01 c2                	add    %eax,%edx
c0101052:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101055:	8d 48 01             	lea    0x1(%eax),%ecx
c0101058:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010105b:	01 c8                	add    %ecx,%eax
c010105d:	0f b6 00             	movzbl (%eax),%eax
c0101060:	88 02                	mov    %al,(%edx)
c0101062:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101065:	8d 50 01             	lea    0x1(%eax),%edx
c0101068:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010106b:	01 c2                	add    %eax,%edx
c010106d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101070:	8b 4d d8             	mov    -0x28(%ebp),%ecx
c0101073:	01 c8                	add    %ecx,%eax
c0101075:	0f b6 00             	movzbl (%eax),%eax
c0101078:	88 02                	mov    %al,(%edx)
        for (i = 0; i < length; i += 2) {
c010107a:	83 45 ec 02          	addl   $0x2,-0x14(%ebp)
c010107e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101081:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c0101084:	72 c4                	jb     c010104a <ide_init+0x230>
        }
        do {
            model[i] = '\0';
c0101086:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101089:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010108c:	01 d0                	add    %edx,%eax
c010108e:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c0101091:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101094:	8d 50 ff             	lea    -0x1(%eax),%edx
c0101097:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010109a:	85 c0                	test   %eax,%eax
c010109c:	74 0f                	je     c01010ad <ide_init+0x293>
c010109e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01010a1:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01010a4:	01 d0                	add    %edx,%eax
c01010a6:	0f b6 00             	movzbl (%eax),%eax
c01010a9:	3c 20                	cmp    $0x20,%al
c01010ab:	74 d9                	je     c0101086 <ide_init+0x26c>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
c01010ad:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01010b1:	c1 e0 03             	shl    $0x3,%eax
c01010b4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01010bb:	29 c2                	sub    %eax,%edx
c01010bd:	8d 82 40 74 12 c0    	lea    -0x3fed8bc0(%edx),%eax
c01010c3:	8d 48 0c             	lea    0xc(%eax),%ecx
c01010c6:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01010ca:	c1 e0 03             	shl    $0x3,%eax
c01010cd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01010d4:	29 c2                	sub    %eax,%edx
c01010d6:	8d 82 40 74 12 c0    	lea    -0x3fed8bc0(%edx),%eax
c01010dc:	8b 50 08             	mov    0x8(%eax),%edx
c01010df:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01010e3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01010e7:	89 54 24 08          	mov    %edx,0x8(%esp)
c01010eb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01010ef:	c7 04 24 fe a1 10 c0 	movl   $0xc010a1fe,(%esp)
c01010f6:	e8 ae f1 ff ff       	call   c01002a9 <cprintf>
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c01010fb:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01010ff:	83 c0 01             	add    $0x1,%eax
c0101102:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c0101106:	66 83 7d f6 03       	cmpw   $0x3,-0xa(%ebp)
c010110b:	0f 86 1f fd ff ff    	jbe    c0100e30 <ide_init+0x16>
    }

    // enable ide interrupt
    pic_enable(IRQ_IDE1);
c0101111:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
c0101118:	e8 91 0e 00 00       	call   c0101fae <pic_enable>
    pic_enable(IRQ_IDE2);
c010111d:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
c0101124:	e8 85 0e 00 00       	call   c0101fae <pic_enable>
}
c0101129:	81 c4 50 02 00 00    	add    $0x250,%esp
c010112f:	5b                   	pop    %ebx
c0101130:	5f                   	pop    %edi
c0101131:	5d                   	pop    %ebp
c0101132:	c3                   	ret    

c0101133 <ide_device_valid>:

bool
ide_device_valid(unsigned short ideno) {
c0101133:	55                   	push   %ebp
c0101134:	89 e5                	mov    %esp,%ebp
c0101136:	83 ec 04             	sub    $0x4,%esp
c0101139:	8b 45 08             	mov    0x8(%ebp),%eax
c010113c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    return VALID_IDE(ideno);
c0101140:	66 83 7d fc 03       	cmpw   $0x3,-0x4(%ebp)
c0101145:	77 24                	ja     c010116b <ide_device_valid+0x38>
c0101147:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c010114b:	c1 e0 03             	shl    $0x3,%eax
c010114e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101155:	29 c2                	sub    %eax,%edx
c0101157:	8d 82 40 74 12 c0    	lea    -0x3fed8bc0(%edx),%eax
c010115d:	0f b6 00             	movzbl (%eax),%eax
c0101160:	84 c0                	test   %al,%al
c0101162:	74 07                	je     c010116b <ide_device_valid+0x38>
c0101164:	b8 01 00 00 00       	mov    $0x1,%eax
c0101169:	eb 05                	jmp    c0101170 <ide_device_valid+0x3d>
c010116b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101170:	c9                   	leave  
c0101171:	c3                   	ret    

c0101172 <ide_device_size>:

size_t
ide_device_size(unsigned short ideno) {
c0101172:	55                   	push   %ebp
c0101173:	89 e5                	mov    %esp,%ebp
c0101175:	83 ec 08             	sub    $0x8,%esp
c0101178:	8b 45 08             	mov    0x8(%ebp),%eax
c010117b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    if (ide_device_valid(ideno)) {
c010117f:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101183:	89 04 24             	mov    %eax,(%esp)
c0101186:	e8 a8 ff ff ff       	call   c0101133 <ide_device_valid>
c010118b:	85 c0                	test   %eax,%eax
c010118d:	74 1b                	je     c01011aa <ide_device_size+0x38>
        return ide_devices[ideno].size;
c010118f:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101193:	c1 e0 03             	shl    $0x3,%eax
c0101196:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010119d:	29 c2                	sub    %eax,%edx
c010119f:	8d 82 40 74 12 c0    	lea    -0x3fed8bc0(%edx),%eax
c01011a5:	8b 40 08             	mov    0x8(%eax),%eax
c01011a8:	eb 05                	jmp    c01011af <ide_device_size+0x3d>
    }
    return 0;
c01011aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01011af:	c9                   	leave  
c01011b0:	c3                   	ret    

c01011b1 <ide_read_secs>:

int
ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs) {
c01011b1:	55                   	push   %ebp
c01011b2:	89 e5                	mov    %esp,%ebp
c01011b4:	57                   	push   %edi
c01011b5:	53                   	push   %ebx
c01011b6:	83 ec 50             	sub    $0x50,%esp
c01011b9:	8b 45 08             	mov    0x8(%ebp),%eax
c01011bc:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c01011c0:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c01011c7:	77 24                	ja     c01011ed <ide_read_secs+0x3c>
c01011c9:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c01011ce:	77 1d                	ja     c01011ed <ide_read_secs+0x3c>
c01011d0:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01011d4:	c1 e0 03             	shl    $0x3,%eax
c01011d7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01011de:	29 c2                	sub    %eax,%edx
c01011e0:	8d 82 40 74 12 c0    	lea    -0x3fed8bc0(%edx),%eax
c01011e6:	0f b6 00             	movzbl (%eax),%eax
c01011e9:	84 c0                	test   %al,%al
c01011eb:	75 24                	jne    c0101211 <ide_read_secs+0x60>
c01011ed:	c7 44 24 0c 1c a2 10 	movl   $0xc010a21c,0xc(%esp)
c01011f4:	c0 
c01011f5:	c7 44 24 08 d7 a1 10 	movl   $0xc010a1d7,0x8(%esp)
c01011fc:	c0 
c01011fd:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c0101204:	00 
c0101205:	c7 04 24 ec a1 10 c0 	movl   $0xc010a1ec,(%esp)
c010120c:	e8 ef f1 ff ff       	call   c0100400 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101211:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101218:	77 0f                	ja     c0101229 <ide_read_secs+0x78>
c010121a:	8b 45 14             	mov    0x14(%ebp),%eax
c010121d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101220:	01 d0                	add    %edx,%eax
c0101222:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101227:	76 24                	jbe    c010124d <ide_read_secs+0x9c>
c0101229:	c7 44 24 0c 44 a2 10 	movl   $0xc010a244,0xc(%esp)
c0101230:	c0 
c0101231:	c7 44 24 08 d7 a1 10 	movl   $0xc010a1d7,0x8(%esp)
c0101238:	c0 
c0101239:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c0101240:	00 
c0101241:	c7 04 24 ec a1 10 c0 	movl   $0xc010a1ec,(%esp)
c0101248:	e8 b3 f1 ff ff       	call   c0100400 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c010124d:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101251:	66 d1 e8             	shr    %ax
c0101254:	0f b7 c0             	movzwl %ax,%eax
c0101257:	0f b7 04 85 8c a1 10 	movzwl -0x3fef5e74(,%eax,4),%eax
c010125e:	c0 
c010125f:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101263:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101267:	66 d1 e8             	shr    %ax
c010126a:	0f b7 c0             	movzwl %ax,%eax
c010126d:	0f b7 04 85 8e a1 10 	movzwl -0x3fef5e72(,%eax,4),%eax
c0101274:	c0 
c0101275:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101279:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010127d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101284:	00 
c0101285:	89 04 24             	mov    %eax,(%esp)
c0101288:	e8 33 fb ff ff       	call   c0100dc0 <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c010128d:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101291:	83 c0 02             	add    $0x2,%eax
c0101294:	0f b7 c0             	movzwl %ax,%eax
c0101297:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c010129b:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010129f:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01012a3:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01012a7:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c01012a8:	8b 45 14             	mov    0x14(%ebp),%eax
c01012ab:	0f b6 c0             	movzbl %al,%eax
c01012ae:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01012b2:	83 c2 02             	add    $0x2,%edx
c01012b5:	0f b7 d2             	movzwl %dx,%edx
c01012b8:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c01012bc:	88 45 e9             	mov    %al,-0x17(%ebp)
c01012bf:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01012c3:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01012c7:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c01012c8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01012cb:	0f b6 c0             	movzbl %al,%eax
c01012ce:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01012d2:	83 c2 03             	add    $0x3,%edx
c01012d5:	0f b7 d2             	movzwl %dx,%edx
c01012d8:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01012dc:	88 45 e5             	mov    %al,-0x1b(%ebp)
c01012df:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01012e3:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01012e7:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c01012e8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01012eb:	c1 e8 08             	shr    $0x8,%eax
c01012ee:	0f b6 c0             	movzbl %al,%eax
c01012f1:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01012f5:	83 c2 04             	add    $0x4,%edx
c01012f8:	0f b7 d2             	movzwl %dx,%edx
c01012fb:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c01012ff:	88 45 e1             	mov    %al,-0x1f(%ebp)
c0101302:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101306:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c010130a:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c010130b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010130e:	c1 e8 10             	shr    $0x10,%eax
c0101311:	0f b6 c0             	movzbl %al,%eax
c0101314:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101318:	83 c2 05             	add    $0x5,%edx
c010131b:	0f b7 d2             	movzwl %dx,%edx
c010131e:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0101322:	88 45 dd             	mov    %al,-0x23(%ebp)
c0101325:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101329:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c010132d:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c010132e:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101332:	83 e0 01             	and    $0x1,%eax
c0101335:	c1 e0 04             	shl    $0x4,%eax
c0101338:	89 c2                	mov    %eax,%edx
c010133a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010133d:	c1 e8 18             	shr    $0x18,%eax
c0101340:	83 e0 0f             	and    $0xf,%eax
c0101343:	09 d0                	or     %edx,%eax
c0101345:	83 c8 e0             	or     $0xffffffe0,%eax
c0101348:	0f b6 c0             	movzbl %al,%eax
c010134b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010134f:	83 c2 06             	add    $0x6,%edx
c0101352:	0f b7 d2             	movzwl %dx,%edx
c0101355:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101359:	88 45 d9             	mov    %al,-0x27(%ebp)
c010135c:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101360:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101364:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);
c0101365:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101369:	83 c0 07             	add    $0x7,%eax
c010136c:	0f b7 c0             	movzwl %ax,%eax
c010136f:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101373:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
c0101377:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c010137b:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c010137f:	ee                   	out    %al,(%dx)

    int ret = 0;
c0101380:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101387:	eb 5a                	jmp    c01013e3 <ide_read_secs+0x232>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101389:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010138d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101394:	00 
c0101395:	89 04 24             	mov    %eax,(%esp)
c0101398:	e8 23 fa ff ff       	call   c0100dc0 <ide_wait_ready>
c010139d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01013a0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01013a4:	74 02                	je     c01013a8 <ide_read_secs+0x1f7>
            goto out;
c01013a6:	eb 41                	jmp    c01013e9 <ide_read_secs+0x238>
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
c01013a8:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01013ac:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01013af:	8b 45 10             	mov    0x10(%ebp),%eax
c01013b2:	89 45 cc             	mov    %eax,-0x34(%ebp)
c01013b5:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile (
c01013bc:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01013bf:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c01013c2:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01013c5:	89 cb                	mov    %ecx,%ebx
c01013c7:	89 df                	mov    %ebx,%edi
c01013c9:	89 c1                	mov    %eax,%ecx
c01013cb:	fc                   	cld    
c01013cc:	f2 6d                	repnz insl (%dx),%es:(%edi)
c01013ce:	89 c8                	mov    %ecx,%eax
c01013d0:	89 fb                	mov    %edi,%ebx
c01013d2:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c01013d5:	89 45 c8             	mov    %eax,-0x38(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c01013d8:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c01013dc:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c01013e3:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c01013e7:	75 a0                	jne    c0101389 <ide_read_secs+0x1d8>
    }

out:
    return ret;
c01013e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01013ec:	83 c4 50             	add    $0x50,%esp
c01013ef:	5b                   	pop    %ebx
c01013f0:	5f                   	pop    %edi
c01013f1:	5d                   	pop    %ebp
c01013f2:	c3                   	ret    

c01013f3 <ide_write_secs>:

int
ide_write_secs(unsigned short ideno, uint32_t secno, const void *src, size_t nsecs) {
c01013f3:	55                   	push   %ebp
c01013f4:	89 e5                	mov    %esp,%ebp
c01013f6:	56                   	push   %esi
c01013f7:	53                   	push   %ebx
c01013f8:	83 ec 50             	sub    $0x50,%esp
c01013fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01013fe:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101402:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101409:	77 24                	ja     c010142f <ide_write_secs+0x3c>
c010140b:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c0101410:	77 1d                	ja     c010142f <ide_write_secs+0x3c>
c0101412:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101416:	c1 e0 03             	shl    $0x3,%eax
c0101419:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101420:	29 c2                	sub    %eax,%edx
c0101422:	8d 82 40 74 12 c0    	lea    -0x3fed8bc0(%edx),%eax
c0101428:	0f b6 00             	movzbl (%eax),%eax
c010142b:	84 c0                	test   %al,%al
c010142d:	75 24                	jne    c0101453 <ide_write_secs+0x60>
c010142f:	c7 44 24 0c 1c a2 10 	movl   $0xc010a21c,0xc(%esp)
c0101436:	c0 
c0101437:	c7 44 24 08 d7 a1 10 	movl   $0xc010a1d7,0x8(%esp)
c010143e:	c0 
c010143f:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c0101446:	00 
c0101447:	c7 04 24 ec a1 10 c0 	movl   $0xc010a1ec,(%esp)
c010144e:	e8 ad ef ff ff       	call   c0100400 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101453:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c010145a:	77 0f                	ja     c010146b <ide_write_secs+0x78>
c010145c:	8b 45 14             	mov    0x14(%ebp),%eax
c010145f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101462:	01 d0                	add    %edx,%eax
c0101464:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101469:	76 24                	jbe    c010148f <ide_write_secs+0x9c>
c010146b:	c7 44 24 0c 44 a2 10 	movl   $0xc010a244,0xc(%esp)
c0101472:	c0 
c0101473:	c7 44 24 08 d7 a1 10 	movl   $0xc010a1d7,0x8(%esp)
c010147a:	c0 
c010147b:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
c0101482:	00 
c0101483:	c7 04 24 ec a1 10 c0 	movl   $0xc010a1ec,(%esp)
c010148a:	e8 71 ef ff ff       	call   c0100400 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c010148f:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101493:	66 d1 e8             	shr    %ax
c0101496:	0f b7 c0             	movzwl %ax,%eax
c0101499:	0f b7 04 85 8c a1 10 	movzwl -0x3fef5e74(,%eax,4),%eax
c01014a0:	c0 
c01014a1:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c01014a5:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01014a9:	66 d1 e8             	shr    %ax
c01014ac:	0f b7 c0             	movzwl %ax,%eax
c01014af:	0f b7 04 85 8e a1 10 	movzwl -0x3fef5e72(,%eax,4),%eax
c01014b6:	c0 
c01014b7:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c01014bb:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01014bf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01014c6:	00 
c01014c7:	89 04 24             	mov    %eax,(%esp)
c01014ca:	e8 f1 f8 ff ff       	call   c0100dc0 <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c01014cf:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01014d3:	83 c0 02             	add    $0x2,%eax
c01014d6:	0f b7 c0             	movzwl %ax,%eax
c01014d9:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c01014dd:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01014e1:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01014e5:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01014e9:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c01014ea:	8b 45 14             	mov    0x14(%ebp),%eax
c01014ed:	0f b6 c0             	movzbl %al,%eax
c01014f0:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01014f4:	83 c2 02             	add    $0x2,%edx
c01014f7:	0f b7 d2             	movzwl %dx,%edx
c01014fa:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c01014fe:	88 45 e9             	mov    %al,-0x17(%ebp)
c0101501:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101505:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101509:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c010150a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010150d:	0f b6 c0             	movzbl %al,%eax
c0101510:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101514:	83 c2 03             	add    $0x3,%edx
c0101517:	0f b7 d2             	movzwl %dx,%edx
c010151a:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c010151e:	88 45 e5             	mov    %al,-0x1b(%ebp)
c0101521:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101525:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101529:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c010152a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010152d:	c1 e8 08             	shr    $0x8,%eax
c0101530:	0f b6 c0             	movzbl %al,%eax
c0101533:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101537:	83 c2 04             	add    $0x4,%edx
c010153a:	0f b7 d2             	movzwl %dx,%edx
c010153d:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101541:	88 45 e1             	mov    %al,-0x1f(%ebp)
c0101544:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101548:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c010154c:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c010154d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101550:	c1 e8 10             	shr    $0x10,%eax
c0101553:	0f b6 c0             	movzbl %al,%eax
c0101556:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010155a:	83 c2 05             	add    $0x5,%edx
c010155d:	0f b7 d2             	movzwl %dx,%edx
c0101560:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0101564:	88 45 dd             	mov    %al,-0x23(%ebp)
c0101567:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c010156b:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c010156f:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101570:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101574:	83 e0 01             	and    $0x1,%eax
c0101577:	c1 e0 04             	shl    $0x4,%eax
c010157a:	89 c2                	mov    %eax,%edx
c010157c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010157f:	c1 e8 18             	shr    $0x18,%eax
c0101582:	83 e0 0f             	and    $0xf,%eax
c0101585:	09 d0                	or     %edx,%eax
c0101587:	83 c8 e0             	or     $0xffffffe0,%eax
c010158a:	0f b6 c0             	movzbl %al,%eax
c010158d:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101591:	83 c2 06             	add    $0x6,%edx
c0101594:	0f b7 d2             	movzwl %dx,%edx
c0101597:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c010159b:	88 45 d9             	mov    %al,-0x27(%ebp)
c010159e:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01015a2:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c01015a6:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);
c01015a7:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01015ab:	83 c0 07             	add    $0x7,%eax
c01015ae:	0f b7 c0             	movzwl %ax,%eax
c01015b1:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c01015b5:	c6 45 d5 30          	movb   $0x30,-0x2b(%ebp)
c01015b9:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c01015bd:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c01015c1:	ee                   	out    %al,(%dx)

    int ret = 0;
c01015c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c01015c9:	eb 5a                	jmp    c0101625 <ide_write_secs+0x232>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c01015cb:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01015cf:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01015d6:	00 
c01015d7:	89 04 24             	mov    %eax,(%esp)
c01015da:	e8 e1 f7 ff ff       	call   c0100dc0 <ide_wait_ready>
c01015df:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01015e2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01015e6:	74 02                	je     c01015ea <ide_write_secs+0x1f7>
            goto out;
c01015e8:	eb 41                	jmp    c010162b <ide_write_secs+0x238>
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
c01015ea:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01015ee:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01015f1:	8b 45 10             	mov    0x10(%ebp),%eax
c01015f4:	89 45 cc             	mov    %eax,-0x34(%ebp)
c01015f7:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile (
c01015fe:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0101601:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0101604:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0101607:	89 cb                	mov    %ecx,%ebx
c0101609:	89 de                	mov    %ebx,%esi
c010160b:	89 c1                	mov    %eax,%ecx
c010160d:	fc                   	cld    
c010160e:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
c0101610:	89 c8                	mov    %ecx,%eax
c0101612:	89 f3                	mov    %esi,%ebx
c0101614:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0101617:	89 45 c8             	mov    %eax,-0x38(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c010161a:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c010161e:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0101625:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101629:	75 a0                	jne    c01015cb <ide_write_secs+0x1d8>
    }

out:
    return ret;
c010162b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010162e:	83 c4 50             	add    $0x50,%esp
c0101631:	5b                   	pop    %ebx
c0101632:	5e                   	pop    %esi
c0101633:	5d                   	pop    %ebp
c0101634:	c3                   	ret    

c0101635 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0101635:	55                   	push   %ebp
c0101636:	89 e5                	mov    %esp,%ebp
c0101638:	83 ec 28             	sub    $0x28,%esp
c010163b:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c0101641:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101645:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101649:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010164d:	ee                   	out    %al,(%dx)
c010164e:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0101654:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
c0101658:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010165c:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101660:	ee                   	out    %al,(%dx)
c0101661:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
c0101667:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
c010166b:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010166f:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101673:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0101674:	c7 05 54 a0 12 c0 00 	movl   $0x0,0xc012a054
c010167b:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c010167e:	c7 04 24 7e a2 10 c0 	movl   $0xc010a27e,(%esp)
c0101685:	e8 1f ec ff ff       	call   c01002a9 <cprintf>
    pic_enable(IRQ_TIMER);
c010168a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0101691:	e8 18 09 00 00       	call   c0101fae <pic_enable>
}
c0101696:	c9                   	leave  
c0101697:	c3                   	ret    

c0101698 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0101698:	55                   	push   %ebp
c0101699:	89 e5                	mov    %esp,%ebp
c010169b:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010169e:	9c                   	pushf  
c010169f:	58                   	pop    %eax
c01016a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01016a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01016a6:	25 00 02 00 00       	and    $0x200,%eax
c01016ab:	85 c0                	test   %eax,%eax
c01016ad:	74 0c                	je     c01016bb <__intr_save+0x23>
        intr_disable();
c01016af:	e8 69 0a 00 00       	call   c010211d <intr_disable>
        return 1;
c01016b4:	b8 01 00 00 00       	mov    $0x1,%eax
c01016b9:	eb 05                	jmp    c01016c0 <__intr_save+0x28>
    }
    return 0;
c01016bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01016c0:	c9                   	leave  
c01016c1:	c3                   	ret    

c01016c2 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c01016c2:	55                   	push   %ebp
c01016c3:	89 e5                	mov    %esp,%ebp
c01016c5:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01016c8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01016cc:	74 05                	je     c01016d3 <__intr_restore+0x11>
        intr_enable();
c01016ce:	e8 44 0a 00 00       	call   c0102117 <intr_enable>
    }
}
c01016d3:	c9                   	leave  
c01016d4:	c3                   	ret    

c01016d5 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c01016d5:	55                   	push   %ebp
c01016d6:	89 e5                	mov    %esp,%ebp
c01016d8:	83 ec 10             	sub    $0x10,%esp
c01016db:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01016e1:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c01016e5:	89 c2                	mov    %eax,%edx
c01016e7:	ec                   	in     (%dx),%al
c01016e8:	88 45 fd             	mov    %al,-0x3(%ebp)
c01016eb:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c01016f1:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01016f5:	89 c2                	mov    %eax,%edx
c01016f7:	ec                   	in     (%dx),%al
c01016f8:	88 45 f9             	mov    %al,-0x7(%ebp)
c01016fb:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0101701:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101705:	89 c2                	mov    %eax,%edx
c0101707:	ec                   	in     (%dx),%al
c0101708:	88 45 f5             	mov    %al,-0xb(%ebp)
c010170b:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
c0101711:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101715:	89 c2                	mov    %eax,%edx
c0101717:	ec                   	in     (%dx),%al
c0101718:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c010171b:	c9                   	leave  
c010171c:	c3                   	ret    

c010171d <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c010171d:	55                   	push   %ebp
c010171e:	89 e5                	mov    %esp,%ebp
c0101720:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0101723:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c010172a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010172d:	0f b7 00             	movzwl (%eax),%eax
c0101730:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0101734:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101737:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c010173c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010173f:	0f b7 00             	movzwl (%eax),%eax
c0101742:	66 3d 5a a5          	cmp    $0xa55a,%ax
c0101746:	74 12                	je     c010175a <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0101748:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c010174f:	66 c7 05 26 75 12 c0 	movw   $0x3b4,0xc0127526
c0101756:	b4 03 
c0101758:	eb 13                	jmp    c010176d <cga_init+0x50>
    } else {
        *cp = was;
c010175a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010175d:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101761:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0101764:	66 c7 05 26 75 12 c0 	movw   $0x3d4,0xc0127526
c010176b:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c010176d:	0f b7 05 26 75 12 c0 	movzwl 0xc0127526,%eax
c0101774:	0f b7 c0             	movzwl %ax,%eax
c0101777:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c010177b:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010177f:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101783:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101787:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0101788:	0f b7 05 26 75 12 c0 	movzwl 0xc0127526,%eax
c010178f:	83 c0 01             	add    $0x1,%eax
c0101792:	0f b7 c0             	movzwl %ax,%eax
c0101795:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101799:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c010179d:	89 c2                	mov    %eax,%edx
c010179f:	ec                   	in     (%dx),%al
c01017a0:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c01017a3:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01017a7:	0f b6 c0             	movzbl %al,%eax
c01017aa:	c1 e0 08             	shl    $0x8,%eax
c01017ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c01017b0:	0f b7 05 26 75 12 c0 	movzwl 0xc0127526,%eax
c01017b7:	0f b7 c0             	movzwl %ax,%eax
c01017ba:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c01017be:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01017c2:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01017c6:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01017ca:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c01017cb:	0f b7 05 26 75 12 c0 	movzwl 0xc0127526,%eax
c01017d2:	83 c0 01             	add    $0x1,%eax
c01017d5:	0f b7 c0             	movzwl %ax,%eax
c01017d8:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01017dc:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c01017e0:	89 c2                	mov    %eax,%edx
c01017e2:	ec                   	in     (%dx),%al
c01017e3:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
c01017e6:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01017ea:	0f b6 c0             	movzbl %al,%eax
c01017ed:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c01017f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01017f3:	a3 20 75 12 c0       	mov    %eax,0xc0127520
    crt_pos = pos;
c01017f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01017fb:	66 a3 24 75 12 c0    	mov    %ax,0xc0127524
}
c0101801:	c9                   	leave  
c0101802:	c3                   	ret    

c0101803 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0101803:	55                   	push   %ebp
c0101804:	89 e5                	mov    %esp,%ebp
c0101806:	83 ec 48             	sub    $0x48,%esp
c0101809:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c010180f:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101813:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101817:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010181b:	ee                   	out    %al,(%dx)
c010181c:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
c0101822:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
c0101826:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010182a:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010182e:	ee                   	out    %al,(%dx)
c010182f:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
c0101835:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
c0101839:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010183d:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101841:	ee                   	out    %al,(%dx)
c0101842:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0101848:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
c010184c:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101850:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101854:	ee                   	out    %al,(%dx)
c0101855:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
c010185b:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
c010185f:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101863:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101867:	ee                   	out    %al,(%dx)
c0101868:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
c010186e:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
c0101872:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101876:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c010187a:	ee                   	out    %al,(%dx)
c010187b:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0101881:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
c0101885:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101889:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c010188d:	ee                   	out    %al,(%dx)
c010188e:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101894:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
c0101898:	89 c2                	mov    %eax,%edx
c010189a:	ec                   	in     (%dx),%al
c010189b:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
c010189e:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c01018a2:	3c ff                	cmp    $0xff,%al
c01018a4:	0f 95 c0             	setne  %al
c01018a7:	0f b6 c0             	movzbl %al,%eax
c01018aa:	a3 28 75 12 c0       	mov    %eax,0xc0127528
c01018af:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01018b5:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
c01018b9:	89 c2                	mov    %eax,%edx
c01018bb:	ec                   	in     (%dx),%al
c01018bc:	88 45 d5             	mov    %al,-0x2b(%ebp)
c01018bf:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
c01018c5:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c01018c9:	89 c2                	mov    %eax,%edx
c01018cb:	ec                   	in     (%dx),%al
c01018cc:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c01018cf:	a1 28 75 12 c0       	mov    0xc0127528,%eax
c01018d4:	85 c0                	test   %eax,%eax
c01018d6:	74 0c                	je     c01018e4 <serial_init+0xe1>
        pic_enable(IRQ_COM1);
c01018d8:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c01018df:	e8 ca 06 00 00       	call   c0101fae <pic_enable>
    }
}
c01018e4:	c9                   	leave  
c01018e5:	c3                   	ret    

c01018e6 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c01018e6:	55                   	push   %ebp
c01018e7:	89 e5                	mov    %esp,%ebp
c01018e9:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01018ec:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01018f3:	eb 09                	jmp    c01018fe <lpt_putc_sub+0x18>
        delay();
c01018f5:	e8 db fd ff ff       	call   c01016d5 <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01018fa:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c01018fe:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c0101904:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101908:	89 c2                	mov    %eax,%edx
c010190a:	ec                   	in     (%dx),%al
c010190b:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c010190e:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101912:	84 c0                	test   %al,%al
c0101914:	78 09                	js     c010191f <lpt_putc_sub+0x39>
c0101916:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c010191d:	7e d6                	jle    c01018f5 <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
c010191f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101922:	0f b6 c0             	movzbl %al,%eax
c0101925:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
c010192b:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010192e:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101932:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101936:	ee                   	out    %al,(%dx)
c0101937:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c010193d:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c0101941:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101945:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101949:	ee                   	out    %al,(%dx)
c010194a:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
c0101950:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
c0101954:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101958:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010195c:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c010195d:	c9                   	leave  
c010195e:	c3                   	ret    

c010195f <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c010195f:	55                   	push   %ebp
c0101960:	89 e5                	mov    %esp,%ebp
c0101962:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101965:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101969:	74 0d                	je     c0101978 <lpt_putc+0x19>
        lpt_putc_sub(c);
c010196b:	8b 45 08             	mov    0x8(%ebp),%eax
c010196e:	89 04 24             	mov    %eax,(%esp)
c0101971:	e8 70 ff ff ff       	call   c01018e6 <lpt_putc_sub>
c0101976:	eb 24                	jmp    c010199c <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
c0101978:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010197f:	e8 62 ff ff ff       	call   c01018e6 <lpt_putc_sub>
        lpt_putc_sub(' ');
c0101984:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010198b:	e8 56 ff ff ff       	call   c01018e6 <lpt_putc_sub>
        lpt_putc_sub('\b');
c0101990:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101997:	e8 4a ff ff ff       	call   c01018e6 <lpt_putc_sub>
    }
}
c010199c:	c9                   	leave  
c010199d:	c3                   	ret    

c010199e <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c010199e:	55                   	push   %ebp
c010199f:	89 e5                	mov    %esp,%ebp
c01019a1:	53                   	push   %ebx
c01019a2:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c01019a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01019a8:	b0 00                	mov    $0x0,%al
c01019aa:	85 c0                	test   %eax,%eax
c01019ac:	75 07                	jne    c01019b5 <cga_putc+0x17>
        c |= 0x0700;
c01019ae:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c01019b5:	8b 45 08             	mov    0x8(%ebp),%eax
c01019b8:	0f b6 c0             	movzbl %al,%eax
c01019bb:	83 f8 0a             	cmp    $0xa,%eax
c01019be:	74 4c                	je     c0101a0c <cga_putc+0x6e>
c01019c0:	83 f8 0d             	cmp    $0xd,%eax
c01019c3:	74 57                	je     c0101a1c <cga_putc+0x7e>
c01019c5:	83 f8 08             	cmp    $0x8,%eax
c01019c8:	0f 85 88 00 00 00    	jne    c0101a56 <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
c01019ce:	0f b7 05 24 75 12 c0 	movzwl 0xc0127524,%eax
c01019d5:	66 85 c0             	test   %ax,%ax
c01019d8:	74 30                	je     c0101a0a <cga_putc+0x6c>
            crt_pos --;
c01019da:	0f b7 05 24 75 12 c0 	movzwl 0xc0127524,%eax
c01019e1:	83 e8 01             	sub    $0x1,%eax
c01019e4:	66 a3 24 75 12 c0    	mov    %ax,0xc0127524
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c01019ea:	a1 20 75 12 c0       	mov    0xc0127520,%eax
c01019ef:	0f b7 15 24 75 12 c0 	movzwl 0xc0127524,%edx
c01019f6:	0f b7 d2             	movzwl %dx,%edx
c01019f9:	01 d2                	add    %edx,%edx
c01019fb:	01 c2                	add    %eax,%edx
c01019fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a00:	b0 00                	mov    $0x0,%al
c0101a02:	83 c8 20             	or     $0x20,%eax
c0101a05:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c0101a08:	eb 72                	jmp    c0101a7c <cga_putc+0xde>
c0101a0a:	eb 70                	jmp    c0101a7c <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
c0101a0c:	0f b7 05 24 75 12 c0 	movzwl 0xc0127524,%eax
c0101a13:	83 c0 50             	add    $0x50,%eax
c0101a16:	66 a3 24 75 12 c0    	mov    %ax,0xc0127524
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c0101a1c:	0f b7 1d 24 75 12 c0 	movzwl 0xc0127524,%ebx
c0101a23:	0f b7 0d 24 75 12 c0 	movzwl 0xc0127524,%ecx
c0101a2a:	0f b7 c1             	movzwl %cx,%eax
c0101a2d:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
c0101a33:	c1 e8 10             	shr    $0x10,%eax
c0101a36:	89 c2                	mov    %eax,%edx
c0101a38:	66 c1 ea 06          	shr    $0x6,%dx
c0101a3c:	89 d0                	mov    %edx,%eax
c0101a3e:	c1 e0 02             	shl    $0x2,%eax
c0101a41:	01 d0                	add    %edx,%eax
c0101a43:	c1 e0 04             	shl    $0x4,%eax
c0101a46:	29 c1                	sub    %eax,%ecx
c0101a48:	89 ca                	mov    %ecx,%edx
c0101a4a:	89 d8                	mov    %ebx,%eax
c0101a4c:	29 d0                	sub    %edx,%eax
c0101a4e:	66 a3 24 75 12 c0    	mov    %ax,0xc0127524
        break;
c0101a54:	eb 26                	jmp    c0101a7c <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c0101a56:	8b 0d 20 75 12 c0    	mov    0xc0127520,%ecx
c0101a5c:	0f b7 05 24 75 12 c0 	movzwl 0xc0127524,%eax
c0101a63:	8d 50 01             	lea    0x1(%eax),%edx
c0101a66:	66 89 15 24 75 12 c0 	mov    %dx,0xc0127524
c0101a6d:	0f b7 c0             	movzwl %ax,%eax
c0101a70:	01 c0                	add    %eax,%eax
c0101a72:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c0101a75:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a78:	66 89 02             	mov    %ax,(%edx)
        break;
c0101a7b:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c0101a7c:	0f b7 05 24 75 12 c0 	movzwl 0xc0127524,%eax
c0101a83:	66 3d cf 07          	cmp    $0x7cf,%ax
c0101a87:	76 5b                	jbe    c0101ae4 <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c0101a89:	a1 20 75 12 c0       	mov    0xc0127520,%eax
c0101a8e:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0101a94:	a1 20 75 12 c0       	mov    0xc0127520,%eax
c0101a99:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c0101aa0:	00 
c0101aa1:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101aa5:	89 04 24             	mov    %eax,(%esp)
c0101aa8:	e8 ea 7a 00 00       	call   c0109597 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101aad:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101ab4:	eb 15                	jmp    c0101acb <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
c0101ab6:	a1 20 75 12 c0       	mov    0xc0127520,%eax
c0101abb:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101abe:	01 d2                	add    %edx,%edx
c0101ac0:	01 d0                	add    %edx,%eax
c0101ac2:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101ac7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101acb:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c0101ad2:	7e e2                	jle    c0101ab6 <cga_putc+0x118>
        }
        crt_pos -= CRT_COLS;
c0101ad4:	0f b7 05 24 75 12 c0 	movzwl 0xc0127524,%eax
c0101adb:	83 e8 50             	sub    $0x50,%eax
c0101ade:	66 a3 24 75 12 c0    	mov    %ax,0xc0127524
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c0101ae4:	0f b7 05 26 75 12 c0 	movzwl 0xc0127526,%eax
c0101aeb:	0f b7 c0             	movzwl %ax,%eax
c0101aee:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101af2:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
c0101af6:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101afa:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101afe:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c0101aff:	0f b7 05 24 75 12 c0 	movzwl 0xc0127524,%eax
c0101b06:	66 c1 e8 08          	shr    $0x8,%ax
c0101b0a:	0f b6 c0             	movzbl %al,%eax
c0101b0d:	0f b7 15 26 75 12 c0 	movzwl 0xc0127526,%edx
c0101b14:	83 c2 01             	add    $0x1,%edx
c0101b17:	0f b7 d2             	movzwl %dx,%edx
c0101b1a:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
c0101b1e:	88 45 ed             	mov    %al,-0x13(%ebp)
c0101b21:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101b25:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101b29:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c0101b2a:	0f b7 05 26 75 12 c0 	movzwl 0xc0127526,%eax
c0101b31:	0f b7 c0             	movzwl %ax,%eax
c0101b34:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c0101b38:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
c0101b3c:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101b40:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101b44:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c0101b45:	0f b7 05 24 75 12 c0 	movzwl 0xc0127524,%eax
c0101b4c:	0f b6 c0             	movzbl %al,%eax
c0101b4f:	0f b7 15 26 75 12 c0 	movzwl 0xc0127526,%edx
c0101b56:	83 c2 01             	add    $0x1,%edx
c0101b59:	0f b7 d2             	movzwl %dx,%edx
c0101b5c:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101b60:	88 45 e5             	mov    %al,-0x1b(%ebp)
c0101b63:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101b67:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101b6b:	ee                   	out    %al,(%dx)
}
c0101b6c:	83 c4 34             	add    $0x34,%esp
c0101b6f:	5b                   	pop    %ebx
c0101b70:	5d                   	pop    %ebp
c0101b71:	c3                   	ret    

c0101b72 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c0101b72:	55                   	push   %ebp
c0101b73:	89 e5                	mov    %esp,%ebp
c0101b75:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101b78:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101b7f:	eb 09                	jmp    c0101b8a <serial_putc_sub+0x18>
        delay();
c0101b81:	e8 4f fb ff ff       	call   c01016d5 <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101b86:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0101b8a:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101b90:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101b94:	89 c2                	mov    %eax,%edx
c0101b96:	ec                   	in     (%dx),%al
c0101b97:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101b9a:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101b9e:	0f b6 c0             	movzbl %al,%eax
c0101ba1:	83 e0 20             	and    $0x20,%eax
c0101ba4:	85 c0                	test   %eax,%eax
c0101ba6:	75 09                	jne    c0101bb1 <serial_putc_sub+0x3f>
c0101ba8:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101baf:	7e d0                	jle    c0101b81 <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
c0101bb1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bb4:	0f b6 c0             	movzbl %al,%eax
c0101bb7:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101bbd:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101bc0:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101bc4:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101bc8:	ee                   	out    %al,(%dx)
}
c0101bc9:	c9                   	leave  
c0101bca:	c3                   	ret    

c0101bcb <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101bcb:	55                   	push   %ebp
c0101bcc:	89 e5                	mov    %esp,%ebp
c0101bce:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101bd1:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101bd5:	74 0d                	je     c0101be4 <serial_putc+0x19>
        serial_putc_sub(c);
c0101bd7:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bda:	89 04 24             	mov    %eax,(%esp)
c0101bdd:	e8 90 ff ff ff       	call   c0101b72 <serial_putc_sub>
c0101be2:	eb 24                	jmp    c0101c08 <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
c0101be4:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101beb:	e8 82 ff ff ff       	call   c0101b72 <serial_putc_sub>
        serial_putc_sub(' ');
c0101bf0:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101bf7:	e8 76 ff ff ff       	call   c0101b72 <serial_putc_sub>
        serial_putc_sub('\b');
c0101bfc:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101c03:	e8 6a ff ff ff       	call   c0101b72 <serial_putc_sub>
    }
}
c0101c08:	c9                   	leave  
c0101c09:	c3                   	ret    

c0101c0a <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0101c0a:	55                   	push   %ebp
c0101c0b:	89 e5                	mov    %esp,%ebp
c0101c0d:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0101c10:	eb 33                	jmp    c0101c45 <cons_intr+0x3b>
        if (c != 0) {
c0101c12:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101c16:	74 2d                	je     c0101c45 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c0101c18:	a1 44 77 12 c0       	mov    0xc0127744,%eax
c0101c1d:	8d 50 01             	lea    0x1(%eax),%edx
c0101c20:	89 15 44 77 12 c0    	mov    %edx,0xc0127744
c0101c26:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101c29:	88 90 40 75 12 c0    	mov    %dl,-0x3fed8ac0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0101c2f:	a1 44 77 12 c0       	mov    0xc0127744,%eax
c0101c34:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101c39:	75 0a                	jne    c0101c45 <cons_intr+0x3b>
                cons.wpos = 0;
c0101c3b:	c7 05 44 77 12 c0 00 	movl   $0x0,0xc0127744
c0101c42:	00 00 00 
    while ((c = (*proc)()) != -1) {
c0101c45:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c48:	ff d0                	call   *%eax
c0101c4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101c4d:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0101c51:	75 bf                	jne    c0101c12 <cons_intr+0x8>
            }
        }
    }
}
c0101c53:	c9                   	leave  
c0101c54:	c3                   	ret    

c0101c55 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c0101c55:	55                   	push   %ebp
c0101c56:	89 e5                	mov    %esp,%ebp
c0101c58:	83 ec 10             	sub    $0x10,%esp
c0101c5b:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101c61:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101c65:	89 c2                	mov    %eax,%edx
c0101c67:	ec                   	in     (%dx),%al
c0101c68:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101c6b:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c0101c6f:	0f b6 c0             	movzbl %al,%eax
c0101c72:	83 e0 01             	and    $0x1,%eax
c0101c75:	85 c0                	test   %eax,%eax
c0101c77:	75 07                	jne    c0101c80 <serial_proc_data+0x2b>
        return -1;
c0101c79:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101c7e:	eb 2a                	jmp    c0101caa <serial_proc_data+0x55>
c0101c80:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101c86:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101c8a:	89 c2                	mov    %eax,%edx
c0101c8c:	ec                   	in     (%dx),%al
c0101c8d:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c0101c90:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c0101c94:	0f b6 c0             	movzbl %al,%eax
c0101c97:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0101c9a:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101c9e:	75 07                	jne    c0101ca7 <serial_proc_data+0x52>
        c = '\b';
c0101ca0:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101ca7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101caa:	c9                   	leave  
c0101cab:	c3                   	ret    

c0101cac <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101cac:	55                   	push   %ebp
c0101cad:	89 e5                	mov    %esp,%ebp
c0101caf:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c0101cb2:	a1 28 75 12 c0       	mov    0xc0127528,%eax
c0101cb7:	85 c0                	test   %eax,%eax
c0101cb9:	74 0c                	je     c0101cc7 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c0101cbb:	c7 04 24 55 1c 10 c0 	movl   $0xc0101c55,(%esp)
c0101cc2:	e8 43 ff ff ff       	call   c0101c0a <cons_intr>
    }
}
c0101cc7:	c9                   	leave  
c0101cc8:	c3                   	ret    

c0101cc9 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101cc9:	55                   	push   %ebp
c0101cca:	89 e5                	mov    %esp,%ebp
c0101ccc:	83 ec 38             	sub    $0x38,%esp
c0101ccf:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101cd5:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101cd9:	89 c2                	mov    %eax,%edx
c0101cdb:	ec                   	in     (%dx),%al
c0101cdc:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c0101cdf:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c0101ce3:	0f b6 c0             	movzbl %al,%eax
c0101ce6:	83 e0 01             	and    $0x1,%eax
c0101ce9:	85 c0                	test   %eax,%eax
c0101ceb:	75 0a                	jne    c0101cf7 <kbd_proc_data+0x2e>
        return -1;
c0101ced:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101cf2:	e9 59 01 00 00       	jmp    c0101e50 <kbd_proc_data+0x187>
c0101cf7:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101cfd:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101d01:	89 c2                	mov    %eax,%edx
c0101d03:	ec                   	in     (%dx),%al
c0101d04:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101d07:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101d0b:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101d0e:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c0101d12:	75 17                	jne    c0101d2b <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
c0101d14:	a1 48 77 12 c0       	mov    0xc0127748,%eax
c0101d19:	83 c8 40             	or     $0x40,%eax
c0101d1c:	a3 48 77 12 c0       	mov    %eax,0xc0127748
        return 0;
c0101d21:	b8 00 00 00 00       	mov    $0x0,%eax
c0101d26:	e9 25 01 00 00       	jmp    c0101e50 <kbd_proc_data+0x187>
    } else if (data & 0x80) {
c0101d2b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d2f:	84 c0                	test   %al,%al
c0101d31:	79 47                	jns    c0101d7a <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c0101d33:	a1 48 77 12 c0       	mov    0xc0127748,%eax
c0101d38:	83 e0 40             	and    $0x40,%eax
c0101d3b:	85 c0                	test   %eax,%eax
c0101d3d:	75 09                	jne    c0101d48 <kbd_proc_data+0x7f>
c0101d3f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d43:	83 e0 7f             	and    $0x7f,%eax
c0101d46:	eb 04                	jmp    c0101d4c <kbd_proc_data+0x83>
c0101d48:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d4c:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c0101d4f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d53:	0f b6 80 40 40 12 c0 	movzbl -0x3fedbfc0(%eax),%eax
c0101d5a:	83 c8 40             	or     $0x40,%eax
c0101d5d:	0f b6 c0             	movzbl %al,%eax
c0101d60:	f7 d0                	not    %eax
c0101d62:	89 c2                	mov    %eax,%edx
c0101d64:	a1 48 77 12 c0       	mov    0xc0127748,%eax
c0101d69:	21 d0                	and    %edx,%eax
c0101d6b:	a3 48 77 12 c0       	mov    %eax,0xc0127748
        return 0;
c0101d70:	b8 00 00 00 00       	mov    $0x0,%eax
c0101d75:	e9 d6 00 00 00       	jmp    c0101e50 <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
c0101d7a:	a1 48 77 12 c0       	mov    0xc0127748,%eax
c0101d7f:	83 e0 40             	and    $0x40,%eax
c0101d82:	85 c0                	test   %eax,%eax
c0101d84:	74 11                	je     c0101d97 <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c0101d86:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0101d8a:	a1 48 77 12 c0       	mov    0xc0127748,%eax
c0101d8f:	83 e0 bf             	and    $0xffffffbf,%eax
c0101d92:	a3 48 77 12 c0       	mov    %eax,0xc0127748
    }

    shift |= shiftcode[data];
c0101d97:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d9b:	0f b6 80 40 40 12 c0 	movzbl -0x3fedbfc0(%eax),%eax
c0101da2:	0f b6 d0             	movzbl %al,%edx
c0101da5:	a1 48 77 12 c0       	mov    0xc0127748,%eax
c0101daa:	09 d0                	or     %edx,%eax
c0101dac:	a3 48 77 12 c0       	mov    %eax,0xc0127748
    shift ^= togglecode[data];
c0101db1:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101db5:	0f b6 80 40 41 12 c0 	movzbl -0x3fedbec0(%eax),%eax
c0101dbc:	0f b6 d0             	movzbl %al,%edx
c0101dbf:	a1 48 77 12 c0       	mov    0xc0127748,%eax
c0101dc4:	31 d0                	xor    %edx,%eax
c0101dc6:	a3 48 77 12 c0       	mov    %eax,0xc0127748

    c = charcode[shift & (CTL | SHIFT)][data];
c0101dcb:	a1 48 77 12 c0       	mov    0xc0127748,%eax
c0101dd0:	83 e0 03             	and    $0x3,%eax
c0101dd3:	8b 14 85 40 45 12 c0 	mov    -0x3fedbac0(,%eax,4),%edx
c0101dda:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101dde:	01 d0                	add    %edx,%eax
c0101de0:	0f b6 00             	movzbl (%eax),%eax
c0101de3:	0f b6 c0             	movzbl %al,%eax
c0101de6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101de9:	a1 48 77 12 c0       	mov    0xc0127748,%eax
c0101dee:	83 e0 08             	and    $0x8,%eax
c0101df1:	85 c0                	test   %eax,%eax
c0101df3:	74 22                	je     c0101e17 <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c0101df5:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101df9:	7e 0c                	jle    c0101e07 <kbd_proc_data+0x13e>
c0101dfb:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101dff:	7f 06                	jg     c0101e07 <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c0101e01:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c0101e05:	eb 10                	jmp    c0101e17 <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c0101e07:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101e0b:	7e 0a                	jle    c0101e17 <kbd_proc_data+0x14e>
c0101e0d:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c0101e11:	7f 04                	jg     c0101e17 <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c0101e13:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c0101e17:	a1 48 77 12 c0       	mov    0xc0127748,%eax
c0101e1c:	f7 d0                	not    %eax
c0101e1e:	83 e0 06             	and    $0x6,%eax
c0101e21:	85 c0                	test   %eax,%eax
c0101e23:	75 28                	jne    c0101e4d <kbd_proc_data+0x184>
c0101e25:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101e2c:	75 1f                	jne    c0101e4d <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
c0101e2e:	c7 04 24 99 a2 10 c0 	movl   $0xc010a299,(%esp)
c0101e35:	e8 6f e4 ff ff       	call   c01002a9 <cprintf>
c0101e3a:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c0101e40:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101e44:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c0101e48:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c0101e4c:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c0101e4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101e50:	c9                   	leave  
c0101e51:	c3                   	ret    

c0101e52 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c0101e52:	55                   	push   %ebp
c0101e53:	89 e5                	mov    %esp,%ebp
c0101e55:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c0101e58:	c7 04 24 c9 1c 10 c0 	movl   $0xc0101cc9,(%esp)
c0101e5f:	e8 a6 fd ff ff       	call   c0101c0a <cons_intr>
}
c0101e64:	c9                   	leave  
c0101e65:	c3                   	ret    

c0101e66 <kbd_init>:

static void
kbd_init(void) {
c0101e66:	55                   	push   %ebp
c0101e67:	89 e5                	mov    %esp,%ebp
c0101e69:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c0101e6c:	e8 e1 ff ff ff       	call   c0101e52 <kbd_intr>
    pic_enable(IRQ_KBD);
c0101e71:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0101e78:	e8 31 01 00 00       	call   c0101fae <pic_enable>
}
c0101e7d:	c9                   	leave  
c0101e7e:	c3                   	ret    

c0101e7f <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c0101e7f:	55                   	push   %ebp
c0101e80:	89 e5                	mov    %esp,%ebp
c0101e82:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c0101e85:	e8 93 f8 ff ff       	call   c010171d <cga_init>
    serial_init();
c0101e8a:	e8 74 f9 ff ff       	call   c0101803 <serial_init>
    kbd_init();
c0101e8f:	e8 d2 ff ff ff       	call   c0101e66 <kbd_init>
    if (!serial_exists) {
c0101e94:	a1 28 75 12 c0       	mov    0xc0127528,%eax
c0101e99:	85 c0                	test   %eax,%eax
c0101e9b:	75 0c                	jne    c0101ea9 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c0101e9d:	c7 04 24 a5 a2 10 c0 	movl   $0xc010a2a5,(%esp)
c0101ea4:	e8 00 e4 ff ff       	call   c01002a9 <cprintf>
    }
}
c0101ea9:	c9                   	leave  
c0101eaa:	c3                   	ret    

c0101eab <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0101eab:	55                   	push   %ebp
c0101eac:	89 e5                	mov    %esp,%ebp
c0101eae:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0101eb1:	e8 e2 f7 ff ff       	call   c0101698 <__intr_save>
c0101eb6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101eb9:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ebc:	89 04 24             	mov    %eax,(%esp)
c0101ebf:	e8 9b fa ff ff       	call   c010195f <lpt_putc>
        cga_putc(c);
c0101ec4:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ec7:	89 04 24             	mov    %eax,(%esp)
c0101eca:	e8 cf fa ff ff       	call   c010199e <cga_putc>
        serial_putc(c);
c0101ecf:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ed2:	89 04 24             	mov    %eax,(%esp)
c0101ed5:	e8 f1 fc ff ff       	call   c0101bcb <serial_putc>
    }
    local_intr_restore(intr_flag);
c0101eda:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101edd:	89 04 24             	mov    %eax,(%esp)
c0101ee0:	e8 dd f7 ff ff       	call   c01016c2 <__intr_restore>
}
c0101ee5:	c9                   	leave  
c0101ee6:	c3                   	ret    

c0101ee7 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0101ee7:	55                   	push   %ebp
c0101ee8:	89 e5                	mov    %esp,%ebp
c0101eea:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c0101eed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0101ef4:	e8 9f f7 ff ff       	call   c0101698 <__intr_save>
c0101ef9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101efc:	e8 ab fd ff ff       	call   c0101cac <serial_intr>
        kbd_intr();
c0101f01:	e8 4c ff ff ff       	call   c0101e52 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0101f06:	8b 15 40 77 12 c0    	mov    0xc0127740,%edx
c0101f0c:	a1 44 77 12 c0       	mov    0xc0127744,%eax
c0101f11:	39 c2                	cmp    %eax,%edx
c0101f13:	74 31                	je     c0101f46 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c0101f15:	a1 40 77 12 c0       	mov    0xc0127740,%eax
c0101f1a:	8d 50 01             	lea    0x1(%eax),%edx
c0101f1d:	89 15 40 77 12 c0    	mov    %edx,0xc0127740
c0101f23:	0f b6 80 40 75 12 c0 	movzbl -0x3fed8ac0(%eax),%eax
c0101f2a:	0f b6 c0             	movzbl %al,%eax
c0101f2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c0101f30:	a1 40 77 12 c0       	mov    0xc0127740,%eax
c0101f35:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101f3a:	75 0a                	jne    c0101f46 <cons_getc+0x5f>
                cons.rpos = 0;
c0101f3c:	c7 05 40 77 12 c0 00 	movl   $0x0,0xc0127740
c0101f43:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c0101f46:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101f49:	89 04 24             	mov    %eax,(%esp)
c0101f4c:	e8 71 f7 ff ff       	call   c01016c2 <__intr_restore>
    return c;
c0101f51:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101f54:	c9                   	leave  
c0101f55:	c3                   	ret    

c0101f56 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c0101f56:	55                   	push   %ebp
c0101f57:	89 e5                	mov    %esp,%ebp
c0101f59:	83 ec 14             	sub    $0x14,%esp
c0101f5c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f5f:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c0101f63:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101f67:	66 a3 50 45 12 c0    	mov    %ax,0xc0124550
    if (did_init) {
c0101f6d:	a1 4c 77 12 c0       	mov    0xc012774c,%eax
c0101f72:	85 c0                	test   %eax,%eax
c0101f74:	74 36                	je     c0101fac <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c0101f76:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101f7a:	0f b6 c0             	movzbl %al,%eax
c0101f7d:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0101f83:	88 45 fd             	mov    %al,-0x3(%ebp)
c0101f86:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101f8a:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101f8e:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c0101f8f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101f93:	66 c1 e8 08          	shr    $0x8,%ax
c0101f97:	0f b6 c0             	movzbl %al,%eax
c0101f9a:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c0101fa0:	88 45 f9             	mov    %al,-0x7(%ebp)
c0101fa3:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101fa7:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101fab:	ee                   	out    %al,(%dx)
    }
}
c0101fac:	c9                   	leave  
c0101fad:	c3                   	ret    

c0101fae <pic_enable>:

void
pic_enable(unsigned int irq) {
c0101fae:	55                   	push   %ebp
c0101faf:	89 e5                	mov    %esp,%ebp
c0101fb1:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c0101fb4:	8b 45 08             	mov    0x8(%ebp),%eax
c0101fb7:	ba 01 00 00 00       	mov    $0x1,%edx
c0101fbc:	89 c1                	mov    %eax,%ecx
c0101fbe:	d3 e2                	shl    %cl,%edx
c0101fc0:	89 d0                	mov    %edx,%eax
c0101fc2:	f7 d0                	not    %eax
c0101fc4:	89 c2                	mov    %eax,%edx
c0101fc6:	0f b7 05 50 45 12 c0 	movzwl 0xc0124550,%eax
c0101fcd:	21 d0                	and    %edx,%eax
c0101fcf:	0f b7 c0             	movzwl %ax,%eax
c0101fd2:	89 04 24             	mov    %eax,(%esp)
c0101fd5:	e8 7c ff ff ff       	call   c0101f56 <pic_setmask>
}
c0101fda:	c9                   	leave  
c0101fdb:	c3                   	ret    

c0101fdc <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0101fdc:	55                   	push   %ebp
c0101fdd:	89 e5                	mov    %esp,%ebp
c0101fdf:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c0101fe2:	c7 05 4c 77 12 c0 01 	movl   $0x1,0xc012774c
c0101fe9:	00 00 00 
c0101fec:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0101ff2:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
c0101ff6:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101ffa:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101ffe:	ee                   	out    %al,(%dx)
c0101fff:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c0102005:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
c0102009:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010200d:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0102011:	ee                   	out    %al,(%dx)
c0102012:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c0102018:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
c010201c:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0102020:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0102024:	ee                   	out    %al,(%dx)
c0102025:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
c010202b:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
c010202f:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0102033:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102037:	ee                   	out    %al,(%dx)
c0102038:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
c010203e:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
c0102042:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0102046:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010204a:	ee                   	out    %al,(%dx)
c010204b:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
c0102051:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
c0102055:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0102059:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010205d:	ee                   	out    %al,(%dx)
c010205e:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c0102064:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
c0102068:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c010206c:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0102070:	ee                   	out    %al,(%dx)
c0102071:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
c0102077:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
c010207b:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c010207f:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0102083:	ee                   	out    %al,(%dx)
c0102084:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
c010208a:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
c010208e:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0102092:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0102096:	ee                   	out    %al,(%dx)
c0102097:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
c010209d:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
c01020a1:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01020a5:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c01020a9:	ee                   	out    %al,(%dx)
c01020aa:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
c01020b0:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
c01020b4:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c01020b8:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c01020bc:	ee                   	out    %al,(%dx)
c01020bd:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c01020c3:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
c01020c7:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c01020cb:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c01020cf:	ee                   	out    %al,(%dx)
c01020d0:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
c01020d6:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
c01020da:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c01020de:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c01020e2:	ee                   	out    %al,(%dx)
c01020e3:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
c01020e9:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
c01020ed:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c01020f1:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c01020f5:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c01020f6:	0f b7 05 50 45 12 c0 	movzwl 0xc0124550,%eax
c01020fd:	66 83 f8 ff          	cmp    $0xffff,%ax
c0102101:	74 12                	je     c0102115 <pic_init+0x139>
        pic_setmask(irq_mask);
c0102103:	0f b7 05 50 45 12 c0 	movzwl 0xc0124550,%eax
c010210a:	0f b7 c0             	movzwl %ax,%eax
c010210d:	89 04 24             	mov    %eax,(%esp)
c0102110:	e8 41 fe ff ff       	call   c0101f56 <pic_setmask>
    }
}
c0102115:	c9                   	leave  
c0102116:	c3                   	ret    

c0102117 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c0102117:	55                   	push   %ebp
c0102118:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
c010211a:	fb                   	sti    
    sti();
}
c010211b:	5d                   	pop    %ebp
c010211c:	c3                   	ret    

c010211d <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c010211d:	55                   	push   %ebp
c010211e:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
c0102120:	fa                   	cli    
    cli();
}
c0102121:	5d                   	pop    %ebp
c0102122:	c3                   	ret    

c0102123 <print_ticks>:
#include <swap.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c0102123:	55                   	push   %ebp
c0102124:	89 e5                	mov    %esp,%ebp
c0102126:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c0102129:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0102130:	00 
c0102131:	c7 04 24 e0 a2 10 c0 	movl   $0xc010a2e0,(%esp)
c0102138:	e8 6c e1 ff ff       	call   c01002a9 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
c010213d:	c7 04 24 ea a2 10 c0 	movl   $0xc010a2ea,(%esp)
c0102144:	e8 60 e1 ff ff       	call   c01002a9 <cprintf>
    panic("EOT: kernel seems ok.");
c0102149:	c7 44 24 08 f8 a2 10 	movl   $0xc010a2f8,0x8(%esp)
c0102150:	c0 
c0102151:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c0102158:	00 
c0102159:	c7 04 24 0e a3 10 c0 	movl   $0xc010a30e,(%esp)
c0102160:	e8 9b e2 ff ff       	call   c0100400 <__panic>

c0102165 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c0102165:	55                   	push   %ebp
c0102166:	89 e5                	mov    %esp,%ebp
c0102168:	83 ec 10             	sub    $0x10,%esp
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];  //保存在vectors.S中的256个中断处理例程的入口地址数组
    int i;
    //使用SETGATE宏，初始化IDT每个表项
    for (i = 0; i < 256; i ++) 
c010216b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0102172:	e9 c3 00 00 00       	jmp    c010223a <idt_init+0xd5>
    { 
    //在中断门描述符表中通过建立中断门描述符，其中存储了中断处理例程的代码段GD_KTEXT和偏移量__vectors[i]
    //特权级为DPL_KERNEL, 通过查询idt[i]就可定位到中断服务例程的起始地址。
     SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c0102177:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010217a:	8b 04 85 e0 45 12 c0 	mov    -0x3fedba20(,%eax,4),%eax
c0102181:	89 c2                	mov    %eax,%edx
c0102183:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102186:	66 89 14 c5 60 77 12 	mov    %dx,-0x3fed88a0(,%eax,8)
c010218d:	c0 
c010218e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102191:	66 c7 04 c5 62 77 12 	movw   $0x8,-0x3fed889e(,%eax,8)
c0102198:	c0 08 00 
c010219b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010219e:	0f b6 14 c5 64 77 12 	movzbl -0x3fed889c(,%eax,8),%edx
c01021a5:	c0 
c01021a6:	83 e2 e0             	and    $0xffffffe0,%edx
c01021a9:	88 14 c5 64 77 12 c0 	mov    %dl,-0x3fed889c(,%eax,8)
c01021b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021b3:	0f b6 14 c5 64 77 12 	movzbl -0x3fed889c(,%eax,8),%edx
c01021ba:	c0 
c01021bb:	83 e2 1f             	and    $0x1f,%edx
c01021be:	88 14 c5 64 77 12 c0 	mov    %dl,-0x3fed889c(,%eax,8)
c01021c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021c8:	0f b6 14 c5 65 77 12 	movzbl -0x3fed889b(,%eax,8),%edx
c01021cf:	c0 
c01021d0:	83 e2 f0             	and    $0xfffffff0,%edx
c01021d3:	83 ca 0e             	or     $0xe,%edx
c01021d6:	88 14 c5 65 77 12 c0 	mov    %dl,-0x3fed889b(,%eax,8)
c01021dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021e0:	0f b6 14 c5 65 77 12 	movzbl -0x3fed889b(,%eax,8),%edx
c01021e7:	c0 
c01021e8:	83 e2 ef             	and    $0xffffffef,%edx
c01021eb:	88 14 c5 65 77 12 c0 	mov    %dl,-0x3fed889b(,%eax,8)
c01021f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021f5:	0f b6 14 c5 65 77 12 	movzbl -0x3fed889b(,%eax,8),%edx
c01021fc:	c0 
c01021fd:	83 e2 9f             	and    $0xffffff9f,%edx
c0102200:	88 14 c5 65 77 12 c0 	mov    %dl,-0x3fed889b(,%eax,8)
c0102207:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010220a:	0f b6 14 c5 65 77 12 	movzbl -0x3fed889b(,%eax,8),%edx
c0102211:	c0 
c0102212:	83 ca 80             	or     $0xffffff80,%edx
c0102215:	88 14 c5 65 77 12 c0 	mov    %dl,-0x3fed889b(,%eax,8)
c010221c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010221f:	8b 04 85 e0 45 12 c0 	mov    -0x3fedba20(,%eax,4),%eax
c0102226:	c1 e8 10             	shr    $0x10,%eax
c0102229:	89 c2                	mov    %eax,%edx
c010222b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010222e:	66 89 14 c5 66 77 12 	mov    %dx,-0x3fed889a(,%eax,8)
c0102235:	c0 
    for (i = 0; i < 256; i ++) 
c0102236:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010223a:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
c0102241:	0f 8e 30 ff ff ff    	jle    c0102177 <idt_init+0x12>
    }
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT,__vectors[T_SWITCH_TOK], DPL_USER);
c0102247:	a1 c4 47 12 c0       	mov    0xc01247c4,%eax
c010224c:	66 a3 28 7b 12 c0    	mov    %ax,0xc0127b28
c0102252:	66 c7 05 2a 7b 12 c0 	movw   $0x8,0xc0127b2a
c0102259:	08 00 
c010225b:	0f b6 05 2c 7b 12 c0 	movzbl 0xc0127b2c,%eax
c0102262:	83 e0 e0             	and    $0xffffffe0,%eax
c0102265:	a2 2c 7b 12 c0       	mov    %al,0xc0127b2c
c010226a:	0f b6 05 2c 7b 12 c0 	movzbl 0xc0127b2c,%eax
c0102271:	83 e0 1f             	and    $0x1f,%eax
c0102274:	a2 2c 7b 12 c0       	mov    %al,0xc0127b2c
c0102279:	0f b6 05 2d 7b 12 c0 	movzbl 0xc0127b2d,%eax
c0102280:	83 e0 f0             	and    $0xfffffff0,%eax
c0102283:	83 c8 0e             	or     $0xe,%eax
c0102286:	a2 2d 7b 12 c0       	mov    %al,0xc0127b2d
c010228b:	0f b6 05 2d 7b 12 c0 	movzbl 0xc0127b2d,%eax
c0102292:	83 e0 ef             	and    $0xffffffef,%eax
c0102295:	a2 2d 7b 12 c0       	mov    %al,0xc0127b2d
c010229a:	0f b6 05 2d 7b 12 c0 	movzbl 0xc0127b2d,%eax
c01022a1:	83 c8 60             	or     $0x60,%eax
c01022a4:	a2 2d 7b 12 c0       	mov    %al,0xc0127b2d
c01022a9:	0f b6 05 2d 7b 12 c0 	movzbl 0xc0127b2d,%eax
c01022b0:	83 c8 80             	or     $0xffffff80,%eax
c01022b3:	a2 2d 7b 12 c0       	mov    %al,0xc0127b2d
c01022b8:	a1 c4 47 12 c0       	mov    0xc01247c4,%eax
c01022bd:	c1 e8 10             	shr    $0x10,%eax
c01022c0:	66 a3 2e 7b 12 c0    	mov    %ax,0xc0127b2e
c01022c6:	c7 45 f8 60 45 12 c0 	movl   $0xc0124560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c01022cd:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01022d0:	0f 01 18             	lidtl  (%eax)
     //指令lidt把中断门描述符表的起始地址装入IDTR寄存器
    lidt(&idt_pd);
}
c01022d3:	c9                   	leave  
c01022d4:	c3                   	ret    

c01022d5 <trapname>:

static const char *
trapname(int trapno) {
c01022d5:	55                   	push   %ebp
c01022d6:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c01022d8:	8b 45 08             	mov    0x8(%ebp),%eax
c01022db:	83 f8 13             	cmp    $0x13,%eax
c01022de:	77 0c                	ja     c01022ec <trapname+0x17>
        return excnames[trapno];
c01022e0:	8b 45 08             	mov    0x8(%ebp),%eax
c01022e3:	8b 04 85 e0 a6 10 c0 	mov    -0x3fef5920(,%eax,4),%eax
c01022ea:	eb 18                	jmp    c0102304 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c01022ec:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c01022f0:	7e 0d                	jle    c01022ff <trapname+0x2a>
c01022f2:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c01022f6:	7f 07                	jg     c01022ff <trapname+0x2a>
        return "Hardware Interrupt";
c01022f8:	b8 1f a3 10 c0       	mov    $0xc010a31f,%eax
c01022fd:	eb 05                	jmp    c0102304 <trapname+0x2f>
    }
    return "(unknown trap)";
c01022ff:	b8 32 a3 10 c0       	mov    $0xc010a332,%eax
}
c0102304:	5d                   	pop    %ebp
c0102305:	c3                   	ret    

c0102306 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c0102306:	55                   	push   %ebp
c0102307:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c0102309:	8b 45 08             	mov    0x8(%ebp),%eax
c010230c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102310:	66 83 f8 08          	cmp    $0x8,%ax
c0102314:	0f 94 c0             	sete   %al
c0102317:	0f b6 c0             	movzbl %al,%eax
}
c010231a:	5d                   	pop    %ebp
c010231b:	c3                   	ret    

c010231c <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c010231c:	55                   	push   %ebp
c010231d:	89 e5                	mov    %esp,%ebp
c010231f:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c0102322:	8b 45 08             	mov    0x8(%ebp),%eax
c0102325:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102329:	c7 04 24 73 a3 10 c0 	movl   $0xc010a373,(%esp)
c0102330:	e8 74 df ff ff       	call   c01002a9 <cprintf>
    print_regs(&tf->tf_regs);
c0102335:	8b 45 08             	mov    0x8(%ebp),%eax
c0102338:	89 04 24             	mov    %eax,(%esp)
c010233b:	e8 a1 01 00 00       	call   c01024e1 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0102340:	8b 45 08             	mov    0x8(%ebp),%eax
c0102343:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0102347:	0f b7 c0             	movzwl %ax,%eax
c010234a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010234e:	c7 04 24 84 a3 10 c0 	movl   $0xc010a384,(%esp)
c0102355:	e8 4f df ff ff       	call   c01002a9 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c010235a:	8b 45 08             	mov    0x8(%ebp),%eax
c010235d:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0102361:	0f b7 c0             	movzwl %ax,%eax
c0102364:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102368:	c7 04 24 97 a3 10 c0 	movl   $0xc010a397,(%esp)
c010236f:	e8 35 df ff ff       	call   c01002a9 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0102374:	8b 45 08             	mov    0x8(%ebp),%eax
c0102377:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c010237b:	0f b7 c0             	movzwl %ax,%eax
c010237e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102382:	c7 04 24 aa a3 10 c0 	movl   $0xc010a3aa,(%esp)
c0102389:	e8 1b df ff ff       	call   c01002a9 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c010238e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102391:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0102395:	0f b7 c0             	movzwl %ax,%eax
c0102398:	89 44 24 04          	mov    %eax,0x4(%esp)
c010239c:	c7 04 24 bd a3 10 c0 	movl   $0xc010a3bd,(%esp)
c01023a3:	e8 01 df ff ff       	call   c01002a9 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c01023a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01023ab:	8b 40 30             	mov    0x30(%eax),%eax
c01023ae:	89 04 24             	mov    %eax,(%esp)
c01023b1:	e8 1f ff ff ff       	call   c01022d5 <trapname>
c01023b6:	8b 55 08             	mov    0x8(%ebp),%edx
c01023b9:	8b 52 30             	mov    0x30(%edx),%edx
c01023bc:	89 44 24 08          	mov    %eax,0x8(%esp)
c01023c0:	89 54 24 04          	mov    %edx,0x4(%esp)
c01023c4:	c7 04 24 d0 a3 10 c0 	movl   $0xc010a3d0,(%esp)
c01023cb:	e8 d9 de ff ff       	call   c01002a9 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c01023d0:	8b 45 08             	mov    0x8(%ebp),%eax
c01023d3:	8b 40 34             	mov    0x34(%eax),%eax
c01023d6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023da:	c7 04 24 e2 a3 10 c0 	movl   $0xc010a3e2,(%esp)
c01023e1:	e8 c3 de ff ff       	call   c01002a9 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c01023e6:	8b 45 08             	mov    0x8(%ebp),%eax
c01023e9:	8b 40 38             	mov    0x38(%eax),%eax
c01023ec:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023f0:	c7 04 24 f1 a3 10 c0 	movl   $0xc010a3f1,(%esp)
c01023f7:	e8 ad de ff ff       	call   c01002a9 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c01023fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01023ff:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102403:	0f b7 c0             	movzwl %ax,%eax
c0102406:	89 44 24 04          	mov    %eax,0x4(%esp)
c010240a:	c7 04 24 00 a4 10 c0 	movl   $0xc010a400,(%esp)
c0102411:	e8 93 de ff ff       	call   c01002a9 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0102416:	8b 45 08             	mov    0x8(%ebp),%eax
c0102419:	8b 40 40             	mov    0x40(%eax),%eax
c010241c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102420:	c7 04 24 13 a4 10 c0 	movl   $0xc010a413,(%esp)
c0102427:	e8 7d de ff ff       	call   c01002a9 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c010242c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0102433:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c010243a:	eb 3e                	jmp    c010247a <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c010243c:	8b 45 08             	mov    0x8(%ebp),%eax
c010243f:	8b 50 40             	mov    0x40(%eax),%edx
c0102442:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102445:	21 d0                	and    %edx,%eax
c0102447:	85 c0                	test   %eax,%eax
c0102449:	74 28                	je     c0102473 <print_trapframe+0x157>
c010244b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010244e:	8b 04 85 80 45 12 c0 	mov    -0x3fedba80(,%eax,4),%eax
c0102455:	85 c0                	test   %eax,%eax
c0102457:	74 1a                	je     c0102473 <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
c0102459:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010245c:	8b 04 85 80 45 12 c0 	mov    -0x3fedba80(,%eax,4),%eax
c0102463:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102467:	c7 04 24 22 a4 10 c0 	movl   $0xc010a422,(%esp)
c010246e:	e8 36 de ff ff       	call   c01002a9 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0102473:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0102477:	d1 65 f0             	shll   -0x10(%ebp)
c010247a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010247d:	83 f8 17             	cmp    $0x17,%eax
c0102480:	76 ba                	jbe    c010243c <print_trapframe+0x120>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0102482:	8b 45 08             	mov    0x8(%ebp),%eax
c0102485:	8b 40 40             	mov    0x40(%eax),%eax
c0102488:	25 00 30 00 00       	and    $0x3000,%eax
c010248d:	c1 e8 0c             	shr    $0xc,%eax
c0102490:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102494:	c7 04 24 26 a4 10 c0 	movl   $0xc010a426,(%esp)
c010249b:	e8 09 de ff ff       	call   c01002a9 <cprintf>

    if (!trap_in_kernel(tf)) {
c01024a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01024a3:	89 04 24             	mov    %eax,(%esp)
c01024a6:	e8 5b fe ff ff       	call   c0102306 <trap_in_kernel>
c01024ab:	85 c0                	test   %eax,%eax
c01024ad:	75 30                	jne    c01024df <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c01024af:	8b 45 08             	mov    0x8(%ebp),%eax
c01024b2:	8b 40 44             	mov    0x44(%eax),%eax
c01024b5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024b9:	c7 04 24 2f a4 10 c0 	movl   $0xc010a42f,(%esp)
c01024c0:	e8 e4 dd ff ff       	call   c01002a9 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c01024c5:	8b 45 08             	mov    0x8(%ebp),%eax
c01024c8:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c01024cc:	0f b7 c0             	movzwl %ax,%eax
c01024cf:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024d3:	c7 04 24 3e a4 10 c0 	movl   $0xc010a43e,(%esp)
c01024da:	e8 ca dd ff ff       	call   c01002a9 <cprintf>
    }
}
c01024df:	c9                   	leave  
c01024e0:	c3                   	ret    

c01024e1 <print_regs>:

void
print_regs(struct pushregs *regs) {
c01024e1:	55                   	push   %ebp
c01024e2:	89 e5                	mov    %esp,%ebp
c01024e4:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c01024e7:	8b 45 08             	mov    0x8(%ebp),%eax
c01024ea:	8b 00                	mov    (%eax),%eax
c01024ec:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024f0:	c7 04 24 51 a4 10 c0 	movl   $0xc010a451,(%esp)
c01024f7:	e8 ad dd ff ff       	call   c01002a9 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c01024fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01024ff:	8b 40 04             	mov    0x4(%eax),%eax
c0102502:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102506:	c7 04 24 60 a4 10 c0 	movl   $0xc010a460,(%esp)
c010250d:	e8 97 dd ff ff       	call   c01002a9 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0102512:	8b 45 08             	mov    0x8(%ebp),%eax
c0102515:	8b 40 08             	mov    0x8(%eax),%eax
c0102518:	89 44 24 04          	mov    %eax,0x4(%esp)
c010251c:	c7 04 24 6f a4 10 c0 	movl   $0xc010a46f,(%esp)
c0102523:	e8 81 dd ff ff       	call   c01002a9 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0102528:	8b 45 08             	mov    0x8(%ebp),%eax
c010252b:	8b 40 0c             	mov    0xc(%eax),%eax
c010252e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102532:	c7 04 24 7e a4 10 c0 	movl   $0xc010a47e,(%esp)
c0102539:	e8 6b dd ff ff       	call   c01002a9 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c010253e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102541:	8b 40 10             	mov    0x10(%eax),%eax
c0102544:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102548:	c7 04 24 8d a4 10 c0 	movl   $0xc010a48d,(%esp)
c010254f:	e8 55 dd ff ff       	call   c01002a9 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0102554:	8b 45 08             	mov    0x8(%ebp),%eax
c0102557:	8b 40 14             	mov    0x14(%eax),%eax
c010255a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010255e:	c7 04 24 9c a4 10 c0 	movl   $0xc010a49c,(%esp)
c0102565:	e8 3f dd ff ff       	call   c01002a9 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c010256a:	8b 45 08             	mov    0x8(%ebp),%eax
c010256d:	8b 40 18             	mov    0x18(%eax),%eax
c0102570:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102574:	c7 04 24 ab a4 10 c0 	movl   $0xc010a4ab,(%esp)
c010257b:	e8 29 dd ff ff       	call   c01002a9 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0102580:	8b 45 08             	mov    0x8(%ebp),%eax
c0102583:	8b 40 1c             	mov    0x1c(%eax),%eax
c0102586:	89 44 24 04          	mov    %eax,0x4(%esp)
c010258a:	c7 04 24 ba a4 10 c0 	movl   $0xc010a4ba,(%esp)
c0102591:	e8 13 dd ff ff       	call   c01002a9 <cprintf>
}
c0102596:	c9                   	leave  
c0102597:	c3                   	ret    

c0102598 <print_pgfault>:

static inline void
print_pgfault(struct trapframe *tf) {
c0102598:	55                   	push   %ebp
c0102599:	89 e5                	mov    %esp,%ebp
c010259b:	53                   	push   %ebx
c010259c:	83 ec 34             	sub    $0x34,%esp
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
c010259f:	8b 45 08             	mov    0x8(%ebp),%eax
c01025a2:	8b 40 34             	mov    0x34(%eax),%eax
c01025a5:	83 e0 01             	and    $0x1,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c01025a8:	85 c0                	test   %eax,%eax
c01025aa:	74 07                	je     c01025b3 <print_pgfault+0x1b>
c01025ac:	b9 c9 a4 10 c0       	mov    $0xc010a4c9,%ecx
c01025b1:	eb 05                	jmp    c01025b8 <print_pgfault+0x20>
c01025b3:	b9 da a4 10 c0       	mov    $0xc010a4da,%ecx
            (tf->tf_err & 2) ? 'W' : 'R',
c01025b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01025bb:	8b 40 34             	mov    0x34(%eax),%eax
c01025be:	83 e0 02             	and    $0x2,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c01025c1:	85 c0                	test   %eax,%eax
c01025c3:	74 07                	je     c01025cc <print_pgfault+0x34>
c01025c5:	ba 57 00 00 00       	mov    $0x57,%edx
c01025ca:	eb 05                	jmp    c01025d1 <print_pgfault+0x39>
c01025cc:	ba 52 00 00 00       	mov    $0x52,%edx
            (tf->tf_err & 4) ? 'U' : 'K',
c01025d1:	8b 45 08             	mov    0x8(%ebp),%eax
c01025d4:	8b 40 34             	mov    0x34(%eax),%eax
c01025d7:	83 e0 04             	and    $0x4,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c01025da:	85 c0                	test   %eax,%eax
c01025dc:	74 07                	je     c01025e5 <print_pgfault+0x4d>
c01025de:	b8 55 00 00 00       	mov    $0x55,%eax
c01025e3:	eb 05                	jmp    c01025ea <print_pgfault+0x52>
c01025e5:	b8 4b 00 00 00       	mov    $0x4b,%eax
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c01025ea:	0f 20 d3             	mov    %cr2,%ebx
c01025ed:	89 5d f4             	mov    %ebx,-0xc(%ebp)
    return cr2;
c01025f0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
c01025f3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c01025f7:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01025fb:	89 44 24 08          	mov    %eax,0x8(%esp)
c01025ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0102603:	c7 04 24 e8 a4 10 c0 	movl   $0xc010a4e8,(%esp)
c010260a:	e8 9a dc ff ff       	call   c01002a9 <cprintf>
}
c010260f:	83 c4 34             	add    $0x34,%esp
c0102612:	5b                   	pop    %ebx
c0102613:	5d                   	pop    %ebp
c0102614:	c3                   	ret    

c0102615 <pgfault_handler>:

static int
pgfault_handler(struct trapframe *tf) {
c0102615:	55                   	push   %ebp
c0102616:	89 e5                	mov    %esp,%ebp
c0102618:	83 ec 28             	sub    $0x28,%esp
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
c010261b:	8b 45 08             	mov    0x8(%ebp),%eax
c010261e:	89 04 24             	mov    %eax,(%esp)
c0102621:	e8 72 ff ff ff       	call   c0102598 <print_pgfault>
    if (check_mm_struct != NULL) {
c0102626:	a1 58 a0 12 c0       	mov    0xc012a058,%eax
c010262b:	85 c0                	test   %eax,%eax
c010262d:	74 28                	je     c0102657 <pgfault_handler+0x42>
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c010262f:	0f 20 d0             	mov    %cr2,%eax
c0102632:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c0102635:	8b 45 f4             	mov    -0xc(%ebp),%eax
        return do_pgfault(check_mm_struct, tf->tf_err, rcr2());
c0102638:	89 c1                	mov    %eax,%ecx
c010263a:	8b 45 08             	mov    0x8(%ebp),%eax
c010263d:	8b 50 34             	mov    0x34(%eax),%edx
c0102640:	a1 58 a0 12 c0       	mov    0xc012a058,%eax
c0102645:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0102649:	89 54 24 04          	mov    %edx,0x4(%esp)
c010264d:	89 04 24             	mov    %eax,(%esp)
c0102650:	e8 63 17 00 00       	call   c0103db8 <do_pgfault>
c0102655:	eb 1c                	jmp    c0102673 <pgfault_handler+0x5e>
    }
    panic("unhandled page fault.\n");
c0102657:	c7 44 24 08 0b a5 10 	movl   $0xc010a50b,0x8(%esp)
c010265e:	c0 
c010265f:	c7 44 24 04 ab 00 00 	movl   $0xab,0x4(%esp)
c0102666:	00 
c0102667:	c7 04 24 0e a3 10 c0 	movl   $0xc010a30e,(%esp)
c010266e:	e8 8d dd ff ff       	call   c0100400 <__panic>
}
c0102673:	c9                   	leave  
c0102674:	c3                   	ret    

c0102675 <trap_dispatch>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

static void
trap_dispatch(struct trapframe *tf) {
c0102675:	55                   	push   %ebp
c0102676:	89 e5                	mov    %esp,%ebp
c0102678:	83 ec 28             	sub    $0x28,%esp
    char c;

    int ret;

    switch (tf->tf_trapno) {
c010267b:	8b 45 08             	mov    0x8(%ebp),%eax
c010267e:	8b 40 30             	mov    0x30(%eax),%eax
c0102681:	83 f8 24             	cmp    $0x24,%eax
c0102684:	0f 84 c9 00 00 00    	je     c0102753 <trap_dispatch+0xde>
c010268a:	83 f8 24             	cmp    $0x24,%eax
c010268d:	77 18                	ja     c01026a7 <trap_dispatch+0x32>
c010268f:	83 f8 20             	cmp    $0x20,%eax
c0102692:	74 7d                	je     c0102711 <trap_dispatch+0x9c>
c0102694:	83 f8 21             	cmp    $0x21,%eax
c0102697:	0f 84 dc 00 00 00    	je     c0102779 <trap_dispatch+0x104>
c010269d:	83 f8 0e             	cmp    $0xe,%eax
c01026a0:	74 28                	je     c01026ca <trap_dispatch+0x55>
c01026a2:	e9 14 01 00 00       	jmp    c01027bb <trap_dispatch+0x146>
c01026a7:	83 f8 2e             	cmp    $0x2e,%eax
c01026aa:	0f 82 0b 01 00 00    	jb     c01027bb <trap_dispatch+0x146>
c01026b0:	83 f8 2f             	cmp    $0x2f,%eax
c01026b3:	0f 86 3a 01 00 00    	jbe    c01027f3 <trap_dispatch+0x17e>
c01026b9:	83 e8 78             	sub    $0x78,%eax
c01026bc:	83 f8 01             	cmp    $0x1,%eax
c01026bf:	0f 87 f6 00 00 00    	ja     c01027bb <trap_dispatch+0x146>
c01026c5:	e9 d5 00 00 00       	jmp    c010279f <trap_dispatch+0x12a>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
c01026ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01026cd:	89 04 24             	mov    %eax,(%esp)
c01026d0:	e8 40 ff ff ff       	call   c0102615 <pgfault_handler>
c01026d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01026d8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01026dc:	74 2e                	je     c010270c <trap_dispatch+0x97>
            print_trapframe(tf);
c01026de:	8b 45 08             	mov    0x8(%ebp),%eax
c01026e1:	89 04 24             	mov    %eax,(%esp)
c01026e4:	e8 33 fc ff ff       	call   c010231c <print_trapframe>
            panic("handle pgfault failed. %e\n", ret);
c01026e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01026ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01026f0:	c7 44 24 08 22 a5 10 	movl   $0xc010a522,0x8(%esp)
c01026f7:	c0 
c01026f8:	c7 44 24 04 bb 00 00 	movl   $0xbb,0x4(%esp)
c01026ff:	00 
c0102700:	c7 04 24 0e a3 10 c0 	movl   $0xc010a30e,(%esp)
c0102707:	e8 f4 dc ff ff       	call   c0100400 <__panic>
        }
        break;
c010270c:	e9 e3 00 00 00       	jmp    c01027f4 <trap_dispatch+0x17f>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
	    if (((++ticks) % TICK_NUM) == 0) {
c0102711:	a1 54 a0 12 c0       	mov    0xc012a054,%eax
c0102716:	83 c0 01             	add    $0x1,%eax
c0102719:	89 c1                	mov    %eax,%ecx
c010271b:	89 0d 54 a0 12 c0    	mov    %ecx,0xc012a054
c0102721:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0102726:	89 c8                	mov    %ecx,%eax
c0102728:	f7 e2                	mul    %edx
c010272a:	89 d0                	mov    %edx,%eax
c010272c:	c1 e8 05             	shr    $0x5,%eax
c010272f:	6b c0 64             	imul   $0x64,%eax,%eax
c0102732:	29 c1                	sub    %eax,%ecx
c0102734:	89 c8                	mov    %ecx,%eax
c0102736:	85 c0                	test   %eax,%eax
c0102738:	75 14                	jne    c010274e <trap_dispatch+0xd9>
		print_ticks();
c010273a:	e8 e4 f9 ff ff       	call   c0102123 <print_ticks>
		ticks = 0;
c010273f:	c7 05 54 a0 12 c0 00 	movl   $0x0,0xc012a054
c0102746:	00 00 00 
        }
        break;
c0102749:	e9 a6 00 00 00       	jmp    c01027f4 <trap_dispatch+0x17f>
c010274e:	e9 a1 00 00 00       	jmp    c01027f4 <trap_dispatch+0x17f>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0102753:	e8 8f f7 ff ff       	call   c0101ee7 <cons_getc>
c0102758:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c010275b:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c010275f:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c0102763:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102767:	89 44 24 04          	mov    %eax,0x4(%esp)
c010276b:	c7 04 24 3d a5 10 c0 	movl   $0xc010a53d,(%esp)
c0102772:	e8 32 db ff ff       	call   c01002a9 <cprintf>
        break;
c0102777:	eb 7b                	jmp    c01027f4 <trap_dispatch+0x17f>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0102779:	e8 69 f7 ff ff       	call   c0101ee7 <cons_getc>
c010277e:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0102781:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c0102785:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c0102789:	89 54 24 08          	mov    %edx,0x8(%esp)
c010278d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102791:	c7 04 24 4f a5 10 c0 	movl   $0xc010a54f,(%esp)
c0102798:	e8 0c db ff ff       	call   c01002a9 <cprintf>
        break;
c010279d:	eb 55                	jmp    c01027f4 <trap_dispatch+0x17f>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c010279f:	c7 44 24 08 5e a5 10 	movl   $0xc010a55e,0x8(%esp)
c01027a6:	c0 
c01027a7:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c01027ae:	00 
c01027af:	c7 04 24 0e a3 10 c0 	movl   $0xc010a30e,(%esp)
c01027b6:	e8 45 dc ff ff       	call   c0100400 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c01027bb:	8b 45 08             	mov    0x8(%ebp),%eax
c01027be:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01027c2:	0f b7 c0             	movzwl %ax,%eax
c01027c5:	83 e0 03             	and    $0x3,%eax
c01027c8:	85 c0                	test   %eax,%eax
c01027ca:	75 28                	jne    c01027f4 <trap_dispatch+0x17f>
            print_trapframe(tf);
c01027cc:	8b 45 08             	mov    0x8(%ebp),%eax
c01027cf:	89 04 24             	mov    %eax,(%esp)
c01027d2:	e8 45 fb ff ff       	call   c010231c <print_trapframe>
            panic("unexpected trap in kernel.\n");
c01027d7:	c7 44 24 08 6e a5 10 	movl   $0xc010a56e,0x8(%esp)
c01027de:	c0 
c01027df:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c01027e6:	00 
c01027e7:	c7 04 24 0e a3 10 c0 	movl   $0xc010a30e,(%esp)
c01027ee:	e8 0d dc ff ff       	call   c0100400 <__panic>
        break;
c01027f3:	90                   	nop
        }
    }
}
c01027f4:	c9                   	leave  
c01027f5:	c3                   	ret    

c01027f6 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c01027f6:	55                   	push   %ebp
c01027f7:	89 e5                	mov    %esp,%ebp
c01027f9:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c01027fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01027ff:	89 04 24             	mov    %eax,(%esp)
c0102802:	e8 6e fe ff ff       	call   c0102675 <trap_dispatch>
}
c0102807:	c9                   	leave  
c0102808:	c3                   	ret    

c0102809 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0102809:	6a 00                	push   $0x0
  pushl $0
c010280b:	6a 00                	push   $0x0
  jmp __alltraps
c010280d:	e9 69 0a 00 00       	jmp    c010327b <__alltraps>

c0102812 <vector1>:
.globl vector1
vector1:
  pushl $0
c0102812:	6a 00                	push   $0x0
  pushl $1
c0102814:	6a 01                	push   $0x1
  jmp __alltraps
c0102816:	e9 60 0a 00 00       	jmp    c010327b <__alltraps>

c010281b <vector2>:
.globl vector2
vector2:
  pushl $0
c010281b:	6a 00                	push   $0x0
  pushl $2
c010281d:	6a 02                	push   $0x2
  jmp __alltraps
c010281f:	e9 57 0a 00 00       	jmp    c010327b <__alltraps>

c0102824 <vector3>:
.globl vector3
vector3:
  pushl $0
c0102824:	6a 00                	push   $0x0
  pushl $3
c0102826:	6a 03                	push   $0x3
  jmp __alltraps
c0102828:	e9 4e 0a 00 00       	jmp    c010327b <__alltraps>

c010282d <vector4>:
.globl vector4
vector4:
  pushl $0
c010282d:	6a 00                	push   $0x0
  pushl $4
c010282f:	6a 04                	push   $0x4
  jmp __alltraps
c0102831:	e9 45 0a 00 00       	jmp    c010327b <__alltraps>

c0102836 <vector5>:
.globl vector5
vector5:
  pushl $0
c0102836:	6a 00                	push   $0x0
  pushl $5
c0102838:	6a 05                	push   $0x5
  jmp __alltraps
c010283a:	e9 3c 0a 00 00       	jmp    c010327b <__alltraps>

c010283f <vector6>:
.globl vector6
vector6:
  pushl $0
c010283f:	6a 00                	push   $0x0
  pushl $6
c0102841:	6a 06                	push   $0x6
  jmp __alltraps
c0102843:	e9 33 0a 00 00       	jmp    c010327b <__alltraps>

c0102848 <vector7>:
.globl vector7
vector7:
  pushl $0
c0102848:	6a 00                	push   $0x0
  pushl $7
c010284a:	6a 07                	push   $0x7
  jmp __alltraps
c010284c:	e9 2a 0a 00 00       	jmp    c010327b <__alltraps>

c0102851 <vector8>:
.globl vector8
vector8:
  pushl $8
c0102851:	6a 08                	push   $0x8
  jmp __alltraps
c0102853:	e9 23 0a 00 00       	jmp    c010327b <__alltraps>

c0102858 <vector9>:
.globl vector9
vector9:
  pushl $0
c0102858:	6a 00                	push   $0x0
  pushl $9
c010285a:	6a 09                	push   $0x9
  jmp __alltraps
c010285c:	e9 1a 0a 00 00       	jmp    c010327b <__alltraps>

c0102861 <vector10>:
.globl vector10
vector10:
  pushl $10
c0102861:	6a 0a                	push   $0xa
  jmp __alltraps
c0102863:	e9 13 0a 00 00       	jmp    c010327b <__alltraps>

c0102868 <vector11>:
.globl vector11
vector11:
  pushl $11
c0102868:	6a 0b                	push   $0xb
  jmp __alltraps
c010286a:	e9 0c 0a 00 00       	jmp    c010327b <__alltraps>

c010286f <vector12>:
.globl vector12
vector12:
  pushl $12
c010286f:	6a 0c                	push   $0xc
  jmp __alltraps
c0102871:	e9 05 0a 00 00       	jmp    c010327b <__alltraps>

c0102876 <vector13>:
.globl vector13
vector13:
  pushl $13
c0102876:	6a 0d                	push   $0xd
  jmp __alltraps
c0102878:	e9 fe 09 00 00       	jmp    c010327b <__alltraps>

c010287d <vector14>:
.globl vector14
vector14:
  pushl $14
c010287d:	6a 0e                	push   $0xe
  jmp __alltraps
c010287f:	e9 f7 09 00 00       	jmp    c010327b <__alltraps>

c0102884 <vector15>:
.globl vector15
vector15:
  pushl $0
c0102884:	6a 00                	push   $0x0
  pushl $15
c0102886:	6a 0f                	push   $0xf
  jmp __alltraps
c0102888:	e9 ee 09 00 00       	jmp    c010327b <__alltraps>

c010288d <vector16>:
.globl vector16
vector16:
  pushl $0
c010288d:	6a 00                	push   $0x0
  pushl $16
c010288f:	6a 10                	push   $0x10
  jmp __alltraps
c0102891:	e9 e5 09 00 00       	jmp    c010327b <__alltraps>

c0102896 <vector17>:
.globl vector17
vector17:
  pushl $17
c0102896:	6a 11                	push   $0x11
  jmp __alltraps
c0102898:	e9 de 09 00 00       	jmp    c010327b <__alltraps>

c010289d <vector18>:
.globl vector18
vector18:
  pushl $0
c010289d:	6a 00                	push   $0x0
  pushl $18
c010289f:	6a 12                	push   $0x12
  jmp __alltraps
c01028a1:	e9 d5 09 00 00       	jmp    c010327b <__alltraps>

c01028a6 <vector19>:
.globl vector19
vector19:
  pushl $0
c01028a6:	6a 00                	push   $0x0
  pushl $19
c01028a8:	6a 13                	push   $0x13
  jmp __alltraps
c01028aa:	e9 cc 09 00 00       	jmp    c010327b <__alltraps>

c01028af <vector20>:
.globl vector20
vector20:
  pushl $0
c01028af:	6a 00                	push   $0x0
  pushl $20
c01028b1:	6a 14                	push   $0x14
  jmp __alltraps
c01028b3:	e9 c3 09 00 00       	jmp    c010327b <__alltraps>

c01028b8 <vector21>:
.globl vector21
vector21:
  pushl $0
c01028b8:	6a 00                	push   $0x0
  pushl $21
c01028ba:	6a 15                	push   $0x15
  jmp __alltraps
c01028bc:	e9 ba 09 00 00       	jmp    c010327b <__alltraps>

c01028c1 <vector22>:
.globl vector22
vector22:
  pushl $0
c01028c1:	6a 00                	push   $0x0
  pushl $22
c01028c3:	6a 16                	push   $0x16
  jmp __alltraps
c01028c5:	e9 b1 09 00 00       	jmp    c010327b <__alltraps>

c01028ca <vector23>:
.globl vector23
vector23:
  pushl $0
c01028ca:	6a 00                	push   $0x0
  pushl $23
c01028cc:	6a 17                	push   $0x17
  jmp __alltraps
c01028ce:	e9 a8 09 00 00       	jmp    c010327b <__alltraps>

c01028d3 <vector24>:
.globl vector24
vector24:
  pushl $0
c01028d3:	6a 00                	push   $0x0
  pushl $24
c01028d5:	6a 18                	push   $0x18
  jmp __alltraps
c01028d7:	e9 9f 09 00 00       	jmp    c010327b <__alltraps>

c01028dc <vector25>:
.globl vector25
vector25:
  pushl $0
c01028dc:	6a 00                	push   $0x0
  pushl $25
c01028de:	6a 19                	push   $0x19
  jmp __alltraps
c01028e0:	e9 96 09 00 00       	jmp    c010327b <__alltraps>

c01028e5 <vector26>:
.globl vector26
vector26:
  pushl $0
c01028e5:	6a 00                	push   $0x0
  pushl $26
c01028e7:	6a 1a                	push   $0x1a
  jmp __alltraps
c01028e9:	e9 8d 09 00 00       	jmp    c010327b <__alltraps>

c01028ee <vector27>:
.globl vector27
vector27:
  pushl $0
c01028ee:	6a 00                	push   $0x0
  pushl $27
c01028f0:	6a 1b                	push   $0x1b
  jmp __alltraps
c01028f2:	e9 84 09 00 00       	jmp    c010327b <__alltraps>

c01028f7 <vector28>:
.globl vector28
vector28:
  pushl $0
c01028f7:	6a 00                	push   $0x0
  pushl $28
c01028f9:	6a 1c                	push   $0x1c
  jmp __alltraps
c01028fb:	e9 7b 09 00 00       	jmp    c010327b <__alltraps>

c0102900 <vector29>:
.globl vector29
vector29:
  pushl $0
c0102900:	6a 00                	push   $0x0
  pushl $29
c0102902:	6a 1d                	push   $0x1d
  jmp __alltraps
c0102904:	e9 72 09 00 00       	jmp    c010327b <__alltraps>

c0102909 <vector30>:
.globl vector30
vector30:
  pushl $0
c0102909:	6a 00                	push   $0x0
  pushl $30
c010290b:	6a 1e                	push   $0x1e
  jmp __alltraps
c010290d:	e9 69 09 00 00       	jmp    c010327b <__alltraps>

c0102912 <vector31>:
.globl vector31
vector31:
  pushl $0
c0102912:	6a 00                	push   $0x0
  pushl $31
c0102914:	6a 1f                	push   $0x1f
  jmp __alltraps
c0102916:	e9 60 09 00 00       	jmp    c010327b <__alltraps>

c010291b <vector32>:
.globl vector32
vector32:
  pushl $0
c010291b:	6a 00                	push   $0x0
  pushl $32
c010291d:	6a 20                	push   $0x20
  jmp __alltraps
c010291f:	e9 57 09 00 00       	jmp    c010327b <__alltraps>

c0102924 <vector33>:
.globl vector33
vector33:
  pushl $0
c0102924:	6a 00                	push   $0x0
  pushl $33
c0102926:	6a 21                	push   $0x21
  jmp __alltraps
c0102928:	e9 4e 09 00 00       	jmp    c010327b <__alltraps>

c010292d <vector34>:
.globl vector34
vector34:
  pushl $0
c010292d:	6a 00                	push   $0x0
  pushl $34
c010292f:	6a 22                	push   $0x22
  jmp __alltraps
c0102931:	e9 45 09 00 00       	jmp    c010327b <__alltraps>

c0102936 <vector35>:
.globl vector35
vector35:
  pushl $0
c0102936:	6a 00                	push   $0x0
  pushl $35
c0102938:	6a 23                	push   $0x23
  jmp __alltraps
c010293a:	e9 3c 09 00 00       	jmp    c010327b <__alltraps>

c010293f <vector36>:
.globl vector36
vector36:
  pushl $0
c010293f:	6a 00                	push   $0x0
  pushl $36
c0102941:	6a 24                	push   $0x24
  jmp __alltraps
c0102943:	e9 33 09 00 00       	jmp    c010327b <__alltraps>

c0102948 <vector37>:
.globl vector37
vector37:
  pushl $0
c0102948:	6a 00                	push   $0x0
  pushl $37
c010294a:	6a 25                	push   $0x25
  jmp __alltraps
c010294c:	e9 2a 09 00 00       	jmp    c010327b <__alltraps>

c0102951 <vector38>:
.globl vector38
vector38:
  pushl $0
c0102951:	6a 00                	push   $0x0
  pushl $38
c0102953:	6a 26                	push   $0x26
  jmp __alltraps
c0102955:	e9 21 09 00 00       	jmp    c010327b <__alltraps>

c010295a <vector39>:
.globl vector39
vector39:
  pushl $0
c010295a:	6a 00                	push   $0x0
  pushl $39
c010295c:	6a 27                	push   $0x27
  jmp __alltraps
c010295e:	e9 18 09 00 00       	jmp    c010327b <__alltraps>

c0102963 <vector40>:
.globl vector40
vector40:
  pushl $0
c0102963:	6a 00                	push   $0x0
  pushl $40
c0102965:	6a 28                	push   $0x28
  jmp __alltraps
c0102967:	e9 0f 09 00 00       	jmp    c010327b <__alltraps>

c010296c <vector41>:
.globl vector41
vector41:
  pushl $0
c010296c:	6a 00                	push   $0x0
  pushl $41
c010296e:	6a 29                	push   $0x29
  jmp __alltraps
c0102970:	e9 06 09 00 00       	jmp    c010327b <__alltraps>

c0102975 <vector42>:
.globl vector42
vector42:
  pushl $0
c0102975:	6a 00                	push   $0x0
  pushl $42
c0102977:	6a 2a                	push   $0x2a
  jmp __alltraps
c0102979:	e9 fd 08 00 00       	jmp    c010327b <__alltraps>

c010297e <vector43>:
.globl vector43
vector43:
  pushl $0
c010297e:	6a 00                	push   $0x0
  pushl $43
c0102980:	6a 2b                	push   $0x2b
  jmp __alltraps
c0102982:	e9 f4 08 00 00       	jmp    c010327b <__alltraps>

c0102987 <vector44>:
.globl vector44
vector44:
  pushl $0
c0102987:	6a 00                	push   $0x0
  pushl $44
c0102989:	6a 2c                	push   $0x2c
  jmp __alltraps
c010298b:	e9 eb 08 00 00       	jmp    c010327b <__alltraps>

c0102990 <vector45>:
.globl vector45
vector45:
  pushl $0
c0102990:	6a 00                	push   $0x0
  pushl $45
c0102992:	6a 2d                	push   $0x2d
  jmp __alltraps
c0102994:	e9 e2 08 00 00       	jmp    c010327b <__alltraps>

c0102999 <vector46>:
.globl vector46
vector46:
  pushl $0
c0102999:	6a 00                	push   $0x0
  pushl $46
c010299b:	6a 2e                	push   $0x2e
  jmp __alltraps
c010299d:	e9 d9 08 00 00       	jmp    c010327b <__alltraps>

c01029a2 <vector47>:
.globl vector47
vector47:
  pushl $0
c01029a2:	6a 00                	push   $0x0
  pushl $47
c01029a4:	6a 2f                	push   $0x2f
  jmp __alltraps
c01029a6:	e9 d0 08 00 00       	jmp    c010327b <__alltraps>

c01029ab <vector48>:
.globl vector48
vector48:
  pushl $0
c01029ab:	6a 00                	push   $0x0
  pushl $48
c01029ad:	6a 30                	push   $0x30
  jmp __alltraps
c01029af:	e9 c7 08 00 00       	jmp    c010327b <__alltraps>

c01029b4 <vector49>:
.globl vector49
vector49:
  pushl $0
c01029b4:	6a 00                	push   $0x0
  pushl $49
c01029b6:	6a 31                	push   $0x31
  jmp __alltraps
c01029b8:	e9 be 08 00 00       	jmp    c010327b <__alltraps>

c01029bd <vector50>:
.globl vector50
vector50:
  pushl $0
c01029bd:	6a 00                	push   $0x0
  pushl $50
c01029bf:	6a 32                	push   $0x32
  jmp __alltraps
c01029c1:	e9 b5 08 00 00       	jmp    c010327b <__alltraps>

c01029c6 <vector51>:
.globl vector51
vector51:
  pushl $0
c01029c6:	6a 00                	push   $0x0
  pushl $51
c01029c8:	6a 33                	push   $0x33
  jmp __alltraps
c01029ca:	e9 ac 08 00 00       	jmp    c010327b <__alltraps>

c01029cf <vector52>:
.globl vector52
vector52:
  pushl $0
c01029cf:	6a 00                	push   $0x0
  pushl $52
c01029d1:	6a 34                	push   $0x34
  jmp __alltraps
c01029d3:	e9 a3 08 00 00       	jmp    c010327b <__alltraps>

c01029d8 <vector53>:
.globl vector53
vector53:
  pushl $0
c01029d8:	6a 00                	push   $0x0
  pushl $53
c01029da:	6a 35                	push   $0x35
  jmp __alltraps
c01029dc:	e9 9a 08 00 00       	jmp    c010327b <__alltraps>

c01029e1 <vector54>:
.globl vector54
vector54:
  pushl $0
c01029e1:	6a 00                	push   $0x0
  pushl $54
c01029e3:	6a 36                	push   $0x36
  jmp __alltraps
c01029e5:	e9 91 08 00 00       	jmp    c010327b <__alltraps>

c01029ea <vector55>:
.globl vector55
vector55:
  pushl $0
c01029ea:	6a 00                	push   $0x0
  pushl $55
c01029ec:	6a 37                	push   $0x37
  jmp __alltraps
c01029ee:	e9 88 08 00 00       	jmp    c010327b <__alltraps>

c01029f3 <vector56>:
.globl vector56
vector56:
  pushl $0
c01029f3:	6a 00                	push   $0x0
  pushl $56
c01029f5:	6a 38                	push   $0x38
  jmp __alltraps
c01029f7:	e9 7f 08 00 00       	jmp    c010327b <__alltraps>

c01029fc <vector57>:
.globl vector57
vector57:
  pushl $0
c01029fc:	6a 00                	push   $0x0
  pushl $57
c01029fe:	6a 39                	push   $0x39
  jmp __alltraps
c0102a00:	e9 76 08 00 00       	jmp    c010327b <__alltraps>

c0102a05 <vector58>:
.globl vector58
vector58:
  pushl $0
c0102a05:	6a 00                	push   $0x0
  pushl $58
c0102a07:	6a 3a                	push   $0x3a
  jmp __alltraps
c0102a09:	e9 6d 08 00 00       	jmp    c010327b <__alltraps>

c0102a0e <vector59>:
.globl vector59
vector59:
  pushl $0
c0102a0e:	6a 00                	push   $0x0
  pushl $59
c0102a10:	6a 3b                	push   $0x3b
  jmp __alltraps
c0102a12:	e9 64 08 00 00       	jmp    c010327b <__alltraps>

c0102a17 <vector60>:
.globl vector60
vector60:
  pushl $0
c0102a17:	6a 00                	push   $0x0
  pushl $60
c0102a19:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102a1b:	e9 5b 08 00 00       	jmp    c010327b <__alltraps>

c0102a20 <vector61>:
.globl vector61
vector61:
  pushl $0
c0102a20:	6a 00                	push   $0x0
  pushl $61
c0102a22:	6a 3d                	push   $0x3d
  jmp __alltraps
c0102a24:	e9 52 08 00 00       	jmp    c010327b <__alltraps>

c0102a29 <vector62>:
.globl vector62
vector62:
  pushl $0
c0102a29:	6a 00                	push   $0x0
  pushl $62
c0102a2b:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102a2d:	e9 49 08 00 00       	jmp    c010327b <__alltraps>

c0102a32 <vector63>:
.globl vector63
vector63:
  pushl $0
c0102a32:	6a 00                	push   $0x0
  pushl $63
c0102a34:	6a 3f                	push   $0x3f
  jmp __alltraps
c0102a36:	e9 40 08 00 00       	jmp    c010327b <__alltraps>

c0102a3b <vector64>:
.globl vector64
vector64:
  pushl $0
c0102a3b:	6a 00                	push   $0x0
  pushl $64
c0102a3d:	6a 40                	push   $0x40
  jmp __alltraps
c0102a3f:	e9 37 08 00 00       	jmp    c010327b <__alltraps>

c0102a44 <vector65>:
.globl vector65
vector65:
  pushl $0
c0102a44:	6a 00                	push   $0x0
  pushl $65
c0102a46:	6a 41                	push   $0x41
  jmp __alltraps
c0102a48:	e9 2e 08 00 00       	jmp    c010327b <__alltraps>

c0102a4d <vector66>:
.globl vector66
vector66:
  pushl $0
c0102a4d:	6a 00                	push   $0x0
  pushl $66
c0102a4f:	6a 42                	push   $0x42
  jmp __alltraps
c0102a51:	e9 25 08 00 00       	jmp    c010327b <__alltraps>

c0102a56 <vector67>:
.globl vector67
vector67:
  pushl $0
c0102a56:	6a 00                	push   $0x0
  pushl $67
c0102a58:	6a 43                	push   $0x43
  jmp __alltraps
c0102a5a:	e9 1c 08 00 00       	jmp    c010327b <__alltraps>

c0102a5f <vector68>:
.globl vector68
vector68:
  pushl $0
c0102a5f:	6a 00                	push   $0x0
  pushl $68
c0102a61:	6a 44                	push   $0x44
  jmp __alltraps
c0102a63:	e9 13 08 00 00       	jmp    c010327b <__alltraps>

c0102a68 <vector69>:
.globl vector69
vector69:
  pushl $0
c0102a68:	6a 00                	push   $0x0
  pushl $69
c0102a6a:	6a 45                	push   $0x45
  jmp __alltraps
c0102a6c:	e9 0a 08 00 00       	jmp    c010327b <__alltraps>

c0102a71 <vector70>:
.globl vector70
vector70:
  pushl $0
c0102a71:	6a 00                	push   $0x0
  pushl $70
c0102a73:	6a 46                	push   $0x46
  jmp __alltraps
c0102a75:	e9 01 08 00 00       	jmp    c010327b <__alltraps>

c0102a7a <vector71>:
.globl vector71
vector71:
  pushl $0
c0102a7a:	6a 00                	push   $0x0
  pushl $71
c0102a7c:	6a 47                	push   $0x47
  jmp __alltraps
c0102a7e:	e9 f8 07 00 00       	jmp    c010327b <__alltraps>

c0102a83 <vector72>:
.globl vector72
vector72:
  pushl $0
c0102a83:	6a 00                	push   $0x0
  pushl $72
c0102a85:	6a 48                	push   $0x48
  jmp __alltraps
c0102a87:	e9 ef 07 00 00       	jmp    c010327b <__alltraps>

c0102a8c <vector73>:
.globl vector73
vector73:
  pushl $0
c0102a8c:	6a 00                	push   $0x0
  pushl $73
c0102a8e:	6a 49                	push   $0x49
  jmp __alltraps
c0102a90:	e9 e6 07 00 00       	jmp    c010327b <__alltraps>

c0102a95 <vector74>:
.globl vector74
vector74:
  pushl $0
c0102a95:	6a 00                	push   $0x0
  pushl $74
c0102a97:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102a99:	e9 dd 07 00 00       	jmp    c010327b <__alltraps>

c0102a9e <vector75>:
.globl vector75
vector75:
  pushl $0
c0102a9e:	6a 00                	push   $0x0
  pushl $75
c0102aa0:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102aa2:	e9 d4 07 00 00       	jmp    c010327b <__alltraps>

c0102aa7 <vector76>:
.globl vector76
vector76:
  pushl $0
c0102aa7:	6a 00                	push   $0x0
  pushl $76
c0102aa9:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102aab:	e9 cb 07 00 00       	jmp    c010327b <__alltraps>

c0102ab0 <vector77>:
.globl vector77
vector77:
  pushl $0
c0102ab0:	6a 00                	push   $0x0
  pushl $77
c0102ab2:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102ab4:	e9 c2 07 00 00       	jmp    c010327b <__alltraps>

c0102ab9 <vector78>:
.globl vector78
vector78:
  pushl $0
c0102ab9:	6a 00                	push   $0x0
  pushl $78
c0102abb:	6a 4e                	push   $0x4e
  jmp __alltraps
c0102abd:	e9 b9 07 00 00       	jmp    c010327b <__alltraps>

c0102ac2 <vector79>:
.globl vector79
vector79:
  pushl $0
c0102ac2:	6a 00                	push   $0x0
  pushl $79
c0102ac4:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102ac6:	e9 b0 07 00 00       	jmp    c010327b <__alltraps>

c0102acb <vector80>:
.globl vector80
vector80:
  pushl $0
c0102acb:	6a 00                	push   $0x0
  pushl $80
c0102acd:	6a 50                	push   $0x50
  jmp __alltraps
c0102acf:	e9 a7 07 00 00       	jmp    c010327b <__alltraps>

c0102ad4 <vector81>:
.globl vector81
vector81:
  pushl $0
c0102ad4:	6a 00                	push   $0x0
  pushl $81
c0102ad6:	6a 51                	push   $0x51
  jmp __alltraps
c0102ad8:	e9 9e 07 00 00       	jmp    c010327b <__alltraps>

c0102add <vector82>:
.globl vector82
vector82:
  pushl $0
c0102add:	6a 00                	push   $0x0
  pushl $82
c0102adf:	6a 52                	push   $0x52
  jmp __alltraps
c0102ae1:	e9 95 07 00 00       	jmp    c010327b <__alltraps>

c0102ae6 <vector83>:
.globl vector83
vector83:
  pushl $0
c0102ae6:	6a 00                	push   $0x0
  pushl $83
c0102ae8:	6a 53                	push   $0x53
  jmp __alltraps
c0102aea:	e9 8c 07 00 00       	jmp    c010327b <__alltraps>

c0102aef <vector84>:
.globl vector84
vector84:
  pushl $0
c0102aef:	6a 00                	push   $0x0
  pushl $84
c0102af1:	6a 54                	push   $0x54
  jmp __alltraps
c0102af3:	e9 83 07 00 00       	jmp    c010327b <__alltraps>

c0102af8 <vector85>:
.globl vector85
vector85:
  pushl $0
c0102af8:	6a 00                	push   $0x0
  pushl $85
c0102afa:	6a 55                	push   $0x55
  jmp __alltraps
c0102afc:	e9 7a 07 00 00       	jmp    c010327b <__alltraps>

c0102b01 <vector86>:
.globl vector86
vector86:
  pushl $0
c0102b01:	6a 00                	push   $0x0
  pushl $86
c0102b03:	6a 56                	push   $0x56
  jmp __alltraps
c0102b05:	e9 71 07 00 00       	jmp    c010327b <__alltraps>

c0102b0a <vector87>:
.globl vector87
vector87:
  pushl $0
c0102b0a:	6a 00                	push   $0x0
  pushl $87
c0102b0c:	6a 57                	push   $0x57
  jmp __alltraps
c0102b0e:	e9 68 07 00 00       	jmp    c010327b <__alltraps>

c0102b13 <vector88>:
.globl vector88
vector88:
  pushl $0
c0102b13:	6a 00                	push   $0x0
  pushl $88
c0102b15:	6a 58                	push   $0x58
  jmp __alltraps
c0102b17:	e9 5f 07 00 00       	jmp    c010327b <__alltraps>

c0102b1c <vector89>:
.globl vector89
vector89:
  pushl $0
c0102b1c:	6a 00                	push   $0x0
  pushl $89
c0102b1e:	6a 59                	push   $0x59
  jmp __alltraps
c0102b20:	e9 56 07 00 00       	jmp    c010327b <__alltraps>

c0102b25 <vector90>:
.globl vector90
vector90:
  pushl $0
c0102b25:	6a 00                	push   $0x0
  pushl $90
c0102b27:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102b29:	e9 4d 07 00 00       	jmp    c010327b <__alltraps>

c0102b2e <vector91>:
.globl vector91
vector91:
  pushl $0
c0102b2e:	6a 00                	push   $0x0
  pushl $91
c0102b30:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102b32:	e9 44 07 00 00       	jmp    c010327b <__alltraps>

c0102b37 <vector92>:
.globl vector92
vector92:
  pushl $0
c0102b37:	6a 00                	push   $0x0
  pushl $92
c0102b39:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102b3b:	e9 3b 07 00 00       	jmp    c010327b <__alltraps>

c0102b40 <vector93>:
.globl vector93
vector93:
  pushl $0
c0102b40:	6a 00                	push   $0x0
  pushl $93
c0102b42:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102b44:	e9 32 07 00 00       	jmp    c010327b <__alltraps>

c0102b49 <vector94>:
.globl vector94
vector94:
  pushl $0
c0102b49:	6a 00                	push   $0x0
  pushl $94
c0102b4b:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102b4d:	e9 29 07 00 00       	jmp    c010327b <__alltraps>

c0102b52 <vector95>:
.globl vector95
vector95:
  pushl $0
c0102b52:	6a 00                	push   $0x0
  pushl $95
c0102b54:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102b56:	e9 20 07 00 00       	jmp    c010327b <__alltraps>

c0102b5b <vector96>:
.globl vector96
vector96:
  pushl $0
c0102b5b:	6a 00                	push   $0x0
  pushl $96
c0102b5d:	6a 60                	push   $0x60
  jmp __alltraps
c0102b5f:	e9 17 07 00 00       	jmp    c010327b <__alltraps>

c0102b64 <vector97>:
.globl vector97
vector97:
  pushl $0
c0102b64:	6a 00                	push   $0x0
  pushl $97
c0102b66:	6a 61                	push   $0x61
  jmp __alltraps
c0102b68:	e9 0e 07 00 00       	jmp    c010327b <__alltraps>

c0102b6d <vector98>:
.globl vector98
vector98:
  pushl $0
c0102b6d:	6a 00                	push   $0x0
  pushl $98
c0102b6f:	6a 62                	push   $0x62
  jmp __alltraps
c0102b71:	e9 05 07 00 00       	jmp    c010327b <__alltraps>

c0102b76 <vector99>:
.globl vector99
vector99:
  pushl $0
c0102b76:	6a 00                	push   $0x0
  pushl $99
c0102b78:	6a 63                	push   $0x63
  jmp __alltraps
c0102b7a:	e9 fc 06 00 00       	jmp    c010327b <__alltraps>

c0102b7f <vector100>:
.globl vector100
vector100:
  pushl $0
c0102b7f:	6a 00                	push   $0x0
  pushl $100
c0102b81:	6a 64                	push   $0x64
  jmp __alltraps
c0102b83:	e9 f3 06 00 00       	jmp    c010327b <__alltraps>

c0102b88 <vector101>:
.globl vector101
vector101:
  pushl $0
c0102b88:	6a 00                	push   $0x0
  pushl $101
c0102b8a:	6a 65                	push   $0x65
  jmp __alltraps
c0102b8c:	e9 ea 06 00 00       	jmp    c010327b <__alltraps>

c0102b91 <vector102>:
.globl vector102
vector102:
  pushl $0
c0102b91:	6a 00                	push   $0x0
  pushl $102
c0102b93:	6a 66                	push   $0x66
  jmp __alltraps
c0102b95:	e9 e1 06 00 00       	jmp    c010327b <__alltraps>

c0102b9a <vector103>:
.globl vector103
vector103:
  pushl $0
c0102b9a:	6a 00                	push   $0x0
  pushl $103
c0102b9c:	6a 67                	push   $0x67
  jmp __alltraps
c0102b9e:	e9 d8 06 00 00       	jmp    c010327b <__alltraps>

c0102ba3 <vector104>:
.globl vector104
vector104:
  pushl $0
c0102ba3:	6a 00                	push   $0x0
  pushl $104
c0102ba5:	6a 68                	push   $0x68
  jmp __alltraps
c0102ba7:	e9 cf 06 00 00       	jmp    c010327b <__alltraps>

c0102bac <vector105>:
.globl vector105
vector105:
  pushl $0
c0102bac:	6a 00                	push   $0x0
  pushl $105
c0102bae:	6a 69                	push   $0x69
  jmp __alltraps
c0102bb0:	e9 c6 06 00 00       	jmp    c010327b <__alltraps>

c0102bb5 <vector106>:
.globl vector106
vector106:
  pushl $0
c0102bb5:	6a 00                	push   $0x0
  pushl $106
c0102bb7:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102bb9:	e9 bd 06 00 00       	jmp    c010327b <__alltraps>

c0102bbe <vector107>:
.globl vector107
vector107:
  pushl $0
c0102bbe:	6a 00                	push   $0x0
  pushl $107
c0102bc0:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102bc2:	e9 b4 06 00 00       	jmp    c010327b <__alltraps>

c0102bc7 <vector108>:
.globl vector108
vector108:
  pushl $0
c0102bc7:	6a 00                	push   $0x0
  pushl $108
c0102bc9:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102bcb:	e9 ab 06 00 00       	jmp    c010327b <__alltraps>

c0102bd0 <vector109>:
.globl vector109
vector109:
  pushl $0
c0102bd0:	6a 00                	push   $0x0
  pushl $109
c0102bd2:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102bd4:	e9 a2 06 00 00       	jmp    c010327b <__alltraps>

c0102bd9 <vector110>:
.globl vector110
vector110:
  pushl $0
c0102bd9:	6a 00                	push   $0x0
  pushl $110
c0102bdb:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102bdd:	e9 99 06 00 00       	jmp    c010327b <__alltraps>

c0102be2 <vector111>:
.globl vector111
vector111:
  pushl $0
c0102be2:	6a 00                	push   $0x0
  pushl $111
c0102be4:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102be6:	e9 90 06 00 00       	jmp    c010327b <__alltraps>

c0102beb <vector112>:
.globl vector112
vector112:
  pushl $0
c0102beb:	6a 00                	push   $0x0
  pushl $112
c0102bed:	6a 70                	push   $0x70
  jmp __alltraps
c0102bef:	e9 87 06 00 00       	jmp    c010327b <__alltraps>

c0102bf4 <vector113>:
.globl vector113
vector113:
  pushl $0
c0102bf4:	6a 00                	push   $0x0
  pushl $113
c0102bf6:	6a 71                	push   $0x71
  jmp __alltraps
c0102bf8:	e9 7e 06 00 00       	jmp    c010327b <__alltraps>

c0102bfd <vector114>:
.globl vector114
vector114:
  pushl $0
c0102bfd:	6a 00                	push   $0x0
  pushl $114
c0102bff:	6a 72                	push   $0x72
  jmp __alltraps
c0102c01:	e9 75 06 00 00       	jmp    c010327b <__alltraps>

c0102c06 <vector115>:
.globl vector115
vector115:
  pushl $0
c0102c06:	6a 00                	push   $0x0
  pushl $115
c0102c08:	6a 73                	push   $0x73
  jmp __alltraps
c0102c0a:	e9 6c 06 00 00       	jmp    c010327b <__alltraps>

c0102c0f <vector116>:
.globl vector116
vector116:
  pushl $0
c0102c0f:	6a 00                	push   $0x0
  pushl $116
c0102c11:	6a 74                	push   $0x74
  jmp __alltraps
c0102c13:	e9 63 06 00 00       	jmp    c010327b <__alltraps>

c0102c18 <vector117>:
.globl vector117
vector117:
  pushl $0
c0102c18:	6a 00                	push   $0x0
  pushl $117
c0102c1a:	6a 75                	push   $0x75
  jmp __alltraps
c0102c1c:	e9 5a 06 00 00       	jmp    c010327b <__alltraps>

c0102c21 <vector118>:
.globl vector118
vector118:
  pushl $0
c0102c21:	6a 00                	push   $0x0
  pushl $118
c0102c23:	6a 76                	push   $0x76
  jmp __alltraps
c0102c25:	e9 51 06 00 00       	jmp    c010327b <__alltraps>

c0102c2a <vector119>:
.globl vector119
vector119:
  pushl $0
c0102c2a:	6a 00                	push   $0x0
  pushl $119
c0102c2c:	6a 77                	push   $0x77
  jmp __alltraps
c0102c2e:	e9 48 06 00 00       	jmp    c010327b <__alltraps>

c0102c33 <vector120>:
.globl vector120
vector120:
  pushl $0
c0102c33:	6a 00                	push   $0x0
  pushl $120
c0102c35:	6a 78                	push   $0x78
  jmp __alltraps
c0102c37:	e9 3f 06 00 00       	jmp    c010327b <__alltraps>

c0102c3c <vector121>:
.globl vector121
vector121:
  pushl $0
c0102c3c:	6a 00                	push   $0x0
  pushl $121
c0102c3e:	6a 79                	push   $0x79
  jmp __alltraps
c0102c40:	e9 36 06 00 00       	jmp    c010327b <__alltraps>

c0102c45 <vector122>:
.globl vector122
vector122:
  pushl $0
c0102c45:	6a 00                	push   $0x0
  pushl $122
c0102c47:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102c49:	e9 2d 06 00 00       	jmp    c010327b <__alltraps>

c0102c4e <vector123>:
.globl vector123
vector123:
  pushl $0
c0102c4e:	6a 00                	push   $0x0
  pushl $123
c0102c50:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102c52:	e9 24 06 00 00       	jmp    c010327b <__alltraps>

c0102c57 <vector124>:
.globl vector124
vector124:
  pushl $0
c0102c57:	6a 00                	push   $0x0
  pushl $124
c0102c59:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102c5b:	e9 1b 06 00 00       	jmp    c010327b <__alltraps>

c0102c60 <vector125>:
.globl vector125
vector125:
  pushl $0
c0102c60:	6a 00                	push   $0x0
  pushl $125
c0102c62:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102c64:	e9 12 06 00 00       	jmp    c010327b <__alltraps>

c0102c69 <vector126>:
.globl vector126
vector126:
  pushl $0
c0102c69:	6a 00                	push   $0x0
  pushl $126
c0102c6b:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102c6d:	e9 09 06 00 00       	jmp    c010327b <__alltraps>

c0102c72 <vector127>:
.globl vector127
vector127:
  pushl $0
c0102c72:	6a 00                	push   $0x0
  pushl $127
c0102c74:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102c76:	e9 00 06 00 00       	jmp    c010327b <__alltraps>

c0102c7b <vector128>:
.globl vector128
vector128:
  pushl $0
c0102c7b:	6a 00                	push   $0x0
  pushl $128
c0102c7d:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102c82:	e9 f4 05 00 00       	jmp    c010327b <__alltraps>

c0102c87 <vector129>:
.globl vector129
vector129:
  pushl $0
c0102c87:	6a 00                	push   $0x0
  pushl $129
c0102c89:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102c8e:	e9 e8 05 00 00       	jmp    c010327b <__alltraps>

c0102c93 <vector130>:
.globl vector130
vector130:
  pushl $0
c0102c93:	6a 00                	push   $0x0
  pushl $130
c0102c95:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102c9a:	e9 dc 05 00 00       	jmp    c010327b <__alltraps>

c0102c9f <vector131>:
.globl vector131
vector131:
  pushl $0
c0102c9f:	6a 00                	push   $0x0
  pushl $131
c0102ca1:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102ca6:	e9 d0 05 00 00       	jmp    c010327b <__alltraps>

c0102cab <vector132>:
.globl vector132
vector132:
  pushl $0
c0102cab:	6a 00                	push   $0x0
  pushl $132
c0102cad:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102cb2:	e9 c4 05 00 00       	jmp    c010327b <__alltraps>

c0102cb7 <vector133>:
.globl vector133
vector133:
  pushl $0
c0102cb7:	6a 00                	push   $0x0
  pushl $133
c0102cb9:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102cbe:	e9 b8 05 00 00       	jmp    c010327b <__alltraps>

c0102cc3 <vector134>:
.globl vector134
vector134:
  pushl $0
c0102cc3:	6a 00                	push   $0x0
  pushl $134
c0102cc5:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102cca:	e9 ac 05 00 00       	jmp    c010327b <__alltraps>

c0102ccf <vector135>:
.globl vector135
vector135:
  pushl $0
c0102ccf:	6a 00                	push   $0x0
  pushl $135
c0102cd1:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102cd6:	e9 a0 05 00 00       	jmp    c010327b <__alltraps>

c0102cdb <vector136>:
.globl vector136
vector136:
  pushl $0
c0102cdb:	6a 00                	push   $0x0
  pushl $136
c0102cdd:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0102ce2:	e9 94 05 00 00       	jmp    c010327b <__alltraps>

c0102ce7 <vector137>:
.globl vector137
vector137:
  pushl $0
c0102ce7:	6a 00                	push   $0x0
  pushl $137
c0102ce9:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102cee:	e9 88 05 00 00       	jmp    c010327b <__alltraps>

c0102cf3 <vector138>:
.globl vector138
vector138:
  pushl $0
c0102cf3:	6a 00                	push   $0x0
  pushl $138
c0102cf5:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102cfa:	e9 7c 05 00 00       	jmp    c010327b <__alltraps>

c0102cff <vector139>:
.globl vector139
vector139:
  pushl $0
c0102cff:	6a 00                	push   $0x0
  pushl $139
c0102d01:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102d06:	e9 70 05 00 00       	jmp    c010327b <__alltraps>

c0102d0b <vector140>:
.globl vector140
vector140:
  pushl $0
c0102d0b:	6a 00                	push   $0x0
  pushl $140
c0102d0d:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0102d12:	e9 64 05 00 00       	jmp    c010327b <__alltraps>

c0102d17 <vector141>:
.globl vector141
vector141:
  pushl $0
c0102d17:	6a 00                	push   $0x0
  pushl $141
c0102d19:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102d1e:	e9 58 05 00 00       	jmp    c010327b <__alltraps>

c0102d23 <vector142>:
.globl vector142
vector142:
  pushl $0
c0102d23:	6a 00                	push   $0x0
  pushl $142
c0102d25:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102d2a:	e9 4c 05 00 00       	jmp    c010327b <__alltraps>

c0102d2f <vector143>:
.globl vector143
vector143:
  pushl $0
c0102d2f:	6a 00                	push   $0x0
  pushl $143
c0102d31:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0102d36:	e9 40 05 00 00       	jmp    c010327b <__alltraps>

c0102d3b <vector144>:
.globl vector144
vector144:
  pushl $0
c0102d3b:	6a 00                	push   $0x0
  pushl $144
c0102d3d:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102d42:	e9 34 05 00 00       	jmp    c010327b <__alltraps>

c0102d47 <vector145>:
.globl vector145
vector145:
  pushl $0
c0102d47:	6a 00                	push   $0x0
  pushl $145
c0102d49:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102d4e:	e9 28 05 00 00       	jmp    c010327b <__alltraps>

c0102d53 <vector146>:
.globl vector146
vector146:
  pushl $0
c0102d53:	6a 00                	push   $0x0
  pushl $146
c0102d55:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102d5a:	e9 1c 05 00 00       	jmp    c010327b <__alltraps>

c0102d5f <vector147>:
.globl vector147
vector147:
  pushl $0
c0102d5f:	6a 00                	push   $0x0
  pushl $147
c0102d61:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0102d66:	e9 10 05 00 00       	jmp    c010327b <__alltraps>

c0102d6b <vector148>:
.globl vector148
vector148:
  pushl $0
c0102d6b:	6a 00                	push   $0x0
  pushl $148
c0102d6d:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102d72:	e9 04 05 00 00       	jmp    c010327b <__alltraps>

c0102d77 <vector149>:
.globl vector149
vector149:
  pushl $0
c0102d77:	6a 00                	push   $0x0
  pushl $149
c0102d79:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102d7e:	e9 f8 04 00 00       	jmp    c010327b <__alltraps>

c0102d83 <vector150>:
.globl vector150
vector150:
  pushl $0
c0102d83:	6a 00                	push   $0x0
  pushl $150
c0102d85:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0102d8a:	e9 ec 04 00 00       	jmp    c010327b <__alltraps>

c0102d8f <vector151>:
.globl vector151
vector151:
  pushl $0
c0102d8f:	6a 00                	push   $0x0
  pushl $151
c0102d91:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102d96:	e9 e0 04 00 00       	jmp    c010327b <__alltraps>

c0102d9b <vector152>:
.globl vector152
vector152:
  pushl $0
c0102d9b:	6a 00                	push   $0x0
  pushl $152
c0102d9d:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0102da2:	e9 d4 04 00 00       	jmp    c010327b <__alltraps>

c0102da7 <vector153>:
.globl vector153
vector153:
  pushl $0
c0102da7:	6a 00                	push   $0x0
  pushl $153
c0102da9:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0102dae:	e9 c8 04 00 00       	jmp    c010327b <__alltraps>

c0102db3 <vector154>:
.globl vector154
vector154:
  pushl $0
c0102db3:	6a 00                	push   $0x0
  pushl $154
c0102db5:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0102dba:	e9 bc 04 00 00       	jmp    c010327b <__alltraps>

c0102dbf <vector155>:
.globl vector155
vector155:
  pushl $0
c0102dbf:	6a 00                	push   $0x0
  pushl $155
c0102dc1:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0102dc6:	e9 b0 04 00 00       	jmp    c010327b <__alltraps>

c0102dcb <vector156>:
.globl vector156
vector156:
  pushl $0
c0102dcb:	6a 00                	push   $0x0
  pushl $156
c0102dcd:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0102dd2:	e9 a4 04 00 00       	jmp    c010327b <__alltraps>

c0102dd7 <vector157>:
.globl vector157
vector157:
  pushl $0
c0102dd7:	6a 00                	push   $0x0
  pushl $157
c0102dd9:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0102dde:	e9 98 04 00 00       	jmp    c010327b <__alltraps>

c0102de3 <vector158>:
.globl vector158
vector158:
  pushl $0
c0102de3:	6a 00                	push   $0x0
  pushl $158
c0102de5:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0102dea:	e9 8c 04 00 00       	jmp    c010327b <__alltraps>

c0102def <vector159>:
.globl vector159
vector159:
  pushl $0
c0102def:	6a 00                	push   $0x0
  pushl $159
c0102df1:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0102df6:	e9 80 04 00 00       	jmp    c010327b <__alltraps>

c0102dfb <vector160>:
.globl vector160
vector160:
  pushl $0
c0102dfb:	6a 00                	push   $0x0
  pushl $160
c0102dfd:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0102e02:	e9 74 04 00 00       	jmp    c010327b <__alltraps>

c0102e07 <vector161>:
.globl vector161
vector161:
  pushl $0
c0102e07:	6a 00                	push   $0x0
  pushl $161
c0102e09:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0102e0e:	e9 68 04 00 00       	jmp    c010327b <__alltraps>

c0102e13 <vector162>:
.globl vector162
vector162:
  pushl $0
c0102e13:	6a 00                	push   $0x0
  pushl $162
c0102e15:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0102e1a:	e9 5c 04 00 00       	jmp    c010327b <__alltraps>

c0102e1f <vector163>:
.globl vector163
vector163:
  pushl $0
c0102e1f:	6a 00                	push   $0x0
  pushl $163
c0102e21:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0102e26:	e9 50 04 00 00       	jmp    c010327b <__alltraps>

c0102e2b <vector164>:
.globl vector164
vector164:
  pushl $0
c0102e2b:	6a 00                	push   $0x0
  pushl $164
c0102e2d:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c0102e32:	e9 44 04 00 00       	jmp    c010327b <__alltraps>

c0102e37 <vector165>:
.globl vector165
vector165:
  pushl $0
c0102e37:	6a 00                	push   $0x0
  pushl $165
c0102e39:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0102e3e:	e9 38 04 00 00       	jmp    c010327b <__alltraps>

c0102e43 <vector166>:
.globl vector166
vector166:
  pushl $0
c0102e43:	6a 00                	push   $0x0
  pushl $166
c0102e45:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c0102e4a:	e9 2c 04 00 00       	jmp    c010327b <__alltraps>

c0102e4f <vector167>:
.globl vector167
vector167:
  pushl $0
c0102e4f:	6a 00                	push   $0x0
  pushl $167
c0102e51:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c0102e56:	e9 20 04 00 00       	jmp    c010327b <__alltraps>

c0102e5b <vector168>:
.globl vector168
vector168:
  pushl $0
c0102e5b:	6a 00                	push   $0x0
  pushl $168
c0102e5d:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0102e62:	e9 14 04 00 00       	jmp    c010327b <__alltraps>

c0102e67 <vector169>:
.globl vector169
vector169:
  pushl $0
c0102e67:	6a 00                	push   $0x0
  pushl $169
c0102e69:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0102e6e:	e9 08 04 00 00       	jmp    c010327b <__alltraps>

c0102e73 <vector170>:
.globl vector170
vector170:
  pushl $0
c0102e73:	6a 00                	push   $0x0
  pushl $170
c0102e75:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0102e7a:	e9 fc 03 00 00       	jmp    c010327b <__alltraps>

c0102e7f <vector171>:
.globl vector171
vector171:
  pushl $0
c0102e7f:	6a 00                	push   $0x0
  pushl $171
c0102e81:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0102e86:	e9 f0 03 00 00       	jmp    c010327b <__alltraps>

c0102e8b <vector172>:
.globl vector172
vector172:
  pushl $0
c0102e8b:	6a 00                	push   $0x0
  pushl $172
c0102e8d:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0102e92:	e9 e4 03 00 00       	jmp    c010327b <__alltraps>

c0102e97 <vector173>:
.globl vector173
vector173:
  pushl $0
c0102e97:	6a 00                	push   $0x0
  pushl $173
c0102e99:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0102e9e:	e9 d8 03 00 00       	jmp    c010327b <__alltraps>

c0102ea3 <vector174>:
.globl vector174
vector174:
  pushl $0
c0102ea3:	6a 00                	push   $0x0
  pushl $174
c0102ea5:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0102eaa:	e9 cc 03 00 00       	jmp    c010327b <__alltraps>

c0102eaf <vector175>:
.globl vector175
vector175:
  pushl $0
c0102eaf:	6a 00                	push   $0x0
  pushl $175
c0102eb1:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0102eb6:	e9 c0 03 00 00       	jmp    c010327b <__alltraps>

c0102ebb <vector176>:
.globl vector176
vector176:
  pushl $0
c0102ebb:	6a 00                	push   $0x0
  pushl $176
c0102ebd:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0102ec2:	e9 b4 03 00 00       	jmp    c010327b <__alltraps>

c0102ec7 <vector177>:
.globl vector177
vector177:
  pushl $0
c0102ec7:	6a 00                	push   $0x0
  pushl $177
c0102ec9:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0102ece:	e9 a8 03 00 00       	jmp    c010327b <__alltraps>

c0102ed3 <vector178>:
.globl vector178
vector178:
  pushl $0
c0102ed3:	6a 00                	push   $0x0
  pushl $178
c0102ed5:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0102eda:	e9 9c 03 00 00       	jmp    c010327b <__alltraps>

c0102edf <vector179>:
.globl vector179
vector179:
  pushl $0
c0102edf:	6a 00                	push   $0x0
  pushl $179
c0102ee1:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0102ee6:	e9 90 03 00 00       	jmp    c010327b <__alltraps>

c0102eeb <vector180>:
.globl vector180
vector180:
  pushl $0
c0102eeb:	6a 00                	push   $0x0
  pushl $180
c0102eed:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0102ef2:	e9 84 03 00 00       	jmp    c010327b <__alltraps>

c0102ef7 <vector181>:
.globl vector181
vector181:
  pushl $0
c0102ef7:	6a 00                	push   $0x0
  pushl $181
c0102ef9:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0102efe:	e9 78 03 00 00       	jmp    c010327b <__alltraps>

c0102f03 <vector182>:
.globl vector182
vector182:
  pushl $0
c0102f03:	6a 00                	push   $0x0
  pushl $182
c0102f05:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0102f0a:	e9 6c 03 00 00       	jmp    c010327b <__alltraps>

c0102f0f <vector183>:
.globl vector183
vector183:
  pushl $0
c0102f0f:	6a 00                	push   $0x0
  pushl $183
c0102f11:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0102f16:	e9 60 03 00 00       	jmp    c010327b <__alltraps>

c0102f1b <vector184>:
.globl vector184
vector184:
  pushl $0
c0102f1b:	6a 00                	push   $0x0
  pushl $184
c0102f1d:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c0102f22:	e9 54 03 00 00       	jmp    c010327b <__alltraps>

c0102f27 <vector185>:
.globl vector185
vector185:
  pushl $0
c0102f27:	6a 00                	push   $0x0
  pushl $185
c0102f29:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0102f2e:	e9 48 03 00 00       	jmp    c010327b <__alltraps>

c0102f33 <vector186>:
.globl vector186
vector186:
  pushl $0
c0102f33:	6a 00                	push   $0x0
  pushl $186
c0102f35:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c0102f3a:	e9 3c 03 00 00       	jmp    c010327b <__alltraps>

c0102f3f <vector187>:
.globl vector187
vector187:
  pushl $0
c0102f3f:	6a 00                	push   $0x0
  pushl $187
c0102f41:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c0102f46:	e9 30 03 00 00       	jmp    c010327b <__alltraps>

c0102f4b <vector188>:
.globl vector188
vector188:
  pushl $0
c0102f4b:	6a 00                	push   $0x0
  pushl $188
c0102f4d:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c0102f52:	e9 24 03 00 00       	jmp    c010327b <__alltraps>

c0102f57 <vector189>:
.globl vector189
vector189:
  pushl $0
c0102f57:	6a 00                	push   $0x0
  pushl $189
c0102f59:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0102f5e:	e9 18 03 00 00       	jmp    c010327b <__alltraps>

c0102f63 <vector190>:
.globl vector190
vector190:
  pushl $0
c0102f63:	6a 00                	push   $0x0
  pushl $190
c0102f65:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c0102f6a:	e9 0c 03 00 00       	jmp    c010327b <__alltraps>

c0102f6f <vector191>:
.globl vector191
vector191:
  pushl $0
c0102f6f:	6a 00                	push   $0x0
  pushl $191
c0102f71:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0102f76:	e9 00 03 00 00       	jmp    c010327b <__alltraps>

c0102f7b <vector192>:
.globl vector192
vector192:
  pushl $0
c0102f7b:	6a 00                	push   $0x0
  pushl $192
c0102f7d:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0102f82:	e9 f4 02 00 00       	jmp    c010327b <__alltraps>

c0102f87 <vector193>:
.globl vector193
vector193:
  pushl $0
c0102f87:	6a 00                	push   $0x0
  pushl $193
c0102f89:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0102f8e:	e9 e8 02 00 00       	jmp    c010327b <__alltraps>

c0102f93 <vector194>:
.globl vector194
vector194:
  pushl $0
c0102f93:	6a 00                	push   $0x0
  pushl $194
c0102f95:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c0102f9a:	e9 dc 02 00 00       	jmp    c010327b <__alltraps>

c0102f9f <vector195>:
.globl vector195
vector195:
  pushl $0
c0102f9f:	6a 00                	push   $0x0
  pushl $195
c0102fa1:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0102fa6:	e9 d0 02 00 00       	jmp    c010327b <__alltraps>

c0102fab <vector196>:
.globl vector196
vector196:
  pushl $0
c0102fab:	6a 00                	push   $0x0
  pushl $196
c0102fad:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0102fb2:	e9 c4 02 00 00       	jmp    c010327b <__alltraps>

c0102fb7 <vector197>:
.globl vector197
vector197:
  pushl $0
c0102fb7:	6a 00                	push   $0x0
  pushl $197
c0102fb9:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0102fbe:	e9 b8 02 00 00       	jmp    c010327b <__alltraps>

c0102fc3 <vector198>:
.globl vector198
vector198:
  pushl $0
c0102fc3:	6a 00                	push   $0x0
  pushl $198
c0102fc5:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0102fca:	e9 ac 02 00 00       	jmp    c010327b <__alltraps>

c0102fcf <vector199>:
.globl vector199
vector199:
  pushl $0
c0102fcf:	6a 00                	push   $0x0
  pushl $199
c0102fd1:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0102fd6:	e9 a0 02 00 00       	jmp    c010327b <__alltraps>

c0102fdb <vector200>:
.globl vector200
vector200:
  pushl $0
c0102fdb:	6a 00                	push   $0x0
  pushl $200
c0102fdd:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0102fe2:	e9 94 02 00 00       	jmp    c010327b <__alltraps>

c0102fe7 <vector201>:
.globl vector201
vector201:
  pushl $0
c0102fe7:	6a 00                	push   $0x0
  pushl $201
c0102fe9:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0102fee:	e9 88 02 00 00       	jmp    c010327b <__alltraps>

c0102ff3 <vector202>:
.globl vector202
vector202:
  pushl $0
c0102ff3:	6a 00                	push   $0x0
  pushl $202
c0102ff5:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0102ffa:	e9 7c 02 00 00       	jmp    c010327b <__alltraps>

c0102fff <vector203>:
.globl vector203
vector203:
  pushl $0
c0102fff:	6a 00                	push   $0x0
  pushl $203
c0103001:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0103006:	e9 70 02 00 00       	jmp    c010327b <__alltraps>

c010300b <vector204>:
.globl vector204
vector204:
  pushl $0
c010300b:	6a 00                	push   $0x0
  pushl $204
c010300d:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c0103012:	e9 64 02 00 00       	jmp    c010327b <__alltraps>

c0103017 <vector205>:
.globl vector205
vector205:
  pushl $0
c0103017:	6a 00                	push   $0x0
  pushl $205
c0103019:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c010301e:	e9 58 02 00 00       	jmp    c010327b <__alltraps>

c0103023 <vector206>:
.globl vector206
vector206:
  pushl $0
c0103023:	6a 00                	push   $0x0
  pushl $206
c0103025:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c010302a:	e9 4c 02 00 00       	jmp    c010327b <__alltraps>

c010302f <vector207>:
.globl vector207
vector207:
  pushl $0
c010302f:	6a 00                	push   $0x0
  pushl $207
c0103031:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c0103036:	e9 40 02 00 00       	jmp    c010327b <__alltraps>

c010303b <vector208>:
.globl vector208
vector208:
  pushl $0
c010303b:	6a 00                	push   $0x0
  pushl $208
c010303d:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c0103042:	e9 34 02 00 00       	jmp    c010327b <__alltraps>

c0103047 <vector209>:
.globl vector209
vector209:
  pushl $0
c0103047:	6a 00                	push   $0x0
  pushl $209
c0103049:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c010304e:	e9 28 02 00 00       	jmp    c010327b <__alltraps>

c0103053 <vector210>:
.globl vector210
vector210:
  pushl $0
c0103053:	6a 00                	push   $0x0
  pushl $210
c0103055:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c010305a:	e9 1c 02 00 00       	jmp    c010327b <__alltraps>

c010305f <vector211>:
.globl vector211
vector211:
  pushl $0
c010305f:	6a 00                	push   $0x0
  pushl $211
c0103061:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c0103066:	e9 10 02 00 00       	jmp    c010327b <__alltraps>

c010306b <vector212>:
.globl vector212
vector212:
  pushl $0
c010306b:	6a 00                	push   $0x0
  pushl $212
c010306d:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0103072:	e9 04 02 00 00       	jmp    c010327b <__alltraps>

c0103077 <vector213>:
.globl vector213
vector213:
  pushl $0
c0103077:	6a 00                	push   $0x0
  pushl $213
c0103079:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c010307e:	e9 f8 01 00 00       	jmp    c010327b <__alltraps>

c0103083 <vector214>:
.globl vector214
vector214:
  pushl $0
c0103083:	6a 00                	push   $0x0
  pushl $214
c0103085:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c010308a:	e9 ec 01 00 00       	jmp    c010327b <__alltraps>

c010308f <vector215>:
.globl vector215
vector215:
  pushl $0
c010308f:	6a 00                	push   $0x0
  pushl $215
c0103091:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0103096:	e9 e0 01 00 00       	jmp    c010327b <__alltraps>

c010309b <vector216>:
.globl vector216
vector216:
  pushl $0
c010309b:	6a 00                	push   $0x0
  pushl $216
c010309d:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c01030a2:	e9 d4 01 00 00       	jmp    c010327b <__alltraps>

c01030a7 <vector217>:
.globl vector217
vector217:
  pushl $0
c01030a7:	6a 00                	push   $0x0
  pushl $217
c01030a9:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c01030ae:	e9 c8 01 00 00       	jmp    c010327b <__alltraps>

c01030b3 <vector218>:
.globl vector218
vector218:
  pushl $0
c01030b3:	6a 00                	push   $0x0
  pushl $218
c01030b5:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c01030ba:	e9 bc 01 00 00       	jmp    c010327b <__alltraps>

c01030bf <vector219>:
.globl vector219
vector219:
  pushl $0
c01030bf:	6a 00                	push   $0x0
  pushl $219
c01030c1:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c01030c6:	e9 b0 01 00 00       	jmp    c010327b <__alltraps>

c01030cb <vector220>:
.globl vector220
vector220:
  pushl $0
c01030cb:	6a 00                	push   $0x0
  pushl $220
c01030cd:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c01030d2:	e9 a4 01 00 00       	jmp    c010327b <__alltraps>

c01030d7 <vector221>:
.globl vector221
vector221:
  pushl $0
c01030d7:	6a 00                	push   $0x0
  pushl $221
c01030d9:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c01030de:	e9 98 01 00 00       	jmp    c010327b <__alltraps>

c01030e3 <vector222>:
.globl vector222
vector222:
  pushl $0
c01030e3:	6a 00                	push   $0x0
  pushl $222
c01030e5:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c01030ea:	e9 8c 01 00 00       	jmp    c010327b <__alltraps>

c01030ef <vector223>:
.globl vector223
vector223:
  pushl $0
c01030ef:	6a 00                	push   $0x0
  pushl $223
c01030f1:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c01030f6:	e9 80 01 00 00       	jmp    c010327b <__alltraps>

c01030fb <vector224>:
.globl vector224
vector224:
  pushl $0
c01030fb:	6a 00                	push   $0x0
  pushl $224
c01030fd:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c0103102:	e9 74 01 00 00       	jmp    c010327b <__alltraps>

c0103107 <vector225>:
.globl vector225
vector225:
  pushl $0
c0103107:	6a 00                	push   $0x0
  pushl $225
c0103109:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c010310e:	e9 68 01 00 00       	jmp    c010327b <__alltraps>

c0103113 <vector226>:
.globl vector226
vector226:
  pushl $0
c0103113:	6a 00                	push   $0x0
  pushl $226
c0103115:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c010311a:	e9 5c 01 00 00       	jmp    c010327b <__alltraps>

c010311f <vector227>:
.globl vector227
vector227:
  pushl $0
c010311f:	6a 00                	push   $0x0
  pushl $227
c0103121:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c0103126:	e9 50 01 00 00       	jmp    c010327b <__alltraps>

c010312b <vector228>:
.globl vector228
vector228:
  pushl $0
c010312b:	6a 00                	push   $0x0
  pushl $228
c010312d:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c0103132:	e9 44 01 00 00       	jmp    c010327b <__alltraps>

c0103137 <vector229>:
.globl vector229
vector229:
  pushl $0
c0103137:	6a 00                	push   $0x0
  pushl $229
c0103139:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c010313e:	e9 38 01 00 00       	jmp    c010327b <__alltraps>

c0103143 <vector230>:
.globl vector230
vector230:
  pushl $0
c0103143:	6a 00                	push   $0x0
  pushl $230
c0103145:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c010314a:	e9 2c 01 00 00       	jmp    c010327b <__alltraps>

c010314f <vector231>:
.globl vector231
vector231:
  pushl $0
c010314f:	6a 00                	push   $0x0
  pushl $231
c0103151:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c0103156:	e9 20 01 00 00       	jmp    c010327b <__alltraps>

c010315b <vector232>:
.globl vector232
vector232:
  pushl $0
c010315b:	6a 00                	push   $0x0
  pushl $232
c010315d:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c0103162:	e9 14 01 00 00       	jmp    c010327b <__alltraps>

c0103167 <vector233>:
.globl vector233
vector233:
  pushl $0
c0103167:	6a 00                	push   $0x0
  pushl $233
c0103169:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c010316e:	e9 08 01 00 00       	jmp    c010327b <__alltraps>

c0103173 <vector234>:
.globl vector234
vector234:
  pushl $0
c0103173:	6a 00                	push   $0x0
  pushl $234
c0103175:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c010317a:	e9 fc 00 00 00       	jmp    c010327b <__alltraps>

c010317f <vector235>:
.globl vector235
vector235:
  pushl $0
c010317f:	6a 00                	push   $0x0
  pushl $235
c0103181:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c0103186:	e9 f0 00 00 00       	jmp    c010327b <__alltraps>

c010318b <vector236>:
.globl vector236
vector236:
  pushl $0
c010318b:	6a 00                	push   $0x0
  pushl $236
c010318d:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0103192:	e9 e4 00 00 00       	jmp    c010327b <__alltraps>

c0103197 <vector237>:
.globl vector237
vector237:
  pushl $0
c0103197:	6a 00                	push   $0x0
  pushl $237
c0103199:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c010319e:	e9 d8 00 00 00       	jmp    c010327b <__alltraps>

c01031a3 <vector238>:
.globl vector238
vector238:
  pushl $0
c01031a3:	6a 00                	push   $0x0
  pushl $238
c01031a5:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c01031aa:	e9 cc 00 00 00       	jmp    c010327b <__alltraps>

c01031af <vector239>:
.globl vector239
vector239:
  pushl $0
c01031af:	6a 00                	push   $0x0
  pushl $239
c01031b1:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c01031b6:	e9 c0 00 00 00       	jmp    c010327b <__alltraps>

c01031bb <vector240>:
.globl vector240
vector240:
  pushl $0
c01031bb:	6a 00                	push   $0x0
  pushl $240
c01031bd:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c01031c2:	e9 b4 00 00 00       	jmp    c010327b <__alltraps>

c01031c7 <vector241>:
.globl vector241
vector241:
  pushl $0
c01031c7:	6a 00                	push   $0x0
  pushl $241
c01031c9:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c01031ce:	e9 a8 00 00 00       	jmp    c010327b <__alltraps>

c01031d3 <vector242>:
.globl vector242
vector242:
  pushl $0
c01031d3:	6a 00                	push   $0x0
  pushl $242
c01031d5:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c01031da:	e9 9c 00 00 00       	jmp    c010327b <__alltraps>

c01031df <vector243>:
.globl vector243
vector243:
  pushl $0
c01031df:	6a 00                	push   $0x0
  pushl $243
c01031e1:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c01031e6:	e9 90 00 00 00       	jmp    c010327b <__alltraps>

c01031eb <vector244>:
.globl vector244
vector244:
  pushl $0
c01031eb:	6a 00                	push   $0x0
  pushl $244
c01031ed:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c01031f2:	e9 84 00 00 00       	jmp    c010327b <__alltraps>

c01031f7 <vector245>:
.globl vector245
vector245:
  pushl $0
c01031f7:	6a 00                	push   $0x0
  pushl $245
c01031f9:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c01031fe:	e9 78 00 00 00       	jmp    c010327b <__alltraps>

c0103203 <vector246>:
.globl vector246
vector246:
  pushl $0
c0103203:	6a 00                	push   $0x0
  pushl $246
c0103205:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c010320a:	e9 6c 00 00 00       	jmp    c010327b <__alltraps>

c010320f <vector247>:
.globl vector247
vector247:
  pushl $0
c010320f:	6a 00                	push   $0x0
  pushl $247
c0103211:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c0103216:	e9 60 00 00 00       	jmp    c010327b <__alltraps>

c010321b <vector248>:
.globl vector248
vector248:
  pushl $0
c010321b:	6a 00                	push   $0x0
  pushl $248
c010321d:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c0103222:	e9 54 00 00 00       	jmp    c010327b <__alltraps>

c0103227 <vector249>:
.globl vector249
vector249:
  pushl $0
c0103227:	6a 00                	push   $0x0
  pushl $249
c0103229:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c010322e:	e9 48 00 00 00       	jmp    c010327b <__alltraps>

c0103233 <vector250>:
.globl vector250
vector250:
  pushl $0
c0103233:	6a 00                	push   $0x0
  pushl $250
c0103235:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c010323a:	e9 3c 00 00 00       	jmp    c010327b <__alltraps>

c010323f <vector251>:
.globl vector251
vector251:
  pushl $0
c010323f:	6a 00                	push   $0x0
  pushl $251
c0103241:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c0103246:	e9 30 00 00 00       	jmp    c010327b <__alltraps>

c010324b <vector252>:
.globl vector252
vector252:
  pushl $0
c010324b:	6a 00                	push   $0x0
  pushl $252
c010324d:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c0103252:	e9 24 00 00 00       	jmp    c010327b <__alltraps>

c0103257 <vector253>:
.globl vector253
vector253:
  pushl $0
c0103257:	6a 00                	push   $0x0
  pushl $253
c0103259:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c010325e:	e9 18 00 00 00       	jmp    c010327b <__alltraps>

c0103263 <vector254>:
.globl vector254
vector254:
  pushl $0
c0103263:	6a 00                	push   $0x0
  pushl $254
c0103265:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c010326a:	e9 0c 00 00 00       	jmp    c010327b <__alltraps>

c010326f <vector255>:
.globl vector255
vector255:
  pushl $0
c010326f:	6a 00                	push   $0x0
  pushl $255
c0103271:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c0103276:	e9 00 00 00 00       	jmp    c010327b <__alltraps>

c010327b <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c010327b:	1e                   	push   %ds
    pushl %es
c010327c:	06                   	push   %es
    pushl %fs
c010327d:	0f a0                	push   %fs
    pushl %gs
c010327f:	0f a8                	push   %gs
    pushal
c0103281:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0103282:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0103287:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0103289:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c010328b:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c010328c:	e8 65 f5 ff ff       	call   c01027f6 <trap>

    # pop the pushed stack pointer
    popl %esp
c0103291:	5c                   	pop    %esp

c0103292 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0103292:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0103293:	0f a9                	pop    %gs
    popl %fs
c0103295:	0f a1                	pop    %fs
    popl %es
c0103297:	07                   	pop    %es
    popl %ds
c0103298:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0103299:	83 c4 08             	add    $0x8,%esp
    iret
c010329c:	cf                   	iret   

c010329d <forkrets>:

.globl forkrets
forkrets:
    # set stack to this new process's trapframe
    movl 4(%esp), %esp
c010329d:	8b 64 24 04          	mov    0x4(%esp),%esp
    jmp __trapret
c01032a1:	eb ef                	jmp    c0103292 <__trapret>

c01032a3 <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c01032a3:	55                   	push   %ebp
c01032a4:	89 e5                	mov    %esp,%ebp
c01032a6:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c01032a9:	8b 45 08             	mov    0x8(%ebp),%eax
c01032ac:	c1 e8 0c             	shr    $0xc,%eax
c01032af:	89 c2                	mov    %eax,%edx
c01032b1:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c01032b6:	39 c2                	cmp    %eax,%edx
c01032b8:	72 1c                	jb     c01032d6 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c01032ba:	c7 44 24 08 30 a7 10 	movl   $0xc010a730,0x8(%esp)
c01032c1:	c0 
c01032c2:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c01032c9:	00 
c01032ca:	c7 04 24 4f a7 10 c0 	movl   $0xc010a74f,(%esp)
c01032d1:	e8 2a d1 ff ff       	call   c0100400 <__panic>
    }
    return &pages[PPN(pa)];
c01032d6:	a1 58 a1 12 c0       	mov    0xc012a158,%eax
c01032db:	8b 55 08             	mov    0x8(%ebp),%edx
c01032de:	c1 ea 0c             	shr    $0xc,%edx
c01032e1:	c1 e2 05             	shl    $0x5,%edx
c01032e4:	01 d0                	add    %edx,%eax
}
c01032e6:	c9                   	leave  
c01032e7:	c3                   	ret    

c01032e8 <pde2page>:
    }
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *
pde2page(pde_t pde) {
c01032e8:	55                   	push   %ebp
c01032e9:	89 e5                	mov    %esp,%ebp
c01032eb:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c01032ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01032f1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01032f6:	89 04 24             	mov    %eax,(%esp)
c01032f9:	e8 a5 ff ff ff       	call   c01032a3 <pa2page>
}
c01032fe:	c9                   	leave  
c01032ff:	c3                   	ret    

c0103300 <mm_create>:
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void) {
c0103300:	55                   	push   %ebp
c0103301:	89 e5                	mov    %esp,%ebp
c0103303:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
c0103306:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c010330d:	e8 fc 17 00 00       	call   c0104b0e <kmalloc>
c0103312:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (mm != NULL) {
c0103315:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103319:	74 58                	je     c0103373 <mm_create+0x73>
        list_init(&(mm->mmap_list));
c010331b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010331e:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0103321:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103324:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0103327:	89 50 04             	mov    %edx,0x4(%eax)
c010332a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010332d:	8b 50 04             	mov    0x4(%eax),%edx
c0103330:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103333:	89 10                	mov    %edx,(%eax)
        mm->mmap_cache = NULL;
c0103335:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103338:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        mm->pgdir = NULL;
c010333f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103342:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        mm->map_count = 0;
c0103349:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010334c:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

        if (swap_init_ok) swap_init_mm(mm);
c0103353:	a1 6c 7f 12 c0       	mov    0xc0127f6c,%eax
c0103358:	85 c0                	test   %eax,%eax
c010335a:	74 0d                	je     c0103369 <mm_create+0x69>
c010335c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010335f:	89 04 24             	mov    %eax,(%esp)
c0103362:	e8 11 1a 00 00       	call   c0104d78 <swap_init_mm>
c0103367:	eb 0a                	jmp    c0103373 <mm_create+0x73>
        else mm->sm_priv = NULL;
c0103369:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010336c:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
    }
    return mm;
c0103373:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103376:	c9                   	leave  
c0103377:	c3                   	ret    

c0103378 <vma_create>:

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
c0103378:	55                   	push   %ebp
c0103379:	89 e5                	mov    %esp,%ebp
c010337b:	83 ec 28             	sub    $0x28,%esp
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
c010337e:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c0103385:	e8 84 17 00 00       	call   c0104b0e <kmalloc>
c010338a:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (vma != NULL) {
c010338d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103391:	74 1b                	je     c01033ae <vma_create+0x36>
        vma->vm_start = vm_start;
c0103393:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103396:	8b 55 08             	mov    0x8(%ebp),%edx
c0103399:	89 50 04             	mov    %edx,0x4(%eax)
        vma->vm_end = vm_end;
c010339c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010339f:	8b 55 0c             	mov    0xc(%ebp),%edx
c01033a2:	89 50 08             	mov    %edx,0x8(%eax)
        vma->vm_flags = vm_flags;
c01033a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033a8:	8b 55 10             	mov    0x10(%ebp),%edx
c01033ab:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    return vma;
c01033ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01033b1:	c9                   	leave  
c01033b2:	c3                   	ret    

c01033b3 <find_vma>:


// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
c01033b3:	55                   	push   %ebp
c01033b4:	89 e5                	mov    %esp,%ebp
c01033b6:	83 ec 20             	sub    $0x20,%esp
    struct vma_struct *vma = NULL;
c01033b9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    if (mm != NULL) {
c01033c0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01033c4:	0f 84 95 00 00 00    	je     c010345f <find_vma+0xac>
        vma = mm->mmap_cache;
c01033ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01033cd:	8b 40 08             	mov    0x8(%eax),%eax
c01033d0:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
c01033d3:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01033d7:	74 16                	je     c01033ef <find_vma+0x3c>
c01033d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01033dc:	8b 40 04             	mov    0x4(%eax),%eax
c01033df:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01033e2:	77 0b                	ja     c01033ef <find_vma+0x3c>
c01033e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01033e7:	8b 40 08             	mov    0x8(%eax),%eax
c01033ea:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01033ed:	77 61                	ja     c0103450 <find_vma+0x9d>
                bool found = 0;
c01033ef:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
                list_entry_t *list = &(mm->mmap_list), *le = list;
c01033f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01033f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01033fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01033ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
                while ((le = list_next(le)) != list) {
c0103402:	eb 28                	jmp    c010342c <find_vma+0x79>
                    vma = le2vma(le, list_link);
c0103404:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103407:	83 e8 10             	sub    $0x10,%eax
c010340a:	89 45 fc             	mov    %eax,-0x4(%ebp)
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
c010340d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103410:	8b 40 04             	mov    0x4(%eax),%eax
c0103413:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103416:	77 14                	ja     c010342c <find_vma+0x79>
c0103418:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010341b:	8b 40 08             	mov    0x8(%eax),%eax
c010341e:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103421:	76 09                	jbe    c010342c <find_vma+0x79>
                        found = 1;
c0103423:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
                        break;
c010342a:	eb 17                	jmp    c0103443 <find_vma+0x90>
c010342c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010342f:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0103432:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103435:	8b 40 04             	mov    0x4(%eax),%eax
                while ((le = list_next(le)) != list) {
c0103438:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010343b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010343e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103441:	75 c1                	jne    c0103404 <find_vma+0x51>
                    }
                }
                if (!found) {
c0103443:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c0103447:	75 07                	jne    c0103450 <find_vma+0x9d>
                    vma = NULL;
c0103449:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
                }
        }
        if (vma != NULL) {
c0103450:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0103454:	74 09                	je     c010345f <find_vma+0xac>
            mm->mmap_cache = vma;
c0103456:	8b 45 08             	mov    0x8(%ebp),%eax
c0103459:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010345c:	89 50 08             	mov    %edx,0x8(%eax)
        }
    }
    return vma;
c010345f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0103462:	c9                   	leave  
c0103463:	c3                   	ret    

c0103464 <check_vma_overlap>:


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
c0103464:	55                   	push   %ebp
c0103465:	89 e5                	mov    %esp,%ebp
c0103467:	83 ec 18             	sub    $0x18,%esp
    assert(prev->vm_start < prev->vm_end);
c010346a:	8b 45 08             	mov    0x8(%ebp),%eax
c010346d:	8b 50 04             	mov    0x4(%eax),%edx
c0103470:	8b 45 08             	mov    0x8(%ebp),%eax
c0103473:	8b 40 08             	mov    0x8(%eax),%eax
c0103476:	39 c2                	cmp    %eax,%edx
c0103478:	72 24                	jb     c010349e <check_vma_overlap+0x3a>
c010347a:	c7 44 24 0c 5d a7 10 	movl   $0xc010a75d,0xc(%esp)
c0103481:	c0 
c0103482:	c7 44 24 08 7b a7 10 	movl   $0xc010a77b,0x8(%esp)
c0103489:	c0 
c010348a:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
c0103491:	00 
c0103492:	c7 04 24 90 a7 10 c0 	movl   $0xc010a790,(%esp)
c0103499:	e8 62 cf ff ff       	call   c0100400 <__panic>
    assert(prev->vm_end <= next->vm_start);
c010349e:	8b 45 08             	mov    0x8(%ebp),%eax
c01034a1:	8b 50 08             	mov    0x8(%eax),%edx
c01034a4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01034a7:	8b 40 04             	mov    0x4(%eax),%eax
c01034aa:	39 c2                	cmp    %eax,%edx
c01034ac:	76 24                	jbe    c01034d2 <check_vma_overlap+0x6e>
c01034ae:	c7 44 24 0c a0 a7 10 	movl   $0xc010a7a0,0xc(%esp)
c01034b5:	c0 
c01034b6:	c7 44 24 08 7b a7 10 	movl   $0xc010a77b,0x8(%esp)
c01034bd:	c0 
c01034be:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
c01034c5:	00 
c01034c6:	c7 04 24 90 a7 10 c0 	movl   $0xc010a790,(%esp)
c01034cd:	e8 2e cf ff ff       	call   c0100400 <__panic>
    assert(next->vm_start < next->vm_end);
c01034d2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01034d5:	8b 50 04             	mov    0x4(%eax),%edx
c01034d8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01034db:	8b 40 08             	mov    0x8(%eax),%eax
c01034de:	39 c2                	cmp    %eax,%edx
c01034e0:	72 24                	jb     c0103506 <check_vma_overlap+0xa2>
c01034e2:	c7 44 24 0c bf a7 10 	movl   $0xc010a7bf,0xc(%esp)
c01034e9:	c0 
c01034ea:	c7 44 24 08 7b a7 10 	movl   $0xc010a77b,0x8(%esp)
c01034f1:	c0 
c01034f2:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c01034f9:	00 
c01034fa:	c7 04 24 90 a7 10 c0 	movl   $0xc010a790,(%esp)
c0103501:	e8 fa ce ff ff       	call   c0100400 <__panic>
}
c0103506:	c9                   	leave  
c0103507:	c3                   	ret    

c0103508 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
c0103508:	55                   	push   %ebp
c0103509:	89 e5                	mov    %esp,%ebp
c010350b:	83 ec 48             	sub    $0x48,%esp
    assert(vma->vm_start < vma->vm_end);
c010350e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103511:	8b 50 04             	mov    0x4(%eax),%edx
c0103514:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103517:	8b 40 08             	mov    0x8(%eax),%eax
c010351a:	39 c2                	cmp    %eax,%edx
c010351c:	72 24                	jb     c0103542 <insert_vma_struct+0x3a>
c010351e:	c7 44 24 0c dd a7 10 	movl   $0xc010a7dd,0xc(%esp)
c0103525:	c0 
c0103526:	c7 44 24 08 7b a7 10 	movl   $0xc010a77b,0x8(%esp)
c010352d:	c0 
c010352e:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
c0103535:	00 
c0103536:	c7 04 24 90 a7 10 c0 	movl   $0xc010a790,(%esp)
c010353d:	e8 be ce ff ff       	call   c0100400 <__panic>
    list_entry_t *list = &(mm->mmap_list);
c0103542:	8b 45 08             	mov    0x8(%ebp),%eax
c0103545:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_entry_t *le_prev = list, *le_next;
c0103548:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010354b:	89 45 f4             	mov    %eax,-0xc(%ebp)

        list_entry_t *le = list;
c010354e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103551:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while ((le = list_next(le)) != list) {
c0103554:	eb 21                	jmp    c0103577 <insert_vma_struct+0x6f>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
c0103556:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103559:	83 e8 10             	sub    $0x10,%eax
c010355c:	89 45 e8             	mov    %eax,-0x18(%ebp)
            if (mmap_prev->vm_start > vma->vm_start) {
c010355f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103562:	8b 50 04             	mov    0x4(%eax),%edx
c0103565:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103568:	8b 40 04             	mov    0x4(%eax),%eax
c010356b:	39 c2                	cmp    %eax,%edx
c010356d:	76 02                	jbe    c0103571 <insert_vma_struct+0x69>
                break;
c010356f:	eb 1d                	jmp    c010358e <insert_vma_struct+0x86>
            }
            le_prev = le;
c0103571:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103574:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103577:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010357a:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010357d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103580:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list) {
c0103583:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103586:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103589:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010358c:	75 c8                	jne    c0103556 <insert_vma_struct+0x4e>
c010358e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103591:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103594:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103597:	8b 40 04             	mov    0x4(%eax),%eax
        }

    le_next = list_next(le_prev);
c010359a:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    /* check overlap */
    if (le_prev != list) {
c010359d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035a0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01035a3:	74 15                	je     c01035ba <insert_vma_struct+0xb2>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
c01035a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035a8:	8d 50 f0             	lea    -0x10(%eax),%edx
c01035ab:	8b 45 0c             	mov    0xc(%ebp),%eax
c01035ae:	89 44 24 04          	mov    %eax,0x4(%esp)
c01035b2:	89 14 24             	mov    %edx,(%esp)
c01035b5:	e8 aa fe ff ff       	call   c0103464 <check_vma_overlap>
    }
    if (le_next != list) {
c01035ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01035bd:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01035c0:	74 15                	je     c01035d7 <insert_vma_struct+0xcf>
        check_vma_overlap(vma, le2vma(le_next, list_link));
c01035c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01035c5:	83 e8 10             	sub    $0x10,%eax
c01035c8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01035cc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01035cf:	89 04 24             	mov    %eax,(%esp)
c01035d2:	e8 8d fe ff ff       	call   c0103464 <check_vma_overlap>
    }

    vma->vm_mm = mm;
c01035d7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01035da:	8b 55 08             	mov    0x8(%ebp),%edx
c01035dd:	89 10                	mov    %edx,(%eax)
    list_add_after(le_prev, &(vma->list_link));
c01035df:	8b 45 0c             	mov    0xc(%ebp),%eax
c01035e2:	8d 50 10             	lea    0x10(%eax),%edx
c01035e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01035eb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
c01035ee:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01035f1:	8b 40 04             	mov    0x4(%eax),%eax
c01035f4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01035f7:	89 55 d0             	mov    %edx,-0x30(%ebp)
c01035fa:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01035fd:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0103600:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0103603:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103606:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103609:	89 10                	mov    %edx,(%eax)
c010360b:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010360e:	8b 10                	mov    (%eax),%edx
c0103610:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103613:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103616:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103619:	8b 55 c8             	mov    -0x38(%ebp),%edx
c010361c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010361f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103622:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0103625:	89 10                	mov    %edx,(%eax)

    mm->map_count ++;
c0103627:	8b 45 08             	mov    0x8(%ebp),%eax
c010362a:	8b 40 10             	mov    0x10(%eax),%eax
c010362d:	8d 50 01             	lea    0x1(%eax),%edx
c0103630:	8b 45 08             	mov    0x8(%ebp),%eax
c0103633:	89 50 10             	mov    %edx,0x10(%eax)
}
c0103636:	c9                   	leave  
c0103637:	c3                   	ret    

c0103638 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
c0103638:	55                   	push   %ebp
c0103639:	89 e5                	mov    %esp,%ebp
c010363b:	83 ec 38             	sub    $0x38,%esp

    list_entry_t *list = &(mm->mmap_list), *le;
c010363e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103641:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(list)) != list) {
c0103644:	eb 36                	jmp    c010367c <mm_destroy+0x44>
c0103646:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103649:	89 45 ec             	mov    %eax,-0x14(%ebp)
    __list_del(listelm->prev, listelm->next);
c010364c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010364f:	8b 40 04             	mov    0x4(%eax),%eax
c0103652:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0103655:	8b 12                	mov    (%edx),%edx
c0103657:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010365a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c010365d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103660:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103663:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103666:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103669:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010366c:	89 10                	mov    %edx,(%eax)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
c010366e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103671:	83 e8 10             	sub    $0x10,%eax
c0103674:	89 04 24             	mov    %eax,(%esp)
c0103677:	e8 ad 14 00 00       	call   c0104b29 <kfree>
c010367c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010367f:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
c0103682:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103685:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(list)) != list) {
c0103688:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010368b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010368e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103691:	75 b3                	jne    c0103646 <mm_destroy+0xe>
    }
    kfree(mm); //kfree mm
c0103693:	8b 45 08             	mov    0x8(%ebp),%eax
c0103696:	89 04 24             	mov    %eax,(%esp)
c0103699:	e8 8b 14 00 00       	call   c0104b29 <kfree>
    mm=NULL;
c010369e:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
}
c01036a5:	c9                   	leave  
c01036a6:	c3                   	ret    

c01036a7 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
c01036a7:	55                   	push   %ebp
c01036a8:	89 e5                	mov    %esp,%ebp
c01036aa:	83 ec 08             	sub    $0x8,%esp
    check_vmm();
c01036ad:	e8 02 00 00 00       	call   c01036b4 <check_vmm>
}
c01036b2:	c9                   	leave  
c01036b3:	c3                   	ret    

c01036b4 <check_vmm>:

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
c01036b4:	55                   	push   %ebp
c01036b5:	89 e5                	mov    %esp,%ebp
c01036b7:	83 ec 28             	sub    $0x28,%esp
    size_t nr_free_pages_store = nr_free_pages();
c01036ba:	e8 7f 36 00 00       	call   c0106d3e <nr_free_pages>
c01036bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    
    check_vma_struct();
c01036c2:	e8 13 00 00 00       	call   c01036da <check_vma_struct>
    check_pgfault();
c01036c7:	e8 a7 04 00 00       	call   c0103b73 <check_pgfault>

    cprintf("check_vmm() succeeded.\n");
c01036cc:	c7 04 24 f9 a7 10 c0 	movl   $0xc010a7f9,(%esp)
c01036d3:	e8 d1 cb ff ff       	call   c01002a9 <cprintf>
}
c01036d8:	c9                   	leave  
c01036d9:	c3                   	ret    

c01036da <check_vma_struct>:

static void
check_vma_struct(void) {
c01036da:	55                   	push   %ebp
c01036db:	89 e5                	mov    %esp,%ebp
c01036dd:	83 ec 68             	sub    $0x68,%esp
    size_t nr_free_pages_store = nr_free_pages();
c01036e0:	e8 59 36 00 00       	call   c0106d3e <nr_free_pages>
c01036e5:	89 45 ec             	mov    %eax,-0x14(%ebp)

    struct mm_struct *mm = mm_create();
c01036e8:	e8 13 fc ff ff       	call   c0103300 <mm_create>
c01036ed:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(mm != NULL);
c01036f0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01036f4:	75 24                	jne    c010371a <check_vma_struct+0x40>
c01036f6:	c7 44 24 0c 11 a8 10 	movl   $0xc010a811,0xc(%esp)
c01036fd:	c0 
c01036fe:	c7 44 24 08 7b a7 10 	movl   $0xc010a77b,0x8(%esp)
c0103705:	c0 
c0103706:	c7 44 24 04 b2 00 00 	movl   $0xb2,0x4(%esp)
c010370d:	00 
c010370e:	c7 04 24 90 a7 10 c0 	movl   $0xc010a790,(%esp)
c0103715:	e8 e6 cc ff ff       	call   c0100400 <__panic>

    int step1 = 10, step2 = step1 * 10;
c010371a:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
c0103721:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103724:	89 d0                	mov    %edx,%eax
c0103726:	c1 e0 02             	shl    $0x2,%eax
c0103729:	01 d0                	add    %edx,%eax
c010372b:	01 c0                	add    %eax,%eax
c010372d:	89 45 e0             	mov    %eax,-0x20(%ebp)

    int i;
    for (i = step1; i >= 1; i --) {
c0103730:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103733:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103736:	eb 70                	jmp    c01037a8 <check_vma_struct+0xce>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0103738:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010373b:	89 d0                	mov    %edx,%eax
c010373d:	c1 e0 02             	shl    $0x2,%eax
c0103740:	01 d0                	add    %edx,%eax
c0103742:	83 c0 02             	add    $0x2,%eax
c0103745:	89 c1                	mov    %eax,%ecx
c0103747:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010374a:	89 d0                	mov    %edx,%eax
c010374c:	c1 e0 02             	shl    $0x2,%eax
c010374f:	01 d0                	add    %edx,%eax
c0103751:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103758:	00 
c0103759:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c010375d:	89 04 24             	mov    %eax,(%esp)
c0103760:	e8 13 fc ff ff       	call   c0103378 <vma_create>
c0103765:	89 45 dc             	mov    %eax,-0x24(%ebp)
        assert(vma != NULL);
c0103768:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010376c:	75 24                	jne    c0103792 <check_vma_struct+0xb8>
c010376e:	c7 44 24 0c 1c a8 10 	movl   $0xc010a81c,0xc(%esp)
c0103775:	c0 
c0103776:	c7 44 24 08 7b a7 10 	movl   $0xc010a77b,0x8(%esp)
c010377d:	c0 
c010377e:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
c0103785:	00 
c0103786:	c7 04 24 90 a7 10 c0 	movl   $0xc010a790,(%esp)
c010378d:	e8 6e cc ff ff       	call   c0100400 <__panic>
        insert_vma_struct(mm, vma);
c0103792:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103795:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103799:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010379c:	89 04 24             	mov    %eax,(%esp)
c010379f:	e8 64 fd ff ff       	call   c0103508 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
c01037a4:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01037a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01037ac:	7f 8a                	jg     c0103738 <check_vma_struct+0x5e>
    }

    for (i = step1 + 1; i <= step2; i ++) {
c01037ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01037b1:	83 c0 01             	add    $0x1,%eax
c01037b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01037b7:	eb 70                	jmp    c0103829 <check_vma_struct+0x14f>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c01037b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01037bc:	89 d0                	mov    %edx,%eax
c01037be:	c1 e0 02             	shl    $0x2,%eax
c01037c1:	01 d0                	add    %edx,%eax
c01037c3:	83 c0 02             	add    $0x2,%eax
c01037c6:	89 c1                	mov    %eax,%ecx
c01037c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01037cb:	89 d0                	mov    %edx,%eax
c01037cd:	c1 e0 02             	shl    $0x2,%eax
c01037d0:	01 d0                	add    %edx,%eax
c01037d2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01037d9:	00 
c01037da:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c01037de:	89 04 24             	mov    %eax,(%esp)
c01037e1:	e8 92 fb ff ff       	call   c0103378 <vma_create>
c01037e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
        assert(vma != NULL);
c01037e9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c01037ed:	75 24                	jne    c0103813 <check_vma_struct+0x139>
c01037ef:	c7 44 24 0c 1c a8 10 	movl   $0xc010a81c,0xc(%esp)
c01037f6:	c0 
c01037f7:	c7 44 24 08 7b a7 10 	movl   $0xc010a77b,0x8(%esp)
c01037fe:	c0 
c01037ff:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
c0103806:	00 
c0103807:	c7 04 24 90 a7 10 c0 	movl   $0xc010a790,(%esp)
c010380e:	e8 ed cb ff ff       	call   c0100400 <__panic>
        insert_vma_struct(mm, vma);
c0103813:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103816:	89 44 24 04          	mov    %eax,0x4(%esp)
c010381a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010381d:	89 04 24             	mov    %eax,(%esp)
c0103820:	e8 e3 fc ff ff       	call   c0103508 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
c0103825:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0103829:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010382c:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c010382f:	7e 88                	jle    c01037b9 <check_vma_struct+0xdf>
    }

    list_entry_t *le = list_next(&(mm->mmap_list));
c0103831:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103834:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0103837:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010383a:	8b 40 04             	mov    0x4(%eax),%eax
c010383d:	89 45 f0             	mov    %eax,-0x10(%ebp)

    for (i = 1; i <= step2; i ++) {
c0103840:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c0103847:	e9 97 00 00 00       	jmp    c01038e3 <check_vma_struct+0x209>
        assert(le != &(mm->mmap_list));
c010384c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010384f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103852:	75 24                	jne    c0103878 <check_vma_struct+0x19e>
c0103854:	c7 44 24 0c 28 a8 10 	movl   $0xc010a828,0xc(%esp)
c010385b:	c0 
c010385c:	c7 44 24 08 7b a7 10 	movl   $0xc010a77b,0x8(%esp)
c0103863:	c0 
c0103864:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
c010386b:	00 
c010386c:	c7 04 24 90 a7 10 c0 	movl   $0xc010a790,(%esp)
c0103873:	e8 88 cb ff ff       	call   c0100400 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
c0103878:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010387b:	83 e8 10             	sub    $0x10,%eax
c010387e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
c0103881:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103884:	8b 48 04             	mov    0x4(%eax),%ecx
c0103887:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010388a:	89 d0                	mov    %edx,%eax
c010388c:	c1 e0 02             	shl    $0x2,%eax
c010388f:	01 d0                	add    %edx,%eax
c0103891:	39 c1                	cmp    %eax,%ecx
c0103893:	75 17                	jne    c01038ac <check_vma_struct+0x1d2>
c0103895:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103898:	8b 48 08             	mov    0x8(%eax),%ecx
c010389b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010389e:	89 d0                	mov    %edx,%eax
c01038a0:	c1 e0 02             	shl    $0x2,%eax
c01038a3:	01 d0                	add    %edx,%eax
c01038a5:	83 c0 02             	add    $0x2,%eax
c01038a8:	39 c1                	cmp    %eax,%ecx
c01038aa:	74 24                	je     c01038d0 <check_vma_struct+0x1f6>
c01038ac:	c7 44 24 0c 40 a8 10 	movl   $0xc010a840,0xc(%esp)
c01038b3:	c0 
c01038b4:	c7 44 24 08 7b a7 10 	movl   $0xc010a77b,0x8(%esp)
c01038bb:	c0 
c01038bc:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
c01038c3:	00 
c01038c4:	c7 04 24 90 a7 10 c0 	movl   $0xc010a790,(%esp)
c01038cb:	e8 30 cb ff ff       	call   c0100400 <__panic>
c01038d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01038d3:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c01038d6:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01038d9:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c01038dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (i = 1; i <= step2; i ++) {
c01038df:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01038e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038e6:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01038e9:	0f 8e 5d ff ff ff    	jle    c010384c <check_vma_struct+0x172>
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c01038ef:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
c01038f6:	e9 cd 01 00 00       	jmp    c0103ac8 <check_vma_struct+0x3ee>
        struct vma_struct *vma1 = find_vma(mm, i);
c01038fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038fe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103902:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103905:	89 04 24             	mov    %eax,(%esp)
c0103908:	e8 a6 fa ff ff       	call   c01033b3 <find_vma>
c010390d:	89 45 d0             	mov    %eax,-0x30(%ebp)
        assert(vma1 != NULL);
c0103910:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c0103914:	75 24                	jne    c010393a <check_vma_struct+0x260>
c0103916:	c7 44 24 0c 75 a8 10 	movl   $0xc010a875,0xc(%esp)
c010391d:	c0 
c010391e:	c7 44 24 08 7b a7 10 	movl   $0xc010a77b,0x8(%esp)
c0103925:	c0 
c0103926:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c010392d:	00 
c010392e:	c7 04 24 90 a7 10 c0 	movl   $0xc010a790,(%esp)
c0103935:	e8 c6 ca ff ff       	call   c0100400 <__panic>
        struct vma_struct *vma2 = find_vma(mm, i+1);
c010393a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010393d:	83 c0 01             	add    $0x1,%eax
c0103940:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103944:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103947:	89 04 24             	mov    %eax,(%esp)
c010394a:	e8 64 fa ff ff       	call   c01033b3 <find_vma>
c010394f:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(vma2 != NULL);
c0103952:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0103956:	75 24                	jne    c010397c <check_vma_struct+0x2a2>
c0103958:	c7 44 24 0c 82 a8 10 	movl   $0xc010a882,0xc(%esp)
c010395f:	c0 
c0103960:	c7 44 24 08 7b a7 10 	movl   $0xc010a77b,0x8(%esp)
c0103967:	c0 
c0103968:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
c010396f:	00 
c0103970:	c7 04 24 90 a7 10 c0 	movl   $0xc010a790,(%esp)
c0103977:	e8 84 ca ff ff       	call   c0100400 <__panic>
        struct vma_struct *vma3 = find_vma(mm, i+2);
c010397c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010397f:	83 c0 02             	add    $0x2,%eax
c0103982:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103986:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103989:	89 04 24             	mov    %eax,(%esp)
c010398c:	e8 22 fa ff ff       	call   c01033b3 <find_vma>
c0103991:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(vma3 == NULL);
c0103994:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0103998:	74 24                	je     c01039be <check_vma_struct+0x2e4>
c010399a:	c7 44 24 0c 8f a8 10 	movl   $0xc010a88f,0xc(%esp)
c01039a1:	c0 
c01039a2:	c7 44 24 08 7b a7 10 	movl   $0xc010a77b,0x8(%esp)
c01039a9:	c0 
c01039aa:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
c01039b1:	00 
c01039b2:	c7 04 24 90 a7 10 c0 	movl   $0xc010a790,(%esp)
c01039b9:	e8 42 ca ff ff       	call   c0100400 <__panic>
        struct vma_struct *vma4 = find_vma(mm, i+3);
c01039be:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039c1:	83 c0 03             	add    $0x3,%eax
c01039c4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01039c8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01039cb:	89 04 24             	mov    %eax,(%esp)
c01039ce:	e8 e0 f9 ff ff       	call   c01033b3 <find_vma>
c01039d3:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        assert(vma4 == NULL);
c01039d6:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
c01039da:	74 24                	je     c0103a00 <check_vma_struct+0x326>
c01039dc:	c7 44 24 0c 9c a8 10 	movl   $0xc010a89c,0xc(%esp)
c01039e3:	c0 
c01039e4:	c7 44 24 08 7b a7 10 	movl   $0xc010a77b,0x8(%esp)
c01039eb:	c0 
c01039ec:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
c01039f3:	00 
c01039f4:	c7 04 24 90 a7 10 c0 	movl   $0xc010a790,(%esp)
c01039fb:	e8 00 ca ff ff       	call   c0100400 <__panic>
        struct vma_struct *vma5 = find_vma(mm, i+4);
c0103a00:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a03:	83 c0 04             	add    $0x4,%eax
c0103a06:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103a0a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103a0d:	89 04 24             	mov    %eax,(%esp)
c0103a10:	e8 9e f9 ff ff       	call   c01033b3 <find_vma>
c0103a15:	89 45 c0             	mov    %eax,-0x40(%ebp)
        assert(vma5 == NULL);
c0103a18:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c0103a1c:	74 24                	je     c0103a42 <check_vma_struct+0x368>
c0103a1e:	c7 44 24 0c a9 a8 10 	movl   $0xc010a8a9,0xc(%esp)
c0103a25:	c0 
c0103a26:	c7 44 24 08 7b a7 10 	movl   $0xc010a77b,0x8(%esp)
c0103a2d:	c0 
c0103a2e:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c0103a35:	00 
c0103a36:	c7 04 24 90 a7 10 c0 	movl   $0xc010a790,(%esp)
c0103a3d:	e8 be c9 ff ff       	call   c0100400 <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
c0103a42:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103a45:	8b 50 04             	mov    0x4(%eax),%edx
c0103a48:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a4b:	39 c2                	cmp    %eax,%edx
c0103a4d:	75 10                	jne    c0103a5f <check_vma_struct+0x385>
c0103a4f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103a52:	8b 50 08             	mov    0x8(%eax),%edx
c0103a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a58:	83 c0 02             	add    $0x2,%eax
c0103a5b:	39 c2                	cmp    %eax,%edx
c0103a5d:	74 24                	je     c0103a83 <check_vma_struct+0x3a9>
c0103a5f:	c7 44 24 0c b8 a8 10 	movl   $0xc010a8b8,0xc(%esp)
c0103a66:	c0 
c0103a67:	c7 44 24 08 7b a7 10 	movl   $0xc010a77b,0x8(%esp)
c0103a6e:	c0 
c0103a6f:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
c0103a76:	00 
c0103a77:	c7 04 24 90 a7 10 c0 	movl   $0xc010a790,(%esp)
c0103a7e:	e8 7d c9 ff ff       	call   c0100400 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
c0103a83:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103a86:	8b 50 04             	mov    0x4(%eax),%edx
c0103a89:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a8c:	39 c2                	cmp    %eax,%edx
c0103a8e:	75 10                	jne    c0103aa0 <check_vma_struct+0x3c6>
c0103a90:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103a93:	8b 50 08             	mov    0x8(%eax),%edx
c0103a96:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a99:	83 c0 02             	add    $0x2,%eax
c0103a9c:	39 c2                	cmp    %eax,%edx
c0103a9e:	74 24                	je     c0103ac4 <check_vma_struct+0x3ea>
c0103aa0:	c7 44 24 0c e8 a8 10 	movl   $0xc010a8e8,0xc(%esp)
c0103aa7:	c0 
c0103aa8:	c7 44 24 08 7b a7 10 	movl   $0xc010a77b,0x8(%esp)
c0103aaf:	c0 
c0103ab0:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c0103ab7:	00 
c0103ab8:	c7 04 24 90 a7 10 c0 	movl   $0xc010a790,(%esp)
c0103abf:	e8 3c c9 ff ff       	call   c0100400 <__panic>
    for (i = 5; i <= 5 * step2; i +=5) {
c0103ac4:	83 45 f4 05          	addl   $0x5,-0xc(%ebp)
c0103ac8:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103acb:	89 d0                	mov    %edx,%eax
c0103acd:	c1 e0 02             	shl    $0x2,%eax
c0103ad0:	01 d0                	add    %edx,%eax
c0103ad2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103ad5:	0f 8d 20 fe ff ff    	jge    c01038fb <check_vma_struct+0x221>
    }

    for (i =4; i>=0; i--) {
c0103adb:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
c0103ae2:	eb 70                	jmp    c0103b54 <check_vma_struct+0x47a>
        struct vma_struct *vma_below_5= find_vma(mm,i);
c0103ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ae7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103aeb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103aee:	89 04 24             	mov    %eax,(%esp)
c0103af1:	e8 bd f8 ff ff       	call   c01033b3 <find_vma>
c0103af6:	89 45 bc             	mov    %eax,-0x44(%ebp)
        if (vma_below_5 != NULL ) {
c0103af9:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0103afd:	74 27                	je     c0103b26 <check_vma_struct+0x44c>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
c0103aff:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103b02:	8b 50 08             	mov    0x8(%eax),%edx
c0103b05:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103b08:	8b 40 04             	mov    0x4(%eax),%eax
c0103b0b:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0103b0f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103b13:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b16:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103b1a:	c7 04 24 18 a9 10 c0 	movl   $0xc010a918,(%esp)
c0103b21:	e8 83 c7 ff ff       	call   c01002a9 <cprintf>
        }
        assert(vma_below_5 == NULL);
c0103b26:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0103b2a:	74 24                	je     c0103b50 <check_vma_struct+0x476>
c0103b2c:	c7 44 24 0c 3d a9 10 	movl   $0xc010a93d,0xc(%esp)
c0103b33:	c0 
c0103b34:	c7 44 24 08 7b a7 10 	movl   $0xc010a77b,0x8(%esp)
c0103b3b:	c0 
c0103b3c:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
c0103b43:	00 
c0103b44:	c7 04 24 90 a7 10 c0 	movl   $0xc010a790,(%esp)
c0103b4b:	e8 b0 c8 ff ff       	call   c0100400 <__panic>
    for (i =4; i>=0; i--) {
c0103b50:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0103b54:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103b58:	79 8a                	jns    c0103ae4 <check_vma_struct+0x40a>
    }

    mm_destroy(mm);
c0103b5a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103b5d:	89 04 24             	mov    %eax,(%esp)
c0103b60:	e8 d3 fa ff ff       	call   c0103638 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
c0103b65:	c7 04 24 54 a9 10 c0 	movl   $0xc010a954,(%esp)
c0103b6c:	e8 38 c7 ff ff       	call   c01002a9 <cprintf>
}
c0103b71:	c9                   	leave  
c0103b72:	c3                   	ret    

c0103b73 <check_pgfault>:

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
c0103b73:	55                   	push   %ebp
c0103b74:	89 e5                	mov    %esp,%ebp
c0103b76:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0103b79:	e8 c0 31 00 00       	call   c0106d3e <nr_free_pages>
c0103b7e:	89 45 ec             	mov    %eax,-0x14(%ebp)

    check_mm_struct = mm_create();
c0103b81:	e8 7a f7 ff ff       	call   c0103300 <mm_create>
c0103b86:	a3 58 a0 12 c0       	mov    %eax,0xc012a058
    assert(check_mm_struct != NULL);
c0103b8b:	a1 58 a0 12 c0       	mov    0xc012a058,%eax
c0103b90:	85 c0                	test   %eax,%eax
c0103b92:	75 24                	jne    c0103bb8 <check_pgfault+0x45>
c0103b94:	c7 44 24 0c 73 a9 10 	movl   $0xc010a973,0xc(%esp)
c0103b9b:	c0 
c0103b9c:	c7 44 24 08 7b a7 10 	movl   $0xc010a77b,0x8(%esp)
c0103ba3:	c0 
c0103ba4:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
c0103bab:	00 
c0103bac:	c7 04 24 90 a7 10 c0 	movl   $0xc010a790,(%esp)
c0103bb3:	e8 48 c8 ff ff       	call   c0100400 <__panic>

    struct mm_struct *mm = check_mm_struct;
c0103bb8:	a1 58 a0 12 c0       	mov    0xc012a058,%eax
c0103bbd:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
c0103bc0:	8b 15 20 4a 12 c0    	mov    0xc0124a20,%edx
c0103bc6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103bc9:	89 50 0c             	mov    %edx,0xc(%eax)
c0103bcc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103bcf:	8b 40 0c             	mov    0xc(%eax),%eax
c0103bd2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(pgdir[0] == 0);
c0103bd5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103bd8:	8b 00                	mov    (%eax),%eax
c0103bda:	85 c0                	test   %eax,%eax
c0103bdc:	74 24                	je     c0103c02 <check_pgfault+0x8f>
c0103bde:	c7 44 24 0c 8b a9 10 	movl   $0xc010a98b,0xc(%esp)
c0103be5:	c0 
c0103be6:	c7 44 24 08 7b a7 10 	movl   $0xc010a77b,0x8(%esp)
c0103bed:	c0 
c0103bee:	c7 44 24 04 f5 00 00 	movl   $0xf5,0x4(%esp)
c0103bf5:	00 
c0103bf6:	c7 04 24 90 a7 10 c0 	movl   $0xc010a790,(%esp)
c0103bfd:	e8 fe c7 ff ff       	call   c0100400 <__panic>

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
c0103c02:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
c0103c09:	00 
c0103c0a:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
c0103c11:	00 
c0103c12:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0103c19:	e8 5a f7 ff ff       	call   c0103378 <vma_create>
c0103c1e:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(vma != NULL);
c0103c21:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0103c25:	75 24                	jne    c0103c4b <check_pgfault+0xd8>
c0103c27:	c7 44 24 0c 1c a8 10 	movl   $0xc010a81c,0xc(%esp)
c0103c2e:	c0 
c0103c2f:	c7 44 24 08 7b a7 10 	movl   $0xc010a77b,0x8(%esp)
c0103c36:	c0 
c0103c37:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c0103c3e:	00 
c0103c3f:	c7 04 24 90 a7 10 c0 	movl   $0xc010a790,(%esp)
c0103c46:	e8 b5 c7 ff ff       	call   c0100400 <__panic>

    insert_vma_struct(mm, vma);
c0103c4b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103c4e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103c52:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103c55:	89 04 24             	mov    %eax,(%esp)
c0103c58:	e8 ab f8 ff ff       	call   c0103508 <insert_vma_struct>

    uintptr_t addr = 0x100;
c0103c5d:	c7 45 dc 00 01 00 00 	movl   $0x100,-0x24(%ebp)
    assert(find_vma(mm, addr) == vma);
c0103c64:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103c67:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103c6b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103c6e:	89 04 24             	mov    %eax,(%esp)
c0103c71:	e8 3d f7 ff ff       	call   c01033b3 <find_vma>
c0103c76:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0103c79:	74 24                	je     c0103c9f <check_pgfault+0x12c>
c0103c7b:	c7 44 24 0c 99 a9 10 	movl   $0xc010a999,0xc(%esp)
c0103c82:	c0 
c0103c83:	c7 44 24 08 7b a7 10 	movl   $0xc010a77b,0x8(%esp)
c0103c8a:	c0 
c0103c8b:	c7 44 24 04 fd 00 00 	movl   $0xfd,0x4(%esp)
c0103c92:	00 
c0103c93:	c7 04 24 90 a7 10 c0 	movl   $0xc010a790,(%esp)
c0103c9a:	e8 61 c7 ff ff       	call   c0100400 <__panic>

    int i, sum = 0;
c0103c9f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0103ca6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103cad:	eb 17                	jmp    c0103cc6 <check_pgfault+0x153>
        *(char *)(addr + i) = i;
c0103caf:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103cb2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103cb5:	01 d0                	add    %edx,%eax
c0103cb7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103cba:	88 10                	mov    %dl,(%eax)
        sum += i;
c0103cbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103cbf:	01 45 f0             	add    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0103cc2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0103cc6:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0103cca:	7e e3                	jle    c0103caf <check_pgfault+0x13c>
    }
    for (i = 0; i < 100; i ++) {
c0103ccc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103cd3:	eb 15                	jmp    c0103cea <check_pgfault+0x177>
        sum -= *(char *)(addr + i);
c0103cd5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103cd8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103cdb:	01 d0                	add    %edx,%eax
c0103cdd:	0f b6 00             	movzbl (%eax),%eax
c0103ce0:	0f be c0             	movsbl %al,%eax
c0103ce3:	29 45 f0             	sub    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0103ce6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0103cea:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0103cee:	7e e5                	jle    c0103cd5 <check_pgfault+0x162>
    }
    assert(sum == 0);
c0103cf0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103cf4:	74 24                	je     c0103d1a <check_pgfault+0x1a7>
c0103cf6:	c7 44 24 0c b3 a9 10 	movl   $0xc010a9b3,0xc(%esp)
c0103cfd:	c0 
c0103cfe:	c7 44 24 08 7b a7 10 	movl   $0xc010a77b,0x8(%esp)
c0103d05:	c0 
c0103d06:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
c0103d0d:	00 
c0103d0e:	c7 04 24 90 a7 10 c0 	movl   $0xc010a790,(%esp)
c0103d15:	e8 e6 c6 ff ff       	call   c0100400 <__panic>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
c0103d1a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103d1d:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0103d20:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103d23:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103d28:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103d2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103d2f:	89 04 24             	mov    %eax,(%esp)
c0103d32:	e8 46 38 00 00       	call   c010757d <page_remove>
    free_page(pde2page(pgdir[0]));
c0103d37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103d3a:	8b 00                	mov    (%eax),%eax
c0103d3c:	89 04 24             	mov    %eax,(%esp)
c0103d3f:	e8 a4 f5 ff ff       	call   c01032e8 <pde2page>
c0103d44:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103d4b:	00 
c0103d4c:	89 04 24             	mov    %eax,(%esp)
c0103d4f:	e8 b8 2f 00 00       	call   c0106d0c <free_pages>
    pgdir[0] = 0;
c0103d54:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103d57:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    mm->pgdir = NULL;
c0103d5d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103d60:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    mm_destroy(mm);
c0103d67:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103d6a:	89 04 24             	mov    %eax,(%esp)
c0103d6d:	e8 c6 f8 ff ff       	call   c0103638 <mm_destroy>
    check_mm_struct = NULL;
c0103d72:	c7 05 58 a0 12 c0 00 	movl   $0x0,0xc012a058
c0103d79:	00 00 00 

    assert(nr_free_pages_store == nr_free_pages());
c0103d7c:	e8 bd 2f 00 00       	call   c0106d3e <nr_free_pages>
c0103d81:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103d84:	74 24                	je     c0103daa <check_pgfault+0x237>
c0103d86:	c7 44 24 0c bc a9 10 	movl   $0xc010a9bc,0xc(%esp)
c0103d8d:	c0 
c0103d8e:	c7 44 24 08 7b a7 10 	movl   $0xc010a77b,0x8(%esp)
c0103d95:	c0 
c0103d96:	c7 44 24 04 11 01 00 	movl   $0x111,0x4(%esp)
c0103d9d:	00 
c0103d9e:	c7 04 24 90 a7 10 c0 	movl   $0xc010a790,(%esp)
c0103da5:	e8 56 c6 ff ff       	call   c0100400 <__panic>

    cprintf("check_pgfault() succeeded!\n");
c0103daa:	c7 04 24 e3 a9 10 c0 	movl   $0xc010a9e3,(%esp)
c0103db1:	e8 f3 c4 ff ff       	call   c01002a9 <cprintf>
}
c0103db6:	c9                   	leave  
c0103db7:	c3                   	ret    

c0103db8 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
c0103db8:	55                   	push   %ebp
c0103db9:	89 e5                	mov    %esp,%ebp
c0103dbb:	83 ec 38             	sub    $0x38,%esp
    int ret = -E_INVAL;
c0103dbe:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
c0103dc5:	8b 45 10             	mov    0x10(%ebp),%eax
c0103dc8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103dcc:	8b 45 08             	mov    0x8(%ebp),%eax
c0103dcf:	89 04 24             	mov    %eax,(%esp)
c0103dd2:	e8 dc f5 ff ff       	call   c01033b3 <find_vma>
c0103dd7:	89 45 ec             	mov    %eax,-0x14(%ebp)

    pgfault_num++;
c0103dda:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c0103ddf:	83 c0 01             	add    $0x1,%eax
c0103de2:	a3 64 7f 12 c0       	mov    %eax,0xc0127f64
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
c0103de7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103deb:	74 0b                	je     c0103df8 <do_pgfault+0x40>
c0103ded:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103df0:	8b 40 04             	mov    0x4(%eax),%eax
c0103df3:	3b 45 10             	cmp    0x10(%ebp),%eax
c0103df6:	76 18                	jbe    c0103e10 <do_pgfault+0x58>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
c0103df8:	8b 45 10             	mov    0x10(%ebp),%eax
c0103dfb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103dff:	c7 04 24 00 aa 10 c0 	movl   $0xc010aa00,(%esp)
c0103e06:	e8 9e c4 ff ff       	call   c01002a9 <cprintf>
        goto failed;
c0103e0b:	e9 bb 01 00 00       	jmp    c0103fcb <do_pgfault+0x213>
    }
    //check the error_code
    switch (error_code & 3) {
c0103e10:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103e13:	83 e0 03             	and    $0x3,%eax
c0103e16:	85 c0                	test   %eax,%eax
c0103e18:	74 36                	je     c0103e50 <do_pgfault+0x98>
c0103e1a:	83 f8 01             	cmp    $0x1,%eax
c0103e1d:	74 20                	je     c0103e3f <do_pgfault+0x87>
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
c0103e1f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103e22:	8b 40 0c             	mov    0xc(%eax),%eax
c0103e25:	83 e0 02             	and    $0x2,%eax
c0103e28:	85 c0                	test   %eax,%eax
c0103e2a:	75 11                	jne    c0103e3d <do_pgfault+0x85>
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
c0103e2c:	c7 04 24 30 aa 10 c0 	movl   $0xc010aa30,(%esp)
c0103e33:	e8 71 c4 ff ff       	call   c01002a9 <cprintf>
            goto failed;
c0103e38:	e9 8e 01 00 00       	jmp    c0103fcb <do_pgfault+0x213>
        }
        break;
c0103e3d:	eb 2f                	jmp    c0103e6e <do_pgfault+0xb6>
    case 1: /* error code flag : (W/R=0, P=1): read, present */
        cprintf("do_pgfault failed: error code flag = read AND present\n");
c0103e3f:	c7 04 24 90 aa 10 c0 	movl   $0xc010aa90,(%esp)
c0103e46:	e8 5e c4 ff ff       	call   c01002a9 <cprintf>
        goto failed;
c0103e4b:	e9 7b 01 00 00       	jmp    c0103fcb <do_pgfault+0x213>
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
c0103e50:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103e53:	8b 40 0c             	mov    0xc(%eax),%eax
c0103e56:	83 e0 05             	and    $0x5,%eax
c0103e59:	85 c0                	test   %eax,%eax
c0103e5b:	75 11                	jne    c0103e6e <do_pgfault+0xb6>
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
c0103e5d:	c7 04 24 c8 aa 10 c0 	movl   $0xc010aac8,(%esp)
c0103e64:	e8 40 c4 ff ff       	call   c01002a9 <cprintf>
            goto failed;
c0103e69:	e9 5d 01 00 00       	jmp    c0103fcb <do_pgfault+0x213>
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
c0103e6e:	c7 45 f0 04 00 00 00 	movl   $0x4,-0x10(%ebp)
    if (vma->vm_flags & VM_WRITE) {
c0103e75:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103e78:	8b 40 0c             	mov    0xc(%eax),%eax
c0103e7b:	83 e0 02             	and    $0x2,%eax
c0103e7e:	85 c0                	test   %eax,%eax
c0103e80:	74 04                	je     c0103e86 <do_pgfault+0xce>
        perm |= PTE_W;
c0103e82:	83 4d f0 02          	orl    $0x2,-0x10(%ebp)
    }
    addr = ROUNDDOWN(addr, PGSIZE);
c0103e86:	8b 45 10             	mov    0x10(%ebp),%eax
c0103e89:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103e8c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103e8f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103e94:	89 45 10             	mov    %eax,0x10(%ebp)

    ret = -E_NO_MEM;
c0103e97:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    pte_t *ptep=NULL;
c0103e9e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    *   mm->pgdir : the PDT of these vma
    *
    */
//try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
	//检查页表中是否有相应的应用程序需要的表项，有就获取指向这个表项的指针
	if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
c0103ea5:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ea8:	8b 40 0c             	mov    0xc(%eax),%eax
c0103eab:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0103eb2:	00 
c0103eb3:	8b 55 10             	mov    0x10(%ebp),%edx
c0103eb6:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103eba:	89 04 24             	mov    %eax,(%esp)
c0103ebd:	e8 c3 34 00 00       	call   c0107385 <get_pte>
c0103ec2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103ec5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103ec9:	75 11                	jne    c0103edc <do_pgfault+0x124>
        cprintf("get_pte in do_pgfault failed\n");
c0103ecb:	c7 04 24 2b ab 10 c0 	movl   $0xc010ab2b,(%esp)
c0103ed2:	e8 d2 c3 ff ff       	call   c01002a9 <cprintf>
        goto failed;
c0103ed7:	e9 ef 00 00 00       	jmp    c0103fcb <do_pgfault+0x213>
    }
	//然后检查这个表项是否为空(是否被映射)，如果为空，pgdir_alloc_page分配一个新的物理页
    if (*ptep == 0) {  
c0103edc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103edf:	8b 00                	mov    (%eax),%eax
c0103ee1:	85 c0                	test   %eax,%eax
c0103ee3:	75 35                	jne    c0103f1a <do_pgfault+0x162>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
c0103ee5:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ee8:	8b 40 0c             	mov    0xc(%eax),%eax
c0103eeb:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0103eee:	89 54 24 08          	mov    %edx,0x8(%esp)
c0103ef2:	8b 55 10             	mov    0x10(%ebp),%edx
c0103ef5:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103ef9:	89 04 24             	mov    %eax,(%esp)
c0103efc:	e8 d6 37 00 00       	call   c01076d7 <pgdir_alloc_page>
c0103f01:	85 c0                	test   %eax,%eax
c0103f03:	0f 85 bb 00 00 00    	jne    c0103fc4 <do_pgfault+0x20c>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
c0103f09:	c7 04 24 4c ab 10 c0 	movl   $0xc010ab4c,(%esp)
c0103f10:	e8 94 c3 ff ff       	call   c01002a9 <cprintf>
            goto failed;
c0103f15:	e9 b1 00 00 00       	jmp    c0103fcb <do_pgfault+0x213>
        }
    }
 //如果这个页表项非空，那么说明这一页已经映射过了但是被保存在磁盘中，需要将这一页内存交换出来
// if this pte is a swap entry, then load data from disk to a page with phy addr and call page_insert to map the phy addr with logical addr
    else {   
        if(swap_init_ok) {
c0103f1a:	a1 6c 7f 12 c0       	mov    0xc0127f6c,%eax
c0103f1f:	85 c0                	test   %eax,%eax
c0103f21:	0f 84 86 00 00 00    	je     c0103fad <do_pgfault+0x1f5>
            //如果可以交换
            struct Page *page=NULL; 
c0103f27:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
            //根据mm结构和addr地址，尝试将硬盘中的内容换入至page中
            //load the content of right disk page into the memory which page managed.
            if ((ret = swap_in(mm, addr, &page)) != 0) {
c0103f2e:	8d 45 e0             	lea    -0x20(%ebp),%eax
c0103f31:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103f35:	8b 45 10             	mov    0x10(%ebp),%eax
c0103f38:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103f3c:	8b 45 08             	mov    0x8(%ebp),%eax
c0103f3f:	89 04 24             	mov    %eax,(%esp)
c0103f42:	e8 2a 10 00 00       	call   c0104f71 <swap_in>
c0103f47:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103f4a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103f4e:	74 0e                	je     c0103f5e <do_pgfault+0x1a6>
                cprintf("swap_in in do_pgfault failed\n");
c0103f50:	c7 04 24 73 ab 10 c0 	movl   $0xc010ab73,(%esp)
c0103f57:	e8 4d c3 ff ff       	call   c01002a9 <cprintf>
c0103f5c:	eb 6d                	jmp    c0103fcb <do_pgfault+0x213>
                goto failed;
            }    
            page_insert(mm->pgdir, page, addr, perm); 
c0103f5e:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103f61:	8b 45 08             	mov    0x8(%ebp),%eax
c0103f64:	8b 40 0c             	mov    0xc(%eax),%eax
c0103f67:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0103f6a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0103f6e:	8b 4d 10             	mov    0x10(%ebp),%ecx
c0103f71:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0103f75:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103f79:	89 04 24             	mov    %eax,(%esp)
c0103f7c:	e8 40 36 00 00       	call   c01075c1 <page_insert>
            //建立虚拟地址和物理地址之间的对应关系 According to the mm, addr AND page, setup the map of phy addr <---> logical addr
            swap_map_swappable(mm, addr, page, 1); 
c0103f81:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103f84:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c0103f8b:	00 
c0103f8c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103f90:	8b 45 10             	mov    0x10(%ebp),%eax
c0103f93:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103f97:	8b 45 08             	mov    0x8(%ebp),%eax
c0103f9a:	89 04 24             	mov    %eax,(%esp)
c0103f9d:	e8 06 0e 00 00       	call   c0104da8 <swap_map_swappable>
            //将此页面设置为可交换的 make the page swappable.  
            page->pra_vaddr = addr;
c0103fa2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103fa5:	8b 55 10             	mov    0x10(%ebp),%edx
c0103fa8:	89 50 1c             	mov    %edx,0x1c(%eax)
c0103fab:	eb 17                	jmp    c0103fc4 <do_pgfault+0x20c>
        }
        else {
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
c0103fad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103fb0:	8b 00                	mov    (%eax),%eax
c0103fb2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103fb6:	c7 04 24 94 ab 10 c0 	movl   $0xc010ab94,(%esp)
c0103fbd:	e8 e7 c2 ff ff       	call   c01002a9 <cprintf>
            goto failed;
c0103fc2:	eb 07                	jmp    c0103fcb <do_pgfault+0x213>
        }
   }
   ret = 0;
c0103fc4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
failed:
    return ret;
c0103fcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103fce:	c9                   	leave  
c0103fcf:	c3                   	ret    

c0103fd0 <_fifo_init_mm>:
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
c0103fd0:	55                   	push   %ebp
c0103fd1:	89 e5                	mov    %esp,%ebp
c0103fd3:	83 ec 10             	sub    $0x10,%esp
c0103fd6:	c7 45 fc 5c a0 12 c0 	movl   $0xc012a05c,-0x4(%ebp)
    elm->prev = elm->next = elm;
c0103fdd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103fe0:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0103fe3:	89 50 04             	mov    %edx,0x4(%eax)
c0103fe6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103fe9:	8b 50 04             	mov    0x4(%eax),%edx
c0103fec:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103fef:	89 10                	mov    %edx,(%eax)
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
c0103ff1:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ff4:	c7 40 14 5c a0 12 c0 	movl   $0xc012a05c,0x14(%eax)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
c0103ffb:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104000:	c9                   	leave  
c0104001:	c3                   	ret    

c0104002 <_fifo_map_swappable>:
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0104002:	55                   	push   %ebp
c0104003:	89 e5                	mov    %esp,%ebp
c0104005:	83 ec 48             	sub    $0x48,%esp
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0104008:	8b 45 08             	mov    0x8(%ebp),%eax
c010400b:	8b 40 14             	mov    0x14(%eax),%eax
c010400e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry=&(page->pra_page_link);
c0104011:	8b 45 10             	mov    0x10(%ebp),%eax
c0104014:	83 c0 14             	add    $0x14,%eax
c0104017:	89 45 f0             	mov    %eax,-0x10(%ebp)
 
    assert(entry != NULL && head != NULL);
c010401a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010401e:	74 06                	je     c0104026 <_fifo_map_swappable+0x24>
c0104020:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104024:	75 24                	jne    c010404a <_fifo_map_swappable+0x48>
c0104026:	c7 44 24 0c bc ab 10 	movl   $0xc010abbc,0xc(%esp)
c010402d:	c0 
c010402e:	c7 44 24 08 da ab 10 	movl   $0xc010abda,0x8(%esp)
c0104035:	c0 
c0104036:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
c010403d:	00 
c010403e:	c7 04 24 ef ab 10 c0 	movl   $0xc010abef,(%esp)
c0104045:	e8 b6 c3 ff ff       	call   c0100400 <__panic>
c010404a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010404d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104050:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104053:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104056:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104059:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010405c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010405f:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_add(elm, listelm, listelm->next);
c0104062:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104065:	8b 40 04             	mov    0x4(%eax),%eax
c0104068:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010406b:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010406e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104071:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0104074:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    prev->next = next->prev = elm;
c0104077:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010407a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010407d:	89 10                	mov    %edx,(%eax)
c010407f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104082:	8b 10                	mov    (%eax),%edx
c0104084:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104087:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010408a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010408d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104090:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0104093:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104096:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104099:	89 10                	mov    %edx,(%eax)
    //record the page access situlation
    /*LAB3 EXERCISE 2: YOUR CODE*/ 
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
    list_add(head, entry);
    return 0;
c010409b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01040a0:	c9                   	leave  
c01040a1:	c3                   	ret    

c01040a2 <_fifo_swap_out_victim>:
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then assign the value of *ptr_page to the addr of this page.
 */
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
c01040a2:	55                   	push   %ebp
c01040a3:	89 e5                	mov    %esp,%ebp
c01040a5:	83 ec 38             	sub    $0x38,%esp
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
c01040a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01040ab:	8b 40 14             	mov    0x14(%eax),%eax
c01040ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
         assert(head != NULL);
c01040b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01040b5:	75 24                	jne    c01040db <_fifo_swap_out_victim+0x39>
c01040b7:	c7 44 24 0c 03 ac 10 	movl   $0xc010ac03,0xc(%esp)
c01040be:	c0 
c01040bf:	c7 44 24 08 da ab 10 	movl   $0xc010abda,0x8(%esp)
c01040c6:	c0 
c01040c7:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
c01040ce:	00 
c01040cf:	c7 04 24 ef ab 10 c0 	movl   $0xc010abef,(%esp)
c01040d6:	e8 25 c3 ff ff       	call   c0100400 <__panic>
     assert(in_tick==0);
c01040db:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01040df:	74 24                	je     c0104105 <_fifo_swap_out_victim+0x63>
c01040e1:	c7 44 24 0c 10 ac 10 	movl   $0xc010ac10,0xc(%esp)
c01040e8:	c0 
c01040e9:	c7 44 24 08 da ab 10 	movl   $0xc010abda,0x8(%esp)
c01040f0:	c0 
c01040f1:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
c01040f8:	00 
c01040f9:	c7 04 24 ef ab 10 c0 	movl   $0xc010abef,(%esp)
c0104100:	e8 fb c2 ff ff       	call   c0100400 <__panic>
     /* Select the victim */
     /*LAB3 EXERCISE 2: YOUR CODE*/ 
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  assign the value of *ptr_page to the addr of this page
     //需要被换出的页
     list_entry_t *le = head->prev;
c0104105:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104108:	8b 00                	mov    (%eax),%eax
c010410a:	89 45 f0             	mov    %eax,-0x10(%ebp)
     assert(head!=le);
c010410d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104110:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104113:	75 24                	jne    c0104139 <_fifo_swap_out_victim+0x97>
c0104115:	c7 44 24 0c 1b ac 10 	movl   $0xc010ac1b,0xc(%esp)
c010411c:	c0 
c010411d:	c7 44 24 08 da ab 10 	movl   $0xc010abda,0x8(%esp)
c0104124:	c0 
c0104125:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
c010412c:	00 
c010412d:	c7 04 24 ef ab 10 c0 	movl   $0xc010abef,(%esp)
c0104134:	e8 c7 c2 ff ff       	call   c0100400 <__panic>
     //获得对应page的指针p
     struct Page *p = le2page(le, pra_page_link);
c0104139:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010413c:	83 e8 14             	sub    $0x14,%eax
c010413f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104142:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104145:	89 45 e8             	mov    %eax,-0x18(%ebp)
    __list_del(listelm->prev, listelm->next);
c0104148:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010414b:	8b 40 04             	mov    0x4(%eax),%eax
c010414e:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104151:	8b 12                	mov    (%edx),%edx
c0104153:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0104156:	89 45 e0             	mov    %eax,-0x20(%ebp)
    prev->next = next;
c0104159:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010415c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010415f:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0104162:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104165:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104168:	89 10                	mov    %edx,(%eax)
     //将最老的页面从队列中删除
     list_del(le);
     assert(p !=NULL);
c010416a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010416e:	75 24                	jne    c0104194 <_fifo_swap_out_victim+0xf2>
c0104170:	c7 44 24 0c 24 ac 10 	movl   $0xc010ac24,0xc(%esp)
c0104177:	c0 
c0104178:	c7 44 24 08 da ab 10 	movl   $0xc010abda,0x8(%esp)
c010417f:	c0 
c0104180:	c7 44 24 04 4e 00 00 	movl   $0x4e,0x4(%esp)
c0104187:	00 
c0104188:	c7 04 24 ef ab 10 c0 	movl   $0xc010abef,(%esp)
c010418f:	e8 6c c2 ff ff       	call   c0100400 <__panic>
     //将这一页的地址存储在ptr_page中
     *ptr_page = p;
c0104194:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104197:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010419a:	89 10                	mov    %edx,(%eax)
     return 0;
c010419c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01041a1:	c9                   	leave  
c01041a2:	c3                   	ret    

c01041a3 <_fifo_check_swap>:

static int
_fifo_check_swap(void) {
c01041a3:	55                   	push   %ebp
c01041a4:	89 e5                	mov    %esp,%ebp
c01041a6:	83 ec 18             	sub    $0x18,%esp
    cprintf("write Virt Page c in fifo_check_swap\n");
c01041a9:	c7 04 24 30 ac 10 c0 	movl   $0xc010ac30,(%esp)
c01041b0:	e8 f4 c0 ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c01041b5:	b8 00 30 00 00       	mov    $0x3000,%eax
c01041ba:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==4);
c01041bd:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c01041c2:	83 f8 04             	cmp    $0x4,%eax
c01041c5:	74 24                	je     c01041eb <_fifo_check_swap+0x48>
c01041c7:	c7 44 24 0c 56 ac 10 	movl   $0xc010ac56,0xc(%esp)
c01041ce:	c0 
c01041cf:	c7 44 24 08 da ab 10 	movl   $0xc010abda,0x8(%esp)
c01041d6:	c0 
c01041d7:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
c01041de:	00 
c01041df:	c7 04 24 ef ab 10 c0 	movl   $0xc010abef,(%esp)
c01041e6:	e8 15 c2 ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c01041eb:	c7 04 24 68 ac 10 c0 	movl   $0xc010ac68,(%esp)
c01041f2:	e8 b2 c0 ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c01041f7:	b8 00 10 00 00       	mov    $0x1000,%eax
c01041fc:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==4);
c01041ff:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c0104204:	83 f8 04             	cmp    $0x4,%eax
c0104207:	74 24                	je     c010422d <_fifo_check_swap+0x8a>
c0104209:	c7 44 24 0c 56 ac 10 	movl   $0xc010ac56,0xc(%esp)
c0104210:	c0 
c0104211:	c7 44 24 08 da ab 10 	movl   $0xc010abda,0x8(%esp)
c0104218:	c0 
c0104219:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c0104220:	00 
c0104221:	c7 04 24 ef ab 10 c0 	movl   $0xc010abef,(%esp)
c0104228:	e8 d3 c1 ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c010422d:	c7 04 24 90 ac 10 c0 	movl   $0xc010ac90,(%esp)
c0104234:	e8 70 c0 ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0104239:	b8 00 40 00 00       	mov    $0x4000,%eax
c010423e:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==4);
c0104241:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c0104246:	83 f8 04             	cmp    $0x4,%eax
c0104249:	74 24                	je     c010426f <_fifo_check_swap+0xcc>
c010424b:	c7 44 24 0c 56 ac 10 	movl   $0xc010ac56,0xc(%esp)
c0104252:	c0 
c0104253:	c7 44 24 08 da ab 10 	movl   $0xc010abda,0x8(%esp)
c010425a:	c0 
c010425b:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0104262:	00 
c0104263:	c7 04 24 ef ab 10 c0 	movl   $0xc010abef,(%esp)
c010426a:	e8 91 c1 ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c010426f:	c7 04 24 b8 ac 10 c0 	movl   $0xc010acb8,(%esp)
c0104276:	e8 2e c0 ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c010427b:	b8 00 20 00 00       	mov    $0x2000,%eax
c0104280:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==4);
c0104283:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c0104288:	83 f8 04             	cmp    $0x4,%eax
c010428b:	74 24                	je     c01042b1 <_fifo_check_swap+0x10e>
c010428d:	c7 44 24 0c 56 ac 10 	movl   $0xc010ac56,0xc(%esp)
c0104294:	c0 
c0104295:	c7 44 24 08 da ab 10 	movl   $0xc010abda,0x8(%esp)
c010429c:	c0 
c010429d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c01042a4:	00 
c01042a5:	c7 04 24 ef ab 10 c0 	movl   $0xc010abef,(%esp)
c01042ac:	e8 4f c1 ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c01042b1:	c7 04 24 e0 ac 10 c0 	movl   $0xc010ace0,(%esp)
c01042b8:	e8 ec bf ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c01042bd:	b8 00 50 00 00       	mov    $0x5000,%eax
c01042c2:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==5);
c01042c5:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c01042ca:	83 f8 05             	cmp    $0x5,%eax
c01042cd:	74 24                	je     c01042f3 <_fifo_check_swap+0x150>
c01042cf:	c7 44 24 0c 06 ad 10 	movl   $0xc010ad06,0xc(%esp)
c01042d6:	c0 
c01042d7:	c7 44 24 08 da ab 10 	movl   $0xc010abda,0x8(%esp)
c01042de:	c0 
c01042df:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c01042e6:	00 
c01042e7:	c7 04 24 ef ab 10 c0 	movl   $0xc010abef,(%esp)
c01042ee:	e8 0d c1 ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c01042f3:	c7 04 24 b8 ac 10 c0 	movl   $0xc010acb8,(%esp)
c01042fa:	e8 aa bf ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c01042ff:	b8 00 20 00 00       	mov    $0x2000,%eax
c0104304:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==5);
c0104307:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c010430c:	83 f8 05             	cmp    $0x5,%eax
c010430f:	74 24                	je     c0104335 <_fifo_check_swap+0x192>
c0104311:	c7 44 24 0c 06 ad 10 	movl   $0xc010ad06,0xc(%esp)
c0104318:	c0 
c0104319:	c7 44 24 08 da ab 10 	movl   $0xc010abda,0x8(%esp)
c0104320:	c0 
c0104321:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c0104328:	00 
c0104329:	c7 04 24 ef ab 10 c0 	movl   $0xc010abef,(%esp)
c0104330:	e8 cb c0 ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0104335:	c7 04 24 68 ac 10 c0 	movl   $0xc010ac68,(%esp)
c010433c:	e8 68 bf ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0104341:	b8 00 10 00 00       	mov    $0x1000,%eax
c0104346:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==6);
c0104349:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c010434e:	83 f8 06             	cmp    $0x6,%eax
c0104351:	74 24                	je     c0104377 <_fifo_check_swap+0x1d4>
c0104353:	c7 44 24 0c 15 ad 10 	movl   $0xc010ad15,0xc(%esp)
c010435a:	c0 
c010435b:	c7 44 24 08 da ab 10 	movl   $0xc010abda,0x8(%esp)
c0104362:	c0 
c0104363:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c010436a:	00 
c010436b:	c7 04 24 ef ab 10 c0 	movl   $0xc010abef,(%esp)
c0104372:	e8 89 c0 ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0104377:	c7 04 24 b8 ac 10 c0 	movl   $0xc010acb8,(%esp)
c010437e:	e8 26 bf ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0104383:	b8 00 20 00 00       	mov    $0x2000,%eax
c0104388:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==7);
c010438b:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c0104390:	83 f8 07             	cmp    $0x7,%eax
c0104393:	74 24                	je     c01043b9 <_fifo_check_swap+0x216>
c0104395:	c7 44 24 0c 24 ad 10 	movl   $0xc010ad24,0xc(%esp)
c010439c:	c0 
c010439d:	c7 44 24 08 da ab 10 	movl   $0xc010abda,0x8(%esp)
c01043a4:	c0 
c01043a5:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c01043ac:	00 
c01043ad:	c7 04 24 ef ab 10 c0 	movl   $0xc010abef,(%esp)
c01043b4:	e8 47 c0 ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c01043b9:	c7 04 24 30 ac 10 c0 	movl   $0xc010ac30,(%esp)
c01043c0:	e8 e4 be ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c01043c5:	b8 00 30 00 00       	mov    $0x3000,%eax
c01043ca:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==8);
c01043cd:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c01043d2:	83 f8 08             	cmp    $0x8,%eax
c01043d5:	74 24                	je     c01043fb <_fifo_check_swap+0x258>
c01043d7:	c7 44 24 0c 33 ad 10 	movl   $0xc010ad33,0xc(%esp)
c01043de:	c0 
c01043df:	c7 44 24 08 da ab 10 	movl   $0xc010abda,0x8(%esp)
c01043e6:	c0 
c01043e7:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c01043ee:	00 
c01043ef:	c7 04 24 ef ab 10 c0 	movl   $0xc010abef,(%esp)
c01043f6:	e8 05 c0 ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c01043fb:	c7 04 24 90 ac 10 c0 	movl   $0xc010ac90,(%esp)
c0104402:	e8 a2 be ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0104407:	b8 00 40 00 00       	mov    $0x4000,%eax
c010440c:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==9);
c010440f:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c0104414:	83 f8 09             	cmp    $0x9,%eax
c0104417:	74 24                	je     c010443d <_fifo_check_swap+0x29a>
c0104419:	c7 44 24 0c 42 ad 10 	movl   $0xc010ad42,0xc(%esp)
c0104420:	c0 
c0104421:	c7 44 24 08 da ab 10 	movl   $0xc010abda,0x8(%esp)
c0104428:	c0 
c0104429:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
c0104430:	00 
c0104431:	c7 04 24 ef ab 10 c0 	movl   $0xc010abef,(%esp)
c0104438:	e8 c3 bf ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c010443d:	c7 04 24 e0 ac 10 c0 	movl   $0xc010ace0,(%esp)
c0104444:	e8 60 be ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0104449:	b8 00 50 00 00       	mov    $0x5000,%eax
c010444e:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==10);
c0104451:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c0104456:	83 f8 0a             	cmp    $0xa,%eax
c0104459:	74 24                	je     c010447f <_fifo_check_swap+0x2dc>
c010445b:	c7 44 24 0c 51 ad 10 	movl   $0xc010ad51,0xc(%esp)
c0104462:	c0 
c0104463:	c7 44 24 08 da ab 10 	movl   $0xc010abda,0x8(%esp)
c010446a:	c0 
c010446b:	c7 44 24 04 76 00 00 	movl   $0x76,0x4(%esp)
c0104472:	00 
c0104473:	c7 04 24 ef ab 10 c0 	movl   $0xc010abef,(%esp)
c010447a:	e8 81 bf ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c010447f:	c7 04 24 68 ac 10 c0 	movl   $0xc010ac68,(%esp)
c0104486:	e8 1e be ff ff       	call   c01002a9 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
c010448b:	b8 00 10 00 00       	mov    $0x1000,%eax
c0104490:	0f b6 00             	movzbl (%eax),%eax
c0104493:	3c 0a                	cmp    $0xa,%al
c0104495:	74 24                	je     c01044bb <_fifo_check_swap+0x318>
c0104497:	c7 44 24 0c 64 ad 10 	movl   $0xc010ad64,0xc(%esp)
c010449e:	c0 
c010449f:	c7 44 24 08 da ab 10 	movl   $0xc010abda,0x8(%esp)
c01044a6:	c0 
c01044a7:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
c01044ae:	00 
c01044af:	c7 04 24 ef ab 10 c0 	movl   $0xc010abef,(%esp)
c01044b6:	e8 45 bf ff ff       	call   c0100400 <__panic>
    *(unsigned char *)0x1000 = 0x0a;
c01044bb:	b8 00 10 00 00       	mov    $0x1000,%eax
c01044c0:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==11);
c01044c3:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c01044c8:	83 f8 0b             	cmp    $0xb,%eax
c01044cb:	74 24                	je     c01044f1 <_fifo_check_swap+0x34e>
c01044cd:	c7 44 24 0c 85 ad 10 	movl   $0xc010ad85,0xc(%esp)
c01044d4:	c0 
c01044d5:	c7 44 24 08 da ab 10 	movl   $0xc010abda,0x8(%esp)
c01044dc:	c0 
c01044dd:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
c01044e4:	00 
c01044e5:	c7 04 24 ef ab 10 c0 	movl   $0xc010abef,(%esp)
c01044ec:	e8 0f bf ff ff       	call   c0100400 <__panic>
    return 0;
c01044f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01044f6:	c9                   	leave  
c01044f7:	c3                   	ret    

c01044f8 <_fifo_init>:


static int
_fifo_init(void)
{
c01044f8:	55                   	push   %ebp
c01044f9:	89 e5                	mov    %esp,%ebp
    return 0;
c01044fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104500:	5d                   	pop    %ebp
c0104501:	c3                   	ret    

c0104502 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c0104502:	55                   	push   %ebp
c0104503:	89 e5                	mov    %esp,%ebp
    return 0;
c0104505:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010450a:	5d                   	pop    %ebp
c010450b:	c3                   	ret    

c010450c <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
c010450c:	55                   	push   %ebp
c010450d:	89 e5                	mov    %esp,%ebp
c010450f:	b8 00 00 00 00       	mov    $0x0,%eax
c0104514:	5d                   	pop    %ebp
c0104515:	c3                   	ret    

c0104516 <__intr_save>:
__intr_save(void) {
c0104516:	55                   	push   %ebp
c0104517:	89 e5                	mov    %esp,%ebp
c0104519:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010451c:	9c                   	pushf  
c010451d:	58                   	pop    %eax
c010451e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0104521:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0104524:	25 00 02 00 00       	and    $0x200,%eax
c0104529:	85 c0                	test   %eax,%eax
c010452b:	74 0c                	je     c0104539 <__intr_save+0x23>
        intr_disable();
c010452d:	e8 eb db ff ff       	call   c010211d <intr_disable>
        return 1;
c0104532:	b8 01 00 00 00       	mov    $0x1,%eax
c0104537:	eb 05                	jmp    c010453e <__intr_save+0x28>
    return 0;
c0104539:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010453e:	c9                   	leave  
c010453f:	c3                   	ret    

c0104540 <__intr_restore>:
__intr_restore(bool flag) {
c0104540:	55                   	push   %ebp
c0104541:	89 e5                	mov    %esp,%ebp
c0104543:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0104546:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010454a:	74 05                	je     c0104551 <__intr_restore+0x11>
        intr_enable();
c010454c:	e8 c6 db ff ff       	call   c0102117 <intr_enable>
}
c0104551:	c9                   	leave  
c0104552:	c3                   	ret    

c0104553 <page2ppn>:
page2ppn(struct Page *page) {
c0104553:	55                   	push   %ebp
c0104554:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0104556:	8b 55 08             	mov    0x8(%ebp),%edx
c0104559:	a1 58 a1 12 c0       	mov    0xc012a158,%eax
c010455e:	29 c2                	sub    %eax,%edx
c0104560:	89 d0                	mov    %edx,%eax
c0104562:	c1 f8 05             	sar    $0x5,%eax
}
c0104565:	5d                   	pop    %ebp
c0104566:	c3                   	ret    

c0104567 <page2pa>:
page2pa(struct Page *page) {
c0104567:	55                   	push   %ebp
c0104568:	89 e5                	mov    %esp,%ebp
c010456a:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c010456d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104570:	89 04 24             	mov    %eax,(%esp)
c0104573:	e8 db ff ff ff       	call   c0104553 <page2ppn>
c0104578:	c1 e0 0c             	shl    $0xc,%eax
}
c010457b:	c9                   	leave  
c010457c:	c3                   	ret    

c010457d <pa2page>:
pa2page(uintptr_t pa) {
c010457d:	55                   	push   %ebp
c010457e:	89 e5                	mov    %esp,%ebp
c0104580:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0104583:	8b 45 08             	mov    0x8(%ebp),%eax
c0104586:	c1 e8 0c             	shr    $0xc,%eax
c0104589:	89 c2                	mov    %eax,%edx
c010458b:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c0104590:	39 c2                	cmp    %eax,%edx
c0104592:	72 1c                	jb     c01045b0 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0104594:	c7 44 24 08 a8 ad 10 	movl   $0xc010ada8,0x8(%esp)
c010459b:	c0 
c010459c:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c01045a3:	00 
c01045a4:	c7 04 24 c7 ad 10 c0 	movl   $0xc010adc7,(%esp)
c01045ab:	e8 50 be ff ff       	call   c0100400 <__panic>
    return &pages[PPN(pa)];
c01045b0:	a1 58 a1 12 c0       	mov    0xc012a158,%eax
c01045b5:	8b 55 08             	mov    0x8(%ebp),%edx
c01045b8:	c1 ea 0c             	shr    $0xc,%edx
c01045bb:	c1 e2 05             	shl    $0x5,%edx
c01045be:	01 d0                	add    %edx,%eax
}
c01045c0:	c9                   	leave  
c01045c1:	c3                   	ret    

c01045c2 <page2kva>:
page2kva(struct Page *page) {
c01045c2:	55                   	push   %ebp
c01045c3:	89 e5                	mov    %esp,%ebp
c01045c5:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c01045c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01045cb:	89 04 24             	mov    %eax,(%esp)
c01045ce:	e8 94 ff ff ff       	call   c0104567 <page2pa>
c01045d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01045d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045d9:	c1 e8 0c             	shr    $0xc,%eax
c01045dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01045df:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c01045e4:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01045e7:	72 23                	jb     c010460c <page2kva+0x4a>
c01045e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01045f0:	c7 44 24 08 d8 ad 10 	movl   $0xc010add8,0x8(%esp)
c01045f7:	c0 
c01045f8:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c01045ff:	00 
c0104600:	c7 04 24 c7 ad 10 c0 	movl   $0xc010adc7,(%esp)
c0104607:	e8 f4 bd ff ff       	call   c0100400 <__panic>
c010460c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010460f:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0104614:	c9                   	leave  
c0104615:	c3                   	ret    

c0104616 <kva2page>:
kva2page(void *kva) {
c0104616:	55                   	push   %ebp
c0104617:	89 e5                	mov    %esp,%ebp
c0104619:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c010461c:	8b 45 08             	mov    0x8(%ebp),%eax
c010461f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104622:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0104629:	77 23                	ja     c010464e <kva2page+0x38>
c010462b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010462e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104632:	c7 44 24 08 fc ad 10 	movl   $0xc010adfc,0x8(%esp)
c0104639:	c0 
c010463a:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
c0104641:	00 
c0104642:	c7 04 24 c7 ad 10 c0 	movl   $0xc010adc7,(%esp)
c0104649:	e8 b2 bd ff ff       	call   c0100400 <__panic>
c010464e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104651:	05 00 00 00 40       	add    $0x40000000,%eax
c0104656:	89 04 24             	mov    %eax,(%esp)
c0104659:	e8 1f ff ff ff       	call   c010457d <pa2page>
}
c010465e:	c9                   	leave  
c010465f:	c3                   	ret    

c0104660 <__slob_get_free_pages>:
static slob_t *slobfree = &arena;
static bigblock_t *bigblocks;


static void* __slob_get_free_pages(gfp_t gfp, int order)
{
c0104660:	55                   	push   %ebp
c0104661:	89 e5                	mov    %esp,%ebp
c0104663:	83 ec 28             	sub    $0x28,%esp
  struct Page * page = alloc_pages(1 << order);
c0104666:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104669:	ba 01 00 00 00       	mov    $0x1,%edx
c010466e:	89 c1                	mov    %eax,%ecx
c0104670:	d3 e2                	shl    %cl,%edx
c0104672:	89 d0                	mov    %edx,%eax
c0104674:	89 04 24             	mov    %eax,(%esp)
c0104677:	e8 25 26 00 00       	call   c0106ca1 <alloc_pages>
c010467c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!page)
c010467f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104683:	75 07                	jne    c010468c <__slob_get_free_pages+0x2c>
    return NULL;
c0104685:	b8 00 00 00 00       	mov    $0x0,%eax
c010468a:	eb 0b                	jmp    c0104697 <__slob_get_free_pages+0x37>
  return page2kva(page);
c010468c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010468f:	89 04 24             	mov    %eax,(%esp)
c0104692:	e8 2b ff ff ff       	call   c01045c2 <page2kva>
}
c0104697:	c9                   	leave  
c0104698:	c3                   	ret    

c0104699 <__slob_free_pages>:

#define __slob_get_free_page(gfp) __slob_get_free_pages(gfp, 0)

static inline void __slob_free_pages(unsigned long kva, int order)
{
c0104699:	55                   	push   %ebp
c010469a:	89 e5                	mov    %esp,%ebp
c010469c:	53                   	push   %ebx
c010469d:	83 ec 14             	sub    $0x14,%esp
  free_pages(kva2page(kva), 1 << order);
c01046a0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01046a3:	ba 01 00 00 00       	mov    $0x1,%edx
c01046a8:	89 c1                	mov    %eax,%ecx
c01046aa:	d3 e2                	shl    %cl,%edx
c01046ac:	89 d0                	mov    %edx,%eax
c01046ae:	89 c3                	mov    %eax,%ebx
c01046b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01046b3:	89 04 24             	mov    %eax,(%esp)
c01046b6:	e8 5b ff ff ff       	call   c0104616 <kva2page>
c01046bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01046bf:	89 04 24             	mov    %eax,(%esp)
c01046c2:	e8 45 26 00 00       	call   c0106d0c <free_pages>
}
c01046c7:	83 c4 14             	add    $0x14,%esp
c01046ca:	5b                   	pop    %ebx
c01046cb:	5d                   	pop    %ebp
c01046cc:	c3                   	ret    

c01046cd <slob_alloc>:

static void slob_free(void *b, int size);

static void *slob_alloc(size_t size, gfp_t gfp, int align)
{
c01046cd:	55                   	push   %ebp
c01046ce:	89 e5                	mov    %esp,%ebp
c01046d0:	83 ec 38             	sub    $0x38,%esp
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
c01046d3:	8b 45 08             	mov    0x8(%ebp),%eax
c01046d6:	83 c0 08             	add    $0x8,%eax
c01046d9:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c01046de:	76 24                	jbe    c0104704 <slob_alloc+0x37>
c01046e0:	c7 44 24 0c 20 ae 10 	movl   $0xc010ae20,0xc(%esp)
c01046e7:	c0 
c01046e8:	c7 44 24 08 3f ae 10 	movl   $0xc010ae3f,0x8(%esp)
c01046ef:	c0 
c01046f0:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c01046f7:	00 
c01046f8:	c7 04 24 54 ae 10 c0 	movl   $0xc010ae54,(%esp)
c01046ff:	e8 fc bc ff ff       	call   c0100400 <__panic>

	slob_t *prev, *cur, *aligned = 0;
c0104704:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	int delta = 0, units = SLOB_UNITS(size);
c010470b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0104712:	8b 45 08             	mov    0x8(%ebp),%eax
c0104715:	83 c0 07             	add    $0x7,%eax
c0104718:	c1 e8 03             	shr    $0x3,%eax
c010471b:	89 45 e0             	mov    %eax,-0x20(%ebp)
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
c010471e:	e8 f3 fd ff ff       	call   c0104516 <__intr_save>
c0104723:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	prev = slobfree;
c0104726:	a1 08 4a 12 c0       	mov    0xc0124a08,%eax
c010472b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c010472e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104731:	8b 40 04             	mov    0x4(%eax),%eax
c0104734:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (align) {
c0104737:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010473b:	74 25                	je     c0104762 <slob_alloc+0x95>
			aligned = (slob_t *)ALIGN((unsigned long)cur, align);
c010473d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104740:	8b 45 10             	mov    0x10(%ebp),%eax
c0104743:	01 d0                	add    %edx,%eax
c0104745:	8d 50 ff             	lea    -0x1(%eax),%edx
c0104748:	8b 45 10             	mov    0x10(%ebp),%eax
c010474b:	f7 d8                	neg    %eax
c010474d:	21 d0                	and    %edx,%eax
c010474f:	89 45 ec             	mov    %eax,-0x14(%ebp)
			delta = aligned - cur;
c0104752:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104755:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104758:	29 c2                	sub    %eax,%edx
c010475a:	89 d0                	mov    %edx,%eax
c010475c:	c1 f8 03             	sar    $0x3,%eax
c010475f:	89 45 e8             	mov    %eax,-0x18(%ebp)
		}
		if (cur->units >= units + delta) { /* room enough? */
c0104762:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104765:	8b 00                	mov    (%eax),%eax
c0104767:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010476a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c010476d:	01 ca                	add    %ecx,%edx
c010476f:	39 d0                	cmp    %edx,%eax
c0104771:	0f 8c aa 00 00 00    	jl     c0104821 <slob_alloc+0x154>
			if (delta) { /* need to fragment head to align? */
c0104777:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010477b:	74 38                	je     c01047b5 <slob_alloc+0xe8>
				aligned->units = cur->units - delta;
c010477d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104780:	8b 00                	mov    (%eax),%eax
c0104782:	2b 45 e8             	sub    -0x18(%ebp),%eax
c0104785:	89 c2                	mov    %eax,%edx
c0104787:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010478a:	89 10                	mov    %edx,(%eax)
				aligned->next = cur->next;
c010478c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010478f:	8b 50 04             	mov    0x4(%eax),%edx
c0104792:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104795:	89 50 04             	mov    %edx,0x4(%eax)
				cur->next = aligned;
c0104798:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010479b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010479e:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = delta;
c01047a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047a4:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01047a7:	89 10                	mov    %edx,(%eax)
				prev = cur;
c01047a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
				cur = aligned;
c01047af:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01047b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
			}

			if (cur->units == units) /* exact fit? */
c01047b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047b8:	8b 00                	mov    (%eax),%eax
c01047ba:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01047bd:	75 0e                	jne    c01047cd <slob_alloc+0x100>
				prev->next = cur->next; /* unlink */
c01047bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047c2:	8b 50 04             	mov    0x4(%eax),%edx
c01047c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047c8:	89 50 04             	mov    %edx,0x4(%eax)
c01047cb:	eb 3c                	jmp    c0104809 <slob_alloc+0x13c>
			else { /* fragment */
				prev->next = cur + units;
c01047cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01047d0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01047d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047da:	01 c2                	add    %eax,%edx
c01047dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047df:	89 50 04             	mov    %edx,0x4(%eax)
				prev->next->units = cur->units - units;
c01047e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047e5:	8b 40 04             	mov    0x4(%eax),%eax
c01047e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01047eb:	8b 12                	mov    (%edx),%edx
c01047ed:	2b 55 e0             	sub    -0x20(%ebp),%edx
c01047f0:	89 10                	mov    %edx,(%eax)
				prev->next->next = cur->next;
c01047f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047f5:	8b 40 04             	mov    0x4(%eax),%eax
c01047f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01047fb:	8b 52 04             	mov    0x4(%edx),%edx
c01047fe:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = units;
c0104801:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104804:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104807:	89 10                	mov    %edx,(%eax)
			}

			slobfree = prev;
c0104809:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010480c:	a3 08 4a 12 c0       	mov    %eax,0xc0124a08
			spin_unlock_irqrestore(&slob_lock, flags);
c0104811:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104814:	89 04 24             	mov    %eax,(%esp)
c0104817:	e8 24 fd ff ff       	call   c0104540 <__intr_restore>
			return cur;
c010481c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010481f:	eb 7f                	jmp    c01048a0 <slob_alloc+0x1d3>
		}
		if (cur == slobfree) {
c0104821:	a1 08 4a 12 c0       	mov    0xc0124a08,%eax
c0104826:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104829:	75 61                	jne    c010488c <slob_alloc+0x1bf>
			spin_unlock_irqrestore(&slob_lock, flags);
c010482b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010482e:	89 04 24             	mov    %eax,(%esp)
c0104831:	e8 0a fd ff ff       	call   c0104540 <__intr_restore>

			if (size == PAGE_SIZE) /* trying to shrink arena? */
c0104836:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c010483d:	75 07                	jne    c0104846 <slob_alloc+0x179>
				return 0;
c010483f:	b8 00 00 00 00       	mov    $0x0,%eax
c0104844:	eb 5a                	jmp    c01048a0 <slob_alloc+0x1d3>

			cur = (slob_t *)__slob_get_free_page(gfp);
c0104846:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010484d:	00 
c010484e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104851:	89 04 24             	mov    %eax,(%esp)
c0104854:	e8 07 fe ff ff       	call   c0104660 <__slob_get_free_pages>
c0104859:	89 45 f0             	mov    %eax,-0x10(%ebp)
			if (!cur)
c010485c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104860:	75 07                	jne    c0104869 <slob_alloc+0x19c>
				return 0;
c0104862:	b8 00 00 00 00       	mov    $0x0,%eax
c0104867:	eb 37                	jmp    c01048a0 <slob_alloc+0x1d3>

			slob_free(cur, PAGE_SIZE);
c0104869:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104870:	00 
c0104871:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104874:	89 04 24             	mov    %eax,(%esp)
c0104877:	e8 26 00 00 00       	call   c01048a2 <slob_free>
			spin_lock_irqsave(&slob_lock, flags);
c010487c:	e8 95 fc ff ff       	call   c0104516 <__intr_save>
c0104881:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			cur = slobfree;
c0104884:	a1 08 4a 12 c0       	mov    0xc0124a08,%eax
c0104889:	89 45 f0             	mov    %eax,-0x10(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c010488c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010488f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104892:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104895:	8b 40 04             	mov    0x4(%eax),%eax
c0104898:	89 45 f0             	mov    %eax,-0x10(%ebp)
		}
	}
c010489b:	e9 97 fe ff ff       	jmp    c0104737 <slob_alloc+0x6a>
}
c01048a0:	c9                   	leave  
c01048a1:	c3                   	ret    

c01048a2 <slob_free>:

static void slob_free(void *block, int size)
{
c01048a2:	55                   	push   %ebp
c01048a3:	89 e5                	mov    %esp,%ebp
c01048a5:	83 ec 28             	sub    $0x28,%esp
	slob_t *cur, *b = (slob_t *)block;
c01048a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01048ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c01048ae:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01048b2:	75 05                	jne    c01048b9 <slob_free+0x17>
		return;
c01048b4:	e9 ff 00 00 00       	jmp    c01049b8 <slob_free+0x116>

	if (size)
c01048b9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01048bd:	74 10                	je     c01048cf <slob_free+0x2d>
		b->units = SLOB_UNITS(size);
c01048bf:	8b 45 0c             	mov    0xc(%ebp),%eax
c01048c2:	83 c0 07             	add    $0x7,%eax
c01048c5:	c1 e8 03             	shr    $0x3,%eax
c01048c8:	89 c2                	mov    %eax,%edx
c01048ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048cd:	89 10                	mov    %edx,(%eax)

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
c01048cf:	e8 42 fc ff ff       	call   c0104516 <__intr_save>
c01048d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c01048d7:	a1 08 4a 12 c0       	mov    0xc0124a08,%eax
c01048dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01048df:	eb 27                	jmp    c0104908 <slob_free+0x66>
		if (cur >= cur->next && (b > cur || b < cur->next))
c01048e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048e4:	8b 40 04             	mov    0x4(%eax),%eax
c01048e7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01048ea:	77 13                	ja     c01048ff <slob_free+0x5d>
c01048ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048ef:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01048f2:	77 27                	ja     c010491b <slob_free+0x79>
c01048f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048f7:	8b 40 04             	mov    0x4(%eax),%eax
c01048fa:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01048fd:	77 1c                	ja     c010491b <slob_free+0x79>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c01048ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104902:	8b 40 04             	mov    0x4(%eax),%eax
c0104905:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104908:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010490b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010490e:	76 d1                	jbe    c01048e1 <slob_free+0x3f>
c0104910:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104913:	8b 40 04             	mov    0x4(%eax),%eax
c0104916:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104919:	76 c6                	jbe    c01048e1 <slob_free+0x3f>
			break;

	if (b + b->units == cur->next) {
c010491b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010491e:	8b 00                	mov    (%eax),%eax
c0104920:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0104927:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010492a:	01 c2                	add    %eax,%edx
c010492c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010492f:	8b 40 04             	mov    0x4(%eax),%eax
c0104932:	39 c2                	cmp    %eax,%edx
c0104934:	75 25                	jne    c010495b <slob_free+0xb9>
		b->units += cur->next->units;
c0104936:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104939:	8b 10                	mov    (%eax),%edx
c010493b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010493e:	8b 40 04             	mov    0x4(%eax),%eax
c0104941:	8b 00                	mov    (%eax),%eax
c0104943:	01 c2                	add    %eax,%edx
c0104945:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104948:	89 10                	mov    %edx,(%eax)
		b->next = cur->next->next;
c010494a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010494d:	8b 40 04             	mov    0x4(%eax),%eax
c0104950:	8b 50 04             	mov    0x4(%eax),%edx
c0104953:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104956:	89 50 04             	mov    %edx,0x4(%eax)
c0104959:	eb 0c                	jmp    c0104967 <slob_free+0xc5>
	} else
		b->next = cur->next;
c010495b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010495e:	8b 50 04             	mov    0x4(%eax),%edx
c0104961:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104964:	89 50 04             	mov    %edx,0x4(%eax)

	if (cur + cur->units == b) {
c0104967:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010496a:	8b 00                	mov    (%eax),%eax
c010496c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0104973:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104976:	01 d0                	add    %edx,%eax
c0104978:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010497b:	75 1f                	jne    c010499c <slob_free+0xfa>
		cur->units += b->units;
c010497d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104980:	8b 10                	mov    (%eax),%edx
c0104982:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104985:	8b 00                	mov    (%eax),%eax
c0104987:	01 c2                	add    %eax,%edx
c0104989:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010498c:	89 10                	mov    %edx,(%eax)
		cur->next = b->next;
c010498e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104991:	8b 50 04             	mov    0x4(%eax),%edx
c0104994:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104997:	89 50 04             	mov    %edx,0x4(%eax)
c010499a:	eb 09                	jmp    c01049a5 <slob_free+0x103>
	} else
		cur->next = b;
c010499c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010499f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01049a2:	89 50 04             	mov    %edx,0x4(%eax)

	slobfree = cur;
c01049a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049a8:	a3 08 4a 12 c0       	mov    %eax,0xc0124a08

	spin_unlock_irqrestore(&slob_lock, flags);
c01049ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01049b0:	89 04 24             	mov    %eax,(%esp)
c01049b3:	e8 88 fb ff ff       	call   c0104540 <__intr_restore>
}
c01049b8:	c9                   	leave  
c01049b9:	c3                   	ret    

c01049ba <slob_init>:



void
slob_init(void) {
c01049ba:	55                   	push   %ebp
c01049bb:	89 e5                	mov    %esp,%ebp
c01049bd:	83 ec 18             	sub    $0x18,%esp
  cprintf("use SLOB allocator\n");
c01049c0:	c7 04 24 66 ae 10 c0 	movl   $0xc010ae66,(%esp)
c01049c7:	e8 dd b8 ff ff       	call   c01002a9 <cprintf>
}
c01049cc:	c9                   	leave  
c01049cd:	c3                   	ret    

c01049ce <kmalloc_init>:

inline void 
kmalloc_init(void) {
c01049ce:	55                   	push   %ebp
c01049cf:	89 e5                	mov    %esp,%ebp
c01049d1:	83 ec 18             	sub    $0x18,%esp
    slob_init();
c01049d4:	e8 e1 ff ff ff       	call   c01049ba <slob_init>
    cprintf("kmalloc_init() succeeded!\n");
c01049d9:	c7 04 24 7a ae 10 c0 	movl   $0xc010ae7a,(%esp)
c01049e0:	e8 c4 b8 ff ff       	call   c01002a9 <cprintf>
}
c01049e5:	c9                   	leave  
c01049e6:	c3                   	ret    

c01049e7 <slob_allocated>:

size_t
slob_allocated(void) {
c01049e7:	55                   	push   %ebp
c01049e8:	89 e5                	mov    %esp,%ebp
  return 0;
c01049ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01049ef:	5d                   	pop    %ebp
c01049f0:	c3                   	ret    

c01049f1 <kallocated>:

size_t
kallocated(void) {
c01049f1:	55                   	push   %ebp
c01049f2:	89 e5                	mov    %esp,%ebp
   return slob_allocated();
c01049f4:	e8 ee ff ff ff       	call   c01049e7 <slob_allocated>
}
c01049f9:	5d                   	pop    %ebp
c01049fa:	c3                   	ret    

c01049fb <find_order>:

static int find_order(int size)
{
c01049fb:	55                   	push   %ebp
c01049fc:	89 e5                	mov    %esp,%ebp
c01049fe:	83 ec 10             	sub    $0x10,%esp
	int order = 0;
c0104a01:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c0104a08:	eb 07                	jmp    c0104a11 <find_order+0x16>
		order++;
c0104a0a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c0104a0e:	d1 7d 08             	sarl   0x8(%ebp)
c0104a11:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c0104a18:	7f f0                	jg     c0104a0a <find_order+0xf>
	return order;
c0104a1a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0104a1d:	c9                   	leave  
c0104a1e:	c3                   	ret    

c0104a1f <__kmalloc>:

static void *__kmalloc(size_t size, gfp_t gfp)
{
c0104a1f:	55                   	push   %ebp
c0104a20:	89 e5                	mov    %esp,%ebp
c0104a22:	83 ec 28             	sub    $0x28,%esp
	slob_t *m;
	bigblock_t *bb;
	unsigned long flags;

	if (size < PAGE_SIZE - SLOB_UNIT) {
c0104a25:	81 7d 08 f7 0f 00 00 	cmpl   $0xff7,0x8(%ebp)
c0104a2c:	77 38                	ja     c0104a66 <__kmalloc+0x47>
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
c0104a2e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104a31:	8d 50 08             	lea    0x8(%eax),%edx
c0104a34:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104a3b:	00 
c0104a3c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104a3f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104a43:	89 14 24             	mov    %edx,(%esp)
c0104a46:	e8 82 fc ff ff       	call   c01046cd <slob_alloc>
c0104a4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
		return m ? (void *)(m + 1) : 0;
c0104a4e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104a52:	74 08                	je     c0104a5c <__kmalloc+0x3d>
c0104a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a57:	83 c0 08             	add    $0x8,%eax
c0104a5a:	eb 05                	jmp    c0104a61 <__kmalloc+0x42>
c0104a5c:	b8 00 00 00 00       	mov    $0x0,%eax
c0104a61:	e9 a6 00 00 00       	jmp    c0104b0c <__kmalloc+0xed>
	}

	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
c0104a66:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104a6d:	00 
c0104a6e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104a71:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104a75:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
c0104a7c:	e8 4c fc ff ff       	call   c01046cd <slob_alloc>
c0104a81:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (!bb)
c0104a84:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104a88:	75 07                	jne    c0104a91 <__kmalloc+0x72>
		return 0;
c0104a8a:	b8 00 00 00 00       	mov    $0x0,%eax
c0104a8f:	eb 7b                	jmp    c0104b0c <__kmalloc+0xed>

	bb->order = find_order(size);
c0104a91:	8b 45 08             	mov    0x8(%ebp),%eax
c0104a94:	89 04 24             	mov    %eax,(%esp)
c0104a97:	e8 5f ff ff ff       	call   c01049fb <find_order>
c0104a9c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104a9f:	89 02                	mov    %eax,(%edx)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
c0104aa1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104aa4:	8b 00                	mov    (%eax),%eax
c0104aa6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104aaa:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104aad:	89 04 24             	mov    %eax,(%esp)
c0104ab0:	e8 ab fb ff ff       	call   c0104660 <__slob_get_free_pages>
c0104ab5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104ab8:	89 42 04             	mov    %eax,0x4(%edx)

	if (bb->pages) {
c0104abb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104abe:	8b 40 04             	mov    0x4(%eax),%eax
c0104ac1:	85 c0                	test   %eax,%eax
c0104ac3:	74 2f                	je     c0104af4 <__kmalloc+0xd5>
		spin_lock_irqsave(&block_lock, flags);
c0104ac5:	e8 4c fa ff ff       	call   c0104516 <__intr_save>
c0104aca:	89 45 ec             	mov    %eax,-0x14(%ebp)
		bb->next = bigblocks;
c0104acd:	8b 15 68 7f 12 c0    	mov    0xc0127f68,%edx
c0104ad3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ad6:	89 50 08             	mov    %edx,0x8(%eax)
		bigblocks = bb;
c0104ad9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104adc:	a3 68 7f 12 c0       	mov    %eax,0xc0127f68
		spin_unlock_irqrestore(&block_lock, flags);
c0104ae1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104ae4:	89 04 24             	mov    %eax,(%esp)
c0104ae7:	e8 54 fa ff ff       	call   c0104540 <__intr_restore>
		return bb->pages;
c0104aec:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104aef:	8b 40 04             	mov    0x4(%eax),%eax
c0104af2:	eb 18                	jmp    c0104b0c <__kmalloc+0xed>
	}

	slob_free(bb, sizeof(bigblock_t));
c0104af4:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c0104afb:	00 
c0104afc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104aff:	89 04 24             	mov    %eax,(%esp)
c0104b02:	e8 9b fd ff ff       	call   c01048a2 <slob_free>
	return 0;
c0104b07:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104b0c:	c9                   	leave  
c0104b0d:	c3                   	ret    

c0104b0e <kmalloc>:

void *
kmalloc(size_t size)
{
c0104b0e:	55                   	push   %ebp
c0104b0f:	89 e5                	mov    %esp,%ebp
c0104b11:	83 ec 18             	sub    $0x18,%esp
  return __kmalloc(size, 0);
c0104b14:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104b1b:	00 
c0104b1c:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b1f:	89 04 24             	mov    %eax,(%esp)
c0104b22:	e8 f8 fe ff ff       	call   c0104a1f <__kmalloc>
}
c0104b27:	c9                   	leave  
c0104b28:	c3                   	ret    

c0104b29 <kfree>:


void kfree(void *block)
{
c0104b29:	55                   	push   %ebp
c0104b2a:	89 e5                	mov    %esp,%ebp
c0104b2c:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb, **last = &bigblocks;
c0104b2f:	c7 45 f0 68 7f 12 c0 	movl   $0xc0127f68,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c0104b36:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104b3a:	75 05                	jne    c0104b41 <kfree+0x18>
		return;
c0104b3c:	e9 a2 00 00 00       	jmp    c0104be3 <kfree+0xba>

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0104b41:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b44:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104b49:	85 c0                	test   %eax,%eax
c0104b4b:	75 7f                	jne    c0104bcc <kfree+0xa3>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
c0104b4d:	e8 c4 f9 ff ff       	call   c0104516 <__intr_save>
c0104b52:	89 45 ec             	mov    %eax,-0x14(%ebp)
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0104b55:	a1 68 7f 12 c0       	mov    0xc0127f68,%eax
c0104b5a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104b5d:	eb 5c                	jmp    c0104bbb <kfree+0x92>
			if (bb->pages == block) {
c0104b5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b62:	8b 40 04             	mov    0x4(%eax),%eax
c0104b65:	3b 45 08             	cmp    0x8(%ebp),%eax
c0104b68:	75 3f                	jne    c0104ba9 <kfree+0x80>
				*last = bb->next;
c0104b6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b6d:	8b 50 08             	mov    0x8(%eax),%edx
c0104b70:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b73:	89 10                	mov    %edx,(%eax)
				spin_unlock_irqrestore(&block_lock, flags);
c0104b75:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104b78:	89 04 24             	mov    %eax,(%esp)
c0104b7b:	e8 c0 f9 ff ff       	call   c0104540 <__intr_restore>
				__slob_free_pages((unsigned long)block, bb->order);
c0104b80:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b83:	8b 10                	mov    (%eax),%edx
c0104b85:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b88:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104b8c:	89 04 24             	mov    %eax,(%esp)
c0104b8f:	e8 05 fb ff ff       	call   c0104699 <__slob_free_pages>
				slob_free(bb, sizeof(bigblock_t));
c0104b94:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c0104b9b:	00 
c0104b9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b9f:	89 04 24             	mov    %eax,(%esp)
c0104ba2:	e8 fb fc ff ff       	call   c01048a2 <slob_free>
				return;
c0104ba7:	eb 3a                	jmp    c0104be3 <kfree+0xba>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0104ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bac:	83 c0 08             	add    $0x8,%eax
c0104baf:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bb5:	8b 40 08             	mov    0x8(%eax),%eax
c0104bb8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104bbb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104bbf:	75 9e                	jne    c0104b5f <kfree+0x36>
			}
		}
		spin_unlock_irqrestore(&block_lock, flags);
c0104bc1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104bc4:	89 04 24             	mov    %eax,(%esp)
c0104bc7:	e8 74 f9 ff ff       	call   c0104540 <__intr_restore>
	}

	slob_free((slob_t *)block - 1, 0);
c0104bcc:	8b 45 08             	mov    0x8(%ebp),%eax
c0104bcf:	83 e8 08             	sub    $0x8,%eax
c0104bd2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104bd9:	00 
c0104bda:	89 04 24             	mov    %eax,(%esp)
c0104bdd:	e8 c0 fc ff ff       	call   c01048a2 <slob_free>
	return;
c0104be2:	90                   	nop
}
c0104be3:	c9                   	leave  
c0104be4:	c3                   	ret    

c0104be5 <ksize>:


unsigned int ksize(const void *block)
{
c0104be5:	55                   	push   %ebp
c0104be6:	89 e5                	mov    %esp,%ebp
c0104be8:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb;
	unsigned long flags;

	if (!block)
c0104beb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104bef:	75 07                	jne    c0104bf8 <ksize+0x13>
		return 0;
c0104bf1:	b8 00 00 00 00       	mov    $0x0,%eax
c0104bf6:	eb 6b                	jmp    c0104c63 <ksize+0x7e>

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0104bf8:	8b 45 08             	mov    0x8(%ebp),%eax
c0104bfb:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104c00:	85 c0                	test   %eax,%eax
c0104c02:	75 54                	jne    c0104c58 <ksize+0x73>
		spin_lock_irqsave(&block_lock, flags);
c0104c04:	e8 0d f9 ff ff       	call   c0104516 <__intr_save>
c0104c09:	89 45 f0             	mov    %eax,-0x10(%ebp)
		for (bb = bigblocks; bb; bb = bb->next)
c0104c0c:	a1 68 7f 12 c0       	mov    0xc0127f68,%eax
c0104c11:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104c14:	eb 31                	jmp    c0104c47 <ksize+0x62>
			if (bb->pages == block) {
c0104c16:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c19:	8b 40 04             	mov    0x4(%eax),%eax
c0104c1c:	3b 45 08             	cmp    0x8(%ebp),%eax
c0104c1f:	75 1d                	jne    c0104c3e <ksize+0x59>
				spin_unlock_irqrestore(&slob_lock, flags);
c0104c21:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c24:	89 04 24             	mov    %eax,(%esp)
c0104c27:	e8 14 f9 ff ff       	call   c0104540 <__intr_restore>
				return PAGE_SIZE << bb->order;
c0104c2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c2f:	8b 00                	mov    (%eax),%eax
c0104c31:	ba 00 10 00 00       	mov    $0x1000,%edx
c0104c36:	89 c1                	mov    %eax,%ecx
c0104c38:	d3 e2                	shl    %cl,%edx
c0104c3a:	89 d0                	mov    %edx,%eax
c0104c3c:	eb 25                	jmp    c0104c63 <ksize+0x7e>
		for (bb = bigblocks; bb; bb = bb->next)
c0104c3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c41:	8b 40 08             	mov    0x8(%eax),%eax
c0104c44:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104c47:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104c4b:	75 c9                	jne    c0104c16 <ksize+0x31>
			}
		spin_unlock_irqrestore(&block_lock, flags);
c0104c4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c50:	89 04 24             	mov    %eax,(%esp)
c0104c53:	e8 e8 f8 ff ff       	call   c0104540 <__intr_restore>
	}

	return ((slob_t *)block - 1)->units * SLOB_UNIT;
c0104c58:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c5b:	83 e8 08             	sub    $0x8,%eax
c0104c5e:	8b 00                	mov    (%eax),%eax
c0104c60:	c1 e0 03             	shl    $0x3,%eax
}
c0104c63:	c9                   	leave  
c0104c64:	c3                   	ret    

c0104c65 <pa2page>:
pa2page(uintptr_t pa) {
c0104c65:	55                   	push   %ebp
c0104c66:	89 e5                	mov    %esp,%ebp
c0104c68:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0104c6b:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c6e:	c1 e8 0c             	shr    $0xc,%eax
c0104c71:	89 c2                	mov    %eax,%edx
c0104c73:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c0104c78:	39 c2                	cmp    %eax,%edx
c0104c7a:	72 1c                	jb     c0104c98 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0104c7c:	c7 44 24 08 98 ae 10 	movl   $0xc010ae98,0x8(%esp)
c0104c83:	c0 
c0104c84:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c0104c8b:	00 
c0104c8c:	c7 04 24 b7 ae 10 c0 	movl   $0xc010aeb7,(%esp)
c0104c93:	e8 68 b7 ff ff       	call   c0100400 <__panic>
    return &pages[PPN(pa)];
c0104c98:	a1 58 a1 12 c0       	mov    0xc012a158,%eax
c0104c9d:	8b 55 08             	mov    0x8(%ebp),%edx
c0104ca0:	c1 ea 0c             	shr    $0xc,%edx
c0104ca3:	c1 e2 05             	shl    $0x5,%edx
c0104ca6:	01 d0                	add    %edx,%eax
}
c0104ca8:	c9                   	leave  
c0104ca9:	c3                   	ret    

c0104caa <pte2page>:
pte2page(pte_t pte) {
c0104caa:	55                   	push   %ebp
c0104cab:	89 e5                	mov    %esp,%ebp
c0104cad:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0104cb0:	8b 45 08             	mov    0x8(%ebp),%eax
c0104cb3:	83 e0 01             	and    $0x1,%eax
c0104cb6:	85 c0                	test   %eax,%eax
c0104cb8:	75 1c                	jne    c0104cd6 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0104cba:	c7 44 24 08 c8 ae 10 	movl   $0xc010aec8,0x8(%esp)
c0104cc1:	c0 
c0104cc2:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
c0104cc9:	00 
c0104cca:	c7 04 24 b7 ae 10 c0 	movl   $0xc010aeb7,(%esp)
c0104cd1:	e8 2a b7 ff ff       	call   c0100400 <__panic>
    return pa2page(PTE_ADDR(pte));
c0104cd6:	8b 45 08             	mov    0x8(%ebp),%eax
c0104cd9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104cde:	89 04 24             	mov    %eax,(%esp)
c0104ce1:	e8 7f ff ff ff       	call   c0104c65 <pa2page>
}
c0104ce6:	c9                   	leave  
c0104ce7:	c3                   	ret    

c0104ce8 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
c0104ce8:	55                   	push   %ebp
c0104ce9:	89 e5                	mov    %esp,%ebp
c0104ceb:	83 ec 28             	sub    $0x28,%esp
     swapfs_init();
c0104cee:	e8 e1 37 00 00       	call   c01084d4 <swapfs_init>

     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
c0104cf3:	a1 1c a1 12 c0       	mov    0xc012a11c,%eax
c0104cf8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
c0104cfd:	76 0c                	jbe    c0104d0b <swap_init+0x23>
c0104cff:	a1 1c a1 12 c0       	mov    0xc012a11c,%eax
c0104d04:	3d ff ff ff 00       	cmp    $0xffffff,%eax
c0104d09:	76 25                	jbe    c0104d30 <swap_init+0x48>
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
c0104d0b:	a1 1c a1 12 c0       	mov    0xc012a11c,%eax
c0104d10:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104d14:	c7 44 24 08 e9 ae 10 	movl   $0xc010aee9,0x8(%esp)
c0104d1b:	c0 
c0104d1c:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
c0104d23:	00 
c0104d24:	c7 04 24 04 af 10 c0 	movl   $0xc010af04,(%esp)
c0104d2b:	e8 d0 b6 ff ff       	call   c0100400 <__panic>
     }
     

     sm = &swap_manager_fifo;
c0104d30:	c7 05 74 7f 12 c0 e0 	movl   $0xc01249e0,0xc0127f74
c0104d37:	49 12 c0 
     int r = sm->init();
c0104d3a:	a1 74 7f 12 c0       	mov    0xc0127f74,%eax
c0104d3f:	8b 40 04             	mov    0x4(%eax),%eax
c0104d42:	ff d0                	call   *%eax
c0104d44:	89 45 f4             	mov    %eax,-0xc(%ebp)
     
     if (r == 0)
c0104d47:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104d4b:	75 26                	jne    c0104d73 <swap_init+0x8b>
     {
          swap_init_ok = 1;
c0104d4d:	c7 05 6c 7f 12 c0 01 	movl   $0x1,0xc0127f6c
c0104d54:	00 00 00 
          cprintf("SWAP: manager = %s\n", sm->name);
c0104d57:	a1 74 7f 12 c0       	mov    0xc0127f74,%eax
c0104d5c:	8b 00                	mov    (%eax),%eax
c0104d5e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104d62:	c7 04 24 13 af 10 c0 	movl   $0xc010af13,(%esp)
c0104d69:	e8 3b b5 ff ff       	call   c01002a9 <cprintf>
          check_swap();
c0104d6e:	e8 a4 04 00 00       	call   c0105217 <check_swap>
     }

     return r;
c0104d73:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104d76:	c9                   	leave  
c0104d77:	c3                   	ret    

c0104d78 <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
c0104d78:	55                   	push   %ebp
c0104d79:	89 e5                	mov    %esp,%ebp
c0104d7b:	83 ec 18             	sub    $0x18,%esp
     return sm->init_mm(mm);
c0104d7e:	a1 74 7f 12 c0       	mov    0xc0127f74,%eax
c0104d83:	8b 40 08             	mov    0x8(%eax),%eax
c0104d86:	8b 55 08             	mov    0x8(%ebp),%edx
c0104d89:	89 14 24             	mov    %edx,(%esp)
c0104d8c:	ff d0                	call   *%eax
}
c0104d8e:	c9                   	leave  
c0104d8f:	c3                   	ret    

c0104d90 <swap_tick_event>:

int
swap_tick_event(struct mm_struct *mm)
{
c0104d90:	55                   	push   %ebp
c0104d91:	89 e5                	mov    %esp,%ebp
c0104d93:	83 ec 18             	sub    $0x18,%esp
     return sm->tick_event(mm);
c0104d96:	a1 74 7f 12 c0       	mov    0xc0127f74,%eax
c0104d9b:	8b 40 0c             	mov    0xc(%eax),%eax
c0104d9e:	8b 55 08             	mov    0x8(%ebp),%edx
c0104da1:	89 14 24             	mov    %edx,(%esp)
c0104da4:	ff d0                	call   *%eax
}
c0104da6:	c9                   	leave  
c0104da7:	c3                   	ret    

c0104da8 <swap_map_swappable>:

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0104da8:	55                   	push   %ebp
c0104da9:	89 e5                	mov    %esp,%ebp
c0104dab:	83 ec 18             	sub    $0x18,%esp
     return sm->map_swappable(mm, addr, page, swap_in);
c0104dae:	a1 74 7f 12 c0       	mov    0xc0127f74,%eax
c0104db3:	8b 40 10             	mov    0x10(%eax),%eax
c0104db6:	8b 55 14             	mov    0x14(%ebp),%edx
c0104db9:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0104dbd:	8b 55 10             	mov    0x10(%ebp),%edx
c0104dc0:	89 54 24 08          	mov    %edx,0x8(%esp)
c0104dc4:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104dc7:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104dcb:	8b 55 08             	mov    0x8(%ebp),%edx
c0104dce:	89 14 24             	mov    %edx,(%esp)
c0104dd1:	ff d0                	call   *%eax
}
c0104dd3:	c9                   	leave  
c0104dd4:	c3                   	ret    

c0104dd5 <swap_set_unswappable>:

int
swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c0104dd5:	55                   	push   %ebp
c0104dd6:	89 e5                	mov    %esp,%ebp
c0104dd8:	83 ec 18             	sub    $0x18,%esp
     return sm->set_unswappable(mm, addr);
c0104ddb:	a1 74 7f 12 c0       	mov    0xc0127f74,%eax
c0104de0:	8b 40 14             	mov    0x14(%eax),%eax
c0104de3:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104de6:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104dea:	8b 55 08             	mov    0x8(%ebp),%edx
c0104ded:	89 14 24             	mov    %edx,(%esp)
c0104df0:	ff d0                	call   *%eax
}
c0104df2:	c9                   	leave  
c0104df3:	c3                   	ret    

c0104df4 <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
c0104df4:	55                   	push   %ebp
c0104df5:	89 e5                	mov    %esp,%ebp
c0104df7:	83 ec 38             	sub    $0x38,%esp
     int i;
     for (i = 0; i != n; ++ i)
c0104dfa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104e01:	e9 5a 01 00 00       	jmp    c0104f60 <swap_out+0x16c>
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
c0104e06:	a1 74 7f 12 c0       	mov    0xc0127f74,%eax
c0104e0b:	8b 40 18             	mov    0x18(%eax),%eax
c0104e0e:	8b 55 10             	mov    0x10(%ebp),%edx
c0104e11:	89 54 24 08          	mov    %edx,0x8(%esp)
c0104e15:	8d 55 e4             	lea    -0x1c(%ebp),%edx
c0104e18:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104e1c:	8b 55 08             	mov    0x8(%ebp),%edx
c0104e1f:	89 14 24             	mov    %edx,(%esp)
c0104e22:	ff d0                	call   *%eax
c0104e24:	89 45 f0             	mov    %eax,-0x10(%ebp)
          if (r != 0) {
c0104e27:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104e2b:	74 18                	je     c0104e45 <swap_out+0x51>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
c0104e2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e30:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104e34:	c7 04 24 28 af 10 c0 	movl   $0xc010af28,(%esp)
c0104e3b:	e8 69 b4 ff ff       	call   c01002a9 <cprintf>
c0104e40:	e9 27 01 00 00       	jmp    c0104f6c <swap_out+0x178>
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
c0104e45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104e48:	8b 40 1c             	mov    0x1c(%eax),%eax
c0104e4b:	89 45 ec             	mov    %eax,-0x14(%ebp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
c0104e4e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e51:	8b 40 0c             	mov    0xc(%eax),%eax
c0104e54:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104e5b:	00 
c0104e5c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104e5f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104e63:	89 04 24             	mov    %eax,(%esp)
c0104e66:	e8 1a 25 00 00       	call   c0107385 <get_pte>
c0104e6b:	89 45 e8             	mov    %eax,-0x18(%ebp)
          assert((*ptep & PTE_P) != 0);
c0104e6e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104e71:	8b 00                	mov    (%eax),%eax
c0104e73:	83 e0 01             	and    $0x1,%eax
c0104e76:	85 c0                	test   %eax,%eax
c0104e78:	75 24                	jne    c0104e9e <swap_out+0xaa>
c0104e7a:	c7 44 24 0c 55 af 10 	movl   $0xc010af55,0xc(%esp)
c0104e81:	c0 
c0104e82:	c7 44 24 08 6a af 10 	movl   $0xc010af6a,0x8(%esp)
c0104e89:	c0 
c0104e8a:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0104e91:	00 
c0104e92:	c7 04 24 04 af 10 c0 	movl   $0xc010af04,(%esp)
c0104e99:	e8 62 b5 ff ff       	call   c0100400 <__panic>

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
c0104e9e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104ea1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104ea4:	8b 52 1c             	mov    0x1c(%edx),%edx
c0104ea7:	c1 ea 0c             	shr    $0xc,%edx
c0104eaa:	83 c2 01             	add    $0x1,%edx
c0104ead:	c1 e2 08             	shl    $0x8,%edx
c0104eb0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104eb4:	89 14 24             	mov    %edx,(%esp)
c0104eb7:	e8 d2 36 00 00       	call   c010858e <swapfs_write>
c0104ebc:	85 c0                	test   %eax,%eax
c0104ebe:	74 34                	je     c0104ef4 <swap_out+0x100>
                    cprintf("SWAP: failed to save\n");
c0104ec0:	c7 04 24 7f af 10 c0 	movl   $0xc010af7f,(%esp)
c0104ec7:	e8 dd b3 ff ff       	call   c01002a9 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
c0104ecc:	a1 74 7f 12 c0       	mov    0xc0127f74,%eax
c0104ed1:	8b 40 10             	mov    0x10(%eax),%eax
c0104ed4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104ed7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104ede:	00 
c0104edf:	89 54 24 08          	mov    %edx,0x8(%esp)
c0104ee3:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104ee6:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104eea:	8b 55 08             	mov    0x8(%ebp),%edx
c0104eed:	89 14 24             	mov    %edx,(%esp)
c0104ef0:	ff d0                	call   *%eax
c0104ef2:	eb 68                	jmp    c0104f5c <swap_out+0x168>
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
c0104ef4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104ef7:	8b 40 1c             	mov    0x1c(%eax),%eax
c0104efa:	c1 e8 0c             	shr    $0xc,%eax
c0104efd:	83 c0 01             	add    $0x1,%eax
c0104f00:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104f04:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104f07:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104f0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f0e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104f12:	c7 04 24 98 af 10 c0 	movl   $0xc010af98,(%esp)
c0104f19:	e8 8b b3 ff ff       	call   c01002a9 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
c0104f1e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104f21:	8b 40 1c             	mov    0x1c(%eax),%eax
c0104f24:	c1 e8 0c             	shr    $0xc,%eax
c0104f27:	83 c0 01             	add    $0x1,%eax
c0104f2a:	c1 e0 08             	shl    $0x8,%eax
c0104f2d:	89 c2                	mov    %eax,%edx
c0104f2f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104f32:	89 10                	mov    %edx,(%eax)
                    free_page(page);
c0104f34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104f37:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104f3e:	00 
c0104f3f:	89 04 24             	mov    %eax,(%esp)
c0104f42:	e8 c5 1d 00 00       	call   c0106d0c <free_pages>
          }
          
          tlb_invalidate(mm->pgdir, v);
c0104f47:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f4a:	8b 40 0c             	mov    0xc(%eax),%eax
c0104f4d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104f50:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104f54:	89 04 24             	mov    %eax,(%esp)
c0104f57:	e8 1e 27 00 00       	call   c010767a <tlb_invalidate>
     for (i = 0; i != n; ++ i)
c0104f5c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0104f60:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f63:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104f66:	0f 85 9a fe ff ff    	jne    c0104e06 <swap_out+0x12>
     }
     return i;
c0104f6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104f6f:	c9                   	leave  
c0104f70:	c3                   	ret    

c0104f71 <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
c0104f71:	55                   	push   %ebp
c0104f72:	89 e5                	mov    %esp,%ebp
c0104f74:	83 ec 28             	sub    $0x28,%esp
     struct Page *result = alloc_page();
c0104f77:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104f7e:	e8 1e 1d 00 00       	call   c0106ca1 <alloc_pages>
c0104f83:	89 45 f4             	mov    %eax,-0xc(%ebp)
     assert(result!=NULL);
c0104f86:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104f8a:	75 24                	jne    c0104fb0 <swap_in+0x3f>
c0104f8c:	c7 44 24 0c d8 af 10 	movl   $0xc010afd8,0xc(%esp)
c0104f93:	c0 
c0104f94:	c7 44 24 08 6a af 10 	movl   $0xc010af6a,0x8(%esp)
c0104f9b:	c0 
c0104f9c:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
c0104fa3:	00 
c0104fa4:	c7 04 24 04 af 10 c0 	movl   $0xc010af04,(%esp)
c0104fab:	e8 50 b4 ff ff       	call   c0100400 <__panic>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
c0104fb0:	8b 45 08             	mov    0x8(%ebp),%eax
c0104fb3:	8b 40 0c             	mov    0xc(%eax),%eax
c0104fb6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104fbd:	00 
c0104fbe:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104fc1:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104fc5:	89 04 24             	mov    %eax,(%esp)
c0104fc8:	e8 b8 23 00 00       	call   c0107385 <get_pte>
c0104fcd:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
c0104fd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104fd3:	8b 00                	mov    (%eax),%eax
c0104fd5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104fd8:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104fdc:	89 04 24             	mov    %eax,(%esp)
c0104fdf:	e8 38 35 00 00       	call   c010851c <swapfs_read>
c0104fe4:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104fe7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104feb:	74 2a                	je     c0105017 <swap_in+0xa6>
     {
        assert(r!=0);
c0104fed:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104ff1:	75 24                	jne    c0105017 <swap_in+0xa6>
c0104ff3:	c7 44 24 0c e5 af 10 	movl   $0xc010afe5,0xc(%esp)
c0104ffa:	c0 
c0104ffb:	c7 44 24 08 6a af 10 	movl   $0xc010af6a,0x8(%esp)
c0105002:	c0 
c0105003:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
c010500a:	00 
c010500b:	c7 04 24 04 af 10 c0 	movl   $0xc010af04,(%esp)
c0105012:	e8 e9 b3 ff ff       	call   c0100400 <__panic>
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
c0105017:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010501a:	8b 00                	mov    (%eax),%eax
c010501c:	c1 e8 08             	shr    $0x8,%eax
c010501f:	89 c2                	mov    %eax,%edx
c0105021:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105024:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105028:	89 54 24 04          	mov    %edx,0x4(%esp)
c010502c:	c7 04 24 ec af 10 c0 	movl   $0xc010afec,(%esp)
c0105033:	e8 71 b2 ff ff       	call   c01002a9 <cprintf>
     *ptr_result=result;
c0105038:	8b 45 10             	mov    0x10(%ebp),%eax
c010503b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010503e:	89 10                	mov    %edx,(%eax)
     return 0;
c0105040:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105045:	c9                   	leave  
c0105046:	c3                   	ret    

c0105047 <check_content_set>:



static inline void
check_content_set(void)
{
c0105047:	55                   	push   %ebp
c0105048:	89 e5                	mov    %esp,%ebp
c010504a:	83 ec 18             	sub    $0x18,%esp
     *(unsigned char *)0x1000 = 0x0a;
c010504d:	b8 00 10 00 00       	mov    $0x1000,%eax
c0105052:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0105055:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c010505a:	83 f8 01             	cmp    $0x1,%eax
c010505d:	74 24                	je     c0105083 <check_content_set+0x3c>
c010505f:	c7 44 24 0c 2a b0 10 	movl   $0xc010b02a,0xc(%esp)
c0105066:	c0 
c0105067:	c7 44 24 08 6a af 10 	movl   $0xc010af6a,0x8(%esp)
c010506e:	c0 
c010506f:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
c0105076:	00 
c0105077:	c7 04 24 04 af 10 c0 	movl   $0xc010af04,(%esp)
c010507e:	e8 7d b3 ff ff       	call   c0100400 <__panic>
     *(unsigned char *)0x1010 = 0x0a;
c0105083:	b8 10 10 00 00       	mov    $0x1010,%eax
c0105088:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c010508b:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c0105090:	83 f8 01             	cmp    $0x1,%eax
c0105093:	74 24                	je     c01050b9 <check_content_set+0x72>
c0105095:	c7 44 24 0c 2a b0 10 	movl   $0xc010b02a,0xc(%esp)
c010509c:	c0 
c010509d:	c7 44 24 08 6a af 10 	movl   $0xc010af6a,0x8(%esp)
c01050a4:	c0 
c01050a5:	c7 44 24 04 92 00 00 	movl   $0x92,0x4(%esp)
c01050ac:	00 
c01050ad:	c7 04 24 04 af 10 c0 	movl   $0xc010af04,(%esp)
c01050b4:	e8 47 b3 ff ff       	call   c0100400 <__panic>
     *(unsigned char *)0x2000 = 0x0b;
c01050b9:	b8 00 20 00 00       	mov    $0x2000,%eax
c01050be:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c01050c1:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c01050c6:	83 f8 02             	cmp    $0x2,%eax
c01050c9:	74 24                	je     c01050ef <check_content_set+0xa8>
c01050cb:	c7 44 24 0c 39 b0 10 	movl   $0xc010b039,0xc(%esp)
c01050d2:	c0 
c01050d3:	c7 44 24 08 6a af 10 	movl   $0xc010af6a,0x8(%esp)
c01050da:	c0 
c01050db:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c01050e2:	00 
c01050e3:	c7 04 24 04 af 10 c0 	movl   $0xc010af04,(%esp)
c01050ea:	e8 11 b3 ff ff       	call   c0100400 <__panic>
     *(unsigned char *)0x2010 = 0x0b;
c01050ef:	b8 10 20 00 00       	mov    $0x2010,%eax
c01050f4:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c01050f7:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c01050fc:	83 f8 02             	cmp    $0x2,%eax
c01050ff:	74 24                	je     c0105125 <check_content_set+0xde>
c0105101:	c7 44 24 0c 39 b0 10 	movl   $0xc010b039,0xc(%esp)
c0105108:	c0 
c0105109:	c7 44 24 08 6a af 10 	movl   $0xc010af6a,0x8(%esp)
c0105110:	c0 
c0105111:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
c0105118:	00 
c0105119:	c7 04 24 04 af 10 c0 	movl   $0xc010af04,(%esp)
c0105120:	e8 db b2 ff ff       	call   c0100400 <__panic>
     *(unsigned char *)0x3000 = 0x0c;
c0105125:	b8 00 30 00 00       	mov    $0x3000,%eax
c010512a:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c010512d:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c0105132:	83 f8 03             	cmp    $0x3,%eax
c0105135:	74 24                	je     c010515b <check_content_set+0x114>
c0105137:	c7 44 24 0c 48 b0 10 	movl   $0xc010b048,0xc(%esp)
c010513e:	c0 
c010513f:	c7 44 24 08 6a af 10 	movl   $0xc010af6a,0x8(%esp)
c0105146:	c0 
c0105147:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
c010514e:	00 
c010514f:	c7 04 24 04 af 10 c0 	movl   $0xc010af04,(%esp)
c0105156:	e8 a5 b2 ff ff       	call   c0100400 <__panic>
     *(unsigned char *)0x3010 = 0x0c;
c010515b:	b8 10 30 00 00       	mov    $0x3010,%eax
c0105160:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0105163:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c0105168:	83 f8 03             	cmp    $0x3,%eax
c010516b:	74 24                	je     c0105191 <check_content_set+0x14a>
c010516d:	c7 44 24 0c 48 b0 10 	movl   $0xc010b048,0xc(%esp)
c0105174:	c0 
c0105175:	c7 44 24 08 6a af 10 	movl   $0xc010af6a,0x8(%esp)
c010517c:	c0 
c010517d:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
c0105184:	00 
c0105185:	c7 04 24 04 af 10 c0 	movl   $0xc010af04,(%esp)
c010518c:	e8 6f b2 ff ff       	call   c0100400 <__panic>
     *(unsigned char *)0x4000 = 0x0d;
c0105191:	b8 00 40 00 00       	mov    $0x4000,%eax
c0105196:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0105199:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c010519e:	83 f8 04             	cmp    $0x4,%eax
c01051a1:	74 24                	je     c01051c7 <check_content_set+0x180>
c01051a3:	c7 44 24 0c 57 b0 10 	movl   $0xc010b057,0xc(%esp)
c01051aa:	c0 
c01051ab:	c7 44 24 08 6a af 10 	movl   $0xc010af6a,0x8(%esp)
c01051b2:	c0 
c01051b3:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c01051ba:	00 
c01051bb:	c7 04 24 04 af 10 c0 	movl   $0xc010af04,(%esp)
c01051c2:	e8 39 b2 ff ff       	call   c0100400 <__panic>
     *(unsigned char *)0x4010 = 0x0d;
c01051c7:	b8 10 40 00 00       	mov    $0x4010,%eax
c01051cc:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c01051cf:	a1 64 7f 12 c0       	mov    0xc0127f64,%eax
c01051d4:	83 f8 04             	cmp    $0x4,%eax
c01051d7:	74 24                	je     c01051fd <check_content_set+0x1b6>
c01051d9:	c7 44 24 0c 57 b0 10 	movl   $0xc010b057,0xc(%esp)
c01051e0:	c0 
c01051e1:	c7 44 24 08 6a af 10 	movl   $0xc010af6a,0x8(%esp)
c01051e8:	c0 
c01051e9:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
c01051f0:	00 
c01051f1:	c7 04 24 04 af 10 c0 	movl   $0xc010af04,(%esp)
c01051f8:	e8 03 b2 ff ff       	call   c0100400 <__panic>
}
c01051fd:	c9                   	leave  
c01051fe:	c3                   	ret    

c01051ff <check_content_access>:

static inline int
check_content_access(void)
{
c01051ff:	55                   	push   %ebp
c0105200:	89 e5                	mov    %esp,%ebp
c0105202:	83 ec 18             	sub    $0x18,%esp
    int ret = sm->check_swap();
c0105205:	a1 74 7f 12 c0       	mov    0xc0127f74,%eax
c010520a:	8b 40 1c             	mov    0x1c(%eax),%eax
c010520d:	ff d0                	call   *%eax
c010520f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c0105212:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105215:	c9                   	leave  
c0105216:	c3                   	ret    

c0105217 <check_swap>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void)
{
c0105217:	55                   	push   %ebp
c0105218:	89 e5                	mov    %esp,%ebp
c010521a:	53                   	push   %ebx
c010521b:	83 ec 74             	sub    $0x74,%esp
    //backup mem env
     int ret, count = 0, total = 0, i;
c010521e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105225:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     list_entry_t *le = &free_list;
c010522c:	c7 45 e8 44 a1 12 c0 	movl   $0xc012a144,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0105233:	eb 6b                	jmp    c01052a0 <check_swap+0x89>
        struct Page *p = le2page(le, page_link);
c0105235:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105238:	83 e8 0c             	sub    $0xc,%eax
c010523b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        assert(PageProperty(p));
c010523e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105241:	83 c0 04             	add    $0x4,%eax
c0105244:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c010524b:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010524e:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0105251:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0105254:	0f a3 10             	bt     %edx,(%eax)
c0105257:	19 c0                	sbb    %eax,%eax
c0105259:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return oldbit != 0;
c010525c:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0105260:	0f 95 c0             	setne  %al
c0105263:	0f b6 c0             	movzbl %al,%eax
c0105266:	85 c0                	test   %eax,%eax
c0105268:	75 24                	jne    c010528e <check_swap+0x77>
c010526a:	c7 44 24 0c 66 b0 10 	movl   $0xc010b066,0xc(%esp)
c0105271:	c0 
c0105272:	c7 44 24 08 6a af 10 	movl   $0xc010af6a,0x8(%esp)
c0105279:	c0 
c010527a:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
c0105281:	00 
c0105282:	c7 04 24 04 af 10 c0 	movl   $0xc010af04,(%esp)
c0105289:	e8 72 b1 ff ff       	call   c0100400 <__panic>
        count ++, total += p->property;
c010528e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0105292:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105295:	8b 50 08             	mov    0x8(%eax),%edx
c0105298:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010529b:	01 d0                	add    %edx,%eax
c010529d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01052a0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01052a3:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return listelm->next;
c01052a6:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01052a9:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c01052ac:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01052af:	81 7d e8 44 a1 12 c0 	cmpl   $0xc012a144,-0x18(%ebp)
c01052b6:	0f 85 79 ff ff ff    	jne    c0105235 <check_swap+0x1e>
     }
     assert(total == nr_free_pages());
c01052bc:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c01052bf:	e8 7a 1a 00 00       	call   c0106d3e <nr_free_pages>
c01052c4:	39 c3                	cmp    %eax,%ebx
c01052c6:	74 24                	je     c01052ec <check_swap+0xd5>
c01052c8:	c7 44 24 0c 76 b0 10 	movl   $0xc010b076,0xc(%esp)
c01052cf:	c0 
c01052d0:	c7 44 24 08 6a af 10 	movl   $0xc010af6a,0x8(%esp)
c01052d7:	c0 
c01052d8:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c01052df:	00 
c01052e0:	c7 04 24 04 af 10 c0 	movl   $0xc010af04,(%esp)
c01052e7:	e8 14 b1 ff ff       	call   c0100400 <__panic>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
c01052ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01052ef:	89 44 24 08          	mov    %eax,0x8(%esp)
c01052f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052f6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01052fa:	c7 04 24 90 b0 10 c0 	movl   $0xc010b090,(%esp)
c0105301:	e8 a3 af ff ff       	call   c01002a9 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
c0105306:	e8 f5 df ff ff       	call   c0103300 <mm_create>
c010530b:	89 45 e0             	mov    %eax,-0x20(%ebp)
     assert(mm != NULL);
c010530e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0105312:	75 24                	jne    c0105338 <check_swap+0x121>
c0105314:	c7 44 24 0c b6 b0 10 	movl   $0xc010b0b6,0xc(%esp)
c010531b:	c0 
c010531c:	c7 44 24 08 6a af 10 	movl   $0xc010af6a,0x8(%esp)
c0105323:	c0 
c0105324:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
c010532b:	00 
c010532c:	c7 04 24 04 af 10 c0 	movl   $0xc010af04,(%esp)
c0105333:	e8 c8 b0 ff ff       	call   c0100400 <__panic>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
c0105338:	a1 58 a0 12 c0       	mov    0xc012a058,%eax
c010533d:	85 c0                	test   %eax,%eax
c010533f:	74 24                	je     c0105365 <check_swap+0x14e>
c0105341:	c7 44 24 0c c1 b0 10 	movl   $0xc010b0c1,0xc(%esp)
c0105348:	c0 
c0105349:	c7 44 24 08 6a af 10 	movl   $0xc010af6a,0x8(%esp)
c0105350:	c0 
c0105351:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
c0105358:	00 
c0105359:	c7 04 24 04 af 10 c0 	movl   $0xc010af04,(%esp)
c0105360:	e8 9b b0 ff ff       	call   c0100400 <__panic>

     check_mm_struct = mm;
c0105365:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105368:	a3 58 a0 12 c0       	mov    %eax,0xc012a058

     pde_t *pgdir = mm->pgdir = boot_pgdir;
c010536d:	8b 15 20 4a 12 c0    	mov    0xc0124a20,%edx
c0105373:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105376:	89 50 0c             	mov    %edx,0xc(%eax)
c0105379:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010537c:	8b 40 0c             	mov    0xc(%eax),%eax
c010537f:	89 45 dc             	mov    %eax,-0x24(%ebp)
     assert(pgdir[0] == 0);
c0105382:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105385:	8b 00                	mov    (%eax),%eax
c0105387:	85 c0                	test   %eax,%eax
c0105389:	74 24                	je     c01053af <check_swap+0x198>
c010538b:	c7 44 24 0c d9 b0 10 	movl   $0xc010b0d9,0xc(%esp)
c0105392:	c0 
c0105393:	c7 44 24 08 6a af 10 	movl   $0xc010af6a,0x8(%esp)
c010539a:	c0 
c010539b:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c01053a2:	00 
c01053a3:	c7 04 24 04 af 10 c0 	movl   $0xc010af04,(%esp)
c01053aa:	e8 51 b0 ff ff       	call   c0100400 <__panic>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
c01053af:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
c01053b6:	00 
c01053b7:	c7 44 24 04 00 60 00 	movl   $0x6000,0x4(%esp)
c01053be:	00 
c01053bf:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
c01053c6:	e8 ad df ff ff       	call   c0103378 <vma_create>
c01053cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
     assert(vma != NULL);
c01053ce:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c01053d2:	75 24                	jne    c01053f8 <check_swap+0x1e1>
c01053d4:	c7 44 24 0c e7 b0 10 	movl   $0xc010b0e7,0xc(%esp)
c01053db:	c0 
c01053dc:	c7 44 24 08 6a af 10 	movl   $0xc010af6a,0x8(%esp)
c01053e3:	c0 
c01053e4:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c01053eb:	00 
c01053ec:	c7 04 24 04 af 10 c0 	movl   $0xc010af04,(%esp)
c01053f3:	e8 08 b0 ff ff       	call   c0100400 <__panic>

     insert_vma_struct(mm, vma);
c01053f8:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01053fb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01053ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105402:	89 04 24             	mov    %eax,(%esp)
c0105405:	e8 fe e0 ff ff       	call   c0103508 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
c010540a:	c7 04 24 f4 b0 10 c0 	movl   $0xc010b0f4,(%esp)
c0105411:	e8 93 ae ff ff       	call   c01002a9 <cprintf>
     pte_t *temp_ptep=NULL;
c0105416:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
c010541d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105420:	8b 40 0c             	mov    0xc(%eax),%eax
c0105423:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c010542a:	00 
c010542b:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0105432:	00 
c0105433:	89 04 24             	mov    %eax,(%esp)
c0105436:	e8 4a 1f 00 00       	call   c0107385 <get_pte>
c010543b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     assert(temp_ptep!= NULL);
c010543e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c0105442:	75 24                	jne    c0105468 <check_swap+0x251>
c0105444:	c7 44 24 0c 28 b1 10 	movl   $0xc010b128,0xc(%esp)
c010544b:	c0 
c010544c:	c7 44 24 08 6a af 10 	movl   $0xc010af6a,0x8(%esp)
c0105453:	c0 
c0105454:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
c010545b:	00 
c010545c:	c7 04 24 04 af 10 c0 	movl   $0xc010af04,(%esp)
c0105463:	e8 98 af ff ff       	call   c0100400 <__panic>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
c0105468:	c7 04 24 3c b1 10 c0 	movl   $0xc010b13c,(%esp)
c010546f:	e8 35 ae ff ff       	call   c01002a9 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105474:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010547b:	e9 a3 00 00 00       	jmp    c0105523 <check_swap+0x30c>
          check_rp[i] = alloc_page();
c0105480:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105487:	e8 15 18 00 00       	call   c0106ca1 <alloc_pages>
c010548c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010548f:	89 04 95 80 a0 12 c0 	mov    %eax,-0x3fed5f80(,%edx,4)
          assert(check_rp[i] != NULL );
c0105496:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105499:	8b 04 85 80 a0 12 c0 	mov    -0x3fed5f80(,%eax,4),%eax
c01054a0:	85 c0                	test   %eax,%eax
c01054a2:	75 24                	jne    c01054c8 <check_swap+0x2b1>
c01054a4:	c7 44 24 0c 60 b1 10 	movl   $0xc010b160,0xc(%esp)
c01054ab:	c0 
c01054ac:	c7 44 24 08 6a af 10 	movl   $0xc010af6a,0x8(%esp)
c01054b3:	c0 
c01054b4:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c01054bb:	00 
c01054bc:	c7 04 24 04 af 10 c0 	movl   $0xc010af04,(%esp)
c01054c3:	e8 38 af ff ff       	call   c0100400 <__panic>
          assert(!PageProperty(check_rp[i]));
c01054c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01054cb:	8b 04 85 80 a0 12 c0 	mov    -0x3fed5f80(,%eax,4),%eax
c01054d2:	83 c0 04             	add    $0x4,%eax
c01054d5:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
c01054dc:	89 45 b0             	mov    %eax,-0x50(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01054df:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01054e2:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01054e5:	0f a3 10             	bt     %edx,(%eax)
c01054e8:	19 c0                	sbb    %eax,%eax
c01054ea:	89 45 ac             	mov    %eax,-0x54(%ebp)
    return oldbit != 0;
c01054ed:	83 7d ac 00          	cmpl   $0x0,-0x54(%ebp)
c01054f1:	0f 95 c0             	setne  %al
c01054f4:	0f b6 c0             	movzbl %al,%eax
c01054f7:	85 c0                	test   %eax,%eax
c01054f9:	74 24                	je     c010551f <check_swap+0x308>
c01054fb:	c7 44 24 0c 74 b1 10 	movl   $0xc010b174,0xc(%esp)
c0105502:	c0 
c0105503:	c7 44 24 08 6a af 10 	movl   $0xc010af6a,0x8(%esp)
c010550a:	c0 
c010550b:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c0105512:	00 
c0105513:	c7 04 24 04 af 10 c0 	movl   $0xc010af04,(%esp)
c010551a:	e8 e1 ae ff ff       	call   c0100400 <__panic>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c010551f:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0105523:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0105527:	0f 8e 53 ff ff ff    	jle    c0105480 <check_swap+0x269>
     }
     list_entry_t free_list_store = free_list;
c010552d:	a1 44 a1 12 c0       	mov    0xc012a144,%eax
c0105532:	8b 15 48 a1 12 c0    	mov    0xc012a148,%edx
c0105538:	89 45 98             	mov    %eax,-0x68(%ebp)
c010553b:	89 55 9c             	mov    %edx,-0x64(%ebp)
c010553e:	c7 45 a8 44 a1 12 c0 	movl   $0xc012a144,-0x58(%ebp)
    elm->prev = elm->next = elm;
c0105545:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0105548:	8b 55 a8             	mov    -0x58(%ebp),%edx
c010554b:	89 50 04             	mov    %edx,0x4(%eax)
c010554e:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0105551:	8b 50 04             	mov    0x4(%eax),%edx
c0105554:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0105557:	89 10                	mov    %edx,(%eax)
c0105559:	c7 45 a4 44 a1 12 c0 	movl   $0xc012a144,-0x5c(%ebp)
    return list->next == list;
c0105560:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0105563:	8b 40 04             	mov    0x4(%eax),%eax
c0105566:	39 45 a4             	cmp    %eax,-0x5c(%ebp)
c0105569:	0f 94 c0             	sete   %al
c010556c:	0f b6 c0             	movzbl %al,%eax
     list_init(&free_list);
     assert(list_empty(&free_list));
c010556f:	85 c0                	test   %eax,%eax
c0105571:	75 24                	jne    c0105597 <check_swap+0x380>
c0105573:	c7 44 24 0c 8f b1 10 	movl   $0xc010b18f,0xc(%esp)
c010557a:	c0 
c010557b:	c7 44 24 08 6a af 10 	movl   $0xc010af6a,0x8(%esp)
c0105582:	c0 
c0105583:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
c010558a:	00 
c010558b:	c7 04 24 04 af 10 c0 	movl   $0xc010af04,(%esp)
c0105592:	e8 69 ae ff ff       	call   c0100400 <__panic>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
c0105597:	a1 4c a1 12 c0       	mov    0xc012a14c,%eax
c010559c:	89 45 d0             	mov    %eax,-0x30(%ebp)
     nr_free = 0;
c010559f:	c7 05 4c a1 12 c0 00 	movl   $0x0,0xc012a14c
c01055a6:	00 00 00 
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01055a9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01055b0:	eb 1e                	jmp    c01055d0 <check_swap+0x3b9>
        free_pages(check_rp[i],1);
c01055b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01055b5:	8b 04 85 80 a0 12 c0 	mov    -0x3fed5f80(,%eax,4),%eax
c01055bc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01055c3:	00 
c01055c4:	89 04 24             	mov    %eax,(%esp)
c01055c7:	e8 40 17 00 00       	call   c0106d0c <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01055cc:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c01055d0:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01055d4:	7e dc                	jle    c01055b2 <check_swap+0x39b>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
c01055d6:	a1 4c a1 12 c0       	mov    0xc012a14c,%eax
c01055db:	83 f8 04             	cmp    $0x4,%eax
c01055de:	74 24                	je     c0105604 <check_swap+0x3ed>
c01055e0:	c7 44 24 0c a8 b1 10 	movl   $0xc010b1a8,0xc(%esp)
c01055e7:	c0 
c01055e8:	c7 44 24 08 6a af 10 	movl   $0xc010af6a,0x8(%esp)
c01055ef:	c0 
c01055f0:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c01055f7:	00 
c01055f8:	c7 04 24 04 af 10 c0 	movl   $0xc010af04,(%esp)
c01055ff:	e8 fc ad ff ff       	call   c0100400 <__panic>
     
     cprintf("set up init env for check_swap begin!\n");
c0105604:	c7 04 24 cc b1 10 c0 	movl   $0xc010b1cc,(%esp)
c010560b:	e8 99 ac ff ff       	call   c01002a9 <cprintf>
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
c0105610:	c7 05 64 7f 12 c0 00 	movl   $0x0,0xc0127f64
c0105617:	00 00 00 
     
     check_content_set();
c010561a:	e8 28 fa ff ff       	call   c0105047 <check_content_set>
     assert( nr_free == 0);         
c010561f:	a1 4c a1 12 c0       	mov    0xc012a14c,%eax
c0105624:	85 c0                	test   %eax,%eax
c0105626:	74 24                	je     c010564c <check_swap+0x435>
c0105628:	c7 44 24 0c f3 b1 10 	movl   $0xc010b1f3,0xc(%esp)
c010562f:	c0 
c0105630:	c7 44 24 08 6a af 10 	movl   $0xc010af6a,0x8(%esp)
c0105637:	c0 
c0105638:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
c010563f:	00 
c0105640:	c7 04 24 04 af 10 c0 	movl   $0xc010af04,(%esp)
c0105647:	e8 b4 ad ff ff       	call   c0100400 <__panic>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c010564c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0105653:	eb 26                	jmp    c010567b <check_swap+0x464>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
c0105655:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105658:	c7 04 85 a0 a0 12 c0 	movl   $0xffffffff,-0x3fed5f60(,%eax,4)
c010565f:	ff ff ff ff 
c0105663:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105666:	8b 14 85 a0 a0 12 c0 	mov    -0x3fed5f60(,%eax,4),%edx
c010566d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105670:	89 14 85 e0 a0 12 c0 	mov    %edx,-0x3fed5f20(,%eax,4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0105677:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c010567b:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
c010567f:	7e d4                	jle    c0105655 <check_swap+0x43e>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105681:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0105688:	e9 eb 00 00 00       	jmp    c0105778 <check_swap+0x561>
         check_ptep[i]=0;
c010568d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105690:	c7 04 85 34 a1 12 c0 	movl   $0x0,-0x3fed5ecc(,%eax,4)
c0105697:	00 00 00 00 
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
c010569b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010569e:	83 c0 01             	add    $0x1,%eax
c01056a1:	c1 e0 0c             	shl    $0xc,%eax
c01056a4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01056ab:	00 
c01056ac:	89 44 24 04          	mov    %eax,0x4(%esp)
c01056b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01056b3:	89 04 24             	mov    %eax,(%esp)
c01056b6:	e8 ca 1c 00 00       	call   c0107385 <get_pte>
c01056bb:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01056be:	89 04 95 34 a1 12 c0 	mov    %eax,-0x3fed5ecc(,%edx,4)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
c01056c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01056c8:	8b 04 85 34 a1 12 c0 	mov    -0x3fed5ecc(,%eax,4),%eax
c01056cf:	85 c0                	test   %eax,%eax
c01056d1:	75 24                	jne    c01056f7 <check_swap+0x4e0>
c01056d3:	c7 44 24 0c 00 b2 10 	movl   $0xc010b200,0xc(%esp)
c01056da:	c0 
c01056db:	c7 44 24 08 6a af 10 	movl   $0xc010af6a,0x8(%esp)
c01056e2:	c0 
c01056e3:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c01056ea:	00 
c01056eb:	c7 04 24 04 af 10 c0 	movl   $0xc010af04,(%esp)
c01056f2:	e8 09 ad ff ff       	call   c0100400 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
c01056f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01056fa:	8b 04 85 34 a1 12 c0 	mov    -0x3fed5ecc(,%eax,4),%eax
c0105701:	8b 00                	mov    (%eax),%eax
c0105703:	89 04 24             	mov    %eax,(%esp)
c0105706:	e8 9f f5 ff ff       	call   c0104caa <pte2page>
c010570b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010570e:	8b 14 95 80 a0 12 c0 	mov    -0x3fed5f80(,%edx,4),%edx
c0105715:	39 d0                	cmp    %edx,%eax
c0105717:	74 24                	je     c010573d <check_swap+0x526>
c0105719:	c7 44 24 0c 18 b2 10 	movl   $0xc010b218,0xc(%esp)
c0105720:	c0 
c0105721:	c7 44 24 08 6a af 10 	movl   $0xc010af6a,0x8(%esp)
c0105728:	c0 
c0105729:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
c0105730:	00 
c0105731:	c7 04 24 04 af 10 c0 	movl   $0xc010af04,(%esp)
c0105738:	e8 c3 ac ff ff       	call   c0100400 <__panic>
         assert((*check_ptep[i] & PTE_P));          
c010573d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105740:	8b 04 85 34 a1 12 c0 	mov    -0x3fed5ecc(,%eax,4),%eax
c0105747:	8b 00                	mov    (%eax),%eax
c0105749:	83 e0 01             	and    $0x1,%eax
c010574c:	85 c0                	test   %eax,%eax
c010574e:	75 24                	jne    c0105774 <check_swap+0x55d>
c0105750:	c7 44 24 0c 40 b2 10 	movl   $0xc010b240,0xc(%esp)
c0105757:	c0 
c0105758:	c7 44 24 08 6a af 10 	movl   $0xc010af6a,0x8(%esp)
c010575f:	c0 
c0105760:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c0105767:	00 
c0105768:	c7 04 24 04 af 10 c0 	movl   $0xc010af04,(%esp)
c010576f:	e8 8c ac ff ff       	call   c0100400 <__panic>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105774:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0105778:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c010577c:	0f 8e 0b ff ff ff    	jle    c010568d <check_swap+0x476>
     }
     cprintf("set up init env for check_swap over!\n");
c0105782:	c7 04 24 5c b2 10 c0 	movl   $0xc010b25c,(%esp)
c0105789:	e8 1b ab ff ff       	call   c01002a9 <cprintf>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
c010578e:	e8 6c fa ff ff       	call   c01051ff <check_content_access>
c0105793:	89 45 cc             	mov    %eax,-0x34(%ebp)
     assert(ret==0);
c0105796:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c010579a:	74 24                	je     c01057c0 <check_swap+0x5a9>
c010579c:	c7 44 24 0c 82 b2 10 	movl   $0xc010b282,0xc(%esp)
c01057a3:	c0 
c01057a4:	c7 44 24 08 6a af 10 	movl   $0xc010af6a,0x8(%esp)
c01057ab:	c0 
c01057ac:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
c01057b3:	00 
c01057b4:	c7 04 24 04 af 10 c0 	movl   $0xc010af04,(%esp)
c01057bb:	e8 40 ac ff ff       	call   c0100400 <__panic>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01057c0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01057c7:	eb 1e                	jmp    c01057e7 <check_swap+0x5d0>
         free_pages(check_rp[i],1);
c01057c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01057cc:	8b 04 85 80 a0 12 c0 	mov    -0x3fed5f80(,%eax,4),%eax
c01057d3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01057da:	00 
c01057db:	89 04 24             	mov    %eax,(%esp)
c01057de:	e8 29 15 00 00       	call   c0106d0c <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01057e3:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c01057e7:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01057eb:	7e dc                	jle    c01057c9 <check_swap+0x5b2>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
c01057ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01057f0:	89 04 24             	mov    %eax,(%esp)
c01057f3:	e8 40 de ff ff       	call   c0103638 <mm_destroy>
         
     nr_free = nr_free_store;
c01057f8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01057fb:	a3 4c a1 12 c0       	mov    %eax,0xc012a14c
     free_list = free_list_store;
c0105800:	8b 45 98             	mov    -0x68(%ebp),%eax
c0105803:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0105806:	a3 44 a1 12 c0       	mov    %eax,0xc012a144
c010580b:	89 15 48 a1 12 c0    	mov    %edx,0xc012a148

     
     le = &free_list;
c0105811:	c7 45 e8 44 a1 12 c0 	movl   $0xc012a144,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0105818:	eb 1d                	jmp    c0105837 <check_swap+0x620>
         struct Page *p = le2page(le, page_link);
c010581a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010581d:	83 e8 0c             	sub    $0xc,%eax
c0105820:	89 45 c8             	mov    %eax,-0x38(%ebp)
         count --, total -= p->property;
c0105823:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0105827:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010582a:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010582d:	8b 40 08             	mov    0x8(%eax),%eax
c0105830:	29 c2                	sub    %eax,%edx
c0105832:	89 d0                	mov    %edx,%eax
c0105834:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105837:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010583a:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return listelm->next;
c010583d:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0105840:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c0105843:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105846:	81 7d e8 44 a1 12 c0 	cmpl   $0xc012a144,-0x18(%ebp)
c010584d:	75 cb                	jne    c010581a <check_swap+0x603>
     }
     cprintf("count is %d, total is %d\n",count,total);
c010584f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105852:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105856:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105859:	89 44 24 04          	mov    %eax,0x4(%esp)
c010585d:	c7 04 24 89 b2 10 c0 	movl   $0xc010b289,(%esp)
c0105864:	e8 40 aa ff ff       	call   c01002a9 <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
c0105869:	c7 04 24 a3 b2 10 c0 	movl   $0xc010b2a3,(%esp)
c0105870:	e8 34 aa ff ff       	call   c01002a9 <cprintf>
}
c0105875:	83 c4 74             	add    $0x74,%esp
c0105878:	5b                   	pop    %ebx
c0105879:	5d                   	pop    %ebp
c010587a:	c3                   	ret    

c010587b <page2ppn>:
page2ppn(struct Page *page) {
c010587b:	55                   	push   %ebp
c010587c:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010587e:	8b 55 08             	mov    0x8(%ebp),%edx
c0105881:	a1 58 a1 12 c0       	mov    0xc012a158,%eax
c0105886:	29 c2                	sub    %eax,%edx
c0105888:	89 d0                	mov    %edx,%eax
c010588a:	c1 f8 05             	sar    $0x5,%eax
}
c010588d:	5d                   	pop    %ebp
c010588e:	c3                   	ret    

c010588f <page2pa>:
page2pa(struct Page *page) {
c010588f:	55                   	push   %ebp
c0105890:	89 e5                	mov    %esp,%ebp
c0105892:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0105895:	8b 45 08             	mov    0x8(%ebp),%eax
c0105898:	89 04 24             	mov    %eax,(%esp)
c010589b:	e8 db ff ff ff       	call   c010587b <page2ppn>
c01058a0:	c1 e0 0c             	shl    $0xc,%eax
}
c01058a3:	c9                   	leave  
c01058a4:	c3                   	ret    

c01058a5 <page_ref>:

static inline int
page_ref(struct Page *page) {
c01058a5:	55                   	push   %ebp
c01058a6:	89 e5                	mov    %esp,%ebp
    return page->ref;
c01058a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01058ab:	8b 00                	mov    (%eax),%eax
}
c01058ad:	5d                   	pop    %ebp
c01058ae:	c3                   	ret    

c01058af <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c01058af:	55                   	push   %ebp
c01058b0:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c01058b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01058b5:	8b 55 0c             	mov    0xc(%ebp),%edx
c01058b8:	89 10                	mov    %edx,(%eax)
}
c01058ba:	5d                   	pop    %ebp
c01058bb:	c3                   	ret    

c01058bc <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c01058bc:	55                   	push   %ebp
c01058bd:	89 e5                	mov    %esp,%ebp
c01058bf:	83 ec 10             	sub    $0x10,%esp
c01058c2:	c7 45 fc 44 a1 12 c0 	movl   $0xc012a144,-0x4(%ebp)
    elm->prev = elm->next = elm;
c01058c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01058cc:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01058cf:	89 50 04             	mov    %edx,0x4(%eax)
c01058d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01058d5:	8b 50 04             	mov    0x4(%eax),%edx
c01058d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01058db:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c01058dd:	c7 05 4c a1 12 c0 00 	movl   $0x0,0xc012a14c
c01058e4:	00 00 00 
}
c01058e7:	c9                   	leave  
c01058e8:	c3                   	ret    

c01058e9 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c01058e9:	55                   	push   %ebp
c01058ea:	89 e5                	mov    %esp,%ebp
c01058ec:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c01058ef:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01058f3:	75 24                	jne    c0105919 <default_init_memmap+0x30>
c01058f5:	c7 44 24 0c bc b2 10 	movl   $0xc010b2bc,0xc(%esp)
c01058fc:	c0 
c01058fd:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c0105904:	c0 
c0105905:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c010590c:	00 
c010590d:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c0105914:	e8 e7 aa ff ff       	call   c0100400 <__panic>
    struct Page *p = base;
c0105919:	8b 45 08             	mov    0x8(%ebp),%eax
c010591c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c010591f:	e9 dc 00 00 00       	jmp    c0105a00 <default_init_memmap+0x117>
        //初始化n块物理页
        assert(PageReserved(p));
c0105924:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105927:	83 c0 04             	add    $0x4,%eax
c010592a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0105931:	89 45 ec             	mov    %eax,-0x14(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105934:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105937:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010593a:	0f a3 10             	bt     %edx,(%eax)
c010593d:	19 c0                	sbb    %eax,%eax
c010593f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c0105942:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105946:	0f 95 c0             	setne  %al
c0105949:	0f b6 c0             	movzbl %al,%eax
c010594c:	85 c0                	test   %eax,%eax
c010594e:	75 24                	jne    c0105974 <default_init_memmap+0x8b>
c0105950:	c7 44 24 0c ed b2 10 	movl   $0xc010b2ed,0xc(%esp)
c0105957:	c0 
c0105958:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c010595f:	c0 
c0105960:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
c0105967:	00 
c0105968:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c010596f:	e8 8c aa ff ff       	call   c0100400 <__panic>
        p->flags = 0;
c0105974:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105977:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        SetPageProperty(p);
c010597e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105981:	83 c0 04             	add    $0x4,%eax
c0105984:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c010598b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010598e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105991:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105994:	0f ab 10             	bts    %edx,(%eax)
        p->property = 0;
c0105997:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010599a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        set_page_ref(p, 0);
c01059a1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01059a8:	00 
c01059a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059ac:	89 04 24             	mov    %eax,(%esp)
c01059af:	e8 fb fe ff ff       	call   c01058af <set_page_ref>
        list_add_before(&free_list, &(p->page_link));
c01059b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059b7:	83 c0 0c             	add    $0xc,%eax
c01059ba:	c7 45 dc 44 a1 12 c0 	movl   $0xc012a144,-0x24(%ebp)
c01059c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
    __list_add(elm, listelm->prev, listelm);
c01059c4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01059c7:	8b 00                	mov    (%eax),%eax
c01059c9:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01059cc:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01059cf:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01059d2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01059d5:	89 45 cc             	mov    %eax,-0x34(%ebp)
    prev->next = next->prev = elm;
c01059d8:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01059db:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01059de:	89 10                	mov    %edx,(%eax)
c01059e0:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01059e3:	8b 10                	mov    (%eax),%edx
c01059e5:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01059e8:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01059eb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01059ee:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01059f1:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01059f4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01059f7:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01059fa:	89 10                	mov    %edx,(%eax)
    for (; p != base + n; p ++) {
c01059fc:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c0105a00:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a03:	c1 e0 05             	shl    $0x5,%eax
c0105a06:	89 c2                	mov    %eax,%edx
c0105a08:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a0b:	01 d0                	add    %edx,%eax
c0105a0d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105a10:	0f 85 0e ff ff ff    	jne    c0105924 <default_init_memmap+0x3b>
    }
    nr_free += n;
c0105a16:	8b 15 4c a1 12 c0    	mov    0xc012a14c,%edx
c0105a1c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a1f:	01 d0                	add    %edx,%eax
c0105a21:	a3 4c a1 12 c0       	mov    %eax,0xc012a14c
    base->property = n;
c0105a26:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a29:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105a2c:	89 50 08             	mov    %edx,0x8(%eax)
}
c0105a2f:	c9                   	leave  
c0105a30:	c3                   	ret    

c0105a31 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c0105a31:	55                   	push   %ebp
c0105a32:	89 e5                	mov    %esp,%ebp
c0105a34:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c0105a37:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105a3b:	75 24                	jne    c0105a61 <default_alloc_pages+0x30>
c0105a3d:	c7 44 24 0c bc b2 10 	movl   $0xc010b2bc,0xc(%esp)
c0105a44:	c0 
c0105a45:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c0105a4c:	c0 
c0105a4d:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
c0105a54:	00 
c0105a55:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c0105a5c:	e8 9f a9 ff ff       	call   c0100400 <__panic>
    if (n > nr_free) {
c0105a61:	a1 4c a1 12 c0       	mov    0xc012a14c,%eax
c0105a66:	3b 45 08             	cmp    0x8(%ebp),%eax
c0105a69:	73 0a                	jae    c0105a75 <default_alloc_pages+0x44>
        return NULL;
c0105a6b:	b8 00 00 00 00       	mov    $0x0,%eax
c0105a70:	e9 37 01 00 00       	jmp    c0105bac <default_alloc_pages+0x17b>
    }
    //如果所有空闲块的空闲页总数都没有n个,直接return null
    list_entry_t *le, *le_next;  //free_list指针和它的下一个
    le = &free_list;
c0105a75:	c7 45 f4 44 a1 12 c0 	movl   $0xc012a144,-0xc(%ebp)
    //从头开始遍历保存空闲物理内存块的链表(按照物理地址的从小到大顺序)
    while((le=list_next(le)) != &free_list) {
c0105a7c:	e9 0a 01 00 00       	jmp    c0105b8b <default_alloc_pages+0x15a>
    //通过宏le2page(memlayout.h)得指向Page的指针p
      struct Page *p = le2page(le, page_link);
c0105a81:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a84:	83 e8 0c             	sub    $0xc,%eax
c0105a87:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(p->property >= n){
c0105a8a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a8d:	8b 40 08             	mov    0x8(%eax),%eax
c0105a90:	3b 45 08             	cmp    0x8(%ebp),%eax
c0105a93:	0f 82 f2 00 00 00    	jb     c0105b8b <default_alloc_pages+0x15a>
        //p->property表示空闲块的大小，大于n则进下一步
        int i;
        //for初始化空闲块中每一个页
        for(i=0;i<n;i++){
c0105a99:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0105aa0:	eb 7c                	jmp    c0105b1e <default_alloc_pages+0xed>
c0105aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105aa5:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
c0105aa8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105aab:	8b 40 04             	mov    0x4(%eax),%eax
          le_next = list_next(le);
c0105aae:	89 45 e8             	mov    %eax,-0x18(%ebp)
          struct Page *p2 = le2page(le, page_link);
c0105ab1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ab4:	83 e8 0c             	sub    $0xc,%eax
c0105ab7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
          SetPageReserved(p2);//flags bit0 置1，表示已经被分配
c0105aba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105abd:	83 c0 04             	add    $0x4,%eax
c0105ac0:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0105ac7:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0105aca:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105acd:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105ad0:	0f ab 10             	bts    %edx,(%eax)
          ClearPageProperty(p2);//falgs bit1 置0，表示已被分配
c0105ad3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105ad6:	83 c0 04             	add    $0x4,%eax
c0105ad9:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0105ae0:	89 45 d0             	mov    %eax,-0x30(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105ae3:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105ae6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105ae9:	0f b3 10             	btr    %edx,(%eax)
c0105aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105aef:	89 45 cc             	mov    %eax,-0x34(%ebp)
    __list_del(listelm->prev, listelm->next);
c0105af2:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105af5:	8b 40 04             	mov    0x4(%eax),%eax
c0105af8:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0105afb:	8b 12                	mov    (%edx),%edx
c0105afd:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0105b00:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    prev->next = next;
c0105b03:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0105b06:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0105b09:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0105b0c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105b0f:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0105b12:	89 10                	mov    %edx,(%eax)
          list_del(le);//取消和free_list的link
          le = le_next;//指针后移
c0105b14:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105b17:	89 45 f4             	mov    %eax,-0xc(%ebp)
        for(i=0;i<n;i++){
c0105b1a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
c0105b1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b21:	3b 45 08             	cmp    0x8(%ebp),%eax
c0105b24:	0f 82 78 ff ff ff    	jb     c0105aa2 <default_alloc_pages+0x71>
        }
        //如果选中的块大于n,需要修改剩下的块的head page的property
        if(p->property>n){
c0105b2a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105b2d:	8b 40 08             	mov    0x8(%eax),%eax
c0105b30:	3b 45 08             	cmp    0x8(%ebp),%eax
c0105b33:	76 12                	jbe    c0105b47 <default_alloc_pages+0x116>
          (le2page(le,page_link))->property = p->property - n;
c0105b35:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105b38:	8d 50 f4             	lea    -0xc(%eax),%edx
c0105b3b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105b3e:	8b 40 08             	mov    0x8(%eax),%eax
c0105b41:	2b 45 08             	sub    0x8(%ebp),%eax
c0105b44:	89 42 08             	mov    %eax,0x8(%edx)
        }
        ClearPageProperty(p);
c0105b47:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105b4a:	83 c0 04             	add    $0x4,%eax
c0105b4d:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0105b54:	89 45 bc             	mov    %eax,-0x44(%ebp)
c0105b57:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0105b5a:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0105b5d:	0f b3 10             	btr    %edx,(%eax)
        SetPageReserved(p);
c0105b60:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105b63:	83 c0 04             	add    $0x4,%eax
c0105b66:	c7 45 b8 00 00 00 00 	movl   $0x0,-0x48(%ebp)
c0105b6d:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105b70:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0105b73:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0105b76:	0f ab 10             	bts    %edx,(%eax)
        nr_free -= n;
c0105b79:	a1 4c a1 12 c0       	mov    0xc012a14c,%eax
c0105b7e:	2b 45 08             	sub    0x8(%ebp),%eax
c0105b81:	a3 4c a1 12 c0       	mov    %eax,0xc012a14c
        return p;
c0105b86:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105b89:	eb 21                	jmp    c0105bac <default_alloc_pages+0x17b>
c0105b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105b8e:	89 45 b0             	mov    %eax,-0x50(%ebp)
    return listelm->next;
c0105b91:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0105b94:	8b 40 04             	mov    0x4(%eax),%eax
    while((le=list_next(le)) != &free_list) {
c0105b97:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105b9a:	81 7d f4 44 a1 12 c0 	cmpl   $0xc012a144,-0xc(%ebp)
c0105ba1:	0f 85 da fe ff ff    	jne    c0105a81 <default_alloc_pages+0x50>
      }
    }
    return NULL;//防止出错
c0105ba7:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105bac:	c9                   	leave  
c0105bad:	c3                   	ret    

c0105bae <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c0105bae:	55                   	push   %ebp
c0105baf:	89 e5                	mov    %esp,%ebp
c0105bb1:	83 ec 68             	sub    $0x68,%esp
     assert(n > 0);
c0105bb4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105bb8:	75 24                	jne    c0105bde <default_free_pages+0x30>
c0105bba:	c7 44 24 0c bc b2 10 	movl   $0xc010b2bc,0xc(%esp)
c0105bc1:	c0 
c0105bc2:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c0105bc9:	c0 
c0105bca:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
c0105bd1:	00 
c0105bd2:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c0105bd9:	e8 22 a8 ff ff       	call   c0100400 <__panic>
    //assert(PageReserved(base) && PageProperty(base));
    assert(PageReserved(base));
c0105bde:	8b 45 08             	mov    0x8(%ebp),%eax
c0105be1:	83 c0 04             	add    $0x4,%eax
c0105be4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0105beb:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105bee:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105bf1:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105bf4:	0f a3 10             	bt     %edx,(%eax)
c0105bf7:	19 c0                	sbb    %eax,%eax
c0105bf9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c0105bfc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105c00:	0f 95 c0             	setne  %al
c0105c03:	0f b6 c0             	movzbl %al,%eax
c0105c06:	85 c0                	test   %eax,%eax
c0105c08:	75 24                	jne    c0105c2e <default_free_pages+0x80>
c0105c0a:	c7 44 24 0c fd b2 10 	movl   $0xc010b2fd,0xc(%esp)
c0105c11:	c0 
c0105c12:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c0105c19:	c0 
c0105c1a:	c7 44 24 04 a6 00 00 	movl   $0xa6,0x4(%esp)
c0105c21:	00 
c0105c22:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c0105c29:	e8 d2 a7 ff ff       	call   c0100400 <__panic>
    //检查需要释放的页块是否已经被分配,只要看bit 0 reserve就好了
    list_entry_t *le = &free_list;
c0105c2e:	c7 45 f4 44 a1 12 c0 	movl   $0xc012a144,-0xc(%ebp)
    struct Page * p;
    while((le=list_next(le)) != &free_list) {
c0105c35:	eb 13                	jmp    c0105c4a <default_free_pages+0x9c>
      p = le2page(le, page_link);
c0105c37:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c3a:	83 e8 0c             	sub    $0xc,%eax
c0105c3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(p>base){break;}
c0105c40:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c43:	3b 45 08             	cmp    0x8(%ebp),%eax
c0105c46:	76 02                	jbe    c0105c4a <default_free_pages+0x9c>
c0105c48:	eb 18                	jmp    c0105c62 <default_free_pages+0xb4>
c0105c4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c4d:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105c50:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105c53:	8b 40 04             	mov    0x4(%eax),%eax
    while((le=list_next(le)) != &free_list) {
c0105c56:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105c59:	81 7d f4 44 a1 12 c0 	cmpl   $0xc012a144,-0xc(%ebp)
c0105c60:	75 d5                	jne    c0105c37 <default_free_pages+0x89>
    }
    //将每一空闲块的链表插入空闲链表中
    for(p=base;p<base+n;p++){
c0105c62:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c65:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105c68:	eb 4b                	jmp    c0105cb5 <default_free_pages+0x107>
      list_add_before(le, &(p->page_link));
c0105c6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c6d:	8d 50 0c             	lea    0xc(%eax),%edx
c0105c70:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c73:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105c76:	89 55 d8             	mov    %edx,-0x28(%ebp)
    __list_add(elm, listelm->prev, listelm);
c0105c79:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105c7c:	8b 00                	mov    (%eax),%eax
c0105c7e:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105c81:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0105c84:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0105c87:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105c8a:	89 45 cc             	mov    %eax,-0x34(%ebp)
    prev->next = next->prev = elm;
c0105c8d:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105c90:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105c93:	89 10                	mov    %edx,(%eax)
c0105c95:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105c98:	8b 10                	mov    (%eax),%edx
c0105c9a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105c9d:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0105ca0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105ca3:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0105ca6:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0105ca9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105cac:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105caf:	89 10                	mov    %edx,(%eax)
    for(p=base;p<base+n;p++){
c0105cb1:	83 45 f0 20          	addl   $0x20,-0x10(%ebp)
c0105cb5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105cb8:	c1 e0 05             	shl    $0x5,%eax
c0105cbb:	89 c2                	mov    %eax,%edx
c0105cbd:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cc0:	01 d0                	add    %edx,%eax
c0105cc2:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0105cc5:	77 a3                	ja     c0105c6a <default_free_pages+0xbc>
    }
    //修改页的各个属性置0
    base->flags = 0;
c0105cc7:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cca:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    set_page_ref(base, 0);
c0105cd1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105cd8:	00 
c0105cd9:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cdc:	89 04 24             	mov    %eax,(%esp)
c0105cdf:	e8 cb fb ff ff       	call   c01058af <set_page_ref>
    ClearPageProperty(base);
c0105ce4:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ce7:	83 c0 04             	add    $0x4,%eax
c0105cea:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c0105cf1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105cf4:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105cf7:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0105cfa:	0f b3 10             	btr    %edx,(%eax)
    SetPageProperty(base);
c0105cfd:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d00:	83 c0 04             	add    $0x4,%eax
c0105d03:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0105d0a:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105d0d:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0105d10:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0105d13:	0f ab 10             	bts    %edx,(%eax)
    base->property = n;//有n空闲页
c0105d16:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d19:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105d1c:	89 50 08             	mov    %edx,0x8(%eax)
    p = le2page(le,page_link) ;
c0105d1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105d22:	83 e8 0c             	sub    $0xc,%eax
c0105d25:	89 45 f0             	mov    %eax,-0x10(%ebp)
    //和高位方向的下一个内存块的地址连续，向高位合并
    if( base+n == p ){
c0105d28:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d2b:	c1 e0 05             	shl    $0x5,%eax
c0105d2e:	89 c2                	mov    %eax,%edx
c0105d30:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d33:	01 d0                	add    %edx,%eax
c0105d35:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0105d38:	75 1e                	jne    c0105d58 <default_free_pages+0x1aa>
      base->property += p->property;
c0105d3a:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d3d:	8b 50 08             	mov    0x8(%eax),%edx
c0105d40:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d43:	8b 40 08             	mov    0x8(%eax),%eax
c0105d46:	01 c2                	add    %eax,%edx
c0105d48:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d4b:	89 50 08             	mov    %edx,0x8(%eax)
      p->property = 0;
c0105d4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d51:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    }
    //如果是低位,向低地址合并
    //把le指针指向前一个内存块
    le = list_prev(&(base->page_link));  //previous
c0105d58:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d5b:	83 c0 0c             	add    $0xc,%eax
c0105d5e:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return listelm->prev;
c0105d61:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0105d64:	8b 00                	mov    (%eax),%eax
c0105d66:	89 45 f4             	mov    %eax,-0xc(%ebp)
    p = le2page(le, page_link);
c0105d69:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105d6c:	83 e8 0c             	sub    $0xc,%eax
c0105d6f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(le!=&free_list && p==base-1){
c0105d72:	81 7d f4 44 a1 12 c0 	cmpl   $0xc012a144,-0xc(%ebp)
c0105d79:	74 57                	je     c0105dd2 <default_free_pages+0x224>
c0105d7b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d7e:	83 e8 20             	sub    $0x20,%eax
c0105d81:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0105d84:	75 4c                	jne    c0105dd2 <default_free_pages+0x224>
      while(le!=&free_list){
c0105d86:	eb 41                	jmp    c0105dc9 <default_free_pages+0x21b>
        if(p->property){
c0105d88:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d8b:	8b 40 08             	mov    0x8(%eax),%eax
c0105d8e:	85 c0                	test   %eax,%eax
c0105d90:	74 20                	je     c0105db2 <default_free_pages+0x204>
          p->property += base->property;
c0105d92:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d95:	8b 50 08             	mov    0x8(%eax),%edx
c0105d98:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d9b:	8b 40 08             	mov    0x8(%eax),%eax
c0105d9e:	01 c2                	add    %eax,%edx
c0105da0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105da3:	89 50 08             	mov    %edx,0x8(%eax)
          base->property = 0;
c0105da6:	8b 45 08             	mov    0x8(%ebp),%eax
c0105da9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
          break;
c0105db0:	eb 20                	jmp    c0105dd2 <default_free_pages+0x224>
c0105db2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105db5:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c0105db8:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0105dbb:	8b 00                	mov    (%eax),%eax
        }
        le = list_prev(le);
c0105dbd:	89 45 f4             	mov    %eax,-0xc(%ebp)
        p = le2page(le,page_link);
c0105dc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105dc3:	83 e8 0c             	sub    $0xc,%eax
c0105dc6:	89 45 f0             	mov    %eax,-0x10(%ebp)
      while(le!=&free_list){
c0105dc9:	81 7d f4 44 a1 12 c0 	cmpl   $0xc012a144,-0xc(%ebp)
c0105dd0:	75 b6                	jne    c0105d88 <default_free_pages+0x1da>
      }
    }
   //更新总空闲页数
    nr_free += n;
c0105dd2:	8b 15 4c a1 12 c0    	mov    0xc012a14c,%edx
c0105dd8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ddb:	01 d0                	add    %edx,%eax
c0105ddd:	a3 4c a1 12 c0       	mov    %eax,0xc012a14c
    return ;
c0105de2:	90                   	nop
}
c0105de3:	c9                   	leave  
c0105de4:	c3                   	ret    

c0105de5 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0105de5:	55                   	push   %ebp
c0105de6:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0105de8:	a1 4c a1 12 c0       	mov    0xc012a14c,%eax
}
c0105ded:	5d                   	pop    %ebp
c0105dee:	c3                   	ret    

c0105def <basic_check>:

static void
basic_check(void) {
c0105def:	55                   	push   %ebp
c0105df0:	89 e5                	mov    %esp,%ebp
c0105df2:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0105df5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105dfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105dff:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105e02:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e05:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0105e08:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105e0f:	e8 8d 0e 00 00       	call   c0106ca1 <alloc_pages>
c0105e14:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105e17:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0105e1b:	75 24                	jne    c0105e41 <basic_check+0x52>
c0105e1d:	c7 44 24 0c 10 b3 10 	movl   $0xc010b310,0xc(%esp)
c0105e24:	c0 
c0105e25:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c0105e2c:	c0 
c0105e2d:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c0105e34:	00 
c0105e35:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c0105e3c:	e8 bf a5 ff ff       	call   c0100400 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0105e41:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105e48:	e8 54 0e 00 00       	call   c0106ca1 <alloc_pages>
c0105e4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105e50:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105e54:	75 24                	jne    c0105e7a <basic_check+0x8b>
c0105e56:	c7 44 24 0c 2c b3 10 	movl   $0xc010b32c,0xc(%esp)
c0105e5d:	c0 
c0105e5e:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c0105e65:	c0 
c0105e66:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c0105e6d:	00 
c0105e6e:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c0105e75:	e8 86 a5 ff ff       	call   c0100400 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0105e7a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105e81:	e8 1b 0e 00 00       	call   c0106ca1 <alloc_pages>
c0105e86:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105e89:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105e8d:	75 24                	jne    c0105eb3 <basic_check+0xc4>
c0105e8f:	c7 44 24 0c 48 b3 10 	movl   $0xc010b348,0xc(%esp)
c0105e96:	c0 
c0105e97:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c0105e9e:	c0 
c0105e9f:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
c0105ea6:	00 
c0105ea7:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c0105eae:	e8 4d a5 ff ff       	call   c0100400 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0105eb3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105eb6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0105eb9:	74 10                	je     c0105ecb <basic_check+0xdc>
c0105ebb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105ebe:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105ec1:	74 08                	je     c0105ecb <basic_check+0xdc>
c0105ec3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ec6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105ec9:	75 24                	jne    c0105eef <basic_check+0x100>
c0105ecb:	c7 44 24 0c 64 b3 10 	movl   $0xc010b364,0xc(%esp)
c0105ed2:	c0 
c0105ed3:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c0105eda:	c0 
c0105edb:	c7 44 24 04 df 00 00 	movl   $0xdf,0x4(%esp)
c0105ee2:	00 
c0105ee3:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c0105eea:	e8 11 a5 ff ff       	call   c0100400 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0105eef:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105ef2:	89 04 24             	mov    %eax,(%esp)
c0105ef5:	e8 ab f9 ff ff       	call   c01058a5 <page_ref>
c0105efa:	85 c0                	test   %eax,%eax
c0105efc:	75 1e                	jne    c0105f1c <basic_check+0x12d>
c0105efe:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105f01:	89 04 24             	mov    %eax,(%esp)
c0105f04:	e8 9c f9 ff ff       	call   c01058a5 <page_ref>
c0105f09:	85 c0                	test   %eax,%eax
c0105f0b:	75 0f                	jne    c0105f1c <basic_check+0x12d>
c0105f0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105f10:	89 04 24             	mov    %eax,(%esp)
c0105f13:	e8 8d f9 ff ff       	call   c01058a5 <page_ref>
c0105f18:	85 c0                	test   %eax,%eax
c0105f1a:	74 24                	je     c0105f40 <basic_check+0x151>
c0105f1c:	c7 44 24 0c 88 b3 10 	movl   $0xc010b388,0xc(%esp)
c0105f23:	c0 
c0105f24:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c0105f2b:	c0 
c0105f2c:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
c0105f33:	00 
c0105f34:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c0105f3b:	e8 c0 a4 ff ff       	call   c0100400 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0105f40:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105f43:	89 04 24             	mov    %eax,(%esp)
c0105f46:	e8 44 f9 ff ff       	call   c010588f <page2pa>
c0105f4b:	8b 15 80 7f 12 c0    	mov    0xc0127f80,%edx
c0105f51:	c1 e2 0c             	shl    $0xc,%edx
c0105f54:	39 d0                	cmp    %edx,%eax
c0105f56:	72 24                	jb     c0105f7c <basic_check+0x18d>
c0105f58:	c7 44 24 0c c4 b3 10 	movl   $0xc010b3c4,0xc(%esp)
c0105f5f:	c0 
c0105f60:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c0105f67:	c0 
c0105f68:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
c0105f6f:	00 
c0105f70:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c0105f77:	e8 84 a4 ff ff       	call   c0100400 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0105f7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105f7f:	89 04 24             	mov    %eax,(%esp)
c0105f82:	e8 08 f9 ff ff       	call   c010588f <page2pa>
c0105f87:	8b 15 80 7f 12 c0    	mov    0xc0127f80,%edx
c0105f8d:	c1 e2 0c             	shl    $0xc,%edx
c0105f90:	39 d0                	cmp    %edx,%eax
c0105f92:	72 24                	jb     c0105fb8 <basic_check+0x1c9>
c0105f94:	c7 44 24 0c e1 b3 10 	movl   $0xc010b3e1,0xc(%esp)
c0105f9b:	c0 
c0105f9c:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c0105fa3:	c0 
c0105fa4:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c0105fab:	00 
c0105fac:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c0105fb3:	e8 48 a4 ff ff       	call   c0100400 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0105fb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105fbb:	89 04 24             	mov    %eax,(%esp)
c0105fbe:	e8 cc f8 ff ff       	call   c010588f <page2pa>
c0105fc3:	8b 15 80 7f 12 c0    	mov    0xc0127f80,%edx
c0105fc9:	c1 e2 0c             	shl    $0xc,%edx
c0105fcc:	39 d0                	cmp    %edx,%eax
c0105fce:	72 24                	jb     c0105ff4 <basic_check+0x205>
c0105fd0:	c7 44 24 0c fe b3 10 	movl   $0xc010b3fe,0xc(%esp)
c0105fd7:	c0 
c0105fd8:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c0105fdf:	c0 
c0105fe0:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
c0105fe7:	00 
c0105fe8:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c0105fef:	e8 0c a4 ff ff       	call   c0100400 <__panic>

    list_entry_t free_list_store = free_list;
c0105ff4:	a1 44 a1 12 c0       	mov    0xc012a144,%eax
c0105ff9:	8b 15 48 a1 12 c0    	mov    0xc012a148,%edx
c0105fff:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0106002:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0106005:	c7 45 e0 44 a1 12 c0 	movl   $0xc012a144,-0x20(%ebp)
    elm->prev = elm->next = elm;
c010600c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010600f:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106012:	89 50 04             	mov    %edx,0x4(%eax)
c0106015:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106018:	8b 50 04             	mov    0x4(%eax),%edx
c010601b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010601e:	89 10                	mov    %edx,(%eax)
c0106020:	c7 45 dc 44 a1 12 c0 	movl   $0xc012a144,-0x24(%ebp)
    return list->next == list;
c0106027:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010602a:	8b 40 04             	mov    0x4(%eax),%eax
c010602d:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0106030:	0f 94 c0             	sete   %al
c0106033:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0106036:	85 c0                	test   %eax,%eax
c0106038:	75 24                	jne    c010605e <basic_check+0x26f>
c010603a:	c7 44 24 0c 1b b4 10 	movl   $0xc010b41b,0xc(%esp)
c0106041:	c0 
c0106042:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c0106049:	c0 
c010604a:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
c0106051:	00 
c0106052:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c0106059:	e8 a2 a3 ff ff       	call   c0100400 <__panic>

    unsigned int nr_free_store = nr_free;
c010605e:	a1 4c a1 12 c0       	mov    0xc012a14c,%eax
c0106063:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0106066:	c7 05 4c a1 12 c0 00 	movl   $0x0,0xc012a14c
c010606d:	00 00 00 

    assert(alloc_page() == NULL);
c0106070:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106077:	e8 25 0c 00 00       	call   c0106ca1 <alloc_pages>
c010607c:	85 c0                	test   %eax,%eax
c010607e:	74 24                	je     c01060a4 <basic_check+0x2b5>
c0106080:	c7 44 24 0c 32 b4 10 	movl   $0xc010b432,0xc(%esp)
c0106087:	c0 
c0106088:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c010608f:	c0 
c0106090:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
c0106097:	00 
c0106098:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c010609f:	e8 5c a3 ff ff       	call   c0100400 <__panic>

    free_page(p0);
c01060a4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01060ab:	00 
c01060ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01060af:	89 04 24             	mov    %eax,(%esp)
c01060b2:	e8 55 0c 00 00       	call   c0106d0c <free_pages>
    free_page(p1);
c01060b7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01060be:	00 
c01060bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01060c2:	89 04 24             	mov    %eax,(%esp)
c01060c5:	e8 42 0c 00 00       	call   c0106d0c <free_pages>
    free_page(p2);
c01060ca:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01060d1:	00 
c01060d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01060d5:	89 04 24             	mov    %eax,(%esp)
c01060d8:	e8 2f 0c 00 00       	call   c0106d0c <free_pages>
    assert(nr_free == 3);
c01060dd:	a1 4c a1 12 c0       	mov    0xc012a14c,%eax
c01060e2:	83 f8 03             	cmp    $0x3,%eax
c01060e5:	74 24                	je     c010610b <basic_check+0x31c>
c01060e7:	c7 44 24 0c 47 b4 10 	movl   $0xc010b447,0xc(%esp)
c01060ee:	c0 
c01060ef:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c01060f6:	c0 
c01060f7:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
c01060fe:	00 
c01060ff:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c0106106:	e8 f5 a2 ff ff       	call   c0100400 <__panic>

    assert((p0 = alloc_page()) != NULL);
c010610b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106112:	e8 8a 0b 00 00       	call   c0106ca1 <alloc_pages>
c0106117:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010611a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010611e:	75 24                	jne    c0106144 <basic_check+0x355>
c0106120:	c7 44 24 0c 10 b3 10 	movl   $0xc010b310,0xc(%esp)
c0106127:	c0 
c0106128:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c010612f:	c0 
c0106130:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
c0106137:	00 
c0106138:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c010613f:	e8 bc a2 ff ff       	call   c0100400 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0106144:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010614b:	e8 51 0b 00 00       	call   c0106ca1 <alloc_pages>
c0106150:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106153:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106157:	75 24                	jne    c010617d <basic_check+0x38e>
c0106159:	c7 44 24 0c 2c b3 10 	movl   $0xc010b32c,0xc(%esp)
c0106160:	c0 
c0106161:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c0106168:	c0 
c0106169:	c7 44 24 04 f5 00 00 	movl   $0xf5,0x4(%esp)
c0106170:	00 
c0106171:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c0106178:	e8 83 a2 ff ff       	call   c0100400 <__panic>
    assert((p2 = alloc_page()) != NULL);
c010617d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106184:	e8 18 0b 00 00       	call   c0106ca1 <alloc_pages>
c0106189:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010618c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106190:	75 24                	jne    c01061b6 <basic_check+0x3c7>
c0106192:	c7 44 24 0c 48 b3 10 	movl   $0xc010b348,0xc(%esp)
c0106199:	c0 
c010619a:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c01061a1:	c0 
c01061a2:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
c01061a9:	00 
c01061aa:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c01061b1:	e8 4a a2 ff ff       	call   c0100400 <__panic>

    assert(alloc_page() == NULL);
c01061b6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01061bd:	e8 df 0a 00 00       	call   c0106ca1 <alloc_pages>
c01061c2:	85 c0                	test   %eax,%eax
c01061c4:	74 24                	je     c01061ea <basic_check+0x3fb>
c01061c6:	c7 44 24 0c 32 b4 10 	movl   $0xc010b432,0xc(%esp)
c01061cd:	c0 
c01061ce:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c01061d5:	c0 
c01061d6:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c01061dd:	00 
c01061de:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c01061e5:	e8 16 a2 ff ff       	call   c0100400 <__panic>

    free_page(p0);
c01061ea:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01061f1:	00 
c01061f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01061f5:	89 04 24             	mov    %eax,(%esp)
c01061f8:	e8 0f 0b 00 00       	call   c0106d0c <free_pages>
c01061fd:	c7 45 d8 44 a1 12 c0 	movl   $0xc012a144,-0x28(%ebp)
c0106204:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106207:	8b 40 04             	mov    0x4(%eax),%eax
c010620a:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c010620d:	0f 94 c0             	sete   %al
c0106210:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0106213:	85 c0                	test   %eax,%eax
c0106215:	74 24                	je     c010623b <basic_check+0x44c>
c0106217:	c7 44 24 0c 54 b4 10 	movl   $0xc010b454,0xc(%esp)
c010621e:	c0 
c010621f:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c0106226:	c0 
c0106227:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c010622e:	00 
c010622f:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c0106236:	e8 c5 a1 ff ff       	call   c0100400 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c010623b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106242:	e8 5a 0a 00 00       	call   c0106ca1 <alloc_pages>
c0106247:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010624a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010624d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0106250:	74 24                	je     c0106276 <basic_check+0x487>
c0106252:	c7 44 24 0c 6c b4 10 	movl   $0xc010b46c,0xc(%esp)
c0106259:	c0 
c010625a:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c0106261:	c0 
c0106262:	c7 44 24 04 fe 00 00 	movl   $0xfe,0x4(%esp)
c0106269:	00 
c010626a:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c0106271:	e8 8a a1 ff ff       	call   c0100400 <__panic>
    assert(alloc_page() == NULL);
c0106276:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010627d:	e8 1f 0a 00 00       	call   c0106ca1 <alloc_pages>
c0106282:	85 c0                	test   %eax,%eax
c0106284:	74 24                	je     c01062aa <basic_check+0x4bb>
c0106286:	c7 44 24 0c 32 b4 10 	movl   $0xc010b432,0xc(%esp)
c010628d:	c0 
c010628e:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c0106295:	c0 
c0106296:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
c010629d:	00 
c010629e:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c01062a5:	e8 56 a1 ff ff       	call   c0100400 <__panic>

    assert(nr_free == 0);
c01062aa:	a1 4c a1 12 c0       	mov    0xc012a14c,%eax
c01062af:	85 c0                	test   %eax,%eax
c01062b1:	74 24                	je     c01062d7 <basic_check+0x4e8>
c01062b3:	c7 44 24 0c 85 b4 10 	movl   $0xc010b485,0xc(%esp)
c01062ba:	c0 
c01062bb:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c01062c2:	c0 
c01062c3:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c01062ca:	00 
c01062cb:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c01062d2:	e8 29 a1 ff ff       	call   c0100400 <__panic>
    free_list = free_list_store;
c01062d7:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01062da:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01062dd:	a3 44 a1 12 c0       	mov    %eax,0xc012a144
c01062e2:	89 15 48 a1 12 c0    	mov    %edx,0xc012a148
    nr_free = nr_free_store;
c01062e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01062eb:	a3 4c a1 12 c0       	mov    %eax,0xc012a14c

    free_page(p);
c01062f0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01062f7:	00 
c01062f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01062fb:	89 04 24             	mov    %eax,(%esp)
c01062fe:	e8 09 0a 00 00       	call   c0106d0c <free_pages>
    free_page(p1);
c0106303:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010630a:	00 
c010630b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010630e:	89 04 24             	mov    %eax,(%esp)
c0106311:	e8 f6 09 00 00       	call   c0106d0c <free_pages>
    free_page(p2);
c0106316:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010631d:	00 
c010631e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106321:	89 04 24             	mov    %eax,(%esp)
c0106324:	e8 e3 09 00 00       	call   c0106d0c <free_pages>
}
c0106329:	c9                   	leave  
c010632a:	c3                   	ret    

c010632b <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c010632b:	55                   	push   %ebp
c010632c:	89 e5                	mov    %esp,%ebp
c010632e:	53                   	push   %ebx
c010632f:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
c0106335:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010633c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0106343:	c7 45 ec 44 a1 12 c0 	movl   $0xc012a144,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c010634a:	eb 6b                	jmp    c01063b7 <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
c010634c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010634f:	83 e8 0c             	sub    $0xc,%eax
c0106352:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
c0106355:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106358:	83 c0 04             	add    $0x4,%eax
c010635b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0106362:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106365:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0106368:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010636b:	0f a3 10             	bt     %edx,(%eax)
c010636e:	19 c0                	sbb    %eax,%eax
c0106370:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0106373:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0106377:	0f 95 c0             	setne  %al
c010637a:	0f b6 c0             	movzbl %al,%eax
c010637d:	85 c0                	test   %eax,%eax
c010637f:	75 24                	jne    c01063a5 <default_check+0x7a>
c0106381:	c7 44 24 0c 92 b4 10 	movl   $0xc010b492,0xc(%esp)
c0106388:	c0 
c0106389:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c0106390:	c0 
c0106391:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
c0106398:	00 
c0106399:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c01063a0:	e8 5b a0 ff ff       	call   c0100400 <__panic>
        count ++, total += p->property;
c01063a5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01063a9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01063ac:	8b 50 08             	mov    0x8(%eax),%edx
c01063af:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01063b2:	01 d0                	add    %edx,%eax
c01063b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01063b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01063ba:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c01063bd:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01063c0:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c01063c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01063c6:	81 7d ec 44 a1 12 c0 	cmpl   $0xc012a144,-0x14(%ebp)
c01063cd:	0f 85 79 ff ff ff    	jne    c010634c <default_check+0x21>
    }
    assert(total == nr_free_pages());
c01063d3:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c01063d6:	e8 63 09 00 00       	call   c0106d3e <nr_free_pages>
c01063db:	39 c3                	cmp    %eax,%ebx
c01063dd:	74 24                	je     c0106403 <default_check+0xd8>
c01063df:	c7 44 24 0c a2 b4 10 	movl   $0xc010b4a2,0xc(%esp)
c01063e6:	c0 
c01063e7:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c01063ee:	c0 
c01063ef:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c01063f6:	00 
c01063f7:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c01063fe:	e8 fd 9f ff ff       	call   c0100400 <__panic>

    basic_check();
c0106403:	e8 e7 f9 ff ff       	call   c0105def <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0106408:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c010640f:	e8 8d 08 00 00       	call   c0106ca1 <alloc_pages>
c0106414:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
c0106417:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010641b:	75 24                	jne    c0106441 <default_check+0x116>
c010641d:	c7 44 24 0c bb b4 10 	movl   $0xc010b4bb,0xc(%esp)
c0106424:	c0 
c0106425:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c010642c:	c0 
c010642d:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c0106434:	00 
c0106435:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c010643c:	e8 bf 9f ff ff       	call   c0100400 <__panic>
    assert(!PageProperty(p0));
c0106441:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106444:	83 c0 04             	add    $0x4,%eax
c0106447:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c010644e:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106451:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0106454:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0106457:	0f a3 10             	bt     %edx,(%eax)
c010645a:	19 c0                	sbb    %eax,%eax
c010645c:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c010645f:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0106463:	0f 95 c0             	setne  %al
c0106466:	0f b6 c0             	movzbl %al,%eax
c0106469:	85 c0                	test   %eax,%eax
c010646b:	74 24                	je     c0106491 <default_check+0x166>
c010646d:	c7 44 24 0c c6 b4 10 	movl   $0xc010b4c6,0xc(%esp)
c0106474:	c0 
c0106475:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c010647c:	c0 
c010647d:	c7 44 24 04 1b 01 00 	movl   $0x11b,0x4(%esp)
c0106484:	00 
c0106485:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c010648c:	e8 6f 9f ff ff       	call   c0100400 <__panic>

    list_entry_t free_list_store = free_list;
c0106491:	a1 44 a1 12 c0       	mov    0xc012a144,%eax
c0106496:	8b 15 48 a1 12 c0    	mov    0xc012a148,%edx
c010649c:	89 45 80             	mov    %eax,-0x80(%ebp)
c010649f:	89 55 84             	mov    %edx,-0x7c(%ebp)
c01064a2:	c7 45 b4 44 a1 12 c0 	movl   $0xc012a144,-0x4c(%ebp)
    elm->prev = elm->next = elm;
c01064a9:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01064ac:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01064af:	89 50 04             	mov    %edx,0x4(%eax)
c01064b2:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01064b5:	8b 50 04             	mov    0x4(%eax),%edx
c01064b8:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01064bb:	89 10                	mov    %edx,(%eax)
c01064bd:	c7 45 b0 44 a1 12 c0 	movl   $0xc012a144,-0x50(%ebp)
    return list->next == list;
c01064c4:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01064c7:	8b 40 04             	mov    0x4(%eax),%eax
c01064ca:	39 45 b0             	cmp    %eax,-0x50(%ebp)
c01064cd:	0f 94 c0             	sete   %al
c01064d0:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c01064d3:	85 c0                	test   %eax,%eax
c01064d5:	75 24                	jne    c01064fb <default_check+0x1d0>
c01064d7:	c7 44 24 0c 1b b4 10 	movl   $0xc010b41b,0xc(%esp)
c01064de:	c0 
c01064df:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c01064e6:	c0 
c01064e7:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
c01064ee:	00 
c01064ef:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c01064f6:	e8 05 9f ff ff       	call   c0100400 <__panic>
    assert(alloc_page() == NULL);
c01064fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106502:	e8 9a 07 00 00       	call   c0106ca1 <alloc_pages>
c0106507:	85 c0                	test   %eax,%eax
c0106509:	74 24                	je     c010652f <default_check+0x204>
c010650b:	c7 44 24 0c 32 b4 10 	movl   $0xc010b432,0xc(%esp)
c0106512:	c0 
c0106513:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c010651a:	c0 
c010651b:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
c0106522:	00 
c0106523:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c010652a:	e8 d1 9e ff ff       	call   c0100400 <__panic>

    unsigned int nr_free_store = nr_free;
c010652f:	a1 4c a1 12 c0       	mov    0xc012a14c,%eax
c0106534:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c0106537:	c7 05 4c a1 12 c0 00 	movl   $0x0,0xc012a14c
c010653e:	00 00 00 

    free_pages(p0 + 2, 3);
c0106541:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106544:	83 c0 40             	add    $0x40,%eax
c0106547:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c010654e:	00 
c010654f:	89 04 24             	mov    %eax,(%esp)
c0106552:	e8 b5 07 00 00       	call   c0106d0c <free_pages>
    assert(alloc_pages(4) == NULL);
c0106557:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c010655e:	e8 3e 07 00 00       	call   c0106ca1 <alloc_pages>
c0106563:	85 c0                	test   %eax,%eax
c0106565:	74 24                	je     c010658b <default_check+0x260>
c0106567:	c7 44 24 0c d8 b4 10 	movl   $0xc010b4d8,0xc(%esp)
c010656e:	c0 
c010656f:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c0106576:	c0 
c0106577:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
c010657e:	00 
c010657f:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c0106586:	e8 75 9e ff ff       	call   c0100400 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c010658b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010658e:	83 c0 40             	add    $0x40,%eax
c0106591:	83 c0 04             	add    $0x4,%eax
c0106594:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c010659b:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010659e:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01065a1:	8b 55 ac             	mov    -0x54(%ebp),%edx
c01065a4:	0f a3 10             	bt     %edx,(%eax)
c01065a7:	19 c0                	sbb    %eax,%eax
c01065a9:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c01065ac:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c01065b0:	0f 95 c0             	setne  %al
c01065b3:	0f b6 c0             	movzbl %al,%eax
c01065b6:	85 c0                	test   %eax,%eax
c01065b8:	74 0e                	je     c01065c8 <default_check+0x29d>
c01065ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01065bd:	83 c0 40             	add    $0x40,%eax
c01065c0:	8b 40 08             	mov    0x8(%eax),%eax
c01065c3:	83 f8 03             	cmp    $0x3,%eax
c01065c6:	74 24                	je     c01065ec <default_check+0x2c1>
c01065c8:	c7 44 24 0c f0 b4 10 	movl   $0xc010b4f0,0xc(%esp)
c01065cf:	c0 
c01065d0:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c01065d7:	c0 
c01065d8:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
c01065df:	00 
c01065e0:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c01065e7:	e8 14 9e ff ff       	call   c0100400 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c01065ec:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c01065f3:	e8 a9 06 00 00       	call   c0106ca1 <alloc_pages>
c01065f8:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01065fb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01065ff:	75 24                	jne    c0106625 <default_check+0x2fa>
c0106601:	c7 44 24 0c 1c b5 10 	movl   $0xc010b51c,0xc(%esp)
c0106608:	c0 
c0106609:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c0106610:	c0 
c0106611:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
c0106618:	00 
c0106619:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c0106620:	e8 db 9d ff ff       	call   c0100400 <__panic>
    assert(alloc_page() == NULL);
c0106625:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010662c:	e8 70 06 00 00       	call   c0106ca1 <alloc_pages>
c0106631:	85 c0                	test   %eax,%eax
c0106633:	74 24                	je     c0106659 <default_check+0x32e>
c0106635:	c7 44 24 0c 32 b4 10 	movl   $0xc010b432,0xc(%esp)
c010663c:	c0 
c010663d:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c0106644:	c0 
c0106645:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
c010664c:	00 
c010664d:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c0106654:	e8 a7 9d ff ff       	call   c0100400 <__panic>
    assert(p0 + 2 == p1);
c0106659:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010665c:	83 c0 40             	add    $0x40,%eax
c010665f:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0106662:	74 24                	je     c0106688 <default_check+0x35d>
c0106664:	c7 44 24 0c 3a b5 10 	movl   $0xc010b53a,0xc(%esp)
c010666b:	c0 
c010666c:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c0106673:	c0 
c0106674:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
c010667b:	00 
c010667c:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c0106683:	e8 78 9d ff ff       	call   c0100400 <__panic>

    p2 = p0 + 1;
c0106688:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010668b:	83 c0 20             	add    $0x20,%eax
c010668e:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
c0106691:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106698:	00 
c0106699:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010669c:	89 04 24             	mov    %eax,(%esp)
c010669f:	e8 68 06 00 00       	call   c0106d0c <free_pages>
    free_pages(p1, 3);
c01066a4:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c01066ab:	00 
c01066ac:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01066af:	89 04 24             	mov    %eax,(%esp)
c01066b2:	e8 55 06 00 00       	call   c0106d0c <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c01066b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01066ba:	83 c0 04             	add    $0x4,%eax
c01066bd:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c01066c4:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01066c7:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01066ca:	8b 55 a0             	mov    -0x60(%ebp),%edx
c01066cd:	0f a3 10             	bt     %edx,(%eax)
c01066d0:	19 c0                	sbb    %eax,%eax
c01066d2:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c01066d5:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c01066d9:	0f 95 c0             	setne  %al
c01066dc:	0f b6 c0             	movzbl %al,%eax
c01066df:	85 c0                	test   %eax,%eax
c01066e1:	74 0b                	je     c01066ee <default_check+0x3c3>
c01066e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01066e6:	8b 40 08             	mov    0x8(%eax),%eax
c01066e9:	83 f8 01             	cmp    $0x1,%eax
c01066ec:	74 24                	je     c0106712 <default_check+0x3e7>
c01066ee:	c7 44 24 0c 48 b5 10 	movl   $0xc010b548,0xc(%esp)
c01066f5:	c0 
c01066f6:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c01066fd:	c0 
c01066fe:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
c0106705:	00 
c0106706:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c010670d:	e8 ee 9c ff ff       	call   c0100400 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0106712:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106715:	83 c0 04             	add    $0x4,%eax
c0106718:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c010671f:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106722:	8b 45 90             	mov    -0x70(%ebp),%eax
c0106725:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0106728:	0f a3 10             	bt     %edx,(%eax)
c010672b:	19 c0                	sbb    %eax,%eax
c010672d:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c0106730:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c0106734:	0f 95 c0             	setne  %al
c0106737:	0f b6 c0             	movzbl %al,%eax
c010673a:	85 c0                	test   %eax,%eax
c010673c:	74 0b                	je     c0106749 <default_check+0x41e>
c010673e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106741:	8b 40 08             	mov    0x8(%eax),%eax
c0106744:	83 f8 03             	cmp    $0x3,%eax
c0106747:	74 24                	je     c010676d <default_check+0x442>
c0106749:	c7 44 24 0c 70 b5 10 	movl   $0xc010b570,0xc(%esp)
c0106750:	c0 
c0106751:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c0106758:	c0 
c0106759:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
c0106760:	00 
c0106761:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c0106768:	e8 93 9c ff ff       	call   c0100400 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c010676d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106774:	e8 28 05 00 00       	call   c0106ca1 <alloc_pages>
c0106779:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010677c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010677f:	83 e8 20             	sub    $0x20,%eax
c0106782:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0106785:	74 24                	je     c01067ab <default_check+0x480>
c0106787:	c7 44 24 0c 96 b5 10 	movl   $0xc010b596,0xc(%esp)
c010678e:	c0 
c010678f:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c0106796:	c0 
c0106797:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
c010679e:	00 
c010679f:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c01067a6:	e8 55 9c ff ff       	call   c0100400 <__panic>
    free_page(p0);
c01067ab:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01067b2:	00 
c01067b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01067b6:	89 04 24             	mov    %eax,(%esp)
c01067b9:	e8 4e 05 00 00       	call   c0106d0c <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c01067be:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c01067c5:	e8 d7 04 00 00       	call   c0106ca1 <alloc_pages>
c01067ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01067cd:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01067d0:	83 c0 20             	add    $0x20,%eax
c01067d3:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c01067d6:	74 24                	je     c01067fc <default_check+0x4d1>
c01067d8:	c7 44 24 0c b4 b5 10 	movl   $0xc010b5b4,0xc(%esp)
c01067df:	c0 
c01067e0:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c01067e7:	c0 
c01067e8:	c7 44 24 04 34 01 00 	movl   $0x134,0x4(%esp)
c01067ef:	00 
c01067f0:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c01067f7:	e8 04 9c ff ff       	call   c0100400 <__panic>

    free_pages(p0, 2);
c01067fc:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0106803:	00 
c0106804:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106807:	89 04 24             	mov    %eax,(%esp)
c010680a:	e8 fd 04 00 00       	call   c0106d0c <free_pages>
    free_page(p2);
c010680f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106816:	00 
c0106817:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010681a:	89 04 24             	mov    %eax,(%esp)
c010681d:	e8 ea 04 00 00       	call   c0106d0c <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c0106822:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0106829:	e8 73 04 00 00       	call   c0106ca1 <alloc_pages>
c010682e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106831:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106835:	75 24                	jne    c010685b <default_check+0x530>
c0106837:	c7 44 24 0c d4 b5 10 	movl   $0xc010b5d4,0xc(%esp)
c010683e:	c0 
c010683f:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c0106846:	c0 
c0106847:	c7 44 24 04 39 01 00 	movl   $0x139,0x4(%esp)
c010684e:	00 
c010684f:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c0106856:	e8 a5 9b ff ff       	call   c0100400 <__panic>
    assert(alloc_page() == NULL);
c010685b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106862:	e8 3a 04 00 00       	call   c0106ca1 <alloc_pages>
c0106867:	85 c0                	test   %eax,%eax
c0106869:	74 24                	je     c010688f <default_check+0x564>
c010686b:	c7 44 24 0c 32 b4 10 	movl   $0xc010b432,0xc(%esp)
c0106872:	c0 
c0106873:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c010687a:	c0 
c010687b:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
c0106882:	00 
c0106883:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c010688a:	e8 71 9b ff ff       	call   c0100400 <__panic>

    assert(nr_free == 0);
c010688f:	a1 4c a1 12 c0       	mov    0xc012a14c,%eax
c0106894:	85 c0                	test   %eax,%eax
c0106896:	74 24                	je     c01068bc <default_check+0x591>
c0106898:	c7 44 24 0c 85 b4 10 	movl   $0xc010b485,0xc(%esp)
c010689f:	c0 
c01068a0:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c01068a7:	c0 
c01068a8:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
c01068af:	00 
c01068b0:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c01068b7:	e8 44 9b ff ff       	call   c0100400 <__panic>
    nr_free = nr_free_store;
c01068bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01068bf:	a3 4c a1 12 c0       	mov    %eax,0xc012a14c

    free_list = free_list_store;
c01068c4:	8b 45 80             	mov    -0x80(%ebp),%eax
c01068c7:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01068ca:	a3 44 a1 12 c0       	mov    %eax,0xc012a144
c01068cf:	89 15 48 a1 12 c0    	mov    %edx,0xc012a148
    free_pages(p0, 5);
c01068d5:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c01068dc:	00 
c01068dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01068e0:	89 04 24             	mov    %eax,(%esp)
c01068e3:	e8 24 04 00 00       	call   c0106d0c <free_pages>

    le = &free_list;
c01068e8:	c7 45 ec 44 a1 12 c0 	movl   $0xc012a144,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01068ef:	eb 1d                	jmp    c010690e <default_check+0x5e3>
        struct Page *p = le2page(le, page_link);
c01068f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01068f4:	83 e8 0c             	sub    $0xc,%eax
c01068f7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
c01068fa:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01068fe:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0106901:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106904:	8b 40 08             	mov    0x8(%eax),%eax
c0106907:	29 c2                	sub    %eax,%edx
c0106909:	89 d0                	mov    %edx,%eax
c010690b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010690e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106911:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c0106914:	8b 45 88             	mov    -0x78(%ebp),%eax
c0106917:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c010691a:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010691d:	81 7d ec 44 a1 12 c0 	cmpl   $0xc012a144,-0x14(%ebp)
c0106924:	75 cb                	jne    c01068f1 <default_check+0x5c6>
    }
    assert(count == 0);
c0106926:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010692a:	74 24                	je     c0106950 <default_check+0x625>
c010692c:	c7 44 24 0c f2 b5 10 	movl   $0xc010b5f2,0xc(%esp)
c0106933:	c0 
c0106934:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c010693b:	c0 
c010693c:	c7 44 24 04 47 01 00 	movl   $0x147,0x4(%esp)
c0106943:	00 
c0106944:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c010694b:	e8 b0 9a ff ff       	call   c0100400 <__panic>
    assert(total == 0);
c0106950:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106954:	74 24                	je     c010697a <default_check+0x64f>
c0106956:	c7 44 24 0c fd b5 10 	movl   $0xc010b5fd,0xc(%esp)
c010695d:	c0 
c010695e:	c7 44 24 08 c2 b2 10 	movl   $0xc010b2c2,0x8(%esp)
c0106965:	c0 
c0106966:	c7 44 24 04 48 01 00 	movl   $0x148,0x4(%esp)
c010696d:	00 
c010696e:	c7 04 24 d7 b2 10 c0 	movl   $0xc010b2d7,(%esp)
c0106975:	e8 86 9a ff ff       	call   c0100400 <__panic>
}
c010697a:	81 c4 94 00 00 00    	add    $0x94,%esp
c0106980:	5b                   	pop    %ebx
c0106981:	5d                   	pop    %ebp
c0106982:	c3                   	ret    

c0106983 <page2ppn>:
page2ppn(struct Page *page) {
c0106983:	55                   	push   %ebp
c0106984:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0106986:	8b 55 08             	mov    0x8(%ebp),%edx
c0106989:	a1 58 a1 12 c0       	mov    0xc012a158,%eax
c010698e:	29 c2                	sub    %eax,%edx
c0106990:	89 d0                	mov    %edx,%eax
c0106992:	c1 f8 05             	sar    $0x5,%eax
}
c0106995:	5d                   	pop    %ebp
c0106996:	c3                   	ret    

c0106997 <page2pa>:
page2pa(struct Page *page) {
c0106997:	55                   	push   %ebp
c0106998:	89 e5                	mov    %esp,%ebp
c010699a:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c010699d:	8b 45 08             	mov    0x8(%ebp),%eax
c01069a0:	89 04 24             	mov    %eax,(%esp)
c01069a3:	e8 db ff ff ff       	call   c0106983 <page2ppn>
c01069a8:	c1 e0 0c             	shl    $0xc,%eax
}
c01069ab:	c9                   	leave  
c01069ac:	c3                   	ret    

c01069ad <pa2page>:
pa2page(uintptr_t pa) {
c01069ad:	55                   	push   %ebp
c01069ae:	89 e5                	mov    %esp,%ebp
c01069b0:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c01069b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01069b6:	c1 e8 0c             	shr    $0xc,%eax
c01069b9:	89 c2                	mov    %eax,%edx
c01069bb:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c01069c0:	39 c2                	cmp    %eax,%edx
c01069c2:	72 1c                	jb     c01069e0 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c01069c4:	c7 44 24 08 38 b6 10 	movl   $0xc010b638,0x8(%esp)
c01069cb:	c0 
c01069cc:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c01069d3:	00 
c01069d4:	c7 04 24 57 b6 10 c0 	movl   $0xc010b657,(%esp)
c01069db:	e8 20 9a ff ff       	call   c0100400 <__panic>
    return &pages[PPN(pa)];
c01069e0:	a1 58 a1 12 c0       	mov    0xc012a158,%eax
c01069e5:	8b 55 08             	mov    0x8(%ebp),%edx
c01069e8:	c1 ea 0c             	shr    $0xc,%edx
c01069eb:	c1 e2 05             	shl    $0x5,%edx
c01069ee:	01 d0                	add    %edx,%eax
}
c01069f0:	c9                   	leave  
c01069f1:	c3                   	ret    

c01069f2 <page2kva>:
page2kva(struct Page *page) {
c01069f2:	55                   	push   %ebp
c01069f3:	89 e5                	mov    %esp,%ebp
c01069f5:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c01069f8:	8b 45 08             	mov    0x8(%ebp),%eax
c01069fb:	89 04 24             	mov    %eax,(%esp)
c01069fe:	e8 94 ff ff ff       	call   c0106997 <page2pa>
c0106a03:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106a06:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106a09:	c1 e8 0c             	shr    $0xc,%eax
c0106a0c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106a0f:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c0106a14:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0106a17:	72 23                	jb     c0106a3c <page2kva+0x4a>
c0106a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106a1c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106a20:	c7 44 24 08 68 b6 10 	movl   $0xc010b668,0x8(%esp)
c0106a27:	c0 
c0106a28:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c0106a2f:	00 
c0106a30:	c7 04 24 57 b6 10 c0 	movl   $0xc010b657,(%esp)
c0106a37:	e8 c4 99 ff ff       	call   c0100400 <__panic>
c0106a3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106a3f:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0106a44:	c9                   	leave  
c0106a45:	c3                   	ret    

c0106a46 <pte2page>:
pte2page(pte_t pte) {
c0106a46:	55                   	push   %ebp
c0106a47:	89 e5                	mov    %esp,%ebp
c0106a49:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0106a4c:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a4f:	83 e0 01             	and    $0x1,%eax
c0106a52:	85 c0                	test   %eax,%eax
c0106a54:	75 1c                	jne    c0106a72 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0106a56:	c7 44 24 08 8c b6 10 	movl   $0xc010b68c,0x8(%esp)
c0106a5d:	c0 
c0106a5e:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
c0106a65:	00 
c0106a66:	c7 04 24 57 b6 10 c0 	movl   $0xc010b657,(%esp)
c0106a6d:	e8 8e 99 ff ff       	call   c0100400 <__panic>
    return pa2page(PTE_ADDR(pte));
c0106a72:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a75:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106a7a:	89 04 24             	mov    %eax,(%esp)
c0106a7d:	e8 2b ff ff ff       	call   c01069ad <pa2page>
}
c0106a82:	c9                   	leave  
c0106a83:	c3                   	ret    

c0106a84 <pde2page>:
pde2page(pde_t pde) {
c0106a84:	55                   	push   %ebp
c0106a85:	89 e5                	mov    %esp,%ebp
c0106a87:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0106a8a:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a8d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106a92:	89 04 24             	mov    %eax,(%esp)
c0106a95:	e8 13 ff ff ff       	call   c01069ad <pa2page>
}
c0106a9a:	c9                   	leave  
c0106a9b:	c3                   	ret    

c0106a9c <page_ref>:
page_ref(struct Page *page) {
c0106a9c:	55                   	push   %ebp
c0106a9d:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0106a9f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106aa2:	8b 00                	mov    (%eax),%eax
}
c0106aa4:	5d                   	pop    %ebp
c0106aa5:	c3                   	ret    

c0106aa6 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c0106aa6:	55                   	push   %ebp
c0106aa7:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0106aa9:	8b 45 08             	mov    0x8(%ebp),%eax
c0106aac:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106aaf:	89 10                	mov    %edx,(%eax)
}
c0106ab1:	5d                   	pop    %ebp
c0106ab2:	c3                   	ret    

c0106ab3 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0106ab3:	55                   	push   %ebp
c0106ab4:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0106ab6:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ab9:	8b 00                	mov    (%eax),%eax
c0106abb:	8d 50 01             	lea    0x1(%eax),%edx
c0106abe:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ac1:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0106ac3:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ac6:	8b 00                	mov    (%eax),%eax
}
c0106ac8:	5d                   	pop    %ebp
c0106ac9:	c3                   	ret    

c0106aca <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0106aca:	55                   	push   %ebp
c0106acb:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0106acd:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ad0:	8b 00                	mov    (%eax),%eax
c0106ad2:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106ad5:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ad8:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0106ada:	8b 45 08             	mov    0x8(%ebp),%eax
c0106add:	8b 00                	mov    (%eax),%eax
}
c0106adf:	5d                   	pop    %ebp
c0106ae0:	c3                   	ret    

c0106ae1 <__intr_save>:
__intr_save(void) {
c0106ae1:	55                   	push   %ebp
c0106ae2:	89 e5                	mov    %esp,%ebp
c0106ae4:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0106ae7:	9c                   	pushf  
c0106ae8:	58                   	pop    %eax
c0106ae9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0106aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0106aef:	25 00 02 00 00       	and    $0x200,%eax
c0106af4:	85 c0                	test   %eax,%eax
c0106af6:	74 0c                	je     c0106b04 <__intr_save+0x23>
        intr_disable();
c0106af8:	e8 20 b6 ff ff       	call   c010211d <intr_disable>
        return 1;
c0106afd:	b8 01 00 00 00       	mov    $0x1,%eax
c0106b02:	eb 05                	jmp    c0106b09 <__intr_save+0x28>
    return 0;
c0106b04:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106b09:	c9                   	leave  
c0106b0a:	c3                   	ret    

c0106b0b <__intr_restore>:
__intr_restore(bool flag) {
c0106b0b:	55                   	push   %ebp
c0106b0c:	89 e5                	mov    %esp,%ebp
c0106b0e:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0106b11:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0106b15:	74 05                	je     c0106b1c <__intr_restore+0x11>
        intr_enable();
c0106b17:	e8 fb b5 ff ff       	call   c0102117 <intr_enable>
}
c0106b1c:	c9                   	leave  
c0106b1d:	c3                   	ret    

c0106b1e <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0106b1e:	55                   	push   %ebp
c0106b1f:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0106b21:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b24:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0106b27:	b8 23 00 00 00       	mov    $0x23,%eax
c0106b2c:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0106b2e:	b8 23 00 00 00       	mov    $0x23,%eax
c0106b33:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0106b35:	b8 10 00 00 00       	mov    $0x10,%eax
c0106b3a:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0106b3c:	b8 10 00 00 00       	mov    $0x10,%eax
c0106b41:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0106b43:	b8 10 00 00 00       	mov    $0x10,%eax
c0106b48:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0106b4a:	ea 51 6b 10 c0 08 00 	ljmp   $0x8,$0xc0106b51
}
c0106b51:	5d                   	pop    %ebp
c0106b52:	c3                   	ret    

c0106b53 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0106b53:	55                   	push   %ebp
c0106b54:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0106b56:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b59:	a3 a4 7f 12 c0       	mov    %eax,0xc0127fa4
}
c0106b5e:	5d                   	pop    %ebp
c0106b5f:	c3                   	ret    

c0106b60 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0106b60:	55                   	push   %ebp
c0106b61:	89 e5                	mov    %esp,%ebp
c0106b63:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0106b66:	b8 00 40 12 c0       	mov    $0xc0124000,%eax
c0106b6b:	89 04 24             	mov    %eax,(%esp)
c0106b6e:	e8 e0 ff ff ff       	call   c0106b53 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0106b73:	66 c7 05 a8 7f 12 c0 	movw   $0x10,0xc0127fa8
c0106b7a:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0106b7c:	66 c7 05 68 4a 12 c0 	movw   $0x68,0xc0124a68
c0106b83:	68 00 
c0106b85:	b8 a0 7f 12 c0       	mov    $0xc0127fa0,%eax
c0106b8a:	66 a3 6a 4a 12 c0    	mov    %ax,0xc0124a6a
c0106b90:	b8 a0 7f 12 c0       	mov    $0xc0127fa0,%eax
c0106b95:	c1 e8 10             	shr    $0x10,%eax
c0106b98:	a2 6c 4a 12 c0       	mov    %al,0xc0124a6c
c0106b9d:	0f b6 05 6d 4a 12 c0 	movzbl 0xc0124a6d,%eax
c0106ba4:	83 e0 f0             	and    $0xfffffff0,%eax
c0106ba7:	83 c8 09             	or     $0x9,%eax
c0106baa:	a2 6d 4a 12 c0       	mov    %al,0xc0124a6d
c0106baf:	0f b6 05 6d 4a 12 c0 	movzbl 0xc0124a6d,%eax
c0106bb6:	83 e0 ef             	and    $0xffffffef,%eax
c0106bb9:	a2 6d 4a 12 c0       	mov    %al,0xc0124a6d
c0106bbe:	0f b6 05 6d 4a 12 c0 	movzbl 0xc0124a6d,%eax
c0106bc5:	83 e0 9f             	and    $0xffffff9f,%eax
c0106bc8:	a2 6d 4a 12 c0       	mov    %al,0xc0124a6d
c0106bcd:	0f b6 05 6d 4a 12 c0 	movzbl 0xc0124a6d,%eax
c0106bd4:	83 c8 80             	or     $0xffffff80,%eax
c0106bd7:	a2 6d 4a 12 c0       	mov    %al,0xc0124a6d
c0106bdc:	0f b6 05 6e 4a 12 c0 	movzbl 0xc0124a6e,%eax
c0106be3:	83 e0 f0             	and    $0xfffffff0,%eax
c0106be6:	a2 6e 4a 12 c0       	mov    %al,0xc0124a6e
c0106beb:	0f b6 05 6e 4a 12 c0 	movzbl 0xc0124a6e,%eax
c0106bf2:	83 e0 ef             	and    $0xffffffef,%eax
c0106bf5:	a2 6e 4a 12 c0       	mov    %al,0xc0124a6e
c0106bfa:	0f b6 05 6e 4a 12 c0 	movzbl 0xc0124a6e,%eax
c0106c01:	83 e0 df             	and    $0xffffffdf,%eax
c0106c04:	a2 6e 4a 12 c0       	mov    %al,0xc0124a6e
c0106c09:	0f b6 05 6e 4a 12 c0 	movzbl 0xc0124a6e,%eax
c0106c10:	83 c8 40             	or     $0x40,%eax
c0106c13:	a2 6e 4a 12 c0       	mov    %al,0xc0124a6e
c0106c18:	0f b6 05 6e 4a 12 c0 	movzbl 0xc0124a6e,%eax
c0106c1f:	83 e0 7f             	and    $0x7f,%eax
c0106c22:	a2 6e 4a 12 c0       	mov    %al,0xc0124a6e
c0106c27:	b8 a0 7f 12 c0       	mov    $0xc0127fa0,%eax
c0106c2c:	c1 e8 18             	shr    $0x18,%eax
c0106c2f:	a2 6f 4a 12 c0       	mov    %al,0xc0124a6f

    // reload all segment registers
    lgdt(&gdt_pd);
c0106c34:	c7 04 24 70 4a 12 c0 	movl   $0xc0124a70,(%esp)
c0106c3b:	e8 de fe ff ff       	call   c0106b1e <lgdt>
c0106c40:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0106c46:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0106c4a:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0106c4d:	c9                   	leave  
c0106c4e:	c3                   	ret    

c0106c4f <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0106c4f:	55                   	push   %ebp
c0106c50:	89 e5                	mov    %esp,%ebp
c0106c52:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0106c55:	c7 05 50 a1 12 c0 1c 	movl   $0xc010b61c,0xc012a150
c0106c5c:	b6 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0106c5f:	a1 50 a1 12 c0       	mov    0xc012a150,%eax
c0106c64:	8b 00                	mov    (%eax),%eax
c0106c66:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106c6a:	c7 04 24 b8 b6 10 c0 	movl   $0xc010b6b8,(%esp)
c0106c71:	e8 33 96 ff ff       	call   c01002a9 <cprintf>
    pmm_manager->init();
c0106c76:	a1 50 a1 12 c0       	mov    0xc012a150,%eax
c0106c7b:	8b 40 04             	mov    0x4(%eax),%eax
c0106c7e:	ff d0                	call   *%eax
}
c0106c80:	c9                   	leave  
c0106c81:	c3                   	ret    

c0106c82 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0106c82:	55                   	push   %ebp
c0106c83:	89 e5                	mov    %esp,%ebp
c0106c85:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0106c88:	a1 50 a1 12 c0       	mov    0xc012a150,%eax
c0106c8d:	8b 40 08             	mov    0x8(%eax),%eax
c0106c90:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106c93:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106c97:	8b 55 08             	mov    0x8(%ebp),%edx
c0106c9a:	89 14 24             	mov    %edx,(%esp)
c0106c9d:	ff d0                	call   *%eax
}
c0106c9f:	c9                   	leave  
c0106ca0:	c3                   	ret    

c0106ca1 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0106ca1:	55                   	push   %ebp
c0106ca2:	89 e5                	mov    %esp,%ebp
c0106ca4:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0106ca7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    
    while (1)
    {
         local_intr_save(intr_flag);
c0106cae:	e8 2e fe ff ff       	call   c0106ae1 <__intr_save>
c0106cb3:	89 45 f0             	mov    %eax,-0x10(%ebp)
         {
              page = pmm_manager->alloc_pages(n);
c0106cb6:	a1 50 a1 12 c0       	mov    0xc012a150,%eax
c0106cbb:	8b 40 0c             	mov    0xc(%eax),%eax
c0106cbe:	8b 55 08             	mov    0x8(%ebp),%edx
c0106cc1:	89 14 24             	mov    %edx,(%esp)
c0106cc4:	ff d0                	call   *%eax
c0106cc6:	89 45 f4             	mov    %eax,-0xc(%ebp)
         }
         local_intr_restore(intr_flag);
c0106cc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106ccc:	89 04 24             	mov    %eax,(%esp)
c0106ccf:	e8 37 fe ff ff       	call   c0106b0b <__intr_restore>

         if (page != NULL || n > 1 || swap_init_ok == 0) break;
c0106cd4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106cd8:	75 2d                	jne    c0106d07 <alloc_pages+0x66>
c0106cda:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
c0106cde:	77 27                	ja     c0106d07 <alloc_pages+0x66>
c0106ce0:	a1 6c 7f 12 c0       	mov    0xc0127f6c,%eax
c0106ce5:	85 c0                	test   %eax,%eax
c0106ce7:	74 1e                	je     c0106d07 <alloc_pages+0x66>
         
         extern struct mm_struct *check_mm_struct;
         //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
         swap_out(check_mm_struct, n, 0);
c0106ce9:	8b 55 08             	mov    0x8(%ebp),%edx
c0106cec:	a1 58 a0 12 c0       	mov    0xc012a058,%eax
c0106cf1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106cf8:	00 
c0106cf9:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106cfd:	89 04 24             	mov    %eax,(%esp)
c0106d00:	e8 ef e0 ff ff       	call   c0104df4 <swap_out>
    }
c0106d05:	eb a7                	jmp    c0106cae <alloc_pages+0xd>
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
c0106d07:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106d0a:	c9                   	leave  
c0106d0b:	c3                   	ret    

c0106d0c <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0106d0c:	55                   	push   %ebp
c0106d0d:	89 e5                	mov    %esp,%ebp
c0106d0f:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0106d12:	e8 ca fd ff ff       	call   c0106ae1 <__intr_save>
c0106d17:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0106d1a:	a1 50 a1 12 c0       	mov    0xc012a150,%eax
c0106d1f:	8b 40 10             	mov    0x10(%eax),%eax
c0106d22:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106d25:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106d29:	8b 55 08             	mov    0x8(%ebp),%edx
c0106d2c:	89 14 24             	mov    %edx,(%esp)
c0106d2f:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0106d31:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106d34:	89 04 24             	mov    %eax,(%esp)
c0106d37:	e8 cf fd ff ff       	call   c0106b0b <__intr_restore>
}
c0106d3c:	c9                   	leave  
c0106d3d:	c3                   	ret    

c0106d3e <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0106d3e:	55                   	push   %ebp
c0106d3f:	89 e5                	mov    %esp,%ebp
c0106d41:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0106d44:	e8 98 fd ff ff       	call   c0106ae1 <__intr_save>
c0106d49:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0106d4c:	a1 50 a1 12 c0       	mov    0xc012a150,%eax
c0106d51:	8b 40 14             	mov    0x14(%eax),%eax
c0106d54:	ff d0                	call   *%eax
c0106d56:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0106d59:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106d5c:	89 04 24             	mov    %eax,(%esp)
c0106d5f:	e8 a7 fd ff ff       	call   c0106b0b <__intr_restore>
    return ret;
c0106d64:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0106d67:	c9                   	leave  
c0106d68:	c3                   	ret    

c0106d69 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0106d69:	55                   	push   %ebp
c0106d6a:	89 e5                	mov    %esp,%ebp
c0106d6c:	57                   	push   %edi
c0106d6d:	56                   	push   %esi
c0106d6e:	53                   	push   %ebx
c0106d6f:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0106d75:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0106d7c:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0106d83:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0106d8a:	c7 04 24 cf b6 10 c0 	movl   $0xc010b6cf,(%esp)
c0106d91:	e8 13 95 ff ff       	call   c01002a9 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0106d96:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0106d9d:	e9 15 01 00 00       	jmp    c0106eb7 <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0106da2:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106da5:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106da8:	89 d0                	mov    %edx,%eax
c0106daa:	c1 e0 02             	shl    $0x2,%eax
c0106dad:	01 d0                	add    %edx,%eax
c0106daf:	c1 e0 02             	shl    $0x2,%eax
c0106db2:	01 c8                	add    %ecx,%eax
c0106db4:	8b 50 08             	mov    0x8(%eax),%edx
c0106db7:	8b 40 04             	mov    0x4(%eax),%eax
c0106dba:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0106dbd:	89 55 bc             	mov    %edx,-0x44(%ebp)
c0106dc0:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106dc3:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106dc6:	89 d0                	mov    %edx,%eax
c0106dc8:	c1 e0 02             	shl    $0x2,%eax
c0106dcb:	01 d0                	add    %edx,%eax
c0106dcd:	c1 e0 02             	shl    $0x2,%eax
c0106dd0:	01 c8                	add    %ecx,%eax
c0106dd2:	8b 48 0c             	mov    0xc(%eax),%ecx
c0106dd5:	8b 58 10             	mov    0x10(%eax),%ebx
c0106dd8:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0106ddb:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0106dde:	01 c8                	add    %ecx,%eax
c0106de0:	11 da                	adc    %ebx,%edx
c0106de2:	89 45 b0             	mov    %eax,-0x50(%ebp)
c0106de5:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0106de8:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106deb:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106dee:	89 d0                	mov    %edx,%eax
c0106df0:	c1 e0 02             	shl    $0x2,%eax
c0106df3:	01 d0                	add    %edx,%eax
c0106df5:	c1 e0 02             	shl    $0x2,%eax
c0106df8:	01 c8                	add    %ecx,%eax
c0106dfa:	83 c0 14             	add    $0x14,%eax
c0106dfd:	8b 00                	mov    (%eax),%eax
c0106dff:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c0106e05:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0106e08:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0106e0b:	83 c0 ff             	add    $0xffffffff,%eax
c0106e0e:	83 d2 ff             	adc    $0xffffffff,%edx
c0106e11:	89 c6                	mov    %eax,%esi
c0106e13:	89 d7                	mov    %edx,%edi
c0106e15:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106e18:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106e1b:	89 d0                	mov    %edx,%eax
c0106e1d:	c1 e0 02             	shl    $0x2,%eax
c0106e20:	01 d0                	add    %edx,%eax
c0106e22:	c1 e0 02             	shl    $0x2,%eax
c0106e25:	01 c8                	add    %ecx,%eax
c0106e27:	8b 48 0c             	mov    0xc(%eax),%ecx
c0106e2a:	8b 58 10             	mov    0x10(%eax),%ebx
c0106e2d:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0106e33:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c0106e37:	89 74 24 14          	mov    %esi,0x14(%esp)
c0106e3b:	89 7c 24 18          	mov    %edi,0x18(%esp)
c0106e3f:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0106e42:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0106e45:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106e49:	89 54 24 10          	mov    %edx,0x10(%esp)
c0106e4d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0106e51:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0106e55:	c7 04 24 dc b6 10 c0 	movl   $0xc010b6dc,(%esp)
c0106e5c:	e8 48 94 ff ff       	call   c01002a9 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0106e61:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106e64:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106e67:	89 d0                	mov    %edx,%eax
c0106e69:	c1 e0 02             	shl    $0x2,%eax
c0106e6c:	01 d0                	add    %edx,%eax
c0106e6e:	c1 e0 02             	shl    $0x2,%eax
c0106e71:	01 c8                	add    %ecx,%eax
c0106e73:	83 c0 14             	add    $0x14,%eax
c0106e76:	8b 00                	mov    (%eax),%eax
c0106e78:	83 f8 01             	cmp    $0x1,%eax
c0106e7b:	75 36                	jne    c0106eb3 <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
c0106e7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106e80:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106e83:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0106e86:	77 2b                	ja     c0106eb3 <page_init+0x14a>
c0106e88:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0106e8b:	72 05                	jb     c0106e92 <page_init+0x129>
c0106e8d:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c0106e90:	73 21                	jae    c0106eb3 <page_init+0x14a>
c0106e92:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0106e96:	77 1b                	ja     c0106eb3 <page_init+0x14a>
c0106e98:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0106e9c:	72 09                	jb     c0106ea7 <page_init+0x13e>
c0106e9e:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c0106ea5:	77 0c                	ja     c0106eb3 <page_init+0x14a>
                maxpa = end;
c0106ea7:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0106eaa:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0106ead:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106eb0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
c0106eb3:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0106eb7:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0106eba:	8b 00                	mov    (%eax),%eax
c0106ebc:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0106ebf:	0f 8f dd fe ff ff    	jg     c0106da2 <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0106ec5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106ec9:	72 1d                	jb     c0106ee8 <page_init+0x17f>
c0106ecb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106ecf:	77 09                	ja     c0106eda <page_init+0x171>
c0106ed1:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0106ed8:	76 0e                	jbe    c0106ee8 <page_init+0x17f>
        maxpa = KMEMSIZE;
c0106eda:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0106ee1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0106ee8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106eeb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106eee:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0106ef2:	c1 ea 0c             	shr    $0xc,%edx
c0106ef5:	a3 80 7f 12 c0       	mov    %eax,0xc0127f80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0106efa:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c0106f01:	b8 64 a1 12 c0       	mov    $0xc012a164,%eax
c0106f06:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106f09:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0106f0c:	01 d0                	add    %edx,%eax
c0106f0e:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0106f11:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0106f14:	ba 00 00 00 00       	mov    $0x0,%edx
c0106f19:	f7 75 ac             	divl   -0x54(%ebp)
c0106f1c:	89 d0                	mov    %edx,%eax
c0106f1e:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0106f21:	29 c2                	sub    %eax,%edx
c0106f23:	89 d0                	mov    %edx,%eax
c0106f25:	a3 58 a1 12 c0       	mov    %eax,0xc012a158

    for (i = 0; i < npage; i ++) {
c0106f2a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0106f31:	eb 27                	jmp    c0106f5a <page_init+0x1f1>
        SetPageReserved(pages + i);
c0106f33:	a1 58 a1 12 c0       	mov    0xc012a158,%eax
c0106f38:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106f3b:	c1 e2 05             	shl    $0x5,%edx
c0106f3e:	01 d0                	add    %edx,%eax
c0106f40:	83 c0 04             	add    $0x4,%eax
c0106f43:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c0106f4a:	89 45 8c             	mov    %eax,-0x74(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0106f4d:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0106f50:	8b 55 90             	mov    -0x70(%ebp),%edx
c0106f53:	0f ab 10             	bts    %edx,(%eax)
    for (i = 0; i < npage; i ++) {
c0106f56:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0106f5a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106f5d:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c0106f62:	39 c2                	cmp    %eax,%edx
c0106f64:	72 cd                	jb     c0106f33 <page_init+0x1ca>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0106f66:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c0106f6b:	c1 e0 05             	shl    $0x5,%eax
c0106f6e:	89 c2                	mov    %eax,%edx
c0106f70:	a1 58 a1 12 c0       	mov    0xc012a158,%eax
c0106f75:	01 d0                	add    %edx,%eax
c0106f77:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c0106f7a:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c0106f81:	77 23                	ja     c0106fa6 <page_init+0x23d>
c0106f83:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106f86:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106f8a:	c7 44 24 08 0c b7 10 	movl   $0xc010b70c,0x8(%esp)
c0106f91:	c0 
c0106f92:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
c0106f99:	00 
c0106f9a:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c0106fa1:	e8 5a 94 ff ff       	call   c0100400 <__panic>
c0106fa6:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106fa9:	05 00 00 00 40       	add    $0x40000000,%eax
c0106fae:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0106fb1:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0106fb8:	e9 74 01 00 00       	jmp    c0107131 <page_init+0x3c8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0106fbd:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106fc0:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106fc3:	89 d0                	mov    %edx,%eax
c0106fc5:	c1 e0 02             	shl    $0x2,%eax
c0106fc8:	01 d0                	add    %edx,%eax
c0106fca:	c1 e0 02             	shl    $0x2,%eax
c0106fcd:	01 c8                	add    %ecx,%eax
c0106fcf:	8b 50 08             	mov    0x8(%eax),%edx
c0106fd2:	8b 40 04             	mov    0x4(%eax),%eax
c0106fd5:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0106fd8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0106fdb:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106fde:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106fe1:	89 d0                	mov    %edx,%eax
c0106fe3:	c1 e0 02             	shl    $0x2,%eax
c0106fe6:	01 d0                	add    %edx,%eax
c0106fe8:	c1 e0 02             	shl    $0x2,%eax
c0106feb:	01 c8                	add    %ecx,%eax
c0106fed:	8b 48 0c             	mov    0xc(%eax),%ecx
c0106ff0:	8b 58 10             	mov    0x10(%eax),%ebx
c0106ff3:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106ff6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106ff9:	01 c8                	add    %ecx,%eax
c0106ffb:	11 da                	adc    %ebx,%edx
c0106ffd:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0107000:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0107003:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0107006:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107009:	89 d0                	mov    %edx,%eax
c010700b:	c1 e0 02             	shl    $0x2,%eax
c010700e:	01 d0                	add    %edx,%eax
c0107010:	c1 e0 02             	shl    $0x2,%eax
c0107013:	01 c8                	add    %ecx,%eax
c0107015:	83 c0 14             	add    $0x14,%eax
c0107018:	8b 00                	mov    (%eax),%eax
c010701a:	83 f8 01             	cmp    $0x1,%eax
c010701d:	0f 85 0a 01 00 00    	jne    c010712d <page_init+0x3c4>
            if (begin < freemem) {
c0107023:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0107026:	ba 00 00 00 00       	mov    $0x0,%edx
c010702b:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010702e:	72 17                	jb     c0107047 <page_init+0x2de>
c0107030:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0107033:	77 05                	ja     c010703a <page_init+0x2d1>
c0107035:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0107038:	76 0d                	jbe    c0107047 <page_init+0x2de>
                begin = freemem;
c010703a:	8b 45 a0             	mov    -0x60(%ebp),%eax
c010703d:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0107040:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0107047:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c010704b:	72 1d                	jb     c010706a <page_init+0x301>
c010704d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0107051:	77 09                	ja     c010705c <page_init+0x2f3>
c0107053:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c010705a:	76 0e                	jbe    c010706a <page_init+0x301>
                end = KMEMSIZE;
c010705c:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0107063:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c010706a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010706d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107070:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0107073:	0f 87 b4 00 00 00    	ja     c010712d <page_init+0x3c4>
c0107079:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c010707c:	72 09                	jb     c0107087 <page_init+0x31e>
c010707e:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0107081:	0f 83 a6 00 00 00    	jae    c010712d <page_init+0x3c4>
                begin = ROUNDUP(begin, PGSIZE);
c0107087:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c010708e:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0107091:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0107094:	01 d0                	add    %edx,%eax
c0107096:	83 e8 01             	sub    $0x1,%eax
c0107099:	89 45 98             	mov    %eax,-0x68(%ebp)
c010709c:	8b 45 98             	mov    -0x68(%ebp),%eax
c010709f:	ba 00 00 00 00       	mov    $0x0,%edx
c01070a4:	f7 75 9c             	divl   -0x64(%ebp)
c01070a7:	89 d0                	mov    %edx,%eax
c01070a9:	8b 55 98             	mov    -0x68(%ebp),%edx
c01070ac:	29 c2                	sub    %eax,%edx
c01070ae:	89 d0                	mov    %edx,%eax
c01070b0:	ba 00 00 00 00       	mov    $0x0,%edx
c01070b5:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01070b8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c01070bb:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01070be:	89 45 94             	mov    %eax,-0x6c(%ebp)
c01070c1:	8b 45 94             	mov    -0x6c(%ebp),%eax
c01070c4:	ba 00 00 00 00       	mov    $0x0,%edx
c01070c9:	89 c7                	mov    %eax,%edi
c01070cb:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c01070d1:	89 7d 80             	mov    %edi,-0x80(%ebp)
c01070d4:	89 d0                	mov    %edx,%eax
c01070d6:	83 e0 00             	and    $0x0,%eax
c01070d9:	89 45 84             	mov    %eax,-0x7c(%ebp)
c01070dc:	8b 45 80             	mov    -0x80(%ebp),%eax
c01070df:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01070e2:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01070e5:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c01070e8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01070eb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01070ee:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01070f1:	77 3a                	ja     c010712d <page_init+0x3c4>
c01070f3:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01070f6:	72 05                	jb     c01070fd <page_init+0x394>
c01070f8:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c01070fb:	73 30                	jae    c010712d <page_init+0x3c4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c01070fd:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c0107100:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
c0107103:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0107106:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0107109:	29 c8                	sub    %ecx,%eax
c010710b:	19 da                	sbb    %ebx,%edx
c010710d:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0107111:	c1 ea 0c             	shr    $0xc,%edx
c0107114:	89 c3                	mov    %eax,%ebx
c0107116:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107119:	89 04 24             	mov    %eax,(%esp)
c010711c:	e8 8c f8 ff ff       	call   c01069ad <pa2page>
c0107121:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0107125:	89 04 24             	mov    %eax,(%esp)
c0107128:	e8 55 fb ff ff       	call   c0106c82 <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
c010712d:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0107131:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0107134:	8b 00                	mov    (%eax),%eax
c0107136:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0107139:	0f 8f 7e fe ff ff    	jg     c0106fbd <page_init+0x254>
                }
            }
        }
    }
}
c010713f:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c0107145:	5b                   	pop    %ebx
c0107146:	5e                   	pop    %esi
c0107147:	5f                   	pop    %edi
c0107148:	5d                   	pop    %ebp
c0107149:	c3                   	ret    

c010714a <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c010714a:	55                   	push   %ebp
c010714b:	89 e5                	mov    %esp,%ebp
c010714d:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0107150:	8b 45 14             	mov    0x14(%ebp),%eax
c0107153:	8b 55 0c             	mov    0xc(%ebp),%edx
c0107156:	31 d0                	xor    %edx,%eax
c0107158:	25 ff 0f 00 00       	and    $0xfff,%eax
c010715d:	85 c0                	test   %eax,%eax
c010715f:	74 24                	je     c0107185 <boot_map_segment+0x3b>
c0107161:	c7 44 24 0c 3e b7 10 	movl   $0xc010b73e,0xc(%esp)
c0107168:	c0 
c0107169:	c7 44 24 08 55 b7 10 	movl   $0xc010b755,0x8(%esp)
c0107170:	c0 
c0107171:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
c0107178:	00 
c0107179:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c0107180:	e8 7b 92 ff ff       	call   c0100400 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0107185:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c010718c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010718f:	25 ff 0f 00 00       	and    $0xfff,%eax
c0107194:	89 c2                	mov    %eax,%edx
c0107196:	8b 45 10             	mov    0x10(%ebp),%eax
c0107199:	01 c2                	add    %eax,%edx
c010719b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010719e:	01 d0                	add    %edx,%eax
c01071a0:	83 e8 01             	sub    $0x1,%eax
c01071a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01071a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01071a9:	ba 00 00 00 00       	mov    $0x0,%edx
c01071ae:	f7 75 f0             	divl   -0x10(%ebp)
c01071b1:	89 d0                	mov    %edx,%eax
c01071b3:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01071b6:	29 c2                	sub    %eax,%edx
c01071b8:	89 d0                	mov    %edx,%eax
c01071ba:	c1 e8 0c             	shr    $0xc,%eax
c01071bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c01071c0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01071c3:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01071c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01071c9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01071ce:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c01071d1:	8b 45 14             	mov    0x14(%ebp),%eax
c01071d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01071d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01071da:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01071df:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01071e2:	eb 6b                	jmp    c010724f <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
c01071e4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01071eb:	00 
c01071ec:	8b 45 0c             	mov    0xc(%ebp),%eax
c01071ef:	89 44 24 04          	mov    %eax,0x4(%esp)
c01071f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01071f6:	89 04 24             	mov    %eax,(%esp)
c01071f9:	e8 87 01 00 00       	call   c0107385 <get_pte>
c01071fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0107201:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0107205:	75 24                	jne    c010722b <boot_map_segment+0xe1>
c0107207:	c7 44 24 0c 6a b7 10 	movl   $0xc010b76a,0xc(%esp)
c010720e:	c0 
c010720f:	c7 44 24 08 55 b7 10 	movl   $0xc010b755,0x8(%esp)
c0107216:	c0 
c0107217:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
c010721e:	00 
c010721f:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c0107226:	e8 d5 91 ff ff       	call   c0100400 <__panic>
        *ptep = pa | PTE_P | perm;
c010722b:	8b 45 18             	mov    0x18(%ebp),%eax
c010722e:	8b 55 14             	mov    0x14(%ebp),%edx
c0107231:	09 d0                	or     %edx,%eax
c0107233:	83 c8 01             	or     $0x1,%eax
c0107236:	89 c2                	mov    %eax,%edx
c0107238:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010723b:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c010723d:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0107241:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c0107248:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c010724f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107253:	75 8f                	jne    c01071e4 <boot_map_segment+0x9a>
    }
}
c0107255:	c9                   	leave  
c0107256:	c3                   	ret    

c0107257 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c0107257:	55                   	push   %ebp
c0107258:	89 e5                	mov    %esp,%ebp
c010725a:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c010725d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107264:	e8 38 fa ff ff       	call   c0106ca1 <alloc_pages>
c0107269:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c010726c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107270:	75 1c                	jne    c010728e <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c0107272:	c7 44 24 08 77 b7 10 	movl   $0xc010b777,0x8(%esp)
c0107279:	c0 
c010727a:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c0107281:	00 
c0107282:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c0107289:	e8 72 91 ff ff       	call   c0100400 <__panic>
    }
    return page2kva(p);
c010728e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107291:	89 04 24             	mov    %eax,(%esp)
c0107294:	e8 59 f7 ff ff       	call   c01069f2 <page2kva>
}
c0107299:	c9                   	leave  
c010729a:	c3                   	ret    

c010729b <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c010729b:	55                   	push   %ebp
c010729c:	89 e5                	mov    %esp,%ebp
c010729e:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c01072a1:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c01072a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01072a9:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01072b0:	77 23                	ja     c01072d5 <pmm_init+0x3a>
c01072b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01072b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01072b9:	c7 44 24 08 0c b7 10 	movl   $0xc010b70c,0x8(%esp)
c01072c0:	c0 
c01072c1:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
c01072c8:	00 
c01072c9:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c01072d0:	e8 2b 91 ff ff       	call   c0100400 <__panic>
c01072d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01072d8:	05 00 00 00 40       	add    $0x40000000,%eax
c01072dd:	a3 54 a1 12 c0       	mov    %eax,0xc012a154
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c01072e2:	e8 68 f9 ff ff       	call   c0106c4f <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c01072e7:	e8 7d fa ff ff       	call   c0106d69 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c01072ec:	e8 b1 04 00 00       	call   c01077a2 <check_alloc_page>

    check_pgdir();
c01072f1:	e8 ca 04 00 00       	call   c01077c0 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c01072f6:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c01072fb:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c0107301:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107306:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107309:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0107310:	77 23                	ja     c0107335 <pmm_init+0x9a>
c0107312:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107315:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107319:	c7 44 24 08 0c b7 10 	movl   $0xc010b70c,0x8(%esp)
c0107320:	c0 
c0107321:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
c0107328:	00 
c0107329:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c0107330:	e8 cb 90 ff ff       	call   c0100400 <__panic>
c0107335:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107338:	05 00 00 00 40       	add    $0x40000000,%eax
c010733d:	83 c8 03             	or     $0x3,%eax
c0107340:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0107342:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107347:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c010734e:	00 
c010734f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0107356:	00 
c0107357:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c010735e:	38 
c010735f:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c0107366:	c0 
c0107367:	89 04 24             	mov    %eax,(%esp)
c010736a:	e8 db fd ff ff       	call   c010714a <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c010736f:	e8 ec f7 ff ff       	call   c0106b60 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0107374:	e8 e2 0a 00 00       	call   c0107e5b <check_boot_pgdir>

    print_pgdir();
c0107379:	e8 6a 0f 00 00       	call   c01082e8 <print_pgdir>
    
    kmalloc_init();
c010737e:	e8 4b d6 ff ff       	call   c01049ce <kmalloc_init>

}
c0107383:	c9                   	leave  
c0107384:	c3                   	ret    

c0107385 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c0107385:	55                   	push   %ebp
c0107386:	89 e5                	mov    %esp,%ebp
c0107388:	83 ec 38             	sub    $0x38,%esp
     pde_t *pdep = &pgdir[PDX(la)];
c010738b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010738e:	c1 e8 16             	shr    $0x16,%eax
c0107391:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0107398:	8b 45 08             	mov    0x8(%ebp),%eax
c010739b:	01 d0                	add    %edx,%eax
c010739d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    //获取一级页表项对应的入口地址
    if (!(*pdep & PTE_P)) {
c01073a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01073a3:	8b 00                	mov    (%eax),%eax
c01073a5:	83 e0 01             	and    $0x1,%eax
c01073a8:	85 c0                	test   %eax,%eax
c01073aa:	0f 85 af 00 00 00    	jne    c010745f <get_pte+0xda>
        //物理页不存在, create==0, null
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {//分配失败
c01073b0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01073b4:	74 15                	je     c01073cb <get_pte+0x46>
c01073b6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01073bd:	e8 df f8 ff ff       	call   c0106ca1 <alloc_pages>
c01073c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01073c5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01073c9:	75 0a                	jne    c01073d5 <get_pte+0x50>
            return NULL;
c01073cb:	b8 00 00 00 00       	mov    $0x0,%eax
c01073d0:	e9 e6 00 00 00       	jmp    c01074bb <get_pte+0x136>
        }
        //引用次数+1
        set_page_ref(page, 1);
c01073d5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01073dc:	00 
c01073dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01073e0:	89 04 24             	mov    %eax,(%esp)
c01073e3:	e8 be f6 ff ff       	call   c0106aa6 <set_page_ref>
        //物理地址
        uintptr_t pa = page2pa(page);
c01073e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01073eb:	89 04 24             	mov    %eax,(%esp)
c01073ee:	e8 a4 f5 ff ff       	call   c0106997 <page2pa>
c01073f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
        ///物理地址转虚拟地址，并初始化,把新申请的数目为pgsize个页全设为0	
        memset(KADDR(pa), 0, PGSIZE);
c01073f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01073f9:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01073fc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01073ff:	c1 e8 0c             	shr    $0xc,%eax
c0107402:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107405:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c010740a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c010740d:	72 23                	jb     c0107432 <get_pte+0xad>
c010740f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107412:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107416:	c7 44 24 08 68 b6 10 	movl   $0xc010b668,0x8(%esp)
c010741d:	c0 
c010741e:	c7 44 24 04 66 01 00 	movl   $0x166,0x4(%esp)
c0107425:	00 
c0107426:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c010742d:	e8 ce 8f ff ff       	call   c0100400 <__panic>
c0107432:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107435:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010743a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0107441:	00 
c0107442:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0107449:	00 
c010744a:	89 04 24             	mov    %eax,(%esp)
c010744d:	e8 06 21 00 00       	call   c0109558 <memset>
        //设置控制位
        *pdep = pa | PTE_U | PTE_W | PTE_P;
c0107452:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107455:	83 c8 07             	or     $0x7,%eax
c0107458:	89 c2                	mov    %eax,%edx
c010745a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010745d:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c010745f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107462:	8b 00                	mov    (%eax),%eax
c0107464:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107469:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010746c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010746f:	c1 e8 0c             	shr    $0xc,%eax
c0107472:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0107475:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c010747a:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c010747d:	72 23                	jb     c01074a2 <get_pte+0x11d>
c010747f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107482:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107486:	c7 44 24 08 68 b6 10 	movl   $0xc010b668,0x8(%esp)
c010748d:	c0 
c010748e:	c7 44 24 04 6a 01 00 	movl   $0x16a,0x4(%esp)
c0107495:	00 
c0107496:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c010749d:	e8 5e 8f ff ff       	call   c0100400 <__panic>
c01074a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01074a5:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01074aa:	8b 55 0c             	mov    0xc(%ebp),%edx
c01074ad:	c1 ea 0c             	shr    $0xc,%edx
c01074b0:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
c01074b6:	c1 e2 02             	shl    $0x2,%edx
c01074b9:	01 d0                	add    %edx,%eax
    //页目录项地址-->>页表物理地址-->>虚拟地址-->>页表项索引
    //PTX(la)：返回虚拟地址la的页表项索引
    //返回la对应的页表项入口地址
}
c01074bb:	c9                   	leave  
c01074bc:	c3                   	ret    

c01074bd <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c01074bd:	55                   	push   %ebp
c01074be:	89 e5                	mov    %esp,%ebp
c01074c0:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01074c3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01074ca:	00 
c01074cb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01074ce:	89 44 24 04          	mov    %eax,0x4(%esp)
c01074d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01074d5:	89 04 24             	mov    %eax,(%esp)
c01074d8:	e8 a8 fe ff ff       	call   c0107385 <get_pte>
c01074dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c01074e0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01074e4:	74 08                	je     c01074ee <get_page+0x31>
        *ptep_store = ptep;
c01074e6:	8b 45 10             	mov    0x10(%ebp),%eax
c01074e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01074ec:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c01074ee:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01074f2:	74 1b                	je     c010750f <get_page+0x52>
c01074f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01074f7:	8b 00                	mov    (%eax),%eax
c01074f9:	83 e0 01             	and    $0x1,%eax
c01074fc:	85 c0                	test   %eax,%eax
c01074fe:	74 0f                	je     c010750f <get_page+0x52>
        return pte2page(*ptep);
c0107500:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107503:	8b 00                	mov    (%eax),%eax
c0107505:	89 04 24             	mov    %eax,(%esp)
c0107508:	e8 39 f5 ff ff       	call   c0106a46 <pte2page>
c010750d:	eb 05                	jmp    c0107514 <get_page+0x57>
    }
    return NULL;
c010750f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107514:	c9                   	leave  
c0107515:	c3                   	ret    

c0107516 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0107516:	55                   	push   %ebp
c0107517:	89 e5                	mov    %esp,%ebp
c0107519:	83 ec 28             	sub    $0x28,%esp
    if (*ptep & PTE_P) {
c010751c:	8b 45 10             	mov    0x10(%ebp),%eax
c010751f:	8b 00                	mov    (%eax),%eax
c0107521:	83 e0 01             	and    $0x1,%eax
c0107524:	85 c0                	test   %eax,%eax
c0107526:	74 53                	je     c010757b <page_remove_pte+0x65>
        //判断页表中该表项是否存在
        struct Page *page = pte2page(*ptep);//获得相应的page
c0107528:	8b 45 10             	mov    0x10(%ebp),%eax
c010752b:	8b 00                	mov    (%eax),%eax
c010752d:	89 04 24             	mov    %eax,(%esp)
c0107530:	e8 11 f5 ff ff       	call   c0106a46 <pte2page>
c0107535:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
c0107538:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010753b:	89 04 24             	mov    %eax,(%esp)
c010753e:	e8 87 f5 ff ff       	call   c0106aca <page_ref_dec>
c0107543:	85 c0                	test   %eax,%eax
c0107545:	75 13                	jne    c010755a <page_remove_pte+0x44>
            ////除了当前进程，没有别的进程引用
            free_page(page);
c0107547:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010754e:	00 
c010754f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107552:	89 04 24             	mov    %eax,(%esp)
c0107555:	e8 b2 f7 ff ff       	call   c0106d0c <free_pages>
        }
        *ptep &= (~PTE_P); 
c010755a:	8b 45 10             	mov    0x10(%ebp),%eax
c010755d:	8b 00                	mov    (%eax),%eax
c010755f:	83 e0 fe             	and    $0xfffffffe,%eax
c0107562:	89 c2                	mov    %eax,%edx
c0107564:	8b 45 10             	mov    0x10(%ebp),%eax
c0107567:	89 10                	mov    %edx,(%eax)
        // 将PTE的存在位设置为0，表示该映射关系无效
        tlb_invalidate(pgdir, la);
c0107569:	8b 45 0c             	mov    0xc(%ebp),%eax
c010756c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107570:	8b 45 08             	mov    0x8(%ebp),%eax
c0107573:	89 04 24             	mov    %eax,(%esp)
c0107576:	e8 ff 00 00 00       	call   c010767a <tlb_invalidate>
         //刷新TLB
    }
}
c010757b:	c9                   	leave  
c010757c:	c3                   	ret    

c010757d <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c010757d:	55                   	push   %ebp
c010757e:	89 e5                	mov    %esp,%ebp
c0107580:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0107583:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010758a:	00 
c010758b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010758e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107592:	8b 45 08             	mov    0x8(%ebp),%eax
c0107595:	89 04 24             	mov    %eax,(%esp)
c0107598:	e8 e8 fd ff ff       	call   c0107385 <get_pte>
c010759d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c01075a0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01075a4:	74 19                	je     c01075bf <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c01075a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01075a9:	89 44 24 08          	mov    %eax,0x8(%esp)
c01075ad:	8b 45 0c             	mov    0xc(%ebp),%eax
c01075b0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01075b4:	8b 45 08             	mov    0x8(%ebp),%eax
c01075b7:	89 04 24             	mov    %eax,(%esp)
c01075ba:	e8 57 ff ff ff       	call   c0107516 <page_remove_pte>
    }
}
c01075bf:	c9                   	leave  
c01075c0:	c3                   	ret    

c01075c1 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c01075c1:	55                   	push   %ebp
c01075c2:	89 e5                	mov    %esp,%ebp
c01075c4:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c01075c7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01075ce:	00 
c01075cf:	8b 45 10             	mov    0x10(%ebp),%eax
c01075d2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01075d6:	8b 45 08             	mov    0x8(%ebp),%eax
c01075d9:	89 04 24             	mov    %eax,(%esp)
c01075dc:	e8 a4 fd ff ff       	call   c0107385 <get_pte>
c01075e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c01075e4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01075e8:	75 0a                	jne    c01075f4 <page_insert+0x33>
        return -E_NO_MEM;
c01075ea:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c01075ef:	e9 84 00 00 00       	jmp    c0107678 <page_insert+0xb7>
    }
    page_ref_inc(page);
c01075f4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01075f7:	89 04 24             	mov    %eax,(%esp)
c01075fa:	e8 b4 f4 ff ff       	call   c0106ab3 <page_ref_inc>
    if (*ptep & PTE_P) {
c01075ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107602:	8b 00                	mov    (%eax),%eax
c0107604:	83 e0 01             	and    $0x1,%eax
c0107607:	85 c0                	test   %eax,%eax
c0107609:	74 3e                	je     c0107649 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c010760b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010760e:	8b 00                	mov    (%eax),%eax
c0107610:	89 04 24             	mov    %eax,(%esp)
c0107613:	e8 2e f4 ff ff       	call   c0106a46 <pte2page>
c0107618:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c010761b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010761e:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107621:	75 0d                	jne    c0107630 <page_insert+0x6f>
            page_ref_dec(page);
c0107623:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107626:	89 04 24             	mov    %eax,(%esp)
c0107629:	e8 9c f4 ff ff       	call   c0106aca <page_ref_dec>
c010762e:	eb 19                	jmp    c0107649 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0107630:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107633:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107637:	8b 45 10             	mov    0x10(%ebp),%eax
c010763a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010763e:	8b 45 08             	mov    0x8(%ebp),%eax
c0107641:	89 04 24             	mov    %eax,(%esp)
c0107644:	e8 cd fe ff ff       	call   c0107516 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0107649:	8b 45 0c             	mov    0xc(%ebp),%eax
c010764c:	89 04 24             	mov    %eax,(%esp)
c010764f:	e8 43 f3 ff ff       	call   c0106997 <page2pa>
c0107654:	0b 45 14             	or     0x14(%ebp),%eax
c0107657:	83 c8 01             	or     $0x1,%eax
c010765a:	89 c2                	mov    %eax,%edx
c010765c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010765f:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c0107661:	8b 45 10             	mov    0x10(%ebp),%eax
c0107664:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107668:	8b 45 08             	mov    0x8(%ebp),%eax
c010766b:	89 04 24             	mov    %eax,(%esp)
c010766e:	e8 07 00 00 00       	call   c010767a <tlb_invalidate>
    return 0;
c0107673:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107678:	c9                   	leave  
c0107679:	c3                   	ret    

c010767a <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c010767a:	55                   	push   %ebp
c010767b:	89 e5                	mov    %esp,%ebp
c010767d:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0107680:	0f 20 d8             	mov    %cr3,%eax
c0107683:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c0107686:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
c0107689:	89 c2                	mov    %eax,%edx
c010768b:	8b 45 08             	mov    0x8(%ebp),%eax
c010768e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107691:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0107698:	77 23                	ja     c01076bd <tlb_invalidate+0x43>
c010769a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010769d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01076a1:	c7 44 24 08 0c b7 10 	movl   $0xc010b70c,0x8(%esp)
c01076a8:	c0 
c01076a9:	c7 44 24 04 ba 01 00 	movl   $0x1ba,0x4(%esp)
c01076b0:	00 
c01076b1:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c01076b8:	e8 43 8d ff ff       	call   c0100400 <__panic>
c01076bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01076c0:	05 00 00 00 40       	add    $0x40000000,%eax
c01076c5:	39 c2                	cmp    %eax,%edx
c01076c7:	75 0c                	jne    c01076d5 <tlb_invalidate+0x5b>
        invlpg((void *)la);
c01076c9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01076cc:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c01076cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01076d2:	0f 01 38             	invlpg (%eax)
    }
}
c01076d5:	c9                   	leave  
c01076d6:	c3                   	ret    

c01076d7 <pgdir_alloc_page>:

// pgdir_alloc_page - call alloc_page & page_insert functions to 
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *
pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
c01076d7:	55                   	push   %ebp
c01076d8:	89 e5                	mov    %esp,%ebp
c01076da:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_page();
c01076dd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01076e4:	e8 b8 f5 ff ff       	call   c0106ca1 <alloc_pages>
c01076e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c01076ec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01076f0:	0f 84 a7 00 00 00    	je     c010779d <pgdir_alloc_page+0xc6>
        if (page_insert(pgdir, page, la, perm) != 0) {
c01076f6:	8b 45 10             	mov    0x10(%ebp),%eax
c01076f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01076fd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107700:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107704:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107707:	89 44 24 04          	mov    %eax,0x4(%esp)
c010770b:	8b 45 08             	mov    0x8(%ebp),%eax
c010770e:	89 04 24             	mov    %eax,(%esp)
c0107711:	e8 ab fe ff ff       	call   c01075c1 <page_insert>
c0107716:	85 c0                	test   %eax,%eax
c0107718:	74 1a                	je     c0107734 <pgdir_alloc_page+0x5d>
            free_page(page);
c010771a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107721:	00 
c0107722:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107725:	89 04 24             	mov    %eax,(%esp)
c0107728:	e8 df f5 ff ff       	call   c0106d0c <free_pages>
            return NULL;
c010772d:	b8 00 00 00 00       	mov    $0x0,%eax
c0107732:	eb 6c                	jmp    c01077a0 <pgdir_alloc_page+0xc9>
        }
        if (swap_init_ok){
c0107734:	a1 6c 7f 12 c0       	mov    0xc0127f6c,%eax
c0107739:	85 c0                	test   %eax,%eax
c010773b:	74 60                	je     c010779d <pgdir_alloc_page+0xc6>
            swap_map_swappable(check_mm_struct, la, page, 0);
c010773d:	a1 58 a0 12 c0       	mov    0xc012a058,%eax
c0107742:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0107749:	00 
c010774a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010774d:	89 54 24 08          	mov    %edx,0x8(%esp)
c0107751:	8b 55 0c             	mov    0xc(%ebp),%edx
c0107754:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107758:	89 04 24             	mov    %eax,(%esp)
c010775b:	e8 48 d6 ff ff       	call   c0104da8 <swap_map_swappable>
            page->pra_vaddr=la;
c0107760:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107763:	8b 55 0c             	mov    0xc(%ebp),%edx
c0107766:	89 50 1c             	mov    %edx,0x1c(%eax)
            assert(page_ref(page) == 1);
c0107769:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010776c:	89 04 24             	mov    %eax,(%esp)
c010776f:	e8 28 f3 ff ff       	call   c0106a9c <page_ref>
c0107774:	83 f8 01             	cmp    $0x1,%eax
c0107777:	74 24                	je     c010779d <pgdir_alloc_page+0xc6>
c0107779:	c7 44 24 0c 90 b7 10 	movl   $0xc010b790,0xc(%esp)
c0107780:	c0 
c0107781:	c7 44 24 08 55 b7 10 	movl   $0xc010b755,0x8(%esp)
c0107788:	c0 
c0107789:	c7 44 24 04 cd 01 00 	movl   $0x1cd,0x4(%esp)
c0107790:	00 
c0107791:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c0107798:	e8 63 8c ff ff       	call   c0100400 <__panic>
            //cprintf("get No. %d  page: pra_vaddr %x, pra_link.prev %x, pra_link_next %x in pgdir_alloc_page\n", (page-pages), page->pra_vaddr,page->pra_page_link.prev, page->pra_page_link.next);
        }

    }

    return page;
c010779d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01077a0:	c9                   	leave  
c01077a1:	c3                   	ret    

c01077a2 <check_alloc_page>:

static void
check_alloc_page(void) {
c01077a2:	55                   	push   %ebp
c01077a3:	89 e5                	mov    %esp,%ebp
c01077a5:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c01077a8:	a1 50 a1 12 c0       	mov    0xc012a150,%eax
c01077ad:	8b 40 18             	mov    0x18(%eax),%eax
c01077b0:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c01077b2:	c7 04 24 a4 b7 10 c0 	movl   $0xc010b7a4,(%esp)
c01077b9:	e8 eb 8a ff ff       	call   c01002a9 <cprintf>
}
c01077be:	c9                   	leave  
c01077bf:	c3                   	ret    

c01077c0 <check_pgdir>:

static void
check_pgdir(void) {
c01077c0:	55                   	push   %ebp
c01077c1:	89 e5                	mov    %esp,%ebp
c01077c3:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c01077c6:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c01077cb:	3d 00 80 03 00       	cmp    $0x38000,%eax
c01077d0:	76 24                	jbe    c01077f6 <check_pgdir+0x36>
c01077d2:	c7 44 24 0c c3 b7 10 	movl   $0xc010b7c3,0xc(%esp)
c01077d9:	c0 
c01077da:	c7 44 24 08 55 b7 10 	movl   $0xc010b755,0x8(%esp)
c01077e1:	c0 
c01077e2:	c7 44 24 04 de 01 00 	movl   $0x1de,0x4(%esp)
c01077e9:	00 
c01077ea:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c01077f1:	e8 0a 8c ff ff       	call   c0100400 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c01077f6:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c01077fb:	85 c0                	test   %eax,%eax
c01077fd:	74 0e                	je     c010780d <check_pgdir+0x4d>
c01077ff:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107804:	25 ff 0f 00 00       	and    $0xfff,%eax
c0107809:	85 c0                	test   %eax,%eax
c010780b:	74 24                	je     c0107831 <check_pgdir+0x71>
c010780d:	c7 44 24 0c e0 b7 10 	movl   $0xc010b7e0,0xc(%esp)
c0107814:	c0 
c0107815:	c7 44 24 08 55 b7 10 	movl   $0xc010b755,0x8(%esp)
c010781c:	c0 
c010781d:	c7 44 24 04 df 01 00 	movl   $0x1df,0x4(%esp)
c0107824:	00 
c0107825:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c010782c:	e8 cf 8b ff ff       	call   c0100400 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c0107831:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107836:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010783d:	00 
c010783e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0107845:	00 
c0107846:	89 04 24             	mov    %eax,(%esp)
c0107849:	e8 6f fc ff ff       	call   c01074bd <get_page>
c010784e:	85 c0                	test   %eax,%eax
c0107850:	74 24                	je     c0107876 <check_pgdir+0xb6>
c0107852:	c7 44 24 0c 18 b8 10 	movl   $0xc010b818,0xc(%esp)
c0107859:	c0 
c010785a:	c7 44 24 08 55 b7 10 	movl   $0xc010b755,0x8(%esp)
c0107861:	c0 
c0107862:	c7 44 24 04 e0 01 00 	movl   $0x1e0,0x4(%esp)
c0107869:	00 
c010786a:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c0107871:	e8 8a 8b ff ff       	call   c0100400 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c0107876:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010787d:	e8 1f f4 ff ff       	call   c0106ca1 <alloc_pages>
c0107882:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c0107885:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c010788a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0107891:	00 
c0107892:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107899:	00 
c010789a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010789d:	89 54 24 04          	mov    %edx,0x4(%esp)
c01078a1:	89 04 24             	mov    %eax,(%esp)
c01078a4:	e8 18 fd ff ff       	call   c01075c1 <page_insert>
c01078a9:	85 c0                	test   %eax,%eax
c01078ab:	74 24                	je     c01078d1 <check_pgdir+0x111>
c01078ad:	c7 44 24 0c 40 b8 10 	movl   $0xc010b840,0xc(%esp)
c01078b4:	c0 
c01078b5:	c7 44 24 08 55 b7 10 	movl   $0xc010b755,0x8(%esp)
c01078bc:	c0 
c01078bd:	c7 44 24 04 e4 01 00 	movl   $0x1e4,0x4(%esp)
c01078c4:	00 
c01078c5:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c01078cc:	e8 2f 8b ff ff       	call   c0100400 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c01078d1:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c01078d6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01078dd:	00 
c01078de:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01078e5:	00 
c01078e6:	89 04 24             	mov    %eax,(%esp)
c01078e9:	e8 97 fa ff ff       	call   c0107385 <get_pte>
c01078ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01078f1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01078f5:	75 24                	jne    c010791b <check_pgdir+0x15b>
c01078f7:	c7 44 24 0c 6c b8 10 	movl   $0xc010b86c,0xc(%esp)
c01078fe:	c0 
c01078ff:	c7 44 24 08 55 b7 10 	movl   $0xc010b755,0x8(%esp)
c0107906:	c0 
c0107907:	c7 44 24 04 e7 01 00 	movl   $0x1e7,0x4(%esp)
c010790e:	00 
c010790f:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c0107916:	e8 e5 8a ff ff       	call   c0100400 <__panic>
    assert(pte2page(*ptep) == p1);
c010791b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010791e:	8b 00                	mov    (%eax),%eax
c0107920:	89 04 24             	mov    %eax,(%esp)
c0107923:	e8 1e f1 ff ff       	call   c0106a46 <pte2page>
c0107928:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010792b:	74 24                	je     c0107951 <check_pgdir+0x191>
c010792d:	c7 44 24 0c 99 b8 10 	movl   $0xc010b899,0xc(%esp)
c0107934:	c0 
c0107935:	c7 44 24 08 55 b7 10 	movl   $0xc010b755,0x8(%esp)
c010793c:	c0 
c010793d:	c7 44 24 04 e8 01 00 	movl   $0x1e8,0x4(%esp)
c0107944:	00 
c0107945:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c010794c:	e8 af 8a ff ff       	call   c0100400 <__panic>
    assert(page_ref(p1) == 1);
c0107951:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107954:	89 04 24             	mov    %eax,(%esp)
c0107957:	e8 40 f1 ff ff       	call   c0106a9c <page_ref>
c010795c:	83 f8 01             	cmp    $0x1,%eax
c010795f:	74 24                	je     c0107985 <check_pgdir+0x1c5>
c0107961:	c7 44 24 0c af b8 10 	movl   $0xc010b8af,0xc(%esp)
c0107968:	c0 
c0107969:	c7 44 24 08 55 b7 10 	movl   $0xc010b755,0x8(%esp)
c0107970:	c0 
c0107971:	c7 44 24 04 e9 01 00 	movl   $0x1e9,0x4(%esp)
c0107978:	00 
c0107979:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c0107980:	e8 7b 8a ff ff       	call   c0100400 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c0107985:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c010798a:	8b 00                	mov    (%eax),%eax
c010798c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107991:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107994:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107997:	c1 e8 0c             	shr    $0xc,%eax
c010799a:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010799d:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c01079a2:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01079a5:	72 23                	jb     c01079ca <check_pgdir+0x20a>
c01079a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01079aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01079ae:	c7 44 24 08 68 b6 10 	movl   $0xc010b668,0x8(%esp)
c01079b5:	c0 
c01079b6:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
c01079bd:	00 
c01079be:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c01079c5:	e8 36 8a ff ff       	call   c0100400 <__panic>
c01079ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01079cd:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01079d2:	83 c0 04             	add    $0x4,%eax
c01079d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c01079d8:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c01079dd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01079e4:	00 
c01079e5:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01079ec:	00 
c01079ed:	89 04 24             	mov    %eax,(%esp)
c01079f0:	e8 90 f9 ff ff       	call   c0107385 <get_pte>
c01079f5:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01079f8:	74 24                	je     c0107a1e <check_pgdir+0x25e>
c01079fa:	c7 44 24 0c c4 b8 10 	movl   $0xc010b8c4,0xc(%esp)
c0107a01:	c0 
c0107a02:	c7 44 24 08 55 b7 10 	movl   $0xc010b755,0x8(%esp)
c0107a09:	c0 
c0107a0a:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
c0107a11:	00 
c0107a12:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c0107a19:	e8 e2 89 ff ff       	call   c0100400 <__panic>

    p2 = alloc_page();
c0107a1e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107a25:	e8 77 f2 ff ff       	call   c0106ca1 <alloc_pages>
c0107a2a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0107a2d:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107a32:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c0107a39:	00 
c0107a3a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0107a41:	00 
c0107a42:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107a45:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107a49:	89 04 24             	mov    %eax,(%esp)
c0107a4c:	e8 70 fb ff ff       	call   c01075c1 <page_insert>
c0107a51:	85 c0                	test   %eax,%eax
c0107a53:	74 24                	je     c0107a79 <check_pgdir+0x2b9>
c0107a55:	c7 44 24 0c ec b8 10 	movl   $0xc010b8ec,0xc(%esp)
c0107a5c:	c0 
c0107a5d:	c7 44 24 08 55 b7 10 	movl   $0xc010b755,0x8(%esp)
c0107a64:	c0 
c0107a65:	c7 44 24 04 ef 01 00 	movl   $0x1ef,0x4(%esp)
c0107a6c:	00 
c0107a6d:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c0107a74:	e8 87 89 ff ff       	call   c0100400 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0107a79:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107a7e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107a85:	00 
c0107a86:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0107a8d:	00 
c0107a8e:	89 04 24             	mov    %eax,(%esp)
c0107a91:	e8 ef f8 ff ff       	call   c0107385 <get_pte>
c0107a96:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107a99:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107a9d:	75 24                	jne    c0107ac3 <check_pgdir+0x303>
c0107a9f:	c7 44 24 0c 24 b9 10 	movl   $0xc010b924,0xc(%esp)
c0107aa6:	c0 
c0107aa7:	c7 44 24 08 55 b7 10 	movl   $0xc010b755,0x8(%esp)
c0107aae:	c0 
c0107aaf:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
c0107ab6:	00 
c0107ab7:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c0107abe:	e8 3d 89 ff ff       	call   c0100400 <__panic>
    assert(*ptep & PTE_U);
c0107ac3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107ac6:	8b 00                	mov    (%eax),%eax
c0107ac8:	83 e0 04             	and    $0x4,%eax
c0107acb:	85 c0                	test   %eax,%eax
c0107acd:	75 24                	jne    c0107af3 <check_pgdir+0x333>
c0107acf:	c7 44 24 0c 54 b9 10 	movl   $0xc010b954,0xc(%esp)
c0107ad6:	c0 
c0107ad7:	c7 44 24 08 55 b7 10 	movl   $0xc010b755,0x8(%esp)
c0107ade:	c0 
c0107adf:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
c0107ae6:	00 
c0107ae7:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c0107aee:	e8 0d 89 ff ff       	call   c0100400 <__panic>
    assert(*ptep & PTE_W);
c0107af3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107af6:	8b 00                	mov    (%eax),%eax
c0107af8:	83 e0 02             	and    $0x2,%eax
c0107afb:	85 c0                	test   %eax,%eax
c0107afd:	75 24                	jne    c0107b23 <check_pgdir+0x363>
c0107aff:	c7 44 24 0c 62 b9 10 	movl   $0xc010b962,0xc(%esp)
c0107b06:	c0 
c0107b07:	c7 44 24 08 55 b7 10 	movl   $0xc010b755,0x8(%esp)
c0107b0e:	c0 
c0107b0f:	c7 44 24 04 f2 01 00 	movl   $0x1f2,0x4(%esp)
c0107b16:	00 
c0107b17:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c0107b1e:	e8 dd 88 ff ff       	call   c0100400 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0107b23:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107b28:	8b 00                	mov    (%eax),%eax
c0107b2a:	83 e0 04             	and    $0x4,%eax
c0107b2d:	85 c0                	test   %eax,%eax
c0107b2f:	75 24                	jne    c0107b55 <check_pgdir+0x395>
c0107b31:	c7 44 24 0c 70 b9 10 	movl   $0xc010b970,0xc(%esp)
c0107b38:	c0 
c0107b39:	c7 44 24 08 55 b7 10 	movl   $0xc010b755,0x8(%esp)
c0107b40:	c0 
c0107b41:	c7 44 24 04 f3 01 00 	movl   $0x1f3,0x4(%esp)
c0107b48:	00 
c0107b49:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c0107b50:	e8 ab 88 ff ff       	call   c0100400 <__panic>
    assert(page_ref(p2) == 1);
c0107b55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107b58:	89 04 24             	mov    %eax,(%esp)
c0107b5b:	e8 3c ef ff ff       	call   c0106a9c <page_ref>
c0107b60:	83 f8 01             	cmp    $0x1,%eax
c0107b63:	74 24                	je     c0107b89 <check_pgdir+0x3c9>
c0107b65:	c7 44 24 0c 86 b9 10 	movl   $0xc010b986,0xc(%esp)
c0107b6c:	c0 
c0107b6d:	c7 44 24 08 55 b7 10 	movl   $0xc010b755,0x8(%esp)
c0107b74:	c0 
c0107b75:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
c0107b7c:	00 
c0107b7d:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c0107b84:	e8 77 88 ff ff       	call   c0100400 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0107b89:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107b8e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0107b95:	00 
c0107b96:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0107b9d:	00 
c0107b9e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107ba1:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107ba5:	89 04 24             	mov    %eax,(%esp)
c0107ba8:	e8 14 fa ff ff       	call   c01075c1 <page_insert>
c0107bad:	85 c0                	test   %eax,%eax
c0107baf:	74 24                	je     c0107bd5 <check_pgdir+0x415>
c0107bb1:	c7 44 24 0c 98 b9 10 	movl   $0xc010b998,0xc(%esp)
c0107bb8:	c0 
c0107bb9:	c7 44 24 08 55 b7 10 	movl   $0xc010b755,0x8(%esp)
c0107bc0:	c0 
c0107bc1:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
c0107bc8:	00 
c0107bc9:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c0107bd0:	e8 2b 88 ff ff       	call   c0100400 <__panic>
    assert(page_ref(p1) == 2);
c0107bd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107bd8:	89 04 24             	mov    %eax,(%esp)
c0107bdb:	e8 bc ee ff ff       	call   c0106a9c <page_ref>
c0107be0:	83 f8 02             	cmp    $0x2,%eax
c0107be3:	74 24                	je     c0107c09 <check_pgdir+0x449>
c0107be5:	c7 44 24 0c c4 b9 10 	movl   $0xc010b9c4,0xc(%esp)
c0107bec:	c0 
c0107bed:	c7 44 24 08 55 b7 10 	movl   $0xc010b755,0x8(%esp)
c0107bf4:	c0 
c0107bf5:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
c0107bfc:	00 
c0107bfd:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c0107c04:	e8 f7 87 ff ff       	call   c0100400 <__panic>
    assert(page_ref(p2) == 0);
c0107c09:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107c0c:	89 04 24             	mov    %eax,(%esp)
c0107c0f:	e8 88 ee ff ff       	call   c0106a9c <page_ref>
c0107c14:	85 c0                	test   %eax,%eax
c0107c16:	74 24                	je     c0107c3c <check_pgdir+0x47c>
c0107c18:	c7 44 24 0c d6 b9 10 	movl   $0xc010b9d6,0xc(%esp)
c0107c1f:	c0 
c0107c20:	c7 44 24 08 55 b7 10 	movl   $0xc010b755,0x8(%esp)
c0107c27:	c0 
c0107c28:	c7 44 24 04 f8 01 00 	movl   $0x1f8,0x4(%esp)
c0107c2f:	00 
c0107c30:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c0107c37:	e8 c4 87 ff ff       	call   c0100400 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0107c3c:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107c41:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107c48:	00 
c0107c49:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0107c50:	00 
c0107c51:	89 04 24             	mov    %eax,(%esp)
c0107c54:	e8 2c f7 ff ff       	call   c0107385 <get_pte>
c0107c59:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107c5c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107c60:	75 24                	jne    c0107c86 <check_pgdir+0x4c6>
c0107c62:	c7 44 24 0c 24 b9 10 	movl   $0xc010b924,0xc(%esp)
c0107c69:	c0 
c0107c6a:	c7 44 24 08 55 b7 10 	movl   $0xc010b755,0x8(%esp)
c0107c71:	c0 
c0107c72:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
c0107c79:	00 
c0107c7a:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c0107c81:	e8 7a 87 ff ff       	call   c0100400 <__panic>
    assert(pte2page(*ptep) == p1);
c0107c86:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107c89:	8b 00                	mov    (%eax),%eax
c0107c8b:	89 04 24             	mov    %eax,(%esp)
c0107c8e:	e8 b3 ed ff ff       	call   c0106a46 <pte2page>
c0107c93:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0107c96:	74 24                	je     c0107cbc <check_pgdir+0x4fc>
c0107c98:	c7 44 24 0c 99 b8 10 	movl   $0xc010b899,0xc(%esp)
c0107c9f:	c0 
c0107ca0:	c7 44 24 08 55 b7 10 	movl   $0xc010b755,0x8(%esp)
c0107ca7:	c0 
c0107ca8:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
c0107caf:	00 
c0107cb0:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c0107cb7:	e8 44 87 ff ff       	call   c0100400 <__panic>
    assert((*ptep & PTE_U) == 0);
c0107cbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107cbf:	8b 00                	mov    (%eax),%eax
c0107cc1:	83 e0 04             	and    $0x4,%eax
c0107cc4:	85 c0                	test   %eax,%eax
c0107cc6:	74 24                	je     c0107cec <check_pgdir+0x52c>
c0107cc8:	c7 44 24 0c e8 b9 10 	movl   $0xc010b9e8,0xc(%esp)
c0107ccf:	c0 
c0107cd0:	c7 44 24 08 55 b7 10 	movl   $0xc010b755,0x8(%esp)
c0107cd7:	c0 
c0107cd8:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
c0107cdf:	00 
c0107ce0:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c0107ce7:	e8 14 87 ff ff       	call   c0100400 <__panic>

    page_remove(boot_pgdir, 0x0);
c0107cec:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107cf1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0107cf8:	00 
c0107cf9:	89 04 24             	mov    %eax,(%esp)
c0107cfc:	e8 7c f8 ff ff       	call   c010757d <page_remove>
    assert(page_ref(p1) == 1);
c0107d01:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107d04:	89 04 24             	mov    %eax,(%esp)
c0107d07:	e8 90 ed ff ff       	call   c0106a9c <page_ref>
c0107d0c:	83 f8 01             	cmp    $0x1,%eax
c0107d0f:	74 24                	je     c0107d35 <check_pgdir+0x575>
c0107d11:	c7 44 24 0c af b8 10 	movl   $0xc010b8af,0xc(%esp)
c0107d18:	c0 
c0107d19:	c7 44 24 08 55 b7 10 	movl   $0xc010b755,0x8(%esp)
c0107d20:	c0 
c0107d21:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
c0107d28:	00 
c0107d29:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c0107d30:	e8 cb 86 ff ff       	call   c0100400 <__panic>
    assert(page_ref(p2) == 0);
c0107d35:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107d38:	89 04 24             	mov    %eax,(%esp)
c0107d3b:	e8 5c ed ff ff       	call   c0106a9c <page_ref>
c0107d40:	85 c0                	test   %eax,%eax
c0107d42:	74 24                	je     c0107d68 <check_pgdir+0x5a8>
c0107d44:	c7 44 24 0c d6 b9 10 	movl   $0xc010b9d6,0xc(%esp)
c0107d4b:	c0 
c0107d4c:	c7 44 24 08 55 b7 10 	movl   $0xc010b755,0x8(%esp)
c0107d53:	c0 
c0107d54:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
c0107d5b:	00 
c0107d5c:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c0107d63:	e8 98 86 ff ff       	call   c0100400 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0107d68:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107d6d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0107d74:	00 
c0107d75:	89 04 24             	mov    %eax,(%esp)
c0107d78:	e8 00 f8 ff ff       	call   c010757d <page_remove>
    assert(page_ref(p1) == 0);
c0107d7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107d80:	89 04 24             	mov    %eax,(%esp)
c0107d83:	e8 14 ed ff ff       	call   c0106a9c <page_ref>
c0107d88:	85 c0                	test   %eax,%eax
c0107d8a:	74 24                	je     c0107db0 <check_pgdir+0x5f0>
c0107d8c:	c7 44 24 0c fd b9 10 	movl   $0xc010b9fd,0xc(%esp)
c0107d93:	c0 
c0107d94:	c7 44 24 08 55 b7 10 	movl   $0xc010b755,0x8(%esp)
c0107d9b:	c0 
c0107d9c:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
c0107da3:	00 
c0107da4:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c0107dab:	e8 50 86 ff ff       	call   c0100400 <__panic>
    assert(page_ref(p2) == 0);
c0107db0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107db3:	89 04 24             	mov    %eax,(%esp)
c0107db6:	e8 e1 ec ff ff       	call   c0106a9c <page_ref>
c0107dbb:	85 c0                	test   %eax,%eax
c0107dbd:	74 24                	je     c0107de3 <check_pgdir+0x623>
c0107dbf:	c7 44 24 0c d6 b9 10 	movl   $0xc010b9d6,0xc(%esp)
c0107dc6:	c0 
c0107dc7:	c7 44 24 08 55 b7 10 	movl   $0xc010b755,0x8(%esp)
c0107dce:	c0 
c0107dcf:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
c0107dd6:	00 
c0107dd7:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c0107dde:	e8 1d 86 ff ff       	call   c0100400 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0107de3:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107de8:	8b 00                	mov    (%eax),%eax
c0107dea:	89 04 24             	mov    %eax,(%esp)
c0107ded:	e8 92 ec ff ff       	call   c0106a84 <pde2page>
c0107df2:	89 04 24             	mov    %eax,(%esp)
c0107df5:	e8 a2 ec ff ff       	call   c0106a9c <page_ref>
c0107dfa:	83 f8 01             	cmp    $0x1,%eax
c0107dfd:	74 24                	je     c0107e23 <check_pgdir+0x663>
c0107dff:	c7 44 24 0c 10 ba 10 	movl   $0xc010ba10,0xc(%esp)
c0107e06:	c0 
c0107e07:	c7 44 24 08 55 b7 10 	movl   $0xc010b755,0x8(%esp)
c0107e0e:	c0 
c0107e0f:	c7 44 24 04 05 02 00 	movl   $0x205,0x4(%esp)
c0107e16:	00 
c0107e17:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c0107e1e:	e8 dd 85 ff ff       	call   c0100400 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0107e23:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107e28:	8b 00                	mov    (%eax),%eax
c0107e2a:	89 04 24             	mov    %eax,(%esp)
c0107e2d:	e8 52 ec ff ff       	call   c0106a84 <pde2page>
c0107e32:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107e39:	00 
c0107e3a:	89 04 24             	mov    %eax,(%esp)
c0107e3d:	e8 ca ee ff ff       	call   c0106d0c <free_pages>
    boot_pgdir[0] = 0;
c0107e42:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107e47:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0107e4d:	c7 04 24 37 ba 10 c0 	movl   $0xc010ba37,(%esp)
c0107e54:	e8 50 84 ff ff       	call   c01002a9 <cprintf>
}
c0107e59:	c9                   	leave  
c0107e5a:	c3                   	ret    

c0107e5b <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0107e5b:	55                   	push   %ebp
c0107e5c:	89 e5                	mov    %esp,%ebp
c0107e5e:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0107e61:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0107e68:	e9 ca 00 00 00       	jmp    c0107f37 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0107e6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107e70:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107e73:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107e76:	c1 e8 0c             	shr    $0xc,%eax
c0107e79:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107e7c:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c0107e81:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0107e84:	72 23                	jb     c0107ea9 <check_boot_pgdir+0x4e>
c0107e86:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107e89:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107e8d:	c7 44 24 08 68 b6 10 	movl   $0xc010b668,0x8(%esp)
c0107e94:	c0 
c0107e95:	c7 44 24 04 11 02 00 	movl   $0x211,0x4(%esp)
c0107e9c:	00 
c0107e9d:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c0107ea4:	e8 57 85 ff ff       	call   c0100400 <__panic>
c0107ea9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107eac:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0107eb1:	89 c2                	mov    %eax,%edx
c0107eb3:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107eb8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107ebf:	00 
c0107ec0:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107ec4:	89 04 24             	mov    %eax,(%esp)
c0107ec7:	e8 b9 f4 ff ff       	call   c0107385 <get_pte>
c0107ecc:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107ecf:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0107ed3:	75 24                	jne    c0107ef9 <check_boot_pgdir+0x9e>
c0107ed5:	c7 44 24 0c 54 ba 10 	movl   $0xc010ba54,0xc(%esp)
c0107edc:	c0 
c0107edd:	c7 44 24 08 55 b7 10 	movl   $0xc010b755,0x8(%esp)
c0107ee4:	c0 
c0107ee5:	c7 44 24 04 11 02 00 	movl   $0x211,0x4(%esp)
c0107eec:	00 
c0107eed:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c0107ef4:	e8 07 85 ff ff       	call   c0100400 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0107ef9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107efc:	8b 00                	mov    (%eax),%eax
c0107efe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107f03:	89 c2                	mov    %eax,%edx
c0107f05:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f08:	39 c2                	cmp    %eax,%edx
c0107f0a:	74 24                	je     c0107f30 <check_boot_pgdir+0xd5>
c0107f0c:	c7 44 24 0c 91 ba 10 	movl   $0xc010ba91,0xc(%esp)
c0107f13:	c0 
c0107f14:	c7 44 24 08 55 b7 10 	movl   $0xc010b755,0x8(%esp)
c0107f1b:	c0 
c0107f1c:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
c0107f23:	00 
c0107f24:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c0107f2b:	e8 d0 84 ff ff       	call   c0100400 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
c0107f30:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0107f37:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107f3a:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c0107f3f:	39 c2                	cmp    %eax,%edx
c0107f41:	0f 82 26 ff ff ff    	jb     c0107e6d <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0107f47:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107f4c:	05 ac 0f 00 00       	add    $0xfac,%eax
c0107f51:	8b 00                	mov    (%eax),%eax
c0107f53:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107f58:	89 c2                	mov    %eax,%edx
c0107f5a:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107f5f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107f62:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c0107f69:	77 23                	ja     c0107f8e <check_boot_pgdir+0x133>
c0107f6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107f6e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107f72:	c7 44 24 08 0c b7 10 	movl   $0xc010b70c,0x8(%esp)
c0107f79:	c0 
c0107f7a:	c7 44 24 04 15 02 00 	movl   $0x215,0x4(%esp)
c0107f81:	00 
c0107f82:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c0107f89:	e8 72 84 ff ff       	call   c0100400 <__panic>
c0107f8e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107f91:	05 00 00 00 40       	add    $0x40000000,%eax
c0107f96:	39 c2                	cmp    %eax,%edx
c0107f98:	74 24                	je     c0107fbe <check_boot_pgdir+0x163>
c0107f9a:	c7 44 24 0c a8 ba 10 	movl   $0xc010baa8,0xc(%esp)
c0107fa1:	c0 
c0107fa2:	c7 44 24 08 55 b7 10 	movl   $0xc010b755,0x8(%esp)
c0107fa9:	c0 
c0107faa:	c7 44 24 04 15 02 00 	movl   $0x215,0x4(%esp)
c0107fb1:	00 
c0107fb2:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c0107fb9:	e8 42 84 ff ff       	call   c0100400 <__panic>

    assert(boot_pgdir[0] == 0);
c0107fbe:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0107fc3:	8b 00                	mov    (%eax),%eax
c0107fc5:	85 c0                	test   %eax,%eax
c0107fc7:	74 24                	je     c0107fed <check_boot_pgdir+0x192>
c0107fc9:	c7 44 24 0c dc ba 10 	movl   $0xc010badc,0xc(%esp)
c0107fd0:	c0 
c0107fd1:	c7 44 24 08 55 b7 10 	movl   $0xc010b755,0x8(%esp)
c0107fd8:	c0 
c0107fd9:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
c0107fe0:	00 
c0107fe1:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c0107fe8:	e8 13 84 ff ff       	call   c0100400 <__panic>

    struct Page *p;
    p = alloc_page();
c0107fed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107ff4:	e8 a8 ec ff ff       	call   c0106ca1 <alloc_pages>
c0107ff9:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0107ffc:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0108001:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0108008:	00 
c0108009:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0108010:	00 
c0108011:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108014:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108018:	89 04 24             	mov    %eax,(%esp)
c010801b:	e8 a1 f5 ff ff       	call   c01075c1 <page_insert>
c0108020:	85 c0                	test   %eax,%eax
c0108022:	74 24                	je     c0108048 <check_boot_pgdir+0x1ed>
c0108024:	c7 44 24 0c f0 ba 10 	movl   $0xc010baf0,0xc(%esp)
c010802b:	c0 
c010802c:	c7 44 24 08 55 b7 10 	movl   $0xc010b755,0x8(%esp)
c0108033:	c0 
c0108034:	c7 44 24 04 1b 02 00 	movl   $0x21b,0x4(%esp)
c010803b:	00 
c010803c:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c0108043:	e8 b8 83 ff ff       	call   c0100400 <__panic>
    assert(page_ref(p) == 1);
c0108048:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010804b:	89 04 24             	mov    %eax,(%esp)
c010804e:	e8 49 ea ff ff       	call   c0106a9c <page_ref>
c0108053:	83 f8 01             	cmp    $0x1,%eax
c0108056:	74 24                	je     c010807c <check_boot_pgdir+0x221>
c0108058:	c7 44 24 0c 1e bb 10 	movl   $0xc010bb1e,0xc(%esp)
c010805f:	c0 
c0108060:	c7 44 24 08 55 b7 10 	movl   $0xc010b755,0x8(%esp)
c0108067:	c0 
c0108068:	c7 44 24 04 1c 02 00 	movl   $0x21c,0x4(%esp)
c010806f:	00 
c0108070:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c0108077:	e8 84 83 ff ff       	call   c0100400 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c010807c:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c0108081:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0108088:	00 
c0108089:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0108090:	00 
c0108091:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108094:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108098:	89 04 24             	mov    %eax,(%esp)
c010809b:	e8 21 f5 ff ff       	call   c01075c1 <page_insert>
c01080a0:	85 c0                	test   %eax,%eax
c01080a2:	74 24                	je     c01080c8 <check_boot_pgdir+0x26d>
c01080a4:	c7 44 24 0c 30 bb 10 	movl   $0xc010bb30,0xc(%esp)
c01080ab:	c0 
c01080ac:	c7 44 24 08 55 b7 10 	movl   $0xc010b755,0x8(%esp)
c01080b3:	c0 
c01080b4:	c7 44 24 04 1d 02 00 	movl   $0x21d,0x4(%esp)
c01080bb:	00 
c01080bc:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c01080c3:	e8 38 83 ff ff       	call   c0100400 <__panic>
    assert(page_ref(p) == 2);
c01080c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01080cb:	89 04 24             	mov    %eax,(%esp)
c01080ce:	e8 c9 e9 ff ff       	call   c0106a9c <page_ref>
c01080d3:	83 f8 02             	cmp    $0x2,%eax
c01080d6:	74 24                	je     c01080fc <check_boot_pgdir+0x2a1>
c01080d8:	c7 44 24 0c 67 bb 10 	movl   $0xc010bb67,0xc(%esp)
c01080df:	c0 
c01080e0:	c7 44 24 08 55 b7 10 	movl   $0xc010b755,0x8(%esp)
c01080e7:	c0 
c01080e8:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
c01080ef:	00 
c01080f0:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c01080f7:	e8 04 83 ff ff       	call   c0100400 <__panic>

    const char *str = "ucore: Hello world!!";
c01080fc:	c7 45 dc 78 bb 10 c0 	movl   $0xc010bb78,-0x24(%ebp)
    strcpy((void *)0x100, str);
c0108103:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108106:	89 44 24 04          	mov    %eax,0x4(%esp)
c010810a:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0108111:	e8 6b 11 00 00       	call   c0109281 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0108116:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c010811d:	00 
c010811e:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0108125:	e8 d0 11 00 00       	call   c01092fa <strcmp>
c010812a:	85 c0                	test   %eax,%eax
c010812c:	74 24                	je     c0108152 <check_boot_pgdir+0x2f7>
c010812e:	c7 44 24 0c 90 bb 10 	movl   $0xc010bb90,0xc(%esp)
c0108135:	c0 
c0108136:	c7 44 24 08 55 b7 10 	movl   $0xc010b755,0x8(%esp)
c010813d:	c0 
c010813e:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
c0108145:	00 
c0108146:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c010814d:	e8 ae 82 ff ff       	call   c0100400 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0108152:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108155:	89 04 24             	mov    %eax,(%esp)
c0108158:	e8 95 e8 ff ff       	call   c01069f2 <page2kva>
c010815d:	05 00 01 00 00       	add    $0x100,%eax
c0108162:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0108165:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c010816c:	e8 b8 10 00 00       	call   c0109229 <strlen>
c0108171:	85 c0                	test   %eax,%eax
c0108173:	74 24                	je     c0108199 <check_boot_pgdir+0x33e>
c0108175:	c7 44 24 0c c8 bb 10 	movl   $0xc010bbc8,0xc(%esp)
c010817c:	c0 
c010817d:	c7 44 24 08 55 b7 10 	movl   $0xc010b755,0x8(%esp)
c0108184:	c0 
c0108185:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
c010818c:	00 
c010818d:	c7 04 24 30 b7 10 c0 	movl   $0xc010b730,(%esp)
c0108194:	e8 67 82 ff ff       	call   c0100400 <__panic>

    free_page(p);
c0108199:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01081a0:	00 
c01081a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01081a4:	89 04 24             	mov    %eax,(%esp)
c01081a7:	e8 60 eb ff ff       	call   c0106d0c <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c01081ac:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c01081b1:	8b 00                	mov    (%eax),%eax
c01081b3:	89 04 24             	mov    %eax,(%esp)
c01081b6:	e8 c9 e8 ff ff       	call   c0106a84 <pde2page>
c01081bb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01081c2:	00 
c01081c3:	89 04 24             	mov    %eax,(%esp)
c01081c6:	e8 41 eb ff ff       	call   c0106d0c <free_pages>
    boot_pgdir[0] = 0;
c01081cb:	a1 20 4a 12 c0       	mov    0xc0124a20,%eax
c01081d0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c01081d6:	c7 04 24 ec bb 10 c0 	movl   $0xc010bbec,(%esp)
c01081dd:	e8 c7 80 ff ff       	call   c01002a9 <cprintf>
}
c01081e2:	c9                   	leave  
c01081e3:	c3                   	ret    

c01081e4 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c01081e4:	55                   	push   %ebp
c01081e5:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c01081e7:	8b 45 08             	mov    0x8(%ebp),%eax
c01081ea:	83 e0 04             	and    $0x4,%eax
c01081ed:	85 c0                	test   %eax,%eax
c01081ef:	74 07                	je     c01081f8 <perm2str+0x14>
c01081f1:	b8 75 00 00 00       	mov    $0x75,%eax
c01081f6:	eb 05                	jmp    c01081fd <perm2str+0x19>
c01081f8:	b8 2d 00 00 00       	mov    $0x2d,%eax
c01081fd:	a2 08 80 12 c0       	mov    %al,0xc0128008
    str[1] = 'r';
c0108202:	c6 05 09 80 12 c0 72 	movb   $0x72,0xc0128009
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0108209:	8b 45 08             	mov    0x8(%ebp),%eax
c010820c:	83 e0 02             	and    $0x2,%eax
c010820f:	85 c0                	test   %eax,%eax
c0108211:	74 07                	je     c010821a <perm2str+0x36>
c0108213:	b8 77 00 00 00       	mov    $0x77,%eax
c0108218:	eb 05                	jmp    c010821f <perm2str+0x3b>
c010821a:	b8 2d 00 00 00       	mov    $0x2d,%eax
c010821f:	a2 0a 80 12 c0       	mov    %al,0xc012800a
    str[3] = '\0';
c0108224:	c6 05 0b 80 12 c0 00 	movb   $0x0,0xc012800b
    return str;
c010822b:	b8 08 80 12 c0       	mov    $0xc0128008,%eax
}
c0108230:	5d                   	pop    %ebp
c0108231:	c3                   	ret    

c0108232 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0108232:	55                   	push   %ebp
c0108233:	89 e5                	mov    %esp,%ebp
c0108235:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0108238:	8b 45 10             	mov    0x10(%ebp),%eax
c010823b:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010823e:	72 0a                	jb     c010824a <get_pgtable_items+0x18>
        return 0;
c0108240:	b8 00 00 00 00       	mov    $0x0,%eax
c0108245:	e9 9c 00 00 00       	jmp    c01082e6 <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
c010824a:	eb 04                	jmp    c0108250 <get_pgtable_items+0x1e>
        start ++;
c010824c:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
c0108250:	8b 45 10             	mov    0x10(%ebp),%eax
c0108253:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108256:	73 18                	jae    c0108270 <get_pgtable_items+0x3e>
c0108258:	8b 45 10             	mov    0x10(%ebp),%eax
c010825b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0108262:	8b 45 14             	mov    0x14(%ebp),%eax
c0108265:	01 d0                	add    %edx,%eax
c0108267:	8b 00                	mov    (%eax),%eax
c0108269:	83 e0 01             	and    $0x1,%eax
c010826c:	85 c0                	test   %eax,%eax
c010826e:	74 dc                	je     c010824c <get_pgtable_items+0x1a>
    }
    if (start < right) {
c0108270:	8b 45 10             	mov    0x10(%ebp),%eax
c0108273:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108276:	73 69                	jae    c01082e1 <get_pgtable_items+0xaf>
        if (left_store != NULL) {
c0108278:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c010827c:	74 08                	je     c0108286 <get_pgtable_items+0x54>
            *left_store = start;
c010827e:	8b 45 18             	mov    0x18(%ebp),%eax
c0108281:	8b 55 10             	mov    0x10(%ebp),%edx
c0108284:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0108286:	8b 45 10             	mov    0x10(%ebp),%eax
c0108289:	8d 50 01             	lea    0x1(%eax),%edx
c010828c:	89 55 10             	mov    %edx,0x10(%ebp)
c010828f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0108296:	8b 45 14             	mov    0x14(%ebp),%eax
c0108299:	01 d0                	add    %edx,%eax
c010829b:	8b 00                	mov    (%eax),%eax
c010829d:	83 e0 07             	and    $0x7,%eax
c01082a0:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c01082a3:	eb 04                	jmp    c01082a9 <get_pgtable_items+0x77>
            start ++;
c01082a5:	83 45 10 01          	addl   $0x1,0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c01082a9:	8b 45 10             	mov    0x10(%ebp),%eax
c01082ac:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01082af:	73 1d                	jae    c01082ce <get_pgtable_items+0x9c>
c01082b1:	8b 45 10             	mov    0x10(%ebp),%eax
c01082b4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01082bb:	8b 45 14             	mov    0x14(%ebp),%eax
c01082be:	01 d0                	add    %edx,%eax
c01082c0:	8b 00                	mov    (%eax),%eax
c01082c2:	83 e0 07             	and    $0x7,%eax
c01082c5:	89 c2                	mov    %eax,%edx
c01082c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01082ca:	39 c2                	cmp    %eax,%edx
c01082cc:	74 d7                	je     c01082a5 <get_pgtable_items+0x73>
        }
        if (right_store != NULL) {
c01082ce:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c01082d2:	74 08                	je     c01082dc <get_pgtable_items+0xaa>
            *right_store = start;
c01082d4:	8b 45 1c             	mov    0x1c(%ebp),%eax
c01082d7:	8b 55 10             	mov    0x10(%ebp),%edx
c01082da:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c01082dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01082df:	eb 05                	jmp    c01082e6 <get_pgtable_items+0xb4>
    }
    return 0;
c01082e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01082e6:	c9                   	leave  
c01082e7:	c3                   	ret    

c01082e8 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c01082e8:	55                   	push   %ebp
c01082e9:	89 e5                	mov    %esp,%ebp
c01082eb:	57                   	push   %edi
c01082ec:	56                   	push   %esi
c01082ed:	53                   	push   %ebx
c01082ee:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c01082f1:	c7 04 24 0c bc 10 c0 	movl   $0xc010bc0c,(%esp)
c01082f8:	e8 ac 7f ff ff       	call   c01002a9 <cprintf>
    size_t left, right = 0, perm;
c01082fd:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0108304:	e9 fa 00 00 00       	jmp    c0108403 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0108309:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010830c:	89 04 24             	mov    %eax,(%esp)
c010830f:	e8 d0 fe ff ff       	call   c01081e4 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0108314:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0108317:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010831a:	29 d1                	sub    %edx,%ecx
c010831c:	89 ca                	mov    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c010831e:	89 d6                	mov    %edx,%esi
c0108320:	c1 e6 16             	shl    $0x16,%esi
c0108323:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0108326:	89 d3                	mov    %edx,%ebx
c0108328:	c1 e3 16             	shl    $0x16,%ebx
c010832b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010832e:	89 d1                	mov    %edx,%ecx
c0108330:	c1 e1 16             	shl    $0x16,%ecx
c0108333:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0108336:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108339:	29 d7                	sub    %edx,%edi
c010833b:	89 fa                	mov    %edi,%edx
c010833d:	89 44 24 14          	mov    %eax,0x14(%esp)
c0108341:	89 74 24 10          	mov    %esi,0x10(%esp)
c0108345:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0108349:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c010834d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108351:	c7 04 24 3d bc 10 c0 	movl   $0xc010bc3d,(%esp)
c0108358:	e8 4c 7f ff ff       	call   c01002a9 <cprintf>
        size_t l, r = left * NPTEENTRY;
c010835d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108360:	c1 e0 0a             	shl    $0xa,%eax
c0108363:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0108366:	eb 54                	jmp    c01083bc <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0108368:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010836b:	89 04 24             	mov    %eax,(%esp)
c010836e:	e8 71 fe ff ff       	call   c01081e4 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0108373:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0108376:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0108379:	29 d1                	sub    %edx,%ecx
c010837b:	89 ca                	mov    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c010837d:	89 d6                	mov    %edx,%esi
c010837f:	c1 e6 0c             	shl    $0xc,%esi
c0108382:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0108385:	89 d3                	mov    %edx,%ebx
c0108387:	c1 e3 0c             	shl    $0xc,%ebx
c010838a:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010838d:	c1 e2 0c             	shl    $0xc,%edx
c0108390:	89 d1                	mov    %edx,%ecx
c0108392:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c0108395:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0108398:	29 d7                	sub    %edx,%edi
c010839a:	89 fa                	mov    %edi,%edx
c010839c:	89 44 24 14          	mov    %eax,0x14(%esp)
c01083a0:	89 74 24 10          	mov    %esi,0x10(%esp)
c01083a4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01083a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01083ac:	89 54 24 04          	mov    %edx,0x4(%esp)
c01083b0:	c7 04 24 5c bc 10 c0 	movl   $0xc010bc5c,(%esp)
c01083b7:	e8 ed 7e ff ff       	call   c01002a9 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c01083bc:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
c01083c1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01083c4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c01083c7:	89 ce                	mov    %ecx,%esi
c01083c9:	c1 e6 0a             	shl    $0xa,%esi
c01083cc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c01083cf:	89 cb                	mov    %ecx,%ebx
c01083d1:	c1 e3 0a             	shl    $0xa,%ebx
c01083d4:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
c01083d7:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c01083db:	8d 4d d8             	lea    -0x28(%ebp),%ecx
c01083de:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c01083e2:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01083e6:	89 44 24 08          	mov    %eax,0x8(%esp)
c01083ea:	89 74 24 04          	mov    %esi,0x4(%esp)
c01083ee:	89 1c 24             	mov    %ebx,(%esp)
c01083f1:	e8 3c fe ff ff       	call   c0108232 <get_pgtable_items>
c01083f6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01083f9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01083fd:	0f 85 65 ff ff ff    	jne    c0108368 <print_pgdir+0x80>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0108403:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
c0108408:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010840b:	8d 4d dc             	lea    -0x24(%ebp),%ecx
c010840e:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c0108412:	8d 4d e0             	lea    -0x20(%ebp),%ecx
c0108415:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0108419:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010841d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108421:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c0108428:	00 
c0108429:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0108430:	e8 fd fd ff ff       	call   c0108232 <get_pgtable_items>
c0108435:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108438:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010843c:	0f 85 c7 fe ff ff    	jne    c0108309 <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0108442:	c7 04 24 80 bc 10 c0 	movl   $0xc010bc80,(%esp)
c0108449:	e8 5b 7e ff ff       	call   c01002a9 <cprintf>
}
c010844e:	83 c4 4c             	add    $0x4c,%esp
c0108451:	5b                   	pop    %ebx
c0108452:	5e                   	pop    %esi
c0108453:	5f                   	pop    %edi
c0108454:	5d                   	pop    %ebp
c0108455:	c3                   	ret    

c0108456 <page2ppn>:
page2ppn(struct Page *page) {
c0108456:	55                   	push   %ebp
c0108457:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0108459:	8b 55 08             	mov    0x8(%ebp),%edx
c010845c:	a1 58 a1 12 c0       	mov    0xc012a158,%eax
c0108461:	29 c2                	sub    %eax,%edx
c0108463:	89 d0                	mov    %edx,%eax
c0108465:	c1 f8 05             	sar    $0x5,%eax
}
c0108468:	5d                   	pop    %ebp
c0108469:	c3                   	ret    

c010846a <page2pa>:
page2pa(struct Page *page) {
c010846a:	55                   	push   %ebp
c010846b:	89 e5                	mov    %esp,%ebp
c010846d:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0108470:	8b 45 08             	mov    0x8(%ebp),%eax
c0108473:	89 04 24             	mov    %eax,(%esp)
c0108476:	e8 db ff ff ff       	call   c0108456 <page2ppn>
c010847b:	c1 e0 0c             	shl    $0xc,%eax
}
c010847e:	c9                   	leave  
c010847f:	c3                   	ret    

c0108480 <page2kva>:
page2kva(struct Page *page) {
c0108480:	55                   	push   %ebp
c0108481:	89 e5                	mov    %esp,%ebp
c0108483:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0108486:	8b 45 08             	mov    0x8(%ebp),%eax
c0108489:	89 04 24             	mov    %eax,(%esp)
c010848c:	e8 d9 ff ff ff       	call   c010846a <page2pa>
c0108491:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108494:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108497:	c1 e8 0c             	shr    $0xc,%eax
c010849a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010849d:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c01084a2:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01084a5:	72 23                	jb     c01084ca <page2kva+0x4a>
c01084a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01084aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01084ae:	c7 44 24 08 b4 bc 10 	movl   $0xc010bcb4,0x8(%esp)
c01084b5:	c0 
c01084b6:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c01084bd:	00 
c01084be:	c7 04 24 d7 bc 10 c0 	movl   $0xc010bcd7,(%esp)
c01084c5:	e8 36 7f ff ff       	call   c0100400 <__panic>
c01084ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01084cd:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01084d2:	c9                   	leave  
c01084d3:	c3                   	ret    

c01084d4 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
c01084d4:	55                   	push   %ebp
c01084d5:	89 e5                	mov    %esp,%ebp
c01084d7:	83 ec 18             	sub    $0x18,%esp
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
c01084da:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01084e1:	e8 4d 8c ff ff       	call   c0101133 <ide_device_valid>
c01084e6:	85 c0                	test   %eax,%eax
c01084e8:	75 1c                	jne    c0108506 <swapfs_init+0x32>
        panic("swap fs isn't available.\n");
c01084ea:	c7 44 24 08 e5 bc 10 	movl   $0xc010bce5,0x8(%esp)
c01084f1:	c0 
c01084f2:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
c01084f9:	00 
c01084fa:	c7 04 24 ff bc 10 c0 	movl   $0xc010bcff,(%esp)
c0108501:	e8 fa 7e ff ff       	call   c0100400 <__panic>
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
c0108506:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010850d:	e8 60 8c ff ff       	call   c0101172 <ide_device_size>
c0108512:	c1 e8 03             	shr    $0x3,%eax
c0108515:	a3 1c a1 12 c0       	mov    %eax,0xc012a11c
}
c010851a:	c9                   	leave  
c010851b:	c3                   	ret    

c010851c <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
c010851c:	55                   	push   %ebp
c010851d:	89 e5                	mov    %esp,%ebp
c010851f:	83 ec 28             	sub    $0x28,%esp
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c0108522:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108525:	89 04 24             	mov    %eax,(%esp)
c0108528:	e8 53 ff ff ff       	call   c0108480 <page2kva>
c010852d:	8b 55 08             	mov    0x8(%ebp),%edx
c0108530:	c1 ea 08             	shr    $0x8,%edx
c0108533:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0108536:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010853a:	74 0b                	je     c0108547 <swapfs_read+0x2b>
c010853c:	8b 15 1c a1 12 c0    	mov    0xc012a11c,%edx
c0108542:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c0108545:	72 23                	jb     c010856a <swapfs_read+0x4e>
c0108547:	8b 45 08             	mov    0x8(%ebp),%eax
c010854a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010854e:	c7 44 24 08 10 bd 10 	movl   $0xc010bd10,0x8(%esp)
c0108555:	c0 
c0108556:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c010855d:	00 
c010855e:	c7 04 24 ff bc 10 c0 	movl   $0xc010bcff,(%esp)
c0108565:	e8 96 7e ff ff       	call   c0100400 <__panic>
c010856a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010856d:	c1 e2 03             	shl    $0x3,%edx
c0108570:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c0108577:	00 
c0108578:	89 44 24 08          	mov    %eax,0x8(%esp)
c010857c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108580:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108587:	e8 25 8c ff ff       	call   c01011b1 <ide_read_secs>
}
c010858c:	c9                   	leave  
c010858d:	c3                   	ret    

c010858e <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
c010858e:	55                   	push   %ebp
c010858f:	89 e5                	mov    %esp,%ebp
c0108591:	83 ec 28             	sub    $0x28,%esp
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c0108594:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108597:	89 04 24             	mov    %eax,(%esp)
c010859a:	e8 e1 fe ff ff       	call   c0108480 <page2kva>
c010859f:	8b 55 08             	mov    0x8(%ebp),%edx
c01085a2:	c1 ea 08             	shr    $0x8,%edx
c01085a5:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01085a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01085ac:	74 0b                	je     c01085b9 <swapfs_write+0x2b>
c01085ae:	8b 15 1c a1 12 c0    	mov    0xc012a11c,%edx
c01085b4:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c01085b7:	72 23                	jb     c01085dc <swapfs_write+0x4e>
c01085b9:	8b 45 08             	mov    0x8(%ebp),%eax
c01085bc:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01085c0:	c7 44 24 08 10 bd 10 	movl   $0xc010bd10,0x8(%esp)
c01085c7:	c0 
c01085c8:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
c01085cf:	00 
c01085d0:	c7 04 24 ff bc 10 c0 	movl   $0xc010bcff,(%esp)
c01085d7:	e8 24 7e ff ff       	call   c0100400 <__panic>
c01085dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01085df:	c1 e2 03             	shl    $0x3,%edx
c01085e2:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c01085e9:	00 
c01085ea:	89 44 24 08          	mov    %eax,0x8(%esp)
c01085ee:	89 54 24 04          	mov    %edx,0x4(%esp)
c01085f2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01085f9:	e8 f5 8d ff ff       	call   c01013f3 <ide_write_secs>
}
c01085fe:	c9                   	leave  
c01085ff:	c3                   	ret    

c0108600 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)

    pushl %edx              # push arg
c0108600:	52                   	push   %edx
    call *%ebx              # call fn
c0108601:	ff d3                	call   *%ebx

    pushl %eax              # save the return value of fn(arg)
c0108603:	50                   	push   %eax
    call do_exit            # call do_exit to terminate current thread
c0108604:	e8 82 08 00 00       	call   c0108e8b <do_exit>

c0108609 <switch_to>:
.text
.globl switch_to
switch_to:                      # switch_to(from, to)

    # save from's registers
    movl 4(%esp), %eax          # eax points to from
c0108609:	8b 44 24 04          	mov    0x4(%esp),%eax
    popl 0(%eax)                # save eip !popl
c010860d:	8f 00                	popl   (%eax)
    movl %esp, 4(%eax)          # save esp::context of from
c010860f:	89 60 04             	mov    %esp,0x4(%eax)
    movl %ebx, 8(%eax)          # save ebx::context of from
c0108612:	89 58 08             	mov    %ebx,0x8(%eax)
    movl %ecx, 12(%eax)         # save ecx::context of from
c0108615:	89 48 0c             	mov    %ecx,0xc(%eax)
    movl %edx, 16(%eax)         # save edx::context of from
c0108618:	89 50 10             	mov    %edx,0x10(%eax)
    movl %esi, 20(%eax)         # save esi::context of from
c010861b:	89 70 14             	mov    %esi,0x14(%eax)
    movl %edi, 24(%eax)         # save edi::context of from
c010861e:	89 78 18             	mov    %edi,0x18(%eax)
    movl %ebp, 28(%eax)         # save ebp::context of from
c0108621:	89 68 1c             	mov    %ebp,0x1c(%eax)

    # restore to's registers
    movl 4(%esp), %eax          # not 8(%esp): popped return address already
c0108624:	8b 44 24 04          	mov    0x4(%esp),%eax
                                # eax now points to to
    movl 28(%eax), %ebp         # restore ebp::context of to
c0108628:	8b 68 1c             	mov    0x1c(%eax),%ebp
    movl 24(%eax), %edi         # restore edi::context of to
c010862b:	8b 78 18             	mov    0x18(%eax),%edi
    movl 20(%eax), %esi         # restore esi::context of to
c010862e:	8b 70 14             	mov    0x14(%eax),%esi
    movl 16(%eax), %edx         # restore edx::context of to
c0108631:	8b 50 10             	mov    0x10(%eax),%edx
    movl 12(%eax), %ecx         # restore ecx::context of to
c0108634:	8b 48 0c             	mov    0xc(%eax),%ecx
    movl 8(%eax), %ebx          # restore ebx::context of to
c0108637:	8b 58 08             	mov    0x8(%eax),%ebx
    movl 4(%eax), %esp          # restore esp::context of to
c010863a:	8b 60 04             	mov    0x4(%eax),%esp

    pushl 0(%eax)               # push eip
c010863d:	ff 30                	pushl  (%eax)

    ret
c010863f:	c3                   	ret    

c0108640 <__intr_save>:
__intr_save(void) {
c0108640:	55                   	push   %ebp
c0108641:	89 e5                	mov    %esp,%ebp
c0108643:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0108646:	9c                   	pushf  
c0108647:	58                   	pop    %eax
c0108648:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c010864b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c010864e:	25 00 02 00 00       	and    $0x200,%eax
c0108653:	85 c0                	test   %eax,%eax
c0108655:	74 0c                	je     c0108663 <__intr_save+0x23>
        intr_disable();
c0108657:	e8 c1 9a ff ff       	call   c010211d <intr_disable>
        return 1;
c010865c:	b8 01 00 00 00       	mov    $0x1,%eax
c0108661:	eb 05                	jmp    c0108668 <__intr_save+0x28>
    return 0;
c0108663:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108668:	c9                   	leave  
c0108669:	c3                   	ret    

c010866a <__intr_restore>:
__intr_restore(bool flag) {
c010866a:	55                   	push   %ebp
c010866b:	89 e5                	mov    %esp,%ebp
c010866d:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0108670:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0108674:	74 05                	je     c010867b <__intr_restore+0x11>
        intr_enable();
c0108676:	e8 9c 9a ff ff       	call   c0102117 <intr_enable>
}
c010867b:	c9                   	leave  
c010867c:	c3                   	ret    

c010867d <page2ppn>:
page2ppn(struct Page *page) {
c010867d:	55                   	push   %ebp
c010867e:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0108680:	8b 55 08             	mov    0x8(%ebp),%edx
c0108683:	a1 58 a1 12 c0       	mov    0xc012a158,%eax
c0108688:	29 c2                	sub    %eax,%edx
c010868a:	89 d0                	mov    %edx,%eax
c010868c:	c1 f8 05             	sar    $0x5,%eax
}
c010868f:	5d                   	pop    %ebp
c0108690:	c3                   	ret    

c0108691 <page2pa>:
page2pa(struct Page *page) {
c0108691:	55                   	push   %ebp
c0108692:	89 e5                	mov    %esp,%ebp
c0108694:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0108697:	8b 45 08             	mov    0x8(%ebp),%eax
c010869a:	89 04 24             	mov    %eax,(%esp)
c010869d:	e8 db ff ff ff       	call   c010867d <page2ppn>
c01086a2:	c1 e0 0c             	shl    $0xc,%eax
}
c01086a5:	c9                   	leave  
c01086a6:	c3                   	ret    

c01086a7 <pa2page>:
pa2page(uintptr_t pa) {
c01086a7:	55                   	push   %ebp
c01086a8:	89 e5                	mov    %esp,%ebp
c01086aa:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c01086ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01086b0:	c1 e8 0c             	shr    $0xc,%eax
c01086b3:	89 c2                	mov    %eax,%edx
c01086b5:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c01086ba:	39 c2                	cmp    %eax,%edx
c01086bc:	72 1c                	jb     c01086da <pa2page+0x33>
        panic("pa2page called with invalid pa");
c01086be:	c7 44 24 08 30 bd 10 	movl   $0xc010bd30,0x8(%esp)
c01086c5:	c0 
c01086c6:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c01086cd:	00 
c01086ce:	c7 04 24 4f bd 10 c0 	movl   $0xc010bd4f,(%esp)
c01086d5:	e8 26 7d ff ff       	call   c0100400 <__panic>
    return &pages[PPN(pa)];
c01086da:	a1 58 a1 12 c0       	mov    0xc012a158,%eax
c01086df:	8b 55 08             	mov    0x8(%ebp),%edx
c01086e2:	c1 ea 0c             	shr    $0xc,%edx
c01086e5:	c1 e2 05             	shl    $0x5,%edx
c01086e8:	01 d0                	add    %edx,%eax
}
c01086ea:	c9                   	leave  
c01086eb:	c3                   	ret    

c01086ec <page2kva>:
page2kva(struct Page *page) {
c01086ec:	55                   	push   %ebp
c01086ed:	89 e5                	mov    %esp,%ebp
c01086ef:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c01086f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01086f5:	89 04 24             	mov    %eax,(%esp)
c01086f8:	e8 94 ff ff ff       	call   c0108691 <page2pa>
c01086fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108700:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108703:	c1 e8 0c             	shr    $0xc,%eax
c0108706:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108709:	a1 80 7f 12 c0       	mov    0xc0127f80,%eax
c010870e:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0108711:	72 23                	jb     c0108736 <page2kva+0x4a>
c0108713:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108716:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010871a:	c7 44 24 08 60 bd 10 	movl   $0xc010bd60,0x8(%esp)
c0108721:	c0 
c0108722:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c0108729:	00 
c010872a:	c7 04 24 4f bd 10 c0 	movl   $0xc010bd4f,(%esp)
c0108731:	e8 ca 7c ff ff       	call   c0100400 <__panic>
c0108736:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108739:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c010873e:	c9                   	leave  
c010873f:	c3                   	ret    

c0108740 <kva2page>:
kva2page(void *kva) {
c0108740:	55                   	push   %ebp
c0108741:	89 e5                	mov    %esp,%ebp
c0108743:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c0108746:	8b 45 08             	mov    0x8(%ebp),%eax
c0108749:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010874c:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0108753:	77 23                	ja     c0108778 <kva2page+0x38>
c0108755:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108758:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010875c:	c7 44 24 08 84 bd 10 	movl   $0xc010bd84,0x8(%esp)
c0108763:	c0 
c0108764:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
c010876b:	00 
c010876c:	c7 04 24 4f bd 10 c0 	movl   $0xc010bd4f,(%esp)
c0108773:	e8 88 7c ff ff       	call   c0100400 <__panic>
c0108778:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010877b:	05 00 00 00 40       	add    $0x40000000,%eax
c0108780:	89 04 24             	mov    %eax,(%esp)
c0108783:	e8 1f ff ff ff       	call   c01086a7 <pa2page>
}
c0108788:	c9                   	leave  
c0108789:	c3                   	ret    

c010878a <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
c010878a:	55                   	push   %ebp
c010878b:	89 e5                	mov    %esp,%ebp
c010878d:	83 ec 28             	sub    $0x28,%esp
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
c0108790:	c7 04 24 68 00 00 00 	movl   $0x68,(%esp)
c0108797:	e8 72 c3 ff ff       	call   c0104b0e <kmalloc>
c010879c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (proc != NULL) {
c010879f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01087a3:	0f 84 a1 00 00 00    	je     c010884a <alloc_proc+0xc0>
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
        proc->state = PROC_UNINIT;//设置进程为未初始化状态
c01087a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01087ac:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        proc->pid = -1; //未初始化的的进程id为-1
c01087b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01087b5:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
        proc->runs = 0;//初始化时间片
c01087bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01087bf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        proc->kstack = 0; //内存栈的地址
c01087c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01087c9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        proc->need_resched = 0;//不需要调度
c01087d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01087d3:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        proc->parent = NULL;  //父节点null
c01087da:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01087dd:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        proc->mm = NULL;      //内核线程常驻内存
c01087e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01087e7:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
        memset(&(proc->context), 0, sizeof(struct context));//上下文初始化0
c01087ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01087f1:	83 c0 1c             	add    $0x1c,%eax
c01087f4:	c7 44 24 08 20 00 00 	movl   $0x20,0x8(%esp)
c01087fb:	00 
c01087fc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0108803:	00 
c0108804:	89 04 24             	mov    %eax,(%esp)
c0108807:	e8 4c 0d 00 00       	call   c0109558 <memset>
        proc->tf = NULL; //中断帧指针null
c010880c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010880f:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
        proc->cr3 = boot_cr3;//页目录设为内核页目录表的基址
c0108816:	8b 15 54 a1 12 c0    	mov    0xc012a154,%edx
c010881c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010881f:	89 50 40             	mov    %edx,0x40(%eax)
        proc->flags = 0;//标志位0
c0108822:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108825:	c7 40 44 00 00 00 00 	movl   $0x0,0x44(%eax)
        memset(proc->name, 0, PROC_NAME_LEN);//进程名设为0
c010882c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010882f:	83 c0 48             	add    $0x48,%eax
c0108832:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c0108839:	00 
c010883a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0108841:	00 
c0108842:	89 04 24             	mov    %eax,(%esp)
c0108845:	e8 0e 0d 00 00       	call   c0109558 <memset>
    }
    return proc;
c010884a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010884d:	c9                   	leave  
c010884e:	c3                   	ret    

c010884f <set_proc_name>:

// set_proc_name - set the name of proc
char *
set_proc_name(struct proc_struct *proc, const char *name) {
c010884f:	55                   	push   %ebp
c0108850:	89 e5                	mov    %esp,%ebp
c0108852:	83 ec 18             	sub    $0x18,%esp
    memset(proc->name, 0, sizeof(proc->name));
c0108855:	8b 45 08             	mov    0x8(%ebp),%eax
c0108858:	83 c0 48             	add    $0x48,%eax
c010885b:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c0108862:	00 
c0108863:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010886a:	00 
c010886b:	89 04 24             	mov    %eax,(%esp)
c010886e:	e8 e5 0c 00 00       	call   c0109558 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
c0108873:	8b 45 08             	mov    0x8(%ebp),%eax
c0108876:	8d 50 48             	lea    0x48(%eax),%edx
c0108879:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c0108880:	00 
c0108881:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108884:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108888:	89 14 24             	mov    %edx,(%esp)
c010888b:	e8 aa 0d 00 00       	call   c010963a <memcpy>
}
c0108890:	c9                   	leave  
c0108891:	c3                   	ret    

c0108892 <get_proc_name>:

// get_proc_name - get the name of proc
char *
get_proc_name(struct proc_struct *proc) {
c0108892:	55                   	push   %ebp
c0108893:	89 e5                	mov    %esp,%ebp
c0108895:	83 ec 18             	sub    $0x18,%esp
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
c0108898:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c010889f:	00 
c01088a0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01088a7:	00 
c01088a8:	c7 04 24 44 a0 12 c0 	movl   $0xc012a044,(%esp)
c01088af:	e8 a4 0c 00 00       	call   c0109558 <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
c01088b4:	8b 45 08             	mov    0x8(%ebp),%eax
c01088b7:	83 c0 48             	add    $0x48,%eax
c01088ba:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c01088c1:	00 
c01088c2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01088c6:	c7 04 24 44 a0 12 c0 	movl   $0xc012a044,(%esp)
c01088cd:	e8 68 0d 00 00       	call   c010963a <memcpy>
}
c01088d2:	c9                   	leave  
c01088d3:	c3                   	ret    

c01088d4 <get_pid>:

// get_pid - alloc a unique pid for process
static int
get_pid(void) {
c01088d4:	55                   	push   %ebp
c01088d5:	89 e5                	mov    %esp,%ebp
c01088d7:	83 ec 10             	sub    $0x10,%esp
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
c01088da:	c7 45 f8 5c a1 12 c0 	movl   $0xc012a15c,-0x8(%ebp)
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++ last_pid >= MAX_PID) {
c01088e1:	a1 78 4a 12 c0       	mov    0xc0124a78,%eax
c01088e6:	83 c0 01             	add    $0x1,%eax
c01088e9:	a3 78 4a 12 c0       	mov    %eax,0xc0124a78
c01088ee:	a1 78 4a 12 c0       	mov    0xc0124a78,%eax
c01088f3:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c01088f8:	7e 0c                	jle    c0108906 <get_pid+0x32>
        last_pid = 1;
c01088fa:	c7 05 78 4a 12 c0 01 	movl   $0x1,0xc0124a78
c0108901:	00 00 00 
        goto inside;
c0108904:	eb 13                	jmp    c0108919 <get_pid+0x45>
    }
    if (last_pid >= next_safe) {
c0108906:	8b 15 78 4a 12 c0    	mov    0xc0124a78,%edx
c010890c:	a1 7c 4a 12 c0       	mov    0xc0124a7c,%eax
c0108911:	39 c2                	cmp    %eax,%edx
c0108913:	0f 8c ac 00 00 00    	jl     c01089c5 <get_pid+0xf1>
    inside:
        next_safe = MAX_PID;
c0108919:	c7 05 7c 4a 12 c0 00 	movl   $0x2000,0xc0124a7c
c0108920:	20 00 00 
    repeat:
        le = list;
c0108923:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108926:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while ((le = list_next(le)) != list) {
c0108929:	eb 7f                	jmp    c01089aa <get_pid+0xd6>
            proc = le2proc(le, list_link);
c010892b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010892e:	83 e8 58             	sub    $0x58,%eax
c0108931:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (proc->pid == last_pid) {
c0108934:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108937:	8b 50 04             	mov    0x4(%eax),%edx
c010893a:	a1 78 4a 12 c0       	mov    0xc0124a78,%eax
c010893f:	39 c2                	cmp    %eax,%edx
c0108941:	75 3e                	jne    c0108981 <get_pid+0xad>
                if (++ last_pid >= next_safe) {
c0108943:	a1 78 4a 12 c0       	mov    0xc0124a78,%eax
c0108948:	83 c0 01             	add    $0x1,%eax
c010894b:	a3 78 4a 12 c0       	mov    %eax,0xc0124a78
c0108950:	8b 15 78 4a 12 c0    	mov    0xc0124a78,%edx
c0108956:	a1 7c 4a 12 c0       	mov    0xc0124a7c,%eax
c010895b:	39 c2                	cmp    %eax,%edx
c010895d:	7c 4b                	jl     c01089aa <get_pid+0xd6>
                    if (last_pid >= MAX_PID) {
c010895f:	a1 78 4a 12 c0       	mov    0xc0124a78,%eax
c0108964:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c0108969:	7e 0a                	jle    c0108975 <get_pid+0xa1>
                        last_pid = 1;
c010896b:	c7 05 78 4a 12 c0 01 	movl   $0x1,0xc0124a78
c0108972:	00 00 00 
                    }
                    next_safe = MAX_PID;
c0108975:	c7 05 7c 4a 12 c0 00 	movl   $0x2000,0xc0124a7c
c010897c:	20 00 00 
                    goto repeat;
c010897f:	eb a2                	jmp    c0108923 <get_pid+0x4f>
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {
c0108981:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108984:	8b 50 04             	mov    0x4(%eax),%edx
c0108987:	a1 78 4a 12 c0       	mov    0xc0124a78,%eax
c010898c:	39 c2                	cmp    %eax,%edx
c010898e:	7e 1a                	jle    c01089aa <get_pid+0xd6>
c0108990:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108993:	8b 50 04             	mov    0x4(%eax),%edx
c0108996:	a1 7c 4a 12 c0       	mov    0xc0124a7c,%eax
c010899b:	39 c2                	cmp    %eax,%edx
c010899d:	7d 0b                	jge    c01089aa <get_pid+0xd6>
                next_safe = proc->pid;
c010899f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01089a2:	8b 40 04             	mov    0x4(%eax),%eax
c01089a5:	a3 7c 4a 12 c0       	mov    %eax,0xc0124a7c
c01089aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01089ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01089b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01089b3:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list) {
c01089b6:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01089b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01089bc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01089bf:	0f 85 66 ff ff ff    	jne    c010892b <get_pid+0x57>
            }
        }
    }
    return last_pid;
c01089c5:	a1 78 4a 12 c0       	mov    0xc0124a78,%eax
}
c01089ca:	c9                   	leave  
c01089cb:	c3                   	ret    

c01089cc <proc_run>:

// proc_run - make process "proc" running on cpu
// NOTE: before call switch_to, should load  base addr of "proc"'s new PDT
void
proc_run(struct proc_struct *proc) {
c01089cc:	55                   	push   %ebp
c01089cd:	89 e5                	mov    %esp,%ebp
c01089cf:	83 ec 28             	sub    $0x28,%esp
    if (proc != current) {
c01089d2:	a1 28 80 12 c0       	mov    0xc0128028,%eax
c01089d7:	39 45 08             	cmp    %eax,0x8(%ebp)
c01089da:	74 63                	je     c0108a3f <proc_run+0x73>
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
c01089dc:	a1 28 80 12 c0       	mov    0xc0128028,%eax
c01089e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01089e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01089e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
        local_intr_save(intr_flag);
c01089ea:	e8 51 fc ff ff       	call   c0108640 <__intr_save>
c01089ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
        {
            current = proc;
c01089f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01089f5:	a3 28 80 12 c0       	mov    %eax,0xc0128028
            load_esp0(next->kstack + KSTACKSIZE);
c01089fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01089fd:	8b 40 0c             	mov    0xc(%eax),%eax
c0108a00:	05 00 20 00 00       	add    $0x2000,%eax
c0108a05:	89 04 24             	mov    %eax,(%esp)
c0108a08:	e8 46 e1 ff ff       	call   c0106b53 <load_esp0>
            lcr3(next->cr3);
c0108a0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108a10:	8b 40 40             	mov    0x40(%eax),%eax
c0108a13:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c0108a16:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108a19:	0f 22 d8             	mov    %eax,%cr3
            switch_to(&(prev->context), &(next->context));
c0108a1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108a1f:	8d 50 1c             	lea    0x1c(%eax),%edx
c0108a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a25:	83 c0 1c             	add    $0x1c,%eax
c0108a28:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108a2c:	89 04 24             	mov    %eax,(%esp)
c0108a2f:	e8 d5 fb ff ff       	call   c0108609 <switch_to>
        }
        local_intr_restore(intr_flag);
c0108a34:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108a37:	89 04 24             	mov    %eax,(%esp)
c0108a3a:	e8 2b fc ff ff       	call   c010866a <__intr_restore>
    }
}
c0108a3f:	c9                   	leave  
c0108a40:	c3                   	ret    

c0108a41 <forkret>:

// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
c0108a41:	55                   	push   %ebp
c0108a42:	89 e5                	mov    %esp,%ebp
c0108a44:	83 ec 18             	sub    $0x18,%esp
    forkrets(current->tf);
c0108a47:	a1 28 80 12 c0       	mov    0xc0128028,%eax
c0108a4c:	8b 40 3c             	mov    0x3c(%eax),%eax
c0108a4f:	89 04 24             	mov    %eax,(%esp)
c0108a52:	e8 46 a8 ff ff       	call   c010329d <forkrets>
}
c0108a57:	c9                   	leave  
c0108a58:	c3                   	ret    

c0108a59 <hash_proc>:

// hash_proc - add proc into proc hash_list
static void
hash_proc(struct proc_struct *proc) {
c0108a59:	55                   	push   %ebp
c0108a5a:	89 e5                	mov    %esp,%ebp
c0108a5c:	53                   	push   %ebx
c0108a5d:	83 ec 34             	sub    $0x34,%esp
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
c0108a60:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a63:	8d 58 60             	lea    0x60(%eax),%ebx
c0108a66:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a69:	8b 40 04             	mov    0x4(%eax),%eax
c0108a6c:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c0108a73:	00 
c0108a74:	89 04 24             	mov    %eax,(%esp)
c0108a77:	e8 e6 12 00 00       	call   c0109d62 <hash32>
c0108a7c:	c1 e0 03             	shl    $0x3,%eax
c0108a7f:	05 40 80 12 c0       	add    $0xc0128040,%eax
c0108a84:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108a87:	89 5d f0             	mov    %ebx,-0x10(%ebp)
c0108a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a8d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108a90:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108a93:	89 45 e8             	mov    %eax,-0x18(%ebp)
    __list_add(elm, listelm, listelm->next);
c0108a96:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108a99:	8b 40 04             	mov    0x4(%eax),%eax
c0108a9c:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0108a9f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0108aa2:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108aa5:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0108aa8:	89 45 dc             	mov    %eax,-0x24(%ebp)
    prev->next = next->prev = elm;
c0108aab:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108aae:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108ab1:	89 10                	mov    %edx,(%eax)
c0108ab3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108ab6:	8b 10                	mov    (%eax),%edx
c0108ab8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108abb:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0108abe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108ac1:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0108ac4:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0108ac7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108aca:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108acd:	89 10                	mov    %edx,(%eax)
}
c0108acf:	83 c4 34             	add    $0x34,%esp
c0108ad2:	5b                   	pop    %ebx
c0108ad3:	5d                   	pop    %ebp
c0108ad4:	c3                   	ret    

c0108ad5 <find_proc>:

// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
c0108ad5:	55                   	push   %ebp
c0108ad6:	89 e5                	mov    %esp,%ebp
c0108ad8:	83 ec 28             	sub    $0x28,%esp
    if (0 < pid && pid < MAX_PID) {
c0108adb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0108adf:	7e 5f                	jle    c0108b40 <find_proc+0x6b>
c0108ae1:	81 7d 08 ff 1f 00 00 	cmpl   $0x1fff,0x8(%ebp)
c0108ae8:	7f 56                	jg     c0108b40 <find_proc+0x6b>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
c0108aea:	8b 45 08             	mov    0x8(%ebp),%eax
c0108aed:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c0108af4:	00 
c0108af5:	89 04 24             	mov    %eax,(%esp)
c0108af8:	e8 65 12 00 00       	call   c0109d62 <hash32>
c0108afd:	c1 e0 03             	shl    $0x3,%eax
c0108b00:	05 40 80 12 c0       	add    $0xc0128040,%eax
c0108b05:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108b08:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108b0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
        while ((le = list_next(le)) != list) {
c0108b0e:	eb 19                	jmp    c0108b29 <find_proc+0x54>
            struct proc_struct *proc = le2proc(le, hash_link);
c0108b10:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108b13:	83 e8 60             	sub    $0x60,%eax
c0108b16:	89 45 ec             	mov    %eax,-0x14(%ebp)
            if (proc->pid == pid) {
c0108b19:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108b1c:	8b 40 04             	mov    0x4(%eax),%eax
c0108b1f:	3b 45 08             	cmp    0x8(%ebp),%eax
c0108b22:	75 05                	jne    c0108b29 <find_proc+0x54>
                return proc;
c0108b24:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108b27:	eb 1c                	jmp    c0108b45 <find_proc+0x70>
c0108b29:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108b2c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return listelm->next;
c0108b2f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108b32:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list) {
c0108b35:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108b3b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0108b3e:	75 d0                	jne    c0108b10 <find_proc+0x3b>
            }
        }
    }
    return NULL;
c0108b40:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108b45:	c9                   	leave  
c0108b46:	c3                   	ret    

c0108b47 <kernel_thread>:

// kernel_thread - create a kernel thread using "fn" function
// NOTE: the contents of temp trapframe tf will be copied to 
//       proc->tf in do_fork-->copy_thread function
int
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
c0108b47:	55                   	push   %ebp
c0108b48:	89 e5                	mov    %esp,%ebp
c0108b4a:	83 ec 68             	sub    $0x68,%esp
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
c0108b4d:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
c0108b54:	00 
c0108b55:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0108b5c:	00 
c0108b5d:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0108b60:	89 04 24             	mov    %eax,(%esp)
c0108b63:	e8 f0 09 00 00       	call   c0109558 <memset>
    tf.tf_cs = KERNEL_CS;
c0108b68:	66 c7 45 e8 08 00    	movw   $0x8,-0x18(%ebp)
    tf.tf_ds = tf.tf_es = tf.tf_ss = KERNEL_DS;
c0108b6e:	66 c7 45 f4 10 00    	movw   $0x10,-0xc(%ebp)
c0108b74:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0108b78:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
c0108b7c:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
c0108b80:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
    tf.tf_regs.reg_ebx = (uint32_t)fn;
c0108b84:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b87:	89 45 bc             	mov    %eax,-0x44(%ebp)
    tf.tf_regs.reg_edx = (uint32_t)arg;
c0108b8a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108b8d:	89 45 c0             	mov    %eax,-0x40(%ebp)
    tf.tf_eip = (uint32_t)kernel_thread_entry;
c0108b90:	b8 00 86 10 c0       	mov    $0xc0108600,%eax
c0108b95:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
c0108b98:	8b 45 10             	mov    0x10(%ebp),%eax
c0108b9b:	80 cc 01             	or     $0x1,%ah
c0108b9e:	89 c2                	mov    %eax,%edx
c0108ba0:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0108ba3:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108ba7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0108bae:	00 
c0108baf:	89 14 24             	mov    %edx,(%esp)
c0108bb2:	e8 79 01 00 00       	call   c0108d30 <do_fork>
}
c0108bb7:	c9                   	leave  
c0108bb8:	c3                   	ret    

c0108bb9 <setup_kstack>:

// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
static int
setup_kstack(struct proc_struct *proc) {
c0108bb9:	55                   	push   %ebp
c0108bba:	89 e5                	mov    %esp,%ebp
c0108bbc:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_pages(KSTACKPAGE);
c0108bbf:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0108bc6:	e8 d6 e0 ff ff       	call   c0106ca1 <alloc_pages>
c0108bcb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c0108bce:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108bd2:	74 1a                	je     c0108bee <setup_kstack+0x35>
        proc->kstack = (uintptr_t)page2kva(page);
c0108bd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108bd7:	89 04 24             	mov    %eax,(%esp)
c0108bda:	e8 0d fb ff ff       	call   c01086ec <page2kva>
c0108bdf:	89 c2                	mov    %eax,%edx
c0108be1:	8b 45 08             	mov    0x8(%ebp),%eax
c0108be4:	89 50 0c             	mov    %edx,0xc(%eax)
        return 0;
c0108be7:	b8 00 00 00 00       	mov    $0x0,%eax
c0108bec:	eb 05                	jmp    c0108bf3 <setup_kstack+0x3a>
    }
    return -E_NO_MEM;
c0108bee:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
c0108bf3:	c9                   	leave  
c0108bf4:	c3                   	ret    

c0108bf5 <put_kstack>:

// put_kstack - free the memory space of process kernel stack
static void
put_kstack(struct proc_struct *proc) {
c0108bf5:	55                   	push   %ebp
c0108bf6:	89 e5                	mov    %esp,%ebp
c0108bf8:	83 ec 18             	sub    $0x18,%esp
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
c0108bfb:	8b 45 08             	mov    0x8(%ebp),%eax
c0108bfe:	8b 40 0c             	mov    0xc(%eax),%eax
c0108c01:	89 04 24             	mov    %eax,(%esp)
c0108c04:	e8 37 fb ff ff       	call   c0108740 <kva2page>
c0108c09:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0108c10:	00 
c0108c11:	89 04 24             	mov    %eax,(%esp)
c0108c14:	e8 f3 e0 ff ff       	call   c0106d0c <free_pages>
}
c0108c19:	c9                   	leave  
c0108c1a:	c3                   	ret    

c0108c1b <copy_mm>:

// copy_mm - process "proc" duplicate OR share process "current"'s mm according clone_flags
//         - if clone_flags & CLONE_VM, then "share" ; else "duplicate"
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
c0108c1b:	55                   	push   %ebp
c0108c1c:	89 e5                	mov    %esp,%ebp
c0108c1e:	83 ec 18             	sub    $0x18,%esp
    assert(current->mm == NULL);
c0108c21:	a1 28 80 12 c0       	mov    0xc0128028,%eax
c0108c26:	8b 40 18             	mov    0x18(%eax),%eax
c0108c29:	85 c0                	test   %eax,%eax
c0108c2b:	74 24                	je     c0108c51 <copy_mm+0x36>
c0108c2d:	c7 44 24 0c a8 bd 10 	movl   $0xc010bda8,0xc(%esp)
c0108c34:	c0 
c0108c35:	c7 44 24 08 bc bd 10 	movl   $0xc010bdbc,0x8(%esp)
c0108c3c:	c0 
c0108c3d:	c7 44 24 04 fe 00 00 	movl   $0xfe,0x4(%esp)
c0108c44:	00 
c0108c45:	c7 04 24 d1 bd 10 c0 	movl   $0xc010bdd1,(%esp)
c0108c4c:	e8 af 77 ff ff       	call   c0100400 <__panic>
    /* do nothing in this project */
    return 0;
c0108c51:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108c56:	c9                   	leave  
c0108c57:	c3                   	ret    

c0108c58 <copy_thread>:

// copy_thread - setup the trapframe on the  process's kernel stack top and
//             - setup the kernel entry point and stack of process
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) {
c0108c58:	55                   	push   %ebp
c0108c59:	89 e5                	mov    %esp,%ebp
c0108c5b:	57                   	push   %edi
c0108c5c:	56                   	push   %esi
c0108c5d:	53                   	push   %ebx
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
c0108c5e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108c61:	8b 40 0c             	mov    0xc(%eax),%eax
c0108c64:	05 b4 1f 00 00       	add    $0x1fb4,%eax
c0108c69:	89 c2                	mov    %eax,%edx
c0108c6b:	8b 45 08             	mov    0x8(%ebp),%eax
c0108c6e:	89 50 3c             	mov    %edx,0x3c(%eax)
    *(proc->tf) = *tf;
c0108c71:	8b 45 08             	mov    0x8(%ebp),%eax
c0108c74:	8b 40 3c             	mov    0x3c(%eax),%eax
c0108c77:	8b 55 10             	mov    0x10(%ebp),%edx
c0108c7a:	bb 4c 00 00 00       	mov    $0x4c,%ebx
c0108c7f:	89 c1                	mov    %eax,%ecx
c0108c81:	83 e1 01             	and    $0x1,%ecx
c0108c84:	85 c9                	test   %ecx,%ecx
c0108c86:	74 0e                	je     c0108c96 <copy_thread+0x3e>
c0108c88:	0f b6 0a             	movzbl (%edx),%ecx
c0108c8b:	88 08                	mov    %cl,(%eax)
c0108c8d:	83 c0 01             	add    $0x1,%eax
c0108c90:	83 c2 01             	add    $0x1,%edx
c0108c93:	83 eb 01             	sub    $0x1,%ebx
c0108c96:	89 c1                	mov    %eax,%ecx
c0108c98:	83 e1 02             	and    $0x2,%ecx
c0108c9b:	85 c9                	test   %ecx,%ecx
c0108c9d:	74 0f                	je     c0108cae <copy_thread+0x56>
c0108c9f:	0f b7 0a             	movzwl (%edx),%ecx
c0108ca2:	66 89 08             	mov    %cx,(%eax)
c0108ca5:	83 c0 02             	add    $0x2,%eax
c0108ca8:	83 c2 02             	add    $0x2,%edx
c0108cab:	83 eb 02             	sub    $0x2,%ebx
c0108cae:	89 d9                	mov    %ebx,%ecx
c0108cb0:	c1 e9 02             	shr    $0x2,%ecx
c0108cb3:	89 c7                	mov    %eax,%edi
c0108cb5:	89 d6                	mov    %edx,%esi
c0108cb7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0108cb9:	89 f2                	mov    %esi,%edx
c0108cbb:	89 f8                	mov    %edi,%eax
c0108cbd:	b9 00 00 00 00       	mov    $0x0,%ecx
c0108cc2:	89 de                	mov    %ebx,%esi
c0108cc4:	83 e6 02             	and    $0x2,%esi
c0108cc7:	85 f6                	test   %esi,%esi
c0108cc9:	74 0b                	je     c0108cd6 <copy_thread+0x7e>
c0108ccb:	0f b7 34 0a          	movzwl (%edx,%ecx,1),%esi
c0108ccf:	66 89 34 08          	mov    %si,(%eax,%ecx,1)
c0108cd3:	83 c1 02             	add    $0x2,%ecx
c0108cd6:	83 e3 01             	and    $0x1,%ebx
c0108cd9:	85 db                	test   %ebx,%ebx
c0108cdb:	74 07                	je     c0108ce4 <copy_thread+0x8c>
c0108cdd:	0f b6 14 0a          	movzbl (%edx,%ecx,1),%edx
c0108ce1:	88 14 08             	mov    %dl,(%eax,%ecx,1)
    proc->tf->tf_regs.reg_eax = 0;
c0108ce4:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ce7:	8b 40 3c             	mov    0x3c(%eax),%eax
c0108cea:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    proc->tf->tf_esp = esp;
c0108cf1:	8b 45 08             	mov    0x8(%ebp),%eax
c0108cf4:	8b 40 3c             	mov    0x3c(%eax),%eax
c0108cf7:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108cfa:	89 50 44             	mov    %edx,0x44(%eax)
    proc->tf->tf_eflags |= FL_IF;
c0108cfd:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d00:	8b 40 3c             	mov    0x3c(%eax),%eax
c0108d03:	8b 55 08             	mov    0x8(%ebp),%edx
c0108d06:	8b 52 3c             	mov    0x3c(%edx),%edx
c0108d09:	8b 52 40             	mov    0x40(%edx),%edx
c0108d0c:	80 ce 02             	or     $0x2,%dh
c0108d0f:	89 50 40             	mov    %edx,0x40(%eax)

    proc->context.eip = (uintptr_t)forkret;
c0108d12:	ba 41 8a 10 c0       	mov    $0xc0108a41,%edx
c0108d17:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d1a:	89 50 1c             	mov    %edx,0x1c(%eax)
    proc->context.esp = (uintptr_t)(proc->tf);
c0108d1d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d20:	8b 40 3c             	mov    0x3c(%eax),%eax
c0108d23:	89 c2                	mov    %eax,%edx
c0108d25:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d28:	89 50 20             	mov    %edx,0x20(%eax)
}
c0108d2b:	5b                   	pop    %ebx
c0108d2c:	5e                   	pop    %esi
c0108d2d:	5f                   	pop    %edi
c0108d2e:	5d                   	pop    %ebp
c0108d2f:	c3                   	ret    

c0108d30 <do_fork>:
 * @clone_flags: used to guide how to clone the child process
 * @stack:       the parent's user stack pointer. if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child process's proc->tf
 */
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
c0108d30:	55                   	push   %ebp
c0108d31:	89 e5                	mov    %esp,%ebp
c0108d33:	83 ec 48             	sub    $0x48,%esp
    int ret = -E_NO_FREE_PROC;
c0108d36:	c7 45 f4 fb ff ff ff 	movl   $0xfffffffb,-0xc(%ebp)
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
c0108d3d:	a1 40 a0 12 c0       	mov    0xc012a040,%eax
c0108d42:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c0108d47:	7e 05                	jle    c0108d4e <do_fork+0x1e>
        goto fork_out;
c0108d49:	e9 38 01 00 00       	jmp    c0108e86 <do_fork+0x156>
    }
    ret = -E_NO_MEM;
c0108d4e:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
    //    3. call copy_mm to dup OR share mm according clone_flag
    //    4. call copy_thread to setup tf & context in proc_struct
    //    5. insert proc_struct into hash_list && proc_list
    //    6. call wakeup_proc to make the new child process RUNNABLE
    //    7. set ret vaule using child proc's pid
    proc = alloc_proc(); // 分配tcb的内存块
c0108d55:	e8 30 fa ff ff       	call   c010878a <alloc_proc>
c0108d5a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (proc == NULL) goto fork_out; // 判断是否分配到内存空间
c0108d5d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0108d61:	75 05                	jne    c0108d68 <do_fork+0x38>
c0108d63:	e9 1e 01 00 00       	jmp    c0108e86 <do_fork+0x156>
	proc->parent = current;//将子进程的父节点设置为当前进程
c0108d68:	8b 15 28 80 12 c0    	mov    0xc0128028,%edx
c0108d6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108d71:	89 50 14             	mov    %edx,0x14(%eax)
    assert(setup_kstack(proc) == 0);  // 为新的线程设置栈
c0108d74:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108d77:	89 04 24             	mov    %eax,(%esp)
c0108d7a:	e8 3a fe ff ff       	call   c0108bb9 <setup_kstack>
c0108d7f:	85 c0                	test   %eax,%eax
c0108d81:	74 24                	je     c0108da7 <do_fork+0x77>
c0108d83:	c7 44 24 0c e5 bd 10 	movl   $0xc010bde5,0xc(%esp)
c0108d8a:	c0 
c0108d8b:	c7 44 24 08 bc bd 10 	movl   $0xc010bdbc,0x8(%esp)
c0108d92:	c0 
c0108d93:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
c0108d9a:	00 
c0108d9b:	c7 04 24 d1 bd 10 c0 	movl   $0xc010bdd1,(%esp)
c0108da2:	e8 59 76 ff ff       	call   c0100400 <__panic>
    assert(copy_mm(clone_flags, proc) == 0); //复制父进程的内存信息到子进程
c0108da7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108daa:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108dae:	8b 45 08             	mov    0x8(%ebp),%eax
c0108db1:	89 04 24             	mov    %eax,(%esp)
c0108db4:	e8 62 fe ff ff       	call   c0108c1b <copy_mm>
c0108db9:	85 c0                	test   %eax,%eax
c0108dbb:	74 24                	je     c0108de1 <do_fork+0xb1>
c0108dbd:	c7 44 24 0c 00 be 10 	movl   $0xc010be00,0xc(%esp)
c0108dc4:	c0 
c0108dc5:	c7 44 24 08 bc bd 10 	movl   $0xc010bdbc,0x8(%esp)
c0108dcc:	c0 
c0108dcd:	c7 44 24 04 3b 01 00 	movl   $0x13b,0x4(%esp)
c0108dd4:	00 
c0108dd5:	c7 04 24 d1 bd 10 c0 	movl   $0xc010bdd1,(%esp)
c0108ddc:	e8 1f 76 ff ff       	call   c0100400 <__panic>
    copy_thread(proc, stack, tf); // 复制父进程的中断帧和上下文信息
c0108de1:	8b 45 10             	mov    0x10(%ebp),%eax
c0108de4:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108de8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108deb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108def:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108df2:	89 04 24             	mov    %eax,(%esp)
c0108df5:	e8 5e fe ff ff       	call   c0108c58 <copy_thread>
    proc->pid = get_pid(); // 为新的线程创建pid
c0108dfa:	e8 d5 fa ff ff       	call   c01088d4 <get_pid>
c0108dff:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0108e02:	89 42 04             	mov    %eax,0x4(%edx)
    hash_proc(proc); //建立 hash 映射
c0108e05:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108e08:	89 04 24             	mov    %eax,(%esp)
c0108e0b:	e8 49 fc ff ff       	call   c0108a59 <hash_proc>
	// 将线程放入使用hash组织的链表中，便于加速以后对某个指定的线程的查找
    nr_process ++; // 全局线程的数目+1
c0108e10:	a1 40 a0 12 c0       	mov    0xc012a040,%eax
c0108e15:	83 c0 01             	add    $0x1,%eax
c0108e18:	a3 40 a0 12 c0       	mov    %eax,0xc012a040
    list_add(&proc_list, &proc->list_link); 
c0108e1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108e20:	83 c0 58             	add    $0x58,%eax
c0108e23:	c7 45 ec 5c a1 12 c0 	movl   $0xc012a15c,-0x14(%ebp)
c0108e2a:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108e2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108e30:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108e33:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108e36:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_add(elm, listelm, listelm->next);
c0108e39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108e3c:	8b 40 04             	mov    0x4(%eax),%eax
c0108e3f:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108e42:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0108e45:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108e48:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0108e4b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    prev->next = next->prev = elm;
c0108e4e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0108e51:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0108e54:	89 10                	mov    %edx,(%eax)
c0108e56:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0108e59:	8b 10                	mov    (%eax),%edx
c0108e5b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108e5e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0108e61:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108e64:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0108e67:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0108e6a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108e6d:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0108e70:	89 10                	mov    %edx,(%eax)
	//将线程加入到所有线程的链表中
    wakeup_proc(proc); // 唤醒该线程
c0108e72:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108e75:	89 04 24             	mov    %eax,(%esp)
c0108e78:	e8 9d 02 00 00       	call   c010911a <wakeup_proc>
    ret = proc->pid; // 返回新线程的pid
c0108e7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108e80:	8b 40 04             	mov    0x4(%eax),%eax
c0108e83:	89 45 f4             	mov    %eax,-0xc(%ebp)
fork_out:
    return ret;
c0108e86:	8b 45 f4             	mov    -0xc(%ebp),%eax
bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}
c0108e89:	c9                   	leave  
c0108e8a:	c3                   	ret    

c0108e8b <do_exit>:
// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int
do_exit(int error_code) {
c0108e8b:	55                   	push   %ebp
c0108e8c:	89 e5                	mov    %esp,%ebp
c0108e8e:	83 ec 18             	sub    $0x18,%esp
    panic("process exit!!.\n");
c0108e91:	c7 44 24 08 20 be 10 	movl   $0xc010be20,0x8(%esp)
c0108e98:	c0 
c0108e99:	c7 44 24 04 55 01 00 	movl   $0x155,0x4(%esp)
c0108ea0:	00 
c0108ea1:	c7 04 24 d1 bd 10 c0 	movl   $0xc010bdd1,(%esp)
c0108ea8:	e8 53 75 ff ff       	call   c0100400 <__panic>

c0108ead <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
c0108ead:	55                   	push   %ebp
c0108eae:	89 e5                	mov    %esp,%ebp
c0108eb0:	83 ec 18             	sub    $0x18,%esp
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
c0108eb3:	a1 28 80 12 c0       	mov    0xc0128028,%eax
c0108eb8:	89 04 24             	mov    %eax,(%esp)
c0108ebb:	e8 d2 f9 ff ff       	call   c0108892 <get_proc_name>
c0108ec0:	8b 15 28 80 12 c0    	mov    0xc0128028,%edx
c0108ec6:	8b 52 04             	mov    0x4(%edx),%edx
c0108ec9:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108ecd:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108ed1:	c7 04 24 34 be 10 c0 	movl   $0xc010be34,(%esp)
c0108ed8:	e8 cc 73 ff ff       	call   c01002a9 <cprintf>
    cprintf("To U: \"%s\".\n", (const char *)arg);
c0108edd:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ee0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108ee4:	c7 04 24 5a be 10 c0 	movl   $0xc010be5a,(%esp)
c0108eeb:	e8 b9 73 ff ff       	call   c01002a9 <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
c0108ef0:	c7 04 24 67 be 10 c0 	movl   $0xc010be67,(%esp)
c0108ef7:	e8 ad 73 ff ff       	call   c01002a9 <cprintf>
    return 0;
c0108efc:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108f01:	c9                   	leave  
c0108f02:	c3                   	ret    

c0108f03 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
c0108f03:	55                   	push   %ebp
c0108f04:	89 e5                	mov    %esp,%ebp
c0108f06:	83 ec 28             	sub    $0x28,%esp
c0108f09:	c7 45 ec 5c a1 12 c0 	movl   $0xc012a15c,-0x14(%ebp)
    elm->prev = elm->next = elm;
c0108f10:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108f13:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108f16:	89 50 04             	mov    %edx,0x4(%eax)
c0108f19:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108f1c:	8b 50 04             	mov    0x4(%eax),%edx
c0108f1f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108f22:	89 10                	mov    %edx,(%eax)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c0108f24:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0108f2b:	eb 26                	jmp    c0108f53 <proc_init+0x50>
        list_init(hash_list + i);
c0108f2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108f30:	c1 e0 03             	shl    $0x3,%eax
c0108f33:	05 40 80 12 c0       	add    $0xc0128040,%eax
c0108f38:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108f3b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108f3e:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0108f41:	89 50 04             	mov    %edx,0x4(%eax)
c0108f44:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108f47:	8b 50 04             	mov    0x4(%eax),%edx
c0108f4a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108f4d:	89 10                	mov    %edx,(%eax)
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c0108f4f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0108f53:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
c0108f5a:	7e d1                	jle    c0108f2d <proc_init+0x2a>
    }

    if ((idleproc = alloc_proc()) == NULL) {
c0108f5c:	e8 29 f8 ff ff       	call   c010878a <alloc_proc>
c0108f61:	a3 20 80 12 c0       	mov    %eax,0xc0128020
c0108f66:	a1 20 80 12 c0       	mov    0xc0128020,%eax
c0108f6b:	85 c0                	test   %eax,%eax
c0108f6d:	75 1c                	jne    c0108f8b <proc_init+0x88>
        panic("cannot alloc idleproc.\n");
c0108f6f:	c7 44 24 08 83 be 10 	movl   $0xc010be83,0x8(%esp)
c0108f76:	c0 
c0108f77:	c7 44 24 04 6d 01 00 	movl   $0x16d,0x4(%esp)
c0108f7e:	00 
c0108f7f:	c7 04 24 d1 bd 10 c0 	movl   $0xc010bdd1,(%esp)
c0108f86:	e8 75 74 ff ff       	call   c0100400 <__panic>
    }

    idleproc->pid = 0;
c0108f8b:	a1 20 80 12 c0       	mov    0xc0128020,%eax
c0108f90:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    idleproc->state = PROC_RUNNABLE;
c0108f97:	a1 20 80 12 c0       	mov    0xc0128020,%eax
c0108f9c:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
    idleproc->kstack = (uintptr_t)bootstack;
c0108fa2:	a1 20 80 12 c0       	mov    0xc0128020,%eax
c0108fa7:	ba 00 20 12 c0       	mov    $0xc0122000,%edx
c0108fac:	89 50 0c             	mov    %edx,0xc(%eax)
    idleproc->need_resched = 1;
c0108faf:	a1 20 80 12 c0       	mov    0xc0128020,%eax
c0108fb4:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    set_proc_name(idleproc, "idle");
c0108fbb:	a1 20 80 12 c0       	mov    0xc0128020,%eax
c0108fc0:	c7 44 24 04 9b be 10 	movl   $0xc010be9b,0x4(%esp)
c0108fc7:	c0 
c0108fc8:	89 04 24             	mov    %eax,(%esp)
c0108fcb:	e8 7f f8 ff ff       	call   c010884f <set_proc_name>
    nr_process ++;
c0108fd0:	a1 40 a0 12 c0       	mov    0xc012a040,%eax
c0108fd5:	83 c0 01             	add    $0x1,%eax
c0108fd8:	a3 40 a0 12 c0       	mov    %eax,0xc012a040

    current = idleproc;
c0108fdd:	a1 20 80 12 c0       	mov    0xc0128020,%eax
c0108fe2:	a3 28 80 12 c0       	mov    %eax,0xc0128028

    int pid = kernel_thread(init_main, "Hello world!!", 0);
c0108fe7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0108fee:	00 
c0108fef:	c7 44 24 04 a0 be 10 	movl   $0xc010bea0,0x4(%esp)
c0108ff6:	c0 
c0108ff7:	c7 04 24 ad 8e 10 c0 	movl   $0xc0108ead,(%esp)
c0108ffe:	e8 44 fb ff ff       	call   c0108b47 <kernel_thread>
c0109003:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (pid <= 0) {
c0109006:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010900a:	7f 1c                	jg     c0109028 <proc_init+0x125>
        panic("create init_main failed.\n");
c010900c:	c7 44 24 08 ae be 10 	movl   $0xc010beae,0x8(%esp)
c0109013:	c0 
c0109014:	c7 44 24 04 7b 01 00 	movl   $0x17b,0x4(%esp)
c010901b:	00 
c010901c:	c7 04 24 d1 bd 10 c0 	movl   $0xc010bdd1,(%esp)
c0109023:	e8 d8 73 ff ff       	call   c0100400 <__panic>
    }

    initproc = find_proc(pid);
c0109028:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010902b:	89 04 24             	mov    %eax,(%esp)
c010902e:	e8 a2 fa ff ff       	call   c0108ad5 <find_proc>
c0109033:	a3 24 80 12 c0       	mov    %eax,0xc0128024
    set_proc_name(initproc, "init");
c0109038:	a1 24 80 12 c0       	mov    0xc0128024,%eax
c010903d:	c7 44 24 04 c8 be 10 	movl   $0xc010bec8,0x4(%esp)
c0109044:	c0 
c0109045:	89 04 24             	mov    %eax,(%esp)
c0109048:	e8 02 f8 ff ff       	call   c010884f <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
c010904d:	a1 20 80 12 c0       	mov    0xc0128020,%eax
c0109052:	85 c0                	test   %eax,%eax
c0109054:	74 0c                	je     c0109062 <proc_init+0x15f>
c0109056:	a1 20 80 12 c0       	mov    0xc0128020,%eax
c010905b:	8b 40 04             	mov    0x4(%eax),%eax
c010905e:	85 c0                	test   %eax,%eax
c0109060:	74 24                	je     c0109086 <proc_init+0x183>
c0109062:	c7 44 24 0c d0 be 10 	movl   $0xc010bed0,0xc(%esp)
c0109069:	c0 
c010906a:	c7 44 24 08 bc bd 10 	movl   $0xc010bdbc,0x8(%esp)
c0109071:	c0 
c0109072:	c7 44 24 04 81 01 00 	movl   $0x181,0x4(%esp)
c0109079:	00 
c010907a:	c7 04 24 d1 bd 10 c0 	movl   $0xc010bdd1,(%esp)
c0109081:	e8 7a 73 ff ff       	call   c0100400 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
c0109086:	a1 24 80 12 c0       	mov    0xc0128024,%eax
c010908b:	85 c0                	test   %eax,%eax
c010908d:	74 0d                	je     c010909c <proc_init+0x199>
c010908f:	a1 24 80 12 c0       	mov    0xc0128024,%eax
c0109094:	8b 40 04             	mov    0x4(%eax),%eax
c0109097:	83 f8 01             	cmp    $0x1,%eax
c010909a:	74 24                	je     c01090c0 <proc_init+0x1bd>
c010909c:	c7 44 24 0c f8 be 10 	movl   $0xc010bef8,0xc(%esp)
c01090a3:	c0 
c01090a4:	c7 44 24 08 bc bd 10 	movl   $0xc010bdbc,0x8(%esp)
c01090ab:	c0 
c01090ac:	c7 44 24 04 82 01 00 	movl   $0x182,0x4(%esp)
c01090b3:	00 
c01090b4:	c7 04 24 d1 bd 10 c0 	movl   $0xc010bdd1,(%esp)
c01090bb:	e8 40 73 ff ff       	call   c0100400 <__panic>
}
c01090c0:	c9                   	leave  
c01090c1:	c3                   	ret    

c01090c2 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
c01090c2:	55                   	push   %ebp
c01090c3:	89 e5                	mov    %esp,%ebp
c01090c5:	83 ec 08             	sub    $0x8,%esp
    while (1) {
        if (current->need_resched) {
c01090c8:	a1 28 80 12 c0       	mov    0xc0128028,%eax
c01090cd:	8b 40 10             	mov    0x10(%eax),%eax
c01090d0:	85 c0                	test   %eax,%eax
c01090d2:	74 07                	je     c01090db <cpu_idle+0x19>
            schedule();
c01090d4:	e8 8a 00 00 00       	call   c0109163 <schedule>
        }
    }
c01090d9:	eb ed                	jmp    c01090c8 <cpu_idle+0x6>
c01090db:	eb eb                	jmp    c01090c8 <cpu_idle+0x6>

c01090dd <__intr_save>:
__intr_save(void) {
c01090dd:	55                   	push   %ebp
c01090de:	89 e5                	mov    %esp,%ebp
c01090e0:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01090e3:	9c                   	pushf  
c01090e4:	58                   	pop    %eax
c01090e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01090e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01090eb:	25 00 02 00 00       	and    $0x200,%eax
c01090f0:	85 c0                	test   %eax,%eax
c01090f2:	74 0c                	je     c0109100 <__intr_save+0x23>
        intr_disable();
c01090f4:	e8 24 90 ff ff       	call   c010211d <intr_disable>
        return 1;
c01090f9:	b8 01 00 00 00       	mov    $0x1,%eax
c01090fe:	eb 05                	jmp    c0109105 <__intr_save+0x28>
    return 0;
c0109100:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109105:	c9                   	leave  
c0109106:	c3                   	ret    

c0109107 <__intr_restore>:
__intr_restore(bool flag) {
c0109107:	55                   	push   %ebp
c0109108:	89 e5                	mov    %esp,%ebp
c010910a:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c010910d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109111:	74 05                	je     c0109118 <__intr_restore+0x11>
        intr_enable();
c0109113:	e8 ff 8f ff ff       	call   c0102117 <intr_enable>
}
c0109118:	c9                   	leave  
c0109119:	c3                   	ret    

c010911a <wakeup_proc>:
#include <proc.h>
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
c010911a:	55                   	push   %ebp
c010911b:	89 e5                	mov    %esp,%ebp
c010911d:	83 ec 18             	sub    $0x18,%esp
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
c0109120:	8b 45 08             	mov    0x8(%ebp),%eax
c0109123:	8b 00                	mov    (%eax),%eax
c0109125:	83 f8 03             	cmp    $0x3,%eax
c0109128:	74 0a                	je     c0109134 <wakeup_proc+0x1a>
c010912a:	8b 45 08             	mov    0x8(%ebp),%eax
c010912d:	8b 00                	mov    (%eax),%eax
c010912f:	83 f8 02             	cmp    $0x2,%eax
c0109132:	75 24                	jne    c0109158 <wakeup_proc+0x3e>
c0109134:	c7 44 24 0c 20 bf 10 	movl   $0xc010bf20,0xc(%esp)
c010913b:	c0 
c010913c:	c7 44 24 08 5b bf 10 	movl   $0xc010bf5b,0x8(%esp)
c0109143:	c0 
c0109144:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
c010914b:	00 
c010914c:	c7 04 24 70 bf 10 c0 	movl   $0xc010bf70,(%esp)
c0109153:	e8 a8 72 ff ff       	call   c0100400 <__panic>
    proc->state = PROC_RUNNABLE;
c0109158:	8b 45 08             	mov    0x8(%ebp),%eax
c010915b:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
}
c0109161:	c9                   	leave  
c0109162:	c3                   	ret    

c0109163 <schedule>:

void
schedule(void) {
c0109163:	55                   	push   %ebp
c0109164:	89 e5                	mov    %esp,%ebp
c0109166:	83 ec 38             	sub    $0x38,%esp
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
c0109169:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    local_intr_save(intr_flag);
c0109170:	e8 68 ff ff ff       	call   c01090dd <__intr_save>
c0109175:	89 45 ec             	mov    %eax,-0x14(%ebp)
    {
        current->need_resched = 0;
c0109178:	a1 28 80 12 c0       	mov    0xc0128028,%eax
c010917d:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
c0109184:	8b 15 28 80 12 c0    	mov    0xc0128028,%edx
c010918a:	a1 20 80 12 c0       	mov    0xc0128020,%eax
c010918f:	39 c2                	cmp    %eax,%edx
c0109191:	74 0a                	je     c010919d <schedule+0x3a>
c0109193:	a1 28 80 12 c0       	mov    0xc0128028,%eax
c0109198:	83 c0 58             	add    $0x58,%eax
c010919b:	eb 05                	jmp    c01091a2 <schedule+0x3f>
c010919d:	b8 5c a1 12 c0       	mov    $0xc012a15c,%eax
c01091a2:	89 45 e8             	mov    %eax,-0x18(%ebp)
        le = last;
c01091a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01091a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01091ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01091ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c01091b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01091b4:	8b 40 04             	mov    0x4(%eax),%eax
        do {
            if ((le = list_next(le)) != &proc_list) {
c01091b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01091ba:	81 7d f4 5c a1 12 c0 	cmpl   $0xc012a15c,-0xc(%ebp)
c01091c1:	74 15                	je     c01091d8 <schedule+0x75>
                next = le2proc(le, list_link);
c01091c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01091c6:	83 e8 58             	sub    $0x58,%eax
c01091c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
                if (next->state == PROC_RUNNABLE) {
c01091cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01091cf:	8b 00                	mov    (%eax),%eax
c01091d1:	83 f8 02             	cmp    $0x2,%eax
c01091d4:	75 02                	jne    c01091d8 <schedule+0x75>
                    break;
c01091d6:	eb 08                	jmp    c01091e0 <schedule+0x7d>
                }
            }
        } while (le != last);
c01091d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01091db:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c01091de:	75 cb                	jne    c01091ab <schedule+0x48>
        if (next == NULL || next->state != PROC_RUNNABLE) {
c01091e0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01091e4:	74 0a                	je     c01091f0 <schedule+0x8d>
c01091e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01091e9:	8b 00                	mov    (%eax),%eax
c01091eb:	83 f8 02             	cmp    $0x2,%eax
c01091ee:	74 08                	je     c01091f8 <schedule+0x95>
            next = idleproc;
c01091f0:	a1 20 80 12 c0       	mov    0xc0128020,%eax
c01091f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        next->runs ++;
c01091f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01091fb:	8b 40 08             	mov    0x8(%eax),%eax
c01091fe:	8d 50 01             	lea    0x1(%eax),%edx
c0109201:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109204:	89 50 08             	mov    %edx,0x8(%eax)
        if (next != current) {
c0109207:	a1 28 80 12 c0       	mov    0xc0128028,%eax
c010920c:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010920f:	74 0b                	je     c010921c <schedule+0xb9>
            proc_run(next);
c0109211:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109214:	89 04 24             	mov    %eax,(%esp)
c0109217:	e8 b0 f7 ff ff       	call   c01089cc <proc_run>
        }
    }
    local_intr_restore(intr_flag);
c010921c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010921f:	89 04 24             	mov    %eax,(%esp)
c0109222:	e8 e0 fe ff ff       	call   c0109107 <__intr_restore>
}
c0109227:	c9                   	leave  
c0109228:	c3                   	ret    

c0109229 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c0109229:	55                   	push   %ebp
c010922a:	89 e5                	mov    %esp,%ebp
c010922c:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010922f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0109236:	eb 04                	jmp    c010923c <strlen+0x13>
        cnt ++;
c0109238:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (*s ++ != '\0') {
c010923c:	8b 45 08             	mov    0x8(%ebp),%eax
c010923f:	8d 50 01             	lea    0x1(%eax),%edx
c0109242:	89 55 08             	mov    %edx,0x8(%ebp)
c0109245:	0f b6 00             	movzbl (%eax),%eax
c0109248:	84 c0                	test   %al,%al
c010924a:	75 ec                	jne    c0109238 <strlen+0xf>
    }
    return cnt;
c010924c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010924f:	c9                   	leave  
c0109250:	c3                   	ret    

c0109251 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0109251:	55                   	push   %ebp
c0109252:	89 e5                	mov    %esp,%ebp
c0109254:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0109257:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c010925e:	eb 04                	jmp    c0109264 <strnlen+0x13>
        cnt ++;
c0109260:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0109264:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109267:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010926a:	73 10                	jae    c010927c <strnlen+0x2b>
c010926c:	8b 45 08             	mov    0x8(%ebp),%eax
c010926f:	8d 50 01             	lea    0x1(%eax),%edx
c0109272:	89 55 08             	mov    %edx,0x8(%ebp)
c0109275:	0f b6 00             	movzbl (%eax),%eax
c0109278:	84 c0                	test   %al,%al
c010927a:	75 e4                	jne    c0109260 <strnlen+0xf>
    }
    return cnt;
c010927c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010927f:	c9                   	leave  
c0109280:	c3                   	ret    

c0109281 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0109281:	55                   	push   %ebp
c0109282:	89 e5                	mov    %esp,%ebp
c0109284:	57                   	push   %edi
c0109285:	56                   	push   %esi
c0109286:	83 ec 20             	sub    $0x20,%esp
c0109289:	8b 45 08             	mov    0x8(%ebp),%eax
c010928c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010928f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109292:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0109295:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109298:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010929b:	89 d1                	mov    %edx,%ecx
c010929d:	89 c2                	mov    %eax,%edx
c010929f:	89 ce                	mov    %ecx,%esi
c01092a1:	89 d7                	mov    %edx,%edi
c01092a3:	ac                   	lods   %ds:(%esi),%al
c01092a4:	aa                   	stos   %al,%es:(%edi)
c01092a5:	84 c0                	test   %al,%al
c01092a7:	75 fa                	jne    c01092a3 <strcpy+0x22>
c01092a9:	89 fa                	mov    %edi,%edx
c01092ab:	89 f1                	mov    %esi,%ecx
c01092ad:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c01092b0:	89 55 e8             	mov    %edx,-0x18(%ebp)
c01092b3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c01092b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c01092b9:	83 c4 20             	add    $0x20,%esp
c01092bc:	5e                   	pop    %esi
c01092bd:	5f                   	pop    %edi
c01092be:	5d                   	pop    %ebp
c01092bf:	c3                   	ret    

c01092c0 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c01092c0:	55                   	push   %ebp
c01092c1:	89 e5                	mov    %esp,%ebp
c01092c3:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c01092c6:	8b 45 08             	mov    0x8(%ebp),%eax
c01092c9:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c01092cc:	eb 21                	jmp    c01092ef <strncpy+0x2f>
        if ((*p = *src) != '\0') {
c01092ce:	8b 45 0c             	mov    0xc(%ebp),%eax
c01092d1:	0f b6 10             	movzbl (%eax),%edx
c01092d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01092d7:	88 10                	mov    %dl,(%eax)
c01092d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01092dc:	0f b6 00             	movzbl (%eax),%eax
c01092df:	84 c0                	test   %al,%al
c01092e1:	74 04                	je     c01092e7 <strncpy+0x27>
            src ++;
c01092e3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
c01092e7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c01092eb:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    while (len > 0) {
c01092ef:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01092f3:	75 d9                	jne    c01092ce <strncpy+0xe>
    }
    return dst;
c01092f5:	8b 45 08             	mov    0x8(%ebp),%eax
}
c01092f8:	c9                   	leave  
c01092f9:	c3                   	ret    

c01092fa <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c01092fa:	55                   	push   %ebp
c01092fb:	89 e5                	mov    %esp,%ebp
c01092fd:	57                   	push   %edi
c01092fe:	56                   	push   %esi
c01092ff:	83 ec 20             	sub    $0x20,%esp
c0109302:	8b 45 08             	mov    0x8(%ebp),%eax
c0109305:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109308:	8b 45 0c             	mov    0xc(%ebp),%eax
c010930b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c010930e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109311:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109314:	89 d1                	mov    %edx,%ecx
c0109316:	89 c2                	mov    %eax,%edx
c0109318:	89 ce                	mov    %ecx,%esi
c010931a:	89 d7                	mov    %edx,%edi
c010931c:	ac                   	lods   %ds:(%esi),%al
c010931d:	ae                   	scas   %es:(%edi),%al
c010931e:	75 08                	jne    c0109328 <strcmp+0x2e>
c0109320:	84 c0                	test   %al,%al
c0109322:	75 f8                	jne    c010931c <strcmp+0x22>
c0109324:	31 c0                	xor    %eax,%eax
c0109326:	eb 04                	jmp    c010932c <strcmp+0x32>
c0109328:	19 c0                	sbb    %eax,%eax
c010932a:	0c 01                	or     $0x1,%al
c010932c:	89 fa                	mov    %edi,%edx
c010932e:	89 f1                	mov    %esi,%ecx
c0109330:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109333:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0109336:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c0109339:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c010933c:	83 c4 20             	add    $0x20,%esp
c010933f:	5e                   	pop    %esi
c0109340:	5f                   	pop    %edi
c0109341:	5d                   	pop    %ebp
c0109342:	c3                   	ret    

c0109343 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c0109343:	55                   	push   %ebp
c0109344:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0109346:	eb 0c                	jmp    c0109354 <strncmp+0x11>
        n --, s1 ++, s2 ++;
c0109348:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010934c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0109350:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0109354:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0109358:	74 1a                	je     c0109374 <strncmp+0x31>
c010935a:	8b 45 08             	mov    0x8(%ebp),%eax
c010935d:	0f b6 00             	movzbl (%eax),%eax
c0109360:	84 c0                	test   %al,%al
c0109362:	74 10                	je     c0109374 <strncmp+0x31>
c0109364:	8b 45 08             	mov    0x8(%ebp),%eax
c0109367:	0f b6 10             	movzbl (%eax),%edx
c010936a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010936d:	0f b6 00             	movzbl (%eax),%eax
c0109370:	38 c2                	cmp    %al,%dl
c0109372:	74 d4                	je     c0109348 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c0109374:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0109378:	74 18                	je     c0109392 <strncmp+0x4f>
c010937a:	8b 45 08             	mov    0x8(%ebp),%eax
c010937d:	0f b6 00             	movzbl (%eax),%eax
c0109380:	0f b6 d0             	movzbl %al,%edx
c0109383:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109386:	0f b6 00             	movzbl (%eax),%eax
c0109389:	0f b6 c0             	movzbl %al,%eax
c010938c:	29 c2                	sub    %eax,%edx
c010938e:	89 d0                	mov    %edx,%eax
c0109390:	eb 05                	jmp    c0109397 <strncmp+0x54>
c0109392:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109397:	5d                   	pop    %ebp
c0109398:	c3                   	ret    

c0109399 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0109399:	55                   	push   %ebp
c010939a:	89 e5                	mov    %esp,%ebp
c010939c:	83 ec 04             	sub    $0x4,%esp
c010939f:	8b 45 0c             	mov    0xc(%ebp),%eax
c01093a2:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c01093a5:	eb 14                	jmp    c01093bb <strchr+0x22>
        if (*s == c) {
c01093a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01093aa:	0f b6 00             	movzbl (%eax),%eax
c01093ad:	3a 45 fc             	cmp    -0x4(%ebp),%al
c01093b0:	75 05                	jne    c01093b7 <strchr+0x1e>
            return (char *)s;
c01093b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01093b5:	eb 13                	jmp    c01093ca <strchr+0x31>
        }
        s ++;
c01093b7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
c01093bb:	8b 45 08             	mov    0x8(%ebp),%eax
c01093be:	0f b6 00             	movzbl (%eax),%eax
c01093c1:	84 c0                	test   %al,%al
c01093c3:	75 e2                	jne    c01093a7 <strchr+0xe>
    }
    return NULL;
c01093c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01093ca:	c9                   	leave  
c01093cb:	c3                   	ret    

c01093cc <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c01093cc:	55                   	push   %ebp
c01093cd:	89 e5                	mov    %esp,%ebp
c01093cf:	83 ec 04             	sub    $0x4,%esp
c01093d2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01093d5:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c01093d8:	eb 11                	jmp    c01093eb <strfind+0x1f>
        if (*s == c) {
c01093da:	8b 45 08             	mov    0x8(%ebp),%eax
c01093dd:	0f b6 00             	movzbl (%eax),%eax
c01093e0:	3a 45 fc             	cmp    -0x4(%ebp),%al
c01093e3:	75 02                	jne    c01093e7 <strfind+0x1b>
            break;
c01093e5:	eb 0e                	jmp    c01093f5 <strfind+0x29>
        }
        s ++;
c01093e7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
c01093eb:	8b 45 08             	mov    0x8(%ebp),%eax
c01093ee:	0f b6 00             	movzbl (%eax),%eax
c01093f1:	84 c0                	test   %al,%al
c01093f3:	75 e5                	jne    c01093da <strfind+0xe>
    }
    return (char *)s;
c01093f5:	8b 45 08             	mov    0x8(%ebp),%eax
}
c01093f8:	c9                   	leave  
c01093f9:	c3                   	ret    

c01093fa <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c01093fa:	55                   	push   %ebp
c01093fb:	89 e5                	mov    %esp,%ebp
c01093fd:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0109400:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0109407:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c010940e:	eb 04                	jmp    c0109414 <strtol+0x1a>
        s ++;
c0109410:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c0109414:	8b 45 08             	mov    0x8(%ebp),%eax
c0109417:	0f b6 00             	movzbl (%eax),%eax
c010941a:	3c 20                	cmp    $0x20,%al
c010941c:	74 f2                	je     c0109410 <strtol+0x16>
c010941e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109421:	0f b6 00             	movzbl (%eax),%eax
c0109424:	3c 09                	cmp    $0x9,%al
c0109426:	74 e8                	je     c0109410 <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
c0109428:	8b 45 08             	mov    0x8(%ebp),%eax
c010942b:	0f b6 00             	movzbl (%eax),%eax
c010942e:	3c 2b                	cmp    $0x2b,%al
c0109430:	75 06                	jne    c0109438 <strtol+0x3e>
        s ++;
c0109432:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0109436:	eb 15                	jmp    c010944d <strtol+0x53>
    }
    else if (*s == '-') {
c0109438:	8b 45 08             	mov    0x8(%ebp),%eax
c010943b:	0f b6 00             	movzbl (%eax),%eax
c010943e:	3c 2d                	cmp    $0x2d,%al
c0109440:	75 0b                	jne    c010944d <strtol+0x53>
        s ++, neg = 1;
c0109442:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0109446:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c010944d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0109451:	74 06                	je     c0109459 <strtol+0x5f>
c0109453:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c0109457:	75 24                	jne    c010947d <strtol+0x83>
c0109459:	8b 45 08             	mov    0x8(%ebp),%eax
c010945c:	0f b6 00             	movzbl (%eax),%eax
c010945f:	3c 30                	cmp    $0x30,%al
c0109461:	75 1a                	jne    c010947d <strtol+0x83>
c0109463:	8b 45 08             	mov    0x8(%ebp),%eax
c0109466:	83 c0 01             	add    $0x1,%eax
c0109469:	0f b6 00             	movzbl (%eax),%eax
c010946c:	3c 78                	cmp    $0x78,%al
c010946e:	75 0d                	jne    c010947d <strtol+0x83>
        s += 2, base = 16;
c0109470:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0109474:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c010947b:	eb 2a                	jmp    c01094a7 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
c010947d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0109481:	75 17                	jne    c010949a <strtol+0xa0>
c0109483:	8b 45 08             	mov    0x8(%ebp),%eax
c0109486:	0f b6 00             	movzbl (%eax),%eax
c0109489:	3c 30                	cmp    $0x30,%al
c010948b:	75 0d                	jne    c010949a <strtol+0xa0>
        s ++, base = 8;
c010948d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0109491:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0109498:	eb 0d                	jmp    c01094a7 <strtol+0xad>
    }
    else if (base == 0) {
c010949a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010949e:	75 07                	jne    c01094a7 <strtol+0xad>
        base = 10;
c01094a0:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c01094a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01094aa:	0f b6 00             	movzbl (%eax),%eax
c01094ad:	3c 2f                	cmp    $0x2f,%al
c01094af:	7e 1b                	jle    c01094cc <strtol+0xd2>
c01094b1:	8b 45 08             	mov    0x8(%ebp),%eax
c01094b4:	0f b6 00             	movzbl (%eax),%eax
c01094b7:	3c 39                	cmp    $0x39,%al
c01094b9:	7f 11                	jg     c01094cc <strtol+0xd2>
            dig = *s - '0';
c01094bb:	8b 45 08             	mov    0x8(%ebp),%eax
c01094be:	0f b6 00             	movzbl (%eax),%eax
c01094c1:	0f be c0             	movsbl %al,%eax
c01094c4:	83 e8 30             	sub    $0x30,%eax
c01094c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01094ca:	eb 48                	jmp    c0109514 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
c01094cc:	8b 45 08             	mov    0x8(%ebp),%eax
c01094cf:	0f b6 00             	movzbl (%eax),%eax
c01094d2:	3c 60                	cmp    $0x60,%al
c01094d4:	7e 1b                	jle    c01094f1 <strtol+0xf7>
c01094d6:	8b 45 08             	mov    0x8(%ebp),%eax
c01094d9:	0f b6 00             	movzbl (%eax),%eax
c01094dc:	3c 7a                	cmp    $0x7a,%al
c01094de:	7f 11                	jg     c01094f1 <strtol+0xf7>
            dig = *s - 'a' + 10;
c01094e0:	8b 45 08             	mov    0x8(%ebp),%eax
c01094e3:	0f b6 00             	movzbl (%eax),%eax
c01094e6:	0f be c0             	movsbl %al,%eax
c01094e9:	83 e8 57             	sub    $0x57,%eax
c01094ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01094ef:	eb 23                	jmp    c0109514 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c01094f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01094f4:	0f b6 00             	movzbl (%eax),%eax
c01094f7:	3c 40                	cmp    $0x40,%al
c01094f9:	7e 3d                	jle    c0109538 <strtol+0x13e>
c01094fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01094fe:	0f b6 00             	movzbl (%eax),%eax
c0109501:	3c 5a                	cmp    $0x5a,%al
c0109503:	7f 33                	jg     c0109538 <strtol+0x13e>
            dig = *s - 'A' + 10;
c0109505:	8b 45 08             	mov    0x8(%ebp),%eax
c0109508:	0f b6 00             	movzbl (%eax),%eax
c010950b:	0f be c0             	movsbl %al,%eax
c010950e:	83 e8 37             	sub    $0x37,%eax
c0109511:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0109514:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109517:	3b 45 10             	cmp    0x10(%ebp),%eax
c010951a:	7c 02                	jl     c010951e <strtol+0x124>
            break;
c010951c:	eb 1a                	jmp    c0109538 <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
c010951e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0109522:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109525:	0f af 45 10          	imul   0x10(%ebp),%eax
c0109529:	89 c2                	mov    %eax,%edx
c010952b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010952e:	01 d0                	add    %edx,%eax
c0109530:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c0109533:	e9 6f ff ff ff       	jmp    c01094a7 <strtol+0xad>

    if (endptr) {
c0109538:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010953c:	74 08                	je     c0109546 <strtol+0x14c>
        *endptr = (char *) s;
c010953e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109541:	8b 55 08             	mov    0x8(%ebp),%edx
c0109544:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0109546:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010954a:	74 07                	je     c0109553 <strtol+0x159>
c010954c:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010954f:	f7 d8                	neg    %eax
c0109551:	eb 03                	jmp    c0109556 <strtol+0x15c>
c0109553:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0109556:	c9                   	leave  
c0109557:	c3                   	ret    

c0109558 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0109558:	55                   	push   %ebp
c0109559:	89 e5                	mov    %esp,%ebp
c010955b:	57                   	push   %edi
c010955c:	83 ec 24             	sub    $0x24,%esp
c010955f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109562:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0109565:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c0109569:	8b 55 08             	mov    0x8(%ebp),%edx
c010956c:	89 55 f8             	mov    %edx,-0x8(%ebp)
c010956f:	88 45 f7             	mov    %al,-0x9(%ebp)
c0109572:	8b 45 10             	mov    0x10(%ebp),%eax
c0109575:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0109578:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c010957b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c010957f:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0109582:	89 d7                	mov    %edx,%edi
c0109584:	f3 aa                	rep stos %al,%es:(%edi)
c0109586:	89 fa                	mov    %edi,%edx
c0109588:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010958b:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c010958e:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0109591:	83 c4 24             	add    $0x24,%esp
c0109594:	5f                   	pop    %edi
c0109595:	5d                   	pop    %ebp
c0109596:	c3                   	ret    

c0109597 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0109597:	55                   	push   %ebp
c0109598:	89 e5                	mov    %esp,%ebp
c010959a:	57                   	push   %edi
c010959b:	56                   	push   %esi
c010959c:	53                   	push   %ebx
c010959d:	83 ec 30             	sub    $0x30,%esp
c01095a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01095a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01095a6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01095a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01095ac:	8b 45 10             	mov    0x10(%ebp),%eax
c01095af:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c01095b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01095b5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01095b8:	73 42                	jae    c01095fc <memmove+0x65>
c01095ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01095bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01095c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01095c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01095c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01095c9:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c01095cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01095cf:	c1 e8 02             	shr    $0x2,%eax
c01095d2:	89 c1                	mov    %eax,%ecx
    asm volatile (
c01095d4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01095d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01095da:	89 d7                	mov    %edx,%edi
c01095dc:	89 c6                	mov    %eax,%esi
c01095de:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c01095e0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c01095e3:	83 e1 03             	and    $0x3,%ecx
c01095e6:	74 02                	je     c01095ea <memmove+0x53>
c01095e8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c01095ea:	89 f0                	mov    %esi,%eax
c01095ec:	89 fa                	mov    %edi,%edx
c01095ee:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c01095f1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01095f4:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c01095f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01095fa:	eb 36                	jmp    c0109632 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c01095fc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01095ff:	8d 50 ff             	lea    -0x1(%eax),%edx
c0109602:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109605:	01 c2                	add    %eax,%edx
c0109607:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010960a:	8d 48 ff             	lea    -0x1(%eax),%ecx
c010960d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109610:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c0109613:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109616:	89 c1                	mov    %eax,%ecx
c0109618:	89 d8                	mov    %ebx,%eax
c010961a:	89 d6                	mov    %edx,%esi
c010961c:	89 c7                	mov    %eax,%edi
c010961e:	fd                   	std    
c010961f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0109621:	fc                   	cld    
c0109622:	89 f8                	mov    %edi,%eax
c0109624:	89 f2                	mov    %esi,%edx
c0109626:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c0109629:	89 55 c8             	mov    %edx,-0x38(%ebp)
c010962c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c010962f:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c0109632:	83 c4 30             	add    $0x30,%esp
c0109635:	5b                   	pop    %ebx
c0109636:	5e                   	pop    %esi
c0109637:	5f                   	pop    %edi
c0109638:	5d                   	pop    %ebp
c0109639:	c3                   	ret    

c010963a <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c010963a:	55                   	push   %ebp
c010963b:	89 e5                	mov    %esp,%ebp
c010963d:	57                   	push   %edi
c010963e:	56                   	push   %esi
c010963f:	83 ec 20             	sub    $0x20,%esp
c0109642:	8b 45 08             	mov    0x8(%ebp),%eax
c0109645:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109648:	8b 45 0c             	mov    0xc(%ebp),%eax
c010964b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010964e:	8b 45 10             	mov    0x10(%ebp),%eax
c0109651:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0109654:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109657:	c1 e8 02             	shr    $0x2,%eax
c010965a:	89 c1                	mov    %eax,%ecx
    asm volatile (
c010965c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010965f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109662:	89 d7                	mov    %edx,%edi
c0109664:	89 c6                	mov    %eax,%esi
c0109666:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0109668:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c010966b:	83 e1 03             	and    $0x3,%ecx
c010966e:	74 02                	je     c0109672 <memcpy+0x38>
c0109670:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0109672:	89 f0                	mov    %esi,%eax
c0109674:	89 fa                	mov    %edi,%edx
c0109676:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0109679:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010967c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c010967f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0109682:	83 c4 20             	add    $0x20,%esp
c0109685:	5e                   	pop    %esi
c0109686:	5f                   	pop    %edi
c0109687:	5d                   	pop    %ebp
c0109688:	c3                   	ret    

c0109689 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c0109689:	55                   	push   %ebp
c010968a:	89 e5                	mov    %esp,%ebp
c010968c:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c010968f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109692:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0109695:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109698:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c010969b:	eb 30                	jmp    c01096cd <memcmp+0x44>
        if (*s1 != *s2) {
c010969d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01096a0:	0f b6 10             	movzbl (%eax),%edx
c01096a3:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01096a6:	0f b6 00             	movzbl (%eax),%eax
c01096a9:	38 c2                	cmp    %al,%dl
c01096ab:	74 18                	je     c01096c5 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c01096ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01096b0:	0f b6 00             	movzbl (%eax),%eax
c01096b3:	0f b6 d0             	movzbl %al,%edx
c01096b6:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01096b9:	0f b6 00             	movzbl (%eax),%eax
c01096bc:	0f b6 c0             	movzbl %al,%eax
c01096bf:	29 c2                	sub    %eax,%edx
c01096c1:	89 d0                	mov    %edx,%eax
c01096c3:	eb 1a                	jmp    c01096df <memcmp+0x56>
        }
        s1 ++, s2 ++;
c01096c5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c01096c9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
    while (n -- > 0) {
c01096cd:	8b 45 10             	mov    0x10(%ebp),%eax
c01096d0:	8d 50 ff             	lea    -0x1(%eax),%edx
c01096d3:	89 55 10             	mov    %edx,0x10(%ebp)
c01096d6:	85 c0                	test   %eax,%eax
c01096d8:	75 c3                	jne    c010969d <memcmp+0x14>
    }
    return 0;
c01096da:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01096df:	c9                   	leave  
c01096e0:	c3                   	ret    

c01096e1 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c01096e1:	55                   	push   %ebp
c01096e2:	89 e5                	mov    %esp,%ebp
c01096e4:	83 ec 58             	sub    $0x58,%esp
c01096e7:	8b 45 10             	mov    0x10(%ebp),%eax
c01096ea:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01096ed:	8b 45 14             	mov    0x14(%ebp),%eax
c01096f0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c01096f3:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01096f6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01096f9:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01096fc:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c01096ff:	8b 45 18             	mov    0x18(%ebp),%eax
c0109702:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0109705:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109708:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010970b:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010970e:	89 55 f0             	mov    %edx,-0x10(%ebp)
c0109711:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109714:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109717:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010971b:	74 1c                	je     c0109739 <printnum+0x58>
c010971d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109720:	ba 00 00 00 00       	mov    $0x0,%edx
c0109725:	f7 75 e4             	divl   -0x1c(%ebp)
c0109728:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010972b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010972e:	ba 00 00 00 00       	mov    $0x0,%edx
c0109733:	f7 75 e4             	divl   -0x1c(%ebp)
c0109736:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109739:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010973c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010973f:	f7 75 e4             	divl   -0x1c(%ebp)
c0109742:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0109745:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0109748:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010974b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010974e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109751:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0109754:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109757:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c010975a:	8b 45 18             	mov    0x18(%ebp),%eax
c010975d:	ba 00 00 00 00       	mov    $0x0,%edx
c0109762:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0109765:	77 56                	ja     c01097bd <printnum+0xdc>
c0109767:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010976a:	72 05                	jb     c0109771 <printnum+0x90>
c010976c:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c010976f:	77 4c                	ja     c01097bd <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c0109771:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0109774:	8d 50 ff             	lea    -0x1(%eax),%edx
c0109777:	8b 45 20             	mov    0x20(%ebp),%eax
c010977a:	89 44 24 18          	mov    %eax,0x18(%esp)
c010977e:	89 54 24 14          	mov    %edx,0x14(%esp)
c0109782:	8b 45 18             	mov    0x18(%ebp),%eax
c0109785:	89 44 24 10          	mov    %eax,0x10(%esp)
c0109789:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010978c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010978f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109793:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0109797:	8b 45 0c             	mov    0xc(%ebp),%eax
c010979a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010979e:	8b 45 08             	mov    0x8(%ebp),%eax
c01097a1:	89 04 24             	mov    %eax,(%esp)
c01097a4:	e8 38 ff ff ff       	call   c01096e1 <printnum>
c01097a9:	eb 1c                	jmp    c01097c7 <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c01097ab:	8b 45 0c             	mov    0xc(%ebp),%eax
c01097ae:	89 44 24 04          	mov    %eax,0x4(%esp)
c01097b2:	8b 45 20             	mov    0x20(%ebp),%eax
c01097b5:	89 04 24             	mov    %eax,(%esp)
c01097b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01097bb:	ff d0                	call   *%eax
        while (-- width > 0)
c01097bd:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
c01097c1:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c01097c5:	7f e4                	jg     c01097ab <printnum+0xca>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c01097c7:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01097ca:	05 08 c0 10 c0       	add    $0xc010c008,%eax
c01097cf:	0f b6 00             	movzbl (%eax),%eax
c01097d2:	0f be c0             	movsbl %al,%eax
c01097d5:	8b 55 0c             	mov    0xc(%ebp),%edx
c01097d8:	89 54 24 04          	mov    %edx,0x4(%esp)
c01097dc:	89 04 24             	mov    %eax,(%esp)
c01097df:	8b 45 08             	mov    0x8(%ebp),%eax
c01097e2:	ff d0                	call   *%eax
}
c01097e4:	c9                   	leave  
c01097e5:	c3                   	ret    

c01097e6 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c01097e6:	55                   	push   %ebp
c01097e7:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01097e9:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01097ed:	7e 14                	jle    c0109803 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c01097ef:	8b 45 08             	mov    0x8(%ebp),%eax
c01097f2:	8b 00                	mov    (%eax),%eax
c01097f4:	8d 48 08             	lea    0x8(%eax),%ecx
c01097f7:	8b 55 08             	mov    0x8(%ebp),%edx
c01097fa:	89 0a                	mov    %ecx,(%edx)
c01097fc:	8b 50 04             	mov    0x4(%eax),%edx
c01097ff:	8b 00                	mov    (%eax),%eax
c0109801:	eb 30                	jmp    c0109833 <getuint+0x4d>
    }
    else if (lflag) {
c0109803:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0109807:	74 16                	je     c010981f <getuint+0x39>
        return va_arg(*ap, unsigned long);
c0109809:	8b 45 08             	mov    0x8(%ebp),%eax
c010980c:	8b 00                	mov    (%eax),%eax
c010980e:	8d 48 04             	lea    0x4(%eax),%ecx
c0109811:	8b 55 08             	mov    0x8(%ebp),%edx
c0109814:	89 0a                	mov    %ecx,(%edx)
c0109816:	8b 00                	mov    (%eax),%eax
c0109818:	ba 00 00 00 00       	mov    $0x0,%edx
c010981d:	eb 14                	jmp    c0109833 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c010981f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109822:	8b 00                	mov    (%eax),%eax
c0109824:	8d 48 04             	lea    0x4(%eax),%ecx
c0109827:	8b 55 08             	mov    0x8(%ebp),%edx
c010982a:	89 0a                	mov    %ecx,(%edx)
c010982c:	8b 00                	mov    (%eax),%eax
c010982e:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c0109833:	5d                   	pop    %ebp
c0109834:	c3                   	ret    

c0109835 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c0109835:	55                   	push   %ebp
c0109836:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0109838:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010983c:	7e 14                	jle    c0109852 <getint+0x1d>
        return va_arg(*ap, long long);
c010983e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109841:	8b 00                	mov    (%eax),%eax
c0109843:	8d 48 08             	lea    0x8(%eax),%ecx
c0109846:	8b 55 08             	mov    0x8(%ebp),%edx
c0109849:	89 0a                	mov    %ecx,(%edx)
c010984b:	8b 50 04             	mov    0x4(%eax),%edx
c010984e:	8b 00                	mov    (%eax),%eax
c0109850:	eb 28                	jmp    c010987a <getint+0x45>
    }
    else if (lflag) {
c0109852:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0109856:	74 12                	je     c010986a <getint+0x35>
        return va_arg(*ap, long);
c0109858:	8b 45 08             	mov    0x8(%ebp),%eax
c010985b:	8b 00                	mov    (%eax),%eax
c010985d:	8d 48 04             	lea    0x4(%eax),%ecx
c0109860:	8b 55 08             	mov    0x8(%ebp),%edx
c0109863:	89 0a                	mov    %ecx,(%edx)
c0109865:	8b 00                	mov    (%eax),%eax
c0109867:	99                   	cltd   
c0109868:	eb 10                	jmp    c010987a <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c010986a:	8b 45 08             	mov    0x8(%ebp),%eax
c010986d:	8b 00                	mov    (%eax),%eax
c010986f:	8d 48 04             	lea    0x4(%eax),%ecx
c0109872:	8b 55 08             	mov    0x8(%ebp),%edx
c0109875:	89 0a                	mov    %ecx,(%edx)
c0109877:	8b 00                	mov    (%eax),%eax
c0109879:	99                   	cltd   
    }
}
c010987a:	5d                   	pop    %ebp
c010987b:	c3                   	ret    

c010987c <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c010987c:	55                   	push   %ebp
c010987d:	89 e5                	mov    %esp,%ebp
c010987f:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c0109882:	8d 45 14             	lea    0x14(%ebp),%eax
c0109885:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c0109888:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010988b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010988f:	8b 45 10             	mov    0x10(%ebp),%eax
c0109892:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109896:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109899:	89 44 24 04          	mov    %eax,0x4(%esp)
c010989d:	8b 45 08             	mov    0x8(%ebp),%eax
c01098a0:	89 04 24             	mov    %eax,(%esp)
c01098a3:	e8 02 00 00 00       	call   c01098aa <vprintfmt>
    va_end(ap);
}
c01098a8:	c9                   	leave  
c01098a9:	c3                   	ret    

c01098aa <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c01098aa:	55                   	push   %ebp
c01098ab:	89 e5                	mov    %esp,%ebp
c01098ad:	56                   	push   %esi
c01098ae:	53                   	push   %ebx
c01098af:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c01098b2:	eb 18                	jmp    c01098cc <vprintfmt+0x22>
            if (ch == '\0') {
c01098b4:	85 db                	test   %ebx,%ebx
c01098b6:	75 05                	jne    c01098bd <vprintfmt+0x13>
                return;
c01098b8:	e9 d1 03 00 00       	jmp    c0109c8e <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
c01098bd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01098c0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01098c4:	89 1c 24             	mov    %ebx,(%esp)
c01098c7:	8b 45 08             	mov    0x8(%ebp),%eax
c01098ca:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c01098cc:	8b 45 10             	mov    0x10(%ebp),%eax
c01098cf:	8d 50 01             	lea    0x1(%eax),%edx
c01098d2:	89 55 10             	mov    %edx,0x10(%ebp)
c01098d5:	0f b6 00             	movzbl (%eax),%eax
c01098d8:	0f b6 d8             	movzbl %al,%ebx
c01098db:	83 fb 25             	cmp    $0x25,%ebx
c01098de:	75 d4                	jne    c01098b4 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
c01098e0:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c01098e4:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c01098eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01098ee:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c01098f1:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01098f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01098fb:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c01098fe:	8b 45 10             	mov    0x10(%ebp),%eax
c0109901:	8d 50 01             	lea    0x1(%eax),%edx
c0109904:	89 55 10             	mov    %edx,0x10(%ebp)
c0109907:	0f b6 00             	movzbl (%eax),%eax
c010990a:	0f b6 d8             	movzbl %al,%ebx
c010990d:	8d 43 dd             	lea    -0x23(%ebx),%eax
c0109910:	83 f8 55             	cmp    $0x55,%eax
c0109913:	0f 87 44 03 00 00    	ja     c0109c5d <vprintfmt+0x3b3>
c0109919:	8b 04 85 2c c0 10 c0 	mov    -0x3fef3fd4(,%eax,4),%eax
c0109920:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c0109922:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c0109926:	eb d6                	jmp    c01098fe <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c0109928:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c010992c:	eb d0                	jmp    c01098fe <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010992e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c0109935:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0109938:	89 d0                	mov    %edx,%eax
c010993a:	c1 e0 02             	shl    $0x2,%eax
c010993d:	01 d0                	add    %edx,%eax
c010993f:	01 c0                	add    %eax,%eax
c0109941:	01 d8                	add    %ebx,%eax
c0109943:	83 e8 30             	sub    $0x30,%eax
c0109946:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c0109949:	8b 45 10             	mov    0x10(%ebp),%eax
c010994c:	0f b6 00             	movzbl (%eax),%eax
c010994f:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c0109952:	83 fb 2f             	cmp    $0x2f,%ebx
c0109955:	7e 0b                	jle    c0109962 <vprintfmt+0xb8>
c0109957:	83 fb 39             	cmp    $0x39,%ebx
c010995a:	7f 06                	jg     c0109962 <vprintfmt+0xb8>
            for (precision = 0; ; ++ fmt) {
c010995c:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                    break;
                }
            }
c0109960:	eb d3                	jmp    c0109935 <vprintfmt+0x8b>
            goto process_precision;
c0109962:	eb 33                	jmp    c0109997 <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
c0109964:	8b 45 14             	mov    0x14(%ebp),%eax
c0109967:	8d 50 04             	lea    0x4(%eax),%edx
c010996a:	89 55 14             	mov    %edx,0x14(%ebp)
c010996d:	8b 00                	mov    (%eax),%eax
c010996f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c0109972:	eb 23                	jmp    c0109997 <vprintfmt+0xed>

        case '.':
            if (width < 0)
c0109974:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0109978:	79 0c                	jns    c0109986 <vprintfmt+0xdc>
                width = 0;
c010997a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c0109981:	e9 78 ff ff ff       	jmp    c01098fe <vprintfmt+0x54>
c0109986:	e9 73 ff ff ff       	jmp    c01098fe <vprintfmt+0x54>

        case '#':
            altflag = 1;
c010998b:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c0109992:	e9 67 ff ff ff       	jmp    c01098fe <vprintfmt+0x54>

        process_precision:
            if (width < 0)
c0109997:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010999b:	79 12                	jns    c01099af <vprintfmt+0x105>
                width = precision, precision = -1;
c010999d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01099a0:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01099a3:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c01099aa:	e9 4f ff ff ff       	jmp    c01098fe <vprintfmt+0x54>
c01099af:	e9 4a ff ff ff       	jmp    c01098fe <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c01099b4:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
c01099b8:	e9 41 ff ff ff       	jmp    c01098fe <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c01099bd:	8b 45 14             	mov    0x14(%ebp),%eax
c01099c0:	8d 50 04             	lea    0x4(%eax),%edx
c01099c3:	89 55 14             	mov    %edx,0x14(%ebp)
c01099c6:	8b 00                	mov    (%eax),%eax
c01099c8:	8b 55 0c             	mov    0xc(%ebp),%edx
c01099cb:	89 54 24 04          	mov    %edx,0x4(%esp)
c01099cf:	89 04 24             	mov    %eax,(%esp)
c01099d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01099d5:	ff d0                	call   *%eax
            break;
c01099d7:	e9 ac 02 00 00       	jmp    c0109c88 <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
c01099dc:	8b 45 14             	mov    0x14(%ebp),%eax
c01099df:	8d 50 04             	lea    0x4(%eax),%edx
c01099e2:	89 55 14             	mov    %edx,0x14(%ebp)
c01099e5:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c01099e7:	85 db                	test   %ebx,%ebx
c01099e9:	79 02                	jns    c01099ed <vprintfmt+0x143>
                err = -err;
c01099eb:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c01099ed:	83 fb 06             	cmp    $0x6,%ebx
c01099f0:	7f 0b                	jg     c01099fd <vprintfmt+0x153>
c01099f2:	8b 34 9d ec bf 10 c0 	mov    -0x3fef4014(,%ebx,4),%esi
c01099f9:	85 f6                	test   %esi,%esi
c01099fb:	75 23                	jne    c0109a20 <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
c01099fd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0109a01:	c7 44 24 08 19 c0 10 	movl   $0xc010c019,0x8(%esp)
c0109a08:	c0 
c0109a09:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109a0c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109a10:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a13:	89 04 24             	mov    %eax,(%esp)
c0109a16:	e8 61 fe ff ff       	call   c010987c <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c0109a1b:	e9 68 02 00 00       	jmp    c0109c88 <vprintfmt+0x3de>
                printfmt(putch, putdat, "%s", p);
c0109a20:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0109a24:	c7 44 24 08 22 c0 10 	movl   $0xc010c022,0x8(%esp)
c0109a2b:	c0 
c0109a2c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109a2f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109a33:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a36:	89 04 24             	mov    %eax,(%esp)
c0109a39:	e8 3e fe ff ff       	call   c010987c <printfmt>
            break;
c0109a3e:	e9 45 02 00 00       	jmp    c0109c88 <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c0109a43:	8b 45 14             	mov    0x14(%ebp),%eax
c0109a46:	8d 50 04             	lea    0x4(%eax),%edx
c0109a49:	89 55 14             	mov    %edx,0x14(%ebp)
c0109a4c:	8b 30                	mov    (%eax),%esi
c0109a4e:	85 f6                	test   %esi,%esi
c0109a50:	75 05                	jne    c0109a57 <vprintfmt+0x1ad>
                p = "(null)";
c0109a52:	be 25 c0 10 c0       	mov    $0xc010c025,%esi
            }
            if (width > 0 && padc != '-') {
c0109a57:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0109a5b:	7e 3e                	jle    c0109a9b <vprintfmt+0x1f1>
c0109a5d:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c0109a61:	74 38                	je     c0109a9b <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
c0109a63:	8b 5d e8             	mov    -0x18(%ebp),%ebx
c0109a66:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109a69:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109a6d:	89 34 24             	mov    %esi,(%esp)
c0109a70:	e8 dc f7 ff ff       	call   c0109251 <strnlen>
c0109a75:	29 c3                	sub    %eax,%ebx
c0109a77:	89 d8                	mov    %ebx,%eax
c0109a79:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109a7c:	eb 17                	jmp    c0109a95 <vprintfmt+0x1eb>
                    putch(padc, putdat);
c0109a7e:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c0109a82:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109a85:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109a89:	89 04 24             	mov    %eax,(%esp)
c0109a8c:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a8f:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
c0109a91:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0109a95:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0109a99:	7f e3                	jg     c0109a7e <vprintfmt+0x1d4>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0109a9b:	eb 38                	jmp    c0109ad5 <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
c0109a9d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0109aa1:	74 1f                	je     c0109ac2 <vprintfmt+0x218>
c0109aa3:	83 fb 1f             	cmp    $0x1f,%ebx
c0109aa6:	7e 05                	jle    c0109aad <vprintfmt+0x203>
c0109aa8:	83 fb 7e             	cmp    $0x7e,%ebx
c0109aab:	7e 15                	jle    c0109ac2 <vprintfmt+0x218>
                    putch('?', putdat);
c0109aad:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109ab0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109ab4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c0109abb:	8b 45 08             	mov    0x8(%ebp),%eax
c0109abe:	ff d0                	call   *%eax
c0109ac0:	eb 0f                	jmp    c0109ad1 <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
c0109ac2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109ac5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109ac9:	89 1c 24             	mov    %ebx,(%esp)
c0109acc:	8b 45 08             	mov    0x8(%ebp),%eax
c0109acf:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0109ad1:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0109ad5:	89 f0                	mov    %esi,%eax
c0109ad7:	8d 70 01             	lea    0x1(%eax),%esi
c0109ada:	0f b6 00             	movzbl (%eax),%eax
c0109add:	0f be d8             	movsbl %al,%ebx
c0109ae0:	85 db                	test   %ebx,%ebx
c0109ae2:	74 10                	je     c0109af4 <vprintfmt+0x24a>
c0109ae4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0109ae8:	78 b3                	js     c0109a9d <vprintfmt+0x1f3>
c0109aea:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
c0109aee:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0109af2:	79 a9                	jns    c0109a9d <vprintfmt+0x1f3>
                }
            }
            for (; width > 0; width --) {
c0109af4:	eb 17                	jmp    c0109b0d <vprintfmt+0x263>
                putch(' ', putdat);
c0109af6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109af9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109afd:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0109b04:	8b 45 08             	mov    0x8(%ebp),%eax
c0109b07:	ff d0                	call   *%eax
            for (; width > 0; width --) {
c0109b09:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0109b0d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0109b11:	7f e3                	jg     c0109af6 <vprintfmt+0x24c>
            }
            break;
c0109b13:	e9 70 01 00 00       	jmp    c0109c88 <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0109b18:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109b1b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109b1f:	8d 45 14             	lea    0x14(%ebp),%eax
c0109b22:	89 04 24             	mov    %eax,(%esp)
c0109b25:	e8 0b fd ff ff       	call   c0109835 <getint>
c0109b2a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109b2d:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c0109b30:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109b33:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109b36:	85 d2                	test   %edx,%edx
c0109b38:	79 26                	jns    c0109b60 <vprintfmt+0x2b6>
                putch('-', putdat);
c0109b3a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109b3d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109b41:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c0109b48:	8b 45 08             	mov    0x8(%ebp),%eax
c0109b4b:	ff d0                	call   *%eax
                num = -(long long)num;
c0109b4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109b50:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109b53:	f7 d8                	neg    %eax
c0109b55:	83 d2 00             	adc    $0x0,%edx
c0109b58:	f7 da                	neg    %edx
c0109b5a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109b5d:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c0109b60:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0109b67:	e9 a8 00 00 00       	jmp    c0109c14 <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c0109b6c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109b6f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109b73:	8d 45 14             	lea    0x14(%ebp),%eax
c0109b76:	89 04 24             	mov    %eax,(%esp)
c0109b79:	e8 68 fc ff ff       	call   c01097e6 <getuint>
c0109b7e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109b81:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c0109b84:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0109b8b:	e9 84 00 00 00       	jmp    c0109c14 <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0109b90:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109b93:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109b97:	8d 45 14             	lea    0x14(%ebp),%eax
c0109b9a:	89 04 24             	mov    %eax,(%esp)
c0109b9d:	e8 44 fc ff ff       	call   c01097e6 <getuint>
c0109ba2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109ba5:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0109ba8:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0109baf:	eb 63                	jmp    c0109c14 <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
c0109bb1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109bb4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109bb8:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0109bbf:	8b 45 08             	mov    0x8(%ebp),%eax
c0109bc2:	ff d0                	call   *%eax
            putch('x', putdat);
c0109bc4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109bc7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109bcb:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c0109bd2:	8b 45 08             	mov    0x8(%ebp),%eax
c0109bd5:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0109bd7:	8b 45 14             	mov    0x14(%ebp),%eax
c0109bda:	8d 50 04             	lea    0x4(%eax),%edx
c0109bdd:	89 55 14             	mov    %edx,0x14(%ebp)
c0109be0:	8b 00                	mov    (%eax),%eax
c0109be2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109be5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0109bec:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0109bf3:	eb 1f                	jmp    c0109c14 <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0109bf5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109bf8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109bfc:	8d 45 14             	lea    0x14(%ebp),%eax
c0109bff:	89 04 24             	mov    %eax,(%esp)
c0109c02:	e8 df fb ff ff       	call   c01097e6 <getuint>
c0109c07:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109c0a:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0109c0d:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0109c14:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0109c18:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109c1b:	89 54 24 18          	mov    %edx,0x18(%esp)
c0109c1f:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0109c22:	89 54 24 14          	mov    %edx,0x14(%esp)
c0109c26:	89 44 24 10          	mov    %eax,0x10(%esp)
c0109c2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109c2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109c30:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109c34:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0109c38:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109c3b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109c3f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c42:	89 04 24             	mov    %eax,(%esp)
c0109c45:	e8 97 fa ff ff       	call   c01096e1 <printnum>
            break;
c0109c4a:	eb 3c                	jmp    c0109c88 <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0109c4c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109c4f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109c53:	89 1c 24             	mov    %ebx,(%esp)
c0109c56:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c59:	ff d0                	call   *%eax
            break;
c0109c5b:	eb 2b                	jmp    c0109c88 <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0109c5d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109c60:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109c64:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c0109c6b:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c6e:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0109c70:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0109c74:	eb 04                	jmp    c0109c7a <vprintfmt+0x3d0>
c0109c76:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0109c7a:	8b 45 10             	mov    0x10(%ebp),%eax
c0109c7d:	83 e8 01             	sub    $0x1,%eax
c0109c80:	0f b6 00             	movzbl (%eax),%eax
c0109c83:	3c 25                	cmp    $0x25,%al
c0109c85:	75 ef                	jne    c0109c76 <vprintfmt+0x3cc>
                /* do nothing */;
            break;
c0109c87:	90                   	nop
        }
    }
c0109c88:	90                   	nop
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0109c89:	e9 3e fc ff ff       	jmp    c01098cc <vprintfmt+0x22>
}
c0109c8e:	83 c4 40             	add    $0x40,%esp
c0109c91:	5b                   	pop    %ebx
c0109c92:	5e                   	pop    %esi
c0109c93:	5d                   	pop    %ebp
c0109c94:	c3                   	ret    

c0109c95 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0109c95:	55                   	push   %ebp
c0109c96:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0109c98:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109c9b:	8b 40 08             	mov    0x8(%eax),%eax
c0109c9e:	8d 50 01             	lea    0x1(%eax),%edx
c0109ca1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109ca4:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0109ca7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109caa:	8b 10                	mov    (%eax),%edx
c0109cac:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109caf:	8b 40 04             	mov    0x4(%eax),%eax
c0109cb2:	39 c2                	cmp    %eax,%edx
c0109cb4:	73 12                	jae    c0109cc8 <sprintputch+0x33>
        *b->buf ++ = ch;
c0109cb6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109cb9:	8b 00                	mov    (%eax),%eax
c0109cbb:	8d 48 01             	lea    0x1(%eax),%ecx
c0109cbe:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109cc1:	89 0a                	mov    %ecx,(%edx)
c0109cc3:	8b 55 08             	mov    0x8(%ebp),%edx
c0109cc6:	88 10                	mov    %dl,(%eax)
    }
}
c0109cc8:	5d                   	pop    %ebp
c0109cc9:	c3                   	ret    

c0109cca <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0109cca:	55                   	push   %ebp
c0109ccb:	89 e5                	mov    %esp,%ebp
c0109ccd:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0109cd0:	8d 45 14             	lea    0x14(%ebp),%eax
c0109cd3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0109cd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109cd9:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109cdd:	8b 45 10             	mov    0x10(%ebp),%eax
c0109ce0:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109ce4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109ce7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109ceb:	8b 45 08             	mov    0x8(%ebp),%eax
c0109cee:	89 04 24             	mov    %eax,(%esp)
c0109cf1:	e8 08 00 00 00       	call   c0109cfe <vsnprintf>
c0109cf6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0109cf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0109cfc:	c9                   	leave  
c0109cfd:	c3                   	ret    

c0109cfe <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0109cfe:	55                   	push   %ebp
c0109cff:	89 e5                	mov    %esp,%ebp
c0109d01:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0109d04:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d07:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109d0a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109d0d:	8d 50 ff             	lea    -0x1(%eax),%edx
c0109d10:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d13:	01 d0                	add    %edx,%eax
c0109d15:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109d18:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0109d1f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109d23:	74 0a                	je     c0109d2f <vsnprintf+0x31>
c0109d25:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109d28:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109d2b:	39 c2                	cmp    %eax,%edx
c0109d2d:	76 07                	jbe    c0109d36 <vsnprintf+0x38>
        return -E_INVAL;
c0109d2f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0109d34:	eb 2a                	jmp    c0109d60 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c0109d36:	8b 45 14             	mov    0x14(%ebp),%eax
c0109d39:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109d3d:	8b 45 10             	mov    0x10(%ebp),%eax
c0109d40:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109d44:	8d 45 ec             	lea    -0x14(%ebp),%eax
c0109d47:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109d4b:	c7 04 24 95 9c 10 c0 	movl   $0xc0109c95,(%esp)
c0109d52:	e8 53 fb ff ff       	call   c01098aa <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c0109d57:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109d5a:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0109d5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0109d60:	c9                   	leave  
c0109d61:	c3                   	ret    

c0109d62 <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
c0109d62:	55                   	push   %ebp
c0109d63:	89 e5                	mov    %esp,%ebp
c0109d65:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
c0109d68:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d6b:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
c0109d71:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
c0109d74:	b8 20 00 00 00       	mov    $0x20,%eax
c0109d79:	2b 45 0c             	sub    0xc(%ebp),%eax
c0109d7c:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0109d7f:	89 c1                	mov    %eax,%ecx
c0109d81:	d3 ea                	shr    %cl,%edx
c0109d83:	89 d0                	mov    %edx,%eax
}
c0109d85:	c9                   	leave  
c0109d86:	c3                   	ret    

c0109d87 <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c0109d87:	55                   	push   %ebp
c0109d88:	89 e5                	mov    %esp,%ebp
c0109d8a:	57                   	push   %edi
c0109d8b:	56                   	push   %esi
c0109d8c:	53                   	push   %ebx
c0109d8d:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c0109d90:	a1 80 4a 12 c0       	mov    0xc0124a80,%eax
c0109d95:	8b 15 84 4a 12 c0    	mov    0xc0124a84,%edx
c0109d9b:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c0109da1:	6b f0 05             	imul   $0x5,%eax,%esi
c0109da4:	01 f7                	add    %esi,%edi
c0109da6:	be 6d e6 ec de       	mov    $0xdeece66d,%esi
c0109dab:	f7 e6                	mul    %esi
c0109dad:	8d 34 17             	lea    (%edi,%edx,1),%esi
c0109db0:	89 f2                	mov    %esi,%edx
c0109db2:	83 c0 0b             	add    $0xb,%eax
c0109db5:	83 d2 00             	adc    $0x0,%edx
c0109db8:	89 c7                	mov    %eax,%edi
c0109dba:	83 e7 ff             	and    $0xffffffff,%edi
c0109dbd:	89 f9                	mov    %edi,%ecx
c0109dbf:	0f b7 da             	movzwl %dx,%ebx
c0109dc2:	89 0d 80 4a 12 c0    	mov    %ecx,0xc0124a80
c0109dc8:	89 1d 84 4a 12 c0    	mov    %ebx,0xc0124a84
    unsigned long long result = (next >> 12);
c0109dce:	a1 80 4a 12 c0       	mov    0xc0124a80,%eax
c0109dd3:	8b 15 84 4a 12 c0    	mov    0xc0124a84,%edx
c0109dd9:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0109ddd:	c1 ea 0c             	shr    $0xc,%edx
c0109de0:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0109de3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c0109de6:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c0109ded:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109df0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0109df3:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0109df6:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0109df9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109dfc:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109dff:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0109e03:	74 1c                	je     c0109e21 <rand+0x9a>
c0109e05:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109e08:	ba 00 00 00 00       	mov    $0x0,%edx
c0109e0d:	f7 75 dc             	divl   -0x24(%ebp)
c0109e10:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0109e13:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109e16:	ba 00 00 00 00       	mov    $0x0,%edx
c0109e1b:	f7 75 dc             	divl   -0x24(%ebp)
c0109e1e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109e21:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0109e24:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109e27:	f7 75 dc             	divl   -0x24(%ebp)
c0109e2a:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0109e2d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0109e30:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0109e33:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0109e36:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0109e39:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0109e3c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c0109e3f:	83 c4 24             	add    $0x24,%esp
c0109e42:	5b                   	pop    %ebx
c0109e43:	5e                   	pop    %esi
c0109e44:	5f                   	pop    %edi
c0109e45:	5d                   	pop    %ebp
c0109e46:	c3                   	ret    

c0109e47 <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c0109e47:	55                   	push   %ebp
c0109e48:	89 e5                	mov    %esp,%ebp
    next = seed;
c0109e4a:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e4d:	ba 00 00 00 00       	mov    $0x0,%edx
c0109e52:	a3 80 4a 12 c0       	mov    %eax,0xc0124a80
c0109e57:	89 15 84 4a 12 c0    	mov    %edx,0xc0124a84
}
c0109e5d:	5d                   	pop    %ebp
c0109e5e:	c3                   	ret    
