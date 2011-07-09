PYVERSION = 2.6
PYBASEDIR = /usr
PYTHON = $(PYBASEDIR)/bin/python$(PYVERION)

CC = gcc
CFLAGS = -O2 -g3 -I$(PYBASEDIR)/include/python$(PYVERSION) -W
LDFLAGS = -fPIC -shared -lev

CYTHON = $(PYTHON)  ~/work/cython-vitek/cython.py
CYTHON_FLAGS = -Wextra

all: ev.so

ev.so: ev.c ev-helper.h
	$(CC) $(CFLAGS) $(LDFLAGS) $< -o $@

ev.c: libev.pxd

%.c: %.pyx
	$(CYTHON) $(CYTHON_FLAGS) $< -o $@

.PHONY:
clean:
	rm -f ev.so ev.c

