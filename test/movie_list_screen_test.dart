import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_themovie/screens/movie_list_screen.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('MovieListScreen', () {
    testWidgets('Initial state', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(MaterialApp(
        home: MovieListScreen(),
      ));

      // Verify that our MovieListScreen is initialized with loading state.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Fetch movies', (WidgetTester tester) async {
      // Mocking the HTTP response
      final response = http.Response('{"results": []}', 200);
      // Stubbing the http.get method
      http.Client client = MockClient((request) async {
        return response;
      });

      // Build our app and trigger a frame.
      await tester.pumpWidget(MaterialApp(
        home: MovieListScreen(),
      ));

      final movieListScreen = tester.widget<MovieListScreen>(find.byType(MovieListScreen));

     
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
