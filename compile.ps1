# Script for compiling GB ROM with RGBDs

Param(
[string]$n
)
rgbasm -o .\Binary\$n.o .\$n.asm
rgblink -o .\ROM\$n.gb .\Binary\$n.o
rgbfix -v -p 0 .\ROM\$n.gb