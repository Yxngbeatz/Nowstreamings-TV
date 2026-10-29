import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const NowstreamigsApp());
}

class NowstreamigsApp extends StatelessWidget {
  const NowstreamigsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nowstreamigs TV',
      theme: ThemeData.dark(),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _urlController = TextEditingController();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final url = _urlController.text.trim();
    final username = _userController.text.trim();
    final password = _passController.text.trim();

    if (url.isEmpty || username.isEmpty || password.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Por favor, preencha todos os campos.';
      });
      return;
    }

    try {
      final formattedUrl = url.endsWith('/') ? url : '$url/';
      final loginUrl = Uri.parse('${formattedUrl}player_api.php?username=$username&password=$password');
      
      final response = await http.get(loginUrl).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['user_info'] != null && data['user_info']['auth'] == 1) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(userInfo: data['user_info']),
            ),
          );
        } else {
          setState(() {
            _errorMessage = 'Dados de acesso incorretos.';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Erro ao ligar ao servidor IPTV.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro de ligação: Verifique o URL.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nowstreamigs TV - Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('NOWSTREAMIGS TV', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                  controller: _urlController,
                  decoration: const InputDecoration(labelText: 'URL do Servidor (ex: http://provider.com:8080)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _userController,
                  decoration: const InputDecoration(labelText: 'Utilizador', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Palavra-passe', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                if (_errorMessage.isNotEmpty)
                  Text(_errorMessage, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 10),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                        child: const Text('Entrar'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final Map<String, dynamic> userInfo;
  const HomeScreen({super.key, required this.userInfo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bem-vindo, ${userInfo['username'] ?? 'Utilizador'}')),
      body: const Center(
        child: Text('Login efetuado com sucesso!\nPainel IPTV pronto.', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
