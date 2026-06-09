import 'dart:ui';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {

  final int myId;

  final int otherUserId;

  final String otherName;

  const ChatScreen({
    super.key,
    required this.myId,
    required this.otherUserId,
    required this.otherName,
  });

  @override
  State<ChatScreen> createState() =>
      _ChatScreenState();
}

class _ChatScreenState
    extends State<ChatScreen> {

  final TextEditingController
  _messageController =
  TextEditingController();

  final ScrollController
  _scrollController =
  ScrollController();

  late DatabaseReference messagesRef;

  String get chatRoomId {

    List ids = [
      widget.myId,
      widget.otherUserId
    ];

    ids.sort();

    return "${ids[0]}_${ids[1]}";
  }

  @override
  void initState() {
    super.initState();

    debugPrint(
        "ROOM ID : $chatRoomId");

    debugPrint(
        "MY ID : ${widget.myId}");

    debugPrint(
        "OTHER USER ID : ${widget.otherUserId}");

    messagesRef =
        FirebaseDatabase.instance
            .ref()
            .child("chat_rooms")
            .child(chatRoomId)
            .child("messages");

    debugPrint(
        "FIREBASE PATH : chat_rooms/$chatRoomId/messages");
  }

  Future<void> sendMessage() async {

    if (_messageController.text
        .trim()
        .isEmpty) return;

    await messagesRef.push().set({

      "senderId": widget.myId,

      "receiverId":
      widget.otherUserId,

      "message":
      _messageController.text.trim(),

      "timestamp":
      ServerValue.timestamp,
    });

    _messageController.clear();

    Future.delayed(
      const Duration(milliseconds: 200),
          () {

        if (_scrollController.hasClients) {

          _scrollController.animateTo(

            _scrollController
                .position
                .maxScrollExtent,

            duration:
            const Duration(
                milliseconds: 300),

            curve: Curves.easeOut,
          );
        }
      },
    );
  }

  String formatTime(dynamic timestamp) {

    if (timestamp == null) return "";

    DateTime date =
    DateTime.fromMillisecondsSinceEpoch(
      timestamp,
    );

    TimeOfDay tod =
    TimeOfDay.fromDateTime(date);

    return tod.format(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      AppColors.background,

      body: Column(

        children: [

          _buildAppBar(context),

          _buildTopicCard(),

          Expanded(

            child: StreamBuilder(

              stream: messagesRef.orderByChild("timestamp").onValue,

              builder: (context, snapshot) {

                if (!snapshot.hasData ||
                    snapshot.data!
                        .snapshot
                        .value ==
                        null) {

                  return const Center(
                    child: Text(
                      "Start Conversation ✨",
                    ),
                  );
                }

                Map data =
                snapshot.data!
                    .snapshot
                    .value as Map;

                List messages = [];

                data.forEach((key, value) {

                  messages.add({

                    "key": key,

                    ...Map<String, dynamic>
                        .from(value),
                  });
                });

                messages.sort(

                      (a, b) =>
                      a['timestamp']
                          .compareTo(
                          b['timestamp']),
                );

                return ListView.builder(

                  controller:
                  _scrollController,

                  padding:
                  const EdgeInsets.fromLTRB(
                      16,
                      12,
                      16,
                      12),

                  itemCount:
                  messages.length,

                  itemBuilder:
                      (context, index) {

                    final msg =
                    messages[index];

                    bool isMe =
                        msg['senderId']
                            ==
                            widget.myId;

                    return ChatBubble(

                      message:
                      msg['message'] ?? '',

                      time:
                      formatTime(
                          msg['timestamp']),

                      isMe: isMe,
                    );
                  },
                );
              },
            ),
          ),

          _ChatInputBar(

            controller:
            _messageController,

            onSend: sendMessage,
          ),
        ],
      ),
    );
  }

  // ───────────────── APP BAR ─────────────────

  Widget _buildAppBar(
      BuildContext context) {

    return SafeArea(

      bottom: false,

      child: Container(

        padding:
        const EdgeInsets.fromLTRB(
            16,
            10,
            16,
            12),

        decoration: BoxDecoration(

          color:
          AppColors.background
              .withOpacity(0.95),

          border: Border(

            bottom: BorderSide(
                color:
                AppColors.border),
          ),
        ),

        child: Row(

          children: [

            GestureDetector(

              onTap: () =>
                  Navigator.pop(context),

              child: Container(

                width: 36,
                height: 36,

                decoration: BoxDecoration(

                  color:
                  AppColors.surface,

                  borderRadius:
                  BorderRadius.circular(
                      12),

                  border: Border.all(
                    color:
                    AppColors.border,
                  ),
                ),

                child: const Icon(

                  Icons
                      .arrow_back_ios_new_rounded,

                  size: 15,

                  color:
                  AppColors.textPrimary,
                ),
              ),
            ),

            const SizedBox(width: 10),

            Container(

              width: 40,
              height: 40,

              decoration: BoxDecoration(

                gradient:
                const LinearGradient(

                  colors: [

                    Color(0xFFFF6B8A),

                    Color(0xFFFF9B6B),
                  ],

                  begin:
                  Alignment.topLeft,

                  end:
                  Alignment.bottomRight,
                ),

                borderRadius:
                BorderRadius.circular(
                    13),
              ),

              child: Center(

                child: Text(

                  widget.otherName[0]
                      .toUpperCase(),

                  style:
                  const TextStyle(

                    fontFamily: 'Sora',

                    fontSize: 16,

                    fontWeight:
                    FontWeight.w700,

                    color:
                    Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(

              child: Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  Text(

                    widget.otherName,

                    style:
                    const TextStyle(

                      fontFamily:
                      'Sora',

                      fontSize: 15,

                      fontWeight:
                      FontWeight.w600,

                      color:
                      AppColors
                          .textPrimary,
                    ),
                  ),

                  Row(

                    children: [

                      Container(

                        width: 7,
                        height: 7,

                        decoration:
                        const BoxDecoration(

                          color:
                          AppColors.success,

                          shape:
                          BoxShape.circle,
                        ),
                      ),

                      const SizedBox(
                          width: 5),

                      const Text(

                        "Online",

                        style: TextStyle(

                          fontSize: 11.5,

                          color:
                          AppColors.success,

                          fontWeight:
                          FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────── TOPIC CARD ─────────────────

  Widget _buildTopicCard() {

    return Padding(

      padding:
      const EdgeInsets.fromLTRB(
          16,
          12,
          16,
          0),

      child: Container(

        padding:
        const EdgeInsets.all(14),

        decoration: BoxDecoration(

          gradient: LinearGradient(

            colors: [

              AppColors.primary
                  .withOpacity(0.05),

              AppColors.primary
                  .withOpacity(0.09),
            ],
          ),

          borderRadius:
          BorderRadius.circular(16),

          border: Border.all(

            color:
            AppColors.primary
                .withOpacity(0.18),

            width: 1.5,
          ),
        ),

        child: Row(

          children: [

            const Text(
              "💬",
              style:
              TextStyle(fontSize: 20),
            ),

            const SizedBox(width: 10),

            Expanded(

              child: Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  Text(

                    "LIVE CHAT",

                    style: TextStyle(

                      fontSize: 10,

                      fontWeight:
                      FontWeight.w700,

                      letterSpacing: 1,

                      color:
                      AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 2),

                  const Text(

                    "Realtime Firebase Chat",

                    style: TextStyle(

                      fontFamily: 'Sora',

                      fontSize: 13,

                      fontWeight:
                      FontWeight.w600,

                      color:
                      AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────── CHAT BUBBLE ─────────────────

class ChatBubble
    extends StatelessWidget {

  final String message;

  final String time;

  final bool isMe;

  const ChatBubble({

    super.key,

    required this.message,

    required this.time,

    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {

    return Align(

      alignment:
      isMe
          ? Alignment.centerRight
          : Alignment.centerLeft,

      child: Container(

        margin:
        const EdgeInsets.only(
            bottom: 8),

        padding:
        const EdgeInsets.fromLTRB(
            14,
            10,
            14,
            8),

        constraints:
        const BoxConstraints(
            maxWidth: 260),

        decoration: BoxDecoration(

          gradient: isMe
              ? LinearGradient(

            colors: [

              AppColors.primary,

              AppColors.primary
                  .withBlue(200),
            ],

            begin:
            Alignment.topLeft,

            end:
            Alignment.bottomRight,
          )
              : null,

          color:
          isMe
              ? null
              : Colors.white,

          borderRadius:
          BorderRadius.only(

            topLeft:
            const Radius.circular(
                18),

            topRight:
            const Radius.circular(
                18),

            bottomLeft:
            Radius.circular(
                isMe ? 18 : 6),

            bottomRight:
            Radius.circular(
                isMe ? 6 : 18),
          ),

          border: isMe
              ? null
              : Border.all(

            color:
            AppColors.border,

            width: 1.5,
          ),
        ),

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.end,

          children: [

            Text(

              message,

              style: TextStyle(

                fontSize: 13.5,

                height: 1.5,

                color: isMe
                    ? Colors.white
                    : AppColors
                    .textPrimary,
              ),
            ),

            const SizedBox(height: 4),

            Text(

              time,

              style: TextStyle(

                fontSize: 10,

                color: isMe
                    ? Colors.white
                    .withOpacity(
                    0.6)
                    : AppColors
                    .textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────── INPUT BAR ─────────────────

class _ChatInputBar
    extends StatelessWidget {

  final TextEditingController
  controller;

  final VoidCallback onSend;

  const _ChatInputBar({

    required this.controller,

    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      padding:
      const EdgeInsets.fromLTRB(
          12,
          10,
          12,
          24),

      decoration: BoxDecoration(

        color:
        AppColors.background,

        border: Border(

          top: BorderSide(
              color:
              AppColors.border),
        ),
      ),

      child: Row(

        children: [

          Expanded(

            child: Container(

              padding:
              const EdgeInsets.symmetric(
                horizontal: 16,
              ),

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius:
                BorderRadius.circular(
                    16),

                border: Border.all(

                  color:
                  AppColors.border,

                  width: 1.5,
                ),
              ),

              child: TextField(

                controller: controller,

                decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Message...",
                hintStyle: TextStyle(
                  fontSize: 13.5,
                  color: AppColors.textMuted,
                ),
              ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          GestureDetector(

            onTap: onSend,

            child: Container(

              width: 44,
              height: 44,

              decoration:
              BoxDecoration(

                gradient:
                LinearGradient(

                  colors: [

                    AppColors.primary,

                    AppColors.primary
                        .withBlue(220),
                  ],

                  begin:
                  Alignment.topLeft,

                  end:
                  Alignment.bottomRight,
                ),

                borderRadius:
                BorderRadius.circular(
                    15),

                boxShadow: [

                  BoxShadow(

                    color:
                    AppColors.primary
                        .withOpacity(
                        0.35),

                    blurRadius: 16,

                    offset:
                    const Offset(
                        0,
                        6),
                  ),
                ],
              ),

              child: const Icon(

                Icons.send_rounded,

                color: Colors.white,

                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}