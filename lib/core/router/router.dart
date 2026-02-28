import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';

// Importa tus pantallas
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/events/presentation/screens/events_screen.dart';
import '../../features/polls/presentation/screens/polls_screen.dart';
import '../../features/members/presentation/screens/members_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../shared/widgets/scaffold_with_navbar.dart';
import '../../features/polls/presentation/screens/create_poll_screen.dart';
import '../../features/events/presentation/screens/create_event_screen.dart'; // <--- AÑADE ESTO
import '../../features/events/domain/models/event_model.dart'; // <--- AÑADE ESTO
import '../../features/events/presentation/screens/event_detail_screen.dart'; // <--- AÑADE EST
import '../../features/admin/presentation/screens/admin_screen.dart';
import '../../features/admin/presentation/screens/family_screen.dart';

// Clave global para el navegador raíz (para diálogos o login full screen)
final _rootNavigatorKey = GlobalKey<NavigatorState>();
// Clave para la navegación dentro de las pestañas
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/', // Inicia en Home
    redirect: (context, state) {
      if (authState.isLoading || authState.hasError) return null;
      final isLoggedIn = authState.value != null;
      final isLoggingIn = state.uri.toString() == '/login';

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/';
      return null;
    },
    routes: [
      // Ruta Login (Fuera del Shell, pantalla completa)
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      // Ruta para crear encuestas (Pantalla completa, fuera del navbar)
      GoRoute(
        path: '/create-poll',
        parentNavigatorKey: _rootNavigatorKey, // <-- Esto asegura que cubra la barra inferior
        builder: (context, state) => const CreatePollScreen(),
      ),

      // Ruta para crear eventos
      GoRoute(
        path: '/create-event',
        parentNavigatorKey: _rootNavigatorKey, 
        builder: (context, state) => const CreateEventScreen(),
      ),

      GoRoute(
        path: '/event-detail',
        parentNavigatorKey: _rootNavigatorKey, // Para que ocupe la pantalla entera (sobre la navbar)
        builder: (context, state) {
          // Extraemos el evento que le hemos pasado por parámetro
          final event = state.extra as EventModel; 
          return EventDetailScreen(event: event);
        },
      ),

      GoRoute(
        path: '/admin',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdminScreen(),
      ),

      GoRoute(
        path: '/family',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const FamilyScreen(),
      ),

      // SHELL ROUTE (Barra de navegación persistente)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // 1. Rama Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // 2. Rama Eventos
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/events',
                builder: (context, state) => const EventsScreen(),
              ),
            ],
          ),
          // 3. Rama Votaciones
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/votings',
                builder: (context, state) => const PollsScreen(),
              ),
            ],
          ),
          // 4. Rama Miembros
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/members',
                builder: (context, state) => const MembersScreen(),
              ),
            ],
          ),
          // 5. Rama Perfil
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});