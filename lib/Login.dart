import 'package:flutter/material.dart';
import 'api_Services.dart';
import 'main.dart';

class Login extends StatelessWidget {
  const Login({super.key});


  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});



  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue),
              ),
            child: TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
      ),
            const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.blue),
        ),
         child:Row(
           children: [
             Expanded(
               child: TextField(
               controller: _passwordController,
               decoration: const InputDecoration(labelText: 'Password'),
               obscureText: _showPassword,
             ),
             ),
             IconButton(
               icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off,
                   color: Colors.blue,
                 ),
               onPressed: (){
                 _showPassword =!_showPassword;
               },
             )
           ],
         )
      ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Đăng nhập thất bại'),
                        content: const Text('Vui lòng nhập tên người dùng và mật khẩu'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  try {
                    Map<String, dynamic> token = await Services.LoginUser(
                      _usernameController.text,
                      _passwordController.text,
                    );
                    if (token != null) {

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AdminUserScreen()),
                      );
                      print('Đăng nhập thành công!');
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Đăng nhập thất bại'),
                            content: const Text('Sai username hoặc password'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  } catch (error) {
                    print('Error: $error');
                  }
                }
              },
              child: const Text('Đăng Nhập'),
            ),
          ],
        ),
      ),
    );
  }
}

