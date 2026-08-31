import 'package:flutter/material.dart';

class PageOut extends StatelessWidget {
  const PageOut({Key? key}) : super(key: key);

  static const routeName = '/pageOut';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Out'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.exit_to_app, size: 72.0),
            const SizedBox(height: 16),
            const Text(
              'Questa è la nuova pagina PageOut.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Torna indietro'),
            ),
          ],
        ),
      ),
    );
  }
}
