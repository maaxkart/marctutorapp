import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';
import '../../main_navigation.dart';
// ── Palette ───────────────────────────────────────────────────────────────────
class _C {
  static const bg       = Color(0xFFF4F6FB);
  static const surface  = Color(0xFFFFFFFF);
  static const emerald  = Color(0xFF08BD80);
  static const emeraldD = Color(0xFF06A870);
  static const violet   = Color(0xFF6C3CE7);
  static const magenta  = Color(0xFFD63CF0);
  static const textPri  = Color(0xFF0D1021);
  static const textSub  = Color(0xFF5A5F7D);
  static const textMute = Color(0xFFADB2C8);
  static const border   = Color(0xFFE3E6F0);
  static const inputBg  = Color(0xFFF0F2FA);
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {

  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _hidePass    = true;
  bool _loading     = false;
  bool _emailFocus  = false;
  bool _passFocus   = false;

  late AnimationController _entryCtrl;  // staggered entry
  late AnimationController _btnCtrl;    // press scale

  // Entry anims
  late Animation<double> _logoFade, _logoScale, _logoSlide;
  late Animation<double> _headFade, _headSlide;
  late Animation<double> _f1Fade,   _f1Slide;
  late Animation<double> _f2Fade,   _f2Slide;
  late Animation<double> _forgotFade;
  late Animation<double> _btnFade,   _btnSlide, _btnScale;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1300));
    _btnCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 110));

    // ── Logo ──────────────────────────────────────────────────────────────
    _logoFade  = _iv(0.00, 0.30);
    _logoScale = _tw(0.55, 1.0, 0.00, 0.45, curve: Curves.easeOutBack);
    _logoSlide = _tw(30.0, 0.0,  0.00, 0.38);

    // ── Header ────────────────────────────────────────────────────────────
    _headFade  = _iv(0.22, 0.46);
    _headSlide = _tw(16.0, 0.0,  0.22, 0.46);

    // ── Fields ────────────────────────────────────────────────────────────
    _f1Fade    = _iv(0.35, 0.57);
    _f1Slide   = _tw(14.0, 0.0, 0.35, 0.57);
    _f2Fade    = _iv(0.46, 0.66);
    _f2Slide   = _tw(14.0, 0.0, 0.46, 0.66);

    // ── Forgot ────────────────────────────────────────────────────────────
    _forgotFade = _iv(0.56, 0.72);

    // ── Button ────────────────────────────────────────────────────────────
    _btnFade   = _iv(0.64, 0.84);
    _btnSlide  = _tw(12.0, 0.0, 0.64, 0.84);
    _btnScale  = _tw(1.0,  0.95, 0.0, 1.0, ctrl: _btnCtrl);

    _entryCtrl.forward();
  }

  // ── Animation helpers ─────────────────────────────────────────────────────

  Animation<double> _iv(double s, double e,
      {Curve curve = Curves.easeOut,
        AnimationController? ctrl}) =>
      CurvedAnimation(
          parent: ctrl ?? _entryCtrl,
          curve: Interval(s, e, curve: curve));

  Animation<double> _tw(double begin, double end, double s, double e,
      {Curve curve = Curves.easeOut,
        AnimationController? ctrl}) =>
      Tween<double>(begin: begin, end: end).animate(
          CurvedAnimation(
              parent: ctrl ?? _entryCtrl,
              curve: Interval(s, e, curve: curve)));

  @override
  void dispose() {
    _entryCtrl.dispose();
    _btnCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ── Login logic ───────────────────────────────────────────────────────────

  Future<void> _login() async {
    if (_emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      _snack('Please enter email & password', error: true);
      return;
    }
    setState(() => _loading = true);
    try {
      final res = await ApiService.login(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );
      setState(() => _loading = false);
      if (res['status'] == true) {
        _snack('Welcome back! 🎉', error: false);
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => MainNavigation(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (_, a, __, child) =>
                FadeTransition(opacity: a, child: child),
          ),
        );
      } else {
        _snack(res['message'] ?? 'Login failed', error: true);
      }
    } catch (e) {
      setState(() => _loading = false);
      _snack('Error: $e', error: true);
    }
  }

  void _snack(String msg, {required bool error}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(
          error
              ? Icons.error_outline_rounded
              : Icons.check_circle_outline_rounded,
          color: Colors.white, size: 16,
        ),
        const SizedBox(width: 10),
        Expanded(
            child: Text(msg,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500))),
      ]),
      backgroundColor: error ? const Color(0xFFD32F2F) : _C.emerald,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      margin: const EdgeInsets.all(16),
    ));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: AnimatedBuilder(
        animation: _entryCtrl,
        builder: (_, __) {
          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.06),

                  // ── Logo ─────────────────────────────────────────────────
                  _buildLogo(size),

                  SizedBox(height: size.height * 0.048),

                  // ── Sign In heading ───────────────────────────────────────
                  _buildHeader(),

                  const SizedBox(height: 30),

                  // ── Email field ───────────────────────────────────────────
                  _animWrap(
                    fade: _f1Fade, slide: _f1Slide,
                    child: _label('Email Address'),
                  ),
                  const SizedBox(height: 8),
                  _animWrap(
                    fade: _f1Fade, slide: _f1Slide,
                    child: _field(
                      ctrl: _emailCtrl,
                      hint: 'you@example.com',
                      icon: Icons.alternate_email_rounded,
                      focused: _emailFocus,
                      onFocus: (v) => setState(() => _emailFocus = v),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Password field ────────────────────────────────────────
                  _animWrap(
                    fade: _f2Fade, slide: _f2Slide,
                    child: _label('Password'),
                  ),
                  const SizedBox(height: 8),
                  _animWrap(
                    fade: _f2Fade, slide: _f2Slide,
                    child: _field(
                      ctrl: _passwordCtrl,
                      hint: '••••••••',
                      icon: Icons.lock_outline_rounded,
                      isPass: true,
                      focused: _passFocus,
                      onFocus: (v) => setState(() => _passFocus = v),
                    ),
                  ),

                  // ── Forgot password ───────────────────────────────────────
                  Opacity(
                    opacity: _forgotFade.value,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 2),
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: _C.emerald,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  // ── Sign In button ────────────────────────────────────────
                  _animWrap(
                    fade: _btnFade, slide: _btnSlide,
                    child: _submitBtn(),
                  ),

                  const SizedBox(height: 44),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Logo — just the image, no circle, no text ─────────────────────────────

  Widget _buildLogo(Size size) {
    return Transform.translate(
      offset: Offset(0, _logoSlide.value),
      child: Opacity(
        opacity: _logoFade.value,
        child: Transform.scale(
          scale: _logoScale.value,
          child: Image.asset(
            'assets/images/marc_logo.png',
            width: size.width * 0.34,
            height: size.width * 0.34,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _fallbackLogo(size.width * 0.34),
          ),
        ),
      ),
    );
  }

  Widget _fallbackLogo(double s) {
    return Container(
      width: s, height: s,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(s * 0.22),
        gradient: const LinearGradient(
          colors: [_C.violet, _C.magenta],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text('M',
            style: TextStyle(
              fontSize: s * 0.44,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -2,
            )),
      ),
    );
  }

  // ── Sign In heading ───────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Transform.translate(
      offset: Offset(0, _headSlide.value),
      child: Opacity(
        opacity: _headFade.value,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Accent pill + title row
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Container(
              width: 4, height: 30,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_C.emerald, _C.violet],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            const Text('Sign In',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: _C.textPri,
                  letterSpacing: -0.8,
                )),
          ]),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text('Enter your credentials to continue',
                style: TextStyle(
                  fontSize: 13,
                  color: _C.textSub,
                  fontWeight: FontWeight.w400,
                )),
          ),
        ]),
      ),
    );
  }

  // ── Field label ───────────────────────────────────────────────────────────

  Widget _label(String text) => Text(text,
      style: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        color: _C.textSub,
        letterSpacing: 0.1,
      ));

  // ── Input field ───────────────────────────────────────────────────────────

  Widget _field({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    bool isPass = false,
    required bool focused,
    required ValueChanged<bool> onFocus,
  }) {
    return Focus(
      onFocusChange: onFocus,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: focused ? _C.surface : _C.inputBg,
          border: Border.all(
            color: focused ? _C.emerald.withOpacity(0.70) : _C.border,
            width: focused ? 1.5 : 1.0,
          ),
          boxShadow: focused
              ? [BoxShadow(
            color: _C.emerald.withOpacity(0.10),
            blurRadius: 16,
          )]
              : [],
        ),
        child: TextField(
          controller: ctrl,
          obscureText: isPass ? _hidePass : false,
          keyboardType: isPass
              ? TextInputType.visiblePassword
              : TextInputType.emailAddress,
          style: const TextStyle(
            color: _C.textPri, fontSize: 14.5, fontWeight: FontWeight.w500,
          ),
          cursorColor: _C.emerald,
          cursorWidth: 1.6,
          decoration: InputDecoration(
            filled: false,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
            prefixIcon: Icon(icon,
                color: focused ? _C.emerald : _C.textMute, size: 19),
            suffixIcon: isPass
                ? GestureDetector(
              onTap: () => setState(() => _hidePass = !_hidePass),
              child: Icon(
                _hidePass
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: _C.textMute, size: 18,
              ),
            )
                : null,
            hintText: hint,
            hintStyle: const TextStyle(
                color: _C.textMute,
                fontSize: 13.5,
                fontWeight: FontWeight.w400),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
      ),
    );
  }

  // ── Submit button ─────────────────────────────────────────────────────────

  Widget _submitBtn() {
    return GestureDetector(
      onTapDown: (_) => _btnCtrl.forward(),
      onTapUp: (_) async {
        await _btnCtrl.reverse();
        _login();
      },
      onTapCancel: () => _btnCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _btnCtrl,
        builder: (_, __) => Transform.scale(
          scale: _btnScale.value,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: const LinearGradient(
                colors: [_C.emerald, _C.emeraldD],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: _C.emerald.withOpacity(0.30),
                  blurRadius: 22, offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: _loading
                  ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.2))
                  : const Row(mainAxisSize: MainAxisSize.min, children: [
                Text('Sign In',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    )),
                SizedBox(width: 10),
                Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 18),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  // ── Animated wrapper ──────────────────────────────────────────────────────

  Widget _animWrap({
    required Animation<double> fade,
    required Animation<double> slide,
    required Widget child,
  }) {
    return Transform.translate(
      offset: Offset(0, slide.value),
      child: Opacity(opacity: fade.value, child: child),
    );
  }
}