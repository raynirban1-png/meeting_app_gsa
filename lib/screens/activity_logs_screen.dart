import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart'
as http;

import '../api_config.dart';

class ActivityLogsScreen
    extends StatefulWidget {

  const ActivityLogsScreen({
    super.key,
  });

  @override
  State<ActivityLogsScreen>
  createState() =>
      _ActivityLogsScreenState();
}

class _ActivityLogsScreenState
    extends State<ActivityLogsScreen> {

  List logs = [];

  bool isLoading = true;

  @override
  void initState() {

    super.initState();

    loadLogs();
  }

  Future<void>
  loadLogs() async {

    try {

      final response =
      await http.get(

        Uri.parse(
          "${ApiConfig.baseUrl}/activity-logs",
        ),
      );

      final data =
      jsonDecode(
          response.body);

      setState(() {

        logs = data;

        isLoading = false;
      });

    } catch (e) {

      setState(() {

        isLoading = false;
      });
    }
  }

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Activity Logs",
        ),
      ),

      body: isLoading

          ? const Center(
        child:
        CircularProgressIndicator(),
      )

          : ListView.builder(

        itemCount:
        logs.length,

        itemBuilder:
            (context, index) {

          final log =
          logs[index];

          return ListTile(

            leading:
            const Icon(
              Icons.history,
            ),

            title: Text(
              log["action"],
            ),

            subtitle: Text(
              "${log["performedBy"]}\n"
                  "${log["timestamp"]}",
            ),
          );
        },
      ),
    );
  }
}