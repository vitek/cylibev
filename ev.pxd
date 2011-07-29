cimport libev

cdef enum:
    EV_NONE  = libev.EV_NONE
    EV_READ  = libev.EV_READ
    EV_WRITE = libev.EV_WRITE

cdef:
    ctypedef void (*watcher_cb)(void *data, Watcher io, int revents) except *


cdef union _any_watcher:
    libev.ev_watcher watcher
    libev.ev_io io
    libev.ev_timer timer
    libev.ev_idle idle
    libev.ev_signal signal



cdef class Watcher:
    cdef _any_watcher _w
    cdef object _cb
    cdef watcher_cb _ccb
    cdef void *_cpriv

    cdef event_handler(self, int revents)
    cpdef set_callback(self, cb)

    # Set low-level C-callback, be careful
    cdef set_ccallback(self, watcher_cb ccb, void *cpriv)

    cpdef bint is_active(self)
    cpdef bint is_pending(self)


cdef class IO(Watcher):
    cpdef int fileno(self)

    cpdef start(self)
    cpdef stop(self)
    cdef event_handler(self, int revents)

    cpdef set(self, fp, int events=*)

cdef class Timer(Watcher):
    cpdef start(self)
    cpdef stop(self)
    cpdef set_timeout(self, float timeout, float periodic=*)
    cpdef set_periodic(self, float timeout)
    cpdef set_oneshot(self, float timeout)
    cdef event_handler(self, int revents)

cdef class Signal(Watcher):
    cpdef start(self)
    cpdef stop(self)
    cpdef set(self, int signum)


cpdef double get_clocks()
cpdef sleep(double delay)

cpdef main(bint once=*)
cpdef quit()
