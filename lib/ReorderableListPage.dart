import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'main.dart'; // Per generare ID unici per gli elementi

// Inizializza un generatore di UUID per avere ID unici
const uuid = Uuid();

void main() {
  runApp(
      StartWidget(
          child: MyAppReorderableListPage()
      )
  );
}

class StartWidget  extends StatelessWidget{
  StartWidget({super.key, required this.child});
  Widget child;
  @override
  Widget build(BuildContext context) {
   return MaterialApp(home: Scaffold(body: child,),);
  }
}

class MyAppReorderableListPage extends StatelessWidget {
  const MyAppReorderableListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Riorganizza la Lista',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ReorderableListPage(),
    );
  }
}

// Definiamo una classe per i nostri elementi della lista,
// includendo un ID unico per una gestione robusta del riordino.
class ListItem {
  final String id;
  String text;

  ListItem({required this.id, required this.text});
}

class ReorderableListPage extends StatefulWidget {
  const ReorderableListPage({super.key});

  @override
  State<ReorderableListPage> createState() => _ReorderableListPageState2();
}

class _ReorderableListPageState extends State<ReorderableListPage> {
  // La nostra lista di elementi iniziali.
  // Ogni elemento ha un ID unico e un testo.
  List<ListItem> _items = [
    ListItem(id: uuid.v4(), text: 'Elemento A'),
    ListItem(id: uuid.v4(), text: 'Elemento B'),
    ListItem(id: uuid.v4(), text: 'Elemento C'),
    ListItem(id: uuid.v4(), text: 'Elemento D'),
    ListItem(id: uuid.v4(), text: 'Elemento E'),
    ListItem(id: uuid.v4(), text: 'Elemento F'),
    ListItem(id: uuid.v4(), text: 'Elemento G'),
  ];

  // Callback chiamato quando un elemento viene riordinato.
  void _onReorder(int oldIndex, int newIndex) {
    // Dichiara la variabile 'item' prima del blocco setState
    // in modo che sia accessibile anche dopo il suo completamento.
    late ListItem item;

    setState(() {
      // Se l'elemento viene spostato verso il basso,
      // il newIndex deve essere decrementato di 1
      // perché l'elemento a oldIndex è stato rimosso
      // prima che l'inserimento avvenga.
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      // Rimuove l'elemento dalla sua vecchia posizione
      item = _items.removeAt(oldIndex);
      // Inserisce l'elemento nella sua nuova posizione
      _items.insert(newIndex, item);
    });

    // Ora 'item' è accessibile qui per mostrare la SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Elemento "${item.text}" spostato.')),
    );
  }

  // Funzione per aggiungere un nuovo elemento alla lista
  void _addNewItem() {
    setState(() {
      final newItemText = 'Nuovo Elemento ${_items.length + 1}';
      _items.add(ListItem(id: uuid.v4(), text: newItemText));
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nuovo elemento aggiunto!')),
    );
  }

  // Funzione per eliminare un elemento dalla lista
  void _deleteItem(int index) {
    setState(() {
      final removedItem = _items.removeAt(index);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Elemento "${removedItem.text}" rimosso.')),
      );
    });
  }

  // Funzione per modificare un elemento dalla lista
  void _editItem(int index) async {
    final TextEditingController _textController = TextEditingController(text: _items[index].text);
    final bool? shouldUpdate = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Modifica Elemento'),
          content: TextField(
            controller: _textController,
            decoration: const InputDecoration(labelText: 'Testo dell\'elemento'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annulla'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            ElevatedButton(
              child: const Text('Salva'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (shouldUpdate == true && _textController.text.isNotEmpty) {
      setState(() {
        _items[index].text = _textController.text;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Elemento aggiornato a "${_textController.text}"')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riorganizza la Lista'),
      ),
      body: ReorderableListView.builder(
        // Il `key` è FONDAMENTALE per ogni elemento nel ReorderableListView!
        // Deve essere unico e stabile per consentire a Flutter di tracciare correttamente
        // gli elementi durante il riordino. Usiamo l'ID unico del nostro ListItem.
        itemBuilder: (BuildContext context, int index) {
          final item = _items[index];
          return Container(
            key: ValueKey(uuid.v4()),//ValueKey(item.id),
            child: Card(
              //key: ValueKey(item.id), // Usa l'ID unico come chiave
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 3,
              child: ListTile(
                // `leading` è un buon posto per un'icona "drag handle"
                // per indicare visivamente che l'elemento è trascinabile.
                leading: const Icon(Icons.drag_handle, color: Colors.grey),
                title: Text(item.text),
                trailing: Row(                mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editItem(index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteItem(index),
                    ),
                  ],
                ),
                // Puoi anche aggiungere un onTap se vuoi che l'elemento sia cliccabile
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hai toccato: ${item.text}')),
                  );
                },
              ),
            ),
          );
        },
        itemCount: _items.length,
        onReorder: _onReorder, // Associa il nostro callback di riordino
        padding: const EdgeInsets.only(top: 8.0),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewItem, // Aggiungi un nuovo elemento quando il FAB viene premuto
        child: const Icon(Icons.add),
        tooltip: 'Aggiungi nuovo elemento',
      ),
    );
  }
}

class _ReorderableListPageState2 extends State<ReorderableListPage> {
  // La nostra lista di elementi iniziali.
  // Ogni elemento ha un ID unico e un testo.
  List<ListItem> _items = [
    ListItem(id: uuid.v4(), text: 'Elemento A'),
    ListItem(id: uuid.v4(), text: 'Elemento B'),
    ListItem(id: uuid.v4(), text: 'Elemento C'),
    ListItem(id: uuid.v4(), text: 'Elemento D'),
    ListItem(id: uuid.v4(), text: 'Elemento E'),
    ListItem(id: uuid.v4(), text: 'Elemento F'),
    ListItem(id: uuid.v4(), text: 'Elemento G'),
  ];

  // Callback chiamato quando un elemento viene riordinato.
  void _onReorder(int oldIndex, int newIndex) {
    // Dichiara la variabile 'item' prima del blocco setState
    // in modo che sia accessibile anche dopo il suo completamento.
    late ListItem item;

    setState(() {
      // Se l'elemento viene spostato verso il basso,
      // il newIndex deve essere decrementato di 1
      // perché l'elemento a oldIndex è stato rimosso
      // prima che l'inserimento avvenga.
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      // Rimuove l'elemento dalla sua vecchia posizione
      item = _items.removeAt(oldIndex);
      // Inserisce l'elemento nella sua nuova posizione
      _items.insert(newIndex, item);
    });

    // Ora 'item' è accessibile qui per mostrare la SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Elemento "${item.text}" spostato.')),
    );
  }

  // Funzione per eliminare un elemento dalla lista
  void _deleteItem(int index) {
    setState(() {
      final removedItem = _items.removeAt(index);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Elemento "${removedItem.text}" rimosso.')),
      );
    });
  }

  // Funzione per modificare un elemento dalla lista
  void _editItem(int index) async {
    final TextEditingController _textController = TextEditingController(text: _items[index].text);
    final bool? shouldUpdate = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Modifica Elemento'),
          content: TextField(
            controller: _textController,
            decoration: const InputDecoration(labelText: 'Testo dell\'elemento'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annulla'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            ElevatedButton(
              child: const Text('Salva'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (shouldUpdate == true && _textController.text.isNotEmpty) {
      setState(() {
        _items[index].text = _textController.text;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Elemento aggiornato a "${_textController.text}"')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return  ReorderableListView.builder(
        // Il `key` è FONDAMENTALE per ogni elemento nel ReorderableListView!
        // Deve essere unico e stabile per consentire a Flutter di tracciare correttamente
        // gli elementi durante il riordino. Usiamo l'ID unico del nostro ListItem.
        itemBuilder: (BuildContext context, int index) {
          final item = _items[index];
          return Container(
            key:  ValueKey(item.id),
            child: Card(
              //key: ValueKey(item.id), // Usa l'ID unico come chiave
              //margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 3,
              child: ListTile(
                // `leading` è un buon posto per un'icona "drag handle"
                // per indicare visivamente che l'elemento è trascinabile.
                leading: const Icon(Icons.drag_handle, color: Colors.grey),
                title: Text(item.text),
                /*trailing: Row(                mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editItem(index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteItem(index),
                    ),
                  ],
                ),*/
                // Puoi anche aggiungere un onTap se vuoi che l'elemento sia cliccabile
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hai toccato: ${item.text}')),
                  );
                },
              ),
            ),
          );
        },
        itemCount: _items.length,
        onReorder: _onReorder, // Associa il nostro callback di riordino
        padding: const EdgeInsets.only(top: 8.0),
      );
  }
}
