import 'package:flutter/material.dart';
import 'package:animations/animations.dart'; // Allowed package for transitions

void main() {
  runApp(const DarkModeShowcaseApp());
}

class DarkModeShowcaseApp extends StatelessWidget {
  const DarkModeShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Componenti UI Personalizzati', // Changed title
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.grey[800],
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)), // Added shape
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // Added for section titles
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w500), // Added
          bodyLarge: TextStyle(color: Colors.white), // Added for detail screens
          bodyMedium: TextStyle(color: Colors.white70),
          labelLarge: TextStyle(color: Colors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[850],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.blue.shade300, width: 2.0),
          ),
          labelStyle: const TextStyle(color: Colors.white70),
          hintStyle: const TextStyle(color: Colors.grey),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.blue.shade300,
            side: BorderSide(color: Colors.blue.shade300, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue.shade300,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white70),
        dividerColor: Colors.grey[700],
        // Customize dialog and bottom sheet background for dark mode
        dialogTheme: DialogThemeData( // Changed DialogTheme to DialogThemeData
          backgroundColor: Colors.grey[800],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: Colors.grey[800],
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
          ),
        ),
      ),
      home: const ComponentShowcasePage(),
    );
  }
}

class ComponentShowcasePage extends StatefulWidget {
  const ComponentShowcasePage({super.key});

  @override
  State<ComponentShowcasePage> createState() => _ComponentShowcasePageState();
}

class _ComponentShowcasePageState extends State<ComponentShowcasePage> {
  // Variabili di stato per i widget di selezione
  bool _checkboxValue = true;
  int? _radioValue = 1;
  bool _switchValue = true;
  double _sliderValue = 0.5;
  bool _filterChipSelected = false;
  int _choiceChipValue = 0;
  String? _dropdownValue = 'Opzione A';
  int _currentStep = 0;
  List<String> _dismissibleItems = List<String>.generate(5, (i) => 'Articolo ${i + 1}');

  // Controller per i campi di testo con dati fittizi
  final TextEditingController _textController = TextEditingController(text: 'NomeUtente123');
  final TextEditingController _passwordController = TextEditingController(text: 'PasswordSegreta');
  final TextEditingController _multilineController = TextEditingController(
      text: 'Questo è un testo lungo su più righe per dimostrare un campo di testo multiline. '
          'È utile per descrizioni, commenti o qualsiasi input che richieda più spazio.');

  @override
  void dispose() {
    _textController.dispose();
    _passwordController.dispose();
    _multilineController.dispose();
    super.dispose();
  }

  // Helper per i titoli di sezione
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }

  // Funzioni per mostrare i dialoghi
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'Annulla', // Italian for 'Undo'
          onPressed: () {
            // Logica per annullare l'azione
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            _showSnackBar(context, 'Azione annullata!');
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showAlertDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Titolo dell\'Alert'),
          content: const Text('Questo è un messaggio di esempio per un AlertDialog in modalità scura. Puoi includere informazioni importanti o richiedere una decisione all\'utente.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showSnackBar(context, 'Azione annullata.');
              },
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showSnackBar(context, 'Azione confermata!');
              },
              child: const Text('Conferma'),
            ),
          ],
        );
      },
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Occupa solo lo spazio necessario
            children: <Widget>[
              Text(
                'Titolo del Bottom Sheet',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              const Text('Contenuto di esempio per il bottom sheet. Qui puoi visualizzare opzioni aggiuntive o informazioni contestuali senza navigare in una nuova schermata.'),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showSnackBar(context, 'Bottom Sheet chiuso.');
                  },
                  child: const Text('Chiudi Bottom Sheet'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDateTimePicker(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.blue.shade300, // Colore primario per il selettore
              onPrimary: Colors.black, // Testo sul colore primario
              onSurface: Colors.white, // Testo sul colore della superficie
              surface: Colors.grey[800]!, // Colore di sfondo del selettore
              onSurfaceVariant: Colors.white70, // For year/month picker text
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.blue.shade300),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.dark(
                primary: Colors.blue.shade300, // Colore primario per il selettore
                onPrimary: Colors.black, // Testo sul colore primario
                onSurface: Colors.white, // Testo sul colore della superficie
                surface: Colors.grey[800]!, // Colore di sfondo del selettore
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(foregroundColor: Colors.blue.shade300),
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        _showSnackBar(
          context,
          'Data e Ora selezionate: ${pickedDate.toLocal().toString().split(' ')[0]} alle ${pickedTime.format(context)}',
        );
      } else {
        _showSnackBar(context, 'Selezione ora annullata.');
      }
    } else {
      _showSnackBar(context, 'Selezione data annullata.');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define steps within build method for dynamic state
    final List<Step> stepsList = <Step>[
      Step(
        title: const Text('Passaggio 1: Dati Personali'),
        content: const Column(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Cognome'),
            ),
            SizedBox(height: 8),
          ],
        ),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Passaggio 2: Indirizzo'),
        content: const Column(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(labelText: 'Via'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Città'),
            ),
            SizedBox(height: 8),
          ],
        ),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Passaggio 3: Riepilogo'),
        content: const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('Rivedi le tue informazioni prima di inviare.'),
        ),
        isActive: _currentStep >= 2,
        state: _currentStep >= 2 ? StepState.complete : StepState.indexed,
      ),
    ];

    final int _stepsLength = stepsList.length; // Get the length of the steps

    return Scaffold(
      appBar: AppBar(
        title: const Text('Componenti UI Personalizzati'), // Changed app bar title
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          // --- Componenti di Testo ---
          _buildSectionTitle('Testo e Titoli'),
          Text('Titolo H1 Grande', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 8),
          Text('Titolo H2 Medio', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Sottotitolo Importante', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
              'Corpo del testo - Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          const Divider(),

          // --- Bottoni ---
          _buildSectionTitle('Bottoni'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  _showSnackBar(context, 'Bottone Elevato premuto!');
                },
                child: const Text('Elevato'),
              ),
              OutlinedButton(
                onPressed: () {
                  _showSnackBar(context, 'Bottone Contornato premuto!');
                },
                child: const Text('Contornato'),
              ),
              TextButton(
                onPressed: () {
                  _showSnackBar(context, 'Bottone Testo premuto!');
                },
                child: const Text('Testo'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.favorite),
                onPressed: () {
                  _showSnackBar(context, 'Icona "Mi piace" premuta!');
                },
                tooltip: 'Mi piace',
              ),
              FloatingActionButton(
                onPressed: () {
                  _showSnackBar(context, 'FAB mini premuto!');
                },
                mini: true,
                child: const Icon(Icons.add),
              ),
              FloatingActionButton.extended(
                onPressed: () {
                  _showSnackBar(context, 'FAB esteso premuto!');
                },
                label: const Text('Aggiungi'),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),

          // --- Campi di Input ---
          _buildSectionTitle('Campi di Input'),
          TextField(
            controller: _textController,
            decoration: const InputDecoration(
              labelText: 'Nome Utente',
              hintText: 'Inserisci il tuo nome',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              hintText: 'Inserisci la tua password',
              prefixIcon: Icon(Icons.lock),
              suffixIcon: Icon(Icons.visibility_off),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _multilineController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Descrizione (Multilinea)',
              hintText: 'Inserisci una descrizione lunga',
              prefixIcon: Icon(Icons.description),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),

          // --- Widget di Selezione ---
          _buildSectionTitle('Selezione'),
          Row(
            children: <Widget>[
              Checkbox(
                value: _checkboxValue,
                onChanged: (bool? value) {
                  setState(() {
                    _checkboxValue = value ?? false;
                  });
                  _showSnackBar(context, 'Checkbox: ${_checkboxValue ? 'Accettato' : 'Non accettato'}');
                },
              ),
              const Text('Accetta i termini e condizioni'),
            ],
          ),
          Row(
            children: <Widget>[
              Radio<int>(
                value: 1,
                groupValue: _radioValue,
                onChanged: (int? value) {
                  setState(() {
                    _radioValue = value;
                  });
                  _showSnackBar(context, 'Radio: Opzione 1 selezionata');
                },
              ),
              const Text('Opzione Radio 1'),
            ],
          ),
          Row(
            children: <Widget>[
              Radio<int>(
                value: 2,
                groupValue: _radioValue,
                onChanged: (int? value) {
                  setState(() {
                    _radioValue = value;
                  });
                  _showSnackBar(context, 'Radio: Opzione 2 selezionata');
                },
              ),
              const Text('Opzione Radio 2'),
            ],
          ),
          Row(
            children: <Widget>[
              Switch(
                value: _switchValue,
                onChanged: (bool value) {
                  setState(() {
                    _switchValue = value;
                  });
                  _showSnackBar(context, 'Switch: ${value ? 'Attivo' : 'Disattivo'}');
                },
              ),
              const Text('Attiva/Disattiva Funzione'),
            ],
          ),
          const SizedBox(height: 16),

          // New: DropdownButton
          DropdownButton<String>(
            value: _dropdownValue,
            icon: const Icon(Icons.arrow_downward),
            elevation: 16,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
            underline: Container(
              height: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
            onChanged: (String? newValue) {
              setState(() {
                _dropdownValue = newValue;
              });
              _showSnackBar(context, 'Dropdown selezionato: $newValue');
            },
            items: <String>['Opzione A', 'Opzione B', 'Opzione C', 'Opzione D']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Divider(),

          // --- Indicatori di Progresso ---
          _buildSectionTitle('Indicatori di Progresso'),
          const LinearProgressIndicator(value: 0.7),
          const SizedBox(height: 16),
          const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 16),
          const Divider(),

          // --- Slider ---
          _buildSectionTitle('Slider'),
          Slider(
            value: _sliderValue,
            min: 0.0,
            max: 1.0,
            divisions: 10,
            label: (_sliderValue * 100).toStringAsFixed(0) + '%',
            onChanged: (double value) {
              setState(() {
                _sliderValue = value;
              });
            },
          ),
          const SizedBox(height: 16),
          const Divider(),

          // --- Immagine (Original) ---
          _buildSectionTitle('Immagine Standard'),
          Card(
            clipBehavior: Clip.antiAlias, // Per ritagliare l'immagine negli angoli arrotondati
            child: Column(
              children: [
                Image.network(
                  'https://www.gstatic.com/flutter-onestack-prototype/genui/example_1.jpg', // Allowed placeholder URL
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => const SizedBox(
                    height: 200,
                    child: Center(child: Icon(Icons.broken_image, size: 50, color: Colors.redAccent)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Questa è un\'immagine di esempio di paesaggio. Le immagini sono caricate dalla rete e mostrano un indicatore di progresso durante il caricamento.',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),

          // --- Card e Liste ---
          _buildSectionTitle('Card e Liste'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications, color: Colors.amber),
              title: const Text('Notifica Importante'),
              subtitle: const Text('Questo è un messaggio di notifica con dettagli aggiuntivi.'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                _showSnackBar(context, 'ListTile premuto!');
              },
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Titolo di una Card Personalizzata', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                      'Questa card contiene un layout personalizzato, utile per visualizzare gruppi di informazioni correlate in modo organizzato.',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text('Dettagli aggiuntivi qui.', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),

          // --- Chips ---
          _buildSectionTitle('Chip'),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: <Widget>[
              Chip(
                avatar: const CircleAvatar(backgroundColor: Colors.blue, child: Text('A', style: TextStyle(color: Colors.white))),
                label: const Text('Chip Semplice'),
                onDeleted: () {
                  _showSnackBar(context, 'Chip Semplice eliminato!');
                },
                deleteIcon: const Icon(Icons.cancel),
              ),
              ActionChip(
                avatar: const Icon(Icons.phone),
                label: const Text('Chiama'),
                onPressed: () {
                  _showSnackBar(context, 'ActionChip "Chiama" premuto!');
                },
              ),
              FilterChip(
                label: const Text('Filtra Opzione'),
                selected: _filterChipSelected,
                onSelected: (bool selected) {
                  setState(() {
                    _filterChipSelected = selected;
                  });
                  _showSnackBar(context, 'FilterChip: ${selected ? 'Selezionato' : 'Deselezionato'}');
                },
              ),
              ChoiceChip(
                label: const Text('Scelta 1'),
                selected: _choiceChipValue == 0,
                onSelected: (bool selected) {
                  setState(() {
                    _choiceChipValue = selected ? 0 : -1;
                  });
                  _showSnackBar(context, 'ChoiceChip: Scelta 1 ${selected ? 'selezionata' : 'deselezionata'}');
                },
              ),
              ChoiceChip(
                label: const Text('Scelta 2'),
                selected: _choiceChipValue == 1,
                onSelected: (bool selected) {
                  setState(() {
                    _choiceChipValue = selected ? 1 : -1;
                  });
                  _showSnackBar(context, 'ChoiceChip: Scelta 2 ${selected ? 'selezionata' : 'deselezionata'}');
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),

          // New: ExpansionTile
          _buildSectionTitle('Espandibile'),
          Card(
            child: ExpansionTile(
              title: const Text('Dettagli Prodotto'),
              subtitle: const Text('Clicca per maggiori informazioni'),
              leading: const Icon(Icons.info_outline),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Questa è la descrizione dettagliata del prodotto. Può contenere testo, immagini o altri widget. Utile per mostrare informazioni aggiuntive senza occupare troppo spazio inizialmente.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      onPressed: () {
                        _showSnackBar(context, 'Azione Espansione!');
                      },
                      child: const Text('Vedi altro'),
                    ),
                  ),
                ),
              ],
              onExpansionChanged: (bool expanded) {
                _showSnackBar(context, 'ExpansionTile ${expanded ? 'espanso' : 'compresso'}');
              },
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),

          // New: Stepper
          _buildSectionTitle('Stepper'),
          Stepper(
            type: StepperType.vertical,
            currentStep: _currentStep,
            onStepContinue: () {
              setState(() {
                if (_currentStep < _stepsLength - 1) {
                  _currentStep += 1;
                } else {
                  _showSnackBar(context, 'Processo completato!');
                  _currentStep = 0; // Reset for demo
                }
                // Ensure _currentStep is always within valid bounds
                _currentStep = _currentStep.clamp(0, _stepsLength - 1);
              });
            },
            onStepCancel: () {
              setState(() {
                if (_currentStep > 0) {
                  _currentStep -= 1;
                } else {
                  _showSnackBar(context, 'Processo annullato.');
                }
                // Ensure _currentStep is always within valid bounds
                _currentStep = _currentStep.clamp(0, _stepsLength - 1);
              });
            },
            onStepTapped: (int step) {
              setState(() {
                // Ensure tapped step is always within valid bounds
                _currentStep = step.clamp(0, _stepsLength - 1);
              });
            },
            steps: stepsList, // Use the stored stepsList
            controlsBuilder: (BuildContext context, ControlsDetails controls) {
              return Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: controls.onStepContinue,
                      child: Text(_currentStep == _stepsLength - 1 ? 'Conferma' : 'Continua'),
                    ),
                    if (_currentStep != 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: TextButton(
                          onPressed: controls.onStepCancel,
                          child: const Text('Indietro'),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const Divider(),

          // New: DataTable
          _buildSectionTitle('Tabella Dati'),
          Card(
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              // For horizontal scrolling if table is wide
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const <DataColumn>[
                  DataColumn(label: Text('Nome')),
                  DataColumn(label: Text('Età')),
                  DataColumn(label: Text('Città')),
                  DataColumn(label: Text('Paese')), // Added a column
                ],
                rows: const <DataRow>[
                  DataRow(cells: <DataCell>[
                    DataCell(Text('Mario Rossi')),
                    DataCell(Text('30')),
                    DataCell(Text('Roma')),
                    DataCell(Text('Italia')),
                  ]),
                  DataRow(cells: <DataCell>[
                    DataCell(Text('Luisa Verdi')),
                    DataCell(Text('24')),
                    DataCell(Text('Milano')),
                    DataCell(Text('Italia')),
                  ]),
                  DataRow(cells: <DataCell>[
                    DataCell(Text('Giulia Bianchi')),
                    DataCell(Text('35')),
                    DataCell(Text('Napoli')),
                    DataCell(Text('Italia')),
                  ]),
                  DataRow(cells: <DataCell>[
                    DataCell(Text('Carlo Neri')),
                    DataCell(Text('28')),
                    DataCell(Text('Torino')),
                    DataCell(Text('Italia')),
                  ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),

          // New: Dismissible List
          _buildSectionTitle('Lista Eliminabile'),
          SizedBox(
            height: 300, // Constrain height for demo within ListView
            child: ListView.builder(
              itemCount: _dismissibleItems.length,
              itemBuilder: (BuildContext context, int index) {
                final String item = _dismissibleItems[index];
                return Dismissible(
                  key: Key(item), // Unique key required for Dismissible
                  direction: DismissDirection.endToStart, // Swipe from right to left
                  onDismissed: (DismissDirection direction) {
                    setState(() {
                      _dismissibleItems.removeAt(index);
                    });
                    _showSnackBar(context, '$item eliminato!');
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: const Icon(Icons.delete, color: Colors.white, size: 30),
                  ),
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0), // Smaller margin for list items
                    child: ListTile(
                      title: Text(item),
                      leading: const Icon(Icons.list),
                      onTap: () => _showSnackBar(context, '$item selezionato!'),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),

          // --- OpenContainer for Animated Transition ---
          _buildSectionTitle('OpenContainer Animato'),
          OpenContainer<void>(
            transitionType: ContainerTransitionType.fadeThrough, // Elegant transition type
            transitionDuration: const Duration(milliseconds: 700),
            closedElevation: 2.0,
            closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            closedColor: Theme.of(context).cardTheme.color!,
            closedBuilder: (BuildContext context, VoidCallback openContainer) {
              return Card(
                clipBehavior: Clip.antiAlias,
                margin: EdgeInsets.zero, // OpenContainer handles its own margin
                child: InkWell(
                  onTap: openContainer,
                  child: Column(
                    children: <Widget>[
                      Image.network(
                        'https://www.gstatic.com/flutter-onestack-prototype/genui/example_1.jpg', // Allowed placeholder URL
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return SizedBox(
                            height: 200,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => const SizedBox(
                          height: 200,
                          child: Center(child: Icon(Icons.broken_image, size: 50, color: Colors.redAccent)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Clicca su questa card per vedere i dettagli con un\'animazione di transizione.',
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            openBuilder: (BuildContext context, VoidCallback _) {
              return const DetailScreen(
                imageUrl: 'https://www.gstatic.com/flutter-onestack-prototype/genui/example_1.jpg',
                title: 'Paesaggio Montano Animato',
              );
            },
          ),
          const SizedBox(height: 16),
          const Divider(),

          // Add implicit animations, e.g., AnimatedContainer on tap
          _buildSectionTitle('Contenitore Animato'),
          const _AnimatedColorContainer(), // New StatefulWidget for this to manage its own state
          const SizedBox(height: 16),
          const Divider(),

          // --- Dialoghi, Bottom Sheets e Snackbars ---
          _buildSectionTitle('Finestre di Dialogo e Fogli'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              ElevatedButton(
                onPressed: () => _showAlertDialog(context),
                child: const Text('Mostra Alert'),
              ),
              ElevatedButton(
                onPressed: () => _showBottomSheet(context),
                child: const Text('Mostra Bottom Sheet'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              ElevatedButton(
                onPressed: () => _showSnackBar(context, 'Questo è un messaggio di Snackbar!'),
                child: const Text('Mostra Snackbar'),
              ),
              ElevatedButton(
                onPressed: () => _showDateTimePicker(context),
                child: const Text('Seleziona Data/Ora'),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// New widget for AnimatedContainer example
class _AnimatedColorContainer extends StatefulWidget {
  const _AnimatedColorContainer({super.key});

  @override
  State<_AnimatedColorContainer> createState() => _AnimatedColorContainerState();
}

class _AnimatedColorContainerState extends State<_AnimatedColorContainer> {
  Color _containerColor = Colors.blueGrey.shade700;
  double _containerSize = 100.0;
  Alignment _containerAlignment = Alignment.center;

  void _changeState() {
    setState(() {
      _containerColor = (_containerColor == Colors.blueGrey.shade700) ? Colors.teal.shade700 : Colors.blueGrey.shade700;
      _containerSize = (_containerSize == 100.0) ? 150.0 : 100.0;
      _containerAlignment = (_containerAlignment == Alignment.center) ? Alignment.topRight : Alignment.center;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _changeState,
      child: AnimatedContainer(
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOutBack,
        width: _containerSize,
        height: _containerSize,
        decoration: BoxDecoration(
          color: _containerColor,
          borderRadius: BorderRadius.circular(_containerSize / 4),
          boxShadow: [
            BoxShadow(
              color: _containerColor.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        alignment: _containerAlignment,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Tocca me!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

// New Detail Screen for OpenContainer Transition
class DetailScreen extends StatelessWidget {
  const DetailScreen({
    super.key,
    required this.imageUrl,
    required this.title,
  });

  final String imageUrl;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettaglio Immagine'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Image.network(
              imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;
                return AspectRatio(
                  aspectRatio: 16 / 9, // Maintain aspect ratio for placeholder
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => AspectRatio(
                aspectRatio: 16 / 9,
                child: Center(child: Icon(Icons.broken_image, size: 100, color: Colors.redAccent)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Questa è una descrizione estesa del paesaggio montano. È un luogo ideale per escursioni, avventure e per godere della bellezza naturale. Il cielo blu e le vette innevate creano uno scenario mozzafiato che ispira tranquillità e meraviglia. Ammira la maestosità della natura in questo scatto. Questo contenuto aggiuntivo dimostra come una pagina di dettaglio possa presentare informazioni più ricche e approfondite relative all\'elemento selezionato, utilizzando diversi stili di testo per una chiara gerarchia.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Informazioni aggiuntive: \n- Altitudine: 3000m \n- Clima: Alpino \n- Attività: Trekking, Sci, Alpinismo, Fotografia paesaggistica.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      const Icon(Icons.location_on, size: 20),
                      const SizedBox(width: 8),
                      Text('Località Sconosciuta', style: Theme.of(context).textTheme.bodyMedium),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.share),
                        label: const Text('Condividi'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}