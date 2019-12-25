
bin/kernel:     file format elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 e0 1a 00       	mov    $0x1ae000,%eax
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
c0100020:	a3 00 e0 1a c0       	mov    %eax,0xc01ae000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 c0 12 c0       	mov    $0xc012c000,%esp
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
c010003c:	ba 84 31 1b c0       	mov    $0xc01b3184,%edx
c0100041:	b8 00 00 1b c0       	mov    $0xc01b0000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 00 1b c0 	movl   $0xc01b0000,(%esp)
c010005d:	e8 d0 b9 00 00       	call   c010ba32 <memset>

    cons_init();                // init the console
c0100062:	e8 15 1f 00 00       	call   c0101f7c <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 40 c3 10 c0 	movl   $0xc010c340,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 5c c3 10 c0 	movl   $0xc010c35c,(%esp)
c010007c:	e8 2d 02 00 00       	call   c01002ae <cprintf>

    print_kerninfo();
c0100081:	e8 d7 09 00 00       	call   c0100a5d <print_kerninfo>

    grade_backtrace();
c0100086:	e8 a2 00 00 00       	call   c010012d <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 23 7a 00 00       	call   c0107ab3 <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 44 20 00 00       	call   c01020d9 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 c8 21 00 00       	call   c0102262 <idt_init>

    vmm_init();                 // init virtual memory management
c010009a:	e8 ab 3c 00 00       	call   c0103d4a <vmm_init>
    sched_init();               // init scheduler
c010009f:	e8 3b af 00 00       	call   c010afdf <sched_init>
    proc_init();                // init process table
c01000a4:	e8 54 ac 00 00       	call   c010acfd <proc_init>
    
    ide_init();                 // init ide devices
c01000a9:	e8 69 0e 00 00       	call   c0100f17 <ide_init>
    swap_init();                // init swap
c01000ae:	e8 13 54 00 00       	call   c01054c6 <swap_init>

    clock_init();               // init clock interrupt
c01000b3:	e8 7a 16 00 00       	call   c0101732 <clock_init>
    intr_enable();              // enable irq interrupt
c01000b8:	e8 57 21 00 00       	call   c0102214 <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();
    
    cpu_idle();                 // run idle process
c01000bd:	e8 fa ad 00 00       	call   c010aebc <cpu_idle>

c01000c2 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000c2:	55                   	push   %ebp
c01000c3:	89 e5                	mov    %esp,%ebp
c01000c5:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000c8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000cf:	00 
c01000d0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000d7:	00 
c01000d8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000df:	e8 c7 0d 00 00       	call   c0100eab <mon_backtrace>
}
c01000e4:	c9                   	leave  
c01000e5:	c3                   	ret    

c01000e6 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000e6:	55                   	push   %ebp
c01000e7:	89 e5                	mov    %esp,%ebp
c01000e9:	53                   	push   %ebx
c01000ea:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000ed:	8d 5d 0c             	lea    0xc(%ebp),%ebx
c01000f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c01000f3:	8d 55 08             	lea    0x8(%ebp),%edx
c01000f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01000f9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01000fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100101:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100105:	89 04 24             	mov    %eax,(%esp)
c0100108:	e8 b5 ff ff ff       	call   c01000c2 <grade_backtrace2>
}
c010010d:	83 c4 14             	add    $0x14,%esp
c0100110:	5b                   	pop    %ebx
c0100111:	5d                   	pop    %ebp
c0100112:	c3                   	ret    

c0100113 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c0100113:	55                   	push   %ebp
c0100114:	89 e5                	mov    %esp,%ebp
c0100116:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c0100119:	8b 45 10             	mov    0x10(%ebp),%eax
c010011c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100120:	8b 45 08             	mov    0x8(%ebp),%eax
c0100123:	89 04 24             	mov    %eax,(%esp)
c0100126:	e8 bb ff ff ff       	call   c01000e6 <grade_backtrace1>
}
c010012b:	c9                   	leave  
c010012c:	c3                   	ret    

c010012d <grade_backtrace>:

void
grade_backtrace(void) {
c010012d:	55                   	push   %ebp
c010012e:	89 e5                	mov    %esp,%ebp
c0100130:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c0100133:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c0100138:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c010013f:	ff 
c0100140:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100144:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010014b:	e8 c3 ff ff ff       	call   c0100113 <grade_backtrace0>
}
c0100150:	c9                   	leave  
c0100151:	c3                   	ret    

c0100152 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c0100152:	55                   	push   %ebp
c0100153:	89 e5                	mov    %esp,%ebp
c0100155:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100158:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c010015b:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c010015e:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100161:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100164:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100168:	0f b7 c0             	movzwl %ax,%eax
c010016b:	83 e0 03             	and    $0x3,%eax
c010016e:	89 c2                	mov    %eax,%edx
c0100170:	a1 00 00 1b c0       	mov    0xc01b0000,%eax
c0100175:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100179:	89 44 24 04          	mov    %eax,0x4(%esp)
c010017d:	c7 04 24 61 c3 10 c0 	movl   $0xc010c361,(%esp)
c0100184:	e8 25 01 00 00       	call   c01002ae <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c0100189:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010018d:	0f b7 d0             	movzwl %ax,%edx
c0100190:	a1 00 00 1b c0       	mov    0xc01b0000,%eax
c0100195:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100199:	89 44 24 04          	mov    %eax,0x4(%esp)
c010019d:	c7 04 24 6f c3 10 c0 	movl   $0xc010c36f,(%esp)
c01001a4:	e8 05 01 00 00       	call   c01002ae <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c01001a9:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c01001ad:	0f b7 d0             	movzwl %ax,%edx
c01001b0:	a1 00 00 1b c0       	mov    0xc01b0000,%eax
c01001b5:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001b9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001bd:	c7 04 24 7d c3 10 c0 	movl   $0xc010c37d,(%esp)
c01001c4:	e8 e5 00 00 00       	call   c01002ae <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001c9:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001cd:	0f b7 d0             	movzwl %ax,%edx
c01001d0:	a1 00 00 1b c0       	mov    0xc01b0000,%eax
c01001d5:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001d9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001dd:	c7 04 24 8b c3 10 c0 	movl   $0xc010c38b,(%esp)
c01001e4:	e8 c5 00 00 00       	call   c01002ae <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001e9:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001ed:	0f b7 d0             	movzwl %ax,%edx
c01001f0:	a1 00 00 1b c0       	mov    0xc01b0000,%eax
c01001f5:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001f9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001fd:	c7 04 24 99 c3 10 c0 	movl   $0xc010c399,(%esp)
c0100204:	e8 a5 00 00 00       	call   c01002ae <cprintf>
    round ++;
c0100209:	a1 00 00 1b c0       	mov    0xc01b0000,%eax
c010020e:	83 c0 01             	add    $0x1,%eax
c0100211:	a3 00 00 1b c0       	mov    %eax,0xc01b0000
}
c0100216:	c9                   	leave  
c0100217:	c3                   	ret    

c0100218 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c0100218:	55                   	push   %ebp
c0100219:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c010021b:	5d                   	pop    %ebp
c010021c:	c3                   	ret    

c010021d <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c010021d:	55                   	push   %ebp
c010021e:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c0100220:	5d                   	pop    %ebp
c0100221:	c3                   	ret    

c0100222 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c0100222:	55                   	push   %ebp
c0100223:	89 e5                	mov    %esp,%ebp
c0100225:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c0100228:	e8 25 ff ff ff       	call   c0100152 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c010022d:	c7 04 24 a8 c3 10 c0 	movl   $0xc010c3a8,(%esp)
c0100234:	e8 75 00 00 00       	call   c01002ae <cprintf>
    lab1_switch_to_user();
c0100239:	e8 da ff ff ff       	call   c0100218 <lab1_switch_to_user>
    lab1_print_cur_status();
c010023e:	e8 0f ff ff ff       	call   c0100152 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100243:	c7 04 24 c8 c3 10 c0 	movl   $0xc010c3c8,(%esp)
c010024a:	e8 5f 00 00 00       	call   c01002ae <cprintf>
    lab1_switch_to_kernel();
c010024f:	e8 c9 ff ff ff       	call   c010021d <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100254:	e8 f9 fe ff ff       	call   c0100152 <lab1_print_cur_status>
}
c0100259:	c9                   	leave  
c010025a:	c3                   	ret    

c010025b <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c010025b:	55                   	push   %ebp
c010025c:	89 e5                	mov    %esp,%ebp
c010025e:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100261:	8b 45 08             	mov    0x8(%ebp),%eax
c0100264:	89 04 24             	mov    %eax,(%esp)
c0100267:	e8 3c 1d 00 00       	call   c0101fa8 <cons_putc>
    (*cnt) ++;
c010026c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010026f:	8b 00                	mov    (%eax),%eax
c0100271:	8d 50 01             	lea    0x1(%eax),%edx
c0100274:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100277:	89 10                	mov    %edx,(%eax)
}
c0100279:	c9                   	leave  
c010027a:	c3                   	ret    

c010027b <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c010027b:	55                   	push   %ebp
c010027c:	89 e5                	mov    %esp,%ebp
c010027e:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100281:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c0100288:	8b 45 0c             	mov    0xc(%ebp),%eax
c010028b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010028f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100292:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100296:	8d 45 f4             	lea    -0xc(%ebp),%eax
c0100299:	89 44 24 04          	mov    %eax,0x4(%esp)
c010029d:	c7 04 24 5b 02 10 c0 	movl   $0xc010025b,(%esp)
c01002a4:	e8 db ba 00 00       	call   c010bd84 <vprintfmt>
    return cnt;
c01002a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002ac:	c9                   	leave  
c01002ad:	c3                   	ret    

c01002ae <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c01002ae:	55                   	push   %ebp
c01002af:	89 e5                	mov    %esp,%ebp
c01002b1:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c01002b4:	8d 45 0c             	lea    0xc(%ebp),%eax
c01002b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c01002ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002bd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01002c1:	8b 45 08             	mov    0x8(%ebp),%eax
c01002c4:	89 04 24             	mov    %eax,(%esp)
c01002c7:	e8 af ff ff ff       	call   c010027b <vcprintf>
c01002cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c01002cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002d2:	c9                   	leave  
c01002d3:	c3                   	ret    

c01002d4 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c01002d4:	55                   	push   %ebp
c01002d5:	89 e5                	mov    %esp,%ebp
c01002d7:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c01002da:	8b 45 08             	mov    0x8(%ebp),%eax
c01002dd:	89 04 24             	mov    %eax,(%esp)
c01002e0:	e8 c3 1c 00 00       	call   c0101fa8 <cons_putc>
}
c01002e5:	c9                   	leave  
c01002e6:	c3                   	ret    

c01002e7 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c01002e7:	55                   	push   %ebp
c01002e8:	89 e5                	mov    %esp,%ebp
c01002ea:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c01002ed:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01002f4:	eb 13                	jmp    c0100309 <cputs+0x22>
        cputch(c, &cnt);
c01002f6:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01002fa:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01002fd:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100301:	89 04 24             	mov    %eax,(%esp)
c0100304:	e8 52 ff ff ff       	call   c010025b <cputch>
    while ((c = *str ++) != '\0') {
c0100309:	8b 45 08             	mov    0x8(%ebp),%eax
c010030c:	8d 50 01             	lea    0x1(%eax),%edx
c010030f:	89 55 08             	mov    %edx,0x8(%ebp)
c0100312:	0f b6 00             	movzbl (%eax),%eax
c0100315:	88 45 f7             	mov    %al,-0x9(%ebp)
c0100318:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c010031c:	75 d8                	jne    c01002f6 <cputs+0xf>
    }
    cputch('\n', &cnt);
c010031e:	8d 45 f0             	lea    -0x10(%ebp),%eax
c0100321:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100325:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c010032c:	e8 2a ff ff ff       	call   c010025b <cputch>
    return cnt;
c0100331:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0100334:	c9                   	leave  
c0100335:	c3                   	ret    

c0100336 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c0100336:	55                   	push   %ebp
c0100337:	89 e5                	mov    %esp,%ebp
c0100339:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c010033c:	e8 a3 1c 00 00       	call   c0101fe4 <cons_getc>
c0100341:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100344:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100348:	74 f2                	je     c010033c <getchar+0x6>
        /* do nothing */;
    return c;
c010034a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010034d:	c9                   	leave  
c010034e:	c3                   	ret    

c010034f <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c010034f:	55                   	push   %ebp
c0100350:	89 e5                	mov    %esp,%ebp
c0100352:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c0100355:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100359:	74 13                	je     c010036e <readline+0x1f>
        cprintf("%s", prompt);
c010035b:	8b 45 08             	mov    0x8(%ebp),%eax
c010035e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100362:	c7 04 24 e7 c3 10 c0 	movl   $0xc010c3e7,(%esp)
c0100369:	e8 40 ff ff ff       	call   c01002ae <cprintf>
    }
    int i = 0, c;
c010036e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c0100375:	e8 bc ff ff ff       	call   c0100336 <getchar>
c010037a:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c010037d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100381:	79 07                	jns    c010038a <readline+0x3b>
            return NULL;
c0100383:	b8 00 00 00 00       	mov    $0x0,%eax
c0100388:	eb 79                	jmp    c0100403 <readline+0xb4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c010038a:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c010038e:	7e 28                	jle    c01003b8 <readline+0x69>
c0100390:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c0100397:	7f 1f                	jg     c01003b8 <readline+0x69>
            cputchar(c);
c0100399:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010039c:	89 04 24             	mov    %eax,(%esp)
c010039f:	e8 30 ff ff ff       	call   c01002d4 <cputchar>
            buf[i ++] = c;
c01003a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01003a7:	8d 50 01             	lea    0x1(%eax),%edx
c01003aa:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01003ad:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01003b0:	88 90 20 00 1b c0    	mov    %dl,-0x3fe4ffe0(%eax)
c01003b6:	eb 46                	jmp    c01003fe <readline+0xaf>
        }
        else if (c == '\b' && i > 0) {
c01003b8:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01003bc:	75 17                	jne    c01003d5 <readline+0x86>
c01003be:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003c2:	7e 11                	jle    c01003d5 <readline+0x86>
            cputchar(c);
c01003c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003c7:	89 04 24             	mov    %eax,(%esp)
c01003ca:	e8 05 ff ff ff       	call   c01002d4 <cputchar>
            i --;
c01003cf:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01003d3:	eb 29                	jmp    c01003fe <readline+0xaf>
        }
        else if (c == '\n' || c == '\r') {
c01003d5:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01003d9:	74 06                	je     c01003e1 <readline+0x92>
c01003db:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01003df:	75 1d                	jne    c01003fe <readline+0xaf>
            cputchar(c);
c01003e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003e4:	89 04 24             	mov    %eax,(%esp)
c01003e7:	e8 e8 fe ff ff       	call   c01002d4 <cputchar>
            buf[i] = '\0';
c01003ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01003ef:	05 20 00 1b c0       	add    $0xc01b0020,%eax
c01003f4:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01003f7:	b8 20 00 1b c0       	mov    $0xc01b0020,%eax
c01003fc:	eb 05                	jmp    c0100403 <readline+0xb4>
        }
    }
c01003fe:	e9 72 ff ff ff       	jmp    c0100375 <readline+0x26>
}
c0100403:	c9                   	leave  
c0100404:	c3                   	ret    

c0100405 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100405:	55                   	push   %ebp
c0100406:	89 e5                	mov    %esp,%ebp
c0100408:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c010040b:	a1 20 04 1b c0       	mov    0xc01b0420,%eax
c0100410:	85 c0                	test   %eax,%eax
c0100412:	74 02                	je     c0100416 <__panic+0x11>
        goto panic_dead;
c0100414:	eb 59                	jmp    c010046f <__panic+0x6a>
    }
    is_panic = 1;
c0100416:	c7 05 20 04 1b c0 01 	movl   $0x1,0xc01b0420
c010041d:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100420:	8d 45 14             	lea    0x14(%ebp),%eax
c0100423:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100426:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100429:	89 44 24 08          	mov    %eax,0x8(%esp)
c010042d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100430:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100434:	c7 04 24 ea c3 10 c0 	movl   $0xc010c3ea,(%esp)
c010043b:	e8 6e fe ff ff       	call   c01002ae <cprintf>
    vcprintf(fmt, ap);
c0100440:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100443:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100447:	8b 45 10             	mov    0x10(%ebp),%eax
c010044a:	89 04 24             	mov    %eax,(%esp)
c010044d:	e8 29 fe ff ff       	call   c010027b <vcprintf>
    cprintf("\n");
c0100452:	c7 04 24 06 c4 10 c0 	movl   $0xc010c406,(%esp)
c0100459:	e8 50 fe ff ff       	call   c01002ae <cprintf>
    
    cprintf("stack trackback:\n");
c010045e:	c7 04 24 08 c4 10 c0 	movl   $0xc010c408,(%esp)
c0100465:	e8 44 fe ff ff       	call   c01002ae <cprintf>
    print_stackframe();
c010046a:	e8 38 07 00 00       	call   c0100ba7 <print_stackframe>
    
    va_end(ap);

panic_dead:
    intr_disable();
c010046f:	e8 a6 1d 00 00       	call   c010221a <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100474:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010047b:	e8 5c 09 00 00       	call   c0100ddc <kmonitor>
    }
c0100480:	eb f2                	jmp    c0100474 <__panic+0x6f>

c0100482 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100482:	55                   	push   %ebp
c0100483:	89 e5                	mov    %esp,%ebp
c0100485:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100488:	8d 45 14             	lea    0x14(%ebp),%eax
c010048b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c010048e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100491:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100495:	8b 45 08             	mov    0x8(%ebp),%eax
c0100498:	89 44 24 04          	mov    %eax,0x4(%esp)
c010049c:	c7 04 24 1a c4 10 c0 	movl   $0xc010c41a,(%esp)
c01004a3:	e8 06 fe ff ff       	call   c01002ae <cprintf>
    vcprintf(fmt, ap);
c01004a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01004ab:	89 44 24 04          	mov    %eax,0x4(%esp)
c01004af:	8b 45 10             	mov    0x10(%ebp),%eax
c01004b2:	89 04 24             	mov    %eax,(%esp)
c01004b5:	e8 c1 fd ff ff       	call   c010027b <vcprintf>
    cprintf("\n");
c01004ba:	c7 04 24 06 c4 10 c0 	movl   $0xc010c406,(%esp)
c01004c1:	e8 e8 fd ff ff       	call   c01002ae <cprintf>
    va_end(ap);
}
c01004c6:	c9                   	leave  
c01004c7:	c3                   	ret    

c01004c8 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c01004c8:	55                   	push   %ebp
c01004c9:	89 e5                	mov    %esp,%ebp
    return is_panic;
c01004cb:	a1 20 04 1b c0       	mov    0xc01b0420,%eax
}
c01004d0:	5d                   	pop    %ebp
c01004d1:	c3                   	ret    

c01004d2 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c01004d2:	55                   	push   %ebp
c01004d3:	89 e5                	mov    %esp,%ebp
c01004d5:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c01004d8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004db:	8b 00                	mov    (%eax),%eax
c01004dd:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004e0:	8b 45 10             	mov    0x10(%ebp),%eax
c01004e3:	8b 00                	mov    (%eax),%eax
c01004e5:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c01004ef:	e9 d2 00 00 00       	jmp    c01005c6 <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
c01004f4:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01004f7:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01004fa:	01 d0                	add    %edx,%eax
c01004fc:	89 c2                	mov    %eax,%edx
c01004fe:	c1 ea 1f             	shr    $0x1f,%edx
c0100501:	01 d0                	add    %edx,%eax
c0100503:	d1 f8                	sar    %eax
c0100505:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0100508:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010050b:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c010050e:	eb 04                	jmp    c0100514 <stab_binsearch+0x42>
            m --;
c0100510:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
c0100514:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100517:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010051a:	7c 1f                	jl     c010053b <stab_binsearch+0x69>
c010051c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010051f:	89 d0                	mov    %edx,%eax
c0100521:	01 c0                	add    %eax,%eax
c0100523:	01 d0                	add    %edx,%eax
c0100525:	c1 e0 02             	shl    $0x2,%eax
c0100528:	89 c2                	mov    %eax,%edx
c010052a:	8b 45 08             	mov    0x8(%ebp),%eax
c010052d:	01 d0                	add    %edx,%eax
c010052f:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100533:	0f b6 c0             	movzbl %al,%eax
c0100536:	3b 45 14             	cmp    0x14(%ebp),%eax
c0100539:	75 d5                	jne    c0100510 <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
c010053b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010053e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100541:	7d 0b                	jge    c010054e <stab_binsearch+0x7c>
            l = true_m + 1;
c0100543:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100546:	83 c0 01             	add    $0x1,%eax
c0100549:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c010054c:	eb 78                	jmp    c01005c6 <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
c010054e:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0100555:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100558:	89 d0                	mov    %edx,%eax
c010055a:	01 c0                	add    %eax,%eax
c010055c:	01 d0                	add    %edx,%eax
c010055e:	c1 e0 02             	shl    $0x2,%eax
c0100561:	89 c2                	mov    %eax,%edx
c0100563:	8b 45 08             	mov    0x8(%ebp),%eax
c0100566:	01 d0                	add    %edx,%eax
c0100568:	8b 40 08             	mov    0x8(%eax),%eax
c010056b:	3b 45 18             	cmp    0x18(%ebp),%eax
c010056e:	73 13                	jae    c0100583 <stab_binsearch+0xb1>
            *region_left = m;
c0100570:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100573:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100576:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c0100578:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010057b:	83 c0 01             	add    $0x1,%eax
c010057e:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100581:	eb 43                	jmp    c01005c6 <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
c0100583:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100586:	89 d0                	mov    %edx,%eax
c0100588:	01 c0                	add    %eax,%eax
c010058a:	01 d0                	add    %edx,%eax
c010058c:	c1 e0 02             	shl    $0x2,%eax
c010058f:	89 c2                	mov    %eax,%edx
c0100591:	8b 45 08             	mov    0x8(%ebp),%eax
c0100594:	01 d0                	add    %edx,%eax
c0100596:	8b 40 08             	mov    0x8(%eax),%eax
c0100599:	3b 45 18             	cmp    0x18(%ebp),%eax
c010059c:	76 16                	jbe    c01005b4 <stab_binsearch+0xe2>
            *region_right = m - 1;
c010059e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005a1:	8d 50 ff             	lea    -0x1(%eax),%edx
c01005a4:	8b 45 10             	mov    0x10(%ebp),%eax
c01005a7:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01005a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005ac:	83 e8 01             	sub    $0x1,%eax
c01005af:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01005b2:	eb 12                	jmp    c01005c6 <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01005b4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005b7:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005ba:	89 10                	mov    %edx,(%eax)
            l = m;
c01005bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005bf:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01005c2:	83 45 18 01          	addl   $0x1,0x18(%ebp)
    while (l <= r) {
c01005c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01005c9:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01005cc:	0f 8e 22 ff ff ff    	jle    c01004f4 <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
c01005d2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01005d6:	75 0f                	jne    c01005e7 <stab_binsearch+0x115>
        *region_right = *region_left - 1;
c01005d8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005db:	8b 00                	mov    (%eax),%eax
c01005dd:	8d 50 ff             	lea    -0x1(%eax),%edx
c01005e0:	8b 45 10             	mov    0x10(%ebp),%eax
c01005e3:	89 10                	mov    %edx,(%eax)
c01005e5:	eb 3f                	jmp    c0100626 <stab_binsearch+0x154>
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
c01005e7:	8b 45 10             	mov    0x10(%ebp),%eax
c01005ea:	8b 00                	mov    (%eax),%eax
c01005ec:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c01005ef:	eb 04                	jmp    c01005f5 <stab_binsearch+0x123>
c01005f1:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
c01005f5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005f8:	8b 00                	mov    (%eax),%eax
c01005fa:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01005fd:	7d 1f                	jge    c010061e <stab_binsearch+0x14c>
c01005ff:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100602:	89 d0                	mov    %edx,%eax
c0100604:	01 c0                	add    %eax,%eax
c0100606:	01 d0                	add    %edx,%eax
c0100608:	c1 e0 02             	shl    $0x2,%eax
c010060b:	89 c2                	mov    %eax,%edx
c010060d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100610:	01 d0                	add    %edx,%eax
c0100612:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100616:	0f b6 c0             	movzbl %al,%eax
c0100619:	3b 45 14             	cmp    0x14(%ebp),%eax
c010061c:	75 d3                	jne    c01005f1 <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
c010061e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100621:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100624:	89 10                	mov    %edx,(%eax)
    }
}
c0100626:	c9                   	leave  
c0100627:	c3                   	ret    

c0100628 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c0100628:	55                   	push   %ebp
c0100629:	89 e5                	mov    %esp,%ebp
c010062b:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c010062e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100631:	c7 00 38 c4 10 c0    	movl   $0xc010c438,(%eax)
    info->eip_line = 0;
c0100637:	8b 45 0c             	mov    0xc(%ebp),%eax
c010063a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c0100641:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100644:	c7 40 08 38 c4 10 c0 	movl   $0xc010c438,0x8(%eax)
    info->eip_fn_namelen = 9;
c010064b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010064e:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c0100655:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100658:	8b 55 08             	mov    0x8(%ebp),%edx
c010065b:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c010065e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100661:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    // find the relevant set of stabs
    if (addr >= KERNBASE) {
c0100668:	81 7d 08 ff ff ff bf 	cmpl   $0xbfffffff,0x8(%ebp)
c010066f:	76 21                	jbe    c0100692 <debuginfo_eip+0x6a>
        stabs = __STAB_BEGIN__;
c0100671:	c7 45 f4 80 eb 10 c0 	movl   $0xc010eb80,-0xc(%ebp)
        stab_end = __STAB_END__;
c0100678:	c7 45 f0 70 39 12 c0 	movl   $0xc0123970,-0x10(%ebp)
        stabstr = __STABSTR_BEGIN__;
c010067f:	c7 45 ec 71 39 12 c0 	movl   $0xc0123971,-0x14(%ebp)
        stabstr_end = __STABSTR_END__;
c0100686:	c7 45 e8 46 9a 12 c0 	movl   $0xc0129a46,-0x18(%ebp)
c010068d:	e9 ea 00 00 00       	jmp    c010077c <debuginfo_eip+0x154>
    }
    else {
        // user-program linker script, tools/user.ld puts the information about the
        // program's stabs (included __STAB_BEGIN__, __STAB_END__, __STABSTR_BEGIN__,
        // and __STABSTR_END__) in a structure located at virtual address USTAB.
        const struct userstabdata *usd = (struct userstabdata *)USTAB;
c0100692:	c7 45 e4 00 00 20 00 	movl   $0x200000,-0x1c(%ebp)

        // make sure that debugger (current process) can access this memory
        struct mm_struct *mm;
        if (current == NULL || (mm = current->mm) == NULL) {
c0100699:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010069e:	85 c0                	test   %eax,%eax
c01006a0:	74 11                	je     c01006b3 <debuginfo_eip+0x8b>
c01006a2:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c01006a7:	8b 40 18             	mov    0x18(%eax),%eax
c01006aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01006ad:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01006b1:	75 0a                	jne    c01006bd <debuginfo_eip+0x95>
            return -1;
c01006b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006b8:	e9 9e 03 00 00       	jmp    c0100a5b <debuginfo_eip+0x433>
        }
        if (!user_mem_check(mm, (uintptr_t)usd, sizeof(struct userstabdata), 0)) {
c01006bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006c0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01006c7:	00 
c01006c8:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c01006cf:	00 
c01006d0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01006d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006d7:	89 04 24             	mov    %eax,(%esp)
c01006da:	e8 94 3f 00 00       	call   c0104673 <user_mem_check>
c01006df:	85 c0                	test   %eax,%eax
c01006e1:	75 0a                	jne    c01006ed <debuginfo_eip+0xc5>
            return -1;
c01006e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006e8:	e9 6e 03 00 00       	jmp    c0100a5b <debuginfo_eip+0x433>
        }

        stabs = usd->stabs;
c01006ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006f0:	8b 00                	mov    (%eax),%eax
c01006f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        stab_end = usd->stab_end;
c01006f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006f8:	8b 40 04             	mov    0x4(%eax),%eax
c01006fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
        stabstr = usd->stabstr;
c01006fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100701:	8b 40 08             	mov    0x8(%eax),%eax
c0100704:	89 45 ec             	mov    %eax,-0x14(%ebp)
        stabstr_end = usd->stabstr_end;
c0100707:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010070a:	8b 40 0c             	mov    0xc(%eax),%eax
c010070d:	89 45 e8             	mov    %eax,-0x18(%ebp)

        // make sure the STABS and string table memory is valid
        if (!user_mem_check(mm, (uintptr_t)stabs, (uintptr_t)stab_end - (uintptr_t)stabs, 0)) {
c0100710:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100713:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100716:	29 c2                	sub    %eax,%edx
c0100718:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010071b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0100722:	00 
c0100723:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100727:	89 44 24 04          	mov    %eax,0x4(%esp)
c010072b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010072e:	89 04 24             	mov    %eax,(%esp)
c0100731:	e8 3d 3f 00 00       	call   c0104673 <user_mem_check>
c0100736:	85 c0                	test   %eax,%eax
c0100738:	75 0a                	jne    c0100744 <debuginfo_eip+0x11c>
            return -1;
c010073a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010073f:	e9 17 03 00 00       	jmp    c0100a5b <debuginfo_eip+0x433>
        }
        if (!user_mem_check(mm, (uintptr_t)stabstr, stabstr_end - stabstr, 0)) {
c0100744:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0100747:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010074a:	29 c2                	sub    %eax,%edx
c010074c:	89 d0                	mov    %edx,%eax
c010074e:	89 c2                	mov    %eax,%edx
c0100750:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100753:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010075a:	00 
c010075b:	89 54 24 08          	mov    %edx,0x8(%esp)
c010075f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100763:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100766:	89 04 24             	mov    %eax,(%esp)
c0100769:	e8 05 3f 00 00       	call   c0104673 <user_mem_check>
c010076e:	85 c0                	test   %eax,%eax
c0100770:	75 0a                	jne    c010077c <debuginfo_eip+0x154>
            return -1;
c0100772:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100777:	e9 df 02 00 00       	jmp    c0100a5b <debuginfo_eip+0x433>
        }
    }

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c010077c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010077f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0100782:	76 0d                	jbe    c0100791 <debuginfo_eip+0x169>
c0100784:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100787:	83 e8 01             	sub    $0x1,%eax
c010078a:	0f b6 00             	movzbl (%eax),%eax
c010078d:	84 c0                	test   %al,%al
c010078f:	74 0a                	je     c010079b <debuginfo_eip+0x173>
        return -1;
c0100791:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100796:	e9 c0 02 00 00       	jmp    c0100a5b <debuginfo_eip+0x433>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c010079b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01007a2:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01007a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007a8:	29 c2                	sub    %eax,%edx
c01007aa:	89 d0                	mov    %edx,%eax
c01007ac:	c1 f8 02             	sar    $0x2,%eax
c01007af:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01007b5:	83 e8 01             	sub    $0x1,%eax
c01007b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01007bb:	8b 45 08             	mov    0x8(%ebp),%eax
c01007be:	89 44 24 10          	mov    %eax,0x10(%esp)
c01007c2:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01007c9:	00 
c01007ca:	8d 45 d8             	lea    -0x28(%ebp),%eax
c01007cd:	89 44 24 08          	mov    %eax,0x8(%esp)
c01007d1:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01007d4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01007d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007db:	89 04 24             	mov    %eax,(%esp)
c01007de:	e8 ef fc ff ff       	call   c01004d2 <stab_binsearch>
    if (lfile == 0)
c01007e3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01007e6:	85 c0                	test   %eax,%eax
c01007e8:	75 0a                	jne    c01007f4 <debuginfo_eip+0x1cc>
        return -1;
c01007ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01007ef:	e9 67 02 00 00       	jmp    c0100a5b <debuginfo_eip+0x433>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c01007f4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01007f7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c01007fa:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01007fd:	89 45 d0             	mov    %eax,-0x30(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c0100800:	8b 45 08             	mov    0x8(%ebp),%eax
c0100803:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100807:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c010080e:	00 
c010080f:	8d 45 d0             	lea    -0x30(%ebp),%eax
c0100812:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100816:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c0100819:	89 44 24 04          	mov    %eax,0x4(%esp)
c010081d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100820:	89 04 24             	mov    %eax,(%esp)
c0100823:	e8 aa fc ff ff       	call   c01004d2 <stab_binsearch>

    if (lfun <= rfun) {
c0100828:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010082b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010082e:	39 c2                	cmp    %eax,%edx
c0100830:	7f 7c                	jg     c01008ae <debuginfo_eip+0x286>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0100832:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100835:	89 c2                	mov    %eax,%edx
c0100837:	89 d0                	mov    %edx,%eax
c0100839:	01 c0                	add    %eax,%eax
c010083b:	01 d0                	add    %edx,%eax
c010083d:	c1 e0 02             	shl    $0x2,%eax
c0100840:	89 c2                	mov    %eax,%edx
c0100842:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100845:	01 d0                	add    %edx,%eax
c0100847:	8b 10                	mov    (%eax),%edx
c0100849:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010084c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010084f:	29 c1                	sub    %eax,%ecx
c0100851:	89 c8                	mov    %ecx,%eax
c0100853:	39 c2                	cmp    %eax,%edx
c0100855:	73 22                	jae    c0100879 <debuginfo_eip+0x251>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0100857:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010085a:	89 c2                	mov    %eax,%edx
c010085c:	89 d0                	mov    %edx,%eax
c010085e:	01 c0                	add    %eax,%eax
c0100860:	01 d0                	add    %edx,%eax
c0100862:	c1 e0 02             	shl    $0x2,%eax
c0100865:	89 c2                	mov    %eax,%edx
c0100867:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010086a:	01 d0                	add    %edx,%eax
c010086c:	8b 10                	mov    (%eax),%edx
c010086e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100871:	01 c2                	add    %eax,%edx
c0100873:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100876:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c0100879:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010087c:	89 c2                	mov    %eax,%edx
c010087e:	89 d0                	mov    %edx,%eax
c0100880:	01 c0                	add    %eax,%eax
c0100882:	01 d0                	add    %edx,%eax
c0100884:	c1 e0 02             	shl    $0x2,%eax
c0100887:	89 c2                	mov    %eax,%edx
c0100889:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010088c:	01 d0                	add    %edx,%eax
c010088e:	8b 50 08             	mov    0x8(%eax),%edx
c0100891:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100894:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c0100897:	8b 45 0c             	mov    0xc(%ebp),%eax
c010089a:	8b 40 10             	mov    0x10(%eax),%eax
c010089d:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c01008a0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008a3:	89 45 cc             	mov    %eax,-0x34(%ebp)
        rline = rfun;
c01008a6:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01008a9:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01008ac:	eb 15                	jmp    c01008c3 <debuginfo_eip+0x29b>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01008ae:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008b1:	8b 55 08             	mov    0x8(%ebp),%edx
c01008b4:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01008b7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01008ba:	89 45 cc             	mov    %eax,-0x34(%ebp)
        rline = rfile;
c01008bd:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01008c0:	89 45 c8             	mov    %eax,-0x38(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01008c3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008c6:	8b 40 08             	mov    0x8(%eax),%eax
c01008c9:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01008d0:	00 
c01008d1:	89 04 24             	mov    %eax,(%esp)
c01008d4:	e8 cd af 00 00       	call   c010b8a6 <strfind>
c01008d9:	89 c2                	mov    %eax,%edx
c01008db:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008de:	8b 40 08             	mov    0x8(%eax),%eax
c01008e1:	29 c2                	sub    %eax,%edx
c01008e3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008e6:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c01008e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01008ec:	89 44 24 10          	mov    %eax,0x10(%esp)
c01008f0:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c01008f7:	00 
c01008f8:	8d 45 c8             	lea    -0x38(%ebp),%eax
c01008fb:	89 44 24 08          	mov    %eax,0x8(%esp)
c01008ff:	8d 45 cc             	lea    -0x34(%ebp),%eax
c0100902:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100906:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100909:	89 04 24             	mov    %eax,(%esp)
c010090c:	e8 c1 fb ff ff       	call   c01004d2 <stab_binsearch>
    if (lline <= rline) {
c0100911:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0100914:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0100917:	39 c2                	cmp    %eax,%edx
c0100919:	7f 24                	jg     c010093f <debuginfo_eip+0x317>
        info->eip_line = stabs[rline].n_desc;
c010091b:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010091e:	89 c2                	mov    %eax,%edx
c0100920:	89 d0                	mov    %edx,%eax
c0100922:	01 c0                	add    %eax,%eax
c0100924:	01 d0                	add    %edx,%eax
c0100926:	c1 e0 02             	shl    $0x2,%eax
c0100929:	89 c2                	mov    %eax,%edx
c010092b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010092e:	01 d0                	add    %edx,%eax
c0100930:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100934:	0f b7 d0             	movzwl %ax,%edx
c0100937:	8b 45 0c             	mov    0xc(%ebp),%eax
c010093a:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c010093d:	eb 13                	jmp    c0100952 <debuginfo_eip+0x32a>
        return -1;
c010093f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100944:	e9 12 01 00 00       	jmp    c0100a5b <debuginfo_eip+0x433>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c0100949:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010094c:	83 e8 01             	sub    $0x1,%eax
c010094f:	89 45 cc             	mov    %eax,-0x34(%ebp)
    while (lline >= lfile
c0100952:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0100955:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100958:	39 c2                	cmp    %eax,%edx
c010095a:	7c 56                	jl     c01009b2 <debuginfo_eip+0x38a>
           && stabs[lline].n_type != N_SOL
c010095c:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010095f:	89 c2                	mov    %eax,%edx
c0100961:	89 d0                	mov    %edx,%eax
c0100963:	01 c0                	add    %eax,%eax
c0100965:	01 d0                	add    %edx,%eax
c0100967:	c1 e0 02             	shl    $0x2,%eax
c010096a:	89 c2                	mov    %eax,%edx
c010096c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010096f:	01 d0                	add    %edx,%eax
c0100971:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100975:	3c 84                	cmp    $0x84,%al
c0100977:	74 39                	je     c01009b2 <debuginfo_eip+0x38a>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c0100979:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010097c:	89 c2                	mov    %eax,%edx
c010097e:	89 d0                	mov    %edx,%eax
c0100980:	01 c0                	add    %eax,%eax
c0100982:	01 d0                	add    %edx,%eax
c0100984:	c1 e0 02             	shl    $0x2,%eax
c0100987:	89 c2                	mov    %eax,%edx
c0100989:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010098c:	01 d0                	add    %edx,%eax
c010098e:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100992:	3c 64                	cmp    $0x64,%al
c0100994:	75 b3                	jne    c0100949 <debuginfo_eip+0x321>
c0100996:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0100999:	89 c2                	mov    %eax,%edx
c010099b:	89 d0                	mov    %edx,%eax
c010099d:	01 c0                	add    %eax,%eax
c010099f:	01 d0                	add    %edx,%eax
c01009a1:	c1 e0 02             	shl    $0x2,%eax
c01009a4:	89 c2                	mov    %eax,%edx
c01009a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009a9:	01 d0                	add    %edx,%eax
c01009ab:	8b 40 08             	mov    0x8(%eax),%eax
c01009ae:	85 c0                	test   %eax,%eax
c01009b0:	74 97                	je     c0100949 <debuginfo_eip+0x321>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01009b2:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01009b5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01009b8:	39 c2                	cmp    %eax,%edx
c01009ba:	7c 46                	jl     c0100a02 <debuginfo_eip+0x3da>
c01009bc:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01009bf:	89 c2                	mov    %eax,%edx
c01009c1:	89 d0                	mov    %edx,%eax
c01009c3:	01 c0                	add    %eax,%eax
c01009c5:	01 d0                	add    %edx,%eax
c01009c7:	c1 e0 02             	shl    $0x2,%eax
c01009ca:	89 c2                	mov    %eax,%edx
c01009cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009cf:	01 d0                	add    %edx,%eax
c01009d1:	8b 10                	mov    (%eax),%edx
c01009d3:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c01009d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01009d9:	29 c1                	sub    %eax,%ecx
c01009db:	89 c8                	mov    %ecx,%eax
c01009dd:	39 c2                	cmp    %eax,%edx
c01009df:	73 21                	jae    c0100a02 <debuginfo_eip+0x3da>
        info->eip_file = stabstr + stabs[lline].n_strx;
c01009e1:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01009e4:	89 c2                	mov    %eax,%edx
c01009e6:	89 d0                	mov    %edx,%eax
c01009e8:	01 c0                	add    %eax,%eax
c01009ea:	01 d0                	add    %edx,%eax
c01009ec:	c1 e0 02             	shl    $0x2,%eax
c01009ef:	89 c2                	mov    %eax,%edx
c01009f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009f4:	01 d0                	add    %edx,%eax
c01009f6:	8b 10                	mov    (%eax),%edx
c01009f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01009fb:	01 c2                	add    %eax,%edx
c01009fd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100a00:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c0100a02:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100a05:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100a08:	39 c2                	cmp    %eax,%edx
c0100a0a:	7d 4a                	jge    c0100a56 <debuginfo_eip+0x42e>
        for (lline = lfun + 1;
c0100a0c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100a0f:	83 c0 01             	add    $0x1,%eax
c0100a12:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0100a15:	eb 18                	jmp    c0100a2f <debuginfo_eip+0x407>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0100a17:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100a1a:	8b 40 14             	mov    0x14(%eax),%eax
c0100a1d:	8d 50 01             	lea    0x1(%eax),%edx
c0100a20:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100a23:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
c0100a26:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0100a29:	83 c0 01             	add    $0x1,%eax
c0100a2c:	89 45 cc             	mov    %eax,-0x34(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100a2f:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0100a32:	8b 45 d0             	mov    -0x30(%ebp),%eax
        for (lline = lfun + 1;
c0100a35:	39 c2                	cmp    %eax,%edx
c0100a37:	7d 1d                	jge    c0100a56 <debuginfo_eip+0x42e>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100a39:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0100a3c:	89 c2                	mov    %eax,%edx
c0100a3e:	89 d0                	mov    %edx,%eax
c0100a40:	01 c0                	add    %eax,%eax
c0100a42:	01 d0                	add    %edx,%eax
c0100a44:	c1 e0 02             	shl    $0x2,%eax
c0100a47:	89 c2                	mov    %eax,%edx
c0100a49:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a4c:	01 d0                	add    %edx,%eax
c0100a4e:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100a52:	3c a0                	cmp    $0xa0,%al
c0100a54:	74 c1                	je     c0100a17 <debuginfo_eip+0x3ef>
        }
    }
    return 0;
c0100a56:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100a5b:	c9                   	leave  
c0100a5c:	c3                   	ret    

c0100a5d <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0100a5d:	55                   	push   %ebp
c0100a5e:	89 e5                	mov    %esp,%ebp
c0100a60:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0100a63:	c7 04 24 42 c4 10 c0 	movl   $0xc010c442,(%esp)
c0100a6a:	e8 3f f8 ff ff       	call   c01002ae <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c0100a6f:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c0100a76:	c0 
c0100a77:	c7 04 24 5b c4 10 c0 	movl   $0xc010c45b,(%esp)
c0100a7e:	e8 2b f8 ff ff       	call   c01002ae <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c0100a83:	c7 44 24 04 39 c3 10 	movl   $0xc010c339,0x4(%esp)
c0100a8a:	c0 
c0100a8b:	c7 04 24 73 c4 10 c0 	movl   $0xc010c473,(%esp)
c0100a92:	e8 17 f8 ff ff       	call   c01002ae <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c0100a97:	c7 44 24 04 00 00 1b 	movl   $0xc01b0000,0x4(%esp)
c0100a9e:	c0 
c0100a9f:	c7 04 24 8b c4 10 c0 	movl   $0xc010c48b,(%esp)
c0100aa6:	e8 03 f8 ff ff       	call   c01002ae <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c0100aab:	c7 44 24 04 84 31 1b 	movl   $0xc01b3184,0x4(%esp)
c0100ab2:	c0 
c0100ab3:	c7 04 24 a3 c4 10 c0 	movl   $0xc010c4a3,(%esp)
c0100aba:	e8 ef f7 ff ff       	call   c01002ae <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c0100abf:	b8 84 31 1b c0       	mov    $0xc01b3184,%eax
c0100ac4:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c0100aca:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c0100acf:	29 c2                	sub    %eax,%edx
c0100ad1:	89 d0                	mov    %edx,%eax
c0100ad3:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c0100ad9:	85 c0                	test   %eax,%eax
c0100adb:	0f 48 c2             	cmovs  %edx,%eax
c0100ade:	c1 f8 0a             	sar    $0xa,%eax
c0100ae1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ae5:	c7 04 24 bc c4 10 c0 	movl   $0xc010c4bc,(%esp)
c0100aec:	e8 bd f7 ff ff       	call   c01002ae <cprintf>
}
c0100af1:	c9                   	leave  
c0100af2:	c3                   	ret    

c0100af3 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c0100af3:	55                   	push   %ebp
c0100af4:	89 e5                	mov    %esp,%ebp
c0100af6:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c0100afc:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100aff:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b03:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b06:	89 04 24             	mov    %eax,(%esp)
c0100b09:	e8 1a fb ff ff       	call   c0100628 <debuginfo_eip>
c0100b0e:	85 c0                	test   %eax,%eax
c0100b10:	74 15                	je     c0100b27 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c0100b12:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b15:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b19:	c7 04 24 e6 c4 10 c0 	movl   $0xc010c4e6,(%esp)
c0100b20:	e8 89 f7 ff ff       	call   c01002ae <cprintf>
c0100b25:	eb 6d                	jmp    c0100b94 <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100b27:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100b2e:	eb 1c                	jmp    c0100b4c <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
c0100b30:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100b33:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b36:	01 d0                	add    %edx,%eax
c0100b38:	0f b6 00             	movzbl (%eax),%eax
c0100b3b:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100b41:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100b44:	01 ca                	add    %ecx,%edx
c0100b46:	88 02                	mov    %al,(%edx)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100b48:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100b4c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100b4f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100b52:	7f dc                	jg     c0100b30 <print_debuginfo+0x3d>
        }
        fnname[j] = '\0';
c0100b54:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b5d:	01 d0                	add    %edx,%eax
c0100b5f:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c0100b62:	8b 45 ec             	mov    -0x14(%ebp),%eax
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100b65:	8b 55 08             	mov    0x8(%ebp),%edx
c0100b68:	89 d1                	mov    %edx,%ecx
c0100b6a:	29 c1                	sub    %eax,%ecx
c0100b6c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100b6f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100b72:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100b76:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100b7c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100b80:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100b84:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b88:	c7 04 24 02 c5 10 c0 	movl   $0xc010c502,(%esp)
c0100b8f:	e8 1a f7 ff ff       	call   c01002ae <cprintf>
    }
}
c0100b94:	c9                   	leave  
c0100b95:	c3                   	ret    

c0100b96 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0100b96:	55                   	push   %ebp
c0100b97:	89 e5                	mov    %esp,%ebp
c0100b99:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0100b9c:	8b 45 04             	mov    0x4(%ebp),%eax
c0100b9f:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0100ba2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100ba5:	c9                   	leave  
c0100ba6:	c3                   	ret    

c0100ba7 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0100ba7:	55                   	push   %ebp
c0100ba8:	89 e5                	mov    %esp,%ebp
c0100baa:	53                   	push   %ebx
c0100bab:	83 ec 44             	sub    $0x44,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0100bae:	89 e8                	mov    %ebp,%eax
c0100bb0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return ebp;
c0100bb3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp=read_ebp(),eip=read_eip();
c0100bb6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100bb9:	e8 d8 ff ff ff       	call   c0100b96 <read_eip>
c0100bbe:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int i;//这里在for循环里定义好像不行的样子就拿出来了
	for(i=0;ebp!=0&&i<STACKFRAME_DEPTH;i++)
c0100bc1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100bc8:	e9 8d 00 00 00       	jmp    c0100c5a <print_stackframe+0xb3>
    {   
		cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c0100bcd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100bd0:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100bd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bd7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bdb:	c7 04 24 14 c5 10 c0 	movl   $0xc010c514,(%esp)
c0100be2:	e8 c7 f6 ff ff       	call   c01002ae <cprintf>
		uint32_t *args = (uint32_t *)ebp + 2;       //ebp+8指向参数，+4指向返回值
c0100be7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bea:	83 c0 08             	add    $0x8,%eax
c0100bed:	89 45 e8             	mov    %eax,-0x18(%ebp)
		cprintf("arg :0x%08x 0x%08x 0x%08x 0x%08x\n",*(args+0),*(args+1),*(args+2),*(args+3));
c0100bf0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100bf3:	83 c0 0c             	add    $0xc,%eax
c0100bf6:	8b 18                	mov    (%eax),%ebx
c0100bf8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100bfb:	83 c0 08             	add    $0x8,%eax
c0100bfe:	8b 08                	mov    (%eax),%ecx
c0100c00:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100c03:	83 c0 04             	add    $0x4,%eax
c0100c06:	8b 10                	mov    (%eax),%edx
c0100c08:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100c0b:	8b 00                	mov    (%eax),%eax
c0100c0d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
c0100c11:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100c15:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100c19:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c1d:	c7 04 24 30 c5 10 c0 	movl   $0xc010c530,(%esp)
c0100c24:	e8 85 f6 ff ff       	call   c01002ae <cprintf>
        //依次打印调用函数的参数1 2 3 4
		cprintf("\n");
c0100c29:	c7 04 24 52 c5 10 c0 	movl   $0xc010c552,(%esp)
c0100c30:	e8 79 f6 ff ff       	call   c01002ae <cprintf>
		print_debuginfo(eip - 1);//eip指向的是下一条指令，所以这里减1  指针占4
c0100c35:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100c38:	83 e8 01             	sub    $0x1,%eax
c0100c3b:	89 04 24             	mov    %eax,(%esp)
c0100c3e:	e8 b0 fe ff ff       	call   c0100af3 <print_debuginfo>
		eip = ((uint32_t *)ebp)[1]; //此时eip指向返回地址
c0100c43:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c46:	83 c0 04             	add    $0x4,%eax
c0100c49:	8b 00                	mov    (%eax),%eax
c0100c4b:	89 45 f0             	mov    %eax,-0x10(%ebp)
		ebp = ((uint32_t *)ebp)[0];//ebp存的是调用者edp，所以这里就复原了调用前edp值
c0100c4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c51:	8b 00                	mov    (%eax),%eax
c0100c53:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for(i=0;ebp!=0&&i<STACKFRAME_DEPTH;i++)
c0100c56:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0100c5a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100c5e:	74 0a                	je     c0100c6a <print_stackframe+0xc3>
c0100c60:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100c64:	0f 8e 63 ff ff ff    	jle    c0100bcd <print_stackframe+0x26>
	}
}
c0100c6a:	83 c4 44             	add    $0x44,%esp
c0100c6d:	5b                   	pop    %ebx
c0100c6e:	5d                   	pop    %ebp
c0100c6f:	c3                   	ret    

c0100c70 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100c70:	55                   	push   %ebp
c0100c71:	89 e5                	mov    %esp,%ebp
c0100c73:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100c76:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100c7d:	eb 0c                	jmp    c0100c8b <parse+0x1b>
            *buf ++ = '\0';
c0100c7f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c82:	8d 50 01             	lea    0x1(%eax),%edx
c0100c85:	89 55 08             	mov    %edx,0x8(%ebp)
c0100c88:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100c8b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c8e:	0f b6 00             	movzbl (%eax),%eax
c0100c91:	84 c0                	test   %al,%al
c0100c93:	74 1d                	je     c0100cb2 <parse+0x42>
c0100c95:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c98:	0f b6 00             	movzbl (%eax),%eax
c0100c9b:	0f be c0             	movsbl %al,%eax
c0100c9e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ca2:	c7 04 24 d4 c5 10 c0 	movl   $0xc010c5d4,(%esp)
c0100ca9:	e8 c5 ab 00 00       	call   c010b873 <strchr>
c0100cae:	85 c0                	test   %eax,%eax
c0100cb0:	75 cd                	jne    c0100c7f <parse+0xf>
        }
        if (*buf == '\0') {
c0100cb2:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cb5:	0f b6 00             	movzbl (%eax),%eax
c0100cb8:	84 c0                	test   %al,%al
c0100cba:	75 02                	jne    c0100cbe <parse+0x4e>
            break;
c0100cbc:	eb 67                	jmp    c0100d25 <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100cbe:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100cc2:	75 14                	jne    c0100cd8 <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100cc4:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100ccb:	00 
c0100ccc:	c7 04 24 d9 c5 10 c0 	movl   $0xc010c5d9,(%esp)
c0100cd3:	e8 d6 f5 ff ff       	call   c01002ae <cprintf>
        }
        argv[argc ++] = buf;
c0100cd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cdb:	8d 50 01             	lea    0x1(%eax),%edx
c0100cde:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100ce1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100ce8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100ceb:	01 c2                	add    %eax,%edx
c0100ced:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cf0:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100cf2:	eb 04                	jmp    c0100cf8 <parse+0x88>
            buf ++;
c0100cf4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100cf8:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cfb:	0f b6 00             	movzbl (%eax),%eax
c0100cfe:	84 c0                	test   %al,%al
c0100d00:	74 1d                	je     c0100d1f <parse+0xaf>
c0100d02:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d05:	0f b6 00             	movzbl (%eax),%eax
c0100d08:	0f be c0             	movsbl %al,%eax
c0100d0b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d0f:	c7 04 24 d4 c5 10 c0 	movl   $0xc010c5d4,(%esp)
c0100d16:	e8 58 ab 00 00       	call   c010b873 <strchr>
c0100d1b:	85 c0                	test   %eax,%eax
c0100d1d:	74 d5                	je     c0100cf4 <parse+0x84>
        }
    }
c0100d1f:	90                   	nop
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100d20:	e9 66 ff ff ff       	jmp    c0100c8b <parse+0x1b>
    return argc;
c0100d25:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100d28:	c9                   	leave  
c0100d29:	c3                   	ret    

c0100d2a <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100d2a:	55                   	push   %ebp
c0100d2b:	89 e5                	mov    %esp,%ebp
c0100d2d:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100d30:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100d33:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d37:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d3a:	89 04 24             	mov    %eax,(%esp)
c0100d3d:	e8 2e ff ff ff       	call   c0100c70 <parse>
c0100d42:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100d45:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100d49:	75 0a                	jne    c0100d55 <runcmd+0x2b>
        return 0;
c0100d4b:	b8 00 00 00 00       	mov    $0x0,%eax
c0100d50:	e9 85 00 00 00       	jmp    c0100dda <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d55:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100d5c:	eb 5c                	jmp    c0100dba <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100d5e:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100d61:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d64:	89 d0                	mov    %edx,%eax
c0100d66:	01 c0                	add    %eax,%eax
c0100d68:	01 d0                	add    %edx,%eax
c0100d6a:	c1 e0 02             	shl    $0x2,%eax
c0100d6d:	05 00 c0 12 c0       	add    $0xc012c000,%eax
c0100d72:	8b 00                	mov    (%eax),%eax
c0100d74:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100d78:	89 04 24             	mov    %eax,(%esp)
c0100d7b:	e8 54 aa 00 00       	call   c010b7d4 <strcmp>
c0100d80:	85 c0                	test   %eax,%eax
c0100d82:	75 32                	jne    c0100db6 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100d84:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d87:	89 d0                	mov    %edx,%eax
c0100d89:	01 c0                	add    %eax,%eax
c0100d8b:	01 d0                	add    %edx,%eax
c0100d8d:	c1 e0 02             	shl    $0x2,%eax
c0100d90:	05 00 c0 12 c0       	add    $0xc012c000,%eax
c0100d95:	8b 40 08             	mov    0x8(%eax),%eax
c0100d98:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100d9b:	8d 4a ff             	lea    -0x1(%edx),%ecx
c0100d9e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100da1:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100da5:	8d 55 b0             	lea    -0x50(%ebp),%edx
c0100da8:	83 c2 04             	add    $0x4,%edx
c0100dab:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100daf:	89 0c 24             	mov    %ecx,(%esp)
c0100db2:	ff d0                	call   *%eax
c0100db4:	eb 24                	jmp    c0100dda <runcmd+0xb0>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100db6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100dba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100dbd:	83 f8 02             	cmp    $0x2,%eax
c0100dc0:	76 9c                	jbe    c0100d5e <runcmd+0x34>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100dc2:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100dc5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100dc9:	c7 04 24 f7 c5 10 c0 	movl   $0xc010c5f7,(%esp)
c0100dd0:	e8 d9 f4 ff ff       	call   c01002ae <cprintf>
    return 0;
c0100dd5:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100dda:	c9                   	leave  
c0100ddb:	c3                   	ret    

c0100ddc <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100ddc:	55                   	push   %ebp
c0100ddd:	89 e5                	mov    %esp,%ebp
c0100ddf:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100de2:	c7 04 24 10 c6 10 c0 	movl   $0xc010c610,(%esp)
c0100de9:	e8 c0 f4 ff ff       	call   c01002ae <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100dee:	c7 04 24 38 c6 10 c0 	movl   $0xc010c638,(%esp)
c0100df5:	e8 b4 f4 ff ff       	call   c01002ae <cprintf>

    if (tf != NULL) {
c0100dfa:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100dfe:	74 0b                	je     c0100e0b <kmonitor+0x2f>
        print_trapframe(tf);
c0100e00:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e03:	89 04 24             	mov    %eax,(%esp)
c0100e06:	e8 0c 16 00 00       	call   c0102417 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100e0b:	c7 04 24 5d c6 10 c0 	movl   $0xc010c65d,(%esp)
c0100e12:	e8 38 f5 ff ff       	call   c010034f <readline>
c0100e17:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100e1a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100e1e:	74 18                	je     c0100e38 <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
c0100e20:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e23:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100e27:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100e2a:	89 04 24             	mov    %eax,(%esp)
c0100e2d:	e8 f8 fe ff ff       	call   c0100d2a <runcmd>
c0100e32:	85 c0                	test   %eax,%eax
c0100e34:	79 02                	jns    c0100e38 <kmonitor+0x5c>
                break;
c0100e36:	eb 02                	jmp    c0100e3a <kmonitor+0x5e>
            }
        }
    }
c0100e38:	eb d1                	jmp    c0100e0b <kmonitor+0x2f>
}
c0100e3a:	c9                   	leave  
c0100e3b:	c3                   	ret    

c0100e3c <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100e3c:	55                   	push   %ebp
c0100e3d:	89 e5                	mov    %esp,%ebp
c0100e3f:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100e42:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100e49:	eb 3f                	jmp    c0100e8a <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100e4b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100e4e:	89 d0                	mov    %edx,%eax
c0100e50:	01 c0                	add    %eax,%eax
c0100e52:	01 d0                	add    %edx,%eax
c0100e54:	c1 e0 02             	shl    $0x2,%eax
c0100e57:	05 00 c0 12 c0       	add    $0xc012c000,%eax
c0100e5c:	8b 48 04             	mov    0x4(%eax),%ecx
c0100e5f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100e62:	89 d0                	mov    %edx,%eax
c0100e64:	01 c0                	add    %eax,%eax
c0100e66:	01 d0                	add    %edx,%eax
c0100e68:	c1 e0 02             	shl    $0x2,%eax
c0100e6b:	05 00 c0 12 c0       	add    $0xc012c000,%eax
c0100e70:	8b 00                	mov    (%eax),%eax
c0100e72:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100e76:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100e7a:	c7 04 24 61 c6 10 c0 	movl   $0xc010c661,(%esp)
c0100e81:	e8 28 f4 ff ff       	call   c01002ae <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100e86:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100e8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100e8d:	83 f8 02             	cmp    $0x2,%eax
c0100e90:	76 b9                	jbe    c0100e4b <mon_help+0xf>
    }
    return 0;
c0100e92:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e97:	c9                   	leave  
c0100e98:	c3                   	ret    

c0100e99 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100e99:	55                   	push   %ebp
c0100e9a:	89 e5                	mov    %esp,%ebp
c0100e9c:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100e9f:	e8 b9 fb ff ff       	call   c0100a5d <print_kerninfo>
    return 0;
c0100ea4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100ea9:	c9                   	leave  
c0100eaa:	c3                   	ret    

c0100eab <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100eab:	55                   	push   %ebp
c0100eac:	89 e5                	mov    %esp,%ebp
c0100eae:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100eb1:	e8 f1 fc ff ff       	call   c0100ba7 <print_stackframe>
    return 0;
c0100eb6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100ebb:	c9                   	leave  
c0100ebc:	c3                   	ret    

c0100ebd <ide_wait_ready>:
    unsigned int size;          // Size in Sectors
    unsigned char model[41];    // Model in String
} ide_devices[MAX_IDE];

static int
ide_wait_ready(unsigned short iobase, bool check_error) {
c0100ebd:	55                   	push   %ebp
c0100ebe:	89 e5                	mov    %esp,%ebp
c0100ec0:	83 ec 14             	sub    $0x14,%esp
c0100ec3:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ec6:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    int r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c0100eca:	90                   	nop
c0100ecb:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0100ecf:	83 c0 07             	add    $0x7,%eax
c0100ed2:	0f b7 c0             	movzwl %ax,%eax
c0100ed5:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100ed9:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100edd:	89 c2                	mov    %eax,%edx
c0100edf:	ec                   	in     (%dx),%al
c0100ee0:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0100ee3:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0100ee7:	0f b6 c0             	movzbl %al,%eax
c0100eea:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100eed:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ef0:	25 80 00 00 00       	and    $0x80,%eax
c0100ef5:	85 c0                	test   %eax,%eax
c0100ef7:	75 d2                	jne    c0100ecb <ide_wait_ready+0xe>
        /* nothing */;
    if (check_error && (r & (IDE_DF | IDE_ERR)) != 0) {
c0100ef9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0100efd:	74 11                	je     c0100f10 <ide_wait_ready+0x53>
c0100eff:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f02:	83 e0 21             	and    $0x21,%eax
c0100f05:	85 c0                	test   %eax,%eax
c0100f07:	74 07                	je     c0100f10 <ide_wait_ready+0x53>
        return -1;
c0100f09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100f0e:	eb 05                	jmp    c0100f15 <ide_wait_ready+0x58>
    }
    return 0;
c0100f10:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100f15:	c9                   	leave  
c0100f16:	c3                   	ret    

c0100f17 <ide_init>:

void
ide_init(void) {
c0100f17:	55                   	push   %ebp
c0100f18:	89 e5                	mov    %esp,%ebp
c0100f1a:	57                   	push   %edi
c0100f1b:	53                   	push   %ebx
c0100f1c:	81 ec 50 02 00 00    	sub    $0x250,%esp
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0100f22:	66 c7 45 f6 00 00    	movw   $0x0,-0xa(%ebp)
c0100f28:	e9 d6 02 00 00       	jmp    c0101203 <ide_init+0x2ec>
        /* assume that no device here */
        ide_devices[ideno].valid = 0;
c0100f2d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100f31:	c1 e0 03             	shl    $0x3,%eax
c0100f34:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0100f3b:	29 c2                	sub    %eax,%edx
c0100f3d:	8d 82 40 04 1b c0    	lea    -0x3fe4fbc0(%edx),%eax
c0100f43:	c6 00 00             	movb   $0x0,(%eax)

        iobase = IO_BASE(ideno);
c0100f46:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100f4a:	66 d1 e8             	shr    %ax
c0100f4d:	0f b7 c0             	movzwl %ax,%eax
c0100f50:	0f b7 04 85 6c c6 10 	movzwl -0x3fef3994(,%eax,4),%eax
c0100f57:	c0 
c0100f58:	66 89 45 ea          	mov    %ax,-0x16(%ebp)

        /* wait device ready */
        ide_wait_ready(iobase, 0);
c0100f5c:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100f60:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100f67:	00 
c0100f68:	89 04 24             	mov    %eax,(%esp)
c0100f6b:	e8 4d ff ff ff       	call   c0100ebd <ide_wait_ready>

        /* step1: select drive */
        outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4));
c0100f70:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100f74:	83 e0 01             	and    $0x1,%eax
c0100f77:	c1 e0 04             	shl    $0x4,%eax
c0100f7a:	83 c8 e0             	or     $0xffffffe0,%eax
c0100f7d:	0f b6 c0             	movzbl %al,%eax
c0100f80:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100f84:	83 c2 06             	add    $0x6,%edx
c0100f87:	0f b7 d2             	movzwl %dx,%edx
c0100f8a:	66 89 55 d2          	mov    %dx,-0x2e(%ebp)
c0100f8e:	88 45 d1             	mov    %al,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f91:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0100f95:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0100f99:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c0100f9a:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100f9e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100fa5:	00 
c0100fa6:	89 04 24             	mov    %eax,(%esp)
c0100fa9:	e8 0f ff ff ff       	call   c0100ebd <ide_wait_ready>

        /* step2: send ATA identify command */
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
c0100fae:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100fb2:	83 c0 07             	add    $0x7,%eax
c0100fb5:	0f b7 c0             	movzwl %ax,%eax
c0100fb8:	66 89 45 ce          	mov    %ax,-0x32(%ebp)
c0100fbc:	c6 45 cd ec          	movb   $0xec,-0x33(%ebp)
c0100fc0:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0100fc4:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0100fc8:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c0100fc9:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100fcd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100fd4:	00 
c0100fd5:	89 04 24             	mov    %eax,(%esp)
c0100fd8:	e8 e0 fe ff ff       	call   c0100ebd <ide_wait_ready>

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
c0100fdd:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100fe1:	83 c0 07             	add    $0x7,%eax
c0100fe4:	0f b7 c0             	movzwl %ax,%eax
c0100fe7:	66 89 45 ca          	mov    %ax,-0x36(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100feb:	0f b7 45 ca          	movzwl -0x36(%ebp),%eax
c0100fef:	89 c2                	mov    %eax,%edx
c0100ff1:	ec                   	in     (%dx),%al
c0100ff2:	88 45 c9             	mov    %al,-0x37(%ebp)
    return data;
c0100ff5:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0100ff9:	84 c0                	test   %al,%al
c0100ffb:	0f 84 f7 01 00 00    	je     c01011f8 <ide_init+0x2e1>
c0101001:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101005:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010100c:	00 
c010100d:	89 04 24             	mov    %eax,(%esp)
c0101010:	e8 a8 fe ff ff       	call   c0100ebd <ide_wait_ready>
c0101015:	85 c0                	test   %eax,%eax
c0101017:	0f 85 db 01 00 00    	jne    c01011f8 <ide_init+0x2e1>
            continue ;
        }

        /* device is ok */
        ide_devices[ideno].valid = 1;
c010101d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101021:	c1 e0 03             	shl    $0x3,%eax
c0101024:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010102b:	29 c2                	sub    %eax,%edx
c010102d:	8d 82 40 04 1b c0    	lea    -0x3fe4fbc0(%edx),%eax
c0101033:	c6 00 01             	movb   $0x1,(%eax)

        /* read identification space of the device */
        unsigned int buffer[128];
        insl(iobase + ISA_DATA, buffer, sizeof(buffer) / sizeof(unsigned int));
c0101036:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c010103a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c010103d:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0101043:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0101046:	c7 45 bc 80 00 00 00 	movl   $0x80,-0x44(%ebp)
    asm volatile (
c010104d:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0101050:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c0101053:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0101056:	89 cb                	mov    %ecx,%ebx
c0101058:	89 df                	mov    %ebx,%edi
c010105a:	89 c1                	mov    %eax,%ecx
c010105c:	fc                   	cld    
c010105d:	f2 6d                	repnz insl (%dx),%es:(%edi)
c010105f:	89 c8                	mov    %ecx,%eax
c0101061:	89 fb                	mov    %edi,%ebx
c0101063:	89 5d c0             	mov    %ebx,-0x40(%ebp)
c0101066:	89 45 bc             	mov    %eax,-0x44(%ebp)

        unsigned char *ident = (unsigned char *)buffer;
c0101069:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c010106f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        unsigned int sectors;
        unsigned int cmdsets = *(unsigned int *)(ident + IDE_IDENT_CMDSETS);
c0101072:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101075:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
c010107b:	89 45 e0             	mov    %eax,-0x20(%ebp)
        /* device use 48-bits or 28-bits addressing */
        if (cmdsets & (1 << 26)) {
c010107e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101081:	25 00 00 00 04       	and    $0x4000000,%eax
c0101086:	85 c0                	test   %eax,%eax
c0101088:	74 0e                	je     c0101098 <ide_init+0x181>
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA_EXT);
c010108a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010108d:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
c0101093:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0101096:	eb 09                	jmp    c01010a1 <ide_init+0x18a>
        }
        else {
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA);
c0101098:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010109b:	8b 40 78             	mov    0x78(%eax),%eax
c010109e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        ide_devices[ideno].sets = cmdsets;
c01010a1:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01010a5:	c1 e0 03             	shl    $0x3,%eax
c01010a8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01010af:	29 c2                	sub    %eax,%edx
c01010b1:	81 c2 40 04 1b c0    	add    $0xc01b0440,%edx
c01010b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01010ba:	89 42 04             	mov    %eax,0x4(%edx)
        ide_devices[ideno].size = sectors;
c01010bd:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01010c1:	c1 e0 03             	shl    $0x3,%eax
c01010c4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01010cb:	29 c2                	sub    %eax,%edx
c01010cd:	81 c2 40 04 1b c0    	add    $0xc01b0440,%edx
c01010d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01010d6:	89 42 08             	mov    %eax,0x8(%edx)

        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c01010d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01010dc:	83 c0 62             	add    $0x62,%eax
c01010df:	0f b7 00             	movzwl (%eax),%eax
c01010e2:	0f b7 c0             	movzwl %ax,%eax
c01010e5:	25 00 02 00 00       	and    $0x200,%eax
c01010ea:	85 c0                	test   %eax,%eax
c01010ec:	75 24                	jne    c0101112 <ide_init+0x1fb>
c01010ee:	c7 44 24 0c 74 c6 10 	movl   $0xc010c674,0xc(%esp)
c01010f5:	c0 
c01010f6:	c7 44 24 08 b7 c6 10 	movl   $0xc010c6b7,0x8(%esp)
c01010fd:	c0 
c01010fe:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c0101105:	00 
c0101106:	c7 04 24 cc c6 10 c0 	movl   $0xc010c6cc,(%esp)
c010110d:	e8 f3 f2 ff ff       	call   c0100405 <__panic>

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
c0101112:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101116:	c1 e0 03             	shl    $0x3,%eax
c0101119:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101120:	29 c2                	sub    %eax,%edx
c0101122:	8d 82 40 04 1b c0    	lea    -0x3fe4fbc0(%edx),%eax
c0101128:	83 c0 0c             	add    $0xc,%eax
c010112b:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010112e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101131:	83 c0 36             	add    $0x36,%eax
c0101134:	89 45 d8             	mov    %eax,-0x28(%ebp)
        unsigned int i, length = 40;
c0101137:	c7 45 d4 28 00 00 00 	movl   $0x28,-0x2c(%ebp)
        for (i = 0; i < length; i += 2) {
c010113e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0101145:	eb 34                	jmp    c010117b <ide_init+0x264>
            model[i] = data[i + 1], model[i + 1] = data[i];
c0101147:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010114a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010114d:	01 c2                	add    %eax,%edx
c010114f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101152:	8d 48 01             	lea    0x1(%eax),%ecx
c0101155:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101158:	01 c8                	add    %ecx,%eax
c010115a:	0f b6 00             	movzbl (%eax),%eax
c010115d:	88 02                	mov    %al,(%edx)
c010115f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101162:	8d 50 01             	lea    0x1(%eax),%edx
c0101165:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101168:	01 c2                	add    %eax,%edx
c010116a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010116d:	8b 4d d8             	mov    -0x28(%ebp),%ecx
c0101170:	01 c8                	add    %ecx,%eax
c0101172:	0f b6 00             	movzbl (%eax),%eax
c0101175:	88 02                	mov    %al,(%edx)
        for (i = 0; i < length; i += 2) {
c0101177:	83 45 ec 02          	addl   $0x2,-0x14(%ebp)
c010117b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010117e:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c0101181:	72 c4                	jb     c0101147 <ide_init+0x230>
        }
        do {
            model[i] = '\0';
c0101183:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101186:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101189:	01 d0                	add    %edx,%eax
c010118b:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c010118e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101191:	8d 50 ff             	lea    -0x1(%eax),%edx
c0101194:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0101197:	85 c0                	test   %eax,%eax
c0101199:	74 0f                	je     c01011aa <ide_init+0x293>
c010119b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010119e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01011a1:	01 d0                	add    %edx,%eax
c01011a3:	0f b6 00             	movzbl (%eax),%eax
c01011a6:	3c 20                	cmp    $0x20,%al
c01011a8:	74 d9                	je     c0101183 <ide_init+0x26c>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
c01011aa:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01011ae:	c1 e0 03             	shl    $0x3,%eax
c01011b1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01011b8:	29 c2                	sub    %eax,%edx
c01011ba:	8d 82 40 04 1b c0    	lea    -0x3fe4fbc0(%edx),%eax
c01011c0:	8d 48 0c             	lea    0xc(%eax),%ecx
c01011c3:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01011c7:	c1 e0 03             	shl    $0x3,%eax
c01011ca:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01011d1:	29 c2                	sub    %eax,%edx
c01011d3:	8d 82 40 04 1b c0    	lea    -0x3fe4fbc0(%edx),%eax
c01011d9:	8b 50 08             	mov    0x8(%eax),%edx
c01011dc:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01011e0:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01011e4:	89 54 24 08          	mov    %edx,0x8(%esp)
c01011e8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01011ec:	c7 04 24 de c6 10 c0 	movl   $0xc010c6de,(%esp)
c01011f3:	e8 b6 f0 ff ff       	call   c01002ae <cprintf>
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c01011f8:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01011fc:	83 c0 01             	add    $0x1,%eax
c01011ff:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c0101203:	66 83 7d f6 03       	cmpw   $0x3,-0xa(%ebp)
c0101208:	0f 86 1f fd ff ff    	jbe    c0100f2d <ide_init+0x16>
    }

    // enable ide interrupt
    pic_enable(IRQ_IDE1);
c010120e:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
c0101215:	e8 91 0e 00 00       	call   c01020ab <pic_enable>
    pic_enable(IRQ_IDE2);
c010121a:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
c0101221:	e8 85 0e 00 00       	call   c01020ab <pic_enable>
}
c0101226:	81 c4 50 02 00 00    	add    $0x250,%esp
c010122c:	5b                   	pop    %ebx
c010122d:	5f                   	pop    %edi
c010122e:	5d                   	pop    %ebp
c010122f:	c3                   	ret    

c0101230 <ide_device_valid>:

bool
ide_device_valid(unsigned short ideno) {
c0101230:	55                   	push   %ebp
c0101231:	89 e5                	mov    %esp,%ebp
c0101233:	83 ec 04             	sub    $0x4,%esp
c0101236:	8b 45 08             	mov    0x8(%ebp),%eax
c0101239:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    return VALID_IDE(ideno);
c010123d:	66 83 7d fc 03       	cmpw   $0x3,-0x4(%ebp)
c0101242:	77 24                	ja     c0101268 <ide_device_valid+0x38>
c0101244:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101248:	c1 e0 03             	shl    $0x3,%eax
c010124b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101252:	29 c2                	sub    %eax,%edx
c0101254:	8d 82 40 04 1b c0    	lea    -0x3fe4fbc0(%edx),%eax
c010125a:	0f b6 00             	movzbl (%eax),%eax
c010125d:	84 c0                	test   %al,%al
c010125f:	74 07                	je     c0101268 <ide_device_valid+0x38>
c0101261:	b8 01 00 00 00       	mov    $0x1,%eax
c0101266:	eb 05                	jmp    c010126d <ide_device_valid+0x3d>
c0101268:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010126d:	c9                   	leave  
c010126e:	c3                   	ret    

c010126f <ide_device_size>:

size_t
ide_device_size(unsigned short ideno) {
c010126f:	55                   	push   %ebp
c0101270:	89 e5                	mov    %esp,%ebp
c0101272:	83 ec 08             	sub    $0x8,%esp
c0101275:	8b 45 08             	mov    0x8(%ebp),%eax
c0101278:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    if (ide_device_valid(ideno)) {
c010127c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101280:	89 04 24             	mov    %eax,(%esp)
c0101283:	e8 a8 ff ff ff       	call   c0101230 <ide_device_valid>
c0101288:	85 c0                	test   %eax,%eax
c010128a:	74 1b                	je     c01012a7 <ide_device_size+0x38>
        return ide_devices[ideno].size;
c010128c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101290:	c1 e0 03             	shl    $0x3,%eax
c0101293:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010129a:	29 c2                	sub    %eax,%edx
c010129c:	8d 82 40 04 1b c0    	lea    -0x3fe4fbc0(%edx),%eax
c01012a2:	8b 40 08             	mov    0x8(%eax),%eax
c01012a5:	eb 05                	jmp    c01012ac <ide_device_size+0x3d>
    }
    return 0;
c01012a7:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01012ac:	c9                   	leave  
c01012ad:	c3                   	ret    

c01012ae <ide_read_secs>:

int
ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs) {
c01012ae:	55                   	push   %ebp
c01012af:	89 e5                	mov    %esp,%ebp
c01012b1:	57                   	push   %edi
c01012b2:	53                   	push   %ebx
c01012b3:	83 ec 50             	sub    $0x50,%esp
c01012b6:	8b 45 08             	mov    0x8(%ebp),%eax
c01012b9:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c01012bd:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c01012c4:	77 24                	ja     c01012ea <ide_read_secs+0x3c>
c01012c6:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c01012cb:	77 1d                	ja     c01012ea <ide_read_secs+0x3c>
c01012cd:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01012d1:	c1 e0 03             	shl    $0x3,%eax
c01012d4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01012db:	29 c2                	sub    %eax,%edx
c01012dd:	8d 82 40 04 1b c0    	lea    -0x3fe4fbc0(%edx),%eax
c01012e3:	0f b6 00             	movzbl (%eax),%eax
c01012e6:	84 c0                	test   %al,%al
c01012e8:	75 24                	jne    c010130e <ide_read_secs+0x60>
c01012ea:	c7 44 24 0c fc c6 10 	movl   $0xc010c6fc,0xc(%esp)
c01012f1:	c0 
c01012f2:	c7 44 24 08 b7 c6 10 	movl   $0xc010c6b7,0x8(%esp)
c01012f9:	c0 
c01012fa:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c0101301:	00 
c0101302:	c7 04 24 cc c6 10 c0 	movl   $0xc010c6cc,(%esp)
c0101309:	e8 f7 f0 ff ff       	call   c0100405 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c010130e:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101315:	77 0f                	ja     c0101326 <ide_read_secs+0x78>
c0101317:	8b 45 14             	mov    0x14(%ebp),%eax
c010131a:	8b 55 0c             	mov    0xc(%ebp),%edx
c010131d:	01 d0                	add    %edx,%eax
c010131f:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101324:	76 24                	jbe    c010134a <ide_read_secs+0x9c>
c0101326:	c7 44 24 0c 24 c7 10 	movl   $0xc010c724,0xc(%esp)
c010132d:	c0 
c010132e:	c7 44 24 08 b7 c6 10 	movl   $0xc010c6b7,0x8(%esp)
c0101335:	c0 
c0101336:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c010133d:	00 
c010133e:	c7 04 24 cc c6 10 c0 	movl   $0xc010c6cc,(%esp)
c0101345:	e8 bb f0 ff ff       	call   c0100405 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c010134a:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c010134e:	66 d1 e8             	shr    %ax
c0101351:	0f b7 c0             	movzwl %ax,%eax
c0101354:	0f b7 04 85 6c c6 10 	movzwl -0x3fef3994(,%eax,4),%eax
c010135b:	c0 
c010135c:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101360:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101364:	66 d1 e8             	shr    %ax
c0101367:	0f b7 c0             	movzwl %ax,%eax
c010136a:	0f b7 04 85 6e c6 10 	movzwl -0x3fef3992(,%eax,4),%eax
c0101371:	c0 
c0101372:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101376:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010137a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101381:	00 
c0101382:	89 04 24             	mov    %eax,(%esp)
c0101385:	e8 33 fb ff ff       	call   c0100ebd <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c010138a:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c010138e:	83 c0 02             	add    $0x2,%eax
c0101391:	0f b7 c0             	movzwl %ax,%eax
c0101394:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101398:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010139c:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01013a0:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01013a4:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c01013a5:	8b 45 14             	mov    0x14(%ebp),%eax
c01013a8:	0f b6 c0             	movzbl %al,%eax
c01013ab:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01013af:	83 c2 02             	add    $0x2,%edx
c01013b2:	0f b7 d2             	movzwl %dx,%edx
c01013b5:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c01013b9:	88 45 e9             	mov    %al,-0x17(%ebp)
c01013bc:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01013c0:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01013c4:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c01013c5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01013c8:	0f b6 c0             	movzbl %al,%eax
c01013cb:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01013cf:	83 c2 03             	add    $0x3,%edx
c01013d2:	0f b7 d2             	movzwl %dx,%edx
c01013d5:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01013d9:	88 45 e5             	mov    %al,-0x1b(%ebp)
c01013dc:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01013e0:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01013e4:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c01013e5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01013e8:	c1 e8 08             	shr    $0x8,%eax
c01013eb:	0f b6 c0             	movzbl %al,%eax
c01013ee:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01013f2:	83 c2 04             	add    $0x4,%edx
c01013f5:	0f b7 d2             	movzwl %dx,%edx
c01013f8:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c01013fc:	88 45 e1             	mov    %al,-0x1f(%ebp)
c01013ff:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101403:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101407:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101408:	8b 45 0c             	mov    0xc(%ebp),%eax
c010140b:	c1 e8 10             	shr    $0x10,%eax
c010140e:	0f b6 c0             	movzbl %al,%eax
c0101411:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101415:	83 c2 05             	add    $0x5,%edx
c0101418:	0f b7 d2             	movzwl %dx,%edx
c010141b:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c010141f:	88 45 dd             	mov    %al,-0x23(%ebp)
c0101422:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101426:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c010142a:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c010142b:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c010142f:	83 e0 01             	and    $0x1,%eax
c0101432:	c1 e0 04             	shl    $0x4,%eax
c0101435:	89 c2                	mov    %eax,%edx
c0101437:	8b 45 0c             	mov    0xc(%ebp),%eax
c010143a:	c1 e8 18             	shr    $0x18,%eax
c010143d:	83 e0 0f             	and    $0xf,%eax
c0101440:	09 d0                	or     %edx,%eax
c0101442:	83 c8 e0             	or     $0xffffffe0,%eax
c0101445:	0f b6 c0             	movzbl %al,%eax
c0101448:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010144c:	83 c2 06             	add    $0x6,%edx
c010144f:	0f b7 d2             	movzwl %dx,%edx
c0101452:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101456:	88 45 d9             	mov    %al,-0x27(%ebp)
c0101459:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c010145d:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101461:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);
c0101462:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101466:	83 c0 07             	add    $0x7,%eax
c0101469:	0f b7 c0             	movzwl %ax,%eax
c010146c:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101470:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
c0101474:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101478:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c010147c:	ee                   	out    %al,(%dx)

    int ret = 0;
c010147d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101484:	eb 5a                	jmp    c01014e0 <ide_read_secs+0x232>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101486:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010148a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101491:	00 
c0101492:	89 04 24             	mov    %eax,(%esp)
c0101495:	e8 23 fa ff ff       	call   c0100ebd <ide_wait_ready>
c010149a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010149d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01014a1:	74 02                	je     c01014a5 <ide_read_secs+0x1f7>
            goto out;
c01014a3:	eb 41                	jmp    c01014e6 <ide_read_secs+0x238>
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
c01014a5:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01014a9:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01014ac:	8b 45 10             	mov    0x10(%ebp),%eax
c01014af:	89 45 cc             	mov    %eax,-0x34(%ebp)
c01014b2:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile (
c01014b9:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01014bc:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c01014bf:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01014c2:	89 cb                	mov    %ecx,%ebx
c01014c4:	89 df                	mov    %ebx,%edi
c01014c6:	89 c1                	mov    %eax,%ecx
c01014c8:	fc                   	cld    
c01014c9:	f2 6d                	repnz insl (%dx),%es:(%edi)
c01014cb:	89 c8                	mov    %ecx,%eax
c01014cd:	89 fb                	mov    %edi,%ebx
c01014cf:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c01014d2:	89 45 c8             	mov    %eax,-0x38(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c01014d5:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c01014d9:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c01014e0:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c01014e4:	75 a0                	jne    c0101486 <ide_read_secs+0x1d8>
    }

out:
    return ret;
c01014e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01014e9:	83 c4 50             	add    $0x50,%esp
c01014ec:	5b                   	pop    %ebx
c01014ed:	5f                   	pop    %edi
c01014ee:	5d                   	pop    %ebp
c01014ef:	c3                   	ret    

c01014f0 <ide_write_secs>:

int
ide_write_secs(unsigned short ideno, uint32_t secno, const void *src, size_t nsecs) {
c01014f0:	55                   	push   %ebp
c01014f1:	89 e5                	mov    %esp,%ebp
c01014f3:	56                   	push   %esi
c01014f4:	53                   	push   %ebx
c01014f5:	83 ec 50             	sub    $0x50,%esp
c01014f8:	8b 45 08             	mov    0x8(%ebp),%eax
c01014fb:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c01014ff:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101506:	77 24                	ja     c010152c <ide_write_secs+0x3c>
c0101508:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c010150d:	77 1d                	ja     c010152c <ide_write_secs+0x3c>
c010150f:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101513:	c1 e0 03             	shl    $0x3,%eax
c0101516:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010151d:	29 c2                	sub    %eax,%edx
c010151f:	8d 82 40 04 1b c0    	lea    -0x3fe4fbc0(%edx),%eax
c0101525:	0f b6 00             	movzbl (%eax),%eax
c0101528:	84 c0                	test   %al,%al
c010152a:	75 24                	jne    c0101550 <ide_write_secs+0x60>
c010152c:	c7 44 24 0c fc c6 10 	movl   $0xc010c6fc,0xc(%esp)
c0101533:	c0 
c0101534:	c7 44 24 08 b7 c6 10 	movl   $0xc010c6b7,0x8(%esp)
c010153b:	c0 
c010153c:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c0101543:	00 
c0101544:	c7 04 24 cc c6 10 c0 	movl   $0xc010c6cc,(%esp)
c010154b:	e8 b5 ee ff ff       	call   c0100405 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101550:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101557:	77 0f                	ja     c0101568 <ide_write_secs+0x78>
c0101559:	8b 45 14             	mov    0x14(%ebp),%eax
c010155c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010155f:	01 d0                	add    %edx,%eax
c0101561:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101566:	76 24                	jbe    c010158c <ide_write_secs+0x9c>
c0101568:	c7 44 24 0c 24 c7 10 	movl   $0xc010c724,0xc(%esp)
c010156f:	c0 
c0101570:	c7 44 24 08 b7 c6 10 	movl   $0xc010c6b7,0x8(%esp)
c0101577:	c0 
c0101578:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
c010157f:	00 
c0101580:	c7 04 24 cc c6 10 c0 	movl   $0xc010c6cc,(%esp)
c0101587:	e8 79 ee ff ff       	call   c0100405 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c010158c:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101590:	66 d1 e8             	shr    %ax
c0101593:	0f b7 c0             	movzwl %ax,%eax
c0101596:	0f b7 04 85 6c c6 10 	movzwl -0x3fef3994(,%eax,4),%eax
c010159d:	c0 
c010159e:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c01015a2:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01015a6:	66 d1 e8             	shr    %ax
c01015a9:	0f b7 c0             	movzwl %ax,%eax
c01015ac:	0f b7 04 85 6e c6 10 	movzwl -0x3fef3992(,%eax,4),%eax
c01015b3:	c0 
c01015b4:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c01015b8:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01015bc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01015c3:	00 
c01015c4:	89 04 24             	mov    %eax,(%esp)
c01015c7:	e8 f1 f8 ff ff       	call   c0100ebd <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c01015cc:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01015d0:	83 c0 02             	add    $0x2,%eax
c01015d3:	0f b7 c0             	movzwl %ax,%eax
c01015d6:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c01015da:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01015de:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01015e2:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01015e6:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c01015e7:	8b 45 14             	mov    0x14(%ebp),%eax
c01015ea:	0f b6 c0             	movzbl %al,%eax
c01015ed:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01015f1:	83 c2 02             	add    $0x2,%edx
c01015f4:	0f b7 d2             	movzwl %dx,%edx
c01015f7:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c01015fb:	88 45 e9             	mov    %al,-0x17(%ebp)
c01015fe:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101602:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101606:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101607:	8b 45 0c             	mov    0xc(%ebp),%eax
c010160a:	0f b6 c0             	movzbl %al,%eax
c010160d:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101611:	83 c2 03             	add    $0x3,%edx
c0101614:	0f b7 d2             	movzwl %dx,%edx
c0101617:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c010161b:	88 45 e5             	mov    %al,-0x1b(%ebp)
c010161e:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101622:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101626:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101627:	8b 45 0c             	mov    0xc(%ebp),%eax
c010162a:	c1 e8 08             	shr    $0x8,%eax
c010162d:	0f b6 c0             	movzbl %al,%eax
c0101630:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101634:	83 c2 04             	add    $0x4,%edx
c0101637:	0f b7 d2             	movzwl %dx,%edx
c010163a:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c010163e:	88 45 e1             	mov    %al,-0x1f(%ebp)
c0101641:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101645:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101649:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c010164a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010164d:	c1 e8 10             	shr    $0x10,%eax
c0101650:	0f b6 c0             	movzbl %al,%eax
c0101653:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101657:	83 c2 05             	add    $0x5,%edx
c010165a:	0f b7 d2             	movzwl %dx,%edx
c010165d:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0101661:	88 45 dd             	mov    %al,-0x23(%ebp)
c0101664:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101668:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c010166c:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c010166d:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101671:	83 e0 01             	and    $0x1,%eax
c0101674:	c1 e0 04             	shl    $0x4,%eax
c0101677:	89 c2                	mov    %eax,%edx
c0101679:	8b 45 0c             	mov    0xc(%ebp),%eax
c010167c:	c1 e8 18             	shr    $0x18,%eax
c010167f:	83 e0 0f             	and    $0xf,%eax
c0101682:	09 d0                	or     %edx,%eax
c0101684:	83 c8 e0             	or     $0xffffffe0,%eax
c0101687:	0f b6 c0             	movzbl %al,%eax
c010168a:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010168e:	83 c2 06             	add    $0x6,%edx
c0101691:	0f b7 d2             	movzwl %dx,%edx
c0101694:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101698:	88 45 d9             	mov    %al,-0x27(%ebp)
c010169b:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c010169f:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c01016a3:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);
c01016a4:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01016a8:	83 c0 07             	add    $0x7,%eax
c01016ab:	0f b7 c0             	movzwl %ax,%eax
c01016ae:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c01016b2:	c6 45 d5 30          	movb   $0x30,-0x2b(%ebp)
c01016b6:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c01016ba:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c01016be:	ee                   	out    %al,(%dx)

    int ret = 0;
c01016bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c01016c6:	eb 5a                	jmp    c0101722 <ide_write_secs+0x232>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c01016c8:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01016cc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01016d3:	00 
c01016d4:	89 04 24             	mov    %eax,(%esp)
c01016d7:	e8 e1 f7 ff ff       	call   c0100ebd <ide_wait_ready>
c01016dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01016df:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01016e3:	74 02                	je     c01016e7 <ide_write_secs+0x1f7>
            goto out;
c01016e5:	eb 41                	jmp    c0101728 <ide_write_secs+0x238>
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
c01016e7:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01016eb:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01016ee:	8b 45 10             	mov    0x10(%ebp),%eax
c01016f1:	89 45 cc             	mov    %eax,-0x34(%ebp)
c01016f4:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile (
c01016fb:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01016fe:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0101701:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0101704:	89 cb                	mov    %ecx,%ebx
c0101706:	89 de                	mov    %ebx,%esi
c0101708:	89 c1                	mov    %eax,%ecx
c010170a:	fc                   	cld    
c010170b:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
c010170d:	89 c8                	mov    %ecx,%eax
c010170f:	89 f3                	mov    %esi,%ebx
c0101711:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0101714:	89 45 c8             	mov    %eax,-0x38(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0101717:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c010171b:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0101722:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101726:	75 a0                	jne    c01016c8 <ide_write_secs+0x1d8>
    }

out:
    return ret;
c0101728:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010172b:	83 c4 50             	add    $0x50,%esp
c010172e:	5b                   	pop    %ebx
c010172f:	5e                   	pop    %esi
c0101730:	5d                   	pop    %ebp
c0101731:	c3                   	ret    

c0101732 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0101732:	55                   	push   %ebp
c0101733:	89 e5                	mov    %esp,%ebp
c0101735:	83 ec 28             	sub    $0x28,%esp
c0101738:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c010173e:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101742:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101746:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010174a:	ee                   	out    %al,(%dx)
c010174b:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0101751:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
c0101755:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101759:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010175d:	ee                   	out    %al,(%dx)
c010175e:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
c0101764:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
c0101768:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010176c:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101770:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0101771:	c7 05 78 30 1b c0 00 	movl   $0x0,0xc01b3078
c0101778:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c010177b:	c7 04 24 5e c7 10 c0 	movl   $0xc010c75e,(%esp)
c0101782:	e8 27 eb ff ff       	call   c01002ae <cprintf>
    pic_enable(IRQ_TIMER);
c0101787:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010178e:	e8 18 09 00 00       	call   c01020ab <pic_enable>
}
c0101793:	c9                   	leave  
c0101794:	c3                   	ret    

c0101795 <__intr_save>:
#include <assert.h>
#include <atomic.h>
#include <sched.h>

static inline bool
__intr_save(void) {
c0101795:	55                   	push   %ebp
c0101796:	89 e5                	mov    %esp,%ebp
c0101798:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010179b:	9c                   	pushf  
c010179c:	58                   	pop    %eax
c010179d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01017a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01017a3:	25 00 02 00 00       	and    $0x200,%eax
c01017a8:	85 c0                	test   %eax,%eax
c01017aa:	74 0c                	je     c01017b8 <__intr_save+0x23>
        intr_disable();
c01017ac:	e8 69 0a 00 00       	call   c010221a <intr_disable>
        return 1;
c01017b1:	b8 01 00 00 00       	mov    $0x1,%eax
c01017b6:	eb 05                	jmp    c01017bd <__intr_save+0x28>
    }
    return 0;
c01017b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01017bd:	c9                   	leave  
c01017be:	c3                   	ret    

c01017bf <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c01017bf:	55                   	push   %ebp
c01017c0:	89 e5                	mov    %esp,%ebp
c01017c2:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01017c5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01017c9:	74 05                	je     c01017d0 <__intr_restore+0x11>
        intr_enable();
c01017cb:	e8 44 0a 00 00       	call   c0102214 <intr_enable>
    }
}
c01017d0:	c9                   	leave  
c01017d1:	c3                   	ret    

c01017d2 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c01017d2:	55                   	push   %ebp
c01017d3:	89 e5                	mov    %esp,%ebp
c01017d5:	83 ec 10             	sub    $0x10,%esp
c01017d8:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01017de:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c01017e2:	89 c2                	mov    %eax,%edx
c01017e4:	ec                   	in     (%dx),%al
c01017e5:	88 45 fd             	mov    %al,-0x3(%ebp)
c01017e8:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c01017ee:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01017f2:	89 c2                	mov    %eax,%edx
c01017f4:	ec                   	in     (%dx),%al
c01017f5:	88 45 f9             	mov    %al,-0x7(%ebp)
c01017f8:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c01017fe:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101802:	89 c2                	mov    %eax,%edx
c0101804:	ec                   	in     (%dx),%al
c0101805:	88 45 f5             	mov    %al,-0xb(%ebp)
c0101808:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
c010180e:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101812:	89 c2                	mov    %eax,%edx
c0101814:	ec                   	in     (%dx),%al
c0101815:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0101818:	c9                   	leave  
c0101819:	c3                   	ret    

c010181a <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c010181a:	55                   	push   %ebp
c010181b:	89 e5                	mov    %esp,%ebp
c010181d:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0101820:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0101827:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010182a:	0f b7 00             	movzwl (%eax),%eax
c010182d:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0101831:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101834:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0101839:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010183c:	0f b7 00             	movzwl (%eax),%eax
c010183f:	66 3d 5a a5          	cmp    $0xa55a,%ax
c0101843:	74 12                	je     c0101857 <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0101845:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c010184c:	66 c7 05 26 05 1b c0 	movw   $0x3b4,0xc01b0526
c0101853:	b4 03 
c0101855:	eb 13                	jmp    c010186a <cga_init+0x50>
    } else {
        *cp = was;
c0101857:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010185a:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c010185e:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0101861:	66 c7 05 26 05 1b c0 	movw   $0x3d4,0xc01b0526
c0101868:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c010186a:	0f b7 05 26 05 1b c0 	movzwl 0xc01b0526,%eax
c0101871:	0f b7 c0             	movzwl %ax,%eax
c0101874:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101878:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010187c:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101880:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101884:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0101885:	0f b7 05 26 05 1b c0 	movzwl 0xc01b0526,%eax
c010188c:	83 c0 01             	add    $0x1,%eax
c010188f:	0f b7 c0             	movzwl %ax,%eax
c0101892:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101896:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c010189a:	89 c2                	mov    %eax,%edx
c010189c:	ec                   	in     (%dx),%al
c010189d:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c01018a0:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01018a4:	0f b6 c0             	movzbl %al,%eax
c01018a7:	c1 e0 08             	shl    $0x8,%eax
c01018aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c01018ad:	0f b7 05 26 05 1b c0 	movzwl 0xc01b0526,%eax
c01018b4:	0f b7 c0             	movzwl %ax,%eax
c01018b7:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c01018bb:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018bf:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01018c3:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01018c7:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c01018c8:	0f b7 05 26 05 1b c0 	movzwl 0xc01b0526,%eax
c01018cf:	83 c0 01             	add    $0x1,%eax
c01018d2:	0f b7 c0             	movzwl %ax,%eax
c01018d5:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01018d9:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c01018dd:	89 c2                	mov    %eax,%edx
c01018df:	ec                   	in     (%dx),%al
c01018e0:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
c01018e3:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01018e7:	0f b6 c0             	movzbl %al,%eax
c01018ea:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c01018ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018f0:	a3 20 05 1b c0       	mov    %eax,0xc01b0520
    crt_pos = pos;
c01018f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01018f8:	66 a3 24 05 1b c0    	mov    %ax,0xc01b0524
}
c01018fe:	c9                   	leave  
c01018ff:	c3                   	ret    

c0101900 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0101900:	55                   	push   %ebp
c0101901:	89 e5                	mov    %esp,%ebp
c0101903:	83 ec 48             	sub    $0x48,%esp
c0101906:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c010190c:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101910:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101914:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101918:	ee                   	out    %al,(%dx)
c0101919:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
c010191f:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
c0101923:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101927:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010192b:	ee                   	out    %al,(%dx)
c010192c:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
c0101932:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
c0101936:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010193a:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010193e:	ee                   	out    %al,(%dx)
c010193f:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0101945:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
c0101949:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c010194d:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101951:	ee                   	out    %al,(%dx)
c0101952:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
c0101958:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
c010195c:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101960:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101964:	ee                   	out    %al,(%dx)
c0101965:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
c010196b:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
c010196f:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101973:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101977:	ee                   	out    %al,(%dx)
c0101978:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c010197e:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
c0101982:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101986:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c010198a:	ee                   	out    %al,(%dx)
c010198b:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101991:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
c0101995:	89 c2                	mov    %eax,%edx
c0101997:	ec                   	in     (%dx),%al
c0101998:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
c010199b:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c010199f:	3c ff                	cmp    $0xff,%al
c01019a1:	0f 95 c0             	setne  %al
c01019a4:	0f b6 c0             	movzbl %al,%eax
c01019a7:	a3 28 05 1b c0       	mov    %eax,0xc01b0528
c01019ac:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01019b2:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
c01019b6:	89 c2                	mov    %eax,%edx
c01019b8:	ec                   	in     (%dx),%al
c01019b9:	88 45 d5             	mov    %al,-0x2b(%ebp)
c01019bc:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
c01019c2:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c01019c6:	89 c2                	mov    %eax,%edx
c01019c8:	ec                   	in     (%dx),%al
c01019c9:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c01019cc:	a1 28 05 1b c0       	mov    0xc01b0528,%eax
c01019d1:	85 c0                	test   %eax,%eax
c01019d3:	74 0c                	je     c01019e1 <serial_init+0xe1>
        pic_enable(IRQ_COM1);
c01019d5:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c01019dc:	e8 ca 06 00 00       	call   c01020ab <pic_enable>
    }
}
c01019e1:	c9                   	leave  
c01019e2:	c3                   	ret    

c01019e3 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c01019e3:	55                   	push   %ebp
c01019e4:	89 e5                	mov    %esp,%ebp
c01019e6:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01019e9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01019f0:	eb 09                	jmp    c01019fb <lpt_putc_sub+0x18>
        delay();
c01019f2:	e8 db fd ff ff       	call   c01017d2 <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01019f7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c01019fb:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c0101a01:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101a05:	89 c2                	mov    %eax,%edx
c0101a07:	ec                   	in     (%dx),%al
c0101a08:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101a0b:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101a0f:	84 c0                	test   %al,%al
c0101a11:	78 09                	js     c0101a1c <lpt_putc_sub+0x39>
c0101a13:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101a1a:	7e d6                	jle    c01019f2 <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
c0101a1c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a1f:	0f b6 c0             	movzbl %al,%eax
c0101a22:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
c0101a28:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101a2b:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101a2f:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101a33:	ee                   	out    %al,(%dx)
c0101a34:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c0101a3a:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c0101a3e:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101a42:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101a46:	ee                   	out    %al,(%dx)
c0101a47:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
c0101a4d:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
c0101a51:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101a55:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101a59:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c0101a5a:	c9                   	leave  
c0101a5b:	c3                   	ret    

c0101a5c <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c0101a5c:	55                   	push   %ebp
c0101a5d:	89 e5                	mov    %esp,%ebp
c0101a5f:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101a62:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101a66:	74 0d                	je     c0101a75 <lpt_putc+0x19>
        lpt_putc_sub(c);
c0101a68:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a6b:	89 04 24             	mov    %eax,(%esp)
c0101a6e:	e8 70 ff ff ff       	call   c01019e3 <lpt_putc_sub>
c0101a73:	eb 24                	jmp    c0101a99 <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
c0101a75:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101a7c:	e8 62 ff ff ff       	call   c01019e3 <lpt_putc_sub>
        lpt_putc_sub(' ');
c0101a81:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101a88:	e8 56 ff ff ff       	call   c01019e3 <lpt_putc_sub>
        lpt_putc_sub('\b');
c0101a8d:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101a94:	e8 4a ff ff ff       	call   c01019e3 <lpt_putc_sub>
    }
}
c0101a99:	c9                   	leave  
c0101a9a:	c3                   	ret    

c0101a9b <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0101a9b:	55                   	push   %ebp
c0101a9c:	89 e5                	mov    %esp,%ebp
c0101a9e:	53                   	push   %ebx
c0101a9f:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c0101aa2:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aa5:	b0 00                	mov    $0x0,%al
c0101aa7:	85 c0                	test   %eax,%eax
c0101aa9:	75 07                	jne    c0101ab2 <cga_putc+0x17>
        c |= 0x0700;
c0101aab:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0101ab2:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ab5:	0f b6 c0             	movzbl %al,%eax
c0101ab8:	83 f8 0a             	cmp    $0xa,%eax
c0101abb:	74 4c                	je     c0101b09 <cga_putc+0x6e>
c0101abd:	83 f8 0d             	cmp    $0xd,%eax
c0101ac0:	74 57                	je     c0101b19 <cga_putc+0x7e>
c0101ac2:	83 f8 08             	cmp    $0x8,%eax
c0101ac5:	0f 85 88 00 00 00    	jne    c0101b53 <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
c0101acb:	0f b7 05 24 05 1b c0 	movzwl 0xc01b0524,%eax
c0101ad2:	66 85 c0             	test   %ax,%ax
c0101ad5:	74 30                	je     c0101b07 <cga_putc+0x6c>
            crt_pos --;
c0101ad7:	0f b7 05 24 05 1b c0 	movzwl 0xc01b0524,%eax
c0101ade:	83 e8 01             	sub    $0x1,%eax
c0101ae1:	66 a3 24 05 1b c0    	mov    %ax,0xc01b0524
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c0101ae7:	a1 20 05 1b c0       	mov    0xc01b0520,%eax
c0101aec:	0f b7 15 24 05 1b c0 	movzwl 0xc01b0524,%edx
c0101af3:	0f b7 d2             	movzwl %dx,%edx
c0101af6:	01 d2                	add    %edx,%edx
c0101af8:	01 c2                	add    %eax,%edx
c0101afa:	8b 45 08             	mov    0x8(%ebp),%eax
c0101afd:	b0 00                	mov    $0x0,%al
c0101aff:	83 c8 20             	or     $0x20,%eax
c0101b02:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c0101b05:	eb 72                	jmp    c0101b79 <cga_putc+0xde>
c0101b07:	eb 70                	jmp    c0101b79 <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
c0101b09:	0f b7 05 24 05 1b c0 	movzwl 0xc01b0524,%eax
c0101b10:	83 c0 50             	add    $0x50,%eax
c0101b13:	66 a3 24 05 1b c0    	mov    %ax,0xc01b0524
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c0101b19:	0f b7 1d 24 05 1b c0 	movzwl 0xc01b0524,%ebx
c0101b20:	0f b7 0d 24 05 1b c0 	movzwl 0xc01b0524,%ecx
c0101b27:	0f b7 c1             	movzwl %cx,%eax
c0101b2a:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
c0101b30:	c1 e8 10             	shr    $0x10,%eax
c0101b33:	89 c2                	mov    %eax,%edx
c0101b35:	66 c1 ea 06          	shr    $0x6,%dx
c0101b39:	89 d0                	mov    %edx,%eax
c0101b3b:	c1 e0 02             	shl    $0x2,%eax
c0101b3e:	01 d0                	add    %edx,%eax
c0101b40:	c1 e0 04             	shl    $0x4,%eax
c0101b43:	29 c1                	sub    %eax,%ecx
c0101b45:	89 ca                	mov    %ecx,%edx
c0101b47:	89 d8                	mov    %ebx,%eax
c0101b49:	29 d0                	sub    %edx,%eax
c0101b4b:	66 a3 24 05 1b c0    	mov    %ax,0xc01b0524
        break;
c0101b51:	eb 26                	jmp    c0101b79 <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c0101b53:	8b 0d 20 05 1b c0    	mov    0xc01b0520,%ecx
c0101b59:	0f b7 05 24 05 1b c0 	movzwl 0xc01b0524,%eax
c0101b60:	8d 50 01             	lea    0x1(%eax),%edx
c0101b63:	66 89 15 24 05 1b c0 	mov    %dx,0xc01b0524
c0101b6a:	0f b7 c0             	movzwl %ax,%eax
c0101b6d:	01 c0                	add    %eax,%eax
c0101b6f:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c0101b72:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b75:	66 89 02             	mov    %ax,(%edx)
        break;
c0101b78:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c0101b79:	0f b7 05 24 05 1b c0 	movzwl 0xc01b0524,%eax
c0101b80:	66 3d cf 07          	cmp    $0x7cf,%ax
c0101b84:	76 5b                	jbe    c0101be1 <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c0101b86:	a1 20 05 1b c0       	mov    0xc01b0520,%eax
c0101b8b:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0101b91:	a1 20 05 1b c0       	mov    0xc01b0520,%eax
c0101b96:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c0101b9d:	00 
c0101b9e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101ba2:	89 04 24             	mov    %eax,(%esp)
c0101ba5:	e8 c7 9e 00 00       	call   c010ba71 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101baa:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101bb1:	eb 15                	jmp    c0101bc8 <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
c0101bb3:	a1 20 05 1b c0       	mov    0xc01b0520,%eax
c0101bb8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101bbb:	01 d2                	add    %edx,%edx
c0101bbd:	01 d0                	add    %edx,%eax
c0101bbf:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101bc4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101bc8:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c0101bcf:	7e e2                	jle    c0101bb3 <cga_putc+0x118>
        }
        crt_pos -= CRT_COLS;
c0101bd1:	0f b7 05 24 05 1b c0 	movzwl 0xc01b0524,%eax
c0101bd8:	83 e8 50             	sub    $0x50,%eax
c0101bdb:	66 a3 24 05 1b c0    	mov    %ax,0xc01b0524
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c0101be1:	0f b7 05 26 05 1b c0 	movzwl 0xc01b0526,%eax
c0101be8:	0f b7 c0             	movzwl %ax,%eax
c0101beb:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101bef:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
c0101bf3:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101bf7:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101bfb:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c0101bfc:	0f b7 05 24 05 1b c0 	movzwl 0xc01b0524,%eax
c0101c03:	66 c1 e8 08          	shr    $0x8,%ax
c0101c07:	0f b6 c0             	movzbl %al,%eax
c0101c0a:	0f b7 15 26 05 1b c0 	movzwl 0xc01b0526,%edx
c0101c11:	83 c2 01             	add    $0x1,%edx
c0101c14:	0f b7 d2             	movzwl %dx,%edx
c0101c17:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
c0101c1b:	88 45 ed             	mov    %al,-0x13(%ebp)
c0101c1e:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101c22:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101c26:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c0101c27:	0f b7 05 26 05 1b c0 	movzwl 0xc01b0526,%eax
c0101c2e:	0f b7 c0             	movzwl %ax,%eax
c0101c31:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c0101c35:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
c0101c39:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101c3d:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101c41:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c0101c42:	0f b7 05 24 05 1b c0 	movzwl 0xc01b0524,%eax
c0101c49:	0f b6 c0             	movzbl %al,%eax
c0101c4c:	0f b7 15 26 05 1b c0 	movzwl 0xc01b0526,%edx
c0101c53:	83 c2 01             	add    $0x1,%edx
c0101c56:	0f b7 d2             	movzwl %dx,%edx
c0101c59:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101c5d:	88 45 e5             	mov    %al,-0x1b(%ebp)
c0101c60:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101c64:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101c68:	ee                   	out    %al,(%dx)
}
c0101c69:	83 c4 34             	add    $0x34,%esp
c0101c6c:	5b                   	pop    %ebx
c0101c6d:	5d                   	pop    %ebp
c0101c6e:	c3                   	ret    

c0101c6f <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c0101c6f:	55                   	push   %ebp
c0101c70:	89 e5                	mov    %esp,%ebp
c0101c72:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101c75:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101c7c:	eb 09                	jmp    c0101c87 <serial_putc_sub+0x18>
        delay();
c0101c7e:	e8 4f fb ff ff       	call   c01017d2 <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101c83:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0101c87:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101c8d:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101c91:	89 c2                	mov    %eax,%edx
c0101c93:	ec                   	in     (%dx),%al
c0101c94:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101c97:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101c9b:	0f b6 c0             	movzbl %al,%eax
c0101c9e:	83 e0 20             	and    $0x20,%eax
c0101ca1:	85 c0                	test   %eax,%eax
c0101ca3:	75 09                	jne    c0101cae <serial_putc_sub+0x3f>
c0101ca5:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101cac:	7e d0                	jle    c0101c7e <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
c0101cae:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cb1:	0f b6 c0             	movzbl %al,%eax
c0101cb4:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101cba:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101cbd:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101cc1:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101cc5:	ee                   	out    %al,(%dx)
}
c0101cc6:	c9                   	leave  
c0101cc7:	c3                   	ret    

c0101cc8 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101cc8:	55                   	push   %ebp
c0101cc9:	89 e5                	mov    %esp,%ebp
c0101ccb:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101cce:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101cd2:	74 0d                	je     c0101ce1 <serial_putc+0x19>
        serial_putc_sub(c);
c0101cd4:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cd7:	89 04 24             	mov    %eax,(%esp)
c0101cda:	e8 90 ff ff ff       	call   c0101c6f <serial_putc_sub>
c0101cdf:	eb 24                	jmp    c0101d05 <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
c0101ce1:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101ce8:	e8 82 ff ff ff       	call   c0101c6f <serial_putc_sub>
        serial_putc_sub(' ');
c0101ced:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101cf4:	e8 76 ff ff ff       	call   c0101c6f <serial_putc_sub>
        serial_putc_sub('\b');
c0101cf9:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101d00:	e8 6a ff ff ff       	call   c0101c6f <serial_putc_sub>
    }
}
c0101d05:	c9                   	leave  
c0101d06:	c3                   	ret    

c0101d07 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0101d07:	55                   	push   %ebp
c0101d08:	89 e5                	mov    %esp,%ebp
c0101d0a:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0101d0d:	eb 33                	jmp    c0101d42 <cons_intr+0x3b>
        if (c != 0) {
c0101d0f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101d13:	74 2d                	je     c0101d42 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c0101d15:	a1 44 07 1b c0       	mov    0xc01b0744,%eax
c0101d1a:	8d 50 01             	lea    0x1(%eax),%edx
c0101d1d:	89 15 44 07 1b c0    	mov    %edx,0xc01b0744
c0101d23:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101d26:	88 90 40 05 1b c0    	mov    %dl,-0x3fe4fac0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0101d2c:	a1 44 07 1b c0       	mov    0xc01b0744,%eax
c0101d31:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101d36:	75 0a                	jne    c0101d42 <cons_intr+0x3b>
                cons.wpos = 0;
c0101d38:	c7 05 44 07 1b c0 00 	movl   $0x0,0xc01b0744
c0101d3f:	00 00 00 
    while ((c = (*proc)()) != -1) {
c0101d42:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d45:	ff d0                	call   *%eax
c0101d47:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101d4a:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0101d4e:	75 bf                	jne    c0101d0f <cons_intr+0x8>
            }
        }
    }
}
c0101d50:	c9                   	leave  
c0101d51:	c3                   	ret    

c0101d52 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c0101d52:	55                   	push   %ebp
c0101d53:	89 e5                	mov    %esp,%ebp
c0101d55:	83 ec 10             	sub    $0x10,%esp
c0101d58:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101d5e:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101d62:	89 c2                	mov    %eax,%edx
c0101d64:	ec                   	in     (%dx),%al
c0101d65:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101d68:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c0101d6c:	0f b6 c0             	movzbl %al,%eax
c0101d6f:	83 e0 01             	and    $0x1,%eax
c0101d72:	85 c0                	test   %eax,%eax
c0101d74:	75 07                	jne    c0101d7d <serial_proc_data+0x2b>
        return -1;
c0101d76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101d7b:	eb 2a                	jmp    c0101da7 <serial_proc_data+0x55>
c0101d7d:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101d83:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101d87:	89 c2                	mov    %eax,%edx
c0101d89:	ec                   	in     (%dx),%al
c0101d8a:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c0101d8d:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c0101d91:	0f b6 c0             	movzbl %al,%eax
c0101d94:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0101d97:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101d9b:	75 07                	jne    c0101da4 <serial_proc_data+0x52>
        c = '\b';
c0101d9d:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101da4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101da7:	c9                   	leave  
c0101da8:	c3                   	ret    

c0101da9 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101da9:	55                   	push   %ebp
c0101daa:	89 e5                	mov    %esp,%ebp
c0101dac:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c0101daf:	a1 28 05 1b c0       	mov    0xc01b0528,%eax
c0101db4:	85 c0                	test   %eax,%eax
c0101db6:	74 0c                	je     c0101dc4 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c0101db8:	c7 04 24 52 1d 10 c0 	movl   $0xc0101d52,(%esp)
c0101dbf:	e8 43 ff ff ff       	call   c0101d07 <cons_intr>
    }
}
c0101dc4:	c9                   	leave  
c0101dc5:	c3                   	ret    

c0101dc6 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101dc6:	55                   	push   %ebp
c0101dc7:	89 e5                	mov    %esp,%ebp
c0101dc9:	83 ec 38             	sub    $0x38,%esp
c0101dcc:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101dd2:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101dd6:	89 c2                	mov    %eax,%edx
c0101dd8:	ec                   	in     (%dx),%al
c0101dd9:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c0101ddc:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c0101de0:	0f b6 c0             	movzbl %al,%eax
c0101de3:	83 e0 01             	and    $0x1,%eax
c0101de6:	85 c0                	test   %eax,%eax
c0101de8:	75 0a                	jne    c0101df4 <kbd_proc_data+0x2e>
        return -1;
c0101dea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101def:	e9 59 01 00 00       	jmp    c0101f4d <kbd_proc_data+0x187>
c0101df4:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101dfa:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101dfe:	89 c2                	mov    %eax,%edx
c0101e00:	ec                   	in     (%dx),%al
c0101e01:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101e04:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101e08:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101e0b:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c0101e0f:	75 17                	jne    c0101e28 <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
c0101e11:	a1 48 07 1b c0       	mov    0xc01b0748,%eax
c0101e16:	83 c8 40             	or     $0x40,%eax
c0101e19:	a3 48 07 1b c0       	mov    %eax,0xc01b0748
        return 0;
c0101e1e:	b8 00 00 00 00       	mov    $0x0,%eax
c0101e23:	e9 25 01 00 00       	jmp    c0101f4d <kbd_proc_data+0x187>
    } else if (data & 0x80) {
c0101e28:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101e2c:	84 c0                	test   %al,%al
c0101e2e:	79 47                	jns    c0101e77 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c0101e30:	a1 48 07 1b c0       	mov    0xc01b0748,%eax
c0101e35:	83 e0 40             	and    $0x40,%eax
c0101e38:	85 c0                	test   %eax,%eax
c0101e3a:	75 09                	jne    c0101e45 <kbd_proc_data+0x7f>
c0101e3c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101e40:	83 e0 7f             	and    $0x7f,%eax
c0101e43:	eb 04                	jmp    c0101e49 <kbd_proc_data+0x83>
c0101e45:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101e49:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c0101e4c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101e50:	0f b6 80 40 c0 12 c0 	movzbl -0x3fed3fc0(%eax),%eax
c0101e57:	83 c8 40             	or     $0x40,%eax
c0101e5a:	0f b6 c0             	movzbl %al,%eax
c0101e5d:	f7 d0                	not    %eax
c0101e5f:	89 c2                	mov    %eax,%edx
c0101e61:	a1 48 07 1b c0       	mov    0xc01b0748,%eax
c0101e66:	21 d0                	and    %edx,%eax
c0101e68:	a3 48 07 1b c0       	mov    %eax,0xc01b0748
        return 0;
c0101e6d:	b8 00 00 00 00       	mov    $0x0,%eax
c0101e72:	e9 d6 00 00 00       	jmp    c0101f4d <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
c0101e77:	a1 48 07 1b c0       	mov    0xc01b0748,%eax
c0101e7c:	83 e0 40             	and    $0x40,%eax
c0101e7f:	85 c0                	test   %eax,%eax
c0101e81:	74 11                	je     c0101e94 <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c0101e83:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0101e87:	a1 48 07 1b c0       	mov    0xc01b0748,%eax
c0101e8c:	83 e0 bf             	and    $0xffffffbf,%eax
c0101e8f:	a3 48 07 1b c0       	mov    %eax,0xc01b0748
    }

    shift |= shiftcode[data];
c0101e94:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101e98:	0f b6 80 40 c0 12 c0 	movzbl -0x3fed3fc0(%eax),%eax
c0101e9f:	0f b6 d0             	movzbl %al,%edx
c0101ea2:	a1 48 07 1b c0       	mov    0xc01b0748,%eax
c0101ea7:	09 d0                	or     %edx,%eax
c0101ea9:	a3 48 07 1b c0       	mov    %eax,0xc01b0748
    shift ^= togglecode[data];
c0101eae:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101eb2:	0f b6 80 40 c1 12 c0 	movzbl -0x3fed3ec0(%eax),%eax
c0101eb9:	0f b6 d0             	movzbl %al,%edx
c0101ebc:	a1 48 07 1b c0       	mov    0xc01b0748,%eax
c0101ec1:	31 d0                	xor    %edx,%eax
c0101ec3:	a3 48 07 1b c0       	mov    %eax,0xc01b0748

    c = charcode[shift & (CTL | SHIFT)][data];
c0101ec8:	a1 48 07 1b c0       	mov    0xc01b0748,%eax
c0101ecd:	83 e0 03             	and    $0x3,%eax
c0101ed0:	8b 14 85 40 c5 12 c0 	mov    -0x3fed3ac0(,%eax,4),%edx
c0101ed7:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101edb:	01 d0                	add    %edx,%eax
c0101edd:	0f b6 00             	movzbl (%eax),%eax
c0101ee0:	0f b6 c0             	movzbl %al,%eax
c0101ee3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101ee6:	a1 48 07 1b c0       	mov    0xc01b0748,%eax
c0101eeb:	83 e0 08             	and    $0x8,%eax
c0101eee:	85 c0                	test   %eax,%eax
c0101ef0:	74 22                	je     c0101f14 <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c0101ef2:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101ef6:	7e 0c                	jle    c0101f04 <kbd_proc_data+0x13e>
c0101ef8:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101efc:	7f 06                	jg     c0101f04 <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c0101efe:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c0101f02:	eb 10                	jmp    c0101f14 <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c0101f04:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101f08:	7e 0a                	jle    c0101f14 <kbd_proc_data+0x14e>
c0101f0a:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c0101f0e:	7f 04                	jg     c0101f14 <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c0101f10:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c0101f14:	a1 48 07 1b c0       	mov    0xc01b0748,%eax
c0101f19:	f7 d0                	not    %eax
c0101f1b:	83 e0 06             	and    $0x6,%eax
c0101f1e:	85 c0                	test   %eax,%eax
c0101f20:	75 28                	jne    c0101f4a <kbd_proc_data+0x184>
c0101f22:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101f29:	75 1f                	jne    c0101f4a <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
c0101f2b:	c7 04 24 79 c7 10 c0 	movl   $0xc010c779,(%esp)
c0101f32:	e8 77 e3 ff ff       	call   c01002ae <cprintf>
c0101f37:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c0101f3d:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101f41:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c0101f45:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c0101f49:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c0101f4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101f4d:	c9                   	leave  
c0101f4e:	c3                   	ret    

c0101f4f <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c0101f4f:	55                   	push   %ebp
c0101f50:	89 e5                	mov    %esp,%ebp
c0101f52:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c0101f55:	c7 04 24 c6 1d 10 c0 	movl   $0xc0101dc6,(%esp)
c0101f5c:	e8 a6 fd ff ff       	call   c0101d07 <cons_intr>
}
c0101f61:	c9                   	leave  
c0101f62:	c3                   	ret    

c0101f63 <kbd_init>:

static void
kbd_init(void) {
c0101f63:	55                   	push   %ebp
c0101f64:	89 e5                	mov    %esp,%ebp
c0101f66:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c0101f69:	e8 e1 ff ff ff       	call   c0101f4f <kbd_intr>
    pic_enable(IRQ_KBD);
c0101f6e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0101f75:	e8 31 01 00 00       	call   c01020ab <pic_enable>
}
c0101f7a:	c9                   	leave  
c0101f7b:	c3                   	ret    

c0101f7c <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c0101f7c:	55                   	push   %ebp
c0101f7d:	89 e5                	mov    %esp,%ebp
c0101f7f:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c0101f82:	e8 93 f8 ff ff       	call   c010181a <cga_init>
    serial_init();
c0101f87:	e8 74 f9 ff ff       	call   c0101900 <serial_init>
    kbd_init();
c0101f8c:	e8 d2 ff ff ff       	call   c0101f63 <kbd_init>
    if (!serial_exists) {
c0101f91:	a1 28 05 1b c0       	mov    0xc01b0528,%eax
c0101f96:	85 c0                	test   %eax,%eax
c0101f98:	75 0c                	jne    c0101fa6 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c0101f9a:	c7 04 24 85 c7 10 c0 	movl   $0xc010c785,(%esp)
c0101fa1:	e8 08 e3 ff ff       	call   c01002ae <cprintf>
    }
}
c0101fa6:	c9                   	leave  
c0101fa7:	c3                   	ret    

c0101fa8 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0101fa8:	55                   	push   %ebp
c0101fa9:	89 e5                	mov    %esp,%ebp
c0101fab:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0101fae:	e8 e2 f7 ff ff       	call   c0101795 <__intr_save>
c0101fb3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101fb6:	8b 45 08             	mov    0x8(%ebp),%eax
c0101fb9:	89 04 24             	mov    %eax,(%esp)
c0101fbc:	e8 9b fa ff ff       	call   c0101a5c <lpt_putc>
        cga_putc(c);
c0101fc1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101fc4:	89 04 24             	mov    %eax,(%esp)
c0101fc7:	e8 cf fa ff ff       	call   c0101a9b <cga_putc>
        serial_putc(c);
c0101fcc:	8b 45 08             	mov    0x8(%ebp),%eax
c0101fcf:	89 04 24             	mov    %eax,(%esp)
c0101fd2:	e8 f1 fc ff ff       	call   c0101cc8 <serial_putc>
    }
    local_intr_restore(intr_flag);
c0101fd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101fda:	89 04 24             	mov    %eax,(%esp)
c0101fdd:	e8 dd f7 ff ff       	call   c01017bf <__intr_restore>
}
c0101fe2:	c9                   	leave  
c0101fe3:	c3                   	ret    

c0101fe4 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0101fe4:	55                   	push   %ebp
c0101fe5:	89 e5                	mov    %esp,%ebp
c0101fe7:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c0101fea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0101ff1:	e8 9f f7 ff ff       	call   c0101795 <__intr_save>
c0101ff6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101ff9:	e8 ab fd ff ff       	call   c0101da9 <serial_intr>
        kbd_intr();
c0101ffe:	e8 4c ff ff ff       	call   c0101f4f <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0102003:	8b 15 40 07 1b c0    	mov    0xc01b0740,%edx
c0102009:	a1 44 07 1b c0       	mov    0xc01b0744,%eax
c010200e:	39 c2                	cmp    %eax,%edx
c0102010:	74 31                	je     c0102043 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c0102012:	a1 40 07 1b c0       	mov    0xc01b0740,%eax
c0102017:	8d 50 01             	lea    0x1(%eax),%edx
c010201a:	89 15 40 07 1b c0    	mov    %edx,0xc01b0740
c0102020:	0f b6 80 40 05 1b c0 	movzbl -0x3fe4fac0(%eax),%eax
c0102027:	0f b6 c0             	movzbl %al,%eax
c010202a:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c010202d:	a1 40 07 1b c0       	mov    0xc01b0740,%eax
c0102032:	3d 00 02 00 00       	cmp    $0x200,%eax
c0102037:	75 0a                	jne    c0102043 <cons_getc+0x5f>
                cons.rpos = 0;
c0102039:	c7 05 40 07 1b c0 00 	movl   $0x0,0xc01b0740
c0102040:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c0102043:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102046:	89 04 24             	mov    %eax,(%esp)
c0102049:	e8 71 f7 ff ff       	call   c01017bf <__intr_restore>
    return c;
c010204e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102051:	c9                   	leave  
c0102052:	c3                   	ret    

c0102053 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c0102053:	55                   	push   %ebp
c0102054:	89 e5                	mov    %esp,%ebp
c0102056:	83 ec 14             	sub    $0x14,%esp
c0102059:	8b 45 08             	mov    0x8(%ebp),%eax
c010205c:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c0102060:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0102064:	66 a3 50 c5 12 c0    	mov    %ax,0xc012c550
    if (did_init) {
c010206a:	a1 4c 07 1b c0       	mov    0xc01b074c,%eax
c010206f:	85 c0                	test   %eax,%eax
c0102071:	74 36                	je     c01020a9 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c0102073:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0102077:	0f b6 c0             	movzbl %al,%eax
c010207a:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0102080:	88 45 fd             	mov    %al,-0x3(%ebp)
c0102083:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0102087:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c010208b:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c010208c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0102090:	66 c1 e8 08          	shr    $0x8,%ax
c0102094:	0f b6 c0             	movzbl %al,%eax
c0102097:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c010209d:	88 45 f9             	mov    %al,-0x7(%ebp)
c01020a0:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01020a4:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c01020a8:	ee                   	out    %al,(%dx)
    }
}
c01020a9:	c9                   	leave  
c01020aa:	c3                   	ret    

c01020ab <pic_enable>:

void
pic_enable(unsigned int irq) {
c01020ab:	55                   	push   %ebp
c01020ac:	89 e5                	mov    %esp,%ebp
c01020ae:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c01020b1:	8b 45 08             	mov    0x8(%ebp),%eax
c01020b4:	ba 01 00 00 00       	mov    $0x1,%edx
c01020b9:	89 c1                	mov    %eax,%ecx
c01020bb:	d3 e2                	shl    %cl,%edx
c01020bd:	89 d0                	mov    %edx,%eax
c01020bf:	f7 d0                	not    %eax
c01020c1:	89 c2                	mov    %eax,%edx
c01020c3:	0f b7 05 50 c5 12 c0 	movzwl 0xc012c550,%eax
c01020ca:	21 d0                	and    %edx,%eax
c01020cc:	0f b7 c0             	movzwl %ax,%eax
c01020cf:	89 04 24             	mov    %eax,(%esp)
c01020d2:	e8 7c ff ff ff       	call   c0102053 <pic_setmask>
}
c01020d7:	c9                   	leave  
c01020d8:	c3                   	ret    

c01020d9 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c01020d9:	55                   	push   %ebp
c01020da:	89 e5                	mov    %esp,%ebp
c01020dc:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c01020df:	c7 05 4c 07 1b c0 01 	movl   $0x1,0xc01b074c
c01020e6:	00 00 00 
c01020e9:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c01020ef:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
c01020f3:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c01020f7:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c01020fb:	ee                   	out    %al,(%dx)
c01020fc:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c0102102:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
c0102106:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010210a:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c010210e:	ee                   	out    %al,(%dx)
c010210f:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c0102115:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
c0102119:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010211d:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0102121:	ee                   	out    %al,(%dx)
c0102122:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
c0102128:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
c010212c:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0102130:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102134:	ee                   	out    %al,(%dx)
c0102135:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
c010213b:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
c010213f:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0102143:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0102147:	ee                   	out    %al,(%dx)
c0102148:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
c010214e:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
c0102152:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0102156:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010215a:	ee                   	out    %al,(%dx)
c010215b:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c0102161:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
c0102165:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0102169:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010216d:	ee                   	out    %al,(%dx)
c010216e:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
c0102174:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
c0102178:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c010217c:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0102180:	ee                   	out    %al,(%dx)
c0102181:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
c0102187:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
c010218b:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c010218f:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0102193:	ee                   	out    %al,(%dx)
c0102194:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
c010219a:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
c010219e:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01021a2:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c01021a6:	ee                   	out    %al,(%dx)
c01021a7:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
c01021ad:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
c01021b1:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c01021b5:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c01021b9:	ee                   	out    %al,(%dx)
c01021ba:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c01021c0:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
c01021c4:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c01021c8:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c01021cc:	ee                   	out    %al,(%dx)
c01021cd:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
c01021d3:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
c01021d7:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c01021db:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c01021df:	ee                   	out    %al,(%dx)
c01021e0:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
c01021e6:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
c01021ea:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c01021ee:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c01021f2:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c01021f3:	0f b7 05 50 c5 12 c0 	movzwl 0xc012c550,%eax
c01021fa:	66 83 f8 ff          	cmp    $0xffff,%ax
c01021fe:	74 12                	je     c0102212 <pic_init+0x139>
        pic_setmask(irq_mask);
c0102200:	0f b7 05 50 c5 12 c0 	movzwl 0xc012c550,%eax
c0102207:	0f b7 c0             	movzwl %ax,%eax
c010220a:	89 04 24             	mov    %eax,(%esp)
c010220d:	e8 41 fe ff ff       	call   c0102053 <pic_setmask>
    }
}
c0102212:	c9                   	leave  
c0102213:	c3                   	ret    

c0102214 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c0102214:	55                   	push   %ebp
c0102215:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
c0102217:	fb                   	sti    
    sti();
}
c0102218:	5d                   	pop    %ebp
c0102219:	c3                   	ret    

c010221a <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c010221a:	55                   	push   %ebp
c010221b:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
c010221d:	fa                   	cli    
    cli();
}
c010221e:	5d                   	pop    %ebp
c010221f:	c3                   	ret    

c0102220 <print_ticks>:
#include <sync.h>
#include <proc.h>

#define TICK_NUM 100

static void print_ticks() {
c0102220:	55                   	push   %ebp
c0102221:	89 e5                	mov    %esp,%ebp
c0102223:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c0102226:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c010222d:	00 
c010222e:	c7 04 24 c0 c7 10 c0 	movl   $0xc010c7c0,(%esp)
c0102235:	e8 74 e0 ff ff       	call   c01002ae <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
c010223a:	c7 04 24 ca c7 10 c0 	movl   $0xc010c7ca,(%esp)
c0102241:	e8 68 e0 ff ff       	call   c01002ae <cprintf>
    panic("EOT: kernel seems ok.");
c0102246:	c7 44 24 08 d8 c7 10 	movl   $0xc010c7d8,0x8(%esp)
c010224d:	c0 
c010224e:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
c0102255:	00 
c0102256:	c7 04 24 ee c7 10 c0 	movl   $0xc010c7ee,(%esp)
c010225d:	e8 a3 e1 ff ff       	call   c0100405 <__panic>

c0102262 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c0102262:	55                   	push   %ebp
c0102263:	89 e5                	mov    %esp,%ebp
c0102265:	83 ec 10             	sub    $0x10,%esp
     /* LAB5 YOUR CODE */ 
     //you should update your lab1 code (just add ONE or TWO lines of code), let user app to use syscall to get the service of ucore
     //so you should setup the syscall interrupt gate in here
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c0102268:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010226f:	e9 c3 00 00 00       	jmp    c0102337 <idt_init+0xd5>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c0102274:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102277:	8b 04 85 e0 c5 12 c0 	mov    -0x3fed3a20(,%eax,4),%eax
c010227e:	89 c2                	mov    %eax,%edx
c0102280:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102283:	66 89 14 c5 60 07 1b 	mov    %dx,-0x3fe4f8a0(,%eax,8)
c010228a:	c0 
c010228b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010228e:	66 c7 04 c5 62 07 1b 	movw   $0x8,-0x3fe4f89e(,%eax,8)
c0102295:	c0 08 00 
c0102298:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010229b:	0f b6 14 c5 64 07 1b 	movzbl -0x3fe4f89c(,%eax,8),%edx
c01022a2:	c0 
c01022a3:	83 e2 e0             	and    $0xffffffe0,%edx
c01022a6:	88 14 c5 64 07 1b c0 	mov    %dl,-0x3fe4f89c(,%eax,8)
c01022ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022b0:	0f b6 14 c5 64 07 1b 	movzbl -0x3fe4f89c(,%eax,8),%edx
c01022b7:	c0 
c01022b8:	83 e2 1f             	and    $0x1f,%edx
c01022bb:	88 14 c5 64 07 1b c0 	mov    %dl,-0x3fe4f89c(,%eax,8)
c01022c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022c5:	0f b6 14 c5 65 07 1b 	movzbl -0x3fe4f89b(,%eax,8),%edx
c01022cc:	c0 
c01022cd:	83 e2 f0             	and    $0xfffffff0,%edx
c01022d0:	83 ca 0e             	or     $0xe,%edx
c01022d3:	88 14 c5 65 07 1b c0 	mov    %dl,-0x3fe4f89b(,%eax,8)
c01022da:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022dd:	0f b6 14 c5 65 07 1b 	movzbl -0x3fe4f89b(,%eax,8),%edx
c01022e4:	c0 
c01022e5:	83 e2 ef             	and    $0xffffffef,%edx
c01022e8:	88 14 c5 65 07 1b c0 	mov    %dl,-0x3fe4f89b(,%eax,8)
c01022ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022f2:	0f b6 14 c5 65 07 1b 	movzbl -0x3fe4f89b(,%eax,8),%edx
c01022f9:	c0 
c01022fa:	83 e2 9f             	and    $0xffffff9f,%edx
c01022fd:	88 14 c5 65 07 1b c0 	mov    %dl,-0x3fe4f89b(,%eax,8)
c0102304:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102307:	0f b6 14 c5 65 07 1b 	movzbl -0x3fe4f89b(,%eax,8),%edx
c010230e:	c0 
c010230f:	83 ca 80             	or     $0xffffff80,%edx
c0102312:	88 14 c5 65 07 1b c0 	mov    %dl,-0x3fe4f89b(,%eax,8)
c0102319:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010231c:	8b 04 85 e0 c5 12 c0 	mov    -0x3fed3a20(,%eax,4),%eax
c0102323:	c1 e8 10             	shr    $0x10,%eax
c0102326:	89 c2                	mov    %eax,%edx
c0102328:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010232b:	66 89 14 c5 66 07 1b 	mov    %dx,-0x3fe4f89a(,%eax,8)
c0102332:	c0 
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c0102333:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0102337:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010233a:	3d ff 00 00 00       	cmp    $0xff,%eax
c010233f:	0f 86 2f ff ff ff    	jbe    c0102274 <idt_init+0x12>
    }
    SETGATE(idt[T_SYSCALL], 1, GD_KTEXT, __vectors[T_SYSCALL], DPL_USER);
c0102345:	a1 e0 c7 12 c0       	mov    0xc012c7e0,%eax
c010234a:	66 a3 60 0b 1b c0    	mov    %ax,0xc01b0b60
c0102350:	66 c7 05 62 0b 1b c0 	movw   $0x8,0xc01b0b62
c0102357:	08 00 
c0102359:	0f b6 05 64 0b 1b c0 	movzbl 0xc01b0b64,%eax
c0102360:	83 e0 e0             	and    $0xffffffe0,%eax
c0102363:	a2 64 0b 1b c0       	mov    %al,0xc01b0b64
c0102368:	0f b6 05 64 0b 1b c0 	movzbl 0xc01b0b64,%eax
c010236f:	83 e0 1f             	and    $0x1f,%eax
c0102372:	a2 64 0b 1b c0       	mov    %al,0xc01b0b64
c0102377:	0f b6 05 65 0b 1b c0 	movzbl 0xc01b0b65,%eax
c010237e:	83 c8 0f             	or     $0xf,%eax
c0102381:	a2 65 0b 1b c0       	mov    %al,0xc01b0b65
c0102386:	0f b6 05 65 0b 1b c0 	movzbl 0xc01b0b65,%eax
c010238d:	83 e0 ef             	and    $0xffffffef,%eax
c0102390:	a2 65 0b 1b c0       	mov    %al,0xc01b0b65
c0102395:	0f b6 05 65 0b 1b c0 	movzbl 0xc01b0b65,%eax
c010239c:	83 c8 60             	or     $0x60,%eax
c010239f:	a2 65 0b 1b c0       	mov    %al,0xc01b0b65
c01023a4:	0f b6 05 65 0b 1b c0 	movzbl 0xc01b0b65,%eax
c01023ab:	83 c8 80             	or     $0xffffff80,%eax
c01023ae:	a2 65 0b 1b c0       	mov    %al,0xc01b0b65
c01023b3:	a1 e0 c7 12 c0       	mov    0xc012c7e0,%eax
c01023b8:	c1 e8 10             	shr    $0x10,%eax
c01023bb:	66 a3 66 0b 1b c0    	mov    %ax,0xc01b0b66
c01023c1:	c7 45 f8 60 c5 12 c0 	movl   $0xc012c560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c01023c8:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01023cb:	0f 01 18             	lidtl  (%eax)
    lidt(&idt_pd);
}
c01023ce:	c9                   	leave  
c01023cf:	c3                   	ret    

c01023d0 <trapname>:

static const char *
trapname(int trapno) {
c01023d0:	55                   	push   %ebp
c01023d1:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c01023d3:	8b 45 08             	mov    0x8(%ebp),%eax
c01023d6:	83 f8 13             	cmp    $0x13,%eax
c01023d9:	77 0c                	ja     c01023e7 <trapname+0x17>
        return excnames[trapno];
c01023db:	8b 45 08             	mov    0x8(%ebp),%eax
c01023de:	8b 04 85 80 cc 10 c0 	mov    -0x3fef3380(,%eax,4),%eax
c01023e5:	eb 18                	jmp    c01023ff <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c01023e7:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c01023eb:	7e 0d                	jle    c01023fa <trapname+0x2a>
c01023ed:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c01023f1:	7f 07                	jg     c01023fa <trapname+0x2a>
        return "Hardware Interrupt";
c01023f3:	b8 ff c7 10 c0       	mov    $0xc010c7ff,%eax
c01023f8:	eb 05                	jmp    c01023ff <trapname+0x2f>
    }
    return "(unknown trap)";
c01023fa:	b8 12 c8 10 c0       	mov    $0xc010c812,%eax
}
c01023ff:	5d                   	pop    %ebp
c0102400:	c3                   	ret    

c0102401 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c0102401:	55                   	push   %ebp
c0102402:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c0102404:	8b 45 08             	mov    0x8(%ebp),%eax
c0102407:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c010240b:	66 83 f8 08          	cmp    $0x8,%ax
c010240f:	0f 94 c0             	sete   %al
c0102412:	0f b6 c0             	movzbl %al,%eax
}
c0102415:	5d                   	pop    %ebp
c0102416:	c3                   	ret    

c0102417 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0102417:	55                   	push   %ebp
c0102418:	89 e5                	mov    %esp,%ebp
c010241a:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c010241d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102420:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102424:	c7 04 24 53 c8 10 c0 	movl   $0xc010c853,(%esp)
c010242b:	e8 7e de ff ff       	call   c01002ae <cprintf>
    print_regs(&tf->tf_regs);
c0102430:	8b 45 08             	mov    0x8(%ebp),%eax
c0102433:	89 04 24             	mov    %eax,(%esp)
c0102436:	e8 a1 01 00 00       	call   c01025dc <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c010243b:	8b 45 08             	mov    0x8(%ebp),%eax
c010243e:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0102442:	0f b7 c0             	movzwl %ax,%eax
c0102445:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102449:	c7 04 24 64 c8 10 c0 	movl   $0xc010c864,(%esp)
c0102450:	e8 59 de ff ff       	call   c01002ae <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0102455:	8b 45 08             	mov    0x8(%ebp),%eax
c0102458:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c010245c:	0f b7 c0             	movzwl %ax,%eax
c010245f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102463:	c7 04 24 77 c8 10 c0 	movl   $0xc010c877,(%esp)
c010246a:	e8 3f de ff ff       	call   c01002ae <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c010246f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102472:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0102476:	0f b7 c0             	movzwl %ax,%eax
c0102479:	89 44 24 04          	mov    %eax,0x4(%esp)
c010247d:	c7 04 24 8a c8 10 c0 	movl   $0xc010c88a,(%esp)
c0102484:	e8 25 de ff ff       	call   c01002ae <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0102489:	8b 45 08             	mov    0x8(%ebp),%eax
c010248c:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0102490:	0f b7 c0             	movzwl %ax,%eax
c0102493:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102497:	c7 04 24 9d c8 10 c0 	movl   $0xc010c89d,(%esp)
c010249e:	e8 0b de ff ff       	call   c01002ae <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c01024a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01024a6:	8b 40 30             	mov    0x30(%eax),%eax
c01024a9:	89 04 24             	mov    %eax,(%esp)
c01024ac:	e8 1f ff ff ff       	call   c01023d0 <trapname>
c01024b1:	8b 55 08             	mov    0x8(%ebp),%edx
c01024b4:	8b 52 30             	mov    0x30(%edx),%edx
c01024b7:	89 44 24 08          	mov    %eax,0x8(%esp)
c01024bb:	89 54 24 04          	mov    %edx,0x4(%esp)
c01024bf:	c7 04 24 b0 c8 10 c0 	movl   $0xc010c8b0,(%esp)
c01024c6:	e8 e3 dd ff ff       	call   c01002ae <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c01024cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01024ce:	8b 40 34             	mov    0x34(%eax),%eax
c01024d1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024d5:	c7 04 24 c2 c8 10 c0 	movl   $0xc010c8c2,(%esp)
c01024dc:	e8 cd dd ff ff       	call   c01002ae <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c01024e1:	8b 45 08             	mov    0x8(%ebp),%eax
c01024e4:	8b 40 38             	mov    0x38(%eax),%eax
c01024e7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024eb:	c7 04 24 d1 c8 10 c0 	movl   $0xc010c8d1,(%esp)
c01024f2:	e8 b7 dd ff ff       	call   c01002ae <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c01024f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01024fa:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01024fe:	0f b7 c0             	movzwl %ax,%eax
c0102501:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102505:	c7 04 24 e0 c8 10 c0 	movl   $0xc010c8e0,(%esp)
c010250c:	e8 9d dd ff ff       	call   c01002ae <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0102511:	8b 45 08             	mov    0x8(%ebp),%eax
c0102514:	8b 40 40             	mov    0x40(%eax),%eax
c0102517:	89 44 24 04          	mov    %eax,0x4(%esp)
c010251b:	c7 04 24 f3 c8 10 c0 	movl   $0xc010c8f3,(%esp)
c0102522:	e8 87 dd ff ff       	call   c01002ae <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0102527:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010252e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0102535:	eb 3e                	jmp    c0102575 <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0102537:	8b 45 08             	mov    0x8(%ebp),%eax
c010253a:	8b 50 40             	mov    0x40(%eax),%edx
c010253d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102540:	21 d0                	and    %edx,%eax
c0102542:	85 c0                	test   %eax,%eax
c0102544:	74 28                	je     c010256e <print_trapframe+0x157>
c0102546:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102549:	8b 04 85 80 c5 12 c0 	mov    -0x3fed3a80(,%eax,4),%eax
c0102550:	85 c0                	test   %eax,%eax
c0102552:	74 1a                	je     c010256e <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
c0102554:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102557:	8b 04 85 80 c5 12 c0 	mov    -0x3fed3a80(,%eax,4),%eax
c010255e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102562:	c7 04 24 02 c9 10 c0 	movl   $0xc010c902,(%esp)
c0102569:	e8 40 dd ff ff       	call   c01002ae <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c010256e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0102572:	d1 65 f0             	shll   -0x10(%ebp)
c0102575:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102578:	83 f8 17             	cmp    $0x17,%eax
c010257b:	76 ba                	jbe    c0102537 <print_trapframe+0x120>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c010257d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102580:	8b 40 40             	mov    0x40(%eax),%eax
c0102583:	25 00 30 00 00       	and    $0x3000,%eax
c0102588:	c1 e8 0c             	shr    $0xc,%eax
c010258b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010258f:	c7 04 24 06 c9 10 c0 	movl   $0xc010c906,(%esp)
c0102596:	e8 13 dd ff ff       	call   c01002ae <cprintf>

    if (!trap_in_kernel(tf)) {
c010259b:	8b 45 08             	mov    0x8(%ebp),%eax
c010259e:	89 04 24             	mov    %eax,(%esp)
c01025a1:	e8 5b fe ff ff       	call   c0102401 <trap_in_kernel>
c01025a6:	85 c0                	test   %eax,%eax
c01025a8:	75 30                	jne    c01025da <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c01025aa:	8b 45 08             	mov    0x8(%ebp),%eax
c01025ad:	8b 40 44             	mov    0x44(%eax),%eax
c01025b0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025b4:	c7 04 24 0f c9 10 c0 	movl   $0xc010c90f,(%esp)
c01025bb:	e8 ee dc ff ff       	call   c01002ae <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c01025c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01025c3:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c01025c7:	0f b7 c0             	movzwl %ax,%eax
c01025ca:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025ce:	c7 04 24 1e c9 10 c0 	movl   $0xc010c91e,(%esp)
c01025d5:	e8 d4 dc ff ff       	call   c01002ae <cprintf>
    }
}
c01025da:	c9                   	leave  
c01025db:	c3                   	ret    

c01025dc <print_regs>:

void
print_regs(struct pushregs *regs) {
c01025dc:	55                   	push   %ebp
c01025dd:	89 e5                	mov    %esp,%ebp
c01025df:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c01025e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01025e5:	8b 00                	mov    (%eax),%eax
c01025e7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025eb:	c7 04 24 31 c9 10 c0 	movl   $0xc010c931,(%esp)
c01025f2:	e8 b7 dc ff ff       	call   c01002ae <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c01025f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01025fa:	8b 40 04             	mov    0x4(%eax),%eax
c01025fd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102601:	c7 04 24 40 c9 10 c0 	movl   $0xc010c940,(%esp)
c0102608:	e8 a1 dc ff ff       	call   c01002ae <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c010260d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102610:	8b 40 08             	mov    0x8(%eax),%eax
c0102613:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102617:	c7 04 24 4f c9 10 c0 	movl   $0xc010c94f,(%esp)
c010261e:	e8 8b dc ff ff       	call   c01002ae <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0102623:	8b 45 08             	mov    0x8(%ebp),%eax
c0102626:	8b 40 0c             	mov    0xc(%eax),%eax
c0102629:	89 44 24 04          	mov    %eax,0x4(%esp)
c010262d:	c7 04 24 5e c9 10 c0 	movl   $0xc010c95e,(%esp)
c0102634:	e8 75 dc ff ff       	call   c01002ae <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0102639:	8b 45 08             	mov    0x8(%ebp),%eax
c010263c:	8b 40 10             	mov    0x10(%eax),%eax
c010263f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102643:	c7 04 24 6d c9 10 c0 	movl   $0xc010c96d,(%esp)
c010264a:	e8 5f dc ff ff       	call   c01002ae <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c010264f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102652:	8b 40 14             	mov    0x14(%eax),%eax
c0102655:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102659:	c7 04 24 7c c9 10 c0 	movl   $0xc010c97c,(%esp)
c0102660:	e8 49 dc ff ff       	call   c01002ae <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0102665:	8b 45 08             	mov    0x8(%ebp),%eax
c0102668:	8b 40 18             	mov    0x18(%eax),%eax
c010266b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010266f:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c0102676:	e8 33 dc ff ff       	call   c01002ae <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c010267b:	8b 45 08             	mov    0x8(%ebp),%eax
c010267e:	8b 40 1c             	mov    0x1c(%eax),%eax
c0102681:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102685:	c7 04 24 9a c9 10 c0 	movl   $0xc010c99a,(%esp)
c010268c:	e8 1d dc ff ff       	call   c01002ae <cprintf>
}
c0102691:	c9                   	leave  
c0102692:	c3                   	ret    

c0102693 <print_pgfault>:

static inline void
print_pgfault(struct trapframe *tf) {
c0102693:	55                   	push   %ebp
c0102694:	89 e5                	mov    %esp,%ebp
c0102696:	53                   	push   %ebx
c0102697:	83 ec 34             	sub    $0x34,%esp
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
c010269a:	8b 45 08             	mov    0x8(%ebp),%eax
c010269d:	8b 40 34             	mov    0x34(%eax),%eax
c01026a0:	83 e0 01             	and    $0x1,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c01026a3:	85 c0                	test   %eax,%eax
c01026a5:	74 07                	je     c01026ae <print_pgfault+0x1b>
c01026a7:	b9 a9 c9 10 c0       	mov    $0xc010c9a9,%ecx
c01026ac:	eb 05                	jmp    c01026b3 <print_pgfault+0x20>
c01026ae:	b9 ba c9 10 c0       	mov    $0xc010c9ba,%ecx
            (tf->tf_err & 2) ? 'W' : 'R',
c01026b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01026b6:	8b 40 34             	mov    0x34(%eax),%eax
c01026b9:	83 e0 02             	and    $0x2,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c01026bc:	85 c0                	test   %eax,%eax
c01026be:	74 07                	je     c01026c7 <print_pgfault+0x34>
c01026c0:	ba 57 00 00 00       	mov    $0x57,%edx
c01026c5:	eb 05                	jmp    c01026cc <print_pgfault+0x39>
c01026c7:	ba 52 00 00 00       	mov    $0x52,%edx
            (tf->tf_err & 4) ? 'U' : 'K',
c01026cc:	8b 45 08             	mov    0x8(%ebp),%eax
c01026cf:	8b 40 34             	mov    0x34(%eax),%eax
c01026d2:	83 e0 04             	and    $0x4,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c01026d5:	85 c0                	test   %eax,%eax
c01026d7:	74 07                	je     c01026e0 <print_pgfault+0x4d>
c01026d9:	b8 55 00 00 00       	mov    $0x55,%eax
c01026de:	eb 05                	jmp    c01026e5 <print_pgfault+0x52>
c01026e0:	b8 4b 00 00 00       	mov    $0x4b,%eax
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c01026e5:	0f 20 d3             	mov    %cr2,%ebx
c01026e8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
    return cr2;
c01026eb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
c01026ee:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c01026f2:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01026f6:	89 44 24 08          	mov    %eax,0x8(%esp)
c01026fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01026fe:	c7 04 24 c8 c9 10 c0 	movl   $0xc010c9c8,(%esp)
c0102705:	e8 a4 db ff ff       	call   c01002ae <cprintf>
}
c010270a:	83 c4 34             	add    $0x34,%esp
c010270d:	5b                   	pop    %ebx
c010270e:	5d                   	pop    %ebp
c010270f:	c3                   	ret    

c0102710 <pgfault_handler>:

static int
pgfault_handler(struct trapframe *tf) {
c0102710:	55                   	push   %ebp
c0102711:	89 e5                	mov    %esp,%ebp
c0102713:	83 ec 28             	sub    $0x28,%esp
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
c0102716:	a1 7c 30 1b c0       	mov    0xc01b307c,%eax
c010271b:	85 c0                	test   %eax,%eax
c010271d:	74 0b                	je     c010272a <pgfault_handler+0x1a>
            print_pgfault(tf);
c010271f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102722:	89 04 24             	mov    %eax,(%esp)
c0102725:	e8 69 ff ff ff       	call   c0102693 <print_pgfault>
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
c010272a:	a1 7c 30 1b c0       	mov    0xc01b307c,%eax
c010272f:	85 c0                	test   %eax,%eax
c0102731:	74 3d                	je     c0102770 <pgfault_handler+0x60>
        assert(current == idleproc);
c0102733:	8b 15 28 10 1b c0    	mov    0xc01b1028,%edx
c0102739:	a1 20 10 1b c0       	mov    0xc01b1020,%eax
c010273e:	39 c2                	cmp    %eax,%edx
c0102740:	74 24                	je     c0102766 <pgfault_handler+0x56>
c0102742:	c7 44 24 0c eb c9 10 	movl   $0xc010c9eb,0xc(%esp)
c0102749:	c0 
c010274a:	c7 44 24 08 ff c9 10 	movl   $0xc010c9ff,0x8(%esp)
c0102751:	c0 
c0102752:	c7 44 24 04 b0 00 00 	movl   $0xb0,0x4(%esp)
c0102759:	00 
c010275a:	c7 04 24 ee c7 10 c0 	movl   $0xc010c7ee,(%esp)
c0102761:	e8 9f dc ff ff       	call   c0100405 <__panic>
        mm = check_mm_struct;
c0102766:	a1 7c 30 1b c0       	mov    0xc01b307c,%eax
c010276b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010276e:	eb 46                	jmp    c01027b6 <pgfault_handler+0xa6>
    }
    else {
        if (current == NULL) {
c0102770:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c0102775:	85 c0                	test   %eax,%eax
c0102777:	75 32                	jne    c01027ab <pgfault_handler+0x9b>
            print_trapframe(tf);
c0102779:	8b 45 08             	mov    0x8(%ebp),%eax
c010277c:	89 04 24             	mov    %eax,(%esp)
c010277f:	e8 93 fc ff ff       	call   c0102417 <print_trapframe>
            print_pgfault(tf);
c0102784:	8b 45 08             	mov    0x8(%ebp),%eax
c0102787:	89 04 24             	mov    %eax,(%esp)
c010278a:	e8 04 ff ff ff       	call   c0102693 <print_pgfault>
            panic("unhandled page fault.\n");
c010278f:	c7 44 24 08 14 ca 10 	movl   $0xc010ca14,0x8(%esp)
c0102796:	c0 
c0102797:	c7 44 24 04 b7 00 00 	movl   $0xb7,0x4(%esp)
c010279e:	00 
c010279f:	c7 04 24 ee c7 10 c0 	movl   $0xc010c7ee,(%esp)
c01027a6:	e8 5a dc ff ff       	call   c0100405 <__panic>
        }
        mm = current->mm;
c01027ab:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c01027b0:	8b 40 18             	mov    0x18(%eax),%eax
c01027b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c01027b6:	0f 20 d0             	mov    %cr2,%eax
c01027b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr2;
c01027bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
    }
    return do_pgfault(mm, tf->tf_err, rcr2());
c01027bf:	89 c2                	mov    %eax,%edx
c01027c1:	8b 45 08             	mov    0x8(%ebp),%eax
c01027c4:	8b 40 34             	mov    0x34(%eax),%eax
c01027c7:	89 54 24 08          	mov    %edx,0x8(%esp)
c01027cb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01027cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01027d2:	89 04 24             	mov    %eax,(%esp)
c01027d5:	e8 81 1c 00 00       	call   c010445b <do_pgfault>
}
c01027da:	c9                   	leave  
c01027db:	c3                   	ret    

c01027dc <trap_dispatch>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

static void
trap_dispatch(struct trapframe *tf) {
c01027dc:	55                   	push   %ebp
c01027dd:	89 e5                	mov    %esp,%ebp
c01027df:	83 ec 28             	sub    $0x28,%esp
    char c;

    int ret=0;
c01027e2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    switch (tf->tf_trapno) {
c01027e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01027ec:	8b 40 30             	mov    0x30(%eax),%eax
c01027ef:	83 f8 2f             	cmp    $0x2f,%eax
c01027f2:	77 38                	ja     c010282c <trap_dispatch+0x50>
c01027f4:	83 f8 2e             	cmp    $0x2e,%eax
c01027f7:	0f 83 0f 02 00 00    	jae    c0102a0c <trap_dispatch+0x230>
c01027fd:	83 f8 20             	cmp    $0x20,%eax
c0102800:	0f 84 07 01 00 00    	je     c010290d <trap_dispatch+0x131>
c0102806:	83 f8 20             	cmp    $0x20,%eax
c0102809:	77 0a                	ja     c0102815 <trap_dispatch+0x39>
c010280b:	83 f8 0e             	cmp    $0xe,%eax
c010280e:	74 3e                	je     c010284e <trap_dispatch+0x72>
c0102810:	e9 af 01 00 00       	jmp    c01029c4 <trap_dispatch+0x1e8>
c0102815:	83 f8 21             	cmp    $0x21,%eax
c0102818:	0f 84 64 01 00 00    	je     c0102982 <trap_dispatch+0x1a6>
c010281e:	83 f8 24             	cmp    $0x24,%eax
c0102821:	0f 84 32 01 00 00    	je     c0102959 <trap_dispatch+0x17d>
c0102827:	e9 98 01 00 00       	jmp    c01029c4 <trap_dispatch+0x1e8>
c010282c:	83 f8 78             	cmp    $0x78,%eax
c010282f:	0f 82 8f 01 00 00    	jb     c01029c4 <trap_dispatch+0x1e8>
c0102835:	83 f8 79             	cmp    $0x79,%eax
c0102838:	0f 86 6a 01 00 00    	jbe    c01029a8 <trap_dispatch+0x1cc>
c010283e:	3d 80 00 00 00       	cmp    $0x80,%eax
c0102843:	0f 84 ba 00 00 00    	je     c0102903 <trap_dispatch+0x127>
c0102849:	e9 76 01 00 00       	jmp    c01029c4 <trap_dispatch+0x1e8>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
c010284e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102851:	89 04 24             	mov    %eax,(%esp)
c0102854:	e8 b7 fe ff ff       	call   c0102710 <pgfault_handler>
c0102859:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010285c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102860:	0f 84 98 00 00 00    	je     c01028fe <trap_dispatch+0x122>
            print_trapframe(tf);
c0102866:	8b 45 08             	mov    0x8(%ebp),%eax
c0102869:	89 04 24             	mov    %eax,(%esp)
c010286c:	e8 a6 fb ff ff       	call   c0102417 <print_trapframe>
            if (current == NULL) {
c0102871:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c0102876:	85 c0                	test   %eax,%eax
c0102878:	75 23                	jne    c010289d <trap_dispatch+0xc1>
                panic("handle pgfault failed. ret=%d\n", ret);
c010287a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010287d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102881:	c7 44 24 08 2c ca 10 	movl   $0xc010ca2c,0x8(%esp)
c0102888:	c0 
c0102889:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c0102890:	00 
c0102891:	c7 04 24 ee c7 10 c0 	movl   $0xc010c7ee,(%esp)
c0102898:	e8 68 db ff ff       	call   c0100405 <__panic>
            }
            else {
                if (trap_in_kernel(tf)) {
c010289d:	8b 45 08             	mov    0x8(%ebp),%eax
c01028a0:	89 04 24             	mov    %eax,(%esp)
c01028a3:	e8 59 fb ff ff       	call   c0102401 <trap_in_kernel>
c01028a8:	85 c0                	test   %eax,%eax
c01028aa:	74 23                	je     c01028cf <trap_dispatch+0xf3>
                    panic("handle pgfault failed in kernel mode. ret=%d\n", ret);
c01028ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01028af:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01028b3:	c7 44 24 08 4c ca 10 	movl   $0xc010ca4c,0x8(%esp)
c01028ba:	c0 
c01028bb:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
c01028c2:	00 
c01028c3:	c7 04 24 ee c7 10 c0 	movl   $0xc010c7ee,(%esp)
c01028ca:	e8 36 db ff ff       	call   c0100405 <__panic>
                }
                cprintf("killed by kernel.\n");
c01028cf:	c7 04 24 7a ca 10 c0 	movl   $0xc010ca7a,(%esp)
c01028d6:	e8 d3 d9 ff ff       	call   c01002ae <cprintf>
                panic("handle user mode pgfault failed. ret=%d\n", ret); 
c01028db:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01028de:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01028e2:	c7 44 24 08 90 ca 10 	movl   $0xc010ca90,0x8(%esp)
c01028e9:	c0 
c01028ea:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c01028f1:	00 
c01028f2:	c7 04 24 ee c7 10 c0 	movl   $0xc010c7ee,(%esp)
c01028f9:	e8 07 db ff ff       	call   c0100405 <__panic>
                do_exit(-E_KILLED);
            }
        }
        break;
c01028fe:	e9 0a 01 00 00       	jmp    c0102a0d <trap_dispatch+0x231>
    case T_SYSCALL:
        syscall();
c0102903:	e8 33 8d 00 00       	call   c010b63b <syscall>
        break;
c0102908:	e9 00 01 00 00       	jmp    c0102a0d <trap_dispatch+0x231>
        /* LAB6 YOUR CODE */
        /* you should upate you lab5 code
         * IMPORTANT FUNCTIONS:
	     * sched_class_proc_tick
         */
        ticks ++;  
c010290d:	a1 78 30 1b c0       	mov    0xc01b3078,%eax
c0102912:	83 c0 01             	add    $0x1,%eax
c0102915:	a3 78 30 1b c0       	mov    %eax,0xc01b3078
        assert(current != NULL);
c010291a:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010291f:	85 c0                	test   %eax,%eax
c0102921:	75 24                	jne    c0102947 <trap_dispatch+0x16b>
c0102923:	c7 44 24 0c b9 ca 10 	movl   $0xc010cab9,0xc(%esp)
c010292a:	c0 
c010292b:	c7 44 24 08 ff c9 10 	movl   $0xc010c9ff,0x8(%esp)
c0102932:	c0 
c0102933:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
c010293a:	00 
c010293b:	c7 04 24 ee c7 10 c0 	movl   $0xc010c7ee,(%esp)
c0102942:	e8 be da ff ff       	call   c0100405 <__panic>
        sched_class_proc_tick(current);
c0102947:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010294c:	89 04 24             	mov    %eax,(%esp)
c010294f:	e8 53 86 00 00       	call   c010afa7 <sched_class_proc_tick>
        break;
c0102954:	e9 b4 00 00 00       	jmp    c0102a0d <trap_dispatch+0x231>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0102959:	e8 86 f6 ff ff       	call   c0101fe4 <cons_getc>
c010295e:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0102961:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c0102965:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c0102969:	89 54 24 08          	mov    %edx,0x8(%esp)
c010296d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102971:	c7 04 24 c9 ca 10 c0 	movl   $0xc010cac9,(%esp)
c0102978:	e8 31 d9 ff ff       	call   c01002ae <cprintf>
        break;
c010297d:	e9 8b 00 00 00       	jmp    c0102a0d <trap_dispatch+0x231>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0102982:	e8 5d f6 ff ff       	call   c0101fe4 <cons_getc>
c0102987:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c010298a:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c010298e:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c0102992:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102996:	89 44 24 04          	mov    %eax,0x4(%esp)
c010299a:	c7 04 24 db ca 10 c0 	movl   $0xc010cadb,(%esp)
c01029a1:	e8 08 d9 ff ff       	call   c01002ae <cprintf>
        break;
c01029a6:	eb 65                	jmp    c0102a0d <trap_dispatch+0x231>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c01029a8:	c7 44 24 08 ea ca 10 	movl   $0xc010caea,0x8(%esp)
c01029af:	c0 
c01029b0:	c7 44 24 04 fe 00 00 	movl   $0xfe,0x4(%esp)
c01029b7:	00 
c01029b8:	c7 04 24 ee c7 10 c0 	movl   $0xc010c7ee,(%esp)
c01029bf:	e8 41 da ff ff       	call   c0100405 <__panic>
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        print_trapframe(tf);
c01029c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01029c7:	89 04 24             	mov    %eax,(%esp)
c01029ca:	e8 48 fa ff ff       	call   c0102417 <print_trapframe>
        if (current != NULL) {
c01029cf:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c01029d4:	85 c0                	test   %eax,%eax
c01029d6:	74 18                	je     c01029f0 <trap_dispatch+0x214>
            cprintf("unhandled trap.\n");
c01029d8:	c7 04 24 fa ca 10 c0 	movl   $0xc010cafa,(%esp)
c01029df:	e8 ca d8 ff ff       	call   c01002ae <cprintf>
            do_exit(-E_KILLED);
c01029e4:	c7 04 24 f7 ff ff ff 	movl   $0xfffffff7,(%esp)
c01029eb:	e8 7a 75 00 00       	call   c0109f6a <do_exit>
        }
        // in kernel, it must be a mistake
        panic("unexpected trap in kernel.\n");
c01029f0:	c7 44 24 08 0b cb 10 	movl   $0xc010cb0b,0x8(%esp)
c01029f7:	c0 
c01029f8:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
c01029ff:	00 
c0102a00:	c7 04 24 ee c7 10 c0 	movl   $0xc010c7ee,(%esp)
c0102a07:	e8 f9 d9 ff ff       	call   c0100405 <__panic>
        break;
c0102a0c:	90                   	nop

    }
}
c0102a0d:	c9                   	leave  
c0102a0e:	c3                   	ret    

c0102a0f <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0102a0f:	55                   	push   %ebp
c0102a10:	89 e5                	mov    %esp,%ebp
c0102a12:	83 ec 28             	sub    $0x28,%esp
    // dispatch based on what type of trap occurred
    // used for previous projects
    if (current == NULL) {
c0102a15:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c0102a1a:	85 c0                	test   %eax,%eax
c0102a1c:	75 0d                	jne    c0102a2b <trap+0x1c>
        trap_dispatch(tf);
c0102a1e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a21:	89 04 24             	mov    %eax,(%esp)
c0102a24:	e8 b3 fd ff ff       	call   c01027dc <trap_dispatch>
c0102a29:	eb 6c                	jmp    c0102a97 <trap+0x88>
    }
    else {
        // keep a trapframe chain in stack
        struct trapframe *otf = current->tf;
c0102a2b:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c0102a30:	8b 40 3c             	mov    0x3c(%eax),%eax
c0102a33:	89 45 f4             	mov    %eax,-0xc(%ebp)
        current->tf = tf;
c0102a36:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c0102a3b:	8b 55 08             	mov    0x8(%ebp),%edx
c0102a3e:	89 50 3c             	mov    %edx,0x3c(%eax)
    
        bool in_kernel = trap_in_kernel(tf);
c0102a41:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a44:	89 04 24             	mov    %eax,(%esp)
c0102a47:	e8 b5 f9 ff ff       	call   c0102401 <trap_in_kernel>
c0102a4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    
        trap_dispatch(tf);
c0102a4f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a52:	89 04 24             	mov    %eax,(%esp)
c0102a55:	e8 82 fd ff ff       	call   c01027dc <trap_dispatch>
    
        current->tf = otf;
c0102a5a:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c0102a5f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102a62:	89 50 3c             	mov    %edx,0x3c(%eax)
        if (!in_kernel) {
c0102a65:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0102a69:	75 2c                	jne    c0102a97 <trap+0x88>
            if (current->flags & PF_EXITING) {
c0102a6b:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c0102a70:	8b 40 44             	mov    0x44(%eax),%eax
c0102a73:	83 e0 01             	and    $0x1,%eax
c0102a76:	85 c0                	test   %eax,%eax
c0102a78:	74 0c                	je     c0102a86 <trap+0x77>
                do_exit(-E_KILLED);
c0102a7a:	c7 04 24 f7 ff ff ff 	movl   $0xfffffff7,(%esp)
c0102a81:	e8 e4 74 00 00       	call   c0109f6a <do_exit>
            }
            if (current->need_resched) {
c0102a86:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c0102a8b:	8b 40 10             	mov    0x10(%eax),%eax
c0102a8e:	85 c0                	test   %eax,%eax
c0102a90:	74 05                	je     c0102a97 <trap+0x88>
                schedule();
c0102a92:	e8 4e 86 00 00       	call   c010b0e5 <schedule>
            }
        }
    }
}
c0102a97:	c9                   	leave  
c0102a98:	c3                   	ret    

c0102a99 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0102a99:	6a 00                	push   $0x0
  pushl $0
c0102a9b:	6a 00                	push   $0x0
  jmp __alltraps
c0102a9d:	e9 69 0a 00 00       	jmp    c010350b <__alltraps>

c0102aa2 <vector1>:
.globl vector1
vector1:
  pushl $0
c0102aa2:	6a 00                	push   $0x0
  pushl $1
c0102aa4:	6a 01                	push   $0x1
  jmp __alltraps
c0102aa6:	e9 60 0a 00 00       	jmp    c010350b <__alltraps>

c0102aab <vector2>:
.globl vector2
vector2:
  pushl $0
c0102aab:	6a 00                	push   $0x0
  pushl $2
c0102aad:	6a 02                	push   $0x2
  jmp __alltraps
c0102aaf:	e9 57 0a 00 00       	jmp    c010350b <__alltraps>

c0102ab4 <vector3>:
.globl vector3
vector3:
  pushl $0
c0102ab4:	6a 00                	push   $0x0
  pushl $3
c0102ab6:	6a 03                	push   $0x3
  jmp __alltraps
c0102ab8:	e9 4e 0a 00 00       	jmp    c010350b <__alltraps>

c0102abd <vector4>:
.globl vector4
vector4:
  pushl $0
c0102abd:	6a 00                	push   $0x0
  pushl $4
c0102abf:	6a 04                	push   $0x4
  jmp __alltraps
c0102ac1:	e9 45 0a 00 00       	jmp    c010350b <__alltraps>

c0102ac6 <vector5>:
.globl vector5
vector5:
  pushl $0
c0102ac6:	6a 00                	push   $0x0
  pushl $5
c0102ac8:	6a 05                	push   $0x5
  jmp __alltraps
c0102aca:	e9 3c 0a 00 00       	jmp    c010350b <__alltraps>

c0102acf <vector6>:
.globl vector6
vector6:
  pushl $0
c0102acf:	6a 00                	push   $0x0
  pushl $6
c0102ad1:	6a 06                	push   $0x6
  jmp __alltraps
c0102ad3:	e9 33 0a 00 00       	jmp    c010350b <__alltraps>

c0102ad8 <vector7>:
.globl vector7
vector7:
  pushl $0
c0102ad8:	6a 00                	push   $0x0
  pushl $7
c0102ada:	6a 07                	push   $0x7
  jmp __alltraps
c0102adc:	e9 2a 0a 00 00       	jmp    c010350b <__alltraps>

c0102ae1 <vector8>:
.globl vector8
vector8:
  pushl $8
c0102ae1:	6a 08                	push   $0x8
  jmp __alltraps
c0102ae3:	e9 23 0a 00 00       	jmp    c010350b <__alltraps>

c0102ae8 <vector9>:
.globl vector9
vector9:
  pushl $0
c0102ae8:	6a 00                	push   $0x0
  pushl $9
c0102aea:	6a 09                	push   $0x9
  jmp __alltraps
c0102aec:	e9 1a 0a 00 00       	jmp    c010350b <__alltraps>

c0102af1 <vector10>:
.globl vector10
vector10:
  pushl $10
c0102af1:	6a 0a                	push   $0xa
  jmp __alltraps
c0102af3:	e9 13 0a 00 00       	jmp    c010350b <__alltraps>

c0102af8 <vector11>:
.globl vector11
vector11:
  pushl $11
c0102af8:	6a 0b                	push   $0xb
  jmp __alltraps
c0102afa:	e9 0c 0a 00 00       	jmp    c010350b <__alltraps>

c0102aff <vector12>:
.globl vector12
vector12:
  pushl $12
c0102aff:	6a 0c                	push   $0xc
  jmp __alltraps
c0102b01:	e9 05 0a 00 00       	jmp    c010350b <__alltraps>

c0102b06 <vector13>:
.globl vector13
vector13:
  pushl $13
c0102b06:	6a 0d                	push   $0xd
  jmp __alltraps
c0102b08:	e9 fe 09 00 00       	jmp    c010350b <__alltraps>

c0102b0d <vector14>:
.globl vector14
vector14:
  pushl $14
c0102b0d:	6a 0e                	push   $0xe
  jmp __alltraps
c0102b0f:	e9 f7 09 00 00       	jmp    c010350b <__alltraps>

c0102b14 <vector15>:
.globl vector15
vector15:
  pushl $0
c0102b14:	6a 00                	push   $0x0
  pushl $15
c0102b16:	6a 0f                	push   $0xf
  jmp __alltraps
c0102b18:	e9 ee 09 00 00       	jmp    c010350b <__alltraps>

c0102b1d <vector16>:
.globl vector16
vector16:
  pushl $0
c0102b1d:	6a 00                	push   $0x0
  pushl $16
c0102b1f:	6a 10                	push   $0x10
  jmp __alltraps
c0102b21:	e9 e5 09 00 00       	jmp    c010350b <__alltraps>

c0102b26 <vector17>:
.globl vector17
vector17:
  pushl $17
c0102b26:	6a 11                	push   $0x11
  jmp __alltraps
c0102b28:	e9 de 09 00 00       	jmp    c010350b <__alltraps>

c0102b2d <vector18>:
.globl vector18
vector18:
  pushl $0
c0102b2d:	6a 00                	push   $0x0
  pushl $18
c0102b2f:	6a 12                	push   $0x12
  jmp __alltraps
c0102b31:	e9 d5 09 00 00       	jmp    c010350b <__alltraps>

c0102b36 <vector19>:
.globl vector19
vector19:
  pushl $0
c0102b36:	6a 00                	push   $0x0
  pushl $19
c0102b38:	6a 13                	push   $0x13
  jmp __alltraps
c0102b3a:	e9 cc 09 00 00       	jmp    c010350b <__alltraps>

c0102b3f <vector20>:
.globl vector20
vector20:
  pushl $0
c0102b3f:	6a 00                	push   $0x0
  pushl $20
c0102b41:	6a 14                	push   $0x14
  jmp __alltraps
c0102b43:	e9 c3 09 00 00       	jmp    c010350b <__alltraps>

c0102b48 <vector21>:
.globl vector21
vector21:
  pushl $0
c0102b48:	6a 00                	push   $0x0
  pushl $21
c0102b4a:	6a 15                	push   $0x15
  jmp __alltraps
c0102b4c:	e9 ba 09 00 00       	jmp    c010350b <__alltraps>

c0102b51 <vector22>:
.globl vector22
vector22:
  pushl $0
c0102b51:	6a 00                	push   $0x0
  pushl $22
c0102b53:	6a 16                	push   $0x16
  jmp __alltraps
c0102b55:	e9 b1 09 00 00       	jmp    c010350b <__alltraps>

c0102b5a <vector23>:
.globl vector23
vector23:
  pushl $0
c0102b5a:	6a 00                	push   $0x0
  pushl $23
c0102b5c:	6a 17                	push   $0x17
  jmp __alltraps
c0102b5e:	e9 a8 09 00 00       	jmp    c010350b <__alltraps>

c0102b63 <vector24>:
.globl vector24
vector24:
  pushl $0
c0102b63:	6a 00                	push   $0x0
  pushl $24
c0102b65:	6a 18                	push   $0x18
  jmp __alltraps
c0102b67:	e9 9f 09 00 00       	jmp    c010350b <__alltraps>

c0102b6c <vector25>:
.globl vector25
vector25:
  pushl $0
c0102b6c:	6a 00                	push   $0x0
  pushl $25
c0102b6e:	6a 19                	push   $0x19
  jmp __alltraps
c0102b70:	e9 96 09 00 00       	jmp    c010350b <__alltraps>

c0102b75 <vector26>:
.globl vector26
vector26:
  pushl $0
c0102b75:	6a 00                	push   $0x0
  pushl $26
c0102b77:	6a 1a                	push   $0x1a
  jmp __alltraps
c0102b79:	e9 8d 09 00 00       	jmp    c010350b <__alltraps>

c0102b7e <vector27>:
.globl vector27
vector27:
  pushl $0
c0102b7e:	6a 00                	push   $0x0
  pushl $27
c0102b80:	6a 1b                	push   $0x1b
  jmp __alltraps
c0102b82:	e9 84 09 00 00       	jmp    c010350b <__alltraps>

c0102b87 <vector28>:
.globl vector28
vector28:
  pushl $0
c0102b87:	6a 00                	push   $0x0
  pushl $28
c0102b89:	6a 1c                	push   $0x1c
  jmp __alltraps
c0102b8b:	e9 7b 09 00 00       	jmp    c010350b <__alltraps>

c0102b90 <vector29>:
.globl vector29
vector29:
  pushl $0
c0102b90:	6a 00                	push   $0x0
  pushl $29
c0102b92:	6a 1d                	push   $0x1d
  jmp __alltraps
c0102b94:	e9 72 09 00 00       	jmp    c010350b <__alltraps>

c0102b99 <vector30>:
.globl vector30
vector30:
  pushl $0
c0102b99:	6a 00                	push   $0x0
  pushl $30
c0102b9b:	6a 1e                	push   $0x1e
  jmp __alltraps
c0102b9d:	e9 69 09 00 00       	jmp    c010350b <__alltraps>

c0102ba2 <vector31>:
.globl vector31
vector31:
  pushl $0
c0102ba2:	6a 00                	push   $0x0
  pushl $31
c0102ba4:	6a 1f                	push   $0x1f
  jmp __alltraps
c0102ba6:	e9 60 09 00 00       	jmp    c010350b <__alltraps>

c0102bab <vector32>:
.globl vector32
vector32:
  pushl $0
c0102bab:	6a 00                	push   $0x0
  pushl $32
c0102bad:	6a 20                	push   $0x20
  jmp __alltraps
c0102baf:	e9 57 09 00 00       	jmp    c010350b <__alltraps>

c0102bb4 <vector33>:
.globl vector33
vector33:
  pushl $0
c0102bb4:	6a 00                	push   $0x0
  pushl $33
c0102bb6:	6a 21                	push   $0x21
  jmp __alltraps
c0102bb8:	e9 4e 09 00 00       	jmp    c010350b <__alltraps>

c0102bbd <vector34>:
.globl vector34
vector34:
  pushl $0
c0102bbd:	6a 00                	push   $0x0
  pushl $34
c0102bbf:	6a 22                	push   $0x22
  jmp __alltraps
c0102bc1:	e9 45 09 00 00       	jmp    c010350b <__alltraps>

c0102bc6 <vector35>:
.globl vector35
vector35:
  pushl $0
c0102bc6:	6a 00                	push   $0x0
  pushl $35
c0102bc8:	6a 23                	push   $0x23
  jmp __alltraps
c0102bca:	e9 3c 09 00 00       	jmp    c010350b <__alltraps>

c0102bcf <vector36>:
.globl vector36
vector36:
  pushl $0
c0102bcf:	6a 00                	push   $0x0
  pushl $36
c0102bd1:	6a 24                	push   $0x24
  jmp __alltraps
c0102bd3:	e9 33 09 00 00       	jmp    c010350b <__alltraps>

c0102bd8 <vector37>:
.globl vector37
vector37:
  pushl $0
c0102bd8:	6a 00                	push   $0x0
  pushl $37
c0102bda:	6a 25                	push   $0x25
  jmp __alltraps
c0102bdc:	e9 2a 09 00 00       	jmp    c010350b <__alltraps>

c0102be1 <vector38>:
.globl vector38
vector38:
  pushl $0
c0102be1:	6a 00                	push   $0x0
  pushl $38
c0102be3:	6a 26                	push   $0x26
  jmp __alltraps
c0102be5:	e9 21 09 00 00       	jmp    c010350b <__alltraps>

c0102bea <vector39>:
.globl vector39
vector39:
  pushl $0
c0102bea:	6a 00                	push   $0x0
  pushl $39
c0102bec:	6a 27                	push   $0x27
  jmp __alltraps
c0102bee:	e9 18 09 00 00       	jmp    c010350b <__alltraps>

c0102bf3 <vector40>:
.globl vector40
vector40:
  pushl $0
c0102bf3:	6a 00                	push   $0x0
  pushl $40
c0102bf5:	6a 28                	push   $0x28
  jmp __alltraps
c0102bf7:	e9 0f 09 00 00       	jmp    c010350b <__alltraps>

c0102bfc <vector41>:
.globl vector41
vector41:
  pushl $0
c0102bfc:	6a 00                	push   $0x0
  pushl $41
c0102bfe:	6a 29                	push   $0x29
  jmp __alltraps
c0102c00:	e9 06 09 00 00       	jmp    c010350b <__alltraps>

c0102c05 <vector42>:
.globl vector42
vector42:
  pushl $0
c0102c05:	6a 00                	push   $0x0
  pushl $42
c0102c07:	6a 2a                	push   $0x2a
  jmp __alltraps
c0102c09:	e9 fd 08 00 00       	jmp    c010350b <__alltraps>

c0102c0e <vector43>:
.globl vector43
vector43:
  pushl $0
c0102c0e:	6a 00                	push   $0x0
  pushl $43
c0102c10:	6a 2b                	push   $0x2b
  jmp __alltraps
c0102c12:	e9 f4 08 00 00       	jmp    c010350b <__alltraps>

c0102c17 <vector44>:
.globl vector44
vector44:
  pushl $0
c0102c17:	6a 00                	push   $0x0
  pushl $44
c0102c19:	6a 2c                	push   $0x2c
  jmp __alltraps
c0102c1b:	e9 eb 08 00 00       	jmp    c010350b <__alltraps>

c0102c20 <vector45>:
.globl vector45
vector45:
  pushl $0
c0102c20:	6a 00                	push   $0x0
  pushl $45
c0102c22:	6a 2d                	push   $0x2d
  jmp __alltraps
c0102c24:	e9 e2 08 00 00       	jmp    c010350b <__alltraps>

c0102c29 <vector46>:
.globl vector46
vector46:
  pushl $0
c0102c29:	6a 00                	push   $0x0
  pushl $46
c0102c2b:	6a 2e                	push   $0x2e
  jmp __alltraps
c0102c2d:	e9 d9 08 00 00       	jmp    c010350b <__alltraps>

c0102c32 <vector47>:
.globl vector47
vector47:
  pushl $0
c0102c32:	6a 00                	push   $0x0
  pushl $47
c0102c34:	6a 2f                	push   $0x2f
  jmp __alltraps
c0102c36:	e9 d0 08 00 00       	jmp    c010350b <__alltraps>

c0102c3b <vector48>:
.globl vector48
vector48:
  pushl $0
c0102c3b:	6a 00                	push   $0x0
  pushl $48
c0102c3d:	6a 30                	push   $0x30
  jmp __alltraps
c0102c3f:	e9 c7 08 00 00       	jmp    c010350b <__alltraps>

c0102c44 <vector49>:
.globl vector49
vector49:
  pushl $0
c0102c44:	6a 00                	push   $0x0
  pushl $49
c0102c46:	6a 31                	push   $0x31
  jmp __alltraps
c0102c48:	e9 be 08 00 00       	jmp    c010350b <__alltraps>

c0102c4d <vector50>:
.globl vector50
vector50:
  pushl $0
c0102c4d:	6a 00                	push   $0x0
  pushl $50
c0102c4f:	6a 32                	push   $0x32
  jmp __alltraps
c0102c51:	e9 b5 08 00 00       	jmp    c010350b <__alltraps>

c0102c56 <vector51>:
.globl vector51
vector51:
  pushl $0
c0102c56:	6a 00                	push   $0x0
  pushl $51
c0102c58:	6a 33                	push   $0x33
  jmp __alltraps
c0102c5a:	e9 ac 08 00 00       	jmp    c010350b <__alltraps>

c0102c5f <vector52>:
.globl vector52
vector52:
  pushl $0
c0102c5f:	6a 00                	push   $0x0
  pushl $52
c0102c61:	6a 34                	push   $0x34
  jmp __alltraps
c0102c63:	e9 a3 08 00 00       	jmp    c010350b <__alltraps>

c0102c68 <vector53>:
.globl vector53
vector53:
  pushl $0
c0102c68:	6a 00                	push   $0x0
  pushl $53
c0102c6a:	6a 35                	push   $0x35
  jmp __alltraps
c0102c6c:	e9 9a 08 00 00       	jmp    c010350b <__alltraps>

c0102c71 <vector54>:
.globl vector54
vector54:
  pushl $0
c0102c71:	6a 00                	push   $0x0
  pushl $54
c0102c73:	6a 36                	push   $0x36
  jmp __alltraps
c0102c75:	e9 91 08 00 00       	jmp    c010350b <__alltraps>

c0102c7a <vector55>:
.globl vector55
vector55:
  pushl $0
c0102c7a:	6a 00                	push   $0x0
  pushl $55
c0102c7c:	6a 37                	push   $0x37
  jmp __alltraps
c0102c7e:	e9 88 08 00 00       	jmp    c010350b <__alltraps>

c0102c83 <vector56>:
.globl vector56
vector56:
  pushl $0
c0102c83:	6a 00                	push   $0x0
  pushl $56
c0102c85:	6a 38                	push   $0x38
  jmp __alltraps
c0102c87:	e9 7f 08 00 00       	jmp    c010350b <__alltraps>

c0102c8c <vector57>:
.globl vector57
vector57:
  pushl $0
c0102c8c:	6a 00                	push   $0x0
  pushl $57
c0102c8e:	6a 39                	push   $0x39
  jmp __alltraps
c0102c90:	e9 76 08 00 00       	jmp    c010350b <__alltraps>

c0102c95 <vector58>:
.globl vector58
vector58:
  pushl $0
c0102c95:	6a 00                	push   $0x0
  pushl $58
c0102c97:	6a 3a                	push   $0x3a
  jmp __alltraps
c0102c99:	e9 6d 08 00 00       	jmp    c010350b <__alltraps>

c0102c9e <vector59>:
.globl vector59
vector59:
  pushl $0
c0102c9e:	6a 00                	push   $0x0
  pushl $59
c0102ca0:	6a 3b                	push   $0x3b
  jmp __alltraps
c0102ca2:	e9 64 08 00 00       	jmp    c010350b <__alltraps>

c0102ca7 <vector60>:
.globl vector60
vector60:
  pushl $0
c0102ca7:	6a 00                	push   $0x0
  pushl $60
c0102ca9:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102cab:	e9 5b 08 00 00       	jmp    c010350b <__alltraps>

c0102cb0 <vector61>:
.globl vector61
vector61:
  pushl $0
c0102cb0:	6a 00                	push   $0x0
  pushl $61
c0102cb2:	6a 3d                	push   $0x3d
  jmp __alltraps
c0102cb4:	e9 52 08 00 00       	jmp    c010350b <__alltraps>

c0102cb9 <vector62>:
.globl vector62
vector62:
  pushl $0
c0102cb9:	6a 00                	push   $0x0
  pushl $62
c0102cbb:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102cbd:	e9 49 08 00 00       	jmp    c010350b <__alltraps>

c0102cc2 <vector63>:
.globl vector63
vector63:
  pushl $0
c0102cc2:	6a 00                	push   $0x0
  pushl $63
c0102cc4:	6a 3f                	push   $0x3f
  jmp __alltraps
c0102cc6:	e9 40 08 00 00       	jmp    c010350b <__alltraps>

c0102ccb <vector64>:
.globl vector64
vector64:
  pushl $0
c0102ccb:	6a 00                	push   $0x0
  pushl $64
c0102ccd:	6a 40                	push   $0x40
  jmp __alltraps
c0102ccf:	e9 37 08 00 00       	jmp    c010350b <__alltraps>

c0102cd4 <vector65>:
.globl vector65
vector65:
  pushl $0
c0102cd4:	6a 00                	push   $0x0
  pushl $65
c0102cd6:	6a 41                	push   $0x41
  jmp __alltraps
c0102cd8:	e9 2e 08 00 00       	jmp    c010350b <__alltraps>

c0102cdd <vector66>:
.globl vector66
vector66:
  pushl $0
c0102cdd:	6a 00                	push   $0x0
  pushl $66
c0102cdf:	6a 42                	push   $0x42
  jmp __alltraps
c0102ce1:	e9 25 08 00 00       	jmp    c010350b <__alltraps>

c0102ce6 <vector67>:
.globl vector67
vector67:
  pushl $0
c0102ce6:	6a 00                	push   $0x0
  pushl $67
c0102ce8:	6a 43                	push   $0x43
  jmp __alltraps
c0102cea:	e9 1c 08 00 00       	jmp    c010350b <__alltraps>

c0102cef <vector68>:
.globl vector68
vector68:
  pushl $0
c0102cef:	6a 00                	push   $0x0
  pushl $68
c0102cf1:	6a 44                	push   $0x44
  jmp __alltraps
c0102cf3:	e9 13 08 00 00       	jmp    c010350b <__alltraps>

c0102cf8 <vector69>:
.globl vector69
vector69:
  pushl $0
c0102cf8:	6a 00                	push   $0x0
  pushl $69
c0102cfa:	6a 45                	push   $0x45
  jmp __alltraps
c0102cfc:	e9 0a 08 00 00       	jmp    c010350b <__alltraps>

c0102d01 <vector70>:
.globl vector70
vector70:
  pushl $0
c0102d01:	6a 00                	push   $0x0
  pushl $70
c0102d03:	6a 46                	push   $0x46
  jmp __alltraps
c0102d05:	e9 01 08 00 00       	jmp    c010350b <__alltraps>

c0102d0a <vector71>:
.globl vector71
vector71:
  pushl $0
c0102d0a:	6a 00                	push   $0x0
  pushl $71
c0102d0c:	6a 47                	push   $0x47
  jmp __alltraps
c0102d0e:	e9 f8 07 00 00       	jmp    c010350b <__alltraps>

c0102d13 <vector72>:
.globl vector72
vector72:
  pushl $0
c0102d13:	6a 00                	push   $0x0
  pushl $72
c0102d15:	6a 48                	push   $0x48
  jmp __alltraps
c0102d17:	e9 ef 07 00 00       	jmp    c010350b <__alltraps>

c0102d1c <vector73>:
.globl vector73
vector73:
  pushl $0
c0102d1c:	6a 00                	push   $0x0
  pushl $73
c0102d1e:	6a 49                	push   $0x49
  jmp __alltraps
c0102d20:	e9 e6 07 00 00       	jmp    c010350b <__alltraps>

c0102d25 <vector74>:
.globl vector74
vector74:
  pushl $0
c0102d25:	6a 00                	push   $0x0
  pushl $74
c0102d27:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102d29:	e9 dd 07 00 00       	jmp    c010350b <__alltraps>

c0102d2e <vector75>:
.globl vector75
vector75:
  pushl $0
c0102d2e:	6a 00                	push   $0x0
  pushl $75
c0102d30:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102d32:	e9 d4 07 00 00       	jmp    c010350b <__alltraps>

c0102d37 <vector76>:
.globl vector76
vector76:
  pushl $0
c0102d37:	6a 00                	push   $0x0
  pushl $76
c0102d39:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102d3b:	e9 cb 07 00 00       	jmp    c010350b <__alltraps>

c0102d40 <vector77>:
.globl vector77
vector77:
  pushl $0
c0102d40:	6a 00                	push   $0x0
  pushl $77
c0102d42:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102d44:	e9 c2 07 00 00       	jmp    c010350b <__alltraps>

c0102d49 <vector78>:
.globl vector78
vector78:
  pushl $0
c0102d49:	6a 00                	push   $0x0
  pushl $78
c0102d4b:	6a 4e                	push   $0x4e
  jmp __alltraps
c0102d4d:	e9 b9 07 00 00       	jmp    c010350b <__alltraps>

c0102d52 <vector79>:
.globl vector79
vector79:
  pushl $0
c0102d52:	6a 00                	push   $0x0
  pushl $79
c0102d54:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102d56:	e9 b0 07 00 00       	jmp    c010350b <__alltraps>

c0102d5b <vector80>:
.globl vector80
vector80:
  pushl $0
c0102d5b:	6a 00                	push   $0x0
  pushl $80
c0102d5d:	6a 50                	push   $0x50
  jmp __alltraps
c0102d5f:	e9 a7 07 00 00       	jmp    c010350b <__alltraps>

c0102d64 <vector81>:
.globl vector81
vector81:
  pushl $0
c0102d64:	6a 00                	push   $0x0
  pushl $81
c0102d66:	6a 51                	push   $0x51
  jmp __alltraps
c0102d68:	e9 9e 07 00 00       	jmp    c010350b <__alltraps>

c0102d6d <vector82>:
.globl vector82
vector82:
  pushl $0
c0102d6d:	6a 00                	push   $0x0
  pushl $82
c0102d6f:	6a 52                	push   $0x52
  jmp __alltraps
c0102d71:	e9 95 07 00 00       	jmp    c010350b <__alltraps>

c0102d76 <vector83>:
.globl vector83
vector83:
  pushl $0
c0102d76:	6a 00                	push   $0x0
  pushl $83
c0102d78:	6a 53                	push   $0x53
  jmp __alltraps
c0102d7a:	e9 8c 07 00 00       	jmp    c010350b <__alltraps>

c0102d7f <vector84>:
.globl vector84
vector84:
  pushl $0
c0102d7f:	6a 00                	push   $0x0
  pushl $84
c0102d81:	6a 54                	push   $0x54
  jmp __alltraps
c0102d83:	e9 83 07 00 00       	jmp    c010350b <__alltraps>

c0102d88 <vector85>:
.globl vector85
vector85:
  pushl $0
c0102d88:	6a 00                	push   $0x0
  pushl $85
c0102d8a:	6a 55                	push   $0x55
  jmp __alltraps
c0102d8c:	e9 7a 07 00 00       	jmp    c010350b <__alltraps>

c0102d91 <vector86>:
.globl vector86
vector86:
  pushl $0
c0102d91:	6a 00                	push   $0x0
  pushl $86
c0102d93:	6a 56                	push   $0x56
  jmp __alltraps
c0102d95:	e9 71 07 00 00       	jmp    c010350b <__alltraps>

c0102d9a <vector87>:
.globl vector87
vector87:
  pushl $0
c0102d9a:	6a 00                	push   $0x0
  pushl $87
c0102d9c:	6a 57                	push   $0x57
  jmp __alltraps
c0102d9e:	e9 68 07 00 00       	jmp    c010350b <__alltraps>

c0102da3 <vector88>:
.globl vector88
vector88:
  pushl $0
c0102da3:	6a 00                	push   $0x0
  pushl $88
c0102da5:	6a 58                	push   $0x58
  jmp __alltraps
c0102da7:	e9 5f 07 00 00       	jmp    c010350b <__alltraps>

c0102dac <vector89>:
.globl vector89
vector89:
  pushl $0
c0102dac:	6a 00                	push   $0x0
  pushl $89
c0102dae:	6a 59                	push   $0x59
  jmp __alltraps
c0102db0:	e9 56 07 00 00       	jmp    c010350b <__alltraps>

c0102db5 <vector90>:
.globl vector90
vector90:
  pushl $0
c0102db5:	6a 00                	push   $0x0
  pushl $90
c0102db7:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102db9:	e9 4d 07 00 00       	jmp    c010350b <__alltraps>

c0102dbe <vector91>:
.globl vector91
vector91:
  pushl $0
c0102dbe:	6a 00                	push   $0x0
  pushl $91
c0102dc0:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102dc2:	e9 44 07 00 00       	jmp    c010350b <__alltraps>

c0102dc7 <vector92>:
.globl vector92
vector92:
  pushl $0
c0102dc7:	6a 00                	push   $0x0
  pushl $92
c0102dc9:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102dcb:	e9 3b 07 00 00       	jmp    c010350b <__alltraps>

c0102dd0 <vector93>:
.globl vector93
vector93:
  pushl $0
c0102dd0:	6a 00                	push   $0x0
  pushl $93
c0102dd2:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102dd4:	e9 32 07 00 00       	jmp    c010350b <__alltraps>

c0102dd9 <vector94>:
.globl vector94
vector94:
  pushl $0
c0102dd9:	6a 00                	push   $0x0
  pushl $94
c0102ddb:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102ddd:	e9 29 07 00 00       	jmp    c010350b <__alltraps>

c0102de2 <vector95>:
.globl vector95
vector95:
  pushl $0
c0102de2:	6a 00                	push   $0x0
  pushl $95
c0102de4:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102de6:	e9 20 07 00 00       	jmp    c010350b <__alltraps>

c0102deb <vector96>:
.globl vector96
vector96:
  pushl $0
c0102deb:	6a 00                	push   $0x0
  pushl $96
c0102ded:	6a 60                	push   $0x60
  jmp __alltraps
c0102def:	e9 17 07 00 00       	jmp    c010350b <__alltraps>

c0102df4 <vector97>:
.globl vector97
vector97:
  pushl $0
c0102df4:	6a 00                	push   $0x0
  pushl $97
c0102df6:	6a 61                	push   $0x61
  jmp __alltraps
c0102df8:	e9 0e 07 00 00       	jmp    c010350b <__alltraps>

c0102dfd <vector98>:
.globl vector98
vector98:
  pushl $0
c0102dfd:	6a 00                	push   $0x0
  pushl $98
c0102dff:	6a 62                	push   $0x62
  jmp __alltraps
c0102e01:	e9 05 07 00 00       	jmp    c010350b <__alltraps>

c0102e06 <vector99>:
.globl vector99
vector99:
  pushl $0
c0102e06:	6a 00                	push   $0x0
  pushl $99
c0102e08:	6a 63                	push   $0x63
  jmp __alltraps
c0102e0a:	e9 fc 06 00 00       	jmp    c010350b <__alltraps>

c0102e0f <vector100>:
.globl vector100
vector100:
  pushl $0
c0102e0f:	6a 00                	push   $0x0
  pushl $100
c0102e11:	6a 64                	push   $0x64
  jmp __alltraps
c0102e13:	e9 f3 06 00 00       	jmp    c010350b <__alltraps>

c0102e18 <vector101>:
.globl vector101
vector101:
  pushl $0
c0102e18:	6a 00                	push   $0x0
  pushl $101
c0102e1a:	6a 65                	push   $0x65
  jmp __alltraps
c0102e1c:	e9 ea 06 00 00       	jmp    c010350b <__alltraps>

c0102e21 <vector102>:
.globl vector102
vector102:
  pushl $0
c0102e21:	6a 00                	push   $0x0
  pushl $102
c0102e23:	6a 66                	push   $0x66
  jmp __alltraps
c0102e25:	e9 e1 06 00 00       	jmp    c010350b <__alltraps>

c0102e2a <vector103>:
.globl vector103
vector103:
  pushl $0
c0102e2a:	6a 00                	push   $0x0
  pushl $103
c0102e2c:	6a 67                	push   $0x67
  jmp __alltraps
c0102e2e:	e9 d8 06 00 00       	jmp    c010350b <__alltraps>

c0102e33 <vector104>:
.globl vector104
vector104:
  pushl $0
c0102e33:	6a 00                	push   $0x0
  pushl $104
c0102e35:	6a 68                	push   $0x68
  jmp __alltraps
c0102e37:	e9 cf 06 00 00       	jmp    c010350b <__alltraps>

c0102e3c <vector105>:
.globl vector105
vector105:
  pushl $0
c0102e3c:	6a 00                	push   $0x0
  pushl $105
c0102e3e:	6a 69                	push   $0x69
  jmp __alltraps
c0102e40:	e9 c6 06 00 00       	jmp    c010350b <__alltraps>

c0102e45 <vector106>:
.globl vector106
vector106:
  pushl $0
c0102e45:	6a 00                	push   $0x0
  pushl $106
c0102e47:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102e49:	e9 bd 06 00 00       	jmp    c010350b <__alltraps>

c0102e4e <vector107>:
.globl vector107
vector107:
  pushl $0
c0102e4e:	6a 00                	push   $0x0
  pushl $107
c0102e50:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102e52:	e9 b4 06 00 00       	jmp    c010350b <__alltraps>

c0102e57 <vector108>:
.globl vector108
vector108:
  pushl $0
c0102e57:	6a 00                	push   $0x0
  pushl $108
c0102e59:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102e5b:	e9 ab 06 00 00       	jmp    c010350b <__alltraps>

c0102e60 <vector109>:
.globl vector109
vector109:
  pushl $0
c0102e60:	6a 00                	push   $0x0
  pushl $109
c0102e62:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102e64:	e9 a2 06 00 00       	jmp    c010350b <__alltraps>

c0102e69 <vector110>:
.globl vector110
vector110:
  pushl $0
c0102e69:	6a 00                	push   $0x0
  pushl $110
c0102e6b:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102e6d:	e9 99 06 00 00       	jmp    c010350b <__alltraps>

c0102e72 <vector111>:
.globl vector111
vector111:
  pushl $0
c0102e72:	6a 00                	push   $0x0
  pushl $111
c0102e74:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102e76:	e9 90 06 00 00       	jmp    c010350b <__alltraps>

c0102e7b <vector112>:
.globl vector112
vector112:
  pushl $0
c0102e7b:	6a 00                	push   $0x0
  pushl $112
c0102e7d:	6a 70                	push   $0x70
  jmp __alltraps
c0102e7f:	e9 87 06 00 00       	jmp    c010350b <__alltraps>

c0102e84 <vector113>:
.globl vector113
vector113:
  pushl $0
c0102e84:	6a 00                	push   $0x0
  pushl $113
c0102e86:	6a 71                	push   $0x71
  jmp __alltraps
c0102e88:	e9 7e 06 00 00       	jmp    c010350b <__alltraps>

c0102e8d <vector114>:
.globl vector114
vector114:
  pushl $0
c0102e8d:	6a 00                	push   $0x0
  pushl $114
c0102e8f:	6a 72                	push   $0x72
  jmp __alltraps
c0102e91:	e9 75 06 00 00       	jmp    c010350b <__alltraps>

c0102e96 <vector115>:
.globl vector115
vector115:
  pushl $0
c0102e96:	6a 00                	push   $0x0
  pushl $115
c0102e98:	6a 73                	push   $0x73
  jmp __alltraps
c0102e9a:	e9 6c 06 00 00       	jmp    c010350b <__alltraps>

c0102e9f <vector116>:
.globl vector116
vector116:
  pushl $0
c0102e9f:	6a 00                	push   $0x0
  pushl $116
c0102ea1:	6a 74                	push   $0x74
  jmp __alltraps
c0102ea3:	e9 63 06 00 00       	jmp    c010350b <__alltraps>

c0102ea8 <vector117>:
.globl vector117
vector117:
  pushl $0
c0102ea8:	6a 00                	push   $0x0
  pushl $117
c0102eaa:	6a 75                	push   $0x75
  jmp __alltraps
c0102eac:	e9 5a 06 00 00       	jmp    c010350b <__alltraps>

c0102eb1 <vector118>:
.globl vector118
vector118:
  pushl $0
c0102eb1:	6a 00                	push   $0x0
  pushl $118
c0102eb3:	6a 76                	push   $0x76
  jmp __alltraps
c0102eb5:	e9 51 06 00 00       	jmp    c010350b <__alltraps>

c0102eba <vector119>:
.globl vector119
vector119:
  pushl $0
c0102eba:	6a 00                	push   $0x0
  pushl $119
c0102ebc:	6a 77                	push   $0x77
  jmp __alltraps
c0102ebe:	e9 48 06 00 00       	jmp    c010350b <__alltraps>

c0102ec3 <vector120>:
.globl vector120
vector120:
  pushl $0
c0102ec3:	6a 00                	push   $0x0
  pushl $120
c0102ec5:	6a 78                	push   $0x78
  jmp __alltraps
c0102ec7:	e9 3f 06 00 00       	jmp    c010350b <__alltraps>

c0102ecc <vector121>:
.globl vector121
vector121:
  pushl $0
c0102ecc:	6a 00                	push   $0x0
  pushl $121
c0102ece:	6a 79                	push   $0x79
  jmp __alltraps
c0102ed0:	e9 36 06 00 00       	jmp    c010350b <__alltraps>

c0102ed5 <vector122>:
.globl vector122
vector122:
  pushl $0
c0102ed5:	6a 00                	push   $0x0
  pushl $122
c0102ed7:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102ed9:	e9 2d 06 00 00       	jmp    c010350b <__alltraps>

c0102ede <vector123>:
.globl vector123
vector123:
  pushl $0
c0102ede:	6a 00                	push   $0x0
  pushl $123
c0102ee0:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102ee2:	e9 24 06 00 00       	jmp    c010350b <__alltraps>

c0102ee7 <vector124>:
.globl vector124
vector124:
  pushl $0
c0102ee7:	6a 00                	push   $0x0
  pushl $124
c0102ee9:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102eeb:	e9 1b 06 00 00       	jmp    c010350b <__alltraps>

c0102ef0 <vector125>:
.globl vector125
vector125:
  pushl $0
c0102ef0:	6a 00                	push   $0x0
  pushl $125
c0102ef2:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102ef4:	e9 12 06 00 00       	jmp    c010350b <__alltraps>

c0102ef9 <vector126>:
.globl vector126
vector126:
  pushl $0
c0102ef9:	6a 00                	push   $0x0
  pushl $126
c0102efb:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102efd:	e9 09 06 00 00       	jmp    c010350b <__alltraps>

c0102f02 <vector127>:
.globl vector127
vector127:
  pushl $0
c0102f02:	6a 00                	push   $0x0
  pushl $127
c0102f04:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102f06:	e9 00 06 00 00       	jmp    c010350b <__alltraps>

c0102f0b <vector128>:
.globl vector128
vector128:
  pushl $0
c0102f0b:	6a 00                	push   $0x0
  pushl $128
c0102f0d:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102f12:	e9 f4 05 00 00       	jmp    c010350b <__alltraps>

c0102f17 <vector129>:
.globl vector129
vector129:
  pushl $0
c0102f17:	6a 00                	push   $0x0
  pushl $129
c0102f19:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102f1e:	e9 e8 05 00 00       	jmp    c010350b <__alltraps>

c0102f23 <vector130>:
.globl vector130
vector130:
  pushl $0
c0102f23:	6a 00                	push   $0x0
  pushl $130
c0102f25:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102f2a:	e9 dc 05 00 00       	jmp    c010350b <__alltraps>

c0102f2f <vector131>:
.globl vector131
vector131:
  pushl $0
c0102f2f:	6a 00                	push   $0x0
  pushl $131
c0102f31:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102f36:	e9 d0 05 00 00       	jmp    c010350b <__alltraps>

c0102f3b <vector132>:
.globl vector132
vector132:
  pushl $0
c0102f3b:	6a 00                	push   $0x0
  pushl $132
c0102f3d:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102f42:	e9 c4 05 00 00       	jmp    c010350b <__alltraps>

c0102f47 <vector133>:
.globl vector133
vector133:
  pushl $0
c0102f47:	6a 00                	push   $0x0
  pushl $133
c0102f49:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102f4e:	e9 b8 05 00 00       	jmp    c010350b <__alltraps>

c0102f53 <vector134>:
.globl vector134
vector134:
  pushl $0
c0102f53:	6a 00                	push   $0x0
  pushl $134
c0102f55:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102f5a:	e9 ac 05 00 00       	jmp    c010350b <__alltraps>

c0102f5f <vector135>:
.globl vector135
vector135:
  pushl $0
c0102f5f:	6a 00                	push   $0x0
  pushl $135
c0102f61:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102f66:	e9 a0 05 00 00       	jmp    c010350b <__alltraps>

c0102f6b <vector136>:
.globl vector136
vector136:
  pushl $0
c0102f6b:	6a 00                	push   $0x0
  pushl $136
c0102f6d:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0102f72:	e9 94 05 00 00       	jmp    c010350b <__alltraps>

c0102f77 <vector137>:
.globl vector137
vector137:
  pushl $0
c0102f77:	6a 00                	push   $0x0
  pushl $137
c0102f79:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102f7e:	e9 88 05 00 00       	jmp    c010350b <__alltraps>

c0102f83 <vector138>:
.globl vector138
vector138:
  pushl $0
c0102f83:	6a 00                	push   $0x0
  pushl $138
c0102f85:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102f8a:	e9 7c 05 00 00       	jmp    c010350b <__alltraps>

c0102f8f <vector139>:
.globl vector139
vector139:
  pushl $0
c0102f8f:	6a 00                	push   $0x0
  pushl $139
c0102f91:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102f96:	e9 70 05 00 00       	jmp    c010350b <__alltraps>

c0102f9b <vector140>:
.globl vector140
vector140:
  pushl $0
c0102f9b:	6a 00                	push   $0x0
  pushl $140
c0102f9d:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0102fa2:	e9 64 05 00 00       	jmp    c010350b <__alltraps>

c0102fa7 <vector141>:
.globl vector141
vector141:
  pushl $0
c0102fa7:	6a 00                	push   $0x0
  pushl $141
c0102fa9:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102fae:	e9 58 05 00 00       	jmp    c010350b <__alltraps>

c0102fb3 <vector142>:
.globl vector142
vector142:
  pushl $0
c0102fb3:	6a 00                	push   $0x0
  pushl $142
c0102fb5:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102fba:	e9 4c 05 00 00       	jmp    c010350b <__alltraps>

c0102fbf <vector143>:
.globl vector143
vector143:
  pushl $0
c0102fbf:	6a 00                	push   $0x0
  pushl $143
c0102fc1:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0102fc6:	e9 40 05 00 00       	jmp    c010350b <__alltraps>

c0102fcb <vector144>:
.globl vector144
vector144:
  pushl $0
c0102fcb:	6a 00                	push   $0x0
  pushl $144
c0102fcd:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102fd2:	e9 34 05 00 00       	jmp    c010350b <__alltraps>

c0102fd7 <vector145>:
.globl vector145
vector145:
  pushl $0
c0102fd7:	6a 00                	push   $0x0
  pushl $145
c0102fd9:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102fde:	e9 28 05 00 00       	jmp    c010350b <__alltraps>

c0102fe3 <vector146>:
.globl vector146
vector146:
  pushl $0
c0102fe3:	6a 00                	push   $0x0
  pushl $146
c0102fe5:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102fea:	e9 1c 05 00 00       	jmp    c010350b <__alltraps>

c0102fef <vector147>:
.globl vector147
vector147:
  pushl $0
c0102fef:	6a 00                	push   $0x0
  pushl $147
c0102ff1:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0102ff6:	e9 10 05 00 00       	jmp    c010350b <__alltraps>

c0102ffb <vector148>:
.globl vector148
vector148:
  pushl $0
c0102ffb:	6a 00                	push   $0x0
  pushl $148
c0102ffd:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0103002:	e9 04 05 00 00       	jmp    c010350b <__alltraps>

c0103007 <vector149>:
.globl vector149
vector149:
  pushl $0
c0103007:	6a 00                	push   $0x0
  pushl $149
c0103009:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c010300e:	e9 f8 04 00 00       	jmp    c010350b <__alltraps>

c0103013 <vector150>:
.globl vector150
vector150:
  pushl $0
c0103013:	6a 00                	push   $0x0
  pushl $150
c0103015:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c010301a:	e9 ec 04 00 00       	jmp    c010350b <__alltraps>

c010301f <vector151>:
.globl vector151
vector151:
  pushl $0
c010301f:	6a 00                	push   $0x0
  pushl $151
c0103021:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0103026:	e9 e0 04 00 00       	jmp    c010350b <__alltraps>

c010302b <vector152>:
.globl vector152
vector152:
  pushl $0
c010302b:	6a 00                	push   $0x0
  pushl $152
c010302d:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0103032:	e9 d4 04 00 00       	jmp    c010350b <__alltraps>

c0103037 <vector153>:
.globl vector153
vector153:
  pushl $0
c0103037:	6a 00                	push   $0x0
  pushl $153
c0103039:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c010303e:	e9 c8 04 00 00       	jmp    c010350b <__alltraps>

c0103043 <vector154>:
.globl vector154
vector154:
  pushl $0
c0103043:	6a 00                	push   $0x0
  pushl $154
c0103045:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c010304a:	e9 bc 04 00 00       	jmp    c010350b <__alltraps>

c010304f <vector155>:
.globl vector155
vector155:
  pushl $0
c010304f:	6a 00                	push   $0x0
  pushl $155
c0103051:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0103056:	e9 b0 04 00 00       	jmp    c010350b <__alltraps>

c010305b <vector156>:
.globl vector156
vector156:
  pushl $0
c010305b:	6a 00                	push   $0x0
  pushl $156
c010305d:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0103062:	e9 a4 04 00 00       	jmp    c010350b <__alltraps>

c0103067 <vector157>:
.globl vector157
vector157:
  pushl $0
c0103067:	6a 00                	push   $0x0
  pushl $157
c0103069:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c010306e:	e9 98 04 00 00       	jmp    c010350b <__alltraps>

c0103073 <vector158>:
.globl vector158
vector158:
  pushl $0
c0103073:	6a 00                	push   $0x0
  pushl $158
c0103075:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c010307a:	e9 8c 04 00 00       	jmp    c010350b <__alltraps>

c010307f <vector159>:
.globl vector159
vector159:
  pushl $0
c010307f:	6a 00                	push   $0x0
  pushl $159
c0103081:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0103086:	e9 80 04 00 00       	jmp    c010350b <__alltraps>

c010308b <vector160>:
.globl vector160
vector160:
  pushl $0
c010308b:	6a 00                	push   $0x0
  pushl $160
c010308d:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0103092:	e9 74 04 00 00       	jmp    c010350b <__alltraps>

c0103097 <vector161>:
.globl vector161
vector161:
  pushl $0
c0103097:	6a 00                	push   $0x0
  pushl $161
c0103099:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c010309e:	e9 68 04 00 00       	jmp    c010350b <__alltraps>

c01030a3 <vector162>:
.globl vector162
vector162:
  pushl $0
c01030a3:	6a 00                	push   $0x0
  pushl $162
c01030a5:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c01030aa:	e9 5c 04 00 00       	jmp    c010350b <__alltraps>

c01030af <vector163>:
.globl vector163
vector163:
  pushl $0
c01030af:	6a 00                	push   $0x0
  pushl $163
c01030b1:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c01030b6:	e9 50 04 00 00       	jmp    c010350b <__alltraps>

c01030bb <vector164>:
.globl vector164
vector164:
  pushl $0
c01030bb:	6a 00                	push   $0x0
  pushl $164
c01030bd:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c01030c2:	e9 44 04 00 00       	jmp    c010350b <__alltraps>

c01030c7 <vector165>:
.globl vector165
vector165:
  pushl $0
c01030c7:	6a 00                	push   $0x0
  pushl $165
c01030c9:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c01030ce:	e9 38 04 00 00       	jmp    c010350b <__alltraps>

c01030d3 <vector166>:
.globl vector166
vector166:
  pushl $0
c01030d3:	6a 00                	push   $0x0
  pushl $166
c01030d5:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c01030da:	e9 2c 04 00 00       	jmp    c010350b <__alltraps>

c01030df <vector167>:
.globl vector167
vector167:
  pushl $0
c01030df:	6a 00                	push   $0x0
  pushl $167
c01030e1:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c01030e6:	e9 20 04 00 00       	jmp    c010350b <__alltraps>

c01030eb <vector168>:
.globl vector168
vector168:
  pushl $0
c01030eb:	6a 00                	push   $0x0
  pushl $168
c01030ed:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c01030f2:	e9 14 04 00 00       	jmp    c010350b <__alltraps>

c01030f7 <vector169>:
.globl vector169
vector169:
  pushl $0
c01030f7:	6a 00                	push   $0x0
  pushl $169
c01030f9:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c01030fe:	e9 08 04 00 00       	jmp    c010350b <__alltraps>

c0103103 <vector170>:
.globl vector170
vector170:
  pushl $0
c0103103:	6a 00                	push   $0x0
  pushl $170
c0103105:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c010310a:	e9 fc 03 00 00       	jmp    c010350b <__alltraps>

c010310f <vector171>:
.globl vector171
vector171:
  pushl $0
c010310f:	6a 00                	push   $0x0
  pushl $171
c0103111:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0103116:	e9 f0 03 00 00       	jmp    c010350b <__alltraps>

c010311b <vector172>:
.globl vector172
vector172:
  pushl $0
c010311b:	6a 00                	push   $0x0
  pushl $172
c010311d:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0103122:	e9 e4 03 00 00       	jmp    c010350b <__alltraps>

c0103127 <vector173>:
.globl vector173
vector173:
  pushl $0
c0103127:	6a 00                	push   $0x0
  pushl $173
c0103129:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c010312e:	e9 d8 03 00 00       	jmp    c010350b <__alltraps>

c0103133 <vector174>:
.globl vector174
vector174:
  pushl $0
c0103133:	6a 00                	push   $0x0
  pushl $174
c0103135:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c010313a:	e9 cc 03 00 00       	jmp    c010350b <__alltraps>

c010313f <vector175>:
.globl vector175
vector175:
  pushl $0
c010313f:	6a 00                	push   $0x0
  pushl $175
c0103141:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0103146:	e9 c0 03 00 00       	jmp    c010350b <__alltraps>

c010314b <vector176>:
.globl vector176
vector176:
  pushl $0
c010314b:	6a 00                	push   $0x0
  pushl $176
c010314d:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0103152:	e9 b4 03 00 00       	jmp    c010350b <__alltraps>

c0103157 <vector177>:
.globl vector177
vector177:
  pushl $0
c0103157:	6a 00                	push   $0x0
  pushl $177
c0103159:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c010315e:	e9 a8 03 00 00       	jmp    c010350b <__alltraps>

c0103163 <vector178>:
.globl vector178
vector178:
  pushl $0
c0103163:	6a 00                	push   $0x0
  pushl $178
c0103165:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c010316a:	e9 9c 03 00 00       	jmp    c010350b <__alltraps>

c010316f <vector179>:
.globl vector179
vector179:
  pushl $0
c010316f:	6a 00                	push   $0x0
  pushl $179
c0103171:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0103176:	e9 90 03 00 00       	jmp    c010350b <__alltraps>

c010317b <vector180>:
.globl vector180
vector180:
  pushl $0
c010317b:	6a 00                	push   $0x0
  pushl $180
c010317d:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0103182:	e9 84 03 00 00       	jmp    c010350b <__alltraps>

c0103187 <vector181>:
.globl vector181
vector181:
  pushl $0
c0103187:	6a 00                	push   $0x0
  pushl $181
c0103189:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c010318e:	e9 78 03 00 00       	jmp    c010350b <__alltraps>

c0103193 <vector182>:
.globl vector182
vector182:
  pushl $0
c0103193:	6a 00                	push   $0x0
  pushl $182
c0103195:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c010319a:	e9 6c 03 00 00       	jmp    c010350b <__alltraps>

c010319f <vector183>:
.globl vector183
vector183:
  pushl $0
c010319f:	6a 00                	push   $0x0
  pushl $183
c01031a1:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c01031a6:	e9 60 03 00 00       	jmp    c010350b <__alltraps>

c01031ab <vector184>:
.globl vector184
vector184:
  pushl $0
c01031ab:	6a 00                	push   $0x0
  pushl $184
c01031ad:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c01031b2:	e9 54 03 00 00       	jmp    c010350b <__alltraps>

c01031b7 <vector185>:
.globl vector185
vector185:
  pushl $0
c01031b7:	6a 00                	push   $0x0
  pushl $185
c01031b9:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c01031be:	e9 48 03 00 00       	jmp    c010350b <__alltraps>

c01031c3 <vector186>:
.globl vector186
vector186:
  pushl $0
c01031c3:	6a 00                	push   $0x0
  pushl $186
c01031c5:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c01031ca:	e9 3c 03 00 00       	jmp    c010350b <__alltraps>

c01031cf <vector187>:
.globl vector187
vector187:
  pushl $0
c01031cf:	6a 00                	push   $0x0
  pushl $187
c01031d1:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c01031d6:	e9 30 03 00 00       	jmp    c010350b <__alltraps>

c01031db <vector188>:
.globl vector188
vector188:
  pushl $0
c01031db:	6a 00                	push   $0x0
  pushl $188
c01031dd:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c01031e2:	e9 24 03 00 00       	jmp    c010350b <__alltraps>

c01031e7 <vector189>:
.globl vector189
vector189:
  pushl $0
c01031e7:	6a 00                	push   $0x0
  pushl $189
c01031e9:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c01031ee:	e9 18 03 00 00       	jmp    c010350b <__alltraps>

c01031f3 <vector190>:
.globl vector190
vector190:
  pushl $0
c01031f3:	6a 00                	push   $0x0
  pushl $190
c01031f5:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c01031fa:	e9 0c 03 00 00       	jmp    c010350b <__alltraps>

c01031ff <vector191>:
.globl vector191
vector191:
  pushl $0
c01031ff:	6a 00                	push   $0x0
  pushl $191
c0103201:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0103206:	e9 00 03 00 00       	jmp    c010350b <__alltraps>

c010320b <vector192>:
.globl vector192
vector192:
  pushl $0
c010320b:	6a 00                	push   $0x0
  pushl $192
c010320d:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0103212:	e9 f4 02 00 00       	jmp    c010350b <__alltraps>

c0103217 <vector193>:
.globl vector193
vector193:
  pushl $0
c0103217:	6a 00                	push   $0x0
  pushl $193
c0103219:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c010321e:	e9 e8 02 00 00       	jmp    c010350b <__alltraps>

c0103223 <vector194>:
.globl vector194
vector194:
  pushl $0
c0103223:	6a 00                	push   $0x0
  pushl $194
c0103225:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c010322a:	e9 dc 02 00 00       	jmp    c010350b <__alltraps>

c010322f <vector195>:
.globl vector195
vector195:
  pushl $0
c010322f:	6a 00                	push   $0x0
  pushl $195
c0103231:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0103236:	e9 d0 02 00 00       	jmp    c010350b <__alltraps>

c010323b <vector196>:
.globl vector196
vector196:
  pushl $0
c010323b:	6a 00                	push   $0x0
  pushl $196
c010323d:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0103242:	e9 c4 02 00 00       	jmp    c010350b <__alltraps>

c0103247 <vector197>:
.globl vector197
vector197:
  pushl $0
c0103247:	6a 00                	push   $0x0
  pushl $197
c0103249:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c010324e:	e9 b8 02 00 00       	jmp    c010350b <__alltraps>

c0103253 <vector198>:
.globl vector198
vector198:
  pushl $0
c0103253:	6a 00                	push   $0x0
  pushl $198
c0103255:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c010325a:	e9 ac 02 00 00       	jmp    c010350b <__alltraps>

c010325f <vector199>:
.globl vector199
vector199:
  pushl $0
c010325f:	6a 00                	push   $0x0
  pushl $199
c0103261:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0103266:	e9 a0 02 00 00       	jmp    c010350b <__alltraps>

c010326b <vector200>:
.globl vector200
vector200:
  pushl $0
c010326b:	6a 00                	push   $0x0
  pushl $200
c010326d:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0103272:	e9 94 02 00 00       	jmp    c010350b <__alltraps>

c0103277 <vector201>:
.globl vector201
vector201:
  pushl $0
c0103277:	6a 00                	push   $0x0
  pushl $201
c0103279:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c010327e:	e9 88 02 00 00       	jmp    c010350b <__alltraps>

c0103283 <vector202>:
.globl vector202
vector202:
  pushl $0
c0103283:	6a 00                	push   $0x0
  pushl $202
c0103285:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c010328a:	e9 7c 02 00 00       	jmp    c010350b <__alltraps>

c010328f <vector203>:
.globl vector203
vector203:
  pushl $0
c010328f:	6a 00                	push   $0x0
  pushl $203
c0103291:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0103296:	e9 70 02 00 00       	jmp    c010350b <__alltraps>

c010329b <vector204>:
.globl vector204
vector204:
  pushl $0
c010329b:	6a 00                	push   $0x0
  pushl $204
c010329d:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c01032a2:	e9 64 02 00 00       	jmp    c010350b <__alltraps>

c01032a7 <vector205>:
.globl vector205
vector205:
  pushl $0
c01032a7:	6a 00                	push   $0x0
  pushl $205
c01032a9:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c01032ae:	e9 58 02 00 00       	jmp    c010350b <__alltraps>

c01032b3 <vector206>:
.globl vector206
vector206:
  pushl $0
c01032b3:	6a 00                	push   $0x0
  pushl $206
c01032b5:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c01032ba:	e9 4c 02 00 00       	jmp    c010350b <__alltraps>

c01032bf <vector207>:
.globl vector207
vector207:
  pushl $0
c01032bf:	6a 00                	push   $0x0
  pushl $207
c01032c1:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c01032c6:	e9 40 02 00 00       	jmp    c010350b <__alltraps>

c01032cb <vector208>:
.globl vector208
vector208:
  pushl $0
c01032cb:	6a 00                	push   $0x0
  pushl $208
c01032cd:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c01032d2:	e9 34 02 00 00       	jmp    c010350b <__alltraps>

c01032d7 <vector209>:
.globl vector209
vector209:
  pushl $0
c01032d7:	6a 00                	push   $0x0
  pushl $209
c01032d9:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c01032de:	e9 28 02 00 00       	jmp    c010350b <__alltraps>

c01032e3 <vector210>:
.globl vector210
vector210:
  pushl $0
c01032e3:	6a 00                	push   $0x0
  pushl $210
c01032e5:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c01032ea:	e9 1c 02 00 00       	jmp    c010350b <__alltraps>

c01032ef <vector211>:
.globl vector211
vector211:
  pushl $0
c01032ef:	6a 00                	push   $0x0
  pushl $211
c01032f1:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c01032f6:	e9 10 02 00 00       	jmp    c010350b <__alltraps>

c01032fb <vector212>:
.globl vector212
vector212:
  pushl $0
c01032fb:	6a 00                	push   $0x0
  pushl $212
c01032fd:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0103302:	e9 04 02 00 00       	jmp    c010350b <__alltraps>

c0103307 <vector213>:
.globl vector213
vector213:
  pushl $0
c0103307:	6a 00                	push   $0x0
  pushl $213
c0103309:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c010330e:	e9 f8 01 00 00       	jmp    c010350b <__alltraps>

c0103313 <vector214>:
.globl vector214
vector214:
  pushl $0
c0103313:	6a 00                	push   $0x0
  pushl $214
c0103315:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c010331a:	e9 ec 01 00 00       	jmp    c010350b <__alltraps>

c010331f <vector215>:
.globl vector215
vector215:
  pushl $0
c010331f:	6a 00                	push   $0x0
  pushl $215
c0103321:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0103326:	e9 e0 01 00 00       	jmp    c010350b <__alltraps>

c010332b <vector216>:
.globl vector216
vector216:
  pushl $0
c010332b:	6a 00                	push   $0x0
  pushl $216
c010332d:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c0103332:	e9 d4 01 00 00       	jmp    c010350b <__alltraps>

c0103337 <vector217>:
.globl vector217
vector217:
  pushl $0
c0103337:	6a 00                	push   $0x0
  pushl $217
c0103339:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c010333e:	e9 c8 01 00 00       	jmp    c010350b <__alltraps>

c0103343 <vector218>:
.globl vector218
vector218:
  pushl $0
c0103343:	6a 00                	push   $0x0
  pushl $218
c0103345:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c010334a:	e9 bc 01 00 00       	jmp    c010350b <__alltraps>

c010334f <vector219>:
.globl vector219
vector219:
  pushl $0
c010334f:	6a 00                	push   $0x0
  pushl $219
c0103351:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0103356:	e9 b0 01 00 00       	jmp    c010350b <__alltraps>

c010335b <vector220>:
.globl vector220
vector220:
  pushl $0
c010335b:	6a 00                	push   $0x0
  pushl $220
c010335d:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0103362:	e9 a4 01 00 00       	jmp    c010350b <__alltraps>

c0103367 <vector221>:
.globl vector221
vector221:
  pushl $0
c0103367:	6a 00                	push   $0x0
  pushl $221
c0103369:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c010336e:	e9 98 01 00 00       	jmp    c010350b <__alltraps>

c0103373 <vector222>:
.globl vector222
vector222:
  pushl $0
c0103373:	6a 00                	push   $0x0
  pushl $222
c0103375:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c010337a:	e9 8c 01 00 00       	jmp    c010350b <__alltraps>

c010337f <vector223>:
.globl vector223
vector223:
  pushl $0
c010337f:	6a 00                	push   $0x0
  pushl $223
c0103381:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0103386:	e9 80 01 00 00       	jmp    c010350b <__alltraps>

c010338b <vector224>:
.globl vector224
vector224:
  pushl $0
c010338b:	6a 00                	push   $0x0
  pushl $224
c010338d:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c0103392:	e9 74 01 00 00       	jmp    c010350b <__alltraps>

c0103397 <vector225>:
.globl vector225
vector225:
  pushl $0
c0103397:	6a 00                	push   $0x0
  pushl $225
c0103399:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c010339e:	e9 68 01 00 00       	jmp    c010350b <__alltraps>

c01033a3 <vector226>:
.globl vector226
vector226:
  pushl $0
c01033a3:	6a 00                	push   $0x0
  pushl $226
c01033a5:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c01033aa:	e9 5c 01 00 00       	jmp    c010350b <__alltraps>

c01033af <vector227>:
.globl vector227
vector227:
  pushl $0
c01033af:	6a 00                	push   $0x0
  pushl $227
c01033b1:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c01033b6:	e9 50 01 00 00       	jmp    c010350b <__alltraps>

c01033bb <vector228>:
.globl vector228
vector228:
  pushl $0
c01033bb:	6a 00                	push   $0x0
  pushl $228
c01033bd:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c01033c2:	e9 44 01 00 00       	jmp    c010350b <__alltraps>

c01033c7 <vector229>:
.globl vector229
vector229:
  pushl $0
c01033c7:	6a 00                	push   $0x0
  pushl $229
c01033c9:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c01033ce:	e9 38 01 00 00       	jmp    c010350b <__alltraps>

c01033d3 <vector230>:
.globl vector230
vector230:
  pushl $0
c01033d3:	6a 00                	push   $0x0
  pushl $230
c01033d5:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c01033da:	e9 2c 01 00 00       	jmp    c010350b <__alltraps>

c01033df <vector231>:
.globl vector231
vector231:
  pushl $0
c01033df:	6a 00                	push   $0x0
  pushl $231
c01033e1:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c01033e6:	e9 20 01 00 00       	jmp    c010350b <__alltraps>

c01033eb <vector232>:
.globl vector232
vector232:
  pushl $0
c01033eb:	6a 00                	push   $0x0
  pushl $232
c01033ed:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c01033f2:	e9 14 01 00 00       	jmp    c010350b <__alltraps>

c01033f7 <vector233>:
.globl vector233
vector233:
  pushl $0
c01033f7:	6a 00                	push   $0x0
  pushl $233
c01033f9:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c01033fe:	e9 08 01 00 00       	jmp    c010350b <__alltraps>

c0103403 <vector234>:
.globl vector234
vector234:
  pushl $0
c0103403:	6a 00                	push   $0x0
  pushl $234
c0103405:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c010340a:	e9 fc 00 00 00       	jmp    c010350b <__alltraps>

c010340f <vector235>:
.globl vector235
vector235:
  pushl $0
c010340f:	6a 00                	push   $0x0
  pushl $235
c0103411:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c0103416:	e9 f0 00 00 00       	jmp    c010350b <__alltraps>

c010341b <vector236>:
.globl vector236
vector236:
  pushl $0
c010341b:	6a 00                	push   $0x0
  pushl $236
c010341d:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0103422:	e9 e4 00 00 00       	jmp    c010350b <__alltraps>

c0103427 <vector237>:
.globl vector237
vector237:
  pushl $0
c0103427:	6a 00                	push   $0x0
  pushl $237
c0103429:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c010342e:	e9 d8 00 00 00       	jmp    c010350b <__alltraps>

c0103433 <vector238>:
.globl vector238
vector238:
  pushl $0
c0103433:	6a 00                	push   $0x0
  pushl $238
c0103435:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c010343a:	e9 cc 00 00 00       	jmp    c010350b <__alltraps>

c010343f <vector239>:
.globl vector239
vector239:
  pushl $0
c010343f:	6a 00                	push   $0x0
  pushl $239
c0103441:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0103446:	e9 c0 00 00 00       	jmp    c010350b <__alltraps>

c010344b <vector240>:
.globl vector240
vector240:
  pushl $0
c010344b:	6a 00                	push   $0x0
  pushl $240
c010344d:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0103452:	e9 b4 00 00 00       	jmp    c010350b <__alltraps>

c0103457 <vector241>:
.globl vector241
vector241:
  pushl $0
c0103457:	6a 00                	push   $0x0
  pushl $241
c0103459:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c010345e:	e9 a8 00 00 00       	jmp    c010350b <__alltraps>

c0103463 <vector242>:
.globl vector242
vector242:
  pushl $0
c0103463:	6a 00                	push   $0x0
  pushl $242
c0103465:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c010346a:	e9 9c 00 00 00       	jmp    c010350b <__alltraps>

c010346f <vector243>:
.globl vector243
vector243:
  pushl $0
c010346f:	6a 00                	push   $0x0
  pushl $243
c0103471:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0103476:	e9 90 00 00 00       	jmp    c010350b <__alltraps>

c010347b <vector244>:
.globl vector244
vector244:
  pushl $0
c010347b:	6a 00                	push   $0x0
  pushl $244
c010347d:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c0103482:	e9 84 00 00 00       	jmp    c010350b <__alltraps>

c0103487 <vector245>:
.globl vector245
vector245:
  pushl $0
c0103487:	6a 00                	push   $0x0
  pushl $245
c0103489:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c010348e:	e9 78 00 00 00       	jmp    c010350b <__alltraps>

c0103493 <vector246>:
.globl vector246
vector246:
  pushl $0
c0103493:	6a 00                	push   $0x0
  pushl $246
c0103495:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c010349a:	e9 6c 00 00 00       	jmp    c010350b <__alltraps>

c010349f <vector247>:
.globl vector247
vector247:
  pushl $0
c010349f:	6a 00                	push   $0x0
  pushl $247
c01034a1:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c01034a6:	e9 60 00 00 00       	jmp    c010350b <__alltraps>

c01034ab <vector248>:
.globl vector248
vector248:
  pushl $0
c01034ab:	6a 00                	push   $0x0
  pushl $248
c01034ad:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c01034b2:	e9 54 00 00 00       	jmp    c010350b <__alltraps>

c01034b7 <vector249>:
.globl vector249
vector249:
  pushl $0
c01034b7:	6a 00                	push   $0x0
  pushl $249
c01034b9:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c01034be:	e9 48 00 00 00       	jmp    c010350b <__alltraps>

c01034c3 <vector250>:
.globl vector250
vector250:
  pushl $0
c01034c3:	6a 00                	push   $0x0
  pushl $250
c01034c5:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c01034ca:	e9 3c 00 00 00       	jmp    c010350b <__alltraps>

c01034cf <vector251>:
.globl vector251
vector251:
  pushl $0
c01034cf:	6a 00                	push   $0x0
  pushl $251
c01034d1:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c01034d6:	e9 30 00 00 00       	jmp    c010350b <__alltraps>

c01034db <vector252>:
.globl vector252
vector252:
  pushl $0
c01034db:	6a 00                	push   $0x0
  pushl $252
c01034dd:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c01034e2:	e9 24 00 00 00       	jmp    c010350b <__alltraps>

c01034e7 <vector253>:
.globl vector253
vector253:
  pushl $0
c01034e7:	6a 00                	push   $0x0
  pushl $253
c01034e9:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c01034ee:	e9 18 00 00 00       	jmp    c010350b <__alltraps>

c01034f3 <vector254>:
.globl vector254
vector254:
  pushl $0
c01034f3:	6a 00                	push   $0x0
  pushl $254
c01034f5:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c01034fa:	e9 0c 00 00 00       	jmp    c010350b <__alltraps>

c01034ff <vector255>:
.globl vector255
vector255:
  pushl $0
c01034ff:	6a 00                	push   $0x0
  pushl $255
c0103501:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c0103506:	e9 00 00 00 00       	jmp    c010350b <__alltraps>

c010350b <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c010350b:	1e                   	push   %ds
    pushl %es
c010350c:	06                   	push   %es
    pushl %fs
c010350d:	0f a0                	push   %fs
    pushl %gs
c010350f:	0f a8                	push   %gs
    pushal
c0103511:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0103512:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0103517:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0103519:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c010351b:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c010351c:	e8 ee f4 ff ff       	call   c0102a0f <trap>

    # pop the pushed stack pointer
    popl %esp
c0103521:	5c                   	pop    %esp

c0103522 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0103522:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0103523:	0f a9                	pop    %gs
    popl %fs
c0103525:	0f a1                	pop    %fs
    popl %es
c0103527:	07                   	pop    %es
    popl %ds
c0103528:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0103529:	83 c4 08             	add    $0x8,%esp
    iret
c010352c:	cf                   	iret   

c010352d <forkrets>:

.globl forkrets
forkrets:
    # set stack to this new process's trapframe
    movl 4(%esp), %esp
c010352d:	8b 64 24 04          	mov    0x4(%esp),%esp
    jmp __trapret
c0103531:	eb ef                	jmp    c0103522 <__trapret>

c0103533 <lock_init>:
#define local_intr_restore(x)   __intr_restore(x);

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
c0103533:	55                   	push   %ebp
c0103534:	89 e5                	mov    %esp,%ebp
    *lock = 0;
c0103536:	8b 45 08             	mov    0x8(%ebp),%eax
c0103539:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
c010353f:	5d                   	pop    %ebp
c0103540:	c3                   	ret    

c0103541 <mm_count>:
bool user_mem_check(struct mm_struct *mm, uintptr_t start, size_t len, bool write);
bool copy_from_user(struct mm_struct *mm, void *dst, const void *src, size_t len, bool writable);
bool copy_to_user(struct mm_struct *mm, void *dst, const void *src, size_t len);

static inline int
mm_count(struct mm_struct *mm) {
c0103541:	55                   	push   %ebp
c0103542:	89 e5                	mov    %esp,%ebp
    return mm->mm_count;
c0103544:	8b 45 08             	mov    0x8(%ebp),%eax
c0103547:	8b 40 18             	mov    0x18(%eax),%eax
}
c010354a:	5d                   	pop    %ebp
c010354b:	c3                   	ret    

c010354c <set_mm_count>:

static inline void
set_mm_count(struct mm_struct *mm, int val) {
c010354c:	55                   	push   %ebp
c010354d:	89 e5                	mov    %esp,%ebp
    mm->mm_count = val;
c010354f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103552:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103555:	89 50 18             	mov    %edx,0x18(%eax)
}
c0103558:	5d                   	pop    %ebp
c0103559:	c3                   	ret    

c010355a <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c010355a:	55                   	push   %ebp
c010355b:	89 e5                	mov    %esp,%ebp
c010355d:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0103560:	8b 45 08             	mov    0x8(%ebp),%eax
c0103563:	c1 e8 0c             	shr    $0xc,%eax
c0103566:	89 c2                	mov    %eax,%edx
c0103568:	a1 80 0f 1b c0       	mov    0xc01b0f80,%eax
c010356d:	39 c2                	cmp    %eax,%edx
c010356f:	72 1c                	jb     c010358d <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0103571:	c7 44 24 08 d0 cc 10 	movl   $0xc010ccd0,0x8(%esp)
c0103578:	c0 
c0103579:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0103580:	00 
c0103581:	c7 04 24 ef cc 10 c0 	movl   $0xc010ccef,(%esp)
c0103588:	e8 78 ce ff ff       	call   c0100405 <__panic>
    }
    return &pages[PPN(pa)];
c010358d:	a1 78 31 1b c0       	mov    0xc01b3178,%eax
c0103592:	8b 55 08             	mov    0x8(%ebp),%edx
c0103595:	c1 ea 0c             	shr    $0xc,%edx
c0103598:	c1 e2 05             	shl    $0x5,%edx
c010359b:	01 d0                	add    %edx,%eax
}
c010359d:	c9                   	leave  
c010359e:	c3                   	ret    

c010359f <pde2page>:
    }
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *
pde2page(pde_t pde) {
c010359f:	55                   	push   %ebp
c01035a0:	89 e5                	mov    %esp,%ebp
c01035a2:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c01035a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01035a8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01035ad:	89 04 24             	mov    %eax,(%esp)
c01035b0:	e8 a5 ff ff ff       	call   c010355a <pa2page>
}
c01035b5:	c9                   	leave  
c01035b6:	c3                   	ret    

c01035b7 <mm_create>:
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void) {
c01035b7:	55                   	push   %ebp
c01035b8:	89 e5                	mov    %esp,%ebp
c01035ba:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
c01035bd:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01035c4:	e8 0b 1d 00 00       	call   c01052d4 <kmalloc>
c01035c9:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (mm != NULL) {
c01035cc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01035d0:	74 79                	je     c010364b <mm_create+0x94>
        list_init(&(mm->mmap_list));
c01035d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01035d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01035db:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01035de:	89 50 04             	mov    %edx,0x4(%eax)
c01035e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01035e4:	8b 50 04             	mov    0x4(%eax),%edx
c01035e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01035ea:	89 10                	mov    %edx,(%eax)
        mm->mmap_cache = NULL;
c01035ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035ef:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        mm->pgdir = NULL;
c01035f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035f9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        mm->map_count = 0;
c0103600:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103603:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

        if (swap_init_ok) swap_init_mm(mm);
c010360a:	a1 6c 0f 1b c0       	mov    0xc01b0f6c,%eax
c010360f:	85 c0                	test   %eax,%eax
c0103611:	74 0d                	je     c0103620 <mm_create+0x69>
c0103613:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103616:	89 04 24             	mov    %eax,(%esp)
c0103619:	e8 38 1f 00 00       	call   c0105556 <swap_init_mm>
c010361e:	eb 0a                	jmp    c010362a <mm_create+0x73>
        else mm->sm_priv = NULL;
c0103620:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103623:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        
        set_mm_count(mm, 0);
c010362a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103631:	00 
c0103632:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103635:	89 04 24             	mov    %eax,(%esp)
c0103638:	e8 0f ff ff ff       	call   c010354c <set_mm_count>
        lock_init(&(mm->mm_lock));
c010363d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103640:	83 c0 1c             	add    $0x1c,%eax
c0103643:	89 04 24             	mov    %eax,(%esp)
c0103646:	e8 e8 fe ff ff       	call   c0103533 <lock_init>
    }    
    return mm;
c010364b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010364e:	c9                   	leave  
c010364f:	c3                   	ret    

c0103650 <vma_create>:

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
c0103650:	55                   	push   %ebp
c0103651:	89 e5                	mov    %esp,%ebp
c0103653:	83 ec 28             	sub    $0x28,%esp
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
c0103656:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c010365d:	e8 72 1c 00 00       	call   c01052d4 <kmalloc>
c0103662:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (vma != NULL) {
c0103665:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103669:	74 1b                	je     c0103686 <vma_create+0x36>
        vma->vm_start = vm_start;
c010366b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010366e:	8b 55 08             	mov    0x8(%ebp),%edx
c0103671:	89 50 04             	mov    %edx,0x4(%eax)
        vma->vm_end = vm_end;
c0103674:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103677:	8b 55 0c             	mov    0xc(%ebp),%edx
c010367a:	89 50 08             	mov    %edx,0x8(%eax)
        vma->vm_flags = vm_flags;
c010367d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103680:	8b 55 10             	mov    0x10(%ebp),%edx
c0103683:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    return vma;
c0103686:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103689:	c9                   	leave  
c010368a:	c3                   	ret    

c010368b <find_vma>:


// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
c010368b:	55                   	push   %ebp
c010368c:	89 e5                	mov    %esp,%ebp
c010368e:	83 ec 20             	sub    $0x20,%esp
    struct vma_struct *vma = NULL;
c0103691:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    if (mm != NULL) {
c0103698:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010369c:	0f 84 95 00 00 00    	je     c0103737 <find_vma+0xac>
        vma = mm->mmap_cache;
c01036a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01036a5:	8b 40 08             	mov    0x8(%eax),%eax
c01036a8:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
c01036ab:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01036af:	74 16                	je     c01036c7 <find_vma+0x3c>
c01036b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01036b4:	8b 40 04             	mov    0x4(%eax),%eax
c01036b7:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01036ba:	77 0b                	ja     c01036c7 <find_vma+0x3c>
c01036bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01036bf:	8b 40 08             	mov    0x8(%eax),%eax
c01036c2:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01036c5:	77 61                	ja     c0103728 <find_vma+0x9d>
                bool found = 0;
c01036c7:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
                list_entry_t *list = &(mm->mmap_list), *le = list;
c01036ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01036d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01036d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01036d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
                while ((le = list_next(le)) != list) {
c01036da:	eb 28                	jmp    c0103704 <find_vma+0x79>
                    vma = le2vma(le, list_link);
c01036dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036df:	83 e8 10             	sub    $0x10,%eax
c01036e2:	89 45 fc             	mov    %eax,-0x4(%ebp)
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
c01036e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01036e8:	8b 40 04             	mov    0x4(%eax),%eax
c01036eb:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01036ee:	77 14                	ja     c0103704 <find_vma+0x79>
c01036f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01036f3:	8b 40 08             	mov    0x8(%eax),%eax
c01036f6:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01036f9:	76 09                	jbe    c0103704 <find_vma+0x79>
                        found = 1;
c01036fb:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
                        break;
c0103702:	eb 17                	jmp    c010371b <find_vma+0x90>
c0103704:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103707:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010370a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010370d:	8b 40 04             	mov    0x4(%eax),%eax
                while ((le = list_next(le)) != list) {
c0103710:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103713:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103716:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103719:	75 c1                	jne    c01036dc <find_vma+0x51>
                    }
                }
                if (!found) {
c010371b:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c010371f:	75 07                	jne    c0103728 <find_vma+0x9d>
                    vma = NULL;
c0103721:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
                }
        }
        if (vma != NULL) {
c0103728:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010372c:	74 09                	je     c0103737 <find_vma+0xac>
            mm->mmap_cache = vma;
c010372e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103731:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0103734:	89 50 08             	mov    %edx,0x8(%eax)
        }
    }
    return vma;
c0103737:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010373a:	c9                   	leave  
c010373b:	c3                   	ret    

c010373c <check_vma_overlap>:


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
c010373c:	55                   	push   %ebp
c010373d:	89 e5                	mov    %esp,%ebp
c010373f:	83 ec 18             	sub    $0x18,%esp
    assert(prev->vm_start < prev->vm_end);
c0103742:	8b 45 08             	mov    0x8(%ebp),%eax
c0103745:	8b 50 04             	mov    0x4(%eax),%edx
c0103748:	8b 45 08             	mov    0x8(%ebp),%eax
c010374b:	8b 40 08             	mov    0x8(%eax),%eax
c010374e:	39 c2                	cmp    %eax,%edx
c0103750:	72 24                	jb     c0103776 <check_vma_overlap+0x3a>
c0103752:	c7 44 24 0c fd cc 10 	movl   $0xc010ccfd,0xc(%esp)
c0103759:	c0 
c010375a:	c7 44 24 08 1b cd 10 	movl   $0xc010cd1b,0x8(%esp)
c0103761:	c0 
c0103762:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
c0103769:	00 
c010376a:	c7 04 24 30 cd 10 c0 	movl   $0xc010cd30,(%esp)
c0103771:	e8 8f cc ff ff       	call   c0100405 <__panic>
    assert(prev->vm_end <= next->vm_start);
c0103776:	8b 45 08             	mov    0x8(%ebp),%eax
c0103779:	8b 50 08             	mov    0x8(%eax),%edx
c010377c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010377f:	8b 40 04             	mov    0x4(%eax),%eax
c0103782:	39 c2                	cmp    %eax,%edx
c0103784:	76 24                	jbe    c01037aa <check_vma_overlap+0x6e>
c0103786:	c7 44 24 0c 40 cd 10 	movl   $0xc010cd40,0xc(%esp)
c010378d:	c0 
c010378e:	c7 44 24 08 1b cd 10 	movl   $0xc010cd1b,0x8(%esp)
c0103795:	c0 
c0103796:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c010379d:	00 
c010379e:	c7 04 24 30 cd 10 c0 	movl   $0xc010cd30,(%esp)
c01037a5:	e8 5b cc ff ff       	call   c0100405 <__panic>
    assert(next->vm_start < next->vm_end);
c01037aa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01037ad:	8b 50 04             	mov    0x4(%eax),%edx
c01037b0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01037b3:	8b 40 08             	mov    0x8(%eax),%eax
c01037b6:	39 c2                	cmp    %eax,%edx
c01037b8:	72 24                	jb     c01037de <check_vma_overlap+0xa2>
c01037ba:	c7 44 24 0c 5f cd 10 	movl   $0xc010cd5f,0xc(%esp)
c01037c1:	c0 
c01037c2:	c7 44 24 08 1b cd 10 	movl   $0xc010cd1b,0x8(%esp)
c01037c9:	c0 
c01037ca:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c01037d1:	00 
c01037d2:	c7 04 24 30 cd 10 c0 	movl   $0xc010cd30,(%esp)
c01037d9:	e8 27 cc ff ff       	call   c0100405 <__panic>
}
c01037de:	c9                   	leave  
c01037df:	c3                   	ret    

c01037e0 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
c01037e0:	55                   	push   %ebp
c01037e1:	89 e5                	mov    %esp,%ebp
c01037e3:	83 ec 48             	sub    $0x48,%esp
    assert(vma->vm_start < vma->vm_end);
c01037e6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01037e9:	8b 50 04             	mov    0x4(%eax),%edx
c01037ec:	8b 45 0c             	mov    0xc(%ebp),%eax
c01037ef:	8b 40 08             	mov    0x8(%eax),%eax
c01037f2:	39 c2                	cmp    %eax,%edx
c01037f4:	72 24                	jb     c010381a <insert_vma_struct+0x3a>
c01037f6:	c7 44 24 0c 7d cd 10 	movl   $0xc010cd7d,0xc(%esp)
c01037fd:	c0 
c01037fe:	c7 44 24 08 1b cd 10 	movl   $0xc010cd1b,0x8(%esp)
c0103805:	c0 
c0103806:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
c010380d:	00 
c010380e:	c7 04 24 30 cd 10 c0 	movl   $0xc010cd30,(%esp)
c0103815:	e8 eb cb ff ff       	call   c0100405 <__panic>
    list_entry_t *list = &(mm->mmap_list);
c010381a:	8b 45 08             	mov    0x8(%ebp),%eax
c010381d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_entry_t *le_prev = list, *le_next;
c0103820:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103823:	89 45 f4             	mov    %eax,-0xc(%ebp)

        list_entry_t *le = list;
c0103826:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103829:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while ((le = list_next(le)) != list) {
c010382c:	eb 21                	jmp    c010384f <insert_vma_struct+0x6f>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
c010382e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103831:	83 e8 10             	sub    $0x10,%eax
c0103834:	89 45 e8             	mov    %eax,-0x18(%ebp)
            if (mmap_prev->vm_start > vma->vm_start) {
c0103837:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010383a:	8b 50 04             	mov    0x4(%eax),%edx
c010383d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103840:	8b 40 04             	mov    0x4(%eax),%eax
c0103843:	39 c2                	cmp    %eax,%edx
c0103845:	76 02                	jbe    c0103849 <insert_vma_struct+0x69>
                break;
c0103847:	eb 1d                	jmp    c0103866 <insert_vma_struct+0x86>
            }
            le_prev = le;
c0103849:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010384c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010384f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103852:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103855:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103858:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list) {
c010385b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010385e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103861:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103864:	75 c8                	jne    c010382e <insert_vma_struct+0x4e>
c0103866:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103869:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010386c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010386f:	8b 40 04             	mov    0x4(%eax),%eax
        }

    le_next = list_next(le_prev);
c0103872:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    /* check overlap */
    if (le_prev != list) {
c0103875:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103878:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010387b:	74 15                	je     c0103892 <insert_vma_struct+0xb2>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
c010387d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103880:	8d 50 f0             	lea    -0x10(%eax),%edx
c0103883:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103886:	89 44 24 04          	mov    %eax,0x4(%esp)
c010388a:	89 14 24             	mov    %edx,(%esp)
c010388d:	e8 aa fe ff ff       	call   c010373c <check_vma_overlap>
    }
    if (le_next != list) {
c0103892:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103895:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103898:	74 15                	je     c01038af <insert_vma_struct+0xcf>
        check_vma_overlap(vma, le2vma(le_next, list_link));
c010389a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010389d:	83 e8 10             	sub    $0x10,%eax
c01038a0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01038a4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01038a7:	89 04 24             	mov    %eax,(%esp)
c01038aa:	e8 8d fe ff ff       	call   c010373c <check_vma_overlap>
    }

    vma->vm_mm = mm;
c01038af:	8b 45 0c             	mov    0xc(%ebp),%eax
c01038b2:	8b 55 08             	mov    0x8(%ebp),%edx
c01038b5:	89 10                	mov    %edx,(%eax)
    list_add_after(le_prev, &(vma->list_link));
c01038b7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01038ba:	8d 50 10             	lea    0x10(%eax),%edx
c01038bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01038c3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
c01038c6:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01038c9:	8b 40 04             	mov    0x4(%eax),%eax
c01038cc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01038cf:	89 55 d0             	mov    %edx,-0x30(%ebp)
c01038d2:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01038d5:	89 55 cc             	mov    %edx,-0x34(%ebp)
c01038d8:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01038db:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01038de:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01038e1:	89 10                	mov    %edx,(%eax)
c01038e3:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01038e6:	8b 10                	mov    (%eax),%edx
c01038e8:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01038eb:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01038ee:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01038f1:	8b 55 c8             	mov    -0x38(%ebp),%edx
c01038f4:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01038f7:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01038fa:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01038fd:	89 10                	mov    %edx,(%eax)

    mm->map_count ++;
c01038ff:	8b 45 08             	mov    0x8(%ebp),%eax
c0103902:	8b 40 10             	mov    0x10(%eax),%eax
c0103905:	8d 50 01             	lea    0x1(%eax),%edx
c0103908:	8b 45 08             	mov    0x8(%ebp),%eax
c010390b:	89 50 10             	mov    %edx,0x10(%eax)
}
c010390e:	c9                   	leave  
c010390f:	c3                   	ret    

c0103910 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
c0103910:	55                   	push   %ebp
c0103911:	89 e5                	mov    %esp,%ebp
c0103913:	83 ec 38             	sub    $0x38,%esp
    assert(mm_count(mm) == 0);
c0103916:	8b 45 08             	mov    0x8(%ebp),%eax
c0103919:	89 04 24             	mov    %eax,(%esp)
c010391c:	e8 20 fc ff ff       	call   c0103541 <mm_count>
c0103921:	85 c0                	test   %eax,%eax
c0103923:	74 24                	je     c0103949 <mm_destroy+0x39>
c0103925:	c7 44 24 0c 99 cd 10 	movl   $0xc010cd99,0xc(%esp)
c010392c:	c0 
c010392d:	c7 44 24 08 1b cd 10 	movl   $0xc010cd1b,0x8(%esp)
c0103934:	c0 
c0103935:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c010393c:	00 
c010393d:	c7 04 24 30 cd 10 c0 	movl   $0xc010cd30,(%esp)
c0103944:	e8 bc ca ff ff       	call   c0100405 <__panic>

    list_entry_t *list = &(mm->mmap_list), *le;
c0103949:	8b 45 08             	mov    0x8(%ebp),%eax
c010394c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(list)) != list) {
c010394f:	eb 36                	jmp    c0103987 <mm_destroy+0x77>
c0103951:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103954:	89 45 ec             	mov    %eax,-0x14(%ebp)
    __list_del(listelm->prev, listelm->next);
c0103957:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010395a:	8b 40 04             	mov    0x4(%eax),%eax
c010395d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0103960:	8b 12                	mov    (%edx),%edx
c0103962:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0103965:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0103968:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010396b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010396e:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103971:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103974:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0103977:	89 10                	mov    %edx,(%eax)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
c0103979:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010397c:	83 e8 10             	sub    $0x10,%eax
c010397f:	89 04 24             	mov    %eax,(%esp)
c0103982:	e8 68 19 00 00       	call   c01052ef <kfree>
c0103987:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010398a:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
c010398d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103990:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(list)) != list) {
c0103993:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103996:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103999:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010399c:	75 b3                	jne    c0103951 <mm_destroy+0x41>
    }
    kfree(mm); //kfree mm
c010399e:	8b 45 08             	mov    0x8(%ebp),%eax
c01039a1:	89 04 24             	mov    %eax,(%esp)
c01039a4:	e8 46 19 00 00       	call   c01052ef <kfree>
    mm=NULL;
c01039a9:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
}
c01039b0:	c9                   	leave  
c01039b1:	c3                   	ret    

c01039b2 <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
c01039b2:	55                   	push   %ebp
c01039b3:	89 e5                	mov    %esp,%ebp
c01039b5:	83 ec 38             	sub    $0x38,%esp
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
c01039b8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01039bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01039be:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01039c1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01039c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01039c9:	c7 45 e8 00 10 00 00 	movl   $0x1000,-0x18(%ebp)
c01039d0:	8b 45 10             	mov    0x10(%ebp),%eax
c01039d3:	8b 55 0c             	mov    0xc(%ebp),%edx
c01039d6:	01 c2                	add    %eax,%edx
c01039d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01039db:	01 d0                	add    %edx,%eax
c01039dd:	83 e8 01             	sub    $0x1,%eax
c01039e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01039e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01039e6:	ba 00 00 00 00       	mov    $0x0,%edx
c01039eb:	f7 75 e8             	divl   -0x18(%ebp)
c01039ee:	89 d0                	mov    %edx,%eax
c01039f0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01039f3:	29 c2                	sub    %eax,%edx
c01039f5:	89 d0                	mov    %edx,%eax
c01039f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if (!USER_ACCESS(start, end)) {
c01039fa:	81 7d ec ff ff 1f 00 	cmpl   $0x1fffff,-0x14(%ebp)
c0103a01:	76 11                	jbe    c0103a14 <mm_map+0x62>
c0103a03:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103a06:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0103a09:	73 09                	jae    c0103a14 <mm_map+0x62>
c0103a0b:	81 7d e0 00 00 00 b0 	cmpl   $0xb0000000,-0x20(%ebp)
c0103a12:	76 0a                	jbe    c0103a1e <mm_map+0x6c>
        return -E_INVAL;
c0103a14:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0103a19:	e9 ae 00 00 00       	jmp    c0103acc <mm_map+0x11a>
    }

    assert(mm != NULL);
c0103a1e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0103a22:	75 24                	jne    c0103a48 <mm_map+0x96>
c0103a24:	c7 44 24 0c ab cd 10 	movl   $0xc010cdab,0xc(%esp)
c0103a2b:	c0 
c0103a2c:	c7 44 24 08 1b cd 10 	movl   $0xc010cd1b,0x8(%esp)
c0103a33:	c0 
c0103a34:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
c0103a3b:	00 
c0103a3c:	c7 04 24 30 cd 10 c0 	movl   $0xc010cd30,(%esp)
c0103a43:	e8 bd c9 ff ff       	call   c0100405 <__panic>

    int ret = -E_INVAL;
c0103a48:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
c0103a4f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103a52:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103a56:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a59:	89 04 24             	mov    %eax,(%esp)
c0103a5c:	e8 2a fc ff ff       	call   c010368b <find_vma>
c0103a61:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103a64:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0103a68:	74 0d                	je     c0103a77 <mm_map+0xc5>
c0103a6a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103a6d:	8b 40 04             	mov    0x4(%eax),%eax
c0103a70:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0103a73:	73 02                	jae    c0103a77 <mm_map+0xc5>
        goto out;
c0103a75:	eb 52                	jmp    c0103ac9 <mm_map+0x117>
    }
    ret = -E_NO_MEM;
c0103a77:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
c0103a7e:	8b 45 14             	mov    0x14(%ebp),%eax
c0103a81:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103a85:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103a88:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103a8c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103a8f:	89 04 24             	mov    %eax,(%esp)
c0103a92:	e8 b9 fb ff ff       	call   c0103650 <vma_create>
c0103a97:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103a9a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0103a9e:	75 02                	jne    c0103aa2 <mm_map+0xf0>
        goto out;
c0103aa0:	eb 27                	jmp    c0103ac9 <mm_map+0x117>
    }
    insert_vma_struct(mm, vma);
c0103aa2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103aa5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103aa9:	8b 45 08             	mov    0x8(%ebp),%eax
c0103aac:	89 04 24             	mov    %eax,(%esp)
c0103aaf:	e8 2c fd ff ff       	call   c01037e0 <insert_vma_struct>
    if (vma_store != NULL) {
c0103ab4:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0103ab8:	74 08                	je     c0103ac2 <mm_map+0x110>
        *vma_store = vma;
c0103aba:	8b 45 18             	mov    0x18(%ebp),%eax
c0103abd:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103ac0:	89 10                	mov    %edx,(%eax)
    }
    ret = 0;
c0103ac2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

out:
    return ret;
c0103ac9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103acc:	c9                   	leave  
c0103acd:	c3                   	ret    

c0103ace <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
c0103ace:	55                   	push   %ebp
c0103acf:	89 e5                	mov    %esp,%ebp
c0103ad1:	56                   	push   %esi
c0103ad2:	53                   	push   %ebx
c0103ad3:	83 ec 40             	sub    $0x40,%esp
    assert(to != NULL && from != NULL);
c0103ad6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0103ada:	74 06                	je     c0103ae2 <dup_mmap+0x14>
c0103adc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0103ae0:	75 24                	jne    c0103b06 <dup_mmap+0x38>
c0103ae2:	c7 44 24 0c b6 cd 10 	movl   $0xc010cdb6,0xc(%esp)
c0103ae9:	c0 
c0103aea:	c7 44 24 08 1b cd 10 	movl   $0xc010cd1b,0x8(%esp)
c0103af1:	c0 
c0103af2:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
c0103af9:	00 
c0103afa:	c7 04 24 30 cd 10 c0 	movl   $0xc010cd30,(%esp)
c0103b01:	e8 ff c8 ff ff       	call   c0100405 <__panic>
    list_entry_t *list = &(from->mmap_list), *le = list;
c0103b06:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103b09:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103b0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103b0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_prev(le)) != list) {
c0103b12:	e9 92 00 00 00       	jmp    c0103ba9 <dup_mmap+0xdb>
        struct vma_struct *vma, *nvma;
        vma = le2vma(le, list_link);
c0103b17:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b1a:	83 e8 10             	sub    $0x10,%eax
c0103b1d:	89 45 ec             	mov    %eax,-0x14(%ebp)
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
c0103b20:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103b23:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103b26:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103b29:	8b 50 08             	mov    0x8(%eax),%edx
c0103b2c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103b2f:	8b 40 04             	mov    0x4(%eax),%eax
c0103b32:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0103b36:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103b3a:	89 04 24             	mov    %eax,(%esp)
c0103b3d:	e8 0e fb ff ff       	call   c0103650 <vma_create>
c0103b42:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (nvma == NULL) {
c0103b45:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103b49:	75 07                	jne    c0103b52 <dup_mmap+0x84>
            return -E_NO_MEM;
c0103b4b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0103b50:	eb 76                	jmp    c0103bc8 <dup_mmap+0xfa>
        }

        insert_vma_struct(to, nvma);
c0103b52:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103b55:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103b59:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b5c:	89 04 24             	mov    %eax,(%esp)
c0103b5f:	e8 7c fc ff ff       	call   c01037e0 <insert_vma_struct>

        bool share = 0;
c0103b64:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
c0103b6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103b6e:	8b 58 08             	mov    0x8(%eax),%ebx
c0103b71:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103b74:	8b 48 04             	mov    0x4(%eax),%ecx
c0103b77:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103b7a:	8b 50 0c             	mov    0xc(%eax),%edx
c0103b7d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b80:	8b 40 0c             	mov    0xc(%eax),%eax
c0103b83:	8b 75 e4             	mov    -0x1c(%ebp),%esi
c0103b86:	89 74 24 10          	mov    %esi,0x10(%esp)
c0103b8a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0103b8e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0103b92:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103b96:	89 04 24             	mov    %eax,(%esp)
c0103b99:	e8 f2 43 00 00       	call   c0107f90 <copy_range>
c0103b9e:	85 c0                	test   %eax,%eax
c0103ba0:	74 07                	je     c0103ba9 <dup_mmap+0xdb>
            return -E_NO_MEM;
c0103ba2:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0103ba7:	eb 1f                	jmp    c0103bc8 <dup_mmap+0xfa>
c0103ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103bac:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->prev;
c0103baf:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103bb2:	8b 00                	mov    (%eax),%eax
    while ((le = list_prev(le)) != list) {
c0103bb4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103bb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103bba:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103bbd:	0f 85 54 ff ff ff    	jne    c0103b17 <dup_mmap+0x49>
        }
    }
    return 0;
c0103bc3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103bc8:	83 c4 40             	add    $0x40,%esp
c0103bcb:	5b                   	pop    %ebx
c0103bcc:	5e                   	pop    %esi
c0103bcd:	5d                   	pop    %ebp
c0103bce:	c3                   	ret    

c0103bcf <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
c0103bcf:	55                   	push   %ebp
c0103bd0:	89 e5                	mov    %esp,%ebp
c0103bd2:	83 ec 38             	sub    $0x38,%esp
    assert(mm != NULL && mm_count(mm) == 0);
c0103bd5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0103bd9:	74 0f                	je     c0103bea <exit_mmap+0x1b>
c0103bdb:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bde:	89 04 24             	mov    %eax,(%esp)
c0103be1:	e8 5b f9 ff ff       	call   c0103541 <mm_count>
c0103be6:	85 c0                	test   %eax,%eax
c0103be8:	74 24                	je     c0103c0e <exit_mmap+0x3f>
c0103bea:	c7 44 24 0c d4 cd 10 	movl   $0xc010cdd4,0xc(%esp)
c0103bf1:	c0 
c0103bf2:	c7 44 24 08 1b cd 10 	movl   $0xc010cd1b,0x8(%esp)
c0103bf9:	c0 
c0103bfa:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c0103c01:	00 
c0103c02:	c7 04 24 30 cd 10 c0 	movl   $0xc010cd30,(%esp)
c0103c09:	e8 f7 c7 ff ff       	call   c0100405 <__panic>
    pde_t *pgdir = mm->pgdir;
c0103c0e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c11:	8b 40 0c             	mov    0xc(%eax),%eax
c0103c14:	89 45 f0             	mov    %eax,-0x10(%ebp)
    list_entry_t *list = &(mm->mmap_list), *le = list;
c0103c17:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c1a:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103c1d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103c20:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(le)) != list) {
c0103c23:	eb 28                	jmp    c0103c4d <exit_mmap+0x7e>
        struct vma_struct *vma = le2vma(le, list_link);
c0103c25:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c28:	83 e8 10             	sub    $0x10,%eax
c0103c2b:	89 45 e8             	mov    %eax,-0x18(%ebp)
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
c0103c2e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103c31:	8b 50 08             	mov    0x8(%eax),%edx
c0103c34:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103c37:	8b 40 04             	mov    0x4(%eax),%eax
c0103c3a:	89 54 24 08          	mov    %edx,0x8(%esp)
c0103c3e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103c42:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c45:	89 04 24             	mov    %eax,(%esp)
c0103c48:	e8 48 41 00 00       	call   c0107d95 <unmap_range>
c0103c4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c50:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
c0103c53:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103c56:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != list) {
c0103c59:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103c5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c5f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103c62:	75 c1                	jne    c0103c25 <exit_mmap+0x56>
    }
    while ((le = list_next(le)) != list) {
c0103c64:	eb 28                	jmp    c0103c8e <exit_mmap+0xbf>
        struct vma_struct *vma = le2vma(le, list_link);
c0103c66:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c69:	83 e8 10             	sub    $0x10,%eax
c0103c6c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        exit_range(pgdir, vma->vm_start, vma->vm_end);
c0103c6f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103c72:	8b 50 08             	mov    0x8(%eax),%edx
c0103c75:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103c78:	8b 40 04             	mov    0x4(%eax),%eax
c0103c7b:	89 54 24 08          	mov    %edx,0x8(%esp)
c0103c7f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103c83:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c86:	89 04 24             	mov    %eax,(%esp)
c0103c89:	e8 fb 41 00 00       	call   c0107e89 <exit_range>
c0103c8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c91:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103c94:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103c97:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != list) {
c0103c9a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103c9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ca0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103ca3:	75 c1                	jne    c0103c66 <exit_mmap+0x97>
    }
}
c0103ca5:	c9                   	leave  
c0103ca6:	c3                   	ret    

c0103ca7 <copy_from_user>:

bool
copy_from_user(struct mm_struct *mm, void *dst, const void *src, size_t len, bool writable) {
c0103ca7:	55                   	push   %ebp
c0103ca8:	89 e5                	mov    %esp,%ebp
c0103caa:	83 ec 18             	sub    $0x18,%esp
    if (!user_mem_check(mm, (uintptr_t)src, len, writable)) {
c0103cad:	8b 45 10             	mov    0x10(%ebp),%eax
c0103cb0:	8b 55 18             	mov    0x18(%ebp),%edx
c0103cb3:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0103cb7:	8b 55 14             	mov    0x14(%ebp),%edx
c0103cba:	89 54 24 08          	mov    %edx,0x8(%esp)
c0103cbe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103cc2:	8b 45 08             	mov    0x8(%ebp),%eax
c0103cc5:	89 04 24             	mov    %eax,(%esp)
c0103cc8:	e8 a6 09 00 00       	call   c0104673 <user_mem_check>
c0103ccd:	85 c0                	test   %eax,%eax
c0103ccf:	75 07                	jne    c0103cd8 <copy_from_user+0x31>
        return 0;
c0103cd1:	b8 00 00 00 00       	mov    $0x0,%eax
c0103cd6:	eb 1e                	jmp    c0103cf6 <copy_from_user+0x4f>
    }
    memcpy(dst, src, len);
c0103cd8:	8b 45 14             	mov    0x14(%ebp),%eax
c0103cdb:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103cdf:	8b 45 10             	mov    0x10(%ebp),%eax
c0103ce2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103ce6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103ce9:	89 04 24             	mov    %eax,(%esp)
c0103cec:	e8 23 7e 00 00       	call   c010bb14 <memcpy>
    return 1;
c0103cf1:	b8 01 00 00 00       	mov    $0x1,%eax
}
c0103cf6:	c9                   	leave  
c0103cf7:	c3                   	ret    

c0103cf8 <copy_to_user>:

bool
copy_to_user(struct mm_struct *mm, void *dst, const void *src, size_t len) {
c0103cf8:	55                   	push   %ebp
c0103cf9:	89 e5                	mov    %esp,%ebp
c0103cfb:	83 ec 18             	sub    $0x18,%esp
    if (!user_mem_check(mm, (uintptr_t)dst, len, 1)) {
c0103cfe:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103d01:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c0103d08:	00 
c0103d09:	8b 55 14             	mov    0x14(%ebp),%edx
c0103d0c:	89 54 24 08          	mov    %edx,0x8(%esp)
c0103d10:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103d14:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d17:	89 04 24             	mov    %eax,(%esp)
c0103d1a:	e8 54 09 00 00       	call   c0104673 <user_mem_check>
c0103d1f:	85 c0                	test   %eax,%eax
c0103d21:	75 07                	jne    c0103d2a <copy_to_user+0x32>
        return 0;
c0103d23:	b8 00 00 00 00       	mov    $0x0,%eax
c0103d28:	eb 1e                	jmp    c0103d48 <copy_to_user+0x50>
    }
    memcpy(dst, src, len);
c0103d2a:	8b 45 14             	mov    0x14(%ebp),%eax
c0103d2d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103d31:	8b 45 10             	mov    0x10(%ebp),%eax
c0103d34:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103d38:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103d3b:	89 04 24             	mov    %eax,(%esp)
c0103d3e:	e8 d1 7d 00 00       	call   c010bb14 <memcpy>
    return 1;
c0103d43:	b8 01 00 00 00       	mov    $0x1,%eax
}
c0103d48:	c9                   	leave  
c0103d49:	c3                   	ret    

c0103d4a <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
c0103d4a:	55                   	push   %ebp
c0103d4b:	89 e5                	mov    %esp,%ebp
c0103d4d:	83 ec 08             	sub    $0x8,%esp
    check_vmm();
c0103d50:	e8 02 00 00 00       	call   c0103d57 <check_vmm>
}
c0103d55:	c9                   	leave  
c0103d56:	c3                   	ret    

c0103d57 <check_vmm>:

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
c0103d57:	55                   	push   %ebp
c0103d58:	89 e5                	mov    %esp,%ebp
c0103d5a:	83 ec 28             	sub    $0x28,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0103d5d:	e8 f4 37 00 00       	call   c0107556 <nr_free_pages>
c0103d62:	89 45 f4             	mov    %eax,-0xc(%ebp)
    
    check_vma_struct();
c0103d65:	e8 13 00 00 00       	call   c0103d7d <check_vma_struct>
    check_pgfault();
c0103d6a:	e8 a7 04 00 00       	call   c0104216 <check_pgfault>

    cprintf("check_vmm() succeeded.\n");
c0103d6f:	c7 04 24 f4 cd 10 c0 	movl   $0xc010cdf4,(%esp)
c0103d76:	e8 33 c5 ff ff       	call   c01002ae <cprintf>
}
c0103d7b:	c9                   	leave  
c0103d7c:	c3                   	ret    

c0103d7d <check_vma_struct>:

static void
check_vma_struct(void) {
c0103d7d:	55                   	push   %ebp
c0103d7e:	89 e5                	mov    %esp,%ebp
c0103d80:	83 ec 68             	sub    $0x68,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0103d83:	e8 ce 37 00 00       	call   c0107556 <nr_free_pages>
c0103d88:	89 45 ec             	mov    %eax,-0x14(%ebp)

    struct mm_struct *mm = mm_create();
c0103d8b:	e8 27 f8 ff ff       	call   c01035b7 <mm_create>
c0103d90:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(mm != NULL);
c0103d93:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103d97:	75 24                	jne    c0103dbd <check_vma_struct+0x40>
c0103d99:	c7 44 24 0c ab cd 10 	movl   $0xc010cdab,0xc(%esp)
c0103da0:	c0 
c0103da1:	c7 44 24 08 1b cd 10 	movl   $0xc010cd1b,0x8(%esp)
c0103da8:	c0 
c0103da9:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c0103db0:	00 
c0103db1:	c7 04 24 30 cd 10 c0 	movl   $0xc010cd30,(%esp)
c0103db8:	e8 48 c6 ff ff       	call   c0100405 <__panic>

    int step1 = 10, step2 = step1 * 10;
c0103dbd:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
c0103dc4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103dc7:	89 d0                	mov    %edx,%eax
c0103dc9:	c1 e0 02             	shl    $0x2,%eax
c0103dcc:	01 d0                	add    %edx,%eax
c0103dce:	01 c0                	add    %eax,%eax
c0103dd0:	89 45 e0             	mov    %eax,-0x20(%ebp)

    int i;
    for (i = step1; i >= 1; i --) {
c0103dd3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103dd6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103dd9:	eb 70                	jmp    c0103e4b <check_vma_struct+0xce>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0103ddb:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103dde:	89 d0                	mov    %edx,%eax
c0103de0:	c1 e0 02             	shl    $0x2,%eax
c0103de3:	01 d0                	add    %edx,%eax
c0103de5:	83 c0 02             	add    $0x2,%eax
c0103de8:	89 c1                	mov    %eax,%ecx
c0103dea:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103ded:	89 d0                	mov    %edx,%eax
c0103def:	c1 e0 02             	shl    $0x2,%eax
c0103df2:	01 d0                	add    %edx,%eax
c0103df4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103dfb:	00 
c0103dfc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0103e00:	89 04 24             	mov    %eax,(%esp)
c0103e03:	e8 48 f8 ff ff       	call   c0103650 <vma_create>
c0103e08:	89 45 dc             	mov    %eax,-0x24(%ebp)
        assert(vma != NULL);
c0103e0b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0103e0f:	75 24                	jne    c0103e35 <check_vma_struct+0xb8>
c0103e11:	c7 44 24 0c 0c ce 10 	movl   $0xc010ce0c,0xc(%esp)
c0103e18:	c0 
c0103e19:	c7 44 24 08 1b cd 10 	movl   $0xc010cd1b,0x8(%esp)
c0103e20:	c0 
c0103e21:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
c0103e28:	00 
c0103e29:	c7 04 24 30 cd 10 c0 	movl   $0xc010cd30,(%esp)
c0103e30:	e8 d0 c5 ff ff       	call   c0100405 <__panic>
        insert_vma_struct(mm, vma);
c0103e35:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103e38:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103e3c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103e3f:	89 04 24             	mov    %eax,(%esp)
c0103e42:	e8 99 f9 ff ff       	call   c01037e0 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
c0103e47:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0103e4b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103e4f:	7f 8a                	jg     c0103ddb <check_vma_struct+0x5e>
    }

    for (i = step1 + 1; i <= step2; i ++) {
c0103e51:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103e54:	83 c0 01             	add    $0x1,%eax
c0103e57:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103e5a:	eb 70                	jmp    c0103ecc <check_vma_struct+0x14f>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0103e5c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103e5f:	89 d0                	mov    %edx,%eax
c0103e61:	c1 e0 02             	shl    $0x2,%eax
c0103e64:	01 d0                	add    %edx,%eax
c0103e66:	83 c0 02             	add    $0x2,%eax
c0103e69:	89 c1                	mov    %eax,%ecx
c0103e6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103e6e:	89 d0                	mov    %edx,%eax
c0103e70:	c1 e0 02             	shl    $0x2,%eax
c0103e73:	01 d0                	add    %edx,%eax
c0103e75:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103e7c:	00 
c0103e7d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0103e81:	89 04 24             	mov    %eax,(%esp)
c0103e84:	e8 c7 f7 ff ff       	call   c0103650 <vma_create>
c0103e89:	89 45 d8             	mov    %eax,-0x28(%ebp)
        assert(vma != NULL);
c0103e8c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0103e90:	75 24                	jne    c0103eb6 <check_vma_struct+0x139>
c0103e92:	c7 44 24 0c 0c ce 10 	movl   $0xc010ce0c,0xc(%esp)
c0103e99:	c0 
c0103e9a:	c7 44 24 08 1b cd 10 	movl   $0xc010cd1b,0x8(%esp)
c0103ea1:	c0 
c0103ea2:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c0103ea9:	00 
c0103eaa:	c7 04 24 30 cd 10 c0 	movl   $0xc010cd30,(%esp)
c0103eb1:	e8 4f c5 ff ff       	call   c0100405 <__panic>
        insert_vma_struct(mm, vma);
c0103eb6:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103eb9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103ebd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103ec0:	89 04 24             	mov    %eax,(%esp)
c0103ec3:	e8 18 f9 ff ff       	call   c01037e0 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
c0103ec8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0103ecc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ecf:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0103ed2:	7e 88                	jle    c0103e5c <check_vma_struct+0xdf>
    }

    list_entry_t *le = list_next(&(mm->mmap_list));
c0103ed4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103ed7:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0103eda:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103edd:	8b 40 04             	mov    0x4(%eax),%eax
c0103ee0:	89 45 f0             	mov    %eax,-0x10(%ebp)

    for (i = 1; i <= step2; i ++) {
c0103ee3:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c0103eea:	e9 97 00 00 00       	jmp    c0103f86 <check_vma_struct+0x209>
        assert(le != &(mm->mmap_list));
c0103eef:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103ef2:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103ef5:	75 24                	jne    c0103f1b <check_vma_struct+0x19e>
c0103ef7:	c7 44 24 0c 18 ce 10 	movl   $0xc010ce18,0xc(%esp)
c0103efe:	c0 
c0103eff:	c7 44 24 08 1b cd 10 	movl   $0xc010cd1b,0x8(%esp)
c0103f06:	c0 
c0103f07:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
c0103f0e:	00 
c0103f0f:	c7 04 24 30 cd 10 c0 	movl   $0xc010cd30,(%esp)
c0103f16:	e8 ea c4 ff ff       	call   c0100405 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
c0103f1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103f1e:	83 e8 10             	sub    $0x10,%eax
c0103f21:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
c0103f24:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103f27:	8b 48 04             	mov    0x4(%eax),%ecx
c0103f2a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103f2d:	89 d0                	mov    %edx,%eax
c0103f2f:	c1 e0 02             	shl    $0x2,%eax
c0103f32:	01 d0                	add    %edx,%eax
c0103f34:	39 c1                	cmp    %eax,%ecx
c0103f36:	75 17                	jne    c0103f4f <check_vma_struct+0x1d2>
c0103f38:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103f3b:	8b 48 08             	mov    0x8(%eax),%ecx
c0103f3e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103f41:	89 d0                	mov    %edx,%eax
c0103f43:	c1 e0 02             	shl    $0x2,%eax
c0103f46:	01 d0                	add    %edx,%eax
c0103f48:	83 c0 02             	add    $0x2,%eax
c0103f4b:	39 c1                	cmp    %eax,%ecx
c0103f4d:	74 24                	je     c0103f73 <check_vma_struct+0x1f6>
c0103f4f:	c7 44 24 0c 30 ce 10 	movl   $0xc010ce30,0xc(%esp)
c0103f56:	c0 
c0103f57:	c7 44 24 08 1b cd 10 	movl   $0xc010cd1b,0x8(%esp)
c0103f5e:	c0 
c0103f5f:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
c0103f66:	00 
c0103f67:	c7 04 24 30 cd 10 c0 	movl   $0xc010cd30,(%esp)
c0103f6e:	e8 92 c4 ff ff       	call   c0100405 <__panic>
c0103f73:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103f76:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c0103f79:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103f7c:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0103f7f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (i = 1; i <= step2; i ++) {
c0103f82:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0103f86:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103f89:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0103f8c:	0f 8e 5d ff ff ff    	jle    c0103eef <check_vma_struct+0x172>
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c0103f92:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
c0103f99:	e9 cd 01 00 00       	jmp    c010416b <check_vma_struct+0x3ee>
        struct vma_struct *vma1 = find_vma(mm, i);
c0103f9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103fa1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103fa5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103fa8:	89 04 24             	mov    %eax,(%esp)
c0103fab:	e8 db f6 ff ff       	call   c010368b <find_vma>
c0103fb0:	89 45 d0             	mov    %eax,-0x30(%ebp)
        assert(vma1 != NULL);
c0103fb3:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c0103fb7:	75 24                	jne    c0103fdd <check_vma_struct+0x260>
c0103fb9:	c7 44 24 0c 65 ce 10 	movl   $0xc010ce65,0xc(%esp)
c0103fc0:	c0 
c0103fc1:	c7 44 24 08 1b cd 10 	movl   $0xc010cd1b,0x8(%esp)
c0103fc8:	c0 
c0103fc9:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
c0103fd0:	00 
c0103fd1:	c7 04 24 30 cd 10 c0 	movl   $0xc010cd30,(%esp)
c0103fd8:	e8 28 c4 ff ff       	call   c0100405 <__panic>
        struct vma_struct *vma2 = find_vma(mm, i+1);
c0103fdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103fe0:	83 c0 01             	add    $0x1,%eax
c0103fe3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103fe7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103fea:	89 04 24             	mov    %eax,(%esp)
c0103fed:	e8 99 f6 ff ff       	call   c010368b <find_vma>
c0103ff2:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(vma2 != NULL);
c0103ff5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0103ff9:	75 24                	jne    c010401f <check_vma_struct+0x2a2>
c0103ffb:	c7 44 24 0c 72 ce 10 	movl   $0xc010ce72,0xc(%esp)
c0104002:	c0 
c0104003:	c7 44 24 08 1b cd 10 	movl   $0xc010cd1b,0x8(%esp)
c010400a:	c0 
c010400b:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
c0104012:	00 
c0104013:	c7 04 24 30 cd 10 c0 	movl   $0xc010cd30,(%esp)
c010401a:	e8 e6 c3 ff ff       	call   c0100405 <__panic>
        struct vma_struct *vma3 = find_vma(mm, i+2);
c010401f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104022:	83 c0 02             	add    $0x2,%eax
c0104025:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104029:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010402c:	89 04 24             	mov    %eax,(%esp)
c010402f:	e8 57 f6 ff ff       	call   c010368b <find_vma>
c0104034:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(vma3 == NULL);
c0104037:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c010403b:	74 24                	je     c0104061 <check_vma_struct+0x2e4>
c010403d:	c7 44 24 0c 7f ce 10 	movl   $0xc010ce7f,0xc(%esp)
c0104044:	c0 
c0104045:	c7 44 24 08 1b cd 10 	movl   $0xc010cd1b,0x8(%esp)
c010404c:	c0 
c010404d:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c0104054:	00 
c0104055:	c7 04 24 30 cd 10 c0 	movl   $0xc010cd30,(%esp)
c010405c:	e8 a4 c3 ff ff       	call   c0100405 <__panic>
        struct vma_struct *vma4 = find_vma(mm, i+3);
c0104061:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104064:	83 c0 03             	add    $0x3,%eax
c0104067:	89 44 24 04          	mov    %eax,0x4(%esp)
c010406b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010406e:	89 04 24             	mov    %eax,(%esp)
c0104071:	e8 15 f6 ff ff       	call   c010368b <find_vma>
c0104076:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        assert(vma4 == NULL);
c0104079:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
c010407d:	74 24                	je     c01040a3 <check_vma_struct+0x326>
c010407f:	c7 44 24 0c 8c ce 10 	movl   $0xc010ce8c,0xc(%esp)
c0104086:	c0 
c0104087:	c7 44 24 08 1b cd 10 	movl   $0xc010cd1b,0x8(%esp)
c010408e:	c0 
c010408f:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
c0104096:	00 
c0104097:	c7 04 24 30 cd 10 c0 	movl   $0xc010cd30,(%esp)
c010409e:	e8 62 c3 ff ff       	call   c0100405 <__panic>
        struct vma_struct *vma5 = find_vma(mm, i+4);
c01040a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01040a6:	83 c0 04             	add    $0x4,%eax
c01040a9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01040ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01040b0:	89 04 24             	mov    %eax,(%esp)
c01040b3:	e8 d3 f5 ff ff       	call   c010368b <find_vma>
c01040b8:	89 45 c0             	mov    %eax,-0x40(%ebp)
        assert(vma5 == NULL);
c01040bb:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c01040bf:	74 24                	je     c01040e5 <check_vma_struct+0x368>
c01040c1:	c7 44 24 0c 99 ce 10 	movl   $0xc010ce99,0xc(%esp)
c01040c8:	c0 
c01040c9:	c7 44 24 08 1b cd 10 	movl   $0xc010cd1b,0x8(%esp)
c01040d0:	c0 
c01040d1:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
c01040d8:	00 
c01040d9:	c7 04 24 30 cd 10 c0 	movl   $0xc010cd30,(%esp)
c01040e0:	e8 20 c3 ff ff       	call   c0100405 <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
c01040e5:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01040e8:	8b 50 04             	mov    0x4(%eax),%edx
c01040eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01040ee:	39 c2                	cmp    %eax,%edx
c01040f0:	75 10                	jne    c0104102 <check_vma_struct+0x385>
c01040f2:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01040f5:	8b 50 08             	mov    0x8(%eax),%edx
c01040f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01040fb:	83 c0 02             	add    $0x2,%eax
c01040fe:	39 c2                	cmp    %eax,%edx
c0104100:	74 24                	je     c0104126 <check_vma_struct+0x3a9>
c0104102:	c7 44 24 0c a8 ce 10 	movl   $0xc010cea8,0xc(%esp)
c0104109:	c0 
c010410a:	c7 44 24 08 1b cd 10 	movl   $0xc010cd1b,0x8(%esp)
c0104111:	c0 
c0104112:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
c0104119:	00 
c010411a:	c7 04 24 30 cd 10 c0 	movl   $0xc010cd30,(%esp)
c0104121:	e8 df c2 ff ff       	call   c0100405 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
c0104126:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104129:	8b 50 04             	mov    0x4(%eax),%edx
c010412c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010412f:	39 c2                	cmp    %eax,%edx
c0104131:	75 10                	jne    c0104143 <check_vma_struct+0x3c6>
c0104133:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104136:	8b 50 08             	mov    0x8(%eax),%edx
c0104139:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010413c:	83 c0 02             	add    $0x2,%eax
c010413f:	39 c2                	cmp    %eax,%edx
c0104141:	74 24                	je     c0104167 <check_vma_struct+0x3ea>
c0104143:	c7 44 24 0c d8 ce 10 	movl   $0xc010ced8,0xc(%esp)
c010414a:	c0 
c010414b:	c7 44 24 08 1b cd 10 	movl   $0xc010cd1b,0x8(%esp)
c0104152:	c0 
c0104153:	c7 44 24 04 33 01 00 	movl   $0x133,0x4(%esp)
c010415a:	00 
c010415b:	c7 04 24 30 cd 10 c0 	movl   $0xc010cd30,(%esp)
c0104162:	e8 9e c2 ff ff       	call   c0100405 <__panic>
    for (i = 5; i <= 5 * step2; i +=5) {
c0104167:	83 45 f4 05          	addl   $0x5,-0xc(%ebp)
c010416b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010416e:	89 d0                	mov    %edx,%eax
c0104170:	c1 e0 02             	shl    $0x2,%eax
c0104173:	01 d0                	add    %edx,%eax
c0104175:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104178:	0f 8d 20 fe ff ff    	jge    c0103f9e <check_vma_struct+0x221>
    }

    for (i =4; i>=0; i--) {
c010417e:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
c0104185:	eb 70                	jmp    c01041f7 <check_vma_struct+0x47a>
        struct vma_struct *vma_below_5= find_vma(mm,i);
c0104187:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010418a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010418e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104191:	89 04 24             	mov    %eax,(%esp)
c0104194:	e8 f2 f4 ff ff       	call   c010368b <find_vma>
c0104199:	89 45 bc             	mov    %eax,-0x44(%ebp)
        if (vma_below_5 != NULL ) {
c010419c:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c01041a0:	74 27                	je     c01041c9 <check_vma_struct+0x44c>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
c01041a2:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01041a5:	8b 50 08             	mov    0x8(%eax),%edx
c01041a8:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01041ab:	8b 40 04             	mov    0x4(%eax),%eax
c01041ae:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01041b2:	89 44 24 08          	mov    %eax,0x8(%esp)
c01041b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01041b9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01041bd:	c7 04 24 08 cf 10 c0 	movl   $0xc010cf08,(%esp)
c01041c4:	e8 e5 c0 ff ff       	call   c01002ae <cprintf>
        }
        assert(vma_below_5 == NULL);
c01041c9:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c01041cd:	74 24                	je     c01041f3 <check_vma_struct+0x476>
c01041cf:	c7 44 24 0c 2d cf 10 	movl   $0xc010cf2d,0xc(%esp)
c01041d6:	c0 
c01041d7:	c7 44 24 08 1b cd 10 	movl   $0xc010cd1b,0x8(%esp)
c01041de:	c0 
c01041df:	c7 44 24 04 3b 01 00 	movl   $0x13b,0x4(%esp)
c01041e6:	00 
c01041e7:	c7 04 24 30 cd 10 c0 	movl   $0xc010cd30,(%esp)
c01041ee:	e8 12 c2 ff ff       	call   c0100405 <__panic>
    for (i =4; i>=0; i--) {
c01041f3:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01041f7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01041fb:	79 8a                	jns    c0104187 <check_vma_struct+0x40a>
    }

    mm_destroy(mm);
c01041fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104200:	89 04 24             	mov    %eax,(%esp)
c0104203:	e8 08 f7 ff ff       	call   c0103910 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
c0104208:	c7 04 24 44 cf 10 c0 	movl   $0xc010cf44,(%esp)
c010420f:	e8 9a c0 ff ff       	call   c01002ae <cprintf>
}
c0104214:	c9                   	leave  
c0104215:	c3                   	ret    

c0104216 <check_pgfault>:

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
c0104216:	55                   	push   %ebp
c0104217:	89 e5                	mov    %esp,%ebp
c0104219:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c010421c:	e8 35 33 00 00       	call   c0107556 <nr_free_pages>
c0104221:	89 45 ec             	mov    %eax,-0x14(%ebp)

    check_mm_struct = mm_create();
c0104224:	e8 8e f3 ff ff       	call   c01035b7 <mm_create>
c0104229:	a3 7c 30 1b c0       	mov    %eax,0xc01b307c
    assert(check_mm_struct != NULL);
c010422e:	a1 7c 30 1b c0       	mov    0xc01b307c,%eax
c0104233:	85 c0                	test   %eax,%eax
c0104235:	75 24                	jne    c010425b <check_pgfault+0x45>
c0104237:	c7 44 24 0c 63 cf 10 	movl   $0xc010cf63,0xc(%esp)
c010423e:	c0 
c010423f:	c7 44 24 08 1b cd 10 	movl   $0xc010cd1b,0x8(%esp)
c0104246:	c0 
c0104247:	c7 44 24 04 4b 01 00 	movl   $0x14b,0x4(%esp)
c010424e:	00 
c010424f:	c7 04 24 30 cd 10 c0 	movl   $0xc010cd30,(%esp)
c0104256:	e8 aa c1 ff ff       	call   c0100405 <__panic>

    struct mm_struct *mm = check_mm_struct;
c010425b:	a1 7c 30 1b c0       	mov    0xc01b307c,%eax
c0104260:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
c0104263:	8b 15 20 ca 12 c0    	mov    0xc012ca20,%edx
c0104269:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010426c:	89 50 0c             	mov    %edx,0xc(%eax)
c010426f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104272:	8b 40 0c             	mov    0xc(%eax),%eax
c0104275:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(pgdir[0] == 0);
c0104278:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010427b:	8b 00                	mov    (%eax),%eax
c010427d:	85 c0                	test   %eax,%eax
c010427f:	74 24                	je     c01042a5 <check_pgfault+0x8f>
c0104281:	c7 44 24 0c 7b cf 10 	movl   $0xc010cf7b,0xc(%esp)
c0104288:	c0 
c0104289:	c7 44 24 08 1b cd 10 	movl   $0xc010cd1b,0x8(%esp)
c0104290:	c0 
c0104291:	c7 44 24 04 4f 01 00 	movl   $0x14f,0x4(%esp)
c0104298:	00 
c0104299:	c7 04 24 30 cd 10 c0 	movl   $0xc010cd30,(%esp)
c01042a0:	e8 60 c1 ff ff       	call   c0100405 <__panic>

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
c01042a5:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
c01042ac:	00 
c01042ad:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
c01042b4:	00 
c01042b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01042bc:	e8 8f f3 ff ff       	call   c0103650 <vma_create>
c01042c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(vma != NULL);
c01042c4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01042c8:	75 24                	jne    c01042ee <check_pgfault+0xd8>
c01042ca:	c7 44 24 0c 0c ce 10 	movl   $0xc010ce0c,0xc(%esp)
c01042d1:	c0 
c01042d2:	c7 44 24 08 1b cd 10 	movl   $0xc010cd1b,0x8(%esp)
c01042d9:	c0 
c01042da:	c7 44 24 04 52 01 00 	movl   $0x152,0x4(%esp)
c01042e1:	00 
c01042e2:	c7 04 24 30 cd 10 c0 	movl   $0xc010cd30,(%esp)
c01042e9:	e8 17 c1 ff ff       	call   c0100405 <__panic>

    insert_vma_struct(mm, vma);
c01042ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01042f1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01042f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01042f8:	89 04 24             	mov    %eax,(%esp)
c01042fb:	e8 e0 f4 ff ff       	call   c01037e0 <insert_vma_struct>

    uintptr_t addr = 0x100;
c0104300:	c7 45 dc 00 01 00 00 	movl   $0x100,-0x24(%ebp)
    assert(find_vma(mm, addr) == vma);
c0104307:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010430a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010430e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104311:	89 04 24             	mov    %eax,(%esp)
c0104314:	e8 72 f3 ff ff       	call   c010368b <find_vma>
c0104319:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c010431c:	74 24                	je     c0104342 <check_pgfault+0x12c>
c010431e:	c7 44 24 0c 89 cf 10 	movl   $0xc010cf89,0xc(%esp)
c0104325:	c0 
c0104326:	c7 44 24 08 1b cd 10 	movl   $0xc010cd1b,0x8(%esp)
c010432d:	c0 
c010432e:	c7 44 24 04 57 01 00 	movl   $0x157,0x4(%esp)
c0104335:	00 
c0104336:	c7 04 24 30 cd 10 c0 	movl   $0xc010cd30,(%esp)
c010433d:	e8 c3 c0 ff ff       	call   c0100405 <__panic>

    int i, sum = 0;
c0104342:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0104349:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104350:	eb 17                	jmp    c0104369 <check_pgfault+0x153>
        *(char *)(addr + i) = i;
c0104352:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104355:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104358:	01 d0                	add    %edx,%eax
c010435a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010435d:	88 10                	mov    %dl,(%eax)
        sum += i;
c010435f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104362:	01 45 f0             	add    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0104365:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0104369:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c010436d:	7e e3                	jle    c0104352 <check_pgfault+0x13c>
    }
    for (i = 0; i < 100; i ++) {
c010436f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104376:	eb 15                	jmp    c010438d <check_pgfault+0x177>
        sum -= *(char *)(addr + i);
c0104378:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010437b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010437e:	01 d0                	add    %edx,%eax
c0104380:	0f b6 00             	movzbl (%eax),%eax
c0104383:	0f be c0             	movsbl %al,%eax
c0104386:	29 45 f0             	sub    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0104389:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010438d:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0104391:	7e e5                	jle    c0104378 <check_pgfault+0x162>
    }
    assert(sum == 0);
c0104393:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104397:	74 24                	je     c01043bd <check_pgfault+0x1a7>
c0104399:	c7 44 24 0c a3 cf 10 	movl   $0xc010cfa3,0xc(%esp)
c01043a0:	c0 
c01043a1:	c7 44 24 08 1b cd 10 	movl   $0xc010cd1b,0x8(%esp)
c01043a8:	c0 
c01043a9:	c7 44 24 04 61 01 00 	movl   $0x161,0x4(%esp)
c01043b0:	00 
c01043b1:	c7 04 24 30 cd 10 c0 	movl   $0xc010cd30,(%esp)
c01043b8:	e8 48 c0 ff ff       	call   c0100405 <__panic>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
c01043bd:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01043c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01043c3:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01043c6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01043cb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01043cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01043d2:	89 04 24             	mov    %eax,(%esp)
c01043d5:	e8 d9 3d 00 00       	call   c01081b3 <page_remove>
    free_page(pde2page(pgdir[0]));
c01043da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01043dd:	8b 00                	mov    (%eax),%eax
c01043df:	89 04 24             	mov    %eax,(%esp)
c01043e2:	e8 b8 f1 ff ff       	call   c010359f <pde2page>
c01043e7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01043ee:	00 
c01043ef:	89 04 24             	mov    %eax,(%esp)
c01043f2:	e8 2d 31 00 00       	call   c0107524 <free_pages>
    pgdir[0] = 0;
c01043f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01043fa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    mm->pgdir = NULL;
c0104400:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104403:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    mm_destroy(mm);
c010440a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010440d:	89 04 24             	mov    %eax,(%esp)
c0104410:	e8 fb f4 ff ff       	call   c0103910 <mm_destroy>
    check_mm_struct = NULL;
c0104415:	c7 05 7c 30 1b c0 00 	movl   $0x0,0xc01b307c
c010441c:	00 00 00 

    assert(nr_free_pages_store == nr_free_pages());
c010441f:	e8 32 31 00 00       	call   c0107556 <nr_free_pages>
c0104424:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0104427:	74 24                	je     c010444d <check_pgfault+0x237>
c0104429:	c7 44 24 0c ac cf 10 	movl   $0xc010cfac,0xc(%esp)
c0104430:	c0 
c0104431:	c7 44 24 08 1b cd 10 	movl   $0xc010cd1b,0x8(%esp)
c0104438:	c0 
c0104439:	c7 44 24 04 6b 01 00 	movl   $0x16b,0x4(%esp)
c0104440:	00 
c0104441:	c7 04 24 30 cd 10 c0 	movl   $0xc010cd30,(%esp)
c0104448:	e8 b8 bf ff ff       	call   c0100405 <__panic>

    cprintf("check_pgfault() succeeded!\n");
c010444d:	c7 04 24 d3 cf 10 c0 	movl   $0xc010cfd3,(%esp)
c0104454:	e8 55 be ff ff       	call   c01002ae <cprintf>
}
c0104459:	c9                   	leave  
c010445a:	c3                   	ret    

c010445b <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
c010445b:	55                   	push   %ebp
c010445c:	89 e5                	mov    %esp,%ebp
c010445e:	83 ec 38             	sub    $0x38,%esp
    int ret = -E_INVAL;
c0104461:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
c0104468:	8b 45 10             	mov    0x10(%ebp),%eax
c010446b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010446f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104472:	89 04 24             	mov    %eax,(%esp)
c0104475:	e8 11 f2 ff ff       	call   c010368b <find_vma>
c010447a:	89 45 ec             	mov    %eax,-0x14(%ebp)

    pgfault_num++;
c010447d:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c0104482:	83 c0 01             	add    $0x1,%eax
c0104485:	a3 64 0f 1b c0       	mov    %eax,0xc01b0f64
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
c010448a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010448e:	74 0b                	je     c010449b <do_pgfault+0x40>
c0104490:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104493:	8b 40 04             	mov    0x4(%eax),%eax
c0104496:	3b 45 10             	cmp    0x10(%ebp),%eax
c0104499:	76 18                	jbe    c01044b3 <do_pgfault+0x58>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
c010449b:	8b 45 10             	mov    0x10(%ebp),%eax
c010449e:	89 44 24 04          	mov    %eax,0x4(%esp)
c01044a2:	c7 04 24 f0 cf 10 c0 	movl   $0xc010cff0,(%esp)
c01044a9:	e8 00 be ff ff       	call   c01002ae <cprintf>
        goto failed;
c01044ae:	e9 bb 01 00 00       	jmp    c010466e <do_pgfault+0x213>
    }
    //check the error_code
    switch (error_code & 3) {
c01044b3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01044b6:	83 e0 03             	and    $0x3,%eax
c01044b9:	85 c0                	test   %eax,%eax
c01044bb:	74 36                	je     c01044f3 <do_pgfault+0x98>
c01044bd:	83 f8 01             	cmp    $0x1,%eax
c01044c0:	74 20                	je     c01044e2 <do_pgfault+0x87>
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
c01044c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01044c5:	8b 40 0c             	mov    0xc(%eax),%eax
c01044c8:	83 e0 02             	and    $0x2,%eax
c01044cb:	85 c0                	test   %eax,%eax
c01044cd:	75 11                	jne    c01044e0 <do_pgfault+0x85>
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
c01044cf:	c7 04 24 20 d0 10 c0 	movl   $0xc010d020,(%esp)
c01044d6:	e8 d3 bd ff ff       	call   c01002ae <cprintf>
            goto failed;
c01044db:	e9 8e 01 00 00       	jmp    c010466e <do_pgfault+0x213>
        }
        break;
c01044e0:	eb 2f                	jmp    c0104511 <do_pgfault+0xb6>
    case 1: /* error code flag : (W/R=0, P=1): read, present */
        cprintf("do_pgfault failed: error code flag = read AND present\n");
c01044e2:	c7 04 24 80 d0 10 c0 	movl   $0xc010d080,(%esp)
c01044e9:	e8 c0 bd ff ff       	call   c01002ae <cprintf>
        goto failed;
c01044ee:	e9 7b 01 00 00       	jmp    c010466e <do_pgfault+0x213>
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
c01044f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01044f6:	8b 40 0c             	mov    0xc(%eax),%eax
c01044f9:	83 e0 05             	and    $0x5,%eax
c01044fc:	85 c0                	test   %eax,%eax
c01044fe:	75 11                	jne    c0104511 <do_pgfault+0xb6>
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
c0104500:	c7 04 24 b8 d0 10 c0 	movl   $0xc010d0b8,(%esp)
c0104507:	e8 a2 bd ff ff       	call   c01002ae <cprintf>
            goto failed;
c010450c:	e9 5d 01 00 00       	jmp    c010466e <do_pgfault+0x213>
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
c0104511:	c7 45 f0 04 00 00 00 	movl   $0x4,-0x10(%ebp)
    if (vma->vm_flags & VM_WRITE) {
c0104518:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010451b:	8b 40 0c             	mov    0xc(%eax),%eax
c010451e:	83 e0 02             	and    $0x2,%eax
c0104521:	85 c0                	test   %eax,%eax
c0104523:	74 04                	je     c0104529 <do_pgfault+0xce>
        perm |= PTE_W;
c0104525:	83 4d f0 02          	orl    $0x2,-0x10(%ebp)
    }
    addr = ROUNDDOWN(addr, PGSIZE);
c0104529:	8b 45 10             	mov    0x10(%ebp),%eax
c010452c:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010452f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104532:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104537:	89 45 10             	mov    %eax,0x10(%ebp)

    ret = -E_NO_MEM;
c010453a:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    pte_t *ptep=NULL;
c0104541:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    *   mm->pgdir : the PDT of these vma
    *
    */
//try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
	//检查页表中是否有相应的应用程序需要的表项，有就获取指向这个表项的指针
	if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
c0104548:	8b 45 08             	mov    0x8(%ebp),%eax
c010454b:	8b 40 0c             	mov    0xc(%eax),%eax
c010454e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0104555:	00 
c0104556:	8b 55 10             	mov    0x10(%ebp),%edx
c0104559:	89 54 24 04          	mov    %edx,0x4(%esp)
c010455d:	89 04 24             	mov    %eax,(%esp)
c0104560:	e8 38 36 00 00       	call   c0107b9d <get_pte>
c0104565:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104568:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010456c:	75 11                	jne    c010457f <do_pgfault+0x124>
        cprintf("get_pte in do_pgfault failed\n");
c010456e:	c7 04 24 1b d1 10 c0 	movl   $0xc010d11b,(%esp)
c0104575:	e8 34 bd ff ff       	call   c01002ae <cprintf>
        goto failed;
c010457a:	e9 ef 00 00 00       	jmp    c010466e <do_pgfault+0x213>
    }
	//然后检查这个表项是否为空(是否被映射)，如果为空，pgdir_alloc_page分配一个新的物理页
    if (*ptep == 0) {  
c010457f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104582:	8b 00                	mov    (%eax),%eax
c0104584:	85 c0                	test   %eax,%eax
c0104586:	75 35                	jne    c01045bd <do_pgfault+0x162>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
c0104588:	8b 45 08             	mov    0x8(%ebp),%eax
c010458b:	8b 40 0c             	mov    0xc(%eax),%eax
c010458e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104591:	89 54 24 08          	mov    %edx,0x8(%esp)
c0104595:	8b 55 10             	mov    0x10(%ebp),%edx
c0104598:	89 54 24 04          	mov    %edx,0x4(%esp)
c010459c:	89 04 24             	mov    %eax,(%esp)
c010459f:	e8 69 3d 00 00       	call   c010830d <pgdir_alloc_page>
c01045a4:	85 c0                	test   %eax,%eax
c01045a6:	0f 85 bb 00 00 00    	jne    c0104667 <do_pgfault+0x20c>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
c01045ac:	c7 04 24 3c d1 10 c0 	movl   $0xc010d13c,(%esp)
c01045b3:	e8 f6 bc ff ff       	call   c01002ae <cprintf>
            goto failed;
c01045b8:	e9 b1 00 00 00       	jmp    c010466e <do_pgfault+0x213>
        }
    }
 //如果这个页表项非空，那么说明这一页已经映射过了但是被保存在磁盘中，需要将这一页内存交换出来
// if this pte is a swap entry, then load data from disk to a page with phy addr and call page_insert to map the phy addr with logical addr
    else {   
        if(swap_init_ok) {
c01045bd:	a1 6c 0f 1b c0       	mov    0xc01b0f6c,%eax
c01045c2:	85 c0                	test   %eax,%eax
c01045c4:	0f 84 86 00 00 00    	je     c0104650 <do_pgfault+0x1f5>
            //如果可以交换
            struct Page *page=NULL; 
c01045ca:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
            //根据mm结构和addr地址，尝试将硬盘中的内容换入至page中
            //load the content of right disk page into the memory which page managed.
            if ((ret = swap_in(mm, addr, &page)) != 0) {
c01045d1:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01045d4:	89 44 24 08          	mov    %eax,0x8(%esp)
c01045d8:	8b 45 10             	mov    0x10(%ebp),%eax
c01045db:	89 44 24 04          	mov    %eax,0x4(%esp)
c01045df:	8b 45 08             	mov    0x8(%ebp),%eax
c01045e2:	89 04 24             	mov    %eax,(%esp)
c01045e5:	e8 65 11 00 00       	call   c010574f <swap_in>
c01045ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01045ed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01045f1:	74 0e                	je     c0104601 <do_pgfault+0x1a6>
                cprintf("swap_in in do_pgfault failed\n");
c01045f3:	c7 04 24 63 d1 10 c0 	movl   $0xc010d163,(%esp)
c01045fa:	e8 af bc ff ff       	call   c01002ae <cprintf>
c01045ff:	eb 6d                	jmp    c010466e <do_pgfault+0x213>
                goto failed;
            }    
            page_insert(mm->pgdir, page, addr, perm); 
c0104601:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104604:	8b 45 08             	mov    0x8(%ebp),%eax
c0104607:	8b 40 0c             	mov    0xc(%eax),%eax
c010460a:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c010460d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0104611:	8b 4d 10             	mov    0x10(%ebp),%ecx
c0104614:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0104618:	89 54 24 04          	mov    %edx,0x4(%esp)
c010461c:	89 04 24             	mov    %eax,(%esp)
c010461f:	e8 d3 3b 00 00       	call   c01081f7 <page_insert>
            //建立虚拟地址和物理地址之间的对应关系 According to the mm, addr AND page, setup the map of phy addr <---> logical addr
            swap_map_swappable(mm, addr, page, 1); 
c0104624:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104627:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c010462e:	00 
c010462f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104633:	8b 45 10             	mov    0x10(%ebp),%eax
c0104636:	89 44 24 04          	mov    %eax,0x4(%esp)
c010463a:	8b 45 08             	mov    0x8(%ebp),%eax
c010463d:	89 04 24             	mov    %eax,(%esp)
c0104640:	e8 41 0f 00 00       	call   c0105586 <swap_map_swappable>
            //将此页面设置为可交换的 make the page swappable.  
            page->pra_vaddr = addr;
c0104645:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104648:	8b 55 10             	mov    0x10(%ebp),%edx
c010464b:	89 50 1c             	mov    %edx,0x1c(%eax)
c010464e:	eb 17                	jmp    c0104667 <do_pgfault+0x20c>
        }
        else {
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
c0104650:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104653:	8b 00                	mov    (%eax),%eax
c0104655:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104659:	c7 04 24 84 d1 10 c0 	movl   $0xc010d184,(%esp)
c0104660:	e8 49 bc ff ff       	call   c01002ae <cprintf>
            goto failed;
c0104665:	eb 07                	jmp    c010466e <do_pgfault+0x213>
        }
   }
   ret = 0;
c0104667:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
failed:
    return ret;
c010466e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104671:	c9                   	leave  
c0104672:	c3                   	ret    

c0104673 <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
c0104673:	55                   	push   %ebp
c0104674:	89 e5                	mov    %esp,%ebp
c0104676:	83 ec 18             	sub    $0x18,%esp
    if (mm != NULL) {
c0104679:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010467d:	0f 84 e0 00 00 00    	je     c0104763 <user_mem_check+0xf0>
        if (!USER_ACCESS(addr, addr + len)) {
c0104683:	81 7d 0c ff ff 1f 00 	cmpl   $0x1fffff,0xc(%ebp)
c010468a:	76 1c                	jbe    c01046a8 <user_mem_check+0x35>
c010468c:	8b 45 10             	mov    0x10(%ebp),%eax
c010468f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104692:	01 d0                	add    %edx,%eax
c0104694:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104697:	76 0f                	jbe    c01046a8 <user_mem_check+0x35>
c0104699:	8b 45 10             	mov    0x10(%ebp),%eax
c010469c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010469f:	01 d0                	add    %edx,%eax
c01046a1:	3d 00 00 00 b0       	cmp    $0xb0000000,%eax
c01046a6:	76 0a                	jbe    c01046b2 <user_mem_check+0x3f>
            return 0;
c01046a8:	b8 00 00 00 00       	mov    $0x0,%eax
c01046ad:	e9 e2 00 00 00       	jmp    c0104794 <user_mem_check+0x121>
        }
        struct vma_struct *vma;
        uintptr_t start = addr, end = addr + len;
c01046b2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01046b5:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01046b8:	8b 45 10             	mov    0x10(%ebp),%eax
c01046bb:	8b 55 0c             	mov    0xc(%ebp),%edx
c01046be:	01 d0                	add    %edx,%eax
c01046c0:	89 45 f8             	mov    %eax,-0x8(%ebp)
        while (start < end) {
c01046c3:	e9 88 00 00 00       	jmp    c0104750 <user_mem_check+0xdd>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
c01046c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01046cb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01046cf:	8b 45 08             	mov    0x8(%ebp),%eax
c01046d2:	89 04 24             	mov    %eax,(%esp)
c01046d5:	e8 b1 ef ff ff       	call   c010368b <find_vma>
c01046da:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01046dd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01046e1:	74 0b                	je     c01046ee <user_mem_check+0x7b>
c01046e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046e6:	8b 40 04             	mov    0x4(%eax),%eax
c01046e9:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01046ec:	76 0a                	jbe    c01046f8 <user_mem_check+0x85>
                return 0;
c01046ee:	b8 00 00 00 00       	mov    $0x0,%eax
c01046f3:	e9 9c 00 00 00       	jmp    c0104794 <user_mem_check+0x121>
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
c01046f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046fb:	8b 50 0c             	mov    0xc(%eax),%edx
c01046fe:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0104702:	74 07                	je     c010470b <user_mem_check+0x98>
c0104704:	b8 02 00 00 00       	mov    $0x2,%eax
c0104709:	eb 05                	jmp    c0104710 <user_mem_check+0x9d>
c010470b:	b8 01 00 00 00       	mov    $0x1,%eax
c0104710:	21 d0                	and    %edx,%eax
c0104712:	85 c0                	test   %eax,%eax
c0104714:	75 07                	jne    c010471d <user_mem_check+0xaa>
                return 0;
c0104716:	b8 00 00 00 00       	mov    $0x0,%eax
c010471b:	eb 77                	jmp    c0104794 <user_mem_check+0x121>
            }
            if (write && (vma->vm_flags & VM_STACK)) {
c010471d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0104721:	74 24                	je     c0104747 <user_mem_check+0xd4>
c0104723:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104726:	8b 40 0c             	mov    0xc(%eax),%eax
c0104729:	83 e0 08             	and    $0x8,%eax
c010472c:	85 c0                	test   %eax,%eax
c010472e:	74 17                	je     c0104747 <user_mem_check+0xd4>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
c0104730:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104733:	8b 40 04             	mov    0x4(%eax),%eax
c0104736:	05 00 10 00 00       	add    $0x1000,%eax
c010473b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010473e:	76 07                	jbe    c0104747 <user_mem_check+0xd4>
                    return 0;
c0104740:	b8 00 00 00 00       	mov    $0x0,%eax
c0104745:	eb 4d                	jmp    c0104794 <user_mem_check+0x121>
                }
            }
            start = vma->vm_end;
c0104747:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010474a:	8b 40 08             	mov    0x8(%eax),%eax
c010474d:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < end) {
c0104750:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104753:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0104756:	0f 82 6c ff ff ff    	jb     c01046c8 <user_mem_check+0x55>
        }
        return 1;
c010475c:	b8 01 00 00 00       	mov    $0x1,%eax
c0104761:	eb 31                	jmp    c0104794 <user_mem_check+0x121>
    }
    return KERN_ACCESS(addr, addr + len);
c0104763:	81 7d 0c ff ff ff bf 	cmpl   $0xbfffffff,0xc(%ebp)
c010476a:	76 23                	jbe    c010478f <user_mem_check+0x11c>
c010476c:	8b 45 10             	mov    0x10(%ebp),%eax
c010476f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104772:	01 d0                	add    %edx,%eax
c0104774:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104777:	76 16                	jbe    c010478f <user_mem_check+0x11c>
c0104779:	8b 45 10             	mov    0x10(%ebp),%eax
c010477c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010477f:	01 d0                	add    %edx,%eax
c0104781:	3d 00 00 00 f8       	cmp    $0xf8000000,%eax
c0104786:	77 07                	ja     c010478f <user_mem_check+0x11c>
c0104788:	b8 01 00 00 00       	mov    $0x1,%eax
c010478d:	eb 05                	jmp    c0104794 <user_mem_check+0x121>
c010478f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104794:	c9                   	leave  
c0104795:	c3                   	ret    

c0104796 <_fifo_init_mm>:
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
c0104796:	55                   	push   %ebp
c0104797:	89 e5                	mov    %esp,%ebp
c0104799:	83 ec 10             	sub    $0x10,%esp
c010479c:	c7 45 fc 80 30 1b c0 	movl   $0xc01b3080,-0x4(%ebp)
    elm->prev = elm->next = elm;
c01047a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01047a6:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01047a9:	89 50 04             	mov    %edx,0x4(%eax)
c01047ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01047af:	8b 50 04             	mov    0x4(%eax),%edx
c01047b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01047b5:	89 10                	mov    %edx,(%eax)
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
c01047b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01047ba:	c7 40 14 80 30 1b c0 	movl   $0xc01b3080,0x14(%eax)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
c01047c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01047c6:	c9                   	leave  
c01047c7:	c3                   	ret    

c01047c8 <_fifo_map_swappable>:
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c01047c8:	55                   	push   %ebp
c01047c9:	89 e5                	mov    %esp,%ebp
c01047cb:	83 ec 48             	sub    $0x48,%esp
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
c01047ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01047d1:	8b 40 14             	mov    0x14(%eax),%eax
c01047d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry=&(page->pra_page_link);
c01047d7:	8b 45 10             	mov    0x10(%ebp),%eax
c01047da:	83 c0 14             	add    $0x14,%eax
c01047dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 
    assert(entry != NULL && head != NULL);
c01047e0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01047e4:	74 06                	je     c01047ec <_fifo_map_swappable+0x24>
c01047e6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01047ea:	75 24                	jne    c0104810 <_fifo_map_swappable+0x48>
c01047ec:	c7 44 24 0c ac d1 10 	movl   $0xc010d1ac,0xc(%esp)
c01047f3:	c0 
c01047f4:	c7 44 24 08 ca d1 10 	movl   $0xc010d1ca,0x8(%esp)
c01047fb:	c0 
c01047fc:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
c0104803:	00 
c0104804:	c7 04 24 df d1 10 c0 	movl   $0xc010d1df,(%esp)
c010480b:	e8 f5 bb ff ff       	call   c0100405 <__panic>
c0104810:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104813:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104816:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104819:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010481c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010481f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104822:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104825:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_add(elm, listelm, listelm->next);
c0104828:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010482b:	8b 40 04             	mov    0x4(%eax),%eax
c010482e:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104831:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0104834:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104837:	89 55 d8             	mov    %edx,-0x28(%ebp)
c010483a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    prev->next = next->prev = elm;
c010483d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104840:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104843:	89 10                	mov    %edx,(%eax)
c0104845:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104848:	8b 10                	mov    (%eax),%edx
c010484a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010484d:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0104850:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104853:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104856:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0104859:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010485c:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010485f:	89 10                	mov    %edx,(%eax)
    //record the page access situlation
    /*LAB3 EXERCISE 2: YOUR CODE*/ 
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
    list_add(head, entry);
    return 0;
c0104861:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104866:	c9                   	leave  
c0104867:	c3                   	ret    

c0104868 <_fifo_swap_out_victim>:
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then assign the value of *ptr_page to the addr of this page.
 */
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
c0104868:	55                   	push   %ebp
c0104869:	89 e5                	mov    %esp,%ebp
c010486b:	83 ec 38             	sub    $0x38,%esp
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
c010486e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104871:	8b 40 14             	mov    0x14(%eax),%eax
c0104874:	89 45 f4             	mov    %eax,-0xc(%ebp)
         assert(head != NULL);
c0104877:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010487b:	75 24                	jne    c01048a1 <_fifo_swap_out_victim+0x39>
c010487d:	c7 44 24 0c f3 d1 10 	movl   $0xc010d1f3,0xc(%esp)
c0104884:	c0 
c0104885:	c7 44 24 08 ca d1 10 	movl   $0xc010d1ca,0x8(%esp)
c010488c:	c0 
c010488d:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
c0104894:	00 
c0104895:	c7 04 24 df d1 10 c0 	movl   $0xc010d1df,(%esp)
c010489c:	e8 64 bb ff ff       	call   c0100405 <__panic>
     assert(in_tick==0);
c01048a1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01048a5:	74 24                	je     c01048cb <_fifo_swap_out_victim+0x63>
c01048a7:	c7 44 24 0c 00 d2 10 	movl   $0xc010d200,0xc(%esp)
c01048ae:	c0 
c01048af:	c7 44 24 08 ca d1 10 	movl   $0xc010d1ca,0x8(%esp)
c01048b6:	c0 
c01048b7:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
c01048be:	00 
c01048bf:	c7 04 24 df d1 10 c0 	movl   $0xc010d1df,(%esp)
c01048c6:	e8 3a bb ff ff       	call   c0100405 <__panic>
     /* Select the victim */
     /*LAB3 EXERCISE 2: YOUR CODE*/ 
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  assign the value of *ptr_page to the addr of this page
     //需要被换出的页
     list_entry_t *le = head->prev;
c01048cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048ce:	8b 00                	mov    (%eax),%eax
c01048d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
     assert(head!=le);
c01048d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048d6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01048d9:	75 24                	jne    c01048ff <_fifo_swap_out_victim+0x97>
c01048db:	c7 44 24 0c 0b d2 10 	movl   $0xc010d20b,0xc(%esp)
c01048e2:	c0 
c01048e3:	c7 44 24 08 ca d1 10 	movl   $0xc010d1ca,0x8(%esp)
c01048ea:	c0 
c01048eb:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
c01048f2:	00 
c01048f3:	c7 04 24 df d1 10 c0 	movl   $0xc010d1df,(%esp)
c01048fa:	e8 06 bb ff ff       	call   c0100405 <__panic>
     //获得对应page的指针p
     struct Page *p = le2page(le, pra_page_link);
c01048ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104902:	83 e8 14             	sub    $0x14,%eax
c0104905:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104908:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010490b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    __list_del(listelm->prev, listelm->next);
c010490e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104911:	8b 40 04             	mov    0x4(%eax),%eax
c0104914:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104917:	8b 12                	mov    (%edx),%edx
c0104919:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010491c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    prev->next = next;
c010491f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104922:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104925:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0104928:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010492b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010492e:	89 10                	mov    %edx,(%eax)
     //将最老的页面从队列中删除
     list_del(le);
     assert(p !=NULL);
c0104930:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104934:	75 24                	jne    c010495a <_fifo_swap_out_victim+0xf2>
c0104936:	c7 44 24 0c 14 d2 10 	movl   $0xc010d214,0xc(%esp)
c010493d:	c0 
c010493e:	c7 44 24 08 ca d1 10 	movl   $0xc010d1ca,0x8(%esp)
c0104945:	c0 
c0104946:	c7 44 24 04 4e 00 00 	movl   $0x4e,0x4(%esp)
c010494d:	00 
c010494e:	c7 04 24 df d1 10 c0 	movl   $0xc010d1df,(%esp)
c0104955:	e8 ab ba ff ff       	call   c0100405 <__panic>
     //将这一页的地址存储在ptr_page中
     *ptr_page = p;
c010495a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010495d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104960:	89 10                	mov    %edx,(%eax)
     return 0;
c0104962:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104967:	c9                   	leave  
c0104968:	c3                   	ret    

c0104969 <_fifo_check_swap>:

static int
_fifo_check_swap(void) {
c0104969:	55                   	push   %ebp
c010496a:	89 e5                	mov    %esp,%ebp
c010496c:	83 ec 18             	sub    $0x18,%esp
    cprintf("write Virt Page c in fifo_check_swap\n");
c010496f:	c7 04 24 20 d2 10 c0 	movl   $0xc010d220,(%esp)
c0104976:	e8 33 b9 ff ff       	call   c01002ae <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c010497b:	b8 00 30 00 00       	mov    $0x3000,%eax
c0104980:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==4);
c0104983:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c0104988:	83 f8 04             	cmp    $0x4,%eax
c010498b:	74 24                	je     c01049b1 <_fifo_check_swap+0x48>
c010498d:	c7 44 24 0c 46 d2 10 	movl   $0xc010d246,0xc(%esp)
c0104994:	c0 
c0104995:	c7 44 24 08 ca d1 10 	movl   $0xc010d1ca,0x8(%esp)
c010499c:	c0 
c010499d:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
c01049a4:	00 
c01049a5:	c7 04 24 df d1 10 c0 	movl   $0xc010d1df,(%esp)
c01049ac:	e8 54 ba ff ff       	call   c0100405 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c01049b1:	c7 04 24 58 d2 10 c0 	movl   $0xc010d258,(%esp)
c01049b8:	e8 f1 b8 ff ff       	call   c01002ae <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c01049bd:	b8 00 10 00 00       	mov    $0x1000,%eax
c01049c2:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==4);
c01049c5:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c01049ca:	83 f8 04             	cmp    $0x4,%eax
c01049cd:	74 24                	je     c01049f3 <_fifo_check_swap+0x8a>
c01049cf:	c7 44 24 0c 46 d2 10 	movl   $0xc010d246,0xc(%esp)
c01049d6:	c0 
c01049d7:	c7 44 24 08 ca d1 10 	movl   $0xc010d1ca,0x8(%esp)
c01049de:	c0 
c01049df:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c01049e6:	00 
c01049e7:	c7 04 24 df d1 10 c0 	movl   $0xc010d1df,(%esp)
c01049ee:	e8 12 ba ff ff       	call   c0100405 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c01049f3:	c7 04 24 80 d2 10 c0 	movl   $0xc010d280,(%esp)
c01049fa:	e8 af b8 ff ff       	call   c01002ae <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c01049ff:	b8 00 40 00 00       	mov    $0x4000,%eax
c0104a04:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==4);
c0104a07:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c0104a0c:	83 f8 04             	cmp    $0x4,%eax
c0104a0f:	74 24                	je     c0104a35 <_fifo_check_swap+0xcc>
c0104a11:	c7 44 24 0c 46 d2 10 	movl   $0xc010d246,0xc(%esp)
c0104a18:	c0 
c0104a19:	c7 44 24 08 ca d1 10 	movl   $0xc010d1ca,0x8(%esp)
c0104a20:	c0 
c0104a21:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0104a28:	00 
c0104a29:	c7 04 24 df d1 10 c0 	movl   $0xc010d1df,(%esp)
c0104a30:	e8 d0 b9 ff ff       	call   c0100405 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0104a35:	c7 04 24 a8 d2 10 c0 	movl   $0xc010d2a8,(%esp)
c0104a3c:	e8 6d b8 ff ff       	call   c01002ae <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0104a41:	b8 00 20 00 00       	mov    $0x2000,%eax
c0104a46:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==4);
c0104a49:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c0104a4e:	83 f8 04             	cmp    $0x4,%eax
c0104a51:	74 24                	je     c0104a77 <_fifo_check_swap+0x10e>
c0104a53:	c7 44 24 0c 46 d2 10 	movl   $0xc010d246,0xc(%esp)
c0104a5a:	c0 
c0104a5b:	c7 44 24 08 ca d1 10 	movl   $0xc010d1ca,0x8(%esp)
c0104a62:	c0 
c0104a63:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c0104a6a:	00 
c0104a6b:	c7 04 24 df d1 10 c0 	movl   $0xc010d1df,(%esp)
c0104a72:	e8 8e b9 ff ff       	call   c0100405 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0104a77:	c7 04 24 d0 d2 10 c0 	movl   $0xc010d2d0,(%esp)
c0104a7e:	e8 2b b8 ff ff       	call   c01002ae <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0104a83:	b8 00 50 00 00       	mov    $0x5000,%eax
c0104a88:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==5);
c0104a8b:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c0104a90:	83 f8 05             	cmp    $0x5,%eax
c0104a93:	74 24                	je     c0104ab9 <_fifo_check_swap+0x150>
c0104a95:	c7 44 24 0c f6 d2 10 	movl   $0xc010d2f6,0xc(%esp)
c0104a9c:	c0 
c0104a9d:	c7 44 24 08 ca d1 10 	movl   $0xc010d1ca,0x8(%esp)
c0104aa4:	c0 
c0104aa5:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0104aac:	00 
c0104aad:	c7 04 24 df d1 10 c0 	movl   $0xc010d1df,(%esp)
c0104ab4:	e8 4c b9 ff ff       	call   c0100405 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0104ab9:	c7 04 24 a8 d2 10 c0 	movl   $0xc010d2a8,(%esp)
c0104ac0:	e8 e9 b7 ff ff       	call   c01002ae <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0104ac5:	b8 00 20 00 00       	mov    $0x2000,%eax
c0104aca:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==5);
c0104acd:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c0104ad2:	83 f8 05             	cmp    $0x5,%eax
c0104ad5:	74 24                	je     c0104afb <_fifo_check_swap+0x192>
c0104ad7:	c7 44 24 0c f6 d2 10 	movl   $0xc010d2f6,0xc(%esp)
c0104ade:	c0 
c0104adf:	c7 44 24 08 ca d1 10 	movl   $0xc010d1ca,0x8(%esp)
c0104ae6:	c0 
c0104ae7:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c0104aee:	00 
c0104aef:	c7 04 24 df d1 10 c0 	movl   $0xc010d1df,(%esp)
c0104af6:	e8 0a b9 ff ff       	call   c0100405 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0104afb:	c7 04 24 58 d2 10 c0 	movl   $0xc010d258,(%esp)
c0104b02:	e8 a7 b7 ff ff       	call   c01002ae <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0104b07:	b8 00 10 00 00       	mov    $0x1000,%eax
c0104b0c:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==6);
c0104b0f:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c0104b14:	83 f8 06             	cmp    $0x6,%eax
c0104b17:	74 24                	je     c0104b3d <_fifo_check_swap+0x1d4>
c0104b19:	c7 44 24 0c 05 d3 10 	movl   $0xc010d305,0xc(%esp)
c0104b20:	c0 
c0104b21:	c7 44 24 08 ca d1 10 	movl   $0xc010d1ca,0x8(%esp)
c0104b28:	c0 
c0104b29:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c0104b30:	00 
c0104b31:	c7 04 24 df d1 10 c0 	movl   $0xc010d1df,(%esp)
c0104b38:	e8 c8 b8 ff ff       	call   c0100405 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0104b3d:	c7 04 24 a8 d2 10 c0 	movl   $0xc010d2a8,(%esp)
c0104b44:	e8 65 b7 ff ff       	call   c01002ae <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0104b49:	b8 00 20 00 00       	mov    $0x2000,%eax
c0104b4e:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==7);
c0104b51:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c0104b56:	83 f8 07             	cmp    $0x7,%eax
c0104b59:	74 24                	je     c0104b7f <_fifo_check_swap+0x216>
c0104b5b:	c7 44 24 0c 14 d3 10 	movl   $0xc010d314,0xc(%esp)
c0104b62:	c0 
c0104b63:	c7 44 24 08 ca d1 10 	movl   $0xc010d1ca,0x8(%esp)
c0104b6a:	c0 
c0104b6b:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0104b72:	00 
c0104b73:	c7 04 24 df d1 10 c0 	movl   $0xc010d1df,(%esp)
c0104b7a:	e8 86 b8 ff ff       	call   c0100405 <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c0104b7f:	c7 04 24 20 d2 10 c0 	movl   $0xc010d220,(%esp)
c0104b86:	e8 23 b7 ff ff       	call   c01002ae <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0104b8b:	b8 00 30 00 00       	mov    $0x3000,%eax
c0104b90:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==8);
c0104b93:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c0104b98:	83 f8 08             	cmp    $0x8,%eax
c0104b9b:	74 24                	je     c0104bc1 <_fifo_check_swap+0x258>
c0104b9d:	c7 44 24 0c 23 d3 10 	movl   $0xc010d323,0xc(%esp)
c0104ba4:	c0 
c0104ba5:	c7 44 24 08 ca d1 10 	movl   $0xc010d1ca,0x8(%esp)
c0104bac:	c0 
c0104bad:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0104bb4:	00 
c0104bb5:	c7 04 24 df d1 10 c0 	movl   $0xc010d1df,(%esp)
c0104bbc:	e8 44 b8 ff ff       	call   c0100405 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0104bc1:	c7 04 24 80 d2 10 c0 	movl   $0xc010d280,(%esp)
c0104bc8:	e8 e1 b6 ff ff       	call   c01002ae <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0104bcd:	b8 00 40 00 00       	mov    $0x4000,%eax
c0104bd2:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==9);
c0104bd5:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c0104bda:	83 f8 09             	cmp    $0x9,%eax
c0104bdd:	74 24                	je     c0104c03 <_fifo_check_swap+0x29a>
c0104bdf:	c7 44 24 0c 32 d3 10 	movl   $0xc010d332,0xc(%esp)
c0104be6:	c0 
c0104be7:	c7 44 24 08 ca d1 10 	movl   $0xc010d1ca,0x8(%esp)
c0104bee:	c0 
c0104bef:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
c0104bf6:	00 
c0104bf7:	c7 04 24 df d1 10 c0 	movl   $0xc010d1df,(%esp)
c0104bfe:	e8 02 b8 ff ff       	call   c0100405 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0104c03:	c7 04 24 d0 d2 10 c0 	movl   $0xc010d2d0,(%esp)
c0104c0a:	e8 9f b6 ff ff       	call   c01002ae <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0104c0f:	b8 00 50 00 00       	mov    $0x5000,%eax
c0104c14:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==10);
c0104c17:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c0104c1c:	83 f8 0a             	cmp    $0xa,%eax
c0104c1f:	74 24                	je     c0104c45 <_fifo_check_swap+0x2dc>
c0104c21:	c7 44 24 0c 41 d3 10 	movl   $0xc010d341,0xc(%esp)
c0104c28:	c0 
c0104c29:	c7 44 24 08 ca d1 10 	movl   $0xc010d1ca,0x8(%esp)
c0104c30:	c0 
c0104c31:	c7 44 24 04 76 00 00 	movl   $0x76,0x4(%esp)
c0104c38:	00 
c0104c39:	c7 04 24 df d1 10 c0 	movl   $0xc010d1df,(%esp)
c0104c40:	e8 c0 b7 ff ff       	call   c0100405 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0104c45:	c7 04 24 58 d2 10 c0 	movl   $0xc010d258,(%esp)
c0104c4c:	e8 5d b6 ff ff       	call   c01002ae <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
c0104c51:	b8 00 10 00 00       	mov    $0x1000,%eax
c0104c56:	0f b6 00             	movzbl (%eax),%eax
c0104c59:	3c 0a                	cmp    $0xa,%al
c0104c5b:	74 24                	je     c0104c81 <_fifo_check_swap+0x318>
c0104c5d:	c7 44 24 0c 54 d3 10 	movl   $0xc010d354,0xc(%esp)
c0104c64:	c0 
c0104c65:	c7 44 24 08 ca d1 10 	movl   $0xc010d1ca,0x8(%esp)
c0104c6c:	c0 
c0104c6d:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
c0104c74:	00 
c0104c75:	c7 04 24 df d1 10 c0 	movl   $0xc010d1df,(%esp)
c0104c7c:	e8 84 b7 ff ff       	call   c0100405 <__panic>
    *(unsigned char *)0x1000 = 0x0a;
c0104c81:	b8 00 10 00 00       	mov    $0x1000,%eax
c0104c86:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==11);
c0104c89:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c0104c8e:	83 f8 0b             	cmp    $0xb,%eax
c0104c91:	74 24                	je     c0104cb7 <_fifo_check_swap+0x34e>
c0104c93:	c7 44 24 0c 75 d3 10 	movl   $0xc010d375,0xc(%esp)
c0104c9a:	c0 
c0104c9b:	c7 44 24 08 ca d1 10 	movl   $0xc010d1ca,0x8(%esp)
c0104ca2:	c0 
c0104ca3:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
c0104caa:	00 
c0104cab:	c7 04 24 df d1 10 c0 	movl   $0xc010d1df,(%esp)
c0104cb2:	e8 4e b7 ff ff       	call   c0100405 <__panic>
    return 0;
c0104cb7:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104cbc:	c9                   	leave  
c0104cbd:	c3                   	ret    

c0104cbe <_fifo_init>:


static int
_fifo_init(void)
{
c0104cbe:	55                   	push   %ebp
c0104cbf:	89 e5                	mov    %esp,%ebp
    return 0;
c0104cc1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104cc6:	5d                   	pop    %ebp
c0104cc7:	c3                   	ret    

c0104cc8 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c0104cc8:	55                   	push   %ebp
c0104cc9:	89 e5                	mov    %esp,%ebp
    return 0;
c0104ccb:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104cd0:	5d                   	pop    %ebp
c0104cd1:	c3                   	ret    

c0104cd2 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
c0104cd2:	55                   	push   %ebp
c0104cd3:	89 e5                	mov    %esp,%ebp
c0104cd5:	b8 00 00 00 00       	mov    $0x0,%eax
c0104cda:	5d                   	pop    %ebp
c0104cdb:	c3                   	ret    

c0104cdc <__intr_save>:
__intr_save(void) {
c0104cdc:	55                   	push   %ebp
c0104cdd:	89 e5                	mov    %esp,%ebp
c0104cdf:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0104ce2:	9c                   	pushf  
c0104ce3:	58                   	pop    %eax
c0104ce4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0104ce7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0104cea:	25 00 02 00 00       	and    $0x200,%eax
c0104cef:	85 c0                	test   %eax,%eax
c0104cf1:	74 0c                	je     c0104cff <__intr_save+0x23>
        intr_disable();
c0104cf3:	e8 22 d5 ff ff       	call   c010221a <intr_disable>
        return 1;
c0104cf8:	b8 01 00 00 00       	mov    $0x1,%eax
c0104cfd:	eb 05                	jmp    c0104d04 <__intr_save+0x28>
    return 0;
c0104cff:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104d04:	c9                   	leave  
c0104d05:	c3                   	ret    

c0104d06 <__intr_restore>:
__intr_restore(bool flag) {
c0104d06:	55                   	push   %ebp
c0104d07:	89 e5                	mov    %esp,%ebp
c0104d09:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0104d0c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104d10:	74 05                	je     c0104d17 <__intr_restore+0x11>
        intr_enable();
c0104d12:	e8 fd d4 ff ff       	call   c0102214 <intr_enable>
}
c0104d17:	c9                   	leave  
c0104d18:	c3                   	ret    

c0104d19 <page2ppn>:
page2ppn(struct Page *page) {
c0104d19:	55                   	push   %ebp
c0104d1a:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0104d1c:	8b 55 08             	mov    0x8(%ebp),%edx
c0104d1f:	a1 78 31 1b c0       	mov    0xc01b3178,%eax
c0104d24:	29 c2                	sub    %eax,%edx
c0104d26:	89 d0                	mov    %edx,%eax
c0104d28:	c1 f8 05             	sar    $0x5,%eax
}
c0104d2b:	5d                   	pop    %ebp
c0104d2c:	c3                   	ret    

c0104d2d <page2pa>:
page2pa(struct Page *page) {
c0104d2d:	55                   	push   %ebp
c0104d2e:	89 e5                	mov    %esp,%ebp
c0104d30:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0104d33:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d36:	89 04 24             	mov    %eax,(%esp)
c0104d39:	e8 db ff ff ff       	call   c0104d19 <page2ppn>
c0104d3e:	c1 e0 0c             	shl    $0xc,%eax
}
c0104d41:	c9                   	leave  
c0104d42:	c3                   	ret    

c0104d43 <pa2page>:
pa2page(uintptr_t pa) {
c0104d43:	55                   	push   %ebp
c0104d44:	89 e5                	mov    %esp,%ebp
c0104d46:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0104d49:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d4c:	c1 e8 0c             	shr    $0xc,%eax
c0104d4f:	89 c2                	mov    %eax,%edx
c0104d51:	a1 80 0f 1b c0       	mov    0xc01b0f80,%eax
c0104d56:	39 c2                	cmp    %eax,%edx
c0104d58:	72 1c                	jb     c0104d76 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0104d5a:	c7 44 24 08 98 d3 10 	movl   $0xc010d398,0x8(%esp)
c0104d61:	c0 
c0104d62:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0104d69:	00 
c0104d6a:	c7 04 24 b7 d3 10 c0 	movl   $0xc010d3b7,(%esp)
c0104d71:	e8 8f b6 ff ff       	call   c0100405 <__panic>
    return &pages[PPN(pa)];
c0104d76:	a1 78 31 1b c0       	mov    0xc01b3178,%eax
c0104d7b:	8b 55 08             	mov    0x8(%ebp),%edx
c0104d7e:	c1 ea 0c             	shr    $0xc,%edx
c0104d81:	c1 e2 05             	shl    $0x5,%edx
c0104d84:	01 d0                	add    %edx,%eax
}
c0104d86:	c9                   	leave  
c0104d87:	c3                   	ret    

c0104d88 <page2kva>:
page2kva(struct Page *page) {
c0104d88:	55                   	push   %ebp
c0104d89:	89 e5                	mov    %esp,%ebp
c0104d8b:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0104d8e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d91:	89 04 24             	mov    %eax,(%esp)
c0104d94:	e8 94 ff ff ff       	call   c0104d2d <page2pa>
c0104d99:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104d9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d9f:	c1 e8 0c             	shr    $0xc,%eax
c0104da2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104da5:	a1 80 0f 1b c0       	mov    0xc01b0f80,%eax
c0104daa:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104dad:	72 23                	jb     c0104dd2 <page2kva+0x4a>
c0104daf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104db2:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104db6:	c7 44 24 08 c8 d3 10 	movl   $0xc010d3c8,0x8(%esp)
c0104dbd:	c0 
c0104dbe:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0104dc5:	00 
c0104dc6:	c7 04 24 b7 d3 10 c0 	movl   $0xc010d3b7,(%esp)
c0104dcd:	e8 33 b6 ff ff       	call   c0100405 <__panic>
c0104dd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104dd5:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0104dda:	c9                   	leave  
c0104ddb:	c3                   	ret    

c0104ddc <kva2page>:
kva2page(void *kva) {
c0104ddc:	55                   	push   %ebp
c0104ddd:	89 e5                	mov    %esp,%ebp
c0104ddf:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c0104de2:	8b 45 08             	mov    0x8(%ebp),%eax
c0104de5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104de8:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0104def:	77 23                	ja     c0104e14 <kva2page+0x38>
c0104df1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104df4:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104df8:	c7 44 24 08 ec d3 10 	movl   $0xc010d3ec,0x8(%esp)
c0104dff:	c0 
c0104e00:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c0104e07:	00 
c0104e08:	c7 04 24 b7 d3 10 c0 	movl   $0xc010d3b7,(%esp)
c0104e0f:	e8 f1 b5 ff ff       	call   c0100405 <__panic>
c0104e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e17:	05 00 00 00 40       	add    $0x40000000,%eax
c0104e1c:	89 04 24             	mov    %eax,(%esp)
c0104e1f:	e8 1f ff ff ff       	call   c0104d43 <pa2page>
}
c0104e24:	c9                   	leave  
c0104e25:	c3                   	ret    

c0104e26 <__slob_get_free_pages>:
static slob_t *slobfree = &arena;
static bigblock_t *bigblocks;


static void* __slob_get_free_pages(gfp_t gfp, int order)
{
c0104e26:	55                   	push   %ebp
c0104e27:	89 e5                	mov    %esp,%ebp
c0104e29:	83 ec 28             	sub    $0x28,%esp
  struct Page * page = alloc_pages(1 << order);
c0104e2c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104e2f:	ba 01 00 00 00       	mov    $0x1,%edx
c0104e34:	89 c1                	mov    %eax,%ecx
c0104e36:	d3 e2                	shl    %cl,%edx
c0104e38:	89 d0                	mov    %edx,%eax
c0104e3a:	89 04 24             	mov    %eax,(%esp)
c0104e3d:	e8 77 26 00 00       	call   c01074b9 <alloc_pages>
c0104e42:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!page)
c0104e45:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104e49:	75 07                	jne    c0104e52 <__slob_get_free_pages+0x2c>
    return NULL;
c0104e4b:	b8 00 00 00 00       	mov    $0x0,%eax
c0104e50:	eb 0b                	jmp    c0104e5d <__slob_get_free_pages+0x37>
  return page2kva(page);
c0104e52:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e55:	89 04 24             	mov    %eax,(%esp)
c0104e58:	e8 2b ff ff ff       	call   c0104d88 <page2kva>
}
c0104e5d:	c9                   	leave  
c0104e5e:	c3                   	ret    

c0104e5f <__slob_free_pages>:

#define __slob_get_free_page(gfp) __slob_get_free_pages(gfp, 0)

static inline void __slob_free_pages(unsigned long kva, int order)
{
c0104e5f:	55                   	push   %ebp
c0104e60:	89 e5                	mov    %esp,%ebp
c0104e62:	53                   	push   %ebx
c0104e63:	83 ec 14             	sub    $0x14,%esp
  free_pages(kva2page(kva), 1 << order);
c0104e66:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104e69:	ba 01 00 00 00       	mov    $0x1,%edx
c0104e6e:	89 c1                	mov    %eax,%ecx
c0104e70:	d3 e2                	shl    %cl,%edx
c0104e72:	89 d0                	mov    %edx,%eax
c0104e74:	89 c3                	mov    %eax,%ebx
c0104e76:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e79:	89 04 24             	mov    %eax,(%esp)
c0104e7c:	e8 5b ff ff ff       	call   c0104ddc <kva2page>
c0104e81:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0104e85:	89 04 24             	mov    %eax,(%esp)
c0104e88:	e8 97 26 00 00       	call   c0107524 <free_pages>
}
c0104e8d:	83 c4 14             	add    $0x14,%esp
c0104e90:	5b                   	pop    %ebx
c0104e91:	5d                   	pop    %ebp
c0104e92:	c3                   	ret    

c0104e93 <slob_alloc>:

static void slob_free(void *b, int size);

static void *slob_alloc(size_t size, gfp_t gfp, int align)
{
c0104e93:	55                   	push   %ebp
c0104e94:	89 e5                	mov    %esp,%ebp
c0104e96:	83 ec 38             	sub    $0x38,%esp
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
c0104e99:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e9c:	83 c0 08             	add    $0x8,%eax
c0104e9f:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c0104ea4:	76 24                	jbe    c0104eca <slob_alloc+0x37>
c0104ea6:	c7 44 24 0c 10 d4 10 	movl   $0xc010d410,0xc(%esp)
c0104ead:	c0 
c0104eae:	c7 44 24 08 2f d4 10 	movl   $0xc010d42f,0x8(%esp)
c0104eb5:	c0 
c0104eb6:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0104ebd:	00 
c0104ebe:	c7 04 24 44 d4 10 c0 	movl   $0xc010d444,(%esp)
c0104ec5:	e8 3b b5 ff ff       	call   c0100405 <__panic>

	slob_t *prev, *cur, *aligned = 0;
c0104eca:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	int delta = 0, units = SLOB_UNITS(size);
c0104ed1:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0104ed8:	8b 45 08             	mov    0x8(%ebp),%eax
c0104edb:	83 c0 07             	add    $0x7,%eax
c0104ede:	c1 e8 03             	shr    $0x3,%eax
c0104ee1:	89 45 e0             	mov    %eax,-0x20(%ebp)
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
c0104ee4:	e8 f3 fd ff ff       	call   c0104cdc <__intr_save>
c0104ee9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	prev = slobfree;
c0104eec:	a1 08 ca 12 c0       	mov    0xc012ca08,%eax
c0104ef1:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c0104ef4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ef7:	8b 40 04             	mov    0x4(%eax),%eax
c0104efa:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (align) {
c0104efd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0104f01:	74 25                	je     c0104f28 <slob_alloc+0x95>
			aligned = (slob_t *)ALIGN((unsigned long)cur, align);
c0104f03:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104f06:	8b 45 10             	mov    0x10(%ebp),%eax
c0104f09:	01 d0                	add    %edx,%eax
c0104f0b:	8d 50 ff             	lea    -0x1(%eax),%edx
c0104f0e:	8b 45 10             	mov    0x10(%ebp),%eax
c0104f11:	f7 d8                	neg    %eax
c0104f13:	21 d0                	and    %edx,%eax
c0104f15:	89 45 ec             	mov    %eax,-0x14(%ebp)
			delta = aligned - cur;
c0104f18:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104f1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f1e:	29 c2                	sub    %eax,%edx
c0104f20:	89 d0                	mov    %edx,%eax
c0104f22:	c1 f8 03             	sar    $0x3,%eax
c0104f25:	89 45 e8             	mov    %eax,-0x18(%ebp)
		}
		if (cur->units >= units + delta) { /* room enough? */
c0104f28:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f2b:	8b 00                	mov    (%eax),%eax
c0104f2d:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104f30:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0104f33:	01 ca                	add    %ecx,%edx
c0104f35:	39 d0                	cmp    %edx,%eax
c0104f37:	0f 8c aa 00 00 00    	jl     c0104fe7 <slob_alloc+0x154>
			if (delta) { /* need to fragment head to align? */
c0104f3d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104f41:	74 38                	je     c0104f7b <slob_alloc+0xe8>
				aligned->units = cur->units - delta;
c0104f43:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f46:	8b 00                	mov    (%eax),%eax
c0104f48:	2b 45 e8             	sub    -0x18(%ebp),%eax
c0104f4b:	89 c2                	mov    %eax,%edx
c0104f4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104f50:	89 10                	mov    %edx,(%eax)
				aligned->next = cur->next;
c0104f52:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f55:	8b 50 04             	mov    0x4(%eax),%edx
c0104f58:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104f5b:	89 50 04             	mov    %edx,0x4(%eax)
				cur->next = aligned;
c0104f5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f61:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104f64:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = delta;
c0104f67:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f6a:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104f6d:	89 10                	mov    %edx,(%eax)
				prev = cur;
c0104f6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f72:	89 45 f4             	mov    %eax,-0xc(%ebp)
				cur = aligned;
c0104f75:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104f78:	89 45 f0             	mov    %eax,-0x10(%ebp)
			}

			if (cur->units == units) /* exact fit? */
c0104f7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f7e:	8b 00                	mov    (%eax),%eax
c0104f80:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0104f83:	75 0e                	jne    c0104f93 <slob_alloc+0x100>
				prev->next = cur->next; /* unlink */
c0104f85:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f88:	8b 50 04             	mov    0x4(%eax),%edx
c0104f8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f8e:	89 50 04             	mov    %edx,0x4(%eax)
c0104f91:	eb 3c                	jmp    c0104fcf <slob_alloc+0x13c>
			else { /* fragment */
				prev->next = cur + units;
c0104f93:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104f96:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0104f9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104fa0:	01 c2                	add    %eax,%edx
c0104fa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104fa5:	89 50 04             	mov    %edx,0x4(%eax)
				prev->next->units = cur->units - units;
c0104fa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104fab:	8b 40 04             	mov    0x4(%eax),%eax
c0104fae:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104fb1:	8b 12                	mov    (%edx),%edx
c0104fb3:	2b 55 e0             	sub    -0x20(%ebp),%edx
c0104fb6:	89 10                	mov    %edx,(%eax)
				prev->next->next = cur->next;
c0104fb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104fbb:	8b 40 04             	mov    0x4(%eax),%eax
c0104fbe:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104fc1:	8b 52 04             	mov    0x4(%edx),%edx
c0104fc4:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = units;
c0104fc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104fca:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104fcd:	89 10                	mov    %edx,(%eax)
			}

			slobfree = prev;
c0104fcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104fd2:	a3 08 ca 12 c0       	mov    %eax,0xc012ca08
			spin_unlock_irqrestore(&slob_lock, flags);
c0104fd7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104fda:	89 04 24             	mov    %eax,(%esp)
c0104fdd:	e8 24 fd ff ff       	call   c0104d06 <__intr_restore>
			return cur;
c0104fe2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104fe5:	eb 7f                	jmp    c0105066 <slob_alloc+0x1d3>
		}
		if (cur == slobfree) {
c0104fe7:	a1 08 ca 12 c0       	mov    0xc012ca08,%eax
c0104fec:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104fef:	75 61                	jne    c0105052 <slob_alloc+0x1bf>
			spin_unlock_irqrestore(&slob_lock, flags);
c0104ff1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104ff4:	89 04 24             	mov    %eax,(%esp)
c0104ff7:	e8 0a fd ff ff       	call   c0104d06 <__intr_restore>

			if (size == PAGE_SIZE) /* trying to shrink arena? */
c0104ffc:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c0105003:	75 07                	jne    c010500c <slob_alloc+0x179>
				return 0;
c0105005:	b8 00 00 00 00       	mov    $0x0,%eax
c010500a:	eb 5a                	jmp    c0105066 <slob_alloc+0x1d3>

			cur = (slob_t *)__slob_get_free_page(gfp);
c010500c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105013:	00 
c0105014:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105017:	89 04 24             	mov    %eax,(%esp)
c010501a:	e8 07 fe ff ff       	call   c0104e26 <__slob_get_free_pages>
c010501f:	89 45 f0             	mov    %eax,-0x10(%ebp)
			if (!cur)
c0105022:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105026:	75 07                	jne    c010502f <slob_alloc+0x19c>
				return 0;
c0105028:	b8 00 00 00 00       	mov    $0x0,%eax
c010502d:	eb 37                	jmp    c0105066 <slob_alloc+0x1d3>

			slob_free(cur, PAGE_SIZE);
c010502f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0105036:	00 
c0105037:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010503a:	89 04 24             	mov    %eax,(%esp)
c010503d:	e8 26 00 00 00       	call   c0105068 <slob_free>
			spin_lock_irqsave(&slob_lock, flags);
c0105042:	e8 95 fc ff ff       	call   c0104cdc <__intr_save>
c0105047:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			cur = slobfree;
c010504a:	a1 08 ca 12 c0       	mov    0xc012ca08,%eax
c010504f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c0105052:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105055:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105058:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010505b:	8b 40 04             	mov    0x4(%eax),%eax
c010505e:	89 45 f0             	mov    %eax,-0x10(%ebp)
		}
	}
c0105061:	e9 97 fe ff ff       	jmp    c0104efd <slob_alloc+0x6a>
}
c0105066:	c9                   	leave  
c0105067:	c3                   	ret    

c0105068 <slob_free>:

static void slob_free(void *block, int size)
{
c0105068:	55                   	push   %ebp
c0105069:	89 e5                	mov    %esp,%ebp
c010506b:	83 ec 28             	sub    $0x28,%esp
	slob_t *cur, *b = (slob_t *)block;
c010506e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105071:	89 45 f0             	mov    %eax,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c0105074:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105078:	75 05                	jne    c010507f <slob_free+0x17>
		return;
c010507a:	e9 ff 00 00 00       	jmp    c010517e <slob_free+0x116>

	if (size)
c010507f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105083:	74 10                	je     c0105095 <slob_free+0x2d>
		b->units = SLOB_UNITS(size);
c0105085:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105088:	83 c0 07             	add    $0x7,%eax
c010508b:	c1 e8 03             	shr    $0x3,%eax
c010508e:	89 c2                	mov    %eax,%edx
c0105090:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105093:	89 10                	mov    %edx,(%eax)

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
c0105095:	e8 42 fc ff ff       	call   c0104cdc <__intr_save>
c010509a:	89 45 ec             	mov    %eax,-0x14(%ebp)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c010509d:	a1 08 ca 12 c0       	mov    0xc012ca08,%eax
c01050a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01050a5:	eb 27                	jmp    c01050ce <slob_free+0x66>
		if (cur >= cur->next && (b > cur || b < cur->next))
c01050a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050aa:	8b 40 04             	mov    0x4(%eax),%eax
c01050ad:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01050b0:	77 13                	ja     c01050c5 <slob_free+0x5d>
c01050b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01050b5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01050b8:	77 27                	ja     c01050e1 <slob_free+0x79>
c01050ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050bd:	8b 40 04             	mov    0x4(%eax),%eax
c01050c0:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01050c3:	77 1c                	ja     c01050e1 <slob_free+0x79>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c01050c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050c8:	8b 40 04             	mov    0x4(%eax),%eax
c01050cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01050ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01050d1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01050d4:	76 d1                	jbe    c01050a7 <slob_free+0x3f>
c01050d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050d9:	8b 40 04             	mov    0x4(%eax),%eax
c01050dc:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01050df:	76 c6                	jbe    c01050a7 <slob_free+0x3f>
			break;

	if (b + b->units == cur->next) {
c01050e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01050e4:	8b 00                	mov    (%eax),%eax
c01050e6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01050ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01050f0:	01 c2                	add    %eax,%edx
c01050f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050f5:	8b 40 04             	mov    0x4(%eax),%eax
c01050f8:	39 c2                	cmp    %eax,%edx
c01050fa:	75 25                	jne    c0105121 <slob_free+0xb9>
		b->units += cur->next->units;
c01050fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01050ff:	8b 10                	mov    (%eax),%edx
c0105101:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105104:	8b 40 04             	mov    0x4(%eax),%eax
c0105107:	8b 00                	mov    (%eax),%eax
c0105109:	01 c2                	add    %eax,%edx
c010510b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010510e:	89 10                	mov    %edx,(%eax)
		b->next = cur->next->next;
c0105110:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105113:	8b 40 04             	mov    0x4(%eax),%eax
c0105116:	8b 50 04             	mov    0x4(%eax),%edx
c0105119:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010511c:	89 50 04             	mov    %edx,0x4(%eax)
c010511f:	eb 0c                	jmp    c010512d <slob_free+0xc5>
	} else
		b->next = cur->next;
c0105121:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105124:	8b 50 04             	mov    0x4(%eax),%edx
c0105127:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010512a:	89 50 04             	mov    %edx,0x4(%eax)

	if (cur + cur->units == b) {
c010512d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105130:	8b 00                	mov    (%eax),%eax
c0105132:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0105139:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010513c:	01 d0                	add    %edx,%eax
c010513e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0105141:	75 1f                	jne    c0105162 <slob_free+0xfa>
		cur->units += b->units;
c0105143:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105146:	8b 10                	mov    (%eax),%edx
c0105148:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010514b:	8b 00                	mov    (%eax),%eax
c010514d:	01 c2                	add    %eax,%edx
c010514f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105152:	89 10                	mov    %edx,(%eax)
		cur->next = b->next;
c0105154:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105157:	8b 50 04             	mov    0x4(%eax),%edx
c010515a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010515d:	89 50 04             	mov    %edx,0x4(%eax)
c0105160:	eb 09                	jmp    c010516b <slob_free+0x103>
	} else
		cur->next = b;
c0105162:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105165:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105168:	89 50 04             	mov    %edx,0x4(%eax)

	slobfree = cur;
c010516b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010516e:	a3 08 ca 12 c0       	mov    %eax,0xc012ca08

	spin_unlock_irqrestore(&slob_lock, flags);
c0105173:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105176:	89 04 24             	mov    %eax,(%esp)
c0105179:	e8 88 fb ff ff       	call   c0104d06 <__intr_restore>
}
c010517e:	c9                   	leave  
c010517f:	c3                   	ret    

c0105180 <slob_init>:



void
slob_init(void) {
c0105180:	55                   	push   %ebp
c0105181:	89 e5                	mov    %esp,%ebp
c0105183:	83 ec 18             	sub    $0x18,%esp
  cprintf("use SLOB allocator\n");
c0105186:	c7 04 24 56 d4 10 c0 	movl   $0xc010d456,(%esp)
c010518d:	e8 1c b1 ff ff       	call   c01002ae <cprintf>
}
c0105192:	c9                   	leave  
c0105193:	c3                   	ret    

c0105194 <kmalloc_init>:

inline void 
kmalloc_init(void) {
c0105194:	55                   	push   %ebp
c0105195:	89 e5                	mov    %esp,%ebp
c0105197:	83 ec 18             	sub    $0x18,%esp
    slob_init();
c010519a:	e8 e1 ff ff ff       	call   c0105180 <slob_init>
    cprintf("kmalloc_init() succeeded!\n");
c010519f:	c7 04 24 6a d4 10 c0 	movl   $0xc010d46a,(%esp)
c01051a6:	e8 03 b1 ff ff       	call   c01002ae <cprintf>
}
c01051ab:	c9                   	leave  
c01051ac:	c3                   	ret    

c01051ad <slob_allocated>:

size_t
slob_allocated(void) {
c01051ad:	55                   	push   %ebp
c01051ae:	89 e5                	mov    %esp,%ebp
  return 0;
c01051b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01051b5:	5d                   	pop    %ebp
c01051b6:	c3                   	ret    

c01051b7 <kallocated>:

size_t
kallocated(void) {
c01051b7:	55                   	push   %ebp
c01051b8:	89 e5                	mov    %esp,%ebp
   return slob_allocated();
c01051ba:	e8 ee ff ff ff       	call   c01051ad <slob_allocated>
}
c01051bf:	5d                   	pop    %ebp
c01051c0:	c3                   	ret    

c01051c1 <find_order>:

static int find_order(int size)
{
c01051c1:	55                   	push   %ebp
c01051c2:	89 e5                	mov    %esp,%ebp
c01051c4:	83 ec 10             	sub    $0x10,%esp
	int order = 0;
c01051c7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c01051ce:	eb 07                	jmp    c01051d7 <find_order+0x16>
		order++;
c01051d0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c01051d4:	d1 7d 08             	sarl   0x8(%ebp)
c01051d7:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c01051de:	7f f0                	jg     c01051d0 <find_order+0xf>
	return order;
c01051e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01051e3:	c9                   	leave  
c01051e4:	c3                   	ret    

c01051e5 <__kmalloc>:

static void *__kmalloc(size_t size, gfp_t gfp)
{
c01051e5:	55                   	push   %ebp
c01051e6:	89 e5                	mov    %esp,%ebp
c01051e8:	83 ec 28             	sub    $0x28,%esp
	slob_t *m;
	bigblock_t *bb;
	unsigned long flags;

	if (size < PAGE_SIZE - SLOB_UNIT) {
c01051eb:	81 7d 08 f7 0f 00 00 	cmpl   $0xff7,0x8(%ebp)
c01051f2:	77 38                	ja     c010522c <__kmalloc+0x47>
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
c01051f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01051f7:	8d 50 08             	lea    0x8(%eax),%edx
c01051fa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105201:	00 
c0105202:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105205:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105209:	89 14 24             	mov    %edx,(%esp)
c010520c:	e8 82 fc ff ff       	call   c0104e93 <slob_alloc>
c0105211:	89 45 f4             	mov    %eax,-0xc(%ebp)
		return m ? (void *)(m + 1) : 0;
c0105214:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105218:	74 08                	je     c0105222 <__kmalloc+0x3d>
c010521a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010521d:	83 c0 08             	add    $0x8,%eax
c0105220:	eb 05                	jmp    c0105227 <__kmalloc+0x42>
c0105222:	b8 00 00 00 00       	mov    $0x0,%eax
c0105227:	e9 a6 00 00 00       	jmp    c01052d2 <__kmalloc+0xed>
	}

	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
c010522c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105233:	00 
c0105234:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105237:	89 44 24 04          	mov    %eax,0x4(%esp)
c010523b:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
c0105242:	e8 4c fc ff ff       	call   c0104e93 <slob_alloc>
c0105247:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (!bb)
c010524a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010524e:	75 07                	jne    c0105257 <__kmalloc+0x72>
		return 0;
c0105250:	b8 00 00 00 00       	mov    $0x0,%eax
c0105255:	eb 7b                	jmp    c01052d2 <__kmalloc+0xed>

	bb->order = find_order(size);
c0105257:	8b 45 08             	mov    0x8(%ebp),%eax
c010525a:	89 04 24             	mov    %eax,(%esp)
c010525d:	e8 5f ff ff ff       	call   c01051c1 <find_order>
c0105262:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105265:	89 02                	mov    %eax,(%edx)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
c0105267:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010526a:	8b 00                	mov    (%eax),%eax
c010526c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105270:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105273:	89 04 24             	mov    %eax,(%esp)
c0105276:	e8 ab fb ff ff       	call   c0104e26 <__slob_get_free_pages>
c010527b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010527e:	89 42 04             	mov    %eax,0x4(%edx)

	if (bb->pages) {
c0105281:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105284:	8b 40 04             	mov    0x4(%eax),%eax
c0105287:	85 c0                	test   %eax,%eax
c0105289:	74 2f                	je     c01052ba <__kmalloc+0xd5>
		spin_lock_irqsave(&block_lock, flags);
c010528b:	e8 4c fa ff ff       	call   c0104cdc <__intr_save>
c0105290:	89 45 ec             	mov    %eax,-0x14(%ebp)
		bb->next = bigblocks;
c0105293:	8b 15 68 0f 1b c0    	mov    0xc01b0f68,%edx
c0105299:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010529c:	89 50 08             	mov    %edx,0x8(%eax)
		bigblocks = bb;
c010529f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01052a2:	a3 68 0f 1b c0       	mov    %eax,0xc01b0f68
		spin_unlock_irqrestore(&block_lock, flags);
c01052a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01052aa:	89 04 24             	mov    %eax,(%esp)
c01052ad:	e8 54 fa ff ff       	call   c0104d06 <__intr_restore>
		return bb->pages;
c01052b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01052b5:	8b 40 04             	mov    0x4(%eax),%eax
c01052b8:	eb 18                	jmp    c01052d2 <__kmalloc+0xed>
	}

	slob_free(bb, sizeof(bigblock_t));
c01052ba:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c01052c1:	00 
c01052c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01052c5:	89 04 24             	mov    %eax,(%esp)
c01052c8:	e8 9b fd ff ff       	call   c0105068 <slob_free>
	return 0;
c01052cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01052d2:	c9                   	leave  
c01052d3:	c3                   	ret    

c01052d4 <kmalloc>:

void *
kmalloc(size_t size)
{
c01052d4:	55                   	push   %ebp
c01052d5:	89 e5                	mov    %esp,%ebp
c01052d7:	83 ec 18             	sub    $0x18,%esp
  return __kmalloc(size, 0);
c01052da:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01052e1:	00 
c01052e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01052e5:	89 04 24             	mov    %eax,(%esp)
c01052e8:	e8 f8 fe ff ff       	call   c01051e5 <__kmalloc>
}
c01052ed:	c9                   	leave  
c01052ee:	c3                   	ret    

c01052ef <kfree>:


void kfree(void *block)
{
c01052ef:	55                   	push   %ebp
c01052f0:	89 e5                	mov    %esp,%ebp
c01052f2:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb, **last = &bigblocks;
c01052f5:	c7 45 f0 68 0f 1b c0 	movl   $0xc01b0f68,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c01052fc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105300:	75 05                	jne    c0105307 <kfree+0x18>
		return;
c0105302:	e9 a2 00 00 00       	jmp    c01053a9 <kfree+0xba>

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0105307:	8b 45 08             	mov    0x8(%ebp),%eax
c010530a:	25 ff 0f 00 00       	and    $0xfff,%eax
c010530f:	85 c0                	test   %eax,%eax
c0105311:	75 7f                	jne    c0105392 <kfree+0xa3>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
c0105313:	e8 c4 f9 ff ff       	call   c0104cdc <__intr_save>
c0105318:	89 45 ec             	mov    %eax,-0x14(%ebp)
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c010531b:	a1 68 0f 1b c0       	mov    0xc01b0f68,%eax
c0105320:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105323:	eb 5c                	jmp    c0105381 <kfree+0x92>
			if (bb->pages == block) {
c0105325:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105328:	8b 40 04             	mov    0x4(%eax),%eax
c010532b:	3b 45 08             	cmp    0x8(%ebp),%eax
c010532e:	75 3f                	jne    c010536f <kfree+0x80>
				*last = bb->next;
c0105330:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105333:	8b 50 08             	mov    0x8(%eax),%edx
c0105336:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105339:	89 10                	mov    %edx,(%eax)
				spin_unlock_irqrestore(&block_lock, flags);
c010533b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010533e:	89 04 24             	mov    %eax,(%esp)
c0105341:	e8 c0 f9 ff ff       	call   c0104d06 <__intr_restore>
				__slob_free_pages((unsigned long)block, bb->order);
c0105346:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105349:	8b 10                	mov    (%eax),%edx
c010534b:	8b 45 08             	mov    0x8(%ebp),%eax
c010534e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105352:	89 04 24             	mov    %eax,(%esp)
c0105355:	e8 05 fb ff ff       	call   c0104e5f <__slob_free_pages>
				slob_free(bb, sizeof(bigblock_t));
c010535a:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c0105361:	00 
c0105362:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105365:	89 04 24             	mov    %eax,(%esp)
c0105368:	e8 fb fc ff ff       	call   c0105068 <slob_free>
				return;
c010536d:	eb 3a                	jmp    c01053a9 <kfree+0xba>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c010536f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105372:	83 c0 08             	add    $0x8,%eax
c0105375:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105378:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010537b:	8b 40 08             	mov    0x8(%eax),%eax
c010537e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105381:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105385:	75 9e                	jne    c0105325 <kfree+0x36>
			}
		}
		spin_unlock_irqrestore(&block_lock, flags);
c0105387:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010538a:	89 04 24             	mov    %eax,(%esp)
c010538d:	e8 74 f9 ff ff       	call   c0104d06 <__intr_restore>
	}

	slob_free((slob_t *)block - 1, 0);
c0105392:	8b 45 08             	mov    0x8(%ebp),%eax
c0105395:	83 e8 08             	sub    $0x8,%eax
c0105398:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010539f:	00 
c01053a0:	89 04 24             	mov    %eax,(%esp)
c01053a3:	e8 c0 fc ff ff       	call   c0105068 <slob_free>
	return;
c01053a8:	90                   	nop
}
c01053a9:	c9                   	leave  
c01053aa:	c3                   	ret    

c01053ab <ksize>:


unsigned int ksize(const void *block)
{
c01053ab:	55                   	push   %ebp
c01053ac:	89 e5                	mov    %esp,%ebp
c01053ae:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb;
	unsigned long flags;

	if (!block)
c01053b1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01053b5:	75 07                	jne    c01053be <ksize+0x13>
		return 0;
c01053b7:	b8 00 00 00 00       	mov    $0x0,%eax
c01053bc:	eb 6b                	jmp    c0105429 <ksize+0x7e>

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c01053be:	8b 45 08             	mov    0x8(%ebp),%eax
c01053c1:	25 ff 0f 00 00       	and    $0xfff,%eax
c01053c6:	85 c0                	test   %eax,%eax
c01053c8:	75 54                	jne    c010541e <ksize+0x73>
		spin_lock_irqsave(&block_lock, flags);
c01053ca:	e8 0d f9 ff ff       	call   c0104cdc <__intr_save>
c01053cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
		for (bb = bigblocks; bb; bb = bb->next)
c01053d2:	a1 68 0f 1b c0       	mov    0xc01b0f68,%eax
c01053d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01053da:	eb 31                	jmp    c010540d <ksize+0x62>
			if (bb->pages == block) {
c01053dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01053df:	8b 40 04             	mov    0x4(%eax),%eax
c01053e2:	3b 45 08             	cmp    0x8(%ebp),%eax
c01053e5:	75 1d                	jne    c0105404 <ksize+0x59>
				spin_unlock_irqrestore(&slob_lock, flags);
c01053e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01053ea:	89 04 24             	mov    %eax,(%esp)
c01053ed:	e8 14 f9 ff ff       	call   c0104d06 <__intr_restore>
				return PAGE_SIZE << bb->order;
c01053f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01053f5:	8b 00                	mov    (%eax),%eax
c01053f7:	ba 00 10 00 00       	mov    $0x1000,%edx
c01053fc:	89 c1                	mov    %eax,%ecx
c01053fe:	d3 e2                	shl    %cl,%edx
c0105400:	89 d0                	mov    %edx,%eax
c0105402:	eb 25                	jmp    c0105429 <ksize+0x7e>
		for (bb = bigblocks; bb; bb = bb->next)
c0105404:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105407:	8b 40 08             	mov    0x8(%eax),%eax
c010540a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010540d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105411:	75 c9                	jne    c01053dc <ksize+0x31>
			}
		spin_unlock_irqrestore(&block_lock, flags);
c0105413:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105416:	89 04 24             	mov    %eax,(%esp)
c0105419:	e8 e8 f8 ff ff       	call   c0104d06 <__intr_restore>
	}

	return ((slob_t *)block - 1)->units * SLOB_UNIT;
c010541e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105421:	83 e8 08             	sub    $0x8,%eax
c0105424:	8b 00                	mov    (%eax),%eax
c0105426:	c1 e0 03             	shl    $0x3,%eax
}
c0105429:	c9                   	leave  
c010542a:	c3                   	ret    

c010542b <pa2page>:
pa2page(uintptr_t pa) {
c010542b:	55                   	push   %ebp
c010542c:	89 e5                	mov    %esp,%ebp
c010542e:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0105431:	8b 45 08             	mov    0x8(%ebp),%eax
c0105434:	c1 e8 0c             	shr    $0xc,%eax
c0105437:	89 c2                	mov    %eax,%edx
c0105439:	a1 80 0f 1b c0       	mov    0xc01b0f80,%eax
c010543e:	39 c2                	cmp    %eax,%edx
c0105440:	72 1c                	jb     c010545e <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0105442:	c7 44 24 08 88 d4 10 	movl   $0xc010d488,0x8(%esp)
c0105449:	c0 
c010544a:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0105451:	00 
c0105452:	c7 04 24 a7 d4 10 c0 	movl   $0xc010d4a7,(%esp)
c0105459:	e8 a7 af ff ff       	call   c0100405 <__panic>
    return &pages[PPN(pa)];
c010545e:	a1 78 31 1b c0       	mov    0xc01b3178,%eax
c0105463:	8b 55 08             	mov    0x8(%ebp),%edx
c0105466:	c1 ea 0c             	shr    $0xc,%edx
c0105469:	c1 e2 05             	shl    $0x5,%edx
c010546c:	01 d0                	add    %edx,%eax
}
c010546e:	c9                   	leave  
c010546f:	c3                   	ret    

c0105470 <pte2page>:
pte2page(pte_t pte) {
c0105470:	55                   	push   %ebp
c0105471:	89 e5                	mov    %esp,%ebp
c0105473:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0105476:	8b 45 08             	mov    0x8(%ebp),%eax
c0105479:	83 e0 01             	and    $0x1,%eax
c010547c:	85 c0                	test   %eax,%eax
c010547e:	75 1c                	jne    c010549c <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0105480:	c7 44 24 08 b8 d4 10 	movl   $0xc010d4b8,0x8(%esp)
c0105487:	c0 
c0105488:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c010548f:	00 
c0105490:	c7 04 24 a7 d4 10 c0 	movl   $0xc010d4a7,(%esp)
c0105497:	e8 69 af ff ff       	call   c0100405 <__panic>
    return pa2page(PTE_ADDR(pte));
c010549c:	8b 45 08             	mov    0x8(%ebp),%eax
c010549f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01054a4:	89 04 24             	mov    %eax,(%esp)
c01054a7:	e8 7f ff ff ff       	call   c010542b <pa2page>
}
c01054ac:	c9                   	leave  
c01054ad:	c3                   	ret    

c01054ae <pde2page>:
pde2page(pde_t pde) {
c01054ae:	55                   	push   %ebp
c01054af:	89 e5                	mov    %esp,%ebp
c01054b1:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c01054b4:	8b 45 08             	mov    0x8(%ebp),%eax
c01054b7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01054bc:	89 04 24             	mov    %eax,(%esp)
c01054bf:	e8 67 ff ff ff       	call   c010542b <pa2page>
}
c01054c4:	c9                   	leave  
c01054c5:	c3                   	ret    

c01054c6 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
c01054c6:	55                   	push   %ebp
c01054c7:	89 e5                	mov    %esp,%ebp
c01054c9:	83 ec 28             	sub    $0x28,%esp
     swapfs_init();
c01054cc:	e8 42 3c 00 00       	call   c0109113 <swapfs_init>

     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
c01054d1:	a1 3c 31 1b c0       	mov    0xc01b313c,%eax
c01054d6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
c01054db:	76 0c                	jbe    c01054e9 <swap_init+0x23>
c01054dd:	a1 3c 31 1b c0       	mov    0xc01b313c,%eax
c01054e2:	3d ff ff ff 00       	cmp    $0xffffff,%eax
c01054e7:	76 25                	jbe    c010550e <swap_init+0x48>
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
c01054e9:	a1 3c 31 1b c0       	mov    0xc01b313c,%eax
c01054ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01054f2:	c7 44 24 08 d9 d4 10 	movl   $0xc010d4d9,0x8(%esp)
c01054f9:	c0 
c01054fa:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
c0105501:	00 
c0105502:	c7 04 24 f4 d4 10 c0 	movl   $0xc010d4f4,(%esp)
c0105509:	e8 f7 ae ff ff       	call   c0100405 <__panic>
     }
     

     sm = &swap_manager_fifo;
c010550e:	c7 05 74 0f 1b c0 e0 	movl   $0xc012c9e0,0xc01b0f74
c0105515:	c9 12 c0 
     int r = sm->init();
c0105518:	a1 74 0f 1b c0       	mov    0xc01b0f74,%eax
c010551d:	8b 40 04             	mov    0x4(%eax),%eax
c0105520:	ff d0                	call   *%eax
c0105522:	89 45 f4             	mov    %eax,-0xc(%ebp)
     
     if (r == 0)
c0105525:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105529:	75 26                	jne    c0105551 <swap_init+0x8b>
     {
          swap_init_ok = 1;
c010552b:	c7 05 6c 0f 1b c0 01 	movl   $0x1,0xc01b0f6c
c0105532:	00 00 00 
          cprintf("SWAP: manager = %s\n", sm->name);
c0105535:	a1 74 0f 1b c0       	mov    0xc01b0f74,%eax
c010553a:	8b 00                	mov    (%eax),%eax
c010553c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105540:	c7 04 24 03 d5 10 c0 	movl   $0xc010d503,(%esp)
c0105547:	e8 62 ad ff ff       	call   c01002ae <cprintf>
          check_swap();
c010554c:	e8 a4 04 00 00       	call   c01059f5 <check_swap>
     }

     return r;
c0105551:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105554:	c9                   	leave  
c0105555:	c3                   	ret    

c0105556 <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
c0105556:	55                   	push   %ebp
c0105557:	89 e5                	mov    %esp,%ebp
c0105559:	83 ec 18             	sub    $0x18,%esp
     return sm->init_mm(mm);
c010555c:	a1 74 0f 1b c0       	mov    0xc01b0f74,%eax
c0105561:	8b 40 08             	mov    0x8(%eax),%eax
c0105564:	8b 55 08             	mov    0x8(%ebp),%edx
c0105567:	89 14 24             	mov    %edx,(%esp)
c010556a:	ff d0                	call   *%eax
}
c010556c:	c9                   	leave  
c010556d:	c3                   	ret    

c010556e <swap_tick_event>:

int
swap_tick_event(struct mm_struct *mm)
{
c010556e:	55                   	push   %ebp
c010556f:	89 e5                	mov    %esp,%ebp
c0105571:	83 ec 18             	sub    $0x18,%esp
     return sm->tick_event(mm);
c0105574:	a1 74 0f 1b c0       	mov    0xc01b0f74,%eax
c0105579:	8b 40 0c             	mov    0xc(%eax),%eax
c010557c:	8b 55 08             	mov    0x8(%ebp),%edx
c010557f:	89 14 24             	mov    %edx,(%esp)
c0105582:	ff d0                	call   *%eax
}
c0105584:	c9                   	leave  
c0105585:	c3                   	ret    

c0105586 <swap_map_swappable>:

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0105586:	55                   	push   %ebp
c0105587:	89 e5                	mov    %esp,%ebp
c0105589:	83 ec 18             	sub    $0x18,%esp
     return sm->map_swappable(mm, addr, page, swap_in);
c010558c:	a1 74 0f 1b c0       	mov    0xc01b0f74,%eax
c0105591:	8b 40 10             	mov    0x10(%eax),%eax
c0105594:	8b 55 14             	mov    0x14(%ebp),%edx
c0105597:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010559b:	8b 55 10             	mov    0x10(%ebp),%edx
c010559e:	89 54 24 08          	mov    %edx,0x8(%esp)
c01055a2:	8b 55 0c             	mov    0xc(%ebp),%edx
c01055a5:	89 54 24 04          	mov    %edx,0x4(%esp)
c01055a9:	8b 55 08             	mov    0x8(%ebp),%edx
c01055ac:	89 14 24             	mov    %edx,(%esp)
c01055af:	ff d0                	call   *%eax
}
c01055b1:	c9                   	leave  
c01055b2:	c3                   	ret    

c01055b3 <swap_set_unswappable>:

int
swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c01055b3:	55                   	push   %ebp
c01055b4:	89 e5                	mov    %esp,%ebp
c01055b6:	83 ec 18             	sub    $0x18,%esp
     return sm->set_unswappable(mm, addr);
c01055b9:	a1 74 0f 1b c0       	mov    0xc01b0f74,%eax
c01055be:	8b 40 14             	mov    0x14(%eax),%eax
c01055c1:	8b 55 0c             	mov    0xc(%ebp),%edx
c01055c4:	89 54 24 04          	mov    %edx,0x4(%esp)
c01055c8:	8b 55 08             	mov    0x8(%ebp),%edx
c01055cb:	89 14 24             	mov    %edx,(%esp)
c01055ce:	ff d0                	call   *%eax
}
c01055d0:	c9                   	leave  
c01055d1:	c3                   	ret    

c01055d2 <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
c01055d2:	55                   	push   %ebp
c01055d3:	89 e5                	mov    %esp,%ebp
c01055d5:	83 ec 38             	sub    $0x38,%esp
     int i;
     for (i = 0; i != n; ++ i)
c01055d8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01055df:	e9 5a 01 00 00       	jmp    c010573e <swap_out+0x16c>
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
c01055e4:	a1 74 0f 1b c0       	mov    0xc01b0f74,%eax
c01055e9:	8b 40 18             	mov    0x18(%eax),%eax
c01055ec:	8b 55 10             	mov    0x10(%ebp),%edx
c01055ef:	89 54 24 08          	mov    %edx,0x8(%esp)
c01055f3:	8d 55 e4             	lea    -0x1c(%ebp),%edx
c01055f6:	89 54 24 04          	mov    %edx,0x4(%esp)
c01055fa:	8b 55 08             	mov    0x8(%ebp),%edx
c01055fd:	89 14 24             	mov    %edx,(%esp)
c0105600:	ff d0                	call   *%eax
c0105602:	89 45 f0             	mov    %eax,-0x10(%ebp)
          if (r != 0) {
c0105605:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105609:	74 18                	je     c0105623 <swap_out+0x51>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
c010560b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010560e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105612:	c7 04 24 18 d5 10 c0 	movl   $0xc010d518,(%esp)
c0105619:	e8 90 ac ff ff       	call   c01002ae <cprintf>
c010561e:	e9 27 01 00 00       	jmp    c010574a <swap_out+0x178>
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
c0105623:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105626:	8b 40 1c             	mov    0x1c(%eax),%eax
c0105629:	89 45 ec             	mov    %eax,-0x14(%ebp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
c010562c:	8b 45 08             	mov    0x8(%ebp),%eax
c010562f:	8b 40 0c             	mov    0xc(%eax),%eax
c0105632:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105639:	00 
c010563a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010563d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105641:	89 04 24             	mov    %eax,(%esp)
c0105644:	e8 54 25 00 00       	call   c0107b9d <get_pte>
c0105649:	89 45 e8             	mov    %eax,-0x18(%ebp)
          assert((*ptep & PTE_P) != 0);
c010564c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010564f:	8b 00                	mov    (%eax),%eax
c0105651:	83 e0 01             	and    $0x1,%eax
c0105654:	85 c0                	test   %eax,%eax
c0105656:	75 24                	jne    c010567c <swap_out+0xaa>
c0105658:	c7 44 24 0c 45 d5 10 	movl   $0xc010d545,0xc(%esp)
c010565f:	c0 
c0105660:	c7 44 24 08 5a d5 10 	movl   $0xc010d55a,0x8(%esp)
c0105667:	c0 
c0105668:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c010566f:	00 
c0105670:	c7 04 24 f4 d4 10 c0 	movl   $0xc010d4f4,(%esp)
c0105677:	e8 89 ad ff ff       	call   c0100405 <__panic>

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
c010567c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010567f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105682:	8b 52 1c             	mov    0x1c(%edx),%edx
c0105685:	c1 ea 0c             	shr    $0xc,%edx
c0105688:	83 c2 01             	add    $0x1,%edx
c010568b:	c1 e2 08             	shl    $0x8,%edx
c010568e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105692:	89 14 24             	mov    %edx,(%esp)
c0105695:	e8 33 3b 00 00       	call   c01091cd <swapfs_write>
c010569a:	85 c0                	test   %eax,%eax
c010569c:	74 34                	je     c01056d2 <swap_out+0x100>
                    cprintf("SWAP: failed to save\n");
c010569e:	c7 04 24 6f d5 10 c0 	movl   $0xc010d56f,(%esp)
c01056a5:	e8 04 ac ff ff       	call   c01002ae <cprintf>
                    sm->map_swappable(mm, v, page, 0);
c01056aa:	a1 74 0f 1b c0       	mov    0xc01b0f74,%eax
c01056af:	8b 40 10             	mov    0x10(%eax),%eax
c01056b2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01056b5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01056bc:	00 
c01056bd:	89 54 24 08          	mov    %edx,0x8(%esp)
c01056c1:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01056c4:	89 54 24 04          	mov    %edx,0x4(%esp)
c01056c8:	8b 55 08             	mov    0x8(%ebp),%edx
c01056cb:	89 14 24             	mov    %edx,(%esp)
c01056ce:	ff d0                	call   *%eax
c01056d0:	eb 68                	jmp    c010573a <swap_out+0x168>
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
c01056d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01056d5:	8b 40 1c             	mov    0x1c(%eax),%eax
c01056d8:	c1 e8 0c             	shr    $0xc,%eax
c01056db:	83 c0 01             	add    $0x1,%eax
c01056de:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01056e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01056e5:	89 44 24 08          	mov    %eax,0x8(%esp)
c01056e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01056ec:	89 44 24 04          	mov    %eax,0x4(%esp)
c01056f0:	c7 04 24 88 d5 10 c0 	movl   $0xc010d588,(%esp)
c01056f7:	e8 b2 ab ff ff       	call   c01002ae <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
c01056fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01056ff:	8b 40 1c             	mov    0x1c(%eax),%eax
c0105702:	c1 e8 0c             	shr    $0xc,%eax
c0105705:	83 c0 01             	add    $0x1,%eax
c0105708:	c1 e0 08             	shl    $0x8,%eax
c010570b:	89 c2                	mov    %eax,%edx
c010570d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105710:	89 10                	mov    %edx,(%eax)
                    free_page(page);
c0105712:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105715:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010571c:	00 
c010571d:	89 04 24             	mov    %eax,(%esp)
c0105720:	e8 ff 1d 00 00       	call   c0107524 <free_pages>
          }
          
          tlb_invalidate(mm->pgdir, v);
c0105725:	8b 45 08             	mov    0x8(%ebp),%eax
c0105728:	8b 40 0c             	mov    0xc(%eax),%eax
c010572b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010572e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105732:	89 04 24             	mov    %eax,(%esp)
c0105735:	e8 76 2b 00 00       	call   c01082b0 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
c010573a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010573e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105741:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105744:	0f 85 9a fe ff ff    	jne    c01055e4 <swap_out+0x12>
     }
     return i;
c010574a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010574d:	c9                   	leave  
c010574e:	c3                   	ret    

c010574f <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
c010574f:	55                   	push   %ebp
c0105750:	89 e5                	mov    %esp,%ebp
c0105752:	83 ec 28             	sub    $0x28,%esp
     struct Page *result = alloc_page();
c0105755:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010575c:	e8 58 1d 00 00       	call   c01074b9 <alloc_pages>
c0105761:	89 45 f4             	mov    %eax,-0xc(%ebp)
     assert(result!=NULL);
c0105764:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105768:	75 24                	jne    c010578e <swap_in+0x3f>
c010576a:	c7 44 24 0c c8 d5 10 	movl   $0xc010d5c8,0xc(%esp)
c0105771:	c0 
c0105772:	c7 44 24 08 5a d5 10 	movl   $0xc010d55a,0x8(%esp)
c0105779:	c0 
c010577a:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c0105781:	00 
c0105782:	c7 04 24 f4 d4 10 c0 	movl   $0xc010d4f4,(%esp)
c0105789:	e8 77 ac ff ff       	call   c0100405 <__panic>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
c010578e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105791:	8b 40 0c             	mov    0xc(%eax),%eax
c0105794:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010579b:	00 
c010579c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010579f:	89 54 24 04          	mov    %edx,0x4(%esp)
c01057a3:	89 04 24             	mov    %eax,(%esp)
c01057a6:	e8 f2 23 00 00       	call   c0107b9d <get_pte>
c01057ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
c01057ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01057b1:	8b 00                	mov    (%eax),%eax
c01057b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01057b6:	89 54 24 04          	mov    %edx,0x4(%esp)
c01057ba:	89 04 24             	mov    %eax,(%esp)
c01057bd:	e8 99 39 00 00       	call   c010915b <swapfs_read>
c01057c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01057c5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01057c9:	74 2a                	je     c01057f5 <swap_in+0xa6>
     {
        assert(r!=0);
c01057cb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01057cf:	75 24                	jne    c01057f5 <swap_in+0xa6>
c01057d1:	c7 44 24 0c d5 d5 10 	movl   $0xc010d5d5,0xc(%esp)
c01057d8:	c0 
c01057d9:	c7 44 24 08 5a d5 10 	movl   $0xc010d55a,0x8(%esp)
c01057e0:	c0 
c01057e1:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
c01057e8:	00 
c01057e9:	c7 04 24 f4 d4 10 c0 	movl   $0xc010d4f4,(%esp)
c01057f0:	e8 10 ac ff ff       	call   c0100405 <__panic>
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
c01057f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01057f8:	8b 00                	mov    (%eax),%eax
c01057fa:	c1 e8 08             	shr    $0x8,%eax
c01057fd:	89 c2                	mov    %eax,%edx
c01057ff:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105802:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105806:	89 54 24 04          	mov    %edx,0x4(%esp)
c010580a:	c7 04 24 dc d5 10 c0 	movl   $0xc010d5dc,(%esp)
c0105811:	e8 98 aa ff ff       	call   c01002ae <cprintf>
     *ptr_result=result;
c0105816:	8b 45 10             	mov    0x10(%ebp),%eax
c0105819:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010581c:	89 10                	mov    %edx,(%eax)
     return 0;
c010581e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105823:	c9                   	leave  
c0105824:	c3                   	ret    

c0105825 <check_content_set>:



static inline void
check_content_set(void)
{
c0105825:	55                   	push   %ebp
c0105826:	89 e5                	mov    %esp,%ebp
c0105828:	83 ec 18             	sub    $0x18,%esp
     *(unsigned char *)0x1000 = 0x0a;
c010582b:	b8 00 10 00 00       	mov    $0x1000,%eax
c0105830:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0105833:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c0105838:	83 f8 01             	cmp    $0x1,%eax
c010583b:	74 24                	je     c0105861 <check_content_set+0x3c>
c010583d:	c7 44 24 0c 1a d6 10 	movl   $0xc010d61a,0xc(%esp)
c0105844:	c0 
c0105845:	c7 44 24 08 5a d5 10 	movl   $0xc010d55a,0x8(%esp)
c010584c:	c0 
c010584d:	c7 44 24 04 92 00 00 	movl   $0x92,0x4(%esp)
c0105854:	00 
c0105855:	c7 04 24 f4 d4 10 c0 	movl   $0xc010d4f4,(%esp)
c010585c:	e8 a4 ab ff ff       	call   c0100405 <__panic>
     *(unsigned char *)0x1010 = 0x0a;
c0105861:	b8 10 10 00 00       	mov    $0x1010,%eax
c0105866:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0105869:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c010586e:	83 f8 01             	cmp    $0x1,%eax
c0105871:	74 24                	je     c0105897 <check_content_set+0x72>
c0105873:	c7 44 24 0c 1a d6 10 	movl   $0xc010d61a,0xc(%esp)
c010587a:	c0 
c010587b:	c7 44 24 08 5a d5 10 	movl   $0xc010d55a,0x8(%esp)
c0105882:	c0 
c0105883:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c010588a:	00 
c010588b:	c7 04 24 f4 d4 10 c0 	movl   $0xc010d4f4,(%esp)
c0105892:	e8 6e ab ff ff       	call   c0100405 <__panic>
     *(unsigned char *)0x2000 = 0x0b;
c0105897:	b8 00 20 00 00       	mov    $0x2000,%eax
c010589c:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c010589f:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c01058a4:	83 f8 02             	cmp    $0x2,%eax
c01058a7:	74 24                	je     c01058cd <check_content_set+0xa8>
c01058a9:	c7 44 24 0c 29 d6 10 	movl   $0xc010d629,0xc(%esp)
c01058b0:	c0 
c01058b1:	c7 44 24 08 5a d5 10 	movl   $0xc010d55a,0x8(%esp)
c01058b8:	c0 
c01058b9:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
c01058c0:	00 
c01058c1:	c7 04 24 f4 d4 10 c0 	movl   $0xc010d4f4,(%esp)
c01058c8:	e8 38 ab ff ff       	call   c0100405 <__panic>
     *(unsigned char *)0x2010 = 0x0b;
c01058cd:	b8 10 20 00 00       	mov    $0x2010,%eax
c01058d2:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c01058d5:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c01058da:	83 f8 02             	cmp    $0x2,%eax
c01058dd:	74 24                	je     c0105903 <check_content_set+0xde>
c01058df:	c7 44 24 0c 29 d6 10 	movl   $0xc010d629,0xc(%esp)
c01058e6:	c0 
c01058e7:	c7 44 24 08 5a d5 10 	movl   $0xc010d55a,0x8(%esp)
c01058ee:	c0 
c01058ef:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
c01058f6:	00 
c01058f7:	c7 04 24 f4 d4 10 c0 	movl   $0xc010d4f4,(%esp)
c01058fe:	e8 02 ab ff ff       	call   c0100405 <__panic>
     *(unsigned char *)0x3000 = 0x0c;
c0105903:	b8 00 30 00 00       	mov    $0x3000,%eax
c0105908:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c010590b:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c0105910:	83 f8 03             	cmp    $0x3,%eax
c0105913:	74 24                	je     c0105939 <check_content_set+0x114>
c0105915:	c7 44 24 0c 38 d6 10 	movl   $0xc010d638,0xc(%esp)
c010591c:	c0 
c010591d:	c7 44 24 08 5a d5 10 	movl   $0xc010d55a,0x8(%esp)
c0105924:	c0 
c0105925:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
c010592c:	00 
c010592d:	c7 04 24 f4 d4 10 c0 	movl   $0xc010d4f4,(%esp)
c0105934:	e8 cc aa ff ff       	call   c0100405 <__panic>
     *(unsigned char *)0x3010 = 0x0c;
c0105939:	b8 10 30 00 00       	mov    $0x3010,%eax
c010593e:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0105941:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c0105946:	83 f8 03             	cmp    $0x3,%eax
c0105949:	74 24                	je     c010596f <check_content_set+0x14a>
c010594b:	c7 44 24 0c 38 d6 10 	movl   $0xc010d638,0xc(%esp)
c0105952:	c0 
c0105953:	c7 44 24 08 5a d5 10 	movl   $0xc010d55a,0x8(%esp)
c010595a:	c0 
c010595b:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c0105962:	00 
c0105963:	c7 04 24 f4 d4 10 c0 	movl   $0xc010d4f4,(%esp)
c010596a:	e8 96 aa ff ff       	call   c0100405 <__panic>
     *(unsigned char *)0x4000 = 0x0d;
c010596f:	b8 00 40 00 00       	mov    $0x4000,%eax
c0105974:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0105977:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c010597c:	83 f8 04             	cmp    $0x4,%eax
c010597f:	74 24                	je     c01059a5 <check_content_set+0x180>
c0105981:	c7 44 24 0c 47 d6 10 	movl   $0xc010d647,0xc(%esp)
c0105988:	c0 
c0105989:	c7 44 24 08 5a d5 10 	movl   $0xc010d55a,0x8(%esp)
c0105990:	c0 
c0105991:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
c0105998:	00 
c0105999:	c7 04 24 f4 d4 10 c0 	movl   $0xc010d4f4,(%esp)
c01059a0:	e8 60 aa ff ff       	call   c0100405 <__panic>
     *(unsigned char *)0x4010 = 0x0d;
c01059a5:	b8 10 40 00 00       	mov    $0x4010,%eax
c01059aa:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c01059ad:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c01059b2:	83 f8 04             	cmp    $0x4,%eax
c01059b5:	74 24                	je     c01059db <check_content_set+0x1b6>
c01059b7:	c7 44 24 0c 47 d6 10 	movl   $0xc010d647,0xc(%esp)
c01059be:	c0 
c01059bf:	c7 44 24 08 5a d5 10 	movl   $0xc010d55a,0x8(%esp)
c01059c6:	c0 
c01059c7:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c01059ce:	00 
c01059cf:	c7 04 24 f4 d4 10 c0 	movl   $0xc010d4f4,(%esp)
c01059d6:	e8 2a aa ff ff       	call   c0100405 <__panic>
}
c01059db:	c9                   	leave  
c01059dc:	c3                   	ret    

c01059dd <check_content_access>:

static inline int
check_content_access(void)
{
c01059dd:	55                   	push   %ebp
c01059de:	89 e5                	mov    %esp,%ebp
c01059e0:	83 ec 18             	sub    $0x18,%esp
    int ret = sm->check_swap();
c01059e3:	a1 74 0f 1b c0       	mov    0xc01b0f74,%eax
c01059e8:	8b 40 1c             	mov    0x1c(%eax),%eax
c01059eb:	ff d0                	call   *%eax
c01059ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c01059f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01059f3:	c9                   	leave  
c01059f4:	c3                   	ret    

c01059f5 <check_swap>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void)
{
c01059f5:	55                   	push   %ebp
c01059f6:	89 e5                	mov    %esp,%ebp
c01059f8:	53                   	push   %ebx
c01059f9:	83 ec 74             	sub    $0x74,%esp
    //backup mem env
     int ret, count = 0, total = 0, i;
c01059fc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105a03:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     list_entry_t *le = &free_list;
c0105a0a:	c7 45 e8 64 31 1b c0 	movl   $0xc01b3164,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0105a11:	eb 6b                	jmp    c0105a7e <check_swap+0x89>
        struct Page *p = le2page(le, page_link);
c0105a13:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105a16:	83 e8 0c             	sub    $0xc,%eax
c0105a19:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        assert(PageProperty(p));
c0105a1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105a1f:	83 c0 04             	add    $0x4,%eax
c0105a22:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0105a29:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105a2c:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0105a2f:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0105a32:	0f a3 10             	bt     %edx,(%eax)
c0105a35:	19 c0                	sbb    %eax,%eax
c0105a37:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return oldbit != 0;
c0105a3a:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0105a3e:	0f 95 c0             	setne  %al
c0105a41:	0f b6 c0             	movzbl %al,%eax
c0105a44:	85 c0                	test   %eax,%eax
c0105a46:	75 24                	jne    c0105a6c <check_swap+0x77>
c0105a48:	c7 44 24 0c 56 d6 10 	movl   $0xc010d656,0xc(%esp)
c0105a4f:	c0 
c0105a50:	c7 44 24 08 5a d5 10 	movl   $0xc010d55a,0x8(%esp)
c0105a57:	c0 
c0105a58:	c7 44 24 04 bb 00 00 	movl   $0xbb,0x4(%esp)
c0105a5f:	00 
c0105a60:	c7 04 24 f4 d4 10 c0 	movl   $0xc010d4f4,(%esp)
c0105a67:	e8 99 a9 ff ff       	call   c0100405 <__panic>
        count ++, total += p->property;
c0105a6c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0105a70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105a73:	8b 50 08             	mov    0x8(%eax),%edx
c0105a76:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a79:	01 d0                	add    %edx,%eax
c0105a7b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105a7e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105a81:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return listelm->next;
c0105a84:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0105a87:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c0105a8a:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105a8d:	81 7d e8 64 31 1b c0 	cmpl   $0xc01b3164,-0x18(%ebp)
c0105a94:	0f 85 79 ff ff ff    	jne    c0105a13 <check_swap+0x1e>
     }
     assert(total == nr_free_pages());
c0105a9a:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c0105a9d:	e8 b4 1a 00 00       	call   c0107556 <nr_free_pages>
c0105aa2:	39 c3                	cmp    %eax,%ebx
c0105aa4:	74 24                	je     c0105aca <check_swap+0xd5>
c0105aa6:	c7 44 24 0c 66 d6 10 	movl   $0xc010d666,0xc(%esp)
c0105aad:	c0 
c0105aae:	c7 44 24 08 5a d5 10 	movl   $0xc010d55a,0x8(%esp)
c0105ab5:	c0 
c0105ab6:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
c0105abd:	00 
c0105abe:	c7 04 24 f4 d4 10 c0 	movl   $0xc010d4f4,(%esp)
c0105ac5:	e8 3b a9 ff ff       	call   c0100405 <__panic>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
c0105aca:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105acd:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ad4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ad8:	c7 04 24 80 d6 10 c0 	movl   $0xc010d680,(%esp)
c0105adf:	e8 ca a7 ff ff       	call   c01002ae <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
c0105ae4:	e8 ce da ff ff       	call   c01035b7 <mm_create>
c0105ae9:	89 45 e0             	mov    %eax,-0x20(%ebp)
     assert(mm != NULL);
c0105aec:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0105af0:	75 24                	jne    c0105b16 <check_swap+0x121>
c0105af2:	c7 44 24 0c a6 d6 10 	movl   $0xc010d6a6,0xc(%esp)
c0105af9:	c0 
c0105afa:	c7 44 24 08 5a d5 10 	movl   $0xc010d55a,0x8(%esp)
c0105b01:	c0 
c0105b02:	c7 44 24 04 c3 00 00 	movl   $0xc3,0x4(%esp)
c0105b09:	00 
c0105b0a:	c7 04 24 f4 d4 10 c0 	movl   $0xc010d4f4,(%esp)
c0105b11:	e8 ef a8 ff ff       	call   c0100405 <__panic>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
c0105b16:	a1 7c 30 1b c0       	mov    0xc01b307c,%eax
c0105b1b:	85 c0                	test   %eax,%eax
c0105b1d:	74 24                	je     c0105b43 <check_swap+0x14e>
c0105b1f:	c7 44 24 0c b1 d6 10 	movl   $0xc010d6b1,0xc(%esp)
c0105b26:	c0 
c0105b27:	c7 44 24 08 5a d5 10 	movl   $0xc010d55a,0x8(%esp)
c0105b2e:	c0 
c0105b2f:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
c0105b36:	00 
c0105b37:	c7 04 24 f4 d4 10 c0 	movl   $0xc010d4f4,(%esp)
c0105b3e:	e8 c2 a8 ff ff       	call   c0100405 <__panic>

     check_mm_struct = mm;
c0105b43:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105b46:	a3 7c 30 1b c0       	mov    %eax,0xc01b307c

     pde_t *pgdir = mm->pgdir = boot_pgdir;
c0105b4b:	8b 15 20 ca 12 c0    	mov    0xc012ca20,%edx
c0105b51:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105b54:	89 50 0c             	mov    %edx,0xc(%eax)
c0105b57:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105b5a:	8b 40 0c             	mov    0xc(%eax),%eax
c0105b5d:	89 45 dc             	mov    %eax,-0x24(%ebp)
     assert(pgdir[0] == 0);
c0105b60:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105b63:	8b 00                	mov    (%eax),%eax
c0105b65:	85 c0                	test   %eax,%eax
c0105b67:	74 24                	je     c0105b8d <check_swap+0x198>
c0105b69:	c7 44 24 0c c9 d6 10 	movl   $0xc010d6c9,0xc(%esp)
c0105b70:	c0 
c0105b71:	c7 44 24 08 5a d5 10 	movl   $0xc010d55a,0x8(%esp)
c0105b78:	c0 
c0105b79:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c0105b80:	00 
c0105b81:	c7 04 24 f4 d4 10 c0 	movl   $0xc010d4f4,(%esp)
c0105b88:	e8 78 a8 ff ff       	call   c0100405 <__panic>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
c0105b8d:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
c0105b94:	00 
c0105b95:	c7 44 24 04 00 60 00 	movl   $0x6000,0x4(%esp)
c0105b9c:	00 
c0105b9d:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
c0105ba4:	e8 a7 da ff ff       	call   c0103650 <vma_create>
c0105ba9:	89 45 d8             	mov    %eax,-0x28(%ebp)
     assert(vma != NULL);
c0105bac:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0105bb0:	75 24                	jne    c0105bd6 <check_swap+0x1e1>
c0105bb2:	c7 44 24 0c d7 d6 10 	movl   $0xc010d6d7,0xc(%esp)
c0105bb9:	c0 
c0105bba:	c7 44 24 08 5a d5 10 	movl   $0xc010d55a,0x8(%esp)
c0105bc1:	c0 
c0105bc2:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c0105bc9:	00 
c0105bca:	c7 04 24 f4 d4 10 c0 	movl   $0xc010d4f4,(%esp)
c0105bd1:	e8 2f a8 ff ff       	call   c0100405 <__panic>

     insert_vma_struct(mm, vma);
c0105bd6:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105bd9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105bdd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105be0:	89 04 24             	mov    %eax,(%esp)
c0105be3:	e8 f8 db ff ff       	call   c01037e0 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
c0105be8:	c7 04 24 e4 d6 10 c0 	movl   $0xc010d6e4,(%esp)
c0105bef:	e8 ba a6 ff ff       	call   c01002ae <cprintf>
     pte_t *temp_ptep=NULL;
c0105bf4:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
c0105bfb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105bfe:	8b 40 0c             	mov    0xc(%eax),%eax
c0105c01:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0105c08:	00 
c0105c09:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0105c10:	00 
c0105c11:	89 04 24             	mov    %eax,(%esp)
c0105c14:	e8 84 1f 00 00       	call   c0107b9d <get_pte>
c0105c19:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     assert(temp_ptep!= NULL);
c0105c1c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c0105c20:	75 24                	jne    c0105c46 <check_swap+0x251>
c0105c22:	c7 44 24 0c 18 d7 10 	movl   $0xc010d718,0xc(%esp)
c0105c29:	c0 
c0105c2a:	c7 44 24 08 5a d5 10 	movl   $0xc010d55a,0x8(%esp)
c0105c31:	c0 
c0105c32:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c0105c39:	00 
c0105c3a:	c7 04 24 f4 d4 10 c0 	movl   $0xc010d4f4,(%esp)
c0105c41:	e8 bf a7 ff ff       	call   c0100405 <__panic>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
c0105c46:	c7 04 24 2c d7 10 c0 	movl   $0xc010d72c,(%esp)
c0105c4d:	e8 5c a6 ff ff       	call   c01002ae <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105c52:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0105c59:	e9 a3 00 00 00       	jmp    c0105d01 <check_swap+0x30c>
          check_rp[i] = alloc_page();
c0105c5e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105c65:	e8 4f 18 00 00       	call   c01074b9 <alloc_pages>
c0105c6a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105c6d:	89 04 95 a0 30 1b c0 	mov    %eax,-0x3fe4cf60(,%edx,4)
          assert(check_rp[i] != NULL );
c0105c74:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105c77:	8b 04 85 a0 30 1b c0 	mov    -0x3fe4cf60(,%eax,4),%eax
c0105c7e:	85 c0                	test   %eax,%eax
c0105c80:	75 24                	jne    c0105ca6 <check_swap+0x2b1>
c0105c82:	c7 44 24 0c 50 d7 10 	movl   $0xc010d750,0xc(%esp)
c0105c89:	c0 
c0105c8a:	c7 44 24 08 5a d5 10 	movl   $0xc010d55a,0x8(%esp)
c0105c91:	c0 
c0105c92:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c0105c99:	00 
c0105c9a:	c7 04 24 f4 d4 10 c0 	movl   $0xc010d4f4,(%esp)
c0105ca1:	e8 5f a7 ff ff       	call   c0100405 <__panic>
          assert(!PageProperty(check_rp[i]));
c0105ca6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105ca9:	8b 04 85 a0 30 1b c0 	mov    -0x3fe4cf60(,%eax,4),%eax
c0105cb0:	83 c0 04             	add    $0x4,%eax
c0105cb3:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
c0105cba:	89 45 b0             	mov    %eax,-0x50(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105cbd:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0105cc0:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0105cc3:	0f a3 10             	bt     %edx,(%eax)
c0105cc6:	19 c0                	sbb    %eax,%eax
c0105cc8:	89 45 ac             	mov    %eax,-0x54(%ebp)
    return oldbit != 0;
c0105ccb:	83 7d ac 00          	cmpl   $0x0,-0x54(%ebp)
c0105ccf:	0f 95 c0             	setne  %al
c0105cd2:	0f b6 c0             	movzbl %al,%eax
c0105cd5:	85 c0                	test   %eax,%eax
c0105cd7:	74 24                	je     c0105cfd <check_swap+0x308>
c0105cd9:	c7 44 24 0c 64 d7 10 	movl   $0xc010d764,0xc(%esp)
c0105ce0:	c0 
c0105ce1:	c7 44 24 08 5a d5 10 	movl   $0xc010d55a,0x8(%esp)
c0105ce8:	c0 
c0105ce9:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c0105cf0:	00 
c0105cf1:	c7 04 24 f4 d4 10 c0 	movl   $0xc010d4f4,(%esp)
c0105cf8:	e8 08 a7 ff ff       	call   c0100405 <__panic>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105cfd:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0105d01:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0105d05:	0f 8e 53 ff ff ff    	jle    c0105c5e <check_swap+0x269>
     }
     list_entry_t free_list_store = free_list;
c0105d0b:	a1 64 31 1b c0       	mov    0xc01b3164,%eax
c0105d10:	8b 15 68 31 1b c0    	mov    0xc01b3168,%edx
c0105d16:	89 45 98             	mov    %eax,-0x68(%ebp)
c0105d19:	89 55 9c             	mov    %edx,-0x64(%ebp)
c0105d1c:	c7 45 a8 64 31 1b c0 	movl   $0xc01b3164,-0x58(%ebp)
    elm->prev = elm->next = elm;
c0105d23:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0105d26:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0105d29:	89 50 04             	mov    %edx,0x4(%eax)
c0105d2c:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0105d2f:	8b 50 04             	mov    0x4(%eax),%edx
c0105d32:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0105d35:	89 10                	mov    %edx,(%eax)
c0105d37:	c7 45 a4 64 31 1b c0 	movl   $0xc01b3164,-0x5c(%ebp)
    return list->next == list;
c0105d3e:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0105d41:	8b 40 04             	mov    0x4(%eax),%eax
c0105d44:	39 45 a4             	cmp    %eax,-0x5c(%ebp)
c0105d47:	0f 94 c0             	sete   %al
c0105d4a:	0f b6 c0             	movzbl %al,%eax
     list_init(&free_list);
     assert(list_empty(&free_list));
c0105d4d:	85 c0                	test   %eax,%eax
c0105d4f:	75 24                	jne    c0105d75 <check_swap+0x380>
c0105d51:	c7 44 24 0c 7f d7 10 	movl   $0xc010d77f,0xc(%esp)
c0105d58:	c0 
c0105d59:	c7 44 24 08 5a d5 10 	movl   $0xc010d55a,0x8(%esp)
c0105d60:	c0 
c0105d61:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
c0105d68:	00 
c0105d69:	c7 04 24 f4 d4 10 c0 	movl   $0xc010d4f4,(%esp)
c0105d70:	e8 90 a6 ff ff       	call   c0100405 <__panic>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
c0105d75:	a1 6c 31 1b c0       	mov    0xc01b316c,%eax
c0105d7a:	89 45 d0             	mov    %eax,-0x30(%ebp)
     nr_free = 0;
c0105d7d:	c7 05 6c 31 1b c0 00 	movl   $0x0,0xc01b316c
c0105d84:	00 00 00 
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105d87:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0105d8e:	eb 1e                	jmp    c0105dae <check_swap+0x3b9>
        free_pages(check_rp[i],1);
c0105d90:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105d93:	8b 04 85 a0 30 1b c0 	mov    -0x3fe4cf60(,%eax,4),%eax
c0105d9a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105da1:	00 
c0105da2:	89 04 24             	mov    %eax,(%esp)
c0105da5:	e8 7a 17 00 00       	call   c0107524 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105daa:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0105dae:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0105db2:	7e dc                	jle    c0105d90 <check_swap+0x39b>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
c0105db4:	a1 6c 31 1b c0       	mov    0xc01b316c,%eax
c0105db9:	83 f8 04             	cmp    $0x4,%eax
c0105dbc:	74 24                	je     c0105de2 <check_swap+0x3ed>
c0105dbe:	c7 44 24 0c 98 d7 10 	movl   $0xc010d798,0xc(%esp)
c0105dc5:	c0 
c0105dc6:	c7 44 24 08 5a d5 10 	movl   $0xc010d55a,0x8(%esp)
c0105dcd:	c0 
c0105dce:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c0105dd5:	00 
c0105dd6:	c7 04 24 f4 d4 10 c0 	movl   $0xc010d4f4,(%esp)
c0105ddd:	e8 23 a6 ff ff       	call   c0100405 <__panic>
     
     cprintf("set up init env for check_swap begin!\n");
c0105de2:	c7 04 24 bc d7 10 c0 	movl   $0xc010d7bc,(%esp)
c0105de9:	e8 c0 a4 ff ff       	call   c01002ae <cprintf>
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
c0105dee:	c7 05 64 0f 1b c0 00 	movl   $0x0,0xc01b0f64
c0105df5:	00 00 00 
     
     check_content_set();
c0105df8:	e8 28 fa ff ff       	call   c0105825 <check_content_set>
     assert( nr_free == 0);         
c0105dfd:	a1 6c 31 1b c0       	mov    0xc01b316c,%eax
c0105e02:	85 c0                	test   %eax,%eax
c0105e04:	74 24                	je     c0105e2a <check_swap+0x435>
c0105e06:	c7 44 24 0c e3 d7 10 	movl   $0xc010d7e3,0xc(%esp)
c0105e0d:	c0 
c0105e0e:	c7 44 24 08 5a d5 10 	movl   $0xc010d55a,0x8(%esp)
c0105e15:	c0 
c0105e16:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
c0105e1d:	00 
c0105e1e:	c7 04 24 f4 d4 10 c0 	movl   $0xc010d4f4,(%esp)
c0105e25:	e8 db a5 ff ff       	call   c0100405 <__panic>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0105e2a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0105e31:	eb 26                	jmp    c0105e59 <check_swap+0x464>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
c0105e33:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105e36:	c7 04 85 c0 30 1b c0 	movl   $0xffffffff,-0x3fe4cf40(,%eax,4)
c0105e3d:	ff ff ff ff 
c0105e41:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105e44:	8b 14 85 c0 30 1b c0 	mov    -0x3fe4cf40(,%eax,4),%edx
c0105e4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105e4e:	89 14 85 00 31 1b c0 	mov    %edx,-0x3fe4cf00(,%eax,4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0105e55:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0105e59:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
c0105e5d:	7e d4                	jle    c0105e33 <check_swap+0x43e>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105e5f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0105e66:	e9 eb 00 00 00       	jmp    c0105f56 <check_swap+0x561>
         check_ptep[i]=0;
c0105e6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105e6e:	c7 04 85 54 31 1b c0 	movl   $0x0,-0x3fe4ceac(,%eax,4)
c0105e75:	00 00 00 00 
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
c0105e79:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105e7c:	83 c0 01             	add    $0x1,%eax
c0105e7f:	c1 e0 0c             	shl    $0xc,%eax
c0105e82:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105e89:	00 
c0105e8a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e8e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105e91:	89 04 24             	mov    %eax,(%esp)
c0105e94:	e8 04 1d 00 00       	call   c0107b9d <get_pte>
c0105e99:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105e9c:	89 04 95 54 31 1b c0 	mov    %eax,-0x3fe4ceac(,%edx,4)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
c0105ea3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105ea6:	8b 04 85 54 31 1b c0 	mov    -0x3fe4ceac(,%eax,4),%eax
c0105ead:	85 c0                	test   %eax,%eax
c0105eaf:	75 24                	jne    c0105ed5 <check_swap+0x4e0>
c0105eb1:	c7 44 24 0c f0 d7 10 	movl   $0xc010d7f0,0xc(%esp)
c0105eb8:	c0 
c0105eb9:	c7 44 24 08 5a d5 10 	movl   $0xc010d55a,0x8(%esp)
c0105ec0:	c0 
c0105ec1:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c0105ec8:	00 
c0105ec9:	c7 04 24 f4 d4 10 c0 	movl   $0xc010d4f4,(%esp)
c0105ed0:	e8 30 a5 ff ff       	call   c0100405 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
c0105ed5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105ed8:	8b 04 85 54 31 1b c0 	mov    -0x3fe4ceac(,%eax,4),%eax
c0105edf:	8b 00                	mov    (%eax),%eax
c0105ee1:	89 04 24             	mov    %eax,(%esp)
c0105ee4:	e8 87 f5 ff ff       	call   c0105470 <pte2page>
c0105ee9:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105eec:	8b 14 95 a0 30 1b c0 	mov    -0x3fe4cf60(,%edx,4),%edx
c0105ef3:	39 d0                	cmp    %edx,%eax
c0105ef5:	74 24                	je     c0105f1b <check_swap+0x526>
c0105ef7:	c7 44 24 0c 08 d8 10 	movl   $0xc010d808,0xc(%esp)
c0105efe:	c0 
c0105eff:	c7 44 24 08 5a d5 10 	movl   $0xc010d55a,0x8(%esp)
c0105f06:	c0 
c0105f07:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c0105f0e:	00 
c0105f0f:	c7 04 24 f4 d4 10 c0 	movl   $0xc010d4f4,(%esp)
c0105f16:	e8 ea a4 ff ff       	call   c0100405 <__panic>
         assert((*check_ptep[i] & PTE_P));          
c0105f1b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105f1e:	8b 04 85 54 31 1b c0 	mov    -0x3fe4ceac(,%eax,4),%eax
c0105f25:	8b 00                	mov    (%eax),%eax
c0105f27:	83 e0 01             	and    $0x1,%eax
c0105f2a:	85 c0                	test   %eax,%eax
c0105f2c:	75 24                	jne    c0105f52 <check_swap+0x55d>
c0105f2e:	c7 44 24 0c 30 d8 10 	movl   $0xc010d830,0xc(%esp)
c0105f35:	c0 
c0105f36:	c7 44 24 08 5a d5 10 	movl   $0xc010d55a,0x8(%esp)
c0105f3d:	c0 
c0105f3e:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c0105f45:	00 
c0105f46:	c7 04 24 f4 d4 10 c0 	movl   $0xc010d4f4,(%esp)
c0105f4d:	e8 b3 a4 ff ff       	call   c0100405 <__panic>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105f52:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0105f56:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0105f5a:	0f 8e 0b ff ff ff    	jle    c0105e6b <check_swap+0x476>
     }
     cprintf("set up init env for check_swap over!\n");
c0105f60:	c7 04 24 4c d8 10 c0 	movl   $0xc010d84c,(%esp)
c0105f67:	e8 42 a3 ff ff       	call   c01002ae <cprintf>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
c0105f6c:	e8 6c fa ff ff       	call   c01059dd <check_content_access>
c0105f71:	89 45 cc             	mov    %eax,-0x34(%ebp)
     assert(ret==0);
c0105f74:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0105f78:	74 24                	je     c0105f9e <check_swap+0x5a9>
c0105f7a:	c7 44 24 0c 72 d8 10 	movl   $0xc010d872,0xc(%esp)
c0105f81:	c0 
c0105f82:	c7 44 24 08 5a d5 10 	movl   $0xc010d55a,0x8(%esp)
c0105f89:	c0 
c0105f8a:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c0105f91:	00 
c0105f92:	c7 04 24 f4 d4 10 c0 	movl   $0xc010d4f4,(%esp)
c0105f99:	e8 67 a4 ff ff       	call   c0100405 <__panic>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105f9e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0105fa5:	eb 1e                	jmp    c0105fc5 <check_swap+0x5d0>
         free_pages(check_rp[i],1);
c0105fa7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105faa:	8b 04 85 a0 30 1b c0 	mov    -0x3fe4cf60(,%eax,4),%eax
c0105fb1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105fb8:	00 
c0105fb9:	89 04 24             	mov    %eax,(%esp)
c0105fbc:	e8 63 15 00 00       	call   c0107524 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105fc1:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0105fc5:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0105fc9:	7e dc                	jle    c0105fa7 <check_swap+0x5b2>
     } 

     //free_page(pte2page(*temp_ptep));
    free_page(pde2page(pgdir[0]));
c0105fcb:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105fce:	8b 00                	mov    (%eax),%eax
c0105fd0:	89 04 24             	mov    %eax,(%esp)
c0105fd3:	e8 d6 f4 ff ff       	call   c01054ae <pde2page>
c0105fd8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105fdf:	00 
c0105fe0:	89 04 24             	mov    %eax,(%esp)
c0105fe3:	e8 3c 15 00 00       	call   c0107524 <free_pages>
     pgdir[0] = 0;
c0105fe8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105feb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
     mm->pgdir = NULL;
c0105ff1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105ff4:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
     mm_destroy(mm);
c0105ffb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105ffe:	89 04 24             	mov    %eax,(%esp)
c0106001:	e8 0a d9 ff ff       	call   c0103910 <mm_destroy>
     check_mm_struct = NULL;
c0106006:	c7 05 7c 30 1b c0 00 	movl   $0x0,0xc01b307c
c010600d:	00 00 00 
     
     nr_free = nr_free_store;
c0106010:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106013:	a3 6c 31 1b c0       	mov    %eax,0xc01b316c
     free_list = free_list_store;
c0106018:	8b 45 98             	mov    -0x68(%ebp),%eax
c010601b:	8b 55 9c             	mov    -0x64(%ebp),%edx
c010601e:	a3 64 31 1b c0       	mov    %eax,0xc01b3164
c0106023:	89 15 68 31 1b c0    	mov    %edx,0xc01b3168

     
     le = &free_list;
c0106029:	c7 45 e8 64 31 1b c0 	movl   $0xc01b3164,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0106030:	eb 1d                	jmp    c010604f <check_swap+0x65a>
         struct Page *p = le2page(le, page_link);
c0106032:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106035:	83 e8 0c             	sub    $0xc,%eax
c0106038:	89 45 c8             	mov    %eax,-0x38(%ebp)
         count --, total -= p->property;
c010603b:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c010603f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0106042:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106045:	8b 40 08             	mov    0x8(%eax),%eax
c0106048:	29 c2                	sub    %eax,%edx
c010604a:	89 d0                	mov    %edx,%eax
c010604c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010604f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106052:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return listelm->next;
c0106055:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0106058:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c010605b:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010605e:	81 7d e8 64 31 1b c0 	cmpl   $0xc01b3164,-0x18(%ebp)
c0106065:	75 cb                	jne    c0106032 <check_swap+0x63d>
     }
     cprintf("count is %d, total is %d\n",count,total);
c0106067:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010606a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010606e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106075:	c7 04 24 79 d8 10 c0 	movl   $0xc010d879,(%esp)
c010607c:	e8 2d a2 ff ff       	call   c01002ae <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
c0106081:	c7 04 24 93 d8 10 c0 	movl   $0xc010d893,(%esp)
c0106088:	e8 21 a2 ff ff       	call   c01002ae <cprintf>
}
c010608d:	83 c4 74             	add    $0x74,%esp
c0106090:	5b                   	pop    %ebx
c0106091:	5d                   	pop    %ebp
c0106092:	c3                   	ret    

c0106093 <page2ppn>:
page2ppn(struct Page *page) {
c0106093:	55                   	push   %ebp
c0106094:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0106096:	8b 55 08             	mov    0x8(%ebp),%edx
c0106099:	a1 78 31 1b c0       	mov    0xc01b3178,%eax
c010609e:	29 c2                	sub    %eax,%edx
c01060a0:	89 d0                	mov    %edx,%eax
c01060a2:	c1 f8 05             	sar    $0x5,%eax
}
c01060a5:	5d                   	pop    %ebp
c01060a6:	c3                   	ret    

c01060a7 <page2pa>:
page2pa(struct Page *page) {
c01060a7:	55                   	push   %ebp
c01060a8:	89 e5                	mov    %esp,%ebp
c01060aa:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01060ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01060b0:	89 04 24             	mov    %eax,(%esp)
c01060b3:	e8 db ff ff ff       	call   c0106093 <page2ppn>
c01060b8:	c1 e0 0c             	shl    $0xc,%eax
}
c01060bb:	c9                   	leave  
c01060bc:	c3                   	ret    

c01060bd <page_ref>:

static inline int
page_ref(struct Page *page) {
c01060bd:	55                   	push   %ebp
c01060be:	89 e5                	mov    %esp,%ebp
    return page->ref;
c01060c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01060c3:	8b 00                	mov    (%eax),%eax
}
c01060c5:	5d                   	pop    %ebp
c01060c6:	c3                   	ret    

c01060c7 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c01060c7:	55                   	push   %ebp
c01060c8:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c01060ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01060cd:	8b 55 0c             	mov    0xc(%ebp),%edx
c01060d0:	89 10                	mov    %edx,(%eax)
}
c01060d2:	5d                   	pop    %ebp
c01060d3:	c3                   	ret    

c01060d4 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c01060d4:	55                   	push   %ebp
c01060d5:	89 e5                	mov    %esp,%ebp
c01060d7:	83 ec 10             	sub    $0x10,%esp
c01060da:	c7 45 fc 64 31 1b c0 	movl   $0xc01b3164,-0x4(%ebp)
    elm->prev = elm->next = elm;
c01060e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01060e4:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01060e7:	89 50 04             	mov    %edx,0x4(%eax)
c01060ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01060ed:	8b 50 04             	mov    0x4(%eax),%edx
c01060f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01060f3:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c01060f5:	c7 05 6c 31 1b c0 00 	movl   $0x0,0xc01b316c
c01060fc:	00 00 00 
}
c01060ff:	c9                   	leave  
c0106100:	c3                   	ret    

c0106101 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c0106101:	55                   	push   %ebp
c0106102:	89 e5                	mov    %esp,%ebp
c0106104:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c0106107:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010610b:	75 24                	jne    c0106131 <default_init_memmap+0x30>
c010610d:	c7 44 24 0c ac d8 10 	movl   $0xc010d8ac,0xc(%esp)
c0106114:	c0 
c0106115:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c010611c:	c0 
c010611d:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0106124:	00 
c0106125:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c010612c:	e8 d4 a2 ff ff       	call   c0100405 <__panic>
    struct Page *p = base;
c0106131:	8b 45 08             	mov    0x8(%ebp),%eax
c0106134:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0106137:	e9 dc 00 00 00       	jmp    c0106218 <default_init_memmap+0x117>
        //初始化n块物理页
        assert(PageReserved(p));
c010613c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010613f:	83 c0 04             	add    $0x4,%eax
c0106142:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0106149:	89 45 ec             	mov    %eax,-0x14(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010614c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010614f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0106152:	0f a3 10             	bt     %edx,(%eax)
c0106155:	19 c0                	sbb    %eax,%eax
c0106157:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c010615a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010615e:	0f 95 c0             	setne  %al
c0106161:	0f b6 c0             	movzbl %al,%eax
c0106164:	85 c0                	test   %eax,%eax
c0106166:	75 24                	jne    c010618c <default_init_memmap+0x8b>
c0106168:	c7 44 24 0c dd d8 10 	movl   $0xc010d8dd,0xc(%esp)
c010616f:	c0 
c0106170:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c0106177:	c0 
c0106178:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
c010617f:	00 
c0106180:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c0106187:	e8 79 a2 ff ff       	call   c0100405 <__panic>
        p->flags = 0;
c010618c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010618f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        SetPageProperty(p);
c0106196:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106199:	83 c0 04             	add    $0x4,%eax
c010619c:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c01061a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01061a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01061a9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01061ac:	0f ab 10             	bts    %edx,(%eax)
        p->property = 0;
c01061af:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01061b2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        set_page_ref(p, 0);
c01061b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01061c0:	00 
c01061c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01061c4:	89 04 24             	mov    %eax,(%esp)
c01061c7:	e8 fb fe ff ff       	call   c01060c7 <set_page_ref>
        list_add_before(&free_list, &(p->page_link));
c01061cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01061cf:	83 c0 0c             	add    $0xc,%eax
c01061d2:	c7 45 dc 64 31 1b c0 	movl   $0xc01b3164,-0x24(%ebp)
c01061d9:	89 45 d8             	mov    %eax,-0x28(%ebp)
    __list_add(elm, listelm->prev, listelm);
c01061dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01061df:	8b 00                	mov    (%eax),%eax
c01061e1:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01061e4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01061e7:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01061ea:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01061ed:	89 45 cc             	mov    %eax,-0x34(%ebp)
    prev->next = next->prev = elm;
c01061f0:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01061f3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01061f6:	89 10                	mov    %edx,(%eax)
c01061f8:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01061fb:	8b 10                	mov    (%eax),%edx
c01061fd:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106200:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0106203:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106206:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0106209:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010620c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010620f:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0106212:	89 10                	mov    %edx,(%eax)
    for (; p != base + n; p ++) {
c0106214:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c0106218:	8b 45 0c             	mov    0xc(%ebp),%eax
c010621b:	c1 e0 05             	shl    $0x5,%eax
c010621e:	89 c2                	mov    %eax,%edx
c0106220:	8b 45 08             	mov    0x8(%ebp),%eax
c0106223:	01 d0                	add    %edx,%eax
c0106225:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0106228:	0f 85 0e ff ff ff    	jne    c010613c <default_init_memmap+0x3b>
    }
    nr_free += n;
c010622e:	8b 15 6c 31 1b c0    	mov    0xc01b316c,%edx
c0106234:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106237:	01 d0                	add    %edx,%eax
c0106239:	a3 6c 31 1b c0       	mov    %eax,0xc01b316c
    base->property = n;
c010623e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106241:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106244:	89 50 08             	mov    %edx,0x8(%eax)
}
c0106247:	c9                   	leave  
c0106248:	c3                   	ret    

c0106249 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c0106249:	55                   	push   %ebp
c010624a:	89 e5                	mov    %esp,%ebp
c010624c:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c010624f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0106253:	75 24                	jne    c0106279 <default_alloc_pages+0x30>
c0106255:	c7 44 24 0c ac d8 10 	movl   $0xc010d8ac,0xc(%esp)
c010625c:	c0 
c010625d:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c0106264:	c0 
c0106265:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
c010626c:	00 
c010626d:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c0106274:	e8 8c a1 ff ff       	call   c0100405 <__panic>
    if (n > nr_free) {
c0106279:	a1 6c 31 1b c0       	mov    0xc01b316c,%eax
c010627e:	3b 45 08             	cmp    0x8(%ebp),%eax
c0106281:	73 0a                	jae    c010628d <default_alloc_pages+0x44>
        return NULL;
c0106283:	b8 00 00 00 00       	mov    $0x0,%eax
c0106288:	e9 37 01 00 00       	jmp    c01063c4 <default_alloc_pages+0x17b>
    }
    //如果所有空闲块的空闲页总数都没有n个,直接return null
    list_entry_t *le, *le_next;  //free_list指针和它的下一个
    le = &free_list;
c010628d:	c7 45 f4 64 31 1b c0 	movl   $0xc01b3164,-0xc(%ebp)
    //从头开始遍历保存空闲物理内存块的链表(按照物理地址的从小到大顺序)
    while((le=list_next(le)) != &free_list) {
c0106294:	e9 0a 01 00 00       	jmp    c01063a3 <default_alloc_pages+0x15a>
    //通过宏le2page(memlayout.h)得指向Page的指针p
      struct Page *p = le2page(le, page_link);
c0106299:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010629c:	83 e8 0c             	sub    $0xc,%eax
c010629f:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(p->property >= n){
c01062a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01062a5:	8b 40 08             	mov    0x8(%eax),%eax
c01062a8:	3b 45 08             	cmp    0x8(%ebp),%eax
c01062ab:	0f 82 f2 00 00 00    	jb     c01063a3 <default_alloc_pages+0x15a>
        //p->property表示空闲块的大小，大于n则进下一步
        int i;
        //for初始化空闲块中每一个页
        for(i=0;i<n;i++){
c01062b1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c01062b8:	eb 7c                	jmp    c0106336 <default_alloc_pages+0xed>
c01062ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01062bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
c01062c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01062c3:	8b 40 04             	mov    0x4(%eax),%eax
          le_next = list_next(le);
c01062c6:	89 45 e8             	mov    %eax,-0x18(%ebp)
          struct Page *p2 = le2page(le, page_link);
c01062c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01062cc:	83 e8 0c             	sub    $0xc,%eax
c01062cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
          SetPageReserved(p2);//flags bit0 置1，表示已经被分配
c01062d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01062d5:	83 c0 04             	add    $0x4,%eax
c01062d8:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01062df:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01062e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01062e5:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01062e8:	0f ab 10             	bts    %edx,(%eax)
          ClearPageProperty(p2);//falgs bit1 置0，表示已被分配
c01062eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01062ee:	83 c0 04             	add    $0x4,%eax
c01062f1:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c01062f8:	89 45 d0             	mov    %eax,-0x30(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01062fb:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01062fe:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106301:	0f b3 10             	btr    %edx,(%eax)
c0106304:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106307:	89 45 cc             	mov    %eax,-0x34(%ebp)
    __list_del(listelm->prev, listelm->next);
c010630a:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010630d:	8b 40 04             	mov    0x4(%eax),%eax
c0106310:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0106313:	8b 12                	mov    (%edx),%edx
c0106315:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0106318:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    prev->next = next;
c010631b:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010631e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0106321:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0106324:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0106327:	8b 55 c8             	mov    -0x38(%ebp),%edx
c010632a:	89 10                	mov    %edx,(%eax)
          list_del(le);//取消和free_list的link
          le = le_next;//指针后移
c010632c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010632f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        for(i=0;i<n;i++){
c0106332:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
c0106336:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106339:	3b 45 08             	cmp    0x8(%ebp),%eax
c010633c:	0f 82 78 ff ff ff    	jb     c01062ba <default_alloc_pages+0x71>
        }
        //如果选中的块大于n,需要修改剩下的块的head page的property
        if(p->property>n){
c0106342:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106345:	8b 40 08             	mov    0x8(%eax),%eax
c0106348:	3b 45 08             	cmp    0x8(%ebp),%eax
c010634b:	76 12                	jbe    c010635f <default_alloc_pages+0x116>
          (le2page(le,page_link))->property = p->property - n;
c010634d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106350:	8d 50 f4             	lea    -0xc(%eax),%edx
c0106353:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106356:	8b 40 08             	mov    0x8(%eax),%eax
c0106359:	2b 45 08             	sub    0x8(%ebp),%eax
c010635c:	89 42 08             	mov    %eax,0x8(%edx)
        }
        ClearPageProperty(p);
c010635f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106362:	83 c0 04             	add    $0x4,%eax
c0106365:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c010636c:	89 45 bc             	mov    %eax,-0x44(%ebp)
c010636f:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0106372:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0106375:	0f b3 10             	btr    %edx,(%eax)
        SetPageReserved(p);
c0106378:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010637b:	83 c0 04             	add    $0x4,%eax
c010637e:	c7 45 b8 00 00 00 00 	movl   $0x0,-0x48(%ebp)
c0106385:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0106388:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010638b:	8b 55 b8             	mov    -0x48(%ebp),%edx
c010638e:	0f ab 10             	bts    %edx,(%eax)
        nr_free -= n;
c0106391:	a1 6c 31 1b c0       	mov    0xc01b316c,%eax
c0106396:	2b 45 08             	sub    0x8(%ebp),%eax
c0106399:	a3 6c 31 1b c0       	mov    %eax,0xc01b316c
        return p;
c010639e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01063a1:	eb 21                	jmp    c01063c4 <default_alloc_pages+0x17b>
c01063a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01063a6:	89 45 b0             	mov    %eax,-0x50(%ebp)
    return listelm->next;
c01063a9:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01063ac:	8b 40 04             	mov    0x4(%eax),%eax
    while((le=list_next(le)) != &free_list) {
c01063af:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01063b2:	81 7d f4 64 31 1b c0 	cmpl   $0xc01b3164,-0xc(%ebp)
c01063b9:	0f 85 da fe ff ff    	jne    c0106299 <default_alloc_pages+0x50>
      }
    }
    return NULL;//防止出错
c01063bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01063c4:	c9                   	leave  
c01063c5:	c3                   	ret    

c01063c6 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c01063c6:	55                   	push   %ebp
c01063c7:	89 e5                	mov    %esp,%ebp
c01063c9:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c01063cc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01063d0:	75 24                	jne    c01063f6 <default_free_pages+0x30>
c01063d2:	c7 44 24 0c ac d8 10 	movl   $0xc010d8ac,0xc(%esp)
c01063d9:	c0 
c01063da:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c01063e1:	c0 
c01063e2:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
c01063e9:	00 
c01063ea:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c01063f1:	e8 0f a0 ff ff       	call   c0100405 <__panic>
    //assert(PageReserved(base) && PageProperty(base));
    assert(PageReserved(base));
c01063f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01063f9:	83 c0 04             	add    $0x4,%eax
c01063fc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106403:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106406:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106409:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010640c:	0f a3 10             	bt     %edx,(%eax)
c010640f:	19 c0                	sbb    %eax,%eax
c0106411:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c0106414:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106418:	0f 95 c0             	setne  %al
c010641b:	0f b6 c0             	movzbl %al,%eax
c010641e:	85 c0                	test   %eax,%eax
c0106420:	75 24                	jne    c0106446 <default_free_pages+0x80>
c0106422:	c7 44 24 0c ed d8 10 	movl   $0xc010d8ed,0xc(%esp)
c0106429:	c0 
c010642a:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c0106431:	c0 
c0106432:	c7 44 24 04 a6 00 00 	movl   $0xa6,0x4(%esp)
c0106439:	00 
c010643a:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c0106441:	e8 bf 9f ff ff       	call   c0100405 <__panic>
    //检查需要释放的页块是否已经被分配,只要看bit 0 reserve就好了
    list_entry_t *le = &free_list;
c0106446:	c7 45 f4 64 31 1b c0 	movl   $0xc01b3164,-0xc(%ebp)
    struct Page * p;
    while((le=list_next(le)) != &free_list) {
c010644d:	eb 13                	jmp    c0106462 <default_free_pages+0x9c>
      p = le2page(le, page_link);
c010644f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106452:	83 e8 0c             	sub    $0xc,%eax
c0106455:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(p>base){break;}
c0106458:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010645b:	3b 45 08             	cmp    0x8(%ebp),%eax
c010645e:	76 02                	jbe    c0106462 <default_free_pages+0x9c>
c0106460:	eb 18                	jmp    c010647a <default_free_pages+0xb4>
c0106462:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106465:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106468:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010646b:	8b 40 04             	mov    0x4(%eax),%eax
    while((le=list_next(le)) != &free_list) {
c010646e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106471:	81 7d f4 64 31 1b c0 	cmpl   $0xc01b3164,-0xc(%ebp)
c0106478:	75 d5                	jne    c010644f <default_free_pages+0x89>
    }
    //将每一空闲块的链表插入空闲链表中
    for(p=base;p<base+n;p++){
c010647a:	8b 45 08             	mov    0x8(%ebp),%eax
c010647d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106480:	eb 4b                	jmp    c01064cd <default_free_pages+0x107>
      list_add_before(le, &(p->page_link));
c0106482:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106485:	8d 50 0c             	lea    0xc(%eax),%edx
c0106488:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010648b:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010648e:	89 55 d8             	mov    %edx,-0x28(%ebp)
    __list_add(elm, listelm->prev, listelm);
c0106491:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106494:	8b 00                	mov    (%eax),%eax
c0106496:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0106499:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010649c:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010649f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01064a2:	89 45 cc             	mov    %eax,-0x34(%ebp)
    prev->next = next->prev = elm;
c01064a5:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01064a8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01064ab:	89 10                	mov    %edx,(%eax)
c01064ad:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01064b0:	8b 10                	mov    (%eax),%edx
c01064b2:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01064b5:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01064b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01064bb:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01064be:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01064c1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01064c4:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01064c7:	89 10                	mov    %edx,(%eax)
    for(p=base;p<base+n;p++){
c01064c9:	83 45 f0 20          	addl   $0x20,-0x10(%ebp)
c01064cd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01064d0:	c1 e0 05             	shl    $0x5,%eax
c01064d3:	89 c2                	mov    %eax,%edx
c01064d5:	8b 45 08             	mov    0x8(%ebp),%eax
c01064d8:	01 d0                	add    %edx,%eax
c01064da:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01064dd:	77 a3                	ja     c0106482 <default_free_pages+0xbc>
    }
    //修改页的各个属性置0
    base->flags = 0;
c01064df:	8b 45 08             	mov    0x8(%ebp),%eax
c01064e2:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    set_page_ref(base, 0);
c01064e9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01064f0:	00 
c01064f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01064f4:	89 04 24             	mov    %eax,(%esp)
c01064f7:	e8 cb fb ff ff       	call   c01060c7 <set_page_ref>
    ClearPageProperty(base);
c01064fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01064ff:	83 c0 04             	add    $0x4,%eax
c0106502:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c0106509:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010650c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010650f:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0106512:	0f b3 10             	btr    %edx,(%eax)
    SetPageProperty(base);
c0106515:	8b 45 08             	mov    0x8(%ebp),%eax
c0106518:	83 c0 04             	add    $0x4,%eax
c010651b:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0106522:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0106525:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0106528:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010652b:	0f ab 10             	bts    %edx,(%eax)
    base->property = n;//有n空闲页
c010652e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106531:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106534:	89 50 08             	mov    %edx,0x8(%eax)
    p = le2page(le,page_link) ;
c0106537:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010653a:	83 e8 0c             	sub    $0xc,%eax
c010653d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    //和高位方向的下一个内存块的地址连续，向高位合并
    if( base+n == p ){
c0106540:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106543:	c1 e0 05             	shl    $0x5,%eax
c0106546:	89 c2                	mov    %eax,%edx
c0106548:	8b 45 08             	mov    0x8(%ebp),%eax
c010654b:	01 d0                	add    %edx,%eax
c010654d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0106550:	75 1e                	jne    c0106570 <default_free_pages+0x1aa>
      base->property += p->property;
c0106552:	8b 45 08             	mov    0x8(%ebp),%eax
c0106555:	8b 50 08             	mov    0x8(%eax),%edx
c0106558:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010655b:	8b 40 08             	mov    0x8(%eax),%eax
c010655e:	01 c2                	add    %eax,%edx
c0106560:	8b 45 08             	mov    0x8(%ebp),%eax
c0106563:	89 50 08             	mov    %edx,0x8(%eax)
      p->property = 0;
c0106566:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106569:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    }
    //如果是低位,向低地址合并
    //把le指针指向前一个内存块
    le = list_prev(&(base->page_link));  //previous
c0106570:	8b 45 08             	mov    0x8(%ebp),%eax
c0106573:	83 c0 0c             	add    $0xc,%eax
c0106576:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return listelm->prev;
c0106579:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010657c:	8b 00                	mov    (%eax),%eax
c010657e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    p = le2page(le, page_link);
c0106581:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106584:	83 e8 0c             	sub    $0xc,%eax
c0106587:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(le!=&free_list && p==base-1){
c010658a:	81 7d f4 64 31 1b c0 	cmpl   $0xc01b3164,-0xc(%ebp)
c0106591:	74 57                	je     c01065ea <default_free_pages+0x224>
c0106593:	8b 45 08             	mov    0x8(%ebp),%eax
c0106596:	83 e8 20             	sub    $0x20,%eax
c0106599:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010659c:	75 4c                	jne    c01065ea <default_free_pages+0x224>
      while(le!=&free_list){
c010659e:	eb 41                	jmp    c01065e1 <default_free_pages+0x21b>
        if(p->property){
c01065a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01065a3:	8b 40 08             	mov    0x8(%eax),%eax
c01065a6:	85 c0                	test   %eax,%eax
c01065a8:	74 20                	je     c01065ca <default_free_pages+0x204>
          p->property += base->property;
c01065aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01065ad:	8b 50 08             	mov    0x8(%eax),%edx
c01065b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01065b3:	8b 40 08             	mov    0x8(%eax),%eax
c01065b6:	01 c2                	add    %eax,%edx
c01065b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01065bb:	89 50 08             	mov    %edx,0x8(%eax)
          base->property = 0;
c01065be:	8b 45 08             	mov    0x8(%ebp),%eax
c01065c1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
          break;
c01065c8:	eb 20                	jmp    c01065ea <default_free_pages+0x224>
c01065ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01065cd:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c01065d0:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01065d3:	8b 00                	mov    (%eax),%eax
        }
        le = list_prev(le);
c01065d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
        p = le2page(le,page_link);
c01065d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01065db:	83 e8 0c             	sub    $0xc,%eax
c01065de:	89 45 f0             	mov    %eax,-0x10(%ebp)
      while(le!=&free_list){
c01065e1:	81 7d f4 64 31 1b c0 	cmpl   $0xc01b3164,-0xc(%ebp)
c01065e8:	75 b6                	jne    c01065a0 <default_free_pages+0x1da>
      }
    }
   //更新总空闲页数
    nr_free += n;
c01065ea:	8b 15 6c 31 1b c0    	mov    0xc01b316c,%edx
c01065f0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01065f3:	01 d0                	add    %edx,%eax
c01065f5:	a3 6c 31 1b c0       	mov    %eax,0xc01b316c
    return ;
c01065fa:	90                   	nop
}
c01065fb:	c9                   	leave  
c01065fc:	c3                   	ret    

c01065fd <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c01065fd:	55                   	push   %ebp
c01065fe:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0106600:	a1 6c 31 1b c0       	mov    0xc01b316c,%eax
}
c0106605:	5d                   	pop    %ebp
c0106606:	c3                   	ret    

c0106607 <basic_check>:

static void
basic_check(void) {
c0106607:	55                   	push   %ebp
c0106608:	89 e5                	mov    %esp,%ebp
c010660a:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c010660d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0106614:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106617:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010661a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010661d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0106620:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106627:	e8 8d 0e 00 00       	call   c01074b9 <alloc_pages>
c010662c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010662f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0106633:	75 24                	jne    c0106659 <basic_check+0x52>
c0106635:	c7 44 24 0c 00 d9 10 	movl   $0xc010d900,0xc(%esp)
c010663c:	c0 
c010663d:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c0106644:	c0 
c0106645:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c010664c:	00 
c010664d:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c0106654:	e8 ac 9d ff ff       	call   c0100405 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0106659:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106660:	e8 54 0e 00 00       	call   c01074b9 <alloc_pages>
c0106665:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106668:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010666c:	75 24                	jne    c0106692 <basic_check+0x8b>
c010666e:	c7 44 24 0c 1c d9 10 	movl   $0xc010d91c,0xc(%esp)
c0106675:	c0 
c0106676:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c010667d:	c0 
c010667e:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c0106685:	00 
c0106686:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c010668d:	e8 73 9d ff ff       	call   c0100405 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0106692:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106699:	e8 1b 0e 00 00       	call   c01074b9 <alloc_pages>
c010669e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01066a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01066a5:	75 24                	jne    c01066cb <basic_check+0xc4>
c01066a7:	c7 44 24 0c 38 d9 10 	movl   $0xc010d938,0xc(%esp)
c01066ae:	c0 
c01066af:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c01066b6:	c0 
c01066b7:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
c01066be:	00 
c01066bf:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c01066c6:	e8 3a 9d ff ff       	call   c0100405 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c01066cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01066ce:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01066d1:	74 10                	je     c01066e3 <basic_check+0xdc>
c01066d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01066d6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01066d9:	74 08                	je     c01066e3 <basic_check+0xdc>
c01066db:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01066de:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01066e1:	75 24                	jne    c0106707 <basic_check+0x100>
c01066e3:	c7 44 24 0c 54 d9 10 	movl   $0xc010d954,0xc(%esp)
c01066ea:	c0 
c01066eb:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c01066f2:	c0 
c01066f3:	c7 44 24 04 df 00 00 	movl   $0xdf,0x4(%esp)
c01066fa:	00 
c01066fb:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c0106702:	e8 fe 9c ff ff       	call   c0100405 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0106707:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010670a:	89 04 24             	mov    %eax,(%esp)
c010670d:	e8 ab f9 ff ff       	call   c01060bd <page_ref>
c0106712:	85 c0                	test   %eax,%eax
c0106714:	75 1e                	jne    c0106734 <basic_check+0x12d>
c0106716:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106719:	89 04 24             	mov    %eax,(%esp)
c010671c:	e8 9c f9 ff ff       	call   c01060bd <page_ref>
c0106721:	85 c0                	test   %eax,%eax
c0106723:	75 0f                	jne    c0106734 <basic_check+0x12d>
c0106725:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106728:	89 04 24             	mov    %eax,(%esp)
c010672b:	e8 8d f9 ff ff       	call   c01060bd <page_ref>
c0106730:	85 c0                	test   %eax,%eax
c0106732:	74 24                	je     c0106758 <basic_check+0x151>
c0106734:	c7 44 24 0c 78 d9 10 	movl   $0xc010d978,0xc(%esp)
c010673b:	c0 
c010673c:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c0106743:	c0 
c0106744:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
c010674b:	00 
c010674c:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c0106753:	e8 ad 9c ff ff       	call   c0100405 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0106758:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010675b:	89 04 24             	mov    %eax,(%esp)
c010675e:	e8 44 f9 ff ff       	call   c01060a7 <page2pa>
c0106763:	8b 15 80 0f 1b c0    	mov    0xc01b0f80,%edx
c0106769:	c1 e2 0c             	shl    $0xc,%edx
c010676c:	39 d0                	cmp    %edx,%eax
c010676e:	72 24                	jb     c0106794 <basic_check+0x18d>
c0106770:	c7 44 24 0c b4 d9 10 	movl   $0xc010d9b4,0xc(%esp)
c0106777:	c0 
c0106778:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c010677f:	c0 
c0106780:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
c0106787:	00 
c0106788:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c010678f:	e8 71 9c ff ff       	call   c0100405 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0106794:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106797:	89 04 24             	mov    %eax,(%esp)
c010679a:	e8 08 f9 ff ff       	call   c01060a7 <page2pa>
c010679f:	8b 15 80 0f 1b c0    	mov    0xc01b0f80,%edx
c01067a5:	c1 e2 0c             	shl    $0xc,%edx
c01067a8:	39 d0                	cmp    %edx,%eax
c01067aa:	72 24                	jb     c01067d0 <basic_check+0x1c9>
c01067ac:	c7 44 24 0c d1 d9 10 	movl   $0xc010d9d1,0xc(%esp)
c01067b3:	c0 
c01067b4:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c01067bb:	c0 
c01067bc:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c01067c3:	00 
c01067c4:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c01067cb:	e8 35 9c ff ff       	call   c0100405 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c01067d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01067d3:	89 04 24             	mov    %eax,(%esp)
c01067d6:	e8 cc f8 ff ff       	call   c01060a7 <page2pa>
c01067db:	8b 15 80 0f 1b c0    	mov    0xc01b0f80,%edx
c01067e1:	c1 e2 0c             	shl    $0xc,%edx
c01067e4:	39 d0                	cmp    %edx,%eax
c01067e6:	72 24                	jb     c010680c <basic_check+0x205>
c01067e8:	c7 44 24 0c ee d9 10 	movl   $0xc010d9ee,0xc(%esp)
c01067ef:	c0 
c01067f0:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c01067f7:	c0 
c01067f8:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
c01067ff:	00 
c0106800:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c0106807:	e8 f9 9b ff ff       	call   c0100405 <__panic>

    list_entry_t free_list_store = free_list;
c010680c:	a1 64 31 1b c0       	mov    0xc01b3164,%eax
c0106811:	8b 15 68 31 1b c0    	mov    0xc01b3168,%edx
c0106817:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010681a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010681d:	c7 45 e0 64 31 1b c0 	movl   $0xc01b3164,-0x20(%ebp)
    elm->prev = elm->next = elm;
c0106824:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106827:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010682a:	89 50 04             	mov    %edx,0x4(%eax)
c010682d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106830:	8b 50 04             	mov    0x4(%eax),%edx
c0106833:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106836:	89 10                	mov    %edx,(%eax)
c0106838:	c7 45 dc 64 31 1b c0 	movl   $0xc01b3164,-0x24(%ebp)
    return list->next == list;
c010683f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106842:	8b 40 04             	mov    0x4(%eax),%eax
c0106845:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0106848:	0f 94 c0             	sete   %al
c010684b:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c010684e:	85 c0                	test   %eax,%eax
c0106850:	75 24                	jne    c0106876 <basic_check+0x26f>
c0106852:	c7 44 24 0c 0b da 10 	movl   $0xc010da0b,0xc(%esp)
c0106859:	c0 
c010685a:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c0106861:	c0 
c0106862:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
c0106869:	00 
c010686a:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c0106871:	e8 8f 9b ff ff       	call   c0100405 <__panic>

    unsigned int nr_free_store = nr_free;
c0106876:	a1 6c 31 1b c0       	mov    0xc01b316c,%eax
c010687b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c010687e:	c7 05 6c 31 1b c0 00 	movl   $0x0,0xc01b316c
c0106885:	00 00 00 

    assert(alloc_page() == NULL);
c0106888:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010688f:	e8 25 0c 00 00       	call   c01074b9 <alloc_pages>
c0106894:	85 c0                	test   %eax,%eax
c0106896:	74 24                	je     c01068bc <basic_check+0x2b5>
c0106898:	c7 44 24 0c 22 da 10 	movl   $0xc010da22,0xc(%esp)
c010689f:	c0 
c01068a0:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c01068a7:	c0 
c01068a8:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
c01068af:	00 
c01068b0:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c01068b7:	e8 49 9b ff ff       	call   c0100405 <__panic>

    free_page(p0);
c01068bc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01068c3:	00 
c01068c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01068c7:	89 04 24             	mov    %eax,(%esp)
c01068ca:	e8 55 0c 00 00       	call   c0107524 <free_pages>
    free_page(p1);
c01068cf:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01068d6:	00 
c01068d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01068da:	89 04 24             	mov    %eax,(%esp)
c01068dd:	e8 42 0c 00 00       	call   c0107524 <free_pages>
    free_page(p2);
c01068e2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01068e9:	00 
c01068ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01068ed:	89 04 24             	mov    %eax,(%esp)
c01068f0:	e8 2f 0c 00 00       	call   c0107524 <free_pages>
    assert(nr_free == 3);
c01068f5:	a1 6c 31 1b c0       	mov    0xc01b316c,%eax
c01068fa:	83 f8 03             	cmp    $0x3,%eax
c01068fd:	74 24                	je     c0106923 <basic_check+0x31c>
c01068ff:	c7 44 24 0c 37 da 10 	movl   $0xc010da37,0xc(%esp)
c0106906:	c0 
c0106907:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c010690e:	c0 
c010690f:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
c0106916:	00 
c0106917:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c010691e:	e8 e2 9a ff ff       	call   c0100405 <__panic>

    assert((p0 = alloc_page()) != NULL);
c0106923:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010692a:	e8 8a 0b 00 00       	call   c01074b9 <alloc_pages>
c010692f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106932:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0106936:	75 24                	jne    c010695c <basic_check+0x355>
c0106938:	c7 44 24 0c 00 d9 10 	movl   $0xc010d900,0xc(%esp)
c010693f:	c0 
c0106940:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c0106947:	c0 
c0106948:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
c010694f:	00 
c0106950:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c0106957:	e8 a9 9a ff ff       	call   c0100405 <__panic>
    assert((p1 = alloc_page()) != NULL);
c010695c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106963:	e8 51 0b 00 00       	call   c01074b9 <alloc_pages>
c0106968:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010696b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010696f:	75 24                	jne    c0106995 <basic_check+0x38e>
c0106971:	c7 44 24 0c 1c d9 10 	movl   $0xc010d91c,0xc(%esp)
c0106978:	c0 
c0106979:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c0106980:	c0 
c0106981:	c7 44 24 04 f5 00 00 	movl   $0xf5,0x4(%esp)
c0106988:	00 
c0106989:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c0106990:	e8 70 9a ff ff       	call   c0100405 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0106995:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010699c:	e8 18 0b 00 00       	call   c01074b9 <alloc_pages>
c01069a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01069a4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01069a8:	75 24                	jne    c01069ce <basic_check+0x3c7>
c01069aa:	c7 44 24 0c 38 d9 10 	movl   $0xc010d938,0xc(%esp)
c01069b1:	c0 
c01069b2:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c01069b9:	c0 
c01069ba:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
c01069c1:	00 
c01069c2:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c01069c9:	e8 37 9a ff ff       	call   c0100405 <__panic>

    assert(alloc_page() == NULL);
c01069ce:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01069d5:	e8 df 0a 00 00       	call   c01074b9 <alloc_pages>
c01069da:	85 c0                	test   %eax,%eax
c01069dc:	74 24                	je     c0106a02 <basic_check+0x3fb>
c01069de:	c7 44 24 0c 22 da 10 	movl   $0xc010da22,0xc(%esp)
c01069e5:	c0 
c01069e6:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c01069ed:	c0 
c01069ee:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c01069f5:	00 
c01069f6:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c01069fd:	e8 03 9a ff ff       	call   c0100405 <__panic>

    free_page(p0);
c0106a02:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106a09:	00 
c0106a0a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106a0d:	89 04 24             	mov    %eax,(%esp)
c0106a10:	e8 0f 0b 00 00       	call   c0107524 <free_pages>
c0106a15:	c7 45 d8 64 31 1b c0 	movl   $0xc01b3164,-0x28(%ebp)
c0106a1c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106a1f:	8b 40 04             	mov    0x4(%eax),%eax
c0106a22:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0106a25:	0f 94 c0             	sete   %al
c0106a28:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0106a2b:	85 c0                	test   %eax,%eax
c0106a2d:	74 24                	je     c0106a53 <basic_check+0x44c>
c0106a2f:	c7 44 24 0c 44 da 10 	movl   $0xc010da44,0xc(%esp)
c0106a36:	c0 
c0106a37:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c0106a3e:	c0 
c0106a3f:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c0106a46:	00 
c0106a47:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c0106a4e:	e8 b2 99 ff ff       	call   c0100405 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0106a53:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106a5a:	e8 5a 0a 00 00       	call   c01074b9 <alloc_pages>
c0106a5f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106a62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106a65:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0106a68:	74 24                	je     c0106a8e <basic_check+0x487>
c0106a6a:	c7 44 24 0c 5c da 10 	movl   $0xc010da5c,0xc(%esp)
c0106a71:	c0 
c0106a72:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c0106a79:	c0 
c0106a7a:	c7 44 24 04 fe 00 00 	movl   $0xfe,0x4(%esp)
c0106a81:	00 
c0106a82:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c0106a89:	e8 77 99 ff ff       	call   c0100405 <__panic>
    assert(alloc_page() == NULL);
c0106a8e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106a95:	e8 1f 0a 00 00       	call   c01074b9 <alloc_pages>
c0106a9a:	85 c0                	test   %eax,%eax
c0106a9c:	74 24                	je     c0106ac2 <basic_check+0x4bb>
c0106a9e:	c7 44 24 0c 22 da 10 	movl   $0xc010da22,0xc(%esp)
c0106aa5:	c0 
c0106aa6:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c0106aad:	c0 
c0106aae:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
c0106ab5:	00 
c0106ab6:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c0106abd:	e8 43 99 ff ff       	call   c0100405 <__panic>

    assert(nr_free == 0);
c0106ac2:	a1 6c 31 1b c0       	mov    0xc01b316c,%eax
c0106ac7:	85 c0                	test   %eax,%eax
c0106ac9:	74 24                	je     c0106aef <basic_check+0x4e8>
c0106acb:	c7 44 24 0c 75 da 10 	movl   $0xc010da75,0xc(%esp)
c0106ad2:	c0 
c0106ad3:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c0106ada:	c0 
c0106adb:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c0106ae2:	00 
c0106ae3:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c0106aea:	e8 16 99 ff ff       	call   c0100405 <__panic>
    free_list = free_list_store;
c0106aef:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106af2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106af5:	a3 64 31 1b c0       	mov    %eax,0xc01b3164
c0106afa:	89 15 68 31 1b c0    	mov    %edx,0xc01b3168
    nr_free = nr_free_store;
c0106b00:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106b03:	a3 6c 31 1b c0       	mov    %eax,0xc01b316c

    free_page(p);
c0106b08:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106b0f:	00 
c0106b10:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106b13:	89 04 24             	mov    %eax,(%esp)
c0106b16:	e8 09 0a 00 00       	call   c0107524 <free_pages>
    free_page(p1);
c0106b1b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106b22:	00 
c0106b23:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106b26:	89 04 24             	mov    %eax,(%esp)
c0106b29:	e8 f6 09 00 00       	call   c0107524 <free_pages>
    free_page(p2);
c0106b2e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106b35:	00 
c0106b36:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106b39:	89 04 24             	mov    %eax,(%esp)
c0106b3c:	e8 e3 09 00 00       	call   c0107524 <free_pages>
}
c0106b41:	c9                   	leave  
c0106b42:	c3                   	ret    

c0106b43 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0106b43:	55                   	push   %ebp
c0106b44:	89 e5                	mov    %esp,%ebp
c0106b46:	53                   	push   %ebx
c0106b47:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
c0106b4d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0106b54:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0106b5b:	c7 45 ec 64 31 1b c0 	movl   $0xc01b3164,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0106b62:	eb 6b                	jmp    c0106bcf <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
c0106b64:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106b67:	83 e8 0c             	sub    $0xc,%eax
c0106b6a:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
c0106b6d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106b70:	83 c0 04             	add    $0x4,%eax
c0106b73:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0106b7a:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106b7d:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0106b80:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0106b83:	0f a3 10             	bt     %edx,(%eax)
c0106b86:	19 c0                	sbb    %eax,%eax
c0106b88:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0106b8b:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0106b8f:	0f 95 c0             	setne  %al
c0106b92:	0f b6 c0             	movzbl %al,%eax
c0106b95:	85 c0                	test   %eax,%eax
c0106b97:	75 24                	jne    c0106bbd <default_check+0x7a>
c0106b99:	c7 44 24 0c 82 da 10 	movl   $0xc010da82,0xc(%esp)
c0106ba0:	c0 
c0106ba1:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c0106ba8:	c0 
c0106ba9:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
c0106bb0:	00 
c0106bb1:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c0106bb8:	e8 48 98 ff ff       	call   c0100405 <__panic>
        count ++, total += p->property;
c0106bbd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0106bc1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106bc4:	8b 50 08             	mov    0x8(%eax),%edx
c0106bc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106bca:	01 d0                	add    %edx,%eax
c0106bcc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106bcf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106bd2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c0106bd5:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0106bd8:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0106bdb:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106bde:	81 7d ec 64 31 1b c0 	cmpl   $0xc01b3164,-0x14(%ebp)
c0106be5:	0f 85 79 ff ff ff    	jne    c0106b64 <default_check+0x21>
    }
    assert(total == nr_free_pages());
c0106beb:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c0106bee:	e8 63 09 00 00       	call   c0107556 <nr_free_pages>
c0106bf3:	39 c3                	cmp    %eax,%ebx
c0106bf5:	74 24                	je     c0106c1b <default_check+0xd8>
c0106bf7:	c7 44 24 0c 92 da 10 	movl   $0xc010da92,0xc(%esp)
c0106bfe:	c0 
c0106bff:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c0106c06:	c0 
c0106c07:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c0106c0e:	00 
c0106c0f:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c0106c16:	e8 ea 97 ff ff       	call   c0100405 <__panic>

    basic_check();
c0106c1b:	e8 e7 f9 ff ff       	call   c0106607 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0106c20:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0106c27:	e8 8d 08 00 00       	call   c01074b9 <alloc_pages>
c0106c2c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
c0106c2f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106c33:	75 24                	jne    c0106c59 <default_check+0x116>
c0106c35:	c7 44 24 0c ab da 10 	movl   $0xc010daab,0xc(%esp)
c0106c3c:	c0 
c0106c3d:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c0106c44:	c0 
c0106c45:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c0106c4c:	00 
c0106c4d:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c0106c54:	e8 ac 97 ff ff       	call   c0100405 <__panic>
    assert(!PageProperty(p0));
c0106c59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106c5c:	83 c0 04             	add    $0x4,%eax
c0106c5f:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0106c66:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106c69:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0106c6c:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0106c6f:	0f a3 10             	bt     %edx,(%eax)
c0106c72:	19 c0                	sbb    %eax,%eax
c0106c74:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0106c77:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0106c7b:	0f 95 c0             	setne  %al
c0106c7e:	0f b6 c0             	movzbl %al,%eax
c0106c81:	85 c0                	test   %eax,%eax
c0106c83:	74 24                	je     c0106ca9 <default_check+0x166>
c0106c85:	c7 44 24 0c b6 da 10 	movl   $0xc010dab6,0xc(%esp)
c0106c8c:	c0 
c0106c8d:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c0106c94:	c0 
c0106c95:	c7 44 24 04 1b 01 00 	movl   $0x11b,0x4(%esp)
c0106c9c:	00 
c0106c9d:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c0106ca4:	e8 5c 97 ff ff       	call   c0100405 <__panic>

    list_entry_t free_list_store = free_list;
c0106ca9:	a1 64 31 1b c0       	mov    0xc01b3164,%eax
c0106cae:	8b 15 68 31 1b c0    	mov    0xc01b3168,%edx
c0106cb4:	89 45 80             	mov    %eax,-0x80(%ebp)
c0106cb7:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0106cba:	c7 45 b4 64 31 1b c0 	movl   $0xc01b3164,-0x4c(%ebp)
    elm->prev = elm->next = elm;
c0106cc1:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0106cc4:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0106cc7:	89 50 04             	mov    %edx,0x4(%eax)
c0106cca:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0106ccd:	8b 50 04             	mov    0x4(%eax),%edx
c0106cd0:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0106cd3:	89 10                	mov    %edx,(%eax)
c0106cd5:	c7 45 b0 64 31 1b c0 	movl   $0xc01b3164,-0x50(%ebp)
    return list->next == list;
c0106cdc:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0106cdf:	8b 40 04             	mov    0x4(%eax),%eax
c0106ce2:	39 45 b0             	cmp    %eax,-0x50(%ebp)
c0106ce5:	0f 94 c0             	sete   %al
c0106ce8:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0106ceb:	85 c0                	test   %eax,%eax
c0106ced:	75 24                	jne    c0106d13 <default_check+0x1d0>
c0106cef:	c7 44 24 0c 0b da 10 	movl   $0xc010da0b,0xc(%esp)
c0106cf6:	c0 
c0106cf7:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c0106cfe:	c0 
c0106cff:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
c0106d06:	00 
c0106d07:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c0106d0e:	e8 f2 96 ff ff       	call   c0100405 <__panic>
    assert(alloc_page() == NULL);
c0106d13:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106d1a:	e8 9a 07 00 00       	call   c01074b9 <alloc_pages>
c0106d1f:	85 c0                	test   %eax,%eax
c0106d21:	74 24                	je     c0106d47 <default_check+0x204>
c0106d23:	c7 44 24 0c 22 da 10 	movl   $0xc010da22,0xc(%esp)
c0106d2a:	c0 
c0106d2b:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c0106d32:	c0 
c0106d33:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
c0106d3a:	00 
c0106d3b:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c0106d42:	e8 be 96 ff ff       	call   c0100405 <__panic>

    unsigned int nr_free_store = nr_free;
c0106d47:	a1 6c 31 1b c0       	mov    0xc01b316c,%eax
c0106d4c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c0106d4f:	c7 05 6c 31 1b c0 00 	movl   $0x0,0xc01b316c
c0106d56:	00 00 00 

    free_pages(p0 + 2, 3);
c0106d59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106d5c:	83 c0 40             	add    $0x40,%eax
c0106d5f:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0106d66:	00 
c0106d67:	89 04 24             	mov    %eax,(%esp)
c0106d6a:	e8 b5 07 00 00       	call   c0107524 <free_pages>
    assert(alloc_pages(4) == NULL);
c0106d6f:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0106d76:	e8 3e 07 00 00       	call   c01074b9 <alloc_pages>
c0106d7b:	85 c0                	test   %eax,%eax
c0106d7d:	74 24                	je     c0106da3 <default_check+0x260>
c0106d7f:	c7 44 24 0c c8 da 10 	movl   $0xc010dac8,0xc(%esp)
c0106d86:	c0 
c0106d87:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c0106d8e:	c0 
c0106d8f:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
c0106d96:	00 
c0106d97:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c0106d9e:	e8 62 96 ff ff       	call   c0100405 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0106da3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106da6:	83 c0 40             	add    $0x40,%eax
c0106da9:	83 c0 04             	add    $0x4,%eax
c0106dac:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c0106db3:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106db6:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0106db9:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0106dbc:	0f a3 10             	bt     %edx,(%eax)
c0106dbf:	19 c0                	sbb    %eax,%eax
c0106dc1:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c0106dc4:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0106dc8:	0f 95 c0             	setne  %al
c0106dcb:	0f b6 c0             	movzbl %al,%eax
c0106dce:	85 c0                	test   %eax,%eax
c0106dd0:	74 0e                	je     c0106de0 <default_check+0x29d>
c0106dd2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106dd5:	83 c0 40             	add    $0x40,%eax
c0106dd8:	8b 40 08             	mov    0x8(%eax),%eax
c0106ddb:	83 f8 03             	cmp    $0x3,%eax
c0106dde:	74 24                	je     c0106e04 <default_check+0x2c1>
c0106de0:	c7 44 24 0c e0 da 10 	movl   $0xc010dae0,0xc(%esp)
c0106de7:	c0 
c0106de8:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c0106def:	c0 
c0106df0:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
c0106df7:	00 
c0106df8:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c0106dff:	e8 01 96 ff ff       	call   c0100405 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0106e04:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0106e0b:	e8 a9 06 00 00       	call   c01074b9 <alloc_pages>
c0106e10:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0106e13:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0106e17:	75 24                	jne    c0106e3d <default_check+0x2fa>
c0106e19:	c7 44 24 0c 0c db 10 	movl   $0xc010db0c,0xc(%esp)
c0106e20:	c0 
c0106e21:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c0106e28:	c0 
c0106e29:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
c0106e30:	00 
c0106e31:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c0106e38:	e8 c8 95 ff ff       	call   c0100405 <__panic>
    assert(alloc_page() == NULL);
c0106e3d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106e44:	e8 70 06 00 00       	call   c01074b9 <alloc_pages>
c0106e49:	85 c0                	test   %eax,%eax
c0106e4b:	74 24                	je     c0106e71 <default_check+0x32e>
c0106e4d:	c7 44 24 0c 22 da 10 	movl   $0xc010da22,0xc(%esp)
c0106e54:	c0 
c0106e55:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c0106e5c:	c0 
c0106e5d:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
c0106e64:	00 
c0106e65:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c0106e6c:	e8 94 95 ff ff       	call   c0100405 <__panic>
    assert(p0 + 2 == p1);
c0106e71:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106e74:	83 c0 40             	add    $0x40,%eax
c0106e77:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0106e7a:	74 24                	je     c0106ea0 <default_check+0x35d>
c0106e7c:	c7 44 24 0c 2a db 10 	movl   $0xc010db2a,0xc(%esp)
c0106e83:	c0 
c0106e84:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c0106e8b:	c0 
c0106e8c:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
c0106e93:	00 
c0106e94:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c0106e9b:	e8 65 95 ff ff       	call   c0100405 <__panic>

    p2 = p0 + 1;
c0106ea0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106ea3:	83 c0 20             	add    $0x20,%eax
c0106ea6:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
c0106ea9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106eb0:	00 
c0106eb1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106eb4:	89 04 24             	mov    %eax,(%esp)
c0106eb7:	e8 68 06 00 00       	call   c0107524 <free_pages>
    free_pages(p1, 3);
c0106ebc:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0106ec3:	00 
c0106ec4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106ec7:	89 04 24             	mov    %eax,(%esp)
c0106eca:	e8 55 06 00 00       	call   c0107524 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c0106ecf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106ed2:	83 c0 04             	add    $0x4,%eax
c0106ed5:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0106edc:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106edf:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0106ee2:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0106ee5:	0f a3 10             	bt     %edx,(%eax)
c0106ee8:	19 c0                	sbb    %eax,%eax
c0106eea:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0106eed:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0106ef1:	0f 95 c0             	setne  %al
c0106ef4:	0f b6 c0             	movzbl %al,%eax
c0106ef7:	85 c0                	test   %eax,%eax
c0106ef9:	74 0b                	je     c0106f06 <default_check+0x3c3>
c0106efb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106efe:	8b 40 08             	mov    0x8(%eax),%eax
c0106f01:	83 f8 01             	cmp    $0x1,%eax
c0106f04:	74 24                	je     c0106f2a <default_check+0x3e7>
c0106f06:	c7 44 24 0c 38 db 10 	movl   $0xc010db38,0xc(%esp)
c0106f0d:	c0 
c0106f0e:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c0106f15:	c0 
c0106f16:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
c0106f1d:	00 
c0106f1e:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c0106f25:	e8 db 94 ff ff       	call   c0100405 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0106f2a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106f2d:	83 c0 04             	add    $0x4,%eax
c0106f30:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c0106f37:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106f3a:	8b 45 90             	mov    -0x70(%ebp),%eax
c0106f3d:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0106f40:	0f a3 10             	bt     %edx,(%eax)
c0106f43:	19 c0                	sbb    %eax,%eax
c0106f45:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c0106f48:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c0106f4c:	0f 95 c0             	setne  %al
c0106f4f:	0f b6 c0             	movzbl %al,%eax
c0106f52:	85 c0                	test   %eax,%eax
c0106f54:	74 0b                	je     c0106f61 <default_check+0x41e>
c0106f56:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106f59:	8b 40 08             	mov    0x8(%eax),%eax
c0106f5c:	83 f8 03             	cmp    $0x3,%eax
c0106f5f:	74 24                	je     c0106f85 <default_check+0x442>
c0106f61:	c7 44 24 0c 60 db 10 	movl   $0xc010db60,0xc(%esp)
c0106f68:	c0 
c0106f69:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c0106f70:	c0 
c0106f71:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
c0106f78:	00 
c0106f79:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c0106f80:	e8 80 94 ff ff       	call   c0100405 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c0106f85:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106f8c:	e8 28 05 00 00       	call   c01074b9 <alloc_pages>
c0106f91:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106f94:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106f97:	83 e8 20             	sub    $0x20,%eax
c0106f9a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0106f9d:	74 24                	je     c0106fc3 <default_check+0x480>
c0106f9f:	c7 44 24 0c 86 db 10 	movl   $0xc010db86,0xc(%esp)
c0106fa6:	c0 
c0106fa7:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c0106fae:	c0 
c0106faf:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
c0106fb6:	00 
c0106fb7:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c0106fbe:	e8 42 94 ff ff       	call   c0100405 <__panic>
    free_page(p0);
c0106fc3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106fca:	00 
c0106fcb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106fce:	89 04 24             	mov    %eax,(%esp)
c0106fd1:	e8 4e 05 00 00       	call   c0107524 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c0106fd6:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0106fdd:	e8 d7 04 00 00       	call   c01074b9 <alloc_pages>
c0106fe2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106fe5:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106fe8:	83 c0 20             	add    $0x20,%eax
c0106feb:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0106fee:	74 24                	je     c0107014 <default_check+0x4d1>
c0106ff0:	c7 44 24 0c a4 db 10 	movl   $0xc010dba4,0xc(%esp)
c0106ff7:	c0 
c0106ff8:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c0106fff:	c0 
c0107000:	c7 44 24 04 34 01 00 	movl   $0x134,0x4(%esp)
c0107007:	00 
c0107008:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c010700f:	e8 f1 93 ff ff       	call   c0100405 <__panic>

    free_pages(p0, 2);
c0107014:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c010701b:	00 
c010701c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010701f:	89 04 24             	mov    %eax,(%esp)
c0107022:	e8 fd 04 00 00       	call   c0107524 <free_pages>
    free_page(p2);
c0107027:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010702e:	00 
c010702f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107032:	89 04 24             	mov    %eax,(%esp)
c0107035:	e8 ea 04 00 00       	call   c0107524 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c010703a:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0107041:	e8 73 04 00 00       	call   c01074b9 <alloc_pages>
c0107046:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107049:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010704d:	75 24                	jne    c0107073 <default_check+0x530>
c010704f:	c7 44 24 0c c4 db 10 	movl   $0xc010dbc4,0xc(%esp)
c0107056:	c0 
c0107057:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c010705e:	c0 
c010705f:	c7 44 24 04 39 01 00 	movl   $0x139,0x4(%esp)
c0107066:	00 
c0107067:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c010706e:	e8 92 93 ff ff       	call   c0100405 <__panic>
    assert(alloc_page() == NULL);
c0107073:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010707a:	e8 3a 04 00 00       	call   c01074b9 <alloc_pages>
c010707f:	85 c0                	test   %eax,%eax
c0107081:	74 24                	je     c01070a7 <default_check+0x564>
c0107083:	c7 44 24 0c 22 da 10 	movl   $0xc010da22,0xc(%esp)
c010708a:	c0 
c010708b:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c0107092:	c0 
c0107093:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
c010709a:	00 
c010709b:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c01070a2:	e8 5e 93 ff ff       	call   c0100405 <__panic>

    assert(nr_free == 0);
c01070a7:	a1 6c 31 1b c0       	mov    0xc01b316c,%eax
c01070ac:	85 c0                	test   %eax,%eax
c01070ae:	74 24                	je     c01070d4 <default_check+0x591>
c01070b0:	c7 44 24 0c 75 da 10 	movl   $0xc010da75,0xc(%esp)
c01070b7:	c0 
c01070b8:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c01070bf:	c0 
c01070c0:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
c01070c7:	00 
c01070c8:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c01070cf:	e8 31 93 ff ff       	call   c0100405 <__panic>
    nr_free = nr_free_store;
c01070d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01070d7:	a3 6c 31 1b c0       	mov    %eax,0xc01b316c

    free_list = free_list_store;
c01070dc:	8b 45 80             	mov    -0x80(%ebp),%eax
c01070df:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01070e2:	a3 64 31 1b c0       	mov    %eax,0xc01b3164
c01070e7:	89 15 68 31 1b c0    	mov    %edx,0xc01b3168
    free_pages(p0, 5);
c01070ed:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c01070f4:	00 
c01070f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01070f8:	89 04 24             	mov    %eax,(%esp)
c01070fb:	e8 24 04 00 00       	call   c0107524 <free_pages>

    le = &free_list;
c0107100:	c7 45 ec 64 31 1b c0 	movl   $0xc01b3164,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0107107:	eb 1d                	jmp    c0107126 <default_check+0x5e3>
        struct Page *p = le2page(le, page_link);
c0107109:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010710c:	83 e8 0c             	sub    $0xc,%eax
c010710f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
c0107112:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0107116:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0107119:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010711c:	8b 40 08             	mov    0x8(%eax),%eax
c010711f:	29 c2                	sub    %eax,%edx
c0107121:	89 d0                	mov    %edx,%eax
c0107123:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107126:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107129:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c010712c:	8b 45 88             	mov    -0x78(%ebp),%eax
c010712f:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0107132:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107135:	81 7d ec 64 31 1b c0 	cmpl   $0xc01b3164,-0x14(%ebp)
c010713c:	75 cb                	jne    c0107109 <default_check+0x5c6>
    }
    assert(count == 0);
c010713e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107142:	74 24                	je     c0107168 <default_check+0x625>
c0107144:	c7 44 24 0c e2 db 10 	movl   $0xc010dbe2,0xc(%esp)
c010714b:	c0 
c010714c:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c0107153:	c0 
c0107154:	c7 44 24 04 47 01 00 	movl   $0x147,0x4(%esp)
c010715b:	00 
c010715c:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c0107163:	e8 9d 92 ff ff       	call   c0100405 <__panic>
    assert(total == 0);
c0107168:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010716c:	74 24                	je     c0107192 <default_check+0x64f>
c010716e:	c7 44 24 0c ed db 10 	movl   $0xc010dbed,0xc(%esp)
c0107175:	c0 
c0107176:	c7 44 24 08 b2 d8 10 	movl   $0xc010d8b2,0x8(%esp)
c010717d:	c0 
c010717e:	c7 44 24 04 48 01 00 	movl   $0x148,0x4(%esp)
c0107185:	00 
c0107186:	c7 04 24 c7 d8 10 c0 	movl   $0xc010d8c7,(%esp)
c010718d:	e8 73 92 ff ff       	call   c0100405 <__panic>
}
c0107192:	81 c4 94 00 00 00    	add    $0x94,%esp
c0107198:	5b                   	pop    %ebx
c0107199:	5d                   	pop    %ebp
c010719a:	c3                   	ret    

c010719b <page2ppn>:
page2ppn(struct Page *page) {
c010719b:	55                   	push   %ebp
c010719c:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010719e:	8b 55 08             	mov    0x8(%ebp),%edx
c01071a1:	a1 78 31 1b c0       	mov    0xc01b3178,%eax
c01071a6:	29 c2                	sub    %eax,%edx
c01071a8:	89 d0                	mov    %edx,%eax
c01071aa:	c1 f8 05             	sar    $0x5,%eax
}
c01071ad:	5d                   	pop    %ebp
c01071ae:	c3                   	ret    

c01071af <page2pa>:
page2pa(struct Page *page) {
c01071af:	55                   	push   %ebp
c01071b0:	89 e5                	mov    %esp,%ebp
c01071b2:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01071b5:	8b 45 08             	mov    0x8(%ebp),%eax
c01071b8:	89 04 24             	mov    %eax,(%esp)
c01071bb:	e8 db ff ff ff       	call   c010719b <page2ppn>
c01071c0:	c1 e0 0c             	shl    $0xc,%eax
}
c01071c3:	c9                   	leave  
c01071c4:	c3                   	ret    

c01071c5 <pa2page>:
pa2page(uintptr_t pa) {
c01071c5:	55                   	push   %ebp
c01071c6:	89 e5                	mov    %esp,%ebp
c01071c8:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c01071cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01071ce:	c1 e8 0c             	shr    $0xc,%eax
c01071d1:	89 c2                	mov    %eax,%edx
c01071d3:	a1 80 0f 1b c0       	mov    0xc01b0f80,%eax
c01071d8:	39 c2                	cmp    %eax,%edx
c01071da:	72 1c                	jb     c01071f8 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c01071dc:	c7 44 24 08 28 dc 10 	movl   $0xc010dc28,0x8(%esp)
c01071e3:	c0 
c01071e4:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c01071eb:	00 
c01071ec:	c7 04 24 47 dc 10 c0 	movl   $0xc010dc47,(%esp)
c01071f3:	e8 0d 92 ff ff       	call   c0100405 <__panic>
    return &pages[PPN(pa)];
c01071f8:	a1 78 31 1b c0       	mov    0xc01b3178,%eax
c01071fd:	8b 55 08             	mov    0x8(%ebp),%edx
c0107200:	c1 ea 0c             	shr    $0xc,%edx
c0107203:	c1 e2 05             	shl    $0x5,%edx
c0107206:	01 d0                	add    %edx,%eax
}
c0107208:	c9                   	leave  
c0107209:	c3                   	ret    

c010720a <page2kva>:
page2kva(struct Page *page) {
c010720a:	55                   	push   %ebp
c010720b:	89 e5                	mov    %esp,%ebp
c010720d:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0107210:	8b 45 08             	mov    0x8(%ebp),%eax
c0107213:	89 04 24             	mov    %eax,(%esp)
c0107216:	e8 94 ff ff ff       	call   c01071af <page2pa>
c010721b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010721e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107221:	c1 e8 0c             	shr    $0xc,%eax
c0107224:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107227:	a1 80 0f 1b c0       	mov    0xc01b0f80,%eax
c010722c:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010722f:	72 23                	jb     c0107254 <page2kva+0x4a>
c0107231:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107234:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107238:	c7 44 24 08 58 dc 10 	movl   $0xc010dc58,0x8(%esp)
c010723f:	c0 
c0107240:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0107247:	00 
c0107248:	c7 04 24 47 dc 10 c0 	movl   $0xc010dc47,(%esp)
c010724f:	e8 b1 91 ff ff       	call   c0100405 <__panic>
c0107254:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107257:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c010725c:	c9                   	leave  
c010725d:	c3                   	ret    

c010725e <pte2page>:
pte2page(pte_t pte) {
c010725e:	55                   	push   %ebp
c010725f:	89 e5                	mov    %esp,%ebp
c0107261:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0107264:	8b 45 08             	mov    0x8(%ebp),%eax
c0107267:	83 e0 01             	and    $0x1,%eax
c010726a:	85 c0                	test   %eax,%eax
c010726c:	75 1c                	jne    c010728a <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c010726e:	c7 44 24 08 7c dc 10 	movl   $0xc010dc7c,0x8(%esp)
c0107275:	c0 
c0107276:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c010727d:	00 
c010727e:	c7 04 24 47 dc 10 c0 	movl   $0xc010dc47,(%esp)
c0107285:	e8 7b 91 ff ff       	call   c0100405 <__panic>
    return pa2page(PTE_ADDR(pte));
c010728a:	8b 45 08             	mov    0x8(%ebp),%eax
c010728d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107292:	89 04 24             	mov    %eax,(%esp)
c0107295:	e8 2b ff ff ff       	call   c01071c5 <pa2page>
}
c010729a:	c9                   	leave  
c010729b:	c3                   	ret    

c010729c <pde2page>:
pde2page(pde_t pde) {
c010729c:	55                   	push   %ebp
c010729d:	89 e5                	mov    %esp,%ebp
c010729f:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c01072a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01072a5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01072aa:	89 04 24             	mov    %eax,(%esp)
c01072ad:	e8 13 ff ff ff       	call   c01071c5 <pa2page>
}
c01072b2:	c9                   	leave  
c01072b3:	c3                   	ret    

c01072b4 <page_ref>:
page_ref(struct Page *page) {
c01072b4:	55                   	push   %ebp
c01072b5:	89 e5                	mov    %esp,%ebp
    return page->ref;
c01072b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01072ba:	8b 00                	mov    (%eax),%eax
}
c01072bc:	5d                   	pop    %ebp
c01072bd:	c3                   	ret    

c01072be <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c01072be:	55                   	push   %ebp
c01072bf:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c01072c1:	8b 45 08             	mov    0x8(%ebp),%eax
c01072c4:	8b 55 0c             	mov    0xc(%ebp),%edx
c01072c7:	89 10                	mov    %edx,(%eax)
}
c01072c9:	5d                   	pop    %ebp
c01072ca:	c3                   	ret    

c01072cb <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c01072cb:	55                   	push   %ebp
c01072cc:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c01072ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01072d1:	8b 00                	mov    (%eax),%eax
c01072d3:	8d 50 01             	lea    0x1(%eax),%edx
c01072d6:	8b 45 08             	mov    0x8(%ebp),%eax
c01072d9:	89 10                	mov    %edx,(%eax)
    return page->ref;
c01072db:	8b 45 08             	mov    0x8(%ebp),%eax
c01072de:	8b 00                	mov    (%eax),%eax
}
c01072e0:	5d                   	pop    %ebp
c01072e1:	c3                   	ret    

c01072e2 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c01072e2:	55                   	push   %ebp
c01072e3:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c01072e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01072e8:	8b 00                	mov    (%eax),%eax
c01072ea:	8d 50 ff             	lea    -0x1(%eax),%edx
c01072ed:	8b 45 08             	mov    0x8(%ebp),%eax
c01072f0:	89 10                	mov    %edx,(%eax)
    return page->ref;
c01072f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01072f5:	8b 00                	mov    (%eax),%eax
}
c01072f7:	5d                   	pop    %ebp
c01072f8:	c3                   	ret    

c01072f9 <__intr_save>:
__intr_save(void) {
c01072f9:	55                   	push   %ebp
c01072fa:	89 e5                	mov    %esp,%ebp
c01072fc:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01072ff:	9c                   	pushf  
c0107300:	58                   	pop    %eax
c0107301:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0107304:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0107307:	25 00 02 00 00       	and    $0x200,%eax
c010730c:	85 c0                	test   %eax,%eax
c010730e:	74 0c                	je     c010731c <__intr_save+0x23>
        intr_disable();
c0107310:	e8 05 af ff ff       	call   c010221a <intr_disable>
        return 1;
c0107315:	b8 01 00 00 00       	mov    $0x1,%eax
c010731a:	eb 05                	jmp    c0107321 <__intr_save+0x28>
    return 0;
c010731c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107321:	c9                   	leave  
c0107322:	c3                   	ret    

c0107323 <__intr_restore>:
__intr_restore(bool flag) {
c0107323:	55                   	push   %ebp
c0107324:	89 e5                	mov    %esp,%ebp
c0107326:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0107329:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010732d:	74 05                	je     c0107334 <__intr_restore+0x11>
        intr_enable();
c010732f:	e8 e0 ae ff ff       	call   c0102214 <intr_enable>
}
c0107334:	c9                   	leave  
c0107335:	c3                   	ret    

c0107336 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0107336:	55                   	push   %ebp
c0107337:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0107339:	8b 45 08             	mov    0x8(%ebp),%eax
c010733c:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c010733f:	b8 23 00 00 00       	mov    $0x23,%eax
c0107344:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0107346:	b8 23 00 00 00       	mov    $0x23,%eax
c010734b:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c010734d:	b8 10 00 00 00       	mov    $0x10,%eax
c0107352:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0107354:	b8 10 00 00 00       	mov    $0x10,%eax
c0107359:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c010735b:	b8 10 00 00 00       	mov    $0x10,%eax
c0107360:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0107362:	ea 69 73 10 c0 08 00 	ljmp   $0x8,$0xc0107369
}
c0107369:	5d                   	pop    %ebp
c010736a:	c3                   	ret    

c010736b <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c010736b:	55                   	push   %ebp
c010736c:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c010736e:	8b 45 08             	mov    0x8(%ebp),%eax
c0107371:	a3 a4 0f 1b c0       	mov    %eax,0xc01b0fa4
}
c0107376:	5d                   	pop    %ebp
c0107377:	c3                   	ret    

c0107378 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0107378:	55                   	push   %ebp
c0107379:	89 e5                	mov    %esp,%ebp
c010737b:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c010737e:	b8 00 c0 12 c0       	mov    $0xc012c000,%eax
c0107383:	89 04 24             	mov    %eax,(%esp)
c0107386:	e8 e0 ff ff ff       	call   c010736b <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c010738b:	66 c7 05 a8 0f 1b c0 	movw   $0x10,0xc01b0fa8
c0107392:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0107394:	66 c7 05 68 ca 12 c0 	movw   $0x68,0xc012ca68
c010739b:	68 00 
c010739d:	b8 a0 0f 1b c0       	mov    $0xc01b0fa0,%eax
c01073a2:	66 a3 6a ca 12 c0    	mov    %ax,0xc012ca6a
c01073a8:	b8 a0 0f 1b c0       	mov    $0xc01b0fa0,%eax
c01073ad:	c1 e8 10             	shr    $0x10,%eax
c01073b0:	a2 6c ca 12 c0       	mov    %al,0xc012ca6c
c01073b5:	0f b6 05 6d ca 12 c0 	movzbl 0xc012ca6d,%eax
c01073bc:	83 e0 f0             	and    $0xfffffff0,%eax
c01073bf:	83 c8 09             	or     $0x9,%eax
c01073c2:	a2 6d ca 12 c0       	mov    %al,0xc012ca6d
c01073c7:	0f b6 05 6d ca 12 c0 	movzbl 0xc012ca6d,%eax
c01073ce:	83 e0 ef             	and    $0xffffffef,%eax
c01073d1:	a2 6d ca 12 c0       	mov    %al,0xc012ca6d
c01073d6:	0f b6 05 6d ca 12 c0 	movzbl 0xc012ca6d,%eax
c01073dd:	83 e0 9f             	and    $0xffffff9f,%eax
c01073e0:	a2 6d ca 12 c0       	mov    %al,0xc012ca6d
c01073e5:	0f b6 05 6d ca 12 c0 	movzbl 0xc012ca6d,%eax
c01073ec:	83 c8 80             	or     $0xffffff80,%eax
c01073ef:	a2 6d ca 12 c0       	mov    %al,0xc012ca6d
c01073f4:	0f b6 05 6e ca 12 c0 	movzbl 0xc012ca6e,%eax
c01073fb:	83 e0 f0             	and    $0xfffffff0,%eax
c01073fe:	a2 6e ca 12 c0       	mov    %al,0xc012ca6e
c0107403:	0f b6 05 6e ca 12 c0 	movzbl 0xc012ca6e,%eax
c010740a:	83 e0 ef             	and    $0xffffffef,%eax
c010740d:	a2 6e ca 12 c0       	mov    %al,0xc012ca6e
c0107412:	0f b6 05 6e ca 12 c0 	movzbl 0xc012ca6e,%eax
c0107419:	83 e0 df             	and    $0xffffffdf,%eax
c010741c:	a2 6e ca 12 c0       	mov    %al,0xc012ca6e
c0107421:	0f b6 05 6e ca 12 c0 	movzbl 0xc012ca6e,%eax
c0107428:	83 c8 40             	or     $0x40,%eax
c010742b:	a2 6e ca 12 c0       	mov    %al,0xc012ca6e
c0107430:	0f b6 05 6e ca 12 c0 	movzbl 0xc012ca6e,%eax
c0107437:	83 e0 7f             	and    $0x7f,%eax
c010743a:	a2 6e ca 12 c0       	mov    %al,0xc012ca6e
c010743f:	b8 a0 0f 1b c0       	mov    $0xc01b0fa0,%eax
c0107444:	c1 e8 18             	shr    $0x18,%eax
c0107447:	a2 6f ca 12 c0       	mov    %al,0xc012ca6f

    // reload all segment registers
    lgdt(&gdt_pd);
c010744c:	c7 04 24 70 ca 12 c0 	movl   $0xc012ca70,(%esp)
c0107453:	e8 de fe ff ff       	call   c0107336 <lgdt>
c0107458:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c010745e:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0107462:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0107465:	c9                   	leave  
c0107466:	c3                   	ret    

c0107467 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0107467:	55                   	push   %ebp
c0107468:	89 e5                	mov    %esp,%ebp
c010746a:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c010746d:	c7 05 70 31 1b c0 0c 	movl   $0xc010dc0c,0xc01b3170
c0107474:	dc 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0107477:	a1 70 31 1b c0       	mov    0xc01b3170,%eax
c010747c:	8b 00                	mov    (%eax),%eax
c010747e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107482:	c7 04 24 a8 dc 10 c0 	movl   $0xc010dca8,(%esp)
c0107489:	e8 20 8e ff ff       	call   c01002ae <cprintf>
    pmm_manager->init();
c010748e:	a1 70 31 1b c0       	mov    0xc01b3170,%eax
c0107493:	8b 40 04             	mov    0x4(%eax),%eax
c0107496:	ff d0                	call   *%eax
}
c0107498:	c9                   	leave  
c0107499:	c3                   	ret    

c010749a <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c010749a:	55                   	push   %ebp
c010749b:	89 e5                	mov    %esp,%ebp
c010749d:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c01074a0:	a1 70 31 1b c0       	mov    0xc01b3170,%eax
c01074a5:	8b 40 08             	mov    0x8(%eax),%eax
c01074a8:	8b 55 0c             	mov    0xc(%ebp),%edx
c01074ab:	89 54 24 04          	mov    %edx,0x4(%esp)
c01074af:	8b 55 08             	mov    0x8(%ebp),%edx
c01074b2:	89 14 24             	mov    %edx,(%esp)
c01074b5:	ff d0                	call   *%eax
}
c01074b7:	c9                   	leave  
c01074b8:	c3                   	ret    

c01074b9 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c01074b9:	55                   	push   %ebp
c01074ba:	89 e5                	mov    %esp,%ebp
c01074bc:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c01074bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    
    while (1)
    {
         local_intr_save(intr_flag);
c01074c6:	e8 2e fe ff ff       	call   c01072f9 <__intr_save>
c01074cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
         {
              page = pmm_manager->alloc_pages(n);
c01074ce:	a1 70 31 1b c0       	mov    0xc01b3170,%eax
c01074d3:	8b 40 0c             	mov    0xc(%eax),%eax
c01074d6:	8b 55 08             	mov    0x8(%ebp),%edx
c01074d9:	89 14 24             	mov    %edx,(%esp)
c01074dc:	ff d0                	call   *%eax
c01074de:	89 45 f4             	mov    %eax,-0xc(%ebp)
         }
         local_intr_restore(intr_flag);
c01074e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01074e4:	89 04 24             	mov    %eax,(%esp)
c01074e7:	e8 37 fe ff ff       	call   c0107323 <__intr_restore>

         if (page != NULL || n > 1 || swap_init_ok == 0) break;
c01074ec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01074f0:	75 2d                	jne    c010751f <alloc_pages+0x66>
c01074f2:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
c01074f6:	77 27                	ja     c010751f <alloc_pages+0x66>
c01074f8:	a1 6c 0f 1b c0       	mov    0xc01b0f6c,%eax
c01074fd:	85 c0                	test   %eax,%eax
c01074ff:	74 1e                	je     c010751f <alloc_pages+0x66>
         
         extern struct mm_struct *check_mm_struct;
         //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
         swap_out(check_mm_struct, n, 0);
c0107501:	8b 55 08             	mov    0x8(%ebp),%edx
c0107504:	a1 7c 30 1b c0       	mov    0xc01b307c,%eax
c0107509:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107510:	00 
c0107511:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107515:	89 04 24             	mov    %eax,(%esp)
c0107518:	e8 b5 e0 ff ff       	call   c01055d2 <swap_out>
    }
c010751d:	eb a7                	jmp    c01074c6 <alloc_pages+0xd>
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
c010751f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107522:	c9                   	leave  
c0107523:	c3                   	ret    

c0107524 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0107524:	55                   	push   %ebp
c0107525:	89 e5                	mov    %esp,%ebp
c0107527:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c010752a:	e8 ca fd ff ff       	call   c01072f9 <__intr_save>
c010752f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0107532:	a1 70 31 1b c0       	mov    0xc01b3170,%eax
c0107537:	8b 40 10             	mov    0x10(%eax),%eax
c010753a:	8b 55 0c             	mov    0xc(%ebp),%edx
c010753d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107541:	8b 55 08             	mov    0x8(%ebp),%edx
c0107544:	89 14 24             	mov    %edx,(%esp)
c0107547:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0107549:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010754c:	89 04 24             	mov    %eax,(%esp)
c010754f:	e8 cf fd ff ff       	call   c0107323 <__intr_restore>
}
c0107554:	c9                   	leave  
c0107555:	c3                   	ret    

c0107556 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0107556:	55                   	push   %ebp
c0107557:	89 e5                	mov    %esp,%ebp
c0107559:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c010755c:	e8 98 fd ff ff       	call   c01072f9 <__intr_save>
c0107561:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0107564:	a1 70 31 1b c0       	mov    0xc01b3170,%eax
c0107569:	8b 40 14             	mov    0x14(%eax),%eax
c010756c:	ff d0                	call   *%eax
c010756e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0107571:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107574:	89 04 24             	mov    %eax,(%esp)
c0107577:	e8 a7 fd ff ff       	call   c0107323 <__intr_restore>
    return ret;
c010757c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c010757f:	c9                   	leave  
c0107580:	c3                   	ret    

c0107581 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0107581:	55                   	push   %ebp
c0107582:	89 e5                	mov    %esp,%ebp
c0107584:	57                   	push   %edi
c0107585:	56                   	push   %esi
c0107586:	53                   	push   %ebx
c0107587:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c010758d:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0107594:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c010759b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c01075a2:	c7 04 24 bf dc 10 c0 	movl   $0xc010dcbf,(%esp)
c01075a9:	e8 00 8d ff ff       	call   c01002ae <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c01075ae:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01075b5:	e9 15 01 00 00       	jmp    c01076cf <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c01075ba:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01075bd:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01075c0:	89 d0                	mov    %edx,%eax
c01075c2:	c1 e0 02             	shl    $0x2,%eax
c01075c5:	01 d0                	add    %edx,%eax
c01075c7:	c1 e0 02             	shl    $0x2,%eax
c01075ca:	01 c8                	add    %ecx,%eax
c01075cc:	8b 50 08             	mov    0x8(%eax),%edx
c01075cf:	8b 40 04             	mov    0x4(%eax),%eax
c01075d2:	89 45 b8             	mov    %eax,-0x48(%ebp)
c01075d5:	89 55 bc             	mov    %edx,-0x44(%ebp)
c01075d8:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01075db:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01075de:	89 d0                	mov    %edx,%eax
c01075e0:	c1 e0 02             	shl    $0x2,%eax
c01075e3:	01 d0                	add    %edx,%eax
c01075e5:	c1 e0 02             	shl    $0x2,%eax
c01075e8:	01 c8                	add    %ecx,%eax
c01075ea:	8b 48 0c             	mov    0xc(%eax),%ecx
c01075ed:	8b 58 10             	mov    0x10(%eax),%ebx
c01075f0:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01075f3:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01075f6:	01 c8                	add    %ecx,%eax
c01075f8:	11 da                	adc    %ebx,%edx
c01075fa:	89 45 b0             	mov    %eax,-0x50(%ebp)
c01075fd:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0107600:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0107603:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107606:	89 d0                	mov    %edx,%eax
c0107608:	c1 e0 02             	shl    $0x2,%eax
c010760b:	01 d0                	add    %edx,%eax
c010760d:	c1 e0 02             	shl    $0x2,%eax
c0107610:	01 c8                	add    %ecx,%eax
c0107612:	83 c0 14             	add    $0x14,%eax
c0107615:	8b 00                	mov    (%eax),%eax
c0107617:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c010761d:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0107620:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0107623:	83 c0 ff             	add    $0xffffffff,%eax
c0107626:	83 d2 ff             	adc    $0xffffffff,%edx
c0107629:	89 c6                	mov    %eax,%esi
c010762b:	89 d7                	mov    %edx,%edi
c010762d:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0107630:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107633:	89 d0                	mov    %edx,%eax
c0107635:	c1 e0 02             	shl    $0x2,%eax
c0107638:	01 d0                	add    %edx,%eax
c010763a:	c1 e0 02             	shl    $0x2,%eax
c010763d:	01 c8                	add    %ecx,%eax
c010763f:	8b 48 0c             	mov    0xc(%eax),%ecx
c0107642:	8b 58 10             	mov    0x10(%eax),%ebx
c0107645:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c010764b:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c010764f:	89 74 24 14          	mov    %esi,0x14(%esp)
c0107653:	89 7c 24 18          	mov    %edi,0x18(%esp)
c0107657:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010765a:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010765d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107661:	89 54 24 10          	mov    %edx,0x10(%esp)
c0107665:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0107669:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c010766d:	c7 04 24 cc dc 10 c0 	movl   $0xc010dccc,(%esp)
c0107674:	e8 35 8c ff ff       	call   c01002ae <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0107679:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010767c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010767f:	89 d0                	mov    %edx,%eax
c0107681:	c1 e0 02             	shl    $0x2,%eax
c0107684:	01 d0                	add    %edx,%eax
c0107686:	c1 e0 02             	shl    $0x2,%eax
c0107689:	01 c8                	add    %ecx,%eax
c010768b:	83 c0 14             	add    $0x14,%eax
c010768e:	8b 00                	mov    (%eax),%eax
c0107690:	83 f8 01             	cmp    $0x1,%eax
c0107693:	75 36                	jne    c01076cb <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
c0107695:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107698:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010769b:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c010769e:	77 2b                	ja     c01076cb <page_init+0x14a>
c01076a0:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c01076a3:	72 05                	jb     c01076aa <page_init+0x129>
c01076a5:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c01076a8:	73 21                	jae    c01076cb <page_init+0x14a>
c01076aa:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c01076ae:	77 1b                	ja     c01076cb <page_init+0x14a>
c01076b0:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c01076b4:	72 09                	jb     c01076bf <page_init+0x13e>
c01076b6:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c01076bd:	77 0c                	ja     c01076cb <page_init+0x14a>
                maxpa = end;
c01076bf:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01076c2:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01076c5:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01076c8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
c01076cb:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c01076cf:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01076d2:	8b 00                	mov    (%eax),%eax
c01076d4:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c01076d7:	0f 8f dd fe ff ff    	jg     c01075ba <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c01076dd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01076e1:	72 1d                	jb     c0107700 <page_init+0x17f>
c01076e3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01076e7:	77 09                	ja     c01076f2 <page_init+0x171>
c01076e9:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c01076f0:	76 0e                	jbe    c0107700 <page_init+0x17f>
        maxpa = KMEMSIZE;
c01076f2:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c01076f9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0107700:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107703:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107706:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c010770a:	c1 ea 0c             	shr    $0xc,%edx
c010770d:	a3 80 0f 1b c0       	mov    %eax,0xc01b0f80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0107712:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c0107719:	b8 84 31 1b c0       	mov    $0xc01b3184,%eax
c010771e:	8d 50 ff             	lea    -0x1(%eax),%edx
c0107721:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0107724:	01 d0                	add    %edx,%eax
c0107726:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0107729:	8b 45 a8             	mov    -0x58(%ebp),%eax
c010772c:	ba 00 00 00 00       	mov    $0x0,%edx
c0107731:	f7 75 ac             	divl   -0x54(%ebp)
c0107734:	89 d0                	mov    %edx,%eax
c0107736:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0107739:	29 c2                	sub    %eax,%edx
c010773b:	89 d0                	mov    %edx,%eax
c010773d:	a3 78 31 1b c0       	mov    %eax,0xc01b3178

    for (i = 0; i < npage; i ++) {
c0107742:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0107749:	eb 27                	jmp    c0107772 <page_init+0x1f1>
        SetPageReserved(pages + i);
c010774b:	a1 78 31 1b c0       	mov    0xc01b3178,%eax
c0107750:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107753:	c1 e2 05             	shl    $0x5,%edx
c0107756:	01 d0                	add    %edx,%eax
c0107758:	83 c0 04             	add    $0x4,%eax
c010775b:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c0107762:	89 45 8c             	mov    %eax,-0x74(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0107765:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0107768:	8b 55 90             	mov    -0x70(%ebp),%edx
c010776b:	0f ab 10             	bts    %edx,(%eax)
    for (i = 0; i < npage; i ++) {
c010776e:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0107772:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107775:	a1 80 0f 1b c0       	mov    0xc01b0f80,%eax
c010777a:	39 c2                	cmp    %eax,%edx
c010777c:	72 cd                	jb     c010774b <page_init+0x1ca>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c010777e:	a1 80 0f 1b c0       	mov    0xc01b0f80,%eax
c0107783:	c1 e0 05             	shl    $0x5,%eax
c0107786:	89 c2                	mov    %eax,%edx
c0107788:	a1 78 31 1b c0       	mov    0xc01b3178,%eax
c010778d:	01 d0                	add    %edx,%eax
c010778f:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c0107792:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c0107799:	77 23                	ja     c01077be <page_init+0x23d>
c010779b:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c010779e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01077a2:	c7 44 24 08 fc dc 10 	movl   $0xc010dcfc,0x8(%esp)
c01077a9:	c0 
c01077aa:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
c01077b1:	00 
c01077b2:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c01077b9:	e8 47 8c ff ff       	call   c0100405 <__panic>
c01077be:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01077c1:	05 00 00 00 40       	add    $0x40000000,%eax
c01077c6:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c01077c9:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01077d0:	e9 74 01 00 00       	jmp    c0107949 <page_init+0x3c8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c01077d5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01077d8:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01077db:	89 d0                	mov    %edx,%eax
c01077dd:	c1 e0 02             	shl    $0x2,%eax
c01077e0:	01 d0                	add    %edx,%eax
c01077e2:	c1 e0 02             	shl    $0x2,%eax
c01077e5:	01 c8                	add    %ecx,%eax
c01077e7:	8b 50 08             	mov    0x8(%eax),%edx
c01077ea:	8b 40 04             	mov    0x4(%eax),%eax
c01077ed:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01077f0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01077f3:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01077f6:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01077f9:	89 d0                	mov    %edx,%eax
c01077fb:	c1 e0 02             	shl    $0x2,%eax
c01077fe:	01 d0                	add    %edx,%eax
c0107800:	c1 e0 02             	shl    $0x2,%eax
c0107803:	01 c8                	add    %ecx,%eax
c0107805:	8b 48 0c             	mov    0xc(%eax),%ecx
c0107808:	8b 58 10             	mov    0x10(%eax),%ebx
c010780b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010780e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107811:	01 c8                	add    %ecx,%eax
c0107813:	11 da                	adc    %ebx,%edx
c0107815:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0107818:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c010781b:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010781e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107821:	89 d0                	mov    %edx,%eax
c0107823:	c1 e0 02             	shl    $0x2,%eax
c0107826:	01 d0                	add    %edx,%eax
c0107828:	c1 e0 02             	shl    $0x2,%eax
c010782b:	01 c8                	add    %ecx,%eax
c010782d:	83 c0 14             	add    $0x14,%eax
c0107830:	8b 00                	mov    (%eax),%eax
c0107832:	83 f8 01             	cmp    $0x1,%eax
c0107835:	0f 85 0a 01 00 00    	jne    c0107945 <page_init+0x3c4>
            if (begin < freemem) {
c010783b:	8b 45 a0             	mov    -0x60(%ebp),%eax
c010783e:	ba 00 00 00 00       	mov    $0x0,%edx
c0107843:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0107846:	72 17                	jb     c010785f <page_init+0x2de>
c0107848:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010784b:	77 05                	ja     c0107852 <page_init+0x2d1>
c010784d:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0107850:	76 0d                	jbe    c010785f <page_init+0x2de>
                begin = freemem;
c0107852:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0107855:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0107858:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c010785f:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0107863:	72 1d                	jb     c0107882 <page_init+0x301>
c0107865:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0107869:	77 09                	ja     c0107874 <page_init+0x2f3>
c010786b:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c0107872:	76 0e                	jbe    c0107882 <page_init+0x301>
                end = KMEMSIZE;
c0107874:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c010787b:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0107882:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107885:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107888:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c010788b:	0f 87 b4 00 00 00    	ja     c0107945 <page_init+0x3c4>
c0107891:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0107894:	72 09                	jb     c010789f <page_init+0x31e>
c0107896:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0107899:	0f 83 a6 00 00 00    	jae    c0107945 <page_init+0x3c4>
                begin = ROUNDUP(begin, PGSIZE);
c010789f:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c01078a6:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01078a9:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01078ac:	01 d0                	add    %edx,%eax
c01078ae:	83 e8 01             	sub    $0x1,%eax
c01078b1:	89 45 98             	mov    %eax,-0x68(%ebp)
c01078b4:	8b 45 98             	mov    -0x68(%ebp),%eax
c01078b7:	ba 00 00 00 00       	mov    $0x0,%edx
c01078bc:	f7 75 9c             	divl   -0x64(%ebp)
c01078bf:	89 d0                	mov    %edx,%eax
c01078c1:	8b 55 98             	mov    -0x68(%ebp),%edx
c01078c4:	29 c2                	sub    %eax,%edx
c01078c6:	89 d0                	mov    %edx,%eax
c01078c8:	ba 00 00 00 00       	mov    $0x0,%edx
c01078cd:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01078d0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c01078d3:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01078d6:	89 45 94             	mov    %eax,-0x6c(%ebp)
c01078d9:	8b 45 94             	mov    -0x6c(%ebp),%eax
c01078dc:	ba 00 00 00 00       	mov    $0x0,%edx
c01078e1:	89 c7                	mov    %eax,%edi
c01078e3:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c01078e9:	89 7d 80             	mov    %edi,-0x80(%ebp)
c01078ec:	89 d0                	mov    %edx,%eax
c01078ee:	83 e0 00             	and    $0x0,%eax
c01078f1:	89 45 84             	mov    %eax,-0x7c(%ebp)
c01078f4:	8b 45 80             	mov    -0x80(%ebp),%eax
c01078f7:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01078fa:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01078fd:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c0107900:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107903:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107906:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0107909:	77 3a                	ja     c0107945 <page_init+0x3c4>
c010790b:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c010790e:	72 05                	jb     c0107915 <page_init+0x394>
c0107910:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0107913:	73 30                	jae    c0107945 <page_init+0x3c4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0107915:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c0107918:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
c010791b:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010791e:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0107921:	29 c8                	sub    %ecx,%eax
c0107923:	19 da                	sbb    %ebx,%edx
c0107925:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0107929:	c1 ea 0c             	shr    $0xc,%edx
c010792c:	89 c3                	mov    %eax,%ebx
c010792e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107931:	89 04 24             	mov    %eax,(%esp)
c0107934:	e8 8c f8 ff ff       	call   c01071c5 <pa2page>
c0107939:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c010793d:	89 04 24             	mov    %eax,(%esp)
c0107940:	e8 55 fb ff ff       	call   c010749a <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
c0107945:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0107949:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010794c:	8b 00                	mov    (%eax),%eax
c010794e:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0107951:	0f 8f 7e fe ff ff    	jg     c01077d5 <page_init+0x254>
                }
            }
        }
    }
}
c0107957:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c010795d:	5b                   	pop    %ebx
c010795e:	5e                   	pop    %esi
c010795f:	5f                   	pop    %edi
c0107960:	5d                   	pop    %ebp
c0107961:	c3                   	ret    

c0107962 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c0107962:	55                   	push   %ebp
c0107963:	89 e5                	mov    %esp,%ebp
c0107965:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0107968:	8b 45 14             	mov    0x14(%ebp),%eax
c010796b:	8b 55 0c             	mov    0xc(%ebp),%edx
c010796e:	31 d0                	xor    %edx,%eax
c0107970:	25 ff 0f 00 00       	and    $0xfff,%eax
c0107975:	85 c0                	test   %eax,%eax
c0107977:	74 24                	je     c010799d <boot_map_segment+0x3b>
c0107979:	c7 44 24 0c 2e dd 10 	movl   $0xc010dd2e,0xc(%esp)
c0107980:	c0 
c0107981:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c0107988:	c0 
c0107989:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
c0107990:	00 
c0107991:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c0107998:	e8 68 8a ff ff       	call   c0100405 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c010799d:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c01079a4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01079a7:	25 ff 0f 00 00       	and    $0xfff,%eax
c01079ac:	89 c2                	mov    %eax,%edx
c01079ae:	8b 45 10             	mov    0x10(%ebp),%eax
c01079b1:	01 c2                	add    %eax,%edx
c01079b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01079b6:	01 d0                	add    %edx,%eax
c01079b8:	83 e8 01             	sub    $0x1,%eax
c01079bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01079be:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01079c1:	ba 00 00 00 00       	mov    $0x0,%edx
c01079c6:	f7 75 f0             	divl   -0x10(%ebp)
c01079c9:	89 d0                	mov    %edx,%eax
c01079cb:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01079ce:	29 c2                	sub    %eax,%edx
c01079d0:	89 d0                	mov    %edx,%eax
c01079d2:	c1 e8 0c             	shr    $0xc,%eax
c01079d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c01079d8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01079db:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01079de:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01079e1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01079e6:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c01079e9:	8b 45 14             	mov    0x14(%ebp),%eax
c01079ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01079ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01079f2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01079f7:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01079fa:	eb 6b                	jmp    c0107a67 <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
c01079fc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0107a03:	00 
c0107a04:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107a07:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107a0b:	8b 45 08             	mov    0x8(%ebp),%eax
c0107a0e:	89 04 24             	mov    %eax,(%esp)
c0107a11:	e8 87 01 00 00       	call   c0107b9d <get_pte>
c0107a16:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0107a19:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0107a1d:	75 24                	jne    c0107a43 <boot_map_segment+0xe1>
c0107a1f:	c7 44 24 0c 5a dd 10 	movl   $0xc010dd5a,0xc(%esp)
c0107a26:	c0 
c0107a27:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c0107a2e:	c0 
c0107a2f:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
c0107a36:	00 
c0107a37:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c0107a3e:	e8 c2 89 ff ff       	call   c0100405 <__panic>
        *ptep = pa | PTE_P | perm;
c0107a43:	8b 45 18             	mov    0x18(%ebp),%eax
c0107a46:	8b 55 14             	mov    0x14(%ebp),%edx
c0107a49:	09 d0                	or     %edx,%eax
c0107a4b:	83 c8 01             	or     $0x1,%eax
c0107a4e:	89 c2                	mov    %eax,%edx
c0107a50:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107a53:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0107a55:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0107a59:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c0107a60:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0107a67:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107a6b:	75 8f                	jne    c01079fc <boot_map_segment+0x9a>
    }
}
c0107a6d:	c9                   	leave  
c0107a6e:	c3                   	ret    

c0107a6f <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c0107a6f:	55                   	push   %ebp
c0107a70:	89 e5                	mov    %esp,%ebp
c0107a72:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c0107a75:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107a7c:	e8 38 fa ff ff       	call   c01074b9 <alloc_pages>
c0107a81:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0107a84:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107a88:	75 1c                	jne    c0107aa6 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c0107a8a:	c7 44 24 08 67 dd 10 	movl   $0xc010dd67,0x8(%esp)
c0107a91:	c0 
c0107a92:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c0107a99:	00 
c0107a9a:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c0107aa1:	e8 5f 89 ff ff       	call   c0100405 <__panic>
    }
    return page2kva(p);
c0107aa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107aa9:	89 04 24             	mov    %eax,(%esp)
c0107aac:	e8 59 f7 ff ff       	call   c010720a <page2kva>
}
c0107ab1:	c9                   	leave  
c0107ab2:	c3                   	ret    

c0107ab3 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c0107ab3:	55                   	push   %ebp
c0107ab4:	89 e5                	mov    %esp,%ebp
c0107ab6:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c0107ab9:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0107abe:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107ac1:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0107ac8:	77 23                	ja     c0107aed <pmm_init+0x3a>
c0107aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107acd:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107ad1:	c7 44 24 08 fc dc 10 	movl   $0xc010dcfc,0x8(%esp)
c0107ad8:	c0 
c0107ad9:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
c0107ae0:	00 
c0107ae1:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c0107ae8:	e8 18 89 ff ff       	call   c0100405 <__panic>
c0107aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107af0:	05 00 00 00 40       	add    $0x40000000,%eax
c0107af5:	a3 74 31 1b c0       	mov    %eax,0xc01b3174
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0107afa:	e8 68 f9 ff ff       	call   c0107467 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c0107aff:	e8 7d fa ff ff       	call   c0107581 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0107b04:	e8 d8 08 00 00       	call   c01083e1 <check_alloc_page>

    check_pgdir();
c0107b09:	e8 f1 08 00 00       	call   c01083ff <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0107b0e:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0107b13:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c0107b19:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0107b1e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107b21:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0107b28:	77 23                	ja     c0107b4d <pmm_init+0x9a>
c0107b2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107b2d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107b31:	c7 44 24 08 fc dc 10 	movl   $0xc010dcfc,0x8(%esp)
c0107b38:	c0 
c0107b39:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
c0107b40:	00 
c0107b41:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c0107b48:	e8 b8 88 ff ff       	call   c0100405 <__panic>
c0107b4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107b50:	05 00 00 00 40       	add    $0x40000000,%eax
c0107b55:	83 c8 03             	or     $0x3,%eax
c0107b58:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0107b5a:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0107b5f:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c0107b66:	00 
c0107b67:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0107b6e:	00 
c0107b6f:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c0107b76:	38 
c0107b77:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c0107b7e:	c0 
c0107b7f:	89 04 24             	mov    %eax,(%esp)
c0107b82:	e8 db fd ff ff       	call   c0107962 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0107b87:	e8 ec f7 ff ff       	call   c0107378 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0107b8c:	e8 09 0f 00 00       	call   c0108a9a <check_boot_pgdir>

    print_pgdir();
c0107b91:	e8 91 13 00 00       	call   c0108f27 <print_pgdir>
    
    kmalloc_init();
c0107b96:	e8 f9 d5 ff ff       	call   c0105194 <kmalloc_init>

}
c0107b9b:	c9                   	leave  
c0107b9c:	c3                   	ret    

c0107b9d <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c0107b9d:	55                   	push   %ebp
c0107b9e:	89 e5                	mov    %esp,%ebp
c0107ba0:	83 ec 38             	sub    $0x38,%esp
     pde_t *pdep = &pgdir[PDX(la)];
c0107ba3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107ba6:	c1 e8 16             	shr    $0x16,%eax
c0107ba9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0107bb0:	8b 45 08             	mov    0x8(%ebp),%eax
c0107bb3:	01 d0                	add    %edx,%eax
c0107bb5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    //获取一级页表项对应的入口地址
    if (!(*pdep & PTE_P)) {
c0107bb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107bbb:	8b 00                	mov    (%eax),%eax
c0107bbd:	83 e0 01             	and    $0x1,%eax
c0107bc0:	85 c0                	test   %eax,%eax
c0107bc2:	0f 85 af 00 00 00    	jne    c0107c77 <get_pte+0xda>
        //物理页不存在, create==0, null
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {//分配失败
c0107bc8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0107bcc:	74 15                	je     c0107be3 <get_pte+0x46>
c0107bce:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107bd5:	e8 df f8 ff ff       	call   c01074b9 <alloc_pages>
c0107bda:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107bdd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107be1:	75 0a                	jne    c0107bed <get_pte+0x50>
            return NULL;
c0107be3:	b8 00 00 00 00       	mov    $0x0,%eax
c0107be8:	e9 e6 00 00 00       	jmp    c0107cd3 <get_pte+0x136>
        }
        //引用次数+1
        set_page_ref(page, 1);
c0107bed:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107bf4:	00 
c0107bf5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107bf8:	89 04 24             	mov    %eax,(%esp)
c0107bfb:	e8 be f6 ff ff       	call   c01072be <set_page_ref>
        //物理地址
        uintptr_t pa = page2pa(page);
c0107c00:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107c03:	89 04 24             	mov    %eax,(%esp)
c0107c06:	e8 a4 f5 ff ff       	call   c01071af <page2pa>
c0107c0b:	89 45 ec             	mov    %eax,-0x14(%ebp)
        ///物理地址转虚拟地址，并初始化,把新申请的数目为pgsize个页全设为0	
        memset(KADDR(pa), 0, PGSIZE);
c0107c0e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107c11:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107c14:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107c17:	c1 e8 0c             	shr    $0xc,%eax
c0107c1a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107c1d:	a1 80 0f 1b c0       	mov    0xc01b0f80,%eax
c0107c22:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0107c25:	72 23                	jb     c0107c4a <get_pte+0xad>
c0107c27:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107c2a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107c2e:	c7 44 24 08 58 dc 10 	movl   $0xc010dc58,0x8(%esp)
c0107c35:	c0 
c0107c36:	c7 44 24 04 66 01 00 	movl   $0x166,0x4(%esp)
c0107c3d:	00 
c0107c3e:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c0107c45:	e8 bb 87 ff ff       	call   c0100405 <__panic>
c0107c4a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107c4d:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0107c52:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0107c59:	00 
c0107c5a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0107c61:	00 
c0107c62:	89 04 24             	mov    %eax,(%esp)
c0107c65:	e8 c8 3d 00 00       	call   c010ba32 <memset>
        //设置控制位
        *pdep = pa | PTE_U | PTE_W | PTE_P;
c0107c6a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107c6d:	83 c8 07             	or     $0x7,%eax
c0107c70:	89 c2                	mov    %eax,%edx
c0107c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107c75:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c0107c77:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107c7a:	8b 00                	mov    (%eax),%eax
c0107c7c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107c81:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0107c84:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107c87:	c1 e8 0c             	shr    $0xc,%eax
c0107c8a:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0107c8d:	a1 80 0f 1b c0       	mov    0xc01b0f80,%eax
c0107c92:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0107c95:	72 23                	jb     c0107cba <get_pte+0x11d>
c0107c97:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107c9a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107c9e:	c7 44 24 08 58 dc 10 	movl   $0xc010dc58,0x8(%esp)
c0107ca5:	c0 
c0107ca6:	c7 44 24 04 6a 01 00 	movl   $0x16a,0x4(%esp)
c0107cad:	00 
c0107cae:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c0107cb5:	e8 4b 87 ff ff       	call   c0100405 <__panic>
c0107cba:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107cbd:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0107cc2:	8b 55 0c             	mov    0xc(%ebp),%edx
c0107cc5:	c1 ea 0c             	shr    $0xc,%edx
c0107cc8:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
c0107cce:	c1 e2 02             	shl    $0x2,%edx
c0107cd1:	01 d0                	add    %edx,%eax
    //页目录项地址-->>页表物理地址-->>虚拟地址-->>页表项索引
    //PTX(la)：返回虚拟地址la的页表项索引
    //返回la对应的页表项入口地址
}
c0107cd3:	c9                   	leave  
c0107cd4:	c3                   	ret    

c0107cd5 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c0107cd5:	55                   	push   %ebp
c0107cd6:	89 e5                	mov    %esp,%ebp
c0107cd8:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0107cdb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107ce2:	00 
c0107ce3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107ce6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107cea:	8b 45 08             	mov    0x8(%ebp),%eax
c0107ced:	89 04 24             	mov    %eax,(%esp)
c0107cf0:	e8 a8 fe ff ff       	call   c0107b9d <get_pte>
c0107cf5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c0107cf8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0107cfc:	74 08                	je     c0107d06 <get_page+0x31>
        *ptep_store = ptep;
c0107cfe:	8b 45 10             	mov    0x10(%ebp),%eax
c0107d01:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107d04:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0107d06:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107d0a:	74 1b                	je     c0107d27 <get_page+0x52>
c0107d0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107d0f:	8b 00                	mov    (%eax),%eax
c0107d11:	83 e0 01             	and    $0x1,%eax
c0107d14:	85 c0                	test   %eax,%eax
c0107d16:	74 0f                	je     c0107d27 <get_page+0x52>
        return pte2page(*ptep);
c0107d18:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107d1b:	8b 00                	mov    (%eax),%eax
c0107d1d:	89 04 24             	mov    %eax,(%esp)
c0107d20:	e8 39 f5 ff ff       	call   c010725e <pte2page>
c0107d25:	eb 05                	jmp    c0107d2c <get_page+0x57>
    }
    return NULL;
c0107d27:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107d2c:	c9                   	leave  
c0107d2d:	c3                   	ret    

c0107d2e <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0107d2e:	55                   	push   %ebp
c0107d2f:	89 e5                	mov    %esp,%ebp
c0107d31:	83 ec 28             	sub    $0x28,%esp
    if (*ptep & PTE_P) {
c0107d34:	8b 45 10             	mov    0x10(%ebp),%eax
c0107d37:	8b 00                	mov    (%eax),%eax
c0107d39:	83 e0 01             	and    $0x1,%eax
c0107d3c:	85 c0                	test   %eax,%eax
c0107d3e:	74 53                	je     c0107d93 <page_remove_pte+0x65>
        //判断页表中该表项是否存在
        struct Page *page = pte2page(*ptep);//获得相应的page
c0107d40:	8b 45 10             	mov    0x10(%ebp),%eax
c0107d43:	8b 00                	mov    (%eax),%eax
c0107d45:	89 04 24             	mov    %eax,(%esp)
c0107d48:	e8 11 f5 ff ff       	call   c010725e <pte2page>
c0107d4d:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
c0107d50:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107d53:	89 04 24             	mov    %eax,(%esp)
c0107d56:	e8 87 f5 ff ff       	call   c01072e2 <page_ref_dec>
c0107d5b:	85 c0                	test   %eax,%eax
c0107d5d:	75 13                	jne    c0107d72 <page_remove_pte+0x44>
            ////除了当前进程，没有别的进程引用
            free_page(page);
c0107d5f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107d66:	00 
c0107d67:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107d6a:	89 04 24             	mov    %eax,(%esp)
c0107d6d:	e8 b2 f7 ff ff       	call   c0107524 <free_pages>
        }
        *ptep &= (~PTE_P); 
c0107d72:	8b 45 10             	mov    0x10(%ebp),%eax
c0107d75:	8b 00                	mov    (%eax),%eax
c0107d77:	83 e0 fe             	and    $0xfffffffe,%eax
c0107d7a:	89 c2                	mov    %eax,%edx
c0107d7c:	8b 45 10             	mov    0x10(%ebp),%eax
c0107d7f:	89 10                	mov    %edx,(%eax)
        // 将PTE的存在位设置为0，表示该映射关系无效
        tlb_invalidate(pgdir, la);
c0107d81:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107d84:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107d88:	8b 45 08             	mov    0x8(%ebp),%eax
c0107d8b:	89 04 24             	mov    %eax,(%esp)
c0107d8e:	e8 1d 05 00 00       	call   c01082b0 <tlb_invalidate>
         //刷新TLB
    }
}
c0107d93:	c9                   	leave  
c0107d94:	c3                   	ret    

c0107d95 <unmap_range>:

void
unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
c0107d95:	55                   	push   %ebp
c0107d96:	89 e5                	mov    %esp,%ebp
c0107d98:	83 ec 28             	sub    $0x28,%esp
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
c0107d9b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107d9e:	25 ff 0f 00 00       	and    $0xfff,%eax
c0107da3:	85 c0                	test   %eax,%eax
c0107da5:	75 0c                	jne    c0107db3 <unmap_range+0x1e>
c0107da7:	8b 45 10             	mov    0x10(%ebp),%eax
c0107daa:	25 ff 0f 00 00       	and    $0xfff,%eax
c0107daf:	85 c0                	test   %eax,%eax
c0107db1:	74 24                	je     c0107dd7 <unmap_range+0x42>
c0107db3:	c7 44 24 0c 80 dd 10 	movl   $0xc010dd80,0xc(%esp)
c0107dba:	c0 
c0107dbb:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c0107dc2:	c0 
c0107dc3:	c7 44 24 04 92 01 00 	movl   $0x192,0x4(%esp)
c0107dca:	00 
c0107dcb:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c0107dd2:	e8 2e 86 ff ff       	call   c0100405 <__panic>
    assert(USER_ACCESS(start, end));
c0107dd7:	81 7d 0c ff ff 1f 00 	cmpl   $0x1fffff,0xc(%ebp)
c0107dde:	76 11                	jbe    c0107df1 <unmap_range+0x5c>
c0107de0:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107de3:	3b 45 10             	cmp    0x10(%ebp),%eax
c0107de6:	73 09                	jae    c0107df1 <unmap_range+0x5c>
c0107de8:	81 7d 10 00 00 00 b0 	cmpl   $0xb0000000,0x10(%ebp)
c0107def:	76 24                	jbe    c0107e15 <unmap_range+0x80>
c0107df1:	c7 44 24 0c a9 dd 10 	movl   $0xc010dda9,0xc(%esp)
c0107df8:	c0 
c0107df9:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c0107e00:	c0 
c0107e01:	c7 44 24 04 93 01 00 	movl   $0x193,0x4(%esp)
c0107e08:	00 
c0107e09:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c0107e10:	e8 f0 85 ff ff       	call   c0100405 <__panic>

    do {
        pte_t *ptep = get_pte(pgdir, start, 0);
c0107e15:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107e1c:	00 
c0107e1d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107e20:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107e24:	8b 45 08             	mov    0x8(%ebp),%eax
c0107e27:	89 04 24             	mov    %eax,(%esp)
c0107e2a:	e8 6e fd ff ff       	call   c0107b9d <get_pte>
c0107e2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (ptep == NULL) {
c0107e32:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107e36:	75 18                	jne    c0107e50 <unmap_range+0xbb>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
c0107e38:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107e3b:	05 00 00 40 00       	add    $0x400000,%eax
c0107e40:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107e43:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107e46:	25 00 00 c0 ff       	and    $0xffc00000,%eax
c0107e4b:	89 45 0c             	mov    %eax,0xc(%ebp)
            continue ;
c0107e4e:	eb 29                	jmp    c0107e79 <unmap_range+0xe4>
        }
        if (*ptep != 0) {
c0107e50:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107e53:	8b 00                	mov    (%eax),%eax
c0107e55:	85 c0                	test   %eax,%eax
c0107e57:	74 19                	je     c0107e72 <unmap_range+0xdd>
            page_remove_pte(pgdir, start, ptep);
c0107e59:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107e5c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107e60:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107e63:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107e67:	8b 45 08             	mov    0x8(%ebp),%eax
c0107e6a:	89 04 24             	mov    %eax,(%esp)
c0107e6d:	e8 bc fe ff ff       	call   c0107d2e <page_remove_pte>
        }
        start += PGSIZE;
c0107e72:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
    } while (start != 0 && start < end);
c0107e79:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0107e7d:	74 08                	je     c0107e87 <unmap_range+0xf2>
c0107e7f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107e82:	3b 45 10             	cmp    0x10(%ebp),%eax
c0107e85:	72 8e                	jb     c0107e15 <unmap_range+0x80>
}
c0107e87:	c9                   	leave  
c0107e88:	c3                   	ret    

c0107e89 <exit_range>:

void
exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
c0107e89:	55                   	push   %ebp
c0107e8a:	89 e5                	mov    %esp,%ebp
c0107e8c:	83 ec 28             	sub    $0x28,%esp
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
c0107e8f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107e92:	25 ff 0f 00 00       	and    $0xfff,%eax
c0107e97:	85 c0                	test   %eax,%eax
c0107e99:	75 0c                	jne    c0107ea7 <exit_range+0x1e>
c0107e9b:	8b 45 10             	mov    0x10(%ebp),%eax
c0107e9e:	25 ff 0f 00 00       	and    $0xfff,%eax
c0107ea3:	85 c0                	test   %eax,%eax
c0107ea5:	74 24                	je     c0107ecb <exit_range+0x42>
c0107ea7:	c7 44 24 0c 80 dd 10 	movl   $0xc010dd80,0xc(%esp)
c0107eae:	c0 
c0107eaf:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c0107eb6:	c0 
c0107eb7:	c7 44 24 04 a4 01 00 	movl   $0x1a4,0x4(%esp)
c0107ebe:	00 
c0107ebf:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c0107ec6:	e8 3a 85 ff ff       	call   c0100405 <__panic>
    assert(USER_ACCESS(start, end));
c0107ecb:	81 7d 0c ff ff 1f 00 	cmpl   $0x1fffff,0xc(%ebp)
c0107ed2:	76 11                	jbe    c0107ee5 <exit_range+0x5c>
c0107ed4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107ed7:	3b 45 10             	cmp    0x10(%ebp),%eax
c0107eda:	73 09                	jae    c0107ee5 <exit_range+0x5c>
c0107edc:	81 7d 10 00 00 00 b0 	cmpl   $0xb0000000,0x10(%ebp)
c0107ee3:	76 24                	jbe    c0107f09 <exit_range+0x80>
c0107ee5:	c7 44 24 0c a9 dd 10 	movl   $0xc010dda9,0xc(%esp)
c0107eec:	c0 
c0107eed:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c0107ef4:	c0 
c0107ef5:	c7 44 24 04 a5 01 00 	movl   $0x1a5,0x4(%esp)
c0107efc:	00 
c0107efd:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c0107f04:	e8 fc 84 ff ff       	call   c0100405 <__panic>

    start = ROUNDDOWN(start, PTSIZE);
c0107f09:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107f0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107f0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f12:	25 00 00 c0 ff       	and    $0xffc00000,%eax
c0107f17:	89 45 0c             	mov    %eax,0xc(%ebp)
    do {
        int pde_idx = PDX(start);
c0107f1a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107f1d:	c1 e8 16             	shr    $0x16,%eax
c0107f20:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (pgdir[pde_idx] & PTE_P) {
c0107f23:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107f26:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0107f2d:	8b 45 08             	mov    0x8(%ebp),%eax
c0107f30:	01 d0                	add    %edx,%eax
c0107f32:	8b 00                	mov    (%eax),%eax
c0107f34:	83 e0 01             	and    $0x1,%eax
c0107f37:	85 c0                	test   %eax,%eax
c0107f39:	74 3e                	je     c0107f79 <exit_range+0xf0>
            free_page(pde2page(pgdir[pde_idx]));
c0107f3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107f3e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0107f45:	8b 45 08             	mov    0x8(%ebp),%eax
c0107f48:	01 d0                	add    %edx,%eax
c0107f4a:	8b 00                	mov    (%eax),%eax
c0107f4c:	89 04 24             	mov    %eax,(%esp)
c0107f4f:	e8 48 f3 ff ff       	call   c010729c <pde2page>
c0107f54:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107f5b:	00 
c0107f5c:	89 04 24             	mov    %eax,(%esp)
c0107f5f:	e8 c0 f5 ff ff       	call   c0107524 <free_pages>
            pgdir[pde_idx] = 0;
c0107f64:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107f67:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0107f6e:	8b 45 08             	mov    0x8(%ebp),%eax
c0107f71:	01 d0                	add    %edx,%eax
c0107f73:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        }
        start += PTSIZE;
c0107f79:	81 45 0c 00 00 40 00 	addl   $0x400000,0xc(%ebp)
    } while (start != 0 && start < end);
c0107f80:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0107f84:	74 08                	je     c0107f8e <exit_range+0x105>
c0107f86:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107f89:	3b 45 10             	cmp    0x10(%ebp),%eax
c0107f8c:	72 8c                	jb     c0107f1a <exit_range+0x91>
}
c0107f8e:	c9                   	leave  
c0107f8f:	c3                   	ret    

c0107f90 <copy_range>:
 * @share: flags to indicate to dup OR share. We just use dup method, so it didn't be used.
 *
 * CALL GRAPH: copy_mm-->dup_mmap-->copy_range
 */
int
copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end, bool share) {
c0107f90:	55                   	push   %ebp
c0107f91:	89 e5                	mov    %esp,%ebp
c0107f93:	83 ec 48             	sub    $0x48,%esp
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
c0107f96:	8b 45 10             	mov    0x10(%ebp),%eax
c0107f99:	25 ff 0f 00 00       	and    $0xfff,%eax
c0107f9e:	85 c0                	test   %eax,%eax
c0107fa0:	75 0c                	jne    c0107fae <copy_range+0x1e>
c0107fa2:	8b 45 14             	mov    0x14(%ebp),%eax
c0107fa5:	25 ff 0f 00 00       	and    $0xfff,%eax
c0107faa:	85 c0                	test   %eax,%eax
c0107fac:	74 24                	je     c0107fd2 <copy_range+0x42>
c0107fae:	c7 44 24 0c 80 dd 10 	movl   $0xc010dd80,0xc(%esp)
c0107fb5:	c0 
c0107fb6:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c0107fbd:	c0 
c0107fbe:	c7 44 24 04 ba 01 00 	movl   $0x1ba,0x4(%esp)
c0107fc5:	00 
c0107fc6:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c0107fcd:	e8 33 84 ff ff       	call   c0100405 <__panic>
    assert(USER_ACCESS(start, end));
c0107fd2:	81 7d 10 ff ff 1f 00 	cmpl   $0x1fffff,0x10(%ebp)
c0107fd9:	76 11                	jbe    c0107fec <copy_range+0x5c>
c0107fdb:	8b 45 10             	mov    0x10(%ebp),%eax
c0107fde:	3b 45 14             	cmp    0x14(%ebp),%eax
c0107fe1:	73 09                	jae    c0107fec <copy_range+0x5c>
c0107fe3:	81 7d 14 00 00 00 b0 	cmpl   $0xb0000000,0x14(%ebp)
c0107fea:	76 24                	jbe    c0108010 <copy_range+0x80>
c0107fec:	c7 44 24 0c a9 dd 10 	movl   $0xc010dda9,0xc(%esp)
c0107ff3:	c0 
c0107ff4:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c0107ffb:	c0 
c0107ffc:	c7 44 24 04 bb 01 00 	movl   $0x1bb,0x4(%esp)
c0108003:	00 
c0108004:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c010800b:	e8 f5 83 ff ff       	call   c0100405 <__panic>
    // copy content by page unit.
    do {
        //call get_pte to find process A's pte according to the addr start
        pte_t *ptep = get_pte(from, start, 0), *nptep;
c0108010:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0108017:	00 
c0108018:	8b 45 10             	mov    0x10(%ebp),%eax
c010801b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010801f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108022:	89 04 24             	mov    %eax,(%esp)
c0108025:	e8 73 fb ff ff       	call   c0107b9d <get_pte>
c010802a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (ptep == NULL) {
c010802d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108031:	75 1b                	jne    c010804e <copy_range+0xbe>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
c0108033:	8b 45 10             	mov    0x10(%ebp),%eax
c0108036:	05 00 00 40 00       	add    $0x400000,%eax
c010803b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010803e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108041:	25 00 00 c0 ff       	and    $0xffc00000,%eax
c0108046:	89 45 10             	mov    %eax,0x10(%ebp)
            continue ;
c0108049:	e9 4c 01 00 00       	jmp    c010819a <copy_range+0x20a>
        }
        //call get_pte to find process B's pte according to the addr start. If pte is NULL, just alloc a PT
        if (*ptep & PTE_P) {
c010804e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108051:	8b 00                	mov    (%eax),%eax
c0108053:	83 e0 01             	and    $0x1,%eax
c0108056:	85 c0                	test   %eax,%eax
c0108058:	0f 84 35 01 00 00    	je     c0108193 <copy_range+0x203>
            if ((nptep = get_pte(to, start, 1)) == NULL) {
c010805e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0108065:	00 
c0108066:	8b 45 10             	mov    0x10(%ebp),%eax
c0108069:	89 44 24 04          	mov    %eax,0x4(%esp)
c010806d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108070:	89 04 24             	mov    %eax,(%esp)
c0108073:	e8 25 fb ff ff       	call   c0107b9d <get_pte>
c0108078:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010807b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010807f:	75 0a                	jne    c010808b <copy_range+0xfb>
                return -E_NO_MEM;
c0108081:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0108086:	e9 26 01 00 00       	jmp    c01081b1 <copy_range+0x221>
            }
        uint32_t perm = (*ptep & PTE_USER);
c010808b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010808e:	8b 00                	mov    (%eax),%eax
c0108090:	83 e0 07             	and    $0x7,%eax
c0108093:	89 45 e8             	mov    %eax,-0x18(%ebp)
        //get page from ptep
        struct Page *page = pte2page(*ptep);
c0108096:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108099:	8b 00                	mov    (%eax),%eax
c010809b:	89 04 24             	mov    %eax,(%esp)
c010809e:	e8 bb f1 ff ff       	call   c010725e <pte2page>
c01080a3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        // alloc a page for process B
        struct Page *npage=alloc_page();
c01080a6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01080ad:	e8 07 f4 ff ff       	call   c01074b9 <alloc_pages>
c01080b2:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(page!=NULL);
c01080b5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01080b9:	75 24                	jne    c01080df <copy_range+0x14f>
c01080bb:	c7 44 24 0c c1 dd 10 	movl   $0xc010ddc1,0xc(%esp)
c01080c2:	c0 
c01080c3:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c01080ca:	c0 
c01080cb:	c7 44 24 04 ce 01 00 	movl   $0x1ce,0x4(%esp)
c01080d2:	00 
c01080d3:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c01080da:	e8 26 83 ff ff       	call   c0100405 <__panic>
        assert(npage!=NULL);
c01080df:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01080e3:	75 24                	jne    c0108109 <copy_range+0x179>
c01080e5:	c7 44 24 0c cc dd 10 	movl   $0xc010ddcc,0xc(%esp)
c01080ec:	c0 
c01080ed:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c01080f4:	c0 
c01080f5:	c7 44 24 04 cf 01 00 	movl   $0x1cf,0x4(%esp)
c01080fc:	00 
c01080fd:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c0108104:	e8 fc 82 ff ff       	call   c0100405 <__panic>
        int ret=0;
c0108109:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
         * (1) find src_kvaddr: the kernel virtual address of page
         * (2) find dst_kvaddr: the kernel virtual address of npage
         * (3) memory copy from src_kvaddr to dst_kvaddr, size is PGSIZE
         * (4) build the map of phy addr of  nage with the linear addr start
         */
        void * kva_src = page2kva(page);
c0108110:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108113:	89 04 24             	mov    %eax,(%esp)
c0108116:	e8 ef f0 ff ff       	call   c010720a <page2kva>
c010811b:	89 45 d8             	mov    %eax,-0x28(%ebp)
        void * kva_dst = page2kva(npage);
c010811e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108121:	89 04 24             	mov    %eax,(%esp)
c0108124:	e8 e1 f0 ff ff       	call   c010720a <page2kva>
c0108129:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    
        memcpy(kva_dst, kva_src, PGSIZE);
c010812c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0108133:	00 
c0108134:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108137:	89 44 24 04          	mov    %eax,0x4(%esp)
c010813b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010813e:	89 04 24             	mov    %eax,(%esp)
c0108141:	e8 ce 39 00 00       	call   c010bb14 <memcpy>

        ret = page_insert(to, npage, start, perm);
c0108146:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108149:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010814d:	8b 45 10             	mov    0x10(%ebp),%eax
c0108150:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108154:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108157:	89 44 24 04          	mov    %eax,0x4(%esp)
c010815b:	8b 45 08             	mov    0x8(%ebp),%eax
c010815e:	89 04 24             	mov    %eax,(%esp)
c0108161:	e8 91 00 00 00       	call   c01081f7 <page_insert>
c0108166:	89 45 dc             	mov    %eax,-0x24(%ebp)
        assert(ret == 0);
c0108169:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010816d:	74 24                	je     c0108193 <copy_range+0x203>
c010816f:	c7 44 24 0c d8 dd 10 	movl   $0xc010ddd8,0xc(%esp)
c0108176:	c0 
c0108177:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c010817e:	c0 
c010817f:	c7 44 24 04 e5 01 00 	movl   $0x1e5,0x4(%esp)
c0108186:	00 
c0108187:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c010818e:	e8 72 82 ff ff       	call   c0100405 <__panic>
        }
        start += PGSIZE;
c0108193:	81 45 10 00 10 00 00 	addl   $0x1000,0x10(%ebp)
    } while (start != 0 && start < end);
c010819a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010819e:	74 0c                	je     c01081ac <copy_range+0x21c>
c01081a0:	8b 45 10             	mov    0x10(%ebp),%eax
c01081a3:	3b 45 14             	cmp    0x14(%ebp),%eax
c01081a6:	0f 82 64 fe ff ff    	jb     c0108010 <copy_range+0x80>
    return 0;
c01081ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01081b1:	c9                   	leave  
c01081b2:	c3                   	ret    

c01081b3 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c01081b3:	55                   	push   %ebp
c01081b4:	89 e5                	mov    %esp,%ebp
c01081b6:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01081b9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01081c0:	00 
c01081c1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01081c4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01081c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01081cb:	89 04 24             	mov    %eax,(%esp)
c01081ce:	e8 ca f9 ff ff       	call   c0107b9d <get_pte>
c01081d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c01081d6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01081da:	74 19                	je     c01081f5 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c01081dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01081df:	89 44 24 08          	mov    %eax,0x8(%esp)
c01081e3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01081e6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01081ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01081ed:	89 04 24             	mov    %eax,(%esp)
c01081f0:	e8 39 fb ff ff       	call   c0107d2e <page_remove_pte>
    }
}
c01081f5:	c9                   	leave  
c01081f6:	c3                   	ret    

c01081f7 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c01081f7:	55                   	push   %ebp
c01081f8:	89 e5                	mov    %esp,%ebp
c01081fa:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c01081fd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0108204:	00 
c0108205:	8b 45 10             	mov    0x10(%ebp),%eax
c0108208:	89 44 24 04          	mov    %eax,0x4(%esp)
c010820c:	8b 45 08             	mov    0x8(%ebp),%eax
c010820f:	89 04 24             	mov    %eax,(%esp)
c0108212:	e8 86 f9 ff ff       	call   c0107b9d <get_pte>
c0108217:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c010821a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010821e:	75 0a                	jne    c010822a <page_insert+0x33>
        return -E_NO_MEM;
c0108220:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0108225:	e9 84 00 00 00       	jmp    c01082ae <page_insert+0xb7>
    }
    page_ref_inc(page);
c010822a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010822d:	89 04 24             	mov    %eax,(%esp)
c0108230:	e8 96 f0 ff ff       	call   c01072cb <page_ref_inc>
    if (*ptep & PTE_P) {
c0108235:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108238:	8b 00                	mov    (%eax),%eax
c010823a:	83 e0 01             	and    $0x1,%eax
c010823d:	85 c0                	test   %eax,%eax
c010823f:	74 3e                	je     c010827f <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c0108241:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108244:	8b 00                	mov    (%eax),%eax
c0108246:	89 04 24             	mov    %eax,(%esp)
c0108249:	e8 10 f0 ff ff       	call   c010725e <pte2page>
c010824e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c0108251:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108254:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108257:	75 0d                	jne    c0108266 <page_insert+0x6f>
            page_ref_dec(page);
c0108259:	8b 45 0c             	mov    0xc(%ebp),%eax
c010825c:	89 04 24             	mov    %eax,(%esp)
c010825f:	e8 7e f0 ff ff       	call   c01072e2 <page_ref_dec>
c0108264:	eb 19                	jmp    c010827f <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0108266:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108269:	89 44 24 08          	mov    %eax,0x8(%esp)
c010826d:	8b 45 10             	mov    0x10(%ebp),%eax
c0108270:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108274:	8b 45 08             	mov    0x8(%ebp),%eax
c0108277:	89 04 24             	mov    %eax,(%esp)
c010827a:	e8 af fa ff ff       	call   c0107d2e <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c010827f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108282:	89 04 24             	mov    %eax,(%esp)
c0108285:	e8 25 ef ff ff       	call   c01071af <page2pa>
c010828a:	0b 45 14             	or     0x14(%ebp),%eax
c010828d:	83 c8 01             	or     $0x1,%eax
c0108290:	89 c2                	mov    %eax,%edx
c0108292:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108295:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c0108297:	8b 45 10             	mov    0x10(%ebp),%eax
c010829a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010829e:	8b 45 08             	mov    0x8(%ebp),%eax
c01082a1:	89 04 24             	mov    %eax,(%esp)
c01082a4:	e8 07 00 00 00       	call   c01082b0 <tlb_invalidate>
    return 0;
c01082a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01082ae:	c9                   	leave  
c01082af:	c3                   	ret    

c01082b0 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c01082b0:	55                   	push   %ebp
c01082b1:	89 e5                	mov    %esp,%ebp
c01082b3:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c01082b6:	0f 20 d8             	mov    %cr3,%eax
c01082b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c01082bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
c01082bf:	89 c2                	mov    %eax,%edx
c01082c1:	8b 45 08             	mov    0x8(%ebp),%eax
c01082c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01082c7:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01082ce:	77 23                	ja     c01082f3 <tlb_invalidate+0x43>
c01082d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01082d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01082d7:	c7 44 24 08 fc dc 10 	movl   $0xc010dcfc,0x8(%esp)
c01082de:	c0 
c01082df:	c7 44 24 04 16 02 00 	movl   $0x216,0x4(%esp)
c01082e6:	00 
c01082e7:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c01082ee:	e8 12 81 ff ff       	call   c0100405 <__panic>
c01082f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01082f6:	05 00 00 00 40       	add    $0x40000000,%eax
c01082fb:	39 c2                	cmp    %eax,%edx
c01082fd:	75 0c                	jne    c010830b <tlb_invalidate+0x5b>
        invlpg((void *)la);
c01082ff:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108302:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0108305:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108308:	0f 01 38             	invlpg (%eax)
    }
}
c010830b:	c9                   	leave  
c010830c:	c3                   	ret    

c010830d <pgdir_alloc_page>:

// pgdir_alloc_page - call alloc_page & page_insert functions to 
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *
pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
c010830d:	55                   	push   %ebp
c010830e:	89 e5                	mov    %esp,%ebp
c0108310:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_page();
c0108313:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010831a:	e8 9a f1 ff ff       	call   c01074b9 <alloc_pages>
c010831f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c0108322:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108326:	0f 84 b0 00 00 00    	je     c01083dc <pgdir_alloc_page+0xcf>
        if (page_insert(pgdir, page, la, perm) != 0) {
c010832c:	8b 45 10             	mov    0x10(%ebp),%eax
c010832f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108333:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108336:	89 44 24 08          	mov    %eax,0x8(%esp)
c010833a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010833d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108341:	8b 45 08             	mov    0x8(%ebp),%eax
c0108344:	89 04 24             	mov    %eax,(%esp)
c0108347:	e8 ab fe ff ff       	call   c01081f7 <page_insert>
c010834c:	85 c0                	test   %eax,%eax
c010834e:	74 1a                	je     c010836a <pgdir_alloc_page+0x5d>
            free_page(page);
c0108350:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0108357:	00 
c0108358:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010835b:	89 04 24             	mov    %eax,(%esp)
c010835e:	e8 c1 f1 ff ff       	call   c0107524 <free_pages>
            return NULL;
c0108363:	b8 00 00 00 00       	mov    $0x0,%eax
c0108368:	eb 75                	jmp    c01083df <pgdir_alloc_page+0xd2>
        }
        if (swap_init_ok){
c010836a:	a1 6c 0f 1b c0       	mov    0xc01b0f6c,%eax
c010836f:	85 c0                	test   %eax,%eax
c0108371:	74 69                	je     c01083dc <pgdir_alloc_page+0xcf>
            if(check_mm_struct!=NULL) {
c0108373:	a1 7c 30 1b c0       	mov    0xc01b307c,%eax
c0108378:	85 c0                	test   %eax,%eax
c010837a:	74 60                	je     c01083dc <pgdir_alloc_page+0xcf>
                swap_map_swappable(check_mm_struct, la, page, 0);
c010837c:	a1 7c 30 1b c0       	mov    0xc01b307c,%eax
c0108381:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0108388:	00 
c0108389:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010838c:	89 54 24 08          	mov    %edx,0x8(%esp)
c0108390:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108393:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108397:	89 04 24             	mov    %eax,(%esp)
c010839a:	e8 e7 d1 ff ff       	call   c0105586 <swap_map_swappable>
                page->pra_vaddr=la;
c010839f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01083a2:	8b 55 0c             	mov    0xc(%ebp),%edx
c01083a5:	89 50 1c             	mov    %edx,0x1c(%eax)
                assert(page_ref(page) == 1);
c01083a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01083ab:	89 04 24             	mov    %eax,(%esp)
c01083ae:	e8 01 ef ff ff       	call   c01072b4 <page_ref>
c01083b3:	83 f8 01             	cmp    $0x1,%eax
c01083b6:	74 24                	je     c01083dc <pgdir_alloc_page+0xcf>
c01083b8:	c7 44 24 0c e1 dd 10 	movl   $0xc010dde1,0xc(%esp)
c01083bf:	c0 
c01083c0:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c01083c7:	c0 
c01083c8:	c7 44 24 04 2a 02 00 	movl   $0x22a,0x4(%esp)
c01083cf:	00 
c01083d0:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c01083d7:	e8 29 80 ff ff       	call   c0100405 <__panic>
            }
        }

    }

    return page;
c01083dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01083df:	c9                   	leave  
c01083e0:	c3                   	ret    

c01083e1 <check_alloc_page>:

static void
check_alloc_page(void) {
c01083e1:	55                   	push   %ebp
c01083e2:	89 e5                	mov    %esp,%ebp
c01083e4:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c01083e7:	a1 70 31 1b c0       	mov    0xc01b3170,%eax
c01083ec:	8b 40 18             	mov    0x18(%eax),%eax
c01083ef:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c01083f1:	c7 04 24 f8 dd 10 c0 	movl   $0xc010ddf8,(%esp)
c01083f8:	e8 b1 7e ff ff       	call   c01002ae <cprintf>
}
c01083fd:	c9                   	leave  
c01083fe:	c3                   	ret    

c01083ff <check_pgdir>:

static void
check_pgdir(void) {
c01083ff:	55                   	push   %ebp
c0108400:	89 e5                	mov    %esp,%ebp
c0108402:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c0108405:	a1 80 0f 1b c0       	mov    0xc01b0f80,%eax
c010840a:	3d 00 80 03 00       	cmp    $0x38000,%eax
c010840f:	76 24                	jbe    c0108435 <check_pgdir+0x36>
c0108411:	c7 44 24 0c 17 de 10 	movl   $0xc010de17,0xc(%esp)
c0108418:	c0 
c0108419:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c0108420:	c0 
c0108421:	c7 44 24 04 42 02 00 	movl   $0x242,0x4(%esp)
c0108428:	00 
c0108429:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c0108430:	e8 d0 7f ff ff       	call   c0100405 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0108435:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c010843a:	85 c0                	test   %eax,%eax
c010843c:	74 0e                	je     c010844c <check_pgdir+0x4d>
c010843e:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0108443:	25 ff 0f 00 00       	and    $0xfff,%eax
c0108448:	85 c0                	test   %eax,%eax
c010844a:	74 24                	je     c0108470 <check_pgdir+0x71>
c010844c:	c7 44 24 0c 34 de 10 	movl   $0xc010de34,0xc(%esp)
c0108453:	c0 
c0108454:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c010845b:	c0 
c010845c:	c7 44 24 04 43 02 00 	movl   $0x243,0x4(%esp)
c0108463:	00 
c0108464:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c010846b:	e8 95 7f ff ff       	call   c0100405 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c0108470:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0108475:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010847c:	00 
c010847d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0108484:	00 
c0108485:	89 04 24             	mov    %eax,(%esp)
c0108488:	e8 48 f8 ff ff       	call   c0107cd5 <get_page>
c010848d:	85 c0                	test   %eax,%eax
c010848f:	74 24                	je     c01084b5 <check_pgdir+0xb6>
c0108491:	c7 44 24 0c 6c de 10 	movl   $0xc010de6c,0xc(%esp)
c0108498:	c0 
c0108499:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c01084a0:	c0 
c01084a1:	c7 44 24 04 44 02 00 	movl   $0x244,0x4(%esp)
c01084a8:	00 
c01084a9:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c01084b0:	e8 50 7f ff ff       	call   c0100405 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c01084b5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01084bc:	e8 f8 ef ff ff       	call   c01074b9 <alloc_pages>
c01084c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c01084c4:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c01084c9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01084d0:	00 
c01084d1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01084d8:	00 
c01084d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01084dc:	89 54 24 04          	mov    %edx,0x4(%esp)
c01084e0:	89 04 24             	mov    %eax,(%esp)
c01084e3:	e8 0f fd ff ff       	call   c01081f7 <page_insert>
c01084e8:	85 c0                	test   %eax,%eax
c01084ea:	74 24                	je     c0108510 <check_pgdir+0x111>
c01084ec:	c7 44 24 0c 94 de 10 	movl   $0xc010de94,0xc(%esp)
c01084f3:	c0 
c01084f4:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c01084fb:	c0 
c01084fc:	c7 44 24 04 48 02 00 	movl   $0x248,0x4(%esp)
c0108503:	00 
c0108504:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c010850b:	e8 f5 7e ff ff       	call   c0100405 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0108510:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0108515:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010851c:	00 
c010851d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0108524:	00 
c0108525:	89 04 24             	mov    %eax,(%esp)
c0108528:	e8 70 f6 ff ff       	call   c0107b9d <get_pte>
c010852d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108530:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0108534:	75 24                	jne    c010855a <check_pgdir+0x15b>
c0108536:	c7 44 24 0c c0 de 10 	movl   $0xc010dec0,0xc(%esp)
c010853d:	c0 
c010853e:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c0108545:	c0 
c0108546:	c7 44 24 04 4b 02 00 	movl   $0x24b,0x4(%esp)
c010854d:	00 
c010854e:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c0108555:	e8 ab 7e ff ff       	call   c0100405 <__panic>
    assert(pte2page(*ptep) == p1);
c010855a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010855d:	8b 00                	mov    (%eax),%eax
c010855f:	89 04 24             	mov    %eax,(%esp)
c0108562:	e8 f7 ec ff ff       	call   c010725e <pte2page>
c0108567:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010856a:	74 24                	je     c0108590 <check_pgdir+0x191>
c010856c:	c7 44 24 0c ed de 10 	movl   $0xc010deed,0xc(%esp)
c0108573:	c0 
c0108574:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c010857b:	c0 
c010857c:	c7 44 24 04 4c 02 00 	movl   $0x24c,0x4(%esp)
c0108583:	00 
c0108584:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c010858b:	e8 75 7e ff ff       	call   c0100405 <__panic>
    assert(page_ref(p1) == 1);
c0108590:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108593:	89 04 24             	mov    %eax,(%esp)
c0108596:	e8 19 ed ff ff       	call   c01072b4 <page_ref>
c010859b:	83 f8 01             	cmp    $0x1,%eax
c010859e:	74 24                	je     c01085c4 <check_pgdir+0x1c5>
c01085a0:	c7 44 24 0c 03 df 10 	movl   $0xc010df03,0xc(%esp)
c01085a7:	c0 
c01085a8:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c01085af:	c0 
c01085b0:	c7 44 24 04 4d 02 00 	movl   $0x24d,0x4(%esp)
c01085b7:	00 
c01085b8:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c01085bf:	e8 41 7e ff ff       	call   c0100405 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c01085c4:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c01085c9:	8b 00                	mov    (%eax),%eax
c01085cb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01085d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01085d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01085d6:	c1 e8 0c             	shr    $0xc,%eax
c01085d9:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01085dc:	a1 80 0f 1b c0       	mov    0xc01b0f80,%eax
c01085e1:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01085e4:	72 23                	jb     c0108609 <check_pgdir+0x20a>
c01085e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01085e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01085ed:	c7 44 24 08 58 dc 10 	movl   $0xc010dc58,0x8(%esp)
c01085f4:	c0 
c01085f5:	c7 44 24 04 4f 02 00 	movl   $0x24f,0x4(%esp)
c01085fc:	00 
c01085fd:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c0108604:	e8 fc 7d ff ff       	call   c0100405 <__panic>
c0108609:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010860c:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0108611:	83 c0 04             	add    $0x4,%eax
c0108614:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0108617:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c010861c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0108623:	00 
c0108624:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c010862b:	00 
c010862c:	89 04 24             	mov    %eax,(%esp)
c010862f:	e8 69 f5 ff ff       	call   c0107b9d <get_pte>
c0108634:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0108637:	74 24                	je     c010865d <check_pgdir+0x25e>
c0108639:	c7 44 24 0c 18 df 10 	movl   $0xc010df18,0xc(%esp)
c0108640:	c0 
c0108641:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c0108648:	c0 
c0108649:	c7 44 24 04 50 02 00 	movl   $0x250,0x4(%esp)
c0108650:	00 
c0108651:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c0108658:	e8 a8 7d ff ff       	call   c0100405 <__panic>

    p2 = alloc_page();
c010865d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108664:	e8 50 ee ff ff       	call   c01074b9 <alloc_pages>
c0108669:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c010866c:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0108671:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c0108678:	00 
c0108679:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0108680:	00 
c0108681:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108684:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108688:	89 04 24             	mov    %eax,(%esp)
c010868b:	e8 67 fb ff ff       	call   c01081f7 <page_insert>
c0108690:	85 c0                	test   %eax,%eax
c0108692:	74 24                	je     c01086b8 <check_pgdir+0x2b9>
c0108694:	c7 44 24 0c 40 df 10 	movl   $0xc010df40,0xc(%esp)
c010869b:	c0 
c010869c:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c01086a3:	c0 
c01086a4:	c7 44 24 04 53 02 00 	movl   $0x253,0x4(%esp)
c01086ab:	00 
c01086ac:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c01086b3:	e8 4d 7d ff ff       	call   c0100405 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c01086b8:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c01086bd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01086c4:	00 
c01086c5:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01086cc:	00 
c01086cd:	89 04 24             	mov    %eax,(%esp)
c01086d0:	e8 c8 f4 ff ff       	call   c0107b9d <get_pte>
c01086d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01086d8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01086dc:	75 24                	jne    c0108702 <check_pgdir+0x303>
c01086de:	c7 44 24 0c 78 df 10 	movl   $0xc010df78,0xc(%esp)
c01086e5:	c0 
c01086e6:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c01086ed:	c0 
c01086ee:	c7 44 24 04 54 02 00 	movl   $0x254,0x4(%esp)
c01086f5:	00 
c01086f6:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c01086fd:	e8 03 7d ff ff       	call   c0100405 <__panic>
    assert(*ptep & PTE_U);
c0108702:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108705:	8b 00                	mov    (%eax),%eax
c0108707:	83 e0 04             	and    $0x4,%eax
c010870a:	85 c0                	test   %eax,%eax
c010870c:	75 24                	jne    c0108732 <check_pgdir+0x333>
c010870e:	c7 44 24 0c a8 df 10 	movl   $0xc010dfa8,0xc(%esp)
c0108715:	c0 
c0108716:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c010871d:	c0 
c010871e:	c7 44 24 04 55 02 00 	movl   $0x255,0x4(%esp)
c0108725:	00 
c0108726:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c010872d:	e8 d3 7c ff ff       	call   c0100405 <__panic>
    assert(*ptep & PTE_W);
c0108732:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108735:	8b 00                	mov    (%eax),%eax
c0108737:	83 e0 02             	and    $0x2,%eax
c010873a:	85 c0                	test   %eax,%eax
c010873c:	75 24                	jne    c0108762 <check_pgdir+0x363>
c010873e:	c7 44 24 0c b6 df 10 	movl   $0xc010dfb6,0xc(%esp)
c0108745:	c0 
c0108746:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c010874d:	c0 
c010874e:	c7 44 24 04 56 02 00 	movl   $0x256,0x4(%esp)
c0108755:	00 
c0108756:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c010875d:	e8 a3 7c ff ff       	call   c0100405 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0108762:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0108767:	8b 00                	mov    (%eax),%eax
c0108769:	83 e0 04             	and    $0x4,%eax
c010876c:	85 c0                	test   %eax,%eax
c010876e:	75 24                	jne    c0108794 <check_pgdir+0x395>
c0108770:	c7 44 24 0c c4 df 10 	movl   $0xc010dfc4,0xc(%esp)
c0108777:	c0 
c0108778:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c010877f:	c0 
c0108780:	c7 44 24 04 57 02 00 	movl   $0x257,0x4(%esp)
c0108787:	00 
c0108788:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c010878f:	e8 71 7c ff ff       	call   c0100405 <__panic>
    assert(page_ref(p2) == 1);
c0108794:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108797:	89 04 24             	mov    %eax,(%esp)
c010879a:	e8 15 eb ff ff       	call   c01072b4 <page_ref>
c010879f:	83 f8 01             	cmp    $0x1,%eax
c01087a2:	74 24                	je     c01087c8 <check_pgdir+0x3c9>
c01087a4:	c7 44 24 0c da df 10 	movl   $0xc010dfda,0xc(%esp)
c01087ab:	c0 
c01087ac:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c01087b3:	c0 
c01087b4:	c7 44 24 04 58 02 00 	movl   $0x258,0x4(%esp)
c01087bb:	00 
c01087bc:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c01087c3:	e8 3d 7c ff ff       	call   c0100405 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c01087c8:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c01087cd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01087d4:	00 
c01087d5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01087dc:	00 
c01087dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01087e0:	89 54 24 04          	mov    %edx,0x4(%esp)
c01087e4:	89 04 24             	mov    %eax,(%esp)
c01087e7:	e8 0b fa ff ff       	call   c01081f7 <page_insert>
c01087ec:	85 c0                	test   %eax,%eax
c01087ee:	74 24                	je     c0108814 <check_pgdir+0x415>
c01087f0:	c7 44 24 0c ec df 10 	movl   $0xc010dfec,0xc(%esp)
c01087f7:	c0 
c01087f8:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c01087ff:	c0 
c0108800:	c7 44 24 04 5a 02 00 	movl   $0x25a,0x4(%esp)
c0108807:	00 
c0108808:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c010880f:	e8 f1 7b ff ff       	call   c0100405 <__panic>
    assert(page_ref(p1) == 2);
c0108814:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108817:	89 04 24             	mov    %eax,(%esp)
c010881a:	e8 95 ea ff ff       	call   c01072b4 <page_ref>
c010881f:	83 f8 02             	cmp    $0x2,%eax
c0108822:	74 24                	je     c0108848 <check_pgdir+0x449>
c0108824:	c7 44 24 0c 18 e0 10 	movl   $0xc010e018,0xc(%esp)
c010882b:	c0 
c010882c:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c0108833:	c0 
c0108834:	c7 44 24 04 5b 02 00 	movl   $0x25b,0x4(%esp)
c010883b:	00 
c010883c:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c0108843:	e8 bd 7b ff ff       	call   c0100405 <__panic>
    assert(page_ref(p2) == 0);
c0108848:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010884b:	89 04 24             	mov    %eax,(%esp)
c010884e:	e8 61 ea ff ff       	call   c01072b4 <page_ref>
c0108853:	85 c0                	test   %eax,%eax
c0108855:	74 24                	je     c010887b <check_pgdir+0x47c>
c0108857:	c7 44 24 0c 2a e0 10 	movl   $0xc010e02a,0xc(%esp)
c010885e:	c0 
c010885f:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c0108866:	c0 
c0108867:	c7 44 24 04 5c 02 00 	movl   $0x25c,0x4(%esp)
c010886e:	00 
c010886f:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c0108876:	e8 8a 7b ff ff       	call   c0100405 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c010887b:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0108880:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0108887:	00 
c0108888:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c010888f:	00 
c0108890:	89 04 24             	mov    %eax,(%esp)
c0108893:	e8 05 f3 ff ff       	call   c0107b9d <get_pte>
c0108898:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010889b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010889f:	75 24                	jne    c01088c5 <check_pgdir+0x4c6>
c01088a1:	c7 44 24 0c 78 df 10 	movl   $0xc010df78,0xc(%esp)
c01088a8:	c0 
c01088a9:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c01088b0:	c0 
c01088b1:	c7 44 24 04 5d 02 00 	movl   $0x25d,0x4(%esp)
c01088b8:	00 
c01088b9:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c01088c0:	e8 40 7b ff ff       	call   c0100405 <__panic>
    assert(pte2page(*ptep) == p1);
c01088c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01088c8:	8b 00                	mov    (%eax),%eax
c01088ca:	89 04 24             	mov    %eax,(%esp)
c01088cd:	e8 8c e9 ff ff       	call   c010725e <pte2page>
c01088d2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01088d5:	74 24                	je     c01088fb <check_pgdir+0x4fc>
c01088d7:	c7 44 24 0c ed de 10 	movl   $0xc010deed,0xc(%esp)
c01088de:	c0 
c01088df:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c01088e6:	c0 
c01088e7:	c7 44 24 04 5e 02 00 	movl   $0x25e,0x4(%esp)
c01088ee:	00 
c01088ef:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c01088f6:	e8 0a 7b ff ff       	call   c0100405 <__panic>
    assert((*ptep & PTE_U) == 0);
c01088fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01088fe:	8b 00                	mov    (%eax),%eax
c0108900:	83 e0 04             	and    $0x4,%eax
c0108903:	85 c0                	test   %eax,%eax
c0108905:	74 24                	je     c010892b <check_pgdir+0x52c>
c0108907:	c7 44 24 0c 3c e0 10 	movl   $0xc010e03c,0xc(%esp)
c010890e:	c0 
c010890f:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c0108916:	c0 
c0108917:	c7 44 24 04 5f 02 00 	movl   $0x25f,0x4(%esp)
c010891e:	00 
c010891f:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c0108926:	e8 da 7a ff ff       	call   c0100405 <__panic>

    page_remove(boot_pgdir, 0x0);
c010892b:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0108930:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0108937:	00 
c0108938:	89 04 24             	mov    %eax,(%esp)
c010893b:	e8 73 f8 ff ff       	call   c01081b3 <page_remove>
    assert(page_ref(p1) == 1);
c0108940:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108943:	89 04 24             	mov    %eax,(%esp)
c0108946:	e8 69 e9 ff ff       	call   c01072b4 <page_ref>
c010894b:	83 f8 01             	cmp    $0x1,%eax
c010894e:	74 24                	je     c0108974 <check_pgdir+0x575>
c0108950:	c7 44 24 0c 03 df 10 	movl   $0xc010df03,0xc(%esp)
c0108957:	c0 
c0108958:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c010895f:	c0 
c0108960:	c7 44 24 04 62 02 00 	movl   $0x262,0x4(%esp)
c0108967:	00 
c0108968:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c010896f:	e8 91 7a ff ff       	call   c0100405 <__panic>
    assert(page_ref(p2) == 0);
c0108974:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108977:	89 04 24             	mov    %eax,(%esp)
c010897a:	e8 35 e9 ff ff       	call   c01072b4 <page_ref>
c010897f:	85 c0                	test   %eax,%eax
c0108981:	74 24                	je     c01089a7 <check_pgdir+0x5a8>
c0108983:	c7 44 24 0c 2a e0 10 	movl   $0xc010e02a,0xc(%esp)
c010898a:	c0 
c010898b:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c0108992:	c0 
c0108993:	c7 44 24 04 63 02 00 	movl   $0x263,0x4(%esp)
c010899a:	00 
c010899b:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c01089a2:	e8 5e 7a ff ff       	call   c0100405 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c01089a7:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c01089ac:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01089b3:	00 
c01089b4:	89 04 24             	mov    %eax,(%esp)
c01089b7:	e8 f7 f7 ff ff       	call   c01081b3 <page_remove>
    assert(page_ref(p1) == 0);
c01089bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01089bf:	89 04 24             	mov    %eax,(%esp)
c01089c2:	e8 ed e8 ff ff       	call   c01072b4 <page_ref>
c01089c7:	85 c0                	test   %eax,%eax
c01089c9:	74 24                	je     c01089ef <check_pgdir+0x5f0>
c01089cb:	c7 44 24 0c 51 e0 10 	movl   $0xc010e051,0xc(%esp)
c01089d2:	c0 
c01089d3:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c01089da:	c0 
c01089db:	c7 44 24 04 66 02 00 	movl   $0x266,0x4(%esp)
c01089e2:	00 
c01089e3:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c01089ea:	e8 16 7a ff ff       	call   c0100405 <__panic>
    assert(page_ref(p2) == 0);
c01089ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01089f2:	89 04 24             	mov    %eax,(%esp)
c01089f5:	e8 ba e8 ff ff       	call   c01072b4 <page_ref>
c01089fa:	85 c0                	test   %eax,%eax
c01089fc:	74 24                	je     c0108a22 <check_pgdir+0x623>
c01089fe:	c7 44 24 0c 2a e0 10 	movl   $0xc010e02a,0xc(%esp)
c0108a05:	c0 
c0108a06:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c0108a0d:	c0 
c0108a0e:	c7 44 24 04 67 02 00 	movl   $0x267,0x4(%esp)
c0108a15:	00 
c0108a16:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c0108a1d:	e8 e3 79 ff ff       	call   c0100405 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0108a22:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0108a27:	8b 00                	mov    (%eax),%eax
c0108a29:	89 04 24             	mov    %eax,(%esp)
c0108a2c:	e8 6b e8 ff ff       	call   c010729c <pde2page>
c0108a31:	89 04 24             	mov    %eax,(%esp)
c0108a34:	e8 7b e8 ff ff       	call   c01072b4 <page_ref>
c0108a39:	83 f8 01             	cmp    $0x1,%eax
c0108a3c:	74 24                	je     c0108a62 <check_pgdir+0x663>
c0108a3e:	c7 44 24 0c 64 e0 10 	movl   $0xc010e064,0xc(%esp)
c0108a45:	c0 
c0108a46:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c0108a4d:	c0 
c0108a4e:	c7 44 24 04 69 02 00 	movl   $0x269,0x4(%esp)
c0108a55:	00 
c0108a56:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c0108a5d:	e8 a3 79 ff ff       	call   c0100405 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0108a62:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0108a67:	8b 00                	mov    (%eax),%eax
c0108a69:	89 04 24             	mov    %eax,(%esp)
c0108a6c:	e8 2b e8 ff ff       	call   c010729c <pde2page>
c0108a71:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0108a78:	00 
c0108a79:	89 04 24             	mov    %eax,(%esp)
c0108a7c:	e8 a3 ea ff ff       	call   c0107524 <free_pages>
    boot_pgdir[0] = 0;
c0108a81:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0108a86:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0108a8c:	c7 04 24 8b e0 10 c0 	movl   $0xc010e08b,(%esp)
c0108a93:	e8 16 78 ff ff       	call   c01002ae <cprintf>
}
c0108a98:	c9                   	leave  
c0108a99:	c3                   	ret    

c0108a9a <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0108a9a:	55                   	push   %ebp
c0108a9b:	89 e5                	mov    %esp,%ebp
c0108a9d:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0108aa0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0108aa7:	e9 ca 00 00 00       	jmp    c0108b76 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0108aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108aaf:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108ab2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108ab5:	c1 e8 0c             	shr    $0xc,%eax
c0108ab8:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108abb:	a1 80 0f 1b c0       	mov    0xc01b0f80,%eax
c0108ac0:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0108ac3:	72 23                	jb     c0108ae8 <check_boot_pgdir+0x4e>
c0108ac5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108ac8:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108acc:	c7 44 24 08 58 dc 10 	movl   $0xc010dc58,0x8(%esp)
c0108ad3:	c0 
c0108ad4:	c7 44 24 04 75 02 00 	movl   $0x275,0x4(%esp)
c0108adb:	00 
c0108adc:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c0108ae3:	e8 1d 79 ff ff       	call   c0100405 <__panic>
c0108ae8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108aeb:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0108af0:	89 c2                	mov    %eax,%edx
c0108af2:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0108af7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0108afe:	00 
c0108aff:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108b03:	89 04 24             	mov    %eax,(%esp)
c0108b06:	e8 92 f0 ff ff       	call   c0107b9d <get_pte>
c0108b0b:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108b0e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108b12:	75 24                	jne    c0108b38 <check_boot_pgdir+0x9e>
c0108b14:	c7 44 24 0c a8 e0 10 	movl   $0xc010e0a8,0xc(%esp)
c0108b1b:	c0 
c0108b1c:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c0108b23:	c0 
c0108b24:	c7 44 24 04 75 02 00 	movl   $0x275,0x4(%esp)
c0108b2b:	00 
c0108b2c:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c0108b33:	e8 cd 78 ff ff       	call   c0100405 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0108b38:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108b3b:	8b 00                	mov    (%eax),%eax
c0108b3d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0108b42:	89 c2                	mov    %eax,%edx
c0108b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108b47:	39 c2                	cmp    %eax,%edx
c0108b49:	74 24                	je     c0108b6f <check_boot_pgdir+0xd5>
c0108b4b:	c7 44 24 0c e5 e0 10 	movl   $0xc010e0e5,0xc(%esp)
c0108b52:	c0 
c0108b53:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c0108b5a:	c0 
c0108b5b:	c7 44 24 04 76 02 00 	movl   $0x276,0x4(%esp)
c0108b62:	00 
c0108b63:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c0108b6a:	e8 96 78 ff ff       	call   c0100405 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
c0108b6f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0108b76:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108b79:	a1 80 0f 1b c0       	mov    0xc01b0f80,%eax
c0108b7e:	39 c2                	cmp    %eax,%edx
c0108b80:	0f 82 26 ff ff ff    	jb     c0108aac <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0108b86:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0108b8b:	05 ac 0f 00 00       	add    $0xfac,%eax
c0108b90:	8b 00                	mov    (%eax),%eax
c0108b92:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0108b97:	89 c2                	mov    %eax,%edx
c0108b99:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0108b9e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108ba1:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c0108ba8:	77 23                	ja     c0108bcd <check_boot_pgdir+0x133>
c0108baa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108bad:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108bb1:	c7 44 24 08 fc dc 10 	movl   $0xc010dcfc,0x8(%esp)
c0108bb8:	c0 
c0108bb9:	c7 44 24 04 79 02 00 	movl   $0x279,0x4(%esp)
c0108bc0:	00 
c0108bc1:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c0108bc8:	e8 38 78 ff ff       	call   c0100405 <__panic>
c0108bcd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108bd0:	05 00 00 00 40       	add    $0x40000000,%eax
c0108bd5:	39 c2                	cmp    %eax,%edx
c0108bd7:	74 24                	je     c0108bfd <check_boot_pgdir+0x163>
c0108bd9:	c7 44 24 0c fc e0 10 	movl   $0xc010e0fc,0xc(%esp)
c0108be0:	c0 
c0108be1:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c0108be8:	c0 
c0108be9:	c7 44 24 04 79 02 00 	movl   $0x279,0x4(%esp)
c0108bf0:	00 
c0108bf1:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c0108bf8:	e8 08 78 ff ff       	call   c0100405 <__panic>

    assert(boot_pgdir[0] == 0);
c0108bfd:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0108c02:	8b 00                	mov    (%eax),%eax
c0108c04:	85 c0                	test   %eax,%eax
c0108c06:	74 24                	je     c0108c2c <check_boot_pgdir+0x192>
c0108c08:	c7 44 24 0c 30 e1 10 	movl   $0xc010e130,0xc(%esp)
c0108c0f:	c0 
c0108c10:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c0108c17:	c0 
c0108c18:	c7 44 24 04 7b 02 00 	movl   $0x27b,0x4(%esp)
c0108c1f:	00 
c0108c20:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c0108c27:	e8 d9 77 ff ff       	call   c0100405 <__panic>

    struct Page *p;
    p = alloc_page();
c0108c2c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108c33:	e8 81 e8 ff ff       	call   c01074b9 <alloc_pages>
c0108c38:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0108c3b:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0108c40:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0108c47:	00 
c0108c48:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0108c4f:	00 
c0108c50:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108c53:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108c57:	89 04 24             	mov    %eax,(%esp)
c0108c5a:	e8 98 f5 ff ff       	call   c01081f7 <page_insert>
c0108c5f:	85 c0                	test   %eax,%eax
c0108c61:	74 24                	je     c0108c87 <check_boot_pgdir+0x1ed>
c0108c63:	c7 44 24 0c 44 e1 10 	movl   $0xc010e144,0xc(%esp)
c0108c6a:	c0 
c0108c6b:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c0108c72:	c0 
c0108c73:	c7 44 24 04 7f 02 00 	movl   $0x27f,0x4(%esp)
c0108c7a:	00 
c0108c7b:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c0108c82:	e8 7e 77 ff ff       	call   c0100405 <__panic>
    assert(page_ref(p) == 1);
c0108c87:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108c8a:	89 04 24             	mov    %eax,(%esp)
c0108c8d:	e8 22 e6 ff ff       	call   c01072b4 <page_ref>
c0108c92:	83 f8 01             	cmp    $0x1,%eax
c0108c95:	74 24                	je     c0108cbb <check_boot_pgdir+0x221>
c0108c97:	c7 44 24 0c 72 e1 10 	movl   $0xc010e172,0xc(%esp)
c0108c9e:	c0 
c0108c9f:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c0108ca6:	c0 
c0108ca7:	c7 44 24 04 80 02 00 	movl   $0x280,0x4(%esp)
c0108cae:	00 
c0108caf:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c0108cb6:	e8 4a 77 ff ff       	call   c0100405 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0108cbb:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0108cc0:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0108cc7:	00 
c0108cc8:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0108ccf:	00 
c0108cd0:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108cd3:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108cd7:	89 04 24             	mov    %eax,(%esp)
c0108cda:	e8 18 f5 ff ff       	call   c01081f7 <page_insert>
c0108cdf:	85 c0                	test   %eax,%eax
c0108ce1:	74 24                	je     c0108d07 <check_boot_pgdir+0x26d>
c0108ce3:	c7 44 24 0c 84 e1 10 	movl   $0xc010e184,0xc(%esp)
c0108cea:	c0 
c0108ceb:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c0108cf2:	c0 
c0108cf3:	c7 44 24 04 81 02 00 	movl   $0x281,0x4(%esp)
c0108cfa:	00 
c0108cfb:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c0108d02:	e8 fe 76 ff ff       	call   c0100405 <__panic>
    assert(page_ref(p) == 2);
c0108d07:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108d0a:	89 04 24             	mov    %eax,(%esp)
c0108d0d:	e8 a2 e5 ff ff       	call   c01072b4 <page_ref>
c0108d12:	83 f8 02             	cmp    $0x2,%eax
c0108d15:	74 24                	je     c0108d3b <check_boot_pgdir+0x2a1>
c0108d17:	c7 44 24 0c bb e1 10 	movl   $0xc010e1bb,0xc(%esp)
c0108d1e:	c0 
c0108d1f:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c0108d26:	c0 
c0108d27:	c7 44 24 04 82 02 00 	movl   $0x282,0x4(%esp)
c0108d2e:	00 
c0108d2f:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c0108d36:	e8 ca 76 ff ff       	call   c0100405 <__panic>

    const char *str = "ucore: Hello world!!";
c0108d3b:	c7 45 dc cc e1 10 c0 	movl   $0xc010e1cc,-0x24(%ebp)
    strcpy((void *)0x100, str);
c0108d42:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108d45:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108d49:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0108d50:	e8 06 2a 00 00       	call   c010b75b <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0108d55:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0108d5c:	00 
c0108d5d:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0108d64:	e8 6b 2a 00 00       	call   c010b7d4 <strcmp>
c0108d69:	85 c0                	test   %eax,%eax
c0108d6b:	74 24                	je     c0108d91 <check_boot_pgdir+0x2f7>
c0108d6d:	c7 44 24 0c e4 e1 10 	movl   $0xc010e1e4,0xc(%esp)
c0108d74:	c0 
c0108d75:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c0108d7c:	c0 
c0108d7d:	c7 44 24 04 86 02 00 	movl   $0x286,0x4(%esp)
c0108d84:	00 
c0108d85:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c0108d8c:	e8 74 76 ff ff       	call   c0100405 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0108d91:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108d94:	89 04 24             	mov    %eax,(%esp)
c0108d97:	e8 6e e4 ff ff       	call   c010720a <page2kva>
c0108d9c:	05 00 01 00 00       	add    $0x100,%eax
c0108da1:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0108da4:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0108dab:	e8 53 29 00 00       	call   c010b703 <strlen>
c0108db0:	85 c0                	test   %eax,%eax
c0108db2:	74 24                	je     c0108dd8 <check_boot_pgdir+0x33e>
c0108db4:	c7 44 24 0c 1c e2 10 	movl   $0xc010e21c,0xc(%esp)
c0108dbb:	c0 
c0108dbc:	c7 44 24 08 45 dd 10 	movl   $0xc010dd45,0x8(%esp)
c0108dc3:	c0 
c0108dc4:	c7 44 24 04 89 02 00 	movl   $0x289,0x4(%esp)
c0108dcb:	00 
c0108dcc:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c0108dd3:	e8 2d 76 ff ff       	call   c0100405 <__panic>

    free_page(p);
c0108dd8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0108ddf:	00 
c0108de0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108de3:	89 04 24             	mov    %eax,(%esp)
c0108de6:	e8 39 e7 ff ff       	call   c0107524 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0108deb:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0108df0:	8b 00                	mov    (%eax),%eax
c0108df2:	89 04 24             	mov    %eax,(%esp)
c0108df5:	e8 a2 e4 ff ff       	call   c010729c <pde2page>
c0108dfa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0108e01:	00 
c0108e02:	89 04 24             	mov    %eax,(%esp)
c0108e05:	e8 1a e7 ff ff       	call   c0107524 <free_pages>
    boot_pgdir[0] = 0;
c0108e0a:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0108e0f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0108e15:	c7 04 24 40 e2 10 c0 	movl   $0xc010e240,(%esp)
c0108e1c:	e8 8d 74 ff ff       	call   c01002ae <cprintf>
}
c0108e21:	c9                   	leave  
c0108e22:	c3                   	ret    

c0108e23 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0108e23:	55                   	push   %ebp
c0108e24:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0108e26:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e29:	83 e0 04             	and    $0x4,%eax
c0108e2c:	85 c0                	test   %eax,%eax
c0108e2e:	74 07                	je     c0108e37 <perm2str+0x14>
c0108e30:	b8 75 00 00 00       	mov    $0x75,%eax
c0108e35:	eb 05                	jmp    c0108e3c <perm2str+0x19>
c0108e37:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0108e3c:	a2 08 10 1b c0       	mov    %al,0xc01b1008
    str[1] = 'r';
c0108e41:	c6 05 09 10 1b c0 72 	movb   $0x72,0xc01b1009
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0108e48:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e4b:	83 e0 02             	and    $0x2,%eax
c0108e4e:	85 c0                	test   %eax,%eax
c0108e50:	74 07                	je     c0108e59 <perm2str+0x36>
c0108e52:	b8 77 00 00 00       	mov    $0x77,%eax
c0108e57:	eb 05                	jmp    c0108e5e <perm2str+0x3b>
c0108e59:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0108e5e:	a2 0a 10 1b c0       	mov    %al,0xc01b100a
    str[3] = '\0';
c0108e63:	c6 05 0b 10 1b c0 00 	movb   $0x0,0xc01b100b
    return str;
c0108e6a:	b8 08 10 1b c0       	mov    $0xc01b1008,%eax
}
c0108e6f:	5d                   	pop    %ebp
c0108e70:	c3                   	ret    

c0108e71 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0108e71:	55                   	push   %ebp
c0108e72:	89 e5                	mov    %esp,%ebp
c0108e74:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0108e77:	8b 45 10             	mov    0x10(%ebp),%eax
c0108e7a:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108e7d:	72 0a                	jb     c0108e89 <get_pgtable_items+0x18>
        return 0;
c0108e7f:	b8 00 00 00 00       	mov    $0x0,%eax
c0108e84:	e9 9c 00 00 00       	jmp    c0108f25 <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
c0108e89:	eb 04                	jmp    c0108e8f <get_pgtable_items+0x1e>
        start ++;
c0108e8b:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
c0108e8f:	8b 45 10             	mov    0x10(%ebp),%eax
c0108e92:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108e95:	73 18                	jae    c0108eaf <get_pgtable_items+0x3e>
c0108e97:	8b 45 10             	mov    0x10(%ebp),%eax
c0108e9a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0108ea1:	8b 45 14             	mov    0x14(%ebp),%eax
c0108ea4:	01 d0                	add    %edx,%eax
c0108ea6:	8b 00                	mov    (%eax),%eax
c0108ea8:	83 e0 01             	and    $0x1,%eax
c0108eab:	85 c0                	test   %eax,%eax
c0108ead:	74 dc                	je     c0108e8b <get_pgtable_items+0x1a>
    }
    if (start < right) {
c0108eaf:	8b 45 10             	mov    0x10(%ebp),%eax
c0108eb2:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108eb5:	73 69                	jae    c0108f20 <get_pgtable_items+0xaf>
        if (left_store != NULL) {
c0108eb7:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0108ebb:	74 08                	je     c0108ec5 <get_pgtable_items+0x54>
            *left_store = start;
c0108ebd:	8b 45 18             	mov    0x18(%ebp),%eax
c0108ec0:	8b 55 10             	mov    0x10(%ebp),%edx
c0108ec3:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0108ec5:	8b 45 10             	mov    0x10(%ebp),%eax
c0108ec8:	8d 50 01             	lea    0x1(%eax),%edx
c0108ecb:	89 55 10             	mov    %edx,0x10(%ebp)
c0108ece:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0108ed5:	8b 45 14             	mov    0x14(%ebp),%eax
c0108ed8:	01 d0                	add    %edx,%eax
c0108eda:	8b 00                	mov    (%eax),%eax
c0108edc:	83 e0 07             	and    $0x7,%eax
c0108edf:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0108ee2:	eb 04                	jmp    c0108ee8 <get_pgtable_items+0x77>
            start ++;
c0108ee4:	83 45 10 01          	addl   $0x1,0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0108ee8:	8b 45 10             	mov    0x10(%ebp),%eax
c0108eeb:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108eee:	73 1d                	jae    c0108f0d <get_pgtable_items+0x9c>
c0108ef0:	8b 45 10             	mov    0x10(%ebp),%eax
c0108ef3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0108efa:	8b 45 14             	mov    0x14(%ebp),%eax
c0108efd:	01 d0                	add    %edx,%eax
c0108eff:	8b 00                	mov    (%eax),%eax
c0108f01:	83 e0 07             	and    $0x7,%eax
c0108f04:	89 c2                	mov    %eax,%edx
c0108f06:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108f09:	39 c2                	cmp    %eax,%edx
c0108f0b:	74 d7                	je     c0108ee4 <get_pgtable_items+0x73>
        }
        if (right_store != NULL) {
c0108f0d:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0108f11:	74 08                	je     c0108f1b <get_pgtable_items+0xaa>
            *right_store = start;
c0108f13:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0108f16:	8b 55 10             	mov    0x10(%ebp),%edx
c0108f19:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0108f1b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108f1e:	eb 05                	jmp    c0108f25 <get_pgtable_items+0xb4>
    }
    return 0;
c0108f20:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108f25:	c9                   	leave  
c0108f26:	c3                   	ret    

c0108f27 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0108f27:	55                   	push   %ebp
c0108f28:	89 e5                	mov    %esp,%ebp
c0108f2a:	57                   	push   %edi
c0108f2b:	56                   	push   %esi
c0108f2c:	53                   	push   %ebx
c0108f2d:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0108f30:	c7 04 24 60 e2 10 c0 	movl   $0xc010e260,(%esp)
c0108f37:	e8 72 73 ff ff       	call   c01002ae <cprintf>
    size_t left, right = 0, perm;
c0108f3c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0108f43:	e9 fa 00 00 00       	jmp    c0109042 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0108f48:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108f4b:	89 04 24             	mov    %eax,(%esp)
c0108f4e:	e8 d0 fe ff ff       	call   c0108e23 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0108f53:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0108f56:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108f59:	29 d1                	sub    %edx,%ecx
c0108f5b:	89 ca                	mov    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0108f5d:	89 d6                	mov    %edx,%esi
c0108f5f:	c1 e6 16             	shl    $0x16,%esi
c0108f62:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0108f65:	89 d3                	mov    %edx,%ebx
c0108f67:	c1 e3 16             	shl    $0x16,%ebx
c0108f6a:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108f6d:	89 d1                	mov    %edx,%ecx
c0108f6f:	c1 e1 16             	shl    $0x16,%ecx
c0108f72:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0108f75:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108f78:	29 d7                	sub    %edx,%edi
c0108f7a:	89 fa                	mov    %edi,%edx
c0108f7c:	89 44 24 14          	mov    %eax,0x14(%esp)
c0108f80:	89 74 24 10          	mov    %esi,0x10(%esp)
c0108f84:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0108f88:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0108f8c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108f90:	c7 04 24 91 e2 10 c0 	movl   $0xc010e291,(%esp)
c0108f97:	e8 12 73 ff ff       	call   c01002ae <cprintf>
        size_t l, r = left * NPTEENTRY;
c0108f9c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108f9f:	c1 e0 0a             	shl    $0xa,%eax
c0108fa2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0108fa5:	eb 54                	jmp    c0108ffb <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0108fa7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108faa:	89 04 24             	mov    %eax,(%esp)
c0108fad:	e8 71 fe ff ff       	call   c0108e23 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0108fb2:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0108fb5:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0108fb8:	29 d1                	sub    %edx,%ecx
c0108fba:	89 ca                	mov    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0108fbc:	89 d6                	mov    %edx,%esi
c0108fbe:	c1 e6 0c             	shl    $0xc,%esi
c0108fc1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0108fc4:	89 d3                	mov    %edx,%ebx
c0108fc6:	c1 e3 0c             	shl    $0xc,%ebx
c0108fc9:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0108fcc:	c1 e2 0c             	shl    $0xc,%edx
c0108fcf:	89 d1                	mov    %edx,%ecx
c0108fd1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c0108fd4:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0108fd7:	29 d7                	sub    %edx,%edi
c0108fd9:	89 fa                	mov    %edi,%edx
c0108fdb:	89 44 24 14          	mov    %eax,0x14(%esp)
c0108fdf:	89 74 24 10          	mov    %esi,0x10(%esp)
c0108fe3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0108fe7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0108feb:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108fef:	c7 04 24 b0 e2 10 c0 	movl   $0xc010e2b0,(%esp)
c0108ff6:	e8 b3 72 ff ff       	call   c01002ae <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0108ffb:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
c0109000:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0109003:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0109006:	89 ce                	mov    %ecx,%esi
c0109008:	c1 e6 0a             	shl    $0xa,%esi
c010900b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c010900e:	89 cb                	mov    %ecx,%ebx
c0109010:	c1 e3 0a             	shl    $0xa,%ebx
c0109013:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
c0109016:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c010901a:	8d 4d d8             	lea    -0x28(%ebp),%ecx
c010901d:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0109021:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0109025:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109029:	89 74 24 04          	mov    %esi,0x4(%esp)
c010902d:	89 1c 24             	mov    %ebx,(%esp)
c0109030:	e8 3c fe ff ff       	call   c0108e71 <get_pgtable_items>
c0109035:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0109038:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010903c:	0f 85 65 ff ff ff    	jne    c0108fa7 <print_pgdir+0x80>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0109042:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
c0109047:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010904a:	8d 4d dc             	lea    -0x24(%ebp),%ecx
c010904d:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c0109051:	8d 4d e0             	lea    -0x20(%ebp),%ecx
c0109054:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0109058:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010905c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109060:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c0109067:	00 
c0109068:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010906f:	e8 fd fd ff ff       	call   c0108e71 <get_pgtable_items>
c0109074:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0109077:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010907b:	0f 85 c7 fe ff ff    	jne    c0108f48 <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0109081:	c7 04 24 d4 e2 10 c0 	movl   $0xc010e2d4,(%esp)
c0109088:	e8 21 72 ff ff       	call   c01002ae <cprintf>
}
c010908d:	83 c4 4c             	add    $0x4c,%esp
c0109090:	5b                   	pop    %ebx
c0109091:	5e                   	pop    %esi
c0109092:	5f                   	pop    %edi
c0109093:	5d                   	pop    %ebp
c0109094:	c3                   	ret    

c0109095 <page2ppn>:
page2ppn(struct Page *page) {
c0109095:	55                   	push   %ebp
c0109096:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0109098:	8b 55 08             	mov    0x8(%ebp),%edx
c010909b:	a1 78 31 1b c0       	mov    0xc01b3178,%eax
c01090a0:	29 c2                	sub    %eax,%edx
c01090a2:	89 d0                	mov    %edx,%eax
c01090a4:	c1 f8 05             	sar    $0x5,%eax
}
c01090a7:	5d                   	pop    %ebp
c01090a8:	c3                   	ret    

c01090a9 <page2pa>:
page2pa(struct Page *page) {
c01090a9:	55                   	push   %ebp
c01090aa:	89 e5                	mov    %esp,%ebp
c01090ac:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01090af:	8b 45 08             	mov    0x8(%ebp),%eax
c01090b2:	89 04 24             	mov    %eax,(%esp)
c01090b5:	e8 db ff ff ff       	call   c0109095 <page2ppn>
c01090ba:	c1 e0 0c             	shl    $0xc,%eax
}
c01090bd:	c9                   	leave  
c01090be:	c3                   	ret    

c01090bf <page2kva>:
page2kva(struct Page *page) {
c01090bf:	55                   	push   %ebp
c01090c0:	89 e5                	mov    %esp,%ebp
c01090c2:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c01090c5:	8b 45 08             	mov    0x8(%ebp),%eax
c01090c8:	89 04 24             	mov    %eax,(%esp)
c01090cb:	e8 d9 ff ff ff       	call   c01090a9 <page2pa>
c01090d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01090d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01090d6:	c1 e8 0c             	shr    $0xc,%eax
c01090d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01090dc:	a1 80 0f 1b c0       	mov    0xc01b0f80,%eax
c01090e1:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01090e4:	72 23                	jb     c0109109 <page2kva+0x4a>
c01090e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01090e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01090ed:	c7 44 24 08 08 e3 10 	movl   $0xc010e308,0x8(%esp)
c01090f4:	c0 
c01090f5:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c01090fc:	00 
c01090fd:	c7 04 24 2b e3 10 c0 	movl   $0xc010e32b,(%esp)
c0109104:	e8 fc 72 ff ff       	call   c0100405 <__panic>
c0109109:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010910c:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0109111:	c9                   	leave  
c0109112:	c3                   	ret    

c0109113 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
c0109113:	55                   	push   %ebp
c0109114:	89 e5                	mov    %esp,%ebp
c0109116:	83 ec 18             	sub    $0x18,%esp
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
c0109119:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0109120:	e8 0b 81 ff ff       	call   c0101230 <ide_device_valid>
c0109125:	85 c0                	test   %eax,%eax
c0109127:	75 1c                	jne    c0109145 <swapfs_init+0x32>
        panic("swap fs isn't available.\n");
c0109129:	c7 44 24 08 39 e3 10 	movl   $0xc010e339,0x8(%esp)
c0109130:	c0 
c0109131:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
c0109138:	00 
c0109139:	c7 04 24 53 e3 10 c0 	movl   $0xc010e353,(%esp)
c0109140:	e8 c0 72 ff ff       	call   c0100405 <__panic>
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
c0109145:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010914c:	e8 1e 81 ff ff       	call   c010126f <ide_device_size>
c0109151:	c1 e8 03             	shr    $0x3,%eax
c0109154:	a3 3c 31 1b c0       	mov    %eax,0xc01b313c
}
c0109159:	c9                   	leave  
c010915a:	c3                   	ret    

c010915b <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
c010915b:	55                   	push   %ebp
c010915c:	89 e5                	mov    %esp,%ebp
c010915e:	83 ec 28             	sub    $0x28,%esp
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c0109161:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109164:	89 04 24             	mov    %eax,(%esp)
c0109167:	e8 53 ff ff ff       	call   c01090bf <page2kva>
c010916c:	8b 55 08             	mov    0x8(%ebp),%edx
c010916f:	c1 ea 08             	shr    $0x8,%edx
c0109172:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0109175:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109179:	74 0b                	je     c0109186 <swapfs_read+0x2b>
c010917b:	8b 15 3c 31 1b c0    	mov    0xc01b313c,%edx
c0109181:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c0109184:	72 23                	jb     c01091a9 <swapfs_read+0x4e>
c0109186:	8b 45 08             	mov    0x8(%ebp),%eax
c0109189:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010918d:	c7 44 24 08 64 e3 10 	movl   $0xc010e364,0x8(%esp)
c0109194:	c0 
c0109195:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c010919c:	00 
c010919d:	c7 04 24 53 e3 10 c0 	movl   $0xc010e353,(%esp)
c01091a4:	e8 5c 72 ff ff       	call   c0100405 <__panic>
c01091a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01091ac:	c1 e2 03             	shl    $0x3,%edx
c01091af:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c01091b6:	00 
c01091b7:	89 44 24 08          	mov    %eax,0x8(%esp)
c01091bb:	89 54 24 04          	mov    %edx,0x4(%esp)
c01091bf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01091c6:	e8 e3 80 ff ff       	call   c01012ae <ide_read_secs>
}
c01091cb:	c9                   	leave  
c01091cc:	c3                   	ret    

c01091cd <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
c01091cd:	55                   	push   %ebp
c01091ce:	89 e5                	mov    %esp,%ebp
c01091d0:	83 ec 28             	sub    $0x28,%esp
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c01091d3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01091d6:	89 04 24             	mov    %eax,(%esp)
c01091d9:	e8 e1 fe ff ff       	call   c01090bf <page2kva>
c01091de:	8b 55 08             	mov    0x8(%ebp),%edx
c01091e1:	c1 ea 08             	shr    $0x8,%edx
c01091e4:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01091e7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01091eb:	74 0b                	je     c01091f8 <swapfs_write+0x2b>
c01091ed:	8b 15 3c 31 1b c0    	mov    0xc01b313c,%edx
c01091f3:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c01091f6:	72 23                	jb     c010921b <swapfs_write+0x4e>
c01091f8:	8b 45 08             	mov    0x8(%ebp),%eax
c01091fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01091ff:	c7 44 24 08 64 e3 10 	movl   $0xc010e364,0x8(%esp)
c0109206:	c0 
c0109207:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
c010920e:	00 
c010920f:	c7 04 24 53 e3 10 c0 	movl   $0xc010e353,(%esp)
c0109216:	e8 ea 71 ff ff       	call   c0100405 <__panic>
c010921b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010921e:	c1 e2 03             	shl    $0x3,%edx
c0109221:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c0109228:	00 
c0109229:	89 44 24 08          	mov    %eax,0x8(%esp)
c010922d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109231:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0109238:	e8 b3 82 ff ff       	call   c01014f0 <ide_write_secs>
}
c010923d:	c9                   	leave  
c010923e:	c3                   	ret    

c010923f <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)

    pushl %edx              # push arg
c010923f:	52                   	push   %edx
    call *%ebx              # call fn
c0109240:	ff d3                	call   *%ebx

    pushl %eax              # save the return value of fn(arg)
c0109242:	50                   	push   %eax
    call do_exit            # call do_exit to terminate current thread
c0109243:	e8 22 0d 00 00       	call   c0109f6a <do_exit>

c0109248 <switch_to>:
.text
.globl switch_to
switch_to:                      # switch_to(from, to)

    # save from's registers
    movl 4(%esp), %eax          # eax points to from
c0109248:	8b 44 24 04          	mov    0x4(%esp),%eax
    popl 0(%eax)                # save eip !popl
c010924c:	8f 00                	popl   (%eax)
    movl %esp, 4(%eax)
c010924e:	89 60 04             	mov    %esp,0x4(%eax)
    movl %ebx, 8(%eax)
c0109251:	89 58 08             	mov    %ebx,0x8(%eax)
    movl %ecx, 12(%eax)
c0109254:	89 48 0c             	mov    %ecx,0xc(%eax)
    movl %edx, 16(%eax)
c0109257:	89 50 10             	mov    %edx,0x10(%eax)
    movl %esi, 20(%eax)
c010925a:	89 70 14             	mov    %esi,0x14(%eax)
    movl %edi, 24(%eax)
c010925d:	89 78 18             	mov    %edi,0x18(%eax)
    movl %ebp, 28(%eax)
c0109260:	89 68 1c             	mov    %ebp,0x1c(%eax)

    # restore to's registers
    movl 4(%esp), %eax          # not 8(%esp): popped return address already
c0109263:	8b 44 24 04          	mov    0x4(%esp),%eax
                                # eax now points to to
    movl 28(%eax), %ebp
c0109267:	8b 68 1c             	mov    0x1c(%eax),%ebp
    movl 24(%eax), %edi
c010926a:	8b 78 18             	mov    0x18(%eax),%edi
    movl 20(%eax), %esi
c010926d:	8b 70 14             	mov    0x14(%eax),%esi
    movl 16(%eax), %edx
c0109270:	8b 50 10             	mov    0x10(%eax),%edx
    movl 12(%eax), %ecx
c0109273:	8b 48 0c             	mov    0xc(%eax),%ecx
    movl 8(%eax), %ebx
c0109276:	8b 58 08             	mov    0x8(%eax),%ebx
    movl 4(%eax), %esp
c0109279:	8b 60 04             	mov    0x4(%eax),%esp

    pushl 0(%eax)               # push eip
c010927c:	ff 30                	pushl  (%eax)

    ret
c010927e:	c3                   	ret    

c010927f <test_and_set_bit>:
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool
test_and_set_bit(int nr, volatile void *addr) {
c010927f:	55                   	push   %ebp
c0109280:	89 e5                	mov    %esp,%ebp
c0109282:	83 ec 10             	sub    $0x10,%esp
    int oldbit;
    asm volatile ("btsl %2, %1; sbbl %0, %0" : "=r" (oldbit), "=m" (*(volatile long *)addr) : "Ir" (nr) : "memory");
c0109285:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109288:	8b 45 08             	mov    0x8(%ebp),%eax
c010928b:	0f ab 02             	bts    %eax,(%edx)
c010928e:	19 c0                	sbb    %eax,%eax
c0109290:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return oldbit != 0;
c0109293:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0109297:	0f 95 c0             	setne  %al
c010929a:	0f b6 c0             	movzbl %al,%eax
}
c010929d:	c9                   	leave  
c010929e:	c3                   	ret    

c010929f <test_and_clear_bit>:
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool
test_and_clear_bit(int nr, volatile void *addr) {
c010929f:	55                   	push   %ebp
c01092a0:	89 e5                	mov    %esp,%ebp
c01092a2:	83 ec 10             	sub    $0x10,%esp
    int oldbit;
    asm volatile ("btrl %2, %1; sbbl %0, %0" : "=r" (oldbit), "=m" (*(volatile long *)addr) : "Ir" (nr) : "memory");
c01092a5:	8b 55 0c             	mov    0xc(%ebp),%edx
c01092a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01092ab:	0f b3 02             	btr    %eax,(%edx)
c01092ae:	19 c0                	sbb    %eax,%eax
c01092b0:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return oldbit != 0;
c01092b3:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01092b7:	0f 95 c0             	setne  %al
c01092ba:	0f b6 c0             	movzbl %al,%eax
}
c01092bd:	c9                   	leave  
c01092be:	c3                   	ret    

c01092bf <__intr_save>:
__intr_save(void) {
c01092bf:	55                   	push   %ebp
c01092c0:	89 e5                	mov    %esp,%ebp
c01092c2:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01092c5:	9c                   	pushf  
c01092c6:	58                   	pop    %eax
c01092c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01092ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01092cd:	25 00 02 00 00       	and    $0x200,%eax
c01092d2:	85 c0                	test   %eax,%eax
c01092d4:	74 0c                	je     c01092e2 <__intr_save+0x23>
        intr_disable();
c01092d6:	e8 3f 8f ff ff       	call   c010221a <intr_disable>
        return 1;
c01092db:	b8 01 00 00 00       	mov    $0x1,%eax
c01092e0:	eb 05                	jmp    c01092e7 <__intr_save+0x28>
    return 0;
c01092e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01092e7:	c9                   	leave  
c01092e8:	c3                   	ret    

c01092e9 <__intr_restore>:
__intr_restore(bool flag) {
c01092e9:	55                   	push   %ebp
c01092ea:	89 e5                	mov    %esp,%ebp
c01092ec:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01092ef:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01092f3:	74 05                	je     c01092fa <__intr_restore+0x11>
        intr_enable();
c01092f5:	e8 1a 8f ff ff       	call   c0102214 <intr_enable>
}
c01092fa:	c9                   	leave  
c01092fb:	c3                   	ret    

c01092fc <try_lock>:

static inline bool
try_lock(lock_t *lock) {
c01092fc:	55                   	push   %ebp
c01092fd:	89 e5                	mov    %esp,%ebp
c01092ff:	83 ec 08             	sub    $0x8,%esp
    return !test_and_set_bit(0, lock);
c0109302:	8b 45 08             	mov    0x8(%ebp),%eax
c0109305:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109309:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0109310:	e8 6a ff ff ff       	call   c010927f <test_and_set_bit>
c0109315:	85 c0                	test   %eax,%eax
c0109317:	0f 94 c0             	sete   %al
c010931a:	0f b6 c0             	movzbl %al,%eax
}
c010931d:	c9                   	leave  
c010931e:	c3                   	ret    

c010931f <lock>:

static inline void
lock(lock_t *lock) {
c010931f:	55                   	push   %ebp
c0109320:	89 e5                	mov    %esp,%ebp
c0109322:	83 ec 18             	sub    $0x18,%esp
    while (!try_lock(lock)) {
c0109325:	eb 05                	jmp    c010932c <lock+0xd>
        schedule();
c0109327:	e8 b9 1d 00 00       	call   c010b0e5 <schedule>
    while (!try_lock(lock)) {
c010932c:	8b 45 08             	mov    0x8(%ebp),%eax
c010932f:	89 04 24             	mov    %eax,(%esp)
c0109332:	e8 c5 ff ff ff       	call   c01092fc <try_lock>
c0109337:	85 c0                	test   %eax,%eax
c0109339:	74 ec                	je     c0109327 <lock+0x8>
    }
}
c010933b:	c9                   	leave  
c010933c:	c3                   	ret    

c010933d <unlock>:

static inline void
unlock(lock_t *lock) {
c010933d:	55                   	push   %ebp
c010933e:	89 e5                	mov    %esp,%ebp
c0109340:	83 ec 18             	sub    $0x18,%esp
    if (!test_and_clear_bit(0, lock)) {
c0109343:	8b 45 08             	mov    0x8(%ebp),%eax
c0109346:	89 44 24 04          	mov    %eax,0x4(%esp)
c010934a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0109351:	e8 49 ff ff ff       	call   c010929f <test_and_clear_bit>
c0109356:	85 c0                	test   %eax,%eax
c0109358:	75 1c                	jne    c0109376 <unlock+0x39>
        panic("Unlock failed.\n");
c010935a:	c7 44 24 08 84 e3 10 	movl   $0xc010e384,0x8(%esp)
c0109361:	c0 
c0109362:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
c0109369:	00 
c010936a:	c7 04 24 94 e3 10 c0 	movl   $0xc010e394,(%esp)
c0109371:	e8 8f 70 ff ff       	call   c0100405 <__panic>
    }
}
c0109376:	c9                   	leave  
c0109377:	c3                   	ret    

c0109378 <page2ppn>:
page2ppn(struct Page *page) {
c0109378:	55                   	push   %ebp
c0109379:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010937b:	8b 55 08             	mov    0x8(%ebp),%edx
c010937e:	a1 78 31 1b c0       	mov    0xc01b3178,%eax
c0109383:	29 c2                	sub    %eax,%edx
c0109385:	89 d0                	mov    %edx,%eax
c0109387:	c1 f8 05             	sar    $0x5,%eax
}
c010938a:	5d                   	pop    %ebp
c010938b:	c3                   	ret    

c010938c <page2pa>:
page2pa(struct Page *page) {
c010938c:	55                   	push   %ebp
c010938d:	89 e5                	mov    %esp,%ebp
c010938f:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0109392:	8b 45 08             	mov    0x8(%ebp),%eax
c0109395:	89 04 24             	mov    %eax,(%esp)
c0109398:	e8 db ff ff ff       	call   c0109378 <page2ppn>
c010939d:	c1 e0 0c             	shl    $0xc,%eax
}
c01093a0:	c9                   	leave  
c01093a1:	c3                   	ret    

c01093a2 <pa2page>:
pa2page(uintptr_t pa) {
c01093a2:	55                   	push   %ebp
c01093a3:	89 e5                	mov    %esp,%ebp
c01093a5:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c01093a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01093ab:	c1 e8 0c             	shr    $0xc,%eax
c01093ae:	89 c2                	mov    %eax,%edx
c01093b0:	a1 80 0f 1b c0       	mov    0xc01b0f80,%eax
c01093b5:	39 c2                	cmp    %eax,%edx
c01093b7:	72 1c                	jb     c01093d5 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c01093b9:	c7 44 24 08 a8 e3 10 	movl   $0xc010e3a8,0x8(%esp)
c01093c0:	c0 
c01093c1:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c01093c8:	00 
c01093c9:	c7 04 24 c7 e3 10 c0 	movl   $0xc010e3c7,(%esp)
c01093d0:	e8 30 70 ff ff       	call   c0100405 <__panic>
    return &pages[PPN(pa)];
c01093d5:	a1 78 31 1b c0       	mov    0xc01b3178,%eax
c01093da:	8b 55 08             	mov    0x8(%ebp),%edx
c01093dd:	c1 ea 0c             	shr    $0xc,%edx
c01093e0:	c1 e2 05             	shl    $0x5,%edx
c01093e3:	01 d0                	add    %edx,%eax
}
c01093e5:	c9                   	leave  
c01093e6:	c3                   	ret    

c01093e7 <page2kva>:
page2kva(struct Page *page) {
c01093e7:	55                   	push   %ebp
c01093e8:	89 e5                	mov    %esp,%ebp
c01093ea:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c01093ed:	8b 45 08             	mov    0x8(%ebp),%eax
c01093f0:	89 04 24             	mov    %eax,(%esp)
c01093f3:	e8 94 ff ff ff       	call   c010938c <page2pa>
c01093f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01093fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01093fe:	c1 e8 0c             	shr    $0xc,%eax
c0109401:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109404:	a1 80 0f 1b c0       	mov    0xc01b0f80,%eax
c0109409:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010940c:	72 23                	jb     c0109431 <page2kva+0x4a>
c010940e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109411:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109415:	c7 44 24 08 d8 e3 10 	movl   $0xc010e3d8,0x8(%esp)
c010941c:	c0 
c010941d:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0109424:	00 
c0109425:	c7 04 24 c7 e3 10 c0 	movl   $0xc010e3c7,(%esp)
c010942c:	e8 d4 6f ff ff       	call   c0100405 <__panic>
c0109431:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109434:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0109439:	c9                   	leave  
c010943a:	c3                   	ret    

c010943b <kva2page>:
kva2page(void *kva) {
c010943b:	55                   	push   %ebp
c010943c:	89 e5                	mov    %esp,%ebp
c010943e:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c0109441:	8b 45 08             	mov    0x8(%ebp),%eax
c0109444:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109447:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c010944e:	77 23                	ja     c0109473 <kva2page+0x38>
c0109450:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109453:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109457:	c7 44 24 08 fc e3 10 	movl   $0xc010e3fc,0x8(%esp)
c010945e:	c0 
c010945f:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c0109466:	00 
c0109467:	c7 04 24 c7 e3 10 c0 	movl   $0xc010e3c7,(%esp)
c010946e:	e8 92 6f ff ff       	call   c0100405 <__panic>
c0109473:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109476:	05 00 00 00 40       	add    $0x40000000,%eax
c010947b:	89 04 24             	mov    %eax,(%esp)
c010947e:	e8 1f ff ff ff       	call   c01093a2 <pa2page>
}
c0109483:	c9                   	leave  
c0109484:	c3                   	ret    

c0109485 <mm_count_inc>:

static inline int
mm_count_inc(struct mm_struct *mm) {
c0109485:	55                   	push   %ebp
c0109486:	89 e5                	mov    %esp,%ebp
    mm->mm_count += 1;
c0109488:	8b 45 08             	mov    0x8(%ebp),%eax
c010948b:	8b 40 18             	mov    0x18(%eax),%eax
c010948e:	8d 50 01             	lea    0x1(%eax),%edx
c0109491:	8b 45 08             	mov    0x8(%ebp),%eax
c0109494:	89 50 18             	mov    %edx,0x18(%eax)
    return mm->mm_count;
c0109497:	8b 45 08             	mov    0x8(%ebp),%eax
c010949a:	8b 40 18             	mov    0x18(%eax),%eax
}
c010949d:	5d                   	pop    %ebp
c010949e:	c3                   	ret    

c010949f <mm_count_dec>:

static inline int
mm_count_dec(struct mm_struct *mm) {
c010949f:	55                   	push   %ebp
c01094a0:	89 e5                	mov    %esp,%ebp
    mm->mm_count -= 1;
c01094a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01094a5:	8b 40 18             	mov    0x18(%eax),%eax
c01094a8:	8d 50 ff             	lea    -0x1(%eax),%edx
c01094ab:	8b 45 08             	mov    0x8(%ebp),%eax
c01094ae:	89 50 18             	mov    %edx,0x18(%eax)
    return mm->mm_count;
c01094b1:	8b 45 08             	mov    0x8(%ebp),%eax
c01094b4:	8b 40 18             	mov    0x18(%eax),%eax
}
c01094b7:	5d                   	pop    %ebp
c01094b8:	c3                   	ret    

c01094b9 <lock_mm>:

static inline void
lock_mm(struct mm_struct *mm) {
c01094b9:	55                   	push   %ebp
c01094ba:	89 e5                	mov    %esp,%ebp
c01094bc:	83 ec 18             	sub    $0x18,%esp
    if (mm != NULL) {
c01094bf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01094c3:	74 0e                	je     c01094d3 <lock_mm+0x1a>
        lock(&(mm->mm_lock));
c01094c5:	8b 45 08             	mov    0x8(%ebp),%eax
c01094c8:	83 c0 1c             	add    $0x1c,%eax
c01094cb:	89 04 24             	mov    %eax,(%esp)
c01094ce:	e8 4c fe ff ff       	call   c010931f <lock>
    }
}
c01094d3:	c9                   	leave  
c01094d4:	c3                   	ret    

c01094d5 <unlock_mm>:

static inline void
unlock_mm(struct mm_struct *mm) {
c01094d5:	55                   	push   %ebp
c01094d6:	89 e5                	mov    %esp,%ebp
c01094d8:	83 ec 18             	sub    $0x18,%esp
    if (mm != NULL) {
c01094db:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01094df:	74 0e                	je     c01094ef <unlock_mm+0x1a>
        unlock(&(mm->mm_lock));
c01094e1:	8b 45 08             	mov    0x8(%ebp),%eax
c01094e4:	83 c0 1c             	add    $0x1c,%eax
c01094e7:	89 04 24             	mov    %eax,(%esp)
c01094ea:	e8 4e fe ff ff       	call   c010933d <unlock>
    }
}
c01094ef:	c9                   	leave  
c01094f0:	c3                   	ret    

c01094f1 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
c01094f1:	55                   	push   %ebp
c01094f2:	89 e5                	mov    %esp,%ebp
c01094f4:	83 ec 28             	sub    $0x28,%esp
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
c01094f7:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
c01094fe:	e8 d1 bd ff ff       	call   c01052d4 <kmalloc>
c0109503:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (proc != NULL) {
c0109506:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010950a:	0f 84 4c 01 00 00    	je     c010965c <alloc_proc+0x16b>
     *     int time_slice;                             // time slice for occupying the CPU
     *     skew_heap_entry_t lab6_run_pool;            // FOR LAB6 ONLY: the entry in the run pool
     *     uint32_t lab6_stride;                       // FOR LAB6 ONLY: the current stride of the process
     *     uint32_t lab6_priority;                     // FOR LAB6 ONLY: the priority of process, set by lab6_set_priority(uint32_t)
     */
        proc->state = PROC_UNINIT;//设置进程为未初始化状态
c0109510:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109513:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        proc->pid = -1; //未初始化的的进程id为-1
c0109519:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010951c:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
        proc->runs = 0;//初始化时间片
c0109523:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109526:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        proc->kstack = 0; //内存栈的地址
c010952d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109530:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        proc->need_resched = 0;//不需要调度
c0109537:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010953a:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        proc->parent = NULL;  //父节点null
c0109541:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109544:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        proc->mm = NULL;      //内核线程常驻内存
c010954b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010954e:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
        memset(&(proc->context), 0, sizeof(struct context));//上下文初始化0
c0109555:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109558:	83 c0 1c             	add    $0x1c,%eax
c010955b:	c7 44 24 08 20 00 00 	movl   $0x20,0x8(%esp)
c0109562:	00 
c0109563:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010956a:	00 
c010956b:	89 04 24             	mov    %eax,(%esp)
c010956e:	e8 bf 24 00 00       	call   c010ba32 <memset>
        proc->tf = NULL; //中断帧指针null
c0109573:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109576:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
        proc->cr3 = boot_cr3;//页目录设为内核页目录表的基址
c010957d:	8b 15 74 31 1b c0    	mov    0xc01b3174,%edx
c0109583:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109586:	89 50 40             	mov    %edx,0x40(%eax)
        proc->flags = 0;//标志位0
c0109589:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010958c:	c7 40 44 00 00 00 00 	movl   $0x0,0x44(%eax)
        memset(proc->name, 0, PROC_NAME_LEN);//进程名设为0
c0109593:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109596:	83 c0 48             	add    $0x48,%eax
c0109599:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c01095a0:	00 
c01095a1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01095a8:	00 
c01095a9:	89 04 24             	mov    %eax,(%esp)
c01095ac:	e8 81 24 00 00       	call   c010ba32 <memset>
        proc->wait_state = 0;//初始化进程等待状态
c01095b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095b4:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%eax)
        proc->cptr = proc->optr = proc->yptr = NULL;//进程相关指针初始化:孩子/旧兄弟/新兄弟
c01095bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095be:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
c01095c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095c8:	8b 50 74             	mov    0x74(%eax),%edx
c01095cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095ce:	89 50 78             	mov    %edx,0x78(%eax)
c01095d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095d4:	8b 50 78             	mov    0x78(%eax),%edx
c01095d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095da:	89 50 70             	mov    %edx,0x70(%eax)
        proc->rq = NULL; //初始化运行队列为空
c01095dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095e0:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
        list_init(&(proc->run_link)); 
c01095e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095ea:	83 e8 80             	sub    $0xffffff80,%eax
c01095ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
    elm->prev = elm->next = elm;
c01095f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01095f3:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01095f6:	89 50 04             	mov    %edx,0x4(%eax)
c01095f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01095fc:	8b 50 04             	mov    0x4(%eax),%edx
c01095ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109602:	89 10                	mov    %edx,(%eax)
        proc->time_slice = 0; //初始化时间片
c0109604:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109607:	c7 80 88 00 00 00 00 	movl   $0x0,0x88(%eax)
c010960e:	00 00 00 
        //初始化指针为空
        proc->lab6_run_pool.left = proc->lab6_run_pool.right = proc->lab6_run_pool.parent = NULL;
c0109611:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109614:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
c010961b:	00 00 00 
c010961e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109621:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
c0109627:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010962a:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
c0109630:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109633:	8b 90 94 00 00 00    	mov    0x94(%eax),%edx
c0109639:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010963c:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
        proc->lab6_stride = 0;    //设置步长为0
c0109642:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109645:	c7 80 98 00 00 00 00 	movl   $0x0,0x98(%eax)
c010964c:	00 00 00 
        proc->lab6_priority = 0;  //设置优先级为0
c010964f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109652:	c7 80 9c 00 00 00 00 	movl   $0x0,0x9c(%eax)
c0109659:	00 00 00 
    }
    return proc;
c010965c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010965f:	c9                   	leave  
c0109660:	c3                   	ret    

c0109661 <set_proc_name>:

// set_proc_name - set the name of proc
char *
set_proc_name(struct proc_struct *proc, const char *name) {
c0109661:	55                   	push   %ebp
c0109662:	89 e5                	mov    %esp,%ebp
c0109664:	83 ec 18             	sub    $0x18,%esp
    memset(proc->name, 0, sizeof(proc->name));
c0109667:	8b 45 08             	mov    0x8(%ebp),%eax
c010966a:	83 c0 48             	add    $0x48,%eax
c010966d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c0109674:	00 
c0109675:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010967c:	00 
c010967d:	89 04 24             	mov    %eax,(%esp)
c0109680:	e8 ad 23 00 00       	call   c010ba32 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
c0109685:	8b 45 08             	mov    0x8(%ebp),%eax
c0109688:	8d 50 48             	lea    0x48(%eax),%edx
c010968b:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c0109692:	00 
c0109693:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109696:	89 44 24 04          	mov    %eax,0x4(%esp)
c010969a:	89 14 24             	mov    %edx,(%esp)
c010969d:	e8 72 24 00 00       	call   c010bb14 <memcpy>
}
c01096a2:	c9                   	leave  
c01096a3:	c3                   	ret    

c01096a4 <get_proc_name>:

// get_proc_name - get the name of proc
char *
get_proc_name(struct proc_struct *proc) {
c01096a4:	55                   	push   %ebp
c01096a5:	89 e5                	mov    %esp,%ebp
c01096a7:	83 ec 18             	sub    $0x18,%esp
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
c01096aa:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c01096b1:	00 
c01096b2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01096b9:	00 
c01096ba:	c7 04 24 44 30 1b c0 	movl   $0xc01b3044,(%esp)
c01096c1:	e8 6c 23 00 00       	call   c010ba32 <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
c01096c6:	8b 45 08             	mov    0x8(%ebp),%eax
c01096c9:	83 c0 48             	add    $0x48,%eax
c01096cc:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c01096d3:	00 
c01096d4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01096d8:	c7 04 24 44 30 1b c0 	movl   $0xc01b3044,(%esp)
c01096df:	e8 30 24 00 00       	call   c010bb14 <memcpy>
}
c01096e4:	c9                   	leave  
c01096e5:	c3                   	ret    

c01096e6 <set_links>:

// set_links - set the relation links of process
static void
set_links(struct proc_struct *proc) {
c01096e6:	55                   	push   %ebp
c01096e7:	89 e5                	mov    %esp,%ebp
c01096e9:	83 ec 20             	sub    $0x20,%esp
    list_add(&proc_list, &(proc->list_link));
c01096ec:	8b 45 08             	mov    0x8(%ebp),%eax
c01096ef:	83 c0 58             	add    $0x58,%eax
c01096f2:	c7 45 fc 7c 31 1b c0 	movl   $0xc01b317c,-0x4(%ebp)
c01096f9:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01096fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01096ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109702:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109705:	89 45 f0             	mov    %eax,-0x10(%ebp)
    __list_add(elm, listelm, listelm->next);
c0109708:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010970b:	8b 40 04             	mov    0x4(%eax),%eax
c010970e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109711:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0109714:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109717:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010971a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    prev->next = next->prev = elm;
c010971d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109720:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109723:	89 10                	mov    %edx,(%eax)
c0109725:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109728:	8b 10                	mov    (%eax),%edx
c010972a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010972d:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0109730:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109733:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0109736:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0109739:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010973c:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010973f:	89 10                	mov    %edx,(%eax)
    proc->yptr = NULL;
c0109741:	8b 45 08             	mov    0x8(%ebp),%eax
c0109744:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
    if ((proc->optr = proc->parent->cptr) != NULL) {
c010974b:	8b 45 08             	mov    0x8(%ebp),%eax
c010974e:	8b 40 14             	mov    0x14(%eax),%eax
c0109751:	8b 50 70             	mov    0x70(%eax),%edx
c0109754:	8b 45 08             	mov    0x8(%ebp),%eax
c0109757:	89 50 78             	mov    %edx,0x78(%eax)
c010975a:	8b 45 08             	mov    0x8(%ebp),%eax
c010975d:	8b 40 78             	mov    0x78(%eax),%eax
c0109760:	85 c0                	test   %eax,%eax
c0109762:	74 0c                	je     c0109770 <set_links+0x8a>
        proc->optr->yptr = proc;
c0109764:	8b 45 08             	mov    0x8(%ebp),%eax
c0109767:	8b 40 78             	mov    0x78(%eax),%eax
c010976a:	8b 55 08             	mov    0x8(%ebp),%edx
c010976d:	89 50 74             	mov    %edx,0x74(%eax)
    }
    proc->parent->cptr = proc;
c0109770:	8b 45 08             	mov    0x8(%ebp),%eax
c0109773:	8b 40 14             	mov    0x14(%eax),%eax
c0109776:	8b 55 08             	mov    0x8(%ebp),%edx
c0109779:	89 50 70             	mov    %edx,0x70(%eax)
    nr_process ++;
c010977c:	a1 40 30 1b c0       	mov    0xc01b3040,%eax
c0109781:	83 c0 01             	add    $0x1,%eax
c0109784:	a3 40 30 1b c0       	mov    %eax,0xc01b3040
}
c0109789:	c9                   	leave  
c010978a:	c3                   	ret    

c010978b <remove_links>:

// remove_links - clean the relation links of process
static void
remove_links(struct proc_struct *proc) {
c010978b:	55                   	push   %ebp
c010978c:	89 e5                	mov    %esp,%ebp
c010978e:	83 ec 10             	sub    $0x10,%esp
    list_del(&(proc->list_link));
c0109791:	8b 45 08             	mov    0x8(%ebp),%eax
c0109794:	83 c0 58             	add    $0x58,%eax
c0109797:	89 45 fc             	mov    %eax,-0x4(%ebp)
    __list_del(listelm->prev, listelm->next);
c010979a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010979d:	8b 40 04             	mov    0x4(%eax),%eax
c01097a0:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01097a3:	8b 12                	mov    (%edx),%edx
c01097a5:	89 55 f8             	mov    %edx,-0x8(%ebp)
c01097a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    prev->next = next;
c01097ab:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01097ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01097b1:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01097b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01097b7:	8b 55 f8             	mov    -0x8(%ebp),%edx
c01097ba:	89 10                	mov    %edx,(%eax)
    if (proc->optr != NULL) {
c01097bc:	8b 45 08             	mov    0x8(%ebp),%eax
c01097bf:	8b 40 78             	mov    0x78(%eax),%eax
c01097c2:	85 c0                	test   %eax,%eax
c01097c4:	74 0f                	je     c01097d5 <remove_links+0x4a>
        proc->optr->yptr = proc->yptr;
c01097c6:	8b 45 08             	mov    0x8(%ebp),%eax
c01097c9:	8b 40 78             	mov    0x78(%eax),%eax
c01097cc:	8b 55 08             	mov    0x8(%ebp),%edx
c01097cf:	8b 52 74             	mov    0x74(%edx),%edx
c01097d2:	89 50 74             	mov    %edx,0x74(%eax)
    }
    if (proc->yptr != NULL) {
c01097d5:	8b 45 08             	mov    0x8(%ebp),%eax
c01097d8:	8b 40 74             	mov    0x74(%eax),%eax
c01097db:	85 c0                	test   %eax,%eax
c01097dd:	74 11                	je     c01097f0 <remove_links+0x65>
        proc->yptr->optr = proc->optr;
c01097df:	8b 45 08             	mov    0x8(%ebp),%eax
c01097e2:	8b 40 74             	mov    0x74(%eax),%eax
c01097e5:	8b 55 08             	mov    0x8(%ebp),%edx
c01097e8:	8b 52 78             	mov    0x78(%edx),%edx
c01097eb:	89 50 78             	mov    %edx,0x78(%eax)
c01097ee:	eb 0f                	jmp    c01097ff <remove_links+0x74>
    }
    else {
       proc->parent->cptr = proc->optr;
c01097f0:	8b 45 08             	mov    0x8(%ebp),%eax
c01097f3:	8b 40 14             	mov    0x14(%eax),%eax
c01097f6:	8b 55 08             	mov    0x8(%ebp),%edx
c01097f9:	8b 52 78             	mov    0x78(%edx),%edx
c01097fc:	89 50 70             	mov    %edx,0x70(%eax)
    }
    nr_process --;
c01097ff:	a1 40 30 1b c0       	mov    0xc01b3040,%eax
c0109804:	83 e8 01             	sub    $0x1,%eax
c0109807:	a3 40 30 1b c0       	mov    %eax,0xc01b3040
}
c010980c:	c9                   	leave  
c010980d:	c3                   	ret    

c010980e <get_pid>:

// get_pid - alloc a unique pid for process
static int
get_pid(void) {
c010980e:	55                   	push   %ebp
c010980f:	89 e5                	mov    %esp,%ebp
c0109811:	83 ec 10             	sub    $0x10,%esp
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
c0109814:	c7 45 f8 7c 31 1b c0 	movl   $0xc01b317c,-0x8(%ebp)
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++ last_pid >= MAX_PID) {
c010981b:	a1 78 ca 12 c0       	mov    0xc012ca78,%eax
c0109820:	83 c0 01             	add    $0x1,%eax
c0109823:	a3 78 ca 12 c0       	mov    %eax,0xc012ca78
c0109828:	a1 78 ca 12 c0       	mov    0xc012ca78,%eax
c010982d:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c0109832:	7e 0c                	jle    c0109840 <get_pid+0x32>
        last_pid = 1;
c0109834:	c7 05 78 ca 12 c0 01 	movl   $0x1,0xc012ca78
c010983b:	00 00 00 
        goto inside;
c010983e:	eb 13                	jmp    c0109853 <get_pid+0x45>
    }
    if (last_pid >= next_safe) {
c0109840:	8b 15 78 ca 12 c0    	mov    0xc012ca78,%edx
c0109846:	a1 7c ca 12 c0       	mov    0xc012ca7c,%eax
c010984b:	39 c2                	cmp    %eax,%edx
c010984d:	0f 8c ac 00 00 00    	jl     c01098ff <get_pid+0xf1>
    inside:
        next_safe = MAX_PID;
c0109853:	c7 05 7c ca 12 c0 00 	movl   $0x2000,0xc012ca7c
c010985a:	20 00 00 
    repeat:
        le = list;
c010985d:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109860:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while ((le = list_next(le)) != list) {
c0109863:	eb 7f                	jmp    c01098e4 <get_pid+0xd6>
            proc = le2proc(le, list_link);
c0109865:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109868:	83 e8 58             	sub    $0x58,%eax
c010986b:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (proc->pid == last_pid) {
c010986e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109871:	8b 50 04             	mov    0x4(%eax),%edx
c0109874:	a1 78 ca 12 c0       	mov    0xc012ca78,%eax
c0109879:	39 c2                	cmp    %eax,%edx
c010987b:	75 3e                	jne    c01098bb <get_pid+0xad>
                if (++ last_pid >= next_safe) {
c010987d:	a1 78 ca 12 c0       	mov    0xc012ca78,%eax
c0109882:	83 c0 01             	add    $0x1,%eax
c0109885:	a3 78 ca 12 c0       	mov    %eax,0xc012ca78
c010988a:	8b 15 78 ca 12 c0    	mov    0xc012ca78,%edx
c0109890:	a1 7c ca 12 c0       	mov    0xc012ca7c,%eax
c0109895:	39 c2                	cmp    %eax,%edx
c0109897:	7c 4b                	jl     c01098e4 <get_pid+0xd6>
                    if (last_pid >= MAX_PID) {
c0109899:	a1 78 ca 12 c0       	mov    0xc012ca78,%eax
c010989e:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c01098a3:	7e 0a                	jle    c01098af <get_pid+0xa1>
                        last_pid = 1;
c01098a5:	c7 05 78 ca 12 c0 01 	movl   $0x1,0xc012ca78
c01098ac:	00 00 00 
                    }
                    next_safe = MAX_PID;
c01098af:	c7 05 7c ca 12 c0 00 	movl   $0x2000,0xc012ca7c
c01098b6:	20 00 00 
                    goto repeat;
c01098b9:	eb a2                	jmp    c010985d <get_pid+0x4f>
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {
c01098bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01098be:	8b 50 04             	mov    0x4(%eax),%edx
c01098c1:	a1 78 ca 12 c0       	mov    0xc012ca78,%eax
c01098c6:	39 c2                	cmp    %eax,%edx
c01098c8:	7e 1a                	jle    c01098e4 <get_pid+0xd6>
c01098ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01098cd:	8b 50 04             	mov    0x4(%eax),%edx
c01098d0:	a1 7c ca 12 c0       	mov    0xc012ca7c,%eax
c01098d5:	39 c2                	cmp    %eax,%edx
c01098d7:	7d 0b                	jge    c01098e4 <get_pid+0xd6>
                next_safe = proc->pid;
c01098d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01098dc:	8b 40 04             	mov    0x4(%eax),%eax
c01098df:	a3 7c ca 12 c0       	mov    %eax,0xc012ca7c
c01098e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01098e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return listelm->next;
c01098ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01098ed:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list) {
c01098f0:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01098f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01098f6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01098f9:	0f 85 66 ff ff ff    	jne    c0109865 <get_pid+0x57>
            }
        }
    }
    return last_pid;
c01098ff:	a1 78 ca 12 c0       	mov    0xc012ca78,%eax
}
c0109904:	c9                   	leave  
c0109905:	c3                   	ret    

c0109906 <proc_run>:

// proc_run - make process "proc" running on cpu
// NOTE: before call switch_to, should load  base addr of "proc"'s new PDT
void
proc_run(struct proc_struct *proc) {
c0109906:	55                   	push   %ebp
c0109907:	89 e5                	mov    %esp,%ebp
c0109909:	83 ec 28             	sub    $0x28,%esp
    if (proc != current) {
c010990c:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c0109911:	39 45 08             	cmp    %eax,0x8(%ebp)
c0109914:	74 63                	je     c0109979 <proc_run+0x73>
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
c0109916:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010991b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010991e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109921:	89 45 f0             	mov    %eax,-0x10(%ebp)
        local_intr_save(intr_flag);
c0109924:	e8 96 f9 ff ff       	call   c01092bf <__intr_save>
c0109929:	89 45 ec             	mov    %eax,-0x14(%ebp)
        {
            current = proc;
c010992c:	8b 45 08             	mov    0x8(%ebp),%eax
c010992f:	a3 28 10 1b c0       	mov    %eax,0xc01b1028
            load_esp0(next->kstack + KSTACKSIZE);
c0109934:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109937:	8b 40 0c             	mov    0xc(%eax),%eax
c010993a:	05 00 20 00 00       	add    $0x2000,%eax
c010993f:	89 04 24             	mov    %eax,(%esp)
c0109942:	e8 24 da ff ff       	call   c010736b <load_esp0>
            lcr3(next->cr3);
c0109947:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010994a:	8b 40 40             	mov    0x40(%eax),%eax
c010994d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c0109950:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109953:	0f 22 d8             	mov    %eax,%cr3
            switch_to(&(prev->context), &(next->context));
c0109956:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109959:	8d 50 1c             	lea    0x1c(%eax),%edx
c010995c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010995f:	83 c0 1c             	add    $0x1c,%eax
c0109962:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109966:	89 04 24             	mov    %eax,(%esp)
c0109969:	e8 da f8 ff ff       	call   c0109248 <switch_to>
        }
        local_intr_restore(intr_flag);
c010996e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109971:	89 04 24             	mov    %eax,(%esp)
c0109974:	e8 70 f9 ff ff       	call   c01092e9 <__intr_restore>
    }
}
c0109979:	c9                   	leave  
c010997a:	c3                   	ret    

c010997b <forkret>:

// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
c010997b:	55                   	push   %ebp
c010997c:	89 e5                	mov    %esp,%ebp
c010997e:	83 ec 18             	sub    $0x18,%esp
    forkrets(current->tf);
c0109981:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c0109986:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109989:	89 04 24             	mov    %eax,(%esp)
c010998c:	e8 9c 9b ff ff       	call   c010352d <forkrets>
}
c0109991:	c9                   	leave  
c0109992:	c3                   	ret    

c0109993 <hash_proc>:

// hash_proc - add proc into proc hash_list
static void
hash_proc(struct proc_struct *proc) {
c0109993:	55                   	push   %ebp
c0109994:	89 e5                	mov    %esp,%ebp
c0109996:	53                   	push   %ebx
c0109997:	83 ec 34             	sub    $0x34,%esp
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
c010999a:	8b 45 08             	mov    0x8(%ebp),%eax
c010999d:	8d 58 60             	lea    0x60(%eax),%ebx
c01099a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01099a3:	8b 40 04             	mov    0x4(%eax),%eax
c01099a6:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c01099ad:	00 
c01099ae:	89 04 24             	mov    %eax,(%esp)
c01099b1:	e8 86 28 00 00       	call   c010c23c <hash32>
c01099b6:	c1 e0 03             	shl    $0x3,%eax
c01099b9:	05 40 10 1b c0       	add    $0xc01b1040,%eax
c01099be:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01099c1:	89 5d f0             	mov    %ebx,-0x10(%ebp)
c01099c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01099c7:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01099ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01099cd:	89 45 e8             	mov    %eax,-0x18(%ebp)
    __list_add(elm, listelm, listelm->next);
c01099d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01099d3:	8b 40 04             	mov    0x4(%eax),%eax
c01099d6:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01099d9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c01099dc:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01099df:	89 55 e0             	mov    %edx,-0x20(%ebp)
c01099e2:	89 45 dc             	mov    %eax,-0x24(%ebp)
    prev->next = next->prev = elm;
c01099e5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01099e8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01099eb:	89 10                	mov    %edx,(%eax)
c01099ed:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01099f0:	8b 10                	mov    (%eax),%edx
c01099f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01099f5:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01099f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01099fb:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01099fe:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0109a01:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109a04:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0109a07:	89 10                	mov    %edx,(%eax)
}
c0109a09:	83 c4 34             	add    $0x34,%esp
c0109a0c:	5b                   	pop    %ebx
c0109a0d:	5d                   	pop    %ebp
c0109a0e:	c3                   	ret    

c0109a0f <unhash_proc>:

// unhash_proc - delete proc from proc hash_list
static void
unhash_proc(struct proc_struct *proc) {
c0109a0f:	55                   	push   %ebp
c0109a10:	89 e5                	mov    %esp,%ebp
c0109a12:	83 ec 10             	sub    $0x10,%esp
    list_del(&(proc->hash_link));
c0109a15:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a18:	83 c0 60             	add    $0x60,%eax
c0109a1b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    __list_del(listelm->prev, listelm->next);
c0109a1e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109a21:	8b 40 04             	mov    0x4(%eax),%eax
c0109a24:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0109a27:	8b 12                	mov    (%edx),%edx
c0109a29:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0109a2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    prev->next = next;
c0109a2f:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109a32:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109a35:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0109a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109a3b:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0109a3e:	89 10                	mov    %edx,(%eax)
}
c0109a40:	c9                   	leave  
c0109a41:	c3                   	ret    

c0109a42 <find_proc>:

// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
c0109a42:	55                   	push   %ebp
c0109a43:	89 e5                	mov    %esp,%ebp
c0109a45:	83 ec 28             	sub    $0x28,%esp
    if (0 < pid && pid < MAX_PID) {
c0109a48:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109a4c:	7e 5f                	jle    c0109aad <find_proc+0x6b>
c0109a4e:	81 7d 08 ff 1f 00 00 	cmpl   $0x1fff,0x8(%ebp)
c0109a55:	7f 56                	jg     c0109aad <find_proc+0x6b>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
c0109a57:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a5a:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c0109a61:	00 
c0109a62:	89 04 24             	mov    %eax,(%esp)
c0109a65:	e8 d2 27 00 00       	call   c010c23c <hash32>
c0109a6a:	c1 e0 03             	shl    $0x3,%eax
c0109a6d:	05 40 10 1b c0       	add    $0xc01b1040,%eax
c0109a72:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109a75:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109a78:	89 45 f4             	mov    %eax,-0xc(%ebp)
        while ((le = list_next(le)) != list) {
c0109a7b:	eb 19                	jmp    c0109a96 <find_proc+0x54>
            struct proc_struct *proc = le2proc(le, hash_link);
c0109a7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109a80:	83 e8 60             	sub    $0x60,%eax
c0109a83:	89 45 ec             	mov    %eax,-0x14(%ebp)
            if (proc->pid == pid) {
c0109a86:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109a89:	8b 40 04             	mov    0x4(%eax),%eax
c0109a8c:	3b 45 08             	cmp    0x8(%ebp),%eax
c0109a8f:	75 05                	jne    c0109a96 <find_proc+0x54>
                return proc;
c0109a91:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109a94:	eb 1c                	jmp    c0109ab2 <find_proc+0x70>
c0109a96:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109a99:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return listelm->next;
c0109a9c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109a9f:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list) {
c0109aa2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109aa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109aa8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0109aab:	75 d0                	jne    c0109a7d <find_proc+0x3b>
            }
        }
    }
    return NULL;
c0109aad:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109ab2:	c9                   	leave  
c0109ab3:	c3                   	ret    

c0109ab4 <kernel_thread>:

// kernel_thread - create a kernel thread using "fn" function
// NOTE: the contents of temp trapframe tf will be copied to 
//       proc->tf in do_fork-->copy_thread function
int
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
c0109ab4:	55                   	push   %ebp
c0109ab5:	89 e5                	mov    %esp,%ebp
c0109ab7:	83 ec 68             	sub    $0x68,%esp
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
c0109aba:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
c0109ac1:	00 
c0109ac2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109ac9:	00 
c0109aca:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0109acd:	89 04 24             	mov    %eax,(%esp)
c0109ad0:	e8 5d 1f 00 00       	call   c010ba32 <memset>
    tf.tf_cs = KERNEL_CS;
c0109ad5:	66 c7 45 e8 08 00    	movw   $0x8,-0x18(%ebp)
    tf.tf_ds = tf.tf_es = tf.tf_ss = KERNEL_DS;
c0109adb:	66 c7 45 f4 10 00    	movw   $0x10,-0xc(%ebp)
c0109ae1:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0109ae5:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
c0109ae9:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
c0109aed:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
    tf.tf_regs.reg_ebx = (uint32_t)fn;
c0109af1:	8b 45 08             	mov    0x8(%ebp),%eax
c0109af4:	89 45 bc             	mov    %eax,-0x44(%ebp)
    tf.tf_regs.reg_edx = (uint32_t)arg;
c0109af7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109afa:	89 45 c0             	mov    %eax,-0x40(%ebp)
    tf.tf_eip = (uint32_t)kernel_thread_entry;
c0109afd:	b8 3f 92 10 c0       	mov    $0xc010923f,%eax
c0109b02:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
c0109b05:	8b 45 10             	mov    0x10(%ebp),%eax
c0109b08:	80 cc 01             	or     $0x1,%ah
c0109b0b:	89 c2                	mov    %eax,%edx
c0109b0d:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0109b10:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109b14:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109b1b:	00 
c0109b1c:	89 14 24             	mov    %edx,(%esp)
c0109b1f:	e8 25 03 00 00       	call   c0109e49 <do_fork>
}
c0109b24:	c9                   	leave  
c0109b25:	c3                   	ret    

c0109b26 <setup_kstack>:

// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
static int
setup_kstack(struct proc_struct *proc) {
c0109b26:	55                   	push   %ebp
c0109b27:	89 e5                	mov    %esp,%ebp
c0109b29:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_pages(KSTACKPAGE);
c0109b2c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0109b33:	e8 81 d9 ff ff       	call   c01074b9 <alloc_pages>
c0109b38:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c0109b3b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109b3f:	74 1a                	je     c0109b5b <setup_kstack+0x35>
        proc->kstack = (uintptr_t)page2kva(page);
c0109b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109b44:	89 04 24             	mov    %eax,(%esp)
c0109b47:	e8 9b f8 ff ff       	call   c01093e7 <page2kva>
c0109b4c:	89 c2                	mov    %eax,%edx
c0109b4e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109b51:	89 50 0c             	mov    %edx,0xc(%eax)
        return 0;
c0109b54:	b8 00 00 00 00       	mov    $0x0,%eax
c0109b59:	eb 05                	jmp    c0109b60 <setup_kstack+0x3a>
    }
    return -E_NO_MEM;
c0109b5b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
c0109b60:	c9                   	leave  
c0109b61:	c3                   	ret    

c0109b62 <put_kstack>:

// put_kstack - free the memory space of process kernel stack
static void
put_kstack(struct proc_struct *proc) {
c0109b62:	55                   	push   %ebp
c0109b63:	89 e5                	mov    %esp,%ebp
c0109b65:	83 ec 18             	sub    $0x18,%esp
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
c0109b68:	8b 45 08             	mov    0x8(%ebp),%eax
c0109b6b:	8b 40 0c             	mov    0xc(%eax),%eax
c0109b6e:	89 04 24             	mov    %eax,(%esp)
c0109b71:	e8 c5 f8 ff ff       	call   c010943b <kva2page>
c0109b76:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0109b7d:	00 
c0109b7e:	89 04 24             	mov    %eax,(%esp)
c0109b81:	e8 9e d9 ff ff       	call   c0107524 <free_pages>
}
c0109b86:	c9                   	leave  
c0109b87:	c3                   	ret    

c0109b88 <setup_pgdir>:

// setup_pgdir - alloc one page as PDT
static int
setup_pgdir(struct mm_struct *mm) {
c0109b88:	55                   	push   %ebp
c0109b89:	89 e5                	mov    %esp,%ebp
c0109b8b:	83 ec 28             	sub    $0x28,%esp
    struct Page *page;
    if ((page = alloc_page()) == NULL) {
c0109b8e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0109b95:	e8 1f d9 ff ff       	call   c01074b9 <alloc_pages>
c0109b9a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109b9d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109ba1:	75 0a                	jne    c0109bad <setup_pgdir+0x25>
        return -E_NO_MEM;
c0109ba3:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0109ba8:	e9 80 00 00 00       	jmp    c0109c2d <setup_pgdir+0xa5>
    }
    pde_t *pgdir = page2kva(page);
c0109bad:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109bb0:	89 04 24             	mov    %eax,(%esp)
c0109bb3:	e8 2f f8 ff ff       	call   c01093e7 <page2kva>
c0109bb8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memcpy(pgdir, boot_pgdir, PGSIZE);
c0109bbb:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0109bc0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0109bc7:	00 
c0109bc8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109bcc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109bcf:	89 04 24             	mov    %eax,(%esp)
c0109bd2:	e8 3d 1f 00 00       	call   c010bb14 <memcpy>
    pgdir[PDX(VPT)] = PADDR(pgdir) | PTE_P | PTE_W;
c0109bd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109bda:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c0109be0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109be3:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109be6:	81 7d ec ff ff ff bf 	cmpl   $0xbfffffff,-0x14(%ebp)
c0109bed:	77 23                	ja     c0109c12 <setup_pgdir+0x8a>
c0109bef:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109bf2:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109bf6:	c7 44 24 08 fc e3 10 	movl   $0xc010e3fc,0x8(%esp)
c0109bfd:	c0 
c0109bfe:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
c0109c05:	00 
c0109c06:	c7 04 24 20 e4 10 c0 	movl   $0xc010e420,(%esp)
c0109c0d:	e8 f3 67 ff ff       	call   c0100405 <__panic>
c0109c12:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109c15:	05 00 00 00 40       	add    $0x40000000,%eax
c0109c1a:	83 c8 03             	or     $0x3,%eax
c0109c1d:	89 02                	mov    %eax,(%edx)
    mm->pgdir = pgdir;
c0109c1f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c22:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109c25:	89 50 0c             	mov    %edx,0xc(%eax)
    return 0;
c0109c28:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109c2d:	c9                   	leave  
c0109c2e:	c3                   	ret    

c0109c2f <put_pgdir>:

// put_pgdir - free the memory space of PDT
static void
put_pgdir(struct mm_struct *mm) {
c0109c2f:	55                   	push   %ebp
c0109c30:	89 e5                	mov    %esp,%ebp
c0109c32:	83 ec 18             	sub    $0x18,%esp
    free_page(kva2page(mm->pgdir));
c0109c35:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c38:	8b 40 0c             	mov    0xc(%eax),%eax
c0109c3b:	89 04 24             	mov    %eax,(%esp)
c0109c3e:	e8 f8 f7 ff ff       	call   c010943b <kva2page>
c0109c43:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0109c4a:	00 
c0109c4b:	89 04 24             	mov    %eax,(%esp)
c0109c4e:	e8 d1 d8 ff ff       	call   c0107524 <free_pages>
}
c0109c53:	c9                   	leave  
c0109c54:	c3                   	ret    

c0109c55 <copy_mm>:

// copy_mm - process "proc" duplicate OR share process "current"'s mm according clone_flags
//         - if clone_flags & CLONE_VM, then "share" ; else "duplicate"
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
c0109c55:	55                   	push   %ebp
c0109c56:	89 e5                	mov    %esp,%ebp
c0109c58:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm, *oldmm = current->mm;
c0109c5b:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c0109c60:	8b 40 18             	mov    0x18(%eax),%eax
c0109c63:	89 45 ec             	mov    %eax,-0x14(%ebp)

    /* current is a kernel thread */
    if (oldmm == NULL) {
c0109c66:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0109c6a:	75 0a                	jne    c0109c76 <copy_mm+0x21>
        return 0;
c0109c6c:	b8 00 00 00 00       	mov    $0x0,%eax
c0109c71:	e9 f9 00 00 00       	jmp    c0109d6f <copy_mm+0x11a>
    }
    if (clone_flags & CLONE_VM) {
c0109c76:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c79:	25 00 01 00 00       	and    $0x100,%eax
c0109c7e:	85 c0                	test   %eax,%eax
c0109c80:	74 08                	je     c0109c8a <copy_mm+0x35>
        mm = oldmm;
c0109c82:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109c85:	89 45 f4             	mov    %eax,-0xc(%ebp)
        goto good_mm;
c0109c88:	eb 78                	jmp    c0109d02 <copy_mm+0xad>
    }

    int ret = -E_NO_MEM;
c0109c8a:	c7 45 f0 fc ff ff ff 	movl   $0xfffffffc,-0x10(%ebp)
    if ((mm = mm_create()) == NULL) {
c0109c91:	e8 21 99 ff ff       	call   c01035b7 <mm_create>
c0109c96:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109c99:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109c9d:	75 05                	jne    c0109ca4 <copy_mm+0x4f>
        goto bad_mm;
c0109c9f:	e9 c8 00 00 00       	jmp    c0109d6c <copy_mm+0x117>
    }
    if (setup_pgdir(mm) != 0) {
c0109ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109ca7:	89 04 24             	mov    %eax,(%esp)
c0109caa:	e8 d9 fe ff ff       	call   c0109b88 <setup_pgdir>
c0109caf:	85 c0                	test   %eax,%eax
c0109cb1:	74 05                	je     c0109cb8 <copy_mm+0x63>
        goto bad_pgdir_cleanup_mm;
c0109cb3:	e9 a9 00 00 00       	jmp    c0109d61 <copy_mm+0x10c>
    }

    lock_mm(oldmm);
c0109cb8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109cbb:	89 04 24             	mov    %eax,(%esp)
c0109cbe:	e8 f6 f7 ff ff       	call   c01094b9 <lock_mm>
    {
        ret = dup_mmap(mm, oldmm);
c0109cc3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109cc6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109cca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109ccd:	89 04 24             	mov    %eax,(%esp)
c0109cd0:	e8 f9 9d ff ff       	call   c0103ace <dup_mmap>
c0109cd5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    unlock_mm(oldmm);
c0109cd8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109cdb:	89 04 24             	mov    %eax,(%esp)
c0109cde:	e8 f2 f7 ff ff       	call   c01094d5 <unlock_mm>

    if (ret != 0) {
c0109ce3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0109ce7:	74 19                	je     c0109d02 <copy_mm+0xad>
        goto bad_dup_cleanup_mmap;
c0109ce9:	90                   	nop
    mm_count_inc(mm);
    proc->mm = mm;
    proc->cr3 = PADDR(mm->pgdir);
    return 0;
bad_dup_cleanup_mmap:
    exit_mmap(mm);
c0109cea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109ced:	89 04 24             	mov    %eax,(%esp)
c0109cf0:	e8 da 9e ff ff       	call   c0103bcf <exit_mmap>
    put_pgdir(mm);
c0109cf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109cf8:	89 04 24             	mov    %eax,(%esp)
c0109cfb:	e8 2f ff ff ff       	call   c0109c2f <put_pgdir>
c0109d00:	eb 5f                	jmp    c0109d61 <copy_mm+0x10c>
    mm_count_inc(mm);
c0109d02:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109d05:	89 04 24             	mov    %eax,(%esp)
c0109d08:	e8 78 f7 ff ff       	call   c0109485 <mm_count_inc>
    proc->mm = mm;
c0109d0d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109d10:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109d13:	89 50 18             	mov    %edx,0x18(%eax)
    proc->cr3 = PADDR(mm->pgdir);
c0109d16:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109d19:	8b 40 0c             	mov    0xc(%eax),%eax
c0109d1c:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109d1f:	81 7d e8 ff ff ff bf 	cmpl   $0xbfffffff,-0x18(%ebp)
c0109d26:	77 23                	ja     c0109d4b <copy_mm+0xf6>
c0109d28:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109d2b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109d2f:	c7 44 24 08 fc e3 10 	movl   $0xc010e3fc,0x8(%esp)
c0109d36:	c0 
c0109d37:	c7 44 24 04 6e 01 00 	movl   $0x16e,0x4(%esp)
c0109d3e:	00 
c0109d3f:	c7 04 24 20 e4 10 c0 	movl   $0xc010e420,(%esp)
c0109d46:	e8 ba 66 ff ff       	call   c0100405 <__panic>
c0109d4b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109d4e:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c0109d54:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109d57:	89 50 40             	mov    %edx,0x40(%eax)
    return 0;
c0109d5a:	b8 00 00 00 00       	mov    $0x0,%eax
c0109d5f:	eb 0e                	jmp    c0109d6f <copy_mm+0x11a>
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
c0109d61:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109d64:	89 04 24             	mov    %eax,(%esp)
c0109d67:	e8 a4 9b ff ff       	call   c0103910 <mm_destroy>
bad_mm:
    return ret;
c0109d6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0109d6f:	c9                   	leave  
c0109d70:	c3                   	ret    

c0109d71 <copy_thread>:

// copy_thread - setup the trapframe on the  process's kernel stack top and
//             - setup the kernel entry point and stack of process
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) {
c0109d71:	55                   	push   %ebp
c0109d72:	89 e5                	mov    %esp,%ebp
c0109d74:	57                   	push   %edi
c0109d75:	56                   	push   %esi
c0109d76:	53                   	push   %ebx
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
c0109d77:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d7a:	8b 40 0c             	mov    0xc(%eax),%eax
c0109d7d:	05 b4 1f 00 00       	add    $0x1fb4,%eax
c0109d82:	89 c2                	mov    %eax,%edx
c0109d84:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d87:	89 50 3c             	mov    %edx,0x3c(%eax)
    *(proc->tf) = *tf;
c0109d8a:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d8d:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109d90:	8b 55 10             	mov    0x10(%ebp),%edx
c0109d93:	bb 4c 00 00 00       	mov    $0x4c,%ebx
c0109d98:	89 c1                	mov    %eax,%ecx
c0109d9a:	83 e1 01             	and    $0x1,%ecx
c0109d9d:	85 c9                	test   %ecx,%ecx
c0109d9f:	74 0e                	je     c0109daf <copy_thread+0x3e>
c0109da1:	0f b6 0a             	movzbl (%edx),%ecx
c0109da4:	88 08                	mov    %cl,(%eax)
c0109da6:	83 c0 01             	add    $0x1,%eax
c0109da9:	83 c2 01             	add    $0x1,%edx
c0109dac:	83 eb 01             	sub    $0x1,%ebx
c0109daf:	89 c1                	mov    %eax,%ecx
c0109db1:	83 e1 02             	and    $0x2,%ecx
c0109db4:	85 c9                	test   %ecx,%ecx
c0109db6:	74 0f                	je     c0109dc7 <copy_thread+0x56>
c0109db8:	0f b7 0a             	movzwl (%edx),%ecx
c0109dbb:	66 89 08             	mov    %cx,(%eax)
c0109dbe:	83 c0 02             	add    $0x2,%eax
c0109dc1:	83 c2 02             	add    $0x2,%edx
c0109dc4:	83 eb 02             	sub    $0x2,%ebx
c0109dc7:	89 d9                	mov    %ebx,%ecx
c0109dc9:	c1 e9 02             	shr    $0x2,%ecx
c0109dcc:	89 c7                	mov    %eax,%edi
c0109dce:	89 d6                	mov    %edx,%esi
c0109dd0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0109dd2:	89 f2                	mov    %esi,%edx
c0109dd4:	89 f8                	mov    %edi,%eax
c0109dd6:	b9 00 00 00 00       	mov    $0x0,%ecx
c0109ddb:	89 de                	mov    %ebx,%esi
c0109ddd:	83 e6 02             	and    $0x2,%esi
c0109de0:	85 f6                	test   %esi,%esi
c0109de2:	74 0b                	je     c0109def <copy_thread+0x7e>
c0109de4:	0f b7 34 0a          	movzwl (%edx,%ecx,1),%esi
c0109de8:	66 89 34 08          	mov    %si,(%eax,%ecx,1)
c0109dec:	83 c1 02             	add    $0x2,%ecx
c0109def:	83 e3 01             	and    $0x1,%ebx
c0109df2:	85 db                	test   %ebx,%ebx
c0109df4:	74 07                	je     c0109dfd <copy_thread+0x8c>
c0109df6:	0f b6 14 0a          	movzbl (%edx,%ecx,1),%edx
c0109dfa:	88 14 08             	mov    %dl,(%eax,%ecx,1)
    proc->tf->tf_regs.reg_eax = 0;
c0109dfd:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e00:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109e03:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    proc->tf->tf_esp = esp;
c0109e0a:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e0d:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109e10:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109e13:	89 50 44             	mov    %edx,0x44(%eax)
    proc->tf->tf_eflags |= FL_IF;
c0109e16:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e19:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109e1c:	8b 55 08             	mov    0x8(%ebp),%edx
c0109e1f:	8b 52 3c             	mov    0x3c(%edx),%edx
c0109e22:	8b 52 40             	mov    0x40(%edx),%edx
c0109e25:	80 ce 02             	or     $0x2,%dh
c0109e28:	89 50 40             	mov    %edx,0x40(%eax)

    proc->context.eip = (uintptr_t)forkret;
c0109e2b:	ba 7b 99 10 c0       	mov    $0xc010997b,%edx
c0109e30:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e33:	89 50 1c             	mov    %edx,0x1c(%eax)
    proc->context.esp = (uintptr_t)(proc->tf);
c0109e36:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e39:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109e3c:	89 c2                	mov    %eax,%edx
c0109e3e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e41:	89 50 20             	mov    %edx,0x20(%eax)
}
c0109e44:	5b                   	pop    %ebx
c0109e45:	5e                   	pop    %esi
c0109e46:	5f                   	pop    %edi
c0109e47:	5d                   	pop    %ebp
c0109e48:	c3                   	ret    

c0109e49 <do_fork>:
 * @clone_flags: used to guide how to clone the child process
 * @stack:       the parent's user stack pointer. if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child process's proc->tf
 */
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
c0109e49:	55                   	push   %ebp
c0109e4a:	89 e5                	mov    %esp,%ebp
c0109e4c:	83 ec 28             	sub    $0x28,%esp
    int ret = -E_NO_FREE_PROC;
c0109e4f:	c7 45 f4 fb ff ff ff 	movl   $0xfffffffb,-0xc(%ebp)
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
c0109e56:	a1 40 30 1b c0       	mov    0xc01b3040,%eax
c0109e5b:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c0109e60:	7e 05                	jle    c0109e67 <do_fork+0x1e>
        goto fork_out;
c0109e62:	e9 ef 00 00 00       	jmp    c0109f56 <do_fork+0x10d>
    }
    ret = -E_NO_MEM;
c0109e67:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
    *    set_links:  set the relation links of process.  ALSO SEE: remove_links:  lean the relation links of process 
    *    -------------------
	*    update step 1: set child proc's parent to current process, make sure current process's wait_state is 0
	*    update step 5: insert proc_struct into hash_list && proc_list, set the relation links of process
    */
    if ((proc = alloc_proc()) == NULL) {
c0109e6e:	e8 7e f6 ff ff       	call   c01094f1 <alloc_proc>
c0109e73:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109e76:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0109e7a:	75 05                	jne    c0109e81 <do_fork+0x38>
        goto fork_out;
c0109e7c:	e9 d5 00 00 00       	jmp    c0109f56 <do_fork+0x10d>
    }

    proc->parent = current;
c0109e81:	8b 15 28 10 1b c0    	mov    0xc01b1028,%edx
c0109e87:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109e8a:	89 50 14             	mov    %edx,0x14(%eax)
    assert(current->wait_state == 0);
c0109e8d:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c0109e92:	8b 40 6c             	mov    0x6c(%eax),%eax
c0109e95:	85 c0                	test   %eax,%eax
c0109e97:	74 24                	je     c0109ebd <do_fork+0x74>
c0109e99:	c7 44 24 0c 34 e4 10 	movl   $0xc010e434,0xc(%esp)
c0109ea0:	c0 
c0109ea1:	c7 44 24 08 4d e4 10 	movl   $0xc010e44d,0x8(%esp)
c0109ea8:	c0 
c0109ea9:	c7 44 24 04 b9 01 00 	movl   $0x1b9,0x4(%esp)
c0109eb0:	00 
c0109eb1:	c7 04 24 20 e4 10 c0 	movl   $0xc010e420,(%esp)
c0109eb8:	e8 48 65 ff ff       	call   c0100405 <__panic>

    if (setup_kstack(proc) != 0) {
c0109ebd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109ec0:	89 04 24             	mov    %eax,(%esp)
c0109ec3:	e8 5e fc ff ff       	call   c0109b26 <setup_kstack>
c0109ec8:	85 c0                	test   %eax,%eax
c0109eca:	74 05                	je     c0109ed1 <do_fork+0x88>
        goto bad_fork_cleanup_proc;
c0109ecc:	e9 8a 00 00 00       	jmp    c0109f5b <do_fork+0x112>
    }
    if (copy_mm(clone_flags, proc) != 0) {
c0109ed1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109ed4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109ed8:	8b 45 08             	mov    0x8(%ebp),%eax
c0109edb:	89 04 24             	mov    %eax,(%esp)
c0109ede:	e8 72 fd ff ff       	call   c0109c55 <copy_mm>
c0109ee3:	85 c0                	test   %eax,%eax
c0109ee5:	74 0e                	je     c0109ef5 <do_fork+0xac>
        goto bad_fork_cleanup_kstack;
c0109ee7:	90                   	nop
    ret = proc->pid;
fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
c0109ee8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109eeb:	89 04 24             	mov    %eax,(%esp)
c0109eee:	e8 6f fc ff ff       	call   c0109b62 <put_kstack>
c0109ef3:	eb 66                	jmp    c0109f5b <do_fork+0x112>
    copy_thread(proc, stack, tf);
c0109ef5:	8b 45 10             	mov    0x10(%ebp),%eax
c0109ef8:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109efc:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109eff:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109f03:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109f06:	89 04 24             	mov    %eax,(%esp)
c0109f09:	e8 63 fe ff ff       	call   c0109d71 <copy_thread>
    local_intr_save(intr_flag);
c0109f0e:	e8 ac f3 ff ff       	call   c01092bf <__intr_save>
c0109f13:	89 45 ec             	mov    %eax,-0x14(%ebp)
        proc->pid = get_pid();
c0109f16:	e8 f3 f8 ff ff       	call   c010980e <get_pid>
c0109f1b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109f1e:	89 42 04             	mov    %eax,0x4(%edx)
        hash_proc(proc);
c0109f21:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109f24:	89 04 24             	mov    %eax,(%esp)
c0109f27:	e8 67 fa ff ff       	call   c0109993 <hash_proc>
        set_links(proc);
c0109f2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109f2f:	89 04 24             	mov    %eax,(%esp)
c0109f32:	e8 af f7 ff ff       	call   c01096e6 <set_links>
    local_intr_restore(intr_flag);
c0109f37:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109f3a:	89 04 24             	mov    %eax,(%esp)
c0109f3d:	e8 a7 f3 ff ff       	call   c01092e9 <__intr_restore>
    wakeup_proc(proc);
c0109f42:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109f45:	89 04 24             	mov    %eax,(%esp)
c0109f48:	e8 ff 10 00 00       	call   c010b04c <wakeup_proc>
    ret = proc->pid;
c0109f4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109f50:	8b 40 04             	mov    0x4(%eax),%eax
c0109f53:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c0109f56:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109f59:	eb 0d                	jmp    c0109f68 <do_fork+0x11f>
bad_fork_cleanup_proc:
    kfree(proc);
c0109f5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109f5e:	89 04 24             	mov    %eax,(%esp)
c0109f61:	e8 89 b3 ff ff       	call   c01052ef <kfree>
    goto fork_out;
c0109f66:	eb ee                	jmp    c0109f56 <do_fork+0x10d>
}
c0109f68:	c9                   	leave  
c0109f69:	c3                   	ret    

c0109f6a <do_exit>:
// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int
do_exit(int error_code) {
c0109f6a:	55                   	push   %ebp
c0109f6b:	89 e5                	mov    %esp,%ebp
c0109f6d:	83 ec 28             	sub    $0x28,%esp
    if (current == idleproc) {
c0109f70:	8b 15 28 10 1b c0    	mov    0xc01b1028,%edx
c0109f76:	a1 20 10 1b c0       	mov    0xc01b1020,%eax
c0109f7b:	39 c2                	cmp    %eax,%edx
c0109f7d:	75 1c                	jne    c0109f9b <do_exit+0x31>
        panic("idleproc exit.\n");
c0109f7f:	c7 44 24 08 62 e4 10 	movl   $0xc010e462,0x8(%esp)
c0109f86:	c0 
c0109f87:	c7 44 24 04 e1 01 00 	movl   $0x1e1,0x4(%esp)
c0109f8e:	00 
c0109f8f:	c7 04 24 20 e4 10 c0 	movl   $0xc010e420,(%esp)
c0109f96:	e8 6a 64 ff ff       	call   c0100405 <__panic>
    }
    if (current == initproc) {
c0109f9b:	8b 15 28 10 1b c0    	mov    0xc01b1028,%edx
c0109fa1:	a1 24 10 1b c0       	mov    0xc01b1024,%eax
c0109fa6:	39 c2                	cmp    %eax,%edx
c0109fa8:	75 1c                	jne    c0109fc6 <do_exit+0x5c>
        panic("initproc exit.\n");
c0109faa:	c7 44 24 08 72 e4 10 	movl   $0xc010e472,0x8(%esp)
c0109fb1:	c0 
c0109fb2:	c7 44 24 04 e4 01 00 	movl   $0x1e4,0x4(%esp)
c0109fb9:	00 
c0109fba:	c7 04 24 20 e4 10 c0 	movl   $0xc010e420,(%esp)
c0109fc1:	e8 3f 64 ff ff       	call   c0100405 <__panic>
    }
    
    struct mm_struct *mm = current->mm;
c0109fc6:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c0109fcb:	8b 40 18             	mov    0x18(%eax),%eax
c0109fce:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (mm != NULL) {
c0109fd1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109fd5:	74 4a                	je     c010a021 <do_exit+0xb7>
        lcr3(boot_cr3);
c0109fd7:	a1 74 31 1b c0       	mov    0xc01b3174,%eax
c0109fdc:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109fdf:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109fe2:	0f 22 d8             	mov    %eax,%cr3
        if (mm_count_dec(mm) == 0) {
c0109fe5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109fe8:	89 04 24             	mov    %eax,(%esp)
c0109feb:	e8 af f4 ff ff       	call   c010949f <mm_count_dec>
c0109ff0:	85 c0                	test   %eax,%eax
c0109ff2:	75 21                	jne    c010a015 <do_exit+0xab>
            exit_mmap(mm);
c0109ff4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109ff7:	89 04 24             	mov    %eax,(%esp)
c0109ffa:	e8 d0 9b ff ff       	call   c0103bcf <exit_mmap>
            put_pgdir(mm);
c0109fff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a002:	89 04 24             	mov    %eax,(%esp)
c010a005:	e8 25 fc ff ff       	call   c0109c2f <put_pgdir>
            mm_destroy(mm);
c010a00a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a00d:	89 04 24             	mov    %eax,(%esp)
c010a010:	e8 fb 98 ff ff       	call   c0103910 <mm_destroy>
        }
        current->mm = NULL;
c010a015:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010a01a:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
    }
    current->state = PROC_ZOMBIE;
c010a021:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010a026:	c7 00 03 00 00 00    	movl   $0x3,(%eax)
    current->exit_code = error_code;
c010a02c:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010a031:	8b 55 08             	mov    0x8(%ebp),%edx
c010a034:	89 50 68             	mov    %edx,0x68(%eax)
    
    bool intr_flag;
    struct proc_struct *proc;
    local_intr_save(intr_flag);
c010a037:	e8 83 f2 ff ff       	call   c01092bf <__intr_save>
c010a03c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        proc = current->parent;
c010a03f:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010a044:	8b 40 14             	mov    0x14(%eax),%eax
c010a047:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (proc->wait_state == WT_CHILD) {
c010a04a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a04d:	8b 40 6c             	mov    0x6c(%eax),%eax
c010a050:	3d 01 00 00 80       	cmp    $0x80000001,%eax
c010a055:	75 10                	jne    c010a067 <do_exit+0xfd>
            wakeup_proc(proc);
c010a057:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a05a:	89 04 24             	mov    %eax,(%esp)
c010a05d:	e8 ea 0f 00 00       	call   c010b04c <wakeup_proc>
        }
        while (current->cptr != NULL) {
c010a062:	e9 8b 00 00 00       	jmp    c010a0f2 <do_exit+0x188>
c010a067:	e9 86 00 00 00       	jmp    c010a0f2 <do_exit+0x188>
            proc = current->cptr;
c010a06c:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010a071:	8b 40 70             	mov    0x70(%eax),%eax
c010a074:	89 45 ec             	mov    %eax,-0x14(%ebp)
            current->cptr = proc->optr;
c010a077:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010a07c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a07f:	8b 52 78             	mov    0x78(%edx),%edx
c010a082:	89 50 70             	mov    %edx,0x70(%eax)
    
            proc->yptr = NULL;
c010a085:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a088:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
            if ((proc->optr = initproc->cptr) != NULL) {
c010a08f:	a1 24 10 1b c0       	mov    0xc01b1024,%eax
c010a094:	8b 50 70             	mov    0x70(%eax),%edx
c010a097:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a09a:	89 50 78             	mov    %edx,0x78(%eax)
c010a09d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a0a0:	8b 40 78             	mov    0x78(%eax),%eax
c010a0a3:	85 c0                	test   %eax,%eax
c010a0a5:	74 0e                	je     c010a0b5 <do_exit+0x14b>
                initproc->cptr->yptr = proc;
c010a0a7:	a1 24 10 1b c0       	mov    0xc01b1024,%eax
c010a0ac:	8b 40 70             	mov    0x70(%eax),%eax
c010a0af:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a0b2:	89 50 74             	mov    %edx,0x74(%eax)
            }
            proc->parent = initproc;
c010a0b5:	8b 15 24 10 1b c0    	mov    0xc01b1024,%edx
c010a0bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a0be:	89 50 14             	mov    %edx,0x14(%eax)
            initproc->cptr = proc;
c010a0c1:	a1 24 10 1b c0       	mov    0xc01b1024,%eax
c010a0c6:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a0c9:	89 50 70             	mov    %edx,0x70(%eax)
            if (proc->state == PROC_ZOMBIE) {
c010a0cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a0cf:	8b 00                	mov    (%eax),%eax
c010a0d1:	83 f8 03             	cmp    $0x3,%eax
c010a0d4:	75 1c                	jne    c010a0f2 <do_exit+0x188>
                if (initproc->wait_state == WT_CHILD) {
c010a0d6:	a1 24 10 1b c0       	mov    0xc01b1024,%eax
c010a0db:	8b 40 6c             	mov    0x6c(%eax),%eax
c010a0de:	3d 01 00 00 80       	cmp    $0x80000001,%eax
c010a0e3:	75 0d                	jne    c010a0f2 <do_exit+0x188>
                    wakeup_proc(initproc);
c010a0e5:	a1 24 10 1b c0       	mov    0xc01b1024,%eax
c010a0ea:	89 04 24             	mov    %eax,(%esp)
c010a0ed:	e8 5a 0f 00 00       	call   c010b04c <wakeup_proc>
        while (current->cptr != NULL) {
c010a0f2:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010a0f7:	8b 40 70             	mov    0x70(%eax),%eax
c010a0fa:	85 c0                	test   %eax,%eax
c010a0fc:	0f 85 6a ff ff ff    	jne    c010a06c <do_exit+0x102>
                }
            }
        }
    }
    local_intr_restore(intr_flag);
c010a102:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a105:	89 04 24             	mov    %eax,(%esp)
c010a108:	e8 dc f1 ff ff       	call   c01092e9 <__intr_restore>
    
    schedule();
c010a10d:	e8 d3 0f 00 00       	call   c010b0e5 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
c010a112:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010a117:	8b 40 04             	mov    0x4(%eax),%eax
c010a11a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a11e:	c7 44 24 08 84 e4 10 	movl   $0xc010e484,0x8(%esp)
c010a125:	c0 
c010a126:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
c010a12d:	00 
c010a12e:	c7 04 24 20 e4 10 c0 	movl   $0xc010e420,(%esp)
c010a135:	e8 cb 62 ff ff       	call   c0100405 <__panic>

c010a13a <load_icode>:
/* load_icode - load the content of binary program(ELF format) as the new content of current process
 * @binary:  the memory addr of the content of binary program
 * @size:  the size of the content of binary program
 */
static int
load_icode(unsigned char *binary, size_t size) {
c010a13a:	55                   	push   %ebp
c010a13b:	89 e5                	mov    %esp,%ebp
c010a13d:	83 ec 78             	sub    $0x78,%esp
    if (current->mm != NULL) {
c010a140:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010a145:	8b 40 18             	mov    0x18(%eax),%eax
c010a148:	85 c0                	test   %eax,%eax
c010a14a:	74 1c                	je     c010a168 <load_icode+0x2e>
        panic("load_icode: current->mm must be empty.\n");
c010a14c:	c7 44 24 08 a4 e4 10 	movl   $0xc010e4a4,0x8(%esp)
c010a153:	c0 
c010a154:	c7 44 24 04 1a 02 00 	movl   $0x21a,0x4(%esp)
c010a15b:	00 
c010a15c:	c7 04 24 20 e4 10 c0 	movl   $0xc010e420,(%esp)
c010a163:	e8 9d 62 ff ff       	call   c0100405 <__panic>
    }

    int ret = -E_NO_MEM;
c010a168:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
    struct mm_struct *mm;
    //(1) create a new mm for current process
    if ((mm = mm_create()) == NULL) {
c010a16f:	e8 43 94 ff ff       	call   c01035b7 <mm_create>
c010a174:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010a177:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c010a17b:	75 06                	jne    c010a183 <load_icode+0x49>
        goto bad_mm;
c010a17d:	90                   	nop
bad_elf_cleanup_pgdir:
    put_pgdir(mm);
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
bad_mm:
    goto out;
c010a17e:	e9 ef 05 00 00       	jmp    c010a772 <load_icode+0x638>
    if (setup_pgdir(mm) != 0) {
c010a183:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a186:	89 04 24             	mov    %eax,(%esp)
c010a189:	e8 fa f9 ff ff       	call   c0109b88 <setup_pgdir>
c010a18e:	85 c0                	test   %eax,%eax
c010a190:	74 05                	je     c010a197 <load_icode+0x5d>
        goto bad_pgdir_cleanup_mm;
c010a192:	e9 f6 05 00 00       	jmp    c010a78d <load_icode+0x653>
    struct elfhdr *elf = (struct elfhdr *)binary;
c010a197:	8b 45 08             	mov    0x8(%ebp),%eax
c010a19a:	89 45 cc             	mov    %eax,-0x34(%ebp)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
c010a19d:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a1a0:	8b 50 1c             	mov    0x1c(%eax),%edx
c010a1a3:	8b 45 08             	mov    0x8(%ebp),%eax
c010a1a6:	01 d0                	add    %edx,%eax
c010a1a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (elf->e_magic != ELF_MAGIC) {
c010a1ab:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a1ae:	8b 00                	mov    (%eax),%eax
c010a1b0:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
c010a1b5:	74 0c                	je     c010a1c3 <load_icode+0x89>
        ret = -E_INVAL_ELF;
c010a1b7:	c7 45 f4 f8 ff ff ff 	movl   $0xfffffff8,-0xc(%ebp)
        goto bad_elf_cleanup_pgdir;
c010a1be:	e9 bf 05 00 00       	jmp    c010a782 <load_icode+0x648>
    struct proghdr *ph_end = ph + elf->e_phnum;
c010a1c3:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a1c6:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c010a1ca:	0f b7 c0             	movzwl %ax,%eax
c010a1cd:	c1 e0 05             	shl    $0x5,%eax
c010a1d0:	89 c2                	mov    %eax,%edx
c010a1d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a1d5:	01 d0                	add    %edx,%eax
c010a1d7:	89 45 c8             	mov    %eax,-0x38(%ebp)
    for (; ph < ph_end; ph ++) {
c010a1da:	e9 13 03 00 00       	jmp    c010a4f2 <load_icode+0x3b8>
        if (ph->p_type != ELF_PT_LOAD) {
c010a1df:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a1e2:	8b 00                	mov    (%eax),%eax
c010a1e4:	83 f8 01             	cmp    $0x1,%eax
c010a1e7:	74 05                	je     c010a1ee <load_icode+0xb4>
            continue ;
c010a1e9:	e9 00 03 00 00       	jmp    c010a4ee <load_icode+0x3b4>
        if (ph->p_filesz > ph->p_memsz) {
c010a1ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a1f1:	8b 50 10             	mov    0x10(%eax),%edx
c010a1f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a1f7:	8b 40 14             	mov    0x14(%eax),%eax
c010a1fa:	39 c2                	cmp    %eax,%edx
c010a1fc:	76 0c                	jbe    c010a20a <load_icode+0xd0>
            ret = -E_INVAL_ELF;
c010a1fe:	c7 45 f4 f8 ff ff ff 	movl   $0xfffffff8,-0xc(%ebp)
            goto bad_cleanup_mmap;
c010a205:	e9 6d 05 00 00       	jmp    c010a777 <load_icode+0x63d>
        if (ph->p_filesz == 0) {
c010a20a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a20d:	8b 40 10             	mov    0x10(%eax),%eax
c010a210:	85 c0                	test   %eax,%eax
c010a212:	75 05                	jne    c010a219 <load_icode+0xdf>
            continue ;
c010a214:	e9 d5 02 00 00       	jmp    c010a4ee <load_icode+0x3b4>
        vm_flags = 0, perm = PTE_U;
c010a219:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c010a220:	c7 45 e4 04 00 00 00 	movl   $0x4,-0x1c(%ebp)
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
c010a227:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a22a:	8b 40 18             	mov    0x18(%eax),%eax
c010a22d:	83 e0 01             	and    $0x1,%eax
c010a230:	85 c0                	test   %eax,%eax
c010a232:	74 04                	je     c010a238 <load_icode+0xfe>
c010a234:	83 4d e8 04          	orl    $0x4,-0x18(%ebp)
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
c010a238:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a23b:	8b 40 18             	mov    0x18(%eax),%eax
c010a23e:	83 e0 02             	and    $0x2,%eax
c010a241:	85 c0                	test   %eax,%eax
c010a243:	74 04                	je     c010a249 <load_icode+0x10f>
c010a245:	83 4d e8 02          	orl    $0x2,-0x18(%ebp)
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
c010a249:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a24c:	8b 40 18             	mov    0x18(%eax),%eax
c010a24f:	83 e0 04             	and    $0x4,%eax
c010a252:	85 c0                	test   %eax,%eax
c010a254:	74 04                	je     c010a25a <load_icode+0x120>
c010a256:	83 4d e8 01          	orl    $0x1,-0x18(%ebp)
        if (vm_flags & VM_WRITE) perm |= PTE_W;
c010a25a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a25d:	83 e0 02             	and    $0x2,%eax
c010a260:	85 c0                	test   %eax,%eax
c010a262:	74 04                	je     c010a268 <load_icode+0x12e>
c010a264:	83 4d e4 02          	orl    $0x2,-0x1c(%ebp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
c010a268:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a26b:	8b 50 14             	mov    0x14(%eax),%edx
c010a26e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a271:	8b 40 08             	mov    0x8(%eax),%eax
c010a274:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
c010a27b:	00 
c010a27c:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010a27f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010a283:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a287:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a28b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a28e:	89 04 24             	mov    %eax,(%esp)
c010a291:	e8 1c 97 ff ff       	call   c01039b2 <mm_map>
c010a296:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a299:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a29d:	74 05                	je     c010a2a4 <load_icode+0x16a>
            goto bad_cleanup_mmap;
c010a29f:	e9 d3 04 00 00       	jmp    c010a777 <load_icode+0x63d>
        unsigned char *from = binary + ph->p_offset;
c010a2a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a2a7:	8b 50 04             	mov    0x4(%eax),%edx
c010a2aa:	8b 45 08             	mov    0x8(%ebp),%eax
c010a2ad:	01 d0                	add    %edx,%eax
c010a2af:	89 45 e0             	mov    %eax,-0x20(%ebp)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
c010a2b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a2b5:	8b 40 08             	mov    0x8(%eax),%eax
c010a2b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010a2bb:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a2be:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c010a2c1:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010a2c4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010a2c9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        ret = -E_NO_MEM;
c010a2cc:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
        end = ph->p_va + ph->p_filesz;
c010a2d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a2d6:	8b 50 08             	mov    0x8(%eax),%edx
c010a2d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a2dc:	8b 40 10             	mov    0x10(%eax),%eax
c010a2df:	01 d0                	add    %edx,%eax
c010a2e1:	89 45 c0             	mov    %eax,-0x40(%ebp)
        while (start < end) {
c010a2e4:	e9 90 00 00 00       	jmp    c010a379 <load_icode+0x23f>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
c010a2e9:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a2ec:	8b 40 0c             	mov    0xc(%eax),%eax
c010a2ef:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010a2f2:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a2f6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010a2f9:	89 54 24 04          	mov    %edx,0x4(%esp)
c010a2fd:	89 04 24             	mov    %eax,(%esp)
c010a300:	e8 08 e0 ff ff       	call   c010830d <pgdir_alloc_page>
c010a305:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a308:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a30c:	75 05                	jne    c010a313 <load_icode+0x1d9>
                goto bad_cleanup_mmap;
c010a30e:	e9 64 04 00 00       	jmp    c010a777 <load_icode+0x63d>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
c010a313:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a316:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010a319:	29 c2                	sub    %eax,%edx
c010a31b:	89 d0                	mov    %edx,%eax
c010a31d:	89 45 bc             	mov    %eax,-0x44(%ebp)
c010a320:	b8 00 10 00 00       	mov    $0x1000,%eax
c010a325:	2b 45 bc             	sub    -0x44(%ebp),%eax
c010a328:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010a32b:	81 45 d4 00 10 00 00 	addl   $0x1000,-0x2c(%ebp)
            if (end < la) {
c010a332:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a335:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a338:	73 0d                	jae    c010a347 <load_icode+0x20d>
                size -= la - end;
c010a33a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a33d:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010a340:	29 c2                	sub    %eax,%edx
c010a342:	89 d0                	mov    %edx,%eax
c010a344:	01 45 dc             	add    %eax,-0x24(%ebp)
            memcpy(page2kva(page) + off, from, size);
c010a347:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a34a:	89 04 24             	mov    %eax,(%esp)
c010a34d:	e8 95 f0 ff ff       	call   c01093e7 <page2kva>
c010a352:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010a355:	01 c2                	add    %eax,%edx
c010a357:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a35a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a35e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010a361:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a365:	89 14 24             	mov    %edx,(%esp)
c010a368:	e8 a7 17 00 00       	call   c010bb14 <memcpy>
            start += size, from += size;
c010a36d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a370:	01 45 d8             	add    %eax,-0x28(%ebp)
c010a373:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a376:	01 45 e0             	add    %eax,-0x20(%ebp)
        while (start < end) {
c010a379:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a37c:	3b 45 c0             	cmp    -0x40(%ebp),%eax
c010a37f:	0f 82 64 ff ff ff    	jb     c010a2e9 <load_icode+0x1af>
        end = ph->p_va + ph->p_memsz;
c010a385:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a388:	8b 50 08             	mov    0x8(%eax),%edx
c010a38b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a38e:	8b 40 14             	mov    0x14(%eax),%eax
c010a391:	01 d0                	add    %edx,%eax
c010a393:	89 45 c0             	mov    %eax,-0x40(%ebp)
        if (start < la) {
c010a396:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a399:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a39c:	0f 83 b0 00 00 00    	jae    c010a452 <load_icode+0x318>
            if (start == end) {
c010a3a2:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a3a5:	3b 45 c0             	cmp    -0x40(%ebp),%eax
c010a3a8:	75 05                	jne    c010a3af <load_icode+0x275>
                continue ;
c010a3aa:	e9 3f 01 00 00       	jmp    c010a4ee <load_icode+0x3b4>
            off = start + PGSIZE - la, size = PGSIZE - off;
c010a3af:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a3b2:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010a3b5:	29 c2                	sub    %eax,%edx
c010a3b7:	89 d0                	mov    %edx,%eax
c010a3b9:	05 00 10 00 00       	add    $0x1000,%eax
c010a3be:	89 45 bc             	mov    %eax,-0x44(%ebp)
c010a3c1:	b8 00 10 00 00       	mov    $0x1000,%eax
c010a3c6:	2b 45 bc             	sub    -0x44(%ebp),%eax
c010a3c9:	89 45 dc             	mov    %eax,-0x24(%ebp)
            if (end < la) {
c010a3cc:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a3cf:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a3d2:	73 0d                	jae    c010a3e1 <load_icode+0x2a7>
                size -= la - end;
c010a3d4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a3d7:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010a3da:	29 c2                	sub    %eax,%edx
c010a3dc:	89 d0                	mov    %edx,%eax
c010a3de:	01 45 dc             	add    %eax,-0x24(%ebp)
            memset(page2kva(page) + off, 0, size);
c010a3e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a3e4:	89 04 24             	mov    %eax,(%esp)
c010a3e7:	e8 fb ef ff ff       	call   c01093e7 <page2kva>
c010a3ec:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010a3ef:	01 c2                	add    %eax,%edx
c010a3f1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a3f4:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a3f8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a3ff:	00 
c010a400:	89 14 24             	mov    %edx,(%esp)
c010a403:	e8 2a 16 00 00       	call   c010ba32 <memset>
            start += size;
c010a408:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a40b:	01 45 d8             	add    %eax,-0x28(%ebp)
            assert((end < la && start == end) || (end >= la && start == la));
c010a40e:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a411:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a414:	73 08                	jae    c010a41e <load_icode+0x2e4>
c010a416:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a419:	3b 45 c0             	cmp    -0x40(%ebp),%eax
c010a41c:	74 34                	je     c010a452 <load_icode+0x318>
c010a41e:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a421:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a424:	72 08                	jb     c010a42e <load_icode+0x2f4>
c010a426:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a429:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a42c:	74 24                	je     c010a452 <load_icode+0x318>
c010a42e:	c7 44 24 0c cc e4 10 	movl   $0xc010e4cc,0xc(%esp)
c010a435:	c0 
c010a436:	c7 44 24 08 4d e4 10 	movl   $0xc010e44d,0x8(%esp)
c010a43d:	c0 
c010a43e:	c7 44 24 04 6c 02 00 	movl   $0x26c,0x4(%esp)
c010a445:	00 
c010a446:	c7 04 24 20 e4 10 c0 	movl   $0xc010e420,(%esp)
c010a44d:	e8 b3 5f ff ff       	call   c0100405 <__panic>
        while (start < end) {
c010a452:	e9 8b 00 00 00       	jmp    c010a4e2 <load_icode+0x3a8>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
c010a457:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a45a:	8b 40 0c             	mov    0xc(%eax),%eax
c010a45d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010a460:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a464:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010a467:	89 54 24 04          	mov    %edx,0x4(%esp)
c010a46b:	89 04 24             	mov    %eax,(%esp)
c010a46e:	e8 9a de ff ff       	call   c010830d <pgdir_alloc_page>
c010a473:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a476:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a47a:	75 05                	jne    c010a481 <load_icode+0x347>
                goto bad_cleanup_mmap;
c010a47c:	e9 f6 02 00 00       	jmp    c010a777 <load_icode+0x63d>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
c010a481:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a484:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010a487:	29 c2                	sub    %eax,%edx
c010a489:	89 d0                	mov    %edx,%eax
c010a48b:	89 45 bc             	mov    %eax,-0x44(%ebp)
c010a48e:	b8 00 10 00 00       	mov    $0x1000,%eax
c010a493:	2b 45 bc             	sub    -0x44(%ebp),%eax
c010a496:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010a499:	81 45 d4 00 10 00 00 	addl   $0x1000,-0x2c(%ebp)
            if (end < la) {
c010a4a0:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a4a3:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a4a6:	73 0d                	jae    c010a4b5 <load_icode+0x37b>
                size -= la - end;
c010a4a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a4ab:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010a4ae:	29 c2                	sub    %eax,%edx
c010a4b0:	89 d0                	mov    %edx,%eax
c010a4b2:	01 45 dc             	add    %eax,-0x24(%ebp)
            memset(page2kva(page) + off, 0, size);
c010a4b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a4b8:	89 04 24             	mov    %eax,(%esp)
c010a4bb:	e8 27 ef ff ff       	call   c01093e7 <page2kva>
c010a4c0:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010a4c3:	01 c2                	add    %eax,%edx
c010a4c5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a4c8:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a4cc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a4d3:	00 
c010a4d4:	89 14 24             	mov    %edx,(%esp)
c010a4d7:	e8 56 15 00 00       	call   c010ba32 <memset>
            start += size;
c010a4dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a4df:	01 45 d8             	add    %eax,-0x28(%ebp)
        while (start < end) {
c010a4e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a4e5:	3b 45 c0             	cmp    -0x40(%ebp),%eax
c010a4e8:	0f 82 69 ff ff ff    	jb     c010a457 <load_icode+0x31d>
    for (; ph < ph_end; ph ++) {
c010a4ee:	83 45 ec 20          	addl   $0x20,-0x14(%ebp)
c010a4f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a4f5:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c010a4f8:	0f 82 e1 fc ff ff    	jb     c010a1df <load_icode+0xa5>
    vm_flags = VM_READ | VM_WRITE | VM_STACK;
c010a4fe:	c7 45 e8 0b 00 00 00 	movl   $0xb,-0x18(%ebp)
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
c010a505:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
c010a50c:	00 
c010a50d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a510:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a514:	c7 44 24 08 00 00 10 	movl   $0x100000,0x8(%esp)
c010a51b:	00 
c010a51c:	c7 44 24 04 00 00 f0 	movl   $0xaff00000,0x4(%esp)
c010a523:	af 
c010a524:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a527:	89 04 24             	mov    %eax,(%esp)
c010a52a:	e8 83 94 ff ff       	call   c01039b2 <mm_map>
c010a52f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a532:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a536:	74 05                	je     c010a53d <load_icode+0x403>
        goto bad_cleanup_mmap;
c010a538:	e9 3a 02 00 00       	jmp    c010a777 <load_icode+0x63d>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
c010a53d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a540:	8b 40 0c             	mov    0xc(%eax),%eax
c010a543:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a54a:	00 
c010a54b:	c7 44 24 04 00 f0 ff 	movl   $0xaffff000,0x4(%esp)
c010a552:	af 
c010a553:	89 04 24             	mov    %eax,(%esp)
c010a556:	e8 b2 dd ff ff       	call   c010830d <pgdir_alloc_page>
c010a55b:	85 c0                	test   %eax,%eax
c010a55d:	75 24                	jne    c010a583 <load_icode+0x449>
c010a55f:	c7 44 24 0c 08 e5 10 	movl   $0xc010e508,0xc(%esp)
c010a566:	c0 
c010a567:	c7 44 24 08 4d e4 10 	movl   $0xc010e44d,0x8(%esp)
c010a56e:	c0 
c010a56f:	c7 44 24 04 7f 02 00 	movl   $0x27f,0x4(%esp)
c010a576:	00 
c010a577:	c7 04 24 20 e4 10 c0 	movl   $0xc010e420,(%esp)
c010a57e:	e8 82 5e ff ff       	call   c0100405 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
c010a583:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a586:	8b 40 0c             	mov    0xc(%eax),%eax
c010a589:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a590:	00 
c010a591:	c7 44 24 04 00 e0 ff 	movl   $0xafffe000,0x4(%esp)
c010a598:	af 
c010a599:	89 04 24             	mov    %eax,(%esp)
c010a59c:	e8 6c dd ff ff       	call   c010830d <pgdir_alloc_page>
c010a5a1:	85 c0                	test   %eax,%eax
c010a5a3:	75 24                	jne    c010a5c9 <load_icode+0x48f>
c010a5a5:	c7 44 24 0c 4c e5 10 	movl   $0xc010e54c,0xc(%esp)
c010a5ac:	c0 
c010a5ad:	c7 44 24 08 4d e4 10 	movl   $0xc010e44d,0x8(%esp)
c010a5b4:	c0 
c010a5b5:	c7 44 24 04 80 02 00 	movl   $0x280,0x4(%esp)
c010a5bc:	00 
c010a5bd:	c7 04 24 20 e4 10 c0 	movl   $0xc010e420,(%esp)
c010a5c4:	e8 3c 5e ff ff       	call   c0100405 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
c010a5c9:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a5cc:	8b 40 0c             	mov    0xc(%eax),%eax
c010a5cf:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a5d6:	00 
c010a5d7:	c7 44 24 04 00 d0 ff 	movl   $0xafffd000,0x4(%esp)
c010a5de:	af 
c010a5df:	89 04 24             	mov    %eax,(%esp)
c010a5e2:	e8 26 dd ff ff       	call   c010830d <pgdir_alloc_page>
c010a5e7:	85 c0                	test   %eax,%eax
c010a5e9:	75 24                	jne    c010a60f <load_icode+0x4d5>
c010a5eb:	c7 44 24 0c 90 e5 10 	movl   $0xc010e590,0xc(%esp)
c010a5f2:	c0 
c010a5f3:	c7 44 24 08 4d e4 10 	movl   $0xc010e44d,0x8(%esp)
c010a5fa:	c0 
c010a5fb:	c7 44 24 04 81 02 00 	movl   $0x281,0x4(%esp)
c010a602:	00 
c010a603:	c7 04 24 20 e4 10 c0 	movl   $0xc010e420,(%esp)
c010a60a:	e8 f6 5d ff ff       	call   c0100405 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
c010a60f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a612:	8b 40 0c             	mov    0xc(%eax),%eax
c010a615:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a61c:	00 
c010a61d:	c7 44 24 04 00 c0 ff 	movl   $0xafffc000,0x4(%esp)
c010a624:	af 
c010a625:	89 04 24             	mov    %eax,(%esp)
c010a628:	e8 e0 dc ff ff       	call   c010830d <pgdir_alloc_page>
c010a62d:	85 c0                	test   %eax,%eax
c010a62f:	75 24                	jne    c010a655 <load_icode+0x51b>
c010a631:	c7 44 24 0c d4 e5 10 	movl   $0xc010e5d4,0xc(%esp)
c010a638:	c0 
c010a639:	c7 44 24 08 4d e4 10 	movl   $0xc010e44d,0x8(%esp)
c010a640:	c0 
c010a641:	c7 44 24 04 82 02 00 	movl   $0x282,0x4(%esp)
c010a648:	00 
c010a649:	c7 04 24 20 e4 10 c0 	movl   $0xc010e420,(%esp)
c010a650:	e8 b0 5d ff ff       	call   c0100405 <__panic>
    mm_count_inc(mm);
c010a655:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a658:	89 04 24             	mov    %eax,(%esp)
c010a65b:	e8 25 ee ff ff       	call   c0109485 <mm_count_inc>
    current->mm = mm;
c010a660:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010a665:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010a668:	89 50 18             	mov    %edx,0x18(%eax)
    current->cr3 = PADDR(mm->pgdir);
c010a66b:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010a670:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010a673:	8b 52 0c             	mov    0xc(%edx),%edx
c010a676:	89 55 b8             	mov    %edx,-0x48(%ebp)
c010a679:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c010a680:	77 23                	ja     c010a6a5 <load_icode+0x56b>
c010a682:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010a685:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a689:	c7 44 24 08 fc e3 10 	movl   $0xc010e3fc,0x8(%esp)
c010a690:	c0 
c010a691:	c7 44 24 04 87 02 00 	movl   $0x287,0x4(%esp)
c010a698:	00 
c010a699:	c7 04 24 20 e4 10 c0 	movl   $0xc010e420,(%esp)
c010a6a0:	e8 60 5d ff ff       	call   c0100405 <__panic>
c010a6a5:	8b 55 b8             	mov    -0x48(%ebp),%edx
c010a6a8:	81 c2 00 00 00 40    	add    $0x40000000,%edx
c010a6ae:	89 50 40             	mov    %edx,0x40(%eax)
    lcr3(PADDR(mm->pgdir));
c010a6b1:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a6b4:	8b 40 0c             	mov    0xc(%eax),%eax
c010a6b7:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c010a6ba:	81 7d b4 ff ff ff bf 	cmpl   $0xbfffffff,-0x4c(%ebp)
c010a6c1:	77 23                	ja     c010a6e6 <load_icode+0x5ac>
c010a6c3:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a6c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a6ca:	c7 44 24 08 fc e3 10 	movl   $0xc010e3fc,0x8(%esp)
c010a6d1:	c0 
c010a6d2:	c7 44 24 04 88 02 00 	movl   $0x288,0x4(%esp)
c010a6d9:	00 
c010a6da:	c7 04 24 20 e4 10 c0 	movl   $0xc010e420,(%esp)
c010a6e1:	e8 1f 5d ff ff       	call   c0100405 <__panic>
c010a6e6:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a6e9:	05 00 00 00 40       	add    $0x40000000,%eax
c010a6ee:	89 45 ac             	mov    %eax,-0x54(%ebp)
c010a6f1:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010a6f4:	0f 22 d8             	mov    %eax,%cr3
    struct trapframe *tf = current->tf;
c010a6f7:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010a6fc:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a6ff:	89 45 b0             	mov    %eax,-0x50(%ebp)
    memset(tf, 0, sizeof(struct trapframe));
c010a702:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
c010a709:	00 
c010a70a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a711:	00 
c010a712:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a715:	89 04 24             	mov    %eax,(%esp)
c010a718:	e8 15 13 00 00       	call   c010ba32 <memset>
    tf->tf_cs = USER_CS;
c010a71d:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a720:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
    tf->tf_ds = tf->tf_es = tf->tf_ss = USER_DS;
c010a726:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a729:	66 c7 40 48 23 00    	movw   $0x23,0x48(%eax)
c010a72f:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a732:	0f b7 50 48          	movzwl 0x48(%eax),%edx
c010a736:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a739:	66 89 50 28          	mov    %dx,0x28(%eax)
c010a73d:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a740:	0f b7 50 28          	movzwl 0x28(%eax),%edx
c010a744:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a747:	66 89 50 2c          	mov    %dx,0x2c(%eax)
    tf->tf_esp = USTACKTOP;
c010a74b:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a74e:	c7 40 44 00 00 00 b0 	movl   $0xb0000000,0x44(%eax)
    tf->tf_eip = elf->e_entry;
c010a755:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a758:	8b 50 18             	mov    0x18(%eax),%edx
c010a75b:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a75e:	89 50 38             	mov    %edx,0x38(%eax)
    tf->tf_eflags = FL_IF;
c010a761:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a764:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
    ret = 0;
c010a76b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    return ret;
c010a772:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a775:	eb 23                	jmp    c010a79a <load_icode+0x660>
    exit_mmap(mm);
c010a777:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a77a:	89 04 24             	mov    %eax,(%esp)
c010a77d:	e8 4d 94 ff ff       	call   c0103bcf <exit_mmap>
    put_pgdir(mm);
c010a782:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a785:	89 04 24             	mov    %eax,(%esp)
c010a788:	e8 a2 f4 ff ff       	call   c0109c2f <put_pgdir>
    mm_destroy(mm);
c010a78d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a790:	89 04 24             	mov    %eax,(%esp)
c010a793:	e8 78 91 ff ff       	call   c0103910 <mm_destroy>
    goto out;
c010a798:	eb d8                	jmp    c010a772 <load_icode+0x638>
}
c010a79a:	c9                   	leave  
c010a79b:	c3                   	ret    

c010a79c <do_execve>:

// do_execve - call exit_mmap(mm)&put_pgdir(mm) to reclaim memory space of current process
//           - call load_icode to setup new memory space accroding binary prog.
int
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
c010a79c:	55                   	push   %ebp
c010a79d:	89 e5                	mov    %esp,%ebp
c010a79f:	83 ec 38             	sub    $0x38,%esp
    struct mm_struct *mm = current->mm;
c010a7a2:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010a7a7:	8b 40 18             	mov    0x18(%eax),%eax
c010a7aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
c010a7ad:	8b 45 08             	mov    0x8(%ebp),%eax
c010a7b0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010a7b7:	00 
c010a7b8:	8b 55 0c             	mov    0xc(%ebp),%edx
c010a7bb:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a7bf:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a7c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a7c6:	89 04 24             	mov    %eax,(%esp)
c010a7c9:	e8 a5 9e ff ff       	call   c0104673 <user_mem_check>
c010a7ce:	85 c0                	test   %eax,%eax
c010a7d0:	75 0a                	jne    c010a7dc <do_execve+0x40>
        return -E_INVAL;
c010a7d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010a7d7:	e9 f4 00 00 00       	jmp    c010a8d0 <do_execve+0x134>
    }
    if (len > PROC_NAME_LEN) {
c010a7dc:	83 7d 0c 0f          	cmpl   $0xf,0xc(%ebp)
c010a7e0:	76 07                	jbe    c010a7e9 <do_execve+0x4d>
        len = PROC_NAME_LEN;
c010a7e2:	c7 45 0c 0f 00 00 00 	movl   $0xf,0xc(%ebp)
    }

    char local_name[PROC_NAME_LEN + 1];
    memset(local_name, 0, sizeof(local_name));
c010a7e9:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c010a7f0:	00 
c010a7f1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a7f8:	00 
c010a7f9:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010a7fc:	89 04 24             	mov    %eax,(%esp)
c010a7ff:	e8 2e 12 00 00       	call   c010ba32 <memset>
    memcpy(local_name, name, len);
c010a804:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a807:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a80b:	8b 45 08             	mov    0x8(%ebp),%eax
c010a80e:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a812:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010a815:	89 04 24             	mov    %eax,(%esp)
c010a818:	e8 f7 12 00 00       	call   c010bb14 <memcpy>

    if (mm != NULL) {
c010a81d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a821:	74 4a                	je     c010a86d <do_execve+0xd1>
        lcr3(boot_cr3);
c010a823:	a1 74 31 1b c0       	mov    0xc01b3174,%eax
c010a828:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010a82b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a82e:	0f 22 d8             	mov    %eax,%cr3
        if (mm_count_dec(mm) == 0) {
c010a831:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a834:	89 04 24             	mov    %eax,(%esp)
c010a837:	e8 63 ec ff ff       	call   c010949f <mm_count_dec>
c010a83c:	85 c0                	test   %eax,%eax
c010a83e:	75 21                	jne    c010a861 <do_execve+0xc5>
            exit_mmap(mm);
c010a840:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a843:	89 04 24             	mov    %eax,(%esp)
c010a846:	e8 84 93 ff ff       	call   c0103bcf <exit_mmap>
            put_pgdir(mm);
c010a84b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a84e:	89 04 24             	mov    %eax,(%esp)
c010a851:	e8 d9 f3 ff ff       	call   c0109c2f <put_pgdir>
            mm_destroy(mm);
c010a856:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a859:	89 04 24             	mov    %eax,(%esp)
c010a85c:	e8 af 90 ff ff       	call   c0103910 <mm_destroy>
        }
        current->mm = NULL;
c010a861:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010a866:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
    }
    int ret;
    if ((ret = load_icode(binary, size)) != 0) {
c010a86d:	8b 45 14             	mov    0x14(%ebp),%eax
c010a870:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a874:	8b 45 10             	mov    0x10(%ebp),%eax
c010a877:	89 04 24             	mov    %eax,(%esp)
c010a87a:	e8 bb f8 ff ff       	call   c010a13a <load_icode>
c010a87f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a882:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a886:	74 2f                	je     c010a8b7 <do_execve+0x11b>
        goto execve_exit;
c010a888:	90                   	nop
    }
    set_proc_name(current, local_name);
    return 0;

execve_exit:
    do_exit(ret);
c010a889:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a88c:	89 04 24             	mov    %eax,(%esp)
c010a88f:	e8 d6 f6 ff ff       	call   c0109f6a <do_exit>
    panic("already exit: %e.\n", ret);
c010a894:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a897:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a89b:	c7 44 24 08 17 e6 10 	movl   $0xc010e617,0x8(%esp)
c010a8a2:	c0 
c010a8a3:	c7 44 24 04 ca 02 00 	movl   $0x2ca,0x4(%esp)
c010a8aa:	00 
c010a8ab:	c7 04 24 20 e4 10 c0 	movl   $0xc010e420,(%esp)
c010a8b2:	e8 4e 5b ff ff       	call   c0100405 <__panic>
    set_proc_name(current, local_name);
c010a8b7:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010a8bc:	8d 55 dc             	lea    -0x24(%ebp),%edx
c010a8bf:	89 54 24 04          	mov    %edx,0x4(%esp)
c010a8c3:	89 04 24             	mov    %eax,(%esp)
c010a8c6:	e8 96 ed ff ff       	call   c0109661 <set_proc_name>
    return 0;
c010a8cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010a8d0:	c9                   	leave  
c010a8d1:	c3                   	ret    

c010a8d2 <do_yield>:

// do_yield - ask the scheduler to reschedule
int
do_yield(void) {
c010a8d2:	55                   	push   %ebp
c010a8d3:	89 e5                	mov    %esp,%ebp
    current->need_resched = 1;
c010a8d5:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010a8da:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    return 0;
c010a8e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010a8e6:	5d                   	pop    %ebp
c010a8e7:	c3                   	ret    

c010a8e8 <do_wait>:

// do_wait - wait one OR any children with PROC_ZOMBIE state, and free memory space of kernel stack
//         - proc struct of this child.
// NOTE: only after do_wait function, all resources of the child proces are free.
int
do_wait(int pid, int *code_store) {
c010a8e8:	55                   	push   %ebp
c010a8e9:	89 e5                	mov    %esp,%ebp
c010a8eb:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = current->mm;
c010a8ee:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010a8f3:	8b 40 18             	mov    0x18(%eax),%eax
c010a8f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (code_store != NULL) {
c010a8f9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010a8fd:	74 30                	je     c010a92f <do_wait+0x47>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
c010a8ff:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a902:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c010a909:	00 
c010a90a:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
c010a911:	00 
c010a912:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a916:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a919:	89 04 24             	mov    %eax,(%esp)
c010a91c:	e8 52 9d ff ff       	call   c0104673 <user_mem_check>
c010a921:	85 c0                	test   %eax,%eax
c010a923:	75 0a                	jne    c010a92f <do_wait+0x47>
            return -E_INVAL;
c010a925:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010a92a:	e9 4b 01 00 00       	jmp    c010aa7a <do_wait+0x192>
    }

    struct proc_struct *proc;
    bool intr_flag, haskid;
repeat:
    haskid = 0;
c010a92f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    if (pid != 0) {
c010a936:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010a93a:	74 39                	je     c010a975 <do_wait+0x8d>
        proc = find_proc(pid);
c010a93c:	8b 45 08             	mov    0x8(%ebp),%eax
c010a93f:	89 04 24             	mov    %eax,(%esp)
c010a942:	e8 fb f0 ff ff       	call   c0109a42 <find_proc>
c010a947:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (proc != NULL && proc->parent == current) {
c010a94a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a94e:	74 54                	je     c010a9a4 <do_wait+0xbc>
c010a950:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a953:	8b 50 14             	mov    0x14(%eax),%edx
c010a956:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010a95b:	39 c2                	cmp    %eax,%edx
c010a95d:	75 45                	jne    c010a9a4 <do_wait+0xbc>
            haskid = 1;
c010a95f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
            if (proc->state == PROC_ZOMBIE) {
c010a966:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a969:	8b 00                	mov    (%eax),%eax
c010a96b:	83 f8 03             	cmp    $0x3,%eax
c010a96e:	75 34                	jne    c010a9a4 <do_wait+0xbc>
                goto found;
c010a970:	e9 80 00 00 00       	jmp    c010a9f5 <do_wait+0x10d>
            }
        }
    }
    else {
        proc = current->cptr;
c010a975:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010a97a:	8b 40 70             	mov    0x70(%eax),%eax
c010a97d:	89 45 f4             	mov    %eax,-0xc(%ebp)
        for (; proc != NULL; proc = proc->optr) {
c010a980:	eb 1c                	jmp    c010a99e <do_wait+0xb6>
            haskid = 1;
c010a982:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
            if (proc->state == PROC_ZOMBIE) {
c010a989:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a98c:	8b 00                	mov    (%eax),%eax
c010a98e:	83 f8 03             	cmp    $0x3,%eax
c010a991:	75 02                	jne    c010a995 <do_wait+0xad>
                goto found;
c010a993:	eb 60                	jmp    c010a9f5 <do_wait+0x10d>
        for (; proc != NULL; proc = proc->optr) {
c010a995:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a998:	8b 40 78             	mov    0x78(%eax),%eax
c010a99b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a99e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a9a2:	75 de                	jne    c010a982 <do_wait+0x9a>
            }
        }
    }
    if (haskid) {
c010a9a4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a9a8:	74 41                	je     c010a9eb <do_wait+0x103>
        current->state = PROC_SLEEPING;
c010a9aa:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010a9af:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
        current->wait_state = WT_CHILD;
c010a9b5:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010a9ba:	c7 40 6c 01 00 00 80 	movl   $0x80000001,0x6c(%eax)
        schedule();
c010a9c1:	e8 1f 07 00 00       	call   c010b0e5 <schedule>
        if (current->flags & PF_EXITING) {
c010a9c6:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010a9cb:	8b 40 44             	mov    0x44(%eax),%eax
c010a9ce:	83 e0 01             	and    $0x1,%eax
c010a9d1:	85 c0                	test   %eax,%eax
c010a9d3:	74 11                	je     c010a9e6 <do_wait+0xfe>
            do_exit(-E_KILLED);
c010a9d5:	c7 04 24 f7 ff ff ff 	movl   $0xfffffff7,(%esp)
c010a9dc:	e8 89 f5 ff ff       	call   c0109f6a <do_exit>
        }
        goto repeat;
c010a9e1:	e9 49 ff ff ff       	jmp    c010a92f <do_wait+0x47>
c010a9e6:	e9 44 ff ff ff       	jmp    c010a92f <do_wait+0x47>
    }
    return -E_BAD_PROC;
c010a9eb:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
c010a9f0:	e9 85 00 00 00       	jmp    c010aa7a <do_wait+0x192>

found:
    if (proc == idleproc || proc == initproc) {
c010a9f5:	a1 20 10 1b c0       	mov    0xc01b1020,%eax
c010a9fa:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010a9fd:	74 0a                	je     c010aa09 <do_wait+0x121>
c010a9ff:	a1 24 10 1b c0       	mov    0xc01b1024,%eax
c010aa04:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010aa07:	75 1c                	jne    c010aa25 <do_wait+0x13d>
        panic("wait idleproc or initproc.\n");
c010aa09:	c7 44 24 08 2a e6 10 	movl   $0xc010e62a,0x8(%esp)
c010aa10:	c0 
c010aa11:	c7 44 24 04 03 03 00 	movl   $0x303,0x4(%esp)
c010aa18:	00 
c010aa19:	c7 04 24 20 e4 10 c0 	movl   $0xc010e420,(%esp)
c010aa20:	e8 e0 59 ff ff       	call   c0100405 <__panic>
    }
    if (code_store != NULL) {
c010aa25:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010aa29:	74 0b                	je     c010aa36 <do_wait+0x14e>
        *code_store = proc->exit_code;
c010aa2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa2e:	8b 50 68             	mov    0x68(%eax),%edx
c010aa31:	8b 45 0c             	mov    0xc(%ebp),%eax
c010aa34:	89 10                	mov    %edx,(%eax)
    }
    local_intr_save(intr_flag);
c010aa36:	e8 84 e8 ff ff       	call   c01092bf <__intr_save>
c010aa3b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    {
        unhash_proc(proc);
c010aa3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa41:	89 04 24             	mov    %eax,(%esp)
c010aa44:	e8 c6 ef ff ff       	call   c0109a0f <unhash_proc>
        remove_links(proc);
c010aa49:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa4c:	89 04 24             	mov    %eax,(%esp)
c010aa4f:	e8 37 ed ff ff       	call   c010978b <remove_links>
    }
    local_intr_restore(intr_flag);
c010aa54:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010aa57:	89 04 24             	mov    %eax,(%esp)
c010aa5a:	e8 8a e8 ff ff       	call   c01092e9 <__intr_restore>
    put_kstack(proc);
c010aa5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa62:	89 04 24             	mov    %eax,(%esp)
c010aa65:	e8 f8 f0 ff ff       	call   c0109b62 <put_kstack>
    kfree(proc);
c010aa6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa6d:	89 04 24             	mov    %eax,(%esp)
c010aa70:	e8 7a a8 ff ff       	call   c01052ef <kfree>
    return 0;
c010aa75:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010aa7a:	c9                   	leave  
c010aa7b:	c3                   	ret    

c010aa7c <do_kill>:

// do_kill - kill process with pid by set this process's flags with PF_EXITING
int
do_kill(int pid) {
c010aa7c:	55                   	push   %ebp
c010aa7d:	89 e5                	mov    %esp,%ebp
c010aa7f:	83 ec 28             	sub    $0x28,%esp
    struct proc_struct *proc;
    if ((proc = find_proc(pid)) != NULL) {
c010aa82:	8b 45 08             	mov    0x8(%ebp),%eax
c010aa85:	89 04 24             	mov    %eax,(%esp)
c010aa88:	e8 b5 ef ff ff       	call   c0109a42 <find_proc>
c010aa8d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010aa90:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010aa94:	74 41                	je     c010aad7 <do_kill+0x5b>
        if (!(proc->flags & PF_EXITING)) {
c010aa96:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa99:	8b 40 44             	mov    0x44(%eax),%eax
c010aa9c:	83 e0 01             	and    $0x1,%eax
c010aa9f:	85 c0                	test   %eax,%eax
c010aaa1:	75 2d                	jne    c010aad0 <do_kill+0x54>
            proc->flags |= PF_EXITING;
c010aaa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aaa6:	8b 40 44             	mov    0x44(%eax),%eax
c010aaa9:	83 c8 01             	or     $0x1,%eax
c010aaac:	89 c2                	mov    %eax,%edx
c010aaae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aab1:	89 50 44             	mov    %edx,0x44(%eax)
            if (proc->wait_state & WT_INTERRUPTED) {
c010aab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aab7:	8b 40 6c             	mov    0x6c(%eax),%eax
c010aaba:	85 c0                	test   %eax,%eax
c010aabc:	79 0b                	jns    c010aac9 <do_kill+0x4d>
                wakeup_proc(proc);
c010aabe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aac1:	89 04 24             	mov    %eax,(%esp)
c010aac4:	e8 83 05 00 00       	call   c010b04c <wakeup_proc>
            }
            return 0;
c010aac9:	b8 00 00 00 00       	mov    $0x0,%eax
c010aace:	eb 0c                	jmp    c010aadc <do_kill+0x60>
        }
        return -E_KILLED;
c010aad0:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
c010aad5:	eb 05                	jmp    c010aadc <do_kill+0x60>
    }
    return -E_INVAL;
c010aad7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
c010aadc:	c9                   	leave  
c010aadd:	c3                   	ret    

c010aade <kernel_execve>:

// kernel_execve - do SYS_exec syscall to exec a user program called by user_main kernel_thread
static int
kernel_execve(const char *name, unsigned char *binary, size_t size) {
c010aade:	55                   	push   %ebp
c010aadf:	89 e5                	mov    %esp,%ebp
c010aae1:	57                   	push   %edi
c010aae2:	56                   	push   %esi
c010aae3:	53                   	push   %ebx
c010aae4:	83 ec 2c             	sub    $0x2c,%esp
    int ret, len = strlen(name);
c010aae7:	8b 45 08             	mov    0x8(%ebp),%eax
c010aaea:	89 04 24             	mov    %eax,(%esp)
c010aaed:	e8 11 0c 00 00       	call   c010b703 <strlen>
c010aaf2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    asm volatile (
c010aaf5:	b8 04 00 00 00       	mov    $0x4,%eax
c010aafa:	8b 55 08             	mov    0x8(%ebp),%edx
c010aafd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
c010ab00:	8b 5d 0c             	mov    0xc(%ebp),%ebx
c010ab03:	8b 75 10             	mov    0x10(%ebp),%esi
c010ab06:	89 f7                	mov    %esi,%edi
c010ab08:	cd 80                	int    $0x80
c010ab0a:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "int %1;"
        : "=a" (ret)
        : "i" (T_SYSCALL), "0" (SYS_exec), "d" (name), "c" (len), "b" (binary), "D" (size)
        : "memory");
    return ret;
c010ab0d:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
c010ab10:	83 c4 2c             	add    $0x2c,%esp
c010ab13:	5b                   	pop    %ebx
c010ab14:	5e                   	pop    %esi
c010ab15:	5f                   	pop    %edi
c010ab16:	5d                   	pop    %ebp
c010ab17:	c3                   	ret    

c010ab18 <user_main>:

#define KERNEL_EXECVE2(x, xstart, xsize)        __KERNEL_EXECVE2(x, xstart, xsize)

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
c010ab18:	55                   	push   %ebp
c010ab19:	89 e5                	mov    %esp,%ebp
c010ab1b:	83 ec 18             	sub    $0x18,%esp
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
c010ab1e:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010ab23:	8b 40 04             	mov    0x4(%eax),%eax
c010ab26:	c7 44 24 08 46 e6 10 	movl   $0xc010e646,0x8(%esp)
c010ab2d:	c0 
c010ab2e:	89 44 24 04          	mov    %eax,0x4(%esp)
c010ab32:	c7 04 24 50 e6 10 c0 	movl   $0xc010e650,(%esp)
c010ab39:	e8 70 57 ff ff       	call   c01002ae <cprintf>
c010ab3e:	b8 60 79 00 00       	mov    $0x7960,%eax
c010ab43:	89 44 24 08          	mov    %eax,0x8(%esp)
c010ab47:	c7 44 24 04 e8 a3 15 	movl   $0xc015a3e8,0x4(%esp)
c010ab4e:	c0 
c010ab4f:	c7 04 24 46 e6 10 c0 	movl   $0xc010e646,(%esp)
c010ab56:	e8 83 ff ff ff       	call   c010aade <kernel_execve>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
c010ab5b:	c7 44 24 08 77 e6 10 	movl   $0xc010e677,0x8(%esp)
c010ab62:	c0 
c010ab63:	c7 44 24 04 4c 03 00 	movl   $0x34c,0x4(%esp)
c010ab6a:	00 
c010ab6b:	c7 04 24 20 e4 10 c0 	movl   $0xc010e420,(%esp)
c010ab72:	e8 8e 58 ff ff       	call   c0100405 <__panic>

c010ab77 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
c010ab77:	55                   	push   %ebp
c010ab78:	89 e5                	mov    %esp,%ebp
c010ab7a:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c010ab7d:	e8 d4 c9 ff ff       	call   c0107556 <nr_free_pages>
c010ab82:	89 45 f4             	mov    %eax,-0xc(%ebp)
    size_t kernel_allocated_store = kallocated();
c010ab85:	e8 2d a6 ff ff       	call   c01051b7 <kallocated>
c010ab8a:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int pid = kernel_thread(user_main, NULL, 0);
c010ab8d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010ab94:	00 
c010ab95:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010ab9c:	00 
c010ab9d:	c7 04 24 18 ab 10 c0 	movl   $0xc010ab18,(%esp)
c010aba4:	e8 0b ef ff ff       	call   c0109ab4 <kernel_thread>
c010aba9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (pid <= 0) {
c010abac:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010abb0:	7f 1c                	jg     c010abce <init_main+0x57>
        panic("create user_main failed.\n");
c010abb2:	c7 44 24 08 91 e6 10 	movl   $0xc010e691,0x8(%esp)
c010abb9:	c0 
c010abba:	c7 44 24 04 57 03 00 	movl   $0x357,0x4(%esp)
c010abc1:	00 
c010abc2:	c7 04 24 20 e4 10 c0 	movl   $0xc010e420,(%esp)
c010abc9:	e8 37 58 ff ff       	call   c0100405 <__panic>
    }

    while (do_wait(0, NULL) == 0) {
c010abce:	eb 05                	jmp    c010abd5 <init_main+0x5e>
        schedule();
c010abd0:	e8 10 05 00 00       	call   c010b0e5 <schedule>
    while (do_wait(0, NULL) == 0) {
c010abd5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010abdc:	00 
c010abdd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010abe4:	e8 ff fc ff ff       	call   c010a8e8 <do_wait>
c010abe9:	85 c0                	test   %eax,%eax
c010abeb:	74 e3                	je     c010abd0 <init_main+0x59>
    }

    cprintf("all user-mode processes have quit.\n");
c010abed:	c7 04 24 ac e6 10 c0 	movl   $0xc010e6ac,(%esp)
c010abf4:	e8 b5 56 ff ff       	call   c01002ae <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
c010abf9:	a1 24 10 1b c0       	mov    0xc01b1024,%eax
c010abfe:	8b 40 70             	mov    0x70(%eax),%eax
c010ac01:	85 c0                	test   %eax,%eax
c010ac03:	75 18                	jne    c010ac1d <init_main+0xa6>
c010ac05:	a1 24 10 1b c0       	mov    0xc01b1024,%eax
c010ac0a:	8b 40 74             	mov    0x74(%eax),%eax
c010ac0d:	85 c0                	test   %eax,%eax
c010ac0f:	75 0c                	jne    c010ac1d <init_main+0xa6>
c010ac11:	a1 24 10 1b c0       	mov    0xc01b1024,%eax
c010ac16:	8b 40 78             	mov    0x78(%eax),%eax
c010ac19:	85 c0                	test   %eax,%eax
c010ac1b:	74 24                	je     c010ac41 <init_main+0xca>
c010ac1d:	c7 44 24 0c d0 e6 10 	movl   $0xc010e6d0,0xc(%esp)
c010ac24:	c0 
c010ac25:	c7 44 24 08 4d e4 10 	movl   $0xc010e44d,0x8(%esp)
c010ac2c:	c0 
c010ac2d:	c7 44 24 04 5f 03 00 	movl   $0x35f,0x4(%esp)
c010ac34:	00 
c010ac35:	c7 04 24 20 e4 10 c0 	movl   $0xc010e420,(%esp)
c010ac3c:	e8 c4 57 ff ff       	call   c0100405 <__panic>
    assert(nr_process == 2);
c010ac41:	a1 40 30 1b c0       	mov    0xc01b3040,%eax
c010ac46:	83 f8 02             	cmp    $0x2,%eax
c010ac49:	74 24                	je     c010ac6f <init_main+0xf8>
c010ac4b:	c7 44 24 0c 1b e7 10 	movl   $0xc010e71b,0xc(%esp)
c010ac52:	c0 
c010ac53:	c7 44 24 08 4d e4 10 	movl   $0xc010e44d,0x8(%esp)
c010ac5a:	c0 
c010ac5b:	c7 44 24 04 60 03 00 	movl   $0x360,0x4(%esp)
c010ac62:	00 
c010ac63:	c7 04 24 20 e4 10 c0 	movl   $0xc010e420,(%esp)
c010ac6a:	e8 96 57 ff ff       	call   c0100405 <__panic>
c010ac6f:	c7 45 e8 7c 31 1b c0 	movl   $0xc01b317c,-0x18(%ebp)
c010ac76:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ac79:	8b 40 04             	mov    0x4(%eax),%eax
    assert(list_next(&proc_list) == &(initproc->list_link));
c010ac7c:	8b 15 24 10 1b c0    	mov    0xc01b1024,%edx
c010ac82:	83 c2 58             	add    $0x58,%edx
c010ac85:	39 d0                	cmp    %edx,%eax
c010ac87:	74 24                	je     c010acad <init_main+0x136>
c010ac89:	c7 44 24 0c 2c e7 10 	movl   $0xc010e72c,0xc(%esp)
c010ac90:	c0 
c010ac91:	c7 44 24 08 4d e4 10 	movl   $0xc010e44d,0x8(%esp)
c010ac98:	c0 
c010ac99:	c7 44 24 04 61 03 00 	movl   $0x361,0x4(%esp)
c010aca0:	00 
c010aca1:	c7 04 24 20 e4 10 c0 	movl   $0xc010e420,(%esp)
c010aca8:	e8 58 57 ff ff       	call   c0100405 <__panic>
c010acad:	c7 45 e4 7c 31 1b c0 	movl   $0xc01b317c,-0x1c(%ebp)
    return listelm->prev;
c010acb4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010acb7:	8b 00                	mov    (%eax),%eax
    assert(list_prev(&proc_list) == &(initproc->list_link));
c010acb9:	8b 15 24 10 1b c0    	mov    0xc01b1024,%edx
c010acbf:	83 c2 58             	add    $0x58,%edx
c010acc2:	39 d0                	cmp    %edx,%eax
c010acc4:	74 24                	je     c010acea <init_main+0x173>
c010acc6:	c7 44 24 0c 5c e7 10 	movl   $0xc010e75c,0xc(%esp)
c010accd:	c0 
c010acce:	c7 44 24 08 4d e4 10 	movl   $0xc010e44d,0x8(%esp)
c010acd5:	c0 
c010acd6:	c7 44 24 04 62 03 00 	movl   $0x362,0x4(%esp)
c010acdd:	00 
c010acde:	c7 04 24 20 e4 10 c0 	movl   $0xc010e420,(%esp)
c010ace5:	e8 1b 57 ff ff       	call   c0100405 <__panic>

    cprintf("init check memory pass.\n");
c010acea:	c7 04 24 8c e7 10 c0 	movl   $0xc010e78c,(%esp)
c010acf1:	e8 b8 55 ff ff       	call   c01002ae <cprintf>
    return 0;
c010acf6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010acfb:	c9                   	leave  
c010acfc:	c3                   	ret    

c010acfd <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
c010acfd:	55                   	push   %ebp
c010acfe:	89 e5                	mov    %esp,%ebp
c010ad00:	83 ec 28             	sub    $0x28,%esp
c010ad03:	c7 45 ec 7c 31 1b c0 	movl   $0xc01b317c,-0x14(%ebp)
    elm->prev = elm->next = elm;
c010ad0a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010ad0d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010ad10:	89 50 04             	mov    %edx,0x4(%eax)
c010ad13:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010ad16:	8b 50 04             	mov    0x4(%eax),%edx
c010ad19:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010ad1c:	89 10                	mov    %edx,(%eax)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c010ad1e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010ad25:	eb 26                	jmp    c010ad4d <proc_init+0x50>
        list_init(hash_list + i);
c010ad27:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ad2a:	c1 e0 03             	shl    $0x3,%eax
c010ad2d:	05 40 10 1b c0       	add    $0xc01b1040,%eax
c010ad32:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010ad35:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ad38:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010ad3b:	89 50 04             	mov    %edx,0x4(%eax)
c010ad3e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ad41:	8b 50 04             	mov    0x4(%eax),%edx
c010ad44:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ad47:	89 10                	mov    %edx,(%eax)
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c010ad49:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010ad4d:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
c010ad54:	7e d1                	jle    c010ad27 <proc_init+0x2a>
    }

    if ((idleproc = alloc_proc()) == NULL) {
c010ad56:	e8 96 e7 ff ff       	call   c01094f1 <alloc_proc>
c010ad5b:	a3 20 10 1b c0       	mov    %eax,0xc01b1020
c010ad60:	a1 20 10 1b c0       	mov    0xc01b1020,%eax
c010ad65:	85 c0                	test   %eax,%eax
c010ad67:	75 1c                	jne    c010ad85 <proc_init+0x88>
        panic("cannot alloc idleproc.\n");
c010ad69:	c7 44 24 08 a5 e7 10 	movl   $0xc010e7a5,0x8(%esp)
c010ad70:	c0 
c010ad71:	c7 44 24 04 74 03 00 	movl   $0x374,0x4(%esp)
c010ad78:	00 
c010ad79:	c7 04 24 20 e4 10 c0 	movl   $0xc010e420,(%esp)
c010ad80:	e8 80 56 ff ff       	call   c0100405 <__panic>
    }

    idleproc->pid = 0;
c010ad85:	a1 20 10 1b c0       	mov    0xc01b1020,%eax
c010ad8a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    idleproc->state = PROC_RUNNABLE;
c010ad91:	a1 20 10 1b c0       	mov    0xc01b1020,%eax
c010ad96:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
    idleproc->kstack = (uintptr_t)bootstack;
c010ad9c:	a1 20 10 1b c0       	mov    0xc01b1020,%eax
c010ada1:	ba 00 a0 12 c0       	mov    $0xc012a000,%edx
c010ada6:	89 50 0c             	mov    %edx,0xc(%eax)
    idleproc->need_resched = 1;
c010ada9:	a1 20 10 1b c0       	mov    0xc01b1020,%eax
c010adae:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    set_proc_name(idleproc, "idle");
c010adb5:	a1 20 10 1b c0       	mov    0xc01b1020,%eax
c010adba:	c7 44 24 04 bd e7 10 	movl   $0xc010e7bd,0x4(%esp)
c010adc1:	c0 
c010adc2:	89 04 24             	mov    %eax,(%esp)
c010adc5:	e8 97 e8 ff ff       	call   c0109661 <set_proc_name>
    nr_process ++;
c010adca:	a1 40 30 1b c0       	mov    0xc01b3040,%eax
c010adcf:	83 c0 01             	add    $0x1,%eax
c010add2:	a3 40 30 1b c0       	mov    %eax,0xc01b3040

    current = idleproc;
c010add7:	a1 20 10 1b c0       	mov    0xc01b1020,%eax
c010addc:	a3 28 10 1b c0       	mov    %eax,0xc01b1028

    int pid = kernel_thread(init_main, NULL, 0);
c010ade1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010ade8:	00 
c010ade9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010adf0:	00 
c010adf1:	c7 04 24 77 ab 10 c0 	movl   $0xc010ab77,(%esp)
c010adf8:	e8 b7 ec ff ff       	call   c0109ab4 <kernel_thread>
c010adfd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (pid <= 0) {
c010ae00:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010ae04:	7f 1c                	jg     c010ae22 <proc_init+0x125>
        panic("create init_main failed.\n");
c010ae06:	c7 44 24 08 c2 e7 10 	movl   $0xc010e7c2,0x8(%esp)
c010ae0d:	c0 
c010ae0e:	c7 44 24 04 82 03 00 	movl   $0x382,0x4(%esp)
c010ae15:	00 
c010ae16:	c7 04 24 20 e4 10 c0 	movl   $0xc010e420,(%esp)
c010ae1d:	e8 e3 55 ff ff       	call   c0100405 <__panic>
    }

    initproc = find_proc(pid);
c010ae22:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010ae25:	89 04 24             	mov    %eax,(%esp)
c010ae28:	e8 15 ec ff ff       	call   c0109a42 <find_proc>
c010ae2d:	a3 24 10 1b c0       	mov    %eax,0xc01b1024
    set_proc_name(initproc, "init");
c010ae32:	a1 24 10 1b c0       	mov    0xc01b1024,%eax
c010ae37:	c7 44 24 04 dc e7 10 	movl   $0xc010e7dc,0x4(%esp)
c010ae3e:	c0 
c010ae3f:	89 04 24             	mov    %eax,(%esp)
c010ae42:	e8 1a e8 ff ff       	call   c0109661 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
c010ae47:	a1 20 10 1b c0       	mov    0xc01b1020,%eax
c010ae4c:	85 c0                	test   %eax,%eax
c010ae4e:	74 0c                	je     c010ae5c <proc_init+0x15f>
c010ae50:	a1 20 10 1b c0       	mov    0xc01b1020,%eax
c010ae55:	8b 40 04             	mov    0x4(%eax),%eax
c010ae58:	85 c0                	test   %eax,%eax
c010ae5a:	74 24                	je     c010ae80 <proc_init+0x183>
c010ae5c:	c7 44 24 0c e4 e7 10 	movl   $0xc010e7e4,0xc(%esp)
c010ae63:	c0 
c010ae64:	c7 44 24 08 4d e4 10 	movl   $0xc010e44d,0x8(%esp)
c010ae6b:	c0 
c010ae6c:	c7 44 24 04 88 03 00 	movl   $0x388,0x4(%esp)
c010ae73:	00 
c010ae74:	c7 04 24 20 e4 10 c0 	movl   $0xc010e420,(%esp)
c010ae7b:	e8 85 55 ff ff       	call   c0100405 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
c010ae80:	a1 24 10 1b c0       	mov    0xc01b1024,%eax
c010ae85:	85 c0                	test   %eax,%eax
c010ae87:	74 0d                	je     c010ae96 <proc_init+0x199>
c010ae89:	a1 24 10 1b c0       	mov    0xc01b1024,%eax
c010ae8e:	8b 40 04             	mov    0x4(%eax),%eax
c010ae91:	83 f8 01             	cmp    $0x1,%eax
c010ae94:	74 24                	je     c010aeba <proc_init+0x1bd>
c010ae96:	c7 44 24 0c 0c e8 10 	movl   $0xc010e80c,0xc(%esp)
c010ae9d:	c0 
c010ae9e:	c7 44 24 08 4d e4 10 	movl   $0xc010e44d,0x8(%esp)
c010aea5:	c0 
c010aea6:	c7 44 24 04 89 03 00 	movl   $0x389,0x4(%esp)
c010aead:	00 
c010aeae:	c7 04 24 20 e4 10 c0 	movl   $0xc010e420,(%esp)
c010aeb5:	e8 4b 55 ff ff       	call   c0100405 <__panic>
}
c010aeba:	c9                   	leave  
c010aebb:	c3                   	ret    

c010aebc <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
c010aebc:	55                   	push   %ebp
c010aebd:	89 e5                	mov    %esp,%ebp
c010aebf:	83 ec 08             	sub    $0x8,%esp
    while (1) {
        if (current->need_resched) {
c010aec2:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010aec7:	8b 40 10             	mov    0x10(%eax),%eax
c010aeca:	85 c0                	test   %eax,%eax
c010aecc:	74 07                	je     c010aed5 <cpu_idle+0x19>
            schedule();
c010aece:	e8 12 02 00 00       	call   c010b0e5 <schedule>
        }
    }
c010aed3:	eb ed                	jmp    c010aec2 <cpu_idle+0x6>
c010aed5:	eb eb                	jmp    c010aec2 <cpu_idle+0x6>

c010aed7 <lab6_set_priority>:
}

//FOR LAB6, set the process's priority (bigger value will get more CPU time) 
void
lab6_set_priority(uint32_t priority)
{
c010aed7:	55                   	push   %ebp
c010aed8:	89 e5                	mov    %esp,%ebp
    if (priority == 0)
c010aeda:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010aede:	75 11                	jne    c010aef1 <lab6_set_priority+0x1a>
        current->lab6_priority = 1;
c010aee0:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010aee5:	c7 80 9c 00 00 00 01 	movl   $0x1,0x9c(%eax)
c010aeec:	00 00 00 
c010aeef:	eb 0e                	jmp    c010aeff <lab6_set_priority+0x28>
    else current->lab6_priority = priority;
c010aef1:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010aef6:	8b 55 08             	mov    0x8(%ebp),%edx
c010aef9:	89 90 9c 00 00 00    	mov    %edx,0x9c(%eax)
}
c010aeff:	5d                   	pop    %ebp
c010af00:	c3                   	ret    

c010af01 <__intr_save>:
__intr_save(void) {
c010af01:	55                   	push   %ebp
c010af02:	89 e5                	mov    %esp,%ebp
c010af04:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010af07:	9c                   	pushf  
c010af08:	58                   	pop    %eax
c010af09:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c010af0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c010af0f:	25 00 02 00 00       	and    $0x200,%eax
c010af14:	85 c0                	test   %eax,%eax
c010af16:	74 0c                	je     c010af24 <__intr_save+0x23>
        intr_disable();
c010af18:	e8 fd 72 ff ff       	call   c010221a <intr_disable>
        return 1;
c010af1d:	b8 01 00 00 00       	mov    $0x1,%eax
c010af22:	eb 05                	jmp    c010af29 <__intr_save+0x28>
    return 0;
c010af24:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010af29:	c9                   	leave  
c010af2a:	c3                   	ret    

c010af2b <__intr_restore>:
__intr_restore(bool flag) {
c010af2b:	55                   	push   %ebp
c010af2c:	89 e5                	mov    %esp,%ebp
c010af2e:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c010af31:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010af35:	74 05                	je     c010af3c <__intr_restore+0x11>
        intr_enable();
c010af37:	e8 d8 72 ff ff       	call   c0102214 <intr_enable>
}
c010af3c:	c9                   	leave  
c010af3d:	c3                   	ret    

c010af3e <sched_class_enqueue>:
static struct sched_class *sched_class;

static struct run_queue *rq;

static inline void
sched_class_enqueue(struct proc_struct *proc) {
c010af3e:	55                   	push   %ebp
c010af3f:	89 e5                	mov    %esp,%ebp
c010af41:	83 ec 18             	sub    $0x18,%esp
    if (proc != idleproc) {
c010af44:	a1 20 10 1b c0       	mov    0xc01b1020,%eax
c010af49:	39 45 08             	cmp    %eax,0x8(%ebp)
c010af4c:	74 1a                	je     c010af68 <sched_class_enqueue+0x2a>
        sched_class->enqueue(rq, proc);
c010af4e:	a1 5c 30 1b c0       	mov    0xc01b305c,%eax
c010af53:	8b 40 08             	mov    0x8(%eax),%eax
c010af56:	8b 15 60 30 1b c0    	mov    0xc01b3060,%edx
c010af5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
c010af5f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c010af63:	89 14 24             	mov    %edx,(%esp)
c010af66:	ff d0                	call   *%eax
    }
}
c010af68:	c9                   	leave  
c010af69:	c3                   	ret    

c010af6a <sched_class_dequeue>:

static inline void
sched_class_dequeue(struct proc_struct *proc) {
c010af6a:	55                   	push   %ebp
c010af6b:	89 e5                	mov    %esp,%ebp
c010af6d:	83 ec 18             	sub    $0x18,%esp
    sched_class->dequeue(rq, proc);
c010af70:	a1 5c 30 1b c0       	mov    0xc01b305c,%eax
c010af75:	8b 40 0c             	mov    0xc(%eax),%eax
c010af78:	8b 15 60 30 1b c0    	mov    0xc01b3060,%edx
c010af7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
c010af81:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c010af85:	89 14 24             	mov    %edx,(%esp)
c010af88:	ff d0                	call   *%eax
}
c010af8a:	c9                   	leave  
c010af8b:	c3                   	ret    

c010af8c <sched_class_pick_next>:

static inline struct proc_struct *
sched_class_pick_next(void) {
c010af8c:	55                   	push   %ebp
c010af8d:	89 e5                	mov    %esp,%ebp
c010af8f:	83 ec 18             	sub    $0x18,%esp
    return sched_class->pick_next(rq);
c010af92:	a1 5c 30 1b c0       	mov    0xc01b305c,%eax
c010af97:	8b 40 10             	mov    0x10(%eax),%eax
c010af9a:	8b 15 60 30 1b c0    	mov    0xc01b3060,%edx
c010afa0:	89 14 24             	mov    %edx,(%esp)
c010afa3:	ff d0                	call   *%eax
}
c010afa5:	c9                   	leave  
c010afa6:	c3                   	ret    

c010afa7 <sched_class_proc_tick>:

void
sched_class_proc_tick(struct proc_struct *proc) {
c010afa7:	55                   	push   %ebp
c010afa8:	89 e5                	mov    %esp,%ebp
c010afaa:	83 ec 18             	sub    $0x18,%esp
    if (proc != idleproc) {
c010afad:	a1 20 10 1b c0       	mov    0xc01b1020,%eax
c010afb2:	39 45 08             	cmp    %eax,0x8(%ebp)
c010afb5:	74 1c                	je     c010afd3 <sched_class_proc_tick+0x2c>
        sched_class->proc_tick(rq, proc);
c010afb7:	a1 5c 30 1b c0       	mov    0xc01b305c,%eax
c010afbc:	8b 40 14             	mov    0x14(%eax),%eax
c010afbf:	8b 15 60 30 1b c0    	mov    0xc01b3060,%edx
c010afc5:	8b 4d 08             	mov    0x8(%ebp),%ecx
c010afc8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c010afcc:	89 14 24             	mov    %edx,(%esp)
c010afcf:	ff d0                	call   *%eax
c010afd1:	eb 0a                	jmp    c010afdd <sched_class_proc_tick+0x36>
    }
    else {
        proc->need_resched = 1;
c010afd3:	8b 45 08             	mov    0x8(%ebp),%eax
c010afd6:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    }
}
c010afdd:	c9                   	leave  
c010afde:	c3                   	ret    

c010afdf <sched_init>:

static struct run_queue __rq;

void
sched_init(void) {
c010afdf:	55                   	push   %ebp
c010afe0:	89 e5                	mov    %esp,%ebp
c010afe2:	83 ec 28             	sub    $0x28,%esp
c010afe5:	c7 45 f4 54 30 1b c0 	movl   $0xc01b3054,-0xc(%ebp)
c010afec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010afef:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010aff2:	89 50 04             	mov    %edx,0x4(%eax)
c010aff5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aff8:	8b 50 04             	mov    0x4(%eax),%edx
c010affb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010affe:	89 10                	mov    %edx,(%eax)
    list_init(&timer_list);

    sched_class = &default_sched_class;
c010b000:	c7 05 5c 30 1b c0 80 	movl   $0xc012ca80,0xc01b305c
c010b007:	ca 12 c0 

    rq = &__rq;
c010b00a:	c7 05 60 30 1b c0 64 	movl   $0xc01b3064,0xc01b3060
c010b011:	30 1b c0 
    rq->max_time_slice = MAX_TIME_SLICE;
c010b014:	a1 60 30 1b c0       	mov    0xc01b3060,%eax
c010b019:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
    sched_class->init(rq);
c010b020:	a1 5c 30 1b c0       	mov    0xc01b305c,%eax
c010b025:	8b 40 04             	mov    0x4(%eax),%eax
c010b028:	8b 15 60 30 1b c0    	mov    0xc01b3060,%edx
c010b02e:	89 14 24             	mov    %edx,(%esp)
c010b031:	ff d0                	call   *%eax

    cprintf("sched class: %s\n", sched_class->name);
c010b033:	a1 5c 30 1b c0       	mov    0xc01b305c,%eax
c010b038:	8b 00                	mov    (%eax),%eax
c010b03a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b03e:	c7 04 24 33 e8 10 c0 	movl   $0xc010e833,(%esp)
c010b045:	e8 64 52 ff ff       	call   c01002ae <cprintf>
}
c010b04a:	c9                   	leave  
c010b04b:	c3                   	ret    

c010b04c <wakeup_proc>:

void
wakeup_proc(struct proc_struct *proc) {
c010b04c:	55                   	push   %ebp
c010b04d:	89 e5                	mov    %esp,%ebp
c010b04f:	83 ec 28             	sub    $0x28,%esp
    assert(proc->state != PROC_ZOMBIE);
c010b052:	8b 45 08             	mov    0x8(%ebp),%eax
c010b055:	8b 00                	mov    (%eax),%eax
c010b057:	83 f8 03             	cmp    $0x3,%eax
c010b05a:	75 24                	jne    c010b080 <wakeup_proc+0x34>
c010b05c:	c7 44 24 0c 44 e8 10 	movl   $0xc010e844,0xc(%esp)
c010b063:	c0 
c010b064:	c7 44 24 08 5f e8 10 	movl   $0xc010e85f,0x8(%esp)
c010b06b:	c0 
c010b06c:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
c010b073:	00 
c010b074:	c7 04 24 74 e8 10 c0 	movl   $0xc010e874,(%esp)
c010b07b:	e8 85 53 ff ff       	call   c0100405 <__panic>
    bool intr_flag;
    local_intr_save(intr_flag);
c010b080:	e8 7c fe ff ff       	call   c010af01 <__intr_save>
c010b085:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        if (proc->state != PROC_RUNNABLE) {
c010b088:	8b 45 08             	mov    0x8(%ebp),%eax
c010b08b:	8b 00                	mov    (%eax),%eax
c010b08d:	83 f8 02             	cmp    $0x2,%eax
c010b090:	74 2a                	je     c010b0bc <wakeup_proc+0x70>
            proc->state = PROC_RUNNABLE;
c010b092:	8b 45 08             	mov    0x8(%ebp),%eax
c010b095:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
            proc->wait_state = 0;
c010b09b:	8b 45 08             	mov    0x8(%ebp),%eax
c010b09e:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%eax)
            if (proc != current) {
c010b0a5:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010b0aa:	39 45 08             	cmp    %eax,0x8(%ebp)
c010b0ad:	74 29                	je     c010b0d8 <wakeup_proc+0x8c>
                sched_class_enqueue(proc);
c010b0af:	8b 45 08             	mov    0x8(%ebp),%eax
c010b0b2:	89 04 24             	mov    %eax,(%esp)
c010b0b5:	e8 84 fe ff ff       	call   c010af3e <sched_class_enqueue>
c010b0ba:	eb 1c                	jmp    c010b0d8 <wakeup_proc+0x8c>
            }
        }
        else {
            warn("wakeup runnable process.\n");
c010b0bc:	c7 44 24 08 8a e8 10 	movl   $0xc010e88a,0x8(%esp)
c010b0c3:	c0 
c010b0c4:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
c010b0cb:	00 
c010b0cc:	c7 04 24 74 e8 10 c0 	movl   $0xc010e874,(%esp)
c010b0d3:	e8 aa 53 ff ff       	call   c0100482 <__warn>
        }
    }
    local_intr_restore(intr_flag);
c010b0d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b0db:	89 04 24             	mov    %eax,(%esp)
c010b0de:	e8 48 fe ff ff       	call   c010af2b <__intr_restore>
}
c010b0e3:	c9                   	leave  
c010b0e4:	c3                   	ret    

c010b0e5 <schedule>:

void
schedule(void) {
c010b0e5:	55                   	push   %ebp
c010b0e6:	89 e5                	mov    %esp,%ebp
c010b0e8:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    struct proc_struct *next;
    local_intr_save(intr_flag);
c010b0eb:	e8 11 fe ff ff       	call   c010af01 <__intr_save>
c010b0f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        current->need_resched = 0;
c010b0f3:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010b0f8:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        if (current->state == PROC_RUNNABLE) {
c010b0ff:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010b104:	8b 00                	mov    (%eax),%eax
c010b106:	83 f8 02             	cmp    $0x2,%eax
c010b109:	75 0d                	jne    c010b118 <schedule+0x33>
            sched_class_enqueue(current);
c010b10b:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010b110:	89 04 24             	mov    %eax,(%esp)
c010b113:	e8 26 fe ff ff       	call   c010af3e <sched_class_enqueue>
        }
        if ((next = sched_class_pick_next()) != NULL) {
c010b118:	e8 6f fe ff ff       	call   c010af8c <sched_class_pick_next>
c010b11d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b120:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010b124:	74 0b                	je     c010b131 <schedule+0x4c>
            sched_class_dequeue(next);
c010b126:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b129:	89 04 24             	mov    %eax,(%esp)
c010b12c:	e8 39 fe ff ff       	call   c010af6a <sched_class_dequeue>
        }
        if (next == NULL) {
c010b131:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010b135:	75 08                	jne    c010b13f <schedule+0x5a>
            next = idleproc;
c010b137:	a1 20 10 1b c0       	mov    0xc01b1020,%eax
c010b13c:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        next->runs ++;
c010b13f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b142:	8b 40 08             	mov    0x8(%eax),%eax
c010b145:	8d 50 01             	lea    0x1(%eax),%edx
c010b148:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b14b:	89 50 08             	mov    %edx,0x8(%eax)
        if (next != current) {
c010b14e:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010b153:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010b156:	74 0b                	je     c010b163 <schedule+0x7e>
            proc_run(next);
c010b158:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b15b:	89 04 24             	mov    %eax,(%esp)
c010b15e:	e8 a3 e7 ff ff       	call   c0109906 <proc_run>
        }
    }
    local_intr_restore(intr_flag);
c010b163:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b166:	89 04 24             	mov    %eax,(%esp)
c010b169:	e8 bd fd ff ff       	call   c010af2b <__intr_restore>
}
c010b16e:	c9                   	leave  
c010b16f:	c3                   	ret    

c010b170 <skew_heap_merge>:
}

static inline skew_heap_entry_t *
skew_heap_merge(skew_heap_entry_t *a, skew_heap_entry_t *b,
                compare_f comp)
{
c010b170:	55                   	push   %ebp
c010b171:	89 e5                	mov    %esp,%ebp
c010b173:	83 ec 28             	sub    $0x28,%esp
     if (a == NULL) return b;
c010b176:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010b17a:	75 08                	jne    c010b184 <skew_heap_merge+0x14>
c010b17c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b17f:	e9 bd 00 00 00       	jmp    c010b241 <skew_heap_merge+0xd1>
     else if (b == NULL) return a;
c010b184:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010b188:	75 08                	jne    c010b192 <skew_heap_merge+0x22>
c010b18a:	8b 45 08             	mov    0x8(%ebp),%eax
c010b18d:	e9 af 00 00 00       	jmp    c010b241 <skew_heap_merge+0xd1>
     
     skew_heap_entry_t *l, *r;
     if (comp(a, b) == -1)
c010b192:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b195:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b199:	8b 45 08             	mov    0x8(%ebp),%eax
c010b19c:	89 04 24             	mov    %eax,(%esp)
c010b19f:	8b 45 10             	mov    0x10(%ebp),%eax
c010b1a2:	ff d0                	call   *%eax
c010b1a4:	83 f8 ff             	cmp    $0xffffffff,%eax
c010b1a7:	75 4d                	jne    c010b1f6 <skew_heap_merge+0x86>
     {
          r = a->left;
c010b1a9:	8b 45 08             	mov    0x8(%ebp),%eax
c010b1ac:	8b 40 04             	mov    0x4(%eax),%eax
c010b1af:	89 45 f4             	mov    %eax,-0xc(%ebp)
          l = skew_heap_merge(a->right, b, comp);
c010b1b2:	8b 45 08             	mov    0x8(%ebp),%eax
c010b1b5:	8b 40 08             	mov    0x8(%eax),%eax
c010b1b8:	8b 55 10             	mov    0x10(%ebp),%edx
c010b1bb:	89 54 24 08          	mov    %edx,0x8(%esp)
c010b1bf:	8b 55 0c             	mov    0xc(%ebp),%edx
c010b1c2:	89 54 24 04          	mov    %edx,0x4(%esp)
c010b1c6:	89 04 24             	mov    %eax,(%esp)
c010b1c9:	e8 a2 ff ff ff       	call   c010b170 <skew_heap_merge>
c010b1ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
          
          a->left = l;
c010b1d1:	8b 45 08             	mov    0x8(%ebp),%eax
c010b1d4:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010b1d7:	89 50 04             	mov    %edx,0x4(%eax)
          a->right = r;
c010b1da:	8b 45 08             	mov    0x8(%ebp),%eax
c010b1dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b1e0:	89 50 08             	mov    %edx,0x8(%eax)
          if (l) l->parent = a;
c010b1e3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010b1e7:	74 08                	je     c010b1f1 <skew_heap_merge+0x81>
c010b1e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b1ec:	8b 55 08             	mov    0x8(%ebp),%edx
c010b1ef:	89 10                	mov    %edx,(%eax)

          return a;
c010b1f1:	8b 45 08             	mov    0x8(%ebp),%eax
c010b1f4:	eb 4b                	jmp    c010b241 <skew_heap_merge+0xd1>
     }
     else
     {
          r = b->left;
c010b1f6:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b1f9:	8b 40 04             	mov    0x4(%eax),%eax
c010b1fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
          l = skew_heap_merge(a, b->right, comp);
c010b1ff:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b202:	8b 40 08             	mov    0x8(%eax),%eax
c010b205:	8b 55 10             	mov    0x10(%ebp),%edx
c010b208:	89 54 24 08          	mov    %edx,0x8(%esp)
c010b20c:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b210:	8b 45 08             	mov    0x8(%ebp),%eax
c010b213:	89 04 24             	mov    %eax,(%esp)
c010b216:	e8 55 ff ff ff       	call   c010b170 <skew_heap_merge>
c010b21b:	89 45 f0             	mov    %eax,-0x10(%ebp)
          
          b->left = l;
c010b21e:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b221:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010b224:	89 50 04             	mov    %edx,0x4(%eax)
          b->right = r;
c010b227:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b22a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b22d:	89 50 08             	mov    %edx,0x8(%eax)
          if (l) l->parent = b;
c010b230:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010b234:	74 08                	je     c010b23e <skew_heap_merge+0xce>
c010b236:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b239:	8b 55 0c             	mov    0xc(%ebp),%edx
c010b23c:	89 10                	mov    %edx,(%eax)

          return b;
c010b23e:	8b 45 0c             	mov    0xc(%ebp),%eax
     }
}
c010b241:	c9                   	leave  
c010b242:	c3                   	ret    

c010b243 <proc_stride_comp_f>:

/* The compare function for two skew_heap_node_t's and the
 * corresponding procs*/
static int
proc_stride_comp_f(void *a, void *b)
{
c010b243:	55                   	push   %ebp
c010b244:	89 e5                	mov    %esp,%ebp
c010b246:	83 ec 10             	sub    $0x10,%esp
     struct proc_struct *p = le2proc(a, lab6_run_pool);
c010b249:	8b 45 08             	mov    0x8(%ebp),%eax
c010b24c:	2d 8c 00 00 00       	sub    $0x8c,%eax
c010b251:	89 45 fc             	mov    %eax,-0x4(%ebp)
     struct proc_struct *q = le2proc(b, lab6_run_pool);
c010b254:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b257:	2d 8c 00 00 00       	sub    $0x8c,%eax
c010b25c:	89 45 f8             	mov    %eax,-0x8(%ebp)
     int32_t c = p->lab6_stride - q->lab6_stride;
c010b25f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b262:	8b 90 98 00 00 00    	mov    0x98(%eax),%edx
c010b268:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b26b:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
c010b271:	29 c2                	sub    %eax,%edx
c010b273:	89 d0                	mov    %edx,%eax
c010b275:	89 45 f4             	mov    %eax,-0xc(%ebp)
     if (c > 0) return 1;
c010b278:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010b27c:	7e 07                	jle    c010b285 <proc_stride_comp_f+0x42>
c010b27e:	b8 01 00 00 00       	mov    $0x1,%eax
c010b283:	eb 12                	jmp    c010b297 <proc_stride_comp_f+0x54>
     else if (c == 0) return 0;
c010b285:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010b289:	75 07                	jne    c010b292 <proc_stride_comp_f+0x4f>
c010b28b:	b8 00 00 00 00       	mov    $0x0,%eax
c010b290:	eb 05                	jmp    c010b297 <proc_stride_comp_f+0x54>
     else return -1;
c010b292:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
c010b297:	c9                   	leave  
c010b298:	c3                   	ret    

c010b299 <stride_init>:
 *   - max_time_slice: no need here, the variable would be assigned by the caller.
 *
 * hint: see libs/list.h for routines of the list structures.
 */
static void
stride_init(struct run_queue *rq) {
c010b299:	55                   	push   %ebp
c010b29a:	89 e5                	mov    %esp,%ebp
c010b29c:	83 ec 10             	sub    $0x10,%esp
     /* LAB6: YOUR CODE 
      * (1) init the ready process list: rq->run_list
      * (2) init the run pool: rq->lab6_run_pool
      * (3) set number of process: rq->proc_num to 0       
      */
     list_init(&(rq->run_list)); //初始化调度器类   这是双向链表！！！
c010b29f:	8b 45 08             	mov    0x8(%ebp),%eax
c010b2a2:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010b2a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b2a8:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010b2ab:	89 50 04             	mov    %edx,0x4(%eax)
c010b2ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b2b1:	8b 50 04             	mov    0x4(%eax),%edx
c010b2b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b2b7:	89 10                	mov    %edx,(%eax)
     rq->lab6_run_pool = NULL; //初始化当前进程运行的优先队列为空
c010b2b9:	8b 45 08             	mov    0x8(%ebp),%eax
c010b2bc:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
     rq->proc_num = 0; //设置运行队列为空
c010b2c3:	8b 45 08             	mov    0x8(%ebp),%eax
c010b2c6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    //max_time_slice会被调度的函数初始化（shed.c) 
}
c010b2cd:	c9                   	leave  
c010b2ce:	c3                   	ret    

c010b2cf <stride_enqueue>:
 * 
 * hint: see libs/skew_heap.h for routines of the priority
 * queue structures.
 */
static void
stride_enqueue(struct run_queue *rq, struct proc_struct *proc) {
c010b2cf:	55                   	push   %ebp
c010b2d0:	89 e5                	mov    %esp,%ebp
c010b2d2:	83 ec 28             	sub    $0x28,%esp
      *         list_add_before: insert  a entry into the last of list   
      * (2) recalculate proc->time_slice
      * (3) set proc->rq pointer to rq
      * (4) increase rq->proc_num
      */
     rq->lab6_run_pool = skew_heap_insert(rq->lab6_run_pool, &(proc->lab6_run_pool), proc_stride_comp_f);
c010b2d5:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b2d8:	8d 90 8c 00 00 00    	lea    0x8c(%eax),%edx
c010b2de:	8b 45 08             	mov    0x8(%ebp),%eax
c010b2e1:	8b 40 10             	mov    0x10(%eax),%eax
c010b2e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b2e7:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010b2ea:	c7 45 ec 43 b2 10 c0 	movl   $0xc010b243,-0x14(%ebp)
c010b2f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b2f4:	89 45 e8             	mov    %eax,-0x18(%ebp)
     a->left = a->right = a->parent = NULL;
c010b2f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b2fa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c010b300:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b303:	8b 10                	mov    (%eax),%edx
c010b305:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b308:	89 50 08             	mov    %edx,0x8(%eax)
c010b30b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b30e:	8b 50 08             	mov    0x8(%eax),%edx
c010b311:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b314:	89 50 04             	mov    %edx,0x4(%eax)
static inline skew_heap_entry_t *
skew_heap_insert(skew_heap_entry_t *a, skew_heap_entry_t *b,
                 compare_f comp)
{
     skew_heap_init(b);
     return skew_heap_merge(a, b, comp);
c010b317:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b31a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b31e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b321:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b325:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b328:	89 04 24             	mov    %eax,(%esp)
c010b32b:	e8 40 fe ff ff       	call   c010b170 <skew_heap_merge>
c010b330:	89 c2                	mov    %eax,%edx
c010b332:	8b 45 08             	mov    0x8(%ebp),%eax
c010b335:	89 50 10             	mov    %edx,0x10(%eax)
    //斜堆将进程插入就绪队列
    if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
c010b338:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b33b:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
c010b341:	85 c0                	test   %eax,%eax
c010b343:	74 13                	je     c010b358 <stride_enqueue+0x89>
c010b345:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b348:	8b 90 88 00 00 00    	mov    0x88(%eax),%edx
c010b34e:	8b 45 08             	mov    0x8(%ebp),%eax
c010b351:	8b 40 0c             	mov    0xc(%eax),%eax
c010b354:	39 c2                	cmp    %eax,%edx
c010b356:	7e 0f                	jle    c010b367 <stride_enqueue+0x98>
          proc->time_slice = rq->max_time_slice;//重新指定时间片
c010b358:	8b 45 08             	mov    0x8(%ebp),%eax
c010b35b:	8b 50 0c             	mov    0xc(%eax),%edx
c010b35e:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b361:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
     }
     proc->rq = rq;//更新就绪队列
c010b367:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b36a:	8b 55 08             	mov    0x8(%ebp),%edx
c010b36d:	89 50 7c             	mov    %edx,0x7c(%eax)
     rq->proc_num ++;//就绪队列中进程数+1
c010b370:	8b 45 08             	mov    0x8(%ebp),%eax
c010b373:	8b 40 08             	mov    0x8(%eax),%eax
c010b376:	8d 50 01             	lea    0x1(%eax),%edx
c010b379:	8b 45 08             	mov    0x8(%ebp),%eax
c010b37c:	89 50 08             	mov    %edx,0x8(%eax)
}
c010b37f:	c9                   	leave  
c010b380:	c3                   	ret    

c010b381 <stride_dequeue>:
 *
 * hint: see libs/skew_heap.h for routines of the priority
 * queue structures.
 */
static void
stride_dequeue(struct run_queue *rq, struct proc_struct *proc) {
c010b381:	55                   	push   %ebp
c010b382:	89 e5                	mov    %esp,%ebp
c010b384:	83 ec 38             	sub    $0x38,%esp
      * (1) remove the proc from rq correctly
      * NOTICE: you can use skew_heap or list. Important functions
      *         skew_heap_remove: remove a entry from skew_heap
      *         list_del_init: remove a entry from the  list
      */
     rq->lab6_run_pool =skew_heap_remove(rq->lab6_run_pool, &(proc->lab6_run_pool), proc_stride_comp_f);
c010b387:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b38a:	8d 90 8c 00 00 00    	lea    0x8c(%eax),%edx
c010b390:	8b 45 08             	mov    0x8(%ebp),%eax
c010b393:	8b 40 10             	mov    0x10(%eax),%eax
c010b396:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b399:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010b39c:	c7 45 ec 43 b2 10 c0 	movl   $0xc010b243,-0x14(%ebp)

static inline skew_heap_entry_t *
skew_heap_remove(skew_heap_entry_t *a, skew_heap_entry_t *b,
                 compare_f comp)
{
     skew_heap_entry_t *p   = b->parent;
c010b3a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b3a6:	8b 00                	mov    (%eax),%eax
c010b3a8:	89 45 e8             	mov    %eax,-0x18(%ebp)
     skew_heap_entry_t *rep = skew_heap_merge(b->left, b->right, comp);
c010b3ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b3ae:	8b 50 08             	mov    0x8(%eax),%edx
c010b3b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b3b4:	8b 40 04             	mov    0x4(%eax),%eax
c010b3b7:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c010b3ba:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c010b3be:	89 54 24 04          	mov    %edx,0x4(%esp)
c010b3c2:	89 04 24             	mov    %eax,(%esp)
c010b3c5:	e8 a6 fd ff ff       	call   c010b170 <skew_heap_merge>
c010b3ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
     if (rep) rep->parent = p;
c010b3cd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010b3d1:	74 08                	je     c010b3db <stride_dequeue+0x5a>
c010b3d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010b3d6:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010b3d9:	89 10                	mov    %edx,(%eax)
     
     if (p)
c010b3db:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010b3df:	74 24                	je     c010b405 <stride_dequeue+0x84>
     {
          if (p->left == b)
c010b3e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b3e4:	8b 40 04             	mov    0x4(%eax),%eax
c010b3e7:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010b3ea:	75 0b                	jne    c010b3f7 <stride_dequeue+0x76>
               p->left = rep;
c010b3ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b3ef:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010b3f2:	89 50 04             	mov    %edx,0x4(%eax)
c010b3f5:	eb 09                	jmp    c010b400 <stride_dequeue+0x7f>
          else p->right = rep;
c010b3f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b3fa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010b3fd:	89 50 08             	mov    %edx,0x8(%eax)
          return a;
c010b400:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b403:	eb 03                	jmp    c010b408 <stride_dequeue+0x87>
     }
     else return rep;
c010b405:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010b408:	89 c2                	mov    %eax,%edx
c010b40a:	8b 45 08             	mov    0x8(%ebp),%eax
c010b40d:	89 50 10             	mov    %edx,0x10(%eax)
     rq->proc_num --;//就绪队列数目-1
c010b410:	8b 45 08             	mov    0x8(%ebp),%eax
c010b413:	8b 40 08             	mov    0x8(%eax),%eax
c010b416:	8d 50 ff             	lea    -0x1(%eax),%edx
c010b419:	8b 45 08             	mov    0x8(%ebp),%eax
c010b41c:	89 50 08             	mov    %edx,0x8(%eax)
}
c010b41f:	c9                   	leave  
c010b420:	c3                   	ret    

c010b421 <stride_pick_next>:
 *
 * hint: see libs/skew_heap.h for routines of the priority
 * queue structures.
 */
static struct proc_struct *
stride_pick_next(struct run_queue *rq) {
c010b421:	55                   	push   %ebp
c010b422:	89 e5                	mov    %esp,%ebp
c010b424:	53                   	push   %ebx
c010b425:	83 ec 10             	sub    $0x10,%esp
             (1.1) If using skew_heap, we can use le2proc get the p from rq->lab6_run_poll
             (1.2) If using list, we have to search list to find the p with minimum stride value
      * (2) update p;s stride value: p->lab6_stride
      * (3) return p
      */
     if (rq->lab6_run_pool == NULL) return NULL; 
c010b428:	8b 45 08             	mov    0x8(%ebp),%eax
c010b42b:	8b 40 10             	mov    0x10(%eax),%eax
c010b42e:	85 c0                	test   %eax,%eax
c010b430:	75 07                	jne    c010b439 <stride_pick_next+0x18>
c010b432:	b8 00 00 00 00       	mov    $0x0,%eax
c010b437:	eb 62                	jmp    c010b49b <stride_pick_next+0x7a>
	struct proc_struct *p = le2proc(rq->lab6_run_pool, lab6_run_pool); // 选择stride值最小的进程-----根节点最小
c010b439:	8b 45 08             	mov    0x8(%ebp),%eax
c010b43c:	8b 40 10             	mov    0x10(%eax),%eax
c010b43f:	2d 8c 00 00 00       	sub    $0x8c,%eax
c010b444:	89 45 f8             	mov    %eax,-0x8(%ebp)
	if (p->lab6_priority == 0){      //   防止异常   优先级为0  
c010b447:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b44a:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
c010b450:	85 c0                	test   %eax,%eax
c010b452:	75 1a                	jne    c010b46e <stride_pick_next+0x4d>
        p->lab6_stride += BIG_STRIDE;}//就设步长为最大值这样就不会被执行
c010b454:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b457:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
c010b45d:	8d 90 ff ff ff 7f    	lea    0x7fffffff(%eax),%edx
c010b463:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b466:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)
c010b46c:	eb 2a                	jmp    c010b498 <stride_pick_next+0x77>
     else p->lab6_stride += BIG_STRIDE / p->lab6_priority;
c010b46e:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b471:	8b 88 98 00 00 00    	mov    0x98(%eax),%ecx
c010b477:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b47a:	8b 98 9c 00 00 00    	mov    0x9c(%eax),%ebx
c010b480:	b8 ff ff ff 7f       	mov    $0x7fffffff,%eax
c010b485:	ba 00 00 00 00       	mov    $0x0,%edx
c010b48a:	f7 f3                	div    %ebx
c010b48c:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c010b48f:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b492:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)
     return p;
c010b498:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c010b49b:	83 c4 10             	add    $0x10,%esp
c010b49e:	5b                   	pop    %ebx
c010b49f:	5d                   	pop    %ebp
c010b4a0:	c3                   	ret    

c010b4a1 <stride_proc_tick>:
 * denotes the time slices left for current
 * process. proc->need_resched is the flag variable for process
 * switching.
 */
static void
stride_proc_tick(struct run_queue *rq, struct proc_struct *proc) {
c010b4a1:	55                   	push   %ebp
c010b4a2:	89 e5                	mov    %esp,%ebp
     /* LAB6: YOUR CODE */
     if (proc->time_slice > 0) {
c010b4a4:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b4a7:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
c010b4ad:	85 c0                	test   %eax,%eax
c010b4af:	7e 15                	jle    c010b4c6 <stride_proc_tick+0x25>
          proc->time_slice --;
c010b4b1:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b4b4:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
c010b4ba:	8d 50 ff             	lea    -0x1(%eax),%edx
c010b4bd:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b4c0:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
     }
     if (proc->time_slice == 0) {
c010b4c6:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b4c9:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
c010b4cf:	85 c0                	test   %eax,%eax
c010b4d1:	75 0a                	jne    c010b4dd <stride_proc_tick+0x3c>
          proc->need_resched = 1;
c010b4d3:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b4d6:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
     }
}
c010b4dd:	5d                   	pop    %ebp
c010b4de:	c3                   	ret    

c010b4df <sys_exit>:
#include <pmm.h>
#include <assert.h>
#include <clock.h>

static int
sys_exit(uint32_t arg[]) {
c010b4df:	55                   	push   %ebp
c010b4e0:	89 e5                	mov    %esp,%ebp
c010b4e2:	83 ec 28             	sub    $0x28,%esp
    int error_code = (int)arg[0];
c010b4e5:	8b 45 08             	mov    0x8(%ebp),%eax
c010b4e8:	8b 00                	mov    (%eax),%eax
c010b4ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return do_exit(error_code);
c010b4ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b4f0:	89 04 24             	mov    %eax,(%esp)
c010b4f3:	e8 72 ea ff ff       	call   c0109f6a <do_exit>
}
c010b4f8:	c9                   	leave  
c010b4f9:	c3                   	ret    

c010b4fa <sys_fork>:

static int
sys_fork(uint32_t arg[]) {
c010b4fa:	55                   	push   %ebp
c010b4fb:	89 e5                	mov    %esp,%ebp
c010b4fd:	83 ec 28             	sub    $0x28,%esp
    struct trapframe *tf = current->tf;
c010b500:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010b505:	8b 40 3c             	mov    0x3c(%eax),%eax
c010b508:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uintptr_t stack = tf->tf_esp;
c010b50b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b50e:	8b 40 44             	mov    0x44(%eax),%eax
c010b511:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return do_fork(0, stack, tf);
c010b514:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b517:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b51b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b51e:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b522:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010b529:	e8 1b e9 ff ff       	call   c0109e49 <do_fork>
}
c010b52e:	c9                   	leave  
c010b52f:	c3                   	ret    

c010b530 <sys_wait>:

static int
sys_wait(uint32_t arg[]) {
c010b530:	55                   	push   %ebp
c010b531:	89 e5                	mov    %esp,%ebp
c010b533:	83 ec 28             	sub    $0x28,%esp
    int pid = (int)arg[0];
c010b536:	8b 45 08             	mov    0x8(%ebp),%eax
c010b539:	8b 00                	mov    (%eax),%eax
c010b53b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int *store = (int *)arg[1];
c010b53e:	8b 45 08             	mov    0x8(%ebp),%eax
c010b541:	83 c0 04             	add    $0x4,%eax
c010b544:	8b 00                	mov    (%eax),%eax
c010b546:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return do_wait(pid, store);
c010b549:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b54c:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b550:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b553:	89 04 24             	mov    %eax,(%esp)
c010b556:	e8 8d f3 ff ff       	call   c010a8e8 <do_wait>
}
c010b55b:	c9                   	leave  
c010b55c:	c3                   	ret    

c010b55d <sys_exec>:

static int
sys_exec(uint32_t arg[]) {
c010b55d:	55                   	push   %ebp
c010b55e:	89 e5                	mov    %esp,%ebp
c010b560:	83 ec 28             	sub    $0x28,%esp
    const char *name = (const char *)arg[0];
c010b563:	8b 45 08             	mov    0x8(%ebp),%eax
c010b566:	8b 00                	mov    (%eax),%eax
c010b568:	89 45 f4             	mov    %eax,-0xc(%ebp)
    size_t len = (size_t)arg[1];
c010b56b:	8b 45 08             	mov    0x8(%ebp),%eax
c010b56e:	8b 40 04             	mov    0x4(%eax),%eax
c010b571:	89 45 f0             	mov    %eax,-0x10(%ebp)
    unsigned char *binary = (unsigned char *)arg[2];
c010b574:	8b 45 08             	mov    0x8(%ebp),%eax
c010b577:	83 c0 08             	add    $0x8,%eax
c010b57a:	8b 00                	mov    (%eax),%eax
c010b57c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    size_t size = (size_t)arg[3];
c010b57f:	8b 45 08             	mov    0x8(%ebp),%eax
c010b582:	8b 40 0c             	mov    0xc(%eax),%eax
c010b585:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return do_execve(name, len, binary, size);
c010b588:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b58b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010b58f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b592:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b596:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b599:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b59d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b5a0:	89 04 24             	mov    %eax,(%esp)
c010b5a3:	e8 f4 f1 ff ff       	call   c010a79c <do_execve>
}
c010b5a8:	c9                   	leave  
c010b5a9:	c3                   	ret    

c010b5aa <sys_yield>:

static int
sys_yield(uint32_t arg[]) {
c010b5aa:	55                   	push   %ebp
c010b5ab:	89 e5                	mov    %esp,%ebp
c010b5ad:	83 ec 08             	sub    $0x8,%esp
    return do_yield();
c010b5b0:	e8 1d f3 ff ff       	call   c010a8d2 <do_yield>
}
c010b5b5:	c9                   	leave  
c010b5b6:	c3                   	ret    

c010b5b7 <sys_kill>:

static int
sys_kill(uint32_t arg[]) {
c010b5b7:	55                   	push   %ebp
c010b5b8:	89 e5                	mov    %esp,%ebp
c010b5ba:	83 ec 28             	sub    $0x28,%esp
    int pid = (int)arg[0];
c010b5bd:	8b 45 08             	mov    0x8(%ebp),%eax
c010b5c0:	8b 00                	mov    (%eax),%eax
c010b5c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return do_kill(pid);
c010b5c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b5c8:	89 04 24             	mov    %eax,(%esp)
c010b5cb:	e8 ac f4 ff ff       	call   c010aa7c <do_kill>
}
c010b5d0:	c9                   	leave  
c010b5d1:	c3                   	ret    

c010b5d2 <sys_getpid>:

static int
sys_getpid(uint32_t arg[]) {
c010b5d2:	55                   	push   %ebp
c010b5d3:	89 e5                	mov    %esp,%ebp
    return current->pid;
c010b5d5:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010b5da:	8b 40 04             	mov    0x4(%eax),%eax
}
c010b5dd:	5d                   	pop    %ebp
c010b5de:	c3                   	ret    

c010b5df <sys_putc>:

static int
sys_putc(uint32_t arg[]) {
c010b5df:	55                   	push   %ebp
c010b5e0:	89 e5                	mov    %esp,%ebp
c010b5e2:	83 ec 28             	sub    $0x28,%esp
    int c = (int)arg[0];
c010b5e5:	8b 45 08             	mov    0x8(%ebp),%eax
c010b5e8:	8b 00                	mov    (%eax),%eax
c010b5ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cputchar(c);
c010b5ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b5f0:	89 04 24             	mov    %eax,(%esp)
c010b5f3:	e8 dc 4c ff ff       	call   c01002d4 <cputchar>
    return 0;
c010b5f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b5fd:	c9                   	leave  
c010b5fe:	c3                   	ret    

c010b5ff <sys_pgdir>:

static int
sys_pgdir(uint32_t arg[]) {
c010b5ff:	55                   	push   %ebp
c010b600:	89 e5                	mov    %esp,%ebp
c010b602:	83 ec 08             	sub    $0x8,%esp
    print_pgdir();
c010b605:	e8 1d d9 ff ff       	call   c0108f27 <print_pgdir>
    return 0;
c010b60a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b60f:	c9                   	leave  
c010b610:	c3                   	ret    

c010b611 <sys_gettime>:

static int
sys_gettime(uint32_t arg[]) {
c010b611:	55                   	push   %ebp
c010b612:	89 e5                	mov    %esp,%ebp
    return (int)ticks;
c010b614:	a1 78 30 1b c0       	mov    0xc01b3078,%eax
}
c010b619:	5d                   	pop    %ebp
c010b61a:	c3                   	ret    

c010b61b <sys_lab6_set_priority>:
static int
sys_lab6_set_priority(uint32_t arg[])
{
c010b61b:	55                   	push   %ebp
c010b61c:	89 e5                	mov    %esp,%ebp
c010b61e:	83 ec 28             	sub    $0x28,%esp
    uint32_t priority = (uint32_t)arg[0];
c010b621:	8b 45 08             	mov    0x8(%ebp),%eax
c010b624:	8b 00                	mov    (%eax),%eax
c010b626:	89 45 f4             	mov    %eax,-0xc(%ebp)
    lab6_set_priority(priority);
c010b629:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b62c:	89 04 24             	mov    %eax,(%esp)
c010b62f:	e8 a3 f8 ff ff       	call   c010aed7 <lab6_set_priority>
    return 0;
c010b634:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b639:	c9                   	leave  
c010b63a:	c3                   	ret    

c010b63b <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
c010b63b:	55                   	push   %ebp
c010b63c:	89 e5                	mov    %esp,%ebp
c010b63e:	83 ec 48             	sub    $0x48,%esp
    struct trapframe *tf = current->tf;
c010b641:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010b646:	8b 40 3c             	mov    0x3c(%eax),%eax
c010b649:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uint32_t arg[5];
    int num = tf->tf_regs.reg_eax;
c010b64c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b64f:	8b 40 1c             	mov    0x1c(%eax),%eax
c010b652:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (num >= 0 && num < NUM_SYSCALLS) {
c010b655:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010b659:	78 60                	js     c010b6bb <syscall+0x80>
c010b65b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b65e:	3d ff 00 00 00       	cmp    $0xff,%eax
c010b663:	77 56                	ja     c010b6bb <syscall+0x80>
        if (syscalls[num] != NULL) {
c010b665:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b668:	8b 04 85 a0 ca 12 c0 	mov    -0x3fed3560(,%eax,4),%eax
c010b66f:	85 c0                	test   %eax,%eax
c010b671:	74 48                	je     c010b6bb <syscall+0x80>
            arg[0] = tf->tf_regs.reg_edx;
c010b673:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b676:	8b 40 14             	mov    0x14(%eax),%eax
c010b679:	89 45 dc             	mov    %eax,-0x24(%ebp)
            arg[1] = tf->tf_regs.reg_ecx;
c010b67c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b67f:	8b 40 18             	mov    0x18(%eax),%eax
c010b682:	89 45 e0             	mov    %eax,-0x20(%ebp)
            arg[2] = tf->tf_regs.reg_ebx;
c010b685:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b688:	8b 40 10             	mov    0x10(%eax),%eax
c010b68b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            arg[3] = tf->tf_regs.reg_edi;
c010b68e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b691:	8b 00                	mov    (%eax),%eax
c010b693:	89 45 e8             	mov    %eax,-0x18(%ebp)
            arg[4] = tf->tf_regs.reg_esi;
c010b696:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b699:	8b 40 04             	mov    0x4(%eax),%eax
c010b69c:	89 45 ec             	mov    %eax,-0x14(%ebp)
            tf->tf_regs.reg_eax = syscalls[num](arg);
c010b69f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b6a2:	8b 04 85 a0 ca 12 c0 	mov    -0x3fed3560(,%eax,4),%eax
c010b6a9:	8d 55 dc             	lea    -0x24(%ebp),%edx
c010b6ac:	89 14 24             	mov    %edx,(%esp)
c010b6af:	ff d0                	call   *%eax
c010b6b1:	89 c2                	mov    %eax,%edx
c010b6b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b6b6:	89 50 1c             	mov    %edx,0x1c(%eax)
            return ;
c010b6b9:	eb 46                	jmp    c010b701 <syscall+0xc6>
        }
    }
    print_trapframe(tf);
c010b6bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b6be:	89 04 24             	mov    %eax,(%esp)
c010b6c1:	e8 51 6d ff ff       	call   c0102417 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
c010b6c6:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010b6cb:	8d 50 48             	lea    0x48(%eax),%edx
c010b6ce:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010b6d3:	8b 40 04             	mov    0x4(%eax),%eax
c010b6d6:	89 54 24 14          	mov    %edx,0x14(%esp)
c010b6da:	89 44 24 10          	mov    %eax,0x10(%esp)
c010b6de:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b6e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010b6e5:	c7 44 24 08 b8 e8 10 	movl   $0xc010e8b8,0x8(%esp)
c010b6ec:	c0 
c010b6ed:	c7 44 24 04 72 00 00 	movl   $0x72,0x4(%esp)
c010b6f4:	00 
c010b6f5:	c7 04 24 e4 e8 10 c0 	movl   $0xc010e8e4,(%esp)
c010b6fc:	e8 04 4d ff ff       	call   c0100405 <__panic>
            num, current->pid, current->name);
}
c010b701:	c9                   	leave  
c010b702:	c3                   	ret    

c010b703 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c010b703:	55                   	push   %ebp
c010b704:	89 e5                	mov    %esp,%ebp
c010b706:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010b709:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c010b710:	eb 04                	jmp    c010b716 <strlen+0x13>
        cnt ++;
c010b712:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (*s ++ != '\0') {
c010b716:	8b 45 08             	mov    0x8(%ebp),%eax
c010b719:	8d 50 01             	lea    0x1(%eax),%edx
c010b71c:	89 55 08             	mov    %edx,0x8(%ebp)
c010b71f:	0f b6 00             	movzbl (%eax),%eax
c010b722:	84 c0                	test   %al,%al
c010b724:	75 ec                	jne    c010b712 <strlen+0xf>
    }
    return cnt;
c010b726:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010b729:	c9                   	leave  
c010b72a:	c3                   	ret    

c010b72b <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c010b72b:	55                   	push   %ebp
c010b72c:	89 e5                	mov    %esp,%ebp
c010b72e:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010b731:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c010b738:	eb 04                	jmp    c010b73e <strnlen+0x13>
        cnt ++;
c010b73a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c010b73e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b741:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010b744:	73 10                	jae    c010b756 <strnlen+0x2b>
c010b746:	8b 45 08             	mov    0x8(%ebp),%eax
c010b749:	8d 50 01             	lea    0x1(%eax),%edx
c010b74c:	89 55 08             	mov    %edx,0x8(%ebp)
c010b74f:	0f b6 00             	movzbl (%eax),%eax
c010b752:	84 c0                	test   %al,%al
c010b754:	75 e4                	jne    c010b73a <strnlen+0xf>
    }
    return cnt;
c010b756:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010b759:	c9                   	leave  
c010b75a:	c3                   	ret    

c010b75b <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c010b75b:	55                   	push   %ebp
c010b75c:	89 e5                	mov    %esp,%ebp
c010b75e:	57                   	push   %edi
c010b75f:	56                   	push   %esi
c010b760:	83 ec 20             	sub    $0x20,%esp
c010b763:	8b 45 08             	mov    0x8(%ebp),%eax
c010b766:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b769:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b76c:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c010b76f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010b772:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b775:	89 d1                	mov    %edx,%ecx
c010b777:	89 c2                	mov    %eax,%edx
c010b779:	89 ce                	mov    %ecx,%esi
c010b77b:	89 d7                	mov    %edx,%edi
c010b77d:	ac                   	lods   %ds:(%esi),%al
c010b77e:	aa                   	stos   %al,%es:(%edi)
c010b77f:	84 c0                	test   %al,%al
c010b781:	75 fa                	jne    c010b77d <strcpy+0x22>
c010b783:	89 fa                	mov    %edi,%edx
c010b785:	89 f1                	mov    %esi,%ecx
c010b787:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010b78a:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010b78d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c010b790:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c010b793:	83 c4 20             	add    $0x20,%esp
c010b796:	5e                   	pop    %esi
c010b797:	5f                   	pop    %edi
c010b798:	5d                   	pop    %ebp
c010b799:	c3                   	ret    

c010b79a <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c010b79a:	55                   	push   %ebp
c010b79b:	89 e5                	mov    %esp,%ebp
c010b79d:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c010b7a0:	8b 45 08             	mov    0x8(%ebp),%eax
c010b7a3:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c010b7a6:	eb 21                	jmp    c010b7c9 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
c010b7a8:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b7ab:	0f b6 10             	movzbl (%eax),%edx
c010b7ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b7b1:	88 10                	mov    %dl,(%eax)
c010b7b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b7b6:	0f b6 00             	movzbl (%eax),%eax
c010b7b9:	84 c0                	test   %al,%al
c010b7bb:	74 04                	je     c010b7c1 <strncpy+0x27>
            src ++;
c010b7bd:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
c010b7c1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010b7c5:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    while (len > 0) {
c010b7c9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b7cd:	75 d9                	jne    c010b7a8 <strncpy+0xe>
    }
    return dst;
c010b7cf:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010b7d2:	c9                   	leave  
c010b7d3:	c3                   	ret    

c010b7d4 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c010b7d4:	55                   	push   %ebp
c010b7d5:	89 e5                	mov    %esp,%ebp
c010b7d7:	57                   	push   %edi
c010b7d8:	56                   	push   %esi
c010b7d9:	83 ec 20             	sub    $0x20,%esp
c010b7dc:	8b 45 08             	mov    0x8(%ebp),%eax
c010b7df:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b7e2:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b7e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c010b7e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b7eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b7ee:	89 d1                	mov    %edx,%ecx
c010b7f0:	89 c2                	mov    %eax,%edx
c010b7f2:	89 ce                	mov    %ecx,%esi
c010b7f4:	89 d7                	mov    %edx,%edi
c010b7f6:	ac                   	lods   %ds:(%esi),%al
c010b7f7:	ae                   	scas   %es:(%edi),%al
c010b7f8:	75 08                	jne    c010b802 <strcmp+0x2e>
c010b7fa:	84 c0                	test   %al,%al
c010b7fc:	75 f8                	jne    c010b7f6 <strcmp+0x22>
c010b7fe:	31 c0                	xor    %eax,%eax
c010b800:	eb 04                	jmp    c010b806 <strcmp+0x32>
c010b802:	19 c0                	sbb    %eax,%eax
c010b804:	0c 01                	or     $0x1,%al
c010b806:	89 fa                	mov    %edi,%edx
c010b808:	89 f1                	mov    %esi,%ecx
c010b80a:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010b80d:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010b810:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c010b813:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c010b816:	83 c4 20             	add    $0x20,%esp
c010b819:	5e                   	pop    %esi
c010b81a:	5f                   	pop    %edi
c010b81b:	5d                   	pop    %ebp
c010b81c:	c3                   	ret    

c010b81d <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c010b81d:	55                   	push   %ebp
c010b81e:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010b820:	eb 0c                	jmp    c010b82e <strncmp+0x11>
        n --, s1 ++, s2 ++;
c010b822:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010b826:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010b82a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010b82e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b832:	74 1a                	je     c010b84e <strncmp+0x31>
c010b834:	8b 45 08             	mov    0x8(%ebp),%eax
c010b837:	0f b6 00             	movzbl (%eax),%eax
c010b83a:	84 c0                	test   %al,%al
c010b83c:	74 10                	je     c010b84e <strncmp+0x31>
c010b83e:	8b 45 08             	mov    0x8(%ebp),%eax
c010b841:	0f b6 10             	movzbl (%eax),%edx
c010b844:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b847:	0f b6 00             	movzbl (%eax),%eax
c010b84a:	38 c2                	cmp    %al,%dl
c010b84c:	74 d4                	je     c010b822 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c010b84e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b852:	74 18                	je     c010b86c <strncmp+0x4f>
c010b854:	8b 45 08             	mov    0x8(%ebp),%eax
c010b857:	0f b6 00             	movzbl (%eax),%eax
c010b85a:	0f b6 d0             	movzbl %al,%edx
c010b85d:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b860:	0f b6 00             	movzbl (%eax),%eax
c010b863:	0f b6 c0             	movzbl %al,%eax
c010b866:	29 c2                	sub    %eax,%edx
c010b868:	89 d0                	mov    %edx,%eax
c010b86a:	eb 05                	jmp    c010b871 <strncmp+0x54>
c010b86c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b871:	5d                   	pop    %ebp
c010b872:	c3                   	ret    

c010b873 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c010b873:	55                   	push   %ebp
c010b874:	89 e5                	mov    %esp,%ebp
c010b876:	83 ec 04             	sub    $0x4,%esp
c010b879:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b87c:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010b87f:	eb 14                	jmp    c010b895 <strchr+0x22>
        if (*s == c) {
c010b881:	8b 45 08             	mov    0x8(%ebp),%eax
c010b884:	0f b6 00             	movzbl (%eax),%eax
c010b887:	3a 45 fc             	cmp    -0x4(%ebp),%al
c010b88a:	75 05                	jne    c010b891 <strchr+0x1e>
            return (char *)s;
c010b88c:	8b 45 08             	mov    0x8(%ebp),%eax
c010b88f:	eb 13                	jmp    c010b8a4 <strchr+0x31>
        }
        s ++;
c010b891:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
c010b895:	8b 45 08             	mov    0x8(%ebp),%eax
c010b898:	0f b6 00             	movzbl (%eax),%eax
c010b89b:	84 c0                	test   %al,%al
c010b89d:	75 e2                	jne    c010b881 <strchr+0xe>
    }
    return NULL;
c010b89f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b8a4:	c9                   	leave  
c010b8a5:	c3                   	ret    

c010b8a6 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c010b8a6:	55                   	push   %ebp
c010b8a7:	89 e5                	mov    %esp,%ebp
c010b8a9:	83 ec 04             	sub    $0x4,%esp
c010b8ac:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b8af:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010b8b2:	eb 11                	jmp    c010b8c5 <strfind+0x1f>
        if (*s == c) {
c010b8b4:	8b 45 08             	mov    0x8(%ebp),%eax
c010b8b7:	0f b6 00             	movzbl (%eax),%eax
c010b8ba:	3a 45 fc             	cmp    -0x4(%ebp),%al
c010b8bd:	75 02                	jne    c010b8c1 <strfind+0x1b>
            break;
c010b8bf:	eb 0e                	jmp    c010b8cf <strfind+0x29>
        }
        s ++;
c010b8c1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
c010b8c5:	8b 45 08             	mov    0x8(%ebp),%eax
c010b8c8:	0f b6 00             	movzbl (%eax),%eax
c010b8cb:	84 c0                	test   %al,%al
c010b8cd:	75 e5                	jne    c010b8b4 <strfind+0xe>
    }
    return (char *)s;
c010b8cf:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010b8d2:	c9                   	leave  
c010b8d3:	c3                   	ret    

c010b8d4 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c010b8d4:	55                   	push   %ebp
c010b8d5:	89 e5                	mov    %esp,%ebp
c010b8d7:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c010b8da:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c010b8e1:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c010b8e8:	eb 04                	jmp    c010b8ee <strtol+0x1a>
        s ++;
c010b8ea:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c010b8ee:	8b 45 08             	mov    0x8(%ebp),%eax
c010b8f1:	0f b6 00             	movzbl (%eax),%eax
c010b8f4:	3c 20                	cmp    $0x20,%al
c010b8f6:	74 f2                	je     c010b8ea <strtol+0x16>
c010b8f8:	8b 45 08             	mov    0x8(%ebp),%eax
c010b8fb:	0f b6 00             	movzbl (%eax),%eax
c010b8fe:	3c 09                	cmp    $0x9,%al
c010b900:	74 e8                	je     c010b8ea <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
c010b902:	8b 45 08             	mov    0x8(%ebp),%eax
c010b905:	0f b6 00             	movzbl (%eax),%eax
c010b908:	3c 2b                	cmp    $0x2b,%al
c010b90a:	75 06                	jne    c010b912 <strtol+0x3e>
        s ++;
c010b90c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010b910:	eb 15                	jmp    c010b927 <strtol+0x53>
    }
    else if (*s == '-') {
c010b912:	8b 45 08             	mov    0x8(%ebp),%eax
c010b915:	0f b6 00             	movzbl (%eax),%eax
c010b918:	3c 2d                	cmp    $0x2d,%al
c010b91a:	75 0b                	jne    c010b927 <strtol+0x53>
        s ++, neg = 1;
c010b91c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010b920:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c010b927:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b92b:	74 06                	je     c010b933 <strtol+0x5f>
c010b92d:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c010b931:	75 24                	jne    c010b957 <strtol+0x83>
c010b933:	8b 45 08             	mov    0x8(%ebp),%eax
c010b936:	0f b6 00             	movzbl (%eax),%eax
c010b939:	3c 30                	cmp    $0x30,%al
c010b93b:	75 1a                	jne    c010b957 <strtol+0x83>
c010b93d:	8b 45 08             	mov    0x8(%ebp),%eax
c010b940:	83 c0 01             	add    $0x1,%eax
c010b943:	0f b6 00             	movzbl (%eax),%eax
c010b946:	3c 78                	cmp    $0x78,%al
c010b948:	75 0d                	jne    c010b957 <strtol+0x83>
        s += 2, base = 16;
c010b94a:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c010b94e:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c010b955:	eb 2a                	jmp    c010b981 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
c010b957:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b95b:	75 17                	jne    c010b974 <strtol+0xa0>
c010b95d:	8b 45 08             	mov    0x8(%ebp),%eax
c010b960:	0f b6 00             	movzbl (%eax),%eax
c010b963:	3c 30                	cmp    $0x30,%al
c010b965:	75 0d                	jne    c010b974 <strtol+0xa0>
        s ++, base = 8;
c010b967:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010b96b:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c010b972:	eb 0d                	jmp    c010b981 <strtol+0xad>
    }
    else if (base == 0) {
c010b974:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b978:	75 07                	jne    c010b981 <strtol+0xad>
        base = 10;
c010b97a:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c010b981:	8b 45 08             	mov    0x8(%ebp),%eax
c010b984:	0f b6 00             	movzbl (%eax),%eax
c010b987:	3c 2f                	cmp    $0x2f,%al
c010b989:	7e 1b                	jle    c010b9a6 <strtol+0xd2>
c010b98b:	8b 45 08             	mov    0x8(%ebp),%eax
c010b98e:	0f b6 00             	movzbl (%eax),%eax
c010b991:	3c 39                	cmp    $0x39,%al
c010b993:	7f 11                	jg     c010b9a6 <strtol+0xd2>
            dig = *s - '0';
c010b995:	8b 45 08             	mov    0x8(%ebp),%eax
c010b998:	0f b6 00             	movzbl (%eax),%eax
c010b99b:	0f be c0             	movsbl %al,%eax
c010b99e:	83 e8 30             	sub    $0x30,%eax
c010b9a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b9a4:	eb 48                	jmp    c010b9ee <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
c010b9a6:	8b 45 08             	mov    0x8(%ebp),%eax
c010b9a9:	0f b6 00             	movzbl (%eax),%eax
c010b9ac:	3c 60                	cmp    $0x60,%al
c010b9ae:	7e 1b                	jle    c010b9cb <strtol+0xf7>
c010b9b0:	8b 45 08             	mov    0x8(%ebp),%eax
c010b9b3:	0f b6 00             	movzbl (%eax),%eax
c010b9b6:	3c 7a                	cmp    $0x7a,%al
c010b9b8:	7f 11                	jg     c010b9cb <strtol+0xf7>
            dig = *s - 'a' + 10;
c010b9ba:	8b 45 08             	mov    0x8(%ebp),%eax
c010b9bd:	0f b6 00             	movzbl (%eax),%eax
c010b9c0:	0f be c0             	movsbl %al,%eax
c010b9c3:	83 e8 57             	sub    $0x57,%eax
c010b9c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b9c9:	eb 23                	jmp    c010b9ee <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c010b9cb:	8b 45 08             	mov    0x8(%ebp),%eax
c010b9ce:	0f b6 00             	movzbl (%eax),%eax
c010b9d1:	3c 40                	cmp    $0x40,%al
c010b9d3:	7e 3d                	jle    c010ba12 <strtol+0x13e>
c010b9d5:	8b 45 08             	mov    0x8(%ebp),%eax
c010b9d8:	0f b6 00             	movzbl (%eax),%eax
c010b9db:	3c 5a                	cmp    $0x5a,%al
c010b9dd:	7f 33                	jg     c010ba12 <strtol+0x13e>
            dig = *s - 'A' + 10;
c010b9df:	8b 45 08             	mov    0x8(%ebp),%eax
c010b9e2:	0f b6 00             	movzbl (%eax),%eax
c010b9e5:	0f be c0             	movsbl %al,%eax
c010b9e8:	83 e8 37             	sub    $0x37,%eax
c010b9eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c010b9ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b9f1:	3b 45 10             	cmp    0x10(%ebp),%eax
c010b9f4:	7c 02                	jl     c010b9f8 <strtol+0x124>
            break;
c010b9f6:	eb 1a                	jmp    c010ba12 <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
c010b9f8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010b9fc:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b9ff:	0f af 45 10          	imul   0x10(%ebp),%eax
c010ba03:	89 c2                	mov    %eax,%edx
c010ba05:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ba08:	01 d0                	add    %edx,%eax
c010ba0a:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c010ba0d:	e9 6f ff ff ff       	jmp    c010b981 <strtol+0xad>

    if (endptr) {
c010ba12:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010ba16:	74 08                	je     c010ba20 <strtol+0x14c>
        *endptr = (char *) s;
c010ba18:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ba1b:	8b 55 08             	mov    0x8(%ebp),%edx
c010ba1e:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c010ba20:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010ba24:	74 07                	je     c010ba2d <strtol+0x159>
c010ba26:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010ba29:	f7 d8                	neg    %eax
c010ba2b:	eb 03                	jmp    c010ba30 <strtol+0x15c>
c010ba2d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c010ba30:	c9                   	leave  
c010ba31:	c3                   	ret    

c010ba32 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c010ba32:	55                   	push   %ebp
c010ba33:	89 e5                	mov    %esp,%ebp
c010ba35:	57                   	push   %edi
c010ba36:	83 ec 24             	sub    $0x24,%esp
c010ba39:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ba3c:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c010ba3f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c010ba43:	8b 55 08             	mov    0x8(%ebp),%edx
c010ba46:	89 55 f8             	mov    %edx,-0x8(%ebp)
c010ba49:	88 45 f7             	mov    %al,-0x9(%ebp)
c010ba4c:	8b 45 10             	mov    0x10(%ebp),%eax
c010ba4f:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c010ba52:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c010ba55:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c010ba59:	8b 55 f8             	mov    -0x8(%ebp),%edx
c010ba5c:	89 d7                	mov    %edx,%edi
c010ba5e:	f3 aa                	rep stos %al,%es:(%edi)
c010ba60:	89 fa                	mov    %edi,%edx
c010ba62:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010ba65:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c010ba68:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c010ba6b:	83 c4 24             	add    $0x24,%esp
c010ba6e:	5f                   	pop    %edi
c010ba6f:	5d                   	pop    %ebp
c010ba70:	c3                   	ret    

c010ba71 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c010ba71:	55                   	push   %ebp
c010ba72:	89 e5                	mov    %esp,%ebp
c010ba74:	57                   	push   %edi
c010ba75:	56                   	push   %esi
c010ba76:	53                   	push   %ebx
c010ba77:	83 ec 30             	sub    $0x30,%esp
c010ba7a:	8b 45 08             	mov    0x8(%ebp),%eax
c010ba7d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010ba80:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ba83:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010ba86:	8b 45 10             	mov    0x10(%ebp),%eax
c010ba89:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c010ba8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010ba8f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010ba92:	73 42                	jae    c010bad6 <memmove+0x65>
c010ba94:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010ba97:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010ba9a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010ba9d:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010baa0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010baa3:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010baa6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010baa9:	c1 e8 02             	shr    $0x2,%eax
c010baac:	89 c1                	mov    %eax,%ecx
    asm volatile (
c010baae:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010bab1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010bab4:	89 d7                	mov    %edx,%edi
c010bab6:	89 c6                	mov    %eax,%esi
c010bab8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010baba:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010babd:	83 e1 03             	and    $0x3,%ecx
c010bac0:	74 02                	je     c010bac4 <memmove+0x53>
c010bac2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010bac4:	89 f0                	mov    %esi,%eax
c010bac6:	89 fa                	mov    %edi,%edx
c010bac8:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c010bacb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010bace:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c010bad1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010bad4:	eb 36                	jmp    c010bb0c <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c010bad6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010bad9:	8d 50 ff             	lea    -0x1(%eax),%edx
c010badc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010badf:	01 c2                	add    %eax,%edx
c010bae1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010bae4:	8d 48 ff             	lea    -0x1(%eax),%ecx
c010bae7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010baea:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c010baed:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010baf0:	89 c1                	mov    %eax,%ecx
c010baf2:	89 d8                	mov    %ebx,%eax
c010baf4:	89 d6                	mov    %edx,%esi
c010baf6:	89 c7                	mov    %eax,%edi
c010baf8:	fd                   	std    
c010baf9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010bafb:	fc                   	cld    
c010bafc:	89 f8                	mov    %edi,%eax
c010bafe:	89 f2                	mov    %esi,%edx
c010bb00:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c010bb03:	89 55 c8             	mov    %edx,-0x38(%ebp)
c010bb06:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c010bb09:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c010bb0c:	83 c4 30             	add    $0x30,%esp
c010bb0f:	5b                   	pop    %ebx
c010bb10:	5e                   	pop    %esi
c010bb11:	5f                   	pop    %edi
c010bb12:	5d                   	pop    %ebp
c010bb13:	c3                   	ret    

c010bb14 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c010bb14:	55                   	push   %ebp
c010bb15:	89 e5                	mov    %esp,%ebp
c010bb17:	57                   	push   %edi
c010bb18:	56                   	push   %esi
c010bb19:	83 ec 20             	sub    $0x20,%esp
c010bb1c:	8b 45 08             	mov    0x8(%ebp),%eax
c010bb1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010bb22:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bb25:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bb28:	8b 45 10             	mov    0x10(%ebp),%eax
c010bb2b:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010bb2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010bb31:	c1 e8 02             	shr    $0x2,%eax
c010bb34:	89 c1                	mov    %eax,%ecx
    asm volatile (
c010bb36:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010bb39:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bb3c:	89 d7                	mov    %edx,%edi
c010bb3e:	89 c6                	mov    %eax,%esi
c010bb40:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010bb42:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c010bb45:	83 e1 03             	and    $0x3,%ecx
c010bb48:	74 02                	je     c010bb4c <memcpy+0x38>
c010bb4a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010bb4c:	89 f0                	mov    %esi,%eax
c010bb4e:	89 fa                	mov    %edi,%edx
c010bb50:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010bb53:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010bb56:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c010bb59:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c010bb5c:	83 c4 20             	add    $0x20,%esp
c010bb5f:	5e                   	pop    %esi
c010bb60:	5f                   	pop    %edi
c010bb61:	5d                   	pop    %ebp
c010bb62:	c3                   	ret    

c010bb63 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c010bb63:	55                   	push   %ebp
c010bb64:	89 e5                	mov    %esp,%ebp
c010bb66:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c010bb69:	8b 45 08             	mov    0x8(%ebp),%eax
c010bb6c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c010bb6f:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bb72:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c010bb75:	eb 30                	jmp    c010bba7 <memcmp+0x44>
        if (*s1 != *s2) {
c010bb77:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010bb7a:	0f b6 10             	movzbl (%eax),%edx
c010bb7d:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010bb80:	0f b6 00             	movzbl (%eax),%eax
c010bb83:	38 c2                	cmp    %al,%dl
c010bb85:	74 18                	je     c010bb9f <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c010bb87:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010bb8a:	0f b6 00             	movzbl (%eax),%eax
c010bb8d:	0f b6 d0             	movzbl %al,%edx
c010bb90:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010bb93:	0f b6 00             	movzbl (%eax),%eax
c010bb96:	0f b6 c0             	movzbl %al,%eax
c010bb99:	29 c2                	sub    %eax,%edx
c010bb9b:	89 d0                	mov    %edx,%eax
c010bb9d:	eb 1a                	jmp    c010bbb9 <memcmp+0x56>
        }
        s1 ++, s2 ++;
c010bb9f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010bba3:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
    while (n -- > 0) {
c010bba7:	8b 45 10             	mov    0x10(%ebp),%eax
c010bbaa:	8d 50 ff             	lea    -0x1(%eax),%edx
c010bbad:	89 55 10             	mov    %edx,0x10(%ebp)
c010bbb0:	85 c0                	test   %eax,%eax
c010bbb2:	75 c3                	jne    c010bb77 <memcmp+0x14>
    }
    return 0;
c010bbb4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010bbb9:	c9                   	leave  
c010bbba:	c3                   	ret    

c010bbbb <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c010bbbb:	55                   	push   %ebp
c010bbbc:	89 e5                	mov    %esp,%ebp
c010bbbe:	83 ec 58             	sub    $0x58,%esp
c010bbc1:	8b 45 10             	mov    0x10(%ebp),%eax
c010bbc4:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010bbc7:	8b 45 14             	mov    0x14(%ebp),%eax
c010bbca:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c010bbcd:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010bbd0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010bbd3:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010bbd6:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c010bbd9:	8b 45 18             	mov    0x18(%ebp),%eax
c010bbdc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010bbdf:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010bbe2:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010bbe5:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010bbe8:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010bbeb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bbee:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010bbf1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010bbf5:	74 1c                	je     c010bc13 <printnum+0x58>
c010bbf7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bbfa:	ba 00 00 00 00       	mov    $0x0,%edx
c010bbff:	f7 75 e4             	divl   -0x1c(%ebp)
c010bc02:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010bc05:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bc08:	ba 00 00 00 00       	mov    $0x0,%edx
c010bc0d:	f7 75 e4             	divl   -0x1c(%ebp)
c010bc10:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bc13:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010bc16:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010bc19:	f7 75 e4             	divl   -0x1c(%ebp)
c010bc1c:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010bc1f:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010bc22:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010bc25:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010bc28:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010bc2b:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010bc2e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010bc31:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c010bc34:	8b 45 18             	mov    0x18(%ebp),%eax
c010bc37:	ba 00 00 00 00       	mov    $0x0,%edx
c010bc3c:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010bc3f:	77 56                	ja     c010bc97 <printnum+0xdc>
c010bc41:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010bc44:	72 05                	jb     c010bc4b <printnum+0x90>
c010bc46:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c010bc49:	77 4c                	ja     c010bc97 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c010bc4b:	8b 45 1c             	mov    0x1c(%ebp),%eax
c010bc4e:	8d 50 ff             	lea    -0x1(%eax),%edx
c010bc51:	8b 45 20             	mov    0x20(%ebp),%eax
c010bc54:	89 44 24 18          	mov    %eax,0x18(%esp)
c010bc58:	89 54 24 14          	mov    %edx,0x14(%esp)
c010bc5c:	8b 45 18             	mov    0x18(%ebp),%eax
c010bc5f:	89 44 24 10          	mov    %eax,0x10(%esp)
c010bc63:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010bc66:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010bc69:	89 44 24 08          	mov    %eax,0x8(%esp)
c010bc6d:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010bc71:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bc74:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bc78:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc7b:	89 04 24             	mov    %eax,(%esp)
c010bc7e:	e8 38 ff ff ff       	call   c010bbbb <printnum>
c010bc83:	eb 1c                	jmp    c010bca1 <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c010bc85:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bc88:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bc8c:	8b 45 20             	mov    0x20(%ebp),%eax
c010bc8f:	89 04 24             	mov    %eax,(%esp)
c010bc92:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc95:	ff d0                	call   *%eax
        while (-- width > 0)
c010bc97:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
c010bc9b:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c010bc9f:	7f e4                	jg     c010bc85 <printnum+0xca>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c010bca1:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010bca4:	05 04 ea 10 c0       	add    $0xc010ea04,%eax
c010bca9:	0f b6 00             	movzbl (%eax),%eax
c010bcac:	0f be c0             	movsbl %al,%eax
c010bcaf:	8b 55 0c             	mov    0xc(%ebp),%edx
c010bcb2:	89 54 24 04          	mov    %edx,0x4(%esp)
c010bcb6:	89 04 24             	mov    %eax,(%esp)
c010bcb9:	8b 45 08             	mov    0x8(%ebp),%eax
c010bcbc:	ff d0                	call   *%eax
}
c010bcbe:	c9                   	leave  
c010bcbf:	c3                   	ret    

c010bcc0 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c010bcc0:	55                   	push   %ebp
c010bcc1:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010bcc3:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010bcc7:	7e 14                	jle    c010bcdd <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c010bcc9:	8b 45 08             	mov    0x8(%ebp),%eax
c010bccc:	8b 00                	mov    (%eax),%eax
c010bcce:	8d 48 08             	lea    0x8(%eax),%ecx
c010bcd1:	8b 55 08             	mov    0x8(%ebp),%edx
c010bcd4:	89 0a                	mov    %ecx,(%edx)
c010bcd6:	8b 50 04             	mov    0x4(%eax),%edx
c010bcd9:	8b 00                	mov    (%eax),%eax
c010bcdb:	eb 30                	jmp    c010bd0d <getuint+0x4d>
    }
    else if (lflag) {
c010bcdd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010bce1:	74 16                	je     c010bcf9 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c010bce3:	8b 45 08             	mov    0x8(%ebp),%eax
c010bce6:	8b 00                	mov    (%eax),%eax
c010bce8:	8d 48 04             	lea    0x4(%eax),%ecx
c010bceb:	8b 55 08             	mov    0x8(%ebp),%edx
c010bcee:	89 0a                	mov    %ecx,(%edx)
c010bcf0:	8b 00                	mov    (%eax),%eax
c010bcf2:	ba 00 00 00 00       	mov    $0x0,%edx
c010bcf7:	eb 14                	jmp    c010bd0d <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c010bcf9:	8b 45 08             	mov    0x8(%ebp),%eax
c010bcfc:	8b 00                	mov    (%eax),%eax
c010bcfe:	8d 48 04             	lea    0x4(%eax),%ecx
c010bd01:	8b 55 08             	mov    0x8(%ebp),%edx
c010bd04:	89 0a                	mov    %ecx,(%edx)
c010bd06:	8b 00                	mov    (%eax),%eax
c010bd08:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c010bd0d:	5d                   	pop    %ebp
c010bd0e:	c3                   	ret    

c010bd0f <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c010bd0f:	55                   	push   %ebp
c010bd10:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010bd12:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010bd16:	7e 14                	jle    c010bd2c <getint+0x1d>
        return va_arg(*ap, long long);
c010bd18:	8b 45 08             	mov    0x8(%ebp),%eax
c010bd1b:	8b 00                	mov    (%eax),%eax
c010bd1d:	8d 48 08             	lea    0x8(%eax),%ecx
c010bd20:	8b 55 08             	mov    0x8(%ebp),%edx
c010bd23:	89 0a                	mov    %ecx,(%edx)
c010bd25:	8b 50 04             	mov    0x4(%eax),%edx
c010bd28:	8b 00                	mov    (%eax),%eax
c010bd2a:	eb 28                	jmp    c010bd54 <getint+0x45>
    }
    else if (lflag) {
c010bd2c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010bd30:	74 12                	je     c010bd44 <getint+0x35>
        return va_arg(*ap, long);
c010bd32:	8b 45 08             	mov    0x8(%ebp),%eax
c010bd35:	8b 00                	mov    (%eax),%eax
c010bd37:	8d 48 04             	lea    0x4(%eax),%ecx
c010bd3a:	8b 55 08             	mov    0x8(%ebp),%edx
c010bd3d:	89 0a                	mov    %ecx,(%edx)
c010bd3f:	8b 00                	mov    (%eax),%eax
c010bd41:	99                   	cltd   
c010bd42:	eb 10                	jmp    c010bd54 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c010bd44:	8b 45 08             	mov    0x8(%ebp),%eax
c010bd47:	8b 00                	mov    (%eax),%eax
c010bd49:	8d 48 04             	lea    0x4(%eax),%ecx
c010bd4c:	8b 55 08             	mov    0x8(%ebp),%edx
c010bd4f:	89 0a                	mov    %ecx,(%edx)
c010bd51:	8b 00                	mov    (%eax),%eax
c010bd53:	99                   	cltd   
    }
}
c010bd54:	5d                   	pop    %ebp
c010bd55:	c3                   	ret    

c010bd56 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c010bd56:	55                   	push   %ebp
c010bd57:	89 e5                	mov    %esp,%ebp
c010bd59:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c010bd5c:	8d 45 14             	lea    0x14(%ebp),%eax
c010bd5f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c010bd62:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010bd65:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010bd69:	8b 45 10             	mov    0x10(%ebp),%eax
c010bd6c:	89 44 24 08          	mov    %eax,0x8(%esp)
c010bd70:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bd73:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bd77:	8b 45 08             	mov    0x8(%ebp),%eax
c010bd7a:	89 04 24             	mov    %eax,(%esp)
c010bd7d:	e8 02 00 00 00       	call   c010bd84 <vprintfmt>
    va_end(ap);
}
c010bd82:	c9                   	leave  
c010bd83:	c3                   	ret    

c010bd84 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c010bd84:	55                   	push   %ebp
c010bd85:	89 e5                	mov    %esp,%ebp
c010bd87:	56                   	push   %esi
c010bd88:	53                   	push   %ebx
c010bd89:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010bd8c:	eb 18                	jmp    c010bda6 <vprintfmt+0x22>
            if (ch == '\0') {
c010bd8e:	85 db                	test   %ebx,%ebx
c010bd90:	75 05                	jne    c010bd97 <vprintfmt+0x13>
                return;
c010bd92:	e9 d1 03 00 00       	jmp    c010c168 <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
c010bd97:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bd9a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bd9e:	89 1c 24             	mov    %ebx,(%esp)
c010bda1:	8b 45 08             	mov    0x8(%ebp),%eax
c010bda4:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010bda6:	8b 45 10             	mov    0x10(%ebp),%eax
c010bda9:	8d 50 01             	lea    0x1(%eax),%edx
c010bdac:	89 55 10             	mov    %edx,0x10(%ebp)
c010bdaf:	0f b6 00             	movzbl (%eax),%eax
c010bdb2:	0f b6 d8             	movzbl %al,%ebx
c010bdb5:	83 fb 25             	cmp    $0x25,%ebx
c010bdb8:	75 d4                	jne    c010bd8e <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
c010bdba:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c010bdbe:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c010bdc5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010bdc8:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c010bdcb:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010bdd2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010bdd5:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c010bdd8:	8b 45 10             	mov    0x10(%ebp),%eax
c010bddb:	8d 50 01             	lea    0x1(%eax),%edx
c010bdde:	89 55 10             	mov    %edx,0x10(%ebp)
c010bde1:	0f b6 00             	movzbl (%eax),%eax
c010bde4:	0f b6 d8             	movzbl %al,%ebx
c010bde7:	8d 43 dd             	lea    -0x23(%ebx),%eax
c010bdea:	83 f8 55             	cmp    $0x55,%eax
c010bded:	0f 87 44 03 00 00    	ja     c010c137 <vprintfmt+0x3b3>
c010bdf3:	8b 04 85 28 ea 10 c0 	mov    -0x3fef15d8(,%eax,4),%eax
c010bdfa:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c010bdfc:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c010be00:	eb d6                	jmp    c010bdd8 <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c010be02:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c010be06:	eb d0                	jmp    c010bdd8 <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010be08:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c010be0f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010be12:	89 d0                	mov    %edx,%eax
c010be14:	c1 e0 02             	shl    $0x2,%eax
c010be17:	01 d0                	add    %edx,%eax
c010be19:	01 c0                	add    %eax,%eax
c010be1b:	01 d8                	add    %ebx,%eax
c010be1d:	83 e8 30             	sub    $0x30,%eax
c010be20:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c010be23:	8b 45 10             	mov    0x10(%ebp),%eax
c010be26:	0f b6 00             	movzbl (%eax),%eax
c010be29:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c010be2c:	83 fb 2f             	cmp    $0x2f,%ebx
c010be2f:	7e 0b                	jle    c010be3c <vprintfmt+0xb8>
c010be31:	83 fb 39             	cmp    $0x39,%ebx
c010be34:	7f 06                	jg     c010be3c <vprintfmt+0xb8>
            for (precision = 0; ; ++ fmt) {
c010be36:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                    break;
                }
            }
c010be3a:	eb d3                	jmp    c010be0f <vprintfmt+0x8b>
            goto process_precision;
c010be3c:	eb 33                	jmp    c010be71 <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
c010be3e:	8b 45 14             	mov    0x14(%ebp),%eax
c010be41:	8d 50 04             	lea    0x4(%eax),%edx
c010be44:	89 55 14             	mov    %edx,0x14(%ebp)
c010be47:	8b 00                	mov    (%eax),%eax
c010be49:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c010be4c:	eb 23                	jmp    c010be71 <vprintfmt+0xed>

        case '.':
            if (width < 0)
c010be4e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010be52:	79 0c                	jns    c010be60 <vprintfmt+0xdc>
                width = 0;
c010be54:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c010be5b:	e9 78 ff ff ff       	jmp    c010bdd8 <vprintfmt+0x54>
c010be60:	e9 73 ff ff ff       	jmp    c010bdd8 <vprintfmt+0x54>

        case '#':
            altflag = 1;
c010be65:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c010be6c:	e9 67 ff ff ff       	jmp    c010bdd8 <vprintfmt+0x54>

        process_precision:
            if (width < 0)
c010be71:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010be75:	79 12                	jns    c010be89 <vprintfmt+0x105>
                width = precision, precision = -1;
c010be77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010be7a:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010be7d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c010be84:	e9 4f ff ff ff       	jmp    c010bdd8 <vprintfmt+0x54>
c010be89:	e9 4a ff ff ff       	jmp    c010bdd8 <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c010be8e:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
c010be92:	e9 41 ff ff ff       	jmp    c010bdd8 <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c010be97:	8b 45 14             	mov    0x14(%ebp),%eax
c010be9a:	8d 50 04             	lea    0x4(%eax),%edx
c010be9d:	89 55 14             	mov    %edx,0x14(%ebp)
c010bea0:	8b 00                	mov    (%eax),%eax
c010bea2:	8b 55 0c             	mov    0xc(%ebp),%edx
c010bea5:	89 54 24 04          	mov    %edx,0x4(%esp)
c010bea9:	89 04 24             	mov    %eax,(%esp)
c010beac:	8b 45 08             	mov    0x8(%ebp),%eax
c010beaf:	ff d0                	call   *%eax
            break;
c010beb1:	e9 ac 02 00 00       	jmp    c010c162 <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
c010beb6:	8b 45 14             	mov    0x14(%ebp),%eax
c010beb9:	8d 50 04             	lea    0x4(%eax),%edx
c010bebc:	89 55 14             	mov    %edx,0x14(%ebp)
c010bebf:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c010bec1:	85 db                	test   %ebx,%ebx
c010bec3:	79 02                	jns    c010bec7 <vprintfmt+0x143>
                err = -err;
c010bec5:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c010bec7:	83 fb 18             	cmp    $0x18,%ebx
c010beca:	7f 0b                	jg     c010bed7 <vprintfmt+0x153>
c010becc:	8b 34 9d a0 e9 10 c0 	mov    -0x3fef1660(,%ebx,4),%esi
c010bed3:	85 f6                	test   %esi,%esi
c010bed5:	75 23                	jne    c010befa <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
c010bed7:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010bedb:	c7 44 24 08 15 ea 10 	movl   $0xc010ea15,0x8(%esp)
c010bee2:	c0 
c010bee3:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bee6:	89 44 24 04          	mov    %eax,0x4(%esp)
c010beea:	8b 45 08             	mov    0x8(%ebp),%eax
c010beed:	89 04 24             	mov    %eax,(%esp)
c010bef0:	e8 61 fe ff ff       	call   c010bd56 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c010bef5:	e9 68 02 00 00       	jmp    c010c162 <vprintfmt+0x3de>
                printfmt(putch, putdat, "%s", p);
c010befa:	89 74 24 0c          	mov    %esi,0xc(%esp)
c010befe:	c7 44 24 08 1e ea 10 	movl   $0xc010ea1e,0x8(%esp)
c010bf05:	c0 
c010bf06:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bf09:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bf0d:	8b 45 08             	mov    0x8(%ebp),%eax
c010bf10:	89 04 24             	mov    %eax,(%esp)
c010bf13:	e8 3e fe ff ff       	call   c010bd56 <printfmt>
            break;
c010bf18:	e9 45 02 00 00       	jmp    c010c162 <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c010bf1d:	8b 45 14             	mov    0x14(%ebp),%eax
c010bf20:	8d 50 04             	lea    0x4(%eax),%edx
c010bf23:	89 55 14             	mov    %edx,0x14(%ebp)
c010bf26:	8b 30                	mov    (%eax),%esi
c010bf28:	85 f6                	test   %esi,%esi
c010bf2a:	75 05                	jne    c010bf31 <vprintfmt+0x1ad>
                p = "(null)";
c010bf2c:	be 21 ea 10 c0       	mov    $0xc010ea21,%esi
            }
            if (width > 0 && padc != '-') {
c010bf31:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010bf35:	7e 3e                	jle    c010bf75 <vprintfmt+0x1f1>
c010bf37:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c010bf3b:	74 38                	je     c010bf75 <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
c010bf3d:	8b 5d e8             	mov    -0x18(%ebp),%ebx
c010bf40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010bf43:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bf47:	89 34 24             	mov    %esi,(%esp)
c010bf4a:	e8 dc f7 ff ff       	call   c010b72b <strnlen>
c010bf4f:	29 c3                	sub    %eax,%ebx
c010bf51:	89 d8                	mov    %ebx,%eax
c010bf53:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010bf56:	eb 17                	jmp    c010bf6f <vprintfmt+0x1eb>
                    putch(padc, putdat);
c010bf58:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c010bf5c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010bf5f:	89 54 24 04          	mov    %edx,0x4(%esp)
c010bf63:	89 04 24             	mov    %eax,(%esp)
c010bf66:	8b 45 08             	mov    0x8(%ebp),%eax
c010bf69:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
c010bf6b:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010bf6f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010bf73:	7f e3                	jg     c010bf58 <vprintfmt+0x1d4>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010bf75:	eb 38                	jmp    c010bfaf <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
c010bf77:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010bf7b:	74 1f                	je     c010bf9c <vprintfmt+0x218>
c010bf7d:	83 fb 1f             	cmp    $0x1f,%ebx
c010bf80:	7e 05                	jle    c010bf87 <vprintfmt+0x203>
c010bf82:	83 fb 7e             	cmp    $0x7e,%ebx
c010bf85:	7e 15                	jle    c010bf9c <vprintfmt+0x218>
                    putch('?', putdat);
c010bf87:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bf8a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bf8e:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c010bf95:	8b 45 08             	mov    0x8(%ebp),%eax
c010bf98:	ff d0                	call   *%eax
c010bf9a:	eb 0f                	jmp    c010bfab <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
c010bf9c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bf9f:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bfa3:	89 1c 24             	mov    %ebx,(%esp)
c010bfa6:	8b 45 08             	mov    0x8(%ebp),%eax
c010bfa9:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010bfab:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010bfaf:	89 f0                	mov    %esi,%eax
c010bfb1:	8d 70 01             	lea    0x1(%eax),%esi
c010bfb4:	0f b6 00             	movzbl (%eax),%eax
c010bfb7:	0f be d8             	movsbl %al,%ebx
c010bfba:	85 db                	test   %ebx,%ebx
c010bfbc:	74 10                	je     c010bfce <vprintfmt+0x24a>
c010bfbe:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010bfc2:	78 b3                	js     c010bf77 <vprintfmt+0x1f3>
c010bfc4:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
c010bfc8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010bfcc:	79 a9                	jns    c010bf77 <vprintfmt+0x1f3>
                }
            }
            for (; width > 0; width --) {
c010bfce:	eb 17                	jmp    c010bfe7 <vprintfmt+0x263>
                putch(' ', putdat);
c010bfd0:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bfd3:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bfd7:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010bfde:	8b 45 08             	mov    0x8(%ebp),%eax
c010bfe1:	ff d0                	call   *%eax
            for (; width > 0; width --) {
c010bfe3:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010bfe7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010bfeb:	7f e3                	jg     c010bfd0 <vprintfmt+0x24c>
            }
            break;
c010bfed:	e9 70 01 00 00       	jmp    c010c162 <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c010bff2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010bff5:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bff9:	8d 45 14             	lea    0x14(%ebp),%eax
c010bffc:	89 04 24             	mov    %eax,(%esp)
c010bfff:	e8 0b fd ff ff       	call   c010bd0f <getint>
c010c004:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010c007:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c010c00a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010c00d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010c010:	85 d2                	test   %edx,%edx
c010c012:	79 26                	jns    c010c03a <vprintfmt+0x2b6>
                putch('-', putdat);
c010c014:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c017:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c01b:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c010c022:	8b 45 08             	mov    0x8(%ebp),%eax
c010c025:	ff d0                	call   *%eax
                num = -(long long)num;
c010c027:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010c02a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010c02d:	f7 d8                	neg    %eax
c010c02f:	83 d2 00             	adc    $0x0,%edx
c010c032:	f7 da                	neg    %edx
c010c034:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010c037:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c010c03a:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010c041:	e9 a8 00 00 00       	jmp    c010c0ee <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c010c046:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010c049:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c04d:	8d 45 14             	lea    0x14(%ebp),%eax
c010c050:	89 04 24             	mov    %eax,(%esp)
c010c053:	e8 68 fc ff ff       	call   c010bcc0 <getuint>
c010c058:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010c05b:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c010c05e:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010c065:	e9 84 00 00 00       	jmp    c010c0ee <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c010c06a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010c06d:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c071:	8d 45 14             	lea    0x14(%ebp),%eax
c010c074:	89 04 24             	mov    %eax,(%esp)
c010c077:	e8 44 fc ff ff       	call   c010bcc0 <getuint>
c010c07c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010c07f:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c010c082:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c010c089:	eb 63                	jmp    c010c0ee <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
c010c08b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c08e:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c092:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c010c099:	8b 45 08             	mov    0x8(%ebp),%eax
c010c09c:	ff d0                	call   *%eax
            putch('x', putdat);
c010c09e:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c0a1:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c0a5:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c010c0ac:	8b 45 08             	mov    0x8(%ebp),%eax
c010c0af:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c010c0b1:	8b 45 14             	mov    0x14(%ebp),%eax
c010c0b4:	8d 50 04             	lea    0x4(%eax),%edx
c010c0b7:	89 55 14             	mov    %edx,0x14(%ebp)
c010c0ba:	8b 00                	mov    (%eax),%eax
c010c0bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010c0bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c010c0c6:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c010c0cd:	eb 1f                	jmp    c010c0ee <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c010c0cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010c0d2:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c0d6:	8d 45 14             	lea    0x14(%ebp),%eax
c010c0d9:	89 04 24             	mov    %eax,(%esp)
c010c0dc:	e8 df fb ff ff       	call   c010bcc0 <getuint>
c010c0e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010c0e4:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c010c0e7:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c010c0ee:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c010c0f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010c0f5:	89 54 24 18          	mov    %edx,0x18(%esp)
c010c0f9:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010c0fc:	89 54 24 14          	mov    %edx,0x14(%esp)
c010c100:	89 44 24 10          	mov    %eax,0x10(%esp)
c010c104:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010c107:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010c10a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010c10e:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010c112:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c115:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c119:	8b 45 08             	mov    0x8(%ebp),%eax
c010c11c:	89 04 24             	mov    %eax,(%esp)
c010c11f:	e8 97 fa ff ff       	call   c010bbbb <printnum>
            break;
c010c124:	eb 3c                	jmp    c010c162 <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c010c126:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c129:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c12d:	89 1c 24             	mov    %ebx,(%esp)
c010c130:	8b 45 08             	mov    0x8(%ebp),%eax
c010c133:	ff d0                	call   *%eax
            break;
c010c135:	eb 2b                	jmp    c010c162 <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c010c137:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c13a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c13e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c010c145:	8b 45 08             	mov    0x8(%ebp),%eax
c010c148:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c010c14a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010c14e:	eb 04                	jmp    c010c154 <vprintfmt+0x3d0>
c010c150:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010c154:	8b 45 10             	mov    0x10(%ebp),%eax
c010c157:	83 e8 01             	sub    $0x1,%eax
c010c15a:	0f b6 00             	movzbl (%eax),%eax
c010c15d:	3c 25                	cmp    $0x25,%al
c010c15f:	75 ef                	jne    c010c150 <vprintfmt+0x3cc>
                /* do nothing */;
            break;
c010c161:	90                   	nop
        }
    }
c010c162:	90                   	nop
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010c163:	e9 3e fc ff ff       	jmp    c010bda6 <vprintfmt+0x22>
}
c010c168:	83 c4 40             	add    $0x40,%esp
c010c16b:	5b                   	pop    %ebx
c010c16c:	5e                   	pop    %esi
c010c16d:	5d                   	pop    %ebp
c010c16e:	c3                   	ret    

c010c16f <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c010c16f:	55                   	push   %ebp
c010c170:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c010c172:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c175:	8b 40 08             	mov    0x8(%eax),%eax
c010c178:	8d 50 01             	lea    0x1(%eax),%edx
c010c17b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c17e:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c010c181:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c184:	8b 10                	mov    (%eax),%edx
c010c186:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c189:	8b 40 04             	mov    0x4(%eax),%eax
c010c18c:	39 c2                	cmp    %eax,%edx
c010c18e:	73 12                	jae    c010c1a2 <sprintputch+0x33>
        *b->buf ++ = ch;
c010c190:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c193:	8b 00                	mov    (%eax),%eax
c010c195:	8d 48 01             	lea    0x1(%eax),%ecx
c010c198:	8b 55 0c             	mov    0xc(%ebp),%edx
c010c19b:	89 0a                	mov    %ecx,(%edx)
c010c19d:	8b 55 08             	mov    0x8(%ebp),%edx
c010c1a0:	88 10                	mov    %dl,(%eax)
    }
}
c010c1a2:	5d                   	pop    %ebp
c010c1a3:	c3                   	ret    

c010c1a4 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c010c1a4:	55                   	push   %ebp
c010c1a5:	89 e5                	mov    %esp,%ebp
c010c1a7:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010c1aa:	8d 45 14             	lea    0x14(%ebp),%eax
c010c1ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c010c1b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010c1b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010c1b7:	8b 45 10             	mov    0x10(%ebp),%eax
c010c1ba:	89 44 24 08          	mov    %eax,0x8(%esp)
c010c1be:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c1c1:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c1c5:	8b 45 08             	mov    0x8(%ebp),%eax
c010c1c8:	89 04 24             	mov    %eax,(%esp)
c010c1cb:	e8 08 00 00 00       	call   c010c1d8 <vsnprintf>
c010c1d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c010c1d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010c1d6:	c9                   	leave  
c010c1d7:	c3                   	ret    

c010c1d8 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c010c1d8:	55                   	push   %ebp
c010c1d9:	89 e5                	mov    %esp,%ebp
c010c1db:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c010c1de:	8b 45 08             	mov    0x8(%ebp),%eax
c010c1e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010c1e4:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c1e7:	8d 50 ff             	lea    -0x1(%eax),%edx
c010c1ea:	8b 45 08             	mov    0x8(%ebp),%eax
c010c1ed:	01 d0                	add    %edx,%eax
c010c1ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010c1f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c010c1f9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010c1fd:	74 0a                	je     c010c209 <vsnprintf+0x31>
c010c1ff:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010c202:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010c205:	39 c2                	cmp    %eax,%edx
c010c207:	76 07                	jbe    c010c210 <vsnprintf+0x38>
        return -E_INVAL;
c010c209:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010c20e:	eb 2a                	jmp    c010c23a <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c010c210:	8b 45 14             	mov    0x14(%ebp),%eax
c010c213:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010c217:	8b 45 10             	mov    0x10(%ebp),%eax
c010c21a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010c21e:	8d 45 ec             	lea    -0x14(%ebp),%eax
c010c221:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c225:	c7 04 24 6f c1 10 c0 	movl   $0xc010c16f,(%esp)
c010c22c:	e8 53 fb ff ff       	call   c010bd84 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c010c231:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010c234:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c010c237:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010c23a:	c9                   	leave  
c010c23b:	c3                   	ret    

c010c23c <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
c010c23c:	55                   	push   %ebp
c010c23d:	89 e5                	mov    %esp,%ebp
c010c23f:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
c010c242:	8b 45 08             	mov    0x8(%ebp),%eax
c010c245:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
c010c24b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
c010c24e:	b8 20 00 00 00       	mov    $0x20,%eax
c010c253:	2b 45 0c             	sub    0xc(%ebp),%eax
c010c256:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010c259:	89 c1                	mov    %eax,%ecx
c010c25b:	d3 ea                	shr    %cl,%edx
c010c25d:	89 d0                	mov    %edx,%eax
}
c010c25f:	c9                   	leave  
c010c260:	c3                   	ret    

c010c261 <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c010c261:	55                   	push   %ebp
c010c262:	89 e5                	mov    %esp,%ebp
c010c264:	57                   	push   %edi
c010c265:	56                   	push   %esi
c010c266:	53                   	push   %ebx
c010c267:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c010c26a:	a1 a0 ce 12 c0       	mov    0xc012cea0,%eax
c010c26f:	8b 15 a4 ce 12 c0    	mov    0xc012cea4,%edx
c010c275:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c010c27b:	6b f0 05             	imul   $0x5,%eax,%esi
c010c27e:	01 f7                	add    %esi,%edi
c010c280:	be 6d e6 ec de       	mov    $0xdeece66d,%esi
c010c285:	f7 e6                	mul    %esi
c010c287:	8d 34 17             	lea    (%edi,%edx,1),%esi
c010c28a:	89 f2                	mov    %esi,%edx
c010c28c:	83 c0 0b             	add    $0xb,%eax
c010c28f:	83 d2 00             	adc    $0x0,%edx
c010c292:	89 c7                	mov    %eax,%edi
c010c294:	83 e7 ff             	and    $0xffffffff,%edi
c010c297:	89 f9                	mov    %edi,%ecx
c010c299:	0f b7 da             	movzwl %dx,%ebx
c010c29c:	89 0d a0 ce 12 c0    	mov    %ecx,0xc012cea0
c010c2a2:	89 1d a4 ce 12 c0    	mov    %ebx,0xc012cea4
    unsigned long long result = (next >> 12);
c010c2a8:	a1 a0 ce 12 c0       	mov    0xc012cea0,%eax
c010c2ad:	8b 15 a4 ce 12 c0    	mov    0xc012cea4,%edx
c010c2b3:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c010c2b7:	c1 ea 0c             	shr    $0xc,%edx
c010c2ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010c2bd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c010c2c0:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c010c2c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010c2ca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010c2cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010c2d0:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010c2d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010c2d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010c2d9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010c2dd:	74 1c                	je     c010c2fb <rand+0x9a>
c010c2df:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010c2e2:	ba 00 00 00 00       	mov    $0x0,%edx
c010c2e7:	f7 75 dc             	divl   -0x24(%ebp)
c010c2ea:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010c2ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010c2f0:	ba 00 00 00 00       	mov    $0x0,%edx
c010c2f5:	f7 75 dc             	divl   -0x24(%ebp)
c010c2f8:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010c2fb:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010c2fe:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010c301:	f7 75 dc             	divl   -0x24(%ebp)
c010c304:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010c307:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010c30a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010c30d:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010c310:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010c313:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010c316:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c010c319:	83 c4 24             	add    $0x24,%esp
c010c31c:	5b                   	pop    %ebx
c010c31d:	5e                   	pop    %esi
c010c31e:	5f                   	pop    %edi
c010c31f:	5d                   	pop    %ebp
c010c320:	c3                   	ret    

c010c321 <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c010c321:	55                   	push   %ebp
c010c322:	89 e5                	mov    %esp,%ebp
    next = seed;
c010c324:	8b 45 08             	mov    0x8(%ebp),%eax
c010c327:	ba 00 00 00 00       	mov    $0x0,%edx
c010c32c:	a3 a0 ce 12 c0       	mov    %eax,0xc012cea0
c010c331:	89 15 a4 ce 12 c0    	mov    %edx,0xc012cea4
}
c010c337:	5d                   	pop    %ebp
c010c338:	c3                   	ret    
