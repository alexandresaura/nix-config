{ config, ... }:
let
  homeDir = config.users.users.${config.system.primaryUser}.home;
in
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
        showhidden = true;
        show-recents = false;
        static-only = true;
        appswitcher-all-displays = true;
        launchanim = false;
        expose-animation-duration = 0.1;
        wvous-tl-corner = 1;
        wvous-tr-corner = 1;
        wvous-bl-corner = 1;
        wvous-br-corner = 13;
      };

      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = true;

        TrackpadFourFingerHorizSwipeGesture = 2;
        TrackpadFourFingerPinchGesture = 0;
        TrackpadFourFingerVertSwipeGesture = 2;
        TrackpadMomentumScroll = true;
        TrackpadPinch = false;
        TrackpadRotate = false;
        TrackpadThreeFingerHorizSwipeGesture = 2;
        TrackpadThreeFingerTapGesture = 2;
        TrackpadThreeFingerVertSwipeGesture = 2;
        TrackpadTwoFingerDoubleTapGesture = false;
        TrackpadTwoFingerFromRightEdgeSwipeGesture = 0;
      };

      finder = {
        CreateDesktop = false;
        AppleShowAllFiles = true;
        AppleShowAllExtensions = true;
        FXDefaultSearchScope = "SCcf";
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "Nlsv";
        FXRemoveOldTrashItems = true;
        NewWindowTarget = "Home";
        QuitMenuItem = false;
        ShowExternalHardDrivesOnDesktop = false;
        ShowHardDrivesOnDesktop = false;
        ShowMountedServersOnDesktop = false;
        ShowRemovableMediaOnDesktop = false;
        ShowPathbar = true;
        ShowStatusBar = true;
        _FXEnableColumnAutoSizing = true;
        _FXShowPosixPathInTitle = true;
        _FXSortFoldersFirst = true;
        _FXSortFoldersFirstOnDesktop = true;
      };

      menuExtraClock = {
        Show24Hour = true;
        ShowDate = 1;
        ShowDayOfWeek = true;
        ShowSeconds = false;
      };

      controlcenter = {
        BatteryShowPercentage = true;
        Bluetooth = true;
        NowPlaying = true;
        Sound = true;
      };

      NSGlobalDomain = {
        "com.apple.swipescrolldirection" = true;
        "com.apple.keyboard.fnState" = false;
        "com.apple.trackpad.scaling" = 2.0;
        AppleICUForce24HourTime = true;
        AppleInterfaceStyle = "Dark";
        AppleKeyboardUIMode = 3;
        AppleMeasurementUnits = "Centimeters";
        AppleMetricUnits = 1;
        AppleScrollerPagingBehavior = true;
        AppleSpacesSwitchOnActivate = true;
        AppleTemperatureUnit = "Celsius";
        ApplePressAndHoldEnabled = false;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticInlinePredictionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSAutomaticWindowAnimationsEnabled = false;
        NSDocumentSaveNewDocumentsToCloud = false;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        NSWindowResizeTime = 0.001;
        NSWindowShouldDragOnGesture = true;
        PMPrintingExpandedStateForPrint = true;
        PMPrintingExpandedStateForPrint2 = true;
      };

      WindowManager = {
        GloballyEnabled = false;
        HideDesktop = true;
        StageManagerHideWidgets = true;
        StandardHideDesktopIcons = true;
        StandardHideWidgets = true;
        EnableStandardClickToShowDesktop = false;
      };

      spaces.spans-displays = false;

      screencapture = {
        location = "${homeDir}/Pictures/Screenshots";
        type = "png";
        disable-shadow = true;
      };

      screensaver = {
        askForPassword = true;
        askForPasswordDelay = 0;
      };

      ActivityMonitor = {
        IconType = 0;
        OpenMainWindow = true;
        ShowCategory = 100;
        SortColumn = "CPUUsage";
        SortDirection = 0;
      };

      LaunchServices.LSQuarantine = false;
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;
      hitoolbox.AppleFnUsageType = "Do Nothing";
      loginwindow.GuestEnabled = false;

      ".GlobalPreferences"."com.apple.mouse.scaling" = 2.0;

      CustomUserPreferences = {
        NSGlobalDomain = {
          "com.apple.trackpad.linear" = true;
          "com.apple.mouse.linear" = true;
        };
        "com.apple.desktopservices" = {
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
      };
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };

  security.pam.services.sudo_local = {
    touchIdAuth = true;
    watchIdAuth = true;
  };
}
