
obj/__user_testbss.out:     file format elf32-i386


Disassembly of section .text:

00800020 <__panic>:
#include <stdio.h>
#include <ulib.h>
#include <error.h>

void
__panic(const char *file, int line, const char *fmt, ...) {
  800020:	55                   	push   %ebp
  800021:	89 e5                	mov    %esp,%ebp
  800023:	83 ec 28             	sub    $0x28,%esp
    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  800026:	8d 45 14             	lea    0x14(%ebp),%eax
  800029:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  80002c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80002f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800033:	8b 45 08             	mov    0x8(%ebp),%eax
  800036:	89 44 24 04          	mov    %eax,0x4(%esp)
  80003a:	c7 04 24 00 11 80 00 	movl   $0x801100,(%esp)
  800041:	e8 d6 02 00 00       	call   80031c <cprintf>
    vcprintf(fmt, ap);
  800046:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800049:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004d:	8b 45 10             	mov    0x10(%ebp),%eax
  800050:	89 04 24             	mov    %eax,(%esp)
  800053:	e8 91 02 00 00       	call   8002e9 <vcprintf>
    cprintf("\n");
  800058:	c7 04 24 1a 11 80 00 	movl   $0x80111a,(%esp)
  80005f:	e8 b8 02 00 00       	call   80031c <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800064:	c7 04 24 f6 ff ff ff 	movl   $0xfffffff6,(%esp)
  80006b:	e8 8e 01 00 00       	call   8001fe <exit>

00800070 <__warn>:
}

void
__warn(const char *file, int line, const char *fmt, ...) {
  800070:	55                   	push   %ebp
  800071:	89 e5                	mov    %esp,%ebp
  800073:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  800076:	8d 45 14             	lea    0x14(%ebp),%eax
  800079:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("user warning at %s:%d:\n    ", file, line);
  80007c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80007f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800083:	8b 45 08             	mov    0x8(%ebp),%eax
  800086:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008a:	c7 04 24 1c 11 80 00 	movl   $0x80111c,(%esp)
  800091:	e8 86 02 00 00       	call   80031c <cprintf>
    vcprintf(fmt, ap);
  800096:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800099:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009d:	8b 45 10             	mov    0x10(%ebp),%eax
  8000a0:	89 04 24             	mov    %eax,(%esp)
  8000a3:	e8 41 02 00 00       	call   8002e9 <vcprintf>
    cprintf("\n");
  8000a8:	c7 04 24 1a 11 80 00 	movl   $0x80111a,(%esp)
  8000af:	e8 68 02 00 00       	call   80031c <cprintf>
    va_end(ap);
}
  8000b4:	c9                   	leave  
  8000b5:	c3                   	ret    

008000b6 <syscall>:
#include <syscall.h>

#define MAX_ARGS            5

static inline int
syscall(int num, ...) {
  8000b6:	55                   	push   %ebp
  8000b7:	89 e5                	mov    %esp,%ebp
  8000b9:	57                   	push   %edi
  8000ba:	56                   	push   %esi
  8000bb:	53                   	push   %ebx
  8000bc:	83 ec 20             	sub    $0x20,%esp
    va_list ap;
    va_start(ap, num);
  8000bf:	8d 45 0c             	lea    0xc(%ebp),%eax
  8000c2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    uint32_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
  8000c5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8000cc:	eb 16                	jmp    8000e4 <syscall+0x2e>
        a[i] = va_arg(ap, uint32_t);
  8000ce:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8000d1:	8d 50 04             	lea    0x4(%eax),%edx
  8000d4:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8000d7:	8b 10                	mov    (%eax),%edx
  8000d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8000dc:	89 54 85 d4          	mov    %edx,-0x2c(%ebp,%eax,4)
    for (i = 0; i < MAX_ARGS; i ++) {
  8000e0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  8000e4:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
  8000e8:	7e e4                	jle    8000ce <syscall+0x18>
    asm volatile (
        "int %1;"
        : "=a" (ret)
        : "i" (T_SYSCALL),
          "a" (num),
          "d" (a[0]),
  8000ea:	8b 55 d4             	mov    -0x2c(%ebp),%edx
          "c" (a[1]),
  8000ed:	8b 4d d8             	mov    -0x28(%ebp),%ecx
          "b" (a[2]),
  8000f0:	8b 5d dc             	mov    -0x24(%ebp),%ebx
          "D" (a[3]),
  8000f3:	8b 7d e0             	mov    -0x20(%ebp),%edi
          "S" (a[4])
  8000f6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
    asm volatile (
  8000f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8000fc:	cd 80                	int    $0x80
  8000fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "cc", "memory");
    return ret;
  800101:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
  800104:	83 c4 20             	add    $0x20,%esp
  800107:	5b                   	pop    %ebx
  800108:	5e                   	pop    %esi
  800109:	5f                   	pop    %edi
  80010a:	5d                   	pop    %ebp
  80010b:	c3                   	ret    

0080010c <sys_exit>:

int
sys_exit(int error_code) {
  80010c:	55                   	push   %ebp
  80010d:	89 e5                	mov    %esp,%ebp
  80010f:	83 ec 08             	sub    $0x8,%esp
    return syscall(SYS_exit, error_code);
  800112:	8b 45 08             	mov    0x8(%ebp),%eax
  800115:	89 44 24 04          	mov    %eax,0x4(%esp)
  800119:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800120:	e8 91 ff ff ff       	call   8000b6 <syscall>
}
  800125:	c9                   	leave  
  800126:	c3                   	ret    

00800127 <sys_fork>:

int
sys_fork(void) {
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_fork);
  80012d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800134:	e8 7d ff ff ff       	call   8000b6 <syscall>
}
  800139:	c9                   	leave  
  80013a:	c3                   	ret    

0080013b <sys_wait>:

int
sys_wait(int pid, int *store) {
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	83 ec 0c             	sub    $0xc,%esp
    return syscall(SYS_wait, pid, store);
  800141:	8b 45 0c             	mov    0xc(%ebp),%eax
  800144:	89 44 24 08          	mov    %eax,0x8(%esp)
  800148:	8b 45 08             	mov    0x8(%ebp),%eax
  80014b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014f:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800156:	e8 5b ff ff ff       	call   8000b6 <syscall>
}
  80015b:	c9                   	leave  
  80015c:	c3                   	ret    

0080015d <sys_yield>:

int
sys_yield(void) {
  80015d:	55                   	push   %ebp
  80015e:	89 e5                	mov    %esp,%ebp
  800160:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_yield);
  800163:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  80016a:	e8 47 ff ff ff       	call   8000b6 <syscall>
}
  80016f:	c9                   	leave  
  800170:	c3                   	ret    

00800171 <sys_kill>:

int
sys_kill(int pid) {
  800171:	55                   	push   %ebp
  800172:	89 e5                	mov    %esp,%ebp
  800174:	83 ec 08             	sub    $0x8,%esp
    return syscall(SYS_kill, pid);
  800177:	8b 45 08             	mov    0x8(%ebp),%eax
  80017a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017e:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  800185:	e8 2c ff ff ff       	call   8000b6 <syscall>
}
  80018a:	c9                   	leave  
  80018b:	c3                   	ret    

0080018c <sys_getpid>:

int
sys_getpid(void) {
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_getpid);
  800192:	c7 04 24 12 00 00 00 	movl   $0x12,(%esp)
  800199:	e8 18 ff ff ff       	call   8000b6 <syscall>
}
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <sys_putc>:

int
sys_putc(int c) {
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	83 ec 08             	sub    $0x8,%esp
    return syscall(SYS_putc, c);
  8001a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ad:	c7 04 24 1e 00 00 00 	movl   $0x1e,(%esp)
  8001b4:	e8 fd fe ff ff       	call   8000b6 <syscall>
}
  8001b9:	c9                   	leave  
  8001ba:	c3                   	ret    

008001bb <sys_pgdir>:

int
sys_pgdir(void) {
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_pgdir);
  8001c1:	c7 04 24 1f 00 00 00 	movl   $0x1f,(%esp)
  8001c8:	e8 e9 fe ff ff       	call   8000b6 <syscall>
}
  8001cd:	c9                   	leave  
  8001ce:	c3                   	ret    

008001cf <sys_gettime>:

int
sys_gettime(void) {
  8001cf:	55                   	push   %ebp
  8001d0:	89 e5                	mov    %esp,%ebp
  8001d2:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_gettime);
  8001d5:	c7 04 24 11 00 00 00 	movl   $0x11,(%esp)
  8001dc:	e8 d5 fe ff ff       	call   8000b6 <syscall>
}
  8001e1:	c9                   	leave  
  8001e2:	c3                   	ret    

008001e3 <sys_lab6_set_priority>:

void
sys_lab6_set_priority(uint32_t priority)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	83 ec 08             	sub    $0x8,%esp
    syscall(SYS_lab6_set_priority, priority);
  8001e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f0:	c7 04 24 ff 00 00 00 	movl   $0xff,(%esp)
  8001f7:	e8 ba fe ff ff       	call   8000b6 <syscall>
}
  8001fc:	c9                   	leave  
  8001fd:	c3                   	ret    

008001fe <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	83 ec 18             	sub    $0x18,%esp
    sys_exit(error_code);
  800204:	8b 45 08             	mov    0x8(%ebp),%eax
  800207:	89 04 24             	mov    %eax,(%esp)
  80020a:	e8 fd fe ff ff       	call   80010c <sys_exit>
    cprintf("BUG: exit failed.\n");
  80020f:	c7 04 24 38 11 80 00 	movl   $0x801138,(%esp)
  800216:	e8 01 01 00 00       	call   80031c <cprintf>
    while (1);
  80021b:	eb fe                	jmp    80021b <exit+0x1d>

0080021d <fork>:
}

int
fork(void) {
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
  800220:	83 ec 08             	sub    $0x8,%esp
    return sys_fork();
  800223:	e8 ff fe ff ff       	call   800127 <sys_fork>
}
  800228:	c9                   	leave  
  800229:	c3                   	ret    

0080022a <wait>:

int
wait(void) {
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	83 ec 18             	sub    $0x18,%esp
    return sys_wait(0, NULL);
  800230:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800237:	00 
  800238:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80023f:	e8 f7 fe ff ff       	call   80013b <sys_wait>
}
  800244:	c9                   	leave  
  800245:	c3                   	ret    

00800246 <waitpid>:

int
waitpid(int pid, int *store) {
  800246:	55                   	push   %ebp
  800247:	89 e5                	mov    %esp,%ebp
  800249:	83 ec 18             	sub    $0x18,%esp
    return sys_wait(pid, store);
  80024c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80024f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800253:	8b 45 08             	mov    0x8(%ebp),%eax
  800256:	89 04 24             	mov    %eax,(%esp)
  800259:	e8 dd fe ff ff       	call   80013b <sys_wait>
}
  80025e:	c9                   	leave  
  80025f:	c3                   	ret    

00800260 <yield>:

void
yield(void) {
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	83 ec 08             	sub    $0x8,%esp
    sys_yield();
  800266:	e8 f2 fe ff ff       	call   80015d <sys_yield>
}
  80026b:	c9                   	leave  
  80026c:	c3                   	ret    

0080026d <kill>:

int
kill(int pid) {
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	83 ec 18             	sub    $0x18,%esp
    return sys_kill(pid);
  800273:	8b 45 08             	mov    0x8(%ebp),%eax
  800276:	89 04 24             	mov    %eax,(%esp)
  800279:	e8 f3 fe ff ff       	call   800171 <sys_kill>
}
  80027e:	c9                   	leave  
  80027f:	c3                   	ret    

00800280 <getpid>:

int
getpid(void) {
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	83 ec 08             	sub    $0x8,%esp
    return sys_getpid();
  800286:	e8 01 ff ff ff       	call   80018c <sys_getpid>
}
  80028b:	c9                   	leave  
  80028c:	c3                   	ret    

0080028d <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  80028d:	55                   	push   %ebp
  80028e:	89 e5                	mov    %esp,%ebp
  800290:	83 ec 08             	sub    $0x8,%esp
    sys_pgdir();
  800293:	e8 23 ff ff ff       	call   8001bb <sys_pgdir>
}
  800298:	c9                   	leave  
  800299:	c3                   	ret    

0080029a <gettime_msec>:

unsigned int
gettime_msec(void) {
  80029a:	55                   	push   %ebp
  80029b:	89 e5                	mov    %esp,%ebp
  80029d:	83 ec 08             	sub    $0x8,%esp
    return (unsigned int)sys_gettime();
  8002a0:	e8 2a ff ff ff       	call   8001cf <sys_gettime>
}
  8002a5:	c9                   	leave  
  8002a6:	c3                   	ret    

008002a7 <lab6_set_priority>:

void
lab6_set_priority(uint32_t priority)
{
  8002a7:	55                   	push   %ebp
  8002a8:	89 e5                	mov    %esp,%ebp
  8002aa:	83 ec 18             	sub    $0x18,%esp
    sys_lab6_set_priority(priority);
  8002ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b0:	89 04 24             	mov    %eax,(%esp)
  8002b3:	e8 2b ff ff ff       	call   8001e3 <sys_lab6_set_priority>
}
  8002b8:	c9                   	leave  
  8002b9:	c3                   	ret    

008002ba <_start>:
.text
.globl _start
_start:
    # set ebp for backtrace
    movl $0x0, %ebp
  8002ba:	bd 00 00 00 00       	mov    $0x0,%ebp

    # move down the esp register
    # since it may cause page fault in backtrace
    subl $0x20, %esp
  8002bf:	83 ec 20             	sub    $0x20,%esp

    # call user-program function
    call umain
  8002c2:	e8 ca 00 00 00       	call   800391 <umain>
1:  jmp 1b
  8002c7:	eb fe                	jmp    8002c7 <_start+0xd>

008002c9 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  8002c9:	55                   	push   %ebp
  8002ca:	89 e5                	mov    %esp,%ebp
  8002cc:	83 ec 18             	sub    $0x18,%esp
    sys_putc(c);
  8002cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d2:	89 04 24             	mov    %eax,(%esp)
  8002d5:	e8 c6 fe ff ff       	call   8001a0 <sys_putc>
    (*cnt) ++;
  8002da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002dd:	8b 00                	mov    (%eax),%eax
  8002df:	8d 50 01             	lea    0x1(%eax),%edx
  8002e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e5:	89 10                	mov    %edx,(%eax)
}
  8002e7:	c9                   	leave  
  8002e8:	c3                   	ret    

008002e9 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  8002e9:	55                   	push   %ebp
  8002ea:	89 e5                	mov    %esp,%ebp
  8002ec:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  8002ef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8002f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800300:	89 44 24 08          	mov    %eax,0x8(%esp)
  800304:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800307:	89 44 24 04          	mov    %eax,0x4(%esp)
  80030b:	c7 04 24 c9 02 80 00 	movl   $0x8002c9,(%esp)
  800312:	e8 14 07 00 00       	call   800a2b <vprintfmt>
    return cnt;
  800317:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80031a:	c9                   	leave  
  80031b:	c3                   	ret    

0080031c <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  800322:	8d 45 0c             	lea    0xc(%ebp),%eax
  800325:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int cnt = vcprintf(fmt, ap);
  800328:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80032b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032f:	8b 45 08             	mov    0x8(%ebp),%eax
  800332:	89 04 24             	mov    %eax,(%esp)
  800335:	e8 af ff ff ff       	call   8002e9 <vcprintf>
  80033a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);

    return cnt;
  80033d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800340:	c9                   	leave  
  800341:	c3                   	ret    

00800342 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
  800345:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  800348:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  80034f:	eb 13                	jmp    800364 <cputs+0x22>
        cputch(c, &cnt);
  800351:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  800355:	8d 55 f0             	lea    -0x10(%ebp),%edx
  800358:	89 54 24 04          	mov    %edx,0x4(%esp)
  80035c:	89 04 24             	mov    %eax,(%esp)
  80035f:	e8 65 ff ff ff       	call   8002c9 <cputch>
    while ((c = *str ++) != '\0') {
  800364:	8b 45 08             	mov    0x8(%ebp),%eax
  800367:	8d 50 01             	lea    0x1(%eax),%edx
  80036a:	89 55 08             	mov    %edx,0x8(%ebp)
  80036d:	0f b6 00             	movzbl (%eax),%eax
  800370:	88 45 f7             	mov    %al,-0x9(%ebp)
  800373:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  800377:	75 d8                	jne    800351 <cputs+0xf>
    }
    cputch('\n', &cnt);
  800379:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80037c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800380:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800387:	e8 3d ff ff ff       	call   8002c9 <cputch>
    return cnt;
  80038c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  80038f:	c9                   	leave  
  800390:	c3                   	ret    

00800391 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800391:	55                   	push   %ebp
  800392:	89 e5                	mov    %esp,%ebp
  800394:	83 ec 28             	sub    $0x28,%esp
    int ret = main();
  800397:	e8 44 0c 00 00       	call   800fe0 <main>
  80039c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    exit(ret);
  80039f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003a2:	89 04 24             	mov    %eax,(%esp)
  8003a5:	e8 54 fe ff ff       	call   8001fe <exit>

008003aa <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  8003aa:	55                   	push   %ebp
  8003ab:	89 e5                	mov    %esp,%ebp
  8003ad:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  8003b0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  8003b7:	eb 04                	jmp    8003bd <strlen+0x13>
        cnt ++;
  8003b9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (*s ++ != '\0') {
  8003bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c0:	8d 50 01             	lea    0x1(%eax),%edx
  8003c3:	89 55 08             	mov    %edx,0x8(%ebp)
  8003c6:	0f b6 00             	movzbl (%eax),%eax
  8003c9:	84 c0                	test   %al,%al
  8003cb:	75 ec                	jne    8003b9 <strlen+0xf>
    }
    return cnt;
  8003cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8003d0:	c9                   	leave  
  8003d1:	c3                   	ret    

008003d2 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  8003d2:	55                   	push   %ebp
  8003d3:	89 e5                	mov    %esp,%ebp
  8003d5:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  8003d8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  8003df:	eb 04                	jmp    8003e5 <strnlen+0x13>
        cnt ++;
  8003e1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  8003e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8003e8:	3b 45 0c             	cmp    0xc(%ebp),%eax
  8003eb:	73 10                	jae    8003fd <strnlen+0x2b>
  8003ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f0:	8d 50 01             	lea    0x1(%eax),%edx
  8003f3:	89 55 08             	mov    %edx,0x8(%ebp)
  8003f6:	0f b6 00             	movzbl (%eax),%eax
  8003f9:	84 c0                	test   %al,%al
  8003fb:	75 e4                	jne    8003e1 <strnlen+0xf>
    }
    return cnt;
  8003fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800400:	c9                   	leave  
  800401:	c3                   	ret    

00800402 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  800402:	55                   	push   %ebp
  800403:	89 e5                	mov    %esp,%ebp
  800405:	57                   	push   %edi
  800406:	56                   	push   %esi
  800407:	83 ec 20             	sub    $0x20,%esp
  80040a:	8b 45 08             	mov    0x8(%ebp),%eax
  80040d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800410:	8b 45 0c             	mov    0xc(%ebp),%eax
  800413:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  800416:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800419:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80041c:	89 d1                	mov    %edx,%ecx
  80041e:	89 c2                	mov    %eax,%edx
  800420:	89 ce                	mov    %ecx,%esi
  800422:	89 d7                	mov    %edx,%edi
  800424:	ac                   	lods   %ds:(%esi),%al
  800425:	aa                   	stos   %al,%es:(%edi)
  800426:	84 c0                	test   %al,%al
  800428:	75 fa                	jne    800424 <strcpy+0x22>
  80042a:	89 fa                	mov    %edi,%edx
  80042c:	89 f1                	mov    %esi,%ecx
  80042e:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  800431:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800434:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  800437:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  80043a:	83 c4 20             	add    $0x20,%esp
  80043d:	5e                   	pop    %esi
  80043e:	5f                   	pop    %edi
  80043f:	5d                   	pop    %ebp
  800440:	c3                   	ret    

00800441 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  800441:	55                   	push   %ebp
  800442:	89 e5                	mov    %esp,%ebp
  800444:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  800447:	8b 45 08             	mov    0x8(%ebp),%eax
  80044a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  80044d:	eb 21                	jmp    800470 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
  80044f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800452:	0f b6 10             	movzbl (%eax),%edx
  800455:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800458:	88 10                	mov    %dl,(%eax)
  80045a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80045d:	0f b6 00             	movzbl (%eax),%eax
  800460:	84 c0                	test   %al,%al
  800462:	74 04                	je     800468 <strncpy+0x27>
            src ++;
  800464:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
  800468:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  80046c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    while (len > 0) {
  800470:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800474:	75 d9                	jne    80044f <strncpy+0xe>
    }
    return dst;
  800476:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800479:	c9                   	leave  
  80047a:	c3                   	ret    

0080047b <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  80047b:	55                   	push   %ebp
  80047c:	89 e5                	mov    %esp,%ebp
  80047e:	57                   	push   %edi
  80047f:	56                   	push   %esi
  800480:	83 ec 20             	sub    $0x20,%esp
  800483:	8b 45 08             	mov    0x8(%ebp),%eax
  800486:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800489:	8b 45 0c             	mov    0xc(%ebp),%eax
  80048c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  80048f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800492:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800495:	89 d1                	mov    %edx,%ecx
  800497:	89 c2                	mov    %eax,%edx
  800499:	89 ce                	mov    %ecx,%esi
  80049b:	89 d7                	mov    %edx,%edi
  80049d:	ac                   	lods   %ds:(%esi),%al
  80049e:	ae                   	scas   %es:(%edi),%al
  80049f:	75 08                	jne    8004a9 <strcmp+0x2e>
  8004a1:	84 c0                	test   %al,%al
  8004a3:	75 f8                	jne    80049d <strcmp+0x22>
  8004a5:	31 c0                	xor    %eax,%eax
  8004a7:	eb 04                	jmp    8004ad <strcmp+0x32>
  8004a9:	19 c0                	sbb    %eax,%eax
  8004ab:	0c 01                	or     $0x1,%al
  8004ad:	89 fa                	mov    %edi,%edx
  8004af:	89 f1                	mov    %esi,%ecx
  8004b1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8004b4:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  8004b7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  8004ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  8004bd:	83 c4 20             	add    $0x20,%esp
  8004c0:	5e                   	pop    %esi
  8004c1:	5f                   	pop    %edi
  8004c2:	5d                   	pop    %ebp
  8004c3:	c3                   	ret    

008004c4 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  8004c4:	55                   	push   %ebp
  8004c5:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  8004c7:	eb 0c                	jmp    8004d5 <strncmp+0x11>
        n --, s1 ++, s2 ++;
  8004c9:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8004cd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8004d1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  8004d5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8004d9:	74 1a                	je     8004f5 <strncmp+0x31>
  8004db:	8b 45 08             	mov    0x8(%ebp),%eax
  8004de:	0f b6 00             	movzbl (%eax),%eax
  8004e1:	84 c0                	test   %al,%al
  8004e3:	74 10                	je     8004f5 <strncmp+0x31>
  8004e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e8:	0f b6 10             	movzbl (%eax),%edx
  8004eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ee:	0f b6 00             	movzbl (%eax),%eax
  8004f1:	38 c2                	cmp    %al,%dl
  8004f3:	74 d4                	je     8004c9 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  8004f5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8004f9:	74 18                	je     800513 <strncmp+0x4f>
  8004fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fe:	0f b6 00             	movzbl (%eax),%eax
  800501:	0f b6 d0             	movzbl %al,%edx
  800504:	8b 45 0c             	mov    0xc(%ebp),%eax
  800507:	0f b6 00             	movzbl (%eax),%eax
  80050a:	0f b6 c0             	movzbl %al,%eax
  80050d:	29 c2                	sub    %eax,%edx
  80050f:	89 d0                	mov    %edx,%eax
  800511:	eb 05                	jmp    800518 <strncmp+0x54>
  800513:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800518:	5d                   	pop    %ebp
  800519:	c3                   	ret    

0080051a <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  80051a:	55                   	push   %ebp
  80051b:	89 e5                	mov    %esp,%ebp
  80051d:	83 ec 04             	sub    $0x4,%esp
  800520:	8b 45 0c             	mov    0xc(%ebp),%eax
  800523:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  800526:	eb 14                	jmp    80053c <strchr+0x22>
        if (*s == c) {
  800528:	8b 45 08             	mov    0x8(%ebp),%eax
  80052b:	0f b6 00             	movzbl (%eax),%eax
  80052e:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800531:	75 05                	jne    800538 <strchr+0x1e>
            return (char *)s;
  800533:	8b 45 08             	mov    0x8(%ebp),%eax
  800536:	eb 13                	jmp    80054b <strchr+0x31>
        }
        s ++;
  800538:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
  80053c:	8b 45 08             	mov    0x8(%ebp),%eax
  80053f:	0f b6 00             	movzbl (%eax),%eax
  800542:	84 c0                	test   %al,%al
  800544:	75 e2                	jne    800528 <strchr+0xe>
    }
    return NULL;
  800546:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80054b:	c9                   	leave  
  80054c:	c3                   	ret    

0080054d <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  80054d:	55                   	push   %ebp
  80054e:	89 e5                	mov    %esp,%ebp
  800550:	83 ec 04             	sub    $0x4,%esp
  800553:	8b 45 0c             	mov    0xc(%ebp),%eax
  800556:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  800559:	eb 11                	jmp    80056c <strfind+0x1f>
        if (*s == c) {
  80055b:	8b 45 08             	mov    0x8(%ebp),%eax
  80055e:	0f b6 00             	movzbl (%eax),%eax
  800561:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800564:	75 02                	jne    800568 <strfind+0x1b>
            break;
  800566:	eb 0e                	jmp    800576 <strfind+0x29>
        }
        s ++;
  800568:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
  80056c:	8b 45 08             	mov    0x8(%ebp),%eax
  80056f:	0f b6 00             	movzbl (%eax),%eax
  800572:	84 c0                	test   %al,%al
  800574:	75 e5                	jne    80055b <strfind+0xe>
    }
    return (char *)s;
  800576:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800579:	c9                   	leave  
  80057a:	c3                   	ret    

0080057b <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  80057b:	55                   	push   %ebp
  80057c:	89 e5                	mov    %esp,%ebp
  80057e:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  800581:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  800588:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  80058f:	eb 04                	jmp    800595 <strtol+0x1a>
        s ++;
  800591:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  800595:	8b 45 08             	mov    0x8(%ebp),%eax
  800598:	0f b6 00             	movzbl (%eax),%eax
  80059b:	3c 20                	cmp    $0x20,%al
  80059d:	74 f2                	je     800591 <strtol+0x16>
  80059f:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a2:	0f b6 00             	movzbl (%eax),%eax
  8005a5:	3c 09                	cmp    $0x9,%al
  8005a7:	74 e8                	je     800591 <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
  8005a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ac:	0f b6 00             	movzbl (%eax),%eax
  8005af:	3c 2b                	cmp    $0x2b,%al
  8005b1:	75 06                	jne    8005b9 <strtol+0x3e>
        s ++;
  8005b3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8005b7:	eb 15                	jmp    8005ce <strtol+0x53>
    }
    else if (*s == '-') {
  8005b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8005bc:	0f b6 00             	movzbl (%eax),%eax
  8005bf:	3c 2d                	cmp    $0x2d,%al
  8005c1:	75 0b                	jne    8005ce <strtol+0x53>
        s ++, neg = 1;
  8005c3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8005c7:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  8005ce:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8005d2:	74 06                	je     8005da <strtol+0x5f>
  8005d4:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  8005d8:	75 24                	jne    8005fe <strtol+0x83>
  8005da:	8b 45 08             	mov    0x8(%ebp),%eax
  8005dd:	0f b6 00             	movzbl (%eax),%eax
  8005e0:	3c 30                	cmp    $0x30,%al
  8005e2:	75 1a                	jne    8005fe <strtol+0x83>
  8005e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e7:	83 c0 01             	add    $0x1,%eax
  8005ea:	0f b6 00             	movzbl (%eax),%eax
  8005ed:	3c 78                	cmp    $0x78,%al
  8005ef:	75 0d                	jne    8005fe <strtol+0x83>
        s += 2, base = 16;
  8005f1:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  8005f5:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8005fc:	eb 2a                	jmp    800628 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
  8005fe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800602:	75 17                	jne    80061b <strtol+0xa0>
  800604:	8b 45 08             	mov    0x8(%ebp),%eax
  800607:	0f b6 00             	movzbl (%eax),%eax
  80060a:	3c 30                	cmp    $0x30,%al
  80060c:	75 0d                	jne    80061b <strtol+0xa0>
        s ++, base = 8;
  80060e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800612:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800619:	eb 0d                	jmp    800628 <strtol+0xad>
    }
    else if (base == 0) {
  80061b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80061f:	75 07                	jne    800628 <strtol+0xad>
        base = 10;
  800621:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  800628:	8b 45 08             	mov    0x8(%ebp),%eax
  80062b:	0f b6 00             	movzbl (%eax),%eax
  80062e:	3c 2f                	cmp    $0x2f,%al
  800630:	7e 1b                	jle    80064d <strtol+0xd2>
  800632:	8b 45 08             	mov    0x8(%ebp),%eax
  800635:	0f b6 00             	movzbl (%eax),%eax
  800638:	3c 39                	cmp    $0x39,%al
  80063a:	7f 11                	jg     80064d <strtol+0xd2>
            dig = *s - '0';
  80063c:	8b 45 08             	mov    0x8(%ebp),%eax
  80063f:	0f b6 00             	movzbl (%eax),%eax
  800642:	0f be c0             	movsbl %al,%eax
  800645:	83 e8 30             	sub    $0x30,%eax
  800648:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80064b:	eb 48                	jmp    800695 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
  80064d:	8b 45 08             	mov    0x8(%ebp),%eax
  800650:	0f b6 00             	movzbl (%eax),%eax
  800653:	3c 60                	cmp    $0x60,%al
  800655:	7e 1b                	jle    800672 <strtol+0xf7>
  800657:	8b 45 08             	mov    0x8(%ebp),%eax
  80065a:	0f b6 00             	movzbl (%eax),%eax
  80065d:	3c 7a                	cmp    $0x7a,%al
  80065f:	7f 11                	jg     800672 <strtol+0xf7>
            dig = *s - 'a' + 10;
  800661:	8b 45 08             	mov    0x8(%ebp),%eax
  800664:	0f b6 00             	movzbl (%eax),%eax
  800667:	0f be c0             	movsbl %al,%eax
  80066a:	83 e8 57             	sub    $0x57,%eax
  80066d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800670:	eb 23                	jmp    800695 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  800672:	8b 45 08             	mov    0x8(%ebp),%eax
  800675:	0f b6 00             	movzbl (%eax),%eax
  800678:	3c 40                	cmp    $0x40,%al
  80067a:	7e 3d                	jle    8006b9 <strtol+0x13e>
  80067c:	8b 45 08             	mov    0x8(%ebp),%eax
  80067f:	0f b6 00             	movzbl (%eax),%eax
  800682:	3c 5a                	cmp    $0x5a,%al
  800684:	7f 33                	jg     8006b9 <strtol+0x13e>
            dig = *s - 'A' + 10;
  800686:	8b 45 08             	mov    0x8(%ebp),%eax
  800689:	0f b6 00             	movzbl (%eax),%eax
  80068c:	0f be c0             	movsbl %al,%eax
  80068f:	83 e8 37             	sub    $0x37,%eax
  800692:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  800695:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800698:	3b 45 10             	cmp    0x10(%ebp),%eax
  80069b:	7c 02                	jl     80069f <strtol+0x124>
            break;
  80069d:	eb 1a                	jmp    8006b9 <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
  80069f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8006a3:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8006a6:	0f af 45 10          	imul   0x10(%ebp),%eax
  8006aa:	89 c2                	mov    %eax,%edx
  8006ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006af:	01 d0                	add    %edx,%eax
  8006b1:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
  8006b4:	e9 6f ff ff ff       	jmp    800628 <strtol+0xad>

    if (endptr) {
  8006b9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006bd:	74 08                	je     8006c7 <strtol+0x14c>
        *endptr = (char *) s;
  8006bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8006c5:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  8006c7:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  8006cb:	74 07                	je     8006d4 <strtol+0x159>
  8006cd:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8006d0:	f7 d8                	neg    %eax
  8006d2:	eb 03                	jmp    8006d7 <strtol+0x15c>
  8006d4:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8006d7:	c9                   	leave  
  8006d8:	c3                   	ret    

008006d9 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  8006d9:	55                   	push   %ebp
  8006da:	89 e5                	mov    %esp,%ebp
  8006dc:	57                   	push   %edi
  8006dd:	83 ec 24             	sub    $0x24,%esp
  8006e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006e3:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  8006e6:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8006ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8006ed:	89 55 f8             	mov    %edx,-0x8(%ebp)
  8006f0:	88 45 f7             	mov    %al,-0x9(%ebp)
  8006f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8006f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  8006f9:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8006fc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800700:	8b 55 f8             	mov    -0x8(%ebp),%edx
  800703:	89 d7                	mov    %edx,%edi
  800705:	f3 aa                	rep stos %al,%es:(%edi)
  800707:	89 fa                	mov    %edi,%edx
  800709:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  80070c:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  80070f:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  800712:	83 c4 24             	add    $0x24,%esp
  800715:	5f                   	pop    %edi
  800716:	5d                   	pop    %ebp
  800717:	c3                   	ret    

00800718 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	57                   	push   %edi
  80071c:	56                   	push   %esi
  80071d:	53                   	push   %ebx
  80071e:	83 ec 30             	sub    $0x30,%esp
  800721:	8b 45 08             	mov    0x8(%ebp),%eax
  800724:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800727:	8b 45 0c             	mov    0xc(%ebp),%eax
  80072a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80072d:	8b 45 10             	mov    0x10(%ebp),%eax
  800730:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  800733:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800736:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800739:	73 42                	jae    80077d <memmove+0x65>
  80073b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80073e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800741:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800744:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800747:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80074a:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  80074d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800750:	c1 e8 02             	shr    $0x2,%eax
  800753:	89 c1                	mov    %eax,%ecx
    asm volatile (
  800755:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800758:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80075b:	89 d7                	mov    %edx,%edi
  80075d:	89 c6                	mov    %eax,%esi
  80075f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800761:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800764:	83 e1 03             	and    $0x3,%ecx
  800767:	74 02                	je     80076b <memmove+0x53>
  800769:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  80076b:	89 f0                	mov    %esi,%eax
  80076d:	89 fa                	mov    %edi,%edx
  80076f:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800772:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800775:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
  800778:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80077b:	eb 36                	jmp    8007b3 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  80077d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800780:	8d 50 ff             	lea    -0x1(%eax),%edx
  800783:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800786:	01 c2                	add    %eax,%edx
  800788:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80078b:	8d 48 ff             	lea    -0x1(%eax),%ecx
  80078e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800791:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  800794:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800797:	89 c1                	mov    %eax,%ecx
  800799:	89 d8                	mov    %ebx,%eax
  80079b:	89 d6                	mov    %edx,%esi
  80079d:	89 c7                	mov    %eax,%edi
  80079f:	fd                   	std    
  8007a0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  8007a2:	fc                   	cld    
  8007a3:	89 f8                	mov    %edi,%eax
  8007a5:	89 f2                	mov    %esi,%edx
  8007a7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8007aa:	89 55 c8             	mov    %edx,-0x38(%ebp)
  8007ad:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  8007b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  8007b3:	83 c4 30             	add    $0x30,%esp
  8007b6:	5b                   	pop    %ebx
  8007b7:	5e                   	pop    %esi
  8007b8:	5f                   	pop    %edi
  8007b9:	5d                   	pop    %ebp
  8007ba:	c3                   	ret    

008007bb <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	57                   	push   %edi
  8007bf:	56                   	push   %esi
  8007c0:	83 ec 20             	sub    $0x20,%esp
  8007c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8007c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007cf:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  8007d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007d8:	c1 e8 02             	shr    $0x2,%eax
  8007db:	89 c1                	mov    %eax,%ecx
    asm volatile (
  8007dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e3:	89 d7                	mov    %edx,%edi
  8007e5:	89 c6                	mov    %eax,%esi
  8007e7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8007e9:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  8007ec:	83 e1 03             	and    $0x3,%ecx
  8007ef:	74 02                	je     8007f3 <memcpy+0x38>
  8007f1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  8007f3:	89 f0                	mov    %esi,%eax
  8007f5:	89 fa                	mov    %edi,%edx
  8007f7:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  8007fa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  800800:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  800803:	83 c4 20             	add    $0x20,%esp
  800806:	5e                   	pop    %esi
  800807:	5f                   	pop    %edi
  800808:	5d                   	pop    %ebp
  800809:	c3                   	ret    

0080080a <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  800810:	8b 45 08             	mov    0x8(%ebp),%eax
  800813:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  800816:	8b 45 0c             	mov    0xc(%ebp),%eax
  800819:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  80081c:	eb 30                	jmp    80084e <memcmp+0x44>
        if (*s1 != *s2) {
  80081e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800821:	0f b6 10             	movzbl (%eax),%edx
  800824:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800827:	0f b6 00             	movzbl (%eax),%eax
  80082a:	38 c2                	cmp    %al,%dl
  80082c:	74 18                	je     800846 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  80082e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800831:	0f b6 00             	movzbl (%eax),%eax
  800834:	0f b6 d0             	movzbl %al,%edx
  800837:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80083a:	0f b6 00             	movzbl (%eax),%eax
  80083d:	0f b6 c0             	movzbl %al,%eax
  800840:	29 c2                	sub    %eax,%edx
  800842:	89 d0                	mov    %edx,%eax
  800844:	eb 1a                	jmp    800860 <memcmp+0x56>
        }
        s1 ++, s2 ++;
  800846:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  80084a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
    while (n -- > 0) {
  80084e:	8b 45 10             	mov    0x10(%ebp),%eax
  800851:	8d 50 ff             	lea    -0x1(%eax),%edx
  800854:	89 55 10             	mov    %edx,0x10(%ebp)
  800857:	85 c0                	test   %eax,%eax
  800859:	75 c3                	jne    80081e <memcmp+0x14>
    }
    return 0;
  80085b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800860:	c9                   	leave  
  800861:	c3                   	ret    

00800862 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	83 ec 58             	sub    $0x58,%esp
  800868:	8b 45 10             	mov    0x10(%ebp),%eax
  80086b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80086e:	8b 45 14             	mov    0x14(%ebp),%eax
  800871:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  800874:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800877:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80087a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  80087d:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  800880:	8b 45 18             	mov    0x18(%ebp),%eax
  800883:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800886:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800889:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80088c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80088f:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800892:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800895:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800898:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80089c:	74 1c                	je     8008ba <printnum+0x58>
  80089e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8008a6:	f7 75 e4             	divl   -0x1c(%ebp)
  8008a9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8008ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008af:	ba 00 00 00 00       	mov    $0x0,%edx
  8008b4:	f7 75 e4             	divl   -0x1c(%ebp)
  8008b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8008ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008c0:	f7 75 e4             	divl   -0x1c(%ebp)
  8008c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008c6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008cc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8008cf:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8008d2:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8008d5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8008d8:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  8008db:	8b 45 18             	mov    0x18(%ebp),%eax
  8008de:	ba 00 00 00 00       	mov    $0x0,%edx
  8008e3:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  8008e6:	77 56                	ja     80093e <printnum+0xdc>
  8008e8:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  8008eb:	72 05                	jb     8008f2 <printnum+0x90>
  8008ed:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  8008f0:	77 4c                	ja     80093e <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  8008f2:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8008f5:	8d 50 ff             	lea    -0x1(%eax),%edx
  8008f8:	8b 45 20             	mov    0x20(%ebp),%eax
  8008fb:	89 44 24 18          	mov    %eax,0x18(%esp)
  8008ff:	89 54 24 14          	mov    %edx,0x14(%esp)
  800903:	8b 45 18             	mov    0x18(%ebp),%eax
  800906:	89 44 24 10          	mov    %eax,0x10(%esp)
  80090a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80090d:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800910:	89 44 24 08          	mov    %eax,0x8(%esp)
  800914:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800918:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80091f:	8b 45 08             	mov    0x8(%ebp),%eax
  800922:	89 04 24             	mov    %eax,(%esp)
  800925:	e8 38 ff ff ff       	call   800862 <printnum>
  80092a:	eb 1c                	jmp    800948 <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  80092c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800933:	8b 45 20             	mov    0x20(%ebp),%eax
  800936:	89 04 24             	mov    %eax,(%esp)
  800939:	8b 45 08             	mov    0x8(%ebp),%eax
  80093c:	ff d0                	call   *%eax
        while (-- width > 0)
  80093e:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800942:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800946:	7f e4                	jg     80092c <printnum+0xca>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800948:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80094b:	05 64 12 80 00       	add    $0x801264,%eax
  800950:	0f b6 00             	movzbl (%eax),%eax
  800953:	0f be c0             	movsbl %al,%eax
  800956:	8b 55 0c             	mov    0xc(%ebp),%edx
  800959:	89 54 24 04          	mov    %edx,0x4(%esp)
  80095d:	89 04 24             	mov    %eax,(%esp)
  800960:	8b 45 08             	mov    0x8(%ebp),%eax
  800963:	ff d0                	call   *%eax
}
  800965:	c9                   	leave  
  800966:	c3                   	ret    

00800967 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  80096a:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80096e:	7e 14                	jle    800984 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	8b 00                	mov    (%eax),%eax
  800975:	8d 48 08             	lea    0x8(%eax),%ecx
  800978:	8b 55 08             	mov    0x8(%ebp),%edx
  80097b:	89 0a                	mov    %ecx,(%edx)
  80097d:	8b 50 04             	mov    0x4(%eax),%edx
  800980:	8b 00                	mov    (%eax),%eax
  800982:	eb 30                	jmp    8009b4 <getuint+0x4d>
    }
    else if (lflag) {
  800984:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800988:	74 16                	je     8009a0 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  80098a:	8b 45 08             	mov    0x8(%ebp),%eax
  80098d:	8b 00                	mov    (%eax),%eax
  80098f:	8d 48 04             	lea    0x4(%eax),%ecx
  800992:	8b 55 08             	mov    0x8(%ebp),%edx
  800995:	89 0a                	mov    %ecx,(%edx)
  800997:	8b 00                	mov    (%eax),%eax
  800999:	ba 00 00 00 00       	mov    $0x0,%edx
  80099e:	eb 14                	jmp    8009b4 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  8009a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a3:	8b 00                	mov    (%eax),%eax
  8009a5:	8d 48 04             	lea    0x4(%eax),%ecx
  8009a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8009ab:	89 0a                	mov    %ecx,(%edx)
  8009ad:	8b 00                	mov    (%eax),%eax
  8009af:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  8009b4:	5d                   	pop    %ebp
  8009b5:	c3                   	ret    

008009b6 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  8009b9:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8009bd:	7e 14                	jle    8009d3 <getint+0x1d>
        return va_arg(*ap, long long);
  8009bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c2:	8b 00                	mov    (%eax),%eax
  8009c4:	8d 48 08             	lea    0x8(%eax),%ecx
  8009c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8009ca:	89 0a                	mov    %ecx,(%edx)
  8009cc:	8b 50 04             	mov    0x4(%eax),%edx
  8009cf:	8b 00                	mov    (%eax),%eax
  8009d1:	eb 28                	jmp    8009fb <getint+0x45>
    }
    else if (lflag) {
  8009d3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009d7:	74 12                	je     8009eb <getint+0x35>
        return va_arg(*ap, long);
  8009d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dc:	8b 00                	mov    (%eax),%eax
  8009de:	8d 48 04             	lea    0x4(%eax),%ecx
  8009e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8009e4:	89 0a                	mov    %ecx,(%edx)
  8009e6:	8b 00                	mov    (%eax),%eax
  8009e8:	99                   	cltd   
  8009e9:	eb 10                	jmp    8009fb <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  8009eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ee:	8b 00                	mov    (%eax),%eax
  8009f0:	8d 48 04             	lea    0x4(%eax),%ecx
  8009f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f6:	89 0a                	mov    %ecx,(%edx)
  8009f8:	8b 00                	mov    (%eax),%eax
  8009fa:	99                   	cltd   
    }
}
  8009fb:	5d                   	pop    %ebp
  8009fc:	c3                   	ret    

008009fd <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
  800a00:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  800a03:	8d 45 14             	lea    0x14(%ebp),%eax
  800a06:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  800a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a0c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a10:	8b 45 10             	mov    0x10(%ebp),%eax
  800a13:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a21:	89 04 24             	mov    %eax,(%esp)
  800a24:	e8 02 00 00 00       	call   800a2b <vprintfmt>
    va_end(ap);
}
  800a29:	c9                   	leave  
  800a2a:	c3                   	ret    

00800a2b <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	56                   	push   %esi
  800a2f:	53                   	push   %ebx
  800a30:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800a33:	eb 18                	jmp    800a4d <vprintfmt+0x22>
            if (ch == '\0') {
  800a35:	85 db                	test   %ebx,%ebx
  800a37:	75 05                	jne    800a3e <vprintfmt+0x13>
                return;
  800a39:	e9 d1 03 00 00       	jmp    800e0f <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
  800a3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a41:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a45:	89 1c 24             	mov    %ebx,(%esp)
  800a48:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4b:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800a4d:	8b 45 10             	mov    0x10(%ebp),%eax
  800a50:	8d 50 01             	lea    0x1(%eax),%edx
  800a53:	89 55 10             	mov    %edx,0x10(%ebp)
  800a56:	0f b6 00             	movzbl (%eax),%eax
  800a59:	0f b6 d8             	movzbl %al,%ebx
  800a5c:	83 fb 25             	cmp    $0x25,%ebx
  800a5f:	75 d4                	jne    800a35 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
  800a61:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  800a65:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800a6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a6f:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  800a72:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800a79:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a7c:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800a7f:	8b 45 10             	mov    0x10(%ebp),%eax
  800a82:	8d 50 01             	lea    0x1(%eax),%edx
  800a85:	89 55 10             	mov    %edx,0x10(%ebp)
  800a88:	0f b6 00             	movzbl (%eax),%eax
  800a8b:	0f b6 d8             	movzbl %al,%ebx
  800a8e:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800a91:	83 f8 55             	cmp    $0x55,%eax
  800a94:	0f 87 44 03 00 00    	ja     800dde <vprintfmt+0x3b3>
  800a9a:	8b 04 85 88 12 80 00 	mov    0x801288(,%eax,4),%eax
  800aa1:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  800aa3:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  800aa7:	eb d6                	jmp    800a7f <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  800aa9:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  800aad:	eb d0                	jmp    800a7f <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  800aaf:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  800ab6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800ab9:	89 d0                	mov    %edx,%eax
  800abb:	c1 e0 02             	shl    $0x2,%eax
  800abe:	01 d0                	add    %edx,%eax
  800ac0:	01 c0                	add    %eax,%eax
  800ac2:	01 d8                	add    %ebx,%eax
  800ac4:	83 e8 30             	sub    $0x30,%eax
  800ac7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  800aca:	8b 45 10             	mov    0x10(%ebp),%eax
  800acd:	0f b6 00             	movzbl (%eax),%eax
  800ad0:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  800ad3:	83 fb 2f             	cmp    $0x2f,%ebx
  800ad6:	7e 0b                	jle    800ae3 <vprintfmt+0xb8>
  800ad8:	83 fb 39             	cmp    $0x39,%ebx
  800adb:	7f 06                	jg     800ae3 <vprintfmt+0xb8>
            for (precision = 0; ; ++ fmt) {
  800add:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                    break;
                }
            }
  800ae1:	eb d3                	jmp    800ab6 <vprintfmt+0x8b>
            goto process_precision;
  800ae3:	eb 33                	jmp    800b18 <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
  800ae5:	8b 45 14             	mov    0x14(%ebp),%eax
  800ae8:	8d 50 04             	lea    0x4(%eax),%edx
  800aeb:	89 55 14             	mov    %edx,0x14(%ebp)
  800aee:	8b 00                	mov    (%eax),%eax
  800af0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  800af3:	eb 23                	jmp    800b18 <vprintfmt+0xed>

        case '.':
            if (width < 0)
  800af5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800af9:	79 0c                	jns    800b07 <vprintfmt+0xdc>
                width = 0;
  800afb:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  800b02:	e9 78 ff ff ff       	jmp    800a7f <vprintfmt+0x54>
  800b07:	e9 73 ff ff ff       	jmp    800a7f <vprintfmt+0x54>

        case '#':
            altflag = 1;
  800b0c:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  800b13:	e9 67 ff ff ff       	jmp    800a7f <vprintfmt+0x54>

        process_precision:
            if (width < 0)
  800b18:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800b1c:	79 12                	jns    800b30 <vprintfmt+0x105>
                width = precision, precision = -1;
  800b1e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800b21:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800b24:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  800b2b:	e9 4f ff ff ff       	jmp    800a7f <vprintfmt+0x54>
  800b30:	e9 4a ff ff ff       	jmp    800a7f <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  800b35:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
  800b39:	e9 41 ff ff ff       	jmp    800a7f <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  800b3e:	8b 45 14             	mov    0x14(%ebp),%eax
  800b41:	8d 50 04             	lea    0x4(%eax),%edx
  800b44:	89 55 14             	mov    %edx,0x14(%ebp)
  800b47:	8b 00                	mov    (%eax),%eax
  800b49:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b4c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b50:	89 04 24             	mov    %eax,(%esp)
  800b53:	8b 45 08             	mov    0x8(%ebp),%eax
  800b56:	ff d0                	call   *%eax
            break;
  800b58:	e9 ac 02 00 00       	jmp    800e09 <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
  800b5d:	8b 45 14             	mov    0x14(%ebp),%eax
  800b60:	8d 50 04             	lea    0x4(%eax),%edx
  800b63:	89 55 14             	mov    %edx,0x14(%ebp)
  800b66:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  800b68:	85 db                	test   %ebx,%ebx
  800b6a:	79 02                	jns    800b6e <vprintfmt+0x143>
                err = -err;
  800b6c:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800b6e:	83 fb 18             	cmp    $0x18,%ebx
  800b71:	7f 0b                	jg     800b7e <vprintfmt+0x153>
  800b73:	8b 34 9d 00 12 80 00 	mov    0x801200(,%ebx,4),%esi
  800b7a:	85 f6                	test   %esi,%esi
  800b7c:	75 23                	jne    800ba1 <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
  800b7e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800b82:	c7 44 24 08 75 12 80 	movl   $0x801275,0x8(%esp)
  800b89:	00 
  800b8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b91:	8b 45 08             	mov    0x8(%ebp),%eax
  800b94:	89 04 24             	mov    %eax,(%esp)
  800b97:	e8 61 fe ff ff       	call   8009fd <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  800b9c:	e9 68 02 00 00       	jmp    800e09 <vprintfmt+0x3de>
                printfmt(putch, putdat, "%s", p);
  800ba1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800ba5:	c7 44 24 08 7e 12 80 	movl   $0x80127e,0x8(%esp)
  800bac:	00 
  800bad:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb7:	89 04 24             	mov    %eax,(%esp)
  800bba:	e8 3e fe ff ff       	call   8009fd <printfmt>
            break;
  800bbf:	e9 45 02 00 00       	jmp    800e09 <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  800bc4:	8b 45 14             	mov    0x14(%ebp),%eax
  800bc7:	8d 50 04             	lea    0x4(%eax),%edx
  800bca:	89 55 14             	mov    %edx,0x14(%ebp)
  800bcd:	8b 30                	mov    (%eax),%esi
  800bcf:	85 f6                	test   %esi,%esi
  800bd1:	75 05                	jne    800bd8 <vprintfmt+0x1ad>
                p = "(null)";
  800bd3:	be 81 12 80 00       	mov    $0x801281,%esi
            }
            if (width > 0 && padc != '-') {
  800bd8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800bdc:	7e 3e                	jle    800c1c <vprintfmt+0x1f1>
  800bde:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800be2:	74 38                	je     800c1c <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800be4:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  800be7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800bea:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bee:	89 34 24             	mov    %esi,(%esp)
  800bf1:	e8 dc f7 ff ff       	call   8003d2 <strnlen>
  800bf6:	29 c3                	sub    %eax,%ebx
  800bf8:	89 d8                	mov    %ebx,%eax
  800bfa:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800bfd:	eb 17                	jmp    800c16 <vprintfmt+0x1eb>
                    putch(padc, putdat);
  800bff:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800c03:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c06:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c0a:	89 04 24             	mov    %eax,(%esp)
  800c0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c10:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
  800c12:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  800c16:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800c1a:	7f e3                	jg     800bff <vprintfmt+0x1d4>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800c1c:	eb 38                	jmp    800c56 <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
  800c1e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800c22:	74 1f                	je     800c43 <vprintfmt+0x218>
  800c24:	83 fb 1f             	cmp    $0x1f,%ebx
  800c27:	7e 05                	jle    800c2e <vprintfmt+0x203>
  800c29:	83 fb 7e             	cmp    $0x7e,%ebx
  800c2c:	7e 15                	jle    800c43 <vprintfmt+0x218>
                    putch('?', putdat);
  800c2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c31:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c35:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800c3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3f:	ff d0                	call   *%eax
  800c41:	eb 0f                	jmp    800c52 <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
  800c43:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c46:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c4a:	89 1c 24             	mov    %ebx,(%esp)
  800c4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c50:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800c52:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  800c56:	89 f0                	mov    %esi,%eax
  800c58:	8d 70 01             	lea    0x1(%eax),%esi
  800c5b:	0f b6 00             	movzbl (%eax),%eax
  800c5e:	0f be d8             	movsbl %al,%ebx
  800c61:	85 db                	test   %ebx,%ebx
  800c63:	74 10                	je     800c75 <vprintfmt+0x24a>
  800c65:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c69:	78 b3                	js     800c1e <vprintfmt+0x1f3>
  800c6b:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800c6f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c73:	79 a9                	jns    800c1e <vprintfmt+0x1f3>
                }
            }
            for (; width > 0; width --) {
  800c75:	eb 17                	jmp    800c8e <vprintfmt+0x263>
                putch(' ', putdat);
  800c77:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c7a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c7e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800c85:	8b 45 08             	mov    0x8(%ebp),%eax
  800c88:	ff d0                	call   *%eax
            for (; width > 0; width --) {
  800c8a:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  800c8e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800c92:	7f e3                	jg     800c77 <vprintfmt+0x24c>
            }
            break;
  800c94:	e9 70 01 00 00       	jmp    800e09 <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  800c99:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800c9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ca0:	8d 45 14             	lea    0x14(%ebp),%eax
  800ca3:	89 04 24             	mov    %eax,(%esp)
  800ca6:	e8 0b fd ff ff       	call   8009b6 <getint>
  800cab:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800cae:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  800cb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cb4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800cb7:	85 d2                	test   %edx,%edx
  800cb9:	79 26                	jns    800ce1 <vprintfmt+0x2b6>
                putch('-', putdat);
  800cbb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cbe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cc2:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800cc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccc:	ff d0                	call   *%eax
                num = -(long long)num;
  800cce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cd1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800cd4:	f7 d8                	neg    %eax
  800cd6:	83 d2 00             	adc    $0x0,%edx
  800cd9:	f7 da                	neg    %edx
  800cdb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800cde:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  800ce1:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  800ce8:	e9 a8 00 00 00       	jmp    800d95 <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  800ced:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800cf0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cf4:	8d 45 14             	lea    0x14(%ebp),%eax
  800cf7:	89 04 24             	mov    %eax,(%esp)
  800cfa:	e8 68 fc ff ff       	call   800967 <getuint>
  800cff:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800d02:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  800d05:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  800d0c:	e9 84 00 00 00       	jmp    800d95 <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  800d11:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d14:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d18:	8d 45 14             	lea    0x14(%ebp),%eax
  800d1b:	89 04 24             	mov    %eax,(%esp)
  800d1e:	e8 44 fc ff ff       	call   800967 <getuint>
  800d23:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800d26:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  800d29:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  800d30:	eb 63                	jmp    800d95 <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
  800d32:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d35:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d39:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800d40:	8b 45 08             	mov    0x8(%ebp),%eax
  800d43:	ff d0                	call   *%eax
            putch('x', putdat);
  800d45:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d48:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d4c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800d53:	8b 45 08             	mov    0x8(%ebp),%eax
  800d56:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800d58:	8b 45 14             	mov    0x14(%ebp),%eax
  800d5b:	8d 50 04             	lea    0x4(%eax),%edx
  800d5e:	89 55 14             	mov    %edx,0x14(%ebp)
  800d61:	8b 00                	mov    (%eax),%eax
  800d63:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800d66:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  800d6d:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  800d74:	eb 1f                	jmp    800d95 <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  800d76:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d79:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d7d:	8d 45 14             	lea    0x14(%ebp),%eax
  800d80:	89 04 24             	mov    %eax,(%esp)
  800d83:	e8 df fb ff ff       	call   800967 <getuint>
  800d88:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800d8b:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  800d8e:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  800d95:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800d99:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d9c:	89 54 24 18          	mov    %edx,0x18(%esp)
  800da0:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800da3:	89 54 24 14          	mov    %edx,0x14(%esp)
  800da7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dae:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800db1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800db5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800db9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dbc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dc0:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc3:	89 04 24             	mov    %eax,(%esp)
  800dc6:	e8 97 fa ff ff       	call   800862 <printnum>
            break;
  800dcb:	eb 3c                	jmp    800e09 <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  800dcd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dd0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dd4:	89 1c 24             	mov    %ebx,(%esp)
  800dd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dda:	ff d0                	call   *%eax
            break;
  800ddc:	eb 2b                	jmp    800e09 <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  800dde:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800de5:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800dec:	8b 45 08             	mov    0x8(%ebp),%eax
  800def:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  800df1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800df5:	eb 04                	jmp    800dfb <vprintfmt+0x3d0>
  800df7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800dfb:	8b 45 10             	mov    0x10(%ebp),%eax
  800dfe:	83 e8 01             	sub    $0x1,%eax
  800e01:	0f b6 00             	movzbl (%eax),%eax
  800e04:	3c 25                	cmp    $0x25,%al
  800e06:	75 ef                	jne    800df7 <vprintfmt+0x3cc>
                /* do nothing */;
            break;
  800e08:	90                   	nop
        }
    }
  800e09:	90                   	nop
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800e0a:	e9 3e fc ff ff       	jmp    800a4d <vprintfmt+0x22>
}
  800e0f:	83 c4 40             	add    $0x40,%esp
  800e12:	5b                   	pop    %ebx
  800e13:	5e                   	pop    %esi
  800e14:	5d                   	pop    %ebp
  800e15:	c3                   	ret    

00800e16 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  800e16:	55                   	push   %ebp
  800e17:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  800e19:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e1c:	8b 40 08             	mov    0x8(%eax),%eax
  800e1f:	8d 50 01             	lea    0x1(%eax),%edx
  800e22:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e25:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  800e28:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e2b:	8b 10                	mov    (%eax),%edx
  800e2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e30:	8b 40 04             	mov    0x4(%eax),%eax
  800e33:	39 c2                	cmp    %eax,%edx
  800e35:	73 12                	jae    800e49 <sprintputch+0x33>
        *b->buf ++ = ch;
  800e37:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e3a:	8b 00                	mov    (%eax),%eax
  800e3c:	8d 48 01             	lea    0x1(%eax),%ecx
  800e3f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e42:	89 0a                	mov    %ecx,(%edx)
  800e44:	8b 55 08             	mov    0x8(%ebp),%edx
  800e47:	88 10                	mov    %dl,(%eax)
    }
}
  800e49:	5d                   	pop    %ebp
  800e4a:	c3                   	ret    

00800e4b <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  800e4b:	55                   	push   %ebp
  800e4c:	89 e5                	mov    %esp,%ebp
  800e4e:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  800e51:	8d 45 14             	lea    0x14(%ebp),%eax
  800e54:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  800e57:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e5a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e5e:	8b 45 10             	mov    0x10(%ebp),%eax
  800e61:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e65:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e68:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6f:	89 04 24             	mov    %eax,(%esp)
  800e72:	e8 08 00 00 00       	call   800e7f <vsnprintf>
  800e77:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  800e7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800e7d:	c9                   	leave  
  800e7e:	c3                   	ret    

00800e7f <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  800e7f:	55                   	push   %ebp
  800e80:	89 e5                	mov    %esp,%ebp
  800e82:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  800e85:	8b 45 08             	mov    0x8(%ebp),%eax
  800e88:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e8e:	8d 50 ff             	lea    -0x1(%eax),%edx
  800e91:	8b 45 08             	mov    0x8(%ebp),%eax
  800e94:	01 d0                	add    %edx,%eax
  800e96:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800e99:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  800ea0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800ea4:	74 0a                	je     800eb0 <vsnprintf+0x31>
  800ea6:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800ea9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eac:	39 c2                	cmp    %eax,%edx
  800eae:	76 07                	jbe    800eb7 <vsnprintf+0x38>
        return -E_INVAL;
  800eb0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eb5:	eb 2a                	jmp    800ee1 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  800eb7:	8b 45 14             	mov    0x14(%ebp),%eax
  800eba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ebe:	8b 45 10             	mov    0x10(%ebp),%eax
  800ec1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ec5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ec8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ecc:	c7 04 24 16 0e 80 00 	movl   $0x800e16,(%esp)
  800ed3:	e8 53 fb ff ff       	call   800a2b <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  800ed8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800edb:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  800ede:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800ee1:	c9                   	leave  
  800ee2:	c3                   	ret    

00800ee3 <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
  800ee3:	55                   	push   %ebp
  800ee4:	89 e5                	mov    %esp,%ebp
  800ee6:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
  800ee9:	8b 45 08             	mov    0x8(%ebp),%eax
  800eec:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
  800ef2:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
  800ef5:	b8 20 00 00 00       	mov    $0x20,%eax
  800efa:	2b 45 0c             	sub    0xc(%ebp),%eax
  800efd:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800f00:	89 c1                	mov    %eax,%ecx
  800f02:	d3 ea                	shr    %cl,%edx
  800f04:	89 d0                	mov    %edx,%eax
}
  800f06:	c9                   	leave  
  800f07:	c3                   	ret    

00800f08 <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
  800f08:	55                   	push   %ebp
  800f09:	89 e5                	mov    %esp,%ebp
  800f0b:	57                   	push   %edi
  800f0c:	56                   	push   %esi
  800f0d:	53                   	push   %ebx
  800f0e:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
  800f11:	a1 00 20 80 00       	mov    0x802000,%eax
  800f16:	8b 15 04 20 80 00    	mov    0x802004,%edx
  800f1c:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
  800f22:	6b f0 05             	imul   $0x5,%eax,%esi
  800f25:	01 f7                	add    %esi,%edi
  800f27:	be 6d e6 ec de       	mov    $0xdeece66d,%esi
  800f2c:	f7 e6                	mul    %esi
  800f2e:	8d 34 17             	lea    (%edi,%edx,1),%esi
  800f31:	89 f2                	mov    %esi,%edx
  800f33:	83 c0 0b             	add    $0xb,%eax
  800f36:	83 d2 00             	adc    $0x0,%edx
  800f39:	89 c7                	mov    %eax,%edi
  800f3b:	83 e7 ff             	and    $0xffffffff,%edi
  800f3e:	89 f9                	mov    %edi,%ecx
  800f40:	0f b7 da             	movzwl %dx,%ebx
  800f43:	89 0d 00 20 80 00    	mov    %ecx,0x802000
  800f49:	89 1d 04 20 80 00    	mov    %ebx,0x802004
    unsigned long long result = (next >> 12);
  800f4f:	a1 00 20 80 00       	mov    0x802000,%eax
  800f54:	8b 15 04 20 80 00    	mov    0x802004,%edx
  800f5a:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  800f5e:	c1 ea 0c             	shr    $0xc,%edx
  800f61:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f64:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
  800f67:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
  800f6e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f71:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f74:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f77:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800f7a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f7d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800f80:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800f84:	74 1c                	je     800fa2 <rand+0x9a>
  800f86:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f89:	ba 00 00 00 00       	mov    $0x0,%edx
  800f8e:	f7 75 dc             	divl   -0x24(%ebp)
  800f91:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800f94:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f97:	ba 00 00 00 00       	mov    $0x0,%edx
  800f9c:	f7 75 dc             	divl   -0x24(%ebp)
  800f9f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800fa2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800fa5:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800fa8:	f7 75 dc             	divl   -0x24(%ebp)
  800fab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800fae:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800fb1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800fb4:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800fb7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800fba:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800fbd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
  800fc0:	83 c4 24             	add    $0x24,%esp
  800fc3:	5b                   	pop    %ebx
  800fc4:	5e                   	pop    %esi
  800fc5:	5f                   	pop    %edi
  800fc6:	5d                   	pop    %ebp
  800fc7:	c3                   	ret    

00800fc8 <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
  800fc8:	55                   	push   %ebp
  800fc9:	89 e5                	mov    %esp,%ebp
    next = seed;
  800fcb:	8b 45 08             	mov    0x8(%ebp),%eax
  800fce:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd3:	a3 00 20 80 00       	mov    %eax,0x802000
  800fd8:	89 15 04 20 80 00    	mov    %edx,0x802004
}
  800fde:	5d                   	pop    %ebp
  800fdf:	c3                   	ret    

00800fe0 <main>:
#define ARRAYSIZE (1024*1024)

uint32_t bigarray[ARRAYSIZE];

int
main(void) {
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
  800fe3:	83 e4 f0             	and    $0xfffffff0,%esp
  800fe6:	83 ec 20             	sub    $0x20,%esp
    cprintf("Making sure bss works right...\n");
  800fe9:	c7 04 24 e0 13 80 00 	movl   $0x8013e0,(%esp)
  800ff0:	e8 27 f3 ff ff       	call   80031c <cprintf>
    int i;
    for (i = 0; i < ARRAYSIZE; i ++) {
  800ff5:	c7 44 24 1c 00 00 00 	movl   $0x0,0x1c(%esp)
  800ffc:	00 
  800ffd:	eb 38                	jmp    801037 <main+0x57>
        if (bigarray[i] != 0) {
  800fff:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801003:	8b 04 85 20 20 80 00 	mov    0x802020(,%eax,4),%eax
  80100a:	85 c0                	test   %eax,%eax
  80100c:	74 24                	je     801032 <main+0x52>
            panic("bigarray[%d] isn't cleared!\n", i);
  80100e:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801012:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801016:	c7 44 24 08 00 14 80 	movl   $0x801400,0x8(%esp)
  80101d:	00 
  80101e:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  801025:	00 
  801026:	c7 04 24 1d 14 80 00 	movl   $0x80141d,(%esp)
  80102d:	e8 ee ef ff ff       	call   800020 <__panic>
    for (i = 0; i < ARRAYSIZE; i ++) {
  801032:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
  801037:	81 7c 24 1c ff ff 0f 	cmpl   $0xfffff,0x1c(%esp)
  80103e:	00 
  80103f:	7e be                	jle    800fff <main+0x1f>
        }
    }
    for (i = 0; i < ARRAYSIZE; i ++) {
  801041:	c7 44 24 1c 00 00 00 	movl   $0x0,0x1c(%esp)
  801048:	00 
  801049:	eb 14                	jmp    80105f <main+0x7f>
        bigarray[i] = i;
  80104b:	8b 54 24 1c          	mov    0x1c(%esp),%edx
  80104f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801053:	89 14 85 20 20 80 00 	mov    %edx,0x802020(,%eax,4)
    for (i = 0; i < ARRAYSIZE; i ++) {
  80105a:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
  80105f:	81 7c 24 1c ff ff 0f 	cmpl   $0xfffff,0x1c(%esp)
  801066:	00 
  801067:	7e e2                	jle    80104b <main+0x6b>
    }
    for (i = 0; i < ARRAYSIZE; i ++) {
  801069:	c7 44 24 1c 00 00 00 	movl   $0x0,0x1c(%esp)
  801070:	00 
  801071:	eb 3c                	jmp    8010af <main+0xcf>
        if (bigarray[i] != i) {
  801073:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801077:	8b 14 85 20 20 80 00 	mov    0x802020(,%eax,4),%edx
  80107e:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801082:	39 c2                	cmp    %eax,%edx
  801084:	74 24                	je     8010aa <main+0xca>
            panic("bigarray[%d] didn't hold its value!\n", i);
  801086:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80108a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80108e:	c7 44 24 08 2c 14 80 	movl   $0x80142c,0x8(%esp)
  801095:	00 
  801096:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  80109d:	00 
  80109e:	c7 04 24 1d 14 80 00 	movl   $0x80141d,(%esp)
  8010a5:	e8 76 ef ff ff       	call   800020 <__panic>
    for (i = 0; i < ARRAYSIZE; i ++) {
  8010aa:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
  8010af:	81 7c 24 1c ff ff 0f 	cmpl   $0xfffff,0x1c(%esp)
  8010b6:	00 
  8010b7:	7e ba                	jle    801073 <main+0x93>
        }
    }

    cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8010b9:	c7 04 24 54 14 80 00 	movl   $0x801454,(%esp)
  8010c0:	e8 57 f2 ff ff       	call   80031c <cprintf>
    cprintf("testbss may pass.\n");
  8010c5:	c7 04 24 87 14 80 00 	movl   $0x801487,(%esp)
  8010cc:	e8 4b f2 ff ff       	call   80031c <cprintf>

    bigarray[ARRAYSIZE + 1024] = 0;
  8010d1:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  8010d8:	00 00 00 
    asm volatile ("int $0x14");
  8010db:	cd 14                	int    $0x14
    panic("FAIL: T.T\n");
  8010dd:	c7 44 24 08 9a 14 80 	movl   $0x80149a,0x8(%esp)
  8010e4:	00 
  8010e5:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  8010ec:	00 
  8010ed:	c7 04 24 1d 14 80 00 	movl   $0x80141d,(%esp)
  8010f4:	e8 27 ef ff ff       	call   800020 <__panic>
