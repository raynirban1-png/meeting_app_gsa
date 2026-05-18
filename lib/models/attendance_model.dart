class AttendanceModel {

  final String memberName;
  bool isPresent;

  AttendanceModel({
    required this.memberName,
    this.isPresent = false,
  });
}