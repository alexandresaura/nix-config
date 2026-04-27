{ pkgs, ... }:
let
  redisWrapper = pkgs.writeShellScript "redis-wrapper" ''
    set -e
    mkdir -p "$HOME/.config/redis" "$HOME/.local/share/redis"
    cd "$HOME/.local/share/redis"
    if [ -f "$HOME/.config/redis/redis.conf" ]; then
      exec ${pkgs.redis}/bin/redis-server "$HOME/.config/redis/redis.conf"
    else
      exec ${pkgs.redis}/bin/redis-server --dir "$HOME/.local/share/redis"
    fi
  '';
in
{
  environment.systemPackages = [ pkgs.redis ];

  launchd.user.agents.redis = {
    serviceConfig = {
      ProgramArguments = [ "${redisWrapper}" ];
      RunAtLoad = true;
      KeepAlive = {
        SuccessfulExit = false;
      };
      StandardOutPath = "/tmp/redis.log";
      StandardErrorPath = "/tmp/redis.err.log";
    };
  };
}
