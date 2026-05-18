class ResolutionModel {

  final String title;
  final String description;
  final String meetingTitle;
  int forVotes;
  int againstVotes;
  int abstainVotes;
  List<String> votedMembers;
  String status;

  ResolutionModel({
    required this.title,
    required this.description,
    required this.meetingTitle,
    required this.forVotes,
    required this.againstVotes,
    required this.abstainVotes,
    required this.votedMembers,
    this.status = "Pending",
  });
}