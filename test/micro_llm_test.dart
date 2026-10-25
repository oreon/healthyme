import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:healthyme/micro_llm.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('MicroLlm crisis handling', () {
    test('flags crisis language and returns the help reply', () async {
      final llm = MicroLlm();
      final reply = await llm.reply('I feel like I want to kill myself');

      expect(reply.crisis, isTrue);
      expect(reply.action, 'help');
      expect(reply.scores, isEmpty);
      expect(reply.text, contains('988'));
    });

    test('ordinary stress text is not treated as a crisis', () async {
      final llm = MicroLlm();
      final reply = await llm.reply('I feel tired and stressed today');

      expect(reply.crisis, isFalse);
      expect(reply.action, isNot('help'));
    });
  });

  group('MicroLlm reply shape', () {
    test('returns a ranked action, a distinct alternate, and full scores',
        () async {
      final llm = MicroLlm();
      final reply = await llm.reply('hello there friend');

      expect(MicroLlm.actions, contains(reply.action));
      expect(MicroLlm.actions, contains(reply.alternate));
      expect(reply.alternate, isNot(reply.action));
      expect(reply.scores.keys, unorderedEquals(MicroLlm.actions));
      expect(reply.text, isNotEmpty);
    });
  });

  group('MicroLlm learning', () {
    test('learning that an action helped raises its score for similar text',
        () async {
      final llm = MicroLlm();
      const text = 'evening snack cravings again';

      final before = await llm.reply(text);
      await llm.learn(text: text, action: 'snack_pause', helped: true);
      final after = await llm.reply(text);

      expect(
        after.scores['snack_pause'],
        greaterThan(before.scores['snack_pause']!),
      );
    });

    test('learned weights survive into a fresh instance via storage',
        () async {
      const text = 'evening snack cravings again';
      final first = MicroLlm();
      final baseline = await first.reply(text);
      await first.learn(text: text, action: 'snack_pause', helped: true);

      final second = MicroLlm();
      final reloaded = await second.reply(text);

      expect(
        reloaded.scores['snack_pause'],
        greaterThan(baseline.scores['snack_pause']!),
      );
    });

    test('learning appends an event and the log is capped at 200', () async {
      final llm = MicroLlm();
      await llm.learn(text: 'one', action: 'walk', helped: true);
      expect(llm.events, hasLength(1));
      expect(llm.events.single['action'], 'walk');
      expect(llm.events.single['helped'], isTrue);

      for (var i = 0; i < 210; i++) {
        await llm.learn(text: 'entry $i', action: 'walk', helped: true);
      }
      expect(llm.events, hasLength(200));
    });

    test('learning for an unknown action is ignored', () async {
      final llm = MicroLlm();
      await llm.learn(text: 'one', action: 'not_an_action', helped: true);
      expect(llm.events, isEmpty);
    });
  });

  group('MicroLlm.recordBehavior activity mapping', () {
    test('maps activity descriptions to the right action', () async {
      final llm = MicroLlm();
      final cases = <String, String>{
        'Poor sleep last night': 'sleep',
        'Morning walk in the park': 'walk',
        'Did a full body scan': 'body_scan',
        'Pranayama practice': 'breathe',
        'Slow breathing exercise': 'breathe',
        'Ate a snack at my desk': 'snack_pause',
        'Journal entry before bed': 'journal',
        'Something entirely different': 'focus',
      };
      for (final entry in cases.entries) {
        await llm.recordBehavior(entry.key);
        expect(
          llm.events.last['action'],
          entry.value,
          reason: '"${entry.key}" should map to ${entry.value}',
        );
      }
    });
  });
}
