
bin/kernel_nopage:     file format elf32-i386


Disassembly of section .text:

00100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
  100000:	b8 00 80 11 40       	mov    $0x40118000,%eax
    movl %eax, %cr3
  100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
  100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
  10000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
  100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
  100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
  100016:	8d 05 1e 00 10 00    	lea    0x10001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
  10001c:	ff e0                	jmp    *%eax

0010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
  10001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
  100020:	a3 00 80 11 00       	mov    %eax,0x118000

    # set ebp, esp
    movl $0x0, %ebp
  100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
  10002a:	bc 00 70 11 00       	mov    $0x117000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
  10002f:	e8 02 00 00 00       	call   100036 <kern_init>

00100034 <spin>:

# should never get here
spin:
    jmp spin
  100034:	eb fe                	jmp    100034 <spin>

00100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
  100036:	55                   	push   %ebp
  100037:	89 e5                	mov    %esp,%ebp
  100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  10003c:	ba 28 af 11 00       	mov    $0x11af28,%edx
  100041:	b8 36 7a 11 00       	mov    $0x117a36,%eax
  100046:	29 c2                	sub    %eax,%edx
  100048:	89 d0                	mov    %edx,%eax
  10004a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  100055:	00 
  100056:	c7 04 24 36 7a 11 00 	movl   $0x117a36,(%esp)
  10005d:	e8 bb 56 00 00       	call   10571d <memset>

    cons_init();                // init the console
  100062:	e8 8c 15 00 00       	call   1015f3 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100067:	c7 45 f4 40 5f 10 00 	movl   $0x105f40,-0xc(%ebp)
    cprintf("%s\n\n", message);
  10006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100071:	89 44 24 04          	mov    %eax,0x4(%esp)
  100075:	c7 04 24 5c 5f 10 00 	movl   $0x105f5c,(%esp)
  10007c:	e8 11 02 00 00       	call   100292 <cprintf>

    print_kerninfo();
  100081:	e8 c3 08 00 00       	call   100949 <print_kerninfo>

    grade_backtrace();
  100086:	e8 86 00 00 00       	call   100111 <grade_backtrace>

    pmm_init();                 // init physical memory management
  10008b:	e8 50 31 00 00       	call   1031e0 <pmm_init>

    pic_init();                 // init interrupt controller
  100090:	e8 bb 16 00 00       	call   101750 <pic_init>
    idt_init();                 // init interrupt descriptor table
  100095:	e8 3f 18 00 00       	call   1018d9 <idt_init>

    clock_init();               // init clock interrupt
  10009a:	e8 0a 0d 00 00       	call   100da9 <clock_init>
    intr_enable();              // enable irq interrupt
  10009f:	e8 e7 17 00 00       	call   10188b <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
  1000a4:	eb fe                	jmp    1000a4 <kern_init+0x6e>

001000a6 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  1000a6:	55                   	push   %ebp
  1000a7:	89 e5                	mov    %esp,%ebp
  1000a9:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
  1000ac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1000b3:	00 
  1000b4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1000bb:	00 
  1000bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1000c3:	e8 cf 0c 00 00       	call   100d97 <mon_backtrace>
}
  1000c8:	c9                   	leave  
  1000c9:	c3                   	ret    

001000ca <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  1000ca:	55                   	push   %ebp
  1000cb:	89 e5                	mov    %esp,%ebp
  1000cd:	53                   	push   %ebx
  1000ce:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  1000d1:	8d 5d 0c             	lea    0xc(%ebp),%ebx
  1000d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  1000d7:	8d 55 08             	lea    0x8(%ebp),%edx
  1000da:	8b 45 08             	mov    0x8(%ebp),%eax
  1000dd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1000e1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  1000e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  1000e9:	89 04 24             	mov    %eax,(%esp)
  1000ec:	e8 b5 ff ff ff       	call   1000a6 <grade_backtrace2>
}
  1000f1:	83 c4 14             	add    $0x14,%esp
  1000f4:	5b                   	pop    %ebx
  1000f5:	5d                   	pop    %ebp
  1000f6:	c3                   	ret    

001000f7 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  1000f7:	55                   	push   %ebp
  1000f8:	89 e5                	mov    %esp,%ebp
  1000fa:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
  1000fd:	8b 45 10             	mov    0x10(%ebp),%eax
  100100:	89 44 24 04          	mov    %eax,0x4(%esp)
  100104:	8b 45 08             	mov    0x8(%ebp),%eax
  100107:	89 04 24             	mov    %eax,(%esp)
  10010a:	e8 bb ff ff ff       	call   1000ca <grade_backtrace1>
}
  10010f:	c9                   	leave  
  100110:	c3                   	ret    

00100111 <grade_backtrace>:

void
grade_backtrace(void) {
  100111:	55                   	push   %ebp
  100112:	89 e5                	mov    %esp,%ebp
  100114:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  100117:	b8 36 00 10 00       	mov    $0x100036,%eax
  10011c:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
  100123:	ff 
  100124:	89 44 24 04          	mov    %eax,0x4(%esp)
  100128:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  10012f:	e8 c3 ff ff ff       	call   1000f7 <grade_backtrace0>
}
  100134:	c9                   	leave  
  100135:	c3                   	ret    

00100136 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  100136:	55                   	push   %ebp
  100137:	89 e5                	mov    %esp,%ebp
  100139:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  10013c:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  10013f:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  100142:	8c 45 f2             	mov    %es,-0xe(%ebp)
  100145:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  100148:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10014c:	0f b7 c0             	movzwl %ax,%eax
  10014f:	83 e0 03             	and    $0x3,%eax
  100152:	89 c2                	mov    %eax,%edx
  100154:	a1 00 a0 11 00       	mov    0x11a000,%eax
  100159:	89 54 24 08          	mov    %edx,0x8(%esp)
  10015d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100161:	c7 04 24 61 5f 10 00 	movl   $0x105f61,(%esp)
  100168:	e8 25 01 00 00       	call   100292 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  10016d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100171:	0f b7 d0             	movzwl %ax,%edx
  100174:	a1 00 a0 11 00       	mov    0x11a000,%eax
  100179:	89 54 24 08          	mov    %edx,0x8(%esp)
  10017d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100181:	c7 04 24 6f 5f 10 00 	movl   $0x105f6f,(%esp)
  100188:	e8 05 01 00 00       	call   100292 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  10018d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100191:	0f b7 d0             	movzwl %ax,%edx
  100194:	a1 00 a0 11 00       	mov    0x11a000,%eax
  100199:	89 54 24 08          	mov    %edx,0x8(%esp)
  10019d:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001a1:	c7 04 24 7d 5f 10 00 	movl   $0x105f7d,(%esp)
  1001a8:	e8 e5 00 00 00       	call   100292 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  1001ad:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1001b1:	0f b7 d0             	movzwl %ax,%edx
  1001b4:	a1 00 a0 11 00       	mov    0x11a000,%eax
  1001b9:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001c1:	c7 04 24 8b 5f 10 00 	movl   $0x105f8b,(%esp)
  1001c8:	e8 c5 00 00 00       	call   100292 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  1001cd:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001d1:	0f b7 d0             	movzwl %ax,%edx
  1001d4:	a1 00 a0 11 00       	mov    0x11a000,%eax
  1001d9:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001e1:	c7 04 24 99 5f 10 00 	movl   $0x105f99,(%esp)
  1001e8:	e8 a5 00 00 00       	call   100292 <cprintf>
    round ++;
  1001ed:	a1 00 a0 11 00       	mov    0x11a000,%eax
  1001f2:	83 c0 01             	add    $0x1,%eax
  1001f5:	a3 00 a0 11 00       	mov    %eax,0x11a000
}
  1001fa:	c9                   	leave  
  1001fb:	c3                   	ret    

001001fc <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  1001fc:	55                   	push   %ebp
  1001fd:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
  1001ff:	5d                   	pop    %ebp
  100200:	c3                   	ret    

00100201 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  100201:	55                   	push   %ebp
  100202:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
  100204:	5d                   	pop    %ebp
  100205:	c3                   	ret    

00100206 <lab1_switch_test>:

static void
lab1_switch_test(void) {
  100206:	55                   	push   %ebp
  100207:	89 e5                	mov    %esp,%ebp
  100209:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
  10020c:	e8 25 ff ff ff       	call   100136 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  100211:	c7 04 24 a8 5f 10 00 	movl   $0x105fa8,(%esp)
  100218:	e8 75 00 00 00       	call   100292 <cprintf>
    lab1_switch_to_user();
  10021d:	e8 da ff ff ff       	call   1001fc <lab1_switch_to_user>
    lab1_print_cur_status();
  100222:	e8 0f ff ff ff       	call   100136 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  100227:	c7 04 24 c8 5f 10 00 	movl   $0x105fc8,(%esp)
  10022e:	e8 5f 00 00 00       	call   100292 <cprintf>
    lab1_switch_to_kernel();
  100233:	e8 c9 ff ff ff       	call   100201 <lab1_switch_to_kernel>
    lab1_print_cur_status();
  100238:	e8 f9 fe ff ff       	call   100136 <lab1_print_cur_status>
}
  10023d:	c9                   	leave  
  10023e:	c3                   	ret    

0010023f <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  10023f:	55                   	push   %ebp
  100240:	89 e5                	mov    %esp,%ebp
  100242:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  100245:	8b 45 08             	mov    0x8(%ebp),%eax
  100248:	89 04 24             	mov    %eax,(%esp)
  10024b:	e8 cf 13 00 00       	call   10161f <cons_putc>
    (*cnt) ++;
  100250:	8b 45 0c             	mov    0xc(%ebp),%eax
  100253:	8b 00                	mov    (%eax),%eax
  100255:	8d 50 01             	lea    0x1(%eax),%edx
  100258:	8b 45 0c             	mov    0xc(%ebp),%eax
  10025b:	89 10                	mov    %edx,(%eax)
}
  10025d:	c9                   	leave  
  10025e:	c3                   	ret    

0010025f <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  10025f:	55                   	push   %ebp
  100260:	89 e5                	mov    %esp,%ebp
  100262:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  100265:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  10026c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10026f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100273:	8b 45 08             	mov    0x8(%ebp),%eax
  100276:	89 44 24 08          	mov    %eax,0x8(%esp)
  10027a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  10027d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100281:	c7 04 24 3f 02 10 00 	movl   $0x10023f,(%esp)
  100288:	e8 e2 57 00 00       	call   105a6f <vprintfmt>
    return cnt;
  10028d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100290:	c9                   	leave  
  100291:	c3                   	ret    

00100292 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  100292:	55                   	push   %ebp
  100293:	89 e5                	mov    %esp,%ebp
  100295:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  100298:	8d 45 0c             	lea    0xc(%ebp),%eax
  10029b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  10029e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1002a5:	8b 45 08             	mov    0x8(%ebp),%eax
  1002a8:	89 04 24             	mov    %eax,(%esp)
  1002ab:	e8 af ff ff ff       	call   10025f <vcprintf>
  1002b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  1002b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1002b6:	c9                   	leave  
  1002b7:	c3                   	ret    

001002b8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  1002b8:	55                   	push   %ebp
  1002b9:	89 e5                	mov    %esp,%ebp
  1002bb:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  1002be:	8b 45 08             	mov    0x8(%ebp),%eax
  1002c1:	89 04 24             	mov    %eax,(%esp)
  1002c4:	e8 56 13 00 00       	call   10161f <cons_putc>
}
  1002c9:	c9                   	leave  
  1002ca:	c3                   	ret    

001002cb <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  1002cb:	55                   	push   %ebp
  1002cc:	89 e5                	mov    %esp,%ebp
  1002ce:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  1002d1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  1002d8:	eb 13                	jmp    1002ed <cputs+0x22>
        cputch(c, &cnt);
  1002da:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  1002de:	8d 55 f0             	lea    -0x10(%ebp),%edx
  1002e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  1002e5:	89 04 24             	mov    %eax,(%esp)
  1002e8:	e8 52 ff ff ff       	call   10023f <cputch>
    while ((c = *str ++) != '\0') {
  1002ed:	8b 45 08             	mov    0x8(%ebp),%eax
  1002f0:	8d 50 01             	lea    0x1(%eax),%edx
  1002f3:	89 55 08             	mov    %edx,0x8(%ebp)
  1002f6:	0f b6 00             	movzbl (%eax),%eax
  1002f9:	88 45 f7             	mov    %al,-0x9(%ebp)
  1002fc:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  100300:	75 d8                	jne    1002da <cputs+0xf>
    }
    cputch('\n', &cnt);
  100302:	8d 45 f0             	lea    -0x10(%ebp),%eax
  100305:	89 44 24 04          	mov    %eax,0x4(%esp)
  100309:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  100310:	e8 2a ff ff ff       	call   10023f <cputch>
    return cnt;
  100315:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  100318:	c9                   	leave  
  100319:	c3                   	ret    

0010031a <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  10031a:	55                   	push   %ebp
  10031b:	89 e5                	mov    %esp,%ebp
  10031d:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  100320:	e8 36 13 00 00       	call   10165b <cons_getc>
  100325:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100328:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10032c:	74 f2                	je     100320 <getchar+0x6>
        /* do nothing */;
    return c;
  10032e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100331:	c9                   	leave  
  100332:	c3                   	ret    

00100333 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  100333:	55                   	push   %ebp
  100334:	89 e5                	mov    %esp,%ebp
  100336:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
  100339:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  10033d:	74 13                	je     100352 <readline+0x1f>
        cprintf("%s", prompt);
  10033f:	8b 45 08             	mov    0x8(%ebp),%eax
  100342:	89 44 24 04          	mov    %eax,0x4(%esp)
  100346:	c7 04 24 e7 5f 10 00 	movl   $0x105fe7,(%esp)
  10034d:	e8 40 ff ff ff       	call   100292 <cprintf>
    }
    int i = 0, c;
  100352:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  100359:	e8 bc ff ff ff       	call   10031a <getchar>
  10035e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  100361:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100365:	79 07                	jns    10036e <readline+0x3b>
            return NULL;
  100367:	b8 00 00 00 00       	mov    $0x0,%eax
  10036c:	eb 79                	jmp    1003e7 <readline+0xb4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  10036e:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  100372:	7e 28                	jle    10039c <readline+0x69>
  100374:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  10037b:	7f 1f                	jg     10039c <readline+0x69>
            cputchar(c);
  10037d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100380:	89 04 24             	mov    %eax,(%esp)
  100383:	e8 30 ff ff ff       	call   1002b8 <cputchar>
            buf[i ++] = c;
  100388:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10038b:	8d 50 01             	lea    0x1(%eax),%edx
  10038e:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100391:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100394:	88 90 20 a0 11 00    	mov    %dl,0x11a020(%eax)
  10039a:	eb 46                	jmp    1003e2 <readline+0xaf>
        }
        else if (c == '\b' && i > 0) {
  10039c:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  1003a0:	75 17                	jne    1003b9 <readline+0x86>
  1003a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1003a6:	7e 11                	jle    1003b9 <readline+0x86>
            cputchar(c);
  1003a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1003ab:	89 04 24             	mov    %eax,(%esp)
  1003ae:	e8 05 ff ff ff       	call   1002b8 <cputchar>
            i --;
  1003b3:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  1003b7:	eb 29                	jmp    1003e2 <readline+0xaf>
        }
        else if (c == '\n' || c == '\r') {
  1003b9:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  1003bd:	74 06                	je     1003c5 <readline+0x92>
  1003bf:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  1003c3:	75 1d                	jne    1003e2 <readline+0xaf>
            cputchar(c);
  1003c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1003c8:	89 04 24             	mov    %eax,(%esp)
  1003cb:	e8 e8 fe ff ff       	call   1002b8 <cputchar>
            buf[i] = '\0';
  1003d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1003d3:	05 20 a0 11 00       	add    $0x11a020,%eax
  1003d8:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1003db:	b8 20 a0 11 00       	mov    $0x11a020,%eax
  1003e0:	eb 05                	jmp    1003e7 <readline+0xb4>
        }
    }
  1003e2:	e9 72 ff ff ff       	jmp    100359 <readline+0x26>
}
  1003e7:	c9                   	leave  
  1003e8:	c3                   	ret    

001003e9 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  1003e9:	55                   	push   %ebp
  1003ea:	89 e5                	mov    %esp,%ebp
  1003ec:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
  1003ef:	a1 20 a4 11 00       	mov    0x11a420,%eax
  1003f4:	85 c0                	test   %eax,%eax
  1003f6:	74 02                	je     1003fa <__panic+0x11>
        goto panic_dead;
  1003f8:	eb 59                	jmp    100453 <__panic+0x6a>
    }
    is_panic = 1;
  1003fa:	c7 05 20 a4 11 00 01 	movl   $0x1,0x11a420
  100401:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  100404:	8d 45 14             	lea    0x14(%ebp),%eax
  100407:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  10040a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10040d:	89 44 24 08          	mov    %eax,0x8(%esp)
  100411:	8b 45 08             	mov    0x8(%ebp),%eax
  100414:	89 44 24 04          	mov    %eax,0x4(%esp)
  100418:	c7 04 24 ea 5f 10 00 	movl   $0x105fea,(%esp)
  10041f:	e8 6e fe ff ff       	call   100292 <cprintf>
    vcprintf(fmt, ap);
  100424:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100427:	89 44 24 04          	mov    %eax,0x4(%esp)
  10042b:	8b 45 10             	mov    0x10(%ebp),%eax
  10042e:	89 04 24             	mov    %eax,(%esp)
  100431:	e8 29 fe ff ff       	call   10025f <vcprintf>
    cprintf("\n");
  100436:	c7 04 24 06 60 10 00 	movl   $0x106006,(%esp)
  10043d:	e8 50 fe ff ff       	call   100292 <cprintf>
    
    cprintf("stack trackback:\n");
  100442:	c7 04 24 08 60 10 00 	movl   $0x106008,(%esp)
  100449:	e8 44 fe ff ff       	call   100292 <cprintf>
    print_stackframe();
  10044e:	e8 40 06 00 00       	call   100a93 <print_stackframe>
    
    va_end(ap);

panic_dead:
    intr_disable();
  100453:	e8 39 14 00 00       	call   101891 <intr_disable>
    while (1) {
        kmonitor(NULL);
  100458:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  10045f:	e8 64 08 00 00       	call   100cc8 <kmonitor>
    }
  100464:	eb f2                	jmp    100458 <__panic+0x6f>

00100466 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100466:	55                   	push   %ebp
  100467:	89 e5                	mov    %esp,%ebp
  100469:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  10046c:	8d 45 14             	lea    0x14(%ebp),%eax
  10046f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  100472:	8b 45 0c             	mov    0xc(%ebp),%eax
  100475:	89 44 24 08          	mov    %eax,0x8(%esp)
  100479:	8b 45 08             	mov    0x8(%ebp),%eax
  10047c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100480:	c7 04 24 1a 60 10 00 	movl   $0x10601a,(%esp)
  100487:	e8 06 fe ff ff       	call   100292 <cprintf>
    vcprintf(fmt, ap);
  10048c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10048f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100493:	8b 45 10             	mov    0x10(%ebp),%eax
  100496:	89 04 24             	mov    %eax,(%esp)
  100499:	e8 c1 fd ff ff       	call   10025f <vcprintf>
    cprintf("\n");
  10049e:	c7 04 24 06 60 10 00 	movl   $0x106006,(%esp)
  1004a5:	e8 e8 fd ff ff       	call   100292 <cprintf>
    va_end(ap);
}
  1004aa:	c9                   	leave  
  1004ab:	c3                   	ret    

001004ac <is_kernel_panic>:

bool
is_kernel_panic(void) {
  1004ac:	55                   	push   %ebp
  1004ad:	89 e5                	mov    %esp,%ebp
    return is_panic;
  1004af:	a1 20 a4 11 00       	mov    0x11a420,%eax
}
  1004b4:	5d                   	pop    %ebp
  1004b5:	c3                   	ret    

001004b6 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  1004b6:	55                   	push   %ebp
  1004b7:	89 e5                	mov    %esp,%ebp
  1004b9:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  1004bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004bf:	8b 00                	mov    (%eax),%eax
  1004c1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  1004c4:	8b 45 10             	mov    0x10(%ebp),%eax
  1004c7:	8b 00                	mov    (%eax),%eax
  1004c9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1004cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  1004d3:	e9 d2 00 00 00       	jmp    1005aa <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
  1004d8:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1004db:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1004de:	01 d0                	add    %edx,%eax
  1004e0:	89 c2                	mov    %eax,%edx
  1004e2:	c1 ea 1f             	shr    $0x1f,%edx
  1004e5:	01 d0                	add    %edx,%eax
  1004e7:	d1 f8                	sar    %eax
  1004e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1004ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1004ef:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  1004f2:	eb 04                	jmp    1004f8 <stab_binsearch+0x42>
            m --;
  1004f4:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
  1004f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004fb:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  1004fe:	7c 1f                	jl     10051f <stab_binsearch+0x69>
  100500:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100503:	89 d0                	mov    %edx,%eax
  100505:	01 c0                	add    %eax,%eax
  100507:	01 d0                	add    %edx,%eax
  100509:	c1 e0 02             	shl    $0x2,%eax
  10050c:	89 c2                	mov    %eax,%edx
  10050e:	8b 45 08             	mov    0x8(%ebp),%eax
  100511:	01 d0                	add    %edx,%eax
  100513:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100517:	0f b6 c0             	movzbl %al,%eax
  10051a:	3b 45 14             	cmp    0x14(%ebp),%eax
  10051d:	75 d5                	jne    1004f4 <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
  10051f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100522:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100525:	7d 0b                	jge    100532 <stab_binsearch+0x7c>
            l = true_m + 1;
  100527:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10052a:	83 c0 01             	add    $0x1,%eax
  10052d:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  100530:	eb 78                	jmp    1005aa <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
  100532:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  100539:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10053c:	89 d0                	mov    %edx,%eax
  10053e:	01 c0                	add    %eax,%eax
  100540:	01 d0                	add    %edx,%eax
  100542:	c1 e0 02             	shl    $0x2,%eax
  100545:	89 c2                	mov    %eax,%edx
  100547:	8b 45 08             	mov    0x8(%ebp),%eax
  10054a:	01 d0                	add    %edx,%eax
  10054c:	8b 40 08             	mov    0x8(%eax),%eax
  10054f:	3b 45 18             	cmp    0x18(%ebp),%eax
  100552:	73 13                	jae    100567 <stab_binsearch+0xb1>
            *region_left = m;
  100554:	8b 45 0c             	mov    0xc(%ebp),%eax
  100557:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10055a:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  10055c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10055f:	83 c0 01             	add    $0x1,%eax
  100562:	89 45 fc             	mov    %eax,-0x4(%ebp)
  100565:	eb 43                	jmp    1005aa <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
  100567:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10056a:	89 d0                	mov    %edx,%eax
  10056c:	01 c0                	add    %eax,%eax
  10056e:	01 d0                	add    %edx,%eax
  100570:	c1 e0 02             	shl    $0x2,%eax
  100573:	89 c2                	mov    %eax,%edx
  100575:	8b 45 08             	mov    0x8(%ebp),%eax
  100578:	01 d0                	add    %edx,%eax
  10057a:	8b 40 08             	mov    0x8(%eax),%eax
  10057d:	3b 45 18             	cmp    0x18(%ebp),%eax
  100580:	76 16                	jbe    100598 <stab_binsearch+0xe2>
            *region_right = m - 1;
  100582:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100585:	8d 50 ff             	lea    -0x1(%eax),%edx
  100588:	8b 45 10             	mov    0x10(%ebp),%eax
  10058b:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  10058d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100590:	83 e8 01             	sub    $0x1,%eax
  100593:	89 45 f8             	mov    %eax,-0x8(%ebp)
  100596:	eb 12                	jmp    1005aa <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  100598:	8b 45 0c             	mov    0xc(%ebp),%eax
  10059b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10059e:	89 10                	mov    %edx,(%eax)
            l = m;
  1005a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1005a3:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  1005a6:	83 45 18 01          	addl   $0x1,0x18(%ebp)
    while (l <= r) {
  1005aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1005ad:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  1005b0:	0f 8e 22 ff ff ff    	jle    1004d8 <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
  1005b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1005ba:	75 0f                	jne    1005cb <stab_binsearch+0x115>
        *region_right = *region_left - 1;
  1005bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005bf:	8b 00                	mov    (%eax),%eax
  1005c1:	8d 50 ff             	lea    -0x1(%eax),%edx
  1005c4:	8b 45 10             	mov    0x10(%ebp),%eax
  1005c7:	89 10                	mov    %edx,(%eax)
  1005c9:	eb 3f                	jmp    10060a <stab_binsearch+0x154>
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
  1005cb:	8b 45 10             	mov    0x10(%ebp),%eax
  1005ce:	8b 00                	mov    (%eax),%eax
  1005d0:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  1005d3:	eb 04                	jmp    1005d9 <stab_binsearch+0x123>
  1005d5:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
  1005d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005dc:	8b 00                	mov    (%eax),%eax
  1005de:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  1005e1:	7d 1f                	jge    100602 <stab_binsearch+0x14c>
  1005e3:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1005e6:	89 d0                	mov    %edx,%eax
  1005e8:	01 c0                	add    %eax,%eax
  1005ea:	01 d0                	add    %edx,%eax
  1005ec:	c1 e0 02             	shl    $0x2,%eax
  1005ef:	89 c2                	mov    %eax,%edx
  1005f1:	8b 45 08             	mov    0x8(%ebp),%eax
  1005f4:	01 d0                	add    %edx,%eax
  1005f6:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1005fa:	0f b6 c0             	movzbl %al,%eax
  1005fd:	3b 45 14             	cmp    0x14(%ebp),%eax
  100600:	75 d3                	jne    1005d5 <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
  100602:	8b 45 0c             	mov    0xc(%ebp),%eax
  100605:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100608:	89 10                	mov    %edx,(%eax)
    }
}
  10060a:	c9                   	leave  
  10060b:	c3                   	ret    

0010060c <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  10060c:	55                   	push   %ebp
  10060d:	89 e5                	mov    %esp,%ebp
  10060f:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  100612:	8b 45 0c             	mov    0xc(%ebp),%eax
  100615:	c7 00 38 60 10 00    	movl   $0x106038,(%eax)
    info->eip_line = 0;
  10061b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10061e:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  100625:	8b 45 0c             	mov    0xc(%ebp),%eax
  100628:	c7 40 08 38 60 10 00 	movl   $0x106038,0x8(%eax)
    info->eip_fn_namelen = 9;
  10062f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100632:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  100639:	8b 45 0c             	mov    0xc(%ebp),%eax
  10063c:	8b 55 08             	mov    0x8(%ebp),%edx
  10063f:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  100642:	8b 45 0c             	mov    0xc(%ebp),%eax
  100645:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  10064c:	c7 45 f4 70 72 10 00 	movl   $0x107270,-0xc(%ebp)
    stab_end = __STAB_END__;
  100653:	c7 45 f0 a0 1d 11 00 	movl   $0x111da0,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  10065a:	c7 45 ec a1 1d 11 00 	movl   $0x111da1,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  100661:	c7 45 e8 cd 47 11 00 	movl   $0x1147cd,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  100668:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10066b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  10066e:	76 0d                	jbe    10067d <debuginfo_eip+0x71>
  100670:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100673:	83 e8 01             	sub    $0x1,%eax
  100676:	0f b6 00             	movzbl (%eax),%eax
  100679:	84 c0                	test   %al,%al
  10067b:	74 0a                	je     100687 <debuginfo_eip+0x7b>
        return -1;
  10067d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100682:	e9 c0 02 00 00       	jmp    100947 <debuginfo_eip+0x33b>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  100687:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  10068e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100691:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100694:	29 c2                	sub    %eax,%edx
  100696:	89 d0                	mov    %edx,%eax
  100698:	c1 f8 02             	sar    $0x2,%eax
  10069b:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  1006a1:	83 e8 01             	sub    $0x1,%eax
  1006a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  1006a7:	8b 45 08             	mov    0x8(%ebp),%eax
  1006aa:	89 44 24 10          	mov    %eax,0x10(%esp)
  1006ae:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
  1006b5:	00 
  1006b6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  1006b9:	89 44 24 08          	mov    %eax,0x8(%esp)
  1006bd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  1006c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1006c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006c7:	89 04 24             	mov    %eax,(%esp)
  1006ca:	e8 e7 fd ff ff       	call   1004b6 <stab_binsearch>
    if (lfile == 0)
  1006cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006d2:	85 c0                	test   %eax,%eax
  1006d4:	75 0a                	jne    1006e0 <debuginfo_eip+0xd4>
        return -1;
  1006d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1006db:	e9 67 02 00 00       	jmp    100947 <debuginfo_eip+0x33b>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  1006e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006e3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1006e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1006e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  1006ec:	8b 45 08             	mov    0x8(%ebp),%eax
  1006ef:	89 44 24 10          	mov    %eax,0x10(%esp)
  1006f3:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
  1006fa:	00 
  1006fb:	8d 45 d8             	lea    -0x28(%ebp),%eax
  1006fe:	89 44 24 08          	mov    %eax,0x8(%esp)
  100702:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100705:	89 44 24 04          	mov    %eax,0x4(%esp)
  100709:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10070c:	89 04 24             	mov    %eax,(%esp)
  10070f:	e8 a2 fd ff ff       	call   1004b6 <stab_binsearch>

    if (lfun <= rfun) {
  100714:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100717:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10071a:	39 c2                	cmp    %eax,%edx
  10071c:	7f 7c                	jg     10079a <debuginfo_eip+0x18e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  10071e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100721:	89 c2                	mov    %eax,%edx
  100723:	89 d0                	mov    %edx,%eax
  100725:	01 c0                	add    %eax,%eax
  100727:	01 d0                	add    %edx,%eax
  100729:	c1 e0 02             	shl    $0x2,%eax
  10072c:	89 c2                	mov    %eax,%edx
  10072e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100731:	01 d0                	add    %edx,%eax
  100733:	8b 10                	mov    (%eax),%edx
  100735:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  100738:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10073b:	29 c1                	sub    %eax,%ecx
  10073d:	89 c8                	mov    %ecx,%eax
  10073f:	39 c2                	cmp    %eax,%edx
  100741:	73 22                	jae    100765 <debuginfo_eip+0x159>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  100743:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100746:	89 c2                	mov    %eax,%edx
  100748:	89 d0                	mov    %edx,%eax
  10074a:	01 c0                	add    %eax,%eax
  10074c:	01 d0                	add    %edx,%eax
  10074e:	c1 e0 02             	shl    $0x2,%eax
  100751:	89 c2                	mov    %eax,%edx
  100753:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100756:	01 d0                	add    %edx,%eax
  100758:	8b 10                	mov    (%eax),%edx
  10075a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10075d:	01 c2                	add    %eax,%edx
  10075f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100762:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  100765:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100768:	89 c2                	mov    %eax,%edx
  10076a:	89 d0                	mov    %edx,%eax
  10076c:	01 c0                	add    %eax,%eax
  10076e:	01 d0                	add    %edx,%eax
  100770:	c1 e0 02             	shl    $0x2,%eax
  100773:	89 c2                	mov    %eax,%edx
  100775:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100778:	01 d0                	add    %edx,%eax
  10077a:	8b 50 08             	mov    0x8(%eax),%edx
  10077d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100780:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  100783:	8b 45 0c             	mov    0xc(%ebp),%eax
  100786:	8b 40 10             	mov    0x10(%eax),%eax
  100789:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  10078c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10078f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  100792:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100795:	89 45 d0             	mov    %eax,-0x30(%ebp)
  100798:	eb 15                	jmp    1007af <debuginfo_eip+0x1a3>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  10079a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10079d:	8b 55 08             	mov    0x8(%ebp),%edx
  1007a0:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  1007a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1007a6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  1007a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1007ac:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  1007af:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007b2:	8b 40 08             	mov    0x8(%eax),%eax
  1007b5:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  1007bc:	00 
  1007bd:	89 04 24             	mov    %eax,(%esp)
  1007c0:	e8 cc 4d 00 00       	call   105591 <strfind>
  1007c5:	89 c2                	mov    %eax,%edx
  1007c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007ca:	8b 40 08             	mov    0x8(%eax),%eax
  1007cd:	29 c2                	sub    %eax,%edx
  1007cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007d2:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  1007d5:	8b 45 08             	mov    0x8(%ebp),%eax
  1007d8:	89 44 24 10          	mov    %eax,0x10(%esp)
  1007dc:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
  1007e3:	00 
  1007e4:	8d 45 d0             	lea    -0x30(%ebp),%eax
  1007e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  1007eb:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  1007ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  1007f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007f5:	89 04 24             	mov    %eax,(%esp)
  1007f8:	e8 b9 fc ff ff       	call   1004b6 <stab_binsearch>
    if (lline <= rline) {
  1007fd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100800:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100803:	39 c2                	cmp    %eax,%edx
  100805:	7f 24                	jg     10082b <debuginfo_eip+0x21f>
        info->eip_line = stabs[rline].n_desc;
  100807:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10080a:	89 c2                	mov    %eax,%edx
  10080c:	89 d0                	mov    %edx,%eax
  10080e:	01 c0                	add    %eax,%eax
  100810:	01 d0                	add    %edx,%eax
  100812:	c1 e0 02             	shl    $0x2,%eax
  100815:	89 c2                	mov    %eax,%edx
  100817:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10081a:	01 d0                	add    %edx,%eax
  10081c:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  100820:	0f b7 d0             	movzwl %ax,%edx
  100823:	8b 45 0c             	mov    0xc(%ebp),%eax
  100826:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  100829:	eb 13                	jmp    10083e <debuginfo_eip+0x232>
        return -1;
  10082b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100830:	e9 12 01 00 00       	jmp    100947 <debuginfo_eip+0x33b>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  100835:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100838:	83 e8 01             	sub    $0x1,%eax
  10083b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
  10083e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100841:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100844:	39 c2                	cmp    %eax,%edx
  100846:	7c 56                	jl     10089e <debuginfo_eip+0x292>
           && stabs[lline].n_type != N_SOL
  100848:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10084b:	89 c2                	mov    %eax,%edx
  10084d:	89 d0                	mov    %edx,%eax
  10084f:	01 c0                	add    %eax,%eax
  100851:	01 d0                	add    %edx,%eax
  100853:	c1 e0 02             	shl    $0x2,%eax
  100856:	89 c2                	mov    %eax,%edx
  100858:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10085b:	01 d0                	add    %edx,%eax
  10085d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100861:	3c 84                	cmp    $0x84,%al
  100863:	74 39                	je     10089e <debuginfo_eip+0x292>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  100865:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100868:	89 c2                	mov    %eax,%edx
  10086a:	89 d0                	mov    %edx,%eax
  10086c:	01 c0                	add    %eax,%eax
  10086e:	01 d0                	add    %edx,%eax
  100870:	c1 e0 02             	shl    $0x2,%eax
  100873:	89 c2                	mov    %eax,%edx
  100875:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100878:	01 d0                	add    %edx,%eax
  10087a:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10087e:	3c 64                	cmp    $0x64,%al
  100880:	75 b3                	jne    100835 <debuginfo_eip+0x229>
  100882:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100885:	89 c2                	mov    %eax,%edx
  100887:	89 d0                	mov    %edx,%eax
  100889:	01 c0                	add    %eax,%eax
  10088b:	01 d0                	add    %edx,%eax
  10088d:	c1 e0 02             	shl    $0x2,%eax
  100890:	89 c2                	mov    %eax,%edx
  100892:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100895:	01 d0                	add    %edx,%eax
  100897:	8b 40 08             	mov    0x8(%eax),%eax
  10089a:	85 c0                	test   %eax,%eax
  10089c:	74 97                	je     100835 <debuginfo_eip+0x229>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  10089e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1008a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1008a4:	39 c2                	cmp    %eax,%edx
  1008a6:	7c 46                	jl     1008ee <debuginfo_eip+0x2e2>
  1008a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008ab:	89 c2                	mov    %eax,%edx
  1008ad:	89 d0                	mov    %edx,%eax
  1008af:	01 c0                	add    %eax,%eax
  1008b1:	01 d0                	add    %edx,%eax
  1008b3:	c1 e0 02             	shl    $0x2,%eax
  1008b6:	89 c2                	mov    %eax,%edx
  1008b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008bb:	01 d0                	add    %edx,%eax
  1008bd:	8b 10                	mov    (%eax),%edx
  1008bf:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  1008c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1008c5:	29 c1                	sub    %eax,%ecx
  1008c7:	89 c8                	mov    %ecx,%eax
  1008c9:	39 c2                	cmp    %eax,%edx
  1008cb:	73 21                	jae    1008ee <debuginfo_eip+0x2e2>
        info->eip_file = stabstr + stabs[lline].n_strx;
  1008cd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008d0:	89 c2                	mov    %eax,%edx
  1008d2:	89 d0                	mov    %edx,%eax
  1008d4:	01 c0                	add    %eax,%eax
  1008d6:	01 d0                	add    %edx,%eax
  1008d8:	c1 e0 02             	shl    $0x2,%eax
  1008db:	89 c2                	mov    %eax,%edx
  1008dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008e0:	01 d0                	add    %edx,%eax
  1008e2:	8b 10                	mov    (%eax),%edx
  1008e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1008e7:	01 c2                	add    %eax,%edx
  1008e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008ec:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  1008ee:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1008f1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1008f4:	39 c2                	cmp    %eax,%edx
  1008f6:	7d 4a                	jge    100942 <debuginfo_eip+0x336>
        for (lline = lfun + 1;
  1008f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1008fb:	83 c0 01             	add    $0x1,%eax
  1008fe:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  100901:	eb 18                	jmp    10091b <debuginfo_eip+0x30f>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  100903:	8b 45 0c             	mov    0xc(%ebp),%eax
  100906:	8b 40 14             	mov    0x14(%eax),%eax
  100909:	8d 50 01             	lea    0x1(%eax),%edx
  10090c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10090f:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
  100912:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100915:	83 c0 01             	add    $0x1,%eax
  100918:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
  10091b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10091e:	8b 45 d8             	mov    -0x28(%ebp),%eax
        for (lline = lfun + 1;
  100921:	39 c2                	cmp    %eax,%edx
  100923:	7d 1d                	jge    100942 <debuginfo_eip+0x336>
             lline < rfun && stabs[lline].n_type == N_PSYM;
  100925:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100928:	89 c2                	mov    %eax,%edx
  10092a:	89 d0                	mov    %edx,%eax
  10092c:	01 c0                	add    %eax,%eax
  10092e:	01 d0                	add    %edx,%eax
  100930:	c1 e0 02             	shl    $0x2,%eax
  100933:	89 c2                	mov    %eax,%edx
  100935:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100938:	01 d0                	add    %edx,%eax
  10093a:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10093e:	3c a0                	cmp    $0xa0,%al
  100940:	74 c1                	je     100903 <debuginfo_eip+0x2f7>
        }
    }
    return 0;
  100942:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100947:	c9                   	leave  
  100948:	c3                   	ret    

00100949 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  100949:	55                   	push   %ebp
  10094a:	89 e5                	mov    %esp,%ebp
  10094c:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  10094f:	c7 04 24 42 60 10 00 	movl   $0x106042,(%esp)
  100956:	e8 37 f9 ff ff       	call   100292 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  10095b:	c7 44 24 04 36 00 10 	movl   $0x100036,0x4(%esp)
  100962:	00 
  100963:	c7 04 24 5b 60 10 00 	movl   $0x10605b,(%esp)
  10096a:	e8 23 f9 ff ff       	call   100292 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  10096f:	c7 44 24 04 27 5f 10 	movl   $0x105f27,0x4(%esp)
  100976:	00 
  100977:	c7 04 24 73 60 10 00 	movl   $0x106073,(%esp)
  10097e:	e8 0f f9 ff ff       	call   100292 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  100983:	c7 44 24 04 36 7a 11 	movl   $0x117a36,0x4(%esp)
  10098a:	00 
  10098b:	c7 04 24 8b 60 10 00 	movl   $0x10608b,(%esp)
  100992:	e8 fb f8 ff ff       	call   100292 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  100997:	c7 44 24 04 28 af 11 	movl   $0x11af28,0x4(%esp)
  10099e:	00 
  10099f:	c7 04 24 a3 60 10 00 	movl   $0x1060a3,(%esp)
  1009a6:	e8 e7 f8 ff ff       	call   100292 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  1009ab:	b8 28 af 11 00       	mov    $0x11af28,%eax
  1009b0:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1009b6:	b8 36 00 10 00       	mov    $0x100036,%eax
  1009bb:	29 c2                	sub    %eax,%edx
  1009bd:	89 d0                	mov    %edx,%eax
  1009bf:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1009c5:	85 c0                	test   %eax,%eax
  1009c7:	0f 48 c2             	cmovs  %edx,%eax
  1009ca:	c1 f8 0a             	sar    $0xa,%eax
  1009cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009d1:	c7 04 24 bc 60 10 00 	movl   $0x1060bc,(%esp)
  1009d8:	e8 b5 f8 ff ff       	call   100292 <cprintf>
}
  1009dd:	c9                   	leave  
  1009de:	c3                   	ret    

001009df <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  1009df:	55                   	push   %ebp
  1009e0:	89 e5                	mov    %esp,%ebp
  1009e2:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  1009e8:	8d 45 dc             	lea    -0x24(%ebp),%eax
  1009eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009ef:	8b 45 08             	mov    0x8(%ebp),%eax
  1009f2:	89 04 24             	mov    %eax,(%esp)
  1009f5:	e8 12 fc ff ff       	call   10060c <debuginfo_eip>
  1009fa:	85 c0                	test   %eax,%eax
  1009fc:	74 15                	je     100a13 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  1009fe:	8b 45 08             	mov    0x8(%ebp),%eax
  100a01:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a05:	c7 04 24 e6 60 10 00 	movl   $0x1060e6,(%esp)
  100a0c:	e8 81 f8 ff ff       	call   100292 <cprintf>
  100a11:	eb 6d                	jmp    100a80 <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100a13:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100a1a:	eb 1c                	jmp    100a38 <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
  100a1c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  100a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a22:	01 d0                	add    %edx,%eax
  100a24:	0f b6 00             	movzbl (%eax),%eax
  100a27:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100a2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100a30:	01 ca                	add    %ecx,%edx
  100a32:	88 02                	mov    %al,(%edx)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100a34:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100a38:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a3b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  100a3e:	7f dc                	jg     100a1c <print_debuginfo+0x3d>
        }
        fnname[j] = '\0';
  100a40:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  100a46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a49:	01 d0                	add    %edx,%eax
  100a4b:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
  100a4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  100a51:	8b 55 08             	mov    0x8(%ebp),%edx
  100a54:	89 d1                	mov    %edx,%ecx
  100a56:	29 c1                	sub    %eax,%ecx
  100a58:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100a5b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100a5e:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  100a62:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100a68:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  100a6c:	89 54 24 08          	mov    %edx,0x8(%esp)
  100a70:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a74:	c7 04 24 02 61 10 00 	movl   $0x106102,(%esp)
  100a7b:	e8 12 f8 ff ff       	call   100292 <cprintf>
    }
}
  100a80:	c9                   	leave  
  100a81:	c3                   	ret    

00100a82 <read_eip>:

static __noinline uint32_t
read_eip(void) {
  100a82:	55                   	push   %ebp
  100a83:	89 e5                	mov    %esp,%ebp
  100a85:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  100a88:	8b 45 04             	mov    0x4(%ebp),%eax
  100a8b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  100a8e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  100a91:	c9                   	leave  
  100a92:	c3                   	ret    

00100a93 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
  100a93:	55                   	push   %ebp
  100a94:	89 e5                	mov    %esp,%ebp
  100a96:	53                   	push   %ebx
  100a97:	83 ec 44             	sub    $0x44,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  100a9a:	89 e8                	mov    %ebp,%eax
  100a9c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return ebp;
  100a9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp=read_ebp(),eip=read_eip();
  100aa2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100aa5:	e8 d8 ff ff ff       	call   100a82 <read_eip>
  100aaa:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int i;//这里在for循环里定义好像不行的样子就拿出来了
	for(i=0;ebp!=0&&i<STACKFRAME_DEPTH;i++)
  100aad:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  100ab4:	e9 8d 00 00 00       	jmp    100b46 <print_stackframe+0xb3>
    {   
		cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
  100ab9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100abc:	89 44 24 08          	mov    %eax,0x8(%esp)
  100ac0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ac3:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ac7:	c7 04 24 14 61 10 00 	movl   $0x106114,(%esp)
  100ace:	e8 bf f7 ff ff       	call   100292 <cprintf>
		uint32_t *args = (uint32_t *)ebp + 2;       //ebp+8指向参数，+4指向返回值
  100ad3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ad6:	83 c0 08             	add    $0x8,%eax
  100ad9:	89 45 e8             	mov    %eax,-0x18(%ebp)
		cprintf("arg :0x%08x 0x%08x 0x%08x 0x%08x\n",*(args+0),*(args+1),*(args+2),*(args+3));
  100adc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100adf:	83 c0 0c             	add    $0xc,%eax
  100ae2:	8b 18                	mov    (%eax),%ebx
  100ae4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100ae7:	83 c0 08             	add    $0x8,%eax
  100aea:	8b 08                	mov    (%eax),%ecx
  100aec:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100aef:	83 c0 04             	add    $0x4,%eax
  100af2:	8b 10                	mov    (%eax),%edx
  100af4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100af7:	8b 00                	mov    (%eax),%eax
  100af9:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  100afd:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  100b01:	89 54 24 08          	mov    %edx,0x8(%esp)
  100b05:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b09:	c7 04 24 30 61 10 00 	movl   $0x106130,(%esp)
  100b10:	e8 7d f7 ff ff       	call   100292 <cprintf>
        //依次打印调用函数的参数1 2 3 4
		cprintf("\n");
  100b15:	c7 04 24 52 61 10 00 	movl   $0x106152,(%esp)
  100b1c:	e8 71 f7 ff ff       	call   100292 <cprintf>
		print_debuginfo(eip - 1);//eip指向的是下一条指令，所以这里减1  指针占4
  100b21:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100b24:	83 e8 01             	sub    $0x1,%eax
  100b27:	89 04 24             	mov    %eax,(%esp)
  100b2a:	e8 b0 fe ff ff       	call   1009df <print_debuginfo>
		eip = ((uint32_t *)ebp)[1]; //此时eip指向返回地址
  100b2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b32:	83 c0 04             	add    $0x4,%eax
  100b35:	8b 00                	mov    (%eax),%eax
  100b37:	89 45 f0             	mov    %eax,-0x10(%ebp)
		ebp = ((uint32_t *)ebp)[0];//ebp存的是调用者edp，所以这里就复原了调用前edp值
  100b3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b3d:	8b 00                	mov    (%eax),%eax
  100b3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for(i=0;ebp!=0&&i<STACKFRAME_DEPTH;i++)
  100b42:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
  100b46:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100b4a:	74 0a                	je     100b56 <print_stackframe+0xc3>
  100b4c:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100b50:	0f 8e 63 ff ff ff    	jle    100ab9 <print_stackframe+0x26>
	}
}
  100b56:	83 c4 44             	add    $0x44,%esp
  100b59:	5b                   	pop    %ebx
  100b5a:	5d                   	pop    %ebp
  100b5b:	c3                   	ret    

00100b5c <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100b5c:	55                   	push   %ebp
  100b5d:	89 e5                	mov    %esp,%ebp
  100b5f:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  100b62:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b69:	eb 0c                	jmp    100b77 <parse+0x1b>
            *buf ++ = '\0';
  100b6b:	8b 45 08             	mov    0x8(%ebp),%eax
  100b6e:	8d 50 01             	lea    0x1(%eax),%edx
  100b71:	89 55 08             	mov    %edx,0x8(%ebp)
  100b74:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b77:	8b 45 08             	mov    0x8(%ebp),%eax
  100b7a:	0f b6 00             	movzbl (%eax),%eax
  100b7d:	84 c0                	test   %al,%al
  100b7f:	74 1d                	je     100b9e <parse+0x42>
  100b81:	8b 45 08             	mov    0x8(%ebp),%eax
  100b84:	0f b6 00             	movzbl (%eax),%eax
  100b87:	0f be c0             	movsbl %al,%eax
  100b8a:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b8e:	c7 04 24 d4 61 10 00 	movl   $0x1061d4,(%esp)
  100b95:	e8 c4 49 00 00       	call   10555e <strchr>
  100b9a:	85 c0                	test   %eax,%eax
  100b9c:	75 cd                	jne    100b6b <parse+0xf>
        }
        if (*buf == '\0') {
  100b9e:	8b 45 08             	mov    0x8(%ebp),%eax
  100ba1:	0f b6 00             	movzbl (%eax),%eax
  100ba4:	84 c0                	test   %al,%al
  100ba6:	75 02                	jne    100baa <parse+0x4e>
            break;
  100ba8:	eb 67                	jmp    100c11 <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100baa:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100bae:	75 14                	jne    100bc4 <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100bb0:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100bb7:	00 
  100bb8:	c7 04 24 d9 61 10 00 	movl   $0x1061d9,(%esp)
  100bbf:	e8 ce f6 ff ff       	call   100292 <cprintf>
        }
        argv[argc ++] = buf;
  100bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100bc7:	8d 50 01             	lea    0x1(%eax),%edx
  100bca:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100bcd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100bd4:	8b 45 0c             	mov    0xc(%ebp),%eax
  100bd7:	01 c2                	add    %eax,%edx
  100bd9:	8b 45 08             	mov    0x8(%ebp),%eax
  100bdc:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100bde:	eb 04                	jmp    100be4 <parse+0x88>
            buf ++;
  100be0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100be4:	8b 45 08             	mov    0x8(%ebp),%eax
  100be7:	0f b6 00             	movzbl (%eax),%eax
  100bea:	84 c0                	test   %al,%al
  100bec:	74 1d                	je     100c0b <parse+0xaf>
  100bee:	8b 45 08             	mov    0x8(%ebp),%eax
  100bf1:	0f b6 00             	movzbl (%eax),%eax
  100bf4:	0f be c0             	movsbl %al,%eax
  100bf7:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bfb:	c7 04 24 d4 61 10 00 	movl   $0x1061d4,(%esp)
  100c02:	e8 57 49 00 00       	call   10555e <strchr>
  100c07:	85 c0                	test   %eax,%eax
  100c09:	74 d5                	je     100be0 <parse+0x84>
        }
    }
  100c0b:	90                   	nop
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100c0c:	e9 66 ff ff ff       	jmp    100b77 <parse+0x1b>
    return argc;
  100c11:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100c14:	c9                   	leave  
  100c15:	c3                   	ret    

00100c16 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100c16:	55                   	push   %ebp
  100c17:	89 e5                	mov    %esp,%ebp
  100c19:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100c1c:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100c1f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c23:	8b 45 08             	mov    0x8(%ebp),%eax
  100c26:	89 04 24             	mov    %eax,(%esp)
  100c29:	e8 2e ff ff ff       	call   100b5c <parse>
  100c2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100c31:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100c35:	75 0a                	jne    100c41 <runcmd+0x2b>
        return 0;
  100c37:	b8 00 00 00 00       	mov    $0x0,%eax
  100c3c:	e9 85 00 00 00       	jmp    100cc6 <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c41:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100c48:	eb 5c                	jmp    100ca6 <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100c4a:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  100c4d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c50:	89 d0                	mov    %edx,%eax
  100c52:	01 c0                	add    %eax,%eax
  100c54:	01 d0                	add    %edx,%eax
  100c56:	c1 e0 02             	shl    $0x2,%eax
  100c59:	05 00 70 11 00       	add    $0x117000,%eax
  100c5e:	8b 00                	mov    (%eax),%eax
  100c60:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100c64:	89 04 24             	mov    %eax,(%esp)
  100c67:	e8 53 48 00 00       	call   1054bf <strcmp>
  100c6c:	85 c0                	test   %eax,%eax
  100c6e:	75 32                	jne    100ca2 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
  100c70:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c73:	89 d0                	mov    %edx,%eax
  100c75:	01 c0                	add    %eax,%eax
  100c77:	01 d0                	add    %edx,%eax
  100c79:	c1 e0 02             	shl    $0x2,%eax
  100c7c:	05 00 70 11 00       	add    $0x117000,%eax
  100c81:	8b 40 08             	mov    0x8(%eax),%eax
  100c84:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100c87:	8d 4a ff             	lea    -0x1(%edx),%ecx
  100c8a:	8b 55 0c             	mov    0xc(%ebp),%edx
  100c8d:	89 54 24 08          	mov    %edx,0x8(%esp)
  100c91:	8d 55 b0             	lea    -0x50(%ebp),%edx
  100c94:	83 c2 04             	add    $0x4,%edx
  100c97:	89 54 24 04          	mov    %edx,0x4(%esp)
  100c9b:	89 0c 24             	mov    %ecx,(%esp)
  100c9e:	ff d0                	call   *%eax
  100ca0:	eb 24                	jmp    100cc6 <runcmd+0xb0>
    for (i = 0; i < NCOMMANDS; i ++) {
  100ca2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100ca6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ca9:	83 f8 02             	cmp    $0x2,%eax
  100cac:	76 9c                	jbe    100c4a <runcmd+0x34>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100cae:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100cb1:	89 44 24 04          	mov    %eax,0x4(%esp)
  100cb5:	c7 04 24 f7 61 10 00 	movl   $0x1061f7,(%esp)
  100cbc:	e8 d1 f5 ff ff       	call   100292 <cprintf>
    return 0;
  100cc1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cc6:	c9                   	leave  
  100cc7:	c3                   	ret    

00100cc8 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100cc8:	55                   	push   %ebp
  100cc9:	89 e5                	mov    %esp,%ebp
  100ccb:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100cce:	c7 04 24 10 62 10 00 	movl   $0x106210,(%esp)
  100cd5:	e8 b8 f5 ff ff       	call   100292 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100cda:	c7 04 24 38 62 10 00 	movl   $0x106238,(%esp)
  100ce1:	e8 ac f5 ff ff       	call   100292 <cprintf>

    if (tf != NULL) {
  100ce6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100cea:	74 0b                	je     100cf7 <kmonitor+0x2f>
        print_trapframe(tf);
  100cec:	8b 45 08             	mov    0x8(%ebp),%eax
  100cef:	89 04 24             	mov    %eax,(%esp)
  100cf2:	e8 99 0d 00 00       	call   101a90 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100cf7:	c7 04 24 5d 62 10 00 	movl   $0x10625d,(%esp)
  100cfe:	e8 30 f6 ff ff       	call   100333 <readline>
  100d03:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100d06:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100d0a:	74 18                	je     100d24 <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
  100d0c:	8b 45 08             	mov    0x8(%ebp),%eax
  100d0f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d13:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d16:	89 04 24             	mov    %eax,(%esp)
  100d19:	e8 f8 fe ff ff       	call   100c16 <runcmd>
  100d1e:	85 c0                	test   %eax,%eax
  100d20:	79 02                	jns    100d24 <kmonitor+0x5c>
                break;
  100d22:	eb 02                	jmp    100d26 <kmonitor+0x5e>
            }
        }
    }
  100d24:	eb d1                	jmp    100cf7 <kmonitor+0x2f>
}
  100d26:	c9                   	leave  
  100d27:	c3                   	ret    

00100d28 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100d28:	55                   	push   %ebp
  100d29:	89 e5                	mov    %esp,%ebp
  100d2b:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100d2e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100d35:	eb 3f                	jmp    100d76 <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100d37:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100d3a:	89 d0                	mov    %edx,%eax
  100d3c:	01 c0                	add    %eax,%eax
  100d3e:	01 d0                	add    %edx,%eax
  100d40:	c1 e0 02             	shl    $0x2,%eax
  100d43:	05 00 70 11 00       	add    $0x117000,%eax
  100d48:	8b 48 04             	mov    0x4(%eax),%ecx
  100d4b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100d4e:	89 d0                	mov    %edx,%eax
  100d50:	01 c0                	add    %eax,%eax
  100d52:	01 d0                	add    %edx,%eax
  100d54:	c1 e0 02             	shl    $0x2,%eax
  100d57:	05 00 70 11 00       	add    $0x117000,%eax
  100d5c:	8b 00                	mov    (%eax),%eax
  100d5e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100d62:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d66:	c7 04 24 61 62 10 00 	movl   $0x106261,(%esp)
  100d6d:	e8 20 f5 ff ff       	call   100292 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
  100d72:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100d76:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d79:	83 f8 02             	cmp    $0x2,%eax
  100d7c:	76 b9                	jbe    100d37 <mon_help+0xf>
    }
    return 0;
  100d7e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d83:	c9                   	leave  
  100d84:	c3                   	ret    

00100d85 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100d85:	55                   	push   %ebp
  100d86:	89 e5                	mov    %esp,%ebp
  100d88:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100d8b:	e8 b9 fb ff ff       	call   100949 <print_kerninfo>
    return 0;
  100d90:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d95:	c9                   	leave  
  100d96:	c3                   	ret    

00100d97 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100d97:	55                   	push   %ebp
  100d98:	89 e5                	mov    %esp,%ebp
  100d9a:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100d9d:	e8 f1 fc ff ff       	call   100a93 <print_stackframe>
    return 0;
  100da2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100da7:	c9                   	leave  
  100da8:	c3                   	ret    

00100da9 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100da9:	55                   	push   %ebp
  100daa:	89 e5                	mov    %esp,%ebp
  100dac:	83 ec 28             	sub    $0x28,%esp
  100daf:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
  100db5:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100db9:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100dbd:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100dc1:	ee                   	out    %al,(%dx)
  100dc2:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100dc8:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
  100dcc:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100dd0:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100dd4:	ee                   	out    %al,(%dx)
  100dd5:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
  100ddb:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
  100ddf:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100de3:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100de7:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100de8:	c7 05 0c af 11 00 00 	movl   $0x0,0x11af0c
  100def:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100df2:	c7 04 24 6a 62 10 00 	movl   $0x10626a,(%esp)
  100df9:	e8 94 f4 ff ff       	call   100292 <cprintf>
    pic_enable(IRQ_TIMER);
  100dfe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100e05:	e8 18 09 00 00       	call   101722 <pic_enable>
}
  100e0a:	c9                   	leave  
  100e0b:	c3                   	ret    

00100e0c <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  100e0c:	55                   	push   %ebp
  100e0d:	89 e5                	mov    %esp,%ebp
  100e0f:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  100e12:	9c                   	pushf  
  100e13:	58                   	pop    %eax
  100e14:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  100e17:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  100e1a:	25 00 02 00 00       	and    $0x200,%eax
  100e1f:	85 c0                	test   %eax,%eax
  100e21:	74 0c                	je     100e2f <__intr_save+0x23>
        intr_disable();
  100e23:	e8 69 0a 00 00       	call   101891 <intr_disable>
        return 1;
  100e28:	b8 01 00 00 00       	mov    $0x1,%eax
  100e2d:	eb 05                	jmp    100e34 <__intr_save+0x28>
    }
    return 0;
  100e2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100e34:	c9                   	leave  
  100e35:	c3                   	ret    

00100e36 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  100e36:	55                   	push   %ebp
  100e37:	89 e5                	mov    %esp,%ebp
  100e39:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  100e3c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100e40:	74 05                	je     100e47 <__intr_restore+0x11>
        intr_enable();
  100e42:	e8 44 0a 00 00       	call   10188b <intr_enable>
    }
}
  100e47:	c9                   	leave  
  100e48:	c3                   	ret    

00100e49 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100e49:	55                   	push   %ebp
  100e4a:	89 e5                	mov    %esp,%ebp
  100e4c:	83 ec 10             	sub    $0x10,%esp
  100e4f:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100e55:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100e59:	89 c2                	mov    %eax,%edx
  100e5b:	ec                   	in     (%dx),%al
  100e5c:	88 45 fd             	mov    %al,-0x3(%ebp)
  100e5f:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100e65:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100e69:	89 c2                	mov    %eax,%edx
  100e6b:	ec                   	in     (%dx),%al
  100e6c:	88 45 f9             	mov    %al,-0x7(%ebp)
  100e6f:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
  100e75:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100e79:	89 c2                	mov    %eax,%edx
  100e7b:	ec                   	in     (%dx),%al
  100e7c:	88 45 f5             	mov    %al,-0xb(%ebp)
  100e7f:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
  100e85:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100e89:	89 c2                	mov    %eax,%edx
  100e8b:	ec                   	in     (%dx),%al
  100e8c:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100e8f:	c9                   	leave  
  100e90:	c3                   	ret    

00100e91 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
  100e91:	55                   	push   %ebp
  100e92:	89 e5                	mov    %esp,%ebp
  100e94:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
  100e97:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
  100e9e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ea1:	0f b7 00             	movzwl (%eax),%eax
  100ea4:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
  100ea8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100eab:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
  100eb0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100eb3:	0f b7 00             	movzwl (%eax),%eax
  100eb6:	66 3d 5a a5          	cmp    $0xa55a,%ax
  100eba:	74 12                	je     100ece <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
  100ebc:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
  100ec3:	66 c7 05 46 a4 11 00 	movw   $0x3b4,0x11a446
  100eca:	b4 03 
  100ecc:	eb 13                	jmp    100ee1 <cga_init+0x50>
    } else {
        *cp = was;
  100ece:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ed1:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100ed5:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
  100ed8:	66 c7 05 46 a4 11 00 	movw   $0x3d4,0x11a446
  100edf:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
  100ee1:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100ee8:	0f b7 c0             	movzwl %ax,%eax
  100eeb:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  100eef:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100ef3:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100ef7:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100efb:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
  100efc:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100f03:	83 c0 01             	add    $0x1,%eax
  100f06:	0f b7 c0             	movzwl %ax,%eax
  100f09:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f0d:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  100f11:	89 c2                	mov    %eax,%edx
  100f13:	ec                   	in     (%dx),%al
  100f14:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  100f17:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100f1b:	0f b6 c0             	movzbl %al,%eax
  100f1e:	c1 e0 08             	shl    $0x8,%eax
  100f21:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100f24:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100f2b:	0f b7 c0             	movzwl %ax,%eax
  100f2e:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
  100f32:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f36:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100f3a:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100f3e:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
  100f3f:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100f46:	83 c0 01             	add    $0x1,%eax
  100f49:	0f b7 c0             	movzwl %ax,%eax
  100f4c:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f50:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
  100f54:	89 c2                	mov    %eax,%edx
  100f56:	ec                   	in     (%dx),%al
  100f57:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
  100f5a:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100f5e:	0f b6 c0             	movzbl %al,%eax
  100f61:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
  100f64:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100f67:	a3 40 a4 11 00       	mov    %eax,0x11a440
    crt_pos = pos;
  100f6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100f6f:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
}
  100f75:	c9                   	leave  
  100f76:	c3                   	ret    

00100f77 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100f77:	55                   	push   %ebp
  100f78:	89 e5                	mov    %esp,%ebp
  100f7a:	83 ec 48             	sub    $0x48,%esp
  100f7d:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
  100f83:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f87:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100f8b:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100f8f:	ee                   	out    %al,(%dx)
  100f90:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
  100f96:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
  100f9a:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100f9e:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100fa2:	ee                   	out    %al,(%dx)
  100fa3:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
  100fa9:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
  100fad:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100fb1:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100fb5:	ee                   	out    %al,(%dx)
  100fb6:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  100fbc:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
  100fc0:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100fc4:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100fc8:	ee                   	out    %al,(%dx)
  100fc9:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
  100fcf:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
  100fd3:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100fd7:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100fdb:	ee                   	out    %al,(%dx)
  100fdc:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
  100fe2:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
  100fe6:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  100fea:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  100fee:	ee                   	out    %al,(%dx)
  100fef:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
  100ff5:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
  100ff9:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100ffd:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  101001:	ee                   	out    %al,(%dx)
  101002:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101008:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
  10100c:	89 c2                	mov    %eax,%edx
  10100e:	ec                   	in     (%dx),%al
  10100f:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
  101012:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  101016:	3c ff                	cmp    $0xff,%al
  101018:	0f 95 c0             	setne  %al
  10101b:	0f b6 c0             	movzbl %al,%eax
  10101e:	a3 48 a4 11 00       	mov    %eax,0x11a448
  101023:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101029:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
  10102d:	89 c2                	mov    %eax,%edx
  10102f:	ec                   	in     (%dx),%al
  101030:	88 45 d5             	mov    %al,-0x2b(%ebp)
  101033:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
  101039:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
  10103d:	89 c2                	mov    %eax,%edx
  10103f:	ec                   	in     (%dx),%al
  101040:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  101043:	a1 48 a4 11 00       	mov    0x11a448,%eax
  101048:	85 c0                	test   %eax,%eax
  10104a:	74 0c                	je     101058 <serial_init+0xe1>
        pic_enable(IRQ_COM1);
  10104c:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  101053:	e8 ca 06 00 00       	call   101722 <pic_enable>
    }
}
  101058:	c9                   	leave  
  101059:	c3                   	ret    

0010105a <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  10105a:	55                   	push   %ebp
  10105b:	89 e5                	mov    %esp,%ebp
  10105d:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  101060:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101067:	eb 09                	jmp    101072 <lpt_putc_sub+0x18>
        delay();
  101069:	e8 db fd ff ff       	call   100e49 <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  10106e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  101072:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
  101078:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  10107c:	89 c2                	mov    %eax,%edx
  10107e:	ec                   	in     (%dx),%al
  10107f:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101082:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101086:	84 c0                	test   %al,%al
  101088:	78 09                	js     101093 <lpt_putc_sub+0x39>
  10108a:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101091:	7e d6                	jle    101069 <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
  101093:	8b 45 08             	mov    0x8(%ebp),%eax
  101096:	0f b6 c0             	movzbl %al,%eax
  101099:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
  10109f:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1010a2:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1010a6:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1010aa:	ee                   	out    %al,(%dx)
  1010ab:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
  1010b1:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
  1010b5:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1010b9:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1010bd:	ee                   	out    %al,(%dx)
  1010be:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
  1010c4:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
  1010c8:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1010cc:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1010d0:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  1010d1:	c9                   	leave  
  1010d2:	c3                   	ret    

001010d3 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  1010d3:	55                   	push   %ebp
  1010d4:	89 e5                	mov    %esp,%ebp
  1010d6:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  1010d9:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1010dd:	74 0d                	je     1010ec <lpt_putc+0x19>
        lpt_putc_sub(c);
  1010df:	8b 45 08             	mov    0x8(%ebp),%eax
  1010e2:	89 04 24             	mov    %eax,(%esp)
  1010e5:	e8 70 ff ff ff       	call   10105a <lpt_putc_sub>
  1010ea:	eb 24                	jmp    101110 <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
  1010ec:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1010f3:	e8 62 ff ff ff       	call   10105a <lpt_putc_sub>
        lpt_putc_sub(' ');
  1010f8:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1010ff:	e8 56 ff ff ff       	call   10105a <lpt_putc_sub>
        lpt_putc_sub('\b');
  101104:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10110b:	e8 4a ff ff ff       	call   10105a <lpt_putc_sub>
    }
}
  101110:	c9                   	leave  
  101111:	c3                   	ret    

00101112 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  101112:	55                   	push   %ebp
  101113:	89 e5                	mov    %esp,%ebp
  101115:	53                   	push   %ebx
  101116:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
  101119:	8b 45 08             	mov    0x8(%ebp),%eax
  10111c:	b0 00                	mov    $0x0,%al
  10111e:	85 c0                	test   %eax,%eax
  101120:	75 07                	jne    101129 <cga_putc+0x17>
        c |= 0x0700;
  101122:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  101129:	8b 45 08             	mov    0x8(%ebp),%eax
  10112c:	0f b6 c0             	movzbl %al,%eax
  10112f:	83 f8 0a             	cmp    $0xa,%eax
  101132:	74 4c                	je     101180 <cga_putc+0x6e>
  101134:	83 f8 0d             	cmp    $0xd,%eax
  101137:	74 57                	je     101190 <cga_putc+0x7e>
  101139:	83 f8 08             	cmp    $0x8,%eax
  10113c:	0f 85 88 00 00 00    	jne    1011ca <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
  101142:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  101149:	66 85 c0             	test   %ax,%ax
  10114c:	74 30                	je     10117e <cga_putc+0x6c>
            crt_pos --;
  10114e:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  101155:	83 e8 01             	sub    $0x1,%eax
  101158:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  10115e:	a1 40 a4 11 00       	mov    0x11a440,%eax
  101163:	0f b7 15 44 a4 11 00 	movzwl 0x11a444,%edx
  10116a:	0f b7 d2             	movzwl %dx,%edx
  10116d:	01 d2                	add    %edx,%edx
  10116f:	01 c2                	add    %eax,%edx
  101171:	8b 45 08             	mov    0x8(%ebp),%eax
  101174:	b0 00                	mov    $0x0,%al
  101176:	83 c8 20             	or     $0x20,%eax
  101179:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  10117c:	eb 72                	jmp    1011f0 <cga_putc+0xde>
  10117e:	eb 70                	jmp    1011f0 <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
  101180:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  101187:	83 c0 50             	add    $0x50,%eax
  10118a:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  101190:	0f b7 1d 44 a4 11 00 	movzwl 0x11a444,%ebx
  101197:	0f b7 0d 44 a4 11 00 	movzwl 0x11a444,%ecx
  10119e:	0f b7 c1             	movzwl %cx,%eax
  1011a1:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
  1011a7:	c1 e8 10             	shr    $0x10,%eax
  1011aa:	89 c2                	mov    %eax,%edx
  1011ac:	66 c1 ea 06          	shr    $0x6,%dx
  1011b0:	89 d0                	mov    %edx,%eax
  1011b2:	c1 e0 02             	shl    $0x2,%eax
  1011b5:	01 d0                	add    %edx,%eax
  1011b7:	c1 e0 04             	shl    $0x4,%eax
  1011ba:	29 c1                	sub    %eax,%ecx
  1011bc:	89 ca                	mov    %ecx,%edx
  1011be:	89 d8                	mov    %ebx,%eax
  1011c0:	29 d0                	sub    %edx,%eax
  1011c2:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
        break;
  1011c8:	eb 26                	jmp    1011f0 <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  1011ca:	8b 0d 40 a4 11 00    	mov    0x11a440,%ecx
  1011d0:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  1011d7:	8d 50 01             	lea    0x1(%eax),%edx
  1011da:	66 89 15 44 a4 11 00 	mov    %dx,0x11a444
  1011e1:	0f b7 c0             	movzwl %ax,%eax
  1011e4:	01 c0                	add    %eax,%eax
  1011e6:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  1011e9:	8b 45 08             	mov    0x8(%ebp),%eax
  1011ec:	66 89 02             	mov    %ax,(%edx)
        break;
  1011ef:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  1011f0:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  1011f7:	66 3d cf 07          	cmp    $0x7cf,%ax
  1011fb:	76 5b                	jbe    101258 <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  1011fd:	a1 40 a4 11 00       	mov    0x11a440,%eax
  101202:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  101208:	a1 40 a4 11 00       	mov    0x11a440,%eax
  10120d:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  101214:	00 
  101215:	89 54 24 04          	mov    %edx,0x4(%esp)
  101219:	89 04 24             	mov    %eax,(%esp)
  10121c:	e8 3b 45 00 00       	call   10575c <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101221:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  101228:	eb 15                	jmp    10123f <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
  10122a:	a1 40 a4 11 00       	mov    0x11a440,%eax
  10122f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101232:	01 d2                	add    %edx,%edx
  101234:	01 d0                	add    %edx,%eax
  101236:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  10123b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  10123f:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  101246:	7e e2                	jle    10122a <cga_putc+0x118>
        }
        crt_pos -= CRT_COLS;
  101248:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  10124f:	83 e8 50             	sub    $0x50,%eax
  101252:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  101258:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  10125f:	0f b7 c0             	movzwl %ax,%eax
  101262:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  101266:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
  10126a:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  10126e:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101272:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
  101273:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  10127a:	66 c1 e8 08          	shr    $0x8,%ax
  10127e:	0f b6 c0             	movzbl %al,%eax
  101281:	0f b7 15 46 a4 11 00 	movzwl 0x11a446,%edx
  101288:	83 c2 01             	add    $0x1,%edx
  10128b:	0f b7 d2             	movzwl %dx,%edx
  10128e:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
  101292:	88 45 ed             	mov    %al,-0x13(%ebp)
  101295:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101299:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  10129d:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
  10129e:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  1012a5:	0f b7 c0             	movzwl %ax,%eax
  1012a8:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
  1012ac:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
  1012b0:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  1012b4:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  1012b8:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
  1012b9:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  1012c0:	0f b6 c0             	movzbl %al,%eax
  1012c3:	0f b7 15 46 a4 11 00 	movzwl 0x11a446,%edx
  1012ca:	83 c2 01             	add    $0x1,%edx
  1012cd:	0f b7 d2             	movzwl %dx,%edx
  1012d0:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
  1012d4:	88 45 e5             	mov    %al,-0x1b(%ebp)
  1012d7:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  1012db:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  1012df:	ee                   	out    %al,(%dx)
}
  1012e0:	83 c4 34             	add    $0x34,%esp
  1012e3:	5b                   	pop    %ebx
  1012e4:	5d                   	pop    %ebp
  1012e5:	c3                   	ret    

001012e6 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  1012e6:	55                   	push   %ebp
  1012e7:	89 e5                	mov    %esp,%ebp
  1012e9:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1012ec:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1012f3:	eb 09                	jmp    1012fe <serial_putc_sub+0x18>
        delay();
  1012f5:	e8 4f fb ff ff       	call   100e49 <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1012fa:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  1012fe:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101304:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101308:	89 c2                	mov    %eax,%edx
  10130a:	ec                   	in     (%dx),%al
  10130b:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  10130e:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101312:	0f b6 c0             	movzbl %al,%eax
  101315:	83 e0 20             	and    $0x20,%eax
  101318:	85 c0                	test   %eax,%eax
  10131a:	75 09                	jne    101325 <serial_putc_sub+0x3f>
  10131c:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101323:	7e d0                	jle    1012f5 <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
  101325:	8b 45 08             	mov    0x8(%ebp),%eax
  101328:	0f b6 c0             	movzbl %al,%eax
  10132b:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  101331:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101334:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  101338:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  10133c:	ee                   	out    %al,(%dx)
}
  10133d:	c9                   	leave  
  10133e:	c3                   	ret    

0010133f <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  10133f:	55                   	push   %ebp
  101340:	89 e5                	mov    %esp,%ebp
  101342:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  101345:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  101349:	74 0d                	je     101358 <serial_putc+0x19>
        serial_putc_sub(c);
  10134b:	8b 45 08             	mov    0x8(%ebp),%eax
  10134e:	89 04 24             	mov    %eax,(%esp)
  101351:	e8 90 ff ff ff       	call   1012e6 <serial_putc_sub>
  101356:	eb 24                	jmp    10137c <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
  101358:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10135f:	e8 82 ff ff ff       	call   1012e6 <serial_putc_sub>
        serial_putc_sub(' ');
  101364:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  10136b:	e8 76 ff ff ff       	call   1012e6 <serial_putc_sub>
        serial_putc_sub('\b');
  101370:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101377:	e8 6a ff ff ff       	call   1012e6 <serial_putc_sub>
    }
}
  10137c:	c9                   	leave  
  10137d:	c3                   	ret    

0010137e <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  10137e:	55                   	push   %ebp
  10137f:	89 e5                	mov    %esp,%ebp
  101381:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  101384:	eb 33                	jmp    1013b9 <cons_intr+0x3b>
        if (c != 0) {
  101386:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10138a:	74 2d                	je     1013b9 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  10138c:	a1 64 a6 11 00       	mov    0x11a664,%eax
  101391:	8d 50 01             	lea    0x1(%eax),%edx
  101394:	89 15 64 a6 11 00    	mov    %edx,0x11a664
  10139a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10139d:	88 90 60 a4 11 00    	mov    %dl,0x11a460(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  1013a3:	a1 64 a6 11 00       	mov    0x11a664,%eax
  1013a8:	3d 00 02 00 00       	cmp    $0x200,%eax
  1013ad:	75 0a                	jne    1013b9 <cons_intr+0x3b>
                cons.wpos = 0;
  1013af:	c7 05 64 a6 11 00 00 	movl   $0x0,0x11a664
  1013b6:	00 00 00 
    while ((c = (*proc)()) != -1) {
  1013b9:	8b 45 08             	mov    0x8(%ebp),%eax
  1013bc:	ff d0                	call   *%eax
  1013be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1013c1:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  1013c5:	75 bf                	jne    101386 <cons_intr+0x8>
            }
        }
    }
}
  1013c7:	c9                   	leave  
  1013c8:	c3                   	ret    

001013c9 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  1013c9:	55                   	push   %ebp
  1013ca:	89 e5                	mov    %esp,%ebp
  1013cc:	83 ec 10             	sub    $0x10,%esp
  1013cf:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1013d5:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1013d9:	89 c2                	mov    %eax,%edx
  1013db:	ec                   	in     (%dx),%al
  1013dc:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  1013df:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  1013e3:	0f b6 c0             	movzbl %al,%eax
  1013e6:	83 e0 01             	and    $0x1,%eax
  1013e9:	85 c0                	test   %eax,%eax
  1013eb:	75 07                	jne    1013f4 <serial_proc_data+0x2b>
        return -1;
  1013ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1013f2:	eb 2a                	jmp    10141e <serial_proc_data+0x55>
  1013f4:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1013fa:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  1013fe:	89 c2                	mov    %eax,%edx
  101400:	ec                   	in     (%dx),%al
  101401:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
  101404:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  101408:	0f b6 c0             	movzbl %al,%eax
  10140b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  10140e:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  101412:	75 07                	jne    10141b <serial_proc_data+0x52>
        c = '\b';
  101414:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  10141b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10141e:	c9                   	leave  
  10141f:	c3                   	ret    

00101420 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  101420:	55                   	push   %ebp
  101421:	89 e5                	mov    %esp,%ebp
  101423:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  101426:	a1 48 a4 11 00       	mov    0x11a448,%eax
  10142b:	85 c0                	test   %eax,%eax
  10142d:	74 0c                	je     10143b <serial_intr+0x1b>
        cons_intr(serial_proc_data);
  10142f:	c7 04 24 c9 13 10 00 	movl   $0x1013c9,(%esp)
  101436:	e8 43 ff ff ff       	call   10137e <cons_intr>
    }
}
  10143b:	c9                   	leave  
  10143c:	c3                   	ret    

0010143d <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  10143d:	55                   	push   %ebp
  10143e:	89 e5                	mov    %esp,%ebp
  101440:	83 ec 38             	sub    $0x38,%esp
  101443:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101449:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  10144d:	89 c2                	mov    %eax,%edx
  10144f:	ec                   	in     (%dx),%al
  101450:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
  101453:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  101457:	0f b6 c0             	movzbl %al,%eax
  10145a:	83 e0 01             	and    $0x1,%eax
  10145d:	85 c0                	test   %eax,%eax
  10145f:	75 0a                	jne    10146b <kbd_proc_data+0x2e>
        return -1;
  101461:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  101466:	e9 59 01 00 00       	jmp    1015c4 <kbd_proc_data+0x187>
  10146b:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101471:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101475:	89 c2                	mov    %eax,%edx
  101477:	ec                   	in     (%dx),%al
  101478:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  10147b:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
  10147f:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  101482:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  101486:	75 17                	jne    10149f <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
  101488:	a1 68 a6 11 00       	mov    0x11a668,%eax
  10148d:	83 c8 40             	or     $0x40,%eax
  101490:	a3 68 a6 11 00       	mov    %eax,0x11a668
        return 0;
  101495:	b8 00 00 00 00       	mov    $0x0,%eax
  10149a:	e9 25 01 00 00       	jmp    1015c4 <kbd_proc_data+0x187>
    } else if (data & 0x80) {
  10149f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014a3:	84 c0                	test   %al,%al
  1014a5:	79 47                	jns    1014ee <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  1014a7:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1014ac:	83 e0 40             	and    $0x40,%eax
  1014af:	85 c0                	test   %eax,%eax
  1014b1:	75 09                	jne    1014bc <kbd_proc_data+0x7f>
  1014b3:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014b7:	83 e0 7f             	and    $0x7f,%eax
  1014ba:	eb 04                	jmp    1014c0 <kbd_proc_data+0x83>
  1014bc:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014c0:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  1014c3:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014c7:	0f b6 80 40 70 11 00 	movzbl 0x117040(%eax),%eax
  1014ce:	83 c8 40             	or     $0x40,%eax
  1014d1:	0f b6 c0             	movzbl %al,%eax
  1014d4:	f7 d0                	not    %eax
  1014d6:	89 c2                	mov    %eax,%edx
  1014d8:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1014dd:	21 d0                	and    %edx,%eax
  1014df:	a3 68 a6 11 00       	mov    %eax,0x11a668
        return 0;
  1014e4:	b8 00 00 00 00       	mov    $0x0,%eax
  1014e9:	e9 d6 00 00 00       	jmp    1015c4 <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
  1014ee:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1014f3:	83 e0 40             	and    $0x40,%eax
  1014f6:	85 c0                	test   %eax,%eax
  1014f8:	74 11                	je     10150b <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  1014fa:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  1014fe:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101503:	83 e0 bf             	and    $0xffffffbf,%eax
  101506:	a3 68 a6 11 00       	mov    %eax,0x11a668
    }

    shift |= shiftcode[data];
  10150b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10150f:	0f b6 80 40 70 11 00 	movzbl 0x117040(%eax),%eax
  101516:	0f b6 d0             	movzbl %al,%edx
  101519:	a1 68 a6 11 00       	mov    0x11a668,%eax
  10151e:	09 d0                	or     %edx,%eax
  101520:	a3 68 a6 11 00       	mov    %eax,0x11a668
    shift ^= togglecode[data];
  101525:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101529:	0f b6 80 40 71 11 00 	movzbl 0x117140(%eax),%eax
  101530:	0f b6 d0             	movzbl %al,%edx
  101533:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101538:	31 d0                	xor    %edx,%eax
  10153a:	a3 68 a6 11 00       	mov    %eax,0x11a668

    c = charcode[shift & (CTL | SHIFT)][data];
  10153f:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101544:	83 e0 03             	and    $0x3,%eax
  101547:	8b 14 85 40 75 11 00 	mov    0x117540(,%eax,4),%edx
  10154e:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101552:	01 d0                	add    %edx,%eax
  101554:	0f b6 00             	movzbl (%eax),%eax
  101557:	0f b6 c0             	movzbl %al,%eax
  10155a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  10155d:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101562:	83 e0 08             	and    $0x8,%eax
  101565:	85 c0                	test   %eax,%eax
  101567:	74 22                	je     10158b <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
  101569:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  10156d:	7e 0c                	jle    10157b <kbd_proc_data+0x13e>
  10156f:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  101573:	7f 06                	jg     10157b <kbd_proc_data+0x13e>
            c += 'A' - 'a';
  101575:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  101579:	eb 10                	jmp    10158b <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
  10157b:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  10157f:	7e 0a                	jle    10158b <kbd_proc_data+0x14e>
  101581:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  101585:	7f 04                	jg     10158b <kbd_proc_data+0x14e>
            c += 'a' - 'A';
  101587:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  10158b:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101590:	f7 d0                	not    %eax
  101592:	83 e0 06             	and    $0x6,%eax
  101595:	85 c0                	test   %eax,%eax
  101597:	75 28                	jne    1015c1 <kbd_proc_data+0x184>
  101599:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  1015a0:	75 1f                	jne    1015c1 <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
  1015a2:	c7 04 24 85 62 10 00 	movl   $0x106285,(%esp)
  1015a9:	e8 e4 ec ff ff       	call   100292 <cprintf>
  1015ae:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
  1015b4:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1015b8:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  1015bc:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
  1015c0:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  1015c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1015c4:	c9                   	leave  
  1015c5:	c3                   	ret    

001015c6 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  1015c6:	55                   	push   %ebp
  1015c7:	89 e5                	mov    %esp,%ebp
  1015c9:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  1015cc:	c7 04 24 3d 14 10 00 	movl   $0x10143d,(%esp)
  1015d3:	e8 a6 fd ff ff       	call   10137e <cons_intr>
}
  1015d8:	c9                   	leave  
  1015d9:	c3                   	ret    

001015da <kbd_init>:

static void
kbd_init(void) {
  1015da:	55                   	push   %ebp
  1015db:	89 e5                	mov    %esp,%ebp
  1015dd:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  1015e0:	e8 e1 ff ff ff       	call   1015c6 <kbd_intr>
    pic_enable(IRQ_KBD);
  1015e5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1015ec:	e8 31 01 00 00       	call   101722 <pic_enable>
}
  1015f1:	c9                   	leave  
  1015f2:	c3                   	ret    

001015f3 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  1015f3:	55                   	push   %ebp
  1015f4:	89 e5                	mov    %esp,%ebp
  1015f6:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  1015f9:	e8 93 f8 ff ff       	call   100e91 <cga_init>
    serial_init();
  1015fe:	e8 74 f9 ff ff       	call   100f77 <serial_init>
    kbd_init();
  101603:	e8 d2 ff ff ff       	call   1015da <kbd_init>
    if (!serial_exists) {
  101608:	a1 48 a4 11 00       	mov    0x11a448,%eax
  10160d:	85 c0                	test   %eax,%eax
  10160f:	75 0c                	jne    10161d <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  101611:	c7 04 24 91 62 10 00 	movl   $0x106291,(%esp)
  101618:	e8 75 ec ff ff       	call   100292 <cprintf>
    }
}
  10161d:	c9                   	leave  
  10161e:	c3                   	ret    

0010161f <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  10161f:	55                   	push   %ebp
  101620:	89 e5                	mov    %esp,%ebp
  101622:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  101625:	e8 e2 f7 ff ff       	call   100e0c <__intr_save>
  10162a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
  10162d:	8b 45 08             	mov    0x8(%ebp),%eax
  101630:	89 04 24             	mov    %eax,(%esp)
  101633:	e8 9b fa ff ff       	call   1010d3 <lpt_putc>
        cga_putc(c);
  101638:	8b 45 08             	mov    0x8(%ebp),%eax
  10163b:	89 04 24             	mov    %eax,(%esp)
  10163e:	e8 cf fa ff ff       	call   101112 <cga_putc>
        serial_putc(c);
  101643:	8b 45 08             	mov    0x8(%ebp),%eax
  101646:	89 04 24             	mov    %eax,(%esp)
  101649:	e8 f1 fc ff ff       	call   10133f <serial_putc>
    }
    local_intr_restore(intr_flag);
  10164e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101651:	89 04 24             	mov    %eax,(%esp)
  101654:	e8 dd f7 ff ff       	call   100e36 <__intr_restore>
}
  101659:	c9                   	leave  
  10165a:	c3                   	ret    

0010165b <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  10165b:	55                   	push   %ebp
  10165c:	89 e5                	mov    %esp,%ebp
  10165e:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
  101661:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  101668:	e8 9f f7 ff ff       	call   100e0c <__intr_save>
  10166d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
  101670:	e8 ab fd ff ff       	call   101420 <serial_intr>
        kbd_intr();
  101675:	e8 4c ff ff ff       	call   1015c6 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
  10167a:	8b 15 60 a6 11 00    	mov    0x11a660,%edx
  101680:	a1 64 a6 11 00       	mov    0x11a664,%eax
  101685:	39 c2                	cmp    %eax,%edx
  101687:	74 31                	je     1016ba <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
  101689:	a1 60 a6 11 00       	mov    0x11a660,%eax
  10168e:	8d 50 01             	lea    0x1(%eax),%edx
  101691:	89 15 60 a6 11 00    	mov    %edx,0x11a660
  101697:	0f b6 80 60 a4 11 00 	movzbl 0x11a460(%eax),%eax
  10169e:	0f b6 c0             	movzbl %al,%eax
  1016a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
  1016a4:	a1 60 a6 11 00       	mov    0x11a660,%eax
  1016a9:	3d 00 02 00 00       	cmp    $0x200,%eax
  1016ae:	75 0a                	jne    1016ba <cons_getc+0x5f>
                cons.rpos = 0;
  1016b0:	c7 05 60 a6 11 00 00 	movl   $0x0,0x11a660
  1016b7:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
  1016ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1016bd:	89 04 24             	mov    %eax,(%esp)
  1016c0:	e8 71 f7 ff ff       	call   100e36 <__intr_restore>
    return c;
  1016c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1016c8:	c9                   	leave  
  1016c9:	c3                   	ret    

001016ca <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  1016ca:	55                   	push   %ebp
  1016cb:	89 e5                	mov    %esp,%ebp
  1016cd:	83 ec 14             	sub    $0x14,%esp
  1016d0:	8b 45 08             	mov    0x8(%ebp),%eax
  1016d3:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  1016d7:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  1016db:	66 a3 50 75 11 00    	mov    %ax,0x117550
    if (did_init) {
  1016e1:	a1 6c a6 11 00       	mov    0x11a66c,%eax
  1016e6:	85 c0                	test   %eax,%eax
  1016e8:	74 36                	je     101720 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
  1016ea:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  1016ee:	0f b6 c0             	movzbl %al,%eax
  1016f1:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  1016f7:	88 45 fd             	mov    %al,-0x3(%ebp)
  1016fa:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  1016fe:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101702:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
  101703:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101707:	66 c1 e8 08          	shr    $0x8,%ax
  10170b:	0f b6 c0             	movzbl %al,%eax
  10170e:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
  101714:	88 45 f9             	mov    %al,-0x7(%ebp)
  101717:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  10171b:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  10171f:	ee                   	out    %al,(%dx)
    }
}
  101720:	c9                   	leave  
  101721:	c3                   	ret    

00101722 <pic_enable>:

void
pic_enable(unsigned int irq) {
  101722:	55                   	push   %ebp
  101723:	89 e5                	mov    %esp,%ebp
  101725:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  101728:	8b 45 08             	mov    0x8(%ebp),%eax
  10172b:	ba 01 00 00 00       	mov    $0x1,%edx
  101730:	89 c1                	mov    %eax,%ecx
  101732:	d3 e2                	shl    %cl,%edx
  101734:	89 d0                	mov    %edx,%eax
  101736:	f7 d0                	not    %eax
  101738:	89 c2                	mov    %eax,%edx
  10173a:	0f b7 05 50 75 11 00 	movzwl 0x117550,%eax
  101741:	21 d0                	and    %edx,%eax
  101743:	0f b7 c0             	movzwl %ax,%eax
  101746:	89 04 24             	mov    %eax,(%esp)
  101749:	e8 7c ff ff ff       	call   1016ca <pic_setmask>
}
  10174e:	c9                   	leave  
  10174f:	c3                   	ret    

00101750 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  101750:	55                   	push   %ebp
  101751:	89 e5                	mov    %esp,%ebp
  101753:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
  101756:	c7 05 6c a6 11 00 01 	movl   $0x1,0x11a66c
  10175d:	00 00 00 
  101760:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  101766:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
  10176a:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  10176e:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101772:	ee                   	out    %al,(%dx)
  101773:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
  101779:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
  10177d:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101781:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101785:	ee                   	out    %al,(%dx)
  101786:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
  10178c:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
  101790:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  101794:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101798:	ee                   	out    %al,(%dx)
  101799:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
  10179f:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
  1017a3:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1017a7:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1017ab:	ee                   	out    %al,(%dx)
  1017ac:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
  1017b2:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
  1017b6:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1017ba:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1017be:	ee                   	out    %al,(%dx)
  1017bf:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
  1017c5:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
  1017c9:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  1017cd:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  1017d1:	ee                   	out    %al,(%dx)
  1017d2:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
  1017d8:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
  1017dc:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  1017e0:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  1017e4:	ee                   	out    %al,(%dx)
  1017e5:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
  1017eb:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
  1017ef:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  1017f3:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  1017f7:	ee                   	out    %al,(%dx)
  1017f8:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
  1017fe:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
  101802:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  101806:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  10180a:	ee                   	out    %al,(%dx)
  10180b:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
  101811:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
  101815:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  101819:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  10181d:	ee                   	out    %al,(%dx)
  10181e:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
  101824:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
  101828:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  10182c:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  101830:	ee                   	out    %al,(%dx)
  101831:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
  101837:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
  10183b:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  10183f:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  101843:	ee                   	out    %al,(%dx)
  101844:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
  10184a:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
  10184e:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
  101852:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
  101856:	ee                   	out    %al,(%dx)
  101857:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
  10185d:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
  101861:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
  101865:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
  101869:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  10186a:	0f b7 05 50 75 11 00 	movzwl 0x117550,%eax
  101871:	66 83 f8 ff          	cmp    $0xffff,%ax
  101875:	74 12                	je     101889 <pic_init+0x139>
        pic_setmask(irq_mask);
  101877:	0f b7 05 50 75 11 00 	movzwl 0x117550,%eax
  10187e:	0f b7 c0             	movzwl %ax,%eax
  101881:	89 04 24             	mov    %eax,(%esp)
  101884:	e8 41 fe ff ff       	call   1016ca <pic_setmask>
    }
}
  101889:	c9                   	leave  
  10188a:	c3                   	ret    

0010188b <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  10188b:	55                   	push   %ebp
  10188c:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
  10188e:	fb                   	sti    
    sti();
}
  10188f:	5d                   	pop    %ebp
  101890:	c3                   	ret    

00101891 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  101891:	55                   	push   %ebp
  101892:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
  101894:	fa                   	cli    
    cli();
}
  101895:	5d                   	pop    %ebp
  101896:	c3                   	ret    

00101897 <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
  101897:	55                   	push   %ebp
  101898:	89 e5                	mov    %esp,%ebp
  10189a:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
  10189d:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  1018a4:	00 
  1018a5:	c7 04 24 c0 62 10 00 	movl   $0x1062c0,(%esp)
  1018ac:	e8 e1 e9 ff ff       	call   100292 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
  1018b1:	c7 04 24 ca 62 10 00 	movl   $0x1062ca,(%esp)
  1018b8:	e8 d5 e9 ff ff       	call   100292 <cprintf>
    panic("EOT: kernel seems ok.");
  1018bd:	c7 44 24 08 d8 62 10 	movl   $0x1062d8,0x8(%esp)
  1018c4:	00 
  1018c5:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  1018cc:	00 
  1018cd:	c7 04 24 ee 62 10 00 	movl   $0x1062ee,(%esp)
  1018d4:	e8 10 eb ff ff       	call   1003e9 <__panic>

001018d9 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  1018d9:	55                   	push   %ebp
  1018da:	89 e5                	mov    %esp,%ebp
  1018dc:	83 ec 10             	sub    $0x10,%esp
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];  //保存在vectors.S中的256个中断处理例程的入口地址数组
    int i;
    //使用SETGATE宏，初始化IDT每个表项
    for (i = 0; i < 256; i ++) 
  1018df:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1018e6:	e9 c3 00 00 00       	jmp    1019ae <idt_init+0xd5>
    { 
    //在中断门描述符表中通过建立中断门描述符，其中存储了中断处理例程的代码段GD_KTEXT和偏移量__vectors[i]
    //特权级为DPL_KERNEL, 通过查询idt[i]就可定位到中断服务例程的起始地址。
     SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
  1018eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018ee:	8b 04 85 e0 75 11 00 	mov    0x1175e0(,%eax,4),%eax
  1018f5:	89 c2                	mov    %eax,%edx
  1018f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018fa:	66 89 14 c5 80 a6 11 	mov    %dx,0x11a680(,%eax,8)
  101901:	00 
  101902:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101905:	66 c7 04 c5 82 a6 11 	movw   $0x8,0x11a682(,%eax,8)
  10190c:	00 08 00 
  10190f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101912:	0f b6 14 c5 84 a6 11 	movzbl 0x11a684(,%eax,8),%edx
  101919:	00 
  10191a:	83 e2 e0             	and    $0xffffffe0,%edx
  10191d:	88 14 c5 84 a6 11 00 	mov    %dl,0x11a684(,%eax,8)
  101924:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101927:	0f b6 14 c5 84 a6 11 	movzbl 0x11a684(,%eax,8),%edx
  10192e:	00 
  10192f:	83 e2 1f             	and    $0x1f,%edx
  101932:	88 14 c5 84 a6 11 00 	mov    %dl,0x11a684(,%eax,8)
  101939:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10193c:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  101943:	00 
  101944:	83 e2 f0             	and    $0xfffffff0,%edx
  101947:	83 ca 0e             	or     $0xe,%edx
  10194a:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  101951:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101954:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  10195b:	00 
  10195c:	83 e2 ef             	and    $0xffffffef,%edx
  10195f:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  101966:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101969:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  101970:	00 
  101971:	83 e2 9f             	and    $0xffffff9f,%edx
  101974:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  10197b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10197e:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  101985:	00 
  101986:	83 ca 80             	or     $0xffffff80,%edx
  101989:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  101990:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101993:	8b 04 85 e0 75 11 00 	mov    0x1175e0(,%eax,4),%eax
  10199a:	c1 e8 10             	shr    $0x10,%eax
  10199d:	89 c2                	mov    %eax,%edx
  10199f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019a2:	66 89 14 c5 86 a6 11 	mov    %dx,0x11a686(,%eax,8)
  1019a9:	00 
    for (i = 0; i < 256; i ++) 
  1019aa:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  1019ae:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
  1019b5:	0f 8e 30 ff ff ff    	jle    1018eb <idt_init+0x12>
    }
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT,__vectors[T_SWITCH_TOK], DPL_USER);
  1019bb:	a1 c4 77 11 00       	mov    0x1177c4,%eax
  1019c0:	66 a3 48 aa 11 00    	mov    %ax,0x11aa48
  1019c6:	66 c7 05 4a aa 11 00 	movw   $0x8,0x11aa4a
  1019cd:	08 00 
  1019cf:	0f b6 05 4c aa 11 00 	movzbl 0x11aa4c,%eax
  1019d6:	83 e0 e0             	and    $0xffffffe0,%eax
  1019d9:	a2 4c aa 11 00       	mov    %al,0x11aa4c
  1019de:	0f b6 05 4c aa 11 00 	movzbl 0x11aa4c,%eax
  1019e5:	83 e0 1f             	and    $0x1f,%eax
  1019e8:	a2 4c aa 11 00       	mov    %al,0x11aa4c
  1019ed:	0f b6 05 4d aa 11 00 	movzbl 0x11aa4d,%eax
  1019f4:	83 e0 f0             	and    $0xfffffff0,%eax
  1019f7:	83 c8 0e             	or     $0xe,%eax
  1019fa:	a2 4d aa 11 00       	mov    %al,0x11aa4d
  1019ff:	0f b6 05 4d aa 11 00 	movzbl 0x11aa4d,%eax
  101a06:	83 e0 ef             	and    $0xffffffef,%eax
  101a09:	a2 4d aa 11 00       	mov    %al,0x11aa4d
  101a0e:	0f b6 05 4d aa 11 00 	movzbl 0x11aa4d,%eax
  101a15:	83 c8 60             	or     $0x60,%eax
  101a18:	a2 4d aa 11 00       	mov    %al,0x11aa4d
  101a1d:	0f b6 05 4d aa 11 00 	movzbl 0x11aa4d,%eax
  101a24:	83 c8 80             	or     $0xffffff80,%eax
  101a27:	a2 4d aa 11 00       	mov    %al,0x11aa4d
  101a2c:	a1 c4 77 11 00       	mov    0x1177c4,%eax
  101a31:	c1 e8 10             	shr    $0x10,%eax
  101a34:	66 a3 4e aa 11 00    	mov    %ax,0x11aa4e
  101a3a:	c7 45 f8 60 75 11 00 	movl   $0x117560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
  101a41:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101a44:	0f 01 18             	lidtl  (%eax)
     //指令lidt把中断门描述符表的起始地址装入IDTR寄存器
    lidt(&idt_pd);
}
  101a47:	c9                   	leave  
  101a48:	c3                   	ret    

00101a49 <trapname>:

static const char *
trapname(int trapno) {
  101a49:	55                   	push   %ebp
  101a4a:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  101a4c:	8b 45 08             	mov    0x8(%ebp),%eax
  101a4f:	83 f8 13             	cmp    $0x13,%eax
  101a52:	77 0c                	ja     101a60 <trapname+0x17>
        return excnames[trapno];
  101a54:	8b 45 08             	mov    0x8(%ebp),%eax
  101a57:	8b 04 85 40 66 10 00 	mov    0x106640(,%eax,4),%eax
  101a5e:	eb 18                	jmp    101a78 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  101a60:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  101a64:	7e 0d                	jle    101a73 <trapname+0x2a>
  101a66:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  101a6a:	7f 07                	jg     101a73 <trapname+0x2a>
        return "Hardware Interrupt";
  101a6c:	b8 ff 62 10 00       	mov    $0x1062ff,%eax
  101a71:	eb 05                	jmp    101a78 <trapname+0x2f>
    }
    return "(unknown trap)";
  101a73:	b8 12 63 10 00       	mov    $0x106312,%eax
}
  101a78:	5d                   	pop    %ebp
  101a79:	c3                   	ret    

00101a7a <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  101a7a:	55                   	push   %ebp
  101a7b:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  101a7d:	8b 45 08             	mov    0x8(%ebp),%eax
  101a80:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101a84:	66 83 f8 08          	cmp    $0x8,%ax
  101a88:	0f 94 c0             	sete   %al
  101a8b:	0f b6 c0             	movzbl %al,%eax
}
  101a8e:	5d                   	pop    %ebp
  101a8f:	c3                   	ret    

00101a90 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  101a90:	55                   	push   %ebp
  101a91:	89 e5                	mov    %esp,%ebp
  101a93:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  101a96:	8b 45 08             	mov    0x8(%ebp),%eax
  101a99:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a9d:	c7 04 24 53 63 10 00 	movl   $0x106353,(%esp)
  101aa4:	e8 e9 e7 ff ff       	call   100292 <cprintf>
    print_regs(&tf->tf_regs);
  101aa9:	8b 45 08             	mov    0x8(%ebp),%eax
  101aac:	89 04 24             	mov    %eax,(%esp)
  101aaf:	e8 a1 01 00 00       	call   101c55 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  101ab7:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101abb:	0f b7 c0             	movzwl %ax,%eax
  101abe:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ac2:	c7 04 24 64 63 10 00 	movl   $0x106364,(%esp)
  101ac9:	e8 c4 e7 ff ff       	call   100292 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101ace:	8b 45 08             	mov    0x8(%ebp),%eax
  101ad1:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101ad5:	0f b7 c0             	movzwl %ax,%eax
  101ad8:	89 44 24 04          	mov    %eax,0x4(%esp)
  101adc:	c7 04 24 77 63 10 00 	movl   $0x106377,(%esp)
  101ae3:	e8 aa e7 ff ff       	call   100292 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101ae8:	8b 45 08             	mov    0x8(%ebp),%eax
  101aeb:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101aef:	0f b7 c0             	movzwl %ax,%eax
  101af2:	89 44 24 04          	mov    %eax,0x4(%esp)
  101af6:	c7 04 24 8a 63 10 00 	movl   $0x10638a,(%esp)
  101afd:	e8 90 e7 ff ff       	call   100292 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101b02:	8b 45 08             	mov    0x8(%ebp),%eax
  101b05:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101b09:	0f b7 c0             	movzwl %ax,%eax
  101b0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b10:	c7 04 24 9d 63 10 00 	movl   $0x10639d,(%esp)
  101b17:	e8 76 e7 ff ff       	call   100292 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101b1c:	8b 45 08             	mov    0x8(%ebp),%eax
  101b1f:	8b 40 30             	mov    0x30(%eax),%eax
  101b22:	89 04 24             	mov    %eax,(%esp)
  101b25:	e8 1f ff ff ff       	call   101a49 <trapname>
  101b2a:	8b 55 08             	mov    0x8(%ebp),%edx
  101b2d:	8b 52 30             	mov    0x30(%edx),%edx
  101b30:	89 44 24 08          	mov    %eax,0x8(%esp)
  101b34:	89 54 24 04          	mov    %edx,0x4(%esp)
  101b38:	c7 04 24 b0 63 10 00 	movl   $0x1063b0,(%esp)
  101b3f:	e8 4e e7 ff ff       	call   100292 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101b44:	8b 45 08             	mov    0x8(%ebp),%eax
  101b47:	8b 40 34             	mov    0x34(%eax),%eax
  101b4a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b4e:	c7 04 24 c2 63 10 00 	movl   $0x1063c2,(%esp)
  101b55:	e8 38 e7 ff ff       	call   100292 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101b5a:	8b 45 08             	mov    0x8(%ebp),%eax
  101b5d:	8b 40 38             	mov    0x38(%eax),%eax
  101b60:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b64:	c7 04 24 d1 63 10 00 	movl   $0x1063d1,(%esp)
  101b6b:	e8 22 e7 ff ff       	call   100292 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101b70:	8b 45 08             	mov    0x8(%ebp),%eax
  101b73:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101b77:	0f b7 c0             	movzwl %ax,%eax
  101b7a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b7e:	c7 04 24 e0 63 10 00 	movl   $0x1063e0,(%esp)
  101b85:	e8 08 e7 ff ff       	call   100292 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101b8a:	8b 45 08             	mov    0x8(%ebp),%eax
  101b8d:	8b 40 40             	mov    0x40(%eax),%eax
  101b90:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b94:	c7 04 24 f3 63 10 00 	movl   $0x1063f3,(%esp)
  101b9b:	e8 f2 e6 ff ff       	call   100292 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101ba0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101ba7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101bae:	eb 3e                	jmp    101bee <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101bb0:	8b 45 08             	mov    0x8(%ebp),%eax
  101bb3:	8b 50 40             	mov    0x40(%eax),%edx
  101bb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101bb9:	21 d0                	and    %edx,%eax
  101bbb:	85 c0                	test   %eax,%eax
  101bbd:	74 28                	je     101be7 <print_trapframe+0x157>
  101bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101bc2:	8b 04 85 80 75 11 00 	mov    0x117580(,%eax,4),%eax
  101bc9:	85 c0                	test   %eax,%eax
  101bcb:	74 1a                	je     101be7 <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
  101bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101bd0:	8b 04 85 80 75 11 00 	mov    0x117580(,%eax,4),%eax
  101bd7:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bdb:	c7 04 24 02 64 10 00 	movl   $0x106402,(%esp)
  101be2:	e8 ab e6 ff ff       	call   100292 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101be7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  101beb:	d1 65 f0             	shll   -0x10(%ebp)
  101bee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101bf1:	83 f8 17             	cmp    $0x17,%eax
  101bf4:	76 ba                	jbe    101bb0 <print_trapframe+0x120>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101bf6:	8b 45 08             	mov    0x8(%ebp),%eax
  101bf9:	8b 40 40             	mov    0x40(%eax),%eax
  101bfc:	25 00 30 00 00       	and    $0x3000,%eax
  101c01:	c1 e8 0c             	shr    $0xc,%eax
  101c04:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c08:	c7 04 24 06 64 10 00 	movl   $0x106406,(%esp)
  101c0f:	e8 7e e6 ff ff       	call   100292 <cprintf>

    if (!trap_in_kernel(tf)) {
  101c14:	8b 45 08             	mov    0x8(%ebp),%eax
  101c17:	89 04 24             	mov    %eax,(%esp)
  101c1a:	e8 5b fe ff ff       	call   101a7a <trap_in_kernel>
  101c1f:	85 c0                	test   %eax,%eax
  101c21:	75 30                	jne    101c53 <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101c23:	8b 45 08             	mov    0x8(%ebp),%eax
  101c26:	8b 40 44             	mov    0x44(%eax),%eax
  101c29:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c2d:	c7 04 24 0f 64 10 00 	movl   $0x10640f,(%esp)
  101c34:	e8 59 e6 ff ff       	call   100292 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101c39:	8b 45 08             	mov    0x8(%ebp),%eax
  101c3c:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101c40:	0f b7 c0             	movzwl %ax,%eax
  101c43:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c47:	c7 04 24 1e 64 10 00 	movl   $0x10641e,(%esp)
  101c4e:	e8 3f e6 ff ff       	call   100292 <cprintf>
    }
}
  101c53:	c9                   	leave  
  101c54:	c3                   	ret    

00101c55 <print_regs>:

void
print_regs(struct pushregs *regs) {
  101c55:	55                   	push   %ebp
  101c56:	89 e5                	mov    %esp,%ebp
  101c58:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101c5b:	8b 45 08             	mov    0x8(%ebp),%eax
  101c5e:	8b 00                	mov    (%eax),%eax
  101c60:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c64:	c7 04 24 31 64 10 00 	movl   $0x106431,(%esp)
  101c6b:	e8 22 e6 ff ff       	call   100292 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101c70:	8b 45 08             	mov    0x8(%ebp),%eax
  101c73:	8b 40 04             	mov    0x4(%eax),%eax
  101c76:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c7a:	c7 04 24 40 64 10 00 	movl   $0x106440,(%esp)
  101c81:	e8 0c e6 ff ff       	call   100292 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101c86:	8b 45 08             	mov    0x8(%ebp),%eax
  101c89:	8b 40 08             	mov    0x8(%eax),%eax
  101c8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c90:	c7 04 24 4f 64 10 00 	movl   $0x10644f,(%esp)
  101c97:	e8 f6 e5 ff ff       	call   100292 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101c9c:	8b 45 08             	mov    0x8(%ebp),%eax
  101c9f:	8b 40 0c             	mov    0xc(%eax),%eax
  101ca2:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ca6:	c7 04 24 5e 64 10 00 	movl   $0x10645e,(%esp)
  101cad:	e8 e0 e5 ff ff       	call   100292 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101cb2:	8b 45 08             	mov    0x8(%ebp),%eax
  101cb5:	8b 40 10             	mov    0x10(%eax),%eax
  101cb8:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cbc:	c7 04 24 6d 64 10 00 	movl   $0x10646d,(%esp)
  101cc3:	e8 ca e5 ff ff       	call   100292 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101cc8:	8b 45 08             	mov    0x8(%ebp),%eax
  101ccb:	8b 40 14             	mov    0x14(%eax),%eax
  101cce:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cd2:	c7 04 24 7c 64 10 00 	movl   $0x10647c,(%esp)
  101cd9:	e8 b4 e5 ff ff       	call   100292 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101cde:	8b 45 08             	mov    0x8(%ebp),%eax
  101ce1:	8b 40 18             	mov    0x18(%eax),%eax
  101ce4:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ce8:	c7 04 24 8b 64 10 00 	movl   $0x10648b,(%esp)
  101cef:	e8 9e e5 ff ff       	call   100292 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101cf4:	8b 45 08             	mov    0x8(%ebp),%eax
  101cf7:	8b 40 1c             	mov    0x1c(%eax),%eax
  101cfa:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cfe:	c7 04 24 9a 64 10 00 	movl   $0x10649a,(%esp)
  101d05:	e8 88 e5 ff ff       	call   100292 <cprintf>
}
  101d0a:	c9                   	leave  
  101d0b:	c3                   	ret    

00101d0c <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101d0c:	55                   	push   %ebp
  101d0d:	89 e5                	mov    %esp,%ebp
  101d0f:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
  101d12:	8b 45 08             	mov    0x8(%ebp),%eax
  101d15:	8b 40 30             	mov    0x30(%eax),%eax
  101d18:	83 f8 2f             	cmp    $0x2f,%eax
  101d1b:	77 21                	ja     101d3e <trap_dispatch+0x32>
  101d1d:	83 f8 2e             	cmp    $0x2e,%eax
  101d20:	0f 83 0b 01 00 00    	jae    101e31 <trap_dispatch+0x125>
  101d26:	83 f8 21             	cmp    $0x21,%eax
  101d29:	0f 84 88 00 00 00    	je     101db7 <trap_dispatch+0xab>
  101d2f:	83 f8 24             	cmp    $0x24,%eax
  101d32:	74 5d                	je     101d91 <trap_dispatch+0x85>
  101d34:	83 f8 20             	cmp    $0x20,%eax
  101d37:	74 16                	je     101d4f <trap_dispatch+0x43>
  101d39:	e9 bb 00 00 00       	jmp    101df9 <trap_dispatch+0xed>
  101d3e:	83 e8 78             	sub    $0x78,%eax
  101d41:	83 f8 01             	cmp    $0x1,%eax
  101d44:	0f 87 af 00 00 00    	ja     101df9 <trap_dispatch+0xed>
  101d4a:	e9 8e 00 00 00       	jmp    101ddd <trap_dispatch+0xd1>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
	    if (((++ticks) % TICK_NUM) == 0) {
  101d4f:	a1 0c af 11 00       	mov    0x11af0c,%eax
  101d54:	83 c0 01             	add    $0x1,%eax
  101d57:	89 c1                	mov    %eax,%ecx
  101d59:	89 0d 0c af 11 00    	mov    %ecx,0x11af0c
  101d5f:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101d64:	89 c8                	mov    %ecx,%eax
  101d66:	f7 e2                	mul    %edx
  101d68:	89 d0                	mov    %edx,%eax
  101d6a:	c1 e8 05             	shr    $0x5,%eax
  101d6d:	6b c0 64             	imul   $0x64,%eax,%eax
  101d70:	29 c1                	sub    %eax,%ecx
  101d72:	89 c8                	mov    %ecx,%eax
  101d74:	85 c0                	test   %eax,%eax
  101d76:	75 14                	jne    101d8c <trap_dispatch+0x80>
		print_ticks();
  101d78:	e8 1a fb ff ff       	call   101897 <print_ticks>
		ticks = 0;
  101d7d:	c7 05 0c af 11 00 00 	movl   $0x0,0x11af0c
  101d84:	00 00 00 
        }
        break;
  101d87:	e9 a6 00 00 00       	jmp    101e32 <trap_dispatch+0x126>
  101d8c:	e9 a1 00 00 00       	jmp    101e32 <trap_dispatch+0x126>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101d91:	e8 c5 f8 ff ff       	call   10165b <cons_getc>
  101d96:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101d99:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101d9d:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101da1:	89 54 24 08          	mov    %edx,0x8(%esp)
  101da5:	89 44 24 04          	mov    %eax,0x4(%esp)
  101da9:	c7 04 24 a9 64 10 00 	movl   $0x1064a9,(%esp)
  101db0:	e8 dd e4 ff ff       	call   100292 <cprintf>
        break;
  101db5:	eb 7b                	jmp    101e32 <trap_dispatch+0x126>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101db7:	e8 9f f8 ff ff       	call   10165b <cons_getc>
  101dbc:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101dbf:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101dc3:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101dc7:	89 54 24 08          	mov    %edx,0x8(%esp)
  101dcb:	89 44 24 04          	mov    %eax,0x4(%esp)
  101dcf:	c7 04 24 bb 64 10 00 	movl   $0x1064bb,(%esp)
  101dd6:	e8 b7 e4 ff ff       	call   100292 <cprintf>
        break;
  101ddb:	eb 55                	jmp    101e32 <trap_dispatch+0x126>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
  101ddd:	c7 44 24 08 ca 64 10 	movl   $0x1064ca,0x8(%esp)
  101de4:	00 
  101de5:	c7 44 24 04 b2 00 00 	movl   $0xb2,0x4(%esp)
  101dec:	00 
  101ded:	c7 04 24 ee 62 10 00 	movl   $0x1062ee,(%esp)
  101df4:	e8 f0 e5 ff ff       	call   1003e9 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101df9:	8b 45 08             	mov    0x8(%ebp),%eax
  101dfc:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101e00:	0f b7 c0             	movzwl %ax,%eax
  101e03:	83 e0 03             	and    $0x3,%eax
  101e06:	85 c0                	test   %eax,%eax
  101e08:	75 28                	jne    101e32 <trap_dispatch+0x126>
            print_trapframe(tf);
  101e0a:	8b 45 08             	mov    0x8(%ebp),%eax
  101e0d:	89 04 24             	mov    %eax,(%esp)
  101e10:	e8 7b fc ff ff       	call   101a90 <print_trapframe>
            panic("unexpected trap in kernel.\n");
  101e15:	c7 44 24 08 da 64 10 	movl   $0x1064da,0x8(%esp)
  101e1c:	00 
  101e1d:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
  101e24:	00 
  101e25:	c7 04 24 ee 62 10 00 	movl   $0x1062ee,(%esp)
  101e2c:	e8 b8 e5 ff ff       	call   1003e9 <__panic>
        break;
  101e31:	90                   	nop
        }
    }
}
  101e32:	c9                   	leave  
  101e33:	c3                   	ret    

00101e34 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101e34:	55                   	push   %ebp
  101e35:	89 e5                	mov    %esp,%ebp
  101e37:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101e3a:	8b 45 08             	mov    0x8(%ebp),%eax
  101e3d:	89 04 24             	mov    %eax,(%esp)
  101e40:	e8 c7 fe ff ff       	call   101d0c <trap_dispatch>
}
  101e45:	c9                   	leave  
  101e46:	c3                   	ret    

00101e47 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101e47:	6a 00                	push   $0x0
  pushl $0
  101e49:	6a 00                	push   $0x0
  jmp __alltraps
  101e4b:	e9 69 0a 00 00       	jmp    1028b9 <__alltraps>

00101e50 <vector1>:
.globl vector1
vector1:
  pushl $0
  101e50:	6a 00                	push   $0x0
  pushl $1
  101e52:	6a 01                	push   $0x1
  jmp __alltraps
  101e54:	e9 60 0a 00 00       	jmp    1028b9 <__alltraps>

00101e59 <vector2>:
.globl vector2
vector2:
  pushl $0
  101e59:	6a 00                	push   $0x0
  pushl $2
  101e5b:	6a 02                	push   $0x2
  jmp __alltraps
  101e5d:	e9 57 0a 00 00       	jmp    1028b9 <__alltraps>

00101e62 <vector3>:
.globl vector3
vector3:
  pushl $0
  101e62:	6a 00                	push   $0x0
  pushl $3
  101e64:	6a 03                	push   $0x3
  jmp __alltraps
  101e66:	e9 4e 0a 00 00       	jmp    1028b9 <__alltraps>

00101e6b <vector4>:
.globl vector4
vector4:
  pushl $0
  101e6b:	6a 00                	push   $0x0
  pushl $4
  101e6d:	6a 04                	push   $0x4
  jmp __alltraps
  101e6f:	e9 45 0a 00 00       	jmp    1028b9 <__alltraps>

00101e74 <vector5>:
.globl vector5
vector5:
  pushl $0
  101e74:	6a 00                	push   $0x0
  pushl $5
  101e76:	6a 05                	push   $0x5
  jmp __alltraps
  101e78:	e9 3c 0a 00 00       	jmp    1028b9 <__alltraps>

00101e7d <vector6>:
.globl vector6
vector6:
  pushl $0
  101e7d:	6a 00                	push   $0x0
  pushl $6
  101e7f:	6a 06                	push   $0x6
  jmp __alltraps
  101e81:	e9 33 0a 00 00       	jmp    1028b9 <__alltraps>

00101e86 <vector7>:
.globl vector7
vector7:
  pushl $0
  101e86:	6a 00                	push   $0x0
  pushl $7
  101e88:	6a 07                	push   $0x7
  jmp __alltraps
  101e8a:	e9 2a 0a 00 00       	jmp    1028b9 <__alltraps>

00101e8f <vector8>:
.globl vector8
vector8:
  pushl $8
  101e8f:	6a 08                	push   $0x8
  jmp __alltraps
  101e91:	e9 23 0a 00 00       	jmp    1028b9 <__alltraps>

00101e96 <vector9>:
.globl vector9
vector9:
  pushl $0
  101e96:	6a 00                	push   $0x0
  pushl $9
  101e98:	6a 09                	push   $0x9
  jmp __alltraps
  101e9a:	e9 1a 0a 00 00       	jmp    1028b9 <__alltraps>

00101e9f <vector10>:
.globl vector10
vector10:
  pushl $10
  101e9f:	6a 0a                	push   $0xa
  jmp __alltraps
  101ea1:	e9 13 0a 00 00       	jmp    1028b9 <__alltraps>

00101ea6 <vector11>:
.globl vector11
vector11:
  pushl $11
  101ea6:	6a 0b                	push   $0xb
  jmp __alltraps
  101ea8:	e9 0c 0a 00 00       	jmp    1028b9 <__alltraps>

00101ead <vector12>:
.globl vector12
vector12:
  pushl $12
  101ead:	6a 0c                	push   $0xc
  jmp __alltraps
  101eaf:	e9 05 0a 00 00       	jmp    1028b9 <__alltraps>

00101eb4 <vector13>:
.globl vector13
vector13:
  pushl $13
  101eb4:	6a 0d                	push   $0xd
  jmp __alltraps
  101eb6:	e9 fe 09 00 00       	jmp    1028b9 <__alltraps>

00101ebb <vector14>:
.globl vector14
vector14:
  pushl $14
  101ebb:	6a 0e                	push   $0xe
  jmp __alltraps
  101ebd:	e9 f7 09 00 00       	jmp    1028b9 <__alltraps>

00101ec2 <vector15>:
.globl vector15
vector15:
  pushl $0
  101ec2:	6a 00                	push   $0x0
  pushl $15
  101ec4:	6a 0f                	push   $0xf
  jmp __alltraps
  101ec6:	e9 ee 09 00 00       	jmp    1028b9 <__alltraps>

00101ecb <vector16>:
.globl vector16
vector16:
  pushl $0
  101ecb:	6a 00                	push   $0x0
  pushl $16
  101ecd:	6a 10                	push   $0x10
  jmp __alltraps
  101ecf:	e9 e5 09 00 00       	jmp    1028b9 <__alltraps>

00101ed4 <vector17>:
.globl vector17
vector17:
  pushl $17
  101ed4:	6a 11                	push   $0x11
  jmp __alltraps
  101ed6:	e9 de 09 00 00       	jmp    1028b9 <__alltraps>

00101edb <vector18>:
.globl vector18
vector18:
  pushl $0
  101edb:	6a 00                	push   $0x0
  pushl $18
  101edd:	6a 12                	push   $0x12
  jmp __alltraps
  101edf:	e9 d5 09 00 00       	jmp    1028b9 <__alltraps>

00101ee4 <vector19>:
.globl vector19
vector19:
  pushl $0
  101ee4:	6a 00                	push   $0x0
  pushl $19
  101ee6:	6a 13                	push   $0x13
  jmp __alltraps
  101ee8:	e9 cc 09 00 00       	jmp    1028b9 <__alltraps>

00101eed <vector20>:
.globl vector20
vector20:
  pushl $0
  101eed:	6a 00                	push   $0x0
  pushl $20
  101eef:	6a 14                	push   $0x14
  jmp __alltraps
  101ef1:	e9 c3 09 00 00       	jmp    1028b9 <__alltraps>

00101ef6 <vector21>:
.globl vector21
vector21:
  pushl $0
  101ef6:	6a 00                	push   $0x0
  pushl $21
  101ef8:	6a 15                	push   $0x15
  jmp __alltraps
  101efa:	e9 ba 09 00 00       	jmp    1028b9 <__alltraps>

00101eff <vector22>:
.globl vector22
vector22:
  pushl $0
  101eff:	6a 00                	push   $0x0
  pushl $22
  101f01:	6a 16                	push   $0x16
  jmp __alltraps
  101f03:	e9 b1 09 00 00       	jmp    1028b9 <__alltraps>

00101f08 <vector23>:
.globl vector23
vector23:
  pushl $0
  101f08:	6a 00                	push   $0x0
  pushl $23
  101f0a:	6a 17                	push   $0x17
  jmp __alltraps
  101f0c:	e9 a8 09 00 00       	jmp    1028b9 <__alltraps>

00101f11 <vector24>:
.globl vector24
vector24:
  pushl $0
  101f11:	6a 00                	push   $0x0
  pushl $24
  101f13:	6a 18                	push   $0x18
  jmp __alltraps
  101f15:	e9 9f 09 00 00       	jmp    1028b9 <__alltraps>

00101f1a <vector25>:
.globl vector25
vector25:
  pushl $0
  101f1a:	6a 00                	push   $0x0
  pushl $25
  101f1c:	6a 19                	push   $0x19
  jmp __alltraps
  101f1e:	e9 96 09 00 00       	jmp    1028b9 <__alltraps>

00101f23 <vector26>:
.globl vector26
vector26:
  pushl $0
  101f23:	6a 00                	push   $0x0
  pushl $26
  101f25:	6a 1a                	push   $0x1a
  jmp __alltraps
  101f27:	e9 8d 09 00 00       	jmp    1028b9 <__alltraps>

00101f2c <vector27>:
.globl vector27
vector27:
  pushl $0
  101f2c:	6a 00                	push   $0x0
  pushl $27
  101f2e:	6a 1b                	push   $0x1b
  jmp __alltraps
  101f30:	e9 84 09 00 00       	jmp    1028b9 <__alltraps>

00101f35 <vector28>:
.globl vector28
vector28:
  pushl $0
  101f35:	6a 00                	push   $0x0
  pushl $28
  101f37:	6a 1c                	push   $0x1c
  jmp __alltraps
  101f39:	e9 7b 09 00 00       	jmp    1028b9 <__alltraps>

00101f3e <vector29>:
.globl vector29
vector29:
  pushl $0
  101f3e:	6a 00                	push   $0x0
  pushl $29
  101f40:	6a 1d                	push   $0x1d
  jmp __alltraps
  101f42:	e9 72 09 00 00       	jmp    1028b9 <__alltraps>

00101f47 <vector30>:
.globl vector30
vector30:
  pushl $0
  101f47:	6a 00                	push   $0x0
  pushl $30
  101f49:	6a 1e                	push   $0x1e
  jmp __alltraps
  101f4b:	e9 69 09 00 00       	jmp    1028b9 <__alltraps>

00101f50 <vector31>:
.globl vector31
vector31:
  pushl $0
  101f50:	6a 00                	push   $0x0
  pushl $31
  101f52:	6a 1f                	push   $0x1f
  jmp __alltraps
  101f54:	e9 60 09 00 00       	jmp    1028b9 <__alltraps>

00101f59 <vector32>:
.globl vector32
vector32:
  pushl $0
  101f59:	6a 00                	push   $0x0
  pushl $32
  101f5b:	6a 20                	push   $0x20
  jmp __alltraps
  101f5d:	e9 57 09 00 00       	jmp    1028b9 <__alltraps>

00101f62 <vector33>:
.globl vector33
vector33:
  pushl $0
  101f62:	6a 00                	push   $0x0
  pushl $33
  101f64:	6a 21                	push   $0x21
  jmp __alltraps
  101f66:	e9 4e 09 00 00       	jmp    1028b9 <__alltraps>

00101f6b <vector34>:
.globl vector34
vector34:
  pushl $0
  101f6b:	6a 00                	push   $0x0
  pushl $34
  101f6d:	6a 22                	push   $0x22
  jmp __alltraps
  101f6f:	e9 45 09 00 00       	jmp    1028b9 <__alltraps>

00101f74 <vector35>:
.globl vector35
vector35:
  pushl $0
  101f74:	6a 00                	push   $0x0
  pushl $35
  101f76:	6a 23                	push   $0x23
  jmp __alltraps
  101f78:	e9 3c 09 00 00       	jmp    1028b9 <__alltraps>

00101f7d <vector36>:
.globl vector36
vector36:
  pushl $0
  101f7d:	6a 00                	push   $0x0
  pushl $36
  101f7f:	6a 24                	push   $0x24
  jmp __alltraps
  101f81:	e9 33 09 00 00       	jmp    1028b9 <__alltraps>

00101f86 <vector37>:
.globl vector37
vector37:
  pushl $0
  101f86:	6a 00                	push   $0x0
  pushl $37
  101f88:	6a 25                	push   $0x25
  jmp __alltraps
  101f8a:	e9 2a 09 00 00       	jmp    1028b9 <__alltraps>

00101f8f <vector38>:
.globl vector38
vector38:
  pushl $0
  101f8f:	6a 00                	push   $0x0
  pushl $38
  101f91:	6a 26                	push   $0x26
  jmp __alltraps
  101f93:	e9 21 09 00 00       	jmp    1028b9 <__alltraps>

00101f98 <vector39>:
.globl vector39
vector39:
  pushl $0
  101f98:	6a 00                	push   $0x0
  pushl $39
  101f9a:	6a 27                	push   $0x27
  jmp __alltraps
  101f9c:	e9 18 09 00 00       	jmp    1028b9 <__alltraps>

00101fa1 <vector40>:
.globl vector40
vector40:
  pushl $0
  101fa1:	6a 00                	push   $0x0
  pushl $40
  101fa3:	6a 28                	push   $0x28
  jmp __alltraps
  101fa5:	e9 0f 09 00 00       	jmp    1028b9 <__alltraps>

00101faa <vector41>:
.globl vector41
vector41:
  pushl $0
  101faa:	6a 00                	push   $0x0
  pushl $41
  101fac:	6a 29                	push   $0x29
  jmp __alltraps
  101fae:	e9 06 09 00 00       	jmp    1028b9 <__alltraps>

00101fb3 <vector42>:
.globl vector42
vector42:
  pushl $0
  101fb3:	6a 00                	push   $0x0
  pushl $42
  101fb5:	6a 2a                	push   $0x2a
  jmp __alltraps
  101fb7:	e9 fd 08 00 00       	jmp    1028b9 <__alltraps>

00101fbc <vector43>:
.globl vector43
vector43:
  pushl $0
  101fbc:	6a 00                	push   $0x0
  pushl $43
  101fbe:	6a 2b                	push   $0x2b
  jmp __alltraps
  101fc0:	e9 f4 08 00 00       	jmp    1028b9 <__alltraps>

00101fc5 <vector44>:
.globl vector44
vector44:
  pushl $0
  101fc5:	6a 00                	push   $0x0
  pushl $44
  101fc7:	6a 2c                	push   $0x2c
  jmp __alltraps
  101fc9:	e9 eb 08 00 00       	jmp    1028b9 <__alltraps>

00101fce <vector45>:
.globl vector45
vector45:
  pushl $0
  101fce:	6a 00                	push   $0x0
  pushl $45
  101fd0:	6a 2d                	push   $0x2d
  jmp __alltraps
  101fd2:	e9 e2 08 00 00       	jmp    1028b9 <__alltraps>

00101fd7 <vector46>:
.globl vector46
vector46:
  pushl $0
  101fd7:	6a 00                	push   $0x0
  pushl $46
  101fd9:	6a 2e                	push   $0x2e
  jmp __alltraps
  101fdb:	e9 d9 08 00 00       	jmp    1028b9 <__alltraps>

00101fe0 <vector47>:
.globl vector47
vector47:
  pushl $0
  101fe0:	6a 00                	push   $0x0
  pushl $47
  101fe2:	6a 2f                	push   $0x2f
  jmp __alltraps
  101fe4:	e9 d0 08 00 00       	jmp    1028b9 <__alltraps>

00101fe9 <vector48>:
.globl vector48
vector48:
  pushl $0
  101fe9:	6a 00                	push   $0x0
  pushl $48
  101feb:	6a 30                	push   $0x30
  jmp __alltraps
  101fed:	e9 c7 08 00 00       	jmp    1028b9 <__alltraps>

00101ff2 <vector49>:
.globl vector49
vector49:
  pushl $0
  101ff2:	6a 00                	push   $0x0
  pushl $49
  101ff4:	6a 31                	push   $0x31
  jmp __alltraps
  101ff6:	e9 be 08 00 00       	jmp    1028b9 <__alltraps>

00101ffb <vector50>:
.globl vector50
vector50:
  pushl $0
  101ffb:	6a 00                	push   $0x0
  pushl $50
  101ffd:	6a 32                	push   $0x32
  jmp __alltraps
  101fff:	e9 b5 08 00 00       	jmp    1028b9 <__alltraps>

00102004 <vector51>:
.globl vector51
vector51:
  pushl $0
  102004:	6a 00                	push   $0x0
  pushl $51
  102006:	6a 33                	push   $0x33
  jmp __alltraps
  102008:	e9 ac 08 00 00       	jmp    1028b9 <__alltraps>

0010200d <vector52>:
.globl vector52
vector52:
  pushl $0
  10200d:	6a 00                	push   $0x0
  pushl $52
  10200f:	6a 34                	push   $0x34
  jmp __alltraps
  102011:	e9 a3 08 00 00       	jmp    1028b9 <__alltraps>

00102016 <vector53>:
.globl vector53
vector53:
  pushl $0
  102016:	6a 00                	push   $0x0
  pushl $53
  102018:	6a 35                	push   $0x35
  jmp __alltraps
  10201a:	e9 9a 08 00 00       	jmp    1028b9 <__alltraps>

0010201f <vector54>:
.globl vector54
vector54:
  pushl $0
  10201f:	6a 00                	push   $0x0
  pushl $54
  102021:	6a 36                	push   $0x36
  jmp __alltraps
  102023:	e9 91 08 00 00       	jmp    1028b9 <__alltraps>

00102028 <vector55>:
.globl vector55
vector55:
  pushl $0
  102028:	6a 00                	push   $0x0
  pushl $55
  10202a:	6a 37                	push   $0x37
  jmp __alltraps
  10202c:	e9 88 08 00 00       	jmp    1028b9 <__alltraps>

00102031 <vector56>:
.globl vector56
vector56:
  pushl $0
  102031:	6a 00                	push   $0x0
  pushl $56
  102033:	6a 38                	push   $0x38
  jmp __alltraps
  102035:	e9 7f 08 00 00       	jmp    1028b9 <__alltraps>

0010203a <vector57>:
.globl vector57
vector57:
  pushl $0
  10203a:	6a 00                	push   $0x0
  pushl $57
  10203c:	6a 39                	push   $0x39
  jmp __alltraps
  10203e:	e9 76 08 00 00       	jmp    1028b9 <__alltraps>

00102043 <vector58>:
.globl vector58
vector58:
  pushl $0
  102043:	6a 00                	push   $0x0
  pushl $58
  102045:	6a 3a                	push   $0x3a
  jmp __alltraps
  102047:	e9 6d 08 00 00       	jmp    1028b9 <__alltraps>

0010204c <vector59>:
.globl vector59
vector59:
  pushl $0
  10204c:	6a 00                	push   $0x0
  pushl $59
  10204e:	6a 3b                	push   $0x3b
  jmp __alltraps
  102050:	e9 64 08 00 00       	jmp    1028b9 <__alltraps>

00102055 <vector60>:
.globl vector60
vector60:
  pushl $0
  102055:	6a 00                	push   $0x0
  pushl $60
  102057:	6a 3c                	push   $0x3c
  jmp __alltraps
  102059:	e9 5b 08 00 00       	jmp    1028b9 <__alltraps>

0010205e <vector61>:
.globl vector61
vector61:
  pushl $0
  10205e:	6a 00                	push   $0x0
  pushl $61
  102060:	6a 3d                	push   $0x3d
  jmp __alltraps
  102062:	e9 52 08 00 00       	jmp    1028b9 <__alltraps>

00102067 <vector62>:
.globl vector62
vector62:
  pushl $0
  102067:	6a 00                	push   $0x0
  pushl $62
  102069:	6a 3e                	push   $0x3e
  jmp __alltraps
  10206b:	e9 49 08 00 00       	jmp    1028b9 <__alltraps>

00102070 <vector63>:
.globl vector63
vector63:
  pushl $0
  102070:	6a 00                	push   $0x0
  pushl $63
  102072:	6a 3f                	push   $0x3f
  jmp __alltraps
  102074:	e9 40 08 00 00       	jmp    1028b9 <__alltraps>

00102079 <vector64>:
.globl vector64
vector64:
  pushl $0
  102079:	6a 00                	push   $0x0
  pushl $64
  10207b:	6a 40                	push   $0x40
  jmp __alltraps
  10207d:	e9 37 08 00 00       	jmp    1028b9 <__alltraps>

00102082 <vector65>:
.globl vector65
vector65:
  pushl $0
  102082:	6a 00                	push   $0x0
  pushl $65
  102084:	6a 41                	push   $0x41
  jmp __alltraps
  102086:	e9 2e 08 00 00       	jmp    1028b9 <__alltraps>

0010208b <vector66>:
.globl vector66
vector66:
  pushl $0
  10208b:	6a 00                	push   $0x0
  pushl $66
  10208d:	6a 42                	push   $0x42
  jmp __alltraps
  10208f:	e9 25 08 00 00       	jmp    1028b9 <__alltraps>

00102094 <vector67>:
.globl vector67
vector67:
  pushl $0
  102094:	6a 00                	push   $0x0
  pushl $67
  102096:	6a 43                	push   $0x43
  jmp __alltraps
  102098:	e9 1c 08 00 00       	jmp    1028b9 <__alltraps>

0010209d <vector68>:
.globl vector68
vector68:
  pushl $0
  10209d:	6a 00                	push   $0x0
  pushl $68
  10209f:	6a 44                	push   $0x44
  jmp __alltraps
  1020a1:	e9 13 08 00 00       	jmp    1028b9 <__alltraps>

001020a6 <vector69>:
.globl vector69
vector69:
  pushl $0
  1020a6:	6a 00                	push   $0x0
  pushl $69
  1020a8:	6a 45                	push   $0x45
  jmp __alltraps
  1020aa:	e9 0a 08 00 00       	jmp    1028b9 <__alltraps>

001020af <vector70>:
.globl vector70
vector70:
  pushl $0
  1020af:	6a 00                	push   $0x0
  pushl $70
  1020b1:	6a 46                	push   $0x46
  jmp __alltraps
  1020b3:	e9 01 08 00 00       	jmp    1028b9 <__alltraps>

001020b8 <vector71>:
.globl vector71
vector71:
  pushl $0
  1020b8:	6a 00                	push   $0x0
  pushl $71
  1020ba:	6a 47                	push   $0x47
  jmp __alltraps
  1020bc:	e9 f8 07 00 00       	jmp    1028b9 <__alltraps>

001020c1 <vector72>:
.globl vector72
vector72:
  pushl $0
  1020c1:	6a 00                	push   $0x0
  pushl $72
  1020c3:	6a 48                	push   $0x48
  jmp __alltraps
  1020c5:	e9 ef 07 00 00       	jmp    1028b9 <__alltraps>

001020ca <vector73>:
.globl vector73
vector73:
  pushl $0
  1020ca:	6a 00                	push   $0x0
  pushl $73
  1020cc:	6a 49                	push   $0x49
  jmp __alltraps
  1020ce:	e9 e6 07 00 00       	jmp    1028b9 <__alltraps>

001020d3 <vector74>:
.globl vector74
vector74:
  pushl $0
  1020d3:	6a 00                	push   $0x0
  pushl $74
  1020d5:	6a 4a                	push   $0x4a
  jmp __alltraps
  1020d7:	e9 dd 07 00 00       	jmp    1028b9 <__alltraps>

001020dc <vector75>:
.globl vector75
vector75:
  pushl $0
  1020dc:	6a 00                	push   $0x0
  pushl $75
  1020de:	6a 4b                	push   $0x4b
  jmp __alltraps
  1020e0:	e9 d4 07 00 00       	jmp    1028b9 <__alltraps>

001020e5 <vector76>:
.globl vector76
vector76:
  pushl $0
  1020e5:	6a 00                	push   $0x0
  pushl $76
  1020e7:	6a 4c                	push   $0x4c
  jmp __alltraps
  1020e9:	e9 cb 07 00 00       	jmp    1028b9 <__alltraps>

001020ee <vector77>:
.globl vector77
vector77:
  pushl $0
  1020ee:	6a 00                	push   $0x0
  pushl $77
  1020f0:	6a 4d                	push   $0x4d
  jmp __alltraps
  1020f2:	e9 c2 07 00 00       	jmp    1028b9 <__alltraps>

001020f7 <vector78>:
.globl vector78
vector78:
  pushl $0
  1020f7:	6a 00                	push   $0x0
  pushl $78
  1020f9:	6a 4e                	push   $0x4e
  jmp __alltraps
  1020fb:	e9 b9 07 00 00       	jmp    1028b9 <__alltraps>

00102100 <vector79>:
.globl vector79
vector79:
  pushl $0
  102100:	6a 00                	push   $0x0
  pushl $79
  102102:	6a 4f                	push   $0x4f
  jmp __alltraps
  102104:	e9 b0 07 00 00       	jmp    1028b9 <__alltraps>

00102109 <vector80>:
.globl vector80
vector80:
  pushl $0
  102109:	6a 00                	push   $0x0
  pushl $80
  10210b:	6a 50                	push   $0x50
  jmp __alltraps
  10210d:	e9 a7 07 00 00       	jmp    1028b9 <__alltraps>

00102112 <vector81>:
.globl vector81
vector81:
  pushl $0
  102112:	6a 00                	push   $0x0
  pushl $81
  102114:	6a 51                	push   $0x51
  jmp __alltraps
  102116:	e9 9e 07 00 00       	jmp    1028b9 <__alltraps>

0010211b <vector82>:
.globl vector82
vector82:
  pushl $0
  10211b:	6a 00                	push   $0x0
  pushl $82
  10211d:	6a 52                	push   $0x52
  jmp __alltraps
  10211f:	e9 95 07 00 00       	jmp    1028b9 <__alltraps>

00102124 <vector83>:
.globl vector83
vector83:
  pushl $0
  102124:	6a 00                	push   $0x0
  pushl $83
  102126:	6a 53                	push   $0x53
  jmp __alltraps
  102128:	e9 8c 07 00 00       	jmp    1028b9 <__alltraps>

0010212d <vector84>:
.globl vector84
vector84:
  pushl $0
  10212d:	6a 00                	push   $0x0
  pushl $84
  10212f:	6a 54                	push   $0x54
  jmp __alltraps
  102131:	e9 83 07 00 00       	jmp    1028b9 <__alltraps>

00102136 <vector85>:
.globl vector85
vector85:
  pushl $0
  102136:	6a 00                	push   $0x0
  pushl $85
  102138:	6a 55                	push   $0x55
  jmp __alltraps
  10213a:	e9 7a 07 00 00       	jmp    1028b9 <__alltraps>

0010213f <vector86>:
.globl vector86
vector86:
  pushl $0
  10213f:	6a 00                	push   $0x0
  pushl $86
  102141:	6a 56                	push   $0x56
  jmp __alltraps
  102143:	e9 71 07 00 00       	jmp    1028b9 <__alltraps>

00102148 <vector87>:
.globl vector87
vector87:
  pushl $0
  102148:	6a 00                	push   $0x0
  pushl $87
  10214a:	6a 57                	push   $0x57
  jmp __alltraps
  10214c:	e9 68 07 00 00       	jmp    1028b9 <__alltraps>

00102151 <vector88>:
.globl vector88
vector88:
  pushl $0
  102151:	6a 00                	push   $0x0
  pushl $88
  102153:	6a 58                	push   $0x58
  jmp __alltraps
  102155:	e9 5f 07 00 00       	jmp    1028b9 <__alltraps>

0010215a <vector89>:
.globl vector89
vector89:
  pushl $0
  10215a:	6a 00                	push   $0x0
  pushl $89
  10215c:	6a 59                	push   $0x59
  jmp __alltraps
  10215e:	e9 56 07 00 00       	jmp    1028b9 <__alltraps>

00102163 <vector90>:
.globl vector90
vector90:
  pushl $0
  102163:	6a 00                	push   $0x0
  pushl $90
  102165:	6a 5a                	push   $0x5a
  jmp __alltraps
  102167:	e9 4d 07 00 00       	jmp    1028b9 <__alltraps>

0010216c <vector91>:
.globl vector91
vector91:
  pushl $0
  10216c:	6a 00                	push   $0x0
  pushl $91
  10216e:	6a 5b                	push   $0x5b
  jmp __alltraps
  102170:	e9 44 07 00 00       	jmp    1028b9 <__alltraps>

00102175 <vector92>:
.globl vector92
vector92:
  pushl $0
  102175:	6a 00                	push   $0x0
  pushl $92
  102177:	6a 5c                	push   $0x5c
  jmp __alltraps
  102179:	e9 3b 07 00 00       	jmp    1028b9 <__alltraps>

0010217e <vector93>:
.globl vector93
vector93:
  pushl $0
  10217e:	6a 00                	push   $0x0
  pushl $93
  102180:	6a 5d                	push   $0x5d
  jmp __alltraps
  102182:	e9 32 07 00 00       	jmp    1028b9 <__alltraps>

00102187 <vector94>:
.globl vector94
vector94:
  pushl $0
  102187:	6a 00                	push   $0x0
  pushl $94
  102189:	6a 5e                	push   $0x5e
  jmp __alltraps
  10218b:	e9 29 07 00 00       	jmp    1028b9 <__alltraps>

00102190 <vector95>:
.globl vector95
vector95:
  pushl $0
  102190:	6a 00                	push   $0x0
  pushl $95
  102192:	6a 5f                	push   $0x5f
  jmp __alltraps
  102194:	e9 20 07 00 00       	jmp    1028b9 <__alltraps>

00102199 <vector96>:
.globl vector96
vector96:
  pushl $0
  102199:	6a 00                	push   $0x0
  pushl $96
  10219b:	6a 60                	push   $0x60
  jmp __alltraps
  10219d:	e9 17 07 00 00       	jmp    1028b9 <__alltraps>

001021a2 <vector97>:
.globl vector97
vector97:
  pushl $0
  1021a2:	6a 00                	push   $0x0
  pushl $97
  1021a4:	6a 61                	push   $0x61
  jmp __alltraps
  1021a6:	e9 0e 07 00 00       	jmp    1028b9 <__alltraps>

001021ab <vector98>:
.globl vector98
vector98:
  pushl $0
  1021ab:	6a 00                	push   $0x0
  pushl $98
  1021ad:	6a 62                	push   $0x62
  jmp __alltraps
  1021af:	e9 05 07 00 00       	jmp    1028b9 <__alltraps>

001021b4 <vector99>:
.globl vector99
vector99:
  pushl $0
  1021b4:	6a 00                	push   $0x0
  pushl $99
  1021b6:	6a 63                	push   $0x63
  jmp __alltraps
  1021b8:	e9 fc 06 00 00       	jmp    1028b9 <__alltraps>

001021bd <vector100>:
.globl vector100
vector100:
  pushl $0
  1021bd:	6a 00                	push   $0x0
  pushl $100
  1021bf:	6a 64                	push   $0x64
  jmp __alltraps
  1021c1:	e9 f3 06 00 00       	jmp    1028b9 <__alltraps>

001021c6 <vector101>:
.globl vector101
vector101:
  pushl $0
  1021c6:	6a 00                	push   $0x0
  pushl $101
  1021c8:	6a 65                	push   $0x65
  jmp __alltraps
  1021ca:	e9 ea 06 00 00       	jmp    1028b9 <__alltraps>

001021cf <vector102>:
.globl vector102
vector102:
  pushl $0
  1021cf:	6a 00                	push   $0x0
  pushl $102
  1021d1:	6a 66                	push   $0x66
  jmp __alltraps
  1021d3:	e9 e1 06 00 00       	jmp    1028b9 <__alltraps>

001021d8 <vector103>:
.globl vector103
vector103:
  pushl $0
  1021d8:	6a 00                	push   $0x0
  pushl $103
  1021da:	6a 67                	push   $0x67
  jmp __alltraps
  1021dc:	e9 d8 06 00 00       	jmp    1028b9 <__alltraps>

001021e1 <vector104>:
.globl vector104
vector104:
  pushl $0
  1021e1:	6a 00                	push   $0x0
  pushl $104
  1021e3:	6a 68                	push   $0x68
  jmp __alltraps
  1021e5:	e9 cf 06 00 00       	jmp    1028b9 <__alltraps>

001021ea <vector105>:
.globl vector105
vector105:
  pushl $0
  1021ea:	6a 00                	push   $0x0
  pushl $105
  1021ec:	6a 69                	push   $0x69
  jmp __alltraps
  1021ee:	e9 c6 06 00 00       	jmp    1028b9 <__alltraps>

001021f3 <vector106>:
.globl vector106
vector106:
  pushl $0
  1021f3:	6a 00                	push   $0x0
  pushl $106
  1021f5:	6a 6a                	push   $0x6a
  jmp __alltraps
  1021f7:	e9 bd 06 00 00       	jmp    1028b9 <__alltraps>

001021fc <vector107>:
.globl vector107
vector107:
  pushl $0
  1021fc:	6a 00                	push   $0x0
  pushl $107
  1021fe:	6a 6b                	push   $0x6b
  jmp __alltraps
  102200:	e9 b4 06 00 00       	jmp    1028b9 <__alltraps>

00102205 <vector108>:
.globl vector108
vector108:
  pushl $0
  102205:	6a 00                	push   $0x0
  pushl $108
  102207:	6a 6c                	push   $0x6c
  jmp __alltraps
  102209:	e9 ab 06 00 00       	jmp    1028b9 <__alltraps>

0010220e <vector109>:
.globl vector109
vector109:
  pushl $0
  10220e:	6a 00                	push   $0x0
  pushl $109
  102210:	6a 6d                	push   $0x6d
  jmp __alltraps
  102212:	e9 a2 06 00 00       	jmp    1028b9 <__alltraps>

00102217 <vector110>:
.globl vector110
vector110:
  pushl $0
  102217:	6a 00                	push   $0x0
  pushl $110
  102219:	6a 6e                	push   $0x6e
  jmp __alltraps
  10221b:	e9 99 06 00 00       	jmp    1028b9 <__alltraps>

00102220 <vector111>:
.globl vector111
vector111:
  pushl $0
  102220:	6a 00                	push   $0x0
  pushl $111
  102222:	6a 6f                	push   $0x6f
  jmp __alltraps
  102224:	e9 90 06 00 00       	jmp    1028b9 <__alltraps>

00102229 <vector112>:
.globl vector112
vector112:
  pushl $0
  102229:	6a 00                	push   $0x0
  pushl $112
  10222b:	6a 70                	push   $0x70
  jmp __alltraps
  10222d:	e9 87 06 00 00       	jmp    1028b9 <__alltraps>

00102232 <vector113>:
.globl vector113
vector113:
  pushl $0
  102232:	6a 00                	push   $0x0
  pushl $113
  102234:	6a 71                	push   $0x71
  jmp __alltraps
  102236:	e9 7e 06 00 00       	jmp    1028b9 <__alltraps>

0010223b <vector114>:
.globl vector114
vector114:
  pushl $0
  10223b:	6a 00                	push   $0x0
  pushl $114
  10223d:	6a 72                	push   $0x72
  jmp __alltraps
  10223f:	e9 75 06 00 00       	jmp    1028b9 <__alltraps>

00102244 <vector115>:
.globl vector115
vector115:
  pushl $0
  102244:	6a 00                	push   $0x0
  pushl $115
  102246:	6a 73                	push   $0x73
  jmp __alltraps
  102248:	e9 6c 06 00 00       	jmp    1028b9 <__alltraps>

0010224d <vector116>:
.globl vector116
vector116:
  pushl $0
  10224d:	6a 00                	push   $0x0
  pushl $116
  10224f:	6a 74                	push   $0x74
  jmp __alltraps
  102251:	e9 63 06 00 00       	jmp    1028b9 <__alltraps>

00102256 <vector117>:
.globl vector117
vector117:
  pushl $0
  102256:	6a 00                	push   $0x0
  pushl $117
  102258:	6a 75                	push   $0x75
  jmp __alltraps
  10225a:	e9 5a 06 00 00       	jmp    1028b9 <__alltraps>

0010225f <vector118>:
.globl vector118
vector118:
  pushl $0
  10225f:	6a 00                	push   $0x0
  pushl $118
  102261:	6a 76                	push   $0x76
  jmp __alltraps
  102263:	e9 51 06 00 00       	jmp    1028b9 <__alltraps>

00102268 <vector119>:
.globl vector119
vector119:
  pushl $0
  102268:	6a 00                	push   $0x0
  pushl $119
  10226a:	6a 77                	push   $0x77
  jmp __alltraps
  10226c:	e9 48 06 00 00       	jmp    1028b9 <__alltraps>

00102271 <vector120>:
.globl vector120
vector120:
  pushl $0
  102271:	6a 00                	push   $0x0
  pushl $120
  102273:	6a 78                	push   $0x78
  jmp __alltraps
  102275:	e9 3f 06 00 00       	jmp    1028b9 <__alltraps>

0010227a <vector121>:
.globl vector121
vector121:
  pushl $0
  10227a:	6a 00                	push   $0x0
  pushl $121
  10227c:	6a 79                	push   $0x79
  jmp __alltraps
  10227e:	e9 36 06 00 00       	jmp    1028b9 <__alltraps>

00102283 <vector122>:
.globl vector122
vector122:
  pushl $0
  102283:	6a 00                	push   $0x0
  pushl $122
  102285:	6a 7a                	push   $0x7a
  jmp __alltraps
  102287:	e9 2d 06 00 00       	jmp    1028b9 <__alltraps>

0010228c <vector123>:
.globl vector123
vector123:
  pushl $0
  10228c:	6a 00                	push   $0x0
  pushl $123
  10228e:	6a 7b                	push   $0x7b
  jmp __alltraps
  102290:	e9 24 06 00 00       	jmp    1028b9 <__alltraps>

00102295 <vector124>:
.globl vector124
vector124:
  pushl $0
  102295:	6a 00                	push   $0x0
  pushl $124
  102297:	6a 7c                	push   $0x7c
  jmp __alltraps
  102299:	e9 1b 06 00 00       	jmp    1028b9 <__alltraps>

0010229e <vector125>:
.globl vector125
vector125:
  pushl $0
  10229e:	6a 00                	push   $0x0
  pushl $125
  1022a0:	6a 7d                	push   $0x7d
  jmp __alltraps
  1022a2:	e9 12 06 00 00       	jmp    1028b9 <__alltraps>

001022a7 <vector126>:
.globl vector126
vector126:
  pushl $0
  1022a7:	6a 00                	push   $0x0
  pushl $126
  1022a9:	6a 7e                	push   $0x7e
  jmp __alltraps
  1022ab:	e9 09 06 00 00       	jmp    1028b9 <__alltraps>

001022b0 <vector127>:
.globl vector127
vector127:
  pushl $0
  1022b0:	6a 00                	push   $0x0
  pushl $127
  1022b2:	6a 7f                	push   $0x7f
  jmp __alltraps
  1022b4:	e9 00 06 00 00       	jmp    1028b9 <__alltraps>

001022b9 <vector128>:
.globl vector128
vector128:
  pushl $0
  1022b9:	6a 00                	push   $0x0
  pushl $128
  1022bb:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  1022c0:	e9 f4 05 00 00       	jmp    1028b9 <__alltraps>

001022c5 <vector129>:
.globl vector129
vector129:
  pushl $0
  1022c5:	6a 00                	push   $0x0
  pushl $129
  1022c7:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  1022cc:	e9 e8 05 00 00       	jmp    1028b9 <__alltraps>

001022d1 <vector130>:
.globl vector130
vector130:
  pushl $0
  1022d1:	6a 00                	push   $0x0
  pushl $130
  1022d3:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  1022d8:	e9 dc 05 00 00       	jmp    1028b9 <__alltraps>

001022dd <vector131>:
.globl vector131
vector131:
  pushl $0
  1022dd:	6a 00                	push   $0x0
  pushl $131
  1022df:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  1022e4:	e9 d0 05 00 00       	jmp    1028b9 <__alltraps>

001022e9 <vector132>:
.globl vector132
vector132:
  pushl $0
  1022e9:	6a 00                	push   $0x0
  pushl $132
  1022eb:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  1022f0:	e9 c4 05 00 00       	jmp    1028b9 <__alltraps>

001022f5 <vector133>:
.globl vector133
vector133:
  pushl $0
  1022f5:	6a 00                	push   $0x0
  pushl $133
  1022f7:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  1022fc:	e9 b8 05 00 00       	jmp    1028b9 <__alltraps>

00102301 <vector134>:
.globl vector134
vector134:
  pushl $0
  102301:	6a 00                	push   $0x0
  pushl $134
  102303:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  102308:	e9 ac 05 00 00       	jmp    1028b9 <__alltraps>

0010230d <vector135>:
.globl vector135
vector135:
  pushl $0
  10230d:	6a 00                	push   $0x0
  pushl $135
  10230f:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  102314:	e9 a0 05 00 00       	jmp    1028b9 <__alltraps>

00102319 <vector136>:
.globl vector136
vector136:
  pushl $0
  102319:	6a 00                	push   $0x0
  pushl $136
  10231b:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  102320:	e9 94 05 00 00       	jmp    1028b9 <__alltraps>

00102325 <vector137>:
.globl vector137
vector137:
  pushl $0
  102325:	6a 00                	push   $0x0
  pushl $137
  102327:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  10232c:	e9 88 05 00 00       	jmp    1028b9 <__alltraps>

00102331 <vector138>:
.globl vector138
vector138:
  pushl $0
  102331:	6a 00                	push   $0x0
  pushl $138
  102333:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  102338:	e9 7c 05 00 00       	jmp    1028b9 <__alltraps>

0010233d <vector139>:
.globl vector139
vector139:
  pushl $0
  10233d:	6a 00                	push   $0x0
  pushl $139
  10233f:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  102344:	e9 70 05 00 00       	jmp    1028b9 <__alltraps>

00102349 <vector140>:
.globl vector140
vector140:
  pushl $0
  102349:	6a 00                	push   $0x0
  pushl $140
  10234b:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  102350:	e9 64 05 00 00       	jmp    1028b9 <__alltraps>

00102355 <vector141>:
.globl vector141
vector141:
  pushl $0
  102355:	6a 00                	push   $0x0
  pushl $141
  102357:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  10235c:	e9 58 05 00 00       	jmp    1028b9 <__alltraps>

00102361 <vector142>:
.globl vector142
vector142:
  pushl $0
  102361:	6a 00                	push   $0x0
  pushl $142
  102363:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  102368:	e9 4c 05 00 00       	jmp    1028b9 <__alltraps>

0010236d <vector143>:
.globl vector143
vector143:
  pushl $0
  10236d:	6a 00                	push   $0x0
  pushl $143
  10236f:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  102374:	e9 40 05 00 00       	jmp    1028b9 <__alltraps>

00102379 <vector144>:
.globl vector144
vector144:
  pushl $0
  102379:	6a 00                	push   $0x0
  pushl $144
  10237b:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  102380:	e9 34 05 00 00       	jmp    1028b9 <__alltraps>

00102385 <vector145>:
.globl vector145
vector145:
  pushl $0
  102385:	6a 00                	push   $0x0
  pushl $145
  102387:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  10238c:	e9 28 05 00 00       	jmp    1028b9 <__alltraps>

00102391 <vector146>:
.globl vector146
vector146:
  pushl $0
  102391:	6a 00                	push   $0x0
  pushl $146
  102393:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  102398:	e9 1c 05 00 00       	jmp    1028b9 <__alltraps>

0010239d <vector147>:
.globl vector147
vector147:
  pushl $0
  10239d:	6a 00                	push   $0x0
  pushl $147
  10239f:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  1023a4:	e9 10 05 00 00       	jmp    1028b9 <__alltraps>

001023a9 <vector148>:
.globl vector148
vector148:
  pushl $0
  1023a9:	6a 00                	push   $0x0
  pushl $148
  1023ab:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  1023b0:	e9 04 05 00 00       	jmp    1028b9 <__alltraps>

001023b5 <vector149>:
.globl vector149
vector149:
  pushl $0
  1023b5:	6a 00                	push   $0x0
  pushl $149
  1023b7:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  1023bc:	e9 f8 04 00 00       	jmp    1028b9 <__alltraps>

001023c1 <vector150>:
.globl vector150
vector150:
  pushl $0
  1023c1:	6a 00                	push   $0x0
  pushl $150
  1023c3:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  1023c8:	e9 ec 04 00 00       	jmp    1028b9 <__alltraps>

001023cd <vector151>:
.globl vector151
vector151:
  pushl $0
  1023cd:	6a 00                	push   $0x0
  pushl $151
  1023cf:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  1023d4:	e9 e0 04 00 00       	jmp    1028b9 <__alltraps>

001023d9 <vector152>:
.globl vector152
vector152:
  pushl $0
  1023d9:	6a 00                	push   $0x0
  pushl $152
  1023db:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  1023e0:	e9 d4 04 00 00       	jmp    1028b9 <__alltraps>

001023e5 <vector153>:
.globl vector153
vector153:
  pushl $0
  1023e5:	6a 00                	push   $0x0
  pushl $153
  1023e7:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  1023ec:	e9 c8 04 00 00       	jmp    1028b9 <__alltraps>

001023f1 <vector154>:
.globl vector154
vector154:
  pushl $0
  1023f1:	6a 00                	push   $0x0
  pushl $154
  1023f3:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  1023f8:	e9 bc 04 00 00       	jmp    1028b9 <__alltraps>

001023fd <vector155>:
.globl vector155
vector155:
  pushl $0
  1023fd:	6a 00                	push   $0x0
  pushl $155
  1023ff:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  102404:	e9 b0 04 00 00       	jmp    1028b9 <__alltraps>

00102409 <vector156>:
.globl vector156
vector156:
  pushl $0
  102409:	6a 00                	push   $0x0
  pushl $156
  10240b:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  102410:	e9 a4 04 00 00       	jmp    1028b9 <__alltraps>

00102415 <vector157>:
.globl vector157
vector157:
  pushl $0
  102415:	6a 00                	push   $0x0
  pushl $157
  102417:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  10241c:	e9 98 04 00 00       	jmp    1028b9 <__alltraps>

00102421 <vector158>:
.globl vector158
vector158:
  pushl $0
  102421:	6a 00                	push   $0x0
  pushl $158
  102423:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  102428:	e9 8c 04 00 00       	jmp    1028b9 <__alltraps>

0010242d <vector159>:
.globl vector159
vector159:
  pushl $0
  10242d:	6a 00                	push   $0x0
  pushl $159
  10242f:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  102434:	e9 80 04 00 00       	jmp    1028b9 <__alltraps>

00102439 <vector160>:
.globl vector160
vector160:
  pushl $0
  102439:	6a 00                	push   $0x0
  pushl $160
  10243b:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  102440:	e9 74 04 00 00       	jmp    1028b9 <__alltraps>

00102445 <vector161>:
.globl vector161
vector161:
  pushl $0
  102445:	6a 00                	push   $0x0
  pushl $161
  102447:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  10244c:	e9 68 04 00 00       	jmp    1028b9 <__alltraps>

00102451 <vector162>:
.globl vector162
vector162:
  pushl $0
  102451:	6a 00                	push   $0x0
  pushl $162
  102453:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  102458:	e9 5c 04 00 00       	jmp    1028b9 <__alltraps>

0010245d <vector163>:
.globl vector163
vector163:
  pushl $0
  10245d:	6a 00                	push   $0x0
  pushl $163
  10245f:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  102464:	e9 50 04 00 00       	jmp    1028b9 <__alltraps>

00102469 <vector164>:
.globl vector164
vector164:
  pushl $0
  102469:	6a 00                	push   $0x0
  pushl $164
  10246b:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  102470:	e9 44 04 00 00       	jmp    1028b9 <__alltraps>

00102475 <vector165>:
.globl vector165
vector165:
  pushl $0
  102475:	6a 00                	push   $0x0
  pushl $165
  102477:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  10247c:	e9 38 04 00 00       	jmp    1028b9 <__alltraps>

00102481 <vector166>:
.globl vector166
vector166:
  pushl $0
  102481:	6a 00                	push   $0x0
  pushl $166
  102483:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  102488:	e9 2c 04 00 00       	jmp    1028b9 <__alltraps>

0010248d <vector167>:
.globl vector167
vector167:
  pushl $0
  10248d:	6a 00                	push   $0x0
  pushl $167
  10248f:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  102494:	e9 20 04 00 00       	jmp    1028b9 <__alltraps>

00102499 <vector168>:
.globl vector168
vector168:
  pushl $0
  102499:	6a 00                	push   $0x0
  pushl $168
  10249b:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  1024a0:	e9 14 04 00 00       	jmp    1028b9 <__alltraps>

001024a5 <vector169>:
.globl vector169
vector169:
  pushl $0
  1024a5:	6a 00                	push   $0x0
  pushl $169
  1024a7:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  1024ac:	e9 08 04 00 00       	jmp    1028b9 <__alltraps>

001024b1 <vector170>:
.globl vector170
vector170:
  pushl $0
  1024b1:	6a 00                	push   $0x0
  pushl $170
  1024b3:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  1024b8:	e9 fc 03 00 00       	jmp    1028b9 <__alltraps>

001024bd <vector171>:
.globl vector171
vector171:
  pushl $0
  1024bd:	6a 00                	push   $0x0
  pushl $171
  1024bf:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  1024c4:	e9 f0 03 00 00       	jmp    1028b9 <__alltraps>

001024c9 <vector172>:
.globl vector172
vector172:
  pushl $0
  1024c9:	6a 00                	push   $0x0
  pushl $172
  1024cb:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  1024d0:	e9 e4 03 00 00       	jmp    1028b9 <__alltraps>

001024d5 <vector173>:
.globl vector173
vector173:
  pushl $0
  1024d5:	6a 00                	push   $0x0
  pushl $173
  1024d7:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  1024dc:	e9 d8 03 00 00       	jmp    1028b9 <__alltraps>

001024e1 <vector174>:
.globl vector174
vector174:
  pushl $0
  1024e1:	6a 00                	push   $0x0
  pushl $174
  1024e3:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  1024e8:	e9 cc 03 00 00       	jmp    1028b9 <__alltraps>

001024ed <vector175>:
.globl vector175
vector175:
  pushl $0
  1024ed:	6a 00                	push   $0x0
  pushl $175
  1024ef:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  1024f4:	e9 c0 03 00 00       	jmp    1028b9 <__alltraps>

001024f9 <vector176>:
.globl vector176
vector176:
  pushl $0
  1024f9:	6a 00                	push   $0x0
  pushl $176
  1024fb:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  102500:	e9 b4 03 00 00       	jmp    1028b9 <__alltraps>

00102505 <vector177>:
.globl vector177
vector177:
  pushl $0
  102505:	6a 00                	push   $0x0
  pushl $177
  102507:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  10250c:	e9 a8 03 00 00       	jmp    1028b9 <__alltraps>

00102511 <vector178>:
.globl vector178
vector178:
  pushl $0
  102511:	6a 00                	push   $0x0
  pushl $178
  102513:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  102518:	e9 9c 03 00 00       	jmp    1028b9 <__alltraps>

0010251d <vector179>:
.globl vector179
vector179:
  pushl $0
  10251d:	6a 00                	push   $0x0
  pushl $179
  10251f:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  102524:	e9 90 03 00 00       	jmp    1028b9 <__alltraps>

00102529 <vector180>:
.globl vector180
vector180:
  pushl $0
  102529:	6a 00                	push   $0x0
  pushl $180
  10252b:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  102530:	e9 84 03 00 00       	jmp    1028b9 <__alltraps>

00102535 <vector181>:
.globl vector181
vector181:
  pushl $0
  102535:	6a 00                	push   $0x0
  pushl $181
  102537:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  10253c:	e9 78 03 00 00       	jmp    1028b9 <__alltraps>

00102541 <vector182>:
.globl vector182
vector182:
  pushl $0
  102541:	6a 00                	push   $0x0
  pushl $182
  102543:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  102548:	e9 6c 03 00 00       	jmp    1028b9 <__alltraps>

0010254d <vector183>:
.globl vector183
vector183:
  pushl $0
  10254d:	6a 00                	push   $0x0
  pushl $183
  10254f:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  102554:	e9 60 03 00 00       	jmp    1028b9 <__alltraps>

00102559 <vector184>:
.globl vector184
vector184:
  pushl $0
  102559:	6a 00                	push   $0x0
  pushl $184
  10255b:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  102560:	e9 54 03 00 00       	jmp    1028b9 <__alltraps>

00102565 <vector185>:
.globl vector185
vector185:
  pushl $0
  102565:	6a 00                	push   $0x0
  pushl $185
  102567:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  10256c:	e9 48 03 00 00       	jmp    1028b9 <__alltraps>

00102571 <vector186>:
.globl vector186
vector186:
  pushl $0
  102571:	6a 00                	push   $0x0
  pushl $186
  102573:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  102578:	e9 3c 03 00 00       	jmp    1028b9 <__alltraps>

0010257d <vector187>:
.globl vector187
vector187:
  pushl $0
  10257d:	6a 00                	push   $0x0
  pushl $187
  10257f:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  102584:	e9 30 03 00 00       	jmp    1028b9 <__alltraps>

00102589 <vector188>:
.globl vector188
vector188:
  pushl $0
  102589:	6a 00                	push   $0x0
  pushl $188
  10258b:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  102590:	e9 24 03 00 00       	jmp    1028b9 <__alltraps>

00102595 <vector189>:
.globl vector189
vector189:
  pushl $0
  102595:	6a 00                	push   $0x0
  pushl $189
  102597:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  10259c:	e9 18 03 00 00       	jmp    1028b9 <__alltraps>

001025a1 <vector190>:
.globl vector190
vector190:
  pushl $0
  1025a1:	6a 00                	push   $0x0
  pushl $190
  1025a3:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  1025a8:	e9 0c 03 00 00       	jmp    1028b9 <__alltraps>

001025ad <vector191>:
.globl vector191
vector191:
  pushl $0
  1025ad:	6a 00                	push   $0x0
  pushl $191
  1025af:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  1025b4:	e9 00 03 00 00       	jmp    1028b9 <__alltraps>

001025b9 <vector192>:
.globl vector192
vector192:
  pushl $0
  1025b9:	6a 00                	push   $0x0
  pushl $192
  1025bb:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  1025c0:	e9 f4 02 00 00       	jmp    1028b9 <__alltraps>

001025c5 <vector193>:
.globl vector193
vector193:
  pushl $0
  1025c5:	6a 00                	push   $0x0
  pushl $193
  1025c7:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  1025cc:	e9 e8 02 00 00       	jmp    1028b9 <__alltraps>

001025d1 <vector194>:
.globl vector194
vector194:
  pushl $0
  1025d1:	6a 00                	push   $0x0
  pushl $194
  1025d3:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  1025d8:	e9 dc 02 00 00       	jmp    1028b9 <__alltraps>

001025dd <vector195>:
.globl vector195
vector195:
  pushl $0
  1025dd:	6a 00                	push   $0x0
  pushl $195
  1025df:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  1025e4:	e9 d0 02 00 00       	jmp    1028b9 <__alltraps>

001025e9 <vector196>:
.globl vector196
vector196:
  pushl $0
  1025e9:	6a 00                	push   $0x0
  pushl $196
  1025eb:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  1025f0:	e9 c4 02 00 00       	jmp    1028b9 <__alltraps>

001025f5 <vector197>:
.globl vector197
vector197:
  pushl $0
  1025f5:	6a 00                	push   $0x0
  pushl $197
  1025f7:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  1025fc:	e9 b8 02 00 00       	jmp    1028b9 <__alltraps>

00102601 <vector198>:
.globl vector198
vector198:
  pushl $0
  102601:	6a 00                	push   $0x0
  pushl $198
  102603:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  102608:	e9 ac 02 00 00       	jmp    1028b9 <__alltraps>

0010260d <vector199>:
.globl vector199
vector199:
  pushl $0
  10260d:	6a 00                	push   $0x0
  pushl $199
  10260f:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  102614:	e9 a0 02 00 00       	jmp    1028b9 <__alltraps>

00102619 <vector200>:
.globl vector200
vector200:
  pushl $0
  102619:	6a 00                	push   $0x0
  pushl $200
  10261b:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  102620:	e9 94 02 00 00       	jmp    1028b9 <__alltraps>

00102625 <vector201>:
.globl vector201
vector201:
  pushl $0
  102625:	6a 00                	push   $0x0
  pushl $201
  102627:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  10262c:	e9 88 02 00 00       	jmp    1028b9 <__alltraps>

00102631 <vector202>:
.globl vector202
vector202:
  pushl $0
  102631:	6a 00                	push   $0x0
  pushl $202
  102633:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  102638:	e9 7c 02 00 00       	jmp    1028b9 <__alltraps>

0010263d <vector203>:
.globl vector203
vector203:
  pushl $0
  10263d:	6a 00                	push   $0x0
  pushl $203
  10263f:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  102644:	e9 70 02 00 00       	jmp    1028b9 <__alltraps>

00102649 <vector204>:
.globl vector204
vector204:
  pushl $0
  102649:	6a 00                	push   $0x0
  pushl $204
  10264b:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  102650:	e9 64 02 00 00       	jmp    1028b9 <__alltraps>

00102655 <vector205>:
.globl vector205
vector205:
  pushl $0
  102655:	6a 00                	push   $0x0
  pushl $205
  102657:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  10265c:	e9 58 02 00 00       	jmp    1028b9 <__alltraps>

00102661 <vector206>:
.globl vector206
vector206:
  pushl $0
  102661:	6a 00                	push   $0x0
  pushl $206
  102663:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  102668:	e9 4c 02 00 00       	jmp    1028b9 <__alltraps>

0010266d <vector207>:
.globl vector207
vector207:
  pushl $0
  10266d:	6a 00                	push   $0x0
  pushl $207
  10266f:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  102674:	e9 40 02 00 00       	jmp    1028b9 <__alltraps>

00102679 <vector208>:
.globl vector208
vector208:
  pushl $0
  102679:	6a 00                	push   $0x0
  pushl $208
  10267b:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  102680:	e9 34 02 00 00       	jmp    1028b9 <__alltraps>

00102685 <vector209>:
.globl vector209
vector209:
  pushl $0
  102685:	6a 00                	push   $0x0
  pushl $209
  102687:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  10268c:	e9 28 02 00 00       	jmp    1028b9 <__alltraps>

00102691 <vector210>:
.globl vector210
vector210:
  pushl $0
  102691:	6a 00                	push   $0x0
  pushl $210
  102693:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  102698:	e9 1c 02 00 00       	jmp    1028b9 <__alltraps>

0010269d <vector211>:
.globl vector211
vector211:
  pushl $0
  10269d:	6a 00                	push   $0x0
  pushl $211
  10269f:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  1026a4:	e9 10 02 00 00       	jmp    1028b9 <__alltraps>

001026a9 <vector212>:
.globl vector212
vector212:
  pushl $0
  1026a9:	6a 00                	push   $0x0
  pushl $212
  1026ab:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  1026b0:	e9 04 02 00 00       	jmp    1028b9 <__alltraps>

001026b5 <vector213>:
.globl vector213
vector213:
  pushl $0
  1026b5:	6a 00                	push   $0x0
  pushl $213
  1026b7:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  1026bc:	e9 f8 01 00 00       	jmp    1028b9 <__alltraps>

001026c1 <vector214>:
.globl vector214
vector214:
  pushl $0
  1026c1:	6a 00                	push   $0x0
  pushl $214
  1026c3:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  1026c8:	e9 ec 01 00 00       	jmp    1028b9 <__alltraps>

001026cd <vector215>:
.globl vector215
vector215:
  pushl $0
  1026cd:	6a 00                	push   $0x0
  pushl $215
  1026cf:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  1026d4:	e9 e0 01 00 00       	jmp    1028b9 <__alltraps>

001026d9 <vector216>:
.globl vector216
vector216:
  pushl $0
  1026d9:	6a 00                	push   $0x0
  pushl $216
  1026db:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  1026e0:	e9 d4 01 00 00       	jmp    1028b9 <__alltraps>

001026e5 <vector217>:
.globl vector217
vector217:
  pushl $0
  1026e5:	6a 00                	push   $0x0
  pushl $217
  1026e7:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  1026ec:	e9 c8 01 00 00       	jmp    1028b9 <__alltraps>

001026f1 <vector218>:
.globl vector218
vector218:
  pushl $0
  1026f1:	6a 00                	push   $0x0
  pushl $218
  1026f3:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  1026f8:	e9 bc 01 00 00       	jmp    1028b9 <__alltraps>

001026fd <vector219>:
.globl vector219
vector219:
  pushl $0
  1026fd:	6a 00                	push   $0x0
  pushl $219
  1026ff:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  102704:	e9 b0 01 00 00       	jmp    1028b9 <__alltraps>

00102709 <vector220>:
.globl vector220
vector220:
  pushl $0
  102709:	6a 00                	push   $0x0
  pushl $220
  10270b:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  102710:	e9 a4 01 00 00       	jmp    1028b9 <__alltraps>

00102715 <vector221>:
.globl vector221
vector221:
  pushl $0
  102715:	6a 00                	push   $0x0
  pushl $221
  102717:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  10271c:	e9 98 01 00 00       	jmp    1028b9 <__alltraps>

00102721 <vector222>:
.globl vector222
vector222:
  pushl $0
  102721:	6a 00                	push   $0x0
  pushl $222
  102723:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  102728:	e9 8c 01 00 00       	jmp    1028b9 <__alltraps>

0010272d <vector223>:
.globl vector223
vector223:
  pushl $0
  10272d:	6a 00                	push   $0x0
  pushl $223
  10272f:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  102734:	e9 80 01 00 00       	jmp    1028b9 <__alltraps>

00102739 <vector224>:
.globl vector224
vector224:
  pushl $0
  102739:	6a 00                	push   $0x0
  pushl $224
  10273b:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  102740:	e9 74 01 00 00       	jmp    1028b9 <__alltraps>

00102745 <vector225>:
.globl vector225
vector225:
  pushl $0
  102745:	6a 00                	push   $0x0
  pushl $225
  102747:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  10274c:	e9 68 01 00 00       	jmp    1028b9 <__alltraps>

00102751 <vector226>:
.globl vector226
vector226:
  pushl $0
  102751:	6a 00                	push   $0x0
  pushl $226
  102753:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  102758:	e9 5c 01 00 00       	jmp    1028b9 <__alltraps>

0010275d <vector227>:
.globl vector227
vector227:
  pushl $0
  10275d:	6a 00                	push   $0x0
  pushl $227
  10275f:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  102764:	e9 50 01 00 00       	jmp    1028b9 <__alltraps>

00102769 <vector228>:
.globl vector228
vector228:
  pushl $0
  102769:	6a 00                	push   $0x0
  pushl $228
  10276b:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  102770:	e9 44 01 00 00       	jmp    1028b9 <__alltraps>

00102775 <vector229>:
.globl vector229
vector229:
  pushl $0
  102775:	6a 00                	push   $0x0
  pushl $229
  102777:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  10277c:	e9 38 01 00 00       	jmp    1028b9 <__alltraps>

00102781 <vector230>:
.globl vector230
vector230:
  pushl $0
  102781:	6a 00                	push   $0x0
  pushl $230
  102783:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  102788:	e9 2c 01 00 00       	jmp    1028b9 <__alltraps>

0010278d <vector231>:
.globl vector231
vector231:
  pushl $0
  10278d:	6a 00                	push   $0x0
  pushl $231
  10278f:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  102794:	e9 20 01 00 00       	jmp    1028b9 <__alltraps>

00102799 <vector232>:
.globl vector232
vector232:
  pushl $0
  102799:	6a 00                	push   $0x0
  pushl $232
  10279b:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  1027a0:	e9 14 01 00 00       	jmp    1028b9 <__alltraps>

001027a5 <vector233>:
.globl vector233
vector233:
  pushl $0
  1027a5:	6a 00                	push   $0x0
  pushl $233
  1027a7:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  1027ac:	e9 08 01 00 00       	jmp    1028b9 <__alltraps>

001027b1 <vector234>:
.globl vector234
vector234:
  pushl $0
  1027b1:	6a 00                	push   $0x0
  pushl $234
  1027b3:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  1027b8:	e9 fc 00 00 00       	jmp    1028b9 <__alltraps>

001027bd <vector235>:
.globl vector235
vector235:
  pushl $0
  1027bd:	6a 00                	push   $0x0
  pushl $235
  1027bf:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  1027c4:	e9 f0 00 00 00       	jmp    1028b9 <__alltraps>

001027c9 <vector236>:
.globl vector236
vector236:
  pushl $0
  1027c9:	6a 00                	push   $0x0
  pushl $236
  1027cb:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  1027d0:	e9 e4 00 00 00       	jmp    1028b9 <__alltraps>

001027d5 <vector237>:
.globl vector237
vector237:
  pushl $0
  1027d5:	6a 00                	push   $0x0
  pushl $237
  1027d7:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  1027dc:	e9 d8 00 00 00       	jmp    1028b9 <__alltraps>

001027e1 <vector238>:
.globl vector238
vector238:
  pushl $0
  1027e1:	6a 00                	push   $0x0
  pushl $238
  1027e3:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  1027e8:	e9 cc 00 00 00       	jmp    1028b9 <__alltraps>

001027ed <vector239>:
.globl vector239
vector239:
  pushl $0
  1027ed:	6a 00                	push   $0x0
  pushl $239
  1027ef:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  1027f4:	e9 c0 00 00 00       	jmp    1028b9 <__alltraps>

001027f9 <vector240>:
.globl vector240
vector240:
  pushl $0
  1027f9:	6a 00                	push   $0x0
  pushl $240
  1027fb:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  102800:	e9 b4 00 00 00       	jmp    1028b9 <__alltraps>

00102805 <vector241>:
.globl vector241
vector241:
  pushl $0
  102805:	6a 00                	push   $0x0
  pushl $241
  102807:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  10280c:	e9 a8 00 00 00       	jmp    1028b9 <__alltraps>

00102811 <vector242>:
.globl vector242
vector242:
  pushl $0
  102811:	6a 00                	push   $0x0
  pushl $242
  102813:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  102818:	e9 9c 00 00 00       	jmp    1028b9 <__alltraps>

0010281d <vector243>:
.globl vector243
vector243:
  pushl $0
  10281d:	6a 00                	push   $0x0
  pushl $243
  10281f:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  102824:	e9 90 00 00 00       	jmp    1028b9 <__alltraps>

00102829 <vector244>:
.globl vector244
vector244:
  pushl $0
  102829:	6a 00                	push   $0x0
  pushl $244
  10282b:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  102830:	e9 84 00 00 00       	jmp    1028b9 <__alltraps>

00102835 <vector245>:
.globl vector245
vector245:
  pushl $0
  102835:	6a 00                	push   $0x0
  pushl $245
  102837:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  10283c:	e9 78 00 00 00       	jmp    1028b9 <__alltraps>

00102841 <vector246>:
.globl vector246
vector246:
  pushl $0
  102841:	6a 00                	push   $0x0
  pushl $246
  102843:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  102848:	e9 6c 00 00 00       	jmp    1028b9 <__alltraps>

0010284d <vector247>:
.globl vector247
vector247:
  pushl $0
  10284d:	6a 00                	push   $0x0
  pushl $247
  10284f:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  102854:	e9 60 00 00 00       	jmp    1028b9 <__alltraps>

00102859 <vector248>:
.globl vector248
vector248:
  pushl $0
  102859:	6a 00                	push   $0x0
  pushl $248
  10285b:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  102860:	e9 54 00 00 00       	jmp    1028b9 <__alltraps>

00102865 <vector249>:
.globl vector249
vector249:
  pushl $0
  102865:	6a 00                	push   $0x0
  pushl $249
  102867:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  10286c:	e9 48 00 00 00       	jmp    1028b9 <__alltraps>

00102871 <vector250>:
.globl vector250
vector250:
  pushl $0
  102871:	6a 00                	push   $0x0
  pushl $250
  102873:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  102878:	e9 3c 00 00 00       	jmp    1028b9 <__alltraps>

0010287d <vector251>:
.globl vector251
vector251:
  pushl $0
  10287d:	6a 00                	push   $0x0
  pushl $251
  10287f:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  102884:	e9 30 00 00 00       	jmp    1028b9 <__alltraps>

00102889 <vector252>:
.globl vector252
vector252:
  pushl $0
  102889:	6a 00                	push   $0x0
  pushl $252
  10288b:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  102890:	e9 24 00 00 00       	jmp    1028b9 <__alltraps>

00102895 <vector253>:
.globl vector253
vector253:
  pushl $0
  102895:	6a 00                	push   $0x0
  pushl $253
  102897:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  10289c:	e9 18 00 00 00       	jmp    1028b9 <__alltraps>

001028a1 <vector254>:
.globl vector254
vector254:
  pushl $0
  1028a1:	6a 00                	push   $0x0
  pushl $254
  1028a3:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  1028a8:	e9 0c 00 00 00       	jmp    1028b9 <__alltraps>

001028ad <vector255>:
.globl vector255
vector255:
  pushl $0
  1028ad:	6a 00                	push   $0x0
  pushl $255
  1028af:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  1028b4:	e9 00 00 00 00       	jmp    1028b9 <__alltraps>

001028b9 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  1028b9:	1e                   	push   %ds
    pushl %es
  1028ba:	06                   	push   %es
    pushl %fs
  1028bb:	0f a0                	push   %fs
    pushl %gs
  1028bd:	0f a8                	push   %gs
    pushal
  1028bf:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  1028c0:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  1028c5:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  1028c7:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  1028c9:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  1028ca:	e8 65 f5 ff ff       	call   101e34 <trap>

    # pop the pushed stack pointer
    popl %esp
  1028cf:	5c                   	pop    %esp

001028d0 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  1028d0:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  1028d1:	0f a9                	pop    %gs
    popl %fs
  1028d3:	0f a1                	pop    %fs
    popl %es
  1028d5:	07                   	pop    %es
    popl %ds
  1028d6:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  1028d7:	83 c4 08             	add    $0x8,%esp
    iret
  1028da:	cf                   	iret   

001028db <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  1028db:	55                   	push   %ebp
  1028dc:	89 e5                	mov    %esp,%ebp
    return page - pages;
  1028de:	8b 55 08             	mov    0x8(%ebp),%edx
  1028e1:	a1 18 af 11 00       	mov    0x11af18,%eax
  1028e6:	29 c2                	sub    %eax,%edx
  1028e8:	89 d0                	mov    %edx,%eax
  1028ea:	c1 f8 02             	sar    $0x2,%eax
  1028ed:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  1028f3:	5d                   	pop    %ebp
  1028f4:	c3                   	ret    

001028f5 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  1028f5:	55                   	push   %ebp
  1028f6:	89 e5                	mov    %esp,%ebp
  1028f8:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  1028fb:	8b 45 08             	mov    0x8(%ebp),%eax
  1028fe:	89 04 24             	mov    %eax,(%esp)
  102901:	e8 d5 ff ff ff       	call   1028db <page2ppn>
  102906:	c1 e0 0c             	shl    $0xc,%eax
}
  102909:	c9                   	leave  
  10290a:	c3                   	ret    

0010290b <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
  10290b:	55                   	push   %ebp
  10290c:	89 e5                	mov    %esp,%ebp
  10290e:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
  102911:	8b 45 08             	mov    0x8(%ebp),%eax
  102914:	c1 e8 0c             	shr    $0xc,%eax
  102917:	89 c2                	mov    %eax,%edx
  102919:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  10291e:	39 c2                	cmp    %eax,%edx
  102920:	72 1c                	jb     10293e <pa2page+0x33>
        panic("pa2page called with invalid pa");
  102922:	c7 44 24 08 90 66 10 	movl   $0x106690,0x8(%esp)
  102929:	00 
  10292a:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  102931:	00 
  102932:	c7 04 24 af 66 10 00 	movl   $0x1066af,(%esp)
  102939:	e8 ab da ff ff       	call   1003e9 <__panic>
    }
    return &pages[PPN(pa)];
  10293e:	8b 0d 18 af 11 00    	mov    0x11af18,%ecx
  102944:	8b 45 08             	mov    0x8(%ebp),%eax
  102947:	c1 e8 0c             	shr    $0xc,%eax
  10294a:	89 c2                	mov    %eax,%edx
  10294c:	89 d0                	mov    %edx,%eax
  10294e:	c1 e0 02             	shl    $0x2,%eax
  102951:	01 d0                	add    %edx,%eax
  102953:	c1 e0 02             	shl    $0x2,%eax
  102956:	01 c8                	add    %ecx,%eax
}
  102958:	c9                   	leave  
  102959:	c3                   	ret    

0010295a <page2kva>:

static inline void *
page2kva(struct Page *page) {
  10295a:	55                   	push   %ebp
  10295b:	89 e5                	mov    %esp,%ebp
  10295d:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
  102960:	8b 45 08             	mov    0x8(%ebp),%eax
  102963:	89 04 24             	mov    %eax,(%esp)
  102966:	e8 8a ff ff ff       	call   1028f5 <page2pa>
  10296b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10296e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102971:	c1 e8 0c             	shr    $0xc,%eax
  102974:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102977:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  10297c:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  10297f:	72 23                	jb     1029a4 <page2kva+0x4a>
  102981:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102984:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102988:	c7 44 24 08 c0 66 10 	movl   $0x1066c0,0x8(%esp)
  10298f:	00 
  102990:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  102997:	00 
  102998:	c7 04 24 af 66 10 00 	movl   $0x1066af,(%esp)
  10299f:	e8 45 da ff ff       	call   1003e9 <__panic>
  1029a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1029a7:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
  1029ac:	c9                   	leave  
  1029ad:	c3                   	ret    

001029ae <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
  1029ae:	55                   	push   %ebp
  1029af:	89 e5                	mov    %esp,%ebp
  1029b1:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
  1029b4:	8b 45 08             	mov    0x8(%ebp),%eax
  1029b7:	83 e0 01             	and    $0x1,%eax
  1029ba:	85 c0                	test   %eax,%eax
  1029bc:	75 1c                	jne    1029da <pte2page+0x2c>
        panic("pte2page called with invalid pte");
  1029be:	c7 44 24 08 e4 66 10 	movl   $0x1066e4,0x8(%esp)
  1029c5:	00 
  1029c6:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  1029cd:	00 
  1029ce:	c7 04 24 af 66 10 00 	movl   $0x1066af,(%esp)
  1029d5:	e8 0f da ff ff       	call   1003e9 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
  1029da:	8b 45 08             	mov    0x8(%ebp),%eax
  1029dd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1029e2:	89 04 24             	mov    %eax,(%esp)
  1029e5:	e8 21 ff ff ff       	call   10290b <pa2page>
}
  1029ea:	c9                   	leave  
  1029eb:	c3                   	ret    

001029ec <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
  1029ec:	55                   	push   %ebp
  1029ed:	89 e5                	mov    %esp,%ebp
  1029ef:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
  1029f2:	8b 45 08             	mov    0x8(%ebp),%eax
  1029f5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1029fa:	89 04 24             	mov    %eax,(%esp)
  1029fd:	e8 09 ff ff ff       	call   10290b <pa2page>
}
  102a02:	c9                   	leave  
  102a03:	c3                   	ret    

00102a04 <page_ref>:

static inline int
page_ref(struct Page *page) {
  102a04:	55                   	push   %ebp
  102a05:	89 e5                	mov    %esp,%ebp
    return page->ref;
  102a07:	8b 45 08             	mov    0x8(%ebp),%eax
  102a0a:	8b 00                	mov    (%eax),%eax
}
  102a0c:	5d                   	pop    %ebp
  102a0d:	c3                   	ret    

00102a0e <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  102a0e:	55                   	push   %ebp
  102a0f:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  102a11:	8b 45 08             	mov    0x8(%ebp),%eax
  102a14:	8b 55 0c             	mov    0xc(%ebp),%edx
  102a17:	89 10                	mov    %edx,(%eax)
}
  102a19:	5d                   	pop    %ebp
  102a1a:	c3                   	ret    

00102a1b <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
  102a1b:	55                   	push   %ebp
  102a1c:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
  102a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  102a21:	8b 00                	mov    (%eax),%eax
  102a23:	8d 50 01             	lea    0x1(%eax),%edx
  102a26:	8b 45 08             	mov    0x8(%ebp),%eax
  102a29:	89 10                	mov    %edx,(%eax)
    return page->ref;
  102a2b:	8b 45 08             	mov    0x8(%ebp),%eax
  102a2e:	8b 00                	mov    (%eax),%eax
}
  102a30:	5d                   	pop    %ebp
  102a31:	c3                   	ret    

00102a32 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
  102a32:	55                   	push   %ebp
  102a33:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
  102a35:	8b 45 08             	mov    0x8(%ebp),%eax
  102a38:	8b 00                	mov    (%eax),%eax
  102a3a:	8d 50 ff             	lea    -0x1(%eax),%edx
  102a3d:	8b 45 08             	mov    0x8(%ebp),%eax
  102a40:	89 10                	mov    %edx,(%eax)
    return page->ref;
  102a42:	8b 45 08             	mov    0x8(%ebp),%eax
  102a45:	8b 00                	mov    (%eax),%eax
}
  102a47:	5d                   	pop    %ebp
  102a48:	c3                   	ret    

00102a49 <__intr_save>:
__intr_save(void) {
  102a49:	55                   	push   %ebp
  102a4a:	89 e5                	mov    %esp,%ebp
  102a4c:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  102a4f:	9c                   	pushf  
  102a50:	58                   	pop    %eax
  102a51:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  102a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  102a57:	25 00 02 00 00       	and    $0x200,%eax
  102a5c:	85 c0                	test   %eax,%eax
  102a5e:	74 0c                	je     102a6c <__intr_save+0x23>
        intr_disable();
  102a60:	e8 2c ee ff ff       	call   101891 <intr_disable>
        return 1;
  102a65:	b8 01 00 00 00       	mov    $0x1,%eax
  102a6a:	eb 05                	jmp    102a71 <__intr_save+0x28>
    return 0;
  102a6c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102a71:	c9                   	leave  
  102a72:	c3                   	ret    

00102a73 <__intr_restore>:
__intr_restore(bool flag) {
  102a73:	55                   	push   %ebp
  102a74:	89 e5                	mov    %esp,%ebp
  102a76:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  102a79:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  102a7d:	74 05                	je     102a84 <__intr_restore+0x11>
        intr_enable();
  102a7f:	e8 07 ee ff ff       	call   10188b <intr_enable>
}
  102a84:	c9                   	leave  
  102a85:	c3                   	ret    

00102a86 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  102a86:	55                   	push   %ebp
  102a87:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  102a89:	8b 45 08             	mov    0x8(%ebp),%eax
  102a8c:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  102a8f:	b8 23 00 00 00       	mov    $0x23,%eax
  102a94:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  102a96:	b8 23 00 00 00       	mov    $0x23,%eax
  102a9b:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  102a9d:	b8 10 00 00 00       	mov    $0x10,%eax
  102aa2:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  102aa4:	b8 10 00 00 00       	mov    $0x10,%eax
  102aa9:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  102aab:	b8 10 00 00 00       	mov    $0x10,%eax
  102ab0:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  102ab2:	ea b9 2a 10 00 08 00 	ljmp   $0x8,$0x102ab9
}
  102ab9:	5d                   	pop    %ebp
  102aba:	c3                   	ret    

00102abb <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
  102abb:	55                   	push   %ebp
  102abc:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
  102abe:	8b 45 08             	mov    0x8(%ebp),%eax
  102ac1:	a3 a4 ae 11 00       	mov    %eax,0x11aea4
}
  102ac6:	5d                   	pop    %ebp
  102ac7:	c3                   	ret    

00102ac8 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  102ac8:	55                   	push   %ebp
  102ac9:	89 e5                	mov    %esp,%ebp
  102acb:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
  102ace:	b8 00 70 11 00       	mov    $0x117000,%eax
  102ad3:	89 04 24             	mov    %eax,(%esp)
  102ad6:	e8 e0 ff ff ff       	call   102abb <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
  102adb:	66 c7 05 a8 ae 11 00 	movw   $0x10,0x11aea8
  102ae2:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
  102ae4:	66 c7 05 28 7a 11 00 	movw   $0x68,0x117a28
  102aeb:	68 00 
  102aed:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  102af2:	66 a3 2a 7a 11 00    	mov    %ax,0x117a2a
  102af8:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  102afd:	c1 e8 10             	shr    $0x10,%eax
  102b00:	a2 2c 7a 11 00       	mov    %al,0x117a2c
  102b05:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  102b0c:	83 e0 f0             	and    $0xfffffff0,%eax
  102b0f:	83 c8 09             	or     $0x9,%eax
  102b12:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  102b17:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  102b1e:	83 e0 ef             	and    $0xffffffef,%eax
  102b21:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  102b26:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  102b2d:	83 e0 9f             	and    $0xffffff9f,%eax
  102b30:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  102b35:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  102b3c:	83 c8 80             	or     $0xffffff80,%eax
  102b3f:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  102b44:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102b4b:	83 e0 f0             	and    $0xfffffff0,%eax
  102b4e:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102b53:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102b5a:	83 e0 ef             	and    $0xffffffef,%eax
  102b5d:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102b62:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102b69:	83 e0 df             	and    $0xffffffdf,%eax
  102b6c:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102b71:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102b78:	83 c8 40             	or     $0x40,%eax
  102b7b:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102b80:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102b87:	83 e0 7f             	and    $0x7f,%eax
  102b8a:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102b8f:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  102b94:	c1 e8 18             	shr    $0x18,%eax
  102b97:	a2 2f 7a 11 00       	mov    %al,0x117a2f

    // reload all segment registers
    lgdt(&gdt_pd);
  102b9c:	c7 04 24 30 7a 11 00 	movl   $0x117a30,(%esp)
  102ba3:	e8 de fe ff ff       	call   102a86 <lgdt>
  102ba8:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
  102bae:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  102bb2:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  102bb5:	c9                   	leave  
  102bb6:	c3                   	ret    

00102bb7 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
  102bb7:	55                   	push   %ebp
  102bb8:	89 e5                	mov    %esp,%ebp
  102bba:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
  102bbd:	c7 05 10 af 11 00 58 	movl   $0x107058,0x11af10
  102bc4:	70 10 00 
    cprintf("memory management: %s\n", pmm_manager->name);
  102bc7:	a1 10 af 11 00       	mov    0x11af10,%eax
  102bcc:	8b 00                	mov    (%eax),%eax
  102bce:	89 44 24 04          	mov    %eax,0x4(%esp)
  102bd2:	c7 04 24 10 67 10 00 	movl   $0x106710,(%esp)
  102bd9:	e8 b4 d6 ff ff       	call   100292 <cprintf>
    pmm_manager->init();
  102bde:	a1 10 af 11 00       	mov    0x11af10,%eax
  102be3:	8b 40 04             	mov    0x4(%eax),%eax
  102be6:	ff d0                	call   *%eax
}
  102be8:	c9                   	leave  
  102be9:	c3                   	ret    

00102bea <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
  102bea:	55                   	push   %ebp
  102beb:	89 e5                	mov    %esp,%ebp
  102bed:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
  102bf0:	a1 10 af 11 00       	mov    0x11af10,%eax
  102bf5:	8b 40 08             	mov    0x8(%eax),%eax
  102bf8:	8b 55 0c             	mov    0xc(%ebp),%edx
  102bfb:	89 54 24 04          	mov    %edx,0x4(%esp)
  102bff:	8b 55 08             	mov    0x8(%ebp),%edx
  102c02:	89 14 24             	mov    %edx,(%esp)
  102c05:	ff d0                	call   *%eax
}
  102c07:	c9                   	leave  
  102c08:	c3                   	ret    

00102c09 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
  102c09:	55                   	push   %ebp
  102c0a:	89 e5                	mov    %esp,%ebp
  102c0c:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
  102c0f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  102c16:	e8 2e fe ff ff       	call   102a49 <__intr_save>
  102c1b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
  102c1e:	a1 10 af 11 00       	mov    0x11af10,%eax
  102c23:	8b 40 0c             	mov    0xc(%eax),%eax
  102c26:	8b 55 08             	mov    0x8(%ebp),%edx
  102c29:	89 14 24             	mov    %edx,(%esp)
  102c2c:	ff d0                	call   *%eax
  102c2e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
  102c31:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102c34:	89 04 24             	mov    %eax,(%esp)
  102c37:	e8 37 fe ff ff       	call   102a73 <__intr_restore>
    return page;
  102c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  102c3f:	c9                   	leave  
  102c40:	c3                   	ret    

00102c41 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
  102c41:	55                   	push   %ebp
  102c42:	89 e5                	mov    %esp,%ebp
  102c44:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  102c47:	e8 fd fd ff ff       	call   102a49 <__intr_save>
  102c4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
  102c4f:	a1 10 af 11 00       	mov    0x11af10,%eax
  102c54:	8b 40 10             	mov    0x10(%eax),%eax
  102c57:	8b 55 0c             	mov    0xc(%ebp),%edx
  102c5a:	89 54 24 04          	mov    %edx,0x4(%esp)
  102c5e:	8b 55 08             	mov    0x8(%ebp),%edx
  102c61:	89 14 24             	mov    %edx,(%esp)
  102c64:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
  102c66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c69:	89 04 24             	mov    %eax,(%esp)
  102c6c:	e8 02 fe ff ff       	call   102a73 <__intr_restore>
}
  102c71:	c9                   	leave  
  102c72:	c3                   	ret    

00102c73 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
  102c73:	55                   	push   %ebp
  102c74:	89 e5                	mov    %esp,%ebp
  102c76:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
  102c79:	e8 cb fd ff ff       	call   102a49 <__intr_save>
  102c7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
  102c81:	a1 10 af 11 00       	mov    0x11af10,%eax
  102c86:	8b 40 14             	mov    0x14(%eax),%eax
  102c89:	ff d0                	call   *%eax
  102c8b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
  102c8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c91:	89 04 24             	mov    %eax,(%esp)
  102c94:	e8 da fd ff ff       	call   102a73 <__intr_restore>
    return ret;
  102c99:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  102c9c:	c9                   	leave  
  102c9d:	c3                   	ret    

00102c9e <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
  102c9e:	55                   	push   %ebp
  102c9f:	89 e5                	mov    %esp,%ebp
  102ca1:	57                   	push   %edi
  102ca2:	56                   	push   %esi
  102ca3:	53                   	push   %ebx
  102ca4:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
  102caa:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
  102cb1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  102cb8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
  102cbf:	c7 04 24 27 67 10 00 	movl   $0x106727,(%esp)
  102cc6:	e8 c7 d5 ff ff       	call   100292 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  102ccb:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102cd2:	e9 15 01 00 00       	jmp    102dec <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  102cd7:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102cda:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102cdd:	89 d0                	mov    %edx,%eax
  102cdf:	c1 e0 02             	shl    $0x2,%eax
  102ce2:	01 d0                	add    %edx,%eax
  102ce4:	c1 e0 02             	shl    $0x2,%eax
  102ce7:	01 c8                	add    %ecx,%eax
  102ce9:	8b 50 08             	mov    0x8(%eax),%edx
  102cec:	8b 40 04             	mov    0x4(%eax),%eax
  102cef:	89 45 b8             	mov    %eax,-0x48(%ebp)
  102cf2:	89 55 bc             	mov    %edx,-0x44(%ebp)
  102cf5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102cf8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102cfb:	89 d0                	mov    %edx,%eax
  102cfd:	c1 e0 02             	shl    $0x2,%eax
  102d00:	01 d0                	add    %edx,%eax
  102d02:	c1 e0 02             	shl    $0x2,%eax
  102d05:	01 c8                	add    %ecx,%eax
  102d07:	8b 48 0c             	mov    0xc(%eax),%ecx
  102d0a:	8b 58 10             	mov    0x10(%eax),%ebx
  102d0d:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102d10:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102d13:	01 c8                	add    %ecx,%eax
  102d15:	11 da                	adc    %ebx,%edx
  102d17:	89 45 b0             	mov    %eax,-0x50(%ebp)
  102d1a:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
  102d1d:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102d20:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102d23:	89 d0                	mov    %edx,%eax
  102d25:	c1 e0 02             	shl    $0x2,%eax
  102d28:	01 d0                	add    %edx,%eax
  102d2a:	c1 e0 02             	shl    $0x2,%eax
  102d2d:	01 c8                	add    %ecx,%eax
  102d2f:	83 c0 14             	add    $0x14,%eax
  102d32:	8b 00                	mov    (%eax),%eax
  102d34:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
  102d3a:	8b 45 b0             	mov    -0x50(%ebp),%eax
  102d3d:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  102d40:	83 c0 ff             	add    $0xffffffff,%eax
  102d43:	83 d2 ff             	adc    $0xffffffff,%edx
  102d46:	89 c6                	mov    %eax,%esi
  102d48:	89 d7                	mov    %edx,%edi
  102d4a:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102d4d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102d50:	89 d0                	mov    %edx,%eax
  102d52:	c1 e0 02             	shl    $0x2,%eax
  102d55:	01 d0                	add    %edx,%eax
  102d57:	c1 e0 02             	shl    $0x2,%eax
  102d5a:	01 c8                	add    %ecx,%eax
  102d5c:	8b 48 0c             	mov    0xc(%eax),%ecx
  102d5f:	8b 58 10             	mov    0x10(%eax),%ebx
  102d62:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  102d68:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  102d6c:	89 74 24 14          	mov    %esi,0x14(%esp)
  102d70:	89 7c 24 18          	mov    %edi,0x18(%esp)
  102d74:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102d77:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102d7a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102d7e:	89 54 24 10          	mov    %edx,0x10(%esp)
  102d82:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  102d86:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  102d8a:	c7 04 24 34 67 10 00 	movl   $0x106734,(%esp)
  102d91:	e8 fc d4 ff ff       	call   100292 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
  102d96:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102d99:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102d9c:	89 d0                	mov    %edx,%eax
  102d9e:	c1 e0 02             	shl    $0x2,%eax
  102da1:	01 d0                	add    %edx,%eax
  102da3:	c1 e0 02             	shl    $0x2,%eax
  102da6:	01 c8                	add    %ecx,%eax
  102da8:	83 c0 14             	add    $0x14,%eax
  102dab:	8b 00                	mov    (%eax),%eax
  102dad:	83 f8 01             	cmp    $0x1,%eax
  102db0:	75 36                	jne    102de8 <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
  102db2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102db5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102db8:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
  102dbb:	77 2b                	ja     102de8 <page_init+0x14a>
  102dbd:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
  102dc0:	72 05                	jb     102dc7 <page_init+0x129>
  102dc2:	3b 45 b0             	cmp    -0x50(%ebp),%eax
  102dc5:	73 21                	jae    102de8 <page_init+0x14a>
  102dc7:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  102dcb:	77 1b                	ja     102de8 <page_init+0x14a>
  102dcd:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  102dd1:	72 09                	jb     102ddc <page_init+0x13e>
  102dd3:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
  102dda:	77 0c                	ja     102de8 <page_init+0x14a>
                maxpa = end;
  102ddc:	8b 45 b0             	mov    -0x50(%ebp),%eax
  102ddf:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  102de2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102de5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
  102de8:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  102dec:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102def:	8b 00                	mov    (%eax),%eax
  102df1:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  102df4:	0f 8f dd fe ff ff    	jg     102cd7 <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
  102dfa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102dfe:	72 1d                	jb     102e1d <page_init+0x17f>
  102e00:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102e04:	77 09                	ja     102e0f <page_init+0x171>
  102e06:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
  102e0d:	76 0e                	jbe    102e1d <page_init+0x17f>
        maxpa = KMEMSIZE;
  102e0f:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
  102e16:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
  102e1d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102e20:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102e23:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  102e27:	c1 ea 0c             	shr    $0xc,%edx
  102e2a:	a3 80 ae 11 00       	mov    %eax,0x11ae80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
  102e2f:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
  102e36:	b8 28 af 11 00       	mov    $0x11af28,%eax
  102e3b:	8d 50 ff             	lea    -0x1(%eax),%edx
  102e3e:	8b 45 ac             	mov    -0x54(%ebp),%eax
  102e41:	01 d0                	add    %edx,%eax
  102e43:	89 45 a8             	mov    %eax,-0x58(%ebp)
  102e46:	8b 45 a8             	mov    -0x58(%ebp),%eax
  102e49:	ba 00 00 00 00       	mov    $0x0,%edx
  102e4e:	f7 75 ac             	divl   -0x54(%ebp)
  102e51:	89 d0                	mov    %edx,%eax
  102e53:	8b 55 a8             	mov    -0x58(%ebp),%edx
  102e56:	29 c2                	sub    %eax,%edx
  102e58:	89 d0                	mov    %edx,%eax
  102e5a:	a3 18 af 11 00       	mov    %eax,0x11af18

    for (i = 0; i < npage; i ++) {
  102e5f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102e66:	eb 2f                	jmp    102e97 <page_init+0x1f9>
        SetPageReserved(pages + i);
  102e68:	8b 0d 18 af 11 00    	mov    0x11af18,%ecx
  102e6e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e71:	89 d0                	mov    %edx,%eax
  102e73:	c1 e0 02             	shl    $0x2,%eax
  102e76:	01 d0                	add    %edx,%eax
  102e78:	c1 e0 02             	shl    $0x2,%eax
  102e7b:	01 c8                	add    %ecx,%eax
  102e7d:	83 c0 04             	add    $0x4,%eax
  102e80:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
  102e87:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102e8a:	8b 45 8c             	mov    -0x74(%ebp),%eax
  102e8d:	8b 55 90             	mov    -0x70(%ebp),%edx
  102e90:	0f ab 10             	bts    %edx,(%eax)
    for (i = 0; i < npage; i ++) {
  102e93:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  102e97:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e9a:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  102e9f:	39 c2                	cmp    %eax,%edx
  102ea1:	72 c5                	jb     102e68 <page_init+0x1ca>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
  102ea3:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  102ea9:	89 d0                	mov    %edx,%eax
  102eab:	c1 e0 02             	shl    $0x2,%eax
  102eae:	01 d0                	add    %edx,%eax
  102eb0:	c1 e0 02             	shl    $0x2,%eax
  102eb3:	89 c2                	mov    %eax,%edx
  102eb5:	a1 18 af 11 00       	mov    0x11af18,%eax
  102eba:	01 d0                	add    %edx,%eax
  102ebc:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  102ebf:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
  102ec6:	77 23                	ja     102eeb <page_init+0x24d>
  102ec8:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  102ecb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102ecf:	c7 44 24 08 64 67 10 	movl   $0x106764,0x8(%esp)
  102ed6:	00 
  102ed7:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
  102ede:	00 
  102edf:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  102ee6:	e8 fe d4 ff ff       	call   1003e9 <__panic>
  102eeb:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  102eee:	05 00 00 00 40       	add    $0x40000000,%eax
  102ef3:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
  102ef6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102efd:	e9 74 01 00 00       	jmp    103076 <page_init+0x3d8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  102f02:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102f05:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102f08:	89 d0                	mov    %edx,%eax
  102f0a:	c1 e0 02             	shl    $0x2,%eax
  102f0d:	01 d0                	add    %edx,%eax
  102f0f:	c1 e0 02             	shl    $0x2,%eax
  102f12:	01 c8                	add    %ecx,%eax
  102f14:	8b 50 08             	mov    0x8(%eax),%edx
  102f17:	8b 40 04             	mov    0x4(%eax),%eax
  102f1a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102f1d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  102f20:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102f23:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102f26:	89 d0                	mov    %edx,%eax
  102f28:	c1 e0 02             	shl    $0x2,%eax
  102f2b:	01 d0                	add    %edx,%eax
  102f2d:	c1 e0 02             	shl    $0x2,%eax
  102f30:	01 c8                	add    %ecx,%eax
  102f32:	8b 48 0c             	mov    0xc(%eax),%ecx
  102f35:	8b 58 10             	mov    0x10(%eax),%ebx
  102f38:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102f3b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102f3e:	01 c8                	add    %ecx,%eax
  102f40:	11 da                	adc    %ebx,%edx
  102f42:	89 45 c8             	mov    %eax,-0x38(%ebp)
  102f45:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
  102f48:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102f4b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102f4e:	89 d0                	mov    %edx,%eax
  102f50:	c1 e0 02             	shl    $0x2,%eax
  102f53:	01 d0                	add    %edx,%eax
  102f55:	c1 e0 02             	shl    $0x2,%eax
  102f58:	01 c8                	add    %ecx,%eax
  102f5a:	83 c0 14             	add    $0x14,%eax
  102f5d:	8b 00                	mov    (%eax),%eax
  102f5f:	83 f8 01             	cmp    $0x1,%eax
  102f62:	0f 85 0a 01 00 00    	jne    103072 <page_init+0x3d4>
            if (begin < freemem) {
  102f68:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102f6b:	ba 00 00 00 00       	mov    $0x0,%edx
  102f70:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  102f73:	72 17                	jb     102f8c <page_init+0x2ee>
  102f75:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  102f78:	77 05                	ja     102f7f <page_init+0x2e1>
  102f7a:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  102f7d:	76 0d                	jbe    102f8c <page_init+0x2ee>
                begin = freemem;
  102f7f:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102f82:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102f85:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
  102f8c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  102f90:	72 1d                	jb     102faf <page_init+0x311>
  102f92:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  102f96:	77 09                	ja     102fa1 <page_init+0x303>
  102f98:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
  102f9f:	76 0e                	jbe    102faf <page_init+0x311>
                end = KMEMSIZE;
  102fa1:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
  102fa8:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
  102faf:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102fb2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102fb5:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102fb8:	0f 87 b4 00 00 00    	ja     103072 <page_init+0x3d4>
  102fbe:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102fc1:	72 09                	jb     102fcc <page_init+0x32e>
  102fc3:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  102fc6:	0f 83 a6 00 00 00    	jae    103072 <page_init+0x3d4>
                begin = ROUNDUP(begin, PGSIZE);
  102fcc:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
  102fd3:	8b 55 d0             	mov    -0x30(%ebp),%edx
  102fd6:	8b 45 9c             	mov    -0x64(%ebp),%eax
  102fd9:	01 d0                	add    %edx,%eax
  102fdb:	83 e8 01             	sub    $0x1,%eax
  102fde:	89 45 98             	mov    %eax,-0x68(%ebp)
  102fe1:	8b 45 98             	mov    -0x68(%ebp),%eax
  102fe4:	ba 00 00 00 00       	mov    $0x0,%edx
  102fe9:	f7 75 9c             	divl   -0x64(%ebp)
  102fec:	89 d0                	mov    %edx,%eax
  102fee:	8b 55 98             	mov    -0x68(%ebp),%edx
  102ff1:	29 c2                	sub    %eax,%edx
  102ff3:	89 d0                	mov    %edx,%eax
  102ff5:	ba 00 00 00 00       	mov    $0x0,%edx
  102ffa:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102ffd:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
  103000:	8b 45 c8             	mov    -0x38(%ebp),%eax
  103003:	89 45 94             	mov    %eax,-0x6c(%ebp)
  103006:	8b 45 94             	mov    -0x6c(%ebp),%eax
  103009:	ba 00 00 00 00       	mov    $0x0,%edx
  10300e:	89 c7                	mov    %eax,%edi
  103010:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  103016:	89 7d 80             	mov    %edi,-0x80(%ebp)
  103019:	89 d0                	mov    %edx,%eax
  10301b:	83 e0 00             	and    $0x0,%eax
  10301e:	89 45 84             	mov    %eax,-0x7c(%ebp)
  103021:	8b 45 80             	mov    -0x80(%ebp),%eax
  103024:	8b 55 84             	mov    -0x7c(%ebp),%edx
  103027:	89 45 c8             	mov    %eax,-0x38(%ebp)
  10302a:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
  10302d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  103030:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  103033:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  103036:	77 3a                	ja     103072 <page_init+0x3d4>
  103038:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  10303b:	72 05                	jb     103042 <page_init+0x3a4>
  10303d:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  103040:	73 30                	jae    103072 <page_init+0x3d4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
  103042:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  103045:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  103048:	8b 45 c8             	mov    -0x38(%ebp),%eax
  10304b:	8b 55 cc             	mov    -0x34(%ebp),%edx
  10304e:	29 c8                	sub    %ecx,%eax
  103050:	19 da                	sbb    %ebx,%edx
  103052:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  103056:	c1 ea 0c             	shr    $0xc,%edx
  103059:	89 c3                	mov    %eax,%ebx
  10305b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10305e:	89 04 24             	mov    %eax,(%esp)
  103061:	e8 a5 f8 ff ff       	call   10290b <pa2page>
  103066:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  10306a:	89 04 24             	mov    %eax,(%esp)
  10306d:	e8 78 fb ff ff       	call   102bea <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
  103072:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  103076:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  103079:	8b 00                	mov    (%eax),%eax
  10307b:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  10307e:	0f 8f 7e fe ff ff    	jg     102f02 <page_init+0x264>
                }
            }
        }
    }
}
  103084:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  10308a:	5b                   	pop    %ebx
  10308b:	5e                   	pop    %esi
  10308c:	5f                   	pop    %edi
  10308d:	5d                   	pop    %ebp
  10308e:	c3                   	ret    

0010308f <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
  10308f:	55                   	push   %ebp
  103090:	89 e5                	mov    %esp,%ebp
  103092:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
  103095:	8b 45 14             	mov    0x14(%ebp),%eax
  103098:	8b 55 0c             	mov    0xc(%ebp),%edx
  10309b:	31 d0                	xor    %edx,%eax
  10309d:	25 ff 0f 00 00       	and    $0xfff,%eax
  1030a2:	85 c0                	test   %eax,%eax
  1030a4:	74 24                	je     1030ca <boot_map_segment+0x3b>
  1030a6:	c7 44 24 0c 96 67 10 	movl   $0x106796,0xc(%esp)
  1030ad:	00 
  1030ae:	c7 44 24 08 ad 67 10 	movl   $0x1067ad,0x8(%esp)
  1030b5:	00 
  1030b6:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
  1030bd:	00 
  1030be:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  1030c5:	e8 1f d3 ff ff       	call   1003e9 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
  1030ca:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  1030d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1030d4:	25 ff 0f 00 00       	and    $0xfff,%eax
  1030d9:	89 c2                	mov    %eax,%edx
  1030db:	8b 45 10             	mov    0x10(%ebp),%eax
  1030de:	01 c2                	add    %eax,%edx
  1030e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1030e3:	01 d0                	add    %edx,%eax
  1030e5:	83 e8 01             	sub    $0x1,%eax
  1030e8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1030eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1030ee:	ba 00 00 00 00       	mov    $0x0,%edx
  1030f3:	f7 75 f0             	divl   -0x10(%ebp)
  1030f6:	89 d0                	mov    %edx,%eax
  1030f8:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1030fb:	29 c2                	sub    %eax,%edx
  1030fd:	89 d0                	mov    %edx,%eax
  1030ff:	c1 e8 0c             	shr    $0xc,%eax
  103102:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
  103105:	8b 45 0c             	mov    0xc(%ebp),%eax
  103108:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10310b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10310e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103113:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
  103116:	8b 45 14             	mov    0x14(%ebp),%eax
  103119:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10311c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10311f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103124:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  103127:	eb 6b                	jmp    103194 <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
  103129:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  103130:	00 
  103131:	8b 45 0c             	mov    0xc(%ebp),%eax
  103134:	89 44 24 04          	mov    %eax,0x4(%esp)
  103138:	8b 45 08             	mov    0x8(%ebp),%eax
  10313b:	89 04 24             	mov    %eax,(%esp)
  10313e:	e8 82 01 00 00       	call   1032c5 <get_pte>
  103143:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
  103146:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  10314a:	75 24                	jne    103170 <boot_map_segment+0xe1>
  10314c:	c7 44 24 0c c2 67 10 	movl   $0x1067c2,0xc(%esp)
  103153:	00 
  103154:	c7 44 24 08 ad 67 10 	movl   $0x1067ad,0x8(%esp)
  10315b:	00 
  10315c:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
  103163:	00 
  103164:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  10316b:	e8 79 d2 ff ff       	call   1003e9 <__panic>
        *ptep = pa | PTE_P | perm;
  103170:	8b 45 18             	mov    0x18(%ebp),%eax
  103173:	8b 55 14             	mov    0x14(%ebp),%edx
  103176:	09 d0                	or     %edx,%eax
  103178:	83 c8 01             	or     $0x1,%eax
  10317b:	89 c2                	mov    %eax,%edx
  10317d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103180:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  103182:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  103186:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
  10318d:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  103194:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103198:	75 8f                	jne    103129 <boot_map_segment+0x9a>
    }
}
  10319a:	c9                   	leave  
  10319b:	c3                   	ret    

0010319c <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
  10319c:	55                   	push   %ebp
  10319d:	89 e5                	mov    %esp,%ebp
  10319f:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
  1031a2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1031a9:	e8 5b fa ff ff       	call   102c09 <alloc_pages>
  1031ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
  1031b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1031b5:	75 1c                	jne    1031d3 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
  1031b7:	c7 44 24 08 cf 67 10 	movl   $0x1067cf,0x8(%esp)
  1031be:	00 
  1031bf:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
  1031c6:	00 
  1031c7:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  1031ce:	e8 16 d2 ff ff       	call   1003e9 <__panic>
    }
    return page2kva(p);
  1031d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1031d6:	89 04 24             	mov    %eax,(%esp)
  1031d9:	e8 7c f7 ff ff       	call   10295a <page2kva>
}
  1031de:	c9                   	leave  
  1031df:	c3                   	ret    

001031e0 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
  1031e0:	55                   	push   %ebp
  1031e1:	89 e5                	mov    %esp,%ebp
  1031e3:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
  1031e6:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1031eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1031ee:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  1031f5:	77 23                	ja     10321a <pmm_init+0x3a>
  1031f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1031fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1031fe:	c7 44 24 08 64 67 10 	movl   $0x106764,0x8(%esp)
  103205:	00 
  103206:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
  10320d:	00 
  10320e:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  103215:	e8 cf d1 ff ff       	call   1003e9 <__panic>
  10321a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10321d:	05 00 00 00 40       	add    $0x40000000,%eax
  103222:	a3 14 af 11 00       	mov    %eax,0x11af14
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
  103227:	e8 8b f9 ff ff       	call   102bb7 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
  10322c:	e8 6d fa ff ff       	call   102c9e <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
  103231:	e8 e1 03 00 00       	call   103617 <check_alloc_page>

    check_pgdir();
  103236:	e8 fa 03 00 00       	call   103635 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
  10323b:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103240:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
  103246:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10324b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10324e:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  103255:	77 23                	ja     10327a <pmm_init+0x9a>
  103257:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10325a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10325e:	c7 44 24 08 64 67 10 	movl   $0x106764,0x8(%esp)
  103265:	00 
  103266:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
  10326d:	00 
  10326e:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  103275:	e8 6f d1 ff ff       	call   1003e9 <__panic>
  10327a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10327d:	05 00 00 00 40       	add    $0x40000000,%eax
  103282:	83 c8 03             	or     $0x3,%eax
  103285:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
  103287:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10328c:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
  103293:	00 
  103294:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  10329b:	00 
  10329c:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
  1032a3:	38 
  1032a4:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
  1032ab:	c0 
  1032ac:	89 04 24             	mov    %eax,(%esp)
  1032af:	e8 db fd ff ff       	call   10308f <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
  1032b4:	e8 0f f8 ff ff       	call   102ac8 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
  1032b9:	e8 12 0a 00 00       	call   103cd0 <check_boot_pgdir>

    print_pgdir();
  1032be:	e8 9a 0e 00 00       	call   10415d <print_pgdir>

}
  1032c3:	c9                   	leave  
  1032c4:	c3                   	ret    

001032c5 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
  1032c5:	55                   	push   %ebp
  1032c6:	89 e5                	mov    %esp,%ebp
  1032c8:	83 ec 38             	sub    $0x38,%esp
    pde_t *pdep = &pgdir[PDX(la)];
  1032cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1032ce:	c1 e8 16             	shr    $0x16,%eax
  1032d1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1032d8:	8b 45 08             	mov    0x8(%ebp),%eax
  1032db:	01 d0                	add    %edx,%eax
  1032dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    //获取一级页表项对应的入口地址
    if (!(*pdep & PTE_P)) {
  1032e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1032e3:	8b 00                	mov    (%eax),%eax
  1032e5:	83 e0 01             	and    $0x1,%eax
  1032e8:	85 c0                	test   %eax,%eax
  1032ea:	0f 85 af 00 00 00    	jne    10339f <get_pte+0xda>
        //物理页不存在, create==0, null
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {//分配失败
  1032f0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1032f4:	74 15                	je     10330b <get_pte+0x46>
  1032f6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1032fd:	e8 07 f9 ff ff       	call   102c09 <alloc_pages>
  103302:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103305:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103309:	75 0a                	jne    103315 <get_pte+0x50>
            return NULL;
  10330b:	b8 00 00 00 00       	mov    $0x0,%eax
  103310:	e9 e6 00 00 00       	jmp    1033fb <get_pte+0x136>
        }
        //引用次数+1
        set_page_ref(page, 1);
  103315:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10331c:	00 
  10331d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103320:	89 04 24             	mov    %eax,(%esp)
  103323:	e8 e6 f6 ff ff       	call   102a0e <set_page_ref>
        //物理地址
        uintptr_t pa = page2pa(page);
  103328:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10332b:	89 04 24             	mov    %eax,(%esp)
  10332e:	e8 c2 f5 ff ff       	call   1028f5 <page2pa>
  103333:	89 45 ec             	mov    %eax,-0x14(%ebp)
        ///物理地址转虚拟地址，并初始化,把新申请的数目为pgsize个页全设为0	
        memset(KADDR(pa), 0, PGSIZE);
  103336:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103339:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10333c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10333f:	c1 e8 0c             	shr    $0xc,%eax
  103342:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103345:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  10334a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  10334d:	72 23                	jb     103372 <get_pte+0xad>
  10334f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103352:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103356:	c7 44 24 08 c0 66 10 	movl   $0x1066c0,0x8(%esp)
  10335d:	00 
  10335e:	c7 44 24 04 56 01 00 	movl   $0x156,0x4(%esp)
  103365:	00 
  103366:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  10336d:	e8 77 d0 ff ff       	call   1003e9 <__panic>
  103372:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103375:	2d 00 00 00 40       	sub    $0x40000000,%eax
  10337a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  103381:	00 
  103382:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103389:	00 
  10338a:	89 04 24             	mov    %eax,(%esp)
  10338d:	e8 8b 23 00 00       	call   10571d <memset>
        //设置控制位
        *pdep = pa | PTE_U | PTE_W | PTE_P;
  103392:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103395:	83 c8 07             	or     $0x7,%eax
  103398:	89 c2                	mov    %eax,%edx
  10339a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10339d:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
  10339f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1033a2:	8b 00                	mov    (%eax),%eax
  1033a4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1033a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1033ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1033af:	c1 e8 0c             	shr    $0xc,%eax
  1033b2:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1033b5:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  1033ba:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  1033bd:	72 23                	jb     1033e2 <get_pte+0x11d>
  1033bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1033c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1033c6:	c7 44 24 08 c0 66 10 	movl   $0x1066c0,0x8(%esp)
  1033cd:	00 
  1033ce:	c7 44 24 04 5a 01 00 	movl   $0x15a,0x4(%esp)
  1033d5:	00 
  1033d6:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  1033dd:	e8 07 d0 ff ff       	call   1003e9 <__panic>
  1033e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1033e5:	2d 00 00 00 40       	sub    $0x40000000,%eax
  1033ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  1033ed:	c1 ea 0c             	shr    $0xc,%edx
  1033f0:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
  1033f6:	c1 e2 02             	shl    $0x2,%edx
  1033f9:	01 d0                	add    %edx,%eax
    //页目录项地址-->>页表物理地址-->>虚拟地址-->>页表项索引
    //PTX(la)：返回虚拟地址la的页表项索引
    //返回la对应的页表项入口地址
}
  1033fb:	c9                   	leave  
  1033fc:	c3                   	ret    

001033fd <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
  1033fd:	55                   	push   %ebp
  1033fe:	89 e5                	mov    %esp,%ebp
  103400:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  103403:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10340a:	00 
  10340b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10340e:	89 44 24 04          	mov    %eax,0x4(%esp)
  103412:	8b 45 08             	mov    0x8(%ebp),%eax
  103415:	89 04 24             	mov    %eax,(%esp)
  103418:	e8 a8 fe ff ff       	call   1032c5 <get_pte>
  10341d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
  103420:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  103424:	74 08                	je     10342e <get_page+0x31>
        *ptep_store = ptep;
  103426:	8b 45 10             	mov    0x10(%ebp),%eax
  103429:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10342c:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
  10342e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103432:	74 1b                	je     10344f <get_page+0x52>
  103434:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103437:	8b 00                	mov    (%eax),%eax
  103439:	83 e0 01             	and    $0x1,%eax
  10343c:	85 c0                	test   %eax,%eax
  10343e:	74 0f                	je     10344f <get_page+0x52>
        return pte2page(*ptep);
  103440:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103443:	8b 00                	mov    (%eax),%eax
  103445:	89 04 24             	mov    %eax,(%esp)
  103448:	e8 61 f5 ff ff       	call   1029ae <pte2page>
  10344d:	eb 05                	jmp    103454 <get_page+0x57>
    }
    return NULL;
  10344f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103454:	c9                   	leave  
  103455:	c3                   	ret    

00103456 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
  103456:	55                   	push   %ebp
  103457:	89 e5                	mov    %esp,%ebp
  103459:	83 ec 28             	sub    $0x28,%esp
    if (*ptep & PTE_P) {
  10345c:	8b 45 10             	mov    0x10(%ebp),%eax
  10345f:	8b 00                	mov    (%eax),%eax
  103461:	83 e0 01             	and    $0x1,%eax
  103464:	85 c0                	test   %eax,%eax
  103466:	74 53                	je     1034bb <page_remove_pte+0x65>
        //判断页表中该表项是否存在
        struct Page *page = pte2page(*ptep);//获得相应的page
  103468:	8b 45 10             	mov    0x10(%ebp),%eax
  10346b:	8b 00                	mov    (%eax),%eax
  10346d:	89 04 24             	mov    %eax,(%esp)
  103470:	e8 39 f5 ff ff       	call   1029ae <pte2page>
  103475:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
  103478:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10347b:	89 04 24             	mov    %eax,(%esp)
  10347e:	e8 af f5 ff ff       	call   102a32 <page_ref_dec>
  103483:	85 c0                	test   %eax,%eax
  103485:	75 13                	jne    10349a <page_remove_pte+0x44>
            ////除了当前进程，没有别的进程引用
            free_page(page);
  103487:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10348e:	00 
  10348f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103492:	89 04 24             	mov    %eax,(%esp)
  103495:	e8 a7 f7 ff ff       	call   102c41 <free_pages>
        }
        *ptep &= (~PTE_P); 
  10349a:	8b 45 10             	mov    0x10(%ebp),%eax
  10349d:	8b 00                	mov    (%eax),%eax
  10349f:	83 e0 fe             	and    $0xfffffffe,%eax
  1034a2:	89 c2                	mov    %eax,%edx
  1034a4:	8b 45 10             	mov    0x10(%ebp),%eax
  1034a7:	89 10                	mov    %edx,(%eax)
        // 将PTE的存在位设置为0，表示该映射关系无效
        tlb_invalidate(pgdir, la);
  1034a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  1034b0:	8b 45 08             	mov    0x8(%ebp),%eax
  1034b3:	89 04 24             	mov    %eax,(%esp)
  1034b6:	e8 ff 00 00 00       	call   1035ba <tlb_invalidate>
         //刷新TLB
    }
}
  1034bb:	c9                   	leave  
  1034bc:	c3                   	ret    

001034bd <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
  1034bd:	55                   	push   %ebp
  1034be:	89 e5                	mov    %esp,%ebp
  1034c0:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  1034c3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1034ca:	00 
  1034cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  1034d2:	8b 45 08             	mov    0x8(%ebp),%eax
  1034d5:	89 04 24             	mov    %eax,(%esp)
  1034d8:	e8 e8 fd ff ff       	call   1032c5 <get_pte>
  1034dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
  1034e0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1034e4:	74 19                	je     1034ff <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
  1034e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1034e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  1034ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1034f4:	8b 45 08             	mov    0x8(%ebp),%eax
  1034f7:	89 04 24             	mov    %eax,(%esp)
  1034fa:	e8 57 ff ff ff       	call   103456 <page_remove_pte>
    }
}
  1034ff:	c9                   	leave  
  103500:	c3                   	ret    

00103501 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
  103501:	55                   	push   %ebp
  103502:	89 e5                	mov    %esp,%ebp
  103504:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
  103507:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  10350e:	00 
  10350f:	8b 45 10             	mov    0x10(%ebp),%eax
  103512:	89 44 24 04          	mov    %eax,0x4(%esp)
  103516:	8b 45 08             	mov    0x8(%ebp),%eax
  103519:	89 04 24             	mov    %eax,(%esp)
  10351c:	e8 a4 fd ff ff       	call   1032c5 <get_pte>
  103521:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
  103524:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103528:	75 0a                	jne    103534 <page_insert+0x33>
        return -E_NO_MEM;
  10352a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  10352f:	e9 84 00 00 00       	jmp    1035b8 <page_insert+0xb7>
    }
    page_ref_inc(page);
  103534:	8b 45 0c             	mov    0xc(%ebp),%eax
  103537:	89 04 24             	mov    %eax,(%esp)
  10353a:	e8 dc f4 ff ff       	call   102a1b <page_ref_inc>
    if (*ptep & PTE_P) {
  10353f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103542:	8b 00                	mov    (%eax),%eax
  103544:	83 e0 01             	and    $0x1,%eax
  103547:	85 c0                	test   %eax,%eax
  103549:	74 3e                	je     103589 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
  10354b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10354e:	8b 00                	mov    (%eax),%eax
  103550:	89 04 24             	mov    %eax,(%esp)
  103553:	e8 56 f4 ff ff       	call   1029ae <pte2page>
  103558:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
  10355b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10355e:	3b 45 0c             	cmp    0xc(%ebp),%eax
  103561:	75 0d                	jne    103570 <page_insert+0x6f>
            page_ref_dec(page);
  103563:	8b 45 0c             	mov    0xc(%ebp),%eax
  103566:	89 04 24             	mov    %eax,(%esp)
  103569:	e8 c4 f4 ff ff       	call   102a32 <page_ref_dec>
  10356e:	eb 19                	jmp    103589 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
  103570:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103573:	89 44 24 08          	mov    %eax,0x8(%esp)
  103577:	8b 45 10             	mov    0x10(%ebp),%eax
  10357a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10357e:	8b 45 08             	mov    0x8(%ebp),%eax
  103581:	89 04 24             	mov    %eax,(%esp)
  103584:	e8 cd fe ff ff       	call   103456 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
  103589:	8b 45 0c             	mov    0xc(%ebp),%eax
  10358c:	89 04 24             	mov    %eax,(%esp)
  10358f:	e8 61 f3 ff ff       	call   1028f5 <page2pa>
  103594:	0b 45 14             	or     0x14(%ebp),%eax
  103597:	83 c8 01             	or     $0x1,%eax
  10359a:	89 c2                	mov    %eax,%edx
  10359c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10359f:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
  1035a1:	8b 45 10             	mov    0x10(%ebp),%eax
  1035a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1035a8:	8b 45 08             	mov    0x8(%ebp),%eax
  1035ab:	89 04 24             	mov    %eax,(%esp)
  1035ae:	e8 07 00 00 00       	call   1035ba <tlb_invalidate>
    return 0;
  1035b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1035b8:	c9                   	leave  
  1035b9:	c3                   	ret    

001035ba <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
  1035ba:	55                   	push   %ebp
  1035bb:	89 e5                	mov    %esp,%ebp
  1035bd:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
  1035c0:	0f 20 d8             	mov    %cr3,%eax
  1035c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
  1035c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
  1035c9:	89 c2                	mov    %eax,%edx
  1035cb:	8b 45 08             	mov    0x8(%ebp),%eax
  1035ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1035d1:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  1035d8:	77 23                	ja     1035fd <tlb_invalidate+0x43>
  1035da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1035dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1035e1:	c7 44 24 08 64 67 10 	movl   $0x106764,0x8(%esp)
  1035e8:	00 
  1035e9:	c7 44 24 04 aa 01 00 	movl   $0x1aa,0x4(%esp)
  1035f0:	00 
  1035f1:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  1035f8:	e8 ec cd ff ff       	call   1003e9 <__panic>
  1035fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103600:	05 00 00 00 40       	add    $0x40000000,%eax
  103605:	39 c2                	cmp    %eax,%edx
  103607:	75 0c                	jne    103615 <tlb_invalidate+0x5b>
        invlpg((void *)la);
  103609:	8b 45 0c             	mov    0xc(%ebp),%eax
  10360c:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
  10360f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103612:	0f 01 38             	invlpg (%eax)
    }
}
  103615:	c9                   	leave  
  103616:	c3                   	ret    

00103617 <check_alloc_page>:

static void
check_alloc_page(void) {
  103617:	55                   	push   %ebp
  103618:	89 e5                	mov    %esp,%ebp
  10361a:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
  10361d:	a1 10 af 11 00       	mov    0x11af10,%eax
  103622:	8b 40 18             	mov    0x18(%eax),%eax
  103625:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
  103627:	c7 04 24 e8 67 10 00 	movl   $0x1067e8,(%esp)
  10362e:	e8 5f cc ff ff       	call   100292 <cprintf>
}
  103633:	c9                   	leave  
  103634:	c3                   	ret    

00103635 <check_pgdir>:

static void
check_pgdir(void) {
  103635:	55                   	push   %ebp
  103636:	89 e5                	mov    %esp,%ebp
  103638:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
  10363b:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  103640:	3d 00 80 03 00       	cmp    $0x38000,%eax
  103645:	76 24                	jbe    10366b <check_pgdir+0x36>
  103647:	c7 44 24 0c 07 68 10 	movl   $0x106807,0xc(%esp)
  10364e:	00 
  10364f:	c7 44 24 08 ad 67 10 	movl   $0x1067ad,0x8(%esp)
  103656:	00 
  103657:	c7 44 24 04 b7 01 00 	movl   $0x1b7,0x4(%esp)
  10365e:	00 
  10365f:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  103666:	e8 7e cd ff ff       	call   1003e9 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
  10366b:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103670:	85 c0                	test   %eax,%eax
  103672:	74 0e                	je     103682 <check_pgdir+0x4d>
  103674:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103679:	25 ff 0f 00 00       	and    $0xfff,%eax
  10367e:	85 c0                	test   %eax,%eax
  103680:	74 24                	je     1036a6 <check_pgdir+0x71>
  103682:	c7 44 24 0c 24 68 10 	movl   $0x106824,0xc(%esp)
  103689:	00 
  10368a:	c7 44 24 08 ad 67 10 	movl   $0x1067ad,0x8(%esp)
  103691:	00 
  103692:	c7 44 24 04 b8 01 00 	movl   $0x1b8,0x4(%esp)
  103699:	00 
  10369a:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  1036a1:	e8 43 cd ff ff       	call   1003e9 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
  1036a6:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1036ab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1036b2:	00 
  1036b3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1036ba:	00 
  1036bb:	89 04 24             	mov    %eax,(%esp)
  1036be:	e8 3a fd ff ff       	call   1033fd <get_page>
  1036c3:	85 c0                	test   %eax,%eax
  1036c5:	74 24                	je     1036eb <check_pgdir+0xb6>
  1036c7:	c7 44 24 0c 5c 68 10 	movl   $0x10685c,0xc(%esp)
  1036ce:	00 
  1036cf:	c7 44 24 08 ad 67 10 	movl   $0x1067ad,0x8(%esp)
  1036d6:	00 
  1036d7:	c7 44 24 04 b9 01 00 	movl   $0x1b9,0x4(%esp)
  1036de:	00 
  1036df:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  1036e6:	e8 fe cc ff ff       	call   1003e9 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
  1036eb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1036f2:	e8 12 f5 ff ff       	call   102c09 <alloc_pages>
  1036f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
  1036fa:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1036ff:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  103706:	00 
  103707:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10370e:	00 
  10370f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103712:	89 54 24 04          	mov    %edx,0x4(%esp)
  103716:	89 04 24             	mov    %eax,(%esp)
  103719:	e8 e3 fd ff ff       	call   103501 <page_insert>
  10371e:	85 c0                	test   %eax,%eax
  103720:	74 24                	je     103746 <check_pgdir+0x111>
  103722:	c7 44 24 0c 84 68 10 	movl   $0x106884,0xc(%esp)
  103729:	00 
  10372a:	c7 44 24 08 ad 67 10 	movl   $0x1067ad,0x8(%esp)
  103731:	00 
  103732:	c7 44 24 04 bd 01 00 	movl   $0x1bd,0x4(%esp)
  103739:	00 
  10373a:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  103741:	e8 a3 cc ff ff       	call   1003e9 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
  103746:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10374b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103752:	00 
  103753:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10375a:	00 
  10375b:	89 04 24             	mov    %eax,(%esp)
  10375e:	e8 62 fb ff ff       	call   1032c5 <get_pte>
  103763:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103766:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10376a:	75 24                	jne    103790 <check_pgdir+0x15b>
  10376c:	c7 44 24 0c b0 68 10 	movl   $0x1068b0,0xc(%esp)
  103773:	00 
  103774:	c7 44 24 08 ad 67 10 	movl   $0x1067ad,0x8(%esp)
  10377b:	00 
  10377c:	c7 44 24 04 c0 01 00 	movl   $0x1c0,0x4(%esp)
  103783:	00 
  103784:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  10378b:	e8 59 cc ff ff       	call   1003e9 <__panic>
    assert(pte2page(*ptep) == p1);
  103790:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103793:	8b 00                	mov    (%eax),%eax
  103795:	89 04 24             	mov    %eax,(%esp)
  103798:	e8 11 f2 ff ff       	call   1029ae <pte2page>
  10379d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  1037a0:	74 24                	je     1037c6 <check_pgdir+0x191>
  1037a2:	c7 44 24 0c dd 68 10 	movl   $0x1068dd,0xc(%esp)
  1037a9:	00 
  1037aa:	c7 44 24 08 ad 67 10 	movl   $0x1067ad,0x8(%esp)
  1037b1:	00 
  1037b2:	c7 44 24 04 c1 01 00 	movl   $0x1c1,0x4(%esp)
  1037b9:	00 
  1037ba:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  1037c1:	e8 23 cc ff ff       	call   1003e9 <__panic>
    assert(page_ref(p1) == 1);
  1037c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1037c9:	89 04 24             	mov    %eax,(%esp)
  1037cc:	e8 33 f2 ff ff       	call   102a04 <page_ref>
  1037d1:	83 f8 01             	cmp    $0x1,%eax
  1037d4:	74 24                	je     1037fa <check_pgdir+0x1c5>
  1037d6:	c7 44 24 0c f3 68 10 	movl   $0x1068f3,0xc(%esp)
  1037dd:	00 
  1037de:	c7 44 24 08 ad 67 10 	movl   $0x1067ad,0x8(%esp)
  1037e5:	00 
  1037e6:	c7 44 24 04 c2 01 00 	movl   $0x1c2,0x4(%esp)
  1037ed:	00 
  1037ee:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  1037f5:	e8 ef cb ff ff       	call   1003e9 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
  1037fa:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1037ff:	8b 00                	mov    (%eax),%eax
  103801:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103806:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103809:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10380c:	c1 e8 0c             	shr    $0xc,%eax
  10380f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103812:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  103817:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  10381a:	72 23                	jb     10383f <check_pgdir+0x20a>
  10381c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10381f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103823:	c7 44 24 08 c0 66 10 	movl   $0x1066c0,0x8(%esp)
  10382a:	00 
  10382b:	c7 44 24 04 c4 01 00 	movl   $0x1c4,0x4(%esp)
  103832:	00 
  103833:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  10383a:	e8 aa cb ff ff       	call   1003e9 <__panic>
  10383f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103842:	2d 00 00 00 40       	sub    $0x40000000,%eax
  103847:	83 c0 04             	add    $0x4,%eax
  10384a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
  10384d:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103852:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103859:	00 
  10385a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103861:	00 
  103862:	89 04 24             	mov    %eax,(%esp)
  103865:	e8 5b fa ff ff       	call   1032c5 <get_pte>
  10386a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  10386d:	74 24                	je     103893 <check_pgdir+0x25e>
  10386f:	c7 44 24 0c 08 69 10 	movl   $0x106908,0xc(%esp)
  103876:	00 
  103877:	c7 44 24 08 ad 67 10 	movl   $0x1067ad,0x8(%esp)
  10387e:	00 
  10387f:	c7 44 24 04 c5 01 00 	movl   $0x1c5,0x4(%esp)
  103886:	00 
  103887:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  10388e:	e8 56 cb ff ff       	call   1003e9 <__panic>

    p2 = alloc_page();
  103893:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10389a:	e8 6a f3 ff ff       	call   102c09 <alloc_pages>
  10389f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
  1038a2:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1038a7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  1038ae:	00 
  1038af:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  1038b6:	00 
  1038b7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1038ba:	89 54 24 04          	mov    %edx,0x4(%esp)
  1038be:	89 04 24             	mov    %eax,(%esp)
  1038c1:	e8 3b fc ff ff       	call   103501 <page_insert>
  1038c6:	85 c0                	test   %eax,%eax
  1038c8:	74 24                	je     1038ee <check_pgdir+0x2b9>
  1038ca:	c7 44 24 0c 30 69 10 	movl   $0x106930,0xc(%esp)
  1038d1:	00 
  1038d2:	c7 44 24 08 ad 67 10 	movl   $0x1067ad,0x8(%esp)
  1038d9:	00 
  1038da:	c7 44 24 04 c8 01 00 	movl   $0x1c8,0x4(%esp)
  1038e1:	00 
  1038e2:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  1038e9:	e8 fb ca ff ff       	call   1003e9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  1038ee:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1038f3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1038fa:	00 
  1038fb:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103902:	00 
  103903:	89 04 24             	mov    %eax,(%esp)
  103906:	e8 ba f9 ff ff       	call   1032c5 <get_pte>
  10390b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10390e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103912:	75 24                	jne    103938 <check_pgdir+0x303>
  103914:	c7 44 24 0c 68 69 10 	movl   $0x106968,0xc(%esp)
  10391b:	00 
  10391c:	c7 44 24 08 ad 67 10 	movl   $0x1067ad,0x8(%esp)
  103923:	00 
  103924:	c7 44 24 04 c9 01 00 	movl   $0x1c9,0x4(%esp)
  10392b:	00 
  10392c:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  103933:	e8 b1 ca ff ff       	call   1003e9 <__panic>
    assert(*ptep & PTE_U);
  103938:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10393b:	8b 00                	mov    (%eax),%eax
  10393d:	83 e0 04             	and    $0x4,%eax
  103940:	85 c0                	test   %eax,%eax
  103942:	75 24                	jne    103968 <check_pgdir+0x333>
  103944:	c7 44 24 0c 98 69 10 	movl   $0x106998,0xc(%esp)
  10394b:	00 
  10394c:	c7 44 24 08 ad 67 10 	movl   $0x1067ad,0x8(%esp)
  103953:	00 
  103954:	c7 44 24 04 ca 01 00 	movl   $0x1ca,0x4(%esp)
  10395b:	00 
  10395c:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  103963:	e8 81 ca ff ff       	call   1003e9 <__panic>
    assert(*ptep & PTE_W);
  103968:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10396b:	8b 00                	mov    (%eax),%eax
  10396d:	83 e0 02             	and    $0x2,%eax
  103970:	85 c0                	test   %eax,%eax
  103972:	75 24                	jne    103998 <check_pgdir+0x363>
  103974:	c7 44 24 0c a6 69 10 	movl   $0x1069a6,0xc(%esp)
  10397b:	00 
  10397c:	c7 44 24 08 ad 67 10 	movl   $0x1067ad,0x8(%esp)
  103983:	00 
  103984:	c7 44 24 04 cb 01 00 	movl   $0x1cb,0x4(%esp)
  10398b:	00 
  10398c:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  103993:	e8 51 ca ff ff       	call   1003e9 <__panic>
    assert(boot_pgdir[0] & PTE_U);
  103998:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10399d:	8b 00                	mov    (%eax),%eax
  10399f:	83 e0 04             	and    $0x4,%eax
  1039a2:	85 c0                	test   %eax,%eax
  1039a4:	75 24                	jne    1039ca <check_pgdir+0x395>
  1039a6:	c7 44 24 0c b4 69 10 	movl   $0x1069b4,0xc(%esp)
  1039ad:	00 
  1039ae:	c7 44 24 08 ad 67 10 	movl   $0x1067ad,0x8(%esp)
  1039b5:	00 
  1039b6:	c7 44 24 04 cc 01 00 	movl   $0x1cc,0x4(%esp)
  1039bd:	00 
  1039be:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  1039c5:	e8 1f ca ff ff       	call   1003e9 <__panic>
    assert(page_ref(p2) == 1);
  1039ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1039cd:	89 04 24             	mov    %eax,(%esp)
  1039d0:	e8 2f f0 ff ff       	call   102a04 <page_ref>
  1039d5:	83 f8 01             	cmp    $0x1,%eax
  1039d8:	74 24                	je     1039fe <check_pgdir+0x3c9>
  1039da:	c7 44 24 0c ca 69 10 	movl   $0x1069ca,0xc(%esp)
  1039e1:	00 
  1039e2:	c7 44 24 08 ad 67 10 	movl   $0x1067ad,0x8(%esp)
  1039e9:	00 
  1039ea:	c7 44 24 04 cd 01 00 	movl   $0x1cd,0x4(%esp)
  1039f1:	00 
  1039f2:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  1039f9:	e8 eb c9 ff ff       	call   1003e9 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
  1039fe:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103a03:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  103a0a:	00 
  103a0b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  103a12:	00 
  103a13:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103a16:	89 54 24 04          	mov    %edx,0x4(%esp)
  103a1a:	89 04 24             	mov    %eax,(%esp)
  103a1d:	e8 df fa ff ff       	call   103501 <page_insert>
  103a22:	85 c0                	test   %eax,%eax
  103a24:	74 24                	je     103a4a <check_pgdir+0x415>
  103a26:	c7 44 24 0c dc 69 10 	movl   $0x1069dc,0xc(%esp)
  103a2d:	00 
  103a2e:	c7 44 24 08 ad 67 10 	movl   $0x1067ad,0x8(%esp)
  103a35:	00 
  103a36:	c7 44 24 04 cf 01 00 	movl   $0x1cf,0x4(%esp)
  103a3d:	00 
  103a3e:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  103a45:	e8 9f c9 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p1) == 2);
  103a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103a4d:	89 04 24             	mov    %eax,(%esp)
  103a50:	e8 af ef ff ff       	call   102a04 <page_ref>
  103a55:	83 f8 02             	cmp    $0x2,%eax
  103a58:	74 24                	je     103a7e <check_pgdir+0x449>
  103a5a:	c7 44 24 0c 08 6a 10 	movl   $0x106a08,0xc(%esp)
  103a61:	00 
  103a62:	c7 44 24 08 ad 67 10 	movl   $0x1067ad,0x8(%esp)
  103a69:	00 
  103a6a:	c7 44 24 04 d0 01 00 	movl   $0x1d0,0x4(%esp)
  103a71:	00 
  103a72:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  103a79:	e8 6b c9 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p2) == 0);
  103a7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103a81:	89 04 24             	mov    %eax,(%esp)
  103a84:	e8 7b ef ff ff       	call   102a04 <page_ref>
  103a89:	85 c0                	test   %eax,%eax
  103a8b:	74 24                	je     103ab1 <check_pgdir+0x47c>
  103a8d:	c7 44 24 0c 1a 6a 10 	movl   $0x106a1a,0xc(%esp)
  103a94:	00 
  103a95:	c7 44 24 08 ad 67 10 	movl   $0x1067ad,0x8(%esp)
  103a9c:	00 
  103a9d:	c7 44 24 04 d1 01 00 	movl   $0x1d1,0x4(%esp)
  103aa4:	00 
  103aa5:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  103aac:	e8 38 c9 ff ff       	call   1003e9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  103ab1:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103ab6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103abd:	00 
  103abe:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103ac5:	00 
  103ac6:	89 04 24             	mov    %eax,(%esp)
  103ac9:	e8 f7 f7 ff ff       	call   1032c5 <get_pte>
  103ace:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103ad1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103ad5:	75 24                	jne    103afb <check_pgdir+0x4c6>
  103ad7:	c7 44 24 0c 68 69 10 	movl   $0x106968,0xc(%esp)
  103ade:	00 
  103adf:	c7 44 24 08 ad 67 10 	movl   $0x1067ad,0x8(%esp)
  103ae6:	00 
  103ae7:	c7 44 24 04 d2 01 00 	movl   $0x1d2,0x4(%esp)
  103aee:	00 
  103aef:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  103af6:	e8 ee c8 ff ff       	call   1003e9 <__panic>
    assert(pte2page(*ptep) == p1);
  103afb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103afe:	8b 00                	mov    (%eax),%eax
  103b00:	89 04 24             	mov    %eax,(%esp)
  103b03:	e8 a6 ee ff ff       	call   1029ae <pte2page>
  103b08:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  103b0b:	74 24                	je     103b31 <check_pgdir+0x4fc>
  103b0d:	c7 44 24 0c dd 68 10 	movl   $0x1068dd,0xc(%esp)
  103b14:	00 
  103b15:	c7 44 24 08 ad 67 10 	movl   $0x1067ad,0x8(%esp)
  103b1c:	00 
  103b1d:	c7 44 24 04 d3 01 00 	movl   $0x1d3,0x4(%esp)
  103b24:	00 
  103b25:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  103b2c:	e8 b8 c8 ff ff       	call   1003e9 <__panic>
    assert((*ptep & PTE_U) == 0);
  103b31:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103b34:	8b 00                	mov    (%eax),%eax
  103b36:	83 e0 04             	and    $0x4,%eax
  103b39:	85 c0                	test   %eax,%eax
  103b3b:	74 24                	je     103b61 <check_pgdir+0x52c>
  103b3d:	c7 44 24 0c 2c 6a 10 	movl   $0x106a2c,0xc(%esp)
  103b44:	00 
  103b45:	c7 44 24 08 ad 67 10 	movl   $0x1067ad,0x8(%esp)
  103b4c:	00 
  103b4d:	c7 44 24 04 d4 01 00 	movl   $0x1d4,0x4(%esp)
  103b54:	00 
  103b55:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  103b5c:	e8 88 c8 ff ff       	call   1003e9 <__panic>

    page_remove(boot_pgdir, 0x0);
  103b61:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103b66:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103b6d:	00 
  103b6e:	89 04 24             	mov    %eax,(%esp)
  103b71:	e8 47 f9 ff ff       	call   1034bd <page_remove>
    assert(page_ref(p1) == 1);
  103b76:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103b79:	89 04 24             	mov    %eax,(%esp)
  103b7c:	e8 83 ee ff ff       	call   102a04 <page_ref>
  103b81:	83 f8 01             	cmp    $0x1,%eax
  103b84:	74 24                	je     103baa <check_pgdir+0x575>
  103b86:	c7 44 24 0c f3 68 10 	movl   $0x1068f3,0xc(%esp)
  103b8d:	00 
  103b8e:	c7 44 24 08 ad 67 10 	movl   $0x1067ad,0x8(%esp)
  103b95:	00 
  103b96:	c7 44 24 04 d7 01 00 	movl   $0x1d7,0x4(%esp)
  103b9d:	00 
  103b9e:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  103ba5:	e8 3f c8 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p2) == 0);
  103baa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103bad:	89 04 24             	mov    %eax,(%esp)
  103bb0:	e8 4f ee ff ff       	call   102a04 <page_ref>
  103bb5:	85 c0                	test   %eax,%eax
  103bb7:	74 24                	je     103bdd <check_pgdir+0x5a8>
  103bb9:	c7 44 24 0c 1a 6a 10 	movl   $0x106a1a,0xc(%esp)
  103bc0:	00 
  103bc1:	c7 44 24 08 ad 67 10 	movl   $0x1067ad,0x8(%esp)
  103bc8:	00 
  103bc9:	c7 44 24 04 d8 01 00 	movl   $0x1d8,0x4(%esp)
  103bd0:	00 
  103bd1:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  103bd8:	e8 0c c8 ff ff       	call   1003e9 <__panic>

    page_remove(boot_pgdir, PGSIZE);
  103bdd:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103be2:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103be9:	00 
  103bea:	89 04 24             	mov    %eax,(%esp)
  103bed:	e8 cb f8 ff ff       	call   1034bd <page_remove>
    assert(page_ref(p1) == 0);
  103bf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103bf5:	89 04 24             	mov    %eax,(%esp)
  103bf8:	e8 07 ee ff ff       	call   102a04 <page_ref>
  103bfd:	85 c0                	test   %eax,%eax
  103bff:	74 24                	je     103c25 <check_pgdir+0x5f0>
  103c01:	c7 44 24 0c 41 6a 10 	movl   $0x106a41,0xc(%esp)
  103c08:	00 
  103c09:	c7 44 24 08 ad 67 10 	movl   $0x1067ad,0x8(%esp)
  103c10:	00 
  103c11:	c7 44 24 04 db 01 00 	movl   $0x1db,0x4(%esp)
  103c18:	00 
  103c19:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  103c20:	e8 c4 c7 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p2) == 0);
  103c25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103c28:	89 04 24             	mov    %eax,(%esp)
  103c2b:	e8 d4 ed ff ff       	call   102a04 <page_ref>
  103c30:	85 c0                	test   %eax,%eax
  103c32:	74 24                	je     103c58 <check_pgdir+0x623>
  103c34:	c7 44 24 0c 1a 6a 10 	movl   $0x106a1a,0xc(%esp)
  103c3b:	00 
  103c3c:	c7 44 24 08 ad 67 10 	movl   $0x1067ad,0x8(%esp)
  103c43:	00 
  103c44:	c7 44 24 04 dc 01 00 	movl   $0x1dc,0x4(%esp)
  103c4b:	00 
  103c4c:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  103c53:	e8 91 c7 ff ff       	call   1003e9 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
  103c58:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103c5d:	8b 00                	mov    (%eax),%eax
  103c5f:	89 04 24             	mov    %eax,(%esp)
  103c62:	e8 85 ed ff ff       	call   1029ec <pde2page>
  103c67:	89 04 24             	mov    %eax,(%esp)
  103c6a:	e8 95 ed ff ff       	call   102a04 <page_ref>
  103c6f:	83 f8 01             	cmp    $0x1,%eax
  103c72:	74 24                	je     103c98 <check_pgdir+0x663>
  103c74:	c7 44 24 0c 54 6a 10 	movl   $0x106a54,0xc(%esp)
  103c7b:	00 
  103c7c:	c7 44 24 08 ad 67 10 	movl   $0x1067ad,0x8(%esp)
  103c83:	00 
  103c84:	c7 44 24 04 de 01 00 	movl   $0x1de,0x4(%esp)
  103c8b:	00 
  103c8c:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  103c93:	e8 51 c7 ff ff       	call   1003e9 <__panic>
    free_page(pde2page(boot_pgdir[0]));
  103c98:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103c9d:	8b 00                	mov    (%eax),%eax
  103c9f:	89 04 24             	mov    %eax,(%esp)
  103ca2:	e8 45 ed ff ff       	call   1029ec <pde2page>
  103ca7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103cae:	00 
  103caf:	89 04 24             	mov    %eax,(%esp)
  103cb2:	e8 8a ef ff ff       	call   102c41 <free_pages>
    boot_pgdir[0] = 0;
  103cb7:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103cbc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
  103cc2:	c7 04 24 7b 6a 10 00 	movl   $0x106a7b,(%esp)
  103cc9:	e8 c4 c5 ff ff       	call   100292 <cprintf>
}
  103cce:	c9                   	leave  
  103ccf:	c3                   	ret    

00103cd0 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
  103cd0:	55                   	push   %ebp
  103cd1:	89 e5                	mov    %esp,%ebp
  103cd3:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  103cd6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  103cdd:	e9 ca 00 00 00       	jmp    103dac <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
  103ce2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103ce5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103ce8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103ceb:	c1 e8 0c             	shr    $0xc,%eax
  103cee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103cf1:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  103cf6:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  103cf9:	72 23                	jb     103d1e <check_boot_pgdir+0x4e>
  103cfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103cfe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103d02:	c7 44 24 08 c0 66 10 	movl   $0x1066c0,0x8(%esp)
  103d09:	00 
  103d0a:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
  103d11:	00 
  103d12:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  103d19:	e8 cb c6 ff ff       	call   1003e9 <__panic>
  103d1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103d21:	2d 00 00 00 40       	sub    $0x40000000,%eax
  103d26:	89 c2                	mov    %eax,%edx
  103d28:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103d2d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103d34:	00 
  103d35:	89 54 24 04          	mov    %edx,0x4(%esp)
  103d39:	89 04 24             	mov    %eax,(%esp)
  103d3c:	e8 84 f5 ff ff       	call   1032c5 <get_pte>
  103d41:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103d44:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  103d48:	75 24                	jne    103d6e <check_boot_pgdir+0x9e>
  103d4a:	c7 44 24 0c 98 6a 10 	movl   $0x106a98,0xc(%esp)
  103d51:	00 
  103d52:	c7 44 24 08 ad 67 10 	movl   $0x1067ad,0x8(%esp)
  103d59:	00 
  103d5a:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
  103d61:	00 
  103d62:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  103d69:	e8 7b c6 ff ff       	call   1003e9 <__panic>
        assert(PTE_ADDR(*ptep) == i);
  103d6e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103d71:	8b 00                	mov    (%eax),%eax
  103d73:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103d78:	89 c2                	mov    %eax,%edx
  103d7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103d7d:	39 c2                	cmp    %eax,%edx
  103d7f:	74 24                	je     103da5 <check_boot_pgdir+0xd5>
  103d81:	c7 44 24 0c d5 6a 10 	movl   $0x106ad5,0xc(%esp)
  103d88:	00 
  103d89:	c7 44 24 08 ad 67 10 	movl   $0x1067ad,0x8(%esp)
  103d90:	00 
  103d91:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
  103d98:	00 
  103d99:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  103da0:	e8 44 c6 ff ff       	call   1003e9 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
  103da5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  103dac:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103daf:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  103db4:	39 c2                	cmp    %eax,%edx
  103db6:	0f 82 26 ff ff ff    	jb     103ce2 <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
  103dbc:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103dc1:	05 ac 0f 00 00       	add    $0xfac,%eax
  103dc6:	8b 00                	mov    (%eax),%eax
  103dc8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103dcd:	89 c2                	mov    %eax,%edx
  103dcf:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103dd4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103dd7:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
  103dde:	77 23                	ja     103e03 <check_boot_pgdir+0x133>
  103de0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103de3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103de7:	c7 44 24 08 64 67 10 	movl   $0x106764,0x8(%esp)
  103dee:	00 
  103def:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
  103df6:	00 
  103df7:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  103dfe:	e8 e6 c5 ff ff       	call   1003e9 <__panic>
  103e03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103e06:	05 00 00 00 40       	add    $0x40000000,%eax
  103e0b:	39 c2                	cmp    %eax,%edx
  103e0d:	74 24                	je     103e33 <check_boot_pgdir+0x163>
  103e0f:	c7 44 24 0c ec 6a 10 	movl   $0x106aec,0xc(%esp)
  103e16:	00 
  103e17:	c7 44 24 08 ad 67 10 	movl   $0x1067ad,0x8(%esp)
  103e1e:	00 
  103e1f:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
  103e26:	00 
  103e27:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  103e2e:	e8 b6 c5 ff ff       	call   1003e9 <__panic>

    assert(boot_pgdir[0] == 0);
  103e33:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103e38:	8b 00                	mov    (%eax),%eax
  103e3a:	85 c0                	test   %eax,%eax
  103e3c:	74 24                	je     103e62 <check_boot_pgdir+0x192>
  103e3e:	c7 44 24 0c 20 6b 10 	movl   $0x106b20,0xc(%esp)
  103e45:	00 
  103e46:	c7 44 24 08 ad 67 10 	movl   $0x1067ad,0x8(%esp)
  103e4d:	00 
  103e4e:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
  103e55:	00 
  103e56:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  103e5d:	e8 87 c5 ff ff       	call   1003e9 <__panic>

    struct Page *p;
    p = alloc_page();
  103e62:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103e69:	e8 9b ed ff ff       	call   102c09 <alloc_pages>
  103e6e:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
  103e71:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103e76:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  103e7d:	00 
  103e7e:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  103e85:	00 
  103e86:	8b 55 e0             	mov    -0x20(%ebp),%edx
  103e89:	89 54 24 04          	mov    %edx,0x4(%esp)
  103e8d:	89 04 24             	mov    %eax,(%esp)
  103e90:	e8 6c f6 ff ff       	call   103501 <page_insert>
  103e95:	85 c0                	test   %eax,%eax
  103e97:	74 24                	je     103ebd <check_boot_pgdir+0x1ed>
  103e99:	c7 44 24 0c 34 6b 10 	movl   $0x106b34,0xc(%esp)
  103ea0:	00 
  103ea1:	c7 44 24 08 ad 67 10 	movl   $0x1067ad,0x8(%esp)
  103ea8:	00 
  103ea9:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
  103eb0:	00 
  103eb1:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  103eb8:	e8 2c c5 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p) == 1);
  103ebd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103ec0:	89 04 24             	mov    %eax,(%esp)
  103ec3:	e8 3c eb ff ff       	call   102a04 <page_ref>
  103ec8:	83 f8 01             	cmp    $0x1,%eax
  103ecb:	74 24                	je     103ef1 <check_boot_pgdir+0x221>
  103ecd:	c7 44 24 0c 62 6b 10 	movl   $0x106b62,0xc(%esp)
  103ed4:	00 
  103ed5:	c7 44 24 08 ad 67 10 	movl   $0x1067ad,0x8(%esp)
  103edc:	00 
  103edd:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
  103ee4:	00 
  103ee5:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  103eec:	e8 f8 c4 ff ff       	call   1003e9 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
  103ef1:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103ef6:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  103efd:	00 
  103efe:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
  103f05:	00 
  103f06:	8b 55 e0             	mov    -0x20(%ebp),%edx
  103f09:	89 54 24 04          	mov    %edx,0x4(%esp)
  103f0d:	89 04 24             	mov    %eax,(%esp)
  103f10:	e8 ec f5 ff ff       	call   103501 <page_insert>
  103f15:	85 c0                	test   %eax,%eax
  103f17:	74 24                	je     103f3d <check_boot_pgdir+0x26d>
  103f19:	c7 44 24 0c 74 6b 10 	movl   $0x106b74,0xc(%esp)
  103f20:	00 
  103f21:	c7 44 24 08 ad 67 10 	movl   $0x1067ad,0x8(%esp)
  103f28:	00 
  103f29:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
  103f30:	00 
  103f31:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  103f38:	e8 ac c4 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p) == 2);
  103f3d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103f40:	89 04 24             	mov    %eax,(%esp)
  103f43:	e8 bc ea ff ff       	call   102a04 <page_ref>
  103f48:	83 f8 02             	cmp    $0x2,%eax
  103f4b:	74 24                	je     103f71 <check_boot_pgdir+0x2a1>
  103f4d:	c7 44 24 0c ab 6b 10 	movl   $0x106bab,0xc(%esp)
  103f54:	00 
  103f55:	c7 44 24 08 ad 67 10 	movl   $0x1067ad,0x8(%esp)
  103f5c:	00 
  103f5d:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
  103f64:	00 
  103f65:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  103f6c:	e8 78 c4 ff ff       	call   1003e9 <__panic>

    const char *str = "ucore: Hello world!!";
  103f71:	c7 45 dc bc 6b 10 00 	movl   $0x106bbc,-0x24(%ebp)
    strcpy((void *)0x100, str);
  103f78:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103f7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  103f7f:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  103f86:	e8 bb 14 00 00       	call   105446 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
  103f8b:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
  103f92:	00 
  103f93:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  103f9a:	e8 20 15 00 00       	call   1054bf <strcmp>
  103f9f:	85 c0                	test   %eax,%eax
  103fa1:	74 24                	je     103fc7 <check_boot_pgdir+0x2f7>
  103fa3:	c7 44 24 0c d4 6b 10 	movl   $0x106bd4,0xc(%esp)
  103faa:	00 
  103fab:	c7 44 24 08 ad 67 10 	movl   $0x1067ad,0x8(%esp)
  103fb2:	00 
  103fb3:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
  103fba:	00 
  103fbb:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  103fc2:	e8 22 c4 ff ff       	call   1003e9 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
  103fc7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103fca:	89 04 24             	mov    %eax,(%esp)
  103fcd:	e8 88 e9 ff ff       	call   10295a <page2kva>
  103fd2:	05 00 01 00 00       	add    $0x100,%eax
  103fd7:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
  103fda:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  103fe1:	e8 08 14 00 00       	call   1053ee <strlen>
  103fe6:	85 c0                	test   %eax,%eax
  103fe8:	74 24                	je     10400e <check_boot_pgdir+0x33e>
  103fea:	c7 44 24 0c 0c 6c 10 	movl   $0x106c0c,0xc(%esp)
  103ff1:	00 
  103ff2:	c7 44 24 08 ad 67 10 	movl   $0x1067ad,0x8(%esp)
  103ff9:	00 
  103ffa:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
  104001:	00 
  104002:	c7 04 24 88 67 10 00 	movl   $0x106788,(%esp)
  104009:	e8 db c3 ff ff       	call   1003e9 <__panic>

    free_page(p);
  10400e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104015:	00 
  104016:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104019:	89 04 24             	mov    %eax,(%esp)
  10401c:	e8 20 ec ff ff       	call   102c41 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
  104021:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104026:	8b 00                	mov    (%eax),%eax
  104028:	89 04 24             	mov    %eax,(%esp)
  10402b:	e8 bc e9 ff ff       	call   1029ec <pde2page>
  104030:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104037:	00 
  104038:	89 04 24             	mov    %eax,(%esp)
  10403b:	e8 01 ec ff ff       	call   102c41 <free_pages>
    boot_pgdir[0] = 0;
  104040:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104045:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
  10404b:	c7 04 24 30 6c 10 00 	movl   $0x106c30,(%esp)
  104052:	e8 3b c2 ff ff       	call   100292 <cprintf>
}
  104057:	c9                   	leave  
  104058:	c3                   	ret    

00104059 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
  104059:	55                   	push   %ebp
  10405a:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
  10405c:	8b 45 08             	mov    0x8(%ebp),%eax
  10405f:	83 e0 04             	and    $0x4,%eax
  104062:	85 c0                	test   %eax,%eax
  104064:	74 07                	je     10406d <perm2str+0x14>
  104066:	b8 75 00 00 00       	mov    $0x75,%eax
  10406b:	eb 05                	jmp    104072 <perm2str+0x19>
  10406d:	b8 2d 00 00 00       	mov    $0x2d,%eax
  104072:	a2 08 af 11 00       	mov    %al,0x11af08
    str[1] = 'r';
  104077:	c6 05 09 af 11 00 72 	movb   $0x72,0x11af09
    str[2] = (perm & PTE_W) ? 'w' : '-';
  10407e:	8b 45 08             	mov    0x8(%ebp),%eax
  104081:	83 e0 02             	and    $0x2,%eax
  104084:	85 c0                	test   %eax,%eax
  104086:	74 07                	je     10408f <perm2str+0x36>
  104088:	b8 77 00 00 00       	mov    $0x77,%eax
  10408d:	eb 05                	jmp    104094 <perm2str+0x3b>
  10408f:	b8 2d 00 00 00       	mov    $0x2d,%eax
  104094:	a2 0a af 11 00       	mov    %al,0x11af0a
    str[3] = '\0';
  104099:	c6 05 0b af 11 00 00 	movb   $0x0,0x11af0b
    return str;
  1040a0:	b8 08 af 11 00       	mov    $0x11af08,%eax
}
  1040a5:	5d                   	pop    %ebp
  1040a6:	c3                   	ret    

001040a7 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
  1040a7:	55                   	push   %ebp
  1040a8:	89 e5                	mov    %esp,%ebp
  1040aa:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
  1040ad:	8b 45 10             	mov    0x10(%ebp),%eax
  1040b0:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1040b3:	72 0a                	jb     1040bf <get_pgtable_items+0x18>
        return 0;
  1040b5:	b8 00 00 00 00       	mov    $0x0,%eax
  1040ba:	e9 9c 00 00 00       	jmp    10415b <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
  1040bf:	eb 04                	jmp    1040c5 <get_pgtable_items+0x1e>
        start ++;
  1040c1:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
  1040c5:	8b 45 10             	mov    0x10(%ebp),%eax
  1040c8:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1040cb:	73 18                	jae    1040e5 <get_pgtable_items+0x3e>
  1040cd:	8b 45 10             	mov    0x10(%ebp),%eax
  1040d0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1040d7:	8b 45 14             	mov    0x14(%ebp),%eax
  1040da:	01 d0                	add    %edx,%eax
  1040dc:	8b 00                	mov    (%eax),%eax
  1040de:	83 e0 01             	and    $0x1,%eax
  1040e1:	85 c0                	test   %eax,%eax
  1040e3:	74 dc                	je     1040c1 <get_pgtable_items+0x1a>
    }
    if (start < right) {
  1040e5:	8b 45 10             	mov    0x10(%ebp),%eax
  1040e8:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1040eb:	73 69                	jae    104156 <get_pgtable_items+0xaf>
        if (left_store != NULL) {
  1040ed:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
  1040f1:	74 08                	je     1040fb <get_pgtable_items+0x54>
            *left_store = start;
  1040f3:	8b 45 18             	mov    0x18(%ebp),%eax
  1040f6:	8b 55 10             	mov    0x10(%ebp),%edx
  1040f9:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
  1040fb:	8b 45 10             	mov    0x10(%ebp),%eax
  1040fe:	8d 50 01             	lea    0x1(%eax),%edx
  104101:	89 55 10             	mov    %edx,0x10(%ebp)
  104104:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  10410b:	8b 45 14             	mov    0x14(%ebp),%eax
  10410e:	01 d0                	add    %edx,%eax
  104110:	8b 00                	mov    (%eax),%eax
  104112:	83 e0 07             	and    $0x7,%eax
  104115:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  104118:	eb 04                	jmp    10411e <get_pgtable_items+0x77>
            start ++;
  10411a:	83 45 10 01          	addl   $0x1,0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  10411e:	8b 45 10             	mov    0x10(%ebp),%eax
  104121:	3b 45 0c             	cmp    0xc(%ebp),%eax
  104124:	73 1d                	jae    104143 <get_pgtable_items+0x9c>
  104126:	8b 45 10             	mov    0x10(%ebp),%eax
  104129:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  104130:	8b 45 14             	mov    0x14(%ebp),%eax
  104133:	01 d0                	add    %edx,%eax
  104135:	8b 00                	mov    (%eax),%eax
  104137:	83 e0 07             	and    $0x7,%eax
  10413a:	89 c2                	mov    %eax,%edx
  10413c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10413f:	39 c2                	cmp    %eax,%edx
  104141:	74 d7                	je     10411a <get_pgtable_items+0x73>
        }
        if (right_store != NULL) {
  104143:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  104147:	74 08                	je     104151 <get_pgtable_items+0xaa>
            *right_store = start;
  104149:	8b 45 1c             	mov    0x1c(%ebp),%eax
  10414c:	8b 55 10             	mov    0x10(%ebp),%edx
  10414f:	89 10                	mov    %edx,(%eax)
        }
        return perm;
  104151:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104154:	eb 05                	jmp    10415b <get_pgtable_items+0xb4>
    }
    return 0;
  104156:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10415b:	c9                   	leave  
  10415c:	c3                   	ret    

0010415d <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  10415d:	55                   	push   %ebp
  10415e:	89 e5                	mov    %esp,%ebp
  104160:	57                   	push   %edi
  104161:	56                   	push   %esi
  104162:	53                   	push   %ebx
  104163:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
  104166:	c7 04 24 50 6c 10 00 	movl   $0x106c50,(%esp)
  10416d:	e8 20 c1 ff ff       	call   100292 <cprintf>
    size_t left, right = 0, perm;
  104172:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  104179:	e9 fa 00 00 00       	jmp    104278 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  10417e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104181:	89 04 24             	mov    %eax,(%esp)
  104184:	e8 d0 fe ff ff       	call   104059 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
  104189:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  10418c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10418f:	29 d1                	sub    %edx,%ecx
  104191:	89 ca                	mov    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  104193:	89 d6                	mov    %edx,%esi
  104195:	c1 e6 16             	shl    $0x16,%esi
  104198:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10419b:	89 d3                	mov    %edx,%ebx
  10419d:	c1 e3 16             	shl    $0x16,%ebx
  1041a0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1041a3:	89 d1                	mov    %edx,%ecx
  1041a5:	c1 e1 16             	shl    $0x16,%ecx
  1041a8:	8b 7d dc             	mov    -0x24(%ebp),%edi
  1041ab:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1041ae:	29 d7                	sub    %edx,%edi
  1041b0:	89 fa                	mov    %edi,%edx
  1041b2:	89 44 24 14          	mov    %eax,0x14(%esp)
  1041b6:	89 74 24 10          	mov    %esi,0x10(%esp)
  1041ba:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1041be:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  1041c2:	89 54 24 04          	mov    %edx,0x4(%esp)
  1041c6:	c7 04 24 81 6c 10 00 	movl   $0x106c81,(%esp)
  1041cd:	e8 c0 c0 ff ff       	call   100292 <cprintf>
        size_t l, r = left * NPTEENTRY;
  1041d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1041d5:	c1 e0 0a             	shl    $0xa,%eax
  1041d8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  1041db:	eb 54                	jmp    104231 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  1041dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1041e0:	89 04 24             	mov    %eax,(%esp)
  1041e3:	e8 71 fe ff ff       	call   104059 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
  1041e8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  1041eb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1041ee:	29 d1                	sub    %edx,%ecx
  1041f0:	89 ca                	mov    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  1041f2:	89 d6                	mov    %edx,%esi
  1041f4:	c1 e6 0c             	shl    $0xc,%esi
  1041f7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1041fa:	89 d3                	mov    %edx,%ebx
  1041fc:	c1 e3 0c             	shl    $0xc,%ebx
  1041ff:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104202:	c1 e2 0c             	shl    $0xc,%edx
  104205:	89 d1                	mov    %edx,%ecx
  104207:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  10420a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  10420d:	29 d7                	sub    %edx,%edi
  10420f:	89 fa                	mov    %edi,%edx
  104211:	89 44 24 14          	mov    %eax,0x14(%esp)
  104215:	89 74 24 10          	mov    %esi,0x10(%esp)
  104219:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  10421d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  104221:	89 54 24 04          	mov    %edx,0x4(%esp)
  104225:	c7 04 24 a0 6c 10 00 	movl   $0x106ca0,(%esp)
  10422c:	e8 61 c0 ff ff       	call   100292 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  104231:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
  104236:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104239:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  10423c:	89 ce                	mov    %ecx,%esi
  10423e:	c1 e6 0a             	shl    $0xa,%esi
  104241:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  104244:	89 cb                	mov    %ecx,%ebx
  104246:	c1 e3 0a             	shl    $0xa,%ebx
  104249:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
  10424c:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  104250:	8d 4d d8             	lea    -0x28(%ebp),%ecx
  104253:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  104257:	89 54 24 0c          	mov    %edx,0xc(%esp)
  10425b:	89 44 24 08          	mov    %eax,0x8(%esp)
  10425f:	89 74 24 04          	mov    %esi,0x4(%esp)
  104263:	89 1c 24             	mov    %ebx,(%esp)
  104266:	e8 3c fe ff ff       	call   1040a7 <get_pgtable_items>
  10426b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10426e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  104272:	0f 85 65 ff ff ff    	jne    1041dd <print_pgdir+0x80>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  104278:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
  10427d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104280:	8d 4d dc             	lea    -0x24(%ebp),%ecx
  104283:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  104287:	8d 4d e0             	lea    -0x20(%ebp),%ecx
  10428a:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  10428e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  104292:	89 44 24 08          	mov    %eax,0x8(%esp)
  104296:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
  10429d:	00 
  10429e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1042a5:	e8 fd fd ff ff       	call   1040a7 <get_pgtable_items>
  1042aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1042ad:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1042b1:	0f 85 c7 fe ff ff    	jne    10417e <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
  1042b7:	c7 04 24 c4 6c 10 00 	movl   $0x106cc4,(%esp)
  1042be:	e8 cf bf ff ff       	call   100292 <cprintf>
}
  1042c3:	83 c4 4c             	add    $0x4c,%esp
  1042c6:	5b                   	pop    %ebx
  1042c7:	5e                   	pop    %esi
  1042c8:	5f                   	pop    %edi
  1042c9:	5d                   	pop    %ebp
  1042ca:	c3                   	ret    

001042cb <page2ppn>:
page2ppn(struct Page *page) {
  1042cb:	55                   	push   %ebp
  1042cc:	89 e5                	mov    %esp,%ebp
    return page - pages;
  1042ce:	8b 55 08             	mov    0x8(%ebp),%edx
  1042d1:	a1 18 af 11 00       	mov    0x11af18,%eax
  1042d6:	29 c2                	sub    %eax,%edx
  1042d8:	89 d0                	mov    %edx,%eax
  1042da:	c1 f8 02             	sar    $0x2,%eax
  1042dd:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  1042e3:	5d                   	pop    %ebp
  1042e4:	c3                   	ret    

001042e5 <page2pa>:
page2pa(struct Page *page) {
  1042e5:	55                   	push   %ebp
  1042e6:	89 e5                	mov    %esp,%ebp
  1042e8:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  1042eb:	8b 45 08             	mov    0x8(%ebp),%eax
  1042ee:	89 04 24             	mov    %eax,(%esp)
  1042f1:	e8 d5 ff ff ff       	call   1042cb <page2ppn>
  1042f6:	c1 e0 0c             	shl    $0xc,%eax
}
  1042f9:	c9                   	leave  
  1042fa:	c3                   	ret    

001042fb <page_ref>:
page_ref(struct Page *page) {
  1042fb:	55                   	push   %ebp
  1042fc:	89 e5                	mov    %esp,%ebp
    return page->ref;
  1042fe:	8b 45 08             	mov    0x8(%ebp),%eax
  104301:	8b 00                	mov    (%eax),%eax
}
  104303:	5d                   	pop    %ebp
  104304:	c3                   	ret    

00104305 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
  104305:	55                   	push   %ebp
  104306:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  104308:	8b 45 08             	mov    0x8(%ebp),%eax
  10430b:	8b 55 0c             	mov    0xc(%ebp),%edx
  10430e:	89 10                	mov    %edx,(%eax)
}
  104310:	5d                   	pop    %ebp
  104311:	c3                   	ret    

00104312 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
  104312:	55                   	push   %ebp
  104313:	89 e5                	mov    %esp,%ebp
  104315:	83 ec 10             	sub    $0x10,%esp
  104318:	c7 45 fc 1c af 11 00 	movl   $0x11af1c,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  10431f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104322:	8b 55 fc             	mov    -0x4(%ebp),%edx
  104325:	89 50 04             	mov    %edx,0x4(%eax)
  104328:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10432b:	8b 50 04             	mov    0x4(%eax),%edx
  10432e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104331:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
  104333:	c7 05 24 af 11 00 00 	movl   $0x0,0x11af24
  10433a:	00 00 00 
}
  10433d:	c9                   	leave  
  10433e:	c3                   	ret    

0010433f <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
  10433f:	55                   	push   %ebp
  104340:	89 e5                	mov    %esp,%ebp
  104342:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
  104345:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  104349:	75 24                	jne    10436f <default_init_memmap+0x30>
  10434b:	c7 44 24 0c f8 6c 10 	movl   $0x106cf8,0xc(%esp)
  104352:	00 
  104353:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  10435a:	00 
  10435b:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  104362:	00 
  104363:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  10436a:	e8 7a c0 ff ff       	call   1003e9 <__panic>
    struct Page *p = base;
  10436f:	8b 45 08             	mov    0x8(%ebp),%eax
  104372:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  104375:	e9 dc 00 00 00       	jmp    104456 <default_init_memmap+0x117>
        //初始化n块物理页
        assert(PageReserved(p));
  10437a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10437d:	83 c0 04             	add    $0x4,%eax
  104380:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  104387:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10438a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10438d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  104390:	0f a3 10             	bt     %edx,(%eax)
  104393:	19 c0                	sbb    %eax,%eax
  104395:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
  104398:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10439c:	0f 95 c0             	setne  %al
  10439f:	0f b6 c0             	movzbl %al,%eax
  1043a2:	85 c0                	test   %eax,%eax
  1043a4:	75 24                	jne    1043ca <default_init_memmap+0x8b>
  1043a6:	c7 44 24 0c 29 6d 10 	movl   $0x106d29,0xc(%esp)
  1043ad:	00 
  1043ae:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  1043b5:	00 
  1043b6:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
  1043bd:	00 
  1043be:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  1043c5:	e8 1f c0 ff ff       	call   1003e9 <__panic>
        p->flags = 0;
  1043ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1043cd:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        SetPageProperty(p);
  1043d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1043d7:	83 c0 04             	add    $0x4,%eax
  1043da:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  1043e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1043e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1043e7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1043ea:	0f ab 10             	bts    %edx,(%eax)
        p->property = 0;
  1043ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1043f0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        set_page_ref(p, 0);
  1043f7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1043fe:	00 
  1043ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104402:	89 04 24             	mov    %eax,(%esp)
  104405:	e8 fb fe ff ff       	call   104305 <set_page_ref>
        list_add_before(&free_list, &(p->page_link));
  10440a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10440d:	83 c0 0c             	add    $0xc,%eax
  104410:	c7 45 dc 1c af 11 00 	movl   $0x11af1c,-0x24(%ebp)
  104417:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  10441a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10441d:	8b 00                	mov    (%eax),%eax
  10441f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104422:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  104425:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104428:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10442b:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  10442e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104431:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104434:	89 10                	mov    %edx,(%eax)
  104436:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104439:	8b 10                	mov    (%eax),%edx
  10443b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10443e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  104441:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104444:	8b 55 cc             	mov    -0x34(%ebp),%edx
  104447:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  10444a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10444d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104450:	89 10                	mov    %edx,(%eax)
    for (; p != base + n; p ++) {
  104452:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  104456:	8b 55 0c             	mov    0xc(%ebp),%edx
  104459:	89 d0                	mov    %edx,%eax
  10445b:	c1 e0 02             	shl    $0x2,%eax
  10445e:	01 d0                	add    %edx,%eax
  104460:	c1 e0 02             	shl    $0x2,%eax
  104463:	89 c2                	mov    %eax,%edx
  104465:	8b 45 08             	mov    0x8(%ebp),%eax
  104468:	01 d0                	add    %edx,%eax
  10446a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  10446d:	0f 85 07 ff ff ff    	jne    10437a <default_init_memmap+0x3b>
    }
    nr_free += n;
  104473:	8b 15 24 af 11 00    	mov    0x11af24,%edx
  104479:	8b 45 0c             	mov    0xc(%ebp),%eax
  10447c:	01 d0                	add    %edx,%eax
  10447e:	a3 24 af 11 00       	mov    %eax,0x11af24
    base->property = n;
  104483:	8b 45 08             	mov    0x8(%ebp),%eax
  104486:	8b 55 0c             	mov    0xc(%ebp),%edx
  104489:	89 50 08             	mov    %edx,0x8(%eax)
}
  10448c:	c9                   	leave  
  10448d:	c3                   	ret    

0010448e <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
  10448e:	55                   	push   %ebp
  10448f:	89 e5                	mov    %esp,%ebp
  104491:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
  104494:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  104498:	75 24                	jne    1044be <default_alloc_pages+0x30>
  10449a:	c7 44 24 0c f8 6c 10 	movl   $0x106cf8,0xc(%esp)
  1044a1:	00 
  1044a2:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  1044a9:	00 
  1044aa:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  1044b1:	00 
  1044b2:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  1044b9:	e8 2b bf ff ff       	call   1003e9 <__panic>
    if (n > nr_free) {
  1044be:	a1 24 af 11 00       	mov    0x11af24,%eax
  1044c3:	3b 45 08             	cmp    0x8(%ebp),%eax
  1044c6:	73 0a                	jae    1044d2 <default_alloc_pages+0x44>
        return NULL;
  1044c8:	b8 00 00 00 00       	mov    $0x0,%eax
  1044cd:	e9 37 01 00 00       	jmp    104609 <default_alloc_pages+0x17b>
    }
    //如果所有空闲块的空闲页总数都没有n个,直接return null
    list_entry_t *le, *le_next;  //free_list指针和它的下一个
    le = &free_list;
  1044d2:	c7 45 f4 1c af 11 00 	movl   $0x11af1c,-0xc(%ebp)
    //从头开始遍历保存空闲物理内存块的链表(按照物理地址的从小到大顺序)
    while((le=list_next(le)) != &free_list) {
  1044d9:	e9 0a 01 00 00       	jmp    1045e8 <default_alloc_pages+0x15a>
    //通过宏le2page(memlayout.h)得指向Page的指针p
      struct Page *p = le2page(le, page_link);
  1044de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1044e1:	83 e8 0c             	sub    $0xc,%eax
  1044e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(p->property >= n){
  1044e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1044ea:	8b 40 08             	mov    0x8(%eax),%eax
  1044ed:	3b 45 08             	cmp    0x8(%ebp),%eax
  1044f0:	0f 82 f2 00 00 00    	jb     1045e8 <default_alloc_pages+0x15a>
        //p->property表示空闲块的大小，大于n则进下一步
        int i;
        //for初始化空闲块中每一个页
        for(i=0;i<n;i++){
  1044f6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  1044fd:	eb 7c                	jmp    10457b <default_alloc_pages+0xed>
  1044ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104502:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
  104505:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104508:	8b 40 04             	mov    0x4(%eax),%eax
          le_next = list_next(le);
  10450b:	89 45 e8             	mov    %eax,-0x18(%ebp)
          struct Page *p2 = le2page(le, page_link);
  10450e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104511:	83 e8 0c             	sub    $0xc,%eax
  104514:	89 45 e4             	mov    %eax,-0x1c(%ebp)
          SetPageReserved(p2);//flags bit0 置1，表示已经被分配
  104517:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10451a:	83 c0 04             	add    $0x4,%eax
  10451d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  104524:	89 45 d8             	mov    %eax,-0x28(%ebp)
  104527:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10452a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10452d:	0f ab 10             	bts    %edx,(%eax)
          ClearPageProperty(p2);//falgs bit1 置0，表示已被分配
  104530:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104533:	83 c0 04             	add    $0x4,%eax
  104536:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  10453d:	89 45 d0             	mov    %eax,-0x30(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104540:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104543:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104546:	0f b3 10             	btr    %edx,(%eax)
  104549:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10454c:	89 45 cc             	mov    %eax,-0x34(%ebp)
    __list_del(listelm->prev, listelm->next);
  10454f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104552:	8b 40 04             	mov    0x4(%eax),%eax
  104555:	8b 55 cc             	mov    -0x34(%ebp),%edx
  104558:	8b 12                	mov    (%edx),%edx
  10455a:	89 55 c8             	mov    %edx,-0x38(%ebp)
  10455d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  104560:	8b 45 c8             	mov    -0x38(%ebp),%eax
  104563:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  104566:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  104569:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  10456c:	8b 55 c8             	mov    -0x38(%ebp),%edx
  10456f:	89 10                	mov    %edx,(%eax)
          list_del(le);//取消和free_list的link
          le = le_next;//指针后移
  104571:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104574:	89 45 f4             	mov    %eax,-0xc(%ebp)
        for(i=0;i<n;i++){
  104577:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  10457b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10457e:	3b 45 08             	cmp    0x8(%ebp),%eax
  104581:	0f 82 78 ff ff ff    	jb     1044ff <default_alloc_pages+0x71>
        }
        //如果选中的块大于n,需要修改剩下的块的head page的property
        if(p->property>n){
  104587:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10458a:	8b 40 08             	mov    0x8(%eax),%eax
  10458d:	3b 45 08             	cmp    0x8(%ebp),%eax
  104590:	76 12                	jbe    1045a4 <default_alloc_pages+0x116>
          (le2page(le,page_link))->property = p->property - n;
  104592:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104595:	8d 50 f4             	lea    -0xc(%eax),%edx
  104598:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10459b:	8b 40 08             	mov    0x8(%eax),%eax
  10459e:	2b 45 08             	sub    0x8(%ebp),%eax
  1045a1:	89 42 08             	mov    %eax,0x8(%edx)
        }
        ClearPageProperty(p);
  1045a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1045a7:	83 c0 04             	add    $0x4,%eax
  1045aa:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  1045b1:	89 45 bc             	mov    %eax,-0x44(%ebp)
  1045b4:	8b 45 bc             	mov    -0x44(%ebp),%eax
  1045b7:	8b 55 c0             	mov    -0x40(%ebp),%edx
  1045ba:	0f b3 10             	btr    %edx,(%eax)
        SetPageReserved(p);
  1045bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1045c0:	83 c0 04             	add    $0x4,%eax
  1045c3:	c7 45 b8 00 00 00 00 	movl   $0x0,-0x48(%ebp)
  1045ca:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1045cd:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1045d0:	8b 55 b8             	mov    -0x48(%ebp),%edx
  1045d3:	0f ab 10             	bts    %edx,(%eax)
        nr_free -= n;
  1045d6:	a1 24 af 11 00       	mov    0x11af24,%eax
  1045db:	2b 45 08             	sub    0x8(%ebp),%eax
  1045de:	a3 24 af 11 00       	mov    %eax,0x11af24
        return p;
  1045e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1045e6:	eb 21                	jmp    104609 <default_alloc_pages+0x17b>
  1045e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045eb:	89 45 b0             	mov    %eax,-0x50(%ebp)
    return listelm->next;
  1045ee:	8b 45 b0             	mov    -0x50(%ebp),%eax
  1045f1:	8b 40 04             	mov    0x4(%eax),%eax
    while((le=list_next(le)) != &free_list) {
  1045f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1045f7:	81 7d f4 1c af 11 00 	cmpl   $0x11af1c,-0xc(%ebp)
  1045fe:	0f 85 da fe ff ff    	jne    1044de <default_alloc_pages+0x50>
      }
    }
    return NULL;//防止出错
  104604:	b8 00 00 00 00       	mov    $0x0,%eax
}
  104609:	c9                   	leave  
  10460a:	c3                   	ret    

0010460b <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
  10460b:	55                   	push   %ebp
  10460c:	89 e5                	mov    %esp,%ebp
  10460e:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
  104611:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  104615:	75 24                	jne    10463b <default_free_pages+0x30>
  104617:	c7 44 24 0c f8 6c 10 	movl   $0x106cf8,0xc(%esp)
  10461e:	00 
  10461f:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  104626:	00 
  104627:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
  10462e:	00 
  10462f:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  104636:	e8 ae bd ff ff       	call   1003e9 <__panic>
    //assert(PageReserved(base) && PageProperty(base));
    assert(PageReserved(base));
  10463b:	8b 45 08             	mov    0x8(%ebp),%eax
  10463e:	83 c0 04             	add    $0x4,%eax
  104641:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  104648:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10464b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10464e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  104651:	0f a3 10             	bt     %edx,(%eax)
  104654:	19 c0                	sbb    %eax,%eax
  104656:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
  104659:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10465d:	0f 95 c0             	setne  %al
  104660:	0f b6 c0             	movzbl %al,%eax
  104663:	85 c0                	test   %eax,%eax
  104665:	75 24                	jne    10468b <default_free_pages+0x80>
  104667:	c7 44 24 0c 39 6d 10 	movl   $0x106d39,0xc(%esp)
  10466e:	00 
  10466f:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  104676:	00 
  104677:	c7 44 24 04 a6 00 00 	movl   $0xa6,0x4(%esp)
  10467e:	00 
  10467f:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  104686:	e8 5e bd ff ff       	call   1003e9 <__panic>
    //检查需要释放的页块是否已经被分配,只要看bit 0 reserve就好了
    list_entry_t *le = &free_list;
  10468b:	c7 45 f4 1c af 11 00 	movl   $0x11af1c,-0xc(%ebp)
    struct Page * p;
    while((le=list_next(le)) != &free_list) {
  104692:	eb 13                	jmp    1046a7 <default_free_pages+0x9c>
      p = le2page(le, page_link);
  104694:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104697:	83 e8 0c             	sub    $0xc,%eax
  10469a:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(p>base){break;}
  10469d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1046a0:	3b 45 08             	cmp    0x8(%ebp),%eax
  1046a3:	76 02                	jbe    1046a7 <default_free_pages+0x9c>
  1046a5:	eb 18                	jmp    1046bf <default_free_pages+0xb4>
  1046a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1046ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1046b0:	8b 40 04             	mov    0x4(%eax),%eax
    while((le=list_next(le)) != &free_list) {
  1046b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1046b6:	81 7d f4 1c af 11 00 	cmpl   $0x11af1c,-0xc(%ebp)
  1046bd:	75 d5                	jne    104694 <default_free_pages+0x89>
    }
    //将每一空闲块的链表插入空闲链表中
    for(p=base;p<base+n;p++){
  1046bf:	8b 45 08             	mov    0x8(%ebp),%eax
  1046c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1046c5:	eb 4b                	jmp    104712 <default_free_pages+0x107>
      list_add_before(le, &(p->page_link));
  1046c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1046ca:	8d 50 0c             	lea    0xc(%eax),%edx
  1046cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046d0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1046d3:	89 55 d8             	mov    %edx,-0x28(%ebp)
    __list_add(elm, listelm->prev, listelm);
  1046d6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1046d9:	8b 00                	mov    (%eax),%eax
  1046db:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1046de:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  1046e1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1046e4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1046e7:	89 45 cc             	mov    %eax,-0x34(%ebp)
    prev->next = next->prev = elm;
  1046ea:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1046ed:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1046f0:	89 10                	mov    %edx,(%eax)
  1046f2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1046f5:	8b 10                	mov    (%eax),%edx
  1046f7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1046fa:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  1046fd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104700:	8b 55 cc             	mov    -0x34(%ebp),%edx
  104703:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  104706:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104709:	8b 55 d0             	mov    -0x30(%ebp),%edx
  10470c:	89 10                	mov    %edx,(%eax)
    for(p=base;p<base+n;p++){
  10470e:	83 45 f0 14          	addl   $0x14,-0x10(%ebp)
  104712:	8b 55 0c             	mov    0xc(%ebp),%edx
  104715:	89 d0                	mov    %edx,%eax
  104717:	c1 e0 02             	shl    $0x2,%eax
  10471a:	01 d0                	add    %edx,%eax
  10471c:	c1 e0 02             	shl    $0x2,%eax
  10471f:	89 c2                	mov    %eax,%edx
  104721:	8b 45 08             	mov    0x8(%ebp),%eax
  104724:	01 d0                	add    %edx,%eax
  104726:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  104729:	77 9c                	ja     1046c7 <default_free_pages+0xbc>
    }
    //修改页的各个属性置0
    base->flags = 0;
  10472b:	8b 45 08             	mov    0x8(%ebp),%eax
  10472e:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    set_page_ref(base, 0);
  104735:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10473c:	00 
  10473d:	8b 45 08             	mov    0x8(%ebp),%eax
  104740:	89 04 24             	mov    %eax,(%esp)
  104743:	e8 bd fb ff ff       	call   104305 <set_page_ref>
    ClearPageProperty(base);
  104748:	8b 45 08             	mov    0x8(%ebp),%eax
  10474b:	83 c0 04             	add    $0x4,%eax
  10474e:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
  104755:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104758:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  10475b:	8b 55 c8             	mov    -0x38(%ebp),%edx
  10475e:	0f b3 10             	btr    %edx,(%eax)
    SetPageProperty(base);
  104761:	8b 45 08             	mov    0x8(%ebp),%eax
  104764:	83 c0 04             	add    $0x4,%eax
  104767:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  10476e:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104771:	8b 45 bc             	mov    -0x44(%ebp),%eax
  104774:	8b 55 c0             	mov    -0x40(%ebp),%edx
  104777:	0f ab 10             	bts    %edx,(%eax)
    base->property = n;//有n空闲页
  10477a:	8b 45 08             	mov    0x8(%ebp),%eax
  10477d:	8b 55 0c             	mov    0xc(%ebp),%edx
  104780:	89 50 08             	mov    %edx,0x8(%eax)
    p = le2page(le,page_link) ;
  104783:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104786:	83 e8 0c             	sub    $0xc,%eax
  104789:	89 45 f0             	mov    %eax,-0x10(%ebp)
    //和高位方向的下一个内存块的地址连续，向高位合并
    if( base+n == p ){
  10478c:	8b 55 0c             	mov    0xc(%ebp),%edx
  10478f:	89 d0                	mov    %edx,%eax
  104791:	c1 e0 02             	shl    $0x2,%eax
  104794:	01 d0                	add    %edx,%eax
  104796:	c1 e0 02             	shl    $0x2,%eax
  104799:	89 c2                	mov    %eax,%edx
  10479b:	8b 45 08             	mov    0x8(%ebp),%eax
  10479e:	01 d0                	add    %edx,%eax
  1047a0:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  1047a3:	75 1e                	jne    1047c3 <default_free_pages+0x1b8>
      base->property += p->property;
  1047a5:	8b 45 08             	mov    0x8(%ebp),%eax
  1047a8:	8b 50 08             	mov    0x8(%eax),%edx
  1047ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1047ae:	8b 40 08             	mov    0x8(%eax),%eax
  1047b1:	01 c2                	add    %eax,%edx
  1047b3:	8b 45 08             	mov    0x8(%ebp),%eax
  1047b6:	89 50 08             	mov    %edx,0x8(%eax)
      p->property = 0;
  1047b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1047bc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    }
    //如果是低位,向低地址合并
    //把le指针指向前一个内存块
    le = list_prev(&(base->page_link));  //previous
  1047c3:	8b 45 08             	mov    0x8(%ebp),%eax
  1047c6:	83 c0 0c             	add    $0xc,%eax
  1047c9:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return listelm->prev;
  1047cc:	8b 45 b8             	mov    -0x48(%ebp),%eax
  1047cf:	8b 00                	mov    (%eax),%eax
  1047d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    p = le2page(le, page_link);
  1047d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1047d7:	83 e8 0c             	sub    $0xc,%eax
  1047da:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(le!=&free_list && p==base-1){
  1047dd:	81 7d f4 1c af 11 00 	cmpl   $0x11af1c,-0xc(%ebp)
  1047e4:	74 57                	je     10483d <default_free_pages+0x232>
  1047e6:	8b 45 08             	mov    0x8(%ebp),%eax
  1047e9:	83 e8 14             	sub    $0x14,%eax
  1047ec:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  1047ef:	75 4c                	jne    10483d <default_free_pages+0x232>
      while(le!=&free_list){
  1047f1:	eb 41                	jmp    104834 <default_free_pages+0x229>
        if(p->property){
  1047f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1047f6:	8b 40 08             	mov    0x8(%eax),%eax
  1047f9:	85 c0                	test   %eax,%eax
  1047fb:	74 20                	je     10481d <default_free_pages+0x212>
          p->property += base->property;
  1047fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104800:	8b 50 08             	mov    0x8(%eax),%edx
  104803:	8b 45 08             	mov    0x8(%ebp),%eax
  104806:	8b 40 08             	mov    0x8(%eax),%eax
  104809:	01 c2                	add    %eax,%edx
  10480b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10480e:	89 50 08             	mov    %edx,0x8(%eax)
          base->property = 0;
  104811:	8b 45 08             	mov    0x8(%ebp),%eax
  104814:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
          break;
  10481b:	eb 20                	jmp    10483d <default_free_pages+0x232>
  10481d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104820:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  104823:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104826:	8b 00                	mov    (%eax),%eax
        }
        le = list_prev(le);
  104828:	89 45 f4             	mov    %eax,-0xc(%ebp)
        p = le2page(le,page_link);
  10482b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10482e:	83 e8 0c             	sub    $0xc,%eax
  104831:	89 45 f0             	mov    %eax,-0x10(%ebp)
      while(le!=&free_list){
  104834:	81 7d f4 1c af 11 00 	cmpl   $0x11af1c,-0xc(%ebp)
  10483b:	75 b6                	jne    1047f3 <default_free_pages+0x1e8>
      }
    }
   //更新总空闲页数
    nr_free += n;
  10483d:	8b 15 24 af 11 00    	mov    0x11af24,%edx
  104843:	8b 45 0c             	mov    0xc(%ebp),%eax
  104846:	01 d0                	add    %edx,%eax
  104848:	a3 24 af 11 00       	mov    %eax,0x11af24
    return ;
  10484d:	90                   	nop
}
  10484e:	c9                   	leave  
  10484f:	c3                   	ret    

00104850 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
  104850:	55                   	push   %ebp
  104851:	89 e5                	mov    %esp,%ebp
    return nr_free;
  104853:	a1 24 af 11 00       	mov    0x11af24,%eax
}
  104858:	5d                   	pop    %ebp
  104859:	c3                   	ret    

0010485a <basic_check>:

static void
basic_check(void) {
  10485a:	55                   	push   %ebp
  10485b:	89 e5                	mov    %esp,%ebp
  10485d:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
  104860:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104867:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10486a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10486d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104870:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
  104873:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10487a:	e8 8a e3 ff ff       	call   102c09 <alloc_pages>
  10487f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104882:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  104886:	75 24                	jne    1048ac <basic_check+0x52>
  104888:	c7 44 24 0c 4c 6d 10 	movl   $0x106d4c,0xc(%esp)
  10488f:	00 
  104890:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  104897:	00 
  104898:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
  10489f:	00 
  1048a0:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  1048a7:	e8 3d bb ff ff       	call   1003e9 <__panic>
    assert((p1 = alloc_page()) != NULL);
  1048ac:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1048b3:	e8 51 e3 ff ff       	call   102c09 <alloc_pages>
  1048b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1048bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1048bf:	75 24                	jne    1048e5 <basic_check+0x8b>
  1048c1:	c7 44 24 0c 68 6d 10 	movl   $0x106d68,0xc(%esp)
  1048c8:	00 
  1048c9:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  1048d0:	00 
  1048d1:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
  1048d8:	00 
  1048d9:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  1048e0:	e8 04 bb ff ff       	call   1003e9 <__panic>
    assert((p2 = alloc_page()) != NULL);
  1048e5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1048ec:	e8 18 e3 ff ff       	call   102c09 <alloc_pages>
  1048f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1048f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1048f8:	75 24                	jne    10491e <basic_check+0xc4>
  1048fa:	c7 44 24 0c 84 6d 10 	movl   $0x106d84,0xc(%esp)
  104901:	00 
  104902:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  104909:	00 
  10490a:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
  104911:	00 
  104912:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  104919:	e8 cb ba ff ff       	call   1003e9 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
  10491e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104921:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  104924:	74 10                	je     104936 <basic_check+0xdc>
  104926:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104929:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  10492c:	74 08                	je     104936 <basic_check+0xdc>
  10492e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104931:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104934:	75 24                	jne    10495a <basic_check+0x100>
  104936:	c7 44 24 0c a0 6d 10 	movl   $0x106da0,0xc(%esp)
  10493d:	00 
  10493e:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  104945:	00 
  104946:	c7 44 24 04 df 00 00 	movl   $0xdf,0x4(%esp)
  10494d:	00 
  10494e:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  104955:	e8 8f ba ff ff       	call   1003e9 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  10495a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10495d:	89 04 24             	mov    %eax,(%esp)
  104960:	e8 96 f9 ff ff       	call   1042fb <page_ref>
  104965:	85 c0                	test   %eax,%eax
  104967:	75 1e                	jne    104987 <basic_check+0x12d>
  104969:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10496c:	89 04 24             	mov    %eax,(%esp)
  10496f:	e8 87 f9 ff ff       	call   1042fb <page_ref>
  104974:	85 c0                	test   %eax,%eax
  104976:	75 0f                	jne    104987 <basic_check+0x12d>
  104978:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10497b:	89 04 24             	mov    %eax,(%esp)
  10497e:	e8 78 f9 ff ff       	call   1042fb <page_ref>
  104983:	85 c0                	test   %eax,%eax
  104985:	74 24                	je     1049ab <basic_check+0x151>
  104987:	c7 44 24 0c c4 6d 10 	movl   $0x106dc4,0xc(%esp)
  10498e:	00 
  10498f:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  104996:	00 
  104997:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
  10499e:	00 
  10499f:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  1049a6:	e8 3e ba ff ff       	call   1003e9 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  1049ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1049ae:	89 04 24             	mov    %eax,(%esp)
  1049b1:	e8 2f f9 ff ff       	call   1042e5 <page2pa>
  1049b6:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  1049bc:	c1 e2 0c             	shl    $0xc,%edx
  1049bf:	39 d0                	cmp    %edx,%eax
  1049c1:	72 24                	jb     1049e7 <basic_check+0x18d>
  1049c3:	c7 44 24 0c 00 6e 10 	movl   $0x106e00,0xc(%esp)
  1049ca:	00 
  1049cb:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  1049d2:	00 
  1049d3:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
  1049da:	00 
  1049db:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  1049e2:	e8 02 ba ff ff       	call   1003e9 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  1049e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1049ea:	89 04 24             	mov    %eax,(%esp)
  1049ed:	e8 f3 f8 ff ff       	call   1042e5 <page2pa>
  1049f2:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  1049f8:	c1 e2 0c             	shl    $0xc,%edx
  1049fb:	39 d0                	cmp    %edx,%eax
  1049fd:	72 24                	jb     104a23 <basic_check+0x1c9>
  1049ff:	c7 44 24 0c 1d 6e 10 	movl   $0x106e1d,0xc(%esp)
  104a06:	00 
  104a07:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  104a0e:	00 
  104a0f:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
  104a16:	00 
  104a17:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  104a1e:	e8 c6 b9 ff ff       	call   1003e9 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  104a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104a26:	89 04 24             	mov    %eax,(%esp)
  104a29:	e8 b7 f8 ff ff       	call   1042e5 <page2pa>
  104a2e:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  104a34:	c1 e2 0c             	shl    $0xc,%edx
  104a37:	39 d0                	cmp    %edx,%eax
  104a39:	72 24                	jb     104a5f <basic_check+0x205>
  104a3b:	c7 44 24 0c 3a 6e 10 	movl   $0x106e3a,0xc(%esp)
  104a42:	00 
  104a43:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  104a4a:	00 
  104a4b:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
  104a52:	00 
  104a53:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  104a5a:	e8 8a b9 ff ff       	call   1003e9 <__panic>

    list_entry_t free_list_store = free_list;
  104a5f:	a1 1c af 11 00       	mov    0x11af1c,%eax
  104a64:	8b 15 20 af 11 00    	mov    0x11af20,%edx
  104a6a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104a6d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  104a70:	c7 45 e0 1c af 11 00 	movl   $0x11af1c,-0x20(%ebp)
    elm->prev = elm->next = elm;
  104a77:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104a7a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104a7d:	89 50 04             	mov    %edx,0x4(%eax)
  104a80:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104a83:	8b 50 04             	mov    0x4(%eax),%edx
  104a86:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104a89:	89 10                	mov    %edx,(%eax)
  104a8b:	c7 45 dc 1c af 11 00 	movl   $0x11af1c,-0x24(%ebp)
    return list->next == list;
  104a92:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104a95:	8b 40 04             	mov    0x4(%eax),%eax
  104a98:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  104a9b:	0f 94 c0             	sete   %al
  104a9e:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  104aa1:	85 c0                	test   %eax,%eax
  104aa3:	75 24                	jne    104ac9 <basic_check+0x26f>
  104aa5:	c7 44 24 0c 57 6e 10 	movl   $0x106e57,0xc(%esp)
  104aac:	00 
  104aad:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  104ab4:	00 
  104ab5:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
  104abc:	00 
  104abd:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  104ac4:	e8 20 b9 ff ff       	call   1003e9 <__panic>

    unsigned int nr_free_store = nr_free;
  104ac9:	a1 24 af 11 00       	mov    0x11af24,%eax
  104ace:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
  104ad1:	c7 05 24 af 11 00 00 	movl   $0x0,0x11af24
  104ad8:	00 00 00 

    assert(alloc_page() == NULL);
  104adb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104ae2:	e8 22 e1 ff ff       	call   102c09 <alloc_pages>
  104ae7:	85 c0                	test   %eax,%eax
  104ae9:	74 24                	je     104b0f <basic_check+0x2b5>
  104aeb:	c7 44 24 0c 6e 6e 10 	movl   $0x106e6e,0xc(%esp)
  104af2:	00 
  104af3:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  104afa:	00 
  104afb:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
  104b02:	00 
  104b03:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  104b0a:	e8 da b8 ff ff       	call   1003e9 <__panic>

    free_page(p0);
  104b0f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104b16:	00 
  104b17:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104b1a:	89 04 24             	mov    %eax,(%esp)
  104b1d:	e8 1f e1 ff ff       	call   102c41 <free_pages>
    free_page(p1);
  104b22:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104b29:	00 
  104b2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104b2d:	89 04 24             	mov    %eax,(%esp)
  104b30:	e8 0c e1 ff ff       	call   102c41 <free_pages>
    free_page(p2);
  104b35:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104b3c:	00 
  104b3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104b40:	89 04 24             	mov    %eax,(%esp)
  104b43:	e8 f9 e0 ff ff       	call   102c41 <free_pages>
    assert(nr_free == 3);
  104b48:	a1 24 af 11 00       	mov    0x11af24,%eax
  104b4d:	83 f8 03             	cmp    $0x3,%eax
  104b50:	74 24                	je     104b76 <basic_check+0x31c>
  104b52:	c7 44 24 0c 83 6e 10 	movl   $0x106e83,0xc(%esp)
  104b59:	00 
  104b5a:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  104b61:	00 
  104b62:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
  104b69:	00 
  104b6a:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  104b71:	e8 73 b8 ff ff       	call   1003e9 <__panic>

    assert((p0 = alloc_page()) != NULL);
  104b76:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104b7d:	e8 87 e0 ff ff       	call   102c09 <alloc_pages>
  104b82:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104b85:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  104b89:	75 24                	jne    104baf <basic_check+0x355>
  104b8b:	c7 44 24 0c 4c 6d 10 	movl   $0x106d4c,0xc(%esp)
  104b92:	00 
  104b93:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  104b9a:	00 
  104b9b:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
  104ba2:	00 
  104ba3:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  104baa:	e8 3a b8 ff ff       	call   1003e9 <__panic>
    assert((p1 = alloc_page()) != NULL);
  104baf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104bb6:	e8 4e e0 ff ff       	call   102c09 <alloc_pages>
  104bbb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104bbe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104bc2:	75 24                	jne    104be8 <basic_check+0x38e>
  104bc4:	c7 44 24 0c 68 6d 10 	movl   $0x106d68,0xc(%esp)
  104bcb:	00 
  104bcc:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  104bd3:	00 
  104bd4:	c7 44 24 04 f5 00 00 	movl   $0xf5,0x4(%esp)
  104bdb:	00 
  104bdc:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  104be3:	e8 01 b8 ff ff       	call   1003e9 <__panic>
    assert((p2 = alloc_page()) != NULL);
  104be8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104bef:	e8 15 e0 ff ff       	call   102c09 <alloc_pages>
  104bf4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104bf7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104bfb:	75 24                	jne    104c21 <basic_check+0x3c7>
  104bfd:	c7 44 24 0c 84 6d 10 	movl   $0x106d84,0xc(%esp)
  104c04:	00 
  104c05:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  104c0c:	00 
  104c0d:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
  104c14:	00 
  104c15:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  104c1c:	e8 c8 b7 ff ff       	call   1003e9 <__panic>

    assert(alloc_page() == NULL);
  104c21:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104c28:	e8 dc df ff ff       	call   102c09 <alloc_pages>
  104c2d:	85 c0                	test   %eax,%eax
  104c2f:	74 24                	je     104c55 <basic_check+0x3fb>
  104c31:	c7 44 24 0c 6e 6e 10 	movl   $0x106e6e,0xc(%esp)
  104c38:	00 
  104c39:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  104c40:	00 
  104c41:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
  104c48:	00 
  104c49:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  104c50:	e8 94 b7 ff ff       	call   1003e9 <__panic>

    free_page(p0);
  104c55:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104c5c:	00 
  104c5d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104c60:	89 04 24             	mov    %eax,(%esp)
  104c63:	e8 d9 df ff ff       	call   102c41 <free_pages>
  104c68:	c7 45 d8 1c af 11 00 	movl   $0x11af1c,-0x28(%ebp)
  104c6f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104c72:	8b 40 04             	mov    0x4(%eax),%eax
  104c75:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  104c78:	0f 94 c0             	sete   %al
  104c7b:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
  104c7e:	85 c0                	test   %eax,%eax
  104c80:	74 24                	je     104ca6 <basic_check+0x44c>
  104c82:	c7 44 24 0c 90 6e 10 	movl   $0x106e90,0xc(%esp)
  104c89:	00 
  104c8a:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  104c91:	00 
  104c92:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
  104c99:	00 
  104c9a:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  104ca1:	e8 43 b7 ff ff       	call   1003e9 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
  104ca6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104cad:	e8 57 df ff ff       	call   102c09 <alloc_pages>
  104cb2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104cb5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104cb8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  104cbb:	74 24                	je     104ce1 <basic_check+0x487>
  104cbd:	c7 44 24 0c a8 6e 10 	movl   $0x106ea8,0xc(%esp)
  104cc4:	00 
  104cc5:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  104ccc:	00 
  104ccd:	c7 44 24 04 fe 00 00 	movl   $0xfe,0x4(%esp)
  104cd4:	00 
  104cd5:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  104cdc:	e8 08 b7 ff ff       	call   1003e9 <__panic>
    assert(alloc_page() == NULL);
  104ce1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104ce8:	e8 1c df ff ff       	call   102c09 <alloc_pages>
  104ced:	85 c0                	test   %eax,%eax
  104cef:	74 24                	je     104d15 <basic_check+0x4bb>
  104cf1:	c7 44 24 0c 6e 6e 10 	movl   $0x106e6e,0xc(%esp)
  104cf8:	00 
  104cf9:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  104d00:	00 
  104d01:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  104d08:	00 
  104d09:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  104d10:	e8 d4 b6 ff ff       	call   1003e9 <__panic>

    assert(nr_free == 0);
  104d15:	a1 24 af 11 00       	mov    0x11af24,%eax
  104d1a:	85 c0                	test   %eax,%eax
  104d1c:	74 24                	je     104d42 <basic_check+0x4e8>
  104d1e:	c7 44 24 0c c1 6e 10 	movl   $0x106ec1,0xc(%esp)
  104d25:	00 
  104d26:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  104d2d:	00 
  104d2e:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
  104d35:	00 
  104d36:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  104d3d:	e8 a7 b6 ff ff       	call   1003e9 <__panic>
    free_list = free_list_store;
  104d42:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104d45:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104d48:	a3 1c af 11 00       	mov    %eax,0x11af1c
  104d4d:	89 15 20 af 11 00    	mov    %edx,0x11af20
    nr_free = nr_free_store;
  104d53:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104d56:	a3 24 af 11 00       	mov    %eax,0x11af24

    free_page(p);
  104d5b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104d62:	00 
  104d63:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104d66:	89 04 24             	mov    %eax,(%esp)
  104d69:	e8 d3 de ff ff       	call   102c41 <free_pages>
    free_page(p1);
  104d6e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104d75:	00 
  104d76:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104d79:	89 04 24             	mov    %eax,(%esp)
  104d7c:	e8 c0 de ff ff       	call   102c41 <free_pages>
    free_page(p2);
  104d81:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104d88:	00 
  104d89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104d8c:	89 04 24             	mov    %eax,(%esp)
  104d8f:	e8 ad de ff ff       	call   102c41 <free_pages>
}
  104d94:	c9                   	leave  
  104d95:	c3                   	ret    

00104d96 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
  104d96:	55                   	push   %ebp
  104d97:	89 e5                	mov    %esp,%ebp
  104d99:	53                   	push   %ebx
  104d9a:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
  104da0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104da7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
  104dae:	c7 45 ec 1c af 11 00 	movl   $0x11af1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  104db5:	eb 6b                	jmp    104e22 <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
  104db7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104dba:	83 e8 0c             	sub    $0xc,%eax
  104dbd:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
  104dc0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104dc3:	83 c0 04             	add    $0x4,%eax
  104dc6:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  104dcd:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104dd0:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104dd3:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104dd6:	0f a3 10             	bt     %edx,(%eax)
  104dd9:	19 c0                	sbb    %eax,%eax
  104ddb:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
  104dde:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  104de2:	0f 95 c0             	setne  %al
  104de5:	0f b6 c0             	movzbl %al,%eax
  104de8:	85 c0                	test   %eax,%eax
  104dea:	75 24                	jne    104e10 <default_check+0x7a>
  104dec:	c7 44 24 0c ce 6e 10 	movl   $0x106ece,0xc(%esp)
  104df3:	00 
  104df4:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  104dfb:	00 
  104dfc:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
  104e03:	00 
  104e04:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  104e0b:	e8 d9 b5 ff ff       	call   1003e9 <__panic>
        count ++, total += p->property;
  104e10:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  104e14:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104e17:	8b 50 08             	mov    0x8(%eax),%edx
  104e1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104e1d:	01 d0                	add    %edx,%eax
  104e1f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104e22:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104e25:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
  104e28:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104e2b:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  104e2e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104e31:	81 7d ec 1c af 11 00 	cmpl   $0x11af1c,-0x14(%ebp)
  104e38:	0f 85 79 ff ff ff    	jne    104db7 <default_check+0x21>
    }
    assert(total == nr_free_pages());
  104e3e:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  104e41:	e8 2d de ff ff       	call   102c73 <nr_free_pages>
  104e46:	39 c3                	cmp    %eax,%ebx
  104e48:	74 24                	je     104e6e <default_check+0xd8>
  104e4a:	c7 44 24 0c de 6e 10 	movl   $0x106ede,0xc(%esp)
  104e51:	00 
  104e52:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  104e59:	00 
  104e5a:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
  104e61:	00 
  104e62:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  104e69:	e8 7b b5 ff ff       	call   1003e9 <__panic>

    basic_check();
  104e6e:	e8 e7 f9 ff ff       	call   10485a <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
  104e73:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  104e7a:	e8 8a dd ff ff       	call   102c09 <alloc_pages>
  104e7f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
  104e82:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  104e86:	75 24                	jne    104eac <default_check+0x116>
  104e88:	c7 44 24 0c f7 6e 10 	movl   $0x106ef7,0xc(%esp)
  104e8f:	00 
  104e90:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  104e97:	00 
  104e98:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
  104e9f:	00 
  104ea0:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  104ea7:	e8 3d b5 ff ff       	call   1003e9 <__panic>
    assert(!PageProperty(p0));
  104eac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104eaf:	83 c0 04             	add    $0x4,%eax
  104eb2:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  104eb9:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104ebc:	8b 45 bc             	mov    -0x44(%ebp),%eax
  104ebf:	8b 55 c0             	mov    -0x40(%ebp),%edx
  104ec2:	0f a3 10             	bt     %edx,(%eax)
  104ec5:	19 c0                	sbb    %eax,%eax
  104ec7:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
  104eca:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  104ece:	0f 95 c0             	setne  %al
  104ed1:	0f b6 c0             	movzbl %al,%eax
  104ed4:	85 c0                	test   %eax,%eax
  104ed6:	74 24                	je     104efc <default_check+0x166>
  104ed8:	c7 44 24 0c 02 6f 10 	movl   $0x106f02,0xc(%esp)
  104edf:	00 
  104ee0:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  104ee7:	00 
  104ee8:	c7 44 24 04 1b 01 00 	movl   $0x11b,0x4(%esp)
  104eef:	00 
  104ef0:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  104ef7:	e8 ed b4 ff ff       	call   1003e9 <__panic>

    list_entry_t free_list_store = free_list;
  104efc:	a1 1c af 11 00       	mov    0x11af1c,%eax
  104f01:	8b 15 20 af 11 00    	mov    0x11af20,%edx
  104f07:	89 45 80             	mov    %eax,-0x80(%ebp)
  104f0a:	89 55 84             	mov    %edx,-0x7c(%ebp)
  104f0d:	c7 45 b4 1c af 11 00 	movl   $0x11af1c,-0x4c(%ebp)
    elm->prev = elm->next = elm;
  104f14:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104f17:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  104f1a:	89 50 04             	mov    %edx,0x4(%eax)
  104f1d:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104f20:	8b 50 04             	mov    0x4(%eax),%edx
  104f23:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104f26:	89 10                	mov    %edx,(%eax)
  104f28:	c7 45 b0 1c af 11 00 	movl   $0x11af1c,-0x50(%ebp)
    return list->next == list;
  104f2f:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104f32:	8b 40 04             	mov    0x4(%eax),%eax
  104f35:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  104f38:	0f 94 c0             	sete   %al
  104f3b:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  104f3e:	85 c0                	test   %eax,%eax
  104f40:	75 24                	jne    104f66 <default_check+0x1d0>
  104f42:	c7 44 24 0c 57 6e 10 	movl   $0x106e57,0xc(%esp)
  104f49:	00 
  104f4a:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  104f51:	00 
  104f52:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
  104f59:	00 
  104f5a:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  104f61:	e8 83 b4 ff ff       	call   1003e9 <__panic>
    assert(alloc_page() == NULL);
  104f66:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104f6d:	e8 97 dc ff ff       	call   102c09 <alloc_pages>
  104f72:	85 c0                	test   %eax,%eax
  104f74:	74 24                	je     104f9a <default_check+0x204>
  104f76:	c7 44 24 0c 6e 6e 10 	movl   $0x106e6e,0xc(%esp)
  104f7d:	00 
  104f7e:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  104f85:	00 
  104f86:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
  104f8d:	00 
  104f8e:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  104f95:	e8 4f b4 ff ff       	call   1003e9 <__panic>

    unsigned int nr_free_store = nr_free;
  104f9a:	a1 24 af 11 00       	mov    0x11af24,%eax
  104f9f:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
  104fa2:	c7 05 24 af 11 00 00 	movl   $0x0,0x11af24
  104fa9:	00 00 00 

    free_pages(p0 + 2, 3);
  104fac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104faf:	83 c0 28             	add    $0x28,%eax
  104fb2:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  104fb9:	00 
  104fba:	89 04 24             	mov    %eax,(%esp)
  104fbd:	e8 7f dc ff ff       	call   102c41 <free_pages>
    assert(alloc_pages(4) == NULL);
  104fc2:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  104fc9:	e8 3b dc ff ff       	call   102c09 <alloc_pages>
  104fce:	85 c0                	test   %eax,%eax
  104fd0:	74 24                	je     104ff6 <default_check+0x260>
  104fd2:	c7 44 24 0c 14 6f 10 	movl   $0x106f14,0xc(%esp)
  104fd9:	00 
  104fda:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  104fe1:	00 
  104fe2:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
  104fe9:	00 
  104fea:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  104ff1:	e8 f3 b3 ff ff       	call   1003e9 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
  104ff6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104ff9:	83 c0 28             	add    $0x28,%eax
  104ffc:	83 c0 04             	add    $0x4,%eax
  104fff:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
  105006:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105009:	8b 45 a8             	mov    -0x58(%ebp),%eax
  10500c:	8b 55 ac             	mov    -0x54(%ebp),%edx
  10500f:	0f a3 10             	bt     %edx,(%eax)
  105012:	19 c0                	sbb    %eax,%eax
  105014:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
  105017:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  10501b:	0f 95 c0             	setne  %al
  10501e:	0f b6 c0             	movzbl %al,%eax
  105021:	85 c0                	test   %eax,%eax
  105023:	74 0e                	je     105033 <default_check+0x29d>
  105025:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105028:	83 c0 28             	add    $0x28,%eax
  10502b:	8b 40 08             	mov    0x8(%eax),%eax
  10502e:	83 f8 03             	cmp    $0x3,%eax
  105031:	74 24                	je     105057 <default_check+0x2c1>
  105033:	c7 44 24 0c 2c 6f 10 	movl   $0x106f2c,0xc(%esp)
  10503a:	00 
  10503b:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  105042:	00 
  105043:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
  10504a:	00 
  10504b:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  105052:	e8 92 b3 ff ff       	call   1003e9 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
  105057:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  10505e:	e8 a6 db ff ff       	call   102c09 <alloc_pages>
  105063:	89 45 dc             	mov    %eax,-0x24(%ebp)
  105066:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  10506a:	75 24                	jne    105090 <default_check+0x2fa>
  10506c:	c7 44 24 0c 58 6f 10 	movl   $0x106f58,0xc(%esp)
  105073:	00 
  105074:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  10507b:	00 
  10507c:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
  105083:	00 
  105084:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  10508b:	e8 59 b3 ff ff       	call   1003e9 <__panic>
    assert(alloc_page() == NULL);
  105090:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105097:	e8 6d db ff ff       	call   102c09 <alloc_pages>
  10509c:	85 c0                	test   %eax,%eax
  10509e:	74 24                	je     1050c4 <default_check+0x32e>
  1050a0:	c7 44 24 0c 6e 6e 10 	movl   $0x106e6e,0xc(%esp)
  1050a7:	00 
  1050a8:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  1050af:	00 
  1050b0:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
  1050b7:	00 
  1050b8:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  1050bf:	e8 25 b3 ff ff       	call   1003e9 <__panic>
    assert(p0 + 2 == p1);
  1050c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1050c7:	83 c0 28             	add    $0x28,%eax
  1050ca:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  1050cd:	74 24                	je     1050f3 <default_check+0x35d>
  1050cf:	c7 44 24 0c 76 6f 10 	movl   $0x106f76,0xc(%esp)
  1050d6:	00 
  1050d7:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  1050de:	00 
  1050df:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
  1050e6:	00 
  1050e7:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  1050ee:	e8 f6 b2 ff ff       	call   1003e9 <__panic>

    p2 = p0 + 1;
  1050f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1050f6:	83 c0 14             	add    $0x14,%eax
  1050f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
  1050fc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105103:	00 
  105104:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105107:	89 04 24             	mov    %eax,(%esp)
  10510a:	e8 32 db ff ff       	call   102c41 <free_pages>
    free_pages(p1, 3);
  10510f:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  105116:	00 
  105117:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10511a:	89 04 24             	mov    %eax,(%esp)
  10511d:	e8 1f db ff ff       	call   102c41 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
  105122:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105125:	83 c0 04             	add    $0x4,%eax
  105128:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
  10512f:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105132:	8b 45 9c             	mov    -0x64(%ebp),%eax
  105135:	8b 55 a0             	mov    -0x60(%ebp),%edx
  105138:	0f a3 10             	bt     %edx,(%eax)
  10513b:	19 c0                	sbb    %eax,%eax
  10513d:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
  105140:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
  105144:	0f 95 c0             	setne  %al
  105147:	0f b6 c0             	movzbl %al,%eax
  10514a:	85 c0                	test   %eax,%eax
  10514c:	74 0b                	je     105159 <default_check+0x3c3>
  10514e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105151:	8b 40 08             	mov    0x8(%eax),%eax
  105154:	83 f8 01             	cmp    $0x1,%eax
  105157:	74 24                	je     10517d <default_check+0x3e7>
  105159:	c7 44 24 0c 84 6f 10 	movl   $0x106f84,0xc(%esp)
  105160:	00 
  105161:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  105168:	00 
  105169:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
  105170:	00 
  105171:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  105178:	e8 6c b2 ff ff       	call   1003e9 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
  10517d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105180:	83 c0 04             	add    $0x4,%eax
  105183:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
  10518a:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10518d:	8b 45 90             	mov    -0x70(%ebp),%eax
  105190:	8b 55 94             	mov    -0x6c(%ebp),%edx
  105193:	0f a3 10             	bt     %edx,(%eax)
  105196:	19 c0                	sbb    %eax,%eax
  105198:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
  10519b:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
  10519f:	0f 95 c0             	setne  %al
  1051a2:	0f b6 c0             	movzbl %al,%eax
  1051a5:	85 c0                	test   %eax,%eax
  1051a7:	74 0b                	je     1051b4 <default_check+0x41e>
  1051a9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1051ac:	8b 40 08             	mov    0x8(%eax),%eax
  1051af:	83 f8 03             	cmp    $0x3,%eax
  1051b2:	74 24                	je     1051d8 <default_check+0x442>
  1051b4:	c7 44 24 0c ac 6f 10 	movl   $0x106fac,0xc(%esp)
  1051bb:	00 
  1051bc:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  1051c3:	00 
  1051c4:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
  1051cb:	00 
  1051cc:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  1051d3:	e8 11 b2 ff ff       	call   1003e9 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
  1051d8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1051df:	e8 25 da ff ff       	call   102c09 <alloc_pages>
  1051e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1051e7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1051ea:	83 e8 14             	sub    $0x14,%eax
  1051ed:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  1051f0:	74 24                	je     105216 <default_check+0x480>
  1051f2:	c7 44 24 0c d2 6f 10 	movl   $0x106fd2,0xc(%esp)
  1051f9:	00 
  1051fa:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  105201:	00 
  105202:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
  105209:	00 
  10520a:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  105211:	e8 d3 b1 ff ff       	call   1003e9 <__panic>
    free_page(p0);
  105216:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10521d:	00 
  10521e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105221:	89 04 24             	mov    %eax,(%esp)
  105224:	e8 18 da ff ff       	call   102c41 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
  105229:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  105230:	e8 d4 d9 ff ff       	call   102c09 <alloc_pages>
  105235:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105238:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10523b:	83 c0 14             	add    $0x14,%eax
  10523e:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  105241:	74 24                	je     105267 <default_check+0x4d1>
  105243:	c7 44 24 0c f0 6f 10 	movl   $0x106ff0,0xc(%esp)
  10524a:	00 
  10524b:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  105252:	00 
  105253:	c7 44 24 04 34 01 00 	movl   $0x134,0x4(%esp)
  10525a:	00 
  10525b:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  105262:	e8 82 b1 ff ff       	call   1003e9 <__panic>

    free_pages(p0, 2);
  105267:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  10526e:	00 
  10526f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105272:	89 04 24             	mov    %eax,(%esp)
  105275:	e8 c7 d9 ff ff       	call   102c41 <free_pages>
    free_page(p2);
  10527a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105281:	00 
  105282:	8b 45 d8             	mov    -0x28(%ebp),%eax
  105285:	89 04 24             	mov    %eax,(%esp)
  105288:	e8 b4 d9 ff ff       	call   102c41 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
  10528d:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  105294:	e8 70 d9 ff ff       	call   102c09 <alloc_pages>
  105299:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10529c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1052a0:	75 24                	jne    1052c6 <default_check+0x530>
  1052a2:	c7 44 24 0c 10 70 10 	movl   $0x107010,0xc(%esp)
  1052a9:	00 
  1052aa:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  1052b1:	00 
  1052b2:	c7 44 24 04 39 01 00 	movl   $0x139,0x4(%esp)
  1052b9:	00 
  1052ba:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  1052c1:	e8 23 b1 ff ff       	call   1003e9 <__panic>
    assert(alloc_page() == NULL);
  1052c6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1052cd:	e8 37 d9 ff ff       	call   102c09 <alloc_pages>
  1052d2:	85 c0                	test   %eax,%eax
  1052d4:	74 24                	je     1052fa <default_check+0x564>
  1052d6:	c7 44 24 0c 6e 6e 10 	movl   $0x106e6e,0xc(%esp)
  1052dd:	00 
  1052de:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  1052e5:	00 
  1052e6:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
  1052ed:	00 
  1052ee:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  1052f5:	e8 ef b0 ff ff       	call   1003e9 <__panic>

    assert(nr_free == 0);
  1052fa:	a1 24 af 11 00       	mov    0x11af24,%eax
  1052ff:	85 c0                	test   %eax,%eax
  105301:	74 24                	je     105327 <default_check+0x591>
  105303:	c7 44 24 0c c1 6e 10 	movl   $0x106ec1,0xc(%esp)
  10530a:	00 
  10530b:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  105312:	00 
  105313:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
  10531a:	00 
  10531b:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  105322:	e8 c2 b0 ff ff       	call   1003e9 <__panic>
    nr_free = nr_free_store;
  105327:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10532a:	a3 24 af 11 00       	mov    %eax,0x11af24

    free_list = free_list_store;
  10532f:	8b 45 80             	mov    -0x80(%ebp),%eax
  105332:	8b 55 84             	mov    -0x7c(%ebp),%edx
  105335:	a3 1c af 11 00       	mov    %eax,0x11af1c
  10533a:	89 15 20 af 11 00    	mov    %edx,0x11af20
    free_pages(p0, 5);
  105340:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  105347:	00 
  105348:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10534b:	89 04 24             	mov    %eax,(%esp)
  10534e:	e8 ee d8 ff ff       	call   102c41 <free_pages>

    le = &free_list;
  105353:	c7 45 ec 1c af 11 00 	movl   $0x11af1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  10535a:	eb 1d                	jmp    105379 <default_check+0x5e3>
        struct Page *p = le2page(le, page_link);
  10535c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10535f:	83 e8 0c             	sub    $0xc,%eax
  105362:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
  105365:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  105369:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10536c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10536f:	8b 40 08             	mov    0x8(%eax),%eax
  105372:	29 c2                	sub    %eax,%edx
  105374:	89 d0                	mov    %edx,%eax
  105376:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105379:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10537c:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
  10537f:	8b 45 88             	mov    -0x78(%ebp),%eax
  105382:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  105385:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105388:	81 7d ec 1c af 11 00 	cmpl   $0x11af1c,-0x14(%ebp)
  10538f:	75 cb                	jne    10535c <default_check+0x5c6>
    }
    assert(count == 0);
  105391:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  105395:	74 24                	je     1053bb <default_check+0x625>
  105397:	c7 44 24 0c 2e 70 10 	movl   $0x10702e,0xc(%esp)
  10539e:	00 
  10539f:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  1053a6:	00 
  1053a7:	c7 44 24 04 47 01 00 	movl   $0x147,0x4(%esp)
  1053ae:	00 
  1053af:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  1053b6:	e8 2e b0 ff ff       	call   1003e9 <__panic>
    assert(total == 0);
  1053bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1053bf:	74 24                	je     1053e5 <default_check+0x64f>
  1053c1:	c7 44 24 0c 39 70 10 	movl   $0x107039,0xc(%esp)
  1053c8:	00 
  1053c9:	c7 44 24 08 fe 6c 10 	movl   $0x106cfe,0x8(%esp)
  1053d0:	00 
  1053d1:	c7 44 24 04 48 01 00 	movl   $0x148,0x4(%esp)
  1053d8:	00 
  1053d9:	c7 04 24 13 6d 10 00 	movl   $0x106d13,(%esp)
  1053e0:	e8 04 b0 ff ff       	call   1003e9 <__panic>
}
  1053e5:	81 c4 94 00 00 00    	add    $0x94,%esp
  1053eb:	5b                   	pop    %ebx
  1053ec:	5d                   	pop    %ebp
  1053ed:	c3                   	ret    

001053ee <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  1053ee:	55                   	push   %ebp
  1053ef:	89 e5                	mov    %esp,%ebp
  1053f1:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  1053f4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  1053fb:	eb 04                	jmp    105401 <strlen+0x13>
        cnt ++;
  1053fd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (*s ++ != '\0') {
  105401:	8b 45 08             	mov    0x8(%ebp),%eax
  105404:	8d 50 01             	lea    0x1(%eax),%edx
  105407:	89 55 08             	mov    %edx,0x8(%ebp)
  10540a:	0f b6 00             	movzbl (%eax),%eax
  10540d:	84 c0                	test   %al,%al
  10540f:	75 ec                	jne    1053fd <strlen+0xf>
    }
    return cnt;
  105411:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  105414:	c9                   	leave  
  105415:	c3                   	ret    

00105416 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  105416:	55                   	push   %ebp
  105417:	89 e5                	mov    %esp,%ebp
  105419:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  10541c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  105423:	eb 04                	jmp    105429 <strnlen+0x13>
        cnt ++;
  105425:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  105429:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10542c:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10542f:	73 10                	jae    105441 <strnlen+0x2b>
  105431:	8b 45 08             	mov    0x8(%ebp),%eax
  105434:	8d 50 01             	lea    0x1(%eax),%edx
  105437:	89 55 08             	mov    %edx,0x8(%ebp)
  10543a:	0f b6 00             	movzbl (%eax),%eax
  10543d:	84 c0                	test   %al,%al
  10543f:	75 e4                	jne    105425 <strnlen+0xf>
    }
    return cnt;
  105441:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  105444:	c9                   	leave  
  105445:	c3                   	ret    

00105446 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  105446:	55                   	push   %ebp
  105447:	89 e5                	mov    %esp,%ebp
  105449:	57                   	push   %edi
  10544a:	56                   	push   %esi
  10544b:	83 ec 20             	sub    $0x20,%esp
  10544e:	8b 45 08             	mov    0x8(%ebp),%eax
  105451:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105454:	8b 45 0c             	mov    0xc(%ebp),%eax
  105457:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  10545a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10545d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105460:	89 d1                	mov    %edx,%ecx
  105462:	89 c2                	mov    %eax,%edx
  105464:	89 ce                	mov    %ecx,%esi
  105466:	89 d7                	mov    %edx,%edi
  105468:	ac                   	lods   %ds:(%esi),%al
  105469:	aa                   	stos   %al,%es:(%edi)
  10546a:	84 c0                	test   %al,%al
  10546c:	75 fa                	jne    105468 <strcpy+0x22>
  10546e:	89 fa                	mov    %edi,%edx
  105470:	89 f1                	mov    %esi,%ecx
  105472:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  105475:	89 55 e8             	mov    %edx,-0x18(%ebp)
  105478:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  10547b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  10547e:	83 c4 20             	add    $0x20,%esp
  105481:	5e                   	pop    %esi
  105482:	5f                   	pop    %edi
  105483:	5d                   	pop    %ebp
  105484:	c3                   	ret    

00105485 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  105485:	55                   	push   %ebp
  105486:	89 e5                	mov    %esp,%ebp
  105488:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  10548b:	8b 45 08             	mov    0x8(%ebp),%eax
  10548e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  105491:	eb 21                	jmp    1054b4 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
  105493:	8b 45 0c             	mov    0xc(%ebp),%eax
  105496:	0f b6 10             	movzbl (%eax),%edx
  105499:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10549c:	88 10                	mov    %dl,(%eax)
  10549e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1054a1:	0f b6 00             	movzbl (%eax),%eax
  1054a4:	84 c0                	test   %al,%al
  1054a6:	74 04                	je     1054ac <strncpy+0x27>
            src ++;
  1054a8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
  1054ac:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  1054b0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    while (len > 0) {
  1054b4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1054b8:	75 d9                	jne    105493 <strncpy+0xe>
    }
    return dst;
  1054ba:	8b 45 08             	mov    0x8(%ebp),%eax
}
  1054bd:	c9                   	leave  
  1054be:	c3                   	ret    

001054bf <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  1054bf:	55                   	push   %ebp
  1054c0:	89 e5                	mov    %esp,%ebp
  1054c2:	57                   	push   %edi
  1054c3:	56                   	push   %esi
  1054c4:	83 ec 20             	sub    $0x20,%esp
  1054c7:	8b 45 08             	mov    0x8(%ebp),%eax
  1054ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1054cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  1054d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  1054d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1054d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1054d9:	89 d1                	mov    %edx,%ecx
  1054db:	89 c2                	mov    %eax,%edx
  1054dd:	89 ce                	mov    %ecx,%esi
  1054df:	89 d7                	mov    %edx,%edi
  1054e1:	ac                   	lods   %ds:(%esi),%al
  1054e2:	ae                   	scas   %es:(%edi),%al
  1054e3:	75 08                	jne    1054ed <strcmp+0x2e>
  1054e5:	84 c0                	test   %al,%al
  1054e7:	75 f8                	jne    1054e1 <strcmp+0x22>
  1054e9:	31 c0                	xor    %eax,%eax
  1054eb:	eb 04                	jmp    1054f1 <strcmp+0x32>
  1054ed:	19 c0                	sbb    %eax,%eax
  1054ef:	0c 01                	or     $0x1,%al
  1054f1:	89 fa                	mov    %edi,%edx
  1054f3:	89 f1                	mov    %esi,%ecx
  1054f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1054f8:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  1054fb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  1054fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  105501:	83 c4 20             	add    $0x20,%esp
  105504:	5e                   	pop    %esi
  105505:	5f                   	pop    %edi
  105506:	5d                   	pop    %ebp
  105507:	c3                   	ret    

00105508 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  105508:	55                   	push   %ebp
  105509:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  10550b:	eb 0c                	jmp    105519 <strncmp+0x11>
        n --, s1 ++, s2 ++;
  10550d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  105511:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105515:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  105519:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10551d:	74 1a                	je     105539 <strncmp+0x31>
  10551f:	8b 45 08             	mov    0x8(%ebp),%eax
  105522:	0f b6 00             	movzbl (%eax),%eax
  105525:	84 c0                	test   %al,%al
  105527:	74 10                	je     105539 <strncmp+0x31>
  105529:	8b 45 08             	mov    0x8(%ebp),%eax
  10552c:	0f b6 10             	movzbl (%eax),%edx
  10552f:	8b 45 0c             	mov    0xc(%ebp),%eax
  105532:	0f b6 00             	movzbl (%eax),%eax
  105535:	38 c2                	cmp    %al,%dl
  105537:	74 d4                	je     10550d <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  105539:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10553d:	74 18                	je     105557 <strncmp+0x4f>
  10553f:	8b 45 08             	mov    0x8(%ebp),%eax
  105542:	0f b6 00             	movzbl (%eax),%eax
  105545:	0f b6 d0             	movzbl %al,%edx
  105548:	8b 45 0c             	mov    0xc(%ebp),%eax
  10554b:	0f b6 00             	movzbl (%eax),%eax
  10554e:	0f b6 c0             	movzbl %al,%eax
  105551:	29 c2                	sub    %eax,%edx
  105553:	89 d0                	mov    %edx,%eax
  105555:	eb 05                	jmp    10555c <strncmp+0x54>
  105557:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10555c:	5d                   	pop    %ebp
  10555d:	c3                   	ret    

0010555e <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  10555e:	55                   	push   %ebp
  10555f:	89 e5                	mov    %esp,%ebp
  105561:	83 ec 04             	sub    $0x4,%esp
  105564:	8b 45 0c             	mov    0xc(%ebp),%eax
  105567:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  10556a:	eb 14                	jmp    105580 <strchr+0x22>
        if (*s == c) {
  10556c:	8b 45 08             	mov    0x8(%ebp),%eax
  10556f:	0f b6 00             	movzbl (%eax),%eax
  105572:	3a 45 fc             	cmp    -0x4(%ebp),%al
  105575:	75 05                	jne    10557c <strchr+0x1e>
            return (char *)s;
  105577:	8b 45 08             	mov    0x8(%ebp),%eax
  10557a:	eb 13                	jmp    10558f <strchr+0x31>
        }
        s ++;
  10557c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
  105580:	8b 45 08             	mov    0x8(%ebp),%eax
  105583:	0f b6 00             	movzbl (%eax),%eax
  105586:	84 c0                	test   %al,%al
  105588:	75 e2                	jne    10556c <strchr+0xe>
    }
    return NULL;
  10558a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10558f:	c9                   	leave  
  105590:	c3                   	ret    

00105591 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  105591:	55                   	push   %ebp
  105592:	89 e5                	mov    %esp,%ebp
  105594:	83 ec 04             	sub    $0x4,%esp
  105597:	8b 45 0c             	mov    0xc(%ebp),%eax
  10559a:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  10559d:	eb 11                	jmp    1055b0 <strfind+0x1f>
        if (*s == c) {
  10559f:	8b 45 08             	mov    0x8(%ebp),%eax
  1055a2:	0f b6 00             	movzbl (%eax),%eax
  1055a5:	3a 45 fc             	cmp    -0x4(%ebp),%al
  1055a8:	75 02                	jne    1055ac <strfind+0x1b>
            break;
  1055aa:	eb 0e                	jmp    1055ba <strfind+0x29>
        }
        s ++;
  1055ac:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
  1055b0:	8b 45 08             	mov    0x8(%ebp),%eax
  1055b3:	0f b6 00             	movzbl (%eax),%eax
  1055b6:	84 c0                	test   %al,%al
  1055b8:	75 e5                	jne    10559f <strfind+0xe>
    }
    return (char *)s;
  1055ba:	8b 45 08             	mov    0x8(%ebp),%eax
}
  1055bd:	c9                   	leave  
  1055be:	c3                   	ret    

001055bf <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  1055bf:	55                   	push   %ebp
  1055c0:	89 e5                	mov    %esp,%ebp
  1055c2:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  1055c5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  1055cc:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  1055d3:	eb 04                	jmp    1055d9 <strtol+0x1a>
        s ++;
  1055d5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  1055d9:	8b 45 08             	mov    0x8(%ebp),%eax
  1055dc:	0f b6 00             	movzbl (%eax),%eax
  1055df:	3c 20                	cmp    $0x20,%al
  1055e1:	74 f2                	je     1055d5 <strtol+0x16>
  1055e3:	8b 45 08             	mov    0x8(%ebp),%eax
  1055e6:	0f b6 00             	movzbl (%eax),%eax
  1055e9:	3c 09                	cmp    $0x9,%al
  1055eb:	74 e8                	je     1055d5 <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
  1055ed:	8b 45 08             	mov    0x8(%ebp),%eax
  1055f0:	0f b6 00             	movzbl (%eax),%eax
  1055f3:	3c 2b                	cmp    $0x2b,%al
  1055f5:	75 06                	jne    1055fd <strtol+0x3e>
        s ++;
  1055f7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  1055fb:	eb 15                	jmp    105612 <strtol+0x53>
    }
    else if (*s == '-') {
  1055fd:	8b 45 08             	mov    0x8(%ebp),%eax
  105600:	0f b6 00             	movzbl (%eax),%eax
  105603:	3c 2d                	cmp    $0x2d,%al
  105605:	75 0b                	jne    105612 <strtol+0x53>
        s ++, neg = 1;
  105607:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  10560b:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  105612:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105616:	74 06                	je     10561e <strtol+0x5f>
  105618:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  10561c:	75 24                	jne    105642 <strtol+0x83>
  10561e:	8b 45 08             	mov    0x8(%ebp),%eax
  105621:	0f b6 00             	movzbl (%eax),%eax
  105624:	3c 30                	cmp    $0x30,%al
  105626:	75 1a                	jne    105642 <strtol+0x83>
  105628:	8b 45 08             	mov    0x8(%ebp),%eax
  10562b:	83 c0 01             	add    $0x1,%eax
  10562e:	0f b6 00             	movzbl (%eax),%eax
  105631:	3c 78                	cmp    $0x78,%al
  105633:	75 0d                	jne    105642 <strtol+0x83>
        s += 2, base = 16;
  105635:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  105639:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  105640:	eb 2a                	jmp    10566c <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
  105642:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105646:	75 17                	jne    10565f <strtol+0xa0>
  105648:	8b 45 08             	mov    0x8(%ebp),%eax
  10564b:	0f b6 00             	movzbl (%eax),%eax
  10564e:	3c 30                	cmp    $0x30,%al
  105650:	75 0d                	jne    10565f <strtol+0xa0>
        s ++, base = 8;
  105652:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105656:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  10565d:	eb 0d                	jmp    10566c <strtol+0xad>
    }
    else if (base == 0) {
  10565f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105663:	75 07                	jne    10566c <strtol+0xad>
        base = 10;
  105665:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  10566c:	8b 45 08             	mov    0x8(%ebp),%eax
  10566f:	0f b6 00             	movzbl (%eax),%eax
  105672:	3c 2f                	cmp    $0x2f,%al
  105674:	7e 1b                	jle    105691 <strtol+0xd2>
  105676:	8b 45 08             	mov    0x8(%ebp),%eax
  105679:	0f b6 00             	movzbl (%eax),%eax
  10567c:	3c 39                	cmp    $0x39,%al
  10567e:	7f 11                	jg     105691 <strtol+0xd2>
            dig = *s - '0';
  105680:	8b 45 08             	mov    0x8(%ebp),%eax
  105683:	0f b6 00             	movzbl (%eax),%eax
  105686:	0f be c0             	movsbl %al,%eax
  105689:	83 e8 30             	sub    $0x30,%eax
  10568c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10568f:	eb 48                	jmp    1056d9 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
  105691:	8b 45 08             	mov    0x8(%ebp),%eax
  105694:	0f b6 00             	movzbl (%eax),%eax
  105697:	3c 60                	cmp    $0x60,%al
  105699:	7e 1b                	jle    1056b6 <strtol+0xf7>
  10569b:	8b 45 08             	mov    0x8(%ebp),%eax
  10569e:	0f b6 00             	movzbl (%eax),%eax
  1056a1:	3c 7a                	cmp    $0x7a,%al
  1056a3:	7f 11                	jg     1056b6 <strtol+0xf7>
            dig = *s - 'a' + 10;
  1056a5:	8b 45 08             	mov    0x8(%ebp),%eax
  1056a8:	0f b6 00             	movzbl (%eax),%eax
  1056ab:	0f be c0             	movsbl %al,%eax
  1056ae:	83 e8 57             	sub    $0x57,%eax
  1056b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1056b4:	eb 23                	jmp    1056d9 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  1056b6:	8b 45 08             	mov    0x8(%ebp),%eax
  1056b9:	0f b6 00             	movzbl (%eax),%eax
  1056bc:	3c 40                	cmp    $0x40,%al
  1056be:	7e 3d                	jle    1056fd <strtol+0x13e>
  1056c0:	8b 45 08             	mov    0x8(%ebp),%eax
  1056c3:	0f b6 00             	movzbl (%eax),%eax
  1056c6:	3c 5a                	cmp    $0x5a,%al
  1056c8:	7f 33                	jg     1056fd <strtol+0x13e>
            dig = *s - 'A' + 10;
  1056ca:	8b 45 08             	mov    0x8(%ebp),%eax
  1056cd:	0f b6 00             	movzbl (%eax),%eax
  1056d0:	0f be c0             	movsbl %al,%eax
  1056d3:	83 e8 37             	sub    $0x37,%eax
  1056d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  1056d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1056dc:	3b 45 10             	cmp    0x10(%ebp),%eax
  1056df:	7c 02                	jl     1056e3 <strtol+0x124>
            break;
  1056e1:	eb 1a                	jmp    1056fd <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
  1056e3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  1056e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1056ea:	0f af 45 10          	imul   0x10(%ebp),%eax
  1056ee:	89 c2                	mov    %eax,%edx
  1056f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1056f3:	01 d0                	add    %edx,%eax
  1056f5:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
  1056f8:	e9 6f ff ff ff       	jmp    10566c <strtol+0xad>

    if (endptr) {
  1056fd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105701:	74 08                	je     10570b <strtol+0x14c>
        *endptr = (char *) s;
  105703:	8b 45 0c             	mov    0xc(%ebp),%eax
  105706:	8b 55 08             	mov    0x8(%ebp),%edx
  105709:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  10570b:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  10570f:	74 07                	je     105718 <strtol+0x159>
  105711:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105714:	f7 d8                	neg    %eax
  105716:	eb 03                	jmp    10571b <strtol+0x15c>
  105718:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  10571b:	c9                   	leave  
  10571c:	c3                   	ret    

0010571d <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  10571d:	55                   	push   %ebp
  10571e:	89 e5                	mov    %esp,%ebp
  105720:	57                   	push   %edi
  105721:	83 ec 24             	sub    $0x24,%esp
  105724:	8b 45 0c             	mov    0xc(%ebp),%eax
  105727:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  10572a:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  10572e:	8b 55 08             	mov    0x8(%ebp),%edx
  105731:	89 55 f8             	mov    %edx,-0x8(%ebp)
  105734:	88 45 f7             	mov    %al,-0x9(%ebp)
  105737:	8b 45 10             	mov    0x10(%ebp),%eax
  10573a:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  10573d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  105740:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  105744:	8b 55 f8             	mov    -0x8(%ebp),%edx
  105747:	89 d7                	mov    %edx,%edi
  105749:	f3 aa                	rep stos %al,%es:(%edi)
  10574b:	89 fa                	mov    %edi,%edx
  10574d:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  105750:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  105753:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  105756:	83 c4 24             	add    $0x24,%esp
  105759:	5f                   	pop    %edi
  10575a:	5d                   	pop    %ebp
  10575b:	c3                   	ret    

0010575c <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  10575c:	55                   	push   %ebp
  10575d:	89 e5                	mov    %esp,%ebp
  10575f:	57                   	push   %edi
  105760:	56                   	push   %esi
  105761:	53                   	push   %ebx
  105762:	83 ec 30             	sub    $0x30,%esp
  105765:	8b 45 08             	mov    0x8(%ebp),%eax
  105768:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10576b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10576e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105771:	8b 45 10             	mov    0x10(%ebp),%eax
  105774:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  105777:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10577a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  10577d:	73 42                	jae    1057c1 <memmove+0x65>
  10577f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105782:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105785:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105788:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10578b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10578e:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  105791:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105794:	c1 e8 02             	shr    $0x2,%eax
  105797:	89 c1                	mov    %eax,%ecx
    asm volatile (
  105799:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10579c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10579f:	89 d7                	mov    %edx,%edi
  1057a1:	89 c6                	mov    %eax,%esi
  1057a3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  1057a5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  1057a8:	83 e1 03             	and    $0x3,%ecx
  1057ab:	74 02                	je     1057af <memmove+0x53>
  1057ad:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  1057af:	89 f0                	mov    %esi,%eax
  1057b1:	89 fa                	mov    %edi,%edx
  1057b3:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  1057b6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  1057b9:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
  1057bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1057bf:	eb 36                	jmp    1057f7 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  1057c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1057c4:	8d 50 ff             	lea    -0x1(%eax),%edx
  1057c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1057ca:	01 c2                	add    %eax,%edx
  1057cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1057cf:	8d 48 ff             	lea    -0x1(%eax),%ecx
  1057d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1057d5:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  1057d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1057db:	89 c1                	mov    %eax,%ecx
  1057dd:	89 d8                	mov    %ebx,%eax
  1057df:	89 d6                	mov    %edx,%esi
  1057e1:	89 c7                	mov    %eax,%edi
  1057e3:	fd                   	std    
  1057e4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  1057e6:	fc                   	cld    
  1057e7:	89 f8                	mov    %edi,%eax
  1057e9:	89 f2                	mov    %esi,%edx
  1057eb:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  1057ee:	89 55 c8             	mov    %edx,-0x38(%ebp)
  1057f1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  1057f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  1057f7:	83 c4 30             	add    $0x30,%esp
  1057fa:	5b                   	pop    %ebx
  1057fb:	5e                   	pop    %esi
  1057fc:	5f                   	pop    %edi
  1057fd:	5d                   	pop    %ebp
  1057fe:	c3                   	ret    

001057ff <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  1057ff:	55                   	push   %ebp
  105800:	89 e5                	mov    %esp,%ebp
  105802:	57                   	push   %edi
  105803:	56                   	push   %esi
  105804:	83 ec 20             	sub    $0x20,%esp
  105807:	8b 45 08             	mov    0x8(%ebp),%eax
  10580a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10580d:	8b 45 0c             	mov    0xc(%ebp),%eax
  105810:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105813:	8b 45 10             	mov    0x10(%ebp),%eax
  105816:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  105819:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10581c:	c1 e8 02             	shr    $0x2,%eax
  10581f:	89 c1                	mov    %eax,%ecx
    asm volatile (
  105821:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105824:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105827:	89 d7                	mov    %edx,%edi
  105829:	89 c6                	mov    %eax,%esi
  10582b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  10582d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  105830:	83 e1 03             	and    $0x3,%ecx
  105833:	74 02                	je     105837 <memcpy+0x38>
  105835:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105837:	89 f0                	mov    %esi,%eax
  105839:	89 fa                	mov    %edi,%edx
  10583b:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  10583e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  105841:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  105844:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  105847:	83 c4 20             	add    $0x20,%esp
  10584a:	5e                   	pop    %esi
  10584b:	5f                   	pop    %edi
  10584c:	5d                   	pop    %ebp
  10584d:	c3                   	ret    

0010584e <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  10584e:	55                   	push   %ebp
  10584f:	89 e5                	mov    %esp,%ebp
  105851:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  105854:	8b 45 08             	mov    0x8(%ebp),%eax
  105857:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  10585a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10585d:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  105860:	eb 30                	jmp    105892 <memcmp+0x44>
        if (*s1 != *s2) {
  105862:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105865:	0f b6 10             	movzbl (%eax),%edx
  105868:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10586b:	0f b6 00             	movzbl (%eax),%eax
  10586e:	38 c2                	cmp    %al,%dl
  105870:	74 18                	je     10588a <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  105872:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105875:	0f b6 00             	movzbl (%eax),%eax
  105878:	0f b6 d0             	movzbl %al,%edx
  10587b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10587e:	0f b6 00             	movzbl (%eax),%eax
  105881:	0f b6 c0             	movzbl %al,%eax
  105884:	29 c2                	sub    %eax,%edx
  105886:	89 d0                	mov    %edx,%eax
  105888:	eb 1a                	jmp    1058a4 <memcmp+0x56>
        }
        s1 ++, s2 ++;
  10588a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  10588e:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
    while (n -- > 0) {
  105892:	8b 45 10             	mov    0x10(%ebp),%eax
  105895:	8d 50 ff             	lea    -0x1(%eax),%edx
  105898:	89 55 10             	mov    %edx,0x10(%ebp)
  10589b:	85 c0                	test   %eax,%eax
  10589d:	75 c3                	jne    105862 <memcmp+0x14>
    }
    return 0;
  10589f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1058a4:	c9                   	leave  
  1058a5:	c3                   	ret    

001058a6 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  1058a6:	55                   	push   %ebp
  1058a7:	89 e5                	mov    %esp,%ebp
  1058a9:	83 ec 58             	sub    $0x58,%esp
  1058ac:	8b 45 10             	mov    0x10(%ebp),%eax
  1058af:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1058b2:	8b 45 14             	mov    0x14(%ebp),%eax
  1058b5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  1058b8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1058bb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1058be:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1058c1:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  1058c4:	8b 45 18             	mov    0x18(%ebp),%eax
  1058c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1058ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1058cd:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1058d0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1058d3:	89 55 f0             	mov    %edx,-0x10(%ebp)
  1058d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1058d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1058dc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1058e0:	74 1c                	je     1058fe <printnum+0x58>
  1058e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1058e5:	ba 00 00 00 00       	mov    $0x0,%edx
  1058ea:	f7 75 e4             	divl   -0x1c(%ebp)
  1058ed:	89 55 f4             	mov    %edx,-0xc(%ebp)
  1058f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1058f3:	ba 00 00 00 00       	mov    $0x0,%edx
  1058f8:	f7 75 e4             	divl   -0x1c(%ebp)
  1058fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1058fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105901:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105904:	f7 75 e4             	divl   -0x1c(%ebp)
  105907:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10590a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  10590d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105910:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105913:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105916:	89 55 ec             	mov    %edx,-0x14(%ebp)
  105919:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10591c:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  10591f:	8b 45 18             	mov    0x18(%ebp),%eax
  105922:	ba 00 00 00 00       	mov    $0x0,%edx
  105927:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  10592a:	77 56                	ja     105982 <printnum+0xdc>
  10592c:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  10592f:	72 05                	jb     105936 <printnum+0x90>
  105931:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  105934:	77 4c                	ja     105982 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  105936:	8b 45 1c             	mov    0x1c(%ebp),%eax
  105939:	8d 50 ff             	lea    -0x1(%eax),%edx
  10593c:	8b 45 20             	mov    0x20(%ebp),%eax
  10593f:	89 44 24 18          	mov    %eax,0x18(%esp)
  105943:	89 54 24 14          	mov    %edx,0x14(%esp)
  105947:	8b 45 18             	mov    0x18(%ebp),%eax
  10594a:	89 44 24 10          	mov    %eax,0x10(%esp)
  10594e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105951:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105954:	89 44 24 08          	mov    %eax,0x8(%esp)
  105958:	89 54 24 0c          	mov    %edx,0xc(%esp)
  10595c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10595f:	89 44 24 04          	mov    %eax,0x4(%esp)
  105963:	8b 45 08             	mov    0x8(%ebp),%eax
  105966:	89 04 24             	mov    %eax,(%esp)
  105969:	e8 38 ff ff ff       	call   1058a6 <printnum>
  10596e:	eb 1c                	jmp    10598c <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  105970:	8b 45 0c             	mov    0xc(%ebp),%eax
  105973:	89 44 24 04          	mov    %eax,0x4(%esp)
  105977:	8b 45 20             	mov    0x20(%ebp),%eax
  10597a:	89 04 24             	mov    %eax,(%esp)
  10597d:	8b 45 08             	mov    0x8(%ebp),%eax
  105980:	ff d0                	call   *%eax
        while (-- width > 0)
  105982:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  105986:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  10598a:	7f e4                	jg     105970 <printnum+0xca>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  10598c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10598f:	05 f4 70 10 00       	add    $0x1070f4,%eax
  105994:	0f b6 00             	movzbl (%eax),%eax
  105997:	0f be c0             	movsbl %al,%eax
  10599a:	8b 55 0c             	mov    0xc(%ebp),%edx
  10599d:	89 54 24 04          	mov    %edx,0x4(%esp)
  1059a1:	89 04 24             	mov    %eax,(%esp)
  1059a4:	8b 45 08             	mov    0x8(%ebp),%eax
  1059a7:	ff d0                	call   *%eax
}
  1059a9:	c9                   	leave  
  1059aa:	c3                   	ret    

001059ab <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  1059ab:	55                   	push   %ebp
  1059ac:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  1059ae:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  1059b2:	7e 14                	jle    1059c8 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  1059b4:	8b 45 08             	mov    0x8(%ebp),%eax
  1059b7:	8b 00                	mov    (%eax),%eax
  1059b9:	8d 48 08             	lea    0x8(%eax),%ecx
  1059bc:	8b 55 08             	mov    0x8(%ebp),%edx
  1059bf:	89 0a                	mov    %ecx,(%edx)
  1059c1:	8b 50 04             	mov    0x4(%eax),%edx
  1059c4:	8b 00                	mov    (%eax),%eax
  1059c6:	eb 30                	jmp    1059f8 <getuint+0x4d>
    }
    else if (lflag) {
  1059c8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1059cc:	74 16                	je     1059e4 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  1059ce:	8b 45 08             	mov    0x8(%ebp),%eax
  1059d1:	8b 00                	mov    (%eax),%eax
  1059d3:	8d 48 04             	lea    0x4(%eax),%ecx
  1059d6:	8b 55 08             	mov    0x8(%ebp),%edx
  1059d9:	89 0a                	mov    %ecx,(%edx)
  1059db:	8b 00                	mov    (%eax),%eax
  1059dd:	ba 00 00 00 00       	mov    $0x0,%edx
  1059e2:	eb 14                	jmp    1059f8 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  1059e4:	8b 45 08             	mov    0x8(%ebp),%eax
  1059e7:	8b 00                	mov    (%eax),%eax
  1059e9:	8d 48 04             	lea    0x4(%eax),%ecx
  1059ec:	8b 55 08             	mov    0x8(%ebp),%edx
  1059ef:	89 0a                	mov    %ecx,(%edx)
  1059f1:	8b 00                	mov    (%eax),%eax
  1059f3:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  1059f8:	5d                   	pop    %ebp
  1059f9:	c3                   	ret    

001059fa <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  1059fa:	55                   	push   %ebp
  1059fb:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  1059fd:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  105a01:	7e 14                	jle    105a17 <getint+0x1d>
        return va_arg(*ap, long long);
  105a03:	8b 45 08             	mov    0x8(%ebp),%eax
  105a06:	8b 00                	mov    (%eax),%eax
  105a08:	8d 48 08             	lea    0x8(%eax),%ecx
  105a0b:	8b 55 08             	mov    0x8(%ebp),%edx
  105a0e:	89 0a                	mov    %ecx,(%edx)
  105a10:	8b 50 04             	mov    0x4(%eax),%edx
  105a13:	8b 00                	mov    (%eax),%eax
  105a15:	eb 28                	jmp    105a3f <getint+0x45>
    }
    else if (lflag) {
  105a17:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105a1b:	74 12                	je     105a2f <getint+0x35>
        return va_arg(*ap, long);
  105a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  105a20:	8b 00                	mov    (%eax),%eax
  105a22:	8d 48 04             	lea    0x4(%eax),%ecx
  105a25:	8b 55 08             	mov    0x8(%ebp),%edx
  105a28:	89 0a                	mov    %ecx,(%edx)
  105a2a:	8b 00                	mov    (%eax),%eax
  105a2c:	99                   	cltd   
  105a2d:	eb 10                	jmp    105a3f <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  105a2f:	8b 45 08             	mov    0x8(%ebp),%eax
  105a32:	8b 00                	mov    (%eax),%eax
  105a34:	8d 48 04             	lea    0x4(%eax),%ecx
  105a37:	8b 55 08             	mov    0x8(%ebp),%edx
  105a3a:	89 0a                	mov    %ecx,(%edx)
  105a3c:	8b 00                	mov    (%eax),%eax
  105a3e:	99                   	cltd   
    }
}
  105a3f:	5d                   	pop    %ebp
  105a40:	c3                   	ret    

00105a41 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  105a41:	55                   	push   %ebp
  105a42:	89 e5                	mov    %esp,%ebp
  105a44:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  105a47:	8d 45 14             	lea    0x14(%ebp),%eax
  105a4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  105a4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105a50:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105a54:	8b 45 10             	mov    0x10(%ebp),%eax
  105a57:	89 44 24 08          	mov    %eax,0x8(%esp)
  105a5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  105a62:	8b 45 08             	mov    0x8(%ebp),%eax
  105a65:	89 04 24             	mov    %eax,(%esp)
  105a68:	e8 02 00 00 00       	call   105a6f <vprintfmt>
    va_end(ap);
}
  105a6d:	c9                   	leave  
  105a6e:	c3                   	ret    

00105a6f <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  105a6f:	55                   	push   %ebp
  105a70:	89 e5                	mov    %esp,%ebp
  105a72:	56                   	push   %esi
  105a73:	53                   	push   %ebx
  105a74:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105a77:	eb 18                	jmp    105a91 <vprintfmt+0x22>
            if (ch == '\0') {
  105a79:	85 db                	test   %ebx,%ebx
  105a7b:	75 05                	jne    105a82 <vprintfmt+0x13>
                return;
  105a7d:	e9 d1 03 00 00       	jmp    105e53 <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
  105a82:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a85:	89 44 24 04          	mov    %eax,0x4(%esp)
  105a89:	89 1c 24             	mov    %ebx,(%esp)
  105a8c:	8b 45 08             	mov    0x8(%ebp),%eax
  105a8f:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105a91:	8b 45 10             	mov    0x10(%ebp),%eax
  105a94:	8d 50 01             	lea    0x1(%eax),%edx
  105a97:	89 55 10             	mov    %edx,0x10(%ebp)
  105a9a:	0f b6 00             	movzbl (%eax),%eax
  105a9d:	0f b6 d8             	movzbl %al,%ebx
  105aa0:	83 fb 25             	cmp    $0x25,%ebx
  105aa3:	75 d4                	jne    105a79 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
  105aa5:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  105aa9:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  105ab0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105ab3:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  105ab6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  105abd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105ac0:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  105ac3:	8b 45 10             	mov    0x10(%ebp),%eax
  105ac6:	8d 50 01             	lea    0x1(%eax),%edx
  105ac9:	89 55 10             	mov    %edx,0x10(%ebp)
  105acc:	0f b6 00             	movzbl (%eax),%eax
  105acf:	0f b6 d8             	movzbl %al,%ebx
  105ad2:	8d 43 dd             	lea    -0x23(%ebx),%eax
  105ad5:	83 f8 55             	cmp    $0x55,%eax
  105ad8:	0f 87 44 03 00 00    	ja     105e22 <vprintfmt+0x3b3>
  105ade:	8b 04 85 18 71 10 00 	mov    0x107118(,%eax,4),%eax
  105ae5:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  105ae7:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  105aeb:	eb d6                	jmp    105ac3 <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  105aed:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  105af1:	eb d0                	jmp    105ac3 <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  105af3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  105afa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105afd:	89 d0                	mov    %edx,%eax
  105aff:	c1 e0 02             	shl    $0x2,%eax
  105b02:	01 d0                	add    %edx,%eax
  105b04:	01 c0                	add    %eax,%eax
  105b06:	01 d8                	add    %ebx,%eax
  105b08:	83 e8 30             	sub    $0x30,%eax
  105b0b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  105b0e:	8b 45 10             	mov    0x10(%ebp),%eax
  105b11:	0f b6 00             	movzbl (%eax),%eax
  105b14:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  105b17:	83 fb 2f             	cmp    $0x2f,%ebx
  105b1a:	7e 0b                	jle    105b27 <vprintfmt+0xb8>
  105b1c:	83 fb 39             	cmp    $0x39,%ebx
  105b1f:	7f 06                	jg     105b27 <vprintfmt+0xb8>
            for (precision = 0; ; ++ fmt) {
  105b21:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                    break;
                }
            }
  105b25:	eb d3                	jmp    105afa <vprintfmt+0x8b>
            goto process_precision;
  105b27:	eb 33                	jmp    105b5c <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
  105b29:	8b 45 14             	mov    0x14(%ebp),%eax
  105b2c:	8d 50 04             	lea    0x4(%eax),%edx
  105b2f:	89 55 14             	mov    %edx,0x14(%ebp)
  105b32:	8b 00                	mov    (%eax),%eax
  105b34:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  105b37:	eb 23                	jmp    105b5c <vprintfmt+0xed>

        case '.':
            if (width < 0)
  105b39:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105b3d:	79 0c                	jns    105b4b <vprintfmt+0xdc>
                width = 0;
  105b3f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  105b46:	e9 78 ff ff ff       	jmp    105ac3 <vprintfmt+0x54>
  105b4b:	e9 73 ff ff ff       	jmp    105ac3 <vprintfmt+0x54>

        case '#':
            altflag = 1;
  105b50:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  105b57:	e9 67 ff ff ff       	jmp    105ac3 <vprintfmt+0x54>

        process_precision:
            if (width < 0)
  105b5c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105b60:	79 12                	jns    105b74 <vprintfmt+0x105>
                width = precision, precision = -1;
  105b62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105b65:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105b68:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  105b6f:	e9 4f ff ff ff       	jmp    105ac3 <vprintfmt+0x54>
  105b74:	e9 4a ff ff ff       	jmp    105ac3 <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  105b79:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
  105b7d:	e9 41 ff ff ff       	jmp    105ac3 <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  105b82:	8b 45 14             	mov    0x14(%ebp),%eax
  105b85:	8d 50 04             	lea    0x4(%eax),%edx
  105b88:	89 55 14             	mov    %edx,0x14(%ebp)
  105b8b:	8b 00                	mov    (%eax),%eax
  105b8d:	8b 55 0c             	mov    0xc(%ebp),%edx
  105b90:	89 54 24 04          	mov    %edx,0x4(%esp)
  105b94:	89 04 24             	mov    %eax,(%esp)
  105b97:	8b 45 08             	mov    0x8(%ebp),%eax
  105b9a:	ff d0                	call   *%eax
            break;
  105b9c:	e9 ac 02 00 00       	jmp    105e4d <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
  105ba1:	8b 45 14             	mov    0x14(%ebp),%eax
  105ba4:	8d 50 04             	lea    0x4(%eax),%edx
  105ba7:	89 55 14             	mov    %edx,0x14(%ebp)
  105baa:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  105bac:	85 db                	test   %ebx,%ebx
  105bae:	79 02                	jns    105bb2 <vprintfmt+0x143>
                err = -err;
  105bb0:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  105bb2:	83 fb 06             	cmp    $0x6,%ebx
  105bb5:	7f 0b                	jg     105bc2 <vprintfmt+0x153>
  105bb7:	8b 34 9d d8 70 10 00 	mov    0x1070d8(,%ebx,4),%esi
  105bbe:	85 f6                	test   %esi,%esi
  105bc0:	75 23                	jne    105be5 <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
  105bc2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  105bc6:	c7 44 24 08 05 71 10 	movl   $0x107105,0x8(%esp)
  105bcd:	00 
  105bce:	8b 45 0c             	mov    0xc(%ebp),%eax
  105bd1:	89 44 24 04          	mov    %eax,0x4(%esp)
  105bd5:	8b 45 08             	mov    0x8(%ebp),%eax
  105bd8:	89 04 24             	mov    %eax,(%esp)
  105bdb:	e8 61 fe ff ff       	call   105a41 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  105be0:	e9 68 02 00 00       	jmp    105e4d <vprintfmt+0x3de>
                printfmt(putch, putdat, "%s", p);
  105be5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  105be9:	c7 44 24 08 0e 71 10 	movl   $0x10710e,0x8(%esp)
  105bf0:	00 
  105bf1:	8b 45 0c             	mov    0xc(%ebp),%eax
  105bf4:	89 44 24 04          	mov    %eax,0x4(%esp)
  105bf8:	8b 45 08             	mov    0x8(%ebp),%eax
  105bfb:	89 04 24             	mov    %eax,(%esp)
  105bfe:	e8 3e fe ff ff       	call   105a41 <printfmt>
            break;
  105c03:	e9 45 02 00 00       	jmp    105e4d <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  105c08:	8b 45 14             	mov    0x14(%ebp),%eax
  105c0b:	8d 50 04             	lea    0x4(%eax),%edx
  105c0e:	89 55 14             	mov    %edx,0x14(%ebp)
  105c11:	8b 30                	mov    (%eax),%esi
  105c13:	85 f6                	test   %esi,%esi
  105c15:	75 05                	jne    105c1c <vprintfmt+0x1ad>
                p = "(null)";
  105c17:	be 11 71 10 00       	mov    $0x107111,%esi
            }
            if (width > 0 && padc != '-') {
  105c1c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105c20:	7e 3e                	jle    105c60 <vprintfmt+0x1f1>
  105c22:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  105c26:	74 38                	je     105c60 <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  105c28:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  105c2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105c2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c32:	89 34 24             	mov    %esi,(%esp)
  105c35:	e8 dc f7 ff ff       	call   105416 <strnlen>
  105c3a:	29 c3                	sub    %eax,%ebx
  105c3c:	89 d8                	mov    %ebx,%eax
  105c3e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105c41:	eb 17                	jmp    105c5a <vprintfmt+0x1eb>
                    putch(padc, putdat);
  105c43:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  105c47:	8b 55 0c             	mov    0xc(%ebp),%edx
  105c4a:	89 54 24 04          	mov    %edx,0x4(%esp)
  105c4e:	89 04 24             	mov    %eax,(%esp)
  105c51:	8b 45 08             	mov    0x8(%ebp),%eax
  105c54:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
  105c56:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  105c5a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105c5e:	7f e3                	jg     105c43 <vprintfmt+0x1d4>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105c60:	eb 38                	jmp    105c9a <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
  105c62:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  105c66:	74 1f                	je     105c87 <vprintfmt+0x218>
  105c68:	83 fb 1f             	cmp    $0x1f,%ebx
  105c6b:	7e 05                	jle    105c72 <vprintfmt+0x203>
  105c6d:	83 fb 7e             	cmp    $0x7e,%ebx
  105c70:	7e 15                	jle    105c87 <vprintfmt+0x218>
                    putch('?', putdat);
  105c72:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c75:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c79:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  105c80:	8b 45 08             	mov    0x8(%ebp),%eax
  105c83:	ff d0                	call   *%eax
  105c85:	eb 0f                	jmp    105c96 <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
  105c87:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c8a:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c8e:	89 1c 24             	mov    %ebx,(%esp)
  105c91:	8b 45 08             	mov    0x8(%ebp),%eax
  105c94:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105c96:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  105c9a:	89 f0                	mov    %esi,%eax
  105c9c:	8d 70 01             	lea    0x1(%eax),%esi
  105c9f:	0f b6 00             	movzbl (%eax),%eax
  105ca2:	0f be d8             	movsbl %al,%ebx
  105ca5:	85 db                	test   %ebx,%ebx
  105ca7:	74 10                	je     105cb9 <vprintfmt+0x24a>
  105ca9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105cad:	78 b3                	js     105c62 <vprintfmt+0x1f3>
  105caf:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  105cb3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105cb7:	79 a9                	jns    105c62 <vprintfmt+0x1f3>
                }
            }
            for (; width > 0; width --) {
  105cb9:	eb 17                	jmp    105cd2 <vprintfmt+0x263>
                putch(' ', putdat);
  105cbb:	8b 45 0c             	mov    0xc(%ebp),%eax
  105cbe:	89 44 24 04          	mov    %eax,0x4(%esp)
  105cc2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  105cc9:	8b 45 08             	mov    0x8(%ebp),%eax
  105ccc:	ff d0                	call   *%eax
            for (; width > 0; width --) {
  105cce:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  105cd2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105cd6:	7f e3                	jg     105cbb <vprintfmt+0x24c>
            }
            break;
  105cd8:	e9 70 01 00 00       	jmp    105e4d <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  105cdd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105ce0:	89 44 24 04          	mov    %eax,0x4(%esp)
  105ce4:	8d 45 14             	lea    0x14(%ebp),%eax
  105ce7:	89 04 24             	mov    %eax,(%esp)
  105cea:	e8 0b fd ff ff       	call   1059fa <getint>
  105cef:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105cf2:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  105cf5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105cf8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105cfb:	85 d2                	test   %edx,%edx
  105cfd:	79 26                	jns    105d25 <vprintfmt+0x2b6>
                putch('-', putdat);
  105cff:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d02:	89 44 24 04          	mov    %eax,0x4(%esp)
  105d06:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  105d0d:	8b 45 08             	mov    0x8(%ebp),%eax
  105d10:	ff d0                	call   *%eax
                num = -(long long)num;
  105d12:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105d15:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105d18:	f7 d8                	neg    %eax
  105d1a:	83 d2 00             	adc    $0x0,%edx
  105d1d:	f7 da                	neg    %edx
  105d1f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105d22:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  105d25:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  105d2c:	e9 a8 00 00 00       	jmp    105dd9 <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  105d31:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105d34:	89 44 24 04          	mov    %eax,0x4(%esp)
  105d38:	8d 45 14             	lea    0x14(%ebp),%eax
  105d3b:	89 04 24             	mov    %eax,(%esp)
  105d3e:	e8 68 fc ff ff       	call   1059ab <getuint>
  105d43:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105d46:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  105d49:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  105d50:	e9 84 00 00 00       	jmp    105dd9 <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  105d55:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105d58:	89 44 24 04          	mov    %eax,0x4(%esp)
  105d5c:	8d 45 14             	lea    0x14(%ebp),%eax
  105d5f:	89 04 24             	mov    %eax,(%esp)
  105d62:	e8 44 fc ff ff       	call   1059ab <getuint>
  105d67:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105d6a:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  105d6d:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  105d74:	eb 63                	jmp    105dd9 <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
  105d76:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d79:	89 44 24 04          	mov    %eax,0x4(%esp)
  105d7d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  105d84:	8b 45 08             	mov    0x8(%ebp),%eax
  105d87:	ff d0                	call   *%eax
            putch('x', putdat);
  105d89:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  105d90:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  105d97:	8b 45 08             	mov    0x8(%ebp),%eax
  105d9a:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  105d9c:	8b 45 14             	mov    0x14(%ebp),%eax
  105d9f:	8d 50 04             	lea    0x4(%eax),%edx
  105da2:	89 55 14             	mov    %edx,0x14(%ebp)
  105da5:	8b 00                	mov    (%eax),%eax
  105da7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105daa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  105db1:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  105db8:	eb 1f                	jmp    105dd9 <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  105dba:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105dbd:	89 44 24 04          	mov    %eax,0x4(%esp)
  105dc1:	8d 45 14             	lea    0x14(%ebp),%eax
  105dc4:	89 04 24             	mov    %eax,(%esp)
  105dc7:	e8 df fb ff ff       	call   1059ab <getuint>
  105dcc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105dcf:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  105dd2:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  105dd9:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  105ddd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105de0:	89 54 24 18          	mov    %edx,0x18(%esp)
  105de4:	8b 55 e8             	mov    -0x18(%ebp),%edx
  105de7:	89 54 24 14          	mov    %edx,0x14(%esp)
  105deb:	89 44 24 10          	mov    %eax,0x10(%esp)
  105def:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105df2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105df5:	89 44 24 08          	mov    %eax,0x8(%esp)
  105df9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105dfd:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e00:	89 44 24 04          	mov    %eax,0x4(%esp)
  105e04:	8b 45 08             	mov    0x8(%ebp),%eax
  105e07:	89 04 24             	mov    %eax,(%esp)
  105e0a:	e8 97 fa ff ff       	call   1058a6 <printnum>
            break;
  105e0f:	eb 3c                	jmp    105e4d <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  105e11:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e14:	89 44 24 04          	mov    %eax,0x4(%esp)
  105e18:	89 1c 24             	mov    %ebx,(%esp)
  105e1b:	8b 45 08             	mov    0x8(%ebp),%eax
  105e1e:	ff d0                	call   *%eax
            break;
  105e20:	eb 2b                	jmp    105e4d <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  105e22:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e25:	89 44 24 04          	mov    %eax,0x4(%esp)
  105e29:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  105e30:	8b 45 08             	mov    0x8(%ebp),%eax
  105e33:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  105e35:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  105e39:	eb 04                	jmp    105e3f <vprintfmt+0x3d0>
  105e3b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  105e3f:	8b 45 10             	mov    0x10(%ebp),%eax
  105e42:	83 e8 01             	sub    $0x1,%eax
  105e45:	0f b6 00             	movzbl (%eax),%eax
  105e48:	3c 25                	cmp    $0x25,%al
  105e4a:	75 ef                	jne    105e3b <vprintfmt+0x3cc>
                /* do nothing */;
            break;
  105e4c:	90                   	nop
        }
    }
  105e4d:	90                   	nop
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105e4e:	e9 3e fc ff ff       	jmp    105a91 <vprintfmt+0x22>
}
  105e53:	83 c4 40             	add    $0x40,%esp
  105e56:	5b                   	pop    %ebx
  105e57:	5e                   	pop    %esi
  105e58:	5d                   	pop    %ebp
  105e59:	c3                   	ret    

00105e5a <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  105e5a:	55                   	push   %ebp
  105e5b:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  105e5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e60:	8b 40 08             	mov    0x8(%eax),%eax
  105e63:	8d 50 01             	lea    0x1(%eax),%edx
  105e66:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e69:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  105e6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e6f:	8b 10                	mov    (%eax),%edx
  105e71:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e74:	8b 40 04             	mov    0x4(%eax),%eax
  105e77:	39 c2                	cmp    %eax,%edx
  105e79:	73 12                	jae    105e8d <sprintputch+0x33>
        *b->buf ++ = ch;
  105e7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e7e:	8b 00                	mov    (%eax),%eax
  105e80:	8d 48 01             	lea    0x1(%eax),%ecx
  105e83:	8b 55 0c             	mov    0xc(%ebp),%edx
  105e86:	89 0a                	mov    %ecx,(%edx)
  105e88:	8b 55 08             	mov    0x8(%ebp),%edx
  105e8b:	88 10                	mov    %dl,(%eax)
    }
}
  105e8d:	5d                   	pop    %ebp
  105e8e:	c3                   	ret    

00105e8f <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  105e8f:	55                   	push   %ebp
  105e90:	89 e5                	mov    %esp,%ebp
  105e92:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  105e95:	8d 45 14             	lea    0x14(%ebp),%eax
  105e98:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  105e9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105e9e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105ea2:	8b 45 10             	mov    0x10(%ebp),%eax
  105ea5:	89 44 24 08          	mov    %eax,0x8(%esp)
  105ea9:	8b 45 0c             	mov    0xc(%ebp),%eax
  105eac:	89 44 24 04          	mov    %eax,0x4(%esp)
  105eb0:	8b 45 08             	mov    0x8(%ebp),%eax
  105eb3:	89 04 24             	mov    %eax,(%esp)
  105eb6:	e8 08 00 00 00       	call   105ec3 <vsnprintf>
  105ebb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  105ebe:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105ec1:	c9                   	leave  
  105ec2:	c3                   	ret    

00105ec3 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  105ec3:	55                   	push   %ebp
  105ec4:	89 e5                	mov    %esp,%ebp
  105ec6:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  105ec9:	8b 45 08             	mov    0x8(%ebp),%eax
  105ecc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105ecf:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ed2:	8d 50 ff             	lea    -0x1(%eax),%edx
  105ed5:	8b 45 08             	mov    0x8(%ebp),%eax
  105ed8:	01 d0                	add    %edx,%eax
  105eda:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105edd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  105ee4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  105ee8:	74 0a                	je     105ef4 <vsnprintf+0x31>
  105eea:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105eed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105ef0:	39 c2                	cmp    %eax,%edx
  105ef2:	76 07                	jbe    105efb <vsnprintf+0x38>
        return -E_INVAL;
  105ef4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  105ef9:	eb 2a                	jmp    105f25 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  105efb:	8b 45 14             	mov    0x14(%ebp),%eax
  105efe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105f02:	8b 45 10             	mov    0x10(%ebp),%eax
  105f05:	89 44 24 08          	mov    %eax,0x8(%esp)
  105f09:	8d 45 ec             	lea    -0x14(%ebp),%eax
  105f0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  105f10:	c7 04 24 5a 5e 10 00 	movl   $0x105e5a,(%esp)
  105f17:	e8 53 fb ff ff       	call   105a6f <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  105f1c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105f1f:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  105f22:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105f25:	c9                   	leave  
  105f26:	c3                   	ret    
