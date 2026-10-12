# Example SSH module — copy to ../local/ssh.nix (gitignored) and edit.
# Do not commit real authorized_keys or NOPASSWD rules.
{ ... }:
{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # users.users.<user>.openssh.authorizedKeys.keys = [
  #   "<paste your SSH public key line here>"
  # ];

  # Optional: passwordless nixos-rebuild for the wheel user (local only).
  # security.sudo.extraRules = [{
  #   users = [ "<user>" ];
  #   commands = [{
  #     command = "/run/current-system/sw/bin/nixos-rebuild";
  #     options = [ "NOPASSWD" ];
  #   }];
  # }];
}
