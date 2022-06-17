import 'package:admin/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late Animation<double> containerSize;

  late AnimationController animationController;

  Duration animationDuration = Duration(milliseconds: 270);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: animationDuration);
  }

  @override
  Widget build(BuildContext context) {
    Size _deviceSize = MediaQuery.of(context).size;
    double viewInset = MediaQuery.of(context)
        .viewInsets
        .bottom; //using this to determine whether keyboard is opened or not
    double defaultLoginSize = _deviceSize.height - (_deviceSize.height * 0.2);
    double defaultRegisterSize =
        _deviceSize.height - (_deviceSize.height * 0.1);
    containerSize = Tween<double>(
            begin: _deviceSize.height * 0.1, end: defaultRegisterSize)
        .animate(
            CurvedAnimation(parent: animationController, curve: Curves.linear));
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      body: AnimatedOpacity(
        opacity: 1.0,
        duration: animationDuration * 4,
        child: Align(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Container(
              width: _deviceSize.width,
              height: defaultLoginSize,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: _deviceSize.height * 0.08,
                  ),
                  Input(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InputContainer extends StatelessWidget {
  InputContainer({
    this.child,
  });
  final child;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      width: size.width * 0.8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.green,
      ),
      child: child,
    );
  }
}

enum Password { visibility, nonVisibility }

class Input extends StatefulWidget {
  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String errorMessage = '';
  Password _password = Password.nonVisibility;
  bool isLoading = false;

  void submit(
    BuildContext ctx,
    email,
    password,
  ) async {
    print("---------------");
    print(email);
    print(password);
    if (email.isNotEmpty &&
        password.isNotEmpty &&
        email == "akshaygade2327@gmail.com" &&
        password == "Akshayy") {
      UserCredential authResult;
      try {
        authResult = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        print(authResult);

        Navigator.of(ctx).pushReplacement(
          MaterialPageRoute(
            builder: (ctx) => HomeScreen(),
          ),
        );
      } on FirebaseAuthException catch (error) {
        switch (error.code) {
          case "wrong-password":
            errorMessage = "Access denied.";
            break;
          case "invalid-email":
            errorMessage = "Please enter a valid email address..............";
            break;
          case "user-not-found":
            errorMessage = "please enter valid credentials";
            break;
          case "too-many-requests":
            errorMessage = "Too many requests. Try again later.";
            break;
        }
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Theme.of(ctx).errorColor,
          ),
        );
      }
    } else {
      if (email != "akshaygade2327@gmail.com" && password != "Akshay") {
        errorMessage = "Access denied.";
      } else {
        errorMessage = "Please enter valid credentials.";
      }
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Theme.of(ctx).errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        InputContainer(
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              icon: const Icon(Icons.email),
              hintText: "Email",
              border: InputBorder.none,
              suffixIcon: _emailController.text.isNotEmpty
                  ? InkWell(
                      child: const Icon(Icons.clear_rounded),
                      onTap: () {
                        setState(() {
                          _emailController.text = "";
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (_) {
              setState(() {});
            },
          ),
        ),
        InputContainer(
          child: TextField(
            controller: _passwordController,
            obscureText: _password == Password.nonVisibility ? true : false,
            decoration: InputDecoration(
              icon: const Icon(
                Icons.lock,
              ),
              hintText: "Password",
              border: InputBorder.none,
              suffixIcon: InkWell(
                child: Icon(
                  _password == Password.nonVisibility
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onTap: () {
                  if (_password == Password.nonVisibility) {
                    setState(() {
                      _password = Password.visibility;
                    });
                  } else {
                    setState(() {
                      _password = Password.nonVisibility;
                    });
                  }
                },
              ),
            ),
          ),
        ),
        SizedBox(height: size.height * 0.015),
        InkWell(
          onTap: () async {
            FocusScope.of(context).unfocus();
            if (isLoading) return;
            if (_emailController.text != "" && _passwordController.text != "") {
              setState(() {
                isLoading = true;
              });
            }
            submit(
              context,
              _emailController.text.trim(),
              _passwordController.text,
            );
            await Future.delayed(Duration(milliseconds: 2000));
            setState(() {
              isLoading = false;
            });
          },
          child: Container(
            width: size.width * 0.8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: EdgeInsets.symmetric(vertical: size.height * 0.03),
            alignment: Alignment.center,
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    "LOGIN",
                    style: TextStyle(color: Colors.green, fontSize: 22),
                  ),
          ),
        )
      ],
    );
  }
}
