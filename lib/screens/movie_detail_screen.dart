import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_themovie/widget/movie_detail_widget.dart';
import '../services/movie_service.dart';
import 'package:flutter_themovie/models/movie.dart';

class MovieDetailScreen extends StatefulWidget {
  final int movieId;

  MovieDetailScreen({required this.movieId});

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late Future<Movie> _movie;

  @override
  void initState() {
    super.initState();
    _movie = MovieService.fetchMovie(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         title: const Text('Detalhes do Filme', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
         backgroundColor: Theme.of(context).primaryColor,
      ),
      body: FutureBuilder<Movie>(
        future: _movie,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SpinKitCircle(
                color: Colors.blue,
                size: 50.0,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return MovieDetailWidget(movie: snapshot.data!);
          } else {
            return const Center(child: Text('No data'));
          }
        },
      ),
    );
  }
}