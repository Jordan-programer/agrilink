import 'package:flutter/material.dart';

import '../presentation/home_marketplace_screen/home_marketplace_screen.dart';
import '../presentation/product_detail_order_screen/product_detail_order_screen.dart';
import '../presentation/sign_up_login_screen/sign_up_login_screen.dart';
import '../presentation/publish_product_screen/publish_product_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String signUpLoginScreen = '/sign-up-login-screen';
  static const String homeMarketplaceScreen = '/home-marketplace-screen';
  static const String productDetailOrderScreen = '/product-detail-order-screen';
  static const String publishProductScreen = '/publish-product-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SignUpLoginScreen(),
    signUpLoginScreen: (context) => const SignUpLoginScreen(),
    homeMarketplaceScreen: (context) => const HomeMarketplaceScreen(),
    publishProductScreen: (context) => const PublishProductScreen(),
    productDetailOrderScreen: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      Map<String, dynamic>? productMap;
      if (args != null) {
        // Handle both Map and ProductModel to avoid TypeErrors
        try {
          if (args is Map<String, dynamic>) {
            productMap = args;
          } else {
            final json = (args as dynamic).toJson() as Map<String, dynamic>;
            json['quantityKg'] = (json['quantity'] as num?)?.toDouble() ?? 0.0;
            json['farmerRating'] = (json['rating'] as num?)?.toDouble() ?? 4.5;
            json['harvestDate'] ??= '2026-04-08';
            json['status'] ??= 'available';
            productMap = json;
          }
        } catch (_) {}
      }
      return ProductDetailOrderScreen(productArgs: productMap);
    },
  };
}

