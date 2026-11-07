import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Marco responsive: apariencia de app en móvil y ancho de lectura en web.
class AppFrame extends StatelessWidget {
  const AppFrame({
    super.key,
    required this.title,
    required this.child,
    this.actions = const [],
    this.leading,
  });
  final String title;
  final Widget child;
  final List<Widget> actions;
  final Widget? leading;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      toolbarHeight: 66,
      title: Text(title),
      leading: leading,
      actions: actions,
      flexibleSpace: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.navyDeep, AppColors.navy, Color(0xFF176A93)],
          ),
        ),
      ),
    ),
    body: Stack(children: [
      const Positioned.fill(child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE7F3FC), AppColors.background, Colors.white],
          ),
        ),
      )),
      const Positioned(top: -110, right: -120,
        child: _GlowingOrb(size: 275, color: Color(0x2421B9CE))),
      const Positioned(bottom: 45, left: -100,
        child: _GlowingOrb(size: 240, color: Color(0x17167DB6))),
      Positioned(bottom: 0, left: 0, right: 0,
        child: IgnorePointer(child: SizedBox(height: 43,
          child: CustomPaint(painter: WavePainter())))),
      SafeArea(child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: SizedBox(width: double.infinity, height: double.infinity,
            child: child),
        ),
      )),
    ]),
  );
}

class _GlowingOrb extends StatelessWidget {
  const _GlowingOrb({required this.size, required this.color});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final wave1 = Path()..moveTo(0, 20)
      ..quadraticBezierTo(size.width * .23, -4, size.width * .5, 23)
      ..quadraticBezierTo(size.width * .78, 47, size.width, 10)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)..close();
    canvas.drawPath(wave1, Paint()..color = const Color(0x3321B9CE));
    final wave2 = Path()..moveTo(0, 36)
      ..quadraticBezierTo(size.width * .36, 8, size.width * .62, 37)
      ..quadraticBezierTo(size.width * .82, 51, size.width, 28)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)..close();
    canvas.drawPath(wave2, Paint()..color = const Color(0x2A1379B8));
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });
  final Widget child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(23),
      border: Border.all(color: const Color(0xFFE4ECF3)),
      boxShadow: [
        BoxShadow(color: AppColors.navy.withOpacity(.055),
          blurRadius: 23, offset: const Offset(0, 9)),
      ],
    ),
    child: child,
  );
}

class ZoneBanner extends StatelessWidget {
  const ZoneBanner({super.key, required this.zone});
  final int zone;
  @override
  Widget build(BuildContext context) {
    final accent = zone == 1 ? AppColors.sea : AppColors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: zone == 1
          ? [const Color(0xFFE5F4FF), const Color(0xFFF0FAFF)]
          : [const Color(0xFFE1F7ED), const Color(0xFFF2FCF7)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(.18)),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: accent.withOpacity(.13),
            borderRadius: BorderRadius.circular(13)),
          child: Icon(Icons.location_on_rounded, color: accent, size: 24),
        ),
        const SizedBox(width: 11),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Zona seleccionada', style: TextStyle(
            fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text('ZONA $zone', style: TextStyle(color: accent,
            fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: .5)),
        ]),
        const Spacer(),
        Icon(Icons.check_circle_rounded, color: accent, size: 21),
      ]),
    );
  }
}

/// Títulos de bloque con icono y acento.
class SectionHeading extends StatelessWidget {
  const SectionHeading({super.key, required this.label, required this.icon,
    this.color = AppColors.sea});
  final String label;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(
      width: 34, height: 34,
      decoration: BoxDecoration(color: color.withOpacity(.1),
        borderRadius: BorderRadius.circular(11)),
      child: Icon(icon, size: 19, color: color),
    ),
    const SizedBox(width: 10),
    Expanded(child: Text(label, style: const TextStyle(
      color: AppColors.ink, fontSize: 16, fontWeight: FontWeight.w800))),
  ]);
}

void showAppMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

Future<DateTime?> selectRecordDate(BuildContext context, DateTime current) async =>
  showDatePicker(
    context: context,
    initialDate: current,
    firstDate: DateTime(2020),
    lastDate: DateTime(2100),
    locale: const Locale('es'),
  );
