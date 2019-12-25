
bin/kernel:     file format elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 10 12 00       	mov    $0x121000,%eax
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
c0100020:	a3 00 10 12 c0       	mov    %eax,0xc0121000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 00 12 c0       	mov    $0xc0120000,%esp
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
c010003c:	ba fc 40 12 c0       	mov    $0xc01240fc,%edx
c0100041:	b8 00 30 12 c0       	mov    $0xc0123000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 30 12 c0 	movl   $0xc0123000,(%esp)
c010005d:	e8 5b 83 00 00       	call   c01083bd <memset>

    cons_init();                // init the console
c0100062:	e8 10 1e 00 00       	call   c0101e77 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 a0 8c 10 c0 	movl   $0xc0108ca0,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 bc 8c 10 c0 	movl   $0xc0108cbc,(%esp)
c010007c:	e8 20 02 00 00       	call   c01002a1 <cprintf>

    print_kerninfo();
c0100081:	e8 d2 08 00 00       	call   c0100958 <print_kerninfo>

    grade_backtrace();
c0100086:	e8 95 00 00 00       	call   c0100120 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 64 6b 00 00       	call   c0106bf4 <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 3f 1f 00 00       	call   c0101fd4 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 c3 20 00 00       	call   c010215d <idt_init>

    vmm_init();                 // init virtual memory management
c010009a:	e8 0a 36 00 00       	call   c01036a9 <vmm_init>

    ide_init();                 // init ide devices
c010009f:	e8 6e 0d 00 00       	call   c0100e12 <ide_init>
    swap_init();                // init swap
c01000a4:	e8 4e 45 00 00       	call   c01045f7 <swap_init>

    clock_init();               // init clock interrupt
c01000a9:	e8 7f 15 00 00       	call   c010162d <clock_init>
    intr_enable();              // enable irq interrupt
c01000ae:	e8 5c 20 00 00       	call   c010210f <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
c01000b3:	eb fe                	jmp    c01000b3 <kern_init+0x7d>

c01000b5 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000b5:	55                   	push   %ebp
c01000b6:	89 e5                	mov    %esp,%ebp
c01000b8:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000bb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000c2:	00 
c01000c3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000ca:	00 
c01000cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000d2:	e8 cf 0c 00 00       	call   c0100da6 <mon_backtrace>
}
c01000d7:	c9                   	leave  
c01000d8:	c3                   	ret    

c01000d9 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000d9:	55                   	push   %ebp
c01000da:	89 e5                	mov    %esp,%ebp
c01000dc:	53                   	push   %ebx
c01000dd:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000e0:	8d 5d 0c             	lea    0xc(%ebp),%ebx
c01000e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c01000e6:	8d 55 08             	lea    0x8(%ebp),%edx
c01000e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01000ec:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01000f0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01000f4:	89 54 24 04          	mov    %edx,0x4(%esp)
c01000f8:	89 04 24             	mov    %eax,(%esp)
c01000fb:	e8 b5 ff ff ff       	call   c01000b5 <grade_backtrace2>
}
c0100100:	83 c4 14             	add    $0x14,%esp
c0100103:	5b                   	pop    %ebx
c0100104:	5d                   	pop    %ebp
c0100105:	c3                   	ret    

c0100106 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c0100106:	55                   	push   %ebp
c0100107:	89 e5                	mov    %esp,%ebp
c0100109:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c010010c:	8b 45 10             	mov    0x10(%ebp),%eax
c010010f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100113:	8b 45 08             	mov    0x8(%ebp),%eax
c0100116:	89 04 24             	mov    %eax,(%esp)
c0100119:	e8 bb ff ff ff       	call   c01000d9 <grade_backtrace1>
}
c010011e:	c9                   	leave  
c010011f:	c3                   	ret    

c0100120 <grade_backtrace>:

void
grade_backtrace(void) {
c0100120:	55                   	push   %ebp
c0100121:	89 e5                	mov    %esp,%ebp
c0100123:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c0100126:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c010012b:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c0100132:	ff 
c0100133:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100137:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010013e:	e8 c3 ff ff ff       	call   c0100106 <grade_backtrace0>
}
c0100143:	c9                   	leave  
c0100144:	c3                   	ret    

c0100145 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c0100145:	55                   	push   %ebp
c0100146:	89 e5                	mov    %esp,%ebp
c0100148:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c010014b:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c010014e:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100151:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100154:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100157:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010015b:	0f b7 c0             	movzwl %ax,%eax
c010015e:	83 e0 03             	and    $0x3,%eax
c0100161:	89 c2                	mov    %eax,%edx
c0100163:	a1 00 30 12 c0       	mov    0xc0123000,%eax
c0100168:	89 54 24 08          	mov    %edx,0x8(%esp)
c010016c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100170:	c7 04 24 c1 8c 10 c0 	movl   $0xc0108cc1,(%esp)
c0100177:	e8 25 01 00 00       	call   c01002a1 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c010017c:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100180:	0f b7 d0             	movzwl %ax,%edx
c0100183:	a1 00 30 12 c0       	mov    0xc0123000,%eax
c0100188:	89 54 24 08          	mov    %edx,0x8(%esp)
c010018c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100190:	c7 04 24 cf 8c 10 c0 	movl   $0xc0108ccf,(%esp)
c0100197:	e8 05 01 00 00       	call   c01002a1 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c010019c:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c01001a0:	0f b7 d0             	movzwl %ax,%edx
c01001a3:	a1 00 30 12 c0       	mov    0xc0123000,%eax
c01001a8:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001ac:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001b0:	c7 04 24 dd 8c 10 c0 	movl   $0xc0108cdd,(%esp)
c01001b7:	e8 e5 00 00 00       	call   c01002a1 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001bc:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001c0:	0f b7 d0             	movzwl %ax,%edx
c01001c3:	a1 00 30 12 c0       	mov    0xc0123000,%eax
c01001c8:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001cc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001d0:	c7 04 24 eb 8c 10 c0 	movl   $0xc0108ceb,(%esp)
c01001d7:	e8 c5 00 00 00       	call   c01002a1 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001dc:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001e0:	0f b7 d0             	movzwl %ax,%edx
c01001e3:	a1 00 30 12 c0       	mov    0xc0123000,%eax
c01001e8:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001ec:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001f0:	c7 04 24 f9 8c 10 c0 	movl   $0xc0108cf9,(%esp)
c01001f7:	e8 a5 00 00 00       	call   c01002a1 <cprintf>
    round ++;
c01001fc:	a1 00 30 12 c0       	mov    0xc0123000,%eax
c0100201:	83 c0 01             	add    $0x1,%eax
c0100204:	a3 00 30 12 c0       	mov    %eax,0xc0123000
}
c0100209:	c9                   	leave  
c010020a:	c3                   	ret    

c010020b <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c010020b:	55                   	push   %ebp
c010020c:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c010020e:	5d                   	pop    %ebp
c010020f:	c3                   	ret    

c0100210 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c0100210:	55                   	push   %ebp
c0100211:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c0100213:	5d                   	pop    %ebp
c0100214:	c3                   	ret    

c0100215 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c0100215:	55                   	push   %ebp
c0100216:	89 e5                	mov    %esp,%ebp
c0100218:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c010021b:	e8 25 ff ff ff       	call   c0100145 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c0100220:	c7 04 24 08 8d 10 c0 	movl   $0xc0108d08,(%esp)
c0100227:	e8 75 00 00 00       	call   c01002a1 <cprintf>
    lab1_switch_to_user();
c010022c:	e8 da ff ff ff       	call   c010020b <lab1_switch_to_user>
    lab1_print_cur_status();
c0100231:	e8 0f ff ff ff       	call   c0100145 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100236:	c7 04 24 28 8d 10 c0 	movl   $0xc0108d28,(%esp)
c010023d:	e8 5f 00 00 00       	call   c01002a1 <cprintf>
    lab1_switch_to_kernel();
c0100242:	e8 c9 ff ff ff       	call   c0100210 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100247:	e8 f9 fe ff ff       	call   c0100145 <lab1_print_cur_status>
}
c010024c:	c9                   	leave  
c010024d:	c3                   	ret    

c010024e <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c010024e:	55                   	push   %ebp
c010024f:	89 e5                	mov    %esp,%ebp
c0100251:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100254:	8b 45 08             	mov    0x8(%ebp),%eax
c0100257:	89 04 24             	mov    %eax,(%esp)
c010025a:	e8 44 1c 00 00       	call   c0101ea3 <cons_putc>
    (*cnt) ++;
c010025f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100262:	8b 00                	mov    (%eax),%eax
c0100264:	8d 50 01             	lea    0x1(%eax),%edx
c0100267:	8b 45 0c             	mov    0xc(%ebp),%eax
c010026a:	89 10                	mov    %edx,(%eax)
}
c010026c:	c9                   	leave  
c010026d:	c3                   	ret    

c010026e <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c010026e:	55                   	push   %ebp
c010026f:	89 e5                	mov    %esp,%ebp
c0100271:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100274:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c010027b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010027e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0100282:	8b 45 08             	mov    0x8(%ebp),%eax
c0100285:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100289:	8d 45 f4             	lea    -0xc(%ebp),%eax
c010028c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100290:	c7 04 24 4e 02 10 c0 	movl   $0xc010024e,(%esp)
c0100297:	e8 73 84 00 00       	call   c010870f <vprintfmt>
    return cnt;
c010029c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010029f:	c9                   	leave  
c01002a0:	c3                   	ret    

c01002a1 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c01002a1:	55                   	push   %ebp
c01002a2:	89 e5                	mov    %esp,%ebp
c01002a4:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c01002a7:	8d 45 0c             	lea    0xc(%ebp),%eax
c01002aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c01002ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002b0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01002b4:	8b 45 08             	mov    0x8(%ebp),%eax
c01002b7:	89 04 24             	mov    %eax,(%esp)
c01002ba:	e8 af ff ff ff       	call   c010026e <vcprintf>
c01002bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c01002c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002c5:	c9                   	leave  
c01002c6:	c3                   	ret    

c01002c7 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c01002c7:	55                   	push   %ebp
c01002c8:	89 e5                	mov    %esp,%ebp
c01002ca:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c01002cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01002d0:	89 04 24             	mov    %eax,(%esp)
c01002d3:	e8 cb 1b 00 00       	call   c0101ea3 <cons_putc>
}
c01002d8:	c9                   	leave  
c01002d9:	c3                   	ret    

c01002da <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c01002da:	55                   	push   %ebp
c01002db:	89 e5                	mov    %esp,%ebp
c01002dd:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c01002e0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01002e7:	eb 13                	jmp    c01002fc <cputs+0x22>
        cputch(c, &cnt);
c01002e9:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01002ed:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01002f0:	89 54 24 04          	mov    %edx,0x4(%esp)
c01002f4:	89 04 24             	mov    %eax,(%esp)
c01002f7:	e8 52 ff ff ff       	call   c010024e <cputch>
    while ((c = *str ++) != '\0') {
c01002fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01002ff:	8d 50 01             	lea    0x1(%eax),%edx
c0100302:	89 55 08             	mov    %edx,0x8(%ebp)
c0100305:	0f b6 00             	movzbl (%eax),%eax
c0100308:	88 45 f7             	mov    %al,-0x9(%ebp)
c010030b:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c010030f:	75 d8                	jne    c01002e9 <cputs+0xf>
    }
    cputch('\n', &cnt);
c0100311:	8d 45 f0             	lea    -0x10(%ebp),%eax
c0100314:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100318:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c010031f:	e8 2a ff ff ff       	call   c010024e <cputch>
    return cnt;
c0100324:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0100327:	c9                   	leave  
c0100328:	c3                   	ret    

c0100329 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c0100329:	55                   	push   %ebp
c010032a:	89 e5                	mov    %esp,%ebp
c010032c:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c010032f:	e8 ab 1b 00 00       	call   c0101edf <cons_getc>
c0100334:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100337:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010033b:	74 f2                	je     c010032f <getchar+0x6>
        /* do nothing */;
    return c;
c010033d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100340:	c9                   	leave  
c0100341:	c3                   	ret    

c0100342 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c0100342:	55                   	push   %ebp
c0100343:	89 e5                	mov    %esp,%ebp
c0100345:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c0100348:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010034c:	74 13                	je     c0100361 <readline+0x1f>
        cprintf("%s", prompt);
c010034e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100351:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100355:	c7 04 24 47 8d 10 c0 	movl   $0xc0108d47,(%esp)
c010035c:	e8 40 ff ff ff       	call   c01002a1 <cprintf>
    }
    int i = 0, c;
c0100361:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c0100368:	e8 bc ff ff ff       	call   c0100329 <getchar>
c010036d:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c0100370:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100374:	79 07                	jns    c010037d <readline+0x3b>
            return NULL;
c0100376:	b8 00 00 00 00       	mov    $0x0,%eax
c010037b:	eb 79                	jmp    c01003f6 <readline+0xb4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c010037d:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c0100381:	7e 28                	jle    c01003ab <readline+0x69>
c0100383:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c010038a:	7f 1f                	jg     c01003ab <readline+0x69>
            cputchar(c);
c010038c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010038f:	89 04 24             	mov    %eax,(%esp)
c0100392:	e8 30 ff ff ff       	call   c01002c7 <cputchar>
            buf[i ++] = c;
c0100397:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010039a:	8d 50 01             	lea    0x1(%eax),%edx
c010039d:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01003a0:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01003a3:	88 90 20 30 12 c0    	mov    %dl,-0x3fedcfe0(%eax)
c01003a9:	eb 46                	jmp    c01003f1 <readline+0xaf>
        }
        else if (c == '\b' && i > 0) {
c01003ab:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01003af:	75 17                	jne    c01003c8 <readline+0x86>
c01003b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003b5:	7e 11                	jle    c01003c8 <readline+0x86>
            cputchar(c);
c01003b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003ba:	89 04 24             	mov    %eax,(%esp)
c01003bd:	e8 05 ff ff ff       	call   c01002c7 <cputchar>
            i --;
c01003c2:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01003c6:	eb 29                	jmp    c01003f1 <readline+0xaf>
        }
        else if (c == '\n' || c == '\r') {
c01003c8:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01003cc:	74 06                	je     c01003d4 <readline+0x92>
c01003ce:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01003d2:	75 1d                	jne    c01003f1 <readline+0xaf>
            cputchar(c);
c01003d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003d7:	89 04 24             	mov    %eax,(%esp)
c01003da:	e8 e8 fe ff ff       	call   c01002c7 <cputchar>
            buf[i] = '\0';
c01003df:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01003e2:	05 20 30 12 c0       	add    $0xc0123020,%eax
c01003e7:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01003ea:	b8 20 30 12 c0       	mov    $0xc0123020,%eax
c01003ef:	eb 05                	jmp    c01003f6 <readline+0xb4>
        }
    }
c01003f1:	e9 72 ff ff ff       	jmp    c0100368 <readline+0x26>
}
c01003f6:	c9                   	leave  
c01003f7:	c3                   	ret    

c01003f8 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c01003f8:	55                   	push   %ebp
c01003f9:	89 e5                	mov    %esp,%ebp
c01003fb:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c01003fe:	a1 20 34 12 c0       	mov    0xc0123420,%eax
c0100403:	85 c0                	test   %eax,%eax
c0100405:	74 02                	je     c0100409 <__panic+0x11>
        goto panic_dead;
c0100407:	eb 59                	jmp    c0100462 <__panic+0x6a>
    }
    is_panic = 1;
c0100409:	c7 05 20 34 12 c0 01 	movl   $0x1,0xc0123420
c0100410:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100413:	8d 45 14             	lea    0x14(%ebp),%eax
c0100416:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100419:	8b 45 0c             	mov    0xc(%ebp),%eax
c010041c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100420:	8b 45 08             	mov    0x8(%ebp),%eax
c0100423:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100427:	c7 04 24 4a 8d 10 c0 	movl   $0xc0108d4a,(%esp)
c010042e:	e8 6e fe ff ff       	call   c01002a1 <cprintf>
    vcprintf(fmt, ap);
c0100433:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100436:	89 44 24 04          	mov    %eax,0x4(%esp)
c010043a:	8b 45 10             	mov    0x10(%ebp),%eax
c010043d:	89 04 24             	mov    %eax,(%esp)
c0100440:	e8 29 fe ff ff       	call   c010026e <vcprintf>
    cprintf("\n");
c0100445:	c7 04 24 66 8d 10 c0 	movl   $0xc0108d66,(%esp)
c010044c:	e8 50 fe ff ff       	call   c01002a1 <cprintf>
    
    cprintf("stack trackback:\n");
c0100451:	c7 04 24 68 8d 10 c0 	movl   $0xc0108d68,(%esp)
c0100458:	e8 44 fe ff ff       	call   c01002a1 <cprintf>
    print_stackframe();
c010045d:	e8 40 06 00 00       	call   c0100aa2 <print_stackframe>
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100462:	e8 ae 1c 00 00       	call   c0102115 <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100467:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010046e:	e8 64 08 00 00       	call   c0100cd7 <kmonitor>
    }
c0100473:	eb f2                	jmp    c0100467 <__panic+0x6f>

c0100475 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100475:	55                   	push   %ebp
c0100476:	89 e5                	mov    %esp,%ebp
c0100478:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c010047b:	8d 45 14             	lea    0x14(%ebp),%eax
c010047e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100481:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100484:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100488:	8b 45 08             	mov    0x8(%ebp),%eax
c010048b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010048f:	c7 04 24 7a 8d 10 c0 	movl   $0xc0108d7a,(%esp)
c0100496:	e8 06 fe ff ff       	call   c01002a1 <cprintf>
    vcprintf(fmt, ap);
c010049b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010049e:	89 44 24 04          	mov    %eax,0x4(%esp)
c01004a2:	8b 45 10             	mov    0x10(%ebp),%eax
c01004a5:	89 04 24             	mov    %eax,(%esp)
c01004a8:	e8 c1 fd ff ff       	call   c010026e <vcprintf>
    cprintf("\n");
c01004ad:	c7 04 24 66 8d 10 c0 	movl   $0xc0108d66,(%esp)
c01004b4:	e8 e8 fd ff ff       	call   c01002a1 <cprintf>
    va_end(ap);
}
c01004b9:	c9                   	leave  
c01004ba:	c3                   	ret    

c01004bb <is_kernel_panic>:

bool
is_kernel_panic(void) {
c01004bb:	55                   	push   %ebp
c01004bc:	89 e5                	mov    %esp,%ebp
    return is_panic;
c01004be:	a1 20 34 12 c0       	mov    0xc0123420,%eax
}
c01004c3:	5d                   	pop    %ebp
c01004c4:	c3                   	ret    

c01004c5 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c01004c5:	55                   	push   %ebp
c01004c6:	89 e5                	mov    %esp,%ebp
c01004c8:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c01004cb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004ce:	8b 00                	mov    (%eax),%eax
c01004d0:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004d3:	8b 45 10             	mov    0x10(%ebp),%eax
c01004d6:	8b 00                	mov    (%eax),%eax
c01004d8:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c01004e2:	e9 d2 00 00 00       	jmp    c01005b9 <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
c01004e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01004ea:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01004ed:	01 d0                	add    %edx,%eax
c01004ef:	89 c2                	mov    %eax,%edx
c01004f1:	c1 ea 1f             	shr    $0x1f,%edx
c01004f4:	01 d0                	add    %edx,%eax
c01004f6:	d1 f8                	sar    %eax
c01004f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01004fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01004fe:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100501:	eb 04                	jmp    c0100507 <stab_binsearch+0x42>
            m --;
c0100503:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
c0100507:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010050a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010050d:	7c 1f                	jl     c010052e <stab_binsearch+0x69>
c010050f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100512:	89 d0                	mov    %edx,%eax
c0100514:	01 c0                	add    %eax,%eax
c0100516:	01 d0                	add    %edx,%eax
c0100518:	c1 e0 02             	shl    $0x2,%eax
c010051b:	89 c2                	mov    %eax,%edx
c010051d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100520:	01 d0                	add    %edx,%eax
c0100522:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100526:	0f b6 c0             	movzbl %al,%eax
c0100529:	3b 45 14             	cmp    0x14(%ebp),%eax
c010052c:	75 d5                	jne    c0100503 <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
c010052e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100531:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100534:	7d 0b                	jge    c0100541 <stab_binsearch+0x7c>
            l = true_m + 1;
c0100536:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100539:	83 c0 01             	add    $0x1,%eax
c010053c:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c010053f:	eb 78                	jmp    c01005b9 <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
c0100541:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0100548:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010054b:	89 d0                	mov    %edx,%eax
c010054d:	01 c0                	add    %eax,%eax
c010054f:	01 d0                	add    %edx,%eax
c0100551:	c1 e0 02             	shl    $0x2,%eax
c0100554:	89 c2                	mov    %eax,%edx
c0100556:	8b 45 08             	mov    0x8(%ebp),%eax
c0100559:	01 d0                	add    %edx,%eax
c010055b:	8b 40 08             	mov    0x8(%eax),%eax
c010055e:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100561:	73 13                	jae    c0100576 <stab_binsearch+0xb1>
            *region_left = m;
c0100563:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100566:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100569:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c010056b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010056e:	83 c0 01             	add    $0x1,%eax
c0100571:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100574:	eb 43                	jmp    c01005b9 <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
c0100576:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100579:	89 d0                	mov    %edx,%eax
c010057b:	01 c0                	add    %eax,%eax
c010057d:	01 d0                	add    %edx,%eax
c010057f:	c1 e0 02             	shl    $0x2,%eax
c0100582:	89 c2                	mov    %eax,%edx
c0100584:	8b 45 08             	mov    0x8(%ebp),%eax
c0100587:	01 d0                	add    %edx,%eax
c0100589:	8b 40 08             	mov    0x8(%eax),%eax
c010058c:	3b 45 18             	cmp    0x18(%ebp),%eax
c010058f:	76 16                	jbe    c01005a7 <stab_binsearch+0xe2>
            *region_right = m - 1;
c0100591:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100594:	8d 50 ff             	lea    -0x1(%eax),%edx
c0100597:	8b 45 10             	mov    0x10(%ebp),%eax
c010059a:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c010059c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010059f:	83 e8 01             	sub    $0x1,%eax
c01005a2:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01005a5:	eb 12                	jmp    c01005b9 <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01005a7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005aa:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005ad:	89 10                	mov    %edx,(%eax)
            l = m;
c01005af:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005b2:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01005b5:	83 45 18 01          	addl   $0x1,0x18(%ebp)
    while (l <= r) {
c01005b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01005bc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01005bf:	0f 8e 22 ff ff ff    	jle    c01004e7 <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
c01005c5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01005c9:	75 0f                	jne    c01005da <stab_binsearch+0x115>
        *region_right = *region_left - 1;
c01005cb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005ce:	8b 00                	mov    (%eax),%eax
c01005d0:	8d 50 ff             	lea    -0x1(%eax),%edx
c01005d3:	8b 45 10             	mov    0x10(%ebp),%eax
c01005d6:	89 10                	mov    %edx,(%eax)
c01005d8:	eb 3f                	jmp    c0100619 <stab_binsearch+0x154>
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
c01005da:	8b 45 10             	mov    0x10(%ebp),%eax
c01005dd:	8b 00                	mov    (%eax),%eax
c01005df:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c01005e2:	eb 04                	jmp    c01005e8 <stab_binsearch+0x123>
c01005e4:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
c01005e8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005eb:	8b 00                	mov    (%eax),%eax
c01005ed:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01005f0:	7d 1f                	jge    c0100611 <stab_binsearch+0x14c>
c01005f2:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01005f5:	89 d0                	mov    %edx,%eax
c01005f7:	01 c0                	add    %eax,%eax
c01005f9:	01 d0                	add    %edx,%eax
c01005fb:	c1 e0 02             	shl    $0x2,%eax
c01005fe:	89 c2                	mov    %eax,%edx
c0100600:	8b 45 08             	mov    0x8(%ebp),%eax
c0100603:	01 d0                	add    %edx,%eax
c0100605:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100609:	0f b6 c0             	movzbl %al,%eax
c010060c:	3b 45 14             	cmp    0x14(%ebp),%eax
c010060f:	75 d3                	jne    c01005e4 <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
c0100611:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100614:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100617:	89 10                	mov    %edx,(%eax)
    }
}
c0100619:	c9                   	leave  
c010061a:	c3                   	ret    

c010061b <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c010061b:	55                   	push   %ebp
c010061c:	89 e5                	mov    %esp,%ebp
c010061e:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0100621:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100624:	c7 00 98 8d 10 c0    	movl   $0xc0108d98,(%eax)
    info->eip_line = 0;
c010062a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010062d:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c0100634:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100637:	c7 40 08 98 8d 10 c0 	movl   $0xc0108d98,0x8(%eax)
    info->eip_fn_namelen = 9;
c010063e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100641:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c0100648:	8b 45 0c             	mov    0xc(%ebp),%eax
c010064b:	8b 55 08             	mov    0x8(%ebp),%edx
c010064e:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0100651:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100654:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c010065b:	c7 45 f4 b0 ac 10 c0 	movl   $0xc010acb0,-0xc(%ebp)
    stab_end = __STAB_END__;
c0100662:	c7 45 f0 28 9a 11 c0 	movl   $0xc0119a28,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c0100669:	c7 45 ec 29 9a 11 c0 	movl   $0xc0119a29,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c0100670:	c7 45 e8 b5 d2 11 c0 	movl   $0xc011d2b5,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c0100677:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010067a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010067d:	76 0d                	jbe    c010068c <debuginfo_eip+0x71>
c010067f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100682:	83 e8 01             	sub    $0x1,%eax
c0100685:	0f b6 00             	movzbl (%eax),%eax
c0100688:	84 c0                	test   %al,%al
c010068a:	74 0a                	je     c0100696 <debuginfo_eip+0x7b>
        return -1;
c010068c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100691:	e9 c0 02 00 00       	jmp    c0100956 <debuginfo_eip+0x33b>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c0100696:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c010069d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01006a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006a3:	29 c2                	sub    %eax,%edx
c01006a5:	89 d0                	mov    %edx,%eax
c01006a7:	c1 f8 02             	sar    $0x2,%eax
c01006aa:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01006b0:	83 e8 01             	sub    $0x1,%eax
c01006b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01006b6:	8b 45 08             	mov    0x8(%ebp),%eax
c01006b9:	89 44 24 10          	mov    %eax,0x10(%esp)
c01006bd:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01006c4:	00 
c01006c5:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01006c8:	89 44 24 08          	mov    %eax,0x8(%esp)
c01006cc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c01006cf:	89 44 24 04          	mov    %eax,0x4(%esp)
c01006d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006d6:	89 04 24             	mov    %eax,(%esp)
c01006d9:	e8 e7 fd ff ff       	call   c01004c5 <stab_binsearch>
    if (lfile == 0)
c01006de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006e1:	85 c0                	test   %eax,%eax
c01006e3:	75 0a                	jne    c01006ef <debuginfo_eip+0xd4>
        return -1;
c01006e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006ea:	e9 67 02 00 00       	jmp    c0100956 <debuginfo_eip+0x33b>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c01006ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006f2:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01006f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c01006fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01006fe:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100702:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c0100709:	00 
c010070a:	8d 45 d8             	lea    -0x28(%ebp),%eax
c010070d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100711:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100714:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100718:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010071b:	89 04 24             	mov    %eax,(%esp)
c010071e:	e8 a2 fd ff ff       	call   c01004c5 <stab_binsearch>

    if (lfun <= rfun) {
c0100723:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100726:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100729:	39 c2                	cmp    %eax,%edx
c010072b:	7f 7c                	jg     c01007a9 <debuginfo_eip+0x18e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c010072d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100730:	89 c2                	mov    %eax,%edx
c0100732:	89 d0                	mov    %edx,%eax
c0100734:	01 c0                	add    %eax,%eax
c0100736:	01 d0                	add    %edx,%eax
c0100738:	c1 e0 02             	shl    $0x2,%eax
c010073b:	89 c2                	mov    %eax,%edx
c010073d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100740:	01 d0                	add    %edx,%eax
c0100742:	8b 10                	mov    (%eax),%edx
c0100744:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0100747:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010074a:	29 c1                	sub    %eax,%ecx
c010074c:	89 c8                	mov    %ecx,%eax
c010074e:	39 c2                	cmp    %eax,%edx
c0100750:	73 22                	jae    c0100774 <debuginfo_eip+0x159>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0100752:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100755:	89 c2                	mov    %eax,%edx
c0100757:	89 d0                	mov    %edx,%eax
c0100759:	01 c0                	add    %eax,%eax
c010075b:	01 d0                	add    %edx,%eax
c010075d:	c1 e0 02             	shl    $0x2,%eax
c0100760:	89 c2                	mov    %eax,%edx
c0100762:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100765:	01 d0                	add    %edx,%eax
c0100767:	8b 10                	mov    (%eax),%edx
c0100769:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010076c:	01 c2                	add    %eax,%edx
c010076e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100771:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c0100774:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100777:	89 c2                	mov    %eax,%edx
c0100779:	89 d0                	mov    %edx,%eax
c010077b:	01 c0                	add    %eax,%eax
c010077d:	01 d0                	add    %edx,%eax
c010077f:	c1 e0 02             	shl    $0x2,%eax
c0100782:	89 c2                	mov    %eax,%edx
c0100784:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100787:	01 d0                	add    %edx,%eax
c0100789:	8b 50 08             	mov    0x8(%eax),%edx
c010078c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010078f:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c0100792:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100795:	8b 40 10             	mov    0x10(%eax),%eax
c0100798:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c010079b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010079e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c01007a1:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01007a4:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01007a7:	eb 15                	jmp    c01007be <debuginfo_eip+0x1a3>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01007a9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007ac:	8b 55 08             	mov    0x8(%ebp),%edx
c01007af:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01007b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01007b5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c01007b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01007bb:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01007be:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007c1:	8b 40 08             	mov    0x8(%eax),%eax
c01007c4:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01007cb:	00 
c01007cc:	89 04 24             	mov    %eax,(%esp)
c01007cf:	e8 5d 7a 00 00       	call   c0108231 <strfind>
c01007d4:	89 c2                	mov    %eax,%edx
c01007d6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007d9:	8b 40 08             	mov    0x8(%eax),%eax
c01007dc:	29 c2                	sub    %eax,%edx
c01007de:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007e1:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c01007e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01007e7:	89 44 24 10          	mov    %eax,0x10(%esp)
c01007eb:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c01007f2:	00 
c01007f3:	8d 45 d0             	lea    -0x30(%ebp),%eax
c01007f6:	89 44 24 08          	mov    %eax,0x8(%esp)
c01007fa:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c01007fd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100801:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100804:	89 04 24             	mov    %eax,(%esp)
c0100807:	e8 b9 fc ff ff       	call   c01004c5 <stab_binsearch>
    if (lline <= rline) {
c010080c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010080f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100812:	39 c2                	cmp    %eax,%edx
c0100814:	7f 24                	jg     c010083a <debuginfo_eip+0x21f>
        info->eip_line = stabs[rline].n_desc;
c0100816:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100819:	89 c2                	mov    %eax,%edx
c010081b:	89 d0                	mov    %edx,%eax
c010081d:	01 c0                	add    %eax,%eax
c010081f:	01 d0                	add    %edx,%eax
c0100821:	c1 e0 02             	shl    $0x2,%eax
c0100824:	89 c2                	mov    %eax,%edx
c0100826:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100829:	01 d0                	add    %edx,%eax
c010082b:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c010082f:	0f b7 d0             	movzwl %ax,%edx
c0100832:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100835:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100838:	eb 13                	jmp    c010084d <debuginfo_eip+0x232>
        return -1;
c010083a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010083f:	e9 12 01 00 00       	jmp    c0100956 <debuginfo_eip+0x33b>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c0100844:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100847:	83 e8 01             	sub    $0x1,%eax
c010084a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
c010084d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100850:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100853:	39 c2                	cmp    %eax,%edx
c0100855:	7c 56                	jl     c01008ad <debuginfo_eip+0x292>
           && stabs[lline].n_type != N_SOL
c0100857:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010085a:	89 c2                	mov    %eax,%edx
c010085c:	89 d0                	mov    %edx,%eax
c010085e:	01 c0                	add    %eax,%eax
c0100860:	01 d0                	add    %edx,%eax
c0100862:	c1 e0 02             	shl    $0x2,%eax
c0100865:	89 c2                	mov    %eax,%edx
c0100867:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010086a:	01 d0                	add    %edx,%eax
c010086c:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100870:	3c 84                	cmp    $0x84,%al
c0100872:	74 39                	je     c01008ad <debuginfo_eip+0x292>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c0100874:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100877:	89 c2                	mov    %eax,%edx
c0100879:	89 d0                	mov    %edx,%eax
c010087b:	01 c0                	add    %eax,%eax
c010087d:	01 d0                	add    %edx,%eax
c010087f:	c1 e0 02             	shl    $0x2,%eax
c0100882:	89 c2                	mov    %eax,%edx
c0100884:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100887:	01 d0                	add    %edx,%eax
c0100889:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010088d:	3c 64                	cmp    $0x64,%al
c010088f:	75 b3                	jne    c0100844 <debuginfo_eip+0x229>
c0100891:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100894:	89 c2                	mov    %eax,%edx
c0100896:	89 d0                	mov    %edx,%eax
c0100898:	01 c0                	add    %eax,%eax
c010089a:	01 d0                	add    %edx,%eax
c010089c:	c1 e0 02             	shl    $0x2,%eax
c010089f:	89 c2                	mov    %eax,%edx
c01008a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008a4:	01 d0                	add    %edx,%eax
c01008a6:	8b 40 08             	mov    0x8(%eax),%eax
c01008a9:	85 c0                	test   %eax,%eax
c01008ab:	74 97                	je     c0100844 <debuginfo_eip+0x229>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01008ad:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01008b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01008b3:	39 c2                	cmp    %eax,%edx
c01008b5:	7c 46                	jl     c01008fd <debuginfo_eip+0x2e2>
c01008b7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008ba:	89 c2                	mov    %eax,%edx
c01008bc:	89 d0                	mov    %edx,%eax
c01008be:	01 c0                	add    %eax,%eax
c01008c0:	01 d0                	add    %edx,%eax
c01008c2:	c1 e0 02             	shl    $0x2,%eax
c01008c5:	89 c2                	mov    %eax,%edx
c01008c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008ca:	01 d0                	add    %edx,%eax
c01008cc:	8b 10                	mov    (%eax),%edx
c01008ce:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c01008d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01008d4:	29 c1                	sub    %eax,%ecx
c01008d6:	89 c8                	mov    %ecx,%eax
c01008d8:	39 c2                	cmp    %eax,%edx
c01008da:	73 21                	jae    c01008fd <debuginfo_eip+0x2e2>
        info->eip_file = stabstr + stabs[lline].n_strx;
c01008dc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008df:	89 c2                	mov    %eax,%edx
c01008e1:	89 d0                	mov    %edx,%eax
c01008e3:	01 c0                	add    %eax,%eax
c01008e5:	01 d0                	add    %edx,%eax
c01008e7:	c1 e0 02             	shl    $0x2,%eax
c01008ea:	89 c2                	mov    %eax,%edx
c01008ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008ef:	01 d0                	add    %edx,%eax
c01008f1:	8b 10                	mov    (%eax),%edx
c01008f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01008f6:	01 c2                	add    %eax,%edx
c01008f8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008fb:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c01008fd:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100900:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100903:	39 c2                	cmp    %eax,%edx
c0100905:	7d 4a                	jge    c0100951 <debuginfo_eip+0x336>
        for (lline = lfun + 1;
c0100907:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010090a:	83 c0 01             	add    $0x1,%eax
c010090d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100910:	eb 18                	jmp    c010092a <debuginfo_eip+0x30f>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0100912:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100915:	8b 40 14             	mov    0x14(%eax),%eax
c0100918:	8d 50 01             	lea    0x1(%eax),%edx
c010091b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010091e:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
c0100921:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100924:	83 c0 01             	add    $0x1,%eax
c0100927:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
c010092a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010092d:	8b 45 d8             	mov    -0x28(%ebp),%eax
        for (lline = lfun + 1;
c0100930:	39 c2                	cmp    %eax,%edx
c0100932:	7d 1d                	jge    c0100951 <debuginfo_eip+0x336>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100934:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100937:	89 c2                	mov    %eax,%edx
c0100939:	89 d0                	mov    %edx,%eax
c010093b:	01 c0                	add    %eax,%eax
c010093d:	01 d0                	add    %edx,%eax
c010093f:	c1 e0 02             	shl    $0x2,%eax
c0100942:	89 c2                	mov    %eax,%edx
c0100944:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100947:	01 d0                	add    %edx,%eax
c0100949:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010094d:	3c a0                	cmp    $0xa0,%al
c010094f:	74 c1                	je     c0100912 <debuginfo_eip+0x2f7>
        }
    }
    return 0;
c0100951:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100956:	c9                   	leave  
c0100957:	c3                   	ret    

c0100958 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0100958:	55                   	push   %ebp
c0100959:	89 e5                	mov    %esp,%ebp
c010095b:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c010095e:	c7 04 24 a2 8d 10 c0 	movl   $0xc0108da2,(%esp)
c0100965:	e8 37 f9 ff ff       	call   c01002a1 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c010096a:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c0100971:	c0 
c0100972:	c7 04 24 bb 8d 10 c0 	movl   $0xc0108dbb,(%esp)
c0100979:	e8 23 f9 ff ff       	call   c01002a1 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c010097e:	c7 44 24 04 9f 8c 10 	movl   $0xc0108c9f,0x4(%esp)
c0100985:	c0 
c0100986:	c7 04 24 d3 8d 10 c0 	movl   $0xc0108dd3,(%esp)
c010098d:	e8 0f f9 ff ff       	call   c01002a1 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c0100992:	c7 44 24 04 00 30 12 	movl   $0xc0123000,0x4(%esp)
c0100999:	c0 
c010099a:	c7 04 24 eb 8d 10 c0 	movl   $0xc0108deb,(%esp)
c01009a1:	e8 fb f8 ff ff       	call   c01002a1 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c01009a6:	c7 44 24 04 fc 40 12 	movl   $0xc01240fc,0x4(%esp)
c01009ad:	c0 
c01009ae:	c7 04 24 03 8e 10 c0 	movl   $0xc0108e03,(%esp)
c01009b5:	e8 e7 f8 ff ff       	call   c01002a1 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01009ba:	b8 fc 40 12 c0       	mov    $0xc01240fc,%eax
c01009bf:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009c5:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c01009ca:	29 c2                	sub    %eax,%edx
c01009cc:	89 d0                	mov    %edx,%eax
c01009ce:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009d4:	85 c0                	test   %eax,%eax
c01009d6:	0f 48 c2             	cmovs  %edx,%eax
c01009d9:	c1 f8 0a             	sar    $0xa,%eax
c01009dc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009e0:	c7 04 24 1c 8e 10 c0 	movl   $0xc0108e1c,(%esp)
c01009e7:	e8 b5 f8 ff ff       	call   c01002a1 <cprintf>
}
c01009ec:	c9                   	leave  
c01009ed:	c3                   	ret    

c01009ee <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c01009ee:	55                   	push   %ebp
c01009ef:	89 e5                	mov    %esp,%ebp
c01009f1:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c01009f7:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01009fa:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a01:	89 04 24             	mov    %eax,(%esp)
c0100a04:	e8 12 fc ff ff       	call   c010061b <debuginfo_eip>
c0100a09:	85 c0                	test   %eax,%eax
c0100a0b:	74 15                	je     c0100a22 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c0100a0d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a10:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a14:	c7 04 24 46 8e 10 c0 	movl   $0xc0108e46,(%esp)
c0100a1b:	e8 81 f8 ff ff       	call   c01002a1 <cprintf>
c0100a20:	eb 6d                	jmp    c0100a8f <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a22:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100a29:	eb 1c                	jmp    c0100a47 <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
c0100a2b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a31:	01 d0                	add    %edx,%eax
c0100a33:	0f b6 00             	movzbl (%eax),%eax
c0100a36:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a3c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100a3f:	01 ca                	add    %ecx,%edx
c0100a41:	88 02                	mov    %al,(%edx)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a43:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100a47:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a4a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100a4d:	7f dc                	jg     c0100a2b <print_debuginfo+0x3d>
        }
        fnname[j] = '\0';
c0100a4f:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a58:	01 d0                	add    %edx,%eax
c0100a5a:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c0100a5d:	8b 45 ec             	mov    -0x14(%ebp),%eax
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100a60:	8b 55 08             	mov    0x8(%ebp),%edx
c0100a63:	89 d1                	mov    %edx,%ecx
c0100a65:	29 c1                	sub    %eax,%ecx
c0100a67:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100a6a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100a6d:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100a71:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a77:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100a7b:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100a7f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a83:	c7 04 24 62 8e 10 c0 	movl   $0xc0108e62,(%esp)
c0100a8a:	e8 12 f8 ff ff       	call   c01002a1 <cprintf>
    }
}
c0100a8f:	c9                   	leave  
c0100a90:	c3                   	ret    

c0100a91 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0100a91:	55                   	push   %ebp
c0100a92:	89 e5                	mov    %esp,%ebp
c0100a94:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0100a97:	8b 45 04             	mov    0x4(%ebp),%eax
c0100a9a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0100a9d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100aa0:	c9                   	leave  
c0100aa1:	c3                   	ret    

c0100aa2 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0100aa2:	55                   	push   %ebp
c0100aa3:	89 e5                	mov    %esp,%ebp
c0100aa5:	53                   	push   %ebx
c0100aa6:	83 ec 44             	sub    $0x44,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0100aa9:	89 e8                	mov    %ebp,%eax
c0100aab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return ebp;
c0100aae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp=read_ebp(),eip=read_eip();
c0100ab1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100ab4:	e8 d8 ff ff ff       	call   c0100a91 <read_eip>
c0100ab9:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int i;//这里在for循环里定义好像不行的样子就拿出来了
	for(i=0;ebp!=0&&i<STACKFRAME_DEPTH;i++)
c0100abc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100ac3:	e9 8d 00 00 00       	jmp    c0100b55 <print_stackframe+0xb3>
    {   
		cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c0100ac8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100acb:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100acf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ad2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ad6:	c7 04 24 74 8e 10 c0 	movl   $0xc0108e74,(%esp)
c0100add:	e8 bf f7 ff ff       	call   c01002a1 <cprintf>
		uint32_t *args = (uint32_t *)ebp + 2;       //ebp+8指向参数，+4指向返回值
c0100ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ae5:	83 c0 08             	add    $0x8,%eax
c0100ae8:	89 45 e8             	mov    %eax,-0x18(%ebp)
		cprintf("arg :0x%08x 0x%08x 0x%08x 0x%08x\n",*(args+0),*(args+1),*(args+2),*(args+3));
c0100aeb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100aee:	83 c0 0c             	add    $0xc,%eax
c0100af1:	8b 18                	mov    (%eax),%ebx
c0100af3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100af6:	83 c0 08             	add    $0x8,%eax
c0100af9:	8b 08                	mov    (%eax),%ecx
c0100afb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100afe:	83 c0 04             	add    $0x4,%eax
c0100b01:	8b 10                	mov    (%eax),%edx
c0100b03:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100b06:	8b 00                	mov    (%eax),%eax
c0100b08:	89 5c 24 10          	mov    %ebx,0x10(%esp)
c0100b0c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100b10:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100b14:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b18:	c7 04 24 90 8e 10 c0 	movl   $0xc0108e90,(%esp)
c0100b1f:	e8 7d f7 ff ff       	call   c01002a1 <cprintf>
        //依次打印调用函数的参数1 2 3 4
		cprintf("\n");
c0100b24:	c7 04 24 b2 8e 10 c0 	movl   $0xc0108eb2,(%esp)
c0100b2b:	e8 71 f7 ff ff       	call   c01002a1 <cprintf>
		print_debuginfo(eip - 1);//eip指向的是下一条指令，所以这里减1  指针占4
c0100b30:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b33:	83 e8 01             	sub    $0x1,%eax
c0100b36:	89 04 24             	mov    %eax,(%esp)
c0100b39:	e8 b0 fe ff ff       	call   c01009ee <print_debuginfo>
		eip = ((uint32_t *)ebp)[1]; //此时eip指向返回地址
c0100b3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b41:	83 c0 04             	add    $0x4,%eax
c0100b44:	8b 00                	mov    (%eax),%eax
c0100b46:	89 45 f0             	mov    %eax,-0x10(%ebp)
		ebp = ((uint32_t *)ebp)[0];//ebp存的是调用者edp，所以这里就复原了调用前edp值
c0100b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b4c:	8b 00                	mov    (%eax),%eax
c0100b4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for(i=0;ebp!=0&&i<STACKFRAME_DEPTH;i++)
c0100b51:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0100b55:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100b59:	74 0a                	je     c0100b65 <print_stackframe+0xc3>
c0100b5b:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100b5f:	0f 8e 63 ff ff ff    	jle    c0100ac8 <print_stackframe+0x26>
	}
}
c0100b65:	83 c4 44             	add    $0x44,%esp
c0100b68:	5b                   	pop    %ebx
c0100b69:	5d                   	pop    %ebp
c0100b6a:	c3                   	ret    

c0100b6b <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100b6b:	55                   	push   %ebp
c0100b6c:	89 e5                	mov    %esp,%ebp
c0100b6e:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100b71:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b78:	eb 0c                	jmp    c0100b86 <parse+0x1b>
            *buf ++ = '\0';
c0100b7a:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b7d:	8d 50 01             	lea    0x1(%eax),%edx
c0100b80:	89 55 08             	mov    %edx,0x8(%ebp)
c0100b83:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b86:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b89:	0f b6 00             	movzbl (%eax),%eax
c0100b8c:	84 c0                	test   %al,%al
c0100b8e:	74 1d                	je     c0100bad <parse+0x42>
c0100b90:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b93:	0f b6 00             	movzbl (%eax),%eax
c0100b96:	0f be c0             	movsbl %al,%eax
c0100b99:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b9d:	c7 04 24 34 8f 10 c0 	movl   $0xc0108f34,(%esp)
c0100ba4:	e8 55 76 00 00       	call   c01081fe <strchr>
c0100ba9:	85 c0                	test   %eax,%eax
c0100bab:	75 cd                	jne    c0100b7a <parse+0xf>
        }
        if (*buf == '\0') {
c0100bad:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bb0:	0f b6 00             	movzbl (%eax),%eax
c0100bb3:	84 c0                	test   %al,%al
c0100bb5:	75 02                	jne    c0100bb9 <parse+0x4e>
            break;
c0100bb7:	eb 67                	jmp    c0100c20 <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100bb9:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100bbd:	75 14                	jne    c0100bd3 <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100bbf:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100bc6:	00 
c0100bc7:	c7 04 24 39 8f 10 c0 	movl   $0xc0108f39,(%esp)
c0100bce:	e8 ce f6 ff ff       	call   c01002a1 <cprintf>
        }
        argv[argc ++] = buf;
c0100bd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bd6:	8d 50 01             	lea    0x1(%eax),%edx
c0100bd9:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100bdc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100be3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100be6:	01 c2                	add    %eax,%edx
c0100be8:	8b 45 08             	mov    0x8(%ebp),%eax
c0100beb:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100bed:	eb 04                	jmp    c0100bf3 <parse+0x88>
            buf ++;
c0100bef:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100bf3:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bf6:	0f b6 00             	movzbl (%eax),%eax
c0100bf9:	84 c0                	test   %al,%al
c0100bfb:	74 1d                	je     c0100c1a <parse+0xaf>
c0100bfd:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c00:	0f b6 00             	movzbl (%eax),%eax
c0100c03:	0f be c0             	movsbl %al,%eax
c0100c06:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c0a:	c7 04 24 34 8f 10 c0 	movl   $0xc0108f34,(%esp)
c0100c11:	e8 e8 75 00 00       	call   c01081fe <strchr>
c0100c16:	85 c0                	test   %eax,%eax
c0100c18:	74 d5                	je     c0100bef <parse+0x84>
        }
    }
c0100c1a:	90                   	nop
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100c1b:	e9 66 ff ff ff       	jmp    c0100b86 <parse+0x1b>
    return argc;
c0100c20:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100c23:	c9                   	leave  
c0100c24:	c3                   	ret    

c0100c25 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100c25:	55                   	push   %ebp
c0100c26:	89 e5                	mov    %esp,%ebp
c0100c28:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100c2b:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c2e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c32:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c35:	89 04 24             	mov    %eax,(%esp)
c0100c38:	e8 2e ff ff ff       	call   c0100b6b <parse>
c0100c3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100c40:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100c44:	75 0a                	jne    c0100c50 <runcmd+0x2b>
        return 0;
c0100c46:	b8 00 00 00 00       	mov    $0x0,%eax
c0100c4b:	e9 85 00 00 00       	jmp    c0100cd5 <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c50:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c57:	eb 5c                	jmp    c0100cb5 <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100c59:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100c5c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c5f:	89 d0                	mov    %edx,%eax
c0100c61:	01 c0                	add    %eax,%eax
c0100c63:	01 d0                	add    %edx,%eax
c0100c65:	c1 e0 02             	shl    $0x2,%eax
c0100c68:	05 00 00 12 c0       	add    $0xc0120000,%eax
c0100c6d:	8b 00                	mov    (%eax),%eax
c0100c6f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100c73:	89 04 24             	mov    %eax,(%esp)
c0100c76:	e8 e4 74 00 00       	call   c010815f <strcmp>
c0100c7b:	85 c0                	test   %eax,%eax
c0100c7d:	75 32                	jne    c0100cb1 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100c7f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c82:	89 d0                	mov    %edx,%eax
c0100c84:	01 c0                	add    %eax,%eax
c0100c86:	01 d0                	add    %edx,%eax
c0100c88:	c1 e0 02             	shl    $0x2,%eax
c0100c8b:	05 00 00 12 c0       	add    $0xc0120000,%eax
c0100c90:	8b 40 08             	mov    0x8(%eax),%eax
c0100c93:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100c96:	8d 4a ff             	lea    -0x1(%edx),%ecx
c0100c99:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100c9c:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100ca0:	8d 55 b0             	lea    -0x50(%ebp),%edx
c0100ca3:	83 c2 04             	add    $0x4,%edx
c0100ca6:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100caa:	89 0c 24             	mov    %ecx,(%esp)
c0100cad:	ff d0                	call   *%eax
c0100caf:	eb 24                	jmp    c0100cd5 <runcmd+0xb0>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100cb1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100cb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cb8:	83 f8 02             	cmp    $0x2,%eax
c0100cbb:	76 9c                	jbe    c0100c59 <runcmd+0x34>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100cbd:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100cc0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100cc4:	c7 04 24 57 8f 10 c0 	movl   $0xc0108f57,(%esp)
c0100ccb:	e8 d1 f5 ff ff       	call   c01002a1 <cprintf>
    return 0;
c0100cd0:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cd5:	c9                   	leave  
c0100cd6:	c3                   	ret    

c0100cd7 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100cd7:	55                   	push   %ebp
c0100cd8:	89 e5                	mov    %esp,%ebp
c0100cda:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100cdd:	c7 04 24 70 8f 10 c0 	movl   $0xc0108f70,(%esp)
c0100ce4:	e8 b8 f5 ff ff       	call   c01002a1 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100ce9:	c7 04 24 98 8f 10 c0 	movl   $0xc0108f98,(%esp)
c0100cf0:	e8 ac f5 ff ff       	call   c01002a1 <cprintf>

    if (tf != NULL) {
c0100cf5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100cf9:	74 0b                	je     c0100d06 <kmonitor+0x2f>
        print_trapframe(tf);
c0100cfb:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cfe:	89 04 24             	mov    %eax,(%esp)
c0100d01:	e8 0e 16 00 00       	call   c0102314 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100d06:	c7 04 24 bd 8f 10 c0 	movl   $0xc0108fbd,(%esp)
c0100d0d:	e8 30 f6 ff ff       	call   c0100342 <readline>
c0100d12:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100d15:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100d19:	74 18                	je     c0100d33 <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
c0100d1b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d1e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d22:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d25:	89 04 24             	mov    %eax,(%esp)
c0100d28:	e8 f8 fe ff ff       	call   c0100c25 <runcmd>
c0100d2d:	85 c0                	test   %eax,%eax
c0100d2f:	79 02                	jns    c0100d33 <kmonitor+0x5c>
                break;
c0100d31:	eb 02                	jmp    c0100d35 <kmonitor+0x5e>
            }
        }
    }
c0100d33:	eb d1                	jmp    c0100d06 <kmonitor+0x2f>
}
c0100d35:	c9                   	leave  
c0100d36:	c3                   	ret    

c0100d37 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100d37:	55                   	push   %ebp
c0100d38:	89 e5                	mov    %esp,%ebp
c0100d3a:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d3d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100d44:	eb 3f                	jmp    c0100d85 <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100d46:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d49:	89 d0                	mov    %edx,%eax
c0100d4b:	01 c0                	add    %eax,%eax
c0100d4d:	01 d0                	add    %edx,%eax
c0100d4f:	c1 e0 02             	shl    $0x2,%eax
c0100d52:	05 00 00 12 c0       	add    $0xc0120000,%eax
c0100d57:	8b 48 04             	mov    0x4(%eax),%ecx
c0100d5a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d5d:	89 d0                	mov    %edx,%eax
c0100d5f:	01 c0                	add    %eax,%eax
c0100d61:	01 d0                	add    %edx,%eax
c0100d63:	c1 e0 02             	shl    $0x2,%eax
c0100d66:	05 00 00 12 c0       	add    $0xc0120000,%eax
c0100d6b:	8b 00                	mov    (%eax),%eax
c0100d6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100d71:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d75:	c7 04 24 c1 8f 10 c0 	movl   $0xc0108fc1,(%esp)
c0100d7c:	e8 20 f5 ff ff       	call   c01002a1 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d81:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100d85:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d88:	83 f8 02             	cmp    $0x2,%eax
c0100d8b:	76 b9                	jbe    c0100d46 <mon_help+0xf>
    }
    return 0;
c0100d8d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d92:	c9                   	leave  
c0100d93:	c3                   	ret    

c0100d94 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100d94:	55                   	push   %ebp
c0100d95:	89 e5                	mov    %esp,%ebp
c0100d97:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100d9a:	e8 b9 fb ff ff       	call   c0100958 <print_kerninfo>
    return 0;
c0100d9f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100da4:	c9                   	leave  
c0100da5:	c3                   	ret    

c0100da6 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100da6:	55                   	push   %ebp
c0100da7:	89 e5                	mov    %esp,%ebp
c0100da9:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100dac:	e8 f1 fc ff ff       	call   c0100aa2 <print_stackframe>
    return 0;
c0100db1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100db6:	c9                   	leave  
c0100db7:	c3                   	ret    

c0100db8 <ide_wait_ready>:
    unsigned int size;          // Size in Sectors
    unsigned char model[41];    // Model in String
} ide_devices[MAX_IDE];

static int
ide_wait_ready(unsigned short iobase, bool check_error) {
c0100db8:	55                   	push   %ebp
c0100db9:	89 e5                	mov    %esp,%ebp
c0100dbb:	83 ec 14             	sub    $0x14,%esp
c0100dbe:	8b 45 08             	mov    0x8(%ebp),%eax
c0100dc1:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    int r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c0100dc5:	90                   	nop
c0100dc6:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0100dca:	83 c0 07             	add    $0x7,%eax
c0100dcd:	0f b7 c0             	movzwl %ax,%eax
c0100dd0:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100dd4:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100dd8:	89 c2                	mov    %eax,%edx
c0100dda:	ec                   	in     (%dx),%al
c0100ddb:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0100dde:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0100de2:	0f b6 c0             	movzbl %al,%eax
c0100de5:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100de8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100deb:	25 80 00 00 00       	and    $0x80,%eax
c0100df0:	85 c0                	test   %eax,%eax
c0100df2:	75 d2                	jne    c0100dc6 <ide_wait_ready+0xe>
        /* nothing */;
    if (check_error && (r & (IDE_DF | IDE_ERR)) != 0) {
c0100df4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0100df8:	74 11                	je     c0100e0b <ide_wait_ready+0x53>
c0100dfa:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100dfd:	83 e0 21             	and    $0x21,%eax
c0100e00:	85 c0                	test   %eax,%eax
c0100e02:	74 07                	je     c0100e0b <ide_wait_ready+0x53>
        return -1;
c0100e04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100e09:	eb 05                	jmp    c0100e10 <ide_wait_ready+0x58>
    }
    return 0;
c0100e0b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e10:	c9                   	leave  
c0100e11:	c3                   	ret    

c0100e12 <ide_init>:

void
ide_init(void) {
c0100e12:	55                   	push   %ebp
c0100e13:	89 e5                	mov    %esp,%ebp
c0100e15:	57                   	push   %edi
c0100e16:	53                   	push   %ebx
c0100e17:	81 ec 50 02 00 00    	sub    $0x250,%esp
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0100e1d:	66 c7 45 f6 00 00    	movw   $0x0,-0xa(%ebp)
c0100e23:	e9 d6 02 00 00       	jmp    c01010fe <ide_init+0x2ec>
        /* assume that no device here */
        ide_devices[ideno].valid = 0;
c0100e28:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e2c:	c1 e0 03             	shl    $0x3,%eax
c0100e2f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0100e36:	29 c2                	sub    %eax,%edx
c0100e38:	8d 82 40 34 12 c0    	lea    -0x3fedcbc0(%edx),%eax
c0100e3e:	c6 00 00             	movb   $0x0,(%eax)

        iobase = IO_BASE(ideno);
c0100e41:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e45:	66 d1 e8             	shr    %ax
c0100e48:	0f b7 c0             	movzwl %ax,%eax
c0100e4b:	0f b7 04 85 cc 8f 10 	movzwl -0x3fef7034(,%eax,4),%eax
c0100e52:	c0 
c0100e53:	66 89 45 ea          	mov    %ax,-0x16(%ebp)

        /* wait device ready */
        ide_wait_ready(iobase, 0);
c0100e57:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100e5b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100e62:	00 
c0100e63:	89 04 24             	mov    %eax,(%esp)
c0100e66:	e8 4d ff ff ff       	call   c0100db8 <ide_wait_ready>

        /* step1: select drive */
        outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4));
c0100e6b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e6f:	83 e0 01             	and    $0x1,%eax
c0100e72:	c1 e0 04             	shl    $0x4,%eax
c0100e75:	83 c8 e0             	or     $0xffffffe0,%eax
c0100e78:	0f b6 c0             	movzbl %al,%eax
c0100e7b:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100e7f:	83 c2 06             	add    $0x6,%edx
c0100e82:	0f b7 d2             	movzwl %dx,%edx
c0100e85:	66 89 55 d2          	mov    %dx,-0x2e(%ebp)
c0100e89:	88 45 d1             	mov    %al,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e8c:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0100e90:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0100e94:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c0100e95:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100e99:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100ea0:	00 
c0100ea1:	89 04 24             	mov    %eax,(%esp)
c0100ea4:	e8 0f ff ff ff       	call   c0100db8 <ide_wait_ready>

        /* step2: send ATA identify command */
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
c0100ea9:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100ead:	83 c0 07             	add    $0x7,%eax
c0100eb0:	0f b7 c0             	movzwl %ax,%eax
c0100eb3:	66 89 45 ce          	mov    %ax,-0x32(%ebp)
c0100eb7:	c6 45 cd ec          	movb   $0xec,-0x33(%ebp)
c0100ebb:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0100ebf:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0100ec3:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c0100ec4:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100ec8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100ecf:	00 
c0100ed0:	89 04 24             	mov    %eax,(%esp)
c0100ed3:	e8 e0 fe ff ff       	call   c0100db8 <ide_wait_ready>

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
c0100ed8:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100edc:	83 c0 07             	add    $0x7,%eax
c0100edf:	0f b7 c0             	movzwl %ax,%eax
c0100ee2:	66 89 45 ca          	mov    %ax,-0x36(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100ee6:	0f b7 45 ca          	movzwl -0x36(%ebp),%eax
c0100eea:	89 c2                	mov    %eax,%edx
c0100eec:	ec                   	in     (%dx),%al
c0100eed:	88 45 c9             	mov    %al,-0x37(%ebp)
    return data;
c0100ef0:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0100ef4:	84 c0                	test   %al,%al
c0100ef6:	0f 84 f7 01 00 00    	je     c01010f3 <ide_init+0x2e1>
c0100efc:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100f00:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0100f07:	00 
c0100f08:	89 04 24             	mov    %eax,(%esp)
c0100f0b:	e8 a8 fe ff ff       	call   c0100db8 <ide_wait_ready>
c0100f10:	85 c0                	test   %eax,%eax
c0100f12:	0f 85 db 01 00 00    	jne    c01010f3 <ide_init+0x2e1>
            continue ;
        }

        /* device is ok */
        ide_devices[ideno].valid = 1;
c0100f18:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100f1c:	c1 e0 03             	shl    $0x3,%eax
c0100f1f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0100f26:	29 c2                	sub    %eax,%edx
c0100f28:	8d 82 40 34 12 c0    	lea    -0x3fedcbc0(%edx),%eax
c0100f2e:	c6 00 01             	movb   $0x1,(%eax)

        /* read identification space of the device */
        unsigned int buffer[128];
        insl(iobase + ISA_DATA, buffer, sizeof(buffer) / sizeof(unsigned int));
c0100f31:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100f35:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0100f38:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0100f3e:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0100f41:	c7 45 bc 80 00 00 00 	movl   $0x80,-0x44(%ebp)
    asm volatile (
c0100f48:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0100f4b:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c0100f4e:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0100f51:	89 cb                	mov    %ecx,%ebx
c0100f53:	89 df                	mov    %ebx,%edi
c0100f55:	89 c1                	mov    %eax,%ecx
c0100f57:	fc                   	cld    
c0100f58:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0100f5a:	89 c8                	mov    %ecx,%eax
c0100f5c:	89 fb                	mov    %edi,%ebx
c0100f5e:	89 5d c0             	mov    %ebx,-0x40(%ebp)
c0100f61:	89 45 bc             	mov    %eax,-0x44(%ebp)

        unsigned char *ident = (unsigned char *)buffer;
c0100f64:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0100f6a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        unsigned int sectors;
        unsigned int cmdsets = *(unsigned int *)(ident + IDE_IDENT_CMDSETS);
c0100f6d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100f70:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
c0100f76:	89 45 e0             	mov    %eax,-0x20(%ebp)
        /* device use 48-bits or 28-bits addressing */
        if (cmdsets & (1 << 26)) {
c0100f79:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100f7c:	25 00 00 00 04       	and    $0x4000000,%eax
c0100f81:	85 c0                	test   %eax,%eax
c0100f83:	74 0e                	je     c0100f93 <ide_init+0x181>
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA_EXT);
c0100f85:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100f88:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
c0100f8e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100f91:	eb 09                	jmp    c0100f9c <ide_init+0x18a>
        }
        else {
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA);
c0100f93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100f96:	8b 40 78             	mov    0x78(%eax),%eax
c0100f99:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        ide_devices[ideno].sets = cmdsets;
c0100f9c:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100fa0:	c1 e0 03             	shl    $0x3,%eax
c0100fa3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0100faa:	29 c2                	sub    %eax,%edx
c0100fac:	81 c2 40 34 12 c0    	add    $0xc0123440,%edx
c0100fb2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100fb5:	89 42 04             	mov    %eax,0x4(%edx)
        ide_devices[ideno].size = sectors;
c0100fb8:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100fbc:	c1 e0 03             	shl    $0x3,%eax
c0100fbf:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0100fc6:	29 c2                	sub    %eax,%edx
c0100fc8:	81 c2 40 34 12 c0    	add    $0xc0123440,%edx
c0100fce:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100fd1:	89 42 08             	mov    %eax,0x8(%edx)

        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c0100fd4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100fd7:	83 c0 62             	add    $0x62,%eax
c0100fda:	0f b7 00             	movzwl (%eax),%eax
c0100fdd:	0f b7 c0             	movzwl %ax,%eax
c0100fe0:	25 00 02 00 00       	and    $0x200,%eax
c0100fe5:	85 c0                	test   %eax,%eax
c0100fe7:	75 24                	jne    c010100d <ide_init+0x1fb>
c0100fe9:	c7 44 24 0c d4 8f 10 	movl   $0xc0108fd4,0xc(%esp)
c0100ff0:	c0 
c0100ff1:	c7 44 24 08 17 90 10 	movl   $0xc0109017,0x8(%esp)
c0100ff8:	c0 
c0100ff9:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c0101000:	00 
c0101001:	c7 04 24 2c 90 10 c0 	movl   $0xc010902c,(%esp)
c0101008:	e8 eb f3 ff ff       	call   c01003f8 <__panic>

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
c010100d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101011:	c1 e0 03             	shl    $0x3,%eax
c0101014:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010101b:	29 c2                	sub    %eax,%edx
c010101d:	8d 82 40 34 12 c0    	lea    -0x3fedcbc0(%edx),%eax
c0101023:	83 c0 0c             	add    $0xc,%eax
c0101026:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0101029:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010102c:	83 c0 36             	add    $0x36,%eax
c010102f:	89 45 d8             	mov    %eax,-0x28(%ebp)
        unsigned int i, length = 40;
c0101032:	c7 45 d4 28 00 00 00 	movl   $0x28,-0x2c(%ebp)
        for (i = 0; i < length; i += 2) {
c0101039:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0101040:	eb 34                	jmp    c0101076 <ide_init+0x264>
            model[i] = data[i + 1], model[i + 1] = data[i];
c0101042:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101045:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101048:	01 c2                	add    %eax,%edx
c010104a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010104d:	8d 48 01             	lea    0x1(%eax),%ecx
c0101050:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101053:	01 c8                	add    %ecx,%eax
c0101055:	0f b6 00             	movzbl (%eax),%eax
c0101058:	88 02                	mov    %al,(%edx)
c010105a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010105d:	8d 50 01             	lea    0x1(%eax),%edx
c0101060:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101063:	01 c2                	add    %eax,%edx
c0101065:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101068:	8b 4d d8             	mov    -0x28(%ebp),%ecx
c010106b:	01 c8                	add    %ecx,%eax
c010106d:	0f b6 00             	movzbl (%eax),%eax
c0101070:	88 02                	mov    %al,(%edx)
        for (i = 0; i < length; i += 2) {
c0101072:	83 45 ec 02          	addl   $0x2,-0x14(%ebp)
c0101076:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101079:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010107c:	72 c4                	jb     c0101042 <ide_init+0x230>
        }
        do {
            model[i] = '\0';
c010107e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101081:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101084:	01 d0                	add    %edx,%eax
c0101086:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c0101089:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010108c:	8d 50 ff             	lea    -0x1(%eax),%edx
c010108f:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0101092:	85 c0                	test   %eax,%eax
c0101094:	74 0f                	je     c01010a5 <ide_init+0x293>
c0101096:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101099:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010109c:	01 d0                	add    %edx,%eax
c010109e:	0f b6 00             	movzbl (%eax),%eax
c01010a1:	3c 20                	cmp    $0x20,%al
c01010a3:	74 d9                	je     c010107e <ide_init+0x26c>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
c01010a5:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01010a9:	c1 e0 03             	shl    $0x3,%eax
c01010ac:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01010b3:	29 c2                	sub    %eax,%edx
c01010b5:	8d 82 40 34 12 c0    	lea    -0x3fedcbc0(%edx),%eax
c01010bb:	8d 48 0c             	lea    0xc(%eax),%ecx
c01010be:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01010c2:	c1 e0 03             	shl    $0x3,%eax
c01010c5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01010cc:	29 c2                	sub    %eax,%edx
c01010ce:	8d 82 40 34 12 c0    	lea    -0x3fedcbc0(%edx),%eax
c01010d4:	8b 50 08             	mov    0x8(%eax),%edx
c01010d7:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01010db:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01010df:	89 54 24 08          	mov    %edx,0x8(%esp)
c01010e3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01010e7:	c7 04 24 3e 90 10 c0 	movl   $0xc010903e,(%esp)
c01010ee:	e8 ae f1 ff ff       	call   c01002a1 <cprintf>
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c01010f3:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01010f7:	83 c0 01             	add    $0x1,%eax
c01010fa:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c01010fe:	66 83 7d f6 03       	cmpw   $0x3,-0xa(%ebp)
c0101103:	0f 86 1f fd ff ff    	jbe    c0100e28 <ide_init+0x16>
    }

    // enable ide interrupt
    pic_enable(IRQ_IDE1);
c0101109:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
c0101110:	e8 91 0e 00 00       	call   c0101fa6 <pic_enable>
    pic_enable(IRQ_IDE2);
c0101115:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
c010111c:	e8 85 0e 00 00       	call   c0101fa6 <pic_enable>
}
c0101121:	81 c4 50 02 00 00    	add    $0x250,%esp
c0101127:	5b                   	pop    %ebx
c0101128:	5f                   	pop    %edi
c0101129:	5d                   	pop    %ebp
c010112a:	c3                   	ret    

c010112b <ide_device_valid>:

bool
ide_device_valid(unsigned short ideno) {
c010112b:	55                   	push   %ebp
c010112c:	89 e5                	mov    %esp,%ebp
c010112e:	83 ec 04             	sub    $0x4,%esp
c0101131:	8b 45 08             	mov    0x8(%ebp),%eax
c0101134:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    return VALID_IDE(ideno);
c0101138:	66 83 7d fc 03       	cmpw   $0x3,-0x4(%ebp)
c010113d:	77 24                	ja     c0101163 <ide_device_valid+0x38>
c010113f:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101143:	c1 e0 03             	shl    $0x3,%eax
c0101146:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010114d:	29 c2                	sub    %eax,%edx
c010114f:	8d 82 40 34 12 c0    	lea    -0x3fedcbc0(%edx),%eax
c0101155:	0f b6 00             	movzbl (%eax),%eax
c0101158:	84 c0                	test   %al,%al
c010115a:	74 07                	je     c0101163 <ide_device_valid+0x38>
c010115c:	b8 01 00 00 00       	mov    $0x1,%eax
c0101161:	eb 05                	jmp    c0101168 <ide_device_valid+0x3d>
c0101163:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101168:	c9                   	leave  
c0101169:	c3                   	ret    

c010116a <ide_device_size>:

size_t
ide_device_size(unsigned short ideno) {
c010116a:	55                   	push   %ebp
c010116b:	89 e5                	mov    %esp,%ebp
c010116d:	83 ec 08             	sub    $0x8,%esp
c0101170:	8b 45 08             	mov    0x8(%ebp),%eax
c0101173:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    if (ide_device_valid(ideno)) {
c0101177:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c010117b:	89 04 24             	mov    %eax,(%esp)
c010117e:	e8 a8 ff ff ff       	call   c010112b <ide_device_valid>
c0101183:	85 c0                	test   %eax,%eax
c0101185:	74 1b                	je     c01011a2 <ide_device_size+0x38>
        return ide_devices[ideno].size;
c0101187:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c010118b:	c1 e0 03             	shl    $0x3,%eax
c010118e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101195:	29 c2                	sub    %eax,%edx
c0101197:	8d 82 40 34 12 c0    	lea    -0x3fedcbc0(%edx),%eax
c010119d:	8b 40 08             	mov    0x8(%eax),%eax
c01011a0:	eb 05                	jmp    c01011a7 <ide_device_size+0x3d>
    }
    return 0;
c01011a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01011a7:	c9                   	leave  
c01011a8:	c3                   	ret    

c01011a9 <ide_read_secs>:

int
ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs) {
c01011a9:	55                   	push   %ebp
c01011aa:	89 e5                	mov    %esp,%ebp
c01011ac:	57                   	push   %edi
c01011ad:	53                   	push   %ebx
c01011ae:	83 ec 50             	sub    $0x50,%esp
c01011b1:	8b 45 08             	mov    0x8(%ebp),%eax
c01011b4:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c01011b8:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c01011bf:	77 24                	ja     c01011e5 <ide_read_secs+0x3c>
c01011c1:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c01011c6:	77 1d                	ja     c01011e5 <ide_read_secs+0x3c>
c01011c8:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01011cc:	c1 e0 03             	shl    $0x3,%eax
c01011cf:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01011d6:	29 c2                	sub    %eax,%edx
c01011d8:	8d 82 40 34 12 c0    	lea    -0x3fedcbc0(%edx),%eax
c01011de:	0f b6 00             	movzbl (%eax),%eax
c01011e1:	84 c0                	test   %al,%al
c01011e3:	75 24                	jne    c0101209 <ide_read_secs+0x60>
c01011e5:	c7 44 24 0c 5c 90 10 	movl   $0xc010905c,0xc(%esp)
c01011ec:	c0 
c01011ed:	c7 44 24 08 17 90 10 	movl   $0xc0109017,0x8(%esp)
c01011f4:	c0 
c01011f5:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c01011fc:	00 
c01011fd:	c7 04 24 2c 90 10 c0 	movl   $0xc010902c,(%esp)
c0101204:	e8 ef f1 ff ff       	call   c01003f8 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101209:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101210:	77 0f                	ja     c0101221 <ide_read_secs+0x78>
c0101212:	8b 45 14             	mov    0x14(%ebp),%eax
c0101215:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101218:	01 d0                	add    %edx,%eax
c010121a:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c010121f:	76 24                	jbe    c0101245 <ide_read_secs+0x9c>
c0101221:	c7 44 24 0c 84 90 10 	movl   $0xc0109084,0xc(%esp)
c0101228:	c0 
c0101229:	c7 44 24 08 17 90 10 	movl   $0xc0109017,0x8(%esp)
c0101230:	c0 
c0101231:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c0101238:	00 
c0101239:	c7 04 24 2c 90 10 c0 	movl   $0xc010902c,(%esp)
c0101240:	e8 b3 f1 ff ff       	call   c01003f8 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101245:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101249:	66 d1 e8             	shr    %ax
c010124c:	0f b7 c0             	movzwl %ax,%eax
c010124f:	0f b7 04 85 cc 8f 10 	movzwl -0x3fef7034(,%eax,4),%eax
c0101256:	c0 
c0101257:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c010125b:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c010125f:	66 d1 e8             	shr    %ax
c0101262:	0f b7 c0             	movzwl %ax,%eax
c0101265:	0f b7 04 85 ce 8f 10 	movzwl -0x3fef7032(,%eax,4),%eax
c010126c:	c0 
c010126d:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101271:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101275:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010127c:	00 
c010127d:	89 04 24             	mov    %eax,(%esp)
c0101280:	e8 33 fb ff ff       	call   c0100db8 <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101285:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101289:	83 c0 02             	add    $0x2,%eax
c010128c:	0f b7 c0             	movzwl %ax,%eax
c010128f:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101293:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101297:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010129b:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010129f:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c01012a0:	8b 45 14             	mov    0x14(%ebp),%eax
c01012a3:	0f b6 c0             	movzbl %al,%eax
c01012a6:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01012aa:	83 c2 02             	add    $0x2,%edx
c01012ad:	0f b7 d2             	movzwl %dx,%edx
c01012b0:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c01012b4:	88 45 e9             	mov    %al,-0x17(%ebp)
c01012b7:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01012bb:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01012bf:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c01012c0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01012c3:	0f b6 c0             	movzbl %al,%eax
c01012c6:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01012ca:	83 c2 03             	add    $0x3,%edx
c01012cd:	0f b7 d2             	movzwl %dx,%edx
c01012d0:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01012d4:	88 45 e5             	mov    %al,-0x1b(%ebp)
c01012d7:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01012db:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01012df:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c01012e0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01012e3:	c1 e8 08             	shr    $0x8,%eax
c01012e6:	0f b6 c0             	movzbl %al,%eax
c01012e9:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01012ed:	83 c2 04             	add    $0x4,%edx
c01012f0:	0f b7 d2             	movzwl %dx,%edx
c01012f3:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c01012f7:	88 45 e1             	mov    %al,-0x1f(%ebp)
c01012fa:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01012fe:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101302:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101303:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101306:	c1 e8 10             	shr    $0x10,%eax
c0101309:	0f b6 c0             	movzbl %al,%eax
c010130c:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101310:	83 c2 05             	add    $0x5,%edx
c0101313:	0f b7 d2             	movzwl %dx,%edx
c0101316:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c010131a:	88 45 dd             	mov    %al,-0x23(%ebp)
c010131d:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101321:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101325:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101326:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c010132a:	83 e0 01             	and    $0x1,%eax
c010132d:	c1 e0 04             	shl    $0x4,%eax
c0101330:	89 c2                	mov    %eax,%edx
c0101332:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101335:	c1 e8 18             	shr    $0x18,%eax
c0101338:	83 e0 0f             	and    $0xf,%eax
c010133b:	09 d0                	or     %edx,%eax
c010133d:	83 c8 e0             	or     $0xffffffe0,%eax
c0101340:	0f b6 c0             	movzbl %al,%eax
c0101343:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101347:	83 c2 06             	add    $0x6,%edx
c010134a:	0f b7 d2             	movzwl %dx,%edx
c010134d:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101351:	88 45 d9             	mov    %al,-0x27(%ebp)
c0101354:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101358:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c010135c:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);
c010135d:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101361:	83 c0 07             	add    $0x7,%eax
c0101364:	0f b7 c0             	movzwl %ax,%eax
c0101367:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c010136b:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
c010136f:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101373:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101377:	ee                   	out    %al,(%dx)

    int ret = 0;
c0101378:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c010137f:	eb 5a                	jmp    c01013db <ide_read_secs+0x232>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101381:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101385:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010138c:	00 
c010138d:	89 04 24             	mov    %eax,(%esp)
c0101390:	e8 23 fa ff ff       	call   c0100db8 <ide_wait_ready>
c0101395:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101398:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010139c:	74 02                	je     c01013a0 <ide_read_secs+0x1f7>
            goto out;
c010139e:	eb 41                	jmp    c01013e1 <ide_read_secs+0x238>
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
c01013a0:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01013a4:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01013a7:	8b 45 10             	mov    0x10(%ebp),%eax
c01013aa:	89 45 cc             	mov    %eax,-0x34(%ebp)
c01013ad:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile (
c01013b4:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01013b7:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c01013ba:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01013bd:	89 cb                	mov    %ecx,%ebx
c01013bf:	89 df                	mov    %ebx,%edi
c01013c1:	89 c1                	mov    %eax,%ecx
c01013c3:	fc                   	cld    
c01013c4:	f2 6d                	repnz insl (%dx),%es:(%edi)
c01013c6:	89 c8                	mov    %ecx,%eax
c01013c8:	89 fb                	mov    %edi,%ebx
c01013ca:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c01013cd:	89 45 c8             	mov    %eax,-0x38(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c01013d0:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c01013d4:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c01013db:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c01013df:	75 a0                	jne    c0101381 <ide_read_secs+0x1d8>
    }

out:
    return ret;
c01013e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01013e4:	83 c4 50             	add    $0x50,%esp
c01013e7:	5b                   	pop    %ebx
c01013e8:	5f                   	pop    %edi
c01013e9:	5d                   	pop    %ebp
c01013ea:	c3                   	ret    

c01013eb <ide_write_secs>:

int
ide_write_secs(unsigned short ideno, uint32_t secno, const void *src, size_t nsecs) {
c01013eb:	55                   	push   %ebp
c01013ec:	89 e5                	mov    %esp,%ebp
c01013ee:	56                   	push   %esi
c01013ef:	53                   	push   %ebx
c01013f0:	83 ec 50             	sub    $0x50,%esp
c01013f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01013f6:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c01013fa:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101401:	77 24                	ja     c0101427 <ide_write_secs+0x3c>
c0101403:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c0101408:	77 1d                	ja     c0101427 <ide_write_secs+0x3c>
c010140a:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c010140e:	c1 e0 03             	shl    $0x3,%eax
c0101411:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101418:	29 c2                	sub    %eax,%edx
c010141a:	8d 82 40 34 12 c0    	lea    -0x3fedcbc0(%edx),%eax
c0101420:	0f b6 00             	movzbl (%eax),%eax
c0101423:	84 c0                	test   %al,%al
c0101425:	75 24                	jne    c010144b <ide_write_secs+0x60>
c0101427:	c7 44 24 0c 5c 90 10 	movl   $0xc010905c,0xc(%esp)
c010142e:	c0 
c010142f:	c7 44 24 08 17 90 10 	movl   $0xc0109017,0x8(%esp)
c0101436:	c0 
c0101437:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c010143e:	00 
c010143f:	c7 04 24 2c 90 10 c0 	movl   $0xc010902c,(%esp)
c0101446:	e8 ad ef ff ff       	call   c01003f8 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c010144b:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101452:	77 0f                	ja     c0101463 <ide_write_secs+0x78>
c0101454:	8b 45 14             	mov    0x14(%ebp),%eax
c0101457:	8b 55 0c             	mov    0xc(%ebp),%edx
c010145a:	01 d0                	add    %edx,%eax
c010145c:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101461:	76 24                	jbe    c0101487 <ide_write_secs+0x9c>
c0101463:	c7 44 24 0c 84 90 10 	movl   $0xc0109084,0xc(%esp)
c010146a:	c0 
c010146b:	c7 44 24 08 17 90 10 	movl   $0xc0109017,0x8(%esp)
c0101472:	c0 
c0101473:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
c010147a:	00 
c010147b:	c7 04 24 2c 90 10 c0 	movl   $0xc010902c,(%esp)
c0101482:	e8 71 ef ff ff       	call   c01003f8 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101487:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c010148b:	66 d1 e8             	shr    %ax
c010148e:	0f b7 c0             	movzwl %ax,%eax
c0101491:	0f b7 04 85 cc 8f 10 	movzwl -0x3fef7034(,%eax,4),%eax
c0101498:	c0 
c0101499:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c010149d:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01014a1:	66 d1 e8             	shr    %ax
c01014a4:	0f b7 c0             	movzwl %ax,%eax
c01014a7:	0f b7 04 85 ce 8f 10 	movzwl -0x3fef7032(,%eax,4),%eax
c01014ae:	c0 
c01014af:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c01014b3:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01014b7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01014be:	00 
c01014bf:	89 04 24             	mov    %eax,(%esp)
c01014c2:	e8 f1 f8 ff ff       	call   c0100db8 <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c01014c7:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01014cb:	83 c0 02             	add    $0x2,%eax
c01014ce:	0f b7 c0             	movzwl %ax,%eax
c01014d1:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c01014d5:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01014d9:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01014dd:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01014e1:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c01014e2:	8b 45 14             	mov    0x14(%ebp),%eax
c01014e5:	0f b6 c0             	movzbl %al,%eax
c01014e8:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01014ec:	83 c2 02             	add    $0x2,%edx
c01014ef:	0f b7 d2             	movzwl %dx,%edx
c01014f2:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c01014f6:	88 45 e9             	mov    %al,-0x17(%ebp)
c01014f9:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01014fd:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101501:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101502:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101505:	0f b6 c0             	movzbl %al,%eax
c0101508:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010150c:	83 c2 03             	add    $0x3,%edx
c010150f:	0f b7 d2             	movzwl %dx,%edx
c0101512:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101516:	88 45 e5             	mov    %al,-0x1b(%ebp)
c0101519:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c010151d:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101521:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101522:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101525:	c1 e8 08             	shr    $0x8,%eax
c0101528:	0f b6 c0             	movzbl %al,%eax
c010152b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010152f:	83 c2 04             	add    $0x4,%edx
c0101532:	0f b7 d2             	movzwl %dx,%edx
c0101535:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101539:	88 45 e1             	mov    %al,-0x1f(%ebp)
c010153c:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101540:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101544:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101545:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101548:	c1 e8 10             	shr    $0x10,%eax
c010154b:	0f b6 c0             	movzbl %al,%eax
c010154e:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101552:	83 c2 05             	add    $0x5,%edx
c0101555:	0f b7 d2             	movzwl %dx,%edx
c0101558:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c010155c:	88 45 dd             	mov    %al,-0x23(%ebp)
c010155f:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101563:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101567:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101568:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c010156c:	83 e0 01             	and    $0x1,%eax
c010156f:	c1 e0 04             	shl    $0x4,%eax
c0101572:	89 c2                	mov    %eax,%edx
c0101574:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101577:	c1 e8 18             	shr    $0x18,%eax
c010157a:	83 e0 0f             	and    $0xf,%eax
c010157d:	09 d0                	or     %edx,%eax
c010157f:	83 c8 e0             	or     $0xffffffe0,%eax
c0101582:	0f b6 c0             	movzbl %al,%eax
c0101585:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101589:	83 c2 06             	add    $0x6,%edx
c010158c:	0f b7 d2             	movzwl %dx,%edx
c010158f:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101593:	88 45 d9             	mov    %al,-0x27(%ebp)
c0101596:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c010159a:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c010159e:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);
c010159f:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01015a3:	83 c0 07             	add    $0x7,%eax
c01015a6:	0f b7 c0             	movzwl %ax,%eax
c01015a9:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c01015ad:	c6 45 d5 30          	movb   $0x30,-0x2b(%ebp)
c01015b1:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c01015b5:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c01015b9:	ee                   	out    %al,(%dx)

    int ret = 0;
c01015ba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c01015c1:	eb 5a                	jmp    c010161d <ide_write_secs+0x232>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c01015c3:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01015c7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01015ce:	00 
c01015cf:	89 04 24             	mov    %eax,(%esp)
c01015d2:	e8 e1 f7 ff ff       	call   c0100db8 <ide_wait_ready>
c01015d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01015da:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01015de:	74 02                	je     c01015e2 <ide_write_secs+0x1f7>
            goto out;
c01015e0:	eb 41                	jmp    c0101623 <ide_write_secs+0x238>
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
c01015e2:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01015e6:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01015e9:	8b 45 10             	mov    0x10(%ebp),%eax
c01015ec:	89 45 cc             	mov    %eax,-0x34(%ebp)
c01015ef:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile (
c01015f6:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01015f9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c01015fc:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01015ff:	89 cb                	mov    %ecx,%ebx
c0101601:	89 de                	mov    %ebx,%esi
c0101603:	89 c1                	mov    %eax,%ecx
c0101605:	fc                   	cld    
c0101606:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
c0101608:	89 c8                	mov    %ecx,%eax
c010160a:	89 f3                	mov    %esi,%ebx
c010160c:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c010160f:	89 45 c8             	mov    %eax,-0x38(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0101612:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c0101616:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c010161d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101621:	75 a0                	jne    c01015c3 <ide_write_secs+0x1d8>
    }

out:
    return ret;
c0101623:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101626:	83 c4 50             	add    $0x50,%esp
c0101629:	5b                   	pop    %ebx
c010162a:	5e                   	pop    %esi
c010162b:	5d                   	pop    %ebp
c010162c:	c3                   	ret    

c010162d <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c010162d:	55                   	push   %ebp
c010162e:	89 e5                	mov    %esp,%ebp
c0101630:	83 ec 28             	sub    $0x28,%esp
c0101633:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c0101639:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010163d:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101641:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101645:	ee                   	out    %al,(%dx)
c0101646:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c010164c:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
c0101650:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101654:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101658:	ee                   	out    %al,(%dx)
c0101659:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
c010165f:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
c0101663:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101667:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010166b:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c010166c:	c7 05 0c 40 12 c0 00 	movl   $0x0,0xc012400c
c0101673:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0101676:	c7 04 24 be 90 10 c0 	movl   $0xc01090be,(%esp)
c010167d:	e8 1f ec ff ff       	call   c01002a1 <cprintf>
    pic_enable(IRQ_TIMER);
c0101682:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0101689:	e8 18 09 00 00       	call   c0101fa6 <pic_enable>
}
c010168e:	c9                   	leave  
c010168f:	c3                   	ret    

c0101690 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0101690:	55                   	push   %ebp
c0101691:	89 e5                	mov    %esp,%ebp
c0101693:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0101696:	9c                   	pushf  
c0101697:	58                   	pop    %eax
c0101698:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c010169b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c010169e:	25 00 02 00 00       	and    $0x200,%eax
c01016a3:	85 c0                	test   %eax,%eax
c01016a5:	74 0c                	je     c01016b3 <__intr_save+0x23>
        intr_disable();
c01016a7:	e8 69 0a 00 00       	call   c0102115 <intr_disable>
        return 1;
c01016ac:	b8 01 00 00 00       	mov    $0x1,%eax
c01016b1:	eb 05                	jmp    c01016b8 <__intr_save+0x28>
    }
    return 0;
c01016b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01016b8:	c9                   	leave  
c01016b9:	c3                   	ret    

c01016ba <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c01016ba:	55                   	push   %ebp
c01016bb:	89 e5                	mov    %esp,%ebp
c01016bd:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01016c0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01016c4:	74 05                	je     c01016cb <__intr_restore+0x11>
        intr_enable();
c01016c6:	e8 44 0a 00 00       	call   c010210f <intr_enable>
    }
}
c01016cb:	c9                   	leave  
c01016cc:	c3                   	ret    

c01016cd <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c01016cd:	55                   	push   %ebp
c01016ce:	89 e5                	mov    %esp,%ebp
c01016d0:	83 ec 10             	sub    $0x10,%esp
c01016d3:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01016d9:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c01016dd:	89 c2                	mov    %eax,%edx
c01016df:	ec                   	in     (%dx),%al
c01016e0:	88 45 fd             	mov    %al,-0x3(%ebp)
c01016e3:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c01016e9:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01016ed:	89 c2                	mov    %eax,%edx
c01016ef:	ec                   	in     (%dx),%al
c01016f0:	88 45 f9             	mov    %al,-0x7(%ebp)
c01016f3:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c01016f9:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01016fd:	89 c2                	mov    %eax,%edx
c01016ff:	ec                   	in     (%dx),%al
c0101700:	88 45 f5             	mov    %al,-0xb(%ebp)
c0101703:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
c0101709:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010170d:	89 c2                	mov    %eax,%edx
c010170f:	ec                   	in     (%dx),%al
c0101710:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0101713:	c9                   	leave  
c0101714:	c3                   	ret    

c0101715 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0101715:	55                   	push   %ebp
c0101716:	89 e5                	mov    %esp,%ebp
c0101718:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c010171b:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0101722:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101725:	0f b7 00             	movzwl (%eax),%eax
c0101728:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c010172c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010172f:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0101734:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101737:	0f b7 00             	movzwl (%eax),%eax
c010173a:	66 3d 5a a5          	cmp    $0xa55a,%ax
c010173e:	74 12                	je     c0101752 <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0101740:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0101747:	66 c7 05 26 35 12 c0 	movw   $0x3b4,0xc0123526
c010174e:	b4 03 
c0101750:	eb 13                	jmp    c0101765 <cga_init+0x50>
    } else {
        *cp = was;
c0101752:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101755:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101759:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c010175c:	66 c7 05 26 35 12 c0 	movw   $0x3d4,0xc0123526
c0101763:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0101765:	0f b7 05 26 35 12 c0 	movzwl 0xc0123526,%eax
c010176c:	0f b7 c0             	movzwl %ax,%eax
c010176f:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101773:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101777:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010177b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010177f:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0101780:	0f b7 05 26 35 12 c0 	movzwl 0xc0123526,%eax
c0101787:	83 c0 01             	add    $0x1,%eax
c010178a:	0f b7 c0             	movzwl %ax,%eax
c010178d:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101791:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0101795:	89 c2                	mov    %eax,%edx
c0101797:	ec                   	in     (%dx),%al
c0101798:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c010179b:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010179f:	0f b6 c0             	movzbl %al,%eax
c01017a2:	c1 e0 08             	shl    $0x8,%eax
c01017a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c01017a8:	0f b7 05 26 35 12 c0 	movzwl 0xc0123526,%eax
c01017af:	0f b7 c0             	movzwl %ax,%eax
c01017b2:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c01017b6:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01017ba:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01017be:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01017c2:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c01017c3:	0f b7 05 26 35 12 c0 	movzwl 0xc0123526,%eax
c01017ca:	83 c0 01             	add    $0x1,%eax
c01017cd:	0f b7 c0             	movzwl %ax,%eax
c01017d0:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01017d4:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c01017d8:	89 c2                	mov    %eax,%edx
c01017da:	ec                   	in     (%dx),%al
c01017db:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
c01017de:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01017e2:	0f b6 c0             	movzbl %al,%eax
c01017e5:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c01017e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01017eb:	a3 20 35 12 c0       	mov    %eax,0xc0123520
    crt_pos = pos;
c01017f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01017f3:	66 a3 24 35 12 c0    	mov    %ax,0xc0123524
}
c01017f9:	c9                   	leave  
c01017fa:	c3                   	ret    

c01017fb <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c01017fb:	55                   	push   %ebp
c01017fc:	89 e5                	mov    %esp,%ebp
c01017fe:	83 ec 48             	sub    $0x48,%esp
c0101801:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c0101807:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010180b:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010180f:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101813:	ee                   	out    %al,(%dx)
c0101814:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
c010181a:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
c010181e:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101822:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101826:	ee                   	out    %al,(%dx)
c0101827:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
c010182d:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
c0101831:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101835:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101839:	ee                   	out    %al,(%dx)
c010183a:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0101840:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
c0101844:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101848:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010184c:	ee                   	out    %al,(%dx)
c010184d:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
c0101853:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
c0101857:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c010185b:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010185f:	ee                   	out    %al,(%dx)
c0101860:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
c0101866:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
c010186a:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c010186e:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101872:	ee                   	out    %al,(%dx)
c0101873:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0101879:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
c010187d:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101881:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101885:	ee                   	out    %al,(%dx)
c0101886:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010188c:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
c0101890:	89 c2                	mov    %eax,%edx
c0101892:	ec                   	in     (%dx),%al
c0101893:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
c0101896:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c010189a:	3c ff                	cmp    $0xff,%al
c010189c:	0f 95 c0             	setne  %al
c010189f:	0f b6 c0             	movzbl %al,%eax
c01018a2:	a3 28 35 12 c0       	mov    %eax,0xc0123528
c01018a7:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01018ad:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
c01018b1:	89 c2                	mov    %eax,%edx
c01018b3:	ec                   	in     (%dx),%al
c01018b4:	88 45 d5             	mov    %al,-0x2b(%ebp)
c01018b7:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
c01018bd:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c01018c1:	89 c2                	mov    %eax,%edx
c01018c3:	ec                   	in     (%dx),%al
c01018c4:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c01018c7:	a1 28 35 12 c0       	mov    0xc0123528,%eax
c01018cc:	85 c0                	test   %eax,%eax
c01018ce:	74 0c                	je     c01018dc <serial_init+0xe1>
        pic_enable(IRQ_COM1);
c01018d0:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c01018d7:	e8 ca 06 00 00       	call   c0101fa6 <pic_enable>
    }
}
c01018dc:	c9                   	leave  
c01018dd:	c3                   	ret    

c01018de <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c01018de:	55                   	push   %ebp
c01018df:	89 e5                	mov    %esp,%ebp
c01018e1:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01018e4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01018eb:	eb 09                	jmp    c01018f6 <lpt_putc_sub+0x18>
        delay();
c01018ed:	e8 db fd ff ff       	call   c01016cd <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01018f2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c01018f6:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c01018fc:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101900:	89 c2                	mov    %eax,%edx
c0101902:	ec                   	in     (%dx),%al
c0101903:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101906:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010190a:	84 c0                	test   %al,%al
c010190c:	78 09                	js     c0101917 <lpt_putc_sub+0x39>
c010190e:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101915:	7e d6                	jle    c01018ed <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
c0101917:	8b 45 08             	mov    0x8(%ebp),%eax
c010191a:	0f b6 c0             	movzbl %al,%eax
c010191d:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
c0101923:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101926:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010192a:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010192e:	ee                   	out    %al,(%dx)
c010192f:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c0101935:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c0101939:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010193d:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101941:	ee                   	out    %al,(%dx)
c0101942:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
c0101948:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
c010194c:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101950:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101954:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c0101955:	c9                   	leave  
c0101956:	c3                   	ret    

c0101957 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c0101957:	55                   	push   %ebp
c0101958:	89 e5                	mov    %esp,%ebp
c010195a:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c010195d:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101961:	74 0d                	je     c0101970 <lpt_putc+0x19>
        lpt_putc_sub(c);
c0101963:	8b 45 08             	mov    0x8(%ebp),%eax
c0101966:	89 04 24             	mov    %eax,(%esp)
c0101969:	e8 70 ff ff ff       	call   c01018de <lpt_putc_sub>
c010196e:	eb 24                	jmp    c0101994 <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
c0101970:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101977:	e8 62 ff ff ff       	call   c01018de <lpt_putc_sub>
        lpt_putc_sub(' ');
c010197c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101983:	e8 56 ff ff ff       	call   c01018de <lpt_putc_sub>
        lpt_putc_sub('\b');
c0101988:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010198f:	e8 4a ff ff ff       	call   c01018de <lpt_putc_sub>
    }
}
c0101994:	c9                   	leave  
c0101995:	c3                   	ret    

c0101996 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0101996:	55                   	push   %ebp
c0101997:	89 e5                	mov    %esp,%ebp
c0101999:	53                   	push   %ebx
c010199a:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c010199d:	8b 45 08             	mov    0x8(%ebp),%eax
c01019a0:	b0 00                	mov    $0x0,%al
c01019a2:	85 c0                	test   %eax,%eax
c01019a4:	75 07                	jne    c01019ad <cga_putc+0x17>
        c |= 0x0700;
c01019a6:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c01019ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01019b0:	0f b6 c0             	movzbl %al,%eax
c01019b3:	83 f8 0a             	cmp    $0xa,%eax
c01019b6:	74 4c                	je     c0101a04 <cga_putc+0x6e>
c01019b8:	83 f8 0d             	cmp    $0xd,%eax
c01019bb:	74 57                	je     c0101a14 <cga_putc+0x7e>
c01019bd:	83 f8 08             	cmp    $0x8,%eax
c01019c0:	0f 85 88 00 00 00    	jne    c0101a4e <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
c01019c6:	0f b7 05 24 35 12 c0 	movzwl 0xc0123524,%eax
c01019cd:	66 85 c0             	test   %ax,%ax
c01019d0:	74 30                	je     c0101a02 <cga_putc+0x6c>
            crt_pos --;
c01019d2:	0f b7 05 24 35 12 c0 	movzwl 0xc0123524,%eax
c01019d9:	83 e8 01             	sub    $0x1,%eax
c01019dc:	66 a3 24 35 12 c0    	mov    %ax,0xc0123524
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c01019e2:	a1 20 35 12 c0       	mov    0xc0123520,%eax
c01019e7:	0f b7 15 24 35 12 c0 	movzwl 0xc0123524,%edx
c01019ee:	0f b7 d2             	movzwl %dx,%edx
c01019f1:	01 d2                	add    %edx,%edx
c01019f3:	01 c2                	add    %eax,%edx
c01019f5:	8b 45 08             	mov    0x8(%ebp),%eax
c01019f8:	b0 00                	mov    $0x0,%al
c01019fa:	83 c8 20             	or     $0x20,%eax
c01019fd:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c0101a00:	eb 72                	jmp    c0101a74 <cga_putc+0xde>
c0101a02:	eb 70                	jmp    c0101a74 <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
c0101a04:	0f b7 05 24 35 12 c0 	movzwl 0xc0123524,%eax
c0101a0b:	83 c0 50             	add    $0x50,%eax
c0101a0e:	66 a3 24 35 12 c0    	mov    %ax,0xc0123524
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c0101a14:	0f b7 1d 24 35 12 c0 	movzwl 0xc0123524,%ebx
c0101a1b:	0f b7 0d 24 35 12 c0 	movzwl 0xc0123524,%ecx
c0101a22:	0f b7 c1             	movzwl %cx,%eax
c0101a25:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
c0101a2b:	c1 e8 10             	shr    $0x10,%eax
c0101a2e:	89 c2                	mov    %eax,%edx
c0101a30:	66 c1 ea 06          	shr    $0x6,%dx
c0101a34:	89 d0                	mov    %edx,%eax
c0101a36:	c1 e0 02             	shl    $0x2,%eax
c0101a39:	01 d0                	add    %edx,%eax
c0101a3b:	c1 e0 04             	shl    $0x4,%eax
c0101a3e:	29 c1                	sub    %eax,%ecx
c0101a40:	89 ca                	mov    %ecx,%edx
c0101a42:	89 d8                	mov    %ebx,%eax
c0101a44:	29 d0                	sub    %edx,%eax
c0101a46:	66 a3 24 35 12 c0    	mov    %ax,0xc0123524
        break;
c0101a4c:	eb 26                	jmp    c0101a74 <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c0101a4e:	8b 0d 20 35 12 c0    	mov    0xc0123520,%ecx
c0101a54:	0f b7 05 24 35 12 c0 	movzwl 0xc0123524,%eax
c0101a5b:	8d 50 01             	lea    0x1(%eax),%edx
c0101a5e:	66 89 15 24 35 12 c0 	mov    %dx,0xc0123524
c0101a65:	0f b7 c0             	movzwl %ax,%eax
c0101a68:	01 c0                	add    %eax,%eax
c0101a6a:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c0101a6d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a70:	66 89 02             	mov    %ax,(%edx)
        break;
c0101a73:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c0101a74:	0f b7 05 24 35 12 c0 	movzwl 0xc0123524,%eax
c0101a7b:	66 3d cf 07          	cmp    $0x7cf,%ax
c0101a7f:	76 5b                	jbe    c0101adc <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c0101a81:	a1 20 35 12 c0       	mov    0xc0123520,%eax
c0101a86:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0101a8c:	a1 20 35 12 c0       	mov    0xc0123520,%eax
c0101a91:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c0101a98:	00 
c0101a99:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101a9d:	89 04 24             	mov    %eax,(%esp)
c0101aa0:	e8 57 69 00 00       	call   c01083fc <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101aa5:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101aac:	eb 15                	jmp    c0101ac3 <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
c0101aae:	a1 20 35 12 c0       	mov    0xc0123520,%eax
c0101ab3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101ab6:	01 d2                	add    %edx,%edx
c0101ab8:	01 d0                	add    %edx,%eax
c0101aba:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101abf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101ac3:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c0101aca:	7e e2                	jle    c0101aae <cga_putc+0x118>
        }
        crt_pos -= CRT_COLS;
c0101acc:	0f b7 05 24 35 12 c0 	movzwl 0xc0123524,%eax
c0101ad3:	83 e8 50             	sub    $0x50,%eax
c0101ad6:	66 a3 24 35 12 c0    	mov    %ax,0xc0123524
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c0101adc:	0f b7 05 26 35 12 c0 	movzwl 0xc0123526,%eax
c0101ae3:	0f b7 c0             	movzwl %ax,%eax
c0101ae6:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101aea:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
c0101aee:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101af2:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101af6:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c0101af7:	0f b7 05 24 35 12 c0 	movzwl 0xc0123524,%eax
c0101afe:	66 c1 e8 08          	shr    $0x8,%ax
c0101b02:	0f b6 c0             	movzbl %al,%eax
c0101b05:	0f b7 15 26 35 12 c0 	movzwl 0xc0123526,%edx
c0101b0c:	83 c2 01             	add    $0x1,%edx
c0101b0f:	0f b7 d2             	movzwl %dx,%edx
c0101b12:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
c0101b16:	88 45 ed             	mov    %al,-0x13(%ebp)
c0101b19:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101b1d:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101b21:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c0101b22:	0f b7 05 26 35 12 c0 	movzwl 0xc0123526,%eax
c0101b29:	0f b7 c0             	movzwl %ax,%eax
c0101b2c:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c0101b30:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
c0101b34:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101b38:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101b3c:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c0101b3d:	0f b7 05 24 35 12 c0 	movzwl 0xc0123524,%eax
c0101b44:	0f b6 c0             	movzbl %al,%eax
c0101b47:	0f b7 15 26 35 12 c0 	movzwl 0xc0123526,%edx
c0101b4e:	83 c2 01             	add    $0x1,%edx
c0101b51:	0f b7 d2             	movzwl %dx,%edx
c0101b54:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101b58:	88 45 e5             	mov    %al,-0x1b(%ebp)
c0101b5b:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101b5f:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101b63:	ee                   	out    %al,(%dx)
}
c0101b64:	83 c4 34             	add    $0x34,%esp
c0101b67:	5b                   	pop    %ebx
c0101b68:	5d                   	pop    %ebp
c0101b69:	c3                   	ret    

c0101b6a <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c0101b6a:	55                   	push   %ebp
c0101b6b:	89 e5                	mov    %esp,%ebp
c0101b6d:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101b70:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101b77:	eb 09                	jmp    c0101b82 <serial_putc_sub+0x18>
        delay();
c0101b79:	e8 4f fb ff ff       	call   c01016cd <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101b7e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0101b82:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101b88:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101b8c:	89 c2                	mov    %eax,%edx
c0101b8e:	ec                   	in     (%dx),%al
c0101b8f:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101b92:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101b96:	0f b6 c0             	movzbl %al,%eax
c0101b99:	83 e0 20             	and    $0x20,%eax
c0101b9c:	85 c0                	test   %eax,%eax
c0101b9e:	75 09                	jne    c0101ba9 <serial_putc_sub+0x3f>
c0101ba0:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101ba7:	7e d0                	jle    c0101b79 <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
c0101ba9:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bac:	0f b6 c0             	movzbl %al,%eax
c0101baf:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101bb5:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101bb8:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101bbc:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101bc0:	ee                   	out    %al,(%dx)
}
c0101bc1:	c9                   	leave  
c0101bc2:	c3                   	ret    

c0101bc3 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101bc3:	55                   	push   %ebp
c0101bc4:	89 e5                	mov    %esp,%ebp
c0101bc6:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101bc9:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101bcd:	74 0d                	je     c0101bdc <serial_putc+0x19>
        serial_putc_sub(c);
c0101bcf:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bd2:	89 04 24             	mov    %eax,(%esp)
c0101bd5:	e8 90 ff ff ff       	call   c0101b6a <serial_putc_sub>
c0101bda:	eb 24                	jmp    c0101c00 <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
c0101bdc:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101be3:	e8 82 ff ff ff       	call   c0101b6a <serial_putc_sub>
        serial_putc_sub(' ');
c0101be8:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101bef:	e8 76 ff ff ff       	call   c0101b6a <serial_putc_sub>
        serial_putc_sub('\b');
c0101bf4:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101bfb:	e8 6a ff ff ff       	call   c0101b6a <serial_putc_sub>
    }
}
c0101c00:	c9                   	leave  
c0101c01:	c3                   	ret    

c0101c02 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0101c02:	55                   	push   %ebp
c0101c03:	89 e5                	mov    %esp,%ebp
c0101c05:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0101c08:	eb 33                	jmp    c0101c3d <cons_intr+0x3b>
        if (c != 0) {
c0101c0a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101c0e:	74 2d                	je     c0101c3d <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c0101c10:	a1 44 37 12 c0       	mov    0xc0123744,%eax
c0101c15:	8d 50 01             	lea    0x1(%eax),%edx
c0101c18:	89 15 44 37 12 c0    	mov    %edx,0xc0123744
c0101c1e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101c21:	88 90 40 35 12 c0    	mov    %dl,-0x3fedcac0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0101c27:	a1 44 37 12 c0       	mov    0xc0123744,%eax
c0101c2c:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101c31:	75 0a                	jne    c0101c3d <cons_intr+0x3b>
                cons.wpos = 0;
c0101c33:	c7 05 44 37 12 c0 00 	movl   $0x0,0xc0123744
c0101c3a:	00 00 00 
    while ((c = (*proc)()) != -1) {
c0101c3d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c40:	ff d0                	call   *%eax
c0101c42:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101c45:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0101c49:	75 bf                	jne    c0101c0a <cons_intr+0x8>
            }
        }
    }
}
c0101c4b:	c9                   	leave  
c0101c4c:	c3                   	ret    

c0101c4d <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c0101c4d:	55                   	push   %ebp
c0101c4e:	89 e5                	mov    %esp,%ebp
c0101c50:	83 ec 10             	sub    $0x10,%esp
c0101c53:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101c59:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101c5d:	89 c2                	mov    %eax,%edx
c0101c5f:	ec                   	in     (%dx),%al
c0101c60:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101c63:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c0101c67:	0f b6 c0             	movzbl %al,%eax
c0101c6a:	83 e0 01             	and    $0x1,%eax
c0101c6d:	85 c0                	test   %eax,%eax
c0101c6f:	75 07                	jne    c0101c78 <serial_proc_data+0x2b>
        return -1;
c0101c71:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101c76:	eb 2a                	jmp    c0101ca2 <serial_proc_data+0x55>
c0101c78:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101c7e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101c82:	89 c2                	mov    %eax,%edx
c0101c84:	ec                   	in     (%dx),%al
c0101c85:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c0101c88:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c0101c8c:	0f b6 c0             	movzbl %al,%eax
c0101c8f:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0101c92:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101c96:	75 07                	jne    c0101c9f <serial_proc_data+0x52>
        c = '\b';
c0101c98:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101c9f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101ca2:	c9                   	leave  
c0101ca3:	c3                   	ret    

c0101ca4 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101ca4:	55                   	push   %ebp
c0101ca5:	89 e5                	mov    %esp,%ebp
c0101ca7:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c0101caa:	a1 28 35 12 c0       	mov    0xc0123528,%eax
c0101caf:	85 c0                	test   %eax,%eax
c0101cb1:	74 0c                	je     c0101cbf <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c0101cb3:	c7 04 24 4d 1c 10 c0 	movl   $0xc0101c4d,(%esp)
c0101cba:	e8 43 ff ff ff       	call   c0101c02 <cons_intr>
    }
}
c0101cbf:	c9                   	leave  
c0101cc0:	c3                   	ret    

c0101cc1 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101cc1:	55                   	push   %ebp
c0101cc2:	89 e5                	mov    %esp,%ebp
c0101cc4:	83 ec 38             	sub    $0x38,%esp
c0101cc7:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101ccd:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101cd1:	89 c2                	mov    %eax,%edx
c0101cd3:	ec                   	in     (%dx),%al
c0101cd4:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c0101cd7:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c0101cdb:	0f b6 c0             	movzbl %al,%eax
c0101cde:	83 e0 01             	and    $0x1,%eax
c0101ce1:	85 c0                	test   %eax,%eax
c0101ce3:	75 0a                	jne    c0101cef <kbd_proc_data+0x2e>
        return -1;
c0101ce5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101cea:	e9 59 01 00 00       	jmp    c0101e48 <kbd_proc_data+0x187>
c0101cef:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101cf5:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101cf9:	89 c2                	mov    %eax,%edx
c0101cfb:	ec                   	in     (%dx),%al
c0101cfc:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101cff:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101d03:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101d06:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c0101d0a:	75 17                	jne    c0101d23 <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
c0101d0c:	a1 48 37 12 c0       	mov    0xc0123748,%eax
c0101d11:	83 c8 40             	or     $0x40,%eax
c0101d14:	a3 48 37 12 c0       	mov    %eax,0xc0123748
        return 0;
c0101d19:	b8 00 00 00 00       	mov    $0x0,%eax
c0101d1e:	e9 25 01 00 00       	jmp    c0101e48 <kbd_proc_data+0x187>
    } else if (data & 0x80) {
c0101d23:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d27:	84 c0                	test   %al,%al
c0101d29:	79 47                	jns    c0101d72 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c0101d2b:	a1 48 37 12 c0       	mov    0xc0123748,%eax
c0101d30:	83 e0 40             	and    $0x40,%eax
c0101d33:	85 c0                	test   %eax,%eax
c0101d35:	75 09                	jne    c0101d40 <kbd_proc_data+0x7f>
c0101d37:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d3b:	83 e0 7f             	and    $0x7f,%eax
c0101d3e:	eb 04                	jmp    c0101d44 <kbd_proc_data+0x83>
c0101d40:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d44:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c0101d47:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d4b:	0f b6 80 40 00 12 c0 	movzbl -0x3fedffc0(%eax),%eax
c0101d52:	83 c8 40             	or     $0x40,%eax
c0101d55:	0f b6 c0             	movzbl %al,%eax
c0101d58:	f7 d0                	not    %eax
c0101d5a:	89 c2                	mov    %eax,%edx
c0101d5c:	a1 48 37 12 c0       	mov    0xc0123748,%eax
c0101d61:	21 d0                	and    %edx,%eax
c0101d63:	a3 48 37 12 c0       	mov    %eax,0xc0123748
        return 0;
c0101d68:	b8 00 00 00 00       	mov    $0x0,%eax
c0101d6d:	e9 d6 00 00 00       	jmp    c0101e48 <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
c0101d72:	a1 48 37 12 c0       	mov    0xc0123748,%eax
c0101d77:	83 e0 40             	and    $0x40,%eax
c0101d7a:	85 c0                	test   %eax,%eax
c0101d7c:	74 11                	je     c0101d8f <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c0101d7e:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0101d82:	a1 48 37 12 c0       	mov    0xc0123748,%eax
c0101d87:	83 e0 bf             	and    $0xffffffbf,%eax
c0101d8a:	a3 48 37 12 c0       	mov    %eax,0xc0123748
    }

    shift |= shiftcode[data];
c0101d8f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d93:	0f b6 80 40 00 12 c0 	movzbl -0x3fedffc0(%eax),%eax
c0101d9a:	0f b6 d0             	movzbl %al,%edx
c0101d9d:	a1 48 37 12 c0       	mov    0xc0123748,%eax
c0101da2:	09 d0                	or     %edx,%eax
c0101da4:	a3 48 37 12 c0       	mov    %eax,0xc0123748
    shift ^= togglecode[data];
c0101da9:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101dad:	0f b6 80 40 01 12 c0 	movzbl -0x3fedfec0(%eax),%eax
c0101db4:	0f b6 d0             	movzbl %al,%edx
c0101db7:	a1 48 37 12 c0       	mov    0xc0123748,%eax
c0101dbc:	31 d0                	xor    %edx,%eax
c0101dbe:	a3 48 37 12 c0       	mov    %eax,0xc0123748

    c = charcode[shift & (CTL | SHIFT)][data];
c0101dc3:	a1 48 37 12 c0       	mov    0xc0123748,%eax
c0101dc8:	83 e0 03             	and    $0x3,%eax
c0101dcb:	8b 14 85 40 05 12 c0 	mov    -0x3fedfac0(,%eax,4),%edx
c0101dd2:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101dd6:	01 d0                	add    %edx,%eax
c0101dd8:	0f b6 00             	movzbl (%eax),%eax
c0101ddb:	0f b6 c0             	movzbl %al,%eax
c0101dde:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101de1:	a1 48 37 12 c0       	mov    0xc0123748,%eax
c0101de6:	83 e0 08             	and    $0x8,%eax
c0101de9:	85 c0                	test   %eax,%eax
c0101deb:	74 22                	je     c0101e0f <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c0101ded:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101df1:	7e 0c                	jle    c0101dff <kbd_proc_data+0x13e>
c0101df3:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101df7:	7f 06                	jg     c0101dff <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c0101df9:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c0101dfd:	eb 10                	jmp    c0101e0f <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c0101dff:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101e03:	7e 0a                	jle    c0101e0f <kbd_proc_data+0x14e>
c0101e05:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c0101e09:	7f 04                	jg     c0101e0f <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c0101e0b:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c0101e0f:	a1 48 37 12 c0       	mov    0xc0123748,%eax
c0101e14:	f7 d0                	not    %eax
c0101e16:	83 e0 06             	and    $0x6,%eax
c0101e19:	85 c0                	test   %eax,%eax
c0101e1b:	75 28                	jne    c0101e45 <kbd_proc_data+0x184>
c0101e1d:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101e24:	75 1f                	jne    c0101e45 <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
c0101e26:	c7 04 24 d9 90 10 c0 	movl   $0xc01090d9,(%esp)
c0101e2d:	e8 6f e4 ff ff       	call   c01002a1 <cprintf>
c0101e32:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c0101e38:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101e3c:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c0101e40:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c0101e44:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c0101e45:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101e48:	c9                   	leave  
c0101e49:	c3                   	ret    

c0101e4a <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c0101e4a:	55                   	push   %ebp
c0101e4b:	89 e5                	mov    %esp,%ebp
c0101e4d:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c0101e50:	c7 04 24 c1 1c 10 c0 	movl   $0xc0101cc1,(%esp)
c0101e57:	e8 a6 fd ff ff       	call   c0101c02 <cons_intr>
}
c0101e5c:	c9                   	leave  
c0101e5d:	c3                   	ret    

c0101e5e <kbd_init>:

static void
kbd_init(void) {
c0101e5e:	55                   	push   %ebp
c0101e5f:	89 e5                	mov    %esp,%ebp
c0101e61:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c0101e64:	e8 e1 ff ff ff       	call   c0101e4a <kbd_intr>
    pic_enable(IRQ_KBD);
c0101e69:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0101e70:	e8 31 01 00 00       	call   c0101fa6 <pic_enable>
}
c0101e75:	c9                   	leave  
c0101e76:	c3                   	ret    

c0101e77 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c0101e77:	55                   	push   %ebp
c0101e78:	89 e5                	mov    %esp,%ebp
c0101e7a:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c0101e7d:	e8 93 f8 ff ff       	call   c0101715 <cga_init>
    serial_init();
c0101e82:	e8 74 f9 ff ff       	call   c01017fb <serial_init>
    kbd_init();
c0101e87:	e8 d2 ff ff ff       	call   c0101e5e <kbd_init>
    if (!serial_exists) {
c0101e8c:	a1 28 35 12 c0       	mov    0xc0123528,%eax
c0101e91:	85 c0                	test   %eax,%eax
c0101e93:	75 0c                	jne    c0101ea1 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c0101e95:	c7 04 24 e5 90 10 c0 	movl   $0xc01090e5,(%esp)
c0101e9c:	e8 00 e4 ff ff       	call   c01002a1 <cprintf>
    }
}
c0101ea1:	c9                   	leave  
c0101ea2:	c3                   	ret    

c0101ea3 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0101ea3:	55                   	push   %ebp
c0101ea4:	89 e5                	mov    %esp,%ebp
c0101ea6:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0101ea9:	e8 e2 f7 ff ff       	call   c0101690 <__intr_save>
c0101eae:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101eb1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101eb4:	89 04 24             	mov    %eax,(%esp)
c0101eb7:	e8 9b fa ff ff       	call   c0101957 <lpt_putc>
        cga_putc(c);
c0101ebc:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ebf:	89 04 24             	mov    %eax,(%esp)
c0101ec2:	e8 cf fa ff ff       	call   c0101996 <cga_putc>
        serial_putc(c);
c0101ec7:	8b 45 08             	mov    0x8(%ebp),%eax
c0101eca:	89 04 24             	mov    %eax,(%esp)
c0101ecd:	e8 f1 fc ff ff       	call   c0101bc3 <serial_putc>
    }
    local_intr_restore(intr_flag);
c0101ed2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101ed5:	89 04 24             	mov    %eax,(%esp)
c0101ed8:	e8 dd f7 ff ff       	call   c01016ba <__intr_restore>
}
c0101edd:	c9                   	leave  
c0101ede:	c3                   	ret    

c0101edf <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0101edf:	55                   	push   %ebp
c0101ee0:	89 e5                	mov    %esp,%ebp
c0101ee2:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c0101ee5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0101eec:	e8 9f f7 ff ff       	call   c0101690 <__intr_save>
c0101ef1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101ef4:	e8 ab fd ff ff       	call   c0101ca4 <serial_intr>
        kbd_intr();
c0101ef9:	e8 4c ff ff ff       	call   c0101e4a <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0101efe:	8b 15 40 37 12 c0    	mov    0xc0123740,%edx
c0101f04:	a1 44 37 12 c0       	mov    0xc0123744,%eax
c0101f09:	39 c2                	cmp    %eax,%edx
c0101f0b:	74 31                	je     c0101f3e <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c0101f0d:	a1 40 37 12 c0       	mov    0xc0123740,%eax
c0101f12:	8d 50 01             	lea    0x1(%eax),%edx
c0101f15:	89 15 40 37 12 c0    	mov    %edx,0xc0123740
c0101f1b:	0f b6 80 40 35 12 c0 	movzbl -0x3fedcac0(%eax),%eax
c0101f22:	0f b6 c0             	movzbl %al,%eax
c0101f25:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c0101f28:	a1 40 37 12 c0       	mov    0xc0123740,%eax
c0101f2d:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101f32:	75 0a                	jne    c0101f3e <cons_getc+0x5f>
                cons.rpos = 0;
c0101f34:	c7 05 40 37 12 c0 00 	movl   $0x0,0xc0123740
c0101f3b:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c0101f3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101f41:	89 04 24             	mov    %eax,(%esp)
c0101f44:	e8 71 f7 ff ff       	call   c01016ba <__intr_restore>
    return c;
c0101f49:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101f4c:	c9                   	leave  
c0101f4d:	c3                   	ret    

c0101f4e <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c0101f4e:	55                   	push   %ebp
c0101f4f:	89 e5                	mov    %esp,%ebp
c0101f51:	83 ec 14             	sub    $0x14,%esp
c0101f54:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f57:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c0101f5b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101f5f:	66 a3 50 05 12 c0    	mov    %ax,0xc0120550
    if (did_init) {
c0101f65:	a1 4c 37 12 c0       	mov    0xc012374c,%eax
c0101f6a:	85 c0                	test   %eax,%eax
c0101f6c:	74 36                	je     c0101fa4 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c0101f6e:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101f72:	0f b6 c0             	movzbl %al,%eax
c0101f75:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0101f7b:	88 45 fd             	mov    %al,-0x3(%ebp)
c0101f7e:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101f82:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101f86:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c0101f87:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101f8b:	66 c1 e8 08          	shr    $0x8,%ax
c0101f8f:	0f b6 c0             	movzbl %al,%eax
c0101f92:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c0101f98:	88 45 f9             	mov    %al,-0x7(%ebp)
c0101f9b:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101f9f:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101fa3:	ee                   	out    %al,(%dx)
    }
}
c0101fa4:	c9                   	leave  
c0101fa5:	c3                   	ret    

c0101fa6 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0101fa6:	55                   	push   %ebp
c0101fa7:	89 e5                	mov    %esp,%ebp
c0101fa9:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c0101fac:	8b 45 08             	mov    0x8(%ebp),%eax
c0101faf:	ba 01 00 00 00       	mov    $0x1,%edx
c0101fb4:	89 c1                	mov    %eax,%ecx
c0101fb6:	d3 e2                	shl    %cl,%edx
c0101fb8:	89 d0                	mov    %edx,%eax
c0101fba:	f7 d0                	not    %eax
c0101fbc:	89 c2                	mov    %eax,%edx
c0101fbe:	0f b7 05 50 05 12 c0 	movzwl 0xc0120550,%eax
c0101fc5:	21 d0                	and    %edx,%eax
c0101fc7:	0f b7 c0             	movzwl %ax,%eax
c0101fca:	89 04 24             	mov    %eax,(%esp)
c0101fcd:	e8 7c ff ff ff       	call   c0101f4e <pic_setmask>
}
c0101fd2:	c9                   	leave  
c0101fd3:	c3                   	ret    

c0101fd4 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0101fd4:	55                   	push   %ebp
c0101fd5:	89 e5                	mov    %esp,%ebp
c0101fd7:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c0101fda:	c7 05 4c 37 12 c0 01 	movl   $0x1,0xc012374c
c0101fe1:	00 00 00 
c0101fe4:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0101fea:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
c0101fee:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101ff2:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101ff6:	ee                   	out    %al,(%dx)
c0101ff7:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c0101ffd:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
c0102001:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0102005:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0102009:	ee                   	out    %al,(%dx)
c010200a:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c0102010:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
c0102014:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0102018:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010201c:	ee                   	out    %al,(%dx)
c010201d:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
c0102023:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
c0102027:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010202b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010202f:	ee                   	out    %al,(%dx)
c0102030:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
c0102036:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
c010203a:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010203e:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0102042:	ee                   	out    %al,(%dx)
c0102043:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
c0102049:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
c010204d:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0102051:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0102055:	ee                   	out    %al,(%dx)
c0102056:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c010205c:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
c0102060:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0102064:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0102068:	ee                   	out    %al,(%dx)
c0102069:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
c010206f:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
c0102073:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0102077:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c010207b:	ee                   	out    %al,(%dx)
c010207c:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
c0102082:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
c0102086:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c010208a:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c010208e:	ee                   	out    %al,(%dx)
c010208f:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
c0102095:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
c0102099:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c010209d:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c01020a1:	ee                   	out    %al,(%dx)
c01020a2:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
c01020a8:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
c01020ac:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c01020b0:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c01020b4:	ee                   	out    %al,(%dx)
c01020b5:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c01020bb:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
c01020bf:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c01020c3:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c01020c7:	ee                   	out    %al,(%dx)
c01020c8:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
c01020ce:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
c01020d2:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c01020d6:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c01020da:	ee                   	out    %al,(%dx)
c01020db:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
c01020e1:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
c01020e5:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c01020e9:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c01020ed:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c01020ee:	0f b7 05 50 05 12 c0 	movzwl 0xc0120550,%eax
c01020f5:	66 83 f8 ff          	cmp    $0xffff,%ax
c01020f9:	74 12                	je     c010210d <pic_init+0x139>
        pic_setmask(irq_mask);
c01020fb:	0f b7 05 50 05 12 c0 	movzwl 0xc0120550,%eax
c0102102:	0f b7 c0             	movzwl %ax,%eax
c0102105:	89 04 24             	mov    %eax,(%esp)
c0102108:	e8 41 fe ff ff       	call   c0101f4e <pic_setmask>
    }
}
c010210d:	c9                   	leave  
c010210e:	c3                   	ret    

c010210f <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c010210f:	55                   	push   %ebp
c0102110:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
c0102112:	fb                   	sti    
    sti();
}
c0102113:	5d                   	pop    %ebp
c0102114:	c3                   	ret    

c0102115 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c0102115:	55                   	push   %ebp
c0102116:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
c0102118:	fa                   	cli    
    cli();
}
c0102119:	5d                   	pop    %ebp
c010211a:	c3                   	ret    

c010211b <print_ticks>:
#include <swap.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c010211b:	55                   	push   %ebp
c010211c:	89 e5                	mov    %esp,%ebp
c010211e:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c0102121:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0102128:	00 
c0102129:	c7 04 24 20 91 10 c0 	movl   $0xc0109120,(%esp)
c0102130:	e8 6c e1 ff ff       	call   c01002a1 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
c0102135:	c7 04 24 2a 91 10 c0 	movl   $0xc010912a,(%esp)
c010213c:	e8 60 e1 ff ff       	call   c01002a1 <cprintf>
    panic("EOT: kernel seems ok.");
c0102141:	c7 44 24 08 38 91 10 	movl   $0xc0109138,0x8(%esp)
c0102148:	c0 
c0102149:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c0102150:	00 
c0102151:	c7 04 24 4e 91 10 c0 	movl   $0xc010914e,(%esp)
c0102158:	e8 9b e2 ff ff       	call   c01003f8 <__panic>

c010215d <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c010215d:	55                   	push   %ebp
c010215e:	89 e5                	mov    %esp,%ebp
c0102160:	83 ec 10             	sub    $0x10,%esp
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];  //保存在vectors.S中的256个中断处理例程的入口地址数组
    int i;
    //使用SETGATE宏，初始化IDT每个表项
    for (i = 0; i < 256; i ++) 
c0102163:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010216a:	e9 c3 00 00 00       	jmp    c0102232 <idt_init+0xd5>
    { 
    //在中断门描述符表中通过建立中断门描述符，其中存储了中断处理例程的代码段GD_KTEXT和偏移量__vectors[i]
    //特权级为DPL_KERNEL, 通过查询idt[i]就可定位到中断服务例程的起始地址。
     SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c010216f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102172:	8b 04 85 e0 05 12 c0 	mov    -0x3fedfa20(,%eax,4),%eax
c0102179:	89 c2                	mov    %eax,%edx
c010217b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010217e:	66 89 14 c5 60 37 12 	mov    %dx,-0x3fedc8a0(,%eax,8)
c0102185:	c0 
c0102186:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102189:	66 c7 04 c5 62 37 12 	movw   $0x8,-0x3fedc89e(,%eax,8)
c0102190:	c0 08 00 
c0102193:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102196:	0f b6 14 c5 64 37 12 	movzbl -0x3fedc89c(,%eax,8),%edx
c010219d:	c0 
c010219e:	83 e2 e0             	and    $0xffffffe0,%edx
c01021a1:	88 14 c5 64 37 12 c0 	mov    %dl,-0x3fedc89c(,%eax,8)
c01021a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021ab:	0f b6 14 c5 64 37 12 	movzbl -0x3fedc89c(,%eax,8),%edx
c01021b2:	c0 
c01021b3:	83 e2 1f             	and    $0x1f,%edx
c01021b6:	88 14 c5 64 37 12 c0 	mov    %dl,-0x3fedc89c(,%eax,8)
c01021bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021c0:	0f b6 14 c5 65 37 12 	movzbl -0x3fedc89b(,%eax,8),%edx
c01021c7:	c0 
c01021c8:	83 e2 f0             	and    $0xfffffff0,%edx
c01021cb:	83 ca 0e             	or     $0xe,%edx
c01021ce:	88 14 c5 65 37 12 c0 	mov    %dl,-0x3fedc89b(,%eax,8)
c01021d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021d8:	0f b6 14 c5 65 37 12 	movzbl -0x3fedc89b(,%eax,8),%edx
c01021df:	c0 
c01021e0:	83 e2 ef             	and    $0xffffffef,%edx
c01021e3:	88 14 c5 65 37 12 c0 	mov    %dl,-0x3fedc89b(,%eax,8)
c01021ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021ed:	0f b6 14 c5 65 37 12 	movzbl -0x3fedc89b(,%eax,8),%edx
c01021f4:	c0 
c01021f5:	83 e2 9f             	and    $0xffffff9f,%edx
c01021f8:	88 14 c5 65 37 12 c0 	mov    %dl,-0x3fedc89b(,%eax,8)
c01021ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102202:	0f b6 14 c5 65 37 12 	movzbl -0x3fedc89b(,%eax,8),%edx
c0102209:	c0 
c010220a:	83 ca 80             	or     $0xffffff80,%edx
c010220d:	88 14 c5 65 37 12 c0 	mov    %dl,-0x3fedc89b(,%eax,8)
c0102214:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102217:	8b 04 85 e0 05 12 c0 	mov    -0x3fedfa20(,%eax,4),%eax
c010221e:	c1 e8 10             	shr    $0x10,%eax
c0102221:	89 c2                	mov    %eax,%edx
c0102223:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102226:	66 89 14 c5 66 37 12 	mov    %dx,-0x3fedc89a(,%eax,8)
c010222d:	c0 
    for (i = 0; i < 256; i ++) 
c010222e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0102232:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
c0102239:	0f 8e 30 ff ff ff    	jle    c010216f <idt_init+0x12>
    }
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT,__vectors[T_SWITCH_TOK], DPL_USER);
c010223f:	a1 c4 07 12 c0       	mov    0xc01207c4,%eax
c0102244:	66 a3 28 3b 12 c0    	mov    %ax,0xc0123b28
c010224a:	66 c7 05 2a 3b 12 c0 	movw   $0x8,0xc0123b2a
c0102251:	08 00 
c0102253:	0f b6 05 2c 3b 12 c0 	movzbl 0xc0123b2c,%eax
c010225a:	83 e0 e0             	and    $0xffffffe0,%eax
c010225d:	a2 2c 3b 12 c0       	mov    %al,0xc0123b2c
c0102262:	0f b6 05 2c 3b 12 c0 	movzbl 0xc0123b2c,%eax
c0102269:	83 e0 1f             	and    $0x1f,%eax
c010226c:	a2 2c 3b 12 c0       	mov    %al,0xc0123b2c
c0102271:	0f b6 05 2d 3b 12 c0 	movzbl 0xc0123b2d,%eax
c0102278:	83 e0 f0             	and    $0xfffffff0,%eax
c010227b:	83 c8 0e             	or     $0xe,%eax
c010227e:	a2 2d 3b 12 c0       	mov    %al,0xc0123b2d
c0102283:	0f b6 05 2d 3b 12 c0 	movzbl 0xc0123b2d,%eax
c010228a:	83 e0 ef             	and    $0xffffffef,%eax
c010228d:	a2 2d 3b 12 c0       	mov    %al,0xc0123b2d
c0102292:	0f b6 05 2d 3b 12 c0 	movzbl 0xc0123b2d,%eax
c0102299:	83 c8 60             	or     $0x60,%eax
c010229c:	a2 2d 3b 12 c0       	mov    %al,0xc0123b2d
c01022a1:	0f b6 05 2d 3b 12 c0 	movzbl 0xc0123b2d,%eax
c01022a8:	83 c8 80             	or     $0xffffff80,%eax
c01022ab:	a2 2d 3b 12 c0       	mov    %al,0xc0123b2d
c01022b0:	a1 c4 07 12 c0       	mov    0xc01207c4,%eax
c01022b5:	c1 e8 10             	shr    $0x10,%eax
c01022b8:	66 a3 2e 3b 12 c0    	mov    %ax,0xc0123b2e
c01022be:	c7 45 f8 60 05 12 c0 	movl   $0xc0120560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c01022c5:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01022c8:	0f 01 18             	lidtl  (%eax)
     //指令lidt把中断门描述符表的起始地址装入IDTR寄存器
    lidt(&idt_pd);
}
c01022cb:	c9                   	leave  
c01022cc:	c3                   	ret    

c01022cd <trapname>:

static const char *
trapname(int trapno) {
c01022cd:	55                   	push   %ebp
c01022ce:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c01022d0:	8b 45 08             	mov    0x8(%ebp),%eax
c01022d3:	83 f8 13             	cmp    $0x13,%eax
c01022d6:	77 0c                	ja     c01022e4 <trapname+0x17>
        return excnames[trapno];
c01022d8:	8b 45 08             	mov    0x8(%ebp),%eax
c01022db:	8b 04 85 20 95 10 c0 	mov    -0x3fef6ae0(,%eax,4),%eax
c01022e2:	eb 18                	jmp    c01022fc <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c01022e4:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c01022e8:	7e 0d                	jle    c01022f7 <trapname+0x2a>
c01022ea:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c01022ee:	7f 07                	jg     c01022f7 <trapname+0x2a>
        return "Hardware Interrupt";
c01022f0:	b8 5f 91 10 c0       	mov    $0xc010915f,%eax
c01022f5:	eb 05                	jmp    c01022fc <trapname+0x2f>
    }
    return "(unknown trap)";
c01022f7:	b8 72 91 10 c0       	mov    $0xc0109172,%eax
}
c01022fc:	5d                   	pop    %ebp
c01022fd:	c3                   	ret    

c01022fe <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c01022fe:	55                   	push   %ebp
c01022ff:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c0102301:	8b 45 08             	mov    0x8(%ebp),%eax
c0102304:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102308:	66 83 f8 08          	cmp    $0x8,%ax
c010230c:	0f 94 c0             	sete   %al
c010230f:	0f b6 c0             	movzbl %al,%eax
}
c0102312:	5d                   	pop    %ebp
c0102313:	c3                   	ret    

c0102314 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0102314:	55                   	push   %ebp
c0102315:	89 e5                	mov    %esp,%ebp
c0102317:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c010231a:	8b 45 08             	mov    0x8(%ebp),%eax
c010231d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102321:	c7 04 24 b3 91 10 c0 	movl   $0xc01091b3,(%esp)
c0102328:	e8 74 df ff ff       	call   c01002a1 <cprintf>
    print_regs(&tf->tf_regs);
c010232d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102330:	89 04 24             	mov    %eax,(%esp)
c0102333:	e8 a1 01 00 00       	call   c01024d9 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0102338:	8b 45 08             	mov    0x8(%ebp),%eax
c010233b:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c010233f:	0f b7 c0             	movzwl %ax,%eax
c0102342:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102346:	c7 04 24 c4 91 10 c0 	movl   $0xc01091c4,(%esp)
c010234d:	e8 4f df ff ff       	call   c01002a1 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0102352:	8b 45 08             	mov    0x8(%ebp),%eax
c0102355:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0102359:	0f b7 c0             	movzwl %ax,%eax
c010235c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102360:	c7 04 24 d7 91 10 c0 	movl   $0xc01091d7,(%esp)
c0102367:	e8 35 df ff ff       	call   c01002a1 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c010236c:	8b 45 08             	mov    0x8(%ebp),%eax
c010236f:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0102373:	0f b7 c0             	movzwl %ax,%eax
c0102376:	89 44 24 04          	mov    %eax,0x4(%esp)
c010237a:	c7 04 24 ea 91 10 c0 	movl   $0xc01091ea,(%esp)
c0102381:	e8 1b df ff ff       	call   c01002a1 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0102386:	8b 45 08             	mov    0x8(%ebp),%eax
c0102389:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c010238d:	0f b7 c0             	movzwl %ax,%eax
c0102390:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102394:	c7 04 24 fd 91 10 c0 	movl   $0xc01091fd,(%esp)
c010239b:	e8 01 df ff ff       	call   c01002a1 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c01023a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01023a3:	8b 40 30             	mov    0x30(%eax),%eax
c01023a6:	89 04 24             	mov    %eax,(%esp)
c01023a9:	e8 1f ff ff ff       	call   c01022cd <trapname>
c01023ae:	8b 55 08             	mov    0x8(%ebp),%edx
c01023b1:	8b 52 30             	mov    0x30(%edx),%edx
c01023b4:	89 44 24 08          	mov    %eax,0x8(%esp)
c01023b8:	89 54 24 04          	mov    %edx,0x4(%esp)
c01023bc:	c7 04 24 10 92 10 c0 	movl   $0xc0109210,(%esp)
c01023c3:	e8 d9 de ff ff       	call   c01002a1 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c01023c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01023cb:	8b 40 34             	mov    0x34(%eax),%eax
c01023ce:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023d2:	c7 04 24 22 92 10 c0 	movl   $0xc0109222,(%esp)
c01023d9:	e8 c3 de ff ff       	call   c01002a1 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c01023de:	8b 45 08             	mov    0x8(%ebp),%eax
c01023e1:	8b 40 38             	mov    0x38(%eax),%eax
c01023e4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023e8:	c7 04 24 31 92 10 c0 	movl   $0xc0109231,(%esp)
c01023ef:	e8 ad de ff ff       	call   c01002a1 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c01023f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01023f7:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01023fb:	0f b7 c0             	movzwl %ax,%eax
c01023fe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102402:	c7 04 24 40 92 10 c0 	movl   $0xc0109240,(%esp)
c0102409:	e8 93 de ff ff       	call   c01002a1 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c010240e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102411:	8b 40 40             	mov    0x40(%eax),%eax
c0102414:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102418:	c7 04 24 53 92 10 c0 	movl   $0xc0109253,(%esp)
c010241f:	e8 7d de ff ff       	call   c01002a1 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0102424:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010242b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0102432:	eb 3e                	jmp    c0102472 <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0102434:	8b 45 08             	mov    0x8(%ebp),%eax
c0102437:	8b 50 40             	mov    0x40(%eax),%edx
c010243a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010243d:	21 d0                	and    %edx,%eax
c010243f:	85 c0                	test   %eax,%eax
c0102441:	74 28                	je     c010246b <print_trapframe+0x157>
c0102443:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102446:	8b 04 85 80 05 12 c0 	mov    -0x3fedfa80(,%eax,4),%eax
c010244d:	85 c0                	test   %eax,%eax
c010244f:	74 1a                	je     c010246b <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
c0102451:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102454:	8b 04 85 80 05 12 c0 	mov    -0x3fedfa80(,%eax,4),%eax
c010245b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010245f:	c7 04 24 62 92 10 c0 	movl   $0xc0109262,(%esp)
c0102466:	e8 36 de ff ff       	call   c01002a1 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c010246b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010246f:	d1 65 f0             	shll   -0x10(%ebp)
c0102472:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102475:	83 f8 17             	cmp    $0x17,%eax
c0102478:	76 ba                	jbe    c0102434 <print_trapframe+0x120>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c010247a:	8b 45 08             	mov    0x8(%ebp),%eax
c010247d:	8b 40 40             	mov    0x40(%eax),%eax
c0102480:	25 00 30 00 00       	and    $0x3000,%eax
c0102485:	c1 e8 0c             	shr    $0xc,%eax
c0102488:	89 44 24 04          	mov    %eax,0x4(%esp)
c010248c:	c7 04 24 66 92 10 c0 	movl   $0xc0109266,(%esp)
c0102493:	e8 09 de ff ff       	call   c01002a1 <cprintf>

    if (!trap_in_kernel(tf)) {
c0102498:	8b 45 08             	mov    0x8(%ebp),%eax
c010249b:	89 04 24             	mov    %eax,(%esp)
c010249e:	e8 5b fe ff ff       	call   c01022fe <trap_in_kernel>
c01024a3:	85 c0                	test   %eax,%eax
c01024a5:	75 30                	jne    c01024d7 <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c01024a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01024aa:	8b 40 44             	mov    0x44(%eax),%eax
c01024ad:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024b1:	c7 04 24 6f 92 10 c0 	movl   $0xc010926f,(%esp)
c01024b8:	e8 e4 dd ff ff       	call   c01002a1 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c01024bd:	8b 45 08             	mov    0x8(%ebp),%eax
c01024c0:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c01024c4:	0f b7 c0             	movzwl %ax,%eax
c01024c7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024cb:	c7 04 24 7e 92 10 c0 	movl   $0xc010927e,(%esp)
c01024d2:	e8 ca dd ff ff       	call   c01002a1 <cprintf>
    }
}
c01024d7:	c9                   	leave  
c01024d8:	c3                   	ret    

c01024d9 <print_regs>:

void
print_regs(struct pushregs *regs) {
c01024d9:	55                   	push   %ebp
c01024da:	89 e5                	mov    %esp,%ebp
c01024dc:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c01024df:	8b 45 08             	mov    0x8(%ebp),%eax
c01024e2:	8b 00                	mov    (%eax),%eax
c01024e4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024e8:	c7 04 24 91 92 10 c0 	movl   $0xc0109291,(%esp)
c01024ef:	e8 ad dd ff ff       	call   c01002a1 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c01024f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01024f7:	8b 40 04             	mov    0x4(%eax),%eax
c01024fa:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024fe:	c7 04 24 a0 92 10 c0 	movl   $0xc01092a0,(%esp)
c0102505:	e8 97 dd ff ff       	call   c01002a1 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c010250a:	8b 45 08             	mov    0x8(%ebp),%eax
c010250d:	8b 40 08             	mov    0x8(%eax),%eax
c0102510:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102514:	c7 04 24 af 92 10 c0 	movl   $0xc01092af,(%esp)
c010251b:	e8 81 dd ff ff       	call   c01002a1 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0102520:	8b 45 08             	mov    0x8(%ebp),%eax
c0102523:	8b 40 0c             	mov    0xc(%eax),%eax
c0102526:	89 44 24 04          	mov    %eax,0x4(%esp)
c010252a:	c7 04 24 be 92 10 c0 	movl   $0xc01092be,(%esp)
c0102531:	e8 6b dd ff ff       	call   c01002a1 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0102536:	8b 45 08             	mov    0x8(%ebp),%eax
c0102539:	8b 40 10             	mov    0x10(%eax),%eax
c010253c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102540:	c7 04 24 cd 92 10 c0 	movl   $0xc01092cd,(%esp)
c0102547:	e8 55 dd ff ff       	call   c01002a1 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c010254c:	8b 45 08             	mov    0x8(%ebp),%eax
c010254f:	8b 40 14             	mov    0x14(%eax),%eax
c0102552:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102556:	c7 04 24 dc 92 10 c0 	movl   $0xc01092dc,(%esp)
c010255d:	e8 3f dd ff ff       	call   c01002a1 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0102562:	8b 45 08             	mov    0x8(%ebp),%eax
c0102565:	8b 40 18             	mov    0x18(%eax),%eax
c0102568:	89 44 24 04          	mov    %eax,0x4(%esp)
c010256c:	c7 04 24 eb 92 10 c0 	movl   $0xc01092eb,(%esp)
c0102573:	e8 29 dd ff ff       	call   c01002a1 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0102578:	8b 45 08             	mov    0x8(%ebp),%eax
c010257b:	8b 40 1c             	mov    0x1c(%eax),%eax
c010257e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102582:	c7 04 24 fa 92 10 c0 	movl   $0xc01092fa,(%esp)
c0102589:	e8 13 dd ff ff       	call   c01002a1 <cprintf>
}
c010258e:	c9                   	leave  
c010258f:	c3                   	ret    

c0102590 <print_pgfault>:

static inline void
print_pgfault(struct trapframe *tf) {
c0102590:	55                   	push   %ebp
c0102591:	89 e5                	mov    %esp,%ebp
c0102593:	53                   	push   %ebx
c0102594:	83 ec 34             	sub    $0x34,%esp
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
c0102597:	8b 45 08             	mov    0x8(%ebp),%eax
c010259a:	8b 40 34             	mov    0x34(%eax),%eax
c010259d:	83 e0 01             	and    $0x1,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c01025a0:	85 c0                	test   %eax,%eax
c01025a2:	74 07                	je     c01025ab <print_pgfault+0x1b>
c01025a4:	b9 09 93 10 c0       	mov    $0xc0109309,%ecx
c01025a9:	eb 05                	jmp    c01025b0 <print_pgfault+0x20>
c01025ab:	b9 1a 93 10 c0       	mov    $0xc010931a,%ecx
            (tf->tf_err & 2) ? 'W' : 'R',
c01025b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01025b3:	8b 40 34             	mov    0x34(%eax),%eax
c01025b6:	83 e0 02             	and    $0x2,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c01025b9:	85 c0                	test   %eax,%eax
c01025bb:	74 07                	je     c01025c4 <print_pgfault+0x34>
c01025bd:	ba 57 00 00 00       	mov    $0x57,%edx
c01025c2:	eb 05                	jmp    c01025c9 <print_pgfault+0x39>
c01025c4:	ba 52 00 00 00       	mov    $0x52,%edx
            (tf->tf_err & 4) ? 'U' : 'K',
c01025c9:	8b 45 08             	mov    0x8(%ebp),%eax
c01025cc:	8b 40 34             	mov    0x34(%eax),%eax
c01025cf:	83 e0 04             	and    $0x4,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c01025d2:	85 c0                	test   %eax,%eax
c01025d4:	74 07                	je     c01025dd <print_pgfault+0x4d>
c01025d6:	b8 55 00 00 00       	mov    $0x55,%eax
c01025db:	eb 05                	jmp    c01025e2 <print_pgfault+0x52>
c01025dd:	b8 4b 00 00 00       	mov    $0x4b,%eax
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c01025e2:	0f 20 d3             	mov    %cr2,%ebx
c01025e5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
    return cr2;
c01025e8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
c01025eb:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c01025ef:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01025f3:	89 44 24 08          	mov    %eax,0x8(%esp)
c01025f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01025fb:	c7 04 24 28 93 10 c0 	movl   $0xc0109328,(%esp)
c0102602:	e8 9a dc ff ff       	call   c01002a1 <cprintf>
}
c0102607:	83 c4 34             	add    $0x34,%esp
c010260a:	5b                   	pop    %ebx
c010260b:	5d                   	pop    %ebp
c010260c:	c3                   	ret    

c010260d <pgfault_handler>:

static int
pgfault_handler(struct trapframe *tf) {
c010260d:	55                   	push   %ebp
c010260e:	89 e5                	mov    %esp,%ebp
c0102610:	83 ec 28             	sub    $0x28,%esp
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
c0102613:	8b 45 08             	mov    0x8(%ebp),%eax
c0102616:	89 04 24             	mov    %eax,(%esp)
c0102619:	e8 72 ff ff ff       	call   c0102590 <print_pgfault>
    if (check_mm_struct != NULL) {
c010261e:	a1 10 40 12 c0       	mov    0xc0124010,%eax
c0102623:	85 c0                	test   %eax,%eax
c0102625:	74 28                	je     c010264f <pgfault_handler+0x42>
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c0102627:	0f 20 d0             	mov    %cr2,%eax
c010262a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c010262d:	8b 45 f4             	mov    -0xc(%ebp),%eax
        return do_pgfault(check_mm_struct, tf->tf_err, rcr2());
c0102630:	89 c1                	mov    %eax,%ecx
c0102632:	8b 45 08             	mov    0x8(%ebp),%eax
c0102635:	8b 50 34             	mov    0x34(%eax),%edx
c0102638:	a1 10 40 12 c0       	mov    0xc0124010,%eax
c010263d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0102641:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102645:	89 04 24             	mov    %eax,(%esp)
c0102648:	e8 c9 17 00 00       	call   c0103e16 <do_pgfault>
c010264d:	eb 1c                	jmp    c010266b <pgfault_handler+0x5e>
    }
    panic("unhandled page fault.\n");
c010264f:	c7 44 24 08 4b 93 10 	movl   $0xc010934b,0x8(%esp)
c0102656:	c0 
c0102657:	c7 44 24 04 ab 00 00 	movl   $0xab,0x4(%esp)
c010265e:	00 
c010265f:	c7 04 24 4e 91 10 c0 	movl   $0xc010914e,(%esp)
c0102666:	e8 8d dd ff ff       	call   c01003f8 <__panic>
}
c010266b:	c9                   	leave  
c010266c:	c3                   	ret    

c010266d <trap_dispatch>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

static void
trap_dispatch(struct trapframe *tf) {
c010266d:	55                   	push   %ebp
c010266e:	89 e5                	mov    %esp,%ebp
c0102670:	83 ec 28             	sub    $0x28,%esp
    char c;

    int ret;

    switch (tf->tf_trapno) {
c0102673:	8b 45 08             	mov    0x8(%ebp),%eax
c0102676:	8b 40 30             	mov    0x30(%eax),%eax
c0102679:	83 f8 24             	cmp    $0x24,%eax
c010267c:	0f 84 c9 00 00 00    	je     c010274b <trap_dispatch+0xde>
c0102682:	83 f8 24             	cmp    $0x24,%eax
c0102685:	77 18                	ja     c010269f <trap_dispatch+0x32>
c0102687:	83 f8 20             	cmp    $0x20,%eax
c010268a:	74 7d                	je     c0102709 <trap_dispatch+0x9c>
c010268c:	83 f8 21             	cmp    $0x21,%eax
c010268f:	0f 84 dc 00 00 00    	je     c0102771 <trap_dispatch+0x104>
c0102695:	83 f8 0e             	cmp    $0xe,%eax
c0102698:	74 28                	je     c01026c2 <trap_dispatch+0x55>
c010269a:	e9 14 01 00 00       	jmp    c01027b3 <trap_dispatch+0x146>
c010269f:	83 f8 2e             	cmp    $0x2e,%eax
c01026a2:	0f 82 0b 01 00 00    	jb     c01027b3 <trap_dispatch+0x146>
c01026a8:	83 f8 2f             	cmp    $0x2f,%eax
c01026ab:	0f 86 3a 01 00 00    	jbe    c01027eb <trap_dispatch+0x17e>
c01026b1:	83 e8 78             	sub    $0x78,%eax
c01026b4:	83 f8 01             	cmp    $0x1,%eax
c01026b7:	0f 87 f6 00 00 00    	ja     c01027b3 <trap_dispatch+0x146>
c01026bd:	e9 d5 00 00 00       	jmp    c0102797 <trap_dispatch+0x12a>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
c01026c2:	8b 45 08             	mov    0x8(%ebp),%eax
c01026c5:	89 04 24             	mov    %eax,(%esp)
c01026c8:	e8 40 ff ff ff       	call   c010260d <pgfault_handler>
c01026cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01026d0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01026d4:	74 2e                	je     c0102704 <trap_dispatch+0x97>
            print_trapframe(tf);
c01026d6:	8b 45 08             	mov    0x8(%ebp),%eax
c01026d9:	89 04 24             	mov    %eax,(%esp)
c01026dc:	e8 33 fc ff ff       	call   c0102314 <print_trapframe>
            panic("handle pgfault failed. %e\n", ret);
c01026e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01026e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01026e8:	c7 44 24 08 62 93 10 	movl   $0xc0109362,0x8(%esp)
c01026ef:	c0 
c01026f0:	c7 44 24 04 bb 00 00 	movl   $0xbb,0x4(%esp)
c01026f7:	00 
c01026f8:	c7 04 24 4e 91 10 c0 	movl   $0xc010914e,(%esp)
c01026ff:	e8 f4 dc ff ff       	call   c01003f8 <__panic>
        }
        break;
c0102704:	e9 e3 00 00 00       	jmp    c01027ec <trap_dispatch+0x17f>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
	    if (((++ticks) % TICK_NUM) == 0) {
c0102709:	a1 0c 40 12 c0       	mov    0xc012400c,%eax
c010270e:	83 c0 01             	add    $0x1,%eax
c0102711:	89 c1                	mov    %eax,%ecx
c0102713:	89 0d 0c 40 12 c0    	mov    %ecx,0xc012400c
c0102719:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c010271e:	89 c8                	mov    %ecx,%eax
c0102720:	f7 e2                	mul    %edx
c0102722:	89 d0                	mov    %edx,%eax
c0102724:	c1 e8 05             	shr    $0x5,%eax
c0102727:	6b c0 64             	imul   $0x64,%eax,%eax
c010272a:	29 c1                	sub    %eax,%ecx
c010272c:	89 c8                	mov    %ecx,%eax
c010272e:	85 c0                	test   %eax,%eax
c0102730:	75 14                	jne    c0102746 <trap_dispatch+0xd9>
		print_ticks();
c0102732:	e8 e4 f9 ff ff       	call   c010211b <print_ticks>
		ticks = 0;
c0102737:	c7 05 0c 40 12 c0 00 	movl   $0x0,0xc012400c
c010273e:	00 00 00 
        }
        break;
c0102741:	e9 a6 00 00 00       	jmp    c01027ec <trap_dispatch+0x17f>
c0102746:	e9 a1 00 00 00       	jmp    c01027ec <trap_dispatch+0x17f>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c010274b:	e8 8f f7 ff ff       	call   c0101edf <cons_getc>
c0102750:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0102753:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c0102757:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c010275b:	89 54 24 08          	mov    %edx,0x8(%esp)
c010275f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102763:	c7 04 24 7d 93 10 c0 	movl   $0xc010937d,(%esp)
c010276a:	e8 32 db ff ff       	call   c01002a1 <cprintf>
        break;
c010276f:	eb 7b                	jmp    c01027ec <trap_dispatch+0x17f>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0102771:	e8 69 f7 ff ff       	call   c0101edf <cons_getc>
c0102776:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0102779:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c010277d:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c0102781:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102785:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102789:	c7 04 24 8f 93 10 c0 	movl   $0xc010938f,(%esp)
c0102790:	e8 0c db ff ff       	call   c01002a1 <cprintf>
        break;
c0102795:	eb 55                	jmp    c01027ec <trap_dispatch+0x17f>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0102797:	c7 44 24 08 9e 93 10 	movl   $0xc010939e,0x8(%esp)
c010279e:	c0 
c010279f:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c01027a6:	00 
c01027a7:	c7 04 24 4e 91 10 c0 	movl   $0xc010914e,(%esp)
c01027ae:	e8 45 dc ff ff       	call   c01003f8 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c01027b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01027b6:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01027ba:	0f b7 c0             	movzwl %ax,%eax
c01027bd:	83 e0 03             	and    $0x3,%eax
c01027c0:	85 c0                	test   %eax,%eax
c01027c2:	75 28                	jne    c01027ec <trap_dispatch+0x17f>
            print_trapframe(tf);
c01027c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01027c7:	89 04 24             	mov    %eax,(%esp)
c01027ca:	e8 45 fb ff ff       	call   c0102314 <print_trapframe>
            panic("unexpected trap in kernel.\n");
c01027cf:	c7 44 24 08 ae 93 10 	movl   $0xc01093ae,0x8(%esp)
c01027d6:	c0 
c01027d7:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c01027de:	00 
c01027df:	c7 04 24 4e 91 10 c0 	movl   $0xc010914e,(%esp)
c01027e6:	e8 0d dc ff ff       	call   c01003f8 <__panic>
        break;
c01027eb:	90                   	nop
        }
    }
}
c01027ec:	c9                   	leave  
c01027ed:	c3                   	ret    

c01027ee <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c01027ee:	55                   	push   %ebp
c01027ef:	89 e5                	mov    %esp,%ebp
c01027f1:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c01027f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01027f7:	89 04 24             	mov    %eax,(%esp)
c01027fa:	e8 6e fe ff ff       	call   c010266d <trap_dispatch>
}
c01027ff:	c9                   	leave  
c0102800:	c3                   	ret    

c0102801 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0102801:	6a 00                	push   $0x0
  pushl $0
c0102803:	6a 00                	push   $0x0
  jmp __alltraps
c0102805:	e9 69 0a 00 00       	jmp    c0103273 <__alltraps>

c010280a <vector1>:
.globl vector1
vector1:
  pushl $0
c010280a:	6a 00                	push   $0x0
  pushl $1
c010280c:	6a 01                	push   $0x1
  jmp __alltraps
c010280e:	e9 60 0a 00 00       	jmp    c0103273 <__alltraps>

c0102813 <vector2>:
.globl vector2
vector2:
  pushl $0
c0102813:	6a 00                	push   $0x0
  pushl $2
c0102815:	6a 02                	push   $0x2
  jmp __alltraps
c0102817:	e9 57 0a 00 00       	jmp    c0103273 <__alltraps>

c010281c <vector3>:
.globl vector3
vector3:
  pushl $0
c010281c:	6a 00                	push   $0x0
  pushl $3
c010281e:	6a 03                	push   $0x3
  jmp __alltraps
c0102820:	e9 4e 0a 00 00       	jmp    c0103273 <__alltraps>

c0102825 <vector4>:
.globl vector4
vector4:
  pushl $0
c0102825:	6a 00                	push   $0x0
  pushl $4
c0102827:	6a 04                	push   $0x4
  jmp __alltraps
c0102829:	e9 45 0a 00 00       	jmp    c0103273 <__alltraps>

c010282e <vector5>:
.globl vector5
vector5:
  pushl $0
c010282e:	6a 00                	push   $0x0
  pushl $5
c0102830:	6a 05                	push   $0x5
  jmp __alltraps
c0102832:	e9 3c 0a 00 00       	jmp    c0103273 <__alltraps>

c0102837 <vector6>:
.globl vector6
vector6:
  pushl $0
c0102837:	6a 00                	push   $0x0
  pushl $6
c0102839:	6a 06                	push   $0x6
  jmp __alltraps
c010283b:	e9 33 0a 00 00       	jmp    c0103273 <__alltraps>

c0102840 <vector7>:
.globl vector7
vector7:
  pushl $0
c0102840:	6a 00                	push   $0x0
  pushl $7
c0102842:	6a 07                	push   $0x7
  jmp __alltraps
c0102844:	e9 2a 0a 00 00       	jmp    c0103273 <__alltraps>

c0102849 <vector8>:
.globl vector8
vector8:
  pushl $8
c0102849:	6a 08                	push   $0x8
  jmp __alltraps
c010284b:	e9 23 0a 00 00       	jmp    c0103273 <__alltraps>

c0102850 <vector9>:
.globl vector9
vector9:
  pushl $0
c0102850:	6a 00                	push   $0x0
  pushl $9
c0102852:	6a 09                	push   $0x9
  jmp __alltraps
c0102854:	e9 1a 0a 00 00       	jmp    c0103273 <__alltraps>

c0102859 <vector10>:
.globl vector10
vector10:
  pushl $10
c0102859:	6a 0a                	push   $0xa
  jmp __alltraps
c010285b:	e9 13 0a 00 00       	jmp    c0103273 <__alltraps>

c0102860 <vector11>:
.globl vector11
vector11:
  pushl $11
c0102860:	6a 0b                	push   $0xb
  jmp __alltraps
c0102862:	e9 0c 0a 00 00       	jmp    c0103273 <__alltraps>

c0102867 <vector12>:
.globl vector12
vector12:
  pushl $12
c0102867:	6a 0c                	push   $0xc
  jmp __alltraps
c0102869:	e9 05 0a 00 00       	jmp    c0103273 <__alltraps>

c010286e <vector13>:
.globl vector13
vector13:
  pushl $13
c010286e:	6a 0d                	push   $0xd
  jmp __alltraps
c0102870:	e9 fe 09 00 00       	jmp    c0103273 <__alltraps>

c0102875 <vector14>:
.globl vector14
vector14:
  pushl $14
c0102875:	6a 0e                	push   $0xe
  jmp __alltraps
c0102877:	e9 f7 09 00 00       	jmp    c0103273 <__alltraps>

c010287c <vector15>:
.globl vector15
vector15:
  pushl $0
c010287c:	6a 00                	push   $0x0
  pushl $15
c010287e:	6a 0f                	push   $0xf
  jmp __alltraps
c0102880:	e9 ee 09 00 00       	jmp    c0103273 <__alltraps>

c0102885 <vector16>:
.globl vector16
vector16:
  pushl $0
c0102885:	6a 00                	push   $0x0
  pushl $16
c0102887:	6a 10                	push   $0x10
  jmp __alltraps
c0102889:	e9 e5 09 00 00       	jmp    c0103273 <__alltraps>

c010288e <vector17>:
.globl vector17
vector17:
  pushl $17
c010288e:	6a 11                	push   $0x11
  jmp __alltraps
c0102890:	e9 de 09 00 00       	jmp    c0103273 <__alltraps>

c0102895 <vector18>:
.globl vector18
vector18:
  pushl $0
c0102895:	6a 00                	push   $0x0
  pushl $18
c0102897:	6a 12                	push   $0x12
  jmp __alltraps
c0102899:	e9 d5 09 00 00       	jmp    c0103273 <__alltraps>

c010289e <vector19>:
.globl vector19
vector19:
  pushl $0
c010289e:	6a 00                	push   $0x0
  pushl $19
c01028a0:	6a 13                	push   $0x13
  jmp __alltraps
c01028a2:	e9 cc 09 00 00       	jmp    c0103273 <__alltraps>

c01028a7 <vector20>:
.globl vector20
vector20:
  pushl $0
c01028a7:	6a 00                	push   $0x0
  pushl $20
c01028a9:	6a 14                	push   $0x14
  jmp __alltraps
c01028ab:	e9 c3 09 00 00       	jmp    c0103273 <__alltraps>

c01028b0 <vector21>:
.globl vector21
vector21:
  pushl $0
c01028b0:	6a 00                	push   $0x0
  pushl $21
c01028b2:	6a 15                	push   $0x15
  jmp __alltraps
c01028b4:	e9 ba 09 00 00       	jmp    c0103273 <__alltraps>

c01028b9 <vector22>:
.globl vector22
vector22:
  pushl $0
c01028b9:	6a 00                	push   $0x0
  pushl $22
c01028bb:	6a 16                	push   $0x16
  jmp __alltraps
c01028bd:	e9 b1 09 00 00       	jmp    c0103273 <__alltraps>

c01028c2 <vector23>:
.globl vector23
vector23:
  pushl $0
c01028c2:	6a 00                	push   $0x0
  pushl $23
c01028c4:	6a 17                	push   $0x17
  jmp __alltraps
c01028c6:	e9 a8 09 00 00       	jmp    c0103273 <__alltraps>

c01028cb <vector24>:
.globl vector24
vector24:
  pushl $0
c01028cb:	6a 00                	push   $0x0
  pushl $24
c01028cd:	6a 18                	push   $0x18
  jmp __alltraps
c01028cf:	e9 9f 09 00 00       	jmp    c0103273 <__alltraps>

c01028d4 <vector25>:
.globl vector25
vector25:
  pushl $0
c01028d4:	6a 00                	push   $0x0
  pushl $25
c01028d6:	6a 19                	push   $0x19
  jmp __alltraps
c01028d8:	e9 96 09 00 00       	jmp    c0103273 <__alltraps>

c01028dd <vector26>:
.globl vector26
vector26:
  pushl $0
c01028dd:	6a 00                	push   $0x0
  pushl $26
c01028df:	6a 1a                	push   $0x1a
  jmp __alltraps
c01028e1:	e9 8d 09 00 00       	jmp    c0103273 <__alltraps>

c01028e6 <vector27>:
.globl vector27
vector27:
  pushl $0
c01028e6:	6a 00                	push   $0x0
  pushl $27
c01028e8:	6a 1b                	push   $0x1b
  jmp __alltraps
c01028ea:	e9 84 09 00 00       	jmp    c0103273 <__alltraps>

c01028ef <vector28>:
.globl vector28
vector28:
  pushl $0
c01028ef:	6a 00                	push   $0x0
  pushl $28
c01028f1:	6a 1c                	push   $0x1c
  jmp __alltraps
c01028f3:	e9 7b 09 00 00       	jmp    c0103273 <__alltraps>

c01028f8 <vector29>:
.globl vector29
vector29:
  pushl $0
c01028f8:	6a 00                	push   $0x0
  pushl $29
c01028fa:	6a 1d                	push   $0x1d
  jmp __alltraps
c01028fc:	e9 72 09 00 00       	jmp    c0103273 <__alltraps>

c0102901 <vector30>:
.globl vector30
vector30:
  pushl $0
c0102901:	6a 00                	push   $0x0
  pushl $30
c0102903:	6a 1e                	push   $0x1e
  jmp __alltraps
c0102905:	e9 69 09 00 00       	jmp    c0103273 <__alltraps>

c010290a <vector31>:
.globl vector31
vector31:
  pushl $0
c010290a:	6a 00                	push   $0x0
  pushl $31
c010290c:	6a 1f                	push   $0x1f
  jmp __alltraps
c010290e:	e9 60 09 00 00       	jmp    c0103273 <__alltraps>

c0102913 <vector32>:
.globl vector32
vector32:
  pushl $0
c0102913:	6a 00                	push   $0x0
  pushl $32
c0102915:	6a 20                	push   $0x20
  jmp __alltraps
c0102917:	e9 57 09 00 00       	jmp    c0103273 <__alltraps>

c010291c <vector33>:
.globl vector33
vector33:
  pushl $0
c010291c:	6a 00                	push   $0x0
  pushl $33
c010291e:	6a 21                	push   $0x21
  jmp __alltraps
c0102920:	e9 4e 09 00 00       	jmp    c0103273 <__alltraps>

c0102925 <vector34>:
.globl vector34
vector34:
  pushl $0
c0102925:	6a 00                	push   $0x0
  pushl $34
c0102927:	6a 22                	push   $0x22
  jmp __alltraps
c0102929:	e9 45 09 00 00       	jmp    c0103273 <__alltraps>

c010292e <vector35>:
.globl vector35
vector35:
  pushl $0
c010292e:	6a 00                	push   $0x0
  pushl $35
c0102930:	6a 23                	push   $0x23
  jmp __alltraps
c0102932:	e9 3c 09 00 00       	jmp    c0103273 <__alltraps>

c0102937 <vector36>:
.globl vector36
vector36:
  pushl $0
c0102937:	6a 00                	push   $0x0
  pushl $36
c0102939:	6a 24                	push   $0x24
  jmp __alltraps
c010293b:	e9 33 09 00 00       	jmp    c0103273 <__alltraps>

c0102940 <vector37>:
.globl vector37
vector37:
  pushl $0
c0102940:	6a 00                	push   $0x0
  pushl $37
c0102942:	6a 25                	push   $0x25
  jmp __alltraps
c0102944:	e9 2a 09 00 00       	jmp    c0103273 <__alltraps>

c0102949 <vector38>:
.globl vector38
vector38:
  pushl $0
c0102949:	6a 00                	push   $0x0
  pushl $38
c010294b:	6a 26                	push   $0x26
  jmp __alltraps
c010294d:	e9 21 09 00 00       	jmp    c0103273 <__alltraps>

c0102952 <vector39>:
.globl vector39
vector39:
  pushl $0
c0102952:	6a 00                	push   $0x0
  pushl $39
c0102954:	6a 27                	push   $0x27
  jmp __alltraps
c0102956:	e9 18 09 00 00       	jmp    c0103273 <__alltraps>

c010295b <vector40>:
.globl vector40
vector40:
  pushl $0
c010295b:	6a 00                	push   $0x0
  pushl $40
c010295d:	6a 28                	push   $0x28
  jmp __alltraps
c010295f:	e9 0f 09 00 00       	jmp    c0103273 <__alltraps>

c0102964 <vector41>:
.globl vector41
vector41:
  pushl $0
c0102964:	6a 00                	push   $0x0
  pushl $41
c0102966:	6a 29                	push   $0x29
  jmp __alltraps
c0102968:	e9 06 09 00 00       	jmp    c0103273 <__alltraps>

c010296d <vector42>:
.globl vector42
vector42:
  pushl $0
c010296d:	6a 00                	push   $0x0
  pushl $42
c010296f:	6a 2a                	push   $0x2a
  jmp __alltraps
c0102971:	e9 fd 08 00 00       	jmp    c0103273 <__alltraps>

c0102976 <vector43>:
.globl vector43
vector43:
  pushl $0
c0102976:	6a 00                	push   $0x0
  pushl $43
c0102978:	6a 2b                	push   $0x2b
  jmp __alltraps
c010297a:	e9 f4 08 00 00       	jmp    c0103273 <__alltraps>

c010297f <vector44>:
.globl vector44
vector44:
  pushl $0
c010297f:	6a 00                	push   $0x0
  pushl $44
c0102981:	6a 2c                	push   $0x2c
  jmp __alltraps
c0102983:	e9 eb 08 00 00       	jmp    c0103273 <__alltraps>

c0102988 <vector45>:
.globl vector45
vector45:
  pushl $0
c0102988:	6a 00                	push   $0x0
  pushl $45
c010298a:	6a 2d                	push   $0x2d
  jmp __alltraps
c010298c:	e9 e2 08 00 00       	jmp    c0103273 <__alltraps>

c0102991 <vector46>:
.globl vector46
vector46:
  pushl $0
c0102991:	6a 00                	push   $0x0
  pushl $46
c0102993:	6a 2e                	push   $0x2e
  jmp __alltraps
c0102995:	e9 d9 08 00 00       	jmp    c0103273 <__alltraps>

c010299a <vector47>:
.globl vector47
vector47:
  pushl $0
c010299a:	6a 00                	push   $0x0
  pushl $47
c010299c:	6a 2f                	push   $0x2f
  jmp __alltraps
c010299e:	e9 d0 08 00 00       	jmp    c0103273 <__alltraps>

c01029a3 <vector48>:
.globl vector48
vector48:
  pushl $0
c01029a3:	6a 00                	push   $0x0
  pushl $48
c01029a5:	6a 30                	push   $0x30
  jmp __alltraps
c01029a7:	e9 c7 08 00 00       	jmp    c0103273 <__alltraps>

c01029ac <vector49>:
.globl vector49
vector49:
  pushl $0
c01029ac:	6a 00                	push   $0x0
  pushl $49
c01029ae:	6a 31                	push   $0x31
  jmp __alltraps
c01029b0:	e9 be 08 00 00       	jmp    c0103273 <__alltraps>

c01029b5 <vector50>:
.globl vector50
vector50:
  pushl $0
c01029b5:	6a 00                	push   $0x0
  pushl $50
c01029b7:	6a 32                	push   $0x32
  jmp __alltraps
c01029b9:	e9 b5 08 00 00       	jmp    c0103273 <__alltraps>

c01029be <vector51>:
.globl vector51
vector51:
  pushl $0
c01029be:	6a 00                	push   $0x0
  pushl $51
c01029c0:	6a 33                	push   $0x33
  jmp __alltraps
c01029c2:	e9 ac 08 00 00       	jmp    c0103273 <__alltraps>

c01029c7 <vector52>:
.globl vector52
vector52:
  pushl $0
c01029c7:	6a 00                	push   $0x0
  pushl $52
c01029c9:	6a 34                	push   $0x34
  jmp __alltraps
c01029cb:	e9 a3 08 00 00       	jmp    c0103273 <__alltraps>

c01029d0 <vector53>:
.globl vector53
vector53:
  pushl $0
c01029d0:	6a 00                	push   $0x0
  pushl $53
c01029d2:	6a 35                	push   $0x35
  jmp __alltraps
c01029d4:	e9 9a 08 00 00       	jmp    c0103273 <__alltraps>

c01029d9 <vector54>:
.globl vector54
vector54:
  pushl $0
c01029d9:	6a 00                	push   $0x0
  pushl $54
c01029db:	6a 36                	push   $0x36
  jmp __alltraps
c01029dd:	e9 91 08 00 00       	jmp    c0103273 <__alltraps>

c01029e2 <vector55>:
.globl vector55
vector55:
  pushl $0
c01029e2:	6a 00                	push   $0x0
  pushl $55
c01029e4:	6a 37                	push   $0x37
  jmp __alltraps
c01029e6:	e9 88 08 00 00       	jmp    c0103273 <__alltraps>

c01029eb <vector56>:
.globl vector56
vector56:
  pushl $0
c01029eb:	6a 00                	push   $0x0
  pushl $56
c01029ed:	6a 38                	push   $0x38
  jmp __alltraps
c01029ef:	e9 7f 08 00 00       	jmp    c0103273 <__alltraps>

c01029f4 <vector57>:
.globl vector57
vector57:
  pushl $0
c01029f4:	6a 00                	push   $0x0
  pushl $57
c01029f6:	6a 39                	push   $0x39
  jmp __alltraps
c01029f8:	e9 76 08 00 00       	jmp    c0103273 <__alltraps>

c01029fd <vector58>:
.globl vector58
vector58:
  pushl $0
c01029fd:	6a 00                	push   $0x0
  pushl $58
c01029ff:	6a 3a                	push   $0x3a
  jmp __alltraps
c0102a01:	e9 6d 08 00 00       	jmp    c0103273 <__alltraps>

c0102a06 <vector59>:
.globl vector59
vector59:
  pushl $0
c0102a06:	6a 00                	push   $0x0
  pushl $59
c0102a08:	6a 3b                	push   $0x3b
  jmp __alltraps
c0102a0a:	e9 64 08 00 00       	jmp    c0103273 <__alltraps>

c0102a0f <vector60>:
.globl vector60
vector60:
  pushl $0
c0102a0f:	6a 00                	push   $0x0
  pushl $60
c0102a11:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102a13:	e9 5b 08 00 00       	jmp    c0103273 <__alltraps>

c0102a18 <vector61>:
.globl vector61
vector61:
  pushl $0
c0102a18:	6a 00                	push   $0x0
  pushl $61
c0102a1a:	6a 3d                	push   $0x3d
  jmp __alltraps
c0102a1c:	e9 52 08 00 00       	jmp    c0103273 <__alltraps>

c0102a21 <vector62>:
.globl vector62
vector62:
  pushl $0
c0102a21:	6a 00                	push   $0x0
  pushl $62
c0102a23:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102a25:	e9 49 08 00 00       	jmp    c0103273 <__alltraps>

c0102a2a <vector63>:
.globl vector63
vector63:
  pushl $0
c0102a2a:	6a 00                	push   $0x0
  pushl $63
c0102a2c:	6a 3f                	push   $0x3f
  jmp __alltraps
c0102a2e:	e9 40 08 00 00       	jmp    c0103273 <__alltraps>

c0102a33 <vector64>:
.globl vector64
vector64:
  pushl $0
c0102a33:	6a 00                	push   $0x0
  pushl $64
c0102a35:	6a 40                	push   $0x40
  jmp __alltraps
c0102a37:	e9 37 08 00 00       	jmp    c0103273 <__alltraps>

c0102a3c <vector65>:
.globl vector65
vector65:
  pushl $0
c0102a3c:	6a 00                	push   $0x0
  pushl $65
c0102a3e:	6a 41                	push   $0x41
  jmp __alltraps
c0102a40:	e9 2e 08 00 00       	jmp    c0103273 <__alltraps>

c0102a45 <vector66>:
.globl vector66
vector66:
  pushl $0
c0102a45:	6a 00                	push   $0x0
  pushl $66
c0102a47:	6a 42                	push   $0x42
  jmp __alltraps
c0102a49:	e9 25 08 00 00       	jmp    c0103273 <__alltraps>

c0102a4e <vector67>:
.globl vector67
vector67:
  pushl $0
c0102a4e:	6a 00                	push   $0x0
  pushl $67
c0102a50:	6a 43                	push   $0x43
  jmp __alltraps
c0102a52:	e9 1c 08 00 00       	jmp    c0103273 <__alltraps>

c0102a57 <vector68>:
.globl vector68
vector68:
  pushl $0
c0102a57:	6a 00                	push   $0x0
  pushl $68
c0102a59:	6a 44                	push   $0x44
  jmp __alltraps
c0102a5b:	e9 13 08 00 00       	jmp    c0103273 <__alltraps>

c0102a60 <vector69>:
.globl vector69
vector69:
  pushl $0
c0102a60:	6a 00                	push   $0x0
  pushl $69
c0102a62:	6a 45                	push   $0x45
  jmp __alltraps
c0102a64:	e9 0a 08 00 00       	jmp    c0103273 <__alltraps>

c0102a69 <vector70>:
.globl vector70
vector70:
  pushl $0
c0102a69:	6a 00                	push   $0x0
  pushl $70
c0102a6b:	6a 46                	push   $0x46
  jmp __alltraps
c0102a6d:	e9 01 08 00 00       	jmp    c0103273 <__alltraps>

c0102a72 <vector71>:
.globl vector71
vector71:
  pushl $0
c0102a72:	6a 00                	push   $0x0
  pushl $71
c0102a74:	6a 47                	push   $0x47
  jmp __alltraps
c0102a76:	e9 f8 07 00 00       	jmp    c0103273 <__alltraps>

c0102a7b <vector72>:
.globl vector72
vector72:
  pushl $0
c0102a7b:	6a 00                	push   $0x0
  pushl $72
c0102a7d:	6a 48                	push   $0x48
  jmp __alltraps
c0102a7f:	e9 ef 07 00 00       	jmp    c0103273 <__alltraps>

c0102a84 <vector73>:
.globl vector73
vector73:
  pushl $0
c0102a84:	6a 00                	push   $0x0
  pushl $73
c0102a86:	6a 49                	push   $0x49
  jmp __alltraps
c0102a88:	e9 e6 07 00 00       	jmp    c0103273 <__alltraps>

c0102a8d <vector74>:
.globl vector74
vector74:
  pushl $0
c0102a8d:	6a 00                	push   $0x0
  pushl $74
c0102a8f:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102a91:	e9 dd 07 00 00       	jmp    c0103273 <__alltraps>

c0102a96 <vector75>:
.globl vector75
vector75:
  pushl $0
c0102a96:	6a 00                	push   $0x0
  pushl $75
c0102a98:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102a9a:	e9 d4 07 00 00       	jmp    c0103273 <__alltraps>

c0102a9f <vector76>:
.globl vector76
vector76:
  pushl $0
c0102a9f:	6a 00                	push   $0x0
  pushl $76
c0102aa1:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102aa3:	e9 cb 07 00 00       	jmp    c0103273 <__alltraps>

c0102aa8 <vector77>:
.globl vector77
vector77:
  pushl $0
c0102aa8:	6a 00                	push   $0x0
  pushl $77
c0102aaa:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102aac:	e9 c2 07 00 00       	jmp    c0103273 <__alltraps>

c0102ab1 <vector78>:
.globl vector78
vector78:
  pushl $0
c0102ab1:	6a 00                	push   $0x0
  pushl $78
c0102ab3:	6a 4e                	push   $0x4e
  jmp __alltraps
c0102ab5:	e9 b9 07 00 00       	jmp    c0103273 <__alltraps>

c0102aba <vector79>:
.globl vector79
vector79:
  pushl $0
c0102aba:	6a 00                	push   $0x0
  pushl $79
c0102abc:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102abe:	e9 b0 07 00 00       	jmp    c0103273 <__alltraps>

c0102ac3 <vector80>:
.globl vector80
vector80:
  pushl $0
c0102ac3:	6a 00                	push   $0x0
  pushl $80
c0102ac5:	6a 50                	push   $0x50
  jmp __alltraps
c0102ac7:	e9 a7 07 00 00       	jmp    c0103273 <__alltraps>

c0102acc <vector81>:
.globl vector81
vector81:
  pushl $0
c0102acc:	6a 00                	push   $0x0
  pushl $81
c0102ace:	6a 51                	push   $0x51
  jmp __alltraps
c0102ad0:	e9 9e 07 00 00       	jmp    c0103273 <__alltraps>

c0102ad5 <vector82>:
.globl vector82
vector82:
  pushl $0
c0102ad5:	6a 00                	push   $0x0
  pushl $82
c0102ad7:	6a 52                	push   $0x52
  jmp __alltraps
c0102ad9:	e9 95 07 00 00       	jmp    c0103273 <__alltraps>

c0102ade <vector83>:
.globl vector83
vector83:
  pushl $0
c0102ade:	6a 00                	push   $0x0
  pushl $83
c0102ae0:	6a 53                	push   $0x53
  jmp __alltraps
c0102ae2:	e9 8c 07 00 00       	jmp    c0103273 <__alltraps>

c0102ae7 <vector84>:
.globl vector84
vector84:
  pushl $0
c0102ae7:	6a 00                	push   $0x0
  pushl $84
c0102ae9:	6a 54                	push   $0x54
  jmp __alltraps
c0102aeb:	e9 83 07 00 00       	jmp    c0103273 <__alltraps>

c0102af0 <vector85>:
.globl vector85
vector85:
  pushl $0
c0102af0:	6a 00                	push   $0x0
  pushl $85
c0102af2:	6a 55                	push   $0x55
  jmp __alltraps
c0102af4:	e9 7a 07 00 00       	jmp    c0103273 <__alltraps>

c0102af9 <vector86>:
.globl vector86
vector86:
  pushl $0
c0102af9:	6a 00                	push   $0x0
  pushl $86
c0102afb:	6a 56                	push   $0x56
  jmp __alltraps
c0102afd:	e9 71 07 00 00       	jmp    c0103273 <__alltraps>

c0102b02 <vector87>:
.globl vector87
vector87:
  pushl $0
c0102b02:	6a 00                	push   $0x0
  pushl $87
c0102b04:	6a 57                	push   $0x57
  jmp __alltraps
c0102b06:	e9 68 07 00 00       	jmp    c0103273 <__alltraps>

c0102b0b <vector88>:
.globl vector88
vector88:
  pushl $0
c0102b0b:	6a 00                	push   $0x0
  pushl $88
c0102b0d:	6a 58                	push   $0x58
  jmp __alltraps
c0102b0f:	e9 5f 07 00 00       	jmp    c0103273 <__alltraps>

c0102b14 <vector89>:
.globl vector89
vector89:
  pushl $0
c0102b14:	6a 00                	push   $0x0
  pushl $89
c0102b16:	6a 59                	push   $0x59
  jmp __alltraps
c0102b18:	e9 56 07 00 00       	jmp    c0103273 <__alltraps>

c0102b1d <vector90>:
.globl vector90
vector90:
  pushl $0
c0102b1d:	6a 00                	push   $0x0
  pushl $90
c0102b1f:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102b21:	e9 4d 07 00 00       	jmp    c0103273 <__alltraps>

c0102b26 <vector91>:
.globl vector91
vector91:
  pushl $0
c0102b26:	6a 00                	push   $0x0
  pushl $91
c0102b28:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102b2a:	e9 44 07 00 00       	jmp    c0103273 <__alltraps>

c0102b2f <vector92>:
.globl vector92
vector92:
  pushl $0
c0102b2f:	6a 00                	push   $0x0
  pushl $92
c0102b31:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102b33:	e9 3b 07 00 00       	jmp    c0103273 <__alltraps>

c0102b38 <vector93>:
.globl vector93
vector93:
  pushl $0
c0102b38:	6a 00                	push   $0x0
  pushl $93
c0102b3a:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102b3c:	e9 32 07 00 00       	jmp    c0103273 <__alltraps>

c0102b41 <vector94>:
.globl vector94
vector94:
  pushl $0
c0102b41:	6a 00                	push   $0x0
  pushl $94
c0102b43:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102b45:	e9 29 07 00 00       	jmp    c0103273 <__alltraps>

c0102b4a <vector95>:
.globl vector95
vector95:
  pushl $0
c0102b4a:	6a 00                	push   $0x0
  pushl $95
c0102b4c:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102b4e:	e9 20 07 00 00       	jmp    c0103273 <__alltraps>

c0102b53 <vector96>:
.globl vector96
vector96:
  pushl $0
c0102b53:	6a 00                	push   $0x0
  pushl $96
c0102b55:	6a 60                	push   $0x60
  jmp __alltraps
c0102b57:	e9 17 07 00 00       	jmp    c0103273 <__alltraps>

c0102b5c <vector97>:
.globl vector97
vector97:
  pushl $0
c0102b5c:	6a 00                	push   $0x0
  pushl $97
c0102b5e:	6a 61                	push   $0x61
  jmp __alltraps
c0102b60:	e9 0e 07 00 00       	jmp    c0103273 <__alltraps>

c0102b65 <vector98>:
.globl vector98
vector98:
  pushl $0
c0102b65:	6a 00                	push   $0x0
  pushl $98
c0102b67:	6a 62                	push   $0x62
  jmp __alltraps
c0102b69:	e9 05 07 00 00       	jmp    c0103273 <__alltraps>

c0102b6e <vector99>:
.globl vector99
vector99:
  pushl $0
c0102b6e:	6a 00                	push   $0x0
  pushl $99
c0102b70:	6a 63                	push   $0x63
  jmp __alltraps
c0102b72:	e9 fc 06 00 00       	jmp    c0103273 <__alltraps>

c0102b77 <vector100>:
.globl vector100
vector100:
  pushl $0
c0102b77:	6a 00                	push   $0x0
  pushl $100
c0102b79:	6a 64                	push   $0x64
  jmp __alltraps
c0102b7b:	e9 f3 06 00 00       	jmp    c0103273 <__alltraps>

c0102b80 <vector101>:
.globl vector101
vector101:
  pushl $0
c0102b80:	6a 00                	push   $0x0
  pushl $101
c0102b82:	6a 65                	push   $0x65
  jmp __alltraps
c0102b84:	e9 ea 06 00 00       	jmp    c0103273 <__alltraps>

c0102b89 <vector102>:
.globl vector102
vector102:
  pushl $0
c0102b89:	6a 00                	push   $0x0
  pushl $102
c0102b8b:	6a 66                	push   $0x66
  jmp __alltraps
c0102b8d:	e9 e1 06 00 00       	jmp    c0103273 <__alltraps>

c0102b92 <vector103>:
.globl vector103
vector103:
  pushl $0
c0102b92:	6a 00                	push   $0x0
  pushl $103
c0102b94:	6a 67                	push   $0x67
  jmp __alltraps
c0102b96:	e9 d8 06 00 00       	jmp    c0103273 <__alltraps>

c0102b9b <vector104>:
.globl vector104
vector104:
  pushl $0
c0102b9b:	6a 00                	push   $0x0
  pushl $104
c0102b9d:	6a 68                	push   $0x68
  jmp __alltraps
c0102b9f:	e9 cf 06 00 00       	jmp    c0103273 <__alltraps>

c0102ba4 <vector105>:
.globl vector105
vector105:
  pushl $0
c0102ba4:	6a 00                	push   $0x0
  pushl $105
c0102ba6:	6a 69                	push   $0x69
  jmp __alltraps
c0102ba8:	e9 c6 06 00 00       	jmp    c0103273 <__alltraps>

c0102bad <vector106>:
.globl vector106
vector106:
  pushl $0
c0102bad:	6a 00                	push   $0x0
  pushl $106
c0102baf:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102bb1:	e9 bd 06 00 00       	jmp    c0103273 <__alltraps>

c0102bb6 <vector107>:
.globl vector107
vector107:
  pushl $0
c0102bb6:	6a 00                	push   $0x0
  pushl $107
c0102bb8:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102bba:	e9 b4 06 00 00       	jmp    c0103273 <__alltraps>

c0102bbf <vector108>:
.globl vector108
vector108:
  pushl $0
c0102bbf:	6a 00                	push   $0x0
  pushl $108
c0102bc1:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102bc3:	e9 ab 06 00 00       	jmp    c0103273 <__alltraps>

c0102bc8 <vector109>:
.globl vector109
vector109:
  pushl $0
c0102bc8:	6a 00                	push   $0x0
  pushl $109
c0102bca:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102bcc:	e9 a2 06 00 00       	jmp    c0103273 <__alltraps>

c0102bd1 <vector110>:
.globl vector110
vector110:
  pushl $0
c0102bd1:	6a 00                	push   $0x0
  pushl $110
c0102bd3:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102bd5:	e9 99 06 00 00       	jmp    c0103273 <__alltraps>

c0102bda <vector111>:
.globl vector111
vector111:
  pushl $0
c0102bda:	6a 00                	push   $0x0
  pushl $111
c0102bdc:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102bde:	e9 90 06 00 00       	jmp    c0103273 <__alltraps>

c0102be3 <vector112>:
.globl vector112
vector112:
  pushl $0
c0102be3:	6a 00                	push   $0x0
  pushl $112
c0102be5:	6a 70                	push   $0x70
  jmp __alltraps
c0102be7:	e9 87 06 00 00       	jmp    c0103273 <__alltraps>

c0102bec <vector113>:
.globl vector113
vector113:
  pushl $0
c0102bec:	6a 00                	push   $0x0
  pushl $113
c0102bee:	6a 71                	push   $0x71
  jmp __alltraps
c0102bf0:	e9 7e 06 00 00       	jmp    c0103273 <__alltraps>

c0102bf5 <vector114>:
.globl vector114
vector114:
  pushl $0
c0102bf5:	6a 00                	push   $0x0
  pushl $114
c0102bf7:	6a 72                	push   $0x72
  jmp __alltraps
c0102bf9:	e9 75 06 00 00       	jmp    c0103273 <__alltraps>

c0102bfe <vector115>:
.globl vector115
vector115:
  pushl $0
c0102bfe:	6a 00                	push   $0x0
  pushl $115
c0102c00:	6a 73                	push   $0x73
  jmp __alltraps
c0102c02:	e9 6c 06 00 00       	jmp    c0103273 <__alltraps>

c0102c07 <vector116>:
.globl vector116
vector116:
  pushl $0
c0102c07:	6a 00                	push   $0x0
  pushl $116
c0102c09:	6a 74                	push   $0x74
  jmp __alltraps
c0102c0b:	e9 63 06 00 00       	jmp    c0103273 <__alltraps>

c0102c10 <vector117>:
.globl vector117
vector117:
  pushl $0
c0102c10:	6a 00                	push   $0x0
  pushl $117
c0102c12:	6a 75                	push   $0x75
  jmp __alltraps
c0102c14:	e9 5a 06 00 00       	jmp    c0103273 <__alltraps>

c0102c19 <vector118>:
.globl vector118
vector118:
  pushl $0
c0102c19:	6a 00                	push   $0x0
  pushl $118
c0102c1b:	6a 76                	push   $0x76
  jmp __alltraps
c0102c1d:	e9 51 06 00 00       	jmp    c0103273 <__alltraps>

c0102c22 <vector119>:
.globl vector119
vector119:
  pushl $0
c0102c22:	6a 00                	push   $0x0
  pushl $119
c0102c24:	6a 77                	push   $0x77
  jmp __alltraps
c0102c26:	e9 48 06 00 00       	jmp    c0103273 <__alltraps>

c0102c2b <vector120>:
.globl vector120
vector120:
  pushl $0
c0102c2b:	6a 00                	push   $0x0
  pushl $120
c0102c2d:	6a 78                	push   $0x78
  jmp __alltraps
c0102c2f:	e9 3f 06 00 00       	jmp    c0103273 <__alltraps>

c0102c34 <vector121>:
.globl vector121
vector121:
  pushl $0
c0102c34:	6a 00                	push   $0x0
  pushl $121
c0102c36:	6a 79                	push   $0x79
  jmp __alltraps
c0102c38:	e9 36 06 00 00       	jmp    c0103273 <__alltraps>

c0102c3d <vector122>:
.globl vector122
vector122:
  pushl $0
c0102c3d:	6a 00                	push   $0x0
  pushl $122
c0102c3f:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102c41:	e9 2d 06 00 00       	jmp    c0103273 <__alltraps>

c0102c46 <vector123>:
.globl vector123
vector123:
  pushl $0
c0102c46:	6a 00                	push   $0x0
  pushl $123
c0102c48:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102c4a:	e9 24 06 00 00       	jmp    c0103273 <__alltraps>

c0102c4f <vector124>:
.globl vector124
vector124:
  pushl $0
c0102c4f:	6a 00                	push   $0x0
  pushl $124
c0102c51:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102c53:	e9 1b 06 00 00       	jmp    c0103273 <__alltraps>

c0102c58 <vector125>:
.globl vector125
vector125:
  pushl $0
c0102c58:	6a 00                	push   $0x0
  pushl $125
c0102c5a:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102c5c:	e9 12 06 00 00       	jmp    c0103273 <__alltraps>

c0102c61 <vector126>:
.globl vector126
vector126:
  pushl $0
c0102c61:	6a 00                	push   $0x0
  pushl $126
c0102c63:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102c65:	e9 09 06 00 00       	jmp    c0103273 <__alltraps>

c0102c6a <vector127>:
.globl vector127
vector127:
  pushl $0
c0102c6a:	6a 00                	push   $0x0
  pushl $127
c0102c6c:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102c6e:	e9 00 06 00 00       	jmp    c0103273 <__alltraps>

c0102c73 <vector128>:
.globl vector128
vector128:
  pushl $0
c0102c73:	6a 00                	push   $0x0
  pushl $128
c0102c75:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102c7a:	e9 f4 05 00 00       	jmp    c0103273 <__alltraps>

c0102c7f <vector129>:
.globl vector129
vector129:
  pushl $0
c0102c7f:	6a 00                	push   $0x0
  pushl $129
c0102c81:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102c86:	e9 e8 05 00 00       	jmp    c0103273 <__alltraps>

c0102c8b <vector130>:
.globl vector130
vector130:
  pushl $0
c0102c8b:	6a 00                	push   $0x0
  pushl $130
c0102c8d:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102c92:	e9 dc 05 00 00       	jmp    c0103273 <__alltraps>

c0102c97 <vector131>:
.globl vector131
vector131:
  pushl $0
c0102c97:	6a 00                	push   $0x0
  pushl $131
c0102c99:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102c9e:	e9 d0 05 00 00       	jmp    c0103273 <__alltraps>

c0102ca3 <vector132>:
.globl vector132
vector132:
  pushl $0
c0102ca3:	6a 00                	push   $0x0
  pushl $132
c0102ca5:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102caa:	e9 c4 05 00 00       	jmp    c0103273 <__alltraps>

c0102caf <vector133>:
.globl vector133
vector133:
  pushl $0
c0102caf:	6a 00                	push   $0x0
  pushl $133
c0102cb1:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102cb6:	e9 b8 05 00 00       	jmp    c0103273 <__alltraps>

c0102cbb <vector134>:
.globl vector134
vector134:
  pushl $0
c0102cbb:	6a 00                	push   $0x0
  pushl $134
c0102cbd:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102cc2:	e9 ac 05 00 00       	jmp    c0103273 <__alltraps>

c0102cc7 <vector135>:
.globl vector135
vector135:
  pushl $0
c0102cc7:	6a 00                	push   $0x0
  pushl $135
c0102cc9:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102cce:	e9 a0 05 00 00       	jmp    c0103273 <__alltraps>

c0102cd3 <vector136>:
.globl vector136
vector136:
  pushl $0
c0102cd3:	6a 00                	push   $0x0
  pushl $136
c0102cd5:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0102cda:	e9 94 05 00 00       	jmp    c0103273 <__alltraps>

c0102cdf <vector137>:
.globl vector137
vector137:
  pushl $0
c0102cdf:	6a 00                	push   $0x0
  pushl $137
c0102ce1:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102ce6:	e9 88 05 00 00       	jmp    c0103273 <__alltraps>

c0102ceb <vector138>:
.globl vector138
vector138:
  pushl $0
c0102ceb:	6a 00                	push   $0x0
  pushl $138
c0102ced:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102cf2:	e9 7c 05 00 00       	jmp    c0103273 <__alltraps>

c0102cf7 <vector139>:
.globl vector139
vector139:
  pushl $0
c0102cf7:	6a 00                	push   $0x0
  pushl $139
c0102cf9:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102cfe:	e9 70 05 00 00       	jmp    c0103273 <__alltraps>

c0102d03 <vector140>:
.globl vector140
vector140:
  pushl $0
c0102d03:	6a 00                	push   $0x0
  pushl $140
c0102d05:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0102d0a:	e9 64 05 00 00       	jmp    c0103273 <__alltraps>

c0102d0f <vector141>:
.globl vector141
vector141:
  pushl $0
c0102d0f:	6a 00                	push   $0x0
  pushl $141
c0102d11:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102d16:	e9 58 05 00 00       	jmp    c0103273 <__alltraps>

c0102d1b <vector142>:
.globl vector142
vector142:
  pushl $0
c0102d1b:	6a 00                	push   $0x0
  pushl $142
c0102d1d:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102d22:	e9 4c 05 00 00       	jmp    c0103273 <__alltraps>

c0102d27 <vector143>:
.globl vector143
vector143:
  pushl $0
c0102d27:	6a 00                	push   $0x0
  pushl $143
c0102d29:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0102d2e:	e9 40 05 00 00       	jmp    c0103273 <__alltraps>

c0102d33 <vector144>:
.globl vector144
vector144:
  pushl $0
c0102d33:	6a 00                	push   $0x0
  pushl $144
c0102d35:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102d3a:	e9 34 05 00 00       	jmp    c0103273 <__alltraps>

c0102d3f <vector145>:
.globl vector145
vector145:
  pushl $0
c0102d3f:	6a 00                	push   $0x0
  pushl $145
c0102d41:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102d46:	e9 28 05 00 00       	jmp    c0103273 <__alltraps>

c0102d4b <vector146>:
.globl vector146
vector146:
  pushl $0
c0102d4b:	6a 00                	push   $0x0
  pushl $146
c0102d4d:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102d52:	e9 1c 05 00 00       	jmp    c0103273 <__alltraps>

c0102d57 <vector147>:
.globl vector147
vector147:
  pushl $0
c0102d57:	6a 00                	push   $0x0
  pushl $147
c0102d59:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0102d5e:	e9 10 05 00 00       	jmp    c0103273 <__alltraps>

c0102d63 <vector148>:
.globl vector148
vector148:
  pushl $0
c0102d63:	6a 00                	push   $0x0
  pushl $148
c0102d65:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102d6a:	e9 04 05 00 00       	jmp    c0103273 <__alltraps>

c0102d6f <vector149>:
.globl vector149
vector149:
  pushl $0
c0102d6f:	6a 00                	push   $0x0
  pushl $149
c0102d71:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102d76:	e9 f8 04 00 00       	jmp    c0103273 <__alltraps>

c0102d7b <vector150>:
.globl vector150
vector150:
  pushl $0
c0102d7b:	6a 00                	push   $0x0
  pushl $150
c0102d7d:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0102d82:	e9 ec 04 00 00       	jmp    c0103273 <__alltraps>

c0102d87 <vector151>:
.globl vector151
vector151:
  pushl $0
c0102d87:	6a 00                	push   $0x0
  pushl $151
c0102d89:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102d8e:	e9 e0 04 00 00       	jmp    c0103273 <__alltraps>

c0102d93 <vector152>:
.globl vector152
vector152:
  pushl $0
c0102d93:	6a 00                	push   $0x0
  pushl $152
c0102d95:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0102d9a:	e9 d4 04 00 00       	jmp    c0103273 <__alltraps>

c0102d9f <vector153>:
.globl vector153
vector153:
  pushl $0
c0102d9f:	6a 00                	push   $0x0
  pushl $153
c0102da1:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0102da6:	e9 c8 04 00 00       	jmp    c0103273 <__alltraps>

c0102dab <vector154>:
.globl vector154
vector154:
  pushl $0
c0102dab:	6a 00                	push   $0x0
  pushl $154
c0102dad:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0102db2:	e9 bc 04 00 00       	jmp    c0103273 <__alltraps>

c0102db7 <vector155>:
.globl vector155
vector155:
  pushl $0
c0102db7:	6a 00                	push   $0x0
  pushl $155
c0102db9:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0102dbe:	e9 b0 04 00 00       	jmp    c0103273 <__alltraps>

c0102dc3 <vector156>:
.globl vector156
vector156:
  pushl $0
c0102dc3:	6a 00                	push   $0x0
  pushl $156
c0102dc5:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0102dca:	e9 a4 04 00 00       	jmp    c0103273 <__alltraps>

c0102dcf <vector157>:
.globl vector157
vector157:
  pushl $0
c0102dcf:	6a 00                	push   $0x0
  pushl $157
c0102dd1:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0102dd6:	e9 98 04 00 00       	jmp    c0103273 <__alltraps>

c0102ddb <vector158>:
.globl vector158
vector158:
  pushl $0
c0102ddb:	6a 00                	push   $0x0
  pushl $158
c0102ddd:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0102de2:	e9 8c 04 00 00       	jmp    c0103273 <__alltraps>

c0102de7 <vector159>:
.globl vector159
vector159:
  pushl $0
c0102de7:	6a 00                	push   $0x0
  pushl $159
c0102de9:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0102dee:	e9 80 04 00 00       	jmp    c0103273 <__alltraps>

c0102df3 <vector160>:
.globl vector160
vector160:
  pushl $0
c0102df3:	6a 00                	push   $0x0
  pushl $160
c0102df5:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0102dfa:	e9 74 04 00 00       	jmp    c0103273 <__alltraps>

c0102dff <vector161>:
.globl vector161
vector161:
  pushl $0
c0102dff:	6a 00                	push   $0x0
  pushl $161
c0102e01:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0102e06:	e9 68 04 00 00       	jmp    c0103273 <__alltraps>

c0102e0b <vector162>:
.globl vector162
vector162:
  pushl $0
c0102e0b:	6a 00                	push   $0x0
  pushl $162
c0102e0d:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0102e12:	e9 5c 04 00 00       	jmp    c0103273 <__alltraps>

c0102e17 <vector163>:
.globl vector163
vector163:
  pushl $0
c0102e17:	6a 00                	push   $0x0
  pushl $163
c0102e19:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0102e1e:	e9 50 04 00 00       	jmp    c0103273 <__alltraps>

c0102e23 <vector164>:
.globl vector164
vector164:
  pushl $0
c0102e23:	6a 00                	push   $0x0
  pushl $164
c0102e25:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c0102e2a:	e9 44 04 00 00       	jmp    c0103273 <__alltraps>

c0102e2f <vector165>:
.globl vector165
vector165:
  pushl $0
c0102e2f:	6a 00                	push   $0x0
  pushl $165
c0102e31:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0102e36:	e9 38 04 00 00       	jmp    c0103273 <__alltraps>

c0102e3b <vector166>:
.globl vector166
vector166:
  pushl $0
c0102e3b:	6a 00                	push   $0x0
  pushl $166
c0102e3d:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c0102e42:	e9 2c 04 00 00       	jmp    c0103273 <__alltraps>

c0102e47 <vector167>:
.globl vector167
vector167:
  pushl $0
c0102e47:	6a 00                	push   $0x0
  pushl $167
c0102e49:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c0102e4e:	e9 20 04 00 00       	jmp    c0103273 <__alltraps>

c0102e53 <vector168>:
.globl vector168
vector168:
  pushl $0
c0102e53:	6a 00                	push   $0x0
  pushl $168
c0102e55:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0102e5a:	e9 14 04 00 00       	jmp    c0103273 <__alltraps>

c0102e5f <vector169>:
.globl vector169
vector169:
  pushl $0
c0102e5f:	6a 00                	push   $0x0
  pushl $169
c0102e61:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0102e66:	e9 08 04 00 00       	jmp    c0103273 <__alltraps>

c0102e6b <vector170>:
.globl vector170
vector170:
  pushl $0
c0102e6b:	6a 00                	push   $0x0
  pushl $170
c0102e6d:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0102e72:	e9 fc 03 00 00       	jmp    c0103273 <__alltraps>

c0102e77 <vector171>:
.globl vector171
vector171:
  pushl $0
c0102e77:	6a 00                	push   $0x0
  pushl $171
c0102e79:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0102e7e:	e9 f0 03 00 00       	jmp    c0103273 <__alltraps>

c0102e83 <vector172>:
.globl vector172
vector172:
  pushl $0
c0102e83:	6a 00                	push   $0x0
  pushl $172
c0102e85:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0102e8a:	e9 e4 03 00 00       	jmp    c0103273 <__alltraps>

c0102e8f <vector173>:
.globl vector173
vector173:
  pushl $0
c0102e8f:	6a 00                	push   $0x0
  pushl $173
c0102e91:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0102e96:	e9 d8 03 00 00       	jmp    c0103273 <__alltraps>

c0102e9b <vector174>:
.globl vector174
vector174:
  pushl $0
c0102e9b:	6a 00                	push   $0x0
  pushl $174
c0102e9d:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0102ea2:	e9 cc 03 00 00       	jmp    c0103273 <__alltraps>

c0102ea7 <vector175>:
.globl vector175
vector175:
  pushl $0
c0102ea7:	6a 00                	push   $0x0
  pushl $175
c0102ea9:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0102eae:	e9 c0 03 00 00       	jmp    c0103273 <__alltraps>

c0102eb3 <vector176>:
.globl vector176
vector176:
  pushl $0
c0102eb3:	6a 00                	push   $0x0
  pushl $176
c0102eb5:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0102eba:	e9 b4 03 00 00       	jmp    c0103273 <__alltraps>

c0102ebf <vector177>:
.globl vector177
vector177:
  pushl $0
c0102ebf:	6a 00                	push   $0x0
  pushl $177
c0102ec1:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0102ec6:	e9 a8 03 00 00       	jmp    c0103273 <__alltraps>

c0102ecb <vector178>:
.globl vector178
vector178:
  pushl $0
c0102ecb:	6a 00                	push   $0x0
  pushl $178
c0102ecd:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0102ed2:	e9 9c 03 00 00       	jmp    c0103273 <__alltraps>

c0102ed7 <vector179>:
.globl vector179
vector179:
  pushl $0
c0102ed7:	6a 00                	push   $0x0
  pushl $179
c0102ed9:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0102ede:	e9 90 03 00 00       	jmp    c0103273 <__alltraps>

c0102ee3 <vector180>:
.globl vector180
vector180:
  pushl $0
c0102ee3:	6a 00                	push   $0x0
  pushl $180
c0102ee5:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0102eea:	e9 84 03 00 00       	jmp    c0103273 <__alltraps>

c0102eef <vector181>:
.globl vector181
vector181:
  pushl $0
c0102eef:	6a 00                	push   $0x0
  pushl $181
c0102ef1:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0102ef6:	e9 78 03 00 00       	jmp    c0103273 <__alltraps>

c0102efb <vector182>:
.globl vector182
vector182:
  pushl $0
c0102efb:	6a 00                	push   $0x0
  pushl $182
c0102efd:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0102f02:	e9 6c 03 00 00       	jmp    c0103273 <__alltraps>

c0102f07 <vector183>:
.globl vector183
vector183:
  pushl $0
c0102f07:	6a 00                	push   $0x0
  pushl $183
c0102f09:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0102f0e:	e9 60 03 00 00       	jmp    c0103273 <__alltraps>

c0102f13 <vector184>:
.globl vector184
vector184:
  pushl $0
c0102f13:	6a 00                	push   $0x0
  pushl $184
c0102f15:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c0102f1a:	e9 54 03 00 00       	jmp    c0103273 <__alltraps>

c0102f1f <vector185>:
.globl vector185
vector185:
  pushl $0
c0102f1f:	6a 00                	push   $0x0
  pushl $185
c0102f21:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0102f26:	e9 48 03 00 00       	jmp    c0103273 <__alltraps>

c0102f2b <vector186>:
.globl vector186
vector186:
  pushl $0
c0102f2b:	6a 00                	push   $0x0
  pushl $186
c0102f2d:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c0102f32:	e9 3c 03 00 00       	jmp    c0103273 <__alltraps>

c0102f37 <vector187>:
.globl vector187
vector187:
  pushl $0
c0102f37:	6a 00                	push   $0x0
  pushl $187
c0102f39:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c0102f3e:	e9 30 03 00 00       	jmp    c0103273 <__alltraps>

c0102f43 <vector188>:
.globl vector188
vector188:
  pushl $0
c0102f43:	6a 00                	push   $0x0
  pushl $188
c0102f45:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c0102f4a:	e9 24 03 00 00       	jmp    c0103273 <__alltraps>

c0102f4f <vector189>:
.globl vector189
vector189:
  pushl $0
c0102f4f:	6a 00                	push   $0x0
  pushl $189
c0102f51:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0102f56:	e9 18 03 00 00       	jmp    c0103273 <__alltraps>

c0102f5b <vector190>:
.globl vector190
vector190:
  pushl $0
c0102f5b:	6a 00                	push   $0x0
  pushl $190
c0102f5d:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c0102f62:	e9 0c 03 00 00       	jmp    c0103273 <__alltraps>

c0102f67 <vector191>:
.globl vector191
vector191:
  pushl $0
c0102f67:	6a 00                	push   $0x0
  pushl $191
c0102f69:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0102f6e:	e9 00 03 00 00       	jmp    c0103273 <__alltraps>

c0102f73 <vector192>:
.globl vector192
vector192:
  pushl $0
c0102f73:	6a 00                	push   $0x0
  pushl $192
c0102f75:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0102f7a:	e9 f4 02 00 00       	jmp    c0103273 <__alltraps>

c0102f7f <vector193>:
.globl vector193
vector193:
  pushl $0
c0102f7f:	6a 00                	push   $0x0
  pushl $193
c0102f81:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0102f86:	e9 e8 02 00 00       	jmp    c0103273 <__alltraps>

c0102f8b <vector194>:
.globl vector194
vector194:
  pushl $0
c0102f8b:	6a 00                	push   $0x0
  pushl $194
c0102f8d:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c0102f92:	e9 dc 02 00 00       	jmp    c0103273 <__alltraps>

c0102f97 <vector195>:
.globl vector195
vector195:
  pushl $0
c0102f97:	6a 00                	push   $0x0
  pushl $195
c0102f99:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0102f9e:	e9 d0 02 00 00       	jmp    c0103273 <__alltraps>

c0102fa3 <vector196>:
.globl vector196
vector196:
  pushl $0
c0102fa3:	6a 00                	push   $0x0
  pushl $196
c0102fa5:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0102faa:	e9 c4 02 00 00       	jmp    c0103273 <__alltraps>

c0102faf <vector197>:
.globl vector197
vector197:
  pushl $0
c0102faf:	6a 00                	push   $0x0
  pushl $197
c0102fb1:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0102fb6:	e9 b8 02 00 00       	jmp    c0103273 <__alltraps>

c0102fbb <vector198>:
.globl vector198
vector198:
  pushl $0
c0102fbb:	6a 00                	push   $0x0
  pushl $198
c0102fbd:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0102fc2:	e9 ac 02 00 00       	jmp    c0103273 <__alltraps>

c0102fc7 <vector199>:
.globl vector199
vector199:
  pushl $0
c0102fc7:	6a 00                	push   $0x0
  pushl $199
c0102fc9:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0102fce:	e9 a0 02 00 00       	jmp    c0103273 <__alltraps>

c0102fd3 <vector200>:
.globl vector200
vector200:
  pushl $0
c0102fd3:	6a 00                	push   $0x0
  pushl $200
c0102fd5:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0102fda:	e9 94 02 00 00       	jmp    c0103273 <__alltraps>

c0102fdf <vector201>:
.globl vector201
vector201:
  pushl $0
c0102fdf:	6a 00                	push   $0x0
  pushl $201
c0102fe1:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0102fe6:	e9 88 02 00 00       	jmp    c0103273 <__alltraps>

c0102feb <vector202>:
.globl vector202
vector202:
  pushl $0
c0102feb:	6a 00                	push   $0x0
  pushl $202
c0102fed:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0102ff2:	e9 7c 02 00 00       	jmp    c0103273 <__alltraps>

c0102ff7 <vector203>:
.globl vector203
vector203:
  pushl $0
c0102ff7:	6a 00                	push   $0x0
  pushl $203
c0102ff9:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0102ffe:	e9 70 02 00 00       	jmp    c0103273 <__alltraps>

c0103003 <vector204>:
.globl vector204
vector204:
  pushl $0
c0103003:	6a 00                	push   $0x0
  pushl $204
c0103005:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c010300a:	e9 64 02 00 00       	jmp    c0103273 <__alltraps>

c010300f <vector205>:
.globl vector205
vector205:
  pushl $0
c010300f:	6a 00                	push   $0x0
  pushl $205
c0103011:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c0103016:	e9 58 02 00 00       	jmp    c0103273 <__alltraps>

c010301b <vector206>:
.globl vector206
vector206:
  pushl $0
c010301b:	6a 00                	push   $0x0
  pushl $206
c010301d:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c0103022:	e9 4c 02 00 00       	jmp    c0103273 <__alltraps>

c0103027 <vector207>:
.globl vector207
vector207:
  pushl $0
c0103027:	6a 00                	push   $0x0
  pushl $207
c0103029:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c010302e:	e9 40 02 00 00       	jmp    c0103273 <__alltraps>

c0103033 <vector208>:
.globl vector208
vector208:
  pushl $0
c0103033:	6a 00                	push   $0x0
  pushl $208
c0103035:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c010303a:	e9 34 02 00 00       	jmp    c0103273 <__alltraps>

c010303f <vector209>:
.globl vector209
vector209:
  pushl $0
c010303f:	6a 00                	push   $0x0
  pushl $209
c0103041:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c0103046:	e9 28 02 00 00       	jmp    c0103273 <__alltraps>

c010304b <vector210>:
.globl vector210
vector210:
  pushl $0
c010304b:	6a 00                	push   $0x0
  pushl $210
c010304d:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c0103052:	e9 1c 02 00 00       	jmp    c0103273 <__alltraps>

c0103057 <vector211>:
.globl vector211
vector211:
  pushl $0
c0103057:	6a 00                	push   $0x0
  pushl $211
c0103059:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c010305e:	e9 10 02 00 00       	jmp    c0103273 <__alltraps>

c0103063 <vector212>:
.globl vector212
vector212:
  pushl $0
c0103063:	6a 00                	push   $0x0
  pushl $212
c0103065:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c010306a:	e9 04 02 00 00       	jmp    c0103273 <__alltraps>

c010306f <vector213>:
.globl vector213
vector213:
  pushl $0
c010306f:	6a 00                	push   $0x0
  pushl $213
c0103071:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c0103076:	e9 f8 01 00 00       	jmp    c0103273 <__alltraps>

c010307b <vector214>:
.globl vector214
vector214:
  pushl $0
c010307b:	6a 00                	push   $0x0
  pushl $214
c010307d:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c0103082:	e9 ec 01 00 00       	jmp    c0103273 <__alltraps>

c0103087 <vector215>:
.globl vector215
vector215:
  pushl $0
c0103087:	6a 00                	push   $0x0
  pushl $215
c0103089:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c010308e:	e9 e0 01 00 00       	jmp    c0103273 <__alltraps>

c0103093 <vector216>:
.globl vector216
vector216:
  pushl $0
c0103093:	6a 00                	push   $0x0
  pushl $216
c0103095:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c010309a:	e9 d4 01 00 00       	jmp    c0103273 <__alltraps>

c010309f <vector217>:
.globl vector217
vector217:
  pushl $0
c010309f:	6a 00                	push   $0x0
  pushl $217
c01030a1:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c01030a6:	e9 c8 01 00 00       	jmp    c0103273 <__alltraps>

c01030ab <vector218>:
.globl vector218
vector218:
  pushl $0
c01030ab:	6a 00                	push   $0x0
  pushl $218
c01030ad:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c01030b2:	e9 bc 01 00 00       	jmp    c0103273 <__alltraps>

c01030b7 <vector219>:
.globl vector219
vector219:
  pushl $0
c01030b7:	6a 00                	push   $0x0
  pushl $219
c01030b9:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c01030be:	e9 b0 01 00 00       	jmp    c0103273 <__alltraps>

c01030c3 <vector220>:
.globl vector220
vector220:
  pushl $0
c01030c3:	6a 00                	push   $0x0
  pushl $220
c01030c5:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c01030ca:	e9 a4 01 00 00       	jmp    c0103273 <__alltraps>

c01030cf <vector221>:
.globl vector221
vector221:
  pushl $0
c01030cf:	6a 00                	push   $0x0
  pushl $221
c01030d1:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c01030d6:	e9 98 01 00 00       	jmp    c0103273 <__alltraps>

c01030db <vector222>:
.globl vector222
vector222:
  pushl $0
c01030db:	6a 00                	push   $0x0
  pushl $222
c01030dd:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c01030e2:	e9 8c 01 00 00       	jmp    c0103273 <__alltraps>

c01030e7 <vector223>:
.globl vector223
vector223:
  pushl $0
c01030e7:	6a 00                	push   $0x0
  pushl $223
c01030e9:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c01030ee:	e9 80 01 00 00       	jmp    c0103273 <__alltraps>

c01030f3 <vector224>:
.globl vector224
vector224:
  pushl $0
c01030f3:	6a 00                	push   $0x0
  pushl $224
c01030f5:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c01030fa:	e9 74 01 00 00       	jmp    c0103273 <__alltraps>

c01030ff <vector225>:
.globl vector225
vector225:
  pushl $0
c01030ff:	6a 00                	push   $0x0
  pushl $225
c0103101:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c0103106:	e9 68 01 00 00       	jmp    c0103273 <__alltraps>

c010310b <vector226>:
.globl vector226
vector226:
  pushl $0
c010310b:	6a 00                	push   $0x0
  pushl $226
c010310d:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c0103112:	e9 5c 01 00 00       	jmp    c0103273 <__alltraps>

c0103117 <vector227>:
.globl vector227
vector227:
  pushl $0
c0103117:	6a 00                	push   $0x0
  pushl $227
c0103119:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c010311e:	e9 50 01 00 00       	jmp    c0103273 <__alltraps>

c0103123 <vector228>:
.globl vector228
vector228:
  pushl $0
c0103123:	6a 00                	push   $0x0
  pushl $228
c0103125:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c010312a:	e9 44 01 00 00       	jmp    c0103273 <__alltraps>

c010312f <vector229>:
.globl vector229
vector229:
  pushl $0
c010312f:	6a 00                	push   $0x0
  pushl $229
c0103131:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c0103136:	e9 38 01 00 00       	jmp    c0103273 <__alltraps>

c010313b <vector230>:
.globl vector230
vector230:
  pushl $0
c010313b:	6a 00                	push   $0x0
  pushl $230
c010313d:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c0103142:	e9 2c 01 00 00       	jmp    c0103273 <__alltraps>

c0103147 <vector231>:
.globl vector231
vector231:
  pushl $0
c0103147:	6a 00                	push   $0x0
  pushl $231
c0103149:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c010314e:	e9 20 01 00 00       	jmp    c0103273 <__alltraps>

c0103153 <vector232>:
.globl vector232
vector232:
  pushl $0
c0103153:	6a 00                	push   $0x0
  pushl $232
c0103155:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c010315a:	e9 14 01 00 00       	jmp    c0103273 <__alltraps>

c010315f <vector233>:
.globl vector233
vector233:
  pushl $0
c010315f:	6a 00                	push   $0x0
  pushl $233
c0103161:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c0103166:	e9 08 01 00 00       	jmp    c0103273 <__alltraps>

c010316b <vector234>:
.globl vector234
vector234:
  pushl $0
c010316b:	6a 00                	push   $0x0
  pushl $234
c010316d:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c0103172:	e9 fc 00 00 00       	jmp    c0103273 <__alltraps>

c0103177 <vector235>:
.globl vector235
vector235:
  pushl $0
c0103177:	6a 00                	push   $0x0
  pushl $235
c0103179:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c010317e:	e9 f0 00 00 00       	jmp    c0103273 <__alltraps>

c0103183 <vector236>:
.globl vector236
vector236:
  pushl $0
c0103183:	6a 00                	push   $0x0
  pushl $236
c0103185:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c010318a:	e9 e4 00 00 00       	jmp    c0103273 <__alltraps>

c010318f <vector237>:
.globl vector237
vector237:
  pushl $0
c010318f:	6a 00                	push   $0x0
  pushl $237
c0103191:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c0103196:	e9 d8 00 00 00       	jmp    c0103273 <__alltraps>

c010319b <vector238>:
.globl vector238
vector238:
  pushl $0
c010319b:	6a 00                	push   $0x0
  pushl $238
c010319d:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c01031a2:	e9 cc 00 00 00       	jmp    c0103273 <__alltraps>

c01031a7 <vector239>:
.globl vector239
vector239:
  pushl $0
c01031a7:	6a 00                	push   $0x0
  pushl $239
c01031a9:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c01031ae:	e9 c0 00 00 00       	jmp    c0103273 <__alltraps>

c01031b3 <vector240>:
.globl vector240
vector240:
  pushl $0
c01031b3:	6a 00                	push   $0x0
  pushl $240
c01031b5:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c01031ba:	e9 b4 00 00 00       	jmp    c0103273 <__alltraps>

c01031bf <vector241>:
.globl vector241
vector241:
  pushl $0
c01031bf:	6a 00                	push   $0x0
  pushl $241
c01031c1:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c01031c6:	e9 a8 00 00 00       	jmp    c0103273 <__alltraps>

c01031cb <vector242>:
.globl vector242
vector242:
  pushl $0
c01031cb:	6a 00                	push   $0x0
  pushl $242
c01031cd:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c01031d2:	e9 9c 00 00 00       	jmp    c0103273 <__alltraps>

c01031d7 <vector243>:
.globl vector243
vector243:
  pushl $0
c01031d7:	6a 00                	push   $0x0
  pushl $243
c01031d9:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c01031de:	e9 90 00 00 00       	jmp    c0103273 <__alltraps>

c01031e3 <vector244>:
.globl vector244
vector244:
  pushl $0
c01031e3:	6a 00                	push   $0x0
  pushl $244
c01031e5:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c01031ea:	e9 84 00 00 00       	jmp    c0103273 <__alltraps>

c01031ef <vector245>:
.globl vector245
vector245:
  pushl $0
c01031ef:	6a 00                	push   $0x0
  pushl $245
c01031f1:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c01031f6:	e9 78 00 00 00       	jmp    c0103273 <__alltraps>

c01031fb <vector246>:
.globl vector246
vector246:
  pushl $0
c01031fb:	6a 00                	push   $0x0
  pushl $246
c01031fd:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c0103202:	e9 6c 00 00 00       	jmp    c0103273 <__alltraps>

c0103207 <vector247>:
.globl vector247
vector247:
  pushl $0
c0103207:	6a 00                	push   $0x0
  pushl $247
c0103209:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c010320e:	e9 60 00 00 00       	jmp    c0103273 <__alltraps>

c0103213 <vector248>:
.globl vector248
vector248:
  pushl $0
c0103213:	6a 00                	push   $0x0
  pushl $248
c0103215:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c010321a:	e9 54 00 00 00       	jmp    c0103273 <__alltraps>

c010321f <vector249>:
.globl vector249
vector249:
  pushl $0
c010321f:	6a 00                	push   $0x0
  pushl $249
c0103221:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c0103226:	e9 48 00 00 00       	jmp    c0103273 <__alltraps>

c010322b <vector250>:
.globl vector250
vector250:
  pushl $0
c010322b:	6a 00                	push   $0x0
  pushl $250
c010322d:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c0103232:	e9 3c 00 00 00       	jmp    c0103273 <__alltraps>

c0103237 <vector251>:
.globl vector251
vector251:
  pushl $0
c0103237:	6a 00                	push   $0x0
  pushl $251
c0103239:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c010323e:	e9 30 00 00 00       	jmp    c0103273 <__alltraps>

c0103243 <vector252>:
.globl vector252
vector252:
  pushl $0
c0103243:	6a 00                	push   $0x0
  pushl $252
c0103245:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c010324a:	e9 24 00 00 00       	jmp    c0103273 <__alltraps>

c010324f <vector253>:
.globl vector253
vector253:
  pushl $0
c010324f:	6a 00                	push   $0x0
  pushl $253
c0103251:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c0103256:	e9 18 00 00 00       	jmp    c0103273 <__alltraps>

c010325b <vector254>:
.globl vector254
vector254:
  pushl $0
c010325b:	6a 00                	push   $0x0
  pushl $254
c010325d:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c0103262:	e9 0c 00 00 00       	jmp    c0103273 <__alltraps>

c0103267 <vector255>:
.globl vector255
vector255:
  pushl $0
c0103267:	6a 00                	push   $0x0
  pushl $255
c0103269:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c010326e:	e9 00 00 00 00       	jmp    c0103273 <__alltraps>

c0103273 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0103273:	1e                   	push   %ds
    pushl %es
c0103274:	06                   	push   %es
    pushl %fs
c0103275:	0f a0                	push   %fs
    pushl %gs
c0103277:	0f a8                	push   %gs
    pushal
c0103279:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c010327a:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c010327f:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0103281:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0103283:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0103284:	e8 65 f5 ff ff       	call   c01027ee <trap>

    # pop the pushed stack pointer
    popl %esp
c0103289:	5c                   	pop    %esp

c010328a <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c010328a:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c010328b:	0f a9                	pop    %gs
    popl %fs
c010328d:	0f a1                	pop    %fs
    popl %es
c010328f:	07                   	pop    %es
    popl %ds
c0103290:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0103291:	83 c4 08             	add    $0x8,%esp
    iret
c0103294:	cf                   	iret   

c0103295 <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c0103295:	55                   	push   %ebp
c0103296:	89 e5                	mov    %esp,%ebp
c0103298:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c010329b:	8b 45 08             	mov    0x8(%ebp),%eax
c010329e:	c1 e8 0c             	shr    $0xc,%eax
c01032a1:	89 c2                	mov    %eax,%edx
c01032a3:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c01032a8:	39 c2                	cmp    %eax,%edx
c01032aa:	72 1c                	jb     c01032c8 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c01032ac:	c7 44 24 08 70 95 10 	movl   $0xc0109570,0x8(%esp)
c01032b3:	c0 
c01032b4:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c01032bb:	00 
c01032bc:	c7 04 24 8f 95 10 c0 	movl   $0xc010958f,(%esp)
c01032c3:	e8 30 d1 ff ff       	call   c01003f8 <__panic>
    }
    return &pages[PPN(pa)];
c01032c8:	a1 f8 40 12 c0       	mov    0xc01240f8,%eax
c01032cd:	8b 55 08             	mov    0x8(%ebp),%edx
c01032d0:	c1 ea 0c             	shr    $0xc,%edx
c01032d3:	c1 e2 05             	shl    $0x5,%edx
c01032d6:	01 d0                	add    %edx,%eax
}
c01032d8:	c9                   	leave  
c01032d9:	c3                   	ret    

c01032da <pde2page>:
    }
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *
pde2page(pde_t pde) {
c01032da:	55                   	push   %ebp
c01032db:	89 e5                	mov    %esp,%ebp
c01032dd:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c01032e0:	8b 45 08             	mov    0x8(%ebp),%eax
c01032e3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01032e8:	89 04 24             	mov    %eax,(%esp)
c01032eb:	e8 a5 ff ff ff       	call   c0103295 <pa2page>
}
c01032f0:	c9                   	leave  
c01032f1:	c3                   	ret    

c01032f2 <mm_create>:
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void) {
c01032f2:	55                   	push   %ebp
c01032f3:	89 e5                	mov    %esp,%ebp
c01032f5:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
c01032f8:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c01032ff:	e8 a6 4a 00 00       	call   c0107daa <kmalloc>
c0103304:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (mm != NULL) {
c0103307:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010330b:	74 58                	je     c0103365 <mm_create+0x73>
        list_init(&(mm->mmap_list));
c010330d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103310:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0103313:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103316:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0103319:	89 50 04             	mov    %edx,0x4(%eax)
c010331c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010331f:	8b 50 04             	mov    0x4(%eax),%edx
c0103322:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103325:	89 10                	mov    %edx,(%eax)
        mm->mmap_cache = NULL;
c0103327:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010332a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        mm->pgdir = NULL;
c0103331:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103334:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        mm->map_count = 0;
c010333b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010333e:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

        if (swap_init_ok) swap_init_mm(mm);
c0103345:	a1 68 3f 12 c0       	mov    0xc0123f68,%eax
c010334a:	85 c0                	test   %eax,%eax
c010334c:	74 0d                	je     c010335b <mm_create+0x69>
c010334e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103351:	89 04 24             	mov    %eax,(%esp)
c0103354:	e8 2e 13 00 00       	call   c0104687 <swap_init_mm>
c0103359:	eb 0a                	jmp    c0103365 <mm_create+0x73>
        else mm->sm_priv = NULL;
c010335b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010335e:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
    }
    return mm;
c0103365:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103368:	c9                   	leave  
c0103369:	c3                   	ret    

c010336a <vma_create>:

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
c010336a:	55                   	push   %ebp
c010336b:	89 e5                	mov    %esp,%ebp
c010336d:	83 ec 28             	sub    $0x28,%esp
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
c0103370:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c0103377:	e8 2e 4a 00 00       	call   c0107daa <kmalloc>
c010337c:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (vma != NULL) {
c010337f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103383:	74 1b                	je     c01033a0 <vma_create+0x36>
        vma->vm_start = vm_start;
c0103385:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103388:	8b 55 08             	mov    0x8(%ebp),%edx
c010338b:	89 50 04             	mov    %edx,0x4(%eax)
        vma->vm_end = vm_end;
c010338e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103391:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103394:	89 50 08             	mov    %edx,0x8(%eax)
        vma->vm_flags = vm_flags;
c0103397:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010339a:	8b 55 10             	mov    0x10(%ebp),%edx
c010339d:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    return vma;
c01033a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01033a3:	c9                   	leave  
c01033a4:	c3                   	ret    

c01033a5 <find_vma>:


// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
c01033a5:	55                   	push   %ebp
c01033a6:	89 e5                	mov    %esp,%ebp
c01033a8:	83 ec 20             	sub    $0x20,%esp
    struct vma_struct *vma = NULL;
c01033ab:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    if (mm != NULL) {
c01033b2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01033b6:	0f 84 95 00 00 00    	je     c0103451 <find_vma+0xac>
        vma = mm->mmap_cache;
c01033bc:	8b 45 08             	mov    0x8(%ebp),%eax
c01033bf:	8b 40 08             	mov    0x8(%eax),%eax
c01033c2:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
c01033c5:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01033c9:	74 16                	je     c01033e1 <find_vma+0x3c>
c01033cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01033ce:	8b 40 04             	mov    0x4(%eax),%eax
c01033d1:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01033d4:	77 0b                	ja     c01033e1 <find_vma+0x3c>
c01033d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01033d9:	8b 40 08             	mov    0x8(%eax),%eax
c01033dc:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01033df:	77 61                	ja     c0103442 <find_vma+0x9d>
                bool found = 0;
c01033e1:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
                list_entry_t *list = &(mm->mmap_list), *le = list;
c01033e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01033eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01033ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01033f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
                while ((le = list_next(le)) != list) {
c01033f4:	eb 28                	jmp    c010341e <find_vma+0x79>
                    vma = le2vma(le, list_link);
c01033f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033f9:	83 e8 10             	sub    $0x10,%eax
c01033fc:	89 45 fc             	mov    %eax,-0x4(%ebp)
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
c01033ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103402:	8b 40 04             	mov    0x4(%eax),%eax
c0103405:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103408:	77 14                	ja     c010341e <find_vma+0x79>
c010340a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010340d:	8b 40 08             	mov    0x8(%eax),%eax
c0103410:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103413:	76 09                	jbe    c010341e <find_vma+0x79>
                        found = 1;
c0103415:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
                        break;
c010341c:	eb 17                	jmp    c0103435 <find_vma+0x90>
c010341e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103421:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0103424:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103427:	8b 40 04             	mov    0x4(%eax),%eax
                while ((le = list_next(le)) != list) {
c010342a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010342d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103430:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103433:	75 c1                	jne    c01033f6 <find_vma+0x51>
                    }
                }
                if (!found) {
c0103435:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c0103439:	75 07                	jne    c0103442 <find_vma+0x9d>
                    vma = NULL;
c010343b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
                }
        }
        if (vma != NULL) {
c0103442:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0103446:	74 09                	je     c0103451 <find_vma+0xac>
            mm->mmap_cache = vma;
c0103448:	8b 45 08             	mov    0x8(%ebp),%eax
c010344b:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010344e:	89 50 08             	mov    %edx,0x8(%eax)
        }
    }
    return vma;
c0103451:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0103454:	c9                   	leave  
c0103455:	c3                   	ret    

c0103456 <check_vma_overlap>:


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
c0103456:	55                   	push   %ebp
c0103457:	89 e5                	mov    %esp,%ebp
c0103459:	83 ec 18             	sub    $0x18,%esp
    assert(prev->vm_start < prev->vm_end);
c010345c:	8b 45 08             	mov    0x8(%ebp),%eax
c010345f:	8b 50 04             	mov    0x4(%eax),%edx
c0103462:	8b 45 08             	mov    0x8(%ebp),%eax
c0103465:	8b 40 08             	mov    0x8(%eax),%eax
c0103468:	39 c2                	cmp    %eax,%edx
c010346a:	72 24                	jb     c0103490 <check_vma_overlap+0x3a>
c010346c:	c7 44 24 0c 9d 95 10 	movl   $0xc010959d,0xc(%esp)
c0103473:	c0 
c0103474:	c7 44 24 08 bb 95 10 	movl   $0xc01095bb,0x8(%esp)
c010347b:	c0 
c010347c:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c0103483:	00 
c0103484:	c7 04 24 d0 95 10 c0 	movl   $0xc01095d0,(%esp)
c010348b:	e8 68 cf ff ff       	call   c01003f8 <__panic>
    assert(prev->vm_end <= next->vm_start);
c0103490:	8b 45 08             	mov    0x8(%ebp),%eax
c0103493:	8b 50 08             	mov    0x8(%eax),%edx
c0103496:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103499:	8b 40 04             	mov    0x4(%eax),%eax
c010349c:	39 c2                	cmp    %eax,%edx
c010349e:	76 24                	jbe    c01034c4 <check_vma_overlap+0x6e>
c01034a0:	c7 44 24 0c e0 95 10 	movl   $0xc01095e0,0xc(%esp)
c01034a7:	c0 
c01034a8:	c7 44 24 08 bb 95 10 	movl   $0xc01095bb,0x8(%esp)
c01034af:	c0 
c01034b0:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
c01034b7:	00 
c01034b8:	c7 04 24 d0 95 10 c0 	movl   $0xc01095d0,(%esp)
c01034bf:	e8 34 cf ff ff       	call   c01003f8 <__panic>
    assert(next->vm_start < next->vm_end);
c01034c4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01034c7:	8b 50 04             	mov    0x4(%eax),%edx
c01034ca:	8b 45 0c             	mov    0xc(%ebp),%eax
c01034cd:	8b 40 08             	mov    0x8(%eax),%eax
c01034d0:	39 c2                	cmp    %eax,%edx
c01034d2:	72 24                	jb     c01034f8 <check_vma_overlap+0xa2>
c01034d4:	c7 44 24 0c ff 95 10 	movl   $0xc01095ff,0xc(%esp)
c01034db:	c0 
c01034dc:	c7 44 24 08 bb 95 10 	movl   $0xc01095bb,0x8(%esp)
c01034e3:	c0 
c01034e4:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
c01034eb:	00 
c01034ec:	c7 04 24 d0 95 10 c0 	movl   $0xc01095d0,(%esp)
c01034f3:	e8 00 cf ff ff       	call   c01003f8 <__panic>
}
c01034f8:	c9                   	leave  
c01034f9:	c3                   	ret    

c01034fa <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
c01034fa:	55                   	push   %ebp
c01034fb:	89 e5                	mov    %esp,%ebp
c01034fd:	83 ec 48             	sub    $0x48,%esp
    assert(vma->vm_start < vma->vm_end);
c0103500:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103503:	8b 50 04             	mov    0x4(%eax),%edx
c0103506:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103509:	8b 40 08             	mov    0x8(%eax),%eax
c010350c:	39 c2                	cmp    %eax,%edx
c010350e:	72 24                	jb     c0103534 <insert_vma_struct+0x3a>
c0103510:	c7 44 24 0c 1d 96 10 	movl   $0xc010961d,0xc(%esp)
c0103517:	c0 
c0103518:	c7 44 24 08 bb 95 10 	movl   $0xc01095bb,0x8(%esp)
c010351f:	c0 
c0103520:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0103527:	00 
c0103528:	c7 04 24 d0 95 10 c0 	movl   $0xc01095d0,(%esp)
c010352f:	e8 c4 ce ff ff       	call   c01003f8 <__panic>
    list_entry_t *list = &(mm->mmap_list);
c0103534:	8b 45 08             	mov    0x8(%ebp),%eax
c0103537:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_entry_t *le_prev = list, *le_next;
c010353a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010353d:	89 45 f4             	mov    %eax,-0xc(%ebp)

        list_entry_t *le = list;
c0103540:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103543:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while ((le = list_next(le)) != list) {
c0103546:	eb 21                	jmp    c0103569 <insert_vma_struct+0x6f>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
c0103548:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010354b:	83 e8 10             	sub    $0x10,%eax
c010354e:	89 45 e8             	mov    %eax,-0x18(%ebp)
            if (mmap_prev->vm_start > vma->vm_start) {
c0103551:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103554:	8b 50 04             	mov    0x4(%eax),%edx
c0103557:	8b 45 0c             	mov    0xc(%ebp),%eax
c010355a:	8b 40 04             	mov    0x4(%eax),%eax
c010355d:	39 c2                	cmp    %eax,%edx
c010355f:	76 02                	jbe    c0103563 <insert_vma_struct+0x69>
                break;
c0103561:	eb 1d                	jmp    c0103580 <insert_vma_struct+0x86>
            }
            le_prev = le;
c0103563:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103566:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103569:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010356c:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010356f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103572:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list) {
c0103575:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103578:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010357b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010357e:	75 c8                	jne    c0103548 <insert_vma_struct+0x4e>
c0103580:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103583:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103586:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103589:	8b 40 04             	mov    0x4(%eax),%eax
        }

    le_next = list_next(le_prev);
c010358c:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    /* check overlap */
    if (le_prev != list) {
c010358f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103592:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103595:	74 15                	je     c01035ac <insert_vma_struct+0xb2>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
c0103597:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010359a:	8d 50 f0             	lea    -0x10(%eax),%edx
c010359d:	8b 45 0c             	mov    0xc(%ebp),%eax
c01035a0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01035a4:	89 14 24             	mov    %edx,(%esp)
c01035a7:	e8 aa fe ff ff       	call   c0103456 <check_vma_overlap>
    }
    if (le_next != list) {
c01035ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01035af:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01035b2:	74 15                	je     c01035c9 <insert_vma_struct+0xcf>
        check_vma_overlap(vma, le2vma(le_next, list_link));
c01035b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01035b7:	83 e8 10             	sub    $0x10,%eax
c01035ba:	89 44 24 04          	mov    %eax,0x4(%esp)
c01035be:	8b 45 0c             	mov    0xc(%ebp),%eax
c01035c1:	89 04 24             	mov    %eax,(%esp)
c01035c4:	e8 8d fe ff ff       	call   c0103456 <check_vma_overlap>
    }

    vma->vm_mm = mm;
c01035c9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01035cc:	8b 55 08             	mov    0x8(%ebp),%edx
c01035cf:	89 10                	mov    %edx,(%eax)
    list_add_after(le_prev, &(vma->list_link));
c01035d1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01035d4:	8d 50 10             	lea    0x10(%eax),%edx
c01035d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035da:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01035dd:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
c01035e0:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01035e3:	8b 40 04             	mov    0x4(%eax),%eax
c01035e6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01035e9:	89 55 d0             	mov    %edx,-0x30(%ebp)
c01035ec:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01035ef:	89 55 cc             	mov    %edx,-0x34(%ebp)
c01035f2:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01035f5:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01035f8:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01035fb:	89 10                	mov    %edx,(%eax)
c01035fd:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103600:	8b 10                	mov    (%eax),%edx
c0103602:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103605:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103608:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010360b:	8b 55 c8             	mov    -0x38(%ebp),%edx
c010360e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103611:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103614:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0103617:	89 10                	mov    %edx,(%eax)

    mm->map_count ++;
c0103619:	8b 45 08             	mov    0x8(%ebp),%eax
c010361c:	8b 40 10             	mov    0x10(%eax),%eax
c010361f:	8d 50 01             	lea    0x1(%eax),%edx
c0103622:	8b 45 08             	mov    0x8(%ebp),%eax
c0103625:	89 50 10             	mov    %edx,0x10(%eax)
}
c0103628:	c9                   	leave  
c0103629:	c3                   	ret    

c010362a <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
c010362a:	55                   	push   %ebp
c010362b:	89 e5                	mov    %esp,%ebp
c010362d:	83 ec 38             	sub    $0x38,%esp

    list_entry_t *list = &(mm->mmap_list), *le;
c0103630:	8b 45 08             	mov    0x8(%ebp),%eax
c0103633:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(list)) != list) {
c0103636:	eb 3e                	jmp    c0103676 <mm_destroy+0x4c>
c0103638:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010363b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    __list_del(listelm->prev, listelm->next);
c010363e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103641:	8b 40 04             	mov    0x4(%eax),%eax
c0103644:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0103647:	8b 12                	mov    (%edx),%edx
c0103649:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010364c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c010364f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103652:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103655:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103658:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010365b:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010365e:	89 10                	mov    %edx,(%eax)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
c0103660:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103663:	83 e8 10             	sub    $0x10,%eax
c0103666:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
c010366d:	00 
c010366e:	89 04 24             	mov    %eax,(%esp)
c0103671:	e8 d4 47 00 00       	call   c0107e4a <kfree>
c0103676:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103679:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
c010367c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010367f:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(list)) != list) {
c0103682:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103685:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103688:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010368b:	75 ab                	jne    c0103638 <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
c010368d:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
c0103694:	00 
c0103695:	8b 45 08             	mov    0x8(%ebp),%eax
c0103698:	89 04 24             	mov    %eax,(%esp)
c010369b:	e8 aa 47 00 00       	call   c0107e4a <kfree>
    mm=NULL;
c01036a0:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
}
c01036a7:	c9                   	leave  
c01036a8:	c3                   	ret    

c01036a9 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
c01036a9:	55                   	push   %ebp
c01036aa:	89 e5                	mov    %esp,%ebp
c01036ac:	83 ec 08             	sub    $0x8,%esp
    check_vmm();
c01036af:	e8 02 00 00 00       	call   c01036b6 <check_vmm>
}
c01036b4:	c9                   	leave  
c01036b5:	c3                   	ret    

c01036b6 <check_vmm>:

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
c01036b6:	55                   	push   %ebp
c01036b7:	89 e5                	mov    %esp,%ebp
c01036b9:	83 ec 28             	sub    $0x28,%esp
    size_t nr_free_pages_store = nr_free_pages();
c01036bc:	e8 d6 2f 00 00       	call   c0106697 <nr_free_pages>
c01036c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    
    check_vma_struct();
c01036c4:	e8 41 00 00 00       	call   c010370a <check_vma_struct>
    check_pgfault();
c01036c9:	e8 03 05 00 00       	call   c0103bd1 <check_pgfault>

    assert(nr_free_pages_store == nr_free_pages());
c01036ce:	e8 c4 2f 00 00       	call   c0106697 <nr_free_pages>
c01036d3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01036d6:	74 24                	je     c01036fc <check_vmm+0x46>
c01036d8:	c7 44 24 0c 3c 96 10 	movl   $0xc010963c,0xc(%esp)
c01036df:	c0 
c01036e0:	c7 44 24 08 bb 95 10 	movl   $0xc01095bb,0x8(%esp)
c01036e7:	c0 
c01036e8:	c7 44 24 04 a9 00 00 	movl   $0xa9,0x4(%esp)
c01036ef:	00 
c01036f0:	c7 04 24 d0 95 10 c0 	movl   $0xc01095d0,(%esp)
c01036f7:	e8 fc cc ff ff       	call   c01003f8 <__panic>

    cprintf("check_vmm() succeeded.\n");
c01036fc:	c7 04 24 63 96 10 c0 	movl   $0xc0109663,(%esp)
c0103703:	e8 99 cb ff ff       	call   c01002a1 <cprintf>
}
c0103708:	c9                   	leave  
c0103709:	c3                   	ret    

c010370a <check_vma_struct>:

static void
check_vma_struct(void) {
c010370a:	55                   	push   %ebp
c010370b:	89 e5                	mov    %esp,%ebp
c010370d:	83 ec 68             	sub    $0x68,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0103710:	e8 82 2f 00 00       	call   c0106697 <nr_free_pages>
c0103715:	89 45 ec             	mov    %eax,-0x14(%ebp)

    struct mm_struct *mm = mm_create();
c0103718:	e8 d5 fb ff ff       	call   c01032f2 <mm_create>
c010371d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(mm != NULL);
c0103720:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103724:	75 24                	jne    c010374a <check_vma_struct+0x40>
c0103726:	c7 44 24 0c 7b 96 10 	movl   $0xc010967b,0xc(%esp)
c010372d:	c0 
c010372e:	c7 44 24 08 bb 95 10 	movl   $0xc01095bb,0x8(%esp)
c0103735:	c0 
c0103736:	c7 44 24 04 b3 00 00 	movl   $0xb3,0x4(%esp)
c010373d:	00 
c010373e:	c7 04 24 d0 95 10 c0 	movl   $0xc01095d0,(%esp)
c0103745:	e8 ae cc ff ff       	call   c01003f8 <__panic>

    int step1 = 10, step2 = step1 * 10;
c010374a:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
c0103751:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103754:	89 d0                	mov    %edx,%eax
c0103756:	c1 e0 02             	shl    $0x2,%eax
c0103759:	01 d0                	add    %edx,%eax
c010375b:	01 c0                	add    %eax,%eax
c010375d:	89 45 e0             	mov    %eax,-0x20(%ebp)

    int i;
    for (i = step1; i >= 1; i --) {
c0103760:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103763:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103766:	eb 70                	jmp    c01037d8 <check_vma_struct+0xce>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0103768:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010376b:	89 d0                	mov    %edx,%eax
c010376d:	c1 e0 02             	shl    $0x2,%eax
c0103770:	01 d0                	add    %edx,%eax
c0103772:	83 c0 02             	add    $0x2,%eax
c0103775:	89 c1                	mov    %eax,%ecx
c0103777:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010377a:	89 d0                	mov    %edx,%eax
c010377c:	c1 e0 02             	shl    $0x2,%eax
c010377f:	01 d0                	add    %edx,%eax
c0103781:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103788:	00 
c0103789:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c010378d:	89 04 24             	mov    %eax,(%esp)
c0103790:	e8 d5 fb ff ff       	call   c010336a <vma_create>
c0103795:	89 45 dc             	mov    %eax,-0x24(%ebp)
        assert(vma != NULL);
c0103798:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010379c:	75 24                	jne    c01037c2 <check_vma_struct+0xb8>
c010379e:	c7 44 24 0c 86 96 10 	movl   $0xc0109686,0xc(%esp)
c01037a5:	c0 
c01037a6:	c7 44 24 08 bb 95 10 	movl   $0xc01095bb,0x8(%esp)
c01037ad:	c0 
c01037ae:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
c01037b5:	00 
c01037b6:	c7 04 24 d0 95 10 c0 	movl   $0xc01095d0,(%esp)
c01037bd:	e8 36 cc ff ff       	call   c01003f8 <__panic>
        insert_vma_struct(mm, vma);
c01037c2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01037c5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01037c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01037cc:	89 04 24             	mov    %eax,(%esp)
c01037cf:	e8 26 fd ff ff       	call   c01034fa <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
c01037d4:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01037d8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01037dc:	7f 8a                	jg     c0103768 <check_vma_struct+0x5e>
    }

    for (i = step1 + 1; i <= step2; i ++) {
c01037de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01037e1:	83 c0 01             	add    $0x1,%eax
c01037e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01037e7:	eb 70                	jmp    c0103859 <check_vma_struct+0x14f>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c01037e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01037ec:	89 d0                	mov    %edx,%eax
c01037ee:	c1 e0 02             	shl    $0x2,%eax
c01037f1:	01 d0                	add    %edx,%eax
c01037f3:	83 c0 02             	add    $0x2,%eax
c01037f6:	89 c1                	mov    %eax,%ecx
c01037f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01037fb:	89 d0                	mov    %edx,%eax
c01037fd:	c1 e0 02             	shl    $0x2,%eax
c0103800:	01 d0                	add    %edx,%eax
c0103802:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103809:	00 
c010380a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c010380e:	89 04 24             	mov    %eax,(%esp)
c0103811:	e8 54 fb ff ff       	call   c010336a <vma_create>
c0103816:	89 45 d8             	mov    %eax,-0x28(%ebp)
        assert(vma != NULL);
c0103819:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c010381d:	75 24                	jne    c0103843 <check_vma_struct+0x139>
c010381f:	c7 44 24 0c 86 96 10 	movl   $0xc0109686,0xc(%esp)
c0103826:	c0 
c0103827:	c7 44 24 08 bb 95 10 	movl   $0xc01095bb,0x8(%esp)
c010382e:	c0 
c010382f:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
c0103836:	00 
c0103837:	c7 04 24 d0 95 10 c0 	movl   $0xc01095d0,(%esp)
c010383e:	e8 b5 cb ff ff       	call   c01003f8 <__panic>
        insert_vma_struct(mm, vma);
c0103843:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103846:	89 44 24 04          	mov    %eax,0x4(%esp)
c010384a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010384d:	89 04 24             	mov    %eax,(%esp)
c0103850:	e8 a5 fc ff ff       	call   c01034fa <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
c0103855:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0103859:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010385c:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c010385f:	7e 88                	jle    c01037e9 <check_vma_struct+0xdf>
    }

    list_entry_t *le = list_next(&(mm->mmap_list));
c0103861:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103864:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0103867:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010386a:	8b 40 04             	mov    0x4(%eax),%eax
c010386d:	89 45 f0             	mov    %eax,-0x10(%ebp)

    for (i = 1; i <= step2; i ++) {
c0103870:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c0103877:	e9 97 00 00 00       	jmp    c0103913 <check_vma_struct+0x209>
        assert(le != &(mm->mmap_list));
c010387c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010387f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103882:	75 24                	jne    c01038a8 <check_vma_struct+0x19e>
c0103884:	c7 44 24 0c 92 96 10 	movl   $0xc0109692,0xc(%esp)
c010388b:	c0 
c010388c:	c7 44 24 08 bb 95 10 	movl   $0xc01095bb,0x8(%esp)
c0103893:	c0 
c0103894:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
c010389b:	00 
c010389c:	c7 04 24 d0 95 10 c0 	movl   $0xc01095d0,(%esp)
c01038a3:	e8 50 cb ff ff       	call   c01003f8 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
c01038a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01038ab:	83 e8 10             	sub    $0x10,%eax
c01038ae:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
c01038b1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01038b4:	8b 48 04             	mov    0x4(%eax),%ecx
c01038b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01038ba:	89 d0                	mov    %edx,%eax
c01038bc:	c1 e0 02             	shl    $0x2,%eax
c01038bf:	01 d0                	add    %edx,%eax
c01038c1:	39 c1                	cmp    %eax,%ecx
c01038c3:	75 17                	jne    c01038dc <check_vma_struct+0x1d2>
c01038c5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01038c8:	8b 48 08             	mov    0x8(%eax),%ecx
c01038cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01038ce:	89 d0                	mov    %edx,%eax
c01038d0:	c1 e0 02             	shl    $0x2,%eax
c01038d3:	01 d0                	add    %edx,%eax
c01038d5:	83 c0 02             	add    $0x2,%eax
c01038d8:	39 c1                	cmp    %eax,%ecx
c01038da:	74 24                	je     c0103900 <check_vma_struct+0x1f6>
c01038dc:	c7 44 24 0c ac 96 10 	movl   $0xc01096ac,0xc(%esp)
c01038e3:	c0 
c01038e4:	c7 44 24 08 bb 95 10 	movl   $0xc01095bb,0x8(%esp)
c01038eb:	c0 
c01038ec:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c01038f3:	00 
c01038f4:	c7 04 24 d0 95 10 c0 	movl   $0xc01095d0,(%esp)
c01038fb:	e8 f8 ca ff ff       	call   c01003f8 <__panic>
c0103900:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103903:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c0103906:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103909:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c010390c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (i = 1; i <= step2; i ++) {
c010390f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0103913:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103916:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0103919:	0f 8e 5d ff ff ff    	jle    c010387c <check_vma_struct+0x172>
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c010391f:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
c0103926:	e9 cd 01 00 00       	jmp    c0103af8 <check_vma_struct+0x3ee>
        struct vma_struct *vma1 = find_vma(mm, i);
c010392b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010392e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103932:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103935:	89 04 24             	mov    %eax,(%esp)
c0103938:	e8 68 fa ff ff       	call   c01033a5 <find_vma>
c010393d:	89 45 d0             	mov    %eax,-0x30(%ebp)
        assert(vma1 != NULL);
c0103940:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c0103944:	75 24                	jne    c010396a <check_vma_struct+0x260>
c0103946:	c7 44 24 0c e1 96 10 	movl   $0xc01096e1,0xc(%esp)
c010394d:	c0 
c010394e:	c7 44 24 08 bb 95 10 	movl   $0xc01095bb,0x8(%esp)
c0103955:	c0 
c0103956:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
c010395d:	00 
c010395e:	c7 04 24 d0 95 10 c0 	movl   $0xc01095d0,(%esp)
c0103965:	e8 8e ca ff ff       	call   c01003f8 <__panic>
        struct vma_struct *vma2 = find_vma(mm, i+1);
c010396a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010396d:	83 c0 01             	add    $0x1,%eax
c0103970:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103974:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103977:	89 04 24             	mov    %eax,(%esp)
c010397a:	e8 26 fa ff ff       	call   c01033a5 <find_vma>
c010397f:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(vma2 != NULL);
c0103982:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0103986:	75 24                	jne    c01039ac <check_vma_struct+0x2a2>
c0103988:	c7 44 24 0c ee 96 10 	movl   $0xc01096ee,0xc(%esp)
c010398f:	c0 
c0103990:	c7 44 24 08 bb 95 10 	movl   $0xc01095bb,0x8(%esp)
c0103997:	c0 
c0103998:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
c010399f:	00 
c01039a0:	c7 04 24 d0 95 10 c0 	movl   $0xc01095d0,(%esp)
c01039a7:	e8 4c ca ff ff       	call   c01003f8 <__panic>
        struct vma_struct *vma3 = find_vma(mm, i+2);
c01039ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039af:	83 c0 02             	add    $0x2,%eax
c01039b2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01039b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01039b9:	89 04 24             	mov    %eax,(%esp)
c01039bc:	e8 e4 f9 ff ff       	call   c01033a5 <find_vma>
c01039c1:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(vma3 == NULL);
c01039c4:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c01039c8:	74 24                	je     c01039ee <check_vma_struct+0x2e4>
c01039ca:	c7 44 24 0c fb 96 10 	movl   $0xc01096fb,0xc(%esp)
c01039d1:	c0 
c01039d2:	c7 44 24 08 bb 95 10 	movl   $0xc01095bb,0x8(%esp)
c01039d9:	c0 
c01039da:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c01039e1:	00 
c01039e2:	c7 04 24 d0 95 10 c0 	movl   $0xc01095d0,(%esp)
c01039e9:	e8 0a ca ff ff       	call   c01003f8 <__panic>
        struct vma_struct *vma4 = find_vma(mm, i+3);
c01039ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039f1:	83 c0 03             	add    $0x3,%eax
c01039f4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01039f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01039fb:	89 04 24             	mov    %eax,(%esp)
c01039fe:	e8 a2 f9 ff ff       	call   c01033a5 <find_vma>
c0103a03:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        assert(vma4 == NULL);
c0103a06:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
c0103a0a:	74 24                	je     c0103a30 <check_vma_struct+0x326>
c0103a0c:	c7 44 24 0c 08 97 10 	movl   $0xc0109708,0xc(%esp)
c0103a13:	c0 
c0103a14:	c7 44 24 08 bb 95 10 	movl   $0xc01095bb,0x8(%esp)
c0103a1b:	c0 
c0103a1c:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
c0103a23:	00 
c0103a24:	c7 04 24 d0 95 10 c0 	movl   $0xc01095d0,(%esp)
c0103a2b:	e8 c8 c9 ff ff       	call   c01003f8 <__panic>
        struct vma_struct *vma5 = find_vma(mm, i+4);
c0103a30:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a33:	83 c0 04             	add    $0x4,%eax
c0103a36:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103a3a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103a3d:	89 04 24             	mov    %eax,(%esp)
c0103a40:	e8 60 f9 ff ff       	call   c01033a5 <find_vma>
c0103a45:	89 45 c0             	mov    %eax,-0x40(%ebp)
        assert(vma5 == NULL);
c0103a48:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c0103a4c:	74 24                	je     c0103a72 <check_vma_struct+0x368>
c0103a4e:	c7 44 24 0c 15 97 10 	movl   $0xc0109715,0xc(%esp)
c0103a55:	c0 
c0103a56:	c7 44 24 08 bb 95 10 	movl   $0xc01095bb,0x8(%esp)
c0103a5d:	c0 
c0103a5e:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
c0103a65:	00 
c0103a66:	c7 04 24 d0 95 10 c0 	movl   $0xc01095d0,(%esp)
c0103a6d:	e8 86 c9 ff ff       	call   c01003f8 <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
c0103a72:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103a75:	8b 50 04             	mov    0x4(%eax),%edx
c0103a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a7b:	39 c2                	cmp    %eax,%edx
c0103a7d:	75 10                	jne    c0103a8f <check_vma_struct+0x385>
c0103a7f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103a82:	8b 50 08             	mov    0x8(%eax),%edx
c0103a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a88:	83 c0 02             	add    $0x2,%eax
c0103a8b:	39 c2                	cmp    %eax,%edx
c0103a8d:	74 24                	je     c0103ab3 <check_vma_struct+0x3a9>
c0103a8f:	c7 44 24 0c 24 97 10 	movl   $0xc0109724,0xc(%esp)
c0103a96:	c0 
c0103a97:	c7 44 24 08 bb 95 10 	movl   $0xc01095bb,0x8(%esp)
c0103a9e:	c0 
c0103a9f:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c0103aa6:	00 
c0103aa7:	c7 04 24 d0 95 10 c0 	movl   $0xc01095d0,(%esp)
c0103aae:	e8 45 c9 ff ff       	call   c01003f8 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
c0103ab3:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103ab6:	8b 50 04             	mov    0x4(%eax),%edx
c0103ab9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103abc:	39 c2                	cmp    %eax,%edx
c0103abe:	75 10                	jne    c0103ad0 <check_vma_struct+0x3c6>
c0103ac0:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103ac3:	8b 50 08             	mov    0x8(%eax),%edx
c0103ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ac9:	83 c0 02             	add    $0x2,%eax
c0103acc:	39 c2                	cmp    %eax,%edx
c0103ace:	74 24                	je     c0103af4 <check_vma_struct+0x3ea>
c0103ad0:	c7 44 24 0c 54 97 10 	movl   $0xc0109754,0xc(%esp)
c0103ad7:	c0 
c0103ad8:	c7 44 24 08 bb 95 10 	movl   $0xc01095bb,0x8(%esp)
c0103adf:	c0 
c0103ae0:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c0103ae7:	00 
c0103ae8:	c7 04 24 d0 95 10 c0 	movl   $0xc01095d0,(%esp)
c0103aef:	e8 04 c9 ff ff       	call   c01003f8 <__panic>
    for (i = 5; i <= 5 * step2; i +=5) {
c0103af4:	83 45 f4 05          	addl   $0x5,-0xc(%ebp)
c0103af8:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103afb:	89 d0                	mov    %edx,%eax
c0103afd:	c1 e0 02             	shl    $0x2,%eax
c0103b00:	01 d0                	add    %edx,%eax
c0103b02:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103b05:	0f 8d 20 fe ff ff    	jge    c010392b <check_vma_struct+0x221>
    }

    for (i =4; i>=0; i--) {
c0103b0b:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
c0103b12:	eb 70                	jmp    c0103b84 <check_vma_struct+0x47a>
        struct vma_struct *vma_below_5= find_vma(mm,i);
c0103b14:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b17:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103b1b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103b1e:	89 04 24             	mov    %eax,(%esp)
c0103b21:	e8 7f f8 ff ff       	call   c01033a5 <find_vma>
c0103b26:	89 45 bc             	mov    %eax,-0x44(%ebp)
        if (vma_below_5 != NULL ) {
c0103b29:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0103b2d:	74 27                	je     c0103b56 <check_vma_struct+0x44c>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
c0103b2f:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103b32:	8b 50 08             	mov    0x8(%eax),%edx
c0103b35:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103b38:	8b 40 04             	mov    0x4(%eax),%eax
c0103b3b:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0103b3f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103b43:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b46:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103b4a:	c7 04 24 84 97 10 c0 	movl   $0xc0109784,(%esp)
c0103b51:	e8 4b c7 ff ff       	call   c01002a1 <cprintf>
        }
        assert(vma_below_5 == NULL);
c0103b56:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0103b5a:	74 24                	je     c0103b80 <check_vma_struct+0x476>
c0103b5c:	c7 44 24 0c a9 97 10 	movl   $0xc01097a9,0xc(%esp)
c0103b63:	c0 
c0103b64:	c7 44 24 08 bb 95 10 	movl   $0xc01095bb,0x8(%esp)
c0103b6b:	c0 
c0103b6c:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
c0103b73:	00 
c0103b74:	c7 04 24 d0 95 10 c0 	movl   $0xc01095d0,(%esp)
c0103b7b:	e8 78 c8 ff ff       	call   c01003f8 <__panic>
    for (i =4; i>=0; i--) {
c0103b80:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0103b84:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103b88:	79 8a                	jns    c0103b14 <check_vma_struct+0x40a>
    }

    mm_destroy(mm);
c0103b8a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103b8d:	89 04 24             	mov    %eax,(%esp)
c0103b90:	e8 95 fa ff ff       	call   c010362a <mm_destroy>

    assert(nr_free_pages_store == nr_free_pages());
c0103b95:	e8 fd 2a 00 00       	call   c0106697 <nr_free_pages>
c0103b9a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103b9d:	74 24                	je     c0103bc3 <check_vma_struct+0x4b9>
c0103b9f:	c7 44 24 0c 3c 96 10 	movl   $0xc010963c,0xc(%esp)
c0103ba6:	c0 
c0103ba7:	c7 44 24 08 bb 95 10 	movl   $0xc01095bb,0x8(%esp)
c0103bae:	c0 
c0103baf:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c0103bb6:	00 
c0103bb7:	c7 04 24 d0 95 10 c0 	movl   $0xc01095d0,(%esp)
c0103bbe:	e8 35 c8 ff ff       	call   c01003f8 <__panic>

    cprintf("check_vma_struct() succeeded!\n");
c0103bc3:	c7 04 24 c0 97 10 c0 	movl   $0xc01097c0,(%esp)
c0103bca:	e8 d2 c6 ff ff       	call   c01002a1 <cprintf>
}
c0103bcf:	c9                   	leave  
c0103bd0:	c3                   	ret    

c0103bd1 <check_pgfault>:

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
c0103bd1:	55                   	push   %ebp
c0103bd2:	89 e5                	mov    %esp,%ebp
c0103bd4:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0103bd7:	e8 bb 2a 00 00       	call   c0106697 <nr_free_pages>
c0103bdc:	89 45 ec             	mov    %eax,-0x14(%ebp)

    check_mm_struct = mm_create();
c0103bdf:	e8 0e f7 ff ff       	call   c01032f2 <mm_create>
c0103be4:	a3 10 40 12 c0       	mov    %eax,0xc0124010
    assert(check_mm_struct != NULL);
c0103be9:	a1 10 40 12 c0       	mov    0xc0124010,%eax
c0103bee:	85 c0                	test   %eax,%eax
c0103bf0:	75 24                	jne    c0103c16 <check_pgfault+0x45>
c0103bf2:	c7 44 24 0c df 97 10 	movl   $0xc01097df,0xc(%esp)
c0103bf9:	c0 
c0103bfa:	c7 44 24 08 bb 95 10 	movl   $0xc01095bb,0x8(%esp)
c0103c01:	c0 
c0103c02:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
c0103c09:	00 
c0103c0a:	c7 04 24 d0 95 10 c0 	movl   $0xc01095d0,(%esp)
c0103c11:	e8 e2 c7 ff ff       	call   c01003f8 <__panic>

    struct mm_struct *mm = check_mm_struct;
c0103c16:	a1 10 40 12 c0       	mov    0xc0124010,%eax
c0103c1b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
c0103c1e:	8b 15 00 0a 12 c0    	mov    0xc0120a00,%edx
c0103c24:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103c27:	89 50 0c             	mov    %edx,0xc(%eax)
c0103c2a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103c2d:	8b 40 0c             	mov    0xc(%eax),%eax
c0103c30:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(pgdir[0] == 0);
c0103c33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103c36:	8b 00                	mov    (%eax),%eax
c0103c38:	85 c0                	test   %eax,%eax
c0103c3a:	74 24                	je     c0103c60 <check_pgfault+0x8f>
c0103c3c:	c7 44 24 0c f7 97 10 	movl   $0xc01097f7,0xc(%esp)
c0103c43:	c0 
c0103c44:	c7 44 24 08 bb 95 10 	movl   $0xc01095bb,0x8(%esp)
c0103c4b:	c0 
c0103c4c:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c0103c53:	00 
c0103c54:	c7 04 24 d0 95 10 c0 	movl   $0xc01095d0,(%esp)
c0103c5b:	e8 98 c7 ff ff       	call   c01003f8 <__panic>

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
c0103c60:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
c0103c67:	00 
c0103c68:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
c0103c6f:	00 
c0103c70:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0103c77:	e8 ee f6 ff ff       	call   c010336a <vma_create>
c0103c7c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(vma != NULL);
c0103c7f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0103c83:	75 24                	jne    c0103ca9 <check_pgfault+0xd8>
c0103c85:	c7 44 24 0c 86 96 10 	movl   $0xc0109686,0xc(%esp)
c0103c8c:	c0 
c0103c8d:	c7 44 24 08 bb 95 10 	movl   $0xc01095bb,0x8(%esp)
c0103c94:	c0 
c0103c95:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c0103c9c:	00 
c0103c9d:	c7 04 24 d0 95 10 c0 	movl   $0xc01095d0,(%esp)
c0103ca4:	e8 4f c7 ff ff       	call   c01003f8 <__panic>

    insert_vma_struct(mm, vma);
c0103ca9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103cac:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103cb0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103cb3:	89 04 24             	mov    %eax,(%esp)
c0103cb6:	e8 3f f8 ff ff       	call   c01034fa <insert_vma_struct>

    uintptr_t addr = 0x100;
c0103cbb:	c7 45 dc 00 01 00 00 	movl   $0x100,-0x24(%ebp)
    assert(find_vma(mm, addr) == vma);
c0103cc2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103cc5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103cc9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103ccc:	89 04 24             	mov    %eax,(%esp)
c0103ccf:	e8 d1 f6 ff ff       	call   c01033a5 <find_vma>
c0103cd4:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0103cd7:	74 24                	je     c0103cfd <check_pgfault+0x12c>
c0103cd9:	c7 44 24 0c 05 98 10 	movl   $0xc0109805,0xc(%esp)
c0103ce0:	c0 
c0103ce1:	c7 44 24 08 bb 95 10 	movl   $0xc01095bb,0x8(%esp)
c0103ce8:	c0 
c0103ce9:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c0103cf0:	00 
c0103cf1:	c7 04 24 d0 95 10 c0 	movl   $0xc01095d0,(%esp)
c0103cf8:	e8 fb c6 ff ff       	call   c01003f8 <__panic>

    int i, sum = 0;
c0103cfd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0103d04:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103d0b:	eb 17                	jmp    c0103d24 <check_pgfault+0x153>
        *(char *)(addr + i) = i;
c0103d0d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103d10:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103d13:	01 d0                	add    %edx,%eax
c0103d15:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103d18:	88 10                	mov    %dl,(%eax)
        sum += i;
c0103d1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103d1d:	01 45 f0             	add    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0103d20:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0103d24:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0103d28:	7e e3                	jle    c0103d0d <check_pgfault+0x13c>
    }
    for (i = 0; i < 100; i ++) {
c0103d2a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103d31:	eb 15                	jmp    c0103d48 <check_pgfault+0x177>
        sum -= *(char *)(addr + i);
c0103d33:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103d36:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103d39:	01 d0                	add    %edx,%eax
c0103d3b:	0f b6 00             	movzbl (%eax),%eax
c0103d3e:	0f be c0             	movsbl %al,%eax
c0103d41:	29 45 f0             	sub    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0103d44:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0103d48:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0103d4c:	7e e5                	jle    c0103d33 <check_pgfault+0x162>
    }
    assert(sum == 0);
c0103d4e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103d52:	74 24                	je     c0103d78 <check_pgfault+0x1a7>
c0103d54:	c7 44 24 0c 1f 98 10 	movl   $0xc010981f,0xc(%esp)
c0103d5b:	c0 
c0103d5c:	c7 44 24 08 bb 95 10 	movl   $0xc01095bb,0x8(%esp)
c0103d63:	c0 
c0103d64:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
c0103d6b:	00 
c0103d6c:	c7 04 24 d0 95 10 c0 	movl   $0xc01095d0,(%esp)
c0103d73:	e8 80 c6 ff ff       	call   c01003f8 <__panic>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
c0103d78:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103d7b:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0103d7e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103d81:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103d86:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103d8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103d8d:	89 04 24             	mov    %eax,(%esp)
c0103d90:	e8 3c 31 00 00       	call   c0106ed1 <page_remove>
    free_page(pde2page(pgdir[0]));
c0103d95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103d98:	8b 00                	mov    (%eax),%eax
c0103d9a:	89 04 24             	mov    %eax,(%esp)
c0103d9d:	e8 38 f5 ff ff       	call   c01032da <pde2page>
c0103da2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103da9:	00 
c0103daa:	89 04 24             	mov    %eax,(%esp)
c0103dad:	e8 b3 28 00 00       	call   c0106665 <free_pages>
    pgdir[0] = 0;
c0103db2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103db5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    mm->pgdir = NULL;
c0103dbb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103dbe:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    mm_destroy(mm);
c0103dc5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103dc8:	89 04 24             	mov    %eax,(%esp)
c0103dcb:	e8 5a f8 ff ff       	call   c010362a <mm_destroy>
    check_mm_struct = NULL;
c0103dd0:	c7 05 10 40 12 c0 00 	movl   $0x0,0xc0124010
c0103dd7:	00 00 00 

    assert(nr_free_pages_store == nr_free_pages());
c0103dda:	e8 b8 28 00 00       	call   c0106697 <nr_free_pages>
c0103ddf:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103de2:	74 24                	je     c0103e08 <check_pgfault+0x237>
c0103de4:	c7 44 24 0c 3c 96 10 	movl   $0xc010963c,0xc(%esp)
c0103deb:	c0 
c0103dec:	c7 44 24 08 bb 95 10 	movl   $0xc01095bb,0x8(%esp)
c0103df3:	c0 
c0103df4:	c7 44 24 04 14 01 00 	movl   $0x114,0x4(%esp)
c0103dfb:	00 
c0103dfc:	c7 04 24 d0 95 10 c0 	movl   $0xc01095d0,(%esp)
c0103e03:	e8 f0 c5 ff ff       	call   c01003f8 <__panic>

    cprintf("check_pgfault() succeeded!\n");
c0103e08:	c7 04 24 28 98 10 c0 	movl   $0xc0109828,(%esp)
c0103e0f:	e8 8d c4 ff ff       	call   c01002a1 <cprintf>
}
c0103e14:	c9                   	leave  
c0103e15:	c3                   	ret    

c0103e16 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
c0103e16:	55                   	push   %ebp
c0103e17:	89 e5                	mov    %esp,%ebp
c0103e19:	83 ec 38             	sub    $0x38,%esp
    int ret = -E_INVAL;
c0103e1c:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
c0103e23:	8b 45 10             	mov    0x10(%ebp),%eax
c0103e26:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103e2a:	8b 45 08             	mov    0x8(%ebp),%eax
c0103e2d:	89 04 24             	mov    %eax,(%esp)
c0103e30:	e8 70 f5 ff ff       	call   c01033a5 <find_vma>
c0103e35:	89 45 ec             	mov    %eax,-0x14(%ebp)

    pgfault_num++;
c0103e38:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c0103e3d:	83 c0 01             	add    $0x1,%eax
c0103e40:	a3 64 3f 12 c0       	mov    %eax,0xc0123f64
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
c0103e45:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103e49:	74 0b                	je     c0103e56 <do_pgfault+0x40>
c0103e4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103e4e:	8b 40 04             	mov    0x4(%eax),%eax
c0103e51:	3b 45 10             	cmp    0x10(%ebp),%eax
c0103e54:	76 18                	jbe    c0103e6e <do_pgfault+0x58>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
c0103e56:	8b 45 10             	mov    0x10(%ebp),%eax
c0103e59:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103e5d:	c7 04 24 44 98 10 c0 	movl   $0xc0109844,(%esp)
c0103e64:	e8 38 c4 ff ff       	call   c01002a1 <cprintf>
        goto failed;
c0103e69:	e9 bb 01 00 00       	jmp    c0104029 <do_pgfault+0x213>
    }
    //check the error_code
    switch (error_code & 3) {
c0103e6e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103e71:	83 e0 03             	and    $0x3,%eax
c0103e74:	85 c0                	test   %eax,%eax
c0103e76:	74 36                	je     c0103eae <do_pgfault+0x98>
c0103e78:	83 f8 01             	cmp    $0x1,%eax
c0103e7b:	74 20                	je     c0103e9d <do_pgfault+0x87>
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
c0103e7d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103e80:	8b 40 0c             	mov    0xc(%eax),%eax
c0103e83:	83 e0 02             	and    $0x2,%eax
c0103e86:	85 c0                	test   %eax,%eax
c0103e88:	75 11                	jne    c0103e9b <do_pgfault+0x85>
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
c0103e8a:	c7 04 24 74 98 10 c0 	movl   $0xc0109874,(%esp)
c0103e91:	e8 0b c4 ff ff       	call   c01002a1 <cprintf>
            goto failed;
c0103e96:	e9 8e 01 00 00       	jmp    c0104029 <do_pgfault+0x213>
        }
        break;
c0103e9b:	eb 2f                	jmp    c0103ecc <do_pgfault+0xb6>
    case 1: /* error code flag : (W/R=0, P=1): read, present */
        cprintf("do_pgfault failed: error code flag = read AND present\n");
c0103e9d:	c7 04 24 d4 98 10 c0 	movl   $0xc01098d4,(%esp)
c0103ea4:	e8 f8 c3 ff ff       	call   c01002a1 <cprintf>
        goto failed;
c0103ea9:	e9 7b 01 00 00       	jmp    c0104029 <do_pgfault+0x213>
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
c0103eae:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103eb1:	8b 40 0c             	mov    0xc(%eax),%eax
c0103eb4:	83 e0 05             	and    $0x5,%eax
c0103eb7:	85 c0                	test   %eax,%eax
c0103eb9:	75 11                	jne    c0103ecc <do_pgfault+0xb6>
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
c0103ebb:	c7 04 24 0c 99 10 c0 	movl   $0xc010990c,(%esp)
c0103ec2:	e8 da c3 ff ff       	call   c01002a1 <cprintf>
            goto failed;
c0103ec7:	e9 5d 01 00 00       	jmp    c0104029 <do_pgfault+0x213>
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
c0103ecc:	c7 45 f0 04 00 00 00 	movl   $0x4,-0x10(%ebp)
    if (vma->vm_flags & VM_WRITE) {
c0103ed3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103ed6:	8b 40 0c             	mov    0xc(%eax),%eax
c0103ed9:	83 e0 02             	and    $0x2,%eax
c0103edc:	85 c0                	test   %eax,%eax
c0103ede:	74 04                	je     c0103ee4 <do_pgfault+0xce>
        perm |= PTE_W;
c0103ee0:	83 4d f0 02          	orl    $0x2,-0x10(%ebp)
    }
    addr = ROUNDDOWN(addr, PGSIZE);
c0103ee4:	8b 45 10             	mov    0x10(%ebp),%eax
c0103ee7:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103eea:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103eed:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103ef2:	89 45 10             	mov    %eax,0x10(%ebp)

    ret = -E_NO_MEM;
c0103ef5:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    pte_t *ptep=NULL;
c0103efc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    *   mm->pgdir : the PDT of these vma
    *
    */
//try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
	//检查页表中是否有相应的应用程序需要的表项，有就获取指向这个表项的指针
	if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
c0103f03:	8b 45 08             	mov    0x8(%ebp),%eax
c0103f06:	8b 40 0c             	mov    0xc(%eax),%eax
c0103f09:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0103f10:	00 
c0103f11:	8b 55 10             	mov    0x10(%ebp),%edx
c0103f14:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103f18:	89 04 24             	mov    %eax,(%esp)
c0103f1b:	e8 b9 2d 00 00       	call   c0106cd9 <get_pte>
c0103f20:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103f23:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103f27:	75 11                	jne    c0103f3a <do_pgfault+0x124>
        cprintf("get_pte in do_pgfault failed\n");
c0103f29:	c7 04 24 6f 99 10 c0 	movl   $0xc010996f,(%esp)
c0103f30:	e8 6c c3 ff ff       	call   c01002a1 <cprintf>
        goto failed;
c0103f35:	e9 ef 00 00 00       	jmp    c0104029 <do_pgfault+0x213>
    }
	//然后检查这个表项是否为空(是否被映射)，如果为空，pgdir_alloc_page分配一个新的物理页
    if (*ptep == 0) {  
c0103f3a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103f3d:	8b 00                	mov    (%eax),%eax
c0103f3f:	85 c0                	test   %eax,%eax
c0103f41:	75 35                	jne    c0103f78 <do_pgfault+0x162>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
c0103f43:	8b 45 08             	mov    0x8(%ebp),%eax
c0103f46:	8b 40 0c             	mov    0xc(%eax),%eax
c0103f49:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0103f4c:	89 54 24 08          	mov    %edx,0x8(%esp)
c0103f50:	8b 55 10             	mov    0x10(%ebp),%edx
c0103f53:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103f57:	89 04 24             	mov    %eax,(%esp)
c0103f5a:	e8 cc 30 00 00       	call   c010702b <pgdir_alloc_page>
c0103f5f:	85 c0                	test   %eax,%eax
c0103f61:	0f 85 bb 00 00 00    	jne    c0104022 <do_pgfault+0x20c>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
c0103f67:	c7 04 24 90 99 10 c0 	movl   $0xc0109990,(%esp)
c0103f6e:	e8 2e c3 ff ff       	call   c01002a1 <cprintf>
            goto failed;
c0103f73:	e9 b1 00 00 00       	jmp    c0104029 <do_pgfault+0x213>
        }
    }
 //如果这个页表项非空，那么说明这一页已经映射过了但是被保存在磁盘中，需要将这一页内存交换出来
// if this pte is a swap entry, then load data from disk to a page with phy addr and call page_insert to map the phy addr with logical addr
    else {   
        if(swap_init_ok) {
c0103f78:	a1 68 3f 12 c0       	mov    0xc0123f68,%eax
c0103f7d:	85 c0                	test   %eax,%eax
c0103f7f:	0f 84 86 00 00 00    	je     c010400b <do_pgfault+0x1f5>
            //如果可以交换
            struct Page *page=NULL; 
c0103f85:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
            //根据mm结构和addr地址，尝试将硬盘中的内容换入至page中
            //load the content of right disk page into the memory which page managed.
            if ((ret = swap_in(mm, addr, &page)) != 0) {
c0103f8c:	8d 45 e0             	lea    -0x20(%ebp),%eax
c0103f8f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103f93:	8b 45 10             	mov    0x10(%ebp),%eax
c0103f96:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103f9a:	8b 45 08             	mov    0x8(%ebp),%eax
c0103f9d:	89 04 24             	mov    %eax,(%esp)
c0103fa0:	e8 db 08 00 00       	call   c0104880 <swap_in>
c0103fa5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103fa8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103fac:	74 0e                	je     c0103fbc <do_pgfault+0x1a6>
                cprintf("swap_in in do_pgfault failed\n");
c0103fae:	c7 04 24 b7 99 10 c0 	movl   $0xc01099b7,(%esp)
c0103fb5:	e8 e7 c2 ff ff       	call   c01002a1 <cprintf>
c0103fba:	eb 6d                	jmp    c0104029 <do_pgfault+0x213>
                goto failed;
            }    
            page_insert(mm->pgdir, page, addr, perm); 
c0103fbc:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103fbf:	8b 45 08             	mov    0x8(%ebp),%eax
c0103fc2:	8b 40 0c             	mov    0xc(%eax),%eax
c0103fc5:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0103fc8:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0103fcc:	8b 4d 10             	mov    0x10(%ebp),%ecx
c0103fcf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0103fd3:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103fd7:	89 04 24             	mov    %eax,(%esp)
c0103fda:	e8 36 2f 00 00       	call   c0106f15 <page_insert>
            //建立虚拟地址和物理地址之间的对应关系 According to the mm, addr AND page, setup the map of phy addr <---> logical addr
            swap_map_swappable(mm, addr, page, 1); 
c0103fdf:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103fe2:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c0103fe9:	00 
c0103fea:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103fee:	8b 45 10             	mov    0x10(%ebp),%eax
c0103ff1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103ff5:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ff8:	89 04 24             	mov    %eax,(%esp)
c0103ffb:	e8 b7 06 00 00       	call   c01046b7 <swap_map_swappable>
            //将此页面设置为可交换的 make the page swappable.  
            page->pra_vaddr = addr;
c0104000:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104003:	8b 55 10             	mov    0x10(%ebp),%edx
c0104006:	89 50 1c             	mov    %edx,0x1c(%eax)
c0104009:	eb 17                	jmp    c0104022 <do_pgfault+0x20c>
        }
        else {
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
c010400b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010400e:	8b 00                	mov    (%eax),%eax
c0104010:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104014:	c7 04 24 d8 99 10 c0 	movl   $0xc01099d8,(%esp)
c010401b:	e8 81 c2 ff ff       	call   c01002a1 <cprintf>
            goto failed;
c0104020:	eb 07                	jmp    c0104029 <do_pgfault+0x213>
        }
   }
   ret = 0;
c0104022:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
failed:
    return ret;
c0104029:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010402c:	c9                   	leave  
c010402d:	c3                   	ret    

c010402e <_fifo_init_mm>:
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
c010402e:	55                   	push   %ebp
c010402f:	89 e5                	mov    %esp,%ebp
c0104031:	83 ec 10             	sub    $0x10,%esp
c0104034:	c7 45 fc 14 40 12 c0 	movl   $0xc0124014,-0x4(%ebp)
    elm->prev = elm->next = elm;
c010403b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010403e:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0104041:	89 50 04             	mov    %edx,0x4(%eax)
c0104044:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104047:	8b 50 04             	mov    0x4(%eax),%edx
c010404a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010404d:	89 10                	mov    %edx,(%eax)
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
c010404f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104052:	c7 40 14 14 40 12 c0 	movl   $0xc0124014,0x14(%eax)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
c0104059:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010405e:	c9                   	leave  
c010405f:	c3                   	ret    

c0104060 <_fifo_map_swappable>:
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0104060:	55                   	push   %ebp
c0104061:	89 e5                	mov    %esp,%ebp
c0104063:	83 ec 48             	sub    $0x48,%esp
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0104066:	8b 45 08             	mov    0x8(%ebp),%eax
c0104069:	8b 40 14             	mov    0x14(%eax),%eax
c010406c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry=&(page->pra_page_link);
c010406f:	8b 45 10             	mov    0x10(%ebp),%eax
c0104072:	83 c0 14             	add    $0x14,%eax
c0104075:	89 45 f0             	mov    %eax,-0x10(%ebp)
 
    assert(entry != NULL && head != NULL);
c0104078:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010407c:	74 06                	je     c0104084 <_fifo_map_swappable+0x24>
c010407e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104082:	75 24                	jne    c01040a8 <_fifo_map_swappable+0x48>
c0104084:	c7 44 24 0c 00 9a 10 	movl   $0xc0109a00,0xc(%esp)
c010408b:	c0 
c010408c:	c7 44 24 08 1e 9a 10 	movl   $0xc0109a1e,0x8(%esp)
c0104093:	c0 
c0104094:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
c010409b:	00 
c010409c:	c7 04 24 33 9a 10 c0 	movl   $0xc0109a33,(%esp)
c01040a3:	e8 50 c3 ff ff       	call   c01003f8 <__panic>
c01040a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01040ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01040ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01040b1:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01040b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01040b7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01040ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01040bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_add(elm, listelm, listelm->next);
c01040c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01040c3:	8b 40 04             	mov    0x4(%eax),%eax
c01040c6:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01040c9:	89 55 dc             	mov    %edx,-0x24(%ebp)
c01040cc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01040cf:	89 55 d8             	mov    %edx,-0x28(%ebp)
c01040d2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    prev->next = next->prev = elm;
c01040d5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01040d8:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01040db:	89 10                	mov    %edx,(%eax)
c01040dd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01040e0:	8b 10                	mov    (%eax),%edx
c01040e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01040e5:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01040e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01040eb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01040ee:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01040f1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01040f4:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01040f7:	89 10                	mov    %edx,(%eax)
    //record the page access situlation
    /*LAB3 EXERCISE 2: YOUR CODE*/ 
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
    list_add(head, entry);
    return 0;
c01040f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01040fe:	c9                   	leave  
c01040ff:	c3                   	ret    

c0104100 <_fifo_swap_out_victim>:
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then assign the value of *ptr_page to the addr of this page.
 */
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
c0104100:	55                   	push   %ebp
c0104101:	89 e5                	mov    %esp,%ebp
c0104103:	83 ec 38             	sub    $0x38,%esp
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0104106:	8b 45 08             	mov    0x8(%ebp),%eax
c0104109:	8b 40 14             	mov    0x14(%eax),%eax
c010410c:	89 45 f4             	mov    %eax,-0xc(%ebp)
         assert(head != NULL);
c010410f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104113:	75 24                	jne    c0104139 <_fifo_swap_out_victim+0x39>
c0104115:	c7 44 24 0c 47 9a 10 	movl   $0xc0109a47,0xc(%esp)
c010411c:	c0 
c010411d:	c7 44 24 08 1e 9a 10 	movl   $0xc0109a1e,0x8(%esp)
c0104124:	c0 
c0104125:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
c010412c:	00 
c010412d:	c7 04 24 33 9a 10 c0 	movl   $0xc0109a33,(%esp)
c0104134:	e8 bf c2 ff ff       	call   c01003f8 <__panic>
     assert(in_tick==0);
c0104139:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010413d:	74 24                	je     c0104163 <_fifo_swap_out_victim+0x63>
c010413f:	c7 44 24 0c 54 9a 10 	movl   $0xc0109a54,0xc(%esp)
c0104146:	c0 
c0104147:	c7 44 24 08 1e 9a 10 	movl   $0xc0109a1e,0x8(%esp)
c010414e:	c0 
c010414f:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
c0104156:	00 
c0104157:	c7 04 24 33 9a 10 c0 	movl   $0xc0109a33,(%esp)
c010415e:	e8 95 c2 ff ff       	call   c01003f8 <__panic>
     /* Select the victim */
     /*LAB3 EXERCISE 2: YOUR CODE*/ 
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  assign the value of *ptr_page to the addr of this page
     //需要被换出的页
     list_entry_t *le = head->prev;
c0104163:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104166:	8b 00                	mov    (%eax),%eax
c0104168:	89 45 f0             	mov    %eax,-0x10(%ebp)
     assert(head!=le);
c010416b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010416e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104171:	75 24                	jne    c0104197 <_fifo_swap_out_victim+0x97>
c0104173:	c7 44 24 0c 5f 9a 10 	movl   $0xc0109a5f,0xc(%esp)
c010417a:	c0 
c010417b:	c7 44 24 08 1e 9a 10 	movl   $0xc0109a1e,0x8(%esp)
c0104182:	c0 
c0104183:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
c010418a:	00 
c010418b:	c7 04 24 33 9a 10 c0 	movl   $0xc0109a33,(%esp)
c0104192:	e8 61 c2 ff ff       	call   c01003f8 <__panic>
     //获得对应page的指针p
     struct Page *p = le2page(le, pra_page_link);
c0104197:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010419a:	83 e8 14             	sub    $0x14,%eax
c010419d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01041a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01041a3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    __list_del(listelm->prev, listelm->next);
c01041a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01041a9:	8b 40 04             	mov    0x4(%eax),%eax
c01041ac:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01041af:	8b 12                	mov    (%edx),%edx
c01041b1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c01041b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
    prev->next = next;
c01041b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01041ba:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01041bd:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01041c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01041c3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01041c6:	89 10                	mov    %edx,(%eax)
     //将最老的页面从队列中删除
     list_del(le);
     assert(p !=NULL);
c01041c8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01041cc:	75 24                	jne    c01041f2 <_fifo_swap_out_victim+0xf2>
c01041ce:	c7 44 24 0c 68 9a 10 	movl   $0xc0109a68,0xc(%esp)
c01041d5:	c0 
c01041d6:	c7 44 24 08 1e 9a 10 	movl   $0xc0109a1e,0x8(%esp)
c01041dd:	c0 
c01041de:	c7 44 24 04 4e 00 00 	movl   $0x4e,0x4(%esp)
c01041e5:	00 
c01041e6:	c7 04 24 33 9a 10 c0 	movl   $0xc0109a33,(%esp)
c01041ed:	e8 06 c2 ff ff       	call   c01003f8 <__panic>
     //将这一页的地址存储在ptr_page中
     *ptr_page = p;
c01041f2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01041f5:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01041f8:	89 10                	mov    %edx,(%eax)
     return 0;
c01041fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01041ff:	c9                   	leave  
c0104200:	c3                   	ret    

c0104201 <_fifo_check_swap>:

static int
_fifo_check_swap(void) {
c0104201:	55                   	push   %ebp
c0104202:	89 e5                	mov    %esp,%ebp
c0104204:	83 ec 18             	sub    $0x18,%esp
    cprintf("write Virt Page c in fifo_check_swap\n");
c0104207:	c7 04 24 74 9a 10 c0 	movl   $0xc0109a74,(%esp)
c010420e:	e8 8e c0 ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0104213:	b8 00 30 00 00       	mov    $0x3000,%eax
c0104218:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==4);
c010421b:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c0104220:	83 f8 04             	cmp    $0x4,%eax
c0104223:	74 24                	je     c0104249 <_fifo_check_swap+0x48>
c0104225:	c7 44 24 0c 9a 9a 10 	movl   $0xc0109a9a,0xc(%esp)
c010422c:	c0 
c010422d:	c7 44 24 08 1e 9a 10 	movl   $0xc0109a1e,0x8(%esp)
c0104234:	c0 
c0104235:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
c010423c:	00 
c010423d:	c7 04 24 33 9a 10 c0 	movl   $0xc0109a33,(%esp)
c0104244:	e8 af c1 ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0104249:	c7 04 24 ac 9a 10 c0 	movl   $0xc0109aac,(%esp)
c0104250:	e8 4c c0 ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0104255:	b8 00 10 00 00       	mov    $0x1000,%eax
c010425a:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==4);
c010425d:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c0104262:	83 f8 04             	cmp    $0x4,%eax
c0104265:	74 24                	je     c010428b <_fifo_check_swap+0x8a>
c0104267:	c7 44 24 0c 9a 9a 10 	movl   $0xc0109a9a,0xc(%esp)
c010426e:	c0 
c010426f:	c7 44 24 08 1e 9a 10 	movl   $0xc0109a1e,0x8(%esp)
c0104276:	c0 
c0104277:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c010427e:	00 
c010427f:	c7 04 24 33 9a 10 c0 	movl   $0xc0109a33,(%esp)
c0104286:	e8 6d c1 ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c010428b:	c7 04 24 d4 9a 10 c0 	movl   $0xc0109ad4,(%esp)
c0104292:	e8 0a c0 ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0104297:	b8 00 40 00 00       	mov    $0x4000,%eax
c010429c:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==4);
c010429f:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c01042a4:	83 f8 04             	cmp    $0x4,%eax
c01042a7:	74 24                	je     c01042cd <_fifo_check_swap+0xcc>
c01042a9:	c7 44 24 0c 9a 9a 10 	movl   $0xc0109a9a,0xc(%esp)
c01042b0:	c0 
c01042b1:	c7 44 24 08 1e 9a 10 	movl   $0xc0109a1e,0x8(%esp)
c01042b8:	c0 
c01042b9:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c01042c0:	00 
c01042c1:	c7 04 24 33 9a 10 c0 	movl   $0xc0109a33,(%esp)
c01042c8:	e8 2b c1 ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c01042cd:	c7 04 24 fc 9a 10 c0 	movl   $0xc0109afc,(%esp)
c01042d4:	e8 c8 bf ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c01042d9:	b8 00 20 00 00       	mov    $0x2000,%eax
c01042de:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==4);
c01042e1:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c01042e6:	83 f8 04             	cmp    $0x4,%eax
c01042e9:	74 24                	je     c010430f <_fifo_check_swap+0x10e>
c01042eb:	c7 44 24 0c 9a 9a 10 	movl   $0xc0109a9a,0xc(%esp)
c01042f2:	c0 
c01042f3:	c7 44 24 08 1e 9a 10 	movl   $0xc0109a1e,0x8(%esp)
c01042fa:	c0 
c01042fb:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c0104302:	00 
c0104303:	c7 04 24 33 9a 10 c0 	movl   $0xc0109a33,(%esp)
c010430a:	e8 e9 c0 ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c010430f:	c7 04 24 24 9b 10 c0 	movl   $0xc0109b24,(%esp)
c0104316:	e8 86 bf ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c010431b:	b8 00 50 00 00       	mov    $0x5000,%eax
c0104320:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==5);
c0104323:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c0104328:	83 f8 05             	cmp    $0x5,%eax
c010432b:	74 24                	je     c0104351 <_fifo_check_swap+0x150>
c010432d:	c7 44 24 0c 4a 9b 10 	movl   $0xc0109b4a,0xc(%esp)
c0104334:	c0 
c0104335:	c7 44 24 08 1e 9a 10 	movl   $0xc0109a1e,0x8(%esp)
c010433c:	c0 
c010433d:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0104344:	00 
c0104345:	c7 04 24 33 9a 10 c0 	movl   $0xc0109a33,(%esp)
c010434c:	e8 a7 c0 ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0104351:	c7 04 24 fc 9a 10 c0 	movl   $0xc0109afc,(%esp)
c0104358:	e8 44 bf ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c010435d:	b8 00 20 00 00       	mov    $0x2000,%eax
c0104362:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==5);
c0104365:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c010436a:	83 f8 05             	cmp    $0x5,%eax
c010436d:	74 24                	je     c0104393 <_fifo_check_swap+0x192>
c010436f:	c7 44 24 0c 4a 9b 10 	movl   $0xc0109b4a,0xc(%esp)
c0104376:	c0 
c0104377:	c7 44 24 08 1e 9a 10 	movl   $0xc0109a1e,0x8(%esp)
c010437e:	c0 
c010437f:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c0104386:	00 
c0104387:	c7 04 24 33 9a 10 c0 	movl   $0xc0109a33,(%esp)
c010438e:	e8 65 c0 ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0104393:	c7 04 24 ac 9a 10 c0 	movl   $0xc0109aac,(%esp)
c010439a:	e8 02 bf ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c010439f:	b8 00 10 00 00       	mov    $0x1000,%eax
c01043a4:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==6);
c01043a7:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c01043ac:	83 f8 06             	cmp    $0x6,%eax
c01043af:	74 24                	je     c01043d5 <_fifo_check_swap+0x1d4>
c01043b1:	c7 44 24 0c 59 9b 10 	movl   $0xc0109b59,0xc(%esp)
c01043b8:	c0 
c01043b9:	c7 44 24 08 1e 9a 10 	movl   $0xc0109a1e,0x8(%esp)
c01043c0:	c0 
c01043c1:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c01043c8:	00 
c01043c9:	c7 04 24 33 9a 10 c0 	movl   $0xc0109a33,(%esp)
c01043d0:	e8 23 c0 ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c01043d5:	c7 04 24 fc 9a 10 c0 	movl   $0xc0109afc,(%esp)
c01043dc:	e8 c0 be ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c01043e1:	b8 00 20 00 00       	mov    $0x2000,%eax
c01043e6:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==7);
c01043e9:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c01043ee:	83 f8 07             	cmp    $0x7,%eax
c01043f1:	74 24                	je     c0104417 <_fifo_check_swap+0x216>
c01043f3:	c7 44 24 0c 68 9b 10 	movl   $0xc0109b68,0xc(%esp)
c01043fa:	c0 
c01043fb:	c7 44 24 08 1e 9a 10 	movl   $0xc0109a1e,0x8(%esp)
c0104402:	c0 
c0104403:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c010440a:	00 
c010440b:	c7 04 24 33 9a 10 c0 	movl   $0xc0109a33,(%esp)
c0104412:	e8 e1 bf ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c0104417:	c7 04 24 74 9a 10 c0 	movl   $0xc0109a74,(%esp)
c010441e:	e8 7e be ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0104423:	b8 00 30 00 00       	mov    $0x3000,%eax
c0104428:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==8);
c010442b:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c0104430:	83 f8 08             	cmp    $0x8,%eax
c0104433:	74 24                	je     c0104459 <_fifo_check_swap+0x258>
c0104435:	c7 44 24 0c 77 9b 10 	movl   $0xc0109b77,0xc(%esp)
c010443c:	c0 
c010443d:	c7 44 24 08 1e 9a 10 	movl   $0xc0109a1e,0x8(%esp)
c0104444:	c0 
c0104445:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c010444c:	00 
c010444d:	c7 04 24 33 9a 10 c0 	movl   $0xc0109a33,(%esp)
c0104454:	e8 9f bf ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0104459:	c7 04 24 d4 9a 10 c0 	movl   $0xc0109ad4,(%esp)
c0104460:	e8 3c be ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0104465:	b8 00 40 00 00       	mov    $0x4000,%eax
c010446a:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==9);
c010446d:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c0104472:	83 f8 09             	cmp    $0x9,%eax
c0104475:	74 24                	je     c010449b <_fifo_check_swap+0x29a>
c0104477:	c7 44 24 0c 86 9b 10 	movl   $0xc0109b86,0xc(%esp)
c010447e:	c0 
c010447f:	c7 44 24 08 1e 9a 10 	movl   $0xc0109a1e,0x8(%esp)
c0104486:	c0 
c0104487:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
c010448e:	00 
c010448f:	c7 04 24 33 9a 10 c0 	movl   $0xc0109a33,(%esp)
c0104496:	e8 5d bf ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c010449b:	c7 04 24 24 9b 10 c0 	movl   $0xc0109b24,(%esp)
c01044a2:	e8 fa bd ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c01044a7:	b8 00 50 00 00       	mov    $0x5000,%eax
c01044ac:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==10);
c01044af:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c01044b4:	83 f8 0a             	cmp    $0xa,%eax
c01044b7:	74 24                	je     c01044dd <_fifo_check_swap+0x2dc>
c01044b9:	c7 44 24 0c 95 9b 10 	movl   $0xc0109b95,0xc(%esp)
c01044c0:	c0 
c01044c1:	c7 44 24 08 1e 9a 10 	movl   $0xc0109a1e,0x8(%esp)
c01044c8:	c0 
c01044c9:	c7 44 24 04 76 00 00 	movl   $0x76,0x4(%esp)
c01044d0:	00 
c01044d1:	c7 04 24 33 9a 10 c0 	movl   $0xc0109a33,(%esp)
c01044d8:	e8 1b bf ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c01044dd:	c7 04 24 ac 9a 10 c0 	movl   $0xc0109aac,(%esp)
c01044e4:	e8 b8 bd ff ff       	call   c01002a1 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
c01044e9:	b8 00 10 00 00       	mov    $0x1000,%eax
c01044ee:	0f b6 00             	movzbl (%eax),%eax
c01044f1:	3c 0a                	cmp    $0xa,%al
c01044f3:	74 24                	je     c0104519 <_fifo_check_swap+0x318>
c01044f5:	c7 44 24 0c a8 9b 10 	movl   $0xc0109ba8,0xc(%esp)
c01044fc:	c0 
c01044fd:	c7 44 24 08 1e 9a 10 	movl   $0xc0109a1e,0x8(%esp)
c0104504:	c0 
c0104505:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
c010450c:	00 
c010450d:	c7 04 24 33 9a 10 c0 	movl   $0xc0109a33,(%esp)
c0104514:	e8 df be ff ff       	call   c01003f8 <__panic>
    *(unsigned char *)0x1000 = 0x0a;
c0104519:	b8 00 10 00 00       	mov    $0x1000,%eax
c010451e:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==11);
c0104521:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c0104526:	83 f8 0b             	cmp    $0xb,%eax
c0104529:	74 24                	je     c010454f <_fifo_check_swap+0x34e>
c010452b:	c7 44 24 0c c9 9b 10 	movl   $0xc0109bc9,0xc(%esp)
c0104532:	c0 
c0104533:	c7 44 24 08 1e 9a 10 	movl   $0xc0109a1e,0x8(%esp)
c010453a:	c0 
c010453b:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
c0104542:	00 
c0104543:	c7 04 24 33 9a 10 c0 	movl   $0xc0109a33,(%esp)
c010454a:	e8 a9 be ff ff       	call   c01003f8 <__panic>
    return 0;
c010454f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104554:	c9                   	leave  
c0104555:	c3                   	ret    

c0104556 <_fifo_init>:


static int
_fifo_init(void)
{
c0104556:	55                   	push   %ebp
c0104557:	89 e5                	mov    %esp,%ebp
    return 0;
c0104559:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010455e:	5d                   	pop    %ebp
c010455f:	c3                   	ret    

c0104560 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c0104560:	55                   	push   %ebp
c0104561:	89 e5                	mov    %esp,%ebp
    return 0;
c0104563:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104568:	5d                   	pop    %ebp
c0104569:	c3                   	ret    

c010456a <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
c010456a:	55                   	push   %ebp
c010456b:	89 e5                	mov    %esp,%ebp
c010456d:	b8 00 00 00 00       	mov    $0x0,%eax
c0104572:	5d                   	pop    %ebp
c0104573:	c3                   	ret    

c0104574 <pa2page>:
pa2page(uintptr_t pa) {
c0104574:	55                   	push   %ebp
c0104575:	89 e5                	mov    %esp,%ebp
c0104577:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c010457a:	8b 45 08             	mov    0x8(%ebp),%eax
c010457d:	c1 e8 0c             	shr    $0xc,%eax
c0104580:	89 c2                	mov    %eax,%edx
c0104582:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c0104587:	39 c2                	cmp    %eax,%edx
c0104589:	72 1c                	jb     c01045a7 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c010458b:	c7 44 24 08 ec 9b 10 	movl   $0xc0109bec,0x8(%esp)
c0104592:	c0 
c0104593:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c010459a:	00 
c010459b:	c7 04 24 0b 9c 10 c0 	movl   $0xc0109c0b,(%esp)
c01045a2:	e8 51 be ff ff       	call   c01003f8 <__panic>
    return &pages[PPN(pa)];
c01045a7:	a1 f8 40 12 c0       	mov    0xc01240f8,%eax
c01045ac:	8b 55 08             	mov    0x8(%ebp),%edx
c01045af:	c1 ea 0c             	shr    $0xc,%edx
c01045b2:	c1 e2 05             	shl    $0x5,%edx
c01045b5:	01 d0                	add    %edx,%eax
}
c01045b7:	c9                   	leave  
c01045b8:	c3                   	ret    

c01045b9 <pte2page>:
pte2page(pte_t pte) {
c01045b9:	55                   	push   %ebp
c01045ba:	89 e5                	mov    %esp,%ebp
c01045bc:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c01045bf:	8b 45 08             	mov    0x8(%ebp),%eax
c01045c2:	83 e0 01             	and    $0x1,%eax
c01045c5:	85 c0                	test   %eax,%eax
c01045c7:	75 1c                	jne    c01045e5 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c01045c9:	c7 44 24 08 1c 9c 10 	movl   $0xc0109c1c,0x8(%esp)
c01045d0:	c0 
c01045d1:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c01045d8:	00 
c01045d9:	c7 04 24 0b 9c 10 c0 	movl   $0xc0109c0b,(%esp)
c01045e0:	e8 13 be ff ff       	call   c01003f8 <__panic>
    return pa2page(PTE_ADDR(pte));
c01045e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01045e8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01045ed:	89 04 24             	mov    %eax,(%esp)
c01045f0:	e8 7f ff ff ff       	call   c0104574 <pa2page>
}
c01045f5:	c9                   	leave  
c01045f6:	c3                   	ret    

c01045f7 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
c01045f7:	55                   	push   %ebp
c01045f8:	89 e5                	mov    %esp,%ebp
c01045fa:	83 ec 28             	sub    $0x28,%esp
     swapfs_init();
c01045fd:	e8 60 39 00 00       	call   c0107f62 <swapfs_init>

     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
c0104602:	a1 bc 40 12 c0       	mov    0xc01240bc,%eax
c0104607:	3d ff 03 00 00       	cmp    $0x3ff,%eax
c010460c:	76 0c                	jbe    c010461a <swap_init+0x23>
c010460e:	a1 bc 40 12 c0       	mov    0xc01240bc,%eax
c0104613:	3d ff ff ff 00       	cmp    $0xffffff,%eax
c0104618:	76 25                	jbe    c010463f <swap_init+0x48>
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
c010461a:	a1 bc 40 12 c0       	mov    0xc01240bc,%eax
c010461f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104623:	c7 44 24 08 3d 9c 10 	movl   $0xc0109c3d,0x8(%esp)
c010462a:	c0 
c010462b:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
c0104632:	00 
c0104633:	c7 04 24 58 9c 10 c0 	movl   $0xc0109c58,(%esp)
c010463a:	e8 b9 bd ff ff       	call   c01003f8 <__panic>
     }
     

     sm = &swap_manager_fifo;
c010463f:	c7 05 70 3f 12 c0 e0 	movl   $0xc01209e0,0xc0123f70
c0104646:	09 12 c0 
     int r = sm->init();
c0104649:	a1 70 3f 12 c0       	mov    0xc0123f70,%eax
c010464e:	8b 40 04             	mov    0x4(%eax),%eax
c0104651:	ff d0                	call   *%eax
c0104653:	89 45 f4             	mov    %eax,-0xc(%ebp)
     
     if (r == 0)
c0104656:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010465a:	75 26                	jne    c0104682 <swap_init+0x8b>
     {
          swap_init_ok = 1;
c010465c:	c7 05 68 3f 12 c0 01 	movl   $0x1,0xc0123f68
c0104663:	00 00 00 
          cprintf("SWAP: manager = %s\n", sm->name);
c0104666:	a1 70 3f 12 c0       	mov    0xc0123f70,%eax
c010466b:	8b 00                	mov    (%eax),%eax
c010466d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104671:	c7 04 24 67 9c 10 c0 	movl   $0xc0109c67,(%esp)
c0104678:	e8 24 bc ff ff       	call   c01002a1 <cprintf>
          check_swap();
c010467d:	e8 a4 04 00 00       	call   c0104b26 <check_swap>
     }

     return r;
c0104682:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104685:	c9                   	leave  
c0104686:	c3                   	ret    

c0104687 <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
c0104687:	55                   	push   %ebp
c0104688:	89 e5                	mov    %esp,%ebp
c010468a:	83 ec 18             	sub    $0x18,%esp
     return sm->init_mm(mm);
c010468d:	a1 70 3f 12 c0       	mov    0xc0123f70,%eax
c0104692:	8b 40 08             	mov    0x8(%eax),%eax
c0104695:	8b 55 08             	mov    0x8(%ebp),%edx
c0104698:	89 14 24             	mov    %edx,(%esp)
c010469b:	ff d0                	call   *%eax
}
c010469d:	c9                   	leave  
c010469e:	c3                   	ret    

c010469f <swap_tick_event>:

int
swap_tick_event(struct mm_struct *mm)
{
c010469f:	55                   	push   %ebp
c01046a0:	89 e5                	mov    %esp,%ebp
c01046a2:	83 ec 18             	sub    $0x18,%esp
     return sm->tick_event(mm);
c01046a5:	a1 70 3f 12 c0       	mov    0xc0123f70,%eax
c01046aa:	8b 40 0c             	mov    0xc(%eax),%eax
c01046ad:	8b 55 08             	mov    0x8(%ebp),%edx
c01046b0:	89 14 24             	mov    %edx,(%esp)
c01046b3:	ff d0                	call   *%eax
}
c01046b5:	c9                   	leave  
c01046b6:	c3                   	ret    

c01046b7 <swap_map_swappable>:

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c01046b7:	55                   	push   %ebp
c01046b8:	89 e5                	mov    %esp,%ebp
c01046ba:	83 ec 18             	sub    $0x18,%esp
     return sm->map_swappable(mm, addr, page, swap_in);
c01046bd:	a1 70 3f 12 c0       	mov    0xc0123f70,%eax
c01046c2:	8b 40 10             	mov    0x10(%eax),%eax
c01046c5:	8b 55 14             	mov    0x14(%ebp),%edx
c01046c8:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01046cc:	8b 55 10             	mov    0x10(%ebp),%edx
c01046cf:	89 54 24 08          	mov    %edx,0x8(%esp)
c01046d3:	8b 55 0c             	mov    0xc(%ebp),%edx
c01046d6:	89 54 24 04          	mov    %edx,0x4(%esp)
c01046da:	8b 55 08             	mov    0x8(%ebp),%edx
c01046dd:	89 14 24             	mov    %edx,(%esp)
c01046e0:	ff d0                	call   *%eax
}
c01046e2:	c9                   	leave  
c01046e3:	c3                   	ret    

c01046e4 <swap_set_unswappable>:

int
swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c01046e4:	55                   	push   %ebp
c01046e5:	89 e5                	mov    %esp,%ebp
c01046e7:	83 ec 18             	sub    $0x18,%esp
     return sm->set_unswappable(mm, addr);
c01046ea:	a1 70 3f 12 c0       	mov    0xc0123f70,%eax
c01046ef:	8b 40 14             	mov    0x14(%eax),%eax
c01046f2:	8b 55 0c             	mov    0xc(%ebp),%edx
c01046f5:	89 54 24 04          	mov    %edx,0x4(%esp)
c01046f9:	8b 55 08             	mov    0x8(%ebp),%edx
c01046fc:	89 14 24             	mov    %edx,(%esp)
c01046ff:	ff d0                	call   *%eax
}
c0104701:	c9                   	leave  
c0104702:	c3                   	ret    

c0104703 <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
c0104703:	55                   	push   %ebp
c0104704:	89 e5                	mov    %esp,%ebp
c0104706:	83 ec 38             	sub    $0x38,%esp
     int i;
     for (i = 0; i != n; ++ i)
c0104709:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104710:	e9 5a 01 00 00       	jmp    c010486f <swap_out+0x16c>
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
c0104715:	a1 70 3f 12 c0       	mov    0xc0123f70,%eax
c010471a:	8b 40 18             	mov    0x18(%eax),%eax
c010471d:	8b 55 10             	mov    0x10(%ebp),%edx
c0104720:	89 54 24 08          	mov    %edx,0x8(%esp)
c0104724:	8d 55 e4             	lea    -0x1c(%ebp),%edx
c0104727:	89 54 24 04          	mov    %edx,0x4(%esp)
c010472b:	8b 55 08             	mov    0x8(%ebp),%edx
c010472e:	89 14 24             	mov    %edx,(%esp)
c0104731:	ff d0                	call   *%eax
c0104733:	89 45 f0             	mov    %eax,-0x10(%ebp)
          if (r != 0) {
c0104736:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010473a:	74 18                	je     c0104754 <swap_out+0x51>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
c010473c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010473f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104743:	c7 04 24 7c 9c 10 c0 	movl   $0xc0109c7c,(%esp)
c010474a:	e8 52 bb ff ff       	call   c01002a1 <cprintf>
c010474f:	e9 27 01 00 00       	jmp    c010487b <swap_out+0x178>
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
c0104754:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104757:	8b 40 1c             	mov    0x1c(%eax),%eax
c010475a:	89 45 ec             	mov    %eax,-0x14(%ebp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
c010475d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104760:	8b 40 0c             	mov    0xc(%eax),%eax
c0104763:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010476a:	00 
c010476b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010476e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104772:	89 04 24             	mov    %eax,(%esp)
c0104775:	e8 5f 25 00 00       	call   c0106cd9 <get_pte>
c010477a:	89 45 e8             	mov    %eax,-0x18(%ebp)
          assert((*ptep & PTE_P) != 0);
c010477d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104780:	8b 00                	mov    (%eax),%eax
c0104782:	83 e0 01             	and    $0x1,%eax
c0104785:	85 c0                	test   %eax,%eax
c0104787:	75 24                	jne    c01047ad <swap_out+0xaa>
c0104789:	c7 44 24 0c a9 9c 10 	movl   $0xc0109ca9,0xc(%esp)
c0104790:	c0 
c0104791:	c7 44 24 08 be 9c 10 	movl   $0xc0109cbe,0x8(%esp)
c0104798:	c0 
c0104799:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c01047a0:	00 
c01047a1:	c7 04 24 58 9c 10 c0 	movl   $0xc0109c58,(%esp)
c01047a8:	e8 4b bc ff ff       	call   c01003f8 <__panic>

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
c01047ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01047b0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01047b3:	8b 52 1c             	mov    0x1c(%edx),%edx
c01047b6:	c1 ea 0c             	shr    $0xc,%edx
c01047b9:	83 c2 01             	add    $0x1,%edx
c01047bc:	c1 e2 08             	shl    $0x8,%edx
c01047bf:	89 44 24 04          	mov    %eax,0x4(%esp)
c01047c3:	89 14 24             	mov    %edx,(%esp)
c01047c6:	e8 51 38 00 00       	call   c010801c <swapfs_write>
c01047cb:	85 c0                	test   %eax,%eax
c01047cd:	74 34                	je     c0104803 <swap_out+0x100>
                    cprintf("SWAP: failed to save\n");
c01047cf:	c7 04 24 d3 9c 10 c0 	movl   $0xc0109cd3,(%esp)
c01047d6:	e8 c6 ba ff ff       	call   c01002a1 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
c01047db:	a1 70 3f 12 c0       	mov    0xc0123f70,%eax
c01047e0:	8b 40 10             	mov    0x10(%eax),%eax
c01047e3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01047e6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01047ed:	00 
c01047ee:	89 54 24 08          	mov    %edx,0x8(%esp)
c01047f2:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01047f5:	89 54 24 04          	mov    %edx,0x4(%esp)
c01047f9:	8b 55 08             	mov    0x8(%ebp),%edx
c01047fc:	89 14 24             	mov    %edx,(%esp)
c01047ff:	ff d0                	call   *%eax
c0104801:	eb 68                	jmp    c010486b <swap_out+0x168>
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
c0104803:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104806:	8b 40 1c             	mov    0x1c(%eax),%eax
c0104809:	c1 e8 0c             	shr    $0xc,%eax
c010480c:	83 c0 01             	add    $0x1,%eax
c010480f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104813:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104816:	89 44 24 08          	mov    %eax,0x8(%esp)
c010481a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010481d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104821:	c7 04 24 ec 9c 10 c0 	movl   $0xc0109cec,(%esp)
c0104828:	e8 74 ba ff ff       	call   c01002a1 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
c010482d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104830:	8b 40 1c             	mov    0x1c(%eax),%eax
c0104833:	c1 e8 0c             	shr    $0xc,%eax
c0104836:	83 c0 01             	add    $0x1,%eax
c0104839:	c1 e0 08             	shl    $0x8,%eax
c010483c:	89 c2                	mov    %eax,%edx
c010483e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104841:	89 10                	mov    %edx,(%eax)
                    free_page(page);
c0104843:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104846:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010484d:	00 
c010484e:	89 04 24             	mov    %eax,(%esp)
c0104851:	e8 0f 1e 00 00       	call   c0106665 <free_pages>
          }
          
          tlb_invalidate(mm->pgdir, v);
c0104856:	8b 45 08             	mov    0x8(%ebp),%eax
c0104859:	8b 40 0c             	mov    0xc(%eax),%eax
c010485c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010485f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104863:	89 04 24             	mov    %eax,(%esp)
c0104866:	e8 63 27 00 00       	call   c0106fce <tlb_invalidate>
     for (i = 0; i != n; ++ i)
c010486b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010486f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104872:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104875:	0f 85 9a fe ff ff    	jne    c0104715 <swap_out+0x12>
     }
     return i;
c010487b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010487e:	c9                   	leave  
c010487f:	c3                   	ret    

c0104880 <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
c0104880:	55                   	push   %ebp
c0104881:	89 e5                	mov    %esp,%ebp
c0104883:	83 ec 28             	sub    $0x28,%esp
     struct Page *result = alloc_page();
c0104886:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010488d:	e8 68 1d 00 00       	call   c01065fa <alloc_pages>
c0104892:	89 45 f4             	mov    %eax,-0xc(%ebp)
     assert(result!=NULL);
c0104895:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104899:	75 24                	jne    c01048bf <swap_in+0x3f>
c010489b:	c7 44 24 0c 2c 9d 10 	movl   $0xc0109d2c,0xc(%esp)
c01048a2:	c0 
c01048a3:	c7 44 24 08 be 9c 10 	movl   $0xc0109cbe,0x8(%esp)
c01048aa:	c0 
c01048ab:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
c01048b2:	00 
c01048b3:	c7 04 24 58 9c 10 c0 	movl   $0xc0109c58,(%esp)
c01048ba:	e8 39 bb ff ff       	call   c01003f8 <__panic>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
c01048bf:	8b 45 08             	mov    0x8(%ebp),%eax
c01048c2:	8b 40 0c             	mov    0xc(%eax),%eax
c01048c5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01048cc:	00 
c01048cd:	8b 55 0c             	mov    0xc(%ebp),%edx
c01048d0:	89 54 24 04          	mov    %edx,0x4(%esp)
c01048d4:	89 04 24             	mov    %eax,(%esp)
c01048d7:	e8 fd 23 00 00       	call   c0106cd9 <get_pte>
c01048dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
c01048df:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048e2:	8b 00                	mov    (%eax),%eax
c01048e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01048e7:	89 54 24 04          	mov    %edx,0x4(%esp)
c01048eb:	89 04 24             	mov    %eax,(%esp)
c01048ee:	e8 b7 36 00 00       	call   c0107faa <swapfs_read>
c01048f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01048f6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01048fa:	74 2a                	je     c0104926 <swap_in+0xa6>
     {
        assert(r!=0);
c01048fc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104900:	75 24                	jne    c0104926 <swap_in+0xa6>
c0104902:	c7 44 24 0c 39 9d 10 	movl   $0xc0109d39,0xc(%esp)
c0104909:	c0 
c010490a:	c7 44 24 08 be 9c 10 	movl   $0xc0109cbe,0x8(%esp)
c0104911:	c0 
c0104912:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
c0104919:	00 
c010491a:	c7 04 24 58 9c 10 c0 	movl   $0xc0109c58,(%esp)
c0104921:	e8 d2 ba ff ff       	call   c01003f8 <__panic>
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
c0104926:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104929:	8b 00                	mov    (%eax),%eax
c010492b:	c1 e8 08             	shr    $0x8,%eax
c010492e:	89 c2                	mov    %eax,%edx
c0104930:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104933:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104937:	89 54 24 04          	mov    %edx,0x4(%esp)
c010493b:	c7 04 24 40 9d 10 c0 	movl   $0xc0109d40,(%esp)
c0104942:	e8 5a b9 ff ff       	call   c01002a1 <cprintf>
     *ptr_result=result;
c0104947:	8b 45 10             	mov    0x10(%ebp),%eax
c010494a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010494d:	89 10                	mov    %edx,(%eax)
     return 0;
c010494f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104954:	c9                   	leave  
c0104955:	c3                   	ret    

c0104956 <check_content_set>:



static inline void
check_content_set(void)
{
c0104956:	55                   	push   %ebp
c0104957:	89 e5                	mov    %esp,%ebp
c0104959:	83 ec 18             	sub    $0x18,%esp
     *(unsigned char *)0x1000 = 0x0a;
c010495c:	b8 00 10 00 00       	mov    $0x1000,%eax
c0104961:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0104964:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c0104969:	83 f8 01             	cmp    $0x1,%eax
c010496c:	74 24                	je     c0104992 <check_content_set+0x3c>
c010496e:	c7 44 24 0c 7e 9d 10 	movl   $0xc0109d7e,0xc(%esp)
c0104975:	c0 
c0104976:	c7 44 24 08 be 9c 10 	movl   $0xc0109cbe,0x8(%esp)
c010497d:	c0 
c010497e:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
c0104985:	00 
c0104986:	c7 04 24 58 9c 10 c0 	movl   $0xc0109c58,(%esp)
c010498d:	e8 66 ba ff ff       	call   c01003f8 <__panic>
     *(unsigned char *)0x1010 = 0x0a;
c0104992:	b8 10 10 00 00       	mov    $0x1010,%eax
c0104997:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c010499a:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c010499f:	83 f8 01             	cmp    $0x1,%eax
c01049a2:	74 24                	je     c01049c8 <check_content_set+0x72>
c01049a4:	c7 44 24 0c 7e 9d 10 	movl   $0xc0109d7e,0xc(%esp)
c01049ab:	c0 
c01049ac:	c7 44 24 08 be 9c 10 	movl   $0xc0109cbe,0x8(%esp)
c01049b3:	c0 
c01049b4:	c7 44 24 04 92 00 00 	movl   $0x92,0x4(%esp)
c01049bb:	00 
c01049bc:	c7 04 24 58 9c 10 c0 	movl   $0xc0109c58,(%esp)
c01049c3:	e8 30 ba ff ff       	call   c01003f8 <__panic>
     *(unsigned char *)0x2000 = 0x0b;
c01049c8:	b8 00 20 00 00       	mov    $0x2000,%eax
c01049cd:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c01049d0:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c01049d5:	83 f8 02             	cmp    $0x2,%eax
c01049d8:	74 24                	je     c01049fe <check_content_set+0xa8>
c01049da:	c7 44 24 0c 8d 9d 10 	movl   $0xc0109d8d,0xc(%esp)
c01049e1:	c0 
c01049e2:	c7 44 24 08 be 9c 10 	movl   $0xc0109cbe,0x8(%esp)
c01049e9:	c0 
c01049ea:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c01049f1:	00 
c01049f2:	c7 04 24 58 9c 10 c0 	movl   $0xc0109c58,(%esp)
c01049f9:	e8 fa b9 ff ff       	call   c01003f8 <__panic>
     *(unsigned char *)0x2010 = 0x0b;
c01049fe:	b8 10 20 00 00       	mov    $0x2010,%eax
c0104a03:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0104a06:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c0104a0b:	83 f8 02             	cmp    $0x2,%eax
c0104a0e:	74 24                	je     c0104a34 <check_content_set+0xde>
c0104a10:	c7 44 24 0c 8d 9d 10 	movl   $0xc0109d8d,0xc(%esp)
c0104a17:	c0 
c0104a18:	c7 44 24 08 be 9c 10 	movl   $0xc0109cbe,0x8(%esp)
c0104a1f:	c0 
c0104a20:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
c0104a27:	00 
c0104a28:	c7 04 24 58 9c 10 c0 	movl   $0xc0109c58,(%esp)
c0104a2f:	e8 c4 b9 ff ff       	call   c01003f8 <__panic>
     *(unsigned char *)0x3000 = 0x0c;
c0104a34:	b8 00 30 00 00       	mov    $0x3000,%eax
c0104a39:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0104a3c:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c0104a41:	83 f8 03             	cmp    $0x3,%eax
c0104a44:	74 24                	je     c0104a6a <check_content_set+0x114>
c0104a46:	c7 44 24 0c 9c 9d 10 	movl   $0xc0109d9c,0xc(%esp)
c0104a4d:	c0 
c0104a4e:	c7 44 24 08 be 9c 10 	movl   $0xc0109cbe,0x8(%esp)
c0104a55:	c0 
c0104a56:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
c0104a5d:	00 
c0104a5e:	c7 04 24 58 9c 10 c0 	movl   $0xc0109c58,(%esp)
c0104a65:	e8 8e b9 ff ff       	call   c01003f8 <__panic>
     *(unsigned char *)0x3010 = 0x0c;
c0104a6a:	b8 10 30 00 00       	mov    $0x3010,%eax
c0104a6f:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0104a72:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c0104a77:	83 f8 03             	cmp    $0x3,%eax
c0104a7a:	74 24                	je     c0104aa0 <check_content_set+0x14a>
c0104a7c:	c7 44 24 0c 9c 9d 10 	movl   $0xc0109d9c,0xc(%esp)
c0104a83:	c0 
c0104a84:	c7 44 24 08 be 9c 10 	movl   $0xc0109cbe,0x8(%esp)
c0104a8b:	c0 
c0104a8c:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
c0104a93:	00 
c0104a94:	c7 04 24 58 9c 10 c0 	movl   $0xc0109c58,(%esp)
c0104a9b:	e8 58 b9 ff ff       	call   c01003f8 <__panic>
     *(unsigned char *)0x4000 = 0x0d;
c0104aa0:	b8 00 40 00 00       	mov    $0x4000,%eax
c0104aa5:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0104aa8:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c0104aad:	83 f8 04             	cmp    $0x4,%eax
c0104ab0:	74 24                	je     c0104ad6 <check_content_set+0x180>
c0104ab2:	c7 44 24 0c ab 9d 10 	movl   $0xc0109dab,0xc(%esp)
c0104ab9:	c0 
c0104aba:	c7 44 24 08 be 9c 10 	movl   $0xc0109cbe,0x8(%esp)
c0104ac1:	c0 
c0104ac2:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c0104ac9:	00 
c0104aca:	c7 04 24 58 9c 10 c0 	movl   $0xc0109c58,(%esp)
c0104ad1:	e8 22 b9 ff ff       	call   c01003f8 <__panic>
     *(unsigned char *)0x4010 = 0x0d;
c0104ad6:	b8 10 40 00 00       	mov    $0x4010,%eax
c0104adb:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0104ade:	a1 64 3f 12 c0       	mov    0xc0123f64,%eax
c0104ae3:	83 f8 04             	cmp    $0x4,%eax
c0104ae6:	74 24                	je     c0104b0c <check_content_set+0x1b6>
c0104ae8:	c7 44 24 0c ab 9d 10 	movl   $0xc0109dab,0xc(%esp)
c0104aef:	c0 
c0104af0:	c7 44 24 08 be 9c 10 	movl   $0xc0109cbe,0x8(%esp)
c0104af7:	c0 
c0104af8:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
c0104aff:	00 
c0104b00:	c7 04 24 58 9c 10 c0 	movl   $0xc0109c58,(%esp)
c0104b07:	e8 ec b8 ff ff       	call   c01003f8 <__panic>
}
c0104b0c:	c9                   	leave  
c0104b0d:	c3                   	ret    

c0104b0e <check_content_access>:

static inline int
check_content_access(void)
{
c0104b0e:	55                   	push   %ebp
c0104b0f:	89 e5                	mov    %esp,%ebp
c0104b11:	83 ec 18             	sub    $0x18,%esp
    int ret = sm->check_swap();
c0104b14:	a1 70 3f 12 c0       	mov    0xc0123f70,%eax
c0104b19:	8b 40 1c             	mov    0x1c(%eax),%eax
c0104b1c:	ff d0                	call   *%eax
c0104b1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c0104b21:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104b24:	c9                   	leave  
c0104b25:	c3                   	ret    

c0104b26 <check_swap>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void)
{
c0104b26:	55                   	push   %ebp
c0104b27:	89 e5                	mov    %esp,%ebp
c0104b29:	53                   	push   %ebx
c0104b2a:	83 ec 74             	sub    $0x74,%esp
    //backup mem env
     int ret, count = 0, total = 0, i;
c0104b2d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104b34:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     list_entry_t *le = &free_list;
c0104b3b:	c7 45 e8 e4 40 12 c0 	movl   $0xc01240e4,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0104b42:	eb 6b                	jmp    c0104baf <check_swap+0x89>
        struct Page *p = le2page(le, page_link);
c0104b44:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104b47:	83 e8 0c             	sub    $0xc,%eax
c0104b4a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        assert(PageProperty(p));
c0104b4d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104b50:	83 c0 04             	add    $0x4,%eax
c0104b53:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0104b5a:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104b5d:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0104b60:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0104b63:	0f a3 10             	bt     %edx,(%eax)
c0104b66:	19 c0                	sbb    %eax,%eax
c0104b68:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return oldbit != 0;
c0104b6b:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0104b6f:	0f 95 c0             	setne  %al
c0104b72:	0f b6 c0             	movzbl %al,%eax
c0104b75:	85 c0                	test   %eax,%eax
c0104b77:	75 24                	jne    c0104b9d <check_swap+0x77>
c0104b79:	c7 44 24 0c ba 9d 10 	movl   $0xc0109dba,0xc(%esp)
c0104b80:	c0 
c0104b81:	c7 44 24 08 be 9c 10 	movl   $0xc0109cbe,0x8(%esp)
c0104b88:	c0 
c0104b89:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
c0104b90:	00 
c0104b91:	c7 04 24 58 9c 10 c0 	movl   $0xc0109c58,(%esp)
c0104b98:	e8 5b b8 ff ff       	call   c01003f8 <__panic>
        count ++, total += p->property;
c0104b9d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0104ba1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104ba4:	8b 50 08             	mov    0x8(%eax),%edx
c0104ba7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104baa:	01 d0                	add    %edx,%eax
c0104bac:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104baf:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104bb2:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return listelm->next;
c0104bb5:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104bb8:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c0104bbb:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104bbe:	81 7d e8 e4 40 12 c0 	cmpl   $0xc01240e4,-0x18(%ebp)
c0104bc5:	0f 85 79 ff ff ff    	jne    c0104b44 <check_swap+0x1e>
     }
     assert(total == nr_free_pages());
c0104bcb:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c0104bce:	e8 c4 1a 00 00       	call   c0106697 <nr_free_pages>
c0104bd3:	39 c3                	cmp    %eax,%ebx
c0104bd5:	74 24                	je     c0104bfb <check_swap+0xd5>
c0104bd7:	c7 44 24 0c ca 9d 10 	movl   $0xc0109dca,0xc(%esp)
c0104bde:	c0 
c0104bdf:	c7 44 24 08 be 9c 10 	movl   $0xc0109cbe,0x8(%esp)
c0104be6:	c0 
c0104be7:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c0104bee:	00 
c0104bef:	c7 04 24 58 9c 10 c0 	movl   $0xc0109c58,(%esp)
c0104bf6:	e8 fd b7 ff ff       	call   c01003f8 <__panic>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
c0104bfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104bfe:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104c02:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c05:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104c09:	c7 04 24 e4 9d 10 c0 	movl   $0xc0109de4,(%esp)
c0104c10:	e8 8c b6 ff ff       	call   c01002a1 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
c0104c15:	e8 d8 e6 ff ff       	call   c01032f2 <mm_create>
c0104c1a:	89 45 e0             	mov    %eax,-0x20(%ebp)
     assert(mm != NULL);
c0104c1d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0104c21:	75 24                	jne    c0104c47 <check_swap+0x121>
c0104c23:	c7 44 24 0c 0a 9e 10 	movl   $0xc0109e0a,0xc(%esp)
c0104c2a:	c0 
c0104c2b:	c7 44 24 08 be 9c 10 	movl   $0xc0109cbe,0x8(%esp)
c0104c32:	c0 
c0104c33:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
c0104c3a:	00 
c0104c3b:	c7 04 24 58 9c 10 c0 	movl   $0xc0109c58,(%esp)
c0104c42:	e8 b1 b7 ff ff       	call   c01003f8 <__panic>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
c0104c47:	a1 10 40 12 c0       	mov    0xc0124010,%eax
c0104c4c:	85 c0                	test   %eax,%eax
c0104c4e:	74 24                	je     c0104c74 <check_swap+0x14e>
c0104c50:	c7 44 24 0c 15 9e 10 	movl   $0xc0109e15,0xc(%esp)
c0104c57:	c0 
c0104c58:	c7 44 24 08 be 9c 10 	movl   $0xc0109cbe,0x8(%esp)
c0104c5f:	c0 
c0104c60:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
c0104c67:	00 
c0104c68:	c7 04 24 58 9c 10 c0 	movl   $0xc0109c58,(%esp)
c0104c6f:	e8 84 b7 ff ff       	call   c01003f8 <__panic>

     check_mm_struct = mm;
c0104c74:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104c77:	a3 10 40 12 c0       	mov    %eax,0xc0124010

     pde_t *pgdir = mm->pgdir = boot_pgdir;
c0104c7c:	8b 15 00 0a 12 c0    	mov    0xc0120a00,%edx
c0104c82:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104c85:	89 50 0c             	mov    %edx,0xc(%eax)
c0104c88:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104c8b:	8b 40 0c             	mov    0xc(%eax),%eax
c0104c8e:	89 45 dc             	mov    %eax,-0x24(%ebp)
     assert(pgdir[0] == 0);
c0104c91:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104c94:	8b 00                	mov    (%eax),%eax
c0104c96:	85 c0                	test   %eax,%eax
c0104c98:	74 24                	je     c0104cbe <check_swap+0x198>
c0104c9a:	c7 44 24 0c 2d 9e 10 	movl   $0xc0109e2d,0xc(%esp)
c0104ca1:	c0 
c0104ca2:	c7 44 24 08 be 9c 10 	movl   $0xc0109cbe,0x8(%esp)
c0104ca9:	c0 
c0104caa:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c0104cb1:	00 
c0104cb2:	c7 04 24 58 9c 10 c0 	movl   $0xc0109c58,(%esp)
c0104cb9:	e8 3a b7 ff ff       	call   c01003f8 <__panic>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
c0104cbe:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
c0104cc5:	00 
c0104cc6:	c7 44 24 04 00 60 00 	movl   $0x6000,0x4(%esp)
c0104ccd:	00 
c0104cce:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
c0104cd5:	e8 90 e6 ff ff       	call   c010336a <vma_create>
c0104cda:	89 45 d8             	mov    %eax,-0x28(%ebp)
     assert(vma != NULL);
c0104cdd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0104ce1:	75 24                	jne    c0104d07 <check_swap+0x1e1>
c0104ce3:	c7 44 24 0c 3b 9e 10 	movl   $0xc0109e3b,0xc(%esp)
c0104cea:	c0 
c0104ceb:	c7 44 24 08 be 9c 10 	movl   $0xc0109cbe,0x8(%esp)
c0104cf2:	c0 
c0104cf3:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c0104cfa:	00 
c0104cfb:	c7 04 24 58 9c 10 c0 	movl   $0xc0109c58,(%esp)
c0104d02:	e8 f1 b6 ff ff       	call   c01003f8 <__panic>

     insert_vma_struct(mm, vma);
c0104d07:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104d0a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104d0e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104d11:	89 04 24             	mov    %eax,(%esp)
c0104d14:	e8 e1 e7 ff ff       	call   c01034fa <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
c0104d19:	c7 04 24 48 9e 10 c0 	movl   $0xc0109e48,(%esp)
c0104d20:	e8 7c b5 ff ff       	call   c01002a1 <cprintf>
     pte_t *temp_ptep=NULL;
c0104d25:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
c0104d2c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104d2f:	8b 40 0c             	mov    0xc(%eax),%eax
c0104d32:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0104d39:	00 
c0104d3a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104d41:	00 
c0104d42:	89 04 24             	mov    %eax,(%esp)
c0104d45:	e8 8f 1f 00 00       	call   c0106cd9 <get_pte>
c0104d4a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     assert(temp_ptep!= NULL);
c0104d4d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c0104d51:	75 24                	jne    c0104d77 <check_swap+0x251>
c0104d53:	c7 44 24 0c 7c 9e 10 	movl   $0xc0109e7c,0xc(%esp)
c0104d5a:	c0 
c0104d5b:	c7 44 24 08 be 9c 10 	movl   $0xc0109cbe,0x8(%esp)
c0104d62:	c0 
c0104d63:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
c0104d6a:	00 
c0104d6b:	c7 04 24 58 9c 10 c0 	movl   $0xc0109c58,(%esp)
c0104d72:	e8 81 b6 ff ff       	call   c01003f8 <__panic>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
c0104d77:	c7 04 24 90 9e 10 c0 	movl   $0xc0109e90,(%esp)
c0104d7e:	e8 1e b5 ff ff       	call   c01002a1 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0104d83:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0104d8a:	e9 a3 00 00 00       	jmp    c0104e32 <check_swap+0x30c>
          check_rp[i] = alloc_page();
c0104d8f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104d96:	e8 5f 18 00 00       	call   c01065fa <alloc_pages>
c0104d9b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104d9e:	89 04 95 20 40 12 c0 	mov    %eax,-0x3fedbfe0(,%edx,4)
          assert(check_rp[i] != NULL );
c0104da5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104da8:	8b 04 85 20 40 12 c0 	mov    -0x3fedbfe0(,%eax,4),%eax
c0104daf:	85 c0                	test   %eax,%eax
c0104db1:	75 24                	jne    c0104dd7 <check_swap+0x2b1>
c0104db3:	c7 44 24 0c b4 9e 10 	movl   $0xc0109eb4,0xc(%esp)
c0104dba:	c0 
c0104dbb:	c7 44 24 08 be 9c 10 	movl   $0xc0109cbe,0x8(%esp)
c0104dc2:	c0 
c0104dc3:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c0104dca:	00 
c0104dcb:	c7 04 24 58 9c 10 c0 	movl   $0xc0109c58,(%esp)
c0104dd2:	e8 21 b6 ff ff       	call   c01003f8 <__panic>
          assert(!PageProperty(check_rp[i]));
c0104dd7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104dda:	8b 04 85 20 40 12 c0 	mov    -0x3fedbfe0(,%eax,4),%eax
c0104de1:	83 c0 04             	add    $0x4,%eax
c0104de4:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
c0104deb:	89 45 b0             	mov    %eax,-0x50(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104dee:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104df1:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0104df4:	0f a3 10             	bt     %edx,(%eax)
c0104df7:	19 c0                	sbb    %eax,%eax
c0104df9:	89 45 ac             	mov    %eax,-0x54(%ebp)
    return oldbit != 0;
c0104dfc:	83 7d ac 00          	cmpl   $0x0,-0x54(%ebp)
c0104e00:	0f 95 c0             	setne  %al
c0104e03:	0f b6 c0             	movzbl %al,%eax
c0104e06:	85 c0                	test   %eax,%eax
c0104e08:	74 24                	je     c0104e2e <check_swap+0x308>
c0104e0a:	c7 44 24 0c c8 9e 10 	movl   $0xc0109ec8,0xc(%esp)
c0104e11:	c0 
c0104e12:	c7 44 24 08 be 9c 10 	movl   $0xc0109cbe,0x8(%esp)
c0104e19:	c0 
c0104e1a:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c0104e21:	00 
c0104e22:	c7 04 24 58 9c 10 c0 	movl   $0xc0109c58,(%esp)
c0104e29:	e8 ca b5 ff ff       	call   c01003f8 <__panic>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0104e2e:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0104e32:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0104e36:	0f 8e 53 ff ff ff    	jle    c0104d8f <check_swap+0x269>
     }
     list_entry_t free_list_store = free_list;
c0104e3c:	a1 e4 40 12 c0       	mov    0xc01240e4,%eax
c0104e41:	8b 15 e8 40 12 c0    	mov    0xc01240e8,%edx
c0104e47:	89 45 98             	mov    %eax,-0x68(%ebp)
c0104e4a:	89 55 9c             	mov    %edx,-0x64(%ebp)
c0104e4d:	c7 45 a8 e4 40 12 c0 	movl   $0xc01240e4,-0x58(%ebp)
    elm->prev = elm->next = elm;
c0104e54:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104e57:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0104e5a:	89 50 04             	mov    %edx,0x4(%eax)
c0104e5d:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104e60:	8b 50 04             	mov    0x4(%eax),%edx
c0104e63:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104e66:	89 10                	mov    %edx,(%eax)
c0104e68:	c7 45 a4 e4 40 12 c0 	movl   $0xc01240e4,-0x5c(%ebp)
    return list->next == list;
c0104e6f:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0104e72:	8b 40 04             	mov    0x4(%eax),%eax
c0104e75:	39 45 a4             	cmp    %eax,-0x5c(%ebp)
c0104e78:	0f 94 c0             	sete   %al
c0104e7b:	0f b6 c0             	movzbl %al,%eax
     list_init(&free_list);
     assert(list_empty(&free_list));
c0104e7e:	85 c0                	test   %eax,%eax
c0104e80:	75 24                	jne    c0104ea6 <check_swap+0x380>
c0104e82:	c7 44 24 0c e3 9e 10 	movl   $0xc0109ee3,0xc(%esp)
c0104e89:	c0 
c0104e8a:	c7 44 24 08 be 9c 10 	movl   $0xc0109cbe,0x8(%esp)
c0104e91:	c0 
c0104e92:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
c0104e99:	00 
c0104e9a:	c7 04 24 58 9c 10 c0 	movl   $0xc0109c58,(%esp)
c0104ea1:	e8 52 b5 ff ff       	call   c01003f8 <__panic>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
c0104ea6:	a1 ec 40 12 c0       	mov    0xc01240ec,%eax
c0104eab:	89 45 d0             	mov    %eax,-0x30(%ebp)
     nr_free = 0;
c0104eae:	c7 05 ec 40 12 c0 00 	movl   $0x0,0xc01240ec
c0104eb5:	00 00 00 
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0104eb8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0104ebf:	eb 1e                	jmp    c0104edf <check_swap+0x3b9>
        free_pages(check_rp[i],1);
c0104ec1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104ec4:	8b 04 85 20 40 12 c0 	mov    -0x3fedbfe0(,%eax,4),%eax
c0104ecb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104ed2:	00 
c0104ed3:	89 04 24             	mov    %eax,(%esp)
c0104ed6:	e8 8a 17 00 00       	call   c0106665 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0104edb:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0104edf:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0104ee3:	7e dc                	jle    c0104ec1 <check_swap+0x39b>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
c0104ee5:	a1 ec 40 12 c0       	mov    0xc01240ec,%eax
c0104eea:	83 f8 04             	cmp    $0x4,%eax
c0104eed:	74 24                	je     c0104f13 <check_swap+0x3ed>
c0104eef:	c7 44 24 0c fc 9e 10 	movl   $0xc0109efc,0xc(%esp)
c0104ef6:	c0 
c0104ef7:	c7 44 24 08 be 9c 10 	movl   $0xc0109cbe,0x8(%esp)
c0104efe:	c0 
c0104eff:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c0104f06:	00 
c0104f07:	c7 04 24 58 9c 10 c0 	movl   $0xc0109c58,(%esp)
c0104f0e:	e8 e5 b4 ff ff       	call   c01003f8 <__panic>
     
     cprintf("set up init env for check_swap begin!\n");
c0104f13:	c7 04 24 20 9f 10 c0 	movl   $0xc0109f20,(%esp)
c0104f1a:	e8 82 b3 ff ff       	call   c01002a1 <cprintf>
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
c0104f1f:	c7 05 64 3f 12 c0 00 	movl   $0x0,0xc0123f64
c0104f26:	00 00 00 
     
     check_content_set();
c0104f29:	e8 28 fa ff ff       	call   c0104956 <check_content_set>
     assert( nr_free == 0);         
c0104f2e:	a1 ec 40 12 c0       	mov    0xc01240ec,%eax
c0104f33:	85 c0                	test   %eax,%eax
c0104f35:	74 24                	je     c0104f5b <check_swap+0x435>
c0104f37:	c7 44 24 0c 47 9f 10 	movl   $0xc0109f47,0xc(%esp)
c0104f3e:	c0 
c0104f3f:	c7 44 24 08 be 9c 10 	movl   $0xc0109cbe,0x8(%esp)
c0104f46:	c0 
c0104f47:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
c0104f4e:	00 
c0104f4f:	c7 04 24 58 9c 10 c0 	movl   $0xc0109c58,(%esp)
c0104f56:	e8 9d b4 ff ff       	call   c01003f8 <__panic>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0104f5b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0104f62:	eb 26                	jmp    c0104f8a <check_swap+0x464>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
c0104f64:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104f67:	c7 04 85 40 40 12 c0 	movl   $0xffffffff,-0x3fedbfc0(,%eax,4)
c0104f6e:	ff ff ff ff 
c0104f72:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104f75:	8b 14 85 40 40 12 c0 	mov    -0x3fedbfc0(,%eax,4),%edx
c0104f7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104f7f:	89 14 85 80 40 12 c0 	mov    %edx,-0x3fedbf80(,%eax,4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0104f86:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0104f8a:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
c0104f8e:	7e d4                	jle    c0104f64 <check_swap+0x43e>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0104f90:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0104f97:	e9 eb 00 00 00       	jmp    c0105087 <check_swap+0x561>
         check_ptep[i]=0;
c0104f9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104f9f:	c7 04 85 d4 40 12 c0 	movl   $0x0,-0x3fedbf2c(,%eax,4)
c0104fa6:	00 00 00 00 
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
c0104faa:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104fad:	83 c0 01             	add    $0x1,%eax
c0104fb0:	c1 e0 0c             	shl    $0xc,%eax
c0104fb3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104fba:	00 
c0104fbb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104fbf:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104fc2:	89 04 24             	mov    %eax,(%esp)
c0104fc5:	e8 0f 1d 00 00       	call   c0106cd9 <get_pte>
c0104fca:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104fcd:	89 04 95 d4 40 12 c0 	mov    %eax,-0x3fedbf2c(,%edx,4)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
c0104fd4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104fd7:	8b 04 85 d4 40 12 c0 	mov    -0x3fedbf2c(,%eax,4),%eax
c0104fde:	85 c0                	test   %eax,%eax
c0104fe0:	75 24                	jne    c0105006 <check_swap+0x4e0>
c0104fe2:	c7 44 24 0c 54 9f 10 	movl   $0xc0109f54,0xc(%esp)
c0104fe9:	c0 
c0104fea:	c7 44 24 08 be 9c 10 	movl   $0xc0109cbe,0x8(%esp)
c0104ff1:	c0 
c0104ff2:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c0104ff9:	00 
c0104ffa:	c7 04 24 58 9c 10 c0 	movl   $0xc0109c58,(%esp)
c0105001:	e8 f2 b3 ff ff       	call   c01003f8 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
c0105006:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105009:	8b 04 85 d4 40 12 c0 	mov    -0x3fedbf2c(,%eax,4),%eax
c0105010:	8b 00                	mov    (%eax),%eax
c0105012:	89 04 24             	mov    %eax,(%esp)
c0105015:	e8 9f f5 ff ff       	call   c01045b9 <pte2page>
c010501a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010501d:	8b 14 95 20 40 12 c0 	mov    -0x3fedbfe0(,%edx,4),%edx
c0105024:	39 d0                	cmp    %edx,%eax
c0105026:	74 24                	je     c010504c <check_swap+0x526>
c0105028:	c7 44 24 0c 6c 9f 10 	movl   $0xc0109f6c,0xc(%esp)
c010502f:	c0 
c0105030:	c7 44 24 08 be 9c 10 	movl   $0xc0109cbe,0x8(%esp)
c0105037:	c0 
c0105038:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
c010503f:	00 
c0105040:	c7 04 24 58 9c 10 c0 	movl   $0xc0109c58,(%esp)
c0105047:	e8 ac b3 ff ff       	call   c01003f8 <__panic>
         assert((*check_ptep[i] & PTE_P));          
c010504c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010504f:	8b 04 85 d4 40 12 c0 	mov    -0x3fedbf2c(,%eax,4),%eax
c0105056:	8b 00                	mov    (%eax),%eax
c0105058:	83 e0 01             	and    $0x1,%eax
c010505b:	85 c0                	test   %eax,%eax
c010505d:	75 24                	jne    c0105083 <check_swap+0x55d>
c010505f:	c7 44 24 0c 94 9f 10 	movl   $0xc0109f94,0xc(%esp)
c0105066:	c0 
c0105067:	c7 44 24 08 be 9c 10 	movl   $0xc0109cbe,0x8(%esp)
c010506e:	c0 
c010506f:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c0105076:	00 
c0105077:	c7 04 24 58 9c 10 c0 	movl   $0xc0109c58,(%esp)
c010507e:	e8 75 b3 ff ff       	call   c01003f8 <__panic>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105083:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0105087:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c010508b:	0f 8e 0b ff ff ff    	jle    c0104f9c <check_swap+0x476>
     }
     cprintf("set up init env for check_swap over!\n");
c0105091:	c7 04 24 b0 9f 10 c0 	movl   $0xc0109fb0,(%esp)
c0105098:	e8 04 b2 ff ff       	call   c01002a1 <cprintf>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
c010509d:	e8 6c fa ff ff       	call   c0104b0e <check_content_access>
c01050a2:	89 45 cc             	mov    %eax,-0x34(%ebp)
     assert(ret==0);
c01050a5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01050a9:	74 24                	je     c01050cf <check_swap+0x5a9>
c01050ab:	c7 44 24 0c d6 9f 10 	movl   $0xc0109fd6,0xc(%esp)
c01050b2:	c0 
c01050b3:	c7 44 24 08 be 9c 10 	movl   $0xc0109cbe,0x8(%esp)
c01050ba:	c0 
c01050bb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
c01050c2:	00 
c01050c3:	c7 04 24 58 9c 10 c0 	movl   $0xc0109c58,(%esp)
c01050ca:	e8 29 b3 ff ff       	call   c01003f8 <__panic>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01050cf:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01050d6:	eb 1e                	jmp    c01050f6 <check_swap+0x5d0>
         free_pages(check_rp[i],1);
c01050d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01050db:	8b 04 85 20 40 12 c0 	mov    -0x3fedbfe0(,%eax,4),%eax
c01050e2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01050e9:	00 
c01050ea:	89 04 24             	mov    %eax,(%esp)
c01050ed:	e8 73 15 00 00       	call   c0106665 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01050f2:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c01050f6:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01050fa:	7e dc                	jle    c01050d8 <check_swap+0x5b2>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
c01050fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01050ff:	89 04 24             	mov    %eax,(%esp)
c0105102:	e8 23 e5 ff ff       	call   c010362a <mm_destroy>
         
     nr_free = nr_free_store;
c0105107:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010510a:	a3 ec 40 12 c0       	mov    %eax,0xc01240ec
     free_list = free_list_store;
c010510f:	8b 45 98             	mov    -0x68(%ebp),%eax
c0105112:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0105115:	a3 e4 40 12 c0       	mov    %eax,0xc01240e4
c010511a:	89 15 e8 40 12 c0    	mov    %edx,0xc01240e8

     
     le = &free_list;
c0105120:	c7 45 e8 e4 40 12 c0 	movl   $0xc01240e4,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0105127:	eb 1d                	jmp    c0105146 <check_swap+0x620>
         struct Page *p = le2page(le, page_link);
c0105129:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010512c:	83 e8 0c             	sub    $0xc,%eax
c010512f:	89 45 c8             	mov    %eax,-0x38(%ebp)
         count --, total -= p->property;
c0105132:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0105136:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105139:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010513c:	8b 40 08             	mov    0x8(%eax),%eax
c010513f:	29 c2                	sub    %eax,%edx
c0105141:	89 d0                	mov    %edx,%eax
c0105143:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105146:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105149:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return listelm->next;
c010514c:	8b 45 a0             	mov    -0x60(%ebp),%eax
c010514f:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c0105152:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105155:	81 7d e8 e4 40 12 c0 	cmpl   $0xc01240e4,-0x18(%ebp)
c010515c:	75 cb                	jne    c0105129 <check_swap+0x603>
     }
     cprintf("count is %d, total is %d\n",count,total);
c010515e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105161:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105165:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105168:	89 44 24 04          	mov    %eax,0x4(%esp)
c010516c:	c7 04 24 dd 9f 10 c0 	movl   $0xc0109fdd,(%esp)
c0105173:	e8 29 b1 ff ff       	call   c01002a1 <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
c0105178:	c7 04 24 f7 9f 10 c0 	movl   $0xc0109ff7,(%esp)
c010517f:	e8 1d b1 ff ff       	call   c01002a1 <cprintf>
}
c0105184:	83 c4 74             	add    $0x74,%esp
c0105187:	5b                   	pop    %ebx
c0105188:	5d                   	pop    %ebp
c0105189:	c3                   	ret    

c010518a <page2ppn>:
page2ppn(struct Page *page) {
c010518a:	55                   	push   %ebp
c010518b:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010518d:	8b 55 08             	mov    0x8(%ebp),%edx
c0105190:	a1 f8 40 12 c0       	mov    0xc01240f8,%eax
c0105195:	29 c2                	sub    %eax,%edx
c0105197:	89 d0                	mov    %edx,%eax
c0105199:	c1 f8 05             	sar    $0x5,%eax
}
c010519c:	5d                   	pop    %ebp
c010519d:	c3                   	ret    

c010519e <page2pa>:
page2pa(struct Page *page) {
c010519e:	55                   	push   %ebp
c010519f:	89 e5                	mov    %esp,%ebp
c01051a1:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01051a4:	8b 45 08             	mov    0x8(%ebp),%eax
c01051a7:	89 04 24             	mov    %eax,(%esp)
c01051aa:	e8 db ff ff ff       	call   c010518a <page2ppn>
c01051af:	c1 e0 0c             	shl    $0xc,%eax
}
c01051b2:	c9                   	leave  
c01051b3:	c3                   	ret    

c01051b4 <page_ref>:

static inline int
page_ref(struct Page *page) {
c01051b4:	55                   	push   %ebp
c01051b5:	89 e5                	mov    %esp,%ebp
    return page->ref;
c01051b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01051ba:	8b 00                	mov    (%eax),%eax
}
c01051bc:	5d                   	pop    %ebp
c01051bd:	c3                   	ret    

c01051be <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c01051be:	55                   	push   %ebp
c01051bf:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c01051c1:	8b 45 08             	mov    0x8(%ebp),%eax
c01051c4:	8b 55 0c             	mov    0xc(%ebp),%edx
c01051c7:	89 10                	mov    %edx,(%eax)
}
c01051c9:	5d                   	pop    %ebp
c01051ca:	c3                   	ret    

c01051cb <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c01051cb:	55                   	push   %ebp
c01051cc:	89 e5                	mov    %esp,%ebp
c01051ce:	83 ec 10             	sub    $0x10,%esp
c01051d1:	c7 45 fc e4 40 12 c0 	movl   $0xc01240e4,-0x4(%ebp)
    elm->prev = elm->next = elm;
c01051d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01051db:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01051de:	89 50 04             	mov    %edx,0x4(%eax)
c01051e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01051e4:	8b 50 04             	mov    0x4(%eax),%edx
c01051e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01051ea:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c01051ec:	c7 05 ec 40 12 c0 00 	movl   $0x0,0xc01240ec
c01051f3:	00 00 00 
}
c01051f6:	c9                   	leave  
c01051f7:	c3                   	ret    

c01051f8 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c01051f8:	55                   	push   %ebp
c01051f9:	89 e5                	mov    %esp,%ebp
c01051fb:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c01051fe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105202:	75 24                	jne    c0105228 <default_init_memmap+0x30>
c0105204:	c7 44 24 0c 10 a0 10 	movl   $0xc010a010,0xc(%esp)
c010520b:	c0 
c010520c:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c0105213:	c0 
c0105214:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c010521b:	00 
c010521c:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c0105223:	e8 d0 b1 ff ff       	call   c01003f8 <__panic>
    struct Page *p = base;
c0105228:	8b 45 08             	mov    0x8(%ebp),%eax
c010522b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c010522e:	e9 dc 00 00 00       	jmp    c010530f <default_init_memmap+0x117>
        //初始化n块物理页
        assert(PageReserved(p));
c0105233:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105236:	83 c0 04             	add    $0x4,%eax
c0105239:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0105240:	89 45 ec             	mov    %eax,-0x14(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105243:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105246:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105249:	0f a3 10             	bt     %edx,(%eax)
c010524c:	19 c0                	sbb    %eax,%eax
c010524e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c0105251:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105255:	0f 95 c0             	setne  %al
c0105258:	0f b6 c0             	movzbl %al,%eax
c010525b:	85 c0                	test   %eax,%eax
c010525d:	75 24                	jne    c0105283 <default_init_memmap+0x8b>
c010525f:	c7 44 24 0c 41 a0 10 	movl   $0xc010a041,0xc(%esp)
c0105266:	c0 
c0105267:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c010526e:	c0 
c010526f:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
c0105276:	00 
c0105277:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c010527e:	e8 75 b1 ff ff       	call   c01003f8 <__panic>
        p->flags = 0;
c0105283:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105286:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        SetPageProperty(p);
c010528d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105290:	83 c0 04             	add    $0x4,%eax
c0105293:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c010529a:	89 45 e0             	mov    %eax,-0x20(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010529d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01052a0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01052a3:	0f ab 10             	bts    %edx,(%eax)
        p->property = 0;
c01052a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052a9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        set_page_ref(p, 0);
c01052b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01052b7:	00 
c01052b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052bb:	89 04 24             	mov    %eax,(%esp)
c01052be:	e8 fb fe ff ff       	call   c01051be <set_page_ref>
        list_add_before(&free_list, &(p->page_link));
c01052c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052c6:	83 c0 0c             	add    $0xc,%eax
c01052c9:	c7 45 dc e4 40 12 c0 	movl   $0xc01240e4,-0x24(%ebp)
c01052d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
    __list_add(elm, listelm->prev, listelm);
c01052d3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01052d6:	8b 00                	mov    (%eax),%eax
c01052d8:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01052db:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01052de:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01052e1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01052e4:	89 45 cc             	mov    %eax,-0x34(%ebp)
    prev->next = next->prev = elm;
c01052e7:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01052ea:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01052ed:	89 10                	mov    %edx,(%eax)
c01052ef:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01052f2:	8b 10                	mov    (%eax),%edx
c01052f4:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01052f7:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01052fa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01052fd:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0105300:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0105303:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105306:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105309:	89 10                	mov    %edx,(%eax)
    for (; p != base + n; p ++) {
c010530b:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c010530f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105312:	c1 e0 05             	shl    $0x5,%eax
c0105315:	89 c2                	mov    %eax,%edx
c0105317:	8b 45 08             	mov    0x8(%ebp),%eax
c010531a:	01 d0                	add    %edx,%eax
c010531c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010531f:	0f 85 0e ff ff ff    	jne    c0105233 <default_init_memmap+0x3b>
    }
    nr_free += n;
c0105325:	8b 15 ec 40 12 c0    	mov    0xc01240ec,%edx
c010532b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010532e:	01 d0                	add    %edx,%eax
c0105330:	a3 ec 40 12 c0       	mov    %eax,0xc01240ec
    base->property = n;
c0105335:	8b 45 08             	mov    0x8(%ebp),%eax
c0105338:	8b 55 0c             	mov    0xc(%ebp),%edx
c010533b:	89 50 08             	mov    %edx,0x8(%eax)
}
c010533e:	c9                   	leave  
c010533f:	c3                   	ret    

c0105340 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c0105340:	55                   	push   %ebp
c0105341:	89 e5                	mov    %esp,%ebp
c0105343:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c0105346:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010534a:	75 24                	jne    c0105370 <default_alloc_pages+0x30>
c010534c:	c7 44 24 0c 10 a0 10 	movl   $0xc010a010,0xc(%esp)
c0105353:	c0 
c0105354:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c010535b:	c0 
c010535c:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
c0105363:	00 
c0105364:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c010536b:	e8 88 b0 ff ff       	call   c01003f8 <__panic>
    if (n > nr_free) {
c0105370:	a1 ec 40 12 c0       	mov    0xc01240ec,%eax
c0105375:	3b 45 08             	cmp    0x8(%ebp),%eax
c0105378:	73 0a                	jae    c0105384 <default_alloc_pages+0x44>
        return NULL;
c010537a:	b8 00 00 00 00       	mov    $0x0,%eax
c010537f:	e9 37 01 00 00       	jmp    c01054bb <default_alloc_pages+0x17b>
    }
    //如果所有空闲块的空闲页总数都没有n个,直接return null
    list_entry_t *le, *le_next;  //free_list指针和它的下一个
    le = &free_list;
c0105384:	c7 45 f4 e4 40 12 c0 	movl   $0xc01240e4,-0xc(%ebp)
    //从头开始遍历保存空闲物理内存块的链表(按照物理地址的从小到大顺序)
    while((le=list_next(le)) != &free_list) {
c010538b:	e9 0a 01 00 00       	jmp    c010549a <default_alloc_pages+0x15a>
    //通过宏le2page(memlayout.h)得指向Page的指针p
      struct Page *p = le2page(le, page_link);
c0105390:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105393:	83 e8 0c             	sub    $0xc,%eax
c0105396:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(p->property >= n){
c0105399:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010539c:	8b 40 08             	mov    0x8(%eax),%eax
c010539f:	3b 45 08             	cmp    0x8(%ebp),%eax
c01053a2:	0f 82 f2 00 00 00    	jb     c010549a <default_alloc_pages+0x15a>
        //p->property表示空闲块的大小，大于n则进下一步
        int i;
        //for初始化空闲块中每一个页
        for(i=0;i<n;i++){
c01053a8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c01053af:	eb 7c                	jmp    c010542d <default_alloc_pages+0xed>
c01053b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01053b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
c01053b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01053ba:	8b 40 04             	mov    0x4(%eax),%eax
          le_next = list_next(le);
c01053bd:	89 45 e8             	mov    %eax,-0x18(%ebp)
          struct Page *p2 = le2page(le, page_link);
c01053c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01053c3:	83 e8 0c             	sub    $0xc,%eax
c01053c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
          SetPageReserved(p2);//flags bit0 置1，表示已经被分配
c01053c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01053cc:	83 c0 04             	add    $0x4,%eax
c01053cf:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01053d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01053d9:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01053dc:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01053df:	0f ab 10             	bts    %edx,(%eax)
          ClearPageProperty(p2);//falgs bit1 置0，表示已被分配
c01053e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01053e5:	83 c0 04             	add    $0x4,%eax
c01053e8:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c01053ef:	89 45 d0             	mov    %eax,-0x30(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01053f2:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01053f5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01053f8:	0f b3 10             	btr    %edx,(%eax)
c01053fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01053fe:	89 45 cc             	mov    %eax,-0x34(%ebp)
    __list_del(listelm->prev, listelm->next);
c0105401:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105404:	8b 40 04             	mov    0x4(%eax),%eax
c0105407:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010540a:	8b 12                	mov    (%edx),%edx
c010540c:	89 55 c8             	mov    %edx,-0x38(%ebp)
c010540f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    prev->next = next;
c0105412:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0105415:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0105418:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010541b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010541e:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0105421:	89 10                	mov    %edx,(%eax)
          list_del(le);//取消和free_list的link
          le = le_next;//指针后移
c0105423:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105426:	89 45 f4             	mov    %eax,-0xc(%ebp)
        for(i=0;i<n;i++){
c0105429:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
c010542d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105430:	3b 45 08             	cmp    0x8(%ebp),%eax
c0105433:	0f 82 78 ff ff ff    	jb     c01053b1 <default_alloc_pages+0x71>
        }
        //如果选中的块大于n,需要修改剩下的块的head page的property
        if(p->property>n){
c0105439:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010543c:	8b 40 08             	mov    0x8(%eax),%eax
c010543f:	3b 45 08             	cmp    0x8(%ebp),%eax
c0105442:	76 12                	jbe    c0105456 <default_alloc_pages+0x116>
          (le2page(le,page_link))->property = p->property - n;
c0105444:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105447:	8d 50 f4             	lea    -0xc(%eax),%edx
c010544a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010544d:	8b 40 08             	mov    0x8(%eax),%eax
c0105450:	2b 45 08             	sub    0x8(%ebp),%eax
c0105453:	89 42 08             	mov    %eax,0x8(%edx)
        }
        ClearPageProperty(p);
c0105456:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105459:	83 c0 04             	add    $0x4,%eax
c010545c:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0105463:	89 45 bc             	mov    %eax,-0x44(%ebp)
c0105466:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0105469:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010546c:	0f b3 10             	btr    %edx,(%eax)
        SetPageReserved(p);
c010546f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105472:	83 c0 04             	add    $0x4,%eax
c0105475:	c7 45 b8 00 00 00 00 	movl   $0x0,-0x48(%ebp)
c010547c:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010547f:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0105482:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0105485:	0f ab 10             	bts    %edx,(%eax)
        nr_free -= n;
c0105488:	a1 ec 40 12 c0       	mov    0xc01240ec,%eax
c010548d:	2b 45 08             	sub    0x8(%ebp),%eax
c0105490:	a3 ec 40 12 c0       	mov    %eax,0xc01240ec
        return p;
c0105495:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105498:	eb 21                	jmp    c01054bb <default_alloc_pages+0x17b>
c010549a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010549d:	89 45 b0             	mov    %eax,-0x50(%ebp)
    return listelm->next;
c01054a0:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01054a3:	8b 40 04             	mov    0x4(%eax),%eax
    while((le=list_next(le)) != &free_list) {
c01054a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01054a9:	81 7d f4 e4 40 12 c0 	cmpl   $0xc01240e4,-0xc(%ebp)
c01054b0:	0f 85 da fe ff ff    	jne    c0105390 <default_alloc_pages+0x50>
      }
    }
    return NULL;//防止出错
c01054b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01054bb:	c9                   	leave  
c01054bc:	c3                   	ret    

c01054bd <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c01054bd:	55                   	push   %ebp
c01054be:	89 e5                	mov    %esp,%ebp
c01054c0:	83 ec 68             	sub    $0x68,%esp
   assert(n > 0);
c01054c3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01054c7:	75 24                	jne    c01054ed <default_free_pages+0x30>
c01054c9:	c7 44 24 0c 10 a0 10 	movl   $0xc010a010,0xc(%esp)
c01054d0:	c0 
c01054d1:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c01054d8:	c0 
c01054d9:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
c01054e0:	00 
c01054e1:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c01054e8:	e8 0b af ff ff       	call   c01003f8 <__panic>
    //assert(PageReserved(base) && PageProperty(base));
    assert(PageReserved(base));
c01054ed:	8b 45 08             	mov    0x8(%ebp),%eax
c01054f0:	83 c0 04             	add    $0x4,%eax
c01054f3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01054fa:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01054fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105500:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105503:	0f a3 10             	bt     %edx,(%eax)
c0105506:	19 c0                	sbb    %eax,%eax
c0105508:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c010550b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010550f:	0f 95 c0             	setne  %al
c0105512:	0f b6 c0             	movzbl %al,%eax
c0105515:	85 c0                	test   %eax,%eax
c0105517:	75 24                	jne    c010553d <default_free_pages+0x80>
c0105519:	c7 44 24 0c 51 a0 10 	movl   $0xc010a051,0xc(%esp)
c0105520:	c0 
c0105521:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c0105528:	c0 
c0105529:	c7 44 24 04 a6 00 00 	movl   $0xa6,0x4(%esp)
c0105530:	00 
c0105531:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c0105538:	e8 bb ae ff ff       	call   c01003f8 <__panic>
    //检查需要释放的页块是否已经被分配,只要看bit 0 reserve就好了
    list_entry_t *le = &free_list;
c010553d:	c7 45 f4 e4 40 12 c0 	movl   $0xc01240e4,-0xc(%ebp)
    struct Page * p;
    while((le=list_next(le)) != &free_list) {
c0105544:	eb 13                	jmp    c0105559 <default_free_pages+0x9c>
      p = le2page(le, page_link);
c0105546:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105549:	83 e8 0c             	sub    $0xc,%eax
c010554c:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(p>base){break;}
c010554f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105552:	3b 45 08             	cmp    0x8(%ebp),%eax
c0105555:	76 02                	jbe    c0105559 <default_free_pages+0x9c>
c0105557:	eb 18                	jmp    c0105571 <default_free_pages+0xb4>
c0105559:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010555c:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010555f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105562:	8b 40 04             	mov    0x4(%eax),%eax
    while((le=list_next(le)) != &free_list) {
c0105565:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105568:	81 7d f4 e4 40 12 c0 	cmpl   $0xc01240e4,-0xc(%ebp)
c010556f:	75 d5                	jne    c0105546 <default_free_pages+0x89>
    }
    //将每一空闲块的链表插入空闲链表中
    for(p=base;p<base+n;p++){
c0105571:	8b 45 08             	mov    0x8(%ebp),%eax
c0105574:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105577:	eb 4b                	jmp    c01055c4 <default_free_pages+0x107>
      list_add_before(le, &(p->page_link));
c0105579:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010557c:	8d 50 0c             	lea    0xc(%eax),%edx
c010557f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105582:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105585:	89 55 d8             	mov    %edx,-0x28(%ebp)
    __list_add(elm, listelm->prev, listelm);
c0105588:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010558b:	8b 00                	mov    (%eax),%eax
c010558d:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105590:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0105593:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0105596:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105599:	89 45 cc             	mov    %eax,-0x34(%ebp)
    prev->next = next->prev = elm;
c010559c:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010559f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01055a2:	89 10                	mov    %edx,(%eax)
c01055a4:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01055a7:	8b 10                	mov    (%eax),%edx
c01055a9:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01055ac:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01055af:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01055b2:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01055b5:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01055b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01055bb:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01055be:	89 10                	mov    %edx,(%eax)
    for(p=base;p<base+n;p++){
c01055c0:	83 45 f0 20          	addl   $0x20,-0x10(%ebp)
c01055c4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01055c7:	c1 e0 05             	shl    $0x5,%eax
c01055ca:	89 c2                	mov    %eax,%edx
c01055cc:	8b 45 08             	mov    0x8(%ebp),%eax
c01055cf:	01 d0                	add    %edx,%eax
c01055d1:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01055d4:	77 a3                	ja     c0105579 <default_free_pages+0xbc>
    }
    //修改页的各个属性置0
    base->flags = 0;
c01055d6:	8b 45 08             	mov    0x8(%ebp),%eax
c01055d9:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    set_page_ref(base, 0);
c01055e0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01055e7:	00 
c01055e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01055eb:	89 04 24             	mov    %eax,(%esp)
c01055ee:	e8 cb fb ff ff       	call   c01051be <set_page_ref>
    ClearPageProperty(base);
c01055f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01055f6:	83 c0 04             	add    $0x4,%eax
c01055f9:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c0105600:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105603:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105606:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0105609:	0f b3 10             	btr    %edx,(%eax)
    SetPageProperty(base);
c010560c:	8b 45 08             	mov    0x8(%ebp),%eax
c010560f:	83 c0 04             	add    $0x4,%eax
c0105612:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0105619:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010561c:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010561f:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0105622:	0f ab 10             	bts    %edx,(%eax)
    base->property = n;//有n空闲页
c0105625:	8b 45 08             	mov    0x8(%ebp),%eax
c0105628:	8b 55 0c             	mov    0xc(%ebp),%edx
c010562b:	89 50 08             	mov    %edx,0x8(%eax)
    p = le2page(le,page_link) ;
c010562e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105631:	83 e8 0c             	sub    $0xc,%eax
c0105634:	89 45 f0             	mov    %eax,-0x10(%ebp)
    //和高位方向的下一个内存块的地址连续，向高位合并
    if( base+n == p ){
c0105637:	8b 45 0c             	mov    0xc(%ebp),%eax
c010563a:	c1 e0 05             	shl    $0x5,%eax
c010563d:	89 c2                	mov    %eax,%edx
c010563f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105642:	01 d0                	add    %edx,%eax
c0105644:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0105647:	75 1e                	jne    c0105667 <default_free_pages+0x1aa>
      base->property += p->property;
c0105649:	8b 45 08             	mov    0x8(%ebp),%eax
c010564c:	8b 50 08             	mov    0x8(%eax),%edx
c010564f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105652:	8b 40 08             	mov    0x8(%eax),%eax
c0105655:	01 c2                	add    %eax,%edx
c0105657:	8b 45 08             	mov    0x8(%ebp),%eax
c010565a:	89 50 08             	mov    %edx,0x8(%eax)
      p->property = 0;
c010565d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105660:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    }
    //如果是低位,向低地址合并
    //把le指针指向前一个内存块
    le = list_prev(&(base->page_link));  //previous
c0105667:	8b 45 08             	mov    0x8(%ebp),%eax
c010566a:	83 c0 0c             	add    $0xc,%eax
c010566d:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return listelm->prev;
c0105670:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0105673:	8b 00                	mov    (%eax),%eax
c0105675:	89 45 f4             	mov    %eax,-0xc(%ebp)
    p = le2page(le, page_link);
c0105678:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010567b:	83 e8 0c             	sub    $0xc,%eax
c010567e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(le!=&free_list && p==base-1){
c0105681:	81 7d f4 e4 40 12 c0 	cmpl   $0xc01240e4,-0xc(%ebp)
c0105688:	74 57                	je     c01056e1 <default_free_pages+0x224>
c010568a:	8b 45 08             	mov    0x8(%ebp),%eax
c010568d:	83 e8 20             	sub    $0x20,%eax
c0105690:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0105693:	75 4c                	jne    c01056e1 <default_free_pages+0x224>
      while(le!=&free_list){
c0105695:	eb 41                	jmp    c01056d8 <default_free_pages+0x21b>
        if(p->property){
c0105697:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010569a:	8b 40 08             	mov    0x8(%eax),%eax
c010569d:	85 c0                	test   %eax,%eax
c010569f:	74 20                	je     c01056c1 <default_free_pages+0x204>
          p->property += base->property;
c01056a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01056a4:	8b 50 08             	mov    0x8(%eax),%edx
c01056a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01056aa:	8b 40 08             	mov    0x8(%eax),%eax
c01056ad:	01 c2                	add    %eax,%edx
c01056af:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01056b2:	89 50 08             	mov    %edx,0x8(%eax)
          base->property = 0;
c01056b5:	8b 45 08             	mov    0x8(%ebp),%eax
c01056b8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
          break;
c01056bf:	eb 20                	jmp    c01056e1 <default_free_pages+0x224>
c01056c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01056c4:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c01056c7:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01056ca:	8b 00                	mov    (%eax),%eax
        }
        le = list_prev(le);
c01056cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
        p = le2page(le,page_link);
c01056cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01056d2:	83 e8 0c             	sub    $0xc,%eax
c01056d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
      while(le!=&free_list){
c01056d8:	81 7d f4 e4 40 12 c0 	cmpl   $0xc01240e4,-0xc(%ebp)
c01056df:	75 b6                	jne    c0105697 <default_free_pages+0x1da>
      }
    }
   //更新总空闲页数
    nr_free += n;
c01056e1:	8b 15 ec 40 12 c0    	mov    0xc01240ec,%edx
c01056e7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01056ea:	01 d0                	add    %edx,%eax
c01056ec:	a3 ec 40 12 c0       	mov    %eax,0xc01240ec
    return ;
c01056f1:	90                   	nop
}
c01056f2:	c9                   	leave  
c01056f3:	c3                   	ret    

c01056f4 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c01056f4:	55                   	push   %ebp
c01056f5:	89 e5                	mov    %esp,%ebp
    return nr_free;
c01056f7:	a1 ec 40 12 c0       	mov    0xc01240ec,%eax
}
c01056fc:	5d                   	pop    %ebp
c01056fd:	c3                   	ret    

c01056fe <basic_check>:

static void
basic_check(void) {
c01056fe:	55                   	push   %ebp
c01056ff:	89 e5                	mov    %esp,%ebp
c0105701:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0105704:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010570b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010570e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105711:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105714:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0105717:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010571e:	e8 d7 0e 00 00       	call   c01065fa <alloc_pages>
c0105723:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105726:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010572a:	75 24                	jne    c0105750 <basic_check+0x52>
c010572c:	c7 44 24 0c 64 a0 10 	movl   $0xc010a064,0xc(%esp)
c0105733:	c0 
c0105734:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c010573b:	c0 
c010573c:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c0105743:	00 
c0105744:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c010574b:	e8 a8 ac ff ff       	call   c01003f8 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0105750:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105757:	e8 9e 0e 00 00       	call   c01065fa <alloc_pages>
c010575c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010575f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105763:	75 24                	jne    c0105789 <basic_check+0x8b>
c0105765:	c7 44 24 0c 80 a0 10 	movl   $0xc010a080,0xc(%esp)
c010576c:	c0 
c010576d:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c0105774:	c0 
c0105775:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c010577c:	00 
c010577d:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c0105784:	e8 6f ac ff ff       	call   c01003f8 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0105789:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105790:	e8 65 0e 00 00       	call   c01065fa <alloc_pages>
c0105795:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105798:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010579c:	75 24                	jne    c01057c2 <basic_check+0xc4>
c010579e:	c7 44 24 0c 9c a0 10 	movl   $0xc010a09c,0xc(%esp)
c01057a5:	c0 
c01057a6:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c01057ad:	c0 
c01057ae:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
c01057b5:	00 
c01057b6:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c01057bd:	e8 36 ac ff ff       	call   c01003f8 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c01057c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01057c5:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01057c8:	74 10                	je     c01057da <basic_check+0xdc>
c01057ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01057cd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01057d0:	74 08                	je     c01057da <basic_check+0xdc>
c01057d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01057d5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01057d8:	75 24                	jne    c01057fe <basic_check+0x100>
c01057da:	c7 44 24 0c b8 a0 10 	movl   $0xc010a0b8,0xc(%esp)
c01057e1:	c0 
c01057e2:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c01057e9:	c0 
c01057ea:	c7 44 24 04 df 00 00 	movl   $0xdf,0x4(%esp)
c01057f1:	00 
c01057f2:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c01057f9:	e8 fa ab ff ff       	call   c01003f8 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c01057fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105801:	89 04 24             	mov    %eax,(%esp)
c0105804:	e8 ab f9 ff ff       	call   c01051b4 <page_ref>
c0105809:	85 c0                	test   %eax,%eax
c010580b:	75 1e                	jne    c010582b <basic_check+0x12d>
c010580d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105810:	89 04 24             	mov    %eax,(%esp)
c0105813:	e8 9c f9 ff ff       	call   c01051b4 <page_ref>
c0105818:	85 c0                	test   %eax,%eax
c010581a:	75 0f                	jne    c010582b <basic_check+0x12d>
c010581c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010581f:	89 04 24             	mov    %eax,(%esp)
c0105822:	e8 8d f9 ff ff       	call   c01051b4 <page_ref>
c0105827:	85 c0                	test   %eax,%eax
c0105829:	74 24                	je     c010584f <basic_check+0x151>
c010582b:	c7 44 24 0c dc a0 10 	movl   $0xc010a0dc,0xc(%esp)
c0105832:	c0 
c0105833:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c010583a:	c0 
c010583b:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
c0105842:	00 
c0105843:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c010584a:	e8 a9 ab ff ff       	call   c01003f8 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c010584f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105852:	89 04 24             	mov    %eax,(%esp)
c0105855:	e8 44 f9 ff ff       	call   c010519e <page2pa>
c010585a:	8b 15 80 3f 12 c0    	mov    0xc0123f80,%edx
c0105860:	c1 e2 0c             	shl    $0xc,%edx
c0105863:	39 d0                	cmp    %edx,%eax
c0105865:	72 24                	jb     c010588b <basic_check+0x18d>
c0105867:	c7 44 24 0c 18 a1 10 	movl   $0xc010a118,0xc(%esp)
c010586e:	c0 
c010586f:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c0105876:	c0 
c0105877:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
c010587e:	00 
c010587f:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c0105886:	e8 6d ab ff ff       	call   c01003f8 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c010588b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010588e:	89 04 24             	mov    %eax,(%esp)
c0105891:	e8 08 f9 ff ff       	call   c010519e <page2pa>
c0105896:	8b 15 80 3f 12 c0    	mov    0xc0123f80,%edx
c010589c:	c1 e2 0c             	shl    $0xc,%edx
c010589f:	39 d0                	cmp    %edx,%eax
c01058a1:	72 24                	jb     c01058c7 <basic_check+0x1c9>
c01058a3:	c7 44 24 0c 35 a1 10 	movl   $0xc010a135,0xc(%esp)
c01058aa:	c0 
c01058ab:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c01058b2:	c0 
c01058b3:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c01058ba:	00 
c01058bb:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c01058c2:	e8 31 ab ff ff       	call   c01003f8 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c01058c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01058ca:	89 04 24             	mov    %eax,(%esp)
c01058cd:	e8 cc f8 ff ff       	call   c010519e <page2pa>
c01058d2:	8b 15 80 3f 12 c0    	mov    0xc0123f80,%edx
c01058d8:	c1 e2 0c             	shl    $0xc,%edx
c01058db:	39 d0                	cmp    %edx,%eax
c01058dd:	72 24                	jb     c0105903 <basic_check+0x205>
c01058df:	c7 44 24 0c 52 a1 10 	movl   $0xc010a152,0xc(%esp)
c01058e6:	c0 
c01058e7:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c01058ee:	c0 
c01058ef:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
c01058f6:	00 
c01058f7:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c01058fe:	e8 f5 aa ff ff       	call   c01003f8 <__panic>

    list_entry_t free_list_store = free_list;
c0105903:	a1 e4 40 12 c0       	mov    0xc01240e4,%eax
c0105908:	8b 15 e8 40 12 c0    	mov    0xc01240e8,%edx
c010590e:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0105911:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0105914:	c7 45 e0 e4 40 12 c0 	movl   $0xc01240e4,-0x20(%ebp)
    elm->prev = elm->next = elm;
c010591b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010591e:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105921:	89 50 04             	mov    %edx,0x4(%eax)
c0105924:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105927:	8b 50 04             	mov    0x4(%eax),%edx
c010592a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010592d:	89 10                	mov    %edx,(%eax)
c010592f:	c7 45 dc e4 40 12 c0 	movl   $0xc01240e4,-0x24(%ebp)
    return list->next == list;
c0105936:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105939:	8b 40 04             	mov    0x4(%eax),%eax
c010593c:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c010593f:	0f 94 c0             	sete   %al
c0105942:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0105945:	85 c0                	test   %eax,%eax
c0105947:	75 24                	jne    c010596d <basic_check+0x26f>
c0105949:	c7 44 24 0c 6f a1 10 	movl   $0xc010a16f,0xc(%esp)
c0105950:	c0 
c0105951:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c0105958:	c0 
c0105959:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
c0105960:	00 
c0105961:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c0105968:	e8 8b aa ff ff       	call   c01003f8 <__panic>

    unsigned int nr_free_store = nr_free;
c010596d:	a1 ec 40 12 c0       	mov    0xc01240ec,%eax
c0105972:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0105975:	c7 05 ec 40 12 c0 00 	movl   $0x0,0xc01240ec
c010597c:	00 00 00 

    assert(alloc_page() == NULL);
c010597f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105986:	e8 6f 0c 00 00       	call   c01065fa <alloc_pages>
c010598b:	85 c0                	test   %eax,%eax
c010598d:	74 24                	je     c01059b3 <basic_check+0x2b5>
c010598f:	c7 44 24 0c 86 a1 10 	movl   $0xc010a186,0xc(%esp)
c0105996:	c0 
c0105997:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c010599e:	c0 
c010599f:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
c01059a6:	00 
c01059a7:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c01059ae:	e8 45 aa ff ff       	call   c01003f8 <__panic>

    free_page(p0);
c01059b3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01059ba:	00 
c01059bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01059be:	89 04 24             	mov    %eax,(%esp)
c01059c1:	e8 9f 0c 00 00       	call   c0106665 <free_pages>
    free_page(p1);
c01059c6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01059cd:	00 
c01059ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01059d1:	89 04 24             	mov    %eax,(%esp)
c01059d4:	e8 8c 0c 00 00       	call   c0106665 <free_pages>
    free_page(p2);
c01059d9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01059e0:	00 
c01059e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059e4:	89 04 24             	mov    %eax,(%esp)
c01059e7:	e8 79 0c 00 00       	call   c0106665 <free_pages>
    assert(nr_free == 3);
c01059ec:	a1 ec 40 12 c0       	mov    0xc01240ec,%eax
c01059f1:	83 f8 03             	cmp    $0x3,%eax
c01059f4:	74 24                	je     c0105a1a <basic_check+0x31c>
c01059f6:	c7 44 24 0c 9b a1 10 	movl   $0xc010a19b,0xc(%esp)
c01059fd:	c0 
c01059fe:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c0105a05:	c0 
c0105a06:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
c0105a0d:	00 
c0105a0e:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c0105a15:	e8 de a9 ff ff       	call   c01003f8 <__panic>

    assert((p0 = alloc_page()) != NULL);
c0105a1a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105a21:	e8 d4 0b 00 00       	call   c01065fa <alloc_pages>
c0105a26:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105a29:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0105a2d:	75 24                	jne    c0105a53 <basic_check+0x355>
c0105a2f:	c7 44 24 0c 64 a0 10 	movl   $0xc010a064,0xc(%esp)
c0105a36:	c0 
c0105a37:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c0105a3e:	c0 
c0105a3f:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
c0105a46:	00 
c0105a47:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c0105a4e:	e8 a5 a9 ff ff       	call   c01003f8 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0105a53:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105a5a:	e8 9b 0b 00 00       	call   c01065fa <alloc_pages>
c0105a5f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105a62:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105a66:	75 24                	jne    c0105a8c <basic_check+0x38e>
c0105a68:	c7 44 24 0c 80 a0 10 	movl   $0xc010a080,0xc(%esp)
c0105a6f:	c0 
c0105a70:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c0105a77:	c0 
c0105a78:	c7 44 24 04 f5 00 00 	movl   $0xf5,0x4(%esp)
c0105a7f:	00 
c0105a80:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c0105a87:	e8 6c a9 ff ff       	call   c01003f8 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0105a8c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105a93:	e8 62 0b 00 00       	call   c01065fa <alloc_pages>
c0105a98:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105a9b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105a9f:	75 24                	jne    c0105ac5 <basic_check+0x3c7>
c0105aa1:	c7 44 24 0c 9c a0 10 	movl   $0xc010a09c,0xc(%esp)
c0105aa8:	c0 
c0105aa9:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c0105ab0:	c0 
c0105ab1:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
c0105ab8:	00 
c0105ab9:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c0105ac0:	e8 33 a9 ff ff       	call   c01003f8 <__panic>

    assert(alloc_page() == NULL);
c0105ac5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105acc:	e8 29 0b 00 00       	call   c01065fa <alloc_pages>
c0105ad1:	85 c0                	test   %eax,%eax
c0105ad3:	74 24                	je     c0105af9 <basic_check+0x3fb>
c0105ad5:	c7 44 24 0c 86 a1 10 	movl   $0xc010a186,0xc(%esp)
c0105adc:	c0 
c0105add:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c0105ae4:	c0 
c0105ae5:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c0105aec:	00 
c0105aed:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c0105af4:	e8 ff a8 ff ff       	call   c01003f8 <__panic>

    free_page(p0);
c0105af9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105b00:	00 
c0105b01:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105b04:	89 04 24             	mov    %eax,(%esp)
c0105b07:	e8 59 0b 00 00       	call   c0106665 <free_pages>
c0105b0c:	c7 45 d8 e4 40 12 c0 	movl   $0xc01240e4,-0x28(%ebp)
c0105b13:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105b16:	8b 40 04             	mov    0x4(%eax),%eax
c0105b19:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0105b1c:	0f 94 c0             	sete   %al
c0105b1f:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0105b22:	85 c0                	test   %eax,%eax
c0105b24:	74 24                	je     c0105b4a <basic_check+0x44c>
c0105b26:	c7 44 24 0c a8 a1 10 	movl   $0xc010a1a8,0xc(%esp)
c0105b2d:	c0 
c0105b2e:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c0105b35:	c0 
c0105b36:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c0105b3d:	00 
c0105b3e:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c0105b45:	e8 ae a8 ff ff       	call   c01003f8 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0105b4a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105b51:	e8 a4 0a 00 00       	call   c01065fa <alloc_pages>
c0105b56:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105b59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105b5c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0105b5f:	74 24                	je     c0105b85 <basic_check+0x487>
c0105b61:	c7 44 24 0c c0 a1 10 	movl   $0xc010a1c0,0xc(%esp)
c0105b68:	c0 
c0105b69:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c0105b70:	c0 
c0105b71:	c7 44 24 04 fe 00 00 	movl   $0xfe,0x4(%esp)
c0105b78:	00 
c0105b79:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c0105b80:	e8 73 a8 ff ff       	call   c01003f8 <__panic>
    assert(alloc_page() == NULL);
c0105b85:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105b8c:	e8 69 0a 00 00       	call   c01065fa <alloc_pages>
c0105b91:	85 c0                	test   %eax,%eax
c0105b93:	74 24                	je     c0105bb9 <basic_check+0x4bb>
c0105b95:	c7 44 24 0c 86 a1 10 	movl   $0xc010a186,0xc(%esp)
c0105b9c:	c0 
c0105b9d:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c0105ba4:	c0 
c0105ba5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
c0105bac:	00 
c0105bad:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c0105bb4:	e8 3f a8 ff ff       	call   c01003f8 <__panic>

    assert(nr_free == 0);
c0105bb9:	a1 ec 40 12 c0       	mov    0xc01240ec,%eax
c0105bbe:	85 c0                	test   %eax,%eax
c0105bc0:	74 24                	je     c0105be6 <basic_check+0x4e8>
c0105bc2:	c7 44 24 0c d9 a1 10 	movl   $0xc010a1d9,0xc(%esp)
c0105bc9:	c0 
c0105bca:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c0105bd1:	c0 
c0105bd2:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c0105bd9:	00 
c0105bda:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c0105be1:	e8 12 a8 ff ff       	call   c01003f8 <__panic>
    free_list = free_list_store;
c0105be6:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105be9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105bec:	a3 e4 40 12 c0       	mov    %eax,0xc01240e4
c0105bf1:	89 15 e8 40 12 c0    	mov    %edx,0xc01240e8
    nr_free = nr_free_store;
c0105bf7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105bfa:	a3 ec 40 12 c0       	mov    %eax,0xc01240ec

    free_page(p);
c0105bff:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105c06:	00 
c0105c07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105c0a:	89 04 24             	mov    %eax,(%esp)
c0105c0d:	e8 53 0a 00 00       	call   c0106665 <free_pages>
    free_page(p1);
c0105c12:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105c19:	00 
c0105c1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c1d:	89 04 24             	mov    %eax,(%esp)
c0105c20:	e8 40 0a 00 00       	call   c0106665 <free_pages>
    free_page(p2);
c0105c25:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105c2c:	00 
c0105c2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c30:	89 04 24             	mov    %eax,(%esp)
c0105c33:	e8 2d 0a 00 00       	call   c0106665 <free_pages>
}
c0105c38:	c9                   	leave  
c0105c39:	c3                   	ret    

c0105c3a <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0105c3a:	55                   	push   %ebp
c0105c3b:	89 e5                	mov    %esp,%ebp
c0105c3d:	53                   	push   %ebx
c0105c3e:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
c0105c44:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105c4b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0105c52:	c7 45 ec e4 40 12 c0 	movl   $0xc01240e4,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0105c59:	eb 6b                	jmp    c0105cc6 <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
c0105c5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105c5e:	83 e8 0c             	sub    $0xc,%eax
c0105c61:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
c0105c64:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105c67:	83 c0 04             	add    $0x4,%eax
c0105c6a:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0105c71:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105c74:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105c77:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105c7a:	0f a3 10             	bt     %edx,(%eax)
c0105c7d:	19 c0                	sbb    %eax,%eax
c0105c7f:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0105c82:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0105c86:	0f 95 c0             	setne  %al
c0105c89:	0f b6 c0             	movzbl %al,%eax
c0105c8c:	85 c0                	test   %eax,%eax
c0105c8e:	75 24                	jne    c0105cb4 <default_check+0x7a>
c0105c90:	c7 44 24 0c e6 a1 10 	movl   $0xc010a1e6,0xc(%esp)
c0105c97:	c0 
c0105c98:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c0105c9f:	c0 
c0105ca0:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
c0105ca7:	00 
c0105ca8:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c0105caf:	e8 44 a7 ff ff       	call   c01003f8 <__panic>
        count ++, total += p->property;
c0105cb4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0105cb8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105cbb:	8b 50 08             	mov    0x8(%eax),%edx
c0105cbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105cc1:	01 d0                	add    %edx,%eax
c0105cc3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105cc6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105cc9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c0105ccc:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105ccf:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0105cd2:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105cd5:	81 7d ec e4 40 12 c0 	cmpl   $0xc01240e4,-0x14(%ebp)
c0105cdc:	0f 85 79 ff ff ff    	jne    c0105c5b <default_check+0x21>
    }
    assert(total == nr_free_pages());
c0105ce2:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c0105ce5:	e8 ad 09 00 00       	call   c0106697 <nr_free_pages>
c0105cea:	39 c3                	cmp    %eax,%ebx
c0105cec:	74 24                	je     c0105d12 <default_check+0xd8>
c0105cee:	c7 44 24 0c f6 a1 10 	movl   $0xc010a1f6,0xc(%esp)
c0105cf5:	c0 
c0105cf6:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c0105cfd:	c0 
c0105cfe:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c0105d05:	00 
c0105d06:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c0105d0d:	e8 e6 a6 ff ff       	call   c01003f8 <__panic>

    basic_check();
c0105d12:	e8 e7 f9 ff ff       	call   c01056fe <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0105d17:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0105d1e:	e8 d7 08 00 00       	call   c01065fa <alloc_pages>
c0105d23:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
c0105d26:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105d2a:	75 24                	jne    c0105d50 <default_check+0x116>
c0105d2c:	c7 44 24 0c 0f a2 10 	movl   $0xc010a20f,0xc(%esp)
c0105d33:	c0 
c0105d34:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c0105d3b:	c0 
c0105d3c:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c0105d43:	00 
c0105d44:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c0105d4b:	e8 a8 a6 ff ff       	call   c01003f8 <__panic>
    assert(!PageProperty(p0));
c0105d50:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105d53:	83 c0 04             	add    $0x4,%eax
c0105d56:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0105d5d:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105d60:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0105d63:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0105d66:	0f a3 10             	bt     %edx,(%eax)
c0105d69:	19 c0                	sbb    %eax,%eax
c0105d6b:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0105d6e:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0105d72:	0f 95 c0             	setne  %al
c0105d75:	0f b6 c0             	movzbl %al,%eax
c0105d78:	85 c0                	test   %eax,%eax
c0105d7a:	74 24                	je     c0105da0 <default_check+0x166>
c0105d7c:	c7 44 24 0c 1a a2 10 	movl   $0xc010a21a,0xc(%esp)
c0105d83:	c0 
c0105d84:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c0105d8b:	c0 
c0105d8c:	c7 44 24 04 1b 01 00 	movl   $0x11b,0x4(%esp)
c0105d93:	00 
c0105d94:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c0105d9b:	e8 58 a6 ff ff       	call   c01003f8 <__panic>

    list_entry_t free_list_store = free_list;
c0105da0:	a1 e4 40 12 c0       	mov    0xc01240e4,%eax
c0105da5:	8b 15 e8 40 12 c0    	mov    0xc01240e8,%edx
c0105dab:	89 45 80             	mov    %eax,-0x80(%ebp)
c0105dae:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0105db1:	c7 45 b4 e4 40 12 c0 	movl   $0xc01240e4,-0x4c(%ebp)
    elm->prev = elm->next = elm;
c0105db8:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0105dbb:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0105dbe:	89 50 04             	mov    %edx,0x4(%eax)
c0105dc1:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0105dc4:	8b 50 04             	mov    0x4(%eax),%edx
c0105dc7:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0105dca:	89 10                	mov    %edx,(%eax)
c0105dcc:	c7 45 b0 e4 40 12 c0 	movl   $0xc01240e4,-0x50(%ebp)
    return list->next == list;
c0105dd3:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0105dd6:	8b 40 04             	mov    0x4(%eax),%eax
c0105dd9:	39 45 b0             	cmp    %eax,-0x50(%ebp)
c0105ddc:	0f 94 c0             	sete   %al
c0105ddf:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0105de2:	85 c0                	test   %eax,%eax
c0105de4:	75 24                	jne    c0105e0a <default_check+0x1d0>
c0105de6:	c7 44 24 0c 6f a1 10 	movl   $0xc010a16f,0xc(%esp)
c0105ded:	c0 
c0105dee:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c0105df5:	c0 
c0105df6:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
c0105dfd:	00 
c0105dfe:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c0105e05:	e8 ee a5 ff ff       	call   c01003f8 <__panic>
    assert(alloc_page() == NULL);
c0105e0a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105e11:	e8 e4 07 00 00       	call   c01065fa <alloc_pages>
c0105e16:	85 c0                	test   %eax,%eax
c0105e18:	74 24                	je     c0105e3e <default_check+0x204>
c0105e1a:	c7 44 24 0c 86 a1 10 	movl   $0xc010a186,0xc(%esp)
c0105e21:	c0 
c0105e22:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c0105e29:	c0 
c0105e2a:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
c0105e31:	00 
c0105e32:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c0105e39:	e8 ba a5 ff ff       	call   c01003f8 <__panic>

    unsigned int nr_free_store = nr_free;
c0105e3e:	a1 ec 40 12 c0       	mov    0xc01240ec,%eax
c0105e43:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c0105e46:	c7 05 ec 40 12 c0 00 	movl   $0x0,0xc01240ec
c0105e4d:	00 00 00 

    free_pages(p0 + 2, 3);
c0105e50:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105e53:	83 c0 40             	add    $0x40,%eax
c0105e56:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0105e5d:	00 
c0105e5e:	89 04 24             	mov    %eax,(%esp)
c0105e61:	e8 ff 07 00 00       	call   c0106665 <free_pages>
    assert(alloc_pages(4) == NULL);
c0105e66:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0105e6d:	e8 88 07 00 00       	call   c01065fa <alloc_pages>
c0105e72:	85 c0                	test   %eax,%eax
c0105e74:	74 24                	je     c0105e9a <default_check+0x260>
c0105e76:	c7 44 24 0c 2c a2 10 	movl   $0xc010a22c,0xc(%esp)
c0105e7d:	c0 
c0105e7e:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c0105e85:	c0 
c0105e86:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
c0105e8d:	00 
c0105e8e:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c0105e95:	e8 5e a5 ff ff       	call   c01003f8 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0105e9a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105e9d:	83 c0 40             	add    $0x40,%eax
c0105ea0:	83 c0 04             	add    $0x4,%eax
c0105ea3:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c0105eaa:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105ead:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0105eb0:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0105eb3:	0f a3 10             	bt     %edx,(%eax)
c0105eb6:	19 c0                	sbb    %eax,%eax
c0105eb8:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c0105ebb:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0105ebf:	0f 95 c0             	setne  %al
c0105ec2:	0f b6 c0             	movzbl %al,%eax
c0105ec5:	85 c0                	test   %eax,%eax
c0105ec7:	74 0e                	je     c0105ed7 <default_check+0x29d>
c0105ec9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105ecc:	83 c0 40             	add    $0x40,%eax
c0105ecf:	8b 40 08             	mov    0x8(%eax),%eax
c0105ed2:	83 f8 03             	cmp    $0x3,%eax
c0105ed5:	74 24                	je     c0105efb <default_check+0x2c1>
c0105ed7:	c7 44 24 0c 44 a2 10 	movl   $0xc010a244,0xc(%esp)
c0105ede:	c0 
c0105edf:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c0105ee6:	c0 
c0105ee7:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
c0105eee:	00 
c0105eef:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c0105ef6:	e8 fd a4 ff ff       	call   c01003f8 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0105efb:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0105f02:	e8 f3 06 00 00       	call   c01065fa <alloc_pages>
c0105f07:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105f0a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105f0e:	75 24                	jne    c0105f34 <default_check+0x2fa>
c0105f10:	c7 44 24 0c 70 a2 10 	movl   $0xc010a270,0xc(%esp)
c0105f17:	c0 
c0105f18:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c0105f1f:	c0 
c0105f20:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
c0105f27:	00 
c0105f28:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c0105f2f:	e8 c4 a4 ff ff       	call   c01003f8 <__panic>
    assert(alloc_page() == NULL);
c0105f34:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105f3b:	e8 ba 06 00 00       	call   c01065fa <alloc_pages>
c0105f40:	85 c0                	test   %eax,%eax
c0105f42:	74 24                	je     c0105f68 <default_check+0x32e>
c0105f44:	c7 44 24 0c 86 a1 10 	movl   $0xc010a186,0xc(%esp)
c0105f4b:	c0 
c0105f4c:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c0105f53:	c0 
c0105f54:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
c0105f5b:	00 
c0105f5c:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c0105f63:	e8 90 a4 ff ff       	call   c01003f8 <__panic>
    assert(p0 + 2 == p1);
c0105f68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105f6b:	83 c0 40             	add    $0x40,%eax
c0105f6e:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0105f71:	74 24                	je     c0105f97 <default_check+0x35d>
c0105f73:	c7 44 24 0c 8e a2 10 	movl   $0xc010a28e,0xc(%esp)
c0105f7a:	c0 
c0105f7b:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c0105f82:	c0 
c0105f83:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
c0105f8a:	00 
c0105f8b:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c0105f92:	e8 61 a4 ff ff       	call   c01003f8 <__panic>

    p2 = p0 + 1;
c0105f97:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105f9a:	83 c0 20             	add    $0x20,%eax
c0105f9d:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
c0105fa0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105fa7:	00 
c0105fa8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105fab:	89 04 24             	mov    %eax,(%esp)
c0105fae:	e8 b2 06 00 00       	call   c0106665 <free_pages>
    free_pages(p1, 3);
c0105fb3:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0105fba:	00 
c0105fbb:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105fbe:	89 04 24             	mov    %eax,(%esp)
c0105fc1:	e8 9f 06 00 00       	call   c0106665 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c0105fc6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105fc9:	83 c0 04             	add    $0x4,%eax
c0105fcc:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0105fd3:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105fd6:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0105fd9:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0105fdc:	0f a3 10             	bt     %edx,(%eax)
c0105fdf:	19 c0                	sbb    %eax,%eax
c0105fe1:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0105fe4:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0105fe8:	0f 95 c0             	setne  %al
c0105feb:	0f b6 c0             	movzbl %al,%eax
c0105fee:	85 c0                	test   %eax,%eax
c0105ff0:	74 0b                	je     c0105ffd <default_check+0x3c3>
c0105ff2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105ff5:	8b 40 08             	mov    0x8(%eax),%eax
c0105ff8:	83 f8 01             	cmp    $0x1,%eax
c0105ffb:	74 24                	je     c0106021 <default_check+0x3e7>
c0105ffd:	c7 44 24 0c 9c a2 10 	movl   $0xc010a29c,0xc(%esp)
c0106004:	c0 
c0106005:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c010600c:	c0 
c010600d:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
c0106014:	00 
c0106015:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c010601c:	e8 d7 a3 ff ff       	call   c01003f8 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0106021:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106024:	83 c0 04             	add    $0x4,%eax
c0106027:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c010602e:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106031:	8b 45 90             	mov    -0x70(%ebp),%eax
c0106034:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0106037:	0f a3 10             	bt     %edx,(%eax)
c010603a:	19 c0                	sbb    %eax,%eax
c010603c:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c010603f:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c0106043:	0f 95 c0             	setne  %al
c0106046:	0f b6 c0             	movzbl %al,%eax
c0106049:	85 c0                	test   %eax,%eax
c010604b:	74 0b                	je     c0106058 <default_check+0x41e>
c010604d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106050:	8b 40 08             	mov    0x8(%eax),%eax
c0106053:	83 f8 03             	cmp    $0x3,%eax
c0106056:	74 24                	je     c010607c <default_check+0x442>
c0106058:	c7 44 24 0c c4 a2 10 	movl   $0xc010a2c4,0xc(%esp)
c010605f:	c0 
c0106060:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c0106067:	c0 
c0106068:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
c010606f:	00 
c0106070:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c0106077:	e8 7c a3 ff ff       	call   c01003f8 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c010607c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106083:	e8 72 05 00 00       	call   c01065fa <alloc_pages>
c0106088:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010608b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010608e:	83 e8 20             	sub    $0x20,%eax
c0106091:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0106094:	74 24                	je     c01060ba <default_check+0x480>
c0106096:	c7 44 24 0c ea a2 10 	movl   $0xc010a2ea,0xc(%esp)
c010609d:	c0 
c010609e:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c01060a5:	c0 
c01060a6:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
c01060ad:	00 
c01060ae:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c01060b5:	e8 3e a3 ff ff       	call   c01003f8 <__panic>
    free_page(p0);
c01060ba:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01060c1:	00 
c01060c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01060c5:	89 04 24             	mov    %eax,(%esp)
c01060c8:	e8 98 05 00 00       	call   c0106665 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c01060cd:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c01060d4:	e8 21 05 00 00       	call   c01065fa <alloc_pages>
c01060d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01060dc:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01060df:	83 c0 20             	add    $0x20,%eax
c01060e2:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c01060e5:	74 24                	je     c010610b <default_check+0x4d1>
c01060e7:	c7 44 24 0c 08 a3 10 	movl   $0xc010a308,0xc(%esp)
c01060ee:	c0 
c01060ef:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c01060f6:	c0 
c01060f7:	c7 44 24 04 34 01 00 	movl   $0x134,0x4(%esp)
c01060fe:	00 
c01060ff:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c0106106:	e8 ed a2 ff ff       	call   c01003f8 <__panic>

    free_pages(p0, 2);
c010610b:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0106112:	00 
c0106113:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106116:	89 04 24             	mov    %eax,(%esp)
c0106119:	e8 47 05 00 00       	call   c0106665 <free_pages>
    free_page(p2);
c010611e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106125:	00 
c0106126:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106129:	89 04 24             	mov    %eax,(%esp)
c010612c:	e8 34 05 00 00       	call   c0106665 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c0106131:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0106138:	e8 bd 04 00 00       	call   c01065fa <alloc_pages>
c010613d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106140:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106144:	75 24                	jne    c010616a <default_check+0x530>
c0106146:	c7 44 24 0c 28 a3 10 	movl   $0xc010a328,0xc(%esp)
c010614d:	c0 
c010614e:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c0106155:	c0 
c0106156:	c7 44 24 04 39 01 00 	movl   $0x139,0x4(%esp)
c010615d:	00 
c010615e:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c0106165:	e8 8e a2 ff ff       	call   c01003f8 <__panic>
    assert(alloc_page() == NULL);
c010616a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106171:	e8 84 04 00 00       	call   c01065fa <alloc_pages>
c0106176:	85 c0                	test   %eax,%eax
c0106178:	74 24                	je     c010619e <default_check+0x564>
c010617a:	c7 44 24 0c 86 a1 10 	movl   $0xc010a186,0xc(%esp)
c0106181:	c0 
c0106182:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c0106189:	c0 
c010618a:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
c0106191:	00 
c0106192:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c0106199:	e8 5a a2 ff ff       	call   c01003f8 <__panic>

    assert(nr_free == 0);
c010619e:	a1 ec 40 12 c0       	mov    0xc01240ec,%eax
c01061a3:	85 c0                	test   %eax,%eax
c01061a5:	74 24                	je     c01061cb <default_check+0x591>
c01061a7:	c7 44 24 0c d9 a1 10 	movl   $0xc010a1d9,0xc(%esp)
c01061ae:	c0 
c01061af:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c01061b6:	c0 
c01061b7:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
c01061be:	00 
c01061bf:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c01061c6:	e8 2d a2 ff ff       	call   c01003f8 <__panic>
    nr_free = nr_free_store;
c01061cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01061ce:	a3 ec 40 12 c0       	mov    %eax,0xc01240ec

    free_list = free_list_store;
c01061d3:	8b 45 80             	mov    -0x80(%ebp),%eax
c01061d6:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01061d9:	a3 e4 40 12 c0       	mov    %eax,0xc01240e4
c01061de:	89 15 e8 40 12 c0    	mov    %edx,0xc01240e8
    free_pages(p0, 5);
c01061e4:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c01061eb:	00 
c01061ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01061ef:	89 04 24             	mov    %eax,(%esp)
c01061f2:	e8 6e 04 00 00       	call   c0106665 <free_pages>

    le = &free_list;
c01061f7:	c7 45 ec e4 40 12 c0 	movl   $0xc01240e4,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01061fe:	eb 1d                	jmp    c010621d <default_check+0x5e3>
        struct Page *p = le2page(le, page_link);
c0106200:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106203:	83 e8 0c             	sub    $0xc,%eax
c0106206:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
c0106209:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c010620d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0106210:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106213:	8b 40 08             	mov    0x8(%eax),%eax
c0106216:	29 c2                	sub    %eax,%edx
c0106218:	89 d0                	mov    %edx,%eax
c010621a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010621d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106220:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c0106223:	8b 45 88             	mov    -0x78(%ebp),%eax
c0106226:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0106229:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010622c:	81 7d ec e4 40 12 c0 	cmpl   $0xc01240e4,-0x14(%ebp)
c0106233:	75 cb                	jne    c0106200 <default_check+0x5c6>
    }
    assert(count == 0);
c0106235:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106239:	74 24                	je     c010625f <default_check+0x625>
c010623b:	c7 44 24 0c 46 a3 10 	movl   $0xc010a346,0xc(%esp)
c0106242:	c0 
c0106243:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c010624a:	c0 
c010624b:	c7 44 24 04 47 01 00 	movl   $0x147,0x4(%esp)
c0106252:	00 
c0106253:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c010625a:	e8 99 a1 ff ff       	call   c01003f8 <__panic>
    assert(total == 0);
c010625f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106263:	74 24                	je     c0106289 <default_check+0x64f>
c0106265:	c7 44 24 0c 51 a3 10 	movl   $0xc010a351,0xc(%esp)
c010626c:	c0 
c010626d:	c7 44 24 08 16 a0 10 	movl   $0xc010a016,0x8(%esp)
c0106274:	c0 
c0106275:	c7 44 24 04 48 01 00 	movl   $0x148,0x4(%esp)
c010627c:	00 
c010627d:	c7 04 24 2b a0 10 c0 	movl   $0xc010a02b,(%esp)
c0106284:	e8 6f a1 ff ff       	call   c01003f8 <__panic>
}
c0106289:	81 c4 94 00 00 00    	add    $0x94,%esp
c010628f:	5b                   	pop    %ebx
c0106290:	5d                   	pop    %ebp
c0106291:	c3                   	ret    

c0106292 <page2ppn>:
page2ppn(struct Page *page) {
c0106292:	55                   	push   %ebp
c0106293:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0106295:	8b 55 08             	mov    0x8(%ebp),%edx
c0106298:	a1 f8 40 12 c0       	mov    0xc01240f8,%eax
c010629d:	29 c2                	sub    %eax,%edx
c010629f:	89 d0                	mov    %edx,%eax
c01062a1:	c1 f8 05             	sar    $0x5,%eax
}
c01062a4:	5d                   	pop    %ebp
c01062a5:	c3                   	ret    

c01062a6 <page2pa>:
page2pa(struct Page *page) {
c01062a6:	55                   	push   %ebp
c01062a7:	89 e5                	mov    %esp,%ebp
c01062a9:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01062ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01062af:	89 04 24             	mov    %eax,(%esp)
c01062b2:	e8 db ff ff ff       	call   c0106292 <page2ppn>
c01062b7:	c1 e0 0c             	shl    $0xc,%eax
}
c01062ba:	c9                   	leave  
c01062bb:	c3                   	ret    

c01062bc <pa2page>:
pa2page(uintptr_t pa) {
c01062bc:	55                   	push   %ebp
c01062bd:	89 e5                	mov    %esp,%ebp
c01062bf:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c01062c2:	8b 45 08             	mov    0x8(%ebp),%eax
c01062c5:	c1 e8 0c             	shr    $0xc,%eax
c01062c8:	89 c2                	mov    %eax,%edx
c01062ca:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c01062cf:	39 c2                	cmp    %eax,%edx
c01062d1:	72 1c                	jb     c01062ef <pa2page+0x33>
        panic("pa2page called with invalid pa");
c01062d3:	c7 44 24 08 8c a3 10 	movl   $0xc010a38c,0x8(%esp)
c01062da:	c0 
c01062db:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c01062e2:	00 
c01062e3:	c7 04 24 ab a3 10 c0 	movl   $0xc010a3ab,(%esp)
c01062ea:	e8 09 a1 ff ff       	call   c01003f8 <__panic>
    return &pages[PPN(pa)];
c01062ef:	a1 f8 40 12 c0       	mov    0xc01240f8,%eax
c01062f4:	8b 55 08             	mov    0x8(%ebp),%edx
c01062f7:	c1 ea 0c             	shr    $0xc,%edx
c01062fa:	c1 e2 05             	shl    $0x5,%edx
c01062fd:	01 d0                	add    %edx,%eax
}
c01062ff:	c9                   	leave  
c0106300:	c3                   	ret    

c0106301 <page2kva>:
page2kva(struct Page *page) {
c0106301:	55                   	push   %ebp
c0106302:	89 e5                	mov    %esp,%ebp
c0106304:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0106307:	8b 45 08             	mov    0x8(%ebp),%eax
c010630a:	89 04 24             	mov    %eax,(%esp)
c010630d:	e8 94 ff ff ff       	call   c01062a6 <page2pa>
c0106312:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106315:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106318:	c1 e8 0c             	shr    $0xc,%eax
c010631b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010631e:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c0106323:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0106326:	72 23                	jb     c010634b <page2kva+0x4a>
c0106328:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010632b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010632f:	c7 44 24 08 bc a3 10 	movl   $0xc010a3bc,0x8(%esp)
c0106336:	c0 
c0106337:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
c010633e:	00 
c010633f:	c7 04 24 ab a3 10 c0 	movl   $0xc010a3ab,(%esp)
c0106346:	e8 ad a0 ff ff       	call   c01003f8 <__panic>
c010634b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010634e:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0106353:	c9                   	leave  
c0106354:	c3                   	ret    

c0106355 <kva2page>:
kva2page(void *kva) {
c0106355:	55                   	push   %ebp
c0106356:	89 e5                	mov    %esp,%ebp
c0106358:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c010635b:	8b 45 08             	mov    0x8(%ebp),%eax
c010635e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106361:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0106368:	77 23                	ja     c010638d <kva2page+0x38>
c010636a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010636d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106371:	c7 44 24 08 e0 a3 10 	movl   $0xc010a3e0,0x8(%esp)
c0106378:	c0 
c0106379:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c0106380:	00 
c0106381:	c7 04 24 ab a3 10 c0 	movl   $0xc010a3ab,(%esp)
c0106388:	e8 6b a0 ff ff       	call   c01003f8 <__panic>
c010638d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106390:	05 00 00 00 40       	add    $0x40000000,%eax
c0106395:	89 04 24             	mov    %eax,(%esp)
c0106398:	e8 1f ff ff ff       	call   c01062bc <pa2page>
}
c010639d:	c9                   	leave  
c010639e:	c3                   	ret    

c010639f <pte2page>:
pte2page(pte_t pte) {
c010639f:	55                   	push   %ebp
c01063a0:	89 e5                	mov    %esp,%ebp
c01063a2:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c01063a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01063a8:	83 e0 01             	and    $0x1,%eax
c01063ab:	85 c0                	test   %eax,%eax
c01063ad:	75 1c                	jne    c01063cb <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c01063af:	c7 44 24 08 04 a4 10 	movl   $0xc010a404,0x8(%esp)
c01063b6:	c0 
c01063b7:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c01063be:	00 
c01063bf:	c7 04 24 ab a3 10 c0 	movl   $0xc010a3ab,(%esp)
c01063c6:	e8 2d a0 ff ff       	call   c01003f8 <__panic>
    return pa2page(PTE_ADDR(pte));
c01063cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01063ce:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01063d3:	89 04 24             	mov    %eax,(%esp)
c01063d6:	e8 e1 fe ff ff       	call   c01062bc <pa2page>
}
c01063db:	c9                   	leave  
c01063dc:	c3                   	ret    

c01063dd <pde2page>:
pde2page(pde_t pde) {
c01063dd:	55                   	push   %ebp
c01063de:	89 e5                	mov    %esp,%ebp
c01063e0:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c01063e3:	8b 45 08             	mov    0x8(%ebp),%eax
c01063e6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01063eb:	89 04 24             	mov    %eax,(%esp)
c01063ee:	e8 c9 fe ff ff       	call   c01062bc <pa2page>
}
c01063f3:	c9                   	leave  
c01063f4:	c3                   	ret    

c01063f5 <page_ref>:
page_ref(struct Page *page) {
c01063f5:	55                   	push   %ebp
c01063f6:	89 e5                	mov    %esp,%ebp
    return page->ref;
c01063f8:	8b 45 08             	mov    0x8(%ebp),%eax
c01063fb:	8b 00                	mov    (%eax),%eax
}
c01063fd:	5d                   	pop    %ebp
c01063fe:	c3                   	ret    

c01063ff <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c01063ff:	55                   	push   %ebp
c0106400:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0106402:	8b 45 08             	mov    0x8(%ebp),%eax
c0106405:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106408:	89 10                	mov    %edx,(%eax)
}
c010640a:	5d                   	pop    %ebp
c010640b:	c3                   	ret    

c010640c <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c010640c:	55                   	push   %ebp
c010640d:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c010640f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106412:	8b 00                	mov    (%eax),%eax
c0106414:	8d 50 01             	lea    0x1(%eax),%edx
c0106417:	8b 45 08             	mov    0x8(%ebp),%eax
c010641a:	89 10                	mov    %edx,(%eax)
    return page->ref;
c010641c:	8b 45 08             	mov    0x8(%ebp),%eax
c010641f:	8b 00                	mov    (%eax),%eax
}
c0106421:	5d                   	pop    %ebp
c0106422:	c3                   	ret    

c0106423 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0106423:	55                   	push   %ebp
c0106424:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0106426:	8b 45 08             	mov    0x8(%ebp),%eax
c0106429:	8b 00                	mov    (%eax),%eax
c010642b:	8d 50 ff             	lea    -0x1(%eax),%edx
c010642e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106431:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0106433:	8b 45 08             	mov    0x8(%ebp),%eax
c0106436:	8b 00                	mov    (%eax),%eax
}
c0106438:	5d                   	pop    %ebp
c0106439:	c3                   	ret    

c010643a <__intr_save>:
__intr_save(void) {
c010643a:	55                   	push   %ebp
c010643b:	89 e5                	mov    %esp,%ebp
c010643d:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0106440:	9c                   	pushf  
c0106441:	58                   	pop    %eax
c0106442:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0106445:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0106448:	25 00 02 00 00       	and    $0x200,%eax
c010644d:	85 c0                	test   %eax,%eax
c010644f:	74 0c                	je     c010645d <__intr_save+0x23>
        intr_disable();
c0106451:	e8 bf bc ff ff       	call   c0102115 <intr_disable>
        return 1;
c0106456:	b8 01 00 00 00       	mov    $0x1,%eax
c010645b:	eb 05                	jmp    c0106462 <__intr_save+0x28>
    return 0;
c010645d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106462:	c9                   	leave  
c0106463:	c3                   	ret    

c0106464 <__intr_restore>:
__intr_restore(bool flag) {
c0106464:	55                   	push   %ebp
c0106465:	89 e5                	mov    %esp,%ebp
c0106467:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c010646a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010646e:	74 05                	je     c0106475 <__intr_restore+0x11>
        intr_enable();
c0106470:	e8 9a bc ff ff       	call   c010210f <intr_enable>
}
c0106475:	c9                   	leave  
c0106476:	c3                   	ret    

c0106477 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0106477:	55                   	push   %ebp
c0106478:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c010647a:	8b 45 08             	mov    0x8(%ebp),%eax
c010647d:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0106480:	b8 23 00 00 00       	mov    $0x23,%eax
c0106485:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0106487:	b8 23 00 00 00       	mov    $0x23,%eax
c010648c:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c010648e:	b8 10 00 00 00       	mov    $0x10,%eax
c0106493:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0106495:	b8 10 00 00 00       	mov    $0x10,%eax
c010649a:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c010649c:	b8 10 00 00 00       	mov    $0x10,%eax
c01064a1:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c01064a3:	ea aa 64 10 c0 08 00 	ljmp   $0x8,$0xc01064aa
}
c01064aa:	5d                   	pop    %ebp
c01064ab:	c3                   	ret    

c01064ac <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c01064ac:	55                   	push   %ebp
c01064ad:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c01064af:	8b 45 08             	mov    0x8(%ebp),%eax
c01064b2:	a3 a4 3f 12 c0       	mov    %eax,0xc0123fa4
}
c01064b7:	5d                   	pop    %ebp
c01064b8:	c3                   	ret    

c01064b9 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c01064b9:	55                   	push   %ebp
c01064ba:	89 e5                	mov    %esp,%ebp
c01064bc:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c01064bf:	b8 00 00 12 c0       	mov    $0xc0120000,%eax
c01064c4:	89 04 24             	mov    %eax,(%esp)
c01064c7:	e8 e0 ff ff ff       	call   c01064ac <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c01064cc:	66 c7 05 a8 3f 12 c0 	movw   $0x10,0xc0123fa8
c01064d3:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c01064d5:	66 c7 05 48 0a 12 c0 	movw   $0x68,0xc0120a48
c01064dc:	68 00 
c01064de:	b8 a0 3f 12 c0       	mov    $0xc0123fa0,%eax
c01064e3:	66 a3 4a 0a 12 c0    	mov    %ax,0xc0120a4a
c01064e9:	b8 a0 3f 12 c0       	mov    $0xc0123fa0,%eax
c01064ee:	c1 e8 10             	shr    $0x10,%eax
c01064f1:	a2 4c 0a 12 c0       	mov    %al,0xc0120a4c
c01064f6:	0f b6 05 4d 0a 12 c0 	movzbl 0xc0120a4d,%eax
c01064fd:	83 e0 f0             	and    $0xfffffff0,%eax
c0106500:	83 c8 09             	or     $0x9,%eax
c0106503:	a2 4d 0a 12 c0       	mov    %al,0xc0120a4d
c0106508:	0f b6 05 4d 0a 12 c0 	movzbl 0xc0120a4d,%eax
c010650f:	83 e0 ef             	and    $0xffffffef,%eax
c0106512:	a2 4d 0a 12 c0       	mov    %al,0xc0120a4d
c0106517:	0f b6 05 4d 0a 12 c0 	movzbl 0xc0120a4d,%eax
c010651e:	83 e0 9f             	and    $0xffffff9f,%eax
c0106521:	a2 4d 0a 12 c0       	mov    %al,0xc0120a4d
c0106526:	0f b6 05 4d 0a 12 c0 	movzbl 0xc0120a4d,%eax
c010652d:	83 c8 80             	or     $0xffffff80,%eax
c0106530:	a2 4d 0a 12 c0       	mov    %al,0xc0120a4d
c0106535:	0f b6 05 4e 0a 12 c0 	movzbl 0xc0120a4e,%eax
c010653c:	83 e0 f0             	and    $0xfffffff0,%eax
c010653f:	a2 4e 0a 12 c0       	mov    %al,0xc0120a4e
c0106544:	0f b6 05 4e 0a 12 c0 	movzbl 0xc0120a4e,%eax
c010654b:	83 e0 ef             	and    $0xffffffef,%eax
c010654e:	a2 4e 0a 12 c0       	mov    %al,0xc0120a4e
c0106553:	0f b6 05 4e 0a 12 c0 	movzbl 0xc0120a4e,%eax
c010655a:	83 e0 df             	and    $0xffffffdf,%eax
c010655d:	a2 4e 0a 12 c0       	mov    %al,0xc0120a4e
c0106562:	0f b6 05 4e 0a 12 c0 	movzbl 0xc0120a4e,%eax
c0106569:	83 c8 40             	or     $0x40,%eax
c010656c:	a2 4e 0a 12 c0       	mov    %al,0xc0120a4e
c0106571:	0f b6 05 4e 0a 12 c0 	movzbl 0xc0120a4e,%eax
c0106578:	83 e0 7f             	and    $0x7f,%eax
c010657b:	a2 4e 0a 12 c0       	mov    %al,0xc0120a4e
c0106580:	b8 a0 3f 12 c0       	mov    $0xc0123fa0,%eax
c0106585:	c1 e8 18             	shr    $0x18,%eax
c0106588:	a2 4f 0a 12 c0       	mov    %al,0xc0120a4f

    // reload all segment registers
    lgdt(&gdt_pd);
c010658d:	c7 04 24 50 0a 12 c0 	movl   $0xc0120a50,(%esp)
c0106594:	e8 de fe ff ff       	call   c0106477 <lgdt>
c0106599:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c010659f:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c01065a3:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c01065a6:	c9                   	leave  
c01065a7:	c3                   	ret    

c01065a8 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c01065a8:	55                   	push   %ebp
c01065a9:	89 e5                	mov    %esp,%ebp
c01065ab:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c01065ae:	c7 05 f0 40 12 c0 70 	movl   $0xc010a370,0xc01240f0
c01065b5:	a3 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c01065b8:	a1 f0 40 12 c0       	mov    0xc01240f0,%eax
c01065bd:	8b 00                	mov    (%eax),%eax
c01065bf:	89 44 24 04          	mov    %eax,0x4(%esp)
c01065c3:	c7 04 24 30 a4 10 c0 	movl   $0xc010a430,(%esp)
c01065ca:	e8 d2 9c ff ff       	call   c01002a1 <cprintf>
    pmm_manager->init();
c01065cf:	a1 f0 40 12 c0       	mov    0xc01240f0,%eax
c01065d4:	8b 40 04             	mov    0x4(%eax),%eax
c01065d7:	ff d0                	call   *%eax
}
c01065d9:	c9                   	leave  
c01065da:	c3                   	ret    

c01065db <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c01065db:	55                   	push   %ebp
c01065dc:	89 e5                	mov    %esp,%ebp
c01065de:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c01065e1:	a1 f0 40 12 c0       	mov    0xc01240f0,%eax
c01065e6:	8b 40 08             	mov    0x8(%eax),%eax
c01065e9:	8b 55 0c             	mov    0xc(%ebp),%edx
c01065ec:	89 54 24 04          	mov    %edx,0x4(%esp)
c01065f0:	8b 55 08             	mov    0x8(%ebp),%edx
c01065f3:	89 14 24             	mov    %edx,(%esp)
c01065f6:	ff d0                	call   *%eax
}
c01065f8:	c9                   	leave  
c01065f9:	c3                   	ret    

c01065fa <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c01065fa:	55                   	push   %ebp
c01065fb:	89 e5                	mov    %esp,%ebp
c01065fd:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0106600:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    
    while (1)
    {
         local_intr_save(intr_flag);
c0106607:	e8 2e fe ff ff       	call   c010643a <__intr_save>
c010660c:	89 45 f0             	mov    %eax,-0x10(%ebp)
         {
              page = pmm_manager->alloc_pages(n);
c010660f:	a1 f0 40 12 c0       	mov    0xc01240f0,%eax
c0106614:	8b 40 0c             	mov    0xc(%eax),%eax
c0106617:	8b 55 08             	mov    0x8(%ebp),%edx
c010661a:	89 14 24             	mov    %edx,(%esp)
c010661d:	ff d0                	call   *%eax
c010661f:	89 45 f4             	mov    %eax,-0xc(%ebp)
         }
         local_intr_restore(intr_flag);
c0106622:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106625:	89 04 24             	mov    %eax,(%esp)
c0106628:	e8 37 fe ff ff       	call   c0106464 <__intr_restore>

         if (page != NULL || n > 1 || swap_init_ok == 0) break;
c010662d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106631:	75 2d                	jne    c0106660 <alloc_pages+0x66>
c0106633:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
c0106637:	77 27                	ja     c0106660 <alloc_pages+0x66>
c0106639:	a1 68 3f 12 c0       	mov    0xc0123f68,%eax
c010663e:	85 c0                	test   %eax,%eax
c0106640:	74 1e                	je     c0106660 <alloc_pages+0x66>
         
         extern struct mm_struct *check_mm_struct;
         //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
         swap_out(check_mm_struct, n, 0);
c0106642:	8b 55 08             	mov    0x8(%ebp),%edx
c0106645:	a1 10 40 12 c0       	mov    0xc0124010,%eax
c010664a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106651:	00 
c0106652:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106656:	89 04 24             	mov    %eax,(%esp)
c0106659:	e8 a5 e0 ff ff       	call   c0104703 <swap_out>
    }
c010665e:	eb a7                	jmp    c0106607 <alloc_pages+0xd>
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
c0106660:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106663:	c9                   	leave  
c0106664:	c3                   	ret    

c0106665 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0106665:	55                   	push   %ebp
c0106666:	89 e5                	mov    %esp,%ebp
c0106668:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c010666b:	e8 ca fd ff ff       	call   c010643a <__intr_save>
c0106670:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0106673:	a1 f0 40 12 c0       	mov    0xc01240f0,%eax
c0106678:	8b 40 10             	mov    0x10(%eax),%eax
c010667b:	8b 55 0c             	mov    0xc(%ebp),%edx
c010667e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106682:	8b 55 08             	mov    0x8(%ebp),%edx
c0106685:	89 14 24             	mov    %edx,(%esp)
c0106688:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c010668a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010668d:	89 04 24             	mov    %eax,(%esp)
c0106690:	e8 cf fd ff ff       	call   c0106464 <__intr_restore>
}
c0106695:	c9                   	leave  
c0106696:	c3                   	ret    

c0106697 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0106697:	55                   	push   %ebp
c0106698:	89 e5                	mov    %esp,%ebp
c010669a:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c010669d:	e8 98 fd ff ff       	call   c010643a <__intr_save>
c01066a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c01066a5:	a1 f0 40 12 c0       	mov    0xc01240f0,%eax
c01066aa:	8b 40 14             	mov    0x14(%eax),%eax
c01066ad:	ff d0                	call   *%eax
c01066af:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c01066b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01066b5:	89 04 24             	mov    %eax,(%esp)
c01066b8:	e8 a7 fd ff ff       	call   c0106464 <__intr_restore>
    return ret;
c01066bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01066c0:	c9                   	leave  
c01066c1:	c3                   	ret    

c01066c2 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c01066c2:	55                   	push   %ebp
c01066c3:	89 e5                	mov    %esp,%ebp
c01066c5:	57                   	push   %edi
c01066c6:	56                   	push   %esi
c01066c7:	53                   	push   %ebx
c01066c8:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c01066ce:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c01066d5:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c01066dc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c01066e3:	c7 04 24 47 a4 10 c0 	movl   $0xc010a447,(%esp)
c01066ea:	e8 b2 9b ff ff       	call   c01002a1 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c01066ef:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01066f6:	e9 15 01 00 00       	jmp    c0106810 <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c01066fb:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01066fe:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106701:	89 d0                	mov    %edx,%eax
c0106703:	c1 e0 02             	shl    $0x2,%eax
c0106706:	01 d0                	add    %edx,%eax
c0106708:	c1 e0 02             	shl    $0x2,%eax
c010670b:	01 c8                	add    %ecx,%eax
c010670d:	8b 50 08             	mov    0x8(%eax),%edx
c0106710:	8b 40 04             	mov    0x4(%eax),%eax
c0106713:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0106716:	89 55 bc             	mov    %edx,-0x44(%ebp)
c0106719:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010671c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010671f:	89 d0                	mov    %edx,%eax
c0106721:	c1 e0 02             	shl    $0x2,%eax
c0106724:	01 d0                	add    %edx,%eax
c0106726:	c1 e0 02             	shl    $0x2,%eax
c0106729:	01 c8                	add    %ecx,%eax
c010672b:	8b 48 0c             	mov    0xc(%eax),%ecx
c010672e:	8b 58 10             	mov    0x10(%eax),%ebx
c0106731:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0106734:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0106737:	01 c8                	add    %ecx,%eax
c0106739:	11 da                	adc    %ebx,%edx
c010673b:	89 45 b0             	mov    %eax,-0x50(%ebp)
c010673e:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0106741:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106744:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106747:	89 d0                	mov    %edx,%eax
c0106749:	c1 e0 02             	shl    $0x2,%eax
c010674c:	01 d0                	add    %edx,%eax
c010674e:	c1 e0 02             	shl    $0x2,%eax
c0106751:	01 c8                	add    %ecx,%eax
c0106753:	83 c0 14             	add    $0x14,%eax
c0106756:	8b 00                	mov    (%eax),%eax
c0106758:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c010675e:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0106761:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0106764:	83 c0 ff             	add    $0xffffffff,%eax
c0106767:	83 d2 ff             	adc    $0xffffffff,%edx
c010676a:	89 c6                	mov    %eax,%esi
c010676c:	89 d7                	mov    %edx,%edi
c010676e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106771:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106774:	89 d0                	mov    %edx,%eax
c0106776:	c1 e0 02             	shl    $0x2,%eax
c0106779:	01 d0                	add    %edx,%eax
c010677b:	c1 e0 02             	shl    $0x2,%eax
c010677e:	01 c8                	add    %ecx,%eax
c0106780:	8b 48 0c             	mov    0xc(%eax),%ecx
c0106783:	8b 58 10             	mov    0x10(%eax),%ebx
c0106786:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c010678c:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c0106790:	89 74 24 14          	mov    %esi,0x14(%esp)
c0106794:	89 7c 24 18          	mov    %edi,0x18(%esp)
c0106798:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010679b:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010679e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01067a2:	89 54 24 10          	mov    %edx,0x10(%esp)
c01067a6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c01067aa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c01067ae:	c7 04 24 54 a4 10 c0 	movl   $0xc010a454,(%esp)
c01067b5:	e8 e7 9a ff ff       	call   c01002a1 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c01067ba:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01067bd:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01067c0:	89 d0                	mov    %edx,%eax
c01067c2:	c1 e0 02             	shl    $0x2,%eax
c01067c5:	01 d0                	add    %edx,%eax
c01067c7:	c1 e0 02             	shl    $0x2,%eax
c01067ca:	01 c8                	add    %ecx,%eax
c01067cc:	83 c0 14             	add    $0x14,%eax
c01067cf:	8b 00                	mov    (%eax),%eax
c01067d1:	83 f8 01             	cmp    $0x1,%eax
c01067d4:	75 36                	jne    c010680c <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
c01067d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01067d9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01067dc:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c01067df:	77 2b                	ja     c010680c <page_init+0x14a>
c01067e1:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c01067e4:	72 05                	jb     c01067eb <page_init+0x129>
c01067e6:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c01067e9:	73 21                	jae    c010680c <page_init+0x14a>
c01067eb:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c01067ef:	77 1b                	ja     c010680c <page_init+0x14a>
c01067f1:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c01067f5:	72 09                	jb     c0106800 <page_init+0x13e>
c01067f7:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c01067fe:	77 0c                	ja     c010680c <page_init+0x14a>
                maxpa = end;
c0106800:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0106803:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0106806:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106809:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
c010680c:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0106810:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0106813:	8b 00                	mov    (%eax),%eax
c0106815:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0106818:	0f 8f dd fe ff ff    	jg     c01066fb <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c010681e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106822:	72 1d                	jb     c0106841 <page_init+0x17f>
c0106824:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106828:	77 09                	ja     c0106833 <page_init+0x171>
c010682a:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0106831:	76 0e                	jbe    c0106841 <page_init+0x17f>
        maxpa = KMEMSIZE;
c0106833:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c010683a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0106841:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106844:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106847:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c010684b:	c1 ea 0c             	shr    $0xc,%edx
c010684e:	a3 80 3f 12 c0       	mov    %eax,0xc0123f80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0106853:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c010685a:	b8 fc 40 12 c0       	mov    $0xc01240fc,%eax
c010685f:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106862:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0106865:	01 d0                	add    %edx,%eax
c0106867:	89 45 a8             	mov    %eax,-0x58(%ebp)
c010686a:	8b 45 a8             	mov    -0x58(%ebp),%eax
c010686d:	ba 00 00 00 00       	mov    $0x0,%edx
c0106872:	f7 75 ac             	divl   -0x54(%ebp)
c0106875:	89 d0                	mov    %edx,%eax
c0106877:	8b 55 a8             	mov    -0x58(%ebp),%edx
c010687a:	29 c2                	sub    %eax,%edx
c010687c:	89 d0                	mov    %edx,%eax
c010687e:	a3 f8 40 12 c0       	mov    %eax,0xc01240f8

    for (i = 0; i < npage; i ++) {
c0106883:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010688a:	eb 27                	jmp    c01068b3 <page_init+0x1f1>
        SetPageReserved(pages + i);
c010688c:	a1 f8 40 12 c0       	mov    0xc01240f8,%eax
c0106891:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106894:	c1 e2 05             	shl    $0x5,%edx
c0106897:	01 d0                	add    %edx,%eax
c0106899:	83 c0 04             	add    $0x4,%eax
c010689c:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c01068a3:	89 45 8c             	mov    %eax,-0x74(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01068a6:	8b 45 8c             	mov    -0x74(%ebp),%eax
c01068a9:	8b 55 90             	mov    -0x70(%ebp),%edx
c01068ac:	0f ab 10             	bts    %edx,(%eax)
    for (i = 0; i < npage; i ++) {
c01068af:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c01068b3:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01068b6:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c01068bb:	39 c2                	cmp    %eax,%edx
c01068bd:	72 cd                	jb     c010688c <page_init+0x1ca>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c01068bf:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c01068c4:	c1 e0 05             	shl    $0x5,%eax
c01068c7:	89 c2                	mov    %eax,%edx
c01068c9:	a1 f8 40 12 c0       	mov    0xc01240f8,%eax
c01068ce:	01 d0                	add    %edx,%eax
c01068d0:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c01068d3:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c01068da:	77 23                	ja     c01068ff <page_init+0x23d>
c01068dc:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01068df:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01068e3:	c7 44 24 08 e0 a3 10 	movl   $0xc010a3e0,0x8(%esp)
c01068ea:	c0 
c01068eb:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c01068f2:	00 
c01068f3:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c01068fa:	e8 f9 9a ff ff       	call   c01003f8 <__panic>
c01068ff:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106902:	05 00 00 00 40       	add    $0x40000000,%eax
c0106907:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c010690a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0106911:	e9 74 01 00 00       	jmp    c0106a8a <page_init+0x3c8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0106916:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106919:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010691c:	89 d0                	mov    %edx,%eax
c010691e:	c1 e0 02             	shl    $0x2,%eax
c0106921:	01 d0                	add    %edx,%eax
c0106923:	c1 e0 02             	shl    $0x2,%eax
c0106926:	01 c8                	add    %ecx,%eax
c0106928:	8b 50 08             	mov    0x8(%eax),%edx
c010692b:	8b 40 04             	mov    0x4(%eax),%eax
c010692e:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0106931:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0106934:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106937:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010693a:	89 d0                	mov    %edx,%eax
c010693c:	c1 e0 02             	shl    $0x2,%eax
c010693f:	01 d0                	add    %edx,%eax
c0106941:	c1 e0 02             	shl    $0x2,%eax
c0106944:	01 c8                	add    %ecx,%eax
c0106946:	8b 48 0c             	mov    0xc(%eax),%ecx
c0106949:	8b 58 10             	mov    0x10(%eax),%ebx
c010694c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010694f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106952:	01 c8                	add    %ecx,%eax
c0106954:	11 da                	adc    %ebx,%edx
c0106956:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0106959:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c010695c:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010695f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106962:	89 d0                	mov    %edx,%eax
c0106964:	c1 e0 02             	shl    $0x2,%eax
c0106967:	01 d0                	add    %edx,%eax
c0106969:	c1 e0 02             	shl    $0x2,%eax
c010696c:	01 c8                	add    %ecx,%eax
c010696e:	83 c0 14             	add    $0x14,%eax
c0106971:	8b 00                	mov    (%eax),%eax
c0106973:	83 f8 01             	cmp    $0x1,%eax
c0106976:	0f 85 0a 01 00 00    	jne    c0106a86 <page_init+0x3c4>
            if (begin < freemem) {
c010697c:	8b 45 a0             	mov    -0x60(%ebp),%eax
c010697f:	ba 00 00 00 00       	mov    $0x0,%edx
c0106984:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0106987:	72 17                	jb     c01069a0 <page_init+0x2de>
c0106989:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010698c:	77 05                	ja     c0106993 <page_init+0x2d1>
c010698e:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0106991:	76 0d                	jbe    c01069a0 <page_init+0x2de>
                begin = freemem;
c0106993:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0106996:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0106999:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c01069a0:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01069a4:	72 1d                	jb     c01069c3 <page_init+0x301>
c01069a6:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01069aa:	77 09                	ja     c01069b5 <page_init+0x2f3>
c01069ac:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c01069b3:	76 0e                	jbe    c01069c3 <page_init+0x301>
                end = KMEMSIZE;
c01069b5:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c01069bc:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c01069c3:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01069c6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01069c9:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01069cc:	0f 87 b4 00 00 00    	ja     c0106a86 <page_init+0x3c4>
c01069d2:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01069d5:	72 09                	jb     c01069e0 <page_init+0x31e>
c01069d7:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c01069da:	0f 83 a6 00 00 00    	jae    c0106a86 <page_init+0x3c4>
                begin = ROUNDUP(begin, PGSIZE);
c01069e0:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c01069e7:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01069ea:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01069ed:	01 d0                	add    %edx,%eax
c01069ef:	83 e8 01             	sub    $0x1,%eax
c01069f2:	89 45 98             	mov    %eax,-0x68(%ebp)
c01069f5:	8b 45 98             	mov    -0x68(%ebp),%eax
c01069f8:	ba 00 00 00 00       	mov    $0x0,%edx
c01069fd:	f7 75 9c             	divl   -0x64(%ebp)
c0106a00:	89 d0                	mov    %edx,%eax
c0106a02:	8b 55 98             	mov    -0x68(%ebp),%edx
c0106a05:	29 c2                	sub    %eax,%edx
c0106a07:	89 d0                	mov    %edx,%eax
c0106a09:	ba 00 00 00 00       	mov    $0x0,%edx
c0106a0e:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0106a11:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0106a14:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106a17:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0106a1a:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0106a1d:	ba 00 00 00 00       	mov    $0x0,%edx
c0106a22:	89 c7                	mov    %eax,%edi
c0106a24:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c0106a2a:	89 7d 80             	mov    %edi,-0x80(%ebp)
c0106a2d:	89 d0                	mov    %edx,%eax
c0106a2f:	83 e0 00             	and    $0x0,%eax
c0106a32:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0106a35:	8b 45 80             	mov    -0x80(%ebp),%eax
c0106a38:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0106a3b:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0106a3e:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c0106a41:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106a44:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106a47:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0106a4a:	77 3a                	ja     c0106a86 <page_init+0x3c4>
c0106a4c:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0106a4f:	72 05                	jb     c0106a56 <page_init+0x394>
c0106a51:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0106a54:	73 30                	jae    c0106a86 <page_init+0x3c4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0106a56:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c0106a59:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
c0106a5c:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106a5f:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0106a62:	29 c8                	sub    %ecx,%eax
c0106a64:	19 da                	sbb    %ebx,%edx
c0106a66:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0106a6a:	c1 ea 0c             	shr    $0xc,%edx
c0106a6d:	89 c3                	mov    %eax,%ebx
c0106a6f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106a72:	89 04 24             	mov    %eax,(%esp)
c0106a75:	e8 42 f8 ff ff       	call   c01062bc <pa2page>
c0106a7a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0106a7e:	89 04 24             	mov    %eax,(%esp)
c0106a81:	e8 55 fb ff ff       	call   c01065db <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
c0106a86:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0106a8a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0106a8d:	8b 00                	mov    (%eax),%eax
c0106a8f:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0106a92:	0f 8f 7e fe ff ff    	jg     c0106916 <page_init+0x254>
                }
            }
        }
    }
}
c0106a98:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c0106a9e:	5b                   	pop    %ebx
c0106a9f:	5e                   	pop    %esi
c0106aa0:	5f                   	pop    %edi
c0106aa1:	5d                   	pop    %ebp
c0106aa2:	c3                   	ret    

c0106aa3 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c0106aa3:	55                   	push   %ebp
c0106aa4:	89 e5                	mov    %esp,%ebp
c0106aa6:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0106aa9:	8b 45 14             	mov    0x14(%ebp),%eax
c0106aac:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106aaf:	31 d0                	xor    %edx,%eax
c0106ab1:	25 ff 0f 00 00       	and    $0xfff,%eax
c0106ab6:	85 c0                	test   %eax,%eax
c0106ab8:	74 24                	je     c0106ade <boot_map_segment+0x3b>
c0106aba:	c7 44 24 0c 92 a4 10 	movl   $0xc010a492,0xc(%esp)
c0106ac1:	c0 
c0106ac2:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c0106ac9:	c0 
c0106aca:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
c0106ad1:	00 
c0106ad2:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c0106ad9:	e8 1a 99 ff ff       	call   c01003f8 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0106ade:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0106ae5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106ae8:	25 ff 0f 00 00       	and    $0xfff,%eax
c0106aed:	89 c2                	mov    %eax,%edx
c0106aef:	8b 45 10             	mov    0x10(%ebp),%eax
c0106af2:	01 c2                	add    %eax,%edx
c0106af4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106af7:	01 d0                	add    %edx,%eax
c0106af9:	83 e8 01             	sub    $0x1,%eax
c0106afc:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106aff:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106b02:	ba 00 00 00 00       	mov    $0x0,%edx
c0106b07:	f7 75 f0             	divl   -0x10(%ebp)
c0106b0a:	89 d0                	mov    %edx,%eax
c0106b0c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106b0f:	29 c2                	sub    %eax,%edx
c0106b11:	89 d0                	mov    %edx,%eax
c0106b13:	c1 e8 0c             	shr    $0xc,%eax
c0106b16:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0106b19:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106b1c:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106b1f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106b22:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106b27:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c0106b2a:	8b 45 14             	mov    0x14(%ebp),%eax
c0106b2d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106b30:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106b33:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106b38:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0106b3b:	eb 6b                	jmp    c0106ba8 <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
c0106b3d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0106b44:	00 
c0106b45:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106b48:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106b4c:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b4f:	89 04 24             	mov    %eax,(%esp)
c0106b52:	e8 82 01 00 00       	call   c0106cd9 <get_pte>
c0106b57:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0106b5a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0106b5e:	75 24                	jne    c0106b84 <boot_map_segment+0xe1>
c0106b60:	c7 44 24 0c be a4 10 	movl   $0xc010a4be,0xc(%esp)
c0106b67:	c0 
c0106b68:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c0106b6f:	c0 
c0106b70:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
c0106b77:	00 
c0106b78:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c0106b7f:	e8 74 98 ff ff       	call   c01003f8 <__panic>
        *ptep = pa | PTE_P | perm;
c0106b84:	8b 45 18             	mov    0x18(%ebp),%eax
c0106b87:	8b 55 14             	mov    0x14(%ebp),%edx
c0106b8a:	09 d0                	or     %edx,%eax
c0106b8c:	83 c8 01             	or     $0x1,%eax
c0106b8f:	89 c2                	mov    %eax,%edx
c0106b91:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106b94:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0106b96:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0106b9a:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c0106ba1:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0106ba8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106bac:	75 8f                	jne    c0106b3d <boot_map_segment+0x9a>
    }
}
c0106bae:	c9                   	leave  
c0106baf:	c3                   	ret    

c0106bb0 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c0106bb0:	55                   	push   %ebp
c0106bb1:	89 e5                	mov    %esp,%ebp
c0106bb3:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c0106bb6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106bbd:	e8 38 fa ff ff       	call   c01065fa <alloc_pages>
c0106bc2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0106bc5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106bc9:	75 1c                	jne    c0106be7 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c0106bcb:	c7 44 24 08 cb a4 10 	movl   $0xc010a4cb,0x8(%esp)
c0106bd2:	c0 
c0106bd3:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c0106bda:	00 
c0106bdb:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c0106be2:	e8 11 98 ff ff       	call   c01003f8 <__panic>
    }
    return page2kva(p);
c0106be7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106bea:	89 04 24             	mov    %eax,(%esp)
c0106bed:	e8 0f f7 ff ff       	call   c0106301 <page2kva>
}
c0106bf2:	c9                   	leave  
c0106bf3:	c3                   	ret    

c0106bf4 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c0106bf4:	55                   	push   %ebp
c0106bf5:	89 e5                	mov    %esp,%ebp
c0106bf7:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c0106bfa:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0106bff:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106c02:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0106c09:	77 23                	ja     c0106c2e <pmm_init+0x3a>
c0106c0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106c0e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106c12:	c7 44 24 08 e0 a3 10 	movl   $0xc010a3e0,0x8(%esp)
c0106c19:	c0 
c0106c1a:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
c0106c21:	00 
c0106c22:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c0106c29:	e8 ca 97 ff ff       	call   c01003f8 <__panic>
c0106c2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106c31:	05 00 00 00 40       	add    $0x40000000,%eax
c0106c36:	a3 f4 40 12 c0       	mov    %eax,0xc01240f4
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0106c3b:	e8 68 f9 ff ff       	call   c01065a8 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c0106c40:	e8 7d fa ff ff       	call   c01066c2 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0106c45:	e8 ac 04 00 00       	call   c01070f6 <check_alloc_page>

    check_pgdir();
c0106c4a:	e8 c5 04 00 00       	call   c0107114 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0106c4f:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0106c54:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c0106c5a:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0106c5f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106c62:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0106c69:	77 23                	ja     c0106c8e <pmm_init+0x9a>
c0106c6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106c6e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106c72:	c7 44 24 08 e0 a3 10 	movl   $0xc010a3e0,0x8(%esp)
c0106c79:	c0 
c0106c7a:	c7 44 24 04 39 01 00 	movl   $0x139,0x4(%esp)
c0106c81:	00 
c0106c82:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c0106c89:	e8 6a 97 ff ff       	call   c01003f8 <__panic>
c0106c8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106c91:	05 00 00 00 40       	add    $0x40000000,%eax
c0106c96:	83 c8 03             	or     $0x3,%eax
c0106c99:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0106c9b:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0106ca0:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c0106ca7:	00 
c0106ca8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0106caf:	00 
c0106cb0:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c0106cb7:	38 
c0106cb8:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c0106cbf:	c0 
c0106cc0:	89 04 24             	mov    %eax,(%esp)
c0106cc3:	e8 db fd ff ff       	call   c0106aa3 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0106cc8:	e8 ec f7 ff ff       	call   c01064b9 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0106ccd:	e8 dd 0a 00 00       	call   c01077af <check_boot_pgdir>

    print_pgdir();
c0106cd2:	e8 65 0f 00 00       	call   c0107c3c <print_pgdir>

}
c0106cd7:	c9                   	leave  
c0106cd8:	c3                   	ret    

c0106cd9 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c0106cd9:	55                   	push   %ebp
c0106cda:	89 e5                	mov    %esp,%ebp
c0106cdc:	83 ec 38             	sub    $0x38,%esp
    pde_t *pdep = &pgdir[PDX(la)];
c0106cdf:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106ce2:	c1 e8 16             	shr    $0x16,%eax
c0106ce5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0106cec:	8b 45 08             	mov    0x8(%ebp),%eax
c0106cef:	01 d0                	add    %edx,%eax
c0106cf1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    //获取一级页表项对应的入口地址
    if (!(*pdep & PTE_P)) {
c0106cf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106cf7:	8b 00                	mov    (%eax),%eax
c0106cf9:	83 e0 01             	and    $0x1,%eax
c0106cfc:	85 c0                	test   %eax,%eax
c0106cfe:	0f 85 af 00 00 00    	jne    c0106db3 <get_pte+0xda>
        //物理页不存在, create==0, null
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {//分配失败
c0106d04:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106d08:	74 15                	je     c0106d1f <get_pte+0x46>
c0106d0a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106d11:	e8 e4 f8 ff ff       	call   c01065fa <alloc_pages>
c0106d16:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106d19:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106d1d:	75 0a                	jne    c0106d29 <get_pte+0x50>
            return NULL;
c0106d1f:	b8 00 00 00 00       	mov    $0x0,%eax
c0106d24:	e9 e6 00 00 00       	jmp    c0106e0f <get_pte+0x136>
        }
        //引用次数+1
        set_page_ref(page, 1);
c0106d29:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106d30:	00 
c0106d31:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106d34:	89 04 24             	mov    %eax,(%esp)
c0106d37:	e8 c3 f6 ff ff       	call   c01063ff <set_page_ref>
        //物理地址
        uintptr_t pa = page2pa(page);
c0106d3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106d3f:	89 04 24             	mov    %eax,(%esp)
c0106d42:	e8 5f f5 ff ff       	call   c01062a6 <page2pa>
c0106d47:	89 45 ec             	mov    %eax,-0x14(%ebp)
        ///物理地址转虚拟地址，并初始化,把新申请的数目为pgsize个页全设为0	
        memset(KADDR(pa), 0, PGSIZE);
c0106d4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106d4d:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106d50:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106d53:	c1 e8 0c             	shr    $0xc,%eax
c0106d56:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106d59:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c0106d5e:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0106d61:	72 23                	jb     c0106d86 <get_pte+0xad>
c0106d63:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106d66:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106d6a:	c7 44 24 08 bc a3 10 	movl   $0xc010a3bc,0x8(%esp)
c0106d71:	c0 
c0106d72:	c7 44 24 04 63 01 00 	movl   $0x163,0x4(%esp)
c0106d79:	00 
c0106d7a:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c0106d81:	e8 72 96 ff ff       	call   c01003f8 <__panic>
c0106d86:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106d89:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0106d8e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0106d95:	00 
c0106d96:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0106d9d:	00 
c0106d9e:	89 04 24             	mov    %eax,(%esp)
c0106da1:	e8 17 16 00 00       	call   c01083bd <memset>
        //设置控制位
        *pdep = pa | PTE_U | PTE_W | PTE_P;
c0106da6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106da9:	83 c8 07             	or     $0x7,%eax
c0106dac:	89 c2                	mov    %eax,%edx
c0106dae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106db1:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c0106db3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106db6:	8b 00                	mov    (%eax),%eax
c0106db8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106dbd:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106dc0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106dc3:	c1 e8 0c             	shr    $0xc,%eax
c0106dc6:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0106dc9:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c0106dce:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0106dd1:	72 23                	jb     c0106df6 <get_pte+0x11d>
c0106dd3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106dd6:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106dda:	c7 44 24 08 bc a3 10 	movl   $0xc010a3bc,0x8(%esp)
c0106de1:	c0 
c0106de2:	c7 44 24 04 67 01 00 	movl   $0x167,0x4(%esp)
c0106de9:	00 
c0106dea:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c0106df1:	e8 02 96 ff ff       	call   c01003f8 <__panic>
c0106df6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106df9:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0106dfe:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106e01:	c1 ea 0c             	shr    $0xc,%edx
c0106e04:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
c0106e0a:	c1 e2 02             	shl    $0x2,%edx
c0106e0d:	01 d0                	add    %edx,%eax
    //页目录项地址-->>页表物理地址-->>虚拟地址-->>页表项索引
    //PTX(la)：返回虚拟地址la的页表项索引
    //返回la对应的页表项入口地址
}
c0106e0f:	c9                   	leave  
c0106e10:	c3                   	ret    

c0106e11 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c0106e11:	55                   	push   %ebp
c0106e12:	89 e5                	mov    %esp,%ebp
c0106e14:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0106e17:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106e1e:	00 
c0106e1f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106e22:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106e26:	8b 45 08             	mov    0x8(%ebp),%eax
c0106e29:	89 04 24             	mov    %eax,(%esp)
c0106e2c:	e8 a8 fe ff ff       	call   c0106cd9 <get_pte>
c0106e31:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c0106e34:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106e38:	74 08                	je     c0106e42 <get_page+0x31>
        *ptep_store = ptep;
c0106e3a:	8b 45 10             	mov    0x10(%ebp),%eax
c0106e3d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106e40:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0106e42:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106e46:	74 1b                	je     c0106e63 <get_page+0x52>
c0106e48:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106e4b:	8b 00                	mov    (%eax),%eax
c0106e4d:	83 e0 01             	and    $0x1,%eax
c0106e50:	85 c0                	test   %eax,%eax
c0106e52:	74 0f                	je     c0106e63 <get_page+0x52>
        return pte2page(*ptep);
c0106e54:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106e57:	8b 00                	mov    (%eax),%eax
c0106e59:	89 04 24             	mov    %eax,(%esp)
c0106e5c:	e8 3e f5 ff ff       	call   c010639f <pte2page>
c0106e61:	eb 05                	jmp    c0106e68 <get_page+0x57>
    }
    return NULL;
c0106e63:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106e68:	c9                   	leave  
c0106e69:	c3                   	ret    

c0106e6a <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0106e6a:	55                   	push   %ebp
c0106e6b:	89 e5                	mov    %esp,%ebp
c0106e6d:	83 ec 28             	sub    $0x28,%esp
    if (*ptep & PTE_P) {
c0106e70:	8b 45 10             	mov    0x10(%ebp),%eax
c0106e73:	8b 00                	mov    (%eax),%eax
c0106e75:	83 e0 01             	and    $0x1,%eax
c0106e78:	85 c0                	test   %eax,%eax
c0106e7a:	74 53                	je     c0106ecf <page_remove_pte+0x65>
        //判断页表中该表项是否存在
        struct Page *page = pte2page(*ptep);//获得相应的page
c0106e7c:	8b 45 10             	mov    0x10(%ebp),%eax
c0106e7f:	8b 00                	mov    (%eax),%eax
c0106e81:	89 04 24             	mov    %eax,(%esp)
c0106e84:	e8 16 f5 ff ff       	call   c010639f <pte2page>
c0106e89:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
c0106e8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106e8f:	89 04 24             	mov    %eax,(%esp)
c0106e92:	e8 8c f5 ff ff       	call   c0106423 <page_ref_dec>
c0106e97:	85 c0                	test   %eax,%eax
c0106e99:	75 13                	jne    c0106eae <page_remove_pte+0x44>
            ////除了当前进程，没有别的进程引用
            free_page(page);
c0106e9b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106ea2:	00 
c0106ea3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106ea6:	89 04 24             	mov    %eax,(%esp)
c0106ea9:	e8 b7 f7 ff ff       	call   c0106665 <free_pages>
        }
        *ptep &= (~PTE_P); 
c0106eae:	8b 45 10             	mov    0x10(%ebp),%eax
c0106eb1:	8b 00                	mov    (%eax),%eax
c0106eb3:	83 e0 fe             	and    $0xfffffffe,%eax
c0106eb6:	89 c2                	mov    %eax,%edx
c0106eb8:	8b 45 10             	mov    0x10(%ebp),%eax
c0106ebb:	89 10                	mov    %edx,(%eax)
        // 将PTE的存在位设置为0，表示该映射关系无效
        tlb_invalidate(pgdir, la);
c0106ebd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106ec0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106ec4:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ec7:	89 04 24             	mov    %eax,(%esp)
c0106eca:	e8 ff 00 00 00       	call   c0106fce <tlb_invalidate>
         //刷新TLB
    }
}
c0106ecf:	c9                   	leave  
c0106ed0:	c3                   	ret    

c0106ed1 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0106ed1:	55                   	push   %ebp
c0106ed2:	89 e5                	mov    %esp,%ebp
c0106ed4:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0106ed7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106ede:	00 
c0106edf:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106ee2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106ee6:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ee9:	89 04 24             	mov    %eax,(%esp)
c0106eec:	e8 e8 fd ff ff       	call   c0106cd9 <get_pte>
c0106ef1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c0106ef4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106ef8:	74 19                	je     c0106f13 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c0106efa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106efd:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106f01:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106f04:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106f08:	8b 45 08             	mov    0x8(%ebp),%eax
c0106f0b:	89 04 24             	mov    %eax,(%esp)
c0106f0e:	e8 57 ff ff ff       	call   c0106e6a <page_remove_pte>
    }
}
c0106f13:	c9                   	leave  
c0106f14:	c3                   	ret    

c0106f15 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0106f15:	55                   	push   %ebp
c0106f16:	89 e5                	mov    %esp,%ebp
c0106f18:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c0106f1b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0106f22:	00 
c0106f23:	8b 45 10             	mov    0x10(%ebp),%eax
c0106f26:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106f2a:	8b 45 08             	mov    0x8(%ebp),%eax
c0106f2d:	89 04 24             	mov    %eax,(%esp)
c0106f30:	e8 a4 fd ff ff       	call   c0106cd9 <get_pte>
c0106f35:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c0106f38:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106f3c:	75 0a                	jne    c0106f48 <page_insert+0x33>
        return -E_NO_MEM;
c0106f3e:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0106f43:	e9 84 00 00 00       	jmp    c0106fcc <page_insert+0xb7>
    }
    page_ref_inc(page);
c0106f48:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106f4b:	89 04 24             	mov    %eax,(%esp)
c0106f4e:	e8 b9 f4 ff ff       	call   c010640c <page_ref_inc>
    if (*ptep & PTE_P) {
c0106f53:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106f56:	8b 00                	mov    (%eax),%eax
c0106f58:	83 e0 01             	and    $0x1,%eax
c0106f5b:	85 c0                	test   %eax,%eax
c0106f5d:	74 3e                	je     c0106f9d <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c0106f5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106f62:	8b 00                	mov    (%eax),%eax
c0106f64:	89 04 24             	mov    %eax,(%esp)
c0106f67:	e8 33 f4 ff ff       	call   c010639f <pte2page>
c0106f6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c0106f6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106f72:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106f75:	75 0d                	jne    c0106f84 <page_insert+0x6f>
            page_ref_dec(page);
c0106f77:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106f7a:	89 04 24             	mov    %eax,(%esp)
c0106f7d:	e8 a1 f4 ff ff       	call   c0106423 <page_ref_dec>
c0106f82:	eb 19                	jmp    c0106f9d <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0106f84:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106f87:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106f8b:	8b 45 10             	mov    0x10(%ebp),%eax
c0106f8e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106f92:	8b 45 08             	mov    0x8(%ebp),%eax
c0106f95:	89 04 24             	mov    %eax,(%esp)
c0106f98:	e8 cd fe ff ff       	call   c0106e6a <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0106f9d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106fa0:	89 04 24             	mov    %eax,(%esp)
c0106fa3:	e8 fe f2 ff ff       	call   c01062a6 <page2pa>
c0106fa8:	0b 45 14             	or     0x14(%ebp),%eax
c0106fab:	83 c8 01             	or     $0x1,%eax
c0106fae:	89 c2                	mov    %eax,%edx
c0106fb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106fb3:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c0106fb5:	8b 45 10             	mov    0x10(%ebp),%eax
c0106fb8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106fbc:	8b 45 08             	mov    0x8(%ebp),%eax
c0106fbf:	89 04 24             	mov    %eax,(%esp)
c0106fc2:	e8 07 00 00 00       	call   c0106fce <tlb_invalidate>
    return 0;
c0106fc7:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106fcc:	c9                   	leave  
c0106fcd:	c3                   	ret    

c0106fce <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c0106fce:	55                   	push   %ebp
c0106fcf:	89 e5                	mov    %esp,%ebp
c0106fd1:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0106fd4:	0f 20 d8             	mov    %cr3,%eax
c0106fd7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c0106fda:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
c0106fdd:	89 c2                	mov    %eax,%edx
c0106fdf:	8b 45 08             	mov    0x8(%ebp),%eax
c0106fe2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106fe5:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0106fec:	77 23                	ja     c0107011 <tlb_invalidate+0x43>
c0106fee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106ff1:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106ff5:	c7 44 24 08 e0 a3 10 	movl   $0xc010a3e0,0x8(%esp)
c0106ffc:	c0 
c0106ffd:	c7 44 24 04 b7 01 00 	movl   $0x1b7,0x4(%esp)
c0107004:	00 
c0107005:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c010700c:	e8 e7 93 ff ff       	call   c01003f8 <__panic>
c0107011:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107014:	05 00 00 00 40       	add    $0x40000000,%eax
c0107019:	39 c2                	cmp    %eax,%edx
c010701b:	75 0c                	jne    c0107029 <tlb_invalidate+0x5b>
        invlpg((void *)la);
c010701d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107020:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0107023:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107026:	0f 01 38             	invlpg (%eax)
    }
}
c0107029:	c9                   	leave  
c010702a:	c3                   	ret    

c010702b <pgdir_alloc_page>:

// pgdir_alloc_page - call alloc_page & page_insert functions to 
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *
pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
c010702b:	55                   	push   %ebp
c010702c:	89 e5                	mov    %esp,%ebp
c010702e:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_page();
c0107031:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107038:	e8 bd f5 ff ff       	call   c01065fa <alloc_pages>
c010703d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c0107040:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107044:	0f 84 a7 00 00 00    	je     c01070f1 <pgdir_alloc_page+0xc6>
        if (page_insert(pgdir, page, la, perm) != 0) {
c010704a:	8b 45 10             	mov    0x10(%ebp),%eax
c010704d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107051:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107054:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107058:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010705b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010705f:	8b 45 08             	mov    0x8(%ebp),%eax
c0107062:	89 04 24             	mov    %eax,(%esp)
c0107065:	e8 ab fe ff ff       	call   c0106f15 <page_insert>
c010706a:	85 c0                	test   %eax,%eax
c010706c:	74 1a                	je     c0107088 <pgdir_alloc_page+0x5d>
            free_page(page);
c010706e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107075:	00 
c0107076:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107079:	89 04 24             	mov    %eax,(%esp)
c010707c:	e8 e4 f5 ff ff       	call   c0106665 <free_pages>
            return NULL;
c0107081:	b8 00 00 00 00       	mov    $0x0,%eax
c0107086:	eb 6c                	jmp    c01070f4 <pgdir_alloc_page+0xc9>
        }
        if (swap_init_ok){
c0107088:	a1 68 3f 12 c0       	mov    0xc0123f68,%eax
c010708d:	85 c0                	test   %eax,%eax
c010708f:	74 60                	je     c01070f1 <pgdir_alloc_page+0xc6>
            swap_map_swappable(check_mm_struct, la, page, 0);
c0107091:	a1 10 40 12 c0       	mov    0xc0124010,%eax
c0107096:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010709d:	00 
c010709e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01070a1:	89 54 24 08          	mov    %edx,0x8(%esp)
c01070a5:	8b 55 0c             	mov    0xc(%ebp),%edx
c01070a8:	89 54 24 04          	mov    %edx,0x4(%esp)
c01070ac:	89 04 24             	mov    %eax,(%esp)
c01070af:	e8 03 d6 ff ff       	call   c01046b7 <swap_map_swappable>
            page->pra_vaddr=la;
c01070b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01070b7:	8b 55 0c             	mov    0xc(%ebp),%edx
c01070ba:	89 50 1c             	mov    %edx,0x1c(%eax)
            assert(page_ref(page) == 1);
c01070bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01070c0:	89 04 24             	mov    %eax,(%esp)
c01070c3:	e8 2d f3 ff ff       	call   c01063f5 <page_ref>
c01070c8:	83 f8 01             	cmp    $0x1,%eax
c01070cb:	74 24                	je     c01070f1 <pgdir_alloc_page+0xc6>
c01070cd:	c7 44 24 0c e4 a4 10 	movl   $0xc010a4e4,0xc(%esp)
c01070d4:	c0 
c01070d5:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c01070dc:	c0 
c01070dd:	c7 44 24 04 ca 01 00 	movl   $0x1ca,0x4(%esp)
c01070e4:	00 
c01070e5:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c01070ec:	e8 07 93 ff ff       	call   c01003f8 <__panic>
            //cprintf("get No. %d  page: pra_vaddr %x, pra_link.prev %x, pra_link_next %x in pgdir_alloc_page\n", (page-pages), page->pra_vaddr,page->pra_page_link.prev, page->pra_page_link.next);
        }

    }

    return page;
c01070f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01070f4:	c9                   	leave  
c01070f5:	c3                   	ret    

c01070f6 <check_alloc_page>:

static void
check_alloc_page(void) {
c01070f6:	55                   	push   %ebp
c01070f7:	89 e5                	mov    %esp,%ebp
c01070f9:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c01070fc:	a1 f0 40 12 c0       	mov    0xc01240f0,%eax
c0107101:	8b 40 18             	mov    0x18(%eax),%eax
c0107104:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c0107106:	c7 04 24 f8 a4 10 c0 	movl   $0xc010a4f8,(%esp)
c010710d:	e8 8f 91 ff ff       	call   c01002a1 <cprintf>
}
c0107112:	c9                   	leave  
c0107113:	c3                   	ret    

c0107114 <check_pgdir>:

static void
check_pgdir(void) {
c0107114:	55                   	push   %ebp
c0107115:	89 e5                	mov    %esp,%ebp
c0107117:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c010711a:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c010711f:	3d 00 80 03 00       	cmp    $0x38000,%eax
c0107124:	76 24                	jbe    c010714a <check_pgdir+0x36>
c0107126:	c7 44 24 0c 17 a5 10 	movl   $0xc010a517,0xc(%esp)
c010712d:	c0 
c010712e:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c0107135:	c0 
c0107136:	c7 44 24 04 db 01 00 	movl   $0x1db,0x4(%esp)
c010713d:	00 
c010713e:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c0107145:	e8 ae 92 ff ff       	call   c01003f8 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c010714a:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c010714f:	85 c0                	test   %eax,%eax
c0107151:	74 0e                	je     c0107161 <check_pgdir+0x4d>
c0107153:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0107158:	25 ff 0f 00 00       	and    $0xfff,%eax
c010715d:	85 c0                	test   %eax,%eax
c010715f:	74 24                	je     c0107185 <check_pgdir+0x71>
c0107161:	c7 44 24 0c 34 a5 10 	movl   $0xc010a534,0xc(%esp)
c0107168:	c0 
c0107169:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c0107170:	c0 
c0107171:	c7 44 24 04 dc 01 00 	movl   $0x1dc,0x4(%esp)
c0107178:	00 
c0107179:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c0107180:	e8 73 92 ff ff       	call   c01003f8 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c0107185:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c010718a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107191:	00 
c0107192:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0107199:	00 
c010719a:	89 04 24             	mov    %eax,(%esp)
c010719d:	e8 6f fc ff ff       	call   c0106e11 <get_page>
c01071a2:	85 c0                	test   %eax,%eax
c01071a4:	74 24                	je     c01071ca <check_pgdir+0xb6>
c01071a6:	c7 44 24 0c 6c a5 10 	movl   $0xc010a56c,0xc(%esp)
c01071ad:	c0 
c01071ae:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c01071b5:	c0 
c01071b6:	c7 44 24 04 dd 01 00 	movl   $0x1dd,0x4(%esp)
c01071bd:	00 
c01071be:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c01071c5:	e8 2e 92 ff ff       	call   c01003f8 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c01071ca:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01071d1:	e8 24 f4 ff ff       	call   c01065fa <alloc_pages>
c01071d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c01071d9:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c01071de:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01071e5:	00 
c01071e6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01071ed:	00 
c01071ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01071f1:	89 54 24 04          	mov    %edx,0x4(%esp)
c01071f5:	89 04 24             	mov    %eax,(%esp)
c01071f8:	e8 18 fd ff ff       	call   c0106f15 <page_insert>
c01071fd:	85 c0                	test   %eax,%eax
c01071ff:	74 24                	je     c0107225 <check_pgdir+0x111>
c0107201:	c7 44 24 0c 94 a5 10 	movl   $0xc010a594,0xc(%esp)
c0107208:	c0 
c0107209:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c0107210:	c0 
c0107211:	c7 44 24 04 e1 01 00 	movl   $0x1e1,0x4(%esp)
c0107218:	00 
c0107219:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c0107220:	e8 d3 91 ff ff       	call   c01003f8 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0107225:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c010722a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107231:	00 
c0107232:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0107239:	00 
c010723a:	89 04 24             	mov    %eax,(%esp)
c010723d:	e8 97 fa ff ff       	call   c0106cd9 <get_pte>
c0107242:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107245:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107249:	75 24                	jne    c010726f <check_pgdir+0x15b>
c010724b:	c7 44 24 0c c0 a5 10 	movl   $0xc010a5c0,0xc(%esp)
c0107252:	c0 
c0107253:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c010725a:	c0 
c010725b:	c7 44 24 04 e4 01 00 	movl   $0x1e4,0x4(%esp)
c0107262:	00 
c0107263:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c010726a:	e8 89 91 ff ff       	call   c01003f8 <__panic>
    assert(pte2page(*ptep) == p1);
c010726f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107272:	8b 00                	mov    (%eax),%eax
c0107274:	89 04 24             	mov    %eax,(%esp)
c0107277:	e8 23 f1 ff ff       	call   c010639f <pte2page>
c010727c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010727f:	74 24                	je     c01072a5 <check_pgdir+0x191>
c0107281:	c7 44 24 0c ed a5 10 	movl   $0xc010a5ed,0xc(%esp)
c0107288:	c0 
c0107289:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c0107290:	c0 
c0107291:	c7 44 24 04 e5 01 00 	movl   $0x1e5,0x4(%esp)
c0107298:	00 
c0107299:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c01072a0:	e8 53 91 ff ff       	call   c01003f8 <__panic>
    assert(page_ref(p1) == 1);
c01072a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01072a8:	89 04 24             	mov    %eax,(%esp)
c01072ab:	e8 45 f1 ff ff       	call   c01063f5 <page_ref>
c01072b0:	83 f8 01             	cmp    $0x1,%eax
c01072b3:	74 24                	je     c01072d9 <check_pgdir+0x1c5>
c01072b5:	c7 44 24 0c 03 a6 10 	movl   $0xc010a603,0xc(%esp)
c01072bc:	c0 
c01072bd:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c01072c4:	c0 
c01072c5:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
c01072cc:	00 
c01072cd:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c01072d4:	e8 1f 91 ff ff       	call   c01003f8 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c01072d9:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c01072de:	8b 00                	mov    (%eax),%eax
c01072e0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01072e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01072e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01072eb:	c1 e8 0c             	shr    $0xc,%eax
c01072ee:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01072f1:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c01072f6:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01072f9:	72 23                	jb     c010731e <check_pgdir+0x20a>
c01072fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01072fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107302:	c7 44 24 08 bc a3 10 	movl   $0xc010a3bc,0x8(%esp)
c0107309:	c0 
c010730a:	c7 44 24 04 e8 01 00 	movl   $0x1e8,0x4(%esp)
c0107311:	00 
c0107312:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c0107319:	e8 da 90 ff ff       	call   c01003f8 <__panic>
c010731e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107321:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0107326:	83 c0 04             	add    $0x4,%eax
c0107329:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c010732c:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0107331:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107338:	00 
c0107339:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0107340:	00 
c0107341:	89 04 24             	mov    %eax,(%esp)
c0107344:	e8 90 f9 ff ff       	call   c0106cd9 <get_pte>
c0107349:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010734c:	74 24                	je     c0107372 <check_pgdir+0x25e>
c010734e:	c7 44 24 0c 18 a6 10 	movl   $0xc010a618,0xc(%esp)
c0107355:	c0 
c0107356:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c010735d:	c0 
c010735e:	c7 44 24 04 e9 01 00 	movl   $0x1e9,0x4(%esp)
c0107365:	00 
c0107366:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c010736d:	e8 86 90 ff ff       	call   c01003f8 <__panic>

    p2 = alloc_page();
c0107372:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107379:	e8 7c f2 ff ff       	call   c01065fa <alloc_pages>
c010737e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0107381:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0107386:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c010738d:	00 
c010738e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0107395:	00 
c0107396:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107399:	89 54 24 04          	mov    %edx,0x4(%esp)
c010739d:	89 04 24             	mov    %eax,(%esp)
c01073a0:	e8 70 fb ff ff       	call   c0106f15 <page_insert>
c01073a5:	85 c0                	test   %eax,%eax
c01073a7:	74 24                	je     c01073cd <check_pgdir+0x2b9>
c01073a9:	c7 44 24 0c 40 a6 10 	movl   $0xc010a640,0xc(%esp)
c01073b0:	c0 
c01073b1:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c01073b8:	c0 
c01073b9:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
c01073c0:	00 
c01073c1:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c01073c8:	e8 2b 90 ff ff       	call   c01003f8 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c01073cd:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c01073d2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01073d9:	00 
c01073da:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01073e1:	00 
c01073e2:	89 04 24             	mov    %eax,(%esp)
c01073e5:	e8 ef f8 ff ff       	call   c0106cd9 <get_pte>
c01073ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01073ed:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01073f1:	75 24                	jne    c0107417 <check_pgdir+0x303>
c01073f3:	c7 44 24 0c 78 a6 10 	movl   $0xc010a678,0xc(%esp)
c01073fa:	c0 
c01073fb:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c0107402:	c0 
c0107403:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
c010740a:	00 
c010740b:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c0107412:	e8 e1 8f ff ff       	call   c01003f8 <__panic>
    assert(*ptep & PTE_U);
c0107417:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010741a:	8b 00                	mov    (%eax),%eax
c010741c:	83 e0 04             	and    $0x4,%eax
c010741f:	85 c0                	test   %eax,%eax
c0107421:	75 24                	jne    c0107447 <check_pgdir+0x333>
c0107423:	c7 44 24 0c a8 a6 10 	movl   $0xc010a6a8,0xc(%esp)
c010742a:	c0 
c010742b:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c0107432:	c0 
c0107433:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
c010743a:	00 
c010743b:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c0107442:	e8 b1 8f ff ff       	call   c01003f8 <__panic>
    assert(*ptep & PTE_W);
c0107447:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010744a:	8b 00                	mov    (%eax),%eax
c010744c:	83 e0 02             	and    $0x2,%eax
c010744f:	85 c0                	test   %eax,%eax
c0107451:	75 24                	jne    c0107477 <check_pgdir+0x363>
c0107453:	c7 44 24 0c b6 a6 10 	movl   $0xc010a6b6,0xc(%esp)
c010745a:	c0 
c010745b:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c0107462:	c0 
c0107463:	c7 44 24 04 ef 01 00 	movl   $0x1ef,0x4(%esp)
c010746a:	00 
c010746b:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c0107472:	e8 81 8f ff ff       	call   c01003f8 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0107477:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c010747c:	8b 00                	mov    (%eax),%eax
c010747e:	83 e0 04             	and    $0x4,%eax
c0107481:	85 c0                	test   %eax,%eax
c0107483:	75 24                	jne    c01074a9 <check_pgdir+0x395>
c0107485:	c7 44 24 0c c4 a6 10 	movl   $0xc010a6c4,0xc(%esp)
c010748c:	c0 
c010748d:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c0107494:	c0 
c0107495:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
c010749c:	00 
c010749d:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c01074a4:	e8 4f 8f ff ff       	call   c01003f8 <__panic>
    assert(page_ref(p2) == 1);
c01074a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01074ac:	89 04 24             	mov    %eax,(%esp)
c01074af:	e8 41 ef ff ff       	call   c01063f5 <page_ref>
c01074b4:	83 f8 01             	cmp    $0x1,%eax
c01074b7:	74 24                	je     c01074dd <check_pgdir+0x3c9>
c01074b9:	c7 44 24 0c da a6 10 	movl   $0xc010a6da,0xc(%esp)
c01074c0:	c0 
c01074c1:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c01074c8:	c0 
c01074c9:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
c01074d0:	00 
c01074d1:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c01074d8:	e8 1b 8f ff ff       	call   c01003f8 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c01074dd:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c01074e2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01074e9:	00 
c01074ea:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01074f1:	00 
c01074f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01074f5:	89 54 24 04          	mov    %edx,0x4(%esp)
c01074f9:	89 04 24             	mov    %eax,(%esp)
c01074fc:	e8 14 fa ff ff       	call   c0106f15 <page_insert>
c0107501:	85 c0                	test   %eax,%eax
c0107503:	74 24                	je     c0107529 <check_pgdir+0x415>
c0107505:	c7 44 24 0c ec a6 10 	movl   $0xc010a6ec,0xc(%esp)
c010750c:	c0 
c010750d:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c0107514:	c0 
c0107515:	c7 44 24 04 f3 01 00 	movl   $0x1f3,0x4(%esp)
c010751c:	00 
c010751d:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c0107524:	e8 cf 8e ff ff       	call   c01003f8 <__panic>
    assert(page_ref(p1) == 2);
c0107529:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010752c:	89 04 24             	mov    %eax,(%esp)
c010752f:	e8 c1 ee ff ff       	call   c01063f5 <page_ref>
c0107534:	83 f8 02             	cmp    $0x2,%eax
c0107537:	74 24                	je     c010755d <check_pgdir+0x449>
c0107539:	c7 44 24 0c 18 a7 10 	movl   $0xc010a718,0xc(%esp)
c0107540:	c0 
c0107541:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c0107548:	c0 
c0107549:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
c0107550:	00 
c0107551:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c0107558:	e8 9b 8e ff ff       	call   c01003f8 <__panic>
    assert(page_ref(p2) == 0);
c010755d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107560:	89 04 24             	mov    %eax,(%esp)
c0107563:	e8 8d ee ff ff       	call   c01063f5 <page_ref>
c0107568:	85 c0                	test   %eax,%eax
c010756a:	74 24                	je     c0107590 <check_pgdir+0x47c>
c010756c:	c7 44 24 0c 2a a7 10 	movl   $0xc010a72a,0xc(%esp)
c0107573:	c0 
c0107574:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c010757b:	c0 
c010757c:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
c0107583:	00 
c0107584:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c010758b:	e8 68 8e ff ff       	call   c01003f8 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0107590:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0107595:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010759c:	00 
c010759d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01075a4:	00 
c01075a5:	89 04 24             	mov    %eax,(%esp)
c01075a8:	e8 2c f7 ff ff       	call   c0106cd9 <get_pte>
c01075ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01075b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01075b4:	75 24                	jne    c01075da <check_pgdir+0x4c6>
c01075b6:	c7 44 24 0c 78 a6 10 	movl   $0xc010a678,0xc(%esp)
c01075bd:	c0 
c01075be:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c01075c5:	c0 
c01075c6:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
c01075cd:	00 
c01075ce:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c01075d5:	e8 1e 8e ff ff       	call   c01003f8 <__panic>
    assert(pte2page(*ptep) == p1);
c01075da:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01075dd:	8b 00                	mov    (%eax),%eax
c01075df:	89 04 24             	mov    %eax,(%esp)
c01075e2:	e8 b8 ed ff ff       	call   c010639f <pte2page>
c01075e7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01075ea:	74 24                	je     c0107610 <check_pgdir+0x4fc>
c01075ec:	c7 44 24 0c ed a5 10 	movl   $0xc010a5ed,0xc(%esp)
c01075f3:	c0 
c01075f4:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c01075fb:	c0 
c01075fc:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
c0107603:	00 
c0107604:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c010760b:	e8 e8 8d ff ff       	call   c01003f8 <__panic>
    assert((*ptep & PTE_U) == 0);
c0107610:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107613:	8b 00                	mov    (%eax),%eax
c0107615:	83 e0 04             	and    $0x4,%eax
c0107618:	85 c0                	test   %eax,%eax
c010761a:	74 24                	je     c0107640 <check_pgdir+0x52c>
c010761c:	c7 44 24 0c 3c a7 10 	movl   $0xc010a73c,0xc(%esp)
c0107623:	c0 
c0107624:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c010762b:	c0 
c010762c:	c7 44 24 04 f8 01 00 	movl   $0x1f8,0x4(%esp)
c0107633:	00 
c0107634:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c010763b:	e8 b8 8d ff ff       	call   c01003f8 <__panic>

    page_remove(boot_pgdir, 0x0);
c0107640:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0107645:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010764c:	00 
c010764d:	89 04 24             	mov    %eax,(%esp)
c0107650:	e8 7c f8 ff ff       	call   c0106ed1 <page_remove>
    assert(page_ref(p1) == 1);
c0107655:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107658:	89 04 24             	mov    %eax,(%esp)
c010765b:	e8 95 ed ff ff       	call   c01063f5 <page_ref>
c0107660:	83 f8 01             	cmp    $0x1,%eax
c0107663:	74 24                	je     c0107689 <check_pgdir+0x575>
c0107665:	c7 44 24 0c 03 a6 10 	movl   $0xc010a603,0xc(%esp)
c010766c:	c0 
c010766d:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c0107674:	c0 
c0107675:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
c010767c:	00 
c010767d:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c0107684:	e8 6f 8d ff ff       	call   c01003f8 <__panic>
    assert(page_ref(p2) == 0);
c0107689:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010768c:	89 04 24             	mov    %eax,(%esp)
c010768f:	e8 61 ed ff ff       	call   c01063f5 <page_ref>
c0107694:	85 c0                	test   %eax,%eax
c0107696:	74 24                	je     c01076bc <check_pgdir+0x5a8>
c0107698:	c7 44 24 0c 2a a7 10 	movl   $0xc010a72a,0xc(%esp)
c010769f:	c0 
c01076a0:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c01076a7:	c0 
c01076a8:	c7 44 24 04 fc 01 00 	movl   $0x1fc,0x4(%esp)
c01076af:	00 
c01076b0:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c01076b7:	e8 3c 8d ff ff       	call   c01003f8 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c01076bc:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c01076c1:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01076c8:	00 
c01076c9:	89 04 24             	mov    %eax,(%esp)
c01076cc:	e8 00 f8 ff ff       	call   c0106ed1 <page_remove>
    assert(page_ref(p1) == 0);
c01076d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01076d4:	89 04 24             	mov    %eax,(%esp)
c01076d7:	e8 19 ed ff ff       	call   c01063f5 <page_ref>
c01076dc:	85 c0                	test   %eax,%eax
c01076de:	74 24                	je     c0107704 <check_pgdir+0x5f0>
c01076e0:	c7 44 24 0c 51 a7 10 	movl   $0xc010a751,0xc(%esp)
c01076e7:	c0 
c01076e8:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c01076ef:	c0 
c01076f0:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
c01076f7:	00 
c01076f8:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c01076ff:	e8 f4 8c ff ff       	call   c01003f8 <__panic>
    assert(page_ref(p2) == 0);
c0107704:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107707:	89 04 24             	mov    %eax,(%esp)
c010770a:	e8 e6 ec ff ff       	call   c01063f5 <page_ref>
c010770f:	85 c0                	test   %eax,%eax
c0107711:	74 24                	je     c0107737 <check_pgdir+0x623>
c0107713:	c7 44 24 0c 2a a7 10 	movl   $0xc010a72a,0xc(%esp)
c010771a:	c0 
c010771b:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c0107722:	c0 
c0107723:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
c010772a:	00 
c010772b:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c0107732:	e8 c1 8c ff ff       	call   c01003f8 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0107737:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c010773c:	8b 00                	mov    (%eax),%eax
c010773e:	89 04 24             	mov    %eax,(%esp)
c0107741:	e8 97 ec ff ff       	call   c01063dd <pde2page>
c0107746:	89 04 24             	mov    %eax,(%esp)
c0107749:	e8 a7 ec ff ff       	call   c01063f5 <page_ref>
c010774e:	83 f8 01             	cmp    $0x1,%eax
c0107751:	74 24                	je     c0107777 <check_pgdir+0x663>
c0107753:	c7 44 24 0c 64 a7 10 	movl   $0xc010a764,0xc(%esp)
c010775a:	c0 
c010775b:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c0107762:	c0 
c0107763:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
c010776a:	00 
c010776b:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c0107772:	e8 81 8c ff ff       	call   c01003f8 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0107777:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c010777c:	8b 00                	mov    (%eax),%eax
c010777e:	89 04 24             	mov    %eax,(%esp)
c0107781:	e8 57 ec ff ff       	call   c01063dd <pde2page>
c0107786:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010778d:	00 
c010778e:	89 04 24             	mov    %eax,(%esp)
c0107791:	e8 cf ee ff ff       	call   c0106665 <free_pages>
    boot_pgdir[0] = 0;
c0107796:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c010779b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c01077a1:	c7 04 24 8b a7 10 c0 	movl   $0xc010a78b,(%esp)
c01077a8:	e8 f4 8a ff ff       	call   c01002a1 <cprintf>
}
c01077ad:	c9                   	leave  
c01077ae:	c3                   	ret    

c01077af <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c01077af:	55                   	push   %ebp
c01077b0:	89 e5                	mov    %esp,%ebp
c01077b2:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c01077b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01077bc:	e9 ca 00 00 00       	jmp    c010788b <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c01077c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01077c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01077c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01077ca:	c1 e8 0c             	shr    $0xc,%eax
c01077cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01077d0:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c01077d5:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c01077d8:	72 23                	jb     c01077fd <check_boot_pgdir+0x4e>
c01077da:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01077dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01077e1:	c7 44 24 08 bc a3 10 	movl   $0xc010a3bc,0x8(%esp)
c01077e8:	c0 
c01077e9:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
c01077f0:	00 
c01077f1:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c01077f8:	e8 fb 8b ff ff       	call   c01003f8 <__panic>
c01077fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107800:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0107805:	89 c2                	mov    %eax,%edx
c0107807:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c010780c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107813:	00 
c0107814:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107818:	89 04 24             	mov    %eax,(%esp)
c010781b:	e8 b9 f4 ff ff       	call   c0106cd9 <get_pte>
c0107820:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107823:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0107827:	75 24                	jne    c010784d <check_boot_pgdir+0x9e>
c0107829:	c7 44 24 0c a8 a7 10 	movl   $0xc010a7a8,0xc(%esp)
c0107830:	c0 
c0107831:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c0107838:	c0 
c0107839:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
c0107840:	00 
c0107841:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c0107848:	e8 ab 8b ff ff       	call   c01003f8 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c010784d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107850:	8b 00                	mov    (%eax),%eax
c0107852:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107857:	89 c2                	mov    %eax,%edx
c0107859:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010785c:	39 c2                	cmp    %eax,%edx
c010785e:	74 24                	je     c0107884 <check_boot_pgdir+0xd5>
c0107860:	c7 44 24 0c e5 a7 10 	movl   $0xc010a7e5,0xc(%esp)
c0107867:	c0 
c0107868:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c010786f:	c0 
c0107870:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
c0107877:	00 
c0107878:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c010787f:	e8 74 8b ff ff       	call   c01003f8 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
c0107884:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c010788b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010788e:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c0107893:	39 c2                	cmp    %eax,%edx
c0107895:	0f 82 26 ff ff ff    	jb     c01077c1 <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c010789b:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c01078a0:	05 ac 0f 00 00       	add    $0xfac,%eax
c01078a5:	8b 00                	mov    (%eax),%eax
c01078a7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01078ac:	89 c2                	mov    %eax,%edx
c01078ae:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c01078b3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01078b6:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c01078bd:	77 23                	ja     c01078e2 <check_boot_pgdir+0x133>
c01078bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01078c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01078c6:	c7 44 24 08 e0 a3 10 	movl   $0xc010a3e0,0x8(%esp)
c01078cd:	c0 
c01078ce:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
c01078d5:	00 
c01078d6:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c01078dd:	e8 16 8b ff ff       	call   c01003f8 <__panic>
c01078e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01078e5:	05 00 00 00 40       	add    $0x40000000,%eax
c01078ea:	39 c2                	cmp    %eax,%edx
c01078ec:	74 24                	je     c0107912 <check_boot_pgdir+0x163>
c01078ee:	c7 44 24 0c fc a7 10 	movl   $0xc010a7fc,0xc(%esp)
c01078f5:	c0 
c01078f6:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c01078fd:	c0 
c01078fe:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
c0107905:	00 
c0107906:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c010790d:	e8 e6 8a ff ff       	call   c01003f8 <__panic>

    assert(boot_pgdir[0] == 0);
c0107912:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0107917:	8b 00                	mov    (%eax),%eax
c0107919:	85 c0                	test   %eax,%eax
c010791b:	74 24                	je     c0107941 <check_boot_pgdir+0x192>
c010791d:	c7 44 24 0c 30 a8 10 	movl   $0xc010a830,0xc(%esp)
c0107924:	c0 
c0107925:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c010792c:	c0 
c010792d:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
c0107934:	00 
c0107935:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c010793c:	e8 b7 8a ff ff       	call   c01003f8 <__panic>

    struct Page *p;
    p = alloc_page();
c0107941:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107948:	e8 ad ec ff ff       	call   c01065fa <alloc_pages>
c010794d:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0107950:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0107955:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c010795c:	00 
c010795d:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0107964:	00 
c0107965:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107968:	89 54 24 04          	mov    %edx,0x4(%esp)
c010796c:	89 04 24             	mov    %eax,(%esp)
c010796f:	e8 a1 f5 ff ff       	call   c0106f15 <page_insert>
c0107974:	85 c0                	test   %eax,%eax
c0107976:	74 24                	je     c010799c <check_boot_pgdir+0x1ed>
c0107978:	c7 44 24 0c 44 a8 10 	movl   $0xc010a844,0xc(%esp)
c010797f:	c0 
c0107980:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c0107987:	c0 
c0107988:	c7 44 24 04 18 02 00 	movl   $0x218,0x4(%esp)
c010798f:	00 
c0107990:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c0107997:	e8 5c 8a ff ff       	call   c01003f8 <__panic>
    assert(page_ref(p) == 1);
c010799c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010799f:	89 04 24             	mov    %eax,(%esp)
c01079a2:	e8 4e ea ff ff       	call   c01063f5 <page_ref>
c01079a7:	83 f8 01             	cmp    $0x1,%eax
c01079aa:	74 24                	je     c01079d0 <check_boot_pgdir+0x221>
c01079ac:	c7 44 24 0c 72 a8 10 	movl   $0xc010a872,0xc(%esp)
c01079b3:	c0 
c01079b4:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c01079bb:	c0 
c01079bc:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
c01079c3:	00 
c01079c4:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c01079cb:	e8 28 8a ff ff       	call   c01003f8 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c01079d0:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c01079d5:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c01079dc:	00 
c01079dd:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c01079e4:	00 
c01079e5:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01079e8:	89 54 24 04          	mov    %edx,0x4(%esp)
c01079ec:	89 04 24             	mov    %eax,(%esp)
c01079ef:	e8 21 f5 ff ff       	call   c0106f15 <page_insert>
c01079f4:	85 c0                	test   %eax,%eax
c01079f6:	74 24                	je     c0107a1c <check_boot_pgdir+0x26d>
c01079f8:	c7 44 24 0c 84 a8 10 	movl   $0xc010a884,0xc(%esp)
c01079ff:	c0 
c0107a00:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c0107a07:	c0 
c0107a08:	c7 44 24 04 1a 02 00 	movl   $0x21a,0x4(%esp)
c0107a0f:	00 
c0107a10:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c0107a17:	e8 dc 89 ff ff       	call   c01003f8 <__panic>
    assert(page_ref(p) == 2);
c0107a1c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107a1f:	89 04 24             	mov    %eax,(%esp)
c0107a22:	e8 ce e9 ff ff       	call   c01063f5 <page_ref>
c0107a27:	83 f8 02             	cmp    $0x2,%eax
c0107a2a:	74 24                	je     c0107a50 <check_boot_pgdir+0x2a1>
c0107a2c:	c7 44 24 0c bb a8 10 	movl   $0xc010a8bb,0xc(%esp)
c0107a33:	c0 
c0107a34:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c0107a3b:	c0 
c0107a3c:	c7 44 24 04 1b 02 00 	movl   $0x21b,0x4(%esp)
c0107a43:	00 
c0107a44:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c0107a4b:	e8 a8 89 ff ff       	call   c01003f8 <__panic>

    const char *str = "ucore: Hello world!!";
c0107a50:	c7 45 dc cc a8 10 c0 	movl   $0xc010a8cc,-0x24(%ebp)
    strcpy((void *)0x100, str);
c0107a57:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107a5a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107a5e:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0107a65:	e8 7c 06 00 00       	call   c01080e6 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0107a6a:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0107a71:	00 
c0107a72:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0107a79:	e8 e1 06 00 00       	call   c010815f <strcmp>
c0107a7e:	85 c0                	test   %eax,%eax
c0107a80:	74 24                	je     c0107aa6 <check_boot_pgdir+0x2f7>
c0107a82:	c7 44 24 0c e4 a8 10 	movl   $0xc010a8e4,0xc(%esp)
c0107a89:	c0 
c0107a8a:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c0107a91:	c0 
c0107a92:	c7 44 24 04 1f 02 00 	movl   $0x21f,0x4(%esp)
c0107a99:	00 
c0107a9a:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c0107aa1:	e8 52 89 ff ff       	call   c01003f8 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0107aa6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107aa9:	89 04 24             	mov    %eax,(%esp)
c0107aac:	e8 50 e8 ff ff       	call   c0106301 <page2kva>
c0107ab1:	05 00 01 00 00       	add    $0x100,%eax
c0107ab6:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0107ab9:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0107ac0:	e8 c9 05 00 00       	call   c010808e <strlen>
c0107ac5:	85 c0                	test   %eax,%eax
c0107ac7:	74 24                	je     c0107aed <check_boot_pgdir+0x33e>
c0107ac9:	c7 44 24 0c 1c a9 10 	movl   $0xc010a91c,0xc(%esp)
c0107ad0:	c0 
c0107ad1:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c0107ad8:	c0 
c0107ad9:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
c0107ae0:	00 
c0107ae1:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c0107ae8:	e8 0b 89 ff ff       	call   c01003f8 <__panic>

    free_page(p);
c0107aed:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107af4:	00 
c0107af5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107af8:	89 04 24             	mov    %eax,(%esp)
c0107afb:	e8 65 eb ff ff       	call   c0106665 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0107b00:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0107b05:	8b 00                	mov    (%eax),%eax
c0107b07:	89 04 24             	mov    %eax,(%esp)
c0107b0a:	e8 ce e8 ff ff       	call   c01063dd <pde2page>
c0107b0f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107b16:	00 
c0107b17:	89 04 24             	mov    %eax,(%esp)
c0107b1a:	e8 46 eb ff ff       	call   c0106665 <free_pages>
    boot_pgdir[0] = 0;
c0107b1f:	a1 00 0a 12 c0       	mov    0xc0120a00,%eax
c0107b24:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0107b2a:	c7 04 24 40 a9 10 c0 	movl   $0xc010a940,(%esp)
c0107b31:	e8 6b 87 ff ff       	call   c01002a1 <cprintf>
}
c0107b36:	c9                   	leave  
c0107b37:	c3                   	ret    

c0107b38 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0107b38:	55                   	push   %ebp
c0107b39:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0107b3b:	8b 45 08             	mov    0x8(%ebp),%eax
c0107b3e:	83 e0 04             	and    $0x4,%eax
c0107b41:	85 c0                	test   %eax,%eax
c0107b43:	74 07                	je     c0107b4c <perm2str+0x14>
c0107b45:	b8 75 00 00 00       	mov    $0x75,%eax
c0107b4a:	eb 05                	jmp    c0107b51 <perm2str+0x19>
c0107b4c:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0107b51:	a2 08 40 12 c0       	mov    %al,0xc0124008
    str[1] = 'r';
c0107b56:	c6 05 09 40 12 c0 72 	movb   $0x72,0xc0124009
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0107b5d:	8b 45 08             	mov    0x8(%ebp),%eax
c0107b60:	83 e0 02             	and    $0x2,%eax
c0107b63:	85 c0                	test   %eax,%eax
c0107b65:	74 07                	je     c0107b6e <perm2str+0x36>
c0107b67:	b8 77 00 00 00       	mov    $0x77,%eax
c0107b6c:	eb 05                	jmp    c0107b73 <perm2str+0x3b>
c0107b6e:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0107b73:	a2 0a 40 12 c0       	mov    %al,0xc012400a
    str[3] = '\0';
c0107b78:	c6 05 0b 40 12 c0 00 	movb   $0x0,0xc012400b
    return str;
c0107b7f:	b8 08 40 12 c0       	mov    $0xc0124008,%eax
}
c0107b84:	5d                   	pop    %ebp
c0107b85:	c3                   	ret    

c0107b86 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0107b86:	55                   	push   %ebp
c0107b87:	89 e5                	mov    %esp,%ebp
c0107b89:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0107b8c:	8b 45 10             	mov    0x10(%ebp),%eax
c0107b8f:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107b92:	72 0a                	jb     c0107b9e <get_pgtable_items+0x18>
        return 0;
c0107b94:	b8 00 00 00 00       	mov    $0x0,%eax
c0107b99:	e9 9c 00 00 00       	jmp    c0107c3a <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
c0107b9e:	eb 04                	jmp    c0107ba4 <get_pgtable_items+0x1e>
        start ++;
c0107ba0:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
c0107ba4:	8b 45 10             	mov    0x10(%ebp),%eax
c0107ba7:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107baa:	73 18                	jae    c0107bc4 <get_pgtable_items+0x3e>
c0107bac:	8b 45 10             	mov    0x10(%ebp),%eax
c0107baf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0107bb6:	8b 45 14             	mov    0x14(%ebp),%eax
c0107bb9:	01 d0                	add    %edx,%eax
c0107bbb:	8b 00                	mov    (%eax),%eax
c0107bbd:	83 e0 01             	and    $0x1,%eax
c0107bc0:	85 c0                	test   %eax,%eax
c0107bc2:	74 dc                	je     c0107ba0 <get_pgtable_items+0x1a>
    }
    if (start < right) {
c0107bc4:	8b 45 10             	mov    0x10(%ebp),%eax
c0107bc7:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107bca:	73 69                	jae    c0107c35 <get_pgtable_items+0xaf>
        if (left_store != NULL) {
c0107bcc:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0107bd0:	74 08                	je     c0107bda <get_pgtable_items+0x54>
            *left_store = start;
c0107bd2:	8b 45 18             	mov    0x18(%ebp),%eax
c0107bd5:	8b 55 10             	mov    0x10(%ebp),%edx
c0107bd8:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0107bda:	8b 45 10             	mov    0x10(%ebp),%eax
c0107bdd:	8d 50 01             	lea    0x1(%eax),%edx
c0107be0:	89 55 10             	mov    %edx,0x10(%ebp)
c0107be3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0107bea:	8b 45 14             	mov    0x14(%ebp),%eax
c0107bed:	01 d0                	add    %edx,%eax
c0107bef:	8b 00                	mov    (%eax),%eax
c0107bf1:	83 e0 07             	and    $0x7,%eax
c0107bf4:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0107bf7:	eb 04                	jmp    c0107bfd <get_pgtable_items+0x77>
            start ++;
c0107bf9:	83 45 10 01          	addl   $0x1,0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0107bfd:	8b 45 10             	mov    0x10(%ebp),%eax
c0107c00:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107c03:	73 1d                	jae    c0107c22 <get_pgtable_items+0x9c>
c0107c05:	8b 45 10             	mov    0x10(%ebp),%eax
c0107c08:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0107c0f:	8b 45 14             	mov    0x14(%ebp),%eax
c0107c12:	01 d0                	add    %edx,%eax
c0107c14:	8b 00                	mov    (%eax),%eax
c0107c16:	83 e0 07             	and    $0x7,%eax
c0107c19:	89 c2                	mov    %eax,%edx
c0107c1b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107c1e:	39 c2                	cmp    %eax,%edx
c0107c20:	74 d7                	je     c0107bf9 <get_pgtable_items+0x73>
        }
        if (right_store != NULL) {
c0107c22:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0107c26:	74 08                	je     c0107c30 <get_pgtable_items+0xaa>
            *right_store = start;
c0107c28:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0107c2b:	8b 55 10             	mov    0x10(%ebp),%edx
c0107c2e:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0107c30:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107c33:	eb 05                	jmp    c0107c3a <get_pgtable_items+0xb4>
    }
    return 0;
c0107c35:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107c3a:	c9                   	leave  
c0107c3b:	c3                   	ret    

c0107c3c <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0107c3c:	55                   	push   %ebp
c0107c3d:	89 e5                	mov    %esp,%ebp
c0107c3f:	57                   	push   %edi
c0107c40:	56                   	push   %esi
c0107c41:	53                   	push   %ebx
c0107c42:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0107c45:	c7 04 24 60 a9 10 c0 	movl   $0xc010a960,(%esp)
c0107c4c:	e8 50 86 ff ff       	call   c01002a1 <cprintf>
    size_t left, right = 0, perm;
c0107c51:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0107c58:	e9 fa 00 00 00       	jmp    c0107d57 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0107c5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107c60:	89 04 24             	mov    %eax,(%esp)
c0107c63:	e8 d0 fe ff ff       	call   c0107b38 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0107c68:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0107c6b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107c6e:	29 d1                	sub    %edx,%ecx
c0107c70:	89 ca                	mov    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0107c72:	89 d6                	mov    %edx,%esi
c0107c74:	c1 e6 16             	shl    $0x16,%esi
c0107c77:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107c7a:	89 d3                	mov    %edx,%ebx
c0107c7c:	c1 e3 16             	shl    $0x16,%ebx
c0107c7f:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107c82:	89 d1                	mov    %edx,%ecx
c0107c84:	c1 e1 16             	shl    $0x16,%ecx
c0107c87:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0107c8a:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107c8d:	29 d7                	sub    %edx,%edi
c0107c8f:	89 fa                	mov    %edi,%edx
c0107c91:	89 44 24 14          	mov    %eax,0x14(%esp)
c0107c95:	89 74 24 10          	mov    %esi,0x10(%esp)
c0107c99:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0107c9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0107ca1:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107ca5:	c7 04 24 91 a9 10 c0 	movl   $0xc010a991,(%esp)
c0107cac:	e8 f0 85 ff ff       	call   c01002a1 <cprintf>
        size_t l, r = left * NPTEENTRY;
c0107cb1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107cb4:	c1 e0 0a             	shl    $0xa,%eax
c0107cb7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0107cba:	eb 54                	jmp    c0107d10 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0107cbc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107cbf:	89 04 24             	mov    %eax,(%esp)
c0107cc2:	e8 71 fe ff ff       	call   c0107b38 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0107cc7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0107cca:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0107ccd:	29 d1                	sub    %edx,%ecx
c0107ccf:	89 ca                	mov    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0107cd1:	89 d6                	mov    %edx,%esi
c0107cd3:	c1 e6 0c             	shl    $0xc,%esi
c0107cd6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107cd9:	89 d3                	mov    %edx,%ebx
c0107cdb:	c1 e3 0c             	shl    $0xc,%ebx
c0107cde:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0107ce1:	c1 e2 0c             	shl    $0xc,%edx
c0107ce4:	89 d1                	mov    %edx,%ecx
c0107ce6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c0107ce9:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0107cec:	29 d7                	sub    %edx,%edi
c0107cee:	89 fa                	mov    %edi,%edx
c0107cf0:	89 44 24 14          	mov    %eax,0x14(%esp)
c0107cf4:	89 74 24 10          	mov    %esi,0x10(%esp)
c0107cf8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0107cfc:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0107d00:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107d04:	c7 04 24 b0 a9 10 c0 	movl   $0xc010a9b0,(%esp)
c0107d0b:	e8 91 85 ff ff       	call   c01002a1 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0107d10:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
c0107d15:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107d18:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0107d1b:	89 ce                	mov    %ecx,%esi
c0107d1d:	c1 e6 0a             	shl    $0xa,%esi
c0107d20:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0107d23:	89 cb                	mov    %ecx,%ebx
c0107d25:	c1 e3 0a             	shl    $0xa,%ebx
c0107d28:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
c0107d2b:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c0107d2f:	8d 4d d8             	lea    -0x28(%ebp),%ecx
c0107d32:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0107d36:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0107d3a:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107d3e:	89 74 24 04          	mov    %esi,0x4(%esp)
c0107d42:	89 1c 24             	mov    %ebx,(%esp)
c0107d45:	e8 3c fe ff ff       	call   c0107b86 <get_pgtable_items>
c0107d4a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107d4d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0107d51:	0f 85 65 ff ff ff    	jne    c0107cbc <print_pgdir+0x80>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0107d57:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
c0107d5c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107d5f:	8d 4d dc             	lea    -0x24(%ebp),%ecx
c0107d62:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c0107d66:	8d 4d e0             	lea    -0x20(%ebp),%ecx
c0107d69:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0107d6d:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0107d71:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107d75:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c0107d7c:	00 
c0107d7d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0107d84:	e8 fd fd ff ff       	call   c0107b86 <get_pgtable_items>
c0107d89:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107d8c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0107d90:	0f 85 c7 fe ff ff    	jne    c0107c5d <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0107d96:	c7 04 24 d4 a9 10 c0 	movl   $0xc010a9d4,(%esp)
c0107d9d:	e8 ff 84 ff ff       	call   c01002a1 <cprintf>
}
c0107da2:	83 c4 4c             	add    $0x4c,%esp
c0107da5:	5b                   	pop    %ebx
c0107da6:	5e                   	pop    %esi
c0107da7:	5f                   	pop    %edi
c0107da8:	5d                   	pop    %ebp
c0107da9:	c3                   	ret    

c0107daa <kmalloc>:

void *
kmalloc(size_t n) {
c0107daa:	55                   	push   %ebp
c0107dab:	89 e5                	mov    %esp,%ebp
c0107dad:	83 ec 28             	sub    $0x28,%esp
    void * ptr=NULL;
c0107db0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    struct Page *base=NULL;
c0107db7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    assert(n > 0 && n < 1024*0124);
c0107dbe:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0107dc2:	74 09                	je     c0107dcd <kmalloc+0x23>
c0107dc4:	81 7d 08 ff 4f 01 00 	cmpl   $0x14fff,0x8(%ebp)
c0107dcb:	76 24                	jbe    c0107df1 <kmalloc+0x47>
c0107dcd:	c7 44 24 0c 05 aa 10 	movl   $0xc010aa05,0xc(%esp)
c0107dd4:	c0 
c0107dd5:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c0107ddc:	c0 
c0107ddd:	c7 44 24 04 6e 02 00 	movl   $0x26e,0x4(%esp)
c0107de4:	00 
c0107de5:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c0107dec:	e8 07 86 ff ff       	call   c01003f8 <__panic>
    int num_pages=(n+PGSIZE-1)/PGSIZE;
c0107df1:	8b 45 08             	mov    0x8(%ebp),%eax
c0107df4:	05 ff 0f 00 00       	add    $0xfff,%eax
c0107df9:	c1 e8 0c             	shr    $0xc,%eax
c0107dfc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    base = alloc_pages(num_pages);
c0107dff:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107e02:	89 04 24             	mov    %eax,(%esp)
c0107e05:	e8 f0 e7 ff ff       	call   c01065fa <alloc_pages>
c0107e0a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(base != NULL);
c0107e0d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107e11:	75 24                	jne    c0107e37 <kmalloc+0x8d>
c0107e13:	c7 44 24 0c 1c aa 10 	movl   $0xc010aa1c,0xc(%esp)
c0107e1a:	c0 
c0107e1b:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c0107e22:	c0 
c0107e23:	c7 44 24 04 71 02 00 	movl   $0x271,0x4(%esp)
c0107e2a:	00 
c0107e2b:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c0107e32:	e8 c1 85 ff ff       	call   c01003f8 <__panic>
    ptr=page2kva(base);
c0107e37:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107e3a:	89 04 24             	mov    %eax,(%esp)
c0107e3d:	e8 bf e4 ff ff       	call   c0106301 <page2kva>
c0107e42:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ptr;
c0107e45:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107e48:	c9                   	leave  
c0107e49:	c3                   	ret    

c0107e4a <kfree>:

void 
kfree(void *ptr, size_t n) {
c0107e4a:	55                   	push   %ebp
c0107e4b:	89 e5                	mov    %esp,%ebp
c0107e4d:	83 ec 28             	sub    $0x28,%esp
    assert(n > 0 && n < 1024*0124);
c0107e50:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0107e54:	74 09                	je     c0107e5f <kfree+0x15>
c0107e56:	81 7d 0c ff 4f 01 00 	cmpl   $0x14fff,0xc(%ebp)
c0107e5d:	76 24                	jbe    c0107e83 <kfree+0x39>
c0107e5f:	c7 44 24 0c 05 aa 10 	movl   $0xc010aa05,0xc(%esp)
c0107e66:	c0 
c0107e67:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c0107e6e:	c0 
c0107e6f:	c7 44 24 04 78 02 00 	movl   $0x278,0x4(%esp)
c0107e76:	00 
c0107e77:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c0107e7e:	e8 75 85 ff ff       	call   c01003f8 <__panic>
    assert(ptr != NULL);
c0107e83:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0107e87:	75 24                	jne    c0107ead <kfree+0x63>
c0107e89:	c7 44 24 0c 29 aa 10 	movl   $0xc010aa29,0xc(%esp)
c0107e90:	c0 
c0107e91:	c7 44 24 08 a9 a4 10 	movl   $0xc010a4a9,0x8(%esp)
c0107e98:	c0 
c0107e99:	c7 44 24 04 79 02 00 	movl   $0x279,0x4(%esp)
c0107ea0:	00 
c0107ea1:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c0107ea8:	e8 4b 85 ff ff       	call   c01003f8 <__panic>
    struct Page *base=NULL;
c0107ead:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    int num_pages=(n+PGSIZE-1)/PGSIZE;
c0107eb4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107eb7:	05 ff 0f 00 00       	add    $0xfff,%eax
c0107ebc:	c1 e8 0c             	shr    $0xc,%eax
c0107ebf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    base = kva2page(ptr);
c0107ec2:	8b 45 08             	mov    0x8(%ebp),%eax
c0107ec5:	89 04 24             	mov    %eax,(%esp)
c0107ec8:	e8 88 e4 ff ff       	call   c0106355 <kva2page>
c0107ecd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    free_pages(base, num_pages);
c0107ed0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107ed3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107ed7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107eda:	89 04 24             	mov    %eax,(%esp)
c0107edd:	e8 83 e7 ff ff       	call   c0106665 <free_pages>
}
c0107ee2:	c9                   	leave  
c0107ee3:	c3                   	ret    

c0107ee4 <page2ppn>:
page2ppn(struct Page *page) {
c0107ee4:	55                   	push   %ebp
c0107ee5:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0107ee7:	8b 55 08             	mov    0x8(%ebp),%edx
c0107eea:	a1 f8 40 12 c0       	mov    0xc01240f8,%eax
c0107eef:	29 c2                	sub    %eax,%edx
c0107ef1:	89 d0                	mov    %edx,%eax
c0107ef3:	c1 f8 05             	sar    $0x5,%eax
}
c0107ef6:	5d                   	pop    %ebp
c0107ef7:	c3                   	ret    

c0107ef8 <page2pa>:
page2pa(struct Page *page) {
c0107ef8:	55                   	push   %ebp
c0107ef9:	89 e5                	mov    %esp,%ebp
c0107efb:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0107efe:	8b 45 08             	mov    0x8(%ebp),%eax
c0107f01:	89 04 24             	mov    %eax,(%esp)
c0107f04:	e8 db ff ff ff       	call   c0107ee4 <page2ppn>
c0107f09:	c1 e0 0c             	shl    $0xc,%eax
}
c0107f0c:	c9                   	leave  
c0107f0d:	c3                   	ret    

c0107f0e <page2kva>:
page2kva(struct Page *page) {
c0107f0e:	55                   	push   %ebp
c0107f0f:	89 e5                	mov    %esp,%ebp
c0107f11:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0107f14:	8b 45 08             	mov    0x8(%ebp),%eax
c0107f17:	89 04 24             	mov    %eax,(%esp)
c0107f1a:	e8 d9 ff ff ff       	call   c0107ef8 <page2pa>
c0107f1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107f22:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f25:	c1 e8 0c             	shr    $0xc,%eax
c0107f28:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107f2b:	a1 80 3f 12 c0       	mov    0xc0123f80,%eax
c0107f30:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0107f33:	72 23                	jb     c0107f58 <page2kva+0x4a>
c0107f35:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f38:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107f3c:	c7 44 24 08 38 aa 10 	movl   $0xc010aa38,0x8(%esp)
c0107f43:	c0 
c0107f44:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
c0107f4b:	00 
c0107f4c:	c7 04 24 5b aa 10 c0 	movl   $0xc010aa5b,(%esp)
c0107f53:	e8 a0 84 ff ff       	call   c01003f8 <__panic>
c0107f58:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f5b:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0107f60:	c9                   	leave  
c0107f61:	c3                   	ret    

c0107f62 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
c0107f62:	55                   	push   %ebp
c0107f63:	89 e5                	mov    %esp,%ebp
c0107f65:	83 ec 18             	sub    $0x18,%esp
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
c0107f68:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107f6f:	e8 b7 91 ff ff       	call   c010112b <ide_device_valid>
c0107f74:	85 c0                	test   %eax,%eax
c0107f76:	75 1c                	jne    c0107f94 <swapfs_init+0x32>
        panic("swap fs isn't available.\n");
c0107f78:	c7 44 24 08 69 aa 10 	movl   $0xc010aa69,0x8(%esp)
c0107f7f:	c0 
c0107f80:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
c0107f87:	00 
c0107f88:	c7 04 24 83 aa 10 c0 	movl   $0xc010aa83,(%esp)
c0107f8f:	e8 64 84 ff ff       	call   c01003f8 <__panic>
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
c0107f94:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107f9b:	e8 ca 91 ff ff       	call   c010116a <ide_device_size>
c0107fa0:	c1 e8 03             	shr    $0x3,%eax
c0107fa3:	a3 bc 40 12 c0       	mov    %eax,0xc01240bc
}
c0107fa8:	c9                   	leave  
c0107fa9:	c3                   	ret    

c0107faa <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
c0107faa:	55                   	push   %ebp
c0107fab:	89 e5                	mov    %esp,%ebp
c0107fad:	83 ec 28             	sub    $0x28,%esp
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c0107fb0:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107fb3:	89 04 24             	mov    %eax,(%esp)
c0107fb6:	e8 53 ff ff ff       	call   c0107f0e <page2kva>
c0107fbb:	8b 55 08             	mov    0x8(%ebp),%edx
c0107fbe:	c1 ea 08             	shr    $0x8,%edx
c0107fc1:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0107fc4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107fc8:	74 0b                	je     c0107fd5 <swapfs_read+0x2b>
c0107fca:	8b 15 bc 40 12 c0    	mov    0xc01240bc,%edx
c0107fd0:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c0107fd3:	72 23                	jb     c0107ff8 <swapfs_read+0x4e>
c0107fd5:	8b 45 08             	mov    0x8(%ebp),%eax
c0107fd8:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107fdc:	c7 44 24 08 94 aa 10 	movl   $0xc010aa94,0x8(%esp)
c0107fe3:	c0 
c0107fe4:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c0107feb:	00 
c0107fec:	c7 04 24 83 aa 10 c0 	movl   $0xc010aa83,(%esp)
c0107ff3:	e8 00 84 ff ff       	call   c01003f8 <__panic>
c0107ff8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107ffb:	c1 e2 03             	shl    $0x3,%edx
c0107ffe:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c0108005:	00 
c0108006:	89 44 24 08          	mov    %eax,0x8(%esp)
c010800a:	89 54 24 04          	mov    %edx,0x4(%esp)
c010800e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108015:	e8 8f 91 ff ff       	call   c01011a9 <ide_read_secs>
}
c010801a:	c9                   	leave  
c010801b:	c3                   	ret    

c010801c <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
c010801c:	55                   	push   %ebp
c010801d:	89 e5                	mov    %esp,%ebp
c010801f:	83 ec 28             	sub    $0x28,%esp
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c0108022:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108025:	89 04 24             	mov    %eax,(%esp)
c0108028:	e8 e1 fe ff ff       	call   c0107f0e <page2kva>
c010802d:	8b 55 08             	mov    0x8(%ebp),%edx
c0108030:	c1 ea 08             	shr    $0x8,%edx
c0108033:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0108036:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010803a:	74 0b                	je     c0108047 <swapfs_write+0x2b>
c010803c:	8b 15 bc 40 12 c0    	mov    0xc01240bc,%edx
c0108042:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c0108045:	72 23                	jb     c010806a <swapfs_write+0x4e>
c0108047:	8b 45 08             	mov    0x8(%ebp),%eax
c010804a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010804e:	c7 44 24 08 94 aa 10 	movl   $0xc010aa94,0x8(%esp)
c0108055:	c0 
c0108056:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
c010805d:	00 
c010805e:	c7 04 24 83 aa 10 c0 	movl   $0xc010aa83,(%esp)
c0108065:	e8 8e 83 ff ff       	call   c01003f8 <__panic>
c010806a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010806d:	c1 e2 03             	shl    $0x3,%edx
c0108070:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c0108077:	00 
c0108078:	89 44 24 08          	mov    %eax,0x8(%esp)
c010807c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108080:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108087:	e8 5f 93 ff ff       	call   c01013eb <ide_write_secs>
}
c010808c:	c9                   	leave  
c010808d:	c3                   	ret    

c010808e <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c010808e:	55                   	push   %ebp
c010808f:	89 e5                	mov    %esp,%ebp
c0108091:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0108094:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c010809b:	eb 04                	jmp    c01080a1 <strlen+0x13>
        cnt ++;
c010809d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (*s ++ != '\0') {
c01080a1:	8b 45 08             	mov    0x8(%ebp),%eax
c01080a4:	8d 50 01             	lea    0x1(%eax),%edx
c01080a7:	89 55 08             	mov    %edx,0x8(%ebp)
c01080aa:	0f b6 00             	movzbl (%eax),%eax
c01080ad:	84 c0                	test   %al,%al
c01080af:	75 ec                	jne    c010809d <strlen+0xf>
    }
    return cnt;
c01080b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01080b4:	c9                   	leave  
c01080b5:	c3                   	ret    

c01080b6 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c01080b6:	55                   	push   %ebp
c01080b7:	89 e5                	mov    %esp,%ebp
c01080b9:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c01080bc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c01080c3:	eb 04                	jmp    c01080c9 <strnlen+0x13>
        cnt ++;
c01080c5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c01080c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01080cc:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01080cf:	73 10                	jae    c01080e1 <strnlen+0x2b>
c01080d1:	8b 45 08             	mov    0x8(%ebp),%eax
c01080d4:	8d 50 01             	lea    0x1(%eax),%edx
c01080d7:	89 55 08             	mov    %edx,0x8(%ebp)
c01080da:	0f b6 00             	movzbl (%eax),%eax
c01080dd:	84 c0                	test   %al,%al
c01080df:	75 e4                	jne    c01080c5 <strnlen+0xf>
    }
    return cnt;
c01080e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01080e4:	c9                   	leave  
c01080e5:	c3                   	ret    

c01080e6 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c01080e6:	55                   	push   %ebp
c01080e7:	89 e5                	mov    %esp,%ebp
c01080e9:	57                   	push   %edi
c01080ea:	56                   	push   %esi
c01080eb:	83 ec 20             	sub    $0x20,%esp
c01080ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01080f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01080f4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01080f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c01080fa:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01080fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108100:	89 d1                	mov    %edx,%ecx
c0108102:	89 c2                	mov    %eax,%edx
c0108104:	89 ce                	mov    %ecx,%esi
c0108106:	89 d7                	mov    %edx,%edi
c0108108:	ac                   	lods   %ds:(%esi),%al
c0108109:	aa                   	stos   %al,%es:(%edi)
c010810a:	84 c0                	test   %al,%al
c010810c:	75 fa                	jne    c0108108 <strcpy+0x22>
c010810e:	89 fa                	mov    %edi,%edx
c0108110:	89 f1                	mov    %esi,%ecx
c0108112:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0108115:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0108118:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c010811b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c010811e:	83 c4 20             	add    $0x20,%esp
c0108121:	5e                   	pop    %esi
c0108122:	5f                   	pop    %edi
c0108123:	5d                   	pop    %ebp
c0108124:	c3                   	ret    

c0108125 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0108125:	55                   	push   %ebp
c0108126:	89 e5                	mov    %esp,%ebp
c0108128:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c010812b:	8b 45 08             	mov    0x8(%ebp),%eax
c010812e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0108131:	eb 21                	jmp    c0108154 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
c0108133:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108136:	0f b6 10             	movzbl (%eax),%edx
c0108139:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010813c:	88 10                	mov    %dl,(%eax)
c010813e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108141:	0f b6 00             	movzbl (%eax),%eax
c0108144:	84 c0                	test   %al,%al
c0108146:	74 04                	je     c010814c <strncpy+0x27>
            src ++;
c0108148:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
c010814c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0108150:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    while (len > 0) {
c0108154:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108158:	75 d9                	jne    c0108133 <strncpy+0xe>
    }
    return dst;
c010815a:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010815d:	c9                   	leave  
c010815e:	c3                   	ret    

c010815f <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c010815f:	55                   	push   %ebp
c0108160:	89 e5                	mov    %esp,%ebp
c0108162:	57                   	push   %edi
c0108163:	56                   	push   %esi
c0108164:	83 ec 20             	sub    $0x20,%esp
c0108167:	8b 45 08             	mov    0x8(%ebp),%eax
c010816a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010816d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108170:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c0108173:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108176:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108179:	89 d1                	mov    %edx,%ecx
c010817b:	89 c2                	mov    %eax,%edx
c010817d:	89 ce                	mov    %ecx,%esi
c010817f:	89 d7                	mov    %edx,%edi
c0108181:	ac                   	lods   %ds:(%esi),%al
c0108182:	ae                   	scas   %es:(%edi),%al
c0108183:	75 08                	jne    c010818d <strcmp+0x2e>
c0108185:	84 c0                	test   %al,%al
c0108187:	75 f8                	jne    c0108181 <strcmp+0x22>
c0108189:	31 c0                	xor    %eax,%eax
c010818b:	eb 04                	jmp    c0108191 <strcmp+0x32>
c010818d:	19 c0                	sbb    %eax,%eax
c010818f:	0c 01                	or     $0x1,%al
c0108191:	89 fa                	mov    %edi,%edx
c0108193:	89 f1                	mov    %esi,%ecx
c0108195:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108198:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010819b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c010819e:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c01081a1:	83 c4 20             	add    $0x20,%esp
c01081a4:	5e                   	pop    %esi
c01081a5:	5f                   	pop    %edi
c01081a6:	5d                   	pop    %ebp
c01081a7:	c3                   	ret    

c01081a8 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c01081a8:	55                   	push   %ebp
c01081a9:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c01081ab:	eb 0c                	jmp    c01081b9 <strncmp+0x11>
        n --, s1 ++, s2 ++;
c01081ad:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c01081b1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c01081b5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c01081b9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01081bd:	74 1a                	je     c01081d9 <strncmp+0x31>
c01081bf:	8b 45 08             	mov    0x8(%ebp),%eax
c01081c2:	0f b6 00             	movzbl (%eax),%eax
c01081c5:	84 c0                	test   %al,%al
c01081c7:	74 10                	je     c01081d9 <strncmp+0x31>
c01081c9:	8b 45 08             	mov    0x8(%ebp),%eax
c01081cc:	0f b6 10             	movzbl (%eax),%edx
c01081cf:	8b 45 0c             	mov    0xc(%ebp),%eax
c01081d2:	0f b6 00             	movzbl (%eax),%eax
c01081d5:	38 c2                	cmp    %al,%dl
c01081d7:	74 d4                	je     c01081ad <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c01081d9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01081dd:	74 18                	je     c01081f7 <strncmp+0x4f>
c01081df:	8b 45 08             	mov    0x8(%ebp),%eax
c01081e2:	0f b6 00             	movzbl (%eax),%eax
c01081e5:	0f b6 d0             	movzbl %al,%edx
c01081e8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01081eb:	0f b6 00             	movzbl (%eax),%eax
c01081ee:	0f b6 c0             	movzbl %al,%eax
c01081f1:	29 c2                	sub    %eax,%edx
c01081f3:	89 d0                	mov    %edx,%eax
c01081f5:	eb 05                	jmp    c01081fc <strncmp+0x54>
c01081f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01081fc:	5d                   	pop    %ebp
c01081fd:	c3                   	ret    

c01081fe <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c01081fe:	55                   	push   %ebp
c01081ff:	89 e5                	mov    %esp,%ebp
c0108201:	83 ec 04             	sub    $0x4,%esp
c0108204:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108207:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010820a:	eb 14                	jmp    c0108220 <strchr+0x22>
        if (*s == c) {
c010820c:	8b 45 08             	mov    0x8(%ebp),%eax
c010820f:	0f b6 00             	movzbl (%eax),%eax
c0108212:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0108215:	75 05                	jne    c010821c <strchr+0x1e>
            return (char *)s;
c0108217:	8b 45 08             	mov    0x8(%ebp),%eax
c010821a:	eb 13                	jmp    c010822f <strchr+0x31>
        }
        s ++;
c010821c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
c0108220:	8b 45 08             	mov    0x8(%ebp),%eax
c0108223:	0f b6 00             	movzbl (%eax),%eax
c0108226:	84 c0                	test   %al,%al
c0108228:	75 e2                	jne    c010820c <strchr+0xe>
    }
    return NULL;
c010822a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010822f:	c9                   	leave  
c0108230:	c3                   	ret    

c0108231 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0108231:	55                   	push   %ebp
c0108232:	89 e5                	mov    %esp,%ebp
c0108234:	83 ec 04             	sub    $0x4,%esp
c0108237:	8b 45 0c             	mov    0xc(%ebp),%eax
c010823a:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010823d:	eb 11                	jmp    c0108250 <strfind+0x1f>
        if (*s == c) {
c010823f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108242:	0f b6 00             	movzbl (%eax),%eax
c0108245:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0108248:	75 02                	jne    c010824c <strfind+0x1b>
            break;
c010824a:	eb 0e                	jmp    c010825a <strfind+0x29>
        }
        s ++;
c010824c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
c0108250:	8b 45 08             	mov    0x8(%ebp),%eax
c0108253:	0f b6 00             	movzbl (%eax),%eax
c0108256:	84 c0                	test   %al,%al
c0108258:	75 e5                	jne    c010823f <strfind+0xe>
    }
    return (char *)s;
c010825a:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010825d:	c9                   	leave  
c010825e:	c3                   	ret    

c010825f <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c010825f:	55                   	push   %ebp
c0108260:	89 e5                	mov    %esp,%ebp
c0108262:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0108265:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c010826c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0108273:	eb 04                	jmp    c0108279 <strtol+0x1a>
        s ++;
c0108275:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c0108279:	8b 45 08             	mov    0x8(%ebp),%eax
c010827c:	0f b6 00             	movzbl (%eax),%eax
c010827f:	3c 20                	cmp    $0x20,%al
c0108281:	74 f2                	je     c0108275 <strtol+0x16>
c0108283:	8b 45 08             	mov    0x8(%ebp),%eax
c0108286:	0f b6 00             	movzbl (%eax),%eax
c0108289:	3c 09                	cmp    $0x9,%al
c010828b:	74 e8                	je     c0108275 <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
c010828d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108290:	0f b6 00             	movzbl (%eax),%eax
c0108293:	3c 2b                	cmp    $0x2b,%al
c0108295:	75 06                	jne    c010829d <strtol+0x3e>
        s ++;
c0108297:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010829b:	eb 15                	jmp    c01082b2 <strtol+0x53>
    }
    else if (*s == '-') {
c010829d:	8b 45 08             	mov    0x8(%ebp),%eax
c01082a0:	0f b6 00             	movzbl (%eax),%eax
c01082a3:	3c 2d                	cmp    $0x2d,%al
c01082a5:	75 0b                	jne    c01082b2 <strtol+0x53>
        s ++, neg = 1;
c01082a7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c01082ab:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c01082b2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01082b6:	74 06                	je     c01082be <strtol+0x5f>
c01082b8:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c01082bc:	75 24                	jne    c01082e2 <strtol+0x83>
c01082be:	8b 45 08             	mov    0x8(%ebp),%eax
c01082c1:	0f b6 00             	movzbl (%eax),%eax
c01082c4:	3c 30                	cmp    $0x30,%al
c01082c6:	75 1a                	jne    c01082e2 <strtol+0x83>
c01082c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01082cb:	83 c0 01             	add    $0x1,%eax
c01082ce:	0f b6 00             	movzbl (%eax),%eax
c01082d1:	3c 78                	cmp    $0x78,%al
c01082d3:	75 0d                	jne    c01082e2 <strtol+0x83>
        s += 2, base = 16;
c01082d5:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c01082d9:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c01082e0:	eb 2a                	jmp    c010830c <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
c01082e2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01082e6:	75 17                	jne    c01082ff <strtol+0xa0>
c01082e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01082eb:	0f b6 00             	movzbl (%eax),%eax
c01082ee:	3c 30                	cmp    $0x30,%al
c01082f0:	75 0d                	jne    c01082ff <strtol+0xa0>
        s ++, base = 8;
c01082f2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c01082f6:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c01082fd:	eb 0d                	jmp    c010830c <strtol+0xad>
    }
    else if (base == 0) {
c01082ff:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108303:	75 07                	jne    c010830c <strtol+0xad>
        base = 10;
c0108305:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c010830c:	8b 45 08             	mov    0x8(%ebp),%eax
c010830f:	0f b6 00             	movzbl (%eax),%eax
c0108312:	3c 2f                	cmp    $0x2f,%al
c0108314:	7e 1b                	jle    c0108331 <strtol+0xd2>
c0108316:	8b 45 08             	mov    0x8(%ebp),%eax
c0108319:	0f b6 00             	movzbl (%eax),%eax
c010831c:	3c 39                	cmp    $0x39,%al
c010831e:	7f 11                	jg     c0108331 <strtol+0xd2>
            dig = *s - '0';
c0108320:	8b 45 08             	mov    0x8(%ebp),%eax
c0108323:	0f b6 00             	movzbl (%eax),%eax
c0108326:	0f be c0             	movsbl %al,%eax
c0108329:	83 e8 30             	sub    $0x30,%eax
c010832c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010832f:	eb 48                	jmp    c0108379 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0108331:	8b 45 08             	mov    0x8(%ebp),%eax
c0108334:	0f b6 00             	movzbl (%eax),%eax
c0108337:	3c 60                	cmp    $0x60,%al
c0108339:	7e 1b                	jle    c0108356 <strtol+0xf7>
c010833b:	8b 45 08             	mov    0x8(%ebp),%eax
c010833e:	0f b6 00             	movzbl (%eax),%eax
c0108341:	3c 7a                	cmp    $0x7a,%al
c0108343:	7f 11                	jg     c0108356 <strtol+0xf7>
            dig = *s - 'a' + 10;
c0108345:	8b 45 08             	mov    0x8(%ebp),%eax
c0108348:	0f b6 00             	movzbl (%eax),%eax
c010834b:	0f be c0             	movsbl %al,%eax
c010834e:	83 e8 57             	sub    $0x57,%eax
c0108351:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108354:	eb 23                	jmp    c0108379 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0108356:	8b 45 08             	mov    0x8(%ebp),%eax
c0108359:	0f b6 00             	movzbl (%eax),%eax
c010835c:	3c 40                	cmp    $0x40,%al
c010835e:	7e 3d                	jle    c010839d <strtol+0x13e>
c0108360:	8b 45 08             	mov    0x8(%ebp),%eax
c0108363:	0f b6 00             	movzbl (%eax),%eax
c0108366:	3c 5a                	cmp    $0x5a,%al
c0108368:	7f 33                	jg     c010839d <strtol+0x13e>
            dig = *s - 'A' + 10;
c010836a:	8b 45 08             	mov    0x8(%ebp),%eax
c010836d:	0f b6 00             	movzbl (%eax),%eax
c0108370:	0f be c0             	movsbl %al,%eax
c0108373:	83 e8 37             	sub    $0x37,%eax
c0108376:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0108379:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010837c:	3b 45 10             	cmp    0x10(%ebp),%eax
c010837f:	7c 02                	jl     c0108383 <strtol+0x124>
            break;
c0108381:	eb 1a                	jmp    c010839d <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
c0108383:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0108387:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010838a:	0f af 45 10          	imul   0x10(%ebp),%eax
c010838e:	89 c2                	mov    %eax,%edx
c0108390:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108393:	01 d0                	add    %edx,%eax
c0108395:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c0108398:	e9 6f ff ff ff       	jmp    c010830c <strtol+0xad>

    if (endptr) {
c010839d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01083a1:	74 08                	je     c01083ab <strtol+0x14c>
        *endptr = (char *) s;
c01083a3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01083a6:	8b 55 08             	mov    0x8(%ebp),%edx
c01083a9:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c01083ab:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01083af:	74 07                	je     c01083b8 <strtol+0x159>
c01083b1:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01083b4:	f7 d8                	neg    %eax
c01083b6:	eb 03                	jmp    c01083bb <strtol+0x15c>
c01083b8:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c01083bb:	c9                   	leave  
c01083bc:	c3                   	ret    

c01083bd <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c01083bd:	55                   	push   %ebp
c01083be:	89 e5                	mov    %esp,%ebp
c01083c0:	57                   	push   %edi
c01083c1:	83 ec 24             	sub    $0x24,%esp
c01083c4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01083c7:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c01083ca:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c01083ce:	8b 55 08             	mov    0x8(%ebp),%edx
c01083d1:	89 55 f8             	mov    %edx,-0x8(%ebp)
c01083d4:	88 45 f7             	mov    %al,-0x9(%ebp)
c01083d7:	8b 45 10             	mov    0x10(%ebp),%eax
c01083da:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c01083dd:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c01083e0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c01083e4:	8b 55 f8             	mov    -0x8(%ebp),%edx
c01083e7:	89 d7                	mov    %edx,%edi
c01083e9:	f3 aa                	rep stos %al,%es:(%edi)
c01083eb:	89 fa                	mov    %edi,%edx
c01083ed:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c01083f0:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c01083f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c01083f6:	83 c4 24             	add    $0x24,%esp
c01083f9:	5f                   	pop    %edi
c01083fa:	5d                   	pop    %ebp
c01083fb:	c3                   	ret    

c01083fc <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c01083fc:	55                   	push   %ebp
c01083fd:	89 e5                	mov    %esp,%ebp
c01083ff:	57                   	push   %edi
c0108400:	56                   	push   %esi
c0108401:	53                   	push   %ebx
c0108402:	83 ec 30             	sub    $0x30,%esp
c0108405:	8b 45 08             	mov    0x8(%ebp),%eax
c0108408:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010840b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010840e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108411:	8b 45 10             	mov    0x10(%ebp),%eax
c0108414:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0108417:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010841a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010841d:	73 42                	jae    c0108461 <memmove+0x65>
c010841f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108422:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108425:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108428:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010842b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010842e:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0108431:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108434:	c1 e8 02             	shr    $0x2,%eax
c0108437:	89 c1                	mov    %eax,%ecx
    asm volatile (
c0108439:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010843c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010843f:	89 d7                	mov    %edx,%edi
c0108441:	89 c6                	mov    %eax,%esi
c0108443:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0108445:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0108448:	83 e1 03             	and    $0x3,%ecx
c010844b:	74 02                	je     c010844f <memmove+0x53>
c010844d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010844f:	89 f0                	mov    %esi,%eax
c0108451:	89 fa                	mov    %edi,%edx
c0108453:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0108456:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0108459:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c010845c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010845f:	eb 36                	jmp    c0108497 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0108461:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108464:	8d 50 ff             	lea    -0x1(%eax),%edx
c0108467:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010846a:	01 c2                	add    %eax,%edx
c010846c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010846f:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0108472:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108475:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c0108478:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010847b:	89 c1                	mov    %eax,%ecx
c010847d:	89 d8                	mov    %ebx,%eax
c010847f:	89 d6                	mov    %edx,%esi
c0108481:	89 c7                	mov    %eax,%edi
c0108483:	fd                   	std    
c0108484:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0108486:	fc                   	cld    
c0108487:	89 f8                	mov    %edi,%eax
c0108489:	89 f2                	mov    %esi,%edx
c010848b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c010848e:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0108491:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c0108494:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c0108497:	83 c4 30             	add    $0x30,%esp
c010849a:	5b                   	pop    %ebx
c010849b:	5e                   	pop    %esi
c010849c:	5f                   	pop    %edi
c010849d:	5d                   	pop    %ebp
c010849e:	c3                   	ret    

c010849f <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c010849f:	55                   	push   %ebp
c01084a0:	89 e5                	mov    %esp,%ebp
c01084a2:	57                   	push   %edi
c01084a3:	56                   	push   %esi
c01084a4:	83 ec 20             	sub    $0x20,%esp
c01084a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01084aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01084ad:	8b 45 0c             	mov    0xc(%ebp),%eax
c01084b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01084b3:	8b 45 10             	mov    0x10(%ebp),%eax
c01084b6:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c01084b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01084bc:	c1 e8 02             	shr    $0x2,%eax
c01084bf:	89 c1                	mov    %eax,%ecx
    asm volatile (
c01084c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01084c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01084c7:	89 d7                	mov    %edx,%edi
c01084c9:	89 c6                	mov    %eax,%esi
c01084cb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c01084cd:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c01084d0:	83 e1 03             	and    $0x3,%ecx
c01084d3:	74 02                	je     c01084d7 <memcpy+0x38>
c01084d5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c01084d7:	89 f0                	mov    %esi,%eax
c01084d9:	89 fa                	mov    %edi,%edx
c01084db:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c01084de:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c01084e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c01084e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c01084e7:	83 c4 20             	add    $0x20,%esp
c01084ea:	5e                   	pop    %esi
c01084eb:	5f                   	pop    %edi
c01084ec:	5d                   	pop    %ebp
c01084ed:	c3                   	ret    

c01084ee <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c01084ee:	55                   	push   %ebp
c01084ef:	89 e5                	mov    %esp,%ebp
c01084f1:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c01084f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01084f7:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c01084fa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01084fd:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c0108500:	eb 30                	jmp    c0108532 <memcmp+0x44>
        if (*s1 != *s2) {
c0108502:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108505:	0f b6 10             	movzbl (%eax),%edx
c0108508:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010850b:	0f b6 00             	movzbl (%eax),%eax
c010850e:	38 c2                	cmp    %al,%dl
c0108510:	74 18                	je     c010852a <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0108512:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108515:	0f b6 00             	movzbl (%eax),%eax
c0108518:	0f b6 d0             	movzbl %al,%edx
c010851b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010851e:	0f b6 00             	movzbl (%eax),%eax
c0108521:	0f b6 c0             	movzbl %al,%eax
c0108524:	29 c2                	sub    %eax,%edx
c0108526:	89 d0                	mov    %edx,%eax
c0108528:	eb 1a                	jmp    c0108544 <memcmp+0x56>
        }
        s1 ++, s2 ++;
c010852a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010852e:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
    while (n -- > 0) {
c0108532:	8b 45 10             	mov    0x10(%ebp),%eax
c0108535:	8d 50 ff             	lea    -0x1(%eax),%edx
c0108538:	89 55 10             	mov    %edx,0x10(%ebp)
c010853b:	85 c0                	test   %eax,%eax
c010853d:	75 c3                	jne    c0108502 <memcmp+0x14>
    }
    return 0;
c010853f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108544:	c9                   	leave  
c0108545:	c3                   	ret    

c0108546 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c0108546:	55                   	push   %ebp
c0108547:	89 e5                	mov    %esp,%ebp
c0108549:	83 ec 58             	sub    $0x58,%esp
c010854c:	8b 45 10             	mov    0x10(%ebp),%eax
c010854f:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0108552:	8b 45 14             	mov    0x14(%ebp),%eax
c0108555:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c0108558:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010855b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010855e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108561:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c0108564:	8b 45 18             	mov    0x18(%ebp),%eax
c0108567:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010856a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010856d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108570:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108573:	89 55 f0             	mov    %edx,-0x10(%ebp)
c0108576:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108579:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010857c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0108580:	74 1c                	je     c010859e <printnum+0x58>
c0108582:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108585:	ba 00 00 00 00       	mov    $0x0,%edx
c010858a:	f7 75 e4             	divl   -0x1c(%ebp)
c010858d:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0108590:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108593:	ba 00 00 00 00       	mov    $0x0,%edx
c0108598:	f7 75 e4             	divl   -0x1c(%ebp)
c010859b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010859e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01085a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01085a4:	f7 75 e4             	divl   -0x1c(%ebp)
c01085a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01085aa:	89 55 dc             	mov    %edx,-0x24(%ebp)
c01085ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01085b0:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01085b3:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01085b6:	89 55 ec             	mov    %edx,-0x14(%ebp)
c01085b9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01085bc:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c01085bf:	8b 45 18             	mov    0x18(%ebp),%eax
c01085c2:	ba 00 00 00 00       	mov    $0x0,%edx
c01085c7:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01085ca:	77 56                	ja     c0108622 <printnum+0xdc>
c01085cc:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01085cf:	72 05                	jb     c01085d6 <printnum+0x90>
c01085d1:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c01085d4:	77 4c                	ja     c0108622 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c01085d6:	8b 45 1c             	mov    0x1c(%ebp),%eax
c01085d9:	8d 50 ff             	lea    -0x1(%eax),%edx
c01085dc:	8b 45 20             	mov    0x20(%ebp),%eax
c01085df:	89 44 24 18          	mov    %eax,0x18(%esp)
c01085e3:	89 54 24 14          	mov    %edx,0x14(%esp)
c01085e7:	8b 45 18             	mov    0x18(%ebp),%eax
c01085ea:	89 44 24 10          	mov    %eax,0x10(%esp)
c01085ee:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01085f1:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01085f4:	89 44 24 08          	mov    %eax,0x8(%esp)
c01085f8:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01085fc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01085ff:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108603:	8b 45 08             	mov    0x8(%ebp),%eax
c0108606:	89 04 24             	mov    %eax,(%esp)
c0108609:	e8 38 ff ff ff       	call   c0108546 <printnum>
c010860e:	eb 1c                	jmp    c010862c <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c0108610:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108613:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108617:	8b 45 20             	mov    0x20(%ebp),%eax
c010861a:	89 04 24             	mov    %eax,(%esp)
c010861d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108620:	ff d0                	call   *%eax
        while (-- width > 0)
c0108622:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
c0108626:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c010862a:	7f e4                	jg     c0108610 <printnum+0xca>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c010862c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010862f:	05 34 ab 10 c0       	add    $0xc010ab34,%eax
c0108634:	0f b6 00             	movzbl (%eax),%eax
c0108637:	0f be c0             	movsbl %al,%eax
c010863a:	8b 55 0c             	mov    0xc(%ebp),%edx
c010863d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108641:	89 04 24             	mov    %eax,(%esp)
c0108644:	8b 45 08             	mov    0x8(%ebp),%eax
c0108647:	ff d0                	call   *%eax
}
c0108649:	c9                   	leave  
c010864a:	c3                   	ret    

c010864b <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c010864b:	55                   	push   %ebp
c010864c:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010864e:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0108652:	7e 14                	jle    c0108668 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c0108654:	8b 45 08             	mov    0x8(%ebp),%eax
c0108657:	8b 00                	mov    (%eax),%eax
c0108659:	8d 48 08             	lea    0x8(%eax),%ecx
c010865c:	8b 55 08             	mov    0x8(%ebp),%edx
c010865f:	89 0a                	mov    %ecx,(%edx)
c0108661:	8b 50 04             	mov    0x4(%eax),%edx
c0108664:	8b 00                	mov    (%eax),%eax
c0108666:	eb 30                	jmp    c0108698 <getuint+0x4d>
    }
    else if (lflag) {
c0108668:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010866c:	74 16                	je     c0108684 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c010866e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108671:	8b 00                	mov    (%eax),%eax
c0108673:	8d 48 04             	lea    0x4(%eax),%ecx
c0108676:	8b 55 08             	mov    0x8(%ebp),%edx
c0108679:	89 0a                	mov    %ecx,(%edx)
c010867b:	8b 00                	mov    (%eax),%eax
c010867d:	ba 00 00 00 00       	mov    $0x0,%edx
c0108682:	eb 14                	jmp    c0108698 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c0108684:	8b 45 08             	mov    0x8(%ebp),%eax
c0108687:	8b 00                	mov    (%eax),%eax
c0108689:	8d 48 04             	lea    0x4(%eax),%ecx
c010868c:	8b 55 08             	mov    0x8(%ebp),%edx
c010868f:	89 0a                	mov    %ecx,(%edx)
c0108691:	8b 00                	mov    (%eax),%eax
c0108693:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c0108698:	5d                   	pop    %ebp
c0108699:	c3                   	ret    

c010869a <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c010869a:	55                   	push   %ebp
c010869b:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010869d:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01086a1:	7e 14                	jle    c01086b7 <getint+0x1d>
        return va_arg(*ap, long long);
c01086a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01086a6:	8b 00                	mov    (%eax),%eax
c01086a8:	8d 48 08             	lea    0x8(%eax),%ecx
c01086ab:	8b 55 08             	mov    0x8(%ebp),%edx
c01086ae:	89 0a                	mov    %ecx,(%edx)
c01086b0:	8b 50 04             	mov    0x4(%eax),%edx
c01086b3:	8b 00                	mov    (%eax),%eax
c01086b5:	eb 28                	jmp    c01086df <getint+0x45>
    }
    else if (lflag) {
c01086b7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01086bb:	74 12                	je     c01086cf <getint+0x35>
        return va_arg(*ap, long);
c01086bd:	8b 45 08             	mov    0x8(%ebp),%eax
c01086c0:	8b 00                	mov    (%eax),%eax
c01086c2:	8d 48 04             	lea    0x4(%eax),%ecx
c01086c5:	8b 55 08             	mov    0x8(%ebp),%edx
c01086c8:	89 0a                	mov    %ecx,(%edx)
c01086ca:	8b 00                	mov    (%eax),%eax
c01086cc:	99                   	cltd   
c01086cd:	eb 10                	jmp    c01086df <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c01086cf:	8b 45 08             	mov    0x8(%ebp),%eax
c01086d2:	8b 00                	mov    (%eax),%eax
c01086d4:	8d 48 04             	lea    0x4(%eax),%ecx
c01086d7:	8b 55 08             	mov    0x8(%ebp),%edx
c01086da:	89 0a                	mov    %ecx,(%edx)
c01086dc:	8b 00                	mov    (%eax),%eax
c01086de:	99                   	cltd   
    }
}
c01086df:	5d                   	pop    %ebp
c01086e0:	c3                   	ret    

c01086e1 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c01086e1:	55                   	push   %ebp
c01086e2:	89 e5                	mov    %esp,%ebp
c01086e4:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c01086e7:	8d 45 14             	lea    0x14(%ebp),%eax
c01086ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c01086ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01086f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01086f4:	8b 45 10             	mov    0x10(%ebp),%eax
c01086f7:	89 44 24 08          	mov    %eax,0x8(%esp)
c01086fb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01086fe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108702:	8b 45 08             	mov    0x8(%ebp),%eax
c0108705:	89 04 24             	mov    %eax,(%esp)
c0108708:	e8 02 00 00 00       	call   c010870f <vprintfmt>
    va_end(ap);
}
c010870d:	c9                   	leave  
c010870e:	c3                   	ret    

c010870f <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c010870f:	55                   	push   %ebp
c0108710:	89 e5                	mov    %esp,%ebp
c0108712:	56                   	push   %esi
c0108713:	53                   	push   %ebx
c0108714:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0108717:	eb 18                	jmp    c0108731 <vprintfmt+0x22>
            if (ch == '\0') {
c0108719:	85 db                	test   %ebx,%ebx
c010871b:	75 05                	jne    c0108722 <vprintfmt+0x13>
                return;
c010871d:	e9 d1 03 00 00       	jmp    c0108af3 <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
c0108722:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108725:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108729:	89 1c 24             	mov    %ebx,(%esp)
c010872c:	8b 45 08             	mov    0x8(%ebp),%eax
c010872f:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0108731:	8b 45 10             	mov    0x10(%ebp),%eax
c0108734:	8d 50 01             	lea    0x1(%eax),%edx
c0108737:	89 55 10             	mov    %edx,0x10(%ebp)
c010873a:	0f b6 00             	movzbl (%eax),%eax
c010873d:	0f b6 d8             	movzbl %al,%ebx
c0108740:	83 fb 25             	cmp    $0x25,%ebx
c0108743:	75 d4                	jne    c0108719 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
c0108745:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c0108749:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c0108750:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108753:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c0108756:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010875d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108760:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c0108763:	8b 45 10             	mov    0x10(%ebp),%eax
c0108766:	8d 50 01             	lea    0x1(%eax),%edx
c0108769:	89 55 10             	mov    %edx,0x10(%ebp)
c010876c:	0f b6 00             	movzbl (%eax),%eax
c010876f:	0f b6 d8             	movzbl %al,%ebx
c0108772:	8d 43 dd             	lea    -0x23(%ebx),%eax
c0108775:	83 f8 55             	cmp    $0x55,%eax
c0108778:	0f 87 44 03 00 00    	ja     c0108ac2 <vprintfmt+0x3b3>
c010877e:	8b 04 85 58 ab 10 c0 	mov    -0x3fef54a8(,%eax,4),%eax
c0108785:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c0108787:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c010878b:	eb d6                	jmp    c0108763 <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c010878d:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c0108791:	eb d0                	jmp    c0108763 <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0108793:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c010879a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010879d:	89 d0                	mov    %edx,%eax
c010879f:	c1 e0 02             	shl    $0x2,%eax
c01087a2:	01 d0                	add    %edx,%eax
c01087a4:	01 c0                	add    %eax,%eax
c01087a6:	01 d8                	add    %ebx,%eax
c01087a8:	83 e8 30             	sub    $0x30,%eax
c01087ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c01087ae:	8b 45 10             	mov    0x10(%ebp),%eax
c01087b1:	0f b6 00             	movzbl (%eax),%eax
c01087b4:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c01087b7:	83 fb 2f             	cmp    $0x2f,%ebx
c01087ba:	7e 0b                	jle    c01087c7 <vprintfmt+0xb8>
c01087bc:	83 fb 39             	cmp    $0x39,%ebx
c01087bf:	7f 06                	jg     c01087c7 <vprintfmt+0xb8>
            for (precision = 0; ; ++ fmt) {
c01087c1:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                    break;
                }
            }
c01087c5:	eb d3                	jmp    c010879a <vprintfmt+0x8b>
            goto process_precision;
c01087c7:	eb 33                	jmp    c01087fc <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
c01087c9:	8b 45 14             	mov    0x14(%ebp),%eax
c01087cc:	8d 50 04             	lea    0x4(%eax),%edx
c01087cf:	89 55 14             	mov    %edx,0x14(%ebp)
c01087d2:	8b 00                	mov    (%eax),%eax
c01087d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c01087d7:	eb 23                	jmp    c01087fc <vprintfmt+0xed>

        case '.':
            if (width < 0)
c01087d9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01087dd:	79 0c                	jns    c01087eb <vprintfmt+0xdc>
                width = 0;
c01087df:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c01087e6:	e9 78 ff ff ff       	jmp    c0108763 <vprintfmt+0x54>
c01087eb:	e9 73 ff ff ff       	jmp    c0108763 <vprintfmt+0x54>

        case '#':
            altflag = 1;
c01087f0:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c01087f7:	e9 67 ff ff ff       	jmp    c0108763 <vprintfmt+0x54>

        process_precision:
            if (width < 0)
c01087fc:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108800:	79 12                	jns    c0108814 <vprintfmt+0x105>
                width = precision, precision = -1;
c0108802:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108805:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108808:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c010880f:	e9 4f ff ff ff       	jmp    c0108763 <vprintfmt+0x54>
c0108814:	e9 4a ff ff ff       	jmp    c0108763 <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c0108819:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
c010881d:	e9 41 ff ff ff       	jmp    c0108763 <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c0108822:	8b 45 14             	mov    0x14(%ebp),%eax
c0108825:	8d 50 04             	lea    0x4(%eax),%edx
c0108828:	89 55 14             	mov    %edx,0x14(%ebp)
c010882b:	8b 00                	mov    (%eax),%eax
c010882d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108830:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108834:	89 04 24             	mov    %eax,(%esp)
c0108837:	8b 45 08             	mov    0x8(%ebp),%eax
c010883a:	ff d0                	call   *%eax
            break;
c010883c:	e9 ac 02 00 00       	jmp    c0108aed <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
c0108841:	8b 45 14             	mov    0x14(%ebp),%eax
c0108844:	8d 50 04             	lea    0x4(%eax),%edx
c0108847:	89 55 14             	mov    %edx,0x14(%ebp)
c010884a:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c010884c:	85 db                	test   %ebx,%ebx
c010884e:	79 02                	jns    c0108852 <vprintfmt+0x143>
                err = -err;
c0108850:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c0108852:	83 fb 06             	cmp    $0x6,%ebx
c0108855:	7f 0b                	jg     c0108862 <vprintfmt+0x153>
c0108857:	8b 34 9d 18 ab 10 c0 	mov    -0x3fef54e8(,%ebx,4),%esi
c010885e:	85 f6                	test   %esi,%esi
c0108860:	75 23                	jne    c0108885 <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
c0108862:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0108866:	c7 44 24 08 45 ab 10 	movl   $0xc010ab45,0x8(%esp)
c010886d:	c0 
c010886e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108871:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108875:	8b 45 08             	mov    0x8(%ebp),%eax
c0108878:	89 04 24             	mov    %eax,(%esp)
c010887b:	e8 61 fe ff ff       	call   c01086e1 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c0108880:	e9 68 02 00 00       	jmp    c0108aed <vprintfmt+0x3de>
                printfmt(putch, putdat, "%s", p);
c0108885:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0108889:	c7 44 24 08 4e ab 10 	movl   $0xc010ab4e,0x8(%esp)
c0108890:	c0 
c0108891:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108894:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108898:	8b 45 08             	mov    0x8(%ebp),%eax
c010889b:	89 04 24             	mov    %eax,(%esp)
c010889e:	e8 3e fe ff ff       	call   c01086e1 <printfmt>
            break;
c01088a3:	e9 45 02 00 00       	jmp    c0108aed <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c01088a8:	8b 45 14             	mov    0x14(%ebp),%eax
c01088ab:	8d 50 04             	lea    0x4(%eax),%edx
c01088ae:	89 55 14             	mov    %edx,0x14(%ebp)
c01088b1:	8b 30                	mov    (%eax),%esi
c01088b3:	85 f6                	test   %esi,%esi
c01088b5:	75 05                	jne    c01088bc <vprintfmt+0x1ad>
                p = "(null)";
c01088b7:	be 51 ab 10 c0       	mov    $0xc010ab51,%esi
            }
            if (width > 0 && padc != '-') {
c01088bc:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01088c0:	7e 3e                	jle    c0108900 <vprintfmt+0x1f1>
c01088c2:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c01088c6:	74 38                	je     c0108900 <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
c01088c8:	8b 5d e8             	mov    -0x18(%ebp),%ebx
c01088cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01088ce:	89 44 24 04          	mov    %eax,0x4(%esp)
c01088d2:	89 34 24             	mov    %esi,(%esp)
c01088d5:	e8 dc f7 ff ff       	call   c01080b6 <strnlen>
c01088da:	29 c3                	sub    %eax,%ebx
c01088dc:	89 d8                	mov    %ebx,%eax
c01088de:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01088e1:	eb 17                	jmp    c01088fa <vprintfmt+0x1eb>
                    putch(padc, putdat);
c01088e3:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c01088e7:	8b 55 0c             	mov    0xc(%ebp),%edx
c01088ea:	89 54 24 04          	mov    %edx,0x4(%esp)
c01088ee:	89 04 24             	mov    %eax,(%esp)
c01088f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01088f4:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
c01088f6:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c01088fa:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01088fe:	7f e3                	jg     c01088e3 <vprintfmt+0x1d4>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0108900:	eb 38                	jmp    c010893a <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
c0108902:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0108906:	74 1f                	je     c0108927 <vprintfmt+0x218>
c0108908:	83 fb 1f             	cmp    $0x1f,%ebx
c010890b:	7e 05                	jle    c0108912 <vprintfmt+0x203>
c010890d:	83 fb 7e             	cmp    $0x7e,%ebx
c0108910:	7e 15                	jle    c0108927 <vprintfmt+0x218>
                    putch('?', putdat);
c0108912:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108915:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108919:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c0108920:	8b 45 08             	mov    0x8(%ebp),%eax
c0108923:	ff d0                	call   *%eax
c0108925:	eb 0f                	jmp    c0108936 <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
c0108927:	8b 45 0c             	mov    0xc(%ebp),%eax
c010892a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010892e:	89 1c 24             	mov    %ebx,(%esp)
c0108931:	8b 45 08             	mov    0x8(%ebp),%eax
c0108934:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0108936:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010893a:	89 f0                	mov    %esi,%eax
c010893c:	8d 70 01             	lea    0x1(%eax),%esi
c010893f:	0f b6 00             	movzbl (%eax),%eax
c0108942:	0f be d8             	movsbl %al,%ebx
c0108945:	85 db                	test   %ebx,%ebx
c0108947:	74 10                	je     c0108959 <vprintfmt+0x24a>
c0108949:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010894d:	78 b3                	js     c0108902 <vprintfmt+0x1f3>
c010894f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
c0108953:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0108957:	79 a9                	jns    c0108902 <vprintfmt+0x1f3>
                }
            }
            for (; width > 0; width --) {
c0108959:	eb 17                	jmp    c0108972 <vprintfmt+0x263>
                putch(' ', putdat);
c010895b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010895e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108962:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0108969:	8b 45 08             	mov    0x8(%ebp),%eax
c010896c:	ff d0                	call   *%eax
            for (; width > 0; width --) {
c010896e:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0108972:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108976:	7f e3                	jg     c010895b <vprintfmt+0x24c>
            }
            break;
c0108978:	e9 70 01 00 00       	jmp    c0108aed <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c010897d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108980:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108984:	8d 45 14             	lea    0x14(%ebp),%eax
c0108987:	89 04 24             	mov    %eax,(%esp)
c010898a:	e8 0b fd ff ff       	call   c010869a <getint>
c010898f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108992:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c0108995:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108998:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010899b:	85 d2                	test   %edx,%edx
c010899d:	79 26                	jns    c01089c5 <vprintfmt+0x2b6>
                putch('-', putdat);
c010899f:	8b 45 0c             	mov    0xc(%ebp),%eax
c01089a2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01089a6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c01089ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01089b0:	ff d0                	call   *%eax
                num = -(long long)num;
c01089b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01089b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01089b8:	f7 d8                	neg    %eax
c01089ba:	83 d2 00             	adc    $0x0,%edx
c01089bd:	f7 da                	neg    %edx
c01089bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01089c2:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c01089c5:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c01089cc:	e9 a8 00 00 00       	jmp    c0108a79 <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c01089d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01089d4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01089d8:	8d 45 14             	lea    0x14(%ebp),%eax
c01089db:	89 04 24             	mov    %eax,(%esp)
c01089de:	e8 68 fc ff ff       	call   c010864b <getuint>
c01089e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01089e6:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c01089e9:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c01089f0:	e9 84 00 00 00       	jmp    c0108a79 <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c01089f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01089f8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01089fc:	8d 45 14             	lea    0x14(%ebp),%eax
c01089ff:	89 04 24             	mov    %eax,(%esp)
c0108a02:	e8 44 fc ff ff       	call   c010864b <getuint>
c0108a07:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108a0a:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0108a0d:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0108a14:	eb 63                	jmp    c0108a79 <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
c0108a16:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108a19:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108a1d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0108a24:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a27:	ff d0                	call   *%eax
            putch('x', putdat);
c0108a29:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108a2c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108a30:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c0108a37:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a3a:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0108a3c:	8b 45 14             	mov    0x14(%ebp),%eax
c0108a3f:	8d 50 04             	lea    0x4(%eax),%edx
c0108a42:	89 55 14             	mov    %edx,0x14(%ebp)
c0108a45:	8b 00                	mov    (%eax),%eax
c0108a47:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108a4a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0108a51:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0108a58:	eb 1f                	jmp    c0108a79 <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0108a5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108a5d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108a61:	8d 45 14             	lea    0x14(%ebp),%eax
c0108a64:	89 04 24             	mov    %eax,(%esp)
c0108a67:	e8 df fb ff ff       	call   c010864b <getuint>
c0108a6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108a6f:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0108a72:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0108a79:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0108a7d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108a80:	89 54 24 18          	mov    %edx,0x18(%esp)
c0108a84:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0108a87:	89 54 24 14          	mov    %edx,0x14(%esp)
c0108a8b:	89 44 24 10          	mov    %eax,0x10(%esp)
c0108a8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108a92:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108a95:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108a99:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0108a9d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108aa0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108aa4:	8b 45 08             	mov    0x8(%ebp),%eax
c0108aa7:	89 04 24             	mov    %eax,(%esp)
c0108aaa:	e8 97 fa ff ff       	call   c0108546 <printnum>
            break;
c0108aaf:	eb 3c                	jmp    c0108aed <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0108ab1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108ab4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108ab8:	89 1c 24             	mov    %ebx,(%esp)
c0108abb:	8b 45 08             	mov    0x8(%ebp),%eax
c0108abe:	ff d0                	call   *%eax
            break;
c0108ac0:	eb 2b                	jmp    c0108aed <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0108ac2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108ac5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108ac9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c0108ad0:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ad3:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0108ad5:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0108ad9:	eb 04                	jmp    c0108adf <vprintfmt+0x3d0>
c0108adb:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0108adf:	8b 45 10             	mov    0x10(%ebp),%eax
c0108ae2:	83 e8 01             	sub    $0x1,%eax
c0108ae5:	0f b6 00             	movzbl (%eax),%eax
c0108ae8:	3c 25                	cmp    $0x25,%al
c0108aea:	75 ef                	jne    c0108adb <vprintfmt+0x3cc>
                /* do nothing */;
            break;
c0108aec:	90                   	nop
        }
    }
c0108aed:	90                   	nop
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0108aee:	e9 3e fc ff ff       	jmp    c0108731 <vprintfmt+0x22>
}
c0108af3:	83 c4 40             	add    $0x40,%esp
c0108af6:	5b                   	pop    %ebx
c0108af7:	5e                   	pop    %esi
c0108af8:	5d                   	pop    %ebp
c0108af9:	c3                   	ret    

c0108afa <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0108afa:	55                   	push   %ebp
c0108afb:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0108afd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108b00:	8b 40 08             	mov    0x8(%eax),%eax
c0108b03:	8d 50 01             	lea    0x1(%eax),%edx
c0108b06:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108b09:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0108b0c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108b0f:	8b 10                	mov    (%eax),%edx
c0108b11:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108b14:	8b 40 04             	mov    0x4(%eax),%eax
c0108b17:	39 c2                	cmp    %eax,%edx
c0108b19:	73 12                	jae    c0108b2d <sprintputch+0x33>
        *b->buf ++ = ch;
c0108b1b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108b1e:	8b 00                	mov    (%eax),%eax
c0108b20:	8d 48 01             	lea    0x1(%eax),%ecx
c0108b23:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108b26:	89 0a                	mov    %ecx,(%edx)
c0108b28:	8b 55 08             	mov    0x8(%ebp),%edx
c0108b2b:	88 10                	mov    %dl,(%eax)
    }
}
c0108b2d:	5d                   	pop    %ebp
c0108b2e:	c3                   	ret    

c0108b2f <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0108b2f:	55                   	push   %ebp
c0108b30:	89 e5                	mov    %esp,%ebp
c0108b32:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0108b35:	8d 45 14             	lea    0x14(%ebp),%eax
c0108b38:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0108b3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108b3e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108b42:	8b 45 10             	mov    0x10(%ebp),%eax
c0108b45:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108b49:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108b4c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108b50:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b53:	89 04 24             	mov    %eax,(%esp)
c0108b56:	e8 08 00 00 00       	call   c0108b63 <vsnprintf>
c0108b5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0108b5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108b61:	c9                   	leave  
c0108b62:	c3                   	ret    

c0108b63 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0108b63:	55                   	push   %ebp
c0108b64:	89 e5                	mov    %esp,%ebp
c0108b66:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0108b69:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b6c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108b6f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108b72:	8d 50 ff             	lea    -0x1(%eax),%edx
c0108b75:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b78:	01 d0                	add    %edx,%eax
c0108b7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108b7d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0108b84:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0108b88:	74 0a                	je     c0108b94 <vsnprintf+0x31>
c0108b8a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108b8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108b90:	39 c2                	cmp    %eax,%edx
c0108b92:	76 07                	jbe    c0108b9b <vsnprintf+0x38>
        return -E_INVAL;
c0108b94:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0108b99:	eb 2a                	jmp    c0108bc5 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c0108b9b:	8b 45 14             	mov    0x14(%ebp),%eax
c0108b9e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108ba2:	8b 45 10             	mov    0x10(%ebp),%eax
c0108ba5:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108ba9:	8d 45 ec             	lea    -0x14(%ebp),%eax
c0108bac:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108bb0:	c7 04 24 fa 8a 10 c0 	movl   $0xc0108afa,(%esp)
c0108bb7:	e8 53 fb ff ff       	call   c010870f <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c0108bbc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108bbf:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0108bc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108bc5:	c9                   	leave  
c0108bc6:	c3                   	ret    

c0108bc7 <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c0108bc7:	55                   	push   %ebp
c0108bc8:	89 e5                	mov    %esp,%ebp
c0108bca:	57                   	push   %edi
c0108bcb:	56                   	push   %esi
c0108bcc:	53                   	push   %ebx
c0108bcd:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c0108bd0:	a1 58 0a 12 c0       	mov    0xc0120a58,%eax
c0108bd5:	8b 15 5c 0a 12 c0    	mov    0xc0120a5c,%edx
c0108bdb:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c0108be1:	6b f0 05             	imul   $0x5,%eax,%esi
c0108be4:	01 f7                	add    %esi,%edi
c0108be6:	be 6d e6 ec de       	mov    $0xdeece66d,%esi
c0108beb:	f7 e6                	mul    %esi
c0108bed:	8d 34 17             	lea    (%edi,%edx,1),%esi
c0108bf0:	89 f2                	mov    %esi,%edx
c0108bf2:	83 c0 0b             	add    $0xb,%eax
c0108bf5:	83 d2 00             	adc    $0x0,%edx
c0108bf8:	89 c7                	mov    %eax,%edi
c0108bfa:	83 e7 ff             	and    $0xffffffff,%edi
c0108bfd:	89 f9                	mov    %edi,%ecx
c0108bff:	0f b7 da             	movzwl %dx,%ebx
c0108c02:	89 0d 58 0a 12 c0    	mov    %ecx,0xc0120a58
c0108c08:	89 1d 5c 0a 12 c0    	mov    %ebx,0xc0120a5c
    unsigned long long result = (next >> 12);
c0108c0e:	a1 58 0a 12 c0       	mov    0xc0120a58,%eax
c0108c13:	8b 15 5c 0a 12 c0    	mov    0xc0120a5c,%edx
c0108c19:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0108c1d:	c1 ea 0c             	shr    $0xc,%edx
c0108c20:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108c23:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c0108c26:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c0108c2d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108c30:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108c33:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0108c36:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0108c39:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108c3c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108c3f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108c43:	74 1c                	je     c0108c61 <rand+0x9a>
c0108c45:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108c48:	ba 00 00 00 00       	mov    $0x0,%edx
c0108c4d:	f7 75 dc             	divl   -0x24(%ebp)
c0108c50:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0108c53:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108c56:	ba 00 00 00 00       	mov    $0x0,%edx
c0108c5b:	f7 75 dc             	divl   -0x24(%ebp)
c0108c5e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108c61:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108c64:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108c67:	f7 75 dc             	divl   -0x24(%ebp)
c0108c6a:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0108c6d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0108c70:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108c73:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0108c76:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108c79:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0108c7c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c0108c7f:	83 c4 24             	add    $0x24,%esp
c0108c82:	5b                   	pop    %ebx
c0108c83:	5e                   	pop    %esi
c0108c84:	5f                   	pop    %edi
c0108c85:	5d                   	pop    %ebp
c0108c86:	c3                   	ret    

c0108c87 <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c0108c87:	55                   	push   %ebp
c0108c88:	89 e5                	mov    %esp,%ebp
    next = seed;
c0108c8a:	8b 45 08             	mov    0x8(%ebp),%eax
c0108c8d:	ba 00 00 00 00       	mov    $0x0,%edx
c0108c92:	a3 58 0a 12 c0       	mov    %eax,0xc0120a58
c0108c97:	89 15 5c 0a 12 c0    	mov    %edx,0xc0120a5c
}
c0108c9d:	5d                   	pop    %ebp
c0108c9e:	c3                   	ret    
