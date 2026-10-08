// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'HippoLulu';

  @override
  String get tagline => 'Explora • Juega • Aprende';

  @override
  String get chooseGame => '🌟 ¡Elige un juego! 🌟';

  @override
  String get starsBadge => '¡3 estrellas!';

  @override
  String get locked => 'Bloqueado';

  @override
  String get tapToPlay => '¡TOCA PARA JUGAR!';

  @override
  String get newRibbon => '¡NUEVO! 🔥';

  @override
  String get comingSoon => '🚀 ¡Más juegos pronto!';

  @override
  String get gamePuzzles => 'PUZZLES';

  @override
  String get gamePuzzlesSub => '¡Combina formas!';

  @override
  String get gameMatching => 'MEMORIA';

  @override
  String get gameMatchingSub => '¡Encuentra las parejas!';

  @override
  String get gameColoring => 'COLOREAR';

  @override
  String get gameColoringSub => '¡Pinta y colorea!';

  @override
  String get gameCounting => 'CONTAR';

  @override
  String get gameCountingSub => '¡Aprende números!';

  @override
  String get languageTitle => 'Elegir idioma';

  @override
  String get languageDeviceDefault => 'Idioma del dispositivo';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageSpanish => 'Español';

  @override
  String get back => 'Atrás';

  @override
  String get play => '¡JUGAR!';

  @override
  String get playNow => '¡JUGAR AHORA!';

  @override
  String get moreLabel => '+más';

  @override
  String get chooseTheme => '¡Elige un tema!';

  @override
  String get pickYourAdventure => 'Elige tu aventura 🎨';

  @override
  String get themeAnimals => 'Animales';

  @override
  String get themefruitsAndVegetables => 'Frutas y verduras';

  @override
  String get themeVehicles => 'Vehículos';

  @override
  String get themeShapes => 'Formas';

  @override
  String get themeFruits => 'Frutas';

  @override
  String get themeVegetables => 'verduras';

  @override
  String get themeDinosaur => 'Dinosaurios';

  @override
  String get themeSpace => 'Espacio';

  @override
  String get themeUnderwater => 'Bajo el mar';

  @override
  String get themeFarm => 'Granja';

  @override
  String get themeAmusementPark => 'Parque de Atracciones';

  @override
  String get themeHippolulu => 'HippoLulu';

  @override
  String puzzlesCount(int count) {
    return '$count puzzles';
  }

  @override
  String get unlockAnimalsHint => '🔓 ¡Completa Animales para desbloquear más!';

  @override
  String get matchingGameTitle => '¡Juego de memoria!';

  @override
  String get pickCategoryToMatch => 'Elige una categoría';

  @override
  String get howToPlayPart1 => 'Las cartas se muestran ';

  @override
  String get howToPlayHighlight => 'unos segundos';

  @override
  String get howToPlayPart2 => ' — ¡memorízalas y encuentra todas las parejas!';

  @override
  String get matchingAnimals => 'Animales';

  @override
  String get matchingAnimalsDesc => '¡Combina animales!';

  @override
  String get matchingFruits => 'Frutas';

  @override
  String get matchingFruitsDesc => '¡Empareja frutas deliciosas!';

  @override
  String get matchingVegetables => 'Saludables';

  @override
  String get matchingVegetablesDesc => '¡Empareja alimentos saludables!';

  @override
  String get matchingFruitAndVegetablesDesc => '¡Combina sabores deliciosos!';

  @override
  String get matchingFoods => 'Comidas';

  @override
  String get matchingFoodsDesc => '¡Empareja comidas deliciosas!';

  @override
  String get matchingVehicles => 'Vehículos';

  @override
  String get matchingVehiclesDesc => '¡Encuentra los vehículos!';

  @override
  String get matchingObjects => 'Objetos';

  @override
  String get matchingObjectsDesc => '¡Combina objetos divertidos!';

  @override
  String levelLabel(int number) {
    return 'Nivel $number';
  }

  @override
  String pairsProgress(int matched, int total) {
    return '$matched/$total parejas';
  }

  @override
  String get rememberCards => '👀 ¡Recuerda las cartas!';

  @override
  String get flipCountdownOne => 'Se voltearán en 1 segundo…';

  @override
  String flipCountdownOther(int count) {
    return 'Se voltearán en $count segundos…';
  }

  @override
  String movesCount(int count) {
    return '$count movimientos';
  }

  @override
  String levelDone(String level) {
    return '¡$level listo!';
  }

  @override
  String matchedAllSummary(int pairs, int moves) {
    return '¡Combinaste $pairs parejas en $moves movimientos!';
  }

  @override
  String nextLevel(String level, int cards) {
    return '🚀 $level — ¡$cards cartas!';
  }

  @override
  String get beatAllLevels => '🏆 ¡Superaste todos los niveles!';

  @override
  String get retry => 'Reintentar';

  @override
  String get menu => 'Menú';

  @override
  String get pickAnimal => '¡Elige un animal! 🐾';

  @override
  String get choosePuzzleBuddy => 'Elige tu compañero de puzzle';

  @override
  String get animalLion => 'León';

  @override
  String get animalElephant => 'Elefante';

  @override
  String get animalGiraffe => 'Jirafa';

  @override
  String get animalTiger => 'Tigre';

  @override
  String get animalPenguin => 'Pingüino';

  @override
  String get animalRabbit => 'Conejo';

  @override
  String puzzleTitle(String animal) {
    return 'Puzzle de $animal 🧩';
  }

  @override
  String get dragPiecesHint => '¡Arrastra las piezas para armar el animal!';

  @override
  String get assemblyArea => 'ÁREA DE ARMADO';

  @override
  String get dragPiecesAbove => '¡ARRASTRA LAS PIEZAS ARRIBA!';

  @override
  String get youDidIt => '¡Lo lograste!';

  @override
  String puzzleComplete(String animal) {
    return '¡Puzzle de $animal completo! 🌟';
  }

  @override
  String get playAgain => '¡Jugar de nuevo!';

  @override
  String get pieceHead => 'Cabeza';

  @override
  String get pieceBody => 'Cuerpo';

  @override
  String get pieceTail => 'Cola';

  @override
  String get pieceLegs => 'Patas';

  @override
  String get pieceEars => 'Orejas';

  @override
  String get pieceNeck => 'Cuello';

  @override
  String get noPuzzlesFound => '¡No se encontraron puzzles aquí!';

  @override
  String get chooseYourPuzzle => 'Elige tu puzzle';

  @override
  String get rotateDevicePrompt =>
      '¡Gira tu teléfono de lado para jugar este juego! 🔄';

  @override
  String get awesome => '¡Increíble!';

  @override
  String get wrongTryAgain => '¡Uy! ¡Inténtalo de nuevo!';

  @override
  String get wrongSoClose => '¡Tan cerca! ¡Sigue así!';

  @override
  String get wrongYouCanDoIt => '¡Tú puedes!';

  @override
  String get wrongNotQuite => '¡Hmm, no del todo!';

  @override
  String get wrongAlmost => '¡Casi! ¡Inténtalo de nuevo!';

  @override
  String get letsPlay => '¡Vamos a Jugar!';

  @override
  String get matchGreat => '¡Muy bien!';

  @override
  String get matchAwesome => '¡Genial!';

  @override
  String get matchYay => '¡Bravo!';

  @override
  String get matchTryAgain => '¡Inténtalo otra vez!';

  @override
  String get matchAlmost => '¡Casi!';

  @override
  String get matchYouCan => '¡Tú puedes!';

  @override
  String get unlockAll => 'Desbloquear todo';

  @override
  String get unlockGames => 'Todos los juegos juntos';

  @override
  String get unlockGamesDetail => '¡Puzles, parejas y nuevas aventuras!';

  @override
  String get unlockThemes => 'Todos los temas y actividades';

  @override
  String get unlockThemesDetail => 'Descubre todos los temas bloqueados.';

  @override
  String get unlockNew => 'Un mundo de juegos que crece';

  @override
  String get unlockNewDetail => 'Nuevas aventuras por descubrir.';

  @override
  String get unlockSafe => 'Diversión sin anuncios';

  @override
  String get unlockSafeDetail => 'Disfruta jugando sin interrupciones.';

  @override
  String get unlockAnnual => 'Suscripción de 1 año';

  @override
  String get unlockBadge => 'ACCESO COMPLETO';

  @override
  String get unlockPriceUnavailable => 'Precio no disponible por ahora';

  @override
  String get unlockSubscribe => 'Desbloquear todo';

  @override
  String get unlockBilling =>
      'Suscripción anual. Se renueva automáticamente salvo cancelación.';

  @override
  String get unlockRestore => 'Restaurar compras';

  @override
  String get unlockPrivacy => 'Privacidad';

  @override
  String get unlockTerms => 'Condiciones de uso';

  @override
  String get parentTitle => 'Área para padres';

  @override
  String get parentPrompt => 'Responde a la pregunta\npara continuar.';

  @override
  String get parentRetry => 'Inténtalo de nuevo.';

  @override
  String get parentGreat => '¡Genial!';

  @override
  String get parentContinue => 'Puedes continuar.';

  @override
  String get parentCancel => 'Cancelar';

  @override
  String get parentStoreUnavailable =>
      'Las compras no están disponibles por ahora. Inténtalo más tarde.';

  @override
  String get matchingRememberTitle => '¡Recuerda las cartas!';

  @override
  String get matchingFindTitle => '¡Encuentra las parejas!';

  @override
  String get matchingPreviewInstruction =>
      'Se darán la vuelta en unos segundos…';

  @override
  String get matchingTapInstruction =>
      '¡Toca dos cartas para encontrar una pareja!';

  @override
  String get matchingPreviewHint => '¡Memoriza las cartas!';

  @override
  String get matchingPlayHint => '¡Intenta encontrar todas las parejas!';

  @override
  String get puzzleImageLoadError =>
      'No se pudo cargar la imagen. Inténtalo de nuevo.';

  @override
  String get puzzleNewPuzzle => 'Nuevo puzle';
}
