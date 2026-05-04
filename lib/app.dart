import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/navigation_history_provider.dart';
import 'providers/social_provider.dart';
import 'views/auth_view.dart';
import 'views/create_post_view.dart';
import 'views/group_detail_view.dart';
import 'views/groups_view.dart';
import 'views/home_view.dart';
import 'views/loading_view.dart';
import 'views/post_detail_view.dart';
import 'views/profile_view.dart';

class SocialNetworkApp extends StatefulWidget {
  const SocialNetworkApp({super.key});

  @override
  State<SocialNetworkApp> createState() => _SocialNetworkAppState();
}

class _SocialNetworkAppState extends State<SocialNetworkApp> {
  GoRouter? _router;
  AuthProvider? _authProvider;
  SocialProvider? _socialProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final authProvider = context.read<AuthProvider>();
    final socialProvider = context.read<SocialProvider>();

    if (_router == null || _authProvider != authProvider || _socialProvider != socialProvider) {
      _authProvider = authProvider;
      _socialProvider = socialProvider;
      _router = _buildRouter(authProvider, socialProvider);
    }
  }

  GoRouter _buildRouter(AuthProvider authProvider, SocialProvider socialProvider) {
    return GoRouter(
      initialLocation: '/loading',
      refreshListenable: Listenable.merge(<Listenable>[authProvider, socialProvider]),
      redirect: (context, state) {
        final location = state.matchedLocation;

        // Отслеживаем навигацию
        try {
          context.read<NavigationHistoryProvider>().push(location);
        } catch (_) {
          // Provider недоступен
        }

        if (authProvider.isBootstrapping || socialProvider.isLoading) {
          return location == '/loading' ? null : '/loading';
        }

        if (!authProvider.isAuthenticated) {
          return location == '/auth' ? null : '/auth';
        }

        if (location == '/auth' || location == '/loading' || location == '/') {
          return '/home';
        }

        return null;
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/loading',
          builder: (context, state) => const LoadingView(),
        ),
        GoRoute(
          path: '/auth',
          builder: (context, state) => const AuthView(),
        ),
        GoRoute(
          path: '/',
          redirect: (context, state) => '/home',
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeView(),
        ),
        GoRoute(
          path: '/groups',
          builder: (context, state) => const GroupsView(),
        ),
        GoRoute(
          path: '/create',
          builder: (context, state) => const CreatePostView(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileView(),
        ),
        GoRoute(
          path: '/group/:id',
          builder: (context, state) => GroupDetailView(
            groupId: state.pathParameters['id'] ?? '',
          ),
        ),
        GoRoute(
          path: '/post/:id',
          builder: (context, state) => PostDetailView(
            postId: state.pathParameters['id'] ?? '',
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final router = _router;
    if (router == null) {
      return const MaterialApp(home: LoadingView());
    }

    return MaterialApp.router(
      title: 'Соцсеть группы',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  AuthProvider? _authProvider;
  SocialProvider? _socialProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }
      _authProvider = context.read<AuthProvider>();
      _socialProvider = context.read<SocialProvider>();
      await _authProvider!.initialize();
      if (!mounted) {
        return;
      }
      if (_authProvider!.isAuthenticated) {
        await _socialProvider!.initialize();
      }
      _authProvider!.addListener(_onAuthChanged);
    });
  }

  void _onAuthChanged() {
    final auth = _authProvider;
    final social = _socialProvider;
    if (auth == null || social == null) {
      return;
    }
    if (auth.isAuthenticated && !social.isLoading) {
      social.initialize();
    }
  }

  @override
  void dispose() {
    _authProvider?.removeListener(_onAuthChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SocialNetworkApp();
  }
}


