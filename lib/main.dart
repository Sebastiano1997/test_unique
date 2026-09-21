import 'package:flutter/material.dart';
import 'pages/PageOut/ui/PageOutPage.dart';
import 'pages/CalendarApp/ui/CalendarApp.dart';
import 'pages/ReorderableListPage/ui/ReorderableListPage.dart';
import 'pages/LineNumberedTextField/ui/LineNumberedTextField.dart';
import 'pages/HistoryObj/ui/HistoryObj.dart';
import 'pages/EGI_DartPad/ui/EGI_DartPad.dart';
import 'pages/Scrapping/ui/Scrapping.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo: Selettore Pagine - Riorganizzato',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainShell(),
    );
  }
}

class PageDescriptor {
  const PageDescriptor({required this.title, required this.icon, required this.page});
  final String title;
  final IconData icon;
  final Widget page;
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final List<PageDescriptor> _pages = const [
    PageDescriptor(title: 'PageOutPage', icon: Icons.other_houses_outlined, page: PageOutPage()),
    PageDescriptor(title: 'Home', icon: Icons.home, page: _HomePlaceholder()),
    PageDescriptor(title: 'Page Out', icon: Icons.view_list, page: PageOutPage()),
    //PageDescriptor(title: 'AlarmManagerExampleApp', icon: Icons.alarm, page: AlarmManagerExampleApp()),
    PageDescriptor(title: 'CalendarApp', icon: Icons.calendar_today, page: CalendarApp()),
    PageDescriptor(title: 'LineNumberedTextField', icon: Icons.format_list_numbered, page: LineNumberedTextField2()),
    PageDescriptor(title: 'ReorderableListPage', icon: Icons.swap_vert, page: ReorderableListPage()),
    PageDescriptor(title: 'HistoryObj', icon: Icons.history, page: HistoryObjPage()),
    PageDescriptor(title: 'EGI DartPad', icon: Icons.code, page: EgiDartPad()),
    PageDescriptor(title: 'Scrapping', icon: Icons.web, page: ScrappingPage()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_pages[_selectedIndex].title)),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              const DrawerHeader(
                child: Text('Selettore Pagine', style: TextStyle(fontSize: 24)),
              ),
              ..._pages.asMap().entries.map(
                    (entry) => ListTile(
                      leading: Icon(entry.value.icon),
                      title: Text(entry.value.title),
                      selected: entry.key == _selectedIndex,
                      onTap: () {
                        setState(() => _selectedIndex = entry.key);
                        Navigator.pop(context);
                      },
                    ),
                  ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages.map((page) => page.page).toList(),
      ),
    );
  }
}

class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Benvenuto! Seleziona una pagina dalla tendina a sinistra.'),
    );
  }
}

class HistoryObjPage extends StatelessWidget {
  const HistoryObjPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('HistoryObj è una classe di utilità.')),
    );
  }
}
