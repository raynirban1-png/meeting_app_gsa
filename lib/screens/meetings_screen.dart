import 'package:flutter/material.dart';
import '../models/meeting_model.dart';
import 'meeting_details_screen.dart';
import '../models/meeting_store.dart';
import 'dart:convert';
import '../models/current_user_store.dart';
import 'package:http/http.dart' as http;
import '../api_config.dart';
import '../lib/api_service.dart';


class MeetingsScreen extends StatefulWidget {
  const MeetingsScreen({
    super.key,
  });

  @override
  State<MeetingsScreen> createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen> {

  final TextEditingController meetingController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController venueController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  final TextEditingController resolutionTitleController = TextEditingController();
  final TextEditingController resolutionDescriptionController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    meetingController.dispose();
    dateController.dispose();
    venueController.dispose();
    typeController.dispose();
    statusController.dispose();
    resolutionTitleController.dispose();
    resolutionDescriptionController.dispose();
    super.dispose();
  }

  Future<void> addMeeting() async {
    if (meetingController.text.trim().isEmpty) {
      return;
    }

    try {
      await http.post(
        Uri.parse("${ApiConfig.baseUrl}/meetings"),
        headers: await ApiService.getHeaders(),
        body: jsonEncode({
          "title": meetingController.text.trim(),
          "date": dateController.text.trim(),
          "venue": venueController.text.trim(),
          "type": typeController.text.trim(),
          "status": statusController.text.trim(),
        }),
      );



      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Meeting Created")),
      );

      meetingController.clear();
      dateController.clear();
      venueController.clear();
      typeController.clear();
      statusController.clear();

      await loadMeetings();
      Navigator.pop(context);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void deleteMeeting(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Meeting"),
          content: const Text(
            "Are you sure you want to delete this meeting?",
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
                  MeetingStore.meetings.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "ongoing":
        return Colors.green;
      case "completed":
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  void editMeeting(int index) {
    meetingController.text = MeetingStore.meetings[index].title;
    dateController.text = MeetingStore.meetings[index].date;
    venueController.text = MeetingStore.meetings[index].venue;
    typeController.text = MeetingStore.meetings[index].type;
    statusController.text = MeetingStore.meetings[index].status;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Meeting"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: meetingController,
                  decoration: const InputDecoration(
                    hintText: "Meeting Title",
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    hintText: "Meeting Date",
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: venueController,
                  decoration: const InputDecoration(
                    hintText: "Venue",
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: typeController,
                  decoration: const InputDecoration(
                    hintText: "Meeting Type (Physical/Online/Hybrid)",
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: statusController,

                  decoration: const InputDecoration(
                    hintText: "Status (Upcoming/Ongoing/Completed)",
                  ),
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
                  MeetingStore.meetings[index] = MeetingModel(
                    title: meetingController.text.trim(),
                    date: dateController.text.trim(),
                    venue: venueController.text.trim(),
                    type: typeController.text.trim(),
                    status: statusController.text.trim(),
                  );
                });
                meetingController.clear();
                dateController.clear();
                venueController.clear();
                typeController.clear();
                statusController.clear();
                Navigator.pop(context);
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  void showAddMeetingDialog() {
    meetingController.clear();
    dateController.clear();
    venueController.clear();
    typeController.clear();
    statusController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Create Meeting"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: meetingController,
                  decoration: const InputDecoration(
                    hintText: "Meeting Title",
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    hintText: "Meeting Date",
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: venueController,
                  decoration: const InputDecoration(
                    hintText: "Venue",
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: typeController,
                  decoration: const InputDecoration(
                    hintText: "Meeting Type (Physical/Online/Hybrid)",
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: statusController,

                  decoration: const InputDecoration(
                    hintText: "Status (Upcoming/Ongoing/Completed)",
                  ),
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
              onPressed: addMeeting,
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> loadMeetings() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/meetings"),
      );
      final List data = jsonDecode(response.body);
      MeetingStore.meetings = data.map((meeting) {
        return MeetingModel(
          title: meeting["title"],
          date: meeting["date"],
          venue: meeting["venue"],
          type: meeting["type"],
          status: meeting["status"],
        );
      }).toList();
      setState(() {});
    } catch (e) {
      print(e);
    }
  }
  @override
  void initState() {

    super.initState();

    loadMeetings();
  }

  bool canManageMeetings() {

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
        title: const Text("Meetings"),
      ),
      floatingActionButton: canManageMeetings()
          ? FloatingActionButton(
              onPressed: showAddMeetingDialog,
              child: const Icon(Icons.add),
            )
          : null,
      body: MeetingStore.meetings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.groups_outlined,
                    size: 60,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "No meetings yet",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Create meetings to organize governance discussions.",
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
                      hintText: "Search meetings...",
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
                    itemCount:

                    MeetingStore
                        .meetings
                        .where((meeting) {

                      final query =
                      searchController.text
                          .toLowerCase();

                      return meeting.title
                          .toLowerCase()
                          .contains(query)

                          ||

                          meeting.venue
                              .toLowerCase()
                              .contains(query)

                          ||

                          meeting.type
                              .toLowerCase()
                              .contains(query)

                          ||

                          meeting.status
                              .toLowerCase()
                              .contains(query);

                    }).length,
              itemBuilder: (context, index) {
                final filteredMeetings =

                MeetingStore
                    .meetings
                    .where((meeting) {

                  final query =
                  searchController.text
                      .toLowerCase();

                  return meeting.title
                      .toLowerCase()
                      .contains(query)

                      ||

                      meeting.venue
                          .toLowerCase()
                          .contains(query)

                      ||

                      meeting.type
                          .toLowerCase()
                          .contains(query)

                      ||

                      meeting.status
                          .toLowerCase()
                          .contains(query);

                }).toList();

                final meeting =
                filteredMeetings[index];
                final filteredMeeting =
                filteredMeetings[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MeetingDetailsScreen(
                          meeting: meeting,
                        ),
                      ),
                    );
                  },
                  onLongPress: () {
                    deleteMeeting(index);
                  },
                  child: Card(
                    margin: const EdgeInsets.all(10),
                    color: getStatusColor(filteredMeeting.status)
                        .withValues(alpha: 0.15),
                    child: ListTile(
                      leading: const Icon(Icons.groups),
                      title: Text(filteredMeeting.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Date: ${filteredMeeting.date}"),
                          Text("Venue: ${filteredMeeting.venue}"),
                          Text("Type: ${filteredMeeting.type}"),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: filteredMeeting.status == "Completed"
                                  ? Colors.green.shade100
                                  : filteredMeeting.status == "Ongoing"
                                      ? Colors.orange.shade100
                                      : Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              filteredMeeting.status,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (CurrentUserStore.isAdmin)

                            IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              editMeeting(index);
                            },
                          ),
                          if (CurrentUserStore.isAdmin)

                            IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              deleteMeeting(index);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
