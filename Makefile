CC = gcc
CFLAGS = -O2 -mwindows -std=c99
LIBS = -luser32 -lkernel32
SRC = switchy.c charmap.c
TARGET = switchy.exe

.PHONY: all build clean release-notes release

all: build

build: $(TARGET)

$(TARGET): $(SRC)
	-taskkill //F //IM $(TARGET) > /dev/null 2>&1 || true
	sleep 0.5
	$(CC) $(SRC) -o $(TARGET) $(CFLAGS) $(LIBS)

clean:
	rm -f $(TARGET)

release-notes:
	@awk '\
	/^<!--/,/^-->/ { next } \
	/^## \[[0-9]+\.[0-9]+\.[0-9]+\]/ { if (found) exit; found=1; next } \
	found { \
		if (/^## \[/) { exit } \
		if (/^$$/) { flush(); print; next } \
		if (/^\* / || /^- /) { flush(); buf=$$0; next } \
		if (/^###/ || /^\[/) { flush(); print; next } \
		sub(/^[ \t]+/, ""); sub(/[ \t]+$$/, ""); \
		if (buf != "") { buf = buf " " $$0 } else { buf = $$0 } \
		next \
	} \
	function flush() { if (buf != "") { print buf; buf = "" } } \
	END { flush() } \
	' CHANGELOG.md
