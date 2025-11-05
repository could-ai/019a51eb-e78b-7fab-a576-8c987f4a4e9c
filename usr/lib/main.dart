import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Optimizador de Cortes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const OptimizationScreen(),
    );
  }
}

class CutPiece {
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
}

class OptimizationScreen extends StatefulWidget {
  const OptimizationScreen({super.key});

  @override
  State<OptimizationScreen> createState() => _OptimizationScreenState();
}

class _OptimizationScreenState extends State<OptimizationScreen> {
  final _stockLengthController = TextEditingController();
  final _stockWidthController = TextEditingController();
  final List<CutPiece> _cutPieces = [];
  List<String> _results = [];

  @override
  void initState() {
    super.initState();
    // Start with one piece to cut by default
    _addCutPiece();
  }

  void _addCutPiece() {
    setState(() {
      _cutPieces.add(CutPiece());
    });
  }

  void _removeCutPiece(int index) {
    setState(() {
      _cutPieces[index].lengthController.dispose();
      _cutPieces[index].widthController.dispose();
      _cutPieces[index].quantityController.dispose();
      _cutPieces.removeAt(index);
    });
  }

  void _optimizeCuts() {
    final double stockLength = double.tryParse(_stockLengthController.text) ?? 0;
    final double stockWidth = double.tryParse(_stockWidthController.text) ?? 0;

    if (stockLength <= 0 || stockWidth <= 0) {
      setState(() {
        _results = ['Por favor, ingrese dimensiones válidas para el material base.'];
      });
      return;
    }

    final piecesToCut = _cutPieces.map((p) {
      return {
        'length': double.tryParse(p.lengthController.text) ?? 0,
        'width': double.tryParse(p.widthController.text) ?? 0,
        'quantity': int.tryParse(p.quantityController.text) ?? 0,
      };
    }).where((p) => p['length']! > 0 && p['width']! > 0 && p['quantity']! > 0).toList();

    if (piecesToCut.isEmpty) {
      setState(() {
        _results = ['Por favor, ingrese al menos una pieza a cortar con dimensiones y cantidad válidas.'];
      });
      return;
    }

    // Placeholder for a real optimization algorithm
    // This is a complex problem (Bin Packing), so we'll just show the inputs for now.
    List<String> resultSummary = [
      'Resumen de la solicitud de optimización:',
      'Material base: $stockLength x $stockWidth',
      'Piezas a cortar:',
    ];

    for (var piece in piecesToCut) {
      resultSummary.add('- ${piece['quantity']}x de ${piece['length']} x ${piece['width']}');
    }
    
    resultSummary.add('\n(Funcionalidad de algoritmo de optimización próximamente)');

    setState(() {
      _results = resultSummary;
    });
  }

  @override
  void dispose() {
    _stockLengthController.dispose();
    _stockWidthController.dispose();
    for (var piece in _cutPieces) {
      piece.lengthController.dispose();
      piece.widthController.dispose();
      piece.quantityController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Optimizador de Cortes'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStockMaterialCard(),
              const SizedBox(height: 20),
              _buildCutPiecesCard(),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _optimizeCuts,
                icon: const Icon(Icons.calculate),
                label: const Text('Optimizar'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              _buildResultsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockMaterialCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Material Base', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField(_stockLengthController, 'Largo')),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField(_stockWidthController, 'Ancho')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCutPiecesCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Piezas a Cortar', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _cutPieces.length,
              itemBuilder: (context, index) {
                return _buildCutPieceItem(index);
              },
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _addCutPiece,
              icon: const Icon(Icons.add),
              label: const Text('Añadir Pieza'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCutPieceItem(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(child: _buildTextField(_cutPieces[index].lengthController, 'Largo')),
          const SizedBox(width: 8),
          Expanded(child: _buildTextField(_cutPieces[index].widthController, 'Ancho')),
          const SizedBox(width: 8),
          Expanded(child: _buildTextField(_cutPieces[index].quantityController, 'Cant.')),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
            onPressed: () => _removeCutPiece(index),
          ),
        ],
      ),
    );
  }
  
  Widget _buildResultsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resultados', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (_results.isEmpty)
              const Text('Presione "Optimizar" para ver los resultados.')
            else
              ..._results.map((line) => Text(line, style: const TextStyle(fontSize: 16))),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }
}
