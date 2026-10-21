import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/tournament.dart';
import '../routes.dart';
import '../utils/format.dart';

/// One screen for new and edit. Answers with the saved Tournament via pop.
class FormScreen extends StatefulWidget {
  const FormScreen({super.key, required this.args});

  final FormArgs args;

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();

  bool get _isNew => widget.args.tournament == null;
  late final Tournament _initial = widget.args.tournament ?? Tournament.empty();

  // Controllers and focus nodes: fields of State, created once, disposed.
  late final _title = TextEditingController(text: _initial.title);
  late final _place = TextEditingController(text: _initial.place);
  late final _slots = TextEditingController(
    text: _isNew ? '' : '${_initial.slots}',
  );
  late final _description = TextEditingController(
    text: _initial.description ?? '',
  );
  late final _dateText = TextEditingController(
    text: _isNew ? '' : formatDay(_initial.startsAt),
  );
  late final _timeText = TextEditingController(
    text: _isNew
        ? ''
        : formatTime(_initial.startsAt.hour, _initial.startsAt.minute),
  );
  final _titleFocus = FocusNode();
  final _placeFocus = FocusNode();
  final _slotsFocus = FocusNode();
  final _descriptionFocus = FocusNode();

  late Category? _category = _isNew ? null : _initial.category;
  late bool _online = _initial.online;
  late DateTime? _date = _isNew ? null : DateUtils.dateOnly(_initial.startsAt);
  late TimeOfDay? _time = _isNew
      ? null
      : TimeOfDay.fromDateTime(_initial.startsAt);
  bool _saving = false;

  /// What the form looked like when it opened.
  late final String _opened;

  @override
  void initState() {
    super.initState();
    _opened = _snapshot();
  }

  @override
  void dispose() {
    for (final c in [
      _title,
      _place,
      _slots,
      _description,
      _dateText,
      _timeText,
    ]) {
      c.dispose();
    }
    for (final f in [
      _titleFocus,
      _placeFocus,
      _slotsFocus,
      _descriptionFocus,
    ]) {
      f.dispose();
    }
    super.dispose();
  }

  /// Every value as one string: different from [_opened] means dirty.
  String _snapshot() => [
    _title.text,
    _place.text,
    _slots.text,
    _description.text,
    _category?.name,
    _online,
    _dateText.text,
    _timeText.text,
  ].join('|');

  bool get _dirty => _snapshot() != _opened;

  // ---- validators: null = fine, a string = the message under the field ----

  String? _validateTitle(String? v) {
    final length = v?.trim().length ?? 0;
    if (length < 3) return 'At least 3 characters';
    if (length > 60) return 'At most 60 characters';
    return null;
  }

  String? _validatePlace(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) {
      return _online ? 'A link is required' : 'A venue is required';
    }
    if (_online && !value.contains('://')) return 'A link must contain ://';
    return null;
  }

  String? _validateSlots(String? v) {
    final n = int.tryParse(v?.trim() ?? '');
    if (n == null) return 'Enter a number';
    if (n < 1 || n > 500) return 'From 1 to 500';
    if (!_isNew && n < _initial.count) {
      return '${_initial.count} players already joined';
    }
    return null;
  }

  String? _validateDate(String? _) => _date == null ? 'Pick a date' : null;

  String? _validateTime(String? _) {
    final date = _date;
    final time = _time;
    if (time == null) return 'Pick a time';
    if (date == null) return null; // the date field says it
    final at = _combine(date, time);
    if (_isNew && !at.isAfter(DateTime.now())) return 'Must be in the future';
    return null;
  }

  DateTime _combine(DateTime d, TimeOfDay t) =>
      DateTime(d.year, d.month, d.day, t.hour, t.minute);

  // ---- pickers: Cancel returns null and keeps the old value ----

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _date = picked;
      _dateText.text = formatDay(picked);
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 19, minute: 0),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _time = picked;
      _timeText.text = formatTime(picked.hour, picked.minute);
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final date = _date;
    final time = _time;
    final category = _category;
    if (date == null || time == null || category == null) return;

    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 1)); // a fake save
    if (!mounted) return;

    final description = _description.text.trim();
    final result = _initial.copyWith(
      id: _isNew ? DateTime.now().microsecondsSinceEpoch.toString() : null,
      title: _title.text.trim(),
      category: category,
      startsAt: _combine(date, time),
      slots: int.parse(_slots.text.trim()), // validated above
      online: _online,
      place: _place.text.trim(),
      description: description.isEmpty ? null : description,
      clearDescription: description.isEmpty,
    );
    Navigator.of(context).pop(result);
  }

  Future<void> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (discard == true && mounted) Navigator.of(context).pop();
  }

  void _unfocus(PointerDownEvent _) => FocusScope.of(context).unfocus();

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_dirty,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) _confirmDiscard();
    },
    child: Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'New tournament' : 'Edit tournament'),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: () => setState(() {}), // re-check _dirty on every keystroke
        // The form scrolls, so the keyboard never pushes Save off-screen.
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              focusNode: _titleFocus,
              maxLength: 60,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.sentences,
              onTapOutside: _unfocus,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: _validateTitle,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Category>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Format',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final c in Category.values)
                  DropdownMenuItem(
                    value: c,
                    child: Row(
                      spacing: 8,
                      children: [Icon(c.icon), Text(c.label)],
                    ),
                  ),
              ],
              onChanged: (c) => setState(() => _category = c),
              validator: (c) => c == null ? 'Choose a format' : null,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Online'),
              subtitle: const Text('The place becomes a link'),
              value: _online,
              onChanged: (v) => setState(() => _online = v),
            ),
            TextFormField(
              controller: _place,
              focusNode: _placeFocus,
              textInputAction: TextInputAction.next,
              keyboardType: _online ? TextInputType.url : TextInputType.text,
              onTapOutside: _unfocus,
              decoration: InputDecoration(
                labelText: _online ? 'Discord / FACEIT link' : 'Venue',
                hintText: _online ? 'https://discord.gg/…' : 'KBTU, hall 254',
                border: const OutlineInputBorder(),
              ),
              validator: _validatePlace,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _slots,
              focusNode: _slotsFocus,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.number,
              onTapOutside: _unfocus,
              decoration: const InputDecoration(
                labelText: 'Slots',
                helperText: '1–500',
                border: OutlineInputBorder(),
              ),
              validator: _validateSlots,
            ),
            const SizedBox(height: 16),
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _dateText,
                    readOnly: true,
                    onTap: _pickDate,
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      suffixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateDate,
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: _timeText,
                    readOnly: true,
                    onTap: _pickTime,
                    decoration: const InputDecoration(
                      labelText: 'Time',
                      suffixIcon: Icon(Icons.schedule),
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _description,
              focusNode: _descriptionFocus,
              textInputAction: TextInputAction.done,
              maxLines: 3,
              onTapOutside: _unfocus,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              // null while saving: a double tap cannot save twice.
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    ),
  );
}
