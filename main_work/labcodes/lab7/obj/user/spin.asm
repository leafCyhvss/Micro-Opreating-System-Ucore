
obj/__user_spin.out:     file format elf32-i386


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
  80003a:	c7 04 24 60 11 80 00 	movl   $0x801160,(%esp)
  800041:	e8 04 03 00 00       	call   80034a <cprintf>
    vcprintf(fmt, ap);
  800046:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800049:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004d:	8b 45 10             	mov    0x10(%ebp),%eax
  800050:	89 04 24             	mov    %eax,(%esp)
  800053:	e8 bf 02 00 00       	call   800317 <vcprintf>
    cprintf("\n");
  800058:	c7 04 24 7a 11 80 00 	movl   $0x80117a,(%esp)
  80005f:	e8 e6 02 00 00       	call   80034a <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800064:	c7 04 24 f6 ff ff ff 	movl   $0xfffffff6,(%esp)
  80006b:	e8 a9 01 00 00       	call   800219 <exit>

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
  80008a:	c7 04 24 7c 11 80 00 	movl   $0x80117c,(%esp)
  800091:	e8 b4 02 00 00       	call   80034a <cprintf>
    vcprintf(fmt, ap);
  800096:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800099:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009d:	8b 45 10             	mov    0x10(%ebp),%eax
  8000a0:	89 04 24             	mov    %eax,(%esp)
  8000a3:	e8 6f 02 00 00       	call   800317 <vcprintf>
    cprintf("\n");
  8000a8:	c7 04 24 7a 11 80 00 	movl   $0x80117a,(%esp)
  8000af:	e8 96 02 00 00       	call   80034a <cprintf>
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

008001fe <sys_sleep>:

int
sys_sleep(unsigned int time) {
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	83 ec 08             	sub    $0x8,%esp
    return syscall(SYS_sleep, time);
  800204:	8b 45 08             	mov    0x8(%ebp),%eax
  800207:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020b:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  800212:	e8 9f fe ff ff       	call   8000b6 <syscall>
}
  800217:	c9                   	leave  
  800218:	c3                   	ret    

00800219 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	83 ec 18             	sub    $0x18,%esp
    sys_exit(error_code);
  80021f:	8b 45 08             	mov    0x8(%ebp),%eax
  800222:	89 04 24             	mov    %eax,(%esp)
  800225:	e8 e2 fe ff ff       	call   80010c <sys_exit>
    cprintf("BUG: exit failed.\n");
  80022a:	c7 04 24 98 11 80 00 	movl   $0x801198,(%esp)
  800231:	e8 14 01 00 00       	call   80034a <cprintf>
    while (1);
  800236:	eb fe                	jmp    800236 <exit+0x1d>

00800238 <fork>:
}

int
fork(void) {
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	83 ec 08             	sub    $0x8,%esp
    return sys_fork();
  80023e:	e8 e4 fe ff ff       	call   800127 <sys_fork>
}
  800243:	c9                   	leave  
  800244:	c3                   	ret    

00800245 <wait>:

int
wait(void) {
  800245:	55                   	push   %ebp
  800246:	89 e5                	mov    %esp,%ebp
  800248:	83 ec 18             	sub    $0x18,%esp
    return sys_wait(0, NULL);
  80024b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800252:	00 
  800253:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80025a:	e8 dc fe ff ff       	call   80013b <sys_wait>
}
  80025f:	c9                   	leave  
  800260:	c3                   	ret    

00800261 <waitpid>:

int
waitpid(int pid, int *store) {
  800261:	55                   	push   %ebp
  800262:	89 e5                	mov    %esp,%ebp
  800264:	83 ec 18             	sub    $0x18,%esp
    return sys_wait(pid, store);
  800267:	8b 45 0c             	mov    0xc(%ebp),%eax
  80026a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80026e:	8b 45 08             	mov    0x8(%ebp),%eax
  800271:	89 04 24             	mov    %eax,(%esp)
  800274:	e8 c2 fe ff ff       	call   80013b <sys_wait>
}
  800279:	c9                   	leave  
  80027a:	c3                   	ret    

0080027b <yield>:

void
yield(void) {
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
  80027e:	83 ec 08             	sub    $0x8,%esp
    sys_yield();
  800281:	e8 d7 fe ff ff       	call   80015d <sys_yield>
}
  800286:	c9                   	leave  
  800287:	c3                   	ret    

00800288 <kill>:

int
kill(int pid) {
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	83 ec 18             	sub    $0x18,%esp
    return sys_kill(pid);
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	89 04 24             	mov    %eax,(%esp)
  800294:	e8 d8 fe ff ff       	call   800171 <sys_kill>
}
  800299:	c9                   	leave  
  80029a:	c3                   	ret    

0080029b <getpid>:

int
getpid(void) {
  80029b:	55                   	push   %ebp
  80029c:	89 e5                	mov    %esp,%ebp
  80029e:	83 ec 08             	sub    $0x8,%esp
    return sys_getpid();
  8002a1:	e8 e6 fe ff ff       	call   80018c <sys_getpid>
}
  8002a6:	c9                   	leave  
  8002a7:	c3                   	ret    

008002a8 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  8002a8:	55                   	push   %ebp
  8002a9:	89 e5                	mov    %esp,%ebp
  8002ab:	83 ec 08             	sub    $0x8,%esp
    sys_pgdir();
  8002ae:	e8 08 ff ff ff       	call   8001bb <sys_pgdir>
}
  8002b3:	c9                   	leave  
  8002b4:	c3                   	ret    

008002b5 <gettime_msec>:

unsigned int
gettime_msec(void) {
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	83 ec 08             	sub    $0x8,%esp
    return (unsigned int)sys_gettime();
  8002bb:	e8 0f ff ff ff       	call   8001cf <sys_gettime>
}
  8002c0:	c9                   	leave  
  8002c1:	c3                   	ret    

008002c2 <lab6_set_priority>:

void
lab6_set_priority(uint32_t priority)
{
  8002c2:	55                   	push   %ebp
  8002c3:	89 e5                	mov    %esp,%ebp
  8002c5:	83 ec 18             	sub    $0x18,%esp
    sys_lab6_set_priority(priority);
  8002c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cb:	89 04 24             	mov    %eax,(%esp)
  8002ce:	e8 10 ff ff ff       	call   8001e3 <sys_lab6_set_priority>
}
  8002d3:	c9                   	leave  
  8002d4:	c3                   	ret    

008002d5 <sleep>:

int
sleep(unsigned int time) {
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
  8002d8:	83 ec 18             	sub    $0x18,%esp
    return sys_sleep(time);
  8002db:	8b 45 08             	mov    0x8(%ebp),%eax
  8002de:	89 04 24             	mov    %eax,(%esp)
  8002e1:	e8 18 ff ff ff       	call   8001fe <sys_sleep>
}
  8002e6:	c9                   	leave  
  8002e7:	c3                   	ret    

008002e8 <_start>:
.text
.globl _start
_start:
    # set ebp for backtrace
    movl $0x0, %ebp
  8002e8:	bd 00 00 00 00       	mov    $0x0,%ebp

    # move down the esp register
    # since it may cause page fault in backtrace
    subl $0x20, %esp
  8002ed:	83 ec 20             	sub    $0x20,%esp

    # call user-program function
    call umain
  8002f0:	e8 ca 00 00 00       	call   8003bf <umain>
1:  jmp 1b
  8002f5:	eb fe                	jmp    8002f5 <_start+0xd>

008002f7 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	83 ec 18             	sub    $0x18,%esp
    sys_putc(c);
  8002fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800300:	89 04 24             	mov    %eax,(%esp)
  800303:	e8 98 fe ff ff       	call   8001a0 <sys_putc>
    (*cnt) ++;
  800308:	8b 45 0c             	mov    0xc(%ebp),%eax
  80030b:	8b 00                	mov    (%eax),%eax
  80030d:	8d 50 01             	lea    0x1(%eax),%edx
  800310:	8b 45 0c             	mov    0xc(%ebp),%eax
  800313:	89 10                	mov    %edx,(%eax)
}
  800315:	c9                   	leave  
  800316:	c3                   	ret    

00800317 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  800317:	55                   	push   %ebp
  800318:	89 e5                	mov    %esp,%ebp
  80031a:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  80031d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800324:	8b 45 0c             	mov    0xc(%ebp),%eax
  800327:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80032b:	8b 45 08             	mov    0x8(%ebp),%eax
  80032e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800332:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800335:	89 44 24 04          	mov    %eax,0x4(%esp)
  800339:	c7 04 24 f7 02 80 00 	movl   $0x8002f7,(%esp)
  800340:	e8 14 07 00 00       	call   800a59 <vprintfmt>
    return cnt;
  800345:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800348:	c9                   	leave  
  800349:	c3                   	ret    

0080034a <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  80034a:	55                   	push   %ebp
  80034b:	89 e5                	mov    %esp,%ebp
  80034d:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  800350:	8d 45 0c             	lea    0xc(%ebp),%eax
  800353:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int cnt = vcprintf(fmt, ap);
  800356:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800359:	89 44 24 04          	mov    %eax,0x4(%esp)
  80035d:	8b 45 08             	mov    0x8(%ebp),%eax
  800360:	89 04 24             	mov    %eax,(%esp)
  800363:	e8 af ff ff ff       	call   800317 <vcprintf>
  800368:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);

    return cnt;
  80036b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80036e:	c9                   	leave  
  80036f:	c3                   	ret    

00800370 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  800370:	55                   	push   %ebp
  800371:	89 e5                	mov    %esp,%ebp
  800373:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  800376:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  80037d:	eb 13                	jmp    800392 <cputs+0x22>
        cputch(c, &cnt);
  80037f:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  800383:	8d 55 f0             	lea    -0x10(%ebp),%edx
  800386:	89 54 24 04          	mov    %edx,0x4(%esp)
  80038a:	89 04 24             	mov    %eax,(%esp)
  80038d:	e8 65 ff ff ff       	call   8002f7 <cputch>
    while ((c = *str ++) != '\0') {
  800392:	8b 45 08             	mov    0x8(%ebp),%eax
  800395:	8d 50 01             	lea    0x1(%eax),%edx
  800398:	89 55 08             	mov    %edx,0x8(%ebp)
  80039b:	0f b6 00             	movzbl (%eax),%eax
  80039e:	88 45 f7             	mov    %al,-0x9(%ebp)
  8003a1:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  8003a5:	75 d8                	jne    80037f <cputs+0xf>
    }
    cputch('\n', &cnt);
  8003a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8003aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ae:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8003b5:	e8 3d ff ff ff       	call   8002f7 <cputch>
    return cnt;
  8003ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8003bd:	c9                   	leave  
  8003be:	c3                   	ret    

008003bf <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8003bf:	55                   	push   %ebp
  8003c0:	89 e5                	mov    %esp,%ebp
  8003c2:	83 ec 28             	sub    $0x28,%esp
    int ret = main();
  8003c5:	e8 44 0c 00 00       	call   80100e <main>
  8003ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
    exit(ret);
  8003cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003d0:	89 04 24             	mov    %eax,(%esp)
  8003d3:	e8 41 fe ff ff       	call   800219 <exit>

008003d8 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  8003d8:	55                   	push   %ebp
  8003d9:	89 e5                	mov    %esp,%ebp
  8003db:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  8003de:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  8003e5:	eb 04                	jmp    8003eb <strlen+0x13>
        cnt ++;
  8003e7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (*s ++ != '\0') {
  8003eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ee:	8d 50 01             	lea    0x1(%eax),%edx
  8003f1:	89 55 08             	mov    %edx,0x8(%ebp)
  8003f4:	0f b6 00             	movzbl (%eax),%eax
  8003f7:	84 c0                	test   %al,%al
  8003f9:	75 ec                	jne    8003e7 <strlen+0xf>
    }
    return cnt;
  8003fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8003fe:	c9                   	leave  
  8003ff:	c3                   	ret    

00800400 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  800400:	55                   	push   %ebp
  800401:	89 e5                	mov    %esp,%ebp
  800403:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  800406:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  80040d:	eb 04                	jmp    800413 <strnlen+0x13>
        cnt ++;
  80040f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  800413:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800416:	3b 45 0c             	cmp    0xc(%ebp),%eax
  800419:	73 10                	jae    80042b <strnlen+0x2b>
  80041b:	8b 45 08             	mov    0x8(%ebp),%eax
  80041e:	8d 50 01             	lea    0x1(%eax),%edx
  800421:	89 55 08             	mov    %edx,0x8(%ebp)
  800424:	0f b6 00             	movzbl (%eax),%eax
  800427:	84 c0                	test   %al,%al
  800429:	75 e4                	jne    80040f <strnlen+0xf>
    }
    return cnt;
  80042b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80042e:	c9                   	leave  
  80042f:	c3                   	ret    

00800430 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  800430:	55                   	push   %ebp
  800431:	89 e5                	mov    %esp,%ebp
  800433:	57                   	push   %edi
  800434:	56                   	push   %esi
  800435:	83 ec 20             	sub    $0x20,%esp
  800438:	8b 45 08             	mov    0x8(%ebp),%eax
  80043b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80043e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800441:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  800444:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800447:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80044a:	89 d1                	mov    %edx,%ecx
  80044c:	89 c2                	mov    %eax,%edx
  80044e:	89 ce                	mov    %ecx,%esi
  800450:	89 d7                	mov    %edx,%edi
  800452:	ac                   	lods   %ds:(%esi),%al
  800453:	aa                   	stos   %al,%es:(%edi)
  800454:	84 c0                	test   %al,%al
  800456:	75 fa                	jne    800452 <strcpy+0x22>
  800458:	89 fa                	mov    %edi,%edx
  80045a:	89 f1                	mov    %esi,%ecx
  80045c:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  80045f:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800462:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  800465:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  800468:	83 c4 20             	add    $0x20,%esp
  80046b:	5e                   	pop    %esi
  80046c:	5f                   	pop    %edi
  80046d:	5d                   	pop    %ebp
  80046e:	c3                   	ret    

0080046f <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  80046f:	55                   	push   %ebp
  800470:	89 e5                	mov    %esp,%ebp
  800472:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  800475:	8b 45 08             	mov    0x8(%ebp),%eax
  800478:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  80047b:	eb 21                	jmp    80049e <strncpy+0x2f>
        if ((*p = *src) != '\0') {
  80047d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800480:	0f b6 10             	movzbl (%eax),%edx
  800483:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800486:	88 10                	mov    %dl,(%eax)
  800488:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80048b:	0f b6 00             	movzbl (%eax),%eax
  80048e:	84 c0                	test   %al,%al
  800490:	74 04                	je     800496 <strncpy+0x27>
            src ++;
  800492:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
  800496:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  80049a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    while (len > 0) {
  80049e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8004a2:	75 d9                	jne    80047d <strncpy+0xe>
    }
    return dst;
  8004a4:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8004a7:	c9                   	leave  
  8004a8:	c3                   	ret    

008004a9 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  8004a9:	55                   	push   %ebp
  8004aa:	89 e5                	mov    %esp,%ebp
  8004ac:	57                   	push   %edi
  8004ad:	56                   	push   %esi
  8004ae:	83 ec 20             	sub    $0x20,%esp
  8004b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8004b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  8004bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8004c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004c3:	89 d1                	mov    %edx,%ecx
  8004c5:	89 c2                	mov    %eax,%edx
  8004c7:	89 ce                	mov    %ecx,%esi
  8004c9:	89 d7                	mov    %edx,%edi
  8004cb:	ac                   	lods   %ds:(%esi),%al
  8004cc:	ae                   	scas   %es:(%edi),%al
  8004cd:	75 08                	jne    8004d7 <strcmp+0x2e>
  8004cf:	84 c0                	test   %al,%al
  8004d1:	75 f8                	jne    8004cb <strcmp+0x22>
  8004d3:	31 c0                	xor    %eax,%eax
  8004d5:	eb 04                	jmp    8004db <strcmp+0x32>
  8004d7:	19 c0                	sbb    %eax,%eax
  8004d9:	0c 01                	or     $0x1,%al
  8004db:	89 fa                	mov    %edi,%edx
  8004dd:	89 f1                	mov    %esi,%ecx
  8004df:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8004e2:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  8004e5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  8004e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  8004eb:	83 c4 20             	add    $0x20,%esp
  8004ee:	5e                   	pop    %esi
  8004ef:	5f                   	pop    %edi
  8004f0:	5d                   	pop    %ebp
  8004f1:	c3                   	ret    

008004f2 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  8004f2:	55                   	push   %ebp
  8004f3:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  8004f5:	eb 0c                	jmp    800503 <strncmp+0x11>
        n --, s1 ++, s2 ++;
  8004f7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8004fb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8004ff:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  800503:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800507:	74 1a                	je     800523 <strncmp+0x31>
  800509:	8b 45 08             	mov    0x8(%ebp),%eax
  80050c:	0f b6 00             	movzbl (%eax),%eax
  80050f:	84 c0                	test   %al,%al
  800511:	74 10                	je     800523 <strncmp+0x31>
  800513:	8b 45 08             	mov    0x8(%ebp),%eax
  800516:	0f b6 10             	movzbl (%eax),%edx
  800519:	8b 45 0c             	mov    0xc(%ebp),%eax
  80051c:	0f b6 00             	movzbl (%eax),%eax
  80051f:	38 c2                	cmp    %al,%dl
  800521:	74 d4                	je     8004f7 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  800523:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800527:	74 18                	je     800541 <strncmp+0x4f>
  800529:	8b 45 08             	mov    0x8(%ebp),%eax
  80052c:	0f b6 00             	movzbl (%eax),%eax
  80052f:	0f b6 d0             	movzbl %al,%edx
  800532:	8b 45 0c             	mov    0xc(%ebp),%eax
  800535:	0f b6 00             	movzbl (%eax),%eax
  800538:	0f b6 c0             	movzbl %al,%eax
  80053b:	29 c2                	sub    %eax,%edx
  80053d:	89 d0                	mov    %edx,%eax
  80053f:	eb 05                	jmp    800546 <strncmp+0x54>
  800541:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800546:	5d                   	pop    %ebp
  800547:	c3                   	ret    

00800548 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  800548:	55                   	push   %ebp
  800549:	89 e5                	mov    %esp,%ebp
  80054b:	83 ec 04             	sub    $0x4,%esp
  80054e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800551:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  800554:	eb 14                	jmp    80056a <strchr+0x22>
        if (*s == c) {
  800556:	8b 45 08             	mov    0x8(%ebp),%eax
  800559:	0f b6 00             	movzbl (%eax),%eax
  80055c:	3a 45 fc             	cmp    -0x4(%ebp),%al
  80055f:	75 05                	jne    800566 <strchr+0x1e>
            return (char *)s;
  800561:	8b 45 08             	mov    0x8(%ebp),%eax
  800564:	eb 13                	jmp    800579 <strchr+0x31>
        }
        s ++;
  800566:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
  80056a:	8b 45 08             	mov    0x8(%ebp),%eax
  80056d:	0f b6 00             	movzbl (%eax),%eax
  800570:	84 c0                	test   %al,%al
  800572:	75 e2                	jne    800556 <strchr+0xe>
    }
    return NULL;
  800574:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800579:	c9                   	leave  
  80057a:	c3                   	ret    

0080057b <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  80057b:	55                   	push   %ebp
  80057c:	89 e5                	mov    %esp,%ebp
  80057e:	83 ec 04             	sub    $0x4,%esp
  800581:	8b 45 0c             	mov    0xc(%ebp),%eax
  800584:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  800587:	eb 11                	jmp    80059a <strfind+0x1f>
        if (*s == c) {
  800589:	8b 45 08             	mov    0x8(%ebp),%eax
  80058c:	0f b6 00             	movzbl (%eax),%eax
  80058f:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800592:	75 02                	jne    800596 <strfind+0x1b>
            break;
  800594:	eb 0e                	jmp    8005a4 <strfind+0x29>
        }
        s ++;
  800596:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
  80059a:	8b 45 08             	mov    0x8(%ebp),%eax
  80059d:	0f b6 00             	movzbl (%eax),%eax
  8005a0:	84 c0                	test   %al,%al
  8005a2:	75 e5                	jne    800589 <strfind+0xe>
    }
    return (char *)s;
  8005a4:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8005a7:	c9                   	leave  
  8005a8:	c3                   	ret    

008005a9 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  8005a9:	55                   	push   %ebp
  8005aa:	89 e5                	mov    %esp,%ebp
  8005ac:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  8005af:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  8005b6:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  8005bd:	eb 04                	jmp    8005c3 <strtol+0x1a>
        s ++;
  8005bf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  8005c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c6:	0f b6 00             	movzbl (%eax),%eax
  8005c9:	3c 20                	cmp    $0x20,%al
  8005cb:	74 f2                	je     8005bf <strtol+0x16>
  8005cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d0:	0f b6 00             	movzbl (%eax),%eax
  8005d3:	3c 09                	cmp    $0x9,%al
  8005d5:	74 e8                	je     8005bf <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
  8005d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8005da:	0f b6 00             	movzbl (%eax),%eax
  8005dd:	3c 2b                	cmp    $0x2b,%al
  8005df:	75 06                	jne    8005e7 <strtol+0x3e>
        s ++;
  8005e1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8005e5:	eb 15                	jmp    8005fc <strtol+0x53>
    }
    else if (*s == '-') {
  8005e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ea:	0f b6 00             	movzbl (%eax),%eax
  8005ed:	3c 2d                	cmp    $0x2d,%al
  8005ef:	75 0b                	jne    8005fc <strtol+0x53>
        s ++, neg = 1;
  8005f1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8005f5:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  8005fc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800600:	74 06                	je     800608 <strtol+0x5f>
  800602:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800606:	75 24                	jne    80062c <strtol+0x83>
  800608:	8b 45 08             	mov    0x8(%ebp),%eax
  80060b:	0f b6 00             	movzbl (%eax),%eax
  80060e:	3c 30                	cmp    $0x30,%al
  800610:	75 1a                	jne    80062c <strtol+0x83>
  800612:	8b 45 08             	mov    0x8(%ebp),%eax
  800615:	83 c0 01             	add    $0x1,%eax
  800618:	0f b6 00             	movzbl (%eax),%eax
  80061b:	3c 78                	cmp    $0x78,%al
  80061d:	75 0d                	jne    80062c <strtol+0x83>
        s += 2, base = 16;
  80061f:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800623:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  80062a:	eb 2a                	jmp    800656 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
  80062c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800630:	75 17                	jne    800649 <strtol+0xa0>
  800632:	8b 45 08             	mov    0x8(%ebp),%eax
  800635:	0f b6 00             	movzbl (%eax),%eax
  800638:	3c 30                	cmp    $0x30,%al
  80063a:	75 0d                	jne    800649 <strtol+0xa0>
        s ++, base = 8;
  80063c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800640:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800647:	eb 0d                	jmp    800656 <strtol+0xad>
    }
    else if (base == 0) {
  800649:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80064d:	75 07                	jne    800656 <strtol+0xad>
        base = 10;
  80064f:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  800656:	8b 45 08             	mov    0x8(%ebp),%eax
  800659:	0f b6 00             	movzbl (%eax),%eax
  80065c:	3c 2f                	cmp    $0x2f,%al
  80065e:	7e 1b                	jle    80067b <strtol+0xd2>
  800660:	8b 45 08             	mov    0x8(%ebp),%eax
  800663:	0f b6 00             	movzbl (%eax),%eax
  800666:	3c 39                	cmp    $0x39,%al
  800668:	7f 11                	jg     80067b <strtol+0xd2>
            dig = *s - '0';
  80066a:	8b 45 08             	mov    0x8(%ebp),%eax
  80066d:	0f b6 00             	movzbl (%eax),%eax
  800670:	0f be c0             	movsbl %al,%eax
  800673:	83 e8 30             	sub    $0x30,%eax
  800676:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800679:	eb 48                	jmp    8006c3 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
  80067b:	8b 45 08             	mov    0x8(%ebp),%eax
  80067e:	0f b6 00             	movzbl (%eax),%eax
  800681:	3c 60                	cmp    $0x60,%al
  800683:	7e 1b                	jle    8006a0 <strtol+0xf7>
  800685:	8b 45 08             	mov    0x8(%ebp),%eax
  800688:	0f b6 00             	movzbl (%eax),%eax
  80068b:	3c 7a                	cmp    $0x7a,%al
  80068d:	7f 11                	jg     8006a0 <strtol+0xf7>
            dig = *s - 'a' + 10;
  80068f:	8b 45 08             	mov    0x8(%ebp),%eax
  800692:	0f b6 00             	movzbl (%eax),%eax
  800695:	0f be c0             	movsbl %al,%eax
  800698:	83 e8 57             	sub    $0x57,%eax
  80069b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80069e:	eb 23                	jmp    8006c3 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  8006a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a3:	0f b6 00             	movzbl (%eax),%eax
  8006a6:	3c 40                	cmp    $0x40,%al
  8006a8:	7e 3d                	jle    8006e7 <strtol+0x13e>
  8006aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ad:	0f b6 00             	movzbl (%eax),%eax
  8006b0:	3c 5a                	cmp    $0x5a,%al
  8006b2:	7f 33                	jg     8006e7 <strtol+0x13e>
            dig = *s - 'A' + 10;
  8006b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b7:	0f b6 00             	movzbl (%eax),%eax
  8006ba:	0f be c0             	movsbl %al,%eax
  8006bd:	83 e8 37             	sub    $0x37,%eax
  8006c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  8006c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006c6:	3b 45 10             	cmp    0x10(%ebp),%eax
  8006c9:	7c 02                	jl     8006cd <strtol+0x124>
            break;
  8006cb:	eb 1a                	jmp    8006e7 <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
  8006cd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8006d1:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8006d4:	0f af 45 10          	imul   0x10(%ebp),%eax
  8006d8:	89 c2                	mov    %eax,%edx
  8006da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006dd:	01 d0                	add    %edx,%eax
  8006df:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
  8006e2:	e9 6f ff ff ff       	jmp    800656 <strtol+0xad>

    if (endptr) {
  8006e7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006eb:	74 08                	je     8006f5 <strtol+0x14c>
        *endptr = (char *) s;
  8006ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8006f3:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  8006f5:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  8006f9:	74 07                	je     800702 <strtol+0x159>
  8006fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8006fe:	f7 d8                	neg    %eax
  800700:	eb 03                	jmp    800705 <strtol+0x15c>
  800702:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800705:	c9                   	leave  
  800706:	c3                   	ret    

00800707 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  800707:	55                   	push   %ebp
  800708:	89 e5                	mov    %esp,%ebp
  80070a:	57                   	push   %edi
  80070b:	83 ec 24             	sub    $0x24,%esp
  80070e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800711:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  800714:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800718:	8b 55 08             	mov    0x8(%ebp),%edx
  80071b:	89 55 f8             	mov    %edx,-0x8(%ebp)
  80071e:	88 45 f7             	mov    %al,-0x9(%ebp)
  800721:	8b 45 10             	mov    0x10(%ebp),%eax
  800724:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  800727:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  80072a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80072e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  800731:	89 d7                	mov    %edx,%edi
  800733:	f3 aa                	rep stos %al,%es:(%edi)
  800735:	89 fa                	mov    %edi,%edx
  800737:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  80073a:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  80073d:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  800740:	83 c4 24             	add    $0x24,%esp
  800743:	5f                   	pop    %edi
  800744:	5d                   	pop    %ebp
  800745:	c3                   	ret    

00800746 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  800746:	55                   	push   %ebp
  800747:	89 e5                	mov    %esp,%ebp
  800749:	57                   	push   %edi
  80074a:	56                   	push   %esi
  80074b:	53                   	push   %ebx
  80074c:	83 ec 30             	sub    $0x30,%esp
  80074f:	8b 45 08             	mov    0x8(%ebp),%eax
  800752:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800755:	8b 45 0c             	mov    0xc(%ebp),%eax
  800758:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80075b:	8b 45 10             	mov    0x10(%ebp),%eax
  80075e:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  800761:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800764:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800767:	73 42                	jae    8007ab <memmove+0x65>
  800769:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80076c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80076f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800772:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800775:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800778:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  80077b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80077e:	c1 e8 02             	shr    $0x2,%eax
  800781:	89 c1                	mov    %eax,%ecx
    asm volatile (
  800783:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800786:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800789:	89 d7                	mov    %edx,%edi
  80078b:	89 c6                	mov    %eax,%esi
  80078d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80078f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800792:	83 e1 03             	and    $0x3,%ecx
  800795:	74 02                	je     800799 <memmove+0x53>
  800797:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  800799:	89 f0                	mov    %esi,%eax
  80079b:	89 fa                	mov    %edi,%edx
  80079d:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8007a0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8007a3:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
  8007a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007a9:	eb 36                	jmp    8007e1 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  8007ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8007ae:	8d 50 ff             	lea    -0x1(%eax),%edx
  8007b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007b4:	01 c2                	add    %eax,%edx
  8007b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8007b9:	8d 48 ff             	lea    -0x1(%eax),%ecx
  8007bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007bf:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  8007c2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8007c5:	89 c1                	mov    %eax,%ecx
  8007c7:	89 d8                	mov    %ebx,%eax
  8007c9:	89 d6                	mov    %edx,%esi
  8007cb:	89 c7                	mov    %eax,%edi
  8007cd:	fd                   	std    
  8007ce:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  8007d0:	fc                   	cld    
  8007d1:	89 f8                	mov    %edi,%eax
  8007d3:	89 f2                	mov    %esi,%edx
  8007d5:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8007d8:	89 55 c8             	mov    %edx,-0x38(%ebp)
  8007db:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  8007de:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  8007e1:	83 c4 30             	add    $0x30,%esp
  8007e4:	5b                   	pop    %ebx
  8007e5:	5e                   	pop    %esi
  8007e6:	5f                   	pop    %edi
  8007e7:	5d                   	pop    %ebp
  8007e8:	c3                   	ret    

008007e9 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	57                   	push   %edi
  8007ed:	56                   	push   %esi
  8007ee:	83 ec 20             	sub    $0x20,%esp
  8007f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8007f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007fd:	8b 45 10             	mov    0x10(%ebp),%eax
  800800:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  800803:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800806:	c1 e8 02             	shr    $0x2,%eax
  800809:	89 c1                	mov    %eax,%ecx
    asm volatile (
  80080b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80080e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800811:	89 d7                	mov    %edx,%edi
  800813:	89 c6                	mov    %eax,%esi
  800815:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800817:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  80081a:	83 e1 03             	and    $0x3,%ecx
  80081d:	74 02                	je     800821 <memcpy+0x38>
  80081f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  800821:	89 f0                	mov    %esi,%eax
  800823:	89 fa                	mov    %edi,%edx
  800825:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  800828:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80082b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  80082e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  800831:	83 c4 20             	add    $0x20,%esp
  800834:	5e                   	pop    %esi
  800835:	5f                   	pop    %edi
  800836:	5d                   	pop    %ebp
  800837:	c3                   	ret    

00800838 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  80083e:	8b 45 08             	mov    0x8(%ebp),%eax
  800841:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  800844:	8b 45 0c             	mov    0xc(%ebp),%eax
  800847:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  80084a:	eb 30                	jmp    80087c <memcmp+0x44>
        if (*s1 != *s2) {
  80084c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80084f:	0f b6 10             	movzbl (%eax),%edx
  800852:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800855:	0f b6 00             	movzbl (%eax),%eax
  800858:	38 c2                	cmp    %al,%dl
  80085a:	74 18                	je     800874 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  80085c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80085f:	0f b6 00             	movzbl (%eax),%eax
  800862:	0f b6 d0             	movzbl %al,%edx
  800865:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800868:	0f b6 00             	movzbl (%eax),%eax
  80086b:	0f b6 c0             	movzbl %al,%eax
  80086e:	29 c2                	sub    %eax,%edx
  800870:	89 d0                	mov    %edx,%eax
  800872:	eb 1a                	jmp    80088e <memcmp+0x56>
        }
        s1 ++, s2 ++;
  800874:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800878:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
    while (n -- > 0) {
  80087c:	8b 45 10             	mov    0x10(%ebp),%eax
  80087f:	8d 50 ff             	lea    -0x1(%eax),%edx
  800882:	89 55 10             	mov    %edx,0x10(%ebp)
  800885:	85 c0                	test   %eax,%eax
  800887:	75 c3                	jne    80084c <memcmp+0x14>
    }
    return 0;
  800889:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80088e:	c9                   	leave  
  80088f:	c3                   	ret    

00800890 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	83 ec 58             	sub    $0x58,%esp
  800896:	8b 45 10             	mov    0x10(%ebp),%eax
  800899:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80089c:	8b 45 14             	mov    0x14(%ebp),%eax
  80089f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  8008a2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008a5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8008a8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8008ab:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  8008ae:	8b 45 18             	mov    0x18(%ebp),%eax
  8008b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8008b7:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8008ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008bd:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8008c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8008c6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8008ca:	74 1c                	je     8008e8 <printnum+0x58>
  8008cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8008d4:	f7 75 e4             	divl   -0x1c(%ebp)
  8008d7:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8008da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8008e2:	f7 75 e4             	divl   -0x1c(%ebp)
  8008e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8008e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008ee:	f7 75 e4             	divl   -0x1c(%ebp)
  8008f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008f4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008fa:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8008fd:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800900:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800903:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800906:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  800909:	8b 45 18             	mov    0x18(%ebp),%eax
  80090c:	ba 00 00 00 00       	mov    $0x0,%edx
  800911:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  800914:	77 56                	ja     80096c <printnum+0xdc>
  800916:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  800919:	72 05                	jb     800920 <printnum+0x90>
  80091b:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  80091e:	77 4c                	ja     80096c <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  800920:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800923:	8d 50 ff             	lea    -0x1(%eax),%edx
  800926:	8b 45 20             	mov    0x20(%ebp),%eax
  800929:	89 44 24 18          	mov    %eax,0x18(%esp)
  80092d:	89 54 24 14          	mov    %edx,0x14(%esp)
  800931:	8b 45 18             	mov    0x18(%ebp),%eax
  800934:	89 44 24 10          	mov    %eax,0x10(%esp)
  800938:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80093b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80093e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800942:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800946:	8b 45 0c             	mov    0xc(%ebp),%eax
  800949:	89 44 24 04          	mov    %eax,0x4(%esp)
  80094d:	8b 45 08             	mov    0x8(%ebp),%eax
  800950:	89 04 24             	mov    %eax,(%esp)
  800953:	e8 38 ff ff ff       	call   800890 <printnum>
  800958:	eb 1c                	jmp    800976 <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  80095a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800961:	8b 45 20             	mov    0x20(%ebp),%eax
  800964:	89 04 24             	mov    %eax,(%esp)
  800967:	8b 45 08             	mov    0x8(%ebp),%eax
  80096a:	ff d0                	call   *%eax
        while (-- width > 0)
  80096c:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800970:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800974:	7f e4                	jg     80095a <printnum+0xca>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800976:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800979:	05 c4 12 80 00       	add    $0x8012c4,%eax
  80097e:	0f b6 00             	movzbl (%eax),%eax
  800981:	0f be c0             	movsbl %al,%eax
  800984:	8b 55 0c             	mov    0xc(%ebp),%edx
  800987:	89 54 24 04          	mov    %edx,0x4(%esp)
  80098b:	89 04 24             	mov    %eax,(%esp)
  80098e:	8b 45 08             	mov    0x8(%ebp),%eax
  800991:	ff d0                	call   *%eax
}
  800993:	c9                   	leave  
  800994:	c3                   	ret    

00800995 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  800998:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80099c:	7e 14                	jle    8009b2 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	8b 00                	mov    (%eax),%eax
  8009a3:	8d 48 08             	lea    0x8(%eax),%ecx
  8009a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8009a9:	89 0a                	mov    %ecx,(%edx)
  8009ab:	8b 50 04             	mov    0x4(%eax),%edx
  8009ae:	8b 00                	mov    (%eax),%eax
  8009b0:	eb 30                	jmp    8009e2 <getuint+0x4d>
    }
    else if (lflag) {
  8009b2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009b6:	74 16                	je     8009ce <getuint+0x39>
        return va_arg(*ap, unsigned long);
  8009b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bb:	8b 00                	mov    (%eax),%eax
  8009bd:	8d 48 04             	lea    0x4(%eax),%ecx
  8009c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8009c3:	89 0a                	mov    %ecx,(%edx)
  8009c5:	8b 00                	mov    (%eax),%eax
  8009c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009cc:	eb 14                	jmp    8009e2 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  8009ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d1:	8b 00                	mov    (%eax),%eax
  8009d3:	8d 48 04             	lea    0x4(%eax),%ecx
  8009d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8009d9:	89 0a                	mov    %ecx,(%edx)
  8009db:	8b 00                	mov    (%eax),%eax
  8009dd:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  8009e2:	5d                   	pop    %ebp
  8009e3:	c3                   	ret    

008009e4 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  8009e7:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8009eb:	7e 14                	jle    800a01 <getint+0x1d>
        return va_arg(*ap, long long);
  8009ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f0:	8b 00                	mov    (%eax),%eax
  8009f2:	8d 48 08             	lea    0x8(%eax),%ecx
  8009f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f8:	89 0a                	mov    %ecx,(%edx)
  8009fa:	8b 50 04             	mov    0x4(%eax),%edx
  8009fd:	8b 00                	mov    (%eax),%eax
  8009ff:	eb 28                	jmp    800a29 <getint+0x45>
    }
    else if (lflag) {
  800a01:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a05:	74 12                	je     800a19 <getint+0x35>
        return va_arg(*ap, long);
  800a07:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0a:	8b 00                	mov    (%eax),%eax
  800a0c:	8d 48 04             	lea    0x4(%eax),%ecx
  800a0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800a12:	89 0a                	mov    %ecx,(%edx)
  800a14:	8b 00                	mov    (%eax),%eax
  800a16:	99                   	cltd   
  800a17:	eb 10                	jmp    800a29 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  800a19:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1c:	8b 00                	mov    (%eax),%eax
  800a1e:	8d 48 04             	lea    0x4(%eax),%ecx
  800a21:	8b 55 08             	mov    0x8(%ebp),%edx
  800a24:	89 0a                	mov    %ecx,(%edx)
  800a26:	8b 00                	mov    (%eax),%eax
  800a28:	99                   	cltd   
    }
}
  800a29:	5d                   	pop    %ebp
  800a2a:	c3                   	ret    

00800a2b <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  800a31:	8d 45 14             	lea    0x14(%ebp),%eax
  800a34:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  800a37:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a3a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a3e:	8b 45 10             	mov    0x10(%ebp),%eax
  800a41:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a45:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a48:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4f:	89 04 24             	mov    %eax,(%esp)
  800a52:	e8 02 00 00 00       	call   800a59 <vprintfmt>
    va_end(ap);
}
  800a57:	c9                   	leave  
  800a58:	c3                   	ret    

00800a59 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	56                   	push   %esi
  800a5d:	53                   	push   %ebx
  800a5e:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800a61:	eb 18                	jmp    800a7b <vprintfmt+0x22>
            if (ch == '\0') {
  800a63:	85 db                	test   %ebx,%ebx
  800a65:	75 05                	jne    800a6c <vprintfmt+0x13>
                return;
  800a67:	e9 d1 03 00 00       	jmp    800e3d <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
  800a6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a73:	89 1c 24             	mov    %ebx,(%esp)
  800a76:	8b 45 08             	mov    0x8(%ebp),%eax
  800a79:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800a7b:	8b 45 10             	mov    0x10(%ebp),%eax
  800a7e:	8d 50 01             	lea    0x1(%eax),%edx
  800a81:	89 55 10             	mov    %edx,0x10(%ebp)
  800a84:	0f b6 00             	movzbl (%eax),%eax
  800a87:	0f b6 d8             	movzbl %al,%ebx
  800a8a:	83 fb 25             	cmp    $0x25,%ebx
  800a8d:	75 d4                	jne    800a63 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
  800a8f:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  800a93:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800a9a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a9d:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  800aa0:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800aa7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800aaa:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800aad:	8b 45 10             	mov    0x10(%ebp),%eax
  800ab0:	8d 50 01             	lea    0x1(%eax),%edx
  800ab3:	89 55 10             	mov    %edx,0x10(%ebp)
  800ab6:	0f b6 00             	movzbl (%eax),%eax
  800ab9:	0f b6 d8             	movzbl %al,%ebx
  800abc:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800abf:	83 f8 55             	cmp    $0x55,%eax
  800ac2:	0f 87 44 03 00 00    	ja     800e0c <vprintfmt+0x3b3>
  800ac8:	8b 04 85 e8 12 80 00 	mov    0x8012e8(,%eax,4),%eax
  800acf:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  800ad1:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  800ad5:	eb d6                	jmp    800aad <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  800ad7:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  800adb:	eb d0                	jmp    800aad <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  800add:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  800ae4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800ae7:	89 d0                	mov    %edx,%eax
  800ae9:	c1 e0 02             	shl    $0x2,%eax
  800aec:	01 d0                	add    %edx,%eax
  800aee:	01 c0                	add    %eax,%eax
  800af0:	01 d8                	add    %ebx,%eax
  800af2:	83 e8 30             	sub    $0x30,%eax
  800af5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  800af8:	8b 45 10             	mov    0x10(%ebp),%eax
  800afb:	0f b6 00             	movzbl (%eax),%eax
  800afe:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  800b01:	83 fb 2f             	cmp    $0x2f,%ebx
  800b04:	7e 0b                	jle    800b11 <vprintfmt+0xb8>
  800b06:	83 fb 39             	cmp    $0x39,%ebx
  800b09:	7f 06                	jg     800b11 <vprintfmt+0xb8>
            for (precision = 0; ; ++ fmt) {
  800b0b:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                    break;
                }
            }
  800b0f:	eb d3                	jmp    800ae4 <vprintfmt+0x8b>
            goto process_precision;
  800b11:	eb 33                	jmp    800b46 <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
  800b13:	8b 45 14             	mov    0x14(%ebp),%eax
  800b16:	8d 50 04             	lea    0x4(%eax),%edx
  800b19:	89 55 14             	mov    %edx,0x14(%ebp)
  800b1c:	8b 00                	mov    (%eax),%eax
  800b1e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  800b21:	eb 23                	jmp    800b46 <vprintfmt+0xed>

        case '.':
            if (width < 0)
  800b23:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800b27:	79 0c                	jns    800b35 <vprintfmt+0xdc>
                width = 0;
  800b29:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  800b30:	e9 78 ff ff ff       	jmp    800aad <vprintfmt+0x54>
  800b35:	e9 73 ff ff ff       	jmp    800aad <vprintfmt+0x54>

        case '#':
            altflag = 1;
  800b3a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  800b41:	e9 67 ff ff ff       	jmp    800aad <vprintfmt+0x54>

        process_precision:
            if (width < 0)
  800b46:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800b4a:	79 12                	jns    800b5e <vprintfmt+0x105>
                width = precision, precision = -1;
  800b4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800b4f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800b52:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  800b59:	e9 4f ff ff ff       	jmp    800aad <vprintfmt+0x54>
  800b5e:	e9 4a ff ff ff       	jmp    800aad <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  800b63:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
  800b67:	e9 41 ff ff ff       	jmp    800aad <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  800b6c:	8b 45 14             	mov    0x14(%ebp),%eax
  800b6f:	8d 50 04             	lea    0x4(%eax),%edx
  800b72:	89 55 14             	mov    %edx,0x14(%ebp)
  800b75:	8b 00                	mov    (%eax),%eax
  800b77:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b7a:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b7e:	89 04 24             	mov    %eax,(%esp)
  800b81:	8b 45 08             	mov    0x8(%ebp),%eax
  800b84:	ff d0                	call   *%eax
            break;
  800b86:	e9 ac 02 00 00       	jmp    800e37 <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
  800b8b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b8e:	8d 50 04             	lea    0x4(%eax),%edx
  800b91:	89 55 14             	mov    %edx,0x14(%ebp)
  800b94:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  800b96:	85 db                	test   %ebx,%ebx
  800b98:	79 02                	jns    800b9c <vprintfmt+0x143>
                err = -err;
  800b9a:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800b9c:	83 fb 18             	cmp    $0x18,%ebx
  800b9f:	7f 0b                	jg     800bac <vprintfmt+0x153>
  800ba1:	8b 34 9d 60 12 80 00 	mov    0x801260(,%ebx,4),%esi
  800ba8:	85 f6                	test   %esi,%esi
  800baa:	75 23                	jne    800bcf <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
  800bac:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800bb0:	c7 44 24 08 d5 12 80 	movl   $0x8012d5,0x8(%esp)
  800bb7:	00 
  800bb8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bbb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc2:	89 04 24             	mov    %eax,(%esp)
  800bc5:	e8 61 fe ff ff       	call   800a2b <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  800bca:	e9 68 02 00 00       	jmp    800e37 <vprintfmt+0x3de>
                printfmt(putch, putdat, "%s", p);
  800bcf:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800bd3:	c7 44 24 08 de 12 80 	movl   $0x8012de,0x8(%esp)
  800bda:	00 
  800bdb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bde:	89 44 24 04          	mov    %eax,0x4(%esp)
  800be2:	8b 45 08             	mov    0x8(%ebp),%eax
  800be5:	89 04 24             	mov    %eax,(%esp)
  800be8:	e8 3e fe ff ff       	call   800a2b <printfmt>
            break;
  800bed:	e9 45 02 00 00       	jmp    800e37 <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  800bf2:	8b 45 14             	mov    0x14(%ebp),%eax
  800bf5:	8d 50 04             	lea    0x4(%eax),%edx
  800bf8:	89 55 14             	mov    %edx,0x14(%ebp)
  800bfb:	8b 30                	mov    (%eax),%esi
  800bfd:	85 f6                	test   %esi,%esi
  800bff:	75 05                	jne    800c06 <vprintfmt+0x1ad>
                p = "(null)";
  800c01:	be e1 12 80 00       	mov    $0x8012e1,%esi
            }
            if (width > 0 && padc != '-') {
  800c06:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800c0a:	7e 3e                	jle    800c4a <vprintfmt+0x1f1>
  800c0c:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800c10:	74 38                	je     800c4a <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800c12:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  800c15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c18:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c1c:	89 34 24             	mov    %esi,(%esp)
  800c1f:	e8 dc f7 ff ff       	call   800400 <strnlen>
  800c24:	29 c3                	sub    %eax,%ebx
  800c26:	89 d8                	mov    %ebx,%eax
  800c28:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800c2b:	eb 17                	jmp    800c44 <vprintfmt+0x1eb>
                    putch(padc, putdat);
  800c2d:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800c31:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c34:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c38:	89 04 24             	mov    %eax,(%esp)
  800c3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3e:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
  800c40:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  800c44:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800c48:	7f e3                	jg     800c2d <vprintfmt+0x1d4>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800c4a:	eb 38                	jmp    800c84 <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
  800c4c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800c50:	74 1f                	je     800c71 <vprintfmt+0x218>
  800c52:	83 fb 1f             	cmp    $0x1f,%ebx
  800c55:	7e 05                	jle    800c5c <vprintfmt+0x203>
  800c57:	83 fb 7e             	cmp    $0x7e,%ebx
  800c5a:	7e 15                	jle    800c71 <vprintfmt+0x218>
                    putch('?', putdat);
  800c5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c63:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800c6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6d:	ff d0                	call   *%eax
  800c6f:	eb 0f                	jmp    800c80 <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
  800c71:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c74:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c78:	89 1c 24             	mov    %ebx,(%esp)
  800c7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7e:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800c80:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  800c84:	89 f0                	mov    %esi,%eax
  800c86:	8d 70 01             	lea    0x1(%eax),%esi
  800c89:	0f b6 00             	movzbl (%eax),%eax
  800c8c:	0f be d8             	movsbl %al,%ebx
  800c8f:	85 db                	test   %ebx,%ebx
  800c91:	74 10                	je     800ca3 <vprintfmt+0x24a>
  800c93:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c97:	78 b3                	js     800c4c <vprintfmt+0x1f3>
  800c99:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800c9d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ca1:	79 a9                	jns    800c4c <vprintfmt+0x1f3>
                }
            }
            for (; width > 0; width --) {
  800ca3:	eb 17                	jmp    800cbc <vprintfmt+0x263>
                putch(' ', putdat);
  800ca5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ca8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cac:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800cb3:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb6:	ff d0                	call   *%eax
            for (; width > 0; width --) {
  800cb8:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  800cbc:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800cc0:	7f e3                	jg     800ca5 <vprintfmt+0x24c>
            }
            break;
  800cc2:	e9 70 01 00 00       	jmp    800e37 <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  800cc7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800cca:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cce:	8d 45 14             	lea    0x14(%ebp),%eax
  800cd1:	89 04 24             	mov    %eax,(%esp)
  800cd4:	e8 0b fd ff ff       	call   8009e4 <getint>
  800cd9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800cdc:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  800cdf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ce2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ce5:	85 d2                	test   %edx,%edx
  800ce7:	79 26                	jns    800d0f <vprintfmt+0x2b6>
                putch('-', putdat);
  800ce9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cec:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cf0:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800cf7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfa:	ff d0                	call   *%eax
                num = -(long long)num;
  800cfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cff:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d02:	f7 d8                	neg    %eax
  800d04:	83 d2 00             	adc    $0x0,%edx
  800d07:	f7 da                	neg    %edx
  800d09:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800d0c:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  800d0f:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  800d16:	e9 a8 00 00 00       	jmp    800dc3 <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  800d1b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d22:	8d 45 14             	lea    0x14(%ebp),%eax
  800d25:	89 04 24             	mov    %eax,(%esp)
  800d28:	e8 68 fc ff ff       	call   800995 <getuint>
  800d2d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800d30:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  800d33:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  800d3a:	e9 84 00 00 00       	jmp    800dc3 <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  800d3f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d42:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d46:	8d 45 14             	lea    0x14(%ebp),%eax
  800d49:	89 04 24             	mov    %eax,(%esp)
  800d4c:	e8 44 fc ff ff       	call   800995 <getuint>
  800d51:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800d54:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  800d57:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  800d5e:	eb 63                	jmp    800dc3 <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
  800d60:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d63:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d67:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800d6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d71:	ff d0                	call   *%eax
            putch('x', putdat);
  800d73:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d76:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d7a:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800d81:	8b 45 08             	mov    0x8(%ebp),%eax
  800d84:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800d86:	8b 45 14             	mov    0x14(%ebp),%eax
  800d89:	8d 50 04             	lea    0x4(%eax),%edx
  800d8c:	89 55 14             	mov    %edx,0x14(%ebp)
  800d8f:	8b 00                	mov    (%eax),%eax
  800d91:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800d94:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  800d9b:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  800da2:	eb 1f                	jmp    800dc3 <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  800da4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800da7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dab:	8d 45 14             	lea    0x14(%ebp),%eax
  800dae:	89 04 24             	mov    %eax,(%esp)
  800db1:	e8 df fb ff ff       	call   800995 <getuint>
  800db6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800db9:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  800dbc:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  800dc3:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800dc7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800dca:	89 54 24 18          	mov    %edx,0x18(%esp)
  800dce:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800dd1:	89 54 24 14          	mov    %edx,0x14(%esp)
  800dd5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ddc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ddf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800de3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800de7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dea:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dee:	8b 45 08             	mov    0x8(%ebp),%eax
  800df1:	89 04 24             	mov    %eax,(%esp)
  800df4:	e8 97 fa ff ff       	call   800890 <printnum>
            break;
  800df9:	eb 3c                	jmp    800e37 <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  800dfb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dfe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e02:	89 1c 24             	mov    %ebx,(%esp)
  800e05:	8b 45 08             	mov    0x8(%ebp),%eax
  800e08:	ff d0                	call   *%eax
            break;
  800e0a:	eb 2b                	jmp    800e37 <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  800e0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e0f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e13:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800e1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1d:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  800e1f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800e23:	eb 04                	jmp    800e29 <vprintfmt+0x3d0>
  800e25:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800e29:	8b 45 10             	mov    0x10(%ebp),%eax
  800e2c:	83 e8 01             	sub    $0x1,%eax
  800e2f:	0f b6 00             	movzbl (%eax),%eax
  800e32:	3c 25                	cmp    $0x25,%al
  800e34:	75 ef                	jne    800e25 <vprintfmt+0x3cc>
                /* do nothing */;
            break;
  800e36:	90                   	nop
        }
    }
  800e37:	90                   	nop
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800e38:	e9 3e fc ff ff       	jmp    800a7b <vprintfmt+0x22>
}
  800e3d:	83 c4 40             	add    $0x40,%esp
  800e40:	5b                   	pop    %ebx
  800e41:	5e                   	pop    %esi
  800e42:	5d                   	pop    %ebp
  800e43:	c3                   	ret    

00800e44 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  800e47:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e4a:	8b 40 08             	mov    0x8(%eax),%eax
  800e4d:	8d 50 01             	lea    0x1(%eax),%edx
  800e50:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e53:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  800e56:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e59:	8b 10                	mov    (%eax),%edx
  800e5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5e:	8b 40 04             	mov    0x4(%eax),%eax
  800e61:	39 c2                	cmp    %eax,%edx
  800e63:	73 12                	jae    800e77 <sprintputch+0x33>
        *b->buf ++ = ch;
  800e65:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e68:	8b 00                	mov    (%eax),%eax
  800e6a:	8d 48 01             	lea    0x1(%eax),%ecx
  800e6d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e70:	89 0a                	mov    %ecx,(%edx)
  800e72:	8b 55 08             	mov    0x8(%ebp),%edx
  800e75:	88 10                	mov    %dl,(%eax)
    }
}
  800e77:	5d                   	pop    %ebp
  800e78:	c3                   	ret    

00800e79 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  800e79:	55                   	push   %ebp
  800e7a:	89 e5                	mov    %esp,%ebp
  800e7c:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  800e7f:	8d 45 14             	lea    0x14(%ebp),%eax
  800e82:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  800e85:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e88:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e8c:	8b 45 10             	mov    0x10(%ebp),%eax
  800e8f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e93:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e96:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9d:	89 04 24             	mov    %eax,(%esp)
  800ea0:	e8 08 00 00 00       	call   800ead <vsnprintf>
  800ea5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  800ea8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800eab:	c9                   	leave  
  800eac:	c3                   	ret    

00800ead <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  800ead:	55                   	push   %ebp
  800eae:	89 e5                	mov    %esp,%ebp
  800eb0:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  800eb3:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800eb9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ebc:	8d 50 ff             	lea    -0x1(%eax),%edx
  800ebf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec2:	01 d0                	add    %edx,%eax
  800ec4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800ec7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  800ece:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800ed2:	74 0a                	je     800ede <vsnprintf+0x31>
  800ed4:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800ed7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eda:	39 c2                	cmp    %eax,%edx
  800edc:	76 07                	jbe    800ee5 <vsnprintf+0x38>
        return -E_INVAL;
  800ede:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ee3:	eb 2a                	jmp    800f0f <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ee5:	8b 45 14             	mov    0x14(%ebp),%eax
  800ee8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800eec:	8b 45 10             	mov    0x10(%ebp),%eax
  800eef:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ef3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ef6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800efa:	c7 04 24 44 0e 80 00 	movl   $0x800e44,(%esp)
  800f01:	e8 53 fb ff ff       	call   800a59 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  800f06:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f09:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  800f0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800f0f:	c9                   	leave  
  800f10:	c3                   	ret    

00800f11 <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
  800f11:	55                   	push   %ebp
  800f12:	89 e5                	mov    %esp,%ebp
  800f14:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
  800f17:	8b 45 08             	mov    0x8(%ebp),%eax
  800f1a:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
  800f20:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
  800f23:	b8 20 00 00 00       	mov    $0x20,%eax
  800f28:	2b 45 0c             	sub    0xc(%ebp),%eax
  800f2b:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800f2e:	89 c1                	mov    %eax,%ecx
  800f30:	d3 ea                	shr    %cl,%edx
  800f32:	89 d0                	mov    %edx,%eax
}
  800f34:	c9                   	leave  
  800f35:	c3                   	ret    

00800f36 <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
  800f36:	55                   	push   %ebp
  800f37:	89 e5                	mov    %esp,%ebp
  800f39:	57                   	push   %edi
  800f3a:	56                   	push   %esi
  800f3b:	53                   	push   %ebx
  800f3c:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
  800f3f:	a1 00 20 80 00       	mov    0x802000,%eax
  800f44:	8b 15 04 20 80 00    	mov    0x802004,%edx
  800f4a:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
  800f50:	6b f0 05             	imul   $0x5,%eax,%esi
  800f53:	01 f7                	add    %esi,%edi
  800f55:	be 6d e6 ec de       	mov    $0xdeece66d,%esi
  800f5a:	f7 e6                	mul    %esi
  800f5c:	8d 34 17             	lea    (%edi,%edx,1),%esi
  800f5f:	89 f2                	mov    %esi,%edx
  800f61:	83 c0 0b             	add    $0xb,%eax
  800f64:	83 d2 00             	adc    $0x0,%edx
  800f67:	89 c7                	mov    %eax,%edi
  800f69:	83 e7 ff             	and    $0xffffffff,%edi
  800f6c:	89 f9                	mov    %edi,%ecx
  800f6e:	0f b7 da             	movzwl %dx,%ebx
  800f71:	89 0d 00 20 80 00    	mov    %ecx,0x802000
  800f77:	89 1d 04 20 80 00    	mov    %ebx,0x802004
    unsigned long long result = (next >> 12);
  800f7d:	a1 00 20 80 00       	mov    0x802000,%eax
  800f82:	8b 15 04 20 80 00    	mov    0x802004,%edx
  800f88:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  800f8c:	c1 ea 0c             	shr    $0xc,%edx
  800f8f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f92:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
  800f95:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
  800f9c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f9f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fa2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800fa5:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800fa8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800fab:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800fae:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800fb2:	74 1c                	je     800fd0 <rand+0x9a>
  800fb4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800fb7:	ba 00 00 00 00       	mov    $0x0,%edx
  800fbc:	f7 75 dc             	divl   -0x24(%ebp)
  800fbf:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800fc2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800fc5:	ba 00 00 00 00       	mov    $0x0,%edx
  800fca:	f7 75 dc             	divl   -0x24(%ebp)
  800fcd:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800fd0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800fd3:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800fd6:	f7 75 dc             	divl   -0x24(%ebp)
  800fd9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800fdc:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800fdf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800fe2:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800fe5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800fe8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800feb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
  800fee:	83 c4 24             	add    $0x24,%esp
  800ff1:	5b                   	pop    %ebx
  800ff2:	5e                   	pop    %esi
  800ff3:	5f                   	pop    %edi
  800ff4:	5d                   	pop    %ebp
  800ff5:	c3                   	ret    

00800ff6 <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
  800ff6:	55                   	push   %ebp
  800ff7:	89 e5                	mov    %esp,%ebp
    next = seed;
  800ff9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ffc:	ba 00 00 00 00       	mov    $0x0,%edx
  801001:	a3 00 20 80 00       	mov    %eax,0x802000
  801006:	89 15 04 20 80 00    	mov    %edx,0x802004
}
  80100c:	5d                   	pop    %ebp
  80100d:	c3                   	ret    

0080100e <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  80100e:	55                   	push   %ebp
  80100f:	89 e5                	mov    %esp,%ebp
  801011:	83 e4 f0             	and    $0xfffffff0,%esp
  801014:	83 ec 20             	sub    $0x20,%esp
    int pid, ret;
    cprintf("I am the parent. Forking the child...\n");
  801017:	c7 04 24 40 14 80 00 	movl   $0x801440,(%esp)
  80101e:	e8 27 f3 ff ff       	call   80034a <cprintf>
    pid = fork();
  801023:	e8 10 f2 ff ff       	call   800238 <fork>
  801028:	89 44 24 1c          	mov    %eax,0x1c(%esp)
    if (pid== 0) {
  80102c:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
  801031:	75 0e                	jne    801041 <main+0x33>
        cprintf("I am the child. spinning ...\n");
  801033:	c7 04 24 67 14 80 00 	movl   $0x801467,(%esp)
  80103a:	e8 0b f3 ff ff       	call   80034a <cprintf>
        while (1);
  80103f:	eb fe                	jmp    80103f <main+0x31>
    }else if (pid<0) {
  801041:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
  801046:	79 1c                	jns    801064 <main+0x56>
        panic("fork child error\n");
  801048:	c7 44 24 08 85 14 80 	movl   $0x801485,0x8(%esp)
  80104f:	00 
  801050:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  801057:	00 
  801058:	c7 04 24 97 14 80 00 	movl   $0x801497,(%esp)
  80105f:	e8 bc ef ff ff       	call   800020 <__panic>
    }
    cprintf("I am the parent. Running the child...\n");
  801064:	c7 04 24 a4 14 80 00 	movl   $0x8014a4,(%esp)
  80106b:	e8 da f2 ff ff       	call   80034a <cprintf>

    yield();
  801070:	e8 06 f2 ff ff       	call   80027b <yield>
    yield();
  801075:	e8 01 f2 ff ff       	call   80027b <yield>
    yield();
  80107a:	e8 fc f1 ff ff       	call   80027b <yield>
    
    cprintf("I am the parent.  Killing the child...\n");
  80107f:	c7 04 24 cc 14 80 00 	movl   $0x8014cc,(%esp)
  801086:	e8 bf f2 ff ff       	call   80034a <cprintf>

    assert((ret = kill(pid)) == 0);
  80108b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80108f:	89 04 24             	mov    %eax,(%esp)
  801092:	e8 f1 f1 ff ff       	call   800288 <kill>
  801097:	89 44 24 18          	mov    %eax,0x18(%esp)
  80109b:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
  8010a0:	74 24                	je     8010c6 <main+0xb8>
  8010a2:	c7 44 24 0c f4 14 80 	movl   $0x8014f4,0xc(%esp)
  8010a9:	00 
  8010aa:	c7 44 24 08 0b 15 80 	movl   $0x80150b,0x8(%esp)
  8010b1:	00 
  8010b2:	c7 44 24 04 17 00 00 	movl   $0x17,0x4(%esp)
  8010b9:	00 
  8010ba:	c7 04 24 97 14 80 00 	movl   $0x801497,(%esp)
  8010c1:	e8 5a ef ff ff       	call   800020 <__panic>
    cprintf("kill returns %d\n", ret);
  8010c6:	8b 44 24 18          	mov    0x18(%esp),%eax
  8010ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010ce:	c7 04 24 20 15 80 00 	movl   $0x801520,(%esp)
  8010d5:	e8 70 f2 ff ff       	call   80034a <cprintf>

    assert((ret = waitpid(pid, NULL)) == 0);
  8010da:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010e1:	00 
  8010e2:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8010e6:	89 04 24             	mov    %eax,(%esp)
  8010e9:	e8 73 f1 ff ff       	call   800261 <waitpid>
  8010ee:	89 44 24 18          	mov    %eax,0x18(%esp)
  8010f2:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
  8010f7:	74 24                	je     80111d <main+0x10f>
  8010f9:	c7 44 24 0c 34 15 80 	movl   $0x801534,0xc(%esp)
  801100:	00 
  801101:	c7 44 24 08 0b 15 80 	movl   $0x80150b,0x8(%esp)
  801108:	00 
  801109:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  801110:	00 
  801111:	c7 04 24 97 14 80 00 	movl   $0x801497,(%esp)
  801118:	e8 03 ef ff ff       	call   800020 <__panic>
    cprintf("wait returns %d\n", ret);
  80111d:	8b 44 24 18          	mov    0x18(%esp),%eax
  801121:	89 44 24 04          	mov    %eax,0x4(%esp)
  801125:	c7 04 24 54 15 80 00 	movl   $0x801554,(%esp)
  80112c:	e8 19 f2 ff ff       	call   80034a <cprintf>

    cprintf("spin may pass.\n");
  801131:	c7 04 24 65 15 80 00 	movl   $0x801565,(%esp)
  801138:	e8 0d f2 ff ff       	call   80034a <cprintf>
    return 0;
  80113d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801142:	c9                   	leave  
  801143:	c3                   	ret    
