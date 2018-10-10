.thumb
.syntax unified

.include "gpio_constants.s"     // Register-adresser og konstanter for GPIO
.include "sys-tick_constants.s" // Register-adresser og konstanter for SysTick

.text
	.global Start
	
Start:
	LDR R0, =SYSTICK_BASE

	//Sette frekvens, det vil si sette load registeret
	LDR R1, =SYSTICK_LOAD
	LDR R2, =FREQUENCY/10 //klokkefrekvens delt på 10.
	STR R2, [R0, R1] //Store frekvensen ved offsetet til load



	// Sette opp systick
	LDR R1, =SYSTICK_CTRL

	LDR R2, [R0, R1] //Offset er 0

	LDR R3, =SysTick_CTRL_CLKSOURCE_Msk | SysTick_CTRL_TICKINT_Msk | SysTick_CTRL_ENABLE_Msk

	STR R3, [R0,R1] //STR-er på ctrl

	//bruke bitmasks og | for å enable alt.






	//Sette opp KNAPP-registeret:

	LDR R3, =GPIO_BASE
	//Først extipselh


	LDR R0, =GPIO_EXTIPSELH

	LDR R5, [R3, R0] //R0 er nå verdien på extipselh

	LDR R1, =0b1111
	LSL R1, R1, 4
	MVN R1, R1
	AND R1, R5, R1

	LDR R2, =1
	LSL R2, R2, 4

	ORR R1, R2, R1 //R1 BLIR nå lik xxxx xxxx xxxx xxxx xxxx xxxx 0001 xxxx
	STR R1, [R3,R0]

	//så GPIO_EXTIFALL

	LDR R0, =GPIO_EXTIFALL
	LDR R5, [R3, R0] //Får inn det som ligger på extifall

	//Sette pin 9 til høy med bitwise or
	LDR R2, =1
	LSL R2, R2, BUTTON_PIN
	ORR R5, R5, R2
	STR R5, [R3, R0]


	//Skrive pin-biten til IFC til høy.

	LDR R0, =GPIO_IFC
	//Vi må sette pinen høy
	LDR R2, =1
	STR R2, [R3, R0]

	//Enabler interrupt på pin 9

	LDR R0, =GPIO_IEN
	LDR R5, [R3, R0] //Får inn det som ligger på I enable

	//Sette pin 9 til høy med bitwise or
	LDR R2, =1
	LSL R2, R2, BUTTON_PIN
	ORR R5, R5, R2
	STR R5, [R3, R0]







	LDR R10, =tenths
		MOV R1, #0
		STR R1, [R10]

	LDR R11, =seconds
		MOV R1, #0
		STR R1, [R11]

	LDR R12, =minutes
		MOV R1, #0
		STR R1, [R12]

	.global SysTick_Handler
	.thumb_func
	SysTick_Handler:
    // Din interrupt-kode her


    	//R10 holder styr på tideler.
    	LDR R10, =tenths
		LDR R2, [R10]
			MOV R1, #1
			ADD R1, R2, R1
			STR R1, [R10]

		//skru på led0


		MOV R0, #10
		LDR R9, [R10]
		CMP R0, R9

		BEQ RESETTENTHS

			B ENDIF

		RESETTENTHS:

			//Toggle led0
			LDR R0, =GPIO_BASE
			LDR R1, =PORT_SIZE
			LDR R2, =PORT_E
			MUL R1, R1, R2
			ADD R1, R1, R0 //Nå er vi på port E

			LDR R3, =GPIO_PORT_DOUT

			LDR R4, [R1,R3]


			MOV R5, #1
			LSL R5, R5, LED_PIN
			EOR R5, R5, R4
			STR R5, [R1,R3]

			//reset tideler

			MOV R0, #0
			STR R0, [R10]

			//legg til et sekund
			LDR R11, =seconds
			LDR R2, [R11]
			MOV R1, #1
			ADD R1, R2, R1
			STR R1, [R11]

			MOV R0, #60
			LDR R9, [R11]
			CMP R0, R9

			BEQ RESETSECONDS

				B ENDIF2
			RESETSECONDS:
				MOV R0, #0
				STR R0, [R11]

				// Add one to minutes.

				LDR R2, [R12]
				MOV R1, #1
				ADD R1, R2, R1
				STR R1, [R12]

		ENDIF2:
		ENDIF:


    	BX LR // Returner fra interrupt


	//Interrupt for knappen
	.global GPIO_ODD_IRQHandler
	.thumb_func
	GPIO_ODD_IRQHandler:
    	// Din interrupt-kode her


//Av-enabler systick
		LDR R0, =SYSTICK_BASE
		LDR R1, =SYSTICK_CTRL

		LDR R2, [R0, R1] //Offset er 0
		EOR R4, R2, (SysTick_CTRL_ENABLE_Msk)
		STR R4, [R0,R1] //STR-er på ctrl

		//Setter interrupt-flagget lavt igjen, clearer.

		LDR R3, =GPIO_BASE
		LDR R0, =GPIO_IFC
		//Vi må sette pinen høy
		LDR R2, =1
		STR R2, [R3, R0]

    BX LR // Returner fra interrupt


	Loop:




































	B Loop
    // Skriv din kode her...


NOP // Behold denne på bunnen av fila

