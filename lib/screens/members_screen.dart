import 'package:flutter/material.dart';
import '../models/member_model.dart';
import '../models/member_store.dart';
import '../models/current_user_store.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_config.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({
    super.key,
  });

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  String selectedAccessRole = "Member";

  @override
  void dispose() {
    nameController.dispose();
    roleController.dispose();
    departmentController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadMembers();
  }

  Future<void> addMember() async{
    if (nameController.text.trim().isEmpty ||
        roleController.text.trim().isEmpty ||
        departmentController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Fill all member fields"),
        ),
      );
      return;
    }

    try {

      await http.post(

        Uri.parse(
          "${ApiConfig.baseUrl}/members",
        ),

        headers: {
          "Content-Type":
          "application/json",
        },

        body: jsonEncode({

          "name":
          nameController.text.trim(),

          "phoneNumber":
          phoneController.text.trim(),

          "password":
          passwordController.text.trim(),

          "accessRole":
          selectedAccessRole,
        }),
      );

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "Member Added",
          ),
        ),
      );

      Navigator.pop(context);
      await loadMembers();

    } catch (e) {

      print(e);

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  Future<void> loadMembers() async {

    try {

      final response =
      await http.get(

        Uri.parse(
          "${ApiConfig.baseUrl}/members",
        ),
      );

      final List data =
      jsonDecode(response.body);

      MemberStore.members =
          data.map((member) {

            return MemberModel(

              name:
              member["name"],

              role:
              "",

              department:
              "",

              accessRole:
              member["accessRole"],

              phoneNumber:
              member["phoneNumber"],

              password:
              member["password"],
            );

          }).toList();

      setState(() {});

    } catch (e) {

      print(e);
    }
  }

  void deleteMember(int index) {
    setState(() {
      MemberStore.members.removeAt(index);
    });
  }

  void editMember(int index) {
    nameController.text = MemberStore.members[index].name;
    roleController.text = MemberStore.members[index].role;
    departmentController.text = MemberStore.members[index].department;
    phoneController.text = MemberStore.members[index].phoneNumber;
    passwordController.text = MemberStore.members[index].password;
    selectedAccessRole = MemberStore.members[index].accessRole;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Member"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: "Member Name",
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: roleController,
                  decoration: const InputDecoration(
                    hintText: "Role",
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: departmentController,
                  decoration: const InputDecoration(
                    hintText: "Department",
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: "Phone Number",
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: "Password",
                  ),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: selectedAccessRole,
                  decoration: const InputDecoration(
                    labelText: "Access Role",
                  ),
                  items: [
                    "Member",
                    "Admin",
                    "President",
                    "Secretary",
                    "Treasurer",
                  ].map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedAccessRole = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  MemberStore.members[index] = MemberModel(
                    name: nameController.text.trim(),
                    role: roleController.text.trim(),
                    department: departmentController.text.trim(),
                    accessRole: selectedAccessRole,
                    phoneNumber: phoneController.text.trim(),
                    password: passwordController.text.trim(),
                  );
                });
                nameController.clear();
                roleController.clear();
                departmentController.clear();
                phoneController.clear();
                passwordController.clear();
                Navigator.pop(context);
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  bool canManageMembers() {
    final role = CurrentUserStore.currentUser?.accessRole;
    return role == "President" || role == "Secretary" || role == "Admin";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Members",
        ),
      ),
      body: MemberStore.members.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.group_outlined,
                    size: 60,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "No members yet",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Add members to begin organizational participation.",
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: "Search members...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: MemberStore.members.where((member) {
                      final query = searchController.text.toLowerCase();
                      return member.name.toLowerCase().contains(query) ||
                          member.role.toLowerCase().contains(query) ||
                          member.department.toLowerCase().contains(query);
                    }).length,
                    itemBuilder: (context, index) {
                      final filteredMembers = MemberStore.members.where((member) {
                        final query = searchController.text.toLowerCase();
                        return member.name.toLowerCase().contains(query) ||
                            member.role.toLowerCase().contains(query) ||
                            member.department.toLowerCase().contains(query);
                      }).toList();

                      final member =
                      filteredMembers[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 8),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(member.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: member.accessRole == "Admin"
                                          ? Colors.purple.shade100
                                          : member.accessRole == "President"
                                              ? Colors.blue.shade100
                                              : member.accessRole == "Secretary"
                                                  ? Colors.green.shade100
                                                  : Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      member.role,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(member.department),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Access: ${member.accessRole}",
                              ),
                            ],
                          ),
                          trailing: canManageMembers()
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        editMember(index);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text("Delete Member"),
                                              content: const Text(
                                                "Are you sure you want to delete this member?",
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text("Cancel"),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    deleteMember(index);
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text("Delete"),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: canManageMembers()
          ? FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Add Member"),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                hintText: "Member Name",
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextField(
                              controller: roleController,
                              decoration: const InputDecoration(
                                hintText: "Role",
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextField(
                              controller: departmentController,
                              decoration: const InputDecoration(
                                hintText: "Department",
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                hintText: "Phone Number",
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                hintText: "Password",
                              ),
                            ),
                            const SizedBox(height: 15),
                            DropdownButtonFormField<String>(
                              value: selectedAccessRole,
                              decoration: const InputDecoration(
                                labelText: "Access Role",
                              ),
                              items: [
                                "Member",
                                "Admin",
                                "President",
                                "Secretary",
                                "Treasurer",
                              ].map((role) {
                                return DropdownMenuItem(
                                  value: role,
                                  child: Text(role),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedAccessRole = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: addMember,
                          child: const Text("Save"),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
