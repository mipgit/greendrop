import 'package:flutter/material.dart';
import 'package:greendrop/view_model/droplet_provider.dart';
import 'package:greendrop/views/droplet_counter.dart';
import 'widgets/task_list.dart';

class TaskScreen extends StatelessWidget {
  const TaskScreen({Key? key}) : super(key: key);

  final List<String> tasks = const [
    "Use a reusable water bottle.",
    "Turn off lights when not in use.",
    "Recycle paper and plastics.",
    "Use public transportation or bike.",
    "Reduce food waste.",
  ];

  @override
  Widget build(BuildContext context) {
    final provider = DropletProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daily Eco Tasks',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.lightGreen.shade900,
          ),
        ),
        backgroundColor: Colors.green.shade50,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.green.shade50,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropletCounter(dropletCount: provider?.dropletCount ?? 0),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return TaskListItem(
                    task: tasks[index],
                    completed: provider!.completedTasks[index],
                    onChanged: (bool? value) {
                      if (value != null) {
                        provider.updateTaskCompletion(index, value);
                        // Update droplets as needed
                        int dropletChange = value ? 1 : -1;
                        provider.updateDroplets(
                          provider.dropletCount + dropletChange,
                        );
                      }
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              // Test button
              onPressed: () {
                provider?.updateDroplets(
                  (provider.dropletCount + 1),
                ); // Increment droplets
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                foregroundColor: Colors.orange,
              ),
              child: const Text("Add Droplet (Test)"),
            ),
          ],
        ),
      ),
    );
  }
}
