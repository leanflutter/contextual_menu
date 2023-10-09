# flutter_desktop_context_menu

[![pub version][pub-image]][pub-url] [![][discord-image]][discord-url] ![][visits-count-image] 

[pub-image]: https://img.shields.io/pub/v/contextual_menu.svg
[pub-url]: https://pub.dev/packages/contextual_menu

[discord-image]: https://img.shields.io/discord/884679008049037342.svg
[discord-url]: https://discord.gg/zPa6EZ2jqb

[visits-count-image]: https://img.shields.io/badge/dynamic/json?label=Visits%20Count&query=value&url=https://api.countapi.xyz/hit/leanflutter.contextual_menu/visits

This plugin allows Flutter desktop apps to create native context menus.

---

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [contextual_menu](#contextual_menu)
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
| ![](https://github.com/leanflutter/contextual_menu/blob/main/screenshots/macos.png?raw=true) | ![](https://github.com/leanflutter/contextual_menu/blob/main/screenshots/linux.png?raw=true) | ![image](https://github.com/leanflutter/contextual_menu/blob/main/screenshots/windows.png?raw=true) |

## Quick Start

### Installation

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  contextual_menu: ^0.1.2
```

Or

```yaml
dependencies:
  contextual_menu:
    git:
      url: https://github.com/leanflutter/contextual_menu.git
      ref: main
```

### Usage

```dart
import 'package:flutter/material.dart' hide MenuItem;
import 'package:contextual_menu/contextual_menu.dart';

Menu menu = Menu(
  items: [
    MenuItem(
      label: 'Copy',
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
  _menu!,
  placement: Placement.bottomLeft,
);

```

> Please see the example app of this plugin for a full example.

## Who's using it?

- [Biyi (比译)](https://biyidev.com/) - A convenient translation and dictionary app.

## Related Links

- https://github.com/leanflutter/menu_base

## License

[MIT](./LICENSE)
