#ifndef __EV_HELPER_H__
#define __EV_HELPER_H__

#include "ev.h"

#ifndef EVLOOP_NORMAL
#define EVLOOP_NORMAL 0
#endif

typedef void (*ev_watcher_cb)(EV_P_ struct ev_watcher *w, int revents);
typedef void (*ev_io_cb)(EV_P_ struct ev_io *w, int revents);
typedef void (*ev_timer_cb)(EV_P_ struct ev_timer *w, int revents);
typedef void (*ev_idle_cb)(EV_P_ struct ev_idle *w, int revents);
typedef void (*ev_signal_cb)(EV_P_ struct ev_signal *w, int revents);
typedef void (*ev_prepare_cb)(EV_P_ struct ev_prepare *w, int revents);
typedef void (*ev_check_cb)(EV_P_ struct ev_prepare *w, int revents);

#endif /* __EV_HELPER_H__ */
