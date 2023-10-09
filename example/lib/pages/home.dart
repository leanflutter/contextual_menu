import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:preference_list/preference_list.dart';

import 'package:flutter_desktop_context_menu/flutter_desktop_context_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _shouldReact = false;
  Offset? _position;
  Placement _placement = Placement.bottomLeft;
  String? _highlighted;
  String? _selected;

  Menu? _menu;

  @override
  void initState() {
    super.initState();
  }

  void _onClick(MenuItem item) {
    setState(() {
      _selected = item.label;
    });
  }

  void _onHighlight(MenuItem item) {
    setState(() {
      _highlighted = item.label;
    });
  }

  void _onLoseHighlight(_) {
    setState(() {
      _highlighted = null;
    });
  }

  void _handleClickPopUp() {
    _menu ??= Menu(
      items: [
        MenuItem(
          label: 'Look Up "LeanFlutter"',
          onClick: _onClick,
          onHighlight: _onHighlight,
          onLoseHighlight: _onLoseHighlight,
        ),
        MenuItem(
          label: 'Search with Google',
          onClick: _onClick,
          onHighlight: _onHighlight,
          onLoseHighlight: _onLoseHighlight,
        ),
        MenuItem.separator(),
        MenuItem(
          label: 'Cut',
          onClick: _onClick,
          onHighlight: _onHighlight,
          onLoseHighlight: _onLoseHighlight,
        ),
        MenuItem(
          label: 'Copy',
          onClick: _onClick,
          onHighlight: _onHighlight,
          onLoseHighlight: _onLoseHighlight,
        ),
        MenuItem(
          label: 'Paste',
          onClick: _onClick,
          onHighlight: _onHighlight,
          onLoseHighlight: _onLoseHighlight,
          disabled: true,
        ),
        MenuItem.submenu(
          label: 'Share',
          onClick: _onClick,
          onHighlight: _onHighlight,
          onLoseHighlight: _onLoseHighlight,
          submenu: Menu(
            items: [
              MenuItem(
                label: 'Item 1',
                onClick: _onClick,
                onHighlight: _onHighlight,
                onLoseHighlight: _onLoseHighlight,
              ),
              MenuItem(
                label: 'Item 2',
                onClick: _onClick,
                onHighlight: _onHighlight,
                onLoseHighlight: _onLoseHighlight,
              ),
              MenuItem.checkbox(
                label: 'Centered Layout',
                onClick: _onClick,
                onHighlight: _onHighlight,
                onLoseHighlight: _onLoseHighlight,
                checked: false,
              ),
              MenuItem.separator(),
              MenuItem.checkbox(
                label: 'Show Primary Side Bar',
                onClick: _onClick,
                onHighlight: _onHighlight,
                onLoseHighlight: _onLoseHighlight,
                checked: true,
              ),
              MenuItem.checkbox(
                label: 'Show Secondary Side Bar',
                onClick: _onClick,
                onHighlight: _onHighlight,
                onLoseHighlight: _onLoseHighlight,
                checked: true,
              ),
              MenuItem.checkbox(
                label: 'Show Status Bar',
                onClick: _onClick,
                onHighlight: _onHighlight,
                onLoseHighlight: _onLoseHighlight,
                checked: true,
              ),
              MenuItem.checkbox(
                label: 'Show Activity Bar',
                onClick: _onClick,
                onHighlight: _onHighlight,
                onLoseHighlight: _onLoseHighlight,
                checked: true,
              ),
              MenuItem.checkbox(
                label: 'Show Panel Bar',
                onClick: _onClick,
                onHighlight: _onHighlight,
                onLoseHighlight: _onLoseHighlight,
                checked: false,
              ),
            ],
          ),
        ),
        MenuItem.separator(),
        MenuItem.submenu(
          label: 'Font',
          onClick: _onClick,
          onHighlight: _onHighlight,
          onLoseHighlight: _onLoseHighlight,
          submenu: Menu(
            items: [
              MenuItem.checkbox(
                label: 'Item 1',
                onHighlight: _onHighlight,
                onLoseHighlight: _onLoseHighlight,
                checked: true,
                onClick: (menuItem) {
                  menuItem.checked = !(menuItem.checked == true);
                  _onClick(menuItem);
                },
              ),
              MenuItem.checkbox(
                label: 'Item 2',
                onHighlight: _onHighlight,
                onLoseHighlight: _onLoseHighlight,
                checked: false,
                onClick: (menuItem) {
                  menuItem.checked = !(menuItem.checked == true);
                  _onClick(menuItem);
                },
              ),
              MenuItem.separator(),
              MenuItem(
                label: 'Item 3',
                onClick: _onClick,
                onHighlight: _onHighlight,
                onLoseHighlight: _onLoseHighlight,
                checked: false,
              ),
              MenuItem(
                label: 'Item 4',
                onClick: _onClick,
                onHighlight: _onHighlight,
                onLoseHighlight: _onLoseHighlight,
                checked: false,
              ),
              MenuItem(
                label: 'Item 5',
                onClick: _onClick,
                onHighlight: _onHighlight,
                onLoseHighlight: _onLoseHighlight,
                checked: false,
              ),
            ],
          ),
        ),
        MenuItem.submenu(
          label: 'Speech',
          onClick: _onClick,
          onHighlight: _onHighlight,
          onLoseHighlight: _onLoseHighlight,
          submenu: Menu(
            items: [
              MenuItem(
                label: 'Item 1',
                onClick: _onClick,
                onHighlight: _onHighlight,
                onLoseHighlight: _onLoseHighlight,
              ),
              MenuItem(
                label: 'Item 2',
                onClick: _onClick,
                onHighlight: _onHighlight,
                onLoseHighlight: _onLoseHighlight,
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
                onPressed: (int index) async {
                  _placement = Placement.values[index];
                  setState(() {});
                },
                isSelected:
                    Placement.values.map((e) => e == _placement).toList(),
                children: <Widget>[
                  for (var placement in Placement.values)
                    Text(describeEnum(placement)),
                ],
              ),
              onTap: () {
                _position = null;
                _handleClickPopUp();
              },
            ),
          ],
        ),
        PreferenceListSection(
          title: const Text('Results'),
          children: [
            PreferenceListItem(
              disabled: true,
              title: const Text('Highlighted'),
              accessoryView: Text(_highlighted.toString()),
            ),
            PreferenceListItem(
              disabled: true,
              title: const Text('Selected'),
              accessoryView: Text(_selected.toString()),
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
