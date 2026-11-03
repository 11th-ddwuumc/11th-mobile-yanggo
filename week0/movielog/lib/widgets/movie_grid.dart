import 'package:flutter/material.dart';

import '../data/models/tmdb_movie_dto.dart';
import 'tmdb_movie_card.dart';

class MovieGrid extends StatelessWidget {
  const MovieGrid({super.key, required this.movies, required this.genreNames});

  final List<TmdbMovieDto> movies;
  final Map<int, String> genreNames;

  String _subtitle(TmdbMovieDto movie) {
    final year = movie.releaseYear;
    final genre = movie.genreIds.isEmpty
        ? null
        : genreNames[movie.genreIds.first];
    return [?year, ?genre].join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: movies.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 24,
        childAspectRatio: 0.5,
      ),
      itemBuilder: (context, index) {
        final movie = movies[index];
        return TmdbMovieCard(
          movie: movie,
          width: double.infinity,
          showRatingBadge: true,
          subtitle: _subtitle(movie),
        );
      },
    );
  }
}
