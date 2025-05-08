import 'package:event/event.dart';

class ChannelMessage extends EventArgs {
  ChannelMessage(this.message);
  String message;
}
