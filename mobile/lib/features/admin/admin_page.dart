import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/services/api_client.dart';
import '../../core/theme/potatos_theme.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage>
    with SingleTickerProviderStateMixin {
  late final TabController controller;
  int categoriesReloadToken = 0;
  int calendarReloadToken = 0;
  int standingsReloadToken = 0;
  int currentTab = 0;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
    controller.addListener(handleTabChange);
  }

  void handleTabChange() {
    if (controller.indexIsChanging || controller.index == currentTab) return;
    setState(() {
      currentTab = controller.index;
      if (currentTab == 0) categoriesReloadToken++;
      if (currentTab == 1) calendarReloadToken++;
      if (currentTab == 2) standingsReloadToken++;
    });
  }

  @override
  void dispose() {
    controller.removeListener(handleTabChange);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrativo'),
        bottom: TabBar(
          controller: controller,
          tabs: const [
            Tab(icon: Icon(Icons.category_outlined), text: 'Categorias'),
            Tab(icon: Icon(Icons.event_note_outlined), text: 'Calendario'),
            Tab(icon: Icon(Icons.emoji_events_outlined), text: 'Classificacao'),
          ],
        ),
      ),
      body: TabBarView(
        controller: controller,
        children: [
          _CategoriesAdminTab(reloadToken: categoriesReloadToken),
          _CalendarAdminTab(reloadToken: calendarReloadToken),
          _StandingsAdminTab(reloadToken: standingsReloadToken),
        ],
      ),
    );
  }
}

class _CategoriesAdminTab extends StatefulWidget {
  const _CategoriesAdminTab({required this.reloadToken});

  final int reloadToken;

  @override
  State<_CategoriesAdminTab> createState() => _CategoriesAdminTabState();
}

class _CategoriesAdminTabState extends State<_CategoriesAdminTab> {
  final name = TextEditingController();
  final description = TextEditingController();
  List<dynamic> categories = [];
  Map<String, dynamic>? selected;
  bool active = true;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void didUpdateWidget(covariant _CategoriesAdminTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reloadToken != widget.reloadToken) load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    await _guard(context, () async {
      final result = await ApiScope.of(context).adminCategories();
      if (!mounted) return;
      setState(() {
        categories = result.data as List<dynamic>;
        loading = false;
      });
    }, successMessage: null);
    if (mounted && loading) setState(() => loading = false);
  }

  void edit(Map<String, dynamic> category) {
    setState(() {
      selected = category;
      name.text = category['name'] as String? ?? '';
      description.text = category['description'] as String? ?? '';
      active = category['active'] as bool? ?? true;
    });
  }

  void clear() {
    setState(() {
      selected = null;
      name.clear();
      description.clear();
      active = true;
    });
  }

  Future<void> save() async {
    await _guard(context, () async {
      final data = {
        'name': name.text.trim(),
        'description': description.text.trim(),
        'active': active
      };
      if (selected == null) {
        await ApiScope.of(context).createCategory(data);
      } else {
        await ApiScope.of(context).updateCategory(selected!['id'] as int, data);
      }
      clear();
      await load();
    });
  }

  Future<void> toggleActive(Map<String, dynamic> category, bool value) async {
    await _guard(context, () async {
      final data = {
        'name': category['name'],
        'description': category['description'] ?? '',
        'active': value,
      };
      await ApiScope.of(context).updateCategory(category['id'] as int, data);
      if (selected?['id'] == category['id']) {
        setState(() {
          selected = {...selected!, 'active': value};
          active = value;
        });
      }
      await load();
    }, successMessage: value ? 'Categoria ativada.' : 'Categoria desativada.');
  }

  @override
  Widget build(BuildContext context) {
    final activeCount =
        categories.where((item) => item['active'] as bool? ?? true).length;
    final inactiveCount = categories.length - activeCount;
    return _AdminList(
      title: 'Categorias',
      subtitle:
          '$activeCount ativas | $inactiveCount inativas. Categorias inativas somem do calendario e da classificacao.',
      form: Column(
        children: [
          TextField(
              controller: name,
              decoration:
                  const InputDecoration(labelText: 'Nome da categoria')),
          const SizedBox(height: 12),
          TextField(
              controller: description,
              decoration: const InputDecoration(labelText: 'Descricao')),
          const SizedBox(height: 10),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Ativa'),
            value: active,
            onChanged: (value) => setState(() => active = value),
          ),
          Row(
            children: [
              Expanded(
                  child: ElevatedButton(
                      onPressed: save,
                      child:
                          Text(selected == null ? 'Cadastrar' : 'Atualizar'))),
              if (selected != null) ...[
                const SizedBox(width: 10),
                IconButton(onPressed: clear, icon: const Icon(Icons.close)),
              ],
            ],
          ),
        ],
      ),
      children: [
        if (loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Center(child: CircularProgressIndicator()),
          ),
        for (final item in categories)
          _CategoryAdminRow(
            category: Map<String, dynamic>.from(item as Map),
            onTap: () => edit(Map<String, dynamic>.from(item)),
            onActiveChanged: (value) =>
                toggleActive(Map<String, dynamic>.from(item), value),
          ),
      ],
    );
  }
}

class _CalendarAdminTab extends StatefulWidget {
  const _CalendarAdminTab({required this.reloadToken});

  final int reloadToken;

  @override
  State<_CalendarAdminTab> createState() => _CalendarAdminTabState();
}

class _CalendarAdminTabState extends State<_CalendarAdminTab> {
  final title = TextEditingController();
  final track = TextEditingController();
  final round = TextEditingController();
  final startsAt = TextEditingController();
  final notes = TextEditingController();
  List<dynamic> categories = [];
  List<dynamic> events = [];
  int? categoryId;
  DateTime? selectedStartsAt;
  String status = 'SCHEDULED';
  Map<String, dynamic>? selected;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  @override
  void didUpdateWidget(covariant _CalendarAdminTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reloadToken != widget.reloadToken) reload();
  }

  Future<void> reload() async {
    if (mounted) ScaffoldMessenger.of(context).clearSnackBars();
    await loadCategories();
    await loadEvents();
  }

  Future<void> loadCategories() async {
    await _guard(context, () async {
      final result = await ApiScope.of(context).adminCategories();
      if (!mounted) return;
      setState(() => categories = result.data as List<dynamic>);
    }, successMessage: null);
  }

  Future<void> loadEvents() async {
    if (categoryId == null) return;
    final result = await ApiScope.of(context).calendar(categoryId!);
    setState(() => events = result.data as List<dynamic>);
  }

  void edit(Map<String, dynamic> event) {
    setState(() {
      selected = event;
      categoryId = event['categoryId'] as int?;
      title.text = event['title'] as String? ?? '';
      track.text = event['trackName'] as String? ?? '';
      round.text = '${event['roundNumber'] ?? ''}';
      selectedStartsAt = DateTime.tryParse(event['startsAt'] as String? ?? '');
      startsAt.text = _formatDateTime(selectedStartsAt);
      status = event['status'] as String? ?? 'SCHEDULED';
      notes.text = event['notes'] as String? ?? '';
    });
  }

  void clear() {
    setState(() {
      selected = null;
      title.clear();
      track.clear();
      round.clear();
      startsAt.clear();
      selectedStartsAt = null;
      notes.clear();
      status = 'SCHEDULED';
    });
  }

  Future<void> pickStartsAt() async {
    final now = DateTime.now();
    final initial = selectedStartsAt ?? now;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (time == null) return;

    final value =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      selectedStartsAt = value;
      startsAt.text = _formatDateTime(value);
    });
  }

  Future<void> save() async {
    if (categoryId == null) {
      _toast(context, 'Selecione uma categoria.');
      return;
    }
    if (title.text.trim().isEmpty ||
        track.text.trim().isEmpty ||
        round.text.trim().isEmpty) {
      _toast(context, 'Preencha etapa, pista e rodada.');
      return;
    }
    if (selectedStartsAt == null) {
      _toast(context, 'Selecione data e hora da etapa.');
      return;
    }
    final roundNumber = int.tryParse(round.text.trim());
    if (roundNumber == null) {
      _toast(context, 'Rodada deve ser um numero.');
      return;
    }
    final selectedId = selected == null ? null : selected!['id'] as int?;
    final hasDuplicateRound = events.any((event) {
      final eventId = event['id'] as int?;
      final eventRound = event['roundNumber'] as int?;
      return eventId != selectedId && eventRound == roundNumber;
    });
    if (hasDuplicateRound) {
      _toast(context, 'Ja existe uma etapa com esta rodada na categoria.');
      return;
    }
    await _guard(context, () async {
      final data = {
        'categoryId': categoryId,
        'title': title.text.trim(),
        'trackName': track.text.trim(),
        'roundNumber': roundNumber,
        'startsAt': selectedStartsAt!.toIso8601String(),
        'status': status,
        'notes': notes.text.trim(),
      };
      if (selected == null) {
        await ApiScope.of(context).createCalendarEvent(data);
      } else {
        await ApiScope.of(context)
            .updateCalendarEvent(selected!['id'] as int, data);
      }
      clear();
      await loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _AdminList(
      title: 'Calendario',
      subtitle: 'Cadastre etapas, pistas, horarios e status da corrida.',
      form: Column(
        children: [
          _CategoryDropdown(
            categories: categories,
            value: categoryId,
            onRefresh: loadCategories,
            onChanged: (value) async {
              setState(() => categoryId = value);
              await loadEvents();
            },
          ),
          const SizedBox(height: 12),
          TextField(
              controller: title,
              decoration: const InputDecoration(labelText: 'Titulo da etapa')),
          const SizedBox(height: 12),
          TextField(
              controller: track,
              decoration: const InputDecoration(labelText: 'Pista')),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: TextField(
                      controller: round,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Rodada'))),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: startsAt,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Data e hora',
                    suffixIcon: Icon(Icons.calendar_month_outlined),
                  ),
                  onTap: pickStartsAt,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            key: ValueKey(status),
            initialValue: status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: const [
              DropdownMenuItem(value: 'SCHEDULED', child: Text('Agendada')),
              DropdownMenuItem(value: 'FINISHED', child: Text('Finalizada')),
              DropdownMenuItem(value: 'CANCELED', child: Text('Cancelada')),
            ],
            onChanged: (value) => setState(() => status = value ?? 'SCHEDULED'),
          ),
          const SizedBox(height: 12),
          TextField(
              controller: notes,
              decoration: const InputDecoration(labelText: 'Observacoes')),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                  child: ElevatedButton(
                      onPressed: save,
                      child: Text(selected == null
                          ? 'Cadastrar etapa'
                          : 'Atualizar etapa'))),
              if (selected != null) ...[
                const SizedBox(width: 10),
                IconButton(onPressed: clear, icon: const Icon(Icons.close)),
              ],
            ],
          ),
        ],
      ),
      children: [
        for (final item in events)
          _AdminRow(
            title: item['title'] as String,
            subtitle: '${item['trackName']} | ${item['startsAt']}',
            badge: item['status'] as String? ?? '',
            onTap: () => edit(Map<String, dynamic>.from(item as Map)),
          ),
      ],
    );
  }
}

class _StandingsAdminTab extends StatefulWidget {
  const _StandingsAdminTab({required this.reloadToken});

  final int reloadToken;

  @override
  State<_StandingsAdminTab> createState() => _StandingsAdminTabState();
}

class _StandingsAdminTabState extends State<_StandingsAdminTab> {
  final position = TextEditingController();
  final points = TextEditingController();
  final wins = TextEditingController(text: '0');
  final poles = TextEditingController(text: '0');
  final fastestLaps = TextEditingController(text: '0');
  final races = TextEditingController(text: '0');
  List<dynamic> categories = [];
  List<dynamic> pilots = [];
  List<dynamic> rows = [];
  int? categoryId;
  int? userId;
  Map<String, dynamic>? selected;

  @override
  void initState() {
    super.initState();
    loadBase();
  }

  @override
  void didUpdateWidget(covariant _StandingsAdminTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reloadToken != widget.reloadToken) reload();
  }

  Future<void> reload() async {
    if (mounted) ScaffoldMessenger.of(context).clearSnackBars();
    await loadBase();
    await loadRows();
  }

  Future<void> loadBase() async {
    await _guard(context, () async {
      final api = ApiScope.of(context);
      final results = await Future.wait([api.adminCategories(), api.pilots()]);
      if (!mounted) return;
      setState(() {
        categories = results[0].data as List<dynamic>;
        pilots = results[1].data as List<dynamic>;
      });
    }, successMessage: null);
  }

  Future<void> loadRows() async {
    if (categoryId == null) return;
    final result = await ApiScope.of(context).standings(categoryId!);
    setState(() => rows = result.data as List<dynamic>);
  }

  void edit(Map<String, dynamic> row) {
    setState(() {
      selected = row;
      categoryId = row['categoryId'] as int?;
      userId = row['userId'] as int?;
      position.text = '${row['position'] ?? ''}';
      points.text = '${row['points'] ?? ''}';
      wins.text = '${row['wins'] ?? 0}';
      poles.text = '${row['poles'] ?? 0}';
      fastestLaps.text = '${row['fastestLaps'] ?? 0}';
      races.text = '${row['races'] ?? 0}';
    });
  }

  void clear() {
    setState(() {
      selected = null;
      userId = null;
      position.clear();
      points.clear();
      wins.text = '0';
      poles.text = '0';
      fastestLaps.text = '0';
      races.text = '0';
    });
  }

  Future<void> save() async {
    if (categoryId == null || userId == null) {
      _toast(context, 'Selecione categoria e piloto.');
      return;
    }
    await _guard(context, () async {
      Map<String, dynamic>? existing;
      for (final row in rows) {
        if (row['userId'] == userId) {
          existing = Map<String, dynamic>.from(row as Map);
          break;
        }
      }
      final data = {
        'categoryId': categoryId,
        'userId': userId,
        'position': int.parse(position.text.trim()),
        'points': int.parse(points.text.trim()),
        'wins': int.parse(wins.text.trim()),
        'poles': int.parse(poles.text.trim()),
        'fastestLaps': int.parse(fastestLaps.text.trim()),
        'races': int.parse(races.text.trim()),
      };
      final selectedId = selected == null ? null : selected!['id'] as int;
      final existingId = existing == null ? null : existing['id'] as int;
      final idToUpdate = selectedId ?? existingId;
      if (idToUpdate == null) {
        await ApiScope.of(context).createStanding(data);
      } else {
        await ApiScope.of(context).updateStanding(idToUpdate, data);
      }
      clear();
      await loadRows();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _AdminList(
      title: 'Classificacao',
      subtitle: 'Atualize pontos, posicao e estatisticas dos pilotos.',
      form: Column(
        children: [
          _CategoryDropdown(
            categories: categories,
            value: categoryId,
            onRefresh: loadBase,
            onChanged: (value) async {
              setState(() => categoryId = value);
              await loadRows();
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            key: ValueKey(userId),
            initialValue: userId,
            decoration: const InputDecoration(labelText: 'Piloto'),
            items: [
              for (final pilot in pilots)
                DropdownMenuItem(
                    value: pilot['id'] as int,
                    child: Text(pilot['name'] as String)),
            ],
            onChanged: (value) => setState(() => userId = value),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: TextField(
                      controller: position,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Posicao'))),
              const SizedBox(width: 10),
              Expanded(
                  child: TextField(
                      controller: points,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Pontos'))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: TextField(
                      controller: wins,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Vitorias'))),
              const SizedBox(width: 10),
              Expanded(
                  child: TextField(
                      controller: poles,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Poles'))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: TextField(
                      controller: fastestLaps,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Voltas rapidas'))),
              const SizedBox(width: 10),
              Expanded(
                  child: TextField(
                      controller: races,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Corridas'))),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                  child: ElevatedButton(
                      onPressed: save,
                      child: Text(selected == null
                          ? 'Salvar piloto'
                          : 'Atualizar piloto'))),
              if (selected != null) ...[
                const SizedBox(width: 10),
                IconButton(onPressed: clear, icon: const Icon(Icons.close)),
              ],
            ],
          ),
        ],
      ),
      children: [
        for (final row in rows)
          _AdminRow(
            title: 'Pos. ${row['position']} - ${row['user']['name']}',
            subtitle:
                '${row['points']} pts | V ${row['wins']} | P ${row['poles']} | VR ${row['fastestLaps']}',
            badge: '${row['races']} corridas',
            onTap: () => edit(Map<String, dynamic>.from(row as Map)),
          ),
      ],
    );
  }
}

class _AdminList extends StatelessWidget {
  const _AdminList(
      {required this.title,
      required this.subtitle,
      required this.form,
      required this.children});

  final String title;
  final String subtitle;
  final Widget form;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(subtitle, style: const TextStyle(color: PotatosColors.smoke)),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: form,
          ),
        ),
        const SizedBox(height: 12),
        if (children.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Text('Nenhum registro encontrado.',
                style: TextStyle(color: PotatosColors.smoke)),
          )
        else
          ...children,
      ],
    );
  }
}

class _AdminRow extends StatelessWidget {
  const _AdminRow(
      {required this.title,
      required this.subtitle,
      required this.badge,
      required this.onTap});

  final String title;
  final String subtitle;
  final String badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(subtitle),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(badge,
                style: const TextStyle(
                    color: PotatosColors.racingOrange,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            const Icon(Icons.edit_outlined, size: 18),
          ],
        ),
      ),
    );
  }
}

class _CategoryAdminRow extends StatelessWidget {
  const _CategoryAdminRow({
    required this.category,
    required this.onTap,
    required this.onActiveChanged,
  });

  final Map<String, dynamic> category;
  final VoidCallback onTap;
  final ValueChanged<bool> onActiveChanged;

  @override
  Widget build(BuildContext context) {
    final isActive = category['active'] as bool? ?? true;
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(
          category['name'] as String,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(category['description'] as String? ?? 'Sem descricao'),
        trailing: SizedBox(
          width: 118,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                isActive ? 'ATIVA' : 'INATIVA',
                style: TextStyle(
                  color: isActive
                      ? PotatosColors.racingOrange
                      : PotatosColors.smoke,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
              Switch(
                value: isActive,
                onChanged: onActiveChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown({
    required this.categories,
    required this.value,
    required this.onChanged,
    required this.onRefresh,
  });

  final List<dynamic> categories;
  final int? value;
  final ValueChanged<int?> onChanged;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      key: ValueKey(value),
      initialValue: value,
      decoration: InputDecoration(
        labelText: 'Categoria',
        helperText: categories.isEmpty
            ? 'Nenhuma categoria carregada'
            : '${categories.length} categorias carregadas',
        suffixIcon: IconButton(
          tooltip: 'Atualizar categorias',
          icon: const Icon(Icons.refresh),
          onPressed: onRefresh,
        ),
      ),
      items: [
        for (final category in categories)
          DropdownMenuItem(
              value: category['id'] as int,
              child: Text(category['name'] as String)),
      ],
      onTap: onRefresh,
      onChanged: onChanged,
    );
  }
}

Future<void> _guard(BuildContext context, Future<void> Function() action,
    {String? successMessage = 'Registro salvo.'}) async {
  try {
    await action();
    if (context.mounted && successMessage != null) {
      _toast(context, successMessage);
    }
  } catch (error) {
    if (!context.mounted) return;
    var message = 'Nao foi possivel salvar.';
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        message = data['message'].toString();
      }
    }
    _toast(context, message);
  }
}

void _toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

String _formatDateTime(DateTime? value) {
  if (value == null) return '';
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final year = value.year.toString();
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$day/$month/$year $hour:$minute';
}
