{ pkgs, ... }:
let
  nginxWrapper = pkgs.writeShellScript "nginx-wrapper" ''
    set -e
    mkdir -p "$HOME/.config/nginx" "$HOME/.local/share/nginx"
    ln -sfn "${pkgs.nginx}/conf/mime.types" "$HOME/.config/nginx/mime.types"
    exec ${pkgs.nginx}/bin/nginx \
      -c "$HOME/.config/nginx/nginx.conf" \
      -p "$HOME/.local/share/nginx" \
      -e /tmp/nginx.error.log \
      -g "daemon off; pid /tmp/nginx.pid;"
  '';
in
{
  environment.systemPackages = [ pkgs.nginx ];

  # nginx was built with --http-log-path=/var/log/nginx/access.log as the
  # compile-time default. If the user's nginx.conf does not set access_log,
  # nginx falls back to that path. Ensure it exists and is writable.
  system.activationScripts.extraActivation.text = ''
    mkdir -p /var/log/nginx
    chown alexandre:staff /var/log/nginx
  '';

  launchd.user.agents.nginx = {
    serviceConfig = {
      ProgramArguments = [ "${nginxWrapper}" ];
      RunAtLoad = true;
      KeepAlive = {
        SuccessfulExit = false;
      };
      StandardOutPath = "/tmp/nginx.log";
      StandardErrorPath = "/tmp/nginx.err.log";
    };
  };
}
