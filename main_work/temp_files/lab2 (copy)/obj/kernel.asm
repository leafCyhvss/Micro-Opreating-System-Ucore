
bin/kernel:     file format elf32-i386


Disassembly of section .text:

00100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
  100000:	b8 00 80 11 00       	mov    $0x118000,%eax
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
  100041:	b8 00 a0 11 00       	mov    $0x11a000,%eax
  100046:	29 c2                	sub    %eax,%edx
  100048:	89 d0                	mov    %edx,%eax
  10004a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  100055:	00 
  100056:	c7 04 24 00 a0 11 00 	movl   $0x11a000,(%esp)
  10005d:	e8 87 55 00 00       	call   1055e9 <memset>

    cons_init();                // init the console
  100062:	e8 8c 15 00 00       	call   1015f3 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100067:	c7 45 f4 00 5e 10 00 	movl   $0x105e00,-0xc(%ebp)
    cprintf("%s\n\n", message);
  10006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100071:	89 44 24 04          	mov    %eax,0x4(%esp)
  100075:	c7 04 24 1c 5e 10 00 	movl   $0x105e1c,(%esp)
  10007c:	e8 11 02 00 00       	call   100292 <cprintf>

    print_kerninfo();
  100081:	e8 c3 08 00 00       	call   100949 <print_kerninfo>

    grade_backtrace();
  100086:	e8 86 00 00 00       	call   100111 <grade_backtrace>

    pmm_init();                 // init physical memory management
  10008b:	e8 f4 30 00 00       	call   103184 <pmm_init>

    pic_init();                 // init interrupt controller
  100090:	e8 bb 16 00 00       	call   101750 <pic_init>
    idt_init();                 // init interrupt descriptor table
  100095:	e8 19 18 00 00       	call   1018b3 <idt_init>

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
  100161:	c7 04 24 21 5e 10 00 	movl   $0x105e21,(%esp)
  100168:	e8 25 01 00 00       	call   100292 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  10016d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100171:	0f b7 d0             	movzwl %ax,%edx
  100174:	a1 00 a0 11 00       	mov    0x11a000,%eax
  100179:	89 54 24 08          	mov    %edx,0x8(%esp)
  10017d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100181:	c7 04 24 2f 5e 10 00 	movl   $0x105e2f,(%esp)
  100188:	e8 05 01 00 00       	call   100292 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  10018d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100191:	0f b7 d0             	movzwl %ax,%edx
  100194:	a1 00 a0 11 00       	mov    0x11a000,%eax
  100199:	89 54 24 08          	mov    %edx,0x8(%esp)
  10019d:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001a1:	c7 04 24 3d 5e 10 00 	movl   $0x105e3d,(%esp)
  1001a8:	e8 e5 00 00 00       	call   100292 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  1001ad:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1001b1:	0f b7 d0             	movzwl %ax,%edx
  1001b4:	a1 00 a0 11 00       	mov    0x11a000,%eax
  1001b9:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001c1:	c7 04 24 4b 5e 10 00 	movl   $0x105e4b,(%esp)
  1001c8:	e8 c5 00 00 00       	call   100292 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  1001cd:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001d1:	0f b7 d0             	movzwl %ax,%edx
  1001d4:	a1 00 a0 11 00       	mov    0x11a000,%eax
  1001d9:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001e1:	c7 04 24 59 5e 10 00 	movl   $0x105e59,(%esp)
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
  100211:	c7 04 24 68 5e 10 00 	movl   $0x105e68,(%esp)
  100218:	e8 75 00 00 00       	call   100292 <cprintf>
    lab1_switch_to_user();
  10021d:	e8 da ff ff ff       	call   1001fc <lab1_switch_to_user>
    lab1_print_cur_status();
  100222:	e8 0f ff ff ff       	call   100136 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  100227:	c7 04 24 88 5e 10 00 	movl   $0x105e88,(%esp)
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
  100288:	e8 ae 56 00 00       	call   10593b <vprintfmt>
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
  100346:	c7 04 24 a7 5e 10 00 	movl   $0x105ea7,(%esp)
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
  100418:	c7 04 24 aa 5e 10 00 	movl   $0x105eaa,(%esp)
  10041f:	e8 6e fe ff ff       	call   100292 <cprintf>
    vcprintf(fmt, ap);
  100424:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100427:	89 44 24 04          	mov    %eax,0x4(%esp)
  10042b:	8b 45 10             	mov    0x10(%ebp),%eax
  10042e:	89 04 24             	mov    %eax,(%esp)
  100431:	e8 29 fe ff ff       	call   10025f <vcprintf>
    cprintf("\n");
  100436:	c7 04 24 c6 5e 10 00 	movl   $0x105ec6,(%esp)
  10043d:	e8 50 fe ff ff       	call   100292 <cprintf>
    
    cprintf("stack trackback:\n");
  100442:	c7 04 24 c8 5e 10 00 	movl   $0x105ec8,(%esp)
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
  100480:	c7 04 24 da 5e 10 00 	movl   $0x105eda,(%esp)
  100487:	e8 06 fe ff ff       	call   100292 <cprintf>
    vcprintf(fmt, ap);
  10048c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10048f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100493:	8b 45 10             	mov    0x10(%ebp),%eax
  100496:	89 04 24             	mov    %eax,(%esp)
  100499:	e8 c1 fd ff ff       	call   10025f <vcprintf>
    cprintf("\n");
  10049e:	c7 04 24 c6 5e 10 00 	movl   $0x105ec6,(%esp)
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
  100615:	c7 00 f8 5e 10 00    	movl   $0x105ef8,(%eax)
    info->eip_line = 0;
  10061b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10061e:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  100625:	8b 45 0c             	mov    0xc(%ebp),%eax
  100628:	c7 40 08 f8 5e 10 00 	movl   $0x105ef8,0x8(%eax)
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
  10064c:	c7 45 f4 ec 70 10 00 	movl   $0x1070ec,-0xc(%ebp)
    stab_end = __STAB_END__;
  100653:	c7 45 f0 98 1b 11 00 	movl   $0x111b98,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  10065a:	c7 45 ec 99 1b 11 00 	movl   $0x111b99,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  100661:	c7 45 e8 c5 45 11 00 	movl   $0x1145c5,-0x18(%ebp)

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
  1007c0:	e8 98 4c 00 00       	call   10545d <strfind>
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
  10094f:	c7 04 24 02 5f 10 00 	movl   $0x105f02,(%esp)
  100956:	e8 37 f9 ff ff       	call   100292 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  10095b:	c7 44 24 04 36 00 10 	movl   $0x100036,0x4(%esp)
  100962:	00 
  100963:	c7 04 24 1b 5f 10 00 	movl   $0x105f1b,(%esp)
  10096a:	e8 23 f9 ff ff       	call   100292 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  10096f:	c7 44 24 04 f3 5d 10 	movl   $0x105df3,0x4(%esp)
  100976:	00 
  100977:	c7 04 24 33 5f 10 00 	movl   $0x105f33,(%esp)
  10097e:	e8 0f f9 ff ff       	call   100292 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  100983:	c7 44 24 04 00 a0 11 	movl   $0x11a000,0x4(%esp)
  10098a:	00 
  10098b:	c7 04 24 4b 5f 10 00 	movl   $0x105f4b,(%esp)
  100992:	e8 fb f8 ff ff       	call   100292 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  100997:	c7 44 24 04 28 af 11 	movl   $0x11af28,0x4(%esp)
  10099e:	00 
  10099f:	c7 04 24 63 5f 10 00 	movl   $0x105f63,(%esp)
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
  1009d1:	c7 04 24 7c 5f 10 00 	movl   $0x105f7c,(%esp)
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
  100a05:	c7 04 24 a6 5f 10 00 	movl   $0x105fa6,(%esp)
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
  100a74:	c7 04 24 c2 5f 10 00 	movl   $0x105fc2,(%esp)
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
  100ac7:	c7 04 24 d4 5f 10 00 	movl   $0x105fd4,(%esp)
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
  100b09:	c7 04 24 f0 5f 10 00 	movl   $0x105ff0,(%esp)
  100b10:	e8 7d f7 ff ff       	call   100292 <cprintf>
        //依次打印调用函数的参数1 2 3 4
		cprintf("\n");
  100b15:	c7 04 24 12 60 10 00 	movl   $0x106012,(%esp)
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
  100b8e:	c7 04 24 94 60 10 00 	movl   $0x106094,(%esp)
  100b95:	e8 90 48 00 00       	call   10542a <strchr>
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
  100bb8:	c7 04 24 99 60 10 00 	movl   $0x106099,(%esp)
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
  100bfb:	c7 04 24 94 60 10 00 	movl   $0x106094,(%esp)
  100c02:	e8 23 48 00 00       	call   10542a <strchr>
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
  100c67:	e8 1f 47 00 00       	call   10538b <strcmp>
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
  100cb5:	c7 04 24 b7 60 10 00 	movl   $0x1060b7,(%esp)
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
  100cce:	c7 04 24 d0 60 10 00 	movl   $0x1060d0,(%esp)
  100cd5:	e8 b8 f5 ff ff       	call   100292 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100cda:	c7 04 24 f8 60 10 00 	movl   $0x1060f8,(%esp)
  100ce1:	e8 ac f5 ff ff       	call   100292 <cprintf>

    if (tf != NULL) {
  100ce6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100cea:	74 0b                	je     100cf7 <kmonitor+0x2f>
        print_trapframe(tf);
  100cec:	8b 45 08             	mov    0x8(%ebp),%eax
  100cef:	89 04 24             	mov    %eax,(%esp)
  100cf2:	e8 73 0d 00 00       	call   101a6a <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100cf7:	c7 04 24 1d 61 10 00 	movl   $0x10611d,(%esp)
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
  100d66:	c7 04 24 21 61 10 00 	movl   $0x106121,(%esp)
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
  100df2:	c7 04 24 2a 61 10 00 	movl   $0x10612a,(%esp)
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
  100e97:	c7 45 fc 00 80 0b 00 	movl   $0xb8000,-0x4(%ebp)
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
  100ebc:	c7 45 fc 00 00 0b 00 	movl   $0xb0000,-0x4(%ebp)
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
  10121c:	e8 07 44 00 00       	call   105628 <memmove>
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
  1015a2:	c7 04 24 45 61 10 00 	movl   $0x106145,(%esp)
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
  101611:	c7 04 24 51 61 10 00 	movl   $0x106151,(%esp)
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
  1018a5:	c7 04 24 80 61 10 00 	movl   $0x106180,(%esp)
  1018ac:	e8 e1 e9 ff ff       	call   100292 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
  1018b1:	c9                   	leave  
  1018b2:	c3                   	ret    

001018b3 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  1018b3:	55                   	push   %ebp
  1018b4:	89 e5                	mov    %esp,%ebp
  1018b6:	83 ec 10             	sub    $0x10,%esp
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];  //保存在vectors.S中的256个中断处理例程的入口地址数组
    int i;
    //使用SETGATE宏，初始化IDT每个表项
    for (i = 0; i < 256; i ++) 
  1018b9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1018c0:	e9 c3 00 00 00       	jmp    101988 <idt_init+0xd5>
    { 
    //在中断门描述符表中通过建立中断门描述符，其中存储了中断处理例程的代码段GD_KTEXT和偏移量__vectors[i]
    //特权级为DPL_KERNEL, 通过查询idt[i]就可定位到中断服务例程的起始地址。
     SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
  1018c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018c8:	8b 04 85 e0 75 11 00 	mov    0x1175e0(,%eax,4),%eax
  1018cf:	89 c2                	mov    %eax,%edx
  1018d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018d4:	66 89 14 c5 80 a6 11 	mov    %dx,0x11a680(,%eax,8)
  1018db:	00 
  1018dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018df:	66 c7 04 c5 82 a6 11 	movw   $0x8,0x11a682(,%eax,8)
  1018e6:	00 08 00 
  1018e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018ec:	0f b6 14 c5 84 a6 11 	movzbl 0x11a684(,%eax,8),%edx
  1018f3:	00 
  1018f4:	83 e2 e0             	and    $0xffffffe0,%edx
  1018f7:	88 14 c5 84 a6 11 00 	mov    %dl,0x11a684(,%eax,8)
  1018fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101901:	0f b6 14 c5 84 a6 11 	movzbl 0x11a684(,%eax,8),%edx
  101908:	00 
  101909:	83 e2 1f             	and    $0x1f,%edx
  10190c:	88 14 c5 84 a6 11 00 	mov    %dl,0x11a684(,%eax,8)
  101913:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101916:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  10191d:	00 
  10191e:	83 e2 f0             	and    $0xfffffff0,%edx
  101921:	83 ca 0e             	or     $0xe,%edx
  101924:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  10192b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10192e:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  101935:	00 
  101936:	83 e2 ef             	and    $0xffffffef,%edx
  101939:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  101940:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101943:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  10194a:	00 
  10194b:	83 e2 9f             	and    $0xffffff9f,%edx
  10194e:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  101955:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101958:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  10195f:	00 
  101960:	83 ca 80             	or     $0xffffff80,%edx
  101963:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  10196a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10196d:	8b 04 85 e0 75 11 00 	mov    0x1175e0(,%eax,4),%eax
  101974:	c1 e8 10             	shr    $0x10,%eax
  101977:	89 c2                	mov    %eax,%edx
  101979:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10197c:	66 89 14 c5 86 a6 11 	mov    %dx,0x11a686(,%eax,8)
  101983:	00 
    for (i = 0; i < 256; i ++) 
  101984:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  101988:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
  10198f:	0f 8e 30 ff ff ff    	jle    1018c5 <idt_init+0x12>
    }
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT,__vectors[T_SWITCH_TOK], DPL_USER);
  101995:	a1 c4 77 11 00       	mov    0x1177c4,%eax
  10199a:	66 a3 48 aa 11 00    	mov    %ax,0x11aa48
  1019a0:	66 c7 05 4a aa 11 00 	movw   $0x8,0x11aa4a
  1019a7:	08 00 
  1019a9:	0f b6 05 4c aa 11 00 	movzbl 0x11aa4c,%eax
  1019b0:	83 e0 e0             	and    $0xffffffe0,%eax
  1019b3:	a2 4c aa 11 00       	mov    %al,0x11aa4c
  1019b8:	0f b6 05 4c aa 11 00 	movzbl 0x11aa4c,%eax
  1019bf:	83 e0 1f             	and    $0x1f,%eax
  1019c2:	a2 4c aa 11 00       	mov    %al,0x11aa4c
  1019c7:	0f b6 05 4d aa 11 00 	movzbl 0x11aa4d,%eax
  1019ce:	83 e0 f0             	and    $0xfffffff0,%eax
  1019d1:	83 c8 0e             	or     $0xe,%eax
  1019d4:	a2 4d aa 11 00       	mov    %al,0x11aa4d
  1019d9:	0f b6 05 4d aa 11 00 	movzbl 0x11aa4d,%eax
  1019e0:	83 e0 ef             	and    $0xffffffef,%eax
  1019e3:	a2 4d aa 11 00       	mov    %al,0x11aa4d
  1019e8:	0f b6 05 4d aa 11 00 	movzbl 0x11aa4d,%eax
  1019ef:	83 c8 60             	or     $0x60,%eax
  1019f2:	a2 4d aa 11 00       	mov    %al,0x11aa4d
  1019f7:	0f b6 05 4d aa 11 00 	movzbl 0x11aa4d,%eax
  1019fe:	83 c8 80             	or     $0xffffff80,%eax
  101a01:	a2 4d aa 11 00       	mov    %al,0x11aa4d
  101a06:	a1 c4 77 11 00       	mov    0x1177c4,%eax
  101a0b:	c1 e8 10             	shr    $0x10,%eax
  101a0e:	66 a3 4e aa 11 00    	mov    %ax,0x11aa4e
  101a14:	c7 45 f8 60 75 11 00 	movl   $0x117560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
  101a1b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101a1e:	0f 01 18             	lidtl  (%eax)
     //指令lidt把中断门描述符表的起始地址装入IDTR寄存器
    lidt(&idt_pd);
}
  101a21:	c9                   	leave  
  101a22:	c3                   	ret    

00101a23 <trapname>:

static const char *
trapname(int trapno) {
  101a23:	55                   	push   %ebp
  101a24:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  101a26:	8b 45 08             	mov    0x8(%ebp),%eax
  101a29:	83 f8 13             	cmp    $0x13,%eax
  101a2c:	77 0c                	ja     101a3a <trapname+0x17>
        return excnames[trapno];
  101a2e:	8b 45 08             	mov    0x8(%ebp),%eax
  101a31:	8b 04 85 e0 64 10 00 	mov    0x1064e0(,%eax,4),%eax
  101a38:	eb 18                	jmp    101a52 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  101a3a:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  101a3e:	7e 0d                	jle    101a4d <trapname+0x2a>
  101a40:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  101a44:	7f 07                	jg     101a4d <trapname+0x2a>
        return "Hardware Interrupt";
  101a46:	b8 8a 61 10 00       	mov    $0x10618a,%eax
  101a4b:	eb 05                	jmp    101a52 <trapname+0x2f>
    }
    return "(unknown trap)";
  101a4d:	b8 9d 61 10 00       	mov    $0x10619d,%eax
}
  101a52:	5d                   	pop    %ebp
  101a53:	c3                   	ret    

00101a54 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  101a54:	55                   	push   %ebp
  101a55:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  101a57:	8b 45 08             	mov    0x8(%ebp),%eax
  101a5a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101a5e:	66 83 f8 08          	cmp    $0x8,%ax
  101a62:	0f 94 c0             	sete   %al
  101a65:	0f b6 c0             	movzbl %al,%eax
}
  101a68:	5d                   	pop    %ebp
  101a69:	c3                   	ret    

00101a6a <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  101a6a:	55                   	push   %ebp
  101a6b:	89 e5                	mov    %esp,%ebp
  101a6d:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  101a70:	8b 45 08             	mov    0x8(%ebp),%eax
  101a73:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a77:	c7 04 24 de 61 10 00 	movl   $0x1061de,(%esp)
  101a7e:	e8 0f e8 ff ff       	call   100292 <cprintf>
    print_regs(&tf->tf_regs);
  101a83:	8b 45 08             	mov    0x8(%ebp),%eax
  101a86:	89 04 24             	mov    %eax,(%esp)
  101a89:	e8 a1 01 00 00       	call   101c2f <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101a8e:	8b 45 08             	mov    0x8(%ebp),%eax
  101a91:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101a95:	0f b7 c0             	movzwl %ax,%eax
  101a98:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a9c:	c7 04 24 ef 61 10 00 	movl   $0x1061ef,(%esp)
  101aa3:	e8 ea e7 ff ff       	call   100292 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101aa8:	8b 45 08             	mov    0x8(%ebp),%eax
  101aab:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101aaf:	0f b7 c0             	movzwl %ax,%eax
  101ab2:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ab6:	c7 04 24 02 62 10 00 	movl   $0x106202,(%esp)
  101abd:	e8 d0 e7 ff ff       	call   100292 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101ac2:	8b 45 08             	mov    0x8(%ebp),%eax
  101ac5:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101ac9:	0f b7 c0             	movzwl %ax,%eax
  101acc:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ad0:	c7 04 24 15 62 10 00 	movl   $0x106215,(%esp)
  101ad7:	e8 b6 e7 ff ff       	call   100292 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101adc:	8b 45 08             	mov    0x8(%ebp),%eax
  101adf:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101ae3:	0f b7 c0             	movzwl %ax,%eax
  101ae6:	89 44 24 04          	mov    %eax,0x4(%esp)
  101aea:	c7 04 24 28 62 10 00 	movl   $0x106228,(%esp)
  101af1:	e8 9c e7 ff ff       	call   100292 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101af6:	8b 45 08             	mov    0x8(%ebp),%eax
  101af9:	8b 40 30             	mov    0x30(%eax),%eax
  101afc:	89 04 24             	mov    %eax,(%esp)
  101aff:	e8 1f ff ff ff       	call   101a23 <trapname>
  101b04:	8b 55 08             	mov    0x8(%ebp),%edx
  101b07:	8b 52 30             	mov    0x30(%edx),%edx
  101b0a:	89 44 24 08          	mov    %eax,0x8(%esp)
  101b0e:	89 54 24 04          	mov    %edx,0x4(%esp)
  101b12:	c7 04 24 3b 62 10 00 	movl   $0x10623b,(%esp)
  101b19:	e8 74 e7 ff ff       	call   100292 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101b1e:	8b 45 08             	mov    0x8(%ebp),%eax
  101b21:	8b 40 34             	mov    0x34(%eax),%eax
  101b24:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b28:	c7 04 24 4d 62 10 00 	movl   $0x10624d,(%esp)
  101b2f:	e8 5e e7 ff ff       	call   100292 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101b34:	8b 45 08             	mov    0x8(%ebp),%eax
  101b37:	8b 40 38             	mov    0x38(%eax),%eax
  101b3a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b3e:	c7 04 24 5c 62 10 00 	movl   $0x10625c,(%esp)
  101b45:	e8 48 e7 ff ff       	call   100292 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101b4a:	8b 45 08             	mov    0x8(%ebp),%eax
  101b4d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101b51:	0f b7 c0             	movzwl %ax,%eax
  101b54:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b58:	c7 04 24 6b 62 10 00 	movl   $0x10626b,(%esp)
  101b5f:	e8 2e e7 ff ff       	call   100292 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101b64:	8b 45 08             	mov    0x8(%ebp),%eax
  101b67:	8b 40 40             	mov    0x40(%eax),%eax
  101b6a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b6e:	c7 04 24 7e 62 10 00 	movl   $0x10627e,(%esp)
  101b75:	e8 18 e7 ff ff       	call   100292 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101b7a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101b81:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101b88:	eb 3e                	jmp    101bc8 <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101b8a:	8b 45 08             	mov    0x8(%ebp),%eax
  101b8d:	8b 50 40             	mov    0x40(%eax),%edx
  101b90:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101b93:	21 d0                	and    %edx,%eax
  101b95:	85 c0                	test   %eax,%eax
  101b97:	74 28                	je     101bc1 <print_trapframe+0x157>
  101b99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b9c:	8b 04 85 80 75 11 00 	mov    0x117580(,%eax,4),%eax
  101ba3:	85 c0                	test   %eax,%eax
  101ba5:	74 1a                	je     101bc1 <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
  101ba7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101baa:	8b 04 85 80 75 11 00 	mov    0x117580(,%eax,4),%eax
  101bb1:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bb5:	c7 04 24 8d 62 10 00 	movl   $0x10628d,(%esp)
  101bbc:	e8 d1 e6 ff ff       	call   100292 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101bc1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  101bc5:	d1 65 f0             	shll   -0x10(%ebp)
  101bc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101bcb:	83 f8 17             	cmp    $0x17,%eax
  101bce:	76 ba                	jbe    101b8a <print_trapframe+0x120>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101bd0:	8b 45 08             	mov    0x8(%ebp),%eax
  101bd3:	8b 40 40             	mov    0x40(%eax),%eax
  101bd6:	25 00 30 00 00       	and    $0x3000,%eax
  101bdb:	c1 e8 0c             	shr    $0xc,%eax
  101bde:	89 44 24 04          	mov    %eax,0x4(%esp)
  101be2:	c7 04 24 91 62 10 00 	movl   $0x106291,(%esp)
  101be9:	e8 a4 e6 ff ff       	call   100292 <cprintf>

    if (!trap_in_kernel(tf)) {
  101bee:	8b 45 08             	mov    0x8(%ebp),%eax
  101bf1:	89 04 24             	mov    %eax,(%esp)
  101bf4:	e8 5b fe ff ff       	call   101a54 <trap_in_kernel>
  101bf9:	85 c0                	test   %eax,%eax
  101bfb:	75 30                	jne    101c2d <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101bfd:	8b 45 08             	mov    0x8(%ebp),%eax
  101c00:	8b 40 44             	mov    0x44(%eax),%eax
  101c03:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c07:	c7 04 24 9a 62 10 00 	movl   $0x10629a,(%esp)
  101c0e:	e8 7f e6 ff ff       	call   100292 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101c13:	8b 45 08             	mov    0x8(%ebp),%eax
  101c16:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101c1a:	0f b7 c0             	movzwl %ax,%eax
  101c1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c21:	c7 04 24 a9 62 10 00 	movl   $0x1062a9,(%esp)
  101c28:	e8 65 e6 ff ff       	call   100292 <cprintf>
    }
}
  101c2d:	c9                   	leave  
  101c2e:	c3                   	ret    

00101c2f <print_regs>:

void
print_regs(struct pushregs *regs) {
  101c2f:	55                   	push   %ebp
  101c30:	89 e5                	mov    %esp,%ebp
  101c32:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101c35:	8b 45 08             	mov    0x8(%ebp),%eax
  101c38:	8b 00                	mov    (%eax),%eax
  101c3a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c3e:	c7 04 24 bc 62 10 00 	movl   $0x1062bc,(%esp)
  101c45:	e8 48 e6 ff ff       	call   100292 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101c4a:	8b 45 08             	mov    0x8(%ebp),%eax
  101c4d:	8b 40 04             	mov    0x4(%eax),%eax
  101c50:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c54:	c7 04 24 cb 62 10 00 	movl   $0x1062cb,(%esp)
  101c5b:	e8 32 e6 ff ff       	call   100292 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101c60:	8b 45 08             	mov    0x8(%ebp),%eax
  101c63:	8b 40 08             	mov    0x8(%eax),%eax
  101c66:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c6a:	c7 04 24 da 62 10 00 	movl   $0x1062da,(%esp)
  101c71:	e8 1c e6 ff ff       	call   100292 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101c76:	8b 45 08             	mov    0x8(%ebp),%eax
  101c79:	8b 40 0c             	mov    0xc(%eax),%eax
  101c7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c80:	c7 04 24 e9 62 10 00 	movl   $0x1062e9,(%esp)
  101c87:	e8 06 e6 ff ff       	call   100292 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101c8c:	8b 45 08             	mov    0x8(%ebp),%eax
  101c8f:	8b 40 10             	mov    0x10(%eax),%eax
  101c92:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c96:	c7 04 24 f8 62 10 00 	movl   $0x1062f8,(%esp)
  101c9d:	e8 f0 e5 ff ff       	call   100292 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101ca2:	8b 45 08             	mov    0x8(%ebp),%eax
  101ca5:	8b 40 14             	mov    0x14(%eax),%eax
  101ca8:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cac:	c7 04 24 07 63 10 00 	movl   $0x106307,(%esp)
  101cb3:	e8 da e5 ff ff       	call   100292 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101cb8:	8b 45 08             	mov    0x8(%ebp),%eax
  101cbb:	8b 40 18             	mov    0x18(%eax),%eax
  101cbe:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cc2:	c7 04 24 16 63 10 00 	movl   $0x106316,(%esp)
  101cc9:	e8 c4 e5 ff ff       	call   100292 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101cce:	8b 45 08             	mov    0x8(%ebp),%eax
  101cd1:	8b 40 1c             	mov    0x1c(%eax),%eax
  101cd4:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cd8:	c7 04 24 25 63 10 00 	movl   $0x106325,(%esp)
  101cdf:	e8 ae e5 ff ff       	call   100292 <cprintf>
}
  101ce4:	c9                   	leave  
  101ce5:	c3                   	ret    

00101ce6 <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101ce6:	55                   	push   %ebp
  101ce7:	89 e5                	mov    %esp,%ebp
  101ce9:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
  101cec:	8b 45 08             	mov    0x8(%ebp),%eax
  101cef:	8b 40 30             	mov    0x30(%eax),%eax
  101cf2:	83 f8 2f             	cmp    $0x2f,%eax
  101cf5:	77 21                	ja     101d18 <trap_dispatch+0x32>
  101cf7:	83 f8 2e             	cmp    $0x2e,%eax
  101cfa:	0f 83 0b 01 00 00    	jae    101e0b <trap_dispatch+0x125>
  101d00:	83 f8 21             	cmp    $0x21,%eax
  101d03:	0f 84 88 00 00 00    	je     101d91 <trap_dispatch+0xab>
  101d09:	83 f8 24             	cmp    $0x24,%eax
  101d0c:	74 5d                	je     101d6b <trap_dispatch+0x85>
  101d0e:	83 f8 20             	cmp    $0x20,%eax
  101d11:	74 16                	je     101d29 <trap_dispatch+0x43>
  101d13:	e9 bb 00 00 00       	jmp    101dd3 <trap_dispatch+0xed>
  101d18:	83 e8 78             	sub    $0x78,%eax
  101d1b:	83 f8 01             	cmp    $0x1,%eax
  101d1e:	0f 87 af 00 00 00    	ja     101dd3 <trap_dispatch+0xed>
  101d24:	e9 8e 00 00 00       	jmp    101db7 <trap_dispatch+0xd1>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
	    if (((++ticks) % TICK_NUM) == 0) {
  101d29:	a1 0c af 11 00       	mov    0x11af0c,%eax
  101d2e:	83 c0 01             	add    $0x1,%eax
  101d31:	89 c1                	mov    %eax,%ecx
  101d33:	89 0d 0c af 11 00    	mov    %ecx,0x11af0c
  101d39:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101d3e:	89 c8                	mov    %ecx,%eax
  101d40:	f7 e2                	mul    %edx
  101d42:	89 d0                	mov    %edx,%eax
  101d44:	c1 e8 05             	shr    $0x5,%eax
  101d47:	6b c0 64             	imul   $0x64,%eax,%eax
  101d4a:	29 c1                	sub    %eax,%ecx
  101d4c:	89 c8                	mov    %ecx,%eax
  101d4e:	85 c0                	test   %eax,%eax
  101d50:	75 14                	jne    101d66 <trap_dispatch+0x80>
		print_ticks();
  101d52:	e8 40 fb ff ff       	call   101897 <print_ticks>
		ticks = 0;
  101d57:	c7 05 0c af 11 00 00 	movl   $0x0,0x11af0c
  101d5e:	00 00 00 
        }
        break;
  101d61:	e9 a6 00 00 00       	jmp    101e0c <trap_dispatch+0x126>
  101d66:	e9 a1 00 00 00       	jmp    101e0c <trap_dispatch+0x126>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101d6b:	e8 eb f8 ff ff       	call   10165b <cons_getc>
  101d70:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101d73:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101d77:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101d7b:	89 54 24 08          	mov    %edx,0x8(%esp)
  101d7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d83:	c7 04 24 34 63 10 00 	movl   $0x106334,(%esp)
  101d8a:	e8 03 e5 ff ff       	call   100292 <cprintf>
        break;
  101d8f:	eb 7b                	jmp    101e0c <trap_dispatch+0x126>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101d91:	e8 c5 f8 ff ff       	call   10165b <cons_getc>
  101d96:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101d99:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101d9d:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101da1:	89 54 24 08          	mov    %edx,0x8(%esp)
  101da5:	89 44 24 04          	mov    %eax,0x4(%esp)
  101da9:	c7 04 24 46 63 10 00 	movl   $0x106346,(%esp)
  101db0:	e8 dd e4 ff ff       	call   100292 <cprintf>
        break;
  101db5:	eb 55                	jmp    101e0c <trap_dispatch+0x126>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
  101db7:	c7 44 24 08 55 63 10 	movl   $0x106355,0x8(%esp)
  101dbe:	00 
  101dbf:	c7 44 24 04 b2 00 00 	movl   $0xb2,0x4(%esp)
  101dc6:	00 
  101dc7:	c7 04 24 65 63 10 00 	movl   $0x106365,(%esp)
  101dce:	e8 16 e6 ff ff       	call   1003e9 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101dd3:	8b 45 08             	mov    0x8(%ebp),%eax
  101dd6:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101dda:	0f b7 c0             	movzwl %ax,%eax
  101ddd:	83 e0 03             	and    $0x3,%eax
  101de0:	85 c0                	test   %eax,%eax
  101de2:	75 28                	jne    101e0c <trap_dispatch+0x126>
            print_trapframe(tf);
  101de4:	8b 45 08             	mov    0x8(%ebp),%eax
  101de7:	89 04 24             	mov    %eax,(%esp)
  101dea:	e8 7b fc ff ff       	call   101a6a <print_trapframe>
            panic("unexpected trap in kernel.\n");
  101def:	c7 44 24 08 76 63 10 	movl   $0x106376,0x8(%esp)
  101df6:	00 
  101df7:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
  101dfe:	00 
  101dff:	c7 04 24 65 63 10 00 	movl   $0x106365,(%esp)
  101e06:	e8 de e5 ff ff       	call   1003e9 <__panic>
        break;
  101e0b:	90                   	nop
        }
    }
}
  101e0c:	c9                   	leave  
  101e0d:	c3                   	ret    

00101e0e <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101e0e:	55                   	push   %ebp
  101e0f:	89 e5                	mov    %esp,%ebp
  101e11:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101e14:	8b 45 08             	mov    0x8(%ebp),%eax
  101e17:	89 04 24             	mov    %eax,(%esp)
  101e1a:	e8 c7 fe ff ff       	call   101ce6 <trap_dispatch>
}
  101e1f:	c9                   	leave  
  101e20:	c3                   	ret    

00101e21 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101e21:	6a 00                	push   $0x0
  pushl $0
  101e23:	6a 00                	push   $0x0
  jmp __alltraps
  101e25:	e9 69 0a 00 00       	jmp    102893 <__alltraps>

00101e2a <vector1>:
.globl vector1
vector1:
  pushl $0
  101e2a:	6a 00                	push   $0x0
  pushl $1
  101e2c:	6a 01                	push   $0x1
  jmp __alltraps
  101e2e:	e9 60 0a 00 00       	jmp    102893 <__alltraps>

00101e33 <vector2>:
.globl vector2
vector2:
  pushl $0
  101e33:	6a 00                	push   $0x0
  pushl $2
  101e35:	6a 02                	push   $0x2
  jmp __alltraps
  101e37:	e9 57 0a 00 00       	jmp    102893 <__alltraps>

00101e3c <vector3>:
.globl vector3
vector3:
  pushl $0
  101e3c:	6a 00                	push   $0x0
  pushl $3
  101e3e:	6a 03                	push   $0x3
  jmp __alltraps
  101e40:	e9 4e 0a 00 00       	jmp    102893 <__alltraps>

00101e45 <vector4>:
.globl vector4
vector4:
  pushl $0
  101e45:	6a 00                	push   $0x0
  pushl $4
  101e47:	6a 04                	push   $0x4
  jmp __alltraps
  101e49:	e9 45 0a 00 00       	jmp    102893 <__alltraps>

00101e4e <vector5>:
.globl vector5
vector5:
  pushl $0
  101e4e:	6a 00                	push   $0x0
  pushl $5
  101e50:	6a 05                	push   $0x5
  jmp __alltraps
  101e52:	e9 3c 0a 00 00       	jmp    102893 <__alltraps>

00101e57 <vector6>:
.globl vector6
vector6:
  pushl $0
  101e57:	6a 00                	push   $0x0
  pushl $6
  101e59:	6a 06                	push   $0x6
  jmp __alltraps
  101e5b:	e9 33 0a 00 00       	jmp    102893 <__alltraps>

00101e60 <vector7>:
.globl vector7
vector7:
  pushl $0
  101e60:	6a 00                	push   $0x0
  pushl $7
  101e62:	6a 07                	push   $0x7
  jmp __alltraps
  101e64:	e9 2a 0a 00 00       	jmp    102893 <__alltraps>

00101e69 <vector8>:
.globl vector8
vector8:
  pushl $8
  101e69:	6a 08                	push   $0x8
  jmp __alltraps
  101e6b:	e9 23 0a 00 00       	jmp    102893 <__alltraps>

00101e70 <vector9>:
.globl vector9
vector9:
  pushl $0
  101e70:	6a 00                	push   $0x0
  pushl $9
  101e72:	6a 09                	push   $0x9
  jmp __alltraps
  101e74:	e9 1a 0a 00 00       	jmp    102893 <__alltraps>

00101e79 <vector10>:
.globl vector10
vector10:
  pushl $10
  101e79:	6a 0a                	push   $0xa
  jmp __alltraps
  101e7b:	e9 13 0a 00 00       	jmp    102893 <__alltraps>

00101e80 <vector11>:
.globl vector11
vector11:
  pushl $11
  101e80:	6a 0b                	push   $0xb
  jmp __alltraps
  101e82:	e9 0c 0a 00 00       	jmp    102893 <__alltraps>

00101e87 <vector12>:
.globl vector12
vector12:
  pushl $12
  101e87:	6a 0c                	push   $0xc
  jmp __alltraps
  101e89:	e9 05 0a 00 00       	jmp    102893 <__alltraps>

00101e8e <vector13>:
.globl vector13
vector13:
  pushl $13
  101e8e:	6a 0d                	push   $0xd
  jmp __alltraps
  101e90:	e9 fe 09 00 00       	jmp    102893 <__alltraps>

00101e95 <vector14>:
.globl vector14
vector14:
  pushl $14
  101e95:	6a 0e                	push   $0xe
  jmp __alltraps
  101e97:	e9 f7 09 00 00       	jmp    102893 <__alltraps>

00101e9c <vector15>:
.globl vector15
vector15:
  pushl $0
  101e9c:	6a 00                	push   $0x0
  pushl $15
  101e9e:	6a 0f                	push   $0xf
  jmp __alltraps
  101ea0:	e9 ee 09 00 00       	jmp    102893 <__alltraps>

00101ea5 <vector16>:
.globl vector16
vector16:
  pushl $0
  101ea5:	6a 00                	push   $0x0
  pushl $16
  101ea7:	6a 10                	push   $0x10
  jmp __alltraps
  101ea9:	e9 e5 09 00 00       	jmp    102893 <__alltraps>

00101eae <vector17>:
.globl vector17
vector17:
  pushl $17
  101eae:	6a 11                	push   $0x11
  jmp __alltraps
  101eb0:	e9 de 09 00 00       	jmp    102893 <__alltraps>

00101eb5 <vector18>:
.globl vector18
vector18:
  pushl $0
  101eb5:	6a 00                	push   $0x0
  pushl $18
  101eb7:	6a 12                	push   $0x12
  jmp __alltraps
  101eb9:	e9 d5 09 00 00       	jmp    102893 <__alltraps>

00101ebe <vector19>:
.globl vector19
vector19:
  pushl $0
  101ebe:	6a 00                	push   $0x0
  pushl $19
  101ec0:	6a 13                	push   $0x13
  jmp __alltraps
  101ec2:	e9 cc 09 00 00       	jmp    102893 <__alltraps>

00101ec7 <vector20>:
.globl vector20
vector20:
  pushl $0
  101ec7:	6a 00                	push   $0x0
  pushl $20
  101ec9:	6a 14                	push   $0x14
  jmp __alltraps
  101ecb:	e9 c3 09 00 00       	jmp    102893 <__alltraps>

00101ed0 <vector21>:
.globl vector21
vector21:
  pushl $0
  101ed0:	6a 00                	push   $0x0
  pushl $21
  101ed2:	6a 15                	push   $0x15
  jmp __alltraps
  101ed4:	e9 ba 09 00 00       	jmp    102893 <__alltraps>

00101ed9 <vector22>:
.globl vector22
vector22:
  pushl $0
  101ed9:	6a 00                	push   $0x0
  pushl $22
  101edb:	6a 16                	push   $0x16
  jmp __alltraps
  101edd:	e9 b1 09 00 00       	jmp    102893 <__alltraps>

00101ee2 <vector23>:
.globl vector23
vector23:
  pushl $0
  101ee2:	6a 00                	push   $0x0
  pushl $23
  101ee4:	6a 17                	push   $0x17
  jmp __alltraps
  101ee6:	e9 a8 09 00 00       	jmp    102893 <__alltraps>

00101eeb <vector24>:
.globl vector24
vector24:
  pushl $0
  101eeb:	6a 00                	push   $0x0
  pushl $24
  101eed:	6a 18                	push   $0x18
  jmp __alltraps
  101eef:	e9 9f 09 00 00       	jmp    102893 <__alltraps>

00101ef4 <vector25>:
.globl vector25
vector25:
  pushl $0
  101ef4:	6a 00                	push   $0x0
  pushl $25
  101ef6:	6a 19                	push   $0x19
  jmp __alltraps
  101ef8:	e9 96 09 00 00       	jmp    102893 <__alltraps>

00101efd <vector26>:
.globl vector26
vector26:
  pushl $0
  101efd:	6a 00                	push   $0x0
  pushl $26
  101eff:	6a 1a                	push   $0x1a
  jmp __alltraps
  101f01:	e9 8d 09 00 00       	jmp    102893 <__alltraps>

00101f06 <vector27>:
.globl vector27
vector27:
  pushl $0
  101f06:	6a 00                	push   $0x0
  pushl $27
  101f08:	6a 1b                	push   $0x1b
  jmp __alltraps
  101f0a:	e9 84 09 00 00       	jmp    102893 <__alltraps>

00101f0f <vector28>:
.globl vector28
vector28:
  pushl $0
  101f0f:	6a 00                	push   $0x0
  pushl $28
  101f11:	6a 1c                	push   $0x1c
  jmp __alltraps
  101f13:	e9 7b 09 00 00       	jmp    102893 <__alltraps>

00101f18 <vector29>:
.globl vector29
vector29:
  pushl $0
  101f18:	6a 00                	push   $0x0
  pushl $29
  101f1a:	6a 1d                	push   $0x1d
  jmp __alltraps
  101f1c:	e9 72 09 00 00       	jmp    102893 <__alltraps>

00101f21 <vector30>:
.globl vector30
vector30:
  pushl $0
  101f21:	6a 00                	push   $0x0
  pushl $30
  101f23:	6a 1e                	push   $0x1e
  jmp __alltraps
  101f25:	e9 69 09 00 00       	jmp    102893 <__alltraps>

00101f2a <vector31>:
.globl vector31
vector31:
  pushl $0
  101f2a:	6a 00                	push   $0x0
  pushl $31
  101f2c:	6a 1f                	push   $0x1f
  jmp __alltraps
  101f2e:	e9 60 09 00 00       	jmp    102893 <__alltraps>

00101f33 <vector32>:
.globl vector32
vector32:
  pushl $0
  101f33:	6a 00                	push   $0x0
  pushl $32
  101f35:	6a 20                	push   $0x20
  jmp __alltraps
  101f37:	e9 57 09 00 00       	jmp    102893 <__alltraps>

00101f3c <vector33>:
.globl vector33
vector33:
  pushl $0
  101f3c:	6a 00                	push   $0x0
  pushl $33
  101f3e:	6a 21                	push   $0x21
  jmp __alltraps
  101f40:	e9 4e 09 00 00       	jmp    102893 <__alltraps>

00101f45 <vector34>:
.globl vector34
vector34:
  pushl $0
  101f45:	6a 00                	push   $0x0
  pushl $34
  101f47:	6a 22                	push   $0x22
  jmp __alltraps
  101f49:	e9 45 09 00 00       	jmp    102893 <__alltraps>

00101f4e <vector35>:
.globl vector35
vector35:
  pushl $0
  101f4e:	6a 00                	push   $0x0
  pushl $35
  101f50:	6a 23                	push   $0x23
  jmp __alltraps
  101f52:	e9 3c 09 00 00       	jmp    102893 <__alltraps>

00101f57 <vector36>:
.globl vector36
vector36:
  pushl $0
  101f57:	6a 00                	push   $0x0
  pushl $36
  101f59:	6a 24                	push   $0x24
  jmp __alltraps
  101f5b:	e9 33 09 00 00       	jmp    102893 <__alltraps>

00101f60 <vector37>:
.globl vector37
vector37:
  pushl $0
  101f60:	6a 00                	push   $0x0
  pushl $37
  101f62:	6a 25                	push   $0x25
  jmp __alltraps
  101f64:	e9 2a 09 00 00       	jmp    102893 <__alltraps>

00101f69 <vector38>:
.globl vector38
vector38:
  pushl $0
  101f69:	6a 00                	push   $0x0
  pushl $38
  101f6b:	6a 26                	push   $0x26
  jmp __alltraps
  101f6d:	e9 21 09 00 00       	jmp    102893 <__alltraps>

00101f72 <vector39>:
.globl vector39
vector39:
  pushl $0
  101f72:	6a 00                	push   $0x0
  pushl $39
  101f74:	6a 27                	push   $0x27
  jmp __alltraps
  101f76:	e9 18 09 00 00       	jmp    102893 <__alltraps>

00101f7b <vector40>:
.globl vector40
vector40:
  pushl $0
  101f7b:	6a 00                	push   $0x0
  pushl $40
  101f7d:	6a 28                	push   $0x28
  jmp __alltraps
  101f7f:	e9 0f 09 00 00       	jmp    102893 <__alltraps>

00101f84 <vector41>:
.globl vector41
vector41:
  pushl $0
  101f84:	6a 00                	push   $0x0
  pushl $41
  101f86:	6a 29                	push   $0x29
  jmp __alltraps
  101f88:	e9 06 09 00 00       	jmp    102893 <__alltraps>

00101f8d <vector42>:
.globl vector42
vector42:
  pushl $0
  101f8d:	6a 00                	push   $0x0
  pushl $42
  101f8f:	6a 2a                	push   $0x2a
  jmp __alltraps
  101f91:	e9 fd 08 00 00       	jmp    102893 <__alltraps>

00101f96 <vector43>:
.globl vector43
vector43:
  pushl $0
  101f96:	6a 00                	push   $0x0
  pushl $43
  101f98:	6a 2b                	push   $0x2b
  jmp __alltraps
  101f9a:	e9 f4 08 00 00       	jmp    102893 <__alltraps>

00101f9f <vector44>:
.globl vector44
vector44:
  pushl $0
  101f9f:	6a 00                	push   $0x0
  pushl $44
  101fa1:	6a 2c                	push   $0x2c
  jmp __alltraps
  101fa3:	e9 eb 08 00 00       	jmp    102893 <__alltraps>

00101fa8 <vector45>:
.globl vector45
vector45:
  pushl $0
  101fa8:	6a 00                	push   $0x0
  pushl $45
  101faa:	6a 2d                	push   $0x2d
  jmp __alltraps
  101fac:	e9 e2 08 00 00       	jmp    102893 <__alltraps>

00101fb1 <vector46>:
.globl vector46
vector46:
  pushl $0
  101fb1:	6a 00                	push   $0x0
  pushl $46
  101fb3:	6a 2e                	push   $0x2e
  jmp __alltraps
  101fb5:	e9 d9 08 00 00       	jmp    102893 <__alltraps>

00101fba <vector47>:
.globl vector47
vector47:
  pushl $0
  101fba:	6a 00                	push   $0x0
  pushl $47
  101fbc:	6a 2f                	push   $0x2f
  jmp __alltraps
  101fbe:	e9 d0 08 00 00       	jmp    102893 <__alltraps>

00101fc3 <vector48>:
.globl vector48
vector48:
  pushl $0
  101fc3:	6a 00                	push   $0x0
  pushl $48
  101fc5:	6a 30                	push   $0x30
  jmp __alltraps
  101fc7:	e9 c7 08 00 00       	jmp    102893 <__alltraps>

00101fcc <vector49>:
.globl vector49
vector49:
  pushl $0
  101fcc:	6a 00                	push   $0x0
  pushl $49
  101fce:	6a 31                	push   $0x31
  jmp __alltraps
  101fd0:	e9 be 08 00 00       	jmp    102893 <__alltraps>

00101fd5 <vector50>:
.globl vector50
vector50:
  pushl $0
  101fd5:	6a 00                	push   $0x0
  pushl $50
  101fd7:	6a 32                	push   $0x32
  jmp __alltraps
  101fd9:	e9 b5 08 00 00       	jmp    102893 <__alltraps>

00101fde <vector51>:
.globl vector51
vector51:
  pushl $0
  101fde:	6a 00                	push   $0x0
  pushl $51
  101fe0:	6a 33                	push   $0x33
  jmp __alltraps
  101fe2:	e9 ac 08 00 00       	jmp    102893 <__alltraps>

00101fe7 <vector52>:
.globl vector52
vector52:
  pushl $0
  101fe7:	6a 00                	push   $0x0
  pushl $52
  101fe9:	6a 34                	push   $0x34
  jmp __alltraps
  101feb:	e9 a3 08 00 00       	jmp    102893 <__alltraps>

00101ff0 <vector53>:
.globl vector53
vector53:
  pushl $0
  101ff0:	6a 00                	push   $0x0
  pushl $53
  101ff2:	6a 35                	push   $0x35
  jmp __alltraps
  101ff4:	e9 9a 08 00 00       	jmp    102893 <__alltraps>

00101ff9 <vector54>:
.globl vector54
vector54:
  pushl $0
  101ff9:	6a 00                	push   $0x0
  pushl $54
  101ffb:	6a 36                	push   $0x36
  jmp __alltraps
  101ffd:	e9 91 08 00 00       	jmp    102893 <__alltraps>

00102002 <vector55>:
.globl vector55
vector55:
  pushl $0
  102002:	6a 00                	push   $0x0
  pushl $55
  102004:	6a 37                	push   $0x37
  jmp __alltraps
  102006:	e9 88 08 00 00       	jmp    102893 <__alltraps>

0010200b <vector56>:
.globl vector56
vector56:
  pushl $0
  10200b:	6a 00                	push   $0x0
  pushl $56
  10200d:	6a 38                	push   $0x38
  jmp __alltraps
  10200f:	e9 7f 08 00 00       	jmp    102893 <__alltraps>

00102014 <vector57>:
.globl vector57
vector57:
  pushl $0
  102014:	6a 00                	push   $0x0
  pushl $57
  102016:	6a 39                	push   $0x39
  jmp __alltraps
  102018:	e9 76 08 00 00       	jmp    102893 <__alltraps>

0010201d <vector58>:
.globl vector58
vector58:
  pushl $0
  10201d:	6a 00                	push   $0x0
  pushl $58
  10201f:	6a 3a                	push   $0x3a
  jmp __alltraps
  102021:	e9 6d 08 00 00       	jmp    102893 <__alltraps>

00102026 <vector59>:
.globl vector59
vector59:
  pushl $0
  102026:	6a 00                	push   $0x0
  pushl $59
  102028:	6a 3b                	push   $0x3b
  jmp __alltraps
  10202a:	e9 64 08 00 00       	jmp    102893 <__alltraps>

0010202f <vector60>:
.globl vector60
vector60:
  pushl $0
  10202f:	6a 00                	push   $0x0
  pushl $60
  102031:	6a 3c                	push   $0x3c
  jmp __alltraps
  102033:	e9 5b 08 00 00       	jmp    102893 <__alltraps>

00102038 <vector61>:
.globl vector61
vector61:
  pushl $0
  102038:	6a 00                	push   $0x0
  pushl $61
  10203a:	6a 3d                	push   $0x3d
  jmp __alltraps
  10203c:	e9 52 08 00 00       	jmp    102893 <__alltraps>

00102041 <vector62>:
.globl vector62
vector62:
  pushl $0
  102041:	6a 00                	push   $0x0
  pushl $62
  102043:	6a 3e                	push   $0x3e
  jmp __alltraps
  102045:	e9 49 08 00 00       	jmp    102893 <__alltraps>

0010204a <vector63>:
.globl vector63
vector63:
  pushl $0
  10204a:	6a 00                	push   $0x0
  pushl $63
  10204c:	6a 3f                	push   $0x3f
  jmp __alltraps
  10204e:	e9 40 08 00 00       	jmp    102893 <__alltraps>

00102053 <vector64>:
.globl vector64
vector64:
  pushl $0
  102053:	6a 00                	push   $0x0
  pushl $64
  102055:	6a 40                	push   $0x40
  jmp __alltraps
  102057:	e9 37 08 00 00       	jmp    102893 <__alltraps>

0010205c <vector65>:
.globl vector65
vector65:
  pushl $0
  10205c:	6a 00                	push   $0x0
  pushl $65
  10205e:	6a 41                	push   $0x41
  jmp __alltraps
  102060:	e9 2e 08 00 00       	jmp    102893 <__alltraps>

00102065 <vector66>:
.globl vector66
vector66:
  pushl $0
  102065:	6a 00                	push   $0x0
  pushl $66
  102067:	6a 42                	push   $0x42
  jmp __alltraps
  102069:	e9 25 08 00 00       	jmp    102893 <__alltraps>

0010206e <vector67>:
.globl vector67
vector67:
  pushl $0
  10206e:	6a 00                	push   $0x0
  pushl $67
  102070:	6a 43                	push   $0x43
  jmp __alltraps
  102072:	e9 1c 08 00 00       	jmp    102893 <__alltraps>

00102077 <vector68>:
.globl vector68
vector68:
  pushl $0
  102077:	6a 00                	push   $0x0
  pushl $68
  102079:	6a 44                	push   $0x44
  jmp __alltraps
  10207b:	e9 13 08 00 00       	jmp    102893 <__alltraps>

00102080 <vector69>:
.globl vector69
vector69:
  pushl $0
  102080:	6a 00                	push   $0x0
  pushl $69
  102082:	6a 45                	push   $0x45
  jmp __alltraps
  102084:	e9 0a 08 00 00       	jmp    102893 <__alltraps>

00102089 <vector70>:
.globl vector70
vector70:
  pushl $0
  102089:	6a 00                	push   $0x0
  pushl $70
  10208b:	6a 46                	push   $0x46
  jmp __alltraps
  10208d:	e9 01 08 00 00       	jmp    102893 <__alltraps>

00102092 <vector71>:
.globl vector71
vector71:
  pushl $0
  102092:	6a 00                	push   $0x0
  pushl $71
  102094:	6a 47                	push   $0x47
  jmp __alltraps
  102096:	e9 f8 07 00 00       	jmp    102893 <__alltraps>

0010209b <vector72>:
.globl vector72
vector72:
  pushl $0
  10209b:	6a 00                	push   $0x0
  pushl $72
  10209d:	6a 48                	push   $0x48
  jmp __alltraps
  10209f:	e9 ef 07 00 00       	jmp    102893 <__alltraps>

001020a4 <vector73>:
.globl vector73
vector73:
  pushl $0
  1020a4:	6a 00                	push   $0x0
  pushl $73
  1020a6:	6a 49                	push   $0x49
  jmp __alltraps
  1020a8:	e9 e6 07 00 00       	jmp    102893 <__alltraps>

001020ad <vector74>:
.globl vector74
vector74:
  pushl $0
  1020ad:	6a 00                	push   $0x0
  pushl $74
  1020af:	6a 4a                	push   $0x4a
  jmp __alltraps
  1020b1:	e9 dd 07 00 00       	jmp    102893 <__alltraps>

001020b6 <vector75>:
.globl vector75
vector75:
  pushl $0
  1020b6:	6a 00                	push   $0x0
  pushl $75
  1020b8:	6a 4b                	push   $0x4b
  jmp __alltraps
  1020ba:	e9 d4 07 00 00       	jmp    102893 <__alltraps>

001020bf <vector76>:
.globl vector76
vector76:
  pushl $0
  1020bf:	6a 00                	push   $0x0
  pushl $76
  1020c1:	6a 4c                	push   $0x4c
  jmp __alltraps
  1020c3:	e9 cb 07 00 00       	jmp    102893 <__alltraps>

001020c8 <vector77>:
.globl vector77
vector77:
  pushl $0
  1020c8:	6a 00                	push   $0x0
  pushl $77
  1020ca:	6a 4d                	push   $0x4d
  jmp __alltraps
  1020cc:	e9 c2 07 00 00       	jmp    102893 <__alltraps>

001020d1 <vector78>:
.globl vector78
vector78:
  pushl $0
  1020d1:	6a 00                	push   $0x0
  pushl $78
  1020d3:	6a 4e                	push   $0x4e
  jmp __alltraps
  1020d5:	e9 b9 07 00 00       	jmp    102893 <__alltraps>

001020da <vector79>:
.globl vector79
vector79:
  pushl $0
  1020da:	6a 00                	push   $0x0
  pushl $79
  1020dc:	6a 4f                	push   $0x4f
  jmp __alltraps
  1020de:	e9 b0 07 00 00       	jmp    102893 <__alltraps>

001020e3 <vector80>:
.globl vector80
vector80:
  pushl $0
  1020e3:	6a 00                	push   $0x0
  pushl $80
  1020e5:	6a 50                	push   $0x50
  jmp __alltraps
  1020e7:	e9 a7 07 00 00       	jmp    102893 <__alltraps>

001020ec <vector81>:
.globl vector81
vector81:
  pushl $0
  1020ec:	6a 00                	push   $0x0
  pushl $81
  1020ee:	6a 51                	push   $0x51
  jmp __alltraps
  1020f0:	e9 9e 07 00 00       	jmp    102893 <__alltraps>

001020f5 <vector82>:
.globl vector82
vector82:
  pushl $0
  1020f5:	6a 00                	push   $0x0
  pushl $82
  1020f7:	6a 52                	push   $0x52
  jmp __alltraps
  1020f9:	e9 95 07 00 00       	jmp    102893 <__alltraps>

001020fe <vector83>:
.globl vector83
vector83:
  pushl $0
  1020fe:	6a 00                	push   $0x0
  pushl $83
  102100:	6a 53                	push   $0x53
  jmp __alltraps
  102102:	e9 8c 07 00 00       	jmp    102893 <__alltraps>

00102107 <vector84>:
.globl vector84
vector84:
  pushl $0
  102107:	6a 00                	push   $0x0
  pushl $84
  102109:	6a 54                	push   $0x54
  jmp __alltraps
  10210b:	e9 83 07 00 00       	jmp    102893 <__alltraps>

00102110 <vector85>:
.globl vector85
vector85:
  pushl $0
  102110:	6a 00                	push   $0x0
  pushl $85
  102112:	6a 55                	push   $0x55
  jmp __alltraps
  102114:	e9 7a 07 00 00       	jmp    102893 <__alltraps>

00102119 <vector86>:
.globl vector86
vector86:
  pushl $0
  102119:	6a 00                	push   $0x0
  pushl $86
  10211b:	6a 56                	push   $0x56
  jmp __alltraps
  10211d:	e9 71 07 00 00       	jmp    102893 <__alltraps>

00102122 <vector87>:
.globl vector87
vector87:
  pushl $0
  102122:	6a 00                	push   $0x0
  pushl $87
  102124:	6a 57                	push   $0x57
  jmp __alltraps
  102126:	e9 68 07 00 00       	jmp    102893 <__alltraps>

0010212b <vector88>:
.globl vector88
vector88:
  pushl $0
  10212b:	6a 00                	push   $0x0
  pushl $88
  10212d:	6a 58                	push   $0x58
  jmp __alltraps
  10212f:	e9 5f 07 00 00       	jmp    102893 <__alltraps>

00102134 <vector89>:
.globl vector89
vector89:
  pushl $0
  102134:	6a 00                	push   $0x0
  pushl $89
  102136:	6a 59                	push   $0x59
  jmp __alltraps
  102138:	e9 56 07 00 00       	jmp    102893 <__alltraps>

0010213d <vector90>:
.globl vector90
vector90:
  pushl $0
  10213d:	6a 00                	push   $0x0
  pushl $90
  10213f:	6a 5a                	push   $0x5a
  jmp __alltraps
  102141:	e9 4d 07 00 00       	jmp    102893 <__alltraps>

00102146 <vector91>:
.globl vector91
vector91:
  pushl $0
  102146:	6a 00                	push   $0x0
  pushl $91
  102148:	6a 5b                	push   $0x5b
  jmp __alltraps
  10214a:	e9 44 07 00 00       	jmp    102893 <__alltraps>

0010214f <vector92>:
.globl vector92
vector92:
  pushl $0
  10214f:	6a 00                	push   $0x0
  pushl $92
  102151:	6a 5c                	push   $0x5c
  jmp __alltraps
  102153:	e9 3b 07 00 00       	jmp    102893 <__alltraps>

00102158 <vector93>:
.globl vector93
vector93:
  pushl $0
  102158:	6a 00                	push   $0x0
  pushl $93
  10215a:	6a 5d                	push   $0x5d
  jmp __alltraps
  10215c:	e9 32 07 00 00       	jmp    102893 <__alltraps>

00102161 <vector94>:
.globl vector94
vector94:
  pushl $0
  102161:	6a 00                	push   $0x0
  pushl $94
  102163:	6a 5e                	push   $0x5e
  jmp __alltraps
  102165:	e9 29 07 00 00       	jmp    102893 <__alltraps>

0010216a <vector95>:
.globl vector95
vector95:
  pushl $0
  10216a:	6a 00                	push   $0x0
  pushl $95
  10216c:	6a 5f                	push   $0x5f
  jmp __alltraps
  10216e:	e9 20 07 00 00       	jmp    102893 <__alltraps>

00102173 <vector96>:
.globl vector96
vector96:
  pushl $0
  102173:	6a 00                	push   $0x0
  pushl $96
  102175:	6a 60                	push   $0x60
  jmp __alltraps
  102177:	e9 17 07 00 00       	jmp    102893 <__alltraps>

0010217c <vector97>:
.globl vector97
vector97:
  pushl $0
  10217c:	6a 00                	push   $0x0
  pushl $97
  10217e:	6a 61                	push   $0x61
  jmp __alltraps
  102180:	e9 0e 07 00 00       	jmp    102893 <__alltraps>

00102185 <vector98>:
.globl vector98
vector98:
  pushl $0
  102185:	6a 00                	push   $0x0
  pushl $98
  102187:	6a 62                	push   $0x62
  jmp __alltraps
  102189:	e9 05 07 00 00       	jmp    102893 <__alltraps>

0010218e <vector99>:
.globl vector99
vector99:
  pushl $0
  10218e:	6a 00                	push   $0x0
  pushl $99
  102190:	6a 63                	push   $0x63
  jmp __alltraps
  102192:	e9 fc 06 00 00       	jmp    102893 <__alltraps>

00102197 <vector100>:
.globl vector100
vector100:
  pushl $0
  102197:	6a 00                	push   $0x0
  pushl $100
  102199:	6a 64                	push   $0x64
  jmp __alltraps
  10219b:	e9 f3 06 00 00       	jmp    102893 <__alltraps>

001021a0 <vector101>:
.globl vector101
vector101:
  pushl $0
  1021a0:	6a 00                	push   $0x0
  pushl $101
  1021a2:	6a 65                	push   $0x65
  jmp __alltraps
  1021a4:	e9 ea 06 00 00       	jmp    102893 <__alltraps>

001021a9 <vector102>:
.globl vector102
vector102:
  pushl $0
  1021a9:	6a 00                	push   $0x0
  pushl $102
  1021ab:	6a 66                	push   $0x66
  jmp __alltraps
  1021ad:	e9 e1 06 00 00       	jmp    102893 <__alltraps>

001021b2 <vector103>:
.globl vector103
vector103:
  pushl $0
  1021b2:	6a 00                	push   $0x0
  pushl $103
  1021b4:	6a 67                	push   $0x67
  jmp __alltraps
  1021b6:	e9 d8 06 00 00       	jmp    102893 <__alltraps>

001021bb <vector104>:
.globl vector104
vector104:
  pushl $0
  1021bb:	6a 00                	push   $0x0
  pushl $104
  1021bd:	6a 68                	push   $0x68
  jmp __alltraps
  1021bf:	e9 cf 06 00 00       	jmp    102893 <__alltraps>

001021c4 <vector105>:
.globl vector105
vector105:
  pushl $0
  1021c4:	6a 00                	push   $0x0
  pushl $105
  1021c6:	6a 69                	push   $0x69
  jmp __alltraps
  1021c8:	e9 c6 06 00 00       	jmp    102893 <__alltraps>

001021cd <vector106>:
.globl vector106
vector106:
  pushl $0
  1021cd:	6a 00                	push   $0x0
  pushl $106
  1021cf:	6a 6a                	push   $0x6a
  jmp __alltraps
  1021d1:	e9 bd 06 00 00       	jmp    102893 <__alltraps>

001021d6 <vector107>:
.globl vector107
vector107:
  pushl $0
  1021d6:	6a 00                	push   $0x0
  pushl $107
  1021d8:	6a 6b                	push   $0x6b
  jmp __alltraps
  1021da:	e9 b4 06 00 00       	jmp    102893 <__alltraps>

001021df <vector108>:
.globl vector108
vector108:
  pushl $0
  1021df:	6a 00                	push   $0x0
  pushl $108
  1021e1:	6a 6c                	push   $0x6c
  jmp __alltraps
  1021e3:	e9 ab 06 00 00       	jmp    102893 <__alltraps>

001021e8 <vector109>:
.globl vector109
vector109:
  pushl $0
  1021e8:	6a 00                	push   $0x0
  pushl $109
  1021ea:	6a 6d                	push   $0x6d
  jmp __alltraps
  1021ec:	e9 a2 06 00 00       	jmp    102893 <__alltraps>

001021f1 <vector110>:
.globl vector110
vector110:
  pushl $0
  1021f1:	6a 00                	push   $0x0
  pushl $110
  1021f3:	6a 6e                	push   $0x6e
  jmp __alltraps
  1021f5:	e9 99 06 00 00       	jmp    102893 <__alltraps>

001021fa <vector111>:
.globl vector111
vector111:
  pushl $0
  1021fa:	6a 00                	push   $0x0
  pushl $111
  1021fc:	6a 6f                	push   $0x6f
  jmp __alltraps
  1021fe:	e9 90 06 00 00       	jmp    102893 <__alltraps>

00102203 <vector112>:
.globl vector112
vector112:
  pushl $0
  102203:	6a 00                	push   $0x0
  pushl $112
  102205:	6a 70                	push   $0x70
  jmp __alltraps
  102207:	e9 87 06 00 00       	jmp    102893 <__alltraps>

0010220c <vector113>:
.globl vector113
vector113:
  pushl $0
  10220c:	6a 00                	push   $0x0
  pushl $113
  10220e:	6a 71                	push   $0x71
  jmp __alltraps
  102210:	e9 7e 06 00 00       	jmp    102893 <__alltraps>

00102215 <vector114>:
.globl vector114
vector114:
  pushl $0
  102215:	6a 00                	push   $0x0
  pushl $114
  102217:	6a 72                	push   $0x72
  jmp __alltraps
  102219:	e9 75 06 00 00       	jmp    102893 <__alltraps>

0010221e <vector115>:
.globl vector115
vector115:
  pushl $0
  10221e:	6a 00                	push   $0x0
  pushl $115
  102220:	6a 73                	push   $0x73
  jmp __alltraps
  102222:	e9 6c 06 00 00       	jmp    102893 <__alltraps>

00102227 <vector116>:
.globl vector116
vector116:
  pushl $0
  102227:	6a 00                	push   $0x0
  pushl $116
  102229:	6a 74                	push   $0x74
  jmp __alltraps
  10222b:	e9 63 06 00 00       	jmp    102893 <__alltraps>

00102230 <vector117>:
.globl vector117
vector117:
  pushl $0
  102230:	6a 00                	push   $0x0
  pushl $117
  102232:	6a 75                	push   $0x75
  jmp __alltraps
  102234:	e9 5a 06 00 00       	jmp    102893 <__alltraps>

00102239 <vector118>:
.globl vector118
vector118:
  pushl $0
  102239:	6a 00                	push   $0x0
  pushl $118
  10223b:	6a 76                	push   $0x76
  jmp __alltraps
  10223d:	e9 51 06 00 00       	jmp    102893 <__alltraps>

00102242 <vector119>:
.globl vector119
vector119:
  pushl $0
  102242:	6a 00                	push   $0x0
  pushl $119
  102244:	6a 77                	push   $0x77
  jmp __alltraps
  102246:	e9 48 06 00 00       	jmp    102893 <__alltraps>

0010224b <vector120>:
.globl vector120
vector120:
  pushl $0
  10224b:	6a 00                	push   $0x0
  pushl $120
  10224d:	6a 78                	push   $0x78
  jmp __alltraps
  10224f:	e9 3f 06 00 00       	jmp    102893 <__alltraps>

00102254 <vector121>:
.globl vector121
vector121:
  pushl $0
  102254:	6a 00                	push   $0x0
  pushl $121
  102256:	6a 79                	push   $0x79
  jmp __alltraps
  102258:	e9 36 06 00 00       	jmp    102893 <__alltraps>

0010225d <vector122>:
.globl vector122
vector122:
  pushl $0
  10225d:	6a 00                	push   $0x0
  pushl $122
  10225f:	6a 7a                	push   $0x7a
  jmp __alltraps
  102261:	e9 2d 06 00 00       	jmp    102893 <__alltraps>

00102266 <vector123>:
.globl vector123
vector123:
  pushl $0
  102266:	6a 00                	push   $0x0
  pushl $123
  102268:	6a 7b                	push   $0x7b
  jmp __alltraps
  10226a:	e9 24 06 00 00       	jmp    102893 <__alltraps>

0010226f <vector124>:
.globl vector124
vector124:
  pushl $0
  10226f:	6a 00                	push   $0x0
  pushl $124
  102271:	6a 7c                	push   $0x7c
  jmp __alltraps
  102273:	e9 1b 06 00 00       	jmp    102893 <__alltraps>

00102278 <vector125>:
.globl vector125
vector125:
  pushl $0
  102278:	6a 00                	push   $0x0
  pushl $125
  10227a:	6a 7d                	push   $0x7d
  jmp __alltraps
  10227c:	e9 12 06 00 00       	jmp    102893 <__alltraps>

00102281 <vector126>:
.globl vector126
vector126:
  pushl $0
  102281:	6a 00                	push   $0x0
  pushl $126
  102283:	6a 7e                	push   $0x7e
  jmp __alltraps
  102285:	e9 09 06 00 00       	jmp    102893 <__alltraps>

0010228a <vector127>:
.globl vector127
vector127:
  pushl $0
  10228a:	6a 00                	push   $0x0
  pushl $127
  10228c:	6a 7f                	push   $0x7f
  jmp __alltraps
  10228e:	e9 00 06 00 00       	jmp    102893 <__alltraps>

00102293 <vector128>:
.globl vector128
vector128:
  pushl $0
  102293:	6a 00                	push   $0x0
  pushl $128
  102295:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  10229a:	e9 f4 05 00 00       	jmp    102893 <__alltraps>

0010229f <vector129>:
.globl vector129
vector129:
  pushl $0
  10229f:	6a 00                	push   $0x0
  pushl $129
  1022a1:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  1022a6:	e9 e8 05 00 00       	jmp    102893 <__alltraps>

001022ab <vector130>:
.globl vector130
vector130:
  pushl $0
  1022ab:	6a 00                	push   $0x0
  pushl $130
  1022ad:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  1022b2:	e9 dc 05 00 00       	jmp    102893 <__alltraps>

001022b7 <vector131>:
.globl vector131
vector131:
  pushl $0
  1022b7:	6a 00                	push   $0x0
  pushl $131
  1022b9:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  1022be:	e9 d0 05 00 00       	jmp    102893 <__alltraps>

001022c3 <vector132>:
.globl vector132
vector132:
  pushl $0
  1022c3:	6a 00                	push   $0x0
  pushl $132
  1022c5:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  1022ca:	e9 c4 05 00 00       	jmp    102893 <__alltraps>

001022cf <vector133>:
.globl vector133
vector133:
  pushl $0
  1022cf:	6a 00                	push   $0x0
  pushl $133
  1022d1:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  1022d6:	e9 b8 05 00 00       	jmp    102893 <__alltraps>

001022db <vector134>:
.globl vector134
vector134:
  pushl $0
  1022db:	6a 00                	push   $0x0
  pushl $134
  1022dd:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  1022e2:	e9 ac 05 00 00       	jmp    102893 <__alltraps>

001022e7 <vector135>:
.globl vector135
vector135:
  pushl $0
  1022e7:	6a 00                	push   $0x0
  pushl $135
  1022e9:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  1022ee:	e9 a0 05 00 00       	jmp    102893 <__alltraps>

001022f3 <vector136>:
.globl vector136
vector136:
  pushl $0
  1022f3:	6a 00                	push   $0x0
  pushl $136
  1022f5:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  1022fa:	e9 94 05 00 00       	jmp    102893 <__alltraps>

001022ff <vector137>:
.globl vector137
vector137:
  pushl $0
  1022ff:	6a 00                	push   $0x0
  pushl $137
  102301:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  102306:	e9 88 05 00 00       	jmp    102893 <__alltraps>

0010230b <vector138>:
.globl vector138
vector138:
  pushl $0
  10230b:	6a 00                	push   $0x0
  pushl $138
  10230d:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  102312:	e9 7c 05 00 00       	jmp    102893 <__alltraps>

00102317 <vector139>:
.globl vector139
vector139:
  pushl $0
  102317:	6a 00                	push   $0x0
  pushl $139
  102319:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  10231e:	e9 70 05 00 00       	jmp    102893 <__alltraps>

00102323 <vector140>:
.globl vector140
vector140:
  pushl $0
  102323:	6a 00                	push   $0x0
  pushl $140
  102325:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  10232a:	e9 64 05 00 00       	jmp    102893 <__alltraps>

0010232f <vector141>:
.globl vector141
vector141:
  pushl $0
  10232f:	6a 00                	push   $0x0
  pushl $141
  102331:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  102336:	e9 58 05 00 00       	jmp    102893 <__alltraps>

0010233b <vector142>:
.globl vector142
vector142:
  pushl $0
  10233b:	6a 00                	push   $0x0
  pushl $142
  10233d:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  102342:	e9 4c 05 00 00       	jmp    102893 <__alltraps>

00102347 <vector143>:
.globl vector143
vector143:
  pushl $0
  102347:	6a 00                	push   $0x0
  pushl $143
  102349:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  10234e:	e9 40 05 00 00       	jmp    102893 <__alltraps>

00102353 <vector144>:
.globl vector144
vector144:
  pushl $0
  102353:	6a 00                	push   $0x0
  pushl $144
  102355:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  10235a:	e9 34 05 00 00       	jmp    102893 <__alltraps>

0010235f <vector145>:
.globl vector145
vector145:
  pushl $0
  10235f:	6a 00                	push   $0x0
  pushl $145
  102361:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  102366:	e9 28 05 00 00       	jmp    102893 <__alltraps>

0010236b <vector146>:
.globl vector146
vector146:
  pushl $0
  10236b:	6a 00                	push   $0x0
  pushl $146
  10236d:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  102372:	e9 1c 05 00 00       	jmp    102893 <__alltraps>

00102377 <vector147>:
.globl vector147
vector147:
  pushl $0
  102377:	6a 00                	push   $0x0
  pushl $147
  102379:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  10237e:	e9 10 05 00 00       	jmp    102893 <__alltraps>

00102383 <vector148>:
.globl vector148
vector148:
  pushl $0
  102383:	6a 00                	push   $0x0
  pushl $148
  102385:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  10238a:	e9 04 05 00 00       	jmp    102893 <__alltraps>

0010238f <vector149>:
.globl vector149
vector149:
  pushl $0
  10238f:	6a 00                	push   $0x0
  pushl $149
  102391:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  102396:	e9 f8 04 00 00       	jmp    102893 <__alltraps>

0010239b <vector150>:
.globl vector150
vector150:
  pushl $0
  10239b:	6a 00                	push   $0x0
  pushl $150
  10239d:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  1023a2:	e9 ec 04 00 00       	jmp    102893 <__alltraps>

001023a7 <vector151>:
.globl vector151
vector151:
  pushl $0
  1023a7:	6a 00                	push   $0x0
  pushl $151
  1023a9:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  1023ae:	e9 e0 04 00 00       	jmp    102893 <__alltraps>

001023b3 <vector152>:
.globl vector152
vector152:
  pushl $0
  1023b3:	6a 00                	push   $0x0
  pushl $152
  1023b5:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  1023ba:	e9 d4 04 00 00       	jmp    102893 <__alltraps>

001023bf <vector153>:
.globl vector153
vector153:
  pushl $0
  1023bf:	6a 00                	push   $0x0
  pushl $153
  1023c1:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  1023c6:	e9 c8 04 00 00       	jmp    102893 <__alltraps>

001023cb <vector154>:
.globl vector154
vector154:
  pushl $0
  1023cb:	6a 00                	push   $0x0
  pushl $154
  1023cd:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  1023d2:	e9 bc 04 00 00       	jmp    102893 <__alltraps>

001023d7 <vector155>:
.globl vector155
vector155:
  pushl $0
  1023d7:	6a 00                	push   $0x0
  pushl $155
  1023d9:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  1023de:	e9 b0 04 00 00       	jmp    102893 <__alltraps>

001023e3 <vector156>:
.globl vector156
vector156:
  pushl $0
  1023e3:	6a 00                	push   $0x0
  pushl $156
  1023e5:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  1023ea:	e9 a4 04 00 00       	jmp    102893 <__alltraps>

001023ef <vector157>:
.globl vector157
vector157:
  pushl $0
  1023ef:	6a 00                	push   $0x0
  pushl $157
  1023f1:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  1023f6:	e9 98 04 00 00       	jmp    102893 <__alltraps>

001023fb <vector158>:
.globl vector158
vector158:
  pushl $0
  1023fb:	6a 00                	push   $0x0
  pushl $158
  1023fd:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  102402:	e9 8c 04 00 00       	jmp    102893 <__alltraps>

00102407 <vector159>:
.globl vector159
vector159:
  pushl $0
  102407:	6a 00                	push   $0x0
  pushl $159
  102409:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  10240e:	e9 80 04 00 00       	jmp    102893 <__alltraps>

00102413 <vector160>:
.globl vector160
vector160:
  pushl $0
  102413:	6a 00                	push   $0x0
  pushl $160
  102415:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  10241a:	e9 74 04 00 00       	jmp    102893 <__alltraps>

0010241f <vector161>:
.globl vector161
vector161:
  pushl $0
  10241f:	6a 00                	push   $0x0
  pushl $161
  102421:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  102426:	e9 68 04 00 00       	jmp    102893 <__alltraps>

0010242b <vector162>:
.globl vector162
vector162:
  pushl $0
  10242b:	6a 00                	push   $0x0
  pushl $162
  10242d:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  102432:	e9 5c 04 00 00       	jmp    102893 <__alltraps>

00102437 <vector163>:
.globl vector163
vector163:
  pushl $0
  102437:	6a 00                	push   $0x0
  pushl $163
  102439:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  10243e:	e9 50 04 00 00       	jmp    102893 <__alltraps>

00102443 <vector164>:
.globl vector164
vector164:
  pushl $0
  102443:	6a 00                	push   $0x0
  pushl $164
  102445:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  10244a:	e9 44 04 00 00       	jmp    102893 <__alltraps>

0010244f <vector165>:
.globl vector165
vector165:
  pushl $0
  10244f:	6a 00                	push   $0x0
  pushl $165
  102451:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  102456:	e9 38 04 00 00       	jmp    102893 <__alltraps>

0010245b <vector166>:
.globl vector166
vector166:
  pushl $0
  10245b:	6a 00                	push   $0x0
  pushl $166
  10245d:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  102462:	e9 2c 04 00 00       	jmp    102893 <__alltraps>

00102467 <vector167>:
.globl vector167
vector167:
  pushl $0
  102467:	6a 00                	push   $0x0
  pushl $167
  102469:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  10246e:	e9 20 04 00 00       	jmp    102893 <__alltraps>

00102473 <vector168>:
.globl vector168
vector168:
  pushl $0
  102473:	6a 00                	push   $0x0
  pushl $168
  102475:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  10247a:	e9 14 04 00 00       	jmp    102893 <__alltraps>

0010247f <vector169>:
.globl vector169
vector169:
  pushl $0
  10247f:	6a 00                	push   $0x0
  pushl $169
  102481:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  102486:	e9 08 04 00 00       	jmp    102893 <__alltraps>

0010248b <vector170>:
.globl vector170
vector170:
  pushl $0
  10248b:	6a 00                	push   $0x0
  pushl $170
  10248d:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  102492:	e9 fc 03 00 00       	jmp    102893 <__alltraps>

00102497 <vector171>:
.globl vector171
vector171:
  pushl $0
  102497:	6a 00                	push   $0x0
  pushl $171
  102499:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  10249e:	e9 f0 03 00 00       	jmp    102893 <__alltraps>

001024a3 <vector172>:
.globl vector172
vector172:
  pushl $0
  1024a3:	6a 00                	push   $0x0
  pushl $172
  1024a5:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  1024aa:	e9 e4 03 00 00       	jmp    102893 <__alltraps>

001024af <vector173>:
.globl vector173
vector173:
  pushl $0
  1024af:	6a 00                	push   $0x0
  pushl $173
  1024b1:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  1024b6:	e9 d8 03 00 00       	jmp    102893 <__alltraps>

001024bb <vector174>:
.globl vector174
vector174:
  pushl $0
  1024bb:	6a 00                	push   $0x0
  pushl $174
  1024bd:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  1024c2:	e9 cc 03 00 00       	jmp    102893 <__alltraps>

001024c7 <vector175>:
.globl vector175
vector175:
  pushl $0
  1024c7:	6a 00                	push   $0x0
  pushl $175
  1024c9:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  1024ce:	e9 c0 03 00 00       	jmp    102893 <__alltraps>

001024d3 <vector176>:
.globl vector176
vector176:
  pushl $0
  1024d3:	6a 00                	push   $0x0
  pushl $176
  1024d5:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  1024da:	e9 b4 03 00 00       	jmp    102893 <__alltraps>

001024df <vector177>:
.globl vector177
vector177:
  pushl $0
  1024df:	6a 00                	push   $0x0
  pushl $177
  1024e1:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  1024e6:	e9 a8 03 00 00       	jmp    102893 <__alltraps>

001024eb <vector178>:
.globl vector178
vector178:
  pushl $0
  1024eb:	6a 00                	push   $0x0
  pushl $178
  1024ed:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  1024f2:	e9 9c 03 00 00       	jmp    102893 <__alltraps>

001024f7 <vector179>:
.globl vector179
vector179:
  pushl $0
  1024f7:	6a 00                	push   $0x0
  pushl $179
  1024f9:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  1024fe:	e9 90 03 00 00       	jmp    102893 <__alltraps>

00102503 <vector180>:
.globl vector180
vector180:
  pushl $0
  102503:	6a 00                	push   $0x0
  pushl $180
  102505:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  10250a:	e9 84 03 00 00       	jmp    102893 <__alltraps>

0010250f <vector181>:
.globl vector181
vector181:
  pushl $0
  10250f:	6a 00                	push   $0x0
  pushl $181
  102511:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  102516:	e9 78 03 00 00       	jmp    102893 <__alltraps>

0010251b <vector182>:
.globl vector182
vector182:
  pushl $0
  10251b:	6a 00                	push   $0x0
  pushl $182
  10251d:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  102522:	e9 6c 03 00 00       	jmp    102893 <__alltraps>

00102527 <vector183>:
.globl vector183
vector183:
  pushl $0
  102527:	6a 00                	push   $0x0
  pushl $183
  102529:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  10252e:	e9 60 03 00 00       	jmp    102893 <__alltraps>

00102533 <vector184>:
.globl vector184
vector184:
  pushl $0
  102533:	6a 00                	push   $0x0
  pushl $184
  102535:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  10253a:	e9 54 03 00 00       	jmp    102893 <__alltraps>

0010253f <vector185>:
.globl vector185
vector185:
  pushl $0
  10253f:	6a 00                	push   $0x0
  pushl $185
  102541:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  102546:	e9 48 03 00 00       	jmp    102893 <__alltraps>

0010254b <vector186>:
.globl vector186
vector186:
  pushl $0
  10254b:	6a 00                	push   $0x0
  pushl $186
  10254d:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  102552:	e9 3c 03 00 00       	jmp    102893 <__alltraps>

00102557 <vector187>:
.globl vector187
vector187:
  pushl $0
  102557:	6a 00                	push   $0x0
  pushl $187
  102559:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  10255e:	e9 30 03 00 00       	jmp    102893 <__alltraps>

00102563 <vector188>:
.globl vector188
vector188:
  pushl $0
  102563:	6a 00                	push   $0x0
  pushl $188
  102565:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  10256a:	e9 24 03 00 00       	jmp    102893 <__alltraps>

0010256f <vector189>:
.globl vector189
vector189:
  pushl $0
  10256f:	6a 00                	push   $0x0
  pushl $189
  102571:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  102576:	e9 18 03 00 00       	jmp    102893 <__alltraps>

0010257b <vector190>:
.globl vector190
vector190:
  pushl $0
  10257b:	6a 00                	push   $0x0
  pushl $190
  10257d:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  102582:	e9 0c 03 00 00       	jmp    102893 <__alltraps>

00102587 <vector191>:
.globl vector191
vector191:
  pushl $0
  102587:	6a 00                	push   $0x0
  pushl $191
  102589:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  10258e:	e9 00 03 00 00       	jmp    102893 <__alltraps>

00102593 <vector192>:
.globl vector192
vector192:
  pushl $0
  102593:	6a 00                	push   $0x0
  pushl $192
  102595:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  10259a:	e9 f4 02 00 00       	jmp    102893 <__alltraps>

0010259f <vector193>:
.globl vector193
vector193:
  pushl $0
  10259f:	6a 00                	push   $0x0
  pushl $193
  1025a1:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  1025a6:	e9 e8 02 00 00       	jmp    102893 <__alltraps>

001025ab <vector194>:
.globl vector194
vector194:
  pushl $0
  1025ab:	6a 00                	push   $0x0
  pushl $194
  1025ad:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  1025b2:	e9 dc 02 00 00       	jmp    102893 <__alltraps>

001025b7 <vector195>:
.globl vector195
vector195:
  pushl $0
  1025b7:	6a 00                	push   $0x0
  pushl $195
  1025b9:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  1025be:	e9 d0 02 00 00       	jmp    102893 <__alltraps>

001025c3 <vector196>:
.globl vector196
vector196:
  pushl $0
  1025c3:	6a 00                	push   $0x0
  pushl $196
  1025c5:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  1025ca:	e9 c4 02 00 00       	jmp    102893 <__alltraps>

001025cf <vector197>:
.globl vector197
vector197:
  pushl $0
  1025cf:	6a 00                	push   $0x0
  pushl $197
  1025d1:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  1025d6:	e9 b8 02 00 00       	jmp    102893 <__alltraps>

001025db <vector198>:
.globl vector198
vector198:
  pushl $0
  1025db:	6a 00                	push   $0x0
  pushl $198
  1025dd:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  1025e2:	e9 ac 02 00 00       	jmp    102893 <__alltraps>

001025e7 <vector199>:
.globl vector199
vector199:
  pushl $0
  1025e7:	6a 00                	push   $0x0
  pushl $199
  1025e9:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  1025ee:	e9 a0 02 00 00       	jmp    102893 <__alltraps>

001025f3 <vector200>:
.globl vector200
vector200:
  pushl $0
  1025f3:	6a 00                	push   $0x0
  pushl $200
  1025f5:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  1025fa:	e9 94 02 00 00       	jmp    102893 <__alltraps>

001025ff <vector201>:
.globl vector201
vector201:
  pushl $0
  1025ff:	6a 00                	push   $0x0
  pushl $201
  102601:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  102606:	e9 88 02 00 00       	jmp    102893 <__alltraps>

0010260b <vector202>:
.globl vector202
vector202:
  pushl $0
  10260b:	6a 00                	push   $0x0
  pushl $202
  10260d:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  102612:	e9 7c 02 00 00       	jmp    102893 <__alltraps>

00102617 <vector203>:
.globl vector203
vector203:
  pushl $0
  102617:	6a 00                	push   $0x0
  pushl $203
  102619:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  10261e:	e9 70 02 00 00       	jmp    102893 <__alltraps>

00102623 <vector204>:
.globl vector204
vector204:
  pushl $0
  102623:	6a 00                	push   $0x0
  pushl $204
  102625:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  10262a:	e9 64 02 00 00       	jmp    102893 <__alltraps>

0010262f <vector205>:
.globl vector205
vector205:
  pushl $0
  10262f:	6a 00                	push   $0x0
  pushl $205
  102631:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  102636:	e9 58 02 00 00       	jmp    102893 <__alltraps>

0010263b <vector206>:
.globl vector206
vector206:
  pushl $0
  10263b:	6a 00                	push   $0x0
  pushl $206
  10263d:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  102642:	e9 4c 02 00 00       	jmp    102893 <__alltraps>

00102647 <vector207>:
.globl vector207
vector207:
  pushl $0
  102647:	6a 00                	push   $0x0
  pushl $207
  102649:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  10264e:	e9 40 02 00 00       	jmp    102893 <__alltraps>

00102653 <vector208>:
.globl vector208
vector208:
  pushl $0
  102653:	6a 00                	push   $0x0
  pushl $208
  102655:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  10265a:	e9 34 02 00 00       	jmp    102893 <__alltraps>

0010265f <vector209>:
.globl vector209
vector209:
  pushl $0
  10265f:	6a 00                	push   $0x0
  pushl $209
  102661:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  102666:	e9 28 02 00 00       	jmp    102893 <__alltraps>

0010266b <vector210>:
.globl vector210
vector210:
  pushl $0
  10266b:	6a 00                	push   $0x0
  pushl $210
  10266d:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  102672:	e9 1c 02 00 00       	jmp    102893 <__alltraps>

00102677 <vector211>:
.globl vector211
vector211:
  pushl $0
  102677:	6a 00                	push   $0x0
  pushl $211
  102679:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  10267e:	e9 10 02 00 00       	jmp    102893 <__alltraps>

00102683 <vector212>:
.globl vector212
vector212:
  pushl $0
  102683:	6a 00                	push   $0x0
  pushl $212
  102685:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  10268a:	e9 04 02 00 00       	jmp    102893 <__alltraps>

0010268f <vector213>:
.globl vector213
vector213:
  pushl $0
  10268f:	6a 00                	push   $0x0
  pushl $213
  102691:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  102696:	e9 f8 01 00 00       	jmp    102893 <__alltraps>

0010269b <vector214>:
.globl vector214
vector214:
  pushl $0
  10269b:	6a 00                	push   $0x0
  pushl $214
  10269d:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  1026a2:	e9 ec 01 00 00       	jmp    102893 <__alltraps>

001026a7 <vector215>:
.globl vector215
vector215:
  pushl $0
  1026a7:	6a 00                	push   $0x0
  pushl $215
  1026a9:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  1026ae:	e9 e0 01 00 00       	jmp    102893 <__alltraps>

001026b3 <vector216>:
.globl vector216
vector216:
  pushl $0
  1026b3:	6a 00                	push   $0x0
  pushl $216
  1026b5:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  1026ba:	e9 d4 01 00 00       	jmp    102893 <__alltraps>

001026bf <vector217>:
.globl vector217
vector217:
  pushl $0
  1026bf:	6a 00                	push   $0x0
  pushl $217
  1026c1:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  1026c6:	e9 c8 01 00 00       	jmp    102893 <__alltraps>

001026cb <vector218>:
.globl vector218
vector218:
  pushl $0
  1026cb:	6a 00                	push   $0x0
  pushl $218
  1026cd:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  1026d2:	e9 bc 01 00 00       	jmp    102893 <__alltraps>

001026d7 <vector219>:
.globl vector219
vector219:
  pushl $0
  1026d7:	6a 00                	push   $0x0
  pushl $219
  1026d9:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  1026de:	e9 b0 01 00 00       	jmp    102893 <__alltraps>

001026e3 <vector220>:
.globl vector220
vector220:
  pushl $0
  1026e3:	6a 00                	push   $0x0
  pushl $220
  1026e5:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  1026ea:	e9 a4 01 00 00       	jmp    102893 <__alltraps>

001026ef <vector221>:
.globl vector221
vector221:
  pushl $0
  1026ef:	6a 00                	push   $0x0
  pushl $221
  1026f1:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  1026f6:	e9 98 01 00 00       	jmp    102893 <__alltraps>

001026fb <vector222>:
.globl vector222
vector222:
  pushl $0
  1026fb:	6a 00                	push   $0x0
  pushl $222
  1026fd:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  102702:	e9 8c 01 00 00       	jmp    102893 <__alltraps>

00102707 <vector223>:
.globl vector223
vector223:
  pushl $0
  102707:	6a 00                	push   $0x0
  pushl $223
  102709:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  10270e:	e9 80 01 00 00       	jmp    102893 <__alltraps>

00102713 <vector224>:
.globl vector224
vector224:
  pushl $0
  102713:	6a 00                	push   $0x0
  pushl $224
  102715:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  10271a:	e9 74 01 00 00       	jmp    102893 <__alltraps>

0010271f <vector225>:
.globl vector225
vector225:
  pushl $0
  10271f:	6a 00                	push   $0x0
  pushl $225
  102721:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  102726:	e9 68 01 00 00       	jmp    102893 <__alltraps>

0010272b <vector226>:
.globl vector226
vector226:
  pushl $0
  10272b:	6a 00                	push   $0x0
  pushl $226
  10272d:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  102732:	e9 5c 01 00 00       	jmp    102893 <__alltraps>

00102737 <vector227>:
.globl vector227
vector227:
  pushl $0
  102737:	6a 00                	push   $0x0
  pushl $227
  102739:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  10273e:	e9 50 01 00 00       	jmp    102893 <__alltraps>

00102743 <vector228>:
.globl vector228
vector228:
  pushl $0
  102743:	6a 00                	push   $0x0
  pushl $228
  102745:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  10274a:	e9 44 01 00 00       	jmp    102893 <__alltraps>

0010274f <vector229>:
.globl vector229
vector229:
  pushl $0
  10274f:	6a 00                	push   $0x0
  pushl $229
  102751:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  102756:	e9 38 01 00 00       	jmp    102893 <__alltraps>

0010275b <vector230>:
.globl vector230
vector230:
  pushl $0
  10275b:	6a 00                	push   $0x0
  pushl $230
  10275d:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  102762:	e9 2c 01 00 00       	jmp    102893 <__alltraps>

00102767 <vector231>:
.globl vector231
vector231:
  pushl $0
  102767:	6a 00                	push   $0x0
  pushl $231
  102769:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  10276e:	e9 20 01 00 00       	jmp    102893 <__alltraps>

00102773 <vector232>:
.globl vector232
vector232:
  pushl $0
  102773:	6a 00                	push   $0x0
  pushl $232
  102775:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  10277a:	e9 14 01 00 00       	jmp    102893 <__alltraps>

0010277f <vector233>:
.globl vector233
vector233:
  pushl $0
  10277f:	6a 00                	push   $0x0
  pushl $233
  102781:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  102786:	e9 08 01 00 00       	jmp    102893 <__alltraps>

0010278b <vector234>:
.globl vector234
vector234:
  pushl $0
  10278b:	6a 00                	push   $0x0
  pushl $234
  10278d:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  102792:	e9 fc 00 00 00       	jmp    102893 <__alltraps>

00102797 <vector235>:
.globl vector235
vector235:
  pushl $0
  102797:	6a 00                	push   $0x0
  pushl $235
  102799:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  10279e:	e9 f0 00 00 00       	jmp    102893 <__alltraps>

001027a3 <vector236>:
.globl vector236
vector236:
  pushl $0
  1027a3:	6a 00                	push   $0x0
  pushl $236
  1027a5:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  1027aa:	e9 e4 00 00 00       	jmp    102893 <__alltraps>

001027af <vector237>:
.globl vector237
vector237:
  pushl $0
  1027af:	6a 00                	push   $0x0
  pushl $237
  1027b1:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  1027b6:	e9 d8 00 00 00       	jmp    102893 <__alltraps>

001027bb <vector238>:
.globl vector238
vector238:
  pushl $0
  1027bb:	6a 00                	push   $0x0
  pushl $238
  1027bd:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  1027c2:	e9 cc 00 00 00       	jmp    102893 <__alltraps>

001027c7 <vector239>:
.globl vector239
vector239:
  pushl $0
  1027c7:	6a 00                	push   $0x0
  pushl $239
  1027c9:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  1027ce:	e9 c0 00 00 00       	jmp    102893 <__alltraps>

001027d3 <vector240>:
.globl vector240
vector240:
  pushl $0
  1027d3:	6a 00                	push   $0x0
  pushl $240
  1027d5:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  1027da:	e9 b4 00 00 00       	jmp    102893 <__alltraps>

001027df <vector241>:
.globl vector241
vector241:
  pushl $0
  1027df:	6a 00                	push   $0x0
  pushl $241
  1027e1:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  1027e6:	e9 a8 00 00 00       	jmp    102893 <__alltraps>

001027eb <vector242>:
.globl vector242
vector242:
  pushl $0
  1027eb:	6a 00                	push   $0x0
  pushl $242
  1027ed:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  1027f2:	e9 9c 00 00 00       	jmp    102893 <__alltraps>

001027f7 <vector243>:
.globl vector243
vector243:
  pushl $0
  1027f7:	6a 00                	push   $0x0
  pushl $243
  1027f9:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  1027fe:	e9 90 00 00 00       	jmp    102893 <__alltraps>

00102803 <vector244>:
.globl vector244
vector244:
  pushl $0
  102803:	6a 00                	push   $0x0
  pushl $244
  102805:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  10280a:	e9 84 00 00 00       	jmp    102893 <__alltraps>

0010280f <vector245>:
.globl vector245
vector245:
  pushl $0
  10280f:	6a 00                	push   $0x0
  pushl $245
  102811:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  102816:	e9 78 00 00 00       	jmp    102893 <__alltraps>

0010281b <vector246>:
.globl vector246
vector246:
  pushl $0
  10281b:	6a 00                	push   $0x0
  pushl $246
  10281d:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  102822:	e9 6c 00 00 00       	jmp    102893 <__alltraps>

00102827 <vector247>:
.globl vector247
vector247:
  pushl $0
  102827:	6a 00                	push   $0x0
  pushl $247
  102829:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  10282e:	e9 60 00 00 00       	jmp    102893 <__alltraps>

00102833 <vector248>:
.globl vector248
vector248:
  pushl $0
  102833:	6a 00                	push   $0x0
  pushl $248
  102835:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  10283a:	e9 54 00 00 00       	jmp    102893 <__alltraps>

0010283f <vector249>:
.globl vector249
vector249:
  pushl $0
  10283f:	6a 00                	push   $0x0
  pushl $249
  102841:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  102846:	e9 48 00 00 00       	jmp    102893 <__alltraps>

0010284b <vector250>:
.globl vector250
vector250:
  pushl $0
  10284b:	6a 00                	push   $0x0
  pushl $250
  10284d:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  102852:	e9 3c 00 00 00       	jmp    102893 <__alltraps>

00102857 <vector251>:
.globl vector251
vector251:
  pushl $0
  102857:	6a 00                	push   $0x0
  pushl $251
  102859:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  10285e:	e9 30 00 00 00       	jmp    102893 <__alltraps>

00102863 <vector252>:
.globl vector252
vector252:
  pushl $0
  102863:	6a 00                	push   $0x0
  pushl $252
  102865:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  10286a:	e9 24 00 00 00       	jmp    102893 <__alltraps>

0010286f <vector253>:
.globl vector253
vector253:
  pushl $0
  10286f:	6a 00                	push   $0x0
  pushl $253
  102871:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  102876:	e9 18 00 00 00       	jmp    102893 <__alltraps>

0010287b <vector254>:
.globl vector254
vector254:
  pushl $0
  10287b:	6a 00                	push   $0x0
  pushl $254
  10287d:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  102882:	e9 0c 00 00 00       	jmp    102893 <__alltraps>

00102887 <vector255>:
.globl vector255
vector255:
  pushl $0
  102887:	6a 00                	push   $0x0
  pushl $255
  102889:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  10288e:	e9 00 00 00 00       	jmp    102893 <__alltraps>

00102893 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  102893:	1e                   	push   %ds
    pushl %es
  102894:	06                   	push   %es
    pushl %fs
  102895:	0f a0                	push   %fs
    pushl %gs
  102897:	0f a8                	push   %gs
    pushal
  102899:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  10289a:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  10289f:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  1028a1:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  1028a3:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  1028a4:	e8 65 f5 ff ff       	call   101e0e <trap>

    # pop the pushed stack pointer
    popl %esp
  1028a9:	5c                   	pop    %esp

001028aa <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  1028aa:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  1028ab:	0f a9                	pop    %gs
    popl %fs
  1028ad:	0f a1                	pop    %fs
    popl %es
  1028af:	07                   	pop    %es
    popl %ds
  1028b0:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  1028b1:	83 c4 08             	add    $0x8,%esp
    iret
  1028b4:	cf                   	iret   

001028b5 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  1028b5:	55                   	push   %ebp
  1028b6:	89 e5                	mov    %esp,%ebp
    return page - pages;
  1028b8:	8b 55 08             	mov    0x8(%ebp),%edx
  1028bb:	a1 18 af 11 00       	mov    0x11af18,%eax
  1028c0:	29 c2                	sub    %eax,%edx
  1028c2:	89 d0                	mov    %edx,%eax
  1028c4:	c1 f8 02             	sar    $0x2,%eax
  1028c7:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  1028cd:	5d                   	pop    %ebp
  1028ce:	c3                   	ret    

001028cf <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  1028cf:	55                   	push   %ebp
  1028d0:	89 e5                	mov    %esp,%ebp
  1028d2:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  1028d5:	8b 45 08             	mov    0x8(%ebp),%eax
  1028d8:	89 04 24             	mov    %eax,(%esp)
  1028db:	e8 d5 ff ff ff       	call   1028b5 <page2ppn>
  1028e0:	c1 e0 0c             	shl    $0xc,%eax
}
  1028e3:	c9                   	leave  
  1028e4:	c3                   	ret    

001028e5 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
  1028e5:	55                   	push   %ebp
  1028e6:	89 e5                	mov    %esp,%ebp
  1028e8:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
  1028eb:	8b 45 08             	mov    0x8(%ebp),%eax
  1028ee:	c1 e8 0c             	shr    $0xc,%eax
  1028f1:	89 c2                	mov    %eax,%edx
  1028f3:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  1028f8:	39 c2                	cmp    %eax,%edx
  1028fa:	72 1c                	jb     102918 <pa2page+0x33>
        panic("pa2page called with invalid pa");
  1028fc:	c7 44 24 08 30 65 10 	movl   $0x106530,0x8(%esp)
  102903:	00 
  102904:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  10290b:	00 
  10290c:	c7 04 24 4f 65 10 00 	movl   $0x10654f,(%esp)
  102913:	e8 d1 da ff ff       	call   1003e9 <__panic>
    }
    return &pages[PPN(pa)];
  102918:	8b 0d 18 af 11 00    	mov    0x11af18,%ecx
  10291e:	8b 45 08             	mov    0x8(%ebp),%eax
  102921:	c1 e8 0c             	shr    $0xc,%eax
  102924:	89 c2                	mov    %eax,%edx
  102926:	89 d0                	mov    %edx,%eax
  102928:	c1 e0 02             	shl    $0x2,%eax
  10292b:	01 d0                	add    %edx,%eax
  10292d:	c1 e0 02             	shl    $0x2,%eax
  102930:	01 c8                	add    %ecx,%eax
}
  102932:	c9                   	leave  
  102933:	c3                   	ret    

00102934 <page2kva>:

static inline void *
page2kva(struct Page *page) {
  102934:	55                   	push   %ebp
  102935:	89 e5                	mov    %esp,%ebp
  102937:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
  10293a:	8b 45 08             	mov    0x8(%ebp),%eax
  10293d:	89 04 24             	mov    %eax,(%esp)
  102940:	e8 8a ff ff ff       	call   1028cf <page2pa>
  102945:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102948:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10294b:	c1 e8 0c             	shr    $0xc,%eax
  10294e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102951:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  102956:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  102959:	72 23                	jb     10297e <page2kva+0x4a>
  10295b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10295e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102962:	c7 44 24 08 60 65 10 	movl   $0x106560,0x8(%esp)
  102969:	00 
  10296a:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  102971:	00 
  102972:	c7 04 24 4f 65 10 00 	movl   $0x10654f,(%esp)
  102979:	e8 6b da ff ff       	call   1003e9 <__panic>
  10297e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  102981:	c9                   	leave  
  102982:	c3                   	ret    

00102983 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
  102983:	55                   	push   %ebp
  102984:	89 e5                	mov    %esp,%ebp
  102986:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
  102989:	8b 45 08             	mov    0x8(%ebp),%eax
  10298c:	83 e0 01             	and    $0x1,%eax
  10298f:	85 c0                	test   %eax,%eax
  102991:	75 1c                	jne    1029af <pte2page+0x2c>
        panic("pte2page called with invalid pte");
  102993:	c7 44 24 08 84 65 10 	movl   $0x106584,0x8(%esp)
  10299a:	00 
  10299b:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  1029a2:	00 
  1029a3:	c7 04 24 4f 65 10 00 	movl   $0x10654f,(%esp)
  1029aa:	e8 3a da ff ff       	call   1003e9 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
  1029af:	8b 45 08             	mov    0x8(%ebp),%eax
  1029b2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1029b7:	89 04 24             	mov    %eax,(%esp)
  1029ba:	e8 26 ff ff ff       	call   1028e5 <pa2page>
}
  1029bf:	c9                   	leave  
  1029c0:	c3                   	ret    

001029c1 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
  1029c1:	55                   	push   %ebp
  1029c2:	89 e5                	mov    %esp,%ebp
  1029c4:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
  1029c7:	8b 45 08             	mov    0x8(%ebp),%eax
  1029ca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1029cf:	89 04 24             	mov    %eax,(%esp)
  1029d2:	e8 0e ff ff ff       	call   1028e5 <pa2page>
}
  1029d7:	c9                   	leave  
  1029d8:	c3                   	ret    

001029d9 <page_ref>:

static inline int
page_ref(struct Page *page) {
  1029d9:	55                   	push   %ebp
  1029da:	89 e5                	mov    %esp,%ebp
    return page->ref;
  1029dc:	8b 45 08             	mov    0x8(%ebp),%eax
  1029df:	8b 00                	mov    (%eax),%eax
}
  1029e1:	5d                   	pop    %ebp
  1029e2:	c3                   	ret    

001029e3 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  1029e3:	55                   	push   %ebp
  1029e4:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  1029e6:	8b 45 08             	mov    0x8(%ebp),%eax
  1029e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  1029ec:	89 10                	mov    %edx,(%eax)
}
  1029ee:	5d                   	pop    %ebp
  1029ef:	c3                   	ret    

001029f0 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
  1029f0:	55                   	push   %ebp
  1029f1:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
  1029f3:	8b 45 08             	mov    0x8(%ebp),%eax
  1029f6:	8b 00                	mov    (%eax),%eax
  1029f8:	8d 50 01             	lea    0x1(%eax),%edx
  1029fb:	8b 45 08             	mov    0x8(%ebp),%eax
  1029fe:	89 10                	mov    %edx,(%eax)
    return page->ref;
  102a00:	8b 45 08             	mov    0x8(%ebp),%eax
  102a03:	8b 00                	mov    (%eax),%eax
}
  102a05:	5d                   	pop    %ebp
  102a06:	c3                   	ret    

00102a07 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
  102a07:	55                   	push   %ebp
  102a08:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
  102a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  102a0d:	8b 00                	mov    (%eax),%eax
  102a0f:	8d 50 ff             	lea    -0x1(%eax),%edx
  102a12:	8b 45 08             	mov    0x8(%ebp),%eax
  102a15:	89 10                	mov    %edx,(%eax)
    return page->ref;
  102a17:	8b 45 08             	mov    0x8(%ebp),%eax
  102a1a:	8b 00                	mov    (%eax),%eax
}
  102a1c:	5d                   	pop    %ebp
  102a1d:	c3                   	ret    

00102a1e <__intr_save>:
__intr_save(void) {
  102a1e:	55                   	push   %ebp
  102a1f:	89 e5                	mov    %esp,%ebp
  102a21:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  102a24:	9c                   	pushf  
  102a25:	58                   	pop    %eax
  102a26:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  102a29:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  102a2c:	25 00 02 00 00       	and    $0x200,%eax
  102a31:	85 c0                	test   %eax,%eax
  102a33:	74 0c                	je     102a41 <__intr_save+0x23>
        intr_disable();
  102a35:	e8 57 ee ff ff       	call   101891 <intr_disable>
        return 1;
  102a3a:	b8 01 00 00 00       	mov    $0x1,%eax
  102a3f:	eb 05                	jmp    102a46 <__intr_save+0x28>
    return 0;
  102a41:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102a46:	c9                   	leave  
  102a47:	c3                   	ret    

00102a48 <__intr_restore>:
__intr_restore(bool flag) {
  102a48:	55                   	push   %ebp
  102a49:	89 e5                	mov    %esp,%ebp
  102a4b:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  102a4e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  102a52:	74 05                	je     102a59 <__intr_restore+0x11>
        intr_enable();
  102a54:	e8 32 ee ff ff       	call   10188b <intr_enable>
}
  102a59:	c9                   	leave  
  102a5a:	c3                   	ret    

00102a5b <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  102a5b:	55                   	push   %ebp
  102a5c:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  102a5e:	8b 45 08             	mov    0x8(%ebp),%eax
  102a61:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  102a64:	b8 23 00 00 00       	mov    $0x23,%eax
  102a69:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  102a6b:	b8 23 00 00 00       	mov    $0x23,%eax
  102a70:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  102a72:	b8 10 00 00 00       	mov    $0x10,%eax
  102a77:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  102a79:	b8 10 00 00 00       	mov    $0x10,%eax
  102a7e:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  102a80:	b8 10 00 00 00       	mov    $0x10,%eax
  102a85:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  102a87:	ea 8e 2a 10 00 08 00 	ljmp   $0x8,$0x102a8e
}
  102a8e:	5d                   	pop    %ebp
  102a8f:	c3                   	ret    

00102a90 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
  102a90:	55                   	push   %ebp
  102a91:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
  102a93:	8b 45 08             	mov    0x8(%ebp),%eax
  102a96:	a3 a4 ae 11 00       	mov    %eax,0x11aea4
}
  102a9b:	5d                   	pop    %ebp
  102a9c:	c3                   	ret    

00102a9d <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  102a9d:	55                   	push   %ebp
  102a9e:	89 e5                	mov    %esp,%ebp
  102aa0:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
  102aa3:	b8 00 70 11 00       	mov    $0x117000,%eax
  102aa8:	89 04 24             	mov    %eax,(%esp)
  102aab:	e8 e0 ff ff ff       	call   102a90 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
  102ab0:	66 c7 05 a8 ae 11 00 	movw   $0x10,0x11aea8
  102ab7:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
  102ab9:	66 c7 05 28 7a 11 00 	movw   $0x68,0x117a28
  102ac0:	68 00 
  102ac2:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  102ac7:	66 a3 2a 7a 11 00    	mov    %ax,0x117a2a
  102acd:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  102ad2:	c1 e8 10             	shr    $0x10,%eax
  102ad5:	a2 2c 7a 11 00       	mov    %al,0x117a2c
  102ada:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  102ae1:	83 e0 f0             	and    $0xfffffff0,%eax
  102ae4:	83 c8 09             	or     $0x9,%eax
  102ae7:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  102aec:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  102af3:	83 e0 ef             	and    $0xffffffef,%eax
  102af6:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  102afb:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  102b02:	83 e0 9f             	and    $0xffffff9f,%eax
  102b05:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  102b0a:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  102b11:	83 c8 80             	or     $0xffffff80,%eax
  102b14:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  102b19:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102b20:	83 e0 f0             	and    $0xfffffff0,%eax
  102b23:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102b28:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102b2f:	83 e0 ef             	and    $0xffffffef,%eax
  102b32:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102b37:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102b3e:	83 e0 df             	and    $0xffffffdf,%eax
  102b41:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102b46:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102b4d:	83 c8 40             	or     $0x40,%eax
  102b50:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102b55:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102b5c:	83 e0 7f             	and    $0x7f,%eax
  102b5f:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102b64:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  102b69:	c1 e8 18             	shr    $0x18,%eax
  102b6c:	a2 2f 7a 11 00       	mov    %al,0x117a2f

    // reload all segment registers
    lgdt(&gdt_pd);
  102b71:	c7 04 24 30 7a 11 00 	movl   $0x117a30,(%esp)
  102b78:	e8 de fe ff ff       	call   102a5b <lgdt>
  102b7d:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
  102b83:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  102b87:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  102b8a:	c9                   	leave  
  102b8b:	c3                   	ret    

00102b8c <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
  102b8c:	55                   	push   %ebp
  102b8d:	89 e5                	mov    %esp,%ebp
  102b8f:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
  102b92:	c7 05 10 af 11 00 d4 	movl   $0x106ed4,0x11af10
  102b99:	6e 10 00 
    cprintf("memory management: %s\n", pmm_manager->name);
  102b9c:	a1 10 af 11 00       	mov    0x11af10,%eax
  102ba1:	8b 00                	mov    (%eax),%eax
  102ba3:	89 44 24 04          	mov    %eax,0x4(%esp)
  102ba7:	c7 04 24 b0 65 10 00 	movl   $0x1065b0,(%esp)
  102bae:	e8 df d6 ff ff       	call   100292 <cprintf>
    pmm_manager->init();
  102bb3:	a1 10 af 11 00       	mov    0x11af10,%eax
  102bb8:	8b 40 04             	mov    0x4(%eax),%eax
  102bbb:	ff d0                	call   *%eax
}
  102bbd:	c9                   	leave  
  102bbe:	c3                   	ret    

00102bbf <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
  102bbf:	55                   	push   %ebp
  102bc0:	89 e5                	mov    %esp,%ebp
  102bc2:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
  102bc5:	a1 10 af 11 00       	mov    0x11af10,%eax
  102bca:	8b 40 08             	mov    0x8(%eax),%eax
  102bcd:	8b 55 0c             	mov    0xc(%ebp),%edx
  102bd0:	89 54 24 04          	mov    %edx,0x4(%esp)
  102bd4:	8b 55 08             	mov    0x8(%ebp),%edx
  102bd7:	89 14 24             	mov    %edx,(%esp)
  102bda:	ff d0                	call   *%eax
}
  102bdc:	c9                   	leave  
  102bdd:	c3                   	ret    

00102bde <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
  102bde:	55                   	push   %ebp
  102bdf:	89 e5                	mov    %esp,%ebp
  102be1:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
  102be4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  102beb:	e8 2e fe ff ff       	call   102a1e <__intr_save>
  102bf0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
  102bf3:	a1 10 af 11 00       	mov    0x11af10,%eax
  102bf8:	8b 40 0c             	mov    0xc(%eax),%eax
  102bfb:	8b 55 08             	mov    0x8(%ebp),%edx
  102bfe:	89 14 24             	mov    %edx,(%esp)
  102c01:	ff d0                	call   *%eax
  102c03:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
  102c06:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102c09:	89 04 24             	mov    %eax,(%esp)
  102c0c:	e8 37 fe ff ff       	call   102a48 <__intr_restore>
    return page;
  102c11:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  102c14:	c9                   	leave  
  102c15:	c3                   	ret    

00102c16 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
  102c16:	55                   	push   %ebp
  102c17:	89 e5                	mov    %esp,%ebp
  102c19:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  102c1c:	e8 fd fd ff ff       	call   102a1e <__intr_save>
  102c21:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
  102c24:	a1 10 af 11 00       	mov    0x11af10,%eax
  102c29:	8b 40 10             	mov    0x10(%eax),%eax
  102c2c:	8b 55 0c             	mov    0xc(%ebp),%edx
  102c2f:	89 54 24 04          	mov    %edx,0x4(%esp)
  102c33:	8b 55 08             	mov    0x8(%ebp),%edx
  102c36:	89 14 24             	mov    %edx,(%esp)
  102c39:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
  102c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c3e:	89 04 24             	mov    %eax,(%esp)
  102c41:	e8 02 fe ff ff       	call   102a48 <__intr_restore>
}
  102c46:	c9                   	leave  
  102c47:	c3                   	ret    

00102c48 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
  102c48:	55                   	push   %ebp
  102c49:	89 e5                	mov    %esp,%ebp
  102c4b:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
  102c4e:	e8 cb fd ff ff       	call   102a1e <__intr_save>
  102c53:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
  102c56:	a1 10 af 11 00       	mov    0x11af10,%eax
  102c5b:	8b 40 14             	mov    0x14(%eax),%eax
  102c5e:	ff d0                	call   *%eax
  102c60:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
  102c63:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c66:	89 04 24             	mov    %eax,(%esp)
  102c69:	e8 da fd ff ff       	call   102a48 <__intr_restore>
    return ret;
  102c6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  102c71:	c9                   	leave  
  102c72:	c3                   	ret    

00102c73 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
  102c73:	55                   	push   %ebp
  102c74:	89 e5                	mov    %esp,%ebp
  102c76:	57                   	push   %edi
  102c77:	56                   	push   %esi
  102c78:	53                   	push   %ebx
  102c79:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
  102c7f:	c7 45 c4 00 80 00 00 	movl   $0x8000,-0x3c(%ebp)
    uint64_t maxpa = 0;
  102c86:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  102c8d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
  102c94:	c7 04 24 c7 65 10 00 	movl   $0x1065c7,(%esp)
  102c9b:	e8 f2 d5 ff ff       	call   100292 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  102ca0:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102ca7:	e9 15 01 00 00       	jmp    102dc1 <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  102cac:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102caf:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102cb2:	89 d0                	mov    %edx,%eax
  102cb4:	c1 e0 02             	shl    $0x2,%eax
  102cb7:	01 d0                	add    %edx,%eax
  102cb9:	c1 e0 02             	shl    $0x2,%eax
  102cbc:	01 c8                	add    %ecx,%eax
  102cbe:	8b 50 08             	mov    0x8(%eax),%edx
  102cc1:	8b 40 04             	mov    0x4(%eax),%eax
  102cc4:	89 45 b8             	mov    %eax,-0x48(%ebp)
  102cc7:	89 55 bc             	mov    %edx,-0x44(%ebp)
  102cca:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102ccd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102cd0:	89 d0                	mov    %edx,%eax
  102cd2:	c1 e0 02             	shl    $0x2,%eax
  102cd5:	01 d0                	add    %edx,%eax
  102cd7:	c1 e0 02             	shl    $0x2,%eax
  102cda:	01 c8                	add    %ecx,%eax
  102cdc:	8b 48 0c             	mov    0xc(%eax),%ecx
  102cdf:	8b 58 10             	mov    0x10(%eax),%ebx
  102ce2:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102ce5:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102ce8:	01 c8                	add    %ecx,%eax
  102cea:	11 da                	adc    %ebx,%edx
  102cec:	89 45 b0             	mov    %eax,-0x50(%ebp)
  102cef:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
  102cf2:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102cf5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102cf8:	89 d0                	mov    %edx,%eax
  102cfa:	c1 e0 02             	shl    $0x2,%eax
  102cfd:	01 d0                	add    %edx,%eax
  102cff:	c1 e0 02             	shl    $0x2,%eax
  102d02:	01 c8                	add    %ecx,%eax
  102d04:	83 c0 14             	add    $0x14,%eax
  102d07:	8b 00                	mov    (%eax),%eax
  102d09:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
  102d0f:	8b 45 b0             	mov    -0x50(%ebp),%eax
  102d12:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  102d15:	83 c0 ff             	add    $0xffffffff,%eax
  102d18:	83 d2 ff             	adc    $0xffffffff,%edx
  102d1b:	89 c6                	mov    %eax,%esi
  102d1d:	89 d7                	mov    %edx,%edi
  102d1f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102d22:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102d25:	89 d0                	mov    %edx,%eax
  102d27:	c1 e0 02             	shl    $0x2,%eax
  102d2a:	01 d0                	add    %edx,%eax
  102d2c:	c1 e0 02             	shl    $0x2,%eax
  102d2f:	01 c8                	add    %ecx,%eax
  102d31:	8b 48 0c             	mov    0xc(%eax),%ecx
  102d34:	8b 58 10             	mov    0x10(%eax),%ebx
  102d37:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  102d3d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  102d41:	89 74 24 14          	mov    %esi,0x14(%esp)
  102d45:	89 7c 24 18          	mov    %edi,0x18(%esp)
  102d49:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102d4c:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102d4f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102d53:	89 54 24 10          	mov    %edx,0x10(%esp)
  102d57:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  102d5b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  102d5f:	c7 04 24 d4 65 10 00 	movl   $0x1065d4,(%esp)
  102d66:	e8 27 d5 ff ff       	call   100292 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
  102d6b:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102d6e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102d71:	89 d0                	mov    %edx,%eax
  102d73:	c1 e0 02             	shl    $0x2,%eax
  102d76:	01 d0                	add    %edx,%eax
  102d78:	c1 e0 02             	shl    $0x2,%eax
  102d7b:	01 c8                	add    %ecx,%eax
  102d7d:	83 c0 14             	add    $0x14,%eax
  102d80:	8b 00                	mov    (%eax),%eax
  102d82:	83 f8 01             	cmp    $0x1,%eax
  102d85:	75 36                	jne    102dbd <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
  102d87:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102d8a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102d8d:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
  102d90:	77 2b                	ja     102dbd <page_init+0x14a>
  102d92:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
  102d95:	72 05                	jb     102d9c <page_init+0x129>
  102d97:	3b 45 b0             	cmp    -0x50(%ebp),%eax
  102d9a:	73 21                	jae    102dbd <page_init+0x14a>
  102d9c:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  102da0:	77 1b                	ja     102dbd <page_init+0x14a>
  102da2:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  102da6:	72 09                	jb     102db1 <page_init+0x13e>
  102da8:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
  102daf:	77 0c                	ja     102dbd <page_init+0x14a>
                maxpa = end;
  102db1:	8b 45 b0             	mov    -0x50(%ebp),%eax
  102db4:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  102db7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102dba:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
  102dbd:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  102dc1:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102dc4:	8b 00                	mov    (%eax),%eax
  102dc6:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  102dc9:	0f 8f dd fe ff ff    	jg     102cac <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
  102dcf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102dd3:	72 1d                	jb     102df2 <page_init+0x17f>
  102dd5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102dd9:	77 09                	ja     102de4 <page_init+0x171>
  102ddb:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
  102de2:	76 0e                	jbe    102df2 <page_init+0x17f>
        maxpa = KMEMSIZE;
  102de4:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
  102deb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
  102df2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102df5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102df8:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  102dfc:	c1 ea 0c             	shr    $0xc,%edx
  102dff:	a3 80 ae 11 00       	mov    %eax,0x11ae80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
  102e04:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
  102e0b:	b8 28 af 11 00       	mov    $0x11af28,%eax
  102e10:	8d 50 ff             	lea    -0x1(%eax),%edx
  102e13:	8b 45 ac             	mov    -0x54(%ebp),%eax
  102e16:	01 d0                	add    %edx,%eax
  102e18:	89 45 a8             	mov    %eax,-0x58(%ebp)
  102e1b:	8b 45 a8             	mov    -0x58(%ebp),%eax
  102e1e:	ba 00 00 00 00       	mov    $0x0,%edx
  102e23:	f7 75 ac             	divl   -0x54(%ebp)
  102e26:	89 d0                	mov    %edx,%eax
  102e28:	8b 55 a8             	mov    -0x58(%ebp),%edx
  102e2b:	29 c2                	sub    %eax,%edx
  102e2d:	89 d0                	mov    %edx,%eax
  102e2f:	a3 18 af 11 00       	mov    %eax,0x11af18

    for (i = 0; i < npage; i ++) {
  102e34:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102e3b:	eb 2f                	jmp    102e6c <page_init+0x1f9>
        SetPageReserved(pages + i);
  102e3d:	8b 0d 18 af 11 00    	mov    0x11af18,%ecx
  102e43:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e46:	89 d0                	mov    %edx,%eax
  102e48:	c1 e0 02             	shl    $0x2,%eax
  102e4b:	01 d0                	add    %edx,%eax
  102e4d:	c1 e0 02             	shl    $0x2,%eax
  102e50:	01 c8                	add    %ecx,%eax
  102e52:	83 c0 04             	add    $0x4,%eax
  102e55:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
  102e5c:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102e5f:	8b 45 8c             	mov    -0x74(%ebp),%eax
  102e62:	8b 55 90             	mov    -0x70(%ebp),%edx
  102e65:	0f ab 10             	bts    %edx,(%eax)
    for (i = 0; i < npage; i ++) {
  102e68:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  102e6c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e6f:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  102e74:	39 c2                	cmp    %eax,%edx
  102e76:	72 c5                	jb     102e3d <page_init+0x1ca>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
  102e78:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  102e7e:	89 d0                	mov    %edx,%eax
  102e80:	c1 e0 02             	shl    $0x2,%eax
  102e83:	01 d0                	add    %edx,%eax
  102e85:	c1 e0 02             	shl    $0x2,%eax
  102e88:	89 c2                	mov    %eax,%edx
  102e8a:	a1 18 af 11 00       	mov    0x11af18,%eax
  102e8f:	01 d0                	add    %edx,%eax
  102e91:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  102e94:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  102e97:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
  102e9a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102ea1:	e9 74 01 00 00       	jmp    10301a <page_init+0x3a7>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  102ea6:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102ea9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102eac:	89 d0                	mov    %edx,%eax
  102eae:	c1 e0 02             	shl    $0x2,%eax
  102eb1:	01 d0                	add    %edx,%eax
  102eb3:	c1 e0 02             	shl    $0x2,%eax
  102eb6:	01 c8                	add    %ecx,%eax
  102eb8:	8b 50 08             	mov    0x8(%eax),%edx
  102ebb:	8b 40 04             	mov    0x4(%eax),%eax
  102ebe:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102ec1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  102ec4:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102ec7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102eca:	89 d0                	mov    %edx,%eax
  102ecc:	c1 e0 02             	shl    $0x2,%eax
  102ecf:	01 d0                	add    %edx,%eax
  102ed1:	c1 e0 02             	shl    $0x2,%eax
  102ed4:	01 c8                	add    %ecx,%eax
  102ed6:	8b 48 0c             	mov    0xc(%eax),%ecx
  102ed9:	8b 58 10             	mov    0x10(%eax),%ebx
  102edc:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102edf:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102ee2:	01 c8                	add    %ecx,%eax
  102ee4:	11 da                	adc    %ebx,%edx
  102ee6:	89 45 c8             	mov    %eax,-0x38(%ebp)
  102ee9:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
  102eec:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102eef:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102ef2:	89 d0                	mov    %edx,%eax
  102ef4:	c1 e0 02             	shl    $0x2,%eax
  102ef7:	01 d0                	add    %edx,%eax
  102ef9:	c1 e0 02             	shl    $0x2,%eax
  102efc:	01 c8                	add    %ecx,%eax
  102efe:	83 c0 14             	add    $0x14,%eax
  102f01:	8b 00                	mov    (%eax),%eax
  102f03:	83 f8 01             	cmp    $0x1,%eax
  102f06:	0f 85 0a 01 00 00    	jne    103016 <page_init+0x3a3>
            if (begin < freemem) {
  102f0c:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102f0f:	ba 00 00 00 00       	mov    $0x0,%edx
  102f14:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  102f17:	72 17                	jb     102f30 <page_init+0x2bd>
  102f19:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  102f1c:	77 05                	ja     102f23 <page_init+0x2b0>
  102f1e:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  102f21:	76 0d                	jbe    102f30 <page_init+0x2bd>
                begin = freemem;
  102f23:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102f26:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102f29:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
  102f30:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  102f34:	72 1d                	jb     102f53 <page_init+0x2e0>
  102f36:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  102f3a:	77 09                	ja     102f45 <page_init+0x2d2>
  102f3c:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
  102f43:	76 0e                	jbe    102f53 <page_init+0x2e0>
                end = KMEMSIZE;
  102f45:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
  102f4c:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
  102f53:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102f56:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102f59:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102f5c:	0f 87 b4 00 00 00    	ja     103016 <page_init+0x3a3>
  102f62:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102f65:	72 09                	jb     102f70 <page_init+0x2fd>
  102f67:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  102f6a:	0f 83 a6 00 00 00    	jae    103016 <page_init+0x3a3>
                begin = ROUNDUP(begin, PGSIZE);
  102f70:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
  102f77:	8b 55 d0             	mov    -0x30(%ebp),%edx
  102f7a:	8b 45 9c             	mov    -0x64(%ebp),%eax
  102f7d:	01 d0                	add    %edx,%eax
  102f7f:	83 e8 01             	sub    $0x1,%eax
  102f82:	89 45 98             	mov    %eax,-0x68(%ebp)
  102f85:	8b 45 98             	mov    -0x68(%ebp),%eax
  102f88:	ba 00 00 00 00       	mov    $0x0,%edx
  102f8d:	f7 75 9c             	divl   -0x64(%ebp)
  102f90:	89 d0                	mov    %edx,%eax
  102f92:	8b 55 98             	mov    -0x68(%ebp),%edx
  102f95:	29 c2                	sub    %eax,%edx
  102f97:	89 d0                	mov    %edx,%eax
  102f99:	ba 00 00 00 00       	mov    $0x0,%edx
  102f9e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102fa1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
  102fa4:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102fa7:	89 45 94             	mov    %eax,-0x6c(%ebp)
  102faa:	8b 45 94             	mov    -0x6c(%ebp),%eax
  102fad:	ba 00 00 00 00       	mov    $0x0,%edx
  102fb2:	89 c7                	mov    %eax,%edi
  102fb4:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  102fba:	89 7d 80             	mov    %edi,-0x80(%ebp)
  102fbd:	89 d0                	mov    %edx,%eax
  102fbf:	83 e0 00             	and    $0x0,%eax
  102fc2:	89 45 84             	mov    %eax,-0x7c(%ebp)
  102fc5:	8b 45 80             	mov    -0x80(%ebp),%eax
  102fc8:	8b 55 84             	mov    -0x7c(%ebp),%edx
  102fcb:	89 45 c8             	mov    %eax,-0x38(%ebp)
  102fce:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
  102fd1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102fd4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102fd7:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102fda:	77 3a                	ja     103016 <page_init+0x3a3>
  102fdc:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102fdf:	72 05                	jb     102fe6 <page_init+0x373>
  102fe1:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  102fe4:	73 30                	jae    103016 <page_init+0x3a3>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
  102fe6:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  102fe9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  102fec:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102fef:	8b 55 cc             	mov    -0x34(%ebp),%edx
  102ff2:	29 c8                	sub    %ecx,%eax
  102ff4:	19 da                	sbb    %ebx,%edx
  102ff6:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  102ffa:	c1 ea 0c             	shr    $0xc,%edx
  102ffd:	89 c3                	mov    %eax,%ebx
  102fff:	8b 45 d0             	mov    -0x30(%ebp),%eax
  103002:	89 04 24             	mov    %eax,(%esp)
  103005:	e8 db f8 ff ff       	call   1028e5 <pa2page>
  10300a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  10300e:	89 04 24             	mov    %eax,(%esp)
  103011:	e8 a9 fb ff ff       	call   102bbf <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
  103016:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  10301a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  10301d:	8b 00                	mov    (%eax),%eax
  10301f:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  103022:	0f 8f 7e fe ff ff    	jg     102ea6 <page_init+0x233>
                }
            }
        }
    }
}
  103028:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  10302e:	5b                   	pop    %ebx
  10302f:	5e                   	pop    %esi
  103030:	5f                   	pop    %edi
  103031:	5d                   	pop    %ebp
  103032:	c3                   	ret    

00103033 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
  103033:	55                   	push   %ebp
  103034:	89 e5                	mov    %esp,%ebp
  103036:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
  103039:	8b 45 14             	mov    0x14(%ebp),%eax
  10303c:	8b 55 0c             	mov    0xc(%ebp),%edx
  10303f:	31 d0                	xor    %edx,%eax
  103041:	25 ff 0f 00 00       	and    $0xfff,%eax
  103046:	85 c0                	test   %eax,%eax
  103048:	74 24                	je     10306e <boot_map_segment+0x3b>
  10304a:	c7 44 24 0c 04 66 10 	movl   $0x106604,0xc(%esp)
  103051:	00 
  103052:	c7 44 24 08 1b 66 10 	movl   $0x10661b,0x8(%esp)
  103059:	00 
  10305a:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
  103061:	00 
  103062:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  103069:	e8 7b d3 ff ff       	call   1003e9 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
  10306e:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  103075:	8b 45 0c             	mov    0xc(%ebp),%eax
  103078:	25 ff 0f 00 00       	and    $0xfff,%eax
  10307d:	89 c2                	mov    %eax,%edx
  10307f:	8b 45 10             	mov    0x10(%ebp),%eax
  103082:	01 c2                	add    %eax,%edx
  103084:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103087:	01 d0                	add    %edx,%eax
  103089:	83 e8 01             	sub    $0x1,%eax
  10308c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10308f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103092:	ba 00 00 00 00       	mov    $0x0,%edx
  103097:	f7 75 f0             	divl   -0x10(%ebp)
  10309a:	89 d0                	mov    %edx,%eax
  10309c:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10309f:	29 c2                	sub    %eax,%edx
  1030a1:	89 d0                	mov    %edx,%eax
  1030a3:	c1 e8 0c             	shr    $0xc,%eax
  1030a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
  1030a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1030ac:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1030af:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1030b2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1030b7:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
  1030ba:	8b 45 14             	mov    0x14(%ebp),%eax
  1030bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1030c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1030c3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1030c8:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  1030cb:	eb 6b                	jmp    103138 <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
  1030cd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  1030d4:	00 
  1030d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1030d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  1030dc:	8b 45 08             	mov    0x8(%ebp),%eax
  1030df:	89 04 24             	mov    %eax,(%esp)
  1030e2:	e8 20 01 00 00       	call   103207 <get_pte>
  1030e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
  1030ea:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  1030ee:	75 24                	jne    103114 <boot_map_segment+0xe1>
  1030f0:	c7 44 24 0c 3e 66 10 	movl   $0x10663e,0xc(%esp)
  1030f7:	00 
  1030f8:	c7 44 24 08 1b 66 10 	movl   $0x10661b,0x8(%esp)
  1030ff:	00 
  103100:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
  103107:	00 
  103108:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  10310f:	e8 d5 d2 ff ff       	call   1003e9 <__panic>
        *ptep = pa | PTE_P | perm;
  103114:	8b 45 18             	mov    0x18(%ebp),%eax
  103117:	8b 55 14             	mov    0x14(%ebp),%edx
  10311a:	09 d0                	or     %edx,%eax
  10311c:	83 c8 01             	or     $0x1,%eax
  10311f:	89 c2                	mov    %eax,%edx
  103121:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103124:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  103126:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  10312a:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
  103131:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  103138:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10313c:	75 8f                	jne    1030cd <boot_map_segment+0x9a>
    }
}
  10313e:	c9                   	leave  
  10313f:	c3                   	ret    

00103140 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
  103140:	55                   	push   %ebp
  103141:	89 e5                	mov    %esp,%ebp
  103143:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
  103146:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10314d:	e8 8c fa ff ff       	call   102bde <alloc_pages>
  103152:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
  103155:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103159:	75 1c                	jne    103177 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
  10315b:	c7 44 24 08 4b 66 10 	movl   $0x10664b,0x8(%esp)
  103162:	00 
  103163:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
  10316a:	00 
  10316b:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  103172:	e8 72 d2 ff ff       	call   1003e9 <__panic>
    }
    return page2kva(p);
  103177:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10317a:	89 04 24             	mov    %eax,(%esp)
  10317d:	e8 b2 f7 ff ff       	call   102934 <page2kva>
}
  103182:	c9                   	leave  
  103183:	c3                   	ret    

00103184 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
  103184:	55                   	push   %ebp
  103185:	89 e5                	mov    %esp,%ebp
  103187:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
  10318a:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10318f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103192:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103195:	a3 14 af 11 00       	mov    %eax,0x11af14
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
  10319a:	e8 ed f9 ff ff       	call   102b8c <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
  10319f:	e8 cf fa ff ff       	call   102c73 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
  1031a4:	e8 75 03 00 00       	call   10351e <check_alloc_page>

    check_pgdir();
  1031a9:	e8 8e 03 00 00       	call   10353c <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
  1031ae:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1031b3:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
  1031b9:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1031be:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1031c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1031c4:	83 c8 03             	or     $0x3,%eax
  1031c7:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
  1031c9:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1031ce:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
  1031d5:	00 
  1031d6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  1031dd:	00 
  1031de:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
  1031e5:	38 
  1031e6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1031ed:	00 
  1031ee:	89 04 24             	mov    %eax,(%esp)
  1031f1:	e8 3d fe ff ff       	call   103033 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
  1031f6:	e8 a2 f8 ff ff       	call   102a9d <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
  1031fb:	e8 d2 09 00 00       	call   103bd2 <check_boot_pgdir>

    print_pgdir();
  103200:	e8 24 0e 00 00       	call   104029 <print_pgdir>

}
  103205:	c9                   	leave  
  103206:	c3                   	ret    

00103207 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
  103207:	55                   	push   %ebp
  103208:	89 e5                	mov    %esp,%ebp
  10320a:	83 ec 38             	sub    $0x38,%esp
    pde_t *pdep = &pgdir[PDX(la)];
  10320d:	8b 45 0c             	mov    0xc(%ebp),%eax
  103210:	c1 e8 16             	shr    $0x16,%eax
  103213:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  10321a:	8b 45 08             	mov    0x8(%ebp),%eax
  10321d:	01 d0                	add    %edx,%eax
  10321f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    //获取一级页表项对应的入口地址
    if (!(*pdep & PTE_P)) {
  103222:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103225:	8b 00                	mov    (%eax),%eax
  103227:	83 e0 01             	and    $0x1,%eax
  10322a:	85 c0                	test   %eax,%eax
  10322c:	0f 85 aa 00 00 00    	jne    1032dc <get_pte+0xd5>
        //物理页不存在, create==0, null
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {//分配失败
  103232:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  103236:	74 15                	je     10324d <get_pte+0x46>
  103238:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10323f:	e8 9a f9 ff ff       	call   102bde <alloc_pages>
  103244:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103247:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10324b:	75 0a                	jne    103257 <get_pte+0x50>
            return NULL;
  10324d:	b8 00 00 00 00       	mov    $0x0,%eax
  103252:	e9 dc 00 00 00       	jmp    103333 <get_pte+0x12c>
        }
        //引用次数+1
        set_page_ref(page, 1);
  103257:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10325e:	00 
  10325f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103262:	89 04 24             	mov    %eax,(%esp)
  103265:	e8 79 f7 ff ff       	call   1029e3 <set_page_ref>
        //物理地址
        uintptr_t pa = page2pa(page);
  10326a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10326d:	89 04 24             	mov    %eax,(%esp)
  103270:	e8 5a f6 ff ff       	call   1028cf <page2pa>
  103275:	89 45 ec             	mov    %eax,-0x14(%ebp)
        ///物理地址转虚拟地址，并初始化,把新申请的数目为pgsize个页全设为0	
        memset(KADDR(pa), 0, PGSIZE);
  103278:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10327b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10327e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103281:	c1 e8 0c             	shr    $0xc,%eax
  103284:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103287:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  10328c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  10328f:	72 23                	jb     1032b4 <get_pte+0xad>
  103291:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103294:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103298:	c7 44 24 08 60 65 10 	movl   $0x106560,0x8(%esp)
  10329f:	00 
  1032a0:	c7 44 24 04 56 01 00 	movl   $0x156,0x4(%esp)
  1032a7:	00 
  1032a8:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  1032af:	e8 35 d1 ff ff       	call   1003e9 <__panic>
  1032b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1032b7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  1032be:	00 
  1032bf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1032c6:	00 
  1032c7:	89 04 24             	mov    %eax,(%esp)
  1032ca:	e8 1a 23 00 00       	call   1055e9 <memset>
        //设置控制位
        *pdep = pa | PTE_U | PTE_W | PTE_P;
  1032cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1032d2:	83 c8 07             	or     $0x7,%eax
  1032d5:	89 c2                	mov    %eax,%edx
  1032d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1032da:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
  1032dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1032df:	8b 00                	mov    (%eax),%eax
  1032e1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1032e6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1032e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1032ec:	c1 e8 0c             	shr    $0xc,%eax
  1032ef:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1032f2:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  1032f7:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  1032fa:	72 23                	jb     10331f <get_pte+0x118>
  1032fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1032ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103303:	c7 44 24 08 60 65 10 	movl   $0x106560,0x8(%esp)
  10330a:	00 
  10330b:	c7 44 24 04 5a 01 00 	movl   $0x15a,0x4(%esp)
  103312:	00 
  103313:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  10331a:	e8 ca d0 ff ff       	call   1003e9 <__panic>
  10331f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103322:	8b 55 0c             	mov    0xc(%ebp),%edx
  103325:	c1 ea 0c             	shr    $0xc,%edx
  103328:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
  10332e:	c1 e2 02             	shl    $0x2,%edx
  103331:	01 d0                	add    %edx,%eax
    //页目录项地址-->>页表物理地址-->>虚拟地址-->>页表项索引
    //PTX(la)：返回虚拟地址la的页表项索引
    //返回la对应的页表项入口地址
}
  103333:	c9                   	leave  
  103334:	c3                   	ret    

00103335 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
  103335:	55                   	push   %ebp
  103336:	89 e5                	mov    %esp,%ebp
  103338:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  10333b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103342:	00 
  103343:	8b 45 0c             	mov    0xc(%ebp),%eax
  103346:	89 44 24 04          	mov    %eax,0x4(%esp)
  10334a:	8b 45 08             	mov    0x8(%ebp),%eax
  10334d:	89 04 24             	mov    %eax,(%esp)
  103350:	e8 b2 fe ff ff       	call   103207 <get_pte>
  103355:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
  103358:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10335c:	74 08                	je     103366 <get_page+0x31>
        *ptep_store = ptep;
  10335e:	8b 45 10             	mov    0x10(%ebp),%eax
  103361:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103364:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
  103366:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10336a:	74 1b                	je     103387 <get_page+0x52>
  10336c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10336f:	8b 00                	mov    (%eax),%eax
  103371:	83 e0 01             	and    $0x1,%eax
  103374:	85 c0                	test   %eax,%eax
  103376:	74 0f                	je     103387 <get_page+0x52>
        return pte2page(*ptep);
  103378:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10337b:	8b 00                	mov    (%eax),%eax
  10337d:	89 04 24             	mov    %eax,(%esp)
  103380:	e8 fe f5 ff ff       	call   102983 <pte2page>
  103385:	eb 05                	jmp    10338c <get_page+0x57>
    }
    return NULL;
  103387:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10338c:	c9                   	leave  
  10338d:	c3                   	ret    

0010338e <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
  10338e:	55                   	push   %ebp
  10338f:	89 e5                	mov    %esp,%ebp
  103391:	83 ec 28             	sub    $0x28,%esp
    if (*ptep & PTE_P) {
  103394:	8b 45 10             	mov    0x10(%ebp),%eax
  103397:	8b 00                	mov    (%eax),%eax
  103399:	83 e0 01             	and    $0x1,%eax
  10339c:	85 c0                	test   %eax,%eax
  10339e:	74 53                	je     1033f3 <page_remove_pte+0x65>
        //判断页表中该表项是否存在
        struct Page *page = pte2page(*ptep);//获得相应的page
  1033a0:	8b 45 10             	mov    0x10(%ebp),%eax
  1033a3:	8b 00                	mov    (%eax),%eax
  1033a5:	89 04 24             	mov    %eax,(%esp)
  1033a8:	e8 d6 f5 ff ff       	call   102983 <pte2page>
  1033ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
  1033b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1033b3:	89 04 24             	mov    %eax,(%esp)
  1033b6:	e8 4c f6 ff ff       	call   102a07 <page_ref_dec>
  1033bb:	85 c0                	test   %eax,%eax
  1033bd:	75 13                	jne    1033d2 <page_remove_pte+0x44>
            ////除了当前进程，没有别的进程引用
            free_page(page);
  1033bf:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1033c6:	00 
  1033c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1033ca:	89 04 24             	mov    %eax,(%esp)
  1033cd:	e8 44 f8 ff ff       	call   102c16 <free_pages>
        }
        *ptep &= (~PTE_P); 
  1033d2:	8b 45 10             	mov    0x10(%ebp),%eax
  1033d5:	8b 00                	mov    (%eax),%eax
  1033d7:	83 e0 fe             	and    $0xfffffffe,%eax
  1033da:	89 c2                	mov    %eax,%edx
  1033dc:	8b 45 10             	mov    0x10(%ebp),%eax
  1033df:	89 10                	mov    %edx,(%eax)
        // 将PTE的存在位设置为0，表示该映射关系无效
        tlb_invalidate(pgdir, la);
  1033e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1033e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1033e8:	8b 45 08             	mov    0x8(%ebp),%eax
  1033eb:	89 04 24             	mov    %eax,(%esp)
  1033ee:	e8 ff 00 00 00       	call   1034f2 <tlb_invalidate>
         //刷新TLB
    }
}
  1033f3:	c9                   	leave  
  1033f4:	c3                   	ret    

001033f5 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
  1033f5:	55                   	push   %ebp
  1033f6:	89 e5                	mov    %esp,%ebp
  1033f8:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  1033fb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103402:	00 
  103403:	8b 45 0c             	mov    0xc(%ebp),%eax
  103406:	89 44 24 04          	mov    %eax,0x4(%esp)
  10340a:	8b 45 08             	mov    0x8(%ebp),%eax
  10340d:	89 04 24             	mov    %eax,(%esp)
  103410:	e8 f2 fd ff ff       	call   103207 <get_pte>
  103415:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
  103418:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10341c:	74 19                	je     103437 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
  10341e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103421:	89 44 24 08          	mov    %eax,0x8(%esp)
  103425:	8b 45 0c             	mov    0xc(%ebp),%eax
  103428:	89 44 24 04          	mov    %eax,0x4(%esp)
  10342c:	8b 45 08             	mov    0x8(%ebp),%eax
  10342f:	89 04 24             	mov    %eax,(%esp)
  103432:	e8 57 ff ff ff       	call   10338e <page_remove_pte>
    }
}
  103437:	c9                   	leave  
  103438:	c3                   	ret    

00103439 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
  103439:	55                   	push   %ebp
  10343a:	89 e5                	mov    %esp,%ebp
  10343c:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
  10343f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  103446:	00 
  103447:	8b 45 10             	mov    0x10(%ebp),%eax
  10344a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10344e:	8b 45 08             	mov    0x8(%ebp),%eax
  103451:	89 04 24             	mov    %eax,(%esp)
  103454:	e8 ae fd ff ff       	call   103207 <get_pte>
  103459:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
  10345c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103460:	75 0a                	jne    10346c <page_insert+0x33>
        return -E_NO_MEM;
  103462:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  103467:	e9 84 00 00 00       	jmp    1034f0 <page_insert+0xb7>
    }
    page_ref_inc(page);
  10346c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10346f:	89 04 24             	mov    %eax,(%esp)
  103472:	e8 79 f5 ff ff       	call   1029f0 <page_ref_inc>
    if (*ptep & PTE_P) {
  103477:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10347a:	8b 00                	mov    (%eax),%eax
  10347c:	83 e0 01             	and    $0x1,%eax
  10347f:	85 c0                	test   %eax,%eax
  103481:	74 3e                	je     1034c1 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
  103483:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103486:	8b 00                	mov    (%eax),%eax
  103488:	89 04 24             	mov    %eax,(%esp)
  10348b:	e8 f3 f4 ff ff       	call   102983 <pte2page>
  103490:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
  103493:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103496:	3b 45 0c             	cmp    0xc(%ebp),%eax
  103499:	75 0d                	jne    1034a8 <page_insert+0x6f>
            page_ref_dec(page);
  10349b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10349e:	89 04 24             	mov    %eax,(%esp)
  1034a1:	e8 61 f5 ff ff       	call   102a07 <page_ref_dec>
  1034a6:	eb 19                	jmp    1034c1 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
  1034a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1034ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  1034af:	8b 45 10             	mov    0x10(%ebp),%eax
  1034b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1034b6:	8b 45 08             	mov    0x8(%ebp),%eax
  1034b9:	89 04 24             	mov    %eax,(%esp)
  1034bc:	e8 cd fe ff ff       	call   10338e <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
  1034c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034c4:	89 04 24             	mov    %eax,(%esp)
  1034c7:	e8 03 f4 ff ff       	call   1028cf <page2pa>
  1034cc:	0b 45 14             	or     0x14(%ebp),%eax
  1034cf:	83 c8 01             	or     $0x1,%eax
  1034d2:	89 c2                	mov    %eax,%edx
  1034d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1034d7:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
  1034d9:	8b 45 10             	mov    0x10(%ebp),%eax
  1034dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  1034e0:	8b 45 08             	mov    0x8(%ebp),%eax
  1034e3:	89 04 24             	mov    %eax,(%esp)
  1034e6:	e8 07 00 00 00       	call   1034f2 <tlb_invalidate>
    return 0;
  1034eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1034f0:	c9                   	leave  
  1034f1:	c3                   	ret    

001034f2 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
  1034f2:	55                   	push   %ebp
  1034f3:	89 e5                	mov    %esp,%ebp
  1034f5:	83 ec 10             	sub    $0x10,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
  1034f8:	0f 20 d8             	mov    %cr3,%eax
  1034fb:	89 45 f8             	mov    %eax,-0x8(%ebp)
    return cr3;
  1034fe:	8b 45 f8             	mov    -0x8(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
  103501:	89 c2                	mov    %eax,%edx
  103503:	8b 45 08             	mov    0x8(%ebp),%eax
  103506:	89 45 fc             	mov    %eax,-0x4(%ebp)
  103509:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10350c:	39 c2                	cmp    %eax,%edx
  10350e:	75 0c                	jne    10351c <tlb_invalidate+0x2a>
        invlpg((void *)la);
  103510:	8b 45 0c             	mov    0xc(%ebp),%eax
  103513:	89 45 f4             	mov    %eax,-0xc(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
  103516:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103519:	0f 01 38             	invlpg (%eax)
    }
}
  10351c:	c9                   	leave  
  10351d:	c3                   	ret    

0010351e <check_alloc_page>:

static void
check_alloc_page(void) {
  10351e:	55                   	push   %ebp
  10351f:	89 e5                	mov    %esp,%ebp
  103521:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
  103524:	a1 10 af 11 00       	mov    0x11af10,%eax
  103529:	8b 40 18             	mov    0x18(%eax),%eax
  10352c:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
  10352e:	c7 04 24 64 66 10 00 	movl   $0x106664,(%esp)
  103535:	e8 58 cd ff ff       	call   100292 <cprintf>
}
  10353a:	c9                   	leave  
  10353b:	c3                   	ret    

0010353c <check_pgdir>:

static void
check_pgdir(void) {
  10353c:	55                   	push   %ebp
  10353d:	89 e5                	mov    %esp,%ebp
  10353f:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
  103542:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  103547:	3d 00 80 03 00       	cmp    $0x38000,%eax
  10354c:	76 24                	jbe    103572 <check_pgdir+0x36>
  10354e:	c7 44 24 0c 83 66 10 	movl   $0x106683,0xc(%esp)
  103555:	00 
  103556:	c7 44 24 08 1b 66 10 	movl   $0x10661b,0x8(%esp)
  10355d:	00 
  10355e:	c7 44 24 04 b7 01 00 	movl   $0x1b7,0x4(%esp)
  103565:	00 
  103566:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  10356d:	e8 77 ce ff ff       	call   1003e9 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
  103572:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103577:	85 c0                	test   %eax,%eax
  103579:	74 0e                	je     103589 <check_pgdir+0x4d>
  10357b:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103580:	25 ff 0f 00 00       	and    $0xfff,%eax
  103585:	85 c0                	test   %eax,%eax
  103587:	74 24                	je     1035ad <check_pgdir+0x71>
  103589:	c7 44 24 0c a0 66 10 	movl   $0x1066a0,0xc(%esp)
  103590:	00 
  103591:	c7 44 24 08 1b 66 10 	movl   $0x10661b,0x8(%esp)
  103598:	00 
  103599:	c7 44 24 04 b8 01 00 	movl   $0x1b8,0x4(%esp)
  1035a0:	00 
  1035a1:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  1035a8:	e8 3c ce ff ff       	call   1003e9 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
  1035ad:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1035b2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1035b9:	00 
  1035ba:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1035c1:	00 
  1035c2:	89 04 24             	mov    %eax,(%esp)
  1035c5:	e8 6b fd ff ff       	call   103335 <get_page>
  1035ca:	85 c0                	test   %eax,%eax
  1035cc:	74 24                	je     1035f2 <check_pgdir+0xb6>
  1035ce:	c7 44 24 0c d8 66 10 	movl   $0x1066d8,0xc(%esp)
  1035d5:	00 
  1035d6:	c7 44 24 08 1b 66 10 	movl   $0x10661b,0x8(%esp)
  1035dd:	00 
  1035de:	c7 44 24 04 b9 01 00 	movl   $0x1b9,0x4(%esp)
  1035e5:	00 
  1035e6:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  1035ed:	e8 f7 cd ff ff       	call   1003e9 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
  1035f2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1035f9:	e8 e0 f5 ff ff       	call   102bde <alloc_pages>
  1035fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
  103601:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103606:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  10360d:	00 
  10360e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103615:	00 
  103616:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103619:	89 54 24 04          	mov    %edx,0x4(%esp)
  10361d:	89 04 24             	mov    %eax,(%esp)
  103620:	e8 14 fe ff ff       	call   103439 <page_insert>
  103625:	85 c0                	test   %eax,%eax
  103627:	74 24                	je     10364d <check_pgdir+0x111>
  103629:	c7 44 24 0c 00 67 10 	movl   $0x106700,0xc(%esp)
  103630:	00 
  103631:	c7 44 24 08 1b 66 10 	movl   $0x10661b,0x8(%esp)
  103638:	00 
  103639:	c7 44 24 04 bd 01 00 	movl   $0x1bd,0x4(%esp)
  103640:	00 
  103641:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  103648:	e8 9c cd ff ff       	call   1003e9 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
  10364d:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103652:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103659:	00 
  10365a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103661:	00 
  103662:	89 04 24             	mov    %eax,(%esp)
  103665:	e8 9d fb ff ff       	call   103207 <get_pte>
  10366a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10366d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103671:	75 24                	jne    103697 <check_pgdir+0x15b>
  103673:	c7 44 24 0c 2c 67 10 	movl   $0x10672c,0xc(%esp)
  10367a:	00 
  10367b:	c7 44 24 08 1b 66 10 	movl   $0x10661b,0x8(%esp)
  103682:	00 
  103683:	c7 44 24 04 c0 01 00 	movl   $0x1c0,0x4(%esp)
  10368a:	00 
  10368b:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  103692:	e8 52 cd ff ff       	call   1003e9 <__panic>
    assert(pte2page(*ptep) == p1);
  103697:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10369a:	8b 00                	mov    (%eax),%eax
  10369c:	89 04 24             	mov    %eax,(%esp)
  10369f:	e8 df f2 ff ff       	call   102983 <pte2page>
  1036a4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  1036a7:	74 24                	je     1036cd <check_pgdir+0x191>
  1036a9:	c7 44 24 0c 59 67 10 	movl   $0x106759,0xc(%esp)
  1036b0:	00 
  1036b1:	c7 44 24 08 1b 66 10 	movl   $0x10661b,0x8(%esp)
  1036b8:	00 
  1036b9:	c7 44 24 04 c1 01 00 	movl   $0x1c1,0x4(%esp)
  1036c0:	00 
  1036c1:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  1036c8:	e8 1c cd ff ff       	call   1003e9 <__panic>
    assert(page_ref(p1) == 1);
  1036cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1036d0:	89 04 24             	mov    %eax,(%esp)
  1036d3:	e8 01 f3 ff ff       	call   1029d9 <page_ref>
  1036d8:	83 f8 01             	cmp    $0x1,%eax
  1036db:	74 24                	je     103701 <check_pgdir+0x1c5>
  1036dd:	c7 44 24 0c 6f 67 10 	movl   $0x10676f,0xc(%esp)
  1036e4:	00 
  1036e5:	c7 44 24 08 1b 66 10 	movl   $0x10661b,0x8(%esp)
  1036ec:	00 
  1036ed:	c7 44 24 04 c2 01 00 	movl   $0x1c2,0x4(%esp)
  1036f4:	00 
  1036f5:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  1036fc:	e8 e8 cc ff ff       	call   1003e9 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
  103701:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103706:	8b 00                	mov    (%eax),%eax
  103708:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10370d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103710:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103713:	c1 e8 0c             	shr    $0xc,%eax
  103716:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103719:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  10371e:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  103721:	72 23                	jb     103746 <check_pgdir+0x20a>
  103723:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103726:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10372a:	c7 44 24 08 60 65 10 	movl   $0x106560,0x8(%esp)
  103731:	00 
  103732:	c7 44 24 04 c4 01 00 	movl   $0x1c4,0x4(%esp)
  103739:	00 
  10373a:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  103741:	e8 a3 cc ff ff       	call   1003e9 <__panic>
  103746:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103749:	83 c0 04             	add    $0x4,%eax
  10374c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
  10374f:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103754:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10375b:	00 
  10375c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103763:	00 
  103764:	89 04 24             	mov    %eax,(%esp)
  103767:	e8 9b fa ff ff       	call   103207 <get_pte>
  10376c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  10376f:	74 24                	je     103795 <check_pgdir+0x259>
  103771:	c7 44 24 0c 84 67 10 	movl   $0x106784,0xc(%esp)
  103778:	00 
  103779:	c7 44 24 08 1b 66 10 	movl   $0x10661b,0x8(%esp)
  103780:	00 
  103781:	c7 44 24 04 c5 01 00 	movl   $0x1c5,0x4(%esp)
  103788:	00 
  103789:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  103790:	e8 54 cc ff ff       	call   1003e9 <__panic>

    p2 = alloc_page();
  103795:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10379c:	e8 3d f4 ff ff       	call   102bde <alloc_pages>
  1037a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
  1037a4:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1037a9:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  1037b0:	00 
  1037b1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  1037b8:	00 
  1037b9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1037bc:	89 54 24 04          	mov    %edx,0x4(%esp)
  1037c0:	89 04 24             	mov    %eax,(%esp)
  1037c3:	e8 71 fc ff ff       	call   103439 <page_insert>
  1037c8:	85 c0                	test   %eax,%eax
  1037ca:	74 24                	je     1037f0 <check_pgdir+0x2b4>
  1037cc:	c7 44 24 0c ac 67 10 	movl   $0x1067ac,0xc(%esp)
  1037d3:	00 
  1037d4:	c7 44 24 08 1b 66 10 	movl   $0x10661b,0x8(%esp)
  1037db:	00 
  1037dc:	c7 44 24 04 c8 01 00 	movl   $0x1c8,0x4(%esp)
  1037e3:	00 
  1037e4:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  1037eb:	e8 f9 cb ff ff       	call   1003e9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  1037f0:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1037f5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1037fc:	00 
  1037fd:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103804:	00 
  103805:	89 04 24             	mov    %eax,(%esp)
  103808:	e8 fa f9 ff ff       	call   103207 <get_pte>
  10380d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103810:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103814:	75 24                	jne    10383a <check_pgdir+0x2fe>
  103816:	c7 44 24 0c e4 67 10 	movl   $0x1067e4,0xc(%esp)
  10381d:	00 
  10381e:	c7 44 24 08 1b 66 10 	movl   $0x10661b,0x8(%esp)
  103825:	00 
  103826:	c7 44 24 04 c9 01 00 	movl   $0x1c9,0x4(%esp)
  10382d:	00 
  10382e:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  103835:	e8 af cb ff ff       	call   1003e9 <__panic>
    assert(*ptep & PTE_U);
  10383a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10383d:	8b 00                	mov    (%eax),%eax
  10383f:	83 e0 04             	and    $0x4,%eax
  103842:	85 c0                	test   %eax,%eax
  103844:	75 24                	jne    10386a <check_pgdir+0x32e>
  103846:	c7 44 24 0c 14 68 10 	movl   $0x106814,0xc(%esp)
  10384d:	00 
  10384e:	c7 44 24 08 1b 66 10 	movl   $0x10661b,0x8(%esp)
  103855:	00 
  103856:	c7 44 24 04 ca 01 00 	movl   $0x1ca,0x4(%esp)
  10385d:	00 
  10385e:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  103865:	e8 7f cb ff ff       	call   1003e9 <__panic>
    assert(*ptep & PTE_W);
  10386a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10386d:	8b 00                	mov    (%eax),%eax
  10386f:	83 e0 02             	and    $0x2,%eax
  103872:	85 c0                	test   %eax,%eax
  103874:	75 24                	jne    10389a <check_pgdir+0x35e>
  103876:	c7 44 24 0c 22 68 10 	movl   $0x106822,0xc(%esp)
  10387d:	00 
  10387e:	c7 44 24 08 1b 66 10 	movl   $0x10661b,0x8(%esp)
  103885:	00 
  103886:	c7 44 24 04 cb 01 00 	movl   $0x1cb,0x4(%esp)
  10388d:	00 
  10388e:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  103895:	e8 4f cb ff ff       	call   1003e9 <__panic>
    assert(boot_pgdir[0] & PTE_U);
  10389a:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10389f:	8b 00                	mov    (%eax),%eax
  1038a1:	83 e0 04             	and    $0x4,%eax
  1038a4:	85 c0                	test   %eax,%eax
  1038a6:	75 24                	jne    1038cc <check_pgdir+0x390>
  1038a8:	c7 44 24 0c 30 68 10 	movl   $0x106830,0xc(%esp)
  1038af:	00 
  1038b0:	c7 44 24 08 1b 66 10 	movl   $0x10661b,0x8(%esp)
  1038b7:	00 
  1038b8:	c7 44 24 04 cc 01 00 	movl   $0x1cc,0x4(%esp)
  1038bf:	00 
  1038c0:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  1038c7:	e8 1d cb ff ff       	call   1003e9 <__panic>
    assert(page_ref(p2) == 1);
  1038cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1038cf:	89 04 24             	mov    %eax,(%esp)
  1038d2:	e8 02 f1 ff ff       	call   1029d9 <page_ref>
  1038d7:	83 f8 01             	cmp    $0x1,%eax
  1038da:	74 24                	je     103900 <check_pgdir+0x3c4>
  1038dc:	c7 44 24 0c 46 68 10 	movl   $0x106846,0xc(%esp)
  1038e3:	00 
  1038e4:	c7 44 24 08 1b 66 10 	movl   $0x10661b,0x8(%esp)
  1038eb:	00 
  1038ec:	c7 44 24 04 cd 01 00 	movl   $0x1cd,0x4(%esp)
  1038f3:	00 
  1038f4:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  1038fb:	e8 e9 ca ff ff       	call   1003e9 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
  103900:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103905:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  10390c:	00 
  10390d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  103914:	00 
  103915:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103918:	89 54 24 04          	mov    %edx,0x4(%esp)
  10391c:	89 04 24             	mov    %eax,(%esp)
  10391f:	e8 15 fb ff ff       	call   103439 <page_insert>
  103924:	85 c0                	test   %eax,%eax
  103926:	74 24                	je     10394c <check_pgdir+0x410>
  103928:	c7 44 24 0c 58 68 10 	movl   $0x106858,0xc(%esp)
  10392f:	00 
  103930:	c7 44 24 08 1b 66 10 	movl   $0x10661b,0x8(%esp)
  103937:	00 
  103938:	c7 44 24 04 cf 01 00 	movl   $0x1cf,0x4(%esp)
  10393f:	00 
  103940:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  103947:	e8 9d ca ff ff       	call   1003e9 <__panic>
    assert(page_ref(p1) == 2);
  10394c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10394f:	89 04 24             	mov    %eax,(%esp)
  103952:	e8 82 f0 ff ff       	call   1029d9 <page_ref>
  103957:	83 f8 02             	cmp    $0x2,%eax
  10395a:	74 24                	je     103980 <check_pgdir+0x444>
  10395c:	c7 44 24 0c 84 68 10 	movl   $0x106884,0xc(%esp)
  103963:	00 
  103964:	c7 44 24 08 1b 66 10 	movl   $0x10661b,0x8(%esp)
  10396b:	00 
  10396c:	c7 44 24 04 d0 01 00 	movl   $0x1d0,0x4(%esp)
  103973:	00 
  103974:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  10397b:	e8 69 ca ff ff       	call   1003e9 <__panic>
    assert(page_ref(p2) == 0);
  103980:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103983:	89 04 24             	mov    %eax,(%esp)
  103986:	e8 4e f0 ff ff       	call   1029d9 <page_ref>
  10398b:	85 c0                	test   %eax,%eax
  10398d:	74 24                	je     1039b3 <check_pgdir+0x477>
  10398f:	c7 44 24 0c 96 68 10 	movl   $0x106896,0xc(%esp)
  103996:	00 
  103997:	c7 44 24 08 1b 66 10 	movl   $0x10661b,0x8(%esp)
  10399e:	00 
  10399f:	c7 44 24 04 d1 01 00 	movl   $0x1d1,0x4(%esp)
  1039a6:	00 
  1039a7:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  1039ae:	e8 36 ca ff ff       	call   1003e9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  1039b3:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1039b8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1039bf:	00 
  1039c0:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  1039c7:	00 
  1039c8:	89 04 24             	mov    %eax,(%esp)
  1039cb:	e8 37 f8 ff ff       	call   103207 <get_pte>
  1039d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1039d3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1039d7:	75 24                	jne    1039fd <check_pgdir+0x4c1>
  1039d9:	c7 44 24 0c e4 67 10 	movl   $0x1067e4,0xc(%esp)
  1039e0:	00 
  1039e1:	c7 44 24 08 1b 66 10 	movl   $0x10661b,0x8(%esp)
  1039e8:	00 
  1039e9:	c7 44 24 04 d2 01 00 	movl   $0x1d2,0x4(%esp)
  1039f0:	00 
  1039f1:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  1039f8:	e8 ec c9 ff ff       	call   1003e9 <__panic>
    assert(pte2page(*ptep) == p1);
  1039fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103a00:	8b 00                	mov    (%eax),%eax
  103a02:	89 04 24             	mov    %eax,(%esp)
  103a05:	e8 79 ef ff ff       	call   102983 <pte2page>
  103a0a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  103a0d:	74 24                	je     103a33 <check_pgdir+0x4f7>
  103a0f:	c7 44 24 0c 59 67 10 	movl   $0x106759,0xc(%esp)
  103a16:	00 
  103a17:	c7 44 24 08 1b 66 10 	movl   $0x10661b,0x8(%esp)
  103a1e:	00 
  103a1f:	c7 44 24 04 d3 01 00 	movl   $0x1d3,0x4(%esp)
  103a26:	00 
  103a27:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  103a2e:	e8 b6 c9 ff ff       	call   1003e9 <__panic>
    assert((*ptep & PTE_U) == 0);
  103a33:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103a36:	8b 00                	mov    (%eax),%eax
  103a38:	83 e0 04             	and    $0x4,%eax
  103a3b:	85 c0                	test   %eax,%eax
  103a3d:	74 24                	je     103a63 <check_pgdir+0x527>
  103a3f:	c7 44 24 0c a8 68 10 	movl   $0x1068a8,0xc(%esp)
  103a46:	00 
  103a47:	c7 44 24 08 1b 66 10 	movl   $0x10661b,0x8(%esp)
  103a4e:	00 
  103a4f:	c7 44 24 04 d4 01 00 	movl   $0x1d4,0x4(%esp)
  103a56:	00 
  103a57:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  103a5e:	e8 86 c9 ff ff       	call   1003e9 <__panic>

    page_remove(boot_pgdir, 0x0);
  103a63:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103a68:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103a6f:	00 
  103a70:	89 04 24             	mov    %eax,(%esp)
  103a73:	e8 7d f9 ff ff       	call   1033f5 <page_remove>
    assert(page_ref(p1) == 1);
  103a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103a7b:	89 04 24             	mov    %eax,(%esp)
  103a7e:	e8 56 ef ff ff       	call   1029d9 <page_ref>
  103a83:	83 f8 01             	cmp    $0x1,%eax
  103a86:	74 24                	je     103aac <check_pgdir+0x570>
  103a88:	c7 44 24 0c 6f 67 10 	movl   $0x10676f,0xc(%esp)
  103a8f:	00 
  103a90:	c7 44 24 08 1b 66 10 	movl   $0x10661b,0x8(%esp)
  103a97:	00 
  103a98:	c7 44 24 04 d7 01 00 	movl   $0x1d7,0x4(%esp)
  103a9f:	00 
  103aa0:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  103aa7:	e8 3d c9 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p2) == 0);
  103aac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103aaf:	89 04 24             	mov    %eax,(%esp)
  103ab2:	e8 22 ef ff ff       	call   1029d9 <page_ref>
  103ab7:	85 c0                	test   %eax,%eax
  103ab9:	74 24                	je     103adf <check_pgdir+0x5a3>
  103abb:	c7 44 24 0c 96 68 10 	movl   $0x106896,0xc(%esp)
  103ac2:	00 
  103ac3:	c7 44 24 08 1b 66 10 	movl   $0x10661b,0x8(%esp)
  103aca:	00 
  103acb:	c7 44 24 04 d8 01 00 	movl   $0x1d8,0x4(%esp)
  103ad2:	00 
  103ad3:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  103ada:	e8 0a c9 ff ff       	call   1003e9 <__panic>

    page_remove(boot_pgdir, PGSIZE);
  103adf:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103ae4:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103aeb:	00 
  103aec:	89 04 24             	mov    %eax,(%esp)
  103aef:	e8 01 f9 ff ff       	call   1033f5 <page_remove>
    assert(page_ref(p1) == 0);
  103af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103af7:	89 04 24             	mov    %eax,(%esp)
  103afa:	e8 da ee ff ff       	call   1029d9 <page_ref>
  103aff:	85 c0                	test   %eax,%eax
  103b01:	74 24                	je     103b27 <check_pgdir+0x5eb>
  103b03:	c7 44 24 0c bd 68 10 	movl   $0x1068bd,0xc(%esp)
  103b0a:	00 
  103b0b:	c7 44 24 08 1b 66 10 	movl   $0x10661b,0x8(%esp)
  103b12:	00 
  103b13:	c7 44 24 04 db 01 00 	movl   $0x1db,0x4(%esp)
  103b1a:	00 
  103b1b:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  103b22:	e8 c2 c8 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p2) == 0);
  103b27:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103b2a:	89 04 24             	mov    %eax,(%esp)
  103b2d:	e8 a7 ee ff ff       	call   1029d9 <page_ref>
  103b32:	85 c0                	test   %eax,%eax
  103b34:	74 24                	je     103b5a <check_pgdir+0x61e>
  103b36:	c7 44 24 0c 96 68 10 	movl   $0x106896,0xc(%esp)
  103b3d:	00 
  103b3e:	c7 44 24 08 1b 66 10 	movl   $0x10661b,0x8(%esp)
  103b45:	00 
  103b46:	c7 44 24 04 dc 01 00 	movl   $0x1dc,0x4(%esp)
  103b4d:	00 
  103b4e:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  103b55:	e8 8f c8 ff ff       	call   1003e9 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
  103b5a:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103b5f:	8b 00                	mov    (%eax),%eax
  103b61:	89 04 24             	mov    %eax,(%esp)
  103b64:	e8 58 ee ff ff       	call   1029c1 <pde2page>
  103b69:	89 04 24             	mov    %eax,(%esp)
  103b6c:	e8 68 ee ff ff       	call   1029d9 <page_ref>
  103b71:	83 f8 01             	cmp    $0x1,%eax
  103b74:	74 24                	je     103b9a <check_pgdir+0x65e>
  103b76:	c7 44 24 0c d0 68 10 	movl   $0x1068d0,0xc(%esp)
  103b7d:	00 
  103b7e:	c7 44 24 08 1b 66 10 	movl   $0x10661b,0x8(%esp)
  103b85:	00 
  103b86:	c7 44 24 04 de 01 00 	movl   $0x1de,0x4(%esp)
  103b8d:	00 
  103b8e:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  103b95:	e8 4f c8 ff ff       	call   1003e9 <__panic>
    free_page(pde2page(boot_pgdir[0]));
  103b9a:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103b9f:	8b 00                	mov    (%eax),%eax
  103ba1:	89 04 24             	mov    %eax,(%esp)
  103ba4:	e8 18 ee ff ff       	call   1029c1 <pde2page>
  103ba9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103bb0:	00 
  103bb1:	89 04 24             	mov    %eax,(%esp)
  103bb4:	e8 5d f0 ff ff       	call   102c16 <free_pages>
    boot_pgdir[0] = 0;
  103bb9:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103bbe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
  103bc4:	c7 04 24 f7 68 10 00 	movl   $0x1068f7,(%esp)
  103bcb:	e8 c2 c6 ff ff       	call   100292 <cprintf>
}
  103bd0:	c9                   	leave  
  103bd1:	c3                   	ret    

00103bd2 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
  103bd2:	55                   	push   %ebp
  103bd3:	89 e5                	mov    %esp,%ebp
  103bd5:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  103bd8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  103bdf:	e9 c5 00 00 00       	jmp    103ca9 <check_boot_pgdir+0xd7>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
  103be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103be7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103bea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103bed:	c1 e8 0c             	shr    $0xc,%eax
  103bf0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103bf3:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  103bf8:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  103bfb:	72 23                	jb     103c20 <check_boot_pgdir+0x4e>
  103bfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103c00:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103c04:	c7 44 24 08 60 65 10 	movl   $0x106560,0x8(%esp)
  103c0b:	00 
  103c0c:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
  103c13:	00 
  103c14:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  103c1b:	e8 c9 c7 ff ff       	call   1003e9 <__panic>
  103c20:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103c23:	89 c2                	mov    %eax,%edx
  103c25:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103c2a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103c31:	00 
  103c32:	89 54 24 04          	mov    %edx,0x4(%esp)
  103c36:	89 04 24             	mov    %eax,(%esp)
  103c39:	e8 c9 f5 ff ff       	call   103207 <get_pte>
  103c3e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103c41:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  103c45:	75 24                	jne    103c6b <check_boot_pgdir+0x99>
  103c47:	c7 44 24 0c 14 69 10 	movl   $0x106914,0xc(%esp)
  103c4e:	00 
  103c4f:	c7 44 24 08 1b 66 10 	movl   $0x10661b,0x8(%esp)
  103c56:	00 
  103c57:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
  103c5e:	00 
  103c5f:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  103c66:	e8 7e c7 ff ff       	call   1003e9 <__panic>
        assert(PTE_ADDR(*ptep) == i);
  103c6b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103c6e:	8b 00                	mov    (%eax),%eax
  103c70:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103c75:	89 c2                	mov    %eax,%edx
  103c77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103c7a:	39 c2                	cmp    %eax,%edx
  103c7c:	74 24                	je     103ca2 <check_boot_pgdir+0xd0>
  103c7e:	c7 44 24 0c 51 69 10 	movl   $0x106951,0xc(%esp)
  103c85:	00 
  103c86:	c7 44 24 08 1b 66 10 	movl   $0x10661b,0x8(%esp)
  103c8d:	00 
  103c8e:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
  103c95:	00 
  103c96:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  103c9d:	e8 47 c7 ff ff       	call   1003e9 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
  103ca2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  103ca9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103cac:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  103cb1:	39 c2                	cmp    %eax,%edx
  103cb3:	0f 82 2b ff ff ff    	jb     103be4 <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
  103cb9:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103cbe:	05 ac 0f 00 00       	add    $0xfac,%eax
  103cc3:	8b 00                	mov    (%eax),%eax
  103cc5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103cca:	89 c2                	mov    %eax,%edx
  103ccc:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103cd1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103cd4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103cd7:	39 c2                	cmp    %eax,%edx
  103cd9:	74 24                	je     103cff <check_boot_pgdir+0x12d>
  103cdb:	c7 44 24 0c 68 69 10 	movl   $0x106968,0xc(%esp)
  103ce2:	00 
  103ce3:	c7 44 24 08 1b 66 10 	movl   $0x10661b,0x8(%esp)
  103cea:	00 
  103ceb:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
  103cf2:	00 
  103cf3:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  103cfa:	e8 ea c6 ff ff       	call   1003e9 <__panic>

    assert(boot_pgdir[0] == 0);
  103cff:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103d04:	8b 00                	mov    (%eax),%eax
  103d06:	85 c0                	test   %eax,%eax
  103d08:	74 24                	je     103d2e <check_boot_pgdir+0x15c>
  103d0a:	c7 44 24 0c 9c 69 10 	movl   $0x10699c,0xc(%esp)
  103d11:	00 
  103d12:	c7 44 24 08 1b 66 10 	movl   $0x10661b,0x8(%esp)
  103d19:	00 
  103d1a:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
  103d21:	00 
  103d22:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  103d29:	e8 bb c6 ff ff       	call   1003e9 <__panic>

    struct Page *p;
    p = alloc_page();
  103d2e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103d35:	e8 a4 ee ff ff       	call   102bde <alloc_pages>
  103d3a:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
  103d3d:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103d42:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  103d49:	00 
  103d4a:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  103d51:	00 
  103d52:	8b 55 e0             	mov    -0x20(%ebp),%edx
  103d55:	89 54 24 04          	mov    %edx,0x4(%esp)
  103d59:	89 04 24             	mov    %eax,(%esp)
  103d5c:	e8 d8 f6 ff ff       	call   103439 <page_insert>
  103d61:	85 c0                	test   %eax,%eax
  103d63:	74 24                	je     103d89 <check_boot_pgdir+0x1b7>
  103d65:	c7 44 24 0c b0 69 10 	movl   $0x1069b0,0xc(%esp)
  103d6c:	00 
  103d6d:	c7 44 24 08 1b 66 10 	movl   $0x10661b,0x8(%esp)
  103d74:	00 
  103d75:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
  103d7c:	00 
  103d7d:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  103d84:	e8 60 c6 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p) == 1);
  103d89:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103d8c:	89 04 24             	mov    %eax,(%esp)
  103d8f:	e8 45 ec ff ff       	call   1029d9 <page_ref>
  103d94:	83 f8 01             	cmp    $0x1,%eax
  103d97:	74 24                	je     103dbd <check_boot_pgdir+0x1eb>
  103d99:	c7 44 24 0c de 69 10 	movl   $0x1069de,0xc(%esp)
  103da0:	00 
  103da1:	c7 44 24 08 1b 66 10 	movl   $0x10661b,0x8(%esp)
  103da8:	00 
  103da9:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
  103db0:	00 
  103db1:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  103db8:	e8 2c c6 ff ff       	call   1003e9 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
  103dbd:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103dc2:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  103dc9:	00 
  103dca:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
  103dd1:	00 
  103dd2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  103dd5:	89 54 24 04          	mov    %edx,0x4(%esp)
  103dd9:	89 04 24             	mov    %eax,(%esp)
  103ddc:	e8 58 f6 ff ff       	call   103439 <page_insert>
  103de1:	85 c0                	test   %eax,%eax
  103de3:	74 24                	je     103e09 <check_boot_pgdir+0x237>
  103de5:	c7 44 24 0c f0 69 10 	movl   $0x1069f0,0xc(%esp)
  103dec:	00 
  103ded:	c7 44 24 08 1b 66 10 	movl   $0x10661b,0x8(%esp)
  103df4:	00 
  103df5:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
  103dfc:	00 
  103dfd:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  103e04:	e8 e0 c5 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p) == 2);
  103e09:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103e0c:	89 04 24             	mov    %eax,(%esp)
  103e0f:	e8 c5 eb ff ff       	call   1029d9 <page_ref>
  103e14:	83 f8 02             	cmp    $0x2,%eax
  103e17:	74 24                	je     103e3d <check_boot_pgdir+0x26b>
  103e19:	c7 44 24 0c 27 6a 10 	movl   $0x106a27,0xc(%esp)
  103e20:	00 
  103e21:	c7 44 24 08 1b 66 10 	movl   $0x10661b,0x8(%esp)
  103e28:	00 
  103e29:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
  103e30:	00 
  103e31:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  103e38:	e8 ac c5 ff ff       	call   1003e9 <__panic>

    const char *str = "ucore: Hello world!!";
  103e3d:	c7 45 dc 38 6a 10 00 	movl   $0x106a38,-0x24(%ebp)
    strcpy((void *)0x100, str);
  103e44:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103e47:	89 44 24 04          	mov    %eax,0x4(%esp)
  103e4b:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  103e52:	e8 bb 14 00 00       	call   105312 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
  103e57:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
  103e5e:	00 
  103e5f:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  103e66:	e8 20 15 00 00       	call   10538b <strcmp>
  103e6b:	85 c0                	test   %eax,%eax
  103e6d:	74 24                	je     103e93 <check_boot_pgdir+0x2c1>
  103e6f:	c7 44 24 0c 50 6a 10 	movl   $0x106a50,0xc(%esp)
  103e76:	00 
  103e77:	c7 44 24 08 1b 66 10 	movl   $0x10661b,0x8(%esp)
  103e7e:	00 
  103e7f:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
  103e86:	00 
  103e87:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  103e8e:	e8 56 c5 ff ff       	call   1003e9 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
  103e93:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103e96:	89 04 24             	mov    %eax,(%esp)
  103e99:	e8 96 ea ff ff       	call   102934 <page2kva>
  103e9e:	05 00 01 00 00       	add    $0x100,%eax
  103ea3:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
  103ea6:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  103ead:	e8 08 14 00 00       	call   1052ba <strlen>
  103eb2:	85 c0                	test   %eax,%eax
  103eb4:	74 24                	je     103eda <check_boot_pgdir+0x308>
  103eb6:	c7 44 24 0c 88 6a 10 	movl   $0x106a88,0xc(%esp)
  103ebd:	00 
  103ebe:	c7 44 24 08 1b 66 10 	movl   $0x10661b,0x8(%esp)
  103ec5:	00 
  103ec6:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
  103ecd:	00 
  103ece:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  103ed5:	e8 0f c5 ff ff       	call   1003e9 <__panic>

    free_page(p);
  103eda:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103ee1:	00 
  103ee2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103ee5:	89 04 24             	mov    %eax,(%esp)
  103ee8:	e8 29 ed ff ff       	call   102c16 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
  103eed:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103ef2:	8b 00                	mov    (%eax),%eax
  103ef4:	89 04 24             	mov    %eax,(%esp)
  103ef7:	e8 c5 ea ff ff       	call   1029c1 <pde2page>
  103efc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103f03:	00 
  103f04:	89 04 24             	mov    %eax,(%esp)
  103f07:	e8 0a ed ff ff       	call   102c16 <free_pages>
    boot_pgdir[0] = 0;
  103f0c:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103f11:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
  103f17:	c7 04 24 ac 6a 10 00 	movl   $0x106aac,(%esp)
  103f1e:	e8 6f c3 ff ff       	call   100292 <cprintf>
}
  103f23:	c9                   	leave  
  103f24:	c3                   	ret    

00103f25 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
  103f25:	55                   	push   %ebp
  103f26:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
  103f28:	8b 45 08             	mov    0x8(%ebp),%eax
  103f2b:	83 e0 04             	and    $0x4,%eax
  103f2e:	85 c0                	test   %eax,%eax
  103f30:	74 07                	je     103f39 <perm2str+0x14>
  103f32:	b8 75 00 00 00       	mov    $0x75,%eax
  103f37:	eb 05                	jmp    103f3e <perm2str+0x19>
  103f39:	b8 2d 00 00 00       	mov    $0x2d,%eax
  103f3e:	a2 08 af 11 00       	mov    %al,0x11af08
    str[1] = 'r';
  103f43:	c6 05 09 af 11 00 72 	movb   $0x72,0x11af09
    str[2] = (perm & PTE_W) ? 'w' : '-';
  103f4a:	8b 45 08             	mov    0x8(%ebp),%eax
  103f4d:	83 e0 02             	and    $0x2,%eax
  103f50:	85 c0                	test   %eax,%eax
  103f52:	74 07                	je     103f5b <perm2str+0x36>
  103f54:	b8 77 00 00 00       	mov    $0x77,%eax
  103f59:	eb 05                	jmp    103f60 <perm2str+0x3b>
  103f5b:	b8 2d 00 00 00       	mov    $0x2d,%eax
  103f60:	a2 0a af 11 00       	mov    %al,0x11af0a
    str[3] = '\0';
  103f65:	c6 05 0b af 11 00 00 	movb   $0x0,0x11af0b
    return str;
  103f6c:	b8 08 af 11 00       	mov    $0x11af08,%eax
}
  103f71:	5d                   	pop    %ebp
  103f72:	c3                   	ret    

00103f73 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
  103f73:	55                   	push   %ebp
  103f74:	89 e5                	mov    %esp,%ebp
  103f76:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
  103f79:	8b 45 10             	mov    0x10(%ebp),%eax
  103f7c:	3b 45 0c             	cmp    0xc(%ebp),%eax
  103f7f:	72 0a                	jb     103f8b <get_pgtable_items+0x18>
        return 0;
  103f81:	b8 00 00 00 00       	mov    $0x0,%eax
  103f86:	e9 9c 00 00 00       	jmp    104027 <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
  103f8b:	eb 04                	jmp    103f91 <get_pgtable_items+0x1e>
        start ++;
  103f8d:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
  103f91:	8b 45 10             	mov    0x10(%ebp),%eax
  103f94:	3b 45 0c             	cmp    0xc(%ebp),%eax
  103f97:	73 18                	jae    103fb1 <get_pgtable_items+0x3e>
  103f99:	8b 45 10             	mov    0x10(%ebp),%eax
  103f9c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  103fa3:	8b 45 14             	mov    0x14(%ebp),%eax
  103fa6:	01 d0                	add    %edx,%eax
  103fa8:	8b 00                	mov    (%eax),%eax
  103faa:	83 e0 01             	and    $0x1,%eax
  103fad:	85 c0                	test   %eax,%eax
  103faf:	74 dc                	je     103f8d <get_pgtable_items+0x1a>
    }
    if (start < right) {
  103fb1:	8b 45 10             	mov    0x10(%ebp),%eax
  103fb4:	3b 45 0c             	cmp    0xc(%ebp),%eax
  103fb7:	73 69                	jae    104022 <get_pgtable_items+0xaf>
        if (left_store != NULL) {
  103fb9:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
  103fbd:	74 08                	je     103fc7 <get_pgtable_items+0x54>
            *left_store = start;
  103fbf:	8b 45 18             	mov    0x18(%ebp),%eax
  103fc2:	8b 55 10             	mov    0x10(%ebp),%edx
  103fc5:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
  103fc7:	8b 45 10             	mov    0x10(%ebp),%eax
  103fca:	8d 50 01             	lea    0x1(%eax),%edx
  103fcd:	89 55 10             	mov    %edx,0x10(%ebp)
  103fd0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  103fd7:	8b 45 14             	mov    0x14(%ebp),%eax
  103fda:	01 d0                	add    %edx,%eax
  103fdc:	8b 00                	mov    (%eax),%eax
  103fde:	83 e0 07             	and    $0x7,%eax
  103fe1:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  103fe4:	eb 04                	jmp    103fea <get_pgtable_items+0x77>
            start ++;
  103fe6:	83 45 10 01          	addl   $0x1,0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  103fea:	8b 45 10             	mov    0x10(%ebp),%eax
  103fed:	3b 45 0c             	cmp    0xc(%ebp),%eax
  103ff0:	73 1d                	jae    10400f <get_pgtable_items+0x9c>
  103ff2:	8b 45 10             	mov    0x10(%ebp),%eax
  103ff5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  103ffc:	8b 45 14             	mov    0x14(%ebp),%eax
  103fff:	01 d0                	add    %edx,%eax
  104001:	8b 00                	mov    (%eax),%eax
  104003:	83 e0 07             	and    $0x7,%eax
  104006:	89 c2                	mov    %eax,%edx
  104008:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10400b:	39 c2                	cmp    %eax,%edx
  10400d:	74 d7                	je     103fe6 <get_pgtable_items+0x73>
        }
        if (right_store != NULL) {
  10400f:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  104013:	74 08                	je     10401d <get_pgtable_items+0xaa>
            *right_store = start;
  104015:	8b 45 1c             	mov    0x1c(%ebp),%eax
  104018:	8b 55 10             	mov    0x10(%ebp),%edx
  10401b:	89 10                	mov    %edx,(%eax)
        }
        return perm;
  10401d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104020:	eb 05                	jmp    104027 <get_pgtable_items+0xb4>
    }
    return 0;
  104022:	b8 00 00 00 00       	mov    $0x0,%eax
}
  104027:	c9                   	leave  
  104028:	c3                   	ret    

00104029 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  104029:	55                   	push   %ebp
  10402a:	89 e5                	mov    %esp,%ebp
  10402c:	57                   	push   %edi
  10402d:	56                   	push   %esi
  10402e:	53                   	push   %ebx
  10402f:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
  104032:	c7 04 24 cc 6a 10 00 	movl   $0x106acc,(%esp)
  104039:	e8 54 c2 ff ff       	call   100292 <cprintf>
    size_t left, right = 0, perm;
  10403e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  104045:	e9 fa 00 00 00       	jmp    104144 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  10404a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10404d:	89 04 24             	mov    %eax,(%esp)
  104050:	e8 d0 fe ff ff       	call   103f25 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
  104055:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  104058:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10405b:	29 d1                	sub    %edx,%ecx
  10405d:	89 ca                	mov    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  10405f:	89 d6                	mov    %edx,%esi
  104061:	c1 e6 16             	shl    $0x16,%esi
  104064:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104067:	89 d3                	mov    %edx,%ebx
  104069:	c1 e3 16             	shl    $0x16,%ebx
  10406c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10406f:	89 d1                	mov    %edx,%ecx
  104071:	c1 e1 16             	shl    $0x16,%ecx
  104074:	8b 7d dc             	mov    -0x24(%ebp),%edi
  104077:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10407a:	29 d7                	sub    %edx,%edi
  10407c:	89 fa                	mov    %edi,%edx
  10407e:	89 44 24 14          	mov    %eax,0x14(%esp)
  104082:	89 74 24 10          	mov    %esi,0x10(%esp)
  104086:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  10408a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  10408e:	89 54 24 04          	mov    %edx,0x4(%esp)
  104092:	c7 04 24 fd 6a 10 00 	movl   $0x106afd,(%esp)
  104099:	e8 f4 c1 ff ff       	call   100292 <cprintf>
        size_t l, r = left * NPTEENTRY;
  10409e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1040a1:	c1 e0 0a             	shl    $0xa,%eax
  1040a4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  1040a7:	eb 54                	jmp    1040fd <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  1040a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1040ac:	89 04 24             	mov    %eax,(%esp)
  1040af:	e8 71 fe ff ff       	call   103f25 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
  1040b4:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  1040b7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1040ba:	29 d1                	sub    %edx,%ecx
  1040bc:	89 ca                	mov    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  1040be:	89 d6                	mov    %edx,%esi
  1040c0:	c1 e6 0c             	shl    $0xc,%esi
  1040c3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1040c6:	89 d3                	mov    %edx,%ebx
  1040c8:	c1 e3 0c             	shl    $0xc,%ebx
  1040cb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1040ce:	c1 e2 0c             	shl    $0xc,%edx
  1040d1:	89 d1                	mov    %edx,%ecx
  1040d3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  1040d6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1040d9:	29 d7                	sub    %edx,%edi
  1040db:	89 fa                	mov    %edi,%edx
  1040dd:	89 44 24 14          	mov    %eax,0x14(%esp)
  1040e1:	89 74 24 10          	mov    %esi,0x10(%esp)
  1040e5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1040e9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  1040ed:	89 54 24 04          	mov    %edx,0x4(%esp)
  1040f1:	c7 04 24 1c 6b 10 00 	movl   $0x106b1c,(%esp)
  1040f8:	e8 95 c1 ff ff       	call   100292 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  1040fd:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
  104102:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104105:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  104108:	89 ce                	mov    %ecx,%esi
  10410a:	c1 e6 0a             	shl    $0xa,%esi
  10410d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  104110:	89 cb                	mov    %ecx,%ebx
  104112:	c1 e3 0a             	shl    $0xa,%ebx
  104115:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
  104118:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  10411c:	8d 4d d8             	lea    -0x28(%ebp),%ecx
  10411f:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  104123:	89 54 24 0c          	mov    %edx,0xc(%esp)
  104127:	89 44 24 08          	mov    %eax,0x8(%esp)
  10412b:	89 74 24 04          	mov    %esi,0x4(%esp)
  10412f:	89 1c 24             	mov    %ebx,(%esp)
  104132:	e8 3c fe ff ff       	call   103f73 <get_pgtable_items>
  104137:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10413a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10413e:	0f 85 65 ff ff ff    	jne    1040a9 <print_pgdir+0x80>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  104144:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
  104149:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10414c:	8d 4d dc             	lea    -0x24(%ebp),%ecx
  10414f:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  104153:	8d 4d e0             	lea    -0x20(%ebp),%ecx
  104156:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  10415a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  10415e:	89 44 24 08          	mov    %eax,0x8(%esp)
  104162:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
  104169:	00 
  10416a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104171:	e8 fd fd ff ff       	call   103f73 <get_pgtable_items>
  104176:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104179:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10417d:	0f 85 c7 fe ff ff    	jne    10404a <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
  104183:	c7 04 24 40 6b 10 00 	movl   $0x106b40,(%esp)
  10418a:	e8 03 c1 ff ff       	call   100292 <cprintf>
}
  10418f:	83 c4 4c             	add    $0x4c,%esp
  104192:	5b                   	pop    %ebx
  104193:	5e                   	pop    %esi
  104194:	5f                   	pop    %edi
  104195:	5d                   	pop    %ebp
  104196:	c3                   	ret    

00104197 <page2ppn>:
page2ppn(struct Page *page) {
  104197:	55                   	push   %ebp
  104198:	89 e5                	mov    %esp,%ebp
    return page - pages;
  10419a:	8b 55 08             	mov    0x8(%ebp),%edx
  10419d:	a1 18 af 11 00       	mov    0x11af18,%eax
  1041a2:	29 c2                	sub    %eax,%edx
  1041a4:	89 d0                	mov    %edx,%eax
  1041a6:	c1 f8 02             	sar    $0x2,%eax
  1041a9:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  1041af:	5d                   	pop    %ebp
  1041b0:	c3                   	ret    

001041b1 <page2pa>:
page2pa(struct Page *page) {
  1041b1:	55                   	push   %ebp
  1041b2:	89 e5                	mov    %esp,%ebp
  1041b4:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  1041b7:	8b 45 08             	mov    0x8(%ebp),%eax
  1041ba:	89 04 24             	mov    %eax,(%esp)
  1041bd:	e8 d5 ff ff ff       	call   104197 <page2ppn>
  1041c2:	c1 e0 0c             	shl    $0xc,%eax
}
  1041c5:	c9                   	leave  
  1041c6:	c3                   	ret    

001041c7 <page_ref>:
page_ref(struct Page *page) {
  1041c7:	55                   	push   %ebp
  1041c8:	89 e5                	mov    %esp,%ebp
    return page->ref;
  1041ca:	8b 45 08             	mov    0x8(%ebp),%eax
  1041cd:	8b 00                	mov    (%eax),%eax
}
  1041cf:	5d                   	pop    %ebp
  1041d0:	c3                   	ret    

001041d1 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
  1041d1:	55                   	push   %ebp
  1041d2:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  1041d4:	8b 45 08             	mov    0x8(%ebp),%eax
  1041d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  1041da:	89 10                	mov    %edx,(%eax)
}
  1041dc:	5d                   	pop    %ebp
  1041dd:	c3                   	ret    

001041de <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
  1041de:	55                   	push   %ebp
  1041df:	89 e5                	mov    %esp,%ebp
  1041e1:	83 ec 10             	sub    $0x10,%esp
  1041e4:	c7 45 fc 1c af 11 00 	movl   $0x11af1c,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  1041eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1041ee:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1041f1:	89 50 04             	mov    %edx,0x4(%eax)
  1041f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1041f7:	8b 50 04             	mov    0x4(%eax),%edx
  1041fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1041fd:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
  1041ff:	c7 05 24 af 11 00 00 	movl   $0x0,0x11af24
  104206:	00 00 00 
}
  104209:	c9                   	leave  
  10420a:	c3                   	ret    

0010420b <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
  10420b:	55                   	push   %ebp
  10420c:	89 e5                	mov    %esp,%ebp
  10420e:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
  104211:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  104215:	75 24                	jne    10423b <default_init_memmap+0x30>
  104217:	c7 44 24 0c 74 6b 10 	movl   $0x106b74,0xc(%esp)
  10421e:	00 
  10421f:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  104226:	00 
  104227:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  10422e:	00 
  10422f:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  104236:	e8 ae c1 ff ff       	call   1003e9 <__panic>
    struct Page *p = base;
  10423b:	8b 45 08             	mov    0x8(%ebp),%eax
  10423e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  104241:	e9 dc 00 00 00       	jmp    104322 <default_init_memmap+0x117>
        //初始化n块物理页
        assert(PageReserved(p));
  104246:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104249:	83 c0 04             	add    $0x4,%eax
  10424c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  104253:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104256:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104259:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10425c:	0f a3 10             	bt     %edx,(%eax)
  10425f:	19 c0                	sbb    %eax,%eax
  104261:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
  104264:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  104268:	0f 95 c0             	setne  %al
  10426b:	0f b6 c0             	movzbl %al,%eax
  10426e:	85 c0                	test   %eax,%eax
  104270:	75 24                	jne    104296 <default_init_memmap+0x8b>
  104272:	c7 44 24 0c a5 6b 10 	movl   $0x106ba5,0xc(%esp)
  104279:	00 
  10427a:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  104281:	00 
  104282:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
  104289:	00 
  10428a:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  104291:	e8 53 c1 ff ff       	call   1003e9 <__panic>
        p->flags = 0;
  104296:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104299:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        SetPageProperty(p);
  1042a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1042a3:	83 c0 04             	add    $0x4,%eax
  1042a6:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  1042ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1042b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1042b3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1042b6:	0f ab 10             	bts    %edx,(%eax)
        p->property = 0;
  1042b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1042bc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        set_page_ref(p, 0);
  1042c3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1042ca:	00 
  1042cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1042ce:	89 04 24             	mov    %eax,(%esp)
  1042d1:	e8 fb fe ff ff       	call   1041d1 <set_page_ref>
        list_add_before(&free_list, &(p->page_link));
  1042d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1042d9:	83 c0 0c             	add    $0xc,%eax
  1042dc:	c7 45 dc 1c af 11 00 	movl   $0x11af1c,-0x24(%ebp)
  1042e3:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  1042e6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1042e9:	8b 00                	mov    (%eax),%eax
  1042eb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1042ee:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  1042f1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1042f4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1042f7:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  1042fa:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1042fd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104300:	89 10                	mov    %edx,(%eax)
  104302:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104305:	8b 10                	mov    (%eax),%edx
  104307:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10430a:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  10430d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104310:	8b 55 cc             	mov    -0x34(%ebp),%edx
  104313:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  104316:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104319:	8b 55 d0             	mov    -0x30(%ebp),%edx
  10431c:	89 10                	mov    %edx,(%eax)
    for (; p != base + n; p ++) {
  10431e:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  104322:	8b 55 0c             	mov    0xc(%ebp),%edx
  104325:	89 d0                	mov    %edx,%eax
  104327:	c1 e0 02             	shl    $0x2,%eax
  10432a:	01 d0                	add    %edx,%eax
  10432c:	c1 e0 02             	shl    $0x2,%eax
  10432f:	89 c2                	mov    %eax,%edx
  104331:	8b 45 08             	mov    0x8(%ebp),%eax
  104334:	01 d0                	add    %edx,%eax
  104336:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104339:	0f 85 07 ff ff ff    	jne    104246 <default_init_memmap+0x3b>
    }
    nr_free += n;
  10433f:	8b 15 24 af 11 00    	mov    0x11af24,%edx
  104345:	8b 45 0c             	mov    0xc(%ebp),%eax
  104348:	01 d0                	add    %edx,%eax
  10434a:	a3 24 af 11 00       	mov    %eax,0x11af24
    base->property = n;
  10434f:	8b 45 08             	mov    0x8(%ebp),%eax
  104352:	8b 55 0c             	mov    0xc(%ebp),%edx
  104355:	89 50 08             	mov    %edx,0x8(%eax)
}
  104358:	c9                   	leave  
  104359:	c3                   	ret    

0010435a <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
  10435a:	55                   	push   %ebp
  10435b:	89 e5                	mov    %esp,%ebp
  10435d:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
  104360:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  104364:	75 24                	jne    10438a <default_alloc_pages+0x30>
  104366:	c7 44 24 0c 74 6b 10 	movl   $0x106b74,0xc(%esp)
  10436d:	00 
  10436e:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  104375:	00 
  104376:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  10437d:	00 
  10437e:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  104385:	e8 5f c0 ff ff       	call   1003e9 <__panic>
    if (n > nr_free) {
  10438a:	a1 24 af 11 00       	mov    0x11af24,%eax
  10438f:	3b 45 08             	cmp    0x8(%ebp),%eax
  104392:	73 0a                	jae    10439e <default_alloc_pages+0x44>
        return NULL;
  104394:	b8 00 00 00 00       	mov    $0x0,%eax
  104399:	e9 37 01 00 00       	jmp    1044d5 <default_alloc_pages+0x17b>
    }
    //如果所有空闲块的空闲页总数都没有n个,直接return null
    list_entry_t *le, *le_next;  //free_list指针和它的下一个
    le = &free_list;
  10439e:	c7 45 f4 1c af 11 00 	movl   $0x11af1c,-0xc(%ebp)
    //从头开始遍历保存空闲物理内存块的链表(按照物理地址的从小到大顺序)
    while((le=list_next(le)) != &free_list) {
  1043a5:	e9 0a 01 00 00       	jmp    1044b4 <default_alloc_pages+0x15a>
    //通过宏le2page(memlayout.h)得指向Page的指针p
      struct Page *p = le2page(le, page_link);
  1043aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1043ad:	83 e8 0c             	sub    $0xc,%eax
  1043b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(p->property >= n){
  1043b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1043b6:	8b 40 08             	mov    0x8(%eax),%eax
  1043b9:	3b 45 08             	cmp    0x8(%ebp),%eax
  1043bc:	0f 82 f2 00 00 00    	jb     1044b4 <default_alloc_pages+0x15a>
        //p->property表示空闲块的大小，大于n则进下一步
        int i;
        //for初始化空闲块中每一个页
        for(i=0;i<n;i++){
  1043c2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  1043c9:	eb 7c                	jmp    104447 <default_alloc_pages+0xed>
  1043cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1043ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
  1043d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1043d4:	8b 40 04             	mov    0x4(%eax),%eax
          le_next = list_next(le);
  1043d7:	89 45 e8             	mov    %eax,-0x18(%ebp)
          struct Page *p2 = le2page(le, page_link);
  1043da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1043dd:	83 e8 0c             	sub    $0xc,%eax
  1043e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
          SetPageReserved(p2);//flags bit0 置1，表示已经被分配
  1043e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1043e6:	83 c0 04             	add    $0x4,%eax
  1043e9:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  1043f0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  1043f3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1043f6:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1043f9:	0f ab 10             	bts    %edx,(%eax)
          ClearPageProperty(p2);//falgs bit1 置0，表示已被分配
  1043fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1043ff:	83 c0 04             	add    $0x4,%eax
  104402:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  104409:	89 45 d0             	mov    %eax,-0x30(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  10440c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10440f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104412:	0f b3 10             	btr    %edx,(%eax)
  104415:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104418:	89 45 cc             	mov    %eax,-0x34(%ebp)
    __list_del(listelm->prev, listelm->next);
  10441b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  10441e:	8b 40 04             	mov    0x4(%eax),%eax
  104421:	8b 55 cc             	mov    -0x34(%ebp),%edx
  104424:	8b 12                	mov    (%edx),%edx
  104426:	89 55 c8             	mov    %edx,-0x38(%ebp)
  104429:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  10442c:	8b 45 c8             	mov    -0x38(%ebp),%eax
  10442f:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  104432:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  104435:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104438:	8b 55 c8             	mov    -0x38(%ebp),%edx
  10443b:	89 10                	mov    %edx,(%eax)
          list_del(le);//取消和free_list的link
          le = le_next;//指针后移
  10443d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104440:	89 45 f4             	mov    %eax,-0xc(%ebp)
        for(i=0;i<n;i++){
  104443:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  104447:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10444a:	3b 45 08             	cmp    0x8(%ebp),%eax
  10444d:	0f 82 78 ff ff ff    	jb     1043cb <default_alloc_pages+0x71>
        }
        //如果选中的块大于n,需要修改剩下的块的head page的property
        if(p->property>n){
  104453:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104456:	8b 40 08             	mov    0x8(%eax),%eax
  104459:	3b 45 08             	cmp    0x8(%ebp),%eax
  10445c:	76 12                	jbe    104470 <default_alloc_pages+0x116>
          (le2page(le,page_link))->property = p->property - n;
  10445e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104461:	8d 50 f4             	lea    -0xc(%eax),%edx
  104464:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104467:	8b 40 08             	mov    0x8(%eax),%eax
  10446a:	2b 45 08             	sub    0x8(%ebp),%eax
  10446d:	89 42 08             	mov    %eax,0x8(%edx)
        }
        ClearPageProperty(p);
  104470:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104473:	83 c0 04             	add    $0x4,%eax
  104476:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  10447d:	89 45 bc             	mov    %eax,-0x44(%ebp)
  104480:	8b 45 bc             	mov    -0x44(%ebp),%eax
  104483:	8b 55 c0             	mov    -0x40(%ebp),%edx
  104486:	0f b3 10             	btr    %edx,(%eax)
        SetPageReserved(p);
  104489:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10448c:	83 c0 04             	add    $0x4,%eax
  10448f:	c7 45 b8 00 00 00 00 	movl   $0x0,-0x48(%ebp)
  104496:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104499:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  10449c:	8b 55 b8             	mov    -0x48(%ebp),%edx
  10449f:	0f ab 10             	bts    %edx,(%eax)
        nr_free -= n;
  1044a2:	a1 24 af 11 00       	mov    0x11af24,%eax
  1044a7:	2b 45 08             	sub    0x8(%ebp),%eax
  1044aa:	a3 24 af 11 00       	mov    %eax,0x11af24
        return p;
  1044af:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1044b2:	eb 21                	jmp    1044d5 <default_alloc_pages+0x17b>
  1044b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1044b7:	89 45 b0             	mov    %eax,-0x50(%ebp)
    return listelm->next;
  1044ba:	8b 45 b0             	mov    -0x50(%ebp),%eax
  1044bd:	8b 40 04             	mov    0x4(%eax),%eax
    while((le=list_next(le)) != &free_list) {
  1044c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1044c3:	81 7d f4 1c af 11 00 	cmpl   $0x11af1c,-0xc(%ebp)
  1044ca:	0f 85 da fe ff ff    	jne    1043aa <default_alloc_pages+0x50>
      }
    }
    return NULL;//防止出错
  1044d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1044d5:	c9                   	leave  
  1044d6:	c3                   	ret    

001044d7 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
  1044d7:	55                   	push   %ebp
  1044d8:	89 e5                	mov    %esp,%ebp
  1044da:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
  1044dd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1044e1:	75 24                	jne    104507 <default_free_pages+0x30>
  1044e3:	c7 44 24 0c 74 6b 10 	movl   $0x106b74,0xc(%esp)
  1044ea:	00 
  1044eb:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  1044f2:	00 
  1044f3:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
  1044fa:	00 
  1044fb:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  104502:	e8 e2 be ff ff       	call   1003e9 <__panic>
    //assert(PageReserved(base) && PageProperty(base));
    assert(PageReserved(base));
  104507:	8b 45 08             	mov    0x8(%ebp),%eax
  10450a:	83 c0 04             	add    $0x4,%eax
  10450d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  104514:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104517:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10451a:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10451d:	0f a3 10             	bt     %edx,(%eax)
  104520:	19 c0                	sbb    %eax,%eax
  104522:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
  104525:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  104529:	0f 95 c0             	setne  %al
  10452c:	0f b6 c0             	movzbl %al,%eax
  10452f:	85 c0                	test   %eax,%eax
  104531:	75 24                	jne    104557 <default_free_pages+0x80>
  104533:	c7 44 24 0c b5 6b 10 	movl   $0x106bb5,0xc(%esp)
  10453a:	00 
  10453b:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  104542:	00 
  104543:	c7 44 24 04 a6 00 00 	movl   $0xa6,0x4(%esp)
  10454a:	00 
  10454b:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  104552:	e8 92 be ff ff       	call   1003e9 <__panic>
    //检查需要释放的页块是否已经被分配,只要看bit 0 reserve就好了
    list_entry_t *le = &free_list;
  104557:	c7 45 f4 1c af 11 00 	movl   $0x11af1c,-0xc(%ebp)
    struct Page * p;
    while((le=list_next(le)) != &free_list) {
  10455e:	eb 13                	jmp    104573 <default_free_pages+0x9c>
      p = le2page(le, page_link);
  104560:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104563:	83 e8 0c             	sub    $0xc,%eax
  104566:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(p>base){break;}
  104569:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10456c:	3b 45 08             	cmp    0x8(%ebp),%eax
  10456f:	76 02                	jbe    104573 <default_free_pages+0x9c>
  104571:	eb 18                	jmp    10458b <default_free_pages+0xb4>
  104573:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104576:	89 45 e0             	mov    %eax,-0x20(%ebp)
  104579:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10457c:	8b 40 04             	mov    0x4(%eax),%eax
    while((le=list_next(le)) != &free_list) {
  10457f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104582:	81 7d f4 1c af 11 00 	cmpl   $0x11af1c,-0xc(%ebp)
  104589:	75 d5                	jne    104560 <default_free_pages+0x89>
    }
    //将每一空闲块的链表插入空闲链表中
    for(p=base;p<base+n;p++){
  10458b:	8b 45 08             	mov    0x8(%ebp),%eax
  10458e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104591:	eb 4b                	jmp    1045de <default_free_pages+0x107>
      list_add_before(le, &(p->page_link));
  104593:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104596:	8d 50 0c             	lea    0xc(%eax),%edx
  104599:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10459c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  10459f:	89 55 d8             	mov    %edx,-0x28(%ebp)
    __list_add(elm, listelm->prev, listelm);
  1045a2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1045a5:	8b 00                	mov    (%eax),%eax
  1045a7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1045aa:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  1045ad:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1045b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1045b3:	89 45 cc             	mov    %eax,-0x34(%ebp)
    prev->next = next->prev = elm;
  1045b6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1045b9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1045bc:	89 10                	mov    %edx,(%eax)
  1045be:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1045c1:	8b 10                	mov    (%eax),%edx
  1045c3:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1045c6:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  1045c9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1045cc:	8b 55 cc             	mov    -0x34(%ebp),%edx
  1045cf:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  1045d2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1045d5:	8b 55 d0             	mov    -0x30(%ebp),%edx
  1045d8:	89 10                	mov    %edx,(%eax)
    for(p=base;p<base+n;p++){
  1045da:	83 45 f0 14          	addl   $0x14,-0x10(%ebp)
  1045de:	8b 55 0c             	mov    0xc(%ebp),%edx
  1045e1:	89 d0                	mov    %edx,%eax
  1045e3:	c1 e0 02             	shl    $0x2,%eax
  1045e6:	01 d0                	add    %edx,%eax
  1045e8:	c1 e0 02             	shl    $0x2,%eax
  1045eb:	89 c2                	mov    %eax,%edx
  1045ed:	8b 45 08             	mov    0x8(%ebp),%eax
  1045f0:	01 d0                	add    %edx,%eax
  1045f2:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  1045f5:	77 9c                	ja     104593 <default_free_pages+0xbc>
    }
    //修改页的各个属性置0
    base->flags = 0;
  1045f7:	8b 45 08             	mov    0x8(%ebp),%eax
  1045fa:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    set_page_ref(base, 0);
  104601:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104608:	00 
  104609:	8b 45 08             	mov    0x8(%ebp),%eax
  10460c:	89 04 24             	mov    %eax,(%esp)
  10460f:	e8 bd fb ff ff       	call   1041d1 <set_page_ref>
    ClearPageProperty(base);
  104614:	8b 45 08             	mov    0x8(%ebp),%eax
  104617:	83 c0 04             	add    $0x4,%eax
  10461a:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
  104621:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104624:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104627:	8b 55 c8             	mov    -0x38(%ebp),%edx
  10462a:	0f b3 10             	btr    %edx,(%eax)
    SetPageProperty(base);
  10462d:	8b 45 08             	mov    0x8(%ebp),%eax
  104630:	83 c0 04             	add    $0x4,%eax
  104633:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  10463a:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  10463d:	8b 45 bc             	mov    -0x44(%ebp),%eax
  104640:	8b 55 c0             	mov    -0x40(%ebp),%edx
  104643:	0f ab 10             	bts    %edx,(%eax)
    base->property = n;//有n空闲页
  104646:	8b 45 08             	mov    0x8(%ebp),%eax
  104649:	8b 55 0c             	mov    0xc(%ebp),%edx
  10464c:	89 50 08             	mov    %edx,0x8(%eax)
    p = le2page(le,page_link) ;
  10464f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104652:	83 e8 0c             	sub    $0xc,%eax
  104655:	89 45 f0             	mov    %eax,-0x10(%ebp)
    //和高位方向的下一个内存块的地址连续，向高位合并
    if( base+n == p ){
  104658:	8b 55 0c             	mov    0xc(%ebp),%edx
  10465b:	89 d0                	mov    %edx,%eax
  10465d:	c1 e0 02             	shl    $0x2,%eax
  104660:	01 d0                	add    %edx,%eax
  104662:	c1 e0 02             	shl    $0x2,%eax
  104665:	89 c2                	mov    %eax,%edx
  104667:	8b 45 08             	mov    0x8(%ebp),%eax
  10466a:	01 d0                	add    %edx,%eax
  10466c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  10466f:	75 1e                	jne    10468f <default_free_pages+0x1b8>
      base->property += p->property;
  104671:	8b 45 08             	mov    0x8(%ebp),%eax
  104674:	8b 50 08             	mov    0x8(%eax),%edx
  104677:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10467a:	8b 40 08             	mov    0x8(%eax),%eax
  10467d:	01 c2                	add    %eax,%edx
  10467f:	8b 45 08             	mov    0x8(%ebp),%eax
  104682:	89 50 08             	mov    %edx,0x8(%eax)
      p->property = 0;
  104685:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104688:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    }
    //如果是低位,向低地址合并
    //把le指针指向前一个内存块
    le = list_prev(&(base->page_link));  //previous
  10468f:	8b 45 08             	mov    0x8(%ebp),%eax
  104692:	83 c0 0c             	add    $0xc,%eax
  104695:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return listelm->prev;
  104698:	8b 45 b8             	mov    -0x48(%ebp),%eax
  10469b:	8b 00                	mov    (%eax),%eax
  10469d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    p = le2page(le, page_link);
  1046a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046a3:	83 e8 0c             	sub    $0xc,%eax
  1046a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(le!=&free_list && p==base-1){
  1046a9:	81 7d f4 1c af 11 00 	cmpl   $0x11af1c,-0xc(%ebp)
  1046b0:	74 57                	je     104709 <default_free_pages+0x232>
  1046b2:	8b 45 08             	mov    0x8(%ebp),%eax
  1046b5:	83 e8 14             	sub    $0x14,%eax
  1046b8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  1046bb:	75 4c                	jne    104709 <default_free_pages+0x232>
      while(le!=&free_list){
  1046bd:	eb 41                	jmp    104700 <default_free_pages+0x229>
        if(p->property){
  1046bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1046c2:	8b 40 08             	mov    0x8(%eax),%eax
  1046c5:	85 c0                	test   %eax,%eax
  1046c7:	74 20                	je     1046e9 <default_free_pages+0x212>
          p->property += base->property;
  1046c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1046cc:	8b 50 08             	mov    0x8(%eax),%edx
  1046cf:	8b 45 08             	mov    0x8(%ebp),%eax
  1046d2:	8b 40 08             	mov    0x8(%eax),%eax
  1046d5:	01 c2                	add    %eax,%edx
  1046d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1046da:	89 50 08             	mov    %edx,0x8(%eax)
          base->property = 0;
  1046dd:	8b 45 08             	mov    0x8(%ebp),%eax
  1046e0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
          break;
  1046e7:	eb 20                	jmp    104709 <default_free_pages+0x232>
  1046e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046ec:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  1046ef:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1046f2:	8b 00                	mov    (%eax),%eax
        }
        le = list_prev(le);
  1046f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
        p = le2page(le,page_link);
  1046f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046fa:	83 e8 0c             	sub    $0xc,%eax
  1046fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
      while(le!=&free_list){
  104700:	81 7d f4 1c af 11 00 	cmpl   $0x11af1c,-0xc(%ebp)
  104707:	75 b6                	jne    1046bf <default_free_pages+0x1e8>
      }
    }
   //更新总空闲页数
    nr_free += n;
  104709:	8b 15 24 af 11 00    	mov    0x11af24,%edx
  10470f:	8b 45 0c             	mov    0xc(%ebp),%eax
  104712:	01 d0                	add    %edx,%eax
  104714:	a3 24 af 11 00       	mov    %eax,0x11af24
    return ;
  104719:	90                   	nop
}
  10471a:	c9                   	leave  
  10471b:	c3                   	ret    

0010471c <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
  10471c:	55                   	push   %ebp
  10471d:	89 e5                	mov    %esp,%ebp
    return nr_free;
  10471f:	a1 24 af 11 00       	mov    0x11af24,%eax
}
  104724:	5d                   	pop    %ebp
  104725:	c3                   	ret    

00104726 <basic_check>:

static void
basic_check(void) {
  104726:	55                   	push   %ebp
  104727:	89 e5                	mov    %esp,%ebp
  104729:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
  10472c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104733:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104736:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104739:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10473c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
  10473f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104746:	e8 93 e4 ff ff       	call   102bde <alloc_pages>
  10474b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10474e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  104752:	75 24                	jne    104778 <basic_check+0x52>
  104754:	c7 44 24 0c c8 6b 10 	movl   $0x106bc8,0xc(%esp)
  10475b:	00 
  10475c:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  104763:	00 
  104764:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
  10476b:	00 
  10476c:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  104773:	e8 71 bc ff ff       	call   1003e9 <__panic>
    assert((p1 = alloc_page()) != NULL);
  104778:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10477f:	e8 5a e4 ff ff       	call   102bde <alloc_pages>
  104784:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104787:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10478b:	75 24                	jne    1047b1 <basic_check+0x8b>
  10478d:	c7 44 24 0c e4 6b 10 	movl   $0x106be4,0xc(%esp)
  104794:	00 
  104795:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  10479c:	00 
  10479d:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
  1047a4:	00 
  1047a5:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  1047ac:	e8 38 bc ff ff       	call   1003e9 <__panic>
    assert((p2 = alloc_page()) != NULL);
  1047b1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1047b8:	e8 21 e4 ff ff       	call   102bde <alloc_pages>
  1047bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1047c0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1047c4:	75 24                	jne    1047ea <basic_check+0xc4>
  1047c6:	c7 44 24 0c 00 6c 10 	movl   $0x106c00,0xc(%esp)
  1047cd:	00 
  1047ce:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  1047d5:	00 
  1047d6:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
  1047dd:	00 
  1047de:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  1047e5:	e8 ff bb ff ff       	call   1003e9 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
  1047ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1047ed:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  1047f0:	74 10                	je     104802 <basic_check+0xdc>
  1047f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1047f5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  1047f8:	74 08                	je     104802 <basic_check+0xdc>
  1047fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1047fd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104800:	75 24                	jne    104826 <basic_check+0x100>
  104802:	c7 44 24 0c 1c 6c 10 	movl   $0x106c1c,0xc(%esp)
  104809:	00 
  10480a:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  104811:	00 
  104812:	c7 44 24 04 df 00 00 	movl   $0xdf,0x4(%esp)
  104819:	00 
  10481a:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  104821:	e8 c3 bb ff ff       	call   1003e9 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  104826:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104829:	89 04 24             	mov    %eax,(%esp)
  10482c:	e8 96 f9 ff ff       	call   1041c7 <page_ref>
  104831:	85 c0                	test   %eax,%eax
  104833:	75 1e                	jne    104853 <basic_check+0x12d>
  104835:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104838:	89 04 24             	mov    %eax,(%esp)
  10483b:	e8 87 f9 ff ff       	call   1041c7 <page_ref>
  104840:	85 c0                	test   %eax,%eax
  104842:	75 0f                	jne    104853 <basic_check+0x12d>
  104844:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104847:	89 04 24             	mov    %eax,(%esp)
  10484a:	e8 78 f9 ff ff       	call   1041c7 <page_ref>
  10484f:	85 c0                	test   %eax,%eax
  104851:	74 24                	je     104877 <basic_check+0x151>
  104853:	c7 44 24 0c 40 6c 10 	movl   $0x106c40,0xc(%esp)
  10485a:	00 
  10485b:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  104862:	00 
  104863:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
  10486a:	00 
  10486b:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  104872:	e8 72 bb ff ff       	call   1003e9 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  104877:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10487a:	89 04 24             	mov    %eax,(%esp)
  10487d:	e8 2f f9 ff ff       	call   1041b1 <page2pa>
  104882:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  104888:	c1 e2 0c             	shl    $0xc,%edx
  10488b:	39 d0                	cmp    %edx,%eax
  10488d:	72 24                	jb     1048b3 <basic_check+0x18d>
  10488f:	c7 44 24 0c 7c 6c 10 	movl   $0x106c7c,0xc(%esp)
  104896:	00 
  104897:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  10489e:	00 
  10489f:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
  1048a6:	00 
  1048a7:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  1048ae:	e8 36 bb ff ff       	call   1003e9 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  1048b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1048b6:	89 04 24             	mov    %eax,(%esp)
  1048b9:	e8 f3 f8 ff ff       	call   1041b1 <page2pa>
  1048be:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  1048c4:	c1 e2 0c             	shl    $0xc,%edx
  1048c7:	39 d0                	cmp    %edx,%eax
  1048c9:	72 24                	jb     1048ef <basic_check+0x1c9>
  1048cb:	c7 44 24 0c 99 6c 10 	movl   $0x106c99,0xc(%esp)
  1048d2:	00 
  1048d3:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  1048da:	00 
  1048db:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
  1048e2:	00 
  1048e3:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  1048ea:	e8 fa ba ff ff       	call   1003e9 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  1048ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1048f2:	89 04 24             	mov    %eax,(%esp)
  1048f5:	e8 b7 f8 ff ff       	call   1041b1 <page2pa>
  1048fa:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  104900:	c1 e2 0c             	shl    $0xc,%edx
  104903:	39 d0                	cmp    %edx,%eax
  104905:	72 24                	jb     10492b <basic_check+0x205>
  104907:	c7 44 24 0c b6 6c 10 	movl   $0x106cb6,0xc(%esp)
  10490e:	00 
  10490f:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  104916:	00 
  104917:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
  10491e:	00 
  10491f:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  104926:	e8 be ba ff ff       	call   1003e9 <__panic>

    list_entry_t free_list_store = free_list;
  10492b:	a1 1c af 11 00       	mov    0x11af1c,%eax
  104930:	8b 15 20 af 11 00    	mov    0x11af20,%edx
  104936:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104939:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  10493c:	c7 45 e0 1c af 11 00 	movl   $0x11af1c,-0x20(%ebp)
    elm->prev = elm->next = elm;
  104943:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104946:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104949:	89 50 04             	mov    %edx,0x4(%eax)
  10494c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10494f:	8b 50 04             	mov    0x4(%eax),%edx
  104952:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104955:	89 10                	mov    %edx,(%eax)
  104957:	c7 45 dc 1c af 11 00 	movl   $0x11af1c,-0x24(%ebp)
    return list->next == list;
  10495e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104961:	8b 40 04             	mov    0x4(%eax),%eax
  104964:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  104967:	0f 94 c0             	sete   %al
  10496a:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  10496d:	85 c0                	test   %eax,%eax
  10496f:	75 24                	jne    104995 <basic_check+0x26f>
  104971:	c7 44 24 0c d3 6c 10 	movl   $0x106cd3,0xc(%esp)
  104978:	00 
  104979:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  104980:	00 
  104981:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
  104988:	00 
  104989:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  104990:	e8 54 ba ff ff       	call   1003e9 <__panic>

    unsigned int nr_free_store = nr_free;
  104995:	a1 24 af 11 00       	mov    0x11af24,%eax
  10499a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
  10499d:	c7 05 24 af 11 00 00 	movl   $0x0,0x11af24
  1049a4:	00 00 00 

    assert(alloc_page() == NULL);
  1049a7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1049ae:	e8 2b e2 ff ff       	call   102bde <alloc_pages>
  1049b3:	85 c0                	test   %eax,%eax
  1049b5:	74 24                	je     1049db <basic_check+0x2b5>
  1049b7:	c7 44 24 0c ea 6c 10 	movl   $0x106cea,0xc(%esp)
  1049be:	00 
  1049bf:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  1049c6:	00 
  1049c7:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
  1049ce:	00 
  1049cf:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  1049d6:	e8 0e ba ff ff       	call   1003e9 <__panic>

    free_page(p0);
  1049db:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1049e2:	00 
  1049e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1049e6:	89 04 24             	mov    %eax,(%esp)
  1049e9:	e8 28 e2 ff ff       	call   102c16 <free_pages>
    free_page(p1);
  1049ee:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1049f5:	00 
  1049f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1049f9:	89 04 24             	mov    %eax,(%esp)
  1049fc:	e8 15 e2 ff ff       	call   102c16 <free_pages>
    free_page(p2);
  104a01:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104a08:	00 
  104a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104a0c:	89 04 24             	mov    %eax,(%esp)
  104a0f:	e8 02 e2 ff ff       	call   102c16 <free_pages>
    assert(nr_free == 3);
  104a14:	a1 24 af 11 00       	mov    0x11af24,%eax
  104a19:	83 f8 03             	cmp    $0x3,%eax
  104a1c:	74 24                	je     104a42 <basic_check+0x31c>
  104a1e:	c7 44 24 0c ff 6c 10 	movl   $0x106cff,0xc(%esp)
  104a25:	00 
  104a26:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  104a2d:	00 
  104a2e:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
  104a35:	00 
  104a36:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  104a3d:	e8 a7 b9 ff ff       	call   1003e9 <__panic>

    assert((p0 = alloc_page()) != NULL);
  104a42:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104a49:	e8 90 e1 ff ff       	call   102bde <alloc_pages>
  104a4e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104a51:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  104a55:	75 24                	jne    104a7b <basic_check+0x355>
  104a57:	c7 44 24 0c c8 6b 10 	movl   $0x106bc8,0xc(%esp)
  104a5e:	00 
  104a5f:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  104a66:	00 
  104a67:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
  104a6e:	00 
  104a6f:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  104a76:	e8 6e b9 ff ff       	call   1003e9 <__panic>
    assert((p1 = alloc_page()) != NULL);
  104a7b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104a82:	e8 57 e1 ff ff       	call   102bde <alloc_pages>
  104a87:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104a8a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104a8e:	75 24                	jne    104ab4 <basic_check+0x38e>
  104a90:	c7 44 24 0c e4 6b 10 	movl   $0x106be4,0xc(%esp)
  104a97:	00 
  104a98:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  104a9f:	00 
  104aa0:	c7 44 24 04 f5 00 00 	movl   $0xf5,0x4(%esp)
  104aa7:	00 
  104aa8:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  104aaf:	e8 35 b9 ff ff       	call   1003e9 <__panic>
    assert((p2 = alloc_page()) != NULL);
  104ab4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104abb:	e8 1e e1 ff ff       	call   102bde <alloc_pages>
  104ac0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104ac3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104ac7:	75 24                	jne    104aed <basic_check+0x3c7>
  104ac9:	c7 44 24 0c 00 6c 10 	movl   $0x106c00,0xc(%esp)
  104ad0:	00 
  104ad1:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  104ad8:	00 
  104ad9:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
  104ae0:	00 
  104ae1:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  104ae8:	e8 fc b8 ff ff       	call   1003e9 <__panic>

    assert(alloc_page() == NULL);
  104aed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104af4:	e8 e5 e0 ff ff       	call   102bde <alloc_pages>
  104af9:	85 c0                	test   %eax,%eax
  104afb:	74 24                	je     104b21 <basic_check+0x3fb>
  104afd:	c7 44 24 0c ea 6c 10 	movl   $0x106cea,0xc(%esp)
  104b04:	00 
  104b05:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  104b0c:	00 
  104b0d:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
  104b14:	00 
  104b15:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  104b1c:	e8 c8 b8 ff ff       	call   1003e9 <__panic>

    free_page(p0);
  104b21:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104b28:	00 
  104b29:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104b2c:	89 04 24             	mov    %eax,(%esp)
  104b2f:	e8 e2 e0 ff ff       	call   102c16 <free_pages>
  104b34:	c7 45 d8 1c af 11 00 	movl   $0x11af1c,-0x28(%ebp)
  104b3b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104b3e:	8b 40 04             	mov    0x4(%eax),%eax
  104b41:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  104b44:	0f 94 c0             	sete   %al
  104b47:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
  104b4a:	85 c0                	test   %eax,%eax
  104b4c:	74 24                	je     104b72 <basic_check+0x44c>
  104b4e:	c7 44 24 0c 0c 6d 10 	movl   $0x106d0c,0xc(%esp)
  104b55:	00 
  104b56:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  104b5d:	00 
  104b5e:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
  104b65:	00 
  104b66:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  104b6d:	e8 77 b8 ff ff       	call   1003e9 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
  104b72:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104b79:	e8 60 e0 ff ff       	call   102bde <alloc_pages>
  104b7e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104b81:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104b84:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  104b87:	74 24                	je     104bad <basic_check+0x487>
  104b89:	c7 44 24 0c 24 6d 10 	movl   $0x106d24,0xc(%esp)
  104b90:	00 
  104b91:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  104b98:	00 
  104b99:	c7 44 24 04 fe 00 00 	movl   $0xfe,0x4(%esp)
  104ba0:	00 
  104ba1:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  104ba8:	e8 3c b8 ff ff       	call   1003e9 <__panic>
    assert(alloc_page() == NULL);
  104bad:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104bb4:	e8 25 e0 ff ff       	call   102bde <alloc_pages>
  104bb9:	85 c0                	test   %eax,%eax
  104bbb:	74 24                	je     104be1 <basic_check+0x4bb>
  104bbd:	c7 44 24 0c ea 6c 10 	movl   $0x106cea,0xc(%esp)
  104bc4:	00 
  104bc5:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  104bcc:	00 
  104bcd:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  104bd4:	00 
  104bd5:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  104bdc:	e8 08 b8 ff ff       	call   1003e9 <__panic>

    assert(nr_free == 0);
  104be1:	a1 24 af 11 00       	mov    0x11af24,%eax
  104be6:	85 c0                	test   %eax,%eax
  104be8:	74 24                	je     104c0e <basic_check+0x4e8>
  104bea:	c7 44 24 0c 3d 6d 10 	movl   $0x106d3d,0xc(%esp)
  104bf1:	00 
  104bf2:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  104bf9:	00 
  104bfa:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
  104c01:	00 
  104c02:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  104c09:	e8 db b7 ff ff       	call   1003e9 <__panic>
    free_list = free_list_store;
  104c0e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104c11:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104c14:	a3 1c af 11 00       	mov    %eax,0x11af1c
  104c19:	89 15 20 af 11 00    	mov    %edx,0x11af20
    nr_free = nr_free_store;
  104c1f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104c22:	a3 24 af 11 00       	mov    %eax,0x11af24

    free_page(p);
  104c27:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104c2e:	00 
  104c2f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104c32:	89 04 24             	mov    %eax,(%esp)
  104c35:	e8 dc df ff ff       	call   102c16 <free_pages>
    free_page(p1);
  104c3a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104c41:	00 
  104c42:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104c45:	89 04 24             	mov    %eax,(%esp)
  104c48:	e8 c9 df ff ff       	call   102c16 <free_pages>
    free_page(p2);
  104c4d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104c54:	00 
  104c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104c58:	89 04 24             	mov    %eax,(%esp)
  104c5b:	e8 b6 df ff ff       	call   102c16 <free_pages>
}
  104c60:	c9                   	leave  
  104c61:	c3                   	ret    

00104c62 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
  104c62:	55                   	push   %ebp
  104c63:	89 e5                	mov    %esp,%ebp
  104c65:	53                   	push   %ebx
  104c66:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
  104c6c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104c73:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
  104c7a:	c7 45 ec 1c af 11 00 	movl   $0x11af1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  104c81:	eb 6b                	jmp    104cee <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
  104c83:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104c86:	83 e8 0c             	sub    $0xc,%eax
  104c89:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
  104c8c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104c8f:	83 c0 04             	add    $0x4,%eax
  104c92:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  104c99:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104c9c:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104c9f:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104ca2:	0f a3 10             	bt     %edx,(%eax)
  104ca5:	19 c0                	sbb    %eax,%eax
  104ca7:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
  104caa:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  104cae:	0f 95 c0             	setne  %al
  104cb1:	0f b6 c0             	movzbl %al,%eax
  104cb4:	85 c0                	test   %eax,%eax
  104cb6:	75 24                	jne    104cdc <default_check+0x7a>
  104cb8:	c7 44 24 0c 4a 6d 10 	movl   $0x106d4a,0xc(%esp)
  104cbf:	00 
  104cc0:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  104cc7:	00 
  104cc8:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
  104ccf:	00 
  104cd0:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  104cd7:	e8 0d b7 ff ff       	call   1003e9 <__panic>
        count ++, total += p->property;
  104cdc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  104ce0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104ce3:	8b 50 08             	mov    0x8(%eax),%edx
  104ce6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104ce9:	01 d0                	add    %edx,%eax
  104ceb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104cee:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104cf1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
  104cf4:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104cf7:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  104cfa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104cfd:	81 7d ec 1c af 11 00 	cmpl   $0x11af1c,-0x14(%ebp)
  104d04:	0f 85 79 ff ff ff    	jne    104c83 <default_check+0x21>
    }
    assert(total == nr_free_pages());
  104d0a:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  104d0d:	e8 36 df ff ff       	call   102c48 <nr_free_pages>
  104d12:	39 c3                	cmp    %eax,%ebx
  104d14:	74 24                	je     104d3a <default_check+0xd8>
  104d16:	c7 44 24 0c 5a 6d 10 	movl   $0x106d5a,0xc(%esp)
  104d1d:	00 
  104d1e:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  104d25:	00 
  104d26:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
  104d2d:	00 
  104d2e:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  104d35:	e8 af b6 ff ff       	call   1003e9 <__panic>

    basic_check();
  104d3a:	e8 e7 f9 ff ff       	call   104726 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
  104d3f:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  104d46:	e8 93 de ff ff       	call   102bde <alloc_pages>
  104d4b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
  104d4e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  104d52:	75 24                	jne    104d78 <default_check+0x116>
  104d54:	c7 44 24 0c 73 6d 10 	movl   $0x106d73,0xc(%esp)
  104d5b:	00 
  104d5c:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  104d63:	00 
  104d64:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
  104d6b:	00 
  104d6c:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  104d73:	e8 71 b6 ff ff       	call   1003e9 <__panic>
    assert(!PageProperty(p0));
  104d78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104d7b:	83 c0 04             	add    $0x4,%eax
  104d7e:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  104d85:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104d88:	8b 45 bc             	mov    -0x44(%ebp),%eax
  104d8b:	8b 55 c0             	mov    -0x40(%ebp),%edx
  104d8e:	0f a3 10             	bt     %edx,(%eax)
  104d91:	19 c0                	sbb    %eax,%eax
  104d93:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
  104d96:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  104d9a:	0f 95 c0             	setne  %al
  104d9d:	0f b6 c0             	movzbl %al,%eax
  104da0:	85 c0                	test   %eax,%eax
  104da2:	74 24                	je     104dc8 <default_check+0x166>
  104da4:	c7 44 24 0c 7e 6d 10 	movl   $0x106d7e,0xc(%esp)
  104dab:	00 
  104dac:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  104db3:	00 
  104db4:	c7 44 24 04 1b 01 00 	movl   $0x11b,0x4(%esp)
  104dbb:	00 
  104dbc:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  104dc3:	e8 21 b6 ff ff       	call   1003e9 <__panic>

    list_entry_t free_list_store = free_list;
  104dc8:	a1 1c af 11 00       	mov    0x11af1c,%eax
  104dcd:	8b 15 20 af 11 00    	mov    0x11af20,%edx
  104dd3:	89 45 80             	mov    %eax,-0x80(%ebp)
  104dd6:	89 55 84             	mov    %edx,-0x7c(%ebp)
  104dd9:	c7 45 b4 1c af 11 00 	movl   $0x11af1c,-0x4c(%ebp)
    elm->prev = elm->next = elm;
  104de0:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104de3:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  104de6:	89 50 04             	mov    %edx,0x4(%eax)
  104de9:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104dec:	8b 50 04             	mov    0x4(%eax),%edx
  104def:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104df2:	89 10                	mov    %edx,(%eax)
  104df4:	c7 45 b0 1c af 11 00 	movl   $0x11af1c,-0x50(%ebp)
    return list->next == list;
  104dfb:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104dfe:	8b 40 04             	mov    0x4(%eax),%eax
  104e01:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  104e04:	0f 94 c0             	sete   %al
  104e07:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  104e0a:	85 c0                	test   %eax,%eax
  104e0c:	75 24                	jne    104e32 <default_check+0x1d0>
  104e0e:	c7 44 24 0c d3 6c 10 	movl   $0x106cd3,0xc(%esp)
  104e15:	00 
  104e16:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  104e1d:	00 
  104e1e:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
  104e25:	00 
  104e26:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  104e2d:	e8 b7 b5 ff ff       	call   1003e9 <__panic>
    assert(alloc_page() == NULL);
  104e32:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104e39:	e8 a0 dd ff ff       	call   102bde <alloc_pages>
  104e3e:	85 c0                	test   %eax,%eax
  104e40:	74 24                	je     104e66 <default_check+0x204>
  104e42:	c7 44 24 0c ea 6c 10 	movl   $0x106cea,0xc(%esp)
  104e49:	00 
  104e4a:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  104e51:	00 
  104e52:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
  104e59:	00 
  104e5a:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  104e61:	e8 83 b5 ff ff       	call   1003e9 <__panic>

    unsigned int nr_free_store = nr_free;
  104e66:	a1 24 af 11 00       	mov    0x11af24,%eax
  104e6b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
  104e6e:	c7 05 24 af 11 00 00 	movl   $0x0,0x11af24
  104e75:	00 00 00 

    free_pages(p0 + 2, 3);
  104e78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104e7b:	83 c0 28             	add    $0x28,%eax
  104e7e:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  104e85:	00 
  104e86:	89 04 24             	mov    %eax,(%esp)
  104e89:	e8 88 dd ff ff       	call   102c16 <free_pages>
    assert(alloc_pages(4) == NULL);
  104e8e:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  104e95:	e8 44 dd ff ff       	call   102bde <alloc_pages>
  104e9a:	85 c0                	test   %eax,%eax
  104e9c:	74 24                	je     104ec2 <default_check+0x260>
  104e9e:	c7 44 24 0c 90 6d 10 	movl   $0x106d90,0xc(%esp)
  104ea5:	00 
  104ea6:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  104ead:	00 
  104eae:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
  104eb5:	00 
  104eb6:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  104ebd:	e8 27 b5 ff ff       	call   1003e9 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
  104ec2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104ec5:	83 c0 28             	add    $0x28,%eax
  104ec8:	83 c0 04             	add    $0x4,%eax
  104ecb:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
  104ed2:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104ed5:	8b 45 a8             	mov    -0x58(%ebp),%eax
  104ed8:	8b 55 ac             	mov    -0x54(%ebp),%edx
  104edb:	0f a3 10             	bt     %edx,(%eax)
  104ede:	19 c0                	sbb    %eax,%eax
  104ee0:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
  104ee3:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  104ee7:	0f 95 c0             	setne  %al
  104eea:	0f b6 c0             	movzbl %al,%eax
  104eed:	85 c0                	test   %eax,%eax
  104eef:	74 0e                	je     104eff <default_check+0x29d>
  104ef1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104ef4:	83 c0 28             	add    $0x28,%eax
  104ef7:	8b 40 08             	mov    0x8(%eax),%eax
  104efa:	83 f8 03             	cmp    $0x3,%eax
  104efd:	74 24                	je     104f23 <default_check+0x2c1>
  104eff:	c7 44 24 0c a8 6d 10 	movl   $0x106da8,0xc(%esp)
  104f06:	00 
  104f07:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  104f0e:	00 
  104f0f:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
  104f16:	00 
  104f17:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  104f1e:	e8 c6 b4 ff ff       	call   1003e9 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
  104f23:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  104f2a:	e8 af dc ff ff       	call   102bde <alloc_pages>
  104f2f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  104f32:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  104f36:	75 24                	jne    104f5c <default_check+0x2fa>
  104f38:	c7 44 24 0c d4 6d 10 	movl   $0x106dd4,0xc(%esp)
  104f3f:	00 
  104f40:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  104f47:	00 
  104f48:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
  104f4f:	00 
  104f50:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  104f57:	e8 8d b4 ff ff       	call   1003e9 <__panic>
    assert(alloc_page() == NULL);
  104f5c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104f63:	e8 76 dc ff ff       	call   102bde <alloc_pages>
  104f68:	85 c0                	test   %eax,%eax
  104f6a:	74 24                	je     104f90 <default_check+0x32e>
  104f6c:	c7 44 24 0c ea 6c 10 	movl   $0x106cea,0xc(%esp)
  104f73:	00 
  104f74:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  104f7b:	00 
  104f7c:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
  104f83:	00 
  104f84:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  104f8b:	e8 59 b4 ff ff       	call   1003e9 <__panic>
    assert(p0 + 2 == p1);
  104f90:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104f93:	83 c0 28             	add    $0x28,%eax
  104f96:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  104f99:	74 24                	je     104fbf <default_check+0x35d>
  104f9b:	c7 44 24 0c f2 6d 10 	movl   $0x106df2,0xc(%esp)
  104fa2:	00 
  104fa3:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  104faa:	00 
  104fab:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
  104fb2:	00 
  104fb3:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  104fba:	e8 2a b4 ff ff       	call   1003e9 <__panic>

    p2 = p0 + 1;
  104fbf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104fc2:	83 c0 14             	add    $0x14,%eax
  104fc5:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
  104fc8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104fcf:	00 
  104fd0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104fd3:	89 04 24             	mov    %eax,(%esp)
  104fd6:	e8 3b dc ff ff       	call   102c16 <free_pages>
    free_pages(p1, 3);
  104fdb:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  104fe2:	00 
  104fe3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104fe6:	89 04 24             	mov    %eax,(%esp)
  104fe9:	e8 28 dc ff ff       	call   102c16 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
  104fee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104ff1:	83 c0 04             	add    $0x4,%eax
  104ff4:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
  104ffb:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104ffe:	8b 45 9c             	mov    -0x64(%ebp),%eax
  105001:	8b 55 a0             	mov    -0x60(%ebp),%edx
  105004:	0f a3 10             	bt     %edx,(%eax)
  105007:	19 c0                	sbb    %eax,%eax
  105009:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
  10500c:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
  105010:	0f 95 c0             	setne  %al
  105013:	0f b6 c0             	movzbl %al,%eax
  105016:	85 c0                	test   %eax,%eax
  105018:	74 0b                	je     105025 <default_check+0x3c3>
  10501a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10501d:	8b 40 08             	mov    0x8(%eax),%eax
  105020:	83 f8 01             	cmp    $0x1,%eax
  105023:	74 24                	je     105049 <default_check+0x3e7>
  105025:	c7 44 24 0c 00 6e 10 	movl   $0x106e00,0xc(%esp)
  10502c:	00 
  10502d:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  105034:	00 
  105035:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
  10503c:	00 
  10503d:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  105044:	e8 a0 b3 ff ff       	call   1003e9 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
  105049:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10504c:	83 c0 04             	add    $0x4,%eax
  10504f:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
  105056:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105059:	8b 45 90             	mov    -0x70(%ebp),%eax
  10505c:	8b 55 94             	mov    -0x6c(%ebp),%edx
  10505f:	0f a3 10             	bt     %edx,(%eax)
  105062:	19 c0                	sbb    %eax,%eax
  105064:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
  105067:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
  10506b:	0f 95 c0             	setne  %al
  10506e:	0f b6 c0             	movzbl %al,%eax
  105071:	85 c0                	test   %eax,%eax
  105073:	74 0b                	je     105080 <default_check+0x41e>
  105075:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105078:	8b 40 08             	mov    0x8(%eax),%eax
  10507b:	83 f8 03             	cmp    $0x3,%eax
  10507e:	74 24                	je     1050a4 <default_check+0x442>
  105080:	c7 44 24 0c 28 6e 10 	movl   $0x106e28,0xc(%esp)
  105087:	00 
  105088:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  10508f:	00 
  105090:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
  105097:	00 
  105098:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  10509f:	e8 45 b3 ff ff       	call   1003e9 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
  1050a4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1050ab:	e8 2e db ff ff       	call   102bde <alloc_pages>
  1050b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1050b3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1050b6:	83 e8 14             	sub    $0x14,%eax
  1050b9:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  1050bc:	74 24                	je     1050e2 <default_check+0x480>
  1050be:	c7 44 24 0c 4e 6e 10 	movl   $0x106e4e,0xc(%esp)
  1050c5:	00 
  1050c6:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  1050cd:	00 
  1050ce:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
  1050d5:	00 
  1050d6:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  1050dd:	e8 07 b3 ff ff       	call   1003e9 <__panic>
    free_page(p0);
  1050e2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1050e9:	00 
  1050ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1050ed:	89 04 24             	mov    %eax,(%esp)
  1050f0:	e8 21 db ff ff       	call   102c16 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
  1050f5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1050fc:	e8 dd da ff ff       	call   102bde <alloc_pages>
  105101:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105104:	8b 45 d8             	mov    -0x28(%ebp),%eax
  105107:	83 c0 14             	add    $0x14,%eax
  10510a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  10510d:	74 24                	je     105133 <default_check+0x4d1>
  10510f:	c7 44 24 0c 6c 6e 10 	movl   $0x106e6c,0xc(%esp)
  105116:	00 
  105117:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  10511e:	00 
  10511f:	c7 44 24 04 34 01 00 	movl   $0x134,0x4(%esp)
  105126:	00 
  105127:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  10512e:	e8 b6 b2 ff ff       	call   1003e9 <__panic>

    free_pages(p0, 2);
  105133:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  10513a:	00 
  10513b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10513e:	89 04 24             	mov    %eax,(%esp)
  105141:	e8 d0 da ff ff       	call   102c16 <free_pages>
    free_page(p2);
  105146:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10514d:	00 
  10514e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  105151:	89 04 24             	mov    %eax,(%esp)
  105154:	e8 bd da ff ff       	call   102c16 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
  105159:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  105160:	e8 79 da ff ff       	call   102bde <alloc_pages>
  105165:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105168:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10516c:	75 24                	jne    105192 <default_check+0x530>
  10516e:	c7 44 24 0c 8c 6e 10 	movl   $0x106e8c,0xc(%esp)
  105175:	00 
  105176:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  10517d:	00 
  10517e:	c7 44 24 04 39 01 00 	movl   $0x139,0x4(%esp)
  105185:	00 
  105186:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  10518d:	e8 57 b2 ff ff       	call   1003e9 <__panic>
    assert(alloc_page() == NULL);
  105192:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105199:	e8 40 da ff ff       	call   102bde <alloc_pages>
  10519e:	85 c0                	test   %eax,%eax
  1051a0:	74 24                	je     1051c6 <default_check+0x564>
  1051a2:	c7 44 24 0c ea 6c 10 	movl   $0x106cea,0xc(%esp)
  1051a9:	00 
  1051aa:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  1051b1:	00 
  1051b2:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
  1051b9:	00 
  1051ba:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  1051c1:	e8 23 b2 ff ff       	call   1003e9 <__panic>

    assert(nr_free == 0);
  1051c6:	a1 24 af 11 00       	mov    0x11af24,%eax
  1051cb:	85 c0                	test   %eax,%eax
  1051cd:	74 24                	je     1051f3 <default_check+0x591>
  1051cf:	c7 44 24 0c 3d 6d 10 	movl   $0x106d3d,0xc(%esp)
  1051d6:	00 
  1051d7:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  1051de:	00 
  1051df:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
  1051e6:	00 
  1051e7:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  1051ee:	e8 f6 b1 ff ff       	call   1003e9 <__panic>
    nr_free = nr_free_store;
  1051f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1051f6:	a3 24 af 11 00       	mov    %eax,0x11af24

    free_list = free_list_store;
  1051fb:	8b 45 80             	mov    -0x80(%ebp),%eax
  1051fe:	8b 55 84             	mov    -0x7c(%ebp),%edx
  105201:	a3 1c af 11 00       	mov    %eax,0x11af1c
  105206:	89 15 20 af 11 00    	mov    %edx,0x11af20
    free_pages(p0, 5);
  10520c:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  105213:	00 
  105214:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105217:	89 04 24             	mov    %eax,(%esp)
  10521a:	e8 f7 d9 ff ff       	call   102c16 <free_pages>

    le = &free_list;
  10521f:	c7 45 ec 1c af 11 00 	movl   $0x11af1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  105226:	eb 1d                	jmp    105245 <default_check+0x5e3>
        struct Page *p = le2page(le, page_link);
  105228:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10522b:	83 e8 0c             	sub    $0xc,%eax
  10522e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
  105231:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  105235:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105238:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10523b:	8b 40 08             	mov    0x8(%eax),%eax
  10523e:	29 c2                	sub    %eax,%edx
  105240:	89 d0                	mov    %edx,%eax
  105242:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105245:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105248:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
  10524b:	8b 45 88             	mov    -0x78(%ebp),%eax
  10524e:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  105251:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105254:	81 7d ec 1c af 11 00 	cmpl   $0x11af1c,-0x14(%ebp)
  10525b:	75 cb                	jne    105228 <default_check+0x5c6>
    }
    assert(count == 0);
  10525d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  105261:	74 24                	je     105287 <default_check+0x625>
  105263:	c7 44 24 0c aa 6e 10 	movl   $0x106eaa,0xc(%esp)
  10526a:	00 
  10526b:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  105272:	00 
  105273:	c7 44 24 04 47 01 00 	movl   $0x147,0x4(%esp)
  10527a:	00 
  10527b:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  105282:	e8 62 b1 ff ff       	call   1003e9 <__panic>
    assert(total == 0);
  105287:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10528b:	74 24                	je     1052b1 <default_check+0x64f>
  10528d:	c7 44 24 0c b5 6e 10 	movl   $0x106eb5,0xc(%esp)
  105294:	00 
  105295:	c7 44 24 08 7a 6b 10 	movl   $0x106b7a,0x8(%esp)
  10529c:	00 
  10529d:	c7 44 24 04 48 01 00 	movl   $0x148,0x4(%esp)
  1052a4:	00 
  1052a5:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  1052ac:	e8 38 b1 ff ff       	call   1003e9 <__panic>
}
  1052b1:	81 c4 94 00 00 00    	add    $0x94,%esp
  1052b7:	5b                   	pop    %ebx
  1052b8:	5d                   	pop    %ebp
  1052b9:	c3                   	ret    

001052ba <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  1052ba:	55                   	push   %ebp
  1052bb:	89 e5                	mov    %esp,%ebp
  1052bd:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  1052c0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  1052c7:	eb 04                	jmp    1052cd <strlen+0x13>
        cnt ++;
  1052c9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (*s ++ != '\0') {
  1052cd:	8b 45 08             	mov    0x8(%ebp),%eax
  1052d0:	8d 50 01             	lea    0x1(%eax),%edx
  1052d3:	89 55 08             	mov    %edx,0x8(%ebp)
  1052d6:	0f b6 00             	movzbl (%eax),%eax
  1052d9:	84 c0                	test   %al,%al
  1052db:	75 ec                	jne    1052c9 <strlen+0xf>
    }
    return cnt;
  1052dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1052e0:	c9                   	leave  
  1052e1:	c3                   	ret    

001052e2 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  1052e2:	55                   	push   %ebp
  1052e3:	89 e5                	mov    %esp,%ebp
  1052e5:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  1052e8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  1052ef:	eb 04                	jmp    1052f5 <strnlen+0x13>
        cnt ++;
  1052f1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  1052f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1052f8:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1052fb:	73 10                	jae    10530d <strnlen+0x2b>
  1052fd:	8b 45 08             	mov    0x8(%ebp),%eax
  105300:	8d 50 01             	lea    0x1(%eax),%edx
  105303:	89 55 08             	mov    %edx,0x8(%ebp)
  105306:	0f b6 00             	movzbl (%eax),%eax
  105309:	84 c0                	test   %al,%al
  10530b:	75 e4                	jne    1052f1 <strnlen+0xf>
    }
    return cnt;
  10530d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  105310:	c9                   	leave  
  105311:	c3                   	ret    

00105312 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  105312:	55                   	push   %ebp
  105313:	89 e5                	mov    %esp,%ebp
  105315:	57                   	push   %edi
  105316:	56                   	push   %esi
  105317:	83 ec 20             	sub    $0x20,%esp
  10531a:	8b 45 08             	mov    0x8(%ebp),%eax
  10531d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105320:	8b 45 0c             	mov    0xc(%ebp),%eax
  105323:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  105326:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105329:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10532c:	89 d1                	mov    %edx,%ecx
  10532e:	89 c2                	mov    %eax,%edx
  105330:	89 ce                	mov    %ecx,%esi
  105332:	89 d7                	mov    %edx,%edi
  105334:	ac                   	lods   %ds:(%esi),%al
  105335:	aa                   	stos   %al,%es:(%edi)
  105336:	84 c0                	test   %al,%al
  105338:	75 fa                	jne    105334 <strcpy+0x22>
  10533a:	89 fa                	mov    %edi,%edx
  10533c:	89 f1                	mov    %esi,%ecx
  10533e:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  105341:	89 55 e8             	mov    %edx,-0x18(%ebp)
  105344:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  105347:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  10534a:	83 c4 20             	add    $0x20,%esp
  10534d:	5e                   	pop    %esi
  10534e:	5f                   	pop    %edi
  10534f:	5d                   	pop    %ebp
  105350:	c3                   	ret    

00105351 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  105351:	55                   	push   %ebp
  105352:	89 e5                	mov    %esp,%ebp
  105354:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  105357:	8b 45 08             	mov    0x8(%ebp),%eax
  10535a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  10535d:	eb 21                	jmp    105380 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
  10535f:	8b 45 0c             	mov    0xc(%ebp),%eax
  105362:	0f b6 10             	movzbl (%eax),%edx
  105365:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105368:	88 10                	mov    %dl,(%eax)
  10536a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10536d:	0f b6 00             	movzbl (%eax),%eax
  105370:	84 c0                	test   %al,%al
  105372:	74 04                	je     105378 <strncpy+0x27>
            src ++;
  105374:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
  105378:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  10537c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    while (len > 0) {
  105380:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105384:	75 d9                	jne    10535f <strncpy+0xe>
    }
    return dst;
  105386:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105389:	c9                   	leave  
  10538a:	c3                   	ret    

0010538b <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  10538b:	55                   	push   %ebp
  10538c:	89 e5                	mov    %esp,%ebp
  10538e:	57                   	push   %edi
  10538f:	56                   	push   %esi
  105390:	83 ec 20             	sub    $0x20,%esp
  105393:	8b 45 08             	mov    0x8(%ebp),%eax
  105396:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105399:	8b 45 0c             	mov    0xc(%ebp),%eax
  10539c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  10539f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1053a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1053a5:	89 d1                	mov    %edx,%ecx
  1053a7:	89 c2                	mov    %eax,%edx
  1053a9:	89 ce                	mov    %ecx,%esi
  1053ab:	89 d7                	mov    %edx,%edi
  1053ad:	ac                   	lods   %ds:(%esi),%al
  1053ae:	ae                   	scas   %es:(%edi),%al
  1053af:	75 08                	jne    1053b9 <strcmp+0x2e>
  1053b1:	84 c0                	test   %al,%al
  1053b3:	75 f8                	jne    1053ad <strcmp+0x22>
  1053b5:	31 c0                	xor    %eax,%eax
  1053b7:	eb 04                	jmp    1053bd <strcmp+0x32>
  1053b9:	19 c0                	sbb    %eax,%eax
  1053bb:	0c 01                	or     $0x1,%al
  1053bd:	89 fa                	mov    %edi,%edx
  1053bf:	89 f1                	mov    %esi,%ecx
  1053c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1053c4:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  1053c7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  1053ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  1053cd:	83 c4 20             	add    $0x20,%esp
  1053d0:	5e                   	pop    %esi
  1053d1:	5f                   	pop    %edi
  1053d2:	5d                   	pop    %ebp
  1053d3:	c3                   	ret    

001053d4 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  1053d4:	55                   	push   %ebp
  1053d5:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  1053d7:	eb 0c                	jmp    1053e5 <strncmp+0x11>
        n --, s1 ++, s2 ++;
  1053d9:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  1053dd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  1053e1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  1053e5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1053e9:	74 1a                	je     105405 <strncmp+0x31>
  1053eb:	8b 45 08             	mov    0x8(%ebp),%eax
  1053ee:	0f b6 00             	movzbl (%eax),%eax
  1053f1:	84 c0                	test   %al,%al
  1053f3:	74 10                	je     105405 <strncmp+0x31>
  1053f5:	8b 45 08             	mov    0x8(%ebp),%eax
  1053f8:	0f b6 10             	movzbl (%eax),%edx
  1053fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1053fe:	0f b6 00             	movzbl (%eax),%eax
  105401:	38 c2                	cmp    %al,%dl
  105403:	74 d4                	je     1053d9 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  105405:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105409:	74 18                	je     105423 <strncmp+0x4f>
  10540b:	8b 45 08             	mov    0x8(%ebp),%eax
  10540e:	0f b6 00             	movzbl (%eax),%eax
  105411:	0f b6 d0             	movzbl %al,%edx
  105414:	8b 45 0c             	mov    0xc(%ebp),%eax
  105417:	0f b6 00             	movzbl (%eax),%eax
  10541a:	0f b6 c0             	movzbl %al,%eax
  10541d:	29 c2                	sub    %eax,%edx
  10541f:	89 d0                	mov    %edx,%eax
  105421:	eb 05                	jmp    105428 <strncmp+0x54>
  105423:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105428:	5d                   	pop    %ebp
  105429:	c3                   	ret    

0010542a <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  10542a:	55                   	push   %ebp
  10542b:	89 e5                	mov    %esp,%ebp
  10542d:	83 ec 04             	sub    $0x4,%esp
  105430:	8b 45 0c             	mov    0xc(%ebp),%eax
  105433:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105436:	eb 14                	jmp    10544c <strchr+0x22>
        if (*s == c) {
  105438:	8b 45 08             	mov    0x8(%ebp),%eax
  10543b:	0f b6 00             	movzbl (%eax),%eax
  10543e:	3a 45 fc             	cmp    -0x4(%ebp),%al
  105441:	75 05                	jne    105448 <strchr+0x1e>
            return (char *)s;
  105443:	8b 45 08             	mov    0x8(%ebp),%eax
  105446:	eb 13                	jmp    10545b <strchr+0x31>
        }
        s ++;
  105448:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
  10544c:	8b 45 08             	mov    0x8(%ebp),%eax
  10544f:	0f b6 00             	movzbl (%eax),%eax
  105452:	84 c0                	test   %al,%al
  105454:	75 e2                	jne    105438 <strchr+0xe>
    }
    return NULL;
  105456:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10545b:	c9                   	leave  
  10545c:	c3                   	ret    

0010545d <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  10545d:	55                   	push   %ebp
  10545e:	89 e5                	mov    %esp,%ebp
  105460:	83 ec 04             	sub    $0x4,%esp
  105463:	8b 45 0c             	mov    0xc(%ebp),%eax
  105466:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105469:	eb 11                	jmp    10547c <strfind+0x1f>
        if (*s == c) {
  10546b:	8b 45 08             	mov    0x8(%ebp),%eax
  10546e:	0f b6 00             	movzbl (%eax),%eax
  105471:	3a 45 fc             	cmp    -0x4(%ebp),%al
  105474:	75 02                	jne    105478 <strfind+0x1b>
            break;
  105476:	eb 0e                	jmp    105486 <strfind+0x29>
        }
        s ++;
  105478:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
  10547c:	8b 45 08             	mov    0x8(%ebp),%eax
  10547f:	0f b6 00             	movzbl (%eax),%eax
  105482:	84 c0                	test   %al,%al
  105484:	75 e5                	jne    10546b <strfind+0xe>
    }
    return (char *)s;
  105486:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105489:	c9                   	leave  
  10548a:	c3                   	ret    

0010548b <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  10548b:	55                   	push   %ebp
  10548c:	89 e5                	mov    %esp,%ebp
  10548e:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  105491:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  105498:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  10549f:	eb 04                	jmp    1054a5 <strtol+0x1a>
        s ++;
  1054a1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  1054a5:	8b 45 08             	mov    0x8(%ebp),%eax
  1054a8:	0f b6 00             	movzbl (%eax),%eax
  1054ab:	3c 20                	cmp    $0x20,%al
  1054ad:	74 f2                	je     1054a1 <strtol+0x16>
  1054af:	8b 45 08             	mov    0x8(%ebp),%eax
  1054b2:	0f b6 00             	movzbl (%eax),%eax
  1054b5:	3c 09                	cmp    $0x9,%al
  1054b7:	74 e8                	je     1054a1 <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
  1054b9:	8b 45 08             	mov    0x8(%ebp),%eax
  1054bc:	0f b6 00             	movzbl (%eax),%eax
  1054bf:	3c 2b                	cmp    $0x2b,%al
  1054c1:	75 06                	jne    1054c9 <strtol+0x3e>
        s ++;
  1054c3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  1054c7:	eb 15                	jmp    1054de <strtol+0x53>
    }
    else if (*s == '-') {
  1054c9:	8b 45 08             	mov    0x8(%ebp),%eax
  1054cc:	0f b6 00             	movzbl (%eax),%eax
  1054cf:	3c 2d                	cmp    $0x2d,%al
  1054d1:	75 0b                	jne    1054de <strtol+0x53>
        s ++, neg = 1;
  1054d3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  1054d7:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  1054de:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1054e2:	74 06                	je     1054ea <strtol+0x5f>
  1054e4:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  1054e8:	75 24                	jne    10550e <strtol+0x83>
  1054ea:	8b 45 08             	mov    0x8(%ebp),%eax
  1054ed:	0f b6 00             	movzbl (%eax),%eax
  1054f0:	3c 30                	cmp    $0x30,%al
  1054f2:	75 1a                	jne    10550e <strtol+0x83>
  1054f4:	8b 45 08             	mov    0x8(%ebp),%eax
  1054f7:	83 c0 01             	add    $0x1,%eax
  1054fa:	0f b6 00             	movzbl (%eax),%eax
  1054fd:	3c 78                	cmp    $0x78,%al
  1054ff:	75 0d                	jne    10550e <strtol+0x83>
        s += 2, base = 16;
  105501:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  105505:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  10550c:	eb 2a                	jmp    105538 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
  10550e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105512:	75 17                	jne    10552b <strtol+0xa0>
  105514:	8b 45 08             	mov    0x8(%ebp),%eax
  105517:	0f b6 00             	movzbl (%eax),%eax
  10551a:	3c 30                	cmp    $0x30,%al
  10551c:	75 0d                	jne    10552b <strtol+0xa0>
        s ++, base = 8;
  10551e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105522:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  105529:	eb 0d                	jmp    105538 <strtol+0xad>
    }
    else if (base == 0) {
  10552b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10552f:	75 07                	jne    105538 <strtol+0xad>
        base = 10;
  105531:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  105538:	8b 45 08             	mov    0x8(%ebp),%eax
  10553b:	0f b6 00             	movzbl (%eax),%eax
  10553e:	3c 2f                	cmp    $0x2f,%al
  105540:	7e 1b                	jle    10555d <strtol+0xd2>
  105542:	8b 45 08             	mov    0x8(%ebp),%eax
  105545:	0f b6 00             	movzbl (%eax),%eax
  105548:	3c 39                	cmp    $0x39,%al
  10554a:	7f 11                	jg     10555d <strtol+0xd2>
            dig = *s - '0';
  10554c:	8b 45 08             	mov    0x8(%ebp),%eax
  10554f:	0f b6 00             	movzbl (%eax),%eax
  105552:	0f be c0             	movsbl %al,%eax
  105555:	83 e8 30             	sub    $0x30,%eax
  105558:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10555b:	eb 48                	jmp    1055a5 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
  10555d:	8b 45 08             	mov    0x8(%ebp),%eax
  105560:	0f b6 00             	movzbl (%eax),%eax
  105563:	3c 60                	cmp    $0x60,%al
  105565:	7e 1b                	jle    105582 <strtol+0xf7>
  105567:	8b 45 08             	mov    0x8(%ebp),%eax
  10556a:	0f b6 00             	movzbl (%eax),%eax
  10556d:	3c 7a                	cmp    $0x7a,%al
  10556f:	7f 11                	jg     105582 <strtol+0xf7>
            dig = *s - 'a' + 10;
  105571:	8b 45 08             	mov    0x8(%ebp),%eax
  105574:	0f b6 00             	movzbl (%eax),%eax
  105577:	0f be c0             	movsbl %al,%eax
  10557a:	83 e8 57             	sub    $0x57,%eax
  10557d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105580:	eb 23                	jmp    1055a5 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  105582:	8b 45 08             	mov    0x8(%ebp),%eax
  105585:	0f b6 00             	movzbl (%eax),%eax
  105588:	3c 40                	cmp    $0x40,%al
  10558a:	7e 3d                	jle    1055c9 <strtol+0x13e>
  10558c:	8b 45 08             	mov    0x8(%ebp),%eax
  10558f:	0f b6 00             	movzbl (%eax),%eax
  105592:	3c 5a                	cmp    $0x5a,%al
  105594:	7f 33                	jg     1055c9 <strtol+0x13e>
            dig = *s - 'A' + 10;
  105596:	8b 45 08             	mov    0x8(%ebp),%eax
  105599:	0f b6 00             	movzbl (%eax),%eax
  10559c:	0f be c0             	movsbl %al,%eax
  10559f:	83 e8 37             	sub    $0x37,%eax
  1055a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  1055a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1055a8:	3b 45 10             	cmp    0x10(%ebp),%eax
  1055ab:	7c 02                	jl     1055af <strtol+0x124>
            break;
  1055ad:	eb 1a                	jmp    1055c9 <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
  1055af:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  1055b3:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1055b6:	0f af 45 10          	imul   0x10(%ebp),%eax
  1055ba:	89 c2                	mov    %eax,%edx
  1055bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1055bf:	01 d0                	add    %edx,%eax
  1055c1:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
  1055c4:	e9 6f ff ff ff       	jmp    105538 <strtol+0xad>

    if (endptr) {
  1055c9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1055cd:	74 08                	je     1055d7 <strtol+0x14c>
        *endptr = (char *) s;
  1055cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  1055d2:	8b 55 08             	mov    0x8(%ebp),%edx
  1055d5:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  1055d7:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  1055db:	74 07                	je     1055e4 <strtol+0x159>
  1055dd:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1055e0:	f7 d8                	neg    %eax
  1055e2:	eb 03                	jmp    1055e7 <strtol+0x15c>
  1055e4:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  1055e7:	c9                   	leave  
  1055e8:	c3                   	ret    

001055e9 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  1055e9:	55                   	push   %ebp
  1055ea:	89 e5                	mov    %esp,%ebp
  1055ec:	57                   	push   %edi
  1055ed:	83 ec 24             	sub    $0x24,%esp
  1055f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1055f3:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  1055f6:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  1055fa:	8b 55 08             	mov    0x8(%ebp),%edx
  1055fd:	89 55 f8             	mov    %edx,-0x8(%ebp)
  105600:	88 45 f7             	mov    %al,-0x9(%ebp)
  105603:	8b 45 10             	mov    0x10(%ebp),%eax
  105606:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  105609:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  10560c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  105610:	8b 55 f8             	mov    -0x8(%ebp),%edx
  105613:	89 d7                	mov    %edx,%edi
  105615:	f3 aa                	rep stos %al,%es:(%edi)
  105617:	89 fa                	mov    %edi,%edx
  105619:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  10561c:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  10561f:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  105622:	83 c4 24             	add    $0x24,%esp
  105625:	5f                   	pop    %edi
  105626:	5d                   	pop    %ebp
  105627:	c3                   	ret    

00105628 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  105628:	55                   	push   %ebp
  105629:	89 e5                	mov    %esp,%ebp
  10562b:	57                   	push   %edi
  10562c:	56                   	push   %esi
  10562d:	53                   	push   %ebx
  10562e:	83 ec 30             	sub    $0x30,%esp
  105631:	8b 45 08             	mov    0x8(%ebp),%eax
  105634:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105637:	8b 45 0c             	mov    0xc(%ebp),%eax
  10563a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10563d:	8b 45 10             	mov    0x10(%ebp),%eax
  105640:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  105643:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105646:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  105649:	73 42                	jae    10568d <memmove+0x65>
  10564b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10564e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105651:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105654:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105657:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10565a:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  10565d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105660:	c1 e8 02             	shr    $0x2,%eax
  105663:	89 c1                	mov    %eax,%ecx
    asm volatile (
  105665:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105668:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10566b:	89 d7                	mov    %edx,%edi
  10566d:	89 c6                	mov    %eax,%esi
  10566f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  105671:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  105674:	83 e1 03             	and    $0x3,%ecx
  105677:	74 02                	je     10567b <memmove+0x53>
  105679:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  10567b:	89 f0                	mov    %esi,%eax
  10567d:	89 fa                	mov    %edi,%edx
  10567f:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  105682:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  105685:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
  105688:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10568b:	eb 36                	jmp    1056c3 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  10568d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105690:	8d 50 ff             	lea    -0x1(%eax),%edx
  105693:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105696:	01 c2                	add    %eax,%edx
  105698:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10569b:	8d 48 ff             	lea    -0x1(%eax),%ecx
  10569e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1056a1:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  1056a4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1056a7:	89 c1                	mov    %eax,%ecx
  1056a9:	89 d8                	mov    %ebx,%eax
  1056ab:	89 d6                	mov    %edx,%esi
  1056ad:	89 c7                	mov    %eax,%edi
  1056af:	fd                   	std    
  1056b0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  1056b2:	fc                   	cld    
  1056b3:	89 f8                	mov    %edi,%eax
  1056b5:	89 f2                	mov    %esi,%edx
  1056b7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  1056ba:	89 55 c8             	mov    %edx,-0x38(%ebp)
  1056bd:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  1056c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  1056c3:	83 c4 30             	add    $0x30,%esp
  1056c6:	5b                   	pop    %ebx
  1056c7:	5e                   	pop    %esi
  1056c8:	5f                   	pop    %edi
  1056c9:	5d                   	pop    %ebp
  1056ca:	c3                   	ret    

001056cb <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  1056cb:	55                   	push   %ebp
  1056cc:	89 e5                	mov    %esp,%ebp
  1056ce:	57                   	push   %edi
  1056cf:	56                   	push   %esi
  1056d0:	83 ec 20             	sub    $0x20,%esp
  1056d3:	8b 45 08             	mov    0x8(%ebp),%eax
  1056d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1056d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1056dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1056df:	8b 45 10             	mov    0x10(%ebp),%eax
  1056e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  1056e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1056e8:	c1 e8 02             	shr    $0x2,%eax
  1056eb:	89 c1                	mov    %eax,%ecx
    asm volatile (
  1056ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1056f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1056f3:	89 d7                	mov    %edx,%edi
  1056f5:	89 c6                	mov    %eax,%esi
  1056f7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  1056f9:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  1056fc:	83 e1 03             	and    $0x3,%ecx
  1056ff:	74 02                	je     105703 <memcpy+0x38>
  105701:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105703:	89 f0                	mov    %esi,%eax
  105705:	89 fa                	mov    %edi,%edx
  105707:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  10570a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  10570d:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  105710:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  105713:	83 c4 20             	add    $0x20,%esp
  105716:	5e                   	pop    %esi
  105717:	5f                   	pop    %edi
  105718:	5d                   	pop    %ebp
  105719:	c3                   	ret    

0010571a <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  10571a:	55                   	push   %ebp
  10571b:	89 e5                	mov    %esp,%ebp
  10571d:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  105720:	8b 45 08             	mov    0x8(%ebp),%eax
  105723:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  105726:	8b 45 0c             	mov    0xc(%ebp),%eax
  105729:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  10572c:	eb 30                	jmp    10575e <memcmp+0x44>
        if (*s1 != *s2) {
  10572e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105731:	0f b6 10             	movzbl (%eax),%edx
  105734:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105737:	0f b6 00             	movzbl (%eax),%eax
  10573a:	38 c2                	cmp    %al,%dl
  10573c:	74 18                	je     105756 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  10573e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105741:	0f b6 00             	movzbl (%eax),%eax
  105744:	0f b6 d0             	movzbl %al,%edx
  105747:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10574a:	0f b6 00             	movzbl (%eax),%eax
  10574d:	0f b6 c0             	movzbl %al,%eax
  105750:	29 c2                	sub    %eax,%edx
  105752:	89 d0                	mov    %edx,%eax
  105754:	eb 1a                	jmp    105770 <memcmp+0x56>
        }
        s1 ++, s2 ++;
  105756:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  10575a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
    while (n -- > 0) {
  10575e:	8b 45 10             	mov    0x10(%ebp),%eax
  105761:	8d 50 ff             	lea    -0x1(%eax),%edx
  105764:	89 55 10             	mov    %edx,0x10(%ebp)
  105767:	85 c0                	test   %eax,%eax
  105769:	75 c3                	jne    10572e <memcmp+0x14>
    }
    return 0;
  10576b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105770:	c9                   	leave  
  105771:	c3                   	ret    

00105772 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  105772:	55                   	push   %ebp
  105773:	89 e5                	mov    %esp,%ebp
  105775:	83 ec 58             	sub    $0x58,%esp
  105778:	8b 45 10             	mov    0x10(%ebp),%eax
  10577b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10577e:	8b 45 14             	mov    0x14(%ebp),%eax
  105781:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  105784:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105787:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10578a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10578d:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  105790:	8b 45 18             	mov    0x18(%ebp),%eax
  105793:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105796:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105799:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10579c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10579f:	89 55 f0             	mov    %edx,-0x10(%ebp)
  1057a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1057a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1057a8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1057ac:	74 1c                	je     1057ca <printnum+0x58>
  1057ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1057b1:	ba 00 00 00 00       	mov    $0x0,%edx
  1057b6:	f7 75 e4             	divl   -0x1c(%ebp)
  1057b9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  1057bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1057bf:	ba 00 00 00 00       	mov    $0x0,%edx
  1057c4:	f7 75 e4             	divl   -0x1c(%ebp)
  1057c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1057ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1057cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1057d0:	f7 75 e4             	divl   -0x1c(%ebp)
  1057d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1057d6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  1057d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1057dc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1057df:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1057e2:	89 55 ec             	mov    %edx,-0x14(%ebp)
  1057e5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1057e8:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  1057eb:	8b 45 18             	mov    0x18(%ebp),%eax
  1057ee:	ba 00 00 00 00       	mov    $0x0,%edx
  1057f3:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  1057f6:	77 56                	ja     10584e <printnum+0xdc>
  1057f8:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  1057fb:	72 05                	jb     105802 <printnum+0x90>
  1057fd:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  105800:	77 4c                	ja     10584e <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  105802:	8b 45 1c             	mov    0x1c(%ebp),%eax
  105805:	8d 50 ff             	lea    -0x1(%eax),%edx
  105808:	8b 45 20             	mov    0x20(%ebp),%eax
  10580b:	89 44 24 18          	mov    %eax,0x18(%esp)
  10580f:	89 54 24 14          	mov    %edx,0x14(%esp)
  105813:	8b 45 18             	mov    0x18(%ebp),%eax
  105816:	89 44 24 10          	mov    %eax,0x10(%esp)
  10581a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10581d:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105820:	89 44 24 08          	mov    %eax,0x8(%esp)
  105824:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105828:	8b 45 0c             	mov    0xc(%ebp),%eax
  10582b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10582f:	8b 45 08             	mov    0x8(%ebp),%eax
  105832:	89 04 24             	mov    %eax,(%esp)
  105835:	e8 38 ff ff ff       	call   105772 <printnum>
  10583a:	eb 1c                	jmp    105858 <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  10583c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10583f:	89 44 24 04          	mov    %eax,0x4(%esp)
  105843:	8b 45 20             	mov    0x20(%ebp),%eax
  105846:	89 04 24             	mov    %eax,(%esp)
  105849:	8b 45 08             	mov    0x8(%ebp),%eax
  10584c:	ff d0                	call   *%eax
        while (-- width > 0)
  10584e:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  105852:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  105856:	7f e4                	jg     10583c <printnum+0xca>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  105858:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10585b:	05 70 6f 10 00       	add    $0x106f70,%eax
  105860:	0f b6 00             	movzbl (%eax),%eax
  105863:	0f be c0             	movsbl %al,%eax
  105866:	8b 55 0c             	mov    0xc(%ebp),%edx
  105869:	89 54 24 04          	mov    %edx,0x4(%esp)
  10586d:	89 04 24             	mov    %eax,(%esp)
  105870:	8b 45 08             	mov    0x8(%ebp),%eax
  105873:	ff d0                	call   *%eax
}
  105875:	c9                   	leave  
  105876:	c3                   	ret    

00105877 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  105877:	55                   	push   %ebp
  105878:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  10587a:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  10587e:	7e 14                	jle    105894 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  105880:	8b 45 08             	mov    0x8(%ebp),%eax
  105883:	8b 00                	mov    (%eax),%eax
  105885:	8d 48 08             	lea    0x8(%eax),%ecx
  105888:	8b 55 08             	mov    0x8(%ebp),%edx
  10588b:	89 0a                	mov    %ecx,(%edx)
  10588d:	8b 50 04             	mov    0x4(%eax),%edx
  105890:	8b 00                	mov    (%eax),%eax
  105892:	eb 30                	jmp    1058c4 <getuint+0x4d>
    }
    else if (lflag) {
  105894:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105898:	74 16                	je     1058b0 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  10589a:	8b 45 08             	mov    0x8(%ebp),%eax
  10589d:	8b 00                	mov    (%eax),%eax
  10589f:	8d 48 04             	lea    0x4(%eax),%ecx
  1058a2:	8b 55 08             	mov    0x8(%ebp),%edx
  1058a5:	89 0a                	mov    %ecx,(%edx)
  1058a7:	8b 00                	mov    (%eax),%eax
  1058a9:	ba 00 00 00 00       	mov    $0x0,%edx
  1058ae:	eb 14                	jmp    1058c4 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  1058b0:	8b 45 08             	mov    0x8(%ebp),%eax
  1058b3:	8b 00                	mov    (%eax),%eax
  1058b5:	8d 48 04             	lea    0x4(%eax),%ecx
  1058b8:	8b 55 08             	mov    0x8(%ebp),%edx
  1058bb:	89 0a                	mov    %ecx,(%edx)
  1058bd:	8b 00                	mov    (%eax),%eax
  1058bf:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  1058c4:	5d                   	pop    %ebp
  1058c5:	c3                   	ret    

001058c6 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  1058c6:	55                   	push   %ebp
  1058c7:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  1058c9:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  1058cd:	7e 14                	jle    1058e3 <getint+0x1d>
        return va_arg(*ap, long long);
  1058cf:	8b 45 08             	mov    0x8(%ebp),%eax
  1058d2:	8b 00                	mov    (%eax),%eax
  1058d4:	8d 48 08             	lea    0x8(%eax),%ecx
  1058d7:	8b 55 08             	mov    0x8(%ebp),%edx
  1058da:	89 0a                	mov    %ecx,(%edx)
  1058dc:	8b 50 04             	mov    0x4(%eax),%edx
  1058df:	8b 00                	mov    (%eax),%eax
  1058e1:	eb 28                	jmp    10590b <getint+0x45>
    }
    else if (lflag) {
  1058e3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1058e7:	74 12                	je     1058fb <getint+0x35>
        return va_arg(*ap, long);
  1058e9:	8b 45 08             	mov    0x8(%ebp),%eax
  1058ec:	8b 00                	mov    (%eax),%eax
  1058ee:	8d 48 04             	lea    0x4(%eax),%ecx
  1058f1:	8b 55 08             	mov    0x8(%ebp),%edx
  1058f4:	89 0a                	mov    %ecx,(%edx)
  1058f6:	8b 00                	mov    (%eax),%eax
  1058f8:	99                   	cltd   
  1058f9:	eb 10                	jmp    10590b <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  1058fb:	8b 45 08             	mov    0x8(%ebp),%eax
  1058fe:	8b 00                	mov    (%eax),%eax
  105900:	8d 48 04             	lea    0x4(%eax),%ecx
  105903:	8b 55 08             	mov    0x8(%ebp),%edx
  105906:	89 0a                	mov    %ecx,(%edx)
  105908:	8b 00                	mov    (%eax),%eax
  10590a:	99                   	cltd   
    }
}
  10590b:	5d                   	pop    %ebp
  10590c:	c3                   	ret    

0010590d <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  10590d:	55                   	push   %ebp
  10590e:	89 e5                	mov    %esp,%ebp
  105910:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  105913:	8d 45 14             	lea    0x14(%ebp),%eax
  105916:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  105919:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10591c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105920:	8b 45 10             	mov    0x10(%ebp),%eax
  105923:	89 44 24 08          	mov    %eax,0x8(%esp)
  105927:	8b 45 0c             	mov    0xc(%ebp),%eax
  10592a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10592e:	8b 45 08             	mov    0x8(%ebp),%eax
  105931:	89 04 24             	mov    %eax,(%esp)
  105934:	e8 02 00 00 00       	call   10593b <vprintfmt>
    va_end(ap);
}
  105939:	c9                   	leave  
  10593a:	c3                   	ret    

0010593b <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  10593b:	55                   	push   %ebp
  10593c:	89 e5                	mov    %esp,%ebp
  10593e:	56                   	push   %esi
  10593f:	53                   	push   %ebx
  105940:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105943:	eb 18                	jmp    10595d <vprintfmt+0x22>
            if (ch == '\0') {
  105945:	85 db                	test   %ebx,%ebx
  105947:	75 05                	jne    10594e <vprintfmt+0x13>
                return;
  105949:	e9 d1 03 00 00       	jmp    105d1f <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
  10594e:	8b 45 0c             	mov    0xc(%ebp),%eax
  105951:	89 44 24 04          	mov    %eax,0x4(%esp)
  105955:	89 1c 24             	mov    %ebx,(%esp)
  105958:	8b 45 08             	mov    0x8(%ebp),%eax
  10595b:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  10595d:	8b 45 10             	mov    0x10(%ebp),%eax
  105960:	8d 50 01             	lea    0x1(%eax),%edx
  105963:	89 55 10             	mov    %edx,0x10(%ebp)
  105966:	0f b6 00             	movzbl (%eax),%eax
  105969:	0f b6 d8             	movzbl %al,%ebx
  10596c:	83 fb 25             	cmp    $0x25,%ebx
  10596f:	75 d4                	jne    105945 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
  105971:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  105975:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  10597c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10597f:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  105982:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  105989:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10598c:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  10598f:	8b 45 10             	mov    0x10(%ebp),%eax
  105992:	8d 50 01             	lea    0x1(%eax),%edx
  105995:	89 55 10             	mov    %edx,0x10(%ebp)
  105998:	0f b6 00             	movzbl (%eax),%eax
  10599b:	0f b6 d8             	movzbl %al,%ebx
  10599e:	8d 43 dd             	lea    -0x23(%ebx),%eax
  1059a1:	83 f8 55             	cmp    $0x55,%eax
  1059a4:	0f 87 44 03 00 00    	ja     105cee <vprintfmt+0x3b3>
  1059aa:	8b 04 85 94 6f 10 00 	mov    0x106f94(,%eax,4),%eax
  1059b1:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  1059b3:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  1059b7:	eb d6                	jmp    10598f <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  1059b9:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  1059bd:	eb d0                	jmp    10598f <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  1059bf:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  1059c6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1059c9:	89 d0                	mov    %edx,%eax
  1059cb:	c1 e0 02             	shl    $0x2,%eax
  1059ce:	01 d0                	add    %edx,%eax
  1059d0:	01 c0                	add    %eax,%eax
  1059d2:	01 d8                	add    %ebx,%eax
  1059d4:	83 e8 30             	sub    $0x30,%eax
  1059d7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  1059da:	8b 45 10             	mov    0x10(%ebp),%eax
  1059dd:	0f b6 00             	movzbl (%eax),%eax
  1059e0:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  1059e3:	83 fb 2f             	cmp    $0x2f,%ebx
  1059e6:	7e 0b                	jle    1059f3 <vprintfmt+0xb8>
  1059e8:	83 fb 39             	cmp    $0x39,%ebx
  1059eb:	7f 06                	jg     1059f3 <vprintfmt+0xb8>
            for (precision = 0; ; ++ fmt) {
  1059ed:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                    break;
                }
            }
  1059f1:	eb d3                	jmp    1059c6 <vprintfmt+0x8b>
            goto process_precision;
  1059f3:	eb 33                	jmp    105a28 <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
  1059f5:	8b 45 14             	mov    0x14(%ebp),%eax
  1059f8:	8d 50 04             	lea    0x4(%eax),%edx
  1059fb:	89 55 14             	mov    %edx,0x14(%ebp)
  1059fe:	8b 00                	mov    (%eax),%eax
  105a00:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  105a03:	eb 23                	jmp    105a28 <vprintfmt+0xed>

        case '.':
            if (width < 0)
  105a05:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105a09:	79 0c                	jns    105a17 <vprintfmt+0xdc>
                width = 0;
  105a0b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  105a12:	e9 78 ff ff ff       	jmp    10598f <vprintfmt+0x54>
  105a17:	e9 73 ff ff ff       	jmp    10598f <vprintfmt+0x54>

        case '#':
            altflag = 1;
  105a1c:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  105a23:	e9 67 ff ff ff       	jmp    10598f <vprintfmt+0x54>

        process_precision:
            if (width < 0)
  105a28:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105a2c:	79 12                	jns    105a40 <vprintfmt+0x105>
                width = precision, precision = -1;
  105a2e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105a31:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105a34:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  105a3b:	e9 4f ff ff ff       	jmp    10598f <vprintfmt+0x54>
  105a40:	e9 4a ff ff ff       	jmp    10598f <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  105a45:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
  105a49:	e9 41 ff ff ff       	jmp    10598f <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  105a4e:	8b 45 14             	mov    0x14(%ebp),%eax
  105a51:	8d 50 04             	lea    0x4(%eax),%edx
  105a54:	89 55 14             	mov    %edx,0x14(%ebp)
  105a57:	8b 00                	mov    (%eax),%eax
  105a59:	8b 55 0c             	mov    0xc(%ebp),%edx
  105a5c:	89 54 24 04          	mov    %edx,0x4(%esp)
  105a60:	89 04 24             	mov    %eax,(%esp)
  105a63:	8b 45 08             	mov    0x8(%ebp),%eax
  105a66:	ff d0                	call   *%eax
            break;
  105a68:	e9 ac 02 00 00       	jmp    105d19 <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
  105a6d:	8b 45 14             	mov    0x14(%ebp),%eax
  105a70:	8d 50 04             	lea    0x4(%eax),%edx
  105a73:	89 55 14             	mov    %edx,0x14(%ebp)
  105a76:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  105a78:	85 db                	test   %ebx,%ebx
  105a7a:	79 02                	jns    105a7e <vprintfmt+0x143>
                err = -err;
  105a7c:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  105a7e:	83 fb 06             	cmp    $0x6,%ebx
  105a81:	7f 0b                	jg     105a8e <vprintfmt+0x153>
  105a83:	8b 34 9d 54 6f 10 00 	mov    0x106f54(,%ebx,4),%esi
  105a8a:	85 f6                	test   %esi,%esi
  105a8c:	75 23                	jne    105ab1 <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
  105a8e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  105a92:	c7 44 24 08 81 6f 10 	movl   $0x106f81,0x8(%esp)
  105a99:	00 
  105a9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  105aa1:	8b 45 08             	mov    0x8(%ebp),%eax
  105aa4:	89 04 24             	mov    %eax,(%esp)
  105aa7:	e8 61 fe ff ff       	call   10590d <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  105aac:	e9 68 02 00 00       	jmp    105d19 <vprintfmt+0x3de>
                printfmt(putch, putdat, "%s", p);
  105ab1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  105ab5:	c7 44 24 08 8a 6f 10 	movl   $0x106f8a,0x8(%esp)
  105abc:	00 
  105abd:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ac0:	89 44 24 04          	mov    %eax,0x4(%esp)
  105ac4:	8b 45 08             	mov    0x8(%ebp),%eax
  105ac7:	89 04 24             	mov    %eax,(%esp)
  105aca:	e8 3e fe ff ff       	call   10590d <printfmt>
            break;
  105acf:	e9 45 02 00 00       	jmp    105d19 <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  105ad4:	8b 45 14             	mov    0x14(%ebp),%eax
  105ad7:	8d 50 04             	lea    0x4(%eax),%edx
  105ada:	89 55 14             	mov    %edx,0x14(%ebp)
  105add:	8b 30                	mov    (%eax),%esi
  105adf:	85 f6                	test   %esi,%esi
  105ae1:	75 05                	jne    105ae8 <vprintfmt+0x1ad>
                p = "(null)";
  105ae3:	be 8d 6f 10 00       	mov    $0x106f8d,%esi
            }
            if (width > 0 && padc != '-') {
  105ae8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105aec:	7e 3e                	jle    105b2c <vprintfmt+0x1f1>
  105aee:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  105af2:	74 38                	je     105b2c <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  105af4:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  105af7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105afa:	89 44 24 04          	mov    %eax,0x4(%esp)
  105afe:	89 34 24             	mov    %esi,(%esp)
  105b01:	e8 dc f7 ff ff       	call   1052e2 <strnlen>
  105b06:	29 c3                	sub    %eax,%ebx
  105b08:	89 d8                	mov    %ebx,%eax
  105b0a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105b0d:	eb 17                	jmp    105b26 <vprintfmt+0x1eb>
                    putch(padc, putdat);
  105b0f:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  105b13:	8b 55 0c             	mov    0xc(%ebp),%edx
  105b16:	89 54 24 04          	mov    %edx,0x4(%esp)
  105b1a:	89 04 24             	mov    %eax,(%esp)
  105b1d:	8b 45 08             	mov    0x8(%ebp),%eax
  105b20:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
  105b22:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  105b26:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105b2a:	7f e3                	jg     105b0f <vprintfmt+0x1d4>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105b2c:	eb 38                	jmp    105b66 <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
  105b2e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  105b32:	74 1f                	je     105b53 <vprintfmt+0x218>
  105b34:	83 fb 1f             	cmp    $0x1f,%ebx
  105b37:	7e 05                	jle    105b3e <vprintfmt+0x203>
  105b39:	83 fb 7e             	cmp    $0x7e,%ebx
  105b3c:	7e 15                	jle    105b53 <vprintfmt+0x218>
                    putch('?', putdat);
  105b3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b41:	89 44 24 04          	mov    %eax,0x4(%esp)
  105b45:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  105b4c:	8b 45 08             	mov    0x8(%ebp),%eax
  105b4f:	ff d0                	call   *%eax
  105b51:	eb 0f                	jmp    105b62 <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
  105b53:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b56:	89 44 24 04          	mov    %eax,0x4(%esp)
  105b5a:	89 1c 24             	mov    %ebx,(%esp)
  105b5d:	8b 45 08             	mov    0x8(%ebp),%eax
  105b60:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105b62:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  105b66:	89 f0                	mov    %esi,%eax
  105b68:	8d 70 01             	lea    0x1(%eax),%esi
  105b6b:	0f b6 00             	movzbl (%eax),%eax
  105b6e:	0f be d8             	movsbl %al,%ebx
  105b71:	85 db                	test   %ebx,%ebx
  105b73:	74 10                	je     105b85 <vprintfmt+0x24a>
  105b75:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105b79:	78 b3                	js     105b2e <vprintfmt+0x1f3>
  105b7b:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  105b7f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105b83:	79 a9                	jns    105b2e <vprintfmt+0x1f3>
                }
            }
            for (; width > 0; width --) {
  105b85:	eb 17                	jmp    105b9e <vprintfmt+0x263>
                putch(' ', putdat);
  105b87:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b8a:	89 44 24 04          	mov    %eax,0x4(%esp)
  105b8e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  105b95:	8b 45 08             	mov    0x8(%ebp),%eax
  105b98:	ff d0                	call   *%eax
            for (; width > 0; width --) {
  105b9a:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  105b9e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105ba2:	7f e3                	jg     105b87 <vprintfmt+0x24c>
            }
            break;
  105ba4:	e9 70 01 00 00       	jmp    105d19 <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  105ba9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105bac:	89 44 24 04          	mov    %eax,0x4(%esp)
  105bb0:	8d 45 14             	lea    0x14(%ebp),%eax
  105bb3:	89 04 24             	mov    %eax,(%esp)
  105bb6:	e8 0b fd ff ff       	call   1058c6 <getint>
  105bbb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105bbe:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  105bc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105bc4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105bc7:	85 d2                	test   %edx,%edx
  105bc9:	79 26                	jns    105bf1 <vprintfmt+0x2b6>
                putch('-', putdat);
  105bcb:	8b 45 0c             	mov    0xc(%ebp),%eax
  105bce:	89 44 24 04          	mov    %eax,0x4(%esp)
  105bd2:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  105bd9:	8b 45 08             	mov    0x8(%ebp),%eax
  105bdc:	ff d0                	call   *%eax
                num = -(long long)num;
  105bde:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105be1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105be4:	f7 d8                	neg    %eax
  105be6:	83 d2 00             	adc    $0x0,%edx
  105be9:	f7 da                	neg    %edx
  105beb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105bee:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  105bf1:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  105bf8:	e9 a8 00 00 00       	jmp    105ca5 <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  105bfd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105c00:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c04:	8d 45 14             	lea    0x14(%ebp),%eax
  105c07:	89 04 24             	mov    %eax,(%esp)
  105c0a:	e8 68 fc ff ff       	call   105877 <getuint>
  105c0f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105c12:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  105c15:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  105c1c:	e9 84 00 00 00       	jmp    105ca5 <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  105c21:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105c24:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c28:	8d 45 14             	lea    0x14(%ebp),%eax
  105c2b:	89 04 24             	mov    %eax,(%esp)
  105c2e:	e8 44 fc ff ff       	call   105877 <getuint>
  105c33:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105c36:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  105c39:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  105c40:	eb 63                	jmp    105ca5 <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
  105c42:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c45:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c49:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  105c50:	8b 45 08             	mov    0x8(%ebp),%eax
  105c53:	ff d0                	call   *%eax
            putch('x', putdat);
  105c55:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c58:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c5c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  105c63:	8b 45 08             	mov    0x8(%ebp),%eax
  105c66:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  105c68:	8b 45 14             	mov    0x14(%ebp),%eax
  105c6b:	8d 50 04             	lea    0x4(%eax),%edx
  105c6e:	89 55 14             	mov    %edx,0x14(%ebp)
  105c71:	8b 00                	mov    (%eax),%eax
  105c73:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105c76:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  105c7d:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  105c84:	eb 1f                	jmp    105ca5 <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  105c86:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105c89:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c8d:	8d 45 14             	lea    0x14(%ebp),%eax
  105c90:	89 04 24             	mov    %eax,(%esp)
  105c93:	e8 df fb ff ff       	call   105877 <getuint>
  105c98:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105c9b:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  105c9e:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  105ca5:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  105ca9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105cac:	89 54 24 18          	mov    %edx,0x18(%esp)
  105cb0:	8b 55 e8             	mov    -0x18(%ebp),%edx
  105cb3:	89 54 24 14          	mov    %edx,0x14(%esp)
  105cb7:	89 44 24 10          	mov    %eax,0x10(%esp)
  105cbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105cbe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105cc1:	89 44 24 08          	mov    %eax,0x8(%esp)
  105cc5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105cc9:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ccc:	89 44 24 04          	mov    %eax,0x4(%esp)
  105cd0:	8b 45 08             	mov    0x8(%ebp),%eax
  105cd3:	89 04 24             	mov    %eax,(%esp)
  105cd6:	e8 97 fa ff ff       	call   105772 <printnum>
            break;
  105cdb:	eb 3c                	jmp    105d19 <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  105cdd:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ce0:	89 44 24 04          	mov    %eax,0x4(%esp)
  105ce4:	89 1c 24             	mov    %ebx,(%esp)
  105ce7:	8b 45 08             	mov    0x8(%ebp),%eax
  105cea:	ff d0                	call   *%eax
            break;
  105cec:	eb 2b                	jmp    105d19 <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  105cee:	8b 45 0c             	mov    0xc(%ebp),%eax
  105cf1:	89 44 24 04          	mov    %eax,0x4(%esp)
  105cf5:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  105cfc:	8b 45 08             	mov    0x8(%ebp),%eax
  105cff:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  105d01:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  105d05:	eb 04                	jmp    105d0b <vprintfmt+0x3d0>
  105d07:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  105d0b:	8b 45 10             	mov    0x10(%ebp),%eax
  105d0e:	83 e8 01             	sub    $0x1,%eax
  105d11:	0f b6 00             	movzbl (%eax),%eax
  105d14:	3c 25                	cmp    $0x25,%al
  105d16:	75 ef                	jne    105d07 <vprintfmt+0x3cc>
                /* do nothing */;
            break;
  105d18:	90                   	nop
        }
    }
  105d19:	90                   	nop
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105d1a:	e9 3e fc ff ff       	jmp    10595d <vprintfmt+0x22>
}
  105d1f:	83 c4 40             	add    $0x40,%esp
  105d22:	5b                   	pop    %ebx
  105d23:	5e                   	pop    %esi
  105d24:	5d                   	pop    %ebp
  105d25:	c3                   	ret    

00105d26 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  105d26:	55                   	push   %ebp
  105d27:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  105d29:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d2c:	8b 40 08             	mov    0x8(%eax),%eax
  105d2f:	8d 50 01             	lea    0x1(%eax),%edx
  105d32:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d35:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  105d38:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d3b:	8b 10                	mov    (%eax),%edx
  105d3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d40:	8b 40 04             	mov    0x4(%eax),%eax
  105d43:	39 c2                	cmp    %eax,%edx
  105d45:	73 12                	jae    105d59 <sprintputch+0x33>
        *b->buf ++ = ch;
  105d47:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d4a:	8b 00                	mov    (%eax),%eax
  105d4c:	8d 48 01             	lea    0x1(%eax),%ecx
  105d4f:	8b 55 0c             	mov    0xc(%ebp),%edx
  105d52:	89 0a                	mov    %ecx,(%edx)
  105d54:	8b 55 08             	mov    0x8(%ebp),%edx
  105d57:	88 10                	mov    %dl,(%eax)
    }
}
  105d59:	5d                   	pop    %ebp
  105d5a:	c3                   	ret    

00105d5b <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  105d5b:	55                   	push   %ebp
  105d5c:	89 e5                	mov    %esp,%ebp
  105d5e:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  105d61:	8d 45 14             	lea    0x14(%ebp),%eax
  105d64:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  105d67:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105d6a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105d6e:	8b 45 10             	mov    0x10(%ebp),%eax
  105d71:	89 44 24 08          	mov    %eax,0x8(%esp)
  105d75:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d78:	89 44 24 04          	mov    %eax,0x4(%esp)
  105d7c:	8b 45 08             	mov    0x8(%ebp),%eax
  105d7f:	89 04 24             	mov    %eax,(%esp)
  105d82:	e8 08 00 00 00       	call   105d8f <vsnprintf>
  105d87:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  105d8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105d8d:	c9                   	leave  
  105d8e:	c3                   	ret    

00105d8f <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  105d8f:	55                   	push   %ebp
  105d90:	89 e5                	mov    %esp,%ebp
  105d92:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  105d95:	8b 45 08             	mov    0x8(%ebp),%eax
  105d98:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105d9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d9e:	8d 50 ff             	lea    -0x1(%eax),%edx
  105da1:	8b 45 08             	mov    0x8(%ebp),%eax
  105da4:	01 d0                	add    %edx,%eax
  105da6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105da9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  105db0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  105db4:	74 0a                	je     105dc0 <vsnprintf+0x31>
  105db6:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105db9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105dbc:	39 c2                	cmp    %eax,%edx
  105dbe:	76 07                	jbe    105dc7 <vsnprintf+0x38>
        return -E_INVAL;
  105dc0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  105dc5:	eb 2a                	jmp    105df1 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  105dc7:	8b 45 14             	mov    0x14(%ebp),%eax
  105dca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105dce:	8b 45 10             	mov    0x10(%ebp),%eax
  105dd1:	89 44 24 08          	mov    %eax,0x8(%esp)
  105dd5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  105dd8:	89 44 24 04          	mov    %eax,0x4(%esp)
  105ddc:	c7 04 24 26 5d 10 00 	movl   $0x105d26,(%esp)
  105de3:	e8 53 fb ff ff       	call   10593b <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  105de8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105deb:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  105dee:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105df1:	c9                   	leave  
  105df2:	c3                   	ret    
