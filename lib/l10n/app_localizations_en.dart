// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'HippoLulu';

  @override
  String get tagline => 'Discover • Play • Learn';

  @override
  String get chooseGame => '🌟 Choose a Game! 🌟';

  @override
  String get starsBadge => '3 Stars!';

  @override
  String get locked => 'Locked';

  @override
  String get tapToPlay => 'TAP TO PLAY!';

  @override
  String get newRibbon => 'NEW! 🔥';

  @override
  String get comingSoon => '🚀 More games coming soon!';

  @override
  String get gamePuzzles => 'PUZZLES';

  @override
  String get gamePuzzlesSub => 'Match shapes!';

  @override
  String get gameMatching => 'MATCHING';

  @override
  String get gameMatchingSub => 'Find the pairs!';

  @override
  String get gameColoring => 'COLORING';

  @override
  String get gameColoringSub => 'Paint & color!';

  @override
  String get gameCounting => 'COUNTING';

  @override
  String get gameCountingSub => 'Learn numbers!';

  @override
  String get languageTitle => 'Choose Language';

  @override
  String get languageDeviceDefault => 'Device language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageSpanish => 'Español';

  @override
  String get back => 'Back';

  @override
  String get play => 'PLAY!';

  @override
  String get playNow => 'PLAY NOW!';

  @override
  String get moreLabel => '+more';

  @override
  String get chooseTheme => 'Choose a Theme!';

  @override
  String get pickYourAdventure => 'Pick your adventure 🎨';

  @override
  String get themeAnimals => 'Animals';

  @override
  String get themefruitsAndVegetables => 'Fruits & Vegetables';

  @override
  String get themeVehicles => 'Vehicles';

  @override
  String get themeShapes => 'Shapes';

  @override
  String get themeFruits => 'Fruits';

  @override
  String get themeVegetables => 'Vegetables';

  @override
  String get themeDinosaur => 'Dinosaur';

  @override
  String get themeSpace => 'Space';

  @override
  String get themeUnderwater => 'Underwater';

  @override
  String get themeFarm => 'Farm';

  @override
  String get themeAmusementPark => 'Amusement Park';

  @override
  String get themeHippolulu => 'HippoLulu';

  @override
  String puzzlesCount(int count) {
    return '$count Puzzles';
  }

  @override
  String get unlockAnimalsHint => '🔓 Complete Animals to unlock more!';

  @override
  String get matchingGameTitle => 'Matching Game!';

  @override
  String get pickCategoryToMatch => 'Pick a category to match';

  @override
  String get howToPlayPart1 => 'Cards show for ';

  @override
  String get howToPlayHighlight => 'a few seconds';

  @override
  String get howToPlayPart2 =>
      ' — remember them, then find all the matching pairs!';

  @override
  String get matchingAnimals => 'Animals';

  @override
  String get matchingAnimalsDesc => 'Match cute animals!';

  @override
  String get matchingFruits => 'Fruits';

  @override
  String get matchingFruitsDesc => 'Match yummy fruits!';

  @override
  String get matchingVegetables => 'Vegetables';

  @override
  String get matchingVegetablesDesc => 'Match healthy food!';

  @override
  String get matchingFruitAndVegetablesDesc => 'Match tasty treats!';

  @override
  String get matchingFoods => 'Foods';

  @override
  String get matchingFoodsDesc => 'Match delicious foods!';

  @override
  String get matchingVehicles => 'Vehicles';

  @override
  String get matchingVehiclesDesc => 'Find the vehicles!';

  @override
  String get matchingObjects => 'Objects';

  @override
  String get matchingObjectsDesc => 'Match fun objects!';

  @override
  String levelLabel(int number) {
    return 'Level $number';
  }

  @override
  String pairsProgress(int matched, int total) {
    return '$matched/$total pairs';
  }

  @override
  String get rememberCards => '👀 Remember the cards!';

  @override
  String get flipCountdownOne => 'They\'ll flip over in 1 second…';

  @override
  String flipCountdownOther(int count) {
    return 'They\'ll flip over in $count seconds…';
  }

  @override
  String movesCount(int count) {
    return '$count moves';
  }

  @override
  String levelDone(String level) {
    return '$level Done!';
  }

  @override
  String matchedAllSummary(int pairs, int moves) {
    return 'You matched all $pairs pairs in $moves moves!';
  }

  @override
  String nextLevel(String level, int cards) {
    return '🚀 $level — $cards cards!';
  }

  @override
  String get beatAllLevels => '🏆 You beat all levels!';

  @override
  String get retry => 'Retry';

  @override
  String get menu => 'Menu';

  @override
  String get pickAnimal => 'Pick an Animal! 🐾';

  @override
  String get choosePuzzleBuddy => 'Choose your puzzle buddy';

  @override
  String get animalLion => 'Lion';

  @override
  String get animalElephant => 'Elephant';

  @override
  String get animalGiraffe => 'Giraffe';

  @override
  String get animalTiger => 'Tiger';

  @override
  String get animalPenguin => 'Penguin';

  @override
  String get animalRabbit => 'Rabbit';

  @override
  String puzzleTitle(String animal) {
    return '$animal Puzzle 🧩';
  }

  @override
  String get dragPiecesHint => 'Drag the pieces to build the animal!';

  @override
  String get assemblyArea => 'ASSEMBLY AREA';

  @override
  String get dragPiecesAbove => 'DRAG THE PIECES ABOVE!';

  @override
  String get youDidIt => 'You did it!';

  @override
  String puzzleComplete(String animal) {
    return '$animal puzzle complete! 🌟';
  }

  @override
  String get playAgain => 'Play Again!';

  @override
  String get pieceHead => 'Head';

  @override
  String get pieceBody => 'Body';

  @override
  String get pieceTail => 'Tail';

  @override
  String get pieceLegs => 'Legs';

  @override
  String get pieceEars => 'Ears';

  @override
  String get pieceNeck => 'Neck';

  @override
  String get noPuzzlesFound => 'No puzzles found here!';

  @override
  String get chooseYourPuzzle => 'Choose your puzzle';

  @override
  String get rotateDevicePrompt =>
      'Rotate your phone landscape to play this game! 🔄';

  @override
  String get awesome => 'Awesome!';

  @override
  String get wrongTryAgain => 'Oops! Try again!';

  @override
  String get wrongSoClose => 'So close! Keep going!';

  @override
  String get wrongYouCanDoIt => 'You can do it!';

  @override
  String get wrongNotQuite => 'Hmm, not quite!';

  @override
  String get wrongAlmost => 'Almost! Try again!';

  @override
  String get letsPlay => 'Let\'s Play!';

  @override
  String get matchGreat => 'Great job!';

  @override
  String get matchAwesome => 'Awesome!';

  @override
  String get matchYay => 'Yay!';

  @override
  String get matchTryAgain => 'Try again!';

  @override
  String get matchAlmost => 'Almost!';

  @override
  String get matchYouCan => 'You can do it!';

  @override
  String get unlockAll => 'Unlock All';

  @override
  String get unlockGames => 'All games in one place';

  @override
  String get unlockGamesDetail => 'Puzzles, matching and more adventures!';

  @override
  String get unlockThemes => 'All themes and activities';

  @override
  String get unlockThemesDetail => 'Discover every locked theme.';

  @override
  String get unlockNew => 'A growing world of play';

  @override
  String get unlockNewDetail => 'New adventures to explore.';

  @override
  String get unlockSafe => 'Ad-free fun';

  @override
  String get unlockSafeDetail => 'Enjoy playing without interruptions.';

  @override
  String get unlockAnnual => '1 Year Membership';

  @override
  String get unlockBadge => 'ALL ACCESS';

  @override
  String get unlockPriceUnavailable => 'Price currently unavailable';

  @override
  String get unlockSubscribe => 'Unlock All';

  @override
  String get unlockBilling =>
      'Annual subscription. Renews automatically unless cancelled.';

  @override
  String get unlockRestore => 'Restore Purchases';

  @override
  String get unlockPrivacy => 'Privacy Policy';

  @override
  String get unlockTerms => 'Terms of Use';

  @override
  String get parentTitle => 'Parent Area';

  @override
  String get parentPrompt => 'Answer the question\nto continue.';

  @override
  String get parentRetry => 'Please try again.';

  @override
  String get parentGreat => 'Great!';

  @override
  String get parentContinue => 'You may continue.';

  @override
  String get parentCancel => 'Cancel';

  @override
  String get parentStoreUnavailable =>
      'Purchases are currently unavailable. Please try again later.';

  @override
  String get matchingRememberTitle => 'Remember the cards!';

  @override
  String get matchingFindTitle => 'Find the pairs!';

  @override
  String get matchingPreviewInstruction =>
      'They’ll flip over in a few seconds…';

  @override
  String get matchingTapInstruction => 'Tap two cards to find a match!';

  @override
  String get matchingPreviewHint => 'Memorize the cards!';

  @override
  String get matchingPlayHint => 'Try to find all the matching pairs!';

  @override
  String get puzzleImageLoadError =>
      'Could not load the picture. Please try again.';

  @override
  String get puzzleNewPuzzle => 'New Puzzle';
}
