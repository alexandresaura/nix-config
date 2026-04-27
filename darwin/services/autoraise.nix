{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.autoraise ];

  launchd.user.agents.autoraise = {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.autoraise}/bin/autoraise"
        "-delay"
        "1"
      ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/autoraise.log";
      StandardErrorPath = "/tmp/autoraise.err.log";
    };
  };
}
