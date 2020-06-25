main:
	wla-gb -o kwirk.o kwirk.s
	wlalink -S linkfile kwirk.gb
	rm kwirk.o