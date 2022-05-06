import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:preference_list/preference_list.dart';
import 'package:contextual_menu/contextual_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _shouldReact = false;
  Offset? _position;

  Menu? _menu;

  @override
  void initState() {
    super.initState();
  }

  void _handleClickPopUp() {
    _menu ??= Menu(
      items: [
        MenuItem(
          label: 'Copy',
          onClick: (_) {
            BotToast.showText(text: 'Clicked Copy');
          },
        ),
        MenuItem(
          label: 'Paste',
          onClick: (_) {
            BotToast.showText(text: 'Clicked Paste');
          },
        ),
        MenuItem(
          label: 'Paste as values',
        ),
        MenuItem.separator(),
        MenuItem(
          label: 'Item number two',
        ),
        MenuItem(
          label: 'Disabled item',
          disabled: true,
        ),
        MenuItem(
          label: 'Disabled item with shortcut',
          disabled: true,
        ),
        MenuItem.separator(),
        MenuItem.submenu(
          label: 'Submenu',
          submenu: Menu(
            items: [
              MenuItem.checkbox(
                key: 'checkbox1',
                label: 'Checkbox1',
                checked: true,
                onClick: (menuItem) {
                  menuItem.checked = !(menuItem.checked == true);
                },
              ),
              MenuItem.checkbox(
                label: 'Checkbox2',
                checked: false,
              ),
              MenuItem.checkbox(
                label: 'Checkbox3',
                checked: null,
              ),
            ],
          ),
        ),
        MenuItem.separator(),
        MenuItem(
          label: 'Control shortcut',
        ),
      ],
    );
    popUpContextualMenu(
      _menu!,
      position: _position,
      placement: Placement.topRight,
    );
  }

  Widget _buildBody(BuildContext context) {
    return PreferenceList(
      children: <Widget>[
        PreferenceListSection(
          title: const Text('Methods'),
          children: [
            PreferenceListItem(
              title: const Text('popUp'),
              onTap: () {
                _position = null;
                _handleClickPopUp();
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        _shouldReact = event.kind == PointerDeviceKind.mouse &&
            event.buttons == kSecondaryMouseButton;
      },
      onPointerUp: (event) {
        if (!_shouldReact) return;

        _position = Offset(
          event.position.dx,
          event.position.dy,
        );

        _handleClickPopUp();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: _buildBody(context),
      ),
    );
  }
}
