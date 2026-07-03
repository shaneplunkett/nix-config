{
  bluebubbles,
  colours ? import ../../home/shane/modules/common/theme/colours.nix,
}:

bluebubbles.overrideAttrs (old: {
  postPatch = (old.postPatch or "") + ''
        substituteInPlace lib/services/ui/theme/themes_service.dart \
          --replace-fail '  List<ThemeStruct> get defaultThemes => [' \
            '  final shaneDesktopTheme = FlexColorScheme(
      textTheme: Typography.englishLike2021.merge(Typography.whiteMountainView),
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: HexColor("${colours.mauve}"),
        onPrimary: HexColor("${colours.crust}"),
        primaryContainer: HexColor("${colours.blue}"),
        onPrimaryContainer: HexColor("${colours.crust}"),
        secondary: HexColor("${colours.pink}"),
        onSecondary: HexColor("${colours.crust}"),
        secondaryContainer: HexColor("${colours.surface1}"),
        onSecondaryContainer: HexColor("${colours.text}"),
        tertiary: HexColor("${colours.green}"),
        onTertiary: HexColor("${colours.crust}"),
        tertiaryContainer: HexColor("${colours.surface0}"),
        onTertiaryContainer: HexColor("${colours.green}"),
        error: HexColor("${colours.red}"),
        onError: HexColor("${colours.crust}"),
        errorContainer: HexColor("${colours.maroon}"),
        onErrorContainer: HexColor("${colours.crust}"),
        background: HexColor("${colours.base}"),
        onBackground: HexColor("${colours.text}"),
        surface: HexColor("${colours.mantle}"),
        onSurface: HexColor("${colours.text}"),
        surfaceVariant: HexColor("${colours.surface0}"),
        onSurfaceVariant: HexColor("${colours.subtext0}"),
        outline: HexColor("${colours.overlay1}"),
        shadow: HexColor("${colours.crust}"),
        inverseSurface: HexColor("${colours.text}"),
        onInverseSurface: HexColor("${colours.base}"),
        inversePrimary: HexColor("${colours.lavender}"),
      ),
      useMaterial3: true,
    ).toTheme.copyWith(splashFactory: InkSparkle.splashFactory, extensions: [
      BubbleColors(
        iMessageBubbleColor: HexColor("${colours.blue}"),
        oniMessageBubbleColor: HexColor("${colours.crust}"),
        smsBubbleColor: HexColor("${colours.green}"),
        onSmsBubbleColor: HexColor("${colours.crust}"),
        receivedBubbleColor: HexColor("${colours.surface0}"),
        onReceivedBubbleColor: HexColor("${colours.text}"),
      ),
      BubbleText(
        bubbleText: Typography.englishLike2021.bodyMedium!.copyWith(
          fontSize: 15,
          height: Typography.englishLike2021.bodyMedium!.height! * 0.85,
          color: HexColor("${colours.text}"),
        ),
      ),
    ]);

    List<ThemeStruct> get defaultThemes => ['

        substituteInPlace lib/services/ui/theme/themes_service.dart \
          --replace-fail '    ThemeStruct(name: "OLED Dark", themeData: oledDarkTheme),' \
            '    ThemeStruct(name: "Shane Desktop", themeData: shaneDesktopTheme),
      ThemeStruct(name: "OLED Dark", themeData: oledDarkTheme),'

    substituteInPlace lib/database/io/theme.dart \
      --replace-fail '    final name = ss.prefs.getString("selected-light");' \
        '    final name = ss.prefs.getString("selected-light");
    if (name == "Shane Desktop") {
      return ThemeStruct(name: "Shane Desktop", themeData: ts.shaneDesktopTheme);
    }'

    substituteInPlace lib/database/io/theme.dart \
      --replace-fail '    final name = ss.prefs.getString("selected-dark");' \
        '    final name = ss.prefs.getString("selected-dark");
    if (name == null || name == "OLED Dark" || name == "Shane Desktop") {
      return ThemeStruct(name: "Shane Desktop", themeData: ts.shaneDesktopTheme);
    }'

  '';
})
