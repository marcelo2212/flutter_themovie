class Movie {
  final int? id;
  final String? title;
  final String? backdropPath;
  final String? releaseDate;
  final double? voteAverage;
  final int? voteCount;
  final String? overview;
  final List<dynamic>? genres;
  final int? budget;
  final int? revenue;

  Movie({
    this.id,
    this.title,
    this.backdropPath,
    this.releaseDate,
    this.voteAverage,
    this.voteCount,
    this.overview,
    this.genres,
    this.budget,
    this.revenue,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      backdropPath: json['backdrop_path'],
      releaseDate: json['release_date'],
      voteAverage: json['vote_average'].toDouble(),
      voteCount: json['vote_count'],
      overview: json['overview'],
      genres: json['genres'],
      budget: json['budget'],
      revenue: json['revenue'],
    );
  }
}