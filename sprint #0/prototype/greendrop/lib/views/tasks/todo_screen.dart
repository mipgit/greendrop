import 'package:flutter/material.dart';
import 'package:greendrop/view_model/droplet_provider.dart';
import 'widgets/task_list';

class TaskScreen extends StatelessWidget {
  const TaskScreen({Key? key}) : super(key: key);

  final List<String> tasks = const [
    "Use a reusable water bottle.",
    "Turn off lights when not in use.",
    "Recycle paper and plastics.",
    "Use public transportation or bike.",
    "Reduce food waste."
  ];

  @override
  Widget build(BuildContext context) {
    final provider = DropletProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Eco Tasks', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.green.shade300,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.green.shade100,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Droplet Count: ${provider?.dropletCount ?? 0}",
              style: TextStyle(fontSize: 18.0, color: Colors.green.shade900, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
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
                        provider.updateDroplets(provider.dropletCount + dropletChange);
                      }
                    },
                  );
                },
              ),
            ),
            ElevatedButton(  // Test button
              onPressed: () {
                provider?.updateDroplets((provider.dropletCount + 1)); // Increment droplets
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade400,
                foregroundColor: Colors.white,
              ),
              child: const Text("Add Droplet (Test)"),
            ),
          ],
        ),
      ),
    );
  }
}