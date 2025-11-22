import 'package:flutter/material.dart';
import 'package:lotus_mobile/database/database.dart';
import 'package:lotus_mobile/database/daos/usuario_dao.dart';
import 'package:provider/provider.dart';
import 'package:lotus_mobile/pages/home_page.dart';
import 'package:lotus_mobile/providers/auth_provider.dart';
import 'package:lotus_mobile/services/login_service.dart';
import 'package:lotus_mobile/services/storage_service.dart';
import '../../../widgets/custom_input_field.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController senhaController = TextEditingController();
  final LoginService _loginService = LoginService();
  String? _errorMessage;
  final StorageService _storageService = StorageService();
  final database = AppDatabase();
  bool _loading = false;

  Future<void> _login() async {
    final email = emailController.text.trim();
    final senha = senhaController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      setState(() {
        _errorMessage = "Usuário/senha inválido";
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.login(email, senha);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage(user: auth.currentUser!)),
      );
    } catch (e) {
      setState(() => _errorMessage = "Usuário/senha inválido");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logotipo_lotusplan_p.png',
                    width: 190,
                    height: 100,
                    filterQuality: FilterQuality.high,
                  ),
                  SizedBox(height: 25),
                  const Text(
                    'Entrar na Conta',
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'Boomer',
                      fontWeight: FontWeight.w900,
                      color: Color.fromRGBO(75, 79, 92, 0.856),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 10.0,
                      left: 25.0,
                      right: 25.0,
                      top: 10.0,
                    ),
                    child: Text(
                      'Seja bem vindo de volta! Preencha os dados da sua conta.',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Boomer',
                        fontWeight: FontWeight.w700,
                        color: Color.fromRGBO(75, 79, 92, 0.856),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  CustomInputField(
                    label: "Email*",
                    controller: emailController,
                  ),
                  const SizedBox(height: 10),
                  PasswordField(
                    label: "Senha*",
                    controller: senhaController,
                  ),
                  SizedBox(
                    height: 60,
                    child: Padding(
                      padding: EdgeInsets.only(top: 15, bottom: 15),
                      child: _errorMessage != null
                          ? Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 20,
                                fontFamily: 'Boomer',
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          : const Text(""),
                    ),
                  ),
                  FilledButton(
                    onPressed: _login,
                    style: FilledButton.styleFrom(
                      minimumSize: Size(250, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Color(0xFF2C2E35),
                    ),
                    child: const Text(
                      'LOGIN',
                      style: TextStyle(
                        fontFamily: 'Boomer',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_loading)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Image.asset(
                    'assets/images/loading-screen-spinner.gif',
                    width: 80,
                    height: 80,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
