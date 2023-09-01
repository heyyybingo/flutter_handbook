
import 'package:event_bus/event_bus.dart';
import 'package:flutter_handbook/utils/logger.dart';

EventBus eventBus = EventBus();

class FolderUpdateEvent{

}


class HandBookUpdateEvent{
  HandBookUpdateEvent(){
    logger.i("HandBookUpdateEvent created");
  }
}