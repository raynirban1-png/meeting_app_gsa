import 'package:flutter/material.dart';
import 'meetings_screen.dart';
import 'resolutions_screen.dart';
import 'members_screen.dart';
import 'notices_screen.dart';
import '../models/current_user_store.dart';
import 'login_screen.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/member_store.dart';
import '../models/meeting_store.dart';
import '../models/notice_store.dart';
import '../models/resolution_store.dart';
import '../models/member_model.dart';
import '../models/meeting_model.dart';
import '../models/notice_model.dart';
import '../models/resolution_model.dart';
import 'package:http/http.dart' as http;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,

  });



  @override
  State<DashboardScreen>
  createState() =>
      _DashboardScreenState();

}

class _DashboardScreenState
    extends State<DashboardScreen> {
      @override
      void initState() {

        super.initState();

        loadMembers();
        loadNotices();
        loadMeetings();
        loadResolutions();
      }

  Future<void> loadResolutions() async {
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:8000/resolutions"),
      );
      final List data = jsonDecode(response.body);
      ResolutionStore.resolutions = data.map((resolution) {
        return ResolutionModel(
          title: resolution["title"],
          description: resolution["description"],
          meetingTitle: resolution["meetingTitle"] ?? "Unassigned",
          forVotes: resolution["forVotes"] ?? 0,
          againstVotes: resolution["againstVotes"] ?? 0,
          abstainVotes: resolution["abstainVotes"] ?? 0,
          votedMembers: List<String>.from(resolution["votedMembers"] ?? []),
          status: resolution["status"] ?? "Draft",
        );
      }).toList();
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  Future<void> loadMeetings() async {
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:8000/meetings"),
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

  Future<void> loadNotices() async {
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:8000/notices"),
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

  Future<void> loadMembers() async {

    try {

      final response =
      await http.get(

        Uri.parse(
          "http://10.0.2.2:8000/members",
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

  Future<void> exportBackup(

      BuildContext context,
      ) async {

    final directory =

    await getApplicationDocumentsDirectory();

    final file = File(

      "${directory.path}/governance_backup.json",
    );

    final backupData = {

      "members":

      MemberStore.members.map((member) {

        return {

          "name": member.name,
          "role": member.role,
          "department":
          member.department,
          "accessRole":
          member.accessRole,
          "phoneNumber":
          member.phoneNumber,
        };

      }).toList(),

      "meetings":

      MeetingStore.meetings.map((meeting) {

        return {

          "title": meeting.title,
          "date": meeting.date,
          "venue": meeting.venue,
          "type": meeting.type,
          "status": meeting.status,
        };

      }).toList(),

      "notices":

      NoticeStore.notices.map((notice) {

        return {

          "title": notice.title,
          "message": notice.message,
          "priority": notice.priority,
        };

      }).toList(),

      "resolutions":

      ResolutionStore
          .resolutions
          .map((resolution) {

        return {

          "title":
          resolution.title,

          "description":
          resolution.description,

          "status":
          resolution.status,

          "meetingTitle":
          resolution.meetingTitle,

          "forVotes":
          resolution.forVotes,

          "againstVotes":
          resolution.againstVotes,

          "abstainVotes":
          resolution.abstainVotes,
        };

      }).toList(),
    };

    await file.writeAsString(

      jsonEncode(backupData),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(

      SnackBar(

        duration: const Duration(
          seconds: 5,
        ),

        content: Text(
          "Backup exported successfully\n"
              "${file.path}",
        ),
      ),
    );
  }

  Future<void> restoreBackup(

      BuildContext context,
      ) async {

    FilePickerResult? result =

    await FilePicker.platform
        .pickFiles();

    if (result == null) {
      return;
    }

    final file = File(
      result.files.single.path!,
    );

    final content =
    await file.readAsString();

    final decoded =
    jsonDecode(content);

    setState(() {

      MemberStore.members =

          (decoded["members"] as List)
              .map((member) {

            return MemberModel(

              name: member["name"],

              role: member["role"],

              department:
              member["department"],

              accessRole:
              member["accessRole"],

              phoneNumber:
              member["phoneNumber"],

              password:
              member["password"],
            );

          }).toList();

      MeetingStore.meetings =

          (decoded["meetings"] as List)
              .map((meeting) {

            return MeetingModel(

              title: meeting["title"],

              date: meeting["date"],

              venue: meeting["venue"],

              type: meeting["type"],

              status: meeting["status"],
            );

          }).toList();

      NoticeStore.notices =

          (decoded["notices"] as List)
              .map((notice) {

            return NoticeModel(

              title: notice["title"],

              message:
              notice["message"],

              priority:
              notice["priority"],
            );

          }).toList();

      ResolutionStore.resolutions =

          (decoded["resolutions"]
          as List)
              .map((resolution) {

            return ResolutionModel(

              title:
              resolution["title"],

              description:
              resolution["description"],

              status:
              resolution["status"],

              meetingTitle:
              resolution[
              "meetingTitle"],

              forVotes:
              resolution["forVotes"],

              againstVotes:
              resolution[
              "againstVotes"],

              abstainVotes:
              resolution[
              "abstainVotes"],

              votedMembers: [],
            );

          }).toList();
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(

      const SnackBar(

        content: Text(
          "Backup restored successfully",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("GSA"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              CurrentUserStore.currentUser = null;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>

                      const LoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome, "
                        "${CurrentUserStore.currentUser?.name ?? ""}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${CurrentUserStore.currentUser?.role ?? ""}"
                        " • "
                        "${CurrentUserStore.currentUser?.accessRole ?? ""}",
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  dashboardCard(
                    title: "Meetings",
                    icon: Icons.groups,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MeetingsScreen(),
                        ),
                      );
                    },
                  ),
                  dashboardCard(
                    title: "Resolutions",
                    icon: Icons.description,
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ResolutionsScreen(),
                        ),
                      );
                    },
                  ),
                  dashboardCard(
                    title: "Notices",
                    icon: Icons.notifications,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NoticesScreen(),
                        ),
                      );
                    },
                  ),
                  dashboardCard(
                    title: "Members",
                    icon: Icons.people,
                    color: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MembersScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              Padding(

                padding:
                const EdgeInsets.symmetric(
                    horizontal: 12),

                child: Row(

                  mainAxisAlignment:
                  MainAxisAlignment
                      .spaceEvenly,

                  children: [

                    _buildStatCard(
                      "Members",
                      MemberStore.members.length.toString(),
                    ),

                    _buildStatCard(
                      "Meetings",
                      MeetingStore.meetings.length
                          .toString(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Padding(

                padding:
                const EdgeInsets.symmetric(
                    horizontal: 12),

                child: Row(

                  mainAxisAlignment:
                  MainAxisAlignment
                      .spaceEvenly,

                  children: [

                    _buildStatCard(
                      "Notices",
                      NoticeStore.notices.length
                          .toString(),
                    ),

                    _buildStatCard(
                      "Resolutions",

                      ResolutionStore
                          .resolutions
                          .length
                          .toString(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),
              const SizedBox(height: 18),
              ElevatedButton.icon(

                onPressed: () {

                  exportBackup(context);
                },

                icon: const Icon(Icons.save),

                label: const Text(
                  "Export Backup",
                ),
              ),
              const SizedBox(height: 12),

              ElevatedButton.icon(

                onPressed: () {

                  restoreBackup(context);
                },

                icon: const Icon(
                  Icons.restore,
                ),

                label: const Text(
                  "Restore Backup",
                ),
              ),
              const Divider(),
              const SizedBox(height: 15),
              const Text(
                "Governance Management System",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Developed for organizational governance, "
                "meeting management, resolutions, notices, "
                "and democratic voting workflows.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                "Developed by Dr. Nirban Ray",
              ),
              const SizedBox(height: 4),
              const Text(
                "Chief Advisor",
              ),
              const SizedBox(height: 8),
              const Text(
                "Version 1.0.0",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget dashboardCard({
    required String title,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: color,
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildStatCard(
    String title,
    String value,
  ) {
    return Card(
      child: SizedBox(
        width: 140,
        height: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(title),
          ],
        ),
      ),
    );
  }
}
