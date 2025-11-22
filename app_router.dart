import 'package:flutter/material.dart';
import 'package:lotus_mobile/pages/home_page.dart';
import 'package:lotus_mobile/pages/login_page.dart';
import 'package:lotus_mobile/providers/auth_provider.dart';
import 'package:lotus_mobile/services/storage_service.dart';
import 'package:provider/provider.dart';

class AppRouter extends StatelessWidget{
  const AppRouter({super.key});
  
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen:false);

    return FutureBuilder<bool>(
      future: auth.loadUser(), 
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting){
          return Scaffold(
            body: Center(child: Image.asset('assets/images/logotipo_lotusplan_p.png'),)
          );
        }

        if(snapshot.hasData && snapshot.data == true) {
          return HomePage(user: auth.currentUser!);
        } else {
          return const LoginPage();
        }
      }
    );
  }

  
}