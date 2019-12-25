
bin/kernel:     file format elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 80 11 00       	mov    $0x118000,%eax
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
c0100020:	a3 00 80 11 c0       	mov    %eax,0xc0118000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 70 11 c0       	mov    $0xc0117000,%esp
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
c010003c:	ba 28 af 11 c0       	mov    $0xc011af28,%edx
c0100041:	b8 00 a0 11 c0       	mov    $0xc011a000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 a0 11 c0 	movl   $0xc011a000,(%esp)
c010005d:	e8 bb 56 00 00       	call   c010571d <memset>

    cons_init();                // init the console
c0100062:	e8 8c 15 00 00       	call   c01015f3 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 40 5f 10 c0 	movl   $0xc0105f40,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 5c 5f 10 c0 	movl   $0xc0105f5c,(%esp)
c010007c:	e8 11 02 00 00       	call   c0100292 <cprintf>

    print_kerninfo();
c0100081:	e8 c3 08 00 00       	call   c0100949 <print_kerninfo>

    grade_backtrace();
c0100086:	e8 86 00 00 00       	call   c0100111 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 50 31 00 00       	call   c01031e0 <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 bb 16 00 00       	call   c0101750 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 3f 18 00 00       	call   c01018d9 <idt_init>

    clock_init();               // init clock interrupt
c010009a:	e8 0a 0d 00 00       	call   c0100da9 <clock_init>
    intr_enable();              // enable irq interrupt
c010009f:	e8 e7 17 00 00       	call   c010188b <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
c01000a4:	eb fe                	jmp    c01000a4 <kern_init+0x6e>

c01000a6 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000a6:	55                   	push   %ebp
c01000a7:	89 e5                	mov    %esp,%ebp
c01000a9:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000ac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000b3:	00 
c01000b4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000bb:	00 
c01000bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000c3:	e8 cf 0c 00 00       	call   c0100d97 <mon_backtrace>
}
c01000c8:	c9                   	leave  
c01000c9:	c3                   	ret    

c01000ca <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000ca:	55                   	push   %ebp
c01000cb:	89 e5                	mov    %esp,%ebp
c01000cd:	53                   	push   %ebx
c01000ce:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000d1:	8d 5d 0c             	lea    0xc(%ebp),%ebx
c01000d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c01000d7:	8d 55 08             	lea    0x8(%ebp),%edx
c01000da:	8b 45 08             	mov    0x8(%ebp),%eax
c01000dd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01000e1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01000e5:	89 54 24 04          	mov    %edx,0x4(%esp)
c01000e9:	89 04 24             	mov    %eax,(%esp)
c01000ec:	e8 b5 ff ff ff       	call   c01000a6 <grade_backtrace2>
}
c01000f1:	83 c4 14             	add    $0x14,%esp
c01000f4:	5b                   	pop    %ebx
c01000f5:	5d                   	pop    %ebp
c01000f6:	c3                   	ret    

c01000f7 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c01000f7:	55                   	push   %ebp
c01000f8:	89 e5                	mov    %esp,%ebp
c01000fa:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c01000fd:	8b 45 10             	mov    0x10(%ebp),%eax
c0100100:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100104:	8b 45 08             	mov    0x8(%ebp),%eax
c0100107:	89 04 24             	mov    %eax,(%esp)
c010010a:	e8 bb ff ff ff       	call   c01000ca <grade_backtrace1>
}
c010010f:	c9                   	leave  
c0100110:	c3                   	ret    

c0100111 <grade_backtrace>:

void
grade_backtrace(void) {
c0100111:	55                   	push   %ebp
c0100112:	89 e5                	mov    %esp,%ebp
c0100114:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c0100117:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c010011c:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c0100123:	ff 
c0100124:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100128:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010012f:	e8 c3 ff ff ff       	call   c01000f7 <grade_backtrace0>
}
c0100134:	c9                   	leave  
c0100135:	c3                   	ret    

c0100136 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c0100136:	55                   	push   %ebp
c0100137:	89 e5                	mov    %esp,%ebp
c0100139:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c010013c:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c010013f:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100142:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100145:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100148:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010014c:	0f b7 c0             	movzwl %ax,%eax
c010014f:	83 e0 03             	and    $0x3,%eax
c0100152:	89 c2                	mov    %eax,%edx
c0100154:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c0100159:	89 54 24 08          	mov    %edx,0x8(%esp)
c010015d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100161:	c7 04 24 61 5f 10 c0 	movl   $0xc0105f61,(%esp)
c0100168:	e8 25 01 00 00       	call   c0100292 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c010016d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100171:	0f b7 d0             	movzwl %ax,%edx
c0100174:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c0100179:	89 54 24 08          	mov    %edx,0x8(%esp)
c010017d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100181:	c7 04 24 6f 5f 10 c0 	movl   $0xc0105f6f,(%esp)
c0100188:	e8 05 01 00 00       	call   c0100292 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c010018d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0100191:	0f b7 d0             	movzwl %ax,%edx
c0100194:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c0100199:	89 54 24 08          	mov    %edx,0x8(%esp)
c010019d:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001a1:	c7 04 24 7d 5f 10 c0 	movl   $0xc0105f7d,(%esp)
c01001a8:	e8 e5 00 00 00       	call   c0100292 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001ad:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001b1:	0f b7 d0             	movzwl %ax,%edx
c01001b4:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001b9:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001bd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001c1:	c7 04 24 8b 5f 10 c0 	movl   $0xc0105f8b,(%esp)
c01001c8:	e8 c5 00 00 00       	call   c0100292 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001cd:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001d1:	0f b7 d0             	movzwl %ax,%edx
c01001d4:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001d9:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001dd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001e1:	c7 04 24 99 5f 10 c0 	movl   $0xc0105f99,(%esp)
c01001e8:	e8 a5 00 00 00       	call   c0100292 <cprintf>
    round ++;
c01001ed:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001f2:	83 c0 01             	add    $0x1,%eax
c01001f5:	a3 00 a0 11 c0       	mov    %eax,0xc011a000
}
c01001fa:	c9                   	leave  
c01001fb:	c3                   	ret    

c01001fc <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c01001fc:	55                   	push   %ebp
c01001fd:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c01001ff:	5d                   	pop    %ebp
c0100200:	c3                   	ret    

c0100201 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c0100201:	55                   	push   %ebp
c0100202:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c0100204:	5d                   	pop    %ebp
c0100205:	c3                   	ret    

c0100206 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c0100206:	55                   	push   %ebp
c0100207:	89 e5                	mov    %esp,%ebp
c0100209:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c010020c:	e8 25 ff ff ff       	call   c0100136 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c0100211:	c7 04 24 a8 5f 10 c0 	movl   $0xc0105fa8,(%esp)
c0100218:	e8 75 00 00 00       	call   c0100292 <cprintf>
    lab1_switch_to_user();
c010021d:	e8 da ff ff ff       	call   c01001fc <lab1_switch_to_user>
    lab1_print_cur_status();
c0100222:	e8 0f ff ff ff       	call   c0100136 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100227:	c7 04 24 c8 5f 10 c0 	movl   $0xc0105fc8,(%esp)
c010022e:	e8 5f 00 00 00       	call   c0100292 <cprintf>
    lab1_switch_to_kernel();
c0100233:	e8 c9 ff ff ff       	call   c0100201 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100238:	e8 f9 fe ff ff       	call   c0100136 <lab1_print_cur_status>
}
c010023d:	c9                   	leave  
c010023e:	c3                   	ret    

c010023f <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c010023f:	55                   	push   %ebp
c0100240:	89 e5                	mov    %esp,%ebp
c0100242:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100245:	8b 45 08             	mov    0x8(%ebp),%eax
c0100248:	89 04 24             	mov    %eax,(%esp)
c010024b:	e8 cf 13 00 00       	call   c010161f <cons_putc>
    (*cnt) ++;
c0100250:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100253:	8b 00                	mov    (%eax),%eax
c0100255:	8d 50 01             	lea    0x1(%eax),%edx
c0100258:	8b 45 0c             	mov    0xc(%ebp),%eax
c010025b:	89 10                	mov    %edx,(%eax)
}
c010025d:	c9                   	leave  
c010025e:	c3                   	ret    

c010025f <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c010025f:	55                   	push   %ebp
c0100260:	89 e5                	mov    %esp,%ebp
c0100262:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100265:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c010026c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010026f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0100273:	8b 45 08             	mov    0x8(%ebp),%eax
c0100276:	89 44 24 08          	mov    %eax,0x8(%esp)
c010027a:	8d 45 f4             	lea    -0xc(%ebp),%eax
c010027d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100281:	c7 04 24 3f 02 10 c0 	movl   $0xc010023f,(%esp)
c0100288:	e8 e2 57 00 00       	call   c0105a6f <vprintfmt>
    return cnt;
c010028d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100290:	c9                   	leave  
c0100291:	c3                   	ret    

c0100292 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c0100292:	55                   	push   %ebp
c0100293:	89 e5                	mov    %esp,%ebp
c0100295:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0100298:	8d 45 0c             	lea    0xc(%ebp),%eax
c010029b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c010029e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002a1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01002a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01002a8:	89 04 24             	mov    %eax,(%esp)
c01002ab:	e8 af ff ff ff       	call   c010025f <vcprintf>
c01002b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c01002b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002b6:	c9                   	leave  
c01002b7:	c3                   	ret    

c01002b8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c01002b8:	55                   	push   %ebp
c01002b9:	89 e5                	mov    %esp,%ebp
c01002bb:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c01002be:	8b 45 08             	mov    0x8(%ebp),%eax
c01002c1:	89 04 24             	mov    %eax,(%esp)
c01002c4:	e8 56 13 00 00       	call   c010161f <cons_putc>
}
c01002c9:	c9                   	leave  
c01002ca:	c3                   	ret    

c01002cb <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c01002cb:	55                   	push   %ebp
c01002cc:	89 e5                	mov    %esp,%ebp
c01002ce:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c01002d1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01002d8:	eb 13                	jmp    c01002ed <cputs+0x22>
        cputch(c, &cnt);
c01002da:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01002de:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01002e1:	89 54 24 04          	mov    %edx,0x4(%esp)
c01002e5:	89 04 24             	mov    %eax,(%esp)
c01002e8:	e8 52 ff ff ff       	call   c010023f <cputch>
    while ((c = *str ++) != '\0') {
c01002ed:	8b 45 08             	mov    0x8(%ebp),%eax
c01002f0:	8d 50 01             	lea    0x1(%eax),%edx
c01002f3:	89 55 08             	mov    %edx,0x8(%ebp)
c01002f6:	0f b6 00             	movzbl (%eax),%eax
c01002f9:	88 45 f7             	mov    %al,-0x9(%ebp)
c01002fc:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c0100300:	75 d8                	jne    c01002da <cputs+0xf>
    }
    cputch('\n', &cnt);
c0100302:	8d 45 f0             	lea    -0x10(%ebp),%eax
c0100305:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100309:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c0100310:	e8 2a ff ff ff       	call   c010023f <cputch>
    return cnt;
c0100315:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0100318:	c9                   	leave  
c0100319:	c3                   	ret    

c010031a <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c010031a:	55                   	push   %ebp
c010031b:	89 e5                	mov    %esp,%ebp
c010031d:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c0100320:	e8 36 13 00 00       	call   c010165b <cons_getc>
c0100325:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100328:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010032c:	74 f2                	je     c0100320 <getchar+0x6>
        /* do nothing */;
    return c;
c010032e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100331:	c9                   	leave  
c0100332:	c3                   	ret    

c0100333 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c0100333:	55                   	push   %ebp
c0100334:	89 e5                	mov    %esp,%ebp
c0100336:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c0100339:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010033d:	74 13                	je     c0100352 <readline+0x1f>
        cprintf("%s", prompt);
c010033f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100342:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100346:	c7 04 24 e7 5f 10 c0 	movl   $0xc0105fe7,(%esp)
c010034d:	e8 40 ff ff ff       	call   c0100292 <cprintf>
    }
    int i = 0, c;
c0100352:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c0100359:	e8 bc ff ff ff       	call   c010031a <getchar>
c010035e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c0100361:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100365:	79 07                	jns    c010036e <readline+0x3b>
            return NULL;
c0100367:	b8 00 00 00 00       	mov    $0x0,%eax
c010036c:	eb 79                	jmp    c01003e7 <readline+0xb4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c010036e:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c0100372:	7e 28                	jle    c010039c <readline+0x69>
c0100374:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c010037b:	7f 1f                	jg     c010039c <readline+0x69>
            cputchar(c);
c010037d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100380:	89 04 24             	mov    %eax,(%esp)
c0100383:	e8 30 ff ff ff       	call   c01002b8 <cputchar>
            buf[i ++] = c;
c0100388:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010038b:	8d 50 01             	lea    0x1(%eax),%edx
c010038e:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100391:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100394:	88 90 20 a0 11 c0    	mov    %dl,-0x3fee5fe0(%eax)
c010039a:	eb 46                	jmp    c01003e2 <readline+0xaf>
        }
        else if (c == '\b' && i > 0) {
c010039c:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01003a0:	75 17                	jne    c01003b9 <readline+0x86>
c01003a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003a6:	7e 11                	jle    c01003b9 <readline+0x86>
            cputchar(c);
c01003a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003ab:	89 04 24             	mov    %eax,(%esp)
c01003ae:	e8 05 ff ff ff       	call   c01002b8 <cputchar>
            i --;
c01003b3:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01003b7:	eb 29                	jmp    c01003e2 <readline+0xaf>
        }
        else if (c == '\n' || c == '\r') {
c01003b9:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01003bd:	74 06                	je     c01003c5 <readline+0x92>
c01003bf:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01003c3:	75 1d                	jne    c01003e2 <readline+0xaf>
            cputchar(c);
c01003c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003c8:	89 04 24             	mov    %eax,(%esp)
c01003cb:	e8 e8 fe ff ff       	call   c01002b8 <cputchar>
            buf[i] = '\0';
c01003d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01003d3:	05 20 a0 11 c0       	add    $0xc011a020,%eax
c01003d8:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01003db:	b8 20 a0 11 c0       	mov    $0xc011a020,%eax
c01003e0:	eb 05                	jmp    c01003e7 <readline+0xb4>
        }
    }
c01003e2:	e9 72 ff ff ff       	jmp    c0100359 <readline+0x26>
}
c01003e7:	c9                   	leave  
c01003e8:	c3                   	ret    

c01003e9 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c01003e9:	55                   	push   %ebp
c01003ea:	89 e5                	mov    %esp,%ebp
c01003ec:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c01003ef:	a1 20 a4 11 c0       	mov    0xc011a420,%eax
c01003f4:	85 c0                	test   %eax,%eax
c01003f6:	74 02                	je     c01003fa <__panic+0x11>
        goto panic_dead;
c01003f8:	eb 59                	jmp    c0100453 <__panic+0x6a>
    }
    is_panic = 1;
c01003fa:	c7 05 20 a4 11 c0 01 	movl   $0x1,0xc011a420
c0100401:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100404:	8d 45 14             	lea    0x14(%ebp),%eax
c0100407:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c010040a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010040d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100411:	8b 45 08             	mov    0x8(%ebp),%eax
c0100414:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100418:	c7 04 24 ea 5f 10 c0 	movl   $0xc0105fea,(%esp)
c010041f:	e8 6e fe ff ff       	call   c0100292 <cprintf>
    vcprintf(fmt, ap);
c0100424:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100427:	89 44 24 04          	mov    %eax,0x4(%esp)
c010042b:	8b 45 10             	mov    0x10(%ebp),%eax
c010042e:	89 04 24             	mov    %eax,(%esp)
c0100431:	e8 29 fe ff ff       	call   c010025f <vcprintf>
    cprintf("\n");
c0100436:	c7 04 24 06 60 10 c0 	movl   $0xc0106006,(%esp)
c010043d:	e8 50 fe ff ff       	call   c0100292 <cprintf>
    
    cprintf("stack trackback:\n");
c0100442:	c7 04 24 08 60 10 c0 	movl   $0xc0106008,(%esp)
c0100449:	e8 44 fe ff ff       	call   c0100292 <cprintf>
    print_stackframe();
c010044e:	e8 40 06 00 00       	call   c0100a93 <print_stackframe>
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100453:	e8 39 14 00 00       	call   c0101891 <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100458:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010045f:	e8 64 08 00 00       	call   c0100cc8 <kmonitor>
    }
c0100464:	eb f2                	jmp    c0100458 <__panic+0x6f>

c0100466 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100466:	55                   	push   %ebp
c0100467:	89 e5                	mov    %esp,%ebp
c0100469:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c010046c:	8d 45 14             	lea    0x14(%ebp),%eax
c010046f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100472:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100475:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100479:	8b 45 08             	mov    0x8(%ebp),%eax
c010047c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100480:	c7 04 24 1a 60 10 c0 	movl   $0xc010601a,(%esp)
c0100487:	e8 06 fe ff ff       	call   c0100292 <cprintf>
    vcprintf(fmt, ap);
c010048c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010048f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100493:	8b 45 10             	mov    0x10(%ebp),%eax
c0100496:	89 04 24             	mov    %eax,(%esp)
c0100499:	e8 c1 fd ff ff       	call   c010025f <vcprintf>
    cprintf("\n");
c010049e:	c7 04 24 06 60 10 c0 	movl   $0xc0106006,(%esp)
c01004a5:	e8 e8 fd ff ff       	call   c0100292 <cprintf>
    va_end(ap);
}
c01004aa:	c9                   	leave  
c01004ab:	c3                   	ret    

c01004ac <is_kernel_panic>:

bool
is_kernel_panic(void) {
c01004ac:	55                   	push   %ebp
c01004ad:	89 e5                	mov    %esp,%ebp
    return is_panic;
c01004af:	a1 20 a4 11 c0       	mov    0xc011a420,%eax
}
c01004b4:	5d                   	pop    %ebp
c01004b5:	c3                   	ret    

c01004b6 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c01004b6:	55                   	push   %ebp
c01004b7:	89 e5                	mov    %esp,%ebp
c01004b9:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c01004bc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004bf:	8b 00                	mov    (%eax),%eax
c01004c1:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004c4:	8b 45 10             	mov    0x10(%ebp),%eax
c01004c7:	8b 00                	mov    (%eax),%eax
c01004c9:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c01004d3:	e9 d2 00 00 00       	jmp    c01005aa <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
c01004d8:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01004db:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01004de:	01 d0                	add    %edx,%eax
c01004e0:	89 c2                	mov    %eax,%edx
c01004e2:	c1 ea 1f             	shr    $0x1f,%edx
c01004e5:	01 d0                	add    %edx,%eax
c01004e7:	d1 f8                	sar    %eax
c01004e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01004ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01004ef:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c01004f2:	eb 04                	jmp    c01004f8 <stab_binsearch+0x42>
            m --;
c01004f4:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
c01004f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004fb:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01004fe:	7c 1f                	jl     c010051f <stab_binsearch+0x69>
c0100500:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100503:	89 d0                	mov    %edx,%eax
c0100505:	01 c0                	add    %eax,%eax
c0100507:	01 d0                	add    %edx,%eax
c0100509:	c1 e0 02             	shl    $0x2,%eax
c010050c:	89 c2                	mov    %eax,%edx
c010050e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100511:	01 d0                	add    %edx,%eax
c0100513:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100517:	0f b6 c0             	movzbl %al,%eax
c010051a:	3b 45 14             	cmp    0x14(%ebp),%eax
c010051d:	75 d5                	jne    c01004f4 <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
c010051f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100522:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100525:	7d 0b                	jge    c0100532 <stab_binsearch+0x7c>
            l = true_m + 1;
c0100527:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010052a:	83 c0 01             	add    $0x1,%eax
c010052d:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c0100530:	eb 78                	jmp    c01005aa <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
c0100532:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0100539:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010053c:	89 d0                	mov    %edx,%eax
c010053e:	01 c0                	add    %eax,%eax
c0100540:	01 d0                	add    %edx,%eax
c0100542:	c1 e0 02             	shl    $0x2,%eax
c0100545:	89 c2                	mov    %eax,%edx
c0100547:	8b 45 08             	mov    0x8(%ebp),%eax
c010054a:	01 d0                	add    %edx,%eax
c010054c:	8b 40 08             	mov    0x8(%eax),%eax
c010054f:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100552:	73 13                	jae    c0100567 <stab_binsearch+0xb1>
            *region_left = m;
c0100554:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100557:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010055a:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c010055c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010055f:	83 c0 01             	add    $0x1,%eax
c0100562:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100565:	eb 43                	jmp    c01005aa <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
c0100567:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010056a:	89 d0                	mov    %edx,%eax
c010056c:	01 c0                	add    %eax,%eax
c010056e:	01 d0                	add    %edx,%eax
c0100570:	c1 e0 02             	shl    $0x2,%eax
c0100573:	89 c2                	mov    %eax,%edx
c0100575:	8b 45 08             	mov    0x8(%ebp),%eax
c0100578:	01 d0                	add    %edx,%eax
c010057a:	8b 40 08             	mov    0x8(%eax),%eax
c010057d:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100580:	76 16                	jbe    c0100598 <stab_binsearch+0xe2>
            *region_right = m - 1;
c0100582:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100585:	8d 50 ff             	lea    -0x1(%eax),%edx
c0100588:	8b 45 10             	mov    0x10(%ebp),%eax
c010058b:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c010058d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100590:	83 e8 01             	sub    $0x1,%eax
c0100593:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0100596:	eb 12                	jmp    c01005aa <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c0100598:	8b 45 0c             	mov    0xc(%ebp),%eax
c010059b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010059e:	89 10                	mov    %edx,(%eax)
            l = m;
c01005a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005a3:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01005a6:	83 45 18 01          	addl   $0x1,0x18(%ebp)
    while (l <= r) {
c01005aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01005ad:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01005b0:	0f 8e 22 ff ff ff    	jle    c01004d8 <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
c01005b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01005ba:	75 0f                	jne    c01005cb <stab_binsearch+0x115>
        *region_right = *region_left - 1;
c01005bc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005bf:	8b 00                	mov    (%eax),%eax
c01005c1:	8d 50 ff             	lea    -0x1(%eax),%edx
c01005c4:	8b 45 10             	mov    0x10(%ebp),%eax
c01005c7:	89 10                	mov    %edx,(%eax)
c01005c9:	eb 3f                	jmp    c010060a <stab_binsearch+0x154>
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
c01005cb:	8b 45 10             	mov    0x10(%ebp),%eax
c01005ce:	8b 00                	mov    (%eax),%eax
c01005d0:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c01005d3:	eb 04                	jmp    c01005d9 <stab_binsearch+0x123>
c01005d5:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
c01005d9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005dc:	8b 00                	mov    (%eax),%eax
c01005de:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01005e1:	7d 1f                	jge    c0100602 <stab_binsearch+0x14c>
c01005e3:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01005e6:	89 d0                	mov    %edx,%eax
c01005e8:	01 c0                	add    %eax,%eax
c01005ea:	01 d0                	add    %edx,%eax
c01005ec:	c1 e0 02             	shl    $0x2,%eax
c01005ef:	89 c2                	mov    %eax,%edx
c01005f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01005f4:	01 d0                	add    %edx,%eax
c01005f6:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01005fa:	0f b6 c0             	movzbl %al,%eax
c01005fd:	3b 45 14             	cmp    0x14(%ebp),%eax
c0100600:	75 d3                	jne    c01005d5 <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
c0100602:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100605:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100608:	89 10                	mov    %edx,(%eax)
    }
}
c010060a:	c9                   	leave  
c010060b:	c3                   	ret    

c010060c <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c010060c:	55                   	push   %ebp
c010060d:	89 e5                	mov    %esp,%ebp
c010060f:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0100612:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100615:	c7 00 38 60 10 c0    	movl   $0xc0106038,(%eax)
    info->eip_line = 0;
c010061b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010061e:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c0100625:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100628:	c7 40 08 38 60 10 c0 	movl   $0xc0106038,0x8(%eax)
    info->eip_fn_namelen = 9;
c010062f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100632:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c0100639:	8b 45 0c             	mov    0xc(%ebp),%eax
c010063c:	8b 55 08             	mov    0x8(%ebp),%edx
c010063f:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0100642:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100645:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c010064c:	c7 45 f4 70 72 10 c0 	movl   $0xc0107270,-0xc(%ebp)
    stab_end = __STAB_END__;
c0100653:	c7 45 f0 a0 1d 11 c0 	movl   $0xc0111da0,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c010065a:	c7 45 ec a1 1d 11 c0 	movl   $0xc0111da1,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c0100661:	c7 45 e8 cd 47 11 c0 	movl   $0xc01147cd,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c0100668:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010066b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010066e:	76 0d                	jbe    c010067d <debuginfo_eip+0x71>
c0100670:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100673:	83 e8 01             	sub    $0x1,%eax
c0100676:	0f b6 00             	movzbl (%eax),%eax
c0100679:	84 c0                	test   %al,%al
c010067b:	74 0a                	je     c0100687 <debuginfo_eip+0x7b>
        return -1;
c010067d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100682:	e9 c0 02 00 00       	jmp    c0100947 <debuginfo_eip+0x33b>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c0100687:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c010068e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100691:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100694:	29 c2                	sub    %eax,%edx
c0100696:	89 d0                	mov    %edx,%eax
c0100698:	c1 f8 02             	sar    $0x2,%eax
c010069b:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01006a1:	83 e8 01             	sub    $0x1,%eax
c01006a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01006a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01006aa:	89 44 24 10          	mov    %eax,0x10(%esp)
c01006ae:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01006b5:	00 
c01006b6:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01006b9:	89 44 24 08          	mov    %eax,0x8(%esp)
c01006bd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c01006c0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01006c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006c7:	89 04 24             	mov    %eax,(%esp)
c01006ca:	e8 e7 fd ff ff       	call   c01004b6 <stab_binsearch>
    if (lfile == 0)
c01006cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006d2:	85 c0                	test   %eax,%eax
c01006d4:	75 0a                	jne    c01006e0 <debuginfo_eip+0xd4>
        return -1;
c01006d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006db:	e9 67 02 00 00       	jmp    c0100947 <debuginfo_eip+0x33b>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c01006e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006e3:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01006e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c01006ec:	8b 45 08             	mov    0x8(%ebp),%eax
c01006ef:	89 44 24 10          	mov    %eax,0x10(%esp)
c01006f3:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c01006fa:	00 
c01006fb:	8d 45 d8             	lea    -0x28(%ebp),%eax
c01006fe:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100702:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100705:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100709:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010070c:	89 04 24             	mov    %eax,(%esp)
c010070f:	e8 a2 fd ff ff       	call   c01004b6 <stab_binsearch>

    if (lfun <= rfun) {
c0100714:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100717:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010071a:	39 c2                	cmp    %eax,%edx
c010071c:	7f 7c                	jg     c010079a <debuginfo_eip+0x18e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c010071e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100721:	89 c2                	mov    %eax,%edx
c0100723:	89 d0                	mov    %edx,%eax
c0100725:	01 c0                	add    %eax,%eax
c0100727:	01 d0                	add    %edx,%eax
c0100729:	c1 e0 02             	shl    $0x2,%eax
c010072c:	89 c2                	mov    %eax,%edx
c010072e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100731:	01 d0                	add    %edx,%eax
c0100733:	8b 10                	mov    (%eax),%edx
c0100735:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0100738:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010073b:	29 c1                	sub    %eax,%ecx
c010073d:	89 c8                	mov    %ecx,%eax
c010073f:	39 c2                	cmp    %eax,%edx
c0100741:	73 22                	jae    c0100765 <debuginfo_eip+0x159>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0100743:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100746:	89 c2                	mov    %eax,%edx
c0100748:	89 d0                	mov    %edx,%eax
c010074a:	01 c0                	add    %eax,%eax
c010074c:	01 d0                	add    %edx,%eax
c010074e:	c1 e0 02             	shl    $0x2,%eax
c0100751:	89 c2                	mov    %eax,%edx
c0100753:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100756:	01 d0                	add    %edx,%eax
c0100758:	8b 10                	mov    (%eax),%edx
c010075a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010075d:	01 c2                	add    %eax,%edx
c010075f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100762:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c0100765:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100768:	89 c2                	mov    %eax,%edx
c010076a:	89 d0                	mov    %edx,%eax
c010076c:	01 c0                	add    %eax,%eax
c010076e:	01 d0                	add    %edx,%eax
c0100770:	c1 e0 02             	shl    $0x2,%eax
c0100773:	89 c2                	mov    %eax,%edx
c0100775:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100778:	01 d0                	add    %edx,%eax
c010077a:	8b 50 08             	mov    0x8(%eax),%edx
c010077d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100780:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c0100783:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100786:	8b 40 10             	mov    0x10(%eax),%eax
c0100789:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c010078c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010078f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c0100792:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100795:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0100798:	eb 15                	jmp    c01007af <debuginfo_eip+0x1a3>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c010079a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010079d:	8b 55 08             	mov    0x8(%ebp),%edx
c01007a0:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01007a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01007a6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c01007a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01007ac:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01007af:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007b2:	8b 40 08             	mov    0x8(%eax),%eax
c01007b5:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01007bc:	00 
c01007bd:	89 04 24             	mov    %eax,(%esp)
c01007c0:	e8 cc 4d 00 00       	call   c0105591 <strfind>
c01007c5:	89 c2                	mov    %eax,%edx
c01007c7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007ca:	8b 40 08             	mov    0x8(%eax),%eax
c01007cd:	29 c2                	sub    %eax,%edx
c01007cf:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007d2:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c01007d5:	8b 45 08             	mov    0x8(%ebp),%eax
c01007d8:	89 44 24 10          	mov    %eax,0x10(%esp)
c01007dc:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c01007e3:	00 
c01007e4:	8d 45 d0             	lea    -0x30(%ebp),%eax
c01007e7:	89 44 24 08          	mov    %eax,0x8(%esp)
c01007eb:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c01007ee:	89 44 24 04          	mov    %eax,0x4(%esp)
c01007f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007f5:	89 04 24             	mov    %eax,(%esp)
c01007f8:	e8 b9 fc ff ff       	call   c01004b6 <stab_binsearch>
    if (lline <= rline) {
c01007fd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100800:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100803:	39 c2                	cmp    %eax,%edx
c0100805:	7f 24                	jg     c010082b <debuginfo_eip+0x21f>
        info->eip_line = stabs[rline].n_desc;
c0100807:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010080a:	89 c2                	mov    %eax,%edx
c010080c:	89 d0                	mov    %edx,%eax
c010080e:	01 c0                	add    %eax,%eax
c0100810:	01 d0                	add    %edx,%eax
c0100812:	c1 e0 02             	shl    $0x2,%eax
c0100815:	89 c2                	mov    %eax,%edx
c0100817:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010081a:	01 d0                	add    %edx,%eax
c010081c:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100820:	0f b7 d0             	movzwl %ax,%edx
c0100823:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100826:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100829:	eb 13                	jmp    c010083e <debuginfo_eip+0x232>
        return -1;
c010082b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100830:	e9 12 01 00 00       	jmp    c0100947 <debuginfo_eip+0x33b>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c0100835:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100838:	83 e8 01             	sub    $0x1,%eax
c010083b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
c010083e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100841:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100844:	39 c2                	cmp    %eax,%edx
c0100846:	7c 56                	jl     c010089e <debuginfo_eip+0x292>
           && stabs[lline].n_type != N_SOL
c0100848:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010084b:	89 c2                	mov    %eax,%edx
c010084d:	89 d0                	mov    %edx,%eax
c010084f:	01 c0                	add    %eax,%eax
c0100851:	01 d0                	add    %edx,%eax
c0100853:	c1 e0 02             	shl    $0x2,%eax
c0100856:	89 c2                	mov    %eax,%edx
c0100858:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010085b:	01 d0                	add    %edx,%eax
c010085d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100861:	3c 84                	cmp    $0x84,%al
c0100863:	74 39                	je     c010089e <debuginfo_eip+0x292>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c0100865:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100868:	89 c2                	mov    %eax,%edx
c010086a:	89 d0                	mov    %edx,%eax
c010086c:	01 c0                	add    %eax,%eax
c010086e:	01 d0                	add    %edx,%eax
c0100870:	c1 e0 02             	shl    $0x2,%eax
c0100873:	89 c2                	mov    %eax,%edx
c0100875:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100878:	01 d0                	add    %edx,%eax
c010087a:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010087e:	3c 64                	cmp    $0x64,%al
c0100880:	75 b3                	jne    c0100835 <debuginfo_eip+0x229>
c0100882:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100885:	89 c2                	mov    %eax,%edx
c0100887:	89 d0                	mov    %edx,%eax
c0100889:	01 c0                	add    %eax,%eax
c010088b:	01 d0                	add    %edx,%eax
c010088d:	c1 e0 02             	shl    $0x2,%eax
c0100890:	89 c2                	mov    %eax,%edx
c0100892:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100895:	01 d0                	add    %edx,%eax
c0100897:	8b 40 08             	mov    0x8(%eax),%eax
c010089a:	85 c0                	test   %eax,%eax
c010089c:	74 97                	je     c0100835 <debuginfo_eip+0x229>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c010089e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01008a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01008a4:	39 c2                	cmp    %eax,%edx
c01008a6:	7c 46                	jl     c01008ee <debuginfo_eip+0x2e2>
c01008a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008ab:	89 c2                	mov    %eax,%edx
c01008ad:	89 d0                	mov    %edx,%eax
c01008af:	01 c0                	add    %eax,%eax
c01008b1:	01 d0                	add    %edx,%eax
c01008b3:	c1 e0 02             	shl    $0x2,%eax
c01008b6:	89 c2                	mov    %eax,%edx
c01008b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008bb:	01 d0                	add    %edx,%eax
c01008bd:	8b 10                	mov    (%eax),%edx
c01008bf:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c01008c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01008c5:	29 c1                	sub    %eax,%ecx
c01008c7:	89 c8                	mov    %ecx,%eax
c01008c9:	39 c2                	cmp    %eax,%edx
c01008cb:	73 21                	jae    c01008ee <debuginfo_eip+0x2e2>
        info->eip_file = stabstr + stabs[lline].n_strx;
c01008cd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008d0:	89 c2                	mov    %eax,%edx
c01008d2:	89 d0                	mov    %edx,%eax
c01008d4:	01 c0                	add    %eax,%eax
c01008d6:	01 d0                	add    %edx,%eax
c01008d8:	c1 e0 02             	shl    $0x2,%eax
c01008db:	89 c2                	mov    %eax,%edx
c01008dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008e0:	01 d0                	add    %edx,%eax
c01008e2:	8b 10                	mov    (%eax),%edx
c01008e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01008e7:	01 c2                	add    %eax,%edx
c01008e9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008ec:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c01008ee:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01008f1:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01008f4:	39 c2                	cmp    %eax,%edx
c01008f6:	7d 4a                	jge    c0100942 <debuginfo_eip+0x336>
        for (lline = lfun + 1;
c01008f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01008fb:	83 c0 01             	add    $0x1,%eax
c01008fe:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100901:	eb 18                	jmp    c010091b <debuginfo_eip+0x30f>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0100903:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100906:	8b 40 14             	mov    0x14(%eax),%eax
c0100909:	8d 50 01             	lea    0x1(%eax),%edx
c010090c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010090f:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
c0100912:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100915:	83 c0 01             	add    $0x1,%eax
c0100918:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
c010091b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010091e:	8b 45 d8             	mov    -0x28(%ebp),%eax
        for (lline = lfun + 1;
c0100921:	39 c2                	cmp    %eax,%edx
c0100923:	7d 1d                	jge    c0100942 <debuginfo_eip+0x336>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100925:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100928:	89 c2                	mov    %eax,%edx
c010092a:	89 d0                	mov    %edx,%eax
c010092c:	01 c0                	add    %eax,%eax
c010092e:	01 d0                	add    %edx,%eax
c0100930:	c1 e0 02             	shl    $0x2,%eax
c0100933:	89 c2                	mov    %eax,%edx
c0100935:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100938:	01 d0                	add    %edx,%eax
c010093a:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010093e:	3c a0                	cmp    $0xa0,%al
c0100940:	74 c1                	je     c0100903 <debuginfo_eip+0x2f7>
        }
    }
    return 0;
c0100942:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100947:	c9                   	leave  
c0100948:	c3                   	ret    

c0100949 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0100949:	55                   	push   %ebp
c010094a:	89 e5                	mov    %esp,%ebp
c010094c:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c010094f:	c7 04 24 42 60 10 c0 	movl   $0xc0106042,(%esp)
c0100956:	e8 37 f9 ff ff       	call   c0100292 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c010095b:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c0100962:	c0 
c0100963:	c7 04 24 5b 60 10 c0 	movl   $0xc010605b,(%esp)
c010096a:	e8 23 f9 ff ff       	call   c0100292 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c010096f:	c7 44 24 04 27 5f 10 	movl   $0xc0105f27,0x4(%esp)
c0100976:	c0 
c0100977:	c7 04 24 73 60 10 c0 	movl   $0xc0106073,(%esp)
c010097e:	e8 0f f9 ff ff       	call   c0100292 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c0100983:	c7 44 24 04 00 a0 11 	movl   $0xc011a000,0x4(%esp)
c010098a:	c0 
c010098b:	c7 04 24 8b 60 10 c0 	movl   $0xc010608b,(%esp)
c0100992:	e8 fb f8 ff ff       	call   c0100292 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c0100997:	c7 44 24 04 28 af 11 	movl   $0xc011af28,0x4(%esp)
c010099e:	c0 
c010099f:	c7 04 24 a3 60 10 c0 	movl   $0xc01060a3,(%esp)
c01009a6:	e8 e7 f8 ff ff       	call   c0100292 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01009ab:	b8 28 af 11 c0       	mov    $0xc011af28,%eax
c01009b0:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009b6:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c01009bb:	29 c2                	sub    %eax,%edx
c01009bd:	89 d0                	mov    %edx,%eax
c01009bf:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009c5:	85 c0                	test   %eax,%eax
c01009c7:	0f 48 c2             	cmovs  %edx,%eax
c01009ca:	c1 f8 0a             	sar    $0xa,%eax
c01009cd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009d1:	c7 04 24 bc 60 10 c0 	movl   $0xc01060bc,(%esp)
c01009d8:	e8 b5 f8 ff ff       	call   c0100292 <cprintf>
}
c01009dd:	c9                   	leave  
c01009de:	c3                   	ret    

c01009df <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c01009df:	55                   	push   %ebp
c01009e0:	89 e5                	mov    %esp,%ebp
c01009e2:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c01009e8:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01009eb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009ef:	8b 45 08             	mov    0x8(%ebp),%eax
c01009f2:	89 04 24             	mov    %eax,(%esp)
c01009f5:	e8 12 fc ff ff       	call   c010060c <debuginfo_eip>
c01009fa:	85 c0                	test   %eax,%eax
c01009fc:	74 15                	je     c0100a13 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c01009fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a01:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a05:	c7 04 24 e6 60 10 c0 	movl   $0xc01060e6,(%esp)
c0100a0c:	e8 81 f8 ff ff       	call   c0100292 <cprintf>
c0100a11:	eb 6d                	jmp    c0100a80 <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a13:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100a1a:	eb 1c                	jmp    c0100a38 <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
c0100a1c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a22:	01 d0                	add    %edx,%eax
c0100a24:	0f b6 00             	movzbl (%eax),%eax
c0100a27:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100a30:	01 ca                	add    %ecx,%edx
c0100a32:	88 02                	mov    %al,(%edx)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a34:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100a38:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a3b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100a3e:	7f dc                	jg     c0100a1c <print_debuginfo+0x3d>
        }
        fnname[j] = '\0';
c0100a40:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100a46:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a49:	01 d0                	add    %edx,%eax
c0100a4b:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c0100a4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100a51:	8b 55 08             	mov    0x8(%ebp),%edx
c0100a54:	89 d1                	mov    %edx,%ecx
c0100a56:	29 c1                	sub    %eax,%ecx
c0100a58:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100a5b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100a5e:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100a62:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a68:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100a6c:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100a70:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a74:	c7 04 24 02 61 10 c0 	movl   $0xc0106102,(%esp)
c0100a7b:	e8 12 f8 ff ff       	call   c0100292 <cprintf>
    }
}
c0100a80:	c9                   	leave  
c0100a81:	c3                   	ret    

c0100a82 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0100a82:	55                   	push   %ebp
c0100a83:	89 e5                	mov    %esp,%ebp
c0100a85:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0100a88:	8b 45 04             	mov    0x4(%ebp),%eax
c0100a8b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0100a8e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100a91:	c9                   	leave  
c0100a92:	c3                   	ret    

c0100a93 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0100a93:	55                   	push   %ebp
c0100a94:	89 e5                	mov    %esp,%ebp
c0100a96:	53                   	push   %ebx
c0100a97:	83 ec 44             	sub    $0x44,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0100a9a:	89 e8                	mov    %ebp,%eax
c0100a9c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return ebp;
c0100a9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp=read_ebp(),eip=read_eip();
c0100aa2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100aa5:	e8 d8 ff ff ff       	call   c0100a82 <read_eip>
c0100aaa:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int i;//这里在for循环里定义好像不行的样子就拿出来了
	for(i=0;ebp!=0&&i<STACKFRAME_DEPTH;i++)
c0100aad:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100ab4:	e9 8d 00 00 00       	jmp    c0100b46 <print_stackframe+0xb3>
    {   
		cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c0100ab9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100abc:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100ac0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ac3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ac7:	c7 04 24 14 61 10 c0 	movl   $0xc0106114,(%esp)
c0100ace:	e8 bf f7 ff ff       	call   c0100292 <cprintf>
		uint32_t *args = (uint32_t *)ebp + 2;       //ebp+8指向参数，+4指向返回值
c0100ad3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ad6:	83 c0 08             	add    $0x8,%eax
c0100ad9:	89 45 e8             	mov    %eax,-0x18(%ebp)
		cprintf("arg :0x%08x 0x%08x 0x%08x 0x%08x\n",*(args+0),*(args+1),*(args+2),*(args+3));
c0100adc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100adf:	83 c0 0c             	add    $0xc,%eax
c0100ae2:	8b 18                	mov    (%eax),%ebx
c0100ae4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100ae7:	83 c0 08             	add    $0x8,%eax
c0100aea:	8b 08                	mov    (%eax),%ecx
c0100aec:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100aef:	83 c0 04             	add    $0x4,%eax
c0100af2:	8b 10                	mov    (%eax),%edx
c0100af4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100af7:	8b 00                	mov    (%eax),%eax
c0100af9:	89 5c 24 10          	mov    %ebx,0x10(%esp)
c0100afd:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100b01:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100b05:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b09:	c7 04 24 30 61 10 c0 	movl   $0xc0106130,(%esp)
c0100b10:	e8 7d f7 ff ff       	call   c0100292 <cprintf>
        //依次打印调用函数的参数1 2 3 4
		cprintf("\n");
c0100b15:	c7 04 24 52 61 10 c0 	movl   $0xc0106152,(%esp)
c0100b1c:	e8 71 f7 ff ff       	call   c0100292 <cprintf>
		print_debuginfo(eip - 1);//eip指向的是下一条指令，所以这里减1  指针占4
c0100b21:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b24:	83 e8 01             	sub    $0x1,%eax
c0100b27:	89 04 24             	mov    %eax,(%esp)
c0100b2a:	e8 b0 fe ff ff       	call   c01009df <print_debuginfo>
		eip = ((uint32_t *)ebp)[1]; //此时eip指向返回地址
c0100b2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b32:	83 c0 04             	add    $0x4,%eax
c0100b35:	8b 00                	mov    (%eax),%eax
c0100b37:	89 45 f0             	mov    %eax,-0x10(%ebp)
		ebp = ((uint32_t *)ebp)[0];//ebp存的是调用者edp，所以这里就复原了调用前edp值
c0100b3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b3d:	8b 00                	mov    (%eax),%eax
c0100b3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for(i=0;ebp!=0&&i<STACKFRAME_DEPTH;i++)
c0100b42:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0100b46:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100b4a:	74 0a                	je     c0100b56 <print_stackframe+0xc3>
c0100b4c:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100b50:	0f 8e 63 ff ff ff    	jle    c0100ab9 <print_stackframe+0x26>
	}
}
c0100b56:	83 c4 44             	add    $0x44,%esp
c0100b59:	5b                   	pop    %ebx
c0100b5a:	5d                   	pop    %ebp
c0100b5b:	c3                   	ret    

c0100b5c <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100b5c:	55                   	push   %ebp
c0100b5d:	89 e5                	mov    %esp,%ebp
c0100b5f:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100b62:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b69:	eb 0c                	jmp    c0100b77 <parse+0x1b>
            *buf ++ = '\0';
c0100b6b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b6e:	8d 50 01             	lea    0x1(%eax),%edx
c0100b71:	89 55 08             	mov    %edx,0x8(%ebp)
c0100b74:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b77:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b7a:	0f b6 00             	movzbl (%eax),%eax
c0100b7d:	84 c0                	test   %al,%al
c0100b7f:	74 1d                	je     c0100b9e <parse+0x42>
c0100b81:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b84:	0f b6 00             	movzbl (%eax),%eax
c0100b87:	0f be c0             	movsbl %al,%eax
c0100b8a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b8e:	c7 04 24 d4 61 10 c0 	movl   $0xc01061d4,(%esp)
c0100b95:	e8 c4 49 00 00       	call   c010555e <strchr>
c0100b9a:	85 c0                	test   %eax,%eax
c0100b9c:	75 cd                	jne    c0100b6b <parse+0xf>
        }
        if (*buf == '\0') {
c0100b9e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ba1:	0f b6 00             	movzbl (%eax),%eax
c0100ba4:	84 c0                	test   %al,%al
c0100ba6:	75 02                	jne    c0100baa <parse+0x4e>
            break;
c0100ba8:	eb 67                	jmp    c0100c11 <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100baa:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100bae:	75 14                	jne    c0100bc4 <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100bb0:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100bb7:	00 
c0100bb8:	c7 04 24 d9 61 10 c0 	movl   $0xc01061d9,(%esp)
c0100bbf:	e8 ce f6 ff ff       	call   c0100292 <cprintf>
        }
        argv[argc ++] = buf;
c0100bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bc7:	8d 50 01             	lea    0x1(%eax),%edx
c0100bca:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100bcd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100bd4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100bd7:	01 c2                	add    %eax,%edx
c0100bd9:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bdc:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100bde:	eb 04                	jmp    c0100be4 <parse+0x88>
            buf ++;
c0100be0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100be4:	8b 45 08             	mov    0x8(%ebp),%eax
c0100be7:	0f b6 00             	movzbl (%eax),%eax
c0100bea:	84 c0                	test   %al,%al
c0100bec:	74 1d                	je     c0100c0b <parse+0xaf>
c0100bee:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bf1:	0f b6 00             	movzbl (%eax),%eax
c0100bf4:	0f be c0             	movsbl %al,%eax
c0100bf7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bfb:	c7 04 24 d4 61 10 c0 	movl   $0xc01061d4,(%esp)
c0100c02:	e8 57 49 00 00       	call   c010555e <strchr>
c0100c07:	85 c0                	test   %eax,%eax
c0100c09:	74 d5                	je     c0100be0 <parse+0x84>
        }
    }
c0100c0b:	90                   	nop
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100c0c:	e9 66 ff ff ff       	jmp    c0100b77 <parse+0x1b>
    return argc;
c0100c11:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100c14:	c9                   	leave  
c0100c15:	c3                   	ret    

c0100c16 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100c16:	55                   	push   %ebp
c0100c17:	89 e5                	mov    %esp,%ebp
c0100c19:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100c1c:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c1f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c23:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c26:	89 04 24             	mov    %eax,(%esp)
c0100c29:	e8 2e ff ff ff       	call   c0100b5c <parse>
c0100c2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100c31:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100c35:	75 0a                	jne    c0100c41 <runcmd+0x2b>
        return 0;
c0100c37:	b8 00 00 00 00       	mov    $0x0,%eax
c0100c3c:	e9 85 00 00 00       	jmp    c0100cc6 <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c41:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c48:	eb 5c                	jmp    c0100ca6 <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100c4a:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100c4d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c50:	89 d0                	mov    %edx,%eax
c0100c52:	01 c0                	add    %eax,%eax
c0100c54:	01 d0                	add    %edx,%eax
c0100c56:	c1 e0 02             	shl    $0x2,%eax
c0100c59:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100c5e:	8b 00                	mov    (%eax),%eax
c0100c60:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100c64:	89 04 24             	mov    %eax,(%esp)
c0100c67:	e8 53 48 00 00       	call   c01054bf <strcmp>
c0100c6c:	85 c0                	test   %eax,%eax
c0100c6e:	75 32                	jne    c0100ca2 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100c70:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c73:	89 d0                	mov    %edx,%eax
c0100c75:	01 c0                	add    %eax,%eax
c0100c77:	01 d0                	add    %edx,%eax
c0100c79:	c1 e0 02             	shl    $0x2,%eax
c0100c7c:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100c81:	8b 40 08             	mov    0x8(%eax),%eax
c0100c84:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100c87:	8d 4a ff             	lea    -0x1(%edx),%ecx
c0100c8a:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100c8d:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100c91:	8d 55 b0             	lea    -0x50(%ebp),%edx
c0100c94:	83 c2 04             	add    $0x4,%edx
c0100c97:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100c9b:	89 0c 24             	mov    %ecx,(%esp)
c0100c9e:	ff d0                	call   *%eax
c0100ca0:	eb 24                	jmp    c0100cc6 <runcmd+0xb0>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100ca2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100ca6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ca9:	83 f8 02             	cmp    $0x2,%eax
c0100cac:	76 9c                	jbe    c0100c4a <runcmd+0x34>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100cae:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100cb1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100cb5:	c7 04 24 f7 61 10 c0 	movl   $0xc01061f7,(%esp)
c0100cbc:	e8 d1 f5 ff ff       	call   c0100292 <cprintf>
    return 0;
c0100cc1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cc6:	c9                   	leave  
c0100cc7:	c3                   	ret    

c0100cc8 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100cc8:	55                   	push   %ebp
c0100cc9:	89 e5                	mov    %esp,%ebp
c0100ccb:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100cce:	c7 04 24 10 62 10 c0 	movl   $0xc0106210,(%esp)
c0100cd5:	e8 b8 f5 ff ff       	call   c0100292 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100cda:	c7 04 24 38 62 10 c0 	movl   $0xc0106238,(%esp)
c0100ce1:	e8 ac f5 ff ff       	call   c0100292 <cprintf>

    if (tf != NULL) {
c0100ce6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100cea:	74 0b                	je     c0100cf7 <kmonitor+0x2f>
        print_trapframe(tf);
c0100cec:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cef:	89 04 24             	mov    %eax,(%esp)
c0100cf2:	e8 99 0d 00 00       	call   c0101a90 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100cf7:	c7 04 24 5d 62 10 c0 	movl   $0xc010625d,(%esp)
c0100cfe:	e8 30 f6 ff ff       	call   c0100333 <readline>
c0100d03:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100d06:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100d0a:	74 18                	je     c0100d24 <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
c0100d0c:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d0f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d13:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d16:	89 04 24             	mov    %eax,(%esp)
c0100d19:	e8 f8 fe ff ff       	call   c0100c16 <runcmd>
c0100d1e:	85 c0                	test   %eax,%eax
c0100d20:	79 02                	jns    c0100d24 <kmonitor+0x5c>
                break;
c0100d22:	eb 02                	jmp    c0100d26 <kmonitor+0x5e>
            }
        }
    }
c0100d24:	eb d1                	jmp    c0100cf7 <kmonitor+0x2f>
}
c0100d26:	c9                   	leave  
c0100d27:	c3                   	ret    

c0100d28 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100d28:	55                   	push   %ebp
c0100d29:	89 e5                	mov    %esp,%ebp
c0100d2b:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d2e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100d35:	eb 3f                	jmp    c0100d76 <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100d37:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d3a:	89 d0                	mov    %edx,%eax
c0100d3c:	01 c0                	add    %eax,%eax
c0100d3e:	01 d0                	add    %edx,%eax
c0100d40:	c1 e0 02             	shl    $0x2,%eax
c0100d43:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100d48:	8b 48 04             	mov    0x4(%eax),%ecx
c0100d4b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d4e:	89 d0                	mov    %edx,%eax
c0100d50:	01 c0                	add    %eax,%eax
c0100d52:	01 d0                	add    %edx,%eax
c0100d54:	c1 e0 02             	shl    $0x2,%eax
c0100d57:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100d5c:	8b 00                	mov    (%eax),%eax
c0100d5e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100d62:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d66:	c7 04 24 61 62 10 c0 	movl   $0xc0106261,(%esp)
c0100d6d:	e8 20 f5 ff ff       	call   c0100292 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d72:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100d76:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d79:	83 f8 02             	cmp    $0x2,%eax
c0100d7c:	76 b9                	jbe    c0100d37 <mon_help+0xf>
    }
    return 0;
c0100d7e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d83:	c9                   	leave  
c0100d84:	c3                   	ret    

c0100d85 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100d85:	55                   	push   %ebp
c0100d86:	89 e5                	mov    %esp,%ebp
c0100d88:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100d8b:	e8 b9 fb ff ff       	call   c0100949 <print_kerninfo>
    return 0;
c0100d90:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d95:	c9                   	leave  
c0100d96:	c3                   	ret    

c0100d97 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100d97:	55                   	push   %ebp
c0100d98:	89 e5                	mov    %esp,%ebp
c0100d9a:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100d9d:	e8 f1 fc ff ff       	call   c0100a93 <print_stackframe>
    return 0;
c0100da2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100da7:	c9                   	leave  
c0100da8:	c3                   	ret    

c0100da9 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100da9:	55                   	push   %ebp
c0100daa:	89 e5                	mov    %esp,%ebp
c0100dac:	83 ec 28             	sub    $0x28,%esp
c0100daf:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c0100db5:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100db9:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100dbd:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100dc1:	ee                   	out    %al,(%dx)
c0100dc2:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100dc8:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
c0100dcc:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100dd0:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100dd4:	ee                   	out    %al,(%dx)
c0100dd5:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
c0100ddb:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
c0100ddf:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100de3:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100de7:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100de8:	c7 05 0c af 11 c0 00 	movl   $0x0,0xc011af0c
c0100def:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100df2:	c7 04 24 6a 62 10 c0 	movl   $0xc010626a,(%esp)
c0100df9:	e8 94 f4 ff ff       	call   c0100292 <cprintf>
    pic_enable(IRQ_TIMER);
c0100dfe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100e05:	e8 18 09 00 00       	call   c0101722 <pic_enable>
}
c0100e0a:	c9                   	leave  
c0100e0b:	c3                   	ret    

c0100e0c <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0100e0c:	55                   	push   %ebp
c0100e0d:	89 e5                	mov    %esp,%ebp
c0100e0f:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100e12:	9c                   	pushf  
c0100e13:	58                   	pop    %eax
c0100e14:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100e17:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100e1a:	25 00 02 00 00       	and    $0x200,%eax
c0100e1f:	85 c0                	test   %eax,%eax
c0100e21:	74 0c                	je     c0100e2f <__intr_save+0x23>
        intr_disable();
c0100e23:	e8 69 0a 00 00       	call   c0101891 <intr_disable>
        return 1;
c0100e28:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e2d:	eb 05                	jmp    c0100e34 <__intr_save+0x28>
    }
    return 0;
c0100e2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e34:	c9                   	leave  
c0100e35:	c3                   	ret    

c0100e36 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100e36:	55                   	push   %ebp
c0100e37:	89 e5                	mov    %esp,%ebp
c0100e39:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100e3c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100e40:	74 05                	je     c0100e47 <__intr_restore+0x11>
        intr_enable();
c0100e42:	e8 44 0a 00 00       	call   c010188b <intr_enable>
    }
}
c0100e47:	c9                   	leave  
c0100e48:	c3                   	ret    

c0100e49 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100e49:	55                   	push   %ebp
c0100e4a:	89 e5                	mov    %esp,%ebp
c0100e4c:	83 ec 10             	sub    $0x10,%esp
c0100e4f:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e55:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100e59:	89 c2                	mov    %eax,%edx
c0100e5b:	ec                   	in     (%dx),%al
c0100e5c:	88 45 fd             	mov    %al,-0x3(%ebp)
c0100e5f:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100e65:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100e69:	89 c2                	mov    %eax,%edx
c0100e6b:	ec                   	in     (%dx),%al
c0100e6c:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100e6f:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100e75:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e79:	89 c2                	mov    %eax,%edx
c0100e7b:	ec                   	in     (%dx),%al
c0100e7c:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100e7f:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
c0100e85:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100e89:	89 c2                	mov    %eax,%edx
c0100e8b:	ec                   	in     (%dx),%al
c0100e8c:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100e8f:	c9                   	leave  
c0100e90:	c3                   	ret    

c0100e91 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100e91:	55                   	push   %ebp
c0100e92:	89 e5                	mov    %esp,%ebp
c0100e94:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100e97:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100e9e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ea1:	0f b7 00             	movzwl (%eax),%eax
c0100ea4:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100ea8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100eab:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100eb0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100eb3:	0f b7 00             	movzwl (%eax),%eax
c0100eb6:	66 3d 5a a5          	cmp    $0xa55a,%ax
c0100eba:	74 12                	je     c0100ece <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100ebc:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100ec3:	66 c7 05 46 a4 11 c0 	movw   $0x3b4,0xc011a446
c0100eca:	b4 03 
c0100ecc:	eb 13                	jmp    c0100ee1 <cga_init+0x50>
    } else {
        *cp = was;
c0100ece:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ed1:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100ed5:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100ed8:	66 c7 05 46 a4 11 c0 	movw   $0x3d4,0xc011a446
c0100edf:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100ee1:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100ee8:	0f b7 c0             	movzwl %ax,%eax
c0100eeb:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0100eef:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ef3:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100ef7:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100efb:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0100efc:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100f03:	83 c0 01             	add    $0x1,%eax
c0100f06:	0f b7 c0             	movzwl %ax,%eax
c0100f09:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f0d:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0100f11:	89 c2                	mov    %eax,%edx
c0100f13:	ec                   	in     (%dx),%al
c0100f14:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0100f17:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f1b:	0f b6 c0             	movzbl %al,%eax
c0100f1e:	c1 e0 08             	shl    $0x8,%eax
c0100f21:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100f24:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100f2b:	0f b7 c0             	movzwl %ax,%eax
c0100f2e:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c0100f32:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f36:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100f3a:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100f3e:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c0100f3f:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100f46:	83 c0 01             	add    $0x1,%eax
c0100f49:	0f b7 c0             	movzwl %ax,%eax
c0100f4c:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f50:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c0100f54:	89 c2                	mov    %eax,%edx
c0100f56:	ec                   	in     (%dx),%al
c0100f57:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
c0100f5a:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100f5e:	0f b6 c0             	movzbl %al,%eax
c0100f61:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100f64:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f67:	a3 40 a4 11 c0       	mov    %eax,0xc011a440
    crt_pos = pos;
c0100f6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100f6f:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
}
c0100f75:	c9                   	leave  
c0100f76:	c3                   	ret    

c0100f77 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100f77:	55                   	push   %ebp
c0100f78:	89 e5                	mov    %esp,%ebp
c0100f7a:	83 ec 48             	sub    $0x48,%esp
c0100f7d:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c0100f83:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f87:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100f8b:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100f8f:	ee                   	out    %al,(%dx)
c0100f90:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
c0100f96:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
c0100f9a:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100f9e:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100fa2:	ee                   	out    %al,(%dx)
c0100fa3:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
c0100fa9:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
c0100fad:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100fb1:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100fb5:	ee                   	out    %al,(%dx)
c0100fb6:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0100fbc:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
c0100fc0:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100fc4:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100fc8:	ee                   	out    %al,(%dx)
c0100fc9:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
c0100fcf:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
c0100fd3:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100fd7:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100fdb:	ee                   	out    %al,(%dx)
c0100fdc:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
c0100fe2:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
c0100fe6:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0100fea:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0100fee:	ee                   	out    %al,(%dx)
c0100fef:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0100ff5:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
c0100ff9:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0100ffd:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101001:	ee                   	out    %al,(%dx)
c0101002:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101008:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
c010100c:	89 c2                	mov    %eax,%edx
c010100e:	ec                   	in     (%dx),%al
c010100f:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
c0101012:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0101016:	3c ff                	cmp    $0xff,%al
c0101018:	0f 95 c0             	setne  %al
c010101b:	0f b6 c0             	movzbl %al,%eax
c010101e:	a3 48 a4 11 c0       	mov    %eax,0xc011a448
c0101023:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101029:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
c010102d:	89 c2                	mov    %eax,%edx
c010102f:	ec                   	in     (%dx),%al
c0101030:	88 45 d5             	mov    %al,-0x2b(%ebp)
c0101033:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
c0101039:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c010103d:	89 c2                	mov    %eax,%edx
c010103f:	ec                   	in     (%dx),%al
c0101040:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0101043:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
c0101048:	85 c0                	test   %eax,%eax
c010104a:	74 0c                	je     c0101058 <serial_init+0xe1>
        pic_enable(IRQ_COM1);
c010104c:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0101053:	e8 ca 06 00 00       	call   c0101722 <pic_enable>
    }
}
c0101058:	c9                   	leave  
c0101059:	c3                   	ret    

c010105a <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c010105a:	55                   	push   %ebp
c010105b:	89 e5                	mov    %esp,%ebp
c010105d:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101060:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101067:	eb 09                	jmp    c0101072 <lpt_putc_sub+0x18>
        delay();
c0101069:	e8 db fd ff ff       	call   c0100e49 <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c010106e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0101072:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c0101078:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c010107c:	89 c2                	mov    %eax,%edx
c010107e:	ec                   	in     (%dx),%al
c010107f:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101082:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101086:	84 c0                	test   %al,%al
c0101088:	78 09                	js     c0101093 <lpt_putc_sub+0x39>
c010108a:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101091:	7e d6                	jle    c0101069 <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
c0101093:	8b 45 08             	mov    0x8(%ebp),%eax
c0101096:	0f b6 c0             	movzbl %al,%eax
c0101099:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
c010109f:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01010a2:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01010a6:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01010aa:	ee                   	out    %al,(%dx)
c01010ab:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c01010b1:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c01010b5:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01010b9:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01010bd:	ee                   	out    %al,(%dx)
c01010be:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
c01010c4:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
c01010c8:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01010cc:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01010d0:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c01010d1:	c9                   	leave  
c01010d2:	c3                   	ret    

c01010d3 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c01010d3:	55                   	push   %ebp
c01010d4:	89 e5                	mov    %esp,%ebp
c01010d6:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01010d9:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01010dd:	74 0d                	je     c01010ec <lpt_putc+0x19>
        lpt_putc_sub(c);
c01010df:	8b 45 08             	mov    0x8(%ebp),%eax
c01010e2:	89 04 24             	mov    %eax,(%esp)
c01010e5:	e8 70 ff ff ff       	call   c010105a <lpt_putc_sub>
c01010ea:	eb 24                	jmp    c0101110 <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
c01010ec:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01010f3:	e8 62 ff ff ff       	call   c010105a <lpt_putc_sub>
        lpt_putc_sub(' ');
c01010f8:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01010ff:	e8 56 ff ff ff       	call   c010105a <lpt_putc_sub>
        lpt_putc_sub('\b');
c0101104:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010110b:	e8 4a ff ff ff       	call   c010105a <lpt_putc_sub>
    }
}
c0101110:	c9                   	leave  
c0101111:	c3                   	ret    

c0101112 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0101112:	55                   	push   %ebp
c0101113:	89 e5                	mov    %esp,%ebp
c0101115:	53                   	push   %ebx
c0101116:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c0101119:	8b 45 08             	mov    0x8(%ebp),%eax
c010111c:	b0 00                	mov    $0x0,%al
c010111e:	85 c0                	test   %eax,%eax
c0101120:	75 07                	jne    c0101129 <cga_putc+0x17>
        c |= 0x0700;
c0101122:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0101129:	8b 45 08             	mov    0x8(%ebp),%eax
c010112c:	0f b6 c0             	movzbl %al,%eax
c010112f:	83 f8 0a             	cmp    $0xa,%eax
c0101132:	74 4c                	je     c0101180 <cga_putc+0x6e>
c0101134:	83 f8 0d             	cmp    $0xd,%eax
c0101137:	74 57                	je     c0101190 <cga_putc+0x7e>
c0101139:	83 f8 08             	cmp    $0x8,%eax
c010113c:	0f 85 88 00 00 00    	jne    c01011ca <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
c0101142:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c0101149:	66 85 c0             	test   %ax,%ax
c010114c:	74 30                	je     c010117e <cga_putc+0x6c>
            crt_pos --;
c010114e:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c0101155:	83 e8 01             	sub    $0x1,%eax
c0101158:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c010115e:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c0101163:	0f b7 15 44 a4 11 c0 	movzwl 0xc011a444,%edx
c010116a:	0f b7 d2             	movzwl %dx,%edx
c010116d:	01 d2                	add    %edx,%edx
c010116f:	01 c2                	add    %eax,%edx
c0101171:	8b 45 08             	mov    0x8(%ebp),%eax
c0101174:	b0 00                	mov    $0x0,%al
c0101176:	83 c8 20             	or     $0x20,%eax
c0101179:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c010117c:	eb 72                	jmp    c01011f0 <cga_putc+0xde>
c010117e:	eb 70                	jmp    c01011f0 <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
c0101180:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c0101187:	83 c0 50             	add    $0x50,%eax
c010118a:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c0101190:	0f b7 1d 44 a4 11 c0 	movzwl 0xc011a444,%ebx
c0101197:	0f b7 0d 44 a4 11 c0 	movzwl 0xc011a444,%ecx
c010119e:	0f b7 c1             	movzwl %cx,%eax
c01011a1:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
c01011a7:	c1 e8 10             	shr    $0x10,%eax
c01011aa:	89 c2                	mov    %eax,%edx
c01011ac:	66 c1 ea 06          	shr    $0x6,%dx
c01011b0:	89 d0                	mov    %edx,%eax
c01011b2:	c1 e0 02             	shl    $0x2,%eax
c01011b5:	01 d0                	add    %edx,%eax
c01011b7:	c1 e0 04             	shl    $0x4,%eax
c01011ba:	29 c1                	sub    %eax,%ecx
c01011bc:	89 ca                	mov    %ecx,%edx
c01011be:	89 d8                	mov    %ebx,%eax
c01011c0:	29 d0                	sub    %edx,%eax
c01011c2:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
        break;
c01011c8:	eb 26                	jmp    c01011f0 <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c01011ca:	8b 0d 40 a4 11 c0    	mov    0xc011a440,%ecx
c01011d0:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c01011d7:	8d 50 01             	lea    0x1(%eax),%edx
c01011da:	66 89 15 44 a4 11 c0 	mov    %dx,0xc011a444
c01011e1:	0f b7 c0             	movzwl %ax,%eax
c01011e4:	01 c0                	add    %eax,%eax
c01011e6:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c01011e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01011ec:	66 89 02             	mov    %ax,(%edx)
        break;
c01011ef:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c01011f0:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c01011f7:	66 3d cf 07          	cmp    $0x7cf,%ax
c01011fb:	76 5b                	jbe    c0101258 <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c01011fd:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c0101202:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0101208:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c010120d:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c0101214:	00 
c0101215:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101219:	89 04 24             	mov    %eax,(%esp)
c010121c:	e8 3b 45 00 00       	call   c010575c <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101221:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101228:	eb 15                	jmp    c010123f <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
c010122a:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c010122f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101232:	01 d2                	add    %edx,%edx
c0101234:	01 d0                	add    %edx,%eax
c0101236:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c010123b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010123f:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c0101246:	7e e2                	jle    c010122a <cga_putc+0x118>
        }
        crt_pos -= CRT_COLS;
c0101248:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c010124f:	83 e8 50             	sub    $0x50,%eax
c0101252:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c0101258:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c010125f:	0f b7 c0             	movzwl %ax,%eax
c0101262:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101266:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
c010126a:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010126e:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101272:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c0101273:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c010127a:	66 c1 e8 08          	shr    $0x8,%ax
c010127e:	0f b6 c0             	movzbl %al,%eax
c0101281:	0f b7 15 46 a4 11 c0 	movzwl 0xc011a446,%edx
c0101288:	83 c2 01             	add    $0x1,%edx
c010128b:	0f b7 d2             	movzwl %dx,%edx
c010128e:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
c0101292:	88 45 ed             	mov    %al,-0x13(%ebp)
c0101295:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101299:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010129d:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c010129e:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c01012a5:	0f b7 c0             	movzwl %ax,%eax
c01012a8:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c01012ac:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
c01012b0:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01012b4:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01012b8:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c01012b9:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c01012c0:	0f b6 c0             	movzbl %al,%eax
c01012c3:	0f b7 15 46 a4 11 c0 	movzwl 0xc011a446,%edx
c01012ca:	83 c2 01             	add    $0x1,%edx
c01012cd:	0f b7 d2             	movzwl %dx,%edx
c01012d0:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01012d4:	88 45 e5             	mov    %al,-0x1b(%ebp)
c01012d7:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01012db:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01012df:	ee                   	out    %al,(%dx)
}
c01012e0:	83 c4 34             	add    $0x34,%esp
c01012e3:	5b                   	pop    %ebx
c01012e4:	5d                   	pop    %ebp
c01012e5:	c3                   	ret    

c01012e6 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c01012e6:	55                   	push   %ebp
c01012e7:	89 e5                	mov    %esp,%ebp
c01012e9:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012ec:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01012f3:	eb 09                	jmp    c01012fe <serial_putc_sub+0x18>
        delay();
c01012f5:	e8 4f fb ff ff       	call   c0100e49 <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012fa:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c01012fe:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101304:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101308:	89 c2                	mov    %eax,%edx
c010130a:	ec                   	in     (%dx),%al
c010130b:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c010130e:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101312:	0f b6 c0             	movzbl %al,%eax
c0101315:	83 e0 20             	and    $0x20,%eax
c0101318:	85 c0                	test   %eax,%eax
c010131a:	75 09                	jne    c0101325 <serial_putc_sub+0x3f>
c010131c:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101323:	7e d0                	jle    c01012f5 <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
c0101325:	8b 45 08             	mov    0x8(%ebp),%eax
c0101328:	0f b6 c0             	movzbl %al,%eax
c010132b:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101331:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101334:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101338:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010133c:	ee                   	out    %al,(%dx)
}
c010133d:	c9                   	leave  
c010133e:	c3                   	ret    

c010133f <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c010133f:	55                   	push   %ebp
c0101340:	89 e5                	mov    %esp,%ebp
c0101342:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101345:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101349:	74 0d                	je     c0101358 <serial_putc+0x19>
        serial_putc_sub(c);
c010134b:	8b 45 08             	mov    0x8(%ebp),%eax
c010134e:	89 04 24             	mov    %eax,(%esp)
c0101351:	e8 90 ff ff ff       	call   c01012e6 <serial_putc_sub>
c0101356:	eb 24                	jmp    c010137c <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
c0101358:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010135f:	e8 82 ff ff ff       	call   c01012e6 <serial_putc_sub>
        serial_putc_sub(' ');
c0101364:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010136b:	e8 76 ff ff ff       	call   c01012e6 <serial_putc_sub>
        serial_putc_sub('\b');
c0101370:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101377:	e8 6a ff ff ff       	call   c01012e6 <serial_putc_sub>
    }
}
c010137c:	c9                   	leave  
c010137d:	c3                   	ret    

c010137e <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c010137e:	55                   	push   %ebp
c010137f:	89 e5                	mov    %esp,%ebp
c0101381:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0101384:	eb 33                	jmp    c01013b9 <cons_intr+0x3b>
        if (c != 0) {
c0101386:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010138a:	74 2d                	je     c01013b9 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c010138c:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c0101391:	8d 50 01             	lea    0x1(%eax),%edx
c0101394:	89 15 64 a6 11 c0    	mov    %edx,0xc011a664
c010139a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010139d:	88 90 60 a4 11 c0    	mov    %dl,-0x3fee5ba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c01013a3:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c01013a8:	3d 00 02 00 00       	cmp    $0x200,%eax
c01013ad:	75 0a                	jne    c01013b9 <cons_intr+0x3b>
                cons.wpos = 0;
c01013af:	c7 05 64 a6 11 c0 00 	movl   $0x0,0xc011a664
c01013b6:	00 00 00 
    while ((c = (*proc)()) != -1) {
c01013b9:	8b 45 08             	mov    0x8(%ebp),%eax
c01013bc:	ff d0                	call   *%eax
c01013be:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01013c1:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c01013c5:	75 bf                	jne    c0101386 <cons_intr+0x8>
            }
        }
    }
}
c01013c7:	c9                   	leave  
c01013c8:	c3                   	ret    

c01013c9 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c01013c9:	55                   	push   %ebp
c01013ca:	89 e5                	mov    %esp,%ebp
c01013cc:	83 ec 10             	sub    $0x10,%esp
c01013cf:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013d5:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01013d9:	89 c2                	mov    %eax,%edx
c01013db:	ec                   	in     (%dx),%al
c01013dc:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01013df:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c01013e3:	0f b6 c0             	movzbl %al,%eax
c01013e6:	83 e0 01             	and    $0x1,%eax
c01013e9:	85 c0                	test   %eax,%eax
c01013eb:	75 07                	jne    c01013f4 <serial_proc_data+0x2b>
        return -1;
c01013ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01013f2:	eb 2a                	jmp    c010141e <serial_proc_data+0x55>
c01013f4:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013fa:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01013fe:	89 c2                	mov    %eax,%edx
c0101400:	ec                   	in     (%dx),%al
c0101401:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c0101404:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c0101408:	0f b6 c0             	movzbl %al,%eax
c010140b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c010140e:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101412:	75 07                	jne    c010141b <serial_proc_data+0x52>
        c = '\b';
c0101414:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c010141b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010141e:	c9                   	leave  
c010141f:	c3                   	ret    

c0101420 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101420:	55                   	push   %ebp
c0101421:	89 e5                	mov    %esp,%ebp
c0101423:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c0101426:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
c010142b:	85 c0                	test   %eax,%eax
c010142d:	74 0c                	je     c010143b <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c010142f:	c7 04 24 c9 13 10 c0 	movl   $0xc01013c9,(%esp)
c0101436:	e8 43 ff ff ff       	call   c010137e <cons_intr>
    }
}
c010143b:	c9                   	leave  
c010143c:	c3                   	ret    

c010143d <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c010143d:	55                   	push   %ebp
c010143e:	89 e5                	mov    %esp,%ebp
c0101440:	83 ec 38             	sub    $0x38,%esp
c0101443:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101449:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c010144d:	89 c2                	mov    %eax,%edx
c010144f:	ec                   	in     (%dx),%al
c0101450:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c0101453:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c0101457:	0f b6 c0             	movzbl %al,%eax
c010145a:	83 e0 01             	and    $0x1,%eax
c010145d:	85 c0                	test   %eax,%eax
c010145f:	75 0a                	jne    c010146b <kbd_proc_data+0x2e>
        return -1;
c0101461:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101466:	e9 59 01 00 00       	jmp    c01015c4 <kbd_proc_data+0x187>
c010146b:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101471:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101475:	89 c2                	mov    %eax,%edx
c0101477:	ec                   	in     (%dx),%al
c0101478:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c010147b:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c010147f:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101482:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c0101486:	75 17                	jne    c010149f <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
c0101488:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c010148d:	83 c8 40             	or     $0x40,%eax
c0101490:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
        return 0;
c0101495:	b8 00 00 00 00       	mov    $0x0,%eax
c010149a:	e9 25 01 00 00       	jmp    c01015c4 <kbd_proc_data+0x187>
    } else if (data & 0x80) {
c010149f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014a3:	84 c0                	test   %al,%al
c01014a5:	79 47                	jns    c01014ee <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c01014a7:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014ac:	83 e0 40             	and    $0x40,%eax
c01014af:	85 c0                	test   %eax,%eax
c01014b1:	75 09                	jne    c01014bc <kbd_proc_data+0x7f>
c01014b3:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014b7:	83 e0 7f             	and    $0x7f,%eax
c01014ba:	eb 04                	jmp    c01014c0 <kbd_proc_data+0x83>
c01014bc:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014c0:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c01014c3:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014c7:	0f b6 80 40 70 11 c0 	movzbl -0x3fee8fc0(%eax),%eax
c01014ce:	83 c8 40             	or     $0x40,%eax
c01014d1:	0f b6 c0             	movzbl %al,%eax
c01014d4:	f7 d0                	not    %eax
c01014d6:	89 c2                	mov    %eax,%edx
c01014d8:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014dd:	21 d0                	and    %edx,%eax
c01014df:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
        return 0;
c01014e4:	b8 00 00 00 00       	mov    $0x0,%eax
c01014e9:	e9 d6 00 00 00       	jmp    c01015c4 <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
c01014ee:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014f3:	83 e0 40             	and    $0x40,%eax
c01014f6:	85 c0                	test   %eax,%eax
c01014f8:	74 11                	je     c010150b <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c01014fa:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c01014fe:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101503:	83 e0 bf             	and    $0xffffffbf,%eax
c0101506:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
    }

    shift |= shiftcode[data];
c010150b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010150f:	0f b6 80 40 70 11 c0 	movzbl -0x3fee8fc0(%eax),%eax
c0101516:	0f b6 d0             	movzbl %al,%edx
c0101519:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c010151e:	09 d0                	or     %edx,%eax
c0101520:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
    shift ^= togglecode[data];
c0101525:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101529:	0f b6 80 40 71 11 c0 	movzbl -0x3fee8ec0(%eax),%eax
c0101530:	0f b6 d0             	movzbl %al,%edx
c0101533:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101538:	31 d0                	xor    %edx,%eax
c010153a:	a3 68 a6 11 c0       	mov    %eax,0xc011a668

    c = charcode[shift & (CTL | SHIFT)][data];
c010153f:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101544:	83 e0 03             	and    $0x3,%eax
c0101547:	8b 14 85 40 75 11 c0 	mov    -0x3fee8ac0(,%eax,4),%edx
c010154e:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101552:	01 d0                	add    %edx,%eax
c0101554:	0f b6 00             	movzbl (%eax),%eax
c0101557:	0f b6 c0             	movzbl %al,%eax
c010155a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c010155d:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101562:	83 e0 08             	and    $0x8,%eax
c0101565:	85 c0                	test   %eax,%eax
c0101567:	74 22                	je     c010158b <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c0101569:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c010156d:	7e 0c                	jle    c010157b <kbd_proc_data+0x13e>
c010156f:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101573:	7f 06                	jg     c010157b <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c0101575:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c0101579:	eb 10                	jmp    c010158b <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c010157b:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c010157f:	7e 0a                	jle    c010158b <kbd_proc_data+0x14e>
c0101581:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c0101585:	7f 04                	jg     c010158b <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c0101587:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c010158b:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101590:	f7 d0                	not    %eax
c0101592:	83 e0 06             	and    $0x6,%eax
c0101595:	85 c0                	test   %eax,%eax
c0101597:	75 28                	jne    c01015c1 <kbd_proc_data+0x184>
c0101599:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c01015a0:	75 1f                	jne    c01015c1 <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
c01015a2:	c7 04 24 85 62 10 c0 	movl   $0xc0106285,(%esp)
c01015a9:	e8 e4 ec ff ff       	call   c0100292 <cprintf>
c01015ae:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c01015b4:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01015b8:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c01015bc:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c01015c0:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c01015c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01015c4:	c9                   	leave  
c01015c5:	c3                   	ret    

c01015c6 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c01015c6:	55                   	push   %ebp
c01015c7:	89 e5                	mov    %esp,%ebp
c01015c9:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c01015cc:	c7 04 24 3d 14 10 c0 	movl   $0xc010143d,(%esp)
c01015d3:	e8 a6 fd ff ff       	call   c010137e <cons_intr>
}
c01015d8:	c9                   	leave  
c01015d9:	c3                   	ret    

c01015da <kbd_init>:

static void
kbd_init(void) {
c01015da:	55                   	push   %ebp
c01015db:	89 e5                	mov    %esp,%ebp
c01015dd:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c01015e0:	e8 e1 ff ff ff       	call   c01015c6 <kbd_intr>
    pic_enable(IRQ_KBD);
c01015e5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01015ec:	e8 31 01 00 00       	call   c0101722 <pic_enable>
}
c01015f1:	c9                   	leave  
c01015f2:	c3                   	ret    

c01015f3 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c01015f3:	55                   	push   %ebp
c01015f4:	89 e5                	mov    %esp,%ebp
c01015f6:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c01015f9:	e8 93 f8 ff ff       	call   c0100e91 <cga_init>
    serial_init();
c01015fe:	e8 74 f9 ff ff       	call   c0100f77 <serial_init>
    kbd_init();
c0101603:	e8 d2 ff ff ff       	call   c01015da <kbd_init>
    if (!serial_exists) {
c0101608:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
c010160d:	85 c0                	test   %eax,%eax
c010160f:	75 0c                	jne    c010161d <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c0101611:	c7 04 24 91 62 10 c0 	movl   $0xc0106291,(%esp)
c0101618:	e8 75 ec ff ff       	call   c0100292 <cprintf>
    }
}
c010161d:	c9                   	leave  
c010161e:	c3                   	ret    

c010161f <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c010161f:	55                   	push   %ebp
c0101620:	89 e5                	mov    %esp,%ebp
c0101622:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0101625:	e8 e2 f7 ff ff       	call   c0100e0c <__intr_save>
c010162a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c010162d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101630:	89 04 24             	mov    %eax,(%esp)
c0101633:	e8 9b fa ff ff       	call   c01010d3 <lpt_putc>
        cga_putc(c);
c0101638:	8b 45 08             	mov    0x8(%ebp),%eax
c010163b:	89 04 24             	mov    %eax,(%esp)
c010163e:	e8 cf fa ff ff       	call   c0101112 <cga_putc>
        serial_putc(c);
c0101643:	8b 45 08             	mov    0x8(%ebp),%eax
c0101646:	89 04 24             	mov    %eax,(%esp)
c0101649:	e8 f1 fc ff ff       	call   c010133f <serial_putc>
    }
    local_intr_restore(intr_flag);
c010164e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101651:	89 04 24             	mov    %eax,(%esp)
c0101654:	e8 dd f7 ff ff       	call   c0100e36 <__intr_restore>
}
c0101659:	c9                   	leave  
c010165a:	c3                   	ret    

c010165b <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c010165b:	55                   	push   %ebp
c010165c:	89 e5                	mov    %esp,%ebp
c010165e:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c0101661:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0101668:	e8 9f f7 ff ff       	call   c0100e0c <__intr_save>
c010166d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101670:	e8 ab fd ff ff       	call   c0101420 <serial_intr>
        kbd_intr();
c0101675:	e8 4c ff ff ff       	call   c01015c6 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c010167a:	8b 15 60 a6 11 c0    	mov    0xc011a660,%edx
c0101680:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c0101685:	39 c2                	cmp    %eax,%edx
c0101687:	74 31                	je     c01016ba <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c0101689:	a1 60 a6 11 c0       	mov    0xc011a660,%eax
c010168e:	8d 50 01             	lea    0x1(%eax),%edx
c0101691:	89 15 60 a6 11 c0    	mov    %edx,0xc011a660
c0101697:	0f b6 80 60 a4 11 c0 	movzbl -0x3fee5ba0(%eax),%eax
c010169e:	0f b6 c0             	movzbl %al,%eax
c01016a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c01016a4:	a1 60 a6 11 c0       	mov    0xc011a660,%eax
c01016a9:	3d 00 02 00 00       	cmp    $0x200,%eax
c01016ae:	75 0a                	jne    c01016ba <cons_getc+0x5f>
                cons.rpos = 0;
c01016b0:	c7 05 60 a6 11 c0 00 	movl   $0x0,0xc011a660
c01016b7:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c01016ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01016bd:	89 04 24             	mov    %eax,(%esp)
c01016c0:	e8 71 f7 ff ff       	call   c0100e36 <__intr_restore>
    return c;
c01016c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01016c8:	c9                   	leave  
c01016c9:	c3                   	ret    

c01016ca <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c01016ca:	55                   	push   %ebp
c01016cb:	89 e5                	mov    %esp,%ebp
c01016cd:	83 ec 14             	sub    $0x14,%esp
c01016d0:	8b 45 08             	mov    0x8(%ebp),%eax
c01016d3:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c01016d7:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01016db:	66 a3 50 75 11 c0    	mov    %ax,0xc0117550
    if (did_init) {
c01016e1:	a1 6c a6 11 c0       	mov    0xc011a66c,%eax
c01016e6:	85 c0                	test   %eax,%eax
c01016e8:	74 36                	je     c0101720 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c01016ea:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01016ee:	0f b6 c0             	movzbl %al,%eax
c01016f1:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c01016f7:	88 45 fd             	mov    %al,-0x3(%ebp)
c01016fa:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c01016fe:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101702:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c0101703:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101707:	66 c1 e8 08          	shr    $0x8,%ax
c010170b:	0f b6 c0             	movzbl %al,%eax
c010170e:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c0101714:	88 45 f9             	mov    %al,-0x7(%ebp)
c0101717:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010171b:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c010171f:	ee                   	out    %al,(%dx)
    }
}
c0101720:	c9                   	leave  
c0101721:	c3                   	ret    

c0101722 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0101722:	55                   	push   %ebp
c0101723:	89 e5                	mov    %esp,%ebp
c0101725:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c0101728:	8b 45 08             	mov    0x8(%ebp),%eax
c010172b:	ba 01 00 00 00       	mov    $0x1,%edx
c0101730:	89 c1                	mov    %eax,%ecx
c0101732:	d3 e2                	shl    %cl,%edx
c0101734:	89 d0                	mov    %edx,%eax
c0101736:	f7 d0                	not    %eax
c0101738:	89 c2                	mov    %eax,%edx
c010173a:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
c0101741:	21 d0                	and    %edx,%eax
c0101743:	0f b7 c0             	movzwl %ax,%eax
c0101746:	89 04 24             	mov    %eax,(%esp)
c0101749:	e8 7c ff ff ff       	call   c01016ca <pic_setmask>
}
c010174e:	c9                   	leave  
c010174f:	c3                   	ret    

c0101750 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0101750:	55                   	push   %ebp
c0101751:	89 e5                	mov    %esp,%ebp
c0101753:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c0101756:	c7 05 6c a6 11 c0 01 	movl   $0x1,0xc011a66c
c010175d:	00 00 00 
c0101760:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0101766:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
c010176a:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c010176e:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101772:	ee                   	out    %al,(%dx)
c0101773:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c0101779:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
c010177d:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101781:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101785:	ee                   	out    %al,(%dx)
c0101786:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c010178c:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
c0101790:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101794:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101798:	ee                   	out    %al,(%dx)
c0101799:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
c010179f:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
c01017a3:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01017a7:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01017ab:	ee                   	out    %al,(%dx)
c01017ac:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
c01017b2:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
c01017b6:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01017ba:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01017be:	ee                   	out    %al,(%dx)
c01017bf:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
c01017c5:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
c01017c9:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01017cd:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01017d1:	ee                   	out    %al,(%dx)
c01017d2:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c01017d8:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
c01017dc:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01017e0:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01017e4:	ee                   	out    %al,(%dx)
c01017e5:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
c01017eb:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
c01017ef:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01017f3:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01017f7:	ee                   	out    %al,(%dx)
c01017f8:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
c01017fe:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
c0101802:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101806:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c010180a:	ee                   	out    %al,(%dx)
c010180b:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
c0101811:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
c0101815:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101819:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c010181d:	ee                   	out    %al,(%dx)
c010181e:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
c0101824:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
c0101828:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c010182c:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101830:	ee                   	out    %al,(%dx)
c0101831:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c0101837:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
c010183b:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c010183f:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0101843:	ee                   	out    %al,(%dx)
c0101844:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
c010184a:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
c010184e:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0101852:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0101856:	ee                   	out    %al,(%dx)
c0101857:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
c010185d:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
c0101861:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0101865:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c0101869:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c010186a:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
c0101871:	66 83 f8 ff          	cmp    $0xffff,%ax
c0101875:	74 12                	je     c0101889 <pic_init+0x139>
        pic_setmask(irq_mask);
c0101877:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
c010187e:	0f b7 c0             	movzwl %ax,%eax
c0101881:	89 04 24             	mov    %eax,(%esp)
c0101884:	e8 41 fe ff ff       	call   c01016ca <pic_setmask>
    }
}
c0101889:	c9                   	leave  
c010188a:	c3                   	ret    

c010188b <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c010188b:	55                   	push   %ebp
c010188c:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
c010188e:	fb                   	sti    
    sti();
}
c010188f:	5d                   	pop    %ebp
c0101890:	c3                   	ret    

c0101891 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c0101891:	55                   	push   %ebp
c0101892:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
c0101894:	fa                   	cli    
    cli();
}
c0101895:	5d                   	pop    %ebp
c0101896:	c3                   	ret    

c0101897 <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c0101897:	55                   	push   %ebp
c0101898:	89 e5                	mov    %esp,%ebp
c010189a:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c010189d:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c01018a4:	00 
c01018a5:	c7 04 24 c0 62 10 c0 	movl   $0xc01062c0,(%esp)
c01018ac:	e8 e1 e9 ff ff       	call   c0100292 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
c01018b1:	c7 04 24 ca 62 10 c0 	movl   $0xc01062ca,(%esp)
c01018b8:	e8 d5 e9 ff ff       	call   c0100292 <cprintf>
    panic("EOT: kernel seems ok.");
c01018bd:	c7 44 24 08 d8 62 10 	movl   $0xc01062d8,0x8(%esp)
c01018c4:	c0 
c01018c5:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
c01018cc:	00 
c01018cd:	c7 04 24 ee 62 10 c0 	movl   $0xc01062ee,(%esp)
c01018d4:	e8 10 eb ff ff       	call   c01003e9 <__panic>

c01018d9 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c01018d9:	55                   	push   %ebp
c01018da:	89 e5                	mov    %esp,%ebp
c01018dc:	83 ec 10             	sub    $0x10,%esp
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];  //保存在vectors.S中的256个中断处理例程的入口地址数组
    int i;
    //使用SETGATE宏，初始化IDT每个表项
    for (i = 0; i < 256; i ++) 
c01018df:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01018e6:	e9 c3 00 00 00       	jmp    c01019ae <idt_init+0xd5>
    { 
    //在中断门描述符表中通过建立中断门描述符，其中存储了中断处理例程的代码段GD_KTEXT和偏移量__vectors[i]
    //特权级为DPL_KERNEL, 通过查询idt[i]就可定位到中断服务例程的起始地址。
     SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c01018eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018ee:	8b 04 85 e0 75 11 c0 	mov    -0x3fee8a20(,%eax,4),%eax
c01018f5:	89 c2                	mov    %eax,%edx
c01018f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018fa:	66 89 14 c5 80 a6 11 	mov    %dx,-0x3fee5980(,%eax,8)
c0101901:	c0 
c0101902:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101905:	66 c7 04 c5 82 a6 11 	movw   $0x8,-0x3fee597e(,%eax,8)
c010190c:	c0 08 00 
c010190f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101912:	0f b6 14 c5 84 a6 11 	movzbl -0x3fee597c(,%eax,8),%edx
c0101919:	c0 
c010191a:	83 e2 e0             	and    $0xffffffe0,%edx
c010191d:	88 14 c5 84 a6 11 c0 	mov    %dl,-0x3fee597c(,%eax,8)
c0101924:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101927:	0f b6 14 c5 84 a6 11 	movzbl -0x3fee597c(,%eax,8),%edx
c010192e:	c0 
c010192f:	83 e2 1f             	and    $0x1f,%edx
c0101932:	88 14 c5 84 a6 11 c0 	mov    %dl,-0x3fee597c(,%eax,8)
c0101939:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010193c:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c0101943:	c0 
c0101944:	83 e2 f0             	and    $0xfffffff0,%edx
c0101947:	83 ca 0e             	or     $0xe,%edx
c010194a:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c0101951:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101954:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c010195b:	c0 
c010195c:	83 e2 ef             	and    $0xffffffef,%edx
c010195f:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c0101966:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101969:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c0101970:	c0 
c0101971:	83 e2 9f             	and    $0xffffff9f,%edx
c0101974:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c010197b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010197e:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c0101985:	c0 
c0101986:	83 ca 80             	or     $0xffffff80,%edx
c0101989:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c0101990:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101993:	8b 04 85 e0 75 11 c0 	mov    -0x3fee8a20(,%eax,4),%eax
c010199a:	c1 e8 10             	shr    $0x10,%eax
c010199d:	89 c2                	mov    %eax,%edx
c010199f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019a2:	66 89 14 c5 86 a6 11 	mov    %dx,-0x3fee597a(,%eax,8)
c01019a9:	c0 
    for (i = 0; i < 256; i ++) 
c01019aa:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c01019ae:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
c01019b5:	0f 8e 30 ff ff ff    	jle    c01018eb <idt_init+0x12>
    }
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT,__vectors[T_SWITCH_TOK], DPL_USER);
c01019bb:	a1 c4 77 11 c0       	mov    0xc01177c4,%eax
c01019c0:	66 a3 48 aa 11 c0    	mov    %ax,0xc011aa48
c01019c6:	66 c7 05 4a aa 11 c0 	movw   $0x8,0xc011aa4a
c01019cd:	08 00 
c01019cf:	0f b6 05 4c aa 11 c0 	movzbl 0xc011aa4c,%eax
c01019d6:	83 e0 e0             	and    $0xffffffe0,%eax
c01019d9:	a2 4c aa 11 c0       	mov    %al,0xc011aa4c
c01019de:	0f b6 05 4c aa 11 c0 	movzbl 0xc011aa4c,%eax
c01019e5:	83 e0 1f             	and    $0x1f,%eax
c01019e8:	a2 4c aa 11 c0       	mov    %al,0xc011aa4c
c01019ed:	0f b6 05 4d aa 11 c0 	movzbl 0xc011aa4d,%eax
c01019f4:	83 e0 f0             	and    $0xfffffff0,%eax
c01019f7:	83 c8 0e             	or     $0xe,%eax
c01019fa:	a2 4d aa 11 c0       	mov    %al,0xc011aa4d
c01019ff:	0f b6 05 4d aa 11 c0 	movzbl 0xc011aa4d,%eax
c0101a06:	83 e0 ef             	and    $0xffffffef,%eax
c0101a09:	a2 4d aa 11 c0       	mov    %al,0xc011aa4d
c0101a0e:	0f b6 05 4d aa 11 c0 	movzbl 0xc011aa4d,%eax
c0101a15:	83 c8 60             	or     $0x60,%eax
c0101a18:	a2 4d aa 11 c0       	mov    %al,0xc011aa4d
c0101a1d:	0f b6 05 4d aa 11 c0 	movzbl 0xc011aa4d,%eax
c0101a24:	83 c8 80             	or     $0xffffff80,%eax
c0101a27:	a2 4d aa 11 c0       	mov    %al,0xc011aa4d
c0101a2c:	a1 c4 77 11 c0       	mov    0xc01177c4,%eax
c0101a31:	c1 e8 10             	shr    $0x10,%eax
c0101a34:	66 a3 4e aa 11 c0    	mov    %ax,0xc011aa4e
c0101a3a:	c7 45 f8 60 75 11 c0 	movl   $0xc0117560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c0101a41:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0101a44:	0f 01 18             	lidtl  (%eax)
     //指令lidt把中断门描述符表的起始地址装入IDTR寄存器
    lidt(&idt_pd);
}
c0101a47:	c9                   	leave  
c0101a48:	c3                   	ret    

c0101a49 <trapname>:

static const char *
trapname(int trapno) {
c0101a49:	55                   	push   %ebp
c0101a4a:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c0101a4c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a4f:	83 f8 13             	cmp    $0x13,%eax
c0101a52:	77 0c                	ja     c0101a60 <trapname+0x17>
        return excnames[trapno];
c0101a54:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a57:	8b 04 85 40 66 10 c0 	mov    -0x3fef99c0(,%eax,4),%eax
c0101a5e:	eb 18                	jmp    c0101a78 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c0101a60:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0101a64:	7e 0d                	jle    c0101a73 <trapname+0x2a>
c0101a66:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0101a6a:	7f 07                	jg     c0101a73 <trapname+0x2a>
        return "Hardware Interrupt";
c0101a6c:	b8 ff 62 10 c0       	mov    $0xc01062ff,%eax
c0101a71:	eb 05                	jmp    c0101a78 <trapname+0x2f>
    }
    return "(unknown trap)";
c0101a73:	b8 12 63 10 c0       	mov    $0xc0106312,%eax
}
c0101a78:	5d                   	pop    %ebp
c0101a79:	c3                   	ret    

c0101a7a <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c0101a7a:	55                   	push   %ebp
c0101a7b:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c0101a7d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a80:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101a84:	66 83 f8 08          	cmp    $0x8,%ax
c0101a88:	0f 94 c0             	sete   %al
c0101a8b:	0f b6 c0             	movzbl %al,%eax
}
c0101a8e:	5d                   	pop    %ebp
c0101a8f:	c3                   	ret    

c0101a90 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0101a90:	55                   	push   %ebp
c0101a91:	89 e5                	mov    %esp,%ebp
c0101a93:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c0101a96:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a99:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a9d:	c7 04 24 53 63 10 c0 	movl   $0xc0106353,(%esp)
c0101aa4:	e8 e9 e7 ff ff       	call   c0100292 <cprintf>
    print_regs(&tf->tf_regs);
c0101aa9:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aac:	89 04 24             	mov    %eax,(%esp)
c0101aaf:	e8 a1 01 00 00       	call   c0101c55 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0101ab4:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ab7:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0101abb:	0f b7 c0             	movzwl %ax,%eax
c0101abe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ac2:	c7 04 24 64 63 10 c0 	movl   $0xc0106364,(%esp)
c0101ac9:	e8 c4 e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0101ace:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ad1:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0101ad5:	0f b7 c0             	movzwl %ax,%eax
c0101ad8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101adc:	c7 04 24 77 63 10 c0 	movl   $0xc0106377,(%esp)
c0101ae3:	e8 aa e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0101ae8:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aeb:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0101aef:	0f b7 c0             	movzwl %ax,%eax
c0101af2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101af6:	c7 04 24 8a 63 10 c0 	movl   $0xc010638a,(%esp)
c0101afd:	e8 90 e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0101b02:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b05:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0101b09:	0f b7 c0             	movzwl %ax,%eax
c0101b0c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b10:	c7 04 24 9d 63 10 c0 	movl   $0xc010639d,(%esp)
c0101b17:	e8 76 e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0101b1c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b1f:	8b 40 30             	mov    0x30(%eax),%eax
c0101b22:	89 04 24             	mov    %eax,(%esp)
c0101b25:	e8 1f ff ff ff       	call   c0101a49 <trapname>
c0101b2a:	8b 55 08             	mov    0x8(%ebp),%edx
c0101b2d:	8b 52 30             	mov    0x30(%edx),%edx
c0101b30:	89 44 24 08          	mov    %eax,0x8(%esp)
c0101b34:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101b38:	c7 04 24 b0 63 10 c0 	movl   $0xc01063b0,(%esp)
c0101b3f:	e8 4e e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0101b44:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b47:	8b 40 34             	mov    0x34(%eax),%eax
c0101b4a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b4e:	c7 04 24 c2 63 10 c0 	movl   $0xc01063c2,(%esp)
c0101b55:	e8 38 e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0101b5a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b5d:	8b 40 38             	mov    0x38(%eax),%eax
c0101b60:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b64:	c7 04 24 d1 63 10 c0 	movl   $0xc01063d1,(%esp)
c0101b6b:	e8 22 e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0101b70:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b73:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101b77:	0f b7 c0             	movzwl %ax,%eax
c0101b7a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b7e:	c7 04 24 e0 63 10 c0 	movl   $0xc01063e0,(%esp)
c0101b85:	e8 08 e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0101b8a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b8d:	8b 40 40             	mov    0x40(%eax),%eax
c0101b90:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b94:	c7 04 24 f3 63 10 c0 	movl   $0xc01063f3,(%esp)
c0101b9b:	e8 f2 e6 ff ff       	call   c0100292 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101ba0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101ba7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0101bae:	eb 3e                	jmp    c0101bee <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0101bb0:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bb3:	8b 50 40             	mov    0x40(%eax),%edx
c0101bb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101bb9:	21 d0                	and    %edx,%eax
c0101bbb:	85 c0                	test   %eax,%eax
c0101bbd:	74 28                	je     c0101be7 <print_trapframe+0x157>
c0101bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101bc2:	8b 04 85 80 75 11 c0 	mov    -0x3fee8a80(,%eax,4),%eax
c0101bc9:	85 c0                	test   %eax,%eax
c0101bcb:	74 1a                	je     c0101be7 <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
c0101bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101bd0:	8b 04 85 80 75 11 c0 	mov    -0x3fee8a80(,%eax,4),%eax
c0101bd7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bdb:	c7 04 24 02 64 10 c0 	movl   $0xc0106402,(%esp)
c0101be2:	e8 ab e6 ff ff       	call   c0100292 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101be7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101beb:	d1 65 f0             	shll   -0x10(%ebp)
c0101bee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101bf1:	83 f8 17             	cmp    $0x17,%eax
c0101bf4:	76 ba                	jbe    c0101bb0 <print_trapframe+0x120>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0101bf6:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bf9:	8b 40 40             	mov    0x40(%eax),%eax
c0101bfc:	25 00 30 00 00       	and    $0x3000,%eax
c0101c01:	c1 e8 0c             	shr    $0xc,%eax
c0101c04:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c08:	c7 04 24 06 64 10 c0 	movl   $0xc0106406,(%esp)
c0101c0f:	e8 7e e6 ff ff       	call   c0100292 <cprintf>

    if (!trap_in_kernel(tf)) {
c0101c14:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c17:	89 04 24             	mov    %eax,(%esp)
c0101c1a:	e8 5b fe ff ff       	call   c0101a7a <trap_in_kernel>
c0101c1f:	85 c0                	test   %eax,%eax
c0101c21:	75 30                	jne    c0101c53 <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0101c23:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c26:	8b 40 44             	mov    0x44(%eax),%eax
c0101c29:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c2d:	c7 04 24 0f 64 10 c0 	movl   $0xc010640f,(%esp)
c0101c34:	e8 59 e6 ff ff       	call   c0100292 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0101c39:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c3c:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0101c40:	0f b7 c0             	movzwl %ax,%eax
c0101c43:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c47:	c7 04 24 1e 64 10 c0 	movl   $0xc010641e,(%esp)
c0101c4e:	e8 3f e6 ff ff       	call   c0100292 <cprintf>
    }
}
c0101c53:	c9                   	leave  
c0101c54:	c3                   	ret    

c0101c55 <print_regs>:

void
print_regs(struct pushregs *regs) {
c0101c55:	55                   	push   %ebp
c0101c56:	89 e5                	mov    %esp,%ebp
c0101c58:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0101c5b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c5e:	8b 00                	mov    (%eax),%eax
c0101c60:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c64:	c7 04 24 31 64 10 c0 	movl   $0xc0106431,(%esp)
c0101c6b:	e8 22 e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0101c70:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c73:	8b 40 04             	mov    0x4(%eax),%eax
c0101c76:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c7a:	c7 04 24 40 64 10 c0 	movl   $0xc0106440,(%esp)
c0101c81:	e8 0c e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0101c86:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c89:	8b 40 08             	mov    0x8(%eax),%eax
c0101c8c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c90:	c7 04 24 4f 64 10 c0 	movl   $0xc010644f,(%esp)
c0101c97:	e8 f6 e5 ff ff       	call   c0100292 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0101c9c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c9f:	8b 40 0c             	mov    0xc(%eax),%eax
c0101ca2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ca6:	c7 04 24 5e 64 10 c0 	movl   $0xc010645e,(%esp)
c0101cad:	e8 e0 e5 ff ff       	call   c0100292 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0101cb2:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cb5:	8b 40 10             	mov    0x10(%eax),%eax
c0101cb8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cbc:	c7 04 24 6d 64 10 c0 	movl   $0xc010646d,(%esp)
c0101cc3:	e8 ca e5 ff ff       	call   c0100292 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0101cc8:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ccb:	8b 40 14             	mov    0x14(%eax),%eax
c0101cce:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cd2:	c7 04 24 7c 64 10 c0 	movl   $0xc010647c,(%esp)
c0101cd9:	e8 b4 e5 ff ff       	call   c0100292 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0101cde:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ce1:	8b 40 18             	mov    0x18(%eax),%eax
c0101ce4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ce8:	c7 04 24 8b 64 10 c0 	movl   $0xc010648b,(%esp)
c0101cef:	e8 9e e5 ff ff       	call   c0100292 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0101cf4:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cf7:	8b 40 1c             	mov    0x1c(%eax),%eax
c0101cfa:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cfe:	c7 04 24 9a 64 10 c0 	movl   $0xc010649a,(%esp)
c0101d05:	e8 88 e5 ff ff       	call   c0100292 <cprintf>
}
c0101d0a:	c9                   	leave  
c0101d0b:	c3                   	ret    

c0101d0c <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
c0101d0c:	55                   	push   %ebp
c0101d0d:	89 e5                	mov    %esp,%ebp
c0101d0f:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
c0101d12:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d15:	8b 40 30             	mov    0x30(%eax),%eax
c0101d18:	83 f8 2f             	cmp    $0x2f,%eax
c0101d1b:	77 21                	ja     c0101d3e <trap_dispatch+0x32>
c0101d1d:	83 f8 2e             	cmp    $0x2e,%eax
c0101d20:	0f 83 0b 01 00 00    	jae    c0101e31 <trap_dispatch+0x125>
c0101d26:	83 f8 21             	cmp    $0x21,%eax
c0101d29:	0f 84 88 00 00 00    	je     c0101db7 <trap_dispatch+0xab>
c0101d2f:	83 f8 24             	cmp    $0x24,%eax
c0101d32:	74 5d                	je     c0101d91 <trap_dispatch+0x85>
c0101d34:	83 f8 20             	cmp    $0x20,%eax
c0101d37:	74 16                	je     c0101d4f <trap_dispatch+0x43>
c0101d39:	e9 bb 00 00 00       	jmp    c0101df9 <trap_dispatch+0xed>
c0101d3e:	83 e8 78             	sub    $0x78,%eax
c0101d41:	83 f8 01             	cmp    $0x1,%eax
c0101d44:	0f 87 af 00 00 00    	ja     c0101df9 <trap_dispatch+0xed>
c0101d4a:	e9 8e 00 00 00       	jmp    c0101ddd <trap_dispatch+0xd1>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
	    if (((++ticks) % TICK_NUM) == 0) {
c0101d4f:	a1 0c af 11 c0       	mov    0xc011af0c,%eax
c0101d54:	83 c0 01             	add    $0x1,%eax
c0101d57:	89 c1                	mov    %eax,%ecx
c0101d59:	89 0d 0c af 11 c0    	mov    %ecx,0xc011af0c
c0101d5f:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0101d64:	89 c8                	mov    %ecx,%eax
c0101d66:	f7 e2                	mul    %edx
c0101d68:	89 d0                	mov    %edx,%eax
c0101d6a:	c1 e8 05             	shr    $0x5,%eax
c0101d6d:	6b c0 64             	imul   $0x64,%eax,%eax
c0101d70:	29 c1                	sub    %eax,%ecx
c0101d72:	89 c8                	mov    %ecx,%eax
c0101d74:	85 c0                	test   %eax,%eax
c0101d76:	75 14                	jne    c0101d8c <trap_dispatch+0x80>
		print_ticks();
c0101d78:	e8 1a fb ff ff       	call   c0101897 <print_ticks>
		ticks = 0;
c0101d7d:	c7 05 0c af 11 c0 00 	movl   $0x0,0xc011af0c
c0101d84:	00 00 00 
        }
        break;
c0101d87:	e9 a6 00 00 00       	jmp    c0101e32 <trap_dispatch+0x126>
c0101d8c:	e9 a1 00 00 00       	jmp    c0101e32 <trap_dispatch+0x126>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0101d91:	e8 c5 f8 ff ff       	call   c010165b <cons_getc>
c0101d96:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0101d99:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101d9d:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101da1:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101da5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101da9:	c7 04 24 a9 64 10 c0 	movl   $0xc01064a9,(%esp)
c0101db0:	e8 dd e4 ff ff       	call   c0100292 <cprintf>
        break;
c0101db5:	eb 7b                	jmp    c0101e32 <trap_dispatch+0x126>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0101db7:	e8 9f f8 ff ff       	call   c010165b <cons_getc>
c0101dbc:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0101dbf:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101dc3:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101dc7:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101dcb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101dcf:	c7 04 24 bb 64 10 c0 	movl   $0xc01064bb,(%esp)
c0101dd6:	e8 b7 e4 ff ff       	call   c0100292 <cprintf>
        break;
c0101ddb:	eb 55                	jmp    c0101e32 <trap_dispatch+0x126>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0101ddd:	c7 44 24 08 ca 64 10 	movl   $0xc01064ca,0x8(%esp)
c0101de4:	c0 
c0101de5:	c7 44 24 04 b2 00 00 	movl   $0xb2,0x4(%esp)
c0101dec:	00 
c0101ded:	c7 04 24 ee 62 10 c0 	movl   $0xc01062ee,(%esp)
c0101df4:	e8 f0 e5 ff ff       	call   c01003e9 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0101df9:	8b 45 08             	mov    0x8(%ebp),%eax
c0101dfc:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101e00:	0f b7 c0             	movzwl %ax,%eax
c0101e03:	83 e0 03             	and    $0x3,%eax
c0101e06:	85 c0                	test   %eax,%eax
c0101e08:	75 28                	jne    c0101e32 <trap_dispatch+0x126>
            print_trapframe(tf);
c0101e0a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e0d:	89 04 24             	mov    %eax,(%esp)
c0101e10:	e8 7b fc ff ff       	call   c0101a90 <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0101e15:	c7 44 24 08 da 64 10 	movl   $0xc01064da,0x8(%esp)
c0101e1c:	c0 
c0101e1d:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c0101e24:	00 
c0101e25:	c7 04 24 ee 62 10 c0 	movl   $0xc01062ee,(%esp)
c0101e2c:	e8 b8 e5 ff ff       	call   c01003e9 <__panic>
        break;
c0101e31:	90                   	nop
        }
    }
}
c0101e32:	c9                   	leave  
c0101e33:	c3                   	ret    

c0101e34 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0101e34:	55                   	push   %ebp
c0101e35:	89 e5                	mov    %esp,%ebp
c0101e37:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0101e3a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e3d:	89 04 24             	mov    %eax,(%esp)
c0101e40:	e8 c7 fe ff ff       	call   c0101d0c <trap_dispatch>
}
c0101e45:	c9                   	leave  
c0101e46:	c3                   	ret    

c0101e47 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0101e47:	6a 00                	push   $0x0
  pushl $0
c0101e49:	6a 00                	push   $0x0
  jmp __alltraps
c0101e4b:	e9 69 0a 00 00       	jmp    c01028b9 <__alltraps>

c0101e50 <vector1>:
.globl vector1
vector1:
  pushl $0
c0101e50:	6a 00                	push   $0x0
  pushl $1
c0101e52:	6a 01                	push   $0x1
  jmp __alltraps
c0101e54:	e9 60 0a 00 00       	jmp    c01028b9 <__alltraps>

c0101e59 <vector2>:
.globl vector2
vector2:
  pushl $0
c0101e59:	6a 00                	push   $0x0
  pushl $2
c0101e5b:	6a 02                	push   $0x2
  jmp __alltraps
c0101e5d:	e9 57 0a 00 00       	jmp    c01028b9 <__alltraps>

c0101e62 <vector3>:
.globl vector3
vector3:
  pushl $0
c0101e62:	6a 00                	push   $0x0
  pushl $3
c0101e64:	6a 03                	push   $0x3
  jmp __alltraps
c0101e66:	e9 4e 0a 00 00       	jmp    c01028b9 <__alltraps>

c0101e6b <vector4>:
.globl vector4
vector4:
  pushl $0
c0101e6b:	6a 00                	push   $0x0
  pushl $4
c0101e6d:	6a 04                	push   $0x4
  jmp __alltraps
c0101e6f:	e9 45 0a 00 00       	jmp    c01028b9 <__alltraps>

c0101e74 <vector5>:
.globl vector5
vector5:
  pushl $0
c0101e74:	6a 00                	push   $0x0
  pushl $5
c0101e76:	6a 05                	push   $0x5
  jmp __alltraps
c0101e78:	e9 3c 0a 00 00       	jmp    c01028b9 <__alltraps>

c0101e7d <vector6>:
.globl vector6
vector6:
  pushl $0
c0101e7d:	6a 00                	push   $0x0
  pushl $6
c0101e7f:	6a 06                	push   $0x6
  jmp __alltraps
c0101e81:	e9 33 0a 00 00       	jmp    c01028b9 <__alltraps>

c0101e86 <vector7>:
.globl vector7
vector7:
  pushl $0
c0101e86:	6a 00                	push   $0x0
  pushl $7
c0101e88:	6a 07                	push   $0x7
  jmp __alltraps
c0101e8a:	e9 2a 0a 00 00       	jmp    c01028b9 <__alltraps>

c0101e8f <vector8>:
.globl vector8
vector8:
  pushl $8
c0101e8f:	6a 08                	push   $0x8
  jmp __alltraps
c0101e91:	e9 23 0a 00 00       	jmp    c01028b9 <__alltraps>

c0101e96 <vector9>:
.globl vector9
vector9:
  pushl $0
c0101e96:	6a 00                	push   $0x0
  pushl $9
c0101e98:	6a 09                	push   $0x9
  jmp __alltraps
c0101e9a:	e9 1a 0a 00 00       	jmp    c01028b9 <__alltraps>

c0101e9f <vector10>:
.globl vector10
vector10:
  pushl $10
c0101e9f:	6a 0a                	push   $0xa
  jmp __alltraps
c0101ea1:	e9 13 0a 00 00       	jmp    c01028b9 <__alltraps>

c0101ea6 <vector11>:
.globl vector11
vector11:
  pushl $11
c0101ea6:	6a 0b                	push   $0xb
  jmp __alltraps
c0101ea8:	e9 0c 0a 00 00       	jmp    c01028b9 <__alltraps>

c0101ead <vector12>:
.globl vector12
vector12:
  pushl $12
c0101ead:	6a 0c                	push   $0xc
  jmp __alltraps
c0101eaf:	e9 05 0a 00 00       	jmp    c01028b9 <__alltraps>

c0101eb4 <vector13>:
.globl vector13
vector13:
  pushl $13
c0101eb4:	6a 0d                	push   $0xd
  jmp __alltraps
c0101eb6:	e9 fe 09 00 00       	jmp    c01028b9 <__alltraps>

c0101ebb <vector14>:
.globl vector14
vector14:
  pushl $14
c0101ebb:	6a 0e                	push   $0xe
  jmp __alltraps
c0101ebd:	e9 f7 09 00 00       	jmp    c01028b9 <__alltraps>

c0101ec2 <vector15>:
.globl vector15
vector15:
  pushl $0
c0101ec2:	6a 00                	push   $0x0
  pushl $15
c0101ec4:	6a 0f                	push   $0xf
  jmp __alltraps
c0101ec6:	e9 ee 09 00 00       	jmp    c01028b9 <__alltraps>

c0101ecb <vector16>:
.globl vector16
vector16:
  pushl $0
c0101ecb:	6a 00                	push   $0x0
  pushl $16
c0101ecd:	6a 10                	push   $0x10
  jmp __alltraps
c0101ecf:	e9 e5 09 00 00       	jmp    c01028b9 <__alltraps>

c0101ed4 <vector17>:
.globl vector17
vector17:
  pushl $17
c0101ed4:	6a 11                	push   $0x11
  jmp __alltraps
c0101ed6:	e9 de 09 00 00       	jmp    c01028b9 <__alltraps>

c0101edb <vector18>:
.globl vector18
vector18:
  pushl $0
c0101edb:	6a 00                	push   $0x0
  pushl $18
c0101edd:	6a 12                	push   $0x12
  jmp __alltraps
c0101edf:	e9 d5 09 00 00       	jmp    c01028b9 <__alltraps>

c0101ee4 <vector19>:
.globl vector19
vector19:
  pushl $0
c0101ee4:	6a 00                	push   $0x0
  pushl $19
c0101ee6:	6a 13                	push   $0x13
  jmp __alltraps
c0101ee8:	e9 cc 09 00 00       	jmp    c01028b9 <__alltraps>

c0101eed <vector20>:
.globl vector20
vector20:
  pushl $0
c0101eed:	6a 00                	push   $0x0
  pushl $20
c0101eef:	6a 14                	push   $0x14
  jmp __alltraps
c0101ef1:	e9 c3 09 00 00       	jmp    c01028b9 <__alltraps>

c0101ef6 <vector21>:
.globl vector21
vector21:
  pushl $0
c0101ef6:	6a 00                	push   $0x0
  pushl $21
c0101ef8:	6a 15                	push   $0x15
  jmp __alltraps
c0101efa:	e9 ba 09 00 00       	jmp    c01028b9 <__alltraps>

c0101eff <vector22>:
.globl vector22
vector22:
  pushl $0
c0101eff:	6a 00                	push   $0x0
  pushl $22
c0101f01:	6a 16                	push   $0x16
  jmp __alltraps
c0101f03:	e9 b1 09 00 00       	jmp    c01028b9 <__alltraps>

c0101f08 <vector23>:
.globl vector23
vector23:
  pushl $0
c0101f08:	6a 00                	push   $0x0
  pushl $23
c0101f0a:	6a 17                	push   $0x17
  jmp __alltraps
c0101f0c:	e9 a8 09 00 00       	jmp    c01028b9 <__alltraps>

c0101f11 <vector24>:
.globl vector24
vector24:
  pushl $0
c0101f11:	6a 00                	push   $0x0
  pushl $24
c0101f13:	6a 18                	push   $0x18
  jmp __alltraps
c0101f15:	e9 9f 09 00 00       	jmp    c01028b9 <__alltraps>

c0101f1a <vector25>:
.globl vector25
vector25:
  pushl $0
c0101f1a:	6a 00                	push   $0x0
  pushl $25
c0101f1c:	6a 19                	push   $0x19
  jmp __alltraps
c0101f1e:	e9 96 09 00 00       	jmp    c01028b9 <__alltraps>

c0101f23 <vector26>:
.globl vector26
vector26:
  pushl $0
c0101f23:	6a 00                	push   $0x0
  pushl $26
c0101f25:	6a 1a                	push   $0x1a
  jmp __alltraps
c0101f27:	e9 8d 09 00 00       	jmp    c01028b9 <__alltraps>

c0101f2c <vector27>:
.globl vector27
vector27:
  pushl $0
c0101f2c:	6a 00                	push   $0x0
  pushl $27
c0101f2e:	6a 1b                	push   $0x1b
  jmp __alltraps
c0101f30:	e9 84 09 00 00       	jmp    c01028b9 <__alltraps>

c0101f35 <vector28>:
.globl vector28
vector28:
  pushl $0
c0101f35:	6a 00                	push   $0x0
  pushl $28
c0101f37:	6a 1c                	push   $0x1c
  jmp __alltraps
c0101f39:	e9 7b 09 00 00       	jmp    c01028b9 <__alltraps>

c0101f3e <vector29>:
.globl vector29
vector29:
  pushl $0
c0101f3e:	6a 00                	push   $0x0
  pushl $29
c0101f40:	6a 1d                	push   $0x1d
  jmp __alltraps
c0101f42:	e9 72 09 00 00       	jmp    c01028b9 <__alltraps>

c0101f47 <vector30>:
.globl vector30
vector30:
  pushl $0
c0101f47:	6a 00                	push   $0x0
  pushl $30
c0101f49:	6a 1e                	push   $0x1e
  jmp __alltraps
c0101f4b:	e9 69 09 00 00       	jmp    c01028b9 <__alltraps>

c0101f50 <vector31>:
.globl vector31
vector31:
  pushl $0
c0101f50:	6a 00                	push   $0x0
  pushl $31
c0101f52:	6a 1f                	push   $0x1f
  jmp __alltraps
c0101f54:	e9 60 09 00 00       	jmp    c01028b9 <__alltraps>

c0101f59 <vector32>:
.globl vector32
vector32:
  pushl $0
c0101f59:	6a 00                	push   $0x0
  pushl $32
c0101f5b:	6a 20                	push   $0x20
  jmp __alltraps
c0101f5d:	e9 57 09 00 00       	jmp    c01028b9 <__alltraps>

c0101f62 <vector33>:
.globl vector33
vector33:
  pushl $0
c0101f62:	6a 00                	push   $0x0
  pushl $33
c0101f64:	6a 21                	push   $0x21
  jmp __alltraps
c0101f66:	e9 4e 09 00 00       	jmp    c01028b9 <__alltraps>

c0101f6b <vector34>:
.globl vector34
vector34:
  pushl $0
c0101f6b:	6a 00                	push   $0x0
  pushl $34
c0101f6d:	6a 22                	push   $0x22
  jmp __alltraps
c0101f6f:	e9 45 09 00 00       	jmp    c01028b9 <__alltraps>

c0101f74 <vector35>:
.globl vector35
vector35:
  pushl $0
c0101f74:	6a 00                	push   $0x0
  pushl $35
c0101f76:	6a 23                	push   $0x23
  jmp __alltraps
c0101f78:	e9 3c 09 00 00       	jmp    c01028b9 <__alltraps>

c0101f7d <vector36>:
.globl vector36
vector36:
  pushl $0
c0101f7d:	6a 00                	push   $0x0
  pushl $36
c0101f7f:	6a 24                	push   $0x24
  jmp __alltraps
c0101f81:	e9 33 09 00 00       	jmp    c01028b9 <__alltraps>

c0101f86 <vector37>:
.globl vector37
vector37:
  pushl $0
c0101f86:	6a 00                	push   $0x0
  pushl $37
c0101f88:	6a 25                	push   $0x25
  jmp __alltraps
c0101f8a:	e9 2a 09 00 00       	jmp    c01028b9 <__alltraps>

c0101f8f <vector38>:
.globl vector38
vector38:
  pushl $0
c0101f8f:	6a 00                	push   $0x0
  pushl $38
c0101f91:	6a 26                	push   $0x26
  jmp __alltraps
c0101f93:	e9 21 09 00 00       	jmp    c01028b9 <__alltraps>

c0101f98 <vector39>:
.globl vector39
vector39:
  pushl $0
c0101f98:	6a 00                	push   $0x0
  pushl $39
c0101f9a:	6a 27                	push   $0x27
  jmp __alltraps
c0101f9c:	e9 18 09 00 00       	jmp    c01028b9 <__alltraps>

c0101fa1 <vector40>:
.globl vector40
vector40:
  pushl $0
c0101fa1:	6a 00                	push   $0x0
  pushl $40
c0101fa3:	6a 28                	push   $0x28
  jmp __alltraps
c0101fa5:	e9 0f 09 00 00       	jmp    c01028b9 <__alltraps>

c0101faa <vector41>:
.globl vector41
vector41:
  pushl $0
c0101faa:	6a 00                	push   $0x0
  pushl $41
c0101fac:	6a 29                	push   $0x29
  jmp __alltraps
c0101fae:	e9 06 09 00 00       	jmp    c01028b9 <__alltraps>

c0101fb3 <vector42>:
.globl vector42
vector42:
  pushl $0
c0101fb3:	6a 00                	push   $0x0
  pushl $42
c0101fb5:	6a 2a                	push   $0x2a
  jmp __alltraps
c0101fb7:	e9 fd 08 00 00       	jmp    c01028b9 <__alltraps>

c0101fbc <vector43>:
.globl vector43
vector43:
  pushl $0
c0101fbc:	6a 00                	push   $0x0
  pushl $43
c0101fbe:	6a 2b                	push   $0x2b
  jmp __alltraps
c0101fc0:	e9 f4 08 00 00       	jmp    c01028b9 <__alltraps>

c0101fc5 <vector44>:
.globl vector44
vector44:
  pushl $0
c0101fc5:	6a 00                	push   $0x0
  pushl $44
c0101fc7:	6a 2c                	push   $0x2c
  jmp __alltraps
c0101fc9:	e9 eb 08 00 00       	jmp    c01028b9 <__alltraps>

c0101fce <vector45>:
.globl vector45
vector45:
  pushl $0
c0101fce:	6a 00                	push   $0x0
  pushl $45
c0101fd0:	6a 2d                	push   $0x2d
  jmp __alltraps
c0101fd2:	e9 e2 08 00 00       	jmp    c01028b9 <__alltraps>

c0101fd7 <vector46>:
.globl vector46
vector46:
  pushl $0
c0101fd7:	6a 00                	push   $0x0
  pushl $46
c0101fd9:	6a 2e                	push   $0x2e
  jmp __alltraps
c0101fdb:	e9 d9 08 00 00       	jmp    c01028b9 <__alltraps>

c0101fe0 <vector47>:
.globl vector47
vector47:
  pushl $0
c0101fe0:	6a 00                	push   $0x0
  pushl $47
c0101fe2:	6a 2f                	push   $0x2f
  jmp __alltraps
c0101fe4:	e9 d0 08 00 00       	jmp    c01028b9 <__alltraps>

c0101fe9 <vector48>:
.globl vector48
vector48:
  pushl $0
c0101fe9:	6a 00                	push   $0x0
  pushl $48
c0101feb:	6a 30                	push   $0x30
  jmp __alltraps
c0101fed:	e9 c7 08 00 00       	jmp    c01028b9 <__alltraps>

c0101ff2 <vector49>:
.globl vector49
vector49:
  pushl $0
c0101ff2:	6a 00                	push   $0x0
  pushl $49
c0101ff4:	6a 31                	push   $0x31
  jmp __alltraps
c0101ff6:	e9 be 08 00 00       	jmp    c01028b9 <__alltraps>

c0101ffb <vector50>:
.globl vector50
vector50:
  pushl $0
c0101ffb:	6a 00                	push   $0x0
  pushl $50
c0101ffd:	6a 32                	push   $0x32
  jmp __alltraps
c0101fff:	e9 b5 08 00 00       	jmp    c01028b9 <__alltraps>

c0102004 <vector51>:
.globl vector51
vector51:
  pushl $0
c0102004:	6a 00                	push   $0x0
  pushl $51
c0102006:	6a 33                	push   $0x33
  jmp __alltraps
c0102008:	e9 ac 08 00 00       	jmp    c01028b9 <__alltraps>

c010200d <vector52>:
.globl vector52
vector52:
  pushl $0
c010200d:	6a 00                	push   $0x0
  pushl $52
c010200f:	6a 34                	push   $0x34
  jmp __alltraps
c0102011:	e9 a3 08 00 00       	jmp    c01028b9 <__alltraps>

c0102016 <vector53>:
.globl vector53
vector53:
  pushl $0
c0102016:	6a 00                	push   $0x0
  pushl $53
c0102018:	6a 35                	push   $0x35
  jmp __alltraps
c010201a:	e9 9a 08 00 00       	jmp    c01028b9 <__alltraps>

c010201f <vector54>:
.globl vector54
vector54:
  pushl $0
c010201f:	6a 00                	push   $0x0
  pushl $54
c0102021:	6a 36                	push   $0x36
  jmp __alltraps
c0102023:	e9 91 08 00 00       	jmp    c01028b9 <__alltraps>

c0102028 <vector55>:
.globl vector55
vector55:
  pushl $0
c0102028:	6a 00                	push   $0x0
  pushl $55
c010202a:	6a 37                	push   $0x37
  jmp __alltraps
c010202c:	e9 88 08 00 00       	jmp    c01028b9 <__alltraps>

c0102031 <vector56>:
.globl vector56
vector56:
  pushl $0
c0102031:	6a 00                	push   $0x0
  pushl $56
c0102033:	6a 38                	push   $0x38
  jmp __alltraps
c0102035:	e9 7f 08 00 00       	jmp    c01028b9 <__alltraps>

c010203a <vector57>:
.globl vector57
vector57:
  pushl $0
c010203a:	6a 00                	push   $0x0
  pushl $57
c010203c:	6a 39                	push   $0x39
  jmp __alltraps
c010203e:	e9 76 08 00 00       	jmp    c01028b9 <__alltraps>

c0102043 <vector58>:
.globl vector58
vector58:
  pushl $0
c0102043:	6a 00                	push   $0x0
  pushl $58
c0102045:	6a 3a                	push   $0x3a
  jmp __alltraps
c0102047:	e9 6d 08 00 00       	jmp    c01028b9 <__alltraps>

c010204c <vector59>:
.globl vector59
vector59:
  pushl $0
c010204c:	6a 00                	push   $0x0
  pushl $59
c010204e:	6a 3b                	push   $0x3b
  jmp __alltraps
c0102050:	e9 64 08 00 00       	jmp    c01028b9 <__alltraps>

c0102055 <vector60>:
.globl vector60
vector60:
  pushl $0
c0102055:	6a 00                	push   $0x0
  pushl $60
c0102057:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102059:	e9 5b 08 00 00       	jmp    c01028b9 <__alltraps>

c010205e <vector61>:
.globl vector61
vector61:
  pushl $0
c010205e:	6a 00                	push   $0x0
  pushl $61
c0102060:	6a 3d                	push   $0x3d
  jmp __alltraps
c0102062:	e9 52 08 00 00       	jmp    c01028b9 <__alltraps>

c0102067 <vector62>:
.globl vector62
vector62:
  pushl $0
c0102067:	6a 00                	push   $0x0
  pushl $62
c0102069:	6a 3e                	push   $0x3e
  jmp __alltraps
c010206b:	e9 49 08 00 00       	jmp    c01028b9 <__alltraps>

c0102070 <vector63>:
.globl vector63
vector63:
  pushl $0
c0102070:	6a 00                	push   $0x0
  pushl $63
c0102072:	6a 3f                	push   $0x3f
  jmp __alltraps
c0102074:	e9 40 08 00 00       	jmp    c01028b9 <__alltraps>

c0102079 <vector64>:
.globl vector64
vector64:
  pushl $0
c0102079:	6a 00                	push   $0x0
  pushl $64
c010207b:	6a 40                	push   $0x40
  jmp __alltraps
c010207d:	e9 37 08 00 00       	jmp    c01028b9 <__alltraps>

c0102082 <vector65>:
.globl vector65
vector65:
  pushl $0
c0102082:	6a 00                	push   $0x0
  pushl $65
c0102084:	6a 41                	push   $0x41
  jmp __alltraps
c0102086:	e9 2e 08 00 00       	jmp    c01028b9 <__alltraps>

c010208b <vector66>:
.globl vector66
vector66:
  pushl $0
c010208b:	6a 00                	push   $0x0
  pushl $66
c010208d:	6a 42                	push   $0x42
  jmp __alltraps
c010208f:	e9 25 08 00 00       	jmp    c01028b9 <__alltraps>

c0102094 <vector67>:
.globl vector67
vector67:
  pushl $0
c0102094:	6a 00                	push   $0x0
  pushl $67
c0102096:	6a 43                	push   $0x43
  jmp __alltraps
c0102098:	e9 1c 08 00 00       	jmp    c01028b9 <__alltraps>

c010209d <vector68>:
.globl vector68
vector68:
  pushl $0
c010209d:	6a 00                	push   $0x0
  pushl $68
c010209f:	6a 44                	push   $0x44
  jmp __alltraps
c01020a1:	e9 13 08 00 00       	jmp    c01028b9 <__alltraps>

c01020a6 <vector69>:
.globl vector69
vector69:
  pushl $0
c01020a6:	6a 00                	push   $0x0
  pushl $69
c01020a8:	6a 45                	push   $0x45
  jmp __alltraps
c01020aa:	e9 0a 08 00 00       	jmp    c01028b9 <__alltraps>

c01020af <vector70>:
.globl vector70
vector70:
  pushl $0
c01020af:	6a 00                	push   $0x0
  pushl $70
c01020b1:	6a 46                	push   $0x46
  jmp __alltraps
c01020b3:	e9 01 08 00 00       	jmp    c01028b9 <__alltraps>

c01020b8 <vector71>:
.globl vector71
vector71:
  pushl $0
c01020b8:	6a 00                	push   $0x0
  pushl $71
c01020ba:	6a 47                	push   $0x47
  jmp __alltraps
c01020bc:	e9 f8 07 00 00       	jmp    c01028b9 <__alltraps>

c01020c1 <vector72>:
.globl vector72
vector72:
  pushl $0
c01020c1:	6a 00                	push   $0x0
  pushl $72
c01020c3:	6a 48                	push   $0x48
  jmp __alltraps
c01020c5:	e9 ef 07 00 00       	jmp    c01028b9 <__alltraps>

c01020ca <vector73>:
.globl vector73
vector73:
  pushl $0
c01020ca:	6a 00                	push   $0x0
  pushl $73
c01020cc:	6a 49                	push   $0x49
  jmp __alltraps
c01020ce:	e9 e6 07 00 00       	jmp    c01028b9 <__alltraps>

c01020d3 <vector74>:
.globl vector74
vector74:
  pushl $0
c01020d3:	6a 00                	push   $0x0
  pushl $74
c01020d5:	6a 4a                	push   $0x4a
  jmp __alltraps
c01020d7:	e9 dd 07 00 00       	jmp    c01028b9 <__alltraps>

c01020dc <vector75>:
.globl vector75
vector75:
  pushl $0
c01020dc:	6a 00                	push   $0x0
  pushl $75
c01020de:	6a 4b                	push   $0x4b
  jmp __alltraps
c01020e0:	e9 d4 07 00 00       	jmp    c01028b9 <__alltraps>

c01020e5 <vector76>:
.globl vector76
vector76:
  pushl $0
c01020e5:	6a 00                	push   $0x0
  pushl $76
c01020e7:	6a 4c                	push   $0x4c
  jmp __alltraps
c01020e9:	e9 cb 07 00 00       	jmp    c01028b9 <__alltraps>

c01020ee <vector77>:
.globl vector77
vector77:
  pushl $0
c01020ee:	6a 00                	push   $0x0
  pushl $77
c01020f0:	6a 4d                	push   $0x4d
  jmp __alltraps
c01020f2:	e9 c2 07 00 00       	jmp    c01028b9 <__alltraps>

c01020f7 <vector78>:
.globl vector78
vector78:
  pushl $0
c01020f7:	6a 00                	push   $0x0
  pushl $78
c01020f9:	6a 4e                	push   $0x4e
  jmp __alltraps
c01020fb:	e9 b9 07 00 00       	jmp    c01028b9 <__alltraps>

c0102100 <vector79>:
.globl vector79
vector79:
  pushl $0
c0102100:	6a 00                	push   $0x0
  pushl $79
c0102102:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102104:	e9 b0 07 00 00       	jmp    c01028b9 <__alltraps>

c0102109 <vector80>:
.globl vector80
vector80:
  pushl $0
c0102109:	6a 00                	push   $0x0
  pushl $80
c010210b:	6a 50                	push   $0x50
  jmp __alltraps
c010210d:	e9 a7 07 00 00       	jmp    c01028b9 <__alltraps>

c0102112 <vector81>:
.globl vector81
vector81:
  pushl $0
c0102112:	6a 00                	push   $0x0
  pushl $81
c0102114:	6a 51                	push   $0x51
  jmp __alltraps
c0102116:	e9 9e 07 00 00       	jmp    c01028b9 <__alltraps>

c010211b <vector82>:
.globl vector82
vector82:
  pushl $0
c010211b:	6a 00                	push   $0x0
  pushl $82
c010211d:	6a 52                	push   $0x52
  jmp __alltraps
c010211f:	e9 95 07 00 00       	jmp    c01028b9 <__alltraps>

c0102124 <vector83>:
.globl vector83
vector83:
  pushl $0
c0102124:	6a 00                	push   $0x0
  pushl $83
c0102126:	6a 53                	push   $0x53
  jmp __alltraps
c0102128:	e9 8c 07 00 00       	jmp    c01028b9 <__alltraps>

c010212d <vector84>:
.globl vector84
vector84:
  pushl $0
c010212d:	6a 00                	push   $0x0
  pushl $84
c010212f:	6a 54                	push   $0x54
  jmp __alltraps
c0102131:	e9 83 07 00 00       	jmp    c01028b9 <__alltraps>

c0102136 <vector85>:
.globl vector85
vector85:
  pushl $0
c0102136:	6a 00                	push   $0x0
  pushl $85
c0102138:	6a 55                	push   $0x55
  jmp __alltraps
c010213a:	e9 7a 07 00 00       	jmp    c01028b9 <__alltraps>

c010213f <vector86>:
.globl vector86
vector86:
  pushl $0
c010213f:	6a 00                	push   $0x0
  pushl $86
c0102141:	6a 56                	push   $0x56
  jmp __alltraps
c0102143:	e9 71 07 00 00       	jmp    c01028b9 <__alltraps>

c0102148 <vector87>:
.globl vector87
vector87:
  pushl $0
c0102148:	6a 00                	push   $0x0
  pushl $87
c010214a:	6a 57                	push   $0x57
  jmp __alltraps
c010214c:	e9 68 07 00 00       	jmp    c01028b9 <__alltraps>

c0102151 <vector88>:
.globl vector88
vector88:
  pushl $0
c0102151:	6a 00                	push   $0x0
  pushl $88
c0102153:	6a 58                	push   $0x58
  jmp __alltraps
c0102155:	e9 5f 07 00 00       	jmp    c01028b9 <__alltraps>

c010215a <vector89>:
.globl vector89
vector89:
  pushl $0
c010215a:	6a 00                	push   $0x0
  pushl $89
c010215c:	6a 59                	push   $0x59
  jmp __alltraps
c010215e:	e9 56 07 00 00       	jmp    c01028b9 <__alltraps>

c0102163 <vector90>:
.globl vector90
vector90:
  pushl $0
c0102163:	6a 00                	push   $0x0
  pushl $90
c0102165:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102167:	e9 4d 07 00 00       	jmp    c01028b9 <__alltraps>

c010216c <vector91>:
.globl vector91
vector91:
  pushl $0
c010216c:	6a 00                	push   $0x0
  pushl $91
c010216e:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102170:	e9 44 07 00 00       	jmp    c01028b9 <__alltraps>

c0102175 <vector92>:
.globl vector92
vector92:
  pushl $0
c0102175:	6a 00                	push   $0x0
  pushl $92
c0102177:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102179:	e9 3b 07 00 00       	jmp    c01028b9 <__alltraps>

c010217e <vector93>:
.globl vector93
vector93:
  pushl $0
c010217e:	6a 00                	push   $0x0
  pushl $93
c0102180:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102182:	e9 32 07 00 00       	jmp    c01028b9 <__alltraps>

c0102187 <vector94>:
.globl vector94
vector94:
  pushl $0
c0102187:	6a 00                	push   $0x0
  pushl $94
c0102189:	6a 5e                	push   $0x5e
  jmp __alltraps
c010218b:	e9 29 07 00 00       	jmp    c01028b9 <__alltraps>

c0102190 <vector95>:
.globl vector95
vector95:
  pushl $0
c0102190:	6a 00                	push   $0x0
  pushl $95
c0102192:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102194:	e9 20 07 00 00       	jmp    c01028b9 <__alltraps>

c0102199 <vector96>:
.globl vector96
vector96:
  pushl $0
c0102199:	6a 00                	push   $0x0
  pushl $96
c010219b:	6a 60                	push   $0x60
  jmp __alltraps
c010219d:	e9 17 07 00 00       	jmp    c01028b9 <__alltraps>

c01021a2 <vector97>:
.globl vector97
vector97:
  pushl $0
c01021a2:	6a 00                	push   $0x0
  pushl $97
c01021a4:	6a 61                	push   $0x61
  jmp __alltraps
c01021a6:	e9 0e 07 00 00       	jmp    c01028b9 <__alltraps>

c01021ab <vector98>:
.globl vector98
vector98:
  pushl $0
c01021ab:	6a 00                	push   $0x0
  pushl $98
c01021ad:	6a 62                	push   $0x62
  jmp __alltraps
c01021af:	e9 05 07 00 00       	jmp    c01028b9 <__alltraps>

c01021b4 <vector99>:
.globl vector99
vector99:
  pushl $0
c01021b4:	6a 00                	push   $0x0
  pushl $99
c01021b6:	6a 63                	push   $0x63
  jmp __alltraps
c01021b8:	e9 fc 06 00 00       	jmp    c01028b9 <__alltraps>

c01021bd <vector100>:
.globl vector100
vector100:
  pushl $0
c01021bd:	6a 00                	push   $0x0
  pushl $100
c01021bf:	6a 64                	push   $0x64
  jmp __alltraps
c01021c1:	e9 f3 06 00 00       	jmp    c01028b9 <__alltraps>

c01021c6 <vector101>:
.globl vector101
vector101:
  pushl $0
c01021c6:	6a 00                	push   $0x0
  pushl $101
c01021c8:	6a 65                	push   $0x65
  jmp __alltraps
c01021ca:	e9 ea 06 00 00       	jmp    c01028b9 <__alltraps>

c01021cf <vector102>:
.globl vector102
vector102:
  pushl $0
c01021cf:	6a 00                	push   $0x0
  pushl $102
c01021d1:	6a 66                	push   $0x66
  jmp __alltraps
c01021d3:	e9 e1 06 00 00       	jmp    c01028b9 <__alltraps>

c01021d8 <vector103>:
.globl vector103
vector103:
  pushl $0
c01021d8:	6a 00                	push   $0x0
  pushl $103
c01021da:	6a 67                	push   $0x67
  jmp __alltraps
c01021dc:	e9 d8 06 00 00       	jmp    c01028b9 <__alltraps>

c01021e1 <vector104>:
.globl vector104
vector104:
  pushl $0
c01021e1:	6a 00                	push   $0x0
  pushl $104
c01021e3:	6a 68                	push   $0x68
  jmp __alltraps
c01021e5:	e9 cf 06 00 00       	jmp    c01028b9 <__alltraps>

c01021ea <vector105>:
.globl vector105
vector105:
  pushl $0
c01021ea:	6a 00                	push   $0x0
  pushl $105
c01021ec:	6a 69                	push   $0x69
  jmp __alltraps
c01021ee:	e9 c6 06 00 00       	jmp    c01028b9 <__alltraps>

c01021f3 <vector106>:
.globl vector106
vector106:
  pushl $0
c01021f3:	6a 00                	push   $0x0
  pushl $106
c01021f5:	6a 6a                	push   $0x6a
  jmp __alltraps
c01021f7:	e9 bd 06 00 00       	jmp    c01028b9 <__alltraps>

c01021fc <vector107>:
.globl vector107
vector107:
  pushl $0
c01021fc:	6a 00                	push   $0x0
  pushl $107
c01021fe:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102200:	e9 b4 06 00 00       	jmp    c01028b9 <__alltraps>

c0102205 <vector108>:
.globl vector108
vector108:
  pushl $0
c0102205:	6a 00                	push   $0x0
  pushl $108
c0102207:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102209:	e9 ab 06 00 00       	jmp    c01028b9 <__alltraps>

c010220e <vector109>:
.globl vector109
vector109:
  pushl $0
c010220e:	6a 00                	push   $0x0
  pushl $109
c0102210:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102212:	e9 a2 06 00 00       	jmp    c01028b9 <__alltraps>

c0102217 <vector110>:
.globl vector110
vector110:
  pushl $0
c0102217:	6a 00                	push   $0x0
  pushl $110
c0102219:	6a 6e                	push   $0x6e
  jmp __alltraps
c010221b:	e9 99 06 00 00       	jmp    c01028b9 <__alltraps>

c0102220 <vector111>:
.globl vector111
vector111:
  pushl $0
c0102220:	6a 00                	push   $0x0
  pushl $111
c0102222:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102224:	e9 90 06 00 00       	jmp    c01028b9 <__alltraps>

c0102229 <vector112>:
.globl vector112
vector112:
  pushl $0
c0102229:	6a 00                	push   $0x0
  pushl $112
c010222b:	6a 70                	push   $0x70
  jmp __alltraps
c010222d:	e9 87 06 00 00       	jmp    c01028b9 <__alltraps>

c0102232 <vector113>:
.globl vector113
vector113:
  pushl $0
c0102232:	6a 00                	push   $0x0
  pushl $113
c0102234:	6a 71                	push   $0x71
  jmp __alltraps
c0102236:	e9 7e 06 00 00       	jmp    c01028b9 <__alltraps>

c010223b <vector114>:
.globl vector114
vector114:
  pushl $0
c010223b:	6a 00                	push   $0x0
  pushl $114
c010223d:	6a 72                	push   $0x72
  jmp __alltraps
c010223f:	e9 75 06 00 00       	jmp    c01028b9 <__alltraps>

c0102244 <vector115>:
.globl vector115
vector115:
  pushl $0
c0102244:	6a 00                	push   $0x0
  pushl $115
c0102246:	6a 73                	push   $0x73
  jmp __alltraps
c0102248:	e9 6c 06 00 00       	jmp    c01028b9 <__alltraps>

c010224d <vector116>:
.globl vector116
vector116:
  pushl $0
c010224d:	6a 00                	push   $0x0
  pushl $116
c010224f:	6a 74                	push   $0x74
  jmp __alltraps
c0102251:	e9 63 06 00 00       	jmp    c01028b9 <__alltraps>

c0102256 <vector117>:
.globl vector117
vector117:
  pushl $0
c0102256:	6a 00                	push   $0x0
  pushl $117
c0102258:	6a 75                	push   $0x75
  jmp __alltraps
c010225a:	e9 5a 06 00 00       	jmp    c01028b9 <__alltraps>

c010225f <vector118>:
.globl vector118
vector118:
  pushl $0
c010225f:	6a 00                	push   $0x0
  pushl $118
c0102261:	6a 76                	push   $0x76
  jmp __alltraps
c0102263:	e9 51 06 00 00       	jmp    c01028b9 <__alltraps>

c0102268 <vector119>:
.globl vector119
vector119:
  pushl $0
c0102268:	6a 00                	push   $0x0
  pushl $119
c010226a:	6a 77                	push   $0x77
  jmp __alltraps
c010226c:	e9 48 06 00 00       	jmp    c01028b9 <__alltraps>

c0102271 <vector120>:
.globl vector120
vector120:
  pushl $0
c0102271:	6a 00                	push   $0x0
  pushl $120
c0102273:	6a 78                	push   $0x78
  jmp __alltraps
c0102275:	e9 3f 06 00 00       	jmp    c01028b9 <__alltraps>

c010227a <vector121>:
.globl vector121
vector121:
  pushl $0
c010227a:	6a 00                	push   $0x0
  pushl $121
c010227c:	6a 79                	push   $0x79
  jmp __alltraps
c010227e:	e9 36 06 00 00       	jmp    c01028b9 <__alltraps>

c0102283 <vector122>:
.globl vector122
vector122:
  pushl $0
c0102283:	6a 00                	push   $0x0
  pushl $122
c0102285:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102287:	e9 2d 06 00 00       	jmp    c01028b9 <__alltraps>

c010228c <vector123>:
.globl vector123
vector123:
  pushl $0
c010228c:	6a 00                	push   $0x0
  pushl $123
c010228e:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102290:	e9 24 06 00 00       	jmp    c01028b9 <__alltraps>

c0102295 <vector124>:
.globl vector124
vector124:
  pushl $0
c0102295:	6a 00                	push   $0x0
  pushl $124
c0102297:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102299:	e9 1b 06 00 00       	jmp    c01028b9 <__alltraps>

c010229e <vector125>:
.globl vector125
vector125:
  pushl $0
c010229e:	6a 00                	push   $0x0
  pushl $125
c01022a0:	6a 7d                	push   $0x7d
  jmp __alltraps
c01022a2:	e9 12 06 00 00       	jmp    c01028b9 <__alltraps>

c01022a7 <vector126>:
.globl vector126
vector126:
  pushl $0
c01022a7:	6a 00                	push   $0x0
  pushl $126
c01022a9:	6a 7e                	push   $0x7e
  jmp __alltraps
c01022ab:	e9 09 06 00 00       	jmp    c01028b9 <__alltraps>

c01022b0 <vector127>:
.globl vector127
vector127:
  pushl $0
c01022b0:	6a 00                	push   $0x0
  pushl $127
c01022b2:	6a 7f                	push   $0x7f
  jmp __alltraps
c01022b4:	e9 00 06 00 00       	jmp    c01028b9 <__alltraps>

c01022b9 <vector128>:
.globl vector128
vector128:
  pushl $0
c01022b9:	6a 00                	push   $0x0
  pushl $128
c01022bb:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c01022c0:	e9 f4 05 00 00       	jmp    c01028b9 <__alltraps>

c01022c5 <vector129>:
.globl vector129
vector129:
  pushl $0
c01022c5:	6a 00                	push   $0x0
  pushl $129
c01022c7:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c01022cc:	e9 e8 05 00 00       	jmp    c01028b9 <__alltraps>

c01022d1 <vector130>:
.globl vector130
vector130:
  pushl $0
c01022d1:	6a 00                	push   $0x0
  pushl $130
c01022d3:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c01022d8:	e9 dc 05 00 00       	jmp    c01028b9 <__alltraps>

c01022dd <vector131>:
.globl vector131
vector131:
  pushl $0
c01022dd:	6a 00                	push   $0x0
  pushl $131
c01022df:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c01022e4:	e9 d0 05 00 00       	jmp    c01028b9 <__alltraps>

c01022e9 <vector132>:
.globl vector132
vector132:
  pushl $0
c01022e9:	6a 00                	push   $0x0
  pushl $132
c01022eb:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c01022f0:	e9 c4 05 00 00       	jmp    c01028b9 <__alltraps>

c01022f5 <vector133>:
.globl vector133
vector133:
  pushl $0
c01022f5:	6a 00                	push   $0x0
  pushl $133
c01022f7:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c01022fc:	e9 b8 05 00 00       	jmp    c01028b9 <__alltraps>

c0102301 <vector134>:
.globl vector134
vector134:
  pushl $0
c0102301:	6a 00                	push   $0x0
  pushl $134
c0102303:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102308:	e9 ac 05 00 00       	jmp    c01028b9 <__alltraps>

c010230d <vector135>:
.globl vector135
vector135:
  pushl $0
c010230d:	6a 00                	push   $0x0
  pushl $135
c010230f:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102314:	e9 a0 05 00 00       	jmp    c01028b9 <__alltraps>

c0102319 <vector136>:
.globl vector136
vector136:
  pushl $0
c0102319:	6a 00                	push   $0x0
  pushl $136
c010231b:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0102320:	e9 94 05 00 00       	jmp    c01028b9 <__alltraps>

c0102325 <vector137>:
.globl vector137
vector137:
  pushl $0
c0102325:	6a 00                	push   $0x0
  pushl $137
c0102327:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c010232c:	e9 88 05 00 00       	jmp    c01028b9 <__alltraps>

c0102331 <vector138>:
.globl vector138
vector138:
  pushl $0
c0102331:	6a 00                	push   $0x0
  pushl $138
c0102333:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102338:	e9 7c 05 00 00       	jmp    c01028b9 <__alltraps>

c010233d <vector139>:
.globl vector139
vector139:
  pushl $0
c010233d:	6a 00                	push   $0x0
  pushl $139
c010233f:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102344:	e9 70 05 00 00       	jmp    c01028b9 <__alltraps>

c0102349 <vector140>:
.globl vector140
vector140:
  pushl $0
c0102349:	6a 00                	push   $0x0
  pushl $140
c010234b:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0102350:	e9 64 05 00 00       	jmp    c01028b9 <__alltraps>

c0102355 <vector141>:
.globl vector141
vector141:
  pushl $0
c0102355:	6a 00                	push   $0x0
  pushl $141
c0102357:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c010235c:	e9 58 05 00 00       	jmp    c01028b9 <__alltraps>

c0102361 <vector142>:
.globl vector142
vector142:
  pushl $0
c0102361:	6a 00                	push   $0x0
  pushl $142
c0102363:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102368:	e9 4c 05 00 00       	jmp    c01028b9 <__alltraps>

c010236d <vector143>:
.globl vector143
vector143:
  pushl $0
c010236d:	6a 00                	push   $0x0
  pushl $143
c010236f:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0102374:	e9 40 05 00 00       	jmp    c01028b9 <__alltraps>

c0102379 <vector144>:
.globl vector144
vector144:
  pushl $0
c0102379:	6a 00                	push   $0x0
  pushl $144
c010237b:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102380:	e9 34 05 00 00       	jmp    c01028b9 <__alltraps>

c0102385 <vector145>:
.globl vector145
vector145:
  pushl $0
c0102385:	6a 00                	push   $0x0
  pushl $145
c0102387:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c010238c:	e9 28 05 00 00       	jmp    c01028b9 <__alltraps>

c0102391 <vector146>:
.globl vector146
vector146:
  pushl $0
c0102391:	6a 00                	push   $0x0
  pushl $146
c0102393:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102398:	e9 1c 05 00 00       	jmp    c01028b9 <__alltraps>

c010239d <vector147>:
.globl vector147
vector147:
  pushl $0
c010239d:	6a 00                	push   $0x0
  pushl $147
c010239f:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c01023a4:	e9 10 05 00 00       	jmp    c01028b9 <__alltraps>

c01023a9 <vector148>:
.globl vector148
vector148:
  pushl $0
c01023a9:	6a 00                	push   $0x0
  pushl $148
c01023ab:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c01023b0:	e9 04 05 00 00       	jmp    c01028b9 <__alltraps>

c01023b5 <vector149>:
.globl vector149
vector149:
  pushl $0
c01023b5:	6a 00                	push   $0x0
  pushl $149
c01023b7:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c01023bc:	e9 f8 04 00 00       	jmp    c01028b9 <__alltraps>

c01023c1 <vector150>:
.globl vector150
vector150:
  pushl $0
c01023c1:	6a 00                	push   $0x0
  pushl $150
c01023c3:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c01023c8:	e9 ec 04 00 00       	jmp    c01028b9 <__alltraps>

c01023cd <vector151>:
.globl vector151
vector151:
  pushl $0
c01023cd:	6a 00                	push   $0x0
  pushl $151
c01023cf:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c01023d4:	e9 e0 04 00 00       	jmp    c01028b9 <__alltraps>

c01023d9 <vector152>:
.globl vector152
vector152:
  pushl $0
c01023d9:	6a 00                	push   $0x0
  pushl $152
c01023db:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c01023e0:	e9 d4 04 00 00       	jmp    c01028b9 <__alltraps>

c01023e5 <vector153>:
.globl vector153
vector153:
  pushl $0
c01023e5:	6a 00                	push   $0x0
  pushl $153
c01023e7:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c01023ec:	e9 c8 04 00 00       	jmp    c01028b9 <__alltraps>

c01023f1 <vector154>:
.globl vector154
vector154:
  pushl $0
c01023f1:	6a 00                	push   $0x0
  pushl $154
c01023f3:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c01023f8:	e9 bc 04 00 00       	jmp    c01028b9 <__alltraps>

c01023fd <vector155>:
.globl vector155
vector155:
  pushl $0
c01023fd:	6a 00                	push   $0x0
  pushl $155
c01023ff:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0102404:	e9 b0 04 00 00       	jmp    c01028b9 <__alltraps>

c0102409 <vector156>:
.globl vector156
vector156:
  pushl $0
c0102409:	6a 00                	push   $0x0
  pushl $156
c010240b:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0102410:	e9 a4 04 00 00       	jmp    c01028b9 <__alltraps>

c0102415 <vector157>:
.globl vector157
vector157:
  pushl $0
c0102415:	6a 00                	push   $0x0
  pushl $157
c0102417:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c010241c:	e9 98 04 00 00       	jmp    c01028b9 <__alltraps>

c0102421 <vector158>:
.globl vector158
vector158:
  pushl $0
c0102421:	6a 00                	push   $0x0
  pushl $158
c0102423:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0102428:	e9 8c 04 00 00       	jmp    c01028b9 <__alltraps>

c010242d <vector159>:
.globl vector159
vector159:
  pushl $0
c010242d:	6a 00                	push   $0x0
  pushl $159
c010242f:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0102434:	e9 80 04 00 00       	jmp    c01028b9 <__alltraps>

c0102439 <vector160>:
.globl vector160
vector160:
  pushl $0
c0102439:	6a 00                	push   $0x0
  pushl $160
c010243b:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0102440:	e9 74 04 00 00       	jmp    c01028b9 <__alltraps>

c0102445 <vector161>:
.globl vector161
vector161:
  pushl $0
c0102445:	6a 00                	push   $0x0
  pushl $161
c0102447:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c010244c:	e9 68 04 00 00       	jmp    c01028b9 <__alltraps>

c0102451 <vector162>:
.globl vector162
vector162:
  pushl $0
c0102451:	6a 00                	push   $0x0
  pushl $162
c0102453:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0102458:	e9 5c 04 00 00       	jmp    c01028b9 <__alltraps>

c010245d <vector163>:
.globl vector163
vector163:
  pushl $0
c010245d:	6a 00                	push   $0x0
  pushl $163
c010245f:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0102464:	e9 50 04 00 00       	jmp    c01028b9 <__alltraps>

c0102469 <vector164>:
.globl vector164
vector164:
  pushl $0
c0102469:	6a 00                	push   $0x0
  pushl $164
c010246b:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c0102470:	e9 44 04 00 00       	jmp    c01028b9 <__alltraps>

c0102475 <vector165>:
.globl vector165
vector165:
  pushl $0
c0102475:	6a 00                	push   $0x0
  pushl $165
c0102477:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c010247c:	e9 38 04 00 00       	jmp    c01028b9 <__alltraps>

c0102481 <vector166>:
.globl vector166
vector166:
  pushl $0
c0102481:	6a 00                	push   $0x0
  pushl $166
c0102483:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c0102488:	e9 2c 04 00 00       	jmp    c01028b9 <__alltraps>

c010248d <vector167>:
.globl vector167
vector167:
  pushl $0
c010248d:	6a 00                	push   $0x0
  pushl $167
c010248f:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c0102494:	e9 20 04 00 00       	jmp    c01028b9 <__alltraps>

c0102499 <vector168>:
.globl vector168
vector168:
  pushl $0
c0102499:	6a 00                	push   $0x0
  pushl $168
c010249b:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c01024a0:	e9 14 04 00 00       	jmp    c01028b9 <__alltraps>

c01024a5 <vector169>:
.globl vector169
vector169:
  pushl $0
c01024a5:	6a 00                	push   $0x0
  pushl $169
c01024a7:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c01024ac:	e9 08 04 00 00       	jmp    c01028b9 <__alltraps>

c01024b1 <vector170>:
.globl vector170
vector170:
  pushl $0
c01024b1:	6a 00                	push   $0x0
  pushl $170
c01024b3:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c01024b8:	e9 fc 03 00 00       	jmp    c01028b9 <__alltraps>

c01024bd <vector171>:
.globl vector171
vector171:
  pushl $0
c01024bd:	6a 00                	push   $0x0
  pushl $171
c01024bf:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c01024c4:	e9 f0 03 00 00       	jmp    c01028b9 <__alltraps>

c01024c9 <vector172>:
.globl vector172
vector172:
  pushl $0
c01024c9:	6a 00                	push   $0x0
  pushl $172
c01024cb:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c01024d0:	e9 e4 03 00 00       	jmp    c01028b9 <__alltraps>

c01024d5 <vector173>:
.globl vector173
vector173:
  pushl $0
c01024d5:	6a 00                	push   $0x0
  pushl $173
c01024d7:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c01024dc:	e9 d8 03 00 00       	jmp    c01028b9 <__alltraps>

c01024e1 <vector174>:
.globl vector174
vector174:
  pushl $0
c01024e1:	6a 00                	push   $0x0
  pushl $174
c01024e3:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c01024e8:	e9 cc 03 00 00       	jmp    c01028b9 <__alltraps>

c01024ed <vector175>:
.globl vector175
vector175:
  pushl $0
c01024ed:	6a 00                	push   $0x0
  pushl $175
c01024ef:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c01024f4:	e9 c0 03 00 00       	jmp    c01028b9 <__alltraps>

c01024f9 <vector176>:
.globl vector176
vector176:
  pushl $0
c01024f9:	6a 00                	push   $0x0
  pushl $176
c01024fb:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0102500:	e9 b4 03 00 00       	jmp    c01028b9 <__alltraps>

c0102505 <vector177>:
.globl vector177
vector177:
  pushl $0
c0102505:	6a 00                	push   $0x0
  pushl $177
c0102507:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c010250c:	e9 a8 03 00 00       	jmp    c01028b9 <__alltraps>

c0102511 <vector178>:
.globl vector178
vector178:
  pushl $0
c0102511:	6a 00                	push   $0x0
  pushl $178
c0102513:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0102518:	e9 9c 03 00 00       	jmp    c01028b9 <__alltraps>

c010251d <vector179>:
.globl vector179
vector179:
  pushl $0
c010251d:	6a 00                	push   $0x0
  pushl $179
c010251f:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0102524:	e9 90 03 00 00       	jmp    c01028b9 <__alltraps>

c0102529 <vector180>:
.globl vector180
vector180:
  pushl $0
c0102529:	6a 00                	push   $0x0
  pushl $180
c010252b:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0102530:	e9 84 03 00 00       	jmp    c01028b9 <__alltraps>

c0102535 <vector181>:
.globl vector181
vector181:
  pushl $0
c0102535:	6a 00                	push   $0x0
  pushl $181
c0102537:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c010253c:	e9 78 03 00 00       	jmp    c01028b9 <__alltraps>

c0102541 <vector182>:
.globl vector182
vector182:
  pushl $0
c0102541:	6a 00                	push   $0x0
  pushl $182
c0102543:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0102548:	e9 6c 03 00 00       	jmp    c01028b9 <__alltraps>

c010254d <vector183>:
.globl vector183
vector183:
  pushl $0
c010254d:	6a 00                	push   $0x0
  pushl $183
c010254f:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0102554:	e9 60 03 00 00       	jmp    c01028b9 <__alltraps>

c0102559 <vector184>:
.globl vector184
vector184:
  pushl $0
c0102559:	6a 00                	push   $0x0
  pushl $184
c010255b:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c0102560:	e9 54 03 00 00       	jmp    c01028b9 <__alltraps>

c0102565 <vector185>:
.globl vector185
vector185:
  pushl $0
c0102565:	6a 00                	push   $0x0
  pushl $185
c0102567:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c010256c:	e9 48 03 00 00       	jmp    c01028b9 <__alltraps>

c0102571 <vector186>:
.globl vector186
vector186:
  pushl $0
c0102571:	6a 00                	push   $0x0
  pushl $186
c0102573:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c0102578:	e9 3c 03 00 00       	jmp    c01028b9 <__alltraps>

c010257d <vector187>:
.globl vector187
vector187:
  pushl $0
c010257d:	6a 00                	push   $0x0
  pushl $187
c010257f:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c0102584:	e9 30 03 00 00       	jmp    c01028b9 <__alltraps>

c0102589 <vector188>:
.globl vector188
vector188:
  pushl $0
c0102589:	6a 00                	push   $0x0
  pushl $188
c010258b:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c0102590:	e9 24 03 00 00       	jmp    c01028b9 <__alltraps>

c0102595 <vector189>:
.globl vector189
vector189:
  pushl $0
c0102595:	6a 00                	push   $0x0
  pushl $189
c0102597:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c010259c:	e9 18 03 00 00       	jmp    c01028b9 <__alltraps>

c01025a1 <vector190>:
.globl vector190
vector190:
  pushl $0
c01025a1:	6a 00                	push   $0x0
  pushl $190
c01025a3:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c01025a8:	e9 0c 03 00 00       	jmp    c01028b9 <__alltraps>

c01025ad <vector191>:
.globl vector191
vector191:
  pushl $0
c01025ad:	6a 00                	push   $0x0
  pushl $191
c01025af:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c01025b4:	e9 00 03 00 00       	jmp    c01028b9 <__alltraps>

c01025b9 <vector192>:
.globl vector192
vector192:
  pushl $0
c01025b9:	6a 00                	push   $0x0
  pushl $192
c01025bb:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c01025c0:	e9 f4 02 00 00       	jmp    c01028b9 <__alltraps>

c01025c5 <vector193>:
.globl vector193
vector193:
  pushl $0
c01025c5:	6a 00                	push   $0x0
  pushl $193
c01025c7:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c01025cc:	e9 e8 02 00 00       	jmp    c01028b9 <__alltraps>

c01025d1 <vector194>:
.globl vector194
vector194:
  pushl $0
c01025d1:	6a 00                	push   $0x0
  pushl $194
c01025d3:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c01025d8:	e9 dc 02 00 00       	jmp    c01028b9 <__alltraps>

c01025dd <vector195>:
.globl vector195
vector195:
  pushl $0
c01025dd:	6a 00                	push   $0x0
  pushl $195
c01025df:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c01025e4:	e9 d0 02 00 00       	jmp    c01028b9 <__alltraps>

c01025e9 <vector196>:
.globl vector196
vector196:
  pushl $0
c01025e9:	6a 00                	push   $0x0
  pushl $196
c01025eb:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c01025f0:	e9 c4 02 00 00       	jmp    c01028b9 <__alltraps>

c01025f5 <vector197>:
.globl vector197
vector197:
  pushl $0
c01025f5:	6a 00                	push   $0x0
  pushl $197
c01025f7:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c01025fc:	e9 b8 02 00 00       	jmp    c01028b9 <__alltraps>

c0102601 <vector198>:
.globl vector198
vector198:
  pushl $0
c0102601:	6a 00                	push   $0x0
  pushl $198
c0102603:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0102608:	e9 ac 02 00 00       	jmp    c01028b9 <__alltraps>

c010260d <vector199>:
.globl vector199
vector199:
  pushl $0
c010260d:	6a 00                	push   $0x0
  pushl $199
c010260f:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0102614:	e9 a0 02 00 00       	jmp    c01028b9 <__alltraps>

c0102619 <vector200>:
.globl vector200
vector200:
  pushl $0
c0102619:	6a 00                	push   $0x0
  pushl $200
c010261b:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0102620:	e9 94 02 00 00       	jmp    c01028b9 <__alltraps>

c0102625 <vector201>:
.globl vector201
vector201:
  pushl $0
c0102625:	6a 00                	push   $0x0
  pushl $201
c0102627:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c010262c:	e9 88 02 00 00       	jmp    c01028b9 <__alltraps>

c0102631 <vector202>:
.globl vector202
vector202:
  pushl $0
c0102631:	6a 00                	push   $0x0
  pushl $202
c0102633:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0102638:	e9 7c 02 00 00       	jmp    c01028b9 <__alltraps>

c010263d <vector203>:
.globl vector203
vector203:
  pushl $0
c010263d:	6a 00                	push   $0x0
  pushl $203
c010263f:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0102644:	e9 70 02 00 00       	jmp    c01028b9 <__alltraps>

c0102649 <vector204>:
.globl vector204
vector204:
  pushl $0
c0102649:	6a 00                	push   $0x0
  pushl $204
c010264b:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c0102650:	e9 64 02 00 00       	jmp    c01028b9 <__alltraps>

c0102655 <vector205>:
.globl vector205
vector205:
  pushl $0
c0102655:	6a 00                	push   $0x0
  pushl $205
c0102657:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c010265c:	e9 58 02 00 00       	jmp    c01028b9 <__alltraps>

c0102661 <vector206>:
.globl vector206
vector206:
  pushl $0
c0102661:	6a 00                	push   $0x0
  pushl $206
c0102663:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c0102668:	e9 4c 02 00 00       	jmp    c01028b9 <__alltraps>

c010266d <vector207>:
.globl vector207
vector207:
  pushl $0
c010266d:	6a 00                	push   $0x0
  pushl $207
c010266f:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c0102674:	e9 40 02 00 00       	jmp    c01028b9 <__alltraps>

c0102679 <vector208>:
.globl vector208
vector208:
  pushl $0
c0102679:	6a 00                	push   $0x0
  pushl $208
c010267b:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c0102680:	e9 34 02 00 00       	jmp    c01028b9 <__alltraps>

c0102685 <vector209>:
.globl vector209
vector209:
  pushl $0
c0102685:	6a 00                	push   $0x0
  pushl $209
c0102687:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c010268c:	e9 28 02 00 00       	jmp    c01028b9 <__alltraps>

c0102691 <vector210>:
.globl vector210
vector210:
  pushl $0
c0102691:	6a 00                	push   $0x0
  pushl $210
c0102693:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c0102698:	e9 1c 02 00 00       	jmp    c01028b9 <__alltraps>

c010269d <vector211>:
.globl vector211
vector211:
  pushl $0
c010269d:	6a 00                	push   $0x0
  pushl $211
c010269f:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c01026a4:	e9 10 02 00 00       	jmp    c01028b9 <__alltraps>

c01026a9 <vector212>:
.globl vector212
vector212:
  pushl $0
c01026a9:	6a 00                	push   $0x0
  pushl $212
c01026ab:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c01026b0:	e9 04 02 00 00       	jmp    c01028b9 <__alltraps>

c01026b5 <vector213>:
.globl vector213
vector213:
  pushl $0
c01026b5:	6a 00                	push   $0x0
  pushl $213
c01026b7:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c01026bc:	e9 f8 01 00 00       	jmp    c01028b9 <__alltraps>

c01026c1 <vector214>:
.globl vector214
vector214:
  pushl $0
c01026c1:	6a 00                	push   $0x0
  pushl $214
c01026c3:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c01026c8:	e9 ec 01 00 00       	jmp    c01028b9 <__alltraps>

c01026cd <vector215>:
.globl vector215
vector215:
  pushl $0
c01026cd:	6a 00                	push   $0x0
  pushl $215
c01026cf:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c01026d4:	e9 e0 01 00 00       	jmp    c01028b9 <__alltraps>

c01026d9 <vector216>:
.globl vector216
vector216:
  pushl $0
c01026d9:	6a 00                	push   $0x0
  pushl $216
c01026db:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c01026e0:	e9 d4 01 00 00       	jmp    c01028b9 <__alltraps>

c01026e5 <vector217>:
.globl vector217
vector217:
  pushl $0
c01026e5:	6a 00                	push   $0x0
  pushl $217
c01026e7:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c01026ec:	e9 c8 01 00 00       	jmp    c01028b9 <__alltraps>

c01026f1 <vector218>:
.globl vector218
vector218:
  pushl $0
c01026f1:	6a 00                	push   $0x0
  pushl $218
c01026f3:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c01026f8:	e9 bc 01 00 00       	jmp    c01028b9 <__alltraps>

c01026fd <vector219>:
.globl vector219
vector219:
  pushl $0
c01026fd:	6a 00                	push   $0x0
  pushl $219
c01026ff:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0102704:	e9 b0 01 00 00       	jmp    c01028b9 <__alltraps>

c0102709 <vector220>:
.globl vector220
vector220:
  pushl $0
c0102709:	6a 00                	push   $0x0
  pushl $220
c010270b:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0102710:	e9 a4 01 00 00       	jmp    c01028b9 <__alltraps>

c0102715 <vector221>:
.globl vector221
vector221:
  pushl $0
c0102715:	6a 00                	push   $0x0
  pushl $221
c0102717:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c010271c:	e9 98 01 00 00       	jmp    c01028b9 <__alltraps>

c0102721 <vector222>:
.globl vector222
vector222:
  pushl $0
c0102721:	6a 00                	push   $0x0
  pushl $222
c0102723:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0102728:	e9 8c 01 00 00       	jmp    c01028b9 <__alltraps>

c010272d <vector223>:
.globl vector223
vector223:
  pushl $0
c010272d:	6a 00                	push   $0x0
  pushl $223
c010272f:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0102734:	e9 80 01 00 00       	jmp    c01028b9 <__alltraps>

c0102739 <vector224>:
.globl vector224
vector224:
  pushl $0
c0102739:	6a 00                	push   $0x0
  pushl $224
c010273b:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c0102740:	e9 74 01 00 00       	jmp    c01028b9 <__alltraps>

c0102745 <vector225>:
.globl vector225
vector225:
  pushl $0
c0102745:	6a 00                	push   $0x0
  pushl $225
c0102747:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c010274c:	e9 68 01 00 00       	jmp    c01028b9 <__alltraps>

c0102751 <vector226>:
.globl vector226
vector226:
  pushl $0
c0102751:	6a 00                	push   $0x0
  pushl $226
c0102753:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c0102758:	e9 5c 01 00 00       	jmp    c01028b9 <__alltraps>

c010275d <vector227>:
.globl vector227
vector227:
  pushl $0
c010275d:	6a 00                	push   $0x0
  pushl $227
c010275f:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c0102764:	e9 50 01 00 00       	jmp    c01028b9 <__alltraps>

c0102769 <vector228>:
.globl vector228
vector228:
  pushl $0
c0102769:	6a 00                	push   $0x0
  pushl $228
c010276b:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c0102770:	e9 44 01 00 00       	jmp    c01028b9 <__alltraps>

c0102775 <vector229>:
.globl vector229
vector229:
  pushl $0
c0102775:	6a 00                	push   $0x0
  pushl $229
c0102777:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c010277c:	e9 38 01 00 00       	jmp    c01028b9 <__alltraps>

c0102781 <vector230>:
.globl vector230
vector230:
  pushl $0
c0102781:	6a 00                	push   $0x0
  pushl $230
c0102783:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c0102788:	e9 2c 01 00 00       	jmp    c01028b9 <__alltraps>

c010278d <vector231>:
.globl vector231
vector231:
  pushl $0
c010278d:	6a 00                	push   $0x0
  pushl $231
c010278f:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c0102794:	e9 20 01 00 00       	jmp    c01028b9 <__alltraps>

c0102799 <vector232>:
.globl vector232
vector232:
  pushl $0
c0102799:	6a 00                	push   $0x0
  pushl $232
c010279b:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c01027a0:	e9 14 01 00 00       	jmp    c01028b9 <__alltraps>

c01027a5 <vector233>:
.globl vector233
vector233:
  pushl $0
c01027a5:	6a 00                	push   $0x0
  pushl $233
c01027a7:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c01027ac:	e9 08 01 00 00       	jmp    c01028b9 <__alltraps>

c01027b1 <vector234>:
.globl vector234
vector234:
  pushl $0
c01027b1:	6a 00                	push   $0x0
  pushl $234
c01027b3:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c01027b8:	e9 fc 00 00 00       	jmp    c01028b9 <__alltraps>

c01027bd <vector235>:
.globl vector235
vector235:
  pushl $0
c01027bd:	6a 00                	push   $0x0
  pushl $235
c01027bf:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c01027c4:	e9 f0 00 00 00       	jmp    c01028b9 <__alltraps>

c01027c9 <vector236>:
.globl vector236
vector236:
  pushl $0
c01027c9:	6a 00                	push   $0x0
  pushl $236
c01027cb:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c01027d0:	e9 e4 00 00 00       	jmp    c01028b9 <__alltraps>

c01027d5 <vector237>:
.globl vector237
vector237:
  pushl $0
c01027d5:	6a 00                	push   $0x0
  pushl $237
c01027d7:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c01027dc:	e9 d8 00 00 00       	jmp    c01028b9 <__alltraps>

c01027e1 <vector238>:
.globl vector238
vector238:
  pushl $0
c01027e1:	6a 00                	push   $0x0
  pushl $238
c01027e3:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c01027e8:	e9 cc 00 00 00       	jmp    c01028b9 <__alltraps>

c01027ed <vector239>:
.globl vector239
vector239:
  pushl $0
c01027ed:	6a 00                	push   $0x0
  pushl $239
c01027ef:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c01027f4:	e9 c0 00 00 00       	jmp    c01028b9 <__alltraps>

c01027f9 <vector240>:
.globl vector240
vector240:
  pushl $0
c01027f9:	6a 00                	push   $0x0
  pushl $240
c01027fb:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0102800:	e9 b4 00 00 00       	jmp    c01028b9 <__alltraps>

c0102805 <vector241>:
.globl vector241
vector241:
  pushl $0
c0102805:	6a 00                	push   $0x0
  pushl $241
c0102807:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c010280c:	e9 a8 00 00 00       	jmp    c01028b9 <__alltraps>

c0102811 <vector242>:
.globl vector242
vector242:
  pushl $0
c0102811:	6a 00                	push   $0x0
  pushl $242
c0102813:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c0102818:	e9 9c 00 00 00       	jmp    c01028b9 <__alltraps>

c010281d <vector243>:
.globl vector243
vector243:
  pushl $0
c010281d:	6a 00                	push   $0x0
  pushl $243
c010281f:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0102824:	e9 90 00 00 00       	jmp    c01028b9 <__alltraps>

c0102829 <vector244>:
.globl vector244
vector244:
  pushl $0
c0102829:	6a 00                	push   $0x0
  pushl $244
c010282b:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c0102830:	e9 84 00 00 00       	jmp    c01028b9 <__alltraps>

c0102835 <vector245>:
.globl vector245
vector245:
  pushl $0
c0102835:	6a 00                	push   $0x0
  pushl $245
c0102837:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c010283c:	e9 78 00 00 00       	jmp    c01028b9 <__alltraps>

c0102841 <vector246>:
.globl vector246
vector246:
  pushl $0
c0102841:	6a 00                	push   $0x0
  pushl $246
c0102843:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c0102848:	e9 6c 00 00 00       	jmp    c01028b9 <__alltraps>

c010284d <vector247>:
.globl vector247
vector247:
  pushl $0
c010284d:	6a 00                	push   $0x0
  pushl $247
c010284f:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c0102854:	e9 60 00 00 00       	jmp    c01028b9 <__alltraps>

c0102859 <vector248>:
.globl vector248
vector248:
  pushl $0
c0102859:	6a 00                	push   $0x0
  pushl $248
c010285b:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c0102860:	e9 54 00 00 00       	jmp    c01028b9 <__alltraps>

c0102865 <vector249>:
.globl vector249
vector249:
  pushl $0
c0102865:	6a 00                	push   $0x0
  pushl $249
c0102867:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c010286c:	e9 48 00 00 00       	jmp    c01028b9 <__alltraps>

c0102871 <vector250>:
.globl vector250
vector250:
  pushl $0
c0102871:	6a 00                	push   $0x0
  pushl $250
c0102873:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c0102878:	e9 3c 00 00 00       	jmp    c01028b9 <__alltraps>

c010287d <vector251>:
.globl vector251
vector251:
  pushl $0
c010287d:	6a 00                	push   $0x0
  pushl $251
c010287f:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c0102884:	e9 30 00 00 00       	jmp    c01028b9 <__alltraps>

c0102889 <vector252>:
.globl vector252
vector252:
  pushl $0
c0102889:	6a 00                	push   $0x0
  pushl $252
c010288b:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c0102890:	e9 24 00 00 00       	jmp    c01028b9 <__alltraps>

c0102895 <vector253>:
.globl vector253
vector253:
  pushl $0
c0102895:	6a 00                	push   $0x0
  pushl $253
c0102897:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c010289c:	e9 18 00 00 00       	jmp    c01028b9 <__alltraps>

c01028a1 <vector254>:
.globl vector254
vector254:
  pushl $0
c01028a1:	6a 00                	push   $0x0
  pushl $254
c01028a3:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c01028a8:	e9 0c 00 00 00       	jmp    c01028b9 <__alltraps>

c01028ad <vector255>:
.globl vector255
vector255:
  pushl $0
c01028ad:	6a 00                	push   $0x0
  pushl $255
c01028af:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c01028b4:	e9 00 00 00 00       	jmp    c01028b9 <__alltraps>

c01028b9 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c01028b9:	1e                   	push   %ds
    pushl %es
c01028ba:	06                   	push   %es
    pushl %fs
c01028bb:	0f a0                	push   %fs
    pushl %gs
c01028bd:	0f a8                	push   %gs
    pushal
c01028bf:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c01028c0:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c01028c5:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c01028c7:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c01028c9:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c01028ca:	e8 65 f5 ff ff       	call   c0101e34 <trap>

    # pop the pushed stack pointer
    popl %esp
c01028cf:	5c                   	pop    %esp

c01028d0 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c01028d0:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c01028d1:	0f a9                	pop    %gs
    popl %fs
c01028d3:	0f a1                	pop    %fs
    popl %es
c01028d5:	07                   	pop    %es
    popl %ds
c01028d6:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c01028d7:	83 c4 08             	add    $0x8,%esp
    iret
c01028da:	cf                   	iret   

c01028db <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01028db:	55                   	push   %ebp
c01028dc:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01028de:	8b 55 08             	mov    0x8(%ebp),%edx
c01028e1:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c01028e6:	29 c2                	sub    %eax,%edx
c01028e8:	89 d0                	mov    %edx,%eax
c01028ea:	c1 f8 02             	sar    $0x2,%eax
c01028ed:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c01028f3:	5d                   	pop    %ebp
c01028f4:	c3                   	ret    

c01028f5 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01028f5:	55                   	push   %ebp
c01028f6:	89 e5                	mov    %esp,%ebp
c01028f8:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01028fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01028fe:	89 04 24             	mov    %eax,(%esp)
c0102901:	e8 d5 ff ff ff       	call   c01028db <page2ppn>
c0102906:	c1 e0 0c             	shl    $0xc,%eax
}
c0102909:	c9                   	leave  
c010290a:	c3                   	ret    

c010290b <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c010290b:	55                   	push   %ebp
c010290c:	89 e5                	mov    %esp,%ebp
c010290e:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0102911:	8b 45 08             	mov    0x8(%ebp),%eax
c0102914:	c1 e8 0c             	shr    $0xc,%eax
c0102917:	89 c2                	mov    %eax,%edx
c0102919:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c010291e:	39 c2                	cmp    %eax,%edx
c0102920:	72 1c                	jb     c010293e <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0102922:	c7 44 24 08 90 66 10 	movl   $0xc0106690,0x8(%esp)
c0102929:	c0 
c010292a:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c0102931:	00 
c0102932:	c7 04 24 af 66 10 c0 	movl   $0xc01066af,(%esp)
c0102939:	e8 ab da ff ff       	call   c01003e9 <__panic>
    }
    return &pages[PPN(pa)];
c010293e:	8b 0d 18 af 11 c0    	mov    0xc011af18,%ecx
c0102944:	8b 45 08             	mov    0x8(%ebp),%eax
c0102947:	c1 e8 0c             	shr    $0xc,%eax
c010294a:	89 c2                	mov    %eax,%edx
c010294c:	89 d0                	mov    %edx,%eax
c010294e:	c1 e0 02             	shl    $0x2,%eax
c0102951:	01 d0                	add    %edx,%eax
c0102953:	c1 e0 02             	shl    $0x2,%eax
c0102956:	01 c8                	add    %ecx,%eax
}
c0102958:	c9                   	leave  
c0102959:	c3                   	ret    

c010295a <page2kva>:

static inline void *
page2kva(struct Page *page) {
c010295a:	55                   	push   %ebp
c010295b:	89 e5                	mov    %esp,%ebp
c010295d:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0102960:	8b 45 08             	mov    0x8(%ebp),%eax
c0102963:	89 04 24             	mov    %eax,(%esp)
c0102966:	e8 8a ff ff ff       	call   c01028f5 <page2pa>
c010296b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010296e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102971:	c1 e8 0c             	shr    $0xc,%eax
c0102974:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102977:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c010297c:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010297f:	72 23                	jb     c01029a4 <page2kva+0x4a>
c0102981:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102984:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102988:	c7 44 24 08 c0 66 10 	movl   $0xc01066c0,0x8(%esp)
c010298f:	c0 
c0102990:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c0102997:	00 
c0102998:	c7 04 24 af 66 10 c0 	movl   $0xc01066af,(%esp)
c010299f:	e8 45 da ff ff       	call   c01003e9 <__panic>
c01029a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01029a7:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01029ac:	c9                   	leave  
c01029ad:	c3                   	ret    

c01029ae <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c01029ae:	55                   	push   %ebp
c01029af:	89 e5                	mov    %esp,%ebp
c01029b1:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c01029b4:	8b 45 08             	mov    0x8(%ebp),%eax
c01029b7:	83 e0 01             	and    $0x1,%eax
c01029ba:	85 c0                	test   %eax,%eax
c01029bc:	75 1c                	jne    c01029da <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c01029be:	c7 44 24 08 e4 66 10 	movl   $0xc01066e4,0x8(%esp)
c01029c5:	c0 
c01029c6:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c01029cd:	00 
c01029ce:	c7 04 24 af 66 10 c0 	movl   $0xc01066af,(%esp)
c01029d5:	e8 0f da ff ff       	call   c01003e9 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c01029da:	8b 45 08             	mov    0x8(%ebp),%eax
c01029dd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01029e2:	89 04 24             	mov    %eax,(%esp)
c01029e5:	e8 21 ff ff ff       	call   c010290b <pa2page>
}
c01029ea:	c9                   	leave  
c01029eb:	c3                   	ret    

c01029ec <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c01029ec:	55                   	push   %ebp
c01029ed:	89 e5                	mov    %esp,%ebp
c01029ef:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c01029f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01029f5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01029fa:	89 04 24             	mov    %eax,(%esp)
c01029fd:	e8 09 ff ff ff       	call   c010290b <pa2page>
}
c0102a02:	c9                   	leave  
c0102a03:	c3                   	ret    

c0102a04 <page_ref>:

static inline int
page_ref(struct Page *page) {
c0102a04:	55                   	push   %ebp
c0102a05:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0102a07:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a0a:	8b 00                	mov    (%eax),%eax
}
c0102a0c:	5d                   	pop    %ebp
c0102a0d:	c3                   	ret    

c0102a0e <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0102a0e:	55                   	push   %ebp
c0102a0f:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0102a11:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a14:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102a17:	89 10                	mov    %edx,(%eax)
}
c0102a19:	5d                   	pop    %ebp
c0102a1a:	c3                   	ret    

c0102a1b <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0102a1b:	55                   	push   %ebp
c0102a1c:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0102a1e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a21:	8b 00                	mov    (%eax),%eax
c0102a23:	8d 50 01             	lea    0x1(%eax),%edx
c0102a26:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a29:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0102a2b:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a2e:	8b 00                	mov    (%eax),%eax
}
c0102a30:	5d                   	pop    %ebp
c0102a31:	c3                   	ret    

c0102a32 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0102a32:	55                   	push   %ebp
c0102a33:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0102a35:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a38:	8b 00                	mov    (%eax),%eax
c0102a3a:	8d 50 ff             	lea    -0x1(%eax),%edx
c0102a3d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a40:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0102a42:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a45:	8b 00                	mov    (%eax),%eax
}
c0102a47:	5d                   	pop    %ebp
c0102a48:	c3                   	ret    

c0102a49 <__intr_save>:
__intr_save(void) {
c0102a49:	55                   	push   %ebp
c0102a4a:	89 e5                	mov    %esp,%ebp
c0102a4c:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0102a4f:	9c                   	pushf  
c0102a50:	58                   	pop    %eax
c0102a51:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0102a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0102a57:	25 00 02 00 00       	and    $0x200,%eax
c0102a5c:	85 c0                	test   %eax,%eax
c0102a5e:	74 0c                	je     c0102a6c <__intr_save+0x23>
        intr_disable();
c0102a60:	e8 2c ee ff ff       	call   c0101891 <intr_disable>
        return 1;
c0102a65:	b8 01 00 00 00       	mov    $0x1,%eax
c0102a6a:	eb 05                	jmp    c0102a71 <__intr_save+0x28>
    return 0;
c0102a6c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0102a71:	c9                   	leave  
c0102a72:	c3                   	ret    

c0102a73 <__intr_restore>:
__intr_restore(bool flag) {
c0102a73:	55                   	push   %ebp
c0102a74:	89 e5                	mov    %esp,%ebp
c0102a76:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0102a79:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0102a7d:	74 05                	je     c0102a84 <__intr_restore+0x11>
        intr_enable();
c0102a7f:	e8 07 ee ff ff       	call   c010188b <intr_enable>
}
c0102a84:	c9                   	leave  
c0102a85:	c3                   	ret    

c0102a86 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0102a86:	55                   	push   %ebp
c0102a87:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0102a89:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a8c:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0102a8f:	b8 23 00 00 00       	mov    $0x23,%eax
c0102a94:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0102a96:	b8 23 00 00 00       	mov    $0x23,%eax
c0102a9b:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0102a9d:	b8 10 00 00 00       	mov    $0x10,%eax
c0102aa2:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0102aa4:	b8 10 00 00 00       	mov    $0x10,%eax
c0102aa9:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0102aab:	b8 10 00 00 00       	mov    $0x10,%eax
c0102ab0:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0102ab2:	ea b9 2a 10 c0 08 00 	ljmp   $0x8,$0xc0102ab9
}
c0102ab9:	5d                   	pop    %ebp
c0102aba:	c3                   	ret    

c0102abb <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0102abb:	55                   	push   %ebp
c0102abc:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0102abe:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ac1:	a3 a4 ae 11 c0       	mov    %eax,0xc011aea4
}
c0102ac6:	5d                   	pop    %ebp
c0102ac7:	c3                   	ret    

c0102ac8 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0102ac8:	55                   	push   %ebp
c0102ac9:	89 e5                	mov    %esp,%ebp
c0102acb:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0102ace:	b8 00 70 11 c0       	mov    $0xc0117000,%eax
c0102ad3:	89 04 24             	mov    %eax,(%esp)
c0102ad6:	e8 e0 ff ff ff       	call   c0102abb <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0102adb:	66 c7 05 a8 ae 11 c0 	movw   $0x10,0xc011aea8
c0102ae2:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0102ae4:	66 c7 05 28 7a 11 c0 	movw   $0x68,0xc0117a28
c0102aeb:	68 00 
c0102aed:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0102af2:	66 a3 2a 7a 11 c0    	mov    %ax,0xc0117a2a
c0102af8:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0102afd:	c1 e8 10             	shr    $0x10,%eax
c0102b00:	a2 2c 7a 11 c0       	mov    %al,0xc0117a2c
c0102b05:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0102b0c:	83 e0 f0             	and    $0xfffffff0,%eax
c0102b0f:	83 c8 09             	or     $0x9,%eax
c0102b12:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0102b17:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0102b1e:	83 e0 ef             	and    $0xffffffef,%eax
c0102b21:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0102b26:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0102b2d:	83 e0 9f             	and    $0xffffff9f,%eax
c0102b30:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0102b35:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0102b3c:	83 c8 80             	or     $0xffffff80,%eax
c0102b3f:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0102b44:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0102b4b:	83 e0 f0             	and    $0xfffffff0,%eax
c0102b4e:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0102b53:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0102b5a:	83 e0 ef             	and    $0xffffffef,%eax
c0102b5d:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0102b62:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0102b69:	83 e0 df             	and    $0xffffffdf,%eax
c0102b6c:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0102b71:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0102b78:	83 c8 40             	or     $0x40,%eax
c0102b7b:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0102b80:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0102b87:	83 e0 7f             	and    $0x7f,%eax
c0102b8a:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0102b8f:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0102b94:	c1 e8 18             	shr    $0x18,%eax
c0102b97:	a2 2f 7a 11 c0       	mov    %al,0xc0117a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0102b9c:	c7 04 24 30 7a 11 c0 	movl   $0xc0117a30,(%esp)
c0102ba3:	e8 de fe ff ff       	call   c0102a86 <lgdt>
c0102ba8:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0102bae:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0102bb2:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0102bb5:	c9                   	leave  
c0102bb6:	c3                   	ret    

c0102bb7 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0102bb7:	55                   	push   %ebp
c0102bb8:	89 e5                	mov    %esp,%ebp
c0102bba:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0102bbd:	c7 05 10 af 11 c0 58 	movl   $0xc0107058,0xc011af10
c0102bc4:	70 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0102bc7:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0102bcc:	8b 00                	mov    (%eax),%eax
c0102bce:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102bd2:	c7 04 24 10 67 10 c0 	movl   $0xc0106710,(%esp)
c0102bd9:	e8 b4 d6 ff ff       	call   c0100292 <cprintf>
    pmm_manager->init();
c0102bde:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0102be3:	8b 40 04             	mov    0x4(%eax),%eax
c0102be6:	ff d0                	call   *%eax
}
c0102be8:	c9                   	leave  
c0102be9:	c3                   	ret    

c0102bea <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0102bea:	55                   	push   %ebp
c0102beb:	89 e5                	mov    %esp,%ebp
c0102bed:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0102bf0:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0102bf5:	8b 40 08             	mov    0x8(%eax),%eax
c0102bf8:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102bfb:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102bff:	8b 55 08             	mov    0x8(%ebp),%edx
c0102c02:	89 14 24             	mov    %edx,(%esp)
c0102c05:	ff d0                	call   *%eax
}
c0102c07:	c9                   	leave  
c0102c08:	c3                   	ret    

c0102c09 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0102c09:	55                   	push   %ebp
c0102c0a:	89 e5                	mov    %esp,%ebp
c0102c0c:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0102c0f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0102c16:	e8 2e fe ff ff       	call   c0102a49 <__intr_save>
c0102c1b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
c0102c1e:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0102c23:	8b 40 0c             	mov    0xc(%eax),%eax
c0102c26:	8b 55 08             	mov    0x8(%ebp),%edx
c0102c29:	89 14 24             	mov    %edx,(%esp)
c0102c2c:	ff d0                	call   *%eax
c0102c2e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
c0102c31:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102c34:	89 04 24             	mov    %eax,(%esp)
c0102c37:	e8 37 fe ff ff       	call   c0102a73 <__intr_restore>
    return page;
c0102c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102c3f:	c9                   	leave  
c0102c40:	c3                   	ret    

c0102c41 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0102c41:	55                   	push   %ebp
c0102c42:	89 e5                	mov    %esp,%ebp
c0102c44:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0102c47:	e8 fd fd ff ff       	call   c0102a49 <__intr_save>
c0102c4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0102c4f:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0102c54:	8b 40 10             	mov    0x10(%eax),%eax
c0102c57:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102c5a:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102c5e:	8b 55 08             	mov    0x8(%ebp),%edx
c0102c61:	89 14 24             	mov    %edx,(%esp)
c0102c64:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0102c66:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c69:	89 04 24             	mov    %eax,(%esp)
c0102c6c:	e8 02 fe ff ff       	call   c0102a73 <__intr_restore>
}
c0102c71:	c9                   	leave  
c0102c72:	c3                   	ret    

c0102c73 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0102c73:	55                   	push   %ebp
c0102c74:	89 e5                	mov    %esp,%ebp
c0102c76:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0102c79:	e8 cb fd ff ff       	call   c0102a49 <__intr_save>
c0102c7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0102c81:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0102c86:	8b 40 14             	mov    0x14(%eax),%eax
c0102c89:	ff d0                	call   *%eax
c0102c8b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0102c8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c91:	89 04 24             	mov    %eax,(%esp)
c0102c94:	e8 da fd ff ff       	call   c0102a73 <__intr_restore>
    return ret;
c0102c99:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0102c9c:	c9                   	leave  
c0102c9d:	c3                   	ret    

c0102c9e <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0102c9e:	55                   	push   %ebp
c0102c9f:	89 e5                	mov    %esp,%ebp
c0102ca1:	57                   	push   %edi
c0102ca2:	56                   	push   %esi
c0102ca3:	53                   	push   %ebx
c0102ca4:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0102caa:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0102cb1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0102cb8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0102cbf:	c7 04 24 27 67 10 c0 	movl   $0xc0106727,(%esp)
c0102cc6:	e8 c7 d5 ff ff       	call   c0100292 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0102ccb:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102cd2:	e9 15 01 00 00       	jmp    c0102dec <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0102cd7:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102cda:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102cdd:	89 d0                	mov    %edx,%eax
c0102cdf:	c1 e0 02             	shl    $0x2,%eax
c0102ce2:	01 d0                	add    %edx,%eax
c0102ce4:	c1 e0 02             	shl    $0x2,%eax
c0102ce7:	01 c8                	add    %ecx,%eax
c0102ce9:	8b 50 08             	mov    0x8(%eax),%edx
c0102cec:	8b 40 04             	mov    0x4(%eax),%eax
c0102cef:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0102cf2:	89 55 bc             	mov    %edx,-0x44(%ebp)
c0102cf5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102cf8:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102cfb:	89 d0                	mov    %edx,%eax
c0102cfd:	c1 e0 02             	shl    $0x2,%eax
c0102d00:	01 d0                	add    %edx,%eax
c0102d02:	c1 e0 02             	shl    $0x2,%eax
c0102d05:	01 c8                	add    %ecx,%eax
c0102d07:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102d0a:	8b 58 10             	mov    0x10(%eax),%ebx
c0102d0d:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0102d10:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0102d13:	01 c8                	add    %ecx,%eax
c0102d15:	11 da                	adc    %ebx,%edx
c0102d17:	89 45 b0             	mov    %eax,-0x50(%ebp)
c0102d1a:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0102d1d:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102d20:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102d23:	89 d0                	mov    %edx,%eax
c0102d25:	c1 e0 02             	shl    $0x2,%eax
c0102d28:	01 d0                	add    %edx,%eax
c0102d2a:	c1 e0 02             	shl    $0x2,%eax
c0102d2d:	01 c8                	add    %ecx,%eax
c0102d2f:	83 c0 14             	add    $0x14,%eax
c0102d32:	8b 00                	mov    (%eax),%eax
c0102d34:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c0102d3a:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0102d3d:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0102d40:	83 c0 ff             	add    $0xffffffff,%eax
c0102d43:	83 d2 ff             	adc    $0xffffffff,%edx
c0102d46:	89 c6                	mov    %eax,%esi
c0102d48:	89 d7                	mov    %edx,%edi
c0102d4a:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102d4d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102d50:	89 d0                	mov    %edx,%eax
c0102d52:	c1 e0 02             	shl    $0x2,%eax
c0102d55:	01 d0                	add    %edx,%eax
c0102d57:	c1 e0 02             	shl    $0x2,%eax
c0102d5a:	01 c8                	add    %ecx,%eax
c0102d5c:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102d5f:	8b 58 10             	mov    0x10(%eax),%ebx
c0102d62:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0102d68:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c0102d6c:	89 74 24 14          	mov    %esi,0x14(%esp)
c0102d70:	89 7c 24 18          	mov    %edi,0x18(%esp)
c0102d74:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0102d77:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0102d7a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102d7e:	89 54 24 10          	mov    %edx,0x10(%esp)
c0102d82:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0102d86:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0102d8a:	c7 04 24 34 67 10 c0 	movl   $0xc0106734,(%esp)
c0102d91:	e8 fc d4 ff ff       	call   c0100292 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0102d96:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102d99:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102d9c:	89 d0                	mov    %edx,%eax
c0102d9e:	c1 e0 02             	shl    $0x2,%eax
c0102da1:	01 d0                	add    %edx,%eax
c0102da3:	c1 e0 02             	shl    $0x2,%eax
c0102da6:	01 c8                	add    %ecx,%eax
c0102da8:	83 c0 14             	add    $0x14,%eax
c0102dab:	8b 00                	mov    (%eax),%eax
c0102dad:	83 f8 01             	cmp    $0x1,%eax
c0102db0:	75 36                	jne    c0102de8 <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
c0102db2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102db5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102db8:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0102dbb:	77 2b                	ja     c0102de8 <page_init+0x14a>
c0102dbd:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0102dc0:	72 05                	jb     c0102dc7 <page_init+0x129>
c0102dc2:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c0102dc5:	73 21                	jae    c0102de8 <page_init+0x14a>
c0102dc7:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0102dcb:	77 1b                	ja     c0102de8 <page_init+0x14a>
c0102dcd:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0102dd1:	72 09                	jb     c0102ddc <page_init+0x13e>
c0102dd3:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c0102dda:	77 0c                	ja     c0102de8 <page_init+0x14a>
                maxpa = end;
c0102ddc:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0102ddf:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0102de2:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0102de5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
c0102de8:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0102dec:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102def:	8b 00                	mov    (%eax),%eax
c0102df1:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0102df4:	0f 8f dd fe ff ff    	jg     c0102cd7 <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0102dfa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102dfe:	72 1d                	jb     c0102e1d <page_init+0x17f>
c0102e00:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102e04:	77 09                	ja     c0102e0f <page_init+0x171>
c0102e06:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0102e0d:	76 0e                	jbe    c0102e1d <page_init+0x17f>
        maxpa = KMEMSIZE;
c0102e0f:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0102e16:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0102e1d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102e20:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102e23:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0102e27:	c1 ea 0c             	shr    $0xc,%edx
c0102e2a:	a3 80 ae 11 c0       	mov    %eax,0xc011ae80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0102e2f:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c0102e36:	b8 28 af 11 c0       	mov    $0xc011af28,%eax
c0102e3b:	8d 50 ff             	lea    -0x1(%eax),%edx
c0102e3e:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0102e41:	01 d0                	add    %edx,%eax
c0102e43:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0102e46:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0102e49:	ba 00 00 00 00       	mov    $0x0,%edx
c0102e4e:	f7 75 ac             	divl   -0x54(%ebp)
c0102e51:	89 d0                	mov    %edx,%eax
c0102e53:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0102e56:	29 c2                	sub    %eax,%edx
c0102e58:	89 d0                	mov    %edx,%eax
c0102e5a:	a3 18 af 11 c0       	mov    %eax,0xc011af18

    for (i = 0; i < npage; i ++) {
c0102e5f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102e66:	eb 2f                	jmp    c0102e97 <page_init+0x1f9>
        SetPageReserved(pages + i);
c0102e68:	8b 0d 18 af 11 c0    	mov    0xc011af18,%ecx
c0102e6e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e71:	89 d0                	mov    %edx,%eax
c0102e73:	c1 e0 02             	shl    $0x2,%eax
c0102e76:	01 d0                	add    %edx,%eax
c0102e78:	c1 e0 02             	shl    $0x2,%eax
c0102e7b:	01 c8                	add    %ecx,%eax
c0102e7d:	83 c0 04             	add    $0x4,%eax
c0102e80:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c0102e87:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102e8a:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0102e8d:	8b 55 90             	mov    -0x70(%ebp),%edx
c0102e90:	0f ab 10             	bts    %edx,(%eax)
    for (i = 0; i < npage; i ++) {
c0102e93:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0102e97:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e9a:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0102e9f:	39 c2                	cmp    %eax,%edx
c0102ea1:	72 c5                	jb     c0102e68 <page_init+0x1ca>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0102ea3:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c0102ea9:	89 d0                	mov    %edx,%eax
c0102eab:	c1 e0 02             	shl    $0x2,%eax
c0102eae:	01 d0                	add    %edx,%eax
c0102eb0:	c1 e0 02             	shl    $0x2,%eax
c0102eb3:	89 c2                	mov    %eax,%edx
c0102eb5:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c0102eba:	01 d0                	add    %edx,%eax
c0102ebc:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c0102ebf:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c0102ec6:	77 23                	ja     c0102eeb <page_init+0x24d>
c0102ec8:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0102ecb:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102ecf:	c7 44 24 08 64 67 10 	movl   $0xc0106764,0x8(%esp)
c0102ed6:	c0 
c0102ed7:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c0102ede:	00 
c0102edf:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c0102ee6:	e8 fe d4 ff ff       	call   c01003e9 <__panic>
c0102eeb:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0102eee:	05 00 00 00 40       	add    $0x40000000,%eax
c0102ef3:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0102ef6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102efd:	e9 74 01 00 00       	jmp    c0103076 <page_init+0x3d8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0102f02:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102f05:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102f08:	89 d0                	mov    %edx,%eax
c0102f0a:	c1 e0 02             	shl    $0x2,%eax
c0102f0d:	01 d0                	add    %edx,%eax
c0102f0f:	c1 e0 02             	shl    $0x2,%eax
c0102f12:	01 c8                	add    %ecx,%eax
c0102f14:	8b 50 08             	mov    0x8(%eax),%edx
c0102f17:	8b 40 04             	mov    0x4(%eax),%eax
c0102f1a:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102f1d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0102f20:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102f23:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102f26:	89 d0                	mov    %edx,%eax
c0102f28:	c1 e0 02             	shl    $0x2,%eax
c0102f2b:	01 d0                	add    %edx,%eax
c0102f2d:	c1 e0 02             	shl    $0x2,%eax
c0102f30:	01 c8                	add    %ecx,%eax
c0102f32:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102f35:	8b 58 10             	mov    0x10(%eax),%ebx
c0102f38:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102f3b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102f3e:	01 c8                	add    %ecx,%eax
c0102f40:	11 da                	adc    %ebx,%edx
c0102f42:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0102f45:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0102f48:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102f4b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102f4e:	89 d0                	mov    %edx,%eax
c0102f50:	c1 e0 02             	shl    $0x2,%eax
c0102f53:	01 d0                	add    %edx,%eax
c0102f55:	c1 e0 02             	shl    $0x2,%eax
c0102f58:	01 c8                	add    %ecx,%eax
c0102f5a:	83 c0 14             	add    $0x14,%eax
c0102f5d:	8b 00                	mov    (%eax),%eax
c0102f5f:	83 f8 01             	cmp    $0x1,%eax
c0102f62:	0f 85 0a 01 00 00    	jne    c0103072 <page_init+0x3d4>
            if (begin < freemem) {
c0102f68:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102f6b:	ba 00 00 00 00       	mov    $0x0,%edx
c0102f70:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0102f73:	72 17                	jb     c0102f8c <page_init+0x2ee>
c0102f75:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0102f78:	77 05                	ja     c0102f7f <page_init+0x2e1>
c0102f7a:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0102f7d:	76 0d                	jbe    c0102f8c <page_init+0x2ee>
                begin = freemem;
c0102f7f:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102f82:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102f85:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0102f8c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0102f90:	72 1d                	jb     c0102faf <page_init+0x311>
c0102f92:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0102f96:	77 09                	ja     c0102fa1 <page_init+0x303>
c0102f98:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c0102f9f:	76 0e                	jbe    c0102faf <page_init+0x311>
                end = KMEMSIZE;
c0102fa1:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0102fa8:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0102faf:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102fb2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102fb5:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0102fb8:	0f 87 b4 00 00 00    	ja     c0103072 <page_init+0x3d4>
c0102fbe:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0102fc1:	72 09                	jb     c0102fcc <page_init+0x32e>
c0102fc3:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0102fc6:	0f 83 a6 00 00 00    	jae    c0103072 <page_init+0x3d4>
                begin = ROUNDUP(begin, PGSIZE);
c0102fcc:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c0102fd3:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102fd6:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0102fd9:	01 d0                	add    %edx,%eax
c0102fdb:	83 e8 01             	sub    $0x1,%eax
c0102fde:	89 45 98             	mov    %eax,-0x68(%ebp)
c0102fe1:	8b 45 98             	mov    -0x68(%ebp),%eax
c0102fe4:	ba 00 00 00 00       	mov    $0x0,%edx
c0102fe9:	f7 75 9c             	divl   -0x64(%ebp)
c0102fec:	89 d0                	mov    %edx,%eax
c0102fee:	8b 55 98             	mov    -0x68(%ebp),%edx
c0102ff1:	29 c2                	sub    %eax,%edx
c0102ff3:	89 d0                	mov    %edx,%eax
c0102ff5:	ba 00 00 00 00       	mov    $0x0,%edx
c0102ffa:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102ffd:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0103000:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103003:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0103006:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0103009:	ba 00 00 00 00       	mov    $0x0,%edx
c010300e:	89 c7                	mov    %eax,%edi
c0103010:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c0103016:	89 7d 80             	mov    %edi,-0x80(%ebp)
c0103019:	89 d0                	mov    %edx,%eax
c010301b:	83 e0 00             	and    $0x0,%eax
c010301e:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0103021:	8b 45 80             	mov    -0x80(%ebp),%eax
c0103024:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0103027:	89 45 c8             	mov    %eax,-0x38(%ebp)
c010302a:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c010302d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103030:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103033:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0103036:	77 3a                	ja     c0103072 <page_init+0x3d4>
c0103038:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c010303b:	72 05                	jb     c0103042 <page_init+0x3a4>
c010303d:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0103040:	73 30                	jae    c0103072 <page_init+0x3d4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0103042:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c0103045:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
c0103048:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010304b:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010304e:	29 c8                	sub    %ecx,%eax
c0103050:	19 da                	sbb    %ebx,%edx
c0103052:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0103056:	c1 ea 0c             	shr    $0xc,%edx
c0103059:	89 c3                	mov    %eax,%ebx
c010305b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010305e:	89 04 24             	mov    %eax,(%esp)
c0103061:	e8 a5 f8 ff ff       	call   c010290b <pa2page>
c0103066:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c010306a:	89 04 24             	mov    %eax,(%esp)
c010306d:	e8 78 fb ff ff       	call   c0102bea <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
c0103072:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0103076:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103079:	8b 00                	mov    (%eax),%eax
c010307b:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c010307e:	0f 8f 7e fe ff ff    	jg     c0102f02 <page_init+0x264>
                }
            }
        }
    }
}
c0103084:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c010308a:	5b                   	pop    %ebx
c010308b:	5e                   	pop    %esi
c010308c:	5f                   	pop    %edi
c010308d:	5d                   	pop    %ebp
c010308e:	c3                   	ret    

c010308f <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c010308f:	55                   	push   %ebp
c0103090:	89 e5                	mov    %esp,%ebp
c0103092:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0103095:	8b 45 14             	mov    0x14(%ebp),%eax
c0103098:	8b 55 0c             	mov    0xc(%ebp),%edx
c010309b:	31 d0                	xor    %edx,%eax
c010309d:	25 ff 0f 00 00       	and    $0xfff,%eax
c01030a2:	85 c0                	test   %eax,%eax
c01030a4:	74 24                	je     c01030ca <boot_map_segment+0x3b>
c01030a6:	c7 44 24 0c 96 67 10 	movl   $0xc0106796,0xc(%esp)
c01030ad:	c0 
c01030ae:	c7 44 24 08 ad 67 10 	movl   $0xc01067ad,0x8(%esp)
c01030b5:	c0 
c01030b6:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c01030bd:	00 
c01030be:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c01030c5:	e8 1f d3 ff ff       	call   c01003e9 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c01030ca:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c01030d1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01030d4:	25 ff 0f 00 00       	and    $0xfff,%eax
c01030d9:	89 c2                	mov    %eax,%edx
c01030db:	8b 45 10             	mov    0x10(%ebp),%eax
c01030de:	01 c2                	add    %eax,%edx
c01030e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01030e3:	01 d0                	add    %edx,%eax
c01030e5:	83 e8 01             	sub    $0x1,%eax
c01030e8:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01030eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01030ee:	ba 00 00 00 00       	mov    $0x0,%edx
c01030f3:	f7 75 f0             	divl   -0x10(%ebp)
c01030f6:	89 d0                	mov    %edx,%eax
c01030f8:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01030fb:	29 c2                	sub    %eax,%edx
c01030fd:	89 d0                	mov    %edx,%eax
c01030ff:	c1 e8 0c             	shr    $0xc,%eax
c0103102:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0103105:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103108:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010310b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010310e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103113:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c0103116:	8b 45 14             	mov    0x14(%ebp),%eax
c0103119:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010311c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010311f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103124:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0103127:	eb 6b                	jmp    c0103194 <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
c0103129:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0103130:	00 
c0103131:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103134:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103138:	8b 45 08             	mov    0x8(%ebp),%eax
c010313b:	89 04 24             	mov    %eax,(%esp)
c010313e:	e8 82 01 00 00       	call   c01032c5 <get_pte>
c0103143:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0103146:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c010314a:	75 24                	jne    c0103170 <boot_map_segment+0xe1>
c010314c:	c7 44 24 0c c2 67 10 	movl   $0xc01067c2,0xc(%esp)
c0103153:	c0 
c0103154:	c7 44 24 08 ad 67 10 	movl   $0xc01067ad,0x8(%esp)
c010315b:	c0 
c010315c:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c0103163:	00 
c0103164:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c010316b:	e8 79 d2 ff ff       	call   c01003e9 <__panic>
        *ptep = pa | PTE_P | perm;
c0103170:	8b 45 18             	mov    0x18(%ebp),%eax
c0103173:	8b 55 14             	mov    0x14(%ebp),%edx
c0103176:	09 d0                	or     %edx,%eax
c0103178:	83 c8 01             	or     $0x1,%eax
c010317b:	89 c2                	mov    %eax,%edx
c010317d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103180:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0103182:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0103186:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c010318d:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0103194:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103198:	75 8f                	jne    c0103129 <boot_map_segment+0x9a>
    }
}
c010319a:	c9                   	leave  
c010319b:	c3                   	ret    

c010319c <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c010319c:	55                   	push   %ebp
c010319d:	89 e5                	mov    %esp,%ebp
c010319f:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c01031a2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01031a9:	e8 5b fa ff ff       	call   c0102c09 <alloc_pages>
c01031ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c01031b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01031b5:	75 1c                	jne    c01031d3 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c01031b7:	c7 44 24 08 cf 67 10 	movl   $0xc01067cf,0x8(%esp)
c01031be:	c0 
c01031bf:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c01031c6:	00 
c01031c7:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c01031ce:	e8 16 d2 ff ff       	call   c01003e9 <__panic>
    }
    return page2kva(p);
c01031d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01031d6:	89 04 24             	mov    %eax,(%esp)
c01031d9:	e8 7c f7 ff ff       	call   c010295a <page2kva>
}
c01031de:	c9                   	leave  
c01031df:	c3                   	ret    

c01031e0 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c01031e0:	55                   	push   %ebp
c01031e1:	89 e5                	mov    %esp,%ebp
c01031e3:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c01031e6:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01031eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01031ee:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01031f5:	77 23                	ja     c010321a <pmm_init+0x3a>
c01031f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01031fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01031fe:	c7 44 24 08 64 67 10 	movl   $0xc0106764,0x8(%esp)
c0103205:	c0 
c0103206:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c010320d:	00 
c010320e:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c0103215:	e8 cf d1 ff ff       	call   c01003e9 <__panic>
c010321a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010321d:	05 00 00 00 40       	add    $0x40000000,%eax
c0103222:	a3 14 af 11 c0       	mov    %eax,0xc011af14
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0103227:	e8 8b f9 ff ff       	call   c0102bb7 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c010322c:	e8 6d fa ff ff       	call   c0102c9e <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0103231:	e8 e1 03 00 00       	call   c0103617 <check_alloc_page>

    check_pgdir();
c0103236:	e8 fa 03 00 00       	call   c0103635 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c010323b:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103240:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c0103246:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010324b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010324e:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0103255:	77 23                	ja     c010327a <pmm_init+0x9a>
c0103257:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010325a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010325e:	c7 44 24 08 64 67 10 	movl   $0xc0106764,0x8(%esp)
c0103265:	c0 
c0103266:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c010326d:	00 
c010326e:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c0103275:	e8 6f d1 ff ff       	call   c01003e9 <__panic>
c010327a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010327d:	05 00 00 00 40       	add    $0x40000000,%eax
c0103282:	83 c8 03             	or     $0x3,%eax
c0103285:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0103287:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010328c:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c0103293:	00 
c0103294:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010329b:	00 
c010329c:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c01032a3:	38 
c01032a4:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c01032ab:	c0 
c01032ac:	89 04 24             	mov    %eax,(%esp)
c01032af:	e8 db fd ff ff       	call   c010308f <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c01032b4:	e8 0f f8 ff ff       	call   c0102ac8 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c01032b9:	e8 12 0a 00 00       	call   c0103cd0 <check_boot_pgdir>

    print_pgdir();
c01032be:	e8 9a 0e 00 00       	call   c010415d <print_pgdir>

}
c01032c3:	c9                   	leave  
c01032c4:	c3                   	ret    

c01032c5 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c01032c5:	55                   	push   %ebp
c01032c6:	89 e5                	mov    %esp,%ebp
c01032c8:	83 ec 38             	sub    $0x38,%esp
    pde_t *pdep = &pgdir[PDX(la)];
c01032cb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01032ce:	c1 e8 16             	shr    $0x16,%eax
c01032d1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01032d8:	8b 45 08             	mov    0x8(%ebp),%eax
c01032db:	01 d0                	add    %edx,%eax
c01032dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    //获取一级页表项对应的入口地址
    if (!(*pdep & PTE_P)) {
c01032e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01032e3:	8b 00                	mov    (%eax),%eax
c01032e5:	83 e0 01             	and    $0x1,%eax
c01032e8:	85 c0                	test   %eax,%eax
c01032ea:	0f 85 af 00 00 00    	jne    c010339f <get_pte+0xda>
        //物理页不存在, create==0, null
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {//分配失败
c01032f0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01032f4:	74 15                	je     c010330b <get_pte+0x46>
c01032f6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01032fd:	e8 07 f9 ff ff       	call   c0102c09 <alloc_pages>
c0103302:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103305:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103309:	75 0a                	jne    c0103315 <get_pte+0x50>
            return NULL;
c010330b:	b8 00 00 00 00       	mov    $0x0,%eax
c0103310:	e9 e6 00 00 00       	jmp    c01033fb <get_pte+0x136>
        }
        //引用次数+1
        set_page_ref(page, 1);
c0103315:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010331c:	00 
c010331d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103320:	89 04 24             	mov    %eax,(%esp)
c0103323:	e8 e6 f6 ff ff       	call   c0102a0e <set_page_ref>
        //物理地址
        uintptr_t pa = page2pa(page);
c0103328:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010332b:	89 04 24             	mov    %eax,(%esp)
c010332e:	e8 c2 f5 ff ff       	call   c01028f5 <page2pa>
c0103333:	89 45 ec             	mov    %eax,-0x14(%ebp)
        ///物理地址转虚拟地址，并初始化,把新申请的数目为pgsize个页全设为0	
        memset(KADDR(pa), 0, PGSIZE);
c0103336:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103339:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010333c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010333f:	c1 e8 0c             	shr    $0xc,%eax
c0103342:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103345:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c010334a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c010334d:	72 23                	jb     c0103372 <get_pte+0xad>
c010334f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103352:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103356:	c7 44 24 08 c0 66 10 	movl   $0xc01066c0,0x8(%esp)
c010335d:	c0 
c010335e:	c7 44 24 04 56 01 00 	movl   $0x156,0x4(%esp)
c0103365:	00 
c0103366:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c010336d:	e8 77 d0 ff ff       	call   c01003e9 <__panic>
c0103372:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103375:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010337a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0103381:	00 
c0103382:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103389:	00 
c010338a:	89 04 24             	mov    %eax,(%esp)
c010338d:	e8 8b 23 00 00       	call   c010571d <memset>
        //设置控制位
        *pdep = pa | PTE_U | PTE_W | PTE_P;
c0103392:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103395:	83 c8 07             	or     $0x7,%eax
c0103398:	89 c2                	mov    %eax,%edx
c010339a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010339d:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c010339f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033a2:	8b 00                	mov    (%eax),%eax
c01033a4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01033a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01033ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01033af:	c1 e8 0c             	shr    $0xc,%eax
c01033b2:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01033b5:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c01033ba:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01033bd:	72 23                	jb     c01033e2 <get_pte+0x11d>
c01033bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01033c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01033c6:	c7 44 24 08 c0 66 10 	movl   $0xc01066c0,0x8(%esp)
c01033cd:	c0 
c01033ce:	c7 44 24 04 5a 01 00 	movl   $0x15a,0x4(%esp)
c01033d5:	00 
c01033d6:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c01033dd:	e8 07 d0 ff ff       	call   c01003e9 <__panic>
c01033e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01033e5:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01033ea:	8b 55 0c             	mov    0xc(%ebp),%edx
c01033ed:	c1 ea 0c             	shr    $0xc,%edx
c01033f0:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
c01033f6:	c1 e2 02             	shl    $0x2,%edx
c01033f9:	01 d0                	add    %edx,%eax
    //页目录项地址-->>页表物理地址-->>虚拟地址-->>页表项索引
    //PTX(la)：返回虚拟地址la的页表项索引
    //返回la对应的页表项入口地址
}
c01033fb:	c9                   	leave  
c01033fc:	c3                   	ret    

c01033fd <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c01033fd:	55                   	push   %ebp
c01033fe:	89 e5                	mov    %esp,%ebp
c0103400:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0103403:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010340a:	00 
c010340b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010340e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103412:	8b 45 08             	mov    0x8(%ebp),%eax
c0103415:	89 04 24             	mov    %eax,(%esp)
c0103418:	e8 a8 fe ff ff       	call   c01032c5 <get_pte>
c010341d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c0103420:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0103424:	74 08                	je     c010342e <get_page+0x31>
        *ptep_store = ptep;
c0103426:	8b 45 10             	mov    0x10(%ebp),%eax
c0103429:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010342c:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c010342e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103432:	74 1b                	je     c010344f <get_page+0x52>
c0103434:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103437:	8b 00                	mov    (%eax),%eax
c0103439:	83 e0 01             	and    $0x1,%eax
c010343c:	85 c0                	test   %eax,%eax
c010343e:	74 0f                	je     c010344f <get_page+0x52>
        return pte2page(*ptep);
c0103440:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103443:	8b 00                	mov    (%eax),%eax
c0103445:	89 04 24             	mov    %eax,(%esp)
c0103448:	e8 61 f5 ff ff       	call   c01029ae <pte2page>
c010344d:	eb 05                	jmp    c0103454 <get_page+0x57>
    }
    return NULL;
c010344f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103454:	c9                   	leave  
c0103455:	c3                   	ret    

c0103456 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0103456:	55                   	push   %ebp
c0103457:	89 e5                	mov    %esp,%ebp
c0103459:	83 ec 28             	sub    $0x28,%esp
    if (*ptep & PTE_P) {
c010345c:	8b 45 10             	mov    0x10(%ebp),%eax
c010345f:	8b 00                	mov    (%eax),%eax
c0103461:	83 e0 01             	and    $0x1,%eax
c0103464:	85 c0                	test   %eax,%eax
c0103466:	74 53                	je     c01034bb <page_remove_pte+0x65>
        //判断页表中该表项是否存在
        struct Page *page = pte2page(*ptep);//获得相应的page
c0103468:	8b 45 10             	mov    0x10(%ebp),%eax
c010346b:	8b 00                	mov    (%eax),%eax
c010346d:	89 04 24             	mov    %eax,(%esp)
c0103470:	e8 39 f5 ff ff       	call   c01029ae <pte2page>
c0103475:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
c0103478:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010347b:	89 04 24             	mov    %eax,(%esp)
c010347e:	e8 af f5 ff ff       	call   c0102a32 <page_ref_dec>
c0103483:	85 c0                	test   %eax,%eax
c0103485:	75 13                	jne    c010349a <page_remove_pte+0x44>
            ////除了当前进程，没有别的进程引用
            free_page(page);
c0103487:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010348e:	00 
c010348f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103492:	89 04 24             	mov    %eax,(%esp)
c0103495:	e8 a7 f7 ff ff       	call   c0102c41 <free_pages>
        }
        *ptep &= (~PTE_P); 
c010349a:	8b 45 10             	mov    0x10(%ebp),%eax
c010349d:	8b 00                	mov    (%eax),%eax
c010349f:	83 e0 fe             	and    $0xfffffffe,%eax
c01034a2:	89 c2                	mov    %eax,%edx
c01034a4:	8b 45 10             	mov    0x10(%ebp),%eax
c01034a7:	89 10                	mov    %edx,(%eax)
        // 将PTE的存在位设置为0，表示该映射关系无效
        tlb_invalidate(pgdir, la);
c01034a9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01034ac:	89 44 24 04          	mov    %eax,0x4(%esp)
c01034b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01034b3:	89 04 24             	mov    %eax,(%esp)
c01034b6:	e8 ff 00 00 00       	call   c01035ba <tlb_invalidate>
         //刷新TLB
    }
}
c01034bb:	c9                   	leave  
c01034bc:	c3                   	ret    

c01034bd <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c01034bd:	55                   	push   %ebp
c01034be:	89 e5                	mov    %esp,%ebp
c01034c0:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01034c3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01034ca:	00 
c01034cb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01034ce:	89 44 24 04          	mov    %eax,0x4(%esp)
c01034d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01034d5:	89 04 24             	mov    %eax,(%esp)
c01034d8:	e8 e8 fd ff ff       	call   c01032c5 <get_pte>
c01034dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c01034e0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01034e4:	74 19                	je     c01034ff <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c01034e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01034e9:	89 44 24 08          	mov    %eax,0x8(%esp)
c01034ed:	8b 45 0c             	mov    0xc(%ebp),%eax
c01034f0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01034f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01034f7:	89 04 24             	mov    %eax,(%esp)
c01034fa:	e8 57 ff ff ff       	call   c0103456 <page_remove_pte>
    }
}
c01034ff:	c9                   	leave  
c0103500:	c3                   	ret    

c0103501 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0103501:	55                   	push   %ebp
c0103502:	89 e5                	mov    %esp,%ebp
c0103504:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c0103507:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c010350e:	00 
c010350f:	8b 45 10             	mov    0x10(%ebp),%eax
c0103512:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103516:	8b 45 08             	mov    0x8(%ebp),%eax
c0103519:	89 04 24             	mov    %eax,(%esp)
c010351c:	e8 a4 fd ff ff       	call   c01032c5 <get_pte>
c0103521:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c0103524:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103528:	75 0a                	jne    c0103534 <page_insert+0x33>
        return -E_NO_MEM;
c010352a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c010352f:	e9 84 00 00 00       	jmp    c01035b8 <page_insert+0xb7>
    }
    page_ref_inc(page);
c0103534:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103537:	89 04 24             	mov    %eax,(%esp)
c010353a:	e8 dc f4 ff ff       	call   c0102a1b <page_ref_inc>
    if (*ptep & PTE_P) {
c010353f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103542:	8b 00                	mov    (%eax),%eax
c0103544:	83 e0 01             	and    $0x1,%eax
c0103547:	85 c0                	test   %eax,%eax
c0103549:	74 3e                	je     c0103589 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c010354b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010354e:	8b 00                	mov    (%eax),%eax
c0103550:	89 04 24             	mov    %eax,(%esp)
c0103553:	e8 56 f4 ff ff       	call   c01029ae <pte2page>
c0103558:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c010355b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010355e:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103561:	75 0d                	jne    c0103570 <page_insert+0x6f>
            page_ref_dec(page);
c0103563:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103566:	89 04 24             	mov    %eax,(%esp)
c0103569:	e8 c4 f4 ff ff       	call   c0102a32 <page_ref_dec>
c010356e:	eb 19                	jmp    c0103589 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0103570:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103573:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103577:	8b 45 10             	mov    0x10(%ebp),%eax
c010357a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010357e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103581:	89 04 24             	mov    %eax,(%esp)
c0103584:	e8 cd fe ff ff       	call   c0103456 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0103589:	8b 45 0c             	mov    0xc(%ebp),%eax
c010358c:	89 04 24             	mov    %eax,(%esp)
c010358f:	e8 61 f3 ff ff       	call   c01028f5 <page2pa>
c0103594:	0b 45 14             	or     0x14(%ebp),%eax
c0103597:	83 c8 01             	or     $0x1,%eax
c010359a:	89 c2                	mov    %eax,%edx
c010359c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010359f:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c01035a1:	8b 45 10             	mov    0x10(%ebp),%eax
c01035a4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01035a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01035ab:	89 04 24             	mov    %eax,(%esp)
c01035ae:	e8 07 00 00 00       	call   c01035ba <tlb_invalidate>
    return 0;
c01035b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01035b8:	c9                   	leave  
c01035b9:	c3                   	ret    

c01035ba <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c01035ba:	55                   	push   %ebp
c01035bb:	89 e5                	mov    %esp,%ebp
c01035bd:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c01035c0:	0f 20 d8             	mov    %cr3,%eax
c01035c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c01035c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
c01035c9:	89 c2                	mov    %eax,%edx
c01035cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01035ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01035d1:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01035d8:	77 23                	ja     c01035fd <tlb_invalidate+0x43>
c01035da:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01035e1:	c7 44 24 08 64 67 10 	movl   $0xc0106764,0x8(%esp)
c01035e8:	c0 
c01035e9:	c7 44 24 04 aa 01 00 	movl   $0x1aa,0x4(%esp)
c01035f0:	00 
c01035f1:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c01035f8:	e8 ec cd ff ff       	call   c01003e9 <__panic>
c01035fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103600:	05 00 00 00 40       	add    $0x40000000,%eax
c0103605:	39 c2                	cmp    %eax,%edx
c0103607:	75 0c                	jne    c0103615 <tlb_invalidate+0x5b>
        invlpg((void *)la);
c0103609:	8b 45 0c             	mov    0xc(%ebp),%eax
c010360c:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c010360f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103612:	0f 01 38             	invlpg (%eax)
    }
}
c0103615:	c9                   	leave  
c0103616:	c3                   	ret    

c0103617 <check_alloc_page>:

static void
check_alloc_page(void) {
c0103617:	55                   	push   %ebp
c0103618:	89 e5                	mov    %esp,%ebp
c010361a:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c010361d:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0103622:	8b 40 18             	mov    0x18(%eax),%eax
c0103625:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c0103627:	c7 04 24 e8 67 10 c0 	movl   $0xc01067e8,(%esp)
c010362e:	e8 5f cc ff ff       	call   c0100292 <cprintf>
}
c0103633:	c9                   	leave  
c0103634:	c3                   	ret    

c0103635 <check_pgdir>:

static void
check_pgdir(void) {
c0103635:	55                   	push   %ebp
c0103636:	89 e5                	mov    %esp,%ebp
c0103638:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c010363b:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0103640:	3d 00 80 03 00       	cmp    $0x38000,%eax
c0103645:	76 24                	jbe    c010366b <check_pgdir+0x36>
c0103647:	c7 44 24 0c 07 68 10 	movl   $0xc0106807,0xc(%esp)
c010364e:	c0 
c010364f:	c7 44 24 08 ad 67 10 	movl   $0xc01067ad,0x8(%esp)
c0103656:	c0 
c0103657:	c7 44 24 04 b7 01 00 	movl   $0x1b7,0x4(%esp)
c010365e:	00 
c010365f:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c0103666:	e8 7e cd ff ff       	call   c01003e9 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c010366b:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103670:	85 c0                	test   %eax,%eax
c0103672:	74 0e                	je     c0103682 <check_pgdir+0x4d>
c0103674:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103679:	25 ff 0f 00 00       	and    $0xfff,%eax
c010367e:	85 c0                	test   %eax,%eax
c0103680:	74 24                	je     c01036a6 <check_pgdir+0x71>
c0103682:	c7 44 24 0c 24 68 10 	movl   $0xc0106824,0xc(%esp)
c0103689:	c0 
c010368a:	c7 44 24 08 ad 67 10 	movl   $0xc01067ad,0x8(%esp)
c0103691:	c0 
c0103692:	c7 44 24 04 b8 01 00 	movl   $0x1b8,0x4(%esp)
c0103699:	00 
c010369a:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c01036a1:	e8 43 cd ff ff       	call   c01003e9 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c01036a6:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01036ab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01036b2:	00 
c01036b3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01036ba:	00 
c01036bb:	89 04 24             	mov    %eax,(%esp)
c01036be:	e8 3a fd ff ff       	call   c01033fd <get_page>
c01036c3:	85 c0                	test   %eax,%eax
c01036c5:	74 24                	je     c01036eb <check_pgdir+0xb6>
c01036c7:	c7 44 24 0c 5c 68 10 	movl   $0xc010685c,0xc(%esp)
c01036ce:	c0 
c01036cf:	c7 44 24 08 ad 67 10 	movl   $0xc01067ad,0x8(%esp)
c01036d6:	c0 
c01036d7:	c7 44 24 04 b9 01 00 	movl   $0x1b9,0x4(%esp)
c01036de:	00 
c01036df:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c01036e6:	e8 fe cc ff ff       	call   c01003e9 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c01036eb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01036f2:	e8 12 f5 ff ff       	call   c0102c09 <alloc_pages>
c01036f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c01036fa:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01036ff:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0103706:	00 
c0103707:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010370e:	00 
c010370f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103712:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103716:	89 04 24             	mov    %eax,(%esp)
c0103719:	e8 e3 fd ff ff       	call   c0103501 <page_insert>
c010371e:	85 c0                	test   %eax,%eax
c0103720:	74 24                	je     c0103746 <check_pgdir+0x111>
c0103722:	c7 44 24 0c 84 68 10 	movl   $0xc0106884,0xc(%esp)
c0103729:	c0 
c010372a:	c7 44 24 08 ad 67 10 	movl   $0xc01067ad,0x8(%esp)
c0103731:	c0 
c0103732:	c7 44 24 04 bd 01 00 	movl   $0x1bd,0x4(%esp)
c0103739:	00 
c010373a:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c0103741:	e8 a3 cc ff ff       	call   c01003e9 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0103746:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010374b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103752:	00 
c0103753:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010375a:	00 
c010375b:	89 04 24             	mov    %eax,(%esp)
c010375e:	e8 62 fb ff ff       	call   c01032c5 <get_pte>
c0103763:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103766:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010376a:	75 24                	jne    c0103790 <check_pgdir+0x15b>
c010376c:	c7 44 24 0c b0 68 10 	movl   $0xc01068b0,0xc(%esp)
c0103773:	c0 
c0103774:	c7 44 24 08 ad 67 10 	movl   $0xc01067ad,0x8(%esp)
c010377b:	c0 
c010377c:	c7 44 24 04 c0 01 00 	movl   $0x1c0,0x4(%esp)
c0103783:	00 
c0103784:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c010378b:	e8 59 cc ff ff       	call   c01003e9 <__panic>
    assert(pte2page(*ptep) == p1);
c0103790:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103793:	8b 00                	mov    (%eax),%eax
c0103795:	89 04 24             	mov    %eax,(%esp)
c0103798:	e8 11 f2 ff ff       	call   c01029ae <pte2page>
c010379d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01037a0:	74 24                	je     c01037c6 <check_pgdir+0x191>
c01037a2:	c7 44 24 0c dd 68 10 	movl   $0xc01068dd,0xc(%esp)
c01037a9:	c0 
c01037aa:	c7 44 24 08 ad 67 10 	movl   $0xc01067ad,0x8(%esp)
c01037b1:	c0 
c01037b2:	c7 44 24 04 c1 01 00 	movl   $0x1c1,0x4(%esp)
c01037b9:	00 
c01037ba:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c01037c1:	e8 23 cc ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p1) == 1);
c01037c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01037c9:	89 04 24             	mov    %eax,(%esp)
c01037cc:	e8 33 f2 ff ff       	call   c0102a04 <page_ref>
c01037d1:	83 f8 01             	cmp    $0x1,%eax
c01037d4:	74 24                	je     c01037fa <check_pgdir+0x1c5>
c01037d6:	c7 44 24 0c f3 68 10 	movl   $0xc01068f3,0xc(%esp)
c01037dd:	c0 
c01037de:	c7 44 24 08 ad 67 10 	movl   $0xc01067ad,0x8(%esp)
c01037e5:	c0 
c01037e6:	c7 44 24 04 c2 01 00 	movl   $0x1c2,0x4(%esp)
c01037ed:	00 
c01037ee:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c01037f5:	e8 ef cb ff ff       	call   c01003e9 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c01037fa:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01037ff:	8b 00                	mov    (%eax),%eax
c0103801:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103806:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103809:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010380c:	c1 e8 0c             	shr    $0xc,%eax
c010380f:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103812:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0103817:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c010381a:	72 23                	jb     c010383f <check_pgdir+0x20a>
c010381c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010381f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103823:	c7 44 24 08 c0 66 10 	movl   $0xc01066c0,0x8(%esp)
c010382a:	c0 
c010382b:	c7 44 24 04 c4 01 00 	movl   $0x1c4,0x4(%esp)
c0103832:	00 
c0103833:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c010383a:	e8 aa cb ff ff       	call   c01003e9 <__panic>
c010383f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103842:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103847:	83 c0 04             	add    $0x4,%eax
c010384a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c010384d:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103852:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103859:	00 
c010385a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103861:	00 
c0103862:	89 04 24             	mov    %eax,(%esp)
c0103865:	e8 5b fa ff ff       	call   c01032c5 <get_pte>
c010386a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010386d:	74 24                	je     c0103893 <check_pgdir+0x25e>
c010386f:	c7 44 24 0c 08 69 10 	movl   $0xc0106908,0xc(%esp)
c0103876:	c0 
c0103877:	c7 44 24 08 ad 67 10 	movl   $0xc01067ad,0x8(%esp)
c010387e:	c0 
c010387f:	c7 44 24 04 c5 01 00 	movl   $0x1c5,0x4(%esp)
c0103886:	00 
c0103887:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c010388e:	e8 56 cb ff ff       	call   c01003e9 <__panic>

    p2 = alloc_page();
c0103893:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010389a:	e8 6a f3 ff ff       	call   c0102c09 <alloc_pages>
c010389f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c01038a2:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01038a7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c01038ae:	00 
c01038af:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01038b6:	00 
c01038b7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01038ba:	89 54 24 04          	mov    %edx,0x4(%esp)
c01038be:	89 04 24             	mov    %eax,(%esp)
c01038c1:	e8 3b fc ff ff       	call   c0103501 <page_insert>
c01038c6:	85 c0                	test   %eax,%eax
c01038c8:	74 24                	je     c01038ee <check_pgdir+0x2b9>
c01038ca:	c7 44 24 0c 30 69 10 	movl   $0xc0106930,0xc(%esp)
c01038d1:	c0 
c01038d2:	c7 44 24 08 ad 67 10 	movl   $0xc01067ad,0x8(%esp)
c01038d9:	c0 
c01038da:	c7 44 24 04 c8 01 00 	movl   $0x1c8,0x4(%esp)
c01038e1:	00 
c01038e2:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c01038e9:	e8 fb ca ff ff       	call   c01003e9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c01038ee:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01038f3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01038fa:	00 
c01038fb:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103902:	00 
c0103903:	89 04 24             	mov    %eax,(%esp)
c0103906:	e8 ba f9 ff ff       	call   c01032c5 <get_pte>
c010390b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010390e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103912:	75 24                	jne    c0103938 <check_pgdir+0x303>
c0103914:	c7 44 24 0c 68 69 10 	movl   $0xc0106968,0xc(%esp)
c010391b:	c0 
c010391c:	c7 44 24 08 ad 67 10 	movl   $0xc01067ad,0x8(%esp)
c0103923:	c0 
c0103924:	c7 44 24 04 c9 01 00 	movl   $0x1c9,0x4(%esp)
c010392b:	00 
c010392c:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c0103933:	e8 b1 ca ff ff       	call   c01003e9 <__panic>
    assert(*ptep & PTE_U);
c0103938:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010393b:	8b 00                	mov    (%eax),%eax
c010393d:	83 e0 04             	and    $0x4,%eax
c0103940:	85 c0                	test   %eax,%eax
c0103942:	75 24                	jne    c0103968 <check_pgdir+0x333>
c0103944:	c7 44 24 0c 98 69 10 	movl   $0xc0106998,0xc(%esp)
c010394b:	c0 
c010394c:	c7 44 24 08 ad 67 10 	movl   $0xc01067ad,0x8(%esp)
c0103953:	c0 
c0103954:	c7 44 24 04 ca 01 00 	movl   $0x1ca,0x4(%esp)
c010395b:	00 
c010395c:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c0103963:	e8 81 ca ff ff       	call   c01003e9 <__panic>
    assert(*ptep & PTE_W);
c0103968:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010396b:	8b 00                	mov    (%eax),%eax
c010396d:	83 e0 02             	and    $0x2,%eax
c0103970:	85 c0                	test   %eax,%eax
c0103972:	75 24                	jne    c0103998 <check_pgdir+0x363>
c0103974:	c7 44 24 0c a6 69 10 	movl   $0xc01069a6,0xc(%esp)
c010397b:	c0 
c010397c:	c7 44 24 08 ad 67 10 	movl   $0xc01067ad,0x8(%esp)
c0103983:	c0 
c0103984:	c7 44 24 04 cb 01 00 	movl   $0x1cb,0x4(%esp)
c010398b:	00 
c010398c:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c0103993:	e8 51 ca ff ff       	call   c01003e9 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0103998:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010399d:	8b 00                	mov    (%eax),%eax
c010399f:	83 e0 04             	and    $0x4,%eax
c01039a2:	85 c0                	test   %eax,%eax
c01039a4:	75 24                	jne    c01039ca <check_pgdir+0x395>
c01039a6:	c7 44 24 0c b4 69 10 	movl   $0xc01069b4,0xc(%esp)
c01039ad:	c0 
c01039ae:	c7 44 24 08 ad 67 10 	movl   $0xc01067ad,0x8(%esp)
c01039b5:	c0 
c01039b6:	c7 44 24 04 cc 01 00 	movl   $0x1cc,0x4(%esp)
c01039bd:	00 
c01039be:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c01039c5:	e8 1f ca ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p2) == 1);
c01039ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01039cd:	89 04 24             	mov    %eax,(%esp)
c01039d0:	e8 2f f0 ff ff       	call   c0102a04 <page_ref>
c01039d5:	83 f8 01             	cmp    $0x1,%eax
c01039d8:	74 24                	je     c01039fe <check_pgdir+0x3c9>
c01039da:	c7 44 24 0c ca 69 10 	movl   $0xc01069ca,0xc(%esp)
c01039e1:	c0 
c01039e2:	c7 44 24 08 ad 67 10 	movl   $0xc01067ad,0x8(%esp)
c01039e9:	c0 
c01039ea:	c7 44 24 04 cd 01 00 	movl   $0x1cd,0x4(%esp)
c01039f1:	00 
c01039f2:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c01039f9:	e8 eb c9 ff ff       	call   c01003e9 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c01039fe:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103a03:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0103a0a:	00 
c0103a0b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0103a12:	00 
c0103a13:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103a16:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103a1a:	89 04 24             	mov    %eax,(%esp)
c0103a1d:	e8 df fa ff ff       	call   c0103501 <page_insert>
c0103a22:	85 c0                	test   %eax,%eax
c0103a24:	74 24                	je     c0103a4a <check_pgdir+0x415>
c0103a26:	c7 44 24 0c dc 69 10 	movl   $0xc01069dc,0xc(%esp)
c0103a2d:	c0 
c0103a2e:	c7 44 24 08 ad 67 10 	movl   $0xc01067ad,0x8(%esp)
c0103a35:	c0 
c0103a36:	c7 44 24 04 cf 01 00 	movl   $0x1cf,0x4(%esp)
c0103a3d:	00 
c0103a3e:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c0103a45:	e8 9f c9 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p1) == 2);
c0103a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a4d:	89 04 24             	mov    %eax,(%esp)
c0103a50:	e8 af ef ff ff       	call   c0102a04 <page_ref>
c0103a55:	83 f8 02             	cmp    $0x2,%eax
c0103a58:	74 24                	je     c0103a7e <check_pgdir+0x449>
c0103a5a:	c7 44 24 0c 08 6a 10 	movl   $0xc0106a08,0xc(%esp)
c0103a61:	c0 
c0103a62:	c7 44 24 08 ad 67 10 	movl   $0xc01067ad,0x8(%esp)
c0103a69:	c0 
c0103a6a:	c7 44 24 04 d0 01 00 	movl   $0x1d0,0x4(%esp)
c0103a71:	00 
c0103a72:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c0103a79:	e8 6b c9 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p2) == 0);
c0103a7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103a81:	89 04 24             	mov    %eax,(%esp)
c0103a84:	e8 7b ef ff ff       	call   c0102a04 <page_ref>
c0103a89:	85 c0                	test   %eax,%eax
c0103a8b:	74 24                	je     c0103ab1 <check_pgdir+0x47c>
c0103a8d:	c7 44 24 0c 1a 6a 10 	movl   $0xc0106a1a,0xc(%esp)
c0103a94:	c0 
c0103a95:	c7 44 24 08 ad 67 10 	movl   $0xc01067ad,0x8(%esp)
c0103a9c:	c0 
c0103a9d:	c7 44 24 04 d1 01 00 	movl   $0x1d1,0x4(%esp)
c0103aa4:	00 
c0103aa5:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c0103aac:	e8 38 c9 ff ff       	call   c01003e9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0103ab1:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103ab6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103abd:	00 
c0103abe:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103ac5:	00 
c0103ac6:	89 04 24             	mov    %eax,(%esp)
c0103ac9:	e8 f7 f7 ff ff       	call   c01032c5 <get_pte>
c0103ace:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103ad1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103ad5:	75 24                	jne    c0103afb <check_pgdir+0x4c6>
c0103ad7:	c7 44 24 0c 68 69 10 	movl   $0xc0106968,0xc(%esp)
c0103ade:	c0 
c0103adf:	c7 44 24 08 ad 67 10 	movl   $0xc01067ad,0x8(%esp)
c0103ae6:	c0 
c0103ae7:	c7 44 24 04 d2 01 00 	movl   $0x1d2,0x4(%esp)
c0103aee:	00 
c0103aef:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c0103af6:	e8 ee c8 ff ff       	call   c01003e9 <__panic>
    assert(pte2page(*ptep) == p1);
c0103afb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103afe:	8b 00                	mov    (%eax),%eax
c0103b00:	89 04 24             	mov    %eax,(%esp)
c0103b03:	e8 a6 ee ff ff       	call   c01029ae <pte2page>
c0103b08:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103b0b:	74 24                	je     c0103b31 <check_pgdir+0x4fc>
c0103b0d:	c7 44 24 0c dd 68 10 	movl   $0xc01068dd,0xc(%esp)
c0103b14:	c0 
c0103b15:	c7 44 24 08 ad 67 10 	movl   $0xc01067ad,0x8(%esp)
c0103b1c:	c0 
c0103b1d:	c7 44 24 04 d3 01 00 	movl   $0x1d3,0x4(%esp)
c0103b24:	00 
c0103b25:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c0103b2c:	e8 b8 c8 ff ff       	call   c01003e9 <__panic>
    assert((*ptep & PTE_U) == 0);
c0103b31:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103b34:	8b 00                	mov    (%eax),%eax
c0103b36:	83 e0 04             	and    $0x4,%eax
c0103b39:	85 c0                	test   %eax,%eax
c0103b3b:	74 24                	je     c0103b61 <check_pgdir+0x52c>
c0103b3d:	c7 44 24 0c 2c 6a 10 	movl   $0xc0106a2c,0xc(%esp)
c0103b44:	c0 
c0103b45:	c7 44 24 08 ad 67 10 	movl   $0xc01067ad,0x8(%esp)
c0103b4c:	c0 
c0103b4d:	c7 44 24 04 d4 01 00 	movl   $0x1d4,0x4(%esp)
c0103b54:	00 
c0103b55:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c0103b5c:	e8 88 c8 ff ff       	call   c01003e9 <__panic>

    page_remove(boot_pgdir, 0x0);
c0103b61:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103b66:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103b6d:	00 
c0103b6e:	89 04 24             	mov    %eax,(%esp)
c0103b71:	e8 47 f9 ff ff       	call   c01034bd <page_remove>
    assert(page_ref(p1) == 1);
c0103b76:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b79:	89 04 24             	mov    %eax,(%esp)
c0103b7c:	e8 83 ee ff ff       	call   c0102a04 <page_ref>
c0103b81:	83 f8 01             	cmp    $0x1,%eax
c0103b84:	74 24                	je     c0103baa <check_pgdir+0x575>
c0103b86:	c7 44 24 0c f3 68 10 	movl   $0xc01068f3,0xc(%esp)
c0103b8d:	c0 
c0103b8e:	c7 44 24 08 ad 67 10 	movl   $0xc01067ad,0x8(%esp)
c0103b95:	c0 
c0103b96:	c7 44 24 04 d7 01 00 	movl   $0x1d7,0x4(%esp)
c0103b9d:	00 
c0103b9e:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c0103ba5:	e8 3f c8 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p2) == 0);
c0103baa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103bad:	89 04 24             	mov    %eax,(%esp)
c0103bb0:	e8 4f ee ff ff       	call   c0102a04 <page_ref>
c0103bb5:	85 c0                	test   %eax,%eax
c0103bb7:	74 24                	je     c0103bdd <check_pgdir+0x5a8>
c0103bb9:	c7 44 24 0c 1a 6a 10 	movl   $0xc0106a1a,0xc(%esp)
c0103bc0:	c0 
c0103bc1:	c7 44 24 08 ad 67 10 	movl   $0xc01067ad,0x8(%esp)
c0103bc8:	c0 
c0103bc9:	c7 44 24 04 d8 01 00 	movl   $0x1d8,0x4(%esp)
c0103bd0:	00 
c0103bd1:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c0103bd8:	e8 0c c8 ff ff       	call   c01003e9 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0103bdd:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103be2:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103be9:	00 
c0103bea:	89 04 24             	mov    %eax,(%esp)
c0103bed:	e8 cb f8 ff ff       	call   c01034bd <page_remove>
    assert(page_ref(p1) == 0);
c0103bf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103bf5:	89 04 24             	mov    %eax,(%esp)
c0103bf8:	e8 07 ee ff ff       	call   c0102a04 <page_ref>
c0103bfd:	85 c0                	test   %eax,%eax
c0103bff:	74 24                	je     c0103c25 <check_pgdir+0x5f0>
c0103c01:	c7 44 24 0c 41 6a 10 	movl   $0xc0106a41,0xc(%esp)
c0103c08:	c0 
c0103c09:	c7 44 24 08 ad 67 10 	movl   $0xc01067ad,0x8(%esp)
c0103c10:	c0 
c0103c11:	c7 44 24 04 db 01 00 	movl   $0x1db,0x4(%esp)
c0103c18:	00 
c0103c19:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c0103c20:	e8 c4 c7 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p2) == 0);
c0103c25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103c28:	89 04 24             	mov    %eax,(%esp)
c0103c2b:	e8 d4 ed ff ff       	call   c0102a04 <page_ref>
c0103c30:	85 c0                	test   %eax,%eax
c0103c32:	74 24                	je     c0103c58 <check_pgdir+0x623>
c0103c34:	c7 44 24 0c 1a 6a 10 	movl   $0xc0106a1a,0xc(%esp)
c0103c3b:	c0 
c0103c3c:	c7 44 24 08 ad 67 10 	movl   $0xc01067ad,0x8(%esp)
c0103c43:	c0 
c0103c44:	c7 44 24 04 dc 01 00 	movl   $0x1dc,0x4(%esp)
c0103c4b:	00 
c0103c4c:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c0103c53:	e8 91 c7 ff ff       	call   c01003e9 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0103c58:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103c5d:	8b 00                	mov    (%eax),%eax
c0103c5f:	89 04 24             	mov    %eax,(%esp)
c0103c62:	e8 85 ed ff ff       	call   c01029ec <pde2page>
c0103c67:	89 04 24             	mov    %eax,(%esp)
c0103c6a:	e8 95 ed ff ff       	call   c0102a04 <page_ref>
c0103c6f:	83 f8 01             	cmp    $0x1,%eax
c0103c72:	74 24                	je     c0103c98 <check_pgdir+0x663>
c0103c74:	c7 44 24 0c 54 6a 10 	movl   $0xc0106a54,0xc(%esp)
c0103c7b:	c0 
c0103c7c:	c7 44 24 08 ad 67 10 	movl   $0xc01067ad,0x8(%esp)
c0103c83:	c0 
c0103c84:	c7 44 24 04 de 01 00 	movl   $0x1de,0x4(%esp)
c0103c8b:	00 
c0103c8c:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c0103c93:	e8 51 c7 ff ff       	call   c01003e9 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0103c98:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103c9d:	8b 00                	mov    (%eax),%eax
c0103c9f:	89 04 24             	mov    %eax,(%esp)
c0103ca2:	e8 45 ed ff ff       	call   c01029ec <pde2page>
c0103ca7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103cae:	00 
c0103caf:	89 04 24             	mov    %eax,(%esp)
c0103cb2:	e8 8a ef ff ff       	call   c0102c41 <free_pages>
    boot_pgdir[0] = 0;
c0103cb7:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103cbc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0103cc2:	c7 04 24 7b 6a 10 c0 	movl   $0xc0106a7b,(%esp)
c0103cc9:	e8 c4 c5 ff ff       	call   c0100292 <cprintf>
}
c0103cce:	c9                   	leave  
c0103ccf:	c3                   	ret    

c0103cd0 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0103cd0:	55                   	push   %ebp
c0103cd1:	89 e5                	mov    %esp,%ebp
c0103cd3:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0103cd6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103cdd:	e9 ca 00 00 00       	jmp    c0103dac <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0103ce2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ce5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103ce8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103ceb:	c1 e8 0c             	shr    $0xc,%eax
c0103cee:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103cf1:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0103cf6:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0103cf9:	72 23                	jb     c0103d1e <check_boot_pgdir+0x4e>
c0103cfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103cfe:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103d02:	c7 44 24 08 c0 66 10 	movl   $0xc01066c0,0x8(%esp)
c0103d09:	c0 
c0103d0a:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
c0103d11:	00 
c0103d12:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c0103d19:	e8 cb c6 ff ff       	call   c01003e9 <__panic>
c0103d1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103d21:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103d26:	89 c2                	mov    %eax,%edx
c0103d28:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103d2d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103d34:	00 
c0103d35:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103d39:	89 04 24             	mov    %eax,(%esp)
c0103d3c:	e8 84 f5 ff ff       	call   c01032c5 <get_pte>
c0103d41:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103d44:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103d48:	75 24                	jne    c0103d6e <check_boot_pgdir+0x9e>
c0103d4a:	c7 44 24 0c 98 6a 10 	movl   $0xc0106a98,0xc(%esp)
c0103d51:	c0 
c0103d52:	c7 44 24 08 ad 67 10 	movl   $0xc01067ad,0x8(%esp)
c0103d59:	c0 
c0103d5a:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
c0103d61:	00 
c0103d62:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c0103d69:	e8 7b c6 ff ff       	call   c01003e9 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0103d6e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103d71:	8b 00                	mov    (%eax),%eax
c0103d73:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103d78:	89 c2                	mov    %eax,%edx
c0103d7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103d7d:	39 c2                	cmp    %eax,%edx
c0103d7f:	74 24                	je     c0103da5 <check_boot_pgdir+0xd5>
c0103d81:	c7 44 24 0c d5 6a 10 	movl   $0xc0106ad5,0xc(%esp)
c0103d88:	c0 
c0103d89:	c7 44 24 08 ad 67 10 	movl   $0xc01067ad,0x8(%esp)
c0103d90:	c0 
c0103d91:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
c0103d98:	00 
c0103d99:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c0103da0:	e8 44 c6 ff ff       	call   c01003e9 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
c0103da5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0103dac:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103daf:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0103db4:	39 c2                	cmp    %eax,%edx
c0103db6:	0f 82 26 ff ff ff    	jb     c0103ce2 <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0103dbc:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103dc1:	05 ac 0f 00 00       	add    $0xfac,%eax
c0103dc6:	8b 00                	mov    (%eax),%eax
c0103dc8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103dcd:	89 c2                	mov    %eax,%edx
c0103dcf:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103dd4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103dd7:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c0103dde:	77 23                	ja     c0103e03 <check_boot_pgdir+0x133>
c0103de0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103de3:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103de7:	c7 44 24 08 64 67 10 	movl   $0xc0106764,0x8(%esp)
c0103dee:	c0 
c0103def:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
c0103df6:	00 
c0103df7:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c0103dfe:	e8 e6 c5 ff ff       	call   c01003e9 <__panic>
c0103e03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103e06:	05 00 00 00 40       	add    $0x40000000,%eax
c0103e0b:	39 c2                	cmp    %eax,%edx
c0103e0d:	74 24                	je     c0103e33 <check_boot_pgdir+0x163>
c0103e0f:	c7 44 24 0c ec 6a 10 	movl   $0xc0106aec,0xc(%esp)
c0103e16:	c0 
c0103e17:	c7 44 24 08 ad 67 10 	movl   $0xc01067ad,0x8(%esp)
c0103e1e:	c0 
c0103e1f:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
c0103e26:	00 
c0103e27:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c0103e2e:	e8 b6 c5 ff ff       	call   c01003e9 <__panic>

    assert(boot_pgdir[0] == 0);
c0103e33:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103e38:	8b 00                	mov    (%eax),%eax
c0103e3a:	85 c0                	test   %eax,%eax
c0103e3c:	74 24                	je     c0103e62 <check_boot_pgdir+0x192>
c0103e3e:	c7 44 24 0c 20 6b 10 	movl   $0xc0106b20,0xc(%esp)
c0103e45:	c0 
c0103e46:	c7 44 24 08 ad 67 10 	movl   $0xc01067ad,0x8(%esp)
c0103e4d:	c0 
c0103e4e:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
c0103e55:	00 
c0103e56:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c0103e5d:	e8 87 c5 ff ff       	call   c01003e9 <__panic>

    struct Page *p;
    p = alloc_page();
c0103e62:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103e69:	e8 9b ed ff ff       	call   c0102c09 <alloc_pages>
c0103e6e:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0103e71:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103e76:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0103e7d:	00 
c0103e7e:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0103e85:	00 
c0103e86:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103e89:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103e8d:	89 04 24             	mov    %eax,(%esp)
c0103e90:	e8 6c f6 ff ff       	call   c0103501 <page_insert>
c0103e95:	85 c0                	test   %eax,%eax
c0103e97:	74 24                	je     c0103ebd <check_boot_pgdir+0x1ed>
c0103e99:	c7 44 24 0c 34 6b 10 	movl   $0xc0106b34,0xc(%esp)
c0103ea0:	c0 
c0103ea1:	c7 44 24 08 ad 67 10 	movl   $0xc01067ad,0x8(%esp)
c0103ea8:	c0 
c0103ea9:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
c0103eb0:	00 
c0103eb1:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c0103eb8:	e8 2c c5 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p) == 1);
c0103ebd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103ec0:	89 04 24             	mov    %eax,(%esp)
c0103ec3:	e8 3c eb ff ff       	call   c0102a04 <page_ref>
c0103ec8:	83 f8 01             	cmp    $0x1,%eax
c0103ecb:	74 24                	je     c0103ef1 <check_boot_pgdir+0x221>
c0103ecd:	c7 44 24 0c 62 6b 10 	movl   $0xc0106b62,0xc(%esp)
c0103ed4:	c0 
c0103ed5:	c7 44 24 08 ad 67 10 	movl   $0xc01067ad,0x8(%esp)
c0103edc:	c0 
c0103edd:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
c0103ee4:	00 
c0103ee5:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c0103eec:	e8 f8 c4 ff ff       	call   c01003e9 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0103ef1:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103ef6:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0103efd:	00 
c0103efe:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0103f05:	00 
c0103f06:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103f09:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103f0d:	89 04 24             	mov    %eax,(%esp)
c0103f10:	e8 ec f5 ff ff       	call   c0103501 <page_insert>
c0103f15:	85 c0                	test   %eax,%eax
c0103f17:	74 24                	je     c0103f3d <check_boot_pgdir+0x26d>
c0103f19:	c7 44 24 0c 74 6b 10 	movl   $0xc0106b74,0xc(%esp)
c0103f20:	c0 
c0103f21:	c7 44 24 08 ad 67 10 	movl   $0xc01067ad,0x8(%esp)
c0103f28:	c0 
c0103f29:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
c0103f30:	00 
c0103f31:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c0103f38:	e8 ac c4 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p) == 2);
c0103f3d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103f40:	89 04 24             	mov    %eax,(%esp)
c0103f43:	e8 bc ea ff ff       	call   c0102a04 <page_ref>
c0103f48:	83 f8 02             	cmp    $0x2,%eax
c0103f4b:	74 24                	je     c0103f71 <check_boot_pgdir+0x2a1>
c0103f4d:	c7 44 24 0c ab 6b 10 	movl   $0xc0106bab,0xc(%esp)
c0103f54:	c0 
c0103f55:	c7 44 24 08 ad 67 10 	movl   $0xc01067ad,0x8(%esp)
c0103f5c:	c0 
c0103f5d:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
c0103f64:	00 
c0103f65:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c0103f6c:	e8 78 c4 ff ff       	call   c01003e9 <__panic>

    const char *str = "ucore: Hello world!!";
c0103f71:	c7 45 dc bc 6b 10 c0 	movl   $0xc0106bbc,-0x24(%ebp)
    strcpy((void *)0x100, str);
c0103f78:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103f7b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103f7f:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0103f86:	e8 bb 14 00 00       	call   c0105446 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0103f8b:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0103f92:	00 
c0103f93:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0103f9a:	e8 20 15 00 00       	call   c01054bf <strcmp>
c0103f9f:	85 c0                	test   %eax,%eax
c0103fa1:	74 24                	je     c0103fc7 <check_boot_pgdir+0x2f7>
c0103fa3:	c7 44 24 0c d4 6b 10 	movl   $0xc0106bd4,0xc(%esp)
c0103faa:	c0 
c0103fab:	c7 44 24 08 ad 67 10 	movl   $0xc01067ad,0x8(%esp)
c0103fb2:	c0 
c0103fb3:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
c0103fba:	00 
c0103fbb:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c0103fc2:	e8 22 c4 ff ff       	call   c01003e9 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0103fc7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103fca:	89 04 24             	mov    %eax,(%esp)
c0103fcd:	e8 88 e9 ff ff       	call   c010295a <page2kva>
c0103fd2:	05 00 01 00 00       	add    $0x100,%eax
c0103fd7:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0103fda:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0103fe1:	e8 08 14 00 00       	call   c01053ee <strlen>
c0103fe6:	85 c0                	test   %eax,%eax
c0103fe8:	74 24                	je     c010400e <check_boot_pgdir+0x33e>
c0103fea:	c7 44 24 0c 0c 6c 10 	movl   $0xc0106c0c,0xc(%esp)
c0103ff1:	c0 
c0103ff2:	c7 44 24 08 ad 67 10 	movl   $0xc01067ad,0x8(%esp)
c0103ff9:	c0 
c0103ffa:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
c0104001:	00 
c0104002:	c7 04 24 88 67 10 c0 	movl   $0xc0106788,(%esp)
c0104009:	e8 db c3 ff ff       	call   c01003e9 <__panic>

    free_page(p);
c010400e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104015:	00 
c0104016:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104019:	89 04 24             	mov    %eax,(%esp)
c010401c:	e8 20 ec ff ff       	call   c0102c41 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0104021:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104026:	8b 00                	mov    (%eax),%eax
c0104028:	89 04 24             	mov    %eax,(%esp)
c010402b:	e8 bc e9 ff ff       	call   c01029ec <pde2page>
c0104030:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104037:	00 
c0104038:	89 04 24             	mov    %eax,(%esp)
c010403b:	e8 01 ec ff ff       	call   c0102c41 <free_pages>
    boot_pgdir[0] = 0;
c0104040:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104045:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c010404b:	c7 04 24 30 6c 10 c0 	movl   $0xc0106c30,(%esp)
c0104052:	e8 3b c2 ff ff       	call   c0100292 <cprintf>
}
c0104057:	c9                   	leave  
c0104058:	c3                   	ret    

c0104059 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0104059:	55                   	push   %ebp
c010405a:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c010405c:	8b 45 08             	mov    0x8(%ebp),%eax
c010405f:	83 e0 04             	and    $0x4,%eax
c0104062:	85 c0                	test   %eax,%eax
c0104064:	74 07                	je     c010406d <perm2str+0x14>
c0104066:	b8 75 00 00 00       	mov    $0x75,%eax
c010406b:	eb 05                	jmp    c0104072 <perm2str+0x19>
c010406d:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0104072:	a2 08 af 11 c0       	mov    %al,0xc011af08
    str[1] = 'r';
c0104077:	c6 05 09 af 11 c0 72 	movb   $0x72,0xc011af09
    str[2] = (perm & PTE_W) ? 'w' : '-';
c010407e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104081:	83 e0 02             	and    $0x2,%eax
c0104084:	85 c0                	test   %eax,%eax
c0104086:	74 07                	je     c010408f <perm2str+0x36>
c0104088:	b8 77 00 00 00       	mov    $0x77,%eax
c010408d:	eb 05                	jmp    c0104094 <perm2str+0x3b>
c010408f:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0104094:	a2 0a af 11 c0       	mov    %al,0xc011af0a
    str[3] = '\0';
c0104099:	c6 05 0b af 11 c0 00 	movb   $0x0,0xc011af0b
    return str;
c01040a0:	b8 08 af 11 c0       	mov    $0xc011af08,%eax
}
c01040a5:	5d                   	pop    %ebp
c01040a6:	c3                   	ret    

c01040a7 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c01040a7:	55                   	push   %ebp
c01040a8:	89 e5                	mov    %esp,%ebp
c01040aa:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c01040ad:	8b 45 10             	mov    0x10(%ebp),%eax
c01040b0:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01040b3:	72 0a                	jb     c01040bf <get_pgtable_items+0x18>
        return 0;
c01040b5:	b8 00 00 00 00       	mov    $0x0,%eax
c01040ba:	e9 9c 00 00 00       	jmp    c010415b <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
c01040bf:	eb 04                	jmp    c01040c5 <get_pgtable_items+0x1e>
        start ++;
c01040c1:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
c01040c5:	8b 45 10             	mov    0x10(%ebp),%eax
c01040c8:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01040cb:	73 18                	jae    c01040e5 <get_pgtable_items+0x3e>
c01040cd:	8b 45 10             	mov    0x10(%ebp),%eax
c01040d0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01040d7:	8b 45 14             	mov    0x14(%ebp),%eax
c01040da:	01 d0                	add    %edx,%eax
c01040dc:	8b 00                	mov    (%eax),%eax
c01040de:	83 e0 01             	and    $0x1,%eax
c01040e1:	85 c0                	test   %eax,%eax
c01040e3:	74 dc                	je     c01040c1 <get_pgtable_items+0x1a>
    }
    if (start < right) {
c01040e5:	8b 45 10             	mov    0x10(%ebp),%eax
c01040e8:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01040eb:	73 69                	jae    c0104156 <get_pgtable_items+0xaf>
        if (left_store != NULL) {
c01040ed:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c01040f1:	74 08                	je     c01040fb <get_pgtable_items+0x54>
            *left_store = start;
c01040f3:	8b 45 18             	mov    0x18(%ebp),%eax
c01040f6:	8b 55 10             	mov    0x10(%ebp),%edx
c01040f9:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c01040fb:	8b 45 10             	mov    0x10(%ebp),%eax
c01040fe:	8d 50 01             	lea    0x1(%eax),%edx
c0104101:	89 55 10             	mov    %edx,0x10(%ebp)
c0104104:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010410b:	8b 45 14             	mov    0x14(%ebp),%eax
c010410e:	01 d0                	add    %edx,%eax
c0104110:	8b 00                	mov    (%eax),%eax
c0104112:	83 e0 07             	and    $0x7,%eax
c0104115:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0104118:	eb 04                	jmp    c010411e <get_pgtable_items+0x77>
            start ++;
c010411a:	83 45 10 01          	addl   $0x1,0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c010411e:	8b 45 10             	mov    0x10(%ebp),%eax
c0104121:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104124:	73 1d                	jae    c0104143 <get_pgtable_items+0x9c>
c0104126:	8b 45 10             	mov    0x10(%ebp),%eax
c0104129:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0104130:	8b 45 14             	mov    0x14(%ebp),%eax
c0104133:	01 d0                	add    %edx,%eax
c0104135:	8b 00                	mov    (%eax),%eax
c0104137:	83 e0 07             	and    $0x7,%eax
c010413a:	89 c2                	mov    %eax,%edx
c010413c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010413f:	39 c2                	cmp    %eax,%edx
c0104141:	74 d7                	je     c010411a <get_pgtable_items+0x73>
        }
        if (right_store != NULL) {
c0104143:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0104147:	74 08                	je     c0104151 <get_pgtable_items+0xaa>
            *right_store = start;
c0104149:	8b 45 1c             	mov    0x1c(%ebp),%eax
c010414c:	8b 55 10             	mov    0x10(%ebp),%edx
c010414f:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0104151:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104154:	eb 05                	jmp    c010415b <get_pgtable_items+0xb4>
    }
    return 0;
c0104156:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010415b:	c9                   	leave  
c010415c:	c3                   	ret    

c010415d <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c010415d:	55                   	push   %ebp
c010415e:	89 e5                	mov    %esp,%ebp
c0104160:	57                   	push   %edi
c0104161:	56                   	push   %esi
c0104162:	53                   	push   %ebx
c0104163:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0104166:	c7 04 24 50 6c 10 c0 	movl   $0xc0106c50,(%esp)
c010416d:	e8 20 c1 ff ff       	call   c0100292 <cprintf>
    size_t left, right = 0, perm;
c0104172:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0104179:	e9 fa 00 00 00       	jmp    c0104278 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c010417e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104181:	89 04 24             	mov    %eax,(%esp)
c0104184:	e8 d0 fe ff ff       	call   c0104059 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0104189:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010418c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010418f:	29 d1                	sub    %edx,%ecx
c0104191:	89 ca                	mov    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0104193:	89 d6                	mov    %edx,%esi
c0104195:	c1 e6 16             	shl    $0x16,%esi
c0104198:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010419b:	89 d3                	mov    %edx,%ebx
c010419d:	c1 e3 16             	shl    $0x16,%ebx
c01041a0:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01041a3:	89 d1                	mov    %edx,%ecx
c01041a5:	c1 e1 16             	shl    $0x16,%ecx
c01041a8:	8b 7d dc             	mov    -0x24(%ebp),%edi
c01041ab:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01041ae:	29 d7                	sub    %edx,%edi
c01041b0:	89 fa                	mov    %edi,%edx
c01041b2:	89 44 24 14          	mov    %eax,0x14(%esp)
c01041b6:	89 74 24 10          	mov    %esi,0x10(%esp)
c01041ba:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01041be:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01041c2:	89 54 24 04          	mov    %edx,0x4(%esp)
c01041c6:	c7 04 24 81 6c 10 c0 	movl   $0xc0106c81,(%esp)
c01041cd:	e8 c0 c0 ff ff       	call   c0100292 <cprintf>
        size_t l, r = left * NPTEENTRY;
c01041d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01041d5:	c1 e0 0a             	shl    $0xa,%eax
c01041d8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c01041db:	eb 54                	jmp    c0104231 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c01041dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01041e0:	89 04 24             	mov    %eax,(%esp)
c01041e3:	e8 71 fe ff ff       	call   c0104059 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c01041e8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c01041eb:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01041ee:	29 d1                	sub    %edx,%ecx
c01041f0:	89 ca                	mov    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c01041f2:	89 d6                	mov    %edx,%esi
c01041f4:	c1 e6 0c             	shl    $0xc,%esi
c01041f7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01041fa:	89 d3                	mov    %edx,%ebx
c01041fc:	c1 e3 0c             	shl    $0xc,%ebx
c01041ff:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104202:	c1 e2 0c             	shl    $0xc,%edx
c0104205:	89 d1                	mov    %edx,%ecx
c0104207:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c010420a:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010420d:	29 d7                	sub    %edx,%edi
c010420f:	89 fa                	mov    %edi,%edx
c0104211:	89 44 24 14          	mov    %eax,0x14(%esp)
c0104215:	89 74 24 10          	mov    %esi,0x10(%esp)
c0104219:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010421d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0104221:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104225:	c7 04 24 a0 6c 10 c0 	movl   $0xc0106ca0,(%esp)
c010422c:	e8 61 c0 ff ff       	call   c0100292 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0104231:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
c0104236:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104239:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010423c:	89 ce                	mov    %ecx,%esi
c010423e:	c1 e6 0a             	shl    $0xa,%esi
c0104241:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0104244:	89 cb                	mov    %ecx,%ebx
c0104246:	c1 e3 0a             	shl    $0xa,%ebx
c0104249:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
c010424c:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c0104250:	8d 4d d8             	lea    -0x28(%ebp),%ecx
c0104253:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0104257:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010425b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010425f:	89 74 24 04          	mov    %esi,0x4(%esp)
c0104263:	89 1c 24             	mov    %ebx,(%esp)
c0104266:	e8 3c fe ff ff       	call   c01040a7 <get_pgtable_items>
c010426b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010426e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104272:	0f 85 65 ff ff ff    	jne    c01041dd <print_pgdir+0x80>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0104278:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
c010427d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104280:	8d 4d dc             	lea    -0x24(%ebp),%ecx
c0104283:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c0104287:	8d 4d e0             	lea    -0x20(%ebp),%ecx
c010428a:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c010428e:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0104292:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104296:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c010429d:	00 
c010429e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01042a5:	e8 fd fd ff ff       	call   c01040a7 <get_pgtable_items>
c01042aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01042ad:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01042b1:	0f 85 c7 fe ff ff    	jne    c010417e <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
c01042b7:	c7 04 24 c4 6c 10 c0 	movl   $0xc0106cc4,(%esp)
c01042be:	e8 cf bf ff ff       	call   c0100292 <cprintf>
}
c01042c3:	83 c4 4c             	add    $0x4c,%esp
c01042c6:	5b                   	pop    %ebx
c01042c7:	5e                   	pop    %esi
c01042c8:	5f                   	pop    %edi
c01042c9:	5d                   	pop    %ebp
c01042ca:	c3                   	ret    

c01042cb <page2ppn>:
page2ppn(struct Page *page) {
c01042cb:	55                   	push   %ebp
c01042cc:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01042ce:	8b 55 08             	mov    0x8(%ebp),%edx
c01042d1:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c01042d6:	29 c2                	sub    %eax,%edx
c01042d8:	89 d0                	mov    %edx,%eax
c01042da:	c1 f8 02             	sar    $0x2,%eax
c01042dd:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c01042e3:	5d                   	pop    %ebp
c01042e4:	c3                   	ret    

c01042e5 <page2pa>:
page2pa(struct Page *page) {
c01042e5:	55                   	push   %ebp
c01042e6:	89 e5                	mov    %esp,%ebp
c01042e8:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01042eb:	8b 45 08             	mov    0x8(%ebp),%eax
c01042ee:	89 04 24             	mov    %eax,(%esp)
c01042f1:	e8 d5 ff ff ff       	call   c01042cb <page2ppn>
c01042f6:	c1 e0 0c             	shl    $0xc,%eax
}
c01042f9:	c9                   	leave  
c01042fa:	c3                   	ret    

c01042fb <page_ref>:
page_ref(struct Page *page) {
c01042fb:	55                   	push   %ebp
c01042fc:	89 e5                	mov    %esp,%ebp
    return page->ref;
c01042fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0104301:	8b 00                	mov    (%eax),%eax
}
c0104303:	5d                   	pop    %ebp
c0104304:	c3                   	ret    

c0104305 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c0104305:	55                   	push   %ebp
c0104306:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0104308:	8b 45 08             	mov    0x8(%ebp),%eax
c010430b:	8b 55 0c             	mov    0xc(%ebp),%edx
c010430e:	89 10                	mov    %edx,(%eax)
}
c0104310:	5d                   	pop    %ebp
c0104311:	c3                   	ret    

c0104312 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c0104312:	55                   	push   %ebp
c0104313:	89 e5                	mov    %esp,%ebp
c0104315:	83 ec 10             	sub    $0x10,%esp
c0104318:	c7 45 fc 1c af 11 c0 	movl   $0xc011af1c,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010431f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104322:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0104325:	89 50 04             	mov    %edx,0x4(%eax)
c0104328:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010432b:	8b 50 04             	mov    0x4(%eax),%edx
c010432e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104331:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c0104333:	c7 05 24 af 11 c0 00 	movl   $0x0,0xc011af24
c010433a:	00 00 00 
}
c010433d:	c9                   	leave  
c010433e:	c3                   	ret    

c010433f <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c010433f:	55                   	push   %ebp
c0104340:	89 e5                	mov    %esp,%ebp
c0104342:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c0104345:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0104349:	75 24                	jne    c010436f <default_init_memmap+0x30>
c010434b:	c7 44 24 0c f8 6c 10 	movl   $0xc0106cf8,0xc(%esp)
c0104352:	c0 
c0104353:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c010435a:	c0 
c010435b:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0104362:	00 
c0104363:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c010436a:	e8 7a c0 ff ff       	call   c01003e9 <__panic>
    struct Page *p = base;
c010436f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104372:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0104375:	e9 dc 00 00 00       	jmp    c0104456 <default_init_memmap+0x117>
        //初始化n块物理页
        assert(PageReserved(p));
c010437a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010437d:	83 c0 04             	add    $0x4,%eax
c0104380:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0104387:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010438a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010438d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104390:	0f a3 10             	bt     %edx,(%eax)
c0104393:	19 c0                	sbb    %eax,%eax
c0104395:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c0104398:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010439c:	0f 95 c0             	setne  %al
c010439f:	0f b6 c0             	movzbl %al,%eax
c01043a2:	85 c0                	test   %eax,%eax
c01043a4:	75 24                	jne    c01043ca <default_init_memmap+0x8b>
c01043a6:	c7 44 24 0c 29 6d 10 	movl   $0xc0106d29,0xc(%esp)
c01043ad:	c0 
c01043ae:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c01043b5:	c0 
c01043b6:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
c01043bd:	00 
c01043be:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c01043c5:	e8 1f c0 ff ff       	call   c01003e9 <__panic>
        p->flags = 0;
c01043ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01043cd:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        SetPageProperty(p);
c01043d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01043d7:	83 c0 04             	add    $0x4,%eax
c01043da:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c01043e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01043e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01043e7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01043ea:	0f ab 10             	bts    %edx,(%eax)
        p->property = 0;
c01043ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01043f0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        set_page_ref(p, 0);
c01043f7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01043fe:	00 
c01043ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104402:	89 04 24             	mov    %eax,(%esp)
c0104405:	e8 fb fe ff ff       	call   c0104305 <set_page_ref>
        list_add_before(&free_list, &(p->page_link));
c010440a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010440d:	83 c0 0c             	add    $0xc,%eax
c0104410:	c7 45 dc 1c af 11 c0 	movl   $0xc011af1c,-0x24(%ebp)
c0104417:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c010441a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010441d:	8b 00                	mov    (%eax),%eax
c010441f:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104422:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0104425:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104428:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010442b:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c010442e:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104431:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104434:	89 10                	mov    %edx,(%eax)
c0104436:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104439:	8b 10                	mov    (%eax),%edx
c010443b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010443e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0104441:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104444:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104447:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010444a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010444d:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104450:	89 10                	mov    %edx,(%eax)
    for (; p != base + n; p ++) {
c0104452:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0104456:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104459:	89 d0                	mov    %edx,%eax
c010445b:	c1 e0 02             	shl    $0x2,%eax
c010445e:	01 d0                	add    %edx,%eax
c0104460:	c1 e0 02             	shl    $0x2,%eax
c0104463:	89 c2                	mov    %eax,%edx
c0104465:	8b 45 08             	mov    0x8(%ebp),%eax
c0104468:	01 d0                	add    %edx,%eax
c010446a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010446d:	0f 85 07 ff ff ff    	jne    c010437a <default_init_memmap+0x3b>
    }
    nr_free += n;
c0104473:	8b 15 24 af 11 c0    	mov    0xc011af24,%edx
c0104479:	8b 45 0c             	mov    0xc(%ebp),%eax
c010447c:	01 d0                	add    %edx,%eax
c010447e:	a3 24 af 11 c0       	mov    %eax,0xc011af24
    base->property = n;
c0104483:	8b 45 08             	mov    0x8(%ebp),%eax
c0104486:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104489:	89 50 08             	mov    %edx,0x8(%eax)
}
c010448c:	c9                   	leave  
c010448d:	c3                   	ret    

c010448e <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c010448e:	55                   	push   %ebp
c010448f:	89 e5                	mov    %esp,%ebp
c0104491:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c0104494:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104498:	75 24                	jne    c01044be <default_alloc_pages+0x30>
c010449a:	c7 44 24 0c f8 6c 10 	movl   $0xc0106cf8,0xc(%esp)
c01044a1:	c0 
c01044a2:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c01044a9:	c0 
c01044aa:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
c01044b1:	00 
c01044b2:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c01044b9:	e8 2b bf ff ff       	call   c01003e9 <__panic>
    if (n > nr_free) {
c01044be:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c01044c3:	3b 45 08             	cmp    0x8(%ebp),%eax
c01044c6:	73 0a                	jae    c01044d2 <default_alloc_pages+0x44>
        return NULL;
c01044c8:	b8 00 00 00 00       	mov    $0x0,%eax
c01044cd:	e9 37 01 00 00       	jmp    c0104609 <default_alloc_pages+0x17b>
    }
    //如果所有空闲块的空闲页总数都没有n个,直接return null
    list_entry_t *le, *le_next;  //free_list指针和它的下一个
    le = &free_list;
c01044d2:	c7 45 f4 1c af 11 c0 	movl   $0xc011af1c,-0xc(%ebp)
    //从头开始遍历保存空闲物理内存块的链表(按照物理地址的从小到大顺序)
    while((le=list_next(le)) != &free_list) {
c01044d9:	e9 0a 01 00 00       	jmp    c01045e8 <default_alloc_pages+0x15a>
    //通过宏le2page(memlayout.h)得指向Page的指针p
      struct Page *p = le2page(le, page_link);
c01044de:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044e1:	83 e8 0c             	sub    $0xc,%eax
c01044e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(p->property >= n){
c01044e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01044ea:	8b 40 08             	mov    0x8(%eax),%eax
c01044ed:	3b 45 08             	cmp    0x8(%ebp),%eax
c01044f0:	0f 82 f2 00 00 00    	jb     c01045e8 <default_alloc_pages+0x15a>
        //p->property表示空闲块的大小，大于n则进下一步
        int i;
        //for初始化空闲块中每一个页
        for(i=0;i<n;i++){
c01044f6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c01044fd:	eb 7c                	jmp    c010457b <default_alloc_pages+0xed>
c01044ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104502:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
c0104505:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104508:	8b 40 04             	mov    0x4(%eax),%eax
          le_next = list_next(le);
c010450b:	89 45 e8             	mov    %eax,-0x18(%ebp)
          struct Page *p2 = le2page(le, page_link);
c010450e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104511:	83 e8 0c             	sub    $0xc,%eax
c0104514:	89 45 e4             	mov    %eax,-0x1c(%ebp)
          SetPageReserved(p2);//flags bit0 置1，表示已经被分配
c0104517:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010451a:	83 c0 04             	add    $0x4,%eax
c010451d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0104524:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0104527:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010452a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010452d:	0f ab 10             	bts    %edx,(%eax)
          ClearPageProperty(p2);//falgs bit1 置0，表示已被分配
c0104530:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104533:	83 c0 04             	add    $0x4,%eax
c0104536:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c010453d:	89 45 d0             	mov    %eax,-0x30(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104540:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104543:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104546:	0f b3 10             	btr    %edx,(%eax)
c0104549:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010454c:	89 45 cc             	mov    %eax,-0x34(%ebp)
    __list_del(listelm->prev, listelm->next);
c010454f:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104552:	8b 40 04             	mov    0x4(%eax),%eax
c0104555:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104558:	8b 12                	mov    (%edx),%edx
c010455a:	89 55 c8             	mov    %edx,-0x38(%ebp)
c010455d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0104560:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104563:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0104566:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0104569:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010456c:	8b 55 c8             	mov    -0x38(%ebp),%edx
c010456f:	89 10                	mov    %edx,(%eax)
          list_del(le);//取消和free_list的link
          le = le_next;//指针后移
c0104571:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104574:	89 45 f4             	mov    %eax,-0xc(%ebp)
        for(i=0;i<n;i++){
c0104577:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
c010457b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010457e:	3b 45 08             	cmp    0x8(%ebp),%eax
c0104581:	0f 82 78 ff ff ff    	jb     c01044ff <default_alloc_pages+0x71>
        }
        //如果选中的块大于n,需要修改剩下的块的head page的property
        if(p->property>n){
c0104587:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010458a:	8b 40 08             	mov    0x8(%eax),%eax
c010458d:	3b 45 08             	cmp    0x8(%ebp),%eax
c0104590:	76 12                	jbe    c01045a4 <default_alloc_pages+0x116>
          (le2page(le,page_link))->property = p->property - n;
c0104592:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104595:	8d 50 f4             	lea    -0xc(%eax),%edx
c0104598:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010459b:	8b 40 08             	mov    0x8(%eax),%eax
c010459e:	2b 45 08             	sub    0x8(%ebp),%eax
c01045a1:	89 42 08             	mov    %eax,0x8(%edx)
        }
        ClearPageProperty(p);
c01045a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01045a7:	83 c0 04             	add    $0x4,%eax
c01045aa:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c01045b1:	89 45 bc             	mov    %eax,-0x44(%ebp)
c01045b4:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01045b7:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01045ba:	0f b3 10             	btr    %edx,(%eax)
        SetPageReserved(p);
c01045bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01045c0:	83 c0 04             	add    $0x4,%eax
c01045c3:	c7 45 b8 00 00 00 00 	movl   $0x0,-0x48(%ebp)
c01045ca:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01045cd:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01045d0:	8b 55 b8             	mov    -0x48(%ebp),%edx
c01045d3:	0f ab 10             	bts    %edx,(%eax)
        nr_free -= n;
c01045d6:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c01045db:	2b 45 08             	sub    0x8(%ebp),%eax
c01045de:	a3 24 af 11 c0       	mov    %eax,0xc011af24
        return p;
c01045e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01045e6:	eb 21                	jmp    c0104609 <default_alloc_pages+0x17b>
c01045e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045eb:	89 45 b0             	mov    %eax,-0x50(%ebp)
    return listelm->next;
c01045ee:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01045f1:	8b 40 04             	mov    0x4(%eax),%eax
    while((le=list_next(le)) != &free_list) {
c01045f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01045f7:	81 7d f4 1c af 11 c0 	cmpl   $0xc011af1c,-0xc(%ebp)
c01045fe:	0f 85 da fe ff ff    	jne    c01044de <default_alloc_pages+0x50>
      }
    }
    return NULL;//防止出错
c0104604:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104609:	c9                   	leave  
c010460a:	c3                   	ret    

c010460b <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c010460b:	55                   	push   %ebp
c010460c:	89 e5                	mov    %esp,%ebp
c010460e:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c0104611:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0104615:	75 24                	jne    c010463b <default_free_pages+0x30>
c0104617:	c7 44 24 0c f8 6c 10 	movl   $0xc0106cf8,0xc(%esp)
c010461e:	c0 
c010461f:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c0104626:	c0 
c0104627:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
c010462e:	00 
c010462f:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c0104636:	e8 ae bd ff ff       	call   c01003e9 <__panic>
    //assert(PageReserved(base) && PageProperty(base));
    assert(PageReserved(base));
c010463b:	8b 45 08             	mov    0x8(%ebp),%eax
c010463e:	83 c0 04             	add    $0x4,%eax
c0104641:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0104648:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010464b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010464e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104651:	0f a3 10             	bt     %edx,(%eax)
c0104654:	19 c0                	sbb    %eax,%eax
c0104656:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c0104659:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010465d:	0f 95 c0             	setne  %al
c0104660:	0f b6 c0             	movzbl %al,%eax
c0104663:	85 c0                	test   %eax,%eax
c0104665:	75 24                	jne    c010468b <default_free_pages+0x80>
c0104667:	c7 44 24 0c 39 6d 10 	movl   $0xc0106d39,0xc(%esp)
c010466e:	c0 
c010466f:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c0104676:	c0 
c0104677:	c7 44 24 04 a6 00 00 	movl   $0xa6,0x4(%esp)
c010467e:	00 
c010467f:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c0104686:	e8 5e bd ff ff       	call   c01003e9 <__panic>
    //检查需要释放的页块是否已经被分配,只要看bit 0 reserve就好了
    list_entry_t *le = &free_list;
c010468b:	c7 45 f4 1c af 11 c0 	movl   $0xc011af1c,-0xc(%ebp)
    struct Page * p;
    while((le=list_next(le)) != &free_list) {
c0104692:	eb 13                	jmp    c01046a7 <default_free_pages+0x9c>
      p = le2page(le, page_link);
c0104694:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104697:	83 e8 0c             	sub    $0xc,%eax
c010469a:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(p>base){break;}
c010469d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01046a0:	3b 45 08             	cmp    0x8(%ebp),%eax
c01046a3:	76 02                	jbe    c01046a7 <default_free_pages+0x9c>
c01046a5:	eb 18                	jmp    c01046bf <default_free_pages+0xb4>
c01046a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01046ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01046b0:	8b 40 04             	mov    0x4(%eax),%eax
    while((le=list_next(le)) != &free_list) {
c01046b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01046b6:	81 7d f4 1c af 11 c0 	cmpl   $0xc011af1c,-0xc(%ebp)
c01046bd:	75 d5                	jne    c0104694 <default_free_pages+0x89>
    }
    //将每一空闲块的链表插入空闲链表中
    for(p=base;p<base+n;p++){
c01046bf:	8b 45 08             	mov    0x8(%ebp),%eax
c01046c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01046c5:	eb 4b                	jmp    c0104712 <default_free_pages+0x107>
      list_add_before(le, &(p->page_link));
c01046c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01046ca:	8d 50 0c             	lea    0xc(%eax),%edx
c01046cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046d0:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01046d3:	89 55 d8             	mov    %edx,-0x28(%ebp)
    __list_add(elm, listelm->prev, listelm);
c01046d6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01046d9:	8b 00                	mov    (%eax),%eax
c01046db:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01046de:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01046e1:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01046e4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01046e7:	89 45 cc             	mov    %eax,-0x34(%ebp)
    prev->next = next->prev = elm;
c01046ea:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01046ed:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01046f0:	89 10                	mov    %edx,(%eax)
c01046f2:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01046f5:	8b 10                	mov    (%eax),%edx
c01046f7:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01046fa:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01046fd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104700:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104703:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0104706:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104709:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010470c:	89 10                	mov    %edx,(%eax)
    for(p=base;p<base+n;p++){
c010470e:	83 45 f0 14          	addl   $0x14,-0x10(%ebp)
c0104712:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104715:	89 d0                	mov    %edx,%eax
c0104717:	c1 e0 02             	shl    $0x2,%eax
c010471a:	01 d0                	add    %edx,%eax
c010471c:	c1 e0 02             	shl    $0x2,%eax
c010471f:	89 c2                	mov    %eax,%edx
c0104721:	8b 45 08             	mov    0x8(%ebp),%eax
c0104724:	01 d0                	add    %edx,%eax
c0104726:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104729:	77 9c                	ja     c01046c7 <default_free_pages+0xbc>
    }
    //修改页的各个属性置0
    base->flags = 0;
c010472b:	8b 45 08             	mov    0x8(%ebp),%eax
c010472e:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    set_page_ref(base, 0);
c0104735:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010473c:	00 
c010473d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104740:	89 04 24             	mov    %eax,(%esp)
c0104743:	e8 bd fb ff ff       	call   c0104305 <set_page_ref>
    ClearPageProperty(base);
c0104748:	8b 45 08             	mov    0x8(%ebp),%eax
c010474b:	83 c0 04             	add    $0x4,%eax
c010474e:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c0104755:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104758:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010475b:	8b 55 c8             	mov    -0x38(%ebp),%edx
c010475e:	0f b3 10             	btr    %edx,(%eax)
    SetPageProperty(base);
c0104761:	8b 45 08             	mov    0x8(%ebp),%eax
c0104764:	83 c0 04             	add    $0x4,%eax
c0104767:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c010476e:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104771:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104774:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0104777:	0f ab 10             	bts    %edx,(%eax)
    base->property = n;//有n空闲页
c010477a:	8b 45 08             	mov    0x8(%ebp),%eax
c010477d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104780:	89 50 08             	mov    %edx,0x8(%eax)
    p = le2page(le,page_link) ;
c0104783:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104786:	83 e8 0c             	sub    $0xc,%eax
c0104789:	89 45 f0             	mov    %eax,-0x10(%ebp)
    //和高位方向的下一个内存块的地址连续，向高位合并
    if( base+n == p ){
c010478c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010478f:	89 d0                	mov    %edx,%eax
c0104791:	c1 e0 02             	shl    $0x2,%eax
c0104794:	01 d0                	add    %edx,%eax
c0104796:	c1 e0 02             	shl    $0x2,%eax
c0104799:	89 c2                	mov    %eax,%edx
c010479b:	8b 45 08             	mov    0x8(%ebp),%eax
c010479e:	01 d0                	add    %edx,%eax
c01047a0:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01047a3:	75 1e                	jne    c01047c3 <default_free_pages+0x1b8>
      base->property += p->property;
c01047a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01047a8:	8b 50 08             	mov    0x8(%eax),%edx
c01047ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047ae:	8b 40 08             	mov    0x8(%eax),%eax
c01047b1:	01 c2                	add    %eax,%edx
c01047b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01047b6:	89 50 08             	mov    %edx,0x8(%eax)
      p->property = 0;
c01047b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047bc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    }
    //如果是低位,向低地址合并
    //把le指针指向前一个内存块
    le = list_prev(&(base->page_link));  //previous
c01047c3:	8b 45 08             	mov    0x8(%ebp),%eax
c01047c6:	83 c0 0c             	add    $0xc,%eax
c01047c9:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return listelm->prev;
c01047cc:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01047cf:	8b 00                	mov    (%eax),%eax
c01047d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    p = le2page(le, page_link);
c01047d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047d7:	83 e8 0c             	sub    $0xc,%eax
c01047da:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(le!=&free_list && p==base-1){
c01047dd:	81 7d f4 1c af 11 c0 	cmpl   $0xc011af1c,-0xc(%ebp)
c01047e4:	74 57                	je     c010483d <default_free_pages+0x232>
c01047e6:	8b 45 08             	mov    0x8(%ebp),%eax
c01047e9:	83 e8 14             	sub    $0x14,%eax
c01047ec:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01047ef:	75 4c                	jne    c010483d <default_free_pages+0x232>
      while(le!=&free_list){
c01047f1:	eb 41                	jmp    c0104834 <default_free_pages+0x229>
        if(p->property){
c01047f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047f6:	8b 40 08             	mov    0x8(%eax),%eax
c01047f9:	85 c0                	test   %eax,%eax
c01047fb:	74 20                	je     c010481d <default_free_pages+0x212>
          p->property += base->property;
c01047fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104800:	8b 50 08             	mov    0x8(%eax),%edx
c0104803:	8b 45 08             	mov    0x8(%ebp),%eax
c0104806:	8b 40 08             	mov    0x8(%eax),%eax
c0104809:	01 c2                	add    %eax,%edx
c010480b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010480e:	89 50 08             	mov    %edx,0x8(%eax)
          base->property = 0;
c0104811:	8b 45 08             	mov    0x8(%ebp),%eax
c0104814:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
          break;
c010481b:	eb 20                	jmp    c010483d <default_free_pages+0x232>
c010481d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104820:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c0104823:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104826:	8b 00                	mov    (%eax),%eax
        }
        le = list_prev(le);
c0104828:	89 45 f4             	mov    %eax,-0xc(%ebp)
        p = le2page(le,page_link);
c010482b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010482e:	83 e8 0c             	sub    $0xc,%eax
c0104831:	89 45 f0             	mov    %eax,-0x10(%ebp)
      while(le!=&free_list){
c0104834:	81 7d f4 1c af 11 c0 	cmpl   $0xc011af1c,-0xc(%ebp)
c010483b:	75 b6                	jne    c01047f3 <default_free_pages+0x1e8>
      }
    }
   //更新总空闲页数
    nr_free += n;
c010483d:	8b 15 24 af 11 c0    	mov    0xc011af24,%edx
c0104843:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104846:	01 d0                	add    %edx,%eax
c0104848:	a3 24 af 11 c0       	mov    %eax,0xc011af24
    return ;
c010484d:	90                   	nop
}
c010484e:	c9                   	leave  
c010484f:	c3                   	ret    

c0104850 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0104850:	55                   	push   %ebp
c0104851:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0104853:	a1 24 af 11 c0       	mov    0xc011af24,%eax
}
c0104858:	5d                   	pop    %ebp
c0104859:	c3                   	ret    

c010485a <basic_check>:

static void
basic_check(void) {
c010485a:	55                   	push   %ebp
c010485b:	89 e5                	mov    %esp,%ebp
c010485d:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0104860:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104867:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010486a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010486d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104870:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0104873:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010487a:	e8 8a e3 ff ff       	call   c0102c09 <alloc_pages>
c010487f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104882:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104886:	75 24                	jne    c01048ac <basic_check+0x52>
c0104888:	c7 44 24 0c 4c 6d 10 	movl   $0xc0106d4c,0xc(%esp)
c010488f:	c0 
c0104890:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c0104897:	c0 
c0104898:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c010489f:	00 
c01048a0:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c01048a7:	e8 3d bb ff ff       	call   c01003e9 <__panic>
    assert((p1 = alloc_page()) != NULL);
c01048ac:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01048b3:	e8 51 e3 ff ff       	call   c0102c09 <alloc_pages>
c01048b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01048bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01048bf:	75 24                	jne    c01048e5 <basic_check+0x8b>
c01048c1:	c7 44 24 0c 68 6d 10 	movl   $0xc0106d68,0xc(%esp)
c01048c8:	c0 
c01048c9:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c01048d0:	c0 
c01048d1:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c01048d8:	00 
c01048d9:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c01048e0:	e8 04 bb ff ff       	call   c01003e9 <__panic>
    assert((p2 = alloc_page()) != NULL);
c01048e5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01048ec:	e8 18 e3 ff ff       	call   c0102c09 <alloc_pages>
c01048f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01048f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01048f8:	75 24                	jne    c010491e <basic_check+0xc4>
c01048fa:	c7 44 24 0c 84 6d 10 	movl   $0xc0106d84,0xc(%esp)
c0104901:	c0 
c0104902:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c0104909:	c0 
c010490a:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
c0104911:	00 
c0104912:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c0104919:	e8 cb ba ff ff       	call   c01003e9 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c010491e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104921:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104924:	74 10                	je     c0104936 <basic_check+0xdc>
c0104926:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104929:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010492c:	74 08                	je     c0104936 <basic_check+0xdc>
c010492e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104931:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104934:	75 24                	jne    c010495a <basic_check+0x100>
c0104936:	c7 44 24 0c a0 6d 10 	movl   $0xc0106da0,0xc(%esp)
c010493d:	c0 
c010493e:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c0104945:	c0 
c0104946:	c7 44 24 04 df 00 00 	movl   $0xdf,0x4(%esp)
c010494d:	00 
c010494e:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c0104955:	e8 8f ba ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c010495a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010495d:	89 04 24             	mov    %eax,(%esp)
c0104960:	e8 96 f9 ff ff       	call   c01042fb <page_ref>
c0104965:	85 c0                	test   %eax,%eax
c0104967:	75 1e                	jne    c0104987 <basic_check+0x12d>
c0104969:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010496c:	89 04 24             	mov    %eax,(%esp)
c010496f:	e8 87 f9 ff ff       	call   c01042fb <page_ref>
c0104974:	85 c0                	test   %eax,%eax
c0104976:	75 0f                	jne    c0104987 <basic_check+0x12d>
c0104978:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010497b:	89 04 24             	mov    %eax,(%esp)
c010497e:	e8 78 f9 ff ff       	call   c01042fb <page_ref>
c0104983:	85 c0                	test   %eax,%eax
c0104985:	74 24                	je     c01049ab <basic_check+0x151>
c0104987:	c7 44 24 0c c4 6d 10 	movl   $0xc0106dc4,0xc(%esp)
c010498e:	c0 
c010498f:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c0104996:	c0 
c0104997:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
c010499e:	00 
c010499f:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c01049a6:	e8 3e ba ff ff       	call   c01003e9 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c01049ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01049ae:	89 04 24             	mov    %eax,(%esp)
c01049b1:	e8 2f f9 ff ff       	call   c01042e5 <page2pa>
c01049b6:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c01049bc:	c1 e2 0c             	shl    $0xc,%edx
c01049bf:	39 d0                	cmp    %edx,%eax
c01049c1:	72 24                	jb     c01049e7 <basic_check+0x18d>
c01049c3:	c7 44 24 0c 00 6e 10 	movl   $0xc0106e00,0xc(%esp)
c01049ca:	c0 
c01049cb:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c01049d2:	c0 
c01049d3:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
c01049da:	00 
c01049db:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c01049e2:	e8 02 ba ff ff       	call   c01003e9 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c01049e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01049ea:	89 04 24             	mov    %eax,(%esp)
c01049ed:	e8 f3 f8 ff ff       	call   c01042e5 <page2pa>
c01049f2:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c01049f8:	c1 e2 0c             	shl    $0xc,%edx
c01049fb:	39 d0                	cmp    %edx,%eax
c01049fd:	72 24                	jb     c0104a23 <basic_check+0x1c9>
c01049ff:	c7 44 24 0c 1d 6e 10 	movl   $0xc0106e1d,0xc(%esp)
c0104a06:	c0 
c0104a07:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c0104a0e:	c0 
c0104a0f:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c0104a16:	00 
c0104a17:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c0104a1e:	e8 c6 b9 ff ff       	call   c01003e9 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0104a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a26:	89 04 24             	mov    %eax,(%esp)
c0104a29:	e8 b7 f8 ff ff       	call   c01042e5 <page2pa>
c0104a2e:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c0104a34:	c1 e2 0c             	shl    $0xc,%edx
c0104a37:	39 d0                	cmp    %edx,%eax
c0104a39:	72 24                	jb     c0104a5f <basic_check+0x205>
c0104a3b:	c7 44 24 0c 3a 6e 10 	movl   $0xc0106e3a,0xc(%esp)
c0104a42:	c0 
c0104a43:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c0104a4a:	c0 
c0104a4b:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
c0104a52:	00 
c0104a53:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c0104a5a:	e8 8a b9 ff ff       	call   c01003e9 <__panic>

    list_entry_t free_list_store = free_list;
c0104a5f:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0104a64:	8b 15 20 af 11 c0    	mov    0xc011af20,%edx
c0104a6a:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104a6d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0104a70:	c7 45 e0 1c af 11 c0 	movl   $0xc011af1c,-0x20(%ebp)
    elm->prev = elm->next = elm;
c0104a77:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104a7a:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104a7d:	89 50 04             	mov    %edx,0x4(%eax)
c0104a80:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104a83:	8b 50 04             	mov    0x4(%eax),%edx
c0104a86:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104a89:	89 10                	mov    %edx,(%eax)
c0104a8b:	c7 45 dc 1c af 11 c0 	movl   $0xc011af1c,-0x24(%ebp)
    return list->next == list;
c0104a92:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104a95:	8b 40 04             	mov    0x4(%eax),%eax
c0104a98:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0104a9b:	0f 94 c0             	sete   %al
c0104a9e:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0104aa1:	85 c0                	test   %eax,%eax
c0104aa3:	75 24                	jne    c0104ac9 <basic_check+0x26f>
c0104aa5:	c7 44 24 0c 57 6e 10 	movl   $0xc0106e57,0xc(%esp)
c0104aac:	c0 
c0104aad:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c0104ab4:	c0 
c0104ab5:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
c0104abc:	00 
c0104abd:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c0104ac4:	e8 20 b9 ff ff       	call   c01003e9 <__panic>

    unsigned int nr_free_store = nr_free;
c0104ac9:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c0104ace:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0104ad1:	c7 05 24 af 11 c0 00 	movl   $0x0,0xc011af24
c0104ad8:	00 00 00 

    assert(alloc_page() == NULL);
c0104adb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104ae2:	e8 22 e1 ff ff       	call   c0102c09 <alloc_pages>
c0104ae7:	85 c0                	test   %eax,%eax
c0104ae9:	74 24                	je     c0104b0f <basic_check+0x2b5>
c0104aeb:	c7 44 24 0c 6e 6e 10 	movl   $0xc0106e6e,0xc(%esp)
c0104af2:	c0 
c0104af3:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c0104afa:	c0 
c0104afb:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
c0104b02:	00 
c0104b03:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c0104b0a:	e8 da b8 ff ff       	call   c01003e9 <__panic>

    free_page(p0);
c0104b0f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104b16:	00 
c0104b17:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104b1a:	89 04 24             	mov    %eax,(%esp)
c0104b1d:	e8 1f e1 ff ff       	call   c0102c41 <free_pages>
    free_page(p1);
c0104b22:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104b29:	00 
c0104b2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b2d:	89 04 24             	mov    %eax,(%esp)
c0104b30:	e8 0c e1 ff ff       	call   c0102c41 <free_pages>
    free_page(p2);
c0104b35:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104b3c:	00 
c0104b3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b40:	89 04 24             	mov    %eax,(%esp)
c0104b43:	e8 f9 e0 ff ff       	call   c0102c41 <free_pages>
    assert(nr_free == 3);
c0104b48:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c0104b4d:	83 f8 03             	cmp    $0x3,%eax
c0104b50:	74 24                	je     c0104b76 <basic_check+0x31c>
c0104b52:	c7 44 24 0c 83 6e 10 	movl   $0xc0106e83,0xc(%esp)
c0104b59:	c0 
c0104b5a:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c0104b61:	c0 
c0104b62:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
c0104b69:	00 
c0104b6a:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c0104b71:	e8 73 b8 ff ff       	call   c01003e9 <__panic>

    assert((p0 = alloc_page()) != NULL);
c0104b76:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104b7d:	e8 87 e0 ff ff       	call   c0102c09 <alloc_pages>
c0104b82:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104b85:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104b89:	75 24                	jne    c0104baf <basic_check+0x355>
c0104b8b:	c7 44 24 0c 4c 6d 10 	movl   $0xc0106d4c,0xc(%esp)
c0104b92:	c0 
c0104b93:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c0104b9a:	c0 
c0104b9b:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
c0104ba2:	00 
c0104ba3:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c0104baa:	e8 3a b8 ff ff       	call   c01003e9 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0104baf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104bb6:	e8 4e e0 ff ff       	call   c0102c09 <alloc_pages>
c0104bbb:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104bbe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104bc2:	75 24                	jne    c0104be8 <basic_check+0x38e>
c0104bc4:	c7 44 24 0c 68 6d 10 	movl   $0xc0106d68,0xc(%esp)
c0104bcb:	c0 
c0104bcc:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c0104bd3:	c0 
c0104bd4:	c7 44 24 04 f5 00 00 	movl   $0xf5,0x4(%esp)
c0104bdb:	00 
c0104bdc:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c0104be3:	e8 01 b8 ff ff       	call   c01003e9 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0104be8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104bef:	e8 15 e0 ff ff       	call   c0102c09 <alloc_pages>
c0104bf4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104bf7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104bfb:	75 24                	jne    c0104c21 <basic_check+0x3c7>
c0104bfd:	c7 44 24 0c 84 6d 10 	movl   $0xc0106d84,0xc(%esp)
c0104c04:	c0 
c0104c05:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c0104c0c:	c0 
c0104c0d:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
c0104c14:	00 
c0104c15:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c0104c1c:	e8 c8 b7 ff ff       	call   c01003e9 <__panic>

    assert(alloc_page() == NULL);
c0104c21:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104c28:	e8 dc df ff ff       	call   c0102c09 <alloc_pages>
c0104c2d:	85 c0                	test   %eax,%eax
c0104c2f:	74 24                	je     c0104c55 <basic_check+0x3fb>
c0104c31:	c7 44 24 0c 6e 6e 10 	movl   $0xc0106e6e,0xc(%esp)
c0104c38:	c0 
c0104c39:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c0104c40:	c0 
c0104c41:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c0104c48:	00 
c0104c49:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c0104c50:	e8 94 b7 ff ff       	call   c01003e9 <__panic>

    free_page(p0);
c0104c55:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104c5c:	00 
c0104c5d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c60:	89 04 24             	mov    %eax,(%esp)
c0104c63:	e8 d9 df ff ff       	call   c0102c41 <free_pages>
c0104c68:	c7 45 d8 1c af 11 c0 	movl   $0xc011af1c,-0x28(%ebp)
c0104c6f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104c72:	8b 40 04             	mov    0x4(%eax),%eax
c0104c75:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0104c78:	0f 94 c0             	sete   %al
c0104c7b:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0104c7e:	85 c0                	test   %eax,%eax
c0104c80:	74 24                	je     c0104ca6 <basic_check+0x44c>
c0104c82:	c7 44 24 0c 90 6e 10 	movl   $0xc0106e90,0xc(%esp)
c0104c89:	c0 
c0104c8a:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c0104c91:	c0 
c0104c92:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c0104c99:	00 
c0104c9a:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c0104ca1:	e8 43 b7 ff ff       	call   c01003e9 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0104ca6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104cad:	e8 57 df ff ff       	call   c0102c09 <alloc_pages>
c0104cb2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104cb5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104cb8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0104cbb:	74 24                	je     c0104ce1 <basic_check+0x487>
c0104cbd:	c7 44 24 0c a8 6e 10 	movl   $0xc0106ea8,0xc(%esp)
c0104cc4:	c0 
c0104cc5:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c0104ccc:	c0 
c0104ccd:	c7 44 24 04 fe 00 00 	movl   $0xfe,0x4(%esp)
c0104cd4:	00 
c0104cd5:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c0104cdc:	e8 08 b7 ff ff       	call   c01003e9 <__panic>
    assert(alloc_page() == NULL);
c0104ce1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104ce8:	e8 1c df ff ff       	call   c0102c09 <alloc_pages>
c0104ced:	85 c0                	test   %eax,%eax
c0104cef:	74 24                	je     c0104d15 <basic_check+0x4bb>
c0104cf1:	c7 44 24 0c 6e 6e 10 	movl   $0xc0106e6e,0xc(%esp)
c0104cf8:	c0 
c0104cf9:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c0104d00:	c0 
c0104d01:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
c0104d08:	00 
c0104d09:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c0104d10:	e8 d4 b6 ff ff       	call   c01003e9 <__panic>

    assert(nr_free == 0);
c0104d15:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c0104d1a:	85 c0                	test   %eax,%eax
c0104d1c:	74 24                	je     c0104d42 <basic_check+0x4e8>
c0104d1e:	c7 44 24 0c c1 6e 10 	movl   $0xc0106ec1,0xc(%esp)
c0104d25:	c0 
c0104d26:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c0104d2d:	c0 
c0104d2e:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c0104d35:	00 
c0104d36:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c0104d3d:	e8 a7 b6 ff ff       	call   c01003e9 <__panic>
    free_list = free_list_store;
c0104d42:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104d45:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104d48:	a3 1c af 11 c0       	mov    %eax,0xc011af1c
c0104d4d:	89 15 20 af 11 c0    	mov    %edx,0xc011af20
    nr_free = nr_free_store;
c0104d53:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104d56:	a3 24 af 11 c0       	mov    %eax,0xc011af24

    free_page(p);
c0104d5b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104d62:	00 
c0104d63:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104d66:	89 04 24             	mov    %eax,(%esp)
c0104d69:	e8 d3 de ff ff       	call   c0102c41 <free_pages>
    free_page(p1);
c0104d6e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104d75:	00 
c0104d76:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d79:	89 04 24             	mov    %eax,(%esp)
c0104d7c:	e8 c0 de ff ff       	call   c0102c41 <free_pages>
    free_page(p2);
c0104d81:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104d88:	00 
c0104d89:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d8c:	89 04 24             	mov    %eax,(%esp)
c0104d8f:	e8 ad de ff ff       	call   c0102c41 <free_pages>
}
c0104d94:	c9                   	leave  
c0104d95:	c3                   	ret    

c0104d96 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0104d96:	55                   	push   %ebp
c0104d97:	89 e5                	mov    %esp,%ebp
c0104d99:	53                   	push   %ebx
c0104d9a:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
c0104da0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104da7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0104dae:	c7 45 ec 1c af 11 c0 	movl   $0xc011af1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0104db5:	eb 6b                	jmp    c0104e22 <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
c0104db7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104dba:	83 e8 0c             	sub    $0xc,%eax
c0104dbd:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
c0104dc0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104dc3:	83 c0 04             	add    $0x4,%eax
c0104dc6:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0104dcd:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104dd0:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104dd3:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104dd6:	0f a3 10             	bt     %edx,(%eax)
c0104dd9:	19 c0                	sbb    %eax,%eax
c0104ddb:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0104dde:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0104de2:	0f 95 c0             	setne  %al
c0104de5:	0f b6 c0             	movzbl %al,%eax
c0104de8:	85 c0                	test   %eax,%eax
c0104dea:	75 24                	jne    c0104e10 <default_check+0x7a>
c0104dec:	c7 44 24 0c ce 6e 10 	movl   $0xc0106ece,0xc(%esp)
c0104df3:	c0 
c0104df4:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c0104dfb:	c0 
c0104dfc:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
c0104e03:	00 
c0104e04:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c0104e0b:	e8 d9 b5 ff ff       	call   c01003e9 <__panic>
        count ++, total += p->property;
c0104e10:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0104e14:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104e17:	8b 50 08             	mov    0x8(%eax),%edx
c0104e1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e1d:	01 d0                	add    %edx,%eax
c0104e1f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104e22:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e25:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c0104e28:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104e2b:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0104e2e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104e31:	81 7d ec 1c af 11 c0 	cmpl   $0xc011af1c,-0x14(%ebp)
c0104e38:	0f 85 79 ff ff ff    	jne    c0104db7 <default_check+0x21>
    }
    assert(total == nr_free_pages());
c0104e3e:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c0104e41:	e8 2d de ff ff       	call   c0102c73 <nr_free_pages>
c0104e46:	39 c3                	cmp    %eax,%ebx
c0104e48:	74 24                	je     c0104e6e <default_check+0xd8>
c0104e4a:	c7 44 24 0c de 6e 10 	movl   $0xc0106ede,0xc(%esp)
c0104e51:	c0 
c0104e52:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c0104e59:	c0 
c0104e5a:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c0104e61:	00 
c0104e62:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c0104e69:	e8 7b b5 ff ff       	call   c01003e9 <__panic>

    basic_check();
c0104e6e:	e8 e7 f9 ff ff       	call   c010485a <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0104e73:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0104e7a:	e8 8a dd ff ff       	call   c0102c09 <alloc_pages>
c0104e7f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
c0104e82:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104e86:	75 24                	jne    c0104eac <default_check+0x116>
c0104e88:	c7 44 24 0c f7 6e 10 	movl   $0xc0106ef7,0xc(%esp)
c0104e8f:	c0 
c0104e90:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c0104e97:	c0 
c0104e98:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c0104e9f:	00 
c0104ea0:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c0104ea7:	e8 3d b5 ff ff       	call   c01003e9 <__panic>
    assert(!PageProperty(p0));
c0104eac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104eaf:	83 c0 04             	add    $0x4,%eax
c0104eb2:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0104eb9:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104ebc:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104ebf:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0104ec2:	0f a3 10             	bt     %edx,(%eax)
c0104ec5:	19 c0                	sbb    %eax,%eax
c0104ec7:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0104eca:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0104ece:	0f 95 c0             	setne  %al
c0104ed1:	0f b6 c0             	movzbl %al,%eax
c0104ed4:	85 c0                	test   %eax,%eax
c0104ed6:	74 24                	je     c0104efc <default_check+0x166>
c0104ed8:	c7 44 24 0c 02 6f 10 	movl   $0xc0106f02,0xc(%esp)
c0104edf:	c0 
c0104ee0:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c0104ee7:	c0 
c0104ee8:	c7 44 24 04 1b 01 00 	movl   $0x11b,0x4(%esp)
c0104eef:	00 
c0104ef0:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c0104ef7:	e8 ed b4 ff ff       	call   c01003e9 <__panic>

    list_entry_t free_list_store = free_list;
c0104efc:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0104f01:	8b 15 20 af 11 c0    	mov    0xc011af20,%edx
c0104f07:	89 45 80             	mov    %eax,-0x80(%ebp)
c0104f0a:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0104f0d:	c7 45 b4 1c af 11 c0 	movl   $0xc011af1c,-0x4c(%ebp)
    elm->prev = elm->next = elm;
c0104f14:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104f17:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0104f1a:	89 50 04             	mov    %edx,0x4(%eax)
c0104f1d:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104f20:	8b 50 04             	mov    0x4(%eax),%edx
c0104f23:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104f26:	89 10                	mov    %edx,(%eax)
c0104f28:	c7 45 b0 1c af 11 c0 	movl   $0xc011af1c,-0x50(%ebp)
    return list->next == list;
c0104f2f:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104f32:	8b 40 04             	mov    0x4(%eax),%eax
c0104f35:	39 45 b0             	cmp    %eax,-0x50(%ebp)
c0104f38:	0f 94 c0             	sete   %al
c0104f3b:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0104f3e:	85 c0                	test   %eax,%eax
c0104f40:	75 24                	jne    c0104f66 <default_check+0x1d0>
c0104f42:	c7 44 24 0c 57 6e 10 	movl   $0xc0106e57,0xc(%esp)
c0104f49:	c0 
c0104f4a:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c0104f51:	c0 
c0104f52:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
c0104f59:	00 
c0104f5a:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c0104f61:	e8 83 b4 ff ff       	call   c01003e9 <__panic>
    assert(alloc_page() == NULL);
c0104f66:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104f6d:	e8 97 dc ff ff       	call   c0102c09 <alloc_pages>
c0104f72:	85 c0                	test   %eax,%eax
c0104f74:	74 24                	je     c0104f9a <default_check+0x204>
c0104f76:	c7 44 24 0c 6e 6e 10 	movl   $0xc0106e6e,0xc(%esp)
c0104f7d:	c0 
c0104f7e:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c0104f85:	c0 
c0104f86:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
c0104f8d:	00 
c0104f8e:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c0104f95:	e8 4f b4 ff ff       	call   c01003e9 <__panic>

    unsigned int nr_free_store = nr_free;
c0104f9a:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c0104f9f:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c0104fa2:	c7 05 24 af 11 c0 00 	movl   $0x0,0xc011af24
c0104fa9:	00 00 00 

    free_pages(p0 + 2, 3);
c0104fac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104faf:	83 c0 28             	add    $0x28,%eax
c0104fb2:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0104fb9:	00 
c0104fba:	89 04 24             	mov    %eax,(%esp)
c0104fbd:	e8 7f dc ff ff       	call   c0102c41 <free_pages>
    assert(alloc_pages(4) == NULL);
c0104fc2:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0104fc9:	e8 3b dc ff ff       	call   c0102c09 <alloc_pages>
c0104fce:	85 c0                	test   %eax,%eax
c0104fd0:	74 24                	je     c0104ff6 <default_check+0x260>
c0104fd2:	c7 44 24 0c 14 6f 10 	movl   $0xc0106f14,0xc(%esp)
c0104fd9:	c0 
c0104fda:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c0104fe1:	c0 
c0104fe2:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
c0104fe9:	00 
c0104fea:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c0104ff1:	e8 f3 b3 ff ff       	call   c01003e9 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0104ff6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104ff9:	83 c0 28             	add    $0x28,%eax
c0104ffc:	83 c0 04             	add    $0x4,%eax
c0104fff:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c0105006:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105009:	8b 45 a8             	mov    -0x58(%ebp),%eax
c010500c:	8b 55 ac             	mov    -0x54(%ebp),%edx
c010500f:	0f a3 10             	bt     %edx,(%eax)
c0105012:	19 c0                	sbb    %eax,%eax
c0105014:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c0105017:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c010501b:	0f 95 c0             	setne  %al
c010501e:	0f b6 c0             	movzbl %al,%eax
c0105021:	85 c0                	test   %eax,%eax
c0105023:	74 0e                	je     c0105033 <default_check+0x29d>
c0105025:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105028:	83 c0 28             	add    $0x28,%eax
c010502b:	8b 40 08             	mov    0x8(%eax),%eax
c010502e:	83 f8 03             	cmp    $0x3,%eax
c0105031:	74 24                	je     c0105057 <default_check+0x2c1>
c0105033:	c7 44 24 0c 2c 6f 10 	movl   $0xc0106f2c,0xc(%esp)
c010503a:	c0 
c010503b:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c0105042:	c0 
c0105043:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
c010504a:	00 
c010504b:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c0105052:	e8 92 b3 ff ff       	call   c01003e9 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0105057:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c010505e:	e8 a6 db ff ff       	call   c0102c09 <alloc_pages>
c0105063:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105066:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010506a:	75 24                	jne    c0105090 <default_check+0x2fa>
c010506c:	c7 44 24 0c 58 6f 10 	movl   $0xc0106f58,0xc(%esp)
c0105073:	c0 
c0105074:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c010507b:	c0 
c010507c:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
c0105083:	00 
c0105084:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c010508b:	e8 59 b3 ff ff       	call   c01003e9 <__panic>
    assert(alloc_page() == NULL);
c0105090:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105097:	e8 6d db ff ff       	call   c0102c09 <alloc_pages>
c010509c:	85 c0                	test   %eax,%eax
c010509e:	74 24                	je     c01050c4 <default_check+0x32e>
c01050a0:	c7 44 24 0c 6e 6e 10 	movl   $0xc0106e6e,0xc(%esp)
c01050a7:	c0 
c01050a8:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c01050af:	c0 
c01050b0:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
c01050b7:	00 
c01050b8:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c01050bf:	e8 25 b3 ff ff       	call   c01003e9 <__panic>
    assert(p0 + 2 == p1);
c01050c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01050c7:	83 c0 28             	add    $0x28,%eax
c01050ca:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c01050cd:	74 24                	je     c01050f3 <default_check+0x35d>
c01050cf:	c7 44 24 0c 76 6f 10 	movl   $0xc0106f76,0xc(%esp)
c01050d6:	c0 
c01050d7:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c01050de:	c0 
c01050df:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
c01050e6:	00 
c01050e7:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c01050ee:	e8 f6 b2 ff ff       	call   c01003e9 <__panic>

    p2 = p0 + 1;
c01050f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01050f6:	83 c0 14             	add    $0x14,%eax
c01050f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
c01050fc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105103:	00 
c0105104:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105107:	89 04 24             	mov    %eax,(%esp)
c010510a:	e8 32 db ff ff       	call   c0102c41 <free_pages>
    free_pages(p1, 3);
c010510f:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0105116:	00 
c0105117:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010511a:	89 04 24             	mov    %eax,(%esp)
c010511d:	e8 1f db ff ff       	call   c0102c41 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c0105122:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105125:	83 c0 04             	add    $0x4,%eax
c0105128:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c010512f:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105132:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0105135:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0105138:	0f a3 10             	bt     %edx,(%eax)
c010513b:	19 c0                	sbb    %eax,%eax
c010513d:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0105140:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0105144:	0f 95 c0             	setne  %al
c0105147:	0f b6 c0             	movzbl %al,%eax
c010514a:	85 c0                	test   %eax,%eax
c010514c:	74 0b                	je     c0105159 <default_check+0x3c3>
c010514e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105151:	8b 40 08             	mov    0x8(%eax),%eax
c0105154:	83 f8 01             	cmp    $0x1,%eax
c0105157:	74 24                	je     c010517d <default_check+0x3e7>
c0105159:	c7 44 24 0c 84 6f 10 	movl   $0xc0106f84,0xc(%esp)
c0105160:	c0 
c0105161:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c0105168:	c0 
c0105169:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
c0105170:	00 
c0105171:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c0105178:	e8 6c b2 ff ff       	call   c01003e9 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c010517d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105180:	83 c0 04             	add    $0x4,%eax
c0105183:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c010518a:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010518d:	8b 45 90             	mov    -0x70(%ebp),%eax
c0105190:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0105193:	0f a3 10             	bt     %edx,(%eax)
c0105196:	19 c0                	sbb    %eax,%eax
c0105198:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c010519b:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c010519f:	0f 95 c0             	setne  %al
c01051a2:	0f b6 c0             	movzbl %al,%eax
c01051a5:	85 c0                	test   %eax,%eax
c01051a7:	74 0b                	je     c01051b4 <default_check+0x41e>
c01051a9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01051ac:	8b 40 08             	mov    0x8(%eax),%eax
c01051af:	83 f8 03             	cmp    $0x3,%eax
c01051b2:	74 24                	je     c01051d8 <default_check+0x442>
c01051b4:	c7 44 24 0c ac 6f 10 	movl   $0xc0106fac,0xc(%esp)
c01051bb:	c0 
c01051bc:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c01051c3:	c0 
c01051c4:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
c01051cb:	00 
c01051cc:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c01051d3:	e8 11 b2 ff ff       	call   c01003e9 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c01051d8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01051df:	e8 25 da ff ff       	call   c0102c09 <alloc_pages>
c01051e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01051e7:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01051ea:	83 e8 14             	sub    $0x14,%eax
c01051ed:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c01051f0:	74 24                	je     c0105216 <default_check+0x480>
c01051f2:	c7 44 24 0c d2 6f 10 	movl   $0xc0106fd2,0xc(%esp)
c01051f9:	c0 
c01051fa:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c0105201:	c0 
c0105202:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
c0105209:	00 
c010520a:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c0105211:	e8 d3 b1 ff ff       	call   c01003e9 <__panic>
    free_page(p0);
c0105216:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010521d:	00 
c010521e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105221:	89 04 24             	mov    %eax,(%esp)
c0105224:	e8 18 da ff ff       	call   c0102c41 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c0105229:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0105230:	e8 d4 d9 ff ff       	call   c0102c09 <alloc_pages>
c0105235:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105238:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010523b:	83 c0 14             	add    $0x14,%eax
c010523e:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0105241:	74 24                	je     c0105267 <default_check+0x4d1>
c0105243:	c7 44 24 0c f0 6f 10 	movl   $0xc0106ff0,0xc(%esp)
c010524a:	c0 
c010524b:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c0105252:	c0 
c0105253:	c7 44 24 04 34 01 00 	movl   $0x134,0x4(%esp)
c010525a:	00 
c010525b:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c0105262:	e8 82 b1 ff ff       	call   c01003e9 <__panic>

    free_pages(p0, 2);
c0105267:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c010526e:	00 
c010526f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105272:	89 04 24             	mov    %eax,(%esp)
c0105275:	e8 c7 d9 ff ff       	call   c0102c41 <free_pages>
    free_page(p2);
c010527a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105281:	00 
c0105282:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105285:	89 04 24             	mov    %eax,(%esp)
c0105288:	e8 b4 d9 ff ff       	call   c0102c41 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c010528d:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0105294:	e8 70 d9 ff ff       	call   c0102c09 <alloc_pages>
c0105299:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010529c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01052a0:	75 24                	jne    c01052c6 <default_check+0x530>
c01052a2:	c7 44 24 0c 10 70 10 	movl   $0xc0107010,0xc(%esp)
c01052a9:	c0 
c01052aa:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c01052b1:	c0 
c01052b2:	c7 44 24 04 39 01 00 	movl   $0x139,0x4(%esp)
c01052b9:	00 
c01052ba:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c01052c1:	e8 23 b1 ff ff       	call   c01003e9 <__panic>
    assert(alloc_page() == NULL);
c01052c6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01052cd:	e8 37 d9 ff ff       	call   c0102c09 <alloc_pages>
c01052d2:	85 c0                	test   %eax,%eax
c01052d4:	74 24                	je     c01052fa <default_check+0x564>
c01052d6:	c7 44 24 0c 6e 6e 10 	movl   $0xc0106e6e,0xc(%esp)
c01052dd:	c0 
c01052de:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c01052e5:	c0 
c01052e6:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
c01052ed:	00 
c01052ee:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c01052f5:	e8 ef b0 ff ff       	call   c01003e9 <__panic>

    assert(nr_free == 0);
c01052fa:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c01052ff:	85 c0                	test   %eax,%eax
c0105301:	74 24                	je     c0105327 <default_check+0x591>
c0105303:	c7 44 24 0c c1 6e 10 	movl   $0xc0106ec1,0xc(%esp)
c010530a:	c0 
c010530b:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c0105312:	c0 
c0105313:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
c010531a:	00 
c010531b:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c0105322:	e8 c2 b0 ff ff       	call   c01003e9 <__panic>
    nr_free = nr_free_store;
c0105327:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010532a:	a3 24 af 11 c0       	mov    %eax,0xc011af24

    free_list = free_list_store;
c010532f:	8b 45 80             	mov    -0x80(%ebp),%eax
c0105332:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0105335:	a3 1c af 11 c0       	mov    %eax,0xc011af1c
c010533a:	89 15 20 af 11 c0    	mov    %edx,0xc011af20
    free_pages(p0, 5);
c0105340:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c0105347:	00 
c0105348:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010534b:	89 04 24             	mov    %eax,(%esp)
c010534e:	e8 ee d8 ff ff       	call   c0102c41 <free_pages>

    le = &free_list;
c0105353:	c7 45 ec 1c af 11 c0 	movl   $0xc011af1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c010535a:	eb 1d                	jmp    c0105379 <default_check+0x5e3>
        struct Page *p = le2page(le, page_link);
c010535c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010535f:	83 e8 0c             	sub    $0xc,%eax
c0105362:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
c0105365:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0105369:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010536c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010536f:	8b 40 08             	mov    0x8(%eax),%eax
c0105372:	29 c2                	sub    %eax,%edx
c0105374:	89 d0                	mov    %edx,%eax
c0105376:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105379:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010537c:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c010537f:	8b 45 88             	mov    -0x78(%ebp),%eax
c0105382:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0105385:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105388:	81 7d ec 1c af 11 c0 	cmpl   $0xc011af1c,-0x14(%ebp)
c010538f:	75 cb                	jne    c010535c <default_check+0x5c6>
    }
    assert(count == 0);
c0105391:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105395:	74 24                	je     c01053bb <default_check+0x625>
c0105397:	c7 44 24 0c 2e 70 10 	movl   $0xc010702e,0xc(%esp)
c010539e:	c0 
c010539f:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c01053a6:	c0 
c01053a7:	c7 44 24 04 47 01 00 	movl   $0x147,0x4(%esp)
c01053ae:	00 
c01053af:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c01053b6:	e8 2e b0 ff ff       	call   c01003e9 <__panic>
    assert(total == 0);
c01053bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01053bf:	74 24                	je     c01053e5 <default_check+0x64f>
c01053c1:	c7 44 24 0c 39 70 10 	movl   $0xc0107039,0xc(%esp)
c01053c8:	c0 
c01053c9:	c7 44 24 08 fe 6c 10 	movl   $0xc0106cfe,0x8(%esp)
c01053d0:	c0 
c01053d1:	c7 44 24 04 48 01 00 	movl   $0x148,0x4(%esp)
c01053d8:	00 
c01053d9:	c7 04 24 13 6d 10 c0 	movl   $0xc0106d13,(%esp)
c01053e0:	e8 04 b0 ff ff       	call   c01003e9 <__panic>
}
c01053e5:	81 c4 94 00 00 00    	add    $0x94,%esp
c01053eb:	5b                   	pop    %ebx
c01053ec:	5d                   	pop    %ebp
c01053ed:	c3                   	ret    

c01053ee <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c01053ee:	55                   	push   %ebp
c01053ef:	89 e5                	mov    %esp,%ebp
c01053f1:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c01053f4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c01053fb:	eb 04                	jmp    c0105401 <strlen+0x13>
        cnt ++;
c01053fd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (*s ++ != '\0') {
c0105401:	8b 45 08             	mov    0x8(%ebp),%eax
c0105404:	8d 50 01             	lea    0x1(%eax),%edx
c0105407:	89 55 08             	mov    %edx,0x8(%ebp)
c010540a:	0f b6 00             	movzbl (%eax),%eax
c010540d:	84 c0                	test   %al,%al
c010540f:	75 ec                	jne    c01053fd <strlen+0xf>
    }
    return cnt;
c0105411:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105414:	c9                   	leave  
c0105415:	c3                   	ret    

c0105416 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0105416:	55                   	push   %ebp
c0105417:	89 e5                	mov    %esp,%ebp
c0105419:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010541c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0105423:	eb 04                	jmp    c0105429 <strnlen+0x13>
        cnt ++;
c0105425:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0105429:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010542c:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010542f:	73 10                	jae    c0105441 <strnlen+0x2b>
c0105431:	8b 45 08             	mov    0x8(%ebp),%eax
c0105434:	8d 50 01             	lea    0x1(%eax),%edx
c0105437:	89 55 08             	mov    %edx,0x8(%ebp)
c010543a:	0f b6 00             	movzbl (%eax),%eax
c010543d:	84 c0                	test   %al,%al
c010543f:	75 e4                	jne    c0105425 <strnlen+0xf>
    }
    return cnt;
c0105441:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105444:	c9                   	leave  
c0105445:	c3                   	ret    

c0105446 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0105446:	55                   	push   %ebp
c0105447:	89 e5                	mov    %esp,%ebp
c0105449:	57                   	push   %edi
c010544a:	56                   	push   %esi
c010544b:	83 ec 20             	sub    $0x20,%esp
c010544e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105451:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105454:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105457:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c010545a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010545d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105460:	89 d1                	mov    %edx,%ecx
c0105462:	89 c2                	mov    %eax,%edx
c0105464:	89 ce                	mov    %ecx,%esi
c0105466:	89 d7                	mov    %edx,%edi
c0105468:	ac                   	lods   %ds:(%esi),%al
c0105469:	aa                   	stos   %al,%es:(%edi)
c010546a:	84 c0                	test   %al,%al
c010546c:	75 fa                	jne    c0105468 <strcpy+0x22>
c010546e:	89 fa                	mov    %edi,%edx
c0105470:	89 f1                	mov    %esi,%ecx
c0105472:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0105475:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0105478:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c010547b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c010547e:	83 c4 20             	add    $0x20,%esp
c0105481:	5e                   	pop    %esi
c0105482:	5f                   	pop    %edi
c0105483:	5d                   	pop    %ebp
c0105484:	c3                   	ret    

c0105485 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0105485:	55                   	push   %ebp
c0105486:	89 e5                	mov    %esp,%ebp
c0105488:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c010548b:	8b 45 08             	mov    0x8(%ebp),%eax
c010548e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0105491:	eb 21                	jmp    c01054b4 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
c0105493:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105496:	0f b6 10             	movzbl (%eax),%edx
c0105499:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010549c:	88 10                	mov    %dl,(%eax)
c010549e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01054a1:	0f b6 00             	movzbl (%eax),%eax
c01054a4:	84 c0                	test   %al,%al
c01054a6:	74 04                	je     c01054ac <strncpy+0x27>
            src ++;
c01054a8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
c01054ac:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c01054b0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    while (len > 0) {
c01054b4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01054b8:	75 d9                	jne    c0105493 <strncpy+0xe>
    }
    return dst;
c01054ba:	8b 45 08             	mov    0x8(%ebp),%eax
}
c01054bd:	c9                   	leave  
c01054be:	c3                   	ret    

c01054bf <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c01054bf:	55                   	push   %ebp
c01054c0:	89 e5                	mov    %esp,%ebp
c01054c2:	57                   	push   %edi
c01054c3:	56                   	push   %esi
c01054c4:	83 ec 20             	sub    $0x20,%esp
c01054c7:	8b 45 08             	mov    0x8(%ebp),%eax
c01054ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01054cd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01054d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c01054d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01054d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01054d9:	89 d1                	mov    %edx,%ecx
c01054db:	89 c2                	mov    %eax,%edx
c01054dd:	89 ce                	mov    %ecx,%esi
c01054df:	89 d7                	mov    %edx,%edi
c01054e1:	ac                   	lods   %ds:(%esi),%al
c01054e2:	ae                   	scas   %es:(%edi),%al
c01054e3:	75 08                	jne    c01054ed <strcmp+0x2e>
c01054e5:	84 c0                	test   %al,%al
c01054e7:	75 f8                	jne    c01054e1 <strcmp+0x22>
c01054e9:	31 c0                	xor    %eax,%eax
c01054eb:	eb 04                	jmp    c01054f1 <strcmp+0x32>
c01054ed:	19 c0                	sbb    %eax,%eax
c01054ef:	0c 01                	or     $0x1,%al
c01054f1:	89 fa                	mov    %edi,%edx
c01054f3:	89 f1                	mov    %esi,%ecx
c01054f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01054f8:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c01054fb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c01054fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c0105501:	83 c4 20             	add    $0x20,%esp
c0105504:	5e                   	pop    %esi
c0105505:	5f                   	pop    %edi
c0105506:	5d                   	pop    %ebp
c0105507:	c3                   	ret    

c0105508 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c0105508:	55                   	push   %ebp
c0105509:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010550b:	eb 0c                	jmp    c0105519 <strncmp+0x11>
        n --, s1 ++, s2 ++;
c010550d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0105511:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105515:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0105519:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010551d:	74 1a                	je     c0105539 <strncmp+0x31>
c010551f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105522:	0f b6 00             	movzbl (%eax),%eax
c0105525:	84 c0                	test   %al,%al
c0105527:	74 10                	je     c0105539 <strncmp+0x31>
c0105529:	8b 45 08             	mov    0x8(%ebp),%eax
c010552c:	0f b6 10             	movzbl (%eax),%edx
c010552f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105532:	0f b6 00             	movzbl (%eax),%eax
c0105535:	38 c2                	cmp    %al,%dl
c0105537:	74 d4                	je     c010550d <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c0105539:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010553d:	74 18                	je     c0105557 <strncmp+0x4f>
c010553f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105542:	0f b6 00             	movzbl (%eax),%eax
c0105545:	0f b6 d0             	movzbl %al,%edx
c0105548:	8b 45 0c             	mov    0xc(%ebp),%eax
c010554b:	0f b6 00             	movzbl (%eax),%eax
c010554e:	0f b6 c0             	movzbl %al,%eax
c0105551:	29 c2                	sub    %eax,%edx
c0105553:	89 d0                	mov    %edx,%eax
c0105555:	eb 05                	jmp    c010555c <strncmp+0x54>
c0105557:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010555c:	5d                   	pop    %ebp
c010555d:	c3                   	ret    

c010555e <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c010555e:	55                   	push   %ebp
c010555f:	89 e5                	mov    %esp,%ebp
c0105561:	83 ec 04             	sub    $0x4,%esp
c0105564:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105567:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010556a:	eb 14                	jmp    c0105580 <strchr+0x22>
        if (*s == c) {
c010556c:	8b 45 08             	mov    0x8(%ebp),%eax
c010556f:	0f b6 00             	movzbl (%eax),%eax
c0105572:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0105575:	75 05                	jne    c010557c <strchr+0x1e>
            return (char *)s;
c0105577:	8b 45 08             	mov    0x8(%ebp),%eax
c010557a:	eb 13                	jmp    c010558f <strchr+0x31>
        }
        s ++;
c010557c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
c0105580:	8b 45 08             	mov    0x8(%ebp),%eax
c0105583:	0f b6 00             	movzbl (%eax),%eax
c0105586:	84 c0                	test   %al,%al
c0105588:	75 e2                	jne    c010556c <strchr+0xe>
    }
    return NULL;
c010558a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010558f:	c9                   	leave  
c0105590:	c3                   	ret    

c0105591 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0105591:	55                   	push   %ebp
c0105592:	89 e5                	mov    %esp,%ebp
c0105594:	83 ec 04             	sub    $0x4,%esp
c0105597:	8b 45 0c             	mov    0xc(%ebp),%eax
c010559a:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010559d:	eb 11                	jmp    c01055b0 <strfind+0x1f>
        if (*s == c) {
c010559f:	8b 45 08             	mov    0x8(%ebp),%eax
c01055a2:	0f b6 00             	movzbl (%eax),%eax
c01055a5:	3a 45 fc             	cmp    -0x4(%ebp),%al
c01055a8:	75 02                	jne    c01055ac <strfind+0x1b>
            break;
c01055aa:	eb 0e                	jmp    c01055ba <strfind+0x29>
        }
        s ++;
c01055ac:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
c01055b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01055b3:	0f b6 00             	movzbl (%eax),%eax
c01055b6:	84 c0                	test   %al,%al
c01055b8:	75 e5                	jne    c010559f <strfind+0xe>
    }
    return (char *)s;
c01055ba:	8b 45 08             	mov    0x8(%ebp),%eax
}
c01055bd:	c9                   	leave  
c01055be:	c3                   	ret    

c01055bf <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c01055bf:	55                   	push   %ebp
c01055c0:	89 e5                	mov    %esp,%ebp
c01055c2:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c01055c5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c01055cc:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c01055d3:	eb 04                	jmp    c01055d9 <strtol+0x1a>
        s ++;
c01055d5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c01055d9:	8b 45 08             	mov    0x8(%ebp),%eax
c01055dc:	0f b6 00             	movzbl (%eax),%eax
c01055df:	3c 20                	cmp    $0x20,%al
c01055e1:	74 f2                	je     c01055d5 <strtol+0x16>
c01055e3:	8b 45 08             	mov    0x8(%ebp),%eax
c01055e6:	0f b6 00             	movzbl (%eax),%eax
c01055e9:	3c 09                	cmp    $0x9,%al
c01055eb:	74 e8                	je     c01055d5 <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
c01055ed:	8b 45 08             	mov    0x8(%ebp),%eax
c01055f0:	0f b6 00             	movzbl (%eax),%eax
c01055f3:	3c 2b                	cmp    $0x2b,%al
c01055f5:	75 06                	jne    c01055fd <strtol+0x3e>
        s ++;
c01055f7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c01055fb:	eb 15                	jmp    c0105612 <strtol+0x53>
    }
    else if (*s == '-') {
c01055fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0105600:	0f b6 00             	movzbl (%eax),%eax
c0105603:	3c 2d                	cmp    $0x2d,%al
c0105605:	75 0b                	jne    c0105612 <strtol+0x53>
        s ++, neg = 1;
c0105607:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010560b:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0105612:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105616:	74 06                	je     c010561e <strtol+0x5f>
c0105618:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c010561c:	75 24                	jne    c0105642 <strtol+0x83>
c010561e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105621:	0f b6 00             	movzbl (%eax),%eax
c0105624:	3c 30                	cmp    $0x30,%al
c0105626:	75 1a                	jne    c0105642 <strtol+0x83>
c0105628:	8b 45 08             	mov    0x8(%ebp),%eax
c010562b:	83 c0 01             	add    $0x1,%eax
c010562e:	0f b6 00             	movzbl (%eax),%eax
c0105631:	3c 78                	cmp    $0x78,%al
c0105633:	75 0d                	jne    c0105642 <strtol+0x83>
        s += 2, base = 16;
c0105635:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0105639:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0105640:	eb 2a                	jmp    c010566c <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
c0105642:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105646:	75 17                	jne    c010565f <strtol+0xa0>
c0105648:	8b 45 08             	mov    0x8(%ebp),%eax
c010564b:	0f b6 00             	movzbl (%eax),%eax
c010564e:	3c 30                	cmp    $0x30,%al
c0105650:	75 0d                	jne    c010565f <strtol+0xa0>
        s ++, base = 8;
c0105652:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105656:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c010565d:	eb 0d                	jmp    c010566c <strtol+0xad>
    }
    else if (base == 0) {
c010565f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105663:	75 07                	jne    c010566c <strtol+0xad>
        base = 10;
c0105665:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c010566c:	8b 45 08             	mov    0x8(%ebp),%eax
c010566f:	0f b6 00             	movzbl (%eax),%eax
c0105672:	3c 2f                	cmp    $0x2f,%al
c0105674:	7e 1b                	jle    c0105691 <strtol+0xd2>
c0105676:	8b 45 08             	mov    0x8(%ebp),%eax
c0105679:	0f b6 00             	movzbl (%eax),%eax
c010567c:	3c 39                	cmp    $0x39,%al
c010567e:	7f 11                	jg     c0105691 <strtol+0xd2>
            dig = *s - '0';
c0105680:	8b 45 08             	mov    0x8(%ebp),%eax
c0105683:	0f b6 00             	movzbl (%eax),%eax
c0105686:	0f be c0             	movsbl %al,%eax
c0105689:	83 e8 30             	sub    $0x30,%eax
c010568c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010568f:	eb 48                	jmp    c01056d9 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0105691:	8b 45 08             	mov    0x8(%ebp),%eax
c0105694:	0f b6 00             	movzbl (%eax),%eax
c0105697:	3c 60                	cmp    $0x60,%al
c0105699:	7e 1b                	jle    c01056b6 <strtol+0xf7>
c010569b:	8b 45 08             	mov    0x8(%ebp),%eax
c010569e:	0f b6 00             	movzbl (%eax),%eax
c01056a1:	3c 7a                	cmp    $0x7a,%al
c01056a3:	7f 11                	jg     c01056b6 <strtol+0xf7>
            dig = *s - 'a' + 10;
c01056a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01056a8:	0f b6 00             	movzbl (%eax),%eax
c01056ab:	0f be c0             	movsbl %al,%eax
c01056ae:	83 e8 57             	sub    $0x57,%eax
c01056b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01056b4:	eb 23                	jmp    c01056d9 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c01056b6:	8b 45 08             	mov    0x8(%ebp),%eax
c01056b9:	0f b6 00             	movzbl (%eax),%eax
c01056bc:	3c 40                	cmp    $0x40,%al
c01056be:	7e 3d                	jle    c01056fd <strtol+0x13e>
c01056c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01056c3:	0f b6 00             	movzbl (%eax),%eax
c01056c6:	3c 5a                	cmp    $0x5a,%al
c01056c8:	7f 33                	jg     c01056fd <strtol+0x13e>
            dig = *s - 'A' + 10;
c01056ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01056cd:	0f b6 00             	movzbl (%eax),%eax
c01056d0:	0f be c0             	movsbl %al,%eax
c01056d3:	83 e8 37             	sub    $0x37,%eax
c01056d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c01056d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01056dc:	3b 45 10             	cmp    0x10(%ebp),%eax
c01056df:	7c 02                	jl     c01056e3 <strtol+0x124>
            break;
c01056e1:	eb 1a                	jmp    c01056fd <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
c01056e3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c01056e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01056ea:	0f af 45 10          	imul   0x10(%ebp),%eax
c01056ee:	89 c2                	mov    %eax,%edx
c01056f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01056f3:	01 d0                	add    %edx,%eax
c01056f5:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c01056f8:	e9 6f ff ff ff       	jmp    c010566c <strtol+0xad>

    if (endptr) {
c01056fd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105701:	74 08                	je     c010570b <strtol+0x14c>
        *endptr = (char *) s;
c0105703:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105706:	8b 55 08             	mov    0x8(%ebp),%edx
c0105709:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c010570b:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010570f:	74 07                	je     c0105718 <strtol+0x159>
c0105711:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105714:	f7 d8                	neg    %eax
c0105716:	eb 03                	jmp    c010571b <strtol+0x15c>
c0105718:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c010571b:	c9                   	leave  
c010571c:	c3                   	ret    

c010571d <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c010571d:	55                   	push   %ebp
c010571e:	89 e5                	mov    %esp,%ebp
c0105720:	57                   	push   %edi
c0105721:	83 ec 24             	sub    $0x24,%esp
c0105724:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105727:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c010572a:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c010572e:	8b 55 08             	mov    0x8(%ebp),%edx
c0105731:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0105734:	88 45 f7             	mov    %al,-0x9(%ebp)
c0105737:	8b 45 10             	mov    0x10(%ebp),%eax
c010573a:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c010573d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0105740:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0105744:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0105747:	89 d7                	mov    %edx,%edi
c0105749:	f3 aa                	rep stos %al,%es:(%edi)
c010574b:	89 fa                	mov    %edi,%edx
c010574d:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0105750:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0105753:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0105756:	83 c4 24             	add    $0x24,%esp
c0105759:	5f                   	pop    %edi
c010575a:	5d                   	pop    %ebp
c010575b:	c3                   	ret    

c010575c <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c010575c:	55                   	push   %ebp
c010575d:	89 e5                	mov    %esp,%ebp
c010575f:	57                   	push   %edi
c0105760:	56                   	push   %esi
c0105761:	53                   	push   %ebx
c0105762:	83 ec 30             	sub    $0x30,%esp
c0105765:	8b 45 08             	mov    0x8(%ebp),%eax
c0105768:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010576b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010576e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105771:	8b 45 10             	mov    0x10(%ebp),%eax
c0105774:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0105777:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010577a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010577d:	73 42                	jae    c01057c1 <memmove+0x65>
c010577f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105782:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105785:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105788:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010578b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010578e:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0105791:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105794:	c1 e8 02             	shr    $0x2,%eax
c0105797:	89 c1                	mov    %eax,%ecx
    asm volatile (
c0105799:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010579c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010579f:	89 d7                	mov    %edx,%edi
c01057a1:	89 c6                	mov    %eax,%esi
c01057a3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c01057a5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c01057a8:	83 e1 03             	and    $0x3,%ecx
c01057ab:	74 02                	je     c01057af <memmove+0x53>
c01057ad:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c01057af:	89 f0                	mov    %esi,%eax
c01057b1:	89 fa                	mov    %edi,%edx
c01057b3:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c01057b6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01057b9:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c01057bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01057bf:	eb 36                	jmp    c01057f7 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c01057c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01057c4:	8d 50 ff             	lea    -0x1(%eax),%edx
c01057c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01057ca:	01 c2                	add    %eax,%edx
c01057cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01057cf:	8d 48 ff             	lea    -0x1(%eax),%ecx
c01057d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01057d5:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c01057d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01057db:	89 c1                	mov    %eax,%ecx
c01057dd:	89 d8                	mov    %ebx,%eax
c01057df:	89 d6                	mov    %edx,%esi
c01057e1:	89 c7                	mov    %eax,%edi
c01057e3:	fd                   	std    
c01057e4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c01057e6:	fc                   	cld    
c01057e7:	89 f8                	mov    %edi,%eax
c01057e9:	89 f2                	mov    %esi,%edx
c01057eb:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c01057ee:	89 55 c8             	mov    %edx,-0x38(%ebp)
c01057f1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c01057f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c01057f7:	83 c4 30             	add    $0x30,%esp
c01057fa:	5b                   	pop    %ebx
c01057fb:	5e                   	pop    %esi
c01057fc:	5f                   	pop    %edi
c01057fd:	5d                   	pop    %ebp
c01057fe:	c3                   	ret    

c01057ff <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c01057ff:	55                   	push   %ebp
c0105800:	89 e5                	mov    %esp,%ebp
c0105802:	57                   	push   %edi
c0105803:	56                   	push   %esi
c0105804:	83 ec 20             	sub    $0x20,%esp
c0105807:	8b 45 08             	mov    0x8(%ebp),%eax
c010580a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010580d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105810:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105813:	8b 45 10             	mov    0x10(%ebp),%eax
c0105816:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0105819:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010581c:	c1 e8 02             	shr    $0x2,%eax
c010581f:	89 c1                	mov    %eax,%ecx
    asm volatile (
c0105821:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105824:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105827:	89 d7                	mov    %edx,%edi
c0105829:	89 c6                	mov    %eax,%esi
c010582b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010582d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c0105830:	83 e1 03             	and    $0x3,%ecx
c0105833:	74 02                	je     c0105837 <memcpy+0x38>
c0105835:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105837:	89 f0                	mov    %esi,%eax
c0105839:	89 fa                	mov    %edi,%edx
c010583b:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010583e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0105841:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c0105844:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0105847:	83 c4 20             	add    $0x20,%esp
c010584a:	5e                   	pop    %esi
c010584b:	5f                   	pop    %edi
c010584c:	5d                   	pop    %ebp
c010584d:	c3                   	ret    

c010584e <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c010584e:	55                   	push   %ebp
c010584f:	89 e5                	mov    %esp,%ebp
c0105851:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0105854:	8b 45 08             	mov    0x8(%ebp),%eax
c0105857:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c010585a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010585d:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c0105860:	eb 30                	jmp    c0105892 <memcmp+0x44>
        if (*s1 != *s2) {
c0105862:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105865:	0f b6 10             	movzbl (%eax),%edx
c0105868:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010586b:	0f b6 00             	movzbl (%eax),%eax
c010586e:	38 c2                	cmp    %al,%dl
c0105870:	74 18                	je     c010588a <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0105872:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105875:	0f b6 00             	movzbl (%eax),%eax
c0105878:	0f b6 d0             	movzbl %al,%edx
c010587b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010587e:	0f b6 00             	movzbl (%eax),%eax
c0105881:	0f b6 c0             	movzbl %al,%eax
c0105884:	29 c2                	sub    %eax,%edx
c0105886:	89 d0                	mov    %edx,%eax
c0105888:	eb 1a                	jmp    c01058a4 <memcmp+0x56>
        }
        s1 ++, s2 ++;
c010588a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010588e:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
    while (n -- > 0) {
c0105892:	8b 45 10             	mov    0x10(%ebp),%eax
c0105895:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105898:	89 55 10             	mov    %edx,0x10(%ebp)
c010589b:	85 c0                	test   %eax,%eax
c010589d:	75 c3                	jne    c0105862 <memcmp+0x14>
    }
    return 0;
c010589f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01058a4:	c9                   	leave  
c01058a5:	c3                   	ret    

c01058a6 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c01058a6:	55                   	push   %ebp
c01058a7:	89 e5                	mov    %esp,%ebp
c01058a9:	83 ec 58             	sub    $0x58,%esp
c01058ac:	8b 45 10             	mov    0x10(%ebp),%eax
c01058af:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01058b2:	8b 45 14             	mov    0x14(%ebp),%eax
c01058b5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c01058b8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01058bb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01058be:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01058c1:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c01058c4:	8b 45 18             	mov    0x18(%ebp),%eax
c01058c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01058ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01058cd:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01058d0:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01058d3:	89 55 f0             	mov    %edx,-0x10(%ebp)
c01058d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01058d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01058dc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01058e0:	74 1c                	je     c01058fe <printnum+0x58>
c01058e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01058e5:	ba 00 00 00 00       	mov    $0x0,%edx
c01058ea:	f7 75 e4             	divl   -0x1c(%ebp)
c01058ed:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01058f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01058f3:	ba 00 00 00 00       	mov    $0x0,%edx
c01058f8:	f7 75 e4             	divl   -0x1c(%ebp)
c01058fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01058fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105901:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105904:	f7 75 e4             	divl   -0x1c(%ebp)
c0105907:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010590a:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010590d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105910:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105913:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105916:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0105919:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010591c:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c010591f:	8b 45 18             	mov    0x18(%ebp),%eax
c0105922:	ba 00 00 00 00       	mov    $0x0,%edx
c0105927:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010592a:	77 56                	ja     c0105982 <printnum+0xdc>
c010592c:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010592f:	72 05                	jb     c0105936 <printnum+0x90>
c0105931:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0105934:	77 4c                	ja     c0105982 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c0105936:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0105939:	8d 50 ff             	lea    -0x1(%eax),%edx
c010593c:	8b 45 20             	mov    0x20(%ebp),%eax
c010593f:	89 44 24 18          	mov    %eax,0x18(%esp)
c0105943:	89 54 24 14          	mov    %edx,0x14(%esp)
c0105947:	8b 45 18             	mov    0x18(%ebp),%eax
c010594a:	89 44 24 10          	mov    %eax,0x10(%esp)
c010594e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105951:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105954:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105958:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010595c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010595f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105963:	8b 45 08             	mov    0x8(%ebp),%eax
c0105966:	89 04 24             	mov    %eax,(%esp)
c0105969:	e8 38 ff ff ff       	call   c01058a6 <printnum>
c010596e:	eb 1c                	jmp    c010598c <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c0105970:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105973:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105977:	8b 45 20             	mov    0x20(%ebp),%eax
c010597a:	89 04 24             	mov    %eax,(%esp)
c010597d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105980:	ff d0                	call   *%eax
        while (-- width > 0)
c0105982:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
c0105986:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c010598a:	7f e4                	jg     c0105970 <printnum+0xca>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c010598c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010598f:	05 f4 70 10 c0       	add    $0xc01070f4,%eax
c0105994:	0f b6 00             	movzbl (%eax),%eax
c0105997:	0f be c0             	movsbl %al,%eax
c010599a:	8b 55 0c             	mov    0xc(%ebp),%edx
c010599d:	89 54 24 04          	mov    %edx,0x4(%esp)
c01059a1:	89 04 24             	mov    %eax,(%esp)
c01059a4:	8b 45 08             	mov    0x8(%ebp),%eax
c01059a7:	ff d0                	call   *%eax
}
c01059a9:	c9                   	leave  
c01059aa:	c3                   	ret    

c01059ab <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c01059ab:	55                   	push   %ebp
c01059ac:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01059ae:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01059b2:	7e 14                	jle    c01059c8 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c01059b4:	8b 45 08             	mov    0x8(%ebp),%eax
c01059b7:	8b 00                	mov    (%eax),%eax
c01059b9:	8d 48 08             	lea    0x8(%eax),%ecx
c01059bc:	8b 55 08             	mov    0x8(%ebp),%edx
c01059bf:	89 0a                	mov    %ecx,(%edx)
c01059c1:	8b 50 04             	mov    0x4(%eax),%edx
c01059c4:	8b 00                	mov    (%eax),%eax
c01059c6:	eb 30                	jmp    c01059f8 <getuint+0x4d>
    }
    else if (lflag) {
c01059c8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01059cc:	74 16                	je     c01059e4 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c01059ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01059d1:	8b 00                	mov    (%eax),%eax
c01059d3:	8d 48 04             	lea    0x4(%eax),%ecx
c01059d6:	8b 55 08             	mov    0x8(%ebp),%edx
c01059d9:	89 0a                	mov    %ecx,(%edx)
c01059db:	8b 00                	mov    (%eax),%eax
c01059dd:	ba 00 00 00 00       	mov    $0x0,%edx
c01059e2:	eb 14                	jmp    c01059f8 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c01059e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01059e7:	8b 00                	mov    (%eax),%eax
c01059e9:	8d 48 04             	lea    0x4(%eax),%ecx
c01059ec:	8b 55 08             	mov    0x8(%ebp),%edx
c01059ef:	89 0a                	mov    %ecx,(%edx)
c01059f1:	8b 00                	mov    (%eax),%eax
c01059f3:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c01059f8:	5d                   	pop    %ebp
c01059f9:	c3                   	ret    

c01059fa <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c01059fa:	55                   	push   %ebp
c01059fb:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01059fd:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0105a01:	7e 14                	jle    c0105a17 <getint+0x1d>
        return va_arg(*ap, long long);
c0105a03:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a06:	8b 00                	mov    (%eax),%eax
c0105a08:	8d 48 08             	lea    0x8(%eax),%ecx
c0105a0b:	8b 55 08             	mov    0x8(%ebp),%edx
c0105a0e:	89 0a                	mov    %ecx,(%edx)
c0105a10:	8b 50 04             	mov    0x4(%eax),%edx
c0105a13:	8b 00                	mov    (%eax),%eax
c0105a15:	eb 28                	jmp    c0105a3f <getint+0x45>
    }
    else if (lflag) {
c0105a17:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105a1b:	74 12                	je     c0105a2f <getint+0x35>
        return va_arg(*ap, long);
c0105a1d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a20:	8b 00                	mov    (%eax),%eax
c0105a22:	8d 48 04             	lea    0x4(%eax),%ecx
c0105a25:	8b 55 08             	mov    0x8(%ebp),%edx
c0105a28:	89 0a                	mov    %ecx,(%edx)
c0105a2a:	8b 00                	mov    (%eax),%eax
c0105a2c:	99                   	cltd   
c0105a2d:	eb 10                	jmp    c0105a3f <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c0105a2f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a32:	8b 00                	mov    (%eax),%eax
c0105a34:	8d 48 04             	lea    0x4(%eax),%ecx
c0105a37:	8b 55 08             	mov    0x8(%ebp),%edx
c0105a3a:	89 0a                	mov    %ecx,(%edx)
c0105a3c:	8b 00                	mov    (%eax),%eax
c0105a3e:	99                   	cltd   
    }
}
c0105a3f:	5d                   	pop    %ebp
c0105a40:	c3                   	ret    

c0105a41 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c0105a41:	55                   	push   %ebp
c0105a42:	89 e5                	mov    %esp,%ebp
c0105a44:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c0105a47:	8d 45 14             	lea    0x14(%ebp),%eax
c0105a4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c0105a4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a50:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105a54:	8b 45 10             	mov    0x10(%ebp),%eax
c0105a57:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105a5b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a5e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a62:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a65:	89 04 24             	mov    %eax,(%esp)
c0105a68:	e8 02 00 00 00       	call   c0105a6f <vprintfmt>
    va_end(ap);
}
c0105a6d:	c9                   	leave  
c0105a6e:	c3                   	ret    

c0105a6f <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c0105a6f:	55                   	push   %ebp
c0105a70:	89 e5                	mov    %esp,%ebp
c0105a72:	56                   	push   %esi
c0105a73:	53                   	push   %ebx
c0105a74:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105a77:	eb 18                	jmp    c0105a91 <vprintfmt+0x22>
            if (ch == '\0') {
c0105a79:	85 db                	test   %ebx,%ebx
c0105a7b:	75 05                	jne    c0105a82 <vprintfmt+0x13>
                return;
c0105a7d:	e9 d1 03 00 00       	jmp    c0105e53 <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
c0105a82:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a85:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a89:	89 1c 24             	mov    %ebx,(%esp)
c0105a8c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a8f:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105a91:	8b 45 10             	mov    0x10(%ebp),%eax
c0105a94:	8d 50 01             	lea    0x1(%eax),%edx
c0105a97:	89 55 10             	mov    %edx,0x10(%ebp)
c0105a9a:	0f b6 00             	movzbl (%eax),%eax
c0105a9d:	0f b6 d8             	movzbl %al,%ebx
c0105aa0:	83 fb 25             	cmp    $0x25,%ebx
c0105aa3:	75 d4                	jne    c0105a79 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
c0105aa5:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c0105aa9:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c0105ab0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105ab3:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c0105ab6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0105abd:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105ac0:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c0105ac3:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ac6:	8d 50 01             	lea    0x1(%eax),%edx
c0105ac9:	89 55 10             	mov    %edx,0x10(%ebp)
c0105acc:	0f b6 00             	movzbl (%eax),%eax
c0105acf:	0f b6 d8             	movzbl %al,%ebx
c0105ad2:	8d 43 dd             	lea    -0x23(%ebx),%eax
c0105ad5:	83 f8 55             	cmp    $0x55,%eax
c0105ad8:	0f 87 44 03 00 00    	ja     c0105e22 <vprintfmt+0x3b3>
c0105ade:	8b 04 85 18 71 10 c0 	mov    -0x3fef8ee8(,%eax,4),%eax
c0105ae5:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c0105ae7:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c0105aeb:	eb d6                	jmp    c0105ac3 <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c0105aed:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c0105af1:	eb d0                	jmp    c0105ac3 <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0105af3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c0105afa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105afd:	89 d0                	mov    %edx,%eax
c0105aff:	c1 e0 02             	shl    $0x2,%eax
c0105b02:	01 d0                	add    %edx,%eax
c0105b04:	01 c0                	add    %eax,%eax
c0105b06:	01 d8                	add    %ebx,%eax
c0105b08:	83 e8 30             	sub    $0x30,%eax
c0105b0b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c0105b0e:	8b 45 10             	mov    0x10(%ebp),%eax
c0105b11:	0f b6 00             	movzbl (%eax),%eax
c0105b14:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c0105b17:	83 fb 2f             	cmp    $0x2f,%ebx
c0105b1a:	7e 0b                	jle    c0105b27 <vprintfmt+0xb8>
c0105b1c:	83 fb 39             	cmp    $0x39,%ebx
c0105b1f:	7f 06                	jg     c0105b27 <vprintfmt+0xb8>
            for (precision = 0; ; ++ fmt) {
c0105b21:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                    break;
                }
            }
c0105b25:	eb d3                	jmp    c0105afa <vprintfmt+0x8b>
            goto process_precision;
c0105b27:	eb 33                	jmp    c0105b5c <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
c0105b29:	8b 45 14             	mov    0x14(%ebp),%eax
c0105b2c:	8d 50 04             	lea    0x4(%eax),%edx
c0105b2f:	89 55 14             	mov    %edx,0x14(%ebp)
c0105b32:	8b 00                	mov    (%eax),%eax
c0105b34:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c0105b37:	eb 23                	jmp    c0105b5c <vprintfmt+0xed>

        case '.':
            if (width < 0)
c0105b39:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105b3d:	79 0c                	jns    c0105b4b <vprintfmt+0xdc>
                width = 0;
c0105b3f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c0105b46:	e9 78 ff ff ff       	jmp    c0105ac3 <vprintfmt+0x54>
c0105b4b:	e9 73 ff ff ff       	jmp    c0105ac3 <vprintfmt+0x54>

        case '#':
            altflag = 1;
c0105b50:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c0105b57:	e9 67 ff ff ff       	jmp    c0105ac3 <vprintfmt+0x54>

        process_precision:
            if (width < 0)
c0105b5c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105b60:	79 12                	jns    c0105b74 <vprintfmt+0x105>
                width = precision, precision = -1;
c0105b62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105b65:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105b68:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c0105b6f:	e9 4f ff ff ff       	jmp    c0105ac3 <vprintfmt+0x54>
c0105b74:	e9 4a ff ff ff       	jmp    c0105ac3 <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c0105b79:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
c0105b7d:	e9 41 ff ff ff       	jmp    c0105ac3 <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c0105b82:	8b 45 14             	mov    0x14(%ebp),%eax
c0105b85:	8d 50 04             	lea    0x4(%eax),%edx
c0105b88:	89 55 14             	mov    %edx,0x14(%ebp)
c0105b8b:	8b 00                	mov    (%eax),%eax
c0105b8d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105b90:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105b94:	89 04 24             	mov    %eax,(%esp)
c0105b97:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b9a:	ff d0                	call   *%eax
            break;
c0105b9c:	e9 ac 02 00 00       	jmp    c0105e4d <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
c0105ba1:	8b 45 14             	mov    0x14(%ebp),%eax
c0105ba4:	8d 50 04             	lea    0x4(%eax),%edx
c0105ba7:	89 55 14             	mov    %edx,0x14(%ebp)
c0105baa:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c0105bac:	85 db                	test   %ebx,%ebx
c0105bae:	79 02                	jns    c0105bb2 <vprintfmt+0x143>
                err = -err;
c0105bb0:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c0105bb2:	83 fb 06             	cmp    $0x6,%ebx
c0105bb5:	7f 0b                	jg     c0105bc2 <vprintfmt+0x153>
c0105bb7:	8b 34 9d d8 70 10 c0 	mov    -0x3fef8f28(,%ebx,4),%esi
c0105bbe:	85 f6                	test   %esi,%esi
c0105bc0:	75 23                	jne    c0105be5 <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
c0105bc2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0105bc6:	c7 44 24 08 05 71 10 	movl   $0xc0107105,0x8(%esp)
c0105bcd:	c0 
c0105bce:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105bd1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105bd5:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bd8:	89 04 24             	mov    %eax,(%esp)
c0105bdb:	e8 61 fe ff ff       	call   c0105a41 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c0105be0:	e9 68 02 00 00       	jmp    c0105e4d <vprintfmt+0x3de>
                printfmt(putch, putdat, "%s", p);
c0105be5:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0105be9:	c7 44 24 08 0e 71 10 	movl   $0xc010710e,0x8(%esp)
c0105bf0:	c0 
c0105bf1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105bf4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105bf8:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bfb:	89 04 24             	mov    %eax,(%esp)
c0105bfe:	e8 3e fe ff ff       	call   c0105a41 <printfmt>
            break;
c0105c03:	e9 45 02 00 00       	jmp    c0105e4d <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c0105c08:	8b 45 14             	mov    0x14(%ebp),%eax
c0105c0b:	8d 50 04             	lea    0x4(%eax),%edx
c0105c0e:	89 55 14             	mov    %edx,0x14(%ebp)
c0105c11:	8b 30                	mov    (%eax),%esi
c0105c13:	85 f6                	test   %esi,%esi
c0105c15:	75 05                	jne    c0105c1c <vprintfmt+0x1ad>
                p = "(null)";
c0105c17:	be 11 71 10 c0       	mov    $0xc0107111,%esi
            }
            if (width > 0 && padc != '-') {
c0105c1c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105c20:	7e 3e                	jle    c0105c60 <vprintfmt+0x1f1>
c0105c22:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c0105c26:	74 38                	je     c0105c60 <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
c0105c28:	8b 5d e8             	mov    -0x18(%ebp),%ebx
c0105c2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105c2e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c32:	89 34 24             	mov    %esi,(%esp)
c0105c35:	e8 dc f7 ff ff       	call   c0105416 <strnlen>
c0105c3a:	29 c3                	sub    %eax,%ebx
c0105c3c:	89 d8                	mov    %ebx,%eax
c0105c3e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105c41:	eb 17                	jmp    c0105c5a <vprintfmt+0x1eb>
                    putch(padc, putdat);
c0105c43:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c0105c47:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105c4a:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105c4e:	89 04 24             	mov    %eax,(%esp)
c0105c51:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c54:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
c0105c56:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0105c5a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105c5e:	7f e3                	jg     c0105c43 <vprintfmt+0x1d4>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0105c60:	eb 38                	jmp    c0105c9a <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
c0105c62:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105c66:	74 1f                	je     c0105c87 <vprintfmt+0x218>
c0105c68:	83 fb 1f             	cmp    $0x1f,%ebx
c0105c6b:	7e 05                	jle    c0105c72 <vprintfmt+0x203>
c0105c6d:	83 fb 7e             	cmp    $0x7e,%ebx
c0105c70:	7e 15                	jle    c0105c87 <vprintfmt+0x218>
                    putch('?', putdat);
c0105c72:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c75:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c79:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c0105c80:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c83:	ff d0                	call   *%eax
c0105c85:	eb 0f                	jmp    c0105c96 <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
c0105c87:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c8a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c8e:	89 1c 24             	mov    %ebx,(%esp)
c0105c91:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c94:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0105c96:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0105c9a:	89 f0                	mov    %esi,%eax
c0105c9c:	8d 70 01             	lea    0x1(%eax),%esi
c0105c9f:	0f b6 00             	movzbl (%eax),%eax
c0105ca2:	0f be d8             	movsbl %al,%ebx
c0105ca5:	85 db                	test   %ebx,%ebx
c0105ca7:	74 10                	je     c0105cb9 <vprintfmt+0x24a>
c0105ca9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105cad:	78 b3                	js     c0105c62 <vprintfmt+0x1f3>
c0105caf:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
c0105cb3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105cb7:	79 a9                	jns    c0105c62 <vprintfmt+0x1f3>
                }
            }
            for (; width > 0; width --) {
c0105cb9:	eb 17                	jmp    c0105cd2 <vprintfmt+0x263>
                putch(' ', putdat);
c0105cbb:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105cbe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105cc2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0105cc9:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ccc:	ff d0                	call   *%eax
            for (; width > 0; width --) {
c0105cce:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0105cd2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105cd6:	7f e3                	jg     c0105cbb <vprintfmt+0x24c>
            }
            break;
c0105cd8:	e9 70 01 00 00       	jmp    c0105e4d <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0105cdd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105ce0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ce4:	8d 45 14             	lea    0x14(%ebp),%eax
c0105ce7:	89 04 24             	mov    %eax,(%esp)
c0105cea:	e8 0b fd ff ff       	call   c01059fa <getint>
c0105cef:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105cf2:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c0105cf5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105cf8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105cfb:	85 d2                	test   %edx,%edx
c0105cfd:	79 26                	jns    c0105d25 <vprintfmt+0x2b6>
                putch('-', putdat);
c0105cff:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d02:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d06:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c0105d0d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d10:	ff d0                	call   *%eax
                num = -(long long)num;
c0105d12:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d15:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105d18:	f7 d8                	neg    %eax
c0105d1a:	83 d2 00             	adc    $0x0,%edx
c0105d1d:	f7 da                	neg    %edx
c0105d1f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105d22:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c0105d25:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0105d2c:	e9 a8 00 00 00       	jmp    c0105dd9 <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c0105d31:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105d34:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d38:	8d 45 14             	lea    0x14(%ebp),%eax
c0105d3b:	89 04 24             	mov    %eax,(%esp)
c0105d3e:	e8 68 fc ff ff       	call   c01059ab <getuint>
c0105d43:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105d46:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c0105d49:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0105d50:	e9 84 00 00 00       	jmp    c0105dd9 <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0105d55:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105d58:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d5c:	8d 45 14             	lea    0x14(%ebp),%eax
c0105d5f:	89 04 24             	mov    %eax,(%esp)
c0105d62:	e8 44 fc ff ff       	call   c01059ab <getuint>
c0105d67:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105d6a:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0105d6d:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0105d74:	eb 63                	jmp    c0105dd9 <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
c0105d76:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d79:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d7d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0105d84:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d87:	ff d0                	call   *%eax
            putch('x', putdat);
c0105d89:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d8c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d90:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c0105d97:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d9a:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0105d9c:	8b 45 14             	mov    0x14(%ebp),%eax
c0105d9f:	8d 50 04             	lea    0x4(%eax),%edx
c0105da2:	89 55 14             	mov    %edx,0x14(%ebp)
c0105da5:	8b 00                	mov    (%eax),%eax
c0105da7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105daa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0105db1:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0105db8:	eb 1f                	jmp    c0105dd9 <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0105dba:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105dbd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105dc1:	8d 45 14             	lea    0x14(%ebp),%eax
c0105dc4:	89 04 24             	mov    %eax,(%esp)
c0105dc7:	e8 df fb ff ff       	call   c01059ab <getuint>
c0105dcc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105dcf:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0105dd2:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0105dd9:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0105ddd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105de0:	89 54 24 18          	mov    %edx,0x18(%esp)
c0105de4:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105de7:	89 54 24 14          	mov    %edx,0x14(%esp)
c0105deb:	89 44 24 10          	mov    %eax,0x10(%esp)
c0105def:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105df2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105df5:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105df9:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105dfd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e00:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e04:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e07:	89 04 24             	mov    %eax,(%esp)
c0105e0a:	e8 97 fa ff ff       	call   c01058a6 <printnum>
            break;
c0105e0f:	eb 3c                	jmp    c0105e4d <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0105e11:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e14:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e18:	89 1c 24             	mov    %ebx,(%esp)
c0105e1b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e1e:	ff d0                	call   *%eax
            break;
c0105e20:	eb 2b                	jmp    c0105e4d <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0105e22:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e25:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e29:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c0105e30:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e33:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0105e35:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0105e39:	eb 04                	jmp    c0105e3f <vprintfmt+0x3d0>
c0105e3b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0105e3f:	8b 45 10             	mov    0x10(%ebp),%eax
c0105e42:	83 e8 01             	sub    $0x1,%eax
c0105e45:	0f b6 00             	movzbl (%eax),%eax
c0105e48:	3c 25                	cmp    $0x25,%al
c0105e4a:	75 ef                	jne    c0105e3b <vprintfmt+0x3cc>
                /* do nothing */;
            break;
c0105e4c:	90                   	nop
        }
    }
c0105e4d:	90                   	nop
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105e4e:	e9 3e fc ff ff       	jmp    c0105a91 <vprintfmt+0x22>
}
c0105e53:	83 c4 40             	add    $0x40,%esp
c0105e56:	5b                   	pop    %ebx
c0105e57:	5e                   	pop    %esi
c0105e58:	5d                   	pop    %ebp
c0105e59:	c3                   	ret    

c0105e5a <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0105e5a:	55                   	push   %ebp
c0105e5b:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0105e5d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e60:	8b 40 08             	mov    0x8(%eax),%eax
c0105e63:	8d 50 01             	lea    0x1(%eax),%edx
c0105e66:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e69:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0105e6c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e6f:	8b 10                	mov    (%eax),%edx
c0105e71:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e74:	8b 40 04             	mov    0x4(%eax),%eax
c0105e77:	39 c2                	cmp    %eax,%edx
c0105e79:	73 12                	jae    c0105e8d <sprintputch+0x33>
        *b->buf ++ = ch;
c0105e7b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e7e:	8b 00                	mov    (%eax),%eax
c0105e80:	8d 48 01             	lea    0x1(%eax),%ecx
c0105e83:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105e86:	89 0a                	mov    %ecx,(%edx)
c0105e88:	8b 55 08             	mov    0x8(%ebp),%edx
c0105e8b:	88 10                	mov    %dl,(%eax)
    }
}
c0105e8d:	5d                   	pop    %ebp
c0105e8e:	c3                   	ret    

c0105e8f <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0105e8f:	55                   	push   %ebp
c0105e90:	89 e5                	mov    %esp,%ebp
c0105e92:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0105e95:	8d 45 14             	lea    0x14(%ebp),%eax
c0105e98:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0105e9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e9e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105ea2:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ea5:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105ea9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105eac:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105eb0:	8b 45 08             	mov    0x8(%ebp),%eax
c0105eb3:	89 04 24             	mov    %eax,(%esp)
c0105eb6:	e8 08 00 00 00       	call   c0105ec3 <vsnprintf>
c0105ebb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0105ebe:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105ec1:	c9                   	leave  
c0105ec2:	c3                   	ret    

c0105ec3 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0105ec3:	55                   	push   %ebp
c0105ec4:	89 e5                	mov    %esp,%ebp
c0105ec6:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0105ec9:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ecc:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105ecf:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ed2:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105ed5:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ed8:	01 d0                	add    %edx,%eax
c0105eda:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105edd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0105ee4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105ee8:	74 0a                	je     c0105ef4 <vsnprintf+0x31>
c0105eea:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105eed:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ef0:	39 c2                	cmp    %eax,%edx
c0105ef2:	76 07                	jbe    c0105efb <vsnprintf+0x38>
        return -E_INVAL;
c0105ef4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0105ef9:	eb 2a                	jmp    c0105f25 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c0105efb:	8b 45 14             	mov    0x14(%ebp),%eax
c0105efe:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105f02:	8b 45 10             	mov    0x10(%ebp),%eax
c0105f05:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105f09:	8d 45 ec             	lea    -0x14(%ebp),%eax
c0105f0c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105f10:	c7 04 24 5a 5e 10 c0 	movl   $0xc0105e5a,(%esp)
c0105f17:	e8 53 fb ff ff       	call   c0105a6f <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c0105f1c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105f1f:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0105f22:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105f25:	c9                   	leave  
c0105f26:	c3                   	ret    
