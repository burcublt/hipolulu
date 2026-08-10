// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'HippoLulu';

  @override
  String get tagline => '✨ Öğren · Oyna · Geliş';

  @override
  String get chooseGame => '🎮 Bir Oyun Seç!';

  @override
  String get starsBadge => '3 Yıldız!';

  @override
  String get locked => 'Kilitli';

  @override
  String get tapToPlay => 'OYNAMAK İÇİN DOKUN!';

  @override
  String get newRibbon => 'YENİ! 🔥';

  @override
  String get comingSoon => '🚀 Daha fazla oyun yakında!';

  @override
  String get gamePuzzles => 'YAPBOZ';

  @override
  String get gamePuzzlesSub => 'Şekilleri eşleştir!';

  @override
  String get gameMatching => 'EŞLEŞTİRME';

  @override
  String get gameMatchingSub => 'Çiftleri bul!';

  @override
  String get gameColoring => 'BOYAMA';

  @override
  String get gameColoringSub => 'Boyama zamanı!';

  @override
  String get gameCounting => 'SAYMA';

  @override
  String get gameCountingSub => 'Sayıları öğren!';

  @override
  String get languageTitle => 'Dil Seç';

  @override
  String get languageDeviceDefault => 'Cihaz dili';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageSpanish => 'Español';

  @override
  String get back => 'Geri';

  @override
  String get play => 'OYNA!';

  @override
  String get playNow => 'HEMEN OYNA!';

  @override
  String get moreLabel => '+daha';

  @override
  String get chooseTheme => 'Bir Tema Seç!';

  @override
  String get pickYourAdventure => 'Macerana başla 🎨';

  @override
  String get themeAnimals => 'Hayvanlar';

  @override
  String get themefruitsAndVegetables => 'Meyve ve Sebzeler';

  @override
  String get themeVehicles => 'Taşıtlar';

  @override
  String get themeShapes => 'Şekiller';

  @override
  String get themeFruits => 'Meyveler';

  @override
  String get themeVegetables => 'Sebzeler';

  @override
  String puzzlesCount(int count) {
    return '$count Yapboz';
  }

  @override
  String get unlockAnimalsHint =>
      '🔓 Daha fazlasını açmak için Hayvanları tamamla!';

  @override
  String get matchingGameTitle => 'Eşleştirme Oyunu!';

  @override
  String get pickCategoryToMatch => 'Eşleştirmek için bir kategori seç';

  @override
  String get howToPlayPart1 => 'Kartlar ';

  @override
  String get howToPlayHighlight => 'birkaç saniye';

  @override
  String get howToPlayPart2 => ' görünür — hatırla ve tüm çiftleri bul!';

  @override
  String get matchingAnimals => 'Hayvanlar';

  @override
  String get matchingAnimalsDesc => 'Sevimli hayvanları eşleştir!';

  @override
  String get matchingFruits => 'Meyveler';

  @override
  String get matchingFruitsDesc => 'Tatlı meyveleri eşleştir!';

  @override
  String get matchingVegetables => 'Sebzeler';

  @override
  String get matchingVegetablesDesc => 'Sağlıklı sebzeleri eşleştir!';

  @override
  String get matchingFruitAndVegetablesDesc =>
      'Tatlı meyve ve sebzeleri eşleştir!';

  @override
  String get matchingFoods => 'Yemekler';

  @override
  String get matchingFoodsDesc => 'Lezzetli yemekleri eşleştir!';

  @override
  String get matchingVehicles => 'Taşıtlar';

  @override
  String get matchingVehiclesDesc => 'Taşıtları bul!';

  @override
  String get matchingObjects => 'Nesneler';

  @override
  String get matchingObjectsDesc => 'Eğlenceli nesneleri eşleştir!';

  @override
  String levelLabel(int number) {
    return 'Seviye $number';
  }

  @override
  String pairsProgress(int matched, int total) {
    return '$matched/$total çift';
  }

  @override
  String get rememberCards => '👀 Kartları hatırla!';

  @override
  String get flipCountdownOne => '1 saniye içinde kapanacaklar…';

  @override
  String flipCountdownOther(int count) {
    return '$count saniye içinde kapanacaklar…';
  }

  @override
  String movesCount(int count) {
    return '$count hamle';
  }

  @override
  String levelDone(String level) {
    return '$level Tamam!';
  }

  @override
  String matchedAllSummary(int pairs, int moves) {
    return 'Tüm $pairs çifti $moves hamlede eşleştirdin!';
  }

  @override
  String nextLevel(String level, int cards) {
    return '🚀 $level — $cards kart!';
  }

  @override
  String get beatAllLevels => '🏆 Tüm seviyeleri geçtin!';

  @override
  String get retry => '🔄 Tekrar';

  @override
  String get menu => '🏠 Menü';

  @override
  String get pickAnimal => 'Bir Hayvan Seç! 🐾';

  @override
  String get choosePuzzleBuddy => 'Yapboz arkadaşını seç';

  @override
  String get animalLion => 'Aslan';

  @override
  String get animalElephant => 'Fil';

  @override
  String get animalGiraffe => 'Zürafa';

  @override
  String get animalTiger => 'Kaplan';

  @override
  String get animalPenguin => 'Penguen';

  @override
  String get animalRabbit => 'Tavşan';

  @override
  String puzzleTitle(String animal) {
    return '$animal Yapbozu 🧩';
  }

  @override
  String get dragPiecesHint => 'Parçaları sürükleyerek hayvanı oluştur!';

  @override
  String get assemblyArea => 'BİRLEŞTİRME ALANI';

  @override
  String get dragPiecesAbove => 'PARÇALARI YUKARI SÜRÜKLE!';

  @override
  String get youDidIt => 'Başardın!';

  @override
  String puzzleComplete(String animal) {
    return '$animal yapbozu tamam! 🌟';
  }

  @override
  String get playAgain => 'Tekrar Oyna! 🔄';

  @override
  String get pieceHead => 'Kafa';

  @override
  String get pieceBody => 'Gövde';

  @override
  String get pieceTail => 'Kuyruk';

  @override
  String get pieceLegs => 'Bacaklar';

  @override
  String get pieceEars => 'Kulaklar';

  @override
  String get pieceNeck => 'Boyun';
}
