cimport cpython

cimport libev

cdef void _ev_callback(libev.ev_loop_t *loop,
                       libev.ev_watcher *watcher,
                       int revents) except *:
    cdef Watcher w = <Watcher> watcher.data
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
    def __cinit__(self, *args, **kwargs):
        libev.ev_init(&self._w.watcher,  _ev_callback)
        self._w.watcher.data = <void *> self
        self._ccb = NULL
        self._cpriv = NULL

    cpdef set_callback(self, cb):
        self._cb = cb

    cdef set_ccallback(self, watcher_cb ccb, void *_cpriv):
        self._ccb = ccb
        self._cpriv = _cpriv

    cdef event_handler(self, int revents):
        raise NotImplementedError




cdef class IO(Watcher):
    def __init__(self, fp, int events=EV_READ, cb=None):
        fd = cpython.PyObject_AsFileDescriptor(fp)
        libev.ev_io_set(&self._w.io, fd, events)
        self._cb = cb

    def __dealloc__(self):
        self.stop()

    cpdef set(self, int fd, int events=EV_READ):
        if libev.ev_is_active(<libev.ev_watcher *>&self._w.io):
            raise Error, "Could not modify active watcher"
        libev.ev_io_set(&self._w.io, fd, events)

    cpdef int fileno(self):
        return self._w.io.fd

    cpdef start(self):
        libev.ev_io_start(libev.EV_DEFAULT, &self._w.io)

    cpdef stop(self):
        libev.ev_io_stop(libev.EV_DEFAULT, &self._w.io)


cdef class Timer(Watcher):
    def __init__(self, float timeout=0, float periodic=0, cb=None):
        libev.ev_timer_set(&self._w.timer, timeout, periodic)
        self._cb = cb

    def __dealloc__(self):
        self.stop()

    cpdef start(self):
        libev.ev_timer_start(libev.EV_DEFAULT, &self._w.timer)

    cpdef stop(self):
        libev.ev_timer_stop(libev.EV_DEFAULT, &self._w.timer)

    cpdef set_timeout(self, float timeout, float periodic=0):
        if libev.ev_is_active(<libev.ev_watcher *>&self._w.io):
            raise Error, "Could not modify active watcher"
        libev.ev_timer_set(&self._w.timer, timeout, periodic)

    cpdef set_periodic(self, float timeout):
        if libev.ev_is_active(<libev.ev_watcher *>&self._w.io):
            raise Error, "Could not modify active watcher"
        libev.ev_timer_set(&self._w.timer, timeout, timeout)

    cpdef set_oneshot(self, float timeout):
        if libev.ev_is_active(<libev.ev_watcher *>&self._w.io):
            raise Error, "Could not modify active watcher"
        libev.ev_timer_set(&self._w.timer, timeout, 0)


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
