class ShortcutModifiers {
  final bool shift;
  final bool control;
  final bool command;
  final bool alt; // option for macOS

  ShortcutModifiers({
    this.shift = false,
    this.control = false,
    this.command = false,
    this.alt = false,
  });

  List<String> toList() {
    List<String> modifiers = [];
    if (shift) {
      modifiers.add('shift');
    }
    if (control) {
      modifiers.add('ctrl');
    }
    if (command) {
      modifiers.add('cmd');
    }
    if (alt) {
      modifiers.add('alt');
    }
    return modifiers;
  }
}
