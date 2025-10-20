import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gusto_app/services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Create my account to save & sync',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => authService.signInWithGoogle(),
              child: const Text('Sign in with Google'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => authService.signInWithApple(),
              child: const Text('Sign in with Apple'),
            ),
            const SizedBox(height: 20),
            _EmailPasswordForm(),
          ],
        ),
      ),
    );
  }
}

class _EmailPasswordForm extends ConsumerStatefulWidget {
  @override
  ConsumerState<_EmailPasswordForm> createState() => __EmailPasswordFormState();
}

class __EmailPasswordFormState extends ConsumerState<_EmailPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final authService = ref.read(authServiceProvider);
      if (_isLogin) {
        authService.signInWithEmailAndPassword(
          _emailController.text,
          _passwordController.text,
        );
      } else {
        authService.createUserWithEmailAndPassword(
          _emailController.text,
          _passwordController.text,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (value) =>
                value!.isEmpty ? 'Please enter an email' : null,
          ),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: (value) =>
                value!.length < 6 ? 'Password must be at least 6 characters' : null,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submit,
            child: Text(_isLogin ? 'Login' : 'Sign Up'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _isLogin = !_isLogin;
              });
            },
            child: Text(_isLogin
                ? 'Create an account'
                : 'I already have an account'),
          ),
        ],
      ),
    );
  }
}
