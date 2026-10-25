/// Traditional-wisdom content for the strong-emotions screen
/// (spec: "Impulse controls and strong emotions").
///
/// Honesty rule for this data: a [WisdomQuote] is marked
/// [QuoteKind.verbatim] only when it is a real, well-attested text
/// with a known source. Everything else is a [QuoteKind.paraphrase]
/// — our summary of a teaching, never presented as a quotation —
/// and the UI labels it "Paraphrase — not a verbatim quote".
/// Editorial reflections are our own words and are shown under a
/// visible "Reflection" label, distinct from both.
library;

/// Whether a wisdom entry is a verbatim quotation or a paraphrase.
enum QuoteKind { verbatim, paraphrase }

/// One tradition's entry for an emotion category.
class WisdomQuote {
  /// 'Sri Guru Granth Sahib' or 'Buddhist teaching'.
  final String tradition;

  /// The quotation, or the paraphrase summary.
  final String text;

  /// Source / Ang / translator for verbatim quotes; the teaching
  /// being summarized for paraphrases.
  final String attribution;

  final QuoteKind kind;

  const WisdomQuote({
    required this.tradition,
    required this.text,
    required this.attribution,
    required this.kind,
  });

  bool get isVerbatim => kind == QuoteKind.verbatim;
}

/// The visible label distinguishing a quotation from a paraphrase.
String quoteKindLabel(WisdomQuote quote) => quote.isVerbatim
    ? 'Quotation'
    : 'Paraphrase — not a verbatim quote';

/// A tappable strong-emotion category with its two traditional
/// entries and an editorial reflection.
class EmotionCategory {
  final String id;
  final String name;
  final WisdomQuote gurbani;
  final WisdomQuote buddhist;

  /// Our own words — never scripture. Shown labeled "Reflection".
  final String reflection;

  const EmotionCategory({
    required this.id,
    required this.name,
    required this.gurbani,
    required this.buddhist,
    required this.reflection,
  });
}

const String _gurbani = 'Sri Guru Granth Sahib';
const String _buddhist = 'Buddhist teaching';

/// The 13 strong-emotion categories from the spec snapshot.
const List<EmotionCategory> emotionCategories = [
  EmotionCategory(
    id: 'anger',
    name: 'Anger',
    gurbani: WisdomQuote(
      tradition: _gurbani,
      kind: QuoteKind.verbatim,
      text: 'Fareed, do good to the one who does evil to you, and do '
          'not hold anger in your mind. Your body shall not suffer '
          'any disease, and you shall obtain everything.',
      attribution: 'Sheikh Farid, Sri Guru Granth Sahib, Ang 1378 '
          '(trans. Sant Singh Khalsa)',
    ),
    buddhist: WisdomQuote(
      tradition: _buddhist,
      kind: QuoteKind.verbatim,
      text: 'Hatred is never appeased by hatred in this world. By '
          'non-hatred alone is hatred appeased. This is a law eternal.',
      attribution: 'Dhammapada 5 (trans. Acharya Buddharakkhita)',
    ),
    reflection: 'Anger feels like strength, but it burns the one who '
        'carries it first. You do not have to approve of what happened '
        'to set the fire down. Breathe for one minute, let the body '
        'cool, and only then decide what — if anything — needs to be '
        'said or done.',
  ),
  EmotionCategory(
    id: 'worry',
    name: 'Worry / overthinking',
    gurbani: WisdomQuote(
      tradition: _gurbani,
      kind: QuoteKind.paraphrase,
      text: 'Everything unfolds within the Divine Order (Hukam); the '
          'mind that rests in acceptance of that Order is freed from '
          'churning over what it cannot control.',
      attribution: 'Paraphrase of the Hukam teaching, Japji Sahib, '
          'Sri Guru Granth Sahib',
    ),
    buddhist: WisdomQuote(
      tradition: _buddhist,
      kind: QuoteKind.paraphrase,
      text: 'Do not revive the past or build hopes on the future: '
          'the past has already gone and the future has not yet '
          'arrived. Instead, see clearly and steadily into whatever '
          'is present right now.',
      attribution: 'Paraphrase of the Bhaddekaratta Sutta, '
          'Majjhima Nikaya 131',
    ),
    reflection: 'Overthinking is the mind rehearsing a life that is '
        'not happening. The worry feels useful, but it solves nothing '
        'from inside the loop. Come back to this breath, this body, '
        'this moment — the only place where anything can actually '
        'be done.',
  ),
  EmotionCategory(
    id: 'money',
    name: 'Money',
    gurbani: WisdomQuote(
      tradition: _gurbani,
      kind: QuoteKind.verbatim,
      text: 'One who works for what he eats, and gives some of what '
          'he has — O Nanak, he knows the Path.',
      attribution: 'Guru Nanak, Sri Guru Granth Sahib, Ang 1245 '
          '(trans. Sant Singh Khalsa)',
    ),
    buddhist: WisdomQuote(
      tradition: _buddhist,
      kind: QuoteKind.verbatim,
      text: 'Health is the most precious gain and contentment the '
          'greatest wealth. A trustworthy friend is the best kinsman, '
          'and Nibbana the highest bliss.',
      attribution: 'Dhammapada 204 (trans. Acharya Buddharakkhita)',
    ),
    reflection: 'Money fear shrinks the world to a number. Honest '
        'work, honest spending, and giving a little away are the '
        'old, steady answer. For this minute, let the breath be '
        'enough; the practical steps can be taken with a clear head '
        'afterwards.',
  ),
  EmotionCategory(
    id: 'lust',
    name: 'Lust / desire',
    gurbani: WisdomQuote(
      tradition: _gurbani,
      kind: QuoteKind.paraphrase,
      text: 'Desire (kaam) is named one of the five thieves that rob '
          'the mind of its peace: a powerful energy to be witnessed '
          'and mastered, never a master to be obeyed.',
      attribution: 'Paraphrase of Gurbani\'s teaching on kaam, '
          'one of the five thieves, Sri Guru Granth Sahib',
    ),
    buddhist: WisdomQuote(
      tradition: _buddhist,
      kind: QuoteKind.verbatim,
      text: 'There is no fire like passion; there is no grip like '
          'hatred; there is no net like delusion; there is no river '
          'like craving.',
      attribution: 'Dhammapada 251 (trans. Acharya Buddharakkhita)',
    ),
    reflection: 'Desire promises that one more indulgence will '
        'finally be enough. It never is — the fire grows by being '
        'fed. You are not your urge. Watch it rise, breathe through '
        'its peak, and notice it begin to fall on its own.',
  ),
  EmotionCategory(
    id: 'loved_ones',
    name: 'Loved ones',
    gurbani: WisdomQuote(
      tradition: _gurbani,
      kind: QuoteKind.paraphrase,
      text: 'Love is sacred when it widens rather than clutches: '
          'held without possessiveness, love for one person becomes '
          'compassion for all beings, who are children of the same '
          'One.',
      attribution: 'Paraphrase of Gurbani\'s teaching on love '
          'without possessiveness, Sri Guru Granth Sahib',
    ),
    buddhist: WisdomQuote(
      tradition: _buddhist,
      kind: QuoteKind.verbatim,
      text: 'As a mother would risk her life to protect her child, '
          'her only child, even so should one develop a mind of '
          'measureless goodwill toward all beings.',
      attribution: 'Metta Sutta, Sutta Nipata 1.8 '
          '(trans. Thanissaro Bhikkhu)',
    ),
    reflection: 'Worrying about the people we love is love wearing '
        'a frightened face. What they need from us is presence, not '
        'anxiety. Send them goodwill with a steady heart — and let '
        'that steadiness be part of your care for them.',
  ),
  EmotionCategory(
    id: 'fear',
    name: 'Fear / anxiety',
    gurbani: WisdomQuote(
      tradition: _gurbani,
      kind: QuoteKind.paraphrase,
      text: 'The Divine is Nirbhau — utterly without fear. The mind '
          'that rests in remembrance of the Fearless One borrows that '
          'fearlessness and loosens its own fear.',
      attribution: 'Paraphrase of the Mool Mantar (Nirbhau, the '
          'Fearless One), Sri Guru Granth Sahib, Ang 1',
    ),
    buddhist: WisdomQuote(
      tradition: _buddhist,
      kind: QuoteKind.verbatim,
      text: 'From endearment springs grief, from endearment springs '
          'fear. For one who is wholly free from endearment there is '
          'no grief, whence then fear?',
      attribution: 'Dhammapada 212 (trans. Acharya Buddharakkhita)',
    ),
    reflection: 'Fear is the body bracing for a future that has not '
        'arrived. The brace itself is most of the suffering. Slow '
        'the exhale, feel your feet on the ground, and let this '
        'moment — which is safe — be fully known.',
  ),
  EmotionCategory(
    id: 'loneliness',
    name: 'Loneliness',
    gurbani: WisdomQuote(
      tradition: _gurbani,
      kind: QuoteKind.paraphrase,
      text: 'You are never truly alone: the Divine Companion is ever '
          'near, within and around you, closer than your own breath; '
          'solitude remembered this way becomes rest, not exile.',
      attribution: 'Paraphrase of Gurbani\'s teaching that the '
          'Divine Companion is ever near, Sri Guru Granth Sahib',
    ),
    buddhist: WisdomQuote(
      tradition: _buddhist,
      kind: QuoteKind.verbatim,
      text: 'If a traveller does not meet with one who is his '
          'better, or his equal, let him firmly keep to his solitary '
          'journey; there is no companionship with a fool.',
      attribution: 'Dhammapada 61 (trans. Acharya Buddharakkhita)',
    ),
    reflection: 'Loneliness hurts, and it is also information: a '
        'hunger for real connection, not for noise. Honour the '
        'hunger without shaming it. Breathe, soften, and when you '
        'are ready, reach toward one person with honesty.',
  ),
  EmotionCategory(
    id: 'grief',
    name: 'Sadness / grief',
    gurbani: WisdomQuote(
      tradition: _gurbani,
      kind: QuoteKind.verbatim,
      text: 'One who is not distressed by sorrow, and who is not '
          'bound by pleasure, fear or attachment, who looks on gold '
          'and dust as the same — that one is liberated.',
      attribution: 'Guru Tegh Bahadur, Raag Sorath, '
          'Sri Guru Granth Sahib, Ang 633 (trans. Sant Singh Khalsa)',
    ),
    buddhist: WisdomQuote(
      tradition: _buddhist,
      kind: QuoteKind.verbatim,
      text: '"All conditioned things are impermanent" — when one '
          'sees this with wisdom, one turns away from suffering. '
          'This is the path to purification.',
      attribution: 'Dhammapada 277 (trans. Acharya Buddharakkhita)',
    ),
    reflection: 'Grief is love with nowhere to go. It does not need '
        'to be fixed or hurried; it needs room. Let the breath make '
        'a little more room around the ache. What you loved was '
        'real, and so is this missing of it.',
  ),
  EmotionCategory(
    id: 'jealousy',
    name: 'Jealousy / comparison',
    gurbani: WisdomQuote(
      tradition: _gurbani,
      kind: QuoteKind.paraphrase,
      text: 'Envy (irkha) and slander (ninda) burn the one who '
          'carries them: the mind busy watching others\' fortunes '
          'forgets its own blessings and its own path.',
      attribution: 'Paraphrase of Gurbani\'s teaching against envy '
          'and slander, Sri Guru Granth Sahib',
    ),
    buddhist: WisdomQuote(
      tradition: _buddhist,
      kind: QuoteKind.verbatim,
      text: 'Let none find fault with others; let none see the '
          'omissions and commissions of others. But let one see '
          'one\'s own acts, done and undone.',
      attribution: 'Dhammapada 50 (trans. Acharya Buddharakkhita)',
    ),
    reflection: 'Comparison shows you someone else\'s highlight '
        'and your own behind-the-scenes, and calls the difference '
        'truth. It is not. Their path is not your path. Return to '
        'your own next step — it is the only one you can take.',
  ),
  EmotionCategory(
    id: 'guilt',
    name: 'Guilt / remorse',
    gurbani: WisdomQuote(
      tradition: _gurbani,
      kind: QuoteKind.paraphrase,
      text: 'The door is never closed: honest remorse, amends where '
          'amends are possible, and a genuinely changed life wash '
          'the past clean — no one who turns is turned away.',
      attribution: 'Paraphrase of Gurbani\'s teaching on remorse, '
          'forgiveness and renewal, Sri Guru Granth Sahib',
    ),
    buddhist: WisdomQuote(
      tradition: _buddhist,
      kind: QuoteKind.verbatim,
      text: 'He who, by good deeds, covers the evil he has done, '
          'illumines this world like the moon freed from clouds.',
      attribution: 'Dhammapada 173 (trans. Acharya Buddharakkhita)',
    ),
    reflection: 'Remorse is useful exactly as long as it moves you '
        'to repair. Beyond that it becomes a tax you pay to no one. '
        'Apologise where you can, change what you can, and let good '
        'action — not self-punishment — be the answer.',
  ),
  EmotionCategory(
    id: 'greed',
    name: 'Greed',
    gurbani: WisdomQuote(
      tradition: _gurbani,
      kind: QuoteKind.verbatim,
      text: 'Where there is greed, there is death; where there is '
          'forgiveness, there is God Himself.',
      attribution: 'Bhagat Kabir, Salok, Sri Guru Granth Sahib',
    ),
    buddhist: WisdomQuote(
      tradition: _buddhist,
      kind: QuoteKind.paraphrase,
      text: 'Not even a shower of gold coins can satisfy sensual '
          'craving, for craving is fed by indulgence and grows with '
          'every feeding; the wise, knowing this, find their '
          'delight elsewhere.',
      attribution: 'Paraphrase of Dhammapada 186',
    ),
    reflection: '"Just a little more" is greed\'s whole vocabulary. '
        'Notice what you already hold, and what it cost you to get '
        'it. Contentment is not giving up — it is the only form of '
        'enough that wanting can never give you.',
  ),
  EmotionCategory(
    id: 'ego',
    name: 'Ego / wounded pride',
    gurbani: WisdomQuote(
      tradition: _gurbani,
      kind: QuoteKind.verbatim,
      text: 'Sweetness and humility, O Nanak, are the essence of '
          'virtue and goodness.',
      attribution: 'Guru Nanak, Asa di Var, Sri Guru Granth Sahib, '
          'Ang 470',
    ),
    buddhist: WisdomQuote(
      tradition: _buddhist,
      kind: QuoteKind.verbatim,
      text: 'Though one may conquer a thousand times a thousand men '
          'in battle, yet he indeed is the noblest victor who '
          'conquers himself.',
      attribution: 'Dhammapada 103 (trans. Acharya Buddharakkhita)',
    ),
    reflection: 'A wounded pride wants a verdict: who was right? '
        'The deeper victory needs no verdict at all. Humility is '
        'not thinking less of yourself; it is needing the argument '
        'less. Breathe, and let the need to win loosen its grip.',
  ),
  EmotionCategory(
    id: 'overwhelm',
    name: 'Overwhelm',
    gurbani: WisdomQuote(
      tradition: _gurbani,
      kind: QuoteKind.paraphrase,
      text: 'When burdens press from every side, rest the mind in '
          'the Naam and carry only the step in front of you; the '
          'whole load was never yours to hold at once.',
      attribution: 'Paraphrase of Gurbani\'s teaching on resting the '
          'burdened mind in the Naam, Sri Guru Granth Sahib',
    ),
    buddhist: WisdomQuote(
      tradition: _buddhist,
      kind: QuoteKind.verbatim,
      text: 'By degrees, little by little, from moment to moment, '
          'a wise man should remove his own impurities, as a smith '
          'removes the dross from silver.',
      attribution: 'Dhammapada 239 (trans. Acharya Buddharakkhita)',
    ),
    reflection: 'Overwhelm is everything demanding to be done at '
        'once, in the imagination. In reality there is only ever '
        'the next small thing. Breathe for one minute. Then do that '
        'one thing. Then, if needed, the next.',
  ),
];
