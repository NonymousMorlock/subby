part of 'router.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, state) => const HomeView()),
  ],
);
