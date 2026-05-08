import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _signInKey = GlobalKey<FormState>();
  final _signUpKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Вход в соцсеть группы'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Tab>[
            Tab(text: 'Вход'),
            Tab(text: 'Регистрация'),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              if (auth.errorMessage != null) ...<Widget>[
                MaterialBanner(
                  content: Text(auth.errorMessage!),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => context.read<AuthProvider>().clearError(),
                      child: const Text('Закрыть'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    _buildSignInForm(context, auth),
                    _buildSignUpForm(context, auth),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignInForm(BuildContext context, AuthProvider auth) {
    return Form(
      key: _signInKey,
      child: ListView(
        children: <Widget>[
          const Text('Войдите, чтобы публиковать посты, лайкать и писать комментарии.'),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            validator: _validateEmail,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Пароль',
              border: OutlineInputBorder(),
            ),
            validator: _validatePassword,
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: auth.isSubmitting ? null : () { _submitSignIn(context); },
            child: auth.isSubmitting ? const CircularProgressIndicator() : const Text('Войти'),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpForm(BuildContext context, AuthProvider auth) {
    return Form(
      key: _signUpKey,
      child: ListView(
        children: <Widget>[
          const Text('Регистрация создаёт профиль в Supabase и сохраняет имя пользователя в базе.'),
          const SizedBox(height: 16),
          TextFormField(
            controller: _displayNameController,
            decoration: const InputDecoration(
              labelText: 'Имя',
              border: OutlineInputBorder(),
            ),
            validator: (value) => (value == null || value.trim().length < 2) ? 'Введите имя' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Никнейм (необязательно)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            validator: _validateEmail,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Пароль',
              border: OutlineInputBorder(),
            ),
            validator: _validatePassword,
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: auth.isSubmitting ? null : () { _submitSignUp(context); },
            child: auth.isSubmitting ? const CircularProgressIndicator() : const Text('Зарегистрироваться'),
          ),
        ],
      ),
    );
  }

  String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty || !text.contains('@')) {
      return 'Введите корректный email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').trim().length < 6) {
      return 'Пароль должен быть не короче 6 символов';
    }
    return null;
  }

  Future<void> _submitSignIn(BuildContext context) async {
    if (!_signInKey.currentState!.validate()) {
      return;
    }
    final auth = context.read<AuthProvider>();
    await auth.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
  }

  Future<void> _submitSignUp(BuildContext context) async {
    if (!_signUpKey.currentState!.validate()) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final auth = context.read<AuthProvider>();
    final success = await auth.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      displayName: _displayNameController.text.trim(),
      username: _usernameController.text.trim().isEmpty ? null : _usernameController.text.trim(),
    );
    if (!mounted || !success) {
      return;
    }
    messenger.showSnackBar(
      const SnackBar(content: Text('Регистрация выполнена. Теперь войдите или дождитесь подтверждения email.')),
    );
    _tabController.animateTo(0);
  }
}



