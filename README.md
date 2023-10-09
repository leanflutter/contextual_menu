# flutter_desktop_context_menu

[![pub version][pub-image]][pub-url]

[pub-image]: https://img.shields.io/pub/v/contextual_menu.svg
[pub-url]: https://pub.dev/packages/flutter_desktop_context_menu

This plugin allows Flutter desktop apps to create native context menus.

---

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [flutter_desktop_context_menu](#flutter_desktop_context_menu)
  - [Platform Support](#platform-support)
  - [Screenshots](#screenshots)
  - [Quick Start](#quick-start)
    - [Installation](#installation)
    - [Usage](#usage)
  - [Who's using it?](#whos-using-it)
  - [Related Links](#related-links)
  - [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Platform Support

| Linux | macOS | Windows |
| :---: | :---: | :-----: |
|   ✔️   |   ✔️   |    ✔️    |

## Screenshots

| macOS                                                                                        | Linux                                                                                        | Windows                                                                                             |
| -------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| ![](https://github.com/proteye/flutter_desktop_context_menu/blob/main/screenshots/macos.png?raw=true) | ![](https://github.com/proteye/flutter_desktop_context_menu/blob/main/screenshots/linux.png?raw=true) | ![image](https://github.com/proteye/flutter_desktop_context_menu/blob/main/screenshots/windows.png?raw=true) |

## Quick Start

### Installation

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  flutter_desktop_context_menu: ^0.2.0
```

Or

```yaml
dependencies:
  flutter_desktop_context_menu:
    git:
      url: https://github.com/proteye/flutter_desktop_context_menu.git
      ref: main
```

### Usage

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_desktop_context_menu/flutter_desktop_context_menu.dart';

Menu menu = Menu(
  items: [
    MenuItem(
      label: 'Copy',
      shortcutKey: 'c',
      shortcutModifiers: ShortcutModifiers(
        control: Platform.isWindows, meta: Platform.isMacOS),
      onClick: (_) {
        print('Clicked Copy');
      },
    ),
    MenuItem(
      label: 'Disabled item',
      disabled: true,
    ),
     MenuItem.checkbox(
      key: 'checkbox1',
      label: 'Checkbox1',
      checked: true,
      onClick: (menuItem) {
        print('Clicked Checkbox1');
        menuItem.checked = !(menuItem.checked == true);
      },
    ),
    MenuItem.separator(),
  ],
);

popUpContextualMenu(
  menu,
  placement: Placement.bottomLeft,
);

```

> Please see the example app of this plugin for a full example.

## License

[MIT](./LICENSE)
