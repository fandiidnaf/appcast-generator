import '../models/appcast_enclosure.dart';
import '../models/appcast_feed.dart';
import '../models/appcast_item.dart';
import '../models/delta_update.dart';
import '../models/preset_profile.dart';

sealed class AppcastEvent {
  const AppcastEvent();
}

class AppcastInitialized extends AppcastEvent {
  const AppcastInitialized();
}

class FeedUpdated extends AppcastEvent {
  final AppcastFeed feed;
  const FeedUpdated(this.feed);
}

class PresetChanged extends AppcastEvent {
  final PresetProfile preset;
  const PresetChanged(this.preset);
}

class ReleaseAdded extends AppcastEvent {
  const ReleaseAdded();
}

class ReleaseUpdated extends AppcastEvent {
  final AppcastItem item;
  const ReleaseUpdated(this.item);
}

class ReleaseRemoved extends AppcastEvent {
  final String id;
  const ReleaseRemoved(this.id);
}

class ReleaseDuplicated extends AppcastEvent {
  final String id;
  const ReleaseDuplicated(this.id);
}

class ReleaseReordered extends AppcastEvent {
  final int oldIndex;
  final int newIndex;
  const ReleaseReordered(this.oldIndex, this.newIndex);
}

class ReleaseExpansionToggled extends AppcastEvent {
  final String id;
  const ReleaseExpansionToggled(this.id);
}

class EnclosureAdded extends AppcastEvent {
  final String releaseId;
  const EnclosureAdded(this.releaseId);
}

class EnclosureUpdated extends AppcastEvent {
  final String releaseId;
  final AppcastEnclosure enclosure;
  const EnclosureUpdated(this.releaseId, this.enclosure);
}

class EnclosureRemoved extends AppcastEvent {
  final String releaseId;
  final String enclosureId;
  const EnclosureRemoved(this.releaseId, this.enclosureId);
}

class DeltaAdded extends AppcastEvent {
  final String releaseId;
  const DeltaAdded(this.releaseId);
}

class DeltaUpdated extends AppcastEvent {
  final String releaseId;
  final DeltaUpdate delta;
  const DeltaUpdated(this.releaseId, this.delta);
}

class DeltaRemoved extends AppcastEvent {
  final String releaseId;
  final String deltaId;
  const DeltaRemoved(this.releaseId, this.deltaId);
}

class XmlImported extends AppcastEvent {
  final String xmlString;
  const XmlImported(this.xmlString);
}
