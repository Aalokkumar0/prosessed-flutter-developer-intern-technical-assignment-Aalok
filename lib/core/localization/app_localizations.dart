import 'package:flutter/widgets.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('hi')];

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const _values = <String, Map<String, String>>{
    'en': {
      'shop': 'Shop',
      'saved': 'Saved',
      'cart': 'Cart',
      'profile': 'Profile',
      'settings': 'Preferences',
      'darkMode': 'Dark mode',
      'language': 'Language',
      'english': 'English',
      'hindi': 'Hindi',
      'signOut': 'Sign out',
      'offline': 'You are offline. Showing saved products.',
      'savedEmpty': 'No saved products yet',
      'savedEmptyMessage': 'Tap the heart on a product to keep it here.',
      'welcome': 'Welcome back',
      'welcomeMessage': 'Sign in to discover products picked for you.',
      'username': 'Username',
      'password': 'Password',
      'signIn': 'Sign in',
      'discover': 'Discover',
      'searchProducts': 'Search products',
      'all': 'All',
      'yourBag': 'Your bag',
      'emptyBag': 'Your bag is empty',
      'emptyBagMessage': 'Explore the catalogue and add something you love.',
      'placeOrder': 'Place order',
      'productDetails': 'Product details',
      'addToCart': 'Add to cart',
      'outOfStock': 'Out of stock',
      'customerReviews': 'Customer reviews',
    },
    'hi': {
      'shop': 'खरीदारी',
      'saved': 'पसंदीदा',
      'cart': 'कार्ट',
      'profile': 'प्रोफ़ाइल',
      'settings': 'प्राथमिकताएँ',
      'darkMode': 'डार्क मोड',
      'language': 'भाषा',
      'english': 'अंग्रेज़ी',
      'hindi': 'हिन्दी',
      'signOut': 'साइन आउट',
      'offline': 'आप ऑफ़लाइन हैं। सहेजे गए उत्पाद दिखाए जा रहे हैं।',
      'savedEmpty': 'अभी कोई पसंदीदा उत्पाद नहीं',
      'savedEmptyMessage': 'उत्पाद सहेजने के लिए दिल के निशान पर टैप करें।',
      'welcome': 'वापसी पर स्वागत है',
      'welcomeMessage': 'अपने लिए चुने गए उत्पाद देखने के लिए साइन इन करें।',
      'username': 'उपयोगकर्ता नाम',
      'password': 'पासवर्ड',
      'signIn': 'साइन इन',
      'discover': 'उत्पाद खोजें',
      'searchProducts': 'उत्पाद खोजें',
      'all': 'सभी',
      'yourBag': 'आपका कार्ट',
      'emptyBag': 'आपका कार्ट खाली है',
      'emptyBagMessage': 'कैटलॉग देखें और पसंदीदा उत्पाद जोड़ें।',
      'placeOrder': 'ऑर्डर करें',
      'productDetails': 'उत्पाद विवरण',
      'addToCart': 'कार्ट में जोड़ें',
      'outOfStock': 'स्टॉक में नहीं',
      'customerReviews': 'ग्राहक समीक्षाएँ',
    },
  };

  String text(String key) =>
      _values[locale.languageCode]?[key] ?? _values['en']![key] ?? key;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'hi'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension LocalizationContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
