Cylibev
=======

Cylibev is Cython_ (and Python) bindings for libev_ library. The goal is to
provide Cython interface to libev library without python-space interactione.

Cylibev isn't complete libev wrapper it only supports IO channels and timers,
if you are looking for a more future reach library, please take a look at pyev_

.. _libev: http://software.schmorp.de/pkg/libev.html
.. _Cython: http://cython.org
.. _pyev: http://code.google.com/p/pyev/


Example 1: Python callbacks
===========================

The only difference between Python and Cython mode is how callbacks work.

::

        >>> import ev

        >>> def my_timer_cb(timer, events):
        ...     print 'Timedout!'

        >>> timer = ev.Timer(1., cb=my_timer_cb)
        >>> timer.start()
        >>> ev.main()

Example 2: Cython subclassing
=============================

::

        # cython
        cimport ev

        cdef class MyTimer(ev.Timer):
            cdef event_handler(self, int revents):
                 print 'Timedout'

        timer = ev.MyTimer(1.)
        timer.start()
        ev.main()

Example 3: Low-level C-callbacks
================================

::

        # cython
        cimport ev

        cdef class MyObject:
             def __init__(self):
                 self.timer = ev.Timer(1.)
                 self.set_ccallback(<ev.watcher_cb>self.timer_event,
                                    <void *> self)
                 self.start()

             cdef void timer_event(self, ev.IO io, int event) except *:
                  print 'Timedout'

        obj = MyObject()
        ev.main()
