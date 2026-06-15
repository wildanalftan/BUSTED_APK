import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/users_provider.dart';
import '../../domain/entities/user.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _password = '';
  bool _isLoading = false;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      final newUser = UserEntity(
        name: _name,
        email: _email,
        password: _password,
        isAdmin: false,
        isBlocked: false,
      );

      final success =
          await ref.read(usersProvider.notifier).registerUser(newUser);

      setState(() => _isLoading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account Created! Please login.'),
            duration: Duration(seconds: 2),
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email or Username already registered!'),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          // ── Angular decorations (no circles) ──────────────────────────
          Positioned(
            top: -60,
            left: -80,
            child: _SplashShard(
              width: 260,
              height: 260,
              color: cs.secondary.withOpacity(0.15),
              angle: 0.2,
            ),
          ),
          Positioned(
            bottom: -40,
            right: -60,
            child: _SplashShard(
              width: 200,
              height: 200,
              color: cs.primary.withOpacity(0.12),
              angle: -0.3,
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
                        'Join The\nNew Era.',
                        style: tt.displayLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          letterSpacing: -1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Create your account and unlock the future.',
                        style: tt.bodyLarge?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 48),
                      TextFormField(
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter your name'
                            : null,
                        onSaved: (value) => _name = value ?? '',
                        decoration: InputDecoration(
                          hintText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outline,
                              color: cs.onSurfaceVariant),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        validator: (value) => value == null ||
                                value.isEmpty ||
                                !value.contains('@')
                            ? 'Please enter a valid email'
                            : null,
                        onSaved: (value) => _email = value ?? '',
                        decoration: InputDecoration(
                          hintText: 'Email address',
                          prefixIcon: Icon(Icons.email_outlined,
                              color: cs.onSurfaceVariant),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        validator: (value) => value == null || value.length < 6
                            ? 'Password must be at least 6 characters'
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
                        onPressed: _isLoading ? null : _register,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Text('Sign Up',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
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

// ── Shared angular splash shard ────────────────────────────────────────────────
class _SplashShard extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final double angle;

  const _SplashShard(
      {required this.width,
      required this.height,
      required this.color,
      required this.angle});

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
              colors: [color, color.withOpacity(0)],
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
