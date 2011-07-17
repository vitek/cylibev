from libev cimport *

cdef:
    ctypedef void (*watcher_cb)(void *data, Watcher io, int revents) except *


cdef class Watcher:
    cdef object _cb
    cdef watcher_cb _ccb
    cdef void *_cpriv

    cdef event_handler(self, int revents)
    cpdef set_callback(self, cb)

    # Set low-level C-callback, be careful
    cdef set_ccallback(self, watcher_cb ccb, void *cpriv)


cdef class IO(Watcher):
    cdef ev_io _io

    cpdef int fileno(self)

    cpdef start(self)
    cpdef stop(self)
    cdef event_handler(self, int revents)


cdef class Timer(Watcher):
    cdef ev_timer _timer

    cpdef start(self)
    cpdef stop(self)
    cpdef set_timeout(self, float timeout, float periodic=*)
    cpdef set_periodic(self, float timeout)
    cpdef set_oneshot(self, float timeout)
    cdef event_handler(self, int revents)


cdef class Idle(Watcher):
    cdef ev_idle _idle

    cpdef start(self)
    cpdef stop(self)
    cdef event_handler(self, int revents)


cpdef double get_clocks()
cpdef sleep(double delay)

cpdef main(bint once=*)
cpdef quit()
