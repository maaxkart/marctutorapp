import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() =>
      _ChatListScreenState();
}

class _ChatListScreenState
    extends State<ChatListScreen> {

  List students = [];

  bool loading = true;

  int myId = 0;

  @override
  void initState() {
    super.initState();

    loadStudents();
  }

  Future<void> loadStudents() async {

    final data =
    await ApiService.chatStudents();

    final tokenData =
    await ApiService.profile();

    debugPrint(
        "PROFILE RESPONSE : $tokenData");

    setState(() {

      students = data;

      // FIX NULL ERROR
      myId =
          tokenData['id'] ??
              tokenData['user']?['id'] ??
              0;

      loading = false;
    });
  }

  String roomId(
      int a,
      int b,
      ) {

    List ids = [a, b];

    ids.sort();

    return "${ids[0]}_${ids[1]}";
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      AppColors.background,

      body: SafeArea(

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            _buildAppBar(),

            _buildSearchBar(),

            _buildSectionLabel(
                "Students"),

            Expanded(

              child: loading

                  ? const Center(
                child:
                CircularProgressIndicator(),
              )

                  : ListView.builder(

                padding:
                const EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    20),

                itemCount:
                students.length,

                itemBuilder:
                    (context, i) {

                  final student =
                  students[i];

                  return StreamBuilder(

                    stream:
                    FirebaseDatabase
                        .instance
                        .ref()
                        .child(
                        "chat_rooms")
                        .child(
                        roomId(
                          myId,
                          student['id'],
                        ))
                        .child(
                        "messages")
                        .limitToLast(1)
                        .onValue,

                    builder:
                        (context,
                        snapshot) {

                      String lastMsg =
                          "Start chatting";

                      String time =
                          "";

                      if (snapshot
                          .hasData &&
                          snapshot
                              .data!
                              .snapshot
                              .value !=
                              null) {

                        Map data =
                        snapshot
                            .data!
                            .snapshot
                            .value
                        as Map;

                        data.forEach(
                                (key,
                                value) {

                              lastMsg =
                                  value[
                                  'message'] ??
                                      '';

                              if (value[
                              'timestamp'] !=
                                  null) {

                                DateTime dt =
                                DateTime
                                    .fromMillisecondsSinceEpoch(
                                  value[
                                  'timestamp'],
                                );

                                time =
                                "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
                              }
                            });
                      }

                      return _ChatTile(

                        name:
                        student['name'] ??
                            'Student',

                        message:
                        lastMsg,

                        time: time,

                        onTap: () {

                          Navigator.push(

                            context,

                            MaterialPageRoute(

                              builder:
                                  (_) =>
                                  ChatScreen(

                                    myId:
                                    myId,

                                    otherUserId:
                                    student['id'],

                                    otherName:
                                    student['name'] ??
                                        '',
                                  ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // APP BAR
  // =========================================================

  Widget _buildAppBar() {

    return Padding(

      padding:
      const EdgeInsets.fromLTRB(
          20,
          16,
          16,
          4),

      child: Row(

        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,

        children: [

          Column(

            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              const Text(

                "Messages",

                style: TextStyle(

                  fontFamily: 'Sora',

                  fontSize: 26,

                  fontWeight:
                  FontWeight.w700,

                  color:
                  AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 2),

              Text(

                "${students.length} active students",

                style: TextStyle(

                  fontSize: 13,

                  color:
                  AppColors.textMuted,
                ),
              ),
            ],
          ),

          Container(

            width: 38,
            height: 38,

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

              Icons.more_vert_rounded,

              size: 18,

              color:
              AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SEARCH
  // =========================================================

  Widget _buildSearchBar() {

    return Padding(

      padding:
      const EdgeInsets.fromLTRB(
          20,
          12,
          20,
          0),

      child: Container(

        padding:
        const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 11),

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius:
          BorderRadius.circular(16),

          border: Border.all(
              color:
              AppColors.border),
        ),

        child: Row(

          children: [

            Icon(

              Icons.search_rounded,

              size: 17,

              color:
              AppColors.textMuted,
            ),

            const SizedBox(width: 10),

            Expanded(

              child: TextField(

                decoration:
                InputDecoration(

                  hintText:
                  "Search students...",

                  border:
                  InputBorder.none,

                  isDense: true,

                  contentPadding:
                  EdgeInsets.zero,

                  hintStyle:
                  TextStyle(

                    fontSize: 14,

                    color:
                    AppColors
                        .textMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // LABEL
  // =========================================================

  Widget _buildSectionLabel(
      String label) {

    return Padding(

      padding:
      const EdgeInsets.fromLTRB(
          20,
          18,
          20,
          8),

      child: Text(

        label.toUpperCase(),

        style: TextStyle(

          fontSize: 11,

          fontWeight:
          FontWeight.w700,

          letterSpacing: 1.2,

          color:
          AppColors.textMuted,
        ),
      ),
    );
  }
}

// =========================================================
// CHAT TILE
// =========================================================

class _ChatTile
    extends StatelessWidget {

  final String name;

  final String message;

  final String time;

  final VoidCallback onTap;

  const _ChatTile({

    required this.name,

    required this.message,

    required this.time,

    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(

      onTap: onTap,

      child: Container(

        margin:
        const EdgeInsets.only(
            bottom: 8),

        padding:
        const EdgeInsets.all(14),

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius:
          BorderRadius.circular(20),

          border: Border.all(
            color:
            AppColors.border,
          ),
        ),

        child: Row(

          children: [

            Container(

              width: 50,
              height: 50,

              decoration: BoxDecoration(

                gradient:
                LinearGradient(

                  colors: [

                    AppColors.primary,

                    AppColors.primary
                        .withBlue(220),
                  ],
                ),

                borderRadius:
                BorderRadius.circular(
                    16),
              ),

              child: Center(

                child: Text(

                  name[0]
                      .toUpperCase(),

                  style:
                  const TextStyle(

                    fontFamily:
                    'Sora',

                    fontSize: 18,

                    fontWeight:
                    FontWeight.w700,

                    color:
                    Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(

              child: Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  Text(

                    name,

                    style:
                    const TextStyle(

                      fontFamily:
                      'Sora',

                      fontSize: 14,

                      fontWeight:
                      FontWeight.w600,

                      color:
                      AppColors
                          .textPrimary,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(

                    message,

                    maxLines: 1,

                    overflow:
                    TextOverflow
                        .ellipsis,

                    style: TextStyle(

                      fontSize: 12.5,

                      color:
                      AppColors
                          .textMuted,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            Text(

              time,

              style: TextStyle(

                fontSize: 11,

                color:
                AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}