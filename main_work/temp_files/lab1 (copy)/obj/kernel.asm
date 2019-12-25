
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
  100027:	e8 5e 2c 00 00       	call   102c8a <memset>

    cons_init();                // init the console
  10002c:	e8 4f 15 00 00       	call   101580 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100031:	c7 45 f4 a0 34 10 00 	movl   $0x1034a0,-0xc(%ebp)
    cprintf("%s\n\n", message);
  100038:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10003b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10003f:	c7 04 24 bc 34 10 00 	movl   $0x1034bc,(%esp)
  100046:	e8 11 02 00 00       	call   10025c <cprintf>

    print_kerninfo();
  10004b:	e8 c3 08 00 00       	call   100913 <print_kerninfo>

    grade_backtrace();
  100050:	e8 86 00 00 00       	call   1000db <grade_backtrace>

    pmm_init();                 // init physical memory management
  100055:	e8 f7 28 00 00       	call   102951 <pmm_init>

    pic_init();                 // init interrupt controller
  10005a:	e8 58 16 00 00       	call   1016b7 <pic_init>
    idt_init();                 // init interrupt descriptor table
  10005f:	e8 b6 17 00 00       	call   10181a <idt_init>

    clock_init();               // init clock interrupt
  100064:	e8 0a 0d 00 00       	call   100d73 <clock_init>
    intr_enable();              // enable irq interrupt
  100069:	e8 84 17 00 00       	call   1017f2 <intr_enable>
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
  10008d:	e8 cf 0c 00 00       	call   100d61 <mon_backtrace>
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
  10012b:	c7 04 24 c1 34 10 00 	movl   $0x1034c1,(%esp)
  100132:	e8 25 01 00 00       	call   10025c <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  100137:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10013b:	0f b7 d0             	movzwl %ax,%edx
  10013e:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100143:	89 54 24 08          	mov    %edx,0x8(%esp)
  100147:	89 44 24 04          	mov    %eax,0x4(%esp)
  10014b:	c7 04 24 cf 34 10 00 	movl   $0x1034cf,(%esp)
  100152:	e8 05 01 00 00       	call   10025c <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  100157:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  10015b:	0f b7 d0             	movzwl %ax,%edx
  10015e:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100163:	89 54 24 08          	mov    %edx,0x8(%esp)
  100167:	89 44 24 04          	mov    %eax,0x4(%esp)
  10016b:	c7 04 24 dd 34 10 00 	movl   $0x1034dd,(%esp)
  100172:	e8 e5 00 00 00       	call   10025c <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  100177:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  10017b:	0f b7 d0             	movzwl %ax,%edx
  10017e:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100183:	89 54 24 08          	mov    %edx,0x8(%esp)
  100187:	89 44 24 04          	mov    %eax,0x4(%esp)
  10018b:	c7 04 24 eb 34 10 00 	movl   $0x1034eb,(%esp)
  100192:	e8 c5 00 00 00       	call   10025c <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  100197:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  10019b:	0f b7 d0             	movzwl %ax,%edx
  10019e:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  1001a3:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001ab:	c7 04 24 f9 34 10 00 	movl   $0x1034f9,(%esp)
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
  1001db:	c7 04 24 08 35 10 00 	movl   $0x103508,(%esp)
  1001e2:	e8 75 00 00 00       	call   10025c <cprintf>
    lab1_switch_to_user();
  1001e7:	e8 da ff ff ff       	call   1001c6 <lab1_switch_to_user>
    lab1_print_cur_status();
  1001ec:	e8 0f ff ff ff       	call   100100 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  1001f1:	c7 04 24 28 35 10 00 	movl   $0x103528,(%esp)
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
  100215:	e8 92 13 00 00       	call   1015ac <cons_putc>
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
  100252:	e8 85 2d 00 00       	call   102fdc <vprintfmt>
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
  10028e:	e8 19 13 00 00       	call   1015ac <cons_putc>
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
  1002ea:	e8 e6 12 00 00       	call   1015d5 <cons_getc>
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
  100310:	c7 04 24 47 35 10 00 	movl   $0x103547,(%esp)
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
  1003e2:	c7 04 24 4a 35 10 00 	movl   $0x10354a,(%esp)
  1003e9:	e8 6e fe ff ff       	call   10025c <cprintf>
    vcprintf(fmt, ap);
  1003ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1003f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1003f5:	8b 45 10             	mov    0x10(%ebp),%eax
  1003f8:	89 04 24             	mov    %eax,(%esp)
  1003fb:	e8 29 fe ff ff       	call   100229 <vcprintf>
    cprintf("\n");
  100400:	c7 04 24 66 35 10 00 	movl   $0x103566,(%esp)
  100407:	e8 50 fe ff ff       	call   10025c <cprintf>
    
    cprintf("stack trackback:\n");
  10040c:	c7 04 24 68 35 10 00 	movl   $0x103568,(%esp)
  100413:	e8 44 fe ff ff       	call   10025c <cprintf>
    print_stackframe();
  100418:	e8 40 06 00 00       	call   100a5d <print_stackframe>
    
    va_end(ap);

panic_dead:
    intr_disable();
  10041d:	e8 d6 13 00 00       	call   1017f8 <intr_disable>
    while (1) {
        kmonitor(NULL);
  100422:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100429:	e8 64 08 00 00       	call   100c92 <kmonitor>
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
  10044a:	c7 04 24 7a 35 10 00 	movl   $0x10357a,(%esp)
  100451:	e8 06 fe ff ff       	call   10025c <cprintf>
    vcprintf(fmt, ap);
  100456:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100459:	89 44 24 04          	mov    %eax,0x4(%esp)
  10045d:	8b 45 10             	mov    0x10(%ebp),%eax
  100460:	89 04 24             	mov    %eax,(%esp)
  100463:	e8 c1 fd ff ff       	call   100229 <vcprintf>
    cprintf("\n");
  100468:	c7 04 24 66 35 10 00 	movl   $0x103566,(%esp)
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
  1005df:	c7 00 98 35 10 00    	movl   $0x103598,(%eax)
    info->eip_line = 0;
  1005e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005e8:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  1005ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005f2:	c7 40 08 98 35 10 00 	movl   $0x103598,0x8(%eax)
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
  100616:	c7 45 f4 cc 3d 10 00 	movl   $0x103dcc,-0xc(%ebp)
    stab_end = __STAB_END__;
  10061d:	c7 45 f0 d0 b4 10 00 	movl   $0x10b4d0,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  100624:	c7 45 ec d1 b4 10 00 	movl   $0x10b4d1,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  10062b:	c7 45 e8 bc d4 10 00 	movl   $0x10d4bc,-0x18(%ebp)

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
  10078a:	e8 6f 23 00 00       	call   102afe <strfind>
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
  100919:	c7 04 24 a2 35 10 00 	movl   $0x1035a2,(%esp)
  100920:	e8 37 f9 ff ff       	call   10025c <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  100925:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  10092c:	00 
  10092d:	c7 04 24 bb 35 10 00 	movl   $0x1035bb,(%esp)
  100934:	e8 23 f9 ff ff       	call   10025c <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  100939:	c7 44 24 04 94 34 10 	movl   $0x103494,0x4(%esp)
  100940:	00 
  100941:	c7 04 24 d3 35 10 00 	movl   $0x1035d3,(%esp)
  100948:	e8 0f f9 ff ff       	call   10025c <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  10094d:	c7 44 24 04 16 ea 10 	movl   $0x10ea16,0x4(%esp)
  100954:	00 
  100955:	c7 04 24 eb 35 10 00 	movl   $0x1035eb,(%esp)
  10095c:	e8 fb f8 ff ff       	call   10025c <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  100961:	c7 44 24 04 20 fd 10 	movl   $0x10fd20,0x4(%esp)
  100968:	00 
  100969:	c7 04 24 03 36 10 00 	movl   $0x103603,(%esp)
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
  10099b:	c7 04 24 1c 36 10 00 	movl   $0x10361c,(%esp)
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
  1009cf:	c7 04 24 46 36 10 00 	movl   $0x103646,(%esp)
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
  100a3e:	c7 04 24 62 36 10 00 	movl   $0x103662,(%esp)
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
  100a60:	53                   	push   %ebx
  100a61:	83 ec 44             	sub    $0x44,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  100a64:	89 e8                	mov    %ebp,%eax
  100a66:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return ebp;
  100a69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp=read_ebp(),eip=read_eip();
  100a6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100a6f:	e8 d8 ff ff ff       	call   100a4c <read_eip>
  100a74:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int i;//这里在for循环里定义好像不行的样子就拿出来了
	for(i=0;ebp!=0&&i<STACKFRAME_DEPTH;i++)
  100a77:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  100a7e:	e9 8d 00 00 00       	jmp    100b10 <print_stackframe+0xb3>
    {   
		cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
  100a83:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100a86:	89 44 24 08          	mov    %eax,0x8(%esp)
  100a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a91:	c7 04 24 74 36 10 00 	movl   $0x103674,(%esp)
  100a98:	e8 bf f7 ff ff       	call   10025c <cprintf>
		uint32_t *args = (uint32_t *)ebp + 2;       //ebp+8指向参数，+4指向返回值
  100a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100aa0:	83 c0 08             	add    $0x8,%eax
  100aa3:	89 45 e8             	mov    %eax,-0x18(%ebp)
		cprintf("arg :0x%08x 0x%08x 0x%08x 0x%08x\n",*(args+0),*(args+1),*(args+2),*(args+3));
  100aa6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100aa9:	83 c0 0c             	add    $0xc,%eax
  100aac:	8b 18                	mov    (%eax),%ebx
  100aae:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100ab1:	83 c0 08             	add    $0x8,%eax
  100ab4:	8b 08                	mov    (%eax),%ecx
  100ab6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100ab9:	83 c0 04             	add    $0x4,%eax
  100abc:	8b 10                	mov    (%eax),%edx
  100abe:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100ac1:	8b 00                	mov    (%eax),%eax
  100ac3:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  100ac7:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  100acb:	89 54 24 08          	mov    %edx,0x8(%esp)
  100acf:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ad3:	c7 04 24 90 36 10 00 	movl   $0x103690,(%esp)
  100ada:	e8 7d f7 ff ff       	call   10025c <cprintf>
        //依次打印调用函数的参数1 2 3 4
		cprintf("\n");
  100adf:	c7 04 24 b2 36 10 00 	movl   $0x1036b2,(%esp)
  100ae6:	e8 71 f7 ff ff       	call   10025c <cprintf>
		print_debuginfo(eip - 1);//eip指向的是下一条指令，所以这里减1  指针占4
  100aeb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100aee:	83 e8 01             	sub    $0x1,%eax
  100af1:	89 04 24             	mov    %eax,(%esp)
  100af4:	e8 b0 fe ff ff       	call   1009a9 <print_debuginfo>
		eip = ((uint32_t *)ebp)[1]; //此时eip指向返回地址
  100af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100afc:	83 c0 04             	add    $0x4,%eax
  100aff:	8b 00                	mov    (%eax),%eax
  100b01:	89 45 f0             	mov    %eax,-0x10(%ebp)
		ebp = ((uint32_t *)ebp)[0];//ebp存的是调用者edp，所以这里就复原了调用前edp值
  100b04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b07:	8b 00                	mov    (%eax),%eax
  100b09:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for(i=0;ebp!=0&&i<STACKFRAME_DEPTH;i++)
  100b0c:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
  100b10:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100b14:	74 0a                	je     100b20 <print_stackframe+0xc3>
  100b16:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100b1a:	0f 8e 63 ff ff ff    	jle    100a83 <print_stackframe+0x26>
	}
}
  100b20:	83 c4 44             	add    $0x44,%esp
  100b23:	5b                   	pop    %ebx
  100b24:	5d                   	pop    %ebp
  100b25:	c3                   	ret    

00100b26 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100b26:	55                   	push   %ebp
  100b27:	89 e5                	mov    %esp,%ebp
  100b29:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  100b2c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b33:	eb 0c                	jmp    100b41 <parse+0x1b>
            *buf ++ = '\0';
  100b35:	8b 45 08             	mov    0x8(%ebp),%eax
  100b38:	8d 50 01             	lea    0x1(%eax),%edx
  100b3b:	89 55 08             	mov    %edx,0x8(%ebp)
  100b3e:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b41:	8b 45 08             	mov    0x8(%ebp),%eax
  100b44:	0f b6 00             	movzbl (%eax),%eax
  100b47:	84 c0                	test   %al,%al
  100b49:	74 1d                	je     100b68 <parse+0x42>
  100b4b:	8b 45 08             	mov    0x8(%ebp),%eax
  100b4e:	0f b6 00             	movzbl (%eax),%eax
  100b51:	0f be c0             	movsbl %al,%eax
  100b54:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b58:	c7 04 24 34 37 10 00 	movl   $0x103734,(%esp)
  100b5f:	e8 67 1f 00 00       	call   102acb <strchr>
  100b64:	85 c0                	test   %eax,%eax
  100b66:	75 cd                	jne    100b35 <parse+0xf>
        }
        if (*buf == '\0') {
  100b68:	8b 45 08             	mov    0x8(%ebp),%eax
  100b6b:	0f b6 00             	movzbl (%eax),%eax
  100b6e:	84 c0                	test   %al,%al
  100b70:	75 02                	jne    100b74 <parse+0x4e>
            break;
  100b72:	eb 67                	jmp    100bdb <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100b74:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100b78:	75 14                	jne    100b8e <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100b7a:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100b81:	00 
  100b82:	c7 04 24 39 37 10 00 	movl   $0x103739,(%esp)
  100b89:	e8 ce f6 ff ff       	call   10025c <cprintf>
        }
        argv[argc ++] = buf;
  100b8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b91:	8d 50 01             	lea    0x1(%eax),%edx
  100b94:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100b97:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100b9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  100ba1:	01 c2                	add    %eax,%edx
  100ba3:	8b 45 08             	mov    0x8(%ebp),%eax
  100ba6:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100ba8:	eb 04                	jmp    100bae <parse+0x88>
            buf ++;
  100baa:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100bae:	8b 45 08             	mov    0x8(%ebp),%eax
  100bb1:	0f b6 00             	movzbl (%eax),%eax
  100bb4:	84 c0                	test   %al,%al
  100bb6:	74 1d                	je     100bd5 <parse+0xaf>
  100bb8:	8b 45 08             	mov    0x8(%ebp),%eax
  100bbb:	0f b6 00             	movzbl (%eax),%eax
  100bbe:	0f be c0             	movsbl %al,%eax
  100bc1:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bc5:	c7 04 24 34 37 10 00 	movl   $0x103734,(%esp)
  100bcc:	e8 fa 1e 00 00       	call   102acb <strchr>
  100bd1:	85 c0                	test   %eax,%eax
  100bd3:	74 d5                	je     100baa <parse+0x84>
        }
    }
  100bd5:	90                   	nop
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100bd6:	e9 66 ff ff ff       	jmp    100b41 <parse+0x1b>
    return argc;
  100bdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100bde:	c9                   	leave  
  100bdf:	c3                   	ret    

00100be0 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100be0:	55                   	push   %ebp
  100be1:	89 e5                	mov    %esp,%ebp
  100be3:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100be6:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100be9:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bed:	8b 45 08             	mov    0x8(%ebp),%eax
  100bf0:	89 04 24             	mov    %eax,(%esp)
  100bf3:	e8 2e ff ff ff       	call   100b26 <parse>
  100bf8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100bfb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100bff:	75 0a                	jne    100c0b <runcmd+0x2b>
        return 0;
  100c01:	b8 00 00 00 00       	mov    $0x0,%eax
  100c06:	e9 85 00 00 00       	jmp    100c90 <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c0b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100c12:	eb 5c                	jmp    100c70 <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100c14:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  100c17:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c1a:	89 d0                	mov    %edx,%eax
  100c1c:	01 c0                	add    %eax,%eax
  100c1e:	01 d0                	add    %edx,%eax
  100c20:	c1 e0 02             	shl    $0x2,%eax
  100c23:	05 00 e0 10 00       	add    $0x10e000,%eax
  100c28:	8b 00                	mov    (%eax),%eax
  100c2a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100c2e:	89 04 24             	mov    %eax,(%esp)
  100c31:	e8 f6 1d 00 00       	call   102a2c <strcmp>
  100c36:	85 c0                	test   %eax,%eax
  100c38:	75 32                	jne    100c6c <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
  100c3a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c3d:	89 d0                	mov    %edx,%eax
  100c3f:	01 c0                	add    %eax,%eax
  100c41:	01 d0                	add    %edx,%eax
  100c43:	c1 e0 02             	shl    $0x2,%eax
  100c46:	05 00 e0 10 00       	add    $0x10e000,%eax
  100c4b:	8b 40 08             	mov    0x8(%eax),%eax
  100c4e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100c51:	8d 4a ff             	lea    -0x1(%edx),%ecx
  100c54:	8b 55 0c             	mov    0xc(%ebp),%edx
  100c57:	89 54 24 08          	mov    %edx,0x8(%esp)
  100c5b:	8d 55 b0             	lea    -0x50(%ebp),%edx
  100c5e:	83 c2 04             	add    $0x4,%edx
  100c61:	89 54 24 04          	mov    %edx,0x4(%esp)
  100c65:	89 0c 24             	mov    %ecx,(%esp)
  100c68:	ff d0                	call   *%eax
  100c6a:	eb 24                	jmp    100c90 <runcmd+0xb0>
    for (i = 0; i < NCOMMANDS; i ++) {
  100c6c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100c70:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c73:	83 f8 02             	cmp    $0x2,%eax
  100c76:	76 9c                	jbe    100c14 <runcmd+0x34>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100c78:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100c7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c7f:	c7 04 24 57 37 10 00 	movl   $0x103757,(%esp)
  100c86:	e8 d1 f5 ff ff       	call   10025c <cprintf>
    return 0;
  100c8b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100c90:	c9                   	leave  
  100c91:	c3                   	ret    

00100c92 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100c92:	55                   	push   %ebp
  100c93:	89 e5                	mov    %esp,%ebp
  100c95:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100c98:	c7 04 24 70 37 10 00 	movl   $0x103770,(%esp)
  100c9f:	e8 b8 f5 ff ff       	call   10025c <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100ca4:	c7 04 24 98 37 10 00 	movl   $0x103798,(%esp)
  100cab:	e8 ac f5 ff ff       	call   10025c <cprintf>

    if (tf != NULL) {
  100cb0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100cb4:	74 0b                	je     100cc1 <kmonitor+0x2f>
        print_trapframe(tf);
  100cb6:	8b 45 08             	mov    0x8(%ebp),%eax
  100cb9:	89 04 24             	mov    %eax,(%esp)
  100cbc:	e8 10 0d 00 00       	call   1019d1 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100cc1:	c7 04 24 bd 37 10 00 	movl   $0x1037bd,(%esp)
  100cc8:	e8 30 f6 ff ff       	call   1002fd <readline>
  100ccd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100cd0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100cd4:	74 18                	je     100cee <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
  100cd6:	8b 45 08             	mov    0x8(%ebp),%eax
  100cd9:	89 44 24 04          	mov    %eax,0x4(%esp)
  100cdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ce0:	89 04 24             	mov    %eax,(%esp)
  100ce3:	e8 f8 fe ff ff       	call   100be0 <runcmd>
  100ce8:	85 c0                	test   %eax,%eax
  100cea:	79 02                	jns    100cee <kmonitor+0x5c>
                break;
  100cec:	eb 02                	jmp    100cf0 <kmonitor+0x5e>
            }
        }
    }
  100cee:	eb d1                	jmp    100cc1 <kmonitor+0x2f>
}
  100cf0:	c9                   	leave  
  100cf1:	c3                   	ret    

00100cf2 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100cf2:	55                   	push   %ebp
  100cf3:	89 e5                	mov    %esp,%ebp
  100cf5:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100cf8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100cff:	eb 3f                	jmp    100d40 <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100d01:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100d04:	89 d0                	mov    %edx,%eax
  100d06:	01 c0                	add    %eax,%eax
  100d08:	01 d0                	add    %edx,%eax
  100d0a:	c1 e0 02             	shl    $0x2,%eax
  100d0d:	05 00 e0 10 00       	add    $0x10e000,%eax
  100d12:	8b 48 04             	mov    0x4(%eax),%ecx
  100d15:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100d18:	89 d0                	mov    %edx,%eax
  100d1a:	01 c0                	add    %eax,%eax
  100d1c:	01 d0                	add    %edx,%eax
  100d1e:	c1 e0 02             	shl    $0x2,%eax
  100d21:	05 00 e0 10 00       	add    $0x10e000,%eax
  100d26:	8b 00                	mov    (%eax),%eax
  100d28:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100d2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d30:	c7 04 24 c1 37 10 00 	movl   $0x1037c1,(%esp)
  100d37:	e8 20 f5 ff ff       	call   10025c <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
  100d3c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100d40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d43:	83 f8 02             	cmp    $0x2,%eax
  100d46:	76 b9                	jbe    100d01 <mon_help+0xf>
    }
    return 0;
  100d48:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d4d:	c9                   	leave  
  100d4e:	c3                   	ret    

00100d4f <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100d4f:	55                   	push   %ebp
  100d50:	89 e5                	mov    %esp,%ebp
  100d52:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100d55:	e8 b9 fb ff ff       	call   100913 <print_kerninfo>
    return 0;
  100d5a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d5f:	c9                   	leave  
  100d60:	c3                   	ret    

00100d61 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100d61:	55                   	push   %ebp
  100d62:	89 e5                	mov    %esp,%ebp
  100d64:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100d67:	e8 f1 fc ff ff       	call   100a5d <print_stackframe>
    return 0;
  100d6c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d71:	c9                   	leave  
  100d72:	c3                   	ret    

00100d73 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100d73:	55                   	push   %ebp
  100d74:	89 e5                	mov    %esp,%ebp
  100d76:	83 ec 28             	sub    $0x28,%esp
  100d79:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
  100d7f:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100d83:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100d87:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100d8b:	ee                   	out    %al,(%dx)
  100d8c:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100d92:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
  100d96:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100d9a:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100d9e:	ee                   	out    %al,(%dx)
  100d9f:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
  100da5:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
  100da9:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100dad:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100db1:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100db2:	c7 05 08 f9 10 00 00 	movl   $0x0,0x10f908
  100db9:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100dbc:	c7 04 24 ca 37 10 00 	movl   $0x1037ca,(%esp)
  100dc3:	e8 94 f4 ff ff       	call   10025c <cprintf>
    pic_enable(IRQ_TIMER);
  100dc8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100dcf:	e8 b5 08 00 00       	call   101689 <pic_enable>
}
  100dd4:	c9                   	leave  
  100dd5:	c3                   	ret    

00100dd6 <delay>:
#include <picirq.h>
#include <trap.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100dd6:	55                   	push   %ebp
  100dd7:	89 e5                	mov    %esp,%ebp
  100dd9:	83 ec 10             	sub    $0x10,%esp
  100ddc:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100de2:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100de6:	89 c2                	mov    %eax,%edx
  100de8:	ec                   	in     (%dx),%al
  100de9:	88 45 fd             	mov    %al,-0x3(%ebp)
  100dec:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100df2:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100df6:	89 c2                	mov    %eax,%edx
  100df8:	ec                   	in     (%dx),%al
  100df9:	88 45 f9             	mov    %al,-0x7(%ebp)
  100dfc:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
  100e02:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100e06:	89 c2                	mov    %eax,%edx
  100e08:	ec                   	in     (%dx),%al
  100e09:	88 45 f5             	mov    %al,-0xb(%ebp)
  100e0c:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
  100e12:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100e16:	89 c2                	mov    %eax,%edx
  100e18:	ec                   	in     (%dx),%al
  100e19:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100e1c:	c9                   	leave  
  100e1d:	c3                   	ret    

00100e1e <cga_init>:
//    -- 数据寄存器 映射 到 端口 0x3D5或0x3B5 
//    -- 索引寄存器 0x3D4或0x3B4,决定在数据寄存器中的数据表示什么。

/* TEXT-mode CGA/VGA display output */
static void
cga_init(void) {
  100e1e:	55                   	push   %ebp
  100e1f:	89 e5                	mov    %esp,%ebp
  100e21:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)CGA_BUF;   //CGA_BUF: 0xB8000 (彩色显示的显存物理基址)
  100e24:	c7 45 fc 00 80 0b 00 	movl   $0xb8000,-0x4(%ebp)
    uint16_t was = *cp;                                            //保存当前显存0xB8000处的值
  100e2b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e2e:	0f b7 00             	movzwl (%eax),%eax
  100e31:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;                                   // 给这个地址随便写个值，看看能否再读出同样的值
  100e35:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e38:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {                                            // 如果读不出来，说明没有这块显存，即是单显配置
  100e3d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e40:	0f b7 00             	movzwl (%eax),%eax
  100e43:	66 3d 5a a5          	cmp    $0xa55a,%ax
  100e47:	74 12                	je     100e5b <cga_init+0x3d>
        cp = (uint16_t*)MONO_BUF;                         //设置为单显的显存基址 MONO_BUF： 0xB0000
  100e49:	c7 45 fc 00 00 0b 00 	movl   $0xb0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;                           //设置为单显控制的IO地址，MONO_BASE: 0x3B4
  100e50:	66 c7 05 66 ee 10 00 	movw   $0x3b4,0x10ee66
  100e57:	b4 03 
  100e59:	eb 13                	jmp    100e6e <cga_init+0x50>
    } else {                                                                // 如果读出来了，有这块显存，即是彩显配置
        *cp = was;                                                      //还原原来显存位置的值
  100e5b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e5e:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100e62:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;                               // 设置为彩显控制的IO地址，CGA_BASE: 0x3D4 
  100e65:	66 c7 05 66 ee 10 00 	movw   $0x3d4,0x10ee66
  100e6c:	d4 03 
    // Extract cursor location
    // 6845索引寄存器的index 0x0E（及十进制的14）== 光标位置(高位)
    // 6845索引寄存器的index 0x0F（及十进制的15）== 光标位置(低位)
    // 6845 reg 15 : Cursor Address (Low Byte)
    uint32_t pos;
    outb(addr_6845, 14);                                        
  100e6e:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100e75:	0f b7 c0             	movzwl %ax,%eax
  100e78:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  100e7c:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100e80:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100e84:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100e88:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;                       //读出了光标位置(高位)
  100e89:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100e90:	83 c0 01             	add    $0x1,%eax
  100e93:	0f b7 c0             	movzwl %ax,%eax
  100e96:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100e9a:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  100e9e:	89 c2                	mov    %eax,%edx
  100ea0:	ec                   	in     (%dx),%al
  100ea1:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  100ea4:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100ea8:	0f b6 c0             	movzbl %al,%eax
  100eab:	c1 e0 08             	shl    $0x8,%eax
  100eae:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100eb1:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100eb8:	0f b7 c0             	movzwl %ax,%eax
  100ebb:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
  100ebf:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100ec3:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100ec7:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100ecb:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);                             //读出了光标位置(低位)
  100ecc:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100ed3:	83 c0 01             	add    $0x1,%eax
  100ed6:	0f b7 c0             	movzwl %ax,%eax
  100ed9:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100edd:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
  100ee1:	89 c2                	mov    %eax,%edx
  100ee3:	ec                   	in     (%dx),%al
  100ee4:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
  100ee7:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100eeb:	0f b6 c0             	movzbl %al,%eax
  100eee:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;                                  //crt_buf是CGA显存起始地址
  100ef1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ef4:	a3 60 ee 10 00       	mov    %eax,0x10ee60
    crt_pos = pos;                                                  //crt_pos是CGA当前光标位置
  100ef9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100efc:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
}
  100f02:	c9                   	leave  
  100f03:	c3                   	ret    

00100f04 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100f04:	55                   	push   %ebp
  100f05:	89 e5                	mov    %esp,%ebp
  100f07:	83 ec 48             	sub    $0x48,%esp
  100f0a:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
  100f10:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100f14:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100f18:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100f1c:	ee                   	out    %al,(%dx)
  100f1d:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
  100f23:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
  100f27:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100f2b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100f2f:	ee                   	out    %al,(%dx)
  100f30:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
  100f36:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
  100f3a:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100f3e:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100f42:	ee                   	out    %al,(%dx)
  100f43:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  100f49:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
  100f4d:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100f51:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100f55:	ee                   	out    %al,(%dx)
  100f56:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
  100f5c:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
  100f60:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100f64:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100f68:	ee                   	out    %al,(%dx)
  100f69:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
  100f6f:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
  100f73:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  100f77:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  100f7b:	ee                   	out    %al,(%dx)
  100f7c:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
  100f82:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
  100f86:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100f8a:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  100f8e:	ee                   	out    %al,(%dx)
  100f8f:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100f95:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
  100f99:	89 c2                	mov    %eax,%edx
  100f9b:	ec                   	in     (%dx),%al
  100f9c:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
  100f9f:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  100fa3:	3c ff                	cmp    $0xff,%al
  100fa5:	0f 95 c0             	setne  %al
  100fa8:	0f b6 c0             	movzbl %al,%eax
  100fab:	a3 68 ee 10 00       	mov    %eax,0x10ee68
  100fb0:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100fb6:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
  100fba:	89 c2                	mov    %eax,%edx
  100fbc:	ec                   	in     (%dx),%al
  100fbd:	88 45 d5             	mov    %al,-0x2b(%ebp)
  100fc0:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
  100fc6:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
  100fca:	89 c2                	mov    %eax,%edx
  100fcc:	ec                   	in     (%dx),%al
  100fcd:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  100fd0:	a1 68 ee 10 00       	mov    0x10ee68,%eax
  100fd5:	85 c0                	test   %eax,%eax
  100fd7:	74 0c                	je     100fe5 <serial_init+0xe1>
        pic_enable(IRQ_COM1);
  100fd9:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  100fe0:	e8 a4 06 00 00       	call   101689 <pic_enable>
    }
}
  100fe5:	c9                   	leave  
  100fe6:	c3                   	ret    

00100fe7 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  100fe7:	55                   	push   %ebp
  100fe8:	89 e5                	mov    %esp,%ebp
  100fea:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  100fed:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  100ff4:	eb 09                	jmp    100fff <lpt_putc_sub+0x18>
        delay();
  100ff6:	e8 db fd ff ff       	call   100dd6 <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  100ffb:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  100fff:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
  101005:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101009:	89 c2                	mov    %eax,%edx
  10100b:	ec                   	in     (%dx),%al
  10100c:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  10100f:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101013:	84 c0                	test   %al,%al
  101015:	78 09                	js     101020 <lpt_putc_sub+0x39>
  101017:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  10101e:	7e d6                	jle    100ff6 <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
  101020:	8b 45 08             	mov    0x8(%ebp),%eax
  101023:	0f b6 c0             	movzbl %al,%eax
  101026:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
  10102c:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  10102f:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  101033:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101037:	ee                   	out    %al,(%dx)
  101038:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
  10103e:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
  101042:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  101046:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  10104a:	ee                   	out    %al,(%dx)
  10104b:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
  101051:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
  101055:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101059:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  10105d:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  10105e:	c9                   	leave  
  10105f:	c3                   	ret    

00101060 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  101060:	55                   	push   %ebp
  101061:	89 e5                	mov    %esp,%ebp
  101063:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  101066:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  10106a:	74 0d                	je     101079 <lpt_putc+0x19>
        lpt_putc_sub(c);
  10106c:	8b 45 08             	mov    0x8(%ebp),%eax
  10106f:	89 04 24             	mov    %eax,(%esp)
  101072:	e8 70 ff ff ff       	call   100fe7 <lpt_putc_sub>
  101077:	eb 24                	jmp    10109d <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
  101079:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101080:	e8 62 ff ff ff       	call   100fe7 <lpt_putc_sub>
        lpt_putc_sub(' ');
  101085:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  10108c:	e8 56 ff ff ff       	call   100fe7 <lpt_putc_sub>
        lpt_putc_sub('\b');
  101091:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101098:	e8 4a ff ff ff       	call   100fe7 <lpt_putc_sub>
    }
}
  10109d:	c9                   	leave  
  10109e:	c3                   	ret    

0010109f <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  10109f:	55                   	push   %ebp
  1010a0:	89 e5                	mov    %esp,%ebp
  1010a2:	53                   	push   %ebx
  1010a3:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
  1010a6:	8b 45 08             	mov    0x8(%ebp),%eax
  1010a9:	b0 00                	mov    $0x0,%al
  1010ab:	85 c0                	test   %eax,%eax
  1010ad:	75 07                	jne    1010b6 <cga_putc+0x17>
        c |= 0x0700;
  1010af:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  1010b6:	8b 45 08             	mov    0x8(%ebp),%eax
  1010b9:	0f b6 c0             	movzbl %al,%eax
  1010bc:	83 f8 0a             	cmp    $0xa,%eax
  1010bf:	74 4c                	je     10110d <cga_putc+0x6e>
  1010c1:	83 f8 0d             	cmp    $0xd,%eax
  1010c4:	74 57                	je     10111d <cga_putc+0x7e>
  1010c6:	83 f8 08             	cmp    $0x8,%eax
  1010c9:	0f 85 88 00 00 00    	jne    101157 <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
  1010cf:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1010d6:	66 85 c0             	test   %ax,%ax
  1010d9:	74 30                	je     10110b <cga_putc+0x6c>
            crt_pos --;
  1010db:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1010e2:	83 e8 01             	sub    $0x1,%eax
  1010e5:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  1010eb:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  1010f0:	0f b7 15 64 ee 10 00 	movzwl 0x10ee64,%edx
  1010f7:	0f b7 d2             	movzwl %dx,%edx
  1010fa:	01 d2                	add    %edx,%edx
  1010fc:	01 c2                	add    %eax,%edx
  1010fe:	8b 45 08             	mov    0x8(%ebp),%eax
  101101:	b0 00                	mov    $0x0,%al
  101103:	83 c8 20             	or     $0x20,%eax
  101106:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  101109:	eb 72                	jmp    10117d <cga_putc+0xde>
  10110b:	eb 70                	jmp    10117d <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
  10110d:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  101114:	83 c0 50             	add    $0x50,%eax
  101117:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  10111d:	0f b7 1d 64 ee 10 00 	movzwl 0x10ee64,%ebx
  101124:	0f b7 0d 64 ee 10 00 	movzwl 0x10ee64,%ecx
  10112b:	0f b7 c1             	movzwl %cx,%eax
  10112e:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
  101134:	c1 e8 10             	shr    $0x10,%eax
  101137:	89 c2                	mov    %eax,%edx
  101139:	66 c1 ea 06          	shr    $0x6,%dx
  10113d:	89 d0                	mov    %edx,%eax
  10113f:	c1 e0 02             	shl    $0x2,%eax
  101142:	01 d0                	add    %edx,%eax
  101144:	c1 e0 04             	shl    $0x4,%eax
  101147:	29 c1                	sub    %eax,%ecx
  101149:	89 ca                	mov    %ecx,%edx
  10114b:	89 d8                	mov    %ebx,%eax
  10114d:	29 d0                	sub    %edx,%eax
  10114f:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
        break;
  101155:	eb 26                	jmp    10117d <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  101157:	8b 0d 60 ee 10 00    	mov    0x10ee60,%ecx
  10115d:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  101164:	8d 50 01             	lea    0x1(%eax),%edx
  101167:	66 89 15 64 ee 10 00 	mov    %dx,0x10ee64
  10116e:	0f b7 c0             	movzwl %ax,%eax
  101171:	01 c0                	add    %eax,%eax
  101173:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  101176:	8b 45 08             	mov    0x8(%ebp),%eax
  101179:	66 89 02             	mov    %ax,(%edx)
        break;
  10117c:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  10117d:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  101184:	66 3d cf 07          	cmp    $0x7cf,%ax
  101188:	76 5b                	jbe    1011e5 <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  10118a:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  10118f:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  101195:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  10119a:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  1011a1:	00 
  1011a2:	89 54 24 04          	mov    %edx,0x4(%esp)
  1011a6:	89 04 24             	mov    %eax,(%esp)
  1011a9:	e8 1b 1b 00 00       	call   102cc9 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  1011ae:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  1011b5:	eb 15                	jmp    1011cc <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
  1011b7:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  1011bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1011bf:	01 d2                	add    %edx,%edx
  1011c1:	01 d0                	add    %edx,%eax
  1011c3:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  1011c8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  1011cc:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  1011d3:	7e e2                	jle    1011b7 <cga_putc+0x118>
        }
        crt_pos -= CRT_COLS;
  1011d5:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1011dc:	83 e8 50             	sub    $0x50,%eax
  1011df:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  1011e5:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  1011ec:	0f b7 c0             	movzwl %ax,%eax
  1011ef:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  1011f3:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
  1011f7:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1011fb:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1011ff:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
  101200:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  101207:	66 c1 e8 08          	shr    $0x8,%ax
  10120b:	0f b6 c0             	movzbl %al,%eax
  10120e:	0f b7 15 66 ee 10 00 	movzwl 0x10ee66,%edx
  101215:	83 c2 01             	add    $0x1,%edx
  101218:	0f b7 d2             	movzwl %dx,%edx
  10121b:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
  10121f:	88 45 ed             	mov    %al,-0x13(%ebp)
  101222:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101226:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  10122a:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
  10122b:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  101232:	0f b7 c0             	movzwl %ax,%eax
  101235:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
  101239:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
  10123d:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101241:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101245:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
  101246:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  10124d:	0f b6 c0             	movzbl %al,%eax
  101250:	0f b7 15 66 ee 10 00 	movzwl 0x10ee66,%edx
  101257:	83 c2 01             	add    $0x1,%edx
  10125a:	0f b7 d2             	movzwl %dx,%edx
  10125d:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
  101261:	88 45 e5             	mov    %al,-0x1b(%ebp)
  101264:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  101268:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  10126c:	ee                   	out    %al,(%dx)
}
  10126d:	83 c4 34             	add    $0x34,%esp
  101270:	5b                   	pop    %ebx
  101271:	5d                   	pop    %ebp
  101272:	c3                   	ret    

00101273 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  101273:	55                   	push   %ebp
  101274:	89 e5                	mov    %esp,%ebp
  101276:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  101279:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101280:	eb 09                	jmp    10128b <serial_putc_sub+0x18>
        delay();
  101282:	e8 4f fb ff ff       	call   100dd6 <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  101287:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  10128b:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101291:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101295:	89 c2                	mov    %eax,%edx
  101297:	ec                   	in     (%dx),%al
  101298:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  10129b:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  10129f:	0f b6 c0             	movzbl %al,%eax
  1012a2:	83 e0 20             	and    $0x20,%eax
  1012a5:	85 c0                	test   %eax,%eax
  1012a7:	75 09                	jne    1012b2 <serial_putc_sub+0x3f>
  1012a9:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  1012b0:	7e d0                	jle    101282 <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
  1012b2:	8b 45 08             	mov    0x8(%ebp),%eax
  1012b5:	0f b6 c0             	movzbl %al,%eax
  1012b8:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  1012be:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1012c1:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1012c5:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1012c9:	ee                   	out    %al,(%dx)
}
  1012ca:	c9                   	leave  
  1012cb:	c3                   	ret    

001012cc <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  1012cc:	55                   	push   %ebp
  1012cd:	89 e5                	mov    %esp,%ebp
  1012cf:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  1012d2:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1012d6:	74 0d                	je     1012e5 <serial_putc+0x19>
        serial_putc_sub(c);
  1012d8:	8b 45 08             	mov    0x8(%ebp),%eax
  1012db:	89 04 24             	mov    %eax,(%esp)
  1012de:	e8 90 ff ff ff       	call   101273 <serial_putc_sub>
  1012e3:	eb 24                	jmp    101309 <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
  1012e5:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1012ec:	e8 82 ff ff ff       	call   101273 <serial_putc_sub>
        serial_putc_sub(' ');
  1012f1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1012f8:	e8 76 ff ff ff       	call   101273 <serial_putc_sub>
        serial_putc_sub('\b');
  1012fd:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101304:	e8 6a ff ff ff       	call   101273 <serial_putc_sub>
    }
}
  101309:	c9                   	leave  
  10130a:	c3                   	ret    

0010130b <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  10130b:	55                   	push   %ebp
  10130c:	89 e5                	mov    %esp,%ebp
  10130e:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  101311:	eb 33                	jmp    101346 <cons_intr+0x3b>
        if (c != 0) {
  101313:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  101317:	74 2d                	je     101346 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  101319:	a1 84 f0 10 00       	mov    0x10f084,%eax
  10131e:	8d 50 01             	lea    0x1(%eax),%edx
  101321:	89 15 84 f0 10 00    	mov    %edx,0x10f084
  101327:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10132a:	88 90 80 ee 10 00    	mov    %dl,0x10ee80(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  101330:	a1 84 f0 10 00       	mov    0x10f084,%eax
  101335:	3d 00 02 00 00       	cmp    $0x200,%eax
  10133a:	75 0a                	jne    101346 <cons_intr+0x3b>
                cons.wpos = 0;
  10133c:	c7 05 84 f0 10 00 00 	movl   $0x0,0x10f084
  101343:	00 00 00 
    while ((c = (*proc)()) != -1) {
  101346:	8b 45 08             	mov    0x8(%ebp),%eax
  101349:	ff d0                	call   *%eax
  10134b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10134e:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  101352:	75 bf                	jne    101313 <cons_intr+0x8>
            }
        }
    }
}
  101354:	c9                   	leave  
  101355:	c3                   	ret    

00101356 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  101356:	55                   	push   %ebp
  101357:	89 e5                	mov    %esp,%ebp
  101359:	83 ec 10             	sub    $0x10,%esp
  10135c:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101362:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101366:	89 c2                	mov    %eax,%edx
  101368:	ec                   	in     (%dx),%al
  101369:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  10136c:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  101370:	0f b6 c0             	movzbl %al,%eax
  101373:	83 e0 01             	and    $0x1,%eax
  101376:	85 c0                	test   %eax,%eax
  101378:	75 07                	jne    101381 <serial_proc_data+0x2b>
        return -1;
  10137a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10137f:	eb 2a                	jmp    1013ab <serial_proc_data+0x55>
  101381:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101387:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10138b:	89 c2                	mov    %eax,%edx
  10138d:	ec                   	in     (%dx),%al
  10138e:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
  101391:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  101395:	0f b6 c0             	movzbl %al,%eax
  101398:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  10139b:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  10139f:	75 07                	jne    1013a8 <serial_proc_data+0x52>
        c = '\b';
  1013a1:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  1013a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1013ab:	c9                   	leave  
  1013ac:	c3                   	ret    

001013ad <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  1013ad:	55                   	push   %ebp
  1013ae:	89 e5                	mov    %esp,%ebp
  1013b0:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  1013b3:	a1 68 ee 10 00       	mov    0x10ee68,%eax
  1013b8:	85 c0                	test   %eax,%eax
  1013ba:	74 0c                	je     1013c8 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
  1013bc:	c7 04 24 56 13 10 00 	movl   $0x101356,(%esp)
  1013c3:	e8 43 ff ff ff       	call   10130b <cons_intr>
    }
}
  1013c8:	c9                   	leave  
  1013c9:	c3                   	ret    

001013ca <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  1013ca:	55                   	push   %ebp
  1013cb:	89 e5                	mov    %esp,%ebp
  1013cd:	83 ec 38             	sub    $0x38,%esp
  1013d0:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  1013d6:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1013da:	89 c2                	mov    %eax,%edx
  1013dc:	ec                   	in     (%dx),%al
  1013dd:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
  1013e0:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  1013e4:	0f b6 c0             	movzbl %al,%eax
  1013e7:	83 e0 01             	and    $0x1,%eax
  1013ea:	85 c0                	test   %eax,%eax
  1013ec:	75 0a                	jne    1013f8 <kbd_proc_data+0x2e>
        return -1;
  1013ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1013f3:	e9 59 01 00 00       	jmp    101551 <kbd_proc_data+0x187>
  1013f8:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  1013fe:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101402:	89 c2                	mov    %eax,%edx
  101404:	ec                   	in     (%dx),%al
  101405:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  101408:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
  10140c:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  10140f:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  101413:	75 17                	jne    10142c <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
  101415:	a1 88 f0 10 00       	mov    0x10f088,%eax
  10141a:	83 c8 40             	or     $0x40,%eax
  10141d:	a3 88 f0 10 00       	mov    %eax,0x10f088
        return 0;
  101422:	b8 00 00 00 00       	mov    $0x0,%eax
  101427:	e9 25 01 00 00       	jmp    101551 <kbd_proc_data+0x187>
    } else if (data & 0x80) {
  10142c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101430:	84 c0                	test   %al,%al
  101432:	79 47                	jns    10147b <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  101434:	a1 88 f0 10 00       	mov    0x10f088,%eax
  101439:	83 e0 40             	and    $0x40,%eax
  10143c:	85 c0                	test   %eax,%eax
  10143e:	75 09                	jne    101449 <kbd_proc_data+0x7f>
  101440:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101444:	83 e0 7f             	and    $0x7f,%eax
  101447:	eb 04                	jmp    10144d <kbd_proc_data+0x83>
  101449:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10144d:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  101450:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101454:	0f b6 80 40 e0 10 00 	movzbl 0x10e040(%eax),%eax
  10145b:	83 c8 40             	or     $0x40,%eax
  10145e:	0f b6 c0             	movzbl %al,%eax
  101461:	f7 d0                	not    %eax
  101463:	89 c2                	mov    %eax,%edx
  101465:	a1 88 f0 10 00       	mov    0x10f088,%eax
  10146a:	21 d0                	and    %edx,%eax
  10146c:	a3 88 f0 10 00       	mov    %eax,0x10f088
        return 0;
  101471:	b8 00 00 00 00       	mov    $0x0,%eax
  101476:	e9 d6 00 00 00       	jmp    101551 <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
  10147b:	a1 88 f0 10 00       	mov    0x10f088,%eax
  101480:	83 e0 40             	and    $0x40,%eax
  101483:	85 c0                	test   %eax,%eax
  101485:	74 11                	je     101498 <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  101487:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  10148b:	a1 88 f0 10 00       	mov    0x10f088,%eax
  101490:	83 e0 bf             	and    $0xffffffbf,%eax
  101493:	a3 88 f0 10 00       	mov    %eax,0x10f088
    }

    shift |= shiftcode[data];
  101498:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10149c:	0f b6 80 40 e0 10 00 	movzbl 0x10e040(%eax),%eax
  1014a3:	0f b6 d0             	movzbl %al,%edx
  1014a6:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1014ab:	09 d0                	or     %edx,%eax
  1014ad:	a3 88 f0 10 00       	mov    %eax,0x10f088
    shift ^= togglecode[data];
  1014b2:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014b6:	0f b6 80 40 e1 10 00 	movzbl 0x10e140(%eax),%eax
  1014bd:	0f b6 d0             	movzbl %al,%edx
  1014c0:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1014c5:	31 d0                	xor    %edx,%eax
  1014c7:	a3 88 f0 10 00       	mov    %eax,0x10f088

    c = charcode[shift & (CTL | SHIFT)][data];
  1014cc:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1014d1:	83 e0 03             	and    $0x3,%eax
  1014d4:	8b 14 85 40 e5 10 00 	mov    0x10e540(,%eax,4),%edx
  1014db:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014df:	01 d0                	add    %edx,%eax
  1014e1:	0f b6 00             	movzbl (%eax),%eax
  1014e4:	0f b6 c0             	movzbl %al,%eax
  1014e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  1014ea:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1014ef:	83 e0 08             	and    $0x8,%eax
  1014f2:	85 c0                	test   %eax,%eax
  1014f4:	74 22                	je     101518 <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
  1014f6:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  1014fa:	7e 0c                	jle    101508 <kbd_proc_data+0x13e>
  1014fc:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  101500:	7f 06                	jg     101508 <kbd_proc_data+0x13e>
            c += 'A' - 'a';
  101502:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  101506:	eb 10                	jmp    101518 <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
  101508:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  10150c:	7e 0a                	jle    101518 <kbd_proc_data+0x14e>
  10150e:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  101512:	7f 04                	jg     101518 <kbd_proc_data+0x14e>
            c += 'a' - 'A';
  101514:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  101518:	a1 88 f0 10 00       	mov    0x10f088,%eax
  10151d:	f7 d0                	not    %eax
  10151f:	83 e0 06             	and    $0x6,%eax
  101522:	85 c0                	test   %eax,%eax
  101524:	75 28                	jne    10154e <kbd_proc_data+0x184>
  101526:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  10152d:	75 1f                	jne    10154e <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
  10152f:	c7 04 24 e5 37 10 00 	movl   $0x1037e5,(%esp)
  101536:	e8 21 ed ff ff       	call   10025c <cprintf>
  10153b:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
  101541:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101545:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  101549:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
  10154d:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  10154e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  101551:	c9                   	leave  
  101552:	c3                   	ret    

00101553 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  101553:	55                   	push   %ebp
  101554:	89 e5                	mov    %esp,%ebp
  101556:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  101559:	c7 04 24 ca 13 10 00 	movl   $0x1013ca,(%esp)
  101560:	e8 a6 fd ff ff       	call   10130b <cons_intr>
}
  101565:	c9                   	leave  
  101566:	c3                   	ret    

00101567 <kbd_init>:

static void
kbd_init(void) {
  101567:	55                   	push   %ebp
  101568:	89 e5                	mov    %esp,%ebp
  10156a:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  10156d:	e8 e1 ff ff ff       	call   101553 <kbd_intr>
    pic_enable(IRQ_KBD);
  101572:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  101579:	e8 0b 01 00 00       	call   101689 <pic_enable>
}
  10157e:	c9                   	leave  
  10157f:	c3                   	ret    

00101580 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  101580:	55                   	push   %ebp
  101581:	89 e5                	mov    %esp,%ebp
  101583:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  101586:	e8 93 f8 ff ff       	call   100e1e <cga_init>
    serial_init();
  10158b:	e8 74 f9 ff ff       	call   100f04 <serial_init>
    kbd_init();
  101590:	e8 d2 ff ff ff       	call   101567 <kbd_init>
    if (!serial_exists) {
  101595:	a1 68 ee 10 00       	mov    0x10ee68,%eax
  10159a:	85 c0                	test   %eax,%eax
  10159c:	75 0c                	jne    1015aa <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  10159e:	c7 04 24 f1 37 10 00 	movl   $0x1037f1,(%esp)
  1015a5:	e8 b2 ec ff ff       	call   10025c <cprintf>
    }
}
  1015aa:	c9                   	leave  
  1015ab:	c3                   	ret    

001015ac <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  1015ac:	55                   	push   %ebp
  1015ad:	89 e5                	mov    %esp,%ebp
  1015af:	83 ec 18             	sub    $0x18,%esp
    lpt_putc(c);
  1015b2:	8b 45 08             	mov    0x8(%ebp),%eax
  1015b5:	89 04 24             	mov    %eax,(%esp)
  1015b8:	e8 a3 fa ff ff       	call   101060 <lpt_putc>
    cga_putc(c);
  1015bd:	8b 45 08             	mov    0x8(%ebp),%eax
  1015c0:	89 04 24             	mov    %eax,(%esp)
  1015c3:	e8 d7 fa ff ff       	call   10109f <cga_putc>
    serial_putc(c);
  1015c8:	8b 45 08             	mov    0x8(%ebp),%eax
  1015cb:	89 04 24             	mov    %eax,(%esp)
  1015ce:	e8 f9 fc ff ff       	call   1012cc <serial_putc>
}
  1015d3:	c9                   	leave  
  1015d4:	c3                   	ret    

001015d5 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  1015d5:	55                   	push   %ebp
  1015d6:	89 e5                	mov    %esp,%ebp
  1015d8:	83 ec 18             	sub    $0x18,%esp
    int c;

    // poll for any pending input characters,
    // so that this function works even when interrupts are disabled
    // (e.g., when called from the kernel monitor).
    serial_intr();
  1015db:	e8 cd fd ff ff       	call   1013ad <serial_intr>
    kbd_intr();
  1015e0:	e8 6e ff ff ff       	call   101553 <kbd_intr>

    // grab the next character from the input buffer.
    if (cons.rpos != cons.wpos) {
  1015e5:	8b 15 80 f0 10 00    	mov    0x10f080,%edx
  1015eb:	a1 84 f0 10 00       	mov    0x10f084,%eax
  1015f0:	39 c2                	cmp    %eax,%edx
  1015f2:	74 36                	je     10162a <cons_getc+0x55>
        c = cons.buf[cons.rpos ++];
  1015f4:	a1 80 f0 10 00       	mov    0x10f080,%eax
  1015f9:	8d 50 01             	lea    0x1(%eax),%edx
  1015fc:	89 15 80 f0 10 00    	mov    %edx,0x10f080
  101602:	0f b6 80 80 ee 10 00 	movzbl 0x10ee80(%eax),%eax
  101609:	0f b6 c0             	movzbl %al,%eax
  10160c:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (cons.rpos == CONSBUFSIZE) {
  10160f:	a1 80 f0 10 00       	mov    0x10f080,%eax
  101614:	3d 00 02 00 00       	cmp    $0x200,%eax
  101619:	75 0a                	jne    101625 <cons_getc+0x50>
            cons.rpos = 0;
  10161b:	c7 05 80 f0 10 00 00 	movl   $0x0,0x10f080
  101622:	00 00 00 
        }
        return c;
  101625:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101628:	eb 05                	jmp    10162f <cons_getc+0x5a>
    }
    return 0;
  10162a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10162f:	c9                   	leave  
  101630:	c3                   	ret    

00101631 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  101631:	55                   	push   %ebp
  101632:	89 e5                	mov    %esp,%ebp
  101634:	83 ec 14             	sub    $0x14,%esp
  101637:	8b 45 08             	mov    0x8(%ebp),%eax
  10163a:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  10163e:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101642:	66 a3 50 e5 10 00    	mov    %ax,0x10e550
    if (did_init) {
  101648:	a1 8c f0 10 00       	mov    0x10f08c,%eax
  10164d:	85 c0                	test   %eax,%eax
  10164f:	74 36                	je     101687 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
  101651:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101655:	0f b6 c0             	movzbl %al,%eax
  101658:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  10165e:	88 45 fd             	mov    %al,-0x3(%ebp)
  101661:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  101665:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101669:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
  10166a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  10166e:	66 c1 e8 08          	shr    $0x8,%ax
  101672:	0f b6 c0             	movzbl %al,%eax
  101675:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
  10167b:	88 45 f9             	mov    %al,-0x7(%ebp)
  10167e:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101682:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101686:	ee                   	out    %al,(%dx)
    }
}
  101687:	c9                   	leave  
  101688:	c3                   	ret    

00101689 <pic_enable>:

void
pic_enable(unsigned int irq) {
  101689:	55                   	push   %ebp
  10168a:	89 e5                	mov    %esp,%ebp
  10168c:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  10168f:	8b 45 08             	mov    0x8(%ebp),%eax
  101692:	ba 01 00 00 00       	mov    $0x1,%edx
  101697:	89 c1                	mov    %eax,%ecx
  101699:	d3 e2                	shl    %cl,%edx
  10169b:	89 d0                	mov    %edx,%eax
  10169d:	f7 d0                	not    %eax
  10169f:	89 c2                	mov    %eax,%edx
  1016a1:	0f b7 05 50 e5 10 00 	movzwl 0x10e550,%eax
  1016a8:	21 d0                	and    %edx,%eax
  1016aa:	0f b7 c0             	movzwl %ax,%eax
  1016ad:	89 04 24             	mov    %eax,(%esp)
  1016b0:	e8 7c ff ff ff       	call   101631 <pic_setmask>
}
  1016b5:	c9                   	leave  
  1016b6:	c3                   	ret    

001016b7 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  1016b7:	55                   	push   %ebp
  1016b8:	89 e5                	mov    %esp,%ebp
  1016ba:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
  1016bd:	c7 05 8c f0 10 00 01 	movl   $0x1,0x10f08c
  1016c4:	00 00 00 
  1016c7:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  1016cd:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
  1016d1:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  1016d5:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  1016d9:	ee                   	out    %al,(%dx)
  1016da:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
  1016e0:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
  1016e4:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  1016e8:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  1016ec:	ee                   	out    %al,(%dx)
  1016ed:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
  1016f3:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
  1016f7:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1016fb:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1016ff:	ee                   	out    %al,(%dx)
  101700:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
  101706:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
  10170a:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  10170e:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101712:	ee                   	out    %al,(%dx)
  101713:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
  101719:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
  10171d:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101721:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101725:	ee                   	out    %al,(%dx)
  101726:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
  10172c:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
  101730:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101734:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101738:	ee                   	out    %al,(%dx)
  101739:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
  10173f:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
  101743:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  101747:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  10174b:	ee                   	out    %al,(%dx)
  10174c:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
  101752:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
  101756:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  10175a:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  10175e:	ee                   	out    %al,(%dx)
  10175f:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
  101765:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
  101769:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  10176d:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  101771:	ee                   	out    %al,(%dx)
  101772:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
  101778:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
  10177c:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  101780:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  101784:	ee                   	out    %al,(%dx)
  101785:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
  10178b:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
  10178f:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  101793:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  101797:	ee                   	out    %al,(%dx)
  101798:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
  10179e:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
  1017a2:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  1017a6:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  1017aa:	ee                   	out    %al,(%dx)
  1017ab:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
  1017b1:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
  1017b5:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
  1017b9:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
  1017bd:	ee                   	out    %al,(%dx)
  1017be:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
  1017c4:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
  1017c8:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
  1017cc:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
  1017d0:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  1017d1:	0f b7 05 50 e5 10 00 	movzwl 0x10e550,%eax
  1017d8:	66 83 f8 ff          	cmp    $0xffff,%ax
  1017dc:	74 12                	je     1017f0 <pic_init+0x139>
        pic_setmask(irq_mask);
  1017de:	0f b7 05 50 e5 10 00 	movzwl 0x10e550,%eax
  1017e5:	0f b7 c0             	movzwl %ax,%eax
  1017e8:	89 04 24             	mov    %eax,(%esp)
  1017eb:	e8 41 fe ff ff       	call   101631 <pic_setmask>
    }
}
  1017f0:	c9                   	leave  
  1017f1:	c3                   	ret    

001017f2 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  1017f2:	55                   	push   %ebp
  1017f3:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd));
}

static inline void
sti(void) {
    asm volatile ("sti");
  1017f5:	fb                   	sti    
    sti();
}
  1017f6:	5d                   	pop    %ebp
  1017f7:	c3                   	ret    

001017f8 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  1017f8:	55                   	push   %ebp
  1017f9:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli");
  1017fb:	fa                   	cli    
    cli();
}
  1017fc:	5d                   	pop    %ebp
  1017fd:	c3                   	ret    

001017fe <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
  1017fe:	55                   	push   %ebp
  1017ff:	89 e5                	mov    %esp,%ebp
  101801:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
  101804:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  10180b:	00 
  10180c:	c7 04 24 20 38 10 00 	movl   $0x103820,(%esp)
  101813:	e8 44 ea ff ff       	call   10025c <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
  101818:	c9                   	leave  
  101819:	c3                   	ret    

0010181a <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  10181a:	55                   	push   %ebp
  10181b:	89 e5                	mov    %esp,%ebp
  10181d:	83 ec 10             	sub    $0x10,%esp
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];  //保存在vectors.S中的256个中断处理例程的入口地址数组
    int i;
    //使用SETGATE宏，初始化IDT每个表项
    for (i = 0; i < 256; i ++) 
  101820:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101827:	e9 c3 00 00 00       	jmp    1018ef <idt_init+0xd5>
    { 
    //在中断门描述符表中通过建立中断门描述符，其中存储了中断处理例程的代码段GD_KTEXT和偏移量__vectors[i]
    //特权级为DPL_KERNEL, 通过查询idt[i]就可定位到中断服务例程的起始地址。
     SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
  10182c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10182f:	8b 04 85 e0 e5 10 00 	mov    0x10e5e0(,%eax,4),%eax
  101836:	89 c2                	mov    %eax,%edx
  101838:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10183b:	66 89 14 c5 a0 f0 10 	mov    %dx,0x10f0a0(,%eax,8)
  101842:	00 
  101843:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101846:	66 c7 04 c5 a2 f0 10 	movw   $0x8,0x10f0a2(,%eax,8)
  10184d:	00 08 00 
  101850:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101853:	0f b6 14 c5 a4 f0 10 	movzbl 0x10f0a4(,%eax,8),%edx
  10185a:	00 
  10185b:	83 e2 e0             	and    $0xffffffe0,%edx
  10185e:	88 14 c5 a4 f0 10 00 	mov    %dl,0x10f0a4(,%eax,8)
  101865:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101868:	0f b6 14 c5 a4 f0 10 	movzbl 0x10f0a4(,%eax,8),%edx
  10186f:	00 
  101870:	83 e2 1f             	and    $0x1f,%edx
  101873:	88 14 c5 a4 f0 10 00 	mov    %dl,0x10f0a4(,%eax,8)
  10187a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10187d:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  101884:	00 
  101885:	83 e2 f0             	and    $0xfffffff0,%edx
  101888:	83 ca 0e             	or     $0xe,%edx
  10188b:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  101892:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101895:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  10189c:	00 
  10189d:	83 e2 ef             	and    $0xffffffef,%edx
  1018a0:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  1018a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018aa:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  1018b1:	00 
  1018b2:	83 e2 9f             	and    $0xffffff9f,%edx
  1018b5:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  1018bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018bf:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  1018c6:	00 
  1018c7:	83 ca 80             	or     $0xffffff80,%edx
  1018ca:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  1018d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018d4:	8b 04 85 e0 e5 10 00 	mov    0x10e5e0(,%eax,4),%eax
  1018db:	c1 e8 10             	shr    $0x10,%eax
  1018de:	89 c2                	mov    %eax,%edx
  1018e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018e3:	66 89 14 c5 a6 f0 10 	mov    %dx,0x10f0a6(,%eax,8)
  1018ea:	00 
    for (i = 0; i < 256; i ++) 
  1018eb:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  1018ef:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
  1018f6:	0f 8e 30 ff ff ff    	jle    10182c <idt_init+0x12>
    }
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT,__vectors[T_SWITCH_TOK], DPL_USER);
  1018fc:	a1 c4 e7 10 00       	mov    0x10e7c4,%eax
  101901:	66 a3 68 f4 10 00    	mov    %ax,0x10f468
  101907:	66 c7 05 6a f4 10 00 	movw   $0x8,0x10f46a
  10190e:	08 00 
  101910:	0f b6 05 6c f4 10 00 	movzbl 0x10f46c,%eax
  101917:	83 e0 e0             	and    $0xffffffe0,%eax
  10191a:	a2 6c f4 10 00       	mov    %al,0x10f46c
  10191f:	0f b6 05 6c f4 10 00 	movzbl 0x10f46c,%eax
  101926:	83 e0 1f             	and    $0x1f,%eax
  101929:	a2 6c f4 10 00       	mov    %al,0x10f46c
  10192e:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  101935:	83 e0 f0             	and    $0xfffffff0,%eax
  101938:	83 c8 0e             	or     $0xe,%eax
  10193b:	a2 6d f4 10 00       	mov    %al,0x10f46d
  101940:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  101947:	83 e0 ef             	and    $0xffffffef,%eax
  10194a:	a2 6d f4 10 00       	mov    %al,0x10f46d
  10194f:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  101956:	83 c8 60             	or     $0x60,%eax
  101959:	a2 6d f4 10 00       	mov    %al,0x10f46d
  10195e:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  101965:	83 c8 80             	or     $0xffffff80,%eax
  101968:	a2 6d f4 10 00       	mov    %al,0x10f46d
  10196d:	a1 c4 e7 10 00       	mov    0x10e7c4,%eax
  101972:	c1 e8 10             	shr    $0x10,%eax
  101975:	66 a3 6e f4 10 00    	mov    %ax,0x10f46e
  10197b:	c7 45 f8 60 e5 10 00 	movl   $0x10e560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd));
  101982:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101985:	0f 01 18             	lidtl  (%eax)
     //指令lidt把中断门描述符表的起始地址装入IDTR寄存器
    lidt(&idt_pd);
}
  101988:	c9                   	leave  
  101989:	c3                   	ret    

0010198a <trapname>:

static const char *
trapname(int trapno) {
  10198a:	55                   	push   %ebp
  10198b:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  10198d:	8b 45 08             	mov    0x8(%ebp),%eax
  101990:	83 f8 13             	cmp    $0x13,%eax
  101993:	77 0c                	ja     1019a1 <trapname+0x17>
        return excnames[trapno];
  101995:	8b 45 08             	mov    0x8(%ebp),%eax
  101998:	8b 04 85 80 3b 10 00 	mov    0x103b80(,%eax,4),%eax
  10199f:	eb 18                	jmp    1019b9 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  1019a1:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  1019a5:	7e 0d                	jle    1019b4 <trapname+0x2a>
  1019a7:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  1019ab:	7f 07                	jg     1019b4 <trapname+0x2a>
        return "Hardware Interrupt";
  1019ad:	b8 2a 38 10 00       	mov    $0x10382a,%eax
  1019b2:	eb 05                	jmp    1019b9 <trapname+0x2f>
    }
    return "(unknown trap)";
  1019b4:	b8 3d 38 10 00       	mov    $0x10383d,%eax
}
  1019b9:	5d                   	pop    %ebp
  1019ba:	c3                   	ret    

001019bb <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  1019bb:	55                   	push   %ebp
  1019bc:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  1019be:	8b 45 08             	mov    0x8(%ebp),%eax
  1019c1:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  1019c5:	66 83 f8 08          	cmp    $0x8,%ax
  1019c9:	0f 94 c0             	sete   %al
  1019cc:	0f b6 c0             	movzbl %al,%eax
}
  1019cf:	5d                   	pop    %ebp
  1019d0:	c3                   	ret    

001019d1 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  1019d1:	55                   	push   %ebp
  1019d2:	89 e5                	mov    %esp,%ebp
  1019d4:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  1019d7:	8b 45 08             	mov    0x8(%ebp),%eax
  1019da:	89 44 24 04          	mov    %eax,0x4(%esp)
  1019de:	c7 04 24 7e 38 10 00 	movl   $0x10387e,(%esp)
  1019e5:	e8 72 e8 ff ff       	call   10025c <cprintf>
    print_regs(&tf->tf_regs);
  1019ea:	8b 45 08             	mov    0x8(%ebp),%eax
  1019ed:	89 04 24             	mov    %eax,(%esp)
  1019f0:	e8 a1 01 00 00       	call   101b96 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  1019f5:	8b 45 08             	mov    0x8(%ebp),%eax
  1019f8:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  1019fc:	0f b7 c0             	movzwl %ax,%eax
  1019ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a03:	c7 04 24 8f 38 10 00 	movl   $0x10388f,(%esp)
  101a0a:	e8 4d e8 ff ff       	call   10025c <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  101a12:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101a16:	0f b7 c0             	movzwl %ax,%eax
  101a19:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a1d:	c7 04 24 a2 38 10 00 	movl   $0x1038a2,(%esp)
  101a24:	e8 33 e8 ff ff       	call   10025c <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101a29:	8b 45 08             	mov    0x8(%ebp),%eax
  101a2c:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101a30:	0f b7 c0             	movzwl %ax,%eax
  101a33:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a37:	c7 04 24 b5 38 10 00 	movl   $0x1038b5,(%esp)
  101a3e:	e8 19 e8 ff ff       	call   10025c <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101a43:	8b 45 08             	mov    0x8(%ebp),%eax
  101a46:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101a4a:	0f b7 c0             	movzwl %ax,%eax
  101a4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a51:	c7 04 24 c8 38 10 00 	movl   $0x1038c8,(%esp)
  101a58:	e8 ff e7 ff ff       	call   10025c <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101a5d:	8b 45 08             	mov    0x8(%ebp),%eax
  101a60:	8b 40 30             	mov    0x30(%eax),%eax
  101a63:	89 04 24             	mov    %eax,(%esp)
  101a66:	e8 1f ff ff ff       	call   10198a <trapname>
  101a6b:	8b 55 08             	mov    0x8(%ebp),%edx
  101a6e:	8b 52 30             	mov    0x30(%edx),%edx
  101a71:	89 44 24 08          	mov    %eax,0x8(%esp)
  101a75:	89 54 24 04          	mov    %edx,0x4(%esp)
  101a79:	c7 04 24 db 38 10 00 	movl   $0x1038db,(%esp)
  101a80:	e8 d7 e7 ff ff       	call   10025c <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101a85:	8b 45 08             	mov    0x8(%ebp),%eax
  101a88:	8b 40 34             	mov    0x34(%eax),%eax
  101a8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a8f:	c7 04 24 ed 38 10 00 	movl   $0x1038ed,(%esp)
  101a96:	e8 c1 e7 ff ff       	call   10025c <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101a9b:	8b 45 08             	mov    0x8(%ebp),%eax
  101a9e:	8b 40 38             	mov    0x38(%eax),%eax
  101aa1:	89 44 24 04          	mov    %eax,0x4(%esp)
  101aa5:	c7 04 24 fc 38 10 00 	movl   $0x1038fc,(%esp)
  101aac:	e8 ab e7 ff ff       	call   10025c <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101ab1:	8b 45 08             	mov    0x8(%ebp),%eax
  101ab4:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101ab8:	0f b7 c0             	movzwl %ax,%eax
  101abb:	89 44 24 04          	mov    %eax,0x4(%esp)
  101abf:	c7 04 24 0b 39 10 00 	movl   $0x10390b,(%esp)
  101ac6:	e8 91 e7 ff ff       	call   10025c <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101acb:	8b 45 08             	mov    0x8(%ebp),%eax
  101ace:	8b 40 40             	mov    0x40(%eax),%eax
  101ad1:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ad5:	c7 04 24 1e 39 10 00 	movl   $0x10391e,(%esp)
  101adc:	e8 7b e7 ff ff       	call   10025c <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101ae1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101ae8:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101aef:	eb 3e                	jmp    101b2f <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101af1:	8b 45 08             	mov    0x8(%ebp),%eax
  101af4:	8b 50 40             	mov    0x40(%eax),%edx
  101af7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101afa:	21 d0                	and    %edx,%eax
  101afc:	85 c0                	test   %eax,%eax
  101afe:	74 28                	je     101b28 <print_trapframe+0x157>
  101b00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b03:	8b 04 85 80 e5 10 00 	mov    0x10e580(,%eax,4),%eax
  101b0a:	85 c0                	test   %eax,%eax
  101b0c:	74 1a                	je     101b28 <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
  101b0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b11:	8b 04 85 80 e5 10 00 	mov    0x10e580(,%eax,4),%eax
  101b18:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b1c:	c7 04 24 2d 39 10 00 	movl   $0x10392d,(%esp)
  101b23:	e8 34 e7 ff ff       	call   10025c <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101b28:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  101b2c:	d1 65 f0             	shll   -0x10(%ebp)
  101b2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b32:	83 f8 17             	cmp    $0x17,%eax
  101b35:	76 ba                	jbe    101af1 <print_trapframe+0x120>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101b37:	8b 45 08             	mov    0x8(%ebp),%eax
  101b3a:	8b 40 40             	mov    0x40(%eax),%eax
  101b3d:	25 00 30 00 00       	and    $0x3000,%eax
  101b42:	c1 e8 0c             	shr    $0xc,%eax
  101b45:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b49:	c7 04 24 31 39 10 00 	movl   $0x103931,(%esp)
  101b50:	e8 07 e7 ff ff       	call   10025c <cprintf>

    if (!trap_in_kernel(tf)) {
  101b55:	8b 45 08             	mov    0x8(%ebp),%eax
  101b58:	89 04 24             	mov    %eax,(%esp)
  101b5b:	e8 5b fe ff ff       	call   1019bb <trap_in_kernel>
  101b60:	85 c0                	test   %eax,%eax
  101b62:	75 30                	jne    101b94 <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101b64:	8b 45 08             	mov    0x8(%ebp),%eax
  101b67:	8b 40 44             	mov    0x44(%eax),%eax
  101b6a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b6e:	c7 04 24 3a 39 10 00 	movl   $0x10393a,(%esp)
  101b75:	e8 e2 e6 ff ff       	call   10025c <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101b7a:	8b 45 08             	mov    0x8(%ebp),%eax
  101b7d:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101b81:	0f b7 c0             	movzwl %ax,%eax
  101b84:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b88:	c7 04 24 49 39 10 00 	movl   $0x103949,(%esp)
  101b8f:	e8 c8 e6 ff ff       	call   10025c <cprintf>
    }
}
  101b94:	c9                   	leave  
  101b95:	c3                   	ret    

00101b96 <print_regs>:

void
print_regs(struct pushregs *regs) {
  101b96:	55                   	push   %ebp
  101b97:	89 e5                	mov    %esp,%ebp
  101b99:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101b9c:	8b 45 08             	mov    0x8(%ebp),%eax
  101b9f:	8b 00                	mov    (%eax),%eax
  101ba1:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ba5:	c7 04 24 5c 39 10 00 	movl   $0x10395c,(%esp)
  101bac:	e8 ab e6 ff ff       	call   10025c <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101bb1:	8b 45 08             	mov    0x8(%ebp),%eax
  101bb4:	8b 40 04             	mov    0x4(%eax),%eax
  101bb7:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bbb:	c7 04 24 6b 39 10 00 	movl   $0x10396b,(%esp)
  101bc2:	e8 95 e6 ff ff       	call   10025c <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101bc7:	8b 45 08             	mov    0x8(%ebp),%eax
  101bca:	8b 40 08             	mov    0x8(%eax),%eax
  101bcd:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bd1:	c7 04 24 7a 39 10 00 	movl   $0x10397a,(%esp)
  101bd8:	e8 7f e6 ff ff       	call   10025c <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101bdd:	8b 45 08             	mov    0x8(%ebp),%eax
  101be0:	8b 40 0c             	mov    0xc(%eax),%eax
  101be3:	89 44 24 04          	mov    %eax,0x4(%esp)
  101be7:	c7 04 24 89 39 10 00 	movl   $0x103989,(%esp)
  101bee:	e8 69 e6 ff ff       	call   10025c <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101bf3:	8b 45 08             	mov    0x8(%ebp),%eax
  101bf6:	8b 40 10             	mov    0x10(%eax),%eax
  101bf9:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bfd:	c7 04 24 98 39 10 00 	movl   $0x103998,(%esp)
  101c04:	e8 53 e6 ff ff       	call   10025c <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101c09:	8b 45 08             	mov    0x8(%ebp),%eax
  101c0c:	8b 40 14             	mov    0x14(%eax),%eax
  101c0f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c13:	c7 04 24 a7 39 10 00 	movl   $0x1039a7,(%esp)
  101c1a:	e8 3d e6 ff ff       	call   10025c <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101c1f:	8b 45 08             	mov    0x8(%ebp),%eax
  101c22:	8b 40 18             	mov    0x18(%eax),%eax
  101c25:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c29:	c7 04 24 b6 39 10 00 	movl   $0x1039b6,(%esp)
  101c30:	e8 27 e6 ff ff       	call   10025c <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101c35:	8b 45 08             	mov    0x8(%ebp),%eax
  101c38:	8b 40 1c             	mov    0x1c(%eax),%eax
  101c3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c3f:	c7 04 24 c5 39 10 00 	movl   $0x1039c5,(%esp)
  101c46:	e8 11 e6 ff ff       	call   10025c <cprintf>
}
  101c4b:	c9                   	leave  
  101c4c:	c3                   	ret    

00101c4d <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101c4d:	55                   	push   %ebp
  101c4e:	89 e5                	mov    %esp,%ebp
  101c50:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
  101c53:	8b 45 08             	mov    0x8(%ebp),%eax
  101c56:	8b 40 30             	mov    0x30(%eax),%eax
  101c59:	83 f8 2f             	cmp    $0x2f,%eax
  101c5c:	77 21                	ja     101c7f <trap_dispatch+0x32>
  101c5e:	83 f8 2e             	cmp    $0x2e,%eax
  101c61:	0f 83 0b 01 00 00    	jae    101d72 <trap_dispatch+0x125>
  101c67:	83 f8 21             	cmp    $0x21,%eax
  101c6a:	0f 84 88 00 00 00    	je     101cf8 <trap_dispatch+0xab>
  101c70:	83 f8 24             	cmp    $0x24,%eax
  101c73:	74 5d                	je     101cd2 <trap_dispatch+0x85>
  101c75:	83 f8 20             	cmp    $0x20,%eax
  101c78:	74 16                	je     101c90 <trap_dispatch+0x43>
  101c7a:	e9 bb 00 00 00       	jmp    101d3a <trap_dispatch+0xed>
  101c7f:	83 e8 78             	sub    $0x78,%eax
  101c82:	83 f8 01             	cmp    $0x1,%eax
  101c85:	0f 87 af 00 00 00    	ja     101d3a <trap_dispatch+0xed>
  101c8b:	e9 8e 00 00 00       	jmp    101d1e <trap_dispatch+0xd1>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
	    if (((++ticks) % TICK_NUM) == 0) {
  101c90:	a1 08 f9 10 00       	mov    0x10f908,%eax
  101c95:	83 c0 01             	add    $0x1,%eax
  101c98:	89 c1                	mov    %eax,%ecx
  101c9a:	89 0d 08 f9 10 00    	mov    %ecx,0x10f908
  101ca0:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101ca5:	89 c8                	mov    %ecx,%eax
  101ca7:	f7 e2                	mul    %edx
  101ca9:	89 d0                	mov    %edx,%eax
  101cab:	c1 e8 05             	shr    $0x5,%eax
  101cae:	6b c0 64             	imul   $0x64,%eax,%eax
  101cb1:	29 c1                	sub    %eax,%ecx
  101cb3:	89 c8                	mov    %ecx,%eax
  101cb5:	85 c0                	test   %eax,%eax
  101cb7:	75 14                	jne    101ccd <trap_dispatch+0x80>
		print_ticks();
  101cb9:	e8 40 fb ff ff       	call   1017fe <print_ticks>
		ticks = 0;
  101cbe:	c7 05 08 f9 10 00 00 	movl   $0x0,0x10f908
  101cc5:	00 00 00 
        }
        break;
  101cc8:	e9 a6 00 00 00       	jmp    101d73 <trap_dispatch+0x126>
  101ccd:	e9 a1 00 00 00       	jmp    101d73 <trap_dispatch+0x126>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101cd2:	e8 fe f8 ff ff       	call   1015d5 <cons_getc>
  101cd7:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101cda:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101cde:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101ce2:	89 54 24 08          	mov    %edx,0x8(%esp)
  101ce6:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cea:	c7 04 24 d4 39 10 00 	movl   $0x1039d4,(%esp)
  101cf1:	e8 66 e5 ff ff       	call   10025c <cprintf>
        break;
  101cf6:	eb 7b                	jmp    101d73 <trap_dispatch+0x126>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101cf8:	e8 d8 f8 ff ff       	call   1015d5 <cons_getc>
  101cfd:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101d00:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101d04:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101d08:	89 54 24 08          	mov    %edx,0x8(%esp)
  101d0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d10:	c7 04 24 e6 39 10 00 	movl   $0x1039e6,(%esp)
  101d17:	e8 40 e5 ff ff       	call   10025c <cprintf>
        break;
  101d1c:	eb 55                	jmp    101d73 <trap_dispatch+0x126>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
  101d1e:	c7 44 24 08 f5 39 10 	movl   $0x1039f5,0x8(%esp)
  101d25:	00 
  101d26:	c7 44 24 04 b4 00 00 	movl   $0xb4,0x4(%esp)
  101d2d:	00 
  101d2e:	c7 04 24 05 3a 10 00 	movl   $0x103a05,(%esp)
  101d35:	e8 79 e6 ff ff       	call   1003b3 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101d3a:	8b 45 08             	mov    0x8(%ebp),%eax
  101d3d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101d41:	0f b7 c0             	movzwl %ax,%eax
  101d44:	83 e0 03             	and    $0x3,%eax
  101d47:	85 c0                	test   %eax,%eax
  101d49:	75 28                	jne    101d73 <trap_dispatch+0x126>
            print_trapframe(tf);
  101d4b:	8b 45 08             	mov    0x8(%ebp),%eax
  101d4e:	89 04 24             	mov    %eax,(%esp)
  101d51:	e8 7b fc ff ff       	call   1019d1 <print_trapframe>
            panic("unexpected trap in kernel.\n");
  101d56:	c7 44 24 08 16 3a 10 	movl   $0x103a16,0x8(%esp)
  101d5d:	00 
  101d5e:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
  101d65:	00 
  101d66:	c7 04 24 05 3a 10 00 	movl   $0x103a05,(%esp)
  101d6d:	e8 41 e6 ff ff       	call   1003b3 <__panic>
        break;
  101d72:	90                   	nop
        }
    }
}
  101d73:	c9                   	leave  
  101d74:	c3                   	ret    

00101d75 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101d75:	55                   	push   %ebp
  101d76:	89 e5                	mov    %esp,%ebp
  101d78:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101d7b:	8b 45 08             	mov    0x8(%ebp),%eax
  101d7e:	89 04 24             	mov    %eax,(%esp)
  101d81:	e8 c7 fe ff ff       	call   101c4d <trap_dispatch>
}
  101d86:	c9                   	leave  
  101d87:	c3                   	ret    

00101d88 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101d88:	6a 00                	push   $0x0
  pushl $0
  101d8a:	6a 00                	push   $0x0
  jmp __alltraps
  101d8c:	e9 69 0a 00 00       	jmp    1027fa <__alltraps>

00101d91 <vector1>:
.globl vector1
vector1:
  pushl $0
  101d91:	6a 00                	push   $0x0
  pushl $1
  101d93:	6a 01                	push   $0x1
  jmp __alltraps
  101d95:	e9 60 0a 00 00       	jmp    1027fa <__alltraps>

00101d9a <vector2>:
.globl vector2
vector2:
  pushl $0
  101d9a:	6a 00                	push   $0x0
  pushl $2
  101d9c:	6a 02                	push   $0x2
  jmp __alltraps
  101d9e:	e9 57 0a 00 00       	jmp    1027fa <__alltraps>

00101da3 <vector3>:
.globl vector3
vector3:
  pushl $0
  101da3:	6a 00                	push   $0x0
  pushl $3
  101da5:	6a 03                	push   $0x3
  jmp __alltraps
  101da7:	e9 4e 0a 00 00       	jmp    1027fa <__alltraps>

00101dac <vector4>:
.globl vector4
vector4:
  pushl $0
  101dac:	6a 00                	push   $0x0
  pushl $4
  101dae:	6a 04                	push   $0x4
  jmp __alltraps
  101db0:	e9 45 0a 00 00       	jmp    1027fa <__alltraps>

00101db5 <vector5>:
.globl vector5
vector5:
  pushl $0
  101db5:	6a 00                	push   $0x0
  pushl $5
  101db7:	6a 05                	push   $0x5
  jmp __alltraps
  101db9:	e9 3c 0a 00 00       	jmp    1027fa <__alltraps>

00101dbe <vector6>:
.globl vector6
vector6:
  pushl $0
  101dbe:	6a 00                	push   $0x0
  pushl $6
  101dc0:	6a 06                	push   $0x6
  jmp __alltraps
  101dc2:	e9 33 0a 00 00       	jmp    1027fa <__alltraps>

00101dc7 <vector7>:
.globl vector7
vector7:
  pushl $0
  101dc7:	6a 00                	push   $0x0
  pushl $7
  101dc9:	6a 07                	push   $0x7
  jmp __alltraps
  101dcb:	e9 2a 0a 00 00       	jmp    1027fa <__alltraps>

00101dd0 <vector8>:
.globl vector8
vector8:
  pushl $8
  101dd0:	6a 08                	push   $0x8
  jmp __alltraps
  101dd2:	e9 23 0a 00 00       	jmp    1027fa <__alltraps>

00101dd7 <vector9>:
.globl vector9
vector9:
  pushl $0
  101dd7:	6a 00                	push   $0x0
  pushl $9
  101dd9:	6a 09                	push   $0x9
  jmp __alltraps
  101ddb:	e9 1a 0a 00 00       	jmp    1027fa <__alltraps>

00101de0 <vector10>:
.globl vector10
vector10:
  pushl $10
  101de0:	6a 0a                	push   $0xa
  jmp __alltraps
  101de2:	e9 13 0a 00 00       	jmp    1027fa <__alltraps>

00101de7 <vector11>:
.globl vector11
vector11:
  pushl $11
  101de7:	6a 0b                	push   $0xb
  jmp __alltraps
  101de9:	e9 0c 0a 00 00       	jmp    1027fa <__alltraps>

00101dee <vector12>:
.globl vector12
vector12:
  pushl $12
  101dee:	6a 0c                	push   $0xc
  jmp __alltraps
  101df0:	e9 05 0a 00 00       	jmp    1027fa <__alltraps>

00101df5 <vector13>:
.globl vector13
vector13:
  pushl $13
  101df5:	6a 0d                	push   $0xd
  jmp __alltraps
  101df7:	e9 fe 09 00 00       	jmp    1027fa <__alltraps>

00101dfc <vector14>:
.globl vector14
vector14:
  pushl $14
  101dfc:	6a 0e                	push   $0xe
  jmp __alltraps
  101dfe:	e9 f7 09 00 00       	jmp    1027fa <__alltraps>

00101e03 <vector15>:
.globl vector15
vector15:
  pushl $0
  101e03:	6a 00                	push   $0x0
  pushl $15
  101e05:	6a 0f                	push   $0xf
  jmp __alltraps
  101e07:	e9 ee 09 00 00       	jmp    1027fa <__alltraps>

00101e0c <vector16>:
.globl vector16
vector16:
  pushl $0
  101e0c:	6a 00                	push   $0x0
  pushl $16
  101e0e:	6a 10                	push   $0x10
  jmp __alltraps
  101e10:	e9 e5 09 00 00       	jmp    1027fa <__alltraps>

00101e15 <vector17>:
.globl vector17
vector17:
  pushl $17
  101e15:	6a 11                	push   $0x11
  jmp __alltraps
  101e17:	e9 de 09 00 00       	jmp    1027fa <__alltraps>

00101e1c <vector18>:
.globl vector18
vector18:
  pushl $0
  101e1c:	6a 00                	push   $0x0
  pushl $18
  101e1e:	6a 12                	push   $0x12
  jmp __alltraps
  101e20:	e9 d5 09 00 00       	jmp    1027fa <__alltraps>

00101e25 <vector19>:
.globl vector19
vector19:
  pushl $0
  101e25:	6a 00                	push   $0x0
  pushl $19
  101e27:	6a 13                	push   $0x13
  jmp __alltraps
  101e29:	e9 cc 09 00 00       	jmp    1027fa <__alltraps>

00101e2e <vector20>:
.globl vector20
vector20:
  pushl $0
  101e2e:	6a 00                	push   $0x0
  pushl $20
  101e30:	6a 14                	push   $0x14
  jmp __alltraps
  101e32:	e9 c3 09 00 00       	jmp    1027fa <__alltraps>

00101e37 <vector21>:
.globl vector21
vector21:
  pushl $0
  101e37:	6a 00                	push   $0x0
  pushl $21
  101e39:	6a 15                	push   $0x15
  jmp __alltraps
  101e3b:	e9 ba 09 00 00       	jmp    1027fa <__alltraps>

00101e40 <vector22>:
.globl vector22
vector22:
  pushl $0
  101e40:	6a 00                	push   $0x0
  pushl $22
  101e42:	6a 16                	push   $0x16
  jmp __alltraps
  101e44:	e9 b1 09 00 00       	jmp    1027fa <__alltraps>

00101e49 <vector23>:
.globl vector23
vector23:
  pushl $0
  101e49:	6a 00                	push   $0x0
  pushl $23
  101e4b:	6a 17                	push   $0x17
  jmp __alltraps
  101e4d:	e9 a8 09 00 00       	jmp    1027fa <__alltraps>

00101e52 <vector24>:
.globl vector24
vector24:
  pushl $0
  101e52:	6a 00                	push   $0x0
  pushl $24
  101e54:	6a 18                	push   $0x18
  jmp __alltraps
  101e56:	e9 9f 09 00 00       	jmp    1027fa <__alltraps>

00101e5b <vector25>:
.globl vector25
vector25:
  pushl $0
  101e5b:	6a 00                	push   $0x0
  pushl $25
  101e5d:	6a 19                	push   $0x19
  jmp __alltraps
  101e5f:	e9 96 09 00 00       	jmp    1027fa <__alltraps>

00101e64 <vector26>:
.globl vector26
vector26:
  pushl $0
  101e64:	6a 00                	push   $0x0
  pushl $26
  101e66:	6a 1a                	push   $0x1a
  jmp __alltraps
  101e68:	e9 8d 09 00 00       	jmp    1027fa <__alltraps>

00101e6d <vector27>:
.globl vector27
vector27:
  pushl $0
  101e6d:	6a 00                	push   $0x0
  pushl $27
  101e6f:	6a 1b                	push   $0x1b
  jmp __alltraps
  101e71:	e9 84 09 00 00       	jmp    1027fa <__alltraps>

00101e76 <vector28>:
.globl vector28
vector28:
  pushl $0
  101e76:	6a 00                	push   $0x0
  pushl $28
  101e78:	6a 1c                	push   $0x1c
  jmp __alltraps
  101e7a:	e9 7b 09 00 00       	jmp    1027fa <__alltraps>

00101e7f <vector29>:
.globl vector29
vector29:
  pushl $0
  101e7f:	6a 00                	push   $0x0
  pushl $29
  101e81:	6a 1d                	push   $0x1d
  jmp __alltraps
  101e83:	e9 72 09 00 00       	jmp    1027fa <__alltraps>

00101e88 <vector30>:
.globl vector30
vector30:
  pushl $0
  101e88:	6a 00                	push   $0x0
  pushl $30
  101e8a:	6a 1e                	push   $0x1e
  jmp __alltraps
  101e8c:	e9 69 09 00 00       	jmp    1027fa <__alltraps>

00101e91 <vector31>:
.globl vector31
vector31:
  pushl $0
  101e91:	6a 00                	push   $0x0
  pushl $31
  101e93:	6a 1f                	push   $0x1f
  jmp __alltraps
  101e95:	e9 60 09 00 00       	jmp    1027fa <__alltraps>

00101e9a <vector32>:
.globl vector32
vector32:
  pushl $0
  101e9a:	6a 00                	push   $0x0
  pushl $32
  101e9c:	6a 20                	push   $0x20
  jmp __alltraps
  101e9e:	e9 57 09 00 00       	jmp    1027fa <__alltraps>

00101ea3 <vector33>:
.globl vector33
vector33:
  pushl $0
  101ea3:	6a 00                	push   $0x0
  pushl $33
  101ea5:	6a 21                	push   $0x21
  jmp __alltraps
  101ea7:	e9 4e 09 00 00       	jmp    1027fa <__alltraps>

00101eac <vector34>:
.globl vector34
vector34:
  pushl $0
  101eac:	6a 00                	push   $0x0
  pushl $34
  101eae:	6a 22                	push   $0x22
  jmp __alltraps
  101eb0:	e9 45 09 00 00       	jmp    1027fa <__alltraps>

00101eb5 <vector35>:
.globl vector35
vector35:
  pushl $0
  101eb5:	6a 00                	push   $0x0
  pushl $35
  101eb7:	6a 23                	push   $0x23
  jmp __alltraps
  101eb9:	e9 3c 09 00 00       	jmp    1027fa <__alltraps>

00101ebe <vector36>:
.globl vector36
vector36:
  pushl $0
  101ebe:	6a 00                	push   $0x0
  pushl $36
  101ec0:	6a 24                	push   $0x24
  jmp __alltraps
  101ec2:	e9 33 09 00 00       	jmp    1027fa <__alltraps>

00101ec7 <vector37>:
.globl vector37
vector37:
  pushl $0
  101ec7:	6a 00                	push   $0x0
  pushl $37
  101ec9:	6a 25                	push   $0x25
  jmp __alltraps
  101ecb:	e9 2a 09 00 00       	jmp    1027fa <__alltraps>

00101ed0 <vector38>:
.globl vector38
vector38:
  pushl $0
  101ed0:	6a 00                	push   $0x0
  pushl $38
  101ed2:	6a 26                	push   $0x26
  jmp __alltraps
  101ed4:	e9 21 09 00 00       	jmp    1027fa <__alltraps>

00101ed9 <vector39>:
.globl vector39
vector39:
  pushl $0
  101ed9:	6a 00                	push   $0x0
  pushl $39
  101edb:	6a 27                	push   $0x27
  jmp __alltraps
  101edd:	e9 18 09 00 00       	jmp    1027fa <__alltraps>

00101ee2 <vector40>:
.globl vector40
vector40:
  pushl $0
  101ee2:	6a 00                	push   $0x0
  pushl $40
  101ee4:	6a 28                	push   $0x28
  jmp __alltraps
  101ee6:	e9 0f 09 00 00       	jmp    1027fa <__alltraps>

00101eeb <vector41>:
.globl vector41
vector41:
  pushl $0
  101eeb:	6a 00                	push   $0x0
  pushl $41
  101eed:	6a 29                	push   $0x29
  jmp __alltraps
  101eef:	e9 06 09 00 00       	jmp    1027fa <__alltraps>

00101ef4 <vector42>:
.globl vector42
vector42:
  pushl $0
  101ef4:	6a 00                	push   $0x0
  pushl $42
  101ef6:	6a 2a                	push   $0x2a
  jmp __alltraps
  101ef8:	e9 fd 08 00 00       	jmp    1027fa <__alltraps>

00101efd <vector43>:
.globl vector43
vector43:
  pushl $0
  101efd:	6a 00                	push   $0x0
  pushl $43
  101eff:	6a 2b                	push   $0x2b
  jmp __alltraps
  101f01:	e9 f4 08 00 00       	jmp    1027fa <__alltraps>

00101f06 <vector44>:
.globl vector44
vector44:
  pushl $0
  101f06:	6a 00                	push   $0x0
  pushl $44
  101f08:	6a 2c                	push   $0x2c
  jmp __alltraps
  101f0a:	e9 eb 08 00 00       	jmp    1027fa <__alltraps>

00101f0f <vector45>:
.globl vector45
vector45:
  pushl $0
  101f0f:	6a 00                	push   $0x0
  pushl $45
  101f11:	6a 2d                	push   $0x2d
  jmp __alltraps
  101f13:	e9 e2 08 00 00       	jmp    1027fa <__alltraps>

00101f18 <vector46>:
.globl vector46
vector46:
  pushl $0
  101f18:	6a 00                	push   $0x0
  pushl $46
  101f1a:	6a 2e                	push   $0x2e
  jmp __alltraps
  101f1c:	e9 d9 08 00 00       	jmp    1027fa <__alltraps>

00101f21 <vector47>:
.globl vector47
vector47:
  pushl $0
  101f21:	6a 00                	push   $0x0
  pushl $47
  101f23:	6a 2f                	push   $0x2f
  jmp __alltraps
  101f25:	e9 d0 08 00 00       	jmp    1027fa <__alltraps>

00101f2a <vector48>:
.globl vector48
vector48:
  pushl $0
  101f2a:	6a 00                	push   $0x0
  pushl $48
  101f2c:	6a 30                	push   $0x30
  jmp __alltraps
  101f2e:	e9 c7 08 00 00       	jmp    1027fa <__alltraps>

00101f33 <vector49>:
.globl vector49
vector49:
  pushl $0
  101f33:	6a 00                	push   $0x0
  pushl $49
  101f35:	6a 31                	push   $0x31
  jmp __alltraps
  101f37:	e9 be 08 00 00       	jmp    1027fa <__alltraps>

00101f3c <vector50>:
.globl vector50
vector50:
  pushl $0
  101f3c:	6a 00                	push   $0x0
  pushl $50
  101f3e:	6a 32                	push   $0x32
  jmp __alltraps
  101f40:	e9 b5 08 00 00       	jmp    1027fa <__alltraps>

00101f45 <vector51>:
.globl vector51
vector51:
  pushl $0
  101f45:	6a 00                	push   $0x0
  pushl $51
  101f47:	6a 33                	push   $0x33
  jmp __alltraps
  101f49:	e9 ac 08 00 00       	jmp    1027fa <__alltraps>

00101f4e <vector52>:
.globl vector52
vector52:
  pushl $0
  101f4e:	6a 00                	push   $0x0
  pushl $52
  101f50:	6a 34                	push   $0x34
  jmp __alltraps
  101f52:	e9 a3 08 00 00       	jmp    1027fa <__alltraps>

00101f57 <vector53>:
.globl vector53
vector53:
  pushl $0
  101f57:	6a 00                	push   $0x0
  pushl $53
  101f59:	6a 35                	push   $0x35
  jmp __alltraps
  101f5b:	e9 9a 08 00 00       	jmp    1027fa <__alltraps>

00101f60 <vector54>:
.globl vector54
vector54:
  pushl $0
  101f60:	6a 00                	push   $0x0
  pushl $54
  101f62:	6a 36                	push   $0x36
  jmp __alltraps
  101f64:	e9 91 08 00 00       	jmp    1027fa <__alltraps>

00101f69 <vector55>:
.globl vector55
vector55:
  pushl $0
  101f69:	6a 00                	push   $0x0
  pushl $55
  101f6b:	6a 37                	push   $0x37
  jmp __alltraps
  101f6d:	e9 88 08 00 00       	jmp    1027fa <__alltraps>

00101f72 <vector56>:
.globl vector56
vector56:
  pushl $0
  101f72:	6a 00                	push   $0x0
  pushl $56
  101f74:	6a 38                	push   $0x38
  jmp __alltraps
  101f76:	e9 7f 08 00 00       	jmp    1027fa <__alltraps>

00101f7b <vector57>:
.globl vector57
vector57:
  pushl $0
  101f7b:	6a 00                	push   $0x0
  pushl $57
  101f7d:	6a 39                	push   $0x39
  jmp __alltraps
  101f7f:	e9 76 08 00 00       	jmp    1027fa <__alltraps>

00101f84 <vector58>:
.globl vector58
vector58:
  pushl $0
  101f84:	6a 00                	push   $0x0
  pushl $58
  101f86:	6a 3a                	push   $0x3a
  jmp __alltraps
  101f88:	e9 6d 08 00 00       	jmp    1027fa <__alltraps>

00101f8d <vector59>:
.globl vector59
vector59:
  pushl $0
  101f8d:	6a 00                	push   $0x0
  pushl $59
  101f8f:	6a 3b                	push   $0x3b
  jmp __alltraps
  101f91:	e9 64 08 00 00       	jmp    1027fa <__alltraps>

00101f96 <vector60>:
.globl vector60
vector60:
  pushl $0
  101f96:	6a 00                	push   $0x0
  pushl $60
  101f98:	6a 3c                	push   $0x3c
  jmp __alltraps
  101f9a:	e9 5b 08 00 00       	jmp    1027fa <__alltraps>

00101f9f <vector61>:
.globl vector61
vector61:
  pushl $0
  101f9f:	6a 00                	push   $0x0
  pushl $61
  101fa1:	6a 3d                	push   $0x3d
  jmp __alltraps
  101fa3:	e9 52 08 00 00       	jmp    1027fa <__alltraps>

00101fa8 <vector62>:
.globl vector62
vector62:
  pushl $0
  101fa8:	6a 00                	push   $0x0
  pushl $62
  101faa:	6a 3e                	push   $0x3e
  jmp __alltraps
  101fac:	e9 49 08 00 00       	jmp    1027fa <__alltraps>

00101fb1 <vector63>:
.globl vector63
vector63:
  pushl $0
  101fb1:	6a 00                	push   $0x0
  pushl $63
  101fb3:	6a 3f                	push   $0x3f
  jmp __alltraps
  101fb5:	e9 40 08 00 00       	jmp    1027fa <__alltraps>

00101fba <vector64>:
.globl vector64
vector64:
  pushl $0
  101fba:	6a 00                	push   $0x0
  pushl $64
  101fbc:	6a 40                	push   $0x40
  jmp __alltraps
  101fbe:	e9 37 08 00 00       	jmp    1027fa <__alltraps>

00101fc3 <vector65>:
.globl vector65
vector65:
  pushl $0
  101fc3:	6a 00                	push   $0x0
  pushl $65
  101fc5:	6a 41                	push   $0x41
  jmp __alltraps
  101fc7:	e9 2e 08 00 00       	jmp    1027fa <__alltraps>

00101fcc <vector66>:
.globl vector66
vector66:
  pushl $0
  101fcc:	6a 00                	push   $0x0
  pushl $66
  101fce:	6a 42                	push   $0x42
  jmp __alltraps
  101fd0:	e9 25 08 00 00       	jmp    1027fa <__alltraps>

00101fd5 <vector67>:
.globl vector67
vector67:
  pushl $0
  101fd5:	6a 00                	push   $0x0
  pushl $67
  101fd7:	6a 43                	push   $0x43
  jmp __alltraps
  101fd9:	e9 1c 08 00 00       	jmp    1027fa <__alltraps>

00101fde <vector68>:
.globl vector68
vector68:
  pushl $0
  101fde:	6a 00                	push   $0x0
  pushl $68
  101fe0:	6a 44                	push   $0x44
  jmp __alltraps
  101fe2:	e9 13 08 00 00       	jmp    1027fa <__alltraps>

00101fe7 <vector69>:
.globl vector69
vector69:
  pushl $0
  101fe7:	6a 00                	push   $0x0
  pushl $69
  101fe9:	6a 45                	push   $0x45
  jmp __alltraps
  101feb:	e9 0a 08 00 00       	jmp    1027fa <__alltraps>

00101ff0 <vector70>:
.globl vector70
vector70:
  pushl $0
  101ff0:	6a 00                	push   $0x0
  pushl $70
  101ff2:	6a 46                	push   $0x46
  jmp __alltraps
  101ff4:	e9 01 08 00 00       	jmp    1027fa <__alltraps>

00101ff9 <vector71>:
.globl vector71
vector71:
  pushl $0
  101ff9:	6a 00                	push   $0x0
  pushl $71
  101ffb:	6a 47                	push   $0x47
  jmp __alltraps
  101ffd:	e9 f8 07 00 00       	jmp    1027fa <__alltraps>

00102002 <vector72>:
.globl vector72
vector72:
  pushl $0
  102002:	6a 00                	push   $0x0
  pushl $72
  102004:	6a 48                	push   $0x48
  jmp __alltraps
  102006:	e9 ef 07 00 00       	jmp    1027fa <__alltraps>

0010200b <vector73>:
.globl vector73
vector73:
  pushl $0
  10200b:	6a 00                	push   $0x0
  pushl $73
  10200d:	6a 49                	push   $0x49
  jmp __alltraps
  10200f:	e9 e6 07 00 00       	jmp    1027fa <__alltraps>

00102014 <vector74>:
.globl vector74
vector74:
  pushl $0
  102014:	6a 00                	push   $0x0
  pushl $74
  102016:	6a 4a                	push   $0x4a
  jmp __alltraps
  102018:	e9 dd 07 00 00       	jmp    1027fa <__alltraps>

0010201d <vector75>:
.globl vector75
vector75:
  pushl $0
  10201d:	6a 00                	push   $0x0
  pushl $75
  10201f:	6a 4b                	push   $0x4b
  jmp __alltraps
  102021:	e9 d4 07 00 00       	jmp    1027fa <__alltraps>

00102026 <vector76>:
.globl vector76
vector76:
  pushl $0
  102026:	6a 00                	push   $0x0
  pushl $76
  102028:	6a 4c                	push   $0x4c
  jmp __alltraps
  10202a:	e9 cb 07 00 00       	jmp    1027fa <__alltraps>

0010202f <vector77>:
.globl vector77
vector77:
  pushl $0
  10202f:	6a 00                	push   $0x0
  pushl $77
  102031:	6a 4d                	push   $0x4d
  jmp __alltraps
  102033:	e9 c2 07 00 00       	jmp    1027fa <__alltraps>

00102038 <vector78>:
.globl vector78
vector78:
  pushl $0
  102038:	6a 00                	push   $0x0
  pushl $78
  10203a:	6a 4e                	push   $0x4e
  jmp __alltraps
  10203c:	e9 b9 07 00 00       	jmp    1027fa <__alltraps>

00102041 <vector79>:
.globl vector79
vector79:
  pushl $0
  102041:	6a 00                	push   $0x0
  pushl $79
  102043:	6a 4f                	push   $0x4f
  jmp __alltraps
  102045:	e9 b0 07 00 00       	jmp    1027fa <__alltraps>

0010204a <vector80>:
.globl vector80
vector80:
  pushl $0
  10204a:	6a 00                	push   $0x0
  pushl $80
  10204c:	6a 50                	push   $0x50
  jmp __alltraps
  10204e:	e9 a7 07 00 00       	jmp    1027fa <__alltraps>

00102053 <vector81>:
.globl vector81
vector81:
  pushl $0
  102053:	6a 00                	push   $0x0
  pushl $81
  102055:	6a 51                	push   $0x51
  jmp __alltraps
  102057:	e9 9e 07 00 00       	jmp    1027fa <__alltraps>

0010205c <vector82>:
.globl vector82
vector82:
  pushl $0
  10205c:	6a 00                	push   $0x0
  pushl $82
  10205e:	6a 52                	push   $0x52
  jmp __alltraps
  102060:	e9 95 07 00 00       	jmp    1027fa <__alltraps>

00102065 <vector83>:
.globl vector83
vector83:
  pushl $0
  102065:	6a 00                	push   $0x0
  pushl $83
  102067:	6a 53                	push   $0x53
  jmp __alltraps
  102069:	e9 8c 07 00 00       	jmp    1027fa <__alltraps>

0010206e <vector84>:
.globl vector84
vector84:
  pushl $0
  10206e:	6a 00                	push   $0x0
  pushl $84
  102070:	6a 54                	push   $0x54
  jmp __alltraps
  102072:	e9 83 07 00 00       	jmp    1027fa <__alltraps>

00102077 <vector85>:
.globl vector85
vector85:
  pushl $0
  102077:	6a 00                	push   $0x0
  pushl $85
  102079:	6a 55                	push   $0x55
  jmp __alltraps
  10207b:	e9 7a 07 00 00       	jmp    1027fa <__alltraps>

00102080 <vector86>:
.globl vector86
vector86:
  pushl $0
  102080:	6a 00                	push   $0x0
  pushl $86
  102082:	6a 56                	push   $0x56
  jmp __alltraps
  102084:	e9 71 07 00 00       	jmp    1027fa <__alltraps>

00102089 <vector87>:
.globl vector87
vector87:
  pushl $0
  102089:	6a 00                	push   $0x0
  pushl $87
  10208b:	6a 57                	push   $0x57
  jmp __alltraps
  10208d:	e9 68 07 00 00       	jmp    1027fa <__alltraps>

00102092 <vector88>:
.globl vector88
vector88:
  pushl $0
  102092:	6a 00                	push   $0x0
  pushl $88
  102094:	6a 58                	push   $0x58
  jmp __alltraps
  102096:	e9 5f 07 00 00       	jmp    1027fa <__alltraps>

0010209b <vector89>:
.globl vector89
vector89:
  pushl $0
  10209b:	6a 00                	push   $0x0
  pushl $89
  10209d:	6a 59                	push   $0x59
  jmp __alltraps
  10209f:	e9 56 07 00 00       	jmp    1027fa <__alltraps>

001020a4 <vector90>:
.globl vector90
vector90:
  pushl $0
  1020a4:	6a 00                	push   $0x0
  pushl $90
  1020a6:	6a 5a                	push   $0x5a
  jmp __alltraps
  1020a8:	e9 4d 07 00 00       	jmp    1027fa <__alltraps>

001020ad <vector91>:
.globl vector91
vector91:
  pushl $0
  1020ad:	6a 00                	push   $0x0
  pushl $91
  1020af:	6a 5b                	push   $0x5b
  jmp __alltraps
  1020b1:	e9 44 07 00 00       	jmp    1027fa <__alltraps>

001020b6 <vector92>:
.globl vector92
vector92:
  pushl $0
  1020b6:	6a 00                	push   $0x0
  pushl $92
  1020b8:	6a 5c                	push   $0x5c
  jmp __alltraps
  1020ba:	e9 3b 07 00 00       	jmp    1027fa <__alltraps>

001020bf <vector93>:
.globl vector93
vector93:
  pushl $0
  1020bf:	6a 00                	push   $0x0
  pushl $93
  1020c1:	6a 5d                	push   $0x5d
  jmp __alltraps
  1020c3:	e9 32 07 00 00       	jmp    1027fa <__alltraps>

001020c8 <vector94>:
.globl vector94
vector94:
  pushl $0
  1020c8:	6a 00                	push   $0x0
  pushl $94
  1020ca:	6a 5e                	push   $0x5e
  jmp __alltraps
  1020cc:	e9 29 07 00 00       	jmp    1027fa <__alltraps>

001020d1 <vector95>:
.globl vector95
vector95:
  pushl $0
  1020d1:	6a 00                	push   $0x0
  pushl $95
  1020d3:	6a 5f                	push   $0x5f
  jmp __alltraps
  1020d5:	e9 20 07 00 00       	jmp    1027fa <__alltraps>

001020da <vector96>:
.globl vector96
vector96:
  pushl $0
  1020da:	6a 00                	push   $0x0
  pushl $96
  1020dc:	6a 60                	push   $0x60
  jmp __alltraps
  1020de:	e9 17 07 00 00       	jmp    1027fa <__alltraps>

001020e3 <vector97>:
.globl vector97
vector97:
  pushl $0
  1020e3:	6a 00                	push   $0x0
  pushl $97
  1020e5:	6a 61                	push   $0x61
  jmp __alltraps
  1020e7:	e9 0e 07 00 00       	jmp    1027fa <__alltraps>

001020ec <vector98>:
.globl vector98
vector98:
  pushl $0
  1020ec:	6a 00                	push   $0x0
  pushl $98
  1020ee:	6a 62                	push   $0x62
  jmp __alltraps
  1020f0:	e9 05 07 00 00       	jmp    1027fa <__alltraps>

001020f5 <vector99>:
.globl vector99
vector99:
  pushl $0
  1020f5:	6a 00                	push   $0x0
  pushl $99
  1020f7:	6a 63                	push   $0x63
  jmp __alltraps
  1020f9:	e9 fc 06 00 00       	jmp    1027fa <__alltraps>

001020fe <vector100>:
.globl vector100
vector100:
  pushl $0
  1020fe:	6a 00                	push   $0x0
  pushl $100
  102100:	6a 64                	push   $0x64
  jmp __alltraps
  102102:	e9 f3 06 00 00       	jmp    1027fa <__alltraps>

00102107 <vector101>:
.globl vector101
vector101:
  pushl $0
  102107:	6a 00                	push   $0x0
  pushl $101
  102109:	6a 65                	push   $0x65
  jmp __alltraps
  10210b:	e9 ea 06 00 00       	jmp    1027fa <__alltraps>

00102110 <vector102>:
.globl vector102
vector102:
  pushl $0
  102110:	6a 00                	push   $0x0
  pushl $102
  102112:	6a 66                	push   $0x66
  jmp __alltraps
  102114:	e9 e1 06 00 00       	jmp    1027fa <__alltraps>

00102119 <vector103>:
.globl vector103
vector103:
  pushl $0
  102119:	6a 00                	push   $0x0
  pushl $103
  10211b:	6a 67                	push   $0x67
  jmp __alltraps
  10211d:	e9 d8 06 00 00       	jmp    1027fa <__alltraps>

00102122 <vector104>:
.globl vector104
vector104:
  pushl $0
  102122:	6a 00                	push   $0x0
  pushl $104
  102124:	6a 68                	push   $0x68
  jmp __alltraps
  102126:	e9 cf 06 00 00       	jmp    1027fa <__alltraps>

0010212b <vector105>:
.globl vector105
vector105:
  pushl $0
  10212b:	6a 00                	push   $0x0
  pushl $105
  10212d:	6a 69                	push   $0x69
  jmp __alltraps
  10212f:	e9 c6 06 00 00       	jmp    1027fa <__alltraps>

00102134 <vector106>:
.globl vector106
vector106:
  pushl $0
  102134:	6a 00                	push   $0x0
  pushl $106
  102136:	6a 6a                	push   $0x6a
  jmp __alltraps
  102138:	e9 bd 06 00 00       	jmp    1027fa <__alltraps>

0010213d <vector107>:
.globl vector107
vector107:
  pushl $0
  10213d:	6a 00                	push   $0x0
  pushl $107
  10213f:	6a 6b                	push   $0x6b
  jmp __alltraps
  102141:	e9 b4 06 00 00       	jmp    1027fa <__alltraps>

00102146 <vector108>:
.globl vector108
vector108:
  pushl $0
  102146:	6a 00                	push   $0x0
  pushl $108
  102148:	6a 6c                	push   $0x6c
  jmp __alltraps
  10214a:	e9 ab 06 00 00       	jmp    1027fa <__alltraps>

0010214f <vector109>:
.globl vector109
vector109:
  pushl $0
  10214f:	6a 00                	push   $0x0
  pushl $109
  102151:	6a 6d                	push   $0x6d
  jmp __alltraps
  102153:	e9 a2 06 00 00       	jmp    1027fa <__alltraps>

00102158 <vector110>:
.globl vector110
vector110:
  pushl $0
  102158:	6a 00                	push   $0x0
  pushl $110
  10215a:	6a 6e                	push   $0x6e
  jmp __alltraps
  10215c:	e9 99 06 00 00       	jmp    1027fa <__alltraps>

00102161 <vector111>:
.globl vector111
vector111:
  pushl $0
  102161:	6a 00                	push   $0x0
  pushl $111
  102163:	6a 6f                	push   $0x6f
  jmp __alltraps
  102165:	e9 90 06 00 00       	jmp    1027fa <__alltraps>

0010216a <vector112>:
.globl vector112
vector112:
  pushl $0
  10216a:	6a 00                	push   $0x0
  pushl $112
  10216c:	6a 70                	push   $0x70
  jmp __alltraps
  10216e:	e9 87 06 00 00       	jmp    1027fa <__alltraps>

00102173 <vector113>:
.globl vector113
vector113:
  pushl $0
  102173:	6a 00                	push   $0x0
  pushl $113
  102175:	6a 71                	push   $0x71
  jmp __alltraps
  102177:	e9 7e 06 00 00       	jmp    1027fa <__alltraps>

0010217c <vector114>:
.globl vector114
vector114:
  pushl $0
  10217c:	6a 00                	push   $0x0
  pushl $114
  10217e:	6a 72                	push   $0x72
  jmp __alltraps
  102180:	e9 75 06 00 00       	jmp    1027fa <__alltraps>

00102185 <vector115>:
.globl vector115
vector115:
  pushl $0
  102185:	6a 00                	push   $0x0
  pushl $115
  102187:	6a 73                	push   $0x73
  jmp __alltraps
  102189:	e9 6c 06 00 00       	jmp    1027fa <__alltraps>

0010218e <vector116>:
.globl vector116
vector116:
  pushl $0
  10218e:	6a 00                	push   $0x0
  pushl $116
  102190:	6a 74                	push   $0x74
  jmp __alltraps
  102192:	e9 63 06 00 00       	jmp    1027fa <__alltraps>

00102197 <vector117>:
.globl vector117
vector117:
  pushl $0
  102197:	6a 00                	push   $0x0
  pushl $117
  102199:	6a 75                	push   $0x75
  jmp __alltraps
  10219b:	e9 5a 06 00 00       	jmp    1027fa <__alltraps>

001021a0 <vector118>:
.globl vector118
vector118:
  pushl $0
  1021a0:	6a 00                	push   $0x0
  pushl $118
  1021a2:	6a 76                	push   $0x76
  jmp __alltraps
  1021a4:	e9 51 06 00 00       	jmp    1027fa <__alltraps>

001021a9 <vector119>:
.globl vector119
vector119:
  pushl $0
  1021a9:	6a 00                	push   $0x0
  pushl $119
  1021ab:	6a 77                	push   $0x77
  jmp __alltraps
  1021ad:	e9 48 06 00 00       	jmp    1027fa <__alltraps>

001021b2 <vector120>:
.globl vector120
vector120:
  pushl $0
  1021b2:	6a 00                	push   $0x0
  pushl $120
  1021b4:	6a 78                	push   $0x78
  jmp __alltraps
  1021b6:	e9 3f 06 00 00       	jmp    1027fa <__alltraps>

001021bb <vector121>:
.globl vector121
vector121:
  pushl $0
  1021bb:	6a 00                	push   $0x0
  pushl $121
  1021bd:	6a 79                	push   $0x79
  jmp __alltraps
  1021bf:	e9 36 06 00 00       	jmp    1027fa <__alltraps>

001021c4 <vector122>:
.globl vector122
vector122:
  pushl $0
  1021c4:	6a 00                	push   $0x0
  pushl $122
  1021c6:	6a 7a                	push   $0x7a
  jmp __alltraps
  1021c8:	e9 2d 06 00 00       	jmp    1027fa <__alltraps>

001021cd <vector123>:
.globl vector123
vector123:
  pushl $0
  1021cd:	6a 00                	push   $0x0
  pushl $123
  1021cf:	6a 7b                	push   $0x7b
  jmp __alltraps
  1021d1:	e9 24 06 00 00       	jmp    1027fa <__alltraps>

001021d6 <vector124>:
.globl vector124
vector124:
  pushl $0
  1021d6:	6a 00                	push   $0x0
  pushl $124
  1021d8:	6a 7c                	push   $0x7c
  jmp __alltraps
  1021da:	e9 1b 06 00 00       	jmp    1027fa <__alltraps>

001021df <vector125>:
.globl vector125
vector125:
  pushl $0
  1021df:	6a 00                	push   $0x0
  pushl $125
  1021e1:	6a 7d                	push   $0x7d
  jmp __alltraps
  1021e3:	e9 12 06 00 00       	jmp    1027fa <__alltraps>

001021e8 <vector126>:
.globl vector126
vector126:
  pushl $0
  1021e8:	6a 00                	push   $0x0
  pushl $126
  1021ea:	6a 7e                	push   $0x7e
  jmp __alltraps
  1021ec:	e9 09 06 00 00       	jmp    1027fa <__alltraps>

001021f1 <vector127>:
.globl vector127
vector127:
  pushl $0
  1021f1:	6a 00                	push   $0x0
  pushl $127
  1021f3:	6a 7f                	push   $0x7f
  jmp __alltraps
  1021f5:	e9 00 06 00 00       	jmp    1027fa <__alltraps>

001021fa <vector128>:
.globl vector128
vector128:
  pushl $0
  1021fa:	6a 00                	push   $0x0
  pushl $128
  1021fc:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  102201:	e9 f4 05 00 00       	jmp    1027fa <__alltraps>

00102206 <vector129>:
.globl vector129
vector129:
  pushl $0
  102206:	6a 00                	push   $0x0
  pushl $129
  102208:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  10220d:	e9 e8 05 00 00       	jmp    1027fa <__alltraps>

00102212 <vector130>:
.globl vector130
vector130:
  pushl $0
  102212:	6a 00                	push   $0x0
  pushl $130
  102214:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  102219:	e9 dc 05 00 00       	jmp    1027fa <__alltraps>

0010221e <vector131>:
.globl vector131
vector131:
  pushl $0
  10221e:	6a 00                	push   $0x0
  pushl $131
  102220:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  102225:	e9 d0 05 00 00       	jmp    1027fa <__alltraps>

0010222a <vector132>:
.globl vector132
vector132:
  pushl $0
  10222a:	6a 00                	push   $0x0
  pushl $132
  10222c:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  102231:	e9 c4 05 00 00       	jmp    1027fa <__alltraps>

00102236 <vector133>:
.globl vector133
vector133:
  pushl $0
  102236:	6a 00                	push   $0x0
  pushl $133
  102238:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  10223d:	e9 b8 05 00 00       	jmp    1027fa <__alltraps>

00102242 <vector134>:
.globl vector134
vector134:
  pushl $0
  102242:	6a 00                	push   $0x0
  pushl $134
  102244:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  102249:	e9 ac 05 00 00       	jmp    1027fa <__alltraps>

0010224e <vector135>:
.globl vector135
vector135:
  pushl $0
  10224e:	6a 00                	push   $0x0
  pushl $135
  102250:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  102255:	e9 a0 05 00 00       	jmp    1027fa <__alltraps>

0010225a <vector136>:
.globl vector136
vector136:
  pushl $0
  10225a:	6a 00                	push   $0x0
  pushl $136
  10225c:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  102261:	e9 94 05 00 00       	jmp    1027fa <__alltraps>

00102266 <vector137>:
.globl vector137
vector137:
  pushl $0
  102266:	6a 00                	push   $0x0
  pushl $137
  102268:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  10226d:	e9 88 05 00 00       	jmp    1027fa <__alltraps>

00102272 <vector138>:
.globl vector138
vector138:
  pushl $0
  102272:	6a 00                	push   $0x0
  pushl $138
  102274:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  102279:	e9 7c 05 00 00       	jmp    1027fa <__alltraps>

0010227e <vector139>:
.globl vector139
vector139:
  pushl $0
  10227e:	6a 00                	push   $0x0
  pushl $139
  102280:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  102285:	e9 70 05 00 00       	jmp    1027fa <__alltraps>

0010228a <vector140>:
.globl vector140
vector140:
  pushl $0
  10228a:	6a 00                	push   $0x0
  pushl $140
  10228c:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  102291:	e9 64 05 00 00       	jmp    1027fa <__alltraps>

00102296 <vector141>:
.globl vector141
vector141:
  pushl $0
  102296:	6a 00                	push   $0x0
  pushl $141
  102298:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  10229d:	e9 58 05 00 00       	jmp    1027fa <__alltraps>

001022a2 <vector142>:
.globl vector142
vector142:
  pushl $0
  1022a2:	6a 00                	push   $0x0
  pushl $142
  1022a4:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  1022a9:	e9 4c 05 00 00       	jmp    1027fa <__alltraps>

001022ae <vector143>:
.globl vector143
vector143:
  pushl $0
  1022ae:	6a 00                	push   $0x0
  pushl $143
  1022b0:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  1022b5:	e9 40 05 00 00       	jmp    1027fa <__alltraps>

001022ba <vector144>:
.globl vector144
vector144:
  pushl $0
  1022ba:	6a 00                	push   $0x0
  pushl $144
  1022bc:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  1022c1:	e9 34 05 00 00       	jmp    1027fa <__alltraps>

001022c6 <vector145>:
.globl vector145
vector145:
  pushl $0
  1022c6:	6a 00                	push   $0x0
  pushl $145
  1022c8:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  1022cd:	e9 28 05 00 00       	jmp    1027fa <__alltraps>

001022d2 <vector146>:
.globl vector146
vector146:
  pushl $0
  1022d2:	6a 00                	push   $0x0
  pushl $146
  1022d4:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  1022d9:	e9 1c 05 00 00       	jmp    1027fa <__alltraps>

001022de <vector147>:
.globl vector147
vector147:
  pushl $0
  1022de:	6a 00                	push   $0x0
  pushl $147
  1022e0:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  1022e5:	e9 10 05 00 00       	jmp    1027fa <__alltraps>

001022ea <vector148>:
.globl vector148
vector148:
  pushl $0
  1022ea:	6a 00                	push   $0x0
  pushl $148
  1022ec:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  1022f1:	e9 04 05 00 00       	jmp    1027fa <__alltraps>

001022f6 <vector149>:
.globl vector149
vector149:
  pushl $0
  1022f6:	6a 00                	push   $0x0
  pushl $149
  1022f8:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  1022fd:	e9 f8 04 00 00       	jmp    1027fa <__alltraps>

00102302 <vector150>:
.globl vector150
vector150:
  pushl $0
  102302:	6a 00                	push   $0x0
  pushl $150
  102304:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  102309:	e9 ec 04 00 00       	jmp    1027fa <__alltraps>

0010230e <vector151>:
.globl vector151
vector151:
  pushl $0
  10230e:	6a 00                	push   $0x0
  pushl $151
  102310:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  102315:	e9 e0 04 00 00       	jmp    1027fa <__alltraps>

0010231a <vector152>:
.globl vector152
vector152:
  pushl $0
  10231a:	6a 00                	push   $0x0
  pushl $152
  10231c:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  102321:	e9 d4 04 00 00       	jmp    1027fa <__alltraps>

00102326 <vector153>:
.globl vector153
vector153:
  pushl $0
  102326:	6a 00                	push   $0x0
  pushl $153
  102328:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  10232d:	e9 c8 04 00 00       	jmp    1027fa <__alltraps>

00102332 <vector154>:
.globl vector154
vector154:
  pushl $0
  102332:	6a 00                	push   $0x0
  pushl $154
  102334:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  102339:	e9 bc 04 00 00       	jmp    1027fa <__alltraps>

0010233e <vector155>:
.globl vector155
vector155:
  pushl $0
  10233e:	6a 00                	push   $0x0
  pushl $155
  102340:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  102345:	e9 b0 04 00 00       	jmp    1027fa <__alltraps>

0010234a <vector156>:
.globl vector156
vector156:
  pushl $0
  10234a:	6a 00                	push   $0x0
  pushl $156
  10234c:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  102351:	e9 a4 04 00 00       	jmp    1027fa <__alltraps>

00102356 <vector157>:
.globl vector157
vector157:
  pushl $0
  102356:	6a 00                	push   $0x0
  pushl $157
  102358:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  10235d:	e9 98 04 00 00       	jmp    1027fa <__alltraps>

00102362 <vector158>:
.globl vector158
vector158:
  pushl $0
  102362:	6a 00                	push   $0x0
  pushl $158
  102364:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  102369:	e9 8c 04 00 00       	jmp    1027fa <__alltraps>

0010236e <vector159>:
.globl vector159
vector159:
  pushl $0
  10236e:	6a 00                	push   $0x0
  pushl $159
  102370:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  102375:	e9 80 04 00 00       	jmp    1027fa <__alltraps>

0010237a <vector160>:
.globl vector160
vector160:
  pushl $0
  10237a:	6a 00                	push   $0x0
  pushl $160
  10237c:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  102381:	e9 74 04 00 00       	jmp    1027fa <__alltraps>

00102386 <vector161>:
.globl vector161
vector161:
  pushl $0
  102386:	6a 00                	push   $0x0
  pushl $161
  102388:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  10238d:	e9 68 04 00 00       	jmp    1027fa <__alltraps>

00102392 <vector162>:
.globl vector162
vector162:
  pushl $0
  102392:	6a 00                	push   $0x0
  pushl $162
  102394:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  102399:	e9 5c 04 00 00       	jmp    1027fa <__alltraps>

0010239e <vector163>:
.globl vector163
vector163:
  pushl $0
  10239e:	6a 00                	push   $0x0
  pushl $163
  1023a0:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  1023a5:	e9 50 04 00 00       	jmp    1027fa <__alltraps>

001023aa <vector164>:
.globl vector164
vector164:
  pushl $0
  1023aa:	6a 00                	push   $0x0
  pushl $164
  1023ac:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  1023b1:	e9 44 04 00 00       	jmp    1027fa <__alltraps>

001023b6 <vector165>:
.globl vector165
vector165:
  pushl $0
  1023b6:	6a 00                	push   $0x0
  pushl $165
  1023b8:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  1023bd:	e9 38 04 00 00       	jmp    1027fa <__alltraps>

001023c2 <vector166>:
.globl vector166
vector166:
  pushl $0
  1023c2:	6a 00                	push   $0x0
  pushl $166
  1023c4:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  1023c9:	e9 2c 04 00 00       	jmp    1027fa <__alltraps>

001023ce <vector167>:
.globl vector167
vector167:
  pushl $0
  1023ce:	6a 00                	push   $0x0
  pushl $167
  1023d0:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  1023d5:	e9 20 04 00 00       	jmp    1027fa <__alltraps>

001023da <vector168>:
.globl vector168
vector168:
  pushl $0
  1023da:	6a 00                	push   $0x0
  pushl $168
  1023dc:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  1023e1:	e9 14 04 00 00       	jmp    1027fa <__alltraps>

001023e6 <vector169>:
.globl vector169
vector169:
  pushl $0
  1023e6:	6a 00                	push   $0x0
  pushl $169
  1023e8:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  1023ed:	e9 08 04 00 00       	jmp    1027fa <__alltraps>

001023f2 <vector170>:
.globl vector170
vector170:
  pushl $0
  1023f2:	6a 00                	push   $0x0
  pushl $170
  1023f4:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  1023f9:	e9 fc 03 00 00       	jmp    1027fa <__alltraps>

001023fe <vector171>:
.globl vector171
vector171:
  pushl $0
  1023fe:	6a 00                	push   $0x0
  pushl $171
  102400:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  102405:	e9 f0 03 00 00       	jmp    1027fa <__alltraps>

0010240a <vector172>:
.globl vector172
vector172:
  pushl $0
  10240a:	6a 00                	push   $0x0
  pushl $172
  10240c:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  102411:	e9 e4 03 00 00       	jmp    1027fa <__alltraps>

00102416 <vector173>:
.globl vector173
vector173:
  pushl $0
  102416:	6a 00                	push   $0x0
  pushl $173
  102418:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  10241d:	e9 d8 03 00 00       	jmp    1027fa <__alltraps>

00102422 <vector174>:
.globl vector174
vector174:
  pushl $0
  102422:	6a 00                	push   $0x0
  pushl $174
  102424:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  102429:	e9 cc 03 00 00       	jmp    1027fa <__alltraps>

0010242e <vector175>:
.globl vector175
vector175:
  pushl $0
  10242e:	6a 00                	push   $0x0
  pushl $175
  102430:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  102435:	e9 c0 03 00 00       	jmp    1027fa <__alltraps>

0010243a <vector176>:
.globl vector176
vector176:
  pushl $0
  10243a:	6a 00                	push   $0x0
  pushl $176
  10243c:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  102441:	e9 b4 03 00 00       	jmp    1027fa <__alltraps>

00102446 <vector177>:
.globl vector177
vector177:
  pushl $0
  102446:	6a 00                	push   $0x0
  pushl $177
  102448:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  10244d:	e9 a8 03 00 00       	jmp    1027fa <__alltraps>

00102452 <vector178>:
.globl vector178
vector178:
  pushl $0
  102452:	6a 00                	push   $0x0
  pushl $178
  102454:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  102459:	e9 9c 03 00 00       	jmp    1027fa <__alltraps>

0010245e <vector179>:
.globl vector179
vector179:
  pushl $0
  10245e:	6a 00                	push   $0x0
  pushl $179
  102460:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  102465:	e9 90 03 00 00       	jmp    1027fa <__alltraps>

0010246a <vector180>:
.globl vector180
vector180:
  pushl $0
  10246a:	6a 00                	push   $0x0
  pushl $180
  10246c:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  102471:	e9 84 03 00 00       	jmp    1027fa <__alltraps>

00102476 <vector181>:
.globl vector181
vector181:
  pushl $0
  102476:	6a 00                	push   $0x0
  pushl $181
  102478:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  10247d:	e9 78 03 00 00       	jmp    1027fa <__alltraps>

00102482 <vector182>:
.globl vector182
vector182:
  pushl $0
  102482:	6a 00                	push   $0x0
  pushl $182
  102484:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  102489:	e9 6c 03 00 00       	jmp    1027fa <__alltraps>

0010248e <vector183>:
.globl vector183
vector183:
  pushl $0
  10248e:	6a 00                	push   $0x0
  pushl $183
  102490:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  102495:	e9 60 03 00 00       	jmp    1027fa <__alltraps>

0010249a <vector184>:
.globl vector184
vector184:
  pushl $0
  10249a:	6a 00                	push   $0x0
  pushl $184
  10249c:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  1024a1:	e9 54 03 00 00       	jmp    1027fa <__alltraps>

001024a6 <vector185>:
.globl vector185
vector185:
  pushl $0
  1024a6:	6a 00                	push   $0x0
  pushl $185
  1024a8:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  1024ad:	e9 48 03 00 00       	jmp    1027fa <__alltraps>

001024b2 <vector186>:
.globl vector186
vector186:
  pushl $0
  1024b2:	6a 00                	push   $0x0
  pushl $186
  1024b4:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  1024b9:	e9 3c 03 00 00       	jmp    1027fa <__alltraps>

001024be <vector187>:
.globl vector187
vector187:
  pushl $0
  1024be:	6a 00                	push   $0x0
  pushl $187
  1024c0:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  1024c5:	e9 30 03 00 00       	jmp    1027fa <__alltraps>

001024ca <vector188>:
.globl vector188
vector188:
  pushl $0
  1024ca:	6a 00                	push   $0x0
  pushl $188
  1024cc:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  1024d1:	e9 24 03 00 00       	jmp    1027fa <__alltraps>

001024d6 <vector189>:
.globl vector189
vector189:
  pushl $0
  1024d6:	6a 00                	push   $0x0
  pushl $189
  1024d8:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  1024dd:	e9 18 03 00 00       	jmp    1027fa <__alltraps>

001024e2 <vector190>:
.globl vector190
vector190:
  pushl $0
  1024e2:	6a 00                	push   $0x0
  pushl $190
  1024e4:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  1024e9:	e9 0c 03 00 00       	jmp    1027fa <__alltraps>

001024ee <vector191>:
.globl vector191
vector191:
  pushl $0
  1024ee:	6a 00                	push   $0x0
  pushl $191
  1024f0:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  1024f5:	e9 00 03 00 00       	jmp    1027fa <__alltraps>

001024fa <vector192>:
.globl vector192
vector192:
  pushl $0
  1024fa:	6a 00                	push   $0x0
  pushl $192
  1024fc:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  102501:	e9 f4 02 00 00       	jmp    1027fa <__alltraps>

00102506 <vector193>:
.globl vector193
vector193:
  pushl $0
  102506:	6a 00                	push   $0x0
  pushl $193
  102508:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  10250d:	e9 e8 02 00 00       	jmp    1027fa <__alltraps>

00102512 <vector194>:
.globl vector194
vector194:
  pushl $0
  102512:	6a 00                	push   $0x0
  pushl $194
  102514:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  102519:	e9 dc 02 00 00       	jmp    1027fa <__alltraps>

0010251e <vector195>:
.globl vector195
vector195:
  pushl $0
  10251e:	6a 00                	push   $0x0
  pushl $195
  102520:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  102525:	e9 d0 02 00 00       	jmp    1027fa <__alltraps>

0010252a <vector196>:
.globl vector196
vector196:
  pushl $0
  10252a:	6a 00                	push   $0x0
  pushl $196
  10252c:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  102531:	e9 c4 02 00 00       	jmp    1027fa <__alltraps>

00102536 <vector197>:
.globl vector197
vector197:
  pushl $0
  102536:	6a 00                	push   $0x0
  pushl $197
  102538:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  10253d:	e9 b8 02 00 00       	jmp    1027fa <__alltraps>

00102542 <vector198>:
.globl vector198
vector198:
  pushl $0
  102542:	6a 00                	push   $0x0
  pushl $198
  102544:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  102549:	e9 ac 02 00 00       	jmp    1027fa <__alltraps>

0010254e <vector199>:
.globl vector199
vector199:
  pushl $0
  10254e:	6a 00                	push   $0x0
  pushl $199
  102550:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  102555:	e9 a0 02 00 00       	jmp    1027fa <__alltraps>

0010255a <vector200>:
.globl vector200
vector200:
  pushl $0
  10255a:	6a 00                	push   $0x0
  pushl $200
  10255c:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  102561:	e9 94 02 00 00       	jmp    1027fa <__alltraps>

00102566 <vector201>:
.globl vector201
vector201:
  pushl $0
  102566:	6a 00                	push   $0x0
  pushl $201
  102568:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  10256d:	e9 88 02 00 00       	jmp    1027fa <__alltraps>

00102572 <vector202>:
.globl vector202
vector202:
  pushl $0
  102572:	6a 00                	push   $0x0
  pushl $202
  102574:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  102579:	e9 7c 02 00 00       	jmp    1027fa <__alltraps>

0010257e <vector203>:
.globl vector203
vector203:
  pushl $0
  10257e:	6a 00                	push   $0x0
  pushl $203
  102580:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  102585:	e9 70 02 00 00       	jmp    1027fa <__alltraps>

0010258a <vector204>:
.globl vector204
vector204:
  pushl $0
  10258a:	6a 00                	push   $0x0
  pushl $204
  10258c:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  102591:	e9 64 02 00 00       	jmp    1027fa <__alltraps>

00102596 <vector205>:
.globl vector205
vector205:
  pushl $0
  102596:	6a 00                	push   $0x0
  pushl $205
  102598:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  10259d:	e9 58 02 00 00       	jmp    1027fa <__alltraps>

001025a2 <vector206>:
.globl vector206
vector206:
  pushl $0
  1025a2:	6a 00                	push   $0x0
  pushl $206
  1025a4:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  1025a9:	e9 4c 02 00 00       	jmp    1027fa <__alltraps>

001025ae <vector207>:
.globl vector207
vector207:
  pushl $0
  1025ae:	6a 00                	push   $0x0
  pushl $207
  1025b0:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  1025b5:	e9 40 02 00 00       	jmp    1027fa <__alltraps>

001025ba <vector208>:
.globl vector208
vector208:
  pushl $0
  1025ba:	6a 00                	push   $0x0
  pushl $208
  1025bc:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  1025c1:	e9 34 02 00 00       	jmp    1027fa <__alltraps>

001025c6 <vector209>:
.globl vector209
vector209:
  pushl $0
  1025c6:	6a 00                	push   $0x0
  pushl $209
  1025c8:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  1025cd:	e9 28 02 00 00       	jmp    1027fa <__alltraps>

001025d2 <vector210>:
.globl vector210
vector210:
  pushl $0
  1025d2:	6a 00                	push   $0x0
  pushl $210
  1025d4:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  1025d9:	e9 1c 02 00 00       	jmp    1027fa <__alltraps>

001025de <vector211>:
.globl vector211
vector211:
  pushl $0
  1025de:	6a 00                	push   $0x0
  pushl $211
  1025e0:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  1025e5:	e9 10 02 00 00       	jmp    1027fa <__alltraps>

001025ea <vector212>:
.globl vector212
vector212:
  pushl $0
  1025ea:	6a 00                	push   $0x0
  pushl $212
  1025ec:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  1025f1:	e9 04 02 00 00       	jmp    1027fa <__alltraps>

001025f6 <vector213>:
.globl vector213
vector213:
  pushl $0
  1025f6:	6a 00                	push   $0x0
  pushl $213
  1025f8:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  1025fd:	e9 f8 01 00 00       	jmp    1027fa <__alltraps>

00102602 <vector214>:
.globl vector214
vector214:
  pushl $0
  102602:	6a 00                	push   $0x0
  pushl $214
  102604:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  102609:	e9 ec 01 00 00       	jmp    1027fa <__alltraps>

0010260e <vector215>:
.globl vector215
vector215:
  pushl $0
  10260e:	6a 00                	push   $0x0
  pushl $215
  102610:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  102615:	e9 e0 01 00 00       	jmp    1027fa <__alltraps>

0010261a <vector216>:
.globl vector216
vector216:
  pushl $0
  10261a:	6a 00                	push   $0x0
  pushl $216
  10261c:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  102621:	e9 d4 01 00 00       	jmp    1027fa <__alltraps>

00102626 <vector217>:
.globl vector217
vector217:
  pushl $0
  102626:	6a 00                	push   $0x0
  pushl $217
  102628:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  10262d:	e9 c8 01 00 00       	jmp    1027fa <__alltraps>

00102632 <vector218>:
.globl vector218
vector218:
  pushl $0
  102632:	6a 00                	push   $0x0
  pushl $218
  102634:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  102639:	e9 bc 01 00 00       	jmp    1027fa <__alltraps>

0010263e <vector219>:
.globl vector219
vector219:
  pushl $0
  10263e:	6a 00                	push   $0x0
  pushl $219
  102640:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  102645:	e9 b0 01 00 00       	jmp    1027fa <__alltraps>

0010264a <vector220>:
.globl vector220
vector220:
  pushl $0
  10264a:	6a 00                	push   $0x0
  pushl $220
  10264c:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  102651:	e9 a4 01 00 00       	jmp    1027fa <__alltraps>

00102656 <vector221>:
.globl vector221
vector221:
  pushl $0
  102656:	6a 00                	push   $0x0
  pushl $221
  102658:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  10265d:	e9 98 01 00 00       	jmp    1027fa <__alltraps>

00102662 <vector222>:
.globl vector222
vector222:
  pushl $0
  102662:	6a 00                	push   $0x0
  pushl $222
  102664:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  102669:	e9 8c 01 00 00       	jmp    1027fa <__alltraps>

0010266e <vector223>:
.globl vector223
vector223:
  pushl $0
  10266e:	6a 00                	push   $0x0
  pushl $223
  102670:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  102675:	e9 80 01 00 00       	jmp    1027fa <__alltraps>

0010267a <vector224>:
.globl vector224
vector224:
  pushl $0
  10267a:	6a 00                	push   $0x0
  pushl $224
  10267c:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  102681:	e9 74 01 00 00       	jmp    1027fa <__alltraps>

00102686 <vector225>:
.globl vector225
vector225:
  pushl $0
  102686:	6a 00                	push   $0x0
  pushl $225
  102688:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  10268d:	e9 68 01 00 00       	jmp    1027fa <__alltraps>

00102692 <vector226>:
.globl vector226
vector226:
  pushl $0
  102692:	6a 00                	push   $0x0
  pushl $226
  102694:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  102699:	e9 5c 01 00 00       	jmp    1027fa <__alltraps>

0010269e <vector227>:
.globl vector227
vector227:
  pushl $0
  10269e:	6a 00                	push   $0x0
  pushl $227
  1026a0:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  1026a5:	e9 50 01 00 00       	jmp    1027fa <__alltraps>

001026aa <vector228>:
.globl vector228
vector228:
  pushl $0
  1026aa:	6a 00                	push   $0x0
  pushl $228
  1026ac:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  1026b1:	e9 44 01 00 00       	jmp    1027fa <__alltraps>

001026b6 <vector229>:
.globl vector229
vector229:
  pushl $0
  1026b6:	6a 00                	push   $0x0
  pushl $229
  1026b8:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  1026bd:	e9 38 01 00 00       	jmp    1027fa <__alltraps>

001026c2 <vector230>:
.globl vector230
vector230:
  pushl $0
  1026c2:	6a 00                	push   $0x0
  pushl $230
  1026c4:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  1026c9:	e9 2c 01 00 00       	jmp    1027fa <__alltraps>

001026ce <vector231>:
.globl vector231
vector231:
  pushl $0
  1026ce:	6a 00                	push   $0x0
  pushl $231
  1026d0:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  1026d5:	e9 20 01 00 00       	jmp    1027fa <__alltraps>

001026da <vector232>:
.globl vector232
vector232:
  pushl $0
  1026da:	6a 00                	push   $0x0
  pushl $232
  1026dc:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  1026e1:	e9 14 01 00 00       	jmp    1027fa <__alltraps>

001026e6 <vector233>:
.globl vector233
vector233:
  pushl $0
  1026e6:	6a 00                	push   $0x0
  pushl $233
  1026e8:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  1026ed:	e9 08 01 00 00       	jmp    1027fa <__alltraps>

001026f2 <vector234>:
.globl vector234
vector234:
  pushl $0
  1026f2:	6a 00                	push   $0x0
  pushl $234
  1026f4:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  1026f9:	e9 fc 00 00 00       	jmp    1027fa <__alltraps>

001026fe <vector235>:
.globl vector235
vector235:
  pushl $0
  1026fe:	6a 00                	push   $0x0
  pushl $235
  102700:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  102705:	e9 f0 00 00 00       	jmp    1027fa <__alltraps>

0010270a <vector236>:
.globl vector236
vector236:
  pushl $0
  10270a:	6a 00                	push   $0x0
  pushl $236
  10270c:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  102711:	e9 e4 00 00 00       	jmp    1027fa <__alltraps>

00102716 <vector237>:
.globl vector237
vector237:
  pushl $0
  102716:	6a 00                	push   $0x0
  pushl $237
  102718:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  10271d:	e9 d8 00 00 00       	jmp    1027fa <__alltraps>

00102722 <vector238>:
.globl vector238
vector238:
  pushl $0
  102722:	6a 00                	push   $0x0
  pushl $238
  102724:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  102729:	e9 cc 00 00 00       	jmp    1027fa <__alltraps>

0010272e <vector239>:
.globl vector239
vector239:
  pushl $0
  10272e:	6a 00                	push   $0x0
  pushl $239
  102730:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  102735:	e9 c0 00 00 00       	jmp    1027fa <__alltraps>

0010273a <vector240>:
.globl vector240
vector240:
  pushl $0
  10273a:	6a 00                	push   $0x0
  pushl $240
  10273c:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  102741:	e9 b4 00 00 00       	jmp    1027fa <__alltraps>

00102746 <vector241>:
.globl vector241
vector241:
  pushl $0
  102746:	6a 00                	push   $0x0
  pushl $241
  102748:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  10274d:	e9 a8 00 00 00       	jmp    1027fa <__alltraps>

00102752 <vector242>:
.globl vector242
vector242:
  pushl $0
  102752:	6a 00                	push   $0x0
  pushl $242
  102754:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  102759:	e9 9c 00 00 00       	jmp    1027fa <__alltraps>

0010275e <vector243>:
.globl vector243
vector243:
  pushl $0
  10275e:	6a 00                	push   $0x0
  pushl $243
  102760:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  102765:	e9 90 00 00 00       	jmp    1027fa <__alltraps>

0010276a <vector244>:
.globl vector244
vector244:
  pushl $0
  10276a:	6a 00                	push   $0x0
  pushl $244
  10276c:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  102771:	e9 84 00 00 00       	jmp    1027fa <__alltraps>

00102776 <vector245>:
.globl vector245
vector245:
  pushl $0
  102776:	6a 00                	push   $0x0
  pushl $245
  102778:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  10277d:	e9 78 00 00 00       	jmp    1027fa <__alltraps>

00102782 <vector246>:
.globl vector246
vector246:
  pushl $0
  102782:	6a 00                	push   $0x0
  pushl $246
  102784:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  102789:	e9 6c 00 00 00       	jmp    1027fa <__alltraps>

0010278e <vector247>:
.globl vector247
vector247:
  pushl $0
  10278e:	6a 00                	push   $0x0
  pushl $247
  102790:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  102795:	e9 60 00 00 00       	jmp    1027fa <__alltraps>

0010279a <vector248>:
.globl vector248
vector248:
  pushl $0
  10279a:	6a 00                	push   $0x0
  pushl $248
  10279c:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  1027a1:	e9 54 00 00 00       	jmp    1027fa <__alltraps>

001027a6 <vector249>:
.globl vector249
vector249:
  pushl $0
  1027a6:	6a 00                	push   $0x0
  pushl $249
  1027a8:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  1027ad:	e9 48 00 00 00       	jmp    1027fa <__alltraps>

001027b2 <vector250>:
.globl vector250
vector250:
  pushl $0
  1027b2:	6a 00                	push   $0x0
  pushl $250
  1027b4:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  1027b9:	e9 3c 00 00 00       	jmp    1027fa <__alltraps>

001027be <vector251>:
.globl vector251
vector251:
  pushl $0
  1027be:	6a 00                	push   $0x0
  pushl $251
  1027c0:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  1027c5:	e9 30 00 00 00       	jmp    1027fa <__alltraps>

001027ca <vector252>:
.globl vector252
vector252:
  pushl $0
  1027ca:	6a 00                	push   $0x0
  pushl $252
  1027cc:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  1027d1:	e9 24 00 00 00       	jmp    1027fa <__alltraps>

001027d6 <vector253>:
.globl vector253
vector253:
  pushl $0
  1027d6:	6a 00                	push   $0x0
  pushl $253
  1027d8:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  1027dd:	e9 18 00 00 00       	jmp    1027fa <__alltraps>

001027e2 <vector254>:
.globl vector254
vector254:
  pushl $0
  1027e2:	6a 00                	push   $0x0
  pushl $254
  1027e4:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  1027e9:	e9 0c 00 00 00       	jmp    1027fa <__alltraps>

001027ee <vector255>:
.globl vector255
vector255:
  pushl $0
  1027ee:	6a 00                	push   $0x0
  pushl $255
  1027f0:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  1027f5:	e9 00 00 00 00       	jmp    1027fa <__alltraps>

001027fa <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  1027fa:	1e                   	push   %ds
    pushl %es
  1027fb:	06                   	push   %es
    pushl %fs
  1027fc:	0f a0                	push   %fs
    pushl %gs
  1027fe:	0f a8                	push   %gs
    pushal
  102800:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  102801:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  102806:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  102808:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  10280a:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  10280b:	e8 65 f5 ff ff       	call   101d75 <trap>

    # pop the pushed stack pointer
    popl %esp
  102810:	5c                   	pop    %esp

00102811 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  102811:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  102812:	0f a9                	pop    %gs
    popl %fs
  102814:	0f a1                	pop    %fs
    popl %es
  102816:	07                   	pop    %es
    popl %ds
  102817:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  102818:	83 c4 08             	add    $0x8,%esp
    iret
  10281b:	cf                   	iret   

0010281c <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  10281c:	55                   	push   %ebp
  10281d:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  10281f:	8b 45 08             	mov    0x8(%ebp),%eax
  102822:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  102825:	b8 23 00 00 00       	mov    $0x23,%eax
  10282a:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  10282c:	b8 23 00 00 00       	mov    $0x23,%eax
  102831:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  102833:	b8 10 00 00 00       	mov    $0x10,%eax
  102838:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  10283a:	b8 10 00 00 00       	mov    $0x10,%eax
  10283f:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  102841:	b8 10 00 00 00       	mov    $0x10,%eax
  102846:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  102848:	ea 4f 28 10 00 08 00 	ljmp   $0x8,$0x10284f
}
  10284f:	5d                   	pop    %ebp
  102850:	c3                   	ret    

00102851 <gdt_init>:
/* temporary kernel stack */
uint8_t stack0[1024];

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  102851:	55                   	push   %ebp
  102852:	89 e5                	mov    %esp,%ebp
  102854:	83 ec 14             	sub    $0x14,%esp
    // Setup a TSS so that we can get the right stack when we trap from
    // user to the kernel. But not safe here, it's only a temporary value,
    // it will be set to KSTACKTOP in lab2.
    ts.ts_esp0 = (uint32_t)&stack0 + sizeof(stack0);
  102857:	b8 20 f9 10 00       	mov    $0x10f920,%eax
  10285c:	05 00 04 00 00       	add    $0x400,%eax
  102861:	a3 a4 f8 10 00       	mov    %eax,0x10f8a4
    ts.ts_ss0 = KERNEL_DS;
  102866:	66 c7 05 a8 f8 10 00 	movw   $0x10,0x10f8a8
  10286d:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEG16(STS_T32A, (uint32_t)&ts, sizeof(ts), DPL_KERNEL);
  10286f:	66 c7 05 08 ea 10 00 	movw   $0x68,0x10ea08
  102876:	68 00 
  102878:	b8 a0 f8 10 00       	mov    $0x10f8a0,%eax
  10287d:	66 a3 0a ea 10 00    	mov    %ax,0x10ea0a
  102883:	b8 a0 f8 10 00       	mov    $0x10f8a0,%eax
  102888:	c1 e8 10             	shr    $0x10,%eax
  10288b:	a2 0c ea 10 00       	mov    %al,0x10ea0c
  102890:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  102897:	83 e0 f0             	and    $0xfffffff0,%eax
  10289a:	83 c8 09             	or     $0x9,%eax
  10289d:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  1028a2:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  1028a9:	83 c8 10             	or     $0x10,%eax
  1028ac:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  1028b1:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  1028b8:	83 e0 9f             	and    $0xffffff9f,%eax
  1028bb:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  1028c0:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  1028c7:	83 c8 80             	or     $0xffffff80,%eax
  1028ca:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  1028cf:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  1028d6:	83 e0 f0             	and    $0xfffffff0,%eax
  1028d9:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  1028de:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  1028e5:	83 e0 ef             	and    $0xffffffef,%eax
  1028e8:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  1028ed:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  1028f4:	83 e0 df             	and    $0xffffffdf,%eax
  1028f7:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  1028fc:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  102903:	83 c8 40             	or     $0x40,%eax
  102906:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  10290b:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  102912:	83 e0 7f             	and    $0x7f,%eax
  102915:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  10291a:	b8 a0 f8 10 00       	mov    $0x10f8a0,%eax
  10291f:	c1 e8 18             	shr    $0x18,%eax
  102922:	a2 0f ea 10 00       	mov    %al,0x10ea0f
    gdt[SEG_TSS].sd_s = 0;
  102927:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  10292e:	83 e0 ef             	and    $0xffffffef,%eax
  102931:	a2 0d ea 10 00       	mov    %al,0x10ea0d

    // reload all segment registers
    lgdt(&gdt_pd);
  102936:	c7 04 24 10 ea 10 00 	movl   $0x10ea10,(%esp)
  10293d:	e8 da fe ff ff       	call   10281c <lgdt>
  102942:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel));
  102948:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  10294c:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  10294f:	c9                   	leave  
  102950:	c3                   	ret    

00102951 <pmm_init>:

/* pmm_init - initialize the physical memory management */
void
pmm_init(void) {
  102951:	55                   	push   %ebp
  102952:	89 e5                	mov    %esp,%ebp
    gdt_init();
  102954:	e8 f8 fe ff ff       	call   102851 <gdt_init>
}
  102959:	5d                   	pop    %ebp
  10295a:	c3                   	ret    

0010295b <strlen>:
 * @s:        the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  10295b:	55                   	push   %ebp
  10295c:	89 e5                	mov    %esp,%ebp
  10295e:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  102961:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  102968:	eb 04                	jmp    10296e <strlen+0x13>
        cnt ++;
  10296a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (*s ++ != '\0') {
  10296e:	8b 45 08             	mov    0x8(%ebp),%eax
  102971:	8d 50 01             	lea    0x1(%eax),%edx
  102974:	89 55 08             	mov    %edx,0x8(%ebp)
  102977:	0f b6 00             	movzbl (%eax),%eax
  10297a:	84 c0                	test   %al,%al
  10297c:	75 ec                	jne    10296a <strlen+0xf>
    }
    return cnt;
  10297e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  102981:	c9                   	leave  
  102982:	c3                   	ret    

00102983 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  102983:	55                   	push   %ebp
  102984:	89 e5                	mov    %esp,%ebp
  102986:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  102989:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  102990:	eb 04                	jmp    102996 <strnlen+0x13>
        cnt ++;
  102992:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  102996:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102999:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10299c:	73 10                	jae    1029ae <strnlen+0x2b>
  10299e:	8b 45 08             	mov    0x8(%ebp),%eax
  1029a1:	8d 50 01             	lea    0x1(%eax),%edx
  1029a4:	89 55 08             	mov    %edx,0x8(%ebp)
  1029a7:	0f b6 00             	movzbl (%eax),%eax
  1029aa:	84 c0                	test   %al,%al
  1029ac:	75 e4                	jne    102992 <strnlen+0xf>
    }
    return cnt;
  1029ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1029b1:	c9                   	leave  
  1029b2:	c3                   	ret    

001029b3 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  1029b3:	55                   	push   %ebp
  1029b4:	89 e5                	mov    %esp,%ebp
  1029b6:	57                   	push   %edi
  1029b7:	56                   	push   %esi
  1029b8:	83 ec 20             	sub    $0x20,%esp
  1029bb:	8b 45 08             	mov    0x8(%ebp),%eax
  1029be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1029c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1029c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  1029c7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1029ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1029cd:	89 d1                	mov    %edx,%ecx
  1029cf:	89 c2                	mov    %eax,%edx
  1029d1:	89 ce                	mov    %ecx,%esi
  1029d3:	89 d7                	mov    %edx,%edi
  1029d5:	ac                   	lods   %ds:(%esi),%al
  1029d6:	aa                   	stos   %al,%es:(%edi)
  1029d7:	84 c0                	test   %al,%al
  1029d9:	75 fa                	jne    1029d5 <strcpy+0x22>
  1029db:	89 fa                	mov    %edi,%edx
  1029dd:	89 f1                	mov    %esi,%ecx
  1029df:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  1029e2:	89 55 e8             	mov    %edx,-0x18(%ebp)
  1029e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            "stosb;"
            "testb %%al, %%al;"
            "jne 1b;"
            : "=&S" (d0), "=&D" (d1), "=&a" (d2)
            : "0" (src), "1" (dst) : "memory");
    return dst;
  1029e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  1029eb:	83 c4 20             	add    $0x20,%esp
  1029ee:	5e                   	pop    %esi
  1029ef:	5f                   	pop    %edi
  1029f0:	5d                   	pop    %ebp
  1029f1:	c3                   	ret    

001029f2 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  1029f2:	55                   	push   %ebp
  1029f3:	89 e5                	mov    %esp,%ebp
  1029f5:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  1029f8:	8b 45 08             	mov    0x8(%ebp),%eax
  1029fb:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  1029fe:	eb 21                	jmp    102a21 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
  102a00:	8b 45 0c             	mov    0xc(%ebp),%eax
  102a03:	0f b6 10             	movzbl (%eax),%edx
  102a06:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102a09:	88 10                	mov    %dl,(%eax)
  102a0b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102a0e:	0f b6 00             	movzbl (%eax),%eax
  102a11:	84 c0                	test   %al,%al
  102a13:	74 04                	je     102a19 <strncpy+0x27>
            src ++;
  102a15:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
  102a19:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  102a1d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    while (len > 0) {
  102a21:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102a25:	75 d9                	jne    102a00 <strncpy+0xe>
    }
    return dst;
  102a27:	8b 45 08             	mov    0x8(%ebp),%eax
}
  102a2a:	c9                   	leave  
  102a2b:	c3                   	ret    

00102a2c <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  102a2c:	55                   	push   %ebp
  102a2d:	89 e5                	mov    %esp,%ebp
  102a2f:	57                   	push   %edi
  102a30:	56                   	push   %esi
  102a31:	83 ec 20             	sub    $0x20,%esp
  102a34:	8b 45 08             	mov    0x8(%ebp),%eax
  102a37:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102a3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  102a3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  102a40:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102a43:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102a46:	89 d1                	mov    %edx,%ecx
  102a48:	89 c2                	mov    %eax,%edx
  102a4a:	89 ce                	mov    %ecx,%esi
  102a4c:	89 d7                	mov    %edx,%edi
  102a4e:	ac                   	lods   %ds:(%esi),%al
  102a4f:	ae                   	scas   %es:(%edi),%al
  102a50:	75 08                	jne    102a5a <strcmp+0x2e>
  102a52:	84 c0                	test   %al,%al
  102a54:	75 f8                	jne    102a4e <strcmp+0x22>
  102a56:	31 c0                	xor    %eax,%eax
  102a58:	eb 04                	jmp    102a5e <strcmp+0x32>
  102a5a:	19 c0                	sbb    %eax,%eax
  102a5c:	0c 01                	or     $0x1,%al
  102a5e:	89 fa                	mov    %edi,%edx
  102a60:	89 f1                	mov    %esi,%ecx
  102a62:	89 45 ec             	mov    %eax,-0x14(%ebp)
  102a65:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  102a68:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  102a6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  102a6e:	83 c4 20             	add    $0x20,%esp
  102a71:	5e                   	pop    %esi
  102a72:	5f                   	pop    %edi
  102a73:	5d                   	pop    %ebp
  102a74:	c3                   	ret    

00102a75 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  102a75:	55                   	push   %ebp
  102a76:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  102a78:	eb 0c                	jmp    102a86 <strncmp+0x11>
        n --, s1 ++, s2 ++;
  102a7a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  102a7e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  102a82:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  102a86:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102a8a:	74 1a                	je     102aa6 <strncmp+0x31>
  102a8c:	8b 45 08             	mov    0x8(%ebp),%eax
  102a8f:	0f b6 00             	movzbl (%eax),%eax
  102a92:	84 c0                	test   %al,%al
  102a94:	74 10                	je     102aa6 <strncmp+0x31>
  102a96:	8b 45 08             	mov    0x8(%ebp),%eax
  102a99:	0f b6 10             	movzbl (%eax),%edx
  102a9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  102a9f:	0f b6 00             	movzbl (%eax),%eax
  102aa2:	38 c2                	cmp    %al,%dl
  102aa4:	74 d4                	je     102a7a <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  102aa6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102aaa:	74 18                	je     102ac4 <strncmp+0x4f>
  102aac:	8b 45 08             	mov    0x8(%ebp),%eax
  102aaf:	0f b6 00             	movzbl (%eax),%eax
  102ab2:	0f b6 d0             	movzbl %al,%edx
  102ab5:	8b 45 0c             	mov    0xc(%ebp),%eax
  102ab8:	0f b6 00             	movzbl (%eax),%eax
  102abb:	0f b6 c0             	movzbl %al,%eax
  102abe:	29 c2                	sub    %eax,%edx
  102ac0:	89 d0                	mov    %edx,%eax
  102ac2:	eb 05                	jmp    102ac9 <strncmp+0x54>
  102ac4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102ac9:	5d                   	pop    %ebp
  102aca:	c3                   	ret    

00102acb <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  102acb:	55                   	push   %ebp
  102acc:	89 e5                	mov    %esp,%ebp
  102ace:	83 ec 04             	sub    $0x4,%esp
  102ad1:	8b 45 0c             	mov    0xc(%ebp),%eax
  102ad4:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  102ad7:	eb 14                	jmp    102aed <strchr+0x22>
        if (*s == c) {
  102ad9:	8b 45 08             	mov    0x8(%ebp),%eax
  102adc:	0f b6 00             	movzbl (%eax),%eax
  102adf:	3a 45 fc             	cmp    -0x4(%ebp),%al
  102ae2:	75 05                	jne    102ae9 <strchr+0x1e>
            return (char *)s;
  102ae4:	8b 45 08             	mov    0x8(%ebp),%eax
  102ae7:	eb 13                	jmp    102afc <strchr+0x31>
        }
        s ++;
  102ae9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
  102aed:	8b 45 08             	mov    0x8(%ebp),%eax
  102af0:	0f b6 00             	movzbl (%eax),%eax
  102af3:	84 c0                	test   %al,%al
  102af5:	75 e2                	jne    102ad9 <strchr+0xe>
    }
    return NULL;
  102af7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102afc:	c9                   	leave  
  102afd:	c3                   	ret    

00102afe <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  102afe:	55                   	push   %ebp
  102aff:	89 e5                	mov    %esp,%ebp
  102b01:	83 ec 04             	sub    $0x4,%esp
  102b04:	8b 45 0c             	mov    0xc(%ebp),%eax
  102b07:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  102b0a:	eb 11                	jmp    102b1d <strfind+0x1f>
        if (*s == c) {
  102b0c:	8b 45 08             	mov    0x8(%ebp),%eax
  102b0f:	0f b6 00             	movzbl (%eax),%eax
  102b12:	3a 45 fc             	cmp    -0x4(%ebp),%al
  102b15:	75 02                	jne    102b19 <strfind+0x1b>
            break;
  102b17:	eb 0e                	jmp    102b27 <strfind+0x29>
        }
        s ++;
  102b19:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
  102b1d:	8b 45 08             	mov    0x8(%ebp),%eax
  102b20:	0f b6 00             	movzbl (%eax),%eax
  102b23:	84 c0                	test   %al,%al
  102b25:	75 e5                	jne    102b0c <strfind+0xe>
    }
    return (char *)s;
  102b27:	8b 45 08             	mov    0x8(%ebp),%eax
}
  102b2a:	c9                   	leave  
  102b2b:	c3                   	ret    

00102b2c <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  102b2c:	55                   	push   %ebp
  102b2d:	89 e5                	mov    %esp,%ebp
  102b2f:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  102b32:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  102b39:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  102b40:	eb 04                	jmp    102b46 <strtol+0x1a>
        s ++;
  102b42:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  102b46:	8b 45 08             	mov    0x8(%ebp),%eax
  102b49:	0f b6 00             	movzbl (%eax),%eax
  102b4c:	3c 20                	cmp    $0x20,%al
  102b4e:	74 f2                	je     102b42 <strtol+0x16>
  102b50:	8b 45 08             	mov    0x8(%ebp),%eax
  102b53:	0f b6 00             	movzbl (%eax),%eax
  102b56:	3c 09                	cmp    $0x9,%al
  102b58:	74 e8                	je     102b42 <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
  102b5a:	8b 45 08             	mov    0x8(%ebp),%eax
  102b5d:	0f b6 00             	movzbl (%eax),%eax
  102b60:	3c 2b                	cmp    $0x2b,%al
  102b62:	75 06                	jne    102b6a <strtol+0x3e>
        s ++;
  102b64:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  102b68:	eb 15                	jmp    102b7f <strtol+0x53>
    }
    else if (*s == '-') {
  102b6a:	8b 45 08             	mov    0x8(%ebp),%eax
  102b6d:	0f b6 00             	movzbl (%eax),%eax
  102b70:	3c 2d                	cmp    $0x2d,%al
  102b72:	75 0b                	jne    102b7f <strtol+0x53>
        s ++, neg = 1;
  102b74:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  102b78:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  102b7f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102b83:	74 06                	je     102b8b <strtol+0x5f>
  102b85:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  102b89:	75 24                	jne    102baf <strtol+0x83>
  102b8b:	8b 45 08             	mov    0x8(%ebp),%eax
  102b8e:	0f b6 00             	movzbl (%eax),%eax
  102b91:	3c 30                	cmp    $0x30,%al
  102b93:	75 1a                	jne    102baf <strtol+0x83>
  102b95:	8b 45 08             	mov    0x8(%ebp),%eax
  102b98:	83 c0 01             	add    $0x1,%eax
  102b9b:	0f b6 00             	movzbl (%eax),%eax
  102b9e:	3c 78                	cmp    $0x78,%al
  102ba0:	75 0d                	jne    102baf <strtol+0x83>
        s += 2, base = 16;
  102ba2:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  102ba6:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  102bad:	eb 2a                	jmp    102bd9 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
  102baf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102bb3:	75 17                	jne    102bcc <strtol+0xa0>
  102bb5:	8b 45 08             	mov    0x8(%ebp),%eax
  102bb8:	0f b6 00             	movzbl (%eax),%eax
  102bbb:	3c 30                	cmp    $0x30,%al
  102bbd:	75 0d                	jne    102bcc <strtol+0xa0>
        s ++, base = 8;
  102bbf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  102bc3:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  102bca:	eb 0d                	jmp    102bd9 <strtol+0xad>
    }
    else if (base == 0) {
  102bcc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102bd0:	75 07                	jne    102bd9 <strtol+0xad>
        base = 10;
  102bd2:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  102bd9:	8b 45 08             	mov    0x8(%ebp),%eax
  102bdc:	0f b6 00             	movzbl (%eax),%eax
  102bdf:	3c 2f                	cmp    $0x2f,%al
  102be1:	7e 1b                	jle    102bfe <strtol+0xd2>
  102be3:	8b 45 08             	mov    0x8(%ebp),%eax
  102be6:	0f b6 00             	movzbl (%eax),%eax
  102be9:	3c 39                	cmp    $0x39,%al
  102beb:	7f 11                	jg     102bfe <strtol+0xd2>
            dig = *s - '0';
  102bed:	8b 45 08             	mov    0x8(%ebp),%eax
  102bf0:	0f b6 00             	movzbl (%eax),%eax
  102bf3:	0f be c0             	movsbl %al,%eax
  102bf6:	83 e8 30             	sub    $0x30,%eax
  102bf9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102bfc:	eb 48                	jmp    102c46 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
  102bfe:	8b 45 08             	mov    0x8(%ebp),%eax
  102c01:	0f b6 00             	movzbl (%eax),%eax
  102c04:	3c 60                	cmp    $0x60,%al
  102c06:	7e 1b                	jle    102c23 <strtol+0xf7>
  102c08:	8b 45 08             	mov    0x8(%ebp),%eax
  102c0b:	0f b6 00             	movzbl (%eax),%eax
  102c0e:	3c 7a                	cmp    $0x7a,%al
  102c10:	7f 11                	jg     102c23 <strtol+0xf7>
            dig = *s - 'a' + 10;
  102c12:	8b 45 08             	mov    0x8(%ebp),%eax
  102c15:	0f b6 00             	movzbl (%eax),%eax
  102c18:	0f be c0             	movsbl %al,%eax
  102c1b:	83 e8 57             	sub    $0x57,%eax
  102c1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102c21:	eb 23                	jmp    102c46 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  102c23:	8b 45 08             	mov    0x8(%ebp),%eax
  102c26:	0f b6 00             	movzbl (%eax),%eax
  102c29:	3c 40                	cmp    $0x40,%al
  102c2b:	7e 3d                	jle    102c6a <strtol+0x13e>
  102c2d:	8b 45 08             	mov    0x8(%ebp),%eax
  102c30:	0f b6 00             	movzbl (%eax),%eax
  102c33:	3c 5a                	cmp    $0x5a,%al
  102c35:	7f 33                	jg     102c6a <strtol+0x13e>
            dig = *s - 'A' + 10;
  102c37:	8b 45 08             	mov    0x8(%ebp),%eax
  102c3a:	0f b6 00             	movzbl (%eax),%eax
  102c3d:	0f be c0             	movsbl %al,%eax
  102c40:	83 e8 37             	sub    $0x37,%eax
  102c43:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  102c46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c49:	3b 45 10             	cmp    0x10(%ebp),%eax
  102c4c:	7c 02                	jl     102c50 <strtol+0x124>
            break;
  102c4e:	eb 1a                	jmp    102c6a <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
  102c50:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  102c54:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102c57:	0f af 45 10          	imul   0x10(%ebp),%eax
  102c5b:	89 c2                	mov    %eax,%edx
  102c5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c60:	01 d0                	add    %edx,%eax
  102c62:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
  102c65:	e9 6f ff ff ff       	jmp    102bd9 <strtol+0xad>

    if (endptr) {
  102c6a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102c6e:	74 08                	je     102c78 <strtol+0x14c>
        *endptr = (char *) s;
  102c70:	8b 45 0c             	mov    0xc(%ebp),%eax
  102c73:	8b 55 08             	mov    0x8(%ebp),%edx
  102c76:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  102c78:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  102c7c:	74 07                	je     102c85 <strtol+0x159>
  102c7e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102c81:	f7 d8                	neg    %eax
  102c83:	eb 03                	jmp    102c88 <strtol+0x15c>
  102c85:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  102c88:	c9                   	leave  
  102c89:	c3                   	ret    

00102c8a <memset>:
 * @n:        number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  102c8a:	55                   	push   %ebp
  102c8b:	89 e5                	mov    %esp,%ebp
  102c8d:	57                   	push   %edi
  102c8e:	83 ec 24             	sub    $0x24,%esp
  102c91:	8b 45 0c             	mov    0xc(%ebp),%eax
  102c94:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  102c97:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  102c9b:	8b 55 08             	mov    0x8(%ebp),%edx
  102c9e:	89 55 f8             	mov    %edx,-0x8(%ebp)
  102ca1:	88 45 f7             	mov    %al,-0x9(%ebp)
  102ca4:	8b 45 10             	mov    0x10(%ebp),%eax
  102ca7:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  102caa:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  102cad:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  102cb1:	8b 55 f8             	mov    -0x8(%ebp),%edx
  102cb4:	89 d7                	mov    %edx,%edi
  102cb6:	f3 aa                	rep stos %al,%es:(%edi)
  102cb8:	89 fa                	mov    %edi,%edx
  102cba:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  102cbd:	89 55 e8             	mov    %edx,-0x18(%ebp)
            "rep; stosb;"
            : "=&c" (d0), "=&D" (d1)
            : "0" (n), "a" (c), "1" (s)
            : "memory");
    return s;
  102cc0:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  102cc3:	83 c4 24             	add    $0x24,%esp
  102cc6:	5f                   	pop    %edi
  102cc7:	5d                   	pop    %ebp
  102cc8:	c3                   	ret    

00102cc9 <memmove>:
 * @n:        number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  102cc9:	55                   	push   %ebp
  102cca:	89 e5                	mov    %esp,%ebp
  102ccc:	57                   	push   %edi
  102ccd:	56                   	push   %esi
  102cce:	53                   	push   %ebx
  102ccf:	83 ec 30             	sub    $0x30,%esp
  102cd2:	8b 45 08             	mov    0x8(%ebp),%eax
  102cd5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102cd8:	8b 45 0c             	mov    0xc(%ebp),%eax
  102cdb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  102cde:	8b 45 10             	mov    0x10(%ebp),%eax
  102ce1:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  102ce4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102ce7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  102cea:	73 42                	jae    102d2e <memmove+0x65>
  102cec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102cef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  102cf2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102cf5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102cf8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102cfb:	89 45 dc             	mov    %eax,-0x24(%ebp)
            "andl $3, %%ecx;"
            "jz 1f;"
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  102cfe:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102d01:	c1 e8 02             	shr    $0x2,%eax
  102d04:	89 c1                	mov    %eax,%ecx
    asm volatile (
  102d06:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102d09:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102d0c:	89 d7                	mov    %edx,%edi
  102d0e:	89 c6                	mov    %eax,%esi
  102d10:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  102d12:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  102d15:	83 e1 03             	and    $0x3,%ecx
  102d18:	74 02                	je     102d1c <memmove+0x53>
  102d1a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  102d1c:	89 f0                	mov    %esi,%eax
  102d1e:	89 fa                	mov    %edi,%edx
  102d20:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  102d23:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  102d26:	89 45 d0             	mov    %eax,-0x30(%ebp)
            : "memory");
    return dst;
  102d29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102d2c:	eb 36                	jmp    102d64 <memmove+0x9b>
            : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  102d2e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102d31:	8d 50 ff             	lea    -0x1(%eax),%edx
  102d34:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102d37:	01 c2                	add    %eax,%edx
  102d39:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102d3c:	8d 48 ff             	lea    -0x1(%eax),%ecx
  102d3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102d42:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  102d45:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102d48:	89 c1                	mov    %eax,%ecx
  102d4a:	89 d8                	mov    %ebx,%eax
  102d4c:	89 d6                	mov    %edx,%esi
  102d4e:	89 c7                	mov    %eax,%edi
  102d50:	fd                   	std    
  102d51:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  102d53:	fc                   	cld    
  102d54:	89 f8                	mov    %edi,%eax
  102d56:	89 f2                	mov    %esi,%edx
  102d58:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  102d5b:	89 55 c8             	mov    %edx,-0x38(%ebp)
  102d5e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  102d61:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  102d64:	83 c4 30             	add    $0x30,%esp
  102d67:	5b                   	pop    %ebx
  102d68:	5e                   	pop    %esi
  102d69:	5f                   	pop    %edi
  102d6a:	5d                   	pop    %ebp
  102d6b:	c3                   	ret    

00102d6c <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  102d6c:	55                   	push   %ebp
  102d6d:	89 e5                	mov    %esp,%ebp
  102d6f:	57                   	push   %edi
  102d70:	56                   	push   %esi
  102d71:	83 ec 20             	sub    $0x20,%esp
  102d74:	8b 45 08             	mov    0x8(%ebp),%eax
  102d77:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102d7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  102d7d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102d80:	8b 45 10             	mov    0x10(%ebp),%eax
  102d83:	89 45 ec             	mov    %eax,-0x14(%ebp)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  102d86:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102d89:	c1 e8 02             	shr    $0x2,%eax
  102d8c:	89 c1                	mov    %eax,%ecx
    asm volatile (
  102d8e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102d91:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102d94:	89 d7                	mov    %edx,%edi
  102d96:	89 c6                	mov    %eax,%esi
  102d98:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  102d9a:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  102d9d:	83 e1 03             	and    $0x3,%ecx
  102da0:	74 02                	je     102da4 <memcpy+0x38>
  102da2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  102da4:	89 f0                	mov    %esi,%eax
  102da6:	89 fa                	mov    %edi,%edx
  102da8:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  102dab:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  102dae:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  102db1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  102db4:	83 c4 20             	add    $0x20,%esp
  102db7:	5e                   	pop    %esi
  102db8:	5f                   	pop    %edi
  102db9:	5d                   	pop    %ebp
  102dba:	c3                   	ret    

00102dbb <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  102dbb:	55                   	push   %ebp
  102dbc:	89 e5                	mov    %esp,%ebp
  102dbe:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  102dc1:	8b 45 08             	mov    0x8(%ebp),%eax
  102dc4:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  102dc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  102dca:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  102dcd:	eb 30                	jmp    102dff <memcmp+0x44>
        if (*s1 != *s2) {
  102dcf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102dd2:	0f b6 10             	movzbl (%eax),%edx
  102dd5:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102dd8:	0f b6 00             	movzbl (%eax),%eax
  102ddb:	38 c2                	cmp    %al,%dl
  102ddd:	74 18                	je     102df7 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  102ddf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102de2:	0f b6 00             	movzbl (%eax),%eax
  102de5:	0f b6 d0             	movzbl %al,%edx
  102de8:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102deb:	0f b6 00             	movzbl (%eax),%eax
  102dee:	0f b6 c0             	movzbl %al,%eax
  102df1:	29 c2                	sub    %eax,%edx
  102df3:	89 d0                	mov    %edx,%eax
  102df5:	eb 1a                	jmp    102e11 <memcmp+0x56>
        }
        s1 ++, s2 ++;
  102df7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  102dfb:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
    while (n -- > 0) {
  102dff:	8b 45 10             	mov    0x10(%ebp),%eax
  102e02:	8d 50 ff             	lea    -0x1(%eax),%edx
  102e05:	89 55 10             	mov    %edx,0x10(%ebp)
  102e08:	85 c0                	test   %eax,%eax
  102e0a:	75 c3                	jne    102dcf <memcmp+0x14>
    }
    return 0;
  102e0c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102e11:	c9                   	leave  
  102e12:	c3                   	ret    

00102e13 <printnum>:
 * @width:         maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:        character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  102e13:	55                   	push   %ebp
  102e14:	89 e5                	mov    %esp,%ebp
  102e16:	83 ec 58             	sub    $0x58,%esp
  102e19:	8b 45 10             	mov    0x10(%ebp),%eax
  102e1c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102e1f:	8b 45 14             	mov    0x14(%ebp),%eax
  102e22:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  102e25:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102e28:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102e2b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102e2e:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  102e31:	8b 45 18             	mov    0x18(%ebp),%eax
  102e34:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  102e37:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102e3a:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102e3d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102e40:	89 55 f0             	mov    %edx,-0x10(%ebp)
  102e43:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e46:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102e49:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  102e4d:	74 1c                	je     102e6b <printnum+0x58>
  102e4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e52:	ba 00 00 00 00       	mov    $0x0,%edx
  102e57:	f7 75 e4             	divl   -0x1c(%ebp)
  102e5a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  102e5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e60:	ba 00 00 00 00       	mov    $0x0,%edx
  102e65:	f7 75 e4             	divl   -0x1c(%ebp)
  102e68:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102e6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102e6e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102e71:	f7 75 e4             	divl   -0x1c(%ebp)
  102e74:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102e77:	89 55 dc             	mov    %edx,-0x24(%ebp)
  102e7a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102e7d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  102e80:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102e83:	89 55 ec             	mov    %edx,-0x14(%ebp)
  102e86:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102e89:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  102e8c:	8b 45 18             	mov    0x18(%ebp),%eax
  102e8f:	ba 00 00 00 00       	mov    $0x0,%edx
  102e94:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  102e97:	77 56                	ja     102eef <printnum+0xdc>
  102e99:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  102e9c:	72 05                	jb     102ea3 <printnum+0x90>
  102e9e:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  102ea1:	77 4c                	ja     102eef <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  102ea3:	8b 45 1c             	mov    0x1c(%ebp),%eax
  102ea6:	8d 50 ff             	lea    -0x1(%eax),%edx
  102ea9:	8b 45 20             	mov    0x20(%ebp),%eax
  102eac:	89 44 24 18          	mov    %eax,0x18(%esp)
  102eb0:	89 54 24 14          	mov    %edx,0x14(%esp)
  102eb4:	8b 45 18             	mov    0x18(%ebp),%eax
  102eb7:	89 44 24 10          	mov    %eax,0x10(%esp)
  102ebb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102ebe:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102ec1:	89 44 24 08          	mov    %eax,0x8(%esp)
  102ec5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  102ec9:	8b 45 0c             	mov    0xc(%ebp),%eax
  102ecc:	89 44 24 04          	mov    %eax,0x4(%esp)
  102ed0:	8b 45 08             	mov    0x8(%ebp),%eax
  102ed3:	89 04 24             	mov    %eax,(%esp)
  102ed6:	e8 38 ff ff ff       	call   102e13 <printnum>
  102edb:	eb 1c                	jmp    102ef9 <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  102edd:	8b 45 0c             	mov    0xc(%ebp),%eax
  102ee0:	89 44 24 04          	mov    %eax,0x4(%esp)
  102ee4:	8b 45 20             	mov    0x20(%ebp),%eax
  102ee7:	89 04 24             	mov    %eax,(%esp)
  102eea:	8b 45 08             	mov    0x8(%ebp),%eax
  102eed:	ff d0                	call   *%eax
        while (-- width > 0)
  102eef:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  102ef3:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  102ef7:	7f e4                	jg     102edd <printnum+0xca>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  102ef9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102efc:	05 50 3c 10 00       	add    $0x103c50,%eax
  102f01:	0f b6 00             	movzbl (%eax),%eax
  102f04:	0f be c0             	movsbl %al,%eax
  102f07:	8b 55 0c             	mov    0xc(%ebp),%edx
  102f0a:	89 54 24 04          	mov    %edx,0x4(%esp)
  102f0e:	89 04 24             	mov    %eax,(%esp)
  102f11:	8b 45 08             	mov    0x8(%ebp),%eax
  102f14:	ff d0                	call   *%eax
}
  102f16:	c9                   	leave  
  102f17:	c3                   	ret    

00102f18 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:            a varargs list pointer
 * @lflag:        determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  102f18:	55                   	push   %ebp
  102f19:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  102f1b:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  102f1f:	7e 14                	jle    102f35 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  102f21:	8b 45 08             	mov    0x8(%ebp),%eax
  102f24:	8b 00                	mov    (%eax),%eax
  102f26:	8d 48 08             	lea    0x8(%eax),%ecx
  102f29:	8b 55 08             	mov    0x8(%ebp),%edx
  102f2c:	89 0a                	mov    %ecx,(%edx)
  102f2e:	8b 50 04             	mov    0x4(%eax),%edx
  102f31:	8b 00                	mov    (%eax),%eax
  102f33:	eb 30                	jmp    102f65 <getuint+0x4d>
    }
    else if (lflag) {
  102f35:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102f39:	74 16                	je     102f51 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  102f3b:	8b 45 08             	mov    0x8(%ebp),%eax
  102f3e:	8b 00                	mov    (%eax),%eax
  102f40:	8d 48 04             	lea    0x4(%eax),%ecx
  102f43:	8b 55 08             	mov    0x8(%ebp),%edx
  102f46:	89 0a                	mov    %ecx,(%edx)
  102f48:	8b 00                	mov    (%eax),%eax
  102f4a:	ba 00 00 00 00       	mov    $0x0,%edx
  102f4f:	eb 14                	jmp    102f65 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  102f51:	8b 45 08             	mov    0x8(%ebp),%eax
  102f54:	8b 00                	mov    (%eax),%eax
  102f56:	8d 48 04             	lea    0x4(%eax),%ecx
  102f59:	8b 55 08             	mov    0x8(%ebp),%edx
  102f5c:	89 0a                	mov    %ecx,(%edx)
  102f5e:	8b 00                	mov    (%eax),%eax
  102f60:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  102f65:	5d                   	pop    %ebp
  102f66:	c3                   	ret    

00102f67 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:            a varargs list pointer
 * @lflag:        determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  102f67:	55                   	push   %ebp
  102f68:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  102f6a:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  102f6e:	7e 14                	jle    102f84 <getint+0x1d>
        return va_arg(*ap, long long);
  102f70:	8b 45 08             	mov    0x8(%ebp),%eax
  102f73:	8b 00                	mov    (%eax),%eax
  102f75:	8d 48 08             	lea    0x8(%eax),%ecx
  102f78:	8b 55 08             	mov    0x8(%ebp),%edx
  102f7b:	89 0a                	mov    %ecx,(%edx)
  102f7d:	8b 50 04             	mov    0x4(%eax),%edx
  102f80:	8b 00                	mov    (%eax),%eax
  102f82:	eb 28                	jmp    102fac <getint+0x45>
    }
    else if (lflag) {
  102f84:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102f88:	74 12                	je     102f9c <getint+0x35>
        return va_arg(*ap, long);
  102f8a:	8b 45 08             	mov    0x8(%ebp),%eax
  102f8d:	8b 00                	mov    (%eax),%eax
  102f8f:	8d 48 04             	lea    0x4(%eax),%ecx
  102f92:	8b 55 08             	mov    0x8(%ebp),%edx
  102f95:	89 0a                	mov    %ecx,(%edx)
  102f97:	8b 00                	mov    (%eax),%eax
  102f99:	99                   	cltd   
  102f9a:	eb 10                	jmp    102fac <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  102f9c:	8b 45 08             	mov    0x8(%ebp),%eax
  102f9f:	8b 00                	mov    (%eax),%eax
  102fa1:	8d 48 04             	lea    0x4(%eax),%ecx
  102fa4:	8b 55 08             	mov    0x8(%ebp),%edx
  102fa7:	89 0a                	mov    %ecx,(%edx)
  102fa9:	8b 00                	mov    (%eax),%eax
  102fab:	99                   	cltd   
    }
}
  102fac:	5d                   	pop    %ebp
  102fad:	c3                   	ret    

00102fae <printfmt>:
 * @putch:        specified putch function, print a single character
 * @putdat:        used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  102fae:	55                   	push   %ebp
  102faf:	89 e5                	mov    %esp,%ebp
  102fb1:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  102fb4:	8d 45 14             	lea    0x14(%ebp),%eax
  102fb7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  102fba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102fbd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102fc1:	8b 45 10             	mov    0x10(%ebp),%eax
  102fc4:	89 44 24 08          	mov    %eax,0x8(%esp)
  102fc8:	8b 45 0c             	mov    0xc(%ebp),%eax
  102fcb:	89 44 24 04          	mov    %eax,0x4(%esp)
  102fcf:	8b 45 08             	mov    0x8(%ebp),%eax
  102fd2:	89 04 24             	mov    %eax,(%esp)
  102fd5:	e8 02 00 00 00       	call   102fdc <vprintfmt>
    va_end(ap);
}
  102fda:	c9                   	leave  
  102fdb:	c3                   	ret    

00102fdc <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  102fdc:	55                   	push   %ebp
  102fdd:	89 e5                	mov    %esp,%ebp
  102fdf:	56                   	push   %esi
  102fe0:	53                   	push   %ebx
  102fe1:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  102fe4:	eb 18                	jmp    102ffe <vprintfmt+0x22>
            if (ch == '\0') {
  102fe6:	85 db                	test   %ebx,%ebx
  102fe8:	75 05                	jne    102fef <vprintfmt+0x13>
                return;
  102fea:	e9 d1 03 00 00       	jmp    1033c0 <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
  102fef:	8b 45 0c             	mov    0xc(%ebp),%eax
  102ff2:	89 44 24 04          	mov    %eax,0x4(%esp)
  102ff6:	89 1c 24             	mov    %ebx,(%esp)
  102ff9:	8b 45 08             	mov    0x8(%ebp),%eax
  102ffc:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  102ffe:	8b 45 10             	mov    0x10(%ebp),%eax
  103001:	8d 50 01             	lea    0x1(%eax),%edx
  103004:	89 55 10             	mov    %edx,0x10(%ebp)
  103007:	0f b6 00             	movzbl (%eax),%eax
  10300a:	0f b6 d8             	movzbl %al,%ebx
  10300d:	83 fb 25             	cmp    $0x25,%ebx
  103010:	75 d4                	jne    102fe6 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
  103012:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  103016:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  10301d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103020:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  103023:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  10302a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10302d:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  103030:	8b 45 10             	mov    0x10(%ebp),%eax
  103033:	8d 50 01             	lea    0x1(%eax),%edx
  103036:	89 55 10             	mov    %edx,0x10(%ebp)
  103039:	0f b6 00             	movzbl (%eax),%eax
  10303c:	0f b6 d8             	movzbl %al,%ebx
  10303f:	8d 43 dd             	lea    -0x23(%ebx),%eax
  103042:	83 f8 55             	cmp    $0x55,%eax
  103045:	0f 87 44 03 00 00    	ja     10338f <vprintfmt+0x3b3>
  10304b:	8b 04 85 74 3c 10 00 	mov    0x103c74(,%eax,4),%eax
  103052:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  103054:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  103058:	eb d6                	jmp    103030 <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  10305a:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  10305e:	eb d0                	jmp    103030 <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  103060:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  103067:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10306a:	89 d0                	mov    %edx,%eax
  10306c:	c1 e0 02             	shl    $0x2,%eax
  10306f:	01 d0                	add    %edx,%eax
  103071:	01 c0                	add    %eax,%eax
  103073:	01 d8                	add    %ebx,%eax
  103075:	83 e8 30             	sub    $0x30,%eax
  103078:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  10307b:	8b 45 10             	mov    0x10(%ebp),%eax
  10307e:	0f b6 00             	movzbl (%eax),%eax
  103081:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  103084:	83 fb 2f             	cmp    $0x2f,%ebx
  103087:	7e 0b                	jle    103094 <vprintfmt+0xb8>
  103089:	83 fb 39             	cmp    $0x39,%ebx
  10308c:	7f 06                	jg     103094 <vprintfmt+0xb8>
            for (precision = 0; ; ++ fmt) {
  10308e:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                    break;
                }
            }
  103092:	eb d3                	jmp    103067 <vprintfmt+0x8b>
            goto process_precision;
  103094:	eb 33                	jmp    1030c9 <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
  103096:	8b 45 14             	mov    0x14(%ebp),%eax
  103099:	8d 50 04             	lea    0x4(%eax),%edx
  10309c:	89 55 14             	mov    %edx,0x14(%ebp)
  10309f:	8b 00                	mov    (%eax),%eax
  1030a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  1030a4:	eb 23                	jmp    1030c9 <vprintfmt+0xed>

        case '.':
            if (width < 0)
  1030a6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1030aa:	79 0c                	jns    1030b8 <vprintfmt+0xdc>
                width = 0;
  1030ac:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  1030b3:	e9 78 ff ff ff       	jmp    103030 <vprintfmt+0x54>
  1030b8:	e9 73 ff ff ff       	jmp    103030 <vprintfmt+0x54>

        case '#':
            altflag = 1;
  1030bd:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  1030c4:	e9 67 ff ff ff       	jmp    103030 <vprintfmt+0x54>

        process_precision:
            if (width < 0)
  1030c9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1030cd:	79 12                	jns    1030e1 <vprintfmt+0x105>
                width = precision, precision = -1;
  1030cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1030d2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1030d5:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  1030dc:	e9 4f ff ff ff       	jmp    103030 <vprintfmt+0x54>
  1030e1:	e9 4a ff ff ff       	jmp    103030 <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  1030e6:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
  1030ea:	e9 41 ff ff ff       	jmp    103030 <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  1030ef:	8b 45 14             	mov    0x14(%ebp),%eax
  1030f2:	8d 50 04             	lea    0x4(%eax),%edx
  1030f5:	89 55 14             	mov    %edx,0x14(%ebp)
  1030f8:	8b 00                	mov    (%eax),%eax
  1030fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  1030fd:	89 54 24 04          	mov    %edx,0x4(%esp)
  103101:	89 04 24             	mov    %eax,(%esp)
  103104:	8b 45 08             	mov    0x8(%ebp),%eax
  103107:	ff d0                	call   *%eax
            break;
  103109:	e9 ac 02 00 00       	jmp    1033ba <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
  10310e:	8b 45 14             	mov    0x14(%ebp),%eax
  103111:	8d 50 04             	lea    0x4(%eax),%edx
  103114:	89 55 14             	mov    %edx,0x14(%ebp)
  103117:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  103119:	85 db                	test   %ebx,%ebx
  10311b:	79 02                	jns    10311f <vprintfmt+0x143>
                err = -err;
  10311d:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  10311f:	83 fb 06             	cmp    $0x6,%ebx
  103122:	7f 0b                	jg     10312f <vprintfmt+0x153>
  103124:	8b 34 9d 34 3c 10 00 	mov    0x103c34(,%ebx,4),%esi
  10312b:	85 f6                	test   %esi,%esi
  10312d:	75 23                	jne    103152 <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
  10312f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  103133:	c7 44 24 08 61 3c 10 	movl   $0x103c61,0x8(%esp)
  10313a:	00 
  10313b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10313e:	89 44 24 04          	mov    %eax,0x4(%esp)
  103142:	8b 45 08             	mov    0x8(%ebp),%eax
  103145:	89 04 24             	mov    %eax,(%esp)
  103148:	e8 61 fe ff ff       	call   102fae <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  10314d:	e9 68 02 00 00       	jmp    1033ba <vprintfmt+0x3de>
                printfmt(putch, putdat, "%s", p);
  103152:	89 74 24 0c          	mov    %esi,0xc(%esp)
  103156:	c7 44 24 08 6a 3c 10 	movl   $0x103c6a,0x8(%esp)
  10315d:	00 
  10315e:	8b 45 0c             	mov    0xc(%ebp),%eax
  103161:	89 44 24 04          	mov    %eax,0x4(%esp)
  103165:	8b 45 08             	mov    0x8(%ebp),%eax
  103168:	89 04 24             	mov    %eax,(%esp)
  10316b:	e8 3e fe ff ff       	call   102fae <printfmt>
            break;
  103170:	e9 45 02 00 00       	jmp    1033ba <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  103175:	8b 45 14             	mov    0x14(%ebp),%eax
  103178:	8d 50 04             	lea    0x4(%eax),%edx
  10317b:	89 55 14             	mov    %edx,0x14(%ebp)
  10317e:	8b 30                	mov    (%eax),%esi
  103180:	85 f6                	test   %esi,%esi
  103182:	75 05                	jne    103189 <vprintfmt+0x1ad>
                p = "(null)";
  103184:	be 6d 3c 10 00       	mov    $0x103c6d,%esi
            }
            if (width > 0 && padc != '-') {
  103189:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10318d:	7e 3e                	jle    1031cd <vprintfmt+0x1f1>
  10318f:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  103193:	74 38                	je     1031cd <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  103195:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  103198:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10319b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10319f:	89 34 24             	mov    %esi,(%esp)
  1031a2:	e8 dc f7 ff ff       	call   102983 <strnlen>
  1031a7:	29 c3                	sub    %eax,%ebx
  1031a9:	89 d8                	mov    %ebx,%eax
  1031ab:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1031ae:	eb 17                	jmp    1031c7 <vprintfmt+0x1eb>
                    putch(padc, putdat);
  1031b0:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  1031b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  1031b7:	89 54 24 04          	mov    %edx,0x4(%esp)
  1031bb:	89 04 24             	mov    %eax,(%esp)
  1031be:	8b 45 08             	mov    0x8(%ebp),%eax
  1031c1:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
  1031c3:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  1031c7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1031cb:	7f e3                	jg     1031b0 <vprintfmt+0x1d4>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  1031cd:	eb 38                	jmp    103207 <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
  1031cf:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  1031d3:	74 1f                	je     1031f4 <vprintfmt+0x218>
  1031d5:	83 fb 1f             	cmp    $0x1f,%ebx
  1031d8:	7e 05                	jle    1031df <vprintfmt+0x203>
  1031da:	83 fb 7e             	cmp    $0x7e,%ebx
  1031dd:	7e 15                	jle    1031f4 <vprintfmt+0x218>
                    putch('?', putdat);
  1031df:	8b 45 0c             	mov    0xc(%ebp),%eax
  1031e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1031e6:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  1031ed:	8b 45 08             	mov    0x8(%ebp),%eax
  1031f0:	ff d0                	call   *%eax
  1031f2:	eb 0f                	jmp    103203 <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
  1031f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1031f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  1031fb:	89 1c 24             	mov    %ebx,(%esp)
  1031fe:	8b 45 08             	mov    0x8(%ebp),%eax
  103201:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  103203:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  103207:	89 f0                	mov    %esi,%eax
  103209:	8d 70 01             	lea    0x1(%eax),%esi
  10320c:	0f b6 00             	movzbl (%eax),%eax
  10320f:	0f be d8             	movsbl %al,%ebx
  103212:	85 db                	test   %ebx,%ebx
  103214:	74 10                	je     103226 <vprintfmt+0x24a>
  103216:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10321a:	78 b3                	js     1031cf <vprintfmt+0x1f3>
  10321c:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  103220:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  103224:	79 a9                	jns    1031cf <vprintfmt+0x1f3>
                }
            }
            for (; width > 0; width --) {
  103226:	eb 17                	jmp    10323f <vprintfmt+0x263>
                putch(' ', putdat);
  103228:	8b 45 0c             	mov    0xc(%ebp),%eax
  10322b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10322f:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  103236:	8b 45 08             	mov    0x8(%ebp),%eax
  103239:	ff d0                	call   *%eax
            for (; width > 0; width --) {
  10323b:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  10323f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  103243:	7f e3                	jg     103228 <vprintfmt+0x24c>
            }
            break;
  103245:	e9 70 01 00 00       	jmp    1033ba <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  10324a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10324d:	89 44 24 04          	mov    %eax,0x4(%esp)
  103251:	8d 45 14             	lea    0x14(%ebp),%eax
  103254:	89 04 24             	mov    %eax,(%esp)
  103257:	e8 0b fd ff ff       	call   102f67 <getint>
  10325c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10325f:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  103262:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103265:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103268:	85 d2                	test   %edx,%edx
  10326a:	79 26                	jns    103292 <vprintfmt+0x2b6>
                putch('-', putdat);
  10326c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10326f:	89 44 24 04          	mov    %eax,0x4(%esp)
  103273:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  10327a:	8b 45 08             	mov    0x8(%ebp),%eax
  10327d:	ff d0                	call   *%eax
                num = -(long long)num;
  10327f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103282:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103285:	f7 d8                	neg    %eax
  103287:	83 d2 00             	adc    $0x0,%edx
  10328a:	f7 da                	neg    %edx
  10328c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10328f:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  103292:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  103299:	e9 a8 00 00 00       	jmp    103346 <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  10329e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1032a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1032a5:	8d 45 14             	lea    0x14(%ebp),%eax
  1032a8:	89 04 24             	mov    %eax,(%esp)
  1032ab:	e8 68 fc ff ff       	call   102f18 <getuint>
  1032b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1032b3:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  1032b6:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  1032bd:	e9 84 00 00 00       	jmp    103346 <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  1032c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1032c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  1032c9:	8d 45 14             	lea    0x14(%ebp),%eax
  1032cc:	89 04 24             	mov    %eax,(%esp)
  1032cf:	e8 44 fc ff ff       	call   102f18 <getuint>
  1032d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1032d7:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  1032da:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  1032e1:	eb 63                	jmp    103346 <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
  1032e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1032e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1032ea:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  1032f1:	8b 45 08             	mov    0x8(%ebp),%eax
  1032f4:	ff d0                	call   *%eax
            putch('x', putdat);
  1032f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1032f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1032fd:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  103304:	8b 45 08             	mov    0x8(%ebp),%eax
  103307:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  103309:	8b 45 14             	mov    0x14(%ebp),%eax
  10330c:	8d 50 04             	lea    0x4(%eax),%edx
  10330f:	89 55 14             	mov    %edx,0x14(%ebp)
  103312:	8b 00                	mov    (%eax),%eax
  103314:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103317:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  10331e:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  103325:	eb 1f                	jmp    103346 <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  103327:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10332a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10332e:	8d 45 14             	lea    0x14(%ebp),%eax
  103331:	89 04 24             	mov    %eax,(%esp)
  103334:	e8 df fb ff ff       	call   102f18 <getuint>
  103339:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10333c:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  10333f:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  103346:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  10334a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10334d:	89 54 24 18          	mov    %edx,0x18(%esp)
  103351:	8b 55 e8             	mov    -0x18(%ebp),%edx
  103354:	89 54 24 14          	mov    %edx,0x14(%esp)
  103358:	89 44 24 10          	mov    %eax,0x10(%esp)
  10335c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10335f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103362:	89 44 24 08          	mov    %eax,0x8(%esp)
  103366:	89 54 24 0c          	mov    %edx,0xc(%esp)
  10336a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10336d:	89 44 24 04          	mov    %eax,0x4(%esp)
  103371:	8b 45 08             	mov    0x8(%ebp),%eax
  103374:	89 04 24             	mov    %eax,(%esp)
  103377:	e8 97 fa ff ff       	call   102e13 <printnum>
            break;
  10337c:	eb 3c                	jmp    1033ba <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  10337e:	8b 45 0c             	mov    0xc(%ebp),%eax
  103381:	89 44 24 04          	mov    %eax,0x4(%esp)
  103385:	89 1c 24             	mov    %ebx,(%esp)
  103388:	8b 45 08             	mov    0x8(%ebp),%eax
  10338b:	ff d0                	call   *%eax
            break;
  10338d:	eb 2b                	jmp    1033ba <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  10338f:	8b 45 0c             	mov    0xc(%ebp),%eax
  103392:	89 44 24 04          	mov    %eax,0x4(%esp)
  103396:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  10339d:	8b 45 08             	mov    0x8(%ebp),%eax
  1033a0:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  1033a2:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  1033a6:	eb 04                	jmp    1033ac <vprintfmt+0x3d0>
  1033a8:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  1033ac:	8b 45 10             	mov    0x10(%ebp),%eax
  1033af:	83 e8 01             	sub    $0x1,%eax
  1033b2:	0f b6 00             	movzbl (%eax),%eax
  1033b5:	3c 25                	cmp    $0x25,%al
  1033b7:	75 ef                	jne    1033a8 <vprintfmt+0x3cc>
                /* do nothing */;
            break;
  1033b9:	90                   	nop
        }
    }
  1033ba:	90                   	nop
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  1033bb:	e9 3e fc ff ff       	jmp    102ffe <vprintfmt+0x22>
}
  1033c0:	83 c4 40             	add    $0x40,%esp
  1033c3:	5b                   	pop    %ebx
  1033c4:	5e                   	pop    %esi
  1033c5:	5d                   	pop    %ebp
  1033c6:	c3                   	ret    

001033c7 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:            the character will be printed
 * @b:            the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  1033c7:	55                   	push   %ebp
  1033c8:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  1033ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  1033cd:	8b 40 08             	mov    0x8(%eax),%eax
  1033d0:	8d 50 01             	lea    0x1(%eax),%edx
  1033d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1033d6:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  1033d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1033dc:	8b 10                	mov    (%eax),%edx
  1033de:	8b 45 0c             	mov    0xc(%ebp),%eax
  1033e1:	8b 40 04             	mov    0x4(%eax),%eax
  1033e4:	39 c2                	cmp    %eax,%edx
  1033e6:	73 12                	jae    1033fa <sprintputch+0x33>
        *b->buf ++ = ch;
  1033e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1033eb:	8b 00                	mov    (%eax),%eax
  1033ed:	8d 48 01             	lea    0x1(%eax),%ecx
  1033f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  1033f3:	89 0a                	mov    %ecx,(%edx)
  1033f5:	8b 55 08             	mov    0x8(%ebp),%edx
  1033f8:	88 10                	mov    %dl,(%eax)
    }
}
  1033fa:	5d                   	pop    %ebp
  1033fb:	c3                   	ret    

001033fc <snprintf>:
 * @str:        the buffer to place the result into
 * @size:        the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  1033fc:	55                   	push   %ebp
  1033fd:	89 e5                	mov    %esp,%ebp
  1033ff:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  103402:	8d 45 14             	lea    0x14(%ebp),%eax
  103405:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  103408:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10340b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10340f:	8b 45 10             	mov    0x10(%ebp),%eax
  103412:	89 44 24 08          	mov    %eax,0x8(%esp)
  103416:	8b 45 0c             	mov    0xc(%ebp),%eax
  103419:	89 44 24 04          	mov    %eax,0x4(%esp)
  10341d:	8b 45 08             	mov    0x8(%ebp),%eax
  103420:	89 04 24             	mov    %eax,(%esp)
  103423:	e8 08 00 00 00       	call   103430 <vsnprintf>
  103428:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  10342b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10342e:	c9                   	leave  
  10342f:	c3                   	ret    

00103430 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  103430:	55                   	push   %ebp
  103431:	89 e5                	mov    %esp,%ebp
  103433:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  103436:	8b 45 08             	mov    0x8(%ebp),%eax
  103439:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10343c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10343f:	8d 50 ff             	lea    -0x1(%eax),%edx
  103442:	8b 45 08             	mov    0x8(%ebp),%eax
  103445:	01 d0                	add    %edx,%eax
  103447:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10344a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  103451:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  103455:	74 0a                	je     103461 <vsnprintf+0x31>
  103457:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10345a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10345d:	39 c2                	cmp    %eax,%edx
  10345f:	76 07                	jbe    103468 <vsnprintf+0x38>
        return -E_INVAL;
  103461:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  103466:	eb 2a                	jmp    103492 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  103468:	8b 45 14             	mov    0x14(%ebp),%eax
  10346b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10346f:	8b 45 10             	mov    0x10(%ebp),%eax
  103472:	89 44 24 08          	mov    %eax,0x8(%esp)
  103476:	8d 45 ec             	lea    -0x14(%ebp),%eax
  103479:	89 44 24 04          	mov    %eax,0x4(%esp)
  10347d:	c7 04 24 c7 33 10 00 	movl   $0x1033c7,(%esp)
  103484:	e8 53 fb ff ff       	call   102fdc <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  103489:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10348c:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  10348f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  103492:	c9                   	leave  
  103493:	c3                   	ret    
