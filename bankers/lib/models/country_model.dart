/// Country model with flag API support
/// Uses flagcdn.com for country flags
class Country {
  final String name;
  final String code; // ISO 3166-1 alpha-2 code
  final String dialCode;
  final String flagEmoji; // Fallback emoji

  const Country({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flagEmoji,
  });

  /// Get flag image URL from flagcdn.com
  String get flagUrl => 'https://flagcdn.com/w40/${code.toLowerCase()}.png';

  /// Get flag image URL for larger size
  String flagUrlLarge(int size) => 'https://flagcdn.com/w$size/${code.toLowerCase()}.png';

  static const List<Country> countries = [
    Country(name: 'India', code: 'IN', dialCode: '+91', flagEmoji: '🇮🇳'),
    Country(name: 'United States', code: 'US', dialCode: '+1', flagEmoji: '🇺🇸'),
    Country(name: 'United Kingdom', code: 'GB', dialCode: '+44', flagEmoji: '🇬🇧'),
    Country(name: 'Canada', code: 'CA', dialCode: '+1', flagEmoji: '🇨🇦'),
    Country(name: 'Australia', code: 'AU', dialCode: '+61', flagEmoji: '🇦🇺'),
    Country(name: 'Germany', code: 'DE', dialCode: '+49', flagEmoji: '🇩🇪'),
    Country(name: 'France', code: 'FR', dialCode: '+33', flagEmoji: '🇫🇷'),
    Country(name: 'Japan', code: 'JP', dialCode: '+81', flagEmoji: '🇯🇵'),
    Country(name: 'China', code: 'CN', dialCode: '+86', flagEmoji: '🇨🇳'),
    Country(name: 'Singapore', code: 'SG', dialCode: '+65', flagEmoji: '🇸🇬'),
    Country(name: 'UAE', code: 'AE', dialCode: '+971', flagEmoji: '🇦🇪'),
    Country(name: 'Saudi Arabia', code: 'SA', dialCode: '+966', flagEmoji: '🇸🇦'),
    Country(name: 'Brazil', code: 'BR', dialCode: '+55', flagEmoji: '🇧🇷'),
    Country(name: 'Russia', code: 'RU', dialCode: '+7', flagEmoji: '🇷🇺'),
    Country(name: 'South Korea', code: 'KR', dialCode: '+82', flagEmoji: '🇰🇷'),
    Country(name: 'Italy', code: 'IT', dialCode: '+39', flagEmoji: '🇮🇹'),
    Country(name: 'Spain', code: 'ES', dialCode: '+34', flagEmoji: '🇪🇸'),
    Country(name: 'Netherlands', code: 'NL', dialCode: '+31', flagEmoji: '🇳🇱'),
    Country(name: 'Sweden', code: 'SE', dialCode: '+46', flagEmoji: '🇸🇪'),
    Country(name: 'Switzerland', code: 'CH', dialCode: '+41', flagEmoji: '🇨🇭'),
    Country(name: 'Belgium', code: 'BE', dialCode: '+32', flagEmoji: '🇧🇪'),
    Country(name: 'Austria', code: 'AT', dialCode: '+43', flagEmoji: '🇦🇹'),
    Country(name: 'Norway', code: 'NO', dialCode: '+47', flagEmoji: '🇳🇴'),
    Country(name: 'Denmark', code: 'DK', dialCode: '+45', flagEmoji: '🇩🇰'),
    Country(name: 'Poland', code: 'PL', dialCode: '+48', flagEmoji: '🇵🇱'),
    Country(name: 'Portugal', code: 'PT', dialCode: '+351', flagEmoji: '🇵🇹'),
    Country(name: 'Greece', code: 'GR', dialCode: '+30', flagEmoji: '🇬🇷'),
    Country(name: 'Turkey', code: 'TR', dialCode: '+90', flagEmoji: '🇹🇷'),
    Country(name: 'Israel', code: 'IL', dialCode: '+972', flagEmoji: '🇮🇱'),
    Country(name: 'South Africa', code: 'ZA', dialCode: '+27', flagEmoji: '🇿🇦'),
    Country(name: 'Mexico', code: 'MX', dialCode: '+52', flagEmoji: '🇲🇽'),
    Country(name: 'Argentina', code: 'AR', dialCode: '+54', flagEmoji: '🇦🇷'),
    Country(name: 'Chile', code: 'CL', dialCode: '+56', flagEmoji: '🇨🇱'),
    Country(name: 'New Zealand', code: 'NZ', dialCode: '+64', flagEmoji: '🇳🇿'),
    Country(name: 'Thailand', code: 'TH', dialCode: '+66', flagEmoji: '🇹🇭'),
    Country(name: 'Malaysia', code: 'MY', dialCode: '+60', flagEmoji: '🇲🇾'),
    Country(name: 'Indonesia', code: 'ID', dialCode: '+62', flagEmoji: '🇮🇩'),
    Country(name: 'Philippines', code: 'PH', dialCode: '+63', flagEmoji: '🇵🇭'),
    Country(name: 'Vietnam', code: 'VN', dialCode: '+84', flagEmoji: '🇻🇳'),
    Country(name: 'Bangladesh', code: 'BD', dialCode: '+880', flagEmoji: '🇧🇩'),
    Country(name: 'Pakistan', code: 'PK', dialCode: '+92', flagEmoji: '🇵🇰'),
    Country(name: 'Sri Lanka', code: 'LK', dialCode: '+94', flagEmoji: '🇱🇰'),
    Country(name: 'Nepal', code: 'NP', dialCode: '+977', flagEmoji: '🇳🇵'),
    Country(name: 'Qatar', code: 'QA', dialCode: '+974', flagEmoji: '🇶🇦'),
    Country(name: 'Kuwait', code: 'KW', dialCode: '+965', flagEmoji: '🇰🇼'),
    Country(name: 'Oman', code: 'OM', dialCode: '+968', flagEmoji: '🇴🇲'),
    Country(name: 'Bahrain', code: 'BH', dialCode: '+973', flagEmoji: '🇧🇭'),
  ];
}
