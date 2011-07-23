import ev
cimport ev

from test_py import pipe


cdef class TestSubclassing(ev.Timer):
    """
    >>> t = TestSubclassing()
    >>> t.is_active()
    True
    >>> ev.main()
    >>> t.timedout
    True
    >>> t.is_active()
    False
    """

    cdef public bint timedout

    def __init__(self):
        ev.Timer.__init__(self, .001)
        self.timedout = False
        self.start()

    cdef event_handler(self, int revents):
        self.timedout = True
        ev.quit()


cdef class TestCCallback(ev.Timer):
    """
    >>> t = TestCCallback()
    >>> t.is_active()
    True
    >>> ev.main()
    >>> t.timedout
    True
    >>> t.is_active()
    False
    """

    cdef public bint timedout

    def __init__(self):
        ev.Timer.__init__(self, .001)
        self.timedout = False
        self.set_ccallback(<ev.watcher_cb>self.ccallback,
                           <void *> self)
        self.start()

    cdef void ccallback(self, ev.IO io, int event) except *:
        self.timedout = True
        ev.quit()


cdef class TestCCallbackExc(ev.Timer):
    """
    >>> t = TestCCallbackExc()
    >>> ev.main()
    Traceback (most recent call last):
        ...
    Error: oops
    """

    def __init__(self):
        ev.Timer.__init__(self, .001)
        self.set_ccallback(<ev.watcher_cb>self.ccallback,
                           <void *> self)
        self.start()

    cdef void ccallback(self, ev.IO io, int event) except *:
        raise ev.Error, "oops"
