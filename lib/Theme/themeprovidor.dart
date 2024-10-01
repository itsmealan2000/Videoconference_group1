import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart'; // Import the file where your themes are defined

class ThemeProvider extends ChangeNotifier {
  ThemeData _selectedTheme;

  ThemeProvider({required ThemeData initialTheme}) : _selectedTheme = initialTheme;

  ThemeData get getTheme => _selectedTheme;

  void setTheme(ThemeData theme) {
    _selectedTheme = theme;
    notifyListeners();
  }
}

class Themeprovidor extends StatelessWidget {
  const Themeprovidor({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the ThemeProvider from the ChangeNotifierProvider
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Theme'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Light Theme'),
            onTap: () {
              themeProvider.setTheme(lightTheme); // Set light theme
            },
          ),
          ListTile(
            title: const Text('Dark Theme'),
            onTap: () {
              themeProvider.setTheme(darkTheme); // Set dark theme
            },
          ),
          ListTile(
            title: const Text('AMOLED Theme'),
            onTap: () {
              themeProvider.setTheme(amoledTheme); // Set AMOLED theme
            },
          ),
        ],
      ),
    );
  }
}
