/// Utility class for formatting currencies with proper symbols and formatting
class CurrencyFormatter {
  static const Map<String, String> _currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'AED': 'د.إ',
    'SAR': 'ر.س',
    'EGP': 'ج.م', // Egyptian Pound
  };

  static const Map<String, bool> _symbolAfterAmount = {
    'USD': false,
    'EUR': false,
    'GBP': false,
    'JPY': false,
    'AED': true,
    'SAR': true,
    'EGP': true,
  };

  /// Formats a price with the appropriate currency symbol
  static String formatPrice(double price, String currency, {int decimals = 2}) {
    final symbol = _currencySymbols[currency] ?? currency;
    final formattedPrice = price.toStringAsFixed(decimals);
    final showAfter = _symbolAfterAmount[currency] ?? false;
    
    if (showAfter) {
      return '$formattedPrice $symbol';
    } else {
      return '$symbol$formattedPrice';
    }
  }

  /// Gets the currency symbol for a given currency code
  static String getCurrencySymbol(String currency) {
    return _currencySymbols[currency] ?? currency;
  }

  /// Checks if the currency symbol should be placed after the amount
  static bool isSymbolAfterAmount(String currency) {
    return _symbolAfterAmount[currency] ?? false;
  }

  /// Gets a list of all supported currencies
  static List<String> getSupportedCurrencies() {
    return _currencySymbols.keys.toList();
  }

  /// Gets the currency name for display
  static String getCurrencyName(String currency) {
    const currencyNames = {
      'USD': 'US Dollar',
      'EUR': 'Euro',
      'GBP': 'British Pound',
      'JPY': 'Japanese Yen',
      'AED': 'UAE Dirham',
      'SAR': 'Saudi Riyal',
      'EGP': 'Egyptian Pound',
    };
    return currencyNames[currency] ?? currency;
  }
}
