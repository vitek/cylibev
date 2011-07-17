PYVERSION = 2.6
PYBASEDIR = /usr
PYTHON    = $(PYBASEDIR)/bin/python$(PYVERION)

CC      = gcc
CFLAGS  = -O2 -g3 -I$(PYBASEDIR)/include/python$(PYVERSION) -W
LDFLAGS = -fPIC -shared -lev
LDLIBS  =

CYTHON = $(PYTHON)  ~/work/cython-vitek/cython.py
CYTHON_FLAGS = -Wextra

all: ev.so

ev.so: ev.c ev-helper.h
	$(CC) $(CFLAGS) $(LDFLAGS) $< $(LDLIBS) -o $@

ev.c: libev.pxd

example2.so: example2.c ev.so
	$(CC) $(CFLAGS) $(LDFLAGS) $< $(LDLIBS) -o $@


%.c: %.pyx
	$(CYTHON) $(CYTHON_FLAGS) $< -o $@

.PHONY:
clean:
	rm -f ev.so ev.c example2.c example2.so

