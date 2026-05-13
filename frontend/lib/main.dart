import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_export.dart';
import '../widgets/custom_error_widget.dart';

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

  // 3. Configuração de Erros Customizados (Seção Crítica)
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

  // 4. Bloqueio de Orientação e Execução do App
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
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
        );
      },
    );
  }
}
