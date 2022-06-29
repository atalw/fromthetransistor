/*
https://peterdn.com/post/2020/08/22/hello-world-in-arm64-assembly/

#include <unistd.h>

void main() {
  const char msg[] = "Hello world!\n";
  write(0, msg, sizeof(msg));
  exit(0);
}
*/

.data

msg:
    .ascii        "Hello world!\n"
len = . - msg

.text

.globl _start
_start:
    mov     x0, #1
    ldr     x1, =msg
    ldr     x2, =len
    mov     w8, #64
    svc     #0

    mov     x0, #0
    mov     w8, #93
    svc     #0
