		.h8300s
		
; ------ definice sekce .vects ---------------------
 
		.section	.vects,"a",@progbits
rs:		.long		_start		

; ----------- symboly ------------- 

		.equ	syscall,0x1FF00	; simulated IO area
		.equ	PUTS,0x0114		; kod PUTS
		.equ	GETS,0x0113		; kod GETS
		
; ----------- data ----------------
				.data
				.align	2
input:			.long	in		
output: 		.long	out
prompt:			.long	text
output_prompt: 	.long   text1
invalid:		.long	text2
terminated:		.long 	text3

in:				.space 	20
out:			.space  20
text:			.asciz	"Vstupni hodnota (0 - 9999). Zadejte 'Q' pro ukoèení: "
text1:  		.asciz  "Hexadecimální: "
text2:			.asciz	"Vstup není validní. Zkuste znovu. \n"
text3:			.asciz	"Konec \n"

				.align	1
				.space	100
stack:	

;----------------------------------

		.text
		.global		_start
		
_start:	
		mov.l	#stack,ER7

prompt_input:
;vypsani vyzvy
		mov.w	#PUTS,R0
		mov.l	#prompt,ER1
		jsr		@syscall
		
;nacteni vstupu		
		mov.w   #GETS,R0
		mov.l	#input,ER1
		jsr		@syscall
	
;funkce		
		mov.l 	#in,ER6
		
		jsr 	asciiToInt
		
		jsr	 	print
		
exit:			;kdyz program skonci pomoci 'Q'
		mov.w	#PUTS,R0
		mov.l	#terminated,ER1
		jsr		@syscall
	
		jmp 	lab1
		
validate:		;nevalidni vstup
		mov.w	#PUTS,R0
		mov.l	#invalid,ER1
		jsr		@syscall

		jmp 	prompt_input

asciiToInt:		;10 - zaklad, R4 - counter cifer
		push.l	ER1
 		xor 	R0,R0 		
 		xor 	R1,R1 		
 		mov.w 	#10,E1 	
		mov.w	#0,R4	

assist1: 		;postupne se prevede kazdy znak na cislo, vystup v R0
		mov.b 	@ER6,R1L
		
		cmp 	#5,R4
		beq 	validate
		
		cmp 	#0x0A,R1L 	
 		beq 	assist2 
		 
		cmp		#'Q',R1L
		beq		exit
		
		cmp     #'0',R1L 
    	blt     validate
    		
		cmp		#'9',R1L
		bgt		validate
		
		inc.w 	#1,R4
			
 		sub.l 	#'0',ER1 	
 		mulxu 	E1,ER0 	
 		add 	R1,R0 		
 		inc.l 	#1,ER6 		
 		jmp 	@assist1	

assist2:
		pop.l	ER1
		rts
		

print:  		;R2H pocet cifer
        mov.l 	#out, ER1   
        mov.b 	#4,R2H 
		mov.w 	#0,R5

toHex:			;prevod na hex
        rotl 	#2,R0
        rotl 	#2,R0
        mov.b 	#0x0F,R2L
        and 	R0L,R2L

        cmp 	#0,R2L          
        beq 	leading_zero_check
        bne 	proceed        

leading_zero_check:		;zkontroluje, jestli uz je cislo, nebo jen nuly na zaèátku
		cmp 	#1,R2H
		beq 	proceed

		cmp 	#0,R5
		bne 	proceed
		
		dec.b 	R2H
		beq 	conv_output

		jmp 	toHex

proceed:		;zjisti, jestli je cislo, nebo znak
		inc.w 	#1,R5
        cmp 	#0x09,R2L
 		bgt 	char 

number: 		;pricte 0x30 k hodnote, napr. 9 -> 0x39 = 9
        add 	#0x30,R2L       
        jmp 	loop

char:			;pokud znak, pricte 0x37
        add 	#0x37,R2L       

loop:       	;ulozi prevedeny do vystupniho bufferu
        mov.b 	R2L,@ER1      
        inc.l 	#1,ER1
        
		dec 	R2H
		beq 	conv_output
		
		jmp 	toHex
		
conv_output:  	;vypise cele prevedene cislo do konzole
        mov.b 	#0x0A,R2L
        mov.b 	R2L,@ER1
		
		mov.w 	#PUTS,R0
		mov.l 	#output_prompt,ER1
		jsr 	@syscall
		
        mov.w 	#PUTS,R0     
        mov.l 	#output,ER1  
        jsr 	@syscall
		
		jmp 	prompt_input
		
lab1:	jmp 	lab1

		.end

