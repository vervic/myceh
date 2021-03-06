
HI=hi
OBJ=obj
SRC=src
BUILD=build
DEFS=$(SRC)/defs

VIEWERR=subl

TARGET=$(BUILD)/myceh

HAPPY=happy
HAPPY_OPTS=--info=grammar.info -g -a -d
#HAPPY_OPTS=

ALEX=alex
ALEX_OPTS=

GHC=ghc
GHC_OPTS=


all: build

run: 
	$(TARGET)

build: generate ensure_directories
	$(GHC) $(GHC_OPTS) -odir $(OBJ) -hidir $(HI) -o $(TARGET) $(SRC)/Main.hs $(SRC)/Scanner.hs $(SRC)/Parser.hs $(SRC)/CodeGen.hs $(SRC)/TypeNames.hs 
	chmod +x $(TARGET)

generate: $(SRC)/Scanner.hs $(SRC)/Parser.hs

$(SRC)/Scanner.hs: $(DEFS)/scanner.x
	$(ALEX) $(ALEX_OPTS) $(DEFS)/scanner.x
	mv $(DEFS)/scanner.hs $(SRC)/Scanner.hs

$(SRC)/Parser.hs: $(DEFS)/parser.y
	$(HAPPY) $(HAPPY_OPTS)  $(DEFS)/parser.y
	mv $(DEFS)/parser.hs $(SRC)/Parser.hs

as: dis 
	llvm-as-mp-3.2 -o bitcode.as bitcode.bc
	$(VIEWERR) bitcode.as

dis: bitcode.bc
	llvm-dis-mp-3.2 -o bitcode.llvm_dis bitcode.bc
	$(VIEWERR) bitcode.llvm_dis

clean: 
	cd $(SRC); rm -rf Scanner.hs Parser.hs
	rm -rf $(OBJ) $(HI) $(BUILD)

help:
	open "http://llvm.org/docs/CommandGuide/llc.html"
	open "http://stackoverflow.com/questions/14604357/expected-top-level-entity"
	
ensure_directories:
	mkdir -p $(OBJ)
	mkdir -p $(HI)
	mkdir -p $(BUILD)

.PHONY: dis as clean help
