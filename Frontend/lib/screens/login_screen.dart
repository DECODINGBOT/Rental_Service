import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sharing_items/main_shell.dart';
import 'package:sharing_items/src/service/auth_service.dart';

/// 로그인 페이지
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(builder: (context, authService, child) {
      final user = authService.currentUser();
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: AppBar(
            centerTitle: true,
            title: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                user == null ? "로그인 해주세요 🙂" : "${user.email}님 안녕하세요 👋",
                //"로그인 해주세요",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            toolbarHeight: 120.0,
            backgroundColor: const Color(0xFF4A5A73)
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// 이메일
              TextField(
                controller: emailController,
                decoration: InputDecoration(hintText: "이메일"),
              ),
        
              /// 비밀번호
              TextField(
                controller: passwordController,
                obscureText: false, // 비밀번호 안보이게
                decoration: InputDecoration(hintText: "비밀번호"),
              ),
              SizedBox(height: 40),

              ///로그인, 회원가입, 구글, 카카오 버튼
              loginButtons(authService),
            ],
          ),
        ),
      );
    },);
  }

  Widget loginButtons(AuthService authService){
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              signInButton(authService),
              const SizedBox(height: 12),
              signUpButton(authService),
              const SizedBox(height: 100),
              signInWithGoogle(),
              const SizedBox(height: 12),
              signInWithKakao(),
              const SizedBox(height: 12),
            ],
          )
        );
      },
    );
  }

  Widget signInButton(AuthService authService) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A5A73),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Text(
          "로그인",
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        onPressed: () {
          // 로그인
          authService.signIn(
            email: emailController.text,
            password: passwordController.text,
            onSuccess: () {
              // 로그인 성공
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("로그인 성공"),
              ));
              // MainShell로 이동
              
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainShell()),
              );
              
              //Navigator.pushReplacementNamed(context, '/home');
            },
            onError: (err) {
              // 에러 발생
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(err),
              ));
            },
          );
        },
      ),
    );
  }

  Widget signUpButton(AuthService authService) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A5A73),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: const Text(
          "회원가입",
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        onPressed: () {
          // 회원가입
          authService.signUp(
            email: emailController.text,
            password: passwordController.text,
            onSuccess: () {
              // 회원가입 성공
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("회원가입 성공"),
              ));
            },
            onError: (err) {
              // 에러 발생
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
		            content: Text(err),
		          ));
            },
          );
        },
      ),
    );
  }
  
  Widget signInWithGoogle() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF5EFE7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/google_logo.svg',
              height: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              '구글로 로그인 하기',
              style: TextStyle(
                fontSize: 24,
                color: Color(0xFF213555),
              ),
            ),
          ],
        ),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainShell()),
          );
          //Navigator.pushReplacementNamed(context, '/home');
        },
      ),
    );
  }

  Widget signInWithKakao() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFEE500),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/kakao_logo.svg',
              height: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              '카카오로 로그인 하기',
              style: TextStyle(
                fontSize: 24,
                color: Color(0xFF213555),
              ),
            ),
          ],
        ),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainShell()),
          );
          //Navigator.pushReplacementNamed(context, '/home');
        },
      ),
    );
  }
}