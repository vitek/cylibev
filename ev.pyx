cimport cpython

from libev cimport *

EVENT_IN = EV_READ


cdef void _ev_callback(ev_loop_t *loop, ev_io *io, int revents) except *:
    try:
        (<Watcher>io.data).event_handler(revents)
    except BaseException:
        ev_unloop(loop, EVUNLOOP_ONE)
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
        ev_io_init(&self._io, _ev_callback, 0, 0)

    def __init__(self, fp, cb=None):
        fd = cpython.PyObject_AsFileDescriptor(fp)
        ev_io_init(&self._io, _ev_callback, fd, EV_READ)
        self._io.data = <void *> self
        self._cb = cb
        self._ccb = NULL
        self._cpriv = NULL

    def __dealloc__(self):
        self.stop()

    cpdef int fileno(self):
        return self._io.fd

    cpdef start(self):
        ev_io_start(EV_DEFAULT, &self._io)

    cpdef stop(self):
        ev_io_stop(EV_DEFAULT, &self._io)


cdef class Timer(Watcher):

    def __init__(self, cb=None):
        ev_timer_init(&self._timer, <ev_timer_cb> _ev_callback, 0, 0)
        self._timer.data = <void *> self
        self._cb = cb

    def __dealloc__(self):
        self.stop()

    cpdef start(self):
        ev_timer_start(EV_DEFAULT, &self._timer)

    cpdef stop(self):
        ev_timer_stop(EV_DEFAULT, &self._timer)

    cpdef set_timeout(self, float timeout, float periodic=0):
        ev_timer_set(&self._timer, timeout, periodic)

    cpdef set_periodic(self, float timeout):
        ev_timer_set(&self._timer, timeout, timeout)

    cpdef set_oneshot(self, float timeout):
        ev_timer_set(&self._timer, timeout, 0)


cdef class Idle(Watcher):

    def __init__(self):
        ev_idle_init(&self._idle, <ev_idle_cb> _ev_callback)
        self._idle.data = <void *> self

    def __dealloc__(self):
        self.stop()

    cpdef start(self):
        ev_idle_start(EV_DEFAULT, &self._idle)

    cpdef stop(self):
        ev_idle_stop(EV_DEFAULT, &self._idle)


cpdef double get_clocks():
    return ev_time()

cpdef sleep(double delay):
    ev_sleep(delay)


cpdef main(bint once=False):
    if once:
        ev_loop(EV_DEFAULT, EVLOOP_ONESHOT)
    else:
        ev_loop(EV_DEFAULT, EVLOOP_NORMAL)

cpdef quit():
    ev_unloop(EV_DEFAULT, EVUNLOOP_ONE)
