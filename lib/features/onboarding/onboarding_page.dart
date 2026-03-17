import 'package:flutter/material.dart';
import '../../core/hive/settings_box.dart';
import '../../core/auth/auth_gate.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _page = PageController();
  int _index = 0;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = <_OnboardCard>[
      _OnboardCard(
        image: 'assets/onboarding/organize.png',
        title: 'Organize seus\nfilmes, séries\ne doramas',
        subtitle: 'Planeje maratonas e nunca mais se perca no que assistir.',
        cta: 'Continuar',
        onPressed: _next,
      ),
      _OnboardCard(
        image: 'assets/onboarding/agenda.png',
        title: 'Agende e planeje',
        subtitle:
            'Escolha dias e horários, crie playlists e maratonas do seu jeito.',
        cta: 'Continuar',
        onPressed: _next,
        innerDots: true,
      ),
      _OnboardCard(
        image: 'assets/onboarding/progresso.png',
        title: 'Veja seu progresso',
        subtitle:
            'Acompanhe estatísticas e compartilhe relatórios do seu consumo.',
        cta: 'Começar agora',
        onPressed: () async {
          await SettingsBox.setSeenOnboarding();
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AuthGate()),
          );
        },
        innerDots: true,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FB),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Expanded(
              child: PageView.builder(
                controller: _page,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => pages[i],
              ),
            ),
            const SizedBox(height: 8),
            _Dots(count: pages.length, index: _index),
            const SizedBox(height: 6),
            // “barra” inferior (detalhe visual do mock)
            Container(
              margin: const EdgeInsets.only(bottom: 10, top: 4),
              height: 4,
              width: 160,
              decoration: BoxDecoration(
                color: const Color(0xFF0D2B57),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _next() => _page.nextPage(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
}

class _OnboardCard extends StatelessWidget {
  const _OnboardCard({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.onPressed,
    this.innerDots = false,
  });

  final String image, title, subtitle, cta;
  final VoidCallback onPressed;
  final bool innerDots;

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF0D2B57);
    const orange = Color(0xFFF28C18);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
          child: Column(
            children: [
              Expanded(
                child: Center(child: Image.asset(image, fit: BoxFit.contain)),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: blue,
                  fontSize: 28,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF3A4A64),
                  fontSize: 16,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),
              if (innerDots) const _Dots(count: 3, index: 1, size: 7, spacing: 8),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  onPressed: onPressed,
                  child: Text(cta),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({
    required this.count,
    required this.index,
    this.size = 6,
    this.spacing = 6,
    this.activeColor = const Color(0xFF0D2B57),
    this.inactiveColor = const Color(0xFFB8C0CF),
  });

  final int count, index;
  final double size, spacing;
  final Color activeColor, inactiveColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final on = i == index;
        return Container(
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          width: on ? size + 4 : size,
          height: on ? size + 4 : size,
          decoration: BoxDecoration(
            color: on ? activeColor : inactiveColor,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
