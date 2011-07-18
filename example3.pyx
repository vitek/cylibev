from posix cimport unistd

cimport ev

cdef class CCallback(ev.IO):
    cdef object fp

    def __init__(self, fp):
        ev.IO.__init__(self, fp)
        self.fp = fp
        self.start()

    cdef event_handler(self, int revents):
        cdef char buf[100]
        cdef size_t len

        len = unistd.read(self.fileno(), buf, sizeof(buf))
        if len <= 0:
            raise IOError
        print 'got input: %r' % buf[:len]

import sys
ccalback = CCallback(sys.stdin)
ev.main()
