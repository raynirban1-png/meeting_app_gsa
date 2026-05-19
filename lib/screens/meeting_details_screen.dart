import 'package:flutter/material.dart';
import '../models/meeting_model.dart';
import '../models/attendance_model.dart';
import '../models/resolution_model.dart';
import '../models/member_store.dart';
import '../models/resolution_store.dart';

class MeetingDetailsScreen extends StatefulWidget {
  final MeetingModel meeting;

  const MeetingDetailsScreen({
    super.key,
    required this.meeting,
  });

  @override
  State<MeetingDetailsScreen> createState() => _MeetingDetailsScreenState();
}

class _MeetingDetailsScreenState extends State<MeetingDetailsScreen> {
  final TextEditingController resolutionTitleController =
      TextEditingController();
  final TextEditingController resolutionDescriptionController =
      TextEditingController();

  List<AttendanceModel> attendanceList = [];

  @override
  void initState() {
    super.initState();
    attendanceList = MemberStore.members.map((member) {
      return AttendanceModel(
        memberName: member.name,
        isPresent: false,
      );
    }).toList();
  }

  int get presentCount {

    return attendanceList
        .where((member) => member.isPresent)
        .length;
  }

  int get absentCount {

    return attendanceList.length - presentCount;
  }

  double get attendancePercentage {

    if (attendanceList.isEmpty) {
      return 0;
    }

    return
      (presentCount / attendanceList.length) * 100;
  }

  final List<ResolutionModel> resolutions = [];
  void addResolution() {

    if (resolutionTitleController.text
        .trim()
        .isEmpty) {
      return;
    }

    setState(() {

      resolutions.add(

        ResolutionModel(

          title:
          resolutionTitleController.text.trim(),

          description:
          resolutionDescriptionController
              .text
              .trim(),
          meetingTitle: "General",
          forVotes: 0,

          againstVotes: 0,

          abstainVotes: 0,
          votedMembers: [],
        ),
      );
    });

    resolutionTitleController.clear();
    resolutionDescriptionController.clear();

    Navigator.pop(context);
  }
  @override
  void dispose() {
    resolutionTitleController.dispose();
    resolutionDescriptionController.dispose();
    super.dispose();
  }

  List<ResolutionModel>
  get filteredResolutions {

    return ResolutionStore.resolutions
        .where((resolution) {

      return resolution.meetingTitle
          == widget.meeting.title;

    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meeting Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.meeting.title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),
              Text(
                "Date: ${widget.meeting.date}",
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 15),
              Text(
                "Venue: ${widget.meeting.venue}",
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 15),
              Text(
                "Type: ${widget.meeting.type}",
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 15),
              Text(
                "Status: ${widget.meeting.status}",
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              const Text(
                "Attendance",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total Members: ${attendanceList.length}",
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Present: $presentCount",
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Absent: $absentCount",
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Attendance: "
                        "${attendancePercentage.toStringAsFixed(1)}%",
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ListView.builder(

                shrinkWrap: true,

                physics:
                const NeverScrollableScrollPhysics(),
                itemCount: attendanceList.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: CheckboxListTile(
                      title: Text(
                        attendanceList[index].memberName,
                      ),
                      value: attendanceList[index].isPresent,
                      onChanged: (value) {
                        setState(() {
                          attendanceList[index].isPresent = value ?? false;
                        });
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),

              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

                children: [

                  const Text(
                    "Resolutions",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  ElevatedButton(
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
                                  controller:
                                  resolutionTitleController,

                                  decoration:
                                  const InputDecoration(
                                    hintText:
                                    "Resolution Title",
                                  ),
                                ),

                                const SizedBox(height: 15),

                                TextField(
                                  controller:
                                  resolutionDescriptionController,

                                  decoration:
                                  const InputDecoration(
                                    hintText:
                                    "Resolution Description",
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
                                onPressed: addResolution,

                                child: const Text("Save"),
                              ),
                            ],
                          );
                        },
                      );
                    },

                    child: const Text("Add"),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              ListView.builder(

                shrinkWrap: true,

                physics:
                const NeverScrollableScrollPhysics(),

                itemCount:
                filteredResolutions.length,

                itemBuilder: (context, index) {

                  return Card(

                    child: ListTile(

                      title: Text(
                        filteredResolutions[index].title,
                      ),

                      subtitle: Text(
                        filteredResolutions[index]
                            .description,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
