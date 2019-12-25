
bin/kernel:     file format elf32-i386


Disassembly of section .text:

00100000 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
  100000:	55                   	push   %ebp
  100001:	89 e5                	mov    %esp,%ebp
  100003:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  100006:	ba 20 fd 10 00       	mov    $0x10fd20,%edx
  10000b:	b8 16 ea 10 00       	mov    $0x10ea16,%eax
  100010:	29 c2                	sub    %eax,%edx
  100012:	89 d0                	mov    %edx,%eax
  100014:	89 44 24 08          	mov    %eax,0x8(%esp)
  100018:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10001f:	00 
  100020:	c7 04 24 16 ea 10 00 	movl   $0x10ea16,(%esp)
  100027:	e8 e6 29 00 00       	call   102a12 <memset>

    cons_init();                // init the console
  10002c:	e8 8b 14 00 00       	call   1014bc <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100031:	c7 45 f4 20 32 10 00 	movl   $0x103220,-0xc(%ebp)
    cprintf("%s\n\n", message);
  100038:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10003b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10003f:	c7 04 24 3c 32 10 00 	movl   $0x10323c,(%esp)
  100046:	e8 11 02 00 00       	call   10025c <cprintf>

    print_kerninfo();
  10004b:	e8 c3 08 00 00       	call   100913 <print_kerninfo>

    grade_backtrace();
  100050:	e8 86 00 00 00       	call   1000db <grade_backtrace>

    pmm_init();                 // init physical memory management
  100055:	e8 7f 26 00 00       	call   1026d9 <pmm_init>

    pic_init();                 // init interrupt controller
  10005a:	e8 94 15 00 00       	call   1015f3 <pic_init>
    idt_init();                 // init interrupt descriptor table
  10005f:	e8 f2 16 00 00       	call   101756 <idt_init>

    clock_init();               // init clock interrupt
  100064:	e8 46 0c 00 00       	call   100caf <clock_init>
    intr_enable();              // enable irq interrupt
  100069:	e8 c0 16 00 00       	call   10172e <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
  10006e:	eb fe                	jmp    10006e <kern_init+0x6e>

00100070 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  100070:	55                   	push   %ebp
  100071:	89 e5                	mov    %esp,%ebp
  100073:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
  100076:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10007d:	00 
  10007e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  100085:	00 
  100086:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  10008d:	e8 0b 0c 00 00       	call   100c9d <mon_backtrace>
}
  100092:	c9                   	leave  
  100093:	c3                   	ret    

00100094 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  100094:	55                   	push   %ebp
  100095:	89 e5                	mov    %esp,%ebp
  100097:	53                   	push   %ebx
  100098:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  10009b:	8d 5d 0c             	lea    0xc(%ebp),%ebx
  10009e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  1000a1:	8d 55 08             	lea    0x8(%ebp),%edx
  1000a4:	8b 45 08             	mov    0x8(%ebp),%eax
  1000a7:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1000ab:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  1000af:	89 54 24 04          	mov    %edx,0x4(%esp)
  1000b3:	89 04 24             	mov    %eax,(%esp)
  1000b6:	e8 b5 ff ff ff       	call   100070 <grade_backtrace2>
}
  1000bb:	83 c4 14             	add    $0x14,%esp
  1000be:	5b                   	pop    %ebx
  1000bf:	5d                   	pop    %ebp
  1000c0:	c3                   	ret    

001000c1 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  1000c1:	55                   	push   %ebp
  1000c2:	89 e5                	mov    %esp,%ebp
  1000c4:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
  1000c7:	8b 45 10             	mov    0x10(%ebp),%eax
  1000ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  1000ce:	8b 45 08             	mov    0x8(%ebp),%eax
  1000d1:	89 04 24             	mov    %eax,(%esp)
  1000d4:	e8 bb ff ff ff       	call   100094 <grade_backtrace1>
}
  1000d9:	c9                   	leave  
  1000da:	c3                   	ret    

001000db <grade_backtrace>:

void
grade_backtrace(void) {
  1000db:	55                   	push   %ebp
  1000dc:	89 e5                	mov    %esp,%ebp
  1000de:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  1000e1:	b8 00 00 10 00       	mov    $0x100000,%eax
  1000e6:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
  1000ed:	ff 
  1000ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  1000f2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1000f9:	e8 c3 ff ff ff       	call   1000c1 <grade_backtrace0>
}
  1000fe:	c9                   	leave  
  1000ff:	c3                   	ret    

00100100 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  100100:	55                   	push   %ebp
  100101:	89 e5                	mov    %esp,%ebp
  100103:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  100106:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  100109:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  10010c:	8c 45 f2             	mov    %es,-0xe(%ebp)
  10010f:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  100112:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100116:	0f b7 c0             	movzwl %ax,%eax
  100119:	83 e0 03             	and    $0x3,%eax
  10011c:	89 c2                	mov    %eax,%edx
  10011e:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100123:	89 54 24 08          	mov    %edx,0x8(%esp)
  100127:	89 44 24 04          	mov    %eax,0x4(%esp)
  10012b:	c7 04 24 41 32 10 00 	movl   $0x103241,(%esp)
  100132:	e8 25 01 00 00       	call   10025c <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  100137:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10013b:	0f b7 d0             	movzwl %ax,%edx
  10013e:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100143:	89 54 24 08          	mov    %edx,0x8(%esp)
  100147:	89 44 24 04          	mov    %eax,0x4(%esp)
  10014b:	c7 04 24 4f 32 10 00 	movl   $0x10324f,(%esp)
  100152:	e8 05 01 00 00       	call   10025c <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  100157:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  10015b:	0f b7 d0             	movzwl %ax,%edx
  10015e:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100163:	89 54 24 08          	mov    %edx,0x8(%esp)
  100167:	89 44 24 04          	mov    %eax,0x4(%esp)
  10016b:	c7 04 24 5d 32 10 00 	movl   $0x10325d,(%esp)
  100172:	e8 e5 00 00 00       	call   10025c <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  100177:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  10017b:	0f b7 d0             	movzwl %ax,%edx
  10017e:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100183:	89 54 24 08          	mov    %edx,0x8(%esp)
  100187:	89 44 24 04          	mov    %eax,0x4(%esp)
  10018b:	c7 04 24 6b 32 10 00 	movl   $0x10326b,(%esp)
  100192:	e8 c5 00 00 00       	call   10025c <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  100197:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  10019b:	0f b7 d0             	movzwl %ax,%edx
  10019e:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  1001a3:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001ab:	c7 04 24 79 32 10 00 	movl   $0x103279,(%esp)
  1001b2:	e8 a5 00 00 00       	call   10025c <cprintf>
    round ++;
  1001b7:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  1001bc:	83 c0 01             	add    $0x1,%eax
  1001bf:	a3 20 ea 10 00       	mov    %eax,0x10ea20
}
  1001c4:	c9                   	leave  
  1001c5:	c3                   	ret    

001001c6 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  1001c6:	55                   	push   %ebp
  1001c7:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
  1001c9:	5d                   	pop    %ebp
  1001ca:	c3                   	ret    

001001cb <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  1001cb:	55                   	push   %ebp
  1001cc:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
  1001ce:	5d                   	pop    %ebp
  1001cf:	c3                   	ret    

001001d0 <lab1_switch_test>:

static void
lab1_switch_test(void) {
  1001d0:	55                   	push   %ebp
  1001d1:	89 e5                	mov    %esp,%ebp
  1001d3:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
  1001d6:	e8 25 ff ff ff       	call   100100 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  1001db:	c7 04 24 88 32 10 00 	movl   $0x103288,(%esp)
  1001e2:	e8 75 00 00 00       	call   10025c <cprintf>
    lab1_switch_to_user();
  1001e7:	e8 da ff ff ff       	call   1001c6 <lab1_switch_to_user>
    lab1_print_cur_status();
  1001ec:	e8 0f ff ff ff       	call   100100 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  1001f1:	c7 04 24 a8 32 10 00 	movl   $0x1032a8,(%esp)
  1001f8:	e8 5f 00 00 00       	call   10025c <cprintf>
    lab1_switch_to_kernel();
  1001fd:	e8 c9 ff ff ff       	call   1001cb <lab1_switch_to_kernel>
    lab1_print_cur_status();
  100202:	e8 f9 fe ff ff       	call   100100 <lab1_print_cur_status>
}
  100207:	c9                   	leave  
  100208:	c3                   	ret    

00100209 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  100209:	55                   	push   %ebp
  10020a:	89 e5                	mov    %esp,%ebp
  10020c:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  10020f:	8b 45 08             	mov    0x8(%ebp),%eax
  100212:	89 04 24             	mov    %eax,(%esp)
  100215:	e8 ce 12 00 00       	call   1014e8 <cons_putc>
    (*cnt) ++;
  10021a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10021d:	8b 00                	mov    (%eax),%eax
  10021f:	8d 50 01             	lea    0x1(%eax),%edx
  100222:	8b 45 0c             	mov    0xc(%ebp),%eax
  100225:	89 10                	mov    %edx,(%eax)
}
  100227:	c9                   	leave  
  100228:	c3                   	ret    

00100229 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  100229:	55                   	push   %ebp
  10022a:	89 e5                	mov    %esp,%ebp
  10022c:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  10022f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  100236:	8b 45 0c             	mov    0xc(%ebp),%eax
  100239:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10023d:	8b 45 08             	mov    0x8(%ebp),%eax
  100240:	89 44 24 08          	mov    %eax,0x8(%esp)
  100244:	8d 45 f4             	lea    -0xc(%ebp),%eax
  100247:	89 44 24 04          	mov    %eax,0x4(%esp)
  10024b:	c7 04 24 09 02 10 00 	movl   $0x100209,(%esp)
  100252:	e8 0d 2b 00 00       	call   102d64 <vprintfmt>
    return cnt;
  100257:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10025a:	c9                   	leave  
  10025b:	c3                   	ret    

0010025c <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  10025c:	55                   	push   %ebp
  10025d:	89 e5                	mov    %esp,%ebp
  10025f:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  100262:	8d 45 0c             	lea    0xc(%ebp),%eax
  100265:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  100268:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10026b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10026f:	8b 45 08             	mov    0x8(%ebp),%eax
  100272:	89 04 24             	mov    %eax,(%esp)
  100275:	e8 af ff ff ff       	call   100229 <vcprintf>
  10027a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  10027d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100280:	c9                   	leave  
  100281:	c3                   	ret    

00100282 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  100282:	55                   	push   %ebp
  100283:	89 e5                	mov    %esp,%ebp
  100285:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  100288:	8b 45 08             	mov    0x8(%ebp),%eax
  10028b:	89 04 24             	mov    %eax,(%esp)
  10028e:	e8 55 12 00 00       	call   1014e8 <cons_putc>
}
  100293:	c9                   	leave  
  100294:	c3                   	ret    

00100295 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  100295:	55                   	push   %ebp
  100296:	89 e5                	mov    %esp,%ebp
  100298:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  10029b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  1002a2:	eb 13                	jmp    1002b7 <cputs+0x22>
        cputch(c, &cnt);
  1002a4:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  1002a8:	8d 55 f0             	lea    -0x10(%ebp),%edx
  1002ab:	89 54 24 04          	mov    %edx,0x4(%esp)
  1002af:	89 04 24             	mov    %eax,(%esp)
  1002b2:	e8 52 ff ff ff       	call   100209 <cputch>
    while ((c = *str ++) != '\0') {
  1002b7:	8b 45 08             	mov    0x8(%ebp),%eax
  1002ba:	8d 50 01             	lea    0x1(%eax),%edx
  1002bd:	89 55 08             	mov    %edx,0x8(%ebp)
  1002c0:	0f b6 00             	movzbl (%eax),%eax
  1002c3:	88 45 f7             	mov    %al,-0x9(%ebp)
  1002c6:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  1002ca:	75 d8                	jne    1002a4 <cputs+0xf>
    }
    cputch('\n', &cnt);
  1002cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  1002cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  1002d3:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  1002da:	e8 2a ff ff ff       	call   100209 <cputch>
    return cnt;
  1002df:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  1002e2:	c9                   	leave  
  1002e3:	c3                   	ret    

001002e4 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  1002e4:	55                   	push   %ebp
  1002e5:	89 e5                	mov    %esp,%ebp
  1002e7:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  1002ea:	e8 22 12 00 00       	call   101511 <cons_getc>
  1002ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1002f2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1002f6:	74 f2                	je     1002ea <getchar+0x6>
        /* do nothing */;
    return c;
  1002f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1002fb:	c9                   	leave  
  1002fc:	c3                   	ret    

001002fd <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  1002fd:	55                   	push   %ebp
  1002fe:	89 e5                	mov    %esp,%ebp
  100300:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
  100303:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100307:	74 13                	je     10031c <readline+0x1f>
        cprintf("%s", prompt);
  100309:	8b 45 08             	mov    0x8(%ebp),%eax
  10030c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100310:	c7 04 24 c7 32 10 00 	movl   $0x1032c7,(%esp)
  100317:	e8 40 ff ff ff       	call   10025c <cprintf>
    }
    int i = 0, c;
  10031c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  100323:	e8 bc ff ff ff       	call   1002e4 <getchar>
  100328:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  10032b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10032f:	79 07                	jns    100338 <readline+0x3b>
            return NULL;
  100331:	b8 00 00 00 00       	mov    $0x0,%eax
  100336:	eb 79                	jmp    1003b1 <readline+0xb4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  100338:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  10033c:	7e 28                	jle    100366 <readline+0x69>
  10033e:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  100345:	7f 1f                	jg     100366 <readline+0x69>
            cputchar(c);
  100347:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10034a:	89 04 24             	mov    %eax,(%esp)
  10034d:	e8 30 ff ff ff       	call   100282 <cputchar>
            buf[i ++] = c;
  100352:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100355:	8d 50 01             	lea    0x1(%eax),%edx
  100358:	89 55 f4             	mov    %edx,-0xc(%ebp)
  10035b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10035e:	88 90 40 ea 10 00    	mov    %dl,0x10ea40(%eax)
  100364:	eb 46                	jmp    1003ac <readline+0xaf>
        }
        else if (c == '\b' && i > 0) {
  100366:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  10036a:	75 17                	jne    100383 <readline+0x86>
  10036c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100370:	7e 11                	jle    100383 <readline+0x86>
            cputchar(c);
  100372:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100375:	89 04 24             	mov    %eax,(%esp)
  100378:	e8 05 ff ff ff       	call   100282 <cputchar>
            i --;
  10037d:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  100381:	eb 29                	jmp    1003ac <readline+0xaf>
        }
        else if (c == '\n' || c == '\r') {
  100383:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  100387:	74 06                	je     10038f <readline+0x92>
  100389:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  10038d:	75 1d                	jne    1003ac <readline+0xaf>
            cputchar(c);
  10038f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100392:	89 04 24             	mov    %eax,(%esp)
  100395:	e8 e8 fe ff ff       	call   100282 <cputchar>
            buf[i] = '\0';
  10039a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10039d:	05 40 ea 10 00       	add    $0x10ea40,%eax
  1003a2:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1003a5:	b8 40 ea 10 00       	mov    $0x10ea40,%eax
  1003aa:	eb 05                	jmp    1003b1 <readline+0xb4>
        }
    }
  1003ac:	e9 72 ff ff ff       	jmp    100323 <readline+0x26>
}
  1003b1:	c9                   	leave  
  1003b2:	c3                   	ret    

001003b3 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  1003b3:	55                   	push   %ebp
  1003b4:	89 e5                	mov    %esp,%ebp
  1003b6:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
  1003b9:	a1 40 ee 10 00       	mov    0x10ee40,%eax
  1003be:	85 c0                	test   %eax,%eax
  1003c0:	74 02                	je     1003c4 <__panic+0x11>
        goto panic_dead;
  1003c2:	eb 59                	jmp    10041d <__panic+0x6a>
    }
    is_panic = 1;
  1003c4:	c7 05 40 ee 10 00 01 	movl   $0x1,0x10ee40
  1003cb:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  1003ce:	8d 45 14             	lea    0x14(%ebp),%eax
  1003d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  1003d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1003d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  1003db:	8b 45 08             	mov    0x8(%ebp),%eax
  1003de:	89 44 24 04          	mov    %eax,0x4(%esp)
  1003e2:	c7 04 24 ca 32 10 00 	movl   $0x1032ca,(%esp)
  1003e9:	e8 6e fe ff ff       	call   10025c <cprintf>
    vcprintf(fmt, ap);
  1003ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1003f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1003f5:	8b 45 10             	mov    0x10(%ebp),%eax
  1003f8:	89 04 24             	mov    %eax,(%esp)
  1003fb:	e8 29 fe ff ff       	call   100229 <vcprintf>
    cprintf("\n");
  100400:	c7 04 24 e6 32 10 00 	movl   $0x1032e6,(%esp)
  100407:	e8 50 fe ff ff       	call   10025c <cprintf>
    
    cprintf("stack trackback:\n");
  10040c:	c7 04 24 e8 32 10 00 	movl   $0x1032e8,(%esp)
  100413:	e8 44 fe ff ff       	call   10025c <cprintf>
    print_stackframe();
  100418:	e8 40 06 00 00       	call   100a5d <print_stackframe>
    
    va_end(ap);

panic_dead:
    intr_disable();
  10041d:	e8 12 13 00 00       	call   101734 <intr_disable>
    while (1) {
        kmonitor(NULL);
  100422:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100429:	e8 a0 07 00 00       	call   100bce <kmonitor>
    }
  10042e:	eb f2                	jmp    100422 <__panic+0x6f>

00100430 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100430:	55                   	push   %ebp
  100431:	89 e5                	mov    %esp,%ebp
  100433:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  100436:	8d 45 14             	lea    0x14(%ebp),%eax
  100439:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  10043c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10043f:	89 44 24 08          	mov    %eax,0x8(%esp)
  100443:	8b 45 08             	mov    0x8(%ebp),%eax
  100446:	89 44 24 04          	mov    %eax,0x4(%esp)
  10044a:	c7 04 24 fa 32 10 00 	movl   $0x1032fa,(%esp)
  100451:	e8 06 fe ff ff       	call   10025c <cprintf>
    vcprintf(fmt, ap);
  100456:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100459:	89 44 24 04          	mov    %eax,0x4(%esp)
  10045d:	8b 45 10             	mov    0x10(%ebp),%eax
  100460:	89 04 24             	mov    %eax,(%esp)
  100463:	e8 c1 fd ff ff       	call   100229 <vcprintf>
    cprintf("\n");
  100468:	c7 04 24 e6 32 10 00 	movl   $0x1032e6,(%esp)
  10046f:	e8 e8 fd ff ff       	call   10025c <cprintf>
    va_end(ap);
}
  100474:	c9                   	leave  
  100475:	c3                   	ret    

00100476 <is_kernel_panic>:

bool
is_kernel_panic(void) {
  100476:	55                   	push   %ebp
  100477:	89 e5                	mov    %esp,%ebp
    return is_panic;
  100479:	a1 40 ee 10 00       	mov    0x10ee40,%eax
}
  10047e:	5d                   	pop    %ebp
  10047f:	c3                   	ret    

00100480 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  100480:	55                   	push   %ebp
  100481:	89 e5                	mov    %esp,%ebp
  100483:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  100486:	8b 45 0c             	mov    0xc(%ebp),%eax
  100489:	8b 00                	mov    (%eax),%eax
  10048b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  10048e:	8b 45 10             	mov    0x10(%ebp),%eax
  100491:	8b 00                	mov    (%eax),%eax
  100493:	89 45 f8             	mov    %eax,-0x8(%ebp)
  100496:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  10049d:	e9 d2 00 00 00       	jmp    100574 <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
  1004a2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1004a5:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1004a8:	01 d0                	add    %edx,%eax
  1004aa:	89 c2                	mov    %eax,%edx
  1004ac:	c1 ea 1f             	shr    $0x1f,%edx
  1004af:	01 d0                	add    %edx,%eax
  1004b1:	d1 f8                	sar    %eax
  1004b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1004b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1004b9:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  1004bc:	eb 04                	jmp    1004c2 <stab_binsearch+0x42>
            m --;
  1004be:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
  1004c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004c5:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  1004c8:	7c 1f                	jl     1004e9 <stab_binsearch+0x69>
  1004ca:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004cd:	89 d0                	mov    %edx,%eax
  1004cf:	01 c0                	add    %eax,%eax
  1004d1:	01 d0                	add    %edx,%eax
  1004d3:	c1 e0 02             	shl    $0x2,%eax
  1004d6:	89 c2                	mov    %eax,%edx
  1004d8:	8b 45 08             	mov    0x8(%ebp),%eax
  1004db:	01 d0                	add    %edx,%eax
  1004dd:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1004e1:	0f b6 c0             	movzbl %al,%eax
  1004e4:	3b 45 14             	cmp    0x14(%ebp),%eax
  1004e7:	75 d5                	jne    1004be <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
  1004e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004ec:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  1004ef:	7d 0b                	jge    1004fc <stab_binsearch+0x7c>
            l = true_m + 1;
  1004f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1004f4:	83 c0 01             	add    $0x1,%eax
  1004f7:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  1004fa:	eb 78                	jmp    100574 <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
  1004fc:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  100503:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100506:	89 d0                	mov    %edx,%eax
  100508:	01 c0                	add    %eax,%eax
  10050a:	01 d0                	add    %edx,%eax
  10050c:	c1 e0 02             	shl    $0x2,%eax
  10050f:	89 c2                	mov    %eax,%edx
  100511:	8b 45 08             	mov    0x8(%ebp),%eax
  100514:	01 d0                	add    %edx,%eax
  100516:	8b 40 08             	mov    0x8(%eax),%eax
  100519:	3b 45 18             	cmp    0x18(%ebp),%eax
  10051c:	73 13                	jae    100531 <stab_binsearch+0xb1>
            *region_left = m;
  10051e:	8b 45 0c             	mov    0xc(%ebp),%eax
  100521:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100524:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  100526:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100529:	83 c0 01             	add    $0x1,%eax
  10052c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  10052f:	eb 43                	jmp    100574 <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
  100531:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100534:	89 d0                	mov    %edx,%eax
  100536:	01 c0                	add    %eax,%eax
  100538:	01 d0                	add    %edx,%eax
  10053a:	c1 e0 02             	shl    $0x2,%eax
  10053d:	89 c2                	mov    %eax,%edx
  10053f:	8b 45 08             	mov    0x8(%ebp),%eax
  100542:	01 d0                	add    %edx,%eax
  100544:	8b 40 08             	mov    0x8(%eax),%eax
  100547:	3b 45 18             	cmp    0x18(%ebp),%eax
  10054a:	76 16                	jbe    100562 <stab_binsearch+0xe2>
            *region_right = m - 1;
  10054c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10054f:	8d 50 ff             	lea    -0x1(%eax),%edx
  100552:	8b 45 10             	mov    0x10(%ebp),%eax
  100555:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  100557:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10055a:	83 e8 01             	sub    $0x1,%eax
  10055d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  100560:	eb 12                	jmp    100574 <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  100562:	8b 45 0c             	mov    0xc(%ebp),%eax
  100565:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100568:	89 10                	mov    %edx,(%eax)
            l = m;
  10056a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10056d:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  100570:	83 45 18 01          	addl   $0x1,0x18(%ebp)
    while (l <= r) {
  100574:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100577:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  10057a:	0f 8e 22 ff ff ff    	jle    1004a2 <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
  100580:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100584:	75 0f                	jne    100595 <stab_binsearch+0x115>
        *region_right = *region_left - 1;
  100586:	8b 45 0c             	mov    0xc(%ebp),%eax
  100589:	8b 00                	mov    (%eax),%eax
  10058b:	8d 50 ff             	lea    -0x1(%eax),%edx
  10058e:	8b 45 10             	mov    0x10(%ebp),%eax
  100591:	89 10                	mov    %edx,(%eax)
  100593:	eb 3f                	jmp    1005d4 <stab_binsearch+0x154>
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
  100595:	8b 45 10             	mov    0x10(%ebp),%eax
  100598:	8b 00                	mov    (%eax),%eax
  10059a:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  10059d:	eb 04                	jmp    1005a3 <stab_binsearch+0x123>
  10059f:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
  1005a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005a6:	8b 00                	mov    (%eax),%eax
  1005a8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  1005ab:	7d 1f                	jge    1005cc <stab_binsearch+0x14c>
  1005ad:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1005b0:	89 d0                	mov    %edx,%eax
  1005b2:	01 c0                	add    %eax,%eax
  1005b4:	01 d0                	add    %edx,%eax
  1005b6:	c1 e0 02             	shl    $0x2,%eax
  1005b9:	89 c2                	mov    %eax,%edx
  1005bb:	8b 45 08             	mov    0x8(%ebp),%eax
  1005be:	01 d0                	add    %edx,%eax
  1005c0:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1005c4:	0f b6 c0             	movzbl %al,%eax
  1005c7:	3b 45 14             	cmp    0x14(%ebp),%eax
  1005ca:	75 d3                	jne    10059f <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
  1005cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005cf:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1005d2:	89 10                	mov    %edx,(%eax)
    }
}
  1005d4:	c9                   	leave  
  1005d5:	c3                   	ret    

001005d6 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  1005d6:	55                   	push   %ebp
  1005d7:	89 e5                	mov    %esp,%ebp
  1005d9:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  1005dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005df:	c7 00 18 33 10 00    	movl   $0x103318,(%eax)
    info->eip_line = 0;
  1005e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005e8:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  1005ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005f2:	c7 40 08 18 33 10 00 	movl   $0x103318,0x8(%eax)
    info->eip_fn_namelen = 9;
  1005f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005fc:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  100603:	8b 45 0c             	mov    0xc(%ebp),%eax
  100606:	8b 55 08             	mov    0x8(%ebp),%edx
  100609:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  10060c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10060f:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  100616:	c7 45 f4 0c 3b 10 00 	movl   $0x103b0c,-0xc(%ebp)
    stab_end = __STAB_END__;
  10061d:	c7 45 f0 54 b0 10 00 	movl   $0x10b054,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  100624:	c7 45 ec 55 b0 10 00 	movl   $0x10b055,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  10062b:	c7 45 e8 23 d0 10 00 	movl   $0x10d023,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  100632:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100635:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  100638:	76 0d                	jbe    100647 <debuginfo_eip+0x71>
  10063a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10063d:	83 e8 01             	sub    $0x1,%eax
  100640:	0f b6 00             	movzbl (%eax),%eax
  100643:	84 c0                	test   %al,%al
  100645:	74 0a                	je     100651 <debuginfo_eip+0x7b>
        return -1;
  100647:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10064c:	e9 c0 02 00 00       	jmp    100911 <debuginfo_eip+0x33b>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  100651:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  100658:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10065b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10065e:	29 c2                	sub    %eax,%edx
  100660:	89 d0                	mov    %edx,%eax
  100662:	c1 f8 02             	sar    $0x2,%eax
  100665:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  10066b:	83 e8 01             	sub    $0x1,%eax
  10066e:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  100671:	8b 45 08             	mov    0x8(%ebp),%eax
  100674:	89 44 24 10          	mov    %eax,0x10(%esp)
  100678:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
  10067f:	00 
  100680:	8d 45 e0             	lea    -0x20(%ebp),%eax
  100683:	89 44 24 08          	mov    %eax,0x8(%esp)
  100687:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  10068a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10068e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100691:	89 04 24             	mov    %eax,(%esp)
  100694:	e8 e7 fd ff ff       	call   100480 <stab_binsearch>
    if (lfile == 0)
  100699:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10069c:	85 c0                	test   %eax,%eax
  10069e:	75 0a                	jne    1006aa <debuginfo_eip+0xd4>
        return -1;
  1006a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1006a5:	e9 67 02 00 00       	jmp    100911 <debuginfo_eip+0x33b>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  1006aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006ad:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1006b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1006b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  1006b6:	8b 45 08             	mov    0x8(%ebp),%eax
  1006b9:	89 44 24 10          	mov    %eax,0x10(%esp)
  1006bd:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
  1006c4:	00 
  1006c5:	8d 45 d8             	lea    -0x28(%ebp),%eax
  1006c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  1006cc:	8d 45 dc             	lea    -0x24(%ebp),%eax
  1006cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  1006d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006d6:	89 04 24             	mov    %eax,(%esp)
  1006d9:	e8 a2 fd ff ff       	call   100480 <stab_binsearch>

    if (lfun <= rfun) {
  1006de:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1006e1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1006e4:	39 c2                	cmp    %eax,%edx
  1006e6:	7f 7c                	jg     100764 <debuginfo_eip+0x18e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  1006e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1006eb:	89 c2                	mov    %eax,%edx
  1006ed:	89 d0                	mov    %edx,%eax
  1006ef:	01 c0                	add    %eax,%eax
  1006f1:	01 d0                	add    %edx,%eax
  1006f3:	c1 e0 02             	shl    $0x2,%eax
  1006f6:	89 c2                	mov    %eax,%edx
  1006f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006fb:	01 d0                	add    %edx,%eax
  1006fd:	8b 10                	mov    (%eax),%edx
  1006ff:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  100702:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100705:	29 c1                	sub    %eax,%ecx
  100707:	89 c8                	mov    %ecx,%eax
  100709:	39 c2                	cmp    %eax,%edx
  10070b:	73 22                	jae    10072f <debuginfo_eip+0x159>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  10070d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100710:	89 c2                	mov    %eax,%edx
  100712:	89 d0                	mov    %edx,%eax
  100714:	01 c0                	add    %eax,%eax
  100716:	01 d0                	add    %edx,%eax
  100718:	c1 e0 02             	shl    $0x2,%eax
  10071b:	89 c2                	mov    %eax,%edx
  10071d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100720:	01 d0                	add    %edx,%eax
  100722:	8b 10                	mov    (%eax),%edx
  100724:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100727:	01 c2                	add    %eax,%edx
  100729:	8b 45 0c             	mov    0xc(%ebp),%eax
  10072c:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  10072f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100732:	89 c2                	mov    %eax,%edx
  100734:	89 d0                	mov    %edx,%eax
  100736:	01 c0                	add    %eax,%eax
  100738:	01 d0                	add    %edx,%eax
  10073a:	c1 e0 02             	shl    $0x2,%eax
  10073d:	89 c2                	mov    %eax,%edx
  10073f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100742:	01 d0                	add    %edx,%eax
  100744:	8b 50 08             	mov    0x8(%eax),%edx
  100747:	8b 45 0c             	mov    0xc(%ebp),%eax
  10074a:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  10074d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100750:	8b 40 10             	mov    0x10(%eax),%eax
  100753:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  100756:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100759:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  10075c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10075f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  100762:	eb 15                	jmp    100779 <debuginfo_eip+0x1a3>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  100764:	8b 45 0c             	mov    0xc(%ebp),%eax
  100767:	8b 55 08             	mov    0x8(%ebp),%edx
  10076a:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  10076d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100770:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  100773:	8b 45 e0             	mov    -0x20(%ebp),%eax
  100776:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  100779:	8b 45 0c             	mov    0xc(%ebp),%eax
  10077c:	8b 40 08             	mov    0x8(%eax),%eax
  10077f:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  100786:	00 
  100787:	89 04 24             	mov    %eax,(%esp)
  10078a:	e8 f7 20 00 00       	call   102886 <strfind>
  10078f:	89 c2                	mov    %eax,%edx
  100791:	8b 45 0c             	mov    0xc(%ebp),%eax
  100794:	8b 40 08             	mov    0x8(%eax),%eax
  100797:	29 c2                	sub    %eax,%edx
  100799:	8b 45 0c             	mov    0xc(%ebp),%eax
  10079c:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  10079f:	8b 45 08             	mov    0x8(%ebp),%eax
  1007a2:	89 44 24 10          	mov    %eax,0x10(%esp)
  1007a6:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
  1007ad:	00 
  1007ae:	8d 45 d0             	lea    -0x30(%ebp),%eax
  1007b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  1007b5:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  1007b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  1007bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007bf:	89 04 24             	mov    %eax,(%esp)
  1007c2:	e8 b9 fc ff ff       	call   100480 <stab_binsearch>
    if (lline <= rline) {
  1007c7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1007ca:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1007cd:	39 c2                	cmp    %eax,%edx
  1007cf:	7f 24                	jg     1007f5 <debuginfo_eip+0x21f>
        info->eip_line = stabs[rline].n_desc;
  1007d1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1007d4:	89 c2                	mov    %eax,%edx
  1007d6:	89 d0                	mov    %edx,%eax
  1007d8:	01 c0                	add    %eax,%eax
  1007da:	01 d0                	add    %edx,%eax
  1007dc:	c1 e0 02             	shl    $0x2,%eax
  1007df:	89 c2                	mov    %eax,%edx
  1007e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007e4:	01 d0                	add    %edx,%eax
  1007e6:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  1007ea:	0f b7 d0             	movzwl %ax,%edx
  1007ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007f0:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  1007f3:	eb 13                	jmp    100808 <debuginfo_eip+0x232>
        return -1;
  1007f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1007fa:	e9 12 01 00 00       	jmp    100911 <debuginfo_eip+0x33b>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  1007ff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100802:	83 e8 01             	sub    $0x1,%eax
  100805:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
  100808:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10080b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10080e:	39 c2                	cmp    %eax,%edx
  100810:	7c 56                	jl     100868 <debuginfo_eip+0x292>
           && stabs[lline].n_type != N_SOL
  100812:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100815:	89 c2                	mov    %eax,%edx
  100817:	89 d0                	mov    %edx,%eax
  100819:	01 c0                	add    %eax,%eax
  10081b:	01 d0                	add    %edx,%eax
  10081d:	c1 e0 02             	shl    $0x2,%eax
  100820:	89 c2                	mov    %eax,%edx
  100822:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100825:	01 d0                	add    %edx,%eax
  100827:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10082b:	3c 84                	cmp    $0x84,%al
  10082d:	74 39                	je     100868 <debuginfo_eip+0x292>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  10082f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100832:	89 c2                	mov    %eax,%edx
  100834:	89 d0                	mov    %edx,%eax
  100836:	01 c0                	add    %eax,%eax
  100838:	01 d0                	add    %edx,%eax
  10083a:	c1 e0 02             	shl    $0x2,%eax
  10083d:	89 c2                	mov    %eax,%edx
  10083f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100842:	01 d0                	add    %edx,%eax
  100844:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100848:	3c 64                	cmp    $0x64,%al
  10084a:	75 b3                	jne    1007ff <debuginfo_eip+0x229>
  10084c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10084f:	89 c2                	mov    %eax,%edx
  100851:	89 d0                	mov    %edx,%eax
  100853:	01 c0                	add    %eax,%eax
  100855:	01 d0                	add    %edx,%eax
  100857:	c1 e0 02             	shl    $0x2,%eax
  10085a:	89 c2                	mov    %eax,%edx
  10085c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10085f:	01 d0                	add    %edx,%eax
  100861:	8b 40 08             	mov    0x8(%eax),%eax
  100864:	85 c0                	test   %eax,%eax
  100866:	74 97                	je     1007ff <debuginfo_eip+0x229>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  100868:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10086b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10086e:	39 c2                	cmp    %eax,%edx
  100870:	7c 46                	jl     1008b8 <debuginfo_eip+0x2e2>
  100872:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100875:	89 c2                	mov    %eax,%edx
  100877:	89 d0                	mov    %edx,%eax
  100879:	01 c0                	add    %eax,%eax
  10087b:	01 d0                	add    %edx,%eax
  10087d:	c1 e0 02             	shl    $0x2,%eax
  100880:	89 c2                	mov    %eax,%edx
  100882:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100885:	01 d0                	add    %edx,%eax
  100887:	8b 10                	mov    (%eax),%edx
  100889:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  10088c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10088f:	29 c1                	sub    %eax,%ecx
  100891:	89 c8                	mov    %ecx,%eax
  100893:	39 c2                	cmp    %eax,%edx
  100895:	73 21                	jae    1008b8 <debuginfo_eip+0x2e2>
        info->eip_file = stabstr + stabs[lline].n_strx;
  100897:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10089a:	89 c2                	mov    %eax,%edx
  10089c:	89 d0                	mov    %edx,%eax
  10089e:	01 c0                	add    %eax,%eax
  1008a0:	01 d0                	add    %edx,%eax
  1008a2:	c1 e0 02             	shl    $0x2,%eax
  1008a5:	89 c2                	mov    %eax,%edx
  1008a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008aa:	01 d0                	add    %edx,%eax
  1008ac:	8b 10                	mov    (%eax),%edx
  1008ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1008b1:	01 c2                	add    %eax,%edx
  1008b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008b6:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  1008b8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1008bb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1008be:	39 c2                	cmp    %eax,%edx
  1008c0:	7d 4a                	jge    10090c <debuginfo_eip+0x336>
        for (lline = lfun + 1;
  1008c2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1008c5:	83 c0 01             	add    $0x1,%eax
  1008c8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  1008cb:	eb 18                	jmp    1008e5 <debuginfo_eip+0x30f>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  1008cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008d0:	8b 40 14             	mov    0x14(%eax),%eax
  1008d3:	8d 50 01             	lea    0x1(%eax),%edx
  1008d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008d9:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
  1008dc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008df:	83 c0 01             	add    $0x1,%eax
  1008e2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
  1008e5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1008e8:	8b 45 d8             	mov    -0x28(%ebp),%eax
        for (lline = lfun + 1;
  1008eb:	39 c2                	cmp    %eax,%edx
  1008ed:	7d 1d                	jge    10090c <debuginfo_eip+0x336>
             lline < rfun && stabs[lline].n_type == N_PSYM;
  1008ef:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008f2:	89 c2                	mov    %eax,%edx
  1008f4:	89 d0                	mov    %edx,%eax
  1008f6:	01 c0                	add    %eax,%eax
  1008f8:	01 d0                	add    %edx,%eax
  1008fa:	c1 e0 02             	shl    $0x2,%eax
  1008fd:	89 c2                	mov    %eax,%edx
  1008ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100902:	01 d0                	add    %edx,%eax
  100904:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100908:	3c a0                	cmp    $0xa0,%al
  10090a:	74 c1                	je     1008cd <debuginfo_eip+0x2f7>
        }
    }
    return 0;
  10090c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100911:	c9                   	leave  
  100912:	c3                   	ret    

00100913 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  100913:	55                   	push   %ebp
  100914:	89 e5                	mov    %esp,%ebp
  100916:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  100919:	c7 04 24 22 33 10 00 	movl   $0x103322,(%esp)
  100920:	e8 37 f9 ff ff       	call   10025c <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  100925:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  10092c:	00 
  10092d:	c7 04 24 3b 33 10 00 	movl   $0x10333b,(%esp)
  100934:	e8 23 f9 ff ff       	call   10025c <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  100939:	c7 44 24 04 1c 32 10 	movl   $0x10321c,0x4(%esp)
  100940:	00 
  100941:	c7 04 24 53 33 10 00 	movl   $0x103353,(%esp)
  100948:	e8 0f f9 ff ff       	call   10025c <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  10094d:	c7 44 24 04 16 ea 10 	movl   $0x10ea16,0x4(%esp)
  100954:	00 
  100955:	c7 04 24 6b 33 10 00 	movl   $0x10336b,(%esp)
  10095c:	e8 fb f8 ff ff       	call   10025c <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  100961:	c7 44 24 04 20 fd 10 	movl   $0x10fd20,0x4(%esp)
  100968:	00 
  100969:	c7 04 24 83 33 10 00 	movl   $0x103383,(%esp)
  100970:	e8 e7 f8 ff ff       	call   10025c <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  100975:	b8 20 fd 10 00       	mov    $0x10fd20,%eax
  10097a:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  100980:	b8 00 00 10 00       	mov    $0x100000,%eax
  100985:	29 c2                	sub    %eax,%edx
  100987:	89 d0                	mov    %edx,%eax
  100989:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  10098f:	85 c0                	test   %eax,%eax
  100991:	0f 48 c2             	cmovs  %edx,%eax
  100994:	c1 f8 0a             	sar    $0xa,%eax
  100997:	89 44 24 04          	mov    %eax,0x4(%esp)
  10099b:	c7 04 24 9c 33 10 00 	movl   $0x10339c,(%esp)
  1009a2:	e8 b5 f8 ff ff       	call   10025c <cprintf>
}
  1009a7:	c9                   	leave  
  1009a8:	c3                   	ret    

001009a9 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  1009a9:	55                   	push   %ebp
  1009aa:	89 e5                	mov    %esp,%ebp
  1009ac:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  1009b2:	8d 45 dc             	lea    -0x24(%ebp),%eax
  1009b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009b9:	8b 45 08             	mov    0x8(%ebp),%eax
  1009bc:	89 04 24             	mov    %eax,(%esp)
  1009bf:	e8 12 fc ff ff       	call   1005d6 <debuginfo_eip>
  1009c4:	85 c0                	test   %eax,%eax
  1009c6:	74 15                	je     1009dd <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  1009c8:	8b 45 08             	mov    0x8(%ebp),%eax
  1009cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009cf:	c7 04 24 c6 33 10 00 	movl   $0x1033c6,(%esp)
  1009d6:	e8 81 f8 ff ff       	call   10025c <cprintf>
  1009db:	eb 6d                	jmp    100a4a <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  1009dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  1009e4:	eb 1c                	jmp    100a02 <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
  1009e6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1009e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1009ec:	01 d0                	add    %edx,%eax
  1009ee:	0f b6 00             	movzbl (%eax),%eax
  1009f1:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  1009f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1009fa:	01 ca                	add    %ecx,%edx
  1009fc:	88 02                	mov    %al,(%edx)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  1009fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100a02:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a05:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  100a08:	7f dc                	jg     1009e6 <print_debuginfo+0x3d>
        }
        fnname[j] = '\0';
  100a0a:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  100a10:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a13:	01 d0                	add    %edx,%eax
  100a15:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
  100a18:	8b 45 ec             	mov    -0x14(%ebp),%eax
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  100a1b:	8b 55 08             	mov    0x8(%ebp),%edx
  100a1e:	89 d1                	mov    %edx,%ecx
  100a20:	29 c1                	sub    %eax,%ecx
  100a22:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100a25:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100a28:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  100a2c:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100a32:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  100a36:	89 54 24 08          	mov    %edx,0x8(%esp)
  100a3a:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a3e:	c7 04 24 e2 33 10 00 	movl   $0x1033e2,(%esp)
  100a45:	e8 12 f8 ff ff       	call   10025c <cprintf>
    }
}
  100a4a:	c9                   	leave  
  100a4b:	c3                   	ret    

00100a4c <read_eip>:

static __noinline uint32_t
read_eip(void) {
  100a4c:	55                   	push   %ebp
  100a4d:	89 e5                	mov    %esp,%ebp
  100a4f:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  100a52:	8b 45 04             	mov    0x4(%ebp),%eax
  100a55:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  100a58:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  100a5b:	c9                   	leave  
  100a5c:	c3                   	ret    

00100a5d <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
  100a5d:	55                   	push   %ebp
  100a5e:	89 e5                	mov    %esp,%ebp
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
}
  100a60:	5d                   	pop    %ebp
  100a61:	c3                   	ret    

00100a62 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100a62:	55                   	push   %ebp
  100a63:	89 e5                	mov    %esp,%ebp
  100a65:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  100a68:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100a6f:	eb 0c                	jmp    100a7d <parse+0x1b>
            *buf ++ = '\0';
  100a71:	8b 45 08             	mov    0x8(%ebp),%eax
  100a74:	8d 50 01             	lea    0x1(%eax),%edx
  100a77:	89 55 08             	mov    %edx,0x8(%ebp)
  100a7a:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100a7d:	8b 45 08             	mov    0x8(%ebp),%eax
  100a80:	0f b6 00             	movzbl (%eax),%eax
  100a83:	84 c0                	test   %al,%al
  100a85:	74 1d                	je     100aa4 <parse+0x42>
  100a87:	8b 45 08             	mov    0x8(%ebp),%eax
  100a8a:	0f b6 00             	movzbl (%eax),%eax
  100a8d:	0f be c0             	movsbl %al,%eax
  100a90:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a94:	c7 04 24 74 34 10 00 	movl   $0x103474,(%esp)
  100a9b:	e8 b3 1d 00 00       	call   102853 <strchr>
  100aa0:	85 c0                	test   %eax,%eax
  100aa2:	75 cd                	jne    100a71 <parse+0xf>
        }
        if (*buf == '\0') {
  100aa4:	8b 45 08             	mov    0x8(%ebp),%eax
  100aa7:	0f b6 00             	movzbl (%eax),%eax
  100aaa:	84 c0                	test   %al,%al
  100aac:	75 02                	jne    100ab0 <parse+0x4e>
            break;
  100aae:	eb 67                	jmp    100b17 <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100ab0:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100ab4:	75 14                	jne    100aca <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100ab6:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100abd:	00 
  100abe:	c7 04 24 79 34 10 00 	movl   $0x103479,(%esp)
  100ac5:	e8 92 f7 ff ff       	call   10025c <cprintf>
        }
        argv[argc ++] = buf;
  100aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100acd:	8d 50 01             	lea    0x1(%eax),%edx
  100ad0:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100ad3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100ada:	8b 45 0c             	mov    0xc(%ebp),%eax
  100add:	01 c2                	add    %eax,%edx
  100adf:	8b 45 08             	mov    0x8(%ebp),%eax
  100ae2:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100ae4:	eb 04                	jmp    100aea <parse+0x88>
            buf ++;
  100ae6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100aea:	8b 45 08             	mov    0x8(%ebp),%eax
  100aed:	0f b6 00             	movzbl (%eax),%eax
  100af0:	84 c0                	test   %al,%al
  100af2:	74 1d                	je     100b11 <parse+0xaf>
  100af4:	8b 45 08             	mov    0x8(%ebp),%eax
  100af7:	0f b6 00             	movzbl (%eax),%eax
  100afa:	0f be c0             	movsbl %al,%eax
  100afd:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b01:	c7 04 24 74 34 10 00 	movl   $0x103474,(%esp)
  100b08:	e8 46 1d 00 00       	call   102853 <strchr>
  100b0d:	85 c0                	test   %eax,%eax
  100b0f:	74 d5                	je     100ae6 <parse+0x84>
        }
    }
  100b11:	90                   	nop
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b12:	e9 66 ff ff ff       	jmp    100a7d <parse+0x1b>
    return argc;
  100b17:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100b1a:	c9                   	leave  
  100b1b:	c3                   	ret    

00100b1c <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100b1c:	55                   	push   %ebp
  100b1d:	89 e5                	mov    %esp,%ebp
  100b1f:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100b22:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100b25:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b29:	8b 45 08             	mov    0x8(%ebp),%eax
  100b2c:	89 04 24             	mov    %eax,(%esp)
  100b2f:	e8 2e ff ff ff       	call   100a62 <parse>
  100b34:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100b37:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100b3b:	75 0a                	jne    100b47 <runcmd+0x2b>
        return 0;
  100b3d:	b8 00 00 00 00       	mov    $0x0,%eax
  100b42:	e9 85 00 00 00       	jmp    100bcc <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100b47:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100b4e:	eb 5c                	jmp    100bac <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100b50:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  100b53:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100b56:	89 d0                	mov    %edx,%eax
  100b58:	01 c0                	add    %eax,%eax
  100b5a:	01 d0                	add    %edx,%eax
  100b5c:	c1 e0 02             	shl    $0x2,%eax
  100b5f:	05 00 e0 10 00       	add    $0x10e000,%eax
  100b64:	8b 00                	mov    (%eax),%eax
  100b66:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100b6a:	89 04 24             	mov    %eax,(%esp)
  100b6d:	e8 42 1c 00 00       	call   1027b4 <strcmp>
  100b72:	85 c0                	test   %eax,%eax
  100b74:	75 32                	jne    100ba8 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
  100b76:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100b79:	89 d0                	mov    %edx,%eax
  100b7b:	01 c0                	add    %eax,%eax
  100b7d:	01 d0                	add    %edx,%eax
  100b7f:	c1 e0 02             	shl    $0x2,%eax
  100b82:	05 00 e0 10 00       	add    $0x10e000,%eax
  100b87:	8b 40 08             	mov    0x8(%eax),%eax
  100b8a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100b8d:	8d 4a ff             	lea    -0x1(%edx),%ecx
  100b90:	8b 55 0c             	mov    0xc(%ebp),%edx
  100b93:	89 54 24 08          	mov    %edx,0x8(%esp)
  100b97:	8d 55 b0             	lea    -0x50(%ebp),%edx
  100b9a:	83 c2 04             	add    $0x4,%edx
  100b9d:	89 54 24 04          	mov    %edx,0x4(%esp)
  100ba1:	89 0c 24             	mov    %ecx,(%esp)
  100ba4:	ff d0                	call   *%eax
  100ba6:	eb 24                	jmp    100bcc <runcmd+0xb0>
    for (i = 0; i < NCOMMANDS; i ++) {
  100ba8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100baf:	83 f8 02             	cmp    $0x2,%eax
  100bb2:	76 9c                	jbe    100b50 <runcmd+0x34>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100bb4:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100bb7:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bbb:	c7 04 24 97 34 10 00 	movl   $0x103497,(%esp)
  100bc2:	e8 95 f6 ff ff       	call   10025c <cprintf>
    return 0;
  100bc7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100bcc:	c9                   	leave  
  100bcd:	c3                   	ret    

00100bce <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100bce:	55                   	push   %ebp
  100bcf:	89 e5                	mov    %esp,%ebp
  100bd1:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100bd4:	c7 04 24 b0 34 10 00 	movl   $0x1034b0,(%esp)
  100bdb:	e8 7c f6 ff ff       	call   10025c <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100be0:	c7 04 24 d8 34 10 00 	movl   $0x1034d8,(%esp)
  100be7:	e8 70 f6 ff ff       	call   10025c <cprintf>

    if (tf != NULL) {
  100bec:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100bf0:	74 0b                	je     100bfd <kmonitor+0x2f>
        print_trapframe(tf);
  100bf2:	8b 45 08             	mov    0x8(%ebp),%eax
  100bf5:	89 04 24             	mov    %eax,(%esp)
  100bf8:	e8 a5 0b 00 00       	call   1017a2 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100bfd:	c7 04 24 fd 34 10 00 	movl   $0x1034fd,(%esp)
  100c04:	e8 f4 f6 ff ff       	call   1002fd <readline>
  100c09:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100c0c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100c10:	74 18                	je     100c2a <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
  100c12:	8b 45 08             	mov    0x8(%ebp),%eax
  100c15:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c1c:	89 04 24             	mov    %eax,(%esp)
  100c1f:	e8 f8 fe ff ff       	call   100b1c <runcmd>
  100c24:	85 c0                	test   %eax,%eax
  100c26:	79 02                	jns    100c2a <kmonitor+0x5c>
                break;
  100c28:	eb 02                	jmp    100c2c <kmonitor+0x5e>
            }
        }
    }
  100c2a:	eb d1                	jmp    100bfd <kmonitor+0x2f>
}
  100c2c:	c9                   	leave  
  100c2d:	c3                   	ret    

00100c2e <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100c2e:	55                   	push   %ebp
  100c2f:	89 e5                	mov    %esp,%ebp
  100c31:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c34:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100c3b:	eb 3f                	jmp    100c7c <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100c3d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c40:	89 d0                	mov    %edx,%eax
  100c42:	01 c0                	add    %eax,%eax
  100c44:	01 d0                	add    %edx,%eax
  100c46:	c1 e0 02             	shl    $0x2,%eax
  100c49:	05 00 e0 10 00       	add    $0x10e000,%eax
  100c4e:	8b 48 04             	mov    0x4(%eax),%ecx
  100c51:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c54:	89 d0                	mov    %edx,%eax
  100c56:	01 c0                	add    %eax,%eax
  100c58:	01 d0                	add    %edx,%eax
  100c5a:	c1 e0 02             	shl    $0x2,%eax
  100c5d:	05 00 e0 10 00       	add    $0x10e000,%eax
  100c62:	8b 00                	mov    (%eax),%eax
  100c64:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100c68:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c6c:	c7 04 24 01 35 10 00 	movl   $0x103501,(%esp)
  100c73:	e8 e4 f5 ff ff       	call   10025c <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
  100c78:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100c7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c7f:	83 f8 02             	cmp    $0x2,%eax
  100c82:	76 b9                	jbe    100c3d <mon_help+0xf>
    }
    return 0;
  100c84:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100c89:	c9                   	leave  
  100c8a:	c3                   	ret    

00100c8b <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100c8b:	55                   	push   %ebp
  100c8c:	89 e5                	mov    %esp,%ebp
  100c8e:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100c91:	e8 7d fc ff ff       	call   100913 <print_kerninfo>
    return 0;
  100c96:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100c9b:	c9                   	leave  
  100c9c:	c3                   	ret    

00100c9d <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100c9d:	55                   	push   %ebp
  100c9e:	89 e5                	mov    %esp,%ebp
  100ca0:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100ca3:	e8 b5 fd ff ff       	call   100a5d <print_stackframe>
    return 0;
  100ca8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cad:	c9                   	leave  
  100cae:	c3                   	ret    

00100caf <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100caf:	55                   	push   %ebp
  100cb0:	89 e5                	mov    %esp,%ebp
  100cb2:	83 ec 28             	sub    $0x28,%esp
  100cb5:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
  100cbb:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100cbf:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100cc3:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100cc7:	ee                   	out    %al,(%dx)
  100cc8:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100cce:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
  100cd2:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100cd6:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100cda:	ee                   	out    %al,(%dx)
  100cdb:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
  100ce1:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
  100ce5:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100ce9:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100ced:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100cee:	c7 05 08 f9 10 00 00 	movl   $0x0,0x10f908
  100cf5:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100cf8:	c7 04 24 0a 35 10 00 	movl   $0x10350a,(%esp)
  100cff:	e8 58 f5 ff ff       	call   10025c <cprintf>
    pic_enable(IRQ_TIMER);
  100d04:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100d0b:	e8 b5 08 00 00       	call   1015c5 <pic_enable>
}
  100d10:	c9                   	leave  
  100d11:	c3                   	ret    

00100d12 <delay>:
#include <picirq.h>
#include <trap.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100d12:	55                   	push   %ebp
  100d13:	89 e5                	mov    %esp,%ebp
  100d15:	83 ec 10             	sub    $0x10,%esp
  100d18:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100d1e:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100d22:	89 c2                	mov    %eax,%edx
  100d24:	ec                   	in     (%dx),%al
  100d25:	88 45 fd             	mov    %al,-0x3(%ebp)
  100d28:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100d2e:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100d32:	89 c2                	mov    %eax,%edx
  100d34:	ec                   	in     (%dx),%al
  100d35:	88 45 f9             	mov    %al,-0x7(%ebp)
  100d38:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
  100d3e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100d42:	89 c2                	mov    %eax,%edx
  100d44:	ec                   	in     (%dx),%al
  100d45:	88 45 f5             	mov    %al,-0xb(%ebp)
  100d48:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
  100d4e:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100d52:	89 c2                	mov    %eax,%edx
  100d54:	ec                   	in     (%dx),%al
  100d55:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100d58:	c9                   	leave  
  100d59:	c3                   	ret    

00100d5a <cga_init>:
//    -- 数据寄存器 映射 到 端口 0x3D5或0x3B5 
//    -- 索引寄存器 0x3D4或0x3B4,决定在数据寄存器中的数据表示什么。

/* TEXT-mode CGA/VGA display output */
static void
cga_init(void) {
  100d5a:	55                   	push   %ebp
  100d5b:	89 e5                	mov    %esp,%ebp
  100d5d:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)CGA_BUF;   //CGA_BUF: 0xB8000 (彩色显示的显存物理基址)
  100d60:	c7 45 fc 00 80 0b 00 	movl   $0xb8000,-0x4(%ebp)
    uint16_t was = *cp;                                            //保存当前显存0xB8000处的值
  100d67:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100d6a:	0f b7 00             	movzwl (%eax),%eax
  100d6d:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;                                   // 给这个地址随便写个值，看看能否再读出同样的值
  100d71:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100d74:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {                                            // 如果读不出来，说明没有这块显存，即是单显配置
  100d79:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100d7c:	0f b7 00             	movzwl (%eax),%eax
  100d7f:	66 3d 5a a5          	cmp    $0xa55a,%ax
  100d83:	74 12                	je     100d97 <cga_init+0x3d>
        cp = (uint16_t*)MONO_BUF;                         //设置为单显的显存基址 MONO_BUF： 0xB0000
  100d85:	c7 45 fc 00 00 0b 00 	movl   $0xb0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;                           //设置为单显控制的IO地址，MONO_BASE: 0x3B4
  100d8c:	66 c7 05 66 ee 10 00 	movw   $0x3b4,0x10ee66
  100d93:	b4 03 
  100d95:	eb 13                	jmp    100daa <cga_init+0x50>
    } else {                                                                // 如果读出来了，有这块显存，即是彩显配置
        *cp = was;                                                      //还原原来显存位置的值
  100d97:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100d9a:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100d9e:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;                               // 设置为彩显控制的IO地址，CGA_BASE: 0x3D4 
  100da1:	66 c7 05 66 ee 10 00 	movw   $0x3d4,0x10ee66
  100da8:	d4 03 
    // Extract cursor location
    // 6845索引寄存器的index 0x0E（及十进制的14）== 光标位置(高位)
    // 6845索引寄存器的index 0x0F（及十进制的15）== 光标位置(低位)
    // 6845 reg 15 : Cursor Address (Low Byte)
    uint32_t pos;
    outb(addr_6845, 14);                                        
  100daa:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100db1:	0f b7 c0             	movzwl %ax,%eax
  100db4:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  100db8:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100dbc:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100dc0:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100dc4:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;                       //读出了光标位置(高位)
  100dc5:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100dcc:	83 c0 01             	add    $0x1,%eax
  100dcf:	0f b7 c0             	movzwl %ax,%eax
  100dd2:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100dd6:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  100dda:	89 c2                	mov    %eax,%edx
  100ddc:	ec                   	in     (%dx),%al
  100ddd:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  100de0:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100de4:	0f b6 c0             	movzbl %al,%eax
  100de7:	c1 e0 08             	shl    $0x8,%eax
  100dea:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100ded:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100df4:	0f b7 c0             	movzwl %ax,%eax
  100df7:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
  100dfb:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100dff:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100e03:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100e07:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);                             //读出了光标位置(低位)
  100e08:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100e0f:	83 c0 01             	add    $0x1,%eax
  100e12:	0f b7 c0             	movzwl %ax,%eax
  100e15:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100e19:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
  100e1d:	89 c2                	mov    %eax,%edx
  100e1f:	ec                   	in     (%dx),%al
  100e20:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
  100e23:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100e27:	0f b6 c0             	movzbl %al,%eax
  100e2a:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;                                  //crt_buf是CGA显存起始地址
  100e2d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e30:	a3 60 ee 10 00       	mov    %eax,0x10ee60
    crt_pos = pos;                                                  //crt_pos是CGA当前光标位置
  100e35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100e38:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
}
  100e3e:	c9                   	leave  
  100e3f:	c3                   	ret    

00100e40 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100e40:	55                   	push   %ebp
  100e41:	89 e5                	mov    %esp,%ebp
  100e43:	83 ec 48             	sub    $0x48,%esp
  100e46:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
  100e4c:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100e50:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100e54:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100e58:	ee                   	out    %al,(%dx)
  100e59:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
  100e5f:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
  100e63:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100e67:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100e6b:	ee                   	out    %al,(%dx)
  100e6c:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
  100e72:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
  100e76:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100e7a:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100e7e:	ee                   	out    %al,(%dx)
  100e7f:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  100e85:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
  100e89:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100e8d:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100e91:	ee                   	out    %al,(%dx)
  100e92:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
  100e98:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
  100e9c:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100ea0:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100ea4:	ee                   	out    %al,(%dx)
  100ea5:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
  100eab:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
  100eaf:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  100eb3:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  100eb7:	ee                   	out    %al,(%dx)
  100eb8:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
  100ebe:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
  100ec2:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100ec6:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  100eca:	ee                   	out    %al,(%dx)
  100ecb:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100ed1:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
  100ed5:	89 c2                	mov    %eax,%edx
  100ed7:	ec                   	in     (%dx),%al
  100ed8:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
  100edb:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  100edf:	3c ff                	cmp    $0xff,%al
  100ee1:	0f 95 c0             	setne  %al
  100ee4:	0f b6 c0             	movzbl %al,%eax
  100ee7:	a3 68 ee 10 00       	mov    %eax,0x10ee68
  100eec:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100ef2:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
  100ef6:	89 c2                	mov    %eax,%edx
  100ef8:	ec                   	in     (%dx),%al
  100ef9:	88 45 d5             	mov    %al,-0x2b(%ebp)
  100efc:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
  100f02:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
  100f06:	89 c2                	mov    %eax,%edx
  100f08:	ec                   	in     (%dx),%al
  100f09:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  100f0c:	a1 68 ee 10 00       	mov    0x10ee68,%eax
  100f11:	85 c0                	test   %eax,%eax
  100f13:	74 0c                	je     100f21 <serial_init+0xe1>
        pic_enable(IRQ_COM1);
  100f15:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  100f1c:	e8 a4 06 00 00       	call   1015c5 <pic_enable>
    }
}
  100f21:	c9                   	leave  
  100f22:	c3                   	ret    

00100f23 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  100f23:	55                   	push   %ebp
  100f24:	89 e5                	mov    %esp,%ebp
  100f26:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  100f29:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  100f30:	eb 09                	jmp    100f3b <lpt_putc_sub+0x18>
        delay();
  100f32:	e8 db fd ff ff       	call   100d12 <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  100f37:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  100f3b:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
  100f41:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100f45:	89 c2                	mov    %eax,%edx
  100f47:	ec                   	in     (%dx),%al
  100f48:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  100f4b:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  100f4f:	84 c0                	test   %al,%al
  100f51:	78 09                	js     100f5c <lpt_putc_sub+0x39>
  100f53:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  100f5a:	7e d6                	jle    100f32 <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
  100f5c:	8b 45 08             	mov    0x8(%ebp),%eax
  100f5f:	0f b6 c0             	movzbl %al,%eax
  100f62:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
  100f68:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100f6b:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100f6f:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100f73:	ee                   	out    %al,(%dx)
  100f74:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
  100f7a:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
  100f7e:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100f82:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100f86:	ee                   	out    %al,(%dx)
  100f87:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
  100f8d:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
  100f91:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100f95:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100f99:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  100f9a:	c9                   	leave  
  100f9b:	c3                   	ret    

00100f9c <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  100f9c:	55                   	push   %ebp
  100f9d:	89 e5                	mov    %esp,%ebp
  100f9f:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  100fa2:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  100fa6:	74 0d                	je     100fb5 <lpt_putc+0x19>
        lpt_putc_sub(c);
  100fa8:	8b 45 08             	mov    0x8(%ebp),%eax
  100fab:	89 04 24             	mov    %eax,(%esp)
  100fae:	e8 70 ff ff ff       	call   100f23 <lpt_putc_sub>
  100fb3:	eb 24                	jmp    100fd9 <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
  100fb5:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  100fbc:	e8 62 ff ff ff       	call   100f23 <lpt_putc_sub>
        lpt_putc_sub(' ');
  100fc1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  100fc8:	e8 56 ff ff ff       	call   100f23 <lpt_putc_sub>
        lpt_putc_sub('\b');
  100fcd:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  100fd4:	e8 4a ff ff ff       	call   100f23 <lpt_putc_sub>
    }
}
  100fd9:	c9                   	leave  
  100fda:	c3                   	ret    

00100fdb <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  100fdb:	55                   	push   %ebp
  100fdc:	89 e5                	mov    %esp,%ebp
  100fde:	53                   	push   %ebx
  100fdf:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
  100fe2:	8b 45 08             	mov    0x8(%ebp),%eax
  100fe5:	b0 00                	mov    $0x0,%al
  100fe7:	85 c0                	test   %eax,%eax
  100fe9:	75 07                	jne    100ff2 <cga_putc+0x17>
        c |= 0x0700;
  100feb:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  100ff2:	8b 45 08             	mov    0x8(%ebp),%eax
  100ff5:	0f b6 c0             	movzbl %al,%eax
  100ff8:	83 f8 0a             	cmp    $0xa,%eax
  100ffb:	74 4c                	je     101049 <cga_putc+0x6e>
  100ffd:	83 f8 0d             	cmp    $0xd,%eax
  101000:	74 57                	je     101059 <cga_putc+0x7e>
  101002:	83 f8 08             	cmp    $0x8,%eax
  101005:	0f 85 88 00 00 00    	jne    101093 <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
  10100b:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  101012:	66 85 c0             	test   %ax,%ax
  101015:	74 30                	je     101047 <cga_putc+0x6c>
            crt_pos --;
  101017:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  10101e:	83 e8 01             	sub    $0x1,%eax
  101021:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  101027:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  10102c:	0f b7 15 64 ee 10 00 	movzwl 0x10ee64,%edx
  101033:	0f b7 d2             	movzwl %dx,%edx
  101036:	01 d2                	add    %edx,%edx
  101038:	01 c2                	add    %eax,%edx
  10103a:	8b 45 08             	mov    0x8(%ebp),%eax
  10103d:	b0 00                	mov    $0x0,%al
  10103f:	83 c8 20             	or     $0x20,%eax
  101042:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  101045:	eb 72                	jmp    1010b9 <cga_putc+0xde>
  101047:	eb 70                	jmp    1010b9 <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
  101049:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  101050:	83 c0 50             	add    $0x50,%eax
  101053:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  101059:	0f b7 1d 64 ee 10 00 	movzwl 0x10ee64,%ebx
  101060:	0f b7 0d 64 ee 10 00 	movzwl 0x10ee64,%ecx
  101067:	0f b7 c1             	movzwl %cx,%eax
  10106a:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
  101070:	c1 e8 10             	shr    $0x10,%eax
  101073:	89 c2                	mov    %eax,%edx
  101075:	66 c1 ea 06          	shr    $0x6,%dx
  101079:	89 d0                	mov    %edx,%eax
  10107b:	c1 e0 02             	shl    $0x2,%eax
  10107e:	01 d0                	add    %edx,%eax
  101080:	c1 e0 04             	shl    $0x4,%eax
  101083:	29 c1                	sub    %eax,%ecx
  101085:	89 ca                	mov    %ecx,%edx
  101087:	89 d8                	mov    %ebx,%eax
  101089:	29 d0                	sub    %edx,%eax
  10108b:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
        break;
  101091:	eb 26                	jmp    1010b9 <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  101093:	8b 0d 60 ee 10 00    	mov    0x10ee60,%ecx
  101099:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1010a0:	8d 50 01             	lea    0x1(%eax),%edx
  1010a3:	66 89 15 64 ee 10 00 	mov    %dx,0x10ee64
  1010aa:	0f b7 c0             	movzwl %ax,%eax
  1010ad:	01 c0                	add    %eax,%eax
  1010af:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  1010b2:	8b 45 08             	mov    0x8(%ebp),%eax
  1010b5:	66 89 02             	mov    %ax,(%edx)
        break;
  1010b8:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  1010b9:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1010c0:	66 3d cf 07          	cmp    $0x7cf,%ax
  1010c4:	76 5b                	jbe    101121 <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  1010c6:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  1010cb:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  1010d1:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  1010d6:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  1010dd:	00 
  1010de:	89 54 24 04          	mov    %edx,0x4(%esp)
  1010e2:	89 04 24             	mov    %eax,(%esp)
  1010e5:	e8 67 19 00 00       	call   102a51 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  1010ea:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  1010f1:	eb 15                	jmp    101108 <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
  1010f3:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  1010f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1010fb:	01 d2                	add    %edx,%edx
  1010fd:	01 d0                	add    %edx,%eax
  1010ff:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101104:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  101108:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  10110f:	7e e2                	jle    1010f3 <cga_putc+0x118>
        }
        crt_pos -= CRT_COLS;
  101111:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  101118:	83 e8 50             	sub    $0x50,%eax
  10111b:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  101121:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  101128:	0f b7 c0             	movzwl %ax,%eax
  10112b:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  10112f:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
  101133:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  101137:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  10113b:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
  10113c:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  101143:	66 c1 e8 08          	shr    $0x8,%ax
  101147:	0f b6 c0             	movzbl %al,%eax
  10114a:	0f b7 15 66 ee 10 00 	movzwl 0x10ee66,%edx
  101151:	83 c2 01             	add    $0x1,%edx
  101154:	0f b7 d2             	movzwl %dx,%edx
  101157:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
  10115b:	88 45 ed             	mov    %al,-0x13(%ebp)
  10115e:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101162:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101166:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
  101167:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  10116e:	0f b7 c0             	movzwl %ax,%eax
  101171:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
  101175:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
  101179:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  10117d:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101181:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
  101182:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  101189:	0f b6 c0             	movzbl %al,%eax
  10118c:	0f b7 15 66 ee 10 00 	movzwl 0x10ee66,%edx
  101193:	83 c2 01             	add    $0x1,%edx
  101196:	0f b7 d2             	movzwl %dx,%edx
  101199:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
  10119d:	88 45 e5             	mov    %al,-0x1b(%ebp)
  1011a0:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  1011a4:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  1011a8:	ee                   	out    %al,(%dx)
}
  1011a9:	83 c4 34             	add    $0x34,%esp
  1011ac:	5b                   	pop    %ebx
  1011ad:	5d                   	pop    %ebp
  1011ae:	c3                   	ret    

001011af <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  1011af:	55                   	push   %ebp
  1011b0:	89 e5                	mov    %esp,%ebp
  1011b2:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1011b5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1011bc:	eb 09                	jmp    1011c7 <serial_putc_sub+0x18>
        delay();
  1011be:	e8 4f fb ff ff       	call   100d12 <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1011c3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  1011c7:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  1011cd:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1011d1:	89 c2                	mov    %eax,%edx
  1011d3:	ec                   	in     (%dx),%al
  1011d4:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  1011d7:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  1011db:	0f b6 c0             	movzbl %al,%eax
  1011de:	83 e0 20             	and    $0x20,%eax
  1011e1:	85 c0                	test   %eax,%eax
  1011e3:	75 09                	jne    1011ee <serial_putc_sub+0x3f>
  1011e5:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  1011ec:	7e d0                	jle    1011be <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
  1011ee:	8b 45 08             	mov    0x8(%ebp),%eax
  1011f1:	0f b6 c0             	movzbl %al,%eax
  1011f4:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  1011fa:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1011fd:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  101201:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101205:	ee                   	out    %al,(%dx)
}
  101206:	c9                   	leave  
  101207:	c3                   	ret    

00101208 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  101208:	55                   	push   %ebp
  101209:	89 e5                	mov    %esp,%ebp
  10120b:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  10120e:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  101212:	74 0d                	je     101221 <serial_putc+0x19>
        serial_putc_sub(c);
  101214:	8b 45 08             	mov    0x8(%ebp),%eax
  101217:	89 04 24             	mov    %eax,(%esp)
  10121a:	e8 90 ff ff ff       	call   1011af <serial_putc_sub>
  10121f:	eb 24                	jmp    101245 <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
  101221:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101228:	e8 82 ff ff ff       	call   1011af <serial_putc_sub>
        serial_putc_sub(' ');
  10122d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  101234:	e8 76 ff ff ff       	call   1011af <serial_putc_sub>
        serial_putc_sub('\b');
  101239:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101240:	e8 6a ff ff ff       	call   1011af <serial_putc_sub>
    }
}
  101245:	c9                   	leave  
  101246:	c3                   	ret    

00101247 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  101247:	55                   	push   %ebp
  101248:	89 e5                	mov    %esp,%ebp
  10124a:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  10124d:	eb 33                	jmp    101282 <cons_intr+0x3b>
        if (c != 0) {
  10124f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  101253:	74 2d                	je     101282 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  101255:	a1 84 f0 10 00       	mov    0x10f084,%eax
  10125a:	8d 50 01             	lea    0x1(%eax),%edx
  10125d:	89 15 84 f0 10 00    	mov    %edx,0x10f084
  101263:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101266:	88 90 80 ee 10 00    	mov    %dl,0x10ee80(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  10126c:	a1 84 f0 10 00       	mov    0x10f084,%eax
  101271:	3d 00 02 00 00       	cmp    $0x200,%eax
  101276:	75 0a                	jne    101282 <cons_intr+0x3b>
                cons.wpos = 0;
  101278:	c7 05 84 f0 10 00 00 	movl   $0x0,0x10f084
  10127f:	00 00 00 
    while ((c = (*proc)()) != -1) {
  101282:	8b 45 08             	mov    0x8(%ebp),%eax
  101285:	ff d0                	call   *%eax
  101287:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10128a:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  10128e:	75 bf                	jne    10124f <cons_intr+0x8>
            }
        }
    }
}
  101290:	c9                   	leave  
  101291:	c3                   	ret    

00101292 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  101292:	55                   	push   %ebp
  101293:	89 e5                	mov    %esp,%ebp
  101295:	83 ec 10             	sub    $0x10,%esp
  101298:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  10129e:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1012a2:	89 c2                	mov    %eax,%edx
  1012a4:	ec                   	in     (%dx),%al
  1012a5:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  1012a8:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  1012ac:	0f b6 c0             	movzbl %al,%eax
  1012af:	83 e0 01             	and    $0x1,%eax
  1012b2:	85 c0                	test   %eax,%eax
  1012b4:	75 07                	jne    1012bd <serial_proc_data+0x2b>
        return -1;
  1012b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1012bb:	eb 2a                	jmp    1012e7 <serial_proc_data+0x55>
  1012bd:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  1012c3:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  1012c7:	89 c2                	mov    %eax,%edx
  1012c9:	ec                   	in     (%dx),%al
  1012ca:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
  1012cd:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  1012d1:	0f b6 c0             	movzbl %al,%eax
  1012d4:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  1012d7:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  1012db:	75 07                	jne    1012e4 <serial_proc_data+0x52>
        c = '\b';
  1012dd:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  1012e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1012e7:	c9                   	leave  
  1012e8:	c3                   	ret    

001012e9 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  1012e9:	55                   	push   %ebp
  1012ea:	89 e5                	mov    %esp,%ebp
  1012ec:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  1012ef:	a1 68 ee 10 00       	mov    0x10ee68,%eax
  1012f4:	85 c0                	test   %eax,%eax
  1012f6:	74 0c                	je     101304 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
  1012f8:	c7 04 24 92 12 10 00 	movl   $0x101292,(%esp)
  1012ff:	e8 43 ff ff ff       	call   101247 <cons_intr>
    }
}
  101304:	c9                   	leave  
  101305:	c3                   	ret    

00101306 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  101306:	55                   	push   %ebp
  101307:	89 e5                	mov    %esp,%ebp
  101309:	83 ec 38             	sub    $0x38,%esp
  10130c:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101312:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  101316:	89 c2                	mov    %eax,%edx
  101318:	ec                   	in     (%dx),%al
  101319:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
  10131c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  101320:	0f b6 c0             	movzbl %al,%eax
  101323:	83 e0 01             	and    $0x1,%eax
  101326:	85 c0                	test   %eax,%eax
  101328:	75 0a                	jne    101334 <kbd_proc_data+0x2e>
        return -1;
  10132a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10132f:	e9 59 01 00 00       	jmp    10148d <kbd_proc_data+0x187>
  101334:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  10133a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  10133e:	89 c2                	mov    %eax,%edx
  101340:	ec                   	in     (%dx),%al
  101341:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  101344:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
  101348:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  10134b:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  10134f:	75 17                	jne    101368 <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
  101351:	a1 88 f0 10 00       	mov    0x10f088,%eax
  101356:	83 c8 40             	or     $0x40,%eax
  101359:	a3 88 f0 10 00       	mov    %eax,0x10f088
        return 0;
  10135e:	b8 00 00 00 00       	mov    $0x0,%eax
  101363:	e9 25 01 00 00       	jmp    10148d <kbd_proc_data+0x187>
    } else if (data & 0x80) {
  101368:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10136c:	84 c0                	test   %al,%al
  10136e:	79 47                	jns    1013b7 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  101370:	a1 88 f0 10 00       	mov    0x10f088,%eax
  101375:	83 e0 40             	and    $0x40,%eax
  101378:	85 c0                	test   %eax,%eax
  10137a:	75 09                	jne    101385 <kbd_proc_data+0x7f>
  10137c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101380:	83 e0 7f             	and    $0x7f,%eax
  101383:	eb 04                	jmp    101389 <kbd_proc_data+0x83>
  101385:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101389:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  10138c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101390:	0f b6 80 40 e0 10 00 	movzbl 0x10e040(%eax),%eax
  101397:	83 c8 40             	or     $0x40,%eax
  10139a:	0f b6 c0             	movzbl %al,%eax
  10139d:	f7 d0                	not    %eax
  10139f:	89 c2                	mov    %eax,%edx
  1013a1:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1013a6:	21 d0                	and    %edx,%eax
  1013a8:	a3 88 f0 10 00       	mov    %eax,0x10f088
        return 0;
  1013ad:	b8 00 00 00 00       	mov    $0x0,%eax
  1013b2:	e9 d6 00 00 00       	jmp    10148d <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
  1013b7:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1013bc:	83 e0 40             	and    $0x40,%eax
  1013bf:	85 c0                	test   %eax,%eax
  1013c1:	74 11                	je     1013d4 <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  1013c3:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  1013c7:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1013cc:	83 e0 bf             	and    $0xffffffbf,%eax
  1013cf:	a3 88 f0 10 00       	mov    %eax,0x10f088
    }

    shift |= shiftcode[data];
  1013d4:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1013d8:	0f b6 80 40 e0 10 00 	movzbl 0x10e040(%eax),%eax
  1013df:	0f b6 d0             	movzbl %al,%edx
  1013e2:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1013e7:	09 d0                	or     %edx,%eax
  1013e9:	a3 88 f0 10 00       	mov    %eax,0x10f088
    shift ^= togglecode[data];
  1013ee:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1013f2:	0f b6 80 40 e1 10 00 	movzbl 0x10e140(%eax),%eax
  1013f9:	0f b6 d0             	movzbl %al,%edx
  1013fc:	a1 88 f0 10 00       	mov    0x10f088,%eax
  101401:	31 d0                	xor    %edx,%eax
  101403:	a3 88 f0 10 00       	mov    %eax,0x10f088

    c = charcode[shift & (CTL | SHIFT)][data];
  101408:	a1 88 f0 10 00       	mov    0x10f088,%eax
  10140d:	83 e0 03             	and    $0x3,%eax
  101410:	8b 14 85 40 e5 10 00 	mov    0x10e540(,%eax,4),%edx
  101417:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10141b:	01 d0                	add    %edx,%eax
  10141d:	0f b6 00             	movzbl (%eax),%eax
  101420:	0f b6 c0             	movzbl %al,%eax
  101423:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  101426:	a1 88 f0 10 00       	mov    0x10f088,%eax
  10142b:	83 e0 08             	and    $0x8,%eax
  10142e:	85 c0                	test   %eax,%eax
  101430:	74 22                	je     101454 <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
  101432:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  101436:	7e 0c                	jle    101444 <kbd_proc_data+0x13e>
  101438:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  10143c:	7f 06                	jg     101444 <kbd_proc_data+0x13e>
            c += 'A' - 'a';
  10143e:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  101442:	eb 10                	jmp    101454 <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
  101444:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  101448:	7e 0a                	jle    101454 <kbd_proc_data+0x14e>
  10144a:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  10144e:	7f 04                	jg     101454 <kbd_proc_data+0x14e>
            c += 'a' - 'A';
  101450:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  101454:	a1 88 f0 10 00       	mov    0x10f088,%eax
  101459:	f7 d0                	not    %eax
  10145b:	83 e0 06             	and    $0x6,%eax
  10145e:	85 c0                	test   %eax,%eax
  101460:	75 28                	jne    10148a <kbd_proc_data+0x184>
  101462:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  101469:	75 1f                	jne    10148a <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
  10146b:	c7 04 24 25 35 10 00 	movl   $0x103525,(%esp)
  101472:	e8 e5 ed ff ff       	call   10025c <cprintf>
  101477:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
  10147d:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101481:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  101485:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
  101489:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  10148a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10148d:	c9                   	leave  
  10148e:	c3                   	ret    

0010148f <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  10148f:	55                   	push   %ebp
  101490:	89 e5                	mov    %esp,%ebp
  101492:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  101495:	c7 04 24 06 13 10 00 	movl   $0x101306,(%esp)
  10149c:	e8 a6 fd ff ff       	call   101247 <cons_intr>
}
  1014a1:	c9                   	leave  
  1014a2:	c3                   	ret    

001014a3 <kbd_init>:

static void
kbd_init(void) {
  1014a3:	55                   	push   %ebp
  1014a4:	89 e5                	mov    %esp,%ebp
  1014a6:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  1014a9:	e8 e1 ff ff ff       	call   10148f <kbd_intr>
    pic_enable(IRQ_KBD);
  1014ae:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1014b5:	e8 0b 01 00 00       	call   1015c5 <pic_enable>
}
  1014ba:	c9                   	leave  
  1014bb:	c3                   	ret    

001014bc <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  1014bc:	55                   	push   %ebp
  1014bd:	89 e5                	mov    %esp,%ebp
  1014bf:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  1014c2:	e8 93 f8 ff ff       	call   100d5a <cga_init>
    serial_init();
  1014c7:	e8 74 f9 ff ff       	call   100e40 <serial_init>
    kbd_init();
  1014cc:	e8 d2 ff ff ff       	call   1014a3 <kbd_init>
    if (!serial_exists) {
  1014d1:	a1 68 ee 10 00       	mov    0x10ee68,%eax
  1014d6:	85 c0                	test   %eax,%eax
  1014d8:	75 0c                	jne    1014e6 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  1014da:	c7 04 24 31 35 10 00 	movl   $0x103531,(%esp)
  1014e1:	e8 76 ed ff ff       	call   10025c <cprintf>
    }
}
  1014e6:	c9                   	leave  
  1014e7:	c3                   	ret    

001014e8 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  1014e8:	55                   	push   %ebp
  1014e9:	89 e5                	mov    %esp,%ebp
  1014eb:	83 ec 18             	sub    $0x18,%esp
    lpt_putc(c);
  1014ee:	8b 45 08             	mov    0x8(%ebp),%eax
  1014f1:	89 04 24             	mov    %eax,(%esp)
  1014f4:	e8 a3 fa ff ff       	call   100f9c <lpt_putc>
    cga_putc(c);
  1014f9:	8b 45 08             	mov    0x8(%ebp),%eax
  1014fc:	89 04 24             	mov    %eax,(%esp)
  1014ff:	e8 d7 fa ff ff       	call   100fdb <cga_putc>
    serial_putc(c);
  101504:	8b 45 08             	mov    0x8(%ebp),%eax
  101507:	89 04 24             	mov    %eax,(%esp)
  10150a:	e8 f9 fc ff ff       	call   101208 <serial_putc>
}
  10150f:	c9                   	leave  
  101510:	c3                   	ret    

00101511 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  101511:	55                   	push   %ebp
  101512:	89 e5                	mov    %esp,%ebp
  101514:	83 ec 18             	sub    $0x18,%esp
    int c;

    // poll for any pending input characters,
    // so that this function works even when interrupts are disabled
    // (e.g., when called from the kernel monitor).
    serial_intr();
  101517:	e8 cd fd ff ff       	call   1012e9 <serial_intr>
    kbd_intr();
  10151c:	e8 6e ff ff ff       	call   10148f <kbd_intr>

    // grab the next character from the input buffer.
    if (cons.rpos != cons.wpos) {
  101521:	8b 15 80 f0 10 00    	mov    0x10f080,%edx
  101527:	a1 84 f0 10 00       	mov    0x10f084,%eax
  10152c:	39 c2                	cmp    %eax,%edx
  10152e:	74 36                	je     101566 <cons_getc+0x55>
        c = cons.buf[cons.rpos ++];
  101530:	a1 80 f0 10 00       	mov    0x10f080,%eax
  101535:	8d 50 01             	lea    0x1(%eax),%edx
  101538:	89 15 80 f0 10 00    	mov    %edx,0x10f080
  10153e:	0f b6 80 80 ee 10 00 	movzbl 0x10ee80(%eax),%eax
  101545:	0f b6 c0             	movzbl %al,%eax
  101548:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (cons.rpos == CONSBUFSIZE) {
  10154b:	a1 80 f0 10 00       	mov    0x10f080,%eax
  101550:	3d 00 02 00 00       	cmp    $0x200,%eax
  101555:	75 0a                	jne    101561 <cons_getc+0x50>
            cons.rpos = 0;
  101557:	c7 05 80 f0 10 00 00 	movl   $0x0,0x10f080
  10155e:	00 00 00 
        }
        return c;
  101561:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101564:	eb 05                	jmp    10156b <cons_getc+0x5a>
    }
    return 0;
  101566:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10156b:	c9                   	leave  
  10156c:	c3                   	ret    

0010156d <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  10156d:	55                   	push   %ebp
  10156e:	89 e5                	mov    %esp,%ebp
  101570:	83 ec 14             	sub    $0x14,%esp
  101573:	8b 45 08             	mov    0x8(%ebp),%eax
  101576:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  10157a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  10157e:	66 a3 50 e5 10 00    	mov    %ax,0x10e550
    if (did_init) {
  101584:	a1 8c f0 10 00       	mov    0x10f08c,%eax
  101589:	85 c0                	test   %eax,%eax
  10158b:	74 36                	je     1015c3 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
  10158d:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101591:	0f b6 c0             	movzbl %al,%eax
  101594:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  10159a:	88 45 fd             	mov    %al,-0x3(%ebp)
  10159d:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  1015a1:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  1015a5:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
  1015a6:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  1015aa:	66 c1 e8 08          	shr    $0x8,%ax
  1015ae:	0f b6 c0             	movzbl %al,%eax
  1015b1:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
  1015b7:	88 45 f9             	mov    %al,-0x7(%ebp)
  1015ba:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  1015be:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  1015c2:	ee                   	out    %al,(%dx)
    }
}
  1015c3:	c9                   	leave  
  1015c4:	c3                   	ret    

001015c5 <pic_enable>:

void
pic_enable(unsigned int irq) {
  1015c5:	55                   	push   %ebp
  1015c6:	89 e5                	mov    %esp,%ebp
  1015c8:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  1015cb:	8b 45 08             	mov    0x8(%ebp),%eax
  1015ce:	ba 01 00 00 00       	mov    $0x1,%edx
  1015d3:	89 c1                	mov    %eax,%ecx
  1015d5:	d3 e2                	shl    %cl,%edx
  1015d7:	89 d0                	mov    %edx,%eax
  1015d9:	f7 d0                	not    %eax
  1015db:	89 c2                	mov    %eax,%edx
  1015dd:	0f b7 05 50 e5 10 00 	movzwl 0x10e550,%eax
  1015e4:	21 d0                	and    %edx,%eax
  1015e6:	0f b7 c0             	movzwl %ax,%eax
  1015e9:	89 04 24             	mov    %eax,(%esp)
  1015ec:	e8 7c ff ff ff       	call   10156d <pic_setmask>
}
  1015f1:	c9                   	leave  
  1015f2:	c3                   	ret    

001015f3 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  1015f3:	55                   	push   %ebp
  1015f4:	89 e5                	mov    %esp,%ebp
  1015f6:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
  1015f9:	c7 05 8c f0 10 00 01 	movl   $0x1,0x10f08c
  101600:	00 00 00 
  101603:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  101609:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
  10160d:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  101611:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101615:	ee                   	out    %al,(%dx)
  101616:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
  10161c:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
  101620:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101624:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101628:	ee                   	out    %al,(%dx)
  101629:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
  10162f:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
  101633:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  101637:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  10163b:	ee                   	out    %al,(%dx)
  10163c:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
  101642:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
  101646:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  10164a:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  10164e:	ee                   	out    %al,(%dx)
  10164f:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
  101655:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
  101659:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  10165d:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101661:	ee                   	out    %al,(%dx)
  101662:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
  101668:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
  10166c:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101670:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101674:	ee                   	out    %al,(%dx)
  101675:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
  10167b:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
  10167f:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  101683:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  101687:	ee                   	out    %al,(%dx)
  101688:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
  10168e:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
  101692:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  101696:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  10169a:	ee                   	out    %al,(%dx)
  10169b:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
  1016a1:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
  1016a5:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  1016a9:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  1016ad:	ee                   	out    %al,(%dx)
  1016ae:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
  1016b4:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
  1016b8:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  1016bc:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  1016c0:	ee                   	out    %al,(%dx)
  1016c1:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
  1016c7:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
  1016cb:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  1016cf:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  1016d3:	ee                   	out    %al,(%dx)
  1016d4:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
  1016da:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
  1016de:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  1016e2:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  1016e6:	ee                   	out    %al,(%dx)
  1016e7:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
  1016ed:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
  1016f1:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
  1016f5:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
  1016f9:	ee                   	out    %al,(%dx)
  1016fa:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
  101700:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
  101704:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
  101708:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
  10170c:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  10170d:	0f b7 05 50 e5 10 00 	movzwl 0x10e550,%eax
  101714:	66 83 f8 ff          	cmp    $0xffff,%ax
  101718:	74 12                	je     10172c <pic_init+0x139>
        pic_setmask(irq_mask);
  10171a:	0f b7 05 50 e5 10 00 	movzwl 0x10e550,%eax
  101721:	0f b7 c0             	movzwl %ax,%eax
  101724:	89 04 24             	mov    %eax,(%esp)
  101727:	e8 41 fe ff ff       	call   10156d <pic_setmask>
    }
}
  10172c:	c9                   	leave  
  10172d:	c3                   	ret    

0010172e <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  10172e:	55                   	push   %ebp
  10172f:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd));
}

static inline void
sti(void) {
    asm volatile ("sti");
  101731:	fb                   	sti    
    sti();
}
  101732:	5d                   	pop    %ebp
  101733:	c3                   	ret    

00101734 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  101734:	55                   	push   %ebp
  101735:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli");
  101737:	fa                   	cli    
    cli();
}
  101738:	5d                   	pop    %ebp
  101739:	c3                   	ret    

0010173a <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
  10173a:	55                   	push   %ebp
  10173b:	89 e5                	mov    %esp,%ebp
  10173d:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
  101740:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  101747:	00 
  101748:	c7 04 24 60 35 10 00 	movl   $0x103560,(%esp)
  10174f:	e8 08 eb ff ff       	call   10025c <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
  101754:	c9                   	leave  
  101755:	c3                   	ret    

00101756 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  101756:	55                   	push   %ebp
  101757:	89 e5                	mov    %esp,%ebp
      *     Can you see idt[256] in this file? Yes, it's IDT! you can use SETGATE macro to setup each item of IDT
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
}
  101759:	5d                   	pop    %ebp
  10175a:	c3                   	ret    

0010175b <trapname>:

static const char *
trapname(int trapno) {
  10175b:	55                   	push   %ebp
  10175c:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  10175e:	8b 45 08             	mov    0x8(%ebp),%eax
  101761:	83 f8 13             	cmp    $0x13,%eax
  101764:	77 0c                	ja     101772 <trapname+0x17>
        return excnames[trapno];
  101766:	8b 45 08             	mov    0x8(%ebp),%eax
  101769:	8b 04 85 c0 38 10 00 	mov    0x1038c0(,%eax,4),%eax
  101770:	eb 18                	jmp    10178a <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  101772:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  101776:	7e 0d                	jle    101785 <trapname+0x2a>
  101778:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  10177c:	7f 07                	jg     101785 <trapname+0x2a>
        return "Hardware Interrupt";
  10177e:	b8 6a 35 10 00       	mov    $0x10356a,%eax
  101783:	eb 05                	jmp    10178a <trapname+0x2f>
    }
    return "(unknown trap)";
  101785:	b8 7d 35 10 00       	mov    $0x10357d,%eax
}
  10178a:	5d                   	pop    %ebp
  10178b:	c3                   	ret    

0010178c <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  10178c:	55                   	push   %ebp
  10178d:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  10178f:	8b 45 08             	mov    0x8(%ebp),%eax
  101792:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101796:	66 83 f8 08          	cmp    $0x8,%ax
  10179a:	0f 94 c0             	sete   %al
  10179d:	0f b6 c0             	movzbl %al,%eax
}
  1017a0:	5d                   	pop    %ebp
  1017a1:	c3                   	ret    

001017a2 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  1017a2:	55                   	push   %ebp
  1017a3:	89 e5                	mov    %esp,%ebp
  1017a5:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  1017a8:	8b 45 08             	mov    0x8(%ebp),%eax
  1017ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  1017af:	c7 04 24 be 35 10 00 	movl   $0x1035be,(%esp)
  1017b6:	e8 a1 ea ff ff       	call   10025c <cprintf>
    print_regs(&tf->tf_regs);
  1017bb:	8b 45 08             	mov    0x8(%ebp),%eax
  1017be:	89 04 24             	mov    %eax,(%esp)
  1017c1:	e8 a1 01 00 00       	call   101967 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  1017c6:	8b 45 08             	mov    0x8(%ebp),%eax
  1017c9:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  1017cd:	0f b7 c0             	movzwl %ax,%eax
  1017d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1017d4:	c7 04 24 cf 35 10 00 	movl   $0x1035cf,(%esp)
  1017db:	e8 7c ea ff ff       	call   10025c <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  1017e0:	8b 45 08             	mov    0x8(%ebp),%eax
  1017e3:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  1017e7:	0f b7 c0             	movzwl %ax,%eax
  1017ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  1017ee:	c7 04 24 e2 35 10 00 	movl   $0x1035e2,(%esp)
  1017f5:	e8 62 ea ff ff       	call   10025c <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  1017fa:	8b 45 08             	mov    0x8(%ebp),%eax
  1017fd:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101801:	0f b7 c0             	movzwl %ax,%eax
  101804:	89 44 24 04          	mov    %eax,0x4(%esp)
  101808:	c7 04 24 f5 35 10 00 	movl   $0x1035f5,(%esp)
  10180f:	e8 48 ea ff ff       	call   10025c <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101814:	8b 45 08             	mov    0x8(%ebp),%eax
  101817:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  10181b:	0f b7 c0             	movzwl %ax,%eax
  10181e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101822:	c7 04 24 08 36 10 00 	movl   $0x103608,(%esp)
  101829:	e8 2e ea ff ff       	call   10025c <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  10182e:	8b 45 08             	mov    0x8(%ebp),%eax
  101831:	8b 40 30             	mov    0x30(%eax),%eax
  101834:	89 04 24             	mov    %eax,(%esp)
  101837:	e8 1f ff ff ff       	call   10175b <trapname>
  10183c:	8b 55 08             	mov    0x8(%ebp),%edx
  10183f:	8b 52 30             	mov    0x30(%edx),%edx
  101842:	89 44 24 08          	mov    %eax,0x8(%esp)
  101846:	89 54 24 04          	mov    %edx,0x4(%esp)
  10184a:	c7 04 24 1b 36 10 00 	movl   $0x10361b,(%esp)
  101851:	e8 06 ea ff ff       	call   10025c <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101856:	8b 45 08             	mov    0x8(%ebp),%eax
  101859:	8b 40 34             	mov    0x34(%eax),%eax
  10185c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101860:	c7 04 24 2d 36 10 00 	movl   $0x10362d,(%esp)
  101867:	e8 f0 e9 ff ff       	call   10025c <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  10186c:	8b 45 08             	mov    0x8(%ebp),%eax
  10186f:	8b 40 38             	mov    0x38(%eax),%eax
  101872:	89 44 24 04          	mov    %eax,0x4(%esp)
  101876:	c7 04 24 3c 36 10 00 	movl   $0x10363c,(%esp)
  10187d:	e8 da e9 ff ff       	call   10025c <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101882:	8b 45 08             	mov    0x8(%ebp),%eax
  101885:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101889:	0f b7 c0             	movzwl %ax,%eax
  10188c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101890:	c7 04 24 4b 36 10 00 	movl   $0x10364b,(%esp)
  101897:	e8 c0 e9 ff ff       	call   10025c <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  10189c:	8b 45 08             	mov    0x8(%ebp),%eax
  10189f:	8b 40 40             	mov    0x40(%eax),%eax
  1018a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1018a6:	c7 04 24 5e 36 10 00 	movl   $0x10365e,(%esp)
  1018ad:	e8 aa e9 ff ff       	call   10025c <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  1018b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  1018b9:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  1018c0:	eb 3e                	jmp    101900 <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  1018c2:	8b 45 08             	mov    0x8(%ebp),%eax
  1018c5:	8b 50 40             	mov    0x40(%eax),%edx
  1018c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1018cb:	21 d0                	and    %edx,%eax
  1018cd:	85 c0                	test   %eax,%eax
  1018cf:	74 28                	je     1018f9 <print_trapframe+0x157>
  1018d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1018d4:	8b 04 85 80 e5 10 00 	mov    0x10e580(,%eax,4),%eax
  1018db:	85 c0                	test   %eax,%eax
  1018dd:	74 1a                	je     1018f9 <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
  1018df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1018e2:	8b 04 85 80 e5 10 00 	mov    0x10e580(,%eax,4),%eax
  1018e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1018ed:	c7 04 24 6d 36 10 00 	movl   $0x10366d,(%esp)
  1018f4:	e8 63 e9 ff ff       	call   10025c <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  1018f9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  1018fd:	d1 65 f0             	shll   -0x10(%ebp)
  101900:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101903:	83 f8 17             	cmp    $0x17,%eax
  101906:	76 ba                	jbe    1018c2 <print_trapframe+0x120>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101908:	8b 45 08             	mov    0x8(%ebp),%eax
  10190b:	8b 40 40             	mov    0x40(%eax),%eax
  10190e:	25 00 30 00 00       	and    $0x3000,%eax
  101913:	c1 e8 0c             	shr    $0xc,%eax
  101916:	89 44 24 04          	mov    %eax,0x4(%esp)
  10191a:	c7 04 24 71 36 10 00 	movl   $0x103671,(%esp)
  101921:	e8 36 e9 ff ff       	call   10025c <cprintf>

    if (!trap_in_kernel(tf)) {
  101926:	8b 45 08             	mov    0x8(%ebp),%eax
  101929:	89 04 24             	mov    %eax,(%esp)
  10192c:	e8 5b fe ff ff       	call   10178c <trap_in_kernel>
  101931:	85 c0                	test   %eax,%eax
  101933:	75 30                	jne    101965 <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101935:	8b 45 08             	mov    0x8(%ebp),%eax
  101938:	8b 40 44             	mov    0x44(%eax),%eax
  10193b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10193f:	c7 04 24 7a 36 10 00 	movl   $0x10367a,(%esp)
  101946:	e8 11 e9 ff ff       	call   10025c <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  10194b:	8b 45 08             	mov    0x8(%ebp),%eax
  10194e:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101952:	0f b7 c0             	movzwl %ax,%eax
  101955:	89 44 24 04          	mov    %eax,0x4(%esp)
  101959:	c7 04 24 89 36 10 00 	movl   $0x103689,(%esp)
  101960:	e8 f7 e8 ff ff       	call   10025c <cprintf>
    }
}
  101965:	c9                   	leave  
  101966:	c3                   	ret    

00101967 <print_regs>:

void
print_regs(struct pushregs *regs) {
  101967:	55                   	push   %ebp
  101968:	89 e5                	mov    %esp,%ebp
  10196a:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  10196d:	8b 45 08             	mov    0x8(%ebp),%eax
  101970:	8b 00                	mov    (%eax),%eax
  101972:	89 44 24 04          	mov    %eax,0x4(%esp)
  101976:	c7 04 24 9c 36 10 00 	movl   $0x10369c,(%esp)
  10197d:	e8 da e8 ff ff       	call   10025c <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101982:	8b 45 08             	mov    0x8(%ebp),%eax
  101985:	8b 40 04             	mov    0x4(%eax),%eax
  101988:	89 44 24 04          	mov    %eax,0x4(%esp)
  10198c:	c7 04 24 ab 36 10 00 	movl   $0x1036ab,(%esp)
  101993:	e8 c4 e8 ff ff       	call   10025c <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101998:	8b 45 08             	mov    0x8(%ebp),%eax
  10199b:	8b 40 08             	mov    0x8(%eax),%eax
  10199e:	89 44 24 04          	mov    %eax,0x4(%esp)
  1019a2:	c7 04 24 ba 36 10 00 	movl   $0x1036ba,(%esp)
  1019a9:	e8 ae e8 ff ff       	call   10025c <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  1019ae:	8b 45 08             	mov    0x8(%ebp),%eax
  1019b1:	8b 40 0c             	mov    0xc(%eax),%eax
  1019b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1019b8:	c7 04 24 c9 36 10 00 	movl   $0x1036c9,(%esp)
  1019bf:	e8 98 e8 ff ff       	call   10025c <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  1019c4:	8b 45 08             	mov    0x8(%ebp),%eax
  1019c7:	8b 40 10             	mov    0x10(%eax),%eax
  1019ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  1019ce:	c7 04 24 d8 36 10 00 	movl   $0x1036d8,(%esp)
  1019d5:	e8 82 e8 ff ff       	call   10025c <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  1019da:	8b 45 08             	mov    0x8(%ebp),%eax
  1019dd:	8b 40 14             	mov    0x14(%eax),%eax
  1019e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1019e4:	c7 04 24 e7 36 10 00 	movl   $0x1036e7,(%esp)
  1019eb:	e8 6c e8 ff ff       	call   10025c <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  1019f0:	8b 45 08             	mov    0x8(%ebp),%eax
  1019f3:	8b 40 18             	mov    0x18(%eax),%eax
  1019f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1019fa:	c7 04 24 f6 36 10 00 	movl   $0x1036f6,(%esp)
  101a01:	e8 56 e8 ff ff       	call   10025c <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101a06:	8b 45 08             	mov    0x8(%ebp),%eax
  101a09:	8b 40 1c             	mov    0x1c(%eax),%eax
  101a0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a10:	c7 04 24 05 37 10 00 	movl   $0x103705,(%esp)
  101a17:	e8 40 e8 ff ff       	call   10025c <cprintf>
}
  101a1c:	c9                   	leave  
  101a1d:	c3                   	ret    

00101a1e <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101a1e:	55                   	push   %ebp
  101a1f:	89 e5                	mov    %esp,%ebp
  101a21:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
  101a24:	8b 45 08             	mov    0x8(%ebp),%eax
  101a27:	8b 40 30             	mov    0x30(%eax),%eax
  101a2a:	83 f8 2f             	cmp    $0x2f,%eax
  101a2d:	77 1e                	ja     101a4d <trap_dispatch+0x2f>
  101a2f:	83 f8 2e             	cmp    $0x2e,%eax
  101a32:	0f 83 bf 00 00 00    	jae    101af7 <trap_dispatch+0xd9>
  101a38:	83 f8 21             	cmp    $0x21,%eax
  101a3b:	74 40                	je     101a7d <trap_dispatch+0x5f>
  101a3d:	83 f8 24             	cmp    $0x24,%eax
  101a40:	74 15                	je     101a57 <trap_dispatch+0x39>
  101a42:	83 f8 20             	cmp    $0x20,%eax
  101a45:	0f 84 af 00 00 00    	je     101afa <trap_dispatch+0xdc>
  101a4b:	eb 72                	jmp    101abf <trap_dispatch+0xa1>
  101a4d:	83 e8 78             	sub    $0x78,%eax
  101a50:	83 f8 01             	cmp    $0x1,%eax
  101a53:	77 6a                	ja     101abf <trap_dispatch+0xa1>
  101a55:	eb 4c                	jmp    101aa3 <trap_dispatch+0x85>
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        break;
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101a57:	e8 b5 fa ff ff       	call   101511 <cons_getc>
  101a5c:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101a5f:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101a63:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101a67:	89 54 24 08          	mov    %edx,0x8(%esp)
  101a6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a6f:	c7 04 24 14 37 10 00 	movl   $0x103714,(%esp)
  101a76:	e8 e1 e7 ff ff       	call   10025c <cprintf>
        break;
  101a7b:	eb 7e                	jmp    101afb <trap_dispatch+0xdd>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101a7d:	e8 8f fa ff ff       	call   101511 <cons_getc>
  101a82:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101a85:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101a89:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101a8d:	89 54 24 08          	mov    %edx,0x8(%esp)
  101a91:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a95:	c7 04 24 26 37 10 00 	movl   $0x103726,(%esp)
  101a9c:	e8 bb e7 ff ff       	call   10025c <cprintf>
        break;
  101aa1:	eb 58                	jmp    101afb <trap_dispatch+0xdd>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
  101aa3:	c7 44 24 08 35 37 10 	movl   $0x103735,0x8(%esp)
  101aaa:	00 
  101aab:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  101ab2:	00 
  101ab3:	c7 04 24 45 37 10 00 	movl   $0x103745,(%esp)
  101aba:	e8 f4 e8 ff ff       	call   1003b3 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101abf:	8b 45 08             	mov    0x8(%ebp),%eax
  101ac2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101ac6:	0f b7 c0             	movzwl %ax,%eax
  101ac9:	83 e0 03             	and    $0x3,%eax
  101acc:	85 c0                	test   %eax,%eax
  101ace:	75 2b                	jne    101afb <trap_dispatch+0xdd>
            print_trapframe(tf);
  101ad0:	8b 45 08             	mov    0x8(%ebp),%eax
  101ad3:	89 04 24             	mov    %eax,(%esp)
  101ad6:	e8 c7 fc ff ff       	call   1017a2 <print_trapframe>
            panic("unexpected trap in kernel.\n");
  101adb:	c7 44 24 08 56 37 10 	movl   $0x103756,0x8(%esp)
  101ae2:	00 
  101ae3:	c7 44 24 04 ac 00 00 	movl   $0xac,0x4(%esp)
  101aea:	00 
  101aeb:	c7 04 24 45 37 10 00 	movl   $0x103745,(%esp)
  101af2:	e8 bc e8 ff ff       	call   1003b3 <__panic>
        break;
  101af7:	90                   	nop
  101af8:	eb 01                	jmp    101afb <trap_dispatch+0xdd>
        break;
  101afa:	90                   	nop
        }
    }
}
  101afb:	c9                   	leave  
  101afc:	c3                   	ret    

00101afd <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101afd:	55                   	push   %ebp
  101afe:	89 e5                	mov    %esp,%ebp
  101b00:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101b03:	8b 45 08             	mov    0x8(%ebp),%eax
  101b06:	89 04 24             	mov    %eax,(%esp)
  101b09:	e8 10 ff ff ff       	call   101a1e <trap_dispatch>
}
  101b0e:	c9                   	leave  
  101b0f:	c3                   	ret    

00101b10 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101b10:	6a 00                	push   $0x0
  pushl $0
  101b12:	6a 00                	push   $0x0
  jmp __alltraps
  101b14:	e9 69 0a 00 00       	jmp    102582 <__alltraps>

00101b19 <vector1>:
.globl vector1
vector1:
  pushl $0
  101b19:	6a 00                	push   $0x0
  pushl $1
  101b1b:	6a 01                	push   $0x1
  jmp __alltraps
  101b1d:	e9 60 0a 00 00       	jmp    102582 <__alltraps>

00101b22 <vector2>:
.globl vector2
vector2:
  pushl $0
  101b22:	6a 00                	push   $0x0
  pushl $2
  101b24:	6a 02                	push   $0x2
  jmp __alltraps
  101b26:	e9 57 0a 00 00       	jmp    102582 <__alltraps>

00101b2b <vector3>:
.globl vector3
vector3:
  pushl $0
  101b2b:	6a 00                	push   $0x0
  pushl $3
  101b2d:	6a 03                	push   $0x3
  jmp __alltraps
  101b2f:	e9 4e 0a 00 00       	jmp    102582 <__alltraps>

00101b34 <vector4>:
.globl vector4
vector4:
  pushl $0
  101b34:	6a 00                	push   $0x0
  pushl $4
  101b36:	6a 04                	push   $0x4
  jmp __alltraps
  101b38:	e9 45 0a 00 00       	jmp    102582 <__alltraps>

00101b3d <vector5>:
.globl vector5
vector5:
  pushl $0
  101b3d:	6a 00                	push   $0x0
  pushl $5
  101b3f:	6a 05                	push   $0x5
  jmp __alltraps
  101b41:	e9 3c 0a 00 00       	jmp    102582 <__alltraps>

00101b46 <vector6>:
.globl vector6
vector6:
  pushl $0
  101b46:	6a 00                	push   $0x0
  pushl $6
  101b48:	6a 06                	push   $0x6
  jmp __alltraps
  101b4a:	e9 33 0a 00 00       	jmp    102582 <__alltraps>

00101b4f <vector7>:
.globl vector7
vector7:
  pushl $0
  101b4f:	6a 00                	push   $0x0
  pushl $7
  101b51:	6a 07                	push   $0x7
  jmp __alltraps
  101b53:	e9 2a 0a 00 00       	jmp    102582 <__alltraps>

00101b58 <vector8>:
.globl vector8
vector8:
  pushl $8
  101b58:	6a 08                	push   $0x8
  jmp __alltraps
  101b5a:	e9 23 0a 00 00       	jmp    102582 <__alltraps>

00101b5f <vector9>:
.globl vector9
vector9:
  pushl $0
  101b5f:	6a 00                	push   $0x0
  pushl $9
  101b61:	6a 09                	push   $0x9
  jmp __alltraps
  101b63:	e9 1a 0a 00 00       	jmp    102582 <__alltraps>

00101b68 <vector10>:
.globl vector10
vector10:
  pushl $10
  101b68:	6a 0a                	push   $0xa
  jmp __alltraps
  101b6a:	e9 13 0a 00 00       	jmp    102582 <__alltraps>

00101b6f <vector11>:
.globl vector11
vector11:
  pushl $11
  101b6f:	6a 0b                	push   $0xb
  jmp __alltraps
  101b71:	e9 0c 0a 00 00       	jmp    102582 <__alltraps>

00101b76 <vector12>:
.globl vector12
vector12:
  pushl $12
  101b76:	6a 0c                	push   $0xc
  jmp __alltraps
  101b78:	e9 05 0a 00 00       	jmp    102582 <__alltraps>

00101b7d <vector13>:
.globl vector13
vector13:
  pushl $13
  101b7d:	6a 0d                	push   $0xd
  jmp __alltraps
  101b7f:	e9 fe 09 00 00       	jmp    102582 <__alltraps>

00101b84 <vector14>:
.globl vector14
vector14:
  pushl $14
  101b84:	6a 0e                	push   $0xe
  jmp __alltraps
  101b86:	e9 f7 09 00 00       	jmp    102582 <__alltraps>

00101b8b <vector15>:
.globl vector15
vector15:
  pushl $0
  101b8b:	6a 00                	push   $0x0
  pushl $15
  101b8d:	6a 0f                	push   $0xf
  jmp __alltraps
  101b8f:	e9 ee 09 00 00       	jmp    102582 <__alltraps>

00101b94 <vector16>:
.globl vector16
vector16:
  pushl $0
  101b94:	6a 00                	push   $0x0
  pushl $16
  101b96:	6a 10                	push   $0x10
  jmp __alltraps
  101b98:	e9 e5 09 00 00       	jmp    102582 <__alltraps>

00101b9d <vector17>:
.globl vector17
vector17:
  pushl $17
  101b9d:	6a 11                	push   $0x11
  jmp __alltraps
  101b9f:	e9 de 09 00 00       	jmp    102582 <__alltraps>

00101ba4 <vector18>:
.globl vector18
vector18:
  pushl $0
  101ba4:	6a 00                	push   $0x0
  pushl $18
  101ba6:	6a 12                	push   $0x12
  jmp __alltraps
  101ba8:	e9 d5 09 00 00       	jmp    102582 <__alltraps>

00101bad <vector19>:
.globl vector19
vector19:
  pushl $0
  101bad:	6a 00                	push   $0x0
  pushl $19
  101baf:	6a 13                	push   $0x13
  jmp __alltraps
  101bb1:	e9 cc 09 00 00       	jmp    102582 <__alltraps>

00101bb6 <vector20>:
.globl vector20
vector20:
  pushl $0
  101bb6:	6a 00                	push   $0x0
  pushl $20
  101bb8:	6a 14                	push   $0x14
  jmp __alltraps
  101bba:	e9 c3 09 00 00       	jmp    102582 <__alltraps>

00101bbf <vector21>:
.globl vector21
vector21:
  pushl $0
  101bbf:	6a 00                	push   $0x0
  pushl $21
  101bc1:	6a 15                	push   $0x15
  jmp __alltraps
  101bc3:	e9 ba 09 00 00       	jmp    102582 <__alltraps>

00101bc8 <vector22>:
.globl vector22
vector22:
  pushl $0
  101bc8:	6a 00                	push   $0x0
  pushl $22
  101bca:	6a 16                	push   $0x16
  jmp __alltraps
  101bcc:	e9 b1 09 00 00       	jmp    102582 <__alltraps>

00101bd1 <vector23>:
.globl vector23
vector23:
  pushl $0
  101bd1:	6a 00                	push   $0x0
  pushl $23
  101bd3:	6a 17                	push   $0x17
  jmp __alltraps
  101bd5:	e9 a8 09 00 00       	jmp    102582 <__alltraps>

00101bda <vector24>:
.globl vector24
vector24:
  pushl $0
  101bda:	6a 00                	push   $0x0
  pushl $24
  101bdc:	6a 18                	push   $0x18
  jmp __alltraps
  101bde:	e9 9f 09 00 00       	jmp    102582 <__alltraps>

00101be3 <vector25>:
.globl vector25
vector25:
  pushl $0
  101be3:	6a 00                	push   $0x0
  pushl $25
  101be5:	6a 19                	push   $0x19
  jmp __alltraps
  101be7:	e9 96 09 00 00       	jmp    102582 <__alltraps>

00101bec <vector26>:
.globl vector26
vector26:
  pushl $0
  101bec:	6a 00                	push   $0x0
  pushl $26
  101bee:	6a 1a                	push   $0x1a
  jmp __alltraps
  101bf0:	e9 8d 09 00 00       	jmp    102582 <__alltraps>

00101bf5 <vector27>:
.globl vector27
vector27:
  pushl $0
  101bf5:	6a 00                	push   $0x0
  pushl $27
  101bf7:	6a 1b                	push   $0x1b
  jmp __alltraps
  101bf9:	e9 84 09 00 00       	jmp    102582 <__alltraps>

00101bfe <vector28>:
.globl vector28
vector28:
  pushl $0
  101bfe:	6a 00                	push   $0x0
  pushl $28
  101c00:	6a 1c                	push   $0x1c
  jmp __alltraps
  101c02:	e9 7b 09 00 00       	jmp    102582 <__alltraps>

00101c07 <vector29>:
.globl vector29
vector29:
  pushl $0
  101c07:	6a 00                	push   $0x0
  pushl $29
  101c09:	6a 1d                	push   $0x1d
  jmp __alltraps
  101c0b:	e9 72 09 00 00       	jmp    102582 <__alltraps>

00101c10 <vector30>:
.globl vector30
vector30:
  pushl $0
  101c10:	6a 00                	push   $0x0
  pushl $30
  101c12:	6a 1e                	push   $0x1e
  jmp __alltraps
  101c14:	e9 69 09 00 00       	jmp    102582 <__alltraps>

00101c19 <vector31>:
.globl vector31
vector31:
  pushl $0
  101c19:	6a 00                	push   $0x0
  pushl $31
  101c1b:	6a 1f                	push   $0x1f
  jmp __alltraps
  101c1d:	e9 60 09 00 00       	jmp    102582 <__alltraps>

00101c22 <vector32>:
.globl vector32
vector32:
  pushl $0
  101c22:	6a 00                	push   $0x0
  pushl $32
  101c24:	6a 20                	push   $0x20
  jmp __alltraps
  101c26:	e9 57 09 00 00       	jmp    102582 <__alltraps>

00101c2b <vector33>:
.globl vector33
vector33:
  pushl $0
  101c2b:	6a 00                	push   $0x0
  pushl $33
  101c2d:	6a 21                	push   $0x21
  jmp __alltraps
  101c2f:	e9 4e 09 00 00       	jmp    102582 <__alltraps>

00101c34 <vector34>:
.globl vector34
vector34:
  pushl $0
  101c34:	6a 00                	push   $0x0
  pushl $34
  101c36:	6a 22                	push   $0x22
  jmp __alltraps
  101c38:	e9 45 09 00 00       	jmp    102582 <__alltraps>

00101c3d <vector35>:
.globl vector35
vector35:
  pushl $0
  101c3d:	6a 00                	push   $0x0
  pushl $35
  101c3f:	6a 23                	push   $0x23
  jmp __alltraps
  101c41:	e9 3c 09 00 00       	jmp    102582 <__alltraps>

00101c46 <vector36>:
.globl vector36
vector36:
  pushl $0
  101c46:	6a 00                	push   $0x0
  pushl $36
  101c48:	6a 24                	push   $0x24
  jmp __alltraps
  101c4a:	e9 33 09 00 00       	jmp    102582 <__alltraps>

00101c4f <vector37>:
.globl vector37
vector37:
  pushl $0
  101c4f:	6a 00                	push   $0x0
  pushl $37
  101c51:	6a 25                	push   $0x25
  jmp __alltraps
  101c53:	e9 2a 09 00 00       	jmp    102582 <__alltraps>

00101c58 <vector38>:
.globl vector38
vector38:
  pushl $0
  101c58:	6a 00                	push   $0x0
  pushl $38
  101c5a:	6a 26                	push   $0x26
  jmp __alltraps
  101c5c:	e9 21 09 00 00       	jmp    102582 <__alltraps>

00101c61 <vector39>:
.globl vector39
vector39:
  pushl $0
  101c61:	6a 00                	push   $0x0
  pushl $39
  101c63:	6a 27                	push   $0x27
  jmp __alltraps
  101c65:	e9 18 09 00 00       	jmp    102582 <__alltraps>

00101c6a <vector40>:
.globl vector40
vector40:
  pushl $0
  101c6a:	6a 00                	push   $0x0
  pushl $40
  101c6c:	6a 28                	push   $0x28
  jmp __alltraps
  101c6e:	e9 0f 09 00 00       	jmp    102582 <__alltraps>

00101c73 <vector41>:
.globl vector41
vector41:
  pushl $0
  101c73:	6a 00                	push   $0x0
  pushl $41
  101c75:	6a 29                	push   $0x29
  jmp __alltraps
  101c77:	e9 06 09 00 00       	jmp    102582 <__alltraps>

00101c7c <vector42>:
.globl vector42
vector42:
  pushl $0
  101c7c:	6a 00                	push   $0x0
  pushl $42
  101c7e:	6a 2a                	push   $0x2a
  jmp __alltraps
  101c80:	e9 fd 08 00 00       	jmp    102582 <__alltraps>

00101c85 <vector43>:
.globl vector43
vector43:
  pushl $0
  101c85:	6a 00                	push   $0x0
  pushl $43
  101c87:	6a 2b                	push   $0x2b
  jmp __alltraps
  101c89:	e9 f4 08 00 00       	jmp    102582 <__alltraps>

00101c8e <vector44>:
.globl vector44
vector44:
  pushl $0
  101c8e:	6a 00                	push   $0x0
  pushl $44
  101c90:	6a 2c                	push   $0x2c
  jmp __alltraps
  101c92:	e9 eb 08 00 00       	jmp    102582 <__alltraps>

00101c97 <vector45>:
.globl vector45
vector45:
  pushl $0
  101c97:	6a 00                	push   $0x0
  pushl $45
  101c99:	6a 2d                	push   $0x2d
  jmp __alltraps
  101c9b:	e9 e2 08 00 00       	jmp    102582 <__alltraps>

00101ca0 <vector46>:
.globl vector46
vector46:
  pushl $0
  101ca0:	6a 00                	push   $0x0
  pushl $46
  101ca2:	6a 2e                	push   $0x2e
  jmp __alltraps
  101ca4:	e9 d9 08 00 00       	jmp    102582 <__alltraps>

00101ca9 <vector47>:
.globl vector47
vector47:
  pushl $0
  101ca9:	6a 00                	push   $0x0
  pushl $47
  101cab:	6a 2f                	push   $0x2f
  jmp __alltraps
  101cad:	e9 d0 08 00 00       	jmp    102582 <__alltraps>

00101cb2 <vector48>:
.globl vector48
vector48:
  pushl $0
  101cb2:	6a 00                	push   $0x0
  pushl $48
  101cb4:	6a 30                	push   $0x30
  jmp __alltraps
  101cb6:	e9 c7 08 00 00       	jmp    102582 <__alltraps>

00101cbb <vector49>:
.globl vector49
vector49:
  pushl $0
  101cbb:	6a 00                	push   $0x0
  pushl $49
  101cbd:	6a 31                	push   $0x31
  jmp __alltraps
  101cbf:	e9 be 08 00 00       	jmp    102582 <__alltraps>

00101cc4 <vector50>:
.globl vector50
vector50:
  pushl $0
  101cc4:	6a 00                	push   $0x0
  pushl $50
  101cc6:	6a 32                	push   $0x32
  jmp __alltraps
  101cc8:	e9 b5 08 00 00       	jmp    102582 <__alltraps>

00101ccd <vector51>:
.globl vector51
vector51:
  pushl $0
  101ccd:	6a 00                	push   $0x0
  pushl $51
  101ccf:	6a 33                	push   $0x33
  jmp __alltraps
  101cd1:	e9 ac 08 00 00       	jmp    102582 <__alltraps>

00101cd6 <vector52>:
.globl vector52
vector52:
  pushl $0
  101cd6:	6a 00                	push   $0x0
  pushl $52
  101cd8:	6a 34                	push   $0x34
  jmp __alltraps
  101cda:	e9 a3 08 00 00       	jmp    102582 <__alltraps>

00101cdf <vector53>:
.globl vector53
vector53:
  pushl $0
  101cdf:	6a 00                	push   $0x0
  pushl $53
  101ce1:	6a 35                	push   $0x35
  jmp __alltraps
  101ce3:	e9 9a 08 00 00       	jmp    102582 <__alltraps>

00101ce8 <vector54>:
.globl vector54
vector54:
  pushl $0
  101ce8:	6a 00                	push   $0x0
  pushl $54
  101cea:	6a 36                	push   $0x36
  jmp __alltraps
  101cec:	e9 91 08 00 00       	jmp    102582 <__alltraps>

00101cf1 <vector55>:
.globl vector55
vector55:
  pushl $0
  101cf1:	6a 00                	push   $0x0
  pushl $55
  101cf3:	6a 37                	push   $0x37
  jmp __alltraps
  101cf5:	e9 88 08 00 00       	jmp    102582 <__alltraps>

00101cfa <vector56>:
.globl vector56
vector56:
  pushl $0
  101cfa:	6a 00                	push   $0x0
  pushl $56
  101cfc:	6a 38                	push   $0x38
  jmp __alltraps
  101cfe:	e9 7f 08 00 00       	jmp    102582 <__alltraps>

00101d03 <vector57>:
.globl vector57
vector57:
  pushl $0
  101d03:	6a 00                	push   $0x0
  pushl $57
  101d05:	6a 39                	push   $0x39
  jmp __alltraps
  101d07:	e9 76 08 00 00       	jmp    102582 <__alltraps>

00101d0c <vector58>:
.globl vector58
vector58:
  pushl $0
  101d0c:	6a 00                	push   $0x0
  pushl $58
  101d0e:	6a 3a                	push   $0x3a
  jmp __alltraps
  101d10:	e9 6d 08 00 00       	jmp    102582 <__alltraps>

00101d15 <vector59>:
.globl vector59
vector59:
  pushl $0
  101d15:	6a 00                	push   $0x0
  pushl $59
  101d17:	6a 3b                	push   $0x3b
  jmp __alltraps
  101d19:	e9 64 08 00 00       	jmp    102582 <__alltraps>

00101d1e <vector60>:
.globl vector60
vector60:
  pushl $0
  101d1e:	6a 00                	push   $0x0
  pushl $60
  101d20:	6a 3c                	push   $0x3c
  jmp __alltraps
  101d22:	e9 5b 08 00 00       	jmp    102582 <__alltraps>

00101d27 <vector61>:
.globl vector61
vector61:
  pushl $0
  101d27:	6a 00                	push   $0x0
  pushl $61
  101d29:	6a 3d                	push   $0x3d
  jmp __alltraps
  101d2b:	e9 52 08 00 00       	jmp    102582 <__alltraps>

00101d30 <vector62>:
.globl vector62
vector62:
  pushl $0
  101d30:	6a 00                	push   $0x0
  pushl $62
  101d32:	6a 3e                	push   $0x3e
  jmp __alltraps
  101d34:	e9 49 08 00 00       	jmp    102582 <__alltraps>

00101d39 <vector63>:
.globl vector63
vector63:
  pushl $0
  101d39:	6a 00                	push   $0x0
  pushl $63
  101d3b:	6a 3f                	push   $0x3f
  jmp __alltraps
  101d3d:	e9 40 08 00 00       	jmp    102582 <__alltraps>

00101d42 <vector64>:
.globl vector64
vector64:
  pushl $0
  101d42:	6a 00                	push   $0x0
  pushl $64
  101d44:	6a 40                	push   $0x40
  jmp __alltraps
  101d46:	e9 37 08 00 00       	jmp    102582 <__alltraps>

00101d4b <vector65>:
.globl vector65
vector65:
  pushl $0
  101d4b:	6a 00                	push   $0x0
  pushl $65
  101d4d:	6a 41                	push   $0x41
  jmp __alltraps
  101d4f:	e9 2e 08 00 00       	jmp    102582 <__alltraps>

00101d54 <vector66>:
.globl vector66
vector66:
  pushl $0
  101d54:	6a 00                	push   $0x0
  pushl $66
  101d56:	6a 42                	push   $0x42
  jmp __alltraps
  101d58:	e9 25 08 00 00       	jmp    102582 <__alltraps>

00101d5d <vector67>:
.globl vector67
vector67:
  pushl $0
  101d5d:	6a 00                	push   $0x0
  pushl $67
  101d5f:	6a 43                	push   $0x43
  jmp __alltraps
  101d61:	e9 1c 08 00 00       	jmp    102582 <__alltraps>

00101d66 <vector68>:
.globl vector68
vector68:
  pushl $0
  101d66:	6a 00                	push   $0x0
  pushl $68
  101d68:	6a 44                	push   $0x44
  jmp __alltraps
  101d6a:	e9 13 08 00 00       	jmp    102582 <__alltraps>

00101d6f <vector69>:
.globl vector69
vector69:
  pushl $0
  101d6f:	6a 00                	push   $0x0
  pushl $69
  101d71:	6a 45                	push   $0x45
  jmp __alltraps
  101d73:	e9 0a 08 00 00       	jmp    102582 <__alltraps>

00101d78 <vector70>:
.globl vector70
vector70:
  pushl $0
  101d78:	6a 00                	push   $0x0
  pushl $70
  101d7a:	6a 46                	push   $0x46
  jmp __alltraps
  101d7c:	e9 01 08 00 00       	jmp    102582 <__alltraps>

00101d81 <vector71>:
.globl vector71
vector71:
  pushl $0
  101d81:	6a 00                	push   $0x0
  pushl $71
  101d83:	6a 47                	push   $0x47
  jmp __alltraps
  101d85:	e9 f8 07 00 00       	jmp    102582 <__alltraps>

00101d8a <vector72>:
.globl vector72
vector72:
  pushl $0
  101d8a:	6a 00                	push   $0x0
  pushl $72
  101d8c:	6a 48                	push   $0x48
  jmp __alltraps
  101d8e:	e9 ef 07 00 00       	jmp    102582 <__alltraps>

00101d93 <vector73>:
.globl vector73
vector73:
  pushl $0
  101d93:	6a 00                	push   $0x0
  pushl $73
  101d95:	6a 49                	push   $0x49
  jmp __alltraps
  101d97:	e9 e6 07 00 00       	jmp    102582 <__alltraps>

00101d9c <vector74>:
.globl vector74
vector74:
  pushl $0
  101d9c:	6a 00                	push   $0x0
  pushl $74
  101d9e:	6a 4a                	push   $0x4a
  jmp __alltraps
  101da0:	e9 dd 07 00 00       	jmp    102582 <__alltraps>

00101da5 <vector75>:
.globl vector75
vector75:
  pushl $0
  101da5:	6a 00                	push   $0x0
  pushl $75
  101da7:	6a 4b                	push   $0x4b
  jmp __alltraps
  101da9:	e9 d4 07 00 00       	jmp    102582 <__alltraps>

00101dae <vector76>:
.globl vector76
vector76:
  pushl $0
  101dae:	6a 00                	push   $0x0
  pushl $76
  101db0:	6a 4c                	push   $0x4c
  jmp __alltraps
  101db2:	e9 cb 07 00 00       	jmp    102582 <__alltraps>

00101db7 <vector77>:
.globl vector77
vector77:
  pushl $0
  101db7:	6a 00                	push   $0x0
  pushl $77
  101db9:	6a 4d                	push   $0x4d
  jmp __alltraps
  101dbb:	e9 c2 07 00 00       	jmp    102582 <__alltraps>

00101dc0 <vector78>:
.globl vector78
vector78:
  pushl $0
  101dc0:	6a 00                	push   $0x0
  pushl $78
  101dc2:	6a 4e                	push   $0x4e
  jmp __alltraps
  101dc4:	e9 b9 07 00 00       	jmp    102582 <__alltraps>

00101dc9 <vector79>:
.globl vector79
vector79:
  pushl $0
  101dc9:	6a 00                	push   $0x0
  pushl $79
  101dcb:	6a 4f                	push   $0x4f
  jmp __alltraps
  101dcd:	e9 b0 07 00 00       	jmp    102582 <__alltraps>

00101dd2 <vector80>:
.globl vector80
vector80:
  pushl $0
  101dd2:	6a 00                	push   $0x0
  pushl $80
  101dd4:	6a 50                	push   $0x50
  jmp __alltraps
  101dd6:	e9 a7 07 00 00       	jmp    102582 <__alltraps>

00101ddb <vector81>:
.globl vector81
vector81:
  pushl $0
  101ddb:	6a 00                	push   $0x0
  pushl $81
  101ddd:	6a 51                	push   $0x51
  jmp __alltraps
  101ddf:	e9 9e 07 00 00       	jmp    102582 <__alltraps>

00101de4 <vector82>:
.globl vector82
vector82:
  pushl $0
  101de4:	6a 00                	push   $0x0
  pushl $82
  101de6:	6a 52                	push   $0x52
  jmp __alltraps
  101de8:	e9 95 07 00 00       	jmp    102582 <__alltraps>

00101ded <vector83>:
.globl vector83
vector83:
  pushl $0
  101ded:	6a 00                	push   $0x0
  pushl $83
  101def:	6a 53                	push   $0x53
  jmp __alltraps
  101df1:	e9 8c 07 00 00       	jmp    102582 <__alltraps>

00101df6 <vector84>:
.globl vector84
vector84:
  pushl $0
  101df6:	6a 00                	push   $0x0
  pushl $84
  101df8:	6a 54                	push   $0x54
  jmp __alltraps
  101dfa:	e9 83 07 00 00       	jmp    102582 <__alltraps>

00101dff <vector85>:
.globl vector85
vector85:
  pushl $0
  101dff:	6a 00                	push   $0x0
  pushl $85
  101e01:	6a 55                	push   $0x55
  jmp __alltraps
  101e03:	e9 7a 07 00 00       	jmp    102582 <__alltraps>

00101e08 <vector86>:
.globl vector86
vector86:
  pushl $0
  101e08:	6a 00                	push   $0x0
  pushl $86
  101e0a:	6a 56                	push   $0x56
  jmp __alltraps
  101e0c:	e9 71 07 00 00       	jmp    102582 <__alltraps>

00101e11 <vector87>:
.globl vector87
vector87:
  pushl $0
  101e11:	6a 00                	push   $0x0
  pushl $87
  101e13:	6a 57                	push   $0x57
  jmp __alltraps
  101e15:	e9 68 07 00 00       	jmp    102582 <__alltraps>

00101e1a <vector88>:
.globl vector88
vector88:
  pushl $0
  101e1a:	6a 00                	push   $0x0
  pushl $88
  101e1c:	6a 58                	push   $0x58
  jmp __alltraps
  101e1e:	e9 5f 07 00 00       	jmp    102582 <__alltraps>

00101e23 <vector89>:
.globl vector89
vector89:
  pushl $0
  101e23:	6a 00                	push   $0x0
  pushl $89
  101e25:	6a 59                	push   $0x59
  jmp __alltraps
  101e27:	e9 56 07 00 00       	jmp    102582 <__alltraps>

00101e2c <vector90>:
.globl vector90
vector90:
  pushl $0
  101e2c:	6a 00                	push   $0x0
  pushl $90
  101e2e:	6a 5a                	push   $0x5a
  jmp __alltraps
  101e30:	e9 4d 07 00 00       	jmp    102582 <__alltraps>

00101e35 <vector91>:
.globl vector91
vector91:
  pushl $0
  101e35:	6a 00                	push   $0x0
  pushl $91
  101e37:	6a 5b                	push   $0x5b
  jmp __alltraps
  101e39:	e9 44 07 00 00       	jmp    102582 <__alltraps>

00101e3e <vector92>:
.globl vector92
vector92:
  pushl $0
  101e3e:	6a 00                	push   $0x0
  pushl $92
  101e40:	6a 5c                	push   $0x5c
  jmp __alltraps
  101e42:	e9 3b 07 00 00       	jmp    102582 <__alltraps>

00101e47 <vector93>:
.globl vector93
vector93:
  pushl $0
  101e47:	6a 00                	push   $0x0
  pushl $93
  101e49:	6a 5d                	push   $0x5d
  jmp __alltraps
  101e4b:	e9 32 07 00 00       	jmp    102582 <__alltraps>

00101e50 <vector94>:
.globl vector94
vector94:
  pushl $0
  101e50:	6a 00                	push   $0x0
  pushl $94
  101e52:	6a 5e                	push   $0x5e
  jmp __alltraps
  101e54:	e9 29 07 00 00       	jmp    102582 <__alltraps>

00101e59 <vector95>:
.globl vector95
vector95:
  pushl $0
  101e59:	6a 00                	push   $0x0
  pushl $95
  101e5b:	6a 5f                	push   $0x5f
  jmp __alltraps
  101e5d:	e9 20 07 00 00       	jmp    102582 <__alltraps>

00101e62 <vector96>:
.globl vector96
vector96:
  pushl $0
  101e62:	6a 00                	push   $0x0
  pushl $96
  101e64:	6a 60                	push   $0x60
  jmp __alltraps
  101e66:	e9 17 07 00 00       	jmp    102582 <__alltraps>

00101e6b <vector97>:
.globl vector97
vector97:
  pushl $0
  101e6b:	6a 00                	push   $0x0
  pushl $97
  101e6d:	6a 61                	push   $0x61
  jmp __alltraps
  101e6f:	e9 0e 07 00 00       	jmp    102582 <__alltraps>

00101e74 <vector98>:
.globl vector98
vector98:
  pushl $0
  101e74:	6a 00                	push   $0x0
  pushl $98
  101e76:	6a 62                	push   $0x62
  jmp __alltraps
  101e78:	e9 05 07 00 00       	jmp    102582 <__alltraps>

00101e7d <vector99>:
.globl vector99
vector99:
  pushl $0
  101e7d:	6a 00                	push   $0x0
  pushl $99
  101e7f:	6a 63                	push   $0x63
  jmp __alltraps
  101e81:	e9 fc 06 00 00       	jmp    102582 <__alltraps>

00101e86 <vector100>:
.globl vector100
vector100:
  pushl $0
  101e86:	6a 00                	push   $0x0
  pushl $100
  101e88:	6a 64                	push   $0x64
  jmp __alltraps
  101e8a:	e9 f3 06 00 00       	jmp    102582 <__alltraps>

00101e8f <vector101>:
.globl vector101
vector101:
  pushl $0
  101e8f:	6a 00                	push   $0x0
  pushl $101
  101e91:	6a 65                	push   $0x65
  jmp __alltraps
  101e93:	e9 ea 06 00 00       	jmp    102582 <__alltraps>

00101e98 <vector102>:
.globl vector102
vector102:
  pushl $0
  101e98:	6a 00                	push   $0x0
  pushl $102
  101e9a:	6a 66                	push   $0x66
  jmp __alltraps
  101e9c:	e9 e1 06 00 00       	jmp    102582 <__alltraps>

00101ea1 <vector103>:
.globl vector103
vector103:
  pushl $0
  101ea1:	6a 00                	push   $0x0
  pushl $103
  101ea3:	6a 67                	push   $0x67
  jmp __alltraps
  101ea5:	e9 d8 06 00 00       	jmp    102582 <__alltraps>

00101eaa <vector104>:
.globl vector104
vector104:
  pushl $0
  101eaa:	6a 00                	push   $0x0
  pushl $104
  101eac:	6a 68                	push   $0x68
  jmp __alltraps
  101eae:	e9 cf 06 00 00       	jmp    102582 <__alltraps>

00101eb3 <vector105>:
.globl vector105
vector105:
  pushl $0
  101eb3:	6a 00                	push   $0x0
  pushl $105
  101eb5:	6a 69                	push   $0x69
  jmp __alltraps
  101eb7:	e9 c6 06 00 00       	jmp    102582 <__alltraps>

00101ebc <vector106>:
.globl vector106
vector106:
  pushl $0
  101ebc:	6a 00                	push   $0x0
  pushl $106
  101ebe:	6a 6a                	push   $0x6a
  jmp __alltraps
  101ec0:	e9 bd 06 00 00       	jmp    102582 <__alltraps>

00101ec5 <vector107>:
.globl vector107
vector107:
  pushl $0
  101ec5:	6a 00                	push   $0x0
  pushl $107
  101ec7:	6a 6b                	push   $0x6b
  jmp __alltraps
  101ec9:	e9 b4 06 00 00       	jmp    102582 <__alltraps>

00101ece <vector108>:
.globl vector108
vector108:
  pushl $0
  101ece:	6a 00                	push   $0x0
  pushl $108
  101ed0:	6a 6c                	push   $0x6c
  jmp __alltraps
  101ed2:	e9 ab 06 00 00       	jmp    102582 <__alltraps>

00101ed7 <vector109>:
.globl vector109
vector109:
  pushl $0
  101ed7:	6a 00                	push   $0x0
  pushl $109
  101ed9:	6a 6d                	push   $0x6d
  jmp __alltraps
  101edb:	e9 a2 06 00 00       	jmp    102582 <__alltraps>

00101ee0 <vector110>:
.globl vector110
vector110:
  pushl $0
  101ee0:	6a 00                	push   $0x0
  pushl $110
  101ee2:	6a 6e                	push   $0x6e
  jmp __alltraps
  101ee4:	e9 99 06 00 00       	jmp    102582 <__alltraps>

00101ee9 <vector111>:
.globl vector111
vector111:
  pushl $0
  101ee9:	6a 00                	push   $0x0
  pushl $111
  101eeb:	6a 6f                	push   $0x6f
  jmp __alltraps
  101eed:	e9 90 06 00 00       	jmp    102582 <__alltraps>

00101ef2 <vector112>:
.globl vector112
vector112:
  pushl $0
  101ef2:	6a 00                	push   $0x0
  pushl $112
  101ef4:	6a 70                	push   $0x70
  jmp __alltraps
  101ef6:	e9 87 06 00 00       	jmp    102582 <__alltraps>

00101efb <vector113>:
.globl vector113
vector113:
  pushl $0
  101efb:	6a 00                	push   $0x0
  pushl $113
  101efd:	6a 71                	push   $0x71
  jmp __alltraps
  101eff:	e9 7e 06 00 00       	jmp    102582 <__alltraps>

00101f04 <vector114>:
.globl vector114
vector114:
  pushl $0
  101f04:	6a 00                	push   $0x0
  pushl $114
  101f06:	6a 72                	push   $0x72
  jmp __alltraps
  101f08:	e9 75 06 00 00       	jmp    102582 <__alltraps>

00101f0d <vector115>:
.globl vector115
vector115:
  pushl $0
  101f0d:	6a 00                	push   $0x0
  pushl $115
  101f0f:	6a 73                	push   $0x73
  jmp __alltraps
  101f11:	e9 6c 06 00 00       	jmp    102582 <__alltraps>

00101f16 <vector116>:
.globl vector116
vector116:
  pushl $0
  101f16:	6a 00                	push   $0x0
  pushl $116
  101f18:	6a 74                	push   $0x74
  jmp __alltraps
  101f1a:	e9 63 06 00 00       	jmp    102582 <__alltraps>

00101f1f <vector117>:
.globl vector117
vector117:
  pushl $0
  101f1f:	6a 00                	push   $0x0
  pushl $117
  101f21:	6a 75                	push   $0x75
  jmp __alltraps
  101f23:	e9 5a 06 00 00       	jmp    102582 <__alltraps>

00101f28 <vector118>:
.globl vector118
vector118:
  pushl $0
  101f28:	6a 00                	push   $0x0
  pushl $118
  101f2a:	6a 76                	push   $0x76
  jmp __alltraps
  101f2c:	e9 51 06 00 00       	jmp    102582 <__alltraps>

00101f31 <vector119>:
.globl vector119
vector119:
  pushl $0
  101f31:	6a 00                	push   $0x0
  pushl $119
  101f33:	6a 77                	push   $0x77
  jmp __alltraps
  101f35:	e9 48 06 00 00       	jmp    102582 <__alltraps>

00101f3a <vector120>:
.globl vector120
vector120:
  pushl $0
  101f3a:	6a 00                	push   $0x0
  pushl $120
  101f3c:	6a 78                	push   $0x78
  jmp __alltraps
  101f3e:	e9 3f 06 00 00       	jmp    102582 <__alltraps>

00101f43 <vector121>:
.globl vector121
vector121:
  pushl $0
  101f43:	6a 00                	push   $0x0
  pushl $121
  101f45:	6a 79                	push   $0x79
  jmp __alltraps
  101f47:	e9 36 06 00 00       	jmp    102582 <__alltraps>

00101f4c <vector122>:
.globl vector122
vector122:
  pushl $0
  101f4c:	6a 00                	push   $0x0
  pushl $122
  101f4e:	6a 7a                	push   $0x7a
  jmp __alltraps
  101f50:	e9 2d 06 00 00       	jmp    102582 <__alltraps>

00101f55 <vector123>:
.globl vector123
vector123:
  pushl $0
  101f55:	6a 00                	push   $0x0
  pushl $123
  101f57:	6a 7b                	push   $0x7b
  jmp __alltraps
  101f59:	e9 24 06 00 00       	jmp    102582 <__alltraps>

00101f5e <vector124>:
.globl vector124
vector124:
  pushl $0
  101f5e:	6a 00                	push   $0x0
  pushl $124
  101f60:	6a 7c                	push   $0x7c
  jmp __alltraps
  101f62:	e9 1b 06 00 00       	jmp    102582 <__alltraps>

00101f67 <vector125>:
.globl vector125
vector125:
  pushl $0
  101f67:	6a 00                	push   $0x0
  pushl $125
  101f69:	6a 7d                	push   $0x7d
  jmp __alltraps
  101f6b:	e9 12 06 00 00       	jmp    102582 <__alltraps>

00101f70 <vector126>:
.globl vector126
vector126:
  pushl $0
  101f70:	6a 00                	push   $0x0
  pushl $126
  101f72:	6a 7e                	push   $0x7e
  jmp __alltraps
  101f74:	e9 09 06 00 00       	jmp    102582 <__alltraps>

00101f79 <vector127>:
.globl vector127
vector127:
  pushl $0
  101f79:	6a 00                	push   $0x0
  pushl $127
  101f7b:	6a 7f                	push   $0x7f
  jmp __alltraps
  101f7d:	e9 00 06 00 00       	jmp    102582 <__alltraps>

00101f82 <vector128>:
.globl vector128
vector128:
  pushl $0
  101f82:	6a 00                	push   $0x0
  pushl $128
  101f84:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  101f89:	e9 f4 05 00 00       	jmp    102582 <__alltraps>

00101f8e <vector129>:
.globl vector129
vector129:
  pushl $0
  101f8e:	6a 00                	push   $0x0
  pushl $129
  101f90:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  101f95:	e9 e8 05 00 00       	jmp    102582 <__alltraps>

00101f9a <vector130>:
.globl vector130
vector130:
  pushl $0
  101f9a:	6a 00                	push   $0x0
  pushl $130
  101f9c:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  101fa1:	e9 dc 05 00 00       	jmp    102582 <__alltraps>

00101fa6 <vector131>:
.globl vector131
vector131:
  pushl $0
  101fa6:	6a 00                	push   $0x0
  pushl $131
  101fa8:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  101fad:	e9 d0 05 00 00       	jmp    102582 <__alltraps>

00101fb2 <vector132>:
.globl vector132
vector132:
  pushl $0
  101fb2:	6a 00                	push   $0x0
  pushl $132
  101fb4:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  101fb9:	e9 c4 05 00 00       	jmp    102582 <__alltraps>

00101fbe <vector133>:
.globl vector133
vector133:
  pushl $0
  101fbe:	6a 00                	push   $0x0
  pushl $133
  101fc0:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  101fc5:	e9 b8 05 00 00       	jmp    102582 <__alltraps>

00101fca <vector134>:
.globl vector134
vector134:
  pushl $0
  101fca:	6a 00                	push   $0x0
  pushl $134
  101fcc:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  101fd1:	e9 ac 05 00 00       	jmp    102582 <__alltraps>

00101fd6 <vector135>:
.globl vector135
vector135:
  pushl $0
  101fd6:	6a 00                	push   $0x0
  pushl $135
  101fd8:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  101fdd:	e9 a0 05 00 00       	jmp    102582 <__alltraps>

00101fe2 <vector136>:
.globl vector136
vector136:
  pushl $0
  101fe2:	6a 00                	push   $0x0
  pushl $136
  101fe4:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  101fe9:	e9 94 05 00 00       	jmp    102582 <__alltraps>

00101fee <vector137>:
.globl vector137
vector137:
  pushl $0
  101fee:	6a 00                	push   $0x0
  pushl $137
  101ff0:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  101ff5:	e9 88 05 00 00       	jmp    102582 <__alltraps>

00101ffa <vector138>:
.globl vector138
vector138:
  pushl $0
  101ffa:	6a 00                	push   $0x0
  pushl $138
  101ffc:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  102001:	e9 7c 05 00 00       	jmp    102582 <__alltraps>

00102006 <vector139>:
.globl vector139
vector139:
  pushl $0
  102006:	6a 00                	push   $0x0
  pushl $139
  102008:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  10200d:	e9 70 05 00 00       	jmp    102582 <__alltraps>

00102012 <vector140>:
.globl vector140
vector140:
  pushl $0
  102012:	6a 00                	push   $0x0
  pushl $140
  102014:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  102019:	e9 64 05 00 00       	jmp    102582 <__alltraps>

0010201e <vector141>:
.globl vector141
vector141:
  pushl $0
  10201e:	6a 00                	push   $0x0
  pushl $141
  102020:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  102025:	e9 58 05 00 00       	jmp    102582 <__alltraps>

0010202a <vector142>:
.globl vector142
vector142:
  pushl $0
  10202a:	6a 00                	push   $0x0
  pushl $142
  10202c:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  102031:	e9 4c 05 00 00       	jmp    102582 <__alltraps>

00102036 <vector143>:
.globl vector143
vector143:
  pushl $0
  102036:	6a 00                	push   $0x0
  pushl $143
  102038:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  10203d:	e9 40 05 00 00       	jmp    102582 <__alltraps>

00102042 <vector144>:
.globl vector144
vector144:
  pushl $0
  102042:	6a 00                	push   $0x0
  pushl $144
  102044:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  102049:	e9 34 05 00 00       	jmp    102582 <__alltraps>

0010204e <vector145>:
.globl vector145
vector145:
  pushl $0
  10204e:	6a 00                	push   $0x0
  pushl $145
  102050:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  102055:	e9 28 05 00 00       	jmp    102582 <__alltraps>

0010205a <vector146>:
.globl vector146
vector146:
  pushl $0
  10205a:	6a 00                	push   $0x0
  pushl $146
  10205c:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  102061:	e9 1c 05 00 00       	jmp    102582 <__alltraps>

00102066 <vector147>:
.globl vector147
vector147:
  pushl $0
  102066:	6a 00                	push   $0x0
  pushl $147
  102068:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  10206d:	e9 10 05 00 00       	jmp    102582 <__alltraps>

00102072 <vector148>:
.globl vector148
vector148:
  pushl $0
  102072:	6a 00                	push   $0x0
  pushl $148
  102074:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  102079:	e9 04 05 00 00       	jmp    102582 <__alltraps>

0010207e <vector149>:
.globl vector149
vector149:
  pushl $0
  10207e:	6a 00                	push   $0x0
  pushl $149
  102080:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  102085:	e9 f8 04 00 00       	jmp    102582 <__alltraps>

0010208a <vector150>:
.globl vector150
vector150:
  pushl $0
  10208a:	6a 00                	push   $0x0
  pushl $150
  10208c:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  102091:	e9 ec 04 00 00       	jmp    102582 <__alltraps>

00102096 <vector151>:
.globl vector151
vector151:
  pushl $0
  102096:	6a 00                	push   $0x0
  pushl $151
  102098:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  10209d:	e9 e0 04 00 00       	jmp    102582 <__alltraps>

001020a2 <vector152>:
.globl vector152
vector152:
  pushl $0
  1020a2:	6a 00                	push   $0x0
  pushl $152
  1020a4:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  1020a9:	e9 d4 04 00 00       	jmp    102582 <__alltraps>

001020ae <vector153>:
.globl vector153
vector153:
  pushl $0
  1020ae:	6a 00                	push   $0x0
  pushl $153
  1020b0:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  1020b5:	e9 c8 04 00 00       	jmp    102582 <__alltraps>

001020ba <vector154>:
.globl vector154
vector154:
  pushl $0
  1020ba:	6a 00                	push   $0x0
  pushl $154
  1020bc:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  1020c1:	e9 bc 04 00 00       	jmp    102582 <__alltraps>

001020c6 <vector155>:
.globl vector155
vector155:
  pushl $0
  1020c6:	6a 00                	push   $0x0
  pushl $155
  1020c8:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  1020cd:	e9 b0 04 00 00       	jmp    102582 <__alltraps>

001020d2 <vector156>:
.globl vector156
vector156:
  pushl $0
  1020d2:	6a 00                	push   $0x0
  pushl $156
  1020d4:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  1020d9:	e9 a4 04 00 00       	jmp    102582 <__alltraps>

001020de <vector157>:
.globl vector157
vector157:
  pushl $0
  1020de:	6a 00                	push   $0x0
  pushl $157
  1020e0:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  1020e5:	e9 98 04 00 00       	jmp    102582 <__alltraps>

001020ea <vector158>:
.globl vector158
vector158:
  pushl $0
  1020ea:	6a 00                	push   $0x0
  pushl $158
  1020ec:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  1020f1:	e9 8c 04 00 00       	jmp    102582 <__alltraps>

001020f6 <vector159>:
.globl vector159
vector159:
  pushl $0
  1020f6:	6a 00                	push   $0x0
  pushl $159
  1020f8:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  1020fd:	e9 80 04 00 00       	jmp    102582 <__alltraps>

00102102 <vector160>:
.globl vector160
vector160:
  pushl $0
  102102:	6a 00                	push   $0x0
  pushl $160
  102104:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  102109:	e9 74 04 00 00       	jmp    102582 <__alltraps>

0010210e <vector161>:
.globl vector161
vector161:
  pushl $0
  10210e:	6a 00                	push   $0x0
  pushl $161
  102110:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  102115:	e9 68 04 00 00       	jmp    102582 <__alltraps>

0010211a <vector162>:
.globl vector162
vector162:
  pushl $0
  10211a:	6a 00                	push   $0x0
  pushl $162
  10211c:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  102121:	e9 5c 04 00 00       	jmp    102582 <__alltraps>

00102126 <vector163>:
.globl vector163
vector163:
  pushl $0
  102126:	6a 00                	push   $0x0
  pushl $163
  102128:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  10212d:	e9 50 04 00 00       	jmp    102582 <__alltraps>

00102132 <vector164>:
.globl vector164
vector164:
  pushl $0
  102132:	6a 00                	push   $0x0
  pushl $164
  102134:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  102139:	e9 44 04 00 00       	jmp    102582 <__alltraps>

0010213e <vector165>:
.globl vector165
vector165:
  pushl $0
  10213e:	6a 00                	push   $0x0
  pushl $165
  102140:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  102145:	e9 38 04 00 00       	jmp    102582 <__alltraps>

0010214a <vector166>:
.globl vector166
vector166:
  pushl $0
  10214a:	6a 00                	push   $0x0
  pushl $166
  10214c:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  102151:	e9 2c 04 00 00       	jmp    102582 <__alltraps>

00102156 <vector167>:
.globl vector167
vector167:
  pushl $0
  102156:	6a 00                	push   $0x0
  pushl $167
  102158:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  10215d:	e9 20 04 00 00       	jmp    102582 <__alltraps>

00102162 <vector168>:
.globl vector168
vector168:
  pushl $0
  102162:	6a 00                	push   $0x0
  pushl $168
  102164:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  102169:	e9 14 04 00 00       	jmp    102582 <__alltraps>

0010216e <vector169>:
.globl vector169
vector169:
  pushl $0
  10216e:	6a 00                	push   $0x0
  pushl $169
  102170:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  102175:	e9 08 04 00 00       	jmp    102582 <__alltraps>

0010217a <vector170>:
.globl vector170
vector170:
  pushl $0
  10217a:	6a 00                	push   $0x0
  pushl $170
  10217c:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  102181:	e9 fc 03 00 00       	jmp    102582 <__alltraps>

00102186 <vector171>:
.globl vector171
vector171:
  pushl $0
  102186:	6a 00                	push   $0x0
  pushl $171
  102188:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  10218d:	e9 f0 03 00 00       	jmp    102582 <__alltraps>

00102192 <vector172>:
.globl vector172
vector172:
  pushl $0
  102192:	6a 00                	push   $0x0
  pushl $172
  102194:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  102199:	e9 e4 03 00 00       	jmp    102582 <__alltraps>

0010219e <vector173>:
.globl vector173
vector173:
  pushl $0
  10219e:	6a 00                	push   $0x0
  pushl $173
  1021a0:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  1021a5:	e9 d8 03 00 00       	jmp    102582 <__alltraps>

001021aa <vector174>:
.globl vector174
vector174:
  pushl $0
  1021aa:	6a 00                	push   $0x0
  pushl $174
  1021ac:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  1021b1:	e9 cc 03 00 00       	jmp    102582 <__alltraps>

001021b6 <vector175>:
.globl vector175
vector175:
  pushl $0
  1021b6:	6a 00                	push   $0x0
  pushl $175
  1021b8:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  1021bd:	e9 c0 03 00 00       	jmp    102582 <__alltraps>

001021c2 <vector176>:
.globl vector176
vector176:
  pushl $0
  1021c2:	6a 00                	push   $0x0
  pushl $176
  1021c4:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  1021c9:	e9 b4 03 00 00       	jmp    102582 <__alltraps>

001021ce <vector177>:
.globl vector177
vector177:
  pushl $0
  1021ce:	6a 00                	push   $0x0
  pushl $177
  1021d0:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  1021d5:	e9 a8 03 00 00       	jmp    102582 <__alltraps>

001021da <vector178>:
.globl vector178
vector178:
  pushl $0
  1021da:	6a 00                	push   $0x0
  pushl $178
  1021dc:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  1021e1:	e9 9c 03 00 00       	jmp    102582 <__alltraps>

001021e6 <vector179>:
.globl vector179
vector179:
  pushl $0
  1021e6:	6a 00                	push   $0x0
  pushl $179
  1021e8:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  1021ed:	e9 90 03 00 00       	jmp    102582 <__alltraps>

001021f2 <vector180>:
.globl vector180
vector180:
  pushl $0
  1021f2:	6a 00                	push   $0x0
  pushl $180
  1021f4:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  1021f9:	e9 84 03 00 00       	jmp    102582 <__alltraps>

001021fe <vector181>:
.globl vector181
vector181:
  pushl $0
  1021fe:	6a 00                	push   $0x0
  pushl $181
  102200:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  102205:	e9 78 03 00 00       	jmp    102582 <__alltraps>

0010220a <vector182>:
.globl vector182
vector182:
  pushl $0
  10220a:	6a 00                	push   $0x0
  pushl $182
  10220c:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  102211:	e9 6c 03 00 00       	jmp    102582 <__alltraps>

00102216 <vector183>:
.globl vector183
vector183:
  pushl $0
  102216:	6a 00                	push   $0x0
  pushl $183
  102218:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  10221d:	e9 60 03 00 00       	jmp    102582 <__alltraps>

00102222 <vector184>:
.globl vector184
vector184:
  pushl $0
  102222:	6a 00                	push   $0x0
  pushl $184
  102224:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  102229:	e9 54 03 00 00       	jmp    102582 <__alltraps>

0010222e <vector185>:
.globl vector185
vector185:
  pushl $0
  10222e:	6a 00                	push   $0x0
  pushl $185
  102230:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  102235:	e9 48 03 00 00       	jmp    102582 <__alltraps>

0010223a <vector186>:
.globl vector186
vector186:
  pushl $0
  10223a:	6a 00                	push   $0x0
  pushl $186
  10223c:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  102241:	e9 3c 03 00 00       	jmp    102582 <__alltraps>

00102246 <vector187>:
.globl vector187
vector187:
  pushl $0
  102246:	6a 00                	push   $0x0
  pushl $187
  102248:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  10224d:	e9 30 03 00 00       	jmp    102582 <__alltraps>

00102252 <vector188>:
.globl vector188
vector188:
  pushl $0
  102252:	6a 00                	push   $0x0
  pushl $188
  102254:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  102259:	e9 24 03 00 00       	jmp    102582 <__alltraps>

0010225e <vector189>:
.globl vector189
vector189:
  pushl $0
  10225e:	6a 00                	push   $0x0
  pushl $189
  102260:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  102265:	e9 18 03 00 00       	jmp    102582 <__alltraps>

0010226a <vector190>:
.globl vector190
vector190:
  pushl $0
  10226a:	6a 00                	push   $0x0
  pushl $190
  10226c:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  102271:	e9 0c 03 00 00       	jmp    102582 <__alltraps>

00102276 <vector191>:
.globl vector191
vector191:
  pushl $0
  102276:	6a 00                	push   $0x0
  pushl $191
  102278:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  10227d:	e9 00 03 00 00       	jmp    102582 <__alltraps>

00102282 <vector192>:
.globl vector192
vector192:
  pushl $0
  102282:	6a 00                	push   $0x0
  pushl $192
  102284:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  102289:	e9 f4 02 00 00       	jmp    102582 <__alltraps>

0010228e <vector193>:
.globl vector193
vector193:
  pushl $0
  10228e:	6a 00                	push   $0x0
  pushl $193
  102290:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  102295:	e9 e8 02 00 00       	jmp    102582 <__alltraps>

0010229a <vector194>:
.globl vector194
vector194:
  pushl $0
  10229a:	6a 00                	push   $0x0
  pushl $194
  10229c:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  1022a1:	e9 dc 02 00 00       	jmp    102582 <__alltraps>

001022a6 <vector195>:
.globl vector195
vector195:
  pushl $0
  1022a6:	6a 00                	push   $0x0
  pushl $195
  1022a8:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  1022ad:	e9 d0 02 00 00       	jmp    102582 <__alltraps>

001022b2 <vector196>:
.globl vector196
vector196:
  pushl $0
  1022b2:	6a 00                	push   $0x0
  pushl $196
  1022b4:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  1022b9:	e9 c4 02 00 00       	jmp    102582 <__alltraps>

001022be <vector197>:
.globl vector197
vector197:
  pushl $0
  1022be:	6a 00                	push   $0x0
  pushl $197
  1022c0:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  1022c5:	e9 b8 02 00 00       	jmp    102582 <__alltraps>

001022ca <vector198>:
.globl vector198
vector198:
  pushl $0
  1022ca:	6a 00                	push   $0x0
  pushl $198
  1022cc:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  1022d1:	e9 ac 02 00 00       	jmp    102582 <__alltraps>

001022d6 <vector199>:
.globl vector199
vector199:
  pushl $0
  1022d6:	6a 00                	push   $0x0
  pushl $199
  1022d8:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  1022dd:	e9 a0 02 00 00       	jmp    102582 <__alltraps>

001022e2 <vector200>:
.globl vector200
vector200:
  pushl $0
  1022e2:	6a 00                	push   $0x0
  pushl $200
  1022e4:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  1022e9:	e9 94 02 00 00       	jmp    102582 <__alltraps>

001022ee <vector201>:
.globl vector201
vector201:
  pushl $0
  1022ee:	6a 00                	push   $0x0
  pushl $201
  1022f0:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  1022f5:	e9 88 02 00 00       	jmp    102582 <__alltraps>

001022fa <vector202>:
.globl vector202
vector202:
  pushl $0
  1022fa:	6a 00                	push   $0x0
  pushl $202
  1022fc:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  102301:	e9 7c 02 00 00       	jmp    102582 <__alltraps>

00102306 <vector203>:
.globl vector203
vector203:
  pushl $0
  102306:	6a 00                	push   $0x0
  pushl $203
  102308:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  10230d:	e9 70 02 00 00       	jmp    102582 <__alltraps>

00102312 <vector204>:
.globl vector204
vector204:
  pushl $0
  102312:	6a 00                	push   $0x0
  pushl $204
  102314:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  102319:	e9 64 02 00 00       	jmp    102582 <__alltraps>

0010231e <vector205>:
.globl vector205
vector205:
  pushl $0
  10231e:	6a 00                	push   $0x0
  pushl $205
  102320:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  102325:	e9 58 02 00 00       	jmp    102582 <__alltraps>

0010232a <vector206>:
.globl vector206
vector206:
  pushl $0
  10232a:	6a 00                	push   $0x0
  pushl $206
  10232c:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  102331:	e9 4c 02 00 00       	jmp    102582 <__alltraps>

00102336 <vector207>:
.globl vector207
vector207:
  pushl $0
  102336:	6a 00                	push   $0x0
  pushl $207
  102338:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  10233d:	e9 40 02 00 00       	jmp    102582 <__alltraps>

00102342 <vector208>:
.globl vector208
vector208:
  pushl $0
  102342:	6a 00                	push   $0x0
  pushl $208
  102344:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  102349:	e9 34 02 00 00       	jmp    102582 <__alltraps>

0010234e <vector209>:
.globl vector209
vector209:
  pushl $0
  10234e:	6a 00                	push   $0x0
  pushl $209
  102350:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  102355:	e9 28 02 00 00       	jmp    102582 <__alltraps>

0010235a <vector210>:
.globl vector210
vector210:
  pushl $0
  10235a:	6a 00                	push   $0x0
  pushl $210
  10235c:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  102361:	e9 1c 02 00 00       	jmp    102582 <__alltraps>

00102366 <vector211>:
.globl vector211
vector211:
  pushl $0
  102366:	6a 00                	push   $0x0
  pushl $211
  102368:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  10236d:	e9 10 02 00 00       	jmp    102582 <__alltraps>

00102372 <vector212>:
.globl vector212
vector212:
  pushl $0
  102372:	6a 00                	push   $0x0
  pushl $212
  102374:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  102379:	e9 04 02 00 00       	jmp    102582 <__alltraps>

0010237e <vector213>:
.globl vector213
vector213:
  pushl $0
  10237e:	6a 00                	push   $0x0
  pushl $213
  102380:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  102385:	e9 f8 01 00 00       	jmp    102582 <__alltraps>

0010238a <vector214>:
.globl vector214
vector214:
  pushl $0
  10238a:	6a 00                	push   $0x0
  pushl $214
  10238c:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  102391:	e9 ec 01 00 00       	jmp    102582 <__alltraps>

00102396 <vector215>:
.globl vector215
vector215:
  pushl $0
  102396:	6a 00                	push   $0x0
  pushl $215
  102398:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  10239d:	e9 e0 01 00 00       	jmp    102582 <__alltraps>

001023a2 <vector216>:
.globl vector216
vector216:
  pushl $0
  1023a2:	6a 00                	push   $0x0
  pushl $216
  1023a4:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  1023a9:	e9 d4 01 00 00       	jmp    102582 <__alltraps>

001023ae <vector217>:
.globl vector217
vector217:
  pushl $0
  1023ae:	6a 00                	push   $0x0
  pushl $217
  1023b0:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  1023b5:	e9 c8 01 00 00       	jmp    102582 <__alltraps>

001023ba <vector218>:
.globl vector218
vector218:
  pushl $0
  1023ba:	6a 00                	push   $0x0
  pushl $218
  1023bc:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  1023c1:	e9 bc 01 00 00       	jmp    102582 <__alltraps>

001023c6 <vector219>:
.globl vector219
vector219:
  pushl $0
  1023c6:	6a 00                	push   $0x0
  pushl $219
  1023c8:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  1023cd:	e9 b0 01 00 00       	jmp    102582 <__alltraps>

001023d2 <vector220>:
.globl vector220
vector220:
  pushl $0
  1023d2:	6a 00                	push   $0x0
  pushl $220
  1023d4:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  1023d9:	e9 a4 01 00 00       	jmp    102582 <__alltraps>

001023de <vector221>:
.globl vector221
vector221:
  pushl $0
  1023de:	6a 00                	push   $0x0
  pushl $221
  1023e0:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  1023e5:	e9 98 01 00 00       	jmp    102582 <__alltraps>

001023ea <vector222>:
.globl vector222
vector222:
  pushl $0
  1023ea:	6a 00                	push   $0x0
  pushl $222
  1023ec:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  1023f1:	e9 8c 01 00 00       	jmp    102582 <__alltraps>

001023f6 <vector223>:
.globl vector223
vector223:
  pushl $0
  1023f6:	6a 00                	push   $0x0
  pushl $223
  1023f8:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  1023fd:	e9 80 01 00 00       	jmp    102582 <__alltraps>

00102402 <vector224>:
.globl vector224
vector224:
  pushl $0
  102402:	6a 00                	push   $0x0
  pushl $224
  102404:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  102409:	e9 74 01 00 00       	jmp    102582 <__alltraps>

0010240e <vector225>:
.globl vector225
vector225:
  pushl $0
  10240e:	6a 00                	push   $0x0
  pushl $225
  102410:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  102415:	e9 68 01 00 00       	jmp    102582 <__alltraps>

0010241a <vector226>:
.globl vector226
vector226:
  pushl $0
  10241a:	6a 00                	push   $0x0
  pushl $226
  10241c:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  102421:	e9 5c 01 00 00       	jmp    102582 <__alltraps>

00102426 <vector227>:
.globl vector227
vector227:
  pushl $0
  102426:	6a 00                	push   $0x0
  pushl $227
  102428:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  10242d:	e9 50 01 00 00       	jmp    102582 <__alltraps>

00102432 <vector228>:
.globl vector228
vector228:
  pushl $0
  102432:	6a 00                	push   $0x0
  pushl $228
  102434:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  102439:	e9 44 01 00 00       	jmp    102582 <__alltraps>

0010243e <vector229>:
.globl vector229
vector229:
  pushl $0
  10243e:	6a 00                	push   $0x0
  pushl $229
  102440:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  102445:	e9 38 01 00 00       	jmp    102582 <__alltraps>

0010244a <vector230>:
.globl vector230
vector230:
  pushl $0
  10244a:	6a 00                	push   $0x0
  pushl $230
  10244c:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  102451:	e9 2c 01 00 00       	jmp    102582 <__alltraps>

00102456 <vector231>:
.globl vector231
vector231:
  pushl $0
  102456:	6a 00                	push   $0x0
  pushl $231
  102458:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  10245d:	e9 20 01 00 00       	jmp    102582 <__alltraps>

00102462 <vector232>:
.globl vector232
vector232:
  pushl $0
  102462:	6a 00                	push   $0x0
  pushl $232
  102464:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  102469:	e9 14 01 00 00       	jmp    102582 <__alltraps>

0010246e <vector233>:
.globl vector233
vector233:
  pushl $0
  10246e:	6a 00                	push   $0x0
  pushl $233
  102470:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  102475:	e9 08 01 00 00       	jmp    102582 <__alltraps>

0010247a <vector234>:
.globl vector234
vector234:
  pushl $0
  10247a:	6a 00                	push   $0x0
  pushl $234
  10247c:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  102481:	e9 fc 00 00 00       	jmp    102582 <__alltraps>

00102486 <vector235>:
.globl vector235
vector235:
  pushl $0
  102486:	6a 00                	push   $0x0
  pushl $235
  102488:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  10248d:	e9 f0 00 00 00       	jmp    102582 <__alltraps>

00102492 <vector236>:
.globl vector236
vector236:
  pushl $0
  102492:	6a 00                	push   $0x0
  pushl $236
  102494:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  102499:	e9 e4 00 00 00       	jmp    102582 <__alltraps>

0010249e <vector237>:
.globl vector237
vector237:
  pushl $0
  10249e:	6a 00                	push   $0x0
  pushl $237
  1024a0:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  1024a5:	e9 d8 00 00 00       	jmp    102582 <__alltraps>

001024aa <vector238>:
.globl vector238
vector238:
  pushl $0
  1024aa:	6a 00                	push   $0x0
  pushl $238
  1024ac:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  1024b1:	e9 cc 00 00 00       	jmp    102582 <__alltraps>

001024b6 <vector239>:
.globl vector239
vector239:
  pushl $0
  1024b6:	6a 00                	push   $0x0
  pushl $239
  1024b8:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  1024bd:	e9 c0 00 00 00       	jmp    102582 <__alltraps>

001024c2 <vector240>:
.globl vector240
vector240:
  pushl $0
  1024c2:	6a 00                	push   $0x0
  pushl $240
  1024c4:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  1024c9:	e9 b4 00 00 00       	jmp    102582 <__alltraps>

001024ce <vector241>:
.globl vector241
vector241:
  pushl $0
  1024ce:	6a 00                	push   $0x0
  pushl $241
  1024d0:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  1024d5:	e9 a8 00 00 00       	jmp    102582 <__alltraps>

001024da <vector242>:
.globl vector242
vector242:
  pushl $0
  1024da:	6a 00                	push   $0x0
  pushl $242
  1024dc:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  1024e1:	e9 9c 00 00 00       	jmp    102582 <__alltraps>

001024e6 <vector243>:
.globl vector243
vector243:
  pushl $0
  1024e6:	6a 00                	push   $0x0
  pushl $243
  1024e8:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  1024ed:	e9 90 00 00 00       	jmp    102582 <__alltraps>

001024f2 <vector244>:
.globl vector244
vector244:
  pushl $0
  1024f2:	6a 00                	push   $0x0
  pushl $244
  1024f4:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  1024f9:	e9 84 00 00 00       	jmp    102582 <__alltraps>

001024fe <vector245>:
.globl vector245
vector245:
  pushl $0
  1024fe:	6a 00                	push   $0x0
  pushl $245
  102500:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  102505:	e9 78 00 00 00       	jmp    102582 <__alltraps>

0010250a <vector246>:
.globl vector246
vector246:
  pushl $0
  10250a:	6a 00                	push   $0x0
  pushl $246
  10250c:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  102511:	e9 6c 00 00 00       	jmp    102582 <__alltraps>

00102516 <vector247>:
.globl vector247
vector247:
  pushl $0
  102516:	6a 00                	push   $0x0
  pushl $247
  102518:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  10251d:	e9 60 00 00 00       	jmp    102582 <__alltraps>

00102522 <vector248>:
.globl vector248
vector248:
  pushl $0
  102522:	6a 00                	push   $0x0
  pushl $248
  102524:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  102529:	e9 54 00 00 00       	jmp    102582 <__alltraps>

0010252e <vector249>:
.globl vector249
vector249:
  pushl $0
  10252e:	6a 00                	push   $0x0
  pushl $249
  102530:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  102535:	e9 48 00 00 00       	jmp    102582 <__alltraps>

0010253a <vector250>:
.globl vector250
vector250:
  pushl $0
  10253a:	6a 00                	push   $0x0
  pushl $250
  10253c:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  102541:	e9 3c 00 00 00       	jmp    102582 <__alltraps>

00102546 <vector251>:
.globl vector251
vector251:
  pushl $0
  102546:	6a 00                	push   $0x0
  pushl $251
  102548:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  10254d:	e9 30 00 00 00       	jmp    102582 <__alltraps>

00102552 <vector252>:
.globl vector252
vector252:
  pushl $0
  102552:	6a 00                	push   $0x0
  pushl $252
  102554:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  102559:	e9 24 00 00 00       	jmp    102582 <__alltraps>

0010255e <vector253>:
.globl vector253
vector253:
  pushl $0
  10255e:	6a 00                	push   $0x0
  pushl $253
  102560:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  102565:	e9 18 00 00 00       	jmp    102582 <__alltraps>

0010256a <vector254>:
.globl vector254
vector254:
  pushl $0
  10256a:	6a 00                	push   $0x0
  pushl $254
  10256c:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  102571:	e9 0c 00 00 00       	jmp    102582 <__alltraps>

00102576 <vector255>:
.globl vector255
vector255:
  pushl $0
  102576:	6a 00                	push   $0x0
  pushl $255
  102578:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  10257d:	e9 00 00 00 00       	jmp    102582 <__alltraps>

00102582 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  102582:	1e                   	push   %ds
    pushl %es
  102583:	06                   	push   %es
    pushl %fs
  102584:	0f a0                	push   %fs
    pushl %gs
  102586:	0f a8                	push   %gs
    pushal
  102588:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  102589:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  10258e:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  102590:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  102592:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  102593:	e8 65 f5 ff ff       	call   101afd <trap>

    # pop the pushed stack pointer
    popl %esp
  102598:	5c                   	pop    %esp

00102599 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  102599:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  10259a:	0f a9                	pop    %gs
    popl %fs
  10259c:	0f a1                	pop    %fs
    popl %es
  10259e:	07                   	pop    %es
    popl %ds
  10259f:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  1025a0:	83 c4 08             	add    $0x8,%esp
    iret
  1025a3:	cf                   	iret   

001025a4 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  1025a4:	55                   	push   %ebp
  1025a5:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  1025a7:	8b 45 08             	mov    0x8(%ebp),%eax
  1025aa:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  1025ad:	b8 23 00 00 00       	mov    $0x23,%eax
  1025b2:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  1025b4:	b8 23 00 00 00       	mov    $0x23,%eax
  1025b9:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  1025bb:	b8 10 00 00 00       	mov    $0x10,%eax
  1025c0:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  1025c2:	b8 10 00 00 00       	mov    $0x10,%eax
  1025c7:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  1025c9:	b8 10 00 00 00       	mov    $0x10,%eax
  1025ce:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  1025d0:	ea d7 25 10 00 08 00 	ljmp   $0x8,$0x1025d7
}
  1025d7:	5d                   	pop    %ebp
  1025d8:	c3                   	ret    

001025d9 <gdt_init>:
/* temporary kernel stack */
uint8_t stack0[1024];

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  1025d9:	55                   	push   %ebp
  1025da:	89 e5                	mov    %esp,%ebp
  1025dc:	83 ec 14             	sub    $0x14,%esp
    // Setup a TSS so that we can get the right stack when we trap from
    // user to the kernel. But not safe here, it's only a temporary value,
    // it will be set to KSTACKTOP in lab2.
    ts.ts_esp0 = (uint32_t)&stack0 + sizeof(stack0);
  1025df:	b8 20 f9 10 00       	mov    $0x10f920,%eax
  1025e4:	05 00 04 00 00       	add    $0x400,%eax
  1025e9:	a3 a4 f8 10 00       	mov    %eax,0x10f8a4
    ts.ts_ss0 = KERNEL_DS;
  1025ee:	66 c7 05 a8 f8 10 00 	movw   $0x10,0x10f8a8
  1025f5:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEG16(STS_T32A, (uint32_t)&ts, sizeof(ts), DPL_KERNEL);
  1025f7:	66 c7 05 08 ea 10 00 	movw   $0x68,0x10ea08
  1025fe:	68 00 
  102600:	b8 a0 f8 10 00       	mov    $0x10f8a0,%eax
  102605:	66 a3 0a ea 10 00    	mov    %ax,0x10ea0a
  10260b:	b8 a0 f8 10 00       	mov    $0x10f8a0,%eax
  102610:	c1 e8 10             	shr    $0x10,%eax
  102613:	a2 0c ea 10 00       	mov    %al,0x10ea0c
  102618:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  10261f:	83 e0 f0             	and    $0xfffffff0,%eax
  102622:	83 c8 09             	or     $0x9,%eax
  102625:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  10262a:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  102631:	83 c8 10             	or     $0x10,%eax
  102634:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  102639:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  102640:	83 e0 9f             	and    $0xffffff9f,%eax
  102643:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  102648:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  10264f:	83 c8 80             	or     $0xffffff80,%eax
  102652:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  102657:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  10265e:	83 e0 f0             	and    $0xfffffff0,%eax
  102661:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  102666:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  10266d:	83 e0 ef             	and    $0xffffffef,%eax
  102670:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  102675:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  10267c:	83 e0 df             	and    $0xffffffdf,%eax
  10267f:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  102684:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  10268b:	83 c8 40             	or     $0x40,%eax
  10268e:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  102693:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  10269a:	83 e0 7f             	and    $0x7f,%eax
  10269d:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  1026a2:	b8 a0 f8 10 00       	mov    $0x10f8a0,%eax
  1026a7:	c1 e8 18             	shr    $0x18,%eax
  1026aa:	a2 0f ea 10 00       	mov    %al,0x10ea0f
    gdt[SEG_TSS].sd_s = 0;
  1026af:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  1026b6:	83 e0 ef             	and    $0xffffffef,%eax
  1026b9:	a2 0d ea 10 00       	mov    %al,0x10ea0d

    // reload all segment registers
    lgdt(&gdt_pd);
  1026be:	c7 04 24 10 ea 10 00 	movl   $0x10ea10,(%esp)
  1026c5:	e8 da fe ff ff       	call   1025a4 <lgdt>
  1026ca:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel));
  1026d0:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  1026d4:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  1026d7:	c9                   	leave  
  1026d8:	c3                   	ret    

001026d9 <pmm_init>:

/* pmm_init - initialize the physical memory management */
void
pmm_init(void) {
  1026d9:	55                   	push   %ebp
  1026da:	89 e5                	mov    %esp,%ebp
    gdt_init();
  1026dc:	e8 f8 fe ff ff       	call   1025d9 <gdt_init>
}
  1026e1:	5d                   	pop    %ebp
  1026e2:	c3                   	ret    

001026e3 <strlen>:
 * @s:        the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  1026e3:	55                   	push   %ebp
  1026e4:	89 e5                	mov    %esp,%ebp
  1026e6:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  1026e9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  1026f0:	eb 04                	jmp    1026f6 <strlen+0x13>
        cnt ++;
  1026f2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (*s ++ != '\0') {
  1026f6:	8b 45 08             	mov    0x8(%ebp),%eax
  1026f9:	8d 50 01             	lea    0x1(%eax),%edx
  1026fc:	89 55 08             	mov    %edx,0x8(%ebp)
  1026ff:	0f b6 00             	movzbl (%eax),%eax
  102702:	84 c0                	test   %al,%al
  102704:	75 ec                	jne    1026f2 <strlen+0xf>
    }
    return cnt;
  102706:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  102709:	c9                   	leave  
  10270a:	c3                   	ret    

0010270b <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  10270b:	55                   	push   %ebp
  10270c:	89 e5                	mov    %esp,%ebp
  10270e:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  102711:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  102718:	eb 04                	jmp    10271e <strnlen+0x13>
        cnt ++;
  10271a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  10271e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102721:	3b 45 0c             	cmp    0xc(%ebp),%eax
  102724:	73 10                	jae    102736 <strnlen+0x2b>
  102726:	8b 45 08             	mov    0x8(%ebp),%eax
  102729:	8d 50 01             	lea    0x1(%eax),%edx
  10272c:	89 55 08             	mov    %edx,0x8(%ebp)
  10272f:	0f b6 00             	movzbl (%eax),%eax
  102732:	84 c0                	test   %al,%al
  102734:	75 e4                	jne    10271a <strnlen+0xf>
    }
    return cnt;
  102736:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  102739:	c9                   	leave  
  10273a:	c3                   	ret    

0010273b <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  10273b:	55                   	push   %ebp
  10273c:	89 e5                	mov    %esp,%ebp
  10273e:	57                   	push   %edi
  10273f:	56                   	push   %esi
  102740:	83 ec 20             	sub    $0x20,%esp
  102743:	8b 45 08             	mov    0x8(%ebp),%eax
  102746:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102749:	8b 45 0c             	mov    0xc(%ebp),%eax
  10274c:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  10274f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  102752:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102755:	89 d1                	mov    %edx,%ecx
  102757:	89 c2                	mov    %eax,%edx
  102759:	89 ce                	mov    %ecx,%esi
  10275b:	89 d7                	mov    %edx,%edi
  10275d:	ac                   	lods   %ds:(%esi),%al
  10275e:	aa                   	stos   %al,%es:(%edi)
  10275f:	84 c0                	test   %al,%al
  102761:	75 fa                	jne    10275d <strcpy+0x22>
  102763:	89 fa                	mov    %edi,%edx
  102765:	89 f1                	mov    %esi,%ecx
  102767:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  10276a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  10276d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            "stosb;"
            "testb %%al, %%al;"
            "jne 1b;"
            : "=&S" (d0), "=&D" (d1), "=&a" (d2)
            : "0" (src), "1" (dst) : "memory");
    return dst;
  102770:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  102773:	83 c4 20             	add    $0x20,%esp
  102776:	5e                   	pop    %esi
  102777:	5f                   	pop    %edi
  102778:	5d                   	pop    %ebp
  102779:	c3                   	ret    

0010277a <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  10277a:	55                   	push   %ebp
  10277b:	89 e5                	mov    %esp,%ebp
  10277d:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  102780:	8b 45 08             	mov    0x8(%ebp),%eax
  102783:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  102786:	eb 21                	jmp    1027a9 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
  102788:	8b 45 0c             	mov    0xc(%ebp),%eax
  10278b:	0f b6 10             	movzbl (%eax),%edx
  10278e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102791:	88 10                	mov    %dl,(%eax)
  102793:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102796:	0f b6 00             	movzbl (%eax),%eax
  102799:	84 c0                	test   %al,%al
  10279b:	74 04                	je     1027a1 <strncpy+0x27>
            src ++;
  10279d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
  1027a1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  1027a5:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    while (len > 0) {
  1027a9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1027ad:	75 d9                	jne    102788 <strncpy+0xe>
    }
    return dst;
  1027af:	8b 45 08             	mov    0x8(%ebp),%eax
}
  1027b2:	c9                   	leave  
  1027b3:	c3                   	ret    

001027b4 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  1027b4:	55                   	push   %ebp
  1027b5:	89 e5                	mov    %esp,%ebp
  1027b7:	57                   	push   %edi
  1027b8:	56                   	push   %esi
  1027b9:	83 ec 20             	sub    $0x20,%esp
  1027bc:	8b 45 08             	mov    0x8(%ebp),%eax
  1027bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1027c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1027c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  1027c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1027cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1027ce:	89 d1                	mov    %edx,%ecx
  1027d0:	89 c2                	mov    %eax,%edx
  1027d2:	89 ce                	mov    %ecx,%esi
  1027d4:	89 d7                	mov    %edx,%edi
  1027d6:	ac                   	lods   %ds:(%esi),%al
  1027d7:	ae                   	scas   %es:(%edi),%al
  1027d8:	75 08                	jne    1027e2 <strcmp+0x2e>
  1027da:	84 c0                	test   %al,%al
  1027dc:	75 f8                	jne    1027d6 <strcmp+0x22>
  1027de:	31 c0                	xor    %eax,%eax
  1027e0:	eb 04                	jmp    1027e6 <strcmp+0x32>
  1027e2:	19 c0                	sbb    %eax,%eax
  1027e4:	0c 01                	or     $0x1,%al
  1027e6:	89 fa                	mov    %edi,%edx
  1027e8:	89 f1                	mov    %esi,%ecx
  1027ea:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1027ed:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  1027f0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  1027f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  1027f6:	83 c4 20             	add    $0x20,%esp
  1027f9:	5e                   	pop    %esi
  1027fa:	5f                   	pop    %edi
  1027fb:	5d                   	pop    %ebp
  1027fc:	c3                   	ret    

001027fd <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  1027fd:	55                   	push   %ebp
  1027fe:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  102800:	eb 0c                	jmp    10280e <strncmp+0x11>
        n --, s1 ++, s2 ++;
  102802:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  102806:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  10280a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  10280e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102812:	74 1a                	je     10282e <strncmp+0x31>
  102814:	8b 45 08             	mov    0x8(%ebp),%eax
  102817:	0f b6 00             	movzbl (%eax),%eax
  10281a:	84 c0                	test   %al,%al
  10281c:	74 10                	je     10282e <strncmp+0x31>
  10281e:	8b 45 08             	mov    0x8(%ebp),%eax
  102821:	0f b6 10             	movzbl (%eax),%edx
  102824:	8b 45 0c             	mov    0xc(%ebp),%eax
  102827:	0f b6 00             	movzbl (%eax),%eax
  10282a:	38 c2                	cmp    %al,%dl
  10282c:	74 d4                	je     102802 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  10282e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102832:	74 18                	je     10284c <strncmp+0x4f>
  102834:	8b 45 08             	mov    0x8(%ebp),%eax
  102837:	0f b6 00             	movzbl (%eax),%eax
  10283a:	0f b6 d0             	movzbl %al,%edx
  10283d:	8b 45 0c             	mov    0xc(%ebp),%eax
  102840:	0f b6 00             	movzbl (%eax),%eax
  102843:	0f b6 c0             	movzbl %al,%eax
  102846:	29 c2                	sub    %eax,%edx
  102848:	89 d0                	mov    %edx,%eax
  10284a:	eb 05                	jmp    102851 <strncmp+0x54>
  10284c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102851:	5d                   	pop    %ebp
  102852:	c3                   	ret    

00102853 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  102853:	55                   	push   %ebp
  102854:	89 e5                	mov    %esp,%ebp
  102856:	83 ec 04             	sub    $0x4,%esp
  102859:	8b 45 0c             	mov    0xc(%ebp),%eax
  10285c:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  10285f:	eb 14                	jmp    102875 <strchr+0x22>
        if (*s == c) {
  102861:	8b 45 08             	mov    0x8(%ebp),%eax
  102864:	0f b6 00             	movzbl (%eax),%eax
  102867:	3a 45 fc             	cmp    -0x4(%ebp),%al
  10286a:	75 05                	jne    102871 <strchr+0x1e>
            return (char *)s;
  10286c:	8b 45 08             	mov    0x8(%ebp),%eax
  10286f:	eb 13                	jmp    102884 <strchr+0x31>
        }
        s ++;
  102871:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
  102875:	8b 45 08             	mov    0x8(%ebp),%eax
  102878:	0f b6 00             	movzbl (%eax),%eax
  10287b:	84 c0                	test   %al,%al
  10287d:	75 e2                	jne    102861 <strchr+0xe>
    }
    return NULL;
  10287f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102884:	c9                   	leave  
  102885:	c3                   	ret    

00102886 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  102886:	55                   	push   %ebp
  102887:	89 e5                	mov    %esp,%ebp
  102889:	83 ec 04             	sub    $0x4,%esp
  10288c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10288f:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  102892:	eb 11                	jmp    1028a5 <strfind+0x1f>
        if (*s == c) {
  102894:	8b 45 08             	mov    0x8(%ebp),%eax
  102897:	0f b6 00             	movzbl (%eax),%eax
  10289a:	3a 45 fc             	cmp    -0x4(%ebp),%al
  10289d:	75 02                	jne    1028a1 <strfind+0x1b>
            break;
  10289f:	eb 0e                	jmp    1028af <strfind+0x29>
        }
        s ++;
  1028a1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
  1028a5:	8b 45 08             	mov    0x8(%ebp),%eax
  1028a8:	0f b6 00             	movzbl (%eax),%eax
  1028ab:	84 c0                	test   %al,%al
  1028ad:	75 e5                	jne    102894 <strfind+0xe>
    }
    return (char *)s;
  1028af:	8b 45 08             	mov    0x8(%ebp),%eax
}
  1028b2:	c9                   	leave  
  1028b3:	c3                   	ret    

001028b4 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  1028b4:	55                   	push   %ebp
  1028b5:	89 e5                	mov    %esp,%ebp
  1028b7:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  1028ba:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  1028c1:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  1028c8:	eb 04                	jmp    1028ce <strtol+0x1a>
        s ++;
  1028ca:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  1028ce:	8b 45 08             	mov    0x8(%ebp),%eax
  1028d1:	0f b6 00             	movzbl (%eax),%eax
  1028d4:	3c 20                	cmp    $0x20,%al
  1028d6:	74 f2                	je     1028ca <strtol+0x16>
  1028d8:	8b 45 08             	mov    0x8(%ebp),%eax
  1028db:	0f b6 00             	movzbl (%eax),%eax
  1028de:	3c 09                	cmp    $0x9,%al
  1028e0:	74 e8                	je     1028ca <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
  1028e2:	8b 45 08             	mov    0x8(%ebp),%eax
  1028e5:	0f b6 00             	movzbl (%eax),%eax
  1028e8:	3c 2b                	cmp    $0x2b,%al
  1028ea:	75 06                	jne    1028f2 <strtol+0x3e>
        s ++;
  1028ec:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  1028f0:	eb 15                	jmp    102907 <strtol+0x53>
    }
    else if (*s == '-') {
  1028f2:	8b 45 08             	mov    0x8(%ebp),%eax
  1028f5:	0f b6 00             	movzbl (%eax),%eax
  1028f8:	3c 2d                	cmp    $0x2d,%al
  1028fa:	75 0b                	jne    102907 <strtol+0x53>
        s ++, neg = 1;
  1028fc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  102900:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  102907:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10290b:	74 06                	je     102913 <strtol+0x5f>
  10290d:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  102911:	75 24                	jne    102937 <strtol+0x83>
  102913:	8b 45 08             	mov    0x8(%ebp),%eax
  102916:	0f b6 00             	movzbl (%eax),%eax
  102919:	3c 30                	cmp    $0x30,%al
  10291b:	75 1a                	jne    102937 <strtol+0x83>
  10291d:	8b 45 08             	mov    0x8(%ebp),%eax
  102920:	83 c0 01             	add    $0x1,%eax
  102923:	0f b6 00             	movzbl (%eax),%eax
  102926:	3c 78                	cmp    $0x78,%al
  102928:	75 0d                	jne    102937 <strtol+0x83>
        s += 2, base = 16;
  10292a:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  10292e:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  102935:	eb 2a                	jmp    102961 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
  102937:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10293b:	75 17                	jne    102954 <strtol+0xa0>
  10293d:	8b 45 08             	mov    0x8(%ebp),%eax
  102940:	0f b6 00             	movzbl (%eax),%eax
  102943:	3c 30                	cmp    $0x30,%al
  102945:	75 0d                	jne    102954 <strtol+0xa0>
        s ++, base = 8;
  102947:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  10294b:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  102952:	eb 0d                	jmp    102961 <strtol+0xad>
    }
    else if (base == 0) {
  102954:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102958:	75 07                	jne    102961 <strtol+0xad>
        base = 10;
  10295a:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  102961:	8b 45 08             	mov    0x8(%ebp),%eax
  102964:	0f b6 00             	movzbl (%eax),%eax
  102967:	3c 2f                	cmp    $0x2f,%al
  102969:	7e 1b                	jle    102986 <strtol+0xd2>
  10296b:	8b 45 08             	mov    0x8(%ebp),%eax
  10296e:	0f b6 00             	movzbl (%eax),%eax
  102971:	3c 39                	cmp    $0x39,%al
  102973:	7f 11                	jg     102986 <strtol+0xd2>
            dig = *s - '0';
  102975:	8b 45 08             	mov    0x8(%ebp),%eax
  102978:	0f b6 00             	movzbl (%eax),%eax
  10297b:	0f be c0             	movsbl %al,%eax
  10297e:	83 e8 30             	sub    $0x30,%eax
  102981:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102984:	eb 48                	jmp    1029ce <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
  102986:	8b 45 08             	mov    0x8(%ebp),%eax
  102989:	0f b6 00             	movzbl (%eax),%eax
  10298c:	3c 60                	cmp    $0x60,%al
  10298e:	7e 1b                	jle    1029ab <strtol+0xf7>
  102990:	8b 45 08             	mov    0x8(%ebp),%eax
  102993:	0f b6 00             	movzbl (%eax),%eax
  102996:	3c 7a                	cmp    $0x7a,%al
  102998:	7f 11                	jg     1029ab <strtol+0xf7>
            dig = *s - 'a' + 10;
  10299a:	8b 45 08             	mov    0x8(%ebp),%eax
  10299d:	0f b6 00             	movzbl (%eax),%eax
  1029a0:	0f be c0             	movsbl %al,%eax
  1029a3:	83 e8 57             	sub    $0x57,%eax
  1029a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1029a9:	eb 23                	jmp    1029ce <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  1029ab:	8b 45 08             	mov    0x8(%ebp),%eax
  1029ae:	0f b6 00             	movzbl (%eax),%eax
  1029b1:	3c 40                	cmp    $0x40,%al
  1029b3:	7e 3d                	jle    1029f2 <strtol+0x13e>
  1029b5:	8b 45 08             	mov    0x8(%ebp),%eax
  1029b8:	0f b6 00             	movzbl (%eax),%eax
  1029bb:	3c 5a                	cmp    $0x5a,%al
  1029bd:	7f 33                	jg     1029f2 <strtol+0x13e>
            dig = *s - 'A' + 10;
  1029bf:	8b 45 08             	mov    0x8(%ebp),%eax
  1029c2:	0f b6 00             	movzbl (%eax),%eax
  1029c5:	0f be c0             	movsbl %al,%eax
  1029c8:	83 e8 37             	sub    $0x37,%eax
  1029cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  1029ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1029d1:	3b 45 10             	cmp    0x10(%ebp),%eax
  1029d4:	7c 02                	jl     1029d8 <strtol+0x124>
            break;
  1029d6:	eb 1a                	jmp    1029f2 <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
  1029d8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  1029dc:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1029df:	0f af 45 10          	imul   0x10(%ebp),%eax
  1029e3:	89 c2                	mov    %eax,%edx
  1029e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1029e8:	01 d0                	add    %edx,%eax
  1029ea:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
  1029ed:	e9 6f ff ff ff       	jmp    102961 <strtol+0xad>

    if (endptr) {
  1029f2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1029f6:	74 08                	je     102a00 <strtol+0x14c>
        *endptr = (char *) s;
  1029f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1029fb:	8b 55 08             	mov    0x8(%ebp),%edx
  1029fe:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  102a00:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  102a04:	74 07                	je     102a0d <strtol+0x159>
  102a06:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102a09:	f7 d8                	neg    %eax
  102a0b:	eb 03                	jmp    102a10 <strtol+0x15c>
  102a0d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  102a10:	c9                   	leave  
  102a11:	c3                   	ret    

00102a12 <memset>:
 * @n:        number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  102a12:	55                   	push   %ebp
  102a13:	89 e5                	mov    %esp,%ebp
  102a15:	57                   	push   %edi
  102a16:	83 ec 24             	sub    $0x24,%esp
  102a19:	8b 45 0c             	mov    0xc(%ebp),%eax
  102a1c:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  102a1f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  102a23:	8b 55 08             	mov    0x8(%ebp),%edx
  102a26:	89 55 f8             	mov    %edx,-0x8(%ebp)
  102a29:	88 45 f7             	mov    %al,-0x9(%ebp)
  102a2c:	8b 45 10             	mov    0x10(%ebp),%eax
  102a2f:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  102a32:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  102a35:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  102a39:	8b 55 f8             	mov    -0x8(%ebp),%edx
  102a3c:	89 d7                	mov    %edx,%edi
  102a3e:	f3 aa                	rep stos %al,%es:(%edi)
  102a40:	89 fa                	mov    %edi,%edx
  102a42:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  102a45:	89 55 e8             	mov    %edx,-0x18(%ebp)
            "rep; stosb;"
            : "=&c" (d0), "=&D" (d1)
            : "0" (n), "a" (c), "1" (s)
            : "memory");
    return s;
  102a48:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  102a4b:	83 c4 24             	add    $0x24,%esp
  102a4e:	5f                   	pop    %edi
  102a4f:	5d                   	pop    %ebp
  102a50:	c3                   	ret    

00102a51 <memmove>:
 * @n:        number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  102a51:	55                   	push   %ebp
  102a52:	89 e5                	mov    %esp,%ebp
  102a54:	57                   	push   %edi
  102a55:	56                   	push   %esi
  102a56:	53                   	push   %ebx
  102a57:	83 ec 30             	sub    $0x30,%esp
  102a5a:	8b 45 08             	mov    0x8(%ebp),%eax
  102a5d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102a60:	8b 45 0c             	mov    0xc(%ebp),%eax
  102a63:	89 45 ec             	mov    %eax,-0x14(%ebp)
  102a66:	8b 45 10             	mov    0x10(%ebp),%eax
  102a69:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  102a6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102a6f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  102a72:	73 42                	jae    102ab6 <memmove+0x65>
  102a74:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102a77:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  102a7a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102a7d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102a80:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102a83:	89 45 dc             	mov    %eax,-0x24(%ebp)
            "andl $3, %%ecx;"
            "jz 1f;"
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  102a86:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102a89:	c1 e8 02             	shr    $0x2,%eax
  102a8c:	89 c1                	mov    %eax,%ecx
    asm volatile (
  102a8e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102a91:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102a94:	89 d7                	mov    %edx,%edi
  102a96:	89 c6                	mov    %eax,%esi
  102a98:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  102a9a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  102a9d:	83 e1 03             	and    $0x3,%ecx
  102aa0:	74 02                	je     102aa4 <memmove+0x53>
  102aa2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  102aa4:	89 f0                	mov    %esi,%eax
  102aa6:	89 fa                	mov    %edi,%edx
  102aa8:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  102aab:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  102aae:	89 45 d0             	mov    %eax,-0x30(%ebp)
            : "memory");
    return dst;
  102ab1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102ab4:	eb 36                	jmp    102aec <memmove+0x9b>
            : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  102ab6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102ab9:	8d 50 ff             	lea    -0x1(%eax),%edx
  102abc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102abf:	01 c2                	add    %eax,%edx
  102ac1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102ac4:	8d 48 ff             	lea    -0x1(%eax),%ecx
  102ac7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102aca:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  102acd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102ad0:	89 c1                	mov    %eax,%ecx
  102ad2:	89 d8                	mov    %ebx,%eax
  102ad4:	89 d6                	mov    %edx,%esi
  102ad6:	89 c7                	mov    %eax,%edi
  102ad8:	fd                   	std    
  102ad9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  102adb:	fc                   	cld    
  102adc:	89 f8                	mov    %edi,%eax
  102ade:	89 f2                	mov    %esi,%edx
  102ae0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  102ae3:	89 55 c8             	mov    %edx,-0x38(%ebp)
  102ae6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  102ae9:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  102aec:	83 c4 30             	add    $0x30,%esp
  102aef:	5b                   	pop    %ebx
  102af0:	5e                   	pop    %esi
  102af1:	5f                   	pop    %edi
  102af2:	5d                   	pop    %ebp
  102af3:	c3                   	ret    

00102af4 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  102af4:	55                   	push   %ebp
  102af5:	89 e5                	mov    %esp,%ebp
  102af7:	57                   	push   %edi
  102af8:	56                   	push   %esi
  102af9:	83 ec 20             	sub    $0x20,%esp
  102afc:	8b 45 08             	mov    0x8(%ebp),%eax
  102aff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102b02:	8b 45 0c             	mov    0xc(%ebp),%eax
  102b05:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102b08:	8b 45 10             	mov    0x10(%ebp),%eax
  102b0b:	89 45 ec             	mov    %eax,-0x14(%ebp)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  102b0e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102b11:	c1 e8 02             	shr    $0x2,%eax
  102b14:	89 c1                	mov    %eax,%ecx
    asm volatile (
  102b16:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102b19:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102b1c:	89 d7                	mov    %edx,%edi
  102b1e:	89 c6                	mov    %eax,%esi
  102b20:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  102b22:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  102b25:	83 e1 03             	and    $0x3,%ecx
  102b28:	74 02                	je     102b2c <memcpy+0x38>
  102b2a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  102b2c:	89 f0                	mov    %esi,%eax
  102b2e:	89 fa                	mov    %edi,%edx
  102b30:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  102b33:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  102b36:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  102b39:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  102b3c:	83 c4 20             	add    $0x20,%esp
  102b3f:	5e                   	pop    %esi
  102b40:	5f                   	pop    %edi
  102b41:	5d                   	pop    %ebp
  102b42:	c3                   	ret    

00102b43 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  102b43:	55                   	push   %ebp
  102b44:	89 e5                	mov    %esp,%ebp
  102b46:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  102b49:	8b 45 08             	mov    0x8(%ebp),%eax
  102b4c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  102b4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  102b52:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  102b55:	eb 30                	jmp    102b87 <memcmp+0x44>
        if (*s1 != *s2) {
  102b57:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102b5a:	0f b6 10             	movzbl (%eax),%edx
  102b5d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102b60:	0f b6 00             	movzbl (%eax),%eax
  102b63:	38 c2                	cmp    %al,%dl
  102b65:	74 18                	je     102b7f <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  102b67:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102b6a:	0f b6 00             	movzbl (%eax),%eax
  102b6d:	0f b6 d0             	movzbl %al,%edx
  102b70:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102b73:	0f b6 00             	movzbl (%eax),%eax
  102b76:	0f b6 c0             	movzbl %al,%eax
  102b79:	29 c2                	sub    %eax,%edx
  102b7b:	89 d0                	mov    %edx,%eax
  102b7d:	eb 1a                	jmp    102b99 <memcmp+0x56>
        }
        s1 ++, s2 ++;
  102b7f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  102b83:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
    while (n -- > 0) {
  102b87:	8b 45 10             	mov    0x10(%ebp),%eax
  102b8a:	8d 50 ff             	lea    -0x1(%eax),%edx
  102b8d:	89 55 10             	mov    %edx,0x10(%ebp)
  102b90:	85 c0                	test   %eax,%eax
  102b92:	75 c3                	jne    102b57 <memcmp+0x14>
    }
    return 0;
  102b94:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102b99:	c9                   	leave  
  102b9a:	c3                   	ret    

00102b9b <printnum>:
 * @width:         maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:        character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  102b9b:	55                   	push   %ebp
  102b9c:	89 e5                	mov    %esp,%ebp
  102b9e:	83 ec 58             	sub    $0x58,%esp
  102ba1:	8b 45 10             	mov    0x10(%ebp),%eax
  102ba4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102ba7:	8b 45 14             	mov    0x14(%ebp),%eax
  102baa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  102bad:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102bb0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102bb3:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102bb6:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  102bb9:	8b 45 18             	mov    0x18(%ebp),%eax
  102bbc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  102bbf:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102bc2:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102bc5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102bc8:	89 55 f0             	mov    %edx,-0x10(%ebp)
  102bcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102bce:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102bd1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  102bd5:	74 1c                	je     102bf3 <printnum+0x58>
  102bd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102bda:	ba 00 00 00 00       	mov    $0x0,%edx
  102bdf:	f7 75 e4             	divl   -0x1c(%ebp)
  102be2:	89 55 f4             	mov    %edx,-0xc(%ebp)
  102be5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102be8:	ba 00 00 00 00       	mov    $0x0,%edx
  102bed:	f7 75 e4             	divl   -0x1c(%ebp)
  102bf0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102bf3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102bf6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102bf9:	f7 75 e4             	divl   -0x1c(%ebp)
  102bfc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102bff:	89 55 dc             	mov    %edx,-0x24(%ebp)
  102c02:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102c05:	8b 55 f0             	mov    -0x10(%ebp),%edx
  102c08:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102c0b:	89 55 ec             	mov    %edx,-0x14(%ebp)
  102c0e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102c11:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  102c14:	8b 45 18             	mov    0x18(%ebp),%eax
  102c17:	ba 00 00 00 00       	mov    $0x0,%edx
  102c1c:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  102c1f:	77 56                	ja     102c77 <printnum+0xdc>
  102c21:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  102c24:	72 05                	jb     102c2b <printnum+0x90>
  102c26:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  102c29:	77 4c                	ja     102c77 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  102c2b:	8b 45 1c             	mov    0x1c(%ebp),%eax
  102c2e:	8d 50 ff             	lea    -0x1(%eax),%edx
  102c31:	8b 45 20             	mov    0x20(%ebp),%eax
  102c34:	89 44 24 18          	mov    %eax,0x18(%esp)
  102c38:	89 54 24 14          	mov    %edx,0x14(%esp)
  102c3c:	8b 45 18             	mov    0x18(%ebp),%eax
  102c3f:	89 44 24 10          	mov    %eax,0x10(%esp)
  102c43:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102c46:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102c49:	89 44 24 08          	mov    %eax,0x8(%esp)
  102c4d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  102c51:	8b 45 0c             	mov    0xc(%ebp),%eax
  102c54:	89 44 24 04          	mov    %eax,0x4(%esp)
  102c58:	8b 45 08             	mov    0x8(%ebp),%eax
  102c5b:	89 04 24             	mov    %eax,(%esp)
  102c5e:	e8 38 ff ff ff       	call   102b9b <printnum>
  102c63:	eb 1c                	jmp    102c81 <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  102c65:	8b 45 0c             	mov    0xc(%ebp),%eax
  102c68:	89 44 24 04          	mov    %eax,0x4(%esp)
  102c6c:	8b 45 20             	mov    0x20(%ebp),%eax
  102c6f:	89 04 24             	mov    %eax,(%esp)
  102c72:	8b 45 08             	mov    0x8(%ebp),%eax
  102c75:	ff d0                	call   *%eax
        while (-- width > 0)
  102c77:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  102c7b:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  102c7f:	7f e4                	jg     102c65 <printnum+0xca>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  102c81:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102c84:	05 90 39 10 00       	add    $0x103990,%eax
  102c89:	0f b6 00             	movzbl (%eax),%eax
  102c8c:	0f be c0             	movsbl %al,%eax
  102c8f:	8b 55 0c             	mov    0xc(%ebp),%edx
  102c92:	89 54 24 04          	mov    %edx,0x4(%esp)
  102c96:	89 04 24             	mov    %eax,(%esp)
  102c99:	8b 45 08             	mov    0x8(%ebp),%eax
  102c9c:	ff d0                	call   *%eax
}
  102c9e:	c9                   	leave  
  102c9f:	c3                   	ret    

00102ca0 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:            a varargs list pointer
 * @lflag:        determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  102ca0:	55                   	push   %ebp
  102ca1:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  102ca3:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  102ca7:	7e 14                	jle    102cbd <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  102ca9:	8b 45 08             	mov    0x8(%ebp),%eax
  102cac:	8b 00                	mov    (%eax),%eax
  102cae:	8d 48 08             	lea    0x8(%eax),%ecx
  102cb1:	8b 55 08             	mov    0x8(%ebp),%edx
  102cb4:	89 0a                	mov    %ecx,(%edx)
  102cb6:	8b 50 04             	mov    0x4(%eax),%edx
  102cb9:	8b 00                	mov    (%eax),%eax
  102cbb:	eb 30                	jmp    102ced <getuint+0x4d>
    }
    else if (lflag) {
  102cbd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102cc1:	74 16                	je     102cd9 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  102cc3:	8b 45 08             	mov    0x8(%ebp),%eax
  102cc6:	8b 00                	mov    (%eax),%eax
  102cc8:	8d 48 04             	lea    0x4(%eax),%ecx
  102ccb:	8b 55 08             	mov    0x8(%ebp),%edx
  102cce:	89 0a                	mov    %ecx,(%edx)
  102cd0:	8b 00                	mov    (%eax),%eax
  102cd2:	ba 00 00 00 00       	mov    $0x0,%edx
  102cd7:	eb 14                	jmp    102ced <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  102cd9:	8b 45 08             	mov    0x8(%ebp),%eax
  102cdc:	8b 00                	mov    (%eax),%eax
  102cde:	8d 48 04             	lea    0x4(%eax),%ecx
  102ce1:	8b 55 08             	mov    0x8(%ebp),%edx
  102ce4:	89 0a                	mov    %ecx,(%edx)
  102ce6:	8b 00                	mov    (%eax),%eax
  102ce8:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  102ced:	5d                   	pop    %ebp
  102cee:	c3                   	ret    

00102cef <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:            a varargs list pointer
 * @lflag:        determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  102cef:	55                   	push   %ebp
  102cf0:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  102cf2:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  102cf6:	7e 14                	jle    102d0c <getint+0x1d>
        return va_arg(*ap, long long);
  102cf8:	8b 45 08             	mov    0x8(%ebp),%eax
  102cfb:	8b 00                	mov    (%eax),%eax
  102cfd:	8d 48 08             	lea    0x8(%eax),%ecx
  102d00:	8b 55 08             	mov    0x8(%ebp),%edx
  102d03:	89 0a                	mov    %ecx,(%edx)
  102d05:	8b 50 04             	mov    0x4(%eax),%edx
  102d08:	8b 00                	mov    (%eax),%eax
  102d0a:	eb 28                	jmp    102d34 <getint+0x45>
    }
    else if (lflag) {
  102d0c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102d10:	74 12                	je     102d24 <getint+0x35>
        return va_arg(*ap, long);
  102d12:	8b 45 08             	mov    0x8(%ebp),%eax
  102d15:	8b 00                	mov    (%eax),%eax
  102d17:	8d 48 04             	lea    0x4(%eax),%ecx
  102d1a:	8b 55 08             	mov    0x8(%ebp),%edx
  102d1d:	89 0a                	mov    %ecx,(%edx)
  102d1f:	8b 00                	mov    (%eax),%eax
  102d21:	99                   	cltd   
  102d22:	eb 10                	jmp    102d34 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  102d24:	8b 45 08             	mov    0x8(%ebp),%eax
  102d27:	8b 00                	mov    (%eax),%eax
  102d29:	8d 48 04             	lea    0x4(%eax),%ecx
  102d2c:	8b 55 08             	mov    0x8(%ebp),%edx
  102d2f:	89 0a                	mov    %ecx,(%edx)
  102d31:	8b 00                	mov    (%eax),%eax
  102d33:	99                   	cltd   
    }
}
  102d34:	5d                   	pop    %ebp
  102d35:	c3                   	ret    

00102d36 <printfmt>:
 * @putch:        specified putch function, print a single character
 * @putdat:        used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  102d36:	55                   	push   %ebp
  102d37:	89 e5                	mov    %esp,%ebp
  102d39:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  102d3c:	8d 45 14             	lea    0x14(%ebp),%eax
  102d3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  102d42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d45:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102d49:	8b 45 10             	mov    0x10(%ebp),%eax
  102d4c:	89 44 24 08          	mov    %eax,0x8(%esp)
  102d50:	8b 45 0c             	mov    0xc(%ebp),%eax
  102d53:	89 44 24 04          	mov    %eax,0x4(%esp)
  102d57:	8b 45 08             	mov    0x8(%ebp),%eax
  102d5a:	89 04 24             	mov    %eax,(%esp)
  102d5d:	e8 02 00 00 00       	call   102d64 <vprintfmt>
    va_end(ap);
}
  102d62:	c9                   	leave  
  102d63:	c3                   	ret    

00102d64 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  102d64:	55                   	push   %ebp
  102d65:	89 e5                	mov    %esp,%ebp
  102d67:	56                   	push   %esi
  102d68:	53                   	push   %ebx
  102d69:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  102d6c:	eb 18                	jmp    102d86 <vprintfmt+0x22>
            if (ch == '\0') {
  102d6e:	85 db                	test   %ebx,%ebx
  102d70:	75 05                	jne    102d77 <vprintfmt+0x13>
                return;
  102d72:	e9 d1 03 00 00       	jmp    103148 <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
  102d77:	8b 45 0c             	mov    0xc(%ebp),%eax
  102d7a:	89 44 24 04          	mov    %eax,0x4(%esp)
  102d7e:	89 1c 24             	mov    %ebx,(%esp)
  102d81:	8b 45 08             	mov    0x8(%ebp),%eax
  102d84:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  102d86:	8b 45 10             	mov    0x10(%ebp),%eax
  102d89:	8d 50 01             	lea    0x1(%eax),%edx
  102d8c:	89 55 10             	mov    %edx,0x10(%ebp)
  102d8f:	0f b6 00             	movzbl (%eax),%eax
  102d92:	0f b6 d8             	movzbl %al,%ebx
  102d95:	83 fb 25             	cmp    $0x25,%ebx
  102d98:	75 d4                	jne    102d6e <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
  102d9a:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  102d9e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  102da5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102da8:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  102dab:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102db2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102db5:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  102db8:	8b 45 10             	mov    0x10(%ebp),%eax
  102dbb:	8d 50 01             	lea    0x1(%eax),%edx
  102dbe:	89 55 10             	mov    %edx,0x10(%ebp)
  102dc1:	0f b6 00             	movzbl (%eax),%eax
  102dc4:	0f b6 d8             	movzbl %al,%ebx
  102dc7:	8d 43 dd             	lea    -0x23(%ebx),%eax
  102dca:	83 f8 55             	cmp    $0x55,%eax
  102dcd:	0f 87 44 03 00 00    	ja     103117 <vprintfmt+0x3b3>
  102dd3:	8b 04 85 b4 39 10 00 	mov    0x1039b4(,%eax,4),%eax
  102dda:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  102ddc:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  102de0:	eb d6                	jmp    102db8 <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  102de2:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  102de6:	eb d0                	jmp    102db8 <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  102de8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  102def:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102df2:	89 d0                	mov    %edx,%eax
  102df4:	c1 e0 02             	shl    $0x2,%eax
  102df7:	01 d0                	add    %edx,%eax
  102df9:	01 c0                	add    %eax,%eax
  102dfb:	01 d8                	add    %ebx,%eax
  102dfd:	83 e8 30             	sub    $0x30,%eax
  102e00:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  102e03:	8b 45 10             	mov    0x10(%ebp),%eax
  102e06:	0f b6 00             	movzbl (%eax),%eax
  102e09:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  102e0c:	83 fb 2f             	cmp    $0x2f,%ebx
  102e0f:	7e 0b                	jle    102e1c <vprintfmt+0xb8>
  102e11:	83 fb 39             	cmp    $0x39,%ebx
  102e14:	7f 06                	jg     102e1c <vprintfmt+0xb8>
            for (precision = 0; ; ++ fmt) {
  102e16:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                    break;
                }
            }
  102e1a:	eb d3                	jmp    102def <vprintfmt+0x8b>
            goto process_precision;
  102e1c:	eb 33                	jmp    102e51 <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
  102e1e:	8b 45 14             	mov    0x14(%ebp),%eax
  102e21:	8d 50 04             	lea    0x4(%eax),%edx
  102e24:	89 55 14             	mov    %edx,0x14(%ebp)
  102e27:	8b 00                	mov    (%eax),%eax
  102e29:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  102e2c:	eb 23                	jmp    102e51 <vprintfmt+0xed>

        case '.':
            if (width < 0)
  102e2e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102e32:	79 0c                	jns    102e40 <vprintfmt+0xdc>
                width = 0;
  102e34:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  102e3b:	e9 78 ff ff ff       	jmp    102db8 <vprintfmt+0x54>
  102e40:	e9 73 ff ff ff       	jmp    102db8 <vprintfmt+0x54>

        case '#':
            altflag = 1;
  102e45:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  102e4c:	e9 67 ff ff ff       	jmp    102db8 <vprintfmt+0x54>

        process_precision:
            if (width < 0)
  102e51:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102e55:	79 12                	jns    102e69 <vprintfmt+0x105>
                width = precision, precision = -1;
  102e57:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102e5a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102e5d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  102e64:	e9 4f ff ff ff       	jmp    102db8 <vprintfmt+0x54>
  102e69:	e9 4a ff ff ff       	jmp    102db8 <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  102e6e:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
  102e72:	e9 41 ff ff ff       	jmp    102db8 <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  102e77:	8b 45 14             	mov    0x14(%ebp),%eax
  102e7a:	8d 50 04             	lea    0x4(%eax),%edx
  102e7d:	89 55 14             	mov    %edx,0x14(%ebp)
  102e80:	8b 00                	mov    (%eax),%eax
  102e82:	8b 55 0c             	mov    0xc(%ebp),%edx
  102e85:	89 54 24 04          	mov    %edx,0x4(%esp)
  102e89:	89 04 24             	mov    %eax,(%esp)
  102e8c:	8b 45 08             	mov    0x8(%ebp),%eax
  102e8f:	ff d0                	call   *%eax
            break;
  102e91:	e9 ac 02 00 00       	jmp    103142 <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
  102e96:	8b 45 14             	mov    0x14(%ebp),%eax
  102e99:	8d 50 04             	lea    0x4(%eax),%edx
  102e9c:	89 55 14             	mov    %edx,0x14(%ebp)
  102e9f:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  102ea1:	85 db                	test   %ebx,%ebx
  102ea3:	79 02                	jns    102ea7 <vprintfmt+0x143>
                err = -err;
  102ea5:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  102ea7:	83 fb 06             	cmp    $0x6,%ebx
  102eaa:	7f 0b                	jg     102eb7 <vprintfmt+0x153>
  102eac:	8b 34 9d 74 39 10 00 	mov    0x103974(,%ebx,4),%esi
  102eb3:	85 f6                	test   %esi,%esi
  102eb5:	75 23                	jne    102eda <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
  102eb7:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  102ebb:	c7 44 24 08 a1 39 10 	movl   $0x1039a1,0x8(%esp)
  102ec2:	00 
  102ec3:	8b 45 0c             	mov    0xc(%ebp),%eax
  102ec6:	89 44 24 04          	mov    %eax,0x4(%esp)
  102eca:	8b 45 08             	mov    0x8(%ebp),%eax
  102ecd:	89 04 24             	mov    %eax,(%esp)
  102ed0:	e8 61 fe ff ff       	call   102d36 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  102ed5:	e9 68 02 00 00       	jmp    103142 <vprintfmt+0x3de>
                printfmt(putch, putdat, "%s", p);
  102eda:	89 74 24 0c          	mov    %esi,0xc(%esp)
  102ede:	c7 44 24 08 aa 39 10 	movl   $0x1039aa,0x8(%esp)
  102ee5:	00 
  102ee6:	8b 45 0c             	mov    0xc(%ebp),%eax
  102ee9:	89 44 24 04          	mov    %eax,0x4(%esp)
  102eed:	8b 45 08             	mov    0x8(%ebp),%eax
  102ef0:	89 04 24             	mov    %eax,(%esp)
  102ef3:	e8 3e fe ff ff       	call   102d36 <printfmt>
            break;
  102ef8:	e9 45 02 00 00       	jmp    103142 <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  102efd:	8b 45 14             	mov    0x14(%ebp),%eax
  102f00:	8d 50 04             	lea    0x4(%eax),%edx
  102f03:	89 55 14             	mov    %edx,0x14(%ebp)
  102f06:	8b 30                	mov    (%eax),%esi
  102f08:	85 f6                	test   %esi,%esi
  102f0a:	75 05                	jne    102f11 <vprintfmt+0x1ad>
                p = "(null)";
  102f0c:	be ad 39 10 00       	mov    $0x1039ad,%esi
            }
            if (width > 0 && padc != '-') {
  102f11:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102f15:	7e 3e                	jle    102f55 <vprintfmt+0x1f1>
  102f17:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  102f1b:	74 38                	je     102f55 <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  102f1d:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  102f20:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102f23:	89 44 24 04          	mov    %eax,0x4(%esp)
  102f27:	89 34 24             	mov    %esi,(%esp)
  102f2a:	e8 dc f7 ff ff       	call   10270b <strnlen>
  102f2f:	29 c3                	sub    %eax,%ebx
  102f31:	89 d8                	mov    %ebx,%eax
  102f33:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102f36:	eb 17                	jmp    102f4f <vprintfmt+0x1eb>
                    putch(padc, putdat);
  102f38:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  102f3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  102f3f:	89 54 24 04          	mov    %edx,0x4(%esp)
  102f43:	89 04 24             	mov    %eax,(%esp)
  102f46:	8b 45 08             	mov    0x8(%ebp),%eax
  102f49:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
  102f4b:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  102f4f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102f53:	7f e3                	jg     102f38 <vprintfmt+0x1d4>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  102f55:	eb 38                	jmp    102f8f <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
  102f57:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  102f5b:	74 1f                	je     102f7c <vprintfmt+0x218>
  102f5d:	83 fb 1f             	cmp    $0x1f,%ebx
  102f60:	7e 05                	jle    102f67 <vprintfmt+0x203>
  102f62:	83 fb 7e             	cmp    $0x7e,%ebx
  102f65:	7e 15                	jle    102f7c <vprintfmt+0x218>
                    putch('?', putdat);
  102f67:	8b 45 0c             	mov    0xc(%ebp),%eax
  102f6a:	89 44 24 04          	mov    %eax,0x4(%esp)
  102f6e:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  102f75:	8b 45 08             	mov    0x8(%ebp),%eax
  102f78:	ff d0                	call   *%eax
  102f7a:	eb 0f                	jmp    102f8b <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
  102f7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  102f7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  102f83:	89 1c 24             	mov    %ebx,(%esp)
  102f86:	8b 45 08             	mov    0x8(%ebp),%eax
  102f89:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  102f8b:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  102f8f:	89 f0                	mov    %esi,%eax
  102f91:	8d 70 01             	lea    0x1(%eax),%esi
  102f94:	0f b6 00             	movzbl (%eax),%eax
  102f97:	0f be d8             	movsbl %al,%ebx
  102f9a:	85 db                	test   %ebx,%ebx
  102f9c:	74 10                	je     102fae <vprintfmt+0x24a>
  102f9e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102fa2:	78 b3                	js     102f57 <vprintfmt+0x1f3>
  102fa4:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  102fa8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102fac:	79 a9                	jns    102f57 <vprintfmt+0x1f3>
                }
            }
            for (; width > 0; width --) {
  102fae:	eb 17                	jmp    102fc7 <vprintfmt+0x263>
                putch(' ', putdat);
  102fb0:	8b 45 0c             	mov    0xc(%ebp),%eax
  102fb3:	89 44 24 04          	mov    %eax,0x4(%esp)
  102fb7:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  102fbe:	8b 45 08             	mov    0x8(%ebp),%eax
  102fc1:	ff d0                	call   *%eax
            for (; width > 0; width --) {
  102fc3:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  102fc7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102fcb:	7f e3                	jg     102fb0 <vprintfmt+0x24c>
            }
            break;
  102fcd:	e9 70 01 00 00       	jmp    103142 <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  102fd2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102fd5:	89 44 24 04          	mov    %eax,0x4(%esp)
  102fd9:	8d 45 14             	lea    0x14(%ebp),%eax
  102fdc:	89 04 24             	mov    %eax,(%esp)
  102fdf:	e8 0b fd ff ff       	call   102cef <getint>
  102fe4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102fe7:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  102fea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102fed:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102ff0:	85 d2                	test   %edx,%edx
  102ff2:	79 26                	jns    10301a <vprintfmt+0x2b6>
                putch('-', putdat);
  102ff4:	8b 45 0c             	mov    0xc(%ebp),%eax
  102ff7:	89 44 24 04          	mov    %eax,0x4(%esp)
  102ffb:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  103002:	8b 45 08             	mov    0x8(%ebp),%eax
  103005:	ff d0                	call   *%eax
                num = -(long long)num;
  103007:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10300a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10300d:	f7 d8                	neg    %eax
  10300f:	83 d2 00             	adc    $0x0,%edx
  103012:	f7 da                	neg    %edx
  103014:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103017:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  10301a:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  103021:	e9 a8 00 00 00       	jmp    1030ce <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  103026:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103029:	89 44 24 04          	mov    %eax,0x4(%esp)
  10302d:	8d 45 14             	lea    0x14(%ebp),%eax
  103030:	89 04 24             	mov    %eax,(%esp)
  103033:	e8 68 fc ff ff       	call   102ca0 <getuint>
  103038:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10303b:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  10303e:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  103045:	e9 84 00 00 00       	jmp    1030ce <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  10304a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10304d:	89 44 24 04          	mov    %eax,0x4(%esp)
  103051:	8d 45 14             	lea    0x14(%ebp),%eax
  103054:	89 04 24             	mov    %eax,(%esp)
  103057:	e8 44 fc ff ff       	call   102ca0 <getuint>
  10305c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10305f:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  103062:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  103069:	eb 63                	jmp    1030ce <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
  10306b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10306e:	89 44 24 04          	mov    %eax,0x4(%esp)
  103072:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  103079:	8b 45 08             	mov    0x8(%ebp),%eax
  10307c:	ff d0                	call   *%eax
            putch('x', putdat);
  10307e:	8b 45 0c             	mov    0xc(%ebp),%eax
  103081:	89 44 24 04          	mov    %eax,0x4(%esp)
  103085:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  10308c:	8b 45 08             	mov    0x8(%ebp),%eax
  10308f:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  103091:	8b 45 14             	mov    0x14(%ebp),%eax
  103094:	8d 50 04             	lea    0x4(%eax),%edx
  103097:	89 55 14             	mov    %edx,0x14(%ebp)
  10309a:	8b 00                	mov    (%eax),%eax
  10309c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10309f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  1030a6:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  1030ad:	eb 1f                	jmp    1030ce <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  1030af:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1030b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1030b6:	8d 45 14             	lea    0x14(%ebp),%eax
  1030b9:	89 04 24             	mov    %eax,(%esp)
  1030bc:	e8 df fb ff ff       	call   102ca0 <getuint>
  1030c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1030c4:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  1030c7:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  1030ce:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  1030d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1030d5:	89 54 24 18          	mov    %edx,0x18(%esp)
  1030d9:	8b 55 e8             	mov    -0x18(%ebp),%edx
  1030dc:	89 54 24 14          	mov    %edx,0x14(%esp)
  1030e0:	89 44 24 10          	mov    %eax,0x10(%esp)
  1030e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1030e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1030ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  1030ee:	89 54 24 0c          	mov    %edx,0xc(%esp)
  1030f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1030f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  1030f9:	8b 45 08             	mov    0x8(%ebp),%eax
  1030fc:	89 04 24             	mov    %eax,(%esp)
  1030ff:	e8 97 fa ff ff       	call   102b9b <printnum>
            break;
  103104:	eb 3c                	jmp    103142 <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  103106:	8b 45 0c             	mov    0xc(%ebp),%eax
  103109:	89 44 24 04          	mov    %eax,0x4(%esp)
  10310d:	89 1c 24             	mov    %ebx,(%esp)
  103110:	8b 45 08             	mov    0x8(%ebp),%eax
  103113:	ff d0                	call   *%eax
            break;
  103115:	eb 2b                	jmp    103142 <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  103117:	8b 45 0c             	mov    0xc(%ebp),%eax
  10311a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10311e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  103125:	8b 45 08             	mov    0x8(%ebp),%eax
  103128:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  10312a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  10312e:	eb 04                	jmp    103134 <vprintfmt+0x3d0>
  103130:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  103134:	8b 45 10             	mov    0x10(%ebp),%eax
  103137:	83 e8 01             	sub    $0x1,%eax
  10313a:	0f b6 00             	movzbl (%eax),%eax
  10313d:	3c 25                	cmp    $0x25,%al
  10313f:	75 ef                	jne    103130 <vprintfmt+0x3cc>
                /* do nothing */;
            break;
  103141:	90                   	nop
        }
    }
  103142:	90                   	nop
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  103143:	e9 3e fc ff ff       	jmp    102d86 <vprintfmt+0x22>
}
  103148:	83 c4 40             	add    $0x40,%esp
  10314b:	5b                   	pop    %ebx
  10314c:	5e                   	pop    %esi
  10314d:	5d                   	pop    %ebp
  10314e:	c3                   	ret    

0010314f <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:            the character will be printed
 * @b:            the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  10314f:	55                   	push   %ebp
  103150:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  103152:	8b 45 0c             	mov    0xc(%ebp),%eax
  103155:	8b 40 08             	mov    0x8(%eax),%eax
  103158:	8d 50 01             	lea    0x1(%eax),%edx
  10315b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10315e:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  103161:	8b 45 0c             	mov    0xc(%ebp),%eax
  103164:	8b 10                	mov    (%eax),%edx
  103166:	8b 45 0c             	mov    0xc(%ebp),%eax
  103169:	8b 40 04             	mov    0x4(%eax),%eax
  10316c:	39 c2                	cmp    %eax,%edx
  10316e:	73 12                	jae    103182 <sprintputch+0x33>
        *b->buf ++ = ch;
  103170:	8b 45 0c             	mov    0xc(%ebp),%eax
  103173:	8b 00                	mov    (%eax),%eax
  103175:	8d 48 01             	lea    0x1(%eax),%ecx
  103178:	8b 55 0c             	mov    0xc(%ebp),%edx
  10317b:	89 0a                	mov    %ecx,(%edx)
  10317d:	8b 55 08             	mov    0x8(%ebp),%edx
  103180:	88 10                	mov    %dl,(%eax)
    }
}
  103182:	5d                   	pop    %ebp
  103183:	c3                   	ret    

00103184 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:        the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  103184:	55                   	push   %ebp
  103185:	89 e5                	mov    %esp,%ebp
  103187:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  10318a:	8d 45 14             	lea    0x14(%ebp),%eax
  10318d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  103190:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103193:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103197:	8b 45 10             	mov    0x10(%ebp),%eax
  10319a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10319e:	8b 45 0c             	mov    0xc(%ebp),%eax
  1031a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1031a5:	8b 45 08             	mov    0x8(%ebp),%eax
  1031a8:	89 04 24             	mov    %eax,(%esp)
  1031ab:	e8 08 00 00 00       	call   1031b8 <vsnprintf>
  1031b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  1031b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1031b6:	c9                   	leave  
  1031b7:	c3                   	ret    

001031b8 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  1031b8:	55                   	push   %ebp
  1031b9:	89 e5                	mov    %esp,%ebp
  1031bb:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  1031be:	8b 45 08             	mov    0x8(%ebp),%eax
  1031c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1031c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1031c7:	8d 50 ff             	lea    -0x1(%eax),%edx
  1031ca:	8b 45 08             	mov    0x8(%ebp),%eax
  1031cd:	01 d0                	add    %edx,%eax
  1031cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1031d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  1031d9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  1031dd:	74 0a                	je     1031e9 <vsnprintf+0x31>
  1031df:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1031e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1031e5:	39 c2                	cmp    %eax,%edx
  1031e7:	76 07                	jbe    1031f0 <vsnprintf+0x38>
        return -E_INVAL;
  1031e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  1031ee:	eb 2a                	jmp    10321a <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  1031f0:	8b 45 14             	mov    0x14(%ebp),%eax
  1031f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1031f7:	8b 45 10             	mov    0x10(%ebp),%eax
  1031fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  1031fe:	8d 45 ec             	lea    -0x14(%ebp),%eax
  103201:	89 44 24 04          	mov    %eax,0x4(%esp)
  103205:	c7 04 24 4f 31 10 00 	movl   $0x10314f,(%esp)
  10320c:	e8 53 fb ff ff       	call   102d64 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  103211:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103214:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  103217:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10321a:	c9                   	leave  
  10321b:	c3                   	ret    
