import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_themovie/models/movie.dart';

class MovieService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _apiKey =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI5YzE2Yzg5NmQ1NDk1NjcwZjVkZjAxMDRiOWFlN2M4OCIsInN1YiI6IjY2NjA4N2UyZDdmYjFjMDFhZDI0NDUyZCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.sLL7iIc1aFZ_pni_KWSOfvUUuPPQnomdArPLXyLkIt4';

  /// FUNÇÃO PARA RETORNAR OS DADOS DO FILME SELECIONADO
  static Future<Movie> fetchMovie(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/movie/$id?language=pt-BR'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
      },
    );

    if (response.statusCode == 200) {
      return Movie.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load movie');
    }
  }

  /// FUNÇÃO PARA CONSULTAR A LISTA DE FILMES
  static Future<List<Movie>> listMovies(
    int page, {
    required String sortBy,
    DateTime? fromDate,
    DateTime? toDate,
    String? certification,
    String? genres,
    String? language,
  }) async {
    String url =
        '$_baseUrl/discover/movie?include_adult=false&include_video=false&language=pt-BR&sort_by=$sortBy&page=$page';

    if (fromDate != null && toDate != null) {
      url = '$url&release_date.gte=$fromDate&release_date.lte=$toDate';
    }

    if (certification != null) {
      url = '$url&certification=$certification';
    }

    if (language != null && language != 'all') {
      url = '$url&with_original_language=$language';
    }

    if (genres != null) {
      url = '$url&with_genres=$genres';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_apiKey',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<Movie> movies = (data['results'] as List<dynamic>)
          .map((movieData) => Movie.fromJson(movieData))
          .toList();
      return movies;
    } else {
      throw Exception('Failed to load movies');
    }
  }

  /// FUNÇÃO PARA RETORNAR TODAS AS CLASSIFICAÇÕES ETÁRIAS
  static Future<List<String>> fetchCertifications() async {
    const url = '$_baseUrl/certification/movie/list';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_apiKey',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final certifications = data['certifications']['BR'] as List;
      return certifications
          .map((cert) => cert['certification'] as String)
          .toList();
    } else {
      throw Exception('Erro ao buscar as classificações etárias');
    }
  }

  /// FUNÇÃO PARA RETORNAR TODAS AS CLASSIFICAÇÕES ETÁRIAS
  static Future<List<dynamic>> fetchGenres() async {
    const url = '$_baseUrl/genre/movie/list?language=pt-BR';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_apiKey',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['genres'];
    } else {
      throw Exception('Erro ao carregar gêneros');
    }
  }

  /// FUNÇÃO PARA RETORNAR TODOS OS IDIOMAS
  static Future<List<dynamic>> fetchLanguages() async {
    const url = '$_baseUrl/configuration/languages';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_apiKey',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data as List)
          .where((language) => language['name'] != null && language['name'] != '')
          .toList();
    } else {
      throw Exception('Erro ao carregar os idiomas');
    }
  }

  /// FUNÇÃO PARA RETORNAR AS PALAVRAS CHAVES DE ACORDO COM OS CARACTERES DIGITADOS PELO USUÁRIO
  static Future<List<dynamic>> searchKeywords(String inputData) async {
    final url = '$_baseUrl/search/keyword?query=$inputData';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_apiKey',
      },
    );
    if (response.statusCode == 200) {
      final rs = json.decode(response.body);
      return rs['results'];
    } else {
      throw Exception('Erro ao carregar as palavras chaves');
    }
  }
}
