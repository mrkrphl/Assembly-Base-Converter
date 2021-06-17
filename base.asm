TITLE Converter (base.asm)

.MODEL medium

.STACK 100H

.DATA

    ;Variables
    cbi DB ?
    cbo DB ?


    ;START MESSAGE
    greeting DB 'Hello, there! Welcome to the CONVERTER!$'
    next DB 10, 13, 'Choose a convertion method:$'
    
    baseInput DB 10, 13, 'In what base is your input?$'
    in1 DB 10, 13, '    A. Binary$'
    in2 DB 10, 13, '    B. Decimal$'
    in3 DB 10, 13, '    C. Octal$'
    in4 DB 10, 13, '    D. Hexadecimal$'
    
    baseOutput DB 'In what base will be your desired output?$'
    
    ;OPERATIONS
    
    choice DB 10, 13, 'Enter Choice: $'
    invalid DB 10, 13, 'Invalid Input. Try Again...$'
    
    entdec DB 10, 13, 'Enter Decmimal: $'
    entbin DB 10, 13, 'Enter Binary: $'
    entoct DB 10, 13, 'Enter Octal: $'
    enthex DB 10, 13, 'Enter Hexadecimal: $'

    outnum DB 10, 13, 'Output: $'
    
    limitMSG DB 10, 13, 'This converter can handle only 16 BITS of data!$'
    
    invIn DB 10, 13, 'That is an invalid input!$'
    again DB 10, 13, 'Would you like to try again? [Y/N] $'
    byeMSG db 10,13, 'BYE!$'
    
.CODE
output_oct proc
    MOV CL, 00H
    MOV AX, BX
    MOV BX, 08H

    octrem:
        xor dx, dx
        div bx
        push dx
        inc cl
        cmp ax, 0h
        jne octrem
    
    octsend:
        pop dx
        add dl, 30H
        MOv Ah, 02H
        int 21h
        dec cl
        cmp cl, 0h
        jne octsend
    
    ret
output_oct endp

INPUT_OCT proc
    MOV Cl, 07H

    MOV AH, 09H
    LEA DX, entoct
    INT 21h
    
    XOR BX, BX
    octin:
        MOV AH, 01H
        INT 21h
        cmp al, 0dh
        je octdone
        cmp cl, 07H
        jl timeseight
        ledig:
            sub al, 30H
            ADD BL, AL
            dec cl
        cmp cl, 00H
        jg octin
        jmp limoct
        timeseight:
            mov ch, 03H
            eigthttimes:
            SHL BX, 01H
            dec ch
            cmp ch, 00h
            jg eigthttimes
            jmp ledig
        
        limoct:
            MOV AH, 09H
            LEA DX, limitMSG
            INT 21H
    octdone:
    ret
INPUT_OCT endp

OUTPUT_HEX PROC                         ;For outputting hex
    MOV CL, 0CH                         ;Counter for place digit
    
    toDisplay:
        MOV DX, BX                  
        SHR DX, CL
        AND DL, 0FH
        ADD DL, 30H
        CMP DL, 30H
        JNE displayDec
        
        SUB CL, 04H
        CMP CL, 00H
        JGE todisplay

    displayDec:
        CMP DL, 39H
        JLE displayHex
        
        letter: 
            ADD DL, 07H
        
        displayHex:    
            MOV AH, 02H
            INT 21h
            SUB CL, 04H
            cmp cl, 00H
            JGE toDisplay

    finish:
    RET

OUTPUT_HEX ENDP

INPUT_DECIMAL PROC
    MOV CL, 05H

    MOV AH, 09H
    
    LEA DX, entdec
    INT 21H
    
    XOR BX, BX
    decIN:
        MOV AH, 01H
        INT 21H
        CMP AL, 0DH
        JE decDone
        CMP cl, 05H
        jl timesten
        lsd:
            SUB AL, 30H
            ADD BL, AL
            dec cl
        cmp cl, 00H
        jg decIN
        jmp showLIM

        timesten:
            SHL BX, 01H
            MOV DX, BX
            SHL BX, 01H
            SHL BX, 01H
            ADD BX, DX
            jmp lsd
        
        showLIM:
            MOV AH, 09H
            LEA DX, limitMSG
            INT 21H
          
        
    decDone:
        RET 
INPUT_DECIMAL ENDP

INPUT_HEX PROC 
    mov ch, 04H

    MOV AH, 09H
    MOV DX, OFFSET  enthex
    INT 21H

    XOR BX, BX
    hexIN: 
        MOV AH, 01H ;input
        INT 21H
        CMP AL, 0DH
        JE hexDone
        cmp AL, 39H
        jg bigletter
        SUB AL, 30H
        XOR AH, AH ;clear AH
        ADD BX, AX
        jmp shiftlefthex
        
        bigletter:
            cmp AL, 41H
            jl invalidHex
            cmp al, 46H
            jg smallLetter
            SUB AL, 37H
            XOR AH, AH
            ADD BX, AX
            jmp shiftlefthex
            

        smallLetter:
            cmp AL, 61H
            jl invalidhex
            cmp al, 66H
            jg invalidHex
            SUB AL, 57H
            XOr AH, AH
            ADD BX, AX
            jmp shiftlefthex
        
        invalidHex:
            MOv AH, 09H
            lea dx, invin
            int 21h
            ret

        ;shift left a nibble
        shiftlefthex:
        dec ch
        cmp ch, 00H
        je limhex

        MOV CL, 04H
        SHL BX, CL
        jmp hexin

        limhex: 
        MOV AH, 09H
        LEa dx, limitMSG
        int 21h
        ret
        

    hexDone:
        MOV CL, 04H
        SHR BX, CL
        
        ;BX now contains decimal number ex. 0047H
    RET 
INPUT_HEX ENDP

INPUT_BINARY PROC
    MOV CL, 0FH
    XOR BX, BX
    
    MOV AH, 09H
    LEA DX, entbin
    INT 21H

    binin:
        MOV AH, 01H
        INT 21H
        CMP AL, 30H
        JE contBin
        CMP AL, 31H
        JE contBin
        CMP AL, 0DH
        JE binDone

    MOV AH, 09H
    LEA DX, invIn 
    INT 21H
    MOV BL, 01H
    jmp bindone

    contBin:
        SUB AL, 30H
        OR BL, AL
        SHL BX, 01H
        dec CL
        CMP CL, 00H
        JGE binin
        MOV AH, 09 
        LEA DX, limitMSG
        INT 21H
        
        RET

    
    binDone:
        SHR BX, 01H
    
    RET


INPUT_BINARY ENDP

OUTPUT_BINARY PROC
    MOV CL, 0CH
    out_bin:
        PUSH BX ;save ko lang BX para sure
        MOV AH, 02H
        MOV CL, 16
        shift:
        SHL BX, 01H
        JC dlOne
        MOV DL, 30H ;DL = 0
        JMP print
        dlOne:
            MOV DL, 31H ;DL = 1
        print:
            INT 21H
        dec cl
        cmp cl, 0CH
        je printSpace
        cmp cl, 08H
        je printSpace
        cmp cl, 04H
        je printSpace
        cmp cl, 00H
        jg shift
        jmp bin_done
        printSpace:
            MOV DL, 20H ;print space when done with highest 4 bits
            INT 21H
            jmp shift

        bin_done:
            POP BX
        RET
OUTPUT_BINARY ENDP

OUTPUT_DECIMAL PROC
    MOV CL, 00H
    MOV AX, BX
    MOV BX, 0AH
    

    rem:
        xor dx, dx
        div BX
        push DX ;remainder
        inc cl
        CMP AX, 0H
        JNE rem
    
    send:
        pop dx
        ADD dl, 30H
        
        MOV AH, 02H
        int 21h
        dec cl
        cmp cl, 0H
        jne send           

    RET
OUTPUT_DECIMAL ENDP

dec_con proc
    CALL INPUT_DECIMAL

    MOV AH, 09H
    LEA DX, outnum
    INT 21h

    CMP cbo, 41H
    JE DecToBin
        
    CMP cbo, 42H
    JE DecToDec
        
    CMP cbo, 43H
    JE DecToOct
        
    CMP cbo, 44H
    JE DecToHex

    CMP cbo, 61H
    JE DecToBin
        
    CMP cbo, 62H
    JE DecToDec
        
    CMP cbo, 63H
    JE DecToOct
        
    CMP cbo, 64H
    JE DecToHex

    DecToDec:
        CALL OUTPUT_DECIMAL
        ret

    DecToBin:
        CALL OUTPUT_BINARY
        ret

    DecToOct:
        CALL output_oct
        ret

    DecToHex:
        CALL OUTPUT_HEX
        ret
dec_con endp

bin_con proc
        CALL INPUT_BINARY

        MOV AH, 09H
        LEA DX, outnum
        INT 21h

        CMP cbo, 41H
        JE BinToBin
        
        CMP cbo, 42H
        JE BinToDec
        
        CMP cbo, 43H
        JE BinToOct
        
        CMP cbo, 44H
        JE BinToHex

        CMP cbo, 61H
        JE BinToBin
        
        CMP cbo, 62H
        JE BinToDec
        
        CMP cbo, 63H
        JE BinToOct
        
        CMP cbo, 64H
        JE BinToHex
        
        BinToDec:
            CALL OUTPUT_DECIMAL
            ret

        BinToBin:
            CALL OUTPUT_BINARY
            ret
        BinToOct:
            CALL output_oct
            ret

        BinToHex:
            CALL OUTPUT_HEX
            ret
bin_con endp

oct_con proc
        CALL INPUT_OCT

        mov AH, 09H
        LEA DX, outnum
        int 21h
        
        CMP cbo, 41H
        JE octtobin
        
        CMP cbo, 42H
        JE octtodec
        
        CMP cbo, 43H
        JE octtooct
        
        CMP cbo, 44H
        JE octtohex

        CMP cbo, 61H
        JE octtobin
        
        CMP cbo, 62H
        JE octtodec
        
        CMP cbo, 63H
        JE octtooct
        
        CMP cbo, 64H
        JE octtohex
        
        OctToDec:
            CALL OUTPUT_DECIMAL
            ret
        OctToBin:
            CALL OUTPUT_BINARY
            ret
        OctToOct:
            CALL output_oct
            ret
        OctToHex:
            call OUTPUT_HEX
            ret
oct_con endp

hex_con proc
        CALL INPUT_HEX

        MOV AH, 09H
        LEA DX, outnum
        INT 21h

        CMP cbo, 41H
        JE HEXTOBIN
        
        CMP cbo, 42H
        JE HEXTODEC
        CMP cbo, 43H
        JE HEXTOOCT
        
        CMP cbo, 44H
        JE HEXTOHEX
    
        CMP cbo, 61H
        JE HEXTOBIN
        
        CMP cbo, 62H
        JE HEXTODEC
        
        CMP cbo, 63H
        JE HEXTOOCT
        
        CMP cbo, 64H
        JE HEXTOHEX
        
        HexToDec:
            CALL OUTPUT_DECIMAL
            ret
        HexToBin:
            CALL OUTPUT_BINARY
            ret
        HexToOct:
            call output_oct
            ret
        HexToHex:
            call OUTPUT_HEX
            ret
hex_con endp

MAIN PROC
    ;move data to data segment
    MOV AX,@DATA
    MOV DS, AX

    ;display greeting
    MOV AH, 09H
    MOV DX, OFFSET greeting
    INT 21H
    
    MOV AH, 09H
    MOV DX, OFFSET next
    INT 21H
    
    ;Display Operations
    operations:
        MOV AH, 09H
        MOV DX, OFFSET baseInput
        INT 21H
    
        MOV AH, 09H
        MOV DX, OFFSET in1
        INT 21H

        MOV AH, 09H
        MOV DX, OFFSET in2
        INT 21H
    
        MOV AH, 09H
        MOV DX, OFFSET in3
        INT 21H
    
        MOV AH, 09H
        MOV DX, OFFSET in4
        INT 21H

        ;Enter Choice
        MOV AH, 09H
        MOV DX, OFFSET choice
        INT 21H

        
        ;Accept Input
        MOV AH, 01H
        acceptBaseIn: 
            MOV BL, AL
            INT 21H
            CMP AL, 0DH
            JNE acceptBaseIn

        




        MOV [cbi], BL

        ;Enter desired base output
        MOV AH, 09H
        LEA DX, baseOutput
        INT 21H

        ;Redisplay Options
        MOV AH, 09H
        MOV DX, OFFSET in1
        INT 21H

        MOV AH, 09H
        MOV DX, OFFSET in2
        INT 21H
    
        MOV AH, 09H
        MOV DX, OFFSET in3
        INT 21H
    
        MOV AH, 09H
        MOV DX, OFFSET in4
        INT 21H
        
        ;Enter Choice
        MOV AH, 09H
        MOV DX, OFFSET choice
        INT 21H

        ;Accept Input
        MOV AH, 01H
        acceptBaseOut: 
            MOV BL, AL
            INT 21H
            CMP AL, 0DH
            JNE acceptBaseOut

        ;save desired output
        MOV [cbo], BL
        
        CMP [cbi], 41H
        je binary

        CMP [cbi], 42H
        je decimal
        
        CMP [cbi], 43H
        je octal

        CMP [cbi], 44H
        je hexadecimal
    
        CMP [cbi], 61H
        je binary

        CMP [cbi], 62H
        je decimal
        
        CMP [cbi], 63H
        je octal

        CMP [cbi], 64H
        je hexadecimal
        
        
        binary:
            CALL bin_con
            jmp done

        decimal:
            call dec_con
            jmp done

        octal:
            call oct_con
            jmp done

        hexadecimal:
            call hex_con
            jmp done

    ;Did not jump means invalid input
    MOV AH, 09H
    MOV DX, OFFSET invalid
    INT 21H
jmpback:
    JMP operations

    done:
        MOV AH, 09H
        LEA DX, again
        INT 21h

        MOV AH, 01H
        int 21h
        
        CMP AL, 59H
        JE jmpback
        
        CMP AL, 79H
        JE jmpback

        CMP AL, 4EH
        je bye
    
        CMP AL, 6EH
        je bye
        
        MOV Ah, 09H
        LEa DX, invIn
        int 21h
        
        jmp done
        
    bye:
    MOV AH, 09H
    LEA DX, byeMSG
    INT 21h

    MOV AH, 4CH
    INT 21H
    

MAIN ENDP
END MAIN


