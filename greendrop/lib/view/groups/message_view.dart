import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageView extends StatelessWidget {
  final String message;
  final bool isMe;
  final Timestamp? timestamp;

  const MessageView({
    super.key,
    required this.message,
    required this.isMe,
    this.timestamp,
  });

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) {
      return '';
    }
    final DateTime dateTime = timestamp.toDate();
    return DateFormat('HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final timestampText = _formatTimestamp(timestamp);
    final TextStyle timestampStyle = TextStyle(
      color: isMe ? Colors.white70 : Colors.grey.shade600,
      fontSize: 10,
    );

    return Align(
      alignment: isMe ? Alignment.topRight : Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: isMe ? Colors.green.shade300 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: TextStyle(color: isMe ? Colors.white : Colors.black),
                    ),
                    if (timestamp != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(width: 8),
                          Text(
                            timestampText,
                            style: timestampStyle,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}