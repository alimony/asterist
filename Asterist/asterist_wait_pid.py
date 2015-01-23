#!/usr/bin/env python

# asterist_wait_pid.py
# Asterist
#
# Created by Markus Amalthea Magnuson on 2015-01-23.
# Copyright (c) 2015 Markus Amalthea Magnuson. All rights reserved.

# The pid_exists() and wait_pid() functions are from psutils:
# https://github.com/giampaolo/psutil/blob/master/psutil/_psposix.py

# psutil is distributed under BSD license reproduced below.
#
# Copyright (c) 2009, Jay Loden, Dave Daeschler, Giampaolo Rodola'
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
#  * Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
#  * Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#  * Neither the name of the psutil authors nor the names of its contributors
#    may be used to endorse or promote products derived from this software without
#    specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import errno
import os
import os.path
import signal
import sys
import time


class TimeoutExpired(Exception):
    pass


def pid_exists(pid):
    """Check whether pid exists in the current process table."""
    if pid == 0:
        # According to "man 2 kill" PID 0 has a special meaning:
        # it refers to <<every process in the process group of the
        # calling process>> so we don't want to go any further.
        # If we get here it means this UNIX platform *does* have
        # a process with id 0.
        return True
    try:
        os.kill(pid, 0)
    except OSError as err:
        if err.errno == errno.ESRCH:
            # ESRCH == No such process
            return False
        elif err.errno == errno.EPERM:
            # EPERM clearly means there's a process to deny access to
            return True
        else:
            # According to "man 2 kill" possible error values are
            # (EINVAL, EPERM, ESRCH) therefore we should never get
            # here. If we do let's be explicit in considering this
            # an error.
            raise err
    else:
        return True


def wait_pid(pid, timeout=None):
    """Wait for process with pid 'pid' to terminate and return its
    exit status code as an integer.
    If pid is not a children of os.getpid() (current process) just
    waits until the process disappears and return None.
    If pid does not exist at all return None immediately.
    Raise TimeoutExpired on timeout expired.
    """
    def check_timeout(delay):
        if timeout is not None:
            if timer() >= stop_at:
                raise TimeoutExpired()
        time.sleep(delay)
        return min(delay * 2, 0.04)

    timer = getattr(time, 'monotonic', time.time)
    if timeout is not None:
        waitcall = lambda: os.waitpid(pid, os.WNOHANG)
        stop_at = timer() + timeout
    else:
        waitcall = lambda: os.waitpid(pid, 0)

    delay = 0.0001
    while True:
        try:
            retpid, status = waitcall()
        except OSError as err:
            if err.errno == errno.EINTR:
                delay = check_timeout(delay)
                continue
            elif err.errno == errno.ECHILD:
                # This has two meanings:
                # - pid is not a child of os.getpid() in which case
                #   we keep polling until it's gone
                # - pid never existed in the first place
                # In both cases we'll eventually return None as we
                # can't determine its exit status code.
                while True:
                    if pid_exists(pid):
                        delay = check_timeout(delay)
                    else:
                        return
            else:
                raise
        else:
            if retpid == 0:
                # WNOHANG was used, pid is still running
                delay = check_timeout(delay)
                continue
            # process exited due to a signal; return the integer of
            # that signal
            if os.WIFSIGNALED(status):
                return os.WTERMSIG(status)
            # process exited using exit(2) system call; return the
            # integer exit(2) system call has been called with
            elif os.WIFEXITED(status):
                return os.WEXITSTATUS(status)
            else:
                # should never happen
                raise RuntimeError("unknown process exit status")

if __name__ == '__main__':
    pid_to_wait_for = int(sys.argv[1])
    pids_to_kill = sys.argv[2:]

    print('Waiting for pid %i to exit' % pid_to_wait_for)

    wait_pid(pid_to_wait_for)

    print('Watched pid %i exited, killing pid(s) %s' % (pid_to_wait_for, ', '.join(pids_to_kill)))

    for p in pids_to_kill:
        pid = int(p)
        try:
            os.kill(pid, signal.SIGINT)
        except OSError as err:
            if err.errno == errno.ESRCH:  # No such process
                print('Killed pid %s' % pid)
            else:
                print('Could not kill pid %i' % pid)

    print('All pids killed, exiting')
