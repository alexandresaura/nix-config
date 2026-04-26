{
  system = {
    defaults = {
      dock = {
        autohide = true;
        autohide-delay = 0.24;
        autohide-time-modifier = 1.0;
        orientation = "bottom";
        tilesize = 48;
        magnification = false;
        minimize-to-application = true;
        show-recents = true;
      };

      finder = {
        CreateDesktop = false;
        AppleShowAllFiles = true;
        AppleShowAllExtensions = true;
        FXPreferredViewStyle = "clmv";
        FXRemoveOldTrashItems = true;
        ShowStatusBar = true;
        QuitMenuItem = false;
        ShowExternalHardDrivesOnDesktop = false;
        ShowHardDrivesOnDesktop = false;
        ShowMountedServersOnDesktop = false;
        ShowRemovableMediaOnDesktop = false;
        ShowPathbar = true;
      };

      NSGlobalDomain = {
        "com.apple.swipescrolldirection" = true;
        "com.apple.keyboard.fnState" = false;
        AppleInterfaceStyle = "Dark";
        AppleSpacesSwitchOnActivate = true;
        ApplePressAndHoldEnabled = false;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
      };

      WindowManager = {
        HideDesktop = true;
        StageManagerHideWidgets = true;
        StandardHideDesktopIcons = true;
        StandardHideWidgets = true;
      };
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };

  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };
}
