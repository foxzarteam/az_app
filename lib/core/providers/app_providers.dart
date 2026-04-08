import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../features/auth/auth_controller.dart';
import '../../features/home/banner_controller.dart';
import '../../features/leads/lead_controller.dart';
import '../../features/profile/user_controller.dart';
import '../../features/wallet/wallet_controller.dart';
import '../../services/api_client.dart';
import '../../services/api_service.dart';
import '../../services/banner_service.dart';
import '../../services/lead_service.dart';
import '../../services/otp_service.dart';
import '../../services/payment_service.dart';
import '../../services/splash_flow_service.dart';
import '../../services/user_service.dart';
import '../../services/wallet_service.dart';
import '../l10n/app_locale.dart';

List<SingleChildWidget> createAppProviders([ApiClient? api]) {
  final client = api ?? ApiService.instance;
  final userService = UserService(client);
  final walletService = WalletService(client);
  return [
    Provider<ApiClient>.value(value: client),
    Provider<UserService>.value(value: userService),
    Provider<OtpService>.value(value: OtpService(client)),
    Provider<LeadService>.value(value: LeadService(client)),
    Provider<WalletService>.value(value: walletService),
    Provider<PaymentService>.value(
      value: PaymentService(client, walletService),
    ),
    Provider<BannerService>.value(value: BannerService(client)),
    Provider<SplashFlowService>.value(
      value: SplashFlowService(users: userService),
    ),
    ChangeNotifierProvider<AppLocale>(create: (_) => AppLocale()),
    ChangeNotifierProvider<AuthController>(
      create: (ctx) => AuthController(
        users: ctx.read<UserService>(),
        otp: ctx.read<OtpService>(),
        splashFlow: ctx.read<SplashFlowService>(),
      ),
    ),
    ChangeNotifierProvider<UserController>(
      create: (ctx) => UserController(users: ctx.read<UserService>()),
    ),
    ChangeNotifierProvider<LeadController>(
      create: (ctx) => LeadController(
        users: ctx.read<UserService>(),
        leads: ctx.read<LeadService>(),
      ),
    ),
    ChangeNotifierProvider<WalletController>(
      create: (ctx) => WalletController(
        users: ctx.read<UserService>(),
        wallet: ctx.read<WalletService>(),
        payments: ctx.read<PaymentService>(),
      ),
    ),
    ChangeNotifierProvider<BannerController>(
      create: (ctx) => BannerController(banners: ctx.read<BannerService>()),
    ),
  ];
}
