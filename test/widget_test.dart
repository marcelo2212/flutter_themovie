import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_themovie/screens/movie_list_screen.dart';

void main() async {
  await initializeDateFormatting('pt_BR', null);

  testWidgets('Movie List Screen Widget Test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    expect(find.text('Themo Movie DB'), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(CustomScrollView), findsOneWidget);
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MovieListScreen(),
    );
  }
}
