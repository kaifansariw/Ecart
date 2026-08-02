import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/signup_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/products/presentation/screens/product_list_screen.dart';
import '../features/products/presentation/screens/product_detail_screen.dart';
import '../features/cart/presentation/screens/cart_screen.dart';
import '../features/checkout/presentation/screens/checkout_screen.dart';
import '../features/checkout/presentation/screens/order_success_screen.dart';
import '../features/wishlist/presentation/screens/wishlist_screen.dart';
import '../features/orders/presentation/screens/order_history_screen.dart';
import '../features/orders/presentation/screens/order_detail_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/profile/presentation/screens/address_book_screen.dart';
import '../features/search/presentation/screens/search_screen.dart';
import '../shell_screen.dart';
import '../services/supabase_service.dart';

/// Application route configuration.
class AppRoutes {
  AppRoutes._();

  // Route names
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/';
  static const String products = '/products';
  static const String productDetail = '/products/:id';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderSuccess = '/order-success';
  static const String wishlist = '/wishlist';
  static const String orders = '/orders';
  static const String orderDetail = '/orders/:id';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String addressBook = '/profile/addresses';
  static const String search = '/search';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    redirect: (context, state) {
      final isAuth = SupabaseService.isAuthenticated;
      final isAuthRoute = state.matchedLocation == login ||
          state.matchedLocation == signup ||
          state.matchedLocation == forgotPassword;

      // If not authenticated and not on an auth route, redirect to login
      if (!isAuth && !isAuthRoute) {
        return login;
      }
      // If authenticated and on an auth route, redirect to home
      if (isAuth && isAuthRoute) {
        return home;
      }
      return null;
    },
    routes: [
      // ── Auth Routes ──
      GoRoute(
        path: login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // ── Shell Route (main app with bottom nav) ──
      ShellRoute(
        builder: (context, state, child) => ShellScreen(child: child),
        routes: [
          GoRoute(
            path: home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: search,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SearchScreen(),
            ),
          ),
          GoRoute(
            path: cart,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CartScreen(),
            ),
          ),
          GoRoute(
            path: wishlist,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: WishlistScreen(),
            ),
          ),
          GoRoute(
            path: profile,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),

      // ── Detail Routes (push on top of shell) ──
      GoRoute(
        path: products,
        builder: (context, state) {
          final category = state.uri.queryParameters['category'];
          return ProductListScreen(categoryId: category);
        },
      ),
      GoRoute(
        path: productDetail,
        builder: (context, state) => ProductDetailScreen(
          productId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: checkout,
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: orderSuccess,
        builder: (context, state) {
          final orderId = state.uri.queryParameters['orderId'] ?? '';
          return OrderSuccessScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: orders,
        builder: (context, state) => const OrderHistoryScreen(),
      ),
      GoRoute(
        path: orderDetail,
        builder: (context, state) => OrderDetailScreen(
          orderId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: addressBook,
        builder: (context, state) => const AddressBookScreen(),
      ),
    ],
  );
}
