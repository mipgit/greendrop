// In view/chat_view.dart
 import 'package:cloud_firestore/cloud_firestore.dart';
 import 'package:firebase_auth/firebase_auth.dart';
 import 'package:flutter/material.dart';
 import 'package:greendrop/view/groups/group_settings_view.dart';

 class ChatView extends StatefulWidget {
   final String groupId;
   final String groupName;

   const ChatView({super.key, required this.groupId, required this.groupName});

   @override
   State<ChatView> createState() => _ChatViewState();
 }

 class _ChatViewState extends State<ChatView> {
   final TextEditingController _messageController = TextEditingController();
   final ScrollController _scrollController = ScrollController();
   final CollectionReference _messagesCollection =
       FirebaseFirestore.instance.collection('messages');
   final CollectionReference _groupsCollection =
       FirebaseFirestore.instance.collection('groups');
   List<String> _memberIds = [];
   Map<String, String> _memberNames = {};

  
   final ValueNotifier<int> _sentTodayNotifier = ValueNotifier<int>(0);
  
   @override
   void initState() {
     super.initState();
     _fetchGroupMembers();
     _updateSentToday();
     WidgetsBinding.instance.addPostFrameCallback((_) {
       _scrollToBottom();
     });
   }

   Future<void> _fetchGroupMembers() async {
     try {
       final groupDoc = await _groupsCollection.doc(widget.groupId).get();
       if (groupDoc.exists && groupDoc.data() != null) {
         final groupData = groupDoc.data() as Map<String, dynamic>;
         _memberIds = (groupData['memberIds'] as List<dynamic>?)?.cast<String>() ?? [];
         for (final memberId in _memberIds) {
           _memberNames[memberId] = memberId;
         }
         setState(() {});
       }
     } catch (e) {
       print('Error fetching group members: $e');
     }
   }

   void _scrollToBottom() {
     if (_scrollController.hasClients) {
       _scrollController.animateTo(
         _scrollController.position.maxScrollExtent,
         duration: const Duration(milliseconds: 300),
         curve: Curves.easeOut,
       );
     }
   }

   void _sendMessage() async {
     final String messageText = _messageController.text.trim();
     final User? user = FirebaseAuth.instance.currentUser;

     if (messageText.isNotEmpty && user != null) {
       await _messagesCollection.add({
         'groupId': widget.groupId,
         'senderId': user.uid,
         'text': messageText,
         'timestamp': FieldValue.serverTimestamp(),
       });
       _messageController.clear();
       _scrollToBottom();
       await _updateSentToday(); 
     }
   }

  Future<int> _getMessagesSentToday(String userId) async {
    print('Fetching messages sent today for user: $userId');
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final snapshot = await _messagesCollection
        .where('groupId', isEqualTo: widget.groupId)
        .where('senderId', isEqualTo: userId)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .get();
    return snapshot.docs.length;
  }


  Future<void> _updateSentToday() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final count = await _getMessagesSentToday(user.uid);
      _sentTodayNotifier.value = count;
    }
  }



   @override
   Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(
         title: InkWell(
           onTap: () {
             Navigator.push(
               context,
               MaterialPageRoute(
                 builder: (context) => GroupSettingsView(groupId: widget.groupId, groupName: widget.groupName),
               ),
             );
           },
           child: Row(
             children: [
               if (_memberIds.isNotEmpty)
                 Row(
                   children: [
                   //_memberIds.take(1).map((memberId) { return 
                    Padding(
                       padding: const EdgeInsets.only(right: 4.0),
                       child: CircleAvatar(
                         radius: 18,
                         child: Icon(Icons.group),
                       ),
                     )
                   ]
                   //}).toList(),
                 ),
               const SizedBox(width: 8.0),
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(
                       widget.groupName,
                       overflow: TextOverflow.ellipsis,
                       style: const TextStyle(fontWeight: FontWeight.bold),
                     ),
                     Text(
                       '${_memberIds.length} members',
                       style: const TextStyle(fontSize: 12),
                     ),
                   ],
                 ),
               ),
             ],
           ),
         ),
         actions: [
           IconButton(
             icon: const Icon(Icons.settings),
             onPressed: () {
               Navigator.push(
                 context,
                 MaterialPageRoute(
                   builder: (context) => GroupSettingsView(groupId: widget.groupId, groupName: widget.groupName),
                 ),
               );
             },
           ),
         ],
       ),
       body: Column(
         children: <Widget>[
           Expanded(
             child: StreamBuilder<QuerySnapshot>(
               stream: _messagesCollection
                   .where('groupId', isEqualTo: widget.groupId)
                   .orderBy('timestamp', descending: false)
                   .snapshots(),
               builder: (context, snapshot) {
                 if (snapshot.hasError) {
                   return Center(child: Text('Something went wrong: ${snapshot.error}'));
                 }

                 if (snapshot.connectionState == ConnectionState.waiting) {
                   return const Center(child: CircularProgressIndicator());
                 }

                 final messages = snapshot.data!.docs;

                 WidgetsBinding.instance.addPostFrameCallback((_) {
                   _scrollToBottom();
                 });

                 return ListView.builder(
                   controller: _scrollController,
                   itemCount: messages.length,
                   itemBuilder: (context, index) {
                     final messageData = messages[index].data() as Map<String, dynamic>;
                     final String senderId = messageData['senderId'] ?? '';
                     final bool isMe = senderId == FirebaseAuth.instance.currentUser?.uid;
                     final Timestamp? timestamp = messageData['timestamp'] as Timestamp?;
                     final DateTime? dateTime = timestamp?.toDate();

                    
                     
                      bool showDateHeader = false;
                      if (index == 0) {
                        showDateHeader = true;
                      } else {
                        final prevMessageData = messages[index - 1].data() as Map<String, dynamic>;
                        final prevTimestamp = prevMessageData['timestamp'] as Timestamp?;
                        final prevDateTime = prevTimestamp?.toDate();
                        if (dateTime != null && prevDateTime != null) {
                          showDateHeader = dateTime.day != prevDateTime.day ||
                                           dateTime.month != prevDateTime.month ||
                                           dateTime.year != prevDateTime.year;
                        }
                      }
                  

                     final String formattedTime = dateTime != null
                         ? '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}'
                         : '';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (showDateHeader)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 220, 236, 202),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              dateTime != null
                                  ? '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}'
                                  : '',
                              style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('users').doc(senderId).get(),
                        builder: (context, userSnapshot) {
                          //String senderName = senderId;
                          String senderName = '';
                          String? photoUrl;
                          if (userSnapshot.hasData && userSnapshot.data != null) {
                            final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                            if (userData != null) {
                               if (userData['email'] != null) {
                                 senderName = (userData['email'] as String).split('@')[0];
                               }
                               photoUrl = userData['profilePicture'] as String?;
                            }  
                          }

                         return Align(
                           alignment: isMe ? Alignment.topRight : Alignment.topLeft,
                           child: Padding(
                             padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                             child: Row(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 if (!isMe)
                                   Padding(
                                     padding: const EdgeInsets.only(right: 10.0, top: 2.0),
                                     child: CircleAvatar(
                                       radius: 15,
                                       backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                                       child: photoUrl == null ? Icon(Icons.person) : null,
                                     ),
                                   ),
                                 Expanded(
                                   child: Column(
                                    crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8.0),
                                        margin: EdgeInsets.only(top: !isMe ? 2.0 : 0),
                                        decoration: BoxDecoration(
                                          color: isMe ? Colors.green.shade100 : Colors.grey.shade200,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(isMe ? 12 : 0),
                                            topRight: const Radius.circular(12),
                                            bottomLeft: const Radius.circular(12),   
                                            bottomRight: Radius.circular(isMe ? 0 : 12),  
                                          ),
                                        ),  
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if (!isMe)
                                              Text(
                                                senderName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blueGrey,
                                                  fontSize: 12.0,
                                                ),
                                              ),
                                            const SizedBox(height: 4.0),
                                            Text(messageData['text'] ?? ''),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2.0, left: 8.0, right: 8.0),
                                        child: Text(
                                          formattedTime,
                                          style: const TextStyle(color: Colors.grey, fontSize: 10.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                 ),
                               ],
                             ),
                           ),
                         );
                       },
                      ),
                      ],
                     );  
                   },
                 );
               },
             ),
           ),
           const Divider(height: 1),
           Padding(
             padding: const EdgeInsets.all(8.0),
             child: Row(
               children: <Widget>[
                 Expanded(
                   child: ValueListenableBuilder<int>(
                    valueListenable: _sentTodayNotifier,
                    builder: (context, sentToday, _) => TextField(
                     controller: _messageController,
                     decoration: InputDecoration(
                       hintText: 'Send a message...   ($sentToday/5)',
                       border: InputBorder.none,
                     ),
                     onSubmitted: (_) => _sendMessage(),
                   ),
                  ), 
                 ),
                 ValueListenableBuilder<int>(
                  valueListenable: _sentTodayNotifier,
                  builder: (context, sentToday, _) => IconButton(
                   icon: const Icon(Icons.send),
                   onPressed: sentToday >= 5 ? null : _sendMessage,
                 ),
                ), 
               ],
             ),
           ),
         ],
       ),
     );
   }
 }