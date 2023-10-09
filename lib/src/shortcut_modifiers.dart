class ShortcutModifiers {
  final bool control;
  final bool shift;
  final bool alt;
  final bool meta;

  ShortcutModifiers({
    this.control = false,
    this.shift = false,
    this.alt = false,
    this.meta = false,
  });

  List<String> toList() {
    List<String> modifiers = [];
    if (control) {
      modifiers.add('control');
    }
    if (shift) {
      modifiers.add('shift');
    }
    if (alt) {
      modifiers.add('alt');
    }
    if (meta) {
      modifiers.add('meta');
    }
    return modifiers;
  }
}
