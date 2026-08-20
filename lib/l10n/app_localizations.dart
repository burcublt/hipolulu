import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('tr')
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'HippoLulu'**
  String get appTitle;

  /// Subtitle under the app name
  ///
  /// In en, this message translates to:
  /// **'Discover • Play • Learn'**
  String get tagline;

  /// No description provided for @chooseGame.
  ///
  /// In en, this message translates to:
  /// **'Choose a Game!'**
  String get chooseGame;

  /// No description provided for @starsBadge.
  ///
  /// In en, this message translates to:
  /// **'3 Stars!'**
  String get starsBadge;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @tapToPlay.
  ///
  /// In en, this message translates to:
  /// **'TAP TO PLAY!'**
  String get tapToPlay;

  /// No description provided for @newRibbon.
  ///
  /// In en, this message translates to:
  /// **'NEW! 🔥'**
  String get newRibbon;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'🚀 More games coming soon!'**
  String get comingSoon;

  /// No description provided for @gamePuzzles.
  ///
  /// In en, this message translates to:
  /// **'PUZZLES'**
  String get gamePuzzles;

  /// No description provided for @gamePuzzlesSub.
  ///
  /// In en, this message translates to:
  /// **'Match shapes!'**
  String get gamePuzzlesSub;

  /// No description provided for @gameMatching.
  ///
  /// In en, this message translates to:
  /// **'MATCHING'**
  String get gameMatching;

  /// No description provided for @gameMatchingSub.
  ///
  /// In en, this message translates to:
  /// **'Find the pairs!'**
  String get gameMatchingSub;

  /// No description provided for @gameColoring.
  ///
  /// In en, this message translates to:
  /// **'COLORING'**
  String get gameColoring;

  /// No description provided for @gameColoringSub.
  ///
  /// In en, this message translates to:
  /// **'Paint & color!'**
  String get gameColoringSub;

  /// No description provided for @gameCounting.
  ///
  /// In en, this message translates to:
  /// **'COUNTING'**
  String get gameCounting;

  /// No description provided for @gameCountingSub.
  ///
  /// In en, this message translates to:
  /// **'Learn numbers!'**
  String get gameCountingSub;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get languageTitle;

  /// No description provided for @languageDeviceDefault.
  ///
  /// In en, this message translates to:
  /// **'Device language'**
  String get languageDeviceDefault;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageTurkish.
  ///
  /// In en, this message translates to:
  /// **'Türkçe'**
  String get languageTurkish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'PLAY!'**
  String get play;

  /// No description provided for @playNow.
  ///
  /// In en, this message translates to:
  /// **'PLAY NOW!'**
  String get playNow;

  /// No description provided for @moreLabel.
  ///
  /// In en, this message translates to:
  /// **'+more'**
  String get moreLabel;

  /// No description provided for @chooseTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose a Theme!'**
  String get chooseTheme;

  /// No description provided for @pickYourAdventure.
  ///
  /// In en, this message translates to:
  /// **'Pick your adventure 🎨'**
  String get pickYourAdventure;

  /// No description provided for @themeAnimals.
  ///
  /// In en, this message translates to:
  /// **'Animals'**
  String get themeAnimals;

  /// No description provided for @themefruitsAndVegetables.
  ///
  /// In en, this message translates to:
  /// **'Fruits & Vegetables'**
  String get themefruitsAndVegetables;

  /// No description provided for @themeVehicles.
  ///
  /// In en, this message translates to:
  /// **'Vehicles'**
  String get themeVehicles;

  /// No description provided for @themeShapes.
  ///
  /// In en, this message translates to:
  /// **'Shapes'**
  String get themeShapes;

  /// No description provided for @themeFruits.
  ///
  /// In en, this message translates to:
  /// **'Fruits'**
  String get themeFruits;

  /// No description provided for @themeVegetables.
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get themeVegetables;

  /// No description provided for @puzzlesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Puzzles'**
  String puzzlesCount(int count);

  /// No description provided for @unlockAnimalsHint.
  ///
  /// In en, this message translates to:
  /// **'🔓 Complete Animals to unlock more!'**
  String get unlockAnimalsHint;

  /// No description provided for @matchingGameTitle.
  ///
  /// In en, this message translates to:
  /// **'Matching Game!'**
  String get matchingGameTitle;

  /// No description provided for @pickCategoryToMatch.
  ///
  /// In en, this message translates to:
  /// **'Pick a category to match'**
  String get pickCategoryToMatch;

  /// No description provided for @howToPlayPart1.
  ///
  /// In en, this message translates to:
  /// **'Cards show for '**
  String get howToPlayPart1;

  /// No description provided for @howToPlayHighlight.
  ///
  /// In en, this message translates to:
  /// **'a few seconds'**
  String get howToPlayHighlight;

  /// No description provided for @howToPlayPart2.
  ///
  /// In en, this message translates to:
  /// **' — remember them, then find all the matching pairs!'**
  String get howToPlayPart2;

  /// No description provided for @matchingAnimals.
  ///
  /// In en, this message translates to:
  /// **'Animals'**
  String get matchingAnimals;

  /// No description provided for @matchingAnimalsDesc.
  ///
  /// In en, this message translates to:
  /// **'Match cute animals!'**
  String get matchingAnimalsDesc;

  /// No description provided for @matchingFruits.
  ///
  /// In en, this message translates to:
  /// **'Fruits'**
  String get matchingFruits;

  /// No description provided for @matchingFruitsDesc.
  ///
  /// In en, this message translates to:
  /// **'Match yummy fruits!'**
  String get matchingFruitsDesc;

  /// No description provided for @matchingVegetables.
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get matchingVegetables;

  /// No description provided for @matchingVegetablesDesc.
  ///
  /// In en, this message translates to:
  /// **'Match healthy food!'**
  String get matchingVegetablesDesc;

  /// No description provided for @matchingFruitAndVegetablesDesc.
  ///
  /// In en, this message translates to:
  /// **'Match tasty treats!'**
  String get matchingFruitAndVegetablesDesc;

  /// No description provided for @matchingFoods.
  ///
  /// In en, this message translates to:
  /// **'Foods'**
  String get matchingFoods;

  /// No description provided for @matchingFoodsDesc.
  ///
  /// In en, this message translates to:
  /// **'Match delicious foods!'**
  String get matchingFoodsDesc;

  /// No description provided for @matchingVehicles.
  ///
  /// In en, this message translates to:
  /// **'Vehicles'**
  String get matchingVehicles;

  /// No description provided for @matchingVehiclesDesc.
  ///
  /// In en, this message translates to:
  /// **'Find the vehicles!'**
  String get matchingVehiclesDesc;

  /// No description provided for @matchingObjects.
  ///
  /// In en, this message translates to:
  /// **'Objects'**
  String get matchingObjects;

  /// No description provided for @matchingObjectsDesc.
  ///
  /// In en, this message translates to:
  /// **'Match fun objects!'**
  String get matchingObjectsDesc;

  /// No description provided for @levelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level {number}'**
  String levelLabel(int number);

  /// No description provided for @pairsProgress.
  ///
  /// In en, this message translates to:
  /// **'{matched}/{total} pairs'**
  String pairsProgress(int matched, int total);

  /// No description provided for @rememberCards.
  ///
  /// In en, this message translates to:
  /// **'👀 Remember the cards!'**
  String get rememberCards;

  /// No description provided for @flipCountdownOne.
  ///
  /// In en, this message translates to:
  /// **'They\'ll flip over in 1 second…'**
  String get flipCountdownOne;

  /// No description provided for @flipCountdownOther.
  ///
  /// In en, this message translates to:
  /// **'They\'ll flip over in {count} seconds…'**
  String flipCountdownOther(int count);

  /// No description provided for @movesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} moves'**
  String movesCount(int count);

  /// No description provided for @levelDone.
  ///
  /// In en, this message translates to:
  /// **'{level} Done!'**
  String levelDone(String level);

  /// No description provided for @matchedAllSummary.
  ///
  /// In en, this message translates to:
  /// **'You matched all {pairs} pairs in {moves} moves!'**
  String matchedAllSummary(int pairs, int moves);

  /// No description provided for @nextLevel.
  ///
  /// In en, this message translates to:
  /// **'🚀 {level} — {cards} cards!'**
  String nextLevel(String level, int cards);

  /// No description provided for @beatAllLevels.
  ///
  /// In en, this message translates to:
  /// **'🏆 You beat all levels!'**
  String get beatAllLevels;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'🔄 Retry'**
  String get retry;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'🏠 Menu'**
  String get menu;

  /// No description provided for @pickAnimal.
  ///
  /// In en, this message translates to:
  /// **'Pick an Animal! 🐾'**
  String get pickAnimal;

  /// No description provided for @choosePuzzleBuddy.
  ///
  /// In en, this message translates to:
  /// **'Choose your puzzle buddy'**
  String get choosePuzzleBuddy;

  /// No description provided for @animalLion.
  ///
  /// In en, this message translates to:
  /// **'Lion'**
  String get animalLion;

  /// No description provided for @animalElephant.
  ///
  /// In en, this message translates to:
  /// **'Elephant'**
  String get animalElephant;

  /// No description provided for @animalGiraffe.
  ///
  /// In en, this message translates to:
  /// **'Giraffe'**
  String get animalGiraffe;

  /// No description provided for @animalTiger.
  ///
  /// In en, this message translates to:
  /// **'Tiger'**
  String get animalTiger;

  /// No description provided for @animalPenguin.
  ///
  /// In en, this message translates to:
  /// **'Penguin'**
  String get animalPenguin;

  /// No description provided for @animalRabbit.
  ///
  /// In en, this message translates to:
  /// **'Rabbit'**
  String get animalRabbit;

  /// No description provided for @puzzleTitle.
  ///
  /// In en, this message translates to:
  /// **'{animal} Puzzle 🧩'**
  String puzzleTitle(String animal);

  /// No description provided for @dragPiecesHint.
  ///
  /// In en, this message translates to:
  /// **'Drag the pieces to build the animal!'**
  String get dragPiecesHint;

  /// No description provided for @assemblyArea.
  ///
  /// In en, this message translates to:
  /// **'ASSEMBLY AREA'**
  String get assemblyArea;

  /// No description provided for @dragPiecesAbove.
  ///
  /// In en, this message translates to:
  /// **'DRAG THE PIECES ABOVE!'**
  String get dragPiecesAbove;

  /// No description provided for @youDidIt.
  ///
  /// In en, this message translates to:
  /// **'You did it!'**
  String get youDidIt;

  /// No description provided for @puzzleComplete.
  ///
  /// In en, this message translates to:
  /// **'{animal} puzzle complete! 🌟'**
  String puzzleComplete(String animal);

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again! 🔄'**
  String get playAgain;

  /// No description provided for @pieceHead.
  ///
  /// In en, this message translates to:
  /// **'Head'**
  String get pieceHead;

  /// No description provided for @pieceBody.
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get pieceBody;

  /// No description provided for @pieceTail.
  ///
  /// In en, this message translates to:
  /// **'Tail'**
  String get pieceTail;

  /// No description provided for @pieceLegs.
  ///
  /// In en, this message translates to:
  /// **'Legs'**
  String get pieceLegs;

  /// No description provided for @pieceEars.
  ///
  /// In en, this message translates to:
  /// **'Ears'**
  String get pieceEars;

  /// No description provided for @pieceNeck.
  ///
  /// In en, this message translates to:
  /// **'Neck'**
  String get pieceNeck;

  /// No description provided for @noPuzzlesFound.
  ///
  /// In en, this message translates to:
  /// **'No puzzles found here!'**
  String get noPuzzlesFound;

  /// No description provided for @chooseYourPuzzle.
  ///
  /// In en, this message translates to:
  /// **'Choose your puzzle'**
  String get chooseYourPuzzle;

  /// No description provided for @rotateDevicePrompt.
  ///
  /// In en, this message translates to:
  /// **'Rotate your phone landscape to play this game! 🔄'**
  String get rotateDevicePrompt;

  /// No description provided for @awesome.
  ///
  /// In en, this message translates to:
  /// **'Awesome!'**
  String get awesome;

  /// No description provided for @wrongTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Oops! Try again!'**
  String get wrongTryAgain;

  /// No description provided for @wrongSoClose.
  ///
  /// In en, this message translates to:
  /// **'So close! Keep going!'**
  String get wrongSoClose;

  /// No description provided for @wrongYouCanDoIt.
  ///
  /// In en, this message translates to:
  /// **'You can do it!'**
  String get wrongYouCanDoIt;

  /// No description provided for @wrongNotQuite.
  ///
  /// In en, this message translates to:
  /// **'Hmm, not quite!'**
  String get wrongNotQuite;

  /// No description provided for @wrongAlmost.
  ///
  /// In en, this message translates to:
  /// **'Almost! Try again!'**
  String get wrongAlmost;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
