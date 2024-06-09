import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_themovie/models/movie.dart';
import 'package:flutter_themovie/widget/movie_detail_widget.dart';


void main() {
  testWidgets('MovieDetailWidget displays correct movie details', (WidgetTester tester) async {
    final Movie movie = Movie(
      title: 'Sample Movie',
      releaseDate: '2022-01-01',
      voteAverage: 8.5,
      voteCount: 100,
      overview: 'This is a sample movie overview.',
      genres: [
        {'name': 'Action'},
        {'name': 'Adventure'},
        {'name': 'Sci-Fi'},
      ],
      budget: 1000000,
      revenue: 5000000,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MovieDetailWidget(movie: movie),
        ),
      ),
    );

    expect(find.text('Sample Movie'), findsOneWidget);
    expect(find.text('1 de jan de 2022'), findsOneWidget);
    expect(find.text('85%'), findsOneWidget);
    expect(find.text('(100 votos)'), findsOneWidget);
    expect(find.text('This is a sample movie overview.'), findsOneWidget);
    expect(find.text('Action'), findsOneWidget);
    expect(find.text('Adventure'), findsOneWidget);
    expect(find.text('Sci-Fi'), findsOneWidget);
    expect(find.text('R\$ 1,000,000'), findsOneWidget);
    expect(find.text('R\$ 5,000,000'), findsOneWidget);
  });
}
