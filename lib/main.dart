import 'package:flutter/material.dart';

import 'pages/PageOut/ui/PageOut.dart';
import 'pages/AlarmManagerExampleApp/ui/AlarmManagerExampleApp.dart';
import 'pages/CalendarApp/ui/CalendarApp.dart';
import 'pages/ReorderableListPage/ui/ReorderableListPage.dart';
import 'pages/LineNumberedTextField/ui/LineNumberedTextField.dart';
import 'pages/HistoryObj/ui/HistoryObj.dart';
import 'pages/EGI_DartPad/ui/EGI_DartPad.dart';
import 'pages/Scrapping/ui/Scrapping.dart';
import 'pages/testUl/ui/testUl.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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

  final List<PageDescriptor> _pages = [
    const PageDescriptor(title: 'Home', icon: Icons.home, page: _HomePlaceholder()),
    const PageDescriptor(title: 'Page Out', icon: Icons.exit_to_app, page: PageOut()),
    const PageDescriptor(title: 'AlarmManagerExampleApp', icon: Icons.alarm, page: AlarmManagerExampleApp()),
    const PageDescriptor(title: 'CalendarApp', icon: Icons.calendar_today, page: CalendarApp()),
    const PageDescriptor(title: 'LineNumberedTextField', icon: Icons.format_list_numbered, page: LineNumberedTextField2()),
    const PageDescriptor(title: 'ReorderableListPage', icon: Icons.swap_vert, page: ReorderableListPage()),
    const PageDescriptor(title: 'HistoryObj', icon: Icons.history, page: HistoryObjPage()),
    const PageDescriptor(title: 'EGI DartPad', icon: Icons.code, page: EgiDartPad()),
    const PageDescriptor(title: 'Scrapping', icon: Icons.web, page: ScrappingPage()),
    const PageDescriptor(title: 'testUl', icon: Icons.bug_report, page: TestUlPage()),
  ];

  void _selectPage(int index) {
    setState(() => _selectedIndex = index);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_pages[_selectedIndex].title)),
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
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages.map((p) => p.page).toList(),
      ),
    );
  }
}

class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Text('Benvenuto! Seleziona una pagina dalla tendina a sinistra.'),
      ),
    );
  }
}

class HistoryObjPage extends StatelessWidget {
  const HistoryObjPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HistoryObj')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('HistoryObj è una classe di utilità. Qui puoi aggiungere una UI che la usa.'),
      ),
    );
  }
}
