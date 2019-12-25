
obj/__user_faultreadkernel.out:     file format elf32-i386


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
  80003a:	c7 04 24 e0 0f 80 00 	movl   $0x800fe0,(%esp)
  800041:	e8 87 02 00 00       	call   8002cd <cprintf>
    vcprintf(fmt, ap);
  800046:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800049:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004d:	8b 45 10             	mov    0x10(%ebp),%eax
  800050:	89 04 24             	mov    %eax,(%esp)
  800053:	e8 42 02 00 00       	call   80029a <vcprintf>
    cprintf("\n");
  800058:	c7 04 24 fa 0f 80 00 	movl   $0x800ffa,(%esp)
  80005f:	e8 69 02 00 00       	call   8002cd <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800064:	c7 04 24 f6 ff ff ff 	movl   $0xfffffff6,(%esp)
  80006b:	e8 5f 01 00 00       	call   8001cf <exit>

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
  80008a:	c7 04 24 fc 0f 80 00 	movl   $0x800ffc,(%esp)
  800091:	e8 37 02 00 00       	call   8002cd <cprintf>
    vcprintf(fmt, ap);
  800096:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800099:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009d:	8b 45 10             	mov    0x10(%ebp),%eax
  8000a0:	89 04 24             	mov    %eax,(%esp)
  8000a3:	e8 f2 01 00 00       	call   80029a <vcprintf>
    cprintf("\n");
  8000a8:	c7 04 24 fa 0f 80 00 	movl   $0x800ffa,(%esp)
  8000af:	e8 19 02 00 00       	call   8002cd <cprintf>
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

008001cf <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8001cf:	55                   	push   %ebp
  8001d0:	89 e5                	mov    %esp,%ebp
  8001d2:	83 ec 18             	sub    $0x18,%esp
    sys_exit(error_code);
  8001d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d8:	89 04 24             	mov    %eax,(%esp)
  8001db:	e8 2c ff ff ff       	call   80010c <sys_exit>
    cprintf("BUG: exit failed.\n");
  8001e0:	c7 04 24 18 10 80 00 	movl   $0x801018,(%esp)
  8001e7:	e8 e1 00 00 00       	call   8002cd <cprintf>
    while (1);
  8001ec:	eb fe                	jmp    8001ec <exit+0x1d>

008001ee <fork>:
}

int
fork(void) {
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	83 ec 08             	sub    $0x8,%esp
    return sys_fork();
  8001f4:	e8 2e ff ff ff       	call   800127 <sys_fork>
}
  8001f9:	c9                   	leave  
  8001fa:	c3                   	ret    

008001fb <wait>:

int
wait(void) {
  8001fb:	55                   	push   %ebp
  8001fc:	89 e5                	mov    %esp,%ebp
  8001fe:	83 ec 18             	sub    $0x18,%esp
    return sys_wait(0, NULL);
  800201:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800208:	00 
  800209:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800210:	e8 26 ff ff ff       	call   80013b <sys_wait>
}
  800215:	c9                   	leave  
  800216:	c3                   	ret    

00800217 <waitpid>:

int
waitpid(int pid, int *store) {
  800217:	55                   	push   %ebp
  800218:	89 e5                	mov    %esp,%ebp
  80021a:	83 ec 18             	sub    $0x18,%esp
    return sys_wait(pid, store);
  80021d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800220:	89 44 24 04          	mov    %eax,0x4(%esp)
  800224:	8b 45 08             	mov    0x8(%ebp),%eax
  800227:	89 04 24             	mov    %eax,(%esp)
  80022a:	e8 0c ff ff ff       	call   80013b <sys_wait>
}
  80022f:	c9                   	leave  
  800230:	c3                   	ret    

00800231 <yield>:

void
yield(void) {
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	83 ec 08             	sub    $0x8,%esp
    sys_yield();
  800237:	e8 21 ff ff ff       	call   80015d <sys_yield>
}
  80023c:	c9                   	leave  
  80023d:	c3                   	ret    

0080023e <kill>:

int
kill(int pid) {
  80023e:	55                   	push   %ebp
  80023f:	89 e5                	mov    %esp,%ebp
  800241:	83 ec 18             	sub    $0x18,%esp
    return sys_kill(pid);
  800244:	8b 45 08             	mov    0x8(%ebp),%eax
  800247:	89 04 24             	mov    %eax,(%esp)
  80024a:	e8 22 ff ff ff       	call   800171 <sys_kill>
}
  80024f:	c9                   	leave  
  800250:	c3                   	ret    

00800251 <getpid>:

int
getpid(void) {
  800251:	55                   	push   %ebp
  800252:	89 e5                	mov    %esp,%ebp
  800254:	83 ec 08             	sub    $0x8,%esp
    return sys_getpid();
  800257:	e8 30 ff ff ff       	call   80018c <sys_getpid>
}
  80025c:	c9                   	leave  
  80025d:	c3                   	ret    

0080025e <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	83 ec 08             	sub    $0x8,%esp
    sys_pgdir();
  800264:	e8 52 ff ff ff       	call   8001bb <sys_pgdir>
}
  800269:	c9                   	leave  
  80026a:	c3                   	ret    

0080026b <_start>:
.text
.globl _start
_start:
    # set ebp for backtrace
    movl $0x0, %ebp
  80026b:	bd 00 00 00 00       	mov    $0x0,%ebp

    # move down the esp register
    # since it may cause page fault in backtrace
    subl $0x20, %esp
  800270:	83 ec 20             	sub    $0x20,%esp

    # call user-program function
    call umain
  800273:	e8 ca 00 00 00       	call   800342 <umain>
1:  jmp 1b
  800278:	eb fe                	jmp    800278 <_start+0xd>

0080027a <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  80027a:	55                   	push   %ebp
  80027b:	89 e5                	mov    %esp,%ebp
  80027d:	83 ec 18             	sub    $0x18,%esp
    sys_putc(c);
  800280:	8b 45 08             	mov    0x8(%ebp),%eax
  800283:	89 04 24             	mov    %eax,(%esp)
  800286:	e8 15 ff ff ff       	call   8001a0 <sys_putc>
    (*cnt) ++;
  80028b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80028e:	8b 00                	mov    (%eax),%eax
  800290:	8d 50 01             	lea    0x1(%eax),%edx
  800293:	8b 45 0c             	mov    0xc(%ebp),%eax
  800296:	89 10                	mov    %edx,(%eax)
}
  800298:	c9                   	leave  
  800299:	c3                   	ret    

0080029a <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  80029a:	55                   	push   %ebp
  80029b:	89 e5                	mov    %esp,%ebp
  80029d:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  8002a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8002a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8002b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002bc:	c7 04 24 7a 02 80 00 	movl   $0x80027a,(%esp)
  8002c3:	e8 14 07 00 00       	call   8009dc <vprintfmt>
    return cnt;
  8002c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8002cb:	c9                   	leave  
  8002cc:	c3                   	ret    

008002cd <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  8002cd:	55                   	push   %ebp
  8002ce:	89 e5                	mov    %esp,%ebp
  8002d0:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  8002d3:	8d 45 0c             	lea    0xc(%ebp),%eax
  8002d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int cnt = vcprintf(fmt, ap);
  8002d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8002dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e3:	89 04 24             	mov    %eax,(%esp)
  8002e6:	e8 af ff ff ff       	call   80029a <vcprintf>
  8002eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);

    return cnt;
  8002ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8002f1:	c9                   	leave  
  8002f2:	c3                   	ret    

008002f3 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  8002f9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  800300:	eb 13                	jmp    800315 <cputs+0x22>
        cputch(c, &cnt);
  800302:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  800306:	8d 55 f0             	lea    -0x10(%ebp),%edx
  800309:	89 54 24 04          	mov    %edx,0x4(%esp)
  80030d:	89 04 24             	mov    %eax,(%esp)
  800310:	e8 65 ff ff ff       	call   80027a <cputch>
    while ((c = *str ++) != '\0') {
  800315:	8b 45 08             	mov    0x8(%ebp),%eax
  800318:	8d 50 01             	lea    0x1(%eax),%edx
  80031b:	89 55 08             	mov    %edx,0x8(%ebp)
  80031e:	0f b6 00             	movzbl (%eax),%eax
  800321:	88 45 f7             	mov    %al,-0x9(%ebp)
  800324:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  800328:	75 d8                	jne    800302 <cputs+0xf>
    }
    cputch('\n', &cnt);
  80032a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80032d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800331:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800338:	e8 3d ff ff ff       	call   80027a <cputch>
    return cnt;
  80033d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800340:	c9                   	leave  
  800341:	c3                   	ret    

00800342 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
  800345:	83 ec 28             	sub    $0x28,%esp
    int ret = main();
  800348:	e8 44 0c 00 00       	call   800f91 <main>
  80034d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    exit(ret);
  800350:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800353:	89 04 24             	mov    %eax,(%esp)
  800356:	e8 74 fe ff ff       	call   8001cf <exit>

0080035b <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
  80035e:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  800361:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  800368:	eb 04                	jmp    80036e <strlen+0x13>
        cnt ++;
  80036a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (*s ++ != '\0') {
  80036e:	8b 45 08             	mov    0x8(%ebp),%eax
  800371:	8d 50 01             	lea    0x1(%eax),%edx
  800374:	89 55 08             	mov    %edx,0x8(%ebp)
  800377:	0f b6 00             	movzbl (%eax),%eax
  80037a:	84 c0                	test   %al,%al
  80037c:	75 ec                	jne    80036a <strlen+0xf>
    }
    return cnt;
  80037e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800381:	c9                   	leave  
  800382:	c3                   	ret    

00800383 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  800383:	55                   	push   %ebp
  800384:	89 e5                	mov    %esp,%ebp
  800386:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  800389:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  800390:	eb 04                	jmp    800396 <strnlen+0x13>
        cnt ++;
  800392:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  800396:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800399:	3b 45 0c             	cmp    0xc(%ebp),%eax
  80039c:	73 10                	jae    8003ae <strnlen+0x2b>
  80039e:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a1:	8d 50 01             	lea    0x1(%eax),%edx
  8003a4:	89 55 08             	mov    %edx,0x8(%ebp)
  8003a7:	0f b6 00             	movzbl (%eax),%eax
  8003aa:	84 c0                	test   %al,%al
  8003ac:	75 e4                	jne    800392 <strnlen+0xf>
    }
    return cnt;
  8003ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8003b1:	c9                   	leave  
  8003b2:	c3                   	ret    

008003b3 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  8003b3:	55                   	push   %ebp
  8003b4:	89 e5                	mov    %esp,%ebp
  8003b6:	57                   	push   %edi
  8003b7:	56                   	push   %esi
  8003b8:	83 ec 20             	sub    $0x20,%esp
  8003bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8003be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8003c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  8003c7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8003ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003cd:	89 d1                	mov    %edx,%ecx
  8003cf:	89 c2                	mov    %eax,%edx
  8003d1:	89 ce                	mov    %ecx,%esi
  8003d3:	89 d7                	mov    %edx,%edi
  8003d5:	ac                   	lods   %ds:(%esi),%al
  8003d6:	aa                   	stos   %al,%es:(%edi)
  8003d7:	84 c0                	test   %al,%al
  8003d9:	75 fa                	jne    8003d5 <strcpy+0x22>
  8003db:	89 fa                	mov    %edi,%edx
  8003dd:	89 f1                	mov    %esi,%ecx
  8003df:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  8003e2:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8003e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  8003e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  8003eb:	83 c4 20             	add    $0x20,%esp
  8003ee:	5e                   	pop    %esi
  8003ef:	5f                   	pop    %edi
  8003f0:	5d                   	pop    %ebp
  8003f1:	c3                   	ret    

008003f2 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  8003f2:	55                   	push   %ebp
  8003f3:	89 e5                	mov    %esp,%ebp
  8003f5:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  8003f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fb:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  8003fe:	eb 21                	jmp    800421 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
  800400:	8b 45 0c             	mov    0xc(%ebp),%eax
  800403:	0f b6 10             	movzbl (%eax),%edx
  800406:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800409:	88 10                	mov    %dl,(%eax)
  80040b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80040e:	0f b6 00             	movzbl (%eax),%eax
  800411:	84 c0                	test   %al,%al
  800413:	74 04                	je     800419 <strncpy+0x27>
            src ++;
  800415:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
  800419:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  80041d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    while (len > 0) {
  800421:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800425:	75 d9                	jne    800400 <strncpy+0xe>
    }
    return dst;
  800427:	8b 45 08             	mov    0x8(%ebp),%eax
}
  80042a:	c9                   	leave  
  80042b:	c3                   	ret    

0080042c <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  80042c:	55                   	push   %ebp
  80042d:	89 e5                	mov    %esp,%ebp
  80042f:	57                   	push   %edi
  800430:	56                   	push   %esi
  800431:	83 ec 20             	sub    $0x20,%esp
  800434:	8b 45 08             	mov    0x8(%ebp),%eax
  800437:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80043a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80043d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  800440:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800443:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800446:	89 d1                	mov    %edx,%ecx
  800448:	89 c2                	mov    %eax,%edx
  80044a:	89 ce                	mov    %ecx,%esi
  80044c:	89 d7                	mov    %edx,%edi
  80044e:	ac                   	lods   %ds:(%esi),%al
  80044f:	ae                   	scas   %es:(%edi),%al
  800450:	75 08                	jne    80045a <strcmp+0x2e>
  800452:	84 c0                	test   %al,%al
  800454:	75 f8                	jne    80044e <strcmp+0x22>
  800456:	31 c0                	xor    %eax,%eax
  800458:	eb 04                	jmp    80045e <strcmp+0x32>
  80045a:	19 c0                	sbb    %eax,%eax
  80045c:	0c 01                	or     $0x1,%al
  80045e:	89 fa                	mov    %edi,%edx
  800460:	89 f1                	mov    %esi,%ecx
  800462:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800465:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  800468:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  80046b:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  80046e:	83 c4 20             	add    $0x20,%esp
  800471:	5e                   	pop    %esi
  800472:	5f                   	pop    %edi
  800473:	5d                   	pop    %ebp
  800474:	c3                   	ret    

00800475 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  800475:	55                   	push   %ebp
  800476:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  800478:	eb 0c                	jmp    800486 <strncmp+0x11>
        n --, s1 ++, s2 ++;
  80047a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  80047e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800482:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  800486:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80048a:	74 1a                	je     8004a6 <strncmp+0x31>
  80048c:	8b 45 08             	mov    0x8(%ebp),%eax
  80048f:	0f b6 00             	movzbl (%eax),%eax
  800492:	84 c0                	test   %al,%al
  800494:	74 10                	je     8004a6 <strncmp+0x31>
  800496:	8b 45 08             	mov    0x8(%ebp),%eax
  800499:	0f b6 10             	movzbl (%eax),%edx
  80049c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80049f:	0f b6 00             	movzbl (%eax),%eax
  8004a2:	38 c2                	cmp    %al,%dl
  8004a4:	74 d4                	je     80047a <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  8004a6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8004aa:	74 18                	je     8004c4 <strncmp+0x4f>
  8004ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8004af:	0f b6 00             	movzbl (%eax),%eax
  8004b2:	0f b6 d0             	movzbl %al,%edx
  8004b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b8:	0f b6 00             	movzbl (%eax),%eax
  8004bb:	0f b6 c0             	movzbl %al,%eax
  8004be:	29 c2                	sub    %eax,%edx
  8004c0:	89 d0                	mov    %edx,%eax
  8004c2:	eb 05                	jmp    8004c9 <strncmp+0x54>
  8004c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8004c9:	5d                   	pop    %ebp
  8004ca:	c3                   	ret    

008004cb <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  8004cb:	55                   	push   %ebp
  8004cc:	89 e5                	mov    %esp,%ebp
  8004ce:	83 ec 04             	sub    $0x4,%esp
  8004d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004d4:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  8004d7:	eb 14                	jmp    8004ed <strchr+0x22>
        if (*s == c) {
  8004d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004dc:	0f b6 00             	movzbl (%eax),%eax
  8004df:	3a 45 fc             	cmp    -0x4(%ebp),%al
  8004e2:	75 05                	jne    8004e9 <strchr+0x1e>
            return (char *)s;
  8004e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e7:	eb 13                	jmp    8004fc <strchr+0x31>
        }
        s ++;
  8004e9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
  8004ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f0:	0f b6 00             	movzbl (%eax),%eax
  8004f3:	84 c0                	test   %al,%al
  8004f5:	75 e2                	jne    8004d9 <strchr+0xe>
    }
    return NULL;
  8004f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8004fc:	c9                   	leave  
  8004fd:	c3                   	ret    

008004fe <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  8004fe:	55                   	push   %ebp
  8004ff:	89 e5                	mov    %esp,%ebp
  800501:	83 ec 04             	sub    $0x4,%esp
  800504:	8b 45 0c             	mov    0xc(%ebp),%eax
  800507:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  80050a:	eb 11                	jmp    80051d <strfind+0x1f>
        if (*s == c) {
  80050c:	8b 45 08             	mov    0x8(%ebp),%eax
  80050f:	0f b6 00             	movzbl (%eax),%eax
  800512:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800515:	75 02                	jne    800519 <strfind+0x1b>
            break;
  800517:	eb 0e                	jmp    800527 <strfind+0x29>
        }
        s ++;
  800519:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
  80051d:	8b 45 08             	mov    0x8(%ebp),%eax
  800520:	0f b6 00             	movzbl (%eax),%eax
  800523:	84 c0                	test   %al,%al
  800525:	75 e5                	jne    80050c <strfind+0xe>
    }
    return (char *)s;
  800527:	8b 45 08             	mov    0x8(%ebp),%eax
}
  80052a:	c9                   	leave  
  80052b:	c3                   	ret    

0080052c <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  80052c:	55                   	push   %ebp
  80052d:	89 e5                	mov    %esp,%ebp
  80052f:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  800532:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  800539:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  800540:	eb 04                	jmp    800546 <strtol+0x1a>
        s ++;
  800542:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  800546:	8b 45 08             	mov    0x8(%ebp),%eax
  800549:	0f b6 00             	movzbl (%eax),%eax
  80054c:	3c 20                	cmp    $0x20,%al
  80054e:	74 f2                	je     800542 <strtol+0x16>
  800550:	8b 45 08             	mov    0x8(%ebp),%eax
  800553:	0f b6 00             	movzbl (%eax),%eax
  800556:	3c 09                	cmp    $0x9,%al
  800558:	74 e8                	je     800542 <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
  80055a:	8b 45 08             	mov    0x8(%ebp),%eax
  80055d:	0f b6 00             	movzbl (%eax),%eax
  800560:	3c 2b                	cmp    $0x2b,%al
  800562:	75 06                	jne    80056a <strtol+0x3e>
        s ++;
  800564:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800568:	eb 15                	jmp    80057f <strtol+0x53>
    }
    else if (*s == '-') {
  80056a:	8b 45 08             	mov    0x8(%ebp),%eax
  80056d:	0f b6 00             	movzbl (%eax),%eax
  800570:	3c 2d                	cmp    $0x2d,%al
  800572:	75 0b                	jne    80057f <strtol+0x53>
        s ++, neg = 1;
  800574:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800578:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  80057f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800583:	74 06                	je     80058b <strtol+0x5f>
  800585:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800589:	75 24                	jne    8005af <strtol+0x83>
  80058b:	8b 45 08             	mov    0x8(%ebp),%eax
  80058e:	0f b6 00             	movzbl (%eax),%eax
  800591:	3c 30                	cmp    $0x30,%al
  800593:	75 1a                	jne    8005af <strtol+0x83>
  800595:	8b 45 08             	mov    0x8(%ebp),%eax
  800598:	83 c0 01             	add    $0x1,%eax
  80059b:	0f b6 00             	movzbl (%eax),%eax
  80059e:	3c 78                	cmp    $0x78,%al
  8005a0:	75 0d                	jne    8005af <strtol+0x83>
        s += 2, base = 16;
  8005a2:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  8005a6:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8005ad:	eb 2a                	jmp    8005d9 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
  8005af:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8005b3:	75 17                	jne    8005cc <strtol+0xa0>
  8005b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b8:	0f b6 00             	movzbl (%eax),%eax
  8005bb:	3c 30                	cmp    $0x30,%al
  8005bd:	75 0d                	jne    8005cc <strtol+0xa0>
        s ++, base = 8;
  8005bf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8005c3:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  8005ca:	eb 0d                	jmp    8005d9 <strtol+0xad>
    }
    else if (base == 0) {
  8005cc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8005d0:	75 07                	jne    8005d9 <strtol+0xad>
        base = 10;
  8005d2:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  8005d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8005dc:	0f b6 00             	movzbl (%eax),%eax
  8005df:	3c 2f                	cmp    $0x2f,%al
  8005e1:	7e 1b                	jle    8005fe <strtol+0xd2>
  8005e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e6:	0f b6 00             	movzbl (%eax),%eax
  8005e9:	3c 39                	cmp    $0x39,%al
  8005eb:	7f 11                	jg     8005fe <strtol+0xd2>
            dig = *s - '0';
  8005ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f0:	0f b6 00             	movzbl (%eax),%eax
  8005f3:	0f be c0             	movsbl %al,%eax
  8005f6:	83 e8 30             	sub    $0x30,%eax
  8005f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8005fc:	eb 48                	jmp    800646 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
  8005fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800601:	0f b6 00             	movzbl (%eax),%eax
  800604:	3c 60                	cmp    $0x60,%al
  800606:	7e 1b                	jle    800623 <strtol+0xf7>
  800608:	8b 45 08             	mov    0x8(%ebp),%eax
  80060b:	0f b6 00             	movzbl (%eax),%eax
  80060e:	3c 7a                	cmp    $0x7a,%al
  800610:	7f 11                	jg     800623 <strtol+0xf7>
            dig = *s - 'a' + 10;
  800612:	8b 45 08             	mov    0x8(%ebp),%eax
  800615:	0f b6 00             	movzbl (%eax),%eax
  800618:	0f be c0             	movsbl %al,%eax
  80061b:	83 e8 57             	sub    $0x57,%eax
  80061e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800621:	eb 23                	jmp    800646 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  800623:	8b 45 08             	mov    0x8(%ebp),%eax
  800626:	0f b6 00             	movzbl (%eax),%eax
  800629:	3c 40                	cmp    $0x40,%al
  80062b:	7e 3d                	jle    80066a <strtol+0x13e>
  80062d:	8b 45 08             	mov    0x8(%ebp),%eax
  800630:	0f b6 00             	movzbl (%eax),%eax
  800633:	3c 5a                	cmp    $0x5a,%al
  800635:	7f 33                	jg     80066a <strtol+0x13e>
            dig = *s - 'A' + 10;
  800637:	8b 45 08             	mov    0x8(%ebp),%eax
  80063a:	0f b6 00             	movzbl (%eax),%eax
  80063d:	0f be c0             	movsbl %al,%eax
  800640:	83 e8 37             	sub    $0x37,%eax
  800643:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  800646:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800649:	3b 45 10             	cmp    0x10(%ebp),%eax
  80064c:	7c 02                	jl     800650 <strtol+0x124>
            break;
  80064e:	eb 1a                	jmp    80066a <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
  800650:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800654:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800657:	0f af 45 10          	imul   0x10(%ebp),%eax
  80065b:	89 c2                	mov    %eax,%edx
  80065d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800660:	01 d0                	add    %edx,%eax
  800662:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
  800665:	e9 6f ff ff ff       	jmp    8005d9 <strtol+0xad>

    if (endptr) {
  80066a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80066e:	74 08                	je     800678 <strtol+0x14c>
        *endptr = (char *) s;
  800670:	8b 45 0c             	mov    0xc(%ebp),%eax
  800673:	8b 55 08             	mov    0x8(%ebp),%edx
  800676:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  800678:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  80067c:	74 07                	je     800685 <strtol+0x159>
  80067e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800681:	f7 d8                	neg    %eax
  800683:	eb 03                	jmp    800688 <strtol+0x15c>
  800685:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800688:	c9                   	leave  
  800689:	c3                   	ret    

0080068a <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  80068a:	55                   	push   %ebp
  80068b:	89 e5                	mov    %esp,%ebp
  80068d:	57                   	push   %edi
  80068e:	83 ec 24             	sub    $0x24,%esp
  800691:	8b 45 0c             	mov    0xc(%ebp),%eax
  800694:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  800697:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80069b:	8b 55 08             	mov    0x8(%ebp),%edx
  80069e:	89 55 f8             	mov    %edx,-0x8(%ebp)
  8006a1:	88 45 f7             	mov    %al,-0x9(%ebp)
  8006a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8006a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  8006aa:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8006ad:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8006b1:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8006b4:	89 d7                	mov    %edx,%edi
  8006b6:	f3 aa                	rep stos %al,%es:(%edi)
  8006b8:	89 fa                	mov    %edi,%edx
  8006ba:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  8006bd:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  8006c0:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  8006c3:	83 c4 24             	add    $0x24,%esp
  8006c6:	5f                   	pop    %edi
  8006c7:	5d                   	pop    %ebp
  8006c8:	c3                   	ret    

008006c9 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  8006c9:	55                   	push   %ebp
  8006ca:	89 e5                	mov    %esp,%ebp
  8006cc:	57                   	push   %edi
  8006cd:	56                   	push   %esi
  8006ce:	53                   	push   %ebx
  8006cf:	83 ec 30             	sub    $0x30,%esp
  8006d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006db:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006de:	8b 45 10             	mov    0x10(%ebp),%eax
  8006e1:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  8006e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006e7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  8006ea:	73 42                	jae    80072e <memmove+0x65>
  8006ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006fb:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  8006fe:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800701:	c1 e8 02             	shr    $0x2,%eax
  800704:	89 c1                	mov    %eax,%ecx
    asm volatile (
  800706:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800709:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80070c:	89 d7                	mov    %edx,%edi
  80070e:	89 c6                	mov    %eax,%esi
  800710:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800712:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800715:	83 e1 03             	and    $0x3,%ecx
  800718:	74 02                	je     80071c <memmove+0x53>
  80071a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  80071c:	89 f0                	mov    %esi,%eax
  80071e:	89 fa                	mov    %edi,%edx
  800720:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800723:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800726:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
  800729:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80072c:	eb 36                	jmp    800764 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  80072e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800731:	8d 50 ff             	lea    -0x1(%eax),%edx
  800734:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800737:	01 c2                	add    %eax,%edx
  800739:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80073c:	8d 48 ff             	lea    -0x1(%eax),%ecx
  80073f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800742:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  800745:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800748:	89 c1                	mov    %eax,%ecx
  80074a:	89 d8                	mov    %ebx,%eax
  80074c:	89 d6                	mov    %edx,%esi
  80074e:	89 c7                	mov    %eax,%edi
  800750:	fd                   	std    
  800751:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  800753:	fc                   	cld    
  800754:	89 f8                	mov    %edi,%eax
  800756:	89 f2                	mov    %esi,%edx
  800758:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80075b:	89 55 c8             	mov    %edx,-0x38(%ebp)
  80075e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  800761:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  800764:	83 c4 30             	add    $0x30,%esp
  800767:	5b                   	pop    %ebx
  800768:	5e                   	pop    %esi
  800769:	5f                   	pop    %edi
  80076a:	5d                   	pop    %ebp
  80076b:	c3                   	ret    

0080076c <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
  80076f:	57                   	push   %edi
  800770:	56                   	push   %esi
  800771:	83 ec 20             	sub    $0x20,%esp
  800774:	8b 45 08             	mov    0x8(%ebp),%eax
  800777:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80077a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80077d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800780:	8b 45 10             	mov    0x10(%ebp),%eax
  800783:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  800786:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800789:	c1 e8 02             	shr    $0x2,%eax
  80078c:	89 c1                	mov    %eax,%ecx
    asm volatile (
  80078e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800791:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800794:	89 d7                	mov    %edx,%edi
  800796:	89 c6                	mov    %eax,%esi
  800798:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80079a:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  80079d:	83 e1 03             	and    $0x3,%ecx
  8007a0:	74 02                	je     8007a4 <memcpy+0x38>
  8007a2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  8007a4:	89 f0                	mov    %esi,%eax
  8007a6:	89 fa                	mov    %edi,%edx
  8007a8:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  8007ab:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  8007b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  8007b4:	83 c4 20             	add    $0x20,%esp
  8007b7:	5e                   	pop    %esi
  8007b8:	5f                   	pop    %edi
  8007b9:	5d                   	pop    %ebp
  8007ba:	c3                   	ret    

008007bb <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  8007c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c4:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  8007c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ca:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  8007cd:	eb 30                	jmp    8007ff <memcmp+0x44>
        if (*s1 != *s2) {
  8007cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007d2:	0f b6 10             	movzbl (%eax),%edx
  8007d5:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8007d8:	0f b6 00             	movzbl (%eax),%eax
  8007db:	38 c2                	cmp    %al,%dl
  8007dd:	74 18                	je     8007f7 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  8007df:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007e2:	0f b6 00             	movzbl (%eax),%eax
  8007e5:	0f b6 d0             	movzbl %al,%edx
  8007e8:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8007eb:	0f b6 00             	movzbl (%eax),%eax
  8007ee:	0f b6 c0             	movzbl %al,%eax
  8007f1:	29 c2                	sub    %eax,%edx
  8007f3:	89 d0                	mov    %edx,%eax
  8007f5:	eb 1a                	jmp    800811 <memcmp+0x56>
        }
        s1 ++, s2 ++;
  8007f7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  8007fb:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
    while (n -- > 0) {
  8007ff:	8b 45 10             	mov    0x10(%ebp),%eax
  800802:	8d 50 ff             	lea    -0x1(%eax),%edx
  800805:	89 55 10             	mov    %edx,0x10(%ebp)
  800808:	85 c0                	test   %eax,%eax
  80080a:	75 c3                	jne    8007cf <memcmp+0x14>
    }
    return 0;
  80080c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800811:	c9                   	leave  
  800812:	c3                   	ret    

00800813 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
  800816:	83 ec 58             	sub    $0x58,%esp
  800819:	8b 45 10             	mov    0x10(%ebp),%eax
  80081c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80081f:	8b 45 14             	mov    0x14(%ebp),%eax
  800822:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  800825:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800828:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80082b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  80082e:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  800831:	8b 45 18             	mov    0x18(%ebp),%eax
  800834:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800837:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80083a:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80083d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800840:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800843:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800846:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800849:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80084d:	74 1c                	je     80086b <printnum+0x58>
  80084f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800852:	ba 00 00 00 00       	mov    $0x0,%edx
  800857:	f7 75 e4             	divl   -0x1c(%ebp)
  80085a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80085d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800860:	ba 00 00 00 00       	mov    $0x0,%edx
  800865:	f7 75 e4             	divl   -0x1c(%ebp)
  800868:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80086b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80086e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800871:	f7 75 e4             	divl   -0x1c(%ebp)
  800874:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800877:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80087a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80087d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800880:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800883:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800886:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800889:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  80088c:	8b 45 18             	mov    0x18(%ebp),%eax
  80088f:	ba 00 00 00 00       	mov    $0x0,%edx
  800894:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  800897:	77 56                	ja     8008ef <printnum+0xdc>
  800899:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  80089c:	72 05                	jb     8008a3 <printnum+0x90>
  80089e:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  8008a1:	77 4c                	ja     8008ef <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  8008a3:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8008a6:	8d 50 ff             	lea    -0x1(%eax),%edx
  8008a9:	8b 45 20             	mov    0x20(%ebp),%eax
  8008ac:	89 44 24 18          	mov    %eax,0x18(%esp)
  8008b0:	89 54 24 14          	mov    %edx,0x14(%esp)
  8008b4:	8b 45 18             	mov    0x18(%ebp),%eax
  8008b7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8008bb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8008be:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8008c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008c5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d3:	89 04 24             	mov    %eax,(%esp)
  8008d6:	e8 38 ff ff ff       	call   800813 <printnum>
  8008db:	eb 1c                	jmp    8008f9 <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  8008dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e4:	8b 45 20             	mov    0x20(%ebp),%eax
  8008e7:	89 04 24             	mov    %eax,(%esp)
  8008ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ed:	ff d0                	call   *%eax
        while (-- width > 0)
  8008ef:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  8008f3:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  8008f7:	7f e4                	jg     8008dd <printnum+0xca>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  8008f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008fc:	05 44 11 80 00       	add    $0x801144,%eax
  800901:	0f b6 00             	movzbl (%eax),%eax
  800904:	0f be c0             	movsbl %al,%eax
  800907:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80090e:	89 04 24             	mov    %eax,(%esp)
  800911:	8b 45 08             	mov    0x8(%ebp),%eax
  800914:	ff d0                	call   *%eax
}
  800916:	c9                   	leave  
  800917:	c3                   	ret    

00800918 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  80091b:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80091f:	7e 14                	jle    800935 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  800921:	8b 45 08             	mov    0x8(%ebp),%eax
  800924:	8b 00                	mov    (%eax),%eax
  800926:	8d 48 08             	lea    0x8(%eax),%ecx
  800929:	8b 55 08             	mov    0x8(%ebp),%edx
  80092c:	89 0a                	mov    %ecx,(%edx)
  80092e:	8b 50 04             	mov    0x4(%eax),%edx
  800931:	8b 00                	mov    (%eax),%eax
  800933:	eb 30                	jmp    800965 <getuint+0x4d>
    }
    else if (lflag) {
  800935:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800939:	74 16                	je     800951 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  80093b:	8b 45 08             	mov    0x8(%ebp),%eax
  80093e:	8b 00                	mov    (%eax),%eax
  800940:	8d 48 04             	lea    0x4(%eax),%ecx
  800943:	8b 55 08             	mov    0x8(%ebp),%edx
  800946:	89 0a                	mov    %ecx,(%edx)
  800948:	8b 00                	mov    (%eax),%eax
  80094a:	ba 00 00 00 00       	mov    $0x0,%edx
  80094f:	eb 14                	jmp    800965 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  800951:	8b 45 08             	mov    0x8(%ebp),%eax
  800954:	8b 00                	mov    (%eax),%eax
  800956:	8d 48 04             	lea    0x4(%eax),%ecx
  800959:	8b 55 08             	mov    0x8(%ebp),%edx
  80095c:	89 0a                	mov    %ecx,(%edx)
  80095e:	8b 00                	mov    (%eax),%eax
  800960:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  800965:	5d                   	pop    %ebp
  800966:	c3                   	ret    

00800967 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  80096a:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80096e:	7e 14                	jle    800984 <getint+0x1d>
        return va_arg(*ap, long long);
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	8b 00                	mov    (%eax),%eax
  800975:	8d 48 08             	lea    0x8(%eax),%ecx
  800978:	8b 55 08             	mov    0x8(%ebp),%edx
  80097b:	89 0a                	mov    %ecx,(%edx)
  80097d:	8b 50 04             	mov    0x4(%eax),%edx
  800980:	8b 00                	mov    (%eax),%eax
  800982:	eb 28                	jmp    8009ac <getint+0x45>
    }
    else if (lflag) {
  800984:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800988:	74 12                	je     80099c <getint+0x35>
        return va_arg(*ap, long);
  80098a:	8b 45 08             	mov    0x8(%ebp),%eax
  80098d:	8b 00                	mov    (%eax),%eax
  80098f:	8d 48 04             	lea    0x4(%eax),%ecx
  800992:	8b 55 08             	mov    0x8(%ebp),%edx
  800995:	89 0a                	mov    %ecx,(%edx)
  800997:	8b 00                	mov    (%eax),%eax
  800999:	99                   	cltd   
  80099a:	eb 10                	jmp    8009ac <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  80099c:	8b 45 08             	mov    0x8(%ebp),%eax
  80099f:	8b 00                	mov    (%eax),%eax
  8009a1:	8d 48 04             	lea    0x4(%eax),%ecx
  8009a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8009a7:	89 0a                	mov    %ecx,(%edx)
  8009a9:	8b 00                	mov    (%eax),%eax
  8009ab:	99                   	cltd   
    }
}
  8009ac:	5d                   	pop    %ebp
  8009ad:	c3                   	ret    

008009ae <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  8009b4:	8d 45 14             	lea    0x14(%ebp),%eax
  8009b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  8009ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8009c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d2:	89 04 24             	mov    %eax,(%esp)
  8009d5:	e8 02 00 00 00       	call   8009dc <vprintfmt>
    va_end(ap);
}
  8009da:	c9                   	leave  
  8009db:	c3                   	ret    

008009dc <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	56                   	push   %esi
  8009e0:	53                   	push   %ebx
  8009e1:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8009e4:	eb 18                	jmp    8009fe <vprintfmt+0x22>
            if (ch == '\0') {
  8009e6:	85 db                	test   %ebx,%ebx
  8009e8:	75 05                	jne    8009ef <vprintfmt+0x13>
                return;
  8009ea:	e9 d1 03 00 00       	jmp    800dc0 <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
  8009ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f6:	89 1c 24             	mov    %ebx,(%esp)
  8009f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fc:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8009fe:	8b 45 10             	mov    0x10(%ebp),%eax
  800a01:	8d 50 01             	lea    0x1(%eax),%edx
  800a04:	89 55 10             	mov    %edx,0x10(%ebp)
  800a07:	0f b6 00             	movzbl (%eax),%eax
  800a0a:	0f b6 d8             	movzbl %al,%ebx
  800a0d:	83 fb 25             	cmp    $0x25,%ebx
  800a10:	75 d4                	jne    8009e6 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
  800a12:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  800a16:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800a1d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a20:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  800a23:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800a2a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a2d:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800a30:	8b 45 10             	mov    0x10(%ebp),%eax
  800a33:	8d 50 01             	lea    0x1(%eax),%edx
  800a36:	89 55 10             	mov    %edx,0x10(%ebp)
  800a39:	0f b6 00             	movzbl (%eax),%eax
  800a3c:	0f b6 d8             	movzbl %al,%ebx
  800a3f:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800a42:	83 f8 55             	cmp    $0x55,%eax
  800a45:	0f 87 44 03 00 00    	ja     800d8f <vprintfmt+0x3b3>
  800a4b:	8b 04 85 68 11 80 00 	mov    0x801168(,%eax,4),%eax
  800a52:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  800a54:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  800a58:	eb d6                	jmp    800a30 <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  800a5a:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  800a5e:	eb d0                	jmp    800a30 <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  800a60:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  800a67:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a6a:	89 d0                	mov    %edx,%eax
  800a6c:	c1 e0 02             	shl    $0x2,%eax
  800a6f:	01 d0                	add    %edx,%eax
  800a71:	01 c0                	add    %eax,%eax
  800a73:	01 d8                	add    %ebx,%eax
  800a75:	83 e8 30             	sub    $0x30,%eax
  800a78:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  800a7b:	8b 45 10             	mov    0x10(%ebp),%eax
  800a7e:	0f b6 00             	movzbl (%eax),%eax
  800a81:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  800a84:	83 fb 2f             	cmp    $0x2f,%ebx
  800a87:	7e 0b                	jle    800a94 <vprintfmt+0xb8>
  800a89:	83 fb 39             	cmp    $0x39,%ebx
  800a8c:	7f 06                	jg     800a94 <vprintfmt+0xb8>
            for (precision = 0; ; ++ fmt) {
  800a8e:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                    break;
                }
            }
  800a92:	eb d3                	jmp    800a67 <vprintfmt+0x8b>
            goto process_precision;
  800a94:	eb 33                	jmp    800ac9 <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
  800a96:	8b 45 14             	mov    0x14(%ebp),%eax
  800a99:	8d 50 04             	lea    0x4(%eax),%edx
  800a9c:	89 55 14             	mov    %edx,0x14(%ebp)
  800a9f:	8b 00                	mov    (%eax),%eax
  800aa1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  800aa4:	eb 23                	jmp    800ac9 <vprintfmt+0xed>

        case '.':
            if (width < 0)
  800aa6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800aaa:	79 0c                	jns    800ab8 <vprintfmt+0xdc>
                width = 0;
  800aac:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  800ab3:	e9 78 ff ff ff       	jmp    800a30 <vprintfmt+0x54>
  800ab8:	e9 73 ff ff ff       	jmp    800a30 <vprintfmt+0x54>

        case '#':
            altflag = 1;
  800abd:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  800ac4:	e9 67 ff ff ff       	jmp    800a30 <vprintfmt+0x54>

        process_precision:
            if (width < 0)
  800ac9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800acd:	79 12                	jns    800ae1 <vprintfmt+0x105>
                width = precision, precision = -1;
  800acf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ad2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800ad5:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  800adc:	e9 4f ff ff ff       	jmp    800a30 <vprintfmt+0x54>
  800ae1:	e9 4a ff ff ff       	jmp    800a30 <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  800ae6:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
  800aea:	e9 41 ff ff ff       	jmp    800a30 <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  800aef:	8b 45 14             	mov    0x14(%ebp),%eax
  800af2:	8d 50 04             	lea    0x4(%eax),%edx
  800af5:	89 55 14             	mov    %edx,0x14(%ebp)
  800af8:	8b 00                	mov    (%eax),%eax
  800afa:	8b 55 0c             	mov    0xc(%ebp),%edx
  800afd:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b01:	89 04 24             	mov    %eax,(%esp)
  800b04:	8b 45 08             	mov    0x8(%ebp),%eax
  800b07:	ff d0                	call   *%eax
            break;
  800b09:	e9 ac 02 00 00       	jmp    800dba <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
  800b0e:	8b 45 14             	mov    0x14(%ebp),%eax
  800b11:	8d 50 04             	lea    0x4(%eax),%edx
  800b14:	89 55 14             	mov    %edx,0x14(%ebp)
  800b17:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  800b19:	85 db                	test   %ebx,%ebx
  800b1b:	79 02                	jns    800b1f <vprintfmt+0x143>
                err = -err;
  800b1d:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800b1f:	83 fb 18             	cmp    $0x18,%ebx
  800b22:	7f 0b                	jg     800b2f <vprintfmt+0x153>
  800b24:	8b 34 9d e0 10 80 00 	mov    0x8010e0(,%ebx,4),%esi
  800b2b:	85 f6                	test   %esi,%esi
  800b2d:	75 23                	jne    800b52 <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
  800b2f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800b33:	c7 44 24 08 55 11 80 	movl   $0x801155,0x8(%esp)
  800b3a:	00 
  800b3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b42:	8b 45 08             	mov    0x8(%ebp),%eax
  800b45:	89 04 24             	mov    %eax,(%esp)
  800b48:	e8 61 fe ff ff       	call   8009ae <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  800b4d:	e9 68 02 00 00       	jmp    800dba <vprintfmt+0x3de>
                printfmt(putch, putdat, "%s", p);
  800b52:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800b56:	c7 44 24 08 5e 11 80 	movl   $0x80115e,0x8(%esp)
  800b5d:	00 
  800b5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b61:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b65:	8b 45 08             	mov    0x8(%ebp),%eax
  800b68:	89 04 24             	mov    %eax,(%esp)
  800b6b:	e8 3e fe ff ff       	call   8009ae <printfmt>
            break;
  800b70:	e9 45 02 00 00       	jmp    800dba <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  800b75:	8b 45 14             	mov    0x14(%ebp),%eax
  800b78:	8d 50 04             	lea    0x4(%eax),%edx
  800b7b:	89 55 14             	mov    %edx,0x14(%ebp)
  800b7e:	8b 30                	mov    (%eax),%esi
  800b80:	85 f6                	test   %esi,%esi
  800b82:	75 05                	jne    800b89 <vprintfmt+0x1ad>
                p = "(null)";
  800b84:	be 61 11 80 00       	mov    $0x801161,%esi
            }
            if (width > 0 && padc != '-') {
  800b89:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800b8d:	7e 3e                	jle    800bcd <vprintfmt+0x1f1>
  800b8f:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800b93:	74 38                	je     800bcd <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800b95:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  800b98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800b9b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b9f:	89 34 24             	mov    %esi,(%esp)
  800ba2:	e8 dc f7 ff ff       	call   800383 <strnlen>
  800ba7:	29 c3                	sub    %eax,%ebx
  800ba9:	89 d8                	mov    %ebx,%eax
  800bab:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800bae:	eb 17                	jmp    800bc7 <vprintfmt+0x1eb>
                    putch(padc, putdat);
  800bb0:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800bb4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bb7:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bbb:	89 04 24             	mov    %eax,(%esp)
  800bbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc1:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
  800bc3:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  800bc7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800bcb:	7f e3                	jg     800bb0 <vprintfmt+0x1d4>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800bcd:	eb 38                	jmp    800c07 <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
  800bcf:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800bd3:	74 1f                	je     800bf4 <vprintfmt+0x218>
  800bd5:	83 fb 1f             	cmp    $0x1f,%ebx
  800bd8:	7e 05                	jle    800bdf <vprintfmt+0x203>
  800bda:	83 fb 7e             	cmp    $0x7e,%ebx
  800bdd:	7e 15                	jle    800bf4 <vprintfmt+0x218>
                    putch('?', putdat);
  800bdf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800be6:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800bed:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf0:	ff d0                	call   *%eax
  800bf2:	eb 0f                	jmp    800c03 <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
  800bf4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bf7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bfb:	89 1c 24             	mov    %ebx,(%esp)
  800bfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800c01:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800c03:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  800c07:	89 f0                	mov    %esi,%eax
  800c09:	8d 70 01             	lea    0x1(%eax),%esi
  800c0c:	0f b6 00             	movzbl (%eax),%eax
  800c0f:	0f be d8             	movsbl %al,%ebx
  800c12:	85 db                	test   %ebx,%ebx
  800c14:	74 10                	je     800c26 <vprintfmt+0x24a>
  800c16:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c1a:	78 b3                	js     800bcf <vprintfmt+0x1f3>
  800c1c:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800c20:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c24:	79 a9                	jns    800bcf <vprintfmt+0x1f3>
                }
            }
            for (; width > 0; width --) {
  800c26:	eb 17                	jmp    800c3f <vprintfmt+0x263>
                putch(' ', putdat);
  800c28:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c2f:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800c36:	8b 45 08             	mov    0x8(%ebp),%eax
  800c39:	ff d0                	call   *%eax
            for (; width > 0; width --) {
  800c3b:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  800c3f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800c43:	7f e3                	jg     800c28 <vprintfmt+0x24c>
            }
            break;
  800c45:	e9 70 01 00 00       	jmp    800dba <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  800c4a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800c4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c51:	8d 45 14             	lea    0x14(%ebp),%eax
  800c54:	89 04 24             	mov    %eax,(%esp)
  800c57:	e8 0b fd ff ff       	call   800967 <getint>
  800c5c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800c5f:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  800c62:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c65:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c68:	85 d2                	test   %edx,%edx
  800c6a:	79 26                	jns    800c92 <vprintfmt+0x2b6>
                putch('-', putdat);
  800c6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c73:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800c7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7d:	ff d0                	call   *%eax
                num = -(long long)num;
  800c7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c82:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c85:	f7 d8                	neg    %eax
  800c87:	83 d2 00             	adc    $0x0,%edx
  800c8a:	f7 da                	neg    %edx
  800c8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800c8f:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  800c92:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  800c99:	e9 a8 00 00 00       	jmp    800d46 <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  800c9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ca1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ca5:	8d 45 14             	lea    0x14(%ebp),%eax
  800ca8:	89 04 24             	mov    %eax,(%esp)
  800cab:	e8 68 fc ff ff       	call   800918 <getuint>
  800cb0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800cb3:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  800cb6:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  800cbd:	e9 84 00 00 00       	jmp    800d46 <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  800cc2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800cc5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cc9:	8d 45 14             	lea    0x14(%ebp),%eax
  800ccc:	89 04 24             	mov    %eax,(%esp)
  800ccf:	e8 44 fc ff ff       	call   800918 <getuint>
  800cd4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800cd7:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  800cda:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  800ce1:	eb 63                	jmp    800d46 <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
  800ce3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ce6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cea:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800cf1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf4:	ff d0                	call   *%eax
            putch('x', putdat);
  800cf6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cf9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cfd:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800d04:	8b 45 08             	mov    0x8(%ebp),%eax
  800d07:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800d09:	8b 45 14             	mov    0x14(%ebp),%eax
  800d0c:	8d 50 04             	lea    0x4(%eax),%edx
  800d0f:	89 55 14             	mov    %edx,0x14(%ebp)
  800d12:	8b 00                	mov    (%eax),%eax
  800d14:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800d17:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  800d1e:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  800d25:	eb 1f                	jmp    800d46 <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  800d27:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d2e:	8d 45 14             	lea    0x14(%ebp),%eax
  800d31:	89 04 24             	mov    %eax,(%esp)
  800d34:	e8 df fb ff ff       	call   800918 <getuint>
  800d39:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800d3c:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  800d3f:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  800d46:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800d4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d4d:	89 54 24 18          	mov    %edx,0x18(%esp)
  800d51:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800d54:	89 54 24 14          	mov    %edx,0x14(%esp)
  800d58:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d5f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d62:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d66:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d6d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d71:	8b 45 08             	mov    0x8(%ebp),%eax
  800d74:	89 04 24             	mov    %eax,(%esp)
  800d77:	e8 97 fa ff ff       	call   800813 <printnum>
            break;
  800d7c:	eb 3c                	jmp    800dba <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  800d7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d81:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d85:	89 1c 24             	mov    %ebx,(%esp)
  800d88:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8b:	ff d0                	call   *%eax
            break;
  800d8d:	eb 2b                	jmp    800dba <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  800d8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d92:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d96:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800d9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800da0:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  800da2:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800da6:	eb 04                	jmp    800dac <vprintfmt+0x3d0>
  800da8:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800dac:	8b 45 10             	mov    0x10(%ebp),%eax
  800daf:	83 e8 01             	sub    $0x1,%eax
  800db2:	0f b6 00             	movzbl (%eax),%eax
  800db5:	3c 25                	cmp    $0x25,%al
  800db7:	75 ef                	jne    800da8 <vprintfmt+0x3cc>
                /* do nothing */;
            break;
  800db9:	90                   	nop
        }
    }
  800dba:	90                   	nop
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800dbb:	e9 3e fc ff ff       	jmp    8009fe <vprintfmt+0x22>
}
  800dc0:	83 c4 40             	add    $0x40,%esp
  800dc3:	5b                   	pop    %ebx
  800dc4:	5e                   	pop    %esi
  800dc5:	5d                   	pop    %ebp
  800dc6:	c3                   	ret    

00800dc7 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  800dc7:	55                   	push   %ebp
  800dc8:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  800dca:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dcd:	8b 40 08             	mov    0x8(%eax),%eax
  800dd0:	8d 50 01             	lea    0x1(%eax),%edx
  800dd3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dd6:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  800dd9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ddc:	8b 10                	mov    (%eax),%edx
  800dde:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de1:	8b 40 04             	mov    0x4(%eax),%eax
  800de4:	39 c2                	cmp    %eax,%edx
  800de6:	73 12                	jae    800dfa <sprintputch+0x33>
        *b->buf ++ = ch;
  800de8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800deb:	8b 00                	mov    (%eax),%eax
  800ded:	8d 48 01             	lea    0x1(%eax),%ecx
  800df0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800df3:	89 0a                	mov    %ecx,(%edx)
  800df5:	8b 55 08             	mov    0x8(%ebp),%edx
  800df8:	88 10                	mov    %dl,(%eax)
    }
}
  800dfa:	5d                   	pop    %ebp
  800dfb:	c3                   	ret    

00800dfc <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  800e02:	8d 45 14             	lea    0x14(%ebp),%eax
  800e05:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  800e08:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e0b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e0f:	8b 45 10             	mov    0x10(%ebp),%eax
  800e12:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e16:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e19:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e20:	89 04 24             	mov    %eax,(%esp)
  800e23:	e8 08 00 00 00       	call   800e30 <vsnprintf>
  800e28:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  800e2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800e2e:	c9                   	leave  
  800e2f:	c3                   	ret    

00800e30 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  800e30:	55                   	push   %ebp
  800e31:	89 e5                	mov    %esp,%ebp
  800e33:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  800e36:	8b 45 08             	mov    0x8(%ebp),%eax
  800e39:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e3f:	8d 50 ff             	lea    -0x1(%eax),%edx
  800e42:	8b 45 08             	mov    0x8(%ebp),%eax
  800e45:	01 d0                	add    %edx,%eax
  800e47:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800e4a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  800e51:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800e55:	74 0a                	je     800e61 <vsnprintf+0x31>
  800e57:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800e5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e5d:	39 c2                	cmp    %eax,%edx
  800e5f:	76 07                	jbe    800e68 <vsnprintf+0x38>
        return -E_INVAL;
  800e61:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e66:	eb 2a                	jmp    800e92 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  800e68:	8b 45 14             	mov    0x14(%ebp),%eax
  800e6b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e6f:	8b 45 10             	mov    0x10(%ebp),%eax
  800e72:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e76:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800e79:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e7d:	c7 04 24 c7 0d 80 00 	movl   $0x800dc7,(%esp)
  800e84:	e8 53 fb ff ff       	call   8009dc <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  800e89:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e8c:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  800e8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800e92:	c9                   	leave  
  800e93:	c3                   	ret    

00800e94 <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
  800e94:	55                   	push   %ebp
  800e95:	89 e5                	mov    %esp,%ebp
  800e97:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
  800e9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9d:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
  800ea3:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
  800ea6:	b8 20 00 00 00       	mov    $0x20,%eax
  800eab:	2b 45 0c             	sub    0xc(%ebp),%eax
  800eae:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800eb1:	89 c1                	mov    %eax,%ecx
  800eb3:	d3 ea                	shr    %cl,%edx
  800eb5:	89 d0                	mov    %edx,%eax
}
  800eb7:	c9                   	leave  
  800eb8:	c3                   	ret    

00800eb9 <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
  800eb9:	55                   	push   %ebp
  800eba:	89 e5                	mov    %esp,%ebp
  800ebc:	57                   	push   %edi
  800ebd:	56                   	push   %esi
  800ebe:	53                   	push   %ebx
  800ebf:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
  800ec2:	a1 00 20 80 00       	mov    0x802000,%eax
  800ec7:	8b 15 04 20 80 00    	mov    0x802004,%edx
  800ecd:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
  800ed3:	6b f0 05             	imul   $0x5,%eax,%esi
  800ed6:	01 f7                	add    %esi,%edi
  800ed8:	be 6d e6 ec de       	mov    $0xdeece66d,%esi
  800edd:	f7 e6                	mul    %esi
  800edf:	8d 34 17             	lea    (%edi,%edx,1),%esi
  800ee2:	89 f2                	mov    %esi,%edx
  800ee4:	83 c0 0b             	add    $0xb,%eax
  800ee7:	83 d2 00             	adc    $0x0,%edx
  800eea:	89 c7                	mov    %eax,%edi
  800eec:	83 e7 ff             	and    $0xffffffff,%edi
  800eef:	89 f9                	mov    %edi,%ecx
  800ef1:	0f b7 da             	movzwl %dx,%ebx
  800ef4:	89 0d 00 20 80 00    	mov    %ecx,0x802000
  800efa:	89 1d 04 20 80 00    	mov    %ebx,0x802004
    unsigned long long result = (next >> 12);
  800f00:	a1 00 20 80 00       	mov    0x802000,%eax
  800f05:	8b 15 04 20 80 00    	mov    0x802004,%edx
  800f0b:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  800f0f:	c1 ea 0c             	shr    $0xc,%edx
  800f12:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f15:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
  800f18:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
  800f1f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f22:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f25:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f28:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800f2b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f2e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800f31:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800f35:	74 1c                	je     800f53 <rand+0x9a>
  800f37:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800f3f:	f7 75 dc             	divl   -0x24(%ebp)
  800f42:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800f45:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f48:	ba 00 00 00 00       	mov    $0x0,%edx
  800f4d:	f7 75 dc             	divl   -0x24(%ebp)
  800f50:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800f53:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800f56:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800f59:	f7 75 dc             	divl   -0x24(%ebp)
  800f5c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f5f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800f62:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800f65:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800f68:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f6b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800f6e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
  800f71:	83 c4 24             	add    $0x24,%esp
  800f74:	5b                   	pop    %ebx
  800f75:	5e                   	pop    %esi
  800f76:	5f                   	pop    %edi
  800f77:	5d                   	pop    %ebp
  800f78:	c3                   	ret    

00800f79 <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
  800f79:	55                   	push   %ebp
  800f7a:	89 e5                	mov    %esp,%ebp
    next = seed;
  800f7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7f:	ba 00 00 00 00       	mov    $0x0,%edx
  800f84:	a3 00 20 80 00       	mov    %eax,0x802000
  800f89:	89 15 04 20 80 00    	mov    %edx,0x802004
}
  800f8f:	5d                   	pop    %ebp
  800f90:	c3                   	ret    

00800f91 <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  800f91:	55                   	push   %ebp
  800f92:	89 e5                	mov    %esp,%ebp
  800f94:	83 e4 f0             	and    $0xfffffff0,%esp
  800f97:	83 ec 10             	sub    $0x10,%esp
    cprintf("I read %08x from 0xfac00000!\n", *(unsigned *)0xfac00000);
  800f9a:	b8 00 00 c0 fa       	mov    $0xfac00000,%eax
  800f9f:	8b 00                	mov    (%eax),%eax
  800fa1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fa5:	c7 04 24 c0 12 80 00 	movl   $0x8012c0,(%esp)
  800fac:	e8 1c f3 ff ff       	call   8002cd <cprintf>
    panic("FAIL: T.T\n");
  800fb1:	c7 44 24 08 de 12 80 	movl   $0x8012de,0x8(%esp)
  800fb8:	00 
  800fb9:	c7 44 24 04 07 00 00 	movl   $0x7,0x4(%esp)
  800fc0:	00 
  800fc1:	c7 04 24 e9 12 80 00 	movl   $0x8012e9,(%esp)
  800fc8:	e8 53 f0 ff ff       	call   800020 <__panic>
