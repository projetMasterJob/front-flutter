import 'package:flutter/material.dart';
import 'chatDetail.dart'; // Import de la page détaillée

class ChatScreen extends StatelessWidget {
  final List<Map<String, String>> conversations = [
    {
      'name': 'Garry Eponge',
      'message': 'Bob, j\'ai faim?'
    },
    {
      'name': 'Chandler',
      'message': 'Hibernate !'
    },
    {
      'name': 'Lisa Lucas',
      'message': 'On se voit demain à la réunion ?'
    },
    {
      'name': 'JBM ',
      'message': 'Sac à dos, sac à dos !'
          'Cest la folie, de la mort qui tue ! je fais un ong message pour tester'
    },
    {
      'name': 'Emma Martin',
      'message': 'Tu as vu le match hier soir ?'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Conversations"),
        backgroundColor: Colors.blue,
      ),
      body: ListView.separated(
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(conversation['name']![0]), // Première lettre du nom
            ),
            title: Text(
              conversation['name']!,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(conversation['message']!),
            onTap: () {
              // Naviguer vers la page détaillée de la conversation
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConversationDetailScreen(
                    name: conversation['name']!,
                  ),
                ),
              );
            },
          );
        },
        separatorBuilder: (context, index) {
          return Divider(
            color: Colors.grey[300],
            thickness: 1,
          );
        },
      ),
    );
  }
}
