from posix cimport unistd

cimport ev

cdef class CCallback:
    cdef ev.IO io
    cdef object fp

    def __init__(self, fp):
        self.fp = fp
        self.io = ev.IO(fp)
        # Warning! Casting pyobject to void * isn't safe
        self.io.set_ccallback(<ev.io_cb>self.handle_event, <void *> self)
        self.io.start()

    cdef void handle_event(self, ev.IO io, int event) except *:
        cdef char buf[100]
        cdef size_t len

        len = unistd.read(io.fileno(), buf, sizeof(buf))
        if len <= 0:
            raise IOError
        print 'got input: %r' % buf[:len]


import sys
ccalback = CCallback(sys.stdin)
ev.main()
