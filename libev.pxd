cdef extern from "ev-helper.h":
    enum:
        EV_NONE
        EV_READ
        EV_WRITE
        EV_TIMER

    struct ev_loop_t "ev_loop":
        pass

    ev_loop_t *EV_DEFAULT

    struct ev_watcher:
        void *data

    struct ev_io:
        void *data
        int fd

    struct ev_timer:
        void *data

    struct ev_idle:
        void *data

    struct ev_signal:
        void *data

    struct ev_prepare:
        void *data

    struct ev_check:
        void *data

    ctypedef double ev_tstamp

    ev_tstamp ev_time()
    void ev_sleep(ev_tstamp delay)


    ctypedef void (*ev_io_cb)(ev_loop_t *loop,
                              ev_io *obj, int revents) except *
    ctypedef void (*ev_timer_cb)(ev_loop_t *loop,
                              ev_timer *obj, int revents) except *
    ctypedef void (*ev_idle_cb)(ev_loop_t *loop,
                              ev_idle *obj, int revents) except *
    ctypedef void (*ev_signal_cb)(ev_loop_t *loop,
                              ev_signal *obj, int revents) except *
    ctypedef void (*ev_prepare_cb)(ev_loop_t *loop,
                              ev_prepare *obj, int revents) except *
    ctypedef void (*ev_check_cb)(ev_loop_t *loop,
                              ev_check *obj, int revents) except *


    int ev_is_active(ev_watcher *watcher)
    int ev_is_pending(ev_watcher *watcher)

    void ev_io_init(ev_io *obj, ev_io_cb cb, int fd, int events)
    void ev_io_start(ev_loop_t *loop, ev_io *obj)
    void ev_io_stop(ev_loop_t *loop, ev_io *obj)
    void ev_io_set(ev_io *obj, int fd, int events)

    void ev_timer_init(ev_timer *obj, ev_timer_cb cb,
                       float after, float repeat)
    void ev_timer_start(ev_loop_t *loop, ev_timer *obj)
    void ev_timer_stop(ev_loop_t *loop, ev_timer *obj)
    void ev_timer_set(ev_timer *obj, float after, float repeat)

    void ev_idle_init(ev_idle *obj, ev_idle_cb cb)
    void ev_idle_start(ev_loop_t *loop, ev_idle *obj)
    void ev_idle_stop(ev_loop_t *loop, ev_idle *obj)

    void ev_signal_init(ev_signal *obj, ev_signal_cb cb, int signum)
    void ev_signal_set(ev_signal *obj, int signum)
    void ev_signal_start(ev_loop_t *loop, ev_signal *obj)
    void ev_signal_stop(ev_loop_t *loop, ev_signal *obj)

    void ev_prepare_init(ev_prepare *obj, ev_prepare_cb cb)
    void ev_prepare_start(ev_loop_t *loop, ev_prepare *obj)
    void ev_prepare_stop(ev_loop_t *loop, ev_prepare *obj)

    void ev_check_init(ev_check *obj, ev_check_cb cb)
    void ev_check_start(ev_loop_t *loop, ev_check *obj)
    void ev_check_stop(ev_loop_t *loop, ev_check *obj)


    enum:
        EVLOOP_NORMAL   # block and loop
        EVLOOP_NONBLOCK # do not block/wait
        EVLOOP_ONESHOT  # block *once* only

    void ev_loop(ev_loop_t *loop, int flags) except *

    enum:
        EVUNLOOP_CANCEL # undo unloop
        EVUNLOOP_ONE    # unloop once
        EVUNLOOP_ALL    # unloop all loops

    void ev_unloop(ev_loop_t *loop, int how)
