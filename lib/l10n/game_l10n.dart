import 'package:hippolulu/l10n/app_localizations.dart';

/// Maps game enums and label keys to localized strings.
extension GameL10n on AppLocalizations {
  String flipCountdown(int count) {
    if (count == 1) return flipCountdownOne;
    return flipCountdownOther(count);
  }

  String animalName(String id) {
    switch (id) {
      case 'lion':
        return animalLion;
      case 'elephant':
        return animalElephant;
      case 'giraffe':
        return animalGiraffe;
      case 'tiger':
        return animalTiger;
      case 'penguin':
        return animalPenguin;
      case 'rabbit':
        return animalRabbit;
      default:
        return id;
    }
  }

  String pieceLabel(String key) {
    switch (key) {
      case 'head':
        return pieceHead;
      case 'body':
        return pieceBody;
      case 'tail':
        return pieceTail;
      case 'legs':
        return pieceLegs;
      case 'ears':
        return pieceEars;
      case 'neck':
        return pieceNeck;
      default:
        return key;
    }
  }
}
