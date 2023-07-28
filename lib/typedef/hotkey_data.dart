import 'package:event/event.dart';

class HotkeyData extends EventArgs {
  HotkeyData({
    required String modifier,
    required String key,
    required this.label,
  }) {
    hotkey = modifier + key;
    _modifier = modifier;
    _key = key;
  }
  String hotkey = "";
  final String label;
  String _modifier = "";
  String _key = "";

  HotkeyData.fromJson(Map<String, dynamic> json)
      : _modifier = json['modifier'],
        _key = json['key'],
        label = json['label'],
        hotkey = json['modifier'] + json['key'];

  Map<String, dynamic> toJson() => {
        'modifier': _modifier,
        'key': _key,
        'label': label,
      };

  String get triggerString => "{Mousetrap.trigger('$hotkey');}";
}
