PYVERSION = 2.6
PYBASEDIR = /usr
PYTHON    = $(PYBASEDIR)/bin/python$(PYVERION)

CC      = gcc
CFLAGS  = -O2 -g3 -I$(PYBASEDIR)/include/python$(PYVERSION) -W
LDFLAGS = -fPIC -shared -lev
LDLIBS  =

CYTHON = cython
CYTHON_FLAGS = -Wextra

all: ev.so

ev.so: ev.c
	$(CC) $(CFLAGS) $(LDFLAGS) ev.c $(LDLIBS) -o $@

ev.c: libev.pxd ev.pxd

example2.so: example2.c ev.so
	$(CC) $(CFLAGS) $(LDFLAGS) $< $(LDLIBS) -o $@

example3.so: example3.c ev.so
	$(CC) $(CFLAGS) $(LDFLAGS) $< $(LDLIBS) -o $@

test_pyx.so: test_pyx.c ev.so
	$(CC) $(CFLAGS) $(LDFLAGS) $< $(LDLIBS) -o $@

%.c: %.pyx
	$(CYTHON) $(CYTHON_FLAGS) $< -o $@

clean:
	rm -f ev.so ev.c example2.c example2.so test_pyx.c test_pyx.so

.PHONY: test
test: ev.so test_pyx.so
	python runtests.py
