CC = gcc
CFLAGS = -I. -g 
DEPS = tcpsnoop.h
OBJSNOOP = tcpsnoop.o
OBJSHOOT = tcpshoot.o

%.s: %.c $(DEPS)
	$(CC) -S -o $@ $< $(CFLAGS)

%.o: %.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

tcpsnoop: $(OBJSNOOP)
	$(CC) -o $@ $^ $(CFLAGS)

tcpshoot: $(OBJSHOOT)
	$(CC) -o $@ $^ $(CFLAGS)

all: tcpsnoop tcpshoot
