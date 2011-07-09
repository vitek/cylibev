import os
import sys

import ev

def my_timer_cb(timer):
    print 'timed out: %.3f' % ev.get_clocks()

def stdin_cb(io, events):
    print 'input: %r' % os.read(io.fileno(), 1024)

timer = ev.Timer(my_timer_cb)
timer.set_periodic(1)
timer.start()

io = ev.IO(sys.stdin, stdin_cb)
io.start()

ev.main()
