#!/bin/bash

cat > /etc/msmtprc <<EOF
account default
host ${MAILER_HOST:-mailcatcher}
port ${MAILER_PORT:-1025}
auto_from on
EOF
