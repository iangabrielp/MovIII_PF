import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:taller_1/screens/MovieScreen.dart';
import 'package:url_launcher/url_launcher.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  List<dynamic> _movies = [];
  List<dynamic> _filteredMovies = [];
  final List<dynamic> _favorites = [];
  String _searchQuery = '';
  String _selectedGenre = 'Todos';

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    try {
      final jsonString = await DefaultAssetBundle.of(
        context,
      ).loadString('assets/data.json');
      final jsonData = json.decode(jsonString);
      setState(() {
        _movies = jsonData['peliculas'];
        _filteredMovies = List.from(_movies);
      });
    } catch (e) {
      throw Exception('Error al leer el archivo local: $e');
    }
  }

  void _filterMovies() {
    setState(() {
      _filteredMovies = _movies.where((movie) {
        final title = (movie['titulo'] ?? '').toLowerCase();
        final matchesSearch = title.contains(_searchQuery.toLowerCase());
        final matchesGenre =
            _selectedGenre == 'Todos' ||
            (movie['genero'] as List).contains(_selectedGenre);
        return matchesSearch && matchesGenre;
      }).toList();
    });
  }

  void _toggleFavorite(Map<String, dynamic> movie) {
    setState(() {
      if (_favorites.contains(movie)) {
        _favorites.remove(movie);
      } else {
        _favorites.add(movie);
      }
    });
  }

  void _cerrarSesion() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir la URL')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al abrir URL: $e')));
    }
  }

  void _showMovieDetailsDialog(
    BuildContext context,
    Map<String, dynamic> movie,
  ) {
    final enlaces = movie['enlaces'] ?? {};
    final String? trailerUrl = enlaces['trailer'];
    final String? peliculaUrl = enlaces['url'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(movie['titulo'] ?? 'Sin título'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    enlaces['image'] ?? '',
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image, size: 100),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Director: ${movie['detalles']?['director'] ?? 'Desconocido'}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text('Duración: ${movie['detalles']?['duracion'] ?? 'N/A'}'),
                Text('Año: ${movie['anio'] ?? 'Desconocido'}'),
                const SizedBox(height: 12),
                Text(movie['descripcion'] ?? 'No hay descripción'),
              ],
            ),
          ),
          actions: [
            if (trailerUrl != null && trailerUrl.isNotEmpty)
              TextButton(
                onPressed: () => _launchURL(trailerUrl),
                child: const Text('VER TRAILER'),
              ),
            if (peliculaUrl != null && peliculaUrl.isNotEmpty)
              TextButton(
  onPressed: peliculaUrl.isNotEmpty
      ? () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Moviescreen(youtubeUrl: peliculaUrl),
            ),
          );
        }
      : null,
  child: Text(
    'VER PELÍCULA',
    style: TextStyle(
      color: peliculaUrl.isNotEmpty
          ? Theme.of(context).colorScheme.primary
          : Colors.grey,
    ),
  ),
),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CERRAR'),
            ),
          ],
        );
      },
    );
  }

  List<String> _getGenres() {
    final genres = _movies.expand((m) => m['genero'] as List).toSet().toList();
    genres.sort();
    return ['Todos', ...genres];
  }

  @override
  Widget build(BuildContext context) {
    final genres = _getGenres();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            // Título y botón cerrar sesión en fila
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Catálogo de Películas',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                    fontSize: 22,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.exit_to_app, color: Colors.blueAccent),
                  tooltip: 'Cerrar sesión',
                  onPressed: _cerrarSesion,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Barra de búsqueda y dropdown
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Buscar película...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (value) {
                      _searchQuery = value;
                      _filterMovies();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _selectedGenre,
                    decoration: InputDecoration(
                      labelText: 'Género',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                    ),
                    items: genres.map((genre) {
                      return DropdownMenuItem(value: genre, child: Text(genre));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _selectedGenre = value;
                        _filterMovies();
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Lista de películas
            Expanded(
              child: _filteredMovies.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.movie_filter_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "No se encontraron películas",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    )
                  : ListView.builder(
                      itemCount: _filteredMovies.length,
                      itemBuilder: (context, index) {
                        final movie = _filteredMovies[index];
                        final isFavorite = _favorites.contains(movie);
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          margin: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 4,
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(8),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                movie['enlaces']?['image'] ?? '',
                                width: 70,
                                height: 90,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.broken_image, size: 50),
                              ),
                            ),
                            title: Text(
                              movie['titulo'] ?? 'Sin título',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                'Géneros: ${(movie['genero'] as List).join(', ')}\nValoración: ${movie['detalles']?['valoracion'] ?? 'N/A'}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            isThreeLine: true,
                            trailing: IconButton(
                              icon: Icon(
                                isFavorite
                                    ? Icons.star
                                    : Icons.star_border_outlined,
                                color: isFavorite ? Colors.amber : Colors.grey,
                                size: 28,
                              ),
                              onPressed: () => _toggleFavorite(movie),
                            ),
                            onTap: () =>
                                _showMovieDetailsDialog(context, movie),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
