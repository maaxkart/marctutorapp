import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../login/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController _logoCtrl;
  late AnimationController _barCtrl;
  late AnimationController _shimmerCtrl;

  // Logo animations
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;

  // Bar animations
  late Animation<double> _barFade;
  late Animation<double> _barProgress;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    // Logo pops in with elastic bounce
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Bar fills
    _barCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    // Shimmer loop
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _barFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _barCtrl,
        curve: const Interval(0.0, 0.15, curve: Curves.easeOut),
      ),
    );

    _barProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _barCtrl,
        curve: const Interval(0.05, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Start logo, then bar after short delay
    _logoCtrl.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _barCtrl.forward();
    });

    // Navigate after 3.2s
    Timer(const Duration(milliseconds: 3200), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const LoginScreen(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _barCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoSize = size.width * 0.70; // BIG logo

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: Listenable.merge([_logoCtrl, _barCtrl, _shimmerCtrl]),
        builder: (_, __) {
          return Stack(
            children: [

              // ── Big centered logo ──────────────────────────────────────────
              Center(
                child: Transform.scale(
                  scale: _logoScale.value,
                  child: Opacity(
                    opacity: _logoFade.value,
                    child: Image.asset(
                      'assets/images/marc_logo.png',
                      width: logoSize,
                      height: logoSize,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => _fallback(logoSize),
                    ),
                  ),
                ),
              ),

              // ── Bottom loading bar ─────────────────────────────────────────
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(36, 0, 36, 48),
                    child: Opacity(
                      opacity: _barFade.value,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          // Progress bar with shimmer
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              height: 4,
                              child: Stack(children: [
                                // Track
                                Container(color: const Color(0xFFECEDF3)),

                                // Filled portion
                                FractionallySizedBox(
                                  widthFactor: _barProgress.value,
                                  child: AnimatedBuilder(
                                    animation: _shimmerCtrl,
                                    builder: (_, __) => Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFF08BD80),
                                            const Color(0xFF08BD80)
                                                .withOpacity(0.55),
                                            Colors.white.withOpacity(0.85),
                                            const Color(0xFF08BD80)
                                                .withOpacity(0.55),
                                            const Color(0xFF08BD80),
                                          ],
                                          stops: [
                                            0.0,
                                            (_shimmerCtrl.value - 0.2)
                                                .clamp(0.0, 1.0),
                                            _shimmerCtrl.value.clamp(0.0, 1.0),
                                            (_shimmerCtrl.value + 0.2)
                                                .clamp(0.0, 1.0),
                                            1.0,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Version
                          Text(
                            'v2.0.0',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _fallback(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.22),
        gradient: const LinearGradient(
          colors: [Color(0xFF6C3CE7), Color(0xFFD63CF0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text('M',
          style: TextStyle(
            fontSize: size * 0.46,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -2,
          ),
        ),
      ),
    );
  }
}