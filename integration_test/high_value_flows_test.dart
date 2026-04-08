import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile/l10n/app_locale.dart';
import 'package:mobile/models/otp_models.dart';
import 'package:mobile/screens/leads_screen.dart';
import 'package:mobile/screens/signup_screen.dart';
import 'package:mobile/screens/wallet_screen.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/widgets/animated_error_banner.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeApiService implements ApiServiceBase {
  _FakeApiService({
    required this.leads,
    required this.wallet,
  });

  final List<Map<String, dynamic>> leads;
  final Map<String, dynamic> wallet;
  final String userId = 'user-1';

  String? upi;
  String? bankName;
  String? ifscCode;

  @override
  Future<Map<String, dynamic>?> getUserByMobile(String mobile) async {
    if (mobile.isEmpty) return null;
    return {'id': userId, 'mobile_number': mobile, 'user_name': 'Test User'};
  }

  @override
  Future<List<Map<String, dynamic>>> getLeadsByUserId(String userId) async => leads;

  @override
  Future<Map<String, dynamic>?> getWallet(String userId) async => wallet;

  @override
  Future<List<Map<String, dynamic>>> getPaymentAccounts(String userId) async {
    final list = <Map<String, dynamic>>[];
    if (upi != null && upi!.isNotEmpty) {
      list.add({'payment_type': 'upi', 'upi_id': upi});
    }
    if (bankName != null && bankName!.isNotEmpty) {
      list.add({
        'payment_type': 'bank',
        'bank_name': bankName,
        'ifsc_code': ifscCode ?? '',
      });
    }
    return list;
  }

  @override
  Future<bool> savePaymentAccount(
    String userId, {
    required String paymentType,
    String? upiId,
    String? bankName,
    String? ifscCode,
  }) async {
    if (paymentType == 'upi') {
      upi = upiId;
      return true;
    }
    if (paymentType == 'bank') {
      this.bankName = bankName;
      this.ifscCode = ifscCode;
      return true;
    }
    return false;
  }

  @override
  Future<Map<String, dynamic>?> createUser({
    required String mobileNumber,
    String? userName,
    String? email,
  }) async => {'id': userId};

  @override
  Future<CreateLeadResult> createLead({
    required String pan,
    required String mobileNumber,
    required String fullName,
    String? email,
    String? pincode,
    double? requiredAmount,
    required String category,
    String? userId,
  }) async => const CreateLeadResult(success: true);

  @override
  Future<bool> getLiveFlag() async => false;

  @override
  Future<OTPResponse> sendOTP(String mobileNumber) async =>
      OTPResponse(success: true);

  @override
  Future<OTPVerificationResponse> verifyOTP(String mobileNumber, String otp) async =>
      OTPVerificationResponse(success: true);

  @override
  Future<bool> updateUserLoginStatus(String mobile, bool isLoggedIn) async => true;

  @override
  Future<bool> updateUserMPin(String mobile, String mpin) async => true;

  @override
  Future<bool> updateUserProfile(String mobile, {String? userName, String? email}) async => true;

  @override
  Future<bool> upsertUser({
    required String mobileNumber,
    String? userName,
    String? email,
    String? mpin,
    bool? isLoggedIn,
  }) async => true;
}

Widget _wrapWithLocale(Widget child) {
  return ChangeNotifierProvider<AppLocale>(
    create: (_) => AppLocale(),
    child: Builder(
      builder: (context) => MaterialApp(
        locale: Locale(context.watch<AppLocale>().locale),
        home: child,
      ),
    ),
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'mobile_number': '9876543210',
    });
  });

  testWidgets('signup validation shows error banner for invalid mobile', (
    tester,
  ) async {
    await tester.pumpWidget(_wrapWithLocale(const SignUpScreen()));
    await tester.enterText(find.byType(TextFormField).first, '12345');
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.byType(AnimatedErrorBanner), findsOneWidget);
  });

  testWidgets('leads flow loads and list renders from stub api', (tester) async {
    final api = _FakeApiService(
      wallet: {'balance': 1500},
      leads: const [
        {'full_name': 'Aman', 'mobile_number': '9999999999', 'status': 'approved'},
        {'full_name': 'Riya', 'mobile_number': '8888888888', 'status': 'pending'},
        {'full_name': 'Karan', 'mobile_number': '7777777777', 'status': 'rejected'},
      ],
    );

    await tester.pumpWidget(
      _wrapWithLocale(LeadsContent(userName: 'Tester', api: api)),
    );
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('View Details').first);
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Aman'), findsOneWidget);
    expect(find.text('Riya'), findsOneWidget);
    expect(find.text('Karan'), findsOneWidget);
  });

  testWidgets('wallet payment method save works with stub api', (tester) async {
    final api = _FakeApiService(
      wallet: {'balance': 2000},
      leads: const [],
    );

    await tester.pumpWidget(
      _wrapWithLocale(WalletScreen(userName: 'Tester', api: api)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('UPI').first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'test@ybl');
    await tester.tap(find.text('Save UPI ID'));
    await tester.pump(const Duration(seconds: 1));

    expect(api.upi, equals('test@ybl'));
    expect(find.text('Added'), findsOneWidget);
  });
}
