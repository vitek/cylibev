import os
import signal

import ev


def pipe():
    r, w = os.pipe()
    return os.fdopen(r, 'r'), os.fdopen(w, 'w')


class TestSimpleIO:
    """
    >>> r, w = pipe()
    >>> reader = TestSimpleIO(r)
    >>> reader.io.is_active()
    True
    >>> reader.io.is_pending()
    False
    >>> w.write("Hello, world!")
    >>> w.close()
    >>> ev.main()
    >>> r.close()
    >>> reader.io.is_active()
    True
    >>> reader.io.stop()
    >>> reader.io.is_active()
    False
    >>> reader.data
    'Hello, world!'
    """

    def __init__(self, fd):
        self.io = ev.IO(fd, cb=self.on_input)
        self.io.start()

    def on_input(self, io, events):
        self.data = os.read(io.fileno(), 4096)
        ev.quit()

class TestTimerOneShoot:
    """
    >>> t = TestTimerOneShoot()
    >>> t.timer.is_active()
    True
    >>> t.timer.is_pending()
    False
    >>> ev.main()
    >>> t.timedout
    True
    >>> t.timer.stop()
    >>> t.timer.is_active()
    False
    """

    def __init__(self):
        self.timer = ev.Timer(.1, cb=self.on_timeout)
        self.timer.start()
        self.timedout = False

    def on_timeout(self, timer, events):
        self.timedout = True
        ev.quit()


class TestTimerPeriodic:
    """
    >>> t = TestTimerPeriodic()
    >>> t.timer.is_active()
    True
    >>> t.timer.is_pending()
    False
    >>> ev.main()
    >>> t.counter
    10
    >>> t.timer.stop()
    >>> t.timer.is_active()
    False
    """

    def __init__(self):
        self.timer = ev.Timer(.001, .001, cb=self.on_timeout)
        self.timer.start()
        self.counter = 0

    def on_timeout(self, timer, events):
        self.counter += 1
        if self.counter >= 10:
            ev.quit()


class TestSignal:
    """
    >>> o = TestSignal()
    >>> ev.main()
    >>> o.interrupted
    True
    """
    interrupted = False

    def __init__(self):
        self.timer = ev.Timer(.001, cb=self.timer_event)
        self.signal = ev.Signal(signal.SIGHUP, cb=self.sigint_event)
        self.signal.start()
        self.timer.start()

    def timer_event(self, timer, events):
        os.kill(os.getpid(), signal.SIGHUP)

    def sigint_event(self, sig, events):
        self.interrupted = True
        ev.quit()


def test_io_error():
    """
    >>> io = ev.IO(0)
    >>> io.start()
    >>> io.set(1)
    Traceback (most recent call last):
        ...
    Error: Could not modify active watcher
    >>> io.stop()
    >>> io.set(1)
    """

def test_timer_error():
    """
    >>> timer = ev.Timer()
    >>> timer.start()
    >>> timer.set_timeout(1, 1)
    Traceback (most recent call last):
        ...
    Error: Could not modify active watcher
    >>> timer.set_periodic(1)
    Traceback (most recent call last):
        ...
    Error: Could not modify active watcher
    >>> timer.set_oneshot(1)
    Traceback (most recent call last):
        ...
    Error: Could not modify active watcher
    >>> timer.stop()
    """

if __name__ == "__main__":
    import doctest
    doctest.testmod()
