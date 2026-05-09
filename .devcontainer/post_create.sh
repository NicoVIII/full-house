#!/bin/bash
set -e

sudo apt-get update

# Install apt repository for modern erlang
sudo apt-get install -y curl gnupg apt-transport-https
curl -1sLf "https://keys.openpgp.org/vks/v1/by-fingerprint/0A9AF2115F4687BD29803A206B73A36E6026DFCA" | sudo gpg --dearmor | sudo tee /usr/share/keyrings/com.rabbitmq.team.gpg > /dev/null
sudo tee /etc/apt/sources.list.d/rabbitmq.list <<EOF
## Modern Erlang/OTP releases
##
deb [arch=amd64 signed-by=/usr/share/keyrings/com.rabbitmq.team.gpg] https://deb1.rabbitmq.com/rabbitmq-erlang/ubuntu/noble noble main
deb [arch=amd64 signed-by=/usr/share/keyrings/com.rabbitmq.team.gpg] https://deb2.rabbitmq.com/rabbitmq-erlang/ubuntu/noble noble main
EOF

sudo apt-get -y update
sudo apt-get install -y erlang-dev rebar3 sqlite3
python3 scripts/setup_dev_db.py --seed

# Install skir
bun install -g skir@1.2

# Ensure Bun global binaries are available in all future shells.
bun_path_line='export PATH="/home/vscode/.bun/bin:$PATH"'
for rc_file in /home/vscode/.bashrc /home/vscode/.zshrc; do
	if [ -f "$rc_file" ] && ! grep -Fqx "$bun_path_line" "$rc_file"; then
		echo "$bun_path_line" >> "$rc_file"
	fi
done
