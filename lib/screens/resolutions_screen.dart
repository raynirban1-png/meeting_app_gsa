import 'package:flutter/material.dart';
import '../models/resolution_model.dart';
import '../models/resolution_store.dart';
import 'dart:convert';
import '../models/meeting_store.dart';
import '../models/current_user_store.dart';
import 'package:http/http.dart' as http;
import '../api_config.dart';
import '../lib/api_service.dart';

class ResolutionsScreen extends StatefulWidget {
  const ResolutionsScreen({
    super.key,
  });

  @override
  State<ResolutionsScreen> createState() =>
      _ResolutionsScreenState();
}
class _ResolutionsScreenState
    extends State<ResolutionsScreen> {

  final TextEditingController
  titleController =
  TextEditingController();

  final TextEditingController
  descriptionController =
  TextEditingController();
  String? selectedMeeting;
  String selectedStatusFilter =
    "All";

  Future<void> addResolution() async {
    if (titleController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all resolution fields")),
      );
      return;
    }

    try {
      await http.post(
        Uri.parse("${ApiConfig.baseUrl}/resolutions"),
        headers: await ApiService.getHeaders(),
        body: jsonEncode({
          "title": titleController.text.trim(),
          "description": descriptionController.text.trim(),
          "meetingTitle": selectedMeeting ?? "Unassigned",
          "forVotes": 0,
          "againstVotes": 0,
          "abstainVotes": 0,
          "votedMembers": [],
          "status": "Draft",
        }),
      );


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Resolution Added")),
      );

      titleController.clear();
      descriptionController.clear();
      await loadResolutions();
      Navigator.pop(context);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void deleteResolution(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Delete Resolution",
          ),
          content: const Text(
            "Are you sure you want to delete this resolution?",
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
                  ResolutionStore.resolutions.removeAt(index);
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
  Future<void> loadResolutions() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/resolutions"),
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

  @override
  void initState() {

    super.initState();

    loadResolutions();
  }

  bool canManageResolutions() {

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

  void updateResolutionStatus(

      int index,

      String newStatus,
      ) {

    setState(() {

      ResolutionStore
          .resolutions[index]

          .status = newStatus;
    });

  }

  void castVote(

      int index,

      String voteType,
      ) {
    final currentPhone =

        CurrentUserStore
            .currentUser
            ?.phoneNumber;

    if (currentPhone == null) {
      return;
    }

    if (

    ResolutionStore
        .resolutions[index]
        .votedMembers
        .contains(currentPhone)

    ) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content: Text(
            "You have already voted",
          ),
        ),
      );

      return;
    }

    setState(() {

      if (voteType == "For") {

        ResolutionStore
            .resolutions[index]
            .forVotes++;

      } else if (

      voteType == "Against") {

        ResolutionStore
            .resolutions[index]
            .againstVotes++;

      } else {

        ResolutionStore
            .resolutions[index]
            .abstainVotes++;
      }

      ResolutionStore
          .resolutions[index]
          .votedMembers
          .add(currentPhone);
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Resolutions",
        ),
      ),

      body: ResolutionStore.resolutions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 60,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "No resolutions yet",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Create resolutions to begin governance voting.",
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

      padding:
      const EdgeInsets.all(12),

      child:
      DropdownButtonFormField<
          String>(

        initialValue:
        selectedStatusFilter,

        decoration:
        const InputDecoration(

          labelText:
          "Filter Status",

          border:
          OutlineInputBorder(),
        ),

        items: [

          "All",

          "Draft",

          "Proposed",

          "Voting",

          "Approved",

          "Rejected",

        ].map((status) {

          return DropdownMenuItem(

            value: status,

            child: Text(status),
          );

        }).toList(),

        onChanged: (value) {

          setState(() {

            selectedStatusFilter =
            value!;
          });
        },
      ),
    ),

    Expanded(

    child: ListView.builder(

      itemCount:

      ResolutionStore
          .resolutions
          .where((resolution) {

        if (
        selectedStatusFilter
            == "All") {

          return true;
        }

        return resolution.status
            ==
            selectedStatusFilter;

      }).length,

        itemBuilder: (context, index) {
          final filteredResolutions =

          ResolutionStore
              .resolutions
              .where((resolution) {

            if (
            selectedStatusFilter
                == "All") {

              return true;
            }

            return resolution.status
                ==
                selectedStatusFilter;

          }).toList();

          final resolution =
          filteredResolutions[index];

          return Card(

            margin:
            const EdgeInsets.all(12),

            child: ListTile(
              title: Text(
                resolution.title,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (CurrentUserStore.isAdmin)

                    IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      editResolution(index);
                    },
                  ),
                  if (CurrentUserStore.isAdmin)

                    IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      deleteResolution(index);
                    },
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    resolution.description,
                  ),
                  const SizedBox(height: 8),

                  Text(
                    "Meeting: "
                        "${resolution.meetingTitle}",
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: resolution.status == "Approved"
                          ? Colors.green.shade100
                          : resolution.status == "Rejected"
                              ? Colors.red.shade100
                              : resolution.status == "Voting"
                                  ? Colors.orange.shade100
                                  : resolution.status == "Proposed"
                                      ? Colors.blue.shade100
                                      : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      resolution.status,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "For: "
                    "${resolution.forVotes}",
                  ),
                  Text(
                    "Against: "
                    "${resolution.againstVotes}",
                  ),
                  Text(
                    "Abstain: "
                    "${resolution.abstainVotes}",
                  ),
                  Builder(

                    builder: (context) {

                      final totalVotes =

                          resolution.forVotes +

                              resolution.againstVotes +

                              resolution.abstainVotes;

                      final approvalPercentage =

                      totalVotes == 0

                          ? 0

                          : ((resolution.forVotes /
                          totalVotes) *
                          100)
                          .round();

                      return Text(

                        "Approval: "
                            "$approvalPercentage%",

                        style: TextStyle(

                          fontWeight:
                          FontWeight.w600,

                          color:
                          approvalPercentage >= 50

                              ? Colors.green

                              : Colors.red,
                        ),
                      );
                    },
                  ),
                  Builder(
                    builder: (context) {
                      final passed =
                          resolution.forVotes > resolution.againstVotes;
                      final totalVotes = resolution.forVotes +
                          resolution.againstVotes +
                          resolution.abstainVotes;
                      if (totalVotes == 0) {
                        return const SizedBox();
                      }
                      return Text(
                        passed ? "Likely Passed" : "Likely Rejected",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: passed ? Colors.green : Colors.red,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  if (resolution.status == "Voting")
                    Wrap(
                      spacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            castVote(
                              index,
                              "For",
                            );
                          },
                          child: const Text(
                            "For",
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            castVote(
                              index,
                              "Against",
                            );
                          },
                          child: const Text(
                            "Against",
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            castVote(
                              index,
                              "Abstain",
                            );
                          },
                          child: const Text(
                            "Abstain",
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  if (canManageResolutions())
                    Wrap(
                      spacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            updateResolutionStatus(
                              index,
                              "Proposed",
                            );
                          },
                          child: const Text(
                            "Propose",
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            updateResolutionStatus(
                              index,
                              "Voting",
                            );
                          },
                          child: const Text(
                            "Voting",
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            updateResolutionStatus(
                              index,
                              "Approved",
                            );
                          },
                          child: const Text(
                            "Approve",
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            updateResolutionStatus(
                              index,
                              "Rejected",
                            );
                          },
                          child: const Text(
                            "Reject",
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  ],
),

      floatingActionButton:
      canManageResolutions()
          ? FloatingActionButton(

        onPressed: () {

          showDialog(
            context: context,

            builder: (context) {

              return AlertDialog(

                title: const Text(
                  "Add Resolution",

                ),

                content: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [

                    TextField(
                      controller: titleController,

                      decoration:
                      const InputDecoration(
                        hintText: "Title",
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller:
                      descriptionController,

                      decoration:
                      const InputDecoration(
                        hintText: "Description",
                      ),
                    ),

                    const SizedBox(height: 15),

                    DropdownButtonFormField<String>(

                      initialValue: selectedMeeting,

                      decoration: const InputDecoration(
                        labelText: "Select Meeting",
                      ),

                      items:
                          MeetingStore.meetings.map((meeting) {

                        return DropdownMenuItem(

                          value: meeting.title,

                          child: Text(meeting.title),
                        );

                      }).toList(),

                      onChanged: (value) {

                        setState(() {

                          selectedMeeting = value;
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
                    onPressed: addResolution,

                    child: const Text("Save"),
                  ),

                ],
              );
            },
          );
        },
      )
          : null,
    );
  }

  void editResolution(int index) {
    titleController.text = ResolutionStore.resolutions[index].title;

    descriptionController.text = ResolutionStore.resolutions[index].description;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Edit Resolution",
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: "Title",
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  hintText: "Description",
                ),
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
                  ResolutionStore.resolutions[index] = ResolutionModel(
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim(),
                    meetingTitle:
                    ResolutionStore
                        .resolutions[index]
                        .meetingTitle,
                    forVotes:
                    ResolutionStore
                        .resolutions[index]
                        .forVotes,

                    againstVotes:
                    ResolutionStore
                        .resolutions[index]
                        .againstVotes,

                    abstainVotes:
                    ResolutionStore
                        .resolutions[index]
                        .abstainVotes,

                    votedMembers:

                    ResolutionStore
                        .resolutions[index]
                        .votedMembers,

                    status: ResolutionStore.resolutions[index].status,
                  );
                });

                Navigator.pop(context);
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }
}