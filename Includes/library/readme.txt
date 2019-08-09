This library is providing asm functions to simplifying GBz80 dev.

inputs.asm
|
\_ readInputs:
		Return inputs in the format 
		down | up | left | right | start | select | B | A
		Params: NONE
		Return: inputs in _PAD (needs to be defined)

memory.asm
|
\_ copyMemory:
		Copy a given number of bytes from one memory location to another
		Params:
			hl - Destination address
			de - Origin address
			bc - Counter
		Return: NONE
|
\_ cleanMemory:
		Reset all bytes on a memory location
		Params:
			hl - Destination address
			bc - Counter
		Return: NONE

screen.asm
|
\_ lcdOff:
		Turn off the LCD screen
		Params: NONE
		Return: NONE
|
\_ waitVBlank:
		Wait until VBlank
		Params: NONE
		Return: NONE

time.asm
|
\_ delay:
		Wait a given time
		Params:
			bc - Time to wait
		Return: NONE
