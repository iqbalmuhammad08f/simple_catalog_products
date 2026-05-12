import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'controllers/auth_controller.dart';
import 'controllers/product_controller.dart';
import 'views/login_page.dart';
import 'package:device_preview/device_preview.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    DevicePreview(
      enabled: true, // ubah jadi false saat production
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthController()),
          ChangeNotifierProvider(create: (_) => ProductController()),
        ],
        child: const PbmApp(),
      ),
    ),
  );
}

class PbmApp extends StatelessWidget {
  const PbmApp({super.key});

  // ─── Color Palette ───────────────────────────────────────────────────────
  static const _bg = Color(0xFF0C0C0C);
  static const _green = Color(0xFF00FF41);
  static const _surface = Color(0xFF111111);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,

      title: 'PBM Task Manager',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: _green,
          surface: _surface,
          background: _bg,
          onPrimary: Colors.black,
          onSurface: Color(0xFFCCCCCC),
        ),

        scaffoldBackgroundColor: _bg,

        textTheme: GoogleFonts.robotoMonoTextTheme(
          ThemeData.dark().textTheme,
        ),

        appBarTheme: AppBarTheme(
          backgroundColor: _surface,
          foregroundColor: _green,
          titleTextStyle: GoogleFonts.robotoMono(
            color: _green,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          elevation: 0,
        ),

        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF111111),
        ),
      ),

      home: const LoginPage(),
    );
  }
}