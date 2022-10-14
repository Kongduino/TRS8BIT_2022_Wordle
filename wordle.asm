	ORG 0xD4FF
MAIN:	CALL CLS
	CALL SETSYS
	MVI A,1
	MVI B,8
	CALL CURSOR
	CALL ERAEOL
	MVI A,17
	MVI B,1
	CALL CURSOR
	LXI H, GREET
	CALL DISPLAY
	LXI H, WAIT1
	CALL DISPLAY
	LXI D,0x8000 ; Beginning of the RAM area, normally whatever BASIC program is loaded
	LHLX ; HL = (DE) Pseudo random number
GETNUM:	; We have 2312 words, so the biggest number allowed is 0x0907, 2311
	MOV A,H
	CPI 0x09
	JM GETNUM0
	MOV A,L
	CPI 0x08 ; less than 0x0908? ok!
	JM GETNUM0
	LXI H,0 ; No? Reset to 0
	PUSH H
	; ===================
	; for now limit to 256 words
	; MVI H,0
GETNUM0:	POP H
	INX H ; increment HL
	PUSH H
	CALL KYREAD
	JZ GETNUM
	POP H
	; crude random number generator
	; We have only 5 blocks...
	; Limit the number to 0-31
	; TEMPORARY!
	; =========================
	; MOV A,L
	; MVI H,0
	; ANI 0x1F
	; MOV L,A ; HL = 0-31
	; =========================
	LXI D,WORDNUM
	SHLX ; (DE) = HL Save the number
	; MVI A,1
	; MVI B,3
	; CALL CURSOR
	; LXI H,ITEMN
	; CALL DISPLAY
	; LXI D,WORDNUM
	; LHLX ; HL = (DE)
	; CALL PRTINT
	; MVI A,15
	; MVI B,3
	; CALL CURSOR
	; LXI H,BLOCKN
	; CALL DISPLAY
	LXI D,WORDNUM
	LHLX ; HL = (DE)
	ARHL ; HL = HL / 2
	ARHL ; HL = HL / 2
	ARHL ; HL = HL / 2 ==> divided by 8
	LXI D, BLOCKNUM
	SHLX ; (DE) = HL ; Save the block number for now
	; CALL PRTINT
	; MVI A,25
	; MVI B,3
	; CALL CURSOR
	; LXI H,INDEXN
	; CALL DISPLAY
	; =========================
	; FASTER!
	; =========================
	LXI D,WORDNUM
	LHLX ; HL = (DE)
	MOV A,L ; We only need the lower byte
	ANI 0x07 ; 0b0000111 The last 3 bits are the ones pushed out...
	; during the division by 8
	; There's our modulo 8 function :-)
	; PUSH PSW
	; MOV L,A
	; MVI H,0
	; CALL PRTINT
	; MVI A,1
	; MVI B,4
	; CALL CURSOR
	; LXI H,INDEXB
	; CALL DISPLAY
	; POP PSW
	CPI 0
	JZ SKIP00 ; if index is 0 skip
	; PUSH PSW
	; MVI A,0x23
	; CALL LCD
	; POP PSW
	MOV B,A
	ADD B ; block offset calculation *is* 8-bit
	ADD B
	ADD B
	ADD B ; A = A * 5
SKIP00:	MOV L,A
	MVI H,0
	PUSH PSW
	LXI D,OFFSET
	SHLX ; (DE) = HL Save the offset
	; CALL PRTINT ; print the word offset
	; MVI A,0x5D
	; CALL LCD ; ]
	; MVI A,32
	; CALL LCD ; and a space
	; CALL CHGET
	LXI D, BLOCKNUM
	LHLX ; Retrieve the block number
	MOV B, H
	MOV C, L ; HL is 3 ---> multiply by 5
	DAD B ; HL is 6
	DAD B ; HL is 9
	DAD B ; HL is 12
	DAD B ; HL is 15
	MOV B, H
	MOV C, L ; BC and HL are 15 ---> multiply by 5 again
	DAD B ; HL is 30
	DAD B ; HL is 45
	DAD B ; HL is 60
	DAD B ; HL is 75: HL = HL * 25
	LXI D,DICTIX
	SHLX ; (DE) = HL Save DICT offset
	; MVI A,1
	; MVI B,3
	; CALL CURSOR
	; CALL PRTINT ; and display
	LXI B,0xD9B8 ; DICT see "answers.map"
	LXI D,DICTIX
	LHLX ; Get DICT offset
	DAD B ; calculate the address within DICT
	; HL = DICT + (DICTIX)
	SHLX ; (DE) = HL Save DICT offset
	LXI D,BUFFER
	MVI A,5 ; 5 times 5 bytes --> 40 bytes
LOOP00:	PUSH PSW
	MOV A,M
	RRC
	RRC
	RRC ; >> 3
	ANI 0x1F ; BYTE 0 0b00011111
	ADI 0x41 ; 0-25 --> 0x41-0x5A
	XCHG ; Exchange HL with DE
	MOV M,A ; store into BUFFER
	INX H
	XCHG
	MOV A,M
	RLC
	RLC ; << 2
	ANI 0x1C ; 0b00011100
	MOV B,A
	INX H
	MOV A,M
	RRC
	RRC
	RRC
	RRC
	RRC
	RRC ; >> 6
	ANI 0x03 ; 0b00000011
	ADD B ; BYTE 1
	ADI 0x41 ; 0-25 --> 0x41-0x5A
	XCHG ; Exchange HL with DE
	MOV M,A
	INX H
	XCHG ; this block should probably be a function call to save a couple of bytes
	MOV A,M
	RRC ; >> 1
	ANI 0x1F ; 0b00011111
	ADI 0x41 ; 0-25 --> 0x41-0x5A
	XCHG ; Exchange HL with DE
	MOV M,A ; BYTE 2
	INX H
	XCHG
	MOV A,M
	RLC
	RLC
	RLC
	RLC
	ANI 0x10 ; 0b00010000
	MOV B,A
	INX H
	MOV A,M
	RRC
	RRC
	RRC
	RRC
	ANI 0x0F ; 0b00001111
	ADD B ; BYTE 3
	ADI 0x41 ; 0-25 --> 0x41-0x5A
	XCHG ; Exchange HL with DE
	MOV M,A
	INX H
	XCHG
	MOV A,M
	RLC
	ANI 0x1E ; 0b00011110
	MOV B,A
	INX H
	MOV A,M
	CPI 128 ; If 1st bit of next byte, ie last byte of this word, is 0 leave it as is
	JM LOOP01
	MOV A,B
	INR A ; Add 1 ie set bit 0
	JP LOOP02
LOOP01:	MOV A,B ; BYTE 4
LOOP02:	ADI 0x41 ; 0-25 --> 0x41-0x5A
	XCHG ; Exchange HL with DE
	MOV M,A
	INX H
	XCHG
	MOV A,M
	RRC
	RRC
	ANI 0x1F ; 0b00011111 BYTE 5
	ADI 0x41 ; 0-25 --> 0x41-0x5A
	XCHG ; Exchange HL with DE
	MOV M,A
	INX H
	XCHG
	MOV A,M
	RLC
	RLC
	RLC
	ANI 0x18
	MOV B,A
	INX H
	MOV A,M
	RRC
	RRC
	RRC
	RRC
	RRC
	ANI 0x07 ; 0b00000111
	ADD B ; BYTE 6
	ADI 0x41 ; 0-25 --> 0x41-0x5A
	XCHG ; Exchange HL with DE
	MOV M,A
	INX H
	XCHG
	MOV A,M
	ANI 0x1F ; 0b00011111 BYTE 7
	ADI 0x41 ; 0-25 --> 0x41-0x5A
	XCHG ; Exchange HL with DE
	MOV M,A
	INX H
	XCHG ; now we have 8 bytes in the BUFFER
	INX H ; increment DICT pointer

	POP PSW ; counter 5 --> 0
	DCR A
	CPI 0
	JNZ LOOP00 ; loop 5 times
	
	CALL CLS
	MVI A,17
	MVI B,1
	CALL CURSOR
	LXI H, GREET
	CALL DISPLAY
	MVI A,35
	MVI B,1
	CALL CURSOR
	LXI B,BUFFER
	LXI D,OFFSET
	LHLX ; Get block offset
	DAD B ; HL = BUFFER + (OFFSET)
	SHLX ; OFFSET now contains the address in BUFFER
	MOV A,M
	CALL LCD
	INX H
	MOV A,M
	CALL LCD
	INX H
	MOV A,M
	CALL LCD
	INX H
	MOV A,M
	CALL LCD
	INX H
	MOV A,M
	CALL LCD ; display 5 chars
	
	XRA A ; A = 0
ASK00:	STA ROUND
	XRA A ; A = 0
	STA LETTER
	LDA ROUND
	ADI 2 ; Line 2 + ROUND (2-->6)
	MOV B,A
	MVI A,1
	CALL CURSOR ; cursor 1,[2-->6]
	LDA ROUND
	ADI 49
	CALL LCD
	MVI A, 0x2e
	CALL LCD
	MVI A,32
	CALL LCD ; Show ROUND + ". "
	LXI H,TRY0 ; Buffer to save current try
ASK01:	PUSH H
ASK03:	CALL CHGET
	CPI 'A
	JM ASK03
	CPI 'Z
	JP ASK03
	POP H
	MOV M,A
	PUSH H
	CALL LCD
	MVI A,32
	CALL LCD
	POP H
	LDA LETTER
	CPI 4
	JZ ASK02
	INR A
	STA LETTER
	INX H
	JMP ASK01
ASK02:	MVI A,1
	MVI B,8
	CALL CURSOR
	LXI H,YOUTRIED
	CALL DISPLAY
	LXI H,TRY0
	CALL DISPLAY
	MVI A,0x2A ; *
	STA RSLT0
	STA RSLT1
	STA RSLT2
	STA RSLT3
	STA RSLT4 ; initialize result
	LXI D,OFFSET
	LHLX ; Get block offset
	MOV A,M
	STA CHOICE0
	INX H
	MOV A,M
	STA CHOICE1
	INX H
	MOV A,M
	STA CHOICE2
	INX H
	MOV A,M
	STA CHOICE3
	INX H
	MOV A,M
	STA CHOICE4 ; Saved word to guess in CHOICE
	XRA A
	PUSH PSW
COMPARE0:	LDA CHOICE0
	LXI H,TRY0
	CMP M
	JNZ COMPARE1
	STA RSLT0
	MVI A,0x5F ; _
	STA CHOICE0
	STA TRY0
	POP PSW
	INR A
	PUSH PSW
COMPARE1:	LDA CHOICE1
	LXI H,TRY1
	CMP M
	JNZ COMPARE2
	STA RSLT1
	MVI A,0x5F ; _
	STA CHOICE1
	STA TRY1
	POP PSW
	INR A
	PUSH PSW
COMPARE2:	LDA CHOICE2
	LXI H,TRY2
	CMP M
	JNZ COMPARE3
	STA RSLT2
	MVI A,0x5F ; _
	STA CHOICE2
	STA TRY2
	POP PSW
	INR A
	PUSH PSW
COMPARE3:	LDA CHOICE3
	LXI H,TRY3
	CMP M
	JNZ COMPARE4
	STA RSLT3
	MVI A,0x5F ; _
	STA CHOICE3
	STA TRY3
	POP PSW
	INR A
	PUSH PSW
COMPARE4:	LDA CHOICE4
	LXI H,TRY4
	CMP M
	JNZ COMPARE5
	STA RSLT4
	MVI A,0x5F ; _
	STA CHOICE4
	STA TRY4
	POP PSW
	INR A
	PUSH PSW
COMPARE5:	POP PSW
	CPI 5
	JZ BINGO ; it's a match!
	; Alright then, let's look for close matches
	LDA RSLT0
	CPI 0x2A ; *
	JNZ COMPARE6 ; Already done if not '*' --> skip
	LDA TRY0
	LXI H,CHOICE1
	CMP M
	JZ COMPARE6A ; is it a close match?
COMPARE7:	LXI H,CHOICE2
	CMP M
	JZ COMPARE6A ; is it a close match?
COMPARE8:	LXI H,CHOICE3
	CMP M
	JZ COMPARE6A ; is it a close match?
COMPARE9:	LXI H,CHOICE4
	CMP M
	JNZ COMPARE6 ; is it a close match?
COMPARE6A:	ADI 0x20 ; lowercase
	STA RSLT0 ; save into result
COMPARE6:	LDA RSLT1
	CPI 0x2A ; *
	JNZ COMPARE10 ; Exact match, already done
	LXI H,TRY0
	LDA TRY1
	CMP M
	JZ COMPARE10A ; is it a close match?
COMPARE11:	LXI H,CHOICE2
	CMP M
	JZ COMPARE10A ; is it a close match?
COMPARE12:	LXI H,CHOICE3
	CMP M
	JZ COMPARE10A ; is it a close match?
COMPARE13:	LXI H,CHOICE4
	CMP M
	JNZ COMPARE10 ; is it a close match?
COMPARE10A:	ADI 0x20 ; lowercase
	STA RSLT1 ; save into result
COMPARE10:	LDA RSLT2
	CPI 0x2A ; *
	JNZ COMPARE14 ; Exact match, already done
	LXI H,CHOICE0
	LDA TRY2
	CMP M
	JZ COMPARE14A ; is it a close match?
COMPARE15:	LXI H,CHOICE1
	CMP M
	JZ COMPARE14A ; is it a close match?
COMPARE16:	LXI H,CHOICE3
	CMP M
	JZ COMPARE14A ; is it a close match?
COMPARE17:	LXI H,CHOICE4
	CMP M
	JNZ COMPARE14 ; is it a close match?
COMPARE14A:	ADI 0x20 ; lowercase
	STA RSLT2 ; save into result
COMPARE14:	LDA RSLT3
	CPI 0x2A ; *
	JNZ COMPARE18 ; Exact match, already done
	LXI H,CHOICE0
	LDA TRY3
	CMP M
	JZ COMPARE18A ; is it a close match?
COMPARE19:	LXI H,CHOICE1
	CMP M
	JZ COMPARE18A ; is it a close match?
COMPARE20:	LXI H,CHOICE2
	CMP M
	JZ COMPARE18A ; is it a close match?
COMPARE21:	LXI H,CHOICE4
	CMP M
	JNZ COMPARE18 ; is it a close match?
COMPARE18A:	ADI 0x20 ; lowercase
	STA RSLT3 ; save into result
COMPARE18:	LDA RSLT4
	CPI 0x2A ; *
	JNZ COMPARE22 ; Exact match, already done
	LXI H,CHOICE0
	LDA TRY4
	CMP M
	JZ COMPARE22A ; is it a close match?
COMPARE23:	LXI H,CHOICE1
	CMP M
	JZ COMPARE22A ; is it a close match?
COMPARE24:	LXI H,CHOICE2
	CMP M
	JZ COMPARE22A ; is it a close match?
COMPARE25:	LXI H,CHOICE3
	CMP M
	JNZ COMPARE22 ; is it a close match?
COMPARE22A:	ADI 0x20 ; lowercase
	STA RSLT4 ; save into result
COMPARE22:	LDA ROUND
	ADI 2 ; Line 2 + ROUND (2-->6)
	MOV B,A
	MVI A,20
	CALL CURSOR ; cursor 1,[2-->6]
	LXI H,RSLT0
	CALL DISPLAY
	LDA ROUND
	INR A
	CPI 6
	JM ASK00

	LXI D, 4184
	MVI B,10
	CALL MUSIC
	LXI D, 5586
	MVI B,10
	CALL MUSIC
	LXI D, 7456
	MVI B,10
	CALL MUSIC
	LXI D, 9952
	MVI B,10
	CALL MUSIC
	LXI H,YOUSUCK
LANDING:	PUSH H
	MVI B,8
	MVI A,1
	CALL CURSOR ; cursor 1,[2-->6]
	CALL ERAEOL
	POP H
	CALL DISPLAY

	CALL CHGET
	CPI 'Q
	JZ MENU
	CPI 'q
	JZ MENU
	JMP MAIN

BINGO:	LXI H,FOUNDIT
	JMP LANDING

CURSOR:	; a = x. b = y
	PUSH H ; preserve HL
	LXI H, CSRY ; 0xF639
	MOV M,B
	INX H ; 0xF63A: CSRX
	MOV M,A ; cursor X, Y
	POP H ; retrieve HL
	RET

HEX2ASC: ; IN: A = BYTE
	PUSH H ; preserve HL
	PUSH PSW ; preserve A for now
	RRC
	RRC
	RRC
	RRC ; A >> 4
	ANI 0x0F ; & 0b00001111
	ADI 0x30 ; Add 0x30 for '0' to '9'
	CPI 0x3A
	JM HEX2ASC0
	ADI 7 ; add 7 extra for 'A' to 'F'
HEX2ASC0:	CALL LCD ; display first char
	POP PSW ; retrieve A
	ANI 0x0F ; same thing on lower nibble
	ADI 0x30
	CPI 0x3A
	JM HEX2ASC1
	ADI 7
HEX2ASC1:	CALL LCD
	POP H ; retrieve HL
	RET

GREET: DS "WORDLE test"
	DB 13,10,0
WAIT1:	DS "Wait a short while and hit a key..."
	DB 0
ITEMN: DS "Word #"
	DB 0
BLOCKN: DS "Block #"
	DB 0
INDEXN: DS "Index #"
	DB 0
INDEXB: DS "Index Bytes ["
	DB 0
BLOCKIX: DS "Block index "
	DB 0
YOUTRIED: DS "You tried: "
	DB 0
FOUNDIT: DS "Well done!"
	DB 0
YOUSUCK: DS "You suck at this, doncha?"
	DB 0

WORDNUM: DB 27,0
OFFSET: DB 0,0
BLOCKNUM: DB 0,0
DICTIX: DB 0,0

ROUND: DB 0
LETTER: DB 0

CHOICE0: DB 0
CHOICE1: DB 0
CHOICE2: DB 0
CHOICE3: DB 0
CHOICE4: DB 0,0 ; extra zero as string terminator

TRY0: DB 0
TRY1: DB 0
TRY2: DB 0
TRY3: DB 0
TRY4: DB 0,0 ; extra zero as string terminator

RSLT0: DB 0
RSLT1: DB 0
RSLT2: DB 0
RSLT3: DB 0
RSLT4: DB 0,0 ; extra zero as string terminator

BUFFER:	DB 0,0,0,0,0,0,0,0
	DB 0,0,0,0,0,0,0,0
	DB 0,0,0,0,0,0,0,0
	DB 0,0,0,0,0,0,0,0
	DB 0,0,0,0,0,0,0,0,0
	; 40 bytes + a zero as string terminator for DISPLAY
