// 🐱 Reto 2: Generador de Memes de Gatos con Filtros
// API: Cataas (Cats as a Service) — https://cataas.com
//
// Idea clave: la imagen NO se descarga con código raro.
// Solo construimos una URL distinta según el estado de la app,
// y Image.network se encarga del resto. ¡Cambias la URL, cambia el gato!

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const GatoMemeApp());

class GatoMemeApp extends StatelessWidget {
  const GatoMemeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gato Meme',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.deepOrange,
      ),
      home: const GeneradorPage(),
    );
  }
}

class GeneradorPage extends StatefulWidget {
  const GeneradorPage({super.key});

  @override
  State<GeneradorPage> createState() => _GeneradorPageState();
}

class _GeneradorPageState extends State<GeneradorPage> {
  // ---------- ESTADO ----------
  final _textoCtrl = TextEditingController(text: 'Hola humano');
  String _filtro = 'ninguno';
  String _colorTexto = 'white';
  double _tamanoFuente = 40;

  // URL que realmente se muestra (solo cambia al presionar "Generar")
  String? _urlActual;

  // Para que cada "Generar" traiga un gato NUEVO (rompe la caché)
  int _semilla = DateTime.now().millisecondsSinceEpoch;

  static const _filtros = {
    'ninguno': '🚫 Normal',
    'mono': '⚫ B/N',
    'negate': '🌈 Negativo',
    'blur': '💨 Borroso',
  };

  static const _colores = {
    'white': Colors.white,
    'yellow': Colors.yellow,
    'red': Colors.red,
    'cyan': Colors.cyan,
    'lime': Colors.lime,
    'black': Colors.black,
  };

  // ---------- LA MAGIA: construir la URL ----------
  Uri _construirUrl({bool conSemilla = true}) {
    // Quitamos "/" porque rompería la ruta de la URL
    final texto = _textoCtrl.text.trim().replaceAll('/', ' ');

    // Ruta: /cat (gato al azar)  |  /cat/says/<texto> (gato con frase)
    final segmentos = <String>[
      'cat',
      if (texto.isNotEmpty) ...['says', texto],
    ];

    // Parámetros: ?fontSize=40&fontColor=white&filter=mono
    final params = <String, String>{
      if (texto.isNotEmpty) 'fontSize': _tamanoFuente.round().toString(),
      if (texto.isNotEmpty) 'fontColor': _colorTexto,
      if (_filtro != 'ninguno') 'filter': _filtro,
      if (conSemilla) 'cb': '$_semilla', // 'cb' = cache buster
    };

    // pathSegments codifica espacios, acentos y emojis automáticamente
    return Uri(
      scheme: 'https',
      host: 'cataas.com',
      pathSegments: segmentos,
      queryParameters: params.isEmpty ? null : params,
    );
  }

  void _generar() {
    FocusScope.of(context).unfocus();
    setState(() {
      _semilla = DateTime.now().millisecondsSinceEpoch;
      _urlActual = _construirUrl().toString();
    });
  }

  @override
  void initState() {
    super.initState();
    _urlActual = _construirUrl().toString();
    // Cada tecla actualiza la vista previa de la URL
    _textoCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _textoCtrl.dispose();
    super.dispose();
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🐱 Gato Meme Generator'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _tarjetaImagen(esquema),
            const SizedBox(height: 16),

            // Texto del meme
            TextField(
              controller: _textoCtrl,
              maxLength: 50,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _generar(),
              decoration: InputDecoration(
                labelText: '¿Qué dice el gato?',
                prefixIcon: const Icon(Icons.chat_bubble_outline),
                suffixIcon: _textoCtrl.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _textoCtrl.clear,
                      ),
                border: const OutlineInputBorder(),
              ),
            ),

            // Filtros
            _titulo('Filtro'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _filtros.entries.map((e) {
                return ChoiceChip(
                  label: Text(e.value),
                  selected: _filtro == e.key,
                  onSelected: (_) {
                    _filtro = e.key;
                    _generar(); // el filtro se aplica al instante
                  },
                );
              }).toList(),
            ),

            // Color del texto
            _titulo('Color del texto'),
            Row(
              children: _colores.entries.map((e) {
                final elegido = _colorTexto == e.key;
                return GestureDetector(
                  onTap: () {
                    _colorTexto = e.key;
                    _generar(); // el color se aplica al instante
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 10),
                    width: elegido ? 40 : 32,
                    height: elegido ? 40 : 32,
                    decoration: BoxDecoration(
                      color: e.value,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: elegido ? esquema.primary : Colors.white24,
                        width: elegido ? 3 : 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            // Tamaño de letra
            _titulo('Tamaño de letra: ${_tamanoFuente.round()}'),
            Slider(
              value: _tamanoFuente,
              min: 15,
              max: 80,
              divisions: 13,
              label: _tamanoFuente.round().toString(),
              onChanged: (v) => setState(() => _tamanoFuente = v),
              onChangeEnd: (_) => _generar(), // al soltar, nuevo meme
            ),

            // URL en vivo (lo educativo 👀)
            _titulo('URL que se va a pedir'),
            _cajaUrl(esquema),
            const SizedBox(height: 20),

            FilledButton.icon(
              onPressed: _generar,
              icon: const Icon(Icons.auto_awesome),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('¡Generar meme!', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaImagen(ColorScheme esquema) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 6,
      child: AspectRatio(
        aspectRatio: 1,
        child: _urlActual == null
            ? const SizedBox()
            : Image.network(
                _urlActual!,
                key: ValueKey(_urlActual), // fuerza recarga con cada URL
                fit: BoxFit.cover,
                gaplessPlayback: true,
                loadingBuilder: (context, child, progreso) {
                  if (progreso == null) return child;
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          value: progreso.expectedTotalBytes != null
                              ? progreso.cumulativeBytesLoaded /
                                  progreso.expectedTotalBytes!
                              : null,
                        ),
                        const SizedBox(height: 12),
                        const Text('Buscando un gato... 🐾'),
                      ],
                    ),
                  );
                },
                errorBuilder: (context, error, stack) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('😿', style: TextStyle(fontSize: 64)),
                      const Text('El gato se escapó'),
                      TextButton(
                        onPressed: _generar,
                        child: const Text('Intentar otra vez'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _cajaUrl(ColorScheme esquema) {
    // Mostramos la URL sin la semilla anti-caché para que se lea limpia
    final url = Uri.decodeFull(_construirUrl(conSemilla: false).toString());
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      decoration: BoxDecoration(
        color: esquema.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: SelectableText(
              url,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: esquema.primary,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Copiar',
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('URL copiada 📋')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _titulo(String texto) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Text(
          texto,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      );
}
