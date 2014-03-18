ROOT = ../..

all: static/** *.elm $(ROOT)/src/elm/*.elm $(ROOT)/src/js/*.js
	elm -mo Keys.elm 
	elm -mo --src-dir=$(ROOT)/src/elm Bot.elm
	mkdir -p build/lib/
	cp -r static/* build/
	cp $(ROOT)/lib/*.js build/lib/
	cp $(ROOT)/src/js/*.js build/

clean:
	-rm -rf build/ cache/
