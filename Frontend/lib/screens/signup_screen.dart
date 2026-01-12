import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharing_items/main_shell.dart';
import 'package:sharing_items/screens/login_screen.dart';
import 'package:sharing_items/src/service/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose(){
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    final username = usernameController.text.trim();
    final password = passwordController.text;

    if(username.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('아이디를 입력해 주세요.')),
      );
      return;
    }

    if(password.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호를 입력해 주세요.')),
      );
      return;
    }

    setState(() => _loading = true);

    final auth = context.read<AuthService>();
    await auth.signUp(
      username: username,
      password: password,
      onSuccess: () {
        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입 성공')),
        );
        /// 옵션1: 로그인 화면으로 복귀
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );

        /*
        /// 옵션2: 바로 메인화면으로 보내기
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainShell()),
        );
         */
      },
      onError: (err) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err)),
        );
      },
    );

    if(mounted){
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              '회원가입',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          toolbarHeight: 120.0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '아이디',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(hintText: "아이디"),
            ),

            const SizedBox(height: 20),

            const Text(
              '비밀번호',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              obscureText: true, /// 비밀번호 안보이게
              decoration: InputDecoration(hintText: "비밀번호"),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Colors.black, width: 1),
                  ),
                  elevation: 0,
                ),
                onPressed: _loading ? null : _signup,
                child: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        '회원가입 완료',
                        style: TextStyle(fontSize: 22),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
