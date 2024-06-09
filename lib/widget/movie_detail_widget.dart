import 'package:flutter/material.dart';
import 'package:flutter_themovie/models/movie.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';

class MovieDetailWidget extends StatelessWidget {
  final Movie movie;

  const MovieDetailWidget({super.key, required this.movie});

  String formatCurrency(int? value) {
    if (value != null) {
      final format = NumberFormat.simpleCurrency(locale: 'pt_BR');
      return format.format(value);
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                'https://image.tmdb.org/t/p/w220_and_h330_face/${movie.backdropPath ?? ''}',
                width: 150,
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title ?? '',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      movie.releaseDate != null ? DateFormat.yMMMd('pt_BR').format(DateTime.parse(movie.releaseDate!)) : '',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        CircularPercentIndicator(
                          radius: 40.0,
                          lineWidth: 5.0,
                          percent: movie.voteAverage != null ? movie.voteAverage! / 10 : 0,
                          center: Text('${(movie.voteAverage != null ? (movie.voteAverage! * 10).toInt() : 0)}%'),
                          progressColor: Colors.blue[900] ?? Colors.blue,
                        ),
                        const SizedBox(width: 8.0),
                        Text('(${movie.voteCount ?? 0} votos)'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          const Text(
            'Sinopse',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          Text(movie.overview ?? ''),
          const SizedBox(height: 16.0),
          const Text(
            'Gêneros',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          Wrap(
            spacing: 8.0,
            children: movie.genres != null
                ? movie.genres!.map((genre) => Chip(
                      label: Text(genre['name'] ?? ''),
                      backgroundColor: Colors.blue,
                      labelStyle: const TextStyle(color: Colors.white),
                    )).toList()
                : [],
          ),
          const SizedBox(height: 16.0),
          const Text(
            'Orçamento',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          Text(formatCurrency(movie.budget)),
          const SizedBox(height: 16.0),
          const Text(
            'Bilheteria',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          Text(formatCurrency(movie.revenue)),
        ],
      ),
    );
  }
}
