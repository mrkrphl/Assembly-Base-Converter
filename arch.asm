TITLE Converter (archi_con.asm)

.MODEL medium

.STACK 100H

.DATA

    ;Variables
    chosen DB ?


    ;START MESSAGE
    greeting DB 'Hello, there! Welcome to the CONVERTER!$'
    next DB 10, 13, 'Choose a convertion method:$'
    ;OPERATIONS
    op1 DB 10, 13, '    A. Decimal To Binary$'
    op2 DB 10, 13, '    B. Binary To Decimal$'
    op3 DB 10, 13, '    C. Decimal To Hexadecimal$'
    op4 DB 10, 13, '    D. Hexadecimal to Decimal$'
    op5 DB 10, 13, '    E. Bianry To Hexadecimal$'
    op6 DB 10, 13, '    F. Hexadecimal to Bianary$'
    
    choice DB 10, 13, 'Enter Choice: $'
    invalid DB 10, 13, 'Invalid Input. Try Again...$'
    
    op1MSG DB 10, 13, 'DECIMAL TO BINARY CONVERSION$'
    op2MSG DB 10, 13, 'BIANRY TO DECIMAL CONVERSION$'
    op3MSG DB 10, 13, 'DECIMAL TO HEXADECIMAL CONVERSION$'
    
    entdec DB 10, 13, 'Enter Decmimal: $'
    
    limitMSG DB 10, 13, 'This converter can handle only 16 BITS of data', 10, 13, '$'

    decimal_number DW ?
    
.CODE

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

        dec cl
        cmp cl, 00H
        jg decIN
        
        showLIM:
            MOV AH, 09H
            LEA DX, limitMSG
            INT 21H
          
        
    decDone:
        MOV decimal_number, BX
        RET 
INPUT_DECIMAL ENDP

INPUT_HEX PROC 
    MOV AH, 09H
    MOV DX, OFFSET op1MSG
    INT 21H
    
    MOV DX, OFFSET entdec
    INT 21H

    XOR BX, BX
    hexIN: 
        MOV AH, 01H ;input
        INT 21H
        CMP AL, 0DH
        JE hexDone
        SUB AL, 30H
        XOR AH, AH ;clear AH
        ADD BX, AX
        
        ;shift left a nibble
        MOV CL, 04H
        shiftLeft:
            SHL BX, 01H
            dec cl
            cmp cl, 0h
            jg shiftLeft

        JMP hexIN

    hexDone:
        MOV CL, 04H
        shiftRight:
            SHR BX, 01H
            dec cl
            cmp cl, 0h
            jg shiftRight 
        
        ;BX now contains decimal number ex. 0047H
    RET 
INPUT_HEX ENDP

OUTPUT_BINARY PROC
    MOV CL, 0CH
    out_bin:
        PUSH BX 
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
    
DEC_TO_HEX PROC
    MOV AH, 09H
    LEA DX, op3MSG
    INT 21h

    CALL INPUT_DECIMAL
    MOV BX, decimal_number
    CALL OUTPUT_HEX

    RET
DEC_To_HEX ENDP

DEC_TO_BIN PROC
    MOV AH, 09H
    LEA DX, op1MSG
    INT 21H

    CALL INPUT_DECIMAL
    MOV BX, decimal_number
    CALL OUTPUT_BINARY
    
    RET
DEC_TO_BIN ENDP


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
        MOV DX, OFFSET op1
        INT 21H
    
        MOV AH, 09H
        MOV DX, OFFSET op2
        INT 21H

        MOV AH, 09H
        MOV DX, OFFSET op3
        INT 21H
    
        MOV AH, 09H
        MOV DX, OFFSET op4
        INT 21H
    
        MOV AH, 09H
        MOV DX, OFFSET op5
        INT 21H
    
        MOV AH, 09H
        MOV DX, OFFSET op6
        INT 21H
    
        ;Enter Choice
        MOV AH, 09H
        MOV DX, OFFSET choice
        INT 21H

        MOV AL, 0H
        ;Accept Input
        MOV AH, 01H
        INPUT: 
            MOV BL, AL
            INT 21H
            CMP AL, 0DH
            JNE INPUT

        MOV chosen, BL

        ;Check Input
        CMP BL, 41H
        JE dec_bin
        
        CMP BL, 42H
        JE bin_dec
        
        CMP BL, 43H
        JE dec_hex
        
    ;Did not jump means invalid input
    MOV AH, 09H
    MOV DX, OFFSET invalid
    INT 21H

    JMP operations

    dec_bin:
        CALL DEC_TO_BIN
        JMP done
        
    bin_dec:

        JMP done
    
    dec_hex:
        CALL DEC_TO_HEX
        JMP done
        
    done:


    
    ;Exit
    MOV AH, 4CH
    INT 21H
    

MAIN ENDP
END MAIN


