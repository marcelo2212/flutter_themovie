import 'package:flutter/material.dart';
import 'package:flutter_themovie/services/movie_service.dart';
import 'package:flutter_themovie/models/movie.dart';
import 'package:intl/intl.dart';
import 'movie_detail_screen.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';

class MovieListScreen extends StatefulWidget {
  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  List<Movie> movies = [];
  int page = 1;
  bool loading = false;
  String selectedSortBy = 'popularity.desc';
  String? tempSortBy;
  DateTime? selectedFromDate;
  DateTime? selectedToDate;
  DateTime? tempFromDate;
  DateTime? tempToDate;
  List<String> certifications = [];
  String? selectedCertification;
  String? tempCertification;
  List<dynamic> genres = [];
  bool genresLoaded = false;
  List<int> selectedGenres = [];
  List<int> tempSelectedGenres = [];
  List<dynamic> languages = [];
  String? selectedLanguage;
  String? tempLanguage;
  bool languagesLoaded = false;
  List<dynamic> keywordResults = [];
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _suggestions = [];
  String? selectedKeyword;
  int? selectedKeywordId;
  GlobalKey<AutoCompleteTextFieldState<String>> key = GlobalKey();
  AutoCompleteTextField? searchTextField;

  @override
  void initState() {
    super.initState();
    fetchMovies();
    fetchCertifications();
    fetchGenres();
    fetchLanguages();
  }

  Future<List<dynamic>> searchKeywordsInput(String input) async {
    try {
      if (input.length < 3) {
        return [];
      }
      var response = await MovieService.searchKeywords(input);
      return response;
    } catch (error) {
      throw Exception(
          'Erro ao buscar palavras-chave. Por favor, tente novamente mais tarde.');
    }
  }

  void _onTextChanged(String input) async {
    if (input.length >= 3) {
      final newSuggestions = await searchKeywordsInput(input);
      setState(() {
        _suggestions = newSuggestions;
      });
    } else {
      setState(() {
        _suggestions = [];
      });
    }
  }

  void _onSuggestionSelected(dynamic suggestion) {
    setState(() {
      selectedKeyword = suggestion['name'];
      selectedKeywordId = suggestion['id'];
      _controller.text = suggestion['name'];
      _suggestions = [];
    });
  }

  Future<void> fetchLanguages() async {
    try {
      languages = await MovieService.fetchLanguages();
      setState(() {
        languagesLoaded = true;
      });
    } catch (error) {
      setState(() {
        languagesLoaded = false;
      });
      throw Exception('Erro ao carregar os idiomas');
    }
  }

  Future<void> fetchGenres() async {
    try {
      genres = await MovieService.fetchGenres();
      setState(() {
        genresLoaded = true;
      });
    } catch (error) {
      throw Exception('Erro ao buscar gêneros: $error');
    }
  }

  Future<void> fetchCertifications() async {
    try {
      certifications = await MovieService.fetchCertifications();
      certifications.sort((a, b) {
        final RegExp regex = RegExp(r'^\d+$');
        final bool isANumberA = regex.hasMatch(a);
        final bool isANumberB = regex.hasMatch(b);

        if (isANumberA && isANumberB || !isANumberA && !isANumberB) {
          return a.compareTo(b);
        } else if (isANumberA) {
          return 1;
        } else {
          return -1;
        }
      });
      setState(() {});
    } catch (error) {
      throw Exception('Erro ao buscar as classificações etárias');
    }
  }

  Future<void> fetchMovies() async {
    setState(() {
      loading = true;
    });

    try {
      final fetchedMovies = await MovieService.listMovies(
        page,
        sortBy: selectedSortBy,
        fromDate: selectedFromDate,
        toDate: selectedToDate,
        certification: selectedCertification,
        genres: selectedGenres.isNotEmpty ? selectedGenres.join(',') : null,
        language: selectedLanguage,
      );
      setState(() {
        movies.addAll(fetchedMovies);
      });
    } catch (error) {
      throw Exception('Erro ao buscar filmes: $error');
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void updateFilters(String? sortBy, DateTime? fromDate, DateTime? toDate,
      String? certification, String? language, dynamic genres) {
    setState(() {
      selectedSortBy = sortBy ?? 'popularity.desc';
      selectedFromDate = fromDate;
      selectedToDate = toDate;
      selectedCertification = certification;
      page = 1;
      selectedLanguage = language;
      selectedGenres = genres;
      movies.clear();
      fetchMovies();
    });
  }

  void showFilterModal(BuildContext context) {
    setState(() {
      tempSortBy = selectedSortBy;
      tempFromDate = selectedFromDate;
      tempToDate = selectedToDate;
      tempCertification = selectedCertification;
      tempSelectedGenres = List.from(selectedGenres);
      tempLanguage = selectedLanguage;
    });

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'FILTROS',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Ordenar por:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    DropdownButton<String>(
                      value: tempSortBy,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                            value: 'popularity.desc',
                            child: Text('Popularidade Descendente')),
                        DropdownMenuItem(
                            value: 'popularity.asc',
                            child: Text('Popularidade Ascendente')),
                        DropdownMenuItem(
                            value: 'vote_average.desc',
                            child: Text('Classificação Descendente')),
                        DropdownMenuItem(
                            value: 'vote_average.asc',
                            child: Text('Classificação Ascendente')),
                        DropdownMenuItem(
                            value: 'primary_release_date.desc',
                            child: Text('Data de lançamento descendente')),
                        DropdownMenuItem(
                            value: 'primary_release_date.asc',
                            child: Text('Data de lançamento ascendente')),
                        DropdownMenuItem(
                            value: 'title.asc', child: Text('Título (A-Z)')),
                        DropdownMenuItem(
                            value: 'title.desc', child: Text('Título (Z-A)')),
                      ],
                      onChanged: (value) {
                        setModalState(() {
                          tempSortBy = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Datas de lançamentos',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'De:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    TextField(
                      controller: TextEditingController(
                        text: tempFromDate != null
                            ? DateFormat('yyyy-MM-dd').format(tempFromDate!)
                            : '',
                      ),
                      decoration: const InputDecoration(
                        hintText: 'dd-mm-aaaa',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: tempFromDate ?? DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          setModalState(() {
                            tempFromDate = pickedDate;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Até:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    TextField(
                      controller: TextEditingController(
                        text: tempToDate != null
                            ? DateFormat('yyyy-MM-dd').format(tempToDate!)
                            : '',
                      ),
                      decoration: const InputDecoration(
                        hintText: 'dd-mm-aaaa',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: tempToDate ?? DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          setModalState(() {
                            tempToDate = pickedDate;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      margin: const EdgeInsets.only(top: 8.0),
                      child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Certificação Etária:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    DropdownButton<String>(
                      value: tempCertification,
                      isExpanded: true,
                      items: certifications
                          .map((cert) => DropdownMenuItem(
                                value: cert,
                                child: Text(cert),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setModalState(() {
                          tempCertification = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      margin: const EdgeInsets.only(top: 8.0),
                      child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Idioma:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    DropdownButton<String>(
                      value: tempLanguage,
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem(
                            value: 'all', child: Text('Todos os Idiomas')),
                        for (var language in languages)
                          DropdownMenuItem(
                            value: language['iso_639_1'],
                            child: Text(language['name']),
                          )
                      ],
                      onChanged: (value) {
                        setModalState(() {
                          tempLanguage = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      margin: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Gêneros:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    genresLoaded
                        ? Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: genres.map<Widget>((genre) {
                              final isSelected =
                                  tempSelectedGenres.contains(genre['id']);
                              return ChoiceChip(
                                label: Text(genre['name']),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setModalState(() {
                                    if (selected) {
                                      tempSelectedGenres.add(genre['id']);
                                    } else {
                                      tempSelectedGenres.remove(genre['id']);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          )
                        : const Center(child: CircularProgressIndicator()),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Palavras-chave:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          AutoCompleteTextField<String>(
                            key: key,
                            controller: _controller,
                            suggestions: _suggestions
                                .map((suggestion) =>
                                    suggestion['name'] as String)
                                .toList(),
                            clearOnSubmit: false,
                            textChanged: _onTextChanged,
                            textSubmitted: (value) {
                              final selectedSuggestion =
                                  _suggestions.firstWhere(
                                (suggestion) => suggestion['name'] == value,
                                orElse: () => null,
                              );
                              if (selectedSuggestion != null) {
                                _onSuggestionSelected(selectedSuggestion);
                              }
                            },
                            decoration: const InputDecoration(
                              labelText: 'Search',
                              border: OutlineInputBorder(),
                            ),
                            itemBuilder: (context, suggestion) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(suggestion),
                            ),
                            itemFilter: (suggestion, input) => suggestion
                                .toLowerCase()
                                .startsWith(input.toLowerCase()),
                            itemSorter: (a, b) => a.compareTo(b),
                            itemSubmitted: (item) {
                              final selectedSuggestion =
                                  _suggestions.firstWhere(
                                (suggestion) => suggestion['name'] == item,
                                orElse: () => null,
                              );
                              if (selectedSuggestion != null) {
                                _onSuggestionSelected(selectedSuggestion);
                              }
                            },
                          ),
                          if (_suggestions.isNotEmpty)
                            Container(
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: ListView.builder(
                                itemCount: _suggestions.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(_suggestions[index]['name']),
                                    onTap: () {
                                      _onSuggestionSelected(
                                          _suggestions[index]);
                                    },
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        updateFilters(
                            tempSortBy,
                            tempFromDate,
                            tempToDate,
                            tempCertification,
                            tempLanguage,
                            tempSelectedGenres);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text('Aplicar Filtros'),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: Colors.grey.shade400,
                          ),
                          child: const Text('Fechar'),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            setModalState(() {
                              tempSortBy = 'popularity.desc';
                              tempFromDate = null;
                              tempToDate = null;
                              tempCertification = null;
                            });
                            updateFilters(null, null, null, null, null, null);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text('Limpar Filtro'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Themo Movie DB',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: loading && movies.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2 / 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final movie = movies[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MovieDetailScreen(movieId: movie.id!),
                            ),
                          );
                        },
                        child: Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Image.network(
                                  movie.backdropPath != null
                                      ? 'https://image.tmdb.org/t/p/w220_and_h330_face/${movie.backdropPath}'
                                      : '/noimage.jpg',
                                  fit: BoxFit.fill,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      movie.title ?? 'No Title',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      movie.releaseDate != null
                                          ? DateFormat.yMMMd('pt_BR').format(
                                              DateTime.parse(
                                                  movie.releaseDate!))
                                          : '',
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: movies.length,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: loading
                          ? null
                          : () {
                              setState(() {
                                page += 1;
                                fetchMovies();
                              });
                            },
                      child: loading
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Text('Ver Mais'),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showFilterModal(context);
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.filter_list),
      ),
    );
  }
}
