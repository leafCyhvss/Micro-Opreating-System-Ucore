
bin/kernel:     file format elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 c0 19 00       	mov    $0x19c000,%eax
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
c0100020:	a3 00 c0 19 c0       	mov    %eax,0xc019c000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 a0 12 c0       	mov    $0xc012a000,%esp
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
c010003c:	ba 64 11 1a c0       	mov    $0xc01a1164,%edx
c0100041:	b8 00 e0 19 c0       	mov    $0xc019e000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 e0 19 c0 	movl   $0xc019e000,(%esp)
c010005d:	e8 f0 b4 00 00       	call   c010b552 <memset>

    cons_init();                // init the console
c0100062:	e8 10 1f 00 00       	call   c0101f77 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 60 be 10 c0 	movl   $0xc010be60,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 7c be 10 c0 	movl   $0xc010be7c,(%esp)
c010007c:	e8 28 02 00 00       	call   c01002a9 <cprintf>

    print_kerninfo();
c0100081:	e8 d2 09 00 00       	call   c0100a58 <print_kerninfo>

    grade_backtrace();
c0100086:	e8 9d 00 00 00       	call   c0100128 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 41 7a 00 00       	call   c0107ad1 <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 3f 20 00 00       	call   c01020d4 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 c3 21 00 00       	call   c010225d <idt_init>

    vmm_init();                 // init virtual memory management
c010009a:	e8 c9 3c 00 00       	call   c0103d68 <vmm_init>
    proc_init();                // init process table
c010009f:	e8 26 ac 00 00       	call   c010acca <proc_init>
    
    ide_init();                 // init ide devices
c01000a4:	e8 69 0e 00 00       	call   c0100f12 <ide_init>
    swap_init();                // init swap
c01000a9:	e8 36 54 00 00       	call   c01054e4 <swap_init>

    clock_init();               // init clock interrupt
c01000ae:	e8 7a 16 00 00       	call   c010172d <clock_init>
    intr_enable();              // enable irq interrupt
c01000b3:	e8 57 21 00 00       	call   c010220f <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();
    
    cpu_idle();                 // run idle process
c01000b8:	e8 cc ad 00 00       	call   c010ae89 <cpu_idle>

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
c01000da:	e8 c7 0d 00 00       	call   c0100ea6 <mon_backtrace>
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
c010016b:	a1 00 e0 19 c0       	mov    0xc019e000,%eax
c0100170:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100174:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100178:	c7 04 24 81 be 10 c0 	movl   $0xc010be81,(%esp)
c010017f:	e8 25 01 00 00       	call   c01002a9 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c0100184:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100188:	0f b7 d0             	movzwl %ax,%edx
c010018b:	a1 00 e0 19 c0       	mov    0xc019e000,%eax
c0100190:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100194:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100198:	c7 04 24 8f be 10 c0 	movl   $0xc010be8f,(%esp)
c010019f:	e8 05 01 00 00       	call   c01002a9 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c01001a4:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c01001a8:	0f b7 d0             	movzwl %ax,%edx
c01001ab:	a1 00 e0 19 c0       	mov    0xc019e000,%eax
c01001b0:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001b4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001b8:	c7 04 24 9d be 10 c0 	movl   $0xc010be9d,(%esp)
c01001bf:	e8 e5 00 00 00       	call   c01002a9 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001c4:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001c8:	0f b7 d0             	movzwl %ax,%edx
c01001cb:	a1 00 e0 19 c0       	mov    0xc019e000,%eax
c01001d0:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001d4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001d8:	c7 04 24 ab be 10 c0 	movl   $0xc010beab,(%esp)
c01001df:	e8 c5 00 00 00       	call   c01002a9 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001e4:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001e8:	0f b7 d0             	movzwl %ax,%edx
c01001eb:	a1 00 e0 19 c0       	mov    0xc019e000,%eax
c01001f0:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001f4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001f8:	c7 04 24 b9 be 10 c0 	movl   $0xc010beb9,(%esp)
c01001ff:	e8 a5 00 00 00       	call   c01002a9 <cprintf>
    round ++;
c0100204:	a1 00 e0 19 c0       	mov    0xc019e000,%eax
c0100209:	83 c0 01             	add    $0x1,%eax
c010020c:	a3 00 e0 19 c0       	mov    %eax,0xc019e000
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
c0100228:	c7 04 24 c8 be 10 c0 	movl   $0xc010bec8,(%esp)
c010022f:	e8 75 00 00 00       	call   c01002a9 <cprintf>
    lab1_switch_to_user();
c0100234:	e8 da ff ff ff       	call   c0100213 <lab1_switch_to_user>
    lab1_print_cur_status();
c0100239:	e8 0f ff ff ff       	call   c010014d <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c010023e:	c7 04 24 e8 be 10 c0 	movl   $0xc010bee8,(%esp)
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
c0100262:	e8 3c 1d 00 00       	call   c0101fa3 <cons_putc>
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
c010029f:	e8 00 b6 00 00       	call   c010b8a4 <vprintfmt>
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
c01002db:	e8 c3 1c 00 00       	call   c0101fa3 <cons_putc>
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
c0100337:	e8 a3 1c 00 00       	call   c0101fdf <cons_getc>
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
c010035d:	c7 04 24 07 bf 10 c0 	movl   $0xc010bf07,(%esp)
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
c01003ab:	88 90 20 e0 19 c0    	mov    %dl,-0x3fe61fe0(%eax)
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
c01003ea:	05 20 e0 19 c0       	add    $0xc019e020,%eax
c01003ef:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01003f2:	b8 20 e0 19 c0       	mov    $0xc019e020,%eax
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
c0100406:	a1 20 e4 19 c0       	mov    0xc019e420,%eax
c010040b:	85 c0                	test   %eax,%eax
c010040d:	74 02                	je     c0100411 <__panic+0x11>
        goto panic_dead;
c010040f:	eb 59                	jmp    c010046a <__panic+0x6a>
    }
    is_panic = 1;
c0100411:	c7 05 20 e4 19 c0 01 	movl   $0x1,0xc019e420
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
c010042f:	c7 04 24 0a bf 10 c0 	movl   $0xc010bf0a,(%esp)
c0100436:	e8 6e fe ff ff       	call   c01002a9 <cprintf>
    vcprintf(fmt, ap);
c010043b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010043e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100442:	8b 45 10             	mov    0x10(%ebp),%eax
c0100445:	89 04 24             	mov    %eax,(%esp)
c0100448:	e8 29 fe ff ff       	call   c0100276 <vcprintf>
    cprintf("\n");
c010044d:	c7 04 24 26 bf 10 c0 	movl   $0xc010bf26,(%esp)
c0100454:	e8 50 fe ff ff       	call   c01002a9 <cprintf>
    
    cprintf("stack trackback:\n");
c0100459:	c7 04 24 28 bf 10 c0 	movl   $0xc010bf28,(%esp)
c0100460:	e8 44 fe ff ff       	call   c01002a9 <cprintf>
    print_stackframe();
c0100465:	e8 38 07 00 00       	call   c0100ba2 <print_stackframe>
    
    va_end(ap);

panic_dead:
    intr_disable();
c010046a:	e8 a6 1d 00 00       	call   c0102215 <intr_disable>
    while (1) {
        kmonitor(NULL);
c010046f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100476:	e8 5c 09 00 00       	call   c0100dd7 <kmonitor>
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
c0100497:	c7 04 24 3a bf 10 c0 	movl   $0xc010bf3a,(%esp)
c010049e:	e8 06 fe ff ff       	call   c01002a9 <cprintf>
    vcprintf(fmt, ap);
c01004a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01004a6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01004aa:	8b 45 10             	mov    0x10(%ebp),%eax
c01004ad:	89 04 24             	mov    %eax,(%esp)
c01004b0:	e8 c1 fd ff ff       	call   c0100276 <vcprintf>
    cprintf("\n");
c01004b5:	c7 04 24 26 bf 10 c0 	movl   $0xc010bf26,(%esp)
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
c01004c6:	a1 20 e4 19 c0       	mov    0xc019e420,%eax
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
c010062c:	c7 00 58 bf 10 c0    	movl   $0xc010bf58,(%eax)
    info->eip_line = 0;
c0100632:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100635:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c010063c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010063f:	c7 40 08 58 bf 10 c0 	movl   $0xc010bf58,0x8(%eax)
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

    // find the relevant set of stabs
    if (addr >= KERNBASE) {
c0100663:	81 7d 08 ff ff ff bf 	cmpl   $0xbfffffff,0x8(%ebp)
c010066a:	76 21                	jbe    c010068d <debuginfo_eip+0x6a>
        stabs = __STAB_BEGIN__;
c010066c:	c7 45 f4 a0 e6 10 c0 	movl   $0xc010e6a0,-0xc(%ebp)
        stab_end = __STAB_END__;
c0100673:	c7 45 f0 74 29 12 c0 	movl   $0xc0122974,-0x10(%ebp)
        stabstr = __STABSTR_BEGIN__;
c010067a:	c7 45 ec 75 29 12 c0 	movl   $0xc0122975,-0x14(%ebp)
        stabstr_end = __STABSTR_END__;
c0100681:	c7 45 e8 56 76 12 c0 	movl   $0xc0127656,-0x18(%ebp)
c0100688:	e9 ea 00 00 00       	jmp    c0100777 <debuginfo_eip+0x154>
    }
    else {
        // user-program linker script, tools/user.ld puts the information about the
        // program's stabs (included __STAB_BEGIN__, __STAB_END__, __STABSTR_BEGIN__,
        // and __STABSTR_END__) in a structure located at virtual address USTAB.
        const struct userstabdata *usd = (struct userstabdata *)USTAB;
c010068d:	c7 45 e4 00 00 20 00 	movl   $0x200000,-0x1c(%ebp)

        // make sure that debugger (current process) can access this memory
        struct mm_struct *mm;
        if (current == NULL || (mm = current->mm) == NULL) {
c0100694:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c0100699:	85 c0                	test   %eax,%eax
c010069b:	74 11                	je     c01006ae <debuginfo_eip+0x8b>
c010069d:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c01006a2:	8b 40 18             	mov    0x18(%eax),%eax
c01006a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01006a8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01006ac:	75 0a                	jne    c01006b8 <debuginfo_eip+0x95>
            return -1;
c01006ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006b3:	e9 9e 03 00 00       	jmp    c0100a56 <debuginfo_eip+0x433>
        }
        if (!user_mem_check(mm, (uintptr_t)usd, sizeof(struct userstabdata), 0)) {
c01006b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006bb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01006c2:	00 
c01006c3:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c01006ca:	00 
c01006cb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01006cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006d2:	89 04 24             	mov    %eax,(%esp)
c01006d5:	e8 b7 3f 00 00       	call   c0104691 <user_mem_check>
c01006da:	85 c0                	test   %eax,%eax
c01006dc:	75 0a                	jne    c01006e8 <debuginfo_eip+0xc5>
            return -1;
c01006de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006e3:	e9 6e 03 00 00       	jmp    c0100a56 <debuginfo_eip+0x433>
        }

        stabs = usd->stabs;
c01006e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006eb:	8b 00                	mov    (%eax),%eax
c01006ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
        stab_end = usd->stab_end;
c01006f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006f3:	8b 40 04             	mov    0x4(%eax),%eax
c01006f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
        stabstr = usd->stabstr;
c01006f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006fc:	8b 40 08             	mov    0x8(%eax),%eax
c01006ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
        stabstr_end = usd->stabstr_end;
c0100702:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100705:	8b 40 0c             	mov    0xc(%eax),%eax
c0100708:	89 45 e8             	mov    %eax,-0x18(%ebp)

        // make sure the STABS and string table memory is valid
        if (!user_mem_check(mm, (uintptr_t)stabs, (uintptr_t)stab_end - (uintptr_t)stabs, 0)) {
c010070b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010070e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100711:	29 c2                	sub    %eax,%edx
c0100713:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100716:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010071d:	00 
c010071e:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100722:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100726:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100729:	89 04 24             	mov    %eax,(%esp)
c010072c:	e8 60 3f 00 00       	call   c0104691 <user_mem_check>
c0100731:	85 c0                	test   %eax,%eax
c0100733:	75 0a                	jne    c010073f <debuginfo_eip+0x11c>
            return -1;
c0100735:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010073a:	e9 17 03 00 00       	jmp    c0100a56 <debuginfo_eip+0x433>
        }
        if (!user_mem_check(mm, (uintptr_t)stabstr, stabstr_end - stabstr, 0)) {
c010073f:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0100742:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100745:	29 c2                	sub    %eax,%edx
c0100747:	89 d0                	mov    %edx,%eax
c0100749:	89 c2                	mov    %eax,%edx
c010074b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010074e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0100755:	00 
c0100756:	89 54 24 08          	mov    %edx,0x8(%esp)
c010075a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010075e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100761:	89 04 24             	mov    %eax,(%esp)
c0100764:	e8 28 3f 00 00       	call   c0104691 <user_mem_check>
c0100769:	85 c0                	test   %eax,%eax
c010076b:	75 0a                	jne    c0100777 <debuginfo_eip+0x154>
            return -1;
c010076d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100772:	e9 df 02 00 00       	jmp    c0100a56 <debuginfo_eip+0x433>
        }
    }

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c0100777:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010077a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010077d:	76 0d                	jbe    c010078c <debuginfo_eip+0x169>
c010077f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100782:	83 e8 01             	sub    $0x1,%eax
c0100785:	0f b6 00             	movzbl (%eax),%eax
c0100788:	84 c0                	test   %al,%al
c010078a:	74 0a                	je     c0100796 <debuginfo_eip+0x173>
        return -1;
c010078c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100791:	e9 c0 02 00 00       	jmp    c0100a56 <debuginfo_eip+0x433>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c0100796:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010079d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01007a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007a3:	29 c2                	sub    %eax,%edx
c01007a5:	89 d0                	mov    %edx,%eax
c01007a7:	c1 f8 02             	sar    $0x2,%eax
c01007aa:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01007b0:	83 e8 01             	sub    $0x1,%eax
c01007b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01007b6:	8b 45 08             	mov    0x8(%ebp),%eax
c01007b9:	89 44 24 10          	mov    %eax,0x10(%esp)
c01007bd:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01007c4:	00 
c01007c5:	8d 45 d8             	lea    -0x28(%ebp),%eax
c01007c8:	89 44 24 08          	mov    %eax,0x8(%esp)
c01007cc:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01007cf:	89 44 24 04          	mov    %eax,0x4(%esp)
c01007d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007d6:	89 04 24             	mov    %eax,(%esp)
c01007d9:	e8 ef fc ff ff       	call   c01004cd <stab_binsearch>
    if (lfile == 0)
c01007de:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01007e1:	85 c0                	test   %eax,%eax
c01007e3:	75 0a                	jne    c01007ef <debuginfo_eip+0x1cc>
        return -1;
c01007e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01007ea:	e9 67 02 00 00       	jmp    c0100a56 <debuginfo_eip+0x433>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c01007ef:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01007f2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c01007f5:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01007f8:	89 45 d0             	mov    %eax,-0x30(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c01007fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01007fe:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100802:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c0100809:	00 
c010080a:	8d 45 d0             	lea    -0x30(%ebp),%eax
c010080d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100811:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c0100814:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100818:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010081b:	89 04 24             	mov    %eax,(%esp)
c010081e:	e8 aa fc ff ff       	call   c01004cd <stab_binsearch>

    if (lfun <= rfun) {
c0100823:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100826:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100829:	39 c2                	cmp    %eax,%edx
c010082b:	7f 7c                	jg     c01008a9 <debuginfo_eip+0x286>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c010082d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100830:	89 c2                	mov    %eax,%edx
c0100832:	89 d0                	mov    %edx,%eax
c0100834:	01 c0                	add    %eax,%eax
c0100836:	01 d0                	add    %edx,%eax
c0100838:	c1 e0 02             	shl    $0x2,%eax
c010083b:	89 c2                	mov    %eax,%edx
c010083d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100840:	01 d0                	add    %edx,%eax
c0100842:	8b 10                	mov    (%eax),%edx
c0100844:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0100847:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010084a:	29 c1                	sub    %eax,%ecx
c010084c:	89 c8                	mov    %ecx,%eax
c010084e:	39 c2                	cmp    %eax,%edx
c0100850:	73 22                	jae    c0100874 <debuginfo_eip+0x251>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0100852:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100855:	89 c2                	mov    %eax,%edx
c0100857:	89 d0                	mov    %edx,%eax
c0100859:	01 c0                	add    %eax,%eax
c010085b:	01 d0                	add    %edx,%eax
c010085d:	c1 e0 02             	shl    $0x2,%eax
c0100860:	89 c2                	mov    %eax,%edx
c0100862:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100865:	01 d0                	add    %edx,%eax
c0100867:	8b 10                	mov    (%eax),%edx
c0100869:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010086c:	01 c2                	add    %eax,%edx
c010086e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100871:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c0100874:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100877:	89 c2                	mov    %eax,%edx
c0100879:	89 d0                	mov    %edx,%eax
c010087b:	01 c0                	add    %eax,%eax
c010087d:	01 d0                	add    %edx,%eax
c010087f:	c1 e0 02             	shl    $0x2,%eax
c0100882:	89 c2                	mov    %eax,%edx
c0100884:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100887:	01 d0                	add    %edx,%eax
c0100889:	8b 50 08             	mov    0x8(%eax),%edx
c010088c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010088f:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c0100892:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100895:	8b 40 10             	mov    0x10(%eax),%eax
c0100898:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c010089b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010089e:	89 45 cc             	mov    %eax,-0x34(%ebp)
        rline = rfun;
c01008a1:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01008a4:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01008a7:	eb 15                	jmp    c01008be <debuginfo_eip+0x29b>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01008a9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008ac:	8b 55 08             	mov    0x8(%ebp),%edx
c01008af:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01008b2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01008b5:	89 45 cc             	mov    %eax,-0x34(%ebp)
        rline = rfile;
c01008b8:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01008bb:	89 45 c8             	mov    %eax,-0x38(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01008be:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008c1:	8b 40 08             	mov    0x8(%eax),%eax
c01008c4:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01008cb:	00 
c01008cc:	89 04 24             	mov    %eax,(%esp)
c01008cf:	e8 f2 aa 00 00       	call   c010b3c6 <strfind>
c01008d4:	89 c2                	mov    %eax,%edx
c01008d6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008d9:	8b 40 08             	mov    0x8(%eax),%eax
c01008dc:	29 c2                	sub    %eax,%edx
c01008de:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008e1:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c01008e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01008e7:	89 44 24 10          	mov    %eax,0x10(%esp)
c01008eb:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c01008f2:	00 
c01008f3:	8d 45 c8             	lea    -0x38(%ebp),%eax
c01008f6:	89 44 24 08          	mov    %eax,0x8(%esp)
c01008fa:	8d 45 cc             	lea    -0x34(%ebp),%eax
c01008fd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100901:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100904:	89 04 24             	mov    %eax,(%esp)
c0100907:	e8 c1 fb ff ff       	call   c01004cd <stab_binsearch>
    if (lline <= rline) {
c010090c:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010090f:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0100912:	39 c2                	cmp    %eax,%edx
c0100914:	7f 24                	jg     c010093a <debuginfo_eip+0x317>
        info->eip_line = stabs[rline].n_desc;
c0100916:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0100919:	89 c2                	mov    %eax,%edx
c010091b:	89 d0                	mov    %edx,%eax
c010091d:	01 c0                	add    %eax,%eax
c010091f:	01 d0                	add    %edx,%eax
c0100921:	c1 e0 02             	shl    $0x2,%eax
c0100924:	89 c2                	mov    %eax,%edx
c0100926:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100929:	01 d0                	add    %edx,%eax
c010092b:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c010092f:	0f b7 d0             	movzwl %ax,%edx
c0100932:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100935:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100938:	eb 13                	jmp    c010094d <debuginfo_eip+0x32a>
        return -1;
c010093a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010093f:	e9 12 01 00 00       	jmp    c0100a56 <debuginfo_eip+0x433>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c0100944:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0100947:	83 e8 01             	sub    $0x1,%eax
c010094a:	89 45 cc             	mov    %eax,-0x34(%ebp)
    while (lline >= lfile
c010094d:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0100950:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100953:	39 c2                	cmp    %eax,%edx
c0100955:	7c 56                	jl     c01009ad <debuginfo_eip+0x38a>
           && stabs[lline].n_type != N_SOL
c0100957:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010095a:	89 c2                	mov    %eax,%edx
c010095c:	89 d0                	mov    %edx,%eax
c010095e:	01 c0                	add    %eax,%eax
c0100960:	01 d0                	add    %edx,%eax
c0100962:	c1 e0 02             	shl    $0x2,%eax
c0100965:	89 c2                	mov    %eax,%edx
c0100967:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010096a:	01 d0                	add    %edx,%eax
c010096c:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100970:	3c 84                	cmp    $0x84,%al
c0100972:	74 39                	je     c01009ad <debuginfo_eip+0x38a>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c0100974:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0100977:	89 c2                	mov    %eax,%edx
c0100979:	89 d0                	mov    %edx,%eax
c010097b:	01 c0                	add    %eax,%eax
c010097d:	01 d0                	add    %edx,%eax
c010097f:	c1 e0 02             	shl    $0x2,%eax
c0100982:	89 c2                	mov    %eax,%edx
c0100984:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100987:	01 d0                	add    %edx,%eax
c0100989:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010098d:	3c 64                	cmp    $0x64,%al
c010098f:	75 b3                	jne    c0100944 <debuginfo_eip+0x321>
c0100991:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0100994:	89 c2                	mov    %eax,%edx
c0100996:	89 d0                	mov    %edx,%eax
c0100998:	01 c0                	add    %eax,%eax
c010099a:	01 d0                	add    %edx,%eax
c010099c:	c1 e0 02             	shl    $0x2,%eax
c010099f:	89 c2                	mov    %eax,%edx
c01009a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009a4:	01 d0                	add    %edx,%eax
c01009a6:	8b 40 08             	mov    0x8(%eax),%eax
c01009a9:	85 c0                	test   %eax,%eax
c01009ab:	74 97                	je     c0100944 <debuginfo_eip+0x321>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01009ad:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01009b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01009b3:	39 c2                	cmp    %eax,%edx
c01009b5:	7c 46                	jl     c01009fd <debuginfo_eip+0x3da>
c01009b7:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01009ba:	89 c2                	mov    %eax,%edx
c01009bc:	89 d0                	mov    %edx,%eax
c01009be:	01 c0                	add    %eax,%eax
c01009c0:	01 d0                	add    %edx,%eax
c01009c2:	c1 e0 02             	shl    $0x2,%eax
c01009c5:	89 c2                	mov    %eax,%edx
c01009c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009ca:	01 d0                	add    %edx,%eax
c01009cc:	8b 10                	mov    (%eax),%edx
c01009ce:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c01009d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01009d4:	29 c1                	sub    %eax,%ecx
c01009d6:	89 c8                	mov    %ecx,%eax
c01009d8:	39 c2                	cmp    %eax,%edx
c01009da:	73 21                	jae    c01009fd <debuginfo_eip+0x3da>
        info->eip_file = stabstr + stabs[lline].n_strx;
c01009dc:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01009df:	89 c2                	mov    %eax,%edx
c01009e1:	89 d0                	mov    %edx,%eax
c01009e3:	01 c0                	add    %eax,%eax
c01009e5:	01 d0                	add    %edx,%eax
c01009e7:	c1 e0 02             	shl    $0x2,%eax
c01009ea:	89 c2                	mov    %eax,%edx
c01009ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009ef:	01 d0                	add    %edx,%eax
c01009f1:	8b 10                	mov    (%eax),%edx
c01009f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01009f6:	01 c2                	add    %eax,%edx
c01009f8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01009fb:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c01009fd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100a00:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100a03:	39 c2                	cmp    %eax,%edx
c0100a05:	7d 4a                	jge    c0100a51 <debuginfo_eip+0x42e>
        for (lline = lfun + 1;
c0100a07:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100a0a:	83 c0 01             	add    $0x1,%eax
c0100a0d:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0100a10:	eb 18                	jmp    c0100a2a <debuginfo_eip+0x407>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0100a12:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100a15:	8b 40 14             	mov    0x14(%eax),%eax
c0100a18:	8d 50 01             	lea    0x1(%eax),%edx
c0100a1b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100a1e:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
c0100a21:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0100a24:	83 c0 01             	add    $0x1,%eax
c0100a27:	89 45 cc             	mov    %eax,-0x34(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100a2a:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0100a2d:	8b 45 d0             	mov    -0x30(%ebp),%eax
        for (lline = lfun + 1;
c0100a30:	39 c2                	cmp    %eax,%edx
c0100a32:	7d 1d                	jge    c0100a51 <debuginfo_eip+0x42e>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100a34:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0100a37:	89 c2                	mov    %eax,%edx
c0100a39:	89 d0                	mov    %edx,%eax
c0100a3b:	01 c0                	add    %eax,%eax
c0100a3d:	01 d0                	add    %edx,%eax
c0100a3f:	c1 e0 02             	shl    $0x2,%eax
c0100a42:	89 c2                	mov    %eax,%edx
c0100a44:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a47:	01 d0                	add    %edx,%eax
c0100a49:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100a4d:	3c a0                	cmp    $0xa0,%al
c0100a4f:	74 c1                	je     c0100a12 <debuginfo_eip+0x3ef>
        }
    }
    return 0;
c0100a51:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100a56:	c9                   	leave  
c0100a57:	c3                   	ret    

c0100a58 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0100a58:	55                   	push   %ebp
c0100a59:	89 e5                	mov    %esp,%ebp
c0100a5b:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0100a5e:	c7 04 24 62 bf 10 c0 	movl   $0xc010bf62,(%esp)
c0100a65:	e8 3f f8 ff ff       	call   c01002a9 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c0100a6a:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c0100a71:	c0 
c0100a72:	c7 04 24 7b bf 10 c0 	movl   $0xc010bf7b,(%esp)
c0100a79:	e8 2b f8 ff ff       	call   c01002a9 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c0100a7e:	c7 44 24 04 59 be 10 	movl   $0xc010be59,0x4(%esp)
c0100a85:	c0 
c0100a86:	c7 04 24 93 bf 10 c0 	movl   $0xc010bf93,(%esp)
c0100a8d:	e8 17 f8 ff ff       	call   c01002a9 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c0100a92:	c7 44 24 04 00 e0 19 	movl   $0xc019e000,0x4(%esp)
c0100a99:	c0 
c0100a9a:	c7 04 24 ab bf 10 c0 	movl   $0xc010bfab,(%esp)
c0100aa1:	e8 03 f8 ff ff       	call   c01002a9 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c0100aa6:	c7 44 24 04 64 11 1a 	movl   $0xc01a1164,0x4(%esp)
c0100aad:	c0 
c0100aae:	c7 04 24 c3 bf 10 c0 	movl   $0xc010bfc3,(%esp)
c0100ab5:	e8 ef f7 ff ff       	call   c01002a9 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c0100aba:	b8 64 11 1a c0       	mov    $0xc01a1164,%eax
c0100abf:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c0100ac5:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c0100aca:	29 c2                	sub    %eax,%edx
c0100acc:	89 d0                	mov    %edx,%eax
c0100ace:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c0100ad4:	85 c0                	test   %eax,%eax
c0100ad6:	0f 48 c2             	cmovs  %edx,%eax
c0100ad9:	c1 f8 0a             	sar    $0xa,%eax
c0100adc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ae0:	c7 04 24 dc bf 10 c0 	movl   $0xc010bfdc,(%esp)
c0100ae7:	e8 bd f7 ff ff       	call   c01002a9 <cprintf>
}
c0100aec:	c9                   	leave  
c0100aed:	c3                   	ret    

c0100aee <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c0100aee:	55                   	push   %ebp
c0100aef:	89 e5                	mov    %esp,%ebp
c0100af1:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c0100af7:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100afa:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100afe:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b01:	89 04 24             	mov    %eax,(%esp)
c0100b04:	e8 1a fb ff ff       	call   c0100623 <debuginfo_eip>
c0100b09:	85 c0                	test   %eax,%eax
c0100b0b:	74 15                	je     c0100b22 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c0100b0d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b10:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b14:	c7 04 24 06 c0 10 c0 	movl   $0xc010c006,(%esp)
c0100b1b:	e8 89 f7 ff ff       	call   c01002a9 <cprintf>
c0100b20:	eb 6d                	jmp    c0100b8f <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100b22:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100b29:	eb 1c                	jmp    c0100b47 <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
c0100b2b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100b2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b31:	01 d0                	add    %edx,%eax
c0100b33:	0f b6 00             	movzbl (%eax),%eax
c0100b36:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100b3c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100b3f:	01 ca                	add    %ecx,%edx
c0100b41:	88 02                	mov    %al,(%edx)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100b43:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100b47:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100b4a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100b4d:	7f dc                	jg     c0100b2b <print_debuginfo+0x3d>
        }
        fnname[j] = '\0';
c0100b4f:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100b55:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b58:	01 d0                	add    %edx,%eax
c0100b5a:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c0100b5d:	8b 45 ec             	mov    -0x14(%ebp),%eax
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100b60:	8b 55 08             	mov    0x8(%ebp),%edx
c0100b63:	89 d1                	mov    %edx,%ecx
c0100b65:	29 c1                	sub    %eax,%ecx
c0100b67:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100b6a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100b6d:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100b71:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100b77:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100b7b:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100b7f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b83:	c7 04 24 22 c0 10 c0 	movl   $0xc010c022,(%esp)
c0100b8a:	e8 1a f7 ff ff       	call   c01002a9 <cprintf>
    }
}
c0100b8f:	c9                   	leave  
c0100b90:	c3                   	ret    

c0100b91 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0100b91:	55                   	push   %ebp
c0100b92:	89 e5                	mov    %esp,%ebp
c0100b94:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0100b97:	8b 45 04             	mov    0x4(%ebp),%eax
c0100b9a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0100b9d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100ba0:	c9                   	leave  
c0100ba1:	c3                   	ret    

c0100ba2 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0100ba2:	55                   	push   %ebp
c0100ba3:	89 e5                	mov    %esp,%ebp
c0100ba5:	53                   	push   %ebx
c0100ba6:	83 ec 44             	sub    $0x44,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0100ba9:	89 e8                	mov    %ebp,%eax
c0100bab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return ebp;
c0100bae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp=read_ebp(),eip=read_eip();
c0100bb1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100bb4:	e8 d8 ff ff ff       	call   c0100b91 <read_eip>
c0100bb9:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int i;//这里在for循环里定义好像不行的样子就拿出来了
	for(i=0;ebp!=0&&i<STACKFRAME_DEPTH;i++)
c0100bbc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100bc3:	e9 8d 00 00 00       	jmp    c0100c55 <print_stackframe+0xb3>
    {   
		cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c0100bc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100bcb:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100bcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bd2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bd6:	c7 04 24 34 c0 10 c0 	movl   $0xc010c034,(%esp)
c0100bdd:	e8 c7 f6 ff ff       	call   c01002a9 <cprintf>
		uint32_t *args = (uint32_t *)ebp + 2;       //ebp+8指向参数，+4指向返回值
c0100be2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100be5:	83 c0 08             	add    $0x8,%eax
c0100be8:	89 45 e8             	mov    %eax,-0x18(%ebp)
		cprintf("arg :0x%08x 0x%08x 0x%08x 0x%08x\n",*(args+0),*(args+1),*(args+2),*(args+3));
c0100beb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100bee:	83 c0 0c             	add    $0xc,%eax
c0100bf1:	8b 18                	mov    (%eax),%ebx
c0100bf3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100bf6:	83 c0 08             	add    $0x8,%eax
c0100bf9:	8b 08                	mov    (%eax),%ecx
c0100bfb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100bfe:	83 c0 04             	add    $0x4,%eax
c0100c01:	8b 10                	mov    (%eax),%edx
c0100c03:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100c06:	8b 00                	mov    (%eax),%eax
c0100c08:	89 5c 24 10          	mov    %ebx,0x10(%esp)
c0100c0c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100c10:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100c14:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c18:	c7 04 24 50 c0 10 c0 	movl   $0xc010c050,(%esp)
c0100c1f:	e8 85 f6 ff ff       	call   c01002a9 <cprintf>
        //依次打印调用函数的参数1 2 3 4
		cprintf("\n");
c0100c24:	c7 04 24 72 c0 10 c0 	movl   $0xc010c072,(%esp)
c0100c2b:	e8 79 f6 ff ff       	call   c01002a9 <cprintf>
		print_debuginfo(eip - 1);//eip指向的是下一条指令，所以这里减1  指针占4
c0100c30:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100c33:	83 e8 01             	sub    $0x1,%eax
c0100c36:	89 04 24             	mov    %eax,(%esp)
c0100c39:	e8 b0 fe ff ff       	call   c0100aee <print_debuginfo>
		eip = ((uint32_t *)ebp)[1]; //此时eip指向返回地址
c0100c3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c41:	83 c0 04             	add    $0x4,%eax
c0100c44:	8b 00                	mov    (%eax),%eax
c0100c46:	89 45 f0             	mov    %eax,-0x10(%ebp)
		ebp = ((uint32_t *)ebp)[0];//ebp存的是调用者edp，所以这里就复原了调用前edp值
c0100c49:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c4c:	8b 00                	mov    (%eax),%eax
c0100c4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for(i=0;ebp!=0&&i<STACKFRAME_DEPTH;i++)
c0100c51:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0100c55:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100c59:	74 0a                	je     c0100c65 <print_stackframe+0xc3>
c0100c5b:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100c5f:	0f 8e 63 ff ff ff    	jle    c0100bc8 <print_stackframe+0x26>
	}
}
c0100c65:	83 c4 44             	add    $0x44,%esp
c0100c68:	5b                   	pop    %ebx
c0100c69:	5d                   	pop    %ebp
c0100c6a:	c3                   	ret    

c0100c6b <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100c6b:	55                   	push   %ebp
c0100c6c:	89 e5                	mov    %esp,%ebp
c0100c6e:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100c71:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100c78:	eb 0c                	jmp    c0100c86 <parse+0x1b>
            *buf ++ = '\0';
c0100c7a:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c7d:	8d 50 01             	lea    0x1(%eax),%edx
c0100c80:	89 55 08             	mov    %edx,0x8(%ebp)
c0100c83:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100c86:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c89:	0f b6 00             	movzbl (%eax),%eax
c0100c8c:	84 c0                	test   %al,%al
c0100c8e:	74 1d                	je     c0100cad <parse+0x42>
c0100c90:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c93:	0f b6 00             	movzbl (%eax),%eax
c0100c96:	0f be c0             	movsbl %al,%eax
c0100c99:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c9d:	c7 04 24 f4 c0 10 c0 	movl   $0xc010c0f4,(%esp)
c0100ca4:	e8 ea a6 00 00       	call   c010b393 <strchr>
c0100ca9:	85 c0                	test   %eax,%eax
c0100cab:	75 cd                	jne    c0100c7a <parse+0xf>
        }
        if (*buf == '\0') {
c0100cad:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cb0:	0f b6 00             	movzbl (%eax),%eax
c0100cb3:	84 c0                	test   %al,%al
c0100cb5:	75 02                	jne    c0100cb9 <parse+0x4e>
            break;
c0100cb7:	eb 67                	jmp    c0100d20 <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100cb9:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100cbd:	75 14                	jne    c0100cd3 <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100cbf:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100cc6:	00 
c0100cc7:	c7 04 24 f9 c0 10 c0 	movl   $0xc010c0f9,(%esp)
c0100cce:	e8 d6 f5 ff ff       	call   c01002a9 <cprintf>
        }
        argv[argc ++] = buf;
c0100cd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cd6:	8d 50 01             	lea    0x1(%eax),%edx
c0100cd9:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100cdc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100ce3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100ce6:	01 c2                	add    %eax,%edx
c0100ce8:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ceb:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100ced:	eb 04                	jmp    c0100cf3 <parse+0x88>
            buf ++;
c0100cef:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100cf3:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cf6:	0f b6 00             	movzbl (%eax),%eax
c0100cf9:	84 c0                	test   %al,%al
c0100cfb:	74 1d                	je     c0100d1a <parse+0xaf>
c0100cfd:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d00:	0f b6 00             	movzbl (%eax),%eax
c0100d03:	0f be c0             	movsbl %al,%eax
c0100d06:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d0a:	c7 04 24 f4 c0 10 c0 	movl   $0xc010c0f4,(%esp)
c0100d11:	e8 7d a6 00 00       	call   c010b393 <strchr>
c0100d16:	85 c0                	test   %eax,%eax
c0100d18:	74 d5                	je     c0100cef <parse+0x84>
        }
    }
c0100d1a:	90                   	nop
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100d1b:	e9 66 ff ff ff       	jmp    c0100c86 <parse+0x1b>
    return argc;
c0100d20:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100d23:	c9                   	leave  
c0100d24:	c3                   	ret    

c0100d25 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100d25:	55                   	push   %ebp
c0100d26:	89 e5                	mov    %esp,%ebp
c0100d28:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100d2b:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100d2e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d32:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d35:	89 04 24             	mov    %eax,(%esp)
c0100d38:	e8 2e ff ff ff       	call   c0100c6b <parse>
c0100d3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100d40:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100d44:	75 0a                	jne    c0100d50 <runcmd+0x2b>
        return 0;
c0100d46:	b8 00 00 00 00       	mov    $0x0,%eax
c0100d4b:	e9 85 00 00 00       	jmp    c0100dd5 <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d50:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100d57:	eb 5c                	jmp    c0100db5 <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100d59:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100d5c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d5f:	89 d0                	mov    %edx,%eax
c0100d61:	01 c0                	add    %eax,%eax
c0100d63:	01 d0                	add    %edx,%eax
c0100d65:	c1 e0 02             	shl    $0x2,%eax
c0100d68:	05 00 a0 12 c0       	add    $0xc012a000,%eax
c0100d6d:	8b 00                	mov    (%eax),%eax
c0100d6f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100d73:	89 04 24             	mov    %eax,(%esp)
c0100d76:	e8 79 a5 00 00       	call   c010b2f4 <strcmp>
c0100d7b:	85 c0                	test   %eax,%eax
c0100d7d:	75 32                	jne    c0100db1 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100d7f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d82:	89 d0                	mov    %edx,%eax
c0100d84:	01 c0                	add    %eax,%eax
c0100d86:	01 d0                	add    %edx,%eax
c0100d88:	c1 e0 02             	shl    $0x2,%eax
c0100d8b:	05 00 a0 12 c0       	add    $0xc012a000,%eax
c0100d90:	8b 40 08             	mov    0x8(%eax),%eax
c0100d93:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100d96:	8d 4a ff             	lea    -0x1(%edx),%ecx
c0100d99:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100d9c:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100da0:	8d 55 b0             	lea    -0x50(%ebp),%edx
c0100da3:	83 c2 04             	add    $0x4,%edx
c0100da6:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100daa:	89 0c 24             	mov    %ecx,(%esp)
c0100dad:	ff d0                	call   *%eax
c0100daf:	eb 24                	jmp    c0100dd5 <runcmd+0xb0>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100db1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100db5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100db8:	83 f8 02             	cmp    $0x2,%eax
c0100dbb:	76 9c                	jbe    c0100d59 <runcmd+0x34>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100dbd:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100dc0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100dc4:	c7 04 24 17 c1 10 c0 	movl   $0xc010c117,(%esp)
c0100dcb:	e8 d9 f4 ff ff       	call   c01002a9 <cprintf>
    return 0;
c0100dd0:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100dd5:	c9                   	leave  
c0100dd6:	c3                   	ret    

c0100dd7 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100dd7:	55                   	push   %ebp
c0100dd8:	89 e5                	mov    %esp,%ebp
c0100dda:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100ddd:	c7 04 24 30 c1 10 c0 	movl   $0xc010c130,(%esp)
c0100de4:	e8 c0 f4 ff ff       	call   c01002a9 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100de9:	c7 04 24 58 c1 10 c0 	movl   $0xc010c158,(%esp)
c0100df0:	e8 b4 f4 ff ff       	call   c01002a9 <cprintf>

    if (tf != NULL) {
c0100df5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100df9:	74 0b                	je     c0100e06 <kmonitor+0x2f>
        print_trapframe(tf);
c0100dfb:	8b 45 08             	mov    0x8(%ebp),%eax
c0100dfe:	89 04 24             	mov    %eax,(%esp)
c0100e01:	e8 0c 16 00 00       	call   c0102412 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100e06:	c7 04 24 7d c1 10 c0 	movl   $0xc010c17d,(%esp)
c0100e0d:	e8 38 f5 ff ff       	call   c010034a <readline>
c0100e12:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100e15:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100e19:	74 18                	je     c0100e33 <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
c0100e1b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e1e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100e22:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100e25:	89 04 24             	mov    %eax,(%esp)
c0100e28:	e8 f8 fe ff ff       	call   c0100d25 <runcmd>
c0100e2d:	85 c0                	test   %eax,%eax
c0100e2f:	79 02                	jns    c0100e33 <kmonitor+0x5c>
                break;
c0100e31:	eb 02                	jmp    c0100e35 <kmonitor+0x5e>
            }
        }
    }
c0100e33:	eb d1                	jmp    c0100e06 <kmonitor+0x2f>
}
c0100e35:	c9                   	leave  
c0100e36:	c3                   	ret    

c0100e37 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100e37:	55                   	push   %ebp
c0100e38:	89 e5                	mov    %esp,%ebp
c0100e3a:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100e3d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100e44:	eb 3f                	jmp    c0100e85 <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100e46:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100e49:	89 d0                	mov    %edx,%eax
c0100e4b:	01 c0                	add    %eax,%eax
c0100e4d:	01 d0                	add    %edx,%eax
c0100e4f:	c1 e0 02             	shl    $0x2,%eax
c0100e52:	05 00 a0 12 c0       	add    $0xc012a000,%eax
c0100e57:	8b 48 04             	mov    0x4(%eax),%ecx
c0100e5a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100e5d:	89 d0                	mov    %edx,%eax
c0100e5f:	01 c0                	add    %eax,%eax
c0100e61:	01 d0                	add    %edx,%eax
c0100e63:	c1 e0 02             	shl    $0x2,%eax
c0100e66:	05 00 a0 12 c0       	add    $0xc012a000,%eax
c0100e6b:	8b 00                	mov    (%eax),%eax
c0100e6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100e71:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100e75:	c7 04 24 81 c1 10 c0 	movl   $0xc010c181,(%esp)
c0100e7c:	e8 28 f4 ff ff       	call   c01002a9 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100e81:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100e85:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100e88:	83 f8 02             	cmp    $0x2,%eax
c0100e8b:	76 b9                	jbe    c0100e46 <mon_help+0xf>
    }
    return 0;
c0100e8d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e92:	c9                   	leave  
c0100e93:	c3                   	ret    

c0100e94 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100e94:	55                   	push   %ebp
c0100e95:	89 e5                	mov    %esp,%ebp
c0100e97:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100e9a:	e8 b9 fb ff ff       	call   c0100a58 <print_kerninfo>
    return 0;
c0100e9f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100ea4:	c9                   	leave  
c0100ea5:	c3                   	ret    

c0100ea6 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100ea6:	55                   	push   %ebp
c0100ea7:	89 e5                	mov    %esp,%ebp
c0100ea9:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100eac:	e8 f1 fc ff ff       	call   c0100ba2 <print_stackframe>
    return 0;
c0100eb1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100eb6:	c9                   	leave  
c0100eb7:	c3                   	ret    

c0100eb8 <ide_wait_ready>:
    unsigned int size;          // Size in Sectors
    unsigned char model[41];    // Model in String
} ide_devices[MAX_IDE];

static int
ide_wait_ready(unsigned short iobase, bool check_error) {
c0100eb8:	55                   	push   %ebp
c0100eb9:	89 e5                	mov    %esp,%ebp
c0100ebb:	83 ec 14             	sub    $0x14,%esp
c0100ebe:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ec1:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    int r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c0100ec5:	90                   	nop
c0100ec6:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0100eca:	83 c0 07             	add    $0x7,%eax
c0100ecd:	0f b7 c0             	movzwl %ax,%eax
c0100ed0:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100ed4:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100ed8:	89 c2                	mov    %eax,%edx
c0100eda:	ec                   	in     (%dx),%al
c0100edb:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0100ede:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0100ee2:	0f b6 c0             	movzbl %al,%eax
c0100ee5:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100ee8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100eeb:	25 80 00 00 00       	and    $0x80,%eax
c0100ef0:	85 c0                	test   %eax,%eax
c0100ef2:	75 d2                	jne    c0100ec6 <ide_wait_ready+0xe>
        /* nothing */;
    if (check_error && (r & (IDE_DF | IDE_ERR)) != 0) {
c0100ef4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0100ef8:	74 11                	je     c0100f0b <ide_wait_ready+0x53>
c0100efa:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100efd:	83 e0 21             	and    $0x21,%eax
c0100f00:	85 c0                	test   %eax,%eax
c0100f02:	74 07                	je     c0100f0b <ide_wait_ready+0x53>
        return -1;
c0100f04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100f09:	eb 05                	jmp    c0100f10 <ide_wait_ready+0x58>
    }
    return 0;
c0100f0b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100f10:	c9                   	leave  
c0100f11:	c3                   	ret    

c0100f12 <ide_init>:

void
ide_init(void) {
c0100f12:	55                   	push   %ebp
c0100f13:	89 e5                	mov    %esp,%ebp
c0100f15:	57                   	push   %edi
c0100f16:	53                   	push   %ebx
c0100f17:	81 ec 50 02 00 00    	sub    $0x250,%esp
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0100f1d:	66 c7 45 f6 00 00    	movw   $0x0,-0xa(%ebp)
c0100f23:	e9 d6 02 00 00       	jmp    c01011fe <ide_init+0x2ec>
        /* assume that no device here */
        ide_devices[ideno].valid = 0;
c0100f28:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100f2c:	c1 e0 03             	shl    $0x3,%eax
c0100f2f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0100f36:	29 c2                	sub    %eax,%edx
c0100f38:	8d 82 40 e4 19 c0    	lea    -0x3fe61bc0(%edx),%eax
c0100f3e:	c6 00 00             	movb   $0x0,(%eax)

        iobase = IO_BASE(ideno);
c0100f41:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100f45:	66 d1 e8             	shr    %ax
c0100f48:	0f b7 c0             	movzwl %ax,%eax
c0100f4b:	0f b7 04 85 8c c1 10 	movzwl -0x3fef3e74(,%eax,4),%eax
c0100f52:	c0 
c0100f53:	66 89 45 ea          	mov    %ax,-0x16(%ebp)

        /* wait device ready */
        ide_wait_ready(iobase, 0);
c0100f57:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100f5b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100f62:	00 
c0100f63:	89 04 24             	mov    %eax,(%esp)
c0100f66:	e8 4d ff ff ff       	call   c0100eb8 <ide_wait_ready>

        /* step1: select drive */
        outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4));
c0100f6b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100f6f:	83 e0 01             	and    $0x1,%eax
c0100f72:	c1 e0 04             	shl    $0x4,%eax
c0100f75:	83 c8 e0             	or     $0xffffffe0,%eax
c0100f78:	0f b6 c0             	movzbl %al,%eax
c0100f7b:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100f7f:	83 c2 06             	add    $0x6,%edx
c0100f82:	0f b7 d2             	movzwl %dx,%edx
c0100f85:	66 89 55 d2          	mov    %dx,-0x2e(%ebp)
c0100f89:	88 45 d1             	mov    %al,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f8c:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0100f90:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0100f94:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c0100f95:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100f99:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100fa0:	00 
c0100fa1:	89 04 24             	mov    %eax,(%esp)
c0100fa4:	e8 0f ff ff ff       	call   c0100eb8 <ide_wait_ready>

        /* step2: send ATA identify command */
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
c0100fa9:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100fad:	83 c0 07             	add    $0x7,%eax
c0100fb0:	0f b7 c0             	movzwl %ax,%eax
c0100fb3:	66 89 45 ce          	mov    %ax,-0x32(%ebp)
c0100fb7:	c6 45 cd ec          	movb   $0xec,-0x33(%ebp)
c0100fbb:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0100fbf:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0100fc3:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c0100fc4:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100fc8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100fcf:	00 
c0100fd0:	89 04 24             	mov    %eax,(%esp)
c0100fd3:	e8 e0 fe ff ff       	call   c0100eb8 <ide_wait_ready>

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
c0100fd8:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100fdc:	83 c0 07             	add    $0x7,%eax
c0100fdf:	0f b7 c0             	movzwl %ax,%eax
c0100fe2:	66 89 45 ca          	mov    %ax,-0x36(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100fe6:	0f b7 45 ca          	movzwl -0x36(%ebp),%eax
c0100fea:	89 c2                	mov    %eax,%edx
c0100fec:	ec                   	in     (%dx),%al
c0100fed:	88 45 c9             	mov    %al,-0x37(%ebp)
    return data;
c0100ff0:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0100ff4:	84 c0                	test   %al,%al
c0100ff6:	0f 84 f7 01 00 00    	je     c01011f3 <ide_init+0x2e1>
c0100ffc:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101000:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101007:	00 
c0101008:	89 04 24             	mov    %eax,(%esp)
c010100b:	e8 a8 fe ff ff       	call   c0100eb8 <ide_wait_ready>
c0101010:	85 c0                	test   %eax,%eax
c0101012:	0f 85 db 01 00 00    	jne    c01011f3 <ide_init+0x2e1>
            continue ;
        }

        /* device is ok */
        ide_devices[ideno].valid = 1;
c0101018:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010101c:	c1 e0 03             	shl    $0x3,%eax
c010101f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101026:	29 c2                	sub    %eax,%edx
c0101028:	8d 82 40 e4 19 c0    	lea    -0x3fe61bc0(%edx),%eax
c010102e:	c6 00 01             	movb   $0x1,(%eax)

        /* read identification space of the device */
        unsigned int buffer[128];
        insl(iobase + ISA_DATA, buffer, sizeof(buffer) / sizeof(unsigned int));
c0101031:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101035:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0101038:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c010103e:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0101041:	c7 45 bc 80 00 00 00 	movl   $0x80,-0x44(%ebp)
    asm volatile (
c0101048:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c010104b:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c010104e:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0101051:	89 cb                	mov    %ecx,%ebx
c0101053:	89 df                	mov    %ebx,%edi
c0101055:	89 c1                	mov    %eax,%ecx
c0101057:	fc                   	cld    
c0101058:	f2 6d                	repnz insl (%dx),%es:(%edi)
c010105a:	89 c8                	mov    %ecx,%eax
c010105c:	89 fb                	mov    %edi,%ebx
c010105e:	89 5d c0             	mov    %ebx,-0x40(%ebp)
c0101061:	89 45 bc             	mov    %eax,-0x44(%ebp)

        unsigned char *ident = (unsigned char *)buffer;
c0101064:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c010106a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        unsigned int sectors;
        unsigned int cmdsets = *(unsigned int *)(ident + IDE_IDENT_CMDSETS);
c010106d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101070:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
c0101076:	89 45 e0             	mov    %eax,-0x20(%ebp)
        /* device use 48-bits or 28-bits addressing */
        if (cmdsets & (1 << 26)) {
c0101079:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010107c:	25 00 00 00 04       	and    $0x4000000,%eax
c0101081:	85 c0                	test   %eax,%eax
c0101083:	74 0e                	je     c0101093 <ide_init+0x181>
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA_EXT);
c0101085:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101088:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
c010108e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0101091:	eb 09                	jmp    c010109c <ide_init+0x18a>
        }
        else {
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA);
c0101093:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101096:	8b 40 78             	mov    0x78(%eax),%eax
c0101099:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        ide_devices[ideno].sets = cmdsets;
c010109c:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01010a0:	c1 e0 03             	shl    $0x3,%eax
c01010a3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01010aa:	29 c2                	sub    %eax,%edx
c01010ac:	81 c2 40 e4 19 c0    	add    $0xc019e440,%edx
c01010b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01010b5:	89 42 04             	mov    %eax,0x4(%edx)
        ide_devices[ideno].size = sectors;
c01010b8:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01010bc:	c1 e0 03             	shl    $0x3,%eax
c01010bf:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01010c6:	29 c2                	sub    %eax,%edx
c01010c8:	81 c2 40 e4 19 c0    	add    $0xc019e440,%edx
c01010ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01010d1:	89 42 08             	mov    %eax,0x8(%edx)

        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c01010d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01010d7:	83 c0 62             	add    $0x62,%eax
c01010da:	0f b7 00             	movzwl (%eax),%eax
c01010dd:	0f b7 c0             	movzwl %ax,%eax
c01010e0:	25 00 02 00 00       	and    $0x200,%eax
c01010e5:	85 c0                	test   %eax,%eax
c01010e7:	75 24                	jne    c010110d <ide_init+0x1fb>
c01010e9:	c7 44 24 0c 94 c1 10 	movl   $0xc010c194,0xc(%esp)
c01010f0:	c0 
c01010f1:	c7 44 24 08 d7 c1 10 	movl   $0xc010c1d7,0x8(%esp)
c01010f8:	c0 
c01010f9:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c0101100:	00 
c0101101:	c7 04 24 ec c1 10 c0 	movl   $0xc010c1ec,(%esp)
c0101108:	e8 f3 f2 ff ff       	call   c0100400 <__panic>

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
c010110d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101111:	c1 e0 03             	shl    $0x3,%eax
c0101114:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010111b:	29 c2                	sub    %eax,%edx
c010111d:	8d 82 40 e4 19 c0    	lea    -0x3fe61bc0(%edx),%eax
c0101123:	83 c0 0c             	add    $0xc,%eax
c0101126:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0101129:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010112c:	83 c0 36             	add    $0x36,%eax
c010112f:	89 45 d8             	mov    %eax,-0x28(%ebp)
        unsigned int i, length = 40;
c0101132:	c7 45 d4 28 00 00 00 	movl   $0x28,-0x2c(%ebp)
        for (i = 0; i < length; i += 2) {
c0101139:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0101140:	eb 34                	jmp    c0101176 <ide_init+0x264>
            model[i] = data[i + 1], model[i + 1] = data[i];
c0101142:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101145:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101148:	01 c2                	add    %eax,%edx
c010114a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010114d:	8d 48 01             	lea    0x1(%eax),%ecx
c0101150:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101153:	01 c8                	add    %ecx,%eax
c0101155:	0f b6 00             	movzbl (%eax),%eax
c0101158:	88 02                	mov    %al,(%edx)
c010115a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010115d:	8d 50 01             	lea    0x1(%eax),%edx
c0101160:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101163:	01 c2                	add    %eax,%edx
c0101165:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101168:	8b 4d d8             	mov    -0x28(%ebp),%ecx
c010116b:	01 c8                	add    %ecx,%eax
c010116d:	0f b6 00             	movzbl (%eax),%eax
c0101170:	88 02                	mov    %al,(%edx)
        for (i = 0; i < length; i += 2) {
c0101172:	83 45 ec 02          	addl   $0x2,-0x14(%ebp)
c0101176:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101179:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010117c:	72 c4                	jb     c0101142 <ide_init+0x230>
        }
        do {
            model[i] = '\0';
c010117e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101181:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101184:	01 d0                	add    %edx,%eax
c0101186:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c0101189:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010118c:	8d 50 ff             	lea    -0x1(%eax),%edx
c010118f:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0101192:	85 c0                	test   %eax,%eax
c0101194:	74 0f                	je     c01011a5 <ide_init+0x293>
c0101196:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101199:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010119c:	01 d0                	add    %edx,%eax
c010119e:	0f b6 00             	movzbl (%eax),%eax
c01011a1:	3c 20                	cmp    $0x20,%al
c01011a3:	74 d9                	je     c010117e <ide_init+0x26c>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
c01011a5:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01011a9:	c1 e0 03             	shl    $0x3,%eax
c01011ac:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01011b3:	29 c2                	sub    %eax,%edx
c01011b5:	8d 82 40 e4 19 c0    	lea    -0x3fe61bc0(%edx),%eax
c01011bb:	8d 48 0c             	lea    0xc(%eax),%ecx
c01011be:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01011c2:	c1 e0 03             	shl    $0x3,%eax
c01011c5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01011cc:	29 c2                	sub    %eax,%edx
c01011ce:	8d 82 40 e4 19 c0    	lea    -0x3fe61bc0(%edx),%eax
c01011d4:	8b 50 08             	mov    0x8(%eax),%edx
c01011d7:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01011db:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01011df:	89 54 24 08          	mov    %edx,0x8(%esp)
c01011e3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01011e7:	c7 04 24 fe c1 10 c0 	movl   $0xc010c1fe,(%esp)
c01011ee:	e8 b6 f0 ff ff       	call   c01002a9 <cprintf>
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c01011f3:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01011f7:	83 c0 01             	add    $0x1,%eax
c01011fa:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c01011fe:	66 83 7d f6 03       	cmpw   $0x3,-0xa(%ebp)
c0101203:	0f 86 1f fd ff ff    	jbe    c0100f28 <ide_init+0x16>
    }

    // enable ide interrupt
    pic_enable(IRQ_IDE1);
c0101209:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
c0101210:	e8 91 0e 00 00       	call   c01020a6 <pic_enable>
    pic_enable(IRQ_IDE2);
c0101215:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
c010121c:	e8 85 0e 00 00       	call   c01020a6 <pic_enable>
}
c0101221:	81 c4 50 02 00 00    	add    $0x250,%esp
c0101227:	5b                   	pop    %ebx
c0101228:	5f                   	pop    %edi
c0101229:	5d                   	pop    %ebp
c010122a:	c3                   	ret    

c010122b <ide_device_valid>:

bool
ide_device_valid(unsigned short ideno) {
c010122b:	55                   	push   %ebp
c010122c:	89 e5                	mov    %esp,%ebp
c010122e:	83 ec 04             	sub    $0x4,%esp
c0101231:	8b 45 08             	mov    0x8(%ebp),%eax
c0101234:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    return VALID_IDE(ideno);
c0101238:	66 83 7d fc 03       	cmpw   $0x3,-0x4(%ebp)
c010123d:	77 24                	ja     c0101263 <ide_device_valid+0x38>
c010123f:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101243:	c1 e0 03             	shl    $0x3,%eax
c0101246:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010124d:	29 c2                	sub    %eax,%edx
c010124f:	8d 82 40 e4 19 c0    	lea    -0x3fe61bc0(%edx),%eax
c0101255:	0f b6 00             	movzbl (%eax),%eax
c0101258:	84 c0                	test   %al,%al
c010125a:	74 07                	je     c0101263 <ide_device_valid+0x38>
c010125c:	b8 01 00 00 00       	mov    $0x1,%eax
c0101261:	eb 05                	jmp    c0101268 <ide_device_valid+0x3d>
c0101263:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101268:	c9                   	leave  
c0101269:	c3                   	ret    

c010126a <ide_device_size>:

size_t
ide_device_size(unsigned short ideno) {
c010126a:	55                   	push   %ebp
c010126b:	89 e5                	mov    %esp,%ebp
c010126d:	83 ec 08             	sub    $0x8,%esp
c0101270:	8b 45 08             	mov    0x8(%ebp),%eax
c0101273:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    if (ide_device_valid(ideno)) {
c0101277:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c010127b:	89 04 24             	mov    %eax,(%esp)
c010127e:	e8 a8 ff ff ff       	call   c010122b <ide_device_valid>
c0101283:	85 c0                	test   %eax,%eax
c0101285:	74 1b                	je     c01012a2 <ide_device_size+0x38>
        return ide_devices[ideno].size;
c0101287:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c010128b:	c1 e0 03             	shl    $0x3,%eax
c010128e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101295:	29 c2                	sub    %eax,%edx
c0101297:	8d 82 40 e4 19 c0    	lea    -0x3fe61bc0(%edx),%eax
c010129d:	8b 40 08             	mov    0x8(%eax),%eax
c01012a0:	eb 05                	jmp    c01012a7 <ide_device_size+0x3d>
    }
    return 0;
c01012a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01012a7:	c9                   	leave  
c01012a8:	c3                   	ret    

c01012a9 <ide_read_secs>:

int
ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs) {
c01012a9:	55                   	push   %ebp
c01012aa:	89 e5                	mov    %esp,%ebp
c01012ac:	57                   	push   %edi
c01012ad:	53                   	push   %ebx
c01012ae:	83 ec 50             	sub    $0x50,%esp
c01012b1:	8b 45 08             	mov    0x8(%ebp),%eax
c01012b4:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c01012b8:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c01012bf:	77 24                	ja     c01012e5 <ide_read_secs+0x3c>
c01012c1:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c01012c6:	77 1d                	ja     c01012e5 <ide_read_secs+0x3c>
c01012c8:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01012cc:	c1 e0 03             	shl    $0x3,%eax
c01012cf:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01012d6:	29 c2                	sub    %eax,%edx
c01012d8:	8d 82 40 e4 19 c0    	lea    -0x3fe61bc0(%edx),%eax
c01012de:	0f b6 00             	movzbl (%eax),%eax
c01012e1:	84 c0                	test   %al,%al
c01012e3:	75 24                	jne    c0101309 <ide_read_secs+0x60>
c01012e5:	c7 44 24 0c 1c c2 10 	movl   $0xc010c21c,0xc(%esp)
c01012ec:	c0 
c01012ed:	c7 44 24 08 d7 c1 10 	movl   $0xc010c1d7,0x8(%esp)
c01012f4:	c0 
c01012f5:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c01012fc:	00 
c01012fd:	c7 04 24 ec c1 10 c0 	movl   $0xc010c1ec,(%esp)
c0101304:	e8 f7 f0 ff ff       	call   c0100400 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101309:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101310:	77 0f                	ja     c0101321 <ide_read_secs+0x78>
c0101312:	8b 45 14             	mov    0x14(%ebp),%eax
c0101315:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101318:	01 d0                	add    %edx,%eax
c010131a:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c010131f:	76 24                	jbe    c0101345 <ide_read_secs+0x9c>
c0101321:	c7 44 24 0c 44 c2 10 	movl   $0xc010c244,0xc(%esp)
c0101328:	c0 
c0101329:	c7 44 24 08 d7 c1 10 	movl   $0xc010c1d7,0x8(%esp)
c0101330:	c0 
c0101331:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c0101338:	00 
c0101339:	c7 04 24 ec c1 10 c0 	movl   $0xc010c1ec,(%esp)
c0101340:	e8 bb f0 ff ff       	call   c0100400 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101345:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101349:	66 d1 e8             	shr    %ax
c010134c:	0f b7 c0             	movzwl %ax,%eax
c010134f:	0f b7 04 85 8c c1 10 	movzwl -0x3fef3e74(,%eax,4),%eax
c0101356:	c0 
c0101357:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c010135b:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c010135f:	66 d1 e8             	shr    %ax
c0101362:	0f b7 c0             	movzwl %ax,%eax
c0101365:	0f b7 04 85 8e c1 10 	movzwl -0x3fef3e72(,%eax,4),%eax
c010136c:	c0 
c010136d:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101371:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101375:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010137c:	00 
c010137d:	89 04 24             	mov    %eax,(%esp)
c0101380:	e8 33 fb ff ff       	call   c0100eb8 <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101385:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101389:	83 c0 02             	add    $0x2,%eax
c010138c:	0f b7 c0             	movzwl %ax,%eax
c010138f:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101393:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101397:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010139b:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010139f:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c01013a0:	8b 45 14             	mov    0x14(%ebp),%eax
c01013a3:	0f b6 c0             	movzbl %al,%eax
c01013a6:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01013aa:	83 c2 02             	add    $0x2,%edx
c01013ad:	0f b7 d2             	movzwl %dx,%edx
c01013b0:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c01013b4:	88 45 e9             	mov    %al,-0x17(%ebp)
c01013b7:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01013bb:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01013bf:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c01013c0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01013c3:	0f b6 c0             	movzbl %al,%eax
c01013c6:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01013ca:	83 c2 03             	add    $0x3,%edx
c01013cd:	0f b7 d2             	movzwl %dx,%edx
c01013d0:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01013d4:	88 45 e5             	mov    %al,-0x1b(%ebp)
c01013d7:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01013db:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01013df:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c01013e0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01013e3:	c1 e8 08             	shr    $0x8,%eax
c01013e6:	0f b6 c0             	movzbl %al,%eax
c01013e9:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01013ed:	83 c2 04             	add    $0x4,%edx
c01013f0:	0f b7 d2             	movzwl %dx,%edx
c01013f3:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c01013f7:	88 45 e1             	mov    %al,-0x1f(%ebp)
c01013fa:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01013fe:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101402:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101403:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101406:	c1 e8 10             	shr    $0x10,%eax
c0101409:	0f b6 c0             	movzbl %al,%eax
c010140c:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101410:	83 c2 05             	add    $0x5,%edx
c0101413:	0f b7 d2             	movzwl %dx,%edx
c0101416:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c010141a:	88 45 dd             	mov    %al,-0x23(%ebp)
c010141d:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101421:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101425:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101426:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c010142a:	83 e0 01             	and    $0x1,%eax
c010142d:	c1 e0 04             	shl    $0x4,%eax
c0101430:	89 c2                	mov    %eax,%edx
c0101432:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101435:	c1 e8 18             	shr    $0x18,%eax
c0101438:	83 e0 0f             	and    $0xf,%eax
c010143b:	09 d0                	or     %edx,%eax
c010143d:	83 c8 e0             	or     $0xffffffe0,%eax
c0101440:	0f b6 c0             	movzbl %al,%eax
c0101443:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101447:	83 c2 06             	add    $0x6,%edx
c010144a:	0f b7 d2             	movzwl %dx,%edx
c010144d:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101451:	88 45 d9             	mov    %al,-0x27(%ebp)
c0101454:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101458:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c010145c:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);
c010145d:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101461:	83 c0 07             	add    $0x7,%eax
c0101464:	0f b7 c0             	movzwl %ax,%eax
c0101467:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c010146b:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
c010146f:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101473:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101477:	ee                   	out    %al,(%dx)

    int ret = 0;
c0101478:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c010147f:	eb 5a                	jmp    c01014db <ide_read_secs+0x232>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101481:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101485:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010148c:	00 
c010148d:	89 04 24             	mov    %eax,(%esp)
c0101490:	e8 23 fa ff ff       	call   c0100eb8 <ide_wait_ready>
c0101495:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101498:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010149c:	74 02                	je     c01014a0 <ide_read_secs+0x1f7>
            goto out;
c010149e:	eb 41                	jmp    c01014e1 <ide_read_secs+0x238>
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
c01014a0:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01014a4:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01014a7:	8b 45 10             	mov    0x10(%ebp),%eax
c01014aa:	89 45 cc             	mov    %eax,-0x34(%ebp)
c01014ad:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile (
c01014b4:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01014b7:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c01014ba:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01014bd:	89 cb                	mov    %ecx,%ebx
c01014bf:	89 df                	mov    %ebx,%edi
c01014c1:	89 c1                	mov    %eax,%ecx
c01014c3:	fc                   	cld    
c01014c4:	f2 6d                	repnz insl (%dx),%es:(%edi)
c01014c6:	89 c8                	mov    %ecx,%eax
c01014c8:	89 fb                	mov    %edi,%ebx
c01014ca:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c01014cd:	89 45 c8             	mov    %eax,-0x38(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c01014d0:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c01014d4:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c01014db:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c01014df:	75 a0                	jne    c0101481 <ide_read_secs+0x1d8>
    }

out:
    return ret;
c01014e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01014e4:	83 c4 50             	add    $0x50,%esp
c01014e7:	5b                   	pop    %ebx
c01014e8:	5f                   	pop    %edi
c01014e9:	5d                   	pop    %ebp
c01014ea:	c3                   	ret    

c01014eb <ide_write_secs>:

int
ide_write_secs(unsigned short ideno, uint32_t secno, const void *src, size_t nsecs) {
c01014eb:	55                   	push   %ebp
c01014ec:	89 e5                	mov    %esp,%ebp
c01014ee:	56                   	push   %esi
c01014ef:	53                   	push   %ebx
c01014f0:	83 ec 50             	sub    $0x50,%esp
c01014f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01014f6:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c01014fa:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101501:	77 24                	ja     c0101527 <ide_write_secs+0x3c>
c0101503:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c0101508:	77 1d                	ja     c0101527 <ide_write_secs+0x3c>
c010150a:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c010150e:	c1 e0 03             	shl    $0x3,%eax
c0101511:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101518:	29 c2                	sub    %eax,%edx
c010151a:	8d 82 40 e4 19 c0    	lea    -0x3fe61bc0(%edx),%eax
c0101520:	0f b6 00             	movzbl (%eax),%eax
c0101523:	84 c0                	test   %al,%al
c0101525:	75 24                	jne    c010154b <ide_write_secs+0x60>
c0101527:	c7 44 24 0c 1c c2 10 	movl   $0xc010c21c,0xc(%esp)
c010152e:	c0 
c010152f:	c7 44 24 08 d7 c1 10 	movl   $0xc010c1d7,0x8(%esp)
c0101536:	c0 
c0101537:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c010153e:	00 
c010153f:	c7 04 24 ec c1 10 c0 	movl   $0xc010c1ec,(%esp)
c0101546:	e8 b5 ee ff ff       	call   c0100400 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c010154b:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101552:	77 0f                	ja     c0101563 <ide_write_secs+0x78>
c0101554:	8b 45 14             	mov    0x14(%ebp),%eax
c0101557:	8b 55 0c             	mov    0xc(%ebp),%edx
c010155a:	01 d0                	add    %edx,%eax
c010155c:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101561:	76 24                	jbe    c0101587 <ide_write_secs+0x9c>
c0101563:	c7 44 24 0c 44 c2 10 	movl   $0xc010c244,0xc(%esp)
c010156a:	c0 
c010156b:	c7 44 24 08 d7 c1 10 	movl   $0xc010c1d7,0x8(%esp)
c0101572:	c0 
c0101573:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
c010157a:	00 
c010157b:	c7 04 24 ec c1 10 c0 	movl   $0xc010c1ec,(%esp)
c0101582:	e8 79 ee ff ff       	call   c0100400 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101587:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c010158b:	66 d1 e8             	shr    %ax
c010158e:	0f b7 c0             	movzwl %ax,%eax
c0101591:	0f b7 04 85 8c c1 10 	movzwl -0x3fef3e74(,%eax,4),%eax
c0101598:	c0 
c0101599:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c010159d:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01015a1:	66 d1 e8             	shr    %ax
c01015a4:	0f b7 c0             	movzwl %ax,%eax
c01015a7:	0f b7 04 85 8e c1 10 	movzwl -0x3fef3e72(,%eax,4),%eax
c01015ae:	c0 
c01015af:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c01015b3:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01015b7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01015be:	00 
c01015bf:	89 04 24             	mov    %eax,(%esp)
c01015c2:	e8 f1 f8 ff ff       	call   c0100eb8 <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c01015c7:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01015cb:	83 c0 02             	add    $0x2,%eax
c01015ce:	0f b7 c0             	movzwl %ax,%eax
c01015d1:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c01015d5:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01015d9:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01015dd:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01015e1:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c01015e2:	8b 45 14             	mov    0x14(%ebp),%eax
c01015e5:	0f b6 c0             	movzbl %al,%eax
c01015e8:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01015ec:	83 c2 02             	add    $0x2,%edx
c01015ef:	0f b7 d2             	movzwl %dx,%edx
c01015f2:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c01015f6:	88 45 e9             	mov    %al,-0x17(%ebp)
c01015f9:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01015fd:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101601:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101602:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101605:	0f b6 c0             	movzbl %al,%eax
c0101608:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010160c:	83 c2 03             	add    $0x3,%edx
c010160f:	0f b7 d2             	movzwl %dx,%edx
c0101612:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101616:	88 45 e5             	mov    %al,-0x1b(%ebp)
c0101619:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c010161d:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101621:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101622:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101625:	c1 e8 08             	shr    $0x8,%eax
c0101628:	0f b6 c0             	movzbl %al,%eax
c010162b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010162f:	83 c2 04             	add    $0x4,%edx
c0101632:	0f b7 d2             	movzwl %dx,%edx
c0101635:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101639:	88 45 e1             	mov    %al,-0x1f(%ebp)
c010163c:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101640:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101644:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101645:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101648:	c1 e8 10             	shr    $0x10,%eax
c010164b:	0f b6 c0             	movzbl %al,%eax
c010164e:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101652:	83 c2 05             	add    $0x5,%edx
c0101655:	0f b7 d2             	movzwl %dx,%edx
c0101658:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c010165c:	88 45 dd             	mov    %al,-0x23(%ebp)
c010165f:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101663:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101667:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101668:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c010166c:	83 e0 01             	and    $0x1,%eax
c010166f:	c1 e0 04             	shl    $0x4,%eax
c0101672:	89 c2                	mov    %eax,%edx
c0101674:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101677:	c1 e8 18             	shr    $0x18,%eax
c010167a:	83 e0 0f             	and    $0xf,%eax
c010167d:	09 d0                	or     %edx,%eax
c010167f:	83 c8 e0             	or     $0xffffffe0,%eax
c0101682:	0f b6 c0             	movzbl %al,%eax
c0101685:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101689:	83 c2 06             	add    $0x6,%edx
c010168c:	0f b7 d2             	movzwl %dx,%edx
c010168f:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101693:	88 45 d9             	mov    %al,-0x27(%ebp)
c0101696:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c010169a:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c010169e:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);
c010169f:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01016a3:	83 c0 07             	add    $0x7,%eax
c01016a6:	0f b7 c0             	movzwl %ax,%eax
c01016a9:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c01016ad:	c6 45 d5 30          	movb   $0x30,-0x2b(%ebp)
c01016b1:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c01016b5:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c01016b9:	ee                   	out    %al,(%dx)

    int ret = 0;
c01016ba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c01016c1:	eb 5a                	jmp    c010171d <ide_write_secs+0x232>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c01016c3:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01016c7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01016ce:	00 
c01016cf:	89 04 24             	mov    %eax,(%esp)
c01016d2:	e8 e1 f7 ff ff       	call   c0100eb8 <ide_wait_ready>
c01016d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01016da:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01016de:	74 02                	je     c01016e2 <ide_write_secs+0x1f7>
            goto out;
c01016e0:	eb 41                	jmp    c0101723 <ide_write_secs+0x238>
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
c01016e2:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01016e6:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01016e9:	8b 45 10             	mov    0x10(%ebp),%eax
c01016ec:	89 45 cc             	mov    %eax,-0x34(%ebp)
c01016ef:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile (
c01016f6:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01016f9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c01016fc:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01016ff:	89 cb                	mov    %ecx,%ebx
c0101701:	89 de                	mov    %ebx,%esi
c0101703:	89 c1                	mov    %eax,%ecx
c0101705:	fc                   	cld    
c0101706:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
c0101708:	89 c8                	mov    %ecx,%eax
c010170a:	89 f3                	mov    %esi,%ebx
c010170c:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c010170f:	89 45 c8             	mov    %eax,-0x38(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0101712:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c0101716:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c010171d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101721:	75 a0                	jne    c01016c3 <ide_write_secs+0x1d8>
    }

out:
    return ret;
c0101723:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101726:	83 c4 50             	add    $0x50,%esp
c0101729:	5b                   	pop    %ebx
c010172a:	5e                   	pop    %esi
c010172b:	5d                   	pop    %ebp
c010172c:	c3                   	ret    

c010172d <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c010172d:	55                   	push   %ebp
c010172e:	89 e5                	mov    %esp,%ebp
c0101730:	83 ec 28             	sub    $0x28,%esp
c0101733:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c0101739:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010173d:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101741:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101745:	ee                   	out    %al,(%dx)
c0101746:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c010174c:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
c0101750:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101754:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101758:	ee                   	out    %al,(%dx)
c0101759:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
c010175f:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
c0101763:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101767:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010176b:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c010176c:	c7 05 54 10 1a c0 00 	movl   $0x0,0xc01a1054
c0101773:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0101776:	c7 04 24 7e c2 10 c0 	movl   $0xc010c27e,(%esp)
c010177d:	e8 27 eb ff ff       	call   c01002a9 <cprintf>
    pic_enable(IRQ_TIMER);
c0101782:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0101789:	e8 18 09 00 00       	call   c01020a6 <pic_enable>
}
c010178e:	c9                   	leave  
c010178f:	c3                   	ret    

c0101790 <__intr_save>:
#include <assert.h>
#include <atomic.h>
#include <sched.h>

static inline bool
__intr_save(void) {
c0101790:	55                   	push   %ebp
c0101791:	89 e5                	mov    %esp,%ebp
c0101793:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0101796:	9c                   	pushf  
c0101797:	58                   	pop    %eax
c0101798:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c010179b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c010179e:	25 00 02 00 00       	and    $0x200,%eax
c01017a3:	85 c0                	test   %eax,%eax
c01017a5:	74 0c                	je     c01017b3 <__intr_save+0x23>
        intr_disable();
c01017a7:	e8 69 0a 00 00       	call   c0102215 <intr_disable>
        return 1;
c01017ac:	b8 01 00 00 00       	mov    $0x1,%eax
c01017b1:	eb 05                	jmp    c01017b8 <__intr_save+0x28>
    }
    return 0;
c01017b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01017b8:	c9                   	leave  
c01017b9:	c3                   	ret    

c01017ba <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c01017ba:	55                   	push   %ebp
c01017bb:	89 e5                	mov    %esp,%ebp
c01017bd:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01017c0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01017c4:	74 05                	je     c01017cb <__intr_restore+0x11>
        intr_enable();
c01017c6:	e8 44 0a 00 00       	call   c010220f <intr_enable>
    }
}
c01017cb:	c9                   	leave  
c01017cc:	c3                   	ret    

c01017cd <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c01017cd:	55                   	push   %ebp
c01017ce:	89 e5                	mov    %esp,%ebp
c01017d0:	83 ec 10             	sub    $0x10,%esp
c01017d3:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01017d9:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c01017dd:	89 c2                	mov    %eax,%edx
c01017df:	ec                   	in     (%dx),%al
c01017e0:	88 45 fd             	mov    %al,-0x3(%ebp)
c01017e3:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c01017e9:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01017ed:	89 c2                	mov    %eax,%edx
c01017ef:	ec                   	in     (%dx),%al
c01017f0:	88 45 f9             	mov    %al,-0x7(%ebp)
c01017f3:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c01017f9:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01017fd:	89 c2                	mov    %eax,%edx
c01017ff:	ec                   	in     (%dx),%al
c0101800:	88 45 f5             	mov    %al,-0xb(%ebp)
c0101803:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
c0101809:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010180d:	89 c2                	mov    %eax,%edx
c010180f:	ec                   	in     (%dx),%al
c0101810:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0101813:	c9                   	leave  
c0101814:	c3                   	ret    

c0101815 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0101815:	55                   	push   %ebp
c0101816:	89 e5                	mov    %esp,%ebp
c0101818:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c010181b:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0101822:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101825:	0f b7 00             	movzwl (%eax),%eax
c0101828:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c010182c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010182f:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0101834:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101837:	0f b7 00             	movzwl (%eax),%eax
c010183a:	66 3d 5a a5          	cmp    $0xa55a,%ax
c010183e:	74 12                	je     c0101852 <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0101840:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0101847:	66 c7 05 26 e5 19 c0 	movw   $0x3b4,0xc019e526
c010184e:	b4 03 
c0101850:	eb 13                	jmp    c0101865 <cga_init+0x50>
    } else {
        *cp = was;
c0101852:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101855:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101859:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c010185c:	66 c7 05 26 e5 19 c0 	movw   $0x3d4,0xc019e526
c0101863:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0101865:	0f b7 05 26 e5 19 c0 	movzwl 0xc019e526,%eax
c010186c:	0f b7 c0             	movzwl %ax,%eax
c010186f:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101873:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101877:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010187b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010187f:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0101880:	0f b7 05 26 e5 19 c0 	movzwl 0xc019e526,%eax
c0101887:	83 c0 01             	add    $0x1,%eax
c010188a:	0f b7 c0             	movzwl %ax,%eax
c010188d:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101891:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0101895:	89 c2                	mov    %eax,%edx
c0101897:	ec                   	in     (%dx),%al
c0101898:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c010189b:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010189f:	0f b6 c0             	movzbl %al,%eax
c01018a2:	c1 e0 08             	shl    $0x8,%eax
c01018a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c01018a8:	0f b7 05 26 e5 19 c0 	movzwl 0xc019e526,%eax
c01018af:	0f b7 c0             	movzwl %ax,%eax
c01018b2:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c01018b6:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018ba:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01018be:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01018c2:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c01018c3:	0f b7 05 26 e5 19 c0 	movzwl 0xc019e526,%eax
c01018ca:	83 c0 01             	add    $0x1,%eax
c01018cd:	0f b7 c0             	movzwl %ax,%eax
c01018d0:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01018d4:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c01018d8:	89 c2                	mov    %eax,%edx
c01018da:	ec                   	in     (%dx),%al
c01018db:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
c01018de:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01018e2:	0f b6 c0             	movzbl %al,%eax
c01018e5:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c01018e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018eb:	a3 20 e5 19 c0       	mov    %eax,0xc019e520
    crt_pos = pos;
c01018f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01018f3:	66 a3 24 e5 19 c0    	mov    %ax,0xc019e524
}
c01018f9:	c9                   	leave  
c01018fa:	c3                   	ret    

c01018fb <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c01018fb:	55                   	push   %ebp
c01018fc:	89 e5                	mov    %esp,%ebp
c01018fe:	83 ec 48             	sub    $0x48,%esp
c0101901:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c0101907:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010190b:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010190f:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101913:	ee                   	out    %al,(%dx)
c0101914:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
c010191a:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
c010191e:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101922:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101926:	ee                   	out    %al,(%dx)
c0101927:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
c010192d:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
c0101931:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101935:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101939:	ee                   	out    %al,(%dx)
c010193a:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0101940:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
c0101944:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101948:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010194c:	ee                   	out    %al,(%dx)
c010194d:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
c0101953:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
c0101957:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c010195b:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010195f:	ee                   	out    %al,(%dx)
c0101960:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
c0101966:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
c010196a:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c010196e:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101972:	ee                   	out    %al,(%dx)
c0101973:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0101979:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
c010197d:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101981:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101985:	ee                   	out    %al,(%dx)
c0101986:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010198c:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
c0101990:	89 c2                	mov    %eax,%edx
c0101992:	ec                   	in     (%dx),%al
c0101993:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
c0101996:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c010199a:	3c ff                	cmp    $0xff,%al
c010199c:	0f 95 c0             	setne  %al
c010199f:	0f b6 c0             	movzbl %al,%eax
c01019a2:	a3 28 e5 19 c0       	mov    %eax,0xc019e528
c01019a7:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01019ad:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
c01019b1:	89 c2                	mov    %eax,%edx
c01019b3:	ec                   	in     (%dx),%al
c01019b4:	88 45 d5             	mov    %al,-0x2b(%ebp)
c01019b7:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
c01019bd:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c01019c1:	89 c2                	mov    %eax,%edx
c01019c3:	ec                   	in     (%dx),%al
c01019c4:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c01019c7:	a1 28 e5 19 c0       	mov    0xc019e528,%eax
c01019cc:	85 c0                	test   %eax,%eax
c01019ce:	74 0c                	je     c01019dc <serial_init+0xe1>
        pic_enable(IRQ_COM1);
c01019d0:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c01019d7:	e8 ca 06 00 00       	call   c01020a6 <pic_enable>
    }
}
c01019dc:	c9                   	leave  
c01019dd:	c3                   	ret    

c01019de <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c01019de:	55                   	push   %ebp
c01019df:	89 e5                	mov    %esp,%ebp
c01019e1:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01019e4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01019eb:	eb 09                	jmp    c01019f6 <lpt_putc_sub+0x18>
        delay();
c01019ed:	e8 db fd ff ff       	call   c01017cd <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01019f2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c01019f6:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c01019fc:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101a00:	89 c2                	mov    %eax,%edx
c0101a02:	ec                   	in     (%dx),%al
c0101a03:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101a06:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101a0a:	84 c0                	test   %al,%al
c0101a0c:	78 09                	js     c0101a17 <lpt_putc_sub+0x39>
c0101a0e:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101a15:	7e d6                	jle    c01019ed <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
c0101a17:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a1a:	0f b6 c0             	movzbl %al,%eax
c0101a1d:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
c0101a23:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101a26:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101a2a:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101a2e:	ee                   	out    %al,(%dx)
c0101a2f:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c0101a35:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c0101a39:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101a3d:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101a41:	ee                   	out    %al,(%dx)
c0101a42:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
c0101a48:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
c0101a4c:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101a50:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101a54:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c0101a55:	c9                   	leave  
c0101a56:	c3                   	ret    

c0101a57 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c0101a57:	55                   	push   %ebp
c0101a58:	89 e5                	mov    %esp,%ebp
c0101a5a:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101a5d:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101a61:	74 0d                	je     c0101a70 <lpt_putc+0x19>
        lpt_putc_sub(c);
c0101a63:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a66:	89 04 24             	mov    %eax,(%esp)
c0101a69:	e8 70 ff ff ff       	call   c01019de <lpt_putc_sub>
c0101a6e:	eb 24                	jmp    c0101a94 <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
c0101a70:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101a77:	e8 62 ff ff ff       	call   c01019de <lpt_putc_sub>
        lpt_putc_sub(' ');
c0101a7c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101a83:	e8 56 ff ff ff       	call   c01019de <lpt_putc_sub>
        lpt_putc_sub('\b');
c0101a88:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101a8f:	e8 4a ff ff ff       	call   c01019de <lpt_putc_sub>
    }
}
c0101a94:	c9                   	leave  
c0101a95:	c3                   	ret    

c0101a96 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0101a96:	55                   	push   %ebp
c0101a97:	89 e5                	mov    %esp,%ebp
c0101a99:	53                   	push   %ebx
c0101a9a:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c0101a9d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aa0:	b0 00                	mov    $0x0,%al
c0101aa2:	85 c0                	test   %eax,%eax
c0101aa4:	75 07                	jne    c0101aad <cga_putc+0x17>
        c |= 0x0700;
c0101aa6:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0101aad:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ab0:	0f b6 c0             	movzbl %al,%eax
c0101ab3:	83 f8 0a             	cmp    $0xa,%eax
c0101ab6:	74 4c                	je     c0101b04 <cga_putc+0x6e>
c0101ab8:	83 f8 0d             	cmp    $0xd,%eax
c0101abb:	74 57                	je     c0101b14 <cga_putc+0x7e>
c0101abd:	83 f8 08             	cmp    $0x8,%eax
c0101ac0:	0f 85 88 00 00 00    	jne    c0101b4e <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
c0101ac6:	0f b7 05 24 e5 19 c0 	movzwl 0xc019e524,%eax
c0101acd:	66 85 c0             	test   %ax,%ax
c0101ad0:	74 30                	je     c0101b02 <cga_putc+0x6c>
            crt_pos --;
c0101ad2:	0f b7 05 24 e5 19 c0 	movzwl 0xc019e524,%eax
c0101ad9:	83 e8 01             	sub    $0x1,%eax
c0101adc:	66 a3 24 e5 19 c0    	mov    %ax,0xc019e524
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c0101ae2:	a1 20 e5 19 c0       	mov    0xc019e520,%eax
c0101ae7:	0f b7 15 24 e5 19 c0 	movzwl 0xc019e524,%edx
c0101aee:	0f b7 d2             	movzwl %dx,%edx
c0101af1:	01 d2                	add    %edx,%edx
c0101af3:	01 c2                	add    %eax,%edx
c0101af5:	8b 45 08             	mov    0x8(%ebp),%eax
c0101af8:	b0 00                	mov    $0x0,%al
c0101afa:	83 c8 20             	or     $0x20,%eax
c0101afd:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c0101b00:	eb 72                	jmp    c0101b74 <cga_putc+0xde>
c0101b02:	eb 70                	jmp    c0101b74 <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
c0101b04:	0f b7 05 24 e5 19 c0 	movzwl 0xc019e524,%eax
c0101b0b:	83 c0 50             	add    $0x50,%eax
c0101b0e:	66 a3 24 e5 19 c0    	mov    %ax,0xc019e524
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c0101b14:	0f b7 1d 24 e5 19 c0 	movzwl 0xc019e524,%ebx
c0101b1b:	0f b7 0d 24 e5 19 c0 	movzwl 0xc019e524,%ecx
c0101b22:	0f b7 c1             	movzwl %cx,%eax
c0101b25:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
c0101b2b:	c1 e8 10             	shr    $0x10,%eax
c0101b2e:	89 c2                	mov    %eax,%edx
c0101b30:	66 c1 ea 06          	shr    $0x6,%dx
c0101b34:	89 d0                	mov    %edx,%eax
c0101b36:	c1 e0 02             	shl    $0x2,%eax
c0101b39:	01 d0                	add    %edx,%eax
c0101b3b:	c1 e0 04             	shl    $0x4,%eax
c0101b3e:	29 c1                	sub    %eax,%ecx
c0101b40:	89 ca                	mov    %ecx,%edx
c0101b42:	89 d8                	mov    %ebx,%eax
c0101b44:	29 d0                	sub    %edx,%eax
c0101b46:	66 a3 24 e5 19 c0    	mov    %ax,0xc019e524
        break;
c0101b4c:	eb 26                	jmp    c0101b74 <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c0101b4e:	8b 0d 20 e5 19 c0    	mov    0xc019e520,%ecx
c0101b54:	0f b7 05 24 e5 19 c0 	movzwl 0xc019e524,%eax
c0101b5b:	8d 50 01             	lea    0x1(%eax),%edx
c0101b5e:	66 89 15 24 e5 19 c0 	mov    %dx,0xc019e524
c0101b65:	0f b7 c0             	movzwl %ax,%eax
c0101b68:	01 c0                	add    %eax,%eax
c0101b6a:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c0101b6d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b70:	66 89 02             	mov    %ax,(%edx)
        break;
c0101b73:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c0101b74:	0f b7 05 24 e5 19 c0 	movzwl 0xc019e524,%eax
c0101b7b:	66 3d cf 07          	cmp    $0x7cf,%ax
c0101b7f:	76 5b                	jbe    c0101bdc <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c0101b81:	a1 20 e5 19 c0       	mov    0xc019e520,%eax
c0101b86:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0101b8c:	a1 20 e5 19 c0       	mov    0xc019e520,%eax
c0101b91:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c0101b98:	00 
c0101b99:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101b9d:	89 04 24             	mov    %eax,(%esp)
c0101ba0:	e8 ec 99 00 00       	call   c010b591 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101ba5:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101bac:	eb 15                	jmp    c0101bc3 <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
c0101bae:	a1 20 e5 19 c0       	mov    0xc019e520,%eax
c0101bb3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101bb6:	01 d2                	add    %edx,%edx
c0101bb8:	01 d0                	add    %edx,%eax
c0101bba:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101bbf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101bc3:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c0101bca:	7e e2                	jle    c0101bae <cga_putc+0x118>
        }
        crt_pos -= CRT_COLS;
c0101bcc:	0f b7 05 24 e5 19 c0 	movzwl 0xc019e524,%eax
c0101bd3:	83 e8 50             	sub    $0x50,%eax
c0101bd6:	66 a3 24 e5 19 c0    	mov    %ax,0xc019e524
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c0101bdc:	0f b7 05 26 e5 19 c0 	movzwl 0xc019e526,%eax
c0101be3:	0f b7 c0             	movzwl %ax,%eax
c0101be6:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101bea:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
c0101bee:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101bf2:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101bf6:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c0101bf7:	0f b7 05 24 e5 19 c0 	movzwl 0xc019e524,%eax
c0101bfe:	66 c1 e8 08          	shr    $0x8,%ax
c0101c02:	0f b6 c0             	movzbl %al,%eax
c0101c05:	0f b7 15 26 e5 19 c0 	movzwl 0xc019e526,%edx
c0101c0c:	83 c2 01             	add    $0x1,%edx
c0101c0f:	0f b7 d2             	movzwl %dx,%edx
c0101c12:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
c0101c16:	88 45 ed             	mov    %al,-0x13(%ebp)
c0101c19:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101c1d:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101c21:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c0101c22:	0f b7 05 26 e5 19 c0 	movzwl 0xc019e526,%eax
c0101c29:	0f b7 c0             	movzwl %ax,%eax
c0101c2c:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c0101c30:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
c0101c34:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101c38:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101c3c:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c0101c3d:	0f b7 05 24 e5 19 c0 	movzwl 0xc019e524,%eax
c0101c44:	0f b6 c0             	movzbl %al,%eax
c0101c47:	0f b7 15 26 e5 19 c0 	movzwl 0xc019e526,%edx
c0101c4e:	83 c2 01             	add    $0x1,%edx
c0101c51:	0f b7 d2             	movzwl %dx,%edx
c0101c54:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101c58:	88 45 e5             	mov    %al,-0x1b(%ebp)
c0101c5b:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101c5f:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101c63:	ee                   	out    %al,(%dx)
}
c0101c64:	83 c4 34             	add    $0x34,%esp
c0101c67:	5b                   	pop    %ebx
c0101c68:	5d                   	pop    %ebp
c0101c69:	c3                   	ret    

c0101c6a <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c0101c6a:	55                   	push   %ebp
c0101c6b:	89 e5                	mov    %esp,%ebp
c0101c6d:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101c70:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101c77:	eb 09                	jmp    c0101c82 <serial_putc_sub+0x18>
        delay();
c0101c79:	e8 4f fb ff ff       	call   c01017cd <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101c7e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0101c82:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101c88:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101c8c:	89 c2                	mov    %eax,%edx
c0101c8e:	ec                   	in     (%dx),%al
c0101c8f:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101c92:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101c96:	0f b6 c0             	movzbl %al,%eax
c0101c99:	83 e0 20             	and    $0x20,%eax
c0101c9c:	85 c0                	test   %eax,%eax
c0101c9e:	75 09                	jne    c0101ca9 <serial_putc_sub+0x3f>
c0101ca0:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101ca7:	7e d0                	jle    c0101c79 <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
c0101ca9:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cac:	0f b6 c0             	movzbl %al,%eax
c0101caf:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101cb5:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101cb8:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101cbc:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101cc0:	ee                   	out    %al,(%dx)
}
c0101cc1:	c9                   	leave  
c0101cc2:	c3                   	ret    

c0101cc3 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101cc3:	55                   	push   %ebp
c0101cc4:	89 e5                	mov    %esp,%ebp
c0101cc6:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101cc9:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101ccd:	74 0d                	je     c0101cdc <serial_putc+0x19>
        serial_putc_sub(c);
c0101ccf:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cd2:	89 04 24             	mov    %eax,(%esp)
c0101cd5:	e8 90 ff ff ff       	call   c0101c6a <serial_putc_sub>
c0101cda:	eb 24                	jmp    c0101d00 <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
c0101cdc:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101ce3:	e8 82 ff ff ff       	call   c0101c6a <serial_putc_sub>
        serial_putc_sub(' ');
c0101ce8:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101cef:	e8 76 ff ff ff       	call   c0101c6a <serial_putc_sub>
        serial_putc_sub('\b');
c0101cf4:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101cfb:	e8 6a ff ff ff       	call   c0101c6a <serial_putc_sub>
    }
}
c0101d00:	c9                   	leave  
c0101d01:	c3                   	ret    

c0101d02 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0101d02:	55                   	push   %ebp
c0101d03:	89 e5                	mov    %esp,%ebp
c0101d05:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0101d08:	eb 33                	jmp    c0101d3d <cons_intr+0x3b>
        if (c != 0) {
c0101d0a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101d0e:	74 2d                	je     c0101d3d <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c0101d10:	a1 44 e7 19 c0       	mov    0xc019e744,%eax
c0101d15:	8d 50 01             	lea    0x1(%eax),%edx
c0101d18:	89 15 44 e7 19 c0    	mov    %edx,0xc019e744
c0101d1e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101d21:	88 90 40 e5 19 c0    	mov    %dl,-0x3fe61ac0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0101d27:	a1 44 e7 19 c0       	mov    0xc019e744,%eax
c0101d2c:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101d31:	75 0a                	jne    c0101d3d <cons_intr+0x3b>
                cons.wpos = 0;
c0101d33:	c7 05 44 e7 19 c0 00 	movl   $0x0,0xc019e744
c0101d3a:	00 00 00 
    while ((c = (*proc)()) != -1) {
c0101d3d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d40:	ff d0                	call   *%eax
c0101d42:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101d45:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0101d49:	75 bf                	jne    c0101d0a <cons_intr+0x8>
            }
        }
    }
}
c0101d4b:	c9                   	leave  
c0101d4c:	c3                   	ret    

c0101d4d <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c0101d4d:	55                   	push   %ebp
c0101d4e:	89 e5                	mov    %esp,%ebp
c0101d50:	83 ec 10             	sub    $0x10,%esp
c0101d53:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101d59:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101d5d:	89 c2                	mov    %eax,%edx
c0101d5f:	ec                   	in     (%dx),%al
c0101d60:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101d63:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c0101d67:	0f b6 c0             	movzbl %al,%eax
c0101d6a:	83 e0 01             	and    $0x1,%eax
c0101d6d:	85 c0                	test   %eax,%eax
c0101d6f:	75 07                	jne    c0101d78 <serial_proc_data+0x2b>
        return -1;
c0101d71:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101d76:	eb 2a                	jmp    c0101da2 <serial_proc_data+0x55>
c0101d78:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101d7e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101d82:	89 c2                	mov    %eax,%edx
c0101d84:	ec                   	in     (%dx),%al
c0101d85:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c0101d88:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c0101d8c:	0f b6 c0             	movzbl %al,%eax
c0101d8f:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0101d92:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101d96:	75 07                	jne    c0101d9f <serial_proc_data+0x52>
        c = '\b';
c0101d98:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101d9f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101da2:	c9                   	leave  
c0101da3:	c3                   	ret    

c0101da4 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101da4:	55                   	push   %ebp
c0101da5:	89 e5                	mov    %esp,%ebp
c0101da7:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c0101daa:	a1 28 e5 19 c0       	mov    0xc019e528,%eax
c0101daf:	85 c0                	test   %eax,%eax
c0101db1:	74 0c                	je     c0101dbf <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c0101db3:	c7 04 24 4d 1d 10 c0 	movl   $0xc0101d4d,(%esp)
c0101dba:	e8 43 ff ff ff       	call   c0101d02 <cons_intr>
    }
}
c0101dbf:	c9                   	leave  
c0101dc0:	c3                   	ret    

c0101dc1 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101dc1:	55                   	push   %ebp
c0101dc2:	89 e5                	mov    %esp,%ebp
c0101dc4:	83 ec 38             	sub    $0x38,%esp
c0101dc7:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101dcd:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101dd1:	89 c2                	mov    %eax,%edx
c0101dd3:	ec                   	in     (%dx),%al
c0101dd4:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c0101dd7:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c0101ddb:	0f b6 c0             	movzbl %al,%eax
c0101dde:	83 e0 01             	and    $0x1,%eax
c0101de1:	85 c0                	test   %eax,%eax
c0101de3:	75 0a                	jne    c0101def <kbd_proc_data+0x2e>
        return -1;
c0101de5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101dea:	e9 59 01 00 00       	jmp    c0101f48 <kbd_proc_data+0x187>
c0101def:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101df5:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101df9:	89 c2                	mov    %eax,%edx
c0101dfb:	ec                   	in     (%dx),%al
c0101dfc:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101dff:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101e03:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101e06:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c0101e0a:	75 17                	jne    c0101e23 <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
c0101e0c:	a1 48 e7 19 c0       	mov    0xc019e748,%eax
c0101e11:	83 c8 40             	or     $0x40,%eax
c0101e14:	a3 48 e7 19 c0       	mov    %eax,0xc019e748
        return 0;
c0101e19:	b8 00 00 00 00       	mov    $0x0,%eax
c0101e1e:	e9 25 01 00 00       	jmp    c0101f48 <kbd_proc_data+0x187>
    } else if (data & 0x80) {
c0101e23:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101e27:	84 c0                	test   %al,%al
c0101e29:	79 47                	jns    c0101e72 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c0101e2b:	a1 48 e7 19 c0       	mov    0xc019e748,%eax
c0101e30:	83 e0 40             	and    $0x40,%eax
c0101e33:	85 c0                	test   %eax,%eax
c0101e35:	75 09                	jne    c0101e40 <kbd_proc_data+0x7f>
c0101e37:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101e3b:	83 e0 7f             	and    $0x7f,%eax
c0101e3e:	eb 04                	jmp    c0101e44 <kbd_proc_data+0x83>
c0101e40:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101e44:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c0101e47:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101e4b:	0f b6 80 40 a0 12 c0 	movzbl -0x3fed5fc0(%eax),%eax
c0101e52:	83 c8 40             	or     $0x40,%eax
c0101e55:	0f b6 c0             	movzbl %al,%eax
c0101e58:	f7 d0                	not    %eax
c0101e5a:	89 c2                	mov    %eax,%edx
c0101e5c:	a1 48 e7 19 c0       	mov    0xc019e748,%eax
c0101e61:	21 d0                	and    %edx,%eax
c0101e63:	a3 48 e7 19 c0       	mov    %eax,0xc019e748
        return 0;
c0101e68:	b8 00 00 00 00       	mov    $0x0,%eax
c0101e6d:	e9 d6 00 00 00       	jmp    c0101f48 <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
c0101e72:	a1 48 e7 19 c0       	mov    0xc019e748,%eax
c0101e77:	83 e0 40             	and    $0x40,%eax
c0101e7a:	85 c0                	test   %eax,%eax
c0101e7c:	74 11                	je     c0101e8f <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c0101e7e:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0101e82:	a1 48 e7 19 c0       	mov    0xc019e748,%eax
c0101e87:	83 e0 bf             	and    $0xffffffbf,%eax
c0101e8a:	a3 48 e7 19 c0       	mov    %eax,0xc019e748
    }

    shift |= shiftcode[data];
c0101e8f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101e93:	0f b6 80 40 a0 12 c0 	movzbl -0x3fed5fc0(%eax),%eax
c0101e9a:	0f b6 d0             	movzbl %al,%edx
c0101e9d:	a1 48 e7 19 c0       	mov    0xc019e748,%eax
c0101ea2:	09 d0                	or     %edx,%eax
c0101ea4:	a3 48 e7 19 c0       	mov    %eax,0xc019e748
    shift ^= togglecode[data];
c0101ea9:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101ead:	0f b6 80 40 a1 12 c0 	movzbl -0x3fed5ec0(%eax),%eax
c0101eb4:	0f b6 d0             	movzbl %al,%edx
c0101eb7:	a1 48 e7 19 c0       	mov    0xc019e748,%eax
c0101ebc:	31 d0                	xor    %edx,%eax
c0101ebe:	a3 48 e7 19 c0       	mov    %eax,0xc019e748

    c = charcode[shift & (CTL | SHIFT)][data];
c0101ec3:	a1 48 e7 19 c0       	mov    0xc019e748,%eax
c0101ec8:	83 e0 03             	and    $0x3,%eax
c0101ecb:	8b 14 85 40 a5 12 c0 	mov    -0x3fed5ac0(,%eax,4),%edx
c0101ed2:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101ed6:	01 d0                	add    %edx,%eax
c0101ed8:	0f b6 00             	movzbl (%eax),%eax
c0101edb:	0f b6 c0             	movzbl %al,%eax
c0101ede:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101ee1:	a1 48 e7 19 c0       	mov    0xc019e748,%eax
c0101ee6:	83 e0 08             	and    $0x8,%eax
c0101ee9:	85 c0                	test   %eax,%eax
c0101eeb:	74 22                	je     c0101f0f <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c0101eed:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101ef1:	7e 0c                	jle    c0101eff <kbd_proc_data+0x13e>
c0101ef3:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101ef7:	7f 06                	jg     c0101eff <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c0101ef9:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c0101efd:	eb 10                	jmp    c0101f0f <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c0101eff:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101f03:	7e 0a                	jle    c0101f0f <kbd_proc_data+0x14e>
c0101f05:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c0101f09:	7f 04                	jg     c0101f0f <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c0101f0b:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c0101f0f:	a1 48 e7 19 c0       	mov    0xc019e748,%eax
c0101f14:	f7 d0                	not    %eax
c0101f16:	83 e0 06             	and    $0x6,%eax
c0101f19:	85 c0                	test   %eax,%eax
c0101f1b:	75 28                	jne    c0101f45 <kbd_proc_data+0x184>
c0101f1d:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101f24:	75 1f                	jne    c0101f45 <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
c0101f26:	c7 04 24 99 c2 10 c0 	movl   $0xc010c299,(%esp)
c0101f2d:	e8 77 e3 ff ff       	call   c01002a9 <cprintf>
c0101f32:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c0101f38:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101f3c:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c0101f40:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c0101f44:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c0101f45:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101f48:	c9                   	leave  
c0101f49:	c3                   	ret    

c0101f4a <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c0101f4a:	55                   	push   %ebp
c0101f4b:	89 e5                	mov    %esp,%ebp
c0101f4d:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c0101f50:	c7 04 24 c1 1d 10 c0 	movl   $0xc0101dc1,(%esp)
c0101f57:	e8 a6 fd ff ff       	call   c0101d02 <cons_intr>
}
c0101f5c:	c9                   	leave  
c0101f5d:	c3                   	ret    

c0101f5e <kbd_init>:

static void
kbd_init(void) {
c0101f5e:	55                   	push   %ebp
c0101f5f:	89 e5                	mov    %esp,%ebp
c0101f61:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c0101f64:	e8 e1 ff ff ff       	call   c0101f4a <kbd_intr>
    pic_enable(IRQ_KBD);
c0101f69:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0101f70:	e8 31 01 00 00       	call   c01020a6 <pic_enable>
}
c0101f75:	c9                   	leave  
c0101f76:	c3                   	ret    

c0101f77 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c0101f77:	55                   	push   %ebp
c0101f78:	89 e5                	mov    %esp,%ebp
c0101f7a:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c0101f7d:	e8 93 f8 ff ff       	call   c0101815 <cga_init>
    serial_init();
c0101f82:	e8 74 f9 ff ff       	call   c01018fb <serial_init>
    kbd_init();
c0101f87:	e8 d2 ff ff ff       	call   c0101f5e <kbd_init>
    if (!serial_exists) {
c0101f8c:	a1 28 e5 19 c0       	mov    0xc019e528,%eax
c0101f91:	85 c0                	test   %eax,%eax
c0101f93:	75 0c                	jne    c0101fa1 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c0101f95:	c7 04 24 a5 c2 10 c0 	movl   $0xc010c2a5,(%esp)
c0101f9c:	e8 08 e3 ff ff       	call   c01002a9 <cprintf>
    }
}
c0101fa1:	c9                   	leave  
c0101fa2:	c3                   	ret    

c0101fa3 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0101fa3:	55                   	push   %ebp
c0101fa4:	89 e5                	mov    %esp,%ebp
c0101fa6:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0101fa9:	e8 e2 f7 ff ff       	call   c0101790 <__intr_save>
c0101fae:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101fb1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101fb4:	89 04 24             	mov    %eax,(%esp)
c0101fb7:	e8 9b fa ff ff       	call   c0101a57 <lpt_putc>
        cga_putc(c);
c0101fbc:	8b 45 08             	mov    0x8(%ebp),%eax
c0101fbf:	89 04 24             	mov    %eax,(%esp)
c0101fc2:	e8 cf fa ff ff       	call   c0101a96 <cga_putc>
        serial_putc(c);
c0101fc7:	8b 45 08             	mov    0x8(%ebp),%eax
c0101fca:	89 04 24             	mov    %eax,(%esp)
c0101fcd:	e8 f1 fc ff ff       	call   c0101cc3 <serial_putc>
    }
    local_intr_restore(intr_flag);
c0101fd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101fd5:	89 04 24             	mov    %eax,(%esp)
c0101fd8:	e8 dd f7 ff ff       	call   c01017ba <__intr_restore>
}
c0101fdd:	c9                   	leave  
c0101fde:	c3                   	ret    

c0101fdf <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0101fdf:	55                   	push   %ebp
c0101fe0:	89 e5                	mov    %esp,%ebp
c0101fe2:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c0101fe5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0101fec:	e8 9f f7 ff ff       	call   c0101790 <__intr_save>
c0101ff1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101ff4:	e8 ab fd ff ff       	call   c0101da4 <serial_intr>
        kbd_intr();
c0101ff9:	e8 4c ff ff ff       	call   c0101f4a <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0101ffe:	8b 15 40 e7 19 c0    	mov    0xc019e740,%edx
c0102004:	a1 44 e7 19 c0       	mov    0xc019e744,%eax
c0102009:	39 c2                	cmp    %eax,%edx
c010200b:	74 31                	je     c010203e <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c010200d:	a1 40 e7 19 c0       	mov    0xc019e740,%eax
c0102012:	8d 50 01             	lea    0x1(%eax),%edx
c0102015:	89 15 40 e7 19 c0    	mov    %edx,0xc019e740
c010201b:	0f b6 80 40 e5 19 c0 	movzbl -0x3fe61ac0(%eax),%eax
c0102022:	0f b6 c0             	movzbl %al,%eax
c0102025:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c0102028:	a1 40 e7 19 c0       	mov    0xc019e740,%eax
c010202d:	3d 00 02 00 00       	cmp    $0x200,%eax
c0102032:	75 0a                	jne    c010203e <cons_getc+0x5f>
                cons.rpos = 0;
c0102034:	c7 05 40 e7 19 c0 00 	movl   $0x0,0xc019e740
c010203b:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c010203e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102041:	89 04 24             	mov    %eax,(%esp)
c0102044:	e8 71 f7 ff ff       	call   c01017ba <__intr_restore>
    return c;
c0102049:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010204c:	c9                   	leave  
c010204d:	c3                   	ret    

c010204e <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c010204e:	55                   	push   %ebp
c010204f:	89 e5                	mov    %esp,%ebp
c0102051:	83 ec 14             	sub    $0x14,%esp
c0102054:	8b 45 08             	mov    0x8(%ebp),%eax
c0102057:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c010205b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c010205f:	66 a3 50 a5 12 c0    	mov    %ax,0xc012a550
    if (did_init) {
c0102065:	a1 4c e7 19 c0       	mov    0xc019e74c,%eax
c010206a:	85 c0                	test   %eax,%eax
c010206c:	74 36                	je     c01020a4 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c010206e:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0102072:	0f b6 c0             	movzbl %al,%eax
c0102075:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c010207b:	88 45 fd             	mov    %al,-0x3(%ebp)
c010207e:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0102082:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0102086:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c0102087:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c010208b:	66 c1 e8 08          	shr    $0x8,%ax
c010208f:	0f b6 c0             	movzbl %al,%eax
c0102092:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c0102098:	88 45 f9             	mov    %al,-0x7(%ebp)
c010209b:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010209f:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c01020a3:	ee                   	out    %al,(%dx)
    }
}
c01020a4:	c9                   	leave  
c01020a5:	c3                   	ret    

c01020a6 <pic_enable>:

void
pic_enable(unsigned int irq) {
c01020a6:	55                   	push   %ebp
c01020a7:	89 e5                	mov    %esp,%ebp
c01020a9:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c01020ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01020af:	ba 01 00 00 00       	mov    $0x1,%edx
c01020b4:	89 c1                	mov    %eax,%ecx
c01020b6:	d3 e2                	shl    %cl,%edx
c01020b8:	89 d0                	mov    %edx,%eax
c01020ba:	f7 d0                	not    %eax
c01020bc:	89 c2                	mov    %eax,%edx
c01020be:	0f b7 05 50 a5 12 c0 	movzwl 0xc012a550,%eax
c01020c5:	21 d0                	and    %edx,%eax
c01020c7:	0f b7 c0             	movzwl %ax,%eax
c01020ca:	89 04 24             	mov    %eax,(%esp)
c01020cd:	e8 7c ff ff ff       	call   c010204e <pic_setmask>
}
c01020d2:	c9                   	leave  
c01020d3:	c3                   	ret    

c01020d4 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c01020d4:	55                   	push   %ebp
c01020d5:	89 e5                	mov    %esp,%ebp
c01020d7:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c01020da:	c7 05 4c e7 19 c0 01 	movl   $0x1,0xc019e74c
c01020e1:	00 00 00 
c01020e4:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c01020ea:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
c01020ee:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c01020f2:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c01020f6:	ee                   	out    %al,(%dx)
c01020f7:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c01020fd:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
c0102101:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0102105:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0102109:	ee                   	out    %al,(%dx)
c010210a:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c0102110:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
c0102114:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0102118:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010211c:	ee                   	out    %al,(%dx)
c010211d:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
c0102123:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
c0102127:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010212b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010212f:	ee                   	out    %al,(%dx)
c0102130:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
c0102136:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
c010213a:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010213e:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0102142:	ee                   	out    %al,(%dx)
c0102143:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
c0102149:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
c010214d:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0102151:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0102155:	ee                   	out    %al,(%dx)
c0102156:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c010215c:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
c0102160:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0102164:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0102168:	ee                   	out    %al,(%dx)
c0102169:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
c010216f:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
c0102173:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0102177:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c010217b:	ee                   	out    %al,(%dx)
c010217c:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
c0102182:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
c0102186:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c010218a:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c010218e:	ee                   	out    %al,(%dx)
c010218f:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
c0102195:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
c0102199:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c010219d:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c01021a1:	ee                   	out    %al,(%dx)
c01021a2:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
c01021a8:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
c01021ac:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c01021b0:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c01021b4:	ee                   	out    %al,(%dx)
c01021b5:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c01021bb:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
c01021bf:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c01021c3:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c01021c7:	ee                   	out    %al,(%dx)
c01021c8:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
c01021ce:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
c01021d2:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c01021d6:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c01021da:	ee                   	out    %al,(%dx)
c01021db:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
c01021e1:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
c01021e5:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c01021e9:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c01021ed:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c01021ee:	0f b7 05 50 a5 12 c0 	movzwl 0xc012a550,%eax
c01021f5:	66 83 f8 ff          	cmp    $0xffff,%ax
c01021f9:	74 12                	je     c010220d <pic_init+0x139>
        pic_setmask(irq_mask);
c01021fb:	0f b7 05 50 a5 12 c0 	movzwl 0xc012a550,%eax
c0102202:	0f b7 c0             	movzwl %ax,%eax
c0102205:	89 04 24             	mov    %eax,(%esp)
c0102208:	e8 41 fe ff ff       	call   c010204e <pic_setmask>
    }
}
c010220d:	c9                   	leave  
c010220e:	c3                   	ret    

c010220f <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c010220f:	55                   	push   %ebp
c0102210:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
c0102212:	fb                   	sti    
    sti();
}
c0102213:	5d                   	pop    %ebp
c0102214:	c3                   	ret    

c0102215 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c0102215:	55                   	push   %ebp
c0102216:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
c0102218:	fa                   	cli    
    cli();
}
c0102219:	5d                   	pop    %ebp
c010221a:	c3                   	ret    

c010221b <print_ticks>:
#include <sched.h>
#include <sync.h>

#define TICK_NUM 100

static void print_ticks() {
c010221b:	55                   	push   %ebp
c010221c:	89 e5                	mov    %esp,%ebp
c010221e:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c0102221:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0102228:	00 
c0102229:	c7 04 24 e0 c2 10 c0 	movl   $0xc010c2e0,(%esp)
c0102230:	e8 74 e0 ff ff       	call   c01002a9 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
c0102235:	c7 04 24 ea c2 10 c0 	movl   $0xc010c2ea,(%esp)
c010223c:	e8 68 e0 ff ff       	call   c01002a9 <cprintf>
    panic("EOT: kernel seems ok.");
c0102241:	c7 44 24 08 f8 c2 10 	movl   $0xc010c2f8,0x8(%esp)
c0102248:	c0 
c0102249:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
c0102250:	00 
c0102251:	c7 04 24 0e c3 10 c0 	movl   $0xc010c30e,(%esp)
c0102258:	e8 a3 e1 ff ff       	call   c0100400 <__panic>

c010225d <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c010225d:	55                   	push   %ebp
c010225e:	89 e5                	mov    %esp,%ebp
c0102260:	83 ec 10             	sub    $0x10,%esp
     /* LAB5 YOUR CODE */ 
     //you should update your lab1 code (just add ONE or TWO lines of code), let user app to use syscall to get the service of ucore
     //so you should setup the syscall interrupt gate in here
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c0102263:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010226a:	e9 c3 00 00 00       	jmp    c0102332 <idt_init+0xd5>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c010226f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102272:	8b 04 85 e0 a5 12 c0 	mov    -0x3fed5a20(,%eax,4),%eax
c0102279:	89 c2                	mov    %eax,%edx
c010227b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010227e:	66 89 14 c5 60 e7 19 	mov    %dx,-0x3fe618a0(,%eax,8)
c0102285:	c0 
c0102286:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102289:	66 c7 04 c5 62 e7 19 	movw   $0x8,-0x3fe6189e(,%eax,8)
c0102290:	c0 08 00 
c0102293:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102296:	0f b6 14 c5 64 e7 19 	movzbl -0x3fe6189c(,%eax,8),%edx
c010229d:	c0 
c010229e:	83 e2 e0             	and    $0xffffffe0,%edx
c01022a1:	88 14 c5 64 e7 19 c0 	mov    %dl,-0x3fe6189c(,%eax,8)
c01022a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022ab:	0f b6 14 c5 64 e7 19 	movzbl -0x3fe6189c(,%eax,8),%edx
c01022b2:	c0 
c01022b3:	83 e2 1f             	and    $0x1f,%edx
c01022b6:	88 14 c5 64 e7 19 c0 	mov    %dl,-0x3fe6189c(,%eax,8)
c01022bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022c0:	0f b6 14 c5 65 e7 19 	movzbl -0x3fe6189b(,%eax,8),%edx
c01022c7:	c0 
c01022c8:	83 e2 f0             	and    $0xfffffff0,%edx
c01022cb:	83 ca 0e             	or     $0xe,%edx
c01022ce:	88 14 c5 65 e7 19 c0 	mov    %dl,-0x3fe6189b(,%eax,8)
c01022d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022d8:	0f b6 14 c5 65 e7 19 	movzbl -0x3fe6189b(,%eax,8),%edx
c01022df:	c0 
c01022e0:	83 e2 ef             	and    $0xffffffef,%edx
c01022e3:	88 14 c5 65 e7 19 c0 	mov    %dl,-0x3fe6189b(,%eax,8)
c01022ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022ed:	0f b6 14 c5 65 e7 19 	movzbl -0x3fe6189b(,%eax,8),%edx
c01022f4:	c0 
c01022f5:	83 e2 9f             	and    $0xffffff9f,%edx
c01022f8:	88 14 c5 65 e7 19 c0 	mov    %dl,-0x3fe6189b(,%eax,8)
c01022ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102302:	0f b6 14 c5 65 e7 19 	movzbl -0x3fe6189b(,%eax,8),%edx
c0102309:	c0 
c010230a:	83 ca 80             	or     $0xffffff80,%edx
c010230d:	88 14 c5 65 e7 19 c0 	mov    %dl,-0x3fe6189b(,%eax,8)
c0102314:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102317:	8b 04 85 e0 a5 12 c0 	mov    -0x3fed5a20(,%eax,4),%eax
c010231e:	c1 e8 10             	shr    $0x10,%eax
c0102321:	89 c2                	mov    %eax,%edx
c0102323:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102326:	66 89 14 c5 66 e7 19 	mov    %dx,-0x3fe6189a(,%eax,8)
c010232d:	c0 
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c010232e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0102332:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102335:	3d ff 00 00 00       	cmp    $0xff,%eax
c010233a:	0f 86 2f ff ff ff    	jbe    c010226f <idt_init+0x12>
    }
    SETGATE(idt[T_SYSCALL], 1, GD_KTEXT, __vectors[T_SYSCALL], DPL_USER);
c0102340:	a1 e0 a7 12 c0       	mov    0xc012a7e0,%eax
c0102345:	66 a3 60 eb 19 c0    	mov    %ax,0xc019eb60
c010234b:	66 c7 05 62 eb 19 c0 	movw   $0x8,0xc019eb62
c0102352:	08 00 
c0102354:	0f b6 05 64 eb 19 c0 	movzbl 0xc019eb64,%eax
c010235b:	83 e0 e0             	and    $0xffffffe0,%eax
c010235e:	a2 64 eb 19 c0       	mov    %al,0xc019eb64
c0102363:	0f b6 05 64 eb 19 c0 	movzbl 0xc019eb64,%eax
c010236a:	83 e0 1f             	and    $0x1f,%eax
c010236d:	a2 64 eb 19 c0       	mov    %al,0xc019eb64
c0102372:	0f b6 05 65 eb 19 c0 	movzbl 0xc019eb65,%eax
c0102379:	83 c8 0f             	or     $0xf,%eax
c010237c:	a2 65 eb 19 c0       	mov    %al,0xc019eb65
c0102381:	0f b6 05 65 eb 19 c0 	movzbl 0xc019eb65,%eax
c0102388:	83 e0 ef             	and    $0xffffffef,%eax
c010238b:	a2 65 eb 19 c0       	mov    %al,0xc019eb65
c0102390:	0f b6 05 65 eb 19 c0 	movzbl 0xc019eb65,%eax
c0102397:	83 c8 60             	or     $0x60,%eax
c010239a:	a2 65 eb 19 c0       	mov    %al,0xc019eb65
c010239f:	0f b6 05 65 eb 19 c0 	movzbl 0xc019eb65,%eax
c01023a6:	83 c8 80             	or     $0xffffff80,%eax
c01023a9:	a2 65 eb 19 c0       	mov    %al,0xc019eb65
c01023ae:	a1 e0 a7 12 c0       	mov    0xc012a7e0,%eax
c01023b3:	c1 e8 10             	shr    $0x10,%eax
c01023b6:	66 a3 66 eb 19 c0    	mov    %ax,0xc019eb66
c01023bc:	c7 45 f8 60 a5 12 c0 	movl   $0xc012a560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c01023c3:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01023c6:	0f 01 18             	lidtl  (%eax)
    lidt(&idt_pd);
}
c01023c9:	c9                   	leave  
c01023ca:	c3                   	ret    

c01023cb <trapname>:

static const char *
trapname(int trapno) {
c01023cb:	55                   	push   %ebp
c01023cc:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c01023ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01023d1:	83 f8 13             	cmp    $0x13,%eax
c01023d4:	77 0c                	ja     c01023e2 <trapname+0x17>
        return excnames[trapno];
c01023d6:	8b 45 08             	mov    0x8(%ebp),%eax
c01023d9:	8b 04 85 a0 c7 10 c0 	mov    -0x3fef3860(,%eax,4),%eax
c01023e0:	eb 18                	jmp    c01023fa <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c01023e2:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c01023e6:	7e 0d                	jle    c01023f5 <trapname+0x2a>
c01023e8:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c01023ec:	7f 07                	jg     c01023f5 <trapname+0x2a>
        return "Hardware Interrupt";
c01023ee:	b8 1f c3 10 c0       	mov    $0xc010c31f,%eax
c01023f3:	eb 05                	jmp    c01023fa <trapname+0x2f>
    }
    return "(unknown trap)";
c01023f5:	b8 32 c3 10 c0       	mov    $0xc010c332,%eax
}
c01023fa:	5d                   	pop    %ebp
c01023fb:	c3                   	ret    

c01023fc <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c01023fc:	55                   	push   %ebp
c01023fd:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c01023ff:	8b 45 08             	mov    0x8(%ebp),%eax
c0102402:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102406:	66 83 f8 08          	cmp    $0x8,%ax
c010240a:	0f 94 c0             	sete   %al
c010240d:	0f b6 c0             	movzbl %al,%eax
}
c0102410:	5d                   	pop    %ebp
c0102411:	c3                   	ret    

c0102412 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0102412:	55                   	push   %ebp
c0102413:	89 e5                	mov    %esp,%ebp
c0102415:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c0102418:	8b 45 08             	mov    0x8(%ebp),%eax
c010241b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010241f:	c7 04 24 73 c3 10 c0 	movl   $0xc010c373,(%esp)
c0102426:	e8 7e de ff ff       	call   c01002a9 <cprintf>
    print_regs(&tf->tf_regs);
c010242b:	8b 45 08             	mov    0x8(%ebp),%eax
c010242e:	89 04 24             	mov    %eax,(%esp)
c0102431:	e8 a1 01 00 00       	call   c01025d7 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0102436:	8b 45 08             	mov    0x8(%ebp),%eax
c0102439:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c010243d:	0f b7 c0             	movzwl %ax,%eax
c0102440:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102444:	c7 04 24 84 c3 10 c0 	movl   $0xc010c384,(%esp)
c010244b:	e8 59 de ff ff       	call   c01002a9 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0102450:	8b 45 08             	mov    0x8(%ebp),%eax
c0102453:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0102457:	0f b7 c0             	movzwl %ax,%eax
c010245a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010245e:	c7 04 24 97 c3 10 c0 	movl   $0xc010c397,(%esp)
c0102465:	e8 3f de ff ff       	call   c01002a9 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c010246a:	8b 45 08             	mov    0x8(%ebp),%eax
c010246d:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0102471:	0f b7 c0             	movzwl %ax,%eax
c0102474:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102478:	c7 04 24 aa c3 10 c0 	movl   $0xc010c3aa,(%esp)
c010247f:	e8 25 de ff ff       	call   c01002a9 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0102484:	8b 45 08             	mov    0x8(%ebp),%eax
c0102487:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c010248b:	0f b7 c0             	movzwl %ax,%eax
c010248e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102492:	c7 04 24 bd c3 10 c0 	movl   $0xc010c3bd,(%esp)
c0102499:	e8 0b de ff ff       	call   c01002a9 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c010249e:	8b 45 08             	mov    0x8(%ebp),%eax
c01024a1:	8b 40 30             	mov    0x30(%eax),%eax
c01024a4:	89 04 24             	mov    %eax,(%esp)
c01024a7:	e8 1f ff ff ff       	call   c01023cb <trapname>
c01024ac:	8b 55 08             	mov    0x8(%ebp),%edx
c01024af:	8b 52 30             	mov    0x30(%edx),%edx
c01024b2:	89 44 24 08          	mov    %eax,0x8(%esp)
c01024b6:	89 54 24 04          	mov    %edx,0x4(%esp)
c01024ba:	c7 04 24 d0 c3 10 c0 	movl   $0xc010c3d0,(%esp)
c01024c1:	e8 e3 dd ff ff       	call   c01002a9 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c01024c6:	8b 45 08             	mov    0x8(%ebp),%eax
c01024c9:	8b 40 34             	mov    0x34(%eax),%eax
c01024cc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024d0:	c7 04 24 e2 c3 10 c0 	movl   $0xc010c3e2,(%esp)
c01024d7:	e8 cd dd ff ff       	call   c01002a9 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c01024dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01024df:	8b 40 38             	mov    0x38(%eax),%eax
c01024e2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024e6:	c7 04 24 f1 c3 10 c0 	movl   $0xc010c3f1,(%esp)
c01024ed:	e8 b7 dd ff ff       	call   c01002a9 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c01024f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01024f5:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01024f9:	0f b7 c0             	movzwl %ax,%eax
c01024fc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102500:	c7 04 24 00 c4 10 c0 	movl   $0xc010c400,(%esp)
c0102507:	e8 9d dd ff ff       	call   c01002a9 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c010250c:	8b 45 08             	mov    0x8(%ebp),%eax
c010250f:	8b 40 40             	mov    0x40(%eax),%eax
c0102512:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102516:	c7 04 24 13 c4 10 c0 	movl   $0xc010c413,(%esp)
c010251d:	e8 87 dd ff ff       	call   c01002a9 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0102522:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0102529:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0102530:	eb 3e                	jmp    c0102570 <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0102532:	8b 45 08             	mov    0x8(%ebp),%eax
c0102535:	8b 50 40             	mov    0x40(%eax),%edx
c0102538:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010253b:	21 d0                	and    %edx,%eax
c010253d:	85 c0                	test   %eax,%eax
c010253f:	74 28                	je     c0102569 <print_trapframe+0x157>
c0102541:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102544:	8b 04 85 80 a5 12 c0 	mov    -0x3fed5a80(,%eax,4),%eax
c010254b:	85 c0                	test   %eax,%eax
c010254d:	74 1a                	je     c0102569 <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
c010254f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102552:	8b 04 85 80 a5 12 c0 	mov    -0x3fed5a80(,%eax,4),%eax
c0102559:	89 44 24 04          	mov    %eax,0x4(%esp)
c010255d:	c7 04 24 22 c4 10 c0 	movl   $0xc010c422,(%esp)
c0102564:	e8 40 dd ff ff       	call   c01002a9 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0102569:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010256d:	d1 65 f0             	shll   -0x10(%ebp)
c0102570:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102573:	83 f8 17             	cmp    $0x17,%eax
c0102576:	76 ba                	jbe    c0102532 <print_trapframe+0x120>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0102578:	8b 45 08             	mov    0x8(%ebp),%eax
c010257b:	8b 40 40             	mov    0x40(%eax),%eax
c010257e:	25 00 30 00 00       	and    $0x3000,%eax
c0102583:	c1 e8 0c             	shr    $0xc,%eax
c0102586:	89 44 24 04          	mov    %eax,0x4(%esp)
c010258a:	c7 04 24 26 c4 10 c0 	movl   $0xc010c426,(%esp)
c0102591:	e8 13 dd ff ff       	call   c01002a9 <cprintf>

    if (!trap_in_kernel(tf)) {
c0102596:	8b 45 08             	mov    0x8(%ebp),%eax
c0102599:	89 04 24             	mov    %eax,(%esp)
c010259c:	e8 5b fe ff ff       	call   c01023fc <trap_in_kernel>
c01025a1:	85 c0                	test   %eax,%eax
c01025a3:	75 30                	jne    c01025d5 <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c01025a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01025a8:	8b 40 44             	mov    0x44(%eax),%eax
c01025ab:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025af:	c7 04 24 2f c4 10 c0 	movl   $0xc010c42f,(%esp)
c01025b6:	e8 ee dc ff ff       	call   c01002a9 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c01025bb:	8b 45 08             	mov    0x8(%ebp),%eax
c01025be:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c01025c2:	0f b7 c0             	movzwl %ax,%eax
c01025c5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025c9:	c7 04 24 3e c4 10 c0 	movl   $0xc010c43e,(%esp)
c01025d0:	e8 d4 dc ff ff       	call   c01002a9 <cprintf>
    }
}
c01025d5:	c9                   	leave  
c01025d6:	c3                   	ret    

c01025d7 <print_regs>:

void
print_regs(struct pushregs *regs) {
c01025d7:	55                   	push   %ebp
c01025d8:	89 e5                	mov    %esp,%ebp
c01025da:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c01025dd:	8b 45 08             	mov    0x8(%ebp),%eax
c01025e0:	8b 00                	mov    (%eax),%eax
c01025e2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025e6:	c7 04 24 51 c4 10 c0 	movl   $0xc010c451,(%esp)
c01025ed:	e8 b7 dc ff ff       	call   c01002a9 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c01025f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01025f5:	8b 40 04             	mov    0x4(%eax),%eax
c01025f8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025fc:	c7 04 24 60 c4 10 c0 	movl   $0xc010c460,(%esp)
c0102603:	e8 a1 dc ff ff       	call   c01002a9 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0102608:	8b 45 08             	mov    0x8(%ebp),%eax
c010260b:	8b 40 08             	mov    0x8(%eax),%eax
c010260e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102612:	c7 04 24 6f c4 10 c0 	movl   $0xc010c46f,(%esp)
c0102619:	e8 8b dc ff ff       	call   c01002a9 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c010261e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102621:	8b 40 0c             	mov    0xc(%eax),%eax
c0102624:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102628:	c7 04 24 7e c4 10 c0 	movl   $0xc010c47e,(%esp)
c010262f:	e8 75 dc ff ff       	call   c01002a9 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0102634:	8b 45 08             	mov    0x8(%ebp),%eax
c0102637:	8b 40 10             	mov    0x10(%eax),%eax
c010263a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010263e:	c7 04 24 8d c4 10 c0 	movl   $0xc010c48d,(%esp)
c0102645:	e8 5f dc ff ff       	call   c01002a9 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c010264a:	8b 45 08             	mov    0x8(%ebp),%eax
c010264d:	8b 40 14             	mov    0x14(%eax),%eax
c0102650:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102654:	c7 04 24 9c c4 10 c0 	movl   $0xc010c49c,(%esp)
c010265b:	e8 49 dc ff ff       	call   c01002a9 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0102660:	8b 45 08             	mov    0x8(%ebp),%eax
c0102663:	8b 40 18             	mov    0x18(%eax),%eax
c0102666:	89 44 24 04          	mov    %eax,0x4(%esp)
c010266a:	c7 04 24 ab c4 10 c0 	movl   $0xc010c4ab,(%esp)
c0102671:	e8 33 dc ff ff       	call   c01002a9 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0102676:	8b 45 08             	mov    0x8(%ebp),%eax
c0102679:	8b 40 1c             	mov    0x1c(%eax),%eax
c010267c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102680:	c7 04 24 ba c4 10 c0 	movl   $0xc010c4ba,(%esp)
c0102687:	e8 1d dc ff ff       	call   c01002a9 <cprintf>
}
c010268c:	c9                   	leave  
c010268d:	c3                   	ret    

c010268e <print_pgfault>:

static inline void
print_pgfault(struct trapframe *tf) {
c010268e:	55                   	push   %ebp
c010268f:	89 e5                	mov    %esp,%ebp
c0102691:	53                   	push   %ebx
c0102692:	83 ec 34             	sub    $0x34,%esp
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
c0102695:	8b 45 08             	mov    0x8(%ebp),%eax
c0102698:	8b 40 34             	mov    0x34(%eax),%eax
c010269b:	83 e0 01             	and    $0x1,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c010269e:	85 c0                	test   %eax,%eax
c01026a0:	74 07                	je     c01026a9 <print_pgfault+0x1b>
c01026a2:	b9 c9 c4 10 c0       	mov    $0xc010c4c9,%ecx
c01026a7:	eb 05                	jmp    c01026ae <print_pgfault+0x20>
c01026a9:	b9 da c4 10 c0       	mov    $0xc010c4da,%ecx
            (tf->tf_err & 2) ? 'W' : 'R',
c01026ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01026b1:	8b 40 34             	mov    0x34(%eax),%eax
c01026b4:	83 e0 02             	and    $0x2,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c01026b7:	85 c0                	test   %eax,%eax
c01026b9:	74 07                	je     c01026c2 <print_pgfault+0x34>
c01026bb:	ba 57 00 00 00       	mov    $0x57,%edx
c01026c0:	eb 05                	jmp    c01026c7 <print_pgfault+0x39>
c01026c2:	ba 52 00 00 00       	mov    $0x52,%edx
            (tf->tf_err & 4) ? 'U' : 'K',
c01026c7:	8b 45 08             	mov    0x8(%ebp),%eax
c01026ca:	8b 40 34             	mov    0x34(%eax),%eax
c01026cd:	83 e0 04             	and    $0x4,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c01026d0:	85 c0                	test   %eax,%eax
c01026d2:	74 07                	je     c01026db <print_pgfault+0x4d>
c01026d4:	b8 55 00 00 00       	mov    $0x55,%eax
c01026d9:	eb 05                	jmp    c01026e0 <print_pgfault+0x52>
c01026db:	b8 4b 00 00 00       	mov    $0x4b,%eax
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c01026e0:	0f 20 d3             	mov    %cr2,%ebx
c01026e3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
    return cr2;
c01026e6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
c01026e9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c01026ed:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01026f1:	89 44 24 08          	mov    %eax,0x8(%esp)
c01026f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01026f9:	c7 04 24 e8 c4 10 c0 	movl   $0xc010c4e8,(%esp)
c0102700:	e8 a4 db ff ff       	call   c01002a9 <cprintf>
}
c0102705:	83 c4 34             	add    $0x34,%esp
c0102708:	5b                   	pop    %ebx
c0102709:	5d                   	pop    %ebp
c010270a:	c3                   	ret    

c010270b <pgfault_handler>:

static int
pgfault_handler(struct trapframe *tf) {
c010270b:	55                   	push   %ebp
c010270c:	89 e5                	mov    %esp,%ebp
c010270e:	83 ec 28             	sub    $0x28,%esp
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
c0102711:	a1 58 10 1a c0       	mov    0xc01a1058,%eax
c0102716:	85 c0                	test   %eax,%eax
c0102718:	74 0b                	je     c0102725 <pgfault_handler+0x1a>
            print_pgfault(tf);
c010271a:	8b 45 08             	mov    0x8(%ebp),%eax
c010271d:	89 04 24             	mov    %eax,(%esp)
c0102720:	e8 69 ff ff ff       	call   c010268e <print_pgfault>
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
c0102725:	a1 58 10 1a c0       	mov    0xc01a1058,%eax
c010272a:	85 c0                	test   %eax,%eax
c010272c:	74 3d                	je     c010276b <pgfault_handler+0x60>
        assert(current == idleproc);
c010272e:	8b 15 28 f0 19 c0    	mov    0xc019f028,%edx
c0102734:	a1 20 f0 19 c0       	mov    0xc019f020,%eax
c0102739:	39 c2                	cmp    %eax,%edx
c010273b:	74 24                	je     c0102761 <pgfault_handler+0x56>
c010273d:	c7 44 24 0c 0b c5 10 	movl   $0xc010c50b,0xc(%esp)
c0102744:	c0 
c0102745:	c7 44 24 08 1f c5 10 	movl   $0xc010c51f,0x8(%esp)
c010274c:	c0 
c010274d:	c7 44 24 04 af 00 00 	movl   $0xaf,0x4(%esp)
c0102754:	00 
c0102755:	c7 04 24 0e c3 10 c0 	movl   $0xc010c30e,(%esp)
c010275c:	e8 9f dc ff ff       	call   c0100400 <__panic>
        mm = check_mm_struct;
c0102761:	a1 58 10 1a c0       	mov    0xc01a1058,%eax
c0102766:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102769:	eb 46                	jmp    c01027b1 <pgfault_handler+0xa6>
    }
    else {
        if (current == NULL) {
c010276b:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c0102770:	85 c0                	test   %eax,%eax
c0102772:	75 32                	jne    c01027a6 <pgfault_handler+0x9b>
            print_trapframe(tf);
c0102774:	8b 45 08             	mov    0x8(%ebp),%eax
c0102777:	89 04 24             	mov    %eax,(%esp)
c010277a:	e8 93 fc ff ff       	call   c0102412 <print_trapframe>
            print_pgfault(tf);
c010277f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102782:	89 04 24             	mov    %eax,(%esp)
c0102785:	e8 04 ff ff ff       	call   c010268e <print_pgfault>
            panic("unhandled page fault.\n");
c010278a:	c7 44 24 08 34 c5 10 	movl   $0xc010c534,0x8(%esp)
c0102791:	c0 
c0102792:	c7 44 24 04 b6 00 00 	movl   $0xb6,0x4(%esp)
c0102799:	00 
c010279a:	c7 04 24 0e c3 10 c0 	movl   $0xc010c30e,(%esp)
c01027a1:	e8 5a dc ff ff       	call   c0100400 <__panic>
        }
        mm = current->mm;
c01027a6:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c01027ab:	8b 40 18             	mov    0x18(%eax),%eax
c01027ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c01027b1:	0f 20 d0             	mov    %cr2,%eax
c01027b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr2;
c01027b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
    }
    return do_pgfault(mm, tf->tf_err, rcr2());
c01027ba:	89 c2                	mov    %eax,%edx
c01027bc:	8b 45 08             	mov    0x8(%ebp),%eax
c01027bf:	8b 40 34             	mov    0x34(%eax),%eax
c01027c2:	89 54 24 08          	mov    %edx,0x8(%esp)
c01027c6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01027ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01027cd:	89 04 24             	mov    %eax,(%esp)
c01027d0:	e8 a4 1c 00 00       	call   c0104479 <do_pgfault>
}
c01027d5:	c9                   	leave  
c01027d6:	c3                   	ret    

c01027d7 <trap_dispatch>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

static void
trap_dispatch(struct trapframe *tf) {
c01027d7:	55                   	push   %ebp
c01027d8:	89 e5                	mov    %esp,%ebp
c01027da:	83 ec 28             	sub    $0x28,%esp
    char c;

    int ret=0;
c01027dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    switch (tf->tf_trapno) {
c01027e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01027e7:	8b 40 30             	mov    0x30(%eax),%eax
c01027ea:	83 f8 2f             	cmp    $0x2f,%eax
c01027ed:	77 38                	ja     c0102827 <trap_dispatch+0x50>
c01027ef:	83 f8 2e             	cmp    $0x2e,%eax
c01027f2:	0f 83 32 02 00 00    	jae    c0102a2a <trap_dispatch+0x253>
c01027f8:	83 f8 20             	cmp    $0x20,%eax
c01027fb:	0f 84 07 01 00 00    	je     c0102908 <trap_dispatch+0x131>
c0102801:	83 f8 20             	cmp    $0x20,%eax
c0102804:	77 0a                	ja     c0102810 <trap_dispatch+0x39>
c0102806:	83 f8 0e             	cmp    $0xe,%eax
c0102809:	74 3e                	je     c0102849 <trap_dispatch+0x72>
c010280b:	e9 d2 01 00 00       	jmp    c01029e2 <trap_dispatch+0x20b>
c0102810:	83 f8 21             	cmp    $0x21,%eax
c0102813:	0f 84 87 01 00 00    	je     c01029a0 <trap_dispatch+0x1c9>
c0102819:	83 f8 24             	cmp    $0x24,%eax
c010281c:	0f 84 55 01 00 00    	je     c0102977 <trap_dispatch+0x1a0>
c0102822:	e9 bb 01 00 00       	jmp    c01029e2 <trap_dispatch+0x20b>
c0102827:	83 f8 78             	cmp    $0x78,%eax
c010282a:	0f 82 b2 01 00 00    	jb     c01029e2 <trap_dispatch+0x20b>
c0102830:	83 f8 79             	cmp    $0x79,%eax
c0102833:	0f 86 8d 01 00 00    	jbe    c01029c6 <trap_dispatch+0x1ef>
c0102839:	3d 80 00 00 00       	cmp    $0x80,%eax
c010283e:	0f 84 ba 00 00 00    	je     c01028fe <trap_dispatch+0x127>
c0102844:	e9 99 01 00 00       	jmp    c01029e2 <trap_dispatch+0x20b>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
c0102849:	8b 45 08             	mov    0x8(%ebp),%eax
c010284c:	89 04 24             	mov    %eax,(%esp)
c010284f:	e8 b7 fe ff ff       	call   c010270b <pgfault_handler>
c0102854:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102857:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010285b:	0f 84 98 00 00 00    	je     c01028f9 <trap_dispatch+0x122>
            print_trapframe(tf);
c0102861:	8b 45 08             	mov    0x8(%ebp),%eax
c0102864:	89 04 24             	mov    %eax,(%esp)
c0102867:	e8 a6 fb ff ff       	call   c0102412 <print_trapframe>
            if (current == NULL) {
c010286c:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c0102871:	85 c0                	test   %eax,%eax
c0102873:	75 23                	jne    c0102898 <trap_dispatch+0xc1>
                panic("handle pgfault failed. ret=%d\n", ret);
c0102875:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102878:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010287c:	c7 44 24 08 4c c5 10 	movl   $0xc010c54c,0x8(%esp)
c0102883:	c0 
c0102884:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c010288b:	00 
c010288c:	c7 04 24 0e c3 10 c0 	movl   $0xc010c30e,(%esp)
c0102893:	e8 68 db ff ff       	call   c0100400 <__panic>
            }
            else {
                if (trap_in_kernel(tf)) {
c0102898:	8b 45 08             	mov    0x8(%ebp),%eax
c010289b:	89 04 24             	mov    %eax,(%esp)
c010289e:	e8 59 fb ff ff       	call   c01023fc <trap_in_kernel>
c01028a3:	85 c0                	test   %eax,%eax
c01028a5:	74 23                	je     c01028ca <trap_dispatch+0xf3>
                    panic("handle pgfault failed in kernel mode. ret=%d\n", ret);
c01028a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01028aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01028ae:	c7 44 24 08 6c c5 10 	movl   $0xc010c56c,0x8(%esp)
c01028b5:	c0 
c01028b6:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
c01028bd:	00 
c01028be:	c7 04 24 0e c3 10 c0 	movl   $0xc010c30e,(%esp)
c01028c5:	e8 36 db ff ff       	call   c0100400 <__panic>
                }
                cprintf("killed by kernel.\n");
c01028ca:	c7 04 24 9a c5 10 c0 	movl   $0xc010c59a,(%esp)
c01028d1:	e8 d3 d9 ff ff       	call   c01002a9 <cprintf>
                panic("handle user mode pgfault failed. ret=%d\n", ret); 
c01028d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01028d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01028dd:	c7 44 24 08 b0 c5 10 	movl   $0xc010c5b0,0x8(%esp)
c01028e4:	c0 
c01028e5:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
c01028ec:	00 
c01028ed:	c7 04 24 0e c3 10 c0 	movl   $0xc010c30e,(%esp)
c01028f4:	e8 07 db ff ff       	call   c0100400 <__panic>
                do_exit(-E_KILLED);
            }
        }
        break;
c01028f9:	e9 2d 01 00 00       	jmp    c0102a2b <trap_dispatch+0x254>
    case T_SYSCALL:
        syscall();
c01028fe:	e8 5a 88 00 00       	call   c010b15d <syscall>
        break;
c0102903:	e9 23 01 00 00       	jmp    c0102a2b <trap_dispatch+0x254>
         */
        /* LAB5 YOUR CODE */
        /* you should upate you lab1 code (just add ONE or TWO lines of code):
         *    Every TICK_NUM cycle, you should set current process's current->need_resched = 1
         */
        ticks ++;
c0102908:	a1 54 10 1a c0       	mov    0xc01a1054,%eax
c010290d:	83 c0 01             	add    $0x1,%eax
c0102910:	a3 54 10 1a c0       	mov    %eax,0xc01a1054
        if (ticks % TICK_NUM == 0) {
c0102915:	8b 0d 54 10 1a c0    	mov    0xc01a1054,%ecx
c010291b:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0102920:	89 c8                	mov    %ecx,%eax
c0102922:	f7 e2                	mul    %edx
c0102924:	89 d0                	mov    %edx,%eax
c0102926:	c1 e8 05             	shr    $0x5,%eax
c0102929:	6b c0 64             	imul   $0x64,%eax,%eax
c010292c:	29 c1                	sub    %eax,%ecx
c010292e:	89 c8                	mov    %ecx,%eax
c0102930:	85 c0                	test   %eax,%eax
c0102932:	75 3e                	jne    c0102972 <trap_dispatch+0x19b>
            assert(current != NULL);
c0102934:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c0102939:	85 c0                	test   %eax,%eax
c010293b:	75 24                	jne    c0102961 <trap_dispatch+0x18a>
c010293d:	c7 44 24 0c d9 c5 10 	movl   $0xc010c5d9,0xc(%esp)
c0102944:	c0 
c0102945:	c7 44 24 08 1f c5 10 	movl   $0xc010c51f,0x8(%esp)
c010294c:	c0 
c010294d:	c7 44 24 04 eb 00 00 	movl   $0xeb,0x4(%esp)
c0102954:	00 
c0102955:	c7 04 24 0e c3 10 c0 	movl   $0xc010c30e,(%esp)
c010295c:	e8 9f da ff ff       	call   c0100400 <__panic>
            current->need_resched = 1;
c0102961:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c0102966:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
        }
        break;
c010296d:	e9 b9 00 00 00       	jmp    c0102a2b <trap_dispatch+0x254>
c0102972:	e9 b4 00 00 00       	jmp    c0102a2b <trap_dispatch+0x254>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0102977:	e8 63 f6 ff ff       	call   c0101fdf <cons_getc>
c010297c:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c010297f:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c0102983:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c0102987:	89 54 24 08          	mov    %edx,0x8(%esp)
c010298b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010298f:	c7 04 24 e9 c5 10 c0 	movl   $0xc010c5e9,(%esp)
c0102996:	e8 0e d9 ff ff       	call   c01002a9 <cprintf>
        break;
c010299b:	e9 8b 00 00 00       	jmp    c0102a2b <trap_dispatch+0x254>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c01029a0:	e8 3a f6 ff ff       	call   c0101fdf <cons_getc>
c01029a5:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c01029a8:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c01029ac:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c01029b0:	89 54 24 08          	mov    %edx,0x8(%esp)
c01029b4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01029b8:	c7 04 24 fb c5 10 c0 	movl   $0xc010c5fb,(%esp)
c01029bf:	e8 e5 d8 ff ff       	call   c01002a9 <cprintf>
        break;
c01029c4:	eb 65                	jmp    c0102a2b <trap_dispatch+0x254>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c01029c6:	c7 44 24 08 0a c6 10 	movl   $0xc010c60a,0x8(%esp)
c01029cd:	c0 
c01029ce:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c01029d5:	00 
c01029d6:	c7 04 24 0e c3 10 c0 	movl   $0xc010c30e,(%esp)
c01029dd:	e8 1e da ff ff       	call   c0100400 <__panic>
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        print_trapframe(tf);
c01029e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01029e5:	89 04 24             	mov    %eax,(%esp)
c01029e8:	e8 25 fa ff ff       	call   c0102412 <print_trapframe>
        if (current != NULL) {
c01029ed:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c01029f2:	85 c0                	test   %eax,%eax
c01029f4:	74 18                	je     c0102a0e <trap_dispatch+0x237>
            cprintf("unhandled trap.\n");
c01029f6:	c7 04 24 1a c6 10 c0 	movl   $0xc010c61a,(%esp)
c01029fd:	e8 a7 d8 ff ff       	call   c01002a9 <cprintf>
            do_exit(-E_KILLED);
c0102a02:	c7 04 24 f7 ff ff ff 	movl   $0xfffffff7,(%esp)
c0102a09:	e8 fb 74 00 00       	call   c0109f09 <do_exit>
        }
        // in kernel, it must be a mistake
        panic("unexpected trap in kernel.\n");
c0102a0e:	c7 44 24 08 2b c6 10 	movl   $0xc010c62b,0x8(%esp)
c0102a15:	c0 
c0102a16:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
c0102a1d:	00 
c0102a1e:	c7 04 24 0e c3 10 c0 	movl   $0xc010c30e,(%esp)
c0102a25:	e8 d6 d9 ff ff       	call   c0100400 <__panic>
        break;
c0102a2a:	90                   	nop

    }
}
c0102a2b:	c9                   	leave  
c0102a2c:	c3                   	ret    

c0102a2d <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0102a2d:	55                   	push   %ebp
c0102a2e:	89 e5                	mov    %esp,%ebp
c0102a30:	83 ec 28             	sub    $0x28,%esp
    // dispatch based on what type of trap occurred
    // used for previous projects
    if (current == NULL) {
c0102a33:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c0102a38:	85 c0                	test   %eax,%eax
c0102a3a:	75 0d                	jne    c0102a49 <trap+0x1c>
        trap_dispatch(tf);
c0102a3c:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a3f:	89 04 24             	mov    %eax,(%esp)
c0102a42:	e8 90 fd ff ff       	call   c01027d7 <trap_dispatch>
c0102a47:	eb 6c                	jmp    c0102ab5 <trap+0x88>
    }
    else {
        // keep a trapframe chain in stack
        struct trapframe *otf = current->tf;
c0102a49:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c0102a4e:	8b 40 3c             	mov    0x3c(%eax),%eax
c0102a51:	89 45 f4             	mov    %eax,-0xc(%ebp)
        current->tf = tf;
c0102a54:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c0102a59:	8b 55 08             	mov    0x8(%ebp),%edx
c0102a5c:	89 50 3c             	mov    %edx,0x3c(%eax)
    
        bool in_kernel = trap_in_kernel(tf);
c0102a5f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a62:	89 04 24             	mov    %eax,(%esp)
c0102a65:	e8 92 f9 ff ff       	call   c01023fc <trap_in_kernel>
c0102a6a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    
        trap_dispatch(tf);
c0102a6d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a70:	89 04 24             	mov    %eax,(%esp)
c0102a73:	e8 5f fd ff ff       	call   c01027d7 <trap_dispatch>
    
        current->tf = otf;
c0102a78:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c0102a7d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102a80:	89 50 3c             	mov    %edx,0x3c(%eax)
        if (!in_kernel) {
c0102a83:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0102a87:	75 2c                	jne    c0102ab5 <trap+0x88>
            if (current->flags & PF_EXITING) {
c0102a89:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c0102a8e:	8b 40 44             	mov    0x44(%eax),%eax
c0102a91:	83 e0 01             	and    $0x1,%eax
c0102a94:	85 c0                	test   %eax,%eax
c0102a96:	74 0c                	je     c0102aa4 <trap+0x77>
                do_exit(-E_KILLED);
c0102a98:	c7 04 24 f7 ff ff ff 	movl   $0xfffffff7,(%esp)
c0102a9f:	e8 65 74 00 00       	call   c0109f09 <do_exit>
            }
            if (current->need_resched) {
c0102aa4:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c0102aa9:	8b 40 10             	mov    0x10(%eax),%eax
c0102aac:	85 c0                	test   %eax,%eax
c0102aae:	74 05                	je     c0102ab5 <trap+0x88>
                schedule();
c0102ab0:	e8 b0 84 00 00       	call   c010af65 <schedule>
            }
        }
    }
}
c0102ab5:	c9                   	leave  
c0102ab6:	c3                   	ret    

c0102ab7 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0102ab7:	6a 00                	push   $0x0
  pushl $0
c0102ab9:	6a 00                	push   $0x0
  jmp __alltraps
c0102abb:	e9 69 0a 00 00       	jmp    c0103529 <__alltraps>

c0102ac0 <vector1>:
.globl vector1
vector1:
  pushl $0
c0102ac0:	6a 00                	push   $0x0
  pushl $1
c0102ac2:	6a 01                	push   $0x1
  jmp __alltraps
c0102ac4:	e9 60 0a 00 00       	jmp    c0103529 <__alltraps>

c0102ac9 <vector2>:
.globl vector2
vector2:
  pushl $0
c0102ac9:	6a 00                	push   $0x0
  pushl $2
c0102acb:	6a 02                	push   $0x2
  jmp __alltraps
c0102acd:	e9 57 0a 00 00       	jmp    c0103529 <__alltraps>

c0102ad2 <vector3>:
.globl vector3
vector3:
  pushl $0
c0102ad2:	6a 00                	push   $0x0
  pushl $3
c0102ad4:	6a 03                	push   $0x3
  jmp __alltraps
c0102ad6:	e9 4e 0a 00 00       	jmp    c0103529 <__alltraps>

c0102adb <vector4>:
.globl vector4
vector4:
  pushl $0
c0102adb:	6a 00                	push   $0x0
  pushl $4
c0102add:	6a 04                	push   $0x4
  jmp __alltraps
c0102adf:	e9 45 0a 00 00       	jmp    c0103529 <__alltraps>

c0102ae4 <vector5>:
.globl vector5
vector5:
  pushl $0
c0102ae4:	6a 00                	push   $0x0
  pushl $5
c0102ae6:	6a 05                	push   $0x5
  jmp __alltraps
c0102ae8:	e9 3c 0a 00 00       	jmp    c0103529 <__alltraps>

c0102aed <vector6>:
.globl vector6
vector6:
  pushl $0
c0102aed:	6a 00                	push   $0x0
  pushl $6
c0102aef:	6a 06                	push   $0x6
  jmp __alltraps
c0102af1:	e9 33 0a 00 00       	jmp    c0103529 <__alltraps>

c0102af6 <vector7>:
.globl vector7
vector7:
  pushl $0
c0102af6:	6a 00                	push   $0x0
  pushl $7
c0102af8:	6a 07                	push   $0x7
  jmp __alltraps
c0102afa:	e9 2a 0a 00 00       	jmp    c0103529 <__alltraps>

c0102aff <vector8>:
.globl vector8
vector8:
  pushl $8
c0102aff:	6a 08                	push   $0x8
  jmp __alltraps
c0102b01:	e9 23 0a 00 00       	jmp    c0103529 <__alltraps>

c0102b06 <vector9>:
.globl vector9
vector9:
  pushl $0
c0102b06:	6a 00                	push   $0x0
  pushl $9
c0102b08:	6a 09                	push   $0x9
  jmp __alltraps
c0102b0a:	e9 1a 0a 00 00       	jmp    c0103529 <__alltraps>

c0102b0f <vector10>:
.globl vector10
vector10:
  pushl $10
c0102b0f:	6a 0a                	push   $0xa
  jmp __alltraps
c0102b11:	e9 13 0a 00 00       	jmp    c0103529 <__alltraps>

c0102b16 <vector11>:
.globl vector11
vector11:
  pushl $11
c0102b16:	6a 0b                	push   $0xb
  jmp __alltraps
c0102b18:	e9 0c 0a 00 00       	jmp    c0103529 <__alltraps>

c0102b1d <vector12>:
.globl vector12
vector12:
  pushl $12
c0102b1d:	6a 0c                	push   $0xc
  jmp __alltraps
c0102b1f:	e9 05 0a 00 00       	jmp    c0103529 <__alltraps>

c0102b24 <vector13>:
.globl vector13
vector13:
  pushl $13
c0102b24:	6a 0d                	push   $0xd
  jmp __alltraps
c0102b26:	e9 fe 09 00 00       	jmp    c0103529 <__alltraps>

c0102b2b <vector14>:
.globl vector14
vector14:
  pushl $14
c0102b2b:	6a 0e                	push   $0xe
  jmp __alltraps
c0102b2d:	e9 f7 09 00 00       	jmp    c0103529 <__alltraps>

c0102b32 <vector15>:
.globl vector15
vector15:
  pushl $0
c0102b32:	6a 00                	push   $0x0
  pushl $15
c0102b34:	6a 0f                	push   $0xf
  jmp __alltraps
c0102b36:	e9 ee 09 00 00       	jmp    c0103529 <__alltraps>

c0102b3b <vector16>:
.globl vector16
vector16:
  pushl $0
c0102b3b:	6a 00                	push   $0x0
  pushl $16
c0102b3d:	6a 10                	push   $0x10
  jmp __alltraps
c0102b3f:	e9 e5 09 00 00       	jmp    c0103529 <__alltraps>

c0102b44 <vector17>:
.globl vector17
vector17:
  pushl $17
c0102b44:	6a 11                	push   $0x11
  jmp __alltraps
c0102b46:	e9 de 09 00 00       	jmp    c0103529 <__alltraps>

c0102b4b <vector18>:
.globl vector18
vector18:
  pushl $0
c0102b4b:	6a 00                	push   $0x0
  pushl $18
c0102b4d:	6a 12                	push   $0x12
  jmp __alltraps
c0102b4f:	e9 d5 09 00 00       	jmp    c0103529 <__alltraps>

c0102b54 <vector19>:
.globl vector19
vector19:
  pushl $0
c0102b54:	6a 00                	push   $0x0
  pushl $19
c0102b56:	6a 13                	push   $0x13
  jmp __alltraps
c0102b58:	e9 cc 09 00 00       	jmp    c0103529 <__alltraps>

c0102b5d <vector20>:
.globl vector20
vector20:
  pushl $0
c0102b5d:	6a 00                	push   $0x0
  pushl $20
c0102b5f:	6a 14                	push   $0x14
  jmp __alltraps
c0102b61:	e9 c3 09 00 00       	jmp    c0103529 <__alltraps>

c0102b66 <vector21>:
.globl vector21
vector21:
  pushl $0
c0102b66:	6a 00                	push   $0x0
  pushl $21
c0102b68:	6a 15                	push   $0x15
  jmp __alltraps
c0102b6a:	e9 ba 09 00 00       	jmp    c0103529 <__alltraps>

c0102b6f <vector22>:
.globl vector22
vector22:
  pushl $0
c0102b6f:	6a 00                	push   $0x0
  pushl $22
c0102b71:	6a 16                	push   $0x16
  jmp __alltraps
c0102b73:	e9 b1 09 00 00       	jmp    c0103529 <__alltraps>

c0102b78 <vector23>:
.globl vector23
vector23:
  pushl $0
c0102b78:	6a 00                	push   $0x0
  pushl $23
c0102b7a:	6a 17                	push   $0x17
  jmp __alltraps
c0102b7c:	e9 a8 09 00 00       	jmp    c0103529 <__alltraps>

c0102b81 <vector24>:
.globl vector24
vector24:
  pushl $0
c0102b81:	6a 00                	push   $0x0
  pushl $24
c0102b83:	6a 18                	push   $0x18
  jmp __alltraps
c0102b85:	e9 9f 09 00 00       	jmp    c0103529 <__alltraps>

c0102b8a <vector25>:
.globl vector25
vector25:
  pushl $0
c0102b8a:	6a 00                	push   $0x0
  pushl $25
c0102b8c:	6a 19                	push   $0x19
  jmp __alltraps
c0102b8e:	e9 96 09 00 00       	jmp    c0103529 <__alltraps>

c0102b93 <vector26>:
.globl vector26
vector26:
  pushl $0
c0102b93:	6a 00                	push   $0x0
  pushl $26
c0102b95:	6a 1a                	push   $0x1a
  jmp __alltraps
c0102b97:	e9 8d 09 00 00       	jmp    c0103529 <__alltraps>

c0102b9c <vector27>:
.globl vector27
vector27:
  pushl $0
c0102b9c:	6a 00                	push   $0x0
  pushl $27
c0102b9e:	6a 1b                	push   $0x1b
  jmp __alltraps
c0102ba0:	e9 84 09 00 00       	jmp    c0103529 <__alltraps>

c0102ba5 <vector28>:
.globl vector28
vector28:
  pushl $0
c0102ba5:	6a 00                	push   $0x0
  pushl $28
c0102ba7:	6a 1c                	push   $0x1c
  jmp __alltraps
c0102ba9:	e9 7b 09 00 00       	jmp    c0103529 <__alltraps>

c0102bae <vector29>:
.globl vector29
vector29:
  pushl $0
c0102bae:	6a 00                	push   $0x0
  pushl $29
c0102bb0:	6a 1d                	push   $0x1d
  jmp __alltraps
c0102bb2:	e9 72 09 00 00       	jmp    c0103529 <__alltraps>

c0102bb7 <vector30>:
.globl vector30
vector30:
  pushl $0
c0102bb7:	6a 00                	push   $0x0
  pushl $30
c0102bb9:	6a 1e                	push   $0x1e
  jmp __alltraps
c0102bbb:	e9 69 09 00 00       	jmp    c0103529 <__alltraps>

c0102bc0 <vector31>:
.globl vector31
vector31:
  pushl $0
c0102bc0:	6a 00                	push   $0x0
  pushl $31
c0102bc2:	6a 1f                	push   $0x1f
  jmp __alltraps
c0102bc4:	e9 60 09 00 00       	jmp    c0103529 <__alltraps>

c0102bc9 <vector32>:
.globl vector32
vector32:
  pushl $0
c0102bc9:	6a 00                	push   $0x0
  pushl $32
c0102bcb:	6a 20                	push   $0x20
  jmp __alltraps
c0102bcd:	e9 57 09 00 00       	jmp    c0103529 <__alltraps>

c0102bd2 <vector33>:
.globl vector33
vector33:
  pushl $0
c0102bd2:	6a 00                	push   $0x0
  pushl $33
c0102bd4:	6a 21                	push   $0x21
  jmp __alltraps
c0102bd6:	e9 4e 09 00 00       	jmp    c0103529 <__alltraps>

c0102bdb <vector34>:
.globl vector34
vector34:
  pushl $0
c0102bdb:	6a 00                	push   $0x0
  pushl $34
c0102bdd:	6a 22                	push   $0x22
  jmp __alltraps
c0102bdf:	e9 45 09 00 00       	jmp    c0103529 <__alltraps>

c0102be4 <vector35>:
.globl vector35
vector35:
  pushl $0
c0102be4:	6a 00                	push   $0x0
  pushl $35
c0102be6:	6a 23                	push   $0x23
  jmp __alltraps
c0102be8:	e9 3c 09 00 00       	jmp    c0103529 <__alltraps>

c0102bed <vector36>:
.globl vector36
vector36:
  pushl $0
c0102bed:	6a 00                	push   $0x0
  pushl $36
c0102bef:	6a 24                	push   $0x24
  jmp __alltraps
c0102bf1:	e9 33 09 00 00       	jmp    c0103529 <__alltraps>

c0102bf6 <vector37>:
.globl vector37
vector37:
  pushl $0
c0102bf6:	6a 00                	push   $0x0
  pushl $37
c0102bf8:	6a 25                	push   $0x25
  jmp __alltraps
c0102bfa:	e9 2a 09 00 00       	jmp    c0103529 <__alltraps>

c0102bff <vector38>:
.globl vector38
vector38:
  pushl $0
c0102bff:	6a 00                	push   $0x0
  pushl $38
c0102c01:	6a 26                	push   $0x26
  jmp __alltraps
c0102c03:	e9 21 09 00 00       	jmp    c0103529 <__alltraps>

c0102c08 <vector39>:
.globl vector39
vector39:
  pushl $0
c0102c08:	6a 00                	push   $0x0
  pushl $39
c0102c0a:	6a 27                	push   $0x27
  jmp __alltraps
c0102c0c:	e9 18 09 00 00       	jmp    c0103529 <__alltraps>

c0102c11 <vector40>:
.globl vector40
vector40:
  pushl $0
c0102c11:	6a 00                	push   $0x0
  pushl $40
c0102c13:	6a 28                	push   $0x28
  jmp __alltraps
c0102c15:	e9 0f 09 00 00       	jmp    c0103529 <__alltraps>

c0102c1a <vector41>:
.globl vector41
vector41:
  pushl $0
c0102c1a:	6a 00                	push   $0x0
  pushl $41
c0102c1c:	6a 29                	push   $0x29
  jmp __alltraps
c0102c1e:	e9 06 09 00 00       	jmp    c0103529 <__alltraps>

c0102c23 <vector42>:
.globl vector42
vector42:
  pushl $0
c0102c23:	6a 00                	push   $0x0
  pushl $42
c0102c25:	6a 2a                	push   $0x2a
  jmp __alltraps
c0102c27:	e9 fd 08 00 00       	jmp    c0103529 <__alltraps>

c0102c2c <vector43>:
.globl vector43
vector43:
  pushl $0
c0102c2c:	6a 00                	push   $0x0
  pushl $43
c0102c2e:	6a 2b                	push   $0x2b
  jmp __alltraps
c0102c30:	e9 f4 08 00 00       	jmp    c0103529 <__alltraps>

c0102c35 <vector44>:
.globl vector44
vector44:
  pushl $0
c0102c35:	6a 00                	push   $0x0
  pushl $44
c0102c37:	6a 2c                	push   $0x2c
  jmp __alltraps
c0102c39:	e9 eb 08 00 00       	jmp    c0103529 <__alltraps>

c0102c3e <vector45>:
.globl vector45
vector45:
  pushl $0
c0102c3e:	6a 00                	push   $0x0
  pushl $45
c0102c40:	6a 2d                	push   $0x2d
  jmp __alltraps
c0102c42:	e9 e2 08 00 00       	jmp    c0103529 <__alltraps>

c0102c47 <vector46>:
.globl vector46
vector46:
  pushl $0
c0102c47:	6a 00                	push   $0x0
  pushl $46
c0102c49:	6a 2e                	push   $0x2e
  jmp __alltraps
c0102c4b:	e9 d9 08 00 00       	jmp    c0103529 <__alltraps>

c0102c50 <vector47>:
.globl vector47
vector47:
  pushl $0
c0102c50:	6a 00                	push   $0x0
  pushl $47
c0102c52:	6a 2f                	push   $0x2f
  jmp __alltraps
c0102c54:	e9 d0 08 00 00       	jmp    c0103529 <__alltraps>

c0102c59 <vector48>:
.globl vector48
vector48:
  pushl $0
c0102c59:	6a 00                	push   $0x0
  pushl $48
c0102c5b:	6a 30                	push   $0x30
  jmp __alltraps
c0102c5d:	e9 c7 08 00 00       	jmp    c0103529 <__alltraps>

c0102c62 <vector49>:
.globl vector49
vector49:
  pushl $0
c0102c62:	6a 00                	push   $0x0
  pushl $49
c0102c64:	6a 31                	push   $0x31
  jmp __alltraps
c0102c66:	e9 be 08 00 00       	jmp    c0103529 <__alltraps>

c0102c6b <vector50>:
.globl vector50
vector50:
  pushl $0
c0102c6b:	6a 00                	push   $0x0
  pushl $50
c0102c6d:	6a 32                	push   $0x32
  jmp __alltraps
c0102c6f:	e9 b5 08 00 00       	jmp    c0103529 <__alltraps>

c0102c74 <vector51>:
.globl vector51
vector51:
  pushl $0
c0102c74:	6a 00                	push   $0x0
  pushl $51
c0102c76:	6a 33                	push   $0x33
  jmp __alltraps
c0102c78:	e9 ac 08 00 00       	jmp    c0103529 <__alltraps>

c0102c7d <vector52>:
.globl vector52
vector52:
  pushl $0
c0102c7d:	6a 00                	push   $0x0
  pushl $52
c0102c7f:	6a 34                	push   $0x34
  jmp __alltraps
c0102c81:	e9 a3 08 00 00       	jmp    c0103529 <__alltraps>

c0102c86 <vector53>:
.globl vector53
vector53:
  pushl $0
c0102c86:	6a 00                	push   $0x0
  pushl $53
c0102c88:	6a 35                	push   $0x35
  jmp __alltraps
c0102c8a:	e9 9a 08 00 00       	jmp    c0103529 <__alltraps>

c0102c8f <vector54>:
.globl vector54
vector54:
  pushl $0
c0102c8f:	6a 00                	push   $0x0
  pushl $54
c0102c91:	6a 36                	push   $0x36
  jmp __alltraps
c0102c93:	e9 91 08 00 00       	jmp    c0103529 <__alltraps>

c0102c98 <vector55>:
.globl vector55
vector55:
  pushl $0
c0102c98:	6a 00                	push   $0x0
  pushl $55
c0102c9a:	6a 37                	push   $0x37
  jmp __alltraps
c0102c9c:	e9 88 08 00 00       	jmp    c0103529 <__alltraps>

c0102ca1 <vector56>:
.globl vector56
vector56:
  pushl $0
c0102ca1:	6a 00                	push   $0x0
  pushl $56
c0102ca3:	6a 38                	push   $0x38
  jmp __alltraps
c0102ca5:	e9 7f 08 00 00       	jmp    c0103529 <__alltraps>

c0102caa <vector57>:
.globl vector57
vector57:
  pushl $0
c0102caa:	6a 00                	push   $0x0
  pushl $57
c0102cac:	6a 39                	push   $0x39
  jmp __alltraps
c0102cae:	e9 76 08 00 00       	jmp    c0103529 <__alltraps>

c0102cb3 <vector58>:
.globl vector58
vector58:
  pushl $0
c0102cb3:	6a 00                	push   $0x0
  pushl $58
c0102cb5:	6a 3a                	push   $0x3a
  jmp __alltraps
c0102cb7:	e9 6d 08 00 00       	jmp    c0103529 <__alltraps>

c0102cbc <vector59>:
.globl vector59
vector59:
  pushl $0
c0102cbc:	6a 00                	push   $0x0
  pushl $59
c0102cbe:	6a 3b                	push   $0x3b
  jmp __alltraps
c0102cc0:	e9 64 08 00 00       	jmp    c0103529 <__alltraps>

c0102cc5 <vector60>:
.globl vector60
vector60:
  pushl $0
c0102cc5:	6a 00                	push   $0x0
  pushl $60
c0102cc7:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102cc9:	e9 5b 08 00 00       	jmp    c0103529 <__alltraps>

c0102cce <vector61>:
.globl vector61
vector61:
  pushl $0
c0102cce:	6a 00                	push   $0x0
  pushl $61
c0102cd0:	6a 3d                	push   $0x3d
  jmp __alltraps
c0102cd2:	e9 52 08 00 00       	jmp    c0103529 <__alltraps>

c0102cd7 <vector62>:
.globl vector62
vector62:
  pushl $0
c0102cd7:	6a 00                	push   $0x0
  pushl $62
c0102cd9:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102cdb:	e9 49 08 00 00       	jmp    c0103529 <__alltraps>

c0102ce0 <vector63>:
.globl vector63
vector63:
  pushl $0
c0102ce0:	6a 00                	push   $0x0
  pushl $63
c0102ce2:	6a 3f                	push   $0x3f
  jmp __alltraps
c0102ce4:	e9 40 08 00 00       	jmp    c0103529 <__alltraps>

c0102ce9 <vector64>:
.globl vector64
vector64:
  pushl $0
c0102ce9:	6a 00                	push   $0x0
  pushl $64
c0102ceb:	6a 40                	push   $0x40
  jmp __alltraps
c0102ced:	e9 37 08 00 00       	jmp    c0103529 <__alltraps>

c0102cf2 <vector65>:
.globl vector65
vector65:
  pushl $0
c0102cf2:	6a 00                	push   $0x0
  pushl $65
c0102cf4:	6a 41                	push   $0x41
  jmp __alltraps
c0102cf6:	e9 2e 08 00 00       	jmp    c0103529 <__alltraps>

c0102cfb <vector66>:
.globl vector66
vector66:
  pushl $0
c0102cfb:	6a 00                	push   $0x0
  pushl $66
c0102cfd:	6a 42                	push   $0x42
  jmp __alltraps
c0102cff:	e9 25 08 00 00       	jmp    c0103529 <__alltraps>

c0102d04 <vector67>:
.globl vector67
vector67:
  pushl $0
c0102d04:	6a 00                	push   $0x0
  pushl $67
c0102d06:	6a 43                	push   $0x43
  jmp __alltraps
c0102d08:	e9 1c 08 00 00       	jmp    c0103529 <__alltraps>

c0102d0d <vector68>:
.globl vector68
vector68:
  pushl $0
c0102d0d:	6a 00                	push   $0x0
  pushl $68
c0102d0f:	6a 44                	push   $0x44
  jmp __alltraps
c0102d11:	e9 13 08 00 00       	jmp    c0103529 <__alltraps>

c0102d16 <vector69>:
.globl vector69
vector69:
  pushl $0
c0102d16:	6a 00                	push   $0x0
  pushl $69
c0102d18:	6a 45                	push   $0x45
  jmp __alltraps
c0102d1a:	e9 0a 08 00 00       	jmp    c0103529 <__alltraps>

c0102d1f <vector70>:
.globl vector70
vector70:
  pushl $0
c0102d1f:	6a 00                	push   $0x0
  pushl $70
c0102d21:	6a 46                	push   $0x46
  jmp __alltraps
c0102d23:	e9 01 08 00 00       	jmp    c0103529 <__alltraps>

c0102d28 <vector71>:
.globl vector71
vector71:
  pushl $0
c0102d28:	6a 00                	push   $0x0
  pushl $71
c0102d2a:	6a 47                	push   $0x47
  jmp __alltraps
c0102d2c:	e9 f8 07 00 00       	jmp    c0103529 <__alltraps>

c0102d31 <vector72>:
.globl vector72
vector72:
  pushl $0
c0102d31:	6a 00                	push   $0x0
  pushl $72
c0102d33:	6a 48                	push   $0x48
  jmp __alltraps
c0102d35:	e9 ef 07 00 00       	jmp    c0103529 <__alltraps>

c0102d3a <vector73>:
.globl vector73
vector73:
  pushl $0
c0102d3a:	6a 00                	push   $0x0
  pushl $73
c0102d3c:	6a 49                	push   $0x49
  jmp __alltraps
c0102d3e:	e9 e6 07 00 00       	jmp    c0103529 <__alltraps>

c0102d43 <vector74>:
.globl vector74
vector74:
  pushl $0
c0102d43:	6a 00                	push   $0x0
  pushl $74
c0102d45:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102d47:	e9 dd 07 00 00       	jmp    c0103529 <__alltraps>

c0102d4c <vector75>:
.globl vector75
vector75:
  pushl $0
c0102d4c:	6a 00                	push   $0x0
  pushl $75
c0102d4e:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102d50:	e9 d4 07 00 00       	jmp    c0103529 <__alltraps>

c0102d55 <vector76>:
.globl vector76
vector76:
  pushl $0
c0102d55:	6a 00                	push   $0x0
  pushl $76
c0102d57:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102d59:	e9 cb 07 00 00       	jmp    c0103529 <__alltraps>

c0102d5e <vector77>:
.globl vector77
vector77:
  pushl $0
c0102d5e:	6a 00                	push   $0x0
  pushl $77
c0102d60:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102d62:	e9 c2 07 00 00       	jmp    c0103529 <__alltraps>

c0102d67 <vector78>:
.globl vector78
vector78:
  pushl $0
c0102d67:	6a 00                	push   $0x0
  pushl $78
c0102d69:	6a 4e                	push   $0x4e
  jmp __alltraps
c0102d6b:	e9 b9 07 00 00       	jmp    c0103529 <__alltraps>

c0102d70 <vector79>:
.globl vector79
vector79:
  pushl $0
c0102d70:	6a 00                	push   $0x0
  pushl $79
c0102d72:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102d74:	e9 b0 07 00 00       	jmp    c0103529 <__alltraps>

c0102d79 <vector80>:
.globl vector80
vector80:
  pushl $0
c0102d79:	6a 00                	push   $0x0
  pushl $80
c0102d7b:	6a 50                	push   $0x50
  jmp __alltraps
c0102d7d:	e9 a7 07 00 00       	jmp    c0103529 <__alltraps>

c0102d82 <vector81>:
.globl vector81
vector81:
  pushl $0
c0102d82:	6a 00                	push   $0x0
  pushl $81
c0102d84:	6a 51                	push   $0x51
  jmp __alltraps
c0102d86:	e9 9e 07 00 00       	jmp    c0103529 <__alltraps>

c0102d8b <vector82>:
.globl vector82
vector82:
  pushl $0
c0102d8b:	6a 00                	push   $0x0
  pushl $82
c0102d8d:	6a 52                	push   $0x52
  jmp __alltraps
c0102d8f:	e9 95 07 00 00       	jmp    c0103529 <__alltraps>

c0102d94 <vector83>:
.globl vector83
vector83:
  pushl $0
c0102d94:	6a 00                	push   $0x0
  pushl $83
c0102d96:	6a 53                	push   $0x53
  jmp __alltraps
c0102d98:	e9 8c 07 00 00       	jmp    c0103529 <__alltraps>

c0102d9d <vector84>:
.globl vector84
vector84:
  pushl $0
c0102d9d:	6a 00                	push   $0x0
  pushl $84
c0102d9f:	6a 54                	push   $0x54
  jmp __alltraps
c0102da1:	e9 83 07 00 00       	jmp    c0103529 <__alltraps>

c0102da6 <vector85>:
.globl vector85
vector85:
  pushl $0
c0102da6:	6a 00                	push   $0x0
  pushl $85
c0102da8:	6a 55                	push   $0x55
  jmp __alltraps
c0102daa:	e9 7a 07 00 00       	jmp    c0103529 <__alltraps>

c0102daf <vector86>:
.globl vector86
vector86:
  pushl $0
c0102daf:	6a 00                	push   $0x0
  pushl $86
c0102db1:	6a 56                	push   $0x56
  jmp __alltraps
c0102db3:	e9 71 07 00 00       	jmp    c0103529 <__alltraps>

c0102db8 <vector87>:
.globl vector87
vector87:
  pushl $0
c0102db8:	6a 00                	push   $0x0
  pushl $87
c0102dba:	6a 57                	push   $0x57
  jmp __alltraps
c0102dbc:	e9 68 07 00 00       	jmp    c0103529 <__alltraps>

c0102dc1 <vector88>:
.globl vector88
vector88:
  pushl $0
c0102dc1:	6a 00                	push   $0x0
  pushl $88
c0102dc3:	6a 58                	push   $0x58
  jmp __alltraps
c0102dc5:	e9 5f 07 00 00       	jmp    c0103529 <__alltraps>

c0102dca <vector89>:
.globl vector89
vector89:
  pushl $0
c0102dca:	6a 00                	push   $0x0
  pushl $89
c0102dcc:	6a 59                	push   $0x59
  jmp __alltraps
c0102dce:	e9 56 07 00 00       	jmp    c0103529 <__alltraps>

c0102dd3 <vector90>:
.globl vector90
vector90:
  pushl $0
c0102dd3:	6a 00                	push   $0x0
  pushl $90
c0102dd5:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102dd7:	e9 4d 07 00 00       	jmp    c0103529 <__alltraps>

c0102ddc <vector91>:
.globl vector91
vector91:
  pushl $0
c0102ddc:	6a 00                	push   $0x0
  pushl $91
c0102dde:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102de0:	e9 44 07 00 00       	jmp    c0103529 <__alltraps>

c0102de5 <vector92>:
.globl vector92
vector92:
  pushl $0
c0102de5:	6a 00                	push   $0x0
  pushl $92
c0102de7:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102de9:	e9 3b 07 00 00       	jmp    c0103529 <__alltraps>

c0102dee <vector93>:
.globl vector93
vector93:
  pushl $0
c0102dee:	6a 00                	push   $0x0
  pushl $93
c0102df0:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102df2:	e9 32 07 00 00       	jmp    c0103529 <__alltraps>

c0102df7 <vector94>:
.globl vector94
vector94:
  pushl $0
c0102df7:	6a 00                	push   $0x0
  pushl $94
c0102df9:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102dfb:	e9 29 07 00 00       	jmp    c0103529 <__alltraps>

c0102e00 <vector95>:
.globl vector95
vector95:
  pushl $0
c0102e00:	6a 00                	push   $0x0
  pushl $95
c0102e02:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102e04:	e9 20 07 00 00       	jmp    c0103529 <__alltraps>

c0102e09 <vector96>:
.globl vector96
vector96:
  pushl $0
c0102e09:	6a 00                	push   $0x0
  pushl $96
c0102e0b:	6a 60                	push   $0x60
  jmp __alltraps
c0102e0d:	e9 17 07 00 00       	jmp    c0103529 <__alltraps>

c0102e12 <vector97>:
.globl vector97
vector97:
  pushl $0
c0102e12:	6a 00                	push   $0x0
  pushl $97
c0102e14:	6a 61                	push   $0x61
  jmp __alltraps
c0102e16:	e9 0e 07 00 00       	jmp    c0103529 <__alltraps>

c0102e1b <vector98>:
.globl vector98
vector98:
  pushl $0
c0102e1b:	6a 00                	push   $0x0
  pushl $98
c0102e1d:	6a 62                	push   $0x62
  jmp __alltraps
c0102e1f:	e9 05 07 00 00       	jmp    c0103529 <__alltraps>

c0102e24 <vector99>:
.globl vector99
vector99:
  pushl $0
c0102e24:	6a 00                	push   $0x0
  pushl $99
c0102e26:	6a 63                	push   $0x63
  jmp __alltraps
c0102e28:	e9 fc 06 00 00       	jmp    c0103529 <__alltraps>

c0102e2d <vector100>:
.globl vector100
vector100:
  pushl $0
c0102e2d:	6a 00                	push   $0x0
  pushl $100
c0102e2f:	6a 64                	push   $0x64
  jmp __alltraps
c0102e31:	e9 f3 06 00 00       	jmp    c0103529 <__alltraps>

c0102e36 <vector101>:
.globl vector101
vector101:
  pushl $0
c0102e36:	6a 00                	push   $0x0
  pushl $101
c0102e38:	6a 65                	push   $0x65
  jmp __alltraps
c0102e3a:	e9 ea 06 00 00       	jmp    c0103529 <__alltraps>

c0102e3f <vector102>:
.globl vector102
vector102:
  pushl $0
c0102e3f:	6a 00                	push   $0x0
  pushl $102
c0102e41:	6a 66                	push   $0x66
  jmp __alltraps
c0102e43:	e9 e1 06 00 00       	jmp    c0103529 <__alltraps>

c0102e48 <vector103>:
.globl vector103
vector103:
  pushl $0
c0102e48:	6a 00                	push   $0x0
  pushl $103
c0102e4a:	6a 67                	push   $0x67
  jmp __alltraps
c0102e4c:	e9 d8 06 00 00       	jmp    c0103529 <__alltraps>

c0102e51 <vector104>:
.globl vector104
vector104:
  pushl $0
c0102e51:	6a 00                	push   $0x0
  pushl $104
c0102e53:	6a 68                	push   $0x68
  jmp __alltraps
c0102e55:	e9 cf 06 00 00       	jmp    c0103529 <__alltraps>

c0102e5a <vector105>:
.globl vector105
vector105:
  pushl $0
c0102e5a:	6a 00                	push   $0x0
  pushl $105
c0102e5c:	6a 69                	push   $0x69
  jmp __alltraps
c0102e5e:	e9 c6 06 00 00       	jmp    c0103529 <__alltraps>

c0102e63 <vector106>:
.globl vector106
vector106:
  pushl $0
c0102e63:	6a 00                	push   $0x0
  pushl $106
c0102e65:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102e67:	e9 bd 06 00 00       	jmp    c0103529 <__alltraps>

c0102e6c <vector107>:
.globl vector107
vector107:
  pushl $0
c0102e6c:	6a 00                	push   $0x0
  pushl $107
c0102e6e:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102e70:	e9 b4 06 00 00       	jmp    c0103529 <__alltraps>

c0102e75 <vector108>:
.globl vector108
vector108:
  pushl $0
c0102e75:	6a 00                	push   $0x0
  pushl $108
c0102e77:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102e79:	e9 ab 06 00 00       	jmp    c0103529 <__alltraps>

c0102e7e <vector109>:
.globl vector109
vector109:
  pushl $0
c0102e7e:	6a 00                	push   $0x0
  pushl $109
c0102e80:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102e82:	e9 a2 06 00 00       	jmp    c0103529 <__alltraps>

c0102e87 <vector110>:
.globl vector110
vector110:
  pushl $0
c0102e87:	6a 00                	push   $0x0
  pushl $110
c0102e89:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102e8b:	e9 99 06 00 00       	jmp    c0103529 <__alltraps>

c0102e90 <vector111>:
.globl vector111
vector111:
  pushl $0
c0102e90:	6a 00                	push   $0x0
  pushl $111
c0102e92:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102e94:	e9 90 06 00 00       	jmp    c0103529 <__alltraps>

c0102e99 <vector112>:
.globl vector112
vector112:
  pushl $0
c0102e99:	6a 00                	push   $0x0
  pushl $112
c0102e9b:	6a 70                	push   $0x70
  jmp __alltraps
c0102e9d:	e9 87 06 00 00       	jmp    c0103529 <__alltraps>

c0102ea2 <vector113>:
.globl vector113
vector113:
  pushl $0
c0102ea2:	6a 00                	push   $0x0
  pushl $113
c0102ea4:	6a 71                	push   $0x71
  jmp __alltraps
c0102ea6:	e9 7e 06 00 00       	jmp    c0103529 <__alltraps>

c0102eab <vector114>:
.globl vector114
vector114:
  pushl $0
c0102eab:	6a 00                	push   $0x0
  pushl $114
c0102ead:	6a 72                	push   $0x72
  jmp __alltraps
c0102eaf:	e9 75 06 00 00       	jmp    c0103529 <__alltraps>

c0102eb4 <vector115>:
.globl vector115
vector115:
  pushl $0
c0102eb4:	6a 00                	push   $0x0
  pushl $115
c0102eb6:	6a 73                	push   $0x73
  jmp __alltraps
c0102eb8:	e9 6c 06 00 00       	jmp    c0103529 <__alltraps>

c0102ebd <vector116>:
.globl vector116
vector116:
  pushl $0
c0102ebd:	6a 00                	push   $0x0
  pushl $116
c0102ebf:	6a 74                	push   $0x74
  jmp __alltraps
c0102ec1:	e9 63 06 00 00       	jmp    c0103529 <__alltraps>

c0102ec6 <vector117>:
.globl vector117
vector117:
  pushl $0
c0102ec6:	6a 00                	push   $0x0
  pushl $117
c0102ec8:	6a 75                	push   $0x75
  jmp __alltraps
c0102eca:	e9 5a 06 00 00       	jmp    c0103529 <__alltraps>

c0102ecf <vector118>:
.globl vector118
vector118:
  pushl $0
c0102ecf:	6a 00                	push   $0x0
  pushl $118
c0102ed1:	6a 76                	push   $0x76
  jmp __alltraps
c0102ed3:	e9 51 06 00 00       	jmp    c0103529 <__alltraps>

c0102ed8 <vector119>:
.globl vector119
vector119:
  pushl $0
c0102ed8:	6a 00                	push   $0x0
  pushl $119
c0102eda:	6a 77                	push   $0x77
  jmp __alltraps
c0102edc:	e9 48 06 00 00       	jmp    c0103529 <__alltraps>

c0102ee1 <vector120>:
.globl vector120
vector120:
  pushl $0
c0102ee1:	6a 00                	push   $0x0
  pushl $120
c0102ee3:	6a 78                	push   $0x78
  jmp __alltraps
c0102ee5:	e9 3f 06 00 00       	jmp    c0103529 <__alltraps>

c0102eea <vector121>:
.globl vector121
vector121:
  pushl $0
c0102eea:	6a 00                	push   $0x0
  pushl $121
c0102eec:	6a 79                	push   $0x79
  jmp __alltraps
c0102eee:	e9 36 06 00 00       	jmp    c0103529 <__alltraps>

c0102ef3 <vector122>:
.globl vector122
vector122:
  pushl $0
c0102ef3:	6a 00                	push   $0x0
  pushl $122
c0102ef5:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102ef7:	e9 2d 06 00 00       	jmp    c0103529 <__alltraps>

c0102efc <vector123>:
.globl vector123
vector123:
  pushl $0
c0102efc:	6a 00                	push   $0x0
  pushl $123
c0102efe:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102f00:	e9 24 06 00 00       	jmp    c0103529 <__alltraps>

c0102f05 <vector124>:
.globl vector124
vector124:
  pushl $0
c0102f05:	6a 00                	push   $0x0
  pushl $124
c0102f07:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102f09:	e9 1b 06 00 00       	jmp    c0103529 <__alltraps>

c0102f0e <vector125>:
.globl vector125
vector125:
  pushl $0
c0102f0e:	6a 00                	push   $0x0
  pushl $125
c0102f10:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102f12:	e9 12 06 00 00       	jmp    c0103529 <__alltraps>

c0102f17 <vector126>:
.globl vector126
vector126:
  pushl $0
c0102f17:	6a 00                	push   $0x0
  pushl $126
c0102f19:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102f1b:	e9 09 06 00 00       	jmp    c0103529 <__alltraps>

c0102f20 <vector127>:
.globl vector127
vector127:
  pushl $0
c0102f20:	6a 00                	push   $0x0
  pushl $127
c0102f22:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102f24:	e9 00 06 00 00       	jmp    c0103529 <__alltraps>

c0102f29 <vector128>:
.globl vector128
vector128:
  pushl $0
c0102f29:	6a 00                	push   $0x0
  pushl $128
c0102f2b:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102f30:	e9 f4 05 00 00       	jmp    c0103529 <__alltraps>

c0102f35 <vector129>:
.globl vector129
vector129:
  pushl $0
c0102f35:	6a 00                	push   $0x0
  pushl $129
c0102f37:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102f3c:	e9 e8 05 00 00       	jmp    c0103529 <__alltraps>

c0102f41 <vector130>:
.globl vector130
vector130:
  pushl $0
c0102f41:	6a 00                	push   $0x0
  pushl $130
c0102f43:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102f48:	e9 dc 05 00 00       	jmp    c0103529 <__alltraps>

c0102f4d <vector131>:
.globl vector131
vector131:
  pushl $0
c0102f4d:	6a 00                	push   $0x0
  pushl $131
c0102f4f:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102f54:	e9 d0 05 00 00       	jmp    c0103529 <__alltraps>

c0102f59 <vector132>:
.globl vector132
vector132:
  pushl $0
c0102f59:	6a 00                	push   $0x0
  pushl $132
c0102f5b:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102f60:	e9 c4 05 00 00       	jmp    c0103529 <__alltraps>

c0102f65 <vector133>:
.globl vector133
vector133:
  pushl $0
c0102f65:	6a 00                	push   $0x0
  pushl $133
c0102f67:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102f6c:	e9 b8 05 00 00       	jmp    c0103529 <__alltraps>

c0102f71 <vector134>:
.globl vector134
vector134:
  pushl $0
c0102f71:	6a 00                	push   $0x0
  pushl $134
c0102f73:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102f78:	e9 ac 05 00 00       	jmp    c0103529 <__alltraps>

c0102f7d <vector135>:
.globl vector135
vector135:
  pushl $0
c0102f7d:	6a 00                	push   $0x0
  pushl $135
c0102f7f:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102f84:	e9 a0 05 00 00       	jmp    c0103529 <__alltraps>

c0102f89 <vector136>:
.globl vector136
vector136:
  pushl $0
c0102f89:	6a 00                	push   $0x0
  pushl $136
c0102f8b:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0102f90:	e9 94 05 00 00       	jmp    c0103529 <__alltraps>

c0102f95 <vector137>:
.globl vector137
vector137:
  pushl $0
c0102f95:	6a 00                	push   $0x0
  pushl $137
c0102f97:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102f9c:	e9 88 05 00 00       	jmp    c0103529 <__alltraps>

c0102fa1 <vector138>:
.globl vector138
vector138:
  pushl $0
c0102fa1:	6a 00                	push   $0x0
  pushl $138
c0102fa3:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102fa8:	e9 7c 05 00 00       	jmp    c0103529 <__alltraps>

c0102fad <vector139>:
.globl vector139
vector139:
  pushl $0
c0102fad:	6a 00                	push   $0x0
  pushl $139
c0102faf:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102fb4:	e9 70 05 00 00       	jmp    c0103529 <__alltraps>

c0102fb9 <vector140>:
.globl vector140
vector140:
  pushl $0
c0102fb9:	6a 00                	push   $0x0
  pushl $140
c0102fbb:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0102fc0:	e9 64 05 00 00       	jmp    c0103529 <__alltraps>

c0102fc5 <vector141>:
.globl vector141
vector141:
  pushl $0
c0102fc5:	6a 00                	push   $0x0
  pushl $141
c0102fc7:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102fcc:	e9 58 05 00 00       	jmp    c0103529 <__alltraps>

c0102fd1 <vector142>:
.globl vector142
vector142:
  pushl $0
c0102fd1:	6a 00                	push   $0x0
  pushl $142
c0102fd3:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102fd8:	e9 4c 05 00 00       	jmp    c0103529 <__alltraps>

c0102fdd <vector143>:
.globl vector143
vector143:
  pushl $0
c0102fdd:	6a 00                	push   $0x0
  pushl $143
c0102fdf:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0102fe4:	e9 40 05 00 00       	jmp    c0103529 <__alltraps>

c0102fe9 <vector144>:
.globl vector144
vector144:
  pushl $0
c0102fe9:	6a 00                	push   $0x0
  pushl $144
c0102feb:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102ff0:	e9 34 05 00 00       	jmp    c0103529 <__alltraps>

c0102ff5 <vector145>:
.globl vector145
vector145:
  pushl $0
c0102ff5:	6a 00                	push   $0x0
  pushl $145
c0102ff7:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102ffc:	e9 28 05 00 00       	jmp    c0103529 <__alltraps>

c0103001 <vector146>:
.globl vector146
vector146:
  pushl $0
c0103001:	6a 00                	push   $0x0
  pushl $146
c0103003:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0103008:	e9 1c 05 00 00       	jmp    c0103529 <__alltraps>

c010300d <vector147>:
.globl vector147
vector147:
  pushl $0
c010300d:	6a 00                	push   $0x0
  pushl $147
c010300f:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0103014:	e9 10 05 00 00       	jmp    c0103529 <__alltraps>

c0103019 <vector148>:
.globl vector148
vector148:
  pushl $0
c0103019:	6a 00                	push   $0x0
  pushl $148
c010301b:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0103020:	e9 04 05 00 00       	jmp    c0103529 <__alltraps>

c0103025 <vector149>:
.globl vector149
vector149:
  pushl $0
c0103025:	6a 00                	push   $0x0
  pushl $149
c0103027:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c010302c:	e9 f8 04 00 00       	jmp    c0103529 <__alltraps>

c0103031 <vector150>:
.globl vector150
vector150:
  pushl $0
c0103031:	6a 00                	push   $0x0
  pushl $150
c0103033:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0103038:	e9 ec 04 00 00       	jmp    c0103529 <__alltraps>

c010303d <vector151>:
.globl vector151
vector151:
  pushl $0
c010303d:	6a 00                	push   $0x0
  pushl $151
c010303f:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0103044:	e9 e0 04 00 00       	jmp    c0103529 <__alltraps>

c0103049 <vector152>:
.globl vector152
vector152:
  pushl $0
c0103049:	6a 00                	push   $0x0
  pushl $152
c010304b:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0103050:	e9 d4 04 00 00       	jmp    c0103529 <__alltraps>

c0103055 <vector153>:
.globl vector153
vector153:
  pushl $0
c0103055:	6a 00                	push   $0x0
  pushl $153
c0103057:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c010305c:	e9 c8 04 00 00       	jmp    c0103529 <__alltraps>

c0103061 <vector154>:
.globl vector154
vector154:
  pushl $0
c0103061:	6a 00                	push   $0x0
  pushl $154
c0103063:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0103068:	e9 bc 04 00 00       	jmp    c0103529 <__alltraps>

c010306d <vector155>:
.globl vector155
vector155:
  pushl $0
c010306d:	6a 00                	push   $0x0
  pushl $155
c010306f:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0103074:	e9 b0 04 00 00       	jmp    c0103529 <__alltraps>

c0103079 <vector156>:
.globl vector156
vector156:
  pushl $0
c0103079:	6a 00                	push   $0x0
  pushl $156
c010307b:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0103080:	e9 a4 04 00 00       	jmp    c0103529 <__alltraps>

c0103085 <vector157>:
.globl vector157
vector157:
  pushl $0
c0103085:	6a 00                	push   $0x0
  pushl $157
c0103087:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c010308c:	e9 98 04 00 00       	jmp    c0103529 <__alltraps>

c0103091 <vector158>:
.globl vector158
vector158:
  pushl $0
c0103091:	6a 00                	push   $0x0
  pushl $158
c0103093:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0103098:	e9 8c 04 00 00       	jmp    c0103529 <__alltraps>

c010309d <vector159>:
.globl vector159
vector159:
  pushl $0
c010309d:	6a 00                	push   $0x0
  pushl $159
c010309f:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c01030a4:	e9 80 04 00 00       	jmp    c0103529 <__alltraps>

c01030a9 <vector160>:
.globl vector160
vector160:
  pushl $0
c01030a9:	6a 00                	push   $0x0
  pushl $160
c01030ab:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c01030b0:	e9 74 04 00 00       	jmp    c0103529 <__alltraps>

c01030b5 <vector161>:
.globl vector161
vector161:
  pushl $0
c01030b5:	6a 00                	push   $0x0
  pushl $161
c01030b7:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c01030bc:	e9 68 04 00 00       	jmp    c0103529 <__alltraps>

c01030c1 <vector162>:
.globl vector162
vector162:
  pushl $0
c01030c1:	6a 00                	push   $0x0
  pushl $162
c01030c3:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c01030c8:	e9 5c 04 00 00       	jmp    c0103529 <__alltraps>

c01030cd <vector163>:
.globl vector163
vector163:
  pushl $0
c01030cd:	6a 00                	push   $0x0
  pushl $163
c01030cf:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c01030d4:	e9 50 04 00 00       	jmp    c0103529 <__alltraps>

c01030d9 <vector164>:
.globl vector164
vector164:
  pushl $0
c01030d9:	6a 00                	push   $0x0
  pushl $164
c01030db:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c01030e0:	e9 44 04 00 00       	jmp    c0103529 <__alltraps>

c01030e5 <vector165>:
.globl vector165
vector165:
  pushl $0
c01030e5:	6a 00                	push   $0x0
  pushl $165
c01030e7:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c01030ec:	e9 38 04 00 00       	jmp    c0103529 <__alltraps>

c01030f1 <vector166>:
.globl vector166
vector166:
  pushl $0
c01030f1:	6a 00                	push   $0x0
  pushl $166
c01030f3:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c01030f8:	e9 2c 04 00 00       	jmp    c0103529 <__alltraps>

c01030fd <vector167>:
.globl vector167
vector167:
  pushl $0
c01030fd:	6a 00                	push   $0x0
  pushl $167
c01030ff:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c0103104:	e9 20 04 00 00       	jmp    c0103529 <__alltraps>

c0103109 <vector168>:
.globl vector168
vector168:
  pushl $0
c0103109:	6a 00                	push   $0x0
  pushl $168
c010310b:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0103110:	e9 14 04 00 00       	jmp    c0103529 <__alltraps>

c0103115 <vector169>:
.globl vector169
vector169:
  pushl $0
c0103115:	6a 00                	push   $0x0
  pushl $169
c0103117:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c010311c:	e9 08 04 00 00       	jmp    c0103529 <__alltraps>

c0103121 <vector170>:
.globl vector170
vector170:
  pushl $0
c0103121:	6a 00                	push   $0x0
  pushl $170
c0103123:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0103128:	e9 fc 03 00 00       	jmp    c0103529 <__alltraps>

c010312d <vector171>:
.globl vector171
vector171:
  pushl $0
c010312d:	6a 00                	push   $0x0
  pushl $171
c010312f:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0103134:	e9 f0 03 00 00       	jmp    c0103529 <__alltraps>

c0103139 <vector172>:
.globl vector172
vector172:
  pushl $0
c0103139:	6a 00                	push   $0x0
  pushl $172
c010313b:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0103140:	e9 e4 03 00 00       	jmp    c0103529 <__alltraps>

c0103145 <vector173>:
.globl vector173
vector173:
  pushl $0
c0103145:	6a 00                	push   $0x0
  pushl $173
c0103147:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c010314c:	e9 d8 03 00 00       	jmp    c0103529 <__alltraps>

c0103151 <vector174>:
.globl vector174
vector174:
  pushl $0
c0103151:	6a 00                	push   $0x0
  pushl $174
c0103153:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0103158:	e9 cc 03 00 00       	jmp    c0103529 <__alltraps>

c010315d <vector175>:
.globl vector175
vector175:
  pushl $0
c010315d:	6a 00                	push   $0x0
  pushl $175
c010315f:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0103164:	e9 c0 03 00 00       	jmp    c0103529 <__alltraps>

c0103169 <vector176>:
.globl vector176
vector176:
  pushl $0
c0103169:	6a 00                	push   $0x0
  pushl $176
c010316b:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0103170:	e9 b4 03 00 00       	jmp    c0103529 <__alltraps>

c0103175 <vector177>:
.globl vector177
vector177:
  pushl $0
c0103175:	6a 00                	push   $0x0
  pushl $177
c0103177:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c010317c:	e9 a8 03 00 00       	jmp    c0103529 <__alltraps>

c0103181 <vector178>:
.globl vector178
vector178:
  pushl $0
c0103181:	6a 00                	push   $0x0
  pushl $178
c0103183:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0103188:	e9 9c 03 00 00       	jmp    c0103529 <__alltraps>

c010318d <vector179>:
.globl vector179
vector179:
  pushl $0
c010318d:	6a 00                	push   $0x0
  pushl $179
c010318f:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0103194:	e9 90 03 00 00       	jmp    c0103529 <__alltraps>

c0103199 <vector180>:
.globl vector180
vector180:
  pushl $0
c0103199:	6a 00                	push   $0x0
  pushl $180
c010319b:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c01031a0:	e9 84 03 00 00       	jmp    c0103529 <__alltraps>

c01031a5 <vector181>:
.globl vector181
vector181:
  pushl $0
c01031a5:	6a 00                	push   $0x0
  pushl $181
c01031a7:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c01031ac:	e9 78 03 00 00       	jmp    c0103529 <__alltraps>

c01031b1 <vector182>:
.globl vector182
vector182:
  pushl $0
c01031b1:	6a 00                	push   $0x0
  pushl $182
c01031b3:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c01031b8:	e9 6c 03 00 00       	jmp    c0103529 <__alltraps>

c01031bd <vector183>:
.globl vector183
vector183:
  pushl $0
c01031bd:	6a 00                	push   $0x0
  pushl $183
c01031bf:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c01031c4:	e9 60 03 00 00       	jmp    c0103529 <__alltraps>

c01031c9 <vector184>:
.globl vector184
vector184:
  pushl $0
c01031c9:	6a 00                	push   $0x0
  pushl $184
c01031cb:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c01031d0:	e9 54 03 00 00       	jmp    c0103529 <__alltraps>

c01031d5 <vector185>:
.globl vector185
vector185:
  pushl $0
c01031d5:	6a 00                	push   $0x0
  pushl $185
c01031d7:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c01031dc:	e9 48 03 00 00       	jmp    c0103529 <__alltraps>

c01031e1 <vector186>:
.globl vector186
vector186:
  pushl $0
c01031e1:	6a 00                	push   $0x0
  pushl $186
c01031e3:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c01031e8:	e9 3c 03 00 00       	jmp    c0103529 <__alltraps>

c01031ed <vector187>:
.globl vector187
vector187:
  pushl $0
c01031ed:	6a 00                	push   $0x0
  pushl $187
c01031ef:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c01031f4:	e9 30 03 00 00       	jmp    c0103529 <__alltraps>

c01031f9 <vector188>:
.globl vector188
vector188:
  pushl $0
c01031f9:	6a 00                	push   $0x0
  pushl $188
c01031fb:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c0103200:	e9 24 03 00 00       	jmp    c0103529 <__alltraps>

c0103205 <vector189>:
.globl vector189
vector189:
  pushl $0
c0103205:	6a 00                	push   $0x0
  pushl $189
c0103207:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c010320c:	e9 18 03 00 00       	jmp    c0103529 <__alltraps>

c0103211 <vector190>:
.globl vector190
vector190:
  pushl $0
c0103211:	6a 00                	push   $0x0
  pushl $190
c0103213:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c0103218:	e9 0c 03 00 00       	jmp    c0103529 <__alltraps>

c010321d <vector191>:
.globl vector191
vector191:
  pushl $0
c010321d:	6a 00                	push   $0x0
  pushl $191
c010321f:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0103224:	e9 00 03 00 00       	jmp    c0103529 <__alltraps>

c0103229 <vector192>:
.globl vector192
vector192:
  pushl $0
c0103229:	6a 00                	push   $0x0
  pushl $192
c010322b:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0103230:	e9 f4 02 00 00       	jmp    c0103529 <__alltraps>

c0103235 <vector193>:
.globl vector193
vector193:
  pushl $0
c0103235:	6a 00                	push   $0x0
  pushl $193
c0103237:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c010323c:	e9 e8 02 00 00       	jmp    c0103529 <__alltraps>

c0103241 <vector194>:
.globl vector194
vector194:
  pushl $0
c0103241:	6a 00                	push   $0x0
  pushl $194
c0103243:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c0103248:	e9 dc 02 00 00       	jmp    c0103529 <__alltraps>

c010324d <vector195>:
.globl vector195
vector195:
  pushl $0
c010324d:	6a 00                	push   $0x0
  pushl $195
c010324f:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0103254:	e9 d0 02 00 00       	jmp    c0103529 <__alltraps>

c0103259 <vector196>:
.globl vector196
vector196:
  pushl $0
c0103259:	6a 00                	push   $0x0
  pushl $196
c010325b:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0103260:	e9 c4 02 00 00       	jmp    c0103529 <__alltraps>

c0103265 <vector197>:
.globl vector197
vector197:
  pushl $0
c0103265:	6a 00                	push   $0x0
  pushl $197
c0103267:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c010326c:	e9 b8 02 00 00       	jmp    c0103529 <__alltraps>

c0103271 <vector198>:
.globl vector198
vector198:
  pushl $0
c0103271:	6a 00                	push   $0x0
  pushl $198
c0103273:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0103278:	e9 ac 02 00 00       	jmp    c0103529 <__alltraps>

c010327d <vector199>:
.globl vector199
vector199:
  pushl $0
c010327d:	6a 00                	push   $0x0
  pushl $199
c010327f:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0103284:	e9 a0 02 00 00       	jmp    c0103529 <__alltraps>

c0103289 <vector200>:
.globl vector200
vector200:
  pushl $0
c0103289:	6a 00                	push   $0x0
  pushl $200
c010328b:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0103290:	e9 94 02 00 00       	jmp    c0103529 <__alltraps>

c0103295 <vector201>:
.globl vector201
vector201:
  pushl $0
c0103295:	6a 00                	push   $0x0
  pushl $201
c0103297:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c010329c:	e9 88 02 00 00       	jmp    c0103529 <__alltraps>

c01032a1 <vector202>:
.globl vector202
vector202:
  pushl $0
c01032a1:	6a 00                	push   $0x0
  pushl $202
c01032a3:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c01032a8:	e9 7c 02 00 00       	jmp    c0103529 <__alltraps>

c01032ad <vector203>:
.globl vector203
vector203:
  pushl $0
c01032ad:	6a 00                	push   $0x0
  pushl $203
c01032af:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c01032b4:	e9 70 02 00 00       	jmp    c0103529 <__alltraps>

c01032b9 <vector204>:
.globl vector204
vector204:
  pushl $0
c01032b9:	6a 00                	push   $0x0
  pushl $204
c01032bb:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c01032c0:	e9 64 02 00 00       	jmp    c0103529 <__alltraps>

c01032c5 <vector205>:
.globl vector205
vector205:
  pushl $0
c01032c5:	6a 00                	push   $0x0
  pushl $205
c01032c7:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c01032cc:	e9 58 02 00 00       	jmp    c0103529 <__alltraps>

c01032d1 <vector206>:
.globl vector206
vector206:
  pushl $0
c01032d1:	6a 00                	push   $0x0
  pushl $206
c01032d3:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c01032d8:	e9 4c 02 00 00       	jmp    c0103529 <__alltraps>

c01032dd <vector207>:
.globl vector207
vector207:
  pushl $0
c01032dd:	6a 00                	push   $0x0
  pushl $207
c01032df:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c01032e4:	e9 40 02 00 00       	jmp    c0103529 <__alltraps>

c01032e9 <vector208>:
.globl vector208
vector208:
  pushl $0
c01032e9:	6a 00                	push   $0x0
  pushl $208
c01032eb:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c01032f0:	e9 34 02 00 00       	jmp    c0103529 <__alltraps>

c01032f5 <vector209>:
.globl vector209
vector209:
  pushl $0
c01032f5:	6a 00                	push   $0x0
  pushl $209
c01032f7:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c01032fc:	e9 28 02 00 00       	jmp    c0103529 <__alltraps>

c0103301 <vector210>:
.globl vector210
vector210:
  pushl $0
c0103301:	6a 00                	push   $0x0
  pushl $210
c0103303:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c0103308:	e9 1c 02 00 00       	jmp    c0103529 <__alltraps>

c010330d <vector211>:
.globl vector211
vector211:
  pushl $0
c010330d:	6a 00                	push   $0x0
  pushl $211
c010330f:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c0103314:	e9 10 02 00 00       	jmp    c0103529 <__alltraps>

c0103319 <vector212>:
.globl vector212
vector212:
  pushl $0
c0103319:	6a 00                	push   $0x0
  pushl $212
c010331b:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0103320:	e9 04 02 00 00       	jmp    c0103529 <__alltraps>

c0103325 <vector213>:
.globl vector213
vector213:
  pushl $0
c0103325:	6a 00                	push   $0x0
  pushl $213
c0103327:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c010332c:	e9 f8 01 00 00       	jmp    c0103529 <__alltraps>

c0103331 <vector214>:
.globl vector214
vector214:
  pushl $0
c0103331:	6a 00                	push   $0x0
  pushl $214
c0103333:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c0103338:	e9 ec 01 00 00       	jmp    c0103529 <__alltraps>

c010333d <vector215>:
.globl vector215
vector215:
  pushl $0
c010333d:	6a 00                	push   $0x0
  pushl $215
c010333f:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0103344:	e9 e0 01 00 00       	jmp    c0103529 <__alltraps>

c0103349 <vector216>:
.globl vector216
vector216:
  pushl $0
c0103349:	6a 00                	push   $0x0
  pushl $216
c010334b:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c0103350:	e9 d4 01 00 00       	jmp    c0103529 <__alltraps>

c0103355 <vector217>:
.globl vector217
vector217:
  pushl $0
c0103355:	6a 00                	push   $0x0
  pushl $217
c0103357:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c010335c:	e9 c8 01 00 00       	jmp    c0103529 <__alltraps>

c0103361 <vector218>:
.globl vector218
vector218:
  pushl $0
c0103361:	6a 00                	push   $0x0
  pushl $218
c0103363:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c0103368:	e9 bc 01 00 00       	jmp    c0103529 <__alltraps>

c010336d <vector219>:
.globl vector219
vector219:
  pushl $0
c010336d:	6a 00                	push   $0x0
  pushl $219
c010336f:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0103374:	e9 b0 01 00 00       	jmp    c0103529 <__alltraps>

c0103379 <vector220>:
.globl vector220
vector220:
  pushl $0
c0103379:	6a 00                	push   $0x0
  pushl $220
c010337b:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0103380:	e9 a4 01 00 00       	jmp    c0103529 <__alltraps>

c0103385 <vector221>:
.globl vector221
vector221:
  pushl $0
c0103385:	6a 00                	push   $0x0
  pushl $221
c0103387:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c010338c:	e9 98 01 00 00       	jmp    c0103529 <__alltraps>

c0103391 <vector222>:
.globl vector222
vector222:
  pushl $0
c0103391:	6a 00                	push   $0x0
  pushl $222
c0103393:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0103398:	e9 8c 01 00 00       	jmp    c0103529 <__alltraps>

c010339d <vector223>:
.globl vector223
vector223:
  pushl $0
c010339d:	6a 00                	push   $0x0
  pushl $223
c010339f:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c01033a4:	e9 80 01 00 00       	jmp    c0103529 <__alltraps>

c01033a9 <vector224>:
.globl vector224
vector224:
  pushl $0
c01033a9:	6a 00                	push   $0x0
  pushl $224
c01033ab:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c01033b0:	e9 74 01 00 00       	jmp    c0103529 <__alltraps>

c01033b5 <vector225>:
.globl vector225
vector225:
  pushl $0
c01033b5:	6a 00                	push   $0x0
  pushl $225
c01033b7:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c01033bc:	e9 68 01 00 00       	jmp    c0103529 <__alltraps>

c01033c1 <vector226>:
.globl vector226
vector226:
  pushl $0
c01033c1:	6a 00                	push   $0x0
  pushl $226
c01033c3:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c01033c8:	e9 5c 01 00 00       	jmp    c0103529 <__alltraps>

c01033cd <vector227>:
.globl vector227
vector227:
  pushl $0
c01033cd:	6a 00                	push   $0x0
  pushl $227
c01033cf:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c01033d4:	e9 50 01 00 00       	jmp    c0103529 <__alltraps>

c01033d9 <vector228>:
.globl vector228
vector228:
  pushl $0
c01033d9:	6a 00                	push   $0x0
  pushl $228
c01033db:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c01033e0:	e9 44 01 00 00       	jmp    c0103529 <__alltraps>

c01033e5 <vector229>:
.globl vector229
vector229:
  pushl $0
c01033e5:	6a 00                	push   $0x0
  pushl $229
c01033e7:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c01033ec:	e9 38 01 00 00       	jmp    c0103529 <__alltraps>

c01033f1 <vector230>:
.globl vector230
vector230:
  pushl $0
c01033f1:	6a 00                	push   $0x0
  pushl $230
c01033f3:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c01033f8:	e9 2c 01 00 00       	jmp    c0103529 <__alltraps>

c01033fd <vector231>:
.globl vector231
vector231:
  pushl $0
c01033fd:	6a 00                	push   $0x0
  pushl $231
c01033ff:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c0103404:	e9 20 01 00 00       	jmp    c0103529 <__alltraps>

c0103409 <vector232>:
.globl vector232
vector232:
  pushl $0
c0103409:	6a 00                	push   $0x0
  pushl $232
c010340b:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c0103410:	e9 14 01 00 00       	jmp    c0103529 <__alltraps>

c0103415 <vector233>:
.globl vector233
vector233:
  pushl $0
c0103415:	6a 00                	push   $0x0
  pushl $233
c0103417:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c010341c:	e9 08 01 00 00       	jmp    c0103529 <__alltraps>

c0103421 <vector234>:
.globl vector234
vector234:
  pushl $0
c0103421:	6a 00                	push   $0x0
  pushl $234
c0103423:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c0103428:	e9 fc 00 00 00       	jmp    c0103529 <__alltraps>

c010342d <vector235>:
.globl vector235
vector235:
  pushl $0
c010342d:	6a 00                	push   $0x0
  pushl $235
c010342f:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c0103434:	e9 f0 00 00 00       	jmp    c0103529 <__alltraps>

c0103439 <vector236>:
.globl vector236
vector236:
  pushl $0
c0103439:	6a 00                	push   $0x0
  pushl $236
c010343b:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0103440:	e9 e4 00 00 00       	jmp    c0103529 <__alltraps>

c0103445 <vector237>:
.globl vector237
vector237:
  pushl $0
c0103445:	6a 00                	push   $0x0
  pushl $237
c0103447:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c010344c:	e9 d8 00 00 00       	jmp    c0103529 <__alltraps>

c0103451 <vector238>:
.globl vector238
vector238:
  pushl $0
c0103451:	6a 00                	push   $0x0
  pushl $238
c0103453:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c0103458:	e9 cc 00 00 00       	jmp    c0103529 <__alltraps>

c010345d <vector239>:
.globl vector239
vector239:
  pushl $0
c010345d:	6a 00                	push   $0x0
  pushl $239
c010345f:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0103464:	e9 c0 00 00 00       	jmp    c0103529 <__alltraps>

c0103469 <vector240>:
.globl vector240
vector240:
  pushl $0
c0103469:	6a 00                	push   $0x0
  pushl $240
c010346b:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0103470:	e9 b4 00 00 00       	jmp    c0103529 <__alltraps>

c0103475 <vector241>:
.globl vector241
vector241:
  pushl $0
c0103475:	6a 00                	push   $0x0
  pushl $241
c0103477:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c010347c:	e9 a8 00 00 00       	jmp    c0103529 <__alltraps>

c0103481 <vector242>:
.globl vector242
vector242:
  pushl $0
c0103481:	6a 00                	push   $0x0
  pushl $242
c0103483:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c0103488:	e9 9c 00 00 00       	jmp    c0103529 <__alltraps>

c010348d <vector243>:
.globl vector243
vector243:
  pushl $0
c010348d:	6a 00                	push   $0x0
  pushl $243
c010348f:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0103494:	e9 90 00 00 00       	jmp    c0103529 <__alltraps>

c0103499 <vector244>:
.globl vector244
vector244:
  pushl $0
c0103499:	6a 00                	push   $0x0
  pushl $244
c010349b:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c01034a0:	e9 84 00 00 00       	jmp    c0103529 <__alltraps>

c01034a5 <vector245>:
.globl vector245
vector245:
  pushl $0
c01034a5:	6a 00                	push   $0x0
  pushl $245
c01034a7:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c01034ac:	e9 78 00 00 00       	jmp    c0103529 <__alltraps>

c01034b1 <vector246>:
.globl vector246
vector246:
  pushl $0
c01034b1:	6a 00                	push   $0x0
  pushl $246
c01034b3:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c01034b8:	e9 6c 00 00 00       	jmp    c0103529 <__alltraps>

c01034bd <vector247>:
.globl vector247
vector247:
  pushl $0
c01034bd:	6a 00                	push   $0x0
  pushl $247
c01034bf:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c01034c4:	e9 60 00 00 00       	jmp    c0103529 <__alltraps>

c01034c9 <vector248>:
.globl vector248
vector248:
  pushl $0
c01034c9:	6a 00                	push   $0x0
  pushl $248
c01034cb:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c01034d0:	e9 54 00 00 00       	jmp    c0103529 <__alltraps>

c01034d5 <vector249>:
.globl vector249
vector249:
  pushl $0
c01034d5:	6a 00                	push   $0x0
  pushl $249
c01034d7:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c01034dc:	e9 48 00 00 00       	jmp    c0103529 <__alltraps>

c01034e1 <vector250>:
.globl vector250
vector250:
  pushl $0
c01034e1:	6a 00                	push   $0x0
  pushl $250
c01034e3:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c01034e8:	e9 3c 00 00 00       	jmp    c0103529 <__alltraps>

c01034ed <vector251>:
.globl vector251
vector251:
  pushl $0
c01034ed:	6a 00                	push   $0x0
  pushl $251
c01034ef:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c01034f4:	e9 30 00 00 00       	jmp    c0103529 <__alltraps>

c01034f9 <vector252>:
.globl vector252
vector252:
  pushl $0
c01034f9:	6a 00                	push   $0x0
  pushl $252
c01034fb:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c0103500:	e9 24 00 00 00       	jmp    c0103529 <__alltraps>

c0103505 <vector253>:
.globl vector253
vector253:
  pushl $0
c0103505:	6a 00                	push   $0x0
  pushl $253
c0103507:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c010350c:	e9 18 00 00 00       	jmp    c0103529 <__alltraps>

c0103511 <vector254>:
.globl vector254
vector254:
  pushl $0
c0103511:	6a 00                	push   $0x0
  pushl $254
c0103513:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c0103518:	e9 0c 00 00 00       	jmp    c0103529 <__alltraps>

c010351d <vector255>:
.globl vector255
vector255:
  pushl $0
c010351d:	6a 00                	push   $0x0
  pushl $255
c010351f:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c0103524:	e9 00 00 00 00       	jmp    c0103529 <__alltraps>

c0103529 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0103529:	1e                   	push   %ds
    pushl %es
c010352a:	06                   	push   %es
    pushl %fs
c010352b:	0f a0                	push   %fs
    pushl %gs
c010352d:	0f a8                	push   %gs
    pushal
c010352f:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0103530:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0103535:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0103537:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0103539:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c010353a:	e8 ee f4 ff ff       	call   c0102a2d <trap>

    # pop the pushed stack pointer
    popl %esp
c010353f:	5c                   	pop    %esp

c0103540 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0103540:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0103541:	0f a9                	pop    %gs
    popl %fs
c0103543:	0f a1                	pop    %fs
    popl %es
c0103545:	07                   	pop    %es
    popl %ds
c0103546:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0103547:	83 c4 08             	add    $0x8,%esp
    iret
c010354a:	cf                   	iret   

c010354b <forkrets>:

.globl forkrets
forkrets:
    # set stack to this new process's trapframe
    movl 4(%esp), %esp
c010354b:	8b 64 24 04          	mov    0x4(%esp),%esp
    jmp __trapret
c010354f:	eb ef                	jmp    c0103540 <__trapret>

c0103551 <lock_init>:
#define local_intr_restore(x)   __intr_restore(x);

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
c0103551:	55                   	push   %ebp
c0103552:	89 e5                	mov    %esp,%ebp
    *lock = 0;
c0103554:	8b 45 08             	mov    0x8(%ebp),%eax
c0103557:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
c010355d:	5d                   	pop    %ebp
c010355e:	c3                   	ret    

c010355f <mm_count>:
bool user_mem_check(struct mm_struct *mm, uintptr_t start, size_t len, bool write);
bool copy_from_user(struct mm_struct *mm, void *dst, const void *src, size_t len, bool writable);
bool copy_to_user(struct mm_struct *mm, void *dst, const void *src, size_t len);

static inline int
mm_count(struct mm_struct *mm) {
c010355f:	55                   	push   %ebp
c0103560:	89 e5                	mov    %esp,%ebp
    return mm->mm_count;
c0103562:	8b 45 08             	mov    0x8(%ebp),%eax
c0103565:	8b 40 18             	mov    0x18(%eax),%eax
}
c0103568:	5d                   	pop    %ebp
c0103569:	c3                   	ret    

c010356a <set_mm_count>:

static inline void
set_mm_count(struct mm_struct *mm, int val) {
c010356a:	55                   	push   %ebp
c010356b:	89 e5                	mov    %esp,%ebp
    mm->mm_count = val;
c010356d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103570:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103573:	89 50 18             	mov    %edx,0x18(%eax)
}
c0103576:	5d                   	pop    %ebp
c0103577:	c3                   	ret    

c0103578 <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c0103578:	55                   	push   %ebp
c0103579:	89 e5                	mov    %esp,%ebp
c010357b:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c010357e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103581:	c1 e8 0c             	shr    $0xc,%eax
c0103584:	89 c2                	mov    %eax,%edx
c0103586:	a1 80 ef 19 c0       	mov    0xc019ef80,%eax
c010358b:	39 c2                	cmp    %eax,%edx
c010358d:	72 1c                	jb     c01035ab <pa2page+0x33>
        panic("pa2page called with invalid pa");
c010358f:	c7 44 24 08 f0 c7 10 	movl   $0xc010c7f0,0x8(%esp)
c0103596:	c0 
c0103597:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c010359e:	00 
c010359f:	c7 04 24 0f c8 10 c0 	movl   $0xc010c80f,(%esp)
c01035a6:	e8 55 ce ff ff       	call   c0100400 <__panic>
    }
    return &pages[PPN(pa)];
c01035ab:	a1 58 11 1a c0       	mov    0xc01a1158,%eax
c01035b0:	8b 55 08             	mov    0x8(%ebp),%edx
c01035b3:	c1 ea 0c             	shr    $0xc,%edx
c01035b6:	c1 e2 05             	shl    $0x5,%edx
c01035b9:	01 d0                	add    %edx,%eax
}
c01035bb:	c9                   	leave  
c01035bc:	c3                   	ret    

c01035bd <pde2page>:
    }
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *
pde2page(pde_t pde) {
c01035bd:	55                   	push   %ebp
c01035be:	89 e5                	mov    %esp,%ebp
c01035c0:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c01035c3:	8b 45 08             	mov    0x8(%ebp),%eax
c01035c6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01035cb:	89 04 24             	mov    %eax,(%esp)
c01035ce:	e8 a5 ff ff ff       	call   c0103578 <pa2page>
}
c01035d3:	c9                   	leave  
c01035d4:	c3                   	ret    

c01035d5 <mm_create>:
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void) {
c01035d5:	55                   	push   %ebp
c01035d6:	89 e5                	mov    %esp,%ebp
c01035d8:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
c01035db:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01035e2:	e8 0b 1d 00 00       	call   c01052f2 <kmalloc>
c01035e7:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (mm != NULL) {
c01035ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01035ee:	74 79                	je     c0103669 <mm_create+0x94>
        list_init(&(mm->mmap_list));
c01035f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01035f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01035f9:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01035fc:	89 50 04             	mov    %edx,0x4(%eax)
c01035ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103602:	8b 50 04             	mov    0x4(%eax),%edx
c0103605:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103608:	89 10                	mov    %edx,(%eax)
        mm->mmap_cache = NULL;
c010360a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010360d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        mm->pgdir = NULL;
c0103614:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103617:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        mm->map_count = 0;
c010361e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103621:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

        if (swap_init_ok) swap_init_mm(mm);
c0103628:	a1 6c ef 19 c0       	mov    0xc019ef6c,%eax
c010362d:	85 c0                	test   %eax,%eax
c010362f:	74 0d                	je     c010363e <mm_create+0x69>
c0103631:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103634:	89 04 24             	mov    %eax,(%esp)
c0103637:	e8 38 1f 00 00       	call   c0105574 <swap_init_mm>
c010363c:	eb 0a                	jmp    c0103648 <mm_create+0x73>
        else mm->sm_priv = NULL;
c010363e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103641:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        
        set_mm_count(mm, 0);
c0103648:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010364f:	00 
c0103650:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103653:	89 04 24             	mov    %eax,(%esp)
c0103656:	e8 0f ff ff ff       	call   c010356a <set_mm_count>
        lock_init(&(mm->mm_lock));
c010365b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010365e:	83 c0 1c             	add    $0x1c,%eax
c0103661:	89 04 24             	mov    %eax,(%esp)
c0103664:	e8 e8 fe ff ff       	call   c0103551 <lock_init>
    }    
    return mm;
c0103669:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010366c:	c9                   	leave  
c010366d:	c3                   	ret    

c010366e <vma_create>:

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
c010366e:	55                   	push   %ebp
c010366f:	89 e5                	mov    %esp,%ebp
c0103671:	83 ec 28             	sub    $0x28,%esp
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
c0103674:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c010367b:	e8 72 1c 00 00       	call   c01052f2 <kmalloc>
c0103680:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (vma != NULL) {
c0103683:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103687:	74 1b                	je     c01036a4 <vma_create+0x36>
        vma->vm_start = vm_start;
c0103689:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010368c:	8b 55 08             	mov    0x8(%ebp),%edx
c010368f:	89 50 04             	mov    %edx,0x4(%eax)
        vma->vm_end = vm_end;
c0103692:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103695:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103698:	89 50 08             	mov    %edx,0x8(%eax)
        vma->vm_flags = vm_flags;
c010369b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010369e:	8b 55 10             	mov    0x10(%ebp),%edx
c01036a1:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    return vma;
c01036a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01036a7:	c9                   	leave  
c01036a8:	c3                   	ret    

c01036a9 <find_vma>:


// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
c01036a9:	55                   	push   %ebp
c01036aa:	89 e5                	mov    %esp,%ebp
c01036ac:	83 ec 20             	sub    $0x20,%esp
    struct vma_struct *vma = NULL;
c01036af:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    if (mm != NULL) {
c01036b6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01036ba:	0f 84 95 00 00 00    	je     c0103755 <find_vma+0xac>
        vma = mm->mmap_cache;
c01036c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01036c3:	8b 40 08             	mov    0x8(%eax),%eax
c01036c6:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
c01036c9:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01036cd:	74 16                	je     c01036e5 <find_vma+0x3c>
c01036cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01036d2:	8b 40 04             	mov    0x4(%eax),%eax
c01036d5:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01036d8:	77 0b                	ja     c01036e5 <find_vma+0x3c>
c01036da:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01036dd:	8b 40 08             	mov    0x8(%eax),%eax
c01036e0:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01036e3:	77 61                	ja     c0103746 <find_vma+0x9d>
                bool found = 0;
c01036e5:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
                list_entry_t *list = &(mm->mmap_list), *le = list;
c01036ec:	8b 45 08             	mov    0x8(%ebp),%eax
c01036ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01036f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01036f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
                while ((le = list_next(le)) != list) {
c01036f8:	eb 28                	jmp    c0103722 <find_vma+0x79>
                    vma = le2vma(le, list_link);
c01036fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036fd:	83 e8 10             	sub    $0x10,%eax
c0103700:	89 45 fc             	mov    %eax,-0x4(%ebp)
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
c0103703:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103706:	8b 40 04             	mov    0x4(%eax),%eax
c0103709:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010370c:	77 14                	ja     c0103722 <find_vma+0x79>
c010370e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103711:	8b 40 08             	mov    0x8(%eax),%eax
c0103714:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103717:	76 09                	jbe    c0103722 <find_vma+0x79>
                        found = 1;
c0103719:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
                        break;
c0103720:	eb 17                	jmp    c0103739 <find_vma+0x90>
c0103722:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103725:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0103728:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010372b:	8b 40 04             	mov    0x4(%eax),%eax
                while ((le = list_next(le)) != list) {
c010372e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103731:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103734:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103737:	75 c1                	jne    c01036fa <find_vma+0x51>
                    }
                }
                if (!found) {
c0103739:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c010373d:	75 07                	jne    c0103746 <find_vma+0x9d>
                    vma = NULL;
c010373f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
                }
        }
        if (vma != NULL) {
c0103746:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010374a:	74 09                	je     c0103755 <find_vma+0xac>
            mm->mmap_cache = vma;
c010374c:	8b 45 08             	mov    0x8(%ebp),%eax
c010374f:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0103752:	89 50 08             	mov    %edx,0x8(%eax)
        }
    }
    return vma;
c0103755:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0103758:	c9                   	leave  
c0103759:	c3                   	ret    

c010375a <check_vma_overlap>:


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
c010375a:	55                   	push   %ebp
c010375b:	89 e5                	mov    %esp,%ebp
c010375d:	83 ec 18             	sub    $0x18,%esp
    assert(prev->vm_start < prev->vm_end);
c0103760:	8b 45 08             	mov    0x8(%ebp),%eax
c0103763:	8b 50 04             	mov    0x4(%eax),%edx
c0103766:	8b 45 08             	mov    0x8(%ebp),%eax
c0103769:	8b 40 08             	mov    0x8(%eax),%eax
c010376c:	39 c2                	cmp    %eax,%edx
c010376e:	72 24                	jb     c0103794 <check_vma_overlap+0x3a>
c0103770:	c7 44 24 0c 1d c8 10 	movl   $0xc010c81d,0xc(%esp)
c0103777:	c0 
c0103778:	c7 44 24 08 3b c8 10 	movl   $0xc010c83b,0x8(%esp)
c010377f:	c0 
c0103780:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
c0103787:	00 
c0103788:	c7 04 24 50 c8 10 c0 	movl   $0xc010c850,(%esp)
c010378f:	e8 6c cc ff ff       	call   c0100400 <__panic>
    assert(prev->vm_end <= next->vm_start);
c0103794:	8b 45 08             	mov    0x8(%ebp),%eax
c0103797:	8b 50 08             	mov    0x8(%eax),%edx
c010379a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010379d:	8b 40 04             	mov    0x4(%eax),%eax
c01037a0:	39 c2                	cmp    %eax,%edx
c01037a2:	76 24                	jbe    c01037c8 <check_vma_overlap+0x6e>
c01037a4:	c7 44 24 0c 60 c8 10 	movl   $0xc010c860,0xc(%esp)
c01037ab:	c0 
c01037ac:	c7 44 24 08 3b c8 10 	movl   $0xc010c83b,0x8(%esp)
c01037b3:	c0 
c01037b4:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c01037bb:	00 
c01037bc:	c7 04 24 50 c8 10 c0 	movl   $0xc010c850,(%esp)
c01037c3:	e8 38 cc ff ff       	call   c0100400 <__panic>
    assert(next->vm_start < next->vm_end);
c01037c8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01037cb:	8b 50 04             	mov    0x4(%eax),%edx
c01037ce:	8b 45 0c             	mov    0xc(%ebp),%eax
c01037d1:	8b 40 08             	mov    0x8(%eax),%eax
c01037d4:	39 c2                	cmp    %eax,%edx
c01037d6:	72 24                	jb     c01037fc <check_vma_overlap+0xa2>
c01037d8:	c7 44 24 0c 7f c8 10 	movl   $0xc010c87f,0xc(%esp)
c01037df:	c0 
c01037e0:	c7 44 24 08 3b c8 10 	movl   $0xc010c83b,0x8(%esp)
c01037e7:	c0 
c01037e8:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c01037ef:	00 
c01037f0:	c7 04 24 50 c8 10 c0 	movl   $0xc010c850,(%esp)
c01037f7:	e8 04 cc ff ff       	call   c0100400 <__panic>
}
c01037fc:	c9                   	leave  
c01037fd:	c3                   	ret    

c01037fe <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
c01037fe:	55                   	push   %ebp
c01037ff:	89 e5                	mov    %esp,%ebp
c0103801:	83 ec 48             	sub    $0x48,%esp
    assert(vma->vm_start < vma->vm_end);
c0103804:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103807:	8b 50 04             	mov    0x4(%eax),%edx
c010380a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010380d:	8b 40 08             	mov    0x8(%eax),%eax
c0103810:	39 c2                	cmp    %eax,%edx
c0103812:	72 24                	jb     c0103838 <insert_vma_struct+0x3a>
c0103814:	c7 44 24 0c 9d c8 10 	movl   $0xc010c89d,0xc(%esp)
c010381b:	c0 
c010381c:	c7 44 24 08 3b c8 10 	movl   $0xc010c83b,0x8(%esp)
c0103823:	c0 
c0103824:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
c010382b:	00 
c010382c:	c7 04 24 50 c8 10 c0 	movl   $0xc010c850,(%esp)
c0103833:	e8 c8 cb ff ff       	call   c0100400 <__panic>
    list_entry_t *list = &(mm->mmap_list);
c0103838:	8b 45 08             	mov    0x8(%ebp),%eax
c010383b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_entry_t *le_prev = list, *le_next;
c010383e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103841:	89 45 f4             	mov    %eax,-0xc(%ebp)

        list_entry_t *le = list;
c0103844:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103847:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while ((le = list_next(le)) != list) {
c010384a:	eb 21                	jmp    c010386d <insert_vma_struct+0x6f>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
c010384c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010384f:	83 e8 10             	sub    $0x10,%eax
c0103852:	89 45 e8             	mov    %eax,-0x18(%ebp)
            if (mmap_prev->vm_start > vma->vm_start) {
c0103855:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103858:	8b 50 04             	mov    0x4(%eax),%edx
c010385b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010385e:	8b 40 04             	mov    0x4(%eax),%eax
c0103861:	39 c2                	cmp    %eax,%edx
c0103863:	76 02                	jbe    c0103867 <insert_vma_struct+0x69>
                break;
c0103865:	eb 1d                	jmp    c0103884 <insert_vma_struct+0x86>
            }
            le_prev = le;
c0103867:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010386a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010386d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103870:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103873:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103876:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list) {
c0103879:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010387c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010387f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103882:	75 c8                	jne    c010384c <insert_vma_struct+0x4e>
c0103884:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103887:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010388a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010388d:	8b 40 04             	mov    0x4(%eax),%eax
        }

    le_next = list_next(le_prev);
c0103890:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    /* check overlap */
    if (le_prev != list) {
c0103893:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103896:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103899:	74 15                	je     c01038b0 <insert_vma_struct+0xb2>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
c010389b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010389e:	8d 50 f0             	lea    -0x10(%eax),%edx
c01038a1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01038a4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01038a8:	89 14 24             	mov    %edx,(%esp)
c01038ab:	e8 aa fe ff ff       	call   c010375a <check_vma_overlap>
    }
    if (le_next != list) {
c01038b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01038b3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01038b6:	74 15                	je     c01038cd <insert_vma_struct+0xcf>
        check_vma_overlap(vma, le2vma(le_next, list_link));
c01038b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01038bb:	83 e8 10             	sub    $0x10,%eax
c01038be:	89 44 24 04          	mov    %eax,0x4(%esp)
c01038c2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01038c5:	89 04 24             	mov    %eax,(%esp)
c01038c8:	e8 8d fe ff ff       	call   c010375a <check_vma_overlap>
    }

    vma->vm_mm = mm;
c01038cd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01038d0:	8b 55 08             	mov    0x8(%ebp),%edx
c01038d3:	89 10                	mov    %edx,(%eax)
    list_add_after(le_prev, &(vma->list_link));
c01038d5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01038d8:	8d 50 10             	lea    0x10(%eax),%edx
c01038db:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038de:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01038e1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
c01038e4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01038e7:	8b 40 04             	mov    0x4(%eax),%eax
c01038ea:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01038ed:	89 55 d0             	mov    %edx,-0x30(%ebp)
c01038f0:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01038f3:	89 55 cc             	mov    %edx,-0x34(%ebp)
c01038f6:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01038f9:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01038fc:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01038ff:	89 10                	mov    %edx,(%eax)
c0103901:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103904:	8b 10                	mov    (%eax),%edx
c0103906:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103909:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010390c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010390f:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0103912:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103915:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103918:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010391b:	89 10                	mov    %edx,(%eax)

    mm->map_count ++;
c010391d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103920:	8b 40 10             	mov    0x10(%eax),%eax
c0103923:	8d 50 01             	lea    0x1(%eax),%edx
c0103926:	8b 45 08             	mov    0x8(%ebp),%eax
c0103929:	89 50 10             	mov    %edx,0x10(%eax)
}
c010392c:	c9                   	leave  
c010392d:	c3                   	ret    

c010392e <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
c010392e:	55                   	push   %ebp
c010392f:	89 e5                	mov    %esp,%ebp
c0103931:	83 ec 38             	sub    $0x38,%esp
    assert(mm_count(mm) == 0);
c0103934:	8b 45 08             	mov    0x8(%ebp),%eax
c0103937:	89 04 24             	mov    %eax,(%esp)
c010393a:	e8 20 fc ff ff       	call   c010355f <mm_count>
c010393f:	85 c0                	test   %eax,%eax
c0103941:	74 24                	je     c0103967 <mm_destroy+0x39>
c0103943:	c7 44 24 0c b9 c8 10 	movl   $0xc010c8b9,0xc(%esp)
c010394a:	c0 
c010394b:	c7 44 24 08 3b c8 10 	movl   $0xc010c83b,0x8(%esp)
c0103952:	c0 
c0103953:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c010395a:	00 
c010395b:	c7 04 24 50 c8 10 c0 	movl   $0xc010c850,(%esp)
c0103962:	e8 99 ca ff ff       	call   c0100400 <__panic>

    list_entry_t *list = &(mm->mmap_list), *le;
c0103967:	8b 45 08             	mov    0x8(%ebp),%eax
c010396a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(list)) != list) {
c010396d:	eb 36                	jmp    c01039a5 <mm_destroy+0x77>
c010396f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103972:	89 45 ec             	mov    %eax,-0x14(%ebp)
    __list_del(listelm->prev, listelm->next);
c0103975:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103978:	8b 40 04             	mov    0x4(%eax),%eax
c010397b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010397e:	8b 12                	mov    (%edx),%edx
c0103980:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0103983:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0103986:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103989:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010398c:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010398f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103992:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0103995:	89 10                	mov    %edx,(%eax)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
c0103997:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010399a:	83 e8 10             	sub    $0x10,%eax
c010399d:	89 04 24             	mov    %eax,(%esp)
c01039a0:	e8 68 19 00 00       	call   c010530d <kfree>
c01039a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039a8:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
c01039ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01039ae:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(list)) != list) {
c01039b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01039b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01039b7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01039ba:	75 b3                	jne    c010396f <mm_destroy+0x41>
    }
    kfree(mm); //kfree mm
c01039bc:	8b 45 08             	mov    0x8(%ebp),%eax
c01039bf:	89 04 24             	mov    %eax,(%esp)
c01039c2:	e8 46 19 00 00       	call   c010530d <kfree>
    mm=NULL;
c01039c7:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
}
c01039ce:	c9                   	leave  
c01039cf:	c3                   	ret    

c01039d0 <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
c01039d0:	55                   	push   %ebp
c01039d1:	89 e5                	mov    %esp,%ebp
c01039d3:	83 ec 38             	sub    $0x38,%esp
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
c01039d6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01039d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01039dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01039df:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01039e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01039e7:	c7 45 e8 00 10 00 00 	movl   $0x1000,-0x18(%ebp)
c01039ee:	8b 45 10             	mov    0x10(%ebp),%eax
c01039f1:	8b 55 0c             	mov    0xc(%ebp),%edx
c01039f4:	01 c2                	add    %eax,%edx
c01039f6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01039f9:	01 d0                	add    %edx,%eax
c01039fb:	83 e8 01             	sub    $0x1,%eax
c01039fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103a01:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103a04:	ba 00 00 00 00       	mov    $0x0,%edx
c0103a09:	f7 75 e8             	divl   -0x18(%ebp)
c0103a0c:	89 d0                	mov    %edx,%eax
c0103a0e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103a11:	29 c2                	sub    %eax,%edx
c0103a13:	89 d0                	mov    %edx,%eax
c0103a15:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if (!USER_ACCESS(start, end)) {
c0103a18:	81 7d ec ff ff 1f 00 	cmpl   $0x1fffff,-0x14(%ebp)
c0103a1f:	76 11                	jbe    c0103a32 <mm_map+0x62>
c0103a21:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103a24:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0103a27:	73 09                	jae    c0103a32 <mm_map+0x62>
c0103a29:	81 7d e0 00 00 00 b0 	cmpl   $0xb0000000,-0x20(%ebp)
c0103a30:	76 0a                	jbe    c0103a3c <mm_map+0x6c>
        return -E_INVAL;
c0103a32:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0103a37:	e9 ae 00 00 00       	jmp    c0103aea <mm_map+0x11a>
    }

    assert(mm != NULL);
c0103a3c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0103a40:	75 24                	jne    c0103a66 <mm_map+0x96>
c0103a42:	c7 44 24 0c cb c8 10 	movl   $0xc010c8cb,0xc(%esp)
c0103a49:	c0 
c0103a4a:	c7 44 24 08 3b c8 10 	movl   $0xc010c83b,0x8(%esp)
c0103a51:	c0 
c0103a52:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
c0103a59:	00 
c0103a5a:	c7 04 24 50 c8 10 c0 	movl   $0xc010c850,(%esp)
c0103a61:	e8 9a c9 ff ff       	call   c0100400 <__panic>

    int ret = -E_INVAL;
c0103a66:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
c0103a6d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103a70:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103a74:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a77:	89 04 24             	mov    %eax,(%esp)
c0103a7a:	e8 2a fc ff ff       	call   c01036a9 <find_vma>
c0103a7f:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103a82:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0103a86:	74 0d                	je     c0103a95 <mm_map+0xc5>
c0103a88:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103a8b:	8b 40 04             	mov    0x4(%eax),%eax
c0103a8e:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0103a91:	73 02                	jae    c0103a95 <mm_map+0xc5>
        goto out;
c0103a93:	eb 52                	jmp    c0103ae7 <mm_map+0x117>
    }
    ret = -E_NO_MEM;
c0103a95:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
c0103a9c:	8b 45 14             	mov    0x14(%ebp),%eax
c0103a9f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103aa3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103aa6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103aaa:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103aad:	89 04 24             	mov    %eax,(%esp)
c0103ab0:	e8 b9 fb ff ff       	call   c010366e <vma_create>
c0103ab5:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103ab8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0103abc:	75 02                	jne    c0103ac0 <mm_map+0xf0>
        goto out;
c0103abe:	eb 27                	jmp    c0103ae7 <mm_map+0x117>
    }
    insert_vma_struct(mm, vma);
c0103ac0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103ac3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103ac7:	8b 45 08             	mov    0x8(%ebp),%eax
c0103aca:	89 04 24             	mov    %eax,(%esp)
c0103acd:	e8 2c fd ff ff       	call   c01037fe <insert_vma_struct>
    if (vma_store != NULL) {
c0103ad2:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0103ad6:	74 08                	je     c0103ae0 <mm_map+0x110>
        *vma_store = vma;
c0103ad8:	8b 45 18             	mov    0x18(%ebp),%eax
c0103adb:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103ade:	89 10                	mov    %edx,(%eax)
    }
    ret = 0;
c0103ae0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

out:
    return ret;
c0103ae7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103aea:	c9                   	leave  
c0103aeb:	c3                   	ret    

c0103aec <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
c0103aec:	55                   	push   %ebp
c0103aed:	89 e5                	mov    %esp,%ebp
c0103aef:	56                   	push   %esi
c0103af0:	53                   	push   %ebx
c0103af1:	83 ec 40             	sub    $0x40,%esp
    assert(to != NULL && from != NULL);
c0103af4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0103af8:	74 06                	je     c0103b00 <dup_mmap+0x14>
c0103afa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0103afe:	75 24                	jne    c0103b24 <dup_mmap+0x38>
c0103b00:	c7 44 24 0c d6 c8 10 	movl   $0xc010c8d6,0xc(%esp)
c0103b07:	c0 
c0103b08:	c7 44 24 08 3b c8 10 	movl   $0xc010c83b,0x8(%esp)
c0103b0f:	c0 
c0103b10:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
c0103b17:	00 
c0103b18:	c7 04 24 50 c8 10 c0 	movl   $0xc010c850,(%esp)
c0103b1f:	e8 dc c8 ff ff       	call   c0100400 <__panic>
    list_entry_t *list = &(from->mmap_list), *le = list;
c0103b24:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103b27:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103b2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103b2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_prev(le)) != list) {
c0103b30:	e9 92 00 00 00       	jmp    c0103bc7 <dup_mmap+0xdb>
        struct vma_struct *vma, *nvma;
        vma = le2vma(le, list_link);
c0103b35:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b38:	83 e8 10             	sub    $0x10,%eax
c0103b3b:	89 45 ec             	mov    %eax,-0x14(%ebp)
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
c0103b3e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103b41:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103b44:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103b47:	8b 50 08             	mov    0x8(%eax),%edx
c0103b4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103b4d:	8b 40 04             	mov    0x4(%eax),%eax
c0103b50:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0103b54:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103b58:	89 04 24             	mov    %eax,(%esp)
c0103b5b:	e8 0e fb ff ff       	call   c010366e <vma_create>
c0103b60:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (nvma == NULL) {
c0103b63:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103b67:	75 07                	jne    c0103b70 <dup_mmap+0x84>
            return -E_NO_MEM;
c0103b69:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0103b6e:	eb 76                	jmp    c0103be6 <dup_mmap+0xfa>
        }

        insert_vma_struct(to, nvma);
c0103b70:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103b73:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103b77:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b7a:	89 04 24             	mov    %eax,(%esp)
c0103b7d:	e8 7c fc ff ff       	call   c01037fe <insert_vma_struct>

        bool share = 0;
c0103b82:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
c0103b89:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103b8c:	8b 58 08             	mov    0x8(%eax),%ebx
c0103b8f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103b92:	8b 48 04             	mov    0x4(%eax),%ecx
c0103b95:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103b98:	8b 50 0c             	mov    0xc(%eax),%edx
c0103b9b:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b9e:	8b 40 0c             	mov    0xc(%eax),%eax
c0103ba1:	8b 75 e4             	mov    -0x1c(%ebp),%esi
c0103ba4:	89 74 24 10          	mov    %esi,0x10(%esp)
c0103ba8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0103bac:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0103bb0:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103bb4:	89 04 24             	mov    %eax,(%esp)
c0103bb7:	e8 f2 43 00 00       	call   c0107fae <copy_range>
c0103bbc:	85 c0                	test   %eax,%eax
c0103bbe:	74 07                	je     c0103bc7 <dup_mmap+0xdb>
            return -E_NO_MEM;
c0103bc0:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0103bc5:	eb 1f                	jmp    c0103be6 <dup_mmap+0xfa>
c0103bc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103bca:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->prev;
c0103bcd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103bd0:	8b 00                	mov    (%eax),%eax
    while ((le = list_prev(le)) != list) {
c0103bd2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103bd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103bd8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103bdb:	0f 85 54 ff ff ff    	jne    c0103b35 <dup_mmap+0x49>
        }
    }
    return 0;
c0103be1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103be6:	83 c4 40             	add    $0x40,%esp
c0103be9:	5b                   	pop    %ebx
c0103bea:	5e                   	pop    %esi
c0103beb:	5d                   	pop    %ebp
c0103bec:	c3                   	ret    

c0103bed <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
c0103bed:	55                   	push   %ebp
c0103bee:	89 e5                	mov    %esp,%ebp
c0103bf0:	83 ec 38             	sub    $0x38,%esp
    assert(mm != NULL && mm_count(mm) == 0);
c0103bf3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0103bf7:	74 0f                	je     c0103c08 <exit_mmap+0x1b>
c0103bf9:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bfc:	89 04 24             	mov    %eax,(%esp)
c0103bff:	e8 5b f9 ff ff       	call   c010355f <mm_count>
c0103c04:	85 c0                	test   %eax,%eax
c0103c06:	74 24                	je     c0103c2c <exit_mmap+0x3f>
c0103c08:	c7 44 24 0c f4 c8 10 	movl   $0xc010c8f4,0xc(%esp)
c0103c0f:	c0 
c0103c10:	c7 44 24 08 3b c8 10 	movl   $0xc010c83b,0x8(%esp)
c0103c17:	c0 
c0103c18:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c0103c1f:	00 
c0103c20:	c7 04 24 50 c8 10 c0 	movl   $0xc010c850,(%esp)
c0103c27:	e8 d4 c7 ff ff       	call   c0100400 <__panic>
    pde_t *pgdir = mm->pgdir;
c0103c2c:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c2f:	8b 40 0c             	mov    0xc(%eax),%eax
c0103c32:	89 45 f0             	mov    %eax,-0x10(%ebp)
    list_entry_t *list = &(mm->mmap_list), *le = list;
c0103c35:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c38:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103c3b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103c3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(le)) != list) {
c0103c41:	eb 28                	jmp    c0103c6b <exit_mmap+0x7e>
        struct vma_struct *vma = le2vma(le, list_link);
c0103c43:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c46:	83 e8 10             	sub    $0x10,%eax
c0103c49:	89 45 e8             	mov    %eax,-0x18(%ebp)
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
c0103c4c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103c4f:	8b 50 08             	mov    0x8(%eax),%edx
c0103c52:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103c55:	8b 40 04             	mov    0x4(%eax),%eax
c0103c58:	89 54 24 08          	mov    %edx,0x8(%esp)
c0103c5c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103c60:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c63:	89 04 24             	mov    %eax,(%esp)
c0103c66:	e8 48 41 00 00       	call   c0107db3 <unmap_range>
c0103c6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c6e:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
c0103c71:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103c74:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != list) {
c0103c77:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103c7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c7d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103c80:	75 c1                	jne    c0103c43 <exit_mmap+0x56>
    }
    while ((le = list_next(le)) != list) {
c0103c82:	eb 28                	jmp    c0103cac <exit_mmap+0xbf>
        struct vma_struct *vma = le2vma(le, list_link);
c0103c84:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c87:	83 e8 10             	sub    $0x10,%eax
c0103c8a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        exit_range(pgdir, vma->vm_start, vma->vm_end);
c0103c8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103c90:	8b 50 08             	mov    0x8(%eax),%edx
c0103c93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103c96:	8b 40 04             	mov    0x4(%eax),%eax
c0103c99:	89 54 24 08          	mov    %edx,0x8(%esp)
c0103c9d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103ca1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103ca4:	89 04 24             	mov    %eax,(%esp)
c0103ca7:	e8 fb 41 00 00       	call   c0107ea7 <exit_range>
c0103cac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103caf:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103cb2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103cb5:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != list) {
c0103cb8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103cbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103cbe:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103cc1:	75 c1                	jne    c0103c84 <exit_mmap+0x97>
    }
}
c0103cc3:	c9                   	leave  
c0103cc4:	c3                   	ret    

c0103cc5 <copy_from_user>:

bool
copy_from_user(struct mm_struct *mm, void *dst, const void *src, size_t len, bool writable) {
c0103cc5:	55                   	push   %ebp
c0103cc6:	89 e5                	mov    %esp,%ebp
c0103cc8:	83 ec 18             	sub    $0x18,%esp
    if (!user_mem_check(mm, (uintptr_t)src, len, writable)) {
c0103ccb:	8b 45 10             	mov    0x10(%ebp),%eax
c0103cce:	8b 55 18             	mov    0x18(%ebp),%edx
c0103cd1:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0103cd5:	8b 55 14             	mov    0x14(%ebp),%edx
c0103cd8:	89 54 24 08          	mov    %edx,0x8(%esp)
c0103cdc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103ce0:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ce3:	89 04 24             	mov    %eax,(%esp)
c0103ce6:	e8 a6 09 00 00       	call   c0104691 <user_mem_check>
c0103ceb:	85 c0                	test   %eax,%eax
c0103ced:	75 07                	jne    c0103cf6 <copy_from_user+0x31>
        return 0;
c0103cef:	b8 00 00 00 00       	mov    $0x0,%eax
c0103cf4:	eb 1e                	jmp    c0103d14 <copy_from_user+0x4f>
    }
    memcpy(dst, src, len);
c0103cf6:	8b 45 14             	mov    0x14(%ebp),%eax
c0103cf9:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103cfd:	8b 45 10             	mov    0x10(%ebp),%eax
c0103d00:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103d04:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103d07:	89 04 24             	mov    %eax,(%esp)
c0103d0a:	e8 25 79 00 00       	call   c010b634 <memcpy>
    return 1;
c0103d0f:	b8 01 00 00 00       	mov    $0x1,%eax
}
c0103d14:	c9                   	leave  
c0103d15:	c3                   	ret    

c0103d16 <copy_to_user>:

bool
copy_to_user(struct mm_struct *mm, void *dst, const void *src, size_t len) {
c0103d16:	55                   	push   %ebp
c0103d17:	89 e5                	mov    %esp,%ebp
c0103d19:	83 ec 18             	sub    $0x18,%esp
    if (!user_mem_check(mm, (uintptr_t)dst, len, 1)) {
c0103d1c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103d1f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c0103d26:	00 
c0103d27:	8b 55 14             	mov    0x14(%ebp),%edx
c0103d2a:	89 54 24 08          	mov    %edx,0x8(%esp)
c0103d2e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103d32:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d35:	89 04 24             	mov    %eax,(%esp)
c0103d38:	e8 54 09 00 00       	call   c0104691 <user_mem_check>
c0103d3d:	85 c0                	test   %eax,%eax
c0103d3f:	75 07                	jne    c0103d48 <copy_to_user+0x32>
        return 0;
c0103d41:	b8 00 00 00 00       	mov    $0x0,%eax
c0103d46:	eb 1e                	jmp    c0103d66 <copy_to_user+0x50>
    }
    memcpy(dst, src, len);
c0103d48:	8b 45 14             	mov    0x14(%ebp),%eax
c0103d4b:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103d4f:	8b 45 10             	mov    0x10(%ebp),%eax
c0103d52:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103d56:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103d59:	89 04 24             	mov    %eax,(%esp)
c0103d5c:	e8 d3 78 00 00       	call   c010b634 <memcpy>
    return 1;
c0103d61:	b8 01 00 00 00       	mov    $0x1,%eax
}
c0103d66:	c9                   	leave  
c0103d67:	c3                   	ret    

c0103d68 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
c0103d68:	55                   	push   %ebp
c0103d69:	89 e5                	mov    %esp,%ebp
c0103d6b:	83 ec 08             	sub    $0x8,%esp
    check_vmm();
c0103d6e:	e8 02 00 00 00       	call   c0103d75 <check_vmm>
}
c0103d73:	c9                   	leave  
c0103d74:	c3                   	ret    

c0103d75 <check_vmm>:

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
c0103d75:	55                   	push   %ebp
c0103d76:	89 e5                	mov    %esp,%ebp
c0103d78:	83 ec 28             	sub    $0x28,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0103d7b:	e8 f4 37 00 00       	call   c0107574 <nr_free_pages>
c0103d80:	89 45 f4             	mov    %eax,-0xc(%ebp)
    
    check_vma_struct();
c0103d83:	e8 13 00 00 00       	call   c0103d9b <check_vma_struct>
    check_pgfault();
c0103d88:	e8 a7 04 00 00       	call   c0104234 <check_pgfault>

    cprintf("check_vmm() succeeded.\n");
c0103d8d:	c7 04 24 14 c9 10 c0 	movl   $0xc010c914,(%esp)
c0103d94:	e8 10 c5 ff ff       	call   c01002a9 <cprintf>
}
c0103d99:	c9                   	leave  
c0103d9a:	c3                   	ret    

c0103d9b <check_vma_struct>:

static void
check_vma_struct(void) {
c0103d9b:	55                   	push   %ebp
c0103d9c:	89 e5                	mov    %esp,%ebp
c0103d9e:	83 ec 68             	sub    $0x68,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0103da1:	e8 ce 37 00 00       	call   c0107574 <nr_free_pages>
c0103da6:	89 45 ec             	mov    %eax,-0x14(%ebp)

    struct mm_struct *mm = mm_create();
c0103da9:	e8 27 f8 ff ff       	call   c01035d5 <mm_create>
c0103dae:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(mm != NULL);
c0103db1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103db5:	75 24                	jne    c0103ddb <check_vma_struct+0x40>
c0103db7:	c7 44 24 0c cb c8 10 	movl   $0xc010c8cb,0xc(%esp)
c0103dbe:	c0 
c0103dbf:	c7 44 24 08 3b c8 10 	movl   $0xc010c83b,0x8(%esp)
c0103dc6:	c0 
c0103dc7:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c0103dce:	00 
c0103dcf:	c7 04 24 50 c8 10 c0 	movl   $0xc010c850,(%esp)
c0103dd6:	e8 25 c6 ff ff       	call   c0100400 <__panic>

    int step1 = 10, step2 = step1 * 10;
c0103ddb:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
c0103de2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103de5:	89 d0                	mov    %edx,%eax
c0103de7:	c1 e0 02             	shl    $0x2,%eax
c0103dea:	01 d0                	add    %edx,%eax
c0103dec:	01 c0                	add    %eax,%eax
c0103dee:	89 45 e0             	mov    %eax,-0x20(%ebp)

    int i;
    for (i = step1; i >= 1; i --) {
c0103df1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103df4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103df7:	eb 70                	jmp    c0103e69 <check_vma_struct+0xce>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0103df9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103dfc:	89 d0                	mov    %edx,%eax
c0103dfe:	c1 e0 02             	shl    $0x2,%eax
c0103e01:	01 d0                	add    %edx,%eax
c0103e03:	83 c0 02             	add    $0x2,%eax
c0103e06:	89 c1                	mov    %eax,%ecx
c0103e08:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103e0b:	89 d0                	mov    %edx,%eax
c0103e0d:	c1 e0 02             	shl    $0x2,%eax
c0103e10:	01 d0                	add    %edx,%eax
c0103e12:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103e19:	00 
c0103e1a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0103e1e:	89 04 24             	mov    %eax,(%esp)
c0103e21:	e8 48 f8 ff ff       	call   c010366e <vma_create>
c0103e26:	89 45 dc             	mov    %eax,-0x24(%ebp)
        assert(vma != NULL);
c0103e29:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0103e2d:	75 24                	jne    c0103e53 <check_vma_struct+0xb8>
c0103e2f:	c7 44 24 0c 2c c9 10 	movl   $0xc010c92c,0xc(%esp)
c0103e36:	c0 
c0103e37:	c7 44 24 08 3b c8 10 	movl   $0xc010c83b,0x8(%esp)
c0103e3e:	c0 
c0103e3f:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
c0103e46:	00 
c0103e47:	c7 04 24 50 c8 10 c0 	movl   $0xc010c850,(%esp)
c0103e4e:	e8 ad c5 ff ff       	call   c0100400 <__panic>
        insert_vma_struct(mm, vma);
c0103e53:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103e56:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103e5a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103e5d:	89 04 24             	mov    %eax,(%esp)
c0103e60:	e8 99 f9 ff ff       	call   c01037fe <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
c0103e65:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0103e69:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103e6d:	7f 8a                	jg     c0103df9 <check_vma_struct+0x5e>
    }

    for (i = step1 + 1; i <= step2; i ++) {
c0103e6f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103e72:	83 c0 01             	add    $0x1,%eax
c0103e75:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103e78:	eb 70                	jmp    c0103eea <check_vma_struct+0x14f>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0103e7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103e7d:	89 d0                	mov    %edx,%eax
c0103e7f:	c1 e0 02             	shl    $0x2,%eax
c0103e82:	01 d0                	add    %edx,%eax
c0103e84:	83 c0 02             	add    $0x2,%eax
c0103e87:	89 c1                	mov    %eax,%ecx
c0103e89:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103e8c:	89 d0                	mov    %edx,%eax
c0103e8e:	c1 e0 02             	shl    $0x2,%eax
c0103e91:	01 d0                	add    %edx,%eax
c0103e93:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103e9a:	00 
c0103e9b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0103e9f:	89 04 24             	mov    %eax,(%esp)
c0103ea2:	e8 c7 f7 ff ff       	call   c010366e <vma_create>
c0103ea7:	89 45 d8             	mov    %eax,-0x28(%ebp)
        assert(vma != NULL);
c0103eaa:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0103eae:	75 24                	jne    c0103ed4 <check_vma_struct+0x139>
c0103eb0:	c7 44 24 0c 2c c9 10 	movl   $0xc010c92c,0xc(%esp)
c0103eb7:	c0 
c0103eb8:	c7 44 24 08 3b c8 10 	movl   $0xc010c83b,0x8(%esp)
c0103ebf:	c0 
c0103ec0:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c0103ec7:	00 
c0103ec8:	c7 04 24 50 c8 10 c0 	movl   $0xc010c850,(%esp)
c0103ecf:	e8 2c c5 ff ff       	call   c0100400 <__panic>
        insert_vma_struct(mm, vma);
c0103ed4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103ed7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103edb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103ede:	89 04 24             	mov    %eax,(%esp)
c0103ee1:	e8 18 f9 ff ff       	call   c01037fe <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
c0103ee6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0103eea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103eed:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0103ef0:	7e 88                	jle    c0103e7a <check_vma_struct+0xdf>
    }

    list_entry_t *le = list_next(&(mm->mmap_list));
c0103ef2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103ef5:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0103ef8:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103efb:	8b 40 04             	mov    0x4(%eax),%eax
c0103efe:	89 45 f0             	mov    %eax,-0x10(%ebp)

    for (i = 1; i <= step2; i ++) {
c0103f01:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c0103f08:	e9 97 00 00 00       	jmp    c0103fa4 <check_vma_struct+0x209>
        assert(le != &(mm->mmap_list));
c0103f0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103f10:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103f13:	75 24                	jne    c0103f39 <check_vma_struct+0x19e>
c0103f15:	c7 44 24 0c 38 c9 10 	movl   $0xc010c938,0xc(%esp)
c0103f1c:	c0 
c0103f1d:	c7 44 24 08 3b c8 10 	movl   $0xc010c83b,0x8(%esp)
c0103f24:	c0 
c0103f25:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
c0103f2c:	00 
c0103f2d:	c7 04 24 50 c8 10 c0 	movl   $0xc010c850,(%esp)
c0103f34:	e8 c7 c4 ff ff       	call   c0100400 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
c0103f39:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103f3c:	83 e8 10             	sub    $0x10,%eax
c0103f3f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
c0103f42:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103f45:	8b 48 04             	mov    0x4(%eax),%ecx
c0103f48:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103f4b:	89 d0                	mov    %edx,%eax
c0103f4d:	c1 e0 02             	shl    $0x2,%eax
c0103f50:	01 d0                	add    %edx,%eax
c0103f52:	39 c1                	cmp    %eax,%ecx
c0103f54:	75 17                	jne    c0103f6d <check_vma_struct+0x1d2>
c0103f56:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103f59:	8b 48 08             	mov    0x8(%eax),%ecx
c0103f5c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103f5f:	89 d0                	mov    %edx,%eax
c0103f61:	c1 e0 02             	shl    $0x2,%eax
c0103f64:	01 d0                	add    %edx,%eax
c0103f66:	83 c0 02             	add    $0x2,%eax
c0103f69:	39 c1                	cmp    %eax,%ecx
c0103f6b:	74 24                	je     c0103f91 <check_vma_struct+0x1f6>
c0103f6d:	c7 44 24 0c 50 c9 10 	movl   $0xc010c950,0xc(%esp)
c0103f74:	c0 
c0103f75:	c7 44 24 08 3b c8 10 	movl   $0xc010c83b,0x8(%esp)
c0103f7c:	c0 
c0103f7d:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
c0103f84:	00 
c0103f85:	c7 04 24 50 c8 10 c0 	movl   $0xc010c850,(%esp)
c0103f8c:	e8 6f c4 ff ff       	call   c0100400 <__panic>
c0103f91:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103f94:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c0103f97:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103f9a:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0103f9d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (i = 1; i <= step2; i ++) {
c0103fa0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0103fa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103fa7:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0103faa:	0f 8e 5d ff ff ff    	jle    c0103f0d <check_vma_struct+0x172>
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c0103fb0:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
c0103fb7:	e9 cd 01 00 00       	jmp    c0104189 <check_vma_struct+0x3ee>
        struct vma_struct *vma1 = find_vma(mm, i);
c0103fbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103fbf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103fc3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103fc6:	89 04 24             	mov    %eax,(%esp)
c0103fc9:	e8 db f6 ff ff       	call   c01036a9 <find_vma>
c0103fce:	89 45 d0             	mov    %eax,-0x30(%ebp)
        assert(vma1 != NULL);
c0103fd1:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c0103fd5:	75 24                	jne    c0103ffb <check_vma_struct+0x260>
c0103fd7:	c7 44 24 0c 85 c9 10 	movl   $0xc010c985,0xc(%esp)
c0103fde:	c0 
c0103fdf:	c7 44 24 08 3b c8 10 	movl   $0xc010c83b,0x8(%esp)
c0103fe6:	c0 
c0103fe7:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
c0103fee:	00 
c0103fef:	c7 04 24 50 c8 10 c0 	movl   $0xc010c850,(%esp)
c0103ff6:	e8 05 c4 ff ff       	call   c0100400 <__panic>
        struct vma_struct *vma2 = find_vma(mm, i+1);
c0103ffb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ffe:	83 c0 01             	add    $0x1,%eax
c0104001:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104005:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104008:	89 04 24             	mov    %eax,(%esp)
c010400b:	e8 99 f6 ff ff       	call   c01036a9 <find_vma>
c0104010:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(vma2 != NULL);
c0104013:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0104017:	75 24                	jne    c010403d <check_vma_struct+0x2a2>
c0104019:	c7 44 24 0c 92 c9 10 	movl   $0xc010c992,0xc(%esp)
c0104020:	c0 
c0104021:	c7 44 24 08 3b c8 10 	movl   $0xc010c83b,0x8(%esp)
c0104028:	c0 
c0104029:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
c0104030:	00 
c0104031:	c7 04 24 50 c8 10 c0 	movl   $0xc010c850,(%esp)
c0104038:	e8 c3 c3 ff ff       	call   c0100400 <__panic>
        struct vma_struct *vma3 = find_vma(mm, i+2);
c010403d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104040:	83 c0 02             	add    $0x2,%eax
c0104043:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104047:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010404a:	89 04 24             	mov    %eax,(%esp)
c010404d:	e8 57 f6 ff ff       	call   c01036a9 <find_vma>
c0104052:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(vma3 == NULL);
c0104055:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0104059:	74 24                	je     c010407f <check_vma_struct+0x2e4>
c010405b:	c7 44 24 0c 9f c9 10 	movl   $0xc010c99f,0xc(%esp)
c0104062:	c0 
c0104063:	c7 44 24 08 3b c8 10 	movl   $0xc010c83b,0x8(%esp)
c010406a:	c0 
c010406b:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c0104072:	00 
c0104073:	c7 04 24 50 c8 10 c0 	movl   $0xc010c850,(%esp)
c010407a:	e8 81 c3 ff ff       	call   c0100400 <__panic>
        struct vma_struct *vma4 = find_vma(mm, i+3);
c010407f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104082:	83 c0 03             	add    $0x3,%eax
c0104085:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104089:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010408c:	89 04 24             	mov    %eax,(%esp)
c010408f:	e8 15 f6 ff ff       	call   c01036a9 <find_vma>
c0104094:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        assert(vma4 == NULL);
c0104097:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
c010409b:	74 24                	je     c01040c1 <check_vma_struct+0x326>
c010409d:	c7 44 24 0c ac c9 10 	movl   $0xc010c9ac,0xc(%esp)
c01040a4:	c0 
c01040a5:	c7 44 24 08 3b c8 10 	movl   $0xc010c83b,0x8(%esp)
c01040ac:	c0 
c01040ad:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
c01040b4:	00 
c01040b5:	c7 04 24 50 c8 10 c0 	movl   $0xc010c850,(%esp)
c01040bc:	e8 3f c3 ff ff       	call   c0100400 <__panic>
        struct vma_struct *vma5 = find_vma(mm, i+4);
c01040c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01040c4:	83 c0 04             	add    $0x4,%eax
c01040c7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01040cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01040ce:	89 04 24             	mov    %eax,(%esp)
c01040d1:	e8 d3 f5 ff ff       	call   c01036a9 <find_vma>
c01040d6:	89 45 c0             	mov    %eax,-0x40(%ebp)
        assert(vma5 == NULL);
c01040d9:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c01040dd:	74 24                	je     c0104103 <check_vma_struct+0x368>
c01040df:	c7 44 24 0c b9 c9 10 	movl   $0xc010c9b9,0xc(%esp)
c01040e6:	c0 
c01040e7:	c7 44 24 08 3b c8 10 	movl   $0xc010c83b,0x8(%esp)
c01040ee:	c0 
c01040ef:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
c01040f6:	00 
c01040f7:	c7 04 24 50 c8 10 c0 	movl   $0xc010c850,(%esp)
c01040fe:	e8 fd c2 ff ff       	call   c0100400 <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
c0104103:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104106:	8b 50 04             	mov    0x4(%eax),%edx
c0104109:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010410c:	39 c2                	cmp    %eax,%edx
c010410e:	75 10                	jne    c0104120 <check_vma_struct+0x385>
c0104110:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104113:	8b 50 08             	mov    0x8(%eax),%edx
c0104116:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104119:	83 c0 02             	add    $0x2,%eax
c010411c:	39 c2                	cmp    %eax,%edx
c010411e:	74 24                	je     c0104144 <check_vma_struct+0x3a9>
c0104120:	c7 44 24 0c c8 c9 10 	movl   $0xc010c9c8,0xc(%esp)
c0104127:	c0 
c0104128:	c7 44 24 08 3b c8 10 	movl   $0xc010c83b,0x8(%esp)
c010412f:	c0 
c0104130:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
c0104137:	00 
c0104138:	c7 04 24 50 c8 10 c0 	movl   $0xc010c850,(%esp)
c010413f:	e8 bc c2 ff ff       	call   c0100400 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
c0104144:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104147:	8b 50 04             	mov    0x4(%eax),%edx
c010414a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010414d:	39 c2                	cmp    %eax,%edx
c010414f:	75 10                	jne    c0104161 <check_vma_struct+0x3c6>
c0104151:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104154:	8b 50 08             	mov    0x8(%eax),%edx
c0104157:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010415a:	83 c0 02             	add    $0x2,%eax
c010415d:	39 c2                	cmp    %eax,%edx
c010415f:	74 24                	je     c0104185 <check_vma_struct+0x3ea>
c0104161:	c7 44 24 0c f8 c9 10 	movl   $0xc010c9f8,0xc(%esp)
c0104168:	c0 
c0104169:	c7 44 24 08 3b c8 10 	movl   $0xc010c83b,0x8(%esp)
c0104170:	c0 
c0104171:	c7 44 24 04 33 01 00 	movl   $0x133,0x4(%esp)
c0104178:	00 
c0104179:	c7 04 24 50 c8 10 c0 	movl   $0xc010c850,(%esp)
c0104180:	e8 7b c2 ff ff       	call   c0100400 <__panic>
    for (i = 5; i <= 5 * step2; i +=5) {
c0104185:	83 45 f4 05          	addl   $0x5,-0xc(%ebp)
c0104189:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010418c:	89 d0                	mov    %edx,%eax
c010418e:	c1 e0 02             	shl    $0x2,%eax
c0104191:	01 d0                	add    %edx,%eax
c0104193:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104196:	0f 8d 20 fe ff ff    	jge    c0103fbc <check_vma_struct+0x221>
    }

    for (i =4; i>=0; i--) {
c010419c:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
c01041a3:	eb 70                	jmp    c0104215 <check_vma_struct+0x47a>
        struct vma_struct *vma_below_5= find_vma(mm,i);
c01041a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01041a8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01041ac:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01041af:	89 04 24             	mov    %eax,(%esp)
c01041b2:	e8 f2 f4 ff ff       	call   c01036a9 <find_vma>
c01041b7:	89 45 bc             	mov    %eax,-0x44(%ebp)
        if (vma_below_5 != NULL ) {
c01041ba:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c01041be:	74 27                	je     c01041e7 <check_vma_struct+0x44c>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
c01041c0:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01041c3:	8b 50 08             	mov    0x8(%eax),%edx
c01041c6:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01041c9:	8b 40 04             	mov    0x4(%eax),%eax
c01041cc:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01041d0:	89 44 24 08          	mov    %eax,0x8(%esp)
c01041d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01041d7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01041db:	c7 04 24 28 ca 10 c0 	movl   $0xc010ca28,(%esp)
c01041e2:	e8 c2 c0 ff ff       	call   c01002a9 <cprintf>
        }
        assert(vma_below_5 == NULL);
c01041e7:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c01041eb:	74 24                	je     c0104211 <check_vma_struct+0x476>
c01041ed:	c7 44 24 0c 4d ca 10 	movl   $0xc010ca4d,0xc(%esp)
c01041f4:	c0 
c01041f5:	c7 44 24 08 3b c8 10 	movl   $0xc010c83b,0x8(%esp)
c01041fc:	c0 
c01041fd:	c7 44 24 04 3b 01 00 	movl   $0x13b,0x4(%esp)
c0104204:	00 
c0104205:	c7 04 24 50 c8 10 c0 	movl   $0xc010c850,(%esp)
c010420c:	e8 ef c1 ff ff       	call   c0100400 <__panic>
    for (i =4; i>=0; i--) {
c0104211:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0104215:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104219:	79 8a                	jns    c01041a5 <check_vma_struct+0x40a>
    }

    mm_destroy(mm);
c010421b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010421e:	89 04 24             	mov    %eax,(%esp)
c0104221:	e8 08 f7 ff ff       	call   c010392e <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
c0104226:	c7 04 24 64 ca 10 c0 	movl   $0xc010ca64,(%esp)
c010422d:	e8 77 c0 ff ff       	call   c01002a9 <cprintf>
}
c0104232:	c9                   	leave  
c0104233:	c3                   	ret    

c0104234 <check_pgfault>:

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
c0104234:	55                   	push   %ebp
c0104235:	89 e5                	mov    %esp,%ebp
c0104237:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c010423a:	e8 35 33 00 00       	call   c0107574 <nr_free_pages>
c010423f:	89 45 ec             	mov    %eax,-0x14(%ebp)

    check_mm_struct = mm_create();
c0104242:	e8 8e f3 ff ff       	call   c01035d5 <mm_create>
c0104247:	a3 58 10 1a c0       	mov    %eax,0xc01a1058
    assert(check_mm_struct != NULL);
c010424c:	a1 58 10 1a c0       	mov    0xc01a1058,%eax
c0104251:	85 c0                	test   %eax,%eax
c0104253:	75 24                	jne    c0104279 <check_pgfault+0x45>
c0104255:	c7 44 24 0c 83 ca 10 	movl   $0xc010ca83,0xc(%esp)
c010425c:	c0 
c010425d:	c7 44 24 08 3b c8 10 	movl   $0xc010c83b,0x8(%esp)
c0104264:	c0 
c0104265:	c7 44 24 04 4b 01 00 	movl   $0x14b,0x4(%esp)
c010426c:	00 
c010426d:	c7 04 24 50 c8 10 c0 	movl   $0xc010c850,(%esp)
c0104274:	e8 87 c1 ff ff       	call   c0100400 <__panic>

    struct mm_struct *mm = check_mm_struct;
c0104279:	a1 58 10 1a c0       	mov    0xc01a1058,%eax
c010427e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
c0104281:	8b 15 20 aa 12 c0    	mov    0xc012aa20,%edx
c0104287:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010428a:	89 50 0c             	mov    %edx,0xc(%eax)
c010428d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104290:	8b 40 0c             	mov    0xc(%eax),%eax
c0104293:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(pgdir[0] == 0);
c0104296:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104299:	8b 00                	mov    (%eax),%eax
c010429b:	85 c0                	test   %eax,%eax
c010429d:	74 24                	je     c01042c3 <check_pgfault+0x8f>
c010429f:	c7 44 24 0c 9b ca 10 	movl   $0xc010ca9b,0xc(%esp)
c01042a6:	c0 
c01042a7:	c7 44 24 08 3b c8 10 	movl   $0xc010c83b,0x8(%esp)
c01042ae:	c0 
c01042af:	c7 44 24 04 4f 01 00 	movl   $0x14f,0x4(%esp)
c01042b6:	00 
c01042b7:	c7 04 24 50 c8 10 c0 	movl   $0xc010c850,(%esp)
c01042be:	e8 3d c1 ff ff       	call   c0100400 <__panic>

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
c01042c3:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
c01042ca:	00 
c01042cb:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
c01042d2:	00 
c01042d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01042da:	e8 8f f3 ff ff       	call   c010366e <vma_create>
c01042df:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(vma != NULL);
c01042e2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01042e6:	75 24                	jne    c010430c <check_pgfault+0xd8>
c01042e8:	c7 44 24 0c 2c c9 10 	movl   $0xc010c92c,0xc(%esp)
c01042ef:	c0 
c01042f0:	c7 44 24 08 3b c8 10 	movl   $0xc010c83b,0x8(%esp)
c01042f7:	c0 
c01042f8:	c7 44 24 04 52 01 00 	movl   $0x152,0x4(%esp)
c01042ff:	00 
c0104300:	c7 04 24 50 c8 10 c0 	movl   $0xc010c850,(%esp)
c0104307:	e8 f4 c0 ff ff       	call   c0100400 <__panic>

    insert_vma_struct(mm, vma);
c010430c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010430f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104313:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104316:	89 04 24             	mov    %eax,(%esp)
c0104319:	e8 e0 f4 ff ff       	call   c01037fe <insert_vma_struct>

    uintptr_t addr = 0x100;
c010431e:	c7 45 dc 00 01 00 00 	movl   $0x100,-0x24(%ebp)
    assert(find_vma(mm, addr) == vma);
c0104325:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104328:	89 44 24 04          	mov    %eax,0x4(%esp)
c010432c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010432f:	89 04 24             	mov    %eax,(%esp)
c0104332:	e8 72 f3 ff ff       	call   c01036a9 <find_vma>
c0104337:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c010433a:	74 24                	je     c0104360 <check_pgfault+0x12c>
c010433c:	c7 44 24 0c a9 ca 10 	movl   $0xc010caa9,0xc(%esp)
c0104343:	c0 
c0104344:	c7 44 24 08 3b c8 10 	movl   $0xc010c83b,0x8(%esp)
c010434b:	c0 
c010434c:	c7 44 24 04 57 01 00 	movl   $0x157,0x4(%esp)
c0104353:	00 
c0104354:	c7 04 24 50 c8 10 c0 	movl   $0xc010c850,(%esp)
c010435b:	e8 a0 c0 ff ff       	call   c0100400 <__panic>

    int i, sum = 0;
c0104360:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0104367:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010436e:	eb 17                	jmp    c0104387 <check_pgfault+0x153>
        *(char *)(addr + i) = i;
c0104370:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104373:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104376:	01 d0                	add    %edx,%eax
c0104378:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010437b:	88 10                	mov    %dl,(%eax)
        sum += i;
c010437d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104380:	01 45 f0             	add    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0104383:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0104387:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c010438b:	7e e3                	jle    c0104370 <check_pgfault+0x13c>
    }
    for (i = 0; i < 100; i ++) {
c010438d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104394:	eb 15                	jmp    c01043ab <check_pgfault+0x177>
        sum -= *(char *)(addr + i);
c0104396:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104399:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010439c:	01 d0                	add    %edx,%eax
c010439e:	0f b6 00             	movzbl (%eax),%eax
c01043a1:	0f be c0             	movsbl %al,%eax
c01043a4:	29 45 f0             	sub    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c01043a7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01043ab:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c01043af:	7e e5                	jle    c0104396 <check_pgfault+0x162>
    }
    assert(sum == 0);
c01043b1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01043b5:	74 24                	je     c01043db <check_pgfault+0x1a7>
c01043b7:	c7 44 24 0c c3 ca 10 	movl   $0xc010cac3,0xc(%esp)
c01043be:	c0 
c01043bf:	c7 44 24 08 3b c8 10 	movl   $0xc010c83b,0x8(%esp)
c01043c6:	c0 
c01043c7:	c7 44 24 04 61 01 00 	movl   $0x161,0x4(%esp)
c01043ce:	00 
c01043cf:	c7 04 24 50 c8 10 c0 	movl   $0xc010c850,(%esp)
c01043d6:	e8 25 c0 ff ff       	call   c0100400 <__panic>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
c01043db:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01043de:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01043e1:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01043e4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01043e9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01043ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01043f0:	89 04 24             	mov    %eax,(%esp)
c01043f3:	e8 d9 3d 00 00       	call   c01081d1 <page_remove>
    free_page(pde2page(pgdir[0]));
c01043f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01043fb:	8b 00                	mov    (%eax),%eax
c01043fd:	89 04 24             	mov    %eax,(%esp)
c0104400:	e8 b8 f1 ff ff       	call   c01035bd <pde2page>
c0104405:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010440c:	00 
c010440d:	89 04 24             	mov    %eax,(%esp)
c0104410:	e8 2d 31 00 00       	call   c0107542 <free_pages>
    pgdir[0] = 0;
c0104415:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104418:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    mm->pgdir = NULL;
c010441e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104421:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    mm_destroy(mm);
c0104428:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010442b:	89 04 24             	mov    %eax,(%esp)
c010442e:	e8 fb f4 ff ff       	call   c010392e <mm_destroy>
    check_mm_struct = NULL;
c0104433:	c7 05 58 10 1a c0 00 	movl   $0x0,0xc01a1058
c010443a:	00 00 00 

    assert(nr_free_pages_store == nr_free_pages());
c010443d:	e8 32 31 00 00       	call   c0107574 <nr_free_pages>
c0104442:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0104445:	74 24                	je     c010446b <check_pgfault+0x237>
c0104447:	c7 44 24 0c cc ca 10 	movl   $0xc010cacc,0xc(%esp)
c010444e:	c0 
c010444f:	c7 44 24 08 3b c8 10 	movl   $0xc010c83b,0x8(%esp)
c0104456:	c0 
c0104457:	c7 44 24 04 6b 01 00 	movl   $0x16b,0x4(%esp)
c010445e:	00 
c010445f:	c7 04 24 50 c8 10 c0 	movl   $0xc010c850,(%esp)
c0104466:	e8 95 bf ff ff       	call   c0100400 <__panic>

    cprintf("check_pgfault() succeeded!\n");
c010446b:	c7 04 24 f3 ca 10 c0 	movl   $0xc010caf3,(%esp)
c0104472:	e8 32 be ff ff       	call   c01002a9 <cprintf>
}
c0104477:	c9                   	leave  
c0104478:	c3                   	ret    

c0104479 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
c0104479:	55                   	push   %ebp
c010447a:	89 e5                	mov    %esp,%ebp
c010447c:	83 ec 38             	sub    $0x38,%esp
    int ret = -E_INVAL;
c010447f:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
c0104486:	8b 45 10             	mov    0x10(%ebp),%eax
c0104489:	89 44 24 04          	mov    %eax,0x4(%esp)
c010448d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104490:	89 04 24             	mov    %eax,(%esp)
c0104493:	e8 11 f2 ff ff       	call   c01036a9 <find_vma>
c0104498:	89 45 ec             	mov    %eax,-0x14(%ebp)

    pgfault_num++;
c010449b:	a1 64 ef 19 c0       	mov    0xc019ef64,%eax
c01044a0:	83 c0 01             	add    $0x1,%eax
c01044a3:	a3 64 ef 19 c0       	mov    %eax,0xc019ef64
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
c01044a8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01044ac:	74 0b                	je     c01044b9 <do_pgfault+0x40>
c01044ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01044b1:	8b 40 04             	mov    0x4(%eax),%eax
c01044b4:	3b 45 10             	cmp    0x10(%ebp),%eax
c01044b7:	76 18                	jbe    c01044d1 <do_pgfault+0x58>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
c01044b9:	8b 45 10             	mov    0x10(%ebp),%eax
c01044bc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01044c0:	c7 04 24 10 cb 10 c0 	movl   $0xc010cb10,(%esp)
c01044c7:	e8 dd bd ff ff       	call   c01002a9 <cprintf>
        goto failed;
c01044cc:	e9 bb 01 00 00       	jmp    c010468c <do_pgfault+0x213>
    }
    //check the error_code
    switch (error_code & 3) {
c01044d1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01044d4:	83 e0 03             	and    $0x3,%eax
c01044d7:	85 c0                	test   %eax,%eax
c01044d9:	74 36                	je     c0104511 <do_pgfault+0x98>
c01044db:	83 f8 01             	cmp    $0x1,%eax
c01044de:	74 20                	je     c0104500 <do_pgfault+0x87>
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
c01044e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01044e3:	8b 40 0c             	mov    0xc(%eax),%eax
c01044e6:	83 e0 02             	and    $0x2,%eax
c01044e9:	85 c0                	test   %eax,%eax
c01044eb:	75 11                	jne    c01044fe <do_pgfault+0x85>
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
c01044ed:	c7 04 24 40 cb 10 c0 	movl   $0xc010cb40,(%esp)
c01044f4:	e8 b0 bd ff ff       	call   c01002a9 <cprintf>
            goto failed;
c01044f9:	e9 8e 01 00 00       	jmp    c010468c <do_pgfault+0x213>
        }
        break;
c01044fe:	eb 2f                	jmp    c010452f <do_pgfault+0xb6>
    case 1: /* error code flag : (W/R=0, P=1): read, present */
        cprintf("do_pgfault failed: error code flag = read AND present\n");
c0104500:	c7 04 24 a0 cb 10 c0 	movl   $0xc010cba0,(%esp)
c0104507:	e8 9d bd ff ff       	call   c01002a9 <cprintf>
        goto failed;
c010450c:	e9 7b 01 00 00       	jmp    c010468c <do_pgfault+0x213>
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
c0104511:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104514:	8b 40 0c             	mov    0xc(%eax),%eax
c0104517:	83 e0 05             	and    $0x5,%eax
c010451a:	85 c0                	test   %eax,%eax
c010451c:	75 11                	jne    c010452f <do_pgfault+0xb6>
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
c010451e:	c7 04 24 d8 cb 10 c0 	movl   $0xc010cbd8,(%esp)
c0104525:	e8 7f bd ff ff       	call   c01002a9 <cprintf>
            goto failed;
c010452a:	e9 5d 01 00 00       	jmp    c010468c <do_pgfault+0x213>
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
c010452f:	c7 45 f0 04 00 00 00 	movl   $0x4,-0x10(%ebp)
    if (vma->vm_flags & VM_WRITE) {
c0104536:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104539:	8b 40 0c             	mov    0xc(%eax),%eax
c010453c:	83 e0 02             	and    $0x2,%eax
c010453f:	85 c0                	test   %eax,%eax
c0104541:	74 04                	je     c0104547 <do_pgfault+0xce>
        perm |= PTE_W;
c0104543:	83 4d f0 02          	orl    $0x2,-0x10(%ebp)
    }
    addr = ROUNDDOWN(addr, PGSIZE);
c0104547:	8b 45 10             	mov    0x10(%ebp),%eax
c010454a:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010454d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104550:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104555:	89 45 10             	mov    %eax,0x10(%ebp)

    ret = -E_NO_MEM;
c0104558:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    pte_t *ptep=NULL;
c010455f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    *   mm->pgdir : the PDT of these vma
    *
    */
//try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
	//检查页表中是否有相应的应用程序需要的表项，有就获取指向这个表项的指针
	if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
c0104566:	8b 45 08             	mov    0x8(%ebp),%eax
c0104569:	8b 40 0c             	mov    0xc(%eax),%eax
c010456c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0104573:	00 
c0104574:	8b 55 10             	mov    0x10(%ebp),%edx
c0104577:	89 54 24 04          	mov    %edx,0x4(%esp)
c010457b:	89 04 24             	mov    %eax,(%esp)
c010457e:	e8 38 36 00 00       	call   c0107bbb <get_pte>
c0104583:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104586:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010458a:	75 11                	jne    c010459d <do_pgfault+0x124>
        cprintf("get_pte in do_pgfault failed\n");
c010458c:	c7 04 24 3b cc 10 c0 	movl   $0xc010cc3b,(%esp)
c0104593:	e8 11 bd ff ff       	call   c01002a9 <cprintf>
        goto failed;
c0104598:	e9 ef 00 00 00       	jmp    c010468c <do_pgfault+0x213>
    }
	//然后检查这个表项是否为空(是否被映射)，如果为空，pgdir_alloc_page分配一个新的物理页
    if (*ptep == 0) {  
c010459d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01045a0:	8b 00                	mov    (%eax),%eax
c01045a2:	85 c0                	test   %eax,%eax
c01045a4:	75 35                	jne    c01045db <do_pgfault+0x162>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
c01045a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01045a9:	8b 40 0c             	mov    0xc(%eax),%eax
c01045ac:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01045af:	89 54 24 08          	mov    %edx,0x8(%esp)
c01045b3:	8b 55 10             	mov    0x10(%ebp),%edx
c01045b6:	89 54 24 04          	mov    %edx,0x4(%esp)
c01045ba:	89 04 24             	mov    %eax,(%esp)
c01045bd:	e8 69 3d 00 00       	call   c010832b <pgdir_alloc_page>
c01045c2:	85 c0                	test   %eax,%eax
c01045c4:	0f 85 bb 00 00 00    	jne    c0104685 <do_pgfault+0x20c>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
c01045ca:	c7 04 24 5c cc 10 c0 	movl   $0xc010cc5c,(%esp)
c01045d1:	e8 d3 bc ff ff       	call   c01002a9 <cprintf>
            goto failed;
c01045d6:	e9 b1 00 00 00       	jmp    c010468c <do_pgfault+0x213>
        }
    }
 //如果这个页表项非空，那么说明这一页已经映射过了但是被保存在磁盘中，需要将这一页内存交换出来
// if this pte is a swap entry, then load data from disk to a page with phy addr and call page_insert to map the phy addr with logical addr
    else {   
        if(swap_init_ok) {
c01045db:	a1 6c ef 19 c0       	mov    0xc019ef6c,%eax
c01045e0:	85 c0                	test   %eax,%eax
c01045e2:	0f 84 86 00 00 00    	je     c010466e <do_pgfault+0x1f5>
            //如果可以交换
            struct Page *page=NULL; 
c01045e8:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
            //根据mm结构和addr地址，尝试将硬盘中的内容换入至page中
            //load the content of right disk page into the memory which page managed.
            if ((ret = swap_in(mm, addr, &page)) != 0) {
c01045ef:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01045f2:	89 44 24 08          	mov    %eax,0x8(%esp)
c01045f6:	8b 45 10             	mov    0x10(%ebp),%eax
c01045f9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01045fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0104600:	89 04 24             	mov    %eax,(%esp)
c0104603:	e8 65 11 00 00       	call   c010576d <swap_in>
c0104608:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010460b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010460f:	74 0e                	je     c010461f <do_pgfault+0x1a6>
                cprintf("swap_in in do_pgfault failed\n");
c0104611:	c7 04 24 83 cc 10 c0 	movl   $0xc010cc83,(%esp)
c0104618:	e8 8c bc ff ff       	call   c01002a9 <cprintf>
c010461d:	eb 6d                	jmp    c010468c <do_pgfault+0x213>
                goto failed;
            }    
            page_insert(mm->pgdir, page, addr, perm); 
c010461f:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104622:	8b 45 08             	mov    0x8(%ebp),%eax
c0104625:	8b 40 0c             	mov    0xc(%eax),%eax
c0104628:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c010462b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010462f:	8b 4d 10             	mov    0x10(%ebp),%ecx
c0104632:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0104636:	89 54 24 04          	mov    %edx,0x4(%esp)
c010463a:	89 04 24             	mov    %eax,(%esp)
c010463d:	e8 d3 3b 00 00       	call   c0108215 <page_insert>
            //建立虚拟地址和物理地址之间的对应关系 According to the mm, addr AND page, setup the map of phy addr <---> logical addr
            swap_map_swappable(mm, addr, page, 1); 
c0104642:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104645:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c010464c:	00 
c010464d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104651:	8b 45 10             	mov    0x10(%ebp),%eax
c0104654:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104658:	8b 45 08             	mov    0x8(%ebp),%eax
c010465b:	89 04 24             	mov    %eax,(%esp)
c010465e:	e8 41 0f 00 00       	call   c01055a4 <swap_map_swappable>
            //将此页面设置为可交换的 make the page swappable.  
            page->pra_vaddr = addr;
c0104663:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104666:	8b 55 10             	mov    0x10(%ebp),%edx
c0104669:	89 50 1c             	mov    %edx,0x1c(%eax)
c010466c:	eb 17                	jmp    c0104685 <do_pgfault+0x20c>
        }
        else {
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
c010466e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104671:	8b 00                	mov    (%eax),%eax
c0104673:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104677:	c7 04 24 a4 cc 10 c0 	movl   $0xc010cca4,(%esp)
c010467e:	e8 26 bc ff ff       	call   c01002a9 <cprintf>
            goto failed;
c0104683:	eb 07                	jmp    c010468c <do_pgfault+0x213>
        }
   }
   ret = 0;
c0104685:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
failed:
    return ret;
c010468c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010468f:	c9                   	leave  
c0104690:	c3                   	ret    

c0104691 <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
c0104691:	55                   	push   %ebp
c0104692:	89 e5                	mov    %esp,%ebp
c0104694:	83 ec 18             	sub    $0x18,%esp
    if (mm != NULL) {
c0104697:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010469b:	0f 84 e0 00 00 00    	je     c0104781 <user_mem_check+0xf0>
        if (!USER_ACCESS(addr, addr + len)) {
c01046a1:	81 7d 0c ff ff 1f 00 	cmpl   $0x1fffff,0xc(%ebp)
c01046a8:	76 1c                	jbe    c01046c6 <user_mem_check+0x35>
c01046aa:	8b 45 10             	mov    0x10(%ebp),%eax
c01046ad:	8b 55 0c             	mov    0xc(%ebp),%edx
c01046b0:	01 d0                	add    %edx,%eax
c01046b2:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01046b5:	76 0f                	jbe    c01046c6 <user_mem_check+0x35>
c01046b7:	8b 45 10             	mov    0x10(%ebp),%eax
c01046ba:	8b 55 0c             	mov    0xc(%ebp),%edx
c01046bd:	01 d0                	add    %edx,%eax
c01046bf:	3d 00 00 00 b0       	cmp    $0xb0000000,%eax
c01046c4:	76 0a                	jbe    c01046d0 <user_mem_check+0x3f>
            return 0;
c01046c6:	b8 00 00 00 00       	mov    $0x0,%eax
c01046cb:	e9 e2 00 00 00       	jmp    c01047b2 <user_mem_check+0x121>
        }
        struct vma_struct *vma;
        uintptr_t start = addr, end = addr + len;
c01046d0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01046d3:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01046d6:	8b 45 10             	mov    0x10(%ebp),%eax
c01046d9:	8b 55 0c             	mov    0xc(%ebp),%edx
c01046dc:	01 d0                	add    %edx,%eax
c01046de:	89 45 f8             	mov    %eax,-0x8(%ebp)
        while (start < end) {
c01046e1:	e9 88 00 00 00       	jmp    c010476e <user_mem_check+0xdd>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
c01046e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01046e9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01046ed:	8b 45 08             	mov    0x8(%ebp),%eax
c01046f0:	89 04 24             	mov    %eax,(%esp)
c01046f3:	e8 b1 ef ff ff       	call   c01036a9 <find_vma>
c01046f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01046fb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01046ff:	74 0b                	je     c010470c <user_mem_check+0x7b>
c0104701:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104704:	8b 40 04             	mov    0x4(%eax),%eax
c0104707:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010470a:	76 0a                	jbe    c0104716 <user_mem_check+0x85>
                return 0;
c010470c:	b8 00 00 00 00       	mov    $0x0,%eax
c0104711:	e9 9c 00 00 00       	jmp    c01047b2 <user_mem_check+0x121>
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
c0104716:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104719:	8b 50 0c             	mov    0xc(%eax),%edx
c010471c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0104720:	74 07                	je     c0104729 <user_mem_check+0x98>
c0104722:	b8 02 00 00 00       	mov    $0x2,%eax
c0104727:	eb 05                	jmp    c010472e <user_mem_check+0x9d>
c0104729:	b8 01 00 00 00       	mov    $0x1,%eax
c010472e:	21 d0                	and    %edx,%eax
c0104730:	85 c0                	test   %eax,%eax
c0104732:	75 07                	jne    c010473b <user_mem_check+0xaa>
                return 0;
c0104734:	b8 00 00 00 00       	mov    $0x0,%eax
c0104739:	eb 77                	jmp    c01047b2 <user_mem_check+0x121>
            }
            if (write && (vma->vm_flags & VM_STACK)) {
c010473b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c010473f:	74 24                	je     c0104765 <user_mem_check+0xd4>
c0104741:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104744:	8b 40 0c             	mov    0xc(%eax),%eax
c0104747:	83 e0 08             	and    $0x8,%eax
c010474a:	85 c0                	test   %eax,%eax
c010474c:	74 17                	je     c0104765 <user_mem_check+0xd4>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
c010474e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104751:	8b 40 04             	mov    0x4(%eax),%eax
c0104754:	05 00 10 00 00       	add    $0x1000,%eax
c0104759:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010475c:	76 07                	jbe    c0104765 <user_mem_check+0xd4>
                    return 0;
c010475e:	b8 00 00 00 00       	mov    $0x0,%eax
c0104763:	eb 4d                	jmp    c01047b2 <user_mem_check+0x121>
                }
            }
            start = vma->vm_end;
c0104765:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104768:	8b 40 08             	mov    0x8(%eax),%eax
c010476b:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < end) {
c010476e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104771:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0104774:	0f 82 6c ff ff ff    	jb     c01046e6 <user_mem_check+0x55>
        }
        return 1;
c010477a:	b8 01 00 00 00       	mov    $0x1,%eax
c010477f:	eb 31                	jmp    c01047b2 <user_mem_check+0x121>
    }
    return KERN_ACCESS(addr, addr + len);
c0104781:	81 7d 0c ff ff ff bf 	cmpl   $0xbfffffff,0xc(%ebp)
c0104788:	76 23                	jbe    c01047ad <user_mem_check+0x11c>
c010478a:	8b 45 10             	mov    0x10(%ebp),%eax
c010478d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104790:	01 d0                	add    %edx,%eax
c0104792:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104795:	76 16                	jbe    c01047ad <user_mem_check+0x11c>
c0104797:	8b 45 10             	mov    0x10(%ebp),%eax
c010479a:	8b 55 0c             	mov    0xc(%ebp),%edx
c010479d:	01 d0                	add    %edx,%eax
c010479f:	3d 00 00 00 f8       	cmp    $0xf8000000,%eax
c01047a4:	77 07                	ja     c01047ad <user_mem_check+0x11c>
c01047a6:	b8 01 00 00 00       	mov    $0x1,%eax
c01047ab:	eb 05                	jmp    c01047b2 <user_mem_check+0x121>
c01047ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01047b2:	c9                   	leave  
c01047b3:	c3                   	ret    

c01047b4 <_fifo_init_mm>:
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
c01047b4:	55                   	push   %ebp
c01047b5:	89 e5                	mov    %esp,%ebp
c01047b7:	83 ec 10             	sub    $0x10,%esp
c01047ba:	c7 45 fc 5c 10 1a c0 	movl   $0xc01a105c,-0x4(%ebp)
    elm->prev = elm->next = elm;
c01047c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01047c4:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01047c7:	89 50 04             	mov    %edx,0x4(%eax)
c01047ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01047cd:	8b 50 04             	mov    0x4(%eax),%edx
c01047d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01047d3:	89 10                	mov    %edx,(%eax)
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
c01047d5:	8b 45 08             	mov    0x8(%ebp),%eax
c01047d8:	c7 40 14 5c 10 1a c0 	movl   $0xc01a105c,0x14(%eax)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
c01047df:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01047e4:	c9                   	leave  
c01047e5:	c3                   	ret    

c01047e6 <_fifo_map_swappable>:
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c01047e6:	55                   	push   %ebp
c01047e7:	89 e5                	mov    %esp,%ebp
c01047e9:	83 ec 48             	sub    $0x48,%esp
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
c01047ec:	8b 45 08             	mov    0x8(%ebp),%eax
c01047ef:	8b 40 14             	mov    0x14(%eax),%eax
c01047f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry=&(page->pra_page_link);
c01047f5:	8b 45 10             	mov    0x10(%ebp),%eax
c01047f8:	83 c0 14             	add    $0x14,%eax
c01047fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
 
    assert(entry != NULL && head != NULL);
c01047fe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104802:	74 06                	je     c010480a <_fifo_map_swappable+0x24>
c0104804:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104808:	75 24                	jne    c010482e <_fifo_map_swappable+0x48>
c010480a:	c7 44 24 0c cc cc 10 	movl   $0xc010cccc,0xc(%esp)
c0104811:	c0 
c0104812:	c7 44 24 08 ea cc 10 	movl   $0xc010ccea,0x8(%esp)
c0104819:	c0 
c010481a:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
c0104821:	00 
c0104822:	c7 04 24 ff cc 10 c0 	movl   $0xc010ccff,(%esp)
c0104829:	e8 d2 bb ff ff       	call   c0100400 <__panic>
c010482e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104831:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104834:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104837:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010483a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010483d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104840:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104843:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_add(elm, listelm, listelm->next);
c0104846:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104849:	8b 40 04             	mov    0x4(%eax),%eax
c010484c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010484f:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0104852:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104855:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0104858:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    prev->next = next->prev = elm;
c010485b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010485e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104861:	89 10                	mov    %edx,(%eax)
c0104863:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104866:	8b 10                	mov    (%eax),%edx
c0104868:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010486b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010486e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104871:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104874:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0104877:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010487a:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010487d:	89 10                	mov    %edx,(%eax)
    //record the page access situlation
    /*LAB3 EXERCISE 2: YOUR CODE*/ 
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
    list_add(head, entry);
    return 0;
c010487f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104884:	c9                   	leave  
c0104885:	c3                   	ret    

c0104886 <_fifo_swap_out_victim>:
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then assign the value of *ptr_page to the addr of this page.
 */
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
c0104886:	55                   	push   %ebp
c0104887:	89 e5                	mov    %esp,%ebp
c0104889:	83 ec 38             	sub    $0x38,%esp
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
c010488c:	8b 45 08             	mov    0x8(%ebp),%eax
c010488f:	8b 40 14             	mov    0x14(%eax),%eax
c0104892:	89 45 f4             	mov    %eax,-0xc(%ebp)
         assert(head != NULL);
c0104895:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104899:	75 24                	jne    c01048bf <_fifo_swap_out_victim+0x39>
c010489b:	c7 44 24 0c 13 cd 10 	movl   $0xc010cd13,0xc(%esp)
c01048a2:	c0 
c01048a3:	c7 44 24 08 ea cc 10 	movl   $0xc010ccea,0x8(%esp)
c01048aa:	c0 
c01048ab:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
c01048b2:	00 
c01048b3:	c7 04 24 ff cc 10 c0 	movl   $0xc010ccff,(%esp)
c01048ba:	e8 41 bb ff ff       	call   c0100400 <__panic>
     assert(in_tick==0);
c01048bf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01048c3:	74 24                	je     c01048e9 <_fifo_swap_out_victim+0x63>
c01048c5:	c7 44 24 0c 20 cd 10 	movl   $0xc010cd20,0xc(%esp)
c01048cc:	c0 
c01048cd:	c7 44 24 08 ea cc 10 	movl   $0xc010ccea,0x8(%esp)
c01048d4:	c0 
c01048d5:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
c01048dc:	00 
c01048dd:	c7 04 24 ff cc 10 c0 	movl   $0xc010ccff,(%esp)
c01048e4:	e8 17 bb ff ff       	call   c0100400 <__panic>
     /* Select the victim */
     /*LAB3 EXERCISE 2: YOUR CODE*/ 
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  assign the value of *ptr_page to the addr of this page
     //需要被换出的页
     list_entry_t *le = head->prev;
c01048e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048ec:	8b 00                	mov    (%eax),%eax
c01048ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
     assert(head!=le);
c01048f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048f4:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01048f7:	75 24                	jne    c010491d <_fifo_swap_out_victim+0x97>
c01048f9:	c7 44 24 0c 2b cd 10 	movl   $0xc010cd2b,0xc(%esp)
c0104900:	c0 
c0104901:	c7 44 24 08 ea cc 10 	movl   $0xc010ccea,0x8(%esp)
c0104908:	c0 
c0104909:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
c0104910:	00 
c0104911:	c7 04 24 ff cc 10 c0 	movl   $0xc010ccff,(%esp)
c0104918:	e8 e3 ba ff ff       	call   c0100400 <__panic>
     //获得对应page的指针p
     struct Page *p = le2page(le, pra_page_link);
c010491d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104920:	83 e8 14             	sub    $0x14,%eax
c0104923:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104926:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104929:	89 45 e8             	mov    %eax,-0x18(%ebp)
    __list_del(listelm->prev, listelm->next);
c010492c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010492f:	8b 40 04             	mov    0x4(%eax),%eax
c0104932:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104935:	8b 12                	mov    (%edx),%edx
c0104937:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010493a:	89 45 e0             	mov    %eax,-0x20(%ebp)
    prev->next = next;
c010493d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104940:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104943:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0104946:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104949:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010494c:	89 10                	mov    %edx,(%eax)
     //将最老的页面从队列中删除
     list_del(le);
     assert(p !=NULL);
c010494e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104952:	75 24                	jne    c0104978 <_fifo_swap_out_victim+0xf2>
c0104954:	c7 44 24 0c 34 cd 10 	movl   $0xc010cd34,0xc(%esp)
c010495b:	c0 
c010495c:	c7 44 24 08 ea cc 10 	movl   $0xc010ccea,0x8(%esp)
c0104963:	c0 
c0104964:	c7 44 24 04 4e 00 00 	movl   $0x4e,0x4(%esp)
c010496b:	00 
c010496c:	c7 04 24 ff cc 10 c0 	movl   $0xc010ccff,(%esp)
c0104973:	e8 88 ba ff ff       	call   c0100400 <__panic>
     //将这一页的地址存储在ptr_page中
     *ptr_page = p;
c0104978:	8b 45 0c             	mov    0xc(%ebp),%eax
c010497b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010497e:	89 10                	mov    %edx,(%eax)
     return 0;
c0104980:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104985:	c9                   	leave  
c0104986:	c3                   	ret    

c0104987 <_fifo_check_swap>:

static int
_fifo_check_swap(void) {
c0104987:	55                   	push   %ebp
c0104988:	89 e5                	mov    %esp,%ebp
c010498a:	83 ec 18             	sub    $0x18,%esp
    cprintf("write Virt Page c in fifo_check_swap\n");
c010498d:	c7 04 24 40 cd 10 c0 	movl   $0xc010cd40,(%esp)
c0104994:	e8 10 b9 ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0104999:	b8 00 30 00 00       	mov    $0x3000,%eax
c010499e:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==4);
c01049a1:	a1 64 ef 19 c0       	mov    0xc019ef64,%eax
c01049a6:	83 f8 04             	cmp    $0x4,%eax
c01049a9:	74 24                	je     c01049cf <_fifo_check_swap+0x48>
c01049ab:	c7 44 24 0c 66 cd 10 	movl   $0xc010cd66,0xc(%esp)
c01049b2:	c0 
c01049b3:	c7 44 24 08 ea cc 10 	movl   $0xc010ccea,0x8(%esp)
c01049ba:	c0 
c01049bb:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
c01049c2:	00 
c01049c3:	c7 04 24 ff cc 10 c0 	movl   $0xc010ccff,(%esp)
c01049ca:	e8 31 ba ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c01049cf:	c7 04 24 78 cd 10 c0 	movl   $0xc010cd78,(%esp)
c01049d6:	e8 ce b8 ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c01049db:	b8 00 10 00 00       	mov    $0x1000,%eax
c01049e0:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==4);
c01049e3:	a1 64 ef 19 c0       	mov    0xc019ef64,%eax
c01049e8:	83 f8 04             	cmp    $0x4,%eax
c01049eb:	74 24                	je     c0104a11 <_fifo_check_swap+0x8a>
c01049ed:	c7 44 24 0c 66 cd 10 	movl   $0xc010cd66,0xc(%esp)
c01049f4:	c0 
c01049f5:	c7 44 24 08 ea cc 10 	movl   $0xc010ccea,0x8(%esp)
c01049fc:	c0 
c01049fd:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c0104a04:	00 
c0104a05:	c7 04 24 ff cc 10 c0 	movl   $0xc010ccff,(%esp)
c0104a0c:	e8 ef b9 ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0104a11:	c7 04 24 a0 cd 10 c0 	movl   $0xc010cda0,(%esp)
c0104a18:	e8 8c b8 ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0104a1d:	b8 00 40 00 00       	mov    $0x4000,%eax
c0104a22:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==4);
c0104a25:	a1 64 ef 19 c0       	mov    0xc019ef64,%eax
c0104a2a:	83 f8 04             	cmp    $0x4,%eax
c0104a2d:	74 24                	je     c0104a53 <_fifo_check_swap+0xcc>
c0104a2f:	c7 44 24 0c 66 cd 10 	movl   $0xc010cd66,0xc(%esp)
c0104a36:	c0 
c0104a37:	c7 44 24 08 ea cc 10 	movl   $0xc010ccea,0x8(%esp)
c0104a3e:	c0 
c0104a3f:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0104a46:	00 
c0104a47:	c7 04 24 ff cc 10 c0 	movl   $0xc010ccff,(%esp)
c0104a4e:	e8 ad b9 ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0104a53:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0104a5a:	e8 4a b8 ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0104a5f:	b8 00 20 00 00       	mov    $0x2000,%eax
c0104a64:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==4);
c0104a67:	a1 64 ef 19 c0       	mov    0xc019ef64,%eax
c0104a6c:	83 f8 04             	cmp    $0x4,%eax
c0104a6f:	74 24                	je     c0104a95 <_fifo_check_swap+0x10e>
c0104a71:	c7 44 24 0c 66 cd 10 	movl   $0xc010cd66,0xc(%esp)
c0104a78:	c0 
c0104a79:	c7 44 24 08 ea cc 10 	movl   $0xc010ccea,0x8(%esp)
c0104a80:	c0 
c0104a81:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c0104a88:	00 
c0104a89:	c7 04 24 ff cc 10 c0 	movl   $0xc010ccff,(%esp)
c0104a90:	e8 6b b9 ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0104a95:	c7 04 24 f0 cd 10 c0 	movl   $0xc010cdf0,(%esp)
c0104a9c:	e8 08 b8 ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0104aa1:	b8 00 50 00 00       	mov    $0x5000,%eax
c0104aa6:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==5);
c0104aa9:	a1 64 ef 19 c0       	mov    0xc019ef64,%eax
c0104aae:	83 f8 05             	cmp    $0x5,%eax
c0104ab1:	74 24                	je     c0104ad7 <_fifo_check_swap+0x150>
c0104ab3:	c7 44 24 0c 16 ce 10 	movl   $0xc010ce16,0xc(%esp)
c0104aba:	c0 
c0104abb:	c7 44 24 08 ea cc 10 	movl   $0xc010ccea,0x8(%esp)
c0104ac2:	c0 
c0104ac3:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0104aca:	00 
c0104acb:	c7 04 24 ff cc 10 c0 	movl   $0xc010ccff,(%esp)
c0104ad2:	e8 29 b9 ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0104ad7:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0104ade:	e8 c6 b7 ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0104ae3:	b8 00 20 00 00       	mov    $0x2000,%eax
c0104ae8:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==5);
c0104aeb:	a1 64 ef 19 c0       	mov    0xc019ef64,%eax
c0104af0:	83 f8 05             	cmp    $0x5,%eax
c0104af3:	74 24                	je     c0104b19 <_fifo_check_swap+0x192>
c0104af5:	c7 44 24 0c 16 ce 10 	movl   $0xc010ce16,0xc(%esp)
c0104afc:	c0 
c0104afd:	c7 44 24 08 ea cc 10 	movl   $0xc010ccea,0x8(%esp)
c0104b04:	c0 
c0104b05:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c0104b0c:	00 
c0104b0d:	c7 04 24 ff cc 10 c0 	movl   $0xc010ccff,(%esp)
c0104b14:	e8 e7 b8 ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0104b19:	c7 04 24 78 cd 10 c0 	movl   $0xc010cd78,(%esp)
c0104b20:	e8 84 b7 ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0104b25:	b8 00 10 00 00       	mov    $0x1000,%eax
c0104b2a:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==6);
c0104b2d:	a1 64 ef 19 c0       	mov    0xc019ef64,%eax
c0104b32:	83 f8 06             	cmp    $0x6,%eax
c0104b35:	74 24                	je     c0104b5b <_fifo_check_swap+0x1d4>
c0104b37:	c7 44 24 0c 25 ce 10 	movl   $0xc010ce25,0xc(%esp)
c0104b3e:	c0 
c0104b3f:	c7 44 24 08 ea cc 10 	movl   $0xc010ccea,0x8(%esp)
c0104b46:	c0 
c0104b47:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c0104b4e:	00 
c0104b4f:	c7 04 24 ff cc 10 c0 	movl   $0xc010ccff,(%esp)
c0104b56:	e8 a5 b8 ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0104b5b:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0104b62:	e8 42 b7 ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0104b67:	b8 00 20 00 00       	mov    $0x2000,%eax
c0104b6c:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==7);
c0104b6f:	a1 64 ef 19 c0       	mov    0xc019ef64,%eax
c0104b74:	83 f8 07             	cmp    $0x7,%eax
c0104b77:	74 24                	je     c0104b9d <_fifo_check_swap+0x216>
c0104b79:	c7 44 24 0c 34 ce 10 	movl   $0xc010ce34,0xc(%esp)
c0104b80:	c0 
c0104b81:	c7 44 24 08 ea cc 10 	movl   $0xc010ccea,0x8(%esp)
c0104b88:	c0 
c0104b89:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0104b90:	00 
c0104b91:	c7 04 24 ff cc 10 c0 	movl   $0xc010ccff,(%esp)
c0104b98:	e8 63 b8 ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c0104b9d:	c7 04 24 40 cd 10 c0 	movl   $0xc010cd40,(%esp)
c0104ba4:	e8 00 b7 ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0104ba9:	b8 00 30 00 00       	mov    $0x3000,%eax
c0104bae:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==8);
c0104bb1:	a1 64 ef 19 c0       	mov    0xc019ef64,%eax
c0104bb6:	83 f8 08             	cmp    $0x8,%eax
c0104bb9:	74 24                	je     c0104bdf <_fifo_check_swap+0x258>
c0104bbb:	c7 44 24 0c 43 ce 10 	movl   $0xc010ce43,0xc(%esp)
c0104bc2:	c0 
c0104bc3:	c7 44 24 08 ea cc 10 	movl   $0xc010ccea,0x8(%esp)
c0104bca:	c0 
c0104bcb:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0104bd2:	00 
c0104bd3:	c7 04 24 ff cc 10 c0 	movl   $0xc010ccff,(%esp)
c0104bda:	e8 21 b8 ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0104bdf:	c7 04 24 a0 cd 10 c0 	movl   $0xc010cda0,(%esp)
c0104be6:	e8 be b6 ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0104beb:	b8 00 40 00 00       	mov    $0x4000,%eax
c0104bf0:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==9);
c0104bf3:	a1 64 ef 19 c0       	mov    0xc019ef64,%eax
c0104bf8:	83 f8 09             	cmp    $0x9,%eax
c0104bfb:	74 24                	je     c0104c21 <_fifo_check_swap+0x29a>
c0104bfd:	c7 44 24 0c 52 ce 10 	movl   $0xc010ce52,0xc(%esp)
c0104c04:	c0 
c0104c05:	c7 44 24 08 ea cc 10 	movl   $0xc010ccea,0x8(%esp)
c0104c0c:	c0 
c0104c0d:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
c0104c14:	00 
c0104c15:	c7 04 24 ff cc 10 c0 	movl   $0xc010ccff,(%esp)
c0104c1c:	e8 df b7 ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0104c21:	c7 04 24 f0 cd 10 c0 	movl   $0xc010cdf0,(%esp)
c0104c28:	e8 7c b6 ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0104c2d:	b8 00 50 00 00       	mov    $0x5000,%eax
c0104c32:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==10);
c0104c35:	a1 64 ef 19 c0       	mov    0xc019ef64,%eax
c0104c3a:	83 f8 0a             	cmp    $0xa,%eax
c0104c3d:	74 24                	je     c0104c63 <_fifo_check_swap+0x2dc>
c0104c3f:	c7 44 24 0c 61 ce 10 	movl   $0xc010ce61,0xc(%esp)
c0104c46:	c0 
c0104c47:	c7 44 24 08 ea cc 10 	movl   $0xc010ccea,0x8(%esp)
c0104c4e:	c0 
c0104c4f:	c7 44 24 04 76 00 00 	movl   $0x76,0x4(%esp)
c0104c56:	00 
c0104c57:	c7 04 24 ff cc 10 c0 	movl   $0xc010ccff,(%esp)
c0104c5e:	e8 9d b7 ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0104c63:	c7 04 24 78 cd 10 c0 	movl   $0xc010cd78,(%esp)
c0104c6a:	e8 3a b6 ff ff       	call   c01002a9 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
c0104c6f:	b8 00 10 00 00       	mov    $0x1000,%eax
c0104c74:	0f b6 00             	movzbl (%eax),%eax
c0104c77:	3c 0a                	cmp    $0xa,%al
c0104c79:	74 24                	je     c0104c9f <_fifo_check_swap+0x318>
c0104c7b:	c7 44 24 0c 74 ce 10 	movl   $0xc010ce74,0xc(%esp)
c0104c82:	c0 
c0104c83:	c7 44 24 08 ea cc 10 	movl   $0xc010ccea,0x8(%esp)
c0104c8a:	c0 
c0104c8b:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
c0104c92:	00 
c0104c93:	c7 04 24 ff cc 10 c0 	movl   $0xc010ccff,(%esp)
c0104c9a:	e8 61 b7 ff ff       	call   c0100400 <__panic>
    *(unsigned char *)0x1000 = 0x0a;
c0104c9f:	b8 00 10 00 00       	mov    $0x1000,%eax
c0104ca4:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==11);
c0104ca7:	a1 64 ef 19 c0       	mov    0xc019ef64,%eax
c0104cac:	83 f8 0b             	cmp    $0xb,%eax
c0104caf:	74 24                	je     c0104cd5 <_fifo_check_swap+0x34e>
c0104cb1:	c7 44 24 0c 95 ce 10 	movl   $0xc010ce95,0xc(%esp)
c0104cb8:	c0 
c0104cb9:	c7 44 24 08 ea cc 10 	movl   $0xc010ccea,0x8(%esp)
c0104cc0:	c0 
c0104cc1:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
c0104cc8:	00 
c0104cc9:	c7 04 24 ff cc 10 c0 	movl   $0xc010ccff,(%esp)
c0104cd0:	e8 2b b7 ff ff       	call   c0100400 <__panic>
    return 0;
c0104cd5:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104cda:	c9                   	leave  
c0104cdb:	c3                   	ret    

c0104cdc <_fifo_init>:


static int
_fifo_init(void)
{
c0104cdc:	55                   	push   %ebp
c0104cdd:	89 e5                	mov    %esp,%ebp
    return 0;
c0104cdf:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104ce4:	5d                   	pop    %ebp
c0104ce5:	c3                   	ret    

c0104ce6 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c0104ce6:	55                   	push   %ebp
c0104ce7:	89 e5                	mov    %esp,%ebp
    return 0;
c0104ce9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104cee:	5d                   	pop    %ebp
c0104cef:	c3                   	ret    

c0104cf0 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
c0104cf0:	55                   	push   %ebp
c0104cf1:	89 e5                	mov    %esp,%ebp
c0104cf3:	b8 00 00 00 00       	mov    $0x0,%eax
c0104cf8:	5d                   	pop    %ebp
c0104cf9:	c3                   	ret    

c0104cfa <__intr_save>:
__intr_save(void) {
c0104cfa:	55                   	push   %ebp
c0104cfb:	89 e5                	mov    %esp,%ebp
c0104cfd:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0104d00:	9c                   	pushf  
c0104d01:	58                   	pop    %eax
c0104d02:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0104d05:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0104d08:	25 00 02 00 00       	and    $0x200,%eax
c0104d0d:	85 c0                	test   %eax,%eax
c0104d0f:	74 0c                	je     c0104d1d <__intr_save+0x23>
        intr_disable();
c0104d11:	e8 ff d4 ff ff       	call   c0102215 <intr_disable>
        return 1;
c0104d16:	b8 01 00 00 00       	mov    $0x1,%eax
c0104d1b:	eb 05                	jmp    c0104d22 <__intr_save+0x28>
    return 0;
c0104d1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104d22:	c9                   	leave  
c0104d23:	c3                   	ret    

c0104d24 <__intr_restore>:
__intr_restore(bool flag) {
c0104d24:	55                   	push   %ebp
c0104d25:	89 e5                	mov    %esp,%ebp
c0104d27:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0104d2a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104d2e:	74 05                	je     c0104d35 <__intr_restore+0x11>
        intr_enable();
c0104d30:	e8 da d4 ff ff       	call   c010220f <intr_enable>
}
c0104d35:	c9                   	leave  
c0104d36:	c3                   	ret    

c0104d37 <page2ppn>:
page2ppn(struct Page *page) {
c0104d37:	55                   	push   %ebp
c0104d38:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0104d3a:	8b 55 08             	mov    0x8(%ebp),%edx
c0104d3d:	a1 58 11 1a c0       	mov    0xc01a1158,%eax
c0104d42:	29 c2                	sub    %eax,%edx
c0104d44:	89 d0                	mov    %edx,%eax
c0104d46:	c1 f8 05             	sar    $0x5,%eax
}
c0104d49:	5d                   	pop    %ebp
c0104d4a:	c3                   	ret    

c0104d4b <page2pa>:
page2pa(struct Page *page) {
c0104d4b:	55                   	push   %ebp
c0104d4c:	89 e5                	mov    %esp,%ebp
c0104d4e:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0104d51:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d54:	89 04 24             	mov    %eax,(%esp)
c0104d57:	e8 db ff ff ff       	call   c0104d37 <page2ppn>
c0104d5c:	c1 e0 0c             	shl    $0xc,%eax
}
c0104d5f:	c9                   	leave  
c0104d60:	c3                   	ret    

c0104d61 <pa2page>:
pa2page(uintptr_t pa) {
c0104d61:	55                   	push   %ebp
c0104d62:	89 e5                	mov    %esp,%ebp
c0104d64:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0104d67:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d6a:	c1 e8 0c             	shr    $0xc,%eax
c0104d6d:	89 c2                	mov    %eax,%edx
c0104d6f:	a1 80 ef 19 c0       	mov    0xc019ef80,%eax
c0104d74:	39 c2                	cmp    %eax,%edx
c0104d76:	72 1c                	jb     c0104d94 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0104d78:	c7 44 24 08 b8 ce 10 	movl   $0xc010ceb8,0x8(%esp)
c0104d7f:	c0 
c0104d80:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0104d87:	00 
c0104d88:	c7 04 24 d7 ce 10 c0 	movl   $0xc010ced7,(%esp)
c0104d8f:	e8 6c b6 ff ff       	call   c0100400 <__panic>
    return &pages[PPN(pa)];
c0104d94:	a1 58 11 1a c0       	mov    0xc01a1158,%eax
c0104d99:	8b 55 08             	mov    0x8(%ebp),%edx
c0104d9c:	c1 ea 0c             	shr    $0xc,%edx
c0104d9f:	c1 e2 05             	shl    $0x5,%edx
c0104da2:	01 d0                	add    %edx,%eax
}
c0104da4:	c9                   	leave  
c0104da5:	c3                   	ret    

c0104da6 <page2kva>:
page2kva(struct Page *page) {
c0104da6:	55                   	push   %ebp
c0104da7:	89 e5                	mov    %esp,%ebp
c0104da9:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0104dac:	8b 45 08             	mov    0x8(%ebp),%eax
c0104daf:	89 04 24             	mov    %eax,(%esp)
c0104db2:	e8 94 ff ff ff       	call   c0104d4b <page2pa>
c0104db7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104dba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104dbd:	c1 e8 0c             	shr    $0xc,%eax
c0104dc0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104dc3:	a1 80 ef 19 c0       	mov    0xc019ef80,%eax
c0104dc8:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104dcb:	72 23                	jb     c0104df0 <page2kva+0x4a>
c0104dcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104dd0:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104dd4:	c7 44 24 08 e8 ce 10 	movl   $0xc010cee8,0x8(%esp)
c0104ddb:	c0 
c0104ddc:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0104de3:	00 
c0104de4:	c7 04 24 d7 ce 10 c0 	movl   $0xc010ced7,(%esp)
c0104deb:	e8 10 b6 ff ff       	call   c0100400 <__panic>
c0104df0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104df3:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0104df8:	c9                   	leave  
c0104df9:	c3                   	ret    

c0104dfa <kva2page>:
kva2page(void *kva) {
c0104dfa:	55                   	push   %ebp
c0104dfb:	89 e5                	mov    %esp,%ebp
c0104dfd:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c0104e00:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e03:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104e06:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0104e0d:	77 23                	ja     c0104e32 <kva2page+0x38>
c0104e0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e12:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104e16:	c7 44 24 08 0c cf 10 	movl   $0xc010cf0c,0x8(%esp)
c0104e1d:	c0 
c0104e1e:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c0104e25:	00 
c0104e26:	c7 04 24 d7 ce 10 c0 	movl   $0xc010ced7,(%esp)
c0104e2d:	e8 ce b5 ff ff       	call   c0100400 <__panic>
c0104e32:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e35:	05 00 00 00 40       	add    $0x40000000,%eax
c0104e3a:	89 04 24             	mov    %eax,(%esp)
c0104e3d:	e8 1f ff ff ff       	call   c0104d61 <pa2page>
}
c0104e42:	c9                   	leave  
c0104e43:	c3                   	ret    

c0104e44 <__slob_get_free_pages>:
static slob_t *slobfree = &arena;
static bigblock_t *bigblocks;


static void* __slob_get_free_pages(gfp_t gfp, int order)
{
c0104e44:	55                   	push   %ebp
c0104e45:	89 e5                	mov    %esp,%ebp
c0104e47:	83 ec 28             	sub    $0x28,%esp
  struct Page * page = alloc_pages(1 << order);
c0104e4a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104e4d:	ba 01 00 00 00       	mov    $0x1,%edx
c0104e52:	89 c1                	mov    %eax,%ecx
c0104e54:	d3 e2                	shl    %cl,%edx
c0104e56:	89 d0                	mov    %edx,%eax
c0104e58:	89 04 24             	mov    %eax,(%esp)
c0104e5b:	e8 77 26 00 00       	call   c01074d7 <alloc_pages>
c0104e60:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!page)
c0104e63:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104e67:	75 07                	jne    c0104e70 <__slob_get_free_pages+0x2c>
    return NULL;
c0104e69:	b8 00 00 00 00       	mov    $0x0,%eax
c0104e6e:	eb 0b                	jmp    c0104e7b <__slob_get_free_pages+0x37>
  return page2kva(page);
c0104e70:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e73:	89 04 24             	mov    %eax,(%esp)
c0104e76:	e8 2b ff ff ff       	call   c0104da6 <page2kva>
}
c0104e7b:	c9                   	leave  
c0104e7c:	c3                   	ret    

c0104e7d <__slob_free_pages>:

#define __slob_get_free_page(gfp) __slob_get_free_pages(gfp, 0)

static inline void __slob_free_pages(unsigned long kva, int order)
{
c0104e7d:	55                   	push   %ebp
c0104e7e:	89 e5                	mov    %esp,%ebp
c0104e80:	53                   	push   %ebx
c0104e81:	83 ec 14             	sub    $0x14,%esp
  free_pages(kva2page(kva), 1 << order);
c0104e84:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104e87:	ba 01 00 00 00       	mov    $0x1,%edx
c0104e8c:	89 c1                	mov    %eax,%ecx
c0104e8e:	d3 e2                	shl    %cl,%edx
c0104e90:	89 d0                	mov    %edx,%eax
c0104e92:	89 c3                	mov    %eax,%ebx
c0104e94:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e97:	89 04 24             	mov    %eax,(%esp)
c0104e9a:	e8 5b ff ff ff       	call   c0104dfa <kva2page>
c0104e9f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0104ea3:	89 04 24             	mov    %eax,(%esp)
c0104ea6:	e8 97 26 00 00       	call   c0107542 <free_pages>
}
c0104eab:	83 c4 14             	add    $0x14,%esp
c0104eae:	5b                   	pop    %ebx
c0104eaf:	5d                   	pop    %ebp
c0104eb0:	c3                   	ret    

c0104eb1 <slob_alloc>:

static void slob_free(void *b, int size);

static void *slob_alloc(size_t size, gfp_t gfp, int align)
{
c0104eb1:	55                   	push   %ebp
c0104eb2:	89 e5                	mov    %esp,%ebp
c0104eb4:	83 ec 38             	sub    $0x38,%esp
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
c0104eb7:	8b 45 08             	mov    0x8(%ebp),%eax
c0104eba:	83 c0 08             	add    $0x8,%eax
c0104ebd:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c0104ec2:	76 24                	jbe    c0104ee8 <slob_alloc+0x37>
c0104ec4:	c7 44 24 0c 30 cf 10 	movl   $0xc010cf30,0xc(%esp)
c0104ecb:	c0 
c0104ecc:	c7 44 24 08 4f cf 10 	movl   $0xc010cf4f,0x8(%esp)
c0104ed3:	c0 
c0104ed4:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0104edb:	00 
c0104edc:	c7 04 24 64 cf 10 c0 	movl   $0xc010cf64,(%esp)
c0104ee3:	e8 18 b5 ff ff       	call   c0100400 <__panic>

	slob_t *prev, *cur, *aligned = 0;
c0104ee8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	int delta = 0, units = SLOB_UNITS(size);
c0104eef:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0104ef6:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ef9:	83 c0 07             	add    $0x7,%eax
c0104efc:	c1 e8 03             	shr    $0x3,%eax
c0104eff:	89 45 e0             	mov    %eax,-0x20(%ebp)
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
c0104f02:	e8 f3 fd ff ff       	call   c0104cfa <__intr_save>
c0104f07:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	prev = slobfree;
c0104f0a:	a1 08 aa 12 c0       	mov    0xc012aa08,%eax
c0104f0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c0104f12:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f15:	8b 40 04             	mov    0x4(%eax),%eax
c0104f18:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (align) {
c0104f1b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0104f1f:	74 25                	je     c0104f46 <slob_alloc+0x95>
			aligned = (slob_t *)ALIGN((unsigned long)cur, align);
c0104f21:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104f24:	8b 45 10             	mov    0x10(%ebp),%eax
c0104f27:	01 d0                	add    %edx,%eax
c0104f29:	8d 50 ff             	lea    -0x1(%eax),%edx
c0104f2c:	8b 45 10             	mov    0x10(%ebp),%eax
c0104f2f:	f7 d8                	neg    %eax
c0104f31:	21 d0                	and    %edx,%eax
c0104f33:	89 45 ec             	mov    %eax,-0x14(%ebp)
			delta = aligned - cur;
c0104f36:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104f39:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f3c:	29 c2                	sub    %eax,%edx
c0104f3e:	89 d0                	mov    %edx,%eax
c0104f40:	c1 f8 03             	sar    $0x3,%eax
c0104f43:	89 45 e8             	mov    %eax,-0x18(%ebp)
		}
		if (cur->units >= units + delta) { /* room enough? */
c0104f46:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f49:	8b 00                	mov    (%eax),%eax
c0104f4b:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104f4e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0104f51:	01 ca                	add    %ecx,%edx
c0104f53:	39 d0                	cmp    %edx,%eax
c0104f55:	0f 8c aa 00 00 00    	jl     c0105005 <slob_alloc+0x154>
			if (delta) { /* need to fragment head to align? */
c0104f5b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104f5f:	74 38                	je     c0104f99 <slob_alloc+0xe8>
				aligned->units = cur->units - delta;
c0104f61:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f64:	8b 00                	mov    (%eax),%eax
c0104f66:	2b 45 e8             	sub    -0x18(%ebp),%eax
c0104f69:	89 c2                	mov    %eax,%edx
c0104f6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104f6e:	89 10                	mov    %edx,(%eax)
				aligned->next = cur->next;
c0104f70:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f73:	8b 50 04             	mov    0x4(%eax),%edx
c0104f76:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104f79:	89 50 04             	mov    %edx,0x4(%eax)
				cur->next = aligned;
c0104f7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f7f:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104f82:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = delta;
c0104f85:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f88:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104f8b:	89 10                	mov    %edx,(%eax)
				prev = cur;
c0104f8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f90:	89 45 f4             	mov    %eax,-0xc(%ebp)
				cur = aligned;
c0104f93:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104f96:	89 45 f0             	mov    %eax,-0x10(%ebp)
			}

			if (cur->units == units) /* exact fit? */
c0104f99:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f9c:	8b 00                	mov    (%eax),%eax
c0104f9e:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0104fa1:	75 0e                	jne    c0104fb1 <slob_alloc+0x100>
				prev->next = cur->next; /* unlink */
c0104fa3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104fa6:	8b 50 04             	mov    0x4(%eax),%edx
c0104fa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104fac:	89 50 04             	mov    %edx,0x4(%eax)
c0104faf:	eb 3c                	jmp    c0104fed <slob_alloc+0x13c>
			else { /* fragment */
				prev->next = cur + units;
c0104fb1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104fb4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0104fbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104fbe:	01 c2                	add    %eax,%edx
c0104fc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104fc3:	89 50 04             	mov    %edx,0x4(%eax)
				prev->next->units = cur->units - units;
c0104fc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104fc9:	8b 40 04             	mov    0x4(%eax),%eax
c0104fcc:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104fcf:	8b 12                	mov    (%edx),%edx
c0104fd1:	2b 55 e0             	sub    -0x20(%ebp),%edx
c0104fd4:	89 10                	mov    %edx,(%eax)
				prev->next->next = cur->next;
c0104fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104fd9:	8b 40 04             	mov    0x4(%eax),%eax
c0104fdc:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104fdf:	8b 52 04             	mov    0x4(%edx),%edx
c0104fe2:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = units;
c0104fe5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104fe8:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104feb:	89 10                	mov    %edx,(%eax)
			}

			slobfree = prev;
c0104fed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ff0:	a3 08 aa 12 c0       	mov    %eax,0xc012aa08
			spin_unlock_irqrestore(&slob_lock, flags);
c0104ff5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104ff8:	89 04 24             	mov    %eax,(%esp)
c0104ffb:	e8 24 fd ff ff       	call   c0104d24 <__intr_restore>
			return cur;
c0105000:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105003:	eb 7f                	jmp    c0105084 <slob_alloc+0x1d3>
		}
		if (cur == slobfree) {
c0105005:	a1 08 aa 12 c0       	mov    0xc012aa08,%eax
c010500a:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010500d:	75 61                	jne    c0105070 <slob_alloc+0x1bf>
			spin_unlock_irqrestore(&slob_lock, flags);
c010500f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105012:	89 04 24             	mov    %eax,(%esp)
c0105015:	e8 0a fd ff ff       	call   c0104d24 <__intr_restore>

			if (size == PAGE_SIZE) /* trying to shrink arena? */
c010501a:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c0105021:	75 07                	jne    c010502a <slob_alloc+0x179>
				return 0;
c0105023:	b8 00 00 00 00       	mov    $0x0,%eax
c0105028:	eb 5a                	jmp    c0105084 <slob_alloc+0x1d3>

			cur = (slob_t *)__slob_get_free_page(gfp);
c010502a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105031:	00 
c0105032:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105035:	89 04 24             	mov    %eax,(%esp)
c0105038:	e8 07 fe ff ff       	call   c0104e44 <__slob_get_free_pages>
c010503d:	89 45 f0             	mov    %eax,-0x10(%ebp)
			if (!cur)
c0105040:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105044:	75 07                	jne    c010504d <slob_alloc+0x19c>
				return 0;
c0105046:	b8 00 00 00 00       	mov    $0x0,%eax
c010504b:	eb 37                	jmp    c0105084 <slob_alloc+0x1d3>

			slob_free(cur, PAGE_SIZE);
c010504d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0105054:	00 
c0105055:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105058:	89 04 24             	mov    %eax,(%esp)
c010505b:	e8 26 00 00 00       	call   c0105086 <slob_free>
			spin_lock_irqsave(&slob_lock, flags);
c0105060:	e8 95 fc ff ff       	call   c0104cfa <__intr_save>
c0105065:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			cur = slobfree;
c0105068:	a1 08 aa 12 c0       	mov    0xc012aa08,%eax
c010506d:	89 45 f0             	mov    %eax,-0x10(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c0105070:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105073:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105076:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105079:	8b 40 04             	mov    0x4(%eax),%eax
c010507c:	89 45 f0             	mov    %eax,-0x10(%ebp)
		}
	}
c010507f:	e9 97 fe ff ff       	jmp    c0104f1b <slob_alloc+0x6a>
}
c0105084:	c9                   	leave  
c0105085:	c3                   	ret    

c0105086 <slob_free>:

static void slob_free(void *block, int size)
{
c0105086:	55                   	push   %ebp
c0105087:	89 e5                	mov    %esp,%ebp
c0105089:	83 ec 28             	sub    $0x28,%esp
	slob_t *cur, *b = (slob_t *)block;
c010508c:	8b 45 08             	mov    0x8(%ebp),%eax
c010508f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c0105092:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105096:	75 05                	jne    c010509d <slob_free+0x17>
		return;
c0105098:	e9 ff 00 00 00       	jmp    c010519c <slob_free+0x116>

	if (size)
c010509d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01050a1:	74 10                	je     c01050b3 <slob_free+0x2d>
		b->units = SLOB_UNITS(size);
c01050a3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01050a6:	83 c0 07             	add    $0x7,%eax
c01050a9:	c1 e8 03             	shr    $0x3,%eax
c01050ac:	89 c2                	mov    %eax,%edx
c01050ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01050b1:	89 10                	mov    %edx,(%eax)

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
c01050b3:	e8 42 fc ff ff       	call   c0104cfa <__intr_save>
c01050b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c01050bb:	a1 08 aa 12 c0       	mov    0xc012aa08,%eax
c01050c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01050c3:	eb 27                	jmp    c01050ec <slob_free+0x66>
		if (cur >= cur->next && (b > cur || b < cur->next))
c01050c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050c8:	8b 40 04             	mov    0x4(%eax),%eax
c01050cb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01050ce:	77 13                	ja     c01050e3 <slob_free+0x5d>
c01050d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01050d3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01050d6:	77 27                	ja     c01050ff <slob_free+0x79>
c01050d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050db:	8b 40 04             	mov    0x4(%eax),%eax
c01050de:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01050e1:	77 1c                	ja     c01050ff <slob_free+0x79>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c01050e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050e6:	8b 40 04             	mov    0x4(%eax),%eax
c01050e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01050ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01050ef:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01050f2:	76 d1                	jbe    c01050c5 <slob_free+0x3f>
c01050f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050f7:	8b 40 04             	mov    0x4(%eax),%eax
c01050fa:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01050fd:	76 c6                	jbe    c01050c5 <slob_free+0x3f>
			break;

	if (b + b->units == cur->next) {
c01050ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105102:	8b 00                	mov    (%eax),%eax
c0105104:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010510b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010510e:	01 c2                	add    %eax,%edx
c0105110:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105113:	8b 40 04             	mov    0x4(%eax),%eax
c0105116:	39 c2                	cmp    %eax,%edx
c0105118:	75 25                	jne    c010513f <slob_free+0xb9>
		b->units += cur->next->units;
c010511a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010511d:	8b 10                	mov    (%eax),%edx
c010511f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105122:	8b 40 04             	mov    0x4(%eax),%eax
c0105125:	8b 00                	mov    (%eax),%eax
c0105127:	01 c2                	add    %eax,%edx
c0105129:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010512c:	89 10                	mov    %edx,(%eax)
		b->next = cur->next->next;
c010512e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105131:	8b 40 04             	mov    0x4(%eax),%eax
c0105134:	8b 50 04             	mov    0x4(%eax),%edx
c0105137:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010513a:	89 50 04             	mov    %edx,0x4(%eax)
c010513d:	eb 0c                	jmp    c010514b <slob_free+0xc5>
	} else
		b->next = cur->next;
c010513f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105142:	8b 50 04             	mov    0x4(%eax),%edx
c0105145:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105148:	89 50 04             	mov    %edx,0x4(%eax)

	if (cur + cur->units == b) {
c010514b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010514e:	8b 00                	mov    (%eax),%eax
c0105150:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0105157:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010515a:	01 d0                	add    %edx,%eax
c010515c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010515f:	75 1f                	jne    c0105180 <slob_free+0xfa>
		cur->units += b->units;
c0105161:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105164:	8b 10                	mov    (%eax),%edx
c0105166:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105169:	8b 00                	mov    (%eax),%eax
c010516b:	01 c2                	add    %eax,%edx
c010516d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105170:	89 10                	mov    %edx,(%eax)
		cur->next = b->next;
c0105172:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105175:	8b 50 04             	mov    0x4(%eax),%edx
c0105178:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010517b:	89 50 04             	mov    %edx,0x4(%eax)
c010517e:	eb 09                	jmp    c0105189 <slob_free+0x103>
	} else
		cur->next = b;
c0105180:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105183:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105186:	89 50 04             	mov    %edx,0x4(%eax)

	slobfree = cur;
c0105189:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010518c:	a3 08 aa 12 c0       	mov    %eax,0xc012aa08

	spin_unlock_irqrestore(&slob_lock, flags);
c0105191:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105194:	89 04 24             	mov    %eax,(%esp)
c0105197:	e8 88 fb ff ff       	call   c0104d24 <__intr_restore>
}
c010519c:	c9                   	leave  
c010519d:	c3                   	ret    

c010519e <slob_init>:



void
slob_init(void) {
c010519e:	55                   	push   %ebp
c010519f:	89 e5                	mov    %esp,%ebp
c01051a1:	83 ec 18             	sub    $0x18,%esp
  cprintf("use SLOB allocator\n");
c01051a4:	c7 04 24 76 cf 10 c0 	movl   $0xc010cf76,(%esp)
c01051ab:	e8 f9 b0 ff ff       	call   c01002a9 <cprintf>
}
c01051b0:	c9                   	leave  
c01051b1:	c3                   	ret    

c01051b2 <kmalloc_init>:

inline void 
kmalloc_init(void) {
c01051b2:	55                   	push   %ebp
c01051b3:	89 e5                	mov    %esp,%ebp
c01051b5:	83 ec 18             	sub    $0x18,%esp
    slob_init();
c01051b8:	e8 e1 ff ff ff       	call   c010519e <slob_init>
    cprintf("kmalloc_init() succeeded!\n");
c01051bd:	c7 04 24 8a cf 10 c0 	movl   $0xc010cf8a,(%esp)
c01051c4:	e8 e0 b0 ff ff       	call   c01002a9 <cprintf>
}
c01051c9:	c9                   	leave  
c01051ca:	c3                   	ret    

c01051cb <slob_allocated>:

size_t
slob_allocated(void) {
c01051cb:	55                   	push   %ebp
c01051cc:	89 e5                	mov    %esp,%ebp
  return 0;
c01051ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01051d3:	5d                   	pop    %ebp
c01051d4:	c3                   	ret    

c01051d5 <kallocated>:

size_t
kallocated(void) {
c01051d5:	55                   	push   %ebp
c01051d6:	89 e5                	mov    %esp,%ebp
   return slob_allocated();
c01051d8:	e8 ee ff ff ff       	call   c01051cb <slob_allocated>
}
c01051dd:	5d                   	pop    %ebp
c01051de:	c3                   	ret    

c01051df <find_order>:

static int find_order(int size)
{
c01051df:	55                   	push   %ebp
c01051e0:	89 e5                	mov    %esp,%ebp
c01051e2:	83 ec 10             	sub    $0x10,%esp
	int order = 0;
c01051e5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c01051ec:	eb 07                	jmp    c01051f5 <find_order+0x16>
		order++;
c01051ee:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c01051f2:	d1 7d 08             	sarl   0x8(%ebp)
c01051f5:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c01051fc:	7f f0                	jg     c01051ee <find_order+0xf>
	return order;
c01051fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105201:	c9                   	leave  
c0105202:	c3                   	ret    

c0105203 <__kmalloc>:

static void *__kmalloc(size_t size, gfp_t gfp)
{
c0105203:	55                   	push   %ebp
c0105204:	89 e5                	mov    %esp,%ebp
c0105206:	83 ec 28             	sub    $0x28,%esp
	slob_t *m;
	bigblock_t *bb;
	unsigned long flags;

	if (size < PAGE_SIZE - SLOB_UNIT) {
c0105209:	81 7d 08 f7 0f 00 00 	cmpl   $0xff7,0x8(%ebp)
c0105210:	77 38                	ja     c010524a <__kmalloc+0x47>
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
c0105212:	8b 45 08             	mov    0x8(%ebp),%eax
c0105215:	8d 50 08             	lea    0x8(%eax),%edx
c0105218:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010521f:	00 
c0105220:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105223:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105227:	89 14 24             	mov    %edx,(%esp)
c010522a:	e8 82 fc ff ff       	call   c0104eb1 <slob_alloc>
c010522f:	89 45 f4             	mov    %eax,-0xc(%ebp)
		return m ? (void *)(m + 1) : 0;
c0105232:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105236:	74 08                	je     c0105240 <__kmalloc+0x3d>
c0105238:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010523b:	83 c0 08             	add    $0x8,%eax
c010523e:	eb 05                	jmp    c0105245 <__kmalloc+0x42>
c0105240:	b8 00 00 00 00       	mov    $0x0,%eax
c0105245:	e9 a6 00 00 00       	jmp    c01052f0 <__kmalloc+0xed>
	}

	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
c010524a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105251:	00 
c0105252:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105255:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105259:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
c0105260:	e8 4c fc ff ff       	call   c0104eb1 <slob_alloc>
c0105265:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (!bb)
c0105268:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010526c:	75 07                	jne    c0105275 <__kmalloc+0x72>
		return 0;
c010526e:	b8 00 00 00 00       	mov    $0x0,%eax
c0105273:	eb 7b                	jmp    c01052f0 <__kmalloc+0xed>

	bb->order = find_order(size);
c0105275:	8b 45 08             	mov    0x8(%ebp),%eax
c0105278:	89 04 24             	mov    %eax,(%esp)
c010527b:	e8 5f ff ff ff       	call   c01051df <find_order>
c0105280:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105283:	89 02                	mov    %eax,(%edx)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
c0105285:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105288:	8b 00                	mov    (%eax),%eax
c010528a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010528e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105291:	89 04 24             	mov    %eax,(%esp)
c0105294:	e8 ab fb ff ff       	call   c0104e44 <__slob_get_free_pages>
c0105299:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010529c:	89 42 04             	mov    %eax,0x4(%edx)

	if (bb->pages) {
c010529f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01052a2:	8b 40 04             	mov    0x4(%eax),%eax
c01052a5:	85 c0                	test   %eax,%eax
c01052a7:	74 2f                	je     c01052d8 <__kmalloc+0xd5>
		spin_lock_irqsave(&block_lock, flags);
c01052a9:	e8 4c fa ff ff       	call   c0104cfa <__intr_save>
c01052ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
		bb->next = bigblocks;
c01052b1:	8b 15 68 ef 19 c0    	mov    0xc019ef68,%edx
c01052b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01052ba:	89 50 08             	mov    %edx,0x8(%eax)
		bigblocks = bb;
c01052bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01052c0:	a3 68 ef 19 c0       	mov    %eax,0xc019ef68
		spin_unlock_irqrestore(&block_lock, flags);
c01052c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01052c8:	89 04 24             	mov    %eax,(%esp)
c01052cb:	e8 54 fa ff ff       	call   c0104d24 <__intr_restore>
		return bb->pages;
c01052d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01052d3:	8b 40 04             	mov    0x4(%eax),%eax
c01052d6:	eb 18                	jmp    c01052f0 <__kmalloc+0xed>
	}

	slob_free(bb, sizeof(bigblock_t));
c01052d8:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c01052df:	00 
c01052e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01052e3:	89 04 24             	mov    %eax,(%esp)
c01052e6:	e8 9b fd ff ff       	call   c0105086 <slob_free>
	return 0;
c01052eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01052f0:	c9                   	leave  
c01052f1:	c3                   	ret    

c01052f2 <kmalloc>:

void *
kmalloc(size_t size)
{
c01052f2:	55                   	push   %ebp
c01052f3:	89 e5                	mov    %esp,%ebp
c01052f5:	83 ec 18             	sub    $0x18,%esp
  return __kmalloc(size, 0);
c01052f8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01052ff:	00 
c0105300:	8b 45 08             	mov    0x8(%ebp),%eax
c0105303:	89 04 24             	mov    %eax,(%esp)
c0105306:	e8 f8 fe ff ff       	call   c0105203 <__kmalloc>
}
c010530b:	c9                   	leave  
c010530c:	c3                   	ret    

c010530d <kfree>:


void kfree(void *block)
{
c010530d:	55                   	push   %ebp
c010530e:	89 e5                	mov    %esp,%ebp
c0105310:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb, **last = &bigblocks;
c0105313:	c7 45 f0 68 ef 19 c0 	movl   $0xc019ef68,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c010531a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010531e:	75 05                	jne    c0105325 <kfree+0x18>
		return;
c0105320:	e9 a2 00 00 00       	jmp    c01053c7 <kfree+0xba>

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0105325:	8b 45 08             	mov    0x8(%ebp),%eax
c0105328:	25 ff 0f 00 00       	and    $0xfff,%eax
c010532d:	85 c0                	test   %eax,%eax
c010532f:	75 7f                	jne    c01053b0 <kfree+0xa3>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
c0105331:	e8 c4 f9 ff ff       	call   c0104cfa <__intr_save>
c0105336:	89 45 ec             	mov    %eax,-0x14(%ebp)
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0105339:	a1 68 ef 19 c0       	mov    0xc019ef68,%eax
c010533e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105341:	eb 5c                	jmp    c010539f <kfree+0x92>
			if (bb->pages == block) {
c0105343:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105346:	8b 40 04             	mov    0x4(%eax),%eax
c0105349:	3b 45 08             	cmp    0x8(%ebp),%eax
c010534c:	75 3f                	jne    c010538d <kfree+0x80>
				*last = bb->next;
c010534e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105351:	8b 50 08             	mov    0x8(%eax),%edx
c0105354:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105357:	89 10                	mov    %edx,(%eax)
				spin_unlock_irqrestore(&block_lock, flags);
c0105359:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010535c:	89 04 24             	mov    %eax,(%esp)
c010535f:	e8 c0 f9 ff ff       	call   c0104d24 <__intr_restore>
				__slob_free_pages((unsigned long)block, bb->order);
c0105364:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105367:	8b 10                	mov    (%eax),%edx
c0105369:	8b 45 08             	mov    0x8(%ebp),%eax
c010536c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105370:	89 04 24             	mov    %eax,(%esp)
c0105373:	e8 05 fb ff ff       	call   c0104e7d <__slob_free_pages>
				slob_free(bb, sizeof(bigblock_t));
c0105378:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c010537f:	00 
c0105380:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105383:	89 04 24             	mov    %eax,(%esp)
c0105386:	e8 fb fc ff ff       	call   c0105086 <slob_free>
				return;
c010538b:	eb 3a                	jmp    c01053c7 <kfree+0xba>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c010538d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105390:	83 c0 08             	add    $0x8,%eax
c0105393:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105396:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105399:	8b 40 08             	mov    0x8(%eax),%eax
c010539c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010539f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01053a3:	75 9e                	jne    c0105343 <kfree+0x36>
			}
		}
		spin_unlock_irqrestore(&block_lock, flags);
c01053a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01053a8:	89 04 24             	mov    %eax,(%esp)
c01053ab:	e8 74 f9 ff ff       	call   c0104d24 <__intr_restore>
	}

	slob_free((slob_t *)block - 1, 0);
c01053b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01053b3:	83 e8 08             	sub    $0x8,%eax
c01053b6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01053bd:	00 
c01053be:	89 04 24             	mov    %eax,(%esp)
c01053c1:	e8 c0 fc ff ff       	call   c0105086 <slob_free>
	return;
c01053c6:	90                   	nop
}
c01053c7:	c9                   	leave  
c01053c8:	c3                   	ret    

c01053c9 <ksize>:


unsigned int ksize(const void *block)
{
c01053c9:	55                   	push   %ebp
c01053ca:	89 e5                	mov    %esp,%ebp
c01053cc:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb;
	unsigned long flags;

	if (!block)
c01053cf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01053d3:	75 07                	jne    c01053dc <ksize+0x13>
		return 0;
c01053d5:	b8 00 00 00 00       	mov    $0x0,%eax
c01053da:	eb 6b                	jmp    c0105447 <ksize+0x7e>

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c01053dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01053df:	25 ff 0f 00 00       	and    $0xfff,%eax
c01053e4:	85 c0                	test   %eax,%eax
c01053e6:	75 54                	jne    c010543c <ksize+0x73>
		spin_lock_irqsave(&block_lock, flags);
c01053e8:	e8 0d f9 ff ff       	call   c0104cfa <__intr_save>
c01053ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
		for (bb = bigblocks; bb; bb = bb->next)
c01053f0:	a1 68 ef 19 c0       	mov    0xc019ef68,%eax
c01053f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01053f8:	eb 31                	jmp    c010542b <ksize+0x62>
			if (bb->pages == block) {
c01053fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01053fd:	8b 40 04             	mov    0x4(%eax),%eax
c0105400:	3b 45 08             	cmp    0x8(%ebp),%eax
c0105403:	75 1d                	jne    c0105422 <ksize+0x59>
				spin_unlock_irqrestore(&slob_lock, flags);
c0105405:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105408:	89 04 24             	mov    %eax,(%esp)
c010540b:	e8 14 f9 ff ff       	call   c0104d24 <__intr_restore>
				return PAGE_SIZE << bb->order;
c0105410:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105413:	8b 00                	mov    (%eax),%eax
c0105415:	ba 00 10 00 00       	mov    $0x1000,%edx
c010541a:	89 c1                	mov    %eax,%ecx
c010541c:	d3 e2                	shl    %cl,%edx
c010541e:	89 d0                	mov    %edx,%eax
c0105420:	eb 25                	jmp    c0105447 <ksize+0x7e>
		for (bb = bigblocks; bb; bb = bb->next)
c0105422:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105425:	8b 40 08             	mov    0x8(%eax),%eax
c0105428:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010542b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010542f:	75 c9                	jne    c01053fa <ksize+0x31>
			}
		spin_unlock_irqrestore(&block_lock, flags);
c0105431:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105434:	89 04 24             	mov    %eax,(%esp)
c0105437:	e8 e8 f8 ff ff       	call   c0104d24 <__intr_restore>
	}

	return ((slob_t *)block - 1)->units * SLOB_UNIT;
c010543c:	8b 45 08             	mov    0x8(%ebp),%eax
c010543f:	83 e8 08             	sub    $0x8,%eax
c0105442:	8b 00                	mov    (%eax),%eax
c0105444:	c1 e0 03             	shl    $0x3,%eax
}
c0105447:	c9                   	leave  
c0105448:	c3                   	ret    

c0105449 <pa2page>:
pa2page(uintptr_t pa) {
c0105449:	55                   	push   %ebp
c010544a:	89 e5                	mov    %esp,%ebp
c010544c:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c010544f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105452:	c1 e8 0c             	shr    $0xc,%eax
c0105455:	89 c2                	mov    %eax,%edx
c0105457:	a1 80 ef 19 c0       	mov    0xc019ef80,%eax
c010545c:	39 c2                	cmp    %eax,%edx
c010545e:	72 1c                	jb     c010547c <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0105460:	c7 44 24 08 a8 cf 10 	movl   $0xc010cfa8,0x8(%esp)
c0105467:	c0 
c0105468:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c010546f:	00 
c0105470:	c7 04 24 c7 cf 10 c0 	movl   $0xc010cfc7,(%esp)
c0105477:	e8 84 af ff ff       	call   c0100400 <__panic>
    return &pages[PPN(pa)];
c010547c:	a1 58 11 1a c0       	mov    0xc01a1158,%eax
c0105481:	8b 55 08             	mov    0x8(%ebp),%edx
c0105484:	c1 ea 0c             	shr    $0xc,%edx
c0105487:	c1 e2 05             	shl    $0x5,%edx
c010548a:	01 d0                	add    %edx,%eax
}
c010548c:	c9                   	leave  
c010548d:	c3                   	ret    

c010548e <pte2page>:
pte2page(pte_t pte) {
c010548e:	55                   	push   %ebp
c010548f:	89 e5                	mov    %esp,%ebp
c0105491:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0105494:	8b 45 08             	mov    0x8(%ebp),%eax
c0105497:	83 e0 01             	and    $0x1,%eax
c010549a:	85 c0                	test   %eax,%eax
c010549c:	75 1c                	jne    c01054ba <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c010549e:	c7 44 24 08 d8 cf 10 	movl   $0xc010cfd8,0x8(%esp)
c01054a5:	c0 
c01054a6:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c01054ad:	00 
c01054ae:	c7 04 24 c7 cf 10 c0 	movl   $0xc010cfc7,(%esp)
c01054b5:	e8 46 af ff ff       	call   c0100400 <__panic>
    return pa2page(PTE_ADDR(pte));
c01054ba:	8b 45 08             	mov    0x8(%ebp),%eax
c01054bd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01054c2:	89 04 24             	mov    %eax,(%esp)
c01054c5:	e8 7f ff ff ff       	call   c0105449 <pa2page>
}
c01054ca:	c9                   	leave  
c01054cb:	c3                   	ret    

c01054cc <pde2page>:
pde2page(pde_t pde) {
c01054cc:	55                   	push   %ebp
c01054cd:	89 e5                	mov    %esp,%ebp
c01054cf:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c01054d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01054d5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01054da:	89 04 24             	mov    %eax,(%esp)
c01054dd:	e8 67 ff ff ff       	call   c0105449 <pa2page>
}
c01054e2:	c9                   	leave  
c01054e3:	c3                   	ret    

c01054e4 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
c01054e4:	55                   	push   %ebp
c01054e5:	89 e5                	mov    %esp,%ebp
c01054e7:	83 ec 28             	sub    $0x28,%esp
     swapfs_init();
c01054ea:	e8 42 3c 00 00       	call   c0109131 <swapfs_init>

     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
c01054ef:	a1 1c 11 1a c0       	mov    0xc01a111c,%eax
c01054f4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
c01054f9:	76 0c                	jbe    c0105507 <swap_init+0x23>
c01054fb:	a1 1c 11 1a c0       	mov    0xc01a111c,%eax
c0105500:	3d ff ff ff 00       	cmp    $0xffffff,%eax
c0105505:	76 25                	jbe    c010552c <swap_init+0x48>
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
c0105507:	a1 1c 11 1a c0       	mov    0xc01a111c,%eax
c010550c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105510:	c7 44 24 08 f9 cf 10 	movl   $0xc010cff9,0x8(%esp)
c0105517:	c0 
c0105518:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
c010551f:	00 
c0105520:	c7 04 24 14 d0 10 c0 	movl   $0xc010d014,(%esp)
c0105527:	e8 d4 ae ff ff       	call   c0100400 <__panic>
     }
     

     sm = &swap_manager_fifo;
c010552c:	c7 05 74 ef 19 c0 e0 	movl   $0xc012a9e0,0xc019ef74
c0105533:	a9 12 c0 
     int r = sm->init();
c0105536:	a1 74 ef 19 c0       	mov    0xc019ef74,%eax
c010553b:	8b 40 04             	mov    0x4(%eax),%eax
c010553e:	ff d0                	call   *%eax
c0105540:	89 45 f4             	mov    %eax,-0xc(%ebp)
     
     if (r == 0)
c0105543:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105547:	75 26                	jne    c010556f <swap_init+0x8b>
     {
          swap_init_ok = 1;
c0105549:	c7 05 6c ef 19 c0 01 	movl   $0x1,0xc019ef6c
c0105550:	00 00 00 
          cprintf("SWAP: manager = %s\n", sm->name);
c0105553:	a1 74 ef 19 c0       	mov    0xc019ef74,%eax
c0105558:	8b 00                	mov    (%eax),%eax
c010555a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010555e:	c7 04 24 23 d0 10 c0 	movl   $0xc010d023,(%esp)
c0105565:	e8 3f ad ff ff       	call   c01002a9 <cprintf>
          check_swap();
c010556a:	e8 a4 04 00 00       	call   c0105a13 <check_swap>
     }

     return r;
c010556f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105572:	c9                   	leave  
c0105573:	c3                   	ret    

c0105574 <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
c0105574:	55                   	push   %ebp
c0105575:	89 e5                	mov    %esp,%ebp
c0105577:	83 ec 18             	sub    $0x18,%esp
     return sm->init_mm(mm);
c010557a:	a1 74 ef 19 c0       	mov    0xc019ef74,%eax
c010557f:	8b 40 08             	mov    0x8(%eax),%eax
c0105582:	8b 55 08             	mov    0x8(%ebp),%edx
c0105585:	89 14 24             	mov    %edx,(%esp)
c0105588:	ff d0                	call   *%eax
}
c010558a:	c9                   	leave  
c010558b:	c3                   	ret    

c010558c <swap_tick_event>:

int
swap_tick_event(struct mm_struct *mm)
{
c010558c:	55                   	push   %ebp
c010558d:	89 e5                	mov    %esp,%ebp
c010558f:	83 ec 18             	sub    $0x18,%esp
     return sm->tick_event(mm);
c0105592:	a1 74 ef 19 c0       	mov    0xc019ef74,%eax
c0105597:	8b 40 0c             	mov    0xc(%eax),%eax
c010559a:	8b 55 08             	mov    0x8(%ebp),%edx
c010559d:	89 14 24             	mov    %edx,(%esp)
c01055a0:	ff d0                	call   *%eax
}
c01055a2:	c9                   	leave  
c01055a3:	c3                   	ret    

c01055a4 <swap_map_swappable>:

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c01055a4:	55                   	push   %ebp
c01055a5:	89 e5                	mov    %esp,%ebp
c01055a7:	83 ec 18             	sub    $0x18,%esp
     return sm->map_swappable(mm, addr, page, swap_in);
c01055aa:	a1 74 ef 19 c0       	mov    0xc019ef74,%eax
c01055af:	8b 40 10             	mov    0x10(%eax),%eax
c01055b2:	8b 55 14             	mov    0x14(%ebp),%edx
c01055b5:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01055b9:	8b 55 10             	mov    0x10(%ebp),%edx
c01055bc:	89 54 24 08          	mov    %edx,0x8(%esp)
c01055c0:	8b 55 0c             	mov    0xc(%ebp),%edx
c01055c3:	89 54 24 04          	mov    %edx,0x4(%esp)
c01055c7:	8b 55 08             	mov    0x8(%ebp),%edx
c01055ca:	89 14 24             	mov    %edx,(%esp)
c01055cd:	ff d0                	call   *%eax
}
c01055cf:	c9                   	leave  
c01055d0:	c3                   	ret    

c01055d1 <swap_set_unswappable>:

int
swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c01055d1:	55                   	push   %ebp
c01055d2:	89 e5                	mov    %esp,%ebp
c01055d4:	83 ec 18             	sub    $0x18,%esp
     return sm->set_unswappable(mm, addr);
c01055d7:	a1 74 ef 19 c0       	mov    0xc019ef74,%eax
c01055dc:	8b 40 14             	mov    0x14(%eax),%eax
c01055df:	8b 55 0c             	mov    0xc(%ebp),%edx
c01055e2:	89 54 24 04          	mov    %edx,0x4(%esp)
c01055e6:	8b 55 08             	mov    0x8(%ebp),%edx
c01055e9:	89 14 24             	mov    %edx,(%esp)
c01055ec:	ff d0                	call   *%eax
}
c01055ee:	c9                   	leave  
c01055ef:	c3                   	ret    

c01055f0 <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
c01055f0:	55                   	push   %ebp
c01055f1:	89 e5                	mov    %esp,%ebp
c01055f3:	83 ec 38             	sub    $0x38,%esp
     int i;
     for (i = 0; i != n; ++ i)
c01055f6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01055fd:	e9 5a 01 00 00       	jmp    c010575c <swap_out+0x16c>
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
c0105602:	a1 74 ef 19 c0       	mov    0xc019ef74,%eax
c0105607:	8b 40 18             	mov    0x18(%eax),%eax
c010560a:	8b 55 10             	mov    0x10(%ebp),%edx
c010560d:	89 54 24 08          	mov    %edx,0x8(%esp)
c0105611:	8d 55 e4             	lea    -0x1c(%ebp),%edx
c0105614:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105618:	8b 55 08             	mov    0x8(%ebp),%edx
c010561b:	89 14 24             	mov    %edx,(%esp)
c010561e:	ff d0                	call   *%eax
c0105620:	89 45 f0             	mov    %eax,-0x10(%ebp)
          if (r != 0) {
c0105623:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105627:	74 18                	je     c0105641 <swap_out+0x51>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
c0105629:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010562c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105630:	c7 04 24 38 d0 10 c0 	movl   $0xc010d038,(%esp)
c0105637:	e8 6d ac ff ff       	call   c01002a9 <cprintf>
c010563c:	e9 27 01 00 00       	jmp    c0105768 <swap_out+0x178>
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
c0105641:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105644:	8b 40 1c             	mov    0x1c(%eax),%eax
c0105647:	89 45 ec             	mov    %eax,-0x14(%ebp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
c010564a:	8b 45 08             	mov    0x8(%ebp),%eax
c010564d:	8b 40 0c             	mov    0xc(%eax),%eax
c0105650:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105657:	00 
c0105658:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010565b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010565f:	89 04 24             	mov    %eax,(%esp)
c0105662:	e8 54 25 00 00       	call   c0107bbb <get_pte>
c0105667:	89 45 e8             	mov    %eax,-0x18(%ebp)
          assert((*ptep & PTE_P) != 0);
c010566a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010566d:	8b 00                	mov    (%eax),%eax
c010566f:	83 e0 01             	and    $0x1,%eax
c0105672:	85 c0                	test   %eax,%eax
c0105674:	75 24                	jne    c010569a <swap_out+0xaa>
c0105676:	c7 44 24 0c 65 d0 10 	movl   $0xc010d065,0xc(%esp)
c010567d:	c0 
c010567e:	c7 44 24 08 7a d0 10 	movl   $0xc010d07a,0x8(%esp)
c0105685:	c0 
c0105686:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c010568d:	00 
c010568e:	c7 04 24 14 d0 10 c0 	movl   $0xc010d014,(%esp)
c0105695:	e8 66 ad ff ff       	call   c0100400 <__panic>

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
c010569a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010569d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01056a0:	8b 52 1c             	mov    0x1c(%edx),%edx
c01056a3:	c1 ea 0c             	shr    $0xc,%edx
c01056a6:	83 c2 01             	add    $0x1,%edx
c01056a9:	c1 e2 08             	shl    $0x8,%edx
c01056ac:	89 44 24 04          	mov    %eax,0x4(%esp)
c01056b0:	89 14 24             	mov    %edx,(%esp)
c01056b3:	e8 33 3b 00 00       	call   c01091eb <swapfs_write>
c01056b8:	85 c0                	test   %eax,%eax
c01056ba:	74 34                	je     c01056f0 <swap_out+0x100>
                    cprintf("SWAP: failed to save\n");
c01056bc:	c7 04 24 8f d0 10 c0 	movl   $0xc010d08f,(%esp)
c01056c3:	e8 e1 ab ff ff       	call   c01002a9 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
c01056c8:	a1 74 ef 19 c0       	mov    0xc019ef74,%eax
c01056cd:	8b 40 10             	mov    0x10(%eax),%eax
c01056d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01056d3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01056da:	00 
c01056db:	89 54 24 08          	mov    %edx,0x8(%esp)
c01056df:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01056e2:	89 54 24 04          	mov    %edx,0x4(%esp)
c01056e6:	8b 55 08             	mov    0x8(%ebp),%edx
c01056e9:	89 14 24             	mov    %edx,(%esp)
c01056ec:	ff d0                	call   *%eax
c01056ee:	eb 68                	jmp    c0105758 <swap_out+0x168>
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
c01056f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01056f3:	8b 40 1c             	mov    0x1c(%eax),%eax
c01056f6:	c1 e8 0c             	shr    $0xc,%eax
c01056f9:	83 c0 01             	add    $0x1,%eax
c01056fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105700:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105703:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105707:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010570a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010570e:	c7 04 24 a8 d0 10 c0 	movl   $0xc010d0a8,(%esp)
c0105715:	e8 8f ab ff ff       	call   c01002a9 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
c010571a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010571d:	8b 40 1c             	mov    0x1c(%eax),%eax
c0105720:	c1 e8 0c             	shr    $0xc,%eax
c0105723:	83 c0 01             	add    $0x1,%eax
c0105726:	c1 e0 08             	shl    $0x8,%eax
c0105729:	89 c2                	mov    %eax,%edx
c010572b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010572e:	89 10                	mov    %edx,(%eax)
                    free_page(page);
c0105730:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105733:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010573a:	00 
c010573b:	89 04 24             	mov    %eax,(%esp)
c010573e:	e8 ff 1d 00 00       	call   c0107542 <free_pages>
          }
          
          tlb_invalidate(mm->pgdir, v);
c0105743:	8b 45 08             	mov    0x8(%ebp),%eax
c0105746:	8b 40 0c             	mov    0xc(%eax),%eax
c0105749:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010574c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105750:	89 04 24             	mov    %eax,(%esp)
c0105753:	e8 76 2b 00 00       	call   c01082ce <tlb_invalidate>
     for (i = 0; i != n; ++ i)
c0105758:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010575c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010575f:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105762:	0f 85 9a fe ff ff    	jne    c0105602 <swap_out+0x12>
     }
     return i;
c0105768:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010576b:	c9                   	leave  
c010576c:	c3                   	ret    

c010576d <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
c010576d:	55                   	push   %ebp
c010576e:	89 e5                	mov    %esp,%ebp
c0105770:	83 ec 28             	sub    $0x28,%esp
     struct Page *result = alloc_page();
c0105773:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010577a:	e8 58 1d 00 00       	call   c01074d7 <alloc_pages>
c010577f:	89 45 f4             	mov    %eax,-0xc(%ebp)
     assert(result!=NULL);
c0105782:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105786:	75 24                	jne    c01057ac <swap_in+0x3f>
c0105788:	c7 44 24 0c e8 d0 10 	movl   $0xc010d0e8,0xc(%esp)
c010578f:	c0 
c0105790:	c7 44 24 08 7a d0 10 	movl   $0xc010d07a,0x8(%esp)
c0105797:	c0 
c0105798:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c010579f:	00 
c01057a0:	c7 04 24 14 d0 10 c0 	movl   $0xc010d014,(%esp)
c01057a7:	e8 54 ac ff ff       	call   c0100400 <__panic>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
c01057ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01057af:	8b 40 0c             	mov    0xc(%eax),%eax
c01057b2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01057b9:	00 
c01057ba:	8b 55 0c             	mov    0xc(%ebp),%edx
c01057bd:	89 54 24 04          	mov    %edx,0x4(%esp)
c01057c1:	89 04 24             	mov    %eax,(%esp)
c01057c4:	e8 f2 23 00 00       	call   c0107bbb <get_pte>
c01057c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
c01057cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01057cf:	8b 00                	mov    (%eax),%eax
c01057d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01057d4:	89 54 24 04          	mov    %edx,0x4(%esp)
c01057d8:	89 04 24             	mov    %eax,(%esp)
c01057db:	e8 99 39 00 00       	call   c0109179 <swapfs_read>
c01057e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01057e3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01057e7:	74 2a                	je     c0105813 <swap_in+0xa6>
     {
        assert(r!=0);
c01057e9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01057ed:	75 24                	jne    c0105813 <swap_in+0xa6>
c01057ef:	c7 44 24 0c f5 d0 10 	movl   $0xc010d0f5,0xc(%esp)
c01057f6:	c0 
c01057f7:	c7 44 24 08 7a d0 10 	movl   $0xc010d07a,0x8(%esp)
c01057fe:	c0 
c01057ff:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
c0105806:	00 
c0105807:	c7 04 24 14 d0 10 c0 	movl   $0xc010d014,(%esp)
c010580e:	e8 ed ab ff ff       	call   c0100400 <__panic>
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
c0105813:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105816:	8b 00                	mov    (%eax),%eax
c0105818:	c1 e8 08             	shr    $0x8,%eax
c010581b:	89 c2                	mov    %eax,%edx
c010581d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105820:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105824:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105828:	c7 04 24 fc d0 10 c0 	movl   $0xc010d0fc,(%esp)
c010582f:	e8 75 aa ff ff       	call   c01002a9 <cprintf>
     *ptr_result=result;
c0105834:	8b 45 10             	mov    0x10(%ebp),%eax
c0105837:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010583a:	89 10                	mov    %edx,(%eax)
     return 0;
c010583c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105841:	c9                   	leave  
c0105842:	c3                   	ret    

c0105843 <check_content_set>:



static inline void
check_content_set(void)
{
c0105843:	55                   	push   %ebp
c0105844:	89 e5                	mov    %esp,%ebp
c0105846:	83 ec 18             	sub    $0x18,%esp
     *(unsigned char *)0x1000 = 0x0a;
c0105849:	b8 00 10 00 00       	mov    $0x1000,%eax
c010584e:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0105851:	a1 64 ef 19 c0       	mov    0xc019ef64,%eax
c0105856:	83 f8 01             	cmp    $0x1,%eax
c0105859:	74 24                	je     c010587f <check_content_set+0x3c>
c010585b:	c7 44 24 0c 3a d1 10 	movl   $0xc010d13a,0xc(%esp)
c0105862:	c0 
c0105863:	c7 44 24 08 7a d0 10 	movl   $0xc010d07a,0x8(%esp)
c010586a:	c0 
c010586b:	c7 44 24 04 92 00 00 	movl   $0x92,0x4(%esp)
c0105872:	00 
c0105873:	c7 04 24 14 d0 10 c0 	movl   $0xc010d014,(%esp)
c010587a:	e8 81 ab ff ff       	call   c0100400 <__panic>
     *(unsigned char *)0x1010 = 0x0a;
c010587f:	b8 10 10 00 00       	mov    $0x1010,%eax
c0105884:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0105887:	a1 64 ef 19 c0       	mov    0xc019ef64,%eax
c010588c:	83 f8 01             	cmp    $0x1,%eax
c010588f:	74 24                	je     c01058b5 <check_content_set+0x72>
c0105891:	c7 44 24 0c 3a d1 10 	movl   $0xc010d13a,0xc(%esp)
c0105898:	c0 
c0105899:	c7 44 24 08 7a d0 10 	movl   $0xc010d07a,0x8(%esp)
c01058a0:	c0 
c01058a1:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c01058a8:	00 
c01058a9:	c7 04 24 14 d0 10 c0 	movl   $0xc010d014,(%esp)
c01058b0:	e8 4b ab ff ff       	call   c0100400 <__panic>
     *(unsigned char *)0x2000 = 0x0b;
c01058b5:	b8 00 20 00 00       	mov    $0x2000,%eax
c01058ba:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c01058bd:	a1 64 ef 19 c0       	mov    0xc019ef64,%eax
c01058c2:	83 f8 02             	cmp    $0x2,%eax
c01058c5:	74 24                	je     c01058eb <check_content_set+0xa8>
c01058c7:	c7 44 24 0c 49 d1 10 	movl   $0xc010d149,0xc(%esp)
c01058ce:	c0 
c01058cf:	c7 44 24 08 7a d0 10 	movl   $0xc010d07a,0x8(%esp)
c01058d6:	c0 
c01058d7:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
c01058de:	00 
c01058df:	c7 04 24 14 d0 10 c0 	movl   $0xc010d014,(%esp)
c01058e6:	e8 15 ab ff ff       	call   c0100400 <__panic>
     *(unsigned char *)0x2010 = 0x0b;
c01058eb:	b8 10 20 00 00       	mov    $0x2010,%eax
c01058f0:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c01058f3:	a1 64 ef 19 c0       	mov    0xc019ef64,%eax
c01058f8:	83 f8 02             	cmp    $0x2,%eax
c01058fb:	74 24                	je     c0105921 <check_content_set+0xde>
c01058fd:	c7 44 24 0c 49 d1 10 	movl   $0xc010d149,0xc(%esp)
c0105904:	c0 
c0105905:	c7 44 24 08 7a d0 10 	movl   $0xc010d07a,0x8(%esp)
c010590c:	c0 
c010590d:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
c0105914:	00 
c0105915:	c7 04 24 14 d0 10 c0 	movl   $0xc010d014,(%esp)
c010591c:	e8 df aa ff ff       	call   c0100400 <__panic>
     *(unsigned char *)0x3000 = 0x0c;
c0105921:	b8 00 30 00 00       	mov    $0x3000,%eax
c0105926:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0105929:	a1 64 ef 19 c0       	mov    0xc019ef64,%eax
c010592e:	83 f8 03             	cmp    $0x3,%eax
c0105931:	74 24                	je     c0105957 <check_content_set+0x114>
c0105933:	c7 44 24 0c 58 d1 10 	movl   $0xc010d158,0xc(%esp)
c010593a:	c0 
c010593b:	c7 44 24 08 7a d0 10 	movl   $0xc010d07a,0x8(%esp)
c0105942:	c0 
c0105943:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
c010594a:	00 
c010594b:	c7 04 24 14 d0 10 c0 	movl   $0xc010d014,(%esp)
c0105952:	e8 a9 aa ff ff       	call   c0100400 <__panic>
     *(unsigned char *)0x3010 = 0x0c;
c0105957:	b8 10 30 00 00       	mov    $0x3010,%eax
c010595c:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c010595f:	a1 64 ef 19 c0       	mov    0xc019ef64,%eax
c0105964:	83 f8 03             	cmp    $0x3,%eax
c0105967:	74 24                	je     c010598d <check_content_set+0x14a>
c0105969:	c7 44 24 0c 58 d1 10 	movl   $0xc010d158,0xc(%esp)
c0105970:	c0 
c0105971:	c7 44 24 08 7a d0 10 	movl   $0xc010d07a,0x8(%esp)
c0105978:	c0 
c0105979:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c0105980:	00 
c0105981:	c7 04 24 14 d0 10 c0 	movl   $0xc010d014,(%esp)
c0105988:	e8 73 aa ff ff       	call   c0100400 <__panic>
     *(unsigned char *)0x4000 = 0x0d;
c010598d:	b8 00 40 00 00       	mov    $0x4000,%eax
c0105992:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0105995:	a1 64 ef 19 c0       	mov    0xc019ef64,%eax
c010599a:	83 f8 04             	cmp    $0x4,%eax
c010599d:	74 24                	je     c01059c3 <check_content_set+0x180>
c010599f:	c7 44 24 0c 67 d1 10 	movl   $0xc010d167,0xc(%esp)
c01059a6:	c0 
c01059a7:	c7 44 24 08 7a d0 10 	movl   $0xc010d07a,0x8(%esp)
c01059ae:	c0 
c01059af:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
c01059b6:	00 
c01059b7:	c7 04 24 14 d0 10 c0 	movl   $0xc010d014,(%esp)
c01059be:	e8 3d aa ff ff       	call   c0100400 <__panic>
     *(unsigned char *)0x4010 = 0x0d;
c01059c3:	b8 10 40 00 00       	mov    $0x4010,%eax
c01059c8:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c01059cb:	a1 64 ef 19 c0       	mov    0xc019ef64,%eax
c01059d0:	83 f8 04             	cmp    $0x4,%eax
c01059d3:	74 24                	je     c01059f9 <check_content_set+0x1b6>
c01059d5:	c7 44 24 0c 67 d1 10 	movl   $0xc010d167,0xc(%esp)
c01059dc:	c0 
c01059dd:	c7 44 24 08 7a d0 10 	movl   $0xc010d07a,0x8(%esp)
c01059e4:	c0 
c01059e5:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c01059ec:	00 
c01059ed:	c7 04 24 14 d0 10 c0 	movl   $0xc010d014,(%esp)
c01059f4:	e8 07 aa ff ff       	call   c0100400 <__panic>
}
c01059f9:	c9                   	leave  
c01059fa:	c3                   	ret    

c01059fb <check_content_access>:

static inline int
check_content_access(void)
{
c01059fb:	55                   	push   %ebp
c01059fc:	89 e5                	mov    %esp,%ebp
c01059fe:	83 ec 18             	sub    $0x18,%esp
    int ret = sm->check_swap();
c0105a01:	a1 74 ef 19 c0       	mov    0xc019ef74,%eax
c0105a06:	8b 40 1c             	mov    0x1c(%eax),%eax
c0105a09:	ff d0                	call   *%eax
c0105a0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c0105a0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105a11:	c9                   	leave  
c0105a12:	c3                   	ret    

c0105a13 <check_swap>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void)
{
c0105a13:	55                   	push   %ebp
c0105a14:	89 e5                	mov    %esp,%ebp
c0105a16:	53                   	push   %ebx
c0105a17:	83 ec 74             	sub    $0x74,%esp
    //backup mem env
     int ret, count = 0, total = 0, i;
c0105a1a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105a21:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     list_entry_t *le = &free_list;
c0105a28:	c7 45 e8 44 11 1a c0 	movl   $0xc01a1144,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0105a2f:	eb 6b                	jmp    c0105a9c <check_swap+0x89>
        struct Page *p = le2page(le, page_link);
c0105a31:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105a34:	83 e8 0c             	sub    $0xc,%eax
c0105a37:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        assert(PageProperty(p));
c0105a3a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105a3d:	83 c0 04             	add    $0x4,%eax
c0105a40:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0105a47:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105a4a:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0105a4d:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0105a50:	0f a3 10             	bt     %edx,(%eax)
c0105a53:	19 c0                	sbb    %eax,%eax
c0105a55:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return oldbit != 0;
c0105a58:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0105a5c:	0f 95 c0             	setne  %al
c0105a5f:	0f b6 c0             	movzbl %al,%eax
c0105a62:	85 c0                	test   %eax,%eax
c0105a64:	75 24                	jne    c0105a8a <check_swap+0x77>
c0105a66:	c7 44 24 0c 76 d1 10 	movl   $0xc010d176,0xc(%esp)
c0105a6d:	c0 
c0105a6e:	c7 44 24 08 7a d0 10 	movl   $0xc010d07a,0x8(%esp)
c0105a75:	c0 
c0105a76:	c7 44 24 04 bb 00 00 	movl   $0xbb,0x4(%esp)
c0105a7d:	00 
c0105a7e:	c7 04 24 14 d0 10 c0 	movl   $0xc010d014,(%esp)
c0105a85:	e8 76 a9 ff ff       	call   c0100400 <__panic>
        count ++, total += p->property;
c0105a8a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0105a8e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105a91:	8b 50 08             	mov    0x8(%eax),%edx
c0105a94:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a97:	01 d0                	add    %edx,%eax
c0105a99:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105a9c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105a9f:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return listelm->next;
c0105aa2:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0105aa5:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c0105aa8:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105aab:	81 7d e8 44 11 1a c0 	cmpl   $0xc01a1144,-0x18(%ebp)
c0105ab2:	0f 85 79 ff ff ff    	jne    c0105a31 <check_swap+0x1e>
     }
     assert(total == nr_free_pages());
c0105ab8:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c0105abb:	e8 b4 1a 00 00       	call   c0107574 <nr_free_pages>
c0105ac0:	39 c3                	cmp    %eax,%ebx
c0105ac2:	74 24                	je     c0105ae8 <check_swap+0xd5>
c0105ac4:	c7 44 24 0c 86 d1 10 	movl   $0xc010d186,0xc(%esp)
c0105acb:	c0 
c0105acc:	c7 44 24 08 7a d0 10 	movl   $0xc010d07a,0x8(%esp)
c0105ad3:	c0 
c0105ad4:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
c0105adb:	00 
c0105adc:	c7 04 24 14 d0 10 c0 	movl   $0xc010d014,(%esp)
c0105ae3:	e8 18 a9 ff ff       	call   c0100400 <__panic>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
c0105ae8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105aeb:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105af2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105af6:	c7 04 24 a0 d1 10 c0 	movl   $0xc010d1a0,(%esp)
c0105afd:	e8 a7 a7 ff ff       	call   c01002a9 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
c0105b02:	e8 ce da ff ff       	call   c01035d5 <mm_create>
c0105b07:	89 45 e0             	mov    %eax,-0x20(%ebp)
     assert(mm != NULL);
c0105b0a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0105b0e:	75 24                	jne    c0105b34 <check_swap+0x121>
c0105b10:	c7 44 24 0c c6 d1 10 	movl   $0xc010d1c6,0xc(%esp)
c0105b17:	c0 
c0105b18:	c7 44 24 08 7a d0 10 	movl   $0xc010d07a,0x8(%esp)
c0105b1f:	c0 
c0105b20:	c7 44 24 04 c3 00 00 	movl   $0xc3,0x4(%esp)
c0105b27:	00 
c0105b28:	c7 04 24 14 d0 10 c0 	movl   $0xc010d014,(%esp)
c0105b2f:	e8 cc a8 ff ff       	call   c0100400 <__panic>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
c0105b34:	a1 58 10 1a c0       	mov    0xc01a1058,%eax
c0105b39:	85 c0                	test   %eax,%eax
c0105b3b:	74 24                	je     c0105b61 <check_swap+0x14e>
c0105b3d:	c7 44 24 0c d1 d1 10 	movl   $0xc010d1d1,0xc(%esp)
c0105b44:	c0 
c0105b45:	c7 44 24 08 7a d0 10 	movl   $0xc010d07a,0x8(%esp)
c0105b4c:	c0 
c0105b4d:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
c0105b54:	00 
c0105b55:	c7 04 24 14 d0 10 c0 	movl   $0xc010d014,(%esp)
c0105b5c:	e8 9f a8 ff ff       	call   c0100400 <__panic>

     check_mm_struct = mm;
c0105b61:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105b64:	a3 58 10 1a c0       	mov    %eax,0xc01a1058

     pde_t *pgdir = mm->pgdir = boot_pgdir;
c0105b69:	8b 15 20 aa 12 c0    	mov    0xc012aa20,%edx
c0105b6f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105b72:	89 50 0c             	mov    %edx,0xc(%eax)
c0105b75:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105b78:	8b 40 0c             	mov    0xc(%eax),%eax
c0105b7b:	89 45 dc             	mov    %eax,-0x24(%ebp)
     assert(pgdir[0] == 0);
c0105b7e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105b81:	8b 00                	mov    (%eax),%eax
c0105b83:	85 c0                	test   %eax,%eax
c0105b85:	74 24                	je     c0105bab <check_swap+0x198>
c0105b87:	c7 44 24 0c e9 d1 10 	movl   $0xc010d1e9,0xc(%esp)
c0105b8e:	c0 
c0105b8f:	c7 44 24 08 7a d0 10 	movl   $0xc010d07a,0x8(%esp)
c0105b96:	c0 
c0105b97:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c0105b9e:	00 
c0105b9f:	c7 04 24 14 d0 10 c0 	movl   $0xc010d014,(%esp)
c0105ba6:	e8 55 a8 ff ff       	call   c0100400 <__panic>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
c0105bab:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
c0105bb2:	00 
c0105bb3:	c7 44 24 04 00 60 00 	movl   $0x6000,0x4(%esp)
c0105bba:	00 
c0105bbb:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
c0105bc2:	e8 a7 da ff ff       	call   c010366e <vma_create>
c0105bc7:	89 45 d8             	mov    %eax,-0x28(%ebp)
     assert(vma != NULL);
c0105bca:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0105bce:	75 24                	jne    c0105bf4 <check_swap+0x1e1>
c0105bd0:	c7 44 24 0c f7 d1 10 	movl   $0xc010d1f7,0xc(%esp)
c0105bd7:	c0 
c0105bd8:	c7 44 24 08 7a d0 10 	movl   $0xc010d07a,0x8(%esp)
c0105bdf:	c0 
c0105be0:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c0105be7:	00 
c0105be8:	c7 04 24 14 d0 10 c0 	movl   $0xc010d014,(%esp)
c0105bef:	e8 0c a8 ff ff       	call   c0100400 <__panic>

     insert_vma_struct(mm, vma);
c0105bf4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105bf7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105bfb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105bfe:	89 04 24             	mov    %eax,(%esp)
c0105c01:	e8 f8 db ff ff       	call   c01037fe <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
c0105c06:	c7 04 24 04 d2 10 c0 	movl   $0xc010d204,(%esp)
c0105c0d:	e8 97 a6 ff ff       	call   c01002a9 <cprintf>
     pte_t *temp_ptep=NULL;
c0105c12:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
c0105c19:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105c1c:	8b 40 0c             	mov    0xc(%eax),%eax
c0105c1f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0105c26:	00 
c0105c27:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0105c2e:	00 
c0105c2f:	89 04 24             	mov    %eax,(%esp)
c0105c32:	e8 84 1f 00 00       	call   c0107bbb <get_pte>
c0105c37:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     assert(temp_ptep!= NULL);
c0105c3a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c0105c3e:	75 24                	jne    c0105c64 <check_swap+0x251>
c0105c40:	c7 44 24 0c 38 d2 10 	movl   $0xc010d238,0xc(%esp)
c0105c47:	c0 
c0105c48:	c7 44 24 08 7a d0 10 	movl   $0xc010d07a,0x8(%esp)
c0105c4f:	c0 
c0105c50:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c0105c57:	00 
c0105c58:	c7 04 24 14 d0 10 c0 	movl   $0xc010d014,(%esp)
c0105c5f:	e8 9c a7 ff ff       	call   c0100400 <__panic>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
c0105c64:	c7 04 24 4c d2 10 c0 	movl   $0xc010d24c,(%esp)
c0105c6b:	e8 39 a6 ff ff       	call   c01002a9 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105c70:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0105c77:	e9 a3 00 00 00       	jmp    c0105d1f <check_swap+0x30c>
          check_rp[i] = alloc_page();
c0105c7c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105c83:	e8 4f 18 00 00       	call   c01074d7 <alloc_pages>
c0105c88:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105c8b:	89 04 95 80 10 1a c0 	mov    %eax,-0x3fe5ef80(,%edx,4)
          assert(check_rp[i] != NULL );
c0105c92:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105c95:	8b 04 85 80 10 1a c0 	mov    -0x3fe5ef80(,%eax,4),%eax
c0105c9c:	85 c0                	test   %eax,%eax
c0105c9e:	75 24                	jne    c0105cc4 <check_swap+0x2b1>
c0105ca0:	c7 44 24 0c 70 d2 10 	movl   $0xc010d270,0xc(%esp)
c0105ca7:	c0 
c0105ca8:	c7 44 24 08 7a d0 10 	movl   $0xc010d07a,0x8(%esp)
c0105caf:	c0 
c0105cb0:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c0105cb7:	00 
c0105cb8:	c7 04 24 14 d0 10 c0 	movl   $0xc010d014,(%esp)
c0105cbf:	e8 3c a7 ff ff       	call   c0100400 <__panic>
          assert(!PageProperty(check_rp[i]));
c0105cc4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105cc7:	8b 04 85 80 10 1a c0 	mov    -0x3fe5ef80(,%eax,4),%eax
c0105cce:	83 c0 04             	add    $0x4,%eax
c0105cd1:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
c0105cd8:	89 45 b0             	mov    %eax,-0x50(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105cdb:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0105cde:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0105ce1:	0f a3 10             	bt     %edx,(%eax)
c0105ce4:	19 c0                	sbb    %eax,%eax
c0105ce6:	89 45 ac             	mov    %eax,-0x54(%ebp)
    return oldbit != 0;
c0105ce9:	83 7d ac 00          	cmpl   $0x0,-0x54(%ebp)
c0105ced:	0f 95 c0             	setne  %al
c0105cf0:	0f b6 c0             	movzbl %al,%eax
c0105cf3:	85 c0                	test   %eax,%eax
c0105cf5:	74 24                	je     c0105d1b <check_swap+0x308>
c0105cf7:	c7 44 24 0c 84 d2 10 	movl   $0xc010d284,0xc(%esp)
c0105cfe:	c0 
c0105cff:	c7 44 24 08 7a d0 10 	movl   $0xc010d07a,0x8(%esp)
c0105d06:	c0 
c0105d07:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c0105d0e:	00 
c0105d0f:	c7 04 24 14 d0 10 c0 	movl   $0xc010d014,(%esp)
c0105d16:	e8 e5 a6 ff ff       	call   c0100400 <__panic>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105d1b:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0105d1f:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0105d23:	0f 8e 53 ff ff ff    	jle    c0105c7c <check_swap+0x269>
     }
     list_entry_t free_list_store = free_list;
c0105d29:	a1 44 11 1a c0       	mov    0xc01a1144,%eax
c0105d2e:	8b 15 48 11 1a c0    	mov    0xc01a1148,%edx
c0105d34:	89 45 98             	mov    %eax,-0x68(%ebp)
c0105d37:	89 55 9c             	mov    %edx,-0x64(%ebp)
c0105d3a:	c7 45 a8 44 11 1a c0 	movl   $0xc01a1144,-0x58(%ebp)
    elm->prev = elm->next = elm;
c0105d41:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0105d44:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0105d47:	89 50 04             	mov    %edx,0x4(%eax)
c0105d4a:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0105d4d:	8b 50 04             	mov    0x4(%eax),%edx
c0105d50:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0105d53:	89 10                	mov    %edx,(%eax)
c0105d55:	c7 45 a4 44 11 1a c0 	movl   $0xc01a1144,-0x5c(%ebp)
    return list->next == list;
c0105d5c:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0105d5f:	8b 40 04             	mov    0x4(%eax),%eax
c0105d62:	39 45 a4             	cmp    %eax,-0x5c(%ebp)
c0105d65:	0f 94 c0             	sete   %al
c0105d68:	0f b6 c0             	movzbl %al,%eax
     list_init(&free_list);
     assert(list_empty(&free_list));
c0105d6b:	85 c0                	test   %eax,%eax
c0105d6d:	75 24                	jne    c0105d93 <check_swap+0x380>
c0105d6f:	c7 44 24 0c 9f d2 10 	movl   $0xc010d29f,0xc(%esp)
c0105d76:	c0 
c0105d77:	c7 44 24 08 7a d0 10 	movl   $0xc010d07a,0x8(%esp)
c0105d7e:	c0 
c0105d7f:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
c0105d86:	00 
c0105d87:	c7 04 24 14 d0 10 c0 	movl   $0xc010d014,(%esp)
c0105d8e:	e8 6d a6 ff ff       	call   c0100400 <__panic>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
c0105d93:	a1 4c 11 1a c0       	mov    0xc01a114c,%eax
c0105d98:	89 45 d0             	mov    %eax,-0x30(%ebp)
     nr_free = 0;
c0105d9b:	c7 05 4c 11 1a c0 00 	movl   $0x0,0xc01a114c
c0105da2:	00 00 00 
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105da5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0105dac:	eb 1e                	jmp    c0105dcc <check_swap+0x3b9>
        free_pages(check_rp[i],1);
c0105dae:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105db1:	8b 04 85 80 10 1a c0 	mov    -0x3fe5ef80(,%eax,4),%eax
c0105db8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105dbf:	00 
c0105dc0:	89 04 24             	mov    %eax,(%esp)
c0105dc3:	e8 7a 17 00 00       	call   c0107542 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105dc8:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0105dcc:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0105dd0:	7e dc                	jle    c0105dae <check_swap+0x39b>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
c0105dd2:	a1 4c 11 1a c0       	mov    0xc01a114c,%eax
c0105dd7:	83 f8 04             	cmp    $0x4,%eax
c0105dda:	74 24                	je     c0105e00 <check_swap+0x3ed>
c0105ddc:	c7 44 24 0c b8 d2 10 	movl   $0xc010d2b8,0xc(%esp)
c0105de3:	c0 
c0105de4:	c7 44 24 08 7a d0 10 	movl   $0xc010d07a,0x8(%esp)
c0105deb:	c0 
c0105dec:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c0105df3:	00 
c0105df4:	c7 04 24 14 d0 10 c0 	movl   $0xc010d014,(%esp)
c0105dfb:	e8 00 a6 ff ff       	call   c0100400 <__panic>
     
     cprintf("set up init env for check_swap begin!\n");
c0105e00:	c7 04 24 dc d2 10 c0 	movl   $0xc010d2dc,(%esp)
c0105e07:	e8 9d a4 ff ff       	call   c01002a9 <cprintf>
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
c0105e0c:	c7 05 64 ef 19 c0 00 	movl   $0x0,0xc019ef64
c0105e13:	00 00 00 
     
     check_content_set();
c0105e16:	e8 28 fa ff ff       	call   c0105843 <check_content_set>
     assert( nr_free == 0);         
c0105e1b:	a1 4c 11 1a c0       	mov    0xc01a114c,%eax
c0105e20:	85 c0                	test   %eax,%eax
c0105e22:	74 24                	je     c0105e48 <check_swap+0x435>
c0105e24:	c7 44 24 0c 03 d3 10 	movl   $0xc010d303,0xc(%esp)
c0105e2b:	c0 
c0105e2c:	c7 44 24 08 7a d0 10 	movl   $0xc010d07a,0x8(%esp)
c0105e33:	c0 
c0105e34:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
c0105e3b:	00 
c0105e3c:	c7 04 24 14 d0 10 c0 	movl   $0xc010d014,(%esp)
c0105e43:	e8 b8 a5 ff ff       	call   c0100400 <__panic>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0105e48:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0105e4f:	eb 26                	jmp    c0105e77 <check_swap+0x464>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
c0105e51:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105e54:	c7 04 85 a0 10 1a c0 	movl   $0xffffffff,-0x3fe5ef60(,%eax,4)
c0105e5b:	ff ff ff ff 
c0105e5f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105e62:	8b 14 85 a0 10 1a c0 	mov    -0x3fe5ef60(,%eax,4),%edx
c0105e69:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105e6c:	89 14 85 e0 10 1a c0 	mov    %edx,-0x3fe5ef20(,%eax,4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0105e73:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0105e77:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
c0105e7b:	7e d4                	jle    c0105e51 <check_swap+0x43e>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105e7d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0105e84:	e9 eb 00 00 00       	jmp    c0105f74 <check_swap+0x561>
         check_ptep[i]=0;
c0105e89:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105e8c:	c7 04 85 34 11 1a c0 	movl   $0x0,-0x3fe5eecc(,%eax,4)
c0105e93:	00 00 00 00 
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
c0105e97:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105e9a:	83 c0 01             	add    $0x1,%eax
c0105e9d:	c1 e0 0c             	shl    $0xc,%eax
c0105ea0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105ea7:	00 
c0105ea8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105eac:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105eaf:	89 04 24             	mov    %eax,(%esp)
c0105eb2:	e8 04 1d 00 00       	call   c0107bbb <get_pte>
c0105eb7:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105eba:	89 04 95 34 11 1a c0 	mov    %eax,-0x3fe5eecc(,%edx,4)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
c0105ec1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105ec4:	8b 04 85 34 11 1a c0 	mov    -0x3fe5eecc(,%eax,4),%eax
c0105ecb:	85 c0                	test   %eax,%eax
c0105ecd:	75 24                	jne    c0105ef3 <check_swap+0x4e0>
c0105ecf:	c7 44 24 0c 10 d3 10 	movl   $0xc010d310,0xc(%esp)
c0105ed6:	c0 
c0105ed7:	c7 44 24 08 7a d0 10 	movl   $0xc010d07a,0x8(%esp)
c0105ede:	c0 
c0105edf:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c0105ee6:	00 
c0105ee7:	c7 04 24 14 d0 10 c0 	movl   $0xc010d014,(%esp)
c0105eee:	e8 0d a5 ff ff       	call   c0100400 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
c0105ef3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105ef6:	8b 04 85 34 11 1a c0 	mov    -0x3fe5eecc(,%eax,4),%eax
c0105efd:	8b 00                	mov    (%eax),%eax
c0105eff:	89 04 24             	mov    %eax,(%esp)
c0105f02:	e8 87 f5 ff ff       	call   c010548e <pte2page>
c0105f07:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105f0a:	8b 14 95 80 10 1a c0 	mov    -0x3fe5ef80(,%edx,4),%edx
c0105f11:	39 d0                	cmp    %edx,%eax
c0105f13:	74 24                	je     c0105f39 <check_swap+0x526>
c0105f15:	c7 44 24 0c 28 d3 10 	movl   $0xc010d328,0xc(%esp)
c0105f1c:	c0 
c0105f1d:	c7 44 24 08 7a d0 10 	movl   $0xc010d07a,0x8(%esp)
c0105f24:	c0 
c0105f25:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c0105f2c:	00 
c0105f2d:	c7 04 24 14 d0 10 c0 	movl   $0xc010d014,(%esp)
c0105f34:	e8 c7 a4 ff ff       	call   c0100400 <__panic>
         assert((*check_ptep[i] & PTE_P));          
c0105f39:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105f3c:	8b 04 85 34 11 1a c0 	mov    -0x3fe5eecc(,%eax,4),%eax
c0105f43:	8b 00                	mov    (%eax),%eax
c0105f45:	83 e0 01             	and    $0x1,%eax
c0105f48:	85 c0                	test   %eax,%eax
c0105f4a:	75 24                	jne    c0105f70 <check_swap+0x55d>
c0105f4c:	c7 44 24 0c 50 d3 10 	movl   $0xc010d350,0xc(%esp)
c0105f53:	c0 
c0105f54:	c7 44 24 08 7a d0 10 	movl   $0xc010d07a,0x8(%esp)
c0105f5b:	c0 
c0105f5c:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c0105f63:	00 
c0105f64:	c7 04 24 14 d0 10 c0 	movl   $0xc010d014,(%esp)
c0105f6b:	e8 90 a4 ff ff       	call   c0100400 <__panic>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105f70:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0105f74:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0105f78:	0f 8e 0b ff ff ff    	jle    c0105e89 <check_swap+0x476>
     }
     cprintf("set up init env for check_swap over!\n");
c0105f7e:	c7 04 24 6c d3 10 c0 	movl   $0xc010d36c,(%esp)
c0105f85:	e8 1f a3 ff ff       	call   c01002a9 <cprintf>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
c0105f8a:	e8 6c fa ff ff       	call   c01059fb <check_content_access>
c0105f8f:	89 45 cc             	mov    %eax,-0x34(%ebp)
     assert(ret==0);
c0105f92:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0105f96:	74 24                	je     c0105fbc <check_swap+0x5a9>
c0105f98:	c7 44 24 0c 92 d3 10 	movl   $0xc010d392,0xc(%esp)
c0105f9f:	c0 
c0105fa0:	c7 44 24 08 7a d0 10 	movl   $0xc010d07a,0x8(%esp)
c0105fa7:	c0 
c0105fa8:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c0105faf:	00 
c0105fb0:	c7 04 24 14 d0 10 c0 	movl   $0xc010d014,(%esp)
c0105fb7:	e8 44 a4 ff ff       	call   c0100400 <__panic>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105fbc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0105fc3:	eb 1e                	jmp    c0105fe3 <check_swap+0x5d0>
         free_pages(check_rp[i],1);
c0105fc5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105fc8:	8b 04 85 80 10 1a c0 	mov    -0x3fe5ef80(,%eax,4),%eax
c0105fcf:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105fd6:	00 
c0105fd7:	89 04 24             	mov    %eax,(%esp)
c0105fda:	e8 63 15 00 00       	call   c0107542 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105fdf:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0105fe3:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0105fe7:	7e dc                	jle    c0105fc5 <check_swap+0x5b2>
     } 

     //free_page(pte2page(*temp_ptep));
    free_page(pde2page(pgdir[0]));
c0105fe9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105fec:	8b 00                	mov    (%eax),%eax
c0105fee:	89 04 24             	mov    %eax,(%esp)
c0105ff1:	e8 d6 f4 ff ff       	call   c01054cc <pde2page>
c0105ff6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105ffd:	00 
c0105ffe:	89 04 24             	mov    %eax,(%esp)
c0106001:	e8 3c 15 00 00       	call   c0107542 <free_pages>
     pgdir[0] = 0;
c0106006:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106009:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
     mm->pgdir = NULL;
c010600f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106012:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
     mm_destroy(mm);
c0106019:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010601c:	89 04 24             	mov    %eax,(%esp)
c010601f:	e8 0a d9 ff ff       	call   c010392e <mm_destroy>
     check_mm_struct = NULL;
c0106024:	c7 05 58 10 1a c0 00 	movl   $0x0,0xc01a1058
c010602b:	00 00 00 
     
     nr_free = nr_free_store;
c010602e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106031:	a3 4c 11 1a c0       	mov    %eax,0xc01a114c
     free_list = free_list_store;
c0106036:	8b 45 98             	mov    -0x68(%ebp),%eax
c0106039:	8b 55 9c             	mov    -0x64(%ebp),%edx
c010603c:	a3 44 11 1a c0       	mov    %eax,0xc01a1144
c0106041:	89 15 48 11 1a c0    	mov    %edx,0xc01a1148

     
     le = &free_list;
c0106047:	c7 45 e8 44 11 1a c0 	movl   $0xc01a1144,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c010604e:	eb 1d                	jmp    c010606d <check_swap+0x65a>
         struct Page *p = le2page(le, page_link);
c0106050:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106053:	83 e8 0c             	sub    $0xc,%eax
c0106056:	89 45 c8             	mov    %eax,-0x38(%ebp)
         count --, total -= p->property;
c0106059:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c010605d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0106060:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106063:	8b 40 08             	mov    0x8(%eax),%eax
c0106066:	29 c2                	sub    %eax,%edx
c0106068:	89 d0                	mov    %edx,%eax
c010606a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010606d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106070:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return listelm->next;
c0106073:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0106076:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c0106079:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010607c:	81 7d e8 44 11 1a c0 	cmpl   $0xc01a1144,-0x18(%ebp)
c0106083:	75 cb                	jne    c0106050 <check_swap+0x63d>
     }
     cprintf("count is %d, total is %d\n",count,total);
c0106085:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106088:	89 44 24 08          	mov    %eax,0x8(%esp)
c010608c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010608f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106093:	c7 04 24 99 d3 10 c0 	movl   $0xc010d399,(%esp)
c010609a:	e8 0a a2 ff ff       	call   c01002a9 <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
c010609f:	c7 04 24 b3 d3 10 c0 	movl   $0xc010d3b3,(%esp)
c01060a6:	e8 fe a1 ff ff       	call   c01002a9 <cprintf>
}
c01060ab:	83 c4 74             	add    $0x74,%esp
c01060ae:	5b                   	pop    %ebx
c01060af:	5d                   	pop    %ebp
c01060b0:	c3                   	ret    

c01060b1 <page2ppn>:
page2ppn(struct Page *page) {
c01060b1:	55                   	push   %ebp
c01060b2:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01060b4:	8b 55 08             	mov    0x8(%ebp),%edx
c01060b7:	a1 58 11 1a c0       	mov    0xc01a1158,%eax
c01060bc:	29 c2                	sub    %eax,%edx
c01060be:	89 d0                	mov    %edx,%eax
c01060c0:	c1 f8 05             	sar    $0x5,%eax
}
c01060c3:	5d                   	pop    %ebp
c01060c4:	c3                   	ret    

c01060c5 <page2pa>:
page2pa(struct Page *page) {
c01060c5:	55                   	push   %ebp
c01060c6:	89 e5                	mov    %esp,%ebp
c01060c8:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01060cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01060ce:	89 04 24             	mov    %eax,(%esp)
c01060d1:	e8 db ff ff ff       	call   c01060b1 <page2ppn>
c01060d6:	c1 e0 0c             	shl    $0xc,%eax
}
c01060d9:	c9                   	leave  
c01060da:	c3                   	ret    

c01060db <page_ref>:

static inline int
page_ref(struct Page *page) {
c01060db:	55                   	push   %ebp
c01060dc:	89 e5                	mov    %esp,%ebp
    return page->ref;
c01060de:	8b 45 08             	mov    0x8(%ebp),%eax
c01060e1:	8b 00                	mov    (%eax),%eax
}
c01060e3:	5d                   	pop    %ebp
c01060e4:	c3                   	ret    

c01060e5 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c01060e5:	55                   	push   %ebp
c01060e6:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c01060e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01060eb:	8b 55 0c             	mov    0xc(%ebp),%edx
c01060ee:	89 10                	mov    %edx,(%eax)
}
c01060f0:	5d                   	pop    %ebp
c01060f1:	c3                   	ret    

c01060f2 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c01060f2:	55                   	push   %ebp
c01060f3:	89 e5                	mov    %esp,%ebp
c01060f5:	83 ec 10             	sub    $0x10,%esp
c01060f8:	c7 45 fc 44 11 1a c0 	movl   $0xc01a1144,-0x4(%ebp)
    elm->prev = elm->next = elm;
c01060ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106102:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0106105:	89 50 04             	mov    %edx,0x4(%eax)
c0106108:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010610b:	8b 50 04             	mov    0x4(%eax),%edx
c010610e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106111:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c0106113:	c7 05 4c 11 1a c0 00 	movl   $0x0,0xc01a114c
c010611a:	00 00 00 
}
c010611d:	c9                   	leave  
c010611e:	c3                   	ret    

c010611f <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c010611f:	55                   	push   %ebp
c0106120:	89 e5                	mov    %esp,%ebp
c0106122:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c0106125:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0106129:	75 24                	jne    c010614f <default_init_memmap+0x30>
c010612b:	c7 44 24 0c cc d3 10 	movl   $0xc010d3cc,0xc(%esp)
c0106132:	c0 
c0106133:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c010613a:	c0 
c010613b:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0106142:	00 
c0106143:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c010614a:	e8 b1 a2 ff ff       	call   c0100400 <__panic>
    struct Page *p = base;
c010614f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106152:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0106155:	e9 dc 00 00 00       	jmp    c0106236 <default_init_memmap+0x117>
        //初始化n块物理页
        assert(PageReserved(p));
c010615a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010615d:	83 c0 04             	add    $0x4,%eax
c0106160:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0106167:	89 45 ec             	mov    %eax,-0x14(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010616a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010616d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0106170:	0f a3 10             	bt     %edx,(%eax)
c0106173:	19 c0                	sbb    %eax,%eax
c0106175:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c0106178:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010617c:	0f 95 c0             	setne  %al
c010617f:	0f b6 c0             	movzbl %al,%eax
c0106182:	85 c0                	test   %eax,%eax
c0106184:	75 24                	jne    c01061aa <default_init_memmap+0x8b>
c0106186:	c7 44 24 0c fd d3 10 	movl   $0xc010d3fd,0xc(%esp)
c010618d:	c0 
c010618e:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c0106195:	c0 
c0106196:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
c010619d:	00 
c010619e:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c01061a5:	e8 56 a2 ff ff       	call   c0100400 <__panic>
        p->flags = 0;
c01061aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01061ad:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        SetPageProperty(p);
c01061b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01061b7:	83 c0 04             	add    $0x4,%eax
c01061ba:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c01061c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01061c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01061c7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01061ca:	0f ab 10             	bts    %edx,(%eax)
        p->property = 0;
c01061cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01061d0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        set_page_ref(p, 0);
c01061d7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01061de:	00 
c01061df:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01061e2:	89 04 24             	mov    %eax,(%esp)
c01061e5:	e8 fb fe ff ff       	call   c01060e5 <set_page_ref>
        list_add_before(&free_list, &(p->page_link));
c01061ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01061ed:	83 c0 0c             	add    $0xc,%eax
c01061f0:	c7 45 dc 44 11 1a c0 	movl   $0xc01a1144,-0x24(%ebp)
c01061f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
    __list_add(elm, listelm->prev, listelm);
c01061fa:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01061fd:	8b 00                	mov    (%eax),%eax
c01061ff:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0106202:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0106205:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0106208:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010620b:	89 45 cc             	mov    %eax,-0x34(%ebp)
    prev->next = next->prev = elm;
c010620e:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0106211:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106214:	89 10                	mov    %edx,(%eax)
c0106216:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0106219:	8b 10                	mov    (%eax),%edx
c010621b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010621e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0106221:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106224:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0106227:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010622a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010622d:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0106230:	89 10                	mov    %edx,(%eax)
    for (; p != base + n; p ++) {
c0106232:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c0106236:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106239:	c1 e0 05             	shl    $0x5,%eax
c010623c:	89 c2                	mov    %eax,%edx
c010623e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106241:	01 d0                	add    %edx,%eax
c0106243:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0106246:	0f 85 0e ff ff ff    	jne    c010615a <default_init_memmap+0x3b>
    }
    nr_free += n;
c010624c:	8b 15 4c 11 1a c0    	mov    0xc01a114c,%edx
c0106252:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106255:	01 d0                	add    %edx,%eax
c0106257:	a3 4c 11 1a c0       	mov    %eax,0xc01a114c
    base->property = n;
c010625c:	8b 45 08             	mov    0x8(%ebp),%eax
c010625f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106262:	89 50 08             	mov    %edx,0x8(%eax)
}
c0106265:	c9                   	leave  
c0106266:	c3                   	ret    

c0106267 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c0106267:	55                   	push   %ebp
c0106268:	89 e5                	mov    %esp,%ebp
c010626a:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c010626d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0106271:	75 24                	jne    c0106297 <default_alloc_pages+0x30>
c0106273:	c7 44 24 0c cc d3 10 	movl   $0xc010d3cc,0xc(%esp)
c010627a:	c0 
c010627b:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c0106282:	c0 
c0106283:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
c010628a:	00 
c010628b:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c0106292:	e8 69 a1 ff ff       	call   c0100400 <__panic>
    if (n > nr_free) {
c0106297:	a1 4c 11 1a c0       	mov    0xc01a114c,%eax
c010629c:	3b 45 08             	cmp    0x8(%ebp),%eax
c010629f:	73 0a                	jae    c01062ab <default_alloc_pages+0x44>
        return NULL;
c01062a1:	b8 00 00 00 00       	mov    $0x0,%eax
c01062a6:	e9 37 01 00 00       	jmp    c01063e2 <default_alloc_pages+0x17b>
    }
    //如果所有空闲块的空闲页总数都没有n个,直接return null
    list_entry_t *le, *le_next;  //free_list指针和它的下一个
    le = &free_list;
c01062ab:	c7 45 f4 44 11 1a c0 	movl   $0xc01a1144,-0xc(%ebp)
    //从头开始遍历保存空闲物理内存块的链表(按照物理地址的从小到大顺序)
    while((le=list_next(le)) != &free_list) {
c01062b2:	e9 0a 01 00 00       	jmp    c01063c1 <default_alloc_pages+0x15a>
    //通过宏le2page(memlayout.h)得指向Page的指针p
      struct Page *p = le2page(le, page_link);
c01062b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01062ba:	83 e8 0c             	sub    $0xc,%eax
c01062bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(p->property >= n){
c01062c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01062c3:	8b 40 08             	mov    0x8(%eax),%eax
c01062c6:	3b 45 08             	cmp    0x8(%ebp),%eax
c01062c9:	0f 82 f2 00 00 00    	jb     c01063c1 <default_alloc_pages+0x15a>
        //p->property表示空闲块的大小，大于n则进下一步
        int i;
        //for初始化空闲块中每一个页
        for(i=0;i<n;i++){
c01062cf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c01062d6:	eb 7c                	jmp    c0106354 <default_alloc_pages+0xed>
c01062d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01062db:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
c01062de:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01062e1:	8b 40 04             	mov    0x4(%eax),%eax
          le_next = list_next(le);
c01062e4:	89 45 e8             	mov    %eax,-0x18(%ebp)
          struct Page *p2 = le2page(le, page_link);
c01062e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01062ea:	83 e8 0c             	sub    $0xc,%eax
c01062ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
          SetPageReserved(p2);//flags bit0 置1，表示已经被分配
c01062f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01062f3:	83 c0 04             	add    $0x4,%eax
c01062f6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01062fd:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0106300:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106303:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106306:	0f ab 10             	bts    %edx,(%eax)
          ClearPageProperty(p2);//falgs bit1 置0，表示已被分配
c0106309:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010630c:	83 c0 04             	add    $0x4,%eax
c010630f:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0106316:	89 45 d0             	mov    %eax,-0x30(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0106319:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010631c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010631f:	0f b3 10             	btr    %edx,(%eax)
c0106322:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106325:	89 45 cc             	mov    %eax,-0x34(%ebp)
    __list_del(listelm->prev, listelm->next);
c0106328:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010632b:	8b 40 04             	mov    0x4(%eax),%eax
c010632e:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0106331:	8b 12                	mov    (%edx),%edx
c0106333:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0106336:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    prev->next = next;
c0106339:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010633c:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c010633f:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0106342:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0106345:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0106348:	89 10                	mov    %edx,(%eax)
          list_del(le);//取消和free_list的link
          le = le_next;//指针后移
c010634a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010634d:	89 45 f4             	mov    %eax,-0xc(%ebp)
        for(i=0;i<n;i++){
c0106350:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
c0106354:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106357:	3b 45 08             	cmp    0x8(%ebp),%eax
c010635a:	0f 82 78 ff ff ff    	jb     c01062d8 <default_alloc_pages+0x71>
        }
        //如果选中的块大于n,需要修改剩下的块的head page的property
        if(p->property>n){
c0106360:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106363:	8b 40 08             	mov    0x8(%eax),%eax
c0106366:	3b 45 08             	cmp    0x8(%ebp),%eax
c0106369:	76 12                	jbe    c010637d <default_alloc_pages+0x116>
          (le2page(le,page_link))->property = p->property - n;
c010636b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010636e:	8d 50 f4             	lea    -0xc(%eax),%edx
c0106371:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106374:	8b 40 08             	mov    0x8(%eax),%eax
c0106377:	2b 45 08             	sub    0x8(%ebp),%eax
c010637a:	89 42 08             	mov    %eax,0x8(%edx)
        }
        ClearPageProperty(p);
c010637d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106380:	83 c0 04             	add    $0x4,%eax
c0106383:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c010638a:	89 45 bc             	mov    %eax,-0x44(%ebp)
c010638d:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0106390:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0106393:	0f b3 10             	btr    %edx,(%eax)
        SetPageReserved(p);
c0106396:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106399:	83 c0 04             	add    $0x4,%eax
c010639c:	c7 45 b8 00 00 00 00 	movl   $0x0,-0x48(%ebp)
c01063a3:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01063a6:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01063a9:	8b 55 b8             	mov    -0x48(%ebp),%edx
c01063ac:	0f ab 10             	bts    %edx,(%eax)
        nr_free -= n;
c01063af:	a1 4c 11 1a c0       	mov    0xc01a114c,%eax
c01063b4:	2b 45 08             	sub    0x8(%ebp),%eax
c01063b7:	a3 4c 11 1a c0       	mov    %eax,0xc01a114c
        return p;
c01063bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01063bf:	eb 21                	jmp    c01063e2 <default_alloc_pages+0x17b>
c01063c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01063c4:	89 45 b0             	mov    %eax,-0x50(%ebp)
    return listelm->next;
c01063c7:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01063ca:	8b 40 04             	mov    0x4(%eax),%eax
    while((le=list_next(le)) != &free_list) {
c01063cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01063d0:	81 7d f4 44 11 1a c0 	cmpl   $0xc01a1144,-0xc(%ebp)
c01063d7:	0f 85 da fe ff ff    	jne    c01062b7 <default_alloc_pages+0x50>
      }
    }
    return NULL;//防止出错
c01063dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01063e2:	c9                   	leave  
c01063e3:	c3                   	ret    

c01063e4 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c01063e4:	55                   	push   %ebp
c01063e5:	89 e5                	mov    %esp,%ebp
c01063e7:	83 ec 68             	sub    $0x68,%esp
     assert(n > 0);
c01063ea:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01063ee:	75 24                	jne    c0106414 <default_free_pages+0x30>
c01063f0:	c7 44 24 0c cc d3 10 	movl   $0xc010d3cc,0xc(%esp)
c01063f7:	c0 
c01063f8:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c01063ff:	c0 
c0106400:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
c0106407:	00 
c0106408:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c010640f:	e8 ec 9f ff ff       	call   c0100400 <__panic>
    //assert(PageReserved(base) && PageProperty(base));
    assert(PageReserved(base));
c0106414:	8b 45 08             	mov    0x8(%ebp),%eax
c0106417:	83 c0 04             	add    $0x4,%eax
c010641a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106421:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106424:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106427:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010642a:	0f a3 10             	bt     %edx,(%eax)
c010642d:	19 c0                	sbb    %eax,%eax
c010642f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c0106432:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106436:	0f 95 c0             	setne  %al
c0106439:	0f b6 c0             	movzbl %al,%eax
c010643c:	85 c0                	test   %eax,%eax
c010643e:	75 24                	jne    c0106464 <default_free_pages+0x80>
c0106440:	c7 44 24 0c 0d d4 10 	movl   $0xc010d40d,0xc(%esp)
c0106447:	c0 
c0106448:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c010644f:	c0 
c0106450:	c7 44 24 04 a6 00 00 	movl   $0xa6,0x4(%esp)
c0106457:	00 
c0106458:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c010645f:	e8 9c 9f ff ff       	call   c0100400 <__panic>
    //检查需要释放的页块是否已经被分配,只要看bit 0 reserve就好了
    list_entry_t *le = &free_list;
c0106464:	c7 45 f4 44 11 1a c0 	movl   $0xc01a1144,-0xc(%ebp)
    struct Page * p;
    while((le=list_next(le)) != &free_list) {
c010646b:	eb 13                	jmp    c0106480 <default_free_pages+0x9c>
      p = le2page(le, page_link);
c010646d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106470:	83 e8 0c             	sub    $0xc,%eax
c0106473:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(p>base){break;}
c0106476:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106479:	3b 45 08             	cmp    0x8(%ebp),%eax
c010647c:	76 02                	jbe    c0106480 <default_free_pages+0x9c>
c010647e:	eb 18                	jmp    c0106498 <default_free_pages+0xb4>
c0106480:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106483:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106486:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106489:	8b 40 04             	mov    0x4(%eax),%eax
    while((le=list_next(le)) != &free_list) {
c010648c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010648f:	81 7d f4 44 11 1a c0 	cmpl   $0xc01a1144,-0xc(%ebp)
c0106496:	75 d5                	jne    c010646d <default_free_pages+0x89>
    }
    //将每一空闲块的链表插入空闲链表中
    for(p=base;p<base+n;p++){
c0106498:	8b 45 08             	mov    0x8(%ebp),%eax
c010649b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010649e:	eb 4b                	jmp    c01064eb <default_free_pages+0x107>
      list_add_before(le, &(p->page_link));
c01064a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01064a3:	8d 50 0c             	lea    0xc(%eax),%edx
c01064a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01064a9:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01064ac:	89 55 d8             	mov    %edx,-0x28(%ebp)
    __list_add(elm, listelm->prev, listelm);
c01064af:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01064b2:	8b 00                	mov    (%eax),%eax
c01064b4:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01064b7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01064ba:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01064bd:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01064c0:	89 45 cc             	mov    %eax,-0x34(%ebp)
    prev->next = next->prev = elm;
c01064c3:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01064c6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01064c9:	89 10                	mov    %edx,(%eax)
c01064cb:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01064ce:	8b 10                	mov    (%eax),%edx
c01064d0:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01064d3:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01064d6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01064d9:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01064dc:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01064df:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01064e2:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01064e5:	89 10                	mov    %edx,(%eax)
    for(p=base;p<base+n;p++){
c01064e7:	83 45 f0 20          	addl   $0x20,-0x10(%ebp)
c01064eb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01064ee:	c1 e0 05             	shl    $0x5,%eax
c01064f1:	89 c2                	mov    %eax,%edx
c01064f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01064f6:	01 d0                	add    %edx,%eax
c01064f8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01064fb:	77 a3                	ja     c01064a0 <default_free_pages+0xbc>
    }
    //修改页的各个属性置0
    base->flags = 0;
c01064fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0106500:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    set_page_ref(base, 0);
c0106507:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010650e:	00 
c010650f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106512:	89 04 24             	mov    %eax,(%esp)
c0106515:	e8 cb fb ff ff       	call   c01060e5 <set_page_ref>
    ClearPageProperty(base);
c010651a:	8b 45 08             	mov    0x8(%ebp),%eax
c010651d:	83 c0 04             	add    $0x4,%eax
c0106520:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c0106527:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010652a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010652d:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0106530:	0f b3 10             	btr    %edx,(%eax)
    SetPageProperty(base);
c0106533:	8b 45 08             	mov    0x8(%ebp),%eax
c0106536:	83 c0 04             	add    $0x4,%eax
c0106539:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0106540:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0106543:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0106546:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0106549:	0f ab 10             	bts    %edx,(%eax)
    base->property = n;//有n空闲页
c010654c:	8b 45 08             	mov    0x8(%ebp),%eax
c010654f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106552:	89 50 08             	mov    %edx,0x8(%eax)
    p = le2page(le,page_link) ;
c0106555:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106558:	83 e8 0c             	sub    $0xc,%eax
c010655b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    //和高位方向的下一个内存块的地址连续，向高位合并
    if( base+n == p ){
c010655e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106561:	c1 e0 05             	shl    $0x5,%eax
c0106564:	89 c2                	mov    %eax,%edx
c0106566:	8b 45 08             	mov    0x8(%ebp),%eax
c0106569:	01 d0                	add    %edx,%eax
c010656b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010656e:	75 1e                	jne    c010658e <default_free_pages+0x1aa>
      base->property += p->property;
c0106570:	8b 45 08             	mov    0x8(%ebp),%eax
c0106573:	8b 50 08             	mov    0x8(%eax),%edx
c0106576:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106579:	8b 40 08             	mov    0x8(%eax),%eax
c010657c:	01 c2                	add    %eax,%edx
c010657e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106581:	89 50 08             	mov    %edx,0x8(%eax)
      p->property = 0;
c0106584:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106587:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    }
    //如果是低位,向低地址合并
    //把le指针指向前一个内存块
    le = list_prev(&(base->page_link));  //previous
c010658e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106591:	83 c0 0c             	add    $0xc,%eax
c0106594:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return listelm->prev;
c0106597:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010659a:	8b 00                	mov    (%eax),%eax
c010659c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    p = le2page(le, page_link);
c010659f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01065a2:	83 e8 0c             	sub    $0xc,%eax
c01065a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(le!=&free_list && p==base-1){
c01065a8:	81 7d f4 44 11 1a c0 	cmpl   $0xc01a1144,-0xc(%ebp)
c01065af:	74 57                	je     c0106608 <default_free_pages+0x224>
c01065b1:	8b 45 08             	mov    0x8(%ebp),%eax
c01065b4:	83 e8 20             	sub    $0x20,%eax
c01065b7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01065ba:	75 4c                	jne    c0106608 <default_free_pages+0x224>
      while(le!=&free_list){
c01065bc:	eb 41                	jmp    c01065ff <default_free_pages+0x21b>
        if(p->property){
c01065be:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01065c1:	8b 40 08             	mov    0x8(%eax),%eax
c01065c4:	85 c0                	test   %eax,%eax
c01065c6:	74 20                	je     c01065e8 <default_free_pages+0x204>
          p->property += base->property;
c01065c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01065cb:	8b 50 08             	mov    0x8(%eax),%edx
c01065ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01065d1:	8b 40 08             	mov    0x8(%eax),%eax
c01065d4:	01 c2                	add    %eax,%edx
c01065d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01065d9:	89 50 08             	mov    %edx,0x8(%eax)
          base->property = 0;
c01065dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01065df:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
          break;
c01065e6:	eb 20                	jmp    c0106608 <default_free_pages+0x224>
c01065e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01065eb:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c01065ee:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01065f1:	8b 00                	mov    (%eax),%eax
        }
        le = list_prev(le);
c01065f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
        p = le2page(le,page_link);
c01065f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01065f9:	83 e8 0c             	sub    $0xc,%eax
c01065fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
      while(le!=&free_list){
c01065ff:	81 7d f4 44 11 1a c0 	cmpl   $0xc01a1144,-0xc(%ebp)
c0106606:	75 b6                	jne    c01065be <default_free_pages+0x1da>
      }
    }
   //更新总空闲页数
    nr_free += n;
c0106608:	8b 15 4c 11 1a c0    	mov    0xc01a114c,%edx
c010660e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106611:	01 d0                	add    %edx,%eax
c0106613:	a3 4c 11 1a c0       	mov    %eax,0xc01a114c
    return ;
c0106618:	90                   	nop
}
c0106619:	c9                   	leave  
c010661a:	c3                   	ret    

c010661b <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c010661b:	55                   	push   %ebp
c010661c:	89 e5                	mov    %esp,%ebp
    return nr_free;
c010661e:	a1 4c 11 1a c0       	mov    0xc01a114c,%eax
}
c0106623:	5d                   	pop    %ebp
c0106624:	c3                   	ret    

c0106625 <basic_check>:

static void
basic_check(void) {
c0106625:	55                   	push   %ebp
c0106626:	89 e5                	mov    %esp,%ebp
c0106628:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c010662b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0106632:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106635:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106638:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010663b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c010663e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106645:	e8 8d 0e 00 00       	call   c01074d7 <alloc_pages>
c010664a:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010664d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0106651:	75 24                	jne    c0106677 <basic_check+0x52>
c0106653:	c7 44 24 0c 20 d4 10 	movl   $0xc010d420,0xc(%esp)
c010665a:	c0 
c010665b:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c0106662:	c0 
c0106663:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c010666a:	00 
c010666b:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c0106672:	e8 89 9d ff ff       	call   c0100400 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0106677:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010667e:	e8 54 0e 00 00       	call   c01074d7 <alloc_pages>
c0106683:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106686:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010668a:	75 24                	jne    c01066b0 <basic_check+0x8b>
c010668c:	c7 44 24 0c 3c d4 10 	movl   $0xc010d43c,0xc(%esp)
c0106693:	c0 
c0106694:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c010669b:	c0 
c010669c:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c01066a3:	00 
c01066a4:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c01066ab:	e8 50 9d ff ff       	call   c0100400 <__panic>
    assert((p2 = alloc_page()) != NULL);
c01066b0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01066b7:	e8 1b 0e 00 00       	call   c01074d7 <alloc_pages>
c01066bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01066bf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01066c3:	75 24                	jne    c01066e9 <basic_check+0xc4>
c01066c5:	c7 44 24 0c 58 d4 10 	movl   $0xc010d458,0xc(%esp)
c01066cc:	c0 
c01066cd:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c01066d4:	c0 
c01066d5:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
c01066dc:	00 
c01066dd:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c01066e4:	e8 17 9d ff ff       	call   c0100400 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c01066e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01066ec:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01066ef:	74 10                	je     c0106701 <basic_check+0xdc>
c01066f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01066f4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01066f7:	74 08                	je     c0106701 <basic_check+0xdc>
c01066f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01066fc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01066ff:	75 24                	jne    c0106725 <basic_check+0x100>
c0106701:	c7 44 24 0c 74 d4 10 	movl   $0xc010d474,0xc(%esp)
c0106708:	c0 
c0106709:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c0106710:	c0 
c0106711:	c7 44 24 04 df 00 00 	movl   $0xdf,0x4(%esp)
c0106718:	00 
c0106719:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c0106720:	e8 db 9c ff ff       	call   c0100400 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0106725:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106728:	89 04 24             	mov    %eax,(%esp)
c010672b:	e8 ab f9 ff ff       	call   c01060db <page_ref>
c0106730:	85 c0                	test   %eax,%eax
c0106732:	75 1e                	jne    c0106752 <basic_check+0x12d>
c0106734:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106737:	89 04 24             	mov    %eax,(%esp)
c010673a:	e8 9c f9 ff ff       	call   c01060db <page_ref>
c010673f:	85 c0                	test   %eax,%eax
c0106741:	75 0f                	jne    c0106752 <basic_check+0x12d>
c0106743:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106746:	89 04 24             	mov    %eax,(%esp)
c0106749:	e8 8d f9 ff ff       	call   c01060db <page_ref>
c010674e:	85 c0                	test   %eax,%eax
c0106750:	74 24                	je     c0106776 <basic_check+0x151>
c0106752:	c7 44 24 0c 98 d4 10 	movl   $0xc010d498,0xc(%esp)
c0106759:	c0 
c010675a:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c0106761:	c0 
c0106762:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
c0106769:	00 
c010676a:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c0106771:	e8 8a 9c ff ff       	call   c0100400 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0106776:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106779:	89 04 24             	mov    %eax,(%esp)
c010677c:	e8 44 f9 ff ff       	call   c01060c5 <page2pa>
c0106781:	8b 15 80 ef 19 c0    	mov    0xc019ef80,%edx
c0106787:	c1 e2 0c             	shl    $0xc,%edx
c010678a:	39 d0                	cmp    %edx,%eax
c010678c:	72 24                	jb     c01067b2 <basic_check+0x18d>
c010678e:	c7 44 24 0c d4 d4 10 	movl   $0xc010d4d4,0xc(%esp)
c0106795:	c0 
c0106796:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c010679d:	c0 
c010679e:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
c01067a5:	00 
c01067a6:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c01067ad:	e8 4e 9c ff ff       	call   c0100400 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c01067b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01067b5:	89 04 24             	mov    %eax,(%esp)
c01067b8:	e8 08 f9 ff ff       	call   c01060c5 <page2pa>
c01067bd:	8b 15 80 ef 19 c0    	mov    0xc019ef80,%edx
c01067c3:	c1 e2 0c             	shl    $0xc,%edx
c01067c6:	39 d0                	cmp    %edx,%eax
c01067c8:	72 24                	jb     c01067ee <basic_check+0x1c9>
c01067ca:	c7 44 24 0c f1 d4 10 	movl   $0xc010d4f1,0xc(%esp)
c01067d1:	c0 
c01067d2:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c01067d9:	c0 
c01067da:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c01067e1:	00 
c01067e2:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c01067e9:	e8 12 9c ff ff       	call   c0100400 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c01067ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01067f1:	89 04 24             	mov    %eax,(%esp)
c01067f4:	e8 cc f8 ff ff       	call   c01060c5 <page2pa>
c01067f9:	8b 15 80 ef 19 c0    	mov    0xc019ef80,%edx
c01067ff:	c1 e2 0c             	shl    $0xc,%edx
c0106802:	39 d0                	cmp    %edx,%eax
c0106804:	72 24                	jb     c010682a <basic_check+0x205>
c0106806:	c7 44 24 0c 0e d5 10 	movl   $0xc010d50e,0xc(%esp)
c010680d:	c0 
c010680e:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c0106815:	c0 
c0106816:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
c010681d:	00 
c010681e:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c0106825:	e8 d6 9b ff ff       	call   c0100400 <__panic>

    list_entry_t free_list_store = free_list;
c010682a:	a1 44 11 1a c0       	mov    0xc01a1144,%eax
c010682f:	8b 15 48 11 1a c0    	mov    0xc01a1148,%edx
c0106835:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0106838:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010683b:	c7 45 e0 44 11 1a c0 	movl   $0xc01a1144,-0x20(%ebp)
    elm->prev = elm->next = elm;
c0106842:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106845:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106848:	89 50 04             	mov    %edx,0x4(%eax)
c010684b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010684e:	8b 50 04             	mov    0x4(%eax),%edx
c0106851:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106854:	89 10                	mov    %edx,(%eax)
c0106856:	c7 45 dc 44 11 1a c0 	movl   $0xc01a1144,-0x24(%ebp)
    return list->next == list;
c010685d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106860:	8b 40 04             	mov    0x4(%eax),%eax
c0106863:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0106866:	0f 94 c0             	sete   %al
c0106869:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c010686c:	85 c0                	test   %eax,%eax
c010686e:	75 24                	jne    c0106894 <basic_check+0x26f>
c0106870:	c7 44 24 0c 2b d5 10 	movl   $0xc010d52b,0xc(%esp)
c0106877:	c0 
c0106878:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c010687f:	c0 
c0106880:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
c0106887:	00 
c0106888:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c010688f:	e8 6c 9b ff ff       	call   c0100400 <__panic>

    unsigned int nr_free_store = nr_free;
c0106894:	a1 4c 11 1a c0       	mov    0xc01a114c,%eax
c0106899:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c010689c:	c7 05 4c 11 1a c0 00 	movl   $0x0,0xc01a114c
c01068a3:	00 00 00 

    assert(alloc_page() == NULL);
c01068a6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01068ad:	e8 25 0c 00 00       	call   c01074d7 <alloc_pages>
c01068b2:	85 c0                	test   %eax,%eax
c01068b4:	74 24                	je     c01068da <basic_check+0x2b5>
c01068b6:	c7 44 24 0c 42 d5 10 	movl   $0xc010d542,0xc(%esp)
c01068bd:	c0 
c01068be:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c01068c5:	c0 
c01068c6:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
c01068cd:	00 
c01068ce:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c01068d5:	e8 26 9b ff ff       	call   c0100400 <__panic>

    free_page(p0);
c01068da:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01068e1:	00 
c01068e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01068e5:	89 04 24             	mov    %eax,(%esp)
c01068e8:	e8 55 0c 00 00       	call   c0107542 <free_pages>
    free_page(p1);
c01068ed:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01068f4:	00 
c01068f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01068f8:	89 04 24             	mov    %eax,(%esp)
c01068fb:	e8 42 0c 00 00       	call   c0107542 <free_pages>
    free_page(p2);
c0106900:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106907:	00 
c0106908:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010690b:	89 04 24             	mov    %eax,(%esp)
c010690e:	e8 2f 0c 00 00       	call   c0107542 <free_pages>
    assert(nr_free == 3);
c0106913:	a1 4c 11 1a c0       	mov    0xc01a114c,%eax
c0106918:	83 f8 03             	cmp    $0x3,%eax
c010691b:	74 24                	je     c0106941 <basic_check+0x31c>
c010691d:	c7 44 24 0c 57 d5 10 	movl   $0xc010d557,0xc(%esp)
c0106924:	c0 
c0106925:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c010692c:	c0 
c010692d:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
c0106934:	00 
c0106935:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c010693c:	e8 bf 9a ff ff       	call   c0100400 <__panic>

    assert((p0 = alloc_page()) != NULL);
c0106941:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106948:	e8 8a 0b 00 00       	call   c01074d7 <alloc_pages>
c010694d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106950:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0106954:	75 24                	jne    c010697a <basic_check+0x355>
c0106956:	c7 44 24 0c 20 d4 10 	movl   $0xc010d420,0xc(%esp)
c010695d:	c0 
c010695e:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c0106965:	c0 
c0106966:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
c010696d:	00 
c010696e:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c0106975:	e8 86 9a ff ff       	call   c0100400 <__panic>
    assert((p1 = alloc_page()) != NULL);
c010697a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106981:	e8 51 0b 00 00       	call   c01074d7 <alloc_pages>
c0106986:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106989:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010698d:	75 24                	jne    c01069b3 <basic_check+0x38e>
c010698f:	c7 44 24 0c 3c d4 10 	movl   $0xc010d43c,0xc(%esp)
c0106996:	c0 
c0106997:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c010699e:	c0 
c010699f:	c7 44 24 04 f5 00 00 	movl   $0xf5,0x4(%esp)
c01069a6:	00 
c01069a7:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c01069ae:	e8 4d 9a ff ff       	call   c0100400 <__panic>
    assert((p2 = alloc_page()) != NULL);
c01069b3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01069ba:	e8 18 0b 00 00       	call   c01074d7 <alloc_pages>
c01069bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01069c2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01069c6:	75 24                	jne    c01069ec <basic_check+0x3c7>
c01069c8:	c7 44 24 0c 58 d4 10 	movl   $0xc010d458,0xc(%esp)
c01069cf:	c0 
c01069d0:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c01069d7:	c0 
c01069d8:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
c01069df:	00 
c01069e0:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c01069e7:	e8 14 9a ff ff       	call   c0100400 <__panic>

    assert(alloc_page() == NULL);
c01069ec:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01069f3:	e8 df 0a 00 00       	call   c01074d7 <alloc_pages>
c01069f8:	85 c0                	test   %eax,%eax
c01069fa:	74 24                	je     c0106a20 <basic_check+0x3fb>
c01069fc:	c7 44 24 0c 42 d5 10 	movl   $0xc010d542,0xc(%esp)
c0106a03:	c0 
c0106a04:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c0106a0b:	c0 
c0106a0c:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c0106a13:	00 
c0106a14:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c0106a1b:	e8 e0 99 ff ff       	call   c0100400 <__panic>

    free_page(p0);
c0106a20:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106a27:	00 
c0106a28:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106a2b:	89 04 24             	mov    %eax,(%esp)
c0106a2e:	e8 0f 0b 00 00       	call   c0107542 <free_pages>
c0106a33:	c7 45 d8 44 11 1a c0 	movl   $0xc01a1144,-0x28(%ebp)
c0106a3a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106a3d:	8b 40 04             	mov    0x4(%eax),%eax
c0106a40:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0106a43:	0f 94 c0             	sete   %al
c0106a46:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0106a49:	85 c0                	test   %eax,%eax
c0106a4b:	74 24                	je     c0106a71 <basic_check+0x44c>
c0106a4d:	c7 44 24 0c 64 d5 10 	movl   $0xc010d564,0xc(%esp)
c0106a54:	c0 
c0106a55:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c0106a5c:	c0 
c0106a5d:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c0106a64:	00 
c0106a65:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c0106a6c:	e8 8f 99 ff ff       	call   c0100400 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0106a71:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106a78:	e8 5a 0a 00 00       	call   c01074d7 <alloc_pages>
c0106a7d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106a80:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106a83:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0106a86:	74 24                	je     c0106aac <basic_check+0x487>
c0106a88:	c7 44 24 0c 7c d5 10 	movl   $0xc010d57c,0xc(%esp)
c0106a8f:	c0 
c0106a90:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c0106a97:	c0 
c0106a98:	c7 44 24 04 fe 00 00 	movl   $0xfe,0x4(%esp)
c0106a9f:	00 
c0106aa0:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c0106aa7:	e8 54 99 ff ff       	call   c0100400 <__panic>
    assert(alloc_page() == NULL);
c0106aac:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106ab3:	e8 1f 0a 00 00       	call   c01074d7 <alloc_pages>
c0106ab8:	85 c0                	test   %eax,%eax
c0106aba:	74 24                	je     c0106ae0 <basic_check+0x4bb>
c0106abc:	c7 44 24 0c 42 d5 10 	movl   $0xc010d542,0xc(%esp)
c0106ac3:	c0 
c0106ac4:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c0106acb:	c0 
c0106acc:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
c0106ad3:	00 
c0106ad4:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c0106adb:	e8 20 99 ff ff       	call   c0100400 <__panic>

    assert(nr_free == 0);
c0106ae0:	a1 4c 11 1a c0       	mov    0xc01a114c,%eax
c0106ae5:	85 c0                	test   %eax,%eax
c0106ae7:	74 24                	je     c0106b0d <basic_check+0x4e8>
c0106ae9:	c7 44 24 0c 95 d5 10 	movl   $0xc010d595,0xc(%esp)
c0106af0:	c0 
c0106af1:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c0106af8:	c0 
c0106af9:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c0106b00:	00 
c0106b01:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c0106b08:	e8 f3 98 ff ff       	call   c0100400 <__panic>
    free_list = free_list_store;
c0106b0d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106b10:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106b13:	a3 44 11 1a c0       	mov    %eax,0xc01a1144
c0106b18:	89 15 48 11 1a c0    	mov    %edx,0xc01a1148
    nr_free = nr_free_store;
c0106b1e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106b21:	a3 4c 11 1a c0       	mov    %eax,0xc01a114c

    free_page(p);
c0106b26:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106b2d:	00 
c0106b2e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106b31:	89 04 24             	mov    %eax,(%esp)
c0106b34:	e8 09 0a 00 00       	call   c0107542 <free_pages>
    free_page(p1);
c0106b39:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106b40:	00 
c0106b41:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106b44:	89 04 24             	mov    %eax,(%esp)
c0106b47:	e8 f6 09 00 00       	call   c0107542 <free_pages>
    free_page(p2);
c0106b4c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106b53:	00 
c0106b54:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106b57:	89 04 24             	mov    %eax,(%esp)
c0106b5a:	e8 e3 09 00 00       	call   c0107542 <free_pages>
}
c0106b5f:	c9                   	leave  
c0106b60:	c3                   	ret    

c0106b61 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0106b61:	55                   	push   %ebp
c0106b62:	89 e5                	mov    %esp,%ebp
c0106b64:	53                   	push   %ebx
c0106b65:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
c0106b6b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0106b72:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0106b79:	c7 45 ec 44 11 1a c0 	movl   $0xc01a1144,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0106b80:	eb 6b                	jmp    c0106bed <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
c0106b82:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106b85:	83 e8 0c             	sub    $0xc,%eax
c0106b88:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
c0106b8b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106b8e:	83 c0 04             	add    $0x4,%eax
c0106b91:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0106b98:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106b9b:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0106b9e:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0106ba1:	0f a3 10             	bt     %edx,(%eax)
c0106ba4:	19 c0                	sbb    %eax,%eax
c0106ba6:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0106ba9:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0106bad:	0f 95 c0             	setne  %al
c0106bb0:	0f b6 c0             	movzbl %al,%eax
c0106bb3:	85 c0                	test   %eax,%eax
c0106bb5:	75 24                	jne    c0106bdb <default_check+0x7a>
c0106bb7:	c7 44 24 0c a2 d5 10 	movl   $0xc010d5a2,0xc(%esp)
c0106bbe:	c0 
c0106bbf:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c0106bc6:	c0 
c0106bc7:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
c0106bce:	00 
c0106bcf:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c0106bd6:	e8 25 98 ff ff       	call   c0100400 <__panic>
        count ++, total += p->property;
c0106bdb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0106bdf:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106be2:	8b 50 08             	mov    0x8(%eax),%edx
c0106be5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106be8:	01 d0                	add    %edx,%eax
c0106bea:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106bed:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106bf0:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c0106bf3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0106bf6:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0106bf9:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106bfc:	81 7d ec 44 11 1a c0 	cmpl   $0xc01a1144,-0x14(%ebp)
c0106c03:	0f 85 79 ff ff ff    	jne    c0106b82 <default_check+0x21>
    }
    assert(total == nr_free_pages());
c0106c09:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c0106c0c:	e8 63 09 00 00       	call   c0107574 <nr_free_pages>
c0106c11:	39 c3                	cmp    %eax,%ebx
c0106c13:	74 24                	je     c0106c39 <default_check+0xd8>
c0106c15:	c7 44 24 0c b2 d5 10 	movl   $0xc010d5b2,0xc(%esp)
c0106c1c:	c0 
c0106c1d:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c0106c24:	c0 
c0106c25:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c0106c2c:	00 
c0106c2d:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c0106c34:	e8 c7 97 ff ff       	call   c0100400 <__panic>

    basic_check();
c0106c39:	e8 e7 f9 ff ff       	call   c0106625 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0106c3e:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0106c45:	e8 8d 08 00 00       	call   c01074d7 <alloc_pages>
c0106c4a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
c0106c4d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106c51:	75 24                	jne    c0106c77 <default_check+0x116>
c0106c53:	c7 44 24 0c cb d5 10 	movl   $0xc010d5cb,0xc(%esp)
c0106c5a:	c0 
c0106c5b:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c0106c62:	c0 
c0106c63:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c0106c6a:	00 
c0106c6b:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c0106c72:	e8 89 97 ff ff       	call   c0100400 <__panic>
    assert(!PageProperty(p0));
c0106c77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106c7a:	83 c0 04             	add    $0x4,%eax
c0106c7d:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0106c84:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106c87:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0106c8a:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0106c8d:	0f a3 10             	bt     %edx,(%eax)
c0106c90:	19 c0                	sbb    %eax,%eax
c0106c92:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0106c95:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0106c99:	0f 95 c0             	setne  %al
c0106c9c:	0f b6 c0             	movzbl %al,%eax
c0106c9f:	85 c0                	test   %eax,%eax
c0106ca1:	74 24                	je     c0106cc7 <default_check+0x166>
c0106ca3:	c7 44 24 0c d6 d5 10 	movl   $0xc010d5d6,0xc(%esp)
c0106caa:	c0 
c0106cab:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c0106cb2:	c0 
c0106cb3:	c7 44 24 04 1b 01 00 	movl   $0x11b,0x4(%esp)
c0106cba:	00 
c0106cbb:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c0106cc2:	e8 39 97 ff ff       	call   c0100400 <__panic>

    list_entry_t free_list_store = free_list;
c0106cc7:	a1 44 11 1a c0       	mov    0xc01a1144,%eax
c0106ccc:	8b 15 48 11 1a c0    	mov    0xc01a1148,%edx
c0106cd2:	89 45 80             	mov    %eax,-0x80(%ebp)
c0106cd5:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0106cd8:	c7 45 b4 44 11 1a c0 	movl   $0xc01a1144,-0x4c(%ebp)
    elm->prev = elm->next = elm;
c0106cdf:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0106ce2:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0106ce5:	89 50 04             	mov    %edx,0x4(%eax)
c0106ce8:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0106ceb:	8b 50 04             	mov    0x4(%eax),%edx
c0106cee:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0106cf1:	89 10                	mov    %edx,(%eax)
c0106cf3:	c7 45 b0 44 11 1a c0 	movl   $0xc01a1144,-0x50(%ebp)
    return list->next == list;
c0106cfa:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0106cfd:	8b 40 04             	mov    0x4(%eax),%eax
c0106d00:	39 45 b0             	cmp    %eax,-0x50(%ebp)
c0106d03:	0f 94 c0             	sete   %al
c0106d06:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0106d09:	85 c0                	test   %eax,%eax
c0106d0b:	75 24                	jne    c0106d31 <default_check+0x1d0>
c0106d0d:	c7 44 24 0c 2b d5 10 	movl   $0xc010d52b,0xc(%esp)
c0106d14:	c0 
c0106d15:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c0106d1c:	c0 
c0106d1d:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
c0106d24:	00 
c0106d25:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c0106d2c:	e8 cf 96 ff ff       	call   c0100400 <__panic>
    assert(alloc_page() == NULL);
c0106d31:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106d38:	e8 9a 07 00 00       	call   c01074d7 <alloc_pages>
c0106d3d:	85 c0                	test   %eax,%eax
c0106d3f:	74 24                	je     c0106d65 <default_check+0x204>
c0106d41:	c7 44 24 0c 42 d5 10 	movl   $0xc010d542,0xc(%esp)
c0106d48:	c0 
c0106d49:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c0106d50:	c0 
c0106d51:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
c0106d58:	00 
c0106d59:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c0106d60:	e8 9b 96 ff ff       	call   c0100400 <__panic>

    unsigned int nr_free_store = nr_free;
c0106d65:	a1 4c 11 1a c0       	mov    0xc01a114c,%eax
c0106d6a:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c0106d6d:	c7 05 4c 11 1a c0 00 	movl   $0x0,0xc01a114c
c0106d74:	00 00 00 

    free_pages(p0 + 2, 3);
c0106d77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106d7a:	83 c0 40             	add    $0x40,%eax
c0106d7d:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0106d84:	00 
c0106d85:	89 04 24             	mov    %eax,(%esp)
c0106d88:	e8 b5 07 00 00       	call   c0107542 <free_pages>
    assert(alloc_pages(4) == NULL);
c0106d8d:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0106d94:	e8 3e 07 00 00       	call   c01074d7 <alloc_pages>
c0106d99:	85 c0                	test   %eax,%eax
c0106d9b:	74 24                	je     c0106dc1 <default_check+0x260>
c0106d9d:	c7 44 24 0c e8 d5 10 	movl   $0xc010d5e8,0xc(%esp)
c0106da4:	c0 
c0106da5:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c0106dac:	c0 
c0106dad:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
c0106db4:	00 
c0106db5:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c0106dbc:	e8 3f 96 ff ff       	call   c0100400 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0106dc1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106dc4:	83 c0 40             	add    $0x40,%eax
c0106dc7:	83 c0 04             	add    $0x4,%eax
c0106dca:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c0106dd1:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106dd4:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0106dd7:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0106dda:	0f a3 10             	bt     %edx,(%eax)
c0106ddd:	19 c0                	sbb    %eax,%eax
c0106ddf:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c0106de2:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0106de6:	0f 95 c0             	setne  %al
c0106de9:	0f b6 c0             	movzbl %al,%eax
c0106dec:	85 c0                	test   %eax,%eax
c0106dee:	74 0e                	je     c0106dfe <default_check+0x29d>
c0106df0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106df3:	83 c0 40             	add    $0x40,%eax
c0106df6:	8b 40 08             	mov    0x8(%eax),%eax
c0106df9:	83 f8 03             	cmp    $0x3,%eax
c0106dfc:	74 24                	je     c0106e22 <default_check+0x2c1>
c0106dfe:	c7 44 24 0c 00 d6 10 	movl   $0xc010d600,0xc(%esp)
c0106e05:	c0 
c0106e06:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c0106e0d:	c0 
c0106e0e:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
c0106e15:	00 
c0106e16:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c0106e1d:	e8 de 95 ff ff       	call   c0100400 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0106e22:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0106e29:	e8 a9 06 00 00       	call   c01074d7 <alloc_pages>
c0106e2e:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0106e31:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0106e35:	75 24                	jne    c0106e5b <default_check+0x2fa>
c0106e37:	c7 44 24 0c 2c d6 10 	movl   $0xc010d62c,0xc(%esp)
c0106e3e:	c0 
c0106e3f:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c0106e46:	c0 
c0106e47:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
c0106e4e:	00 
c0106e4f:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c0106e56:	e8 a5 95 ff ff       	call   c0100400 <__panic>
    assert(alloc_page() == NULL);
c0106e5b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106e62:	e8 70 06 00 00       	call   c01074d7 <alloc_pages>
c0106e67:	85 c0                	test   %eax,%eax
c0106e69:	74 24                	je     c0106e8f <default_check+0x32e>
c0106e6b:	c7 44 24 0c 42 d5 10 	movl   $0xc010d542,0xc(%esp)
c0106e72:	c0 
c0106e73:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c0106e7a:	c0 
c0106e7b:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
c0106e82:	00 
c0106e83:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c0106e8a:	e8 71 95 ff ff       	call   c0100400 <__panic>
    assert(p0 + 2 == p1);
c0106e8f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106e92:	83 c0 40             	add    $0x40,%eax
c0106e95:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0106e98:	74 24                	je     c0106ebe <default_check+0x35d>
c0106e9a:	c7 44 24 0c 4a d6 10 	movl   $0xc010d64a,0xc(%esp)
c0106ea1:	c0 
c0106ea2:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c0106ea9:	c0 
c0106eaa:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
c0106eb1:	00 
c0106eb2:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c0106eb9:	e8 42 95 ff ff       	call   c0100400 <__panic>

    p2 = p0 + 1;
c0106ebe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106ec1:	83 c0 20             	add    $0x20,%eax
c0106ec4:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
c0106ec7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106ece:	00 
c0106ecf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106ed2:	89 04 24             	mov    %eax,(%esp)
c0106ed5:	e8 68 06 00 00       	call   c0107542 <free_pages>
    free_pages(p1, 3);
c0106eda:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0106ee1:	00 
c0106ee2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106ee5:	89 04 24             	mov    %eax,(%esp)
c0106ee8:	e8 55 06 00 00       	call   c0107542 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c0106eed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106ef0:	83 c0 04             	add    $0x4,%eax
c0106ef3:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0106efa:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106efd:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0106f00:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0106f03:	0f a3 10             	bt     %edx,(%eax)
c0106f06:	19 c0                	sbb    %eax,%eax
c0106f08:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0106f0b:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0106f0f:	0f 95 c0             	setne  %al
c0106f12:	0f b6 c0             	movzbl %al,%eax
c0106f15:	85 c0                	test   %eax,%eax
c0106f17:	74 0b                	je     c0106f24 <default_check+0x3c3>
c0106f19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106f1c:	8b 40 08             	mov    0x8(%eax),%eax
c0106f1f:	83 f8 01             	cmp    $0x1,%eax
c0106f22:	74 24                	je     c0106f48 <default_check+0x3e7>
c0106f24:	c7 44 24 0c 58 d6 10 	movl   $0xc010d658,0xc(%esp)
c0106f2b:	c0 
c0106f2c:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c0106f33:	c0 
c0106f34:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
c0106f3b:	00 
c0106f3c:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c0106f43:	e8 b8 94 ff ff       	call   c0100400 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0106f48:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106f4b:	83 c0 04             	add    $0x4,%eax
c0106f4e:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c0106f55:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106f58:	8b 45 90             	mov    -0x70(%ebp),%eax
c0106f5b:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0106f5e:	0f a3 10             	bt     %edx,(%eax)
c0106f61:	19 c0                	sbb    %eax,%eax
c0106f63:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c0106f66:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c0106f6a:	0f 95 c0             	setne  %al
c0106f6d:	0f b6 c0             	movzbl %al,%eax
c0106f70:	85 c0                	test   %eax,%eax
c0106f72:	74 0b                	je     c0106f7f <default_check+0x41e>
c0106f74:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106f77:	8b 40 08             	mov    0x8(%eax),%eax
c0106f7a:	83 f8 03             	cmp    $0x3,%eax
c0106f7d:	74 24                	je     c0106fa3 <default_check+0x442>
c0106f7f:	c7 44 24 0c 80 d6 10 	movl   $0xc010d680,0xc(%esp)
c0106f86:	c0 
c0106f87:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c0106f8e:	c0 
c0106f8f:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
c0106f96:	00 
c0106f97:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c0106f9e:	e8 5d 94 ff ff       	call   c0100400 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c0106fa3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106faa:	e8 28 05 00 00       	call   c01074d7 <alloc_pages>
c0106faf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106fb2:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106fb5:	83 e8 20             	sub    $0x20,%eax
c0106fb8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0106fbb:	74 24                	je     c0106fe1 <default_check+0x480>
c0106fbd:	c7 44 24 0c a6 d6 10 	movl   $0xc010d6a6,0xc(%esp)
c0106fc4:	c0 
c0106fc5:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c0106fcc:	c0 
c0106fcd:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
c0106fd4:	00 
c0106fd5:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c0106fdc:	e8 1f 94 ff ff       	call   c0100400 <__panic>
    free_page(p0);
c0106fe1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106fe8:	00 
c0106fe9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106fec:	89 04 24             	mov    %eax,(%esp)
c0106fef:	e8 4e 05 00 00       	call   c0107542 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c0106ff4:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0106ffb:	e8 d7 04 00 00       	call   c01074d7 <alloc_pages>
c0107000:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107003:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107006:	83 c0 20             	add    $0x20,%eax
c0107009:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c010700c:	74 24                	je     c0107032 <default_check+0x4d1>
c010700e:	c7 44 24 0c c4 d6 10 	movl   $0xc010d6c4,0xc(%esp)
c0107015:	c0 
c0107016:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c010701d:	c0 
c010701e:	c7 44 24 04 34 01 00 	movl   $0x134,0x4(%esp)
c0107025:	00 
c0107026:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c010702d:	e8 ce 93 ff ff       	call   c0100400 <__panic>

    free_pages(p0, 2);
c0107032:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0107039:	00 
c010703a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010703d:	89 04 24             	mov    %eax,(%esp)
c0107040:	e8 fd 04 00 00       	call   c0107542 <free_pages>
    free_page(p2);
c0107045:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010704c:	00 
c010704d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107050:	89 04 24             	mov    %eax,(%esp)
c0107053:	e8 ea 04 00 00       	call   c0107542 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c0107058:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c010705f:	e8 73 04 00 00       	call   c01074d7 <alloc_pages>
c0107064:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107067:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010706b:	75 24                	jne    c0107091 <default_check+0x530>
c010706d:	c7 44 24 0c e4 d6 10 	movl   $0xc010d6e4,0xc(%esp)
c0107074:	c0 
c0107075:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c010707c:	c0 
c010707d:	c7 44 24 04 39 01 00 	movl   $0x139,0x4(%esp)
c0107084:	00 
c0107085:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c010708c:	e8 6f 93 ff ff       	call   c0100400 <__panic>
    assert(alloc_page() == NULL);
c0107091:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107098:	e8 3a 04 00 00       	call   c01074d7 <alloc_pages>
c010709d:	85 c0                	test   %eax,%eax
c010709f:	74 24                	je     c01070c5 <default_check+0x564>
c01070a1:	c7 44 24 0c 42 d5 10 	movl   $0xc010d542,0xc(%esp)
c01070a8:	c0 
c01070a9:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c01070b0:	c0 
c01070b1:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
c01070b8:	00 
c01070b9:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c01070c0:	e8 3b 93 ff ff       	call   c0100400 <__panic>

    assert(nr_free == 0);
c01070c5:	a1 4c 11 1a c0       	mov    0xc01a114c,%eax
c01070ca:	85 c0                	test   %eax,%eax
c01070cc:	74 24                	je     c01070f2 <default_check+0x591>
c01070ce:	c7 44 24 0c 95 d5 10 	movl   $0xc010d595,0xc(%esp)
c01070d5:	c0 
c01070d6:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c01070dd:	c0 
c01070de:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
c01070e5:	00 
c01070e6:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c01070ed:	e8 0e 93 ff ff       	call   c0100400 <__panic>
    nr_free = nr_free_store;
c01070f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01070f5:	a3 4c 11 1a c0       	mov    %eax,0xc01a114c

    free_list = free_list_store;
c01070fa:	8b 45 80             	mov    -0x80(%ebp),%eax
c01070fd:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0107100:	a3 44 11 1a c0       	mov    %eax,0xc01a1144
c0107105:	89 15 48 11 1a c0    	mov    %edx,0xc01a1148
    free_pages(p0, 5);
c010710b:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c0107112:	00 
c0107113:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107116:	89 04 24             	mov    %eax,(%esp)
c0107119:	e8 24 04 00 00       	call   c0107542 <free_pages>

    le = &free_list;
c010711e:	c7 45 ec 44 11 1a c0 	movl   $0xc01a1144,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0107125:	eb 1d                	jmp    c0107144 <default_check+0x5e3>
        struct Page *p = le2page(le, page_link);
c0107127:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010712a:	83 e8 0c             	sub    $0xc,%eax
c010712d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
c0107130:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0107134:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0107137:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010713a:	8b 40 08             	mov    0x8(%eax),%eax
c010713d:	29 c2                	sub    %eax,%edx
c010713f:	89 d0                	mov    %edx,%eax
c0107141:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107144:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107147:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c010714a:	8b 45 88             	mov    -0x78(%ebp),%eax
c010714d:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0107150:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107153:	81 7d ec 44 11 1a c0 	cmpl   $0xc01a1144,-0x14(%ebp)
c010715a:	75 cb                	jne    c0107127 <default_check+0x5c6>
    }
    assert(count == 0);
c010715c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107160:	74 24                	je     c0107186 <default_check+0x625>
c0107162:	c7 44 24 0c 02 d7 10 	movl   $0xc010d702,0xc(%esp)
c0107169:	c0 
c010716a:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c0107171:	c0 
c0107172:	c7 44 24 04 47 01 00 	movl   $0x147,0x4(%esp)
c0107179:	00 
c010717a:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c0107181:	e8 7a 92 ff ff       	call   c0100400 <__panic>
    assert(total == 0);
c0107186:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010718a:	74 24                	je     c01071b0 <default_check+0x64f>
c010718c:	c7 44 24 0c 0d d7 10 	movl   $0xc010d70d,0xc(%esp)
c0107193:	c0 
c0107194:	c7 44 24 08 d2 d3 10 	movl   $0xc010d3d2,0x8(%esp)
c010719b:	c0 
c010719c:	c7 44 24 04 48 01 00 	movl   $0x148,0x4(%esp)
c01071a3:	00 
c01071a4:	c7 04 24 e7 d3 10 c0 	movl   $0xc010d3e7,(%esp)
c01071ab:	e8 50 92 ff ff       	call   c0100400 <__panic>
}
c01071b0:	81 c4 94 00 00 00    	add    $0x94,%esp
c01071b6:	5b                   	pop    %ebx
c01071b7:	5d                   	pop    %ebp
c01071b8:	c3                   	ret    

c01071b9 <page2ppn>:
page2ppn(struct Page *page) {
c01071b9:	55                   	push   %ebp
c01071ba:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01071bc:	8b 55 08             	mov    0x8(%ebp),%edx
c01071bf:	a1 58 11 1a c0       	mov    0xc01a1158,%eax
c01071c4:	29 c2                	sub    %eax,%edx
c01071c6:	89 d0                	mov    %edx,%eax
c01071c8:	c1 f8 05             	sar    $0x5,%eax
}
c01071cb:	5d                   	pop    %ebp
c01071cc:	c3                   	ret    

c01071cd <page2pa>:
page2pa(struct Page *page) {
c01071cd:	55                   	push   %ebp
c01071ce:	89 e5                	mov    %esp,%ebp
c01071d0:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01071d3:	8b 45 08             	mov    0x8(%ebp),%eax
c01071d6:	89 04 24             	mov    %eax,(%esp)
c01071d9:	e8 db ff ff ff       	call   c01071b9 <page2ppn>
c01071de:	c1 e0 0c             	shl    $0xc,%eax
}
c01071e1:	c9                   	leave  
c01071e2:	c3                   	ret    

c01071e3 <pa2page>:
pa2page(uintptr_t pa) {
c01071e3:	55                   	push   %ebp
c01071e4:	89 e5                	mov    %esp,%ebp
c01071e6:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c01071e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01071ec:	c1 e8 0c             	shr    $0xc,%eax
c01071ef:	89 c2                	mov    %eax,%edx
c01071f1:	a1 80 ef 19 c0       	mov    0xc019ef80,%eax
c01071f6:	39 c2                	cmp    %eax,%edx
c01071f8:	72 1c                	jb     c0107216 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c01071fa:	c7 44 24 08 48 d7 10 	movl   $0xc010d748,0x8(%esp)
c0107201:	c0 
c0107202:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0107209:	00 
c010720a:	c7 04 24 67 d7 10 c0 	movl   $0xc010d767,(%esp)
c0107211:	e8 ea 91 ff ff       	call   c0100400 <__panic>
    return &pages[PPN(pa)];
c0107216:	a1 58 11 1a c0       	mov    0xc01a1158,%eax
c010721b:	8b 55 08             	mov    0x8(%ebp),%edx
c010721e:	c1 ea 0c             	shr    $0xc,%edx
c0107221:	c1 e2 05             	shl    $0x5,%edx
c0107224:	01 d0                	add    %edx,%eax
}
c0107226:	c9                   	leave  
c0107227:	c3                   	ret    

c0107228 <page2kva>:
page2kva(struct Page *page) {
c0107228:	55                   	push   %ebp
c0107229:	89 e5                	mov    %esp,%ebp
c010722b:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c010722e:	8b 45 08             	mov    0x8(%ebp),%eax
c0107231:	89 04 24             	mov    %eax,(%esp)
c0107234:	e8 94 ff ff ff       	call   c01071cd <page2pa>
c0107239:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010723c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010723f:	c1 e8 0c             	shr    $0xc,%eax
c0107242:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107245:	a1 80 ef 19 c0       	mov    0xc019ef80,%eax
c010724a:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010724d:	72 23                	jb     c0107272 <page2kva+0x4a>
c010724f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107252:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107256:	c7 44 24 08 78 d7 10 	movl   $0xc010d778,0x8(%esp)
c010725d:	c0 
c010725e:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0107265:	00 
c0107266:	c7 04 24 67 d7 10 c0 	movl   $0xc010d767,(%esp)
c010726d:	e8 8e 91 ff ff       	call   c0100400 <__panic>
c0107272:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107275:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c010727a:	c9                   	leave  
c010727b:	c3                   	ret    

c010727c <pte2page>:
pte2page(pte_t pte) {
c010727c:	55                   	push   %ebp
c010727d:	89 e5                	mov    %esp,%ebp
c010727f:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0107282:	8b 45 08             	mov    0x8(%ebp),%eax
c0107285:	83 e0 01             	and    $0x1,%eax
c0107288:	85 c0                	test   %eax,%eax
c010728a:	75 1c                	jne    c01072a8 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c010728c:	c7 44 24 08 9c d7 10 	movl   $0xc010d79c,0x8(%esp)
c0107293:	c0 
c0107294:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c010729b:	00 
c010729c:	c7 04 24 67 d7 10 c0 	movl   $0xc010d767,(%esp)
c01072a3:	e8 58 91 ff ff       	call   c0100400 <__panic>
    return pa2page(PTE_ADDR(pte));
c01072a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01072ab:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01072b0:	89 04 24             	mov    %eax,(%esp)
c01072b3:	e8 2b ff ff ff       	call   c01071e3 <pa2page>
}
c01072b8:	c9                   	leave  
c01072b9:	c3                   	ret    

c01072ba <pde2page>:
pde2page(pde_t pde) {
c01072ba:	55                   	push   %ebp
c01072bb:	89 e5                	mov    %esp,%ebp
c01072bd:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c01072c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01072c3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01072c8:	89 04 24             	mov    %eax,(%esp)
c01072cb:	e8 13 ff ff ff       	call   c01071e3 <pa2page>
}
c01072d0:	c9                   	leave  
c01072d1:	c3                   	ret    

c01072d2 <page_ref>:
page_ref(struct Page *page) {
c01072d2:	55                   	push   %ebp
c01072d3:	89 e5                	mov    %esp,%ebp
    return page->ref;
c01072d5:	8b 45 08             	mov    0x8(%ebp),%eax
c01072d8:	8b 00                	mov    (%eax),%eax
}
c01072da:	5d                   	pop    %ebp
c01072db:	c3                   	ret    

c01072dc <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c01072dc:	55                   	push   %ebp
c01072dd:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c01072df:	8b 45 08             	mov    0x8(%ebp),%eax
c01072e2:	8b 55 0c             	mov    0xc(%ebp),%edx
c01072e5:	89 10                	mov    %edx,(%eax)
}
c01072e7:	5d                   	pop    %ebp
c01072e8:	c3                   	ret    

c01072e9 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c01072e9:	55                   	push   %ebp
c01072ea:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c01072ec:	8b 45 08             	mov    0x8(%ebp),%eax
c01072ef:	8b 00                	mov    (%eax),%eax
c01072f1:	8d 50 01             	lea    0x1(%eax),%edx
c01072f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01072f7:	89 10                	mov    %edx,(%eax)
    return page->ref;
c01072f9:	8b 45 08             	mov    0x8(%ebp),%eax
c01072fc:	8b 00                	mov    (%eax),%eax
}
c01072fe:	5d                   	pop    %ebp
c01072ff:	c3                   	ret    

c0107300 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0107300:	55                   	push   %ebp
c0107301:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0107303:	8b 45 08             	mov    0x8(%ebp),%eax
c0107306:	8b 00                	mov    (%eax),%eax
c0107308:	8d 50 ff             	lea    -0x1(%eax),%edx
c010730b:	8b 45 08             	mov    0x8(%ebp),%eax
c010730e:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0107310:	8b 45 08             	mov    0x8(%ebp),%eax
c0107313:	8b 00                	mov    (%eax),%eax
}
c0107315:	5d                   	pop    %ebp
c0107316:	c3                   	ret    

c0107317 <__intr_save>:
__intr_save(void) {
c0107317:	55                   	push   %ebp
c0107318:	89 e5                	mov    %esp,%ebp
c010731a:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010731d:	9c                   	pushf  
c010731e:	58                   	pop    %eax
c010731f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0107322:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0107325:	25 00 02 00 00       	and    $0x200,%eax
c010732a:	85 c0                	test   %eax,%eax
c010732c:	74 0c                	je     c010733a <__intr_save+0x23>
        intr_disable();
c010732e:	e8 e2 ae ff ff       	call   c0102215 <intr_disable>
        return 1;
c0107333:	b8 01 00 00 00       	mov    $0x1,%eax
c0107338:	eb 05                	jmp    c010733f <__intr_save+0x28>
    return 0;
c010733a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010733f:	c9                   	leave  
c0107340:	c3                   	ret    

c0107341 <__intr_restore>:
__intr_restore(bool flag) {
c0107341:	55                   	push   %ebp
c0107342:	89 e5                	mov    %esp,%ebp
c0107344:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0107347:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010734b:	74 05                	je     c0107352 <__intr_restore+0x11>
        intr_enable();
c010734d:	e8 bd ae ff ff       	call   c010220f <intr_enable>
}
c0107352:	c9                   	leave  
c0107353:	c3                   	ret    

c0107354 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0107354:	55                   	push   %ebp
c0107355:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0107357:	8b 45 08             	mov    0x8(%ebp),%eax
c010735a:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c010735d:	b8 23 00 00 00       	mov    $0x23,%eax
c0107362:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0107364:	b8 23 00 00 00       	mov    $0x23,%eax
c0107369:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c010736b:	b8 10 00 00 00       	mov    $0x10,%eax
c0107370:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0107372:	b8 10 00 00 00       	mov    $0x10,%eax
c0107377:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0107379:	b8 10 00 00 00       	mov    $0x10,%eax
c010737e:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0107380:	ea 87 73 10 c0 08 00 	ljmp   $0x8,$0xc0107387
}
c0107387:	5d                   	pop    %ebp
c0107388:	c3                   	ret    

c0107389 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0107389:	55                   	push   %ebp
c010738a:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c010738c:	8b 45 08             	mov    0x8(%ebp),%eax
c010738f:	a3 a4 ef 19 c0       	mov    %eax,0xc019efa4
}
c0107394:	5d                   	pop    %ebp
c0107395:	c3                   	ret    

c0107396 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0107396:	55                   	push   %ebp
c0107397:	89 e5                	mov    %esp,%ebp
c0107399:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c010739c:	b8 00 a0 12 c0       	mov    $0xc012a000,%eax
c01073a1:	89 04 24             	mov    %eax,(%esp)
c01073a4:	e8 e0 ff ff ff       	call   c0107389 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c01073a9:	66 c7 05 a8 ef 19 c0 	movw   $0x10,0xc019efa8
c01073b0:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c01073b2:	66 c7 05 68 aa 12 c0 	movw   $0x68,0xc012aa68
c01073b9:	68 00 
c01073bb:	b8 a0 ef 19 c0       	mov    $0xc019efa0,%eax
c01073c0:	66 a3 6a aa 12 c0    	mov    %ax,0xc012aa6a
c01073c6:	b8 a0 ef 19 c0       	mov    $0xc019efa0,%eax
c01073cb:	c1 e8 10             	shr    $0x10,%eax
c01073ce:	a2 6c aa 12 c0       	mov    %al,0xc012aa6c
c01073d3:	0f b6 05 6d aa 12 c0 	movzbl 0xc012aa6d,%eax
c01073da:	83 e0 f0             	and    $0xfffffff0,%eax
c01073dd:	83 c8 09             	or     $0x9,%eax
c01073e0:	a2 6d aa 12 c0       	mov    %al,0xc012aa6d
c01073e5:	0f b6 05 6d aa 12 c0 	movzbl 0xc012aa6d,%eax
c01073ec:	83 e0 ef             	and    $0xffffffef,%eax
c01073ef:	a2 6d aa 12 c0       	mov    %al,0xc012aa6d
c01073f4:	0f b6 05 6d aa 12 c0 	movzbl 0xc012aa6d,%eax
c01073fb:	83 e0 9f             	and    $0xffffff9f,%eax
c01073fe:	a2 6d aa 12 c0       	mov    %al,0xc012aa6d
c0107403:	0f b6 05 6d aa 12 c0 	movzbl 0xc012aa6d,%eax
c010740a:	83 c8 80             	or     $0xffffff80,%eax
c010740d:	a2 6d aa 12 c0       	mov    %al,0xc012aa6d
c0107412:	0f b6 05 6e aa 12 c0 	movzbl 0xc012aa6e,%eax
c0107419:	83 e0 f0             	and    $0xfffffff0,%eax
c010741c:	a2 6e aa 12 c0       	mov    %al,0xc012aa6e
c0107421:	0f b6 05 6e aa 12 c0 	movzbl 0xc012aa6e,%eax
c0107428:	83 e0 ef             	and    $0xffffffef,%eax
c010742b:	a2 6e aa 12 c0       	mov    %al,0xc012aa6e
c0107430:	0f b6 05 6e aa 12 c0 	movzbl 0xc012aa6e,%eax
c0107437:	83 e0 df             	and    $0xffffffdf,%eax
c010743a:	a2 6e aa 12 c0       	mov    %al,0xc012aa6e
c010743f:	0f b6 05 6e aa 12 c0 	movzbl 0xc012aa6e,%eax
c0107446:	83 c8 40             	or     $0x40,%eax
c0107449:	a2 6e aa 12 c0       	mov    %al,0xc012aa6e
c010744e:	0f b6 05 6e aa 12 c0 	movzbl 0xc012aa6e,%eax
c0107455:	83 e0 7f             	and    $0x7f,%eax
c0107458:	a2 6e aa 12 c0       	mov    %al,0xc012aa6e
c010745d:	b8 a0 ef 19 c0       	mov    $0xc019efa0,%eax
c0107462:	c1 e8 18             	shr    $0x18,%eax
c0107465:	a2 6f aa 12 c0       	mov    %al,0xc012aa6f

    // reload all segment registers
    lgdt(&gdt_pd);
c010746a:	c7 04 24 70 aa 12 c0 	movl   $0xc012aa70,(%esp)
c0107471:	e8 de fe ff ff       	call   c0107354 <lgdt>
c0107476:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c010747c:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0107480:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0107483:	c9                   	leave  
c0107484:	c3                   	ret    

c0107485 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0107485:	55                   	push   %ebp
c0107486:	89 e5                	mov    %esp,%ebp
c0107488:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c010748b:	c7 05 50 11 1a c0 2c 	movl   $0xc010d72c,0xc01a1150
c0107492:	d7 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0107495:	a1 50 11 1a c0       	mov    0xc01a1150,%eax
c010749a:	8b 00                	mov    (%eax),%eax
c010749c:	89 44 24 04          	mov    %eax,0x4(%esp)
c01074a0:	c7 04 24 c8 d7 10 c0 	movl   $0xc010d7c8,(%esp)
c01074a7:	e8 fd 8d ff ff       	call   c01002a9 <cprintf>
    pmm_manager->init();
c01074ac:	a1 50 11 1a c0       	mov    0xc01a1150,%eax
c01074b1:	8b 40 04             	mov    0x4(%eax),%eax
c01074b4:	ff d0                	call   *%eax
}
c01074b6:	c9                   	leave  
c01074b7:	c3                   	ret    

c01074b8 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c01074b8:	55                   	push   %ebp
c01074b9:	89 e5                	mov    %esp,%ebp
c01074bb:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c01074be:	a1 50 11 1a c0       	mov    0xc01a1150,%eax
c01074c3:	8b 40 08             	mov    0x8(%eax),%eax
c01074c6:	8b 55 0c             	mov    0xc(%ebp),%edx
c01074c9:	89 54 24 04          	mov    %edx,0x4(%esp)
c01074cd:	8b 55 08             	mov    0x8(%ebp),%edx
c01074d0:	89 14 24             	mov    %edx,(%esp)
c01074d3:	ff d0                	call   *%eax
}
c01074d5:	c9                   	leave  
c01074d6:	c3                   	ret    

c01074d7 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c01074d7:	55                   	push   %ebp
c01074d8:	89 e5                	mov    %esp,%ebp
c01074da:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c01074dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    
    while (1)
    {
         local_intr_save(intr_flag);
c01074e4:	e8 2e fe ff ff       	call   c0107317 <__intr_save>
c01074e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
         {
              page = pmm_manager->alloc_pages(n);
c01074ec:	a1 50 11 1a c0       	mov    0xc01a1150,%eax
c01074f1:	8b 40 0c             	mov    0xc(%eax),%eax
c01074f4:	8b 55 08             	mov    0x8(%ebp),%edx
c01074f7:	89 14 24             	mov    %edx,(%esp)
c01074fa:	ff d0                	call   *%eax
c01074fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
         }
         local_intr_restore(intr_flag);
c01074ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107502:	89 04 24             	mov    %eax,(%esp)
c0107505:	e8 37 fe ff ff       	call   c0107341 <__intr_restore>

         if (page != NULL || n > 1 || swap_init_ok == 0) break;
c010750a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010750e:	75 2d                	jne    c010753d <alloc_pages+0x66>
c0107510:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
c0107514:	77 27                	ja     c010753d <alloc_pages+0x66>
c0107516:	a1 6c ef 19 c0       	mov    0xc019ef6c,%eax
c010751b:	85 c0                	test   %eax,%eax
c010751d:	74 1e                	je     c010753d <alloc_pages+0x66>
         
         extern struct mm_struct *check_mm_struct;
         //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
         swap_out(check_mm_struct, n, 0);
c010751f:	8b 55 08             	mov    0x8(%ebp),%edx
c0107522:	a1 58 10 1a c0       	mov    0xc01a1058,%eax
c0107527:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010752e:	00 
c010752f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107533:	89 04 24             	mov    %eax,(%esp)
c0107536:	e8 b5 e0 ff ff       	call   c01055f0 <swap_out>
    }
c010753b:	eb a7                	jmp    c01074e4 <alloc_pages+0xd>
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
c010753d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107540:	c9                   	leave  
c0107541:	c3                   	ret    

c0107542 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0107542:	55                   	push   %ebp
c0107543:	89 e5                	mov    %esp,%ebp
c0107545:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0107548:	e8 ca fd ff ff       	call   c0107317 <__intr_save>
c010754d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0107550:	a1 50 11 1a c0       	mov    0xc01a1150,%eax
c0107555:	8b 40 10             	mov    0x10(%eax),%eax
c0107558:	8b 55 0c             	mov    0xc(%ebp),%edx
c010755b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010755f:	8b 55 08             	mov    0x8(%ebp),%edx
c0107562:	89 14 24             	mov    %edx,(%esp)
c0107565:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0107567:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010756a:	89 04 24             	mov    %eax,(%esp)
c010756d:	e8 cf fd ff ff       	call   c0107341 <__intr_restore>
}
c0107572:	c9                   	leave  
c0107573:	c3                   	ret    

c0107574 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0107574:	55                   	push   %ebp
c0107575:	89 e5                	mov    %esp,%ebp
c0107577:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c010757a:	e8 98 fd ff ff       	call   c0107317 <__intr_save>
c010757f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0107582:	a1 50 11 1a c0       	mov    0xc01a1150,%eax
c0107587:	8b 40 14             	mov    0x14(%eax),%eax
c010758a:	ff d0                	call   *%eax
c010758c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c010758f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107592:	89 04 24             	mov    %eax,(%esp)
c0107595:	e8 a7 fd ff ff       	call   c0107341 <__intr_restore>
    return ret;
c010759a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c010759d:	c9                   	leave  
c010759e:	c3                   	ret    

c010759f <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c010759f:	55                   	push   %ebp
c01075a0:	89 e5                	mov    %esp,%ebp
c01075a2:	57                   	push   %edi
c01075a3:	56                   	push   %esi
c01075a4:	53                   	push   %ebx
c01075a5:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c01075ab:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c01075b2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c01075b9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c01075c0:	c7 04 24 df d7 10 c0 	movl   $0xc010d7df,(%esp)
c01075c7:	e8 dd 8c ff ff       	call   c01002a9 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c01075cc:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01075d3:	e9 15 01 00 00       	jmp    c01076ed <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c01075d8:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01075db:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01075de:	89 d0                	mov    %edx,%eax
c01075e0:	c1 e0 02             	shl    $0x2,%eax
c01075e3:	01 d0                	add    %edx,%eax
c01075e5:	c1 e0 02             	shl    $0x2,%eax
c01075e8:	01 c8                	add    %ecx,%eax
c01075ea:	8b 50 08             	mov    0x8(%eax),%edx
c01075ed:	8b 40 04             	mov    0x4(%eax),%eax
c01075f0:	89 45 b8             	mov    %eax,-0x48(%ebp)
c01075f3:	89 55 bc             	mov    %edx,-0x44(%ebp)
c01075f6:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01075f9:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01075fc:	89 d0                	mov    %edx,%eax
c01075fe:	c1 e0 02             	shl    $0x2,%eax
c0107601:	01 d0                	add    %edx,%eax
c0107603:	c1 e0 02             	shl    $0x2,%eax
c0107606:	01 c8                	add    %ecx,%eax
c0107608:	8b 48 0c             	mov    0xc(%eax),%ecx
c010760b:	8b 58 10             	mov    0x10(%eax),%ebx
c010760e:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0107611:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0107614:	01 c8                	add    %ecx,%eax
c0107616:	11 da                	adc    %ebx,%edx
c0107618:	89 45 b0             	mov    %eax,-0x50(%ebp)
c010761b:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c010761e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0107621:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107624:	89 d0                	mov    %edx,%eax
c0107626:	c1 e0 02             	shl    $0x2,%eax
c0107629:	01 d0                	add    %edx,%eax
c010762b:	c1 e0 02             	shl    $0x2,%eax
c010762e:	01 c8                	add    %ecx,%eax
c0107630:	83 c0 14             	add    $0x14,%eax
c0107633:	8b 00                	mov    (%eax),%eax
c0107635:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c010763b:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010763e:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0107641:	83 c0 ff             	add    $0xffffffff,%eax
c0107644:	83 d2 ff             	adc    $0xffffffff,%edx
c0107647:	89 c6                	mov    %eax,%esi
c0107649:	89 d7                	mov    %edx,%edi
c010764b:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010764e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107651:	89 d0                	mov    %edx,%eax
c0107653:	c1 e0 02             	shl    $0x2,%eax
c0107656:	01 d0                	add    %edx,%eax
c0107658:	c1 e0 02             	shl    $0x2,%eax
c010765b:	01 c8                	add    %ecx,%eax
c010765d:	8b 48 0c             	mov    0xc(%eax),%ecx
c0107660:	8b 58 10             	mov    0x10(%eax),%ebx
c0107663:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0107669:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c010766d:	89 74 24 14          	mov    %esi,0x14(%esp)
c0107671:	89 7c 24 18          	mov    %edi,0x18(%esp)
c0107675:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0107678:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010767b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010767f:	89 54 24 10          	mov    %edx,0x10(%esp)
c0107683:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0107687:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c010768b:	c7 04 24 ec d7 10 c0 	movl   $0xc010d7ec,(%esp)
c0107692:	e8 12 8c ff ff       	call   c01002a9 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0107697:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010769a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010769d:	89 d0                	mov    %edx,%eax
c010769f:	c1 e0 02             	shl    $0x2,%eax
c01076a2:	01 d0                	add    %edx,%eax
c01076a4:	c1 e0 02             	shl    $0x2,%eax
c01076a7:	01 c8                	add    %ecx,%eax
c01076a9:	83 c0 14             	add    $0x14,%eax
c01076ac:	8b 00                	mov    (%eax),%eax
c01076ae:	83 f8 01             	cmp    $0x1,%eax
c01076b1:	75 36                	jne    c01076e9 <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
c01076b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01076b6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01076b9:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c01076bc:	77 2b                	ja     c01076e9 <page_init+0x14a>
c01076be:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c01076c1:	72 05                	jb     c01076c8 <page_init+0x129>
c01076c3:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c01076c6:	73 21                	jae    c01076e9 <page_init+0x14a>
c01076c8:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c01076cc:	77 1b                	ja     c01076e9 <page_init+0x14a>
c01076ce:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c01076d2:	72 09                	jb     c01076dd <page_init+0x13e>
c01076d4:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c01076db:	77 0c                	ja     c01076e9 <page_init+0x14a>
                maxpa = end;
c01076dd:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01076e0:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01076e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01076e6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
c01076e9:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c01076ed:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01076f0:	8b 00                	mov    (%eax),%eax
c01076f2:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c01076f5:	0f 8f dd fe ff ff    	jg     c01075d8 <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c01076fb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01076ff:	72 1d                	jb     c010771e <page_init+0x17f>
c0107701:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0107705:	77 09                	ja     c0107710 <page_init+0x171>
c0107707:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c010770e:	76 0e                	jbe    c010771e <page_init+0x17f>
        maxpa = KMEMSIZE;
c0107710:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0107717:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c010771e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107721:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107724:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0107728:	c1 ea 0c             	shr    $0xc,%edx
c010772b:	a3 80 ef 19 c0       	mov    %eax,0xc019ef80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0107730:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c0107737:	b8 64 11 1a c0       	mov    $0xc01a1164,%eax
c010773c:	8d 50 ff             	lea    -0x1(%eax),%edx
c010773f:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0107742:	01 d0                	add    %edx,%eax
c0107744:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0107747:	8b 45 a8             	mov    -0x58(%ebp),%eax
c010774a:	ba 00 00 00 00       	mov    $0x0,%edx
c010774f:	f7 75 ac             	divl   -0x54(%ebp)
c0107752:	89 d0                	mov    %edx,%eax
c0107754:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0107757:	29 c2                	sub    %eax,%edx
c0107759:	89 d0                	mov    %edx,%eax
c010775b:	a3 58 11 1a c0       	mov    %eax,0xc01a1158

    for (i = 0; i < npage; i ++) {
c0107760:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0107767:	eb 27                	jmp    c0107790 <page_init+0x1f1>
        SetPageReserved(pages + i);
c0107769:	a1 58 11 1a c0       	mov    0xc01a1158,%eax
c010776e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107771:	c1 e2 05             	shl    $0x5,%edx
c0107774:	01 d0                	add    %edx,%eax
c0107776:	83 c0 04             	add    $0x4,%eax
c0107779:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c0107780:	89 45 8c             	mov    %eax,-0x74(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0107783:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0107786:	8b 55 90             	mov    -0x70(%ebp),%edx
c0107789:	0f ab 10             	bts    %edx,(%eax)
    for (i = 0; i < npage; i ++) {
c010778c:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0107790:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107793:	a1 80 ef 19 c0       	mov    0xc019ef80,%eax
c0107798:	39 c2                	cmp    %eax,%edx
c010779a:	72 cd                	jb     c0107769 <page_init+0x1ca>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c010779c:	a1 80 ef 19 c0       	mov    0xc019ef80,%eax
c01077a1:	c1 e0 05             	shl    $0x5,%eax
c01077a4:	89 c2                	mov    %eax,%edx
c01077a6:	a1 58 11 1a c0       	mov    0xc01a1158,%eax
c01077ab:	01 d0                	add    %edx,%eax
c01077ad:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c01077b0:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c01077b7:	77 23                	ja     c01077dc <page_init+0x23d>
c01077b9:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01077bc:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01077c0:	c7 44 24 08 1c d8 10 	movl   $0xc010d81c,0x8(%esp)
c01077c7:	c0 
c01077c8:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
c01077cf:	00 
c01077d0:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c01077d7:	e8 24 8c ff ff       	call   c0100400 <__panic>
c01077dc:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01077df:	05 00 00 00 40       	add    $0x40000000,%eax
c01077e4:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c01077e7:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01077ee:	e9 74 01 00 00       	jmp    c0107967 <page_init+0x3c8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c01077f3:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01077f6:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01077f9:	89 d0                	mov    %edx,%eax
c01077fb:	c1 e0 02             	shl    $0x2,%eax
c01077fe:	01 d0                	add    %edx,%eax
c0107800:	c1 e0 02             	shl    $0x2,%eax
c0107803:	01 c8                	add    %ecx,%eax
c0107805:	8b 50 08             	mov    0x8(%eax),%edx
c0107808:	8b 40 04             	mov    0x4(%eax),%eax
c010780b:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010780e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0107811:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0107814:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107817:	89 d0                	mov    %edx,%eax
c0107819:	c1 e0 02             	shl    $0x2,%eax
c010781c:	01 d0                	add    %edx,%eax
c010781e:	c1 e0 02             	shl    $0x2,%eax
c0107821:	01 c8                	add    %ecx,%eax
c0107823:	8b 48 0c             	mov    0xc(%eax),%ecx
c0107826:	8b 58 10             	mov    0x10(%eax),%ebx
c0107829:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010782c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010782f:	01 c8                	add    %ecx,%eax
c0107831:	11 da                	adc    %ebx,%edx
c0107833:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0107836:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0107839:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010783c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010783f:	89 d0                	mov    %edx,%eax
c0107841:	c1 e0 02             	shl    $0x2,%eax
c0107844:	01 d0                	add    %edx,%eax
c0107846:	c1 e0 02             	shl    $0x2,%eax
c0107849:	01 c8                	add    %ecx,%eax
c010784b:	83 c0 14             	add    $0x14,%eax
c010784e:	8b 00                	mov    (%eax),%eax
c0107850:	83 f8 01             	cmp    $0x1,%eax
c0107853:	0f 85 0a 01 00 00    	jne    c0107963 <page_init+0x3c4>
            if (begin < freemem) {
c0107859:	8b 45 a0             	mov    -0x60(%ebp),%eax
c010785c:	ba 00 00 00 00       	mov    $0x0,%edx
c0107861:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0107864:	72 17                	jb     c010787d <page_init+0x2de>
c0107866:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0107869:	77 05                	ja     c0107870 <page_init+0x2d1>
c010786b:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c010786e:	76 0d                	jbe    c010787d <page_init+0x2de>
                begin = freemem;
c0107870:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0107873:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0107876:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c010787d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0107881:	72 1d                	jb     c01078a0 <page_init+0x301>
c0107883:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0107887:	77 09                	ja     c0107892 <page_init+0x2f3>
c0107889:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c0107890:	76 0e                	jbe    c01078a0 <page_init+0x301>
                end = KMEMSIZE;
c0107892:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0107899:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c01078a0:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01078a3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01078a6:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01078a9:	0f 87 b4 00 00 00    	ja     c0107963 <page_init+0x3c4>
c01078af:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01078b2:	72 09                	jb     c01078bd <page_init+0x31e>
c01078b4:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c01078b7:	0f 83 a6 00 00 00    	jae    c0107963 <page_init+0x3c4>
                begin = ROUNDUP(begin, PGSIZE);
c01078bd:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c01078c4:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01078c7:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01078ca:	01 d0                	add    %edx,%eax
c01078cc:	83 e8 01             	sub    $0x1,%eax
c01078cf:	89 45 98             	mov    %eax,-0x68(%ebp)
c01078d2:	8b 45 98             	mov    -0x68(%ebp),%eax
c01078d5:	ba 00 00 00 00       	mov    $0x0,%edx
c01078da:	f7 75 9c             	divl   -0x64(%ebp)
c01078dd:	89 d0                	mov    %edx,%eax
c01078df:	8b 55 98             	mov    -0x68(%ebp),%edx
c01078e2:	29 c2                	sub    %eax,%edx
c01078e4:	89 d0                	mov    %edx,%eax
c01078e6:	ba 00 00 00 00       	mov    $0x0,%edx
c01078eb:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01078ee:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c01078f1:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01078f4:	89 45 94             	mov    %eax,-0x6c(%ebp)
c01078f7:	8b 45 94             	mov    -0x6c(%ebp),%eax
c01078fa:	ba 00 00 00 00       	mov    $0x0,%edx
c01078ff:	89 c7                	mov    %eax,%edi
c0107901:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c0107907:	89 7d 80             	mov    %edi,-0x80(%ebp)
c010790a:	89 d0                	mov    %edx,%eax
c010790c:	83 e0 00             	and    $0x0,%eax
c010790f:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0107912:	8b 45 80             	mov    -0x80(%ebp),%eax
c0107915:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0107918:	89 45 c8             	mov    %eax,-0x38(%ebp)
c010791b:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c010791e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107921:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107924:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0107927:	77 3a                	ja     c0107963 <page_init+0x3c4>
c0107929:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c010792c:	72 05                	jb     c0107933 <page_init+0x394>
c010792e:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0107931:	73 30                	jae    c0107963 <page_init+0x3c4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0107933:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c0107936:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
c0107939:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010793c:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010793f:	29 c8                	sub    %ecx,%eax
c0107941:	19 da                	sbb    %ebx,%edx
c0107943:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0107947:	c1 ea 0c             	shr    $0xc,%edx
c010794a:	89 c3                	mov    %eax,%ebx
c010794c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010794f:	89 04 24             	mov    %eax,(%esp)
c0107952:	e8 8c f8 ff ff       	call   c01071e3 <pa2page>
c0107957:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c010795b:	89 04 24             	mov    %eax,(%esp)
c010795e:	e8 55 fb ff ff       	call   c01074b8 <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
c0107963:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0107967:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010796a:	8b 00                	mov    (%eax),%eax
c010796c:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c010796f:	0f 8f 7e fe ff ff    	jg     c01077f3 <page_init+0x254>
                }
            }
        }
    }
}
c0107975:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c010797b:	5b                   	pop    %ebx
c010797c:	5e                   	pop    %esi
c010797d:	5f                   	pop    %edi
c010797e:	5d                   	pop    %ebp
c010797f:	c3                   	ret    

c0107980 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c0107980:	55                   	push   %ebp
c0107981:	89 e5                	mov    %esp,%ebp
c0107983:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0107986:	8b 45 14             	mov    0x14(%ebp),%eax
c0107989:	8b 55 0c             	mov    0xc(%ebp),%edx
c010798c:	31 d0                	xor    %edx,%eax
c010798e:	25 ff 0f 00 00       	and    $0xfff,%eax
c0107993:	85 c0                	test   %eax,%eax
c0107995:	74 24                	je     c01079bb <boot_map_segment+0x3b>
c0107997:	c7 44 24 0c 4e d8 10 	movl   $0xc010d84e,0xc(%esp)
c010799e:	c0 
c010799f:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c01079a6:	c0 
c01079a7:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
c01079ae:	00 
c01079af:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c01079b6:	e8 45 8a ff ff       	call   c0100400 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c01079bb:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c01079c2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01079c5:	25 ff 0f 00 00       	and    $0xfff,%eax
c01079ca:	89 c2                	mov    %eax,%edx
c01079cc:	8b 45 10             	mov    0x10(%ebp),%eax
c01079cf:	01 c2                	add    %eax,%edx
c01079d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01079d4:	01 d0                	add    %edx,%eax
c01079d6:	83 e8 01             	sub    $0x1,%eax
c01079d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01079dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01079df:	ba 00 00 00 00       	mov    $0x0,%edx
c01079e4:	f7 75 f0             	divl   -0x10(%ebp)
c01079e7:	89 d0                	mov    %edx,%eax
c01079e9:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01079ec:	29 c2                	sub    %eax,%edx
c01079ee:	89 d0                	mov    %edx,%eax
c01079f0:	c1 e8 0c             	shr    $0xc,%eax
c01079f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c01079f6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01079f9:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01079fc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01079ff:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107a04:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c0107a07:	8b 45 14             	mov    0x14(%ebp),%eax
c0107a0a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107a0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107a10:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107a15:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0107a18:	eb 6b                	jmp    c0107a85 <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
c0107a1a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0107a21:	00 
c0107a22:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107a25:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107a29:	8b 45 08             	mov    0x8(%ebp),%eax
c0107a2c:	89 04 24             	mov    %eax,(%esp)
c0107a2f:	e8 87 01 00 00       	call   c0107bbb <get_pte>
c0107a34:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0107a37:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0107a3b:	75 24                	jne    c0107a61 <boot_map_segment+0xe1>
c0107a3d:	c7 44 24 0c 7a d8 10 	movl   $0xc010d87a,0xc(%esp)
c0107a44:	c0 
c0107a45:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c0107a4c:	c0 
c0107a4d:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
c0107a54:	00 
c0107a55:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c0107a5c:	e8 9f 89 ff ff       	call   c0100400 <__panic>
        *ptep = pa | PTE_P | perm;
c0107a61:	8b 45 18             	mov    0x18(%ebp),%eax
c0107a64:	8b 55 14             	mov    0x14(%ebp),%edx
c0107a67:	09 d0                	or     %edx,%eax
c0107a69:	83 c8 01             	or     $0x1,%eax
c0107a6c:	89 c2                	mov    %eax,%edx
c0107a6e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107a71:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0107a73:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0107a77:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c0107a7e:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0107a85:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107a89:	75 8f                	jne    c0107a1a <boot_map_segment+0x9a>
    }
}
c0107a8b:	c9                   	leave  
c0107a8c:	c3                   	ret    

c0107a8d <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c0107a8d:	55                   	push   %ebp
c0107a8e:	89 e5                	mov    %esp,%ebp
c0107a90:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c0107a93:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107a9a:	e8 38 fa ff ff       	call   c01074d7 <alloc_pages>
c0107a9f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0107aa2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107aa6:	75 1c                	jne    c0107ac4 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c0107aa8:	c7 44 24 08 87 d8 10 	movl   $0xc010d887,0x8(%esp)
c0107aaf:	c0 
c0107ab0:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c0107ab7:	00 
c0107ab8:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c0107abf:	e8 3c 89 ff ff       	call   c0100400 <__panic>
    }
    return page2kva(p);
c0107ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107ac7:	89 04 24             	mov    %eax,(%esp)
c0107aca:	e8 59 f7 ff ff       	call   c0107228 <page2kva>
}
c0107acf:	c9                   	leave  
c0107ad0:	c3                   	ret    

c0107ad1 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c0107ad1:	55                   	push   %ebp
c0107ad2:	89 e5                	mov    %esp,%ebp
c0107ad4:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c0107ad7:	a1 20 aa 12 c0       	mov    0xc012aa20,%eax
c0107adc:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107adf:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0107ae6:	77 23                	ja     c0107b0b <pmm_init+0x3a>
c0107ae8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107aeb:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107aef:	c7 44 24 08 1c d8 10 	movl   $0xc010d81c,0x8(%esp)
c0107af6:	c0 
c0107af7:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
c0107afe:	00 
c0107aff:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c0107b06:	e8 f5 88 ff ff       	call   c0100400 <__panic>
c0107b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107b0e:	05 00 00 00 40       	add    $0x40000000,%eax
c0107b13:	a3 54 11 1a c0       	mov    %eax,0xc01a1154
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0107b18:	e8 68 f9 ff ff       	call   c0107485 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c0107b1d:	e8 7d fa ff ff       	call   c010759f <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0107b22:	e8 d8 08 00 00       	call   c01083ff <check_alloc_page>

    check_pgdir();
c0107b27:	e8 f1 08 00 00       	call   c010841d <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0107b2c:	a1 20 aa 12 c0       	mov    0xc012aa20,%eax
c0107b31:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c0107b37:	a1 20 aa 12 c0       	mov    0xc012aa20,%eax
c0107b3c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107b3f:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0107b46:	77 23                	ja     c0107b6b <pmm_init+0x9a>
c0107b48:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107b4b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107b4f:	c7 44 24 08 1c d8 10 	movl   $0xc010d81c,0x8(%esp)
c0107b56:	c0 
c0107b57:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
c0107b5e:	00 
c0107b5f:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c0107b66:	e8 95 88 ff ff       	call   c0100400 <__panic>
c0107b6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107b6e:	05 00 00 00 40       	add    $0x40000000,%eax
c0107b73:	83 c8 03             	or     $0x3,%eax
c0107b76:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0107b78:	a1 20 aa 12 c0       	mov    0xc012aa20,%eax
c0107b7d:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c0107b84:	00 
c0107b85:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0107b8c:	00 
c0107b8d:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c0107b94:	38 
c0107b95:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c0107b9c:	c0 
c0107b9d:	89 04 24             	mov    %eax,(%esp)
c0107ba0:	e8 db fd ff ff       	call   c0107980 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0107ba5:	e8 ec f7 ff ff       	call   c0107396 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0107baa:	e8 09 0f 00 00       	call   c0108ab8 <check_boot_pgdir>

    print_pgdir();
c0107baf:	e8 91 13 00 00       	call   c0108f45 <print_pgdir>
    
    kmalloc_init();
c0107bb4:	e8 f9 d5 ff ff       	call   c01051b2 <kmalloc_init>

}
c0107bb9:	c9                   	leave  
c0107bba:	c3                   	ret    

c0107bbb <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c0107bbb:	55                   	push   %ebp
c0107bbc:	89 e5                	mov    %esp,%ebp
c0107bbe:	83 ec 38             	sub    $0x38,%esp
     pde_t *pdep = &pgdir[PDX(la)];
c0107bc1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107bc4:	c1 e8 16             	shr    $0x16,%eax
c0107bc7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0107bce:	8b 45 08             	mov    0x8(%ebp),%eax
c0107bd1:	01 d0                	add    %edx,%eax
c0107bd3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    //获取一级页表项对应的入口地址
    if (!(*pdep & PTE_P)) {
c0107bd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107bd9:	8b 00                	mov    (%eax),%eax
c0107bdb:	83 e0 01             	and    $0x1,%eax
c0107bde:	85 c0                	test   %eax,%eax
c0107be0:	0f 85 af 00 00 00    	jne    c0107c95 <get_pte+0xda>
        //物理页不存在, create==0, null
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {//分配失败
c0107be6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0107bea:	74 15                	je     c0107c01 <get_pte+0x46>
c0107bec:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107bf3:	e8 df f8 ff ff       	call   c01074d7 <alloc_pages>
c0107bf8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107bfb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107bff:	75 0a                	jne    c0107c0b <get_pte+0x50>
            return NULL;
c0107c01:	b8 00 00 00 00       	mov    $0x0,%eax
c0107c06:	e9 e6 00 00 00       	jmp    c0107cf1 <get_pte+0x136>
        }
        //引用次数+1
        set_page_ref(page, 1);
c0107c0b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107c12:	00 
c0107c13:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107c16:	89 04 24             	mov    %eax,(%esp)
c0107c19:	e8 be f6 ff ff       	call   c01072dc <set_page_ref>
        //物理地址
        uintptr_t pa = page2pa(page);
c0107c1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107c21:	89 04 24             	mov    %eax,(%esp)
c0107c24:	e8 a4 f5 ff ff       	call   c01071cd <page2pa>
c0107c29:	89 45 ec             	mov    %eax,-0x14(%ebp)
        ///物理地址转虚拟地址，并初始化,把新申请的数目为pgsize个页全设为0	
        memset(KADDR(pa), 0, PGSIZE);
c0107c2c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107c2f:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107c32:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107c35:	c1 e8 0c             	shr    $0xc,%eax
c0107c38:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107c3b:	a1 80 ef 19 c0       	mov    0xc019ef80,%eax
c0107c40:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0107c43:	72 23                	jb     c0107c68 <get_pte+0xad>
c0107c45:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107c48:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107c4c:	c7 44 24 08 78 d7 10 	movl   $0xc010d778,0x8(%esp)
c0107c53:	c0 
c0107c54:	c7 44 24 04 66 01 00 	movl   $0x166,0x4(%esp)
c0107c5b:	00 
c0107c5c:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c0107c63:	e8 98 87 ff ff       	call   c0100400 <__panic>
c0107c68:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107c6b:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0107c70:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0107c77:	00 
c0107c78:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0107c7f:	00 
c0107c80:	89 04 24             	mov    %eax,(%esp)
c0107c83:	e8 ca 38 00 00       	call   c010b552 <memset>
        //设置控制位
        *pdep = pa | PTE_U | PTE_W | PTE_P;
c0107c88:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107c8b:	83 c8 07             	or     $0x7,%eax
c0107c8e:	89 c2                	mov    %eax,%edx
c0107c90:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107c93:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c0107c95:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107c98:	8b 00                	mov    (%eax),%eax
c0107c9a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107c9f:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0107ca2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107ca5:	c1 e8 0c             	shr    $0xc,%eax
c0107ca8:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0107cab:	a1 80 ef 19 c0       	mov    0xc019ef80,%eax
c0107cb0:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0107cb3:	72 23                	jb     c0107cd8 <get_pte+0x11d>
c0107cb5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107cb8:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107cbc:	c7 44 24 08 78 d7 10 	movl   $0xc010d778,0x8(%esp)
c0107cc3:	c0 
c0107cc4:	c7 44 24 04 6a 01 00 	movl   $0x16a,0x4(%esp)
c0107ccb:	00 
c0107ccc:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c0107cd3:	e8 28 87 ff ff       	call   c0100400 <__panic>
c0107cd8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107cdb:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0107ce0:	8b 55 0c             	mov    0xc(%ebp),%edx
c0107ce3:	c1 ea 0c             	shr    $0xc,%edx
c0107ce6:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
c0107cec:	c1 e2 02             	shl    $0x2,%edx
c0107cef:	01 d0                	add    %edx,%eax
    //页目录项地址-->>页表物理地址-->>虚拟地址-->>页表项索引
    //PTX(la)：返回虚拟地址la的页表项索引
    //返回la对应的页表项入口地址
}
c0107cf1:	c9                   	leave  
c0107cf2:	c3                   	ret    

c0107cf3 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c0107cf3:	55                   	push   %ebp
c0107cf4:	89 e5                	mov    %esp,%ebp
c0107cf6:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0107cf9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107d00:	00 
c0107d01:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107d04:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107d08:	8b 45 08             	mov    0x8(%ebp),%eax
c0107d0b:	89 04 24             	mov    %eax,(%esp)
c0107d0e:	e8 a8 fe ff ff       	call   c0107bbb <get_pte>
c0107d13:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c0107d16:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0107d1a:	74 08                	je     c0107d24 <get_page+0x31>
        *ptep_store = ptep;
c0107d1c:	8b 45 10             	mov    0x10(%ebp),%eax
c0107d1f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107d22:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0107d24:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107d28:	74 1b                	je     c0107d45 <get_page+0x52>
c0107d2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107d2d:	8b 00                	mov    (%eax),%eax
c0107d2f:	83 e0 01             	and    $0x1,%eax
c0107d32:	85 c0                	test   %eax,%eax
c0107d34:	74 0f                	je     c0107d45 <get_page+0x52>
        return pte2page(*ptep);
c0107d36:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107d39:	8b 00                	mov    (%eax),%eax
c0107d3b:	89 04 24             	mov    %eax,(%esp)
c0107d3e:	e8 39 f5 ff ff       	call   c010727c <pte2page>
c0107d43:	eb 05                	jmp    c0107d4a <get_page+0x57>
    }
    return NULL;
c0107d45:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107d4a:	c9                   	leave  
c0107d4b:	c3                   	ret    

c0107d4c <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0107d4c:	55                   	push   %ebp
c0107d4d:	89 e5                	mov    %esp,%ebp
c0107d4f:	83 ec 28             	sub    $0x28,%esp
    if (*ptep & PTE_P) {
c0107d52:	8b 45 10             	mov    0x10(%ebp),%eax
c0107d55:	8b 00                	mov    (%eax),%eax
c0107d57:	83 e0 01             	and    $0x1,%eax
c0107d5a:	85 c0                	test   %eax,%eax
c0107d5c:	74 53                	je     c0107db1 <page_remove_pte+0x65>
        //判断页表中该表项是否存在
        struct Page *page = pte2page(*ptep);//获得相应的page
c0107d5e:	8b 45 10             	mov    0x10(%ebp),%eax
c0107d61:	8b 00                	mov    (%eax),%eax
c0107d63:	89 04 24             	mov    %eax,(%esp)
c0107d66:	e8 11 f5 ff ff       	call   c010727c <pte2page>
c0107d6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
c0107d6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107d71:	89 04 24             	mov    %eax,(%esp)
c0107d74:	e8 87 f5 ff ff       	call   c0107300 <page_ref_dec>
c0107d79:	85 c0                	test   %eax,%eax
c0107d7b:	75 13                	jne    c0107d90 <page_remove_pte+0x44>
            ////除了当前进程，没有别的进程引用
            free_page(page);
c0107d7d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107d84:	00 
c0107d85:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107d88:	89 04 24             	mov    %eax,(%esp)
c0107d8b:	e8 b2 f7 ff ff       	call   c0107542 <free_pages>
        }
        *ptep &= (~PTE_P); 
c0107d90:	8b 45 10             	mov    0x10(%ebp),%eax
c0107d93:	8b 00                	mov    (%eax),%eax
c0107d95:	83 e0 fe             	and    $0xfffffffe,%eax
c0107d98:	89 c2                	mov    %eax,%edx
c0107d9a:	8b 45 10             	mov    0x10(%ebp),%eax
c0107d9d:	89 10                	mov    %edx,(%eax)
        // 将PTE的存在位设置为0，表示该映射关系无效
        tlb_invalidate(pgdir, la);
c0107d9f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107da2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107da6:	8b 45 08             	mov    0x8(%ebp),%eax
c0107da9:	89 04 24             	mov    %eax,(%esp)
c0107dac:	e8 1d 05 00 00       	call   c01082ce <tlb_invalidate>
         //刷新TLB
    }
}
c0107db1:	c9                   	leave  
c0107db2:	c3                   	ret    

c0107db3 <unmap_range>:

void
unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
c0107db3:	55                   	push   %ebp
c0107db4:	89 e5                	mov    %esp,%ebp
c0107db6:	83 ec 28             	sub    $0x28,%esp
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
c0107db9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107dbc:	25 ff 0f 00 00       	and    $0xfff,%eax
c0107dc1:	85 c0                	test   %eax,%eax
c0107dc3:	75 0c                	jne    c0107dd1 <unmap_range+0x1e>
c0107dc5:	8b 45 10             	mov    0x10(%ebp),%eax
c0107dc8:	25 ff 0f 00 00       	and    $0xfff,%eax
c0107dcd:	85 c0                	test   %eax,%eax
c0107dcf:	74 24                	je     c0107df5 <unmap_range+0x42>
c0107dd1:	c7 44 24 0c a0 d8 10 	movl   $0xc010d8a0,0xc(%esp)
c0107dd8:	c0 
c0107dd9:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c0107de0:	c0 
c0107de1:	c7 44 24 04 92 01 00 	movl   $0x192,0x4(%esp)
c0107de8:	00 
c0107de9:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c0107df0:	e8 0b 86 ff ff       	call   c0100400 <__panic>
    assert(USER_ACCESS(start, end));
c0107df5:	81 7d 0c ff ff 1f 00 	cmpl   $0x1fffff,0xc(%ebp)
c0107dfc:	76 11                	jbe    c0107e0f <unmap_range+0x5c>
c0107dfe:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107e01:	3b 45 10             	cmp    0x10(%ebp),%eax
c0107e04:	73 09                	jae    c0107e0f <unmap_range+0x5c>
c0107e06:	81 7d 10 00 00 00 b0 	cmpl   $0xb0000000,0x10(%ebp)
c0107e0d:	76 24                	jbe    c0107e33 <unmap_range+0x80>
c0107e0f:	c7 44 24 0c c9 d8 10 	movl   $0xc010d8c9,0xc(%esp)
c0107e16:	c0 
c0107e17:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c0107e1e:	c0 
c0107e1f:	c7 44 24 04 93 01 00 	movl   $0x193,0x4(%esp)
c0107e26:	00 
c0107e27:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c0107e2e:	e8 cd 85 ff ff       	call   c0100400 <__panic>

    do {
        pte_t *ptep = get_pte(pgdir, start, 0);
c0107e33:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107e3a:	00 
c0107e3b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107e3e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107e42:	8b 45 08             	mov    0x8(%ebp),%eax
c0107e45:	89 04 24             	mov    %eax,(%esp)
c0107e48:	e8 6e fd ff ff       	call   c0107bbb <get_pte>
c0107e4d:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (ptep == NULL) {
c0107e50:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107e54:	75 18                	jne    c0107e6e <unmap_range+0xbb>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
c0107e56:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107e59:	05 00 00 40 00       	add    $0x400000,%eax
c0107e5e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107e61:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107e64:	25 00 00 c0 ff       	and    $0xffc00000,%eax
c0107e69:	89 45 0c             	mov    %eax,0xc(%ebp)
            continue ;
c0107e6c:	eb 29                	jmp    c0107e97 <unmap_range+0xe4>
        }
        if (*ptep != 0) {
c0107e6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107e71:	8b 00                	mov    (%eax),%eax
c0107e73:	85 c0                	test   %eax,%eax
c0107e75:	74 19                	je     c0107e90 <unmap_range+0xdd>
            page_remove_pte(pgdir, start, ptep);
c0107e77:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107e7a:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107e7e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107e81:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107e85:	8b 45 08             	mov    0x8(%ebp),%eax
c0107e88:	89 04 24             	mov    %eax,(%esp)
c0107e8b:	e8 bc fe ff ff       	call   c0107d4c <page_remove_pte>
        }
        start += PGSIZE;
c0107e90:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
    } while (start != 0 && start < end);
c0107e97:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0107e9b:	74 08                	je     c0107ea5 <unmap_range+0xf2>
c0107e9d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107ea0:	3b 45 10             	cmp    0x10(%ebp),%eax
c0107ea3:	72 8e                	jb     c0107e33 <unmap_range+0x80>
}
c0107ea5:	c9                   	leave  
c0107ea6:	c3                   	ret    

c0107ea7 <exit_range>:

void
exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
c0107ea7:	55                   	push   %ebp
c0107ea8:	89 e5                	mov    %esp,%ebp
c0107eaa:	83 ec 28             	sub    $0x28,%esp
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
c0107ead:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107eb0:	25 ff 0f 00 00       	and    $0xfff,%eax
c0107eb5:	85 c0                	test   %eax,%eax
c0107eb7:	75 0c                	jne    c0107ec5 <exit_range+0x1e>
c0107eb9:	8b 45 10             	mov    0x10(%ebp),%eax
c0107ebc:	25 ff 0f 00 00       	and    $0xfff,%eax
c0107ec1:	85 c0                	test   %eax,%eax
c0107ec3:	74 24                	je     c0107ee9 <exit_range+0x42>
c0107ec5:	c7 44 24 0c a0 d8 10 	movl   $0xc010d8a0,0xc(%esp)
c0107ecc:	c0 
c0107ecd:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c0107ed4:	c0 
c0107ed5:	c7 44 24 04 a4 01 00 	movl   $0x1a4,0x4(%esp)
c0107edc:	00 
c0107edd:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c0107ee4:	e8 17 85 ff ff       	call   c0100400 <__panic>
    assert(USER_ACCESS(start, end));
c0107ee9:	81 7d 0c ff ff 1f 00 	cmpl   $0x1fffff,0xc(%ebp)
c0107ef0:	76 11                	jbe    c0107f03 <exit_range+0x5c>
c0107ef2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107ef5:	3b 45 10             	cmp    0x10(%ebp),%eax
c0107ef8:	73 09                	jae    c0107f03 <exit_range+0x5c>
c0107efa:	81 7d 10 00 00 00 b0 	cmpl   $0xb0000000,0x10(%ebp)
c0107f01:	76 24                	jbe    c0107f27 <exit_range+0x80>
c0107f03:	c7 44 24 0c c9 d8 10 	movl   $0xc010d8c9,0xc(%esp)
c0107f0a:	c0 
c0107f0b:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c0107f12:	c0 
c0107f13:	c7 44 24 04 a5 01 00 	movl   $0x1a5,0x4(%esp)
c0107f1a:	00 
c0107f1b:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c0107f22:	e8 d9 84 ff ff       	call   c0100400 <__panic>

    start = ROUNDDOWN(start, PTSIZE);
c0107f27:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107f2a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107f2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f30:	25 00 00 c0 ff       	and    $0xffc00000,%eax
c0107f35:	89 45 0c             	mov    %eax,0xc(%ebp)
    do {
        int pde_idx = PDX(start);
c0107f38:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107f3b:	c1 e8 16             	shr    $0x16,%eax
c0107f3e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (pgdir[pde_idx] & PTE_P) {
c0107f41:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107f44:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0107f4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0107f4e:	01 d0                	add    %edx,%eax
c0107f50:	8b 00                	mov    (%eax),%eax
c0107f52:	83 e0 01             	and    $0x1,%eax
c0107f55:	85 c0                	test   %eax,%eax
c0107f57:	74 3e                	je     c0107f97 <exit_range+0xf0>
            free_page(pde2page(pgdir[pde_idx]));
c0107f59:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107f5c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0107f63:	8b 45 08             	mov    0x8(%ebp),%eax
c0107f66:	01 d0                	add    %edx,%eax
c0107f68:	8b 00                	mov    (%eax),%eax
c0107f6a:	89 04 24             	mov    %eax,(%esp)
c0107f6d:	e8 48 f3 ff ff       	call   c01072ba <pde2page>
c0107f72:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107f79:	00 
c0107f7a:	89 04 24             	mov    %eax,(%esp)
c0107f7d:	e8 c0 f5 ff ff       	call   c0107542 <free_pages>
            pgdir[pde_idx] = 0;
c0107f82:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107f85:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0107f8c:	8b 45 08             	mov    0x8(%ebp),%eax
c0107f8f:	01 d0                	add    %edx,%eax
c0107f91:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        }
        start += PTSIZE;
c0107f97:	81 45 0c 00 00 40 00 	addl   $0x400000,0xc(%ebp)
    } while (start != 0 && start < end);
c0107f9e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0107fa2:	74 08                	je     c0107fac <exit_range+0x105>
c0107fa4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107fa7:	3b 45 10             	cmp    0x10(%ebp),%eax
c0107faa:	72 8c                	jb     c0107f38 <exit_range+0x91>
}
c0107fac:	c9                   	leave  
c0107fad:	c3                   	ret    

c0107fae <copy_range>:
 * @share: flags to indicate to dup OR share. We just use dup method, so it didn't be used.
 *
 * CALL GRAPH: copy_mm-->dup_mmap-->copy_range
 */
int
copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end, bool share) {
c0107fae:	55                   	push   %ebp
c0107faf:	89 e5                	mov    %esp,%ebp
c0107fb1:	83 ec 48             	sub    $0x48,%esp
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
c0107fb4:	8b 45 10             	mov    0x10(%ebp),%eax
c0107fb7:	25 ff 0f 00 00       	and    $0xfff,%eax
c0107fbc:	85 c0                	test   %eax,%eax
c0107fbe:	75 0c                	jne    c0107fcc <copy_range+0x1e>
c0107fc0:	8b 45 14             	mov    0x14(%ebp),%eax
c0107fc3:	25 ff 0f 00 00       	and    $0xfff,%eax
c0107fc8:	85 c0                	test   %eax,%eax
c0107fca:	74 24                	je     c0107ff0 <copy_range+0x42>
c0107fcc:	c7 44 24 0c a0 d8 10 	movl   $0xc010d8a0,0xc(%esp)
c0107fd3:	c0 
c0107fd4:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c0107fdb:	c0 
c0107fdc:	c7 44 24 04 ba 01 00 	movl   $0x1ba,0x4(%esp)
c0107fe3:	00 
c0107fe4:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c0107feb:	e8 10 84 ff ff       	call   c0100400 <__panic>
    assert(USER_ACCESS(start, end));
c0107ff0:	81 7d 10 ff ff 1f 00 	cmpl   $0x1fffff,0x10(%ebp)
c0107ff7:	76 11                	jbe    c010800a <copy_range+0x5c>
c0107ff9:	8b 45 10             	mov    0x10(%ebp),%eax
c0107ffc:	3b 45 14             	cmp    0x14(%ebp),%eax
c0107fff:	73 09                	jae    c010800a <copy_range+0x5c>
c0108001:	81 7d 14 00 00 00 b0 	cmpl   $0xb0000000,0x14(%ebp)
c0108008:	76 24                	jbe    c010802e <copy_range+0x80>
c010800a:	c7 44 24 0c c9 d8 10 	movl   $0xc010d8c9,0xc(%esp)
c0108011:	c0 
c0108012:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c0108019:	c0 
c010801a:	c7 44 24 04 bb 01 00 	movl   $0x1bb,0x4(%esp)
c0108021:	00 
c0108022:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c0108029:	e8 d2 83 ff ff       	call   c0100400 <__panic>
    // copy content by page unit.
    do {
        //call get_pte to find process A's pte according to the addr start
        pte_t *ptep = get_pte(from, start, 0), *nptep;
c010802e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0108035:	00 
c0108036:	8b 45 10             	mov    0x10(%ebp),%eax
c0108039:	89 44 24 04          	mov    %eax,0x4(%esp)
c010803d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108040:	89 04 24             	mov    %eax,(%esp)
c0108043:	e8 73 fb ff ff       	call   c0107bbb <get_pte>
c0108048:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (ptep == NULL) {
c010804b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010804f:	75 1b                	jne    c010806c <copy_range+0xbe>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
c0108051:	8b 45 10             	mov    0x10(%ebp),%eax
c0108054:	05 00 00 40 00       	add    $0x400000,%eax
c0108059:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010805c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010805f:	25 00 00 c0 ff       	and    $0xffc00000,%eax
c0108064:	89 45 10             	mov    %eax,0x10(%ebp)
            continue ;
c0108067:	e9 4c 01 00 00       	jmp    c01081b8 <copy_range+0x20a>
        }
        //call get_pte to find process B's pte according to the addr start. If pte is NULL, just alloc a PT
        if (*ptep & PTE_P) {
c010806c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010806f:	8b 00                	mov    (%eax),%eax
c0108071:	83 e0 01             	and    $0x1,%eax
c0108074:	85 c0                	test   %eax,%eax
c0108076:	0f 84 35 01 00 00    	je     c01081b1 <copy_range+0x203>
            if ((nptep = get_pte(to, start, 1)) == NULL) {
c010807c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0108083:	00 
c0108084:	8b 45 10             	mov    0x10(%ebp),%eax
c0108087:	89 44 24 04          	mov    %eax,0x4(%esp)
c010808b:	8b 45 08             	mov    0x8(%ebp),%eax
c010808e:	89 04 24             	mov    %eax,(%esp)
c0108091:	e8 25 fb ff ff       	call   c0107bbb <get_pte>
c0108096:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108099:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010809d:	75 0a                	jne    c01080a9 <copy_range+0xfb>
                return -E_NO_MEM;
c010809f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c01080a4:	e9 26 01 00 00       	jmp    c01081cf <copy_range+0x221>
            }
        uint32_t perm = (*ptep & PTE_USER);
c01080a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01080ac:	8b 00                	mov    (%eax),%eax
c01080ae:	83 e0 07             	and    $0x7,%eax
c01080b1:	89 45 e8             	mov    %eax,-0x18(%ebp)
        //get page from ptep
        struct Page *page = pte2page(*ptep);
c01080b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01080b7:	8b 00                	mov    (%eax),%eax
c01080b9:	89 04 24             	mov    %eax,(%esp)
c01080bc:	e8 bb f1 ff ff       	call   c010727c <pte2page>
c01080c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        // alloc a page for process B
        struct Page *npage=alloc_page();
c01080c4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01080cb:	e8 07 f4 ff ff       	call   c01074d7 <alloc_pages>
c01080d0:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(page!=NULL);
c01080d3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01080d7:	75 24                	jne    c01080fd <copy_range+0x14f>
c01080d9:	c7 44 24 0c e1 d8 10 	movl   $0xc010d8e1,0xc(%esp)
c01080e0:	c0 
c01080e1:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c01080e8:	c0 
c01080e9:	c7 44 24 04 ce 01 00 	movl   $0x1ce,0x4(%esp)
c01080f0:	00 
c01080f1:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c01080f8:	e8 03 83 ff ff       	call   c0100400 <__panic>
        assert(npage!=NULL);
c01080fd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0108101:	75 24                	jne    c0108127 <copy_range+0x179>
c0108103:	c7 44 24 0c ec d8 10 	movl   $0xc010d8ec,0xc(%esp)
c010810a:	c0 
c010810b:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c0108112:	c0 
c0108113:	c7 44 24 04 cf 01 00 	movl   $0x1cf,0x4(%esp)
c010811a:	00 
c010811b:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c0108122:	e8 d9 82 ff ff       	call   c0100400 <__panic>
        int ret=0;
c0108127:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
         * (1) find src_kvaddr: the kernel virtual address of page
         * (2) find dst_kvaddr: the kernel virtual address of npage
         * (3) memory copy from src_kvaddr to dst_kvaddr, size is PGSIZE
         * (4) build the map of phy addr of  nage with the linear addr start
         */
        void * kva_src = page2kva(page);
c010812e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108131:	89 04 24             	mov    %eax,(%esp)
c0108134:	e8 ef f0 ff ff       	call   c0107228 <page2kva>
c0108139:	89 45 d8             	mov    %eax,-0x28(%ebp)
        void * kva_dst = page2kva(npage);
c010813c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010813f:	89 04 24             	mov    %eax,(%esp)
c0108142:	e8 e1 f0 ff ff       	call   c0107228 <page2kva>
c0108147:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    
        memcpy(kva_dst, kva_src, PGSIZE);
c010814a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0108151:	00 
c0108152:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108155:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108159:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010815c:	89 04 24             	mov    %eax,(%esp)
c010815f:	e8 d0 34 00 00       	call   c010b634 <memcpy>

        ret = page_insert(to, npage, start, perm);
c0108164:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108167:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010816b:	8b 45 10             	mov    0x10(%ebp),%eax
c010816e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108172:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108175:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108179:	8b 45 08             	mov    0x8(%ebp),%eax
c010817c:	89 04 24             	mov    %eax,(%esp)
c010817f:	e8 91 00 00 00       	call   c0108215 <page_insert>
c0108184:	89 45 dc             	mov    %eax,-0x24(%ebp)
        assert(ret == 0);
c0108187:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010818b:	74 24                	je     c01081b1 <copy_range+0x203>
c010818d:	c7 44 24 0c f8 d8 10 	movl   $0xc010d8f8,0xc(%esp)
c0108194:	c0 
c0108195:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c010819c:	c0 
c010819d:	c7 44 24 04 e5 01 00 	movl   $0x1e5,0x4(%esp)
c01081a4:	00 
c01081a5:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c01081ac:	e8 4f 82 ff ff       	call   c0100400 <__panic>
        }
        start += PGSIZE;
c01081b1:	81 45 10 00 10 00 00 	addl   $0x1000,0x10(%ebp)
    } while (start != 0 && start < end);
c01081b8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01081bc:	74 0c                	je     c01081ca <copy_range+0x21c>
c01081be:	8b 45 10             	mov    0x10(%ebp),%eax
c01081c1:	3b 45 14             	cmp    0x14(%ebp),%eax
c01081c4:	0f 82 64 fe ff ff    	jb     c010802e <copy_range+0x80>
    return 0;
c01081ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01081cf:	c9                   	leave  
c01081d0:	c3                   	ret    

c01081d1 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c01081d1:	55                   	push   %ebp
c01081d2:	89 e5                	mov    %esp,%ebp
c01081d4:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01081d7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01081de:	00 
c01081df:	8b 45 0c             	mov    0xc(%ebp),%eax
c01081e2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01081e6:	8b 45 08             	mov    0x8(%ebp),%eax
c01081e9:	89 04 24             	mov    %eax,(%esp)
c01081ec:	e8 ca f9 ff ff       	call   c0107bbb <get_pte>
c01081f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c01081f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01081f8:	74 19                	je     c0108213 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c01081fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01081fd:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108201:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108204:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108208:	8b 45 08             	mov    0x8(%ebp),%eax
c010820b:	89 04 24             	mov    %eax,(%esp)
c010820e:	e8 39 fb ff ff       	call   c0107d4c <page_remove_pte>
    }
}
c0108213:	c9                   	leave  
c0108214:	c3                   	ret    

c0108215 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0108215:	55                   	push   %ebp
c0108216:	89 e5                	mov    %esp,%ebp
c0108218:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c010821b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0108222:	00 
c0108223:	8b 45 10             	mov    0x10(%ebp),%eax
c0108226:	89 44 24 04          	mov    %eax,0x4(%esp)
c010822a:	8b 45 08             	mov    0x8(%ebp),%eax
c010822d:	89 04 24             	mov    %eax,(%esp)
c0108230:	e8 86 f9 ff ff       	call   c0107bbb <get_pte>
c0108235:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c0108238:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010823c:	75 0a                	jne    c0108248 <page_insert+0x33>
        return -E_NO_MEM;
c010823e:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0108243:	e9 84 00 00 00       	jmp    c01082cc <page_insert+0xb7>
    }
    page_ref_inc(page);
c0108248:	8b 45 0c             	mov    0xc(%ebp),%eax
c010824b:	89 04 24             	mov    %eax,(%esp)
c010824e:	e8 96 f0 ff ff       	call   c01072e9 <page_ref_inc>
    if (*ptep & PTE_P) {
c0108253:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108256:	8b 00                	mov    (%eax),%eax
c0108258:	83 e0 01             	and    $0x1,%eax
c010825b:	85 c0                	test   %eax,%eax
c010825d:	74 3e                	je     c010829d <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c010825f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108262:	8b 00                	mov    (%eax),%eax
c0108264:	89 04 24             	mov    %eax,(%esp)
c0108267:	e8 10 f0 ff ff       	call   c010727c <pte2page>
c010826c:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c010826f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108272:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108275:	75 0d                	jne    c0108284 <page_insert+0x6f>
            page_ref_dec(page);
c0108277:	8b 45 0c             	mov    0xc(%ebp),%eax
c010827a:	89 04 24             	mov    %eax,(%esp)
c010827d:	e8 7e f0 ff ff       	call   c0107300 <page_ref_dec>
c0108282:	eb 19                	jmp    c010829d <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0108284:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108287:	89 44 24 08          	mov    %eax,0x8(%esp)
c010828b:	8b 45 10             	mov    0x10(%ebp),%eax
c010828e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108292:	8b 45 08             	mov    0x8(%ebp),%eax
c0108295:	89 04 24             	mov    %eax,(%esp)
c0108298:	e8 af fa ff ff       	call   c0107d4c <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c010829d:	8b 45 0c             	mov    0xc(%ebp),%eax
c01082a0:	89 04 24             	mov    %eax,(%esp)
c01082a3:	e8 25 ef ff ff       	call   c01071cd <page2pa>
c01082a8:	0b 45 14             	or     0x14(%ebp),%eax
c01082ab:	83 c8 01             	or     $0x1,%eax
c01082ae:	89 c2                	mov    %eax,%edx
c01082b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01082b3:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c01082b5:	8b 45 10             	mov    0x10(%ebp),%eax
c01082b8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01082bc:	8b 45 08             	mov    0x8(%ebp),%eax
c01082bf:	89 04 24             	mov    %eax,(%esp)
c01082c2:	e8 07 00 00 00       	call   c01082ce <tlb_invalidate>
    return 0;
c01082c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01082cc:	c9                   	leave  
c01082cd:	c3                   	ret    

c01082ce <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c01082ce:	55                   	push   %ebp
c01082cf:	89 e5                	mov    %esp,%ebp
c01082d1:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c01082d4:	0f 20 d8             	mov    %cr3,%eax
c01082d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c01082da:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
c01082dd:	89 c2                	mov    %eax,%edx
c01082df:	8b 45 08             	mov    0x8(%ebp),%eax
c01082e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01082e5:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01082ec:	77 23                	ja     c0108311 <tlb_invalidate+0x43>
c01082ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01082f1:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01082f5:	c7 44 24 08 1c d8 10 	movl   $0xc010d81c,0x8(%esp)
c01082fc:	c0 
c01082fd:	c7 44 24 04 16 02 00 	movl   $0x216,0x4(%esp)
c0108304:	00 
c0108305:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c010830c:	e8 ef 80 ff ff       	call   c0100400 <__panic>
c0108311:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108314:	05 00 00 00 40       	add    $0x40000000,%eax
c0108319:	39 c2                	cmp    %eax,%edx
c010831b:	75 0c                	jne    c0108329 <tlb_invalidate+0x5b>
        invlpg((void *)la);
c010831d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108320:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0108323:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108326:	0f 01 38             	invlpg (%eax)
    }
}
c0108329:	c9                   	leave  
c010832a:	c3                   	ret    

c010832b <pgdir_alloc_page>:

// pgdir_alloc_page - call alloc_page & page_insert functions to 
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *
pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
c010832b:	55                   	push   %ebp
c010832c:	89 e5                	mov    %esp,%ebp
c010832e:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_page();
c0108331:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108338:	e8 9a f1 ff ff       	call   c01074d7 <alloc_pages>
c010833d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c0108340:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108344:	0f 84 b0 00 00 00    	je     c01083fa <pgdir_alloc_page+0xcf>
        if (page_insert(pgdir, page, la, perm) != 0) {
c010834a:	8b 45 10             	mov    0x10(%ebp),%eax
c010834d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108351:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108354:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108358:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010835b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010835f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108362:	89 04 24             	mov    %eax,(%esp)
c0108365:	e8 ab fe ff ff       	call   c0108215 <page_insert>
c010836a:	85 c0                	test   %eax,%eax
c010836c:	74 1a                	je     c0108388 <pgdir_alloc_page+0x5d>
            free_page(page);
c010836e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0108375:	00 
c0108376:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108379:	89 04 24             	mov    %eax,(%esp)
c010837c:	e8 c1 f1 ff ff       	call   c0107542 <free_pages>
            return NULL;
c0108381:	b8 00 00 00 00       	mov    $0x0,%eax
c0108386:	eb 75                	jmp    c01083fd <pgdir_alloc_page+0xd2>
        }
        if (swap_init_ok){
c0108388:	a1 6c ef 19 c0       	mov    0xc019ef6c,%eax
c010838d:	85 c0                	test   %eax,%eax
c010838f:	74 69                	je     c01083fa <pgdir_alloc_page+0xcf>
            if(check_mm_struct!=NULL) {
c0108391:	a1 58 10 1a c0       	mov    0xc01a1058,%eax
c0108396:	85 c0                	test   %eax,%eax
c0108398:	74 60                	je     c01083fa <pgdir_alloc_page+0xcf>
                swap_map_swappable(check_mm_struct, la, page, 0);
c010839a:	a1 58 10 1a c0       	mov    0xc01a1058,%eax
c010839f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01083a6:	00 
c01083a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01083aa:	89 54 24 08          	mov    %edx,0x8(%esp)
c01083ae:	8b 55 0c             	mov    0xc(%ebp),%edx
c01083b1:	89 54 24 04          	mov    %edx,0x4(%esp)
c01083b5:	89 04 24             	mov    %eax,(%esp)
c01083b8:	e8 e7 d1 ff ff       	call   c01055a4 <swap_map_swappable>
                page->pra_vaddr=la;
c01083bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01083c0:	8b 55 0c             	mov    0xc(%ebp),%edx
c01083c3:	89 50 1c             	mov    %edx,0x1c(%eax)
                assert(page_ref(page) == 1);
c01083c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01083c9:	89 04 24             	mov    %eax,(%esp)
c01083cc:	e8 01 ef ff ff       	call   c01072d2 <page_ref>
c01083d1:	83 f8 01             	cmp    $0x1,%eax
c01083d4:	74 24                	je     c01083fa <pgdir_alloc_page+0xcf>
c01083d6:	c7 44 24 0c 01 d9 10 	movl   $0xc010d901,0xc(%esp)
c01083dd:	c0 
c01083de:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c01083e5:	c0 
c01083e6:	c7 44 24 04 2a 02 00 	movl   $0x22a,0x4(%esp)
c01083ed:	00 
c01083ee:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c01083f5:	e8 06 80 ff ff       	call   c0100400 <__panic>
            }
        }

    }

    return page;
c01083fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01083fd:	c9                   	leave  
c01083fe:	c3                   	ret    

c01083ff <check_alloc_page>:

static void
check_alloc_page(void) {
c01083ff:	55                   	push   %ebp
c0108400:	89 e5                	mov    %esp,%ebp
c0108402:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c0108405:	a1 50 11 1a c0       	mov    0xc01a1150,%eax
c010840a:	8b 40 18             	mov    0x18(%eax),%eax
c010840d:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c010840f:	c7 04 24 18 d9 10 c0 	movl   $0xc010d918,(%esp)
c0108416:	e8 8e 7e ff ff       	call   c01002a9 <cprintf>
}
c010841b:	c9                   	leave  
c010841c:	c3                   	ret    

c010841d <check_pgdir>:

static void
check_pgdir(void) {
c010841d:	55                   	push   %ebp
c010841e:	89 e5                	mov    %esp,%ebp
c0108420:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c0108423:	a1 80 ef 19 c0       	mov    0xc019ef80,%eax
c0108428:	3d 00 80 03 00       	cmp    $0x38000,%eax
c010842d:	76 24                	jbe    c0108453 <check_pgdir+0x36>
c010842f:	c7 44 24 0c 37 d9 10 	movl   $0xc010d937,0xc(%esp)
c0108436:	c0 
c0108437:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c010843e:	c0 
c010843f:	c7 44 24 04 42 02 00 	movl   $0x242,0x4(%esp)
c0108446:	00 
c0108447:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c010844e:	e8 ad 7f ff ff       	call   c0100400 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0108453:	a1 20 aa 12 c0       	mov    0xc012aa20,%eax
c0108458:	85 c0                	test   %eax,%eax
c010845a:	74 0e                	je     c010846a <check_pgdir+0x4d>
c010845c:	a1 20 aa 12 c0       	mov    0xc012aa20,%eax
c0108461:	25 ff 0f 00 00       	and    $0xfff,%eax
c0108466:	85 c0                	test   %eax,%eax
c0108468:	74 24                	je     c010848e <check_pgdir+0x71>
c010846a:	c7 44 24 0c 54 d9 10 	movl   $0xc010d954,0xc(%esp)
c0108471:	c0 
c0108472:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c0108479:	c0 
c010847a:	c7 44 24 04 43 02 00 	movl   $0x243,0x4(%esp)
c0108481:	00 
c0108482:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c0108489:	e8 72 7f ff ff       	call   c0100400 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c010848e:	a1 20 aa 12 c0       	mov    0xc012aa20,%eax
c0108493:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010849a:	00 
c010849b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01084a2:	00 
c01084a3:	89 04 24             	mov    %eax,(%esp)
c01084a6:	e8 48 f8 ff ff       	call   c0107cf3 <get_page>
c01084ab:	85 c0                	test   %eax,%eax
c01084ad:	74 24                	je     c01084d3 <check_pgdir+0xb6>
c01084af:	c7 44 24 0c 8c d9 10 	movl   $0xc010d98c,0xc(%esp)
c01084b6:	c0 
c01084b7:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c01084be:	c0 
c01084bf:	c7 44 24 04 44 02 00 	movl   $0x244,0x4(%esp)
c01084c6:	00 
c01084c7:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c01084ce:	e8 2d 7f ff ff       	call   c0100400 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c01084d3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01084da:	e8 f8 ef ff ff       	call   c01074d7 <alloc_pages>
c01084df:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c01084e2:	a1 20 aa 12 c0       	mov    0xc012aa20,%eax
c01084e7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01084ee:	00 
c01084ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01084f6:	00 
c01084f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01084fa:	89 54 24 04          	mov    %edx,0x4(%esp)
c01084fe:	89 04 24             	mov    %eax,(%esp)
c0108501:	e8 0f fd ff ff       	call   c0108215 <page_insert>
c0108506:	85 c0                	test   %eax,%eax
c0108508:	74 24                	je     c010852e <check_pgdir+0x111>
c010850a:	c7 44 24 0c b4 d9 10 	movl   $0xc010d9b4,0xc(%esp)
c0108511:	c0 
c0108512:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c0108519:	c0 
c010851a:	c7 44 24 04 48 02 00 	movl   $0x248,0x4(%esp)
c0108521:	00 
c0108522:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c0108529:	e8 d2 7e ff ff       	call   c0100400 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c010852e:	a1 20 aa 12 c0       	mov    0xc012aa20,%eax
c0108533:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010853a:	00 
c010853b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0108542:	00 
c0108543:	89 04 24             	mov    %eax,(%esp)
c0108546:	e8 70 f6 ff ff       	call   c0107bbb <get_pte>
c010854b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010854e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0108552:	75 24                	jne    c0108578 <check_pgdir+0x15b>
c0108554:	c7 44 24 0c e0 d9 10 	movl   $0xc010d9e0,0xc(%esp)
c010855b:	c0 
c010855c:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c0108563:	c0 
c0108564:	c7 44 24 04 4b 02 00 	movl   $0x24b,0x4(%esp)
c010856b:	00 
c010856c:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c0108573:	e8 88 7e ff ff       	call   c0100400 <__panic>
    assert(pte2page(*ptep) == p1);
c0108578:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010857b:	8b 00                	mov    (%eax),%eax
c010857d:	89 04 24             	mov    %eax,(%esp)
c0108580:	e8 f7 ec ff ff       	call   c010727c <pte2page>
c0108585:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0108588:	74 24                	je     c01085ae <check_pgdir+0x191>
c010858a:	c7 44 24 0c 0d da 10 	movl   $0xc010da0d,0xc(%esp)
c0108591:	c0 
c0108592:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c0108599:	c0 
c010859a:	c7 44 24 04 4c 02 00 	movl   $0x24c,0x4(%esp)
c01085a1:	00 
c01085a2:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c01085a9:	e8 52 7e ff ff       	call   c0100400 <__panic>
    assert(page_ref(p1) == 1);
c01085ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01085b1:	89 04 24             	mov    %eax,(%esp)
c01085b4:	e8 19 ed ff ff       	call   c01072d2 <page_ref>
c01085b9:	83 f8 01             	cmp    $0x1,%eax
c01085bc:	74 24                	je     c01085e2 <check_pgdir+0x1c5>
c01085be:	c7 44 24 0c 23 da 10 	movl   $0xc010da23,0xc(%esp)
c01085c5:	c0 
c01085c6:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c01085cd:	c0 
c01085ce:	c7 44 24 04 4d 02 00 	movl   $0x24d,0x4(%esp)
c01085d5:	00 
c01085d6:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c01085dd:	e8 1e 7e ff ff       	call   c0100400 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c01085e2:	a1 20 aa 12 c0       	mov    0xc012aa20,%eax
c01085e7:	8b 00                	mov    (%eax),%eax
c01085e9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01085ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01085f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01085f4:	c1 e8 0c             	shr    $0xc,%eax
c01085f7:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01085fa:	a1 80 ef 19 c0       	mov    0xc019ef80,%eax
c01085ff:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0108602:	72 23                	jb     c0108627 <check_pgdir+0x20a>
c0108604:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108607:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010860b:	c7 44 24 08 78 d7 10 	movl   $0xc010d778,0x8(%esp)
c0108612:	c0 
c0108613:	c7 44 24 04 4f 02 00 	movl   $0x24f,0x4(%esp)
c010861a:	00 
c010861b:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c0108622:	e8 d9 7d ff ff       	call   c0100400 <__panic>
c0108627:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010862a:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010862f:	83 c0 04             	add    $0x4,%eax
c0108632:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0108635:	a1 20 aa 12 c0       	mov    0xc012aa20,%eax
c010863a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0108641:	00 
c0108642:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0108649:	00 
c010864a:	89 04 24             	mov    %eax,(%esp)
c010864d:	e8 69 f5 ff ff       	call   c0107bbb <get_pte>
c0108652:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0108655:	74 24                	je     c010867b <check_pgdir+0x25e>
c0108657:	c7 44 24 0c 38 da 10 	movl   $0xc010da38,0xc(%esp)
c010865e:	c0 
c010865f:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c0108666:	c0 
c0108667:	c7 44 24 04 50 02 00 	movl   $0x250,0x4(%esp)
c010866e:	00 
c010866f:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c0108676:	e8 85 7d ff ff       	call   c0100400 <__panic>

    p2 = alloc_page();
c010867b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108682:	e8 50 ee ff ff       	call   c01074d7 <alloc_pages>
c0108687:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c010868a:	a1 20 aa 12 c0       	mov    0xc012aa20,%eax
c010868f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c0108696:	00 
c0108697:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c010869e:	00 
c010869f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01086a2:	89 54 24 04          	mov    %edx,0x4(%esp)
c01086a6:	89 04 24             	mov    %eax,(%esp)
c01086a9:	e8 67 fb ff ff       	call   c0108215 <page_insert>
c01086ae:	85 c0                	test   %eax,%eax
c01086b0:	74 24                	je     c01086d6 <check_pgdir+0x2b9>
c01086b2:	c7 44 24 0c 60 da 10 	movl   $0xc010da60,0xc(%esp)
c01086b9:	c0 
c01086ba:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c01086c1:	c0 
c01086c2:	c7 44 24 04 53 02 00 	movl   $0x253,0x4(%esp)
c01086c9:	00 
c01086ca:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c01086d1:	e8 2a 7d ff ff       	call   c0100400 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c01086d6:	a1 20 aa 12 c0       	mov    0xc012aa20,%eax
c01086db:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01086e2:	00 
c01086e3:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01086ea:	00 
c01086eb:	89 04 24             	mov    %eax,(%esp)
c01086ee:	e8 c8 f4 ff ff       	call   c0107bbb <get_pte>
c01086f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01086f6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01086fa:	75 24                	jne    c0108720 <check_pgdir+0x303>
c01086fc:	c7 44 24 0c 98 da 10 	movl   $0xc010da98,0xc(%esp)
c0108703:	c0 
c0108704:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c010870b:	c0 
c010870c:	c7 44 24 04 54 02 00 	movl   $0x254,0x4(%esp)
c0108713:	00 
c0108714:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c010871b:	e8 e0 7c ff ff       	call   c0100400 <__panic>
    assert(*ptep & PTE_U);
c0108720:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108723:	8b 00                	mov    (%eax),%eax
c0108725:	83 e0 04             	and    $0x4,%eax
c0108728:	85 c0                	test   %eax,%eax
c010872a:	75 24                	jne    c0108750 <check_pgdir+0x333>
c010872c:	c7 44 24 0c c8 da 10 	movl   $0xc010dac8,0xc(%esp)
c0108733:	c0 
c0108734:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c010873b:	c0 
c010873c:	c7 44 24 04 55 02 00 	movl   $0x255,0x4(%esp)
c0108743:	00 
c0108744:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c010874b:	e8 b0 7c ff ff       	call   c0100400 <__panic>
    assert(*ptep & PTE_W);
c0108750:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108753:	8b 00                	mov    (%eax),%eax
c0108755:	83 e0 02             	and    $0x2,%eax
c0108758:	85 c0                	test   %eax,%eax
c010875a:	75 24                	jne    c0108780 <check_pgdir+0x363>
c010875c:	c7 44 24 0c d6 da 10 	movl   $0xc010dad6,0xc(%esp)
c0108763:	c0 
c0108764:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c010876b:	c0 
c010876c:	c7 44 24 04 56 02 00 	movl   $0x256,0x4(%esp)
c0108773:	00 
c0108774:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c010877b:	e8 80 7c ff ff       	call   c0100400 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0108780:	a1 20 aa 12 c0       	mov    0xc012aa20,%eax
c0108785:	8b 00                	mov    (%eax),%eax
c0108787:	83 e0 04             	and    $0x4,%eax
c010878a:	85 c0                	test   %eax,%eax
c010878c:	75 24                	jne    c01087b2 <check_pgdir+0x395>
c010878e:	c7 44 24 0c e4 da 10 	movl   $0xc010dae4,0xc(%esp)
c0108795:	c0 
c0108796:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c010879d:	c0 
c010879e:	c7 44 24 04 57 02 00 	movl   $0x257,0x4(%esp)
c01087a5:	00 
c01087a6:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c01087ad:	e8 4e 7c ff ff       	call   c0100400 <__panic>
    assert(page_ref(p2) == 1);
c01087b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01087b5:	89 04 24             	mov    %eax,(%esp)
c01087b8:	e8 15 eb ff ff       	call   c01072d2 <page_ref>
c01087bd:	83 f8 01             	cmp    $0x1,%eax
c01087c0:	74 24                	je     c01087e6 <check_pgdir+0x3c9>
c01087c2:	c7 44 24 0c fa da 10 	movl   $0xc010dafa,0xc(%esp)
c01087c9:	c0 
c01087ca:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c01087d1:	c0 
c01087d2:	c7 44 24 04 58 02 00 	movl   $0x258,0x4(%esp)
c01087d9:	00 
c01087da:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c01087e1:	e8 1a 7c ff ff       	call   c0100400 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c01087e6:	a1 20 aa 12 c0       	mov    0xc012aa20,%eax
c01087eb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01087f2:	00 
c01087f3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01087fa:	00 
c01087fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01087fe:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108802:	89 04 24             	mov    %eax,(%esp)
c0108805:	e8 0b fa ff ff       	call   c0108215 <page_insert>
c010880a:	85 c0                	test   %eax,%eax
c010880c:	74 24                	je     c0108832 <check_pgdir+0x415>
c010880e:	c7 44 24 0c 0c db 10 	movl   $0xc010db0c,0xc(%esp)
c0108815:	c0 
c0108816:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c010881d:	c0 
c010881e:	c7 44 24 04 5a 02 00 	movl   $0x25a,0x4(%esp)
c0108825:	00 
c0108826:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c010882d:	e8 ce 7b ff ff       	call   c0100400 <__panic>
    assert(page_ref(p1) == 2);
c0108832:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108835:	89 04 24             	mov    %eax,(%esp)
c0108838:	e8 95 ea ff ff       	call   c01072d2 <page_ref>
c010883d:	83 f8 02             	cmp    $0x2,%eax
c0108840:	74 24                	je     c0108866 <check_pgdir+0x449>
c0108842:	c7 44 24 0c 38 db 10 	movl   $0xc010db38,0xc(%esp)
c0108849:	c0 
c010884a:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c0108851:	c0 
c0108852:	c7 44 24 04 5b 02 00 	movl   $0x25b,0x4(%esp)
c0108859:	00 
c010885a:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c0108861:	e8 9a 7b ff ff       	call   c0100400 <__panic>
    assert(page_ref(p2) == 0);
c0108866:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108869:	89 04 24             	mov    %eax,(%esp)
c010886c:	e8 61 ea ff ff       	call   c01072d2 <page_ref>
c0108871:	85 c0                	test   %eax,%eax
c0108873:	74 24                	je     c0108899 <check_pgdir+0x47c>
c0108875:	c7 44 24 0c 4a db 10 	movl   $0xc010db4a,0xc(%esp)
c010887c:	c0 
c010887d:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c0108884:	c0 
c0108885:	c7 44 24 04 5c 02 00 	movl   $0x25c,0x4(%esp)
c010888c:	00 
c010888d:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c0108894:	e8 67 7b ff ff       	call   c0100400 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0108899:	a1 20 aa 12 c0       	mov    0xc012aa20,%eax
c010889e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01088a5:	00 
c01088a6:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01088ad:	00 
c01088ae:	89 04 24             	mov    %eax,(%esp)
c01088b1:	e8 05 f3 ff ff       	call   c0107bbb <get_pte>
c01088b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01088b9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01088bd:	75 24                	jne    c01088e3 <check_pgdir+0x4c6>
c01088bf:	c7 44 24 0c 98 da 10 	movl   $0xc010da98,0xc(%esp)
c01088c6:	c0 
c01088c7:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c01088ce:	c0 
c01088cf:	c7 44 24 04 5d 02 00 	movl   $0x25d,0x4(%esp)
c01088d6:	00 
c01088d7:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c01088de:	e8 1d 7b ff ff       	call   c0100400 <__panic>
    assert(pte2page(*ptep) == p1);
c01088e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01088e6:	8b 00                	mov    (%eax),%eax
c01088e8:	89 04 24             	mov    %eax,(%esp)
c01088eb:	e8 8c e9 ff ff       	call   c010727c <pte2page>
c01088f0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01088f3:	74 24                	je     c0108919 <check_pgdir+0x4fc>
c01088f5:	c7 44 24 0c 0d da 10 	movl   $0xc010da0d,0xc(%esp)
c01088fc:	c0 
c01088fd:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c0108904:	c0 
c0108905:	c7 44 24 04 5e 02 00 	movl   $0x25e,0x4(%esp)
c010890c:	00 
c010890d:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c0108914:	e8 e7 7a ff ff       	call   c0100400 <__panic>
    assert((*ptep & PTE_U) == 0);
c0108919:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010891c:	8b 00                	mov    (%eax),%eax
c010891e:	83 e0 04             	and    $0x4,%eax
c0108921:	85 c0                	test   %eax,%eax
c0108923:	74 24                	je     c0108949 <check_pgdir+0x52c>
c0108925:	c7 44 24 0c 5c db 10 	movl   $0xc010db5c,0xc(%esp)
c010892c:	c0 
c010892d:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c0108934:	c0 
c0108935:	c7 44 24 04 5f 02 00 	movl   $0x25f,0x4(%esp)
c010893c:	00 
c010893d:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c0108944:	e8 b7 7a ff ff       	call   c0100400 <__panic>

    page_remove(boot_pgdir, 0x0);
c0108949:	a1 20 aa 12 c0       	mov    0xc012aa20,%eax
c010894e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0108955:	00 
c0108956:	89 04 24             	mov    %eax,(%esp)
c0108959:	e8 73 f8 ff ff       	call   c01081d1 <page_remove>
    assert(page_ref(p1) == 1);
c010895e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108961:	89 04 24             	mov    %eax,(%esp)
c0108964:	e8 69 e9 ff ff       	call   c01072d2 <page_ref>
c0108969:	83 f8 01             	cmp    $0x1,%eax
c010896c:	74 24                	je     c0108992 <check_pgdir+0x575>
c010896e:	c7 44 24 0c 23 da 10 	movl   $0xc010da23,0xc(%esp)
c0108975:	c0 
c0108976:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c010897d:	c0 
c010897e:	c7 44 24 04 62 02 00 	movl   $0x262,0x4(%esp)
c0108985:	00 
c0108986:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c010898d:	e8 6e 7a ff ff       	call   c0100400 <__panic>
    assert(page_ref(p2) == 0);
c0108992:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108995:	89 04 24             	mov    %eax,(%esp)
c0108998:	e8 35 e9 ff ff       	call   c01072d2 <page_ref>
c010899d:	85 c0                	test   %eax,%eax
c010899f:	74 24                	je     c01089c5 <check_pgdir+0x5a8>
c01089a1:	c7 44 24 0c 4a db 10 	movl   $0xc010db4a,0xc(%esp)
c01089a8:	c0 
c01089a9:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c01089b0:	c0 
c01089b1:	c7 44 24 04 63 02 00 	movl   $0x263,0x4(%esp)
c01089b8:	00 
c01089b9:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c01089c0:	e8 3b 7a ff ff       	call   c0100400 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c01089c5:	a1 20 aa 12 c0       	mov    0xc012aa20,%eax
c01089ca:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01089d1:	00 
c01089d2:	89 04 24             	mov    %eax,(%esp)
c01089d5:	e8 f7 f7 ff ff       	call   c01081d1 <page_remove>
    assert(page_ref(p1) == 0);
c01089da:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01089dd:	89 04 24             	mov    %eax,(%esp)
c01089e0:	e8 ed e8 ff ff       	call   c01072d2 <page_ref>
c01089e5:	85 c0                	test   %eax,%eax
c01089e7:	74 24                	je     c0108a0d <check_pgdir+0x5f0>
c01089e9:	c7 44 24 0c 71 db 10 	movl   $0xc010db71,0xc(%esp)
c01089f0:	c0 
c01089f1:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c01089f8:	c0 
c01089f9:	c7 44 24 04 66 02 00 	movl   $0x266,0x4(%esp)
c0108a00:	00 
c0108a01:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c0108a08:	e8 f3 79 ff ff       	call   c0100400 <__panic>
    assert(page_ref(p2) == 0);
c0108a0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108a10:	89 04 24             	mov    %eax,(%esp)
c0108a13:	e8 ba e8 ff ff       	call   c01072d2 <page_ref>
c0108a18:	85 c0                	test   %eax,%eax
c0108a1a:	74 24                	je     c0108a40 <check_pgdir+0x623>
c0108a1c:	c7 44 24 0c 4a db 10 	movl   $0xc010db4a,0xc(%esp)
c0108a23:	c0 
c0108a24:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c0108a2b:	c0 
c0108a2c:	c7 44 24 04 67 02 00 	movl   $0x267,0x4(%esp)
c0108a33:	00 
c0108a34:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c0108a3b:	e8 c0 79 ff ff       	call   c0100400 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0108a40:	a1 20 aa 12 c0       	mov    0xc012aa20,%eax
c0108a45:	8b 00                	mov    (%eax),%eax
c0108a47:	89 04 24             	mov    %eax,(%esp)
c0108a4a:	e8 6b e8 ff ff       	call   c01072ba <pde2page>
c0108a4f:	89 04 24             	mov    %eax,(%esp)
c0108a52:	e8 7b e8 ff ff       	call   c01072d2 <page_ref>
c0108a57:	83 f8 01             	cmp    $0x1,%eax
c0108a5a:	74 24                	je     c0108a80 <check_pgdir+0x663>
c0108a5c:	c7 44 24 0c 84 db 10 	movl   $0xc010db84,0xc(%esp)
c0108a63:	c0 
c0108a64:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c0108a6b:	c0 
c0108a6c:	c7 44 24 04 69 02 00 	movl   $0x269,0x4(%esp)
c0108a73:	00 
c0108a74:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c0108a7b:	e8 80 79 ff ff       	call   c0100400 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0108a80:	a1 20 aa 12 c0       	mov    0xc012aa20,%eax
c0108a85:	8b 00                	mov    (%eax),%eax
c0108a87:	89 04 24             	mov    %eax,(%esp)
c0108a8a:	e8 2b e8 ff ff       	call   c01072ba <pde2page>
c0108a8f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0108a96:	00 
c0108a97:	89 04 24             	mov    %eax,(%esp)
c0108a9a:	e8 a3 ea ff ff       	call   c0107542 <free_pages>
    boot_pgdir[0] = 0;
c0108a9f:	a1 20 aa 12 c0       	mov    0xc012aa20,%eax
c0108aa4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0108aaa:	c7 04 24 ab db 10 c0 	movl   $0xc010dbab,(%esp)
c0108ab1:	e8 f3 77 ff ff       	call   c01002a9 <cprintf>
}
c0108ab6:	c9                   	leave  
c0108ab7:	c3                   	ret    

c0108ab8 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0108ab8:	55                   	push   %ebp
c0108ab9:	89 e5                	mov    %esp,%ebp
c0108abb:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0108abe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0108ac5:	e9 ca 00 00 00       	jmp    c0108b94 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0108aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108acd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108ad0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108ad3:	c1 e8 0c             	shr    $0xc,%eax
c0108ad6:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108ad9:	a1 80 ef 19 c0       	mov    0xc019ef80,%eax
c0108ade:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0108ae1:	72 23                	jb     c0108b06 <check_boot_pgdir+0x4e>
c0108ae3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108ae6:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108aea:	c7 44 24 08 78 d7 10 	movl   $0xc010d778,0x8(%esp)
c0108af1:	c0 
c0108af2:	c7 44 24 04 75 02 00 	movl   $0x275,0x4(%esp)
c0108af9:	00 
c0108afa:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c0108b01:	e8 fa 78 ff ff       	call   c0100400 <__panic>
c0108b06:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108b09:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0108b0e:	89 c2                	mov    %eax,%edx
c0108b10:	a1 20 aa 12 c0       	mov    0xc012aa20,%eax
c0108b15:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0108b1c:	00 
c0108b1d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108b21:	89 04 24             	mov    %eax,(%esp)
c0108b24:	e8 92 f0 ff ff       	call   c0107bbb <get_pte>
c0108b29:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108b2c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108b30:	75 24                	jne    c0108b56 <check_boot_pgdir+0x9e>
c0108b32:	c7 44 24 0c c8 db 10 	movl   $0xc010dbc8,0xc(%esp)
c0108b39:	c0 
c0108b3a:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c0108b41:	c0 
c0108b42:	c7 44 24 04 75 02 00 	movl   $0x275,0x4(%esp)
c0108b49:	00 
c0108b4a:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c0108b51:	e8 aa 78 ff ff       	call   c0100400 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0108b56:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108b59:	8b 00                	mov    (%eax),%eax
c0108b5b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0108b60:	89 c2                	mov    %eax,%edx
c0108b62:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108b65:	39 c2                	cmp    %eax,%edx
c0108b67:	74 24                	je     c0108b8d <check_boot_pgdir+0xd5>
c0108b69:	c7 44 24 0c 05 dc 10 	movl   $0xc010dc05,0xc(%esp)
c0108b70:	c0 
c0108b71:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c0108b78:	c0 
c0108b79:	c7 44 24 04 76 02 00 	movl   $0x276,0x4(%esp)
c0108b80:	00 
c0108b81:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c0108b88:	e8 73 78 ff ff       	call   c0100400 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
c0108b8d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0108b94:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108b97:	a1 80 ef 19 c0       	mov    0xc019ef80,%eax
c0108b9c:	39 c2                	cmp    %eax,%edx
c0108b9e:	0f 82 26 ff ff ff    	jb     c0108aca <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0108ba4:	a1 20 aa 12 c0       	mov    0xc012aa20,%eax
c0108ba9:	05 ac 0f 00 00       	add    $0xfac,%eax
c0108bae:	8b 00                	mov    (%eax),%eax
c0108bb0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0108bb5:	89 c2                	mov    %eax,%edx
c0108bb7:	a1 20 aa 12 c0       	mov    0xc012aa20,%eax
c0108bbc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108bbf:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c0108bc6:	77 23                	ja     c0108beb <check_boot_pgdir+0x133>
c0108bc8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108bcb:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108bcf:	c7 44 24 08 1c d8 10 	movl   $0xc010d81c,0x8(%esp)
c0108bd6:	c0 
c0108bd7:	c7 44 24 04 79 02 00 	movl   $0x279,0x4(%esp)
c0108bde:	00 
c0108bdf:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c0108be6:	e8 15 78 ff ff       	call   c0100400 <__panic>
c0108beb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108bee:	05 00 00 00 40       	add    $0x40000000,%eax
c0108bf3:	39 c2                	cmp    %eax,%edx
c0108bf5:	74 24                	je     c0108c1b <check_boot_pgdir+0x163>
c0108bf7:	c7 44 24 0c 1c dc 10 	movl   $0xc010dc1c,0xc(%esp)
c0108bfe:	c0 
c0108bff:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c0108c06:	c0 
c0108c07:	c7 44 24 04 79 02 00 	movl   $0x279,0x4(%esp)
c0108c0e:	00 
c0108c0f:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c0108c16:	e8 e5 77 ff ff       	call   c0100400 <__panic>

    assert(boot_pgdir[0] == 0);
c0108c1b:	a1 20 aa 12 c0       	mov    0xc012aa20,%eax
c0108c20:	8b 00                	mov    (%eax),%eax
c0108c22:	85 c0                	test   %eax,%eax
c0108c24:	74 24                	je     c0108c4a <check_boot_pgdir+0x192>
c0108c26:	c7 44 24 0c 50 dc 10 	movl   $0xc010dc50,0xc(%esp)
c0108c2d:	c0 
c0108c2e:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c0108c35:	c0 
c0108c36:	c7 44 24 04 7b 02 00 	movl   $0x27b,0x4(%esp)
c0108c3d:	00 
c0108c3e:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c0108c45:	e8 b6 77 ff ff       	call   c0100400 <__panic>

    struct Page *p;
    p = alloc_page();
c0108c4a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108c51:	e8 81 e8 ff ff       	call   c01074d7 <alloc_pages>
c0108c56:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0108c59:	a1 20 aa 12 c0       	mov    0xc012aa20,%eax
c0108c5e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0108c65:	00 
c0108c66:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0108c6d:	00 
c0108c6e:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108c71:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108c75:	89 04 24             	mov    %eax,(%esp)
c0108c78:	e8 98 f5 ff ff       	call   c0108215 <page_insert>
c0108c7d:	85 c0                	test   %eax,%eax
c0108c7f:	74 24                	je     c0108ca5 <check_boot_pgdir+0x1ed>
c0108c81:	c7 44 24 0c 64 dc 10 	movl   $0xc010dc64,0xc(%esp)
c0108c88:	c0 
c0108c89:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c0108c90:	c0 
c0108c91:	c7 44 24 04 7f 02 00 	movl   $0x27f,0x4(%esp)
c0108c98:	00 
c0108c99:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c0108ca0:	e8 5b 77 ff ff       	call   c0100400 <__panic>
    assert(page_ref(p) == 1);
c0108ca5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108ca8:	89 04 24             	mov    %eax,(%esp)
c0108cab:	e8 22 e6 ff ff       	call   c01072d2 <page_ref>
c0108cb0:	83 f8 01             	cmp    $0x1,%eax
c0108cb3:	74 24                	je     c0108cd9 <check_boot_pgdir+0x221>
c0108cb5:	c7 44 24 0c 92 dc 10 	movl   $0xc010dc92,0xc(%esp)
c0108cbc:	c0 
c0108cbd:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c0108cc4:	c0 
c0108cc5:	c7 44 24 04 80 02 00 	movl   $0x280,0x4(%esp)
c0108ccc:	00 
c0108ccd:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c0108cd4:	e8 27 77 ff ff       	call   c0100400 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0108cd9:	a1 20 aa 12 c0       	mov    0xc012aa20,%eax
c0108cde:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0108ce5:	00 
c0108ce6:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0108ced:	00 
c0108cee:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108cf1:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108cf5:	89 04 24             	mov    %eax,(%esp)
c0108cf8:	e8 18 f5 ff ff       	call   c0108215 <page_insert>
c0108cfd:	85 c0                	test   %eax,%eax
c0108cff:	74 24                	je     c0108d25 <check_boot_pgdir+0x26d>
c0108d01:	c7 44 24 0c a4 dc 10 	movl   $0xc010dca4,0xc(%esp)
c0108d08:	c0 
c0108d09:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c0108d10:	c0 
c0108d11:	c7 44 24 04 81 02 00 	movl   $0x281,0x4(%esp)
c0108d18:	00 
c0108d19:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c0108d20:	e8 db 76 ff ff       	call   c0100400 <__panic>
    assert(page_ref(p) == 2);
c0108d25:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108d28:	89 04 24             	mov    %eax,(%esp)
c0108d2b:	e8 a2 e5 ff ff       	call   c01072d2 <page_ref>
c0108d30:	83 f8 02             	cmp    $0x2,%eax
c0108d33:	74 24                	je     c0108d59 <check_boot_pgdir+0x2a1>
c0108d35:	c7 44 24 0c db dc 10 	movl   $0xc010dcdb,0xc(%esp)
c0108d3c:	c0 
c0108d3d:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c0108d44:	c0 
c0108d45:	c7 44 24 04 82 02 00 	movl   $0x282,0x4(%esp)
c0108d4c:	00 
c0108d4d:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c0108d54:	e8 a7 76 ff ff       	call   c0100400 <__panic>

    const char *str = "ucore: Hello world!!";
c0108d59:	c7 45 dc ec dc 10 c0 	movl   $0xc010dcec,-0x24(%ebp)
    strcpy((void *)0x100, str);
c0108d60:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108d63:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108d67:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0108d6e:	e8 08 25 00 00       	call   c010b27b <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0108d73:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0108d7a:	00 
c0108d7b:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0108d82:	e8 6d 25 00 00       	call   c010b2f4 <strcmp>
c0108d87:	85 c0                	test   %eax,%eax
c0108d89:	74 24                	je     c0108daf <check_boot_pgdir+0x2f7>
c0108d8b:	c7 44 24 0c 04 dd 10 	movl   $0xc010dd04,0xc(%esp)
c0108d92:	c0 
c0108d93:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c0108d9a:	c0 
c0108d9b:	c7 44 24 04 86 02 00 	movl   $0x286,0x4(%esp)
c0108da2:	00 
c0108da3:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c0108daa:	e8 51 76 ff ff       	call   c0100400 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0108daf:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108db2:	89 04 24             	mov    %eax,(%esp)
c0108db5:	e8 6e e4 ff ff       	call   c0107228 <page2kva>
c0108dba:	05 00 01 00 00       	add    $0x100,%eax
c0108dbf:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0108dc2:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0108dc9:	e8 55 24 00 00       	call   c010b223 <strlen>
c0108dce:	85 c0                	test   %eax,%eax
c0108dd0:	74 24                	je     c0108df6 <check_boot_pgdir+0x33e>
c0108dd2:	c7 44 24 0c 3c dd 10 	movl   $0xc010dd3c,0xc(%esp)
c0108dd9:	c0 
c0108dda:	c7 44 24 08 65 d8 10 	movl   $0xc010d865,0x8(%esp)
c0108de1:	c0 
c0108de2:	c7 44 24 04 89 02 00 	movl   $0x289,0x4(%esp)
c0108de9:	00 
c0108dea:	c7 04 24 40 d8 10 c0 	movl   $0xc010d840,(%esp)
c0108df1:	e8 0a 76 ff ff       	call   c0100400 <__panic>

    free_page(p);
c0108df6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0108dfd:	00 
c0108dfe:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108e01:	89 04 24             	mov    %eax,(%esp)
c0108e04:	e8 39 e7 ff ff       	call   c0107542 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0108e09:	a1 20 aa 12 c0       	mov    0xc012aa20,%eax
c0108e0e:	8b 00                	mov    (%eax),%eax
c0108e10:	89 04 24             	mov    %eax,(%esp)
c0108e13:	e8 a2 e4 ff ff       	call   c01072ba <pde2page>
c0108e18:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0108e1f:	00 
c0108e20:	89 04 24             	mov    %eax,(%esp)
c0108e23:	e8 1a e7 ff ff       	call   c0107542 <free_pages>
    boot_pgdir[0] = 0;
c0108e28:	a1 20 aa 12 c0       	mov    0xc012aa20,%eax
c0108e2d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0108e33:	c7 04 24 60 dd 10 c0 	movl   $0xc010dd60,(%esp)
c0108e3a:	e8 6a 74 ff ff       	call   c01002a9 <cprintf>
}
c0108e3f:	c9                   	leave  
c0108e40:	c3                   	ret    

c0108e41 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0108e41:	55                   	push   %ebp
c0108e42:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0108e44:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e47:	83 e0 04             	and    $0x4,%eax
c0108e4a:	85 c0                	test   %eax,%eax
c0108e4c:	74 07                	je     c0108e55 <perm2str+0x14>
c0108e4e:	b8 75 00 00 00       	mov    $0x75,%eax
c0108e53:	eb 05                	jmp    c0108e5a <perm2str+0x19>
c0108e55:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0108e5a:	a2 08 f0 19 c0       	mov    %al,0xc019f008
    str[1] = 'r';
c0108e5f:	c6 05 09 f0 19 c0 72 	movb   $0x72,0xc019f009
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0108e66:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e69:	83 e0 02             	and    $0x2,%eax
c0108e6c:	85 c0                	test   %eax,%eax
c0108e6e:	74 07                	je     c0108e77 <perm2str+0x36>
c0108e70:	b8 77 00 00 00       	mov    $0x77,%eax
c0108e75:	eb 05                	jmp    c0108e7c <perm2str+0x3b>
c0108e77:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0108e7c:	a2 0a f0 19 c0       	mov    %al,0xc019f00a
    str[3] = '\0';
c0108e81:	c6 05 0b f0 19 c0 00 	movb   $0x0,0xc019f00b
    return str;
c0108e88:	b8 08 f0 19 c0       	mov    $0xc019f008,%eax
}
c0108e8d:	5d                   	pop    %ebp
c0108e8e:	c3                   	ret    

c0108e8f <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0108e8f:	55                   	push   %ebp
c0108e90:	89 e5                	mov    %esp,%ebp
c0108e92:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0108e95:	8b 45 10             	mov    0x10(%ebp),%eax
c0108e98:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108e9b:	72 0a                	jb     c0108ea7 <get_pgtable_items+0x18>
        return 0;
c0108e9d:	b8 00 00 00 00       	mov    $0x0,%eax
c0108ea2:	e9 9c 00 00 00       	jmp    c0108f43 <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
c0108ea7:	eb 04                	jmp    c0108ead <get_pgtable_items+0x1e>
        start ++;
c0108ea9:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
c0108ead:	8b 45 10             	mov    0x10(%ebp),%eax
c0108eb0:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108eb3:	73 18                	jae    c0108ecd <get_pgtable_items+0x3e>
c0108eb5:	8b 45 10             	mov    0x10(%ebp),%eax
c0108eb8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0108ebf:	8b 45 14             	mov    0x14(%ebp),%eax
c0108ec2:	01 d0                	add    %edx,%eax
c0108ec4:	8b 00                	mov    (%eax),%eax
c0108ec6:	83 e0 01             	and    $0x1,%eax
c0108ec9:	85 c0                	test   %eax,%eax
c0108ecb:	74 dc                	je     c0108ea9 <get_pgtable_items+0x1a>
    }
    if (start < right) {
c0108ecd:	8b 45 10             	mov    0x10(%ebp),%eax
c0108ed0:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108ed3:	73 69                	jae    c0108f3e <get_pgtable_items+0xaf>
        if (left_store != NULL) {
c0108ed5:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0108ed9:	74 08                	je     c0108ee3 <get_pgtable_items+0x54>
            *left_store = start;
c0108edb:	8b 45 18             	mov    0x18(%ebp),%eax
c0108ede:	8b 55 10             	mov    0x10(%ebp),%edx
c0108ee1:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0108ee3:	8b 45 10             	mov    0x10(%ebp),%eax
c0108ee6:	8d 50 01             	lea    0x1(%eax),%edx
c0108ee9:	89 55 10             	mov    %edx,0x10(%ebp)
c0108eec:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0108ef3:	8b 45 14             	mov    0x14(%ebp),%eax
c0108ef6:	01 d0                	add    %edx,%eax
c0108ef8:	8b 00                	mov    (%eax),%eax
c0108efa:	83 e0 07             	and    $0x7,%eax
c0108efd:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0108f00:	eb 04                	jmp    c0108f06 <get_pgtable_items+0x77>
            start ++;
c0108f02:	83 45 10 01          	addl   $0x1,0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0108f06:	8b 45 10             	mov    0x10(%ebp),%eax
c0108f09:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108f0c:	73 1d                	jae    c0108f2b <get_pgtable_items+0x9c>
c0108f0e:	8b 45 10             	mov    0x10(%ebp),%eax
c0108f11:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0108f18:	8b 45 14             	mov    0x14(%ebp),%eax
c0108f1b:	01 d0                	add    %edx,%eax
c0108f1d:	8b 00                	mov    (%eax),%eax
c0108f1f:	83 e0 07             	and    $0x7,%eax
c0108f22:	89 c2                	mov    %eax,%edx
c0108f24:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108f27:	39 c2                	cmp    %eax,%edx
c0108f29:	74 d7                	je     c0108f02 <get_pgtable_items+0x73>
        }
        if (right_store != NULL) {
c0108f2b:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0108f2f:	74 08                	je     c0108f39 <get_pgtable_items+0xaa>
            *right_store = start;
c0108f31:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0108f34:	8b 55 10             	mov    0x10(%ebp),%edx
c0108f37:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0108f39:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108f3c:	eb 05                	jmp    c0108f43 <get_pgtable_items+0xb4>
    }
    return 0;
c0108f3e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108f43:	c9                   	leave  
c0108f44:	c3                   	ret    

c0108f45 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0108f45:	55                   	push   %ebp
c0108f46:	89 e5                	mov    %esp,%ebp
c0108f48:	57                   	push   %edi
c0108f49:	56                   	push   %esi
c0108f4a:	53                   	push   %ebx
c0108f4b:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0108f4e:	c7 04 24 80 dd 10 c0 	movl   $0xc010dd80,(%esp)
c0108f55:	e8 4f 73 ff ff       	call   c01002a9 <cprintf>
    size_t left, right = 0, perm;
c0108f5a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0108f61:	e9 fa 00 00 00       	jmp    c0109060 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0108f66:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108f69:	89 04 24             	mov    %eax,(%esp)
c0108f6c:	e8 d0 fe ff ff       	call   c0108e41 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0108f71:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0108f74:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108f77:	29 d1                	sub    %edx,%ecx
c0108f79:	89 ca                	mov    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0108f7b:	89 d6                	mov    %edx,%esi
c0108f7d:	c1 e6 16             	shl    $0x16,%esi
c0108f80:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0108f83:	89 d3                	mov    %edx,%ebx
c0108f85:	c1 e3 16             	shl    $0x16,%ebx
c0108f88:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108f8b:	89 d1                	mov    %edx,%ecx
c0108f8d:	c1 e1 16             	shl    $0x16,%ecx
c0108f90:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0108f93:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108f96:	29 d7                	sub    %edx,%edi
c0108f98:	89 fa                	mov    %edi,%edx
c0108f9a:	89 44 24 14          	mov    %eax,0x14(%esp)
c0108f9e:	89 74 24 10          	mov    %esi,0x10(%esp)
c0108fa2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0108fa6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0108faa:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108fae:	c7 04 24 b1 dd 10 c0 	movl   $0xc010ddb1,(%esp)
c0108fb5:	e8 ef 72 ff ff       	call   c01002a9 <cprintf>
        size_t l, r = left * NPTEENTRY;
c0108fba:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108fbd:	c1 e0 0a             	shl    $0xa,%eax
c0108fc0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0108fc3:	eb 54                	jmp    c0109019 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0108fc5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108fc8:	89 04 24             	mov    %eax,(%esp)
c0108fcb:	e8 71 fe ff ff       	call   c0108e41 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0108fd0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0108fd3:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0108fd6:	29 d1                	sub    %edx,%ecx
c0108fd8:	89 ca                	mov    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0108fda:	89 d6                	mov    %edx,%esi
c0108fdc:	c1 e6 0c             	shl    $0xc,%esi
c0108fdf:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0108fe2:	89 d3                	mov    %edx,%ebx
c0108fe4:	c1 e3 0c             	shl    $0xc,%ebx
c0108fe7:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0108fea:	c1 e2 0c             	shl    $0xc,%edx
c0108fed:	89 d1                	mov    %edx,%ecx
c0108fef:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c0108ff2:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0108ff5:	29 d7                	sub    %edx,%edi
c0108ff7:	89 fa                	mov    %edi,%edx
c0108ff9:	89 44 24 14          	mov    %eax,0x14(%esp)
c0108ffd:	89 74 24 10          	mov    %esi,0x10(%esp)
c0109001:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0109005:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0109009:	89 54 24 04          	mov    %edx,0x4(%esp)
c010900d:	c7 04 24 d0 dd 10 c0 	movl   $0xc010ddd0,(%esp)
c0109014:	e8 90 72 ff ff       	call   c01002a9 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0109019:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
c010901e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0109021:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0109024:	89 ce                	mov    %ecx,%esi
c0109026:	c1 e6 0a             	shl    $0xa,%esi
c0109029:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c010902c:	89 cb                	mov    %ecx,%ebx
c010902e:	c1 e3 0a             	shl    $0xa,%ebx
c0109031:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
c0109034:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c0109038:	8d 4d d8             	lea    -0x28(%ebp),%ecx
c010903b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c010903f:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0109043:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109047:	89 74 24 04          	mov    %esi,0x4(%esp)
c010904b:	89 1c 24             	mov    %ebx,(%esp)
c010904e:	e8 3c fe ff ff       	call   c0108e8f <get_pgtable_items>
c0109053:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0109056:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010905a:	0f 85 65 ff ff ff    	jne    c0108fc5 <print_pgdir+0x80>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0109060:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
c0109065:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109068:	8d 4d dc             	lea    -0x24(%ebp),%ecx
c010906b:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c010906f:	8d 4d e0             	lea    -0x20(%ebp),%ecx
c0109072:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0109076:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010907a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010907e:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c0109085:	00 
c0109086:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010908d:	e8 fd fd ff ff       	call   c0108e8f <get_pgtable_items>
c0109092:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0109095:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0109099:	0f 85 c7 fe ff ff    	jne    c0108f66 <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
c010909f:	c7 04 24 f4 dd 10 c0 	movl   $0xc010ddf4,(%esp)
c01090a6:	e8 fe 71 ff ff       	call   c01002a9 <cprintf>
}
c01090ab:	83 c4 4c             	add    $0x4c,%esp
c01090ae:	5b                   	pop    %ebx
c01090af:	5e                   	pop    %esi
c01090b0:	5f                   	pop    %edi
c01090b1:	5d                   	pop    %ebp
c01090b2:	c3                   	ret    

c01090b3 <page2ppn>:
page2ppn(struct Page *page) {
c01090b3:	55                   	push   %ebp
c01090b4:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01090b6:	8b 55 08             	mov    0x8(%ebp),%edx
c01090b9:	a1 58 11 1a c0       	mov    0xc01a1158,%eax
c01090be:	29 c2                	sub    %eax,%edx
c01090c0:	89 d0                	mov    %edx,%eax
c01090c2:	c1 f8 05             	sar    $0x5,%eax
}
c01090c5:	5d                   	pop    %ebp
c01090c6:	c3                   	ret    

c01090c7 <page2pa>:
page2pa(struct Page *page) {
c01090c7:	55                   	push   %ebp
c01090c8:	89 e5                	mov    %esp,%ebp
c01090ca:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01090cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01090d0:	89 04 24             	mov    %eax,(%esp)
c01090d3:	e8 db ff ff ff       	call   c01090b3 <page2ppn>
c01090d8:	c1 e0 0c             	shl    $0xc,%eax
}
c01090db:	c9                   	leave  
c01090dc:	c3                   	ret    

c01090dd <page2kva>:
page2kva(struct Page *page) {
c01090dd:	55                   	push   %ebp
c01090de:	89 e5                	mov    %esp,%ebp
c01090e0:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c01090e3:	8b 45 08             	mov    0x8(%ebp),%eax
c01090e6:	89 04 24             	mov    %eax,(%esp)
c01090e9:	e8 d9 ff ff ff       	call   c01090c7 <page2pa>
c01090ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01090f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01090f4:	c1 e8 0c             	shr    $0xc,%eax
c01090f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01090fa:	a1 80 ef 19 c0       	mov    0xc019ef80,%eax
c01090ff:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0109102:	72 23                	jb     c0109127 <page2kva+0x4a>
c0109104:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109107:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010910b:	c7 44 24 08 28 de 10 	movl   $0xc010de28,0x8(%esp)
c0109112:	c0 
c0109113:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c010911a:	00 
c010911b:	c7 04 24 4b de 10 c0 	movl   $0xc010de4b,(%esp)
c0109122:	e8 d9 72 ff ff       	call   c0100400 <__panic>
c0109127:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010912a:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c010912f:	c9                   	leave  
c0109130:	c3                   	ret    

c0109131 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
c0109131:	55                   	push   %ebp
c0109132:	89 e5                	mov    %esp,%ebp
c0109134:	83 ec 18             	sub    $0x18,%esp
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
c0109137:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010913e:	e8 e8 80 ff ff       	call   c010122b <ide_device_valid>
c0109143:	85 c0                	test   %eax,%eax
c0109145:	75 1c                	jne    c0109163 <swapfs_init+0x32>
        panic("swap fs isn't available.\n");
c0109147:	c7 44 24 08 59 de 10 	movl   $0xc010de59,0x8(%esp)
c010914e:	c0 
c010914f:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
c0109156:	00 
c0109157:	c7 04 24 73 de 10 c0 	movl   $0xc010de73,(%esp)
c010915e:	e8 9d 72 ff ff       	call   c0100400 <__panic>
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
c0109163:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010916a:	e8 fb 80 ff ff       	call   c010126a <ide_device_size>
c010916f:	c1 e8 03             	shr    $0x3,%eax
c0109172:	a3 1c 11 1a c0       	mov    %eax,0xc01a111c
}
c0109177:	c9                   	leave  
c0109178:	c3                   	ret    

c0109179 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
c0109179:	55                   	push   %ebp
c010917a:	89 e5                	mov    %esp,%ebp
c010917c:	83 ec 28             	sub    $0x28,%esp
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c010917f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109182:	89 04 24             	mov    %eax,(%esp)
c0109185:	e8 53 ff ff ff       	call   c01090dd <page2kva>
c010918a:	8b 55 08             	mov    0x8(%ebp),%edx
c010918d:	c1 ea 08             	shr    $0x8,%edx
c0109190:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0109193:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109197:	74 0b                	je     c01091a4 <swapfs_read+0x2b>
c0109199:	8b 15 1c 11 1a c0    	mov    0xc01a111c,%edx
c010919f:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c01091a2:	72 23                	jb     c01091c7 <swapfs_read+0x4e>
c01091a4:	8b 45 08             	mov    0x8(%ebp),%eax
c01091a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01091ab:	c7 44 24 08 84 de 10 	movl   $0xc010de84,0x8(%esp)
c01091b2:	c0 
c01091b3:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c01091ba:	00 
c01091bb:	c7 04 24 73 de 10 c0 	movl   $0xc010de73,(%esp)
c01091c2:	e8 39 72 ff ff       	call   c0100400 <__panic>
c01091c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01091ca:	c1 e2 03             	shl    $0x3,%edx
c01091cd:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c01091d4:	00 
c01091d5:	89 44 24 08          	mov    %eax,0x8(%esp)
c01091d9:	89 54 24 04          	mov    %edx,0x4(%esp)
c01091dd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01091e4:	e8 c0 80 ff ff       	call   c01012a9 <ide_read_secs>
}
c01091e9:	c9                   	leave  
c01091ea:	c3                   	ret    

c01091eb <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
c01091eb:	55                   	push   %ebp
c01091ec:	89 e5                	mov    %esp,%ebp
c01091ee:	83 ec 28             	sub    $0x28,%esp
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c01091f1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01091f4:	89 04 24             	mov    %eax,(%esp)
c01091f7:	e8 e1 fe ff ff       	call   c01090dd <page2kva>
c01091fc:	8b 55 08             	mov    0x8(%ebp),%edx
c01091ff:	c1 ea 08             	shr    $0x8,%edx
c0109202:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0109205:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109209:	74 0b                	je     c0109216 <swapfs_write+0x2b>
c010920b:	8b 15 1c 11 1a c0    	mov    0xc01a111c,%edx
c0109211:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c0109214:	72 23                	jb     c0109239 <swapfs_write+0x4e>
c0109216:	8b 45 08             	mov    0x8(%ebp),%eax
c0109219:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010921d:	c7 44 24 08 84 de 10 	movl   $0xc010de84,0x8(%esp)
c0109224:	c0 
c0109225:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
c010922c:	00 
c010922d:	c7 04 24 73 de 10 c0 	movl   $0xc010de73,(%esp)
c0109234:	e8 c7 71 ff ff       	call   c0100400 <__panic>
c0109239:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010923c:	c1 e2 03             	shl    $0x3,%edx
c010923f:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c0109246:	00 
c0109247:	89 44 24 08          	mov    %eax,0x8(%esp)
c010924b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010924f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0109256:	e8 90 82 ff ff       	call   c01014eb <ide_write_secs>
}
c010925b:	c9                   	leave  
c010925c:	c3                   	ret    

c010925d <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)

    pushl %edx              # push arg
c010925d:	52                   	push   %edx
    call *%ebx              # call fn
c010925e:	ff d3                	call   *%ebx

    pushl %eax              # save the return value of fn(arg)
c0109260:	50                   	push   %eax
    call do_exit            # call do_exit to terminate current thread
c0109261:	e8 a3 0c 00 00       	call   c0109f09 <do_exit>

c0109266 <switch_to>:
.text
.globl switch_to
switch_to:                      # switch_to(from, to)

    # save from's registers
    movl 4(%esp), %eax          # eax points to from
c0109266:	8b 44 24 04          	mov    0x4(%esp),%eax
    popl 0(%eax)                # save eip !popl
c010926a:	8f 00                	popl   (%eax)
    movl %esp, 4(%eax)
c010926c:	89 60 04             	mov    %esp,0x4(%eax)
    movl %ebx, 8(%eax)
c010926f:	89 58 08             	mov    %ebx,0x8(%eax)
    movl %ecx, 12(%eax)
c0109272:	89 48 0c             	mov    %ecx,0xc(%eax)
    movl %edx, 16(%eax)
c0109275:	89 50 10             	mov    %edx,0x10(%eax)
    movl %esi, 20(%eax)
c0109278:	89 70 14             	mov    %esi,0x14(%eax)
    movl %edi, 24(%eax)
c010927b:	89 78 18             	mov    %edi,0x18(%eax)
    movl %ebp, 28(%eax)
c010927e:	89 68 1c             	mov    %ebp,0x1c(%eax)

    # restore to's registers
    movl 4(%esp), %eax          # not 8(%esp): popped return address already
c0109281:	8b 44 24 04          	mov    0x4(%esp),%eax
                                # eax now points to to
    movl 28(%eax), %ebp
c0109285:	8b 68 1c             	mov    0x1c(%eax),%ebp
    movl 24(%eax), %edi
c0109288:	8b 78 18             	mov    0x18(%eax),%edi
    movl 20(%eax), %esi
c010928b:	8b 70 14             	mov    0x14(%eax),%esi
    movl 16(%eax), %edx
c010928e:	8b 50 10             	mov    0x10(%eax),%edx
    movl 12(%eax), %ecx
c0109291:	8b 48 0c             	mov    0xc(%eax),%ecx
    movl 8(%eax), %ebx
c0109294:	8b 58 08             	mov    0x8(%eax),%ebx
    movl 4(%eax), %esp
c0109297:	8b 60 04             	mov    0x4(%eax),%esp

    pushl 0(%eax)               # push eip
c010929a:	ff 30                	pushl  (%eax)

    ret
c010929c:	c3                   	ret    

c010929d <test_and_set_bit>:
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool
test_and_set_bit(int nr, volatile void *addr) {
c010929d:	55                   	push   %ebp
c010929e:	89 e5                	mov    %esp,%ebp
c01092a0:	83 ec 10             	sub    $0x10,%esp
    int oldbit;
    asm volatile ("btsl %2, %1; sbbl %0, %0" : "=r" (oldbit), "=m" (*(volatile long *)addr) : "Ir" (nr) : "memory");
c01092a3:	8b 55 0c             	mov    0xc(%ebp),%edx
c01092a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01092a9:	0f ab 02             	bts    %eax,(%edx)
c01092ac:	19 c0                	sbb    %eax,%eax
c01092ae:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return oldbit != 0;
c01092b1:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01092b5:	0f 95 c0             	setne  %al
c01092b8:	0f b6 c0             	movzbl %al,%eax
}
c01092bb:	c9                   	leave  
c01092bc:	c3                   	ret    

c01092bd <test_and_clear_bit>:
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool
test_and_clear_bit(int nr, volatile void *addr) {
c01092bd:	55                   	push   %ebp
c01092be:	89 e5                	mov    %esp,%ebp
c01092c0:	83 ec 10             	sub    $0x10,%esp
    int oldbit;
    asm volatile ("btrl %2, %1; sbbl %0, %0" : "=r" (oldbit), "=m" (*(volatile long *)addr) : "Ir" (nr) : "memory");
c01092c3:	8b 55 0c             	mov    0xc(%ebp),%edx
c01092c6:	8b 45 08             	mov    0x8(%ebp),%eax
c01092c9:	0f b3 02             	btr    %eax,(%edx)
c01092cc:	19 c0                	sbb    %eax,%eax
c01092ce:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return oldbit != 0;
c01092d1:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01092d5:	0f 95 c0             	setne  %al
c01092d8:	0f b6 c0             	movzbl %al,%eax
}
c01092db:	c9                   	leave  
c01092dc:	c3                   	ret    

c01092dd <__intr_save>:
__intr_save(void) {
c01092dd:	55                   	push   %ebp
c01092de:	89 e5                	mov    %esp,%ebp
c01092e0:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01092e3:	9c                   	pushf  
c01092e4:	58                   	pop    %eax
c01092e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01092e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01092eb:	25 00 02 00 00       	and    $0x200,%eax
c01092f0:	85 c0                	test   %eax,%eax
c01092f2:	74 0c                	je     c0109300 <__intr_save+0x23>
        intr_disable();
c01092f4:	e8 1c 8f ff ff       	call   c0102215 <intr_disable>
        return 1;
c01092f9:	b8 01 00 00 00       	mov    $0x1,%eax
c01092fe:	eb 05                	jmp    c0109305 <__intr_save+0x28>
    return 0;
c0109300:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109305:	c9                   	leave  
c0109306:	c3                   	ret    

c0109307 <__intr_restore>:
__intr_restore(bool flag) {
c0109307:	55                   	push   %ebp
c0109308:	89 e5                	mov    %esp,%ebp
c010930a:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c010930d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109311:	74 05                	je     c0109318 <__intr_restore+0x11>
        intr_enable();
c0109313:	e8 f7 8e ff ff       	call   c010220f <intr_enable>
}
c0109318:	c9                   	leave  
c0109319:	c3                   	ret    

c010931a <try_lock>:

static inline bool
try_lock(lock_t *lock) {
c010931a:	55                   	push   %ebp
c010931b:	89 e5                	mov    %esp,%ebp
c010931d:	83 ec 08             	sub    $0x8,%esp
    return !test_and_set_bit(0, lock);
c0109320:	8b 45 08             	mov    0x8(%ebp),%eax
c0109323:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109327:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010932e:	e8 6a ff ff ff       	call   c010929d <test_and_set_bit>
c0109333:	85 c0                	test   %eax,%eax
c0109335:	0f 94 c0             	sete   %al
c0109338:	0f b6 c0             	movzbl %al,%eax
}
c010933b:	c9                   	leave  
c010933c:	c3                   	ret    

c010933d <lock>:

static inline void
lock(lock_t *lock) {
c010933d:	55                   	push   %ebp
c010933e:	89 e5                	mov    %esp,%ebp
c0109340:	83 ec 18             	sub    $0x18,%esp
    while (!try_lock(lock)) {
c0109343:	eb 05                	jmp    c010934a <lock+0xd>
        schedule();
c0109345:	e8 1b 1c 00 00       	call   c010af65 <schedule>
    while (!try_lock(lock)) {
c010934a:	8b 45 08             	mov    0x8(%ebp),%eax
c010934d:	89 04 24             	mov    %eax,(%esp)
c0109350:	e8 c5 ff ff ff       	call   c010931a <try_lock>
c0109355:	85 c0                	test   %eax,%eax
c0109357:	74 ec                	je     c0109345 <lock+0x8>
    }
}
c0109359:	c9                   	leave  
c010935a:	c3                   	ret    

c010935b <unlock>:

static inline void
unlock(lock_t *lock) {
c010935b:	55                   	push   %ebp
c010935c:	89 e5                	mov    %esp,%ebp
c010935e:	83 ec 18             	sub    $0x18,%esp
    if (!test_and_clear_bit(0, lock)) {
c0109361:	8b 45 08             	mov    0x8(%ebp),%eax
c0109364:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109368:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010936f:	e8 49 ff ff ff       	call   c01092bd <test_and_clear_bit>
c0109374:	85 c0                	test   %eax,%eax
c0109376:	75 1c                	jne    c0109394 <unlock+0x39>
        panic("Unlock failed.\n");
c0109378:	c7 44 24 08 a4 de 10 	movl   $0xc010dea4,0x8(%esp)
c010937f:	c0 
c0109380:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
c0109387:	00 
c0109388:	c7 04 24 b4 de 10 c0 	movl   $0xc010deb4,(%esp)
c010938f:	e8 6c 70 ff ff       	call   c0100400 <__panic>
    }
}
c0109394:	c9                   	leave  
c0109395:	c3                   	ret    

c0109396 <page2ppn>:
page2ppn(struct Page *page) {
c0109396:	55                   	push   %ebp
c0109397:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0109399:	8b 55 08             	mov    0x8(%ebp),%edx
c010939c:	a1 58 11 1a c0       	mov    0xc01a1158,%eax
c01093a1:	29 c2                	sub    %eax,%edx
c01093a3:	89 d0                	mov    %edx,%eax
c01093a5:	c1 f8 05             	sar    $0x5,%eax
}
c01093a8:	5d                   	pop    %ebp
c01093a9:	c3                   	ret    

c01093aa <page2pa>:
page2pa(struct Page *page) {
c01093aa:	55                   	push   %ebp
c01093ab:	89 e5                	mov    %esp,%ebp
c01093ad:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01093b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01093b3:	89 04 24             	mov    %eax,(%esp)
c01093b6:	e8 db ff ff ff       	call   c0109396 <page2ppn>
c01093bb:	c1 e0 0c             	shl    $0xc,%eax
}
c01093be:	c9                   	leave  
c01093bf:	c3                   	ret    

c01093c0 <pa2page>:
pa2page(uintptr_t pa) {
c01093c0:	55                   	push   %ebp
c01093c1:	89 e5                	mov    %esp,%ebp
c01093c3:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c01093c6:	8b 45 08             	mov    0x8(%ebp),%eax
c01093c9:	c1 e8 0c             	shr    $0xc,%eax
c01093cc:	89 c2                	mov    %eax,%edx
c01093ce:	a1 80 ef 19 c0       	mov    0xc019ef80,%eax
c01093d3:	39 c2                	cmp    %eax,%edx
c01093d5:	72 1c                	jb     c01093f3 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c01093d7:	c7 44 24 08 c8 de 10 	movl   $0xc010dec8,0x8(%esp)
c01093de:	c0 
c01093df:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c01093e6:	00 
c01093e7:	c7 04 24 e7 de 10 c0 	movl   $0xc010dee7,(%esp)
c01093ee:	e8 0d 70 ff ff       	call   c0100400 <__panic>
    return &pages[PPN(pa)];
c01093f3:	a1 58 11 1a c0       	mov    0xc01a1158,%eax
c01093f8:	8b 55 08             	mov    0x8(%ebp),%edx
c01093fb:	c1 ea 0c             	shr    $0xc,%edx
c01093fe:	c1 e2 05             	shl    $0x5,%edx
c0109401:	01 d0                	add    %edx,%eax
}
c0109403:	c9                   	leave  
c0109404:	c3                   	ret    

c0109405 <page2kva>:
page2kva(struct Page *page) {
c0109405:	55                   	push   %ebp
c0109406:	89 e5                	mov    %esp,%ebp
c0109408:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c010940b:	8b 45 08             	mov    0x8(%ebp),%eax
c010940e:	89 04 24             	mov    %eax,(%esp)
c0109411:	e8 94 ff ff ff       	call   c01093aa <page2pa>
c0109416:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109419:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010941c:	c1 e8 0c             	shr    $0xc,%eax
c010941f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109422:	a1 80 ef 19 c0       	mov    0xc019ef80,%eax
c0109427:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010942a:	72 23                	jb     c010944f <page2kva+0x4a>
c010942c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010942f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109433:	c7 44 24 08 f8 de 10 	movl   $0xc010def8,0x8(%esp)
c010943a:	c0 
c010943b:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0109442:	00 
c0109443:	c7 04 24 e7 de 10 c0 	movl   $0xc010dee7,(%esp)
c010944a:	e8 b1 6f ff ff       	call   c0100400 <__panic>
c010944f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109452:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0109457:	c9                   	leave  
c0109458:	c3                   	ret    

c0109459 <kva2page>:
kva2page(void *kva) {
c0109459:	55                   	push   %ebp
c010945a:	89 e5                	mov    %esp,%ebp
c010945c:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c010945f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109462:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109465:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c010946c:	77 23                	ja     c0109491 <kva2page+0x38>
c010946e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109471:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109475:	c7 44 24 08 1c df 10 	movl   $0xc010df1c,0x8(%esp)
c010947c:	c0 
c010947d:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c0109484:	00 
c0109485:	c7 04 24 e7 de 10 c0 	movl   $0xc010dee7,(%esp)
c010948c:	e8 6f 6f ff ff       	call   c0100400 <__panic>
c0109491:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109494:	05 00 00 00 40       	add    $0x40000000,%eax
c0109499:	89 04 24             	mov    %eax,(%esp)
c010949c:	e8 1f ff ff ff       	call   c01093c0 <pa2page>
}
c01094a1:	c9                   	leave  
c01094a2:	c3                   	ret    

c01094a3 <mm_count_inc>:

static inline int
mm_count_inc(struct mm_struct *mm) {
c01094a3:	55                   	push   %ebp
c01094a4:	89 e5                	mov    %esp,%ebp
    mm->mm_count += 1;
c01094a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01094a9:	8b 40 18             	mov    0x18(%eax),%eax
c01094ac:	8d 50 01             	lea    0x1(%eax),%edx
c01094af:	8b 45 08             	mov    0x8(%ebp),%eax
c01094b2:	89 50 18             	mov    %edx,0x18(%eax)
    return mm->mm_count;
c01094b5:	8b 45 08             	mov    0x8(%ebp),%eax
c01094b8:	8b 40 18             	mov    0x18(%eax),%eax
}
c01094bb:	5d                   	pop    %ebp
c01094bc:	c3                   	ret    

c01094bd <mm_count_dec>:

static inline int
mm_count_dec(struct mm_struct *mm) {
c01094bd:	55                   	push   %ebp
c01094be:	89 e5                	mov    %esp,%ebp
    mm->mm_count -= 1;
c01094c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01094c3:	8b 40 18             	mov    0x18(%eax),%eax
c01094c6:	8d 50 ff             	lea    -0x1(%eax),%edx
c01094c9:	8b 45 08             	mov    0x8(%ebp),%eax
c01094cc:	89 50 18             	mov    %edx,0x18(%eax)
    return mm->mm_count;
c01094cf:	8b 45 08             	mov    0x8(%ebp),%eax
c01094d2:	8b 40 18             	mov    0x18(%eax),%eax
}
c01094d5:	5d                   	pop    %ebp
c01094d6:	c3                   	ret    

c01094d7 <lock_mm>:

static inline void
lock_mm(struct mm_struct *mm) {
c01094d7:	55                   	push   %ebp
c01094d8:	89 e5                	mov    %esp,%ebp
c01094da:	83 ec 18             	sub    $0x18,%esp
    if (mm != NULL) {
c01094dd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01094e1:	74 0e                	je     c01094f1 <lock_mm+0x1a>
        lock(&(mm->mm_lock));
c01094e3:	8b 45 08             	mov    0x8(%ebp),%eax
c01094e6:	83 c0 1c             	add    $0x1c,%eax
c01094e9:	89 04 24             	mov    %eax,(%esp)
c01094ec:	e8 4c fe ff ff       	call   c010933d <lock>
    }
}
c01094f1:	c9                   	leave  
c01094f2:	c3                   	ret    

c01094f3 <unlock_mm>:

static inline void
unlock_mm(struct mm_struct *mm) {
c01094f3:	55                   	push   %ebp
c01094f4:	89 e5                	mov    %esp,%ebp
c01094f6:	83 ec 18             	sub    $0x18,%esp
    if (mm != NULL) {
c01094f9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01094fd:	74 0e                	je     c010950d <unlock_mm+0x1a>
        unlock(&(mm->mm_lock));
c01094ff:	8b 45 08             	mov    0x8(%ebp),%eax
c0109502:	83 c0 1c             	add    $0x1c,%eax
c0109505:	89 04 24             	mov    %eax,(%esp)
c0109508:	e8 4e fe ff ff       	call   c010935b <unlock>
    }
}
c010950d:	c9                   	leave  
c010950e:	c3                   	ret    

c010950f <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
c010950f:	55                   	push   %ebp
c0109510:	89 e5                	mov    %esp,%ebp
c0109512:	83 ec 28             	sub    $0x28,%esp
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
c0109515:	c7 04 24 7c 00 00 00 	movl   $0x7c,(%esp)
c010951c:	e8 d1 bd ff ff       	call   c01052f2 <kmalloc>
c0109521:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (proc != NULL) {
c0109524:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109528:	0f 84 cd 00 00 00    	je     c01095fb <alloc_proc+0xec>
    /*
     * below fields(add in LAB5) in proc_struct need to be initialized	
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
	 */
        proc->state = PROC_UNINIT;//设置进程为未初始化状态
c010952e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109531:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        proc->pid = -1; //未初始化的的进程id为-1
c0109537:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010953a:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
        proc->runs = 0;//初始化时间片
c0109541:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109544:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        proc->kstack = 0; //内存栈的地址
c010954b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010954e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        proc->need_resched = 0;//不需要调度
c0109555:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109558:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        proc->parent = NULL;  //父节点null
c010955f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109562:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        proc->mm = NULL;      //内核线程常驻内存
c0109569:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010956c:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
        memset(&(proc->context), 0, sizeof(struct context));//上下文初始化0
c0109573:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109576:	83 c0 1c             	add    $0x1c,%eax
c0109579:	c7 44 24 08 20 00 00 	movl   $0x20,0x8(%esp)
c0109580:	00 
c0109581:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109588:	00 
c0109589:	89 04 24             	mov    %eax,(%esp)
c010958c:	e8 c1 1f 00 00       	call   c010b552 <memset>
        proc->tf = NULL; //中断帧指针null
c0109591:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109594:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
        proc->cr3 = boot_cr3;//页目录设为内核页目录表的基址
c010959b:	8b 15 54 11 1a c0    	mov    0xc01a1154,%edx
c01095a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095a4:	89 50 40             	mov    %edx,0x40(%eax)
        proc->flags = 0;//标志位0
c01095a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095aa:	c7 40 44 00 00 00 00 	movl   $0x0,0x44(%eax)
        memset(proc->name, 0, PROC_NAME_LEN);//进程名设为0
c01095b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095b4:	83 c0 48             	add    $0x48,%eax
c01095b7:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c01095be:	00 
c01095bf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01095c6:	00 
c01095c7:	89 04 24             	mov    %eax,(%esp)
c01095ca:	e8 83 1f 00 00       	call   c010b552 <memset>
        proc->wait_state = 0;//初始化进程等待状态
c01095cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095d2:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%eax)
        proc->cptr = proc->optr = proc->yptr = NULL;//进程相关指针初始化:孩子/旧兄弟/新兄弟
c01095d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095dc:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
c01095e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095e6:	8b 50 74             	mov    0x74(%eax),%edx
c01095e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095ec:	89 50 78             	mov    %edx,0x78(%eax)
c01095ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095f2:	8b 50 78             	mov    0x78(%eax),%edx
c01095f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095f8:	89 50 70             	mov    %edx,0x70(%eax)
    }
    return proc;
c01095fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01095fe:	c9                   	leave  
c01095ff:	c3                   	ret    

c0109600 <set_proc_name>:

// set_proc_name - set the name of proc
char *
set_proc_name(struct proc_struct *proc, const char *name) {
c0109600:	55                   	push   %ebp
c0109601:	89 e5                	mov    %esp,%ebp
c0109603:	83 ec 18             	sub    $0x18,%esp
    memset(proc->name, 0, sizeof(proc->name));
c0109606:	8b 45 08             	mov    0x8(%ebp),%eax
c0109609:	83 c0 48             	add    $0x48,%eax
c010960c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c0109613:	00 
c0109614:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010961b:	00 
c010961c:	89 04 24             	mov    %eax,(%esp)
c010961f:	e8 2e 1f 00 00       	call   c010b552 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
c0109624:	8b 45 08             	mov    0x8(%ebp),%eax
c0109627:	8d 50 48             	lea    0x48(%eax),%edx
c010962a:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c0109631:	00 
c0109632:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109635:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109639:	89 14 24             	mov    %edx,(%esp)
c010963c:	e8 f3 1f 00 00       	call   c010b634 <memcpy>
}
c0109641:	c9                   	leave  
c0109642:	c3                   	ret    

c0109643 <get_proc_name>:

// get_proc_name - get the name of proc
char *
get_proc_name(struct proc_struct *proc) {
c0109643:	55                   	push   %ebp
c0109644:	89 e5                	mov    %esp,%ebp
c0109646:	83 ec 18             	sub    $0x18,%esp
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
c0109649:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c0109650:	00 
c0109651:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109658:	00 
c0109659:	c7 04 24 44 10 1a c0 	movl   $0xc01a1044,(%esp)
c0109660:	e8 ed 1e 00 00       	call   c010b552 <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
c0109665:	8b 45 08             	mov    0x8(%ebp),%eax
c0109668:	83 c0 48             	add    $0x48,%eax
c010966b:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c0109672:	00 
c0109673:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109677:	c7 04 24 44 10 1a c0 	movl   $0xc01a1044,(%esp)
c010967e:	e8 b1 1f 00 00       	call   c010b634 <memcpy>
}
c0109683:	c9                   	leave  
c0109684:	c3                   	ret    

c0109685 <set_links>:

// set_links - set the relation links of process
static void
set_links(struct proc_struct *proc) {
c0109685:	55                   	push   %ebp
c0109686:	89 e5                	mov    %esp,%ebp
c0109688:	83 ec 20             	sub    $0x20,%esp
    list_add(&proc_list, &(proc->list_link));
c010968b:	8b 45 08             	mov    0x8(%ebp),%eax
c010968e:	83 c0 58             	add    $0x58,%eax
c0109691:	c7 45 fc 5c 11 1a c0 	movl   $0xc01a115c,-0x4(%ebp)
c0109698:	89 45 f8             	mov    %eax,-0x8(%ebp)
c010969b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010969e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01096a1:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01096a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    __list_add(elm, listelm, listelm->next);
c01096a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01096aa:	8b 40 04             	mov    0x4(%eax),%eax
c01096ad:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01096b0:	89 55 ec             	mov    %edx,-0x14(%ebp)
c01096b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01096b6:	89 55 e8             	mov    %edx,-0x18(%ebp)
c01096b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    prev->next = next->prev = elm;
c01096bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01096bf:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01096c2:	89 10                	mov    %edx,(%eax)
c01096c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01096c7:	8b 10                	mov    (%eax),%edx
c01096c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01096cc:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01096cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01096d2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01096d5:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01096d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01096db:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01096de:	89 10                	mov    %edx,(%eax)
    proc->yptr = NULL;
c01096e0:	8b 45 08             	mov    0x8(%ebp),%eax
c01096e3:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
    if ((proc->optr = proc->parent->cptr) != NULL) {
c01096ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01096ed:	8b 40 14             	mov    0x14(%eax),%eax
c01096f0:	8b 50 70             	mov    0x70(%eax),%edx
c01096f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01096f6:	89 50 78             	mov    %edx,0x78(%eax)
c01096f9:	8b 45 08             	mov    0x8(%ebp),%eax
c01096fc:	8b 40 78             	mov    0x78(%eax),%eax
c01096ff:	85 c0                	test   %eax,%eax
c0109701:	74 0c                	je     c010970f <set_links+0x8a>
        proc->optr->yptr = proc;
c0109703:	8b 45 08             	mov    0x8(%ebp),%eax
c0109706:	8b 40 78             	mov    0x78(%eax),%eax
c0109709:	8b 55 08             	mov    0x8(%ebp),%edx
c010970c:	89 50 74             	mov    %edx,0x74(%eax)
    }
    proc->parent->cptr = proc;
c010970f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109712:	8b 40 14             	mov    0x14(%eax),%eax
c0109715:	8b 55 08             	mov    0x8(%ebp),%edx
c0109718:	89 50 70             	mov    %edx,0x70(%eax)
    nr_process ++;
c010971b:	a1 40 10 1a c0       	mov    0xc01a1040,%eax
c0109720:	83 c0 01             	add    $0x1,%eax
c0109723:	a3 40 10 1a c0       	mov    %eax,0xc01a1040
}
c0109728:	c9                   	leave  
c0109729:	c3                   	ret    

c010972a <remove_links>:

// remove_links - clean the relation links of process
static void
remove_links(struct proc_struct *proc) {
c010972a:	55                   	push   %ebp
c010972b:	89 e5                	mov    %esp,%ebp
c010972d:	83 ec 10             	sub    $0x10,%esp
    list_del(&(proc->list_link));
c0109730:	8b 45 08             	mov    0x8(%ebp),%eax
c0109733:	83 c0 58             	add    $0x58,%eax
c0109736:	89 45 fc             	mov    %eax,-0x4(%ebp)
    __list_del(listelm->prev, listelm->next);
c0109739:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010973c:	8b 40 04             	mov    0x4(%eax),%eax
c010973f:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0109742:	8b 12                	mov    (%edx),%edx
c0109744:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0109747:	89 45 f4             	mov    %eax,-0xc(%ebp)
    prev->next = next;
c010974a:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010974d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109750:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0109753:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109756:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0109759:	89 10                	mov    %edx,(%eax)
    if (proc->optr != NULL) {
c010975b:	8b 45 08             	mov    0x8(%ebp),%eax
c010975e:	8b 40 78             	mov    0x78(%eax),%eax
c0109761:	85 c0                	test   %eax,%eax
c0109763:	74 0f                	je     c0109774 <remove_links+0x4a>
        proc->optr->yptr = proc->yptr;
c0109765:	8b 45 08             	mov    0x8(%ebp),%eax
c0109768:	8b 40 78             	mov    0x78(%eax),%eax
c010976b:	8b 55 08             	mov    0x8(%ebp),%edx
c010976e:	8b 52 74             	mov    0x74(%edx),%edx
c0109771:	89 50 74             	mov    %edx,0x74(%eax)
    }
    if (proc->yptr != NULL) {
c0109774:	8b 45 08             	mov    0x8(%ebp),%eax
c0109777:	8b 40 74             	mov    0x74(%eax),%eax
c010977a:	85 c0                	test   %eax,%eax
c010977c:	74 11                	je     c010978f <remove_links+0x65>
        proc->yptr->optr = proc->optr;
c010977e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109781:	8b 40 74             	mov    0x74(%eax),%eax
c0109784:	8b 55 08             	mov    0x8(%ebp),%edx
c0109787:	8b 52 78             	mov    0x78(%edx),%edx
c010978a:	89 50 78             	mov    %edx,0x78(%eax)
c010978d:	eb 0f                	jmp    c010979e <remove_links+0x74>
    }
    else {
       proc->parent->cptr = proc->optr;
c010978f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109792:	8b 40 14             	mov    0x14(%eax),%eax
c0109795:	8b 55 08             	mov    0x8(%ebp),%edx
c0109798:	8b 52 78             	mov    0x78(%edx),%edx
c010979b:	89 50 70             	mov    %edx,0x70(%eax)
    }
    nr_process --;
c010979e:	a1 40 10 1a c0       	mov    0xc01a1040,%eax
c01097a3:	83 e8 01             	sub    $0x1,%eax
c01097a6:	a3 40 10 1a c0       	mov    %eax,0xc01a1040
}
c01097ab:	c9                   	leave  
c01097ac:	c3                   	ret    

c01097ad <get_pid>:

// get_pid - alloc a unique pid for process
static int
get_pid(void) {
c01097ad:	55                   	push   %ebp
c01097ae:	89 e5                	mov    %esp,%ebp
c01097b0:	83 ec 10             	sub    $0x10,%esp
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
c01097b3:	c7 45 f8 5c 11 1a c0 	movl   $0xc01a115c,-0x8(%ebp)
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++ last_pid >= MAX_PID) {
c01097ba:	a1 78 aa 12 c0       	mov    0xc012aa78,%eax
c01097bf:	83 c0 01             	add    $0x1,%eax
c01097c2:	a3 78 aa 12 c0       	mov    %eax,0xc012aa78
c01097c7:	a1 78 aa 12 c0       	mov    0xc012aa78,%eax
c01097cc:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c01097d1:	7e 0c                	jle    c01097df <get_pid+0x32>
        last_pid = 1;
c01097d3:	c7 05 78 aa 12 c0 01 	movl   $0x1,0xc012aa78
c01097da:	00 00 00 
        goto inside;
c01097dd:	eb 13                	jmp    c01097f2 <get_pid+0x45>
    }
    if (last_pid >= next_safe) {
c01097df:	8b 15 78 aa 12 c0    	mov    0xc012aa78,%edx
c01097e5:	a1 7c aa 12 c0       	mov    0xc012aa7c,%eax
c01097ea:	39 c2                	cmp    %eax,%edx
c01097ec:	0f 8c ac 00 00 00    	jl     c010989e <get_pid+0xf1>
    inside:
        next_safe = MAX_PID;
c01097f2:	c7 05 7c aa 12 c0 00 	movl   $0x2000,0xc012aa7c
c01097f9:	20 00 00 
    repeat:
        le = list;
c01097fc:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01097ff:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while ((le = list_next(le)) != list) {
c0109802:	eb 7f                	jmp    c0109883 <get_pid+0xd6>
            proc = le2proc(le, list_link);
c0109804:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109807:	83 e8 58             	sub    $0x58,%eax
c010980a:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (proc->pid == last_pid) {
c010980d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109810:	8b 50 04             	mov    0x4(%eax),%edx
c0109813:	a1 78 aa 12 c0       	mov    0xc012aa78,%eax
c0109818:	39 c2                	cmp    %eax,%edx
c010981a:	75 3e                	jne    c010985a <get_pid+0xad>
                if (++ last_pid >= next_safe) {
c010981c:	a1 78 aa 12 c0       	mov    0xc012aa78,%eax
c0109821:	83 c0 01             	add    $0x1,%eax
c0109824:	a3 78 aa 12 c0       	mov    %eax,0xc012aa78
c0109829:	8b 15 78 aa 12 c0    	mov    0xc012aa78,%edx
c010982f:	a1 7c aa 12 c0       	mov    0xc012aa7c,%eax
c0109834:	39 c2                	cmp    %eax,%edx
c0109836:	7c 4b                	jl     c0109883 <get_pid+0xd6>
                    if (last_pid >= MAX_PID) {
c0109838:	a1 78 aa 12 c0       	mov    0xc012aa78,%eax
c010983d:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c0109842:	7e 0a                	jle    c010984e <get_pid+0xa1>
                        last_pid = 1;
c0109844:	c7 05 78 aa 12 c0 01 	movl   $0x1,0xc012aa78
c010984b:	00 00 00 
                    }
                    next_safe = MAX_PID;
c010984e:	c7 05 7c aa 12 c0 00 	movl   $0x2000,0xc012aa7c
c0109855:	20 00 00 
                    goto repeat;
c0109858:	eb a2                	jmp    c01097fc <get_pid+0x4f>
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {
c010985a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010985d:	8b 50 04             	mov    0x4(%eax),%edx
c0109860:	a1 78 aa 12 c0       	mov    0xc012aa78,%eax
c0109865:	39 c2                	cmp    %eax,%edx
c0109867:	7e 1a                	jle    c0109883 <get_pid+0xd6>
c0109869:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010986c:	8b 50 04             	mov    0x4(%eax),%edx
c010986f:	a1 7c aa 12 c0       	mov    0xc012aa7c,%eax
c0109874:	39 c2                	cmp    %eax,%edx
c0109876:	7d 0b                	jge    c0109883 <get_pid+0xd6>
                next_safe = proc->pid;
c0109878:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010987b:	8b 40 04             	mov    0x4(%eax),%eax
c010987e:	a3 7c aa 12 c0       	mov    %eax,0xc012aa7c
c0109883:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109886:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return listelm->next;
c0109889:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010988c:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list) {
c010988f:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0109892:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109895:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0109898:	0f 85 66 ff ff ff    	jne    c0109804 <get_pid+0x57>
            }
        }
    }
    return last_pid;
c010989e:	a1 78 aa 12 c0       	mov    0xc012aa78,%eax
}
c01098a3:	c9                   	leave  
c01098a4:	c3                   	ret    

c01098a5 <proc_run>:

// proc_run - make process "proc" running on cpu
// NOTE: before call switch_to, should load  base addr of "proc"'s new PDT
void
proc_run(struct proc_struct *proc) {
c01098a5:	55                   	push   %ebp
c01098a6:	89 e5                	mov    %esp,%ebp
c01098a8:	83 ec 28             	sub    $0x28,%esp
    if (proc != current) {
c01098ab:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c01098b0:	39 45 08             	cmp    %eax,0x8(%ebp)
c01098b3:	74 63                	je     c0109918 <proc_run+0x73>
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
c01098b5:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c01098ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01098bd:	8b 45 08             	mov    0x8(%ebp),%eax
c01098c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
        local_intr_save(intr_flag);
c01098c3:	e8 15 fa ff ff       	call   c01092dd <__intr_save>
c01098c8:	89 45 ec             	mov    %eax,-0x14(%ebp)
        {
            current = proc;
c01098cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01098ce:	a3 28 f0 19 c0       	mov    %eax,0xc019f028
            load_esp0(next->kstack + KSTACKSIZE);
c01098d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01098d6:	8b 40 0c             	mov    0xc(%eax),%eax
c01098d9:	05 00 20 00 00       	add    $0x2000,%eax
c01098de:	89 04 24             	mov    %eax,(%esp)
c01098e1:	e8 a3 da ff ff       	call   c0107389 <load_esp0>
            lcr3(next->cr3);
c01098e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01098e9:	8b 40 40             	mov    0x40(%eax),%eax
c01098ec:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c01098ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01098f2:	0f 22 d8             	mov    %eax,%cr3
            switch_to(&(prev->context), &(next->context));
c01098f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01098f8:	8d 50 1c             	lea    0x1c(%eax),%edx
c01098fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01098fe:	83 c0 1c             	add    $0x1c,%eax
c0109901:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109905:	89 04 24             	mov    %eax,(%esp)
c0109908:	e8 59 f9 ff ff       	call   c0109266 <switch_to>
        }
        local_intr_restore(intr_flag);
c010990d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109910:	89 04 24             	mov    %eax,(%esp)
c0109913:	e8 ef f9 ff ff       	call   c0109307 <__intr_restore>
    }
}
c0109918:	c9                   	leave  
c0109919:	c3                   	ret    

c010991a <forkret>:

// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
c010991a:	55                   	push   %ebp
c010991b:	89 e5                	mov    %esp,%ebp
c010991d:	83 ec 18             	sub    $0x18,%esp
    forkrets(current->tf);
c0109920:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c0109925:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109928:	89 04 24             	mov    %eax,(%esp)
c010992b:	e8 1b 9c ff ff       	call   c010354b <forkrets>
}
c0109930:	c9                   	leave  
c0109931:	c3                   	ret    

c0109932 <hash_proc>:

// hash_proc - add proc into proc hash_list
static void
hash_proc(struct proc_struct *proc) {
c0109932:	55                   	push   %ebp
c0109933:	89 e5                	mov    %esp,%ebp
c0109935:	53                   	push   %ebx
c0109936:	83 ec 34             	sub    $0x34,%esp
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
c0109939:	8b 45 08             	mov    0x8(%ebp),%eax
c010993c:	8d 58 60             	lea    0x60(%eax),%ebx
c010993f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109942:	8b 40 04             	mov    0x4(%eax),%eax
c0109945:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c010994c:	00 
c010994d:	89 04 24             	mov    %eax,(%esp)
c0109950:	e8 07 24 00 00       	call   c010bd5c <hash32>
c0109955:	c1 e0 03             	shl    $0x3,%eax
c0109958:	05 40 f0 19 c0       	add    $0xc019f040,%eax
c010995d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109960:	89 5d f0             	mov    %ebx,-0x10(%ebp)
c0109963:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109966:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109969:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010996c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    __list_add(elm, listelm, listelm->next);
c010996f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109972:	8b 40 04             	mov    0x4(%eax),%eax
c0109975:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0109978:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010997b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010997e:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0109981:	89 45 dc             	mov    %eax,-0x24(%ebp)
    prev->next = next->prev = elm;
c0109984:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109987:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010998a:	89 10                	mov    %edx,(%eax)
c010998c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010998f:	8b 10                	mov    (%eax),%edx
c0109991:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109994:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0109997:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010999a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010999d:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01099a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01099a3:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01099a6:	89 10                	mov    %edx,(%eax)
}
c01099a8:	83 c4 34             	add    $0x34,%esp
c01099ab:	5b                   	pop    %ebx
c01099ac:	5d                   	pop    %ebp
c01099ad:	c3                   	ret    

c01099ae <unhash_proc>:

// unhash_proc - delete proc from proc hash_list
static void
unhash_proc(struct proc_struct *proc) {
c01099ae:	55                   	push   %ebp
c01099af:	89 e5                	mov    %esp,%ebp
c01099b1:	83 ec 10             	sub    $0x10,%esp
    list_del(&(proc->hash_link));
c01099b4:	8b 45 08             	mov    0x8(%ebp),%eax
c01099b7:	83 c0 60             	add    $0x60,%eax
c01099ba:	89 45 fc             	mov    %eax,-0x4(%ebp)
    __list_del(listelm->prev, listelm->next);
c01099bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01099c0:	8b 40 04             	mov    0x4(%eax),%eax
c01099c3:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01099c6:	8b 12                	mov    (%edx),%edx
c01099c8:	89 55 f8             	mov    %edx,-0x8(%ebp)
c01099cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    prev->next = next;
c01099ce:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01099d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01099d4:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01099d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01099da:	8b 55 f8             	mov    -0x8(%ebp),%edx
c01099dd:	89 10                	mov    %edx,(%eax)
}
c01099df:	c9                   	leave  
c01099e0:	c3                   	ret    

c01099e1 <find_proc>:

// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
c01099e1:	55                   	push   %ebp
c01099e2:	89 e5                	mov    %esp,%ebp
c01099e4:	83 ec 28             	sub    $0x28,%esp
    if (0 < pid && pid < MAX_PID) {
c01099e7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01099eb:	7e 5f                	jle    c0109a4c <find_proc+0x6b>
c01099ed:	81 7d 08 ff 1f 00 00 	cmpl   $0x1fff,0x8(%ebp)
c01099f4:	7f 56                	jg     c0109a4c <find_proc+0x6b>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
c01099f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01099f9:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c0109a00:	00 
c0109a01:	89 04 24             	mov    %eax,(%esp)
c0109a04:	e8 53 23 00 00       	call   c010bd5c <hash32>
c0109a09:	c1 e0 03             	shl    $0x3,%eax
c0109a0c:	05 40 f0 19 c0       	add    $0xc019f040,%eax
c0109a11:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109a14:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109a17:	89 45 f4             	mov    %eax,-0xc(%ebp)
        while ((le = list_next(le)) != list) {
c0109a1a:	eb 19                	jmp    c0109a35 <find_proc+0x54>
            struct proc_struct *proc = le2proc(le, hash_link);
c0109a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109a1f:	83 e8 60             	sub    $0x60,%eax
c0109a22:	89 45 ec             	mov    %eax,-0x14(%ebp)
            if (proc->pid == pid) {
c0109a25:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109a28:	8b 40 04             	mov    0x4(%eax),%eax
c0109a2b:	3b 45 08             	cmp    0x8(%ebp),%eax
c0109a2e:	75 05                	jne    c0109a35 <find_proc+0x54>
                return proc;
c0109a30:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109a33:	eb 1c                	jmp    c0109a51 <find_proc+0x70>
c0109a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109a38:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return listelm->next;
c0109a3b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109a3e:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list) {
c0109a41:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109a44:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109a47:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0109a4a:	75 d0                	jne    c0109a1c <find_proc+0x3b>
            }
        }
    }
    return NULL;
c0109a4c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109a51:	c9                   	leave  
c0109a52:	c3                   	ret    

c0109a53 <kernel_thread>:

// kernel_thread - create a kernel thread using "fn" function
// NOTE: the contents of temp trapframe tf will be copied to 
//       proc->tf in do_fork-->copy_thread function
int
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
c0109a53:	55                   	push   %ebp
c0109a54:	89 e5                	mov    %esp,%ebp
c0109a56:	83 ec 68             	sub    $0x68,%esp
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
c0109a59:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
c0109a60:	00 
c0109a61:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109a68:	00 
c0109a69:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0109a6c:	89 04 24             	mov    %eax,(%esp)
c0109a6f:	e8 de 1a 00 00       	call   c010b552 <memset>
    tf.tf_cs = KERNEL_CS;
c0109a74:	66 c7 45 e8 08 00    	movw   $0x8,-0x18(%ebp)
    tf.tf_ds = tf.tf_es = tf.tf_ss = KERNEL_DS;
c0109a7a:	66 c7 45 f4 10 00    	movw   $0x10,-0xc(%ebp)
c0109a80:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0109a84:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
c0109a88:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
c0109a8c:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
    tf.tf_regs.reg_ebx = (uint32_t)fn;
c0109a90:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a93:	89 45 bc             	mov    %eax,-0x44(%ebp)
    tf.tf_regs.reg_edx = (uint32_t)arg;
c0109a96:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109a99:	89 45 c0             	mov    %eax,-0x40(%ebp)
    tf.tf_eip = (uint32_t)kernel_thread_entry;
c0109a9c:	b8 5d 92 10 c0       	mov    $0xc010925d,%eax
c0109aa1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
c0109aa4:	8b 45 10             	mov    0x10(%ebp),%eax
c0109aa7:	80 cc 01             	or     $0x1,%ah
c0109aaa:	89 c2                	mov    %eax,%edx
c0109aac:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0109aaf:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109ab3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109aba:	00 
c0109abb:	89 14 24             	mov    %edx,(%esp)
c0109abe:	e8 25 03 00 00       	call   c0109de8 <do_fork>
}
c0109ac3:	c9                   	leave  
c0109ac4:	c3                   	ret    

c0109ac5 <setup_kstack>:

// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
static int
setup_kstack(struct proc_struct *proc) {
c0109ac5:	55                   	push   %ebp
c0109ac6:	89 e5                	mov    %esp,%ebp
c0109ac8:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_pages(KSTACKPAGE);
c0109acb:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0109ad2:	e8 00 da ff ff       	call   c01074d7 <alloc_pages>
c0109ad7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c0109ada:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109ade:	74 1a                	je     c0109afa <setup_kstack+0x35>
        proc->kstack = (uintptr_t)page2kva(page);
c0109ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109ae3:	89 04 24             	mov    %eax,(%esp)
c0109ae6:	e8 1a f9 ff ff       	call   c0109405 <page2kva>
c0109aeb:	89 c2                	mov    %eax,%edx
c0109aed:	8b 45 08             	mov    0x8(%ebp),%eax
c0109af0:	89 50 0c             	mov    %edx,0xc(%eax)
        return 0;
c0109af3:	b8 00 00 00 00       	mov    $0x0,%eax
c0109af8:	eb 05                	jmp    c0109aff <setup_kstack+0x3a>
    }
    return -E_NO_MEM;
c0109afa:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
c0109aff:	c9                   	leave  
c0109b00:	c3                   	ret    

c0109b01 <put_kstack>:

// put_kstack - free the memory space of process kernel stack
static void
put_kstack(struct proc_struct *proc) {
c0109b01:	55                   	push   %ebp
c0109b02:	89 e5                	mov    %esp,%ebp
c0109b04:	83 ec 18             	sub    $0x18,%esp
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
c0109b07:	8b 45 08             	mov    0x8(%ebp),%eax
c0109b0a:	8b 40 0c             	mov    0xc(%eax),%eax
c0109b0d:	89 04 24             	mov    %eax,(%esp)
c0109b10:	e8 44 f9 ff ff       	call   c0109459 <kva2page>
c0109b15:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0109b1c:	00 
c0109b1d:	89 04 24             	mov    %eax,(%esp)
c0109b20:	e8 1d da ff ff       	call   c0107542 <free_pages>
}
c0109b25:	c9                   	leave  
c0109b26:	c3                   	ret    

c0109b27 <setup_pgdir>:

// setup_pgdir - alloc one page as PDT
static int
setup_pgdir(struct mm_struct *mm) {
c0109b27:	55                   	push   %ebp
c0109b28:	89 e5                	mov    %esp,%ebp
c0109b2a:	83 ec 28             	sub    $0x28,%esp
    struct Page *page;
    if ((page = alloc_page()) == NULL) {
c0109b2d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0109b34:	e8 9e d9 ff ff       	call   c01074d7 <alloc_pages>
c0109b39:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109b3c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109b40:	75 0a                	jne    c0109b4c <setup_pgdir+0x25>
        return -E_NO_MEM;
c0109b42:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0109b47:	e9 80 00 00 00       	jmp    c0109bcc <setup_pgdir+0xa5>
    }
    pde_t *pgdir = page2kva(page);
c0109b4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109b4f:	89 04 24             	mov    %eax,(%esp)
c0109b52:	e8 ae f8 ff ff       	call   c0109405 <page2kva>
c0109b57:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memcpy(pgdir, boot_pgdir, PGSIZE);
c0109b5a:	a1 20 aa 12 c0       	mov    0xc012aa20,%eax
c0109b5f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0109b66:	00 
c0109b67:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109b6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109b6e:	89 04 24             	mov    %eax,(%esp)
c0109b71:	e8 be 1a 00 00       	call   c010b634 <memcpy>
    pgdir[PDX(VPT)] = PADDR(pgdir) | PTE_P | PTE_W;
c0109b76:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109b79:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c0109b7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109b82:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109b85:	81 7d ec ff ff ff bf 	cmpl   $0xbfffffff,-0x14(%ebp)
c0109b8c:	77 23                	ja     c0109bb1 <setup_pgdir+0x8a>
c0109b8e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109b91:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109b95:	c7 44 24 08 1c df 10 	movl   $0xc010df1c,0x8(%esp)
c0109b9c:	c0 
c0109b9d:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
c0109ba4:	00 
c0109ba5:	c7 04 24 40 df 10 c0 	movl   $0xc010df40,(%esp)
c0109bac:	e8 4f 68 ff ff       	call   c0100400 <__panic>
c0109bb1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109bb4:	05 00 00 00 40       	add    $0x40000000,%eax
c0109bb9:	83 c8 03             	or     $0x3,%eax
c0109bbc:	89 02                	mov    %eax,(%edx)
    mm->pgdir = pgdir;
c0109bbe:	8b 45 08             	mov    0x8(%ebp),%eax
c0109bc1:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109bc4:	89 50 0c             	mov    %edx,0xc(%eax)
    return 0;
c0109bc7:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109bcc:	c9                   	leave  
c0109bcd:	c3                   	ret    

c0109bce <put_pgdir>:

// put_pgdir - free the memory space of PDT
static void
put_pgdir(struct mm_struct *mm) {
c0109bce:	55                   	push   %ebp
c0109bcf:	89 e5                	mov    %esp,%ebp
c0109bd1:	83 ec 18             	sub    $0x18,%esp
    free_page(kva2page(mm->pgdir));
c0109bd4:	8b 45 08             	mov    0x8(%ebp),%eax
c0109bd7:	8b 40 0c             	mov    0xc(%eax),%eax
c0109bda:	89 04 24             	mov    %eax,(%esp)
c0109bdd:	e8 77 f8 ff ff       	call   c0109459 <kva2page>
c0109be2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0109be9:	00 
c0109bea:	89 04 24             	mov    %eax,(%esp)
c0109bed:	e8 50 d9 ff ff       	call   c0107542 <free_pages>
}
c0109bf2:	c9                   	leave  
c0109bf3:	c3                   	ret    

c0109bf4 <copy_mm>:

// copy_mm - process "proc" duplicate OR share process "current"'s mm according clone_flags
//         - if clone_flags & CLONE_VM, then "share" ; else "duplicate"
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
c0109bf4:	55                   	push   %ebp
c0109bf5:	89 e5                	mov    %esp,%ebp
c0109bf7:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm, *oldmm = current->mm;
c0109bfa:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c0109bff:	8b 40 18             	mov    0x18(%eax),%eax
c0109c02:	89 45 ec             	mov    %eax,-0x14(%ebp)

    /* current is a kernel thread */
    if (oldmm == NULL) {
c0109c05:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0109c09:	75 0a                	jne    c0109c15 <copy_mm+0x21>
        return 0;
c0109c0b:	b8 00 00 00 00       	mov    $0x0,%eax
c0109c10:	e9 f9 00 00 00       	jmp    c0109d0e <copy_mm+0x11a>
    }
    if (clone_flags & CLONE_VM) {
c0109c15:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c18:	25 00 01 00 00       	and    $0x100,%eax
c0109c1d:	85 c0                	test   %eax,%eax
c0109c1f:	74 08                	je     c0109c29 <copy_mm+0x35>
        mm = oldmm;
c0109c21:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109c24:	89 45 f4             	mov    %eax,-0xc(%ebp)
        goto good_mm;
c0109c27:	eb 78                	jmp    c0109ca1 <copy_mm+0xad>
    }

    int ret = -E_NO_MEM;
c0109c29:	c7 45 f0 fc ff ff ff 	movl   $0xfffffffc,-0x10(%ebp)
    if ((mm = mm_create()) == NULL) {
c0109c30:	e8 a0 99 ff ff       	call   c01035d5 <mm_create>
c0109c35:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109c38:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109c3c:	75 05                	jne    c0109c43 <copy_mm+0x4f>
        goto bad_mm;
c0109c3e:	e9 c8 00 00 00       	jmp    c0109d0b <copy_mm+0x117>
    }
    if (setup_pgdir(mm) != 0) {
c0109c43:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109c46:	89 04 24             	mov    %eax,(%esp)
c0109c49:	e8 d9 fe ff ff       	call   c0109b27 <setup_pgdir>
c0109c4e:	85 c0                	test   %eax,%eax
c0109c50:	74 05                	je     c0109c57 <copy_mm+0x63>
        goto bad_pgdir_cleanup_mm;
c0109c52:	e9 a9 00 00 00       	jmp    c0109d00 <copy_mm+0x10c>
    }

    lock_mm(oldmm);
c0109c57:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109c5a:	89 04 24             	mov    %eax,(%esp)
c0109c5d:	e8 75 f8 ff ff       	call   c01094d7 <lock_mm>
    {
        ret = dup_mmap(mm, oldmm);
c0109c62:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109c65:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109c69:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109c6c:	89 04 24             	mov    %eax,(%esp)
c0109c6f:	e8 78 9e ff ff       	call   c0103aec <dup_mmap>
c0109c74:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    unlock_mm(oldmm);
c0109c77:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109c7a:	89 04 24             	mov    %eax,(%esp)
c0109c7d:	e8 71 f8 ff ff       	call   c01094f3 <unlock_mm>

    if (ret != 0) {
c0109c82:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0109c86:	74 19                	je     c0109ca1 <copy_mm+0xad>
        goto bad_dup_cleanup_mmap;
c0109c88:	90                   	nop
    mm_count_inc(mm);
    proc->mm = mm;
    proc->cr3 = PADDR(mm->pgdir);
    return 0;
bad_dup_cleanup_mmap:
    exit_mmap(mm);
c0109c89:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109c8c:	89 04 24             	mov    %eax,(%esp)
c0109c8f:	e8 59 9f ff ff       	call   c0103bed <exit_mmap>
    put_pgdir(mm);
c0109c94:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109c97:	89 04 24             	mov    %eax,(%esp)
c0109c9a:	e8 2f ff ff ff       	call   c0109bce <put_pgdir>
c0109c9f:	eb 5f                	jmp    c0109d00 <copy_mm+0x10c>
    mm_count_inc(mm);
c0109ca1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109ca4:	89 04 24             	mov    %eax,(%esp)
c0109ca7:	e8 f7 f7 ff ff       	call   c01094a3 <mm_count_inc>
    proc->mm = mm;
c0109cac:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109caf:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109cb2:	89 50 18             	mov    %edx,0x18(%eax)
    proc->cr3 = PADDR(mm->pgdir);
c0109cb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109cb8:	8b 40 0c             	mov    0xc(%eax),%eax
c0109cbb:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109cbe:	81 7d e8 ff ff ff bf 	cmpl   $0xbfffffff,-0x18(%ebp)
c0109cc5:	77 23                	ja     c0109cea <copy_mm+0xf6>
c0109cc7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109cca:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109cce:	c7 44 24 08 1c df 10 	movl   $0xc010df1c,0x8(%esp)
c0109cd5:	c0 
c0109cd6:	c7 44 24 04 5d 01 00 	movl   $0x15d,0x4(%esp)
c0109cdd:	00 
c0109cde:	c7 04 24 40 df 10 c0 	movl   $0xc010df40,(%esp)
c0109ce5:	e8 16 67 ff ff       	call   c0100400 <__panic>
c0109cea:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109ced:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c0109cf3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109cf6:	89 50 40             	mov    %edx,0x40(%eax)
    return 0;
c0109cf9:	b8 00 00 00 00       	mov    $0x0,%eax
c0109cfe:	eb 0e                	jmp    c0109d0e <copy_mm+0x11a>
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
c0109d00:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109d03:	89 04 24             	mov    %eax,(%esp)
c0109d06:	e8 23 9c ff ff       	call   c010392e <mm_destroy>
bad_mm:
    return ret;
c0109d0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0109d0e:	c9                   	leave  
c0109d0f:	c3                   	ret    

c0109d10 <copy_thread>:

// copy_thread - setup the trapframe on the  process's kernel stack top and
//             - setup the kernel entry point and stack of process
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) {
c0109d10:	55                   	push   %ebp
c0109d11:	89 e5                	mov    %esp,%ebp
c0109d13:	57                   	push   %edi
c0109d14:	56                   	push   %esi
c0109d15:	53                   	push   %ebx
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
c0109d16:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d19:	8b 40 0c             	mov    0xc(%eax),%eax
c0109d1c:	05 b4 1f 00 00       	add    $0x1fb4,%eax
c0109d21:	89 c2                	mov    %eax,%edx
c0109d23:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d26:	89 50 3c             	mov    %edx,0x3c(%eax)
    *(proc->tf) = *tf;
c0109d29:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d2c:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109d2f:	8b 55 10             	mov    0x10(%ebp),%edx
c0109d32:	bb 4c 00 00 00       	mov    $0x4c,%ebx
c0109d37:	89 c1                	mov    %eax,%ecx
c0109d39:	83 e1 01             	and    $0x1,%ecx
c0109d3c:	85 c9                	test   %ecx,%ecx
c0109d3e:	74 0e                	je     c0109d4e <copy_thread+0x3e>
c0109d40:	0f b6 0a             	movzbl (%edx),%ecx
c0109d43:	88 08                	mov    %cl,(%eax)
c0109d45:	83 c0 01             	add    $0x1,%eax
c0109d48:	83 c2 01             	add    $0x1,%edx
c0109d4b:	83 eb 01             	sub    $0x1,%ebx
c0109d4e:	89 c1                	mov    %eax,%ecx
c0109d50:	83 e1 02             	and    $0x2,%ecx
c0109d53:	85 c9                	test   %ecx,%ecx
c0109d55:	74 0f                	je     c0109d66 <copy_thread+0x56>
c0109d57:	0f b7 0a             	movzwl (%edx),%ecx
c0109d5a:	66 89 08             	mov    %cx,(%eax)
c0109d5d:	83 c0 02             	add    $0x2,%eax
c0109d60:	83 c2 02             	add    $0x2,%edx
c0109d63:	83 eb 02             	sub    $0x2,%ebx
c0109d66:	89 d9                	mov    %ebx,%ecx
c0109d68:	c1 e9 02             	shr    $0x2,%ecx
c0109d6b:	89 c7                	mov    %eax,%edi
c0109d6d:	89 d6                	mov    %edx,%esi
c0109d6f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0109d71:	89 f2                	mov    %esi,%edx
c0109d73:	89 f8                	mov    %edi,%eax
c0109d75:	b9 00 00 00 00       	mov    $0x0,%ecx
c0109d7a:	89 de                	mov    %ebx,%esi
c0109d7c:	83 e6 02             	and    $0x2,%esi
c0109d7f:	85 f6                	test   %esi,%esi
c0109d81:	74 0b                	je     c0109d8e <copy_thread+0x7e>
c0109d83:	0f b7 34 0a          	movzwl (%edx,%ecx,1),%esi
c0109d87:	66 89 34 08          	mov    %si,(%eax,%ecx,1)
c0109d8b:	83 c1 02             	add    $0x2,%ecx
c0109d8e:	83 e3 01             	and    $0x1,%ebx
c0109d91:	85 db                	test   %ebx,%ebx
c0109d93:	74 07                	je     c0109d9c <copy_thread+0x8c>
c0109d95:	0f b6 14 0a          	movzbl (%edx,%ecx,1),%edx
c0109d99:	88 14 08             	mov    %dl,(%eax,%ecx,1)
    proc->tf->tf_regs.reg_eax = 0;
c0109d9c:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d9f:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109da2:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    proc->tf->tf_esp = esp;
c0109da9:	8b 45 08             	mov    0x8(%ebp),%eax
c0109dac:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109daf:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109db2:	89 50 44             	mov    %edx,0x44(%eax)
    proc->tf->tf_eflags |= FL_IF;
c0109db5:	8b 45 08             	mov    0x8(%ebp),%eax
c0109db8:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109dbb:	8b 55 08             	mov    0x8(%ebp),%edx
c0109dbe:	8b 52 3c             	mov    0x3c(%edx),%edx
c0109dc1:	8b 52 40             	mov    0x40(%edx),%edx
c0109dc4:	80 ce 02             	or     $0x2,%dh
c0109dc7:	89 50 40             	mov    %edx,0x40(%eax)

    proc->context.eip = (uintptr_t)forkret;
c0109dca:	ba 1a 99 10 c0       	mov    $0xc010991a,%edx
c0109dcf:	8b 45 08             	mov    0x8(%ebp),%eax
c0109dd2:	89 50 1c             	mov    %edx,0x1c(%eax)
    proc->context.esp = (uintptr_t)(proc->tf);
c0109dd5:	8b 45 08             	mov    0x8(%ebp),%eax
c0109dd8:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109ddb:	89 c2                	mov    %eax,%edx
c0109ddd:	8b 45 08             	mov    0x8(%ebp),%eax
c0109de0:	89 50 20             	mov    %edx,0x20(%eax)
}
c0109de3:	5b                   	pop    %ebx
c0109de4:	5e                   	pop    %esi
c0109de5:	5f                   	pop    %edi
c0109de6:	5d                   	pop    %ebp
c0109de7:	c3                   	ret    

c0109de8 <do_fork>:
 * @clone_flags: used to guide how to clone the child process
 * @stack:       the parent's user stack pointer. if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child process's proc->tf
 */
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
c0109de8:	55                   	push   %ebp
c0109de9:	89 e5                	mov    %esp,%ebp
c0109deb:	83 ec 28             	sub    $0x28,%esp
    int ret = -E_NO_FREE_PROC;
c0109dee:	c7 45 f4 fb ff ff ff 	movl   $0xfffffffb,-0xc(%ebp)
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
c0109df5:	a1 40 10 1a c0       	mov    0xc01a1040,%eax
c0109dfa:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c0109dff:	7e 05                	jle    c0109e06 <do_fork+0x1e>
        goto fork_out;
c0109e01:	e9 ef 00 00 00       	jmp    c0109ef5 <do_fork+0x10d>
    }
    ret = -E_NO_MEM;
c0109e06:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
    *    set_links:  set the relation links of process.  ALSO SEE: remove_links:  lean the relation links of process 
    *    -------------------
	*    update step 1: set child proc's parent to current process, make sure current process's wait_state is 0
	*    update step 5: insert proc_struct into hash_list && proc_list, set the relation links of process
    */
    if ((proc = alloc_proc()) == NULL) {
c0109e0d:	e8 fd f6 ff ff       	call   c010950f <alloc_proc>
c0109e12:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109e15:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0109e19:	75 05                	jne    c0109e20 <do_fork+0x38>
        goto fork_out;
c0109e1b:	e9 d5 00 00 00       	jmp    c0109ef5 <do_fork+0x10d>
    }

    proc->parent = current;
c0109e20:	8b 15 28 f0 19 c0    	mov    0xc019f028,%edx
c0109e26:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109e29:	89 50 14             	mov    %edx,0x14(%eax)
    assert(current->wait_state == 0);
c0109e2c:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c0109e31:	8b 40 6c             	mov    0x6c(%eax),%eax
c0109e34:	85 c0                	test   %eax,%eax
c0109e36:	74 24                	je     c0109e5c <do_fork+0x74>
c0109e38:	c7 44 24 0c 54 df 10 	movl   $0xc010df54,0xc(%esp)
c0109e3f:	c0 
c0109e40:	c7 44 24 08 6d df 10 	movl   $0xc010df6d,0x8(%esp)
c0109e47:	c0 
c0109e48:	c7 44 24 04 a8 01 00 	movl   $0x1a8,0x4(%esp)
c0109e4f:	00 
c0109e50:	c7 04 24 40 df 10 c0 	movl   $0xc010df40,(%esp)
c0109e57:	e8 a4 65 ff ff       	call   c0100400 <__panic>

    if (setup_kstack(proc) != 0) {
c0109e5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109e5f:	89 04 24             	mov    %eax,(%esp)
c0109e62:	e8 5e fc ff ff       	call   c0109ac5 <setup_kstack>
c0109e67:	85 c0                	test   %eax,%eax
c0109e69:	74 05                	je     c0109e70 <do_fork+0x88>
        goto bad_fork_cleanup_proc;
c0109e6b:	e9 8a 00 00 00       	jmp    c0109efa <do_fork+0x112>
    }
    if (copy_mm(clone_flags, proc) != 0) {
c0109e70:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109e73:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109e77:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e7a:	89 04 24             	mov    %eax,(%esp)
c0109e7d:	e8 72 fd ff ff       	call   c0109bf4 <copy_mm>
c0109e82:	85 c0                	test   %eax,%eax
c0109e84:	74 0e                	je     c0109e94 <do_fork+0xac>
        goto bad_fork_cleanup_kstack;
c0109e86:	90                   	nop
    ret = proc->pid;
fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
c0109e87:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109e8a:	89 04 24             	mov    %eax,(%esp)
c0109e8d:	e8 6f fc ff ff       	call   c0109b01 <put_kstack>
c0109e92:	eb 66                	jmp    c0109efa <do_fork+0x112>
    copy_thread(proc, stack, tf);
c0109e94:	8b 45 10             	mov    0x10(%ebp),%eax
c0109e97:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109e9b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109e9e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109ea2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109ea5:	89 04 24             	mov    %eax,(%esp)
c0109ea8:	e8 63 fe ff ff       	call   c0109d10 <copy_thread>
    local_intr_save(intr_flag);
c0109ead:	e8 2b f4 ff ff       	call   c01092dd <__intr_save>
c0109eb2:	89 45 ec             	mov    %eax,-0x14(%ebp)
        proc->pid = get_pid();
c0109eb5:	e8 f3 f8 ff ff       	call   c01097ad <get_pid>
c0109eba:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109ebd:	89 42 04             	mov    %eax,0x4(%edx)
        hash_proc(proc);
c0109ec0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109ec3:	89 04 24             	mov    %eax,(%esp)
c0109ec6:	e8 67 fa ff ff       	call   c0109932 <hash_proc>
        set_links(proc);
c0109ecb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109ece:	89 04 24             	mov    %eax,(%esp)
c0109ed1:	e8 af f7 ff ff       	call   c0109685 <set_links>
    local_intr_restore(intr_flag);
c0109ed6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109ed9:	89 04 24             	mov    %eax,(%esp)
c0109edc:	e8 26 f4 ff ff       	call   c0109307 <__intr_restore>
    wakeup_proc(proc);
c0109ee1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109ee4:	89 04 24             	mov    %eax,(%esp)
c0109ee7:	e8 f5 0f 00 00       	call   c010aee1 <wakeup_proc>
    ret = proc->pid;
c0109eec:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109eef:	8b 40 04             	mov    0x4(%eax),%eax
c0109ef2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c0109ef5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109ef8:	eb 0d                	jmp    c0109f07 <do_fork+0x11f>
bad_fork_cleanup_proc:
    kfree(proc);
c0109efa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109efd:	89 04 24             	mov    %eax,(%esp)
c0109f00:	e8 08 b4 ff ff       	call   c010530d <kfree>
    goto fork_out;
c0109f05:	eb ee                	jmp    c0109ef5 <do_fork+0x10d>
}
c0109f07:	c9                   	leave  
c0109f08:	c3                   	ret    

c0109f09 <do_exit>:
// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int
do_exit(int error_code) {
c0109f09:	55                   	push   %ebp
c0109f0a:	89 e5                	mov    %esp,%ebp
c0109f0c:	83 ec 28             	sub    $0x28,%esp
    if (current == idleproc) {
c0109f0f:	8b 15 28 f0 19 c0    	mov    0xc019f028,%edx
c0109f15:	a1 20 f0 19 c0       	mov    0xc019f020,%eax
c0109f1a:	39 c2                	cmp    %eax,%edx
c0109f1c:	75 1c                	jne    c0109f3a <do_exit+0x31>
        panic("idleproc exit.\n");
c0109f1e:	c7 44 24 08 82 df 10 	movl   $0xc010df82,0x8(%esp)
c0109f25:	c0 
c0109f26:	c7 44 24 04 d0 01 00 	movl   $0x1d0,0x4(%esp)
c0109f2d:	00 
c0109f2e:	c7 04 24 40 df 10 c0 	movl   $0xc010df40,(%esp)
c0109f35:	e8 c6 64 ff ff       	call   c0100400 <__panic>
    }
    if (current == initproc) {
c0109f3a:	8b 15 28 f0 19 c0    	mov    0xc019f028,%edx
c0109f40:	a1 24 f0 19 c0       	mov    0xc019f024,%eax
c0109f45:	39 c2                	cmp    %eax,%edx
c0109f47:	75 1c                	jne    c0109f65 <do_exit+0x5c>
        panic("initproc exit.\n");
c0109f49:	c7 44 24 08 92 df 10 	movl   $0xc010df92,0x8(%esp)
c0109f50:	c0 
c0109f51:	c7 44 24 04 d3 01 00 	movl   $0x1d3,0x4(%esp)
c0109f58:	00 
c0109f59:	c7 04 24 40 df 10 c0 	movl   $0xc010df40,(%esp)
c0109f60:	e8 9b 64 ff ff       	call   c0100400 <__panic>
    }
    
    struct mm_struct *mm = current->mm;
c0109f65:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c0109f6a:	8b 40 18             	mov    0x18(%eax),%eax
c0109f6d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (mm != NULL) {
c0109f70:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109f74:	74 4a                	je     c0109fc0 <do_exit+0xb7>
        lcr3(boot_cr3);
c0109f76:	a1 54 11 1a c0       	mov    0xc01a1154,%eax
c0109f7b:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109f7e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109f81:	0f 22 d8             	mov    %eax,%cr3
        if (mm_count_dec(mm) == 0) {
c0109f84:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109f87:	89 04 24             	mov    %eax,(%esp)
c0109f8a:	e8 2e f5 ff ff       	call   c01094bd <mm_count_dec>
c0109f8f:	85 c0                	test   %eax,%eax
c0109f91:	75 21                	jne    c0109fb4 <do_exit+0xab>
            exit_mmap(mm);
c0109f93:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109f96:	89 04 24             	mov    %eax,(%esp)
c0109f99:	e8 4f 9c ff ff       	call   c0103bed <exit_mmap>
            put_pgdir(mm);
c0109f9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109fa1:	89 04 24             	mov    %eax,(%esp)
c0109fa4:	e8 25 fc ff ff       	call   c0109bce <put_pgdir>
            mm_destroy(mm);
c0109fa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109fac:	89 04 24             	mov    %eax,(%esp)
c0109faf:	e8 7a 99 ff ff       	call   c010392e <mm_destroy>
        }
        current->mm = NULL;
c0109fb4:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c0109fb9:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
    }
    current->state = PROC_ZOMBIE;
c0109fc0:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c0109fc5:	c7 00 03 00 00 00    	movl   $0x3,(%eax)
    current->exit_code = error_code;
c0109fcb:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c0109fd0:	8b 55 08             	mov    0x8(%ebp),%edx
c0109fd3:	89 50 68             	mov    %edx,0x68(%eax)
    
    bool intr_flag;
    struct proc_struct *proc;
    local_intr_save(intr_flag);
c0109fd6:	e8 02 f3 ff ff       	call   c01092dd <__intr_save>
c0109fdb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        proc = current->parent;
c0109fde:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c0109fe3:	8b 40 14             	mov    0x14(%eax),%eax
c0109fe6:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (proc->wait_state == WT_CHILD) {
c0109fe9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109fec:	8b 40 6c             	mov    0x6c(%eax),%eax
c0109fef:	3d 01 00 00 80       	cmp    $0x80000001,%eax
c0109ff4:	75 10                	jne    c010a006 <do_exit+0xfd>
            wakeup_proc(proc);
c0109ff6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109ff9:	89 04 24             	mov    %eax,(%esp)
c0109ffc:	e8 e0 0e 00 00       	call   c010aee1 <wakeup_proc>
        }
        while (current->cptr != NULL) {
c010a001:	e9 8b 00 00 00       	jmp    c010a091 <do_exit+0x188>
c010a006:	e9 86 00 00 00       	jmp    c010a091 <do_exit+0x188>
            proc = current->cptr;
c010a00b:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c010a010:	8b 40 70             	mov    0x70(%eax),%eax
c010a013:	89 45 ec             	mov    %eax,-0x14(%ebp)
            current->cptr = proc->optr;
c010a016:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c010a01b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a01e:	8b 52 78             	mov    0x78(%edx),%edx
c010a021:	89 50 70             	mov    %edx,0x70(%eax)
    
            proc->yptr = NULL;
c010a024:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a027:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
            if ((proc->optr = initproc->cptr) != NULL) {
c010a02e:	a1 24 f0 19 c0       	mov    0xc019f024,%eax
c010a033:	8b 50 70             	mov    0x70(%eax),%edx
c010a036:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a039:	89 50 78             	mov    %edx,0x78(%eax)
c010a03c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a03f:	8b 40 78             	mov    0x78(%eax),%eax
c010a042:	85 c0                	test   %eax,%eax
c010a044:	74 0e                	je     c010a054 <do_exit+0x14b>
                initproc->cptr->yptr = proc;
c010a046:	a1 24 f0 19 c0       	mov    0xc019f024,%eax
c010a04b:	8b 40 70             	mov    0x70(%eax),%eax
c010a04e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a051:	89 50 74             	mov    %edx,0x74(%eax)
            }
            proc->parent = initproc;
c010a054:	8b 15 24 f0 19 c0    	mov    0xc019f024,%edx
c010a05a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a05d:	89 50 14             	mov    %edx,0x14(%eax)
            initproc->cptr = proc;
c010a060:	a1 24 f0 19 c0       	mov    0xc019f024,%eax
c010a065:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a068:	89 50 70             	mov    %edx,0x70(%eax)
            if (proc->state == PROC_ZOMBIE) {
c010a06b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a06e:	8b 00                	mov    (%eax),%eax
c010a070:	83 f8 03             	cmp    $0x3,%eax
c010a073:	75 1c                	jne    c010a091 <do_exit+0x188>
                if (initproc->wait_state == WT_CHILD) {
c010a075:	a1 24 f0 19 c0       	mov    0xc019f024,%eax
c010a07a:	8b 40 6c             	mov    0x6c(%eax),%eax
c010a07d:	3d 01 00 00 80       	cmp    $0x80000001,%eax
c010a082:	75 0d                	jne    c010a091 <do_exit+0x188>
                    wakeup_proc(initproc);
c010a084:	a1 24 f0 19 c0       	mov    0xc019f024,%eax
c010a089:	89 04 24             	mov    %eax,(%esp)
c010a08c:	e8 50 0e 00 00       	call   c010aee1 <wakeup_proc>
        while (current->cptr != NULL) {
c010a091:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c010a096:	8b 40 70             	mov    0x70(%eax),%eax
c010a099:	85 c0                	test   %eax,%eax
c010a09b:	0f 85 6a ff ff ff    	jne    c010a00b <do_exit+0x102>
                }
            }
        }
    }
    local_intr_restore(intr_flag);
c010a0a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a0a4:	89 04 24             	mov    %eax,(%esp)
c010a0a7:	e8 5b f2 ff ff       	call   c0109307 <__intr_restore>
    
    schedule();
c010a0ac:	e8 b4 0e 00 00       	call   c010af65 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
c010a0b1:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c010a0b6:	8b 40 04             	mov    0x4(%eax),%eax
c010a0b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a0bd:	c7 44 24 08 a4 df 10 	movl   $0xc010dfa4,0x8(%esp)
c010a0c4:	c0 
c010a0c5:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
c010a0cc:	00 
c010a0cd:	c7 04 24 40 df 10 c0 	movl   $0xc010df40,(%esp)
c010a0d4:	e8 27 63 ff ff       	call   c0100400 <__panic>

c010a0d9 <load_icode>:
/* load_icode - load the content of binary program(ELF format) as the new content of current process
 * @binary:  the memory addr of the content of binary program
 * @size:  the size of the content of binary program
 */
static int
load_icode(unsigned char *binary, size_t size) {
c010a0d9:	55                   	push   %ebp
c010a0da:	89 e5                	mov    %esp,%ebp
c010a0dc:	83 ec 78             	sub    $0x78,%esp
    if (current->mm != NULL) {
c010a0df:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c010a0e4:	8b 40 18             	mov    0x18(%eax),%eax
c010a0e7:	85 c0                	test   %eax,%eax
c010a0e9:	74 1c                	je     c010a107 <load_icode+0x2e>
        panic("load_icode: current->mm must be empty.\n");
c010a0eb:	c7 44 24 08 c4 df 10 	movl   $0xc010dfc4,0x8(%esp)
c010a0f2:	c0 
c010a0f3:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
c010a0fa:	00 
c010a0fb:	c7 04 24 40 df 10 c0 	movl   $0xc010df40,(%esp)
c010a102:	e8 f9 62 ff ff       	call   c0100400 <__panic>
    }

    int ret = -E_NO_MEM;
c010a107:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
    struct mm_struct *mm;
    //(1) create a new mm for current process
    if ((mm = mm_create()) == NULL) {
c010a10e:	e8 c2 94 ff ff       	call   c01035d5 <mm_create>
c010a113:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010a116:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c010a11a:	75 06                	jne    c010a122 <load_icode+0x49>
        goto bad_mm;
c010a11c:	90                   	nop
bad_elf_cleanup_pgdir:
    put_pgdir(mm);
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
bad_mm:
    goto out;
c010a11d:	e9 ef 05 00 00       	jmp    c010a711 <load_icode+0x638>
    if (setup_pgdir(mm) != 0) {
c010a122:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a125:	89 04 24             	mov    %eax,(%esp)
c010a128:	e8 fa f9 ff ff       	call   c0109b27 <setup_pgdir>
c010a12d:	85 c0                	test   %eax,%eax
c010a12f:	74 05                	je     c010a136 <load_icode+0x5d>
        goto bad_pgdir_cleanup_mm;
c010a131:	e9 f6 05 00 00       	jmp    c010a72c <load_icode+0x653>
    struct elfhdr *elf = (struct elfhdr *)binary;
c010a136:	8b 45 08             	mov    0x8(%ebp),%eax
c010a139:	89 45 cc             	mov    %eax,-0x34(%ebp)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
c010a13c:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a13f:	8b 50 1c             	mov    0x1c(%eax),%edx
c010a142:	8b 45 08             	mov    0x8(%ebp),%eax
c010a145:	01 d0                	add    %edx,%eax
c010a147:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (elf->e_magic != ELF_MAGIC) {
c010a14a:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a14d:	8b 00                	mov    (%eax),%eax
c010a14f:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
c010a154:	74 0c                	je     c010a162 <load_icode+0x89>
        ret = -E_INVAL_ELF;
c010a156:	c7 45 f4 f8 ff ff ff 	movl   $0xfffffff8,-0xc(%ebp)
        goto bad_elf_cleanup_pgdir;
c010a15d:	e9 bf 05 00 00       	jmp    c010a721 <load_icode+0x648>
    struct proghdr *ph_end = ph + elf->e_phnum;
c010a162:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a165:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c010a169:	0f b7 c0             	movzwl %ax,%eax
c010a16c:	c1 e0 05             	shl    $0x5,%eax
c010a16f:	89 c2                	mov    %eax,%edx
c010a171:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a174:	01 d0                	add    %edx,%eax
c010a176:	89 45 c8             	mov    %eax,-0x38(%ebp)
    for (; ph < ph_end; ph ++) {
c010a179:	e9 13 03 00 00       	jmp    c010a491 <load_icode+0x3b8>
        if (ph->p_type != ELF_PT_LOAD) {
c010a17e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a181:	8b 00                	mov    (%eax),%eax
c010a183:	83 f8 01             	cmp    $0x1,%eax
c010a186:	74 05                	je     c010a18d <load_icode+0xb4>
            continue ;
c010a188:	e9 00 03 00 00       	jmp    c010a48d <load_icode+0x3b4>
        if (ph->p_filesz > ph->p_memsz) {
c010a18d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a190:	8b 50 10             	mov    0x10(%eax),%edx
c010a193:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a196:	8b 40 14             	mov    0x14(%eax),%eax
c010a199:	39 c2                	cmp    %eax,%edx
c010a19b:	76 0c                	jbe    c010a1a9 <load_icode+0xd0>
            ret = -E_INVAL_ELF;
c010a19d:	c7 45 f4 f8 ff ff ff 	movl   $0xfffffff8,-0xc(%ebp)
            goto bad_cleanup_mmap;
c010a1a4:	e9 6d 05 00 00       	jmp    c010a716 <load_icode+0x63d>
        if (ph->p_filesz == 0) {
c010a1a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a1ac:	8b 40 10             	mov    0x10(%eax),%eax
c010a1af:	85 c0                	test   %eax,%eax
c010a1b1:	75 05                	jne    c010a1b8 <load_icode+0xdf>
            continue ;
c010a1b3:	e9 d5 02 00 00       	jmp    c010a48d <load_icode+0x3b4>
        vm_flags = 0, perm = PTE_U;
c010a1b8:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c010a1bf:	c7 45 e4 04 00 00 00 	movl   $0x4,-0x1c(%ebp)
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
c010a1c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a1c9:	8b 40 18             	mov    0x18(%eax),%eax
c010a1cc:	83 e0 01             	and    $0x1,%eax
c010a1cf:	85 c0                	test   %eax,%eax
c010a1d1:	74 04                	je     c010a1d7 <load_icode+0xfe>
c010a1d3:	83 4d e8 04          	orl    $0x4,-0x18(%ebp)
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
c010a1d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a1da:	8b 40 18             	mov    0x18(%eax),%eax
c010a1dd:	83 e0 02             	and    $0x2,%eax
c010a1e0:	85 c0                	test   %eax,%eax
c010a1e2:	74 04                	je     c010a1e8 <load_icode+0x10f>
c010a1e4:	83 4d e8 02          	orl    $0x2,-0x18(%ebp)
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
c010a1e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a1eb:	8b 40 18             	mov    0x18(%eax),%eax
c010a1ee:	83 e0 04             	and    $0x4,%eax
c010a1f1:	85 c0                	test   %eax,%eax
c010a1f3:	74 04                	je     c010a1f9 <load_icode+0x120>
c010a1f5:	83 4d e8 01          	orl    $0x1,-0x18(%ebp)
        if (vm_flags & VM_WRITE) perm |= PTE_W;
c010a1f9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a1fc:	83 e0 02             	and    $0x2,%eax
c010a1ff:	85 c0                	test   %eax,%eax
c010a201:	74 04                	je     c010a207 <load_icode+0x12e>
c010a203:	83 4d e4 02          	orl    $0x2,-0x1c(%ebp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
c010a207:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a20a:	8b 50 14             	mov    0x14(%eax),%edx
c010a20d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a210:	8b 40 08             	mov    0x8(%eax),%eax
c010a213:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
c010a21a:	00 
c010a21b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010a21e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010a222:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a226:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a22a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a22d:	89 04 24             	mov    %eax,(%esp)
c010a230:	e8 9b 97 ff ff       	call   c01039d0 <mm_map>
c010a235:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a238:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a23c:	74 05                	je     c010a243 <load_icode+0x16a>
            goto bad_cleanup_mmap;
c010a23e:	e9 d3 04 00 00       	jmp    c010a716 <load_icode+0x63d>
        unsigned char *from = binary + ph->p_offset;
c010a243:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a246:	8b 50 04             	mov    0x4(%eax),%edx
c010a249:	8b 45 08             	mov    0x8(%ebp),%eax
c010a24c:	01 d0                	add    %edx,%eax
c010a24e:	89 45 e0             	mov    %eax,-0x20(%ebp)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
c010a251:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a254:	8b 40 08             	mov    0x8(%eax),%eax
c010a257:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010a25a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a25d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c010a260:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010a263:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010a268:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        ret = -E_NO_MEM;
c010a26b:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
        end = ph->p_va + ph->p_filesz;
c010a272:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a275:	8b 50 08             	mov    0x8(%eax),%edx
c010a278:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a27b:	8b 40 10             	mov    0x10(%eax),%eax
c010a27e:	01 d0                	add    %edx,%eax
c010a280:	89 45 c0             	mov    %eax,-0x40(%ebp)
        while (start < end) {
c010a283:	e9 90 00 00 00       	jmp    c010a318 <load_icode+0x23f>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
c010a288:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a28b:	8b 40 0c             	mov    0xc(%eax),%eax
c010a28e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010a291:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a295:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010a298:	89 54 24 04          	mov    %edx,0x4(%esp)
c010a29c:	89 04 24             	mov    %eax,(%esp)
c010a29f:	e8 87 e0 ff ff       	call   c010832b <pgdir_alloc_page>
c010a2a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a2a7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a2ab:	75 05                	jne    c010a2b2 <load_icode+0x1d9>
                goto bad_cleanup_mmap;
c010a2ad:	e9 64 04 00 00       	jmp    c010a716 <load_icode+0x63d>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
c010a2b2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a2b5:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010a2b8:	29 c2                	sub    %eax,%edx
c010a2ba:	89 d0                	mov    %edx,%eax
c010a2bc:	89 45 bc             	mov    %eax,-0x44(%ebp)
c010a2bf:	b8 00 10 00 00       	mov    $0x1000,%eax
c010a2c4:	2b 45 bc             	sub    -0x44(%ebp),%eax
c010a2c7:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010a2ca:	81 45 d4 00 10 00 00 	addl   $0x1000,-0x2c(%ebp)
            if (end < la) {
c010a2d1:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a2d4:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a2d7:	73 0d                	jae    c010a2e6 <load_icode+0x20d>
                size -= la - end;
c010a2d9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a2dc:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010a2df:	29 c2                	sub    %eax,%edx
c010a2e1:	89 d0                	mov    %edx,%eax
c010a2e3:	01 45 dc             	add    %eax,-0x24(%ebp)
            memcpy(page2kva(page) + off, from, size);
c010a2e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a2e9:	89 04 24             	mov    %eax,(%esp)
c010a2ec:	e8 14 f1 ff ff       	call   c0109405 <page2kva>
c010a2f1:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010a2f4:	01 c2                	add    %eax,%edx
c010a2f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a2f9:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a2fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010a300:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a304:	89 14 24             	mov    %edx,(%esp)
c010a307:	e8 28 13 00 00       	call   c010b634 <memcpy>
            start += size, from += size;
c010a30c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a30f:	01 45 d8             	add    %eax,-0x28(%ebp)
c010a312:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a315:	01 45 e0             	add    %eax,-0x20(%ebp)
        while (start < end) {
c010a318:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a31b:	3b 45 c0             	cmp    -0x40(%ebp),%eax
c010a31e:	0f 82 64 ff ff ff    	jb     c010a288 <load_icode+0x1af>
        end = ph->p_va + ph->p_memsz;
c010a324:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a327:	8b 50 08             	mov    0x8(%eax),%edx
c010a32a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a32d:	8b 40 14             	mov    0x14(%eax),%eax
c010a330:	01 d0                	add    %edx,%eax
c010a332:	89 45 c0             	mov    %eax,-0x40(%ebp)
        if (start < la) {
c010a335:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a338:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a33b:	0f 83 b0 00 00 00    	jae    c010a3f1 <load_icode+0x318>
            if (start == end) {
c010a341:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a344:	3b 45 c0             	cmp    -0x40(%ebp),%eax
c010a347:	75 05                	jne    c010a34e <load_icode+0x275>
                continue ;
c010a349:	e9 3f 01 00 00       	jmp    c010a48d <load_icode+0x3b4>
            off = start + PGSIZE - la, size = PGSIZE - off;
c010a34e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a351:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010a354:	29 c2                	sub    %eax,%edx
c010a356:	89 d0                	mov    %edx,%eax
c010a358:	05 00 10 00 00       	add    $0x1000,%eax
c010a35d:	89 45 bc             	mov    %eax,-0x44(%ebp)
c010a360:	b8 00 10 00 00       	mov    $0x1000,%eax
c010a365:	2b 45 bc             	sub    -0x44(%ebp),%eax
c010a368:	89 45 dc             	mov    %eax,-0x24(%ebp)
            if (end < la) {
c010a36b:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a36e:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a371:	73 0d                	jae    c010a380 <load_icode+0x2a7>
                size -= la - end;
c010a373:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a376:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010a379:	29 c2                	sub    %eax,%edx
c010a37b:	89 d0                	mov    %edx,%eax
c010a37d:	01 45 dc             	add    %eax,-0x24(%ebp)
            memset(page2kva(page) + off, 0, size);
c010a380:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a383:	89 04 24             	mov    %eax,(%esp)
c010a386:	e8 7a f0 ff ff       	call   c0109405 <page2kva>
c010a38b:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010a38e:	01 c2                	add    %eax,%edx
c010a390:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a393:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a397:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a39e:	00 
c010a39f:	89 14 24             	mov    %edx,(%esp)
c010a3a2:	e8 ab 11 00 00       	call   c010b552 <memset>
            start += size;
c010a3a7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a3aa:	01 45 d8             	add    %eax,-0x28(%ebp)
            assert((end < la && start == end) || (end >= la && start == la));
c010a3ad:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a3b0:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a3b3:	73 08                	jae    c010a3bd <load_icode+0x2e4>
c010a3b5:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a3b8:	3b 45 c0             	cmp    -0x40(%ebp),%eax
c010a3bb:	74 34                	je     c010a3f1 <load_icode+0x318>
c010a3bd:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a3c0:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a3c3:	72 08                	jb     c010a3cd <load_icode+0x2f4>
c010a3c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a3c8:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a3cb:	74 24                	je     c010a3f1 <load_icode+0x318>
c010a3cd:	c7 44 24 0c ec df 10 	movl   $0xc010dfec,0xc(%esp)
c010a3d4:	c0 
c010a3d5:	c7 44 24 08 6d df 10 	movl   $0xc010df6d,0x8(%esp)
c010a3dc:	c0 
c010a3dd:	c7 44 24 04 5b 02 00 	movl   $0x25b,0x4(%esp)
c010a3e4:	00 
c010a3e5:	c7 04 24 40 df 10 c0 	movl   $0xc010df40,(%esp)
c010a3ec:	e8 0f 60 ff ff       	call   c0100400 <__panic>
        while (start < end) {
c010a3f1:	e9 8b 00 00 00       	jmp    c010a481 <load_icode+0x3a8>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
c010a3f6:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a3f9:	8b 40 0c             	mov    0xc(%eax),%eax
c010a3fc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010a3ff:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a403:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010a406:	89 54 24 04          	mov    %edx,0x4(%esp)
c010a40a:	89 04 24             	mov    %eax,(%esp)
c010a40d:	e8 19 df ff ff       	call   c010832b <pgdir_alloc_page>
c010a412:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a415:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a419:	75 05                	jne    c010a420 <load_icode+0x347>
                goto bad_cleanup_mmap;
c010a41b:	e9 f6 02 00 00       	jmp    c010a716 <load_icode+0x63d>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
c010a420:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a423:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010a426:	29 c2                	sub    %eax,%edx
c010a428:	89 d0                	mov    %edx,%eax
c010a42a:	89 45 bc             	mov    %eax,-0x44(%ebp)
c010a42d:	b8 00 10 00 00       	mov    $0x1000,%eax
c010a432:	2b 45 bc             	sub    -0x44(%ebp),%eax
c010a435:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010a438:	81 45 d4 00 10 00 00 	addl   $0x1000,-0x2c(%ebp)
            if (end < la) {
c010a43f:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a442:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a445:	73 0d                	jae    c010a454 <load_icode+0x37b>
                size -= la - end;
c010a447:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a44a:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010a44d:	29 c2                	sub    %eax,%edx
c010a44f:	89 d0                	mov    %edx,%eax
c010a451:	01 45 dc             	add    %eax,-0x24(%ebp)
            memset(page2kva(page) + off, 0, size);
c010a454:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a457:	89 04 24             	mov    %eax,(%esp)
c010a45a:	e8 a6 ef ff ff       	call   c0109405 <page2kva>
c010a45f:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010a462:	01 c2                	add    %eax,%edx
c010a464:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a467:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a46b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a472:	00 
c010a473:	89 14 24             	mov    %edx,(%esp)
c010a476:	e8 d7 10 00 00       	call   c010b552 <memset>
            start += size;
c010a47b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a47e:	01 45 d8             	add    %eax,-0x28(%ebp)
        while (start < end) {
c010a481:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a484:	3b 45 c0             	cmp    -0x40(%ebp),%eax
c010a487:	0f 82 69 ff ff ff    	jb     c010a3f6 <load_icode+0x31d>
    for (; ph < ph_end; ph ++) {
c010a48d:	83 45 ec 20          	addl   $0x20,-0x14(%ebp)
c010a491:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a494:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c010a497:	0f 82 e1 fc ff ff    	jb     c010a17e <load_icode+0xa5>
    vm_flags = VM_READ | VM_WRITE | VM_STACK;
c010a49d:	c7 45 e8 0b 00 00 00 	movl   $0xb,-0x18(%ebp)
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
c010a4a4:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
c010a4ab:	00 
c010a4ac:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a4af:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a4b3:	c7 44 24 08 00 00 10 	movl   $0x100000,0x8(%esp)
c010a4ba:	00 
c010a4bb:	c7 44 24 04 00 00 f0 	movl   $0xaff00000,0x4(%esp)
c010a4c2:	af 
c010a4c3:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a4c6:	89 04 24             	mov    %eax,(%esp)
c010a4c9:	e8 02 95 ff ff       	call   c01039d0 <mm_map>
c010a4ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a4d1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a4d5:	74 05                	je     c010a4dc <load_icode+0x403>
        goto bad_cleanup_mmap;
c010a4d7:	e9 3a 02 00 00       	jmp    c010a716 <load_icode+0x63d>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
c010a4dc:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a4df:	8b 40 0c             	mov    0xc(%eax),%eax
c010a4e2:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a4e9:	00 
c010a4ea:	c7 44 24 04 00 f0 ff 	movl   $0xaffff000,0x4(%esp)
c010a4f1:	af 
c010a4f2:	89 04 24             	mov    %eax,(%esp)
c010a4f5:	e8 31 de ff ff       	call   c010832b <pgdir_alloc_page>
c010a4fa:	85 c0                	test   %eax,%eax
c010a4fc:	75 24                	jne    c010a522 <load_icode+0x449>
c010a4fe:	c7 44 24 0c 28 e0 10 	movl   $0xc010e028,0xc(%esp)
c010a505:	c0 
c010a506:	c7 44 24 08 6d df 10 	movl   $0xc010df6d,0x8(%esp)
c010a50d:	c0 
c010a50e:	c7 44 24 04 6e 02 00 	movl   $0x26e,0x4(%esp)
c010a515:	00 
c010a516:	c7 04 24 40 df 10 c0 	movl   $0xc010df40,(%esp)
c010a51d:	e8 de 5e ff ff       	call   c0100400 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
c010a522:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a525:	8b 40 0c             	mov    0xc(%eax),%eax
c010a528:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a52f:	00 
c010a530:	c7 44 24 04 00 e0 ff 	movl   $0xafffe000,0x4(%esp)
c010a537:	af 
c010a538:	89 04 24             	mov    %eax,(%esp)
c010a53b:	e8 eb dd ff ff       	call   c010832b <pgdir_alloc_page>
c010a540:	85 c0                	test   %eax,%eax
c010a542:	75 24                	jne    c010a568 <load_icode+0x48f>
c010a544:	c7 44 24 0c 6c e0 10 	movl   $0xc010e06c,0xc(%esp)
c010a54b:	c0 
c010a54c:	c7 44 24 08 6d df 10 	movl   $0xc010df6d,0x8(%esp)
c010a553:	c0 
c010a554:	c7 44 24 04 6f 02 00 	movl   $0x26f,0x4(%esp)
c010a55b:	00 
c010a55c:	c7 04 24 40 df 10 c0 	movl   $0xc010df40,(%esp)
c010a563:	e8 98 5e ff ff       	call   c0100400 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
c010a568:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a56b:	8b 40 0c             	mov    0xc(%eax),%eax
c010a56e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a575:	00 
c010a576:	c7 44 24 04 00 d0 ff 	movl   $0xafffd000,0x4(%esp)
c010a57d:	af 
c010a57e:	89 04 24             	mov    %eax,(%esp)
c010a581:	e8 a5 dd ff ff       	call   c010832b <pgdir_alloc_page>
c010a586:	85 c0                	test   %eax,%eax
c010a588:	75 24                	jne    c010a5ae <load_icode+0x4d5>
c010a58a:	c7 44 24 0c b0 e0 10 	movl   $0xc010e0b0,0xc(%esp)
c010a591:	c0 
c010a592:	c7 44 24 08 6d df 10 	movl   $0xc010df6d,0x8(%esp)
c010a599:	c0 
c010a59a:	c7 44 24 04 70 02 00 	movl   $0x270,0x4(%esp)
c010a5a1:	00 
c010a5a2:	c7 04 24 40 df 10 c0 	movl   $0xc010df40,(%esp)
c010a5a9:	e8 52 5e ff ff       	call   c0100400 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
c010a5ae:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a5b1:	8b 40 0c             	mov    0xc(%eax),%eax
c010a5b4:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a5bb:	00 
c010a5bc:	c7 44 24 04 00 c0 ff 	movl   $0xafffc000,0x4(%esp)
c010a5c3:	af 
c010a5c4:	89 04 24             	mov    %eax,(%esp)
c010a5c7:	e8 5f dd ff ff       	call   c010832b <pgdir_alloc_page>
c010a5cc:	85 c0                	test   %eax,%eax
c010a5ce:	75 24                	jne    c010a5f4 <load_icode+0x51b>
c010a5d0:	c7 44 24 0c f4 e0 10 	movl   $0xc010e0f4,0xc(%esp)
c010a5d7:	c0 
c010a5d8:	c7 44 24 08 6d df 10 	movl   $0xc010df6d,0x8(%esp)
c010a5df:	c0 
c010a5e0:	c7 44 24 04 71 02 00 	movl   $0x271,0x4(%esp)
c010a5e7:	00 
c010a5e8:	c7 04 24 40 df 10 c0 	movl   $0xc010df40,(%esp)
c010a5ef:	e8 0c 5e ff ff       	call   c0100400 <__panic>
    mm_count_inc(mm);
c010a5f4:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a5f7:	89 04 24             	mov    %eax,(%esp)
c010a5fa:	e8 a4 ee ff ff       	call   c01094a3 <mm_count_inc>
    current->mm = mm;
c010a5ff:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c010a604:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010a607:	89 50 18             	mov    %edx,0x18(%eax)
    current->cr3 = PADDR(mm->pgdir);
c010a60a:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c010a60f:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010a612:	8b 52 0c             	mov    0xc(%edx),%edx
c010a615:	89 55 b8             	mov    %edx,-0x48(%ebp)
c010a618:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c010a61f:	77 23                	ja     c010a644 <load_icode+0x56b>
c010a621:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010a624:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a628:	c7 44 24 08 1c df 10 	movl   $0xc010df1c,0x8(%esp)
c010a62f:	c0 
c010a630:	c7 44 24 04 76 02 00 	movl   $0x276,0x4(%esp)
c010a637:	00 
c010a638:	c7 04 24 40 df 10 c0 	movl   $0xc010df40,(%esp)
c010a63f:	e8 bc 5d ff ff       	call   c0100400 <__panic>
c010a644:	8b 55 b8             	mov    -0x48(%ebp),%edx
c010a647:	81 c2 00 00 00 40    	add    $0x40000000,%edx
c010a64d:	89 50 40             	mov    %edx,0x40(%eax)
    lcr3(PADDR(mm->pgdir));
c010a650:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a653:	8b 40 0c             	mov    0xc(%eax),%eax
c010a656:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c010a659:	81 7d b4 ff ff ff bf 	cmpl   $0xbfffffff,-0x4c(%ebp)
c010a660:	77 23                	ja     c010a685 <load_icode+0x5ac>
c010a662:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a665:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a669:	c7 44 24 08 1c df 10 	movl   $0xc010df1c,0x8(%esp)
c010a670:	c0 
c010a671:	c7 44 24 04 77 02 00 	movl   $0x277,0x4(%esp)
c010a678:	00 
c010a679:	c7 04 24 40 df 10 c0 	movl   $0xc010df40,(%esp)
c010a680:	e8 7b 5d ff ff       	call   c0100400 <__panic>
c010a685:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a688:	05 00 00 00 40       	add    $0x40000000,%eax
c010a68d:	89 45 ac             	mov    %eax,-0x54(%ebp)
c010a690:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010a693:	0f 22 d8             	mov    %eax,%cr3
    struct trapframe *tf = current->tf;
c010a696:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c010a69b:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a69e:	89 45 b0             	mov    %eax,-0x50(%ebp)
    memset(tf, 0, sizeof(struct trapframe));
c010a6a1:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
c010a6a8:	00 
c010a6a9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a6b0:	00 
c010a6b1:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a6b4:	89 04 24             	mov    %eax,(%esp)
c010a6b7:	e8 96 0e 00 00       	call   c010b552 <memset>
    tf->tf_cs = USER_CS;
c010a6bc:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a6bf:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
    tf->tf_ds = tf->tf_es = tf->tf_ss = USER_DS;
c010a6c5:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a6c8:	66 c7 40 48 23 00    	movw   $0x23,0x48(%eax)
c010a6ce:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a6d1:	0f b7 50 48          	movzwl 0x48(%eax),%edx
c010a6d5:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a6d8:	66 89 50 28          	mov    %dx,0x28(%eax)
c010a6dc:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a6df:	0f b7 50 28          	movzwl 0x28(%eax),%edx
c010a6e3:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a6e6:	66 89 50 2c          	mov    %dx,0x2c(%eax)
    tf->tf_esp = USTACKTOP;
c010a6ea:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a6ed:	c7 40 44 00 00 00 b0 	movl   $0xb0000000,0x44(%eax)
    tf->tf_eip = elf->e_entry;
c010a6f4:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a6f7:	8b 50 18             	mov    0x18(%eax),%edx
c010a6fa:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a6fd:	89 50 38             	mov    %edx,0x38(%eax)
    tf->tf_eflags = FL_IF;
c010a700:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a703:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
    ret = 0;
c010a70a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    return ret;
c010a711:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a714:	eb 23                	jmp    c010a739 <load_icode+0x660>
    exit_mmap(mm);
c010a716:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a719:	89 04 24             	mov    %eax,(%esp)
c010a71c:	e8 cc 94 ff ff       	call   c0103bed <exit_mmap>
    put_pgdir(mm);
c010a721:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a724:	89 04 24             	mov    %eax,(%esp)
c010a727:	e8 a2 f4 ff ff       	call   c0109bce <put_pgdir>
    mm_destroy(mm);
c010a72c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a72f:	89 04 24             	mov    %eax,(%esp)
c010a732:	e8 f7 91 ff ff       	call   c010392e <mm_destroy>
    goto out;
c010a737:	eb d8                	jmp    c010a711 <load_icode+0x638>
}
c010a739:	c9                   	leave  
c010a73a:	c3                   	ret    

c010a73b <do_execve>:

// do_execve - call exit_mmap(mm)&pug_pgdir(mm) to reclaim memory space of current process
//           - call load_icode to setup new memory space accroding binary prog.
int
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
c010a73b:	55                   	push   %ebp
c010a73c:	89 e5                	mov    %esp,%ebp
c010a73e:	83 ec 38             	sub    $0x38,%esp
    struct mm_struct *mm = current->mm;
c010a741:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c010a746:	8b 40 18             	mov    0x18(%eax),%eax
c010a749:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
c010a74c:	8b 45 08             	mov    0x8(%ebp),%eax
c010a74f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010a756:	00 
c010a757:	8b 55 0c             	mov    0xc(%ebp),%edx
c010a75a:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a75e:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a762:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a765:	89 04 24             	mov    %eax,(%esp)
c010a768:	e8 24 9f ff ff       	call   c0104691 <user_mem_check>
c010a76d:	85 c0                	test   %eax,%eax
c010a76f:	75 0a                	jne    c010a77b <do_execve+0x40>
        return -E_INVAL;
c010a771:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010a776:	e9 f4 00 00 00       	jmp    c010a86f <do_execve+0x134>
    }
    if (len > PROC_NAME_LEN) {
c010a77b:	83 7d 0c 0f          	cmpl   $0xf,0xc(%ebp)
c010a77f:	76 07                	jbe    c010a788 <do_execve+0x4d>
        len = PROC_NAME_LEN;
c010a781:	c7 45 0c 0f 00 00 00 	movl   $0xf,0xc(%ebp)
    }

    char local_name[PROC_NAME_LEN + 1];
    memset(local_name, 0, sizeof(local_name));
c010a788:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c010a78f:	00 
c010a790:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a797:	00 
c010a798:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010a79b:	89 04 24             	mov    %eax,(%esp)
c010a79e:	e8 af 0d 00 00       	call   c010b552 <memset>
    memcpy(local_name, name, len);
c010a7a3:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a7a6:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a7aa:	8b 45 08             	mov    0x8(%ebp),%eax
c010a7ad:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a7b1:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010a7b4:	89 04 24             	mov    %eax,(%esp)
c010a7b7:	e8 78 0e 00 00       	call   c010b634 <memcpy>

    if (mm != NULL) {
c010a7bc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a7c0:	74 4a                	je     c010a80c <do_execve+0xd1>
        lcr3(boot_cr3);
c010a7c2:	a1 54 11 1a c0       	mov    0xc01a1154,%eax
c010a7c7:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010a7ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a7cd:	0f 22 d8             	mov    %eax,%cr3
        if (mm_count_dec(mm) == 0) {
c010a7d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a7d3:	89 04 24             	mov    %eax,(%esp)
c010a7d6:	e8 e2 ec ff ff       	call   c01094bd <mm_count_dec>
c010a7db:	85 c0                	test   %eax,%eax
c010a7dd:	75 21                	jne    c010a800 <do_execve+0xc5>
            exit_mmap(mm);
c010a7df:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a7e2:	89 04 24             	mov    %eax,(%esp)
c010a7e5:	e8 03 94 ff ff       	call   c0103bed <exit_mmap>
            put_pgdir(mm);
c010a7ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a7ed:	89 04 24             	mov    %eax,(%esp)
c010a7f0:	e8 d9 f3 ff ff       	call   c0109bce <put_pgdir>
            mm_destroy(mm);
c010a7f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a7f8:	89 04 24             	mov    %eax,(%esp)
c010a7fb:	e8 2e 91 ff ff       	call   c010392e <mm_destroy>
        }
        current->mm = NULL;
c010a800:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c010a805:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
    }
    int ret;
    if ((ret = load_icode(binary, size)) != 0) {
c010a80c:	8b 45 14             	mov    0x14(%ebp),%eax
c010a80f:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a813:	8b 45 10             	mov    0x10(%ebp),%eax
c010a816:	89 04 24             	mov    %eax,(%esp)
c010a819:	e8 bb f8 ff ff       	call   c010a0d9 <load_icode>
c010a81e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a821:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a825:	74 2f                	je     c010a856 <do_execve+0x11b>
        goto execve_exit;
c010a827:	90                   	nop
    }
    set_proc_name(current, local_name);
    return 0;

execve_exit:
    do_exit(ret);
c010a828:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a82b:	89 04 24             	mov    %eax,(%esp)
c010a82e:	e8 d6 f6 ff ff       	call   c0109f09 <do_exit>
    panic("already exit: %e.\n", ret);
c010a833:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a836:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a83a:	c7 44 24 08 37 e1 10 	movl   $0xc010e137,0x8(%esp)
c010a841:	c0 
c010a842:	c7 44 24 04 b9 02 00 	movl   $0x2b9,0x4(%esp)
c010a849:	00 
c010a84a:	c7 04 24 40 df 10 c0 	movl   $0xc010df40,(%esp)
c010a851:	e8 aa 5b ff ff       	call   c0100400 <__panic>
    set_proc_name(current, local_name);
c010a856:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c010a85b:	8d 55 dc             	lea    -0x24(%ebp),%edx
c010a85e:	89 54 24 04          	mov    %edx,0x4(%esp)
c010a862:	89 04 24             	mov    %eax,(%esp)
c010a865:	e8 96 ed ff ff       	call   c0109600 <set_proc_name>
    return 0;
c010a86a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010a86f:	c9                   	leave  
c010a870:	c3                   	ret    

c010a871 <do_yield>:

// do_yield - ask the scheduler to reschedule
int
do_yield(void) {
c010a871:	55                   	push   %ebp
c010a872:	89 e5                	mov    %esp,%ebp
    current->need_resched = 1;
c010a874:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c010a879:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    return 0;
c010a880:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010a885:	5d                   	pop    %ebp
c010a886:	c3                   	ret    

c010a887 <do_wait>:

// do_wait - wait one OR any children with PROC_ZOMBIE state, and free memory space of kernel stack
//         - proc struct of this child.
// NOTE: only after do_wait function, all resources of the child proces are free.
int
do_wait(int pid, int *code_store) {
c010a887:	55                   	push   %ebp
c010a888:	89 e5                	mov    %esp,%ebp
c010a88a:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = current->mm;
c010a88d:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c010a892:	8b 40 18             	mov    0x18(%eax),%eax
c010a895:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (code_store != NULL) {
c010a898:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010a89c:	74 30                	je     c010a8ce <do_wait+0x47>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
c010a89e:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a8a1:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c010a8a8:	00 
c010a8a9:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
c010a8b0:	00 
c010a8b1:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a8b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a8b8:	89 04 24             	mov    %eax,(%esp)
c010a8bb:	e8 d1 9d ff ff       	call   c0104691 <user_mem_check>
c010a8c0:	85 c0                	test   %eax,%eax
c010a8c2:	75 0a                	jne    c010a8ce <do_wait+0x47>
            return -E_INVAL;
c010a8c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010a8c9:	e9 4b 01 00 00       	jmp    c010aa19 <do_wait+0x192>
    }

    struct proc_struct *proc;
    bool intr_flag, haskid;
repeat:
    haskid = 0;
c010a8ce:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    if (pid != 0) {
c010a8d5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010a8d9:	74 39                	je     c010a914 <do_wait+0x8d>
        proc = find_proc(pid);
c010a8db:	8b 45 08             	mov    0x8(%ebp),%eax
c010a8de:	89 04 24             	mov    %eax,(%esp)
c010a8e1:	e8 fb f0 ff ff       	call   c01099e1 <find_proc>
c010a8e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (proc != NULL && proc->parent == current) {
c010a8e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a8ed:	74 54                	je     c010a943 <do_wait+0xbc>
c010a8ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a8f2:	8b 50 14             	mov    0x14(%eax),%edx
c010a8f5:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c010a8fa:	39 c2                	cmp    %eax,%edx
c010a8fc:	75 45                	jne    c010a943 <do_wait+0xbc>
            haskid = 1;
c010a8fe:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
            if (proc->state == PROC_ZOMBIE) {
c010a905:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a908:	8b 00                	mov    (%eax),%eax
c010a90a:	83 f8 03             	cmp    $0x3,%eax
c010a90d:	75 34                	jne    c010a943 <do_wait+0xbc>
                goto found;
c010a90f:	e9 80 00 00 00       	jmp    c010a994 <do_wait+0x10d>
            }
        }
    }
    else {
        proc = current->cptr;
c010a914:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c010a919:	8b 40 70             	mov    0x70(%eax),%eax
c010a91c:	89 45 f4             	mov    %eax,-0xc(%ebp)
        for (; proc != NULL; proc = proc->optr) {
c010a91f:	eb 1c                	jmp    c010a93d <do_wait+0xb6>
            haskid = 1;
c010a921:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
            if (proc->state == PROC_ZOMBIE) {
c010a928:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a92b:	8b 00                	mov    (%eax),%eax
c010a92d:	83 f8 03             	cmp    $0x3,%eax
c010a930:	75 02                	jne    c010a934 <do_wait+0xad>
                goto found;
c010a932:	eb 60                	jmp    c010a994 <do_wait+0x10d>
        for (; proc != NULL; proc = proc->optr) {
c010a934:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a937:	8b 40 78             	mov    0x78(%eax),%eax
c010a93a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a93d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a941:	75 de                	jne    c010a921 <do_wait+0x9a>
            }
        }
    }
    if (haskid) {
c010a943:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a947:	74 41                	je     c010a98a <do_wait+0x103>
        current->state = PROC_SLEEPING;
c010a949:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c010a94e:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
        current->wait_state = WT_CHILD;
c010a954:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c010a959:	c7 40 6c 01 00 00 80 	movl   $0x80000001,0x6c(%eax)
        schedule();
c010a960:	e8 00 06 00 00       	call   c010af65 <schedule>
        if (current->flags & PF_EXITING) {
c010a965:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c010a96a:	8b 40 44             	mov    0x44(%eax),%eax
c010a96d:	83 e0 01             	and    $0x1,%eax
c010a970:	85 c0                	test   %eax,%eax
c010a972:	74 11                	je     c010a985 <do_wait+0xfe>
            do_exit(-E_KILLED);
c010a974:	c7 04 24 f7 ff ff ff 	movl   $0xfffffff7,(%esp)
c010a97b:	e8 89 f5 ff ff       	call   c0109f09 <do_exit>
        }
        goto repeat;
c010a980:	e9 49 ff ff ff       	jmp    c010a8ce <do_wait+0x47>
c010a985:	e9 44 ff ff ff       	jmp    c010a8ce <do_wait+0x47>
    }
    return -E_BAD_PROC;
c010a98a:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
c010a98f:	e9 85 00 00 00       	jmp    c010aa19 <do_wait+0x192>

found:
    if (proc == idleproc || proc == initproc) {
c010a994:	a1 20 f0 19 c0       	mov    0xc019f020,%eax
c010a999:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010a99c:	74 0a                	je     c010a9a8 <do_wait+0x121>
c010a99e:	a1 24 f0 19 c0       	mov    0xc019f024,%eax
c010a9a3:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010a9a6:	75 1c                	jne    c010a9c4 <do_wait+0x13d>
        panic("wait idleproc or initproc.\n");
c010a9a8:	c7 44 24 08 4a e1 10 	movl   $0xc010e14a,0x8(%esp)
c010a9af:	c0 
c010a9b0:	c7 44 24 04 f2 02 00 	movl   $0x2f2,0x4(%esp)
c010a9b7:	00 
c010a9b8:	c7 04 24 40 df 10 c0 	movl   $0xc010df40,(%esp)
c010a9bf:	e8 3c 5a ff ff       	call   c0100400 <__panic>
    }
    if (code_store != NULL) {
c010a9c4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010a9c8:	74 0b                	je     c010a9d5 <do_wait+0x14e>
        *code_store = proc->exit_code;
c010a9ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a9cd:	8b 50 68             	mov    0x68(%eax),%edx
c010a9d0:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a9d3:	89 10                	mov    %edx,(%eax)
    }
    local_intr_save(intr_flag);
c010a9d5:	e8 03 e9 ff ff       	call   c01092dd <__intr_save>
c010a9da:	89 45 e8             	mov    %eax,-0x18(%ebp)
    {
        unhash_proc(proc);
c010a9dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a9e0:	89 04 24             	mov    %eax,(%esp)
c010a9e3:	e8 c6 ef ff ff       	call   c01099ae <unhash_proc>
        remove_links(proc);
c010a9e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a9eb:	89 04 24             	mov    %eax,(%esp)
c010a9ee:	e8 37 ed ff ff       	call   c010972a <remove_links>
    }
    local_intr_restore(intr_flag);
c010a9f3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a9f6:	89 04 24             	mov    %eax,(%esp)
c010a9f9:	e8 09 e9 ff ff       	call   c0109307 <__intr_restore>
    put_kstack(proc);
c010a9fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa01:	89 04 24             	mov    %eax,(%esp)
c010aa04:	e8 f8 f0 ff ff       	call   c0109b01 <put_kstack>
    kfree(proc);
c010aa09:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa0c:	89 04 24             	mov    %eax,(%esp)
c010aa0f:	e8 f9 a8 ff ff       	call   c010530d <kfree>
    return 0;
c010aa14:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010aa19:	c9                   	leave  
c010aa1a:	c3                   	ret    

c010aa1b <do_kill>:

// do_kill - kill process with pid by set this process's flags with PF_EXITING
int
do_kill(int pid) {
c010aa1b:	55                   	push   %ebp
c010aa1c:	89 e5                	mov    %esp,%ebp
c010aa1e:	83 ec 28             	sub    $0x28,%esp
    struct proc_struct *proc;
    if ((proc = find_proc(pid)) != NULL) {
c010aa21:	8b 45 08             	mov    0x8(%ebp),%eax
c010aa24:	89 04 24             	mov    %eax,(%esp)
c010aa27:	e8 b5 ef ff ff       	call   c01099e1 <find_proc>
c010aa2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010aa2f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010aa33:	74 41                	je     c010aa76 <do_kill+0x5b>
        if (!(proc->flags & PF_EXITING)) {
c010aa35:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa38:	8b 40 44             	mov    0x44(%eax),%eax
c010aa3b:	83 e0 01             	and    $0x1,%eax
c010aa3e:	85 c0                	test   %eax,%eax
c010aa40:	75 2d                	jne    c010aa6f <do_kill+0x54>
            proc->flags |= PF_EXITING;
c010aa42:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa45:	8b 40 44             	mov    0x44(%eax),%eax
c010aa48:	83 c8 01             	or     $0x1,%eax
c010aa4b:	89 c2                	mov    %eax,%edx
c010aa4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa50:	89 50 44             	mov    %edx,0x44(%eax)
            if (proc->wait_state & WT_INTERRUPTED) {
c010aa53:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa56:	8b 40 6c             	mov    0x6c(%eax),%eax
c010aa59:	85 c0                	test   %eax,%eax
c010aa5b:	79 0b                	jns    c010aa68 <do_kill+0x4d>
                wakeup_proc(proc);
c010aa5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa60:	89 04 24             	mov    %eax,(%esp)
c010aa63:	e8 79 04 00 00       	call   c010aee1 <wakeup_proc>
            }
            return 0;
c010aa68:	b8 00 00 00 00       	mov    $0x0,%eax
c010aa6d:	eb 0c                	jmp    c010aa7b <do_kill+0x60>
        }
        return -E_KILLED;
c010aa6f:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
c010aa74:	eb 05                	jmp    c010aa7b <do_kill+0x60>
    }
    return -E_INVAL;
c010aa76:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
c010aa7b:	c9                   	leave  
c010aa7c:	c3                   	ret    

c010aa7d <kernel_execve>:

// kernel_execve - do SYS_exec syscall to exec a user program called by user_main kernel_thread
static int
kernel_execve(const char *name, unsigned char *binary, size_t size) {
c010aa7d:	55                   	push   %ebp
c010aa7e:	89 e5                	mov    %esp,%ebp
c010aa80:	57                   	push   %edi
c010aa81:	56                   	push   %esi
c010aa82:	53                   	push   %ebx
c010aa83:	83 ec 2c             	sub    $0x2c,%esp
    int ret, len = strlen(name);
c010aa86:	8b 45 08             	mov    0x8(%ebp),%eax
c010aa89:	89 04 24             	mov    %eax,(%esp)
c010aa8c:	e8 92 07 00 00       	call   c010b223 <strlen>
c010aa91:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    asm volatile (
c010aa94:	b8 04 00 00 00       	mov    $0x4,%eax
c010aa99:	8b 55 08             	mov    0x8(%ebp),%edx
c010aa9c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
c010aa9f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
c010aaa2:	8b 75 10             	mov    0x10(%ebp),%esi
c010aaa5:	89 f7                	mov    %esi,%edi
c010aaa7:	cd 80                	int    $0x80
c010aaa9:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "int %1;"
        : "=a" (ret)
        : "i" (T_SYSCALL), "0" (SYS_exec), "d" (name), "c" (len), "b" (binary), "D" (size)
        : "memory");
    return ret;
c010aaac:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
c010aaaf:	83 c4 2c             	add    $0x2c,%esp
c010aab2:	5b                   	pop    %ebx
c010aab3:	5e                   	pop    %esi
c010aab4:	5f                   	pop    %edi
c010aab5:	5d                   	pop    %ebp
c010aab6:	c3                   	ret    

c010aab7 <user_main>:

#define KERNEL_EXECVE2(x, xstart, xsize)        __KERNEL_EXECVE2(x, xstart, xsize)

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
c010aab7:	55                   	push   %ebp
c010aab8:	89 e5                	mov    %esp,%ebp
c010aaba:	83 ec 18             	sub    $0x18,%esp
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
c010aabd:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c010aac2:	8b 40 04             	mov    0x4(%eax),%eax
c010aac5:	c7 44 24 08 66 e1 10 	movl   $0xc010e166,0x8(%esp)
c010aacc:	c0 
c010aacd:	89 44 24 04          	mov    %eax,0x4(%esp)
c010aad1:	c7 04 24 70 e1 10 c0 	movl   $0xc010e170,(%esp)
c010aad8:	e8 cc 57 ff ff       	call   c01002a9 <cprintf>
c010aadd:	b8 8c 78 00 00       	mov    $0x788c,%eax
c010aae2:	89 44 24 08          	mov    %eax,0x8(%esp)
c010aae6:	c7 44 24 04 b4 9b 13 	movl   $0xc0139bb4,0x4(%esp)
c010aaed:	c0 
c010aaee:	c7 04 24 66 e1 10 c0 	movl   $0xc010e166,(%esp)
c010aaf5:	e8 83 ff ff ff       	call   c010aa7d <kernel_execve>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
c010aafa:	c7 44 24 08 97 e1 10 	movl   $0xc010e197,0x8(%esp)
c010ab01:	c0 
c010ab02:	c7 44 24 04 3b 03 00 	movl   $0x33b,0x4(%esp)
c010ab09:	00 
c010ab0a:	c7 04 24 40 df 10 c0 	movl   $0xc010df40,(%esp)
c010ab11:	e8 ea 58 ff ff       	call   c0100400 <__panic>

c010ab16 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
c010ab16:	55                   	push   %ebp
c010ab17:	89 e5                	mov    %esp,%ebp
c010ab19:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c010ab1c:	e8 53 ca ff ff       	call   c0107574 <nr_free_pages>
c010ab21:	89 45 f4             	mov    %eax,-0xc(%ebp)
    size_t kernel_allocated_store = kallocated();
c010ab24:	e8 ac a6 ff ff       	call   c01051d5 <kallocated>
c010ab29:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int pid = kernel_thread(user_main, NULL, 0);
c010ab2c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010ab33:	00 
c010ab34:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010ab3b:	00 
c010ab3c:	c7 04 24 b7 aa 10 c0 	movl   $0xc010aab7,(%esp)
c010ab43:	e8 0b ef ff ff       	call   c0109a53 <kernel_thread>
c010ab48:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (pid <= 0) {
c010ab4b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010ab4f:	7f 1c                	jg     c010ab6d <init_main+0x57>
        panic("create user_main failed.\n");
c010ab51:	c7 44 24 08 b1 e1 10 	movl   $0xc010e1b1,0x8(%esp)
c010ab58:	c0 
c010ab59:	c7 44 24 04 46 03 00 	movl   $0x346,0x4(%esp)
c010ab60:	00 
c010ab61:	c7 04 24 40 df 10 c0 	movl   $0xc010df40,(%esp)
c010ab68:	e8 93 58 ff ff       	call   c0100400 <__panic>
    }

    while (do_wait(0, NULL) == 0) {
c010ab6d:	eb 05                	jmp    c010ab74 <init_main+0x5e>
        schedule();
c010ab6f:	e8 f1 03 00 00       	call   c010af65 <schedule>
    while (do_wait(0, NULL) == 0) {
c010ab74:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010ab7b:	00 
c010ab7c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010ab83:	e8 ff fc ff ff       	call   c010a887 <do_wait>
c010ab88:	85 c0                	test   %eax,%eax
c010ab8a:	74 e3                	je     c010ab6f <init_main+0x59>
    }

    cprintf("all user-mode processes have quit.\n");
c010ab8c:	c7 04 24 cc e1 10 c0 	movl   $0xc010e1cc,(%esp)
c010ab93:	e8 11 57 ff ff       	call   c01002a9 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
c010ab98:	a1 24 f0 19 c0       	mov    0xc019f024,%eax
c010ab9d:	8b 40 70             	mov    0x70(%eax),%eax
c010aba0:	85 c0                	test   %eax,%eax
c010aba2:	75 18                	jne    c010abbc <init_main+0xa6>
c010aba4:	a1 24 f0 19 c0       	mov    0xc019f024,%eax
c010aba9:	8b 40 74             	mov    0x74(%eax),%eax
c010abac:	85 c0                	test   %eax,%eax
c010abae:	75 0c                	jne    c010abbc <init_main+0xa6>
c010abb0:	a1 24 f0 19 c0       	mov    0xc019f024,%eax
c010abb5:	8b 40 78             	mov    0x78(%eax),%eax
c010abb8:	85 c0                	test   %eax,%eax
c010abba:	74 24                	je     c010abe0 <init_main+0xca>
c010abbc:	c7 44 24 0c f0 e1 10 	movl   $0xc010e1f0,0xc(%esp)
c010abc3:	c0 
c010abc4:	c7 44 24 08 6d df 10 	movl   $0xc010df6d,0x8(%esp)
c010abcb:	c0 
c010abcc:	c7 44 24 04 4e 03 00 	movl   $0x34e,0x4(%esp)
c010abd3:	00 
c010abd4:	c7 04 24 40 df 10 c0 	movl   $0xc010df40,(%esp)
c010abdb:	e8 20 58 ff ff       	call   c0100400 <__panic>
    assert(nr_process == 2);
c010abe0:	a1 40 10 1a c0       	mov    0xc01a1040,%eax
c010abe5:	83 f8 02             	cmp    $0x2,%eax
c010abe8:	74 24                	je     c010ac0e <init_main+0xf8>
c010abea:	c7 44 24 0c 3b e2 10 	movl   $0xc010e23b,0xc(%esp)
c010abf1:	c0 
c010abf2:	c7 44 24 08 6d df 10 	movl   $0xc010df6d,0x8(%esp)
c010abf9:	c0 
c010abfa:	c7 44 24 04 4f 03 00 	movl   $0x34f,0x4(%esp)
c010ac01:	00 
c010ac02:	c7 04 24 40 df 10 c0 	movl   $0xc010df40,(%esp)
c010ac09:	e8 f2 57 ff ff       	call   c0100400 <__panic>
c010ac0e:	c7 45 e8 5c 11 1a c0 	movl   $0xc01a115c,-0x18(%ebp)
c010ac15:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ac18:	8b 40 04             	mov    0x4(%eax),%eax
    assert(list_next(&proc_list) == &(initproc->list_link));
c010ac1b:	8b 15 24 f0 19 c0    	mov    0xc019f024,%edx
c010ac21:	83 c2 58             	add    $0x58,%edx
c010ac24:	39 d0                	cmp    %edx,%eax
c010ac26:	74 24                	je     c010ac4c <init_main+0x136>
c010ac28:	c7 44 24 0c 4c e2 10 	movl   $0xc010e24c,0xc(%esp)
c010ac2f:	c0 
c010ac30:	c7 44 24 08 6d df 10 	movl   $0xc010df6d,0x8(%esp)
c010ac37:	c0 
c010ac38:	c7 44 24 04 50 03 00 	movl   $0x350,0x4(%esp)
c010ac3f:	00 
c010ac40:	c7 04 24 40 df 10 c0 	movl   $0xc010df40,(%esp)
c010ac47:	e8 b4 57 ff ff       	call   c0100400 <__panic>
c010ac4c:	c7 45 e4 5c 11 1a c0 	movl   $0xc01a115c,-0x1c(%ebp)
    return listelm->prev;
c010ac53:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010ac56:	8b 00                	mov    (%eax),%eax
    assert(list_prev(&proc_list) == &(initproc->list_link));
c010ac58:	8b 15 24 f0 19 c0    	mov    0xc019f024,%edx
c010ac5e:	83 c2 58             	add    $0x58,%edx
c010ac61:	39 d0                	cmp    %edx,%eax
c010ac63:	74 24                	je     c010ac89 <init_main+0x173>
c010ac65:	c7 44 24 0c 7c e2 10 	movl   $0xc010e27c,0xc(%esp)
c010ac6c:	c0 
c010ac6d:	c7 44 24 08 6d df 10 	movl   $0xc010df6d,0x8(%esp)
c010ac74:	c0 
c010ac75:	c7 44 24 04 51 03 00 	movl   $0x351,0x4(%esp)
c010ac7c:	00 
c010ac7d:	c7 04 24 40 df 10 c0 	movl   $0xc010df40,(%esp)
c010ac84:	e8 77 57 ff ff       	call   c0100400 <__panic>
    assert(kernel_allocated_store == kallocated());
c010ac89:	e8 47 a5 ff ff       	call   c01051d5 <kallocated>
c010ac8e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010ac91:	74 24                	je     c010acb7 <init_main+0x1a1>
c010ac93:	c7 44 24 0c ac e2 10 	movl   $0xc010e2ac,0xc(%esp)
c010ac9a:	c0 
c010ac9b:	c7 44 24 08 6d df 10 	movl   $0xc010df6d,0x8(%esp)
c010aca2:	c0 
c010aca3:	c7 44 24 04 52 03 00 	movl   $0x352,0x4(%esp)
c010acaa:	00 
c010acab:	c7 04 24 40 df 10 c0 	movl   $0xc010df40,(%esp)
c010acb2:	e8 49 57 ff ff       	call   c0100400 <__panic>
    cprintf("init check memory pass.\n");
c010acb7:	c7 04 24 d3 e2 10 c0 	movl   $0xc010e2d3,(%esp)
c010acbe:	e8 e6 55 ff ff       	call   c01002a9 <cprintf>
    return 0;
c010acc3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010acc8:	c9                   	leave  
c010acc9:	c3                   	ret    

c010acca <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
c010acca:	55                   	push   %ebp
c010accb:	89 e5                	mov    %esp,%ebp
c010accd:	83 ec 28             	sub    $0x28,%esp
c010acd0:	c7 45 ec 5c 11 1a c0 	movl   $0xc01a115c,-0x14(%ebp)
    elm->prev = elm->next = elm;
c010acd7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010acda:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010acdd:	89 50 04             	mov    %edx,0x4(%eax)
c010ace0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010ace3:	8b 50 04             	mov    0x4(%eax),%edx
c010ace6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010ace9:	89 10                	mov    %edx,(%eax)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c010aceb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010acf2:	eb 26                	jmp    c010ad1a <proc_init+0x50>
        list_init(hash_list + i);
c010acf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010acf7:	c1 e0 03             	shl    $0x3,%eax
c010acfa:	05 40 f0 19 c0       	add    $0xc019f040,%eax
c010acff:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010ad02:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ad05:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010ad08:	89 50 04             	mov    %edx,0x4(%eax)
c010ad0b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ad0e:	8b 50 04             	mov    0x4(%eax),%edx
c010ad11:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ad14:	89 10                	mov    %edx,(%eax)
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c010ad16:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010ad1a:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
c010ad21:	7e d1                	jle    c010acf4 <proc_init+0x2a>
    }

    if ((idleproc = alloc_proc()) == NULL) {
c010ad23:	e8 e7 e7 ff ff       	call   c010950f <alloc_proc>
c010ad28:	a3 20 f0 19 c0       	mov    %eax,0xc019f020
c010ad2d:	a1 20 f0 19 c0       	mov    0xc019f020,%eax
c010ad32:	85 c0                	test   %eax,%eax
c010ad34:	75 1c                	jne    c010ad52 <proc_init+0x88>
        panic("cannot alloc idleproc.\n");
c010ad36:	c7 44 24 08 ec e2 10 	movl   $0xc010e2ec,0x8(%esp)
c010ad3d:	c0 
c010ad3e:	c7 44 24 04 63 03 00 	movl   $0x363,0x4(%esp)
c010ad45:	00 
c010ad46:	c7 04 24 40 df 10 c0 	movl   $0xc010df40,(%esp)
c010ad4d:	e8 ae 56 ff ff       	call   c0100400 <__panic>
    }

    idleproc->pid = 0;
c010ad52:	a1 20 f0 19 c0       	mov    0xc019f020,%eax
c010ad57:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    idleproc->state = PROC_RUNNABLE;
c010ad5e:	a1 20 f0 19 c0       	mov    0xc019f020,%eax
c010ad63:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
    idleproc->kstack = (uintptr_t)bootstack;
c010ad69:	a1 20 f0 19 c0       	mov    0xc019f020,%eax
c010ad6e:	ba 00 80 12 c0       	mov    $0xc0128000,%edx
c010ad73:	89 50 0c             	mov    %edx,0xc(%eax)
    idleproc->need_resched = 1;
c010ad76:	a1 20 f0 19 c0       	mov    0xc019f020,%eax
c010ad7b:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    set_proc_name(idleproc, "idle");
c010ad82:	a1 20 f0 19 c0       	mov    0xc019f020,%eax
c010ad87:	c7 44 24 04 04 e3 10 	movl   $0xc010e304,0x4(%esp)
c010ad8e:	c0 
c010ad8f:	89 04 24             	mov    %eax,(%esp)
c010ad92:	e8 69 e8 ff ff       	call   c0109600 <set_proc_name>
    nr_process ++;
c010ad97:	a1 40 10 1a c0       	mov    0xc01a1040,%eax
c010ad9c:	83 c0 01             	add    $0x1,%eax
c010ad9f:	a3 40 10 1a c0       	mov    %eax,0xc01a1040

    current = idleproc;
c010ada4:	a1 20 f0 19 c0       	mov    0xc019f020,%eax
c010ada9:	a3 28 f0 19 c0       	mov    %eax,0xc019f028

    int pid = kernel_thread(init_main, NULL, 0);
c010adae:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010adb5:	00 
c010adb6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010adbd:	00 
c010adbe:	c7 04 24 16 ab 10 c0 	movl   $0xc010ab16,(%esp)
c010adc5:	e8 89 ec ff ff       	call   c0109a53 <kernel_thread>
c010adca:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (pid <= 0) {
c010adcd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010add1:	7f 1c                	jg     c010adef <proc_init+0x125>
        panic("create init_main failed.\n");
c010add3:	c7 44 24 08 09 e3 10 	movl   $0xc010e309,0x8(%esp)
c010adda:	c0 
c010addb:	c7 44 24 04 71 03 00 	movl   $0x371,0x4(%esp)
c010ade2:	00 
c010ade3:	c7 04 24 40 df 10 c0 	movl   $0xc010df40,(%esp)
c010adea:	e8 11 56 ff ff       	call   c0100400 <__panic>
    }

    initproc = find_proc(pid);
c010adef:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010adf2:	89 04 24             	mov    %eax,(%esp)
c010adf5:	e8 e7 eb ff ff       	call   c01099e1 <find_proc>
c010adfa:	a3 24 f0 19 c0       	mov    %eax,0xc019f024
    set_proc_name(initproc, "init");
c010adff:	a1 24 f0 19 c0       	mov    0xc019f024,%eax
c010ae04:	c7 44 24 04 23 e3 10 	movl   $0xc010e323,0x4(%esp)
c010ae0b:	c0 
c010ae0c:	89 04 24             	mov    %eax,(%esp)
c010ae0f:	e8 ec e7 ff ff       	call   c0109600 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
c010ae14:	a1 20 f0 19 c0       	mov    0xc019f020,%eax
c010ae19:	85 c0                	test   %eax,%eax
c010ae1b:	74 0c                	je     c010ae29 <proc_init+0x15f>
c010ae1d:	a1 20 f0 19 c0       	mov    0xc019f020,%eax
c010ae22:	8b 40 04             	mov    0x4(%eax),%eax
c010ae25:	85 c0                	test   %eax,%eax
c010ae27:	74 24                	je     c010ae4d <proc_init+0x183>
c010ae29:	c7 44 24 0c 28 e3 10 	movl   $0xc010e328,0xc(%esp)
c010ae30:	c0 
c010ae31:	c7 44 24 08 6d df 10 	movl   $0xc010df6d,0x8(%esp)
c010ae38:	c0 
c010ae39:	c7 44 24 04 77 03 00 	movl   $0x377,0x4(%esp)
c010ae40:	00 
c010ae41:	c7 04 24 40 df 10 c0 	movl   $0xc010df40,(%esp)
c010ae48:	e8 b3 55 ff ff       	call   c0100400 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
c010ae4d:	a1 24 f0 19 c0       	mov    0xc019f024,%eax
c010ae52:	85 c0                	test   %eax,%eax
c010ae54:	74 0d                	je     c010ae63 <proc_init+0x199>
c010ae56:	a1 24 f0 19 c0       	mov    0xc019f024,%eax
c010ae5b:	8b 40 04             	mov    0x4(%eax),%eax
c010ae5e:	83 f8 01             	cmp    $0x1,%eax
c010ae61:	74 24                	je     c010ae87 <proc_init+0x1bd>
c010ae63:	c7 44 24 0c 50 e3 10 	movl   $0xc010e350,0xc(%esp)
c010ae6a:	c0 
c010ae6b:	c7 44 24 08 6d df 10 	movl   $0xc010df6d,0x8(%esp)
c010ae72:	c0 
c010ae73:	c7 44 24 04 78 03 00 	movl   $0x378,0x4(%esp)
c010ae7a:	00 
c010ae7b:	c7 04 24 40 df 10 c0 	movl   $0xc010df40,(%esp)
c010ae82:	e8 79 55 ff ff       	call   c0100400 <__panic>
}
c010ae87:	c9                   	leave  
c010ae88:	c3                   	ret    

c010ae89 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
c010ae89:	55                   	push   %ebp
c010ae8a:	89 e5                	mov    %esp,%ebp
c010ae8c:	83 ec 08             	sub    $0x8,%esp
    while (1) {
        if (current->need_resched) {
c010ae8f:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c010ae94:	8b 40 10             	mov    0x10(%eax),%eax
c010ae97:	85 c0                	test   %eax,%eax
c010ae99:	74 07                	je     c010aea2 <cpu_idle+0x19>
            schedule();
c010ae9b:	e8 c5 00 00 00       	call   c010af65 <schedule>
        }
    }
c010aea0:	eb ed                	jmp    c010ae8f <cpu_idle+0x6>
c010aea2:	eb eb                	jmp    c010ae8f <cpu_idle+0x6>

c010aea4 <__intr_save>:
__intr_save(void) {
c010aea4:	55                   	push   %ebp
c010aea5:	89 e5                	mov    %esp,%ebp
c010aea7:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010aeaa:	9c                   	pushf  
c010aeab:	58                   	pop    %eax
c010aeac:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c010aeaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c010aeb2:	25 00 02 00 00       	and    $0x200,%eax
c010aeb7:	85 c0                	test   %eax,%eax
c010aeb9:	74 0c                	je     c010aec7 <__intr_save+0x23>
        intr_disable();
c010aebb:	e8 55 73 ff ff       	call   c0102215 <intr_disable>
        return 1;
c010aec0:	b8 01 00 00 00       	mov    $0x1,%eax
c010aec5:	eb 05                	jmp    c010aecc <__intr_save+0x28>
    return 0;
c010aec7:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010aecc:	c9                   	leave  
c010aecd:	c3                   	ret    

c010aece <__intr_restore>:
__intr_restore(bool flag) {
c010aece:	55                   	push   %ebp
c010aecf:	89 e5                	mov    %esp,%ebp
c010aed1:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c010aed4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010aed8:	74 05                	je     c010aedf <__intr_restore+0x11>
        intr_enable();
c010aeda:	e8 30 73 ff ff       	call   c010220f <intr_enable>
}
c010aedf:	c9                   	leave  
c010aee0:	c3                   	ret    

c010aee1 <wakeup_proc>:
#include <proc.h>
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
c010aee1:	55                   	push   %ebp
c010aee2:	89 e5                	mov    %esp,%ebp
c010aee4:	83 ec 28             	sub    $0x28,%esp
    assert(proc->state != PROC_ZOMBIE);
c010aee7:	8b 45 08             	mov    0x8(%ebp),%eax
c010aeea:	8b 00                	mov    (%eax),%eax
c010aeec:	83 f8 03             	cmp    $0x3,%eax
c010aeef:	75 24                	jne    c010af15 <wakeup_proc+0x34>
c010aef1:	c7 44 24 0c 77 e3 10 	movl   $0xc010e377,0xc(%esp)
c010aef8:	c0 
c010aef9:	c7 44 24 08 92 e3 10 	movl   $0xc010e392,0x8(%esp)
c010af00:	c0 
c010af01:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
c010af08:	00 
c010af09:	c7 04 24 a7 e3 10 c0 	movl   $0xc010e3a7,(%esp)
c010af10:	e8 eb 54 ff ff       	call   c0100400 <__panic>
    bool intr_flag;
    local_intr_save(intr_flag);
c010af15:	e8 8a ff ff ff       	call   c010aea4 <__intr_save>
c010af1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        if (proc->state != PROC_RUNNABLE) {
c010af1d:	8b 45 08             	mov    0x8(%ebp),%eax
c010af20:	8b 00                	mov    (%eax),%eax
c010af22:	83 f8 02             	cmp    $0x2,%eax
c010af25:	74 15                	je     c010af3c <wakeup_proc+0x5b>
            proc->state = PROC_RUNNABLE;
c010af27:	8b 45 08             	mov    0x8(%ebp),%eax
c010af2a:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
            proc->wait_state = 0;
c010af30:	8b 45 08             	mov    0x8(%ebp),%eax
c010af33:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%eax)
c010af3a:	eb 1c                	jmp    c010af58 <wakeup_proc+0x77>
        }
        else {
            warn("wakeup runnable process.\n");
c010af3c:	c7 44 24 08 bd e3 10 	movl   $0xc010e3bd,0x8(%esp)
c010af43:	c0 
c010af44:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
c010af4b:	00 
c010af4c:	c7 04 24 a7 e3 10 c0 	movl   $0xc010e3a7,(%esp)
c010af53:	e8 25 55 ff ff       	call   c010047d <__warn>
        }
    }
    local_intr_restore(intr_flag);
c010af58:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010af5b:	89 04 24             	mov    %eax,(%esp)
c010af5e:	e8 6b ff ff ff       	call   c010aece <__intr_restore>
}
c010af63:	c9                   	leave  
c010af64:	c3                   	ret    

c010af65 <schedule>:

void
schedule(void) {
c010af65:	55                   	push   %ebp
c010af66:	89 e5                	mov    %esp,%ebp
c010af68:	83 ec 38             	sub    $0x38,%esp
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
c010af6b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    local_intr_save(intr_flag);
c010af72:	e8 2d ff ff ff       	call   c010aea4 <__intr_save>
c010af77:	89 45 ec             	mov    %eax,-0x14(%ebp)
    {
        current->need_resched = 0;
c010af7a:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c010af7f:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
c010af86:	8b 15 28 f0 19 c0    	mov    0xc019f028,%edx
c010af8c:	a1 20 f0 19 c0       	mov    0xc019f020,%eax
c010af91:	39 c2                	cmp    %eax,%edx
c010af93:	74 0a                	je     c010af9f <schedule+0x3a>
c010af95:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c010af9a:	83 c0 58             	add    $0x58,%eax
c010af9d:	eb 05                	jmp    c010afa4 <schedule+0x3f>
c010af9f:	b8 5c 11 1a c0       	mov    $0xc01a115c,%eax
c010afa4:	89 45 e8             	mov    %eax,-0x18(%ebp)
        le = last;
c010afa7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010afaa:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010afad:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010afb0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c010afb3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010afb6:	8b 40 04             	mov    0x4(%eax),%eax
        do {
            if ((le = list_next(le)) != &proc_list) {
c010afb9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010afbc:	81 7d f4 5c 11 1a c0 	cmpl   $0xc01a115c,-0xc(%ebp)
c010afc3:	74 15                	je     c010afda <schedule+0x75>
                next = le2proc(le, list_link);
c010afc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010afc8:	83 e8 58             	sub    $0x58,%eax
c010afcb:	89 45 f0             	mov    %eax,-0x10(%ebp)
                if (next->state == PROC_RUNNABLE) {
c010afce:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010afd1:	8b 00                	mov    (%eax),%eax
c010afd3:	83 f8 02             	cmp    $0x2,%eax
c010afd6:	75 02                	jne    c010afda <schedule+0x75>
                    break;
c010afd8:	eb 08                	jmp    c010afe2 <schedule+0x7d>
                }
            }
        } while (le != last);
c010afda:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010afdd:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c010afe0:	75 cb                	jne    c010afad <schedule+0x48>
        if (next == NULL || next->state != PROC_RUNNABLE) {
c010afe2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010afe6:	74 0a                	je     c010aff2 <schedule+0x8d>
c010afe8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010afeb:	8b 00                	mov    (%eax),%eax
c010afed:	83 f8 02             	cmp    $0x2,%eax
c010aff0:	74 08                	je     c010affa <schedule+0x95>
            next = idleproc;
c010aff2:	a1 20 f0 19 c0       	mov    0xc019f020,%eax
c010aff7:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        next->runs ++;
c010affa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010affd:	8b 40 08             	mov    0x8(%eax),%eax
c010b000:	8d 50 01             	lea    0x1(%eax),%edx
c010b003:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b006:	89 50 08             	mov    %edx,0x8(%eax)
        if (next != current) {
c010b009:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c010b00e:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010b011:	74 0b                	je     c010b01e <schedule+0xb9>
            proc_run(next);
c010b013:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b016:	89 04 24             	mov    %eax,(%esp)
c010b019:	e8 87 e8 ff ff       	call   c01098a5 <proc_run>
        }
    }
    local_intr_restore(intr_flag);
c010b01e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b021:	89 04 24             	mov    %eax,(%esp)
c010b024:	e8 a5 fe ff ff       	call   c010aece <__intr_restore>
}
c010b029:	c9                   	leave  
c010b02a:	c3                   	ret    

c010b02b <sys_exit>:
#include <stdio.h>
#include <pmm.h>
#include <assert.h>

static int
sys_exit(uint32_t arg[]) {
c010b02b:	55                   	push   %ebp
c010b02c:	89 e5                	mov    %esp,%ebp
c010b02e:	83 ec 28             	sub    $0x28,%esp
    int error_code = (int)arg[0];
c010b031:	8b 45 08             	mov    0x8(%ebp),%eax
c010b034:	8b 00                	mov    (%eax),%eax
c010b036:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return do_exit(error_code);
c010b039:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b03c:	89 04 24             	mov    %eax,(%esp)
c010b03f:	e8 c5 ee ff ff       	call   c0109f09 <do_exit>
}
c010b044:	c9                   	leave  
c010b045:	c3                   	ret    

c010b046 <sys_fork>:

static int
sys_fork(uint32_t arg[]) {
c010b046:	55                   	push   %ebp
c010b047:	89 e5                	mov    %esp,%ebp
c010b049:	83 ec 28             	sub    $0x28,%esp
    struct trapframe *tf = current->tf;
c010b04c:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c010b051:	8b 40 3c             	mov    0x3c(%eax),%eax
c010b054:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uintptr_t stack = tf->tf_esp;
c010b057:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b05a:	8b 40 44             	mov    0x44(%eax),%eax
c010b05d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return do_fork(0, stack, tf);
c010b060:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b063:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b067:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b06a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b06e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010b075:	e8 6e ed ff ff       	call   c0109de8 <do_fork>
}
c010b07a:	c9                   	leave  
c010b07b:	c3                   	ret    

c010b07c <sys_wait>:

static int
sys_wait(uint32_t arg[]) {
c010b07c:	55                   	push   %ebp
c010b07d:	89 e5                	mov    %esp,%ebp
c010b07f:	83 ec 28             	sub    $0x28,%esp
    int pid = (int)arg[0];
c010b082:	8b 45 08             	mov    0x8(%ebp),%eax
c010b085:	8b 00                	mov    (%eax),%eax
c010b087:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int *store = (int *)arg[1];
c010b08a:	8b 45 08             	mov    0x8(%ebp),%eax
c010b08d:	83 c0 04             	add    $0x4,%eax
c010b090:	8b 00                	mov    (%eax),%eax
c010b092:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return do_wait(pid, store);
c010b095:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b098:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b09c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b09f:	89 04 24             	mov    %eax,(%esp)
c010b0a2:	e8 e0 f7 ff ff       	call   c010a887 <do_wait>
}
c010b0a7:	c9                   	leave  
c010b0a8:	c3                   	ret    

c010b0a9 <sys_exec>:

static int
sys_exec(uint32_t arg[]) {
c010b0a9:	55                   	push   %ebp
c010b0aa:	89 e5                	mov    %esp,%ebp
c010b0ac:	83 ec 28             	sub    $0x28,%esp
    const char *name = (const char *)arg[0];
c010b0af:	8b 45 08             	mov    0x8(%ebp),%eax
c010b0b2:	8b 00                	mov    (%eax),%eax
c010b0b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    size_t len = (size_t)arg[1];
c010b0b7:	8b 45 08             	mov    0x8(%ebp),%eax
c010b0ba:	8b 40 04             	mov    0x4(%eax),%eax
c010b0bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    unsigned char *binary = (unsigned char *)arg[2];
c010b0c0:	8b 45 08             	mov    0x8(%ebp),%eax
c010b0c3:	83 c0 08             	add    $0x8,%eax
c010b0c6:	8b 00                	mov    (%eax),%eax
c010b0c8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    size_t size = (size_t)arg[3];
c010b0cb:	8b 45 08             	mov    0x8(%ebp),%eax
c010b0ce:	8b 40 0c             	mov    0xc(%eax),%eax
c010b0d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return do_execve(name, len, binary, size);
c010b0d4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b0d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010b0db:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b0de:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b0e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b0e5:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b0e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b0ec:	89 04 24             	mov    %eax,(%esp)
c010b0ef:	e8 47 f6 ff ff       	call   c010a73b <do_execve>
}
c010b0f4:	c9                   	leave  
c010b0f5:	c3                   	ret    

c010b0f6 <sys_yield>:

static int
sys_yield(uint32_t arg[]) {
c010b0f6:	55                   	push   %ebp
c010b0f7:	89 e5                	mov    %esp,%ebp
c010b0f9:	83 ec 08             	sub    $0x8,%esp
    return do_yield();
c010b0fc:	e8 70 f7 ff ff       	call   c010a871 <do_yield>
}
c010b101:	c9                   	leave  
c010b102:	c3                   	ret    

c010b103 <sys_kill>:

static int
sys_kill(uint32_t arg[]) {
c010b103:	55                   	push   %ebp
c010b104:	89 e5                	mov    %esp,%ebp
c010b106:	83 ec 28             	sub    $0x28,%esp
    int pid = (int)arg[0];
c010b109:	8b 45 08             	mov    0x8(%ebp),%eax
c010b10c:	8b 00                	mov    (%eax),%eax
c010b10e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return do_kill(pid);
c010b111:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b114:	89 04 24             	mov    %eax,(%esp)
c010b117:	e8 ff f8 ff ff       	call   c010aa1b <do_kill>
}
c010b11c:	c9                   	leave  
c010b11d:	c3                   	ret    

c010b11e <sys_getpid>:

static int
sys_getpid(uint32_t arg[]) {
c010b11e:	55                   	push   %ebp
c010b11f:	89 e5                	mov    %esp,%ebp
    return current->pid;
c010b121:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c010b126:	8b 40 04             	mov    0x4(%eax),%eax
}
c010b129:	5d                   	pop    %ebp
c010b12a:	c3                   	ret    

c010b12b <sys_putc>:

static int
sys_putc(uint32_t arg[]) {
c010b12b:	55                   	push   %ebp
c010b12c:	89 e5                	mov    %esp,%ebp
c010b12e:	83 ec 28             	sub    $0x28,%esp
    int c = (int)arg[0];
c010b131:	8b 45 08             	mov    0x8(%ebp),%eax
c010b134:	8b 00                	mov    (%eax),%eax
c010b136:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cputchar(c);
c010b139:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b13c:	89 04 24             	mov    %eax,(%esp)
c010b13f:	e8 8b 51 ff ff       	call   c01002cf <cputchar>
    return 0;
c010b144:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b149:	c9                   	leave  
c010b14a:	c3                   	ret    

c010b14b <sys_pgdir>:

static int
sys_pgdir(uint32_t arg[]) {
c010b14b:	55                   	push   %ebp
c010b14c:	89 e5                	mov    %esp,%ebp
c010b14e:	83 ec 08             	sub    $0x8,%esp
    print_pgdir();
c010b151:	e8 ef dd ff ff       	call   c0108f45 <print_pgdir>
    return 0;
c010b156:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b15b:	c9                   	leave  
c010b15c:	c3                   	ret    

c010b15d <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
c010b15d:	55                   	push   %ebp
c010b15e:	89 e5                	mov    %esp,%ebp
c010b160:	83 ec 48             	sub    $0x48,%esp
    struct trapframe *tf = current->tf;
c010b163:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c010b168:	8b 40 3c             	mov    0x3c(%eax),%eax
c010b16b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uint32_t arg[5];
    int num = tf->tf_regs.reg_eax;
c010b16e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b171:	8b 40 1c             	mov    0x1c(%eax),%eax
c010b174:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (num >= 0 && num < NUM_SYSCALLS) {
c010b177:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010b17b:	78 5e                	js     c010b1db <syscall+0x7e>
c010b17d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b180:	83 f8 1f             	cmp    $0x1f,%eax
c010b183:	77 56                	ja     c010b1db <syscall+0x7e>
        if (syscalls[num] != NULL) {
c010b185:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b188:	8b 04 85 80 aa 12 c0 	mov    -0x3fed5580(,%eax,4),%eax
c010b18f:	85 c0                	test   %eax,%eax
c010b191:	74 48                	je     c010b1db <syscall+0x7e>
            arg[0] = tf->tf_regs.reg_edx;
c010b193:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b196:	8b 40 14             	mov    0x14(%eax),%eax
c010b199:	89 45 dc             	mov    %eax,-0x24(%ebp)
            arg[1] = tf->tf_regs.reg_ecx;
c010b19c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b19f:	8b 40 18             	mov    0x18(%eax),%eax
c010b1a2:	89 45 e0             	mov    %eax,-0x20(%ebp)
            arg[2] = tf->tf_regs.reg_ebx;
c010b1a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b1a8:	8b 40 10             	mov    0x10(%eax),%eax
c010b1ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            arg[3] = tf->tf_regs.reg_edi;
c010b1ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b1b1:	8b 00                	mov    (%eax),%eax
c010b1b3:	89 45 e8             	mov    %eax,-0x18(%ebp)
            arg[4] = tf->tf_regs.reg_esi;
c010b1b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b1b9:	8b 40 04             	mov    0x4(%eax),%eax
c010b1bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
            tf->tf_regs.reg_eax = syscalls[num](arg);
c010b1bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b1c2:	8b 04 85 80 aa 12 c0 	mov    -0x3fed5580(,%eax,4),%eax
c010b1c9:	8d 55 dc             	lea    -0x24(%ebp),%edx
c010b1cc:	89 14 24             	mov    %edx,(%esp)
c010b1cf:	ff d0                	call   *%eax
c010b1d1:	89 c2                	mov    %eax,%edx
c010b1d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b1d6:	89 50 1c             	mov    %edx,0x1c(%eax)
            return ;
c010b1d9:	eb 46                	jmp    c010b221 <syscall+0xc4>
        }
    }
    print_trapframe(tf);
c010b1db:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b1de:	89 04 24             	mov    %eax,(%esp)
c010b1e1:	e8 2c 72 ff ff       	call   c0102412 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
c010b1e6:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c010b1eb:	8d 50 48             	lea    0x48(%eax),%edx
c010b1ee:	a1 28 f0 19 c0       	mov    0xc019f028,%eax
c010b1f3:	8b 40 04             	mov    0x4(%eax),%eax
c010b1f6:	89 54 24 14          	mov    %edx,0x14(%esp)
c010b1fa:	89 44 24 10          	mov    %eax,0x10(%esp)
c010b1fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b201:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010b205:	c7 44 24 08 d8 e3 10 	movl   $0xc010e3d8,0x8(%esp)
c010b20c:	c0 
c010b20d:	c7 44 24 04 63 00 00 	movl   $0x63,0x4(%esp)
c010b214:	00 
c010b215:	c7 04 24 04 e4 10 c0 	movl   $0xc010e404,(%esp)
c010b21c:	e8 df 51 ff ff       	call   c0100400 <__panic>
            num, current->pid, current->name);
}
c010b221:	c9                   	leave  
c010b222:	c3                   	ret    

c010b223 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c010b223:	55                   	push   %ebp
c010b224:	89 e5                	mov    %esp,%ebp
c010b226:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010b229:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c010b230:	eb 04                	jmp    c010b236 <strlen+0x13>
        cnt ++;
c010b232:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (*s ++ != '\0') {
c010b236:	8b 45 08             	mov    0x8(%ebp),%eax
c010b239:	8d 50 01             	lea    0x1(%eax),%edx
c010b23c:	89 55 08             	mov    %edx,0x8(%ebp)
c010b23f:	0f b6 00             	movzbl (%eax),%eax
c010b242:	84 c0                	test   %al,%al
c010b244:	75 ec                	jne    c010b232 <strlen+0xf>
    }
    return cnt;
c010b246:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010b249:	c9                   	leave  
c010b24a:	c3                   	ret    

c010b24b <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c010b24b:	55                   	push   %ebp
c010b24c:	89 e5                	mov    %esp,%ebp
c010b24e:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010b251:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c010b258:	eb 04                	jmp    c010b25e <strnlen+0x13>
        cnt ++;
c010b25a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c010b25e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b261:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010b264:	73 10                	jae    c010b276 <strnlen+0x2b>
c010b266:	8b 45 08             	mov    0x8(%ebp),%eax
c010b269:	8d 50 01             	lea    0x1(%eax),%edx
c010b26c:	89 55 08             	mov    %edx,0x8(%ebp)
c010b26f:	0f b6 00             	movzbl (%eax),%eax
c010b272:	84 c0                	test   %al,%al
c010b274:	75 e4                	jne    c010b25a <strnlen+0xf>
    }
    return cnt;
c010b276:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010b279:	c9                   	leave  
c010b27a:	c3                   	ret    

c010b27b <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c010b27b:	55                   	push   %ebp
c010b27c:	89 e5                	mov    %esp,%ebp
c010b27e:	57                   	push   %edi
c010b27f:	56                   	push   %esi
c010b280:	83 ec 20             	sub    $0x20,%esp
c010b283:	8b 45 08             	mov    0x8(%ebp),%eax
c010b286:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b289:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b28c:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c010b28f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010b292:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b295:	89 d1                	mov    %edx,%ecx
c010b297:	89 c2                	mov    %eax,%edx
c010b299:	89 ce                	mov    %ecx,%esi
c010b29b:	89 d7                	mov    %edx,%edi
c010b29d:	ac                   	lods   %ds:(%esi),%al
c010b29e:	aa                   	stos   %al,%es:(%edi)
c010b29f:	84 c0                	test   %al,%al
c010b2a1:	75 fa                	jne    c010b29d <strcpy+0x22>
c010b2a3:	89 fa                	mov    %edi,%edx
c010b2a5:	89 f1                	mov    %esi,%ecx
c010b2a7:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010b2aa:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010b2ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c010b2b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c010b2b3:	83 c4 20             	add    $0x20,%esp
c010b2b6:	5e                   	pop    %esi
c010b2b7:	5f                   	pop    %edi
c010b2b8:	5d                   	pop    %ebp
c010b2b9:	c3                   	ret    

c010b2ba <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c010b2ba:	55                   	push   %ebp
c010b2bb:	89 e5                	mov    %esp,%ebp
c010b2bd:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c010b2c0:	8b 45 08             	mov    0x8(%ebp),%eax
c010b2c3:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c010b2c6:	eb 21                	jmp    c010b2e9 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
c010b2c8:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b2cb:	0f b6 10             	movzbl (%eax),%edx
c010b2ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b2d1:	88 10                	mov    %dl,(%eax)
c010b2d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b2d6:	0f b6 00             	movzbl (%eax),%eax
c010b2d9:	84 c0                	test   %al,%al
c010b2db:	74 04                	je     c010b2e1 <strncpy+0x27>
            src ++;
c010b2dd:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
c010b2e1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010b2e5:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    while (len > 0) {
c010b2e9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b2ed:	75 d9                	jne    c010b2c8 <strncpy+0xe>
    }
    return dst;
c010b2ef:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010b2f2:	c9                   	leave  
c010b2f3:	c3                   	ret    

c010b2f4 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c010b2f4:	55                   	push   %ebp
c010b2f5:	89 e5                	mov    %esp,%ebp
c010b2f7:	57                   	push   %edi
c010b2f8:	56                   	push   %esi
c010b2f9:	83 ec 20             	sub    $0x20,%esp
c010b2fc:	8b 45 08             	mov    0x8(%ebp),%eax
c010b2ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b302:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b305:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c010b308:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b30b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b30e:	89 d1                	mov    %edx,%ecx
c010b310:	89 c2                	mov    %eax,%edx
c010b312:	89 ce                	mov    %ecx,%esi
c010b314:	89 d7                	mov    %edx,%edi
c010b316:	ac                   	lods   %ds:(%esi),%al
c010b317:	ae                   	scas   %es:(%edi),%al
c010b318:	75 08                	jne    c010b322 <strcmp+0x2e>
c010b31a:	84 c0                	test   %al,%al
c010b31c:	75 f8                	jne    c010b316 <strcmp+0x22>
c010b31e:	31 c0                	xor    %eax,%eax
c010b320:	eb 04                	jmp    c010b326 <strcmp+0x32>
c010b322:	19 c0                	sbb    %eax,%eax
c010b324:	0c 01                	or     $0x1,%al
c010b326:	89 fa                	mov    %edi,%edx
c010b328:	89 f1                	mov    %esi,%ecx
c010b32a:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010b32d:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010b330:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c010b333:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c010b336:	83 c4 20             	add    $0x20,%esp
c010b339:	5e                   	pop    %esi
c010b33a:	5f                   	pop    %edi
c010b33b:	5d                   	pop    %ebp
c010b33c:	c3                   	ret    

c010b33d <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c010b33d:	55                   	push   %ebp
c010b33e:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010b340:	eb 0c                	jmp    c010b34e <strncmp+0x11>
        n --, s1 ++, s2 ++;
c010b342:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010b346:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010b34a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010b34e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b352:	74 1a                	je     c010b36e <strncmp+0x31>
c010b354:	8b 45 08             	mov    0x8(%ebp),%eax
c010b357:	0f b6 00             	movzbl (%eax),%eax
c010b35a:	84 c0                	test   %al,%al
c010b35c:	74 10                	je     c010b36e <strncmp+0x31>
c010b35e:	8b 45 08             	mov    0x8(%ebp),%eax
c010b361:	0f b6 10             	movzbl (%eax),%edx
c010b364:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b367:	0f b6 00             	movzbl (%eax),%eax
c010b36a:	38 c2                	cmp    %al,%dl
c010b36c:	74 d4                	je     c010b342 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c010b36e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b372:	74 18                	je     c010b38c <strncmp+0x4f>
c010b374:	8b 45 08             	mov    0x8(%ebp),%eax
c010b377:	0f b6 00             	movzbl (%eax),%eax
c010b37a:	0f b6 d0             	movzbl %al,%edx
c010b37d:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b380:	0f b6 00             	movzbl (%eax),%eax
c010b383:	0f b6 c0             	movzbl %al,%eax
c010b386:	29 c2                	sub    %eax,%edx
c010b388:	89 d0                	mov    %edx,%eax
c010b38a:	eb 05                	jmp    c010b391 <strncmp+0x54>
c010b38c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b391:	5d                   	pop    %ebp
c010b392:	c3                   	ret    

c010b393 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c010b393:	55                   	push   %ebp
c010b394:	89 e5                	mov    %esp,%ebp
c010b396:	83 ec 04             	sub    $0x4,%esp
c010b399:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b39c:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010b39f:	eb 14                	jmp    c010b3b5 <strchr+0x22>
        if (*s == c) {
c010b3a1:	8b 45 08             	mov    0x8(%ebp),%eax
c010b3a4:	0f b6 00             	movzbl (%eax),%eax
c010b3a7:	3a 45 fc             	cmp    -0x4(%ebp),%al
c010b3aa:	75 05                	jne    c010b3b1 <strchr+0x1e>
            return (char *)s;
c010b3ac:	8b 45 08             	mov    0x8(%ebp),%eax
c010b3af:	eb 13                	jmp    c010b3c4 <strchr+0x31>
        }
        s ++;
c010b3b1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
c010b3b5:	8b 45 08             	mov    0x8(%ebp),%eax
c010b3b8:	0f b6 00             	movzbl (%eax),%eax
c010b3bb:	84 c0                	test   %al,%al
c010b3bd:	75 e2                	jne    c010b3a1 <strchr+0xe>
    }
    return NULL;
c010b3bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b3c4:	c9                   	leave  
c010b3c5:	c3                   	ret    

c010b3c6 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c010b3c6:	55                   	push   %ebp
c010b3c7:	89 e5                	mov    %esp,%ebp
c010b3c9:	83 ec 04             	sub    $0x4,%esp
c010b3cc:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b3cf:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010b3d2:	eb 11                	jmp    c010b3e5 <strfind+0x1f>
        if (*s == c) {
c010b3d4:	8b 45 08             	mov    0x8(%ebp),%eax
c010b3d7:	0f b6 00             	movzbl (%eax),%eax
c010b3da:	3a 45 fc             	cmp    -0x4(%ebp),%al
c010b3dd:	75 02                	jne    c010b3e1 <strfind+0x1b>
            break;
c010b3df:	eb 0e                	jmp    c010b3ef <strfind+0x29>
        }
        s ++;
c010b3e1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
c010b3e5:	8b 45 08             	mov    0x8(%ebp),%eax
c010b3e8:	0f b6 00             	movzbl (%eax),%eax
c010b3eb:	84 c0                	test   %al,%al
c010b3ed:	75 e5                	jne    c010b3d4 <strfind+0xe>
    }
    return (char *)s;
c010b3ef:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010b3f2:	c9                   	leave  
c010b3f3:	c3                   	ret    

c010b3f4 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c010b3f4:	55                   	push   %ebp
c010b3f5:	89 e5                	mov    %esp,%ebp
c010b3f7:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c010b3fa:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c010b401:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c010b408:	eb 04                	jmp    c010b40e <strtol+0x1a>
        s ++;
c010b40a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c010b40e:	8b 45 08             	mov    0x8(%ebp),%eax
c010b411:	0f b6 00             	movzbl (%eax),%eax
c010b414:	3c 20                	cmp    $0x20,%al
c010b416:	74 f2                	je     c010b40a <strtol+0x16>
c010b418:	8b 45 08             	mov    0x8(%ebp),%eax
c010b41b:	0f b6 00             	movzbl (%eax),%eax
c010b41e:	3c 09                	cmp    $0x9,%al
c010b420:	74 e8                	je     c010b40a <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
c010b422:	8b 45 08             	mov    0x8(%ebp),%eax
c010b425:	0f b6 00             	movzbl (%eax),%eax
c010b428:	3c 2b                	cmp    $0x2b,%al
c010b42a:	75 06                	jne    c010b432 <strtol+0x3e>
        s ++;
c010b42c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010b430:	eb 15                	jmp    c010b447 <strtol+0x53>
    }
    else if (*s == '-') {
c010b432:	8b 45 08             	mov    0x8(%ebp),%eax
c010b435:	0f b6 00             	movzbl (%eax),%eax
c010b438:	3c 2d                	cmp    $0x2d,%al
c010b43a:	75 0b                	jne    c010b447 <strtol+0x53>
        s ++, neg = 1;
c010b43c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010b440:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c010b447:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b44b:	74 06                	je     c010b453 <strtol+0x5f>
c010b44d:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c010b451:	75 24                	jne    c010b477 <strtol+0x83>
c010b453:	8b 45 08             	mov    0x8(%ebp),%eax
c010b456:	0f b6 00             	movzbl (%eax),%eax
c010b459:	3c 30                	cmp    $0x30,%al
c010b45b:	75 1a                	jne    c010b477 <strtol+0x83>
c010b45d:	8b 45 08             	mov    0x8(%ebp),%eax
c010b460:	83 c0 01             	add    $0x1,%eax
c010b463:	0f b6 00             	movzbl (%eax),%eax
c010b466:	3c 78                	cmp    $0x78,%al
c010b468:	75 0d                	jne    c010b477 <strtol+0x83>
        s += 2, base = 16;
c010b46a:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c010b46e:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c010b475:	eb 2a                	jmp    c010b4a1 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
c010b477:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b47b:	75 17                	jne    c010b494 <strtol+0xa0>
c010b47d:	8b 45 08             	mov    0x8(%ebp),%eax
c010b480:	0f b6 00             	movzbl (%eax),%eax
c010b483:	3c 30                	cmp    $0x30,%al
c010b485:	75 0d                	jne    c010b494 <strtol+0xa0>
        s ++, base = 8;
c010b487:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010b48b:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c010b492:	eb 0d                	jmp    c010b4a1 <strtol+0xad>
    }
    else if (base == 0) {
c010b494:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b498:	75 07                	jne    c010b4a1 <strtol+0xad>
        base = 10;
c010b49a:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c010b4a1:	8b 45 08             	mov    0x8(%ebp),%eax
c010b4a4:	0f b6 00             	movzbl (%eax),%eax
c010b4a7:	3c 2f                	cmp    $0x2f,%al
c010b4a9:	7e 1b                	jle    c010b4c6 <strtol+0xd2>
c010b4ab:	8b 45 08             	mov    0x8(%ebp),%eax
c010b4ae:	0f b6 00             	movzbl (%eax),%eax
c010b4b1:	3c 39                	cmp    $0x39,%al
c010b4b3:	7f 11                	jg     c010b4c6 <strtol+0xd2>
            dig = *s - '0';
c010b4b5:	8b 45 08             	mov    0x8(%ebp),%eax
c010b4b8:	0f b6 00             	movzbl (%eax),%eax
c010b4bb:	0f be c0             	movsbl %al,%eax
c010b4be:	83 e8 30             	sub    $0x30,%eax
c010b4c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b4c4:	eb 48                	jmp    c010b50e <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
c010b4c6:	8b 45 08             	mov    0x8(%ebp),%eax
c010b4c9:	0f b6 00             	movzbl (%eax),%eax
c010b4cc:	3c 60                	cmp    $0x60,%al
c010b4ce:	7e 1b                	jle    c010b4eb <strtol+0xf7>
c010b4d0:	8b 45 08             	mov    0x8(%ebp),%eax
c010b4d3:	0f b6 00             	movzbl (%eax),%eax
c010b4d6:	3c 7a                	cmp    $0x7a,%al
c010b4d8:	7f 11                	jg     c010b4eb <strtol+0xf7>
            dig = *s - 'a' + 10;
c010b4da:	8b 45 08             	mov    0x8(%ebp),%eax
c010b4dd:	0f b6 00             	movzbl (%eax),%eax
c010b4e0:	0f be c0             	movsbl %al,%eax
c010b4e3:	83 e8 57             	sub    $0x57,%eax
c010b4e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b4e9:	eb 23                	jmp    c010b50e <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c010b4eb:	8b 45 08             	mov    0x8(%ebp),%eax
c010b4ee:	0f b6 00             	movzbl (%eax),%eax
c010b4f1:	3c 40                	cmp    $0x40,%al
c010b4f3:	7e 3d                	jle    c010b532 <strtol+0x13e>
c010b4f5:	8b 45 08             	mov    0x8(%ebp),%eax
c010b4f8:	0f b6 00             	movzbl (%eax),%eax
c010b4fb:	3c 5a                	cmp    $0x5a,%al
c010b4fd:	7f 33                	jg     c010b532 <strtol+0x13e>
            dig = *s - 'A' + 10;
c010b4ff:	8b 45 08             	mov    0x8(%ebp),%eax
c010b502:	0f b6 00             	movzbl (%eax),%eax
c010b505:	0f be c0             	movsbl %al,%eax
c010b508:	83 e8 37             	sub    $0x37,%eax
c010b50b:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c010b50e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b511:	3b 45 10             	cmp    0x10(%ebp),%eax
c010b514:	7c 02                	jl     c010b518 <strtol+0x124>
            break;
c010b516:	eb 1a                	jmp    c010b532 <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
c010b518:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010b51c:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b51f:	0f af 45 10          	imul   0x10(%ebp),%eax
c010b523:	89 c2                	mov    %eax,%edx
c010b525:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b528:	01 d0                	add    %edx,%eax
c010b52a:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c010b52d:	e9 6f ff ff ff       	jmp    c010b4a1 <strtol+0xad>

    if (endptr) {
c010b532:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010b536:	74 08                	je     c010b540 <strtol+0x14c>
        *endptr = (char *) s;
c010b538:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b53b:	8b 55 08             	mov    0x8(%ebp),%edx
c010b53e:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c010b540:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010b544:	74 07                	je     c010b54d <strtol+0x159>
c010b546:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b549:	f7 d8                	neg    %eax
c010b54b:	eb 03                	jmp    c010b550 <strtol+0x15c>
c010b54d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c010b550:	c9                   	leave  
c010b551:	c3                   	ret    

c010b552 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c010b552:	55                   	push   %ebp
c010b553:	89 e5                	mov    %esp,%ebp
c010b555:	57                   	push   %edi
c010b556:	83 ec 24             	sub    $0x24,%esp
c010b559:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b55c:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c010b55f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c010b563:	8b 55 08             	mov    0x8(%ebp),%edx
c010b566:	89 55 f8             	mov    %edx,-0x8(%ebp)
c010b569:	88 45 f7             	mov    %al,-0x9(%ebp)
c010b56c:	8b 45 10             	mov    0x10(%ebp),%eax
c010b56f:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c010b572:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c010b575:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c010b579:	8b 55 f8             	mov    -0x8(%ebp),%edx
c010b57c:	89 d7                	mov    %edx,%edi
c010b57e:	f3 aa                	rep stos %al,%es:(%edi)
c010b580:	89 fa                	mov    %edi,%edx
c010b582:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010b585:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c010b588:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c010b58b:	83 c4 24             	add    $0x24,%esp
c010b58e:	5f                   	pop    %edi
c010b58f:	5d                   	pop    %ebp
c010b590:	c3                   	ret    

c010b591 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c010b591:	55                   	push   %ebp
c010b592:	89 e5                	mov    %esp,%ebp
c010b594:	57                   	push   %edi
c010b595:	56                   	push   %esi
c010b596:	53                   	push   %ebx
c010b597:	83 ec 30             	sub    $0x30,%esp
c010b59a:	8b 45 08             	mov    0x8(%ebp),%eax
c010b59d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b5a0:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b5a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010b5a6:	8b 45 10             	mov    0x10(%ebp),%eax
c010b5a9:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c010b5ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b5af:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010b5b2:	73 42                	jae    c010b5f6 <memmove+0x65>
c010b5b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b5b7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010b5ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b5bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010b5c0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b5c3:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010b5c6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010b5c9:	c1 e8 02             	shr    $0x2,%eax
c010b5cc:	89 c1                	mov    %eax,%ecx
    asm volatile (
c010b5ce:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010b5d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b5d4:	89 d7                	mov    %edx,%edi
c010b5d6:	89 c6                	mov    %eax,%esi
c010b5d8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010b5da:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010b5dd:	83 e1 03             	and    $0x3,%ecx
c010b5e0:	74 02                	je     c010b5e4 <memmove+0x53>
c010b5e2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010b5e4:	89 f0                	mov    %esi,%eax
c010b5e6:	89 fa                	mov    %edi,%edx
c010b5e8:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c010b5eb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010b5ee:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c010b5f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010b5f4:	eb 36                	jmp    c010b62c <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c010b5f6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b5f9:	8d 50 ff             	lea    -0x1(%eax),%edx
c010b5fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b5ff:	01 c2                	add    %eax,%edx
c010b601:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b604:	8d 48 ff             	lea    -0x1(%eax),%ecx
c010b607:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b60a:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c010b60d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b610:	89 c1                	mov    %eax,%ecx
c010b612:	89 d8                	mov    %ebx,%eax
c010b614:	89 d6                	mov    %edx,%esi
c010b616:	89 c7                	mov    %eax,%edi
c010b618:	fd                   	std    
c010b619:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010b61b:	fc                   	cld    
c010b61c:	89 f8                	mov    %edi,%eax
c010b61e:	89 f2                	mov    %esi,%edx
c010b620:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c010b623:	89 55 c8             	mov    %edx,-0x38(%ebp)
c010b626:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c010b629:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c010b62c:	83 c4 30             	add    $0x30,%esp
c010b62f:	5b                   	pop    %ebx
c010b630:	5e                   	pop    %esi
c010b631:	5f                   	pop    %edi
c010b632:	5d                   	pop    %ebp
c010b633:	c3                   	ret    

c010b634 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c010b634:	55                   	push   %ebp
c010b635:	89 e5                	mov    %esp,%ebp
c010b637:	57                   	push   %edi
c010b638:	56                   	push   %esi
c010b639:	83 ec 20             	sub    $0x20,%esp
c010b63c:	8b 45 08             	mov    0x8(%ebp),%eax
c010b63f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b642:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b645:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b648:	8b 45 10             	mov    0x10(%ebp),%eax
c010b64b:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010b64e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b651:	c1 e8 02             	shr    $0x2,%eax
c010b654:	89 c1                	mov    %eax,%ecx
    asm volatile (
c010b656:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b659:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b65c:	89 d7                	mov    %edx,%edi
c010b65e:	89 c6                	mov    %eax,%esi
c010b660:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010b662:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c010b665:	83 e1 03             	and    $0x3,%ecx
c010b668:	74 02                	je     c010b66c <memcpy+0x38>
c010b66a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010b66c:	89 f0                	mov    %esi,%eax
c010b66e:	89 fa                	mov    %edi,%edx
c010b670:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010b673:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010b676:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c010b679:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c010b67c:	83 c4 20             	add    $0x20,%esp
c010b67f:	5e                   	pop    %esi
c010b680:	5f                   	pop    %edi
c010b681:	5d                   	pop    %ebp
c010b682:	c3                   	ret    

c010b683 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c010b683:	55                   	push   %ebp
c010b684:	89 e5                	mov    %esp,%ebp
c010b686:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c010b689:	8b 45 08             	mov    0x8(%ebp),%eax
c010b68c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c010b68f:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b692:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c010b695:	eb 30                	jmp    c010b6c7 <memcmp+0x44>
        if (*s1 != *s2) {
c010b697:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b69a:	0f b6 10             	movzbl (%eax),%edx
c010b69d:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b6a0:	0f b6 00             	movzbl (%eax),%eax
c010b6a3:	38 c2                	cmp    %al,%dl
c010b6a5:	74 18                	je     c010b6bf <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c010b6a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b6aa:	0f b6 00             	movzbl (%eax),%eax
c010b6ad:	0f b6 d0             	movzbl %al,%edx
c010b6b0:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b6b3:	0f b6 00             	movzbl (%eax),%eax
c010b6b6:	0f b6 c0             	movzbl %al,%eax
c010b6b9:	29 c2                	sub    %eax,%edx
c010b6bb:	89 d0                	mov    %edx,%eax
c010b6bd:	eb 1a                	jmp    c010b6d9 <memcmp+0x56>
        }
        s1 ++, s2 ++;
c010b6bf:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010b6c3:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
    while (n -- > 0) {
c010b6c7:	8b 45 10             	mov    0x10(%ebp),%eax
c010b6ca:	8d 50 ff             	lea    -0x1(%eax),%edx
c010b6cd:	89 55 10             	mov    %edx,0x10(%ebp)
c010b6d0:	85 c0                	test   %eax,%eax
c010b6d2:	75 c3                	jne    c010b697 <memcmp+0x14>
    }
    return 0;
c010b6d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b6d9:	c9                   	leave  
c010b6da:	c3                   	ret    

c010b6db <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c010b6db:	55                   	push   %ebp
c010b6dc:	89 e5                	mov    %esp,%ebp
c010b6de:	83 ec 58             	sub    $0x58,%esp
c010b6e1:	8b 45 10             	mov    0x10(%ebp),%eax
c010b6e4:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010b6e7:	8b 45 14             	mov    0x14(%ebp),%eax
c010b6ea:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c010b6ed:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010b6f0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010b6f3:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010b6f6:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c010b6f9:	8b 45 18             	mov    0x18(%ebp),%eax
c010b6fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010b6ff:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b702:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010b705:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010b708:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010b70b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b70e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b711:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010b715:	74 1c                	je     c010b733 <printnum+0x58>
c010b717:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b71a:	ba 00 00 00 00       	mov    $0x0,%edx
c010b71f:	f7 75 e4             	divl   -0x1c(%ebp)
c010b722:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010b725:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b728:	ba 00 00 00 00       	mov    $0x0,%edx
c010b72d:	f7 75 e4             	divl   -0x1c(%ebp)
c010b730:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b733:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b736:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b739:	f7 75 e4             	divl   -0x1c(%ebp)
c010b73c:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010b73f:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010b742:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b745:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010b748:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010b74b:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010b74e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010b751:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c010b754:	8b 45 18             	mov    0x18(%ebp),%eax
c010b757:	ba 00 00 00 00       	mov    $0x0,%edx
c010b75c:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010b75f:	77 56                	ja     c010b7b7 <printnum+0xdc>
c010b761:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010b764:	72 05                	jb     c010b76b <printnum+0x90>
c010b766:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c010b769:	77 4c                	ja     c010b7b7 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c010b76b:	8b 45 1c             	mov    0x1c(%ebp),%eax
c010b76e:	8d 50 ff             	lea    -0x1(%eax),%edx
c010b771:	8b 45 20             	mov    0x20(%ebp),%eax
c010b774:	89 44 24 18          	mov    %eax,0x18(%esp)
c010b778:	89 54 24 14          	mov    %edx,0x14(%esp)
c010b77c:	8b 45 18             	mov    0x18(%ebp),%eax
c010b77f:	89 44 24 10          	mov    %eax,0x10(%esp)
c010b783:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b786:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010b789:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b78d:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010b791:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b794:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b798:	8b 45 08             	mov    0x8(%ebp),%eax
c010b79b:	89 04 24             	mov    %eax,(%esp)
c010b79e:	e8 38 ff ff ff       	call   c010b6db <printnum>
c010b7a3:	eb 1c                	jmp    c010b7c1 <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c010b7a5:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b7a8:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b7ac:	8b 45 20             	mov    0x20(%ebp),%eax
c010b7af:	89 04 24             	mov    %eax,(%esp)
c010b7b2:	8b 45 08             	mov    0x8(%ebp),%eax
c010b7b5:	ff d0                	call   *%eax
        while (-- width > 0)
c010b7b7:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
c010b7bb:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c010b7bf:	7f e4                	jg     c010b7a5 <printnum+0xca>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c010b7c1:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010b7c4:	05 24 e5 10 c0       	add    $0xc010e524,%eax
c010b7c9:	0f b6 00             	movzbl (%eax),%eax
c010b7cc:	0f be c0             	movsbl %al,%eax
c010b7cf:	8b 55 0c             	mov    0xc(%ebp),%edx
c010b7d2:	89 54 24 04          	mov    %edx,0x4(%esp)
c010b7d6:	89 04 24             	mov    %eax,(%esp)
c010b7d9:	8b 45 08             	mov    0x8(%ebp),%eax
c010b7dc:	ff d0                	call   *%eax
}
c010b7de:	c9                   	leave  
c010b7df:	c3                   	ret    

c010b7e0 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c010b7e0:	55                   	push   %ebp
c010b7e1:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010b7e3:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010b7e7:	7e 14                	jle    c010b7fd <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c010b7e9:	8b 45 08             	mov    0x8(%ebp),%eax
c010b7ec:	8b 00                	mov    (%eax),%eax
c010b7ee:	8d 48 08             	lea    0x8(%eax),%ecx
c010b7f1:	8b 55 08             	mov    0x8(%ebp),%edx
c010b7f4:	89 0a                	mov    %ecx,(%edx)
c010b7f6:	8b 50 04             	mov    0x4(%eax),%edx
c010b7f9:	8b 00                	mov    (%eax),%eax
c010b7fb:	eb 30                	jmp    c010b82d <getuint+0x4d>
    }
    else if (lflag) {
c010b7fd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010b801:	74 16                	je     c010b819 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c010b803:	8b 45 08             	mov    0x8(%ebp),%eax
c010b806:	8b 00                	mov    (%eax),%eax
c010b808:	8d 48 04             	lea    0x4(%eax),%ecx
c010b80b:	8b 55 08             	mov    0x8(%ebp),%edx
c010b80e:	89 0a                	mov    %ecx,(%edx)
c010b810:	8b 00                	mov    (%eax),%eax
c010b812:	ba 00 00 00 00       	mov    $0x0,%edx
c010b817:	eb 14                	jmp    c010b82d <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c010b819:	8b 45 08             	mov    0x8(%ebp),%eax
c010b81c:	8b 00                	mov    (%eax),%eax
c010b81e:	8d 48 04             	lea    0x4(%eax),%ecx
c010b821:	8b 55 08             	mov    0x8(%ebp),%edx
c010b824:	89 0a                	mov    %ecx,(%edx)
c010b826:	8b 00                	mov    (%eax),%eax
c010b828:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c010b82d:	5d                   	pop    %ebp
c010b82e:	c3                   	ret    

c010b82f <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c010b82f:	55                   	push   %ebp
c010b830:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010b832:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010b836:	7e 14                	jle    c010b84c <getint+0x1d>
        return va_arg(*ap, long long);
c010b838:	8b 45 08             	mov    0x8(%ebp),%eax
c010b83b:	8b 00                	mov    (%eax),%eax
c010b83d:	8d 48 08             	lea    0x8(%eax),%ecx
c010b840:	8b 55 08             	mov    0x8(%ebp),%edx
c010b843:	89 0a                	mov    %ecx,(%edx)
c010b845:	8b 50 04             	mov    0x4(%eax),%edx
c010b848:	8b 00                	mov    (%eax),%eax
c010b84a:	eb 28                	jmp    c010b874 <getint+0x45>
    }
    else if (lflag) {
c010b84c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010b850:	74 12                	je     c010b864 <getint+0x35>
        return va_arg(*ap, long);
c010b852:	8b 45 08             	mov    0x8(%ebp),%eax
c010b855:	8b 00                	mov    (%eax),%eax
c010b857:	8d 48 04             	lea    0x4(%eax),%ecx
c010b85a:	8b 55 08             	mov    0x8(%ebp),%edx
c010b85d:	89 0a                	mov    %ecx,(%edx)
c010b85f:	8b 00                	mov    (%eax),%eax
c010b861:	99                   	cltd   
c010b862:	eb 10                	jmp    c010b874 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c010b864:	8b 45 08             	mov    0x8(%ebp),%eax
c010b867:	8b 00                	mov    (%eax),%eax
c010b869:	8d 48 04             	lea    0x4(%eax),%ecx
c010b86c:	8b 55 08             	mov    0x8(%ebp),%edx
c010b86f:	89 0a                	mov    %ecx,(%edx)
c010b871:	8b 00                	mov    (%eax),%eax
c010b873:	99                   	cltd   
    }
}
c010b874:	5d                   	pop    %ebp
c010b875:	c3                   	ret    

c010b876 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c010b876:	55                   	push   %ebp
c010b877:	89 e5                	mov    %esp,%ebp
c010b879:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c010b87c:	8d 45 14             	lea    0x14(%ebp),%eax
c010b87f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c010b882:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b885:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010b889:	8b 45 10             	mov    0x10(%ebp),%eax
c010b88c:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b890:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b893:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b897:	8b 45 08             	mov    0x8(%ebp),%eax
c010b89a:	89 04 24             	mov    %eax,(%esp)
c010b89d:	e8 02 00 00 00       	call   c010b8a4 <vprintfmt>
    va_end(ap);
}
c010b8a2:	c9                   	leave  
c010b8a3:	c3                   	ret    

c010b8a4 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c010b8a4:	55                   	push   %ebp
c010b8a5:	89 e5                	mov    %esp,%ebp
c010b8a7:	56                   	push   %esi
c010b8a8:	53                   	push   %ebx
c010b8a9:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010b8ac:	eb 18                	jmp    c010b8c6 <vprintfmt+0x22>
            if (ch == '\0') {
c010b8ae:	85 db                	test   %ebx,%ebx
c010b8b0:	75 05                	jne    c010b8b7 <vprintfmt+0x13>
                return;
c010b8b2:	e9 d1 03 00 00       	jmp    c010bc88 <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
c010b8b7:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b8ba:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b8be:	89 1c 24             	mov    %ebx,(%esp)
c010b8c1:	8b 45 08             	mov    0x8(%ebp),%eax
c010b8c4:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010b8c6:	8b 45 10             	mov    0x10(%ebp),%eax
c010b8c9:	8d 50 01             	lea    0x1(%eax),%edx
c010b8cc:	89 55 10             	mov    %edx,0x10(%ebp)
c010b8cf:	0f b6 00             	movzbl (%eax),%eax
c010b8d2:	0f b6 d8             	movzbl %al,%ebx
c010b8d5:	83 fb 25             	cmp    $0x25,%ebx
c010b8d8:	75 d4                	jne    c010b8ae <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
c010b8da:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c010b8de:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c010b8e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010b8e8:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c010b8eb:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010b8f2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010b8f5:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c010b8f8:	8b 45 10             	mov    0x10(%ebp),%eax
c010b8fb:	8d 50 01             	lea    0x1(%eax),%edx
c010b8fe:	89 55 10             	mov    %edx,0x10(%ebp)
c010b901:	0f b6 00             	movzbl (%eax),%eax
c010b904:	0f b6 d8             	movzbl %al,%ebx
c010b907:	8d 43 dd             	lea    -0x23(%ebx),%eax
c010b90a:	83 f8 55             	cmp    $0x55,%eax
c010b90d:	0f 87 44 03 00 00    	ja     c010bc57 <vprintfmt+0x3b3>
c010b913:	8b 04 85 48 e5 10 c0 	mov    -0x3fef1ab8(,%eax,4),%eax
c010b91a:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c010b91c:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c010b920:	eb d6                	jmp    c010b8f8 <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c010b922:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c010b926:	eb d0                	jmp    c010b8f8 <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010b928:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c010b92f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010b932:	89 d0                	mov    %edx,%eax
c010b934:	c1 e0 02             	shl    $0x2,%eax
c010b937:	01 d0                	add    %edx,%eax
c010b939:	01 c0                	add    %eax,%eax
c010b93b:	01 d8                	add    %ebx,%eax
c010b93d:	83 e8 30             	sub    $0x30,%eax
c010b940:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c010b943:	8b 45 10             	mov    0x10(%ebp),%eax
c010b946:	0f b6 00             	movzbl (%eax),%eax
c010b949:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c010b94c:	83 fb 2f             	cmp    $0x2f,%ebx
c010b94f:	7e 0b                	jle    c010b95c <vprintfmt+0xb8>
c010b951:	83 fb 39             	cmp    $0x39,%ebx
c010b954:	7f 06                	jg     c010b95c <vprintfmt+0xb8>
            for (precision = 0; ; ++ fmt) {
c010b956:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                    break;
                }
            }
c010b95a:	eb d3                	jmp    c010b92f <vprintfmt+0x8b>
            goto process_precision;
c010b95c:	eb 33                	jmp    c010b991 <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
c010b95e:	8b 45 14             	mov    0x14(%ebp),%eax
c010b961:	8d 50 04             	lea    0x4(%eax),%edx
c010b964:	89 55 14             	mov    %edx,0x14(%ebp)
c010b967:	8b 00                	mov    (%eax),%eax
c010b969:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c010b96c:	eb 23                	jmp    c010b991 <vprintfmt+0xed>

        case '.':
            if (width < 0)
c010b96e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010b972:	79 0c                	jns    c010b980 <vprintfmt+0xdc>
                width = 0;
c010b974:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c010b97b:	e9 78 ff ff ff       	jmp    c010b8f8 <vprintfmt+0x54>
c010b980:	e9 73 ff ff ff       	jmp    c010b8f8 <vprintfmt+0x54>

        case '#':
            altflag = 1;
c010b985:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c010b98c:	e9 67 ff ff ff       	jmp    c010b8f8 <vprintfmt+0x54>

        process_precision:
            if (width < 0)
c010b991:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010b995:	79 12                	jns    c010b9a9 <vprintfmt+0x105>
                width = precision, precision = -1;
c010b997:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010b99a:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010b99d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c010b9a4:	e9 4f ff ff ff       	jmp    c010b8f8 <vprintfmt+0x54>
c010b9a9:	e9 4a ff ff ff       	jmp    c010b8f8 <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c010b9ae:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
c010b9b2:	e9 41 ff ff ff       	jmp    c010b8f8 <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c010b9b7:	8b 45 14             	mov    0x14(%ebp),%eax
c010b9ba:	8d 50 04             	lea    0x4(%eax),%edx
c010b9bd:	89 55 14             	mov    %edx,0x14(%ebp)
c010b9c0:	8b 00                	mov    (%eax),%eax
c010b9c2:	8b 55 0c             	mov    0xc(%ebp),%edx
c010b9c5:	89 54 24 04          	mov    %edx,0x4(%esp)
c010b9c9:	89 04 24             	mov    %eax,(%esp)
c010b9cc:	8b 45 08             	mov    0x8(%ebp),%eax
c010b9cf:	ff d0                	call   *%eax
            break;
c010b9d1:	e9 ac 02 00 00       	jmp    c010bc82 <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
c010b9d6:	8b 45 14             	mov    0x14(%ebp),%eax
c010b9d9:	8d 50 04             	lea    0x4(%eax),%edx
c010b9dc:	89 55 14             	mov    %edx,0x14(%ebp)
c010b9df:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c010b9e1:	85 db                	test   %ebx,%ebx
c010b9e3:	79 02                	jns    c010b9e7 <vprintfmt+0x143>
                err = -err;
c010b9e5:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c010b9e7:	83 fb 18             	cmp    $0x18,%ebx
c010b9ea:	7f 0b                	jg     c010b9f7 <vprintfmt+0x153>
c010b9ec:	8b 34 9d c0 e4 10 c0 	mov    -0x3fef1b40(,%ebx,4),%esi
c010b9f3:	85 f6                	test   %esi,%esi
c010b9f5:	75 23                	jne    c010ba1a <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
c010b9f7:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010b9fb:	c7 44 24 08 35 e5 10 	movl   $0xc010e535,0x8(%esp)
c010ba02:	c0 
c010ba03:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ba06:	89 44 24 04          	mov    %eax,0x4(%esp)
c010ba0a:	8b 45 08             	mov    0x8(%ebp),%eax
c010ba0d:	89 04 24             	mov    %eax,(%esp)
c010ba10:	e8 61 fe ff ff       	call   c010b876 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c010ba15:	e9 68 02 00 00       	jmp    c010bc82 <vprintfmt+0x3de>
                printfmt(putch, putdat, "%s", p);
c010ba1a:	89 74 24 0c          	mov    %esi,0xc(%esp)
c010ba1e:	c7 44 24 08 3e e5 10 	movl   $0xc010e53e,0x8(%esp)
c010ba25:	c0 
c010ba26:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ba29:	89 44 24 04          	mov    %eax,0x4(%esp)
c010ba2d:	8b 45 08             	mov    0x8(%ebp),%eax
c010ba30:	89 04 24             	mov    %eax,(%esp)
c010ba33:	e8 3e fe ff ff       	call   c010b876 <printfmt>
            break;
c010ba38:	e9 45 02 00 00       	jmp    c010bc82 <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c010ba3d:	8b 45 14             	mov    0x14(%ebp),%eax
c010ba40:	8d 50 04             	lea    0x4(%eax),%edx
c010ba43:	89 55 14             	mov    %edx,0x14(%ebp)
c010ba46:	8b 30                	mov    (%eax),%esi
c010ba48:	85 f6                	test   %esi,%esi
c010ba4a:	75 05                	jne    c010ba51 <vprintfmt+0x1ad>
                p = "(null)";
c010ba4c:	be 41 e5 10 c0       	mov    $0xc010e541,%esi
            }
            if (width > 0 && padc != '-') {
c010ba51:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010ba55:	7e 3e                	jle    c010ba95 <vprintfmt+0x1f1>
c010ba57:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c010ba5b:	74 38                	je     c010ba95 <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
c010ba5d:	8b 5d e8             	mov    -0x18(%ebp),%ebx
c010ba60:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010ba63:	89 44 24 04          	mov    %eax,0x4(%esp)
c010ba67:	89 34 24             	mov    %esi,(%esp)
c010ba6a:	e8 dc f7 ff ff       	call   c010b24b <strnlen>
c010ba6f:	29 c3                	sub    %eax,%ebx
c010ba71:	89 d8                	mov    %ebx,%eax
c010ba73:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010ba76:	eb 17                	jmp    c010ba8f <vprintfmt+0x1eb>
                    putch(padc, putdat);
c010ba78:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c010ba7c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010ba7f:	89 54 24 04          	mov    %edx,0x4(%esp)
c010ba83:	89 04 24             	mov    %eax,(%esp)
c010ba86:	8b 45 08             	mov    0x8(%ebp),%eax
c010ba89:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
c010ba8b:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010ba8f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010ba93:	7f e3                	jg     c010ba78 <vprintfmt+0x1d4>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010ba95:	eb 38                	jmp    c010bacf <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
c010ba97:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010ba9b:	74 1f                	je     c010babc <vprintfmt+0x218>
c010ba9d:	83 fb 1f             	cmp    $0x1f,%ebx
c010baa0:	7e 05                	jle    c010baa7 <vprintfmt+0x203>
c010baa2:	83 fb 7e             	cmp    $0x7e,%ebx
c010baa5:	7e 15                	jle    c010babc <vprintfmt+0x218>
                    putch('?', putdat);
c010baa7:	8b 45 0c             	mov    0xc(%ebp),%eax
c010baaa:	89 44 24 04          	mov    %eax,0x4(%esp)
c010baae:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c010bab5:	8b 45 08             	mov    0x8(%ebp),%eax
c010bab8:	ff d0                	call   *%eax
c010baba:	eb 0f                	jmp    c010bacb <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
c010babc:	8b 45 0c             	mov    0xc(%ebp),%eax
c010babf:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bac3:	89 1c 24             	mov    %ebx,(%esp)
c010bac6:	8b 45 08             	mov    0x8(%ebp),%eax
c010bac9:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010bacb:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010bacf:	89 f0                	mov    %esi,%eax
c010bad1:	8d 70 01             	lea    0x1(%eax),%esi
c010bad4:	0f b6 00             	movzbl (%eax),%eax
c010bad7:	0f be d8             	movsbl %al,%ebx
c010bada:	85 db                	test   %ebx,%ebx
c010badc:	74 10                	je     c010baee <vprintfmt+0x24a>
c010bade:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010bae2:	78 b3                	js     c010ba97 <vprintfmt+0x1f3>
c010bae4:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
c010bae8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010baec:	79 a9                	jns    c010ba97 <vprintfmt+0x1f3>
                }
            }
            for (; width > 0; width --) {
c010baee:	eb 17                	jmp    c010bb07 <vprintfmt+0x263>
                putch(' ', putdat);
c010baf0:	8b 45 0c             	mov    0xc(%ebp),%eax
c010baf3:	89 44 24 04          	mov    %eax,0x4(%esp)
c010baf7:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010bafe:	8b 45 08             	mov    0x8(%ebp),%eax
c010bb01:	ff d0                	call   *%eax
            for (; width > 0; width --) {
c010bb03:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010bb07:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010bb0b:	7f e3                	jg     c010baf0 <vprintfmt+0x24c>
            }
            break;
c010bb0d:	e9 70 01 00 00       	jmp    c010bc82 <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c010bb12:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010bb15:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bb19:	8d 45 14             	lea    0x14(%ebp),%eax
c010bb1c:	89 04 24             	mov    %eax,(%esp)
c010bb1f:	e8 0b fd ff ff       	call   c010b82f <getint>
c010bb24:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bb27:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c010bb2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bb2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010bb30:	85 d2                	test   %edx,%edx
c010bb32:	79 26                	jns    c010bb5a <vprintfmt+0x2b6>
                putch('-', putdat);
c010bb34:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bb37:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bb3b:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c010bb42:	8b 45 08             	mov    0x8(%ebp),%eax
c010bb45:	ff d0                	call   *%eax
                num = -(long long)num;
c010bb47:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bb4a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010bb4d:	f7 d8                	neg    %eax
c010bb4f:	83 d2 00             	adc    $0x0,%edx
c010bb52:	f7 da                	neg    %edx
c010bb54:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bb57:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c010bb5a:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010bb61:	e9 a8 00 00 00       	jmp    c010bc0e <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c010bb66:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010bb69:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bb6d:	8d 45 14             	lea    0x14(%ebp),%eax
c010bb70:	89 04 24             	mov    %eax,(%esp)
c010bb73:	e8 68 fc ff ff       	call   c010b7e0 <getuint>
c010bb78:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bb7b:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c010bb7e:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010bb85:	e9 84 00 00 00       	jmp    c010bc0e <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c010bb8a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010bb8d:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bb91:	8d 45 14             	lea    0x14(%ebp),%eax
c010bb94:	89 04 24             	mov    %eax,(%esp)
c010bb97:	e8 44 fc ff ff       	call   c010b7e0 <getuint>
c010bb9c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bb9f:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c010bba2:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c010bba9:	eb 63                	jmp    c010bc0e <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
c010bbab:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bbae:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bbb2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c010bbb9:	8b 45 08             	mov    0x8(%ebp),%eax
c010bbbc:	ff d0                	call   *%eax
            putch('x', putdat);
c010bbbe:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bbc1:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bbc5:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c010bbcc:	8b 45 08             	mov    0x8(%ebp),%eax
c010bbcf:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c010bbd1:	8b 45 14             	mov    0x14(%ebp),%eax
c010bbd4:	8d 50 04             	lea    0x4(%eax),%edx
c010bbd7:	89 55 14             	mov    %edx,0x14(%ebp)
c010bbda:	8b 00                	mov    (%eax),%eax
c010bbdc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bbdf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c010bbe6:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c010bbed:	eb 1f                	jmp    c010bc0e <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c010bbef:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010bbf2:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bbf6:	8d 45 14             	lea    0x14(%ebp),%eax
c010bbf9:	89 04 24             	mov    %eax,(%esp)
c010bbfc:	e8 df fb ff ff       	call   c010b7e0 <getuint>
c010bc01:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bc04:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c010bc07:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c010bc0e:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c010bc12:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010bc15:	89 54 24 18          	mov    %edx,0x18(%esp)
c010bc19:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010bc1c:	89 54 24 14          	mov    %edx,0x14(%esp)
c010bc20:	89 44 24 10          	mov    %eax,0x10(%esp)
c010bc24:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bc27:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010bc2a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010bc2e:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010bc32:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bc35:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bc39:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc3c:	89 04 24             	mov    %eax,(%esp)
c010bc3f:	e8 97 fa ff ff       	call   c010b6db <printnum>
            break;
c010bc44:	eb 3c                	jmp    c010bc82 <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c010bc46:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bc49:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bc4d:	89 1c 24             	mov    %ebx,(%esp)
c010bc50:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc53:	ff d0                	call   *%eax
            break;
c010bc55:	eb 2b                	jmp    c010bc82 <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c010bc57:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bc5a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bc5e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c010bc65:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc68:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c010bc6a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010bc6e:	eb 04                	jmp    c010bc74 <vprintfmt+0x3d0>
c010bc70:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010bc74:	8b 45 10             	mov    0x10(%ebp),%eax
c010bc77:	83 e8 01             	sub    $0x1,%eax
c010bc7a:	0f b6 00             	movzbl (%eax),%eax
c010bc7d:	3c 25                	cmp    $0x25,%al
c010bc7f:	75 ef                	jne    c010bc70 <vprintfmt+0x3cc>
                /* do nothing */;
            break;
c010bc81:	90                   	nop
        }
    }
c010bc82:	90                   	nop
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010bc83:	e9 3e fc ff ff       	jmp    c010b8c6 <vprintfmt+0x22>
}
c010bc88:	83 c4 40             	add    $0x40,%esp
c010bc8b:	5b                   	pop    %ebx
c010bc8c:	5e                   	pop    %esi
c010bc8d:	5d                   	pop    %ebp
c010bc8e:	c3                   	ret    

c010bc8f <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c010bc8f:	55                   	push   %ebp
c010bc90:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c010bc92:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bc95:	8b 40 08             	mov    0x8(%eax),%eax
c010bc98:	8d 50 01             	lea    0x1(%eax),%edx
c010bc9b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bc9e:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c010bca1:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bca4:	8b 10                	mov    (%eax),%edx
c010bca6:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bca9:	8b 40 04             	mov    0x4(%eax),%eax
c010bcac:	39 c2                	cmp    %eax,%edx
c010bcae:	73 12                	jae    c010bcc2 <sprintputch+0x33>
        *b->buf ++ = ch;
c010bcb0:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bcb3:	8b 00                	mov    (%eax),%eax
c010bcb5:	8d 48 01             	lea    0x1(%eax),%ecx
c010bcb8:	8b 55 0c             	mov    0xc(%ebp),%edx
c010bcbb:	89 0a                	mov    %ecx,(%edx)
c010bcbd:	8b 55 08             	mov    0x8(%ebp),%edx
c010bcc0:	88 10                	mov    %dl,(%eax)
    }
}
c010bcc2:	5d                   	pop    %ebp
c010bcc3:	c3                   	ret    

c010bcc4 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c010bcc4:	55                   	push   %ebp
c010bcc5:	89 e5                	mov    %esp,%ebp
c010bcc7:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010bcca:	8d 45 14             	lea    0x14(%ebp),%eax
c010bccd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c010bcd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bcd3:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010bcd7:	8b 45 10             	mov    0x10(%ebp),%eax
c010bcda:	89 44 24 08          	mov    %eax,0x8(%esp)
c010bcde:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bce1:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bce5:	8b 45 08             	mov    0x8(%ebp),%eax
c010bce8:	89 04 24             	mov    %eax,(%esp)
c010bceb:	e8 08 00 00 00       	call   c010bcf8 <vsnprintf>
c010bcf0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c010bcf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010bcf6:	c9                   	leave  
c010bcf7:	c3                   	ret    

c010bcf8 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c010bcf8:	55                   	push   %ebp
c010bcf9:	89 e5                	mov    %esp,%ebp
c010bcfb:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c010bcfe:	8b 45 08             	mov    0x8(%ebp),%eax
c010bd01:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010bd04:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bd07:	8d 50 ff             	lea    -0x1(%eax),%edx
c010bd0a:	8b 45 08             	mov    0x8(%ebp),%eax
c010bd0d:	01 d0                	add    %edx,%eax
c010bd0f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bd12:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c010bd19:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010bd1d:	74 0a                	je     c010bd29 <vsnprintf+0x31>
c010bd1f:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010bd22:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bd25:	39 c2                	cmp    %eax,%edx
c010bd27:	76 07                	jbe    c010bd30 <vsnprintf+0x38>
        return -E_INVAL;
c010bd29:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010bd2e:	eb 2a                	jmp    c010bd5a <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c010bd30:	8b 45 14             	mov    0x14(%ebp),%eax
c010bd33:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010bd37:	8b 45 10             	mov    0x10(%ebp),%eax
c010bd3a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010bd3e:	8d 45 ec             	lea    -0x14(%ebp),%eax
c010bd41:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bd45:	c7 04 24 8f bc 10 c0 	movl   $0xc010bc8f,(%esp)
c010bd4c:	e8 53 fb ff ff       	call   c010b8a4 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c010bd51:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010bd54:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c010bd57:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010bd5a:	c9                   	leave  
c010bd5b:	c3                   	ret    

c010bd5c <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
c010bd5c:	55                   	push   %ebp
c010bd5d:	89 e5                	mov    %esp,%ebp
c010bd5f:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
c010bd62:	8b 45 08             	mov    0x8(%ebp),%eax
c010bd65:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
c010bd6b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
c010bd6e:	b8 20 00 00 00       	mov    $0x20,%eax
c010bd73:	2b 45 0c             	sub    0xc(%ebp),%eax
c010bd76:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010bd79:	89 c1                	mov    %eax,%ecx
c010bd7b:	d3 ea                	shr    %cl,%edx
c010bd7d:	89 d0                	mov    %edx,%eax
}
c010bd7f:	c9                   	leave  
c010bd80:	c3                   	ret    

c010bd81 <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c010bd81:	55                   	push   %ebp
c010bd82:	89 e5                	mov    %esp,%ebp
c010bd84:	57                   	push   %edi
c010bd85:	56                   	push   %esi
c010bd86:	53                   	push   %ebx
c010bd87:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c010bd8a:	a1 00 ab 12 c0       	mov    0xc012ab00,%eax
c010bd8f:	8b 15 04 ab 12 c0    	mov    0xc012ab04,%edx
c010bd95:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c010bd9b:	6b f0 05             	imul   $0x5,%eax,%esi
c010bd9e:	01 f7                	add    %esi,%edi
c010bda0:	be 6d e6 ec de       	mov    $0xdeece66d,%esi
c010bda5:	f7 e6                	mul    %esi
c010bda7:	8d 34 17             	lea    (%edi,%edx,1),%esi
c010bdaa:	89 f2                	mov    %esi,%edx
c010bdac:	83 c0 0b             	add    $0xb,%eax
c010bdaf:	83 d2 00             	adc    $0x0,%edx
c010bdb2:	89 c7                	mov    %eax,%edi
c010bdb4:	83 e7 ff             	and    $0xffffffff,%edi
c010bdb7:	89 f9                	mov    %edi,%ecx
c010bdb9:	0f b7 da             	movzwl %dx,%ebx
c010bdbc:	89 0d 00 ab 12 c0    	mov    %ecx,0xc012ab00
c010bdc2:	89 1d 04 ab 12 c0    	mov    %ebx,0xc012ab04
    unsigned long long result = (next >> 12);
c010bdc8:	a1 00 ab 12 c0       	mov    0xc012ab00,%eax
c010bdcd:	8b 15 04 ab 12 c0    	mov    0xc012ab04,%edx
c010bdd3:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c010bdd7:	c1 ea 0c             	shr    $0xc,%edx
c010bdda:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010bddd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c010bde0:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c010bde7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010bdea:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010bded:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010bdf0:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010bdf3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010bdf6:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010bdf9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010bdfd:	74 1c                	je     c010be1b <rand+0x9a>
c010bdff:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010be02:	ba 00 00 00 00       	mov    $0x0,%edx
c010be07:	f7 75 dc             	divl   -0x24(%ebp)
c010be0a:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010be0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010be10:	ba 00 00 00 00       	mov    $0x0,%edx
c010be15:	f7 75 dc             	divl   -0x24(%ebp)
c010be18:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010be1b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010be1e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010be21:	f7 75 dc             	divl   -0x24(%ebp)
c010be24:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010be27:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010be2a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010be2d:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010be30:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010be33:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010be36:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c010be39:	83 c4 24             	add    $0x24,%esp
c010be3c:	5b                   	pop    %ebx
c010be3d:	5e                   	pop    %esi
c010be3e:	5f                   	pop    %edi
c010be3f:	5d                   	pop    %ebp
c010be40:	c3                   	ret    

c010be41 <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c010be41:	55                   	push   %ebp
c010be42:	89 e5                	mov    %esp,%ebp
    next = seed;
c010be44:	8b 45 08             	mov    0x8(%ebp),%eax
c010be47:	ba 00 00 00 00       	mov    $0x0,%edx
c010be4c:	a3 00 ab 12 c0       	mov    %eax,0xc012ab00
c010be51:	89 15 04 ab 12 c0    	mov    %edx,0xc012ab04
}
c010be57:	5d                   	pop    %ebp
c010be58:	c3                   	ret    
