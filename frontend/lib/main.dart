import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_export.dart';
import '../widgets/custom_error_widget.dart';
import 'providers/cart_provider.dart';

// Atalho global para o cliente Supabase
final supabase = Supabase.instance.client;

void main() async {
  // 1. Garante os bindings do Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializa o Supabase (Substitua pelas suas chaves reais)
  try {
    await Supabase.initialize(
      url: 'https://ydexusniluxlmcfpirmt.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlkZXh1c25pbHV4bG1jZnBpcm10Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwOTA2NzQsImV4cCI6MjA5MTY2NjY3NH0.NCaQ1Qi9TBOJOCo5xraygQD1Spq5F-JPv3D8oMFyyYg',
    );
    debugPrint('Supabase inicializado com sucesso!');
  } catch (e) {
    debugPrint('Erro ao inicializar Supabase: $e');
  }

  // 3. Inicializa o CarrinhoProvider e carrega dados persistidos
  final cartProvider = CartProvider();
  await cartProvider.loadFromStorage();

  // 4. Configuração de Erros Customizados (Seção Crítica)
  bool hasShownError = false;
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (!hasShownError) {
      hasShownError = true;
      Future.delayed(const Duration(seconds: 5), () {
        hasShownError = false;
      });
      return CustomErrorWidget(errorDetails: details);
    }
    return const SizedBox.shrink();
  };

  // 5. Bloqueio de Orientação e Execução do App
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(
      ChangeNotifierProvider<CartProvider>.value(
        value: cartProvider,
        child: const MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtain the CartProvider from the root-level provider (set in main())
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Sizer(
      builder: (context, orientation, screenType) {
        return ChangeNotifierProvider<CartProvider>.value(
          value: cartProvider,
          child: MaterialApp(
            title: 'agrilink',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            // Seção Crítica de Media Query
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.0),
                ),
                child: child!,
              );
            },
            debugShowCheckedModeBanner: false,
            routes: AppRoutes.routes,
            initialRoute: AppRoutes.initial,
          ),
        );
      },
    );
  }
}
