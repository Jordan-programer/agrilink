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
      final args =
      ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
  return ProductDetailOrderScreen(productArgs: args);
    },
  };
}

