#!/usr/bin/env bash


#boot on nixos install or live
# make sure we have the password for nixos user: `passwd`
# Delete the tailscale machine if exists and create a new ts-auth key: Add device>linux server
# Add the ts-auth to the screts: nix-shell -p sops --run "sops ../nix-secrets/secrets.yaml"
# launch the first step of this script => It will generate the ssh key for new host
# Add the agekey to the sops
# Update secrets with new key: sops updatekeys secrets.yaml
# commit and push to git
# update the flake lock: nix flake update mysecrets
# Boot the live os from where it is needed, then add a password to nixos user to be able to connect in ssh:
# passwd
# continue Install

# to remove a previousknown_host key:
# ssh-keygen -R 150.107.75.153
SECRETS_DIR="../nix-secrets"
SSH_PORT=22

HOSTNAME="cloudnix"
IP="150.107.75.153"

HOSTNAME="cloud"
IP="103.230.156.63"

HOSTNAME="nucnix"
IP="127.0.0.1"
SSH_PORT=60032

# Create a temporary directory
temp=$(mktemp -d)
echo "$temp"

# Function to cleanup temporary directory on exit
cleanup() {
  rm -rf "$temp"
}
trap cleanup EXIT
# $temp="/tmp/new"

# Create the directory where sshd expects to find the host keys
install -d -m755 "$temp/etc/ssh"

# create a new host key:
ssh-keygen -q -N "" -t ed25519 -f "$temp/etc/ssh/ssh_host_ed25519_key"
# copy current host key to the temporary directory
# sudo cp /etc/ssh/ssh_host_ed25519_key "$temp/etc/ssh/ssh_host_ed25519_key"
# sudo chown $USER "$temp/etc/ssh/ssh_host_ed25519_key"
# Set the correct permissions so sshd will accept the key
sudo chmod 600 "$temp/etc/ssh/ssh_host_ed25519_key"

#create an age key from the public host key:
agekey=$(nix-shell -p ssh-to-age --run "cat $temp/etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age")
echo "#####################################"
echo "On current system, edit the github:hcoohb/nix-secrets/.sops.yaml and add the following agekey"
echo "$agekey"
echo "then 'sops updatekeys secrets.yaml' and commit and push"
echo "then 'nix flake update mysecrets' to refresh the lock file"
echo "#####################################"
#updating age-key in nix-secrets/.sops.yaml, make sure it already exists as sed look for it:
sed -i "s/\(&$HOSTNAME\) .*/\1 $agekey/" "$SECRETS_DIR/.sops.yaml"
# now we reencode our secrets with the new key
# sops --config "$SECRETS_DIR/.sops.yaml" updatekeys "$SECRETS_DIR/secrets.yaml"
# if the current system is not part of the nix already, we may need the hcooh private age key to decrypt secerts:
# export SOPS_AGE_KEY=AGE-SECRET-KEY-XXXXXXXXXXXX
nix-shell -p sops --run "sops --config '$SECRETS_DIR/.sops.yaml' updatekeys '$SECRETS_DIR/secrets.yaml'"

# committing in the secrets repo:
git --git-dir="$SECRETS_DIR/.git" --work-tree="$SECRETS_DIR" commit -a -m "Updating for host $HOSTNAME" --no-verify
# now we updte the flake lock to use the recently modifid files
nix --extra-experimental-features 'nix-command flakes' flake update mysecrets --override-input mysecrets "$SECRETS_DIR"
read -n 1 -s -r -p "About to launch the install - Press any key to continue..."


# the previous known_host key:
ssh-keygen -R "$IP"
ssh-keygen -R "$HOSTNAME"

# Install NixOS to the host system with our secrets
# nixos-anywhere --extra-files "$temp" --flake '.#your-host' --target-host root@yourip
nix --extra-experimental-features 'nix-command flakes' run github:nix-community/nixos-anywhere -- --extra-files "$temp" --flake ".#$HOSTNAME" --target-host "nixos@$IP" -p "$SSH_PORT"

# the previous known_host key:
ssh-keygen -R "[$IP]:$SSH_PORT"
ssh-keygen -R "$HOSTNAME"

# sudo nixos-rebuild dry-build --flake github:hcoohb/nix-config --show-trace


### change IP in tailscale if needed and MUST reboot to advertise as exit-node, and disable expiry in tailscale!
