import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../data/services/member_api_service.dart';
import '../data/services/member_service.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/tmdb_movie_service.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/movie_detail_screen.dart';
import '../screens/movie_list_screen.dart';
import '../screens/my_ratings_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/sign_up_screen.dart';
import '../screens/start_screen.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/edit_profile_view_model.dart';
import '../view_models/movie_detail_view_model.dart';
import '../view_models/movie_home_view_model.dart';
import '../view_models/paged_movies_view_model.dart';
import '../view_models/my_ratings_view_model.dart';
import '../view_models/sign_up_view_model.dart';
import '../widgets/main_screen.dart';
import '../widgets/movielog_button.dart';
import '../core/session/session_guard.dart';
import '../data/services/favorite_api_service.dart';
import '../view_models/favorite_detail_view_model.dart';
import '../screens/favorites_screen.dart';
import '../view_models/favorites_view_model.dart';
import '../screens/movie_search_screen.dart';

String? authRedirect(AuthStatus status, String location) {
  const publicPaths = {'/login', '/register'};
  final atStart = location == '/start';
  final atPublic = publicPaths.contains(location);

  return switch (status) {
    // 토큰 확인 중이거나 확인 실패(재시도 버튼)
    AuthStatus.initializing ||
    AuthStatus.retryRequired => atStart ? null : '/start',
    // 로그아웃 또는 로그인 요청 중
    AuthStatus.signedOut ||
    AuthStatus.authenticating => atPublic ? null : '/login',
    // 로그인됨
    AuthStatus.signedIn => (atStart || atPublic) ? '/home' : null,
  };
}

class AppRouter {
  AppRouter._();

  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter(AuthViewModel authViewModel) {
    return GoRouter(
      initialLocation: '/start',
      navigatorKey: rootNavigatorKey,
      refreshListenable: authViewModel,
      redirect: (context, state) {
        return authRedirect(authViewModel.status, state.uri.path);
      },
      routes: [
        GoRoute(
          path: '/start',
          builder: (context, state) {
            final auth = context.watch<AuthViewModel>();
            return StartScreen(
              message: auth.message,
              onRetry: auth.status == AuthStatus.retryRequired
                  ? auth.restoreSession
                  : null,
            );
          },
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => ChangeNotifierProvider<SignUpViewModel>(
            create: (context) => SignUpViewModel(context.read<MemberService>()),
            child: const SignUpScreen(),
          ),
        ),
        GoRoute(
          path: '/movies/search',
          builder: (context, state) =>
              ChangeNotifierProvider<PagedMoviesViewModel>(
                // 영화 목록과 별도의 인스턴스입니다.
                create: (context) => PagedMoviesViewModel(
                  tmdbApi: context.read<TmdbMovieService>(),
                ),
                child: const MovieSearchScreen(),
              ),
        ),
        GoRoute(
          path: '/movies/:movieId',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['movieId'] ?? '');
            final extra = state.extra;
            final movie = extra is TmdbMovieDto && extra.id == id
                ? extra
                : null;

            if (movie == null) {
              return MovieDetailScreen(movieId: id);
            }

            // 내 정보가 준비되고 현재 세션과 일치할 때까지 로딩을 보여 줍니다.
            final member = context.watch<AuthViewModel>().member;
            final guard = context.read<SessionGuard>();
            if (member == null || guard.accountId != member.email) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            return MultiProvider(
              // 계정이나 세션이 바뀌면 이전 ViewModel을 버리고 새로 만듭니다.
              key: ValueKey('${member.email}:${guard.generation}'),
              providers: [
                ChangeNotifierProvider<MovieDetailViewModel>(
                  create: (context) => MovieDetailViewModel(
                    context.read<RatingApiService>(),
                    context.read<AuthViewModel>(),
                    context.read<MyRatingsViewModel>(),
                    movie,
                  ),
                ),
                ChangeNotifierProvider<FavoriteDetailViewModel>(
                  create: (context) => FavoriteDetailViewModel(
                    movieId: movie.id,
                    favoriteApi: context.read<FavoriteApiService>(),
                    sessionGuard: guard,
                    accountId: member.email,
                    onSessionExpired: context
                        .read<AuthViewModel>()
                        .expireSession,
                  ),
                ),
              ],
              child: MovieDetailScreen(movieId: id, movie: movie),
            );
          },
        ),
        ShellRoute(
          builder: (context, state, child) {
            return MainScreen(
              currentIndex: indexFromLocation(state.uri.path),
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) =>
                  ChangeNotifierProvider<MovieHomeViewModel>(
                    lazy: false,
                    create: (context) =>
                        MovieHomeViewModel(context.read<TmdbMovieService>())
                          ..loadPopular(),
                    child: const HomeScreen(),
                  ),
            ),
            GoRoute(
              path: '/movies',
              builder: (context, state) =>
                  ChangeNotifierProvider<PagedMoviesViewModel>(
                    create: (context) =>
                        PagedMoviesViewModel(
                            tmdbApi: context.read<TmdbMovieService>(),
                          )
                          ..loadGenres()
                          ..loadInitial(),
                    child: const MovieListScreen(),
                  ),
            ),
            GoRoute(
              path: '/my',
              builder: (context, state) => const ProfileScreen(),
              routes: [
                GoRoute(
                  path: 'ratings',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) => const MyRatingsScreen(),
                ),
                GoRoute(
                  path: 'profile/edit',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) {
                    final auth = context.watch<AuthViewModel>();
                    if (auth.member == null) {
                      return Scaffold(
                        appBar: AppBar(
                          centerTitle: true,
                          title: const Text('프로필 수정'),
                        ),
                        body: Center(
                          child: auth.memberStatus == MemberLoadStatus.error
                              ? MovieLogButton(
                                  label: '다시 시도',
                                  onPressed: () => auth.loadMember(force: true),
                                )
                              : const CircularProgressIndicator(),
                        ),
                      );
                    }
                    return ChangeNotifierProvider<EditProfileViewModel>(
                      create: (context) => EditProfileViewModel(
                        context.read<MemberApiService>(),
                        auth,
                      ),
                      child: const EditProfileScreen(),
                    );
                  },
                ),
                GoRoute(
                  path: 'favorites',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) {
                    final auth = context.watch<AuthViewModel>();
                    final member = auth.member;
                    final guard = context.read<SessionGuard>();

                    if (member == null) {
                      return Scaffold(
                        appBar: AppBar(
                          centerTitle: true,
                          title: const Text('내 즐겨찾기'),
                        ),
                        body: Center(
                          child: auth.memberStatus == MemberLoadStatus.error
                              ? MovieLogButton(
                                  label: '다시 시도',
                                  onPressed: () => auth.loadMember(force: true),
                                )
                              : const CircularProgressIndicator(),
                        ),
                      );
                    }
                    if (guard.accountId != member.email) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }

                    return ChangeNotifierProvider<FavoritesViewModel>(
                      // 계정이 바뀌면 이전 사용자의 목록을 버리고 새로 생성
                      key: ValueKey('${member.email}:${guard.generation}'),
                      create: (context) => FavoritesViewModel(
                        favoriteApi: context.read<FavoriteApiService>(),
                        tmdbApi: context.read<TmdbMovieService>(),
                        sessionGuard: guard,
                        accountId: member.email,
                        onSessionExpired: context
                            .read<AuthViewModel>()
                            .expireSession,
                      ),
                      child: const FavoritesScreen(),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static int indexFromLocation(String path) {
    if (path.startsWith('/movies')) return 1;
    if (path.startsWith('/my')) return 2;
    return 0;
  }
}
