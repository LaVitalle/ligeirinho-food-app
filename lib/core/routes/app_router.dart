import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/verify_code_screen.dart';
import '../../features/auth/new_password_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/client/client_shell.dart';
import '../../features/client/home/home_screen.dart';
import '../../features/client/stores/stores_screen.dart';
import '../../features/client/store_menu/store_menu_screen.dart';
import '../../features/client/product_detail/product_detail_screen.dart';
import '../../features/client/cart/cart_screen.dart';
import '../../features/client/checkout/checkout_screen.dart';
import '../../features/client/orders/orders_screen.dart';
import '../../features/client/profile/client_profile_screen.dart';
import '../../features/vendor/vendor_shell.dart';
import '../../features/vendor/orders_panel/orders_panel_screen.dart';
import '../../features/vendor/products/products_screen.dart';
import '../../features/vendor/products/create_product_screen.dart';
import '../../features/vendor/additionals/additionals_screen.dart';
import '../../features/vendor/additionals/create_additional_screen.dart';
import '../../features/vendor/reports/reports_screen.dart';
import '../../features/vendor/profile/vendor_profile_screen.dart';
import '../../data/models/product_model.dart';
import '../../data/models/store_model.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _clientShellKey = GlobalKey<NavigatorState>();
final _vendorShellKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: '/verify-code', builder: (_, __) => const VerifyCodeScreen()),
      GoRoute(path: '/new-password', builder: (_, __) => const NewPasswordScreen()),

      // Client shell with bottom nav
      ShellRoute(
        navigatorKey: _clientShellKey,
        builder: (context, state, child) => ClientShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/stores', builder: (_, __) => const StoresScreen()),
          GoRoute(path: '/orders', builder: (_, __) => const OrdersScreen()),
        ],
      ),

      // Client screens outside shell (full page)
      GoRoute(
        path: '/store/:storeId',
        builder: (context, state) {
          final store = state.extra as StoreModel;
          return StoreMenuScreen(store: store);
        },
      ),
      GoRoute(
        path: '/product/:productId',
        builder: (context, state) {
          final product = state.extra as ProductModel;
          return ProductDetailScreen(product: product);
        },
      ),
      GoRoute(path: '/cart', builder: (_, __) => const CartScreen()),
      GoRoute(path: '/checkout', builder: (_, __) => const CheckoutScreen()),
      GoRoute(
        path: '/client-profile',
        builder: (_, __) => const ClientProfileScreen(),
      ),

      // Vendor shell
      ShellRoute(
        navigatorKey: _vendorShellKey,
        builder: (context, state, child) => VendorShell(child: child),
        routes: [
          GoRoute(path: '/vendor/orders', builder: (_, __) => const OrdersPanelScreen()),
          GoRoute(path: '/vendor/products', builder: (_, __) => const ProductsScreen()),
          GoRoute(path: '/vendor/reports', builder: (_, __) => const ReportsScreen()),
        ],
      ),

      GoRoute(path: '/vendor/create-product', builder: (_, __) => const CreateProductScreen()),
      GoRoute(path: '/vendor/additionals', builder: (_, __) => const AdditionalsScreen()),
      GoRoute(path: '/vendor/create-additional', builder: (_, __) => const CreateAdditionalScreen()),
      GoRoute(path: '/vendor/profile', builder: (_, __) => const VendorProfileScreen()),
    ],
  );
});
