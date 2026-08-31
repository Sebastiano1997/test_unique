import 'package:flutter/material.dart';
import 'pages/PageOut.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo: Selettore Pagine',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainShell(),
    );
  }
}

/// Descrive una "pagina componente" isolata che può essere selezionata
class PageDescriptor {
  final String title;
  final IconData icon;
  final Widget page;

  const PageDescriptor({required this.title, required this.icon, required this.page});
}

class MainShell extends StatefulWidget {
  const MainShell({Key? key}) : super(key: key);

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  // Registra qui tutte le pagine/componenti isolate che vuoi poter selezionare
  final List<PageDescriptor> _pages = const [
    PageDescriptor(
      title: 'Home',
      icon: Icons.home,
      page: _HomePlaceholder(),
    ),
    PageDescriptor(
      title: 'Page Out',
      icon: Icons.exit_to_app,
      page: PageOut(),
    ),
    // Aggiungi altre PageDescriptor qui per nuovi componenti
  ];

  void _selectPage(int index) {
    setState(() => _selectedIndex = index);
    Navigator.of(context).pop(); // chiude la drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pages[_selectedIndex].title),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Theme.of(context).primaryColorLight),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Selettore Pagine', style: TextStyle(fontSize: 24)),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final p = _pages[index];
                    return ListTile(
                      leading: Icon(p.icon),
                      title: Text(p.title),
                      selected: index == _selectedIndex,
                      onTap: () => _selectPage(index),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // IndexedStack mantiene lo stato interno di ogni pagina mentre si cambia selezione
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages.map((p) => p.page).toList(),
      ),
    );
  }
}

// Un semplice widget placeholder per la "Home"; sostituisci con componenti reali
class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.widgets, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Benvenuto!\nSeleziona una pagina dalla tendina a sinistra per visualizzare componenti isolati.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
