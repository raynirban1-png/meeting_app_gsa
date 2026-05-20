import 'package:flutter/material.dart';
import '../models/member_store.dart';
import '../models/current_user_store.dart';
import 'dashboard_screen.dart';
import '../models/member_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {

  final TextEditingController
  phoneController =
  TextEditingController();

  final TextEditingController
  passwordController =
  TextEditingController();

  bool isLoading = false;

  Future<void> loadMembers() async {

    final prefs =
    await SharedPreferences.getInstance();

    List<String>? memberData =
    prefs.getStringList("members");

    if (memberData == null || memberData.isEmpty) {
      MemberStore.members = [
        MemberModel(
          name: "Dr. Nirban Ray",
          role: "Chief Advisor",
          department: "Chief Advisor",
          accessRole: "Admin",
          phoneNumber: "9999999999",
          password: "admin123",
        ),
      ];
      return;
    }

    MemberStore.members = memberData.map((member) {
      final decoded = jsonDecode(member);
      return MemberModel(
        name: decoded["name"],
        role: decoded["role"],
        department: decoded["department"],
        accessRole: decoded["accessRole"] ?? "Member",
        phoneNumber: decoded["phoneNumber"] ?? "",
        password: decoded["password"] ?? "",
      );
    }).toList();
  }

  Future<void> login() async {
    try {
      setState(() {
        isLoading = true;
      });
      final response = await http.post(
        Uri.parse(
          "${ApiConfig.baseUrl}/login",
        ),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "phoneNumber": phoneController.text.trim(),
          "password": passwordController.text.trim(),
        }),
      );

      final data = jsonDecode(
        response.body,
      );

      if (data["success"] == true) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString(
          "token",
          data["token"],
        );
        final memberData = data["member"];

        final member = MemberModel(
          name: memberData["name"],
          role: "",
          department: "",
          accessRole: memberData["accessRole"],
          phoneNumber: memberData["phoneNumber"],
          password: memberData["password"],
        );

        CurrentUserStore.currentUser = member;
        setState(() {
          isLoading = false;
        });
        print(CurrentUserStore.currentUser?.phoneNumber);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardScreen(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Invalid Login",
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Login error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Connection Error: ${e.toString()}",
          ),
        ),
      );
    }
  }



  @override
  void initState() {

    super.initState();

    loadMembers();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Login"),
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            TextField(

              controller: phoneController,

              keyboardType:
              TextInputType.phone,

              decoration:
              const InputDecoration(
                labelText: "Phone Number",
              ),
            ),

            const SizedBox(height: 20),

            TextField(

              controller: passwordController,

              obscureText: true,

              decoration:
              const InputDecoration(
                labelText: "Password",
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(

              onPressed: isLoading
                  ? null
                  : login,

              child: isLoading

                  ? const CircularProgressIndicator()

                  : const Text(
                "Login",
              ),
            ),
          ],
        ),
      ),
    );
  }
}