import os
import sys

import ev

def my_timer_cb(timer, events):
    print 'timed out: %.3f' % ev.get_clocks()

def stdin_cb(io, events):
    data = os.read(io.fileno(), 1024)
    if not data:
        raise OSError
    print 'input: %r' % data

timer = ev.Timer(cb=my_timer_cb)
timer.set_periodic(1)
timer.start()

io = ev.IO(sys.stdin, cb=stdin_cb)
io.start()

ev.main()
