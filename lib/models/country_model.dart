/// India only - default country for the app. No picker, no other countries.
class Country {
  final String name;
  final String code;
  final String dialCode;
  final String flagEmoji;

  const Country({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flagEmoji,
  });

  static const Country india = Country(
    name: 'India',
    code: 'IN',
    dialCode: '+91',
    flagEmoji: '🇮🇳',
  );
}
