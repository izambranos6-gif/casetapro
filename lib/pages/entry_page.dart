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
  final _observation = TextEditingController();

  static const _reasons = [
    'Error en el reporte de bodega',
    'Sacos pendientes de entrega',
    'Corrección de inventario',
    'Diferencia en conteo físico',
    'Otro',
  ];

  String? _reason;
  late DateTime _date;
  late String _pool;
  bool _saving = false;

  int? _parse(TextEditingController controller) =>
      int.tryParse(controller.text.trim());

  int? get _calculated {
    final previous = _parse(_previous);
    final requested = _parse(_requested);
    final supplied = _parse(_supplied);
    if (previous == null || requested == null || supplied == null) return null;
    return FeedRecord.suggestedCaseta(previous, requested, supplied);
  }

  int? get _difference {
    final actual = _parse(_caseta);
    final calculated = _calculated;
    if (actual == null || calculated == null) return null;
    return actual - calculated;
  }

  @override
  void initState() {
    super.initState();
    _date = widget.initialRecord?.date ?? DateTime.now();
    _pool = widget.initialRecord?.pool ??
        widget.initialPool ?? Pools.forZone(widget.zone).first;
    for (final controller in [_previous, _requested, _supplied, _caseta]) {
      controller.addListener(_onAmountsChanged);
    }
    if (widget.initialRecord != null) _fill(widget.initialRecord!);
  }

  void _onAmountsChanged() {
    if (mounted) setState(() {});
  }

  void _fill(FeedRecord record) {
    _previous.text = '${record.previous}';
    _requested.text = '${record.requested}';
    _supplied.text = '${record.supplied}';
    _caseta.text = '${record.caseta}';
    _observation.text = record.observation;
    _reason = record.differenceReason.isEmpty ? null : record.differenceReason;
    if (_reason != null && !_reasons.contains(_reason)) {
      _reason = 'Otro';
    }
  }

  void _clearAmounts() {
    _previous.clear();
    _requested.clear();
    _supplied.clear();
    _caseta.clear();
    _observation.clear();
    setState(() => _reason = null);
  }

  void _loadIfExisting() {
    final existing = AppScope.of(context).find(widget.zone, _date, _pool);
    if (existing == null) {
      _clearAmounts();
    } else {
      _fill(existing);
      showAppMessage(context,
          'Esta piscina ya tiene registro en esa fecha. Puedes editarlo.');
    }
  }

  @override
  void dispose() {
    _previous.dispose();
    _requested.dispose();
    _supplied.dispose();
    _caseta.dispose();
    _observation.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    final difference = _difference;
    if (difference == null) return;
    if (difference != 0 && (_reason == null || _reason!.trim().isEmpty)) {
      showAppMessage(context, 'Selecciona el motivo de la diferencia.');
      return;
    }
    if (difference != 0 && _reason == 'Otro' &&
        _observation.text.trim().isEmpty) {
      showAppMessage(context, 'Describe la diferencia en Observación.');
      return;
    }

    final controller = AppScope.of(context);
    final existing = controller.find(widget.zone, _date, _pool);
    if (existing != null) {
      final shouldUpdate = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Actualizar registro'),
          content: Text('La piscina $_pool ya tiene datos el ${niceDate(_date)}. '
              '¿Deseas reemplazarlos?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Actualizar'),
            ),
          ],
        ),
      );
      if (shouldUpdate != true || !mounted) return;
    }

    final record = FeedRecord(
      zone: widget.zone,
      pool: _pool,
      date: _date,
      previous: int.parse(_previous.text),
      requested: int.parse(_requested.text),
      supplied: int.parse(_supplied.text),
      caseta: int.parse(_caseta.text),
      differenceReason: difference == 0 ? '' : _reason!,
      observation: _observation.text.trim(),
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
      final pending = Pools.forZone(widget.zone)
          .where((pool) => controller.find(widget.zone, _date, pool) == null)
          .toList();
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
    final calculated = _calculated;
    final difference = _difference;
    return AppFrame(
      title: editing ? 'Editar Registro' : 'Nuevo Registro',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 100),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeading(
                label: 'Datos del registro',
                icon: Icons.edit_note_rounded,
              ),
              const SizedBox(height: 13),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Fecha del registro', style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    )),
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
                        color: AppColors.ink,
                        fontWeight: FontWeight.w800,
                      )),
                    ),
                    const SizedBox(height: 18),
                    const Text('Piscina', style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    )),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _pool,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.waves_rounded,
                            color: AppColors.sea),
                      ),
                      items: Pools.forZone(widget.zone).map((pool) =>
                        DropdownMenuItem(
                          value: pool,
                          child: Text(pool, style: const TextStyle(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w800,
                          )),
                        ),
                      ).toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _pool = value);
                        _loadIfExisting();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 19),
              const SectionHeading(
                label: 'Movimiento de sacos',
                icon: Icons.inventory_2_outlined,
                color: AppColors.green,
              ),
              const SizedBox(height: 13),
              SectionCard(
                child: Column(
                  children: [
                    _quantityField('Sacos del día anterior',
                      Icons.history_rounded, AppColors.sea, _previous),
                    const Divider(height: 21),
                    _quantityField('Sacos pedidos a bodega',
                      Icons.shopping_cart_outlined, AppColors.orange, _requested),
                    const Divider(height: 21),
                    _quantityField('Sacos abastecidos',
                      Icons.check_circle_outline_rounded,
                      AppColors.green, _supplied),
                    const Divider(height: 21),
                    _quantityField('Sacos caseta (real)',
                      Icons.home_work_outlined, AppColors.violet, _caseta),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _calculationPanel(calculated, difference),
              const SizedBox(height: 14),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (difference != null && difference != 0) ...[
                      const Text('Motivo de la diferencia *',
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _reason,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.report_problem_outlined,
                            color: AppColors.orange),
                          hintText: 'Seleccionar motivo',
                        ),
                        items: _reasons.map((reason) => DropdownMenuItem(
                          value: reason,
                          child: Text(reason, overflow: TextOverflow.ellipsis),
                        )).toList(),
                        onChanged: (value) => setState(() => _reason = value),
                        validator: (value) => difference != 0 &&
                          (value == null || value.isEmpty)
                            ? 'Selecciona un motivo' : null,
                      ),
                      const SizedBox(height: 16),
                    ],
                    const Text('Observación (opcional)', style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    )),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _observation,
                      maxLines: 3,
                      maxLength: 250,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.notes_rounded,
                          color: AppColors.sea),
                        hintText: 'Escribe un detalle si es necesario...',
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 21),
              Row(children: [
                Expanded(child: OutlinedButton.icon(
                  onPressed: _saving ? null : _clearAmounts,
                  icon: const Icon(Icons.backspace_outlined, size: 19),
                  label: const Text('Limpiar'),
                )),
                const SizedBox(width: 12),
                Expanded(child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                    ? const SizedBox(width: 17, height: 17,
                        child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_outlined, size: 20),
                  label: Text(_saving ? 'Guardando...' : 'Guardar'),
                )),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _calculationPanel(int? calculated, int? difference) {
    final hasDifference = difference != null && difference != 0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: hasDifference
            ? const Color(0xFFFFF6E8) : const Color(0xFFEAF6FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: hasDifference
            ? const Color(0xFFF7D6A2) : const Color(0xFFD5E9F2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Icon(hasDifference ? Icons.warning_amber_rounded
                : Icons.calculate_outlined,
                color: hasDifference ? AppColors.orange : AppColors.sea),
            const SizedBox(width: 8),
            const Expanded(child: Text('Control de inventario',
              style: TextStyle(color: AppColors.ink,
                fontWeight: FontWeight.w800))),
          ]),
          const SizedBox(height: 9),
          Text('Sacos en caseta: ${calculated ?? '—'}',
            style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 7),
          Text(difference == null ? 'Ingresa los cuatro valores para comparar.'
              : difference == 0 ? 'Sin diferencias. El conteo coincide.'
              : 'Diferencia: ${difference > 0 ? '+' : ''}$difference sacos',
            style: TextStyle(
              color: hasDifference ? const Color(0xFF9C5700) : AppColors.muted,
              fontWeight: hasDifference ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
          if (hasDifference) ...[
            const SizedBox(height: 7),
            const Text('Verifica los datos y selecciona un motivo para guardar '
                'el valor real reportado.',
              style: TextStyle(color: AppColors.muted, fontSize: 12)),
          ],
        ],
      ),
    );
  }

  Widget _quantityField(String label, IconData icon, Color accent,
      TextEditingController controller) => Row(children: [
    Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: accent.withOpacity(.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: accent, size: 21),
    ),
    const SizedBox(width: 10),
    Expanded(child: Text(label, style: const TextStyle(
      color: AppColors.ink, fontSize: 12,
      fontWeight: FontWeight.w700,
    ))),
    const SizedBox(width: 8),
    SizedBox(width: 93, child: TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(color: AppColors.ink,
        fontWeight: FontWeight.w900, fontSize: 16),
      decoration: const InputDecoration(
        isDense: true,
        hintText: '0',
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 13),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Requerido';
        if (int.tryParse(value) == null) return 'Inválido';
        return null;
      },
    )),
  ]);
}
