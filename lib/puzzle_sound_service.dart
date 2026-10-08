import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// A session-owned, bounded SFX channel. New feedback replaces old feedback;
/// cancelled sessions never play a sound after asynchronous preloading finishes.
class PuzzleSoundService {
  static const directory = 'audio/puzzle/';
  static const files = [
    'puzzle_piece_correct_01.ogg',
    'puzzle_piece_correct_02.ogg',
    'puzzle_piece_correct_03.ogg',
    'puzzle_piece_wrong.ogg',
    'puzzle_final_piece.ogg',
    'puzzle_complete_C.ogg',
  ];
  final PuzzleAudioOutput _output;
  PuzzleSoundService({PuzzleAudioOutput? output})
      : _output = output ?? _AssetAudioOutput();
  Future<void> get idle => _queue;
  final Random _random = Random();
  Future<void>? _ready;
  Future<void> _queue = Future.value();
  int _epoch = 0, _lastCorrect = -1;
  bool enabled = true, _disposed = false, _completePlayed = false;
  final Set<String> _placements = {};

  Future<void> preload() => _ready ??= _prepare();
  Future<void> _prepare() async {
    try {
      await _output.preload(files.map((f) => '$directory$f').toList());
    } catch (error) {
      debugPrint('Puzzle audio preload unavailable: $error');
    }
  }

  void correct(String id, {required bool finalPiece}) {
    if (!_placements.add(id)) return;
    if (finalPiece) {
      _play(files[4]);
      return;
    }
    final choices = [0, 1, 2]..remove(_lastCorrect);
    _lastCorrect = choices[_random.nextInt(choices.length)];
    _play(files[_lastCorrect]);
  }

  void wrong() => _play(files[3]);
  void complete() {
    if (_completePlayed) return;
    _completePlayed = true;
    _play(files[5]);
  }

  void _play(String file) {
    if (_disposed || !enabled) return;
    final epoch = ++_epoch;
    _queue = _queue.then((_) async {
      await preload();
      if (_disposed || !enabled || epoch != _epoch) return;
      await _output.stop();
      if (_disposed || epoch != _epoch) return;
      await _output.play('$directory$file');
    }).catchError((Object error) {
      debugPrint('Puzzle audio unavailable: $error');
    });
  }

  void stop() {
    ++_epoch;
    _queue = _queue.then((_) async {
      if (!_disposed) await _output.stop();
    }).catchError((Object _) {});
  }

  void reset() {
    stop();
    _placements.clear();
    _completePlayed = false;
  }

  void dispose() {
    stop();
    _disposed = true;
    _queue = _queue.then((_) => _output.dispose()).catchError((Object _) {});
  }
}

abstract class PuzzleAudioOutput {
  Future<void> preload(List<String> files);
  Future<void> play(String file);
  Future<void> stop();
  Future<void> dispose();
}

class _AssetAudioOutput implements PuzzleAudioOutput {
  final AudioPlayer _player = AudioPlayer();
  String _path(String file) => !kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS)
      ? file.replaceAll('.ogg', '.wav')
      : file;
  @override
  Future<void> preload(List<String> files) async {
    await _player.audioCache.loadAll(files.map(_path).toList());
    await _player.setReleaseMode(ReleaseMode.stop);
  }

  @override
  Future<void> play(String file) => _player.play(AssetSource(_path(file)));
  @override
  Future<void> stop() => _player.stop();
  @override
  Future<void> dispose() => _player.dispose();
}
