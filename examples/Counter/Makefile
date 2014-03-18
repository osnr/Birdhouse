ROOT = ../..

all: index.html *.elm $(ROOT)/src/elm/*.elm $(ROOT)/src/js/*.js
	elm -mo Keys.elm 
	elm -mo Bot.elm --src-dir=$(ROOT)/src/elm --build-dir=build --cache-dir=cache Bot.elm
	mkdir -p build/lib/
	cp index.html build/
	cp $(ROOT)/lib/*.js build/lib/
	cp $(ROOT)/src/js/*.js build/

clean:
	-rm -rf build/ cache/
