{
  inputs,
  config,
  pkgs,
  ...
}:
let
  secretspath = builtins.toString inputs.mysecrets;
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];
  environment.systemPackages = with pkgs; [

    # secrets
    age
    sops

  ];

  sops = {

    defaultSopsFile = "${secretspath}/secrets.yaml";
    #     defaultSopsFile = "../../../secrets.yaml";
    validateSopsFiles = false;

    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };

    # secrets will be output in /run/secrets (accessible by root only unless specified)
    #     secrets = {
    #       new_val = { };
    # #       hello = {};
    #     };
  };
}
