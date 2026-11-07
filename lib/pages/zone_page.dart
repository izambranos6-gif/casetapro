import 'package:flutter/material.dart';
import '../core/pools.dart';
import '../core/theme.dart';
import '../widgets/app_frame.dart';
import 'home_page.dart';

/// Pantalla inicial aprobada: elegir la zona ANTES del menú.
class ZonePage extends StatelessWidget {
  const ZonePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(children: [
      const Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0, .35, .70, 1],
          colors: [AppColors.navyDeep, Color(0xFF115B88),
            Color(0xFFE1F4FA), Color(0xFFF5FAFD)]),
      ))),
      Positioned(top: -110, right: -90, child: Container(width: 250, height: 250,
        decoration: BoxDecoration(shape: BoxShape.circle,
          color: Colors.white.withOpacity(.035)))),
      Positioned(top: 80, left: -130, child: Container(width: 290, height: 290,
        decoration: BoxDecoration(shape: BoxShape.circle,
          color: Colors.white.withOpacity(.035)))),
      Positioned(bottom: 0, left: 0, right: 0,
        child: IgnorePointer(child: SizedBox(height: 78,
          child: CustomPaint(painter: WavePainter())))),
      SafeArea(child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(padding: const EdgeInsets.fromLTRB(19, 22, 19, 78),
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(width: 54, height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.14),
                  border: Border.all(color: Colors.white.withOpacity(.3)),
                  borderRadius: BorderRadius.circular(17)),
                child: const Icon(Icons.waves_rounded,
                  size: 31, color: Colors.white)),
              const SizedBox(width: 12),
              const Flexible(child: Text('Seleccionar Zona',
                style: TextStyle(color: Colors.white, fontSize: 27,
                  fontWeight: FontWeight.w900, letterSpacing: -.8))),
            ]),
            const SizedBox(height: 10),
            const Text('Elige la zona donde registrarás el balanceado',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFFD4EBF6), fontSize: 13.5)),
            const SizedBox(height: 33),
            _ZoneTile(zone: 1, count: Pools.zone1.length),
            const SizedBox(height: 18),
            _ZoneTile(zone: 2, count: Pools.zone2.length),
            const SizedBox(height: 34),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.verified_outlined, color: AppColors.navy.withOpacity(.65),
                size: 18),
              const SizedBox(width: 7),
              const Text('Control de Balanceado',
                style: TextStyle(color: AppColors.navy,
                  fontWeight: FontWeight.w800, fontSize: 13)),
            ]),
          ],
        ),
      ))),
    ]),
  );
}

class _ZoneTile extends StatelessWidget {
  const _ZoneTile({required this.zone, required this.count});
  final int zone;
  final int count;
  @override
  Widget build(BuildContext context) {
    final accent = zone == 1 ? AppColors.sea : AppColors.green;
    return Material(color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => HomePage(zone: zone))),
        child: Container(
          height: 168,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: LinearGradient(begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: zone == 1
                ? [const Color(0xFFF3FBFF), const Color(0xFFD7EFFB)]
                : [const Color(0xFFF2FCF7), const Color(0xFFD6F2E7)]),
            border: Border.all(color: Colors.white, width: 2.4),
            boxShadow: [BoxShadow(color: AppColors.navy.withOpacity(.20),
              blurRadius: 20, offset: const Offset(0, 12))],
          ),
          child: ClipRRect(borderRadius: BorderRadius.circular(23),
            child: Stack(children: [
              Positioned(bottom: 0, left: 0, right: 0,
                height: 69, child: CustomPaint(painter: _PoolLandscape(
                  color: accent))),
              Padding(padding: const EdgeInsets.all(19), child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 51, height: 51,
                    decoration: BoxDecoration(color: accent,
                      borderRadius: BorderRadius.circular(17)),
                    child: const Icon(Icons.location_on_rounded,
                      size: 30, color: Colors.white)),
                  const SizedBox(width: 13),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ZONA $zone', style: const TextStyle(
                        color: AppColors.navyDeep, fontSize: 27,
                        fontWeight: FontWeight.w900, letterSpacing: -.8)),
                      const SizedBox(height: 4),
                      Text('$count piscinas', style: TextStyle(color: accent,
                        fontWeight: FontWeight.w800, fontSize: 15)),
                    ])),
                  Container(width: 38, height: 38,
                    decoration: BoxDecoration(color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: accent.withOpacity(.11),
                        blurRadius: 12)]),
                    child: Icon(Icons.arrow_forward_rounded, color: accent)),
                ],
              )),
              Positioned(right: 16, bottom: 12,
                child: Icon(Icons.water_rounded, size: 27,
                  color: Colors.white.withOpacity(.85))),
            ]),
          ),
        ),
      ),
    );
  }
}

class _PoolLandscape extends CustomPainter {
  const _PoolLandscape({required this.color});
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final rear = Path()..moveTo(0, size.height * .52)
      ..quadraticBezierTo(size.width * .2, size.height * .15,
        size.width * .42, size.height * .55)
      ..quadraticBezierTo(size.width * .65, size.height * .86,
        size.width, size.height * .29)
      ..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    canvas.drawPath(rear, Paint()..color = color.withOpacity(.15));
    final front = Path()..moveTo(0, size.height * .66)
      ..quadraticBezierTo(size.width * .3, size.height * .12,
        size.width * .56, size.height * .64)
      ..quadraticBezierTo(size.width * .78, size.height * .91,
        size.width, size.height * .42)
      ..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    canvas.drawPath(front, Paint()..color = color.withOpacity(.40));
    final highlight = Path()..moveTo(0, size.height * .84)
      ..quadraticBezierTo(size.width * .36, size.height * .32,
        size.width * .60, size.height * .86)
      ..quadraticBezierTo(size.width * .80, size.height * 1.04,
        size.width, size.height * .61);
    canvas.drawPath(highlight, Paint()..color = Colors.white.withOpacity(.72)
      ..strokeWidth = 2.3..style = PaintingStyle.stroke);
  }
  @override
  bool shouldRepaint(covariant _PoolLandscape oldDelegate) => oldDelegate.color != color;
}
