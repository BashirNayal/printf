.text
string:
    .asciz  "My name is %d. I think I’ll get a %u for my exam. What does %r do? And %%? And %d?And again %u? Some extra values: %s %u %u %s"
name:
    .asciz  "Marvin" 
  
.global main
main:
    pushq   %rbp
    movq    %rsp, %rbp

    call    print
    
    movq    $60, %rax
    movq    $0, %rsi
    syscall

print:
    pushq   %rbp            # set up the stack frame
    movq    %rsp, %rbp
    
    pushq   $name           # push all arguments onto the stack
    pushq   $123
    pushq   $123
    pushq   $name
    pushq   $-123
    pushq   $-123                   
    pushq   $10
    pushq   $123
    pushq   $string
   
    movq    $1, %rax        # writing system call       
    movq    $1, %rdi                
    movq    $1, %rdx        # rdx will always be 1 because we are only printing one character at a time
    popq    %rsi            # move the pointer into rsi
 
    loop:
        cmpb    $0, (%rsi)          # check if the pointer reached the end of the string
        je      return              # return if it reached the end
        
        cmpb    $'%', (%rsi)        # check if the pointer is point to a percentage sign
        je      if                  # if so, jump to if statement
        jne     continue            # else, continue
        if:
            incq    %rsi                # increment the pointer
            cmpb    $'d', (%rsi)        # jump to one of the labels accordingly
            je      letterD
            cmpb    $'u', (%rsi)
            je      letterU
            cmpb    $'s', (%rsi)
            je      letterS
            cmpb    $'%', (%rsi)
            je      continue            # if this execute, this means that the program doesn't support that specifier
            
            decq    %rsi                # if the specifier is not supported: point to the pervious character   
            syscall                     # and print the percentage sign
            
            incq     %rsi               # point to the next character
            jmp     loop
        
        letterD:
            incq    %rsi                # point to the next character
            popq    %rax                # move the current argument on the stack to rax
            cmp     $0, %rax            # check whether the number is positve 
            jge     endNegative         # skip the loop if it is positive
            negative:
                imul    $-1, %rax           # turn the number into a positive number
                movq    %rsi, %r8           # a temporary holder for the format string
                movq    %rax, %r9           # place holder for the number
                movq    $1, %rax            # writing system call       
                pushq   $45                 # push the ascii value of minus onto the stack                
                leaq    (%rsp), %rsi            
                addq    $8, %rsp
                syscall                     # print a minus sign
                
                movq    %r8, %rsi           # move the format string back to rsi    
                movq    %r9, %rax           # move the now positive number to rax
            endNegative:
                movq    $10, %r10           # divisor for divloop   
                xor     %r9, %r9            # counter for divloop
                jmp     divLoop
                    
        letterU:
            popq    %rax                # move the current argument on the stack to rax
            movq    $10, %r10           # move the divisor into r10
            xor     %r9, %r9            # reset the loop pointer
            incq    %rsi                # point to the next character
            
            divLoop:  
                xor     %rdx, %rdx          # clean rdx             
                divq    %r10                # divide the number stored in rax by 10
                
                pushq   %rdx                # push the remainder onto the stack
                incq    %r9                 # increment the loop counter 
                
                cmpq    $0, %rax            # check if the result of multiplication is 0
                jne     divLoop
            printNumbers:
                movq    %rsi, %r8           # temporary holder for the pointer
                movq    $1, %rax            # preparing the needed registers for a write syscall
                movq    $1, %rdx
                movq    $1, %rdi
                numberPrintingLoop:
                    leaq    (%rsp), %rsi        # load the address of the last remainder into rsi
                    addq    $'0', (%rsi)        # turn the digit into ascii
                    syscall                     # print the first digit of the whole number

                    addq    $8, %rsp            # clean top of the stack
                    decq    %r9                 # decrement the loop counter
            
                    cmpq    $0, %r9             # check if the counter is 0
                    jne     numberPrintingLoop
                    movq    %r8, %rsi           # move the format string back to rsi
                    jmp     loop
            
        letterS:
            incq    %rsi                # point to the next character
            movq    %rsi, %r8           # place holder for the format string
            popq    %rsi                # move the current argument on the stack into rsi
            printChar:
                syscall                     # print the character the pointer is pointing to        
                incq    %rsi                # point to the next character
                cmpb     $0, (%rsi)         # check if the pointer reached the end of the string
                jne     printChar
                
                movq    %r8, %rsi           # move the format string back to rsi
                jmp     loop                # jump back to the loop

        continue:               
            syscall                     # print the character that the pointer is pointing
            incq    %rsi                # point to the next character
            jmp     loop    

    return:
        movq    %rbp, %rsp           # clean up the stack 
        popq    %rbp
        ret
