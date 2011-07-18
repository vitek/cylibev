cimport cpython

cimport libev

cdef void _ev_callback(libev.ev_loop_t *loop,
                       libev.ev_io *io, int revents) except *:
    try:
        (<Watcher>io.data).event_handler(revents)
    except BaseException:
        libev.ev_unloop(loop, libev.EVUNLOOP_ONE)
        raise


cdef class Watcher:
    cpdef set_callback(self, cb):
        self._cb = cb

    cdef set_ccallback(self, watcher_cb ccb, void *_cpriv):
        self._ccb = ccb
        self._cpriv = _cpriv

    cdef event_handler(self, int revents):
        if self._ccb != NULL:
            self._ccb(self._cpriv, self, revents)
        if self._cb is not None:
            self._cb(self, revents)


cdef class IO(Watcher):

    def __cinit__(self, *args, **kwargs):
        libev.ev_io_init(&self._io, _ev_callback, 0, 0)

    def __init__(self, fp, cb=None):
        fd = cpython.PyObject_AsFileDescriptor(fp)
        libev.ev_io_init(&self._io, _ev_callback, fd, EV_READ)
        self._io.data = <void *> self
        self._cb = cb
        self._ccb = NULL
        self._cpriv = NULL

    def __dealloc__(self):
        self.stop()

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


cdef class Idle(Watcher):

    def __init__(self):
        libev.ev_idle_init(&self._idle, <libev.ev_idle_cb> _ev_callback)
        self._idle.data = <void *> self

    def __dealloc__(self):
        self.stop()

    cpdef start(self):
        libev.ev_idle_start(libev.EV_DEFAULT, &self._idle)

    cpdef stop(self):
        libev.ev_idle_stop(libev.EV_DEFAULT, &self._idle)


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
