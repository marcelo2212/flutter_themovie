import 'package:flutter/material.dart';
import 'screens/movie_list_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

	void main() async{
    await initializeDateFormatting('pt_BR', null);
	  runApp(MyApp());
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