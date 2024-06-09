import 'dart:convert';
import 'package:flutter_themovie/services/movie_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('MovieService', () {
    test('fetchMovie returns Movie object when successful', () async {
      final response = http.Response(
        jsonEncode({'id': 123, 'title': 'Sample Movie'}),
        200,
      );
      http.Client client = MockClient((request) async {
        return response;
      });

 

      final movie = await MovieService.fetchMovie(123);

      expect(movie.id, 123);
      expect(movie.title, 'Sample Movie');
    });

    test('fetchMovie throws Exception on failure', () async {
      final response = http.Response('Error message', 404);
      http.Client client = MockClient((request) async {
        return response;
      });

      
      expect(
        () async => await MovieService.fetchMovie(123),
        throwsException,
      );
    });

   
  });
}
