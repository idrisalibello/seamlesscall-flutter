import 'package:flutter/material.dart';
import 'package:seamlesscall/features/auth/presentation/login_screen.dart';
import '../../../common/widgets/logo_widget.dart';
import '../../../common/widgets/gradient_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _current = 0;

  late final AnimationController _bgController;
  late final Animation<Alignment> _alignmentAnim;

  late final AnimationController _staggerController;

  final _pages = [
    {
      "title": "Book a handyman in minutes",
      "subtitle": "Find trusted help near you — fast and easy.",
    },
    {
      "title": "Secure payments & scheduling",
      "subtitle": "Pay securely and choose the time that works for you.",
    },
    {
      "title": "Manage jobs & earnings",
      "subtitle": "Tools for handymen to manage jobs, photos and payouts.",
    },
  ];

  @override
  void initState() {
    super.initState();

    // Background gradient animation
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _alignmentAnim = AlignmentTween(
      begin: const Alignment(-0.9, -0.7),
      end: const Alignment(0.9, 0.7),
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));

    // Staggered content animation controller
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _staggerController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bgController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  void _restartStaggerAnimation() {
    _staggerController.reset();
    _staggerController.forward();
  }

  Widget _animatedItem({
    required Widget child,
    required double start,
    required double end,
  }) {
    final fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );

    final slide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _staggerController,
            curve: Interval(start, end, curve: Curves.easeOutCubic),
          ),
        );

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }

  Widget _buildPage(Map<String, dynamic> page) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _animatedItem(start: 0.0, end: 0.3, child: const LogoWidget()),
              const SizedBox(height: 20),
              _animatedItem(
                start: 0.2,
                end: 0.5,
                child: Image.asset('assets/images/logo4.png', height: 200),
              ),
              const SizedBox(height: 28),
              _animatedItem(
                start: 0.4,
                end: 0.7,
                child: Text(
                  page['title'],
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _animatedItem(
                start: 0.6,
                end: 0.9,
                child: Text(
                  page['subtitle'],
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _alignmentAnim,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: const [
                  Color.fromARGB(255, 4, 23, 59),
                  Color.fromARGB(255, 1, 62, 95),
                ],
                begin: _alignmentAnim.value,
                end: Alignment(
                  -_alignmentAnim.value.x,
                  -_alignmentAnim.value.y,
                ),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _pages.length,
                      onPageChanged: (i) {
                        setState(() => _current = i);
                        _restartStaggerAnimation();
                      },
                      itemBuilder: (context, index) {
                        return _buildPage(_pages[index]);
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _pages.length,
                            (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 350),
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              width: _current == i ? 24 : 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(
                                  _current == i ? 0.95 : 0.4,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          child: _current == _pages.length - 1
                              ? GradientButton(
                                  key: const ValueKey('start'),
                                  label: 'Get Started',
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const LoginScreen(),
                                      ),
                                    );
                                  },
                                )
                              : GradientButton(
                                  key: ValueKey('next_$_current'),
                                  label: 'Next',
                                  onPressed: () {
                                    _pageController.nextPage(
                                      duration: const Duration(
                                        milliseconds: 450,
                                      ),
                                      curve: Curves.easeInOut,
                                    );
                                  },
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
    );
  }
}
