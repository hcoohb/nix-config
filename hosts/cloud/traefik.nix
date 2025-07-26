{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  secretspath = builtins.toString inputs.mysecrets;
in
{

  services.traefik = {
    enable = true;
    environmentFiles = [ config.sops.templates.cloud_traefik_env.path ];
    staticConfigFile = "/etc/traefik.toml";
    #     dynamicConfigFile = "/etc/traefik-dynamic.toml";
  };
  users.users.traefik.extraGroups = [ "docker" ];
  environment.etc."traefik.toml".source = "${secretspath}/cloud/traefik/traefik.toml";
  environment.etc."traefik-dynamic.toml".source = "${inputs.mysecrets}/cloud/traefik/dynamic.toml";
  home-manager.users.hcooh.home.file."traefik/traefik-dynamic.toml".source =
    "${inputs.mysecrets}/cloud/traefik/dynamic.toml";

  sops.secrets = {
    email = { };
    CF_DNS_API_TOKEN = { };
  };
  sops.templates.cloud_traefik_env.content = ''
    CF_API_EMAIL=${config.sops.placeholder.email}
    CF_DNS_API_TOKEN=${config.sops.placeholder.CF_DNS_API_TOKEN}
  '';
}
