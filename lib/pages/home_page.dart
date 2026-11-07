import 'package:flutter/material.dart';

import '../core/dates.dart';
import '../core/pools.dart';
import '../core/theme.dart';
import '../state/app_scope.dart';
import '../widgets/app_frame.dart';
import 'daily_page.dart';
import 'entry_page.dart';
import 'generate_report_page.dart';
import 'query_page.dart';

/// Menú principal de CasetaPro. Mantiene la zona elegida en la primera pantalla.
class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.zone});

  final int zone;

  @override
  Widget build(BuildContext context) {
    final hoy = DateTime.now();
    final registrados = AppScope.of(context).forDay(zone, hoy).length;
    final total = Pools.forZone(zone).length;

    return AppFrame(
      title: 'CasetaPro',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        children: [
          // Cabecera sin camarón: más pequeña y sobria.
          Container(
            padding: const EdgeInsets.all(19),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF11385E),
                  Color(0xFF176F9A),
                  Color(0xFF15A8BA),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy.withOpacity(0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'CasetaPro',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.17),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        'ZONA $zone',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Control de Balanceado',
                  style: TextStyle(
                    color: Color(0xFFDBF5FA),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.white,
                        size: 19,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hoy · ${niceDate(hoy)}',
                              style: const TextStyle(
                                color: Color(0xFFE2F5FB),
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$registrados de $total piscinas registradas',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.trending_up_rounded,
                        color: Colors.white,
                        size: 21,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            '¿Qué deseas hacer?',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 12),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              mainAxisExtent: 124,
            ),
            children: [
              _MenuTile(
                title: 'Nuevo registro',
                subtitle: 'Registrar sacos',
                icon: Icons.add_circle_outline_rounded,
                accent: AppColors.sea,
                onTap: () => _open(context, EntryPage(zone: zone)),
              ),
              _MenuTile(
                title: 'Registros del día',
                subtitle: 'Revisar y editar',
                icon: Icons.fact_check_outlined,
                accent: AppColors.green,
                onTap: () => _open(context, DailyPage(zone: zone)),
              ),
              _MenuTile(
                title: 'Generar reporte',
                subtitle: 'Imagen o PDF',
                icon: Icons.bar_chart_rounded,
                accent: AppColors.orange,
                onTap: () => _open(context, GenerateReportPage(zone: zone)),
              ),
              _MenuTile(
                title: 'Consultas por fecha',
                subtitle: 'Ver historial',
                icon: Icons.calendar_month_rounded,
                accent: AppColors.violet,
                onTap: () => _open(context, QueryPage(zone: zone)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE0EAF2)),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withOpacity(0.045),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.11),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: accent, size: 20),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_outward_rounded, color: accent, size: 17),
                ],
              ),
              const Spacer(),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 13,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
