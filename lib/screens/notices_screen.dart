import 'package:flutter/material.dart';
import '../models/notice_model.dart';
import '../models/notice_store.dart';
import '../models/current_user_store.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_config.dart';
import '../lib/api_service.dart';

class NoticesScreen extends StatefulWidget {
  const NoticesScreen({
    super.key,
  });

  @override
  State<NoticesScreen> createState() =>
      _NoticesScreenState();
}

class _NoticesScreenState
    extends State<NoticesScreen> {
  final TextEditingController
  titleController =
  TextEditingController();

  final TextEditingController
  messageController =
  TextEditingController();

  String selectedPriority =
      "Normal";

  @override
  void initState() {
    super.initState();
    loadNotices();
  }

  Future<void> loadNotices() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/notices"),
      );
      final List data = jsonDecode(response.body);
      NoticeStore.notices = data.map((notice) {
        return NoticeModel(
          title: notice["title"],
          message: notice["message"],
          priority: notice["priority"],
        );
      }).toList();
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  Future<void> addNotice() async {
    if (titleController.text.trim().isEmpty) {
      return;
    }

    try {
      await http.post(
        Uri.parse("${ApiConfig.baseUrl}/notices"),
        headers: await ApiService.getHeaders(),
        body: jsonEncode({
          "title": titleController.text.trim(),
          "message": messageController.text.trim(),
          "priority": selectedPriority,
        }),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Notice Added")),
      );

      titleController.clear();
      messageController.clear();
      Navigator.pop(context);
      await loadNotices();
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void editNotice(int index) {

    titleController.text =
        NoticeStore.notices[index].title;

    messageController.text =
        NoticeStore.notices[index].message;

    selectedPriority =
        NoticeStore.notices[index].priority;

    showDialog(
      context: context,

      builder: (context) {

        return AlertDialog(

          title: const Text(
            "Edit Notice",
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,

            children: [

              TextField(
                controller: titleController,

                decoration:
                const InputDecoration(
                  hintText: "Notice Title",
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller:
                messageController,

                decoration:
                const InputDecoration(
                  hintText: "Message",
                ),
              ),

              const SizedBox(height: 15),

              DropdownButtonFormField<String>(

                initialValue: selectedPriority,

                decoration:
                const InputDecoration(
                  labelText: "Priority",
                ),

                items: [

                  "Low",
                  "Normal",
                  "High",
                ].map((priority) {

                  return DropdownMenuItem(

                    value: priority,

                    child: Text(priority),
                  );

                }).toList(),

                onChanged: (value) {

                  setState(() {

                    selectedPriority =
                    value!;
                  });
                },
              ),
            ],
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

                  NoticeStore.notices[index] =

                      NoticeModel(

                        title:
                        titleController.text.trim(),

                        message:
                        messageController.text.trim(),

                        priority:
                        selectedPriority,
                      );
                });

                titleController.clear();
                messageController.clear();

                Navigator.pop(context);
              },

              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  bool canManageNotices() {

    final role =

        CurrentUserStore
            .currentUser
            ?.accessRole;

    return role == "President"

        ||

        role == "Secretary"

        ||

        role == "Admin";
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Notices",
        ),
      ),

      body: NoticeStore.notices.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 60,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "No notices yet",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Publish notices to communicate with members.",
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )

          : ListView.builder(

        itemCount:
        NoticeStore.notices.length,

        itemBuilder: (context, index) {

          return Card(

            margin:
            const EdgeInsets.all(12),

            child: ListTile(

              leading: CircleAvatar(

                backgroundColor:

                NoticeStore.notices[index]
                    .priority
                    == "High"

                    ? Colors.red

                    : NoticeStore.notices[index]
                    .priority
                    == "Low"

                    ? Colors.green

                    : Colors.orange,

                child:
                const Icon(Icons.notifications),
              ),

              title: Text(
                NoticeStore.notices[index]
                    .title,
              ),

              subtitle: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  const SizedBox(height: 8),

                  Text(
                    NoticeStore.notices[index]
                        .message,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Priority: "
                        "${NoticeStore.notices[index].priority}",
                  ),
                ],
              ),
              trailing: Row(

                mainAxisSize: MainAxisSize.min,

                children: [

                  IconButton(

                    icon: const Icon(Icons.edit),

                    onPressed: () {

                      editNotice(index);
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

                            title: const Text(
                              "Delete Notice",
                            ),

                            content: const Text(
                              "Are you sure you want to delete this notice?",
                            ),

                            actions: [

                              TextButton(

                                onPressed: () {

                                  Navigator.pop(context);
                                },

                                child: const Text(
                                  "Cancel",
                                ),
                              ),

                              ElevatedButton(

                                onPressed: () {

                                  setState(() {

                                    NoticeStore.notices
                                        .removeAt(index);
                                  });

                                  Navigator.pop(context);
                                },

                                child: const Text(
                                  "Delete",
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),

      floatingActionButton:
      canManageNotices()
          ? FloatingActionButton(

        onPressed: () {

          showDialog(
            context: context,

            builder: (context) {

              return AlertDialog(

                title: const Text(
                  "Add Notice",
                ),

                content: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [

                    TextField(
                      controller: titleController,

                      decoration:
                      const InputDecoration(
                        hintText: "Notice Title",
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller:
                      messageController,

                      decoration:
                      const InputDecoration(
                        hintText: "Message",
                      ),
                    ),

                    const SizedBox(height: 15),

                    DropdownButtonFormField<String>(

                      initialValue: selectedPriority,

                      decoration:
                      const InputDecoration(
                        labelText: "Priority",
                      ),

                      items: [

                        "Low",
                        "Normal",
                        "High",
                      ].map((priority) {

                        return DropdownMenuItem(

                          value: priority,

                          child: Text(priority),
                        );

                      }).toList(),

                      onChanged: (value) {

                        setState(() {

                          selectedPriority =
                          value!;
                        });
                      },
                    ),
                  ],
                ),

                actions: [

                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },

                    child: const Text("Cancel"),
                  ),

                  ElevatedButton(
                    onPressed: addNotice,

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