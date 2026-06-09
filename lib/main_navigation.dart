import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home/home_screen.dart';
import 'screens/live/live_screen.dart';
import 'screens/chat/chat_list_screen.dart';
import 'screens/profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _current = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    LiveScreen(),
    ChatListScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _current, children: _screens),
      bottomNavigationBar: _buildNav(),
    );
  }

  Widget _buildNav() {
    final items = [
      {
        'icon': Icons.dashboard_rounded,
        'activeIcon': Icons.dashboard,
        'label': 'Home'
      },
      {
        'icon': Icons.videocam_outlined,
        'activeIcon': Icons.videocam,
        'label': 'Classes'
      },
      {
        'icon': Icons.chat_bubble_outline_rounded,
        'activeIcon': Icons.chat_bubble,
        'label': 'Chat'
      },
      {
        'icon': Icons.person_outline_rounded,
        'activeIcon': Icons.person,
        'label': 'Profile'
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Container(
        height: 75,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 25,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.asMap().entries.map((e) {
            final index = e.key;
            final item = e.value;
            final selected = _current == index;
            final isLive = index == 1;

            return GestureDetector(
              onTap: () => setState(() => _current = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glow effect
                        if (selected)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isLive
                                  ? AppColors.liveSoft
                                  : AppColors.primarySoft,
                              shape: BoxShape.circle,
                            ),
                          ),

                        Icon(
                          selected
                              ? item['activeIcon'] as IconData
                              : item['icon'] as IconData,
                          size: 24,
                          color: selected
                              ? (isLive
                              ? AppColors.live
                              : AppColors.primary)
                              : AppColors.textMuted,
                        ),

                        // 🔴 Live dot
                        if (isLive)
                          Positioned(
                            top: 2,
                            right: 2,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.live,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w400,
                        color: selected
                            ? (isLive
                            ? AppColors.live
                            : AppColors.primary)
                            : AppColors.textMuted,
                      ),
                      child: Text(item['label'] as String),
                    ),

                    const SizedBox(height: 4),

                    // Bottom active indicator
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 3,
                      width: selected ? 18 : 0,
                      decoration: BoxDecoration(
                        color: isLive
                            ? AppColors.live
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    )
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}