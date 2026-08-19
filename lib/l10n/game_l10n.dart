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
        return itemTitle(id);
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

  /// Translates an asset path or filename key to the active language.
  String itemTitle(String pathOrKey) {
    final key = pathOrKey.split('/').last.split('.').first.toLowerCase();

    const Map<String, Map<String, String>> translations = {
      // Animals
      'bear': {'en': 'Bear', 'tr': 'Ayı', 'es': 'Oso'},
      'capybara': {'en': 'Capybara', 'tr': 'Kapibara', 'es': 'Capibara'},
      'cabybara': {'en': 'Capybara', 'tr': 'Kapibara', 'es': 'Capibara'},
      'cat': {'en': 'Cat', 'tr': 'Kedi', 'es': 'Gato'},
      'cow': {'en': 'Cow', 'tr': 'İnek', 'es': 'Vaca'},
      'dog': {'en': 'Dog', 'tr': 'Köpek', 'es': 'Perro'},
      'donkey': {'en': 'Donkey', 'tr': 'Eşek', 'es': 'Burro'},
      'elephant': {'en': 'Elephant', 'tr': 'Fil', 'es': 'Elefante'},
      'fox': {'en': 'Fox', 'tr': 'Tilki', 'es': 'Zorro'},
      'frog': {'en': 'Frog', 'tr': 'Kurbağa', 'es': 'Rana'},
      'giraffe': {'en': 'Giraffe', 'tr': 'Zürafa', 'es': 'Jirafa'},
      'horse': {'en': 'Horse', 'tr': 'At', 'es': 'Caballo'},
      'lion': {'en': 'Lion', 'tr': 'Aslan', 'es': 'León'},
      'parrot': {'en': 'Parrot', 'tr': 'Papağan', 'es': 'Loro'},
      'penguin': {'en': 'Penguin', 'tr': 'Penguen', 'es': 'Pingüino'},
      'rabbit': {'en': 'Rabbit', 'tr': 'Tavşan', 'es': 'Conejo'},
      'tiger': {'en': 'Tiger', 'tr': 'Kaplan', 'es': 'Tigre'},
      'turkey': {'en': 'Turkey', 'tr': 'Hindi', 'es': 'Pavo'},

      // Fruits
      'apple': {'en': 'Apple', 'tr': 'Elma', 'es': 'Manzana'},
      'avocado': {'en': 'Avocado', 'tr': 'Avokado', 'es': 'Aguacate'},
      'avokado': {'en': 'Avocado', 'tr': 'Avokado', 'es': 'Aguacate'},
      'banana': {'en': 'Banana', 'tr': 'Muz', 'es': 'Plátano'},
      'blueberry': {'en': 'Blueberry', 'tr': 'Yaban Mersini', 'es': 'Arándano'},
      'cherry': {'en': 'Cherry', 'tr': 'Kiraz', 'es': 'Cereza'},
      'grape': {'en': 'Grape', 'tr': 'Üzüm', 'es': 'Uva'},
      'kiwi': {'en': 'Kiwi', 'tr': 'Kivi', 'es': 'Kiwi'},
      'orange': {'en': 'Orange', 'tr': 'Portakal', 'es': 'Naranja'},
      'pineapple': {'en': 'Pineapple', 'tr': 'Ananas', 'es': 'Piña'},
      'strawberry': {'en': 'Strawberry', 'tr': 'Çilek', 'es': 'Fresa'},
      'watermelon': {'en': 'Watermelon', 'tr': 'Karpuz', 'es': 'Sandía'},

      // Vegetables
      'broccoli': {'en': 'Broccoli', 'tr': 'Brokoli', 'es': 'Brócoli'},
      'carrot': {'en': 'Carrot', 'tr': 'Havuç', 'es': 'Zanahoria'},
      'corn': {'en': 'Corn', 'tr': 'Mısır', 'es': 'Maíz'},
      'cucumber': {'en': 'Cucumber', 'tr': 'Salatalık', 'es': 'Pepino'},
      'eggplant': {'en': 'Eggplant', 'tr': 'Patlıcan', 'es': 'Berenjena'},
      'onion': {'en': 'Onion', 'tr': 'Soğan', 'es': 'Cebolla'},
      'potato': {'en': 'Potato', 'tr': 'Patates', 'es': 'Patata'},
      'pumpkin': {'en': 'Pumpkin', 'tr': 'Bal Kabağı', 'es': 'Calabaza'},
      'tomato': {'en': 'Tomato', 'tr': 'Domates', 'es': 'Tomate'},

      // Foods
      'bread': {'en': 'Bread', 'tr': 'Ekmek', 'es': 'Pan'},
      'butter': {'en': 'Butter', 'tr': 'Tereyağı', 'es': 'Mantequilla'},
      'cheese': {'en': 'Cheese', 'tr': 'Peynir', 'es': 'Queso'},
      'egg': {'en': 'Egg', 'tr': 'Yumurta', 'es': 'Huevo'},
      'ice_cream': {'en': 'Ice Cream', 'tr': 'Dondurma', 'es': 'Helado'},
      'milk': {'en': 'Milk', 'tr': 'Süt', 'es': 'Leche'},
      'pasta': {'en': 'Pasta', 'tr': 'Makarna', 'es': 'Pasta'},
      'pizza': {'en': 'Pizza', 'tr': 'Pizza', 'es': 'Pizza'},

      // Vehicles
      'airplane': {'en': 'Airplane', 'tr': 'Uçak', 'es': 'Avión'},
      'ambulance': {'en': 'Ambulance', 'tr': 'Ambulans', 'es': 'Ambulancia'},
      'bicycle': {'en': 'Bicycle', 'tr': 'Bisiklet', 'es': 'Bicicleta'},
      'bulldozer': {'en': 'Bulldozer', 'tr': 'Buldozer', 'es': 'Bulldozer'},
      'bus': {'en': 'Bus', 'tr': 'Otobüs', 'es': 'Autobús'},
      'car': {'en': 'Car', 'tr': 'Araba', 'es': 'Coche'},
      'excavator': {'en': 'Excavator', 'tr': 'Ekskavatör', 'es': 'Excavadora'},
      'fire_truck': {'en': 'Fire Truck', 'tr': 'İtfaiye Kamyonu', 'es': 'Camión de bomberos'},
      'garbage_truck': {'en': 'Garbage Truck', 'tr': 'Çöp Kamyonu', 'es': 'Camión de basura'},
      'helicopter': {'en': 'Helicopter', 'tr': 'Helikopter', 'es': 'Helicóptero'},
      'motorcycle': {'en': 'Motorcycle', 'tr': 'Motosiklet', 'es': 'Motocicleta'},
      'police_car': {'en': 'Police Car', 'tr': 'Polis Arabası', 'es': 'Coche de policía'},
      'ship': {'en': 'Ship', 'tr': 'Gemi', 'es': 'Barco'},
      'taxi': {'en': 'Taxi', 'tr': 'Taksi', 'es': 'Taxi'},
      'tractor': {'en': 'Tractor', 'tr': 'Traktör', 'es': 'Tractor'},
      'train': {'en': 'Train', 'tr': 'Tren', 'es': 'Tren'},
    };

    final lang = localeName.toLowerCase().split('_').first;
    if (translations.containsKey(key)) {
      final map = translations[key]!;
      return map[lang] ?? map['en'] ?? key;
    }

    final words = key.split('_').map((w) {
      if (w.isEmpty) return '';
      return w[0].toUpperCase() + w.substring(1).toLowerCase();
    }).toList();
    return words.join(' ');
  }
}
