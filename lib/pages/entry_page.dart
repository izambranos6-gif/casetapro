import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/dates.dart';
import '../core/pools.dart';
import '../core/theme.dart';
import '../models/feed_record.dart';
import '../state/app_scope.dart';
import '../widgets/app_frame.dart';

class EntryPage extends StatefulWidget {
  const EntryPage({super.key, required this.zone, this.initialRecord, this.initialPool});
  final int zone;
  final FeedRecord? initialRecord;
  final String? initialPool;
  @override
  State<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  final _formKey = GlobalKey<FormState>();
  final _previous = TextEditingController();
  final _requested = TextEditingController();
  final _supplied = TextEditingController();
  final _caseta = TextEditingController();
  late DateTime _date;
  late String _pool;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _date = widget.initialRecord?.date ?? DateTime.now();
    _pool = widget.initialRecord?.pool ?? widget.initialPool ?? Pools.forZone(widget.zone).first;
    if (widget.initialRecord != null) {
      _fill(widget.initialRecord!);
    }
  }

  void _fill(FeedRecord record) {
    _previous.text = '${record.previous}';
    _requested.text = '${record.requested}';
    _supplied.text = '${record.supplied}';
    _caseta.text = '${record.caseta}';
  }

  void _clearAmounts() {
    _previous.clear();
    _requested.clear();
    _supplied.clear();
    _caseta.clear();
  }

  void _loadIfExisting() {
    final existing = AppScope.of(context).find(widget.zone, _date, _pool);
    if (existing == null) {
      _clearAmounts();
    } else {
      _fill(existing);
      showAppMessage(context, 'Esta piscina ya tiene registro en esa fecha. Puedes editarlo.');
    }
  }

  @override
  void dispose() {
    _previous.dispose();
    _requested.dispose();
    _supplied.dispose();
    _caseta.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    final controller = AppScope.of(context);
    final existing = controller.find(widget.zone, _date, _pool);
    if (existing != null) {
      final shouldUpdate = await showDialog<bool>(context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Actualizar registro'),
          content: Text('La piscina $_pool ya tiene datos el ${niceDate(_date)}. '
            '¿Deseas reemplazarlos?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Actualizar')),
          ],
        ));
      if (shouldUpdate != true || !mounted) return;
    }

    final record = FeedRecord(
      zone: widget.zone, pool: _pool, date: _date,
      previous: int.parse(_previous.text),
      requested: int.parse(_requested.text),
      supplied: int.parse(_supplied.text),
      caseta: int.parse(_caseta.text),
    );
    setState(() => _saving = true);
    try {
      await controller.upsert(record);
      if (!mounted) return;
      showAppMessage(context, 'Registro guardado correctamente: $_pool.');
      if (widget.initialRecord != null) {
        Navigator.pop(context);
        return;
      }
      final pending = Pools.forZone(widget.zone).where(
        (p) => controller.find(widget.zone, _date, p) == null,
      ).toList();
      setState(() {
        if (pending.isNotEmpty) _pool = pending.first;
        _clearAmounts();
      });
    } catch (e) {
      if (mounted) showAppMessage(context, 'No fue posible guardar: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.initialRecord != null;
    return AppFrame(
      title: editing ? 'Editar Registro' : 'Nuevo Registro',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 100),
        child: Form(key: _formKey, child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeading(label: 'Datos del registro',
              icon: Icons.edit_note_rounded),
            const SizedBox(height: 13),
            SectionCard(child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Fecha del registro', style: TextStyle(
                  color: AppColors.ink, fontSize: 13,
                  fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    final date = await selectRecordDate(context, _date);
                    if (date != null) {
                      setState(() => _date = date);
                      if (mounted) _loadIfExisting();
                    }
                  },
                  icon: const Icon(Icons.calendar_month_rounded,
                    color: AppColors.sea),
                  label: Text(niceDate(_date), style: const TextStyle(
                    color: AppColors.ink, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: 17),
                ZoneBanner(zone: widget.zone),
                const SizedBox(height: 18),
                const Text('Piscina', style: TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 13)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _pool,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.waves_rounded, color: AppColors.sea)),
                  items: Pools.forZone(widget.zone).map((pool) =>
                    DropdownMenuItem(value: pool,
                      child: Text(pool, style: const TextStyle(
                        color: AppColors.ink, fontWeight: FontWeight.w800))))
                    .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _pool = value);
                    _loadIfExisting();
                  },
                ),
              ],
            )),
            const SizedBox(height: 19),
            const SectionHeading(label: 'Movimiento de sacos',
              icon: Icons.inventory_2_outlined, color: AppColors.green),
            const SizedBox(height: 13),
            SectionCard(child: Column(children: [
              _quantityField('Sacos del día anterior',
                Icons.history_rounded, AppColors.sea, _previous),
              const Divider(height: 21),
              _quantityField('Sacos pedidos a bodega',
                Icons.shopping_cart_outlined, AppColors.orange, _requested),
              const Divider(height: 21),
              _quantityField('Sacos abastecidos',
                Icons.check_circle_outline_rounded, AppColors.green, _supplied),
              const Divider(height: 21),
              _quantityField('Sacos caseta',
                Icons.home_work_outlined, AppColors.violet, _caseta),
            ])),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF6FB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFD5E9F2))),
              child: const Row(children: [
                Icon(Icons.info_outline, color: AppColors.sea, size: 19),
                SizedBox(width: 9),
                Expanded(child: Text('Ingresa los cuatro valores tal como '
                  'fueron reportados. No se modifican automáticamente.',
                  style: TextStyle(color: AppColors.muted, fontSize: 11.5))),
              ]),
            ),
            const SizedBox(height: 21),
            Row(children: [
              Expanded(child: OutlinedButton.icon(
                onPressed: _saving ? null : _clearAmounts,
                icon: const Icon(Icons.backspace_outlined, size: 19),
                label: const Text('Limpiar'))),
              const SizedBox(width: 12),
              Expanded(child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                  ? const SizedBox(width: 17, height: 17,
                      child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save_outlined, size: 20),
                label: Text(_saving ? 'Guardando...' : 'Guardar'))),
            ]),
          ],
        )),
      ),
    );
  }

  Widget _quantityField(String label, IconData icon, Color accent,
      TextEditingController controller) => Row(children: [
    Container(width: 38, height: 38,
      decoration: BoxDecoration(color: accent.withOpacity(.10),
        borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: accent, size: 21)),
    const SizedBox(width: 10),
    Expanded(child: Text(label, style: const TextStyle(
      color: AppColors.ink, fontSize: 12,
      fontWeight: FontWeight.w700))),
    const SizedBox(width: 8),
    SizedBox(width: 93, child: TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(color: AppColors.ink,
        fontWeight: FontWeight.w900, fontSize: 16),
      decoration: const InputDecoration(isDense: true,
        hintText: '0',
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 13)),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Requerido';
        if (int.tryParse(value) == null) return 'Inválido';
        return null;
      },
    )),
  ]);
}
