cimport cpython

cimport libev

cdef void _ev_callback(libev.ev_loop_t *loop,
                       libev.ev_io *io, int revents) except *:
    cdef Watcher w = <Watcher> io.data
    try:
        if w._ccb != NULL:
            w._ccb(w._cpriv, w, revents)
        elif w._cb is not None:
            w._cb(w, revents)
        else:
            w.event_handler(revents)
    except BaseException:
        libev.ev_unloop(loop, libev.EVUNLOOP_ONE)
        raise


cdef class Error(Exception):
    pass


cdef class Watcher:
    cpdef set_callback(self, cb):
        self._cb = cb

    cdef set_ccallback(self, watcher_cb ccb, void *_cpriv):
        self._ccb = ccb
        self._cpriv = _cpriv

    cdef event_handler(self, int revents):
        raise NotImplementedError


cdef class IO(Watcher):

    def __cinit__(self, *args, **kwargs):
        libev.ev_io_init(&self._io, _ev_callback, 0, 0)

    def __init__(self, fp, int events=EV_READ, cb=None):
        fd = cpython.PyObject_AsFileDescriptor(fp)
        libev.ev_io_init(&self._io, _ev_callback, fd, events)
        self._io.data = <void *> self
        self._cb = cb
        self._ccb = NULL
        self._cpriv = NULL

    def __dealloc__(self):
        self.stop()

    cpdef set(self, int fd, int events=EV_READ):
        if libev.ev_is_active(<libev.ev_watcher *>&self._io):
            raise Error, "Could not modify active watcher"
        libev.ev_io_set(&self._io, fd, events)

    cpdef int fileno(self):
        return self._io.fd

    cpdef start(self):
        libev.ev_io_start(libev.EV_DEFAULT, &self._io)

    cpdef stop(self):
        libev.ev_io_stop(libev.EV_DEFAULT, &self._io)


cdef class Timer(Watcher):

    def __init__(self, cb=None):
        libev.ev_timer_init(&self._timer,
                            <libev.ev_timer_cb> _ev_callback, 0, 0)
        self._timer.data = <void *> self
        self._cb = cb

    def __dealloc__(self):
        self.stop()

    cpdef start(self):
        libev.ev_timer_start(libev.EV_DEFAULT, &self._timer)

    cpdef stop(self):
        libev.ev_timer_stop(libev.EV_DEFAULT, &self._timer)

    cpdef set_timeout(self, float timeout, float periodic=0):
        libev.ev_timer_set(&self._timer, timeout, periodic)

    cpdef set_periodic(self, float timeout):
        libev.ev_timer_set(&self._timer, timeout, timeout)

    cpdef set_oneshot(self, float timeout):
        libev.ev_timer_set(&self._timer, timeout, 0)


cpdef double get_clocks():
    return libev.ev_time()

cpdef sleep(double delay):
    libev.ev_sleep(delay)


cpdef main(bint once=False):
    if once:
        libev.ev_loop(libev.EV_DEFAULT, libev.EVLOOP_ONESHOT)
    else:
        libev.ev_loop(libev.EV_DEFAULT, libev.EVLOOP_NORMAL)

cpdef quit():
    libev.ev_unloop(libev.EV_DEFAULT, libev.EVUNLOOP_ONE)
