> **🚀 快速发布您的应用**: 试试 [Fastforge](https://fastforge.dev) - 构建、打包和分发您的 Flutter 应用最简单的方式。

# contextual_menu

[![pub version][pub-image]][pub-url] [![][discord-image]][discord-url] ![][visits-count-image] 

[pub-image]: https://img.shields.io/pub/v/contextual_menu.svg
[pub-url]: https://pub.dev/packages/contextual_menu

[discord-image]: https://img.shields.io/discord/884679008049037342.svg
[discord-url]: https://discord.gg/zPa6EZ2jqb

[visits-count-image]: https://img.shields.io/badge/dynamic/json?label=Visits%20Count&query=value&url=https://api.countapi.xyz/hit/leanflutter.contextual_menu/visits

这个插件允许 Flutter 桌面应用创建原生上下文菜单。

---

[English](./README.md) | 简体中文

---

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [contextual_menu](#contextual_menu)
  - [平台支持](#平台支持)
  - [截图](#截图)
  - [快速开始](#快速开始)
    - [安装](#安装)
    - [用法](#用法)
  - [谁在用使用它？](#谁在用使用它)
  - [相关链接](#相关链接)
  - [许可证](#许可证)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## 平台支持

| Linux | macOS | Windows |
| :---: | :---: | :-----: |
|   ✔️   |   ✔️   |    ✔️    |

## 截图

| macOS                                                                                        | Linux                                                                                        | Windows                                                                                             |
| -------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| ![](https://github.com/leanflutter/contextual_menu/blob/main/screenshots/macos.png?raw=true) | ![](https://github.com/leanflutter/contextual_menu/blob/main/screenshots/linux.png?raw=true) | ![image](https://github.com/leanflutter/contextual_menu/blob/main/screenshots/windows.png?raw=true) |

## 快速开始

### 安装

将此添加到你的软件包的 pubspec.yaml 文件：

```yaml
dependencies:
  contextual_menu: ^0.1.2
```

或

```yaml
dependencies:
  contextual_menu:
    git:
      url: https://github.com/leanflutter/contextual_menu.git
      ref: main
```

### 用法

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

> 请看这个插件的示例应用，以了解完整的例子。

## 谁在用使用它？

- [Biyi (比译)](https://biyidev.com/) - 一个便捷的翻译和词典应用。

## 相关链接

- https://github.com/leanflutter/menu_base

## 许可证

[MIT](./LICENSE)
