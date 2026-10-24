import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../models/appcast_enclosure.dart';
import '../models/appcast_feed.dart';
import '../models/appcast_item.dart';
import '../models/delta_update.dart';
import '../services/schema_validator.dart';
import '../services/xml_generator_service.dart';
import '../services/xml_parser_service.dart';
import 'appcast_event.dart';
import 'appcast_state.dart';

class AppcastBloc extends Bloc<AppcastEvent, AppcastState> {
  static const _uuid = Uuid();

  AppcastBloc() : super(const AppcastState()) {
    on<AppcastInitialized>(_onInitialized);
    on<FeedUpdated>(_onFeedUpdated);
    on<PresetChanged>(_onPresetChanged);
    on<ReleaseAdded>(_onReleaseAdded);
    on<ReleaseUpdated>(_onReleaseUpdated);
    on<ReleaseRemoved>(_onReleaseRemoved);
    on<ReleaseDuplicated>(_onReleaseDuplicated);
    on<ReleaseReordered>(_onReleaseReordered);
    on<ReleaseExpansionToggled>(_onReleaseExpansionToggled);
    on<EnclosureAdded>(_onEnclosureAdded);
    on<EnclosureUpdated>(_onEnclosureUpdated);
    on<EnclosureRemoved>(_onEnclosureRemoved);
    on<DeltaAdded>(_onDeltaAdded);
    on<DeltaUpdated>(_onDeltaUpdated);
    on<DeltaRemoved>(_onDeltaRemoved);
    on<XmlImported>(_onXmlImported);

    add(const AppcastInitialized());
  }

  void _onInitialized(AppcastInitialized event, Emitter<AppcastState> emit) {
    final initialFeed = const AppcastFeed();
    final initialItem = AppcastItem(
      id: _uuid.v4(),
      title: 'Version 1.0.0',
      version: '1.0.0',
      shortVersionString: '1.0.0',
      pubDate: DateTime.now(),
      enclosures: [
        AppcastEnclosure(
          id: _uuid.v4(),
          url: 'https://example.com/app-1.0.0.zip',
          fileLength: 10485760,
          mimeType: 'application/zip',
          os: 'macos',
          arch: 'all',
        ),
      ],
    );

    _emitComputed(emit, initialFeed, [initialItem]);
  }

  void _onFeedUpdated(FeedUpdated event, Emitter<AppcastState> emit) {
    _emitComputed(emit, event.feed, state.items);
  }

  void _onPresetChanged(PresetChanged event, Emitter<AppcastState> emit) {
    final updatedFeed = state.feed.copyWith(preset: event.preset);
    _emitComputed(emit, updatedFeed, state.items);
  }

  void _onReleaseAdded(ReleaseAdded event, Emitter<AppcastState> emit) {
    final newVersion = '${state.items.length + 1}.0.0';
    final newItem = AppcastItem(
      id: _uuid.v4(),
      title: 'Version $newVersion',
      version: newVersion,
      shortVersionString: newVersion,
      pubDate: DateTime.now(),
      enclosures: [
        AppcastEnclosure(
          id: _uuid.v4(),
          url: 'https://example.com/app-$newVersion.zip',
          fileLength: 10485760,
          mimeType: 'application/zip',
          os: 'all',
        ),
      ],
    );

    final updated = [newItem, ...state.items];
    _emitComputed(emit, state.feed, updated);
  }

  void _onReleaseUpdated(ReleaseUpdated event, Emitter<AppcastState> emit) {
    final updated = state.items.map((item) {
      return item.id == event.item.id ? event.item : item;
    }).toList();

    _emitComputed(emit, state.feed, updated);
  }

  void _onReleaseRemoved(ReleaseRemoved event, Emitter<AppcastState> emit) {
    final updated = state.items.where((i) => i.id != event.id).toList();
    _emitComputed(emit, state.feed, updated);
  }

  void _onReleaseDuplicated(ReleaseDuplicated event, Emitter<AppcastState> emit) {
    final idx = state.items.indexWhere((i) => i.id == event.id);
    if (idx != -1) {
      final src = state.items[idx];
      final copy = src.copyWith(
        id: _uuid.v4(),
        title: '${src.title} (Copy)',
        isExpanded: true,
        enclosures: src.enclosures.map((e) => e.copyWith(id: _uuid.v4())).toList(),
        deltas: src.deltas.map((d) => d.copyWith(id: _uuid.v4())).toList(),
      );
      final updated = List<AppcastItem>.from(state.items)..insert(idx + 1, copy);
      _emitComputed(emit, state.feed, updated);
    }
  }

  void _onReleaseReordered(ReleaseReordered event, Emitter<AppcastState> emit) {
    final updated = List<AppcastItem>.from(state.items);
    final item = updated.removeAt(event.oldIndex);
    updated.insert(event.newIndex, item);
    _emitComputed(emit, state.feed, updated);
  }

  void _onReleaseExpansionToggled(ReleaseExpansionToggled event, Emitter<AppcastState> emit) {
    final updated = state.items.map((item) {
      return item.id == event.id ? item.copyWith(isExpanded: !item.isExpanded) : item;
    }).toList();
    emit(state.copyWith(items: updated));
  }

  void _onEnclosureAdded(EnclosureAdded event, Emitter<AppcastState> emit) {
    final updated = state.items.map((item) {
      if (item.id != event.releaseId) return item;
      final newEnc = AppcastEnclosure(
        id: _uuid.v4(),
        url: 'https://example.com/app-${item.version}-x64.zip',
        fileLength: 10485760,
      );
      return item.copyWith(enclosures: [...item.enclosures, newEnc]);
    }).toList();

    _emitComputed(emit, state.feed, updated);
  }

  void _onEnclosureUpdated(EnclosureUpdated event, Emitter<AppcastState> emit) {
    final updated = state.items.map((item) {
      if (item.id != event.releaseId) return item;
      final encs = item.enclosures.map((e) {
        return e.id == event.enclosure.id ? event.enclosure : e;
      }).toList();
      return item.copyWith(enclosures: encs);
    }).toList();

    _emitComputed(emit, state.feed, updated);
  }

  void _onEnclosureRemoved(EnclosureRemoved event, Emitter<AppcastState> emit) {
    final updated = state.items.map((item) {
      if (item.id != event.releaseId) return item;
      final encs = item.enclosures.where((e) => e.id != event.enclosureId).toList();
      return item.copyWith(enclosures: encs);
    }).toList();

    _emitComputed(emit, state.feed, updated);
  }

  void _onDeltaAdded(DeltaAdded event, Emitter<AppcastState> emit) {
    final updated = state.items.map((item) {
      if (item.id != event.releaseId) return item;
      final newDelta = DeltaUpdate(
        id: _uuid.v4(),
        fromVersion: '1.0.0',
        url: 'https://example.com/patch.delta',
      );
      return item.copyWith(deltas: [...item.deltas, newDelta]);
    }).toList();

    _emitComputed(emit, state.feed, updated);
  }

  void _onDeltaUpdated(DeltaUpdated event, Emitter<AppcastState> emit) {
    final updated = state.items.map((item) {
      if (item.id != event.releaseId) return item;
      final deltas = item.deltas.map((d) {
        return d.id == event.delta.id ? event.delta : d;
      }).toList();
      return item.copyWith(deltas: deltas);
    }).toList();

    _emitComputed(emit, state.feed, updated);
  }

  void _onDeltaRemoved(DeltaRemoved event, Emitter<AppcastState> emit) {
    final updated = state.items.map((item) {
      if (item.id != event.releaseId) return item;
      final deltas = item.deltas.where((d) => d.id != event.deltaId).toList();
      return item.copyWith(deltas: deltas);
    }).toList();

    _emitComputed(emit, state.feed, updated);
  }

  void _onXmlImported(XmlImported event, Emitter<AppcastState> emit) {
    try {
      final (feed, items) = XmlParserService.parse(event.xmlString);
      if (items.isEmpty) {
        emit(state.copyWith(importError: () => 'No <item> elements found in XML.'));
        return;
      }
      _emitComputed(emit, feed, items, clearError: true);
    } catch (e) {
      emit(state.copyWith(importError: () => 'Failed to parse XML: $e'));
    }
  }

  void _emitComputed(
    Emitter<AppcastState> emit,
    AppcastFeed feed,
    List<AppcastItem> items, {
    bool clearError = false,
  }) {
    final xml = XmlGeneratorService.generate(feed, items);
    final issues = SchemaValidator.validate(feed, items);

    emit(state.copyWith(
      feed: feed,
      items: items,
      generatedXml: xml,
      issues: issues,
      importError: clearError ? () => null : null,
    ));
  }
}
