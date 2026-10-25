// Data-integrity tests for the strong-emotions content: exactly
// the 13 spec categories, a reflection for every category, and an
// enforceable line between verbatim quotations (which must carry
// an attribution) and paraphrases (which must be labeled as such).

import 'package:flutter_test/flutter_test.dart';

import 'package:healthyme/emotions_data.dart';

void main() {
  group('emotionCategories', () {
    test('has exactly the 13 spec categories, in order', () {
      expect(
        emotionCategories.map((c) => c.name).toList(),
        [
          'Anger',
          'Worry / overthinking',
          'Money',
          'Lust / desire',
          'Loved ones',
          'Fear / anxiety',
          'Loneliness',
          'Sadness / grief',
          'Jealousy / comparison',
          'Guilt / remorse',
          'Greed',
          'Ego / wounded pride',
          'Overwhelm',
        ],
      );
      expect(emotionCategories.map((c) => c.id).toSet(),
          hasLength(13));
    });

    test('every category has a reflection (our words, never empty)',
        () {
      for (final category in emotionCategories) {
        expect(category.reflection.trim(), isNotEmpty,
            reason: '${category.name} needs a reflection');
      }
    });

    test('every category offers both traditions', () {
      for (final category in emotionCategories) {
        expect(category.gurbani.tradition, 'Sri Guru Granth Sahib');
        expect(category.buddhist.tradition, 'Buddhist teaching');
        expect(category.gurbani.text.trim(), isNotEmpty);
        expect(category.buddhist.text.trim(), isNotEmpty);
      }
    });

    test('verbatim entries always carry text and attribution', () {
      for (final category in emotionCategories) {
        for (final quote in [category.gurbani, category.buddhist]) {
          if (quote.isVerbatim) {
            expect(quote.text.trim(), isNotEmpty,
                reason: '${category.name} verbatim quote needs text');
            expect(quote.attribution.trim(), isNotEmpty,
                reason:
                    '${category.name} verbatim quote needs attribution');
            expect(quoteKindLabel(quote), 'Quotation');
          }
        }
      }
    });

    test('non-verbatim entries are labeled paraphrase, never quote',
        () {
      var paraphraseCount = 0;
      for (final category in emotionCategories) {
        for (final quote in [category.gurbani, category.buddhist]) {
          if (!quote.isVerbatim) {
            paraphraseCount++;
            expect(quote.kind, QuoteKind.paraphrase);
            expect(quoteKindLabel(quote),
                'Paraphrase — not a verbatim quote',
                reason:
                    '${category.name} paraphrase must be labeled');
          }
        }
      }
      // The honesty constraint is exercised: some entries really
      // are paraphrases rather than dressed-up quotations.
      expect(paraphraseCount, greaterThan(0));
    });
  });
}
