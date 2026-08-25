import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home.dart';

void main() => runApp(const TienCuaTuiApp());

class TienCuaTuiApp extends StatelessWidget {
  const TienCuaTuiApp({super.key});

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFE0C47A);
    const bg = Color(0xFF12171D);
    const surface = Color(0xFF1D242C);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tiền của tui',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: bg,
        fontFamily: 'Roboto',
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: const Color(0xFFE8EDF2),
          displayColor: const Color(0xFFF4F7FA),
        ),
        colorScheme: const ColorScheme.dark(
          primary: gold,
          secondary: gold,
          surface: surface,
        ),
        
        appBarTheme: const AppBarTheme(
          backgroundColor: bg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w600,
            color: Color(0xFFF4F7FA),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: gold,
          foregroundColor: Color(0xFF111318),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          labelStyle: const TextStyle(color: Color(0xFFAEB8C3), fontWeight: FontWeight.w400),
          hintStyle: const TextStyle(color: Color(0xFF7E8995), fontWeight: FontWeight.w400),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF39424D)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: gold, width: 1.3),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('vi', 'VN')],
      home: const HomeScreen(),
    );
  }
}
