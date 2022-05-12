import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide MenuItem;
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
  Placement _placement = Placement.bottomLeft;

  Menu? _menu;

  @override
  void initState() {
    super.initState();
  }

  void _handleClickPopUp() {
    _menu ??= Menu(
      items: [
        MenuItem(
          label: 'Look Up "LeanFlutter"',
        ),
        MenuItem(
          label: 'Search with Google',
        ),
        MenuItem.separator(),
        MenuItem(
          label: 'Cut',
        ),
        MenuItem(
          label: 'Copy',
        ),
        MenuItem(
          label: 'Paste',
          disabled: true,
        ),
        MenuItem.submenu(
          label: 'Share',
          submenu: Menu(
            items: [
              MenuItem(
                label: 'Item 1',
              ),
              MenuItem(
                label: 'Item 2',
              ),
              MenuItem.checkbox(
                label: 'Centered Layout',
                checked: false,
              ),
              MenuItem.separator(),
              MenuItem.checkbox(
                label: 'Show Primary Side Bar',
                checked: true,
              ),
              MenuItem.checkbox(
                label: 'Show Secondary Side Bar',
                checked: true,
              ),
              MenuItem.checkbox(
                label: 'Show Status Bar',
                checked: true,
              ),
              MenuItem.checkbox(
                label: 'Show Activity Bar',
                checked: true,
              ),
              MenuItem.checkbox(
                label: 'Show Panel Bar',
                checked: false,
              ),
            ],
          ),
        ),
        MenuItem.separator(),
        MenuItem.submenu(
          label: 'Font',
          submenu: Menu(
            items: [
              MenuItem.checkbox(
                label: 'Item 1',
                checked: true,
                onClick: (menuItem) {
                  menuItem.checked = !(menuItem.checked == true);
                },
              ),
              MenuItem.checkbox(
                label: 'Item 2',
                checked: false,
                onClick: (menuItem) {
                  menuItem.checked = !(menuItem.checked == true);
                },
              ),
              MenuItem.separator(),
              MenuItem(
                label: 'Item 3',
                checked: false,
              ),
              MenuItem(
                label: 'Item 4',
                checked: false,
              ),
              MenuItem(
                label: 'Item 5',
                checked: false,
              ),
            ],
          ),
        ),
        MenuItem.submenu(
          label: 'Speech',
          submenu: Menu(
            items: [
              MenuItem(
                label: 'Item 1',
              ),
              MenuItem(
                label: 'Item 2',
              ),
            ],
          ),
        ),
      ],
    );
    popUpContextualMenu(
      _menu!,
      position: _position,
      placement: _placement,
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
              accessoryView: ToggleButtons(
                children: <Widget>[
                  for (var placement in Placement.values)
                    Text('${describeEnum(placement)}'),
                ],
                onPressed: (int index) async {
                  _placement = Placement.values[index];
                  setState(() {});
                },
                isSelected:
                    Placement.values.map((e) => e == _placement).toList(),
              ),
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
