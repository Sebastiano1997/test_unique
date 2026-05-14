//----------------------------------------------------

/*


// parte da un colore (nel seedColor) e da esso definisce colore primario, secondario, ecc. in modo armonico

// _seedColor: colore seme

// _brightness: per il Dark Mode o no

Color _seedColor = Colors.deepPurple;

Brightness _brightness = Brightness.light;



ThemeData get currentTheme => ThemeData(

  colorScheme: ColorScheme.fromSeed(seedColor: _seedColor, brightness: _brightness),

  useMaterial3: true,

);







// ---------------------------------------------------



Widget build(BuildContext context) {

  return MaterialApp(

    debugShowCheckedModeBanner: false,

    title: 'Styled App Example', // A more appropriate title

    theme: _buildAppTheme(), // Apply the centralized theme

    home: const HomePage(),

  );

}



/// Builds the centralized ThemeData for the application.

/// This function encapsulates all styling definitions, making them easily

/// maintainable and accessible throughout the app.

ThemeData _buildAppTheme() {

  // Define a primary color scheme for the app.

  // ColorScheme.fromSeed creates a harmonized set of colors based on a single seed color.

  final ColorScheme colorScheme = ColorScheme.fromSeed(

    seedColor: Colors.deepPurple, // Main brand color

    brightness: Brightness.light,

  );



  return ThemeData(

    colorScheme: colorScheme,

    useMaterial3: true, // Enable Material 3 features



    // Define global AppBar styling

    appBarTheme: AppBarTheme(

      backgroundColor: colorScheme.primary,

      foregroundColor: colorScheme.onPrimary, // Text and icon color on primary background

      elevation: 4.0, // Shadow beneath the AppBar

      centerTitle: true,

      titleTextStyle: TextStyle(

        color: colorScheme.onPrimary,

        fontSize: 20.0,

        fontWeight: FontWeight.bold,

      ),

    ),



    // Define global text styling using TextTheme.

    // This allows consistent typography across the application.

    textTheme: TextTheme(

      displayLarge: TextStyle(

          fontSize: 57,

          fontWeight: FontWeight.w400,

          color: colorScheme.onSurface),

      headlineLarge: TextStyle(

          fontSize: 32,

          fontWeight: FontWeight.w700,

          color: colorScheme.primary),

      bodyLarge: TextStyle(

          fontSize: 16,

          fontWeight: FontWeight.w400,

          color: colorScheme.onSurfaceVariant),

      bodyMedium: TextStyle(

          fontSize: 14,

          fontWeight: FontWeight.w400,

          color: colorScheme.onSurface),

      labelLarge: TextStyle(

          fontSize: 14,

          fontWeight: FontWeight.w500,

          color: colorScheme.onPrimary),

    ),



    // Define global styling for ElevatedButtons

    elevatedButtonTheme: ElevatedButtonThemeData(

      style: ElevatedButton.styleFrom(

        backgroundColor: colorScheme.secondary,

        foregroundColor: colorScheme.onSecondary,

        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),

        shape: RoundedRectangleBorder(

          borderRadius: BorderRadius.circular(8.0),

        ),

        textStyle: TextStyle(

          fontSize: 16,

          fontWeight: FontWeight.bold,

          color: colorScheme.onSecondary,

        ),

      ),

    ),



    // Define global styling for Card widgets

    cardTheme: CardThemeData(

      color: colorScheme.surfaceVariant,

      elevation: 2.0,

      shape: RoundedRectangleBorder(

        borderRadius: BorderRadius.circular(12.0),

      ),

    ),

  );

}




*/


// -----------------------------------



import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {

  const HomePage({super.key});



  @override
  Widget build(BuildContext context) {

    // Access the theme data defined in MyApp

    final ThemeData theme = Theme.of(context);

    final ColorScheme colorScheme = theme.colorScheme;

    final TextTheme textTheme = theme.textTheme;

    return Container();

  }



}




