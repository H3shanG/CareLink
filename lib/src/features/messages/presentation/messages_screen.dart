import 'package:flutter/material.dart';

import '../data/message_store.dart';

import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Demo Conversations',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          _buildConversation(
            context,
            'CareLink Support',
            'Support conversation',
            Icons.support_agent,
            Colors.blue,
          ),

          _buildConversation(
            context,
            'Caregiver',
            'Caregiver conversation',
            Icons.person_outline,
            Colors.green,
          ),

          _buildConversation(
            context,
            'Medical Services',
            'Medical service conversation',
            Icons.medical_services_outlined,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildConversation(
    BuildContext context,
    String name,
    String message,
    IconData icon,
    Color color,
  ) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          MessageStore.getMessages(name).isEmpty
              ? message
              : MessageStore.getMessages(name).last,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ChatScreen(name: name)),
          );

          if (mounted) {
            setState(() {});
          }
        },
      ),
    );
  }
}
