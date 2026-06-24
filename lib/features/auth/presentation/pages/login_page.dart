// Contributor: Farhanfzlwargzl
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/users_provider.dart';
import '../../domain/entities/user.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final errorMsg = await ref.read(currentUserProvider.notifier).loginWithCredentials(_email, _password);
      
      if (!mounted) return;

      if (errorMsg != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(errorMsg),
              backgroundColor: Colors.redAccent),
        );
        return;
      }

      // Check state for routing
      final currentUser = ref.read(currentUserProvider);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome back, ${currentUser?.name ?? "User"}!'),
          duration: const Duration(seconds: 2),
        ),
      );

      if (currentUser?.isAdmin == true) {
        context.go('/admin');
      } else {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(usersProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // ── Diagonal spray-paint slash decoration ──────────────────────
          // Replaces BoxShape.circle — uses sharp angular clip instead
          Positioned(
            top: -60,
            right: -80,
            child: _SplashShard(
              width: 280,
              height: 280,
              color: cs.primary.withValues(alpha: isDark ? 0.25 : 0.18),
              angle: 0.35,
            ),
          ),
          Positioned(
            bottom: -60,
            left: -80,
            child: _SplashShard(
              width: 240,
              height: 240,
              color: cs.secondary.withValues(alpha: isDark ? 0.15 : 0.20),
              angle: -0.25,
            ),
          ),
          // ── Main content ───────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'BUSTED\nWORLD.',
                        style: tt.displayLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          letterSpacing: -1.5,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Enter the new era of shopping.',
                        style: tt.bodyLarge?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 48),
                      TextFormField(
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter your username or email'
                            : null,
                        onSaved: (value) => _email = value ?? '',
                        decoration: InputDecoration(
                          hintText: 'Username or Email',
                          prefixIcon: Icon(Icons.person_outline,
                              color: cs.onSurfaceVariant),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        validator: (value) =>
                            value == null || value.length < 3
                                ? 'Password must be at least 3 characters'
                                : null,
                        onSaved: (value) => _password = value ?? '',
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline,
                              color: cs.onSurfaceVariant),
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _login,
                        child: const Text('Sign In',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          // Admin bypass for testing
                          final users = ref.read(usersProvider);
                          final adminUser = users.firstWhere(
                            (u) => u.isAdmin,
                            orElse: () => UserEntity(
                                name: 'Administrator',
                                email: 'admin',
                                password: 'admin',
                                isAdmin: true),
                          );
                          ref
                              .read(currentUserProvider.notifier)
                              .login(adminUser);
                          context.go('/admin');
                        },
                        child: Text('Admin Login Test',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: cs.primary)),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: () => context.push('/register'),
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(color: cs.onSurfaceVariant),
                              children: [
                                TextSpan(
                                  text: 'Sign up',
                                  style: TextStyle(
                                      color: cs.primary,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Angular "Spray Splash" Shard ─────────────────────────────────────────────
// Pengganti BoxShape.circle — bentuk jajar genjang miring khas street art
class _SplashShard extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final double angle;

  const _SplashShard({
    required this.width,
    required this.height,
    required this.color,
    required this.angle,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: ClipPath(
        clipper: _ParallelogramClipper(),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );
  }
}

class _ParallelogramClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final offset = size.width * 0.25;
    path.moveTo(offset, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width - offset, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_ParallelogramClipper oldClipper) => false;
}
