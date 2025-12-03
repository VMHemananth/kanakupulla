import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/split_provider.dart';
import 'group_details_screen.dart';

class GroupListScreen extends ConsumerWidget {
  const GroupListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(splitGroupsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bill Split Groups')),
      body: groupsAsync.when(
        data: (groups) {
          if (groups.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.group_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No groups yet'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showCreateGroupDialog(context, ref),
                    child: const Text('Create Group'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.group)),
                  title: Text(group.name),
                  subtitle: Text('Created: ${DateFormat('dd MMM yyyy').format(group.createdAt)}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditGroupDialog(context, ref, group);
                      } else if (value == 'add_member') {
                        _showAddMemberDialog(context, ref, group);
                      } else if (value == 'delete') {
                        _confirmDeleteGroup(context, ref, group);
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'add_member',
                        child: Row(
                          children: [
                            Icon(Icons.person_add, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Add Members'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupDetailsScreen(groupId: group.id, groupName: group.name),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateGroupDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Group'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Group Name (e.g., Trip to Goa)'),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(splitGroupsProvider.notifier).createGroup(controller.text);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditGroupDialog(BuildContext context, WidgetRef ref, dynamic group) {
    final controller = TextEditingController(text: group.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Group Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Group Name'),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(splitGroupsProvider.notifier).updateGroup(group.copyWith(name: controller.text));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteGroup(BuildContext context, WidgetRef ref, dynamic group) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Group?'),
        content: Text('Are you sure you want to delete "${group.name}"? This will delete all members and expenses in this group.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(splitGroupsProvider.notifier).deleteGroup(group.id);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context, WidgetRef ref, dynamic group) {
    final controller = TextEditingController();
    final members = <String>[];
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Members'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Name',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        setState(() {
                          members.add(controller.text);
                          controller.clear();
                        });
                      }
                    },
                  ),
                ),
                onSubmitted: (val) {
                  if (val.isNotEmpty) {
                    setState(() {
                      members.add(val);
                      controller.clear();
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              if (members.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: members.map((m) => Chip(
                    label: Text(m),
                    onDeleted: () {
                      setState(() {
                        members.remove(m);
                      });
                    },
                  )).toList(),
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  members.add(controller.text);
                }
                if (members.isNotEmpty) {
                  for (var name in members) {
                    ref.read(splitGroupsProvider.notifier).addMember(group.id, name);
                  }
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added ${members.length} members')),
                  );
                }
              },
              child: const Text('Add All'),
            ),
          ],
        ),
      ),
    );
  }
}
