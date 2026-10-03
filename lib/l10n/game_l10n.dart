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
      // Puzzle scenes
      'cute_dinosaurs_camp': {
        'en': 'Cute Dinosaur Camp',
        'tr': 'Sevimli Dinozor Kampı',
        'es': 'Campamento de dinosaurios adorables'
      },
      'hatching_from_an_egg': {
        'en': 'Hatching from an Egg',
        'tr': 'Yumurtadan Çıkış',
        'es': 'Saliendo del huevo'
      },
      'crystal_cave': {
        'en': 'Crystal Cave',
        'tr': 'Kristal Mağara',
        'es': 'Cueva de cristal'
      },
      'balloon_festival': {
        'en': 'Balloon Festival',
        'tr': 'Balon Festivali',
        'es': 'Festival de globos'
      },
      'sunset': {'en': 'Sunset', 'tr': 'Gün Batımı', 'es': 'Atardecer'},
      'game_bridge': {
        'en': 'Play Bridge',
        'tr': 'Oyun Köprüsü',
        'es': 'Puente de juegos'
      },
      'the_water_war_at_the_waterfall': {
        'en': 'Water Games at the Waterfall',
        'tr': 'Şelalede Su Oyunları',
        'es': 'Juegos de agua en la cascada'
      },
      'volcanic_region': {
        'en': 'Volcanic Region',
        'tr': 'Volkanik Bölge',
        'es': 'Región volcánica'
      },
      'hide_and_seek': {
        'en': 'Hide and Seek',
        'tr': 'Saklambaç',
        'es': 'El escondite'
      },
      'fruit_festival': {
        'en': 'Fruit Festival',
        'tr': 'Meyve Festivali',
        'es': 'Festival de frutas'
      },
      'the_lost_stones_of_the_dinosaurs': {
        'en': 'The Dinosaurs’ Lost Stones',
        'tr': 'Dinozorların Kayıp Taşları',
        'es': 'Las piedras perdidas de los dinosaurios'
      },
      'fun_in_the_snow': {
        'en': 'Fun in the Snow',
        'tr': 'Karda Eğlence',
        'es': 'Diversión en la nieve'
      },
      'giant_mushroom_forest': {
        'en': 'Giant Mushroom Forest',
        'tr': 'Dev Mantar Ormanı',
        'es': 'Bosque de hongos gigantes'
      },
      'underwater_orchestra': {
        'en': 'Underwater Orchestra',
        'tr': 'Su Altı Orkestrası',
        'es': 'Orquesta submarina'
      },
      'underwater_lantern': {
        'en': 'Underwater Lantern',
        'tr': 'Su Altı Feneri',
        'es': 'Farol submarino'
      },
      'underwater_gardeners': {
        'en': 'Underwater Gardeners',
        'tr': 'Su Altı Bahçıvanları',
        'es': 'Jardineros submarinos'
      },
      'first_exploration_of_the_coral_garden': {
        'en': 'Exploring the Coral Garden',
        'tr': 'Mercan Bahçesini Keşif',
        'es': 'Explorando el jardín de coral'
      },
      'jellyfish_light_garden': {
        'en': 'Jellyfish Light Garden',
        'tr': 'Denizanalarının Işık Bahçesi',
        'es': 'Jardín luminoso de medusas'
      },
      'bubble_valley': {
        'en': 'Bubble Valley',
        'tr': 'Baloncuk Vadisi',
        'es': 'Valle de burbujas'
      },
      'fun_in_the_sand': {
        'en': 'Fun in the Sand',
        'tr': 'Kumda Eğlence',
        'es': 'Diversión en la arena'
      },
      'the_sea_turtle_race': {
        'en': 'Sea Turtle Race',
        'tr': 'Deniz Kaplumbağası Yarışı',
        'es': 'Carrera de tortugas marinas'
      },
      'underwater_chiefs': {
        'en': 'Underwater Chiefs',
        'tr': 'Su Altı Liderleri',
        'es': 'Líderes submarinos'
      },
      'arctic_ocean_adventure': {
        'en': 'Arctic Ocean Adventure',
        'tr': 'Kuzey Buz Denizi Macerası',
        'es': 'Aventura en el océano Ártico'
      },
      'acrobatic_show': {
        'en': 'Acrobatic Show',
        'tr': 'Akrobasi Gösterisi',
        'es': 'Espectáculo acrobático'
      },
      'valley_of_the_colorful_fish': {
        'en': 'Valley of Colorful Fish',
        'tr': 'Renkli Balıklar Vadisi',
        'es': 'Valle de peces de colores'
      },
      'magic_brushes': {
        'en': 'Magic Brushes',
        'tr': 'Sihirli Fırçalar',
        'es': 'Pinceles mágicos'
      },
      'the_discovery_of_colored_stones': {
        'en': 'Discovering Colored Stones',
        'tr': 'Renkli Taşların Keşfi',
        'es': 'Descubriendo piedras de colores'
      },
      'whale_passage': {
        'en': 'Whale Passage',
        'tr': 'Balinaların Geçişi',
        'es': 'El paso de las ballenas'
      },

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
      'fire_truck': {
        'en': 'Fire Truck',
        'tr': 'İtfaiye Kamyonu',
        'es': 'Camión de bomberos'
      },
      'garbage_truck': {
        'en': 'Garbage Truck',
        'tr': 'Çöp Kamyonu',
        'es': 'Camión de basura'
      },
      'helicopter': {
        'en': 'Helicopter',
        'tr': 'Helikopter',
        'es': 'Helicóptero'
      },
      'motorcycle': {
        'en': 'Motorcycle',
        'tr': 'Motosiklet',
        'es': 'Motocicleta'
      },
      'police_car': {
        'en': 'Police Car',
        'tr': 'Polis Arabası',
        'es': 'Coche de policía'
      },
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
