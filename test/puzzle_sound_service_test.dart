import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:hippolulu/puzzle_sound_service.dart';

class Output implements PuzzleAudioOutput {
  final played = <String>[];
  Completer<void>? loading;
  bool disposed = false;
  @override
  Future<void> preload(List<String> files) async {
    await loading?.future;
  }

  @override
  Future<void> play(String file) async {
    played.add(file);
  }

  @override
  Future<void> stop() async {}
  @override
  Future<void> dispose() async {
    disposed = true;
  }
}

void main() {
  test('Correct variants do not repeat; final and completion are exactly once',
      () async {
    final output = Output();
    final sounds = PuzzleSoundService(output: output);
    for (var i = 0; i < 12; i++) {
      sounds.correct('$i', finalPiece: false);
      await sounds.idle;
      if (i > 0) expect(output.played[i], isNot(output.played[i - 1]));
    }
    sounds.correct('final', finalPiece: true);
    await sounds.idle;
    sounds.correct('final', finalPiece: true);
    sounds.complete();
    await sounds.idle;
    sounds.complete();
    await sounds.idle;
    expect(output.played.length, 14);
    expect(output.played[12], endsWith('puzzle_final_piece.ogg'));
    expect(output.played[13], endsWith('puzzle_complete_C.ogg'));
    sounds.reset();
    sounds.complete();
    await sounds.idle;
    expect(output.played.length, 15);
    sounds.dispose();
    await sounds.idle;
    expect(output.disposed, isTrue);
  });
  test('Leaving while preload is pending cancels queued audio', () async {
    final output = Output()..loading = Completer<void>();
    final sounds = PuzzleSoundService(output: output);
    sounds.complete();
    await Future<void>.delayed(Duration.zero);
    sounds.dispose();
    output.loading!.complete();
    await sounds.idle;
    expect(output.played, isEmpty);
    expect(output.disposed, isTrue);
  });
  test('Wrong feedback is bounded and mute suppresses playback', () async {
    final output = Output();
    final sounds = PuzzleSoundService(output: output);
    sounds.wrong();
    sounds.wrong();
    sounds.wrong();
    await sounds.idle;
    expect(output.played, [endsWith('puzzle_piece_wrong.ogg')]);
    sounds.enabled = false;
    sounds.wrong();
    await sounds.idle;
    expect(output.played.length, 1);
    sounds.dispose();
    await sounds.idle;
  });
}
