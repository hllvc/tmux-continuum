### Behavior when running multiple tmux servers

(This is safe to skip if you're always running a single tmux server.)

If you're an advanced tmux user, you might be running multiple tmux servers at
the same time. Maybe you start the first tmux server with `$ tmux` and then
later another one with e.g. `$ tmux -S/tmp/foo`.

You probably don't want to "auto restore" the same environment in the second
tmux that uses `/tmp/foo` socket. You also probably don't want two tmux
environments both having "auto save" feature on (think about overwrites).

This plugin handles multi-server scenario by giving precedence to the tmux
server that was first started.

In the above example, the server started with `$ tmux` will do "auto
restore" (if enabled) and will start "auto saving".
"Auto restore" or "auto saving" **will not** happen for the second server that
was started later with the `$ tmux -S/tmp/foo` command. The plugin will
detect the presence of another server (`$ tmux`) and give it precedence.

### Opting in to saving on all sockets

If you intentionally run separate tmux servers on different sockets and want
each to save and restore independently, set the following option in your
`.tmux.conf`:

```
set -g @continuum-multiple-sockets on
```

**Trade-off:** When this option is on, all active tmux servers write to the
same tmux-resurrect save file. If two servers save at nearly the same time the
last write wins, potentially overwriting the other server's session. This is
the same race that the default (off) behaviour is designed to prevent. Only
enable this if you understand the trade-off and your workflow avoids concurrent
saves (e.g. only one server is active at a time).
