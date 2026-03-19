# Noctalia shell — replaces hyprpanel, rofi, swaync, hyprpaper
{ config, lib, ... }:
let
  c = import ../common/theme/colours.nix;
  hex = v: "#${v}";
in
{
  imports = [ ./vex-timer-plugin.nix ];
  programs.noctalia-shell = {
    enable = true;

    # ── Material Design 3 colour tokens mapped from Catppuccin Mocha ──
    # Primary (lavender — soft), Secondary (teal), Tertiary (peach) — chill base, colourful accents
    colors = lib.mapAttrs (_: lib.mkForce) {
      mPrimary = hex c.lavender;
      mOnPrimary = hex c.crust;
      mSecondary = hex c.teal;
      mOnSecondary = hex c.crust;
      mTertiary = hex c.peach;
      mOnTertiary = hex c.crust;
      mError = hex c.red;
      mOnError = hex c.crust;
      mSurface = hex c.base;
      mOnSurface = hex c.text;
      mSurfaceVariant = hex c.surface0;
      mOnSurfaceVariant = hex c.subtext1;
      mOutline = hex c.overlay0;
      mShadow = hex c.crust;
      mHover = hex c.surface1;
      mOnHover = hex c.text;
    };

    # ── Settings ──
    settings = {
      settingsVersion = 59;

      # ── Bar ──
      bar = {
        barType = "simple";
        position = "top";
        monitors = [ "DP-2" ];
        density = "spacious";
        showOutline = false;
        showCapsule = true;
        capsuleOpacity = 0.65;
        capsuleColorKey = "none";
        widgetSpacing = 3;
        contentPadding = 15;
        fontScale = 1.3;
        enableExclusionZoneInset = true;
        backgroundOpacity = 0.93;
        useSeparateOpacity = false;
        floating = false;
        marginVertical = 4;
        marginHorizontal = 4;
        frameThickness = 8;
        frameRadius = 12;
        outerCorners = true;
        hideOnOverview = false;
        displayMode = "always_visible";
        autoHideDelay = 500;
        autoShowDelay = 150;
        showOnWorkspaceSwitch = true;
        mouseWheelAction = "none";
        reverseScroll = false;
        mouseWheelWrap = true;
        middleClickAction = "none";
        middleClickFollowMouse = false;
        middleClickCommand = "";
        rightClickAction = "controlCenter";
        rightClickFollowMouse = true;
        rightClickCommand = "";
        screenOverrides = [ ];
        widgets = {
          left = [
            {
              id = "SystemMonitor";
              compactMode = true;
              diskPath = "/";
              iconColor = "secondary";
              showCpuCores = false;
              showCpuFreq = false;
              showCpuTemp = true;
              showCpuUsage = true;
              showDiskAvailable = false;
              showDiskUsage = false;
              showDiskUsageAsPercent = false;
              showGpuTemp = false;
              showLoadAverage = false;
              showMemoryAsPercent = false;
              showMemoryUsage = true;
              showNetworkStats = false;
              showSwapUsage = false;
              textColor = "secondary";
              useMonospaceFont = true;
              usePadding = false;
            }
            {
              id = "MediaMini";
              compactMode = false;
              hideMode = "hidden";
              hideWhenIdle = false;
              maxWidth = 250;
              panelShowAlbumArt = true;
              scrollingMode = "hover";
              showAlbumArt = true;
              showArtistFirst = true;
              showProgressRing = true;
              showVisualizer = true;
              textColor = "primary";
              useFixedWidth = false;
              visualizerType = "mirrored";
            }
          ];
          center = [
            {
              id = "Workspace";
              characterCount = 3;
              colorizeIcons = true;
              emptyColor = "tertiary";
              enableScrollWheel = true;
              focusedColor = "primary";
              followFocusedScreen = false;
              fontWeight = "regular";
              groupedBorderOpacity = 1;
              hideUnoccupied = true;
              iconScale = 0.58;
              labelMode = "none";
              occupiedColor = "secondary";
              pillSize = 0.8;
              showApplications = true;
              showApplicationsHover = false;
              showBadge = true;
              showLabelsOnlyWhenOccupied = true;
              unfocusedIconsOpacity = 0.5;
            }
            {
              id = "ActiveWindow";
              colorizeIcons = false;
              hideMode = "hidden";
              maxWidth = 145;
              scrollingMode = "hover";
              showIcon = true;
              textColor = "none";
              useFixedWidth = false;
            }
          ];
          right = [
            {
              id = "Tray";
              blacklist = [ ];
              chevronColor = "none";
              colorizeIcons = false;
              drawerEnabled = true;
              hidePassive = false;
              pinned = [ ];
            }
            {
              id = "Volume";
              displayMode = "onhover";
              iconColor = "secondary";
              middleClickCommand = "pwvucontrol || pavucontrol";
              textColor = "secondary";
            }
            {
              id = "Microphone";
              displayMode = "onhover";
              iconColor = "tertiary";
              middleClickCommand = "pwvucontrol || pavucontrol";
              textColor = "tertiary";
            }
            {
              id = "VPN";
              displayMode = "onhover";
              iconColor = "primary";
              textColor = "primary";
            }
            {
              id = "Network";
              displayMode = "onhover";
              iconColor = "primary";
              textColor = "primary";
            }
            {
              id = "plugin:vex-timer";
            }
            {
              id = "Clock";
              clockColor = "tertiary";
              customFont = "";
              formatHorizontal = "HH:mm ddd, MMM dd";
              formatVertical = "HH mm - dd MM";
              tooltipFormat = "HH:mm ddd, MMM dd";
              useCustomFont = false;
            }
            {
              id = "NotificationHistory";
              hideWhenZero = false;
              hideWhenZeroUnread = false;
              iconColor = "primary";
              showUnreadBadge = true;
              unreadBadgeColor = "error";
            }
            {
              id = "ControlCenter";
              colorizeDistroLogo = false;
              colorizeSystemIcon = "primary";
              customIconPath = "";
              enableColorization = true;
              icon = "noctalia";
              useDistroLogo = false;
            }
          ];
        };
      };

      # ── General ──
      general = {
        avatarImage = "/home/shane/.face";
        dimmerOpacity = 0.2;
        showScreenCorners = false;
        forceBlackScreenCorners = false;
        scaleRatio = 1.25;
        radiusRatio = 1;
        iRadiusRatio = 1;
        boxRadiusRatio = 1;
        screenRadiusRatio = 1;
        animationSpeed = 1;
        animationDisabled = false;
        compactLockScreen = false;
        lockScreenAnimations = false;
        lockOnSuspend = true;
        showSessionButtonsOnLockScreen = true;
        showHibernateOnLockScreen = false;
        enableLockScreenMediaControls = false;
        enableShadows = true;
        enableBlurBehind = true;
        shadowDirection = "bottom_right";
        shadowOffsetX = 2;
        shadowOffsetY = 3;
        language = "";
        allowPanelsOnScreenWithoutBar = true;
        showChangelogOnStartup = false;
        telemetryEnabled = false;
        enableLockScreenCountdown = true;
        lockScreenCountdownDuration = 10000;
        autoStartAuth = false;
        allowPasswordWithFprintd = false;
        clockStyle = "custom";
        clockFormat = "hh\\nmm";
        passwordChars = false;
        lockScreenMonitors = [ ];
        lockScreenBlur = 0;
        lockScreenTint = 0;
        keybinds = {
          keyUp = [ "Up" ];
          keyDown = [ "Down" ];
          keyLeft = [ "Left" ];
          keyRight = [ "Right" ];
          keyEnter = [ "Return" "Enter" ];
          keyEscape = [ "Esc" ];
          keyRemove = [ "Del" ];
        };
        reverseScroll = false;
      };

      # ── UI ──
      ui = {
        fontDefault = "Mononoki Nerd Font";
        fontFixed = "monospace";
        fontDefaultScale = 0.85;
        fontFixedScale = 0.95;
        tooltipsEnabled = true;
        scrollbarAlwaysVisible = true;
        boxBorderEnabled = false;
        panelBackgroundOpacity = 0.93;
        translucentWidgets = false;
        panelsAttachedToBar = true;
        settingsPanelMode = "attached";
        settingsPanelSideBarCardStyle = false;
      };

      # ── Location (Melbourne) ──
      location = {
        name = "Melbourne";
        weatherEnabled = true;
        weatherShowEffects = true;
        useFahrenheit = false;
        use12hourFormat = true;
        showWeekNumberInCalendar = false;
        showCalendarEvents = true;
        showCalendarWeather = true;
        analogClockInCalendar = false;
        firstDayOfWeek = 1;
        hideWeatherTimezone = false;
        hideWeatherCityName = false;
      };

      # ── Calendar ──
      calendar = {
        cards = [
          { enabled = true; id = "calendar-header-card"; }
          { enabled = true; id = "calendar-month-card"; }
          { enabled = true; id = "weather-card"; }
        ];
      };

      # ── Wallpaper ──
      wallpaper = {
        enabled = true;
        overviewEnabled = false;
        directory = "${config.home.homeDirectory}/wallpapers";
        monitorDirectories = [
          { directory = "${config.home.homeDirectory}/wallpapers"; name = "DP-2"; wallpaper = ""; }
          { directory = "${config.home.homeDirectory}/wallpapers"; name = "HDMI-A-1"; wallpaper = ""; }
        ];
        enableMultiMonitorDirectories = false;
        showHiddenFiles = false;
        viewMode = "shuffle";
        setWallpaperOnAllMonitors = true;
        fillMode = "crop";
        fillColor = "#000000";
        useSolidColor = false;
        solidColor = "#1a1a2e";
        automationEnabled = true;
        wallpaperChangeMode = "random";
        randomIntervalSec = 300;
        transitionDuration = 1500;
        transitionType = [ "pixelate" "fade" ];
        skipStartupTransition = false;
        transitionEdgeSmoothness = 0.05;
        panelPosition = "follow_bar";
        hideWallpaperFilenames = false;
        overviewBlur = 0.4;
        overviewTint = 0.6;
        useWallhaven = false;
        wallhavenQuery = "";
        wallhavenSorting = "relevance";
        wallhavenOrder = "desc";
        wallhavenCategories = "111";
        wallhavenPurity = "100";
        wallhavenRatios = "";
        wallhavenApiKey = "";
        wallhavenResolutionMode = "atleast";
        wallhavenResolutionWidth = "";
        wallhavenResolutionHeight = "";
        sortOrder = "name";
        favorites = [ ];
      };

      # ── App launcher ──
      appLauncher = {
        enableClipboardHistory = true;
        autoPasteClipboard = false;
        enableClipPreview = true;
        clipboardWrapText = true;
        enableClipboardSmartIcons = true;
        enableClipboardChips = true;
        clipboardWatchTextCommand = "wl-paste --type text --watch cliphist store";
        clipboardWatchImageCommand = "wl-paste --type image --watch cliphist store";
        position = "center";
        pinnedApps = [ ];
        sortByMostUsed = true;
        terminalCommand = "ghostty -e";
        customLaunchPrefixEnabled = false;
        customLaunchPrefix = "";
        viewMode = "list";
        showCategories = true;
        iconMode = "tabler";
        showIconBackground = false;
        enableSettingsSearch = true;
        enableWindowsSearch = true;
        enableSessionSearch = true;
        ignoreMouseInput = false;
        screenshotAnnotationTool = "";
        overviewLayer = false;
        density = "comfortable";
      };

      # ── Control center ──
      controlCenter = {
        position = "close_to_bar_button";
        diskPath = "/";
        shortcuts = {
          left = [
            { id = "Network"; }
            { id = "Bluetooth"; }
            { id = "WallpaperSelector"; }
            { id = "NoctaliaPerformance"; }
          ];
          right = [
            { id = "Notifications"; }
            { id = "KeepAwake"; }
            { id = "NightLight"; }
          ];
        };
        cards = [
          { enabled = true; id = "profile-card"; }
          { enabled = true; id = "shortcuts-card"; }
          { enabled = true; id = "audio-card"; }
          { enabled = true; id = "weather-card"; }
          { enabled = true; id = "media-sysmon-card"; }
        ];
      };

      # ── System monitor ──
      systemMonitor = {
        cpuWarningThreshold = 80;
        cpuCriticalThreshold = 90;
        tempWarningThreshold = 80;
        tempCriticalThreshold = 90;
        gpuWarningThreshold = 80;
        gpuCriticalThreshold = 90;
        memWarningThreshold = 80;
        memCriticalThreshold = 90;
        swapWarningThreshold = 80;
        swapCriticalThreshold = 90;
        diskWarningThreshold = 80;
        diskCriticalThreshold = 90;
        diskAvailWarningThreshold = 20;
        diskAvailCriticalThreshold = 10;
        batteryWarningThreshold = 20;
        batteryCriticalThreshold = 5;
        enableDgpuMonitoring = false;
        useCustomColors = false;
        warningColor = hex c.peach;
        criticalColor = hex c.red;
        externalMonitor = "resources || missioncenter || jdsystemmonitor || corestats || system-monitoring-center || gnome-system-monitor || plasma-systemmonitor || mate-system-monitor || ukui-system-monitor || deepin-system-monitor || pantheon-system-monitor";
      };

      # ── Noctalia performance ──
      noctaliaPerformance = {
        disableWallpaper = true;
        disableDesktopWidgets = true;
      };

      # ── Dock ──
      dock = {
        enabled = true;
        position = "bottom";
        displayMode = "auto_hide";
        dockType = "floating";
        backgroundOpacity = 1;
        floatingRatio = 1;
        size = 1;
        onlySameOutput = true;
        monitors = [ ];
        pinnedApps = [ ];
        colorizeIcons = false;
        showLauncherIcon = false;
        launcherPosition = "end";
        launcherUseDistroLogo = false;
        launcherIcon = "";
        launcherIconColor = "none";
        pinnedStatic = false;
        inactiveIndicators = false;
        groupApps = false;
        groupContextMenuMode = "extended";
        groupClickAction = "cycle";
        groupIndicatorStyle = "dots";
        deadOpacity = 0.6;
        animationSpeed = 1;
        sitOnFrame = false;
        showDockIndicator = false;
        indicatorThickness = 3;
        indicatorColor = "secondary";
        indicatorOpacity = 0.6;
      };

      # ── Network ──
      network = {
        wifiEnabled = true;
        airplaneModeEnabled = false;
        bluetoothRssiPollingEnabled = false;
        bluetoothRssiPollIntervalMs = 60000;
        networkPanelView = "wifi";
        wifiDetailsViewMode = "grid";
        bluetoothDetailsViewMode = "grid";
        bluetoothHideUnnamedDevices = false;
        disableDiscoverability = false;
        bluetoothAutoConnect = true;
      };

      # ── Session menu ──
      sessionMenu = {
        enableCountdown = true;
        countdownDuration = 10000;
        position = "center";
        showHeader = true;
        showKeybinds = true;
        largeButtonsStyle = true;
        largeButtonsLayout = "single-row";
        powerOptions = [
          { action = "lock"; command = ""; countdownEnabled = true; enabled = true; keybind = "1"; }
          { action = "suspend"; command = ""; countdownEnabled = true; enabled = true; keybind = "2"; }
          { action = "hibernate"; command = ""; countdownEnabled = true; enabled = true; keybind = "3"; }
          { action = "reboot"; command = ""; countdownEnabled = true; enabled = true; keybind = "4"; }
          { action = "logout"; command = ""; countdownEnabled = true; enabled = true; keybind = "5"; }
          { action = "shutdown"; command = ""; countdownEnabled = true; enabled = true; keybind = "6"; }
          { action = "rebootToUefi"; command = ""; countdownEnabled = true; enabled = true; keybind = "7"; }
          { action = "userspaceReboot"; command = ""; countdownEnabled = true; enabled = false; keybind = ""; }
        ];
      };

      # ── Notifications ──
      notifications = {
        enabled = true;
        enableMarkdown = false;
        density = "default";
        monitors = [ "DP-2" ];
        location = "top_right";
        overlayLayer = true;
        backgroundOpacity = 0.6;
        respectExpireTimeout = false;
        lowUrgencyDuration = 2;
        normalUrgencyDuration = 3;
        criticalUrgencyDuration = 5;
        clearDismissed = true;
        saveToHistory = {
          low = true;
          normal = true;
          critical = true;
        };
        sounds = {
          enabled = false;
          volume = 0.5;
          separateSounds = false;
          criticalSoundFile = "";
          normalSoundFile = "";
          lowSoundFile = "";
          excludedApps = "discord,firefox,chrome,chromium,edge";
        };
        enableMediaToast = false;
        enableKeyboardLayoutToast = true;
        enableBatteryToast = true;
      };

      # ── OSD ──
      osd = {
        enabled = true;
        location = "top_right";
        autoHideMs = 2000;
        overlayLayer = true;
        backgroundOpacity = 1;
        enabledTypes = [ 0 1 2 ];
        monitors = [ ];
      };

      # ── Audio ──
      audio = {
        volumeStep = 5;
        volumeOverdrive = false;
        spectrumFrameRate = 30;
        visualizerType = "linear";
        mprisBlacklist = [ ];
        preferredPlayer = "";
        volumeFeedback = false;
        volumeFeedbackSoundFile = "";
      };

      # ── Brightness ──
      brightness = {
        brightnessStep = 5;
        enforceMinimum = true;
        enableDdcSupport = false;
        backlightDeviceMappings = [ ];
      };

      # ── Colour scheme ──
      colorSchemes = {
        useWallpaperColors = false;
        predefinedScheme = "Catppuccin";
        darkMode = true;
        schedulingMode = "off";
        manualSunrise = "06:30";
        manualSunset = "18:30";
        generationMethod = "tonal-spot";
        monitorForColors = "";
      };

      # ── Templates ──
      templates = {
        activeTemplates = [ ];
        enableUserTheming = false;
      };

      # ── Night light ──
      nightLight = {
        enabled = false;
        forced = false;
        autoSchedule = true;
        nightTemp = "4000";
        dayTemp = "6500";
        manualSunrise = "06:30";
        manualSunset = "18:30";
      };

      # ── Hooks ──
      hooks = {
        enabled = false;
        wallpaperChange = "";
        darkModeChange = "";
        screenLock = "";
        screenUnlock = "";
        performanceModeEnabled = "";
        performanceModeDisabled = "";
        startup = "";
        session = "";
        colorGeneration = "";
      };

      # ── Plugins ──
      plugins = {
        autoUpdate = false;
        notifyUpdates = false;
      };

      # ── Idle ──
      idle = {
        enabled = false;
        screenOffTimeout = 600;
        lockTimeout = 660;
        suspendTimeout = 1800;
        fadeDuration = 5;
        screenOffCommand = "";
        lockCommand = "";
        suspendCommand = "";
        resumeScreenOffCommand = "";
        resumeLockCommand = "";
        resumeSuspendCommand = "";
        customCommands = "[]";
      };

      # ── Desktop widgets ──
      desktopWidgets = {
        enabled = false;
        overviewEnabled = true;
        gridSnap = false;
        gridSnapScale = false;
        monitorWidgets = [ ];
      };
    };
  };

  # Launch via compositor exec-once (systemd launch is deprecated)
  wayland.windowManager.hyprland.settings = {
    exec-once = [ "noctalia-shell" ];
  };
}
