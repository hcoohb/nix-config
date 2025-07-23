#!/usr/bin/env bash


#boot on nixos install or live
# make sure we have the password for nixos user: `passwd`
# launch this script

# to remove a previousknown_host key:
# ssh-keygen -R 150.107.75.153


# Create a temporary directory
temp=$(mktemp -d)
echo "$temp"

# Function to cleanup temporary directory on exit
cleanup() {
  rm -rf "$temp"
}
# trap cleanup EXIT

# Create the directory where sshd expects to find the host keys
install -d -m755 "$temp/etc/ssh"

# copy current host key to the temporary directory
sudo cp /etc/ssh/ssh_host_ed25519_key "$temp/etc/ssh/ssh_host_ed25519_key"
sudo chown $USER "$temp/etc/ssh/ssh_host_ed25519_key"
# Set the correct permissions so sshd will accept the key
sudo chmod 600 "$temp/etc/ssh/ssh_host_ed25519_key"
echo "key copied"
# Install NixOS to the host system with our secrets
# nixos-anywhere --extra-files "$temp" --flake '.#your-host' --target-host root@yourip
nix run github:nix-community/nixos-anywhere -- --extra-files "$temp" --flake .#cloudnix --target-host nixos@150.107.75.153 --no-reboot

# the previous known_host key:
ssh-keygen -R 150.107.75.153

# now we can connect to the host to delete the ssh_host_ed25519_key
