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
  int notificationsReloadToken = 0;
  int currentTab = 0;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 4, vsync: this);
    controller.addListener(handleTabChange);
  }

  void handleTabChange() {
    if (controller.indexIsChanging || controller.index == currentTab) return;
    setState(() {
      currentTab = controller.index;
      if (currentTab == 0) categoriesReloadToken++;
      if (currentTab == 1) calendarReloadToken++;
      if (currentTab == 2) standingsReloadToken++;
      if (currentTab == 3) notificationsReloadToken++;
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
            Tab(
                icon: Icon(Icons.notifications_active_outlined),
                text: 'Notificacoes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: controller,
        children: [
          _CategoriesAdminTab(reloadToken: categoriesReloadToken),
          _CalendarAdminTab(reloadToken: calendarReloadToken),
          _StandingsAdminTab(reloadToken: standingsReloadToken),
          _NotificationsAdminTab(reloadToken: notificationsReloadToken),
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
  String? loadError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) load();
    });
  }

  @override
  void didUpdateWidget(covariant _CategoriesAdminTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reloadToken != widget.reloadToken) load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      loadError = null;
    });
    try {
      final result = await ApiScope.of(context).adminCategories();
      if (!mounted) return;
      setState(() {
        categories = result.data as List<dynamic>;
        loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        loading = false;
        loadError =
            _errorMessage(error, 'Nao foi possivel carregar categorias.');
      });
    }
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
        if (loadError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _AdminInlineError(message: loadError!, onRetry: load),
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
  List<dynamic> categories = [];
  List<dynamic> pilots = [];
  List<dynamic> rows = [];
  List<_StandingDraft> drafts = [];
  int? categoryId;
  bool loadingBase = false;
  bool loadingRows = false;
  bool savingRows = false;
  String? loadError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) loadBase();
    });
  }

  @override
  void dispose() {
    clearDrafts();
    super.dispose();
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
    setState(() {
      loadingBase = true;
      loadError = null;
    });
    try {
      final api = ApiScope.of(context);
      final results = await Future.wait([api.adminCategories(), api.pilots()]);
      if (!mounted) return;
      setState(() {
        categories = results[0].data as List<dynamic>;
        pilots = results[1].data as List<dynamic>;
        loadingBase = false;
      });
      buildDrafts();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        loadingBase = false;
        loadError = _errorMessage(
            error, 'Nao foi possivel carregar categorias e pilotos.');
      });
    }
  }

  Future<void> loadRows() async {
    if (categoryId == null) {
      setState(() {
        rows = [];
        clearDrafts();
        drafts = [];
      });
      return;
    }
    setState(() {
      loadingRows = true;
      loadError = null;
    });
    try {
      final result = await ApiScope.of(context).standings(categoryId!);
      if (!mounted) return;
      setState(() {
        rows = result.data as List<dynamic>;
        loadingRows = false;
      });
      buildDrafts();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        loadingRows = false;
        loadError =
            _errorMessage(error, 'Nao foi possivel carregar classificacao.');
      });
    }
  }

  Future<void> save() async {
    if (categoryId == null) {
      _toast(context, 'Selecione uma categoria.');
      return;
    }
    if (drafts.isEmpty) {
      _toast(context, 'Nenhum piloto encontrado.');
      return;
    }
    final payloads = <_StandingPayload>[];
    for (final draft in drafts) {
      final payload = draft.toPayload(categoryId!);
      if (payload == null) {
        _toast(context, 'Revise os campos numericos de ${draft.pilotName}.');
        return;
      }
      payloads.add(payload);
    }
    setState(() => savingRows = true);
    await _guard(context, () async {
      final api = ApiScope.of(context);
      for (final payload in payloads) {
        if (payload.standingId == null) {
          await api.createStanding(payload.data);
        } else {
          await api.updateStanding(payload.standingId!, payload.data);
        }
      }
      await loadRows();
    }, successMessage: 'Classificacao atualizada.');
    if (mounted) setState(() => savingRows = false);
  }

  void clearDrafts() {
    for (final draft in drafts) {
      draft.dispose();
    }
  }

  void buildDrafts() {
    clearDrafts();
    final existingByUserId = <int, Map<String, dynamic>>{};
    for (final row in rows) {
      existingByUserId[row['userId'] as int] = Map<String, dynamic>.from(row);
    }
    final nextDrafts = <_StandingDraft>[];
    for (var index = 0; index < pilots.length; index++) {
      final pilot = Map<String, dynamic>.from(pilots[index] as Map);
      final row = existingByUserId[pilot['id'] as int];
      nextDrafts.add(_StandingDraft(
        standingId: row?['id'] as int?,
        userId: pilot['id'] as int,
        pilotName: pilot['name'] as String,
        position: row?['position'] as int? ?? index + 1,
        points: row?['points'] as int? ?? 0,
        wins: row?['wins'] as int? ?? 0,
        poles: row?['poles'] as int? ?? 0,
        fastestLaps: row?['fastestLaps'] as int? ?? 0,
        races: row?['races'] as int? ?? 0,
      ));
    }
    if (!mounted) {
      for (final draft in nextDrafts) {
        draft.dispose();
      }
      return;
    }
    setState(() => drafts = nextDrafts);
  }

  @override
  Widget build(BuildContext context) {
    return _AdminList(
      title: 'Classificacao',
      subtitle:
          'Selecione a categoria e atualize todos os pilotos em uma unica tabela.',
      form: Column(
        children: [
          _CategoryDropdown(
            categories: categories,
            value: categoryId,
            onRefresh: loadBase,
            onChanged: (value) async {
              setState(() {
                categoryId = value;
                rows = [];
                clearDrafts();
                drafts = [];
              });
              await loadRows();
            },
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: categoryId == null || savingRows || drafts.isEmpty
                  ? null
                  : save,
              icon: savingRows
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(
                  savingRows ? 'Salvando...' : 'Salvar classificacao completa'),
            ),
          ),
        ],
      ),
      children: [
        if (loadingBase || loadingRows)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (loadError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _AdminInlineError(message: loadError!, onRetry: reload),
          ),
        if (categoryId == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Text('Selecione uma categoria para editar a classificacao.',
                style: TextStyle(color: PotatosColors.smoke)),
          )
        else if (!loadingRows && drafts.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Text('Nenhum piloto encontrado.',
                style: TextStyle(color: PotatosColors.smoke)),
          )
        else if (drafts.isNotEmpty)
          _StandingsGrid(drafts: drafts),
      ],
    );
  }
}

class _StandingDraft {
  _StandingDraft({
    required this.standingId,
    required this.userId,
    required this.pilotName,
    required int position,
    required int points,
    required int wins,
    required int poles,
    required int fastestLaps,
    required int races,
  })  : position = TextEditingController(text: '$position'),
        points = TextEditingController(text: '$points'),
        wins = TextEditingController(text: '$wins'),
        poles = TextEditingController(text: '$poles'),
        fastestLaps = TextEditingController(text: '$fastestLaps'),
        races = TextEditingController(text: '$races');

  final int? standingId;
  final int userId;
  final String pilotName;
  final TextEditingController position;
  final TextEditingController points;
  final TextEditingController wins;
  final TextEditingController poles;
  final TextEditingController fastestLaps;
  final TextEditingController races;

  _StandingPayload? toPayload(int categoryId) {
    final parsedPosition = int.tryParse(position.text.trim());
    final parsedPoints = int.tryParse(points.text.trim());
    final parsedWins = int.tryParse(wins.text.trim());
    final parsedPoles = int.tryParse(poles.text.trim());
    final parsedFastestLaps = int.tryParse(fastestLaps.text.trim());
    final parsedRaces = int.tryParse(races.text.trim());
    if (parsedPosition == null ||
        parsedPoints == null ||
        parsedWins == null ||
        parsedPoles == null ||
        parsedFastestLaps == null ||
        parsedRaces == null) {
      return null;
    }
    return _StandingPayload(standingId, {
      'categoryId': categoryId,
      'userId': userId,
      'position': parsedPosition,
      'points': parsedPoints,
      'wins': parsedWins,
      'poles': parsedPoles,
      'fastestLaps': parsedFastestLaps,
      'races': parsedRaces,
    });
  }

  void dispose() {
    position.dispose();
    points.dispose();
    wins.dispose();
    poles.dispose();
    fastestLaps.dispose();
    races.dispose();
  }
}

class _StandingPayload {
  const _StandingPayload(this.standingId, this.data);

  final int? standingId;
  final Map<String, dynamic> data;
}

class _StandingsGrid extends StatefulWidget {
  const _StandingsGrid({required this.drafts});

  final List<_StandingDraft> drafts;

  @override
  State<_StandingsGrid> createState() => _StandingsGridState();
}

class _StandingsGridState extends State<_StandingsGrid> {
  final horizontalController = ScrollController();

  @override
  void dispose() {
    horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Scrollbar(
          controller: horizontalController,
          thumbVisibility: true,
          notificationPredicate: (notification) =>
              notification.metrics.axis == Axis.horizontal,
          child: SingleChildScrollView(
            controller: horizontalController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(bottom: 16),
            child: DataTable(
              columnSpacing: 18,
              headingTextStyle: const TextStyle(
                color: PotatosColors.smoke,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
              columns: const [
                DataColumn(label: Text('Piloto')),
                DataColumn(label: Text('Pos.')),
                DataColumn(label: Text('Pts')),
                DataColumn(label: Text('Vitorias')),
                DataColumn(label: Text('Poles')),
                DataColumn(label: Text('Corridas')),
                DataColumn(label: Text('Voltas rapidas')),
              ],
              rows: [
                for (final draft in widget.drafts)
                  DataRow(
                    cells: [
                      DataCell(SizedBox(
                        width: 150,
                        child: Text(draft.pilotName,
                            overflow: TextOverflow.ellipsis,
                            style:
                                const TextStyle(fontWeight: FontWeight.w800)),
                      )),
                      DataCell(
                          _StandingNumberField(controller: draft.position)),
                      DataCell(_StandingNumberField(controller: draft.points)),
                      DataCell(_StandingNumberField(controller: draft.wins)),
                      DataCell(_StandingNumberField(controller: draft.poles)),
                      DataCell(_StandingNumberField(controller: draft.races)),
                      DataCell(
                          _StandingNumberField(controller: draft.fastestLaps)),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StandingNumberField extends StatelessWidget {
  const _StandingNumberField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 74,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        ),
      ),
    );
  }
}

class _NotificationsAdminTab extends StatefulWidget {
  const _NotificationsAdminTab({required this.reloadToken});

  final int reloadToken;

  @override
  State<_NotificationsAdminTab> createState() => _NotificationsAdminTabState();
}

class _NotificationsAdminTabState extends State<_NotificationsAdminTab> {
  final message = TextEditingController();
  List<dynamic> pilots = [];
  final selectedPilotIds = <int>{};
  bool allPilots = true;
  bool loading = false;
  bool sending = false;
  String? loadError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) loadPilots();
    });
  }

  @override
  void didUpdateWidget(covariant _NotificationsAdminTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reloadToken != widget.reloadToken) loadPilots();
  }

  @override
  void dispose() {
    message.dispose();
    super.dispose();
  }

  Future<void> loadPilots() async {
    setState(() {
      loading = true;
      loadError = null;
    });
    try {
      final result = await ApiScope.of(context).pilots();
      final loadedPilots = result.data as List<dynamic>;
      if (!mounted) return;
      setState(() {
        pilots = loadedPilots;
        loading = false;
        selectedPilotIds
          ..clear()
          ..addAll(loadedPilots.map((pilot) => pilot['id'] as int));
        allPilots = true;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        loading = false;
        loadError = _errorMessage(error, 'Nao foi possivel carregar pilotos.');
      });
    }
  }

  void toggleAll(bool value) {
    setState(() {
      allPilots = value;
      selectedPilotIds.clear();
      if (value) {
        selectedPilotIds.addAll(pilots.map((pilot) => pilot['id'] as int));
      }
    });
  }

  void togglePilot(int id, bool value) {
    setState(() {
      if (value) {
        selectedPilotIds.add(id);
      } else {
        selectedPilotIds.remove(id);
      }
      allPilots = selectedPilotIds.length == pilots.length && pilots.isNotEmpty;
    });
  }

  Future<void> send() async {
    final text = message.text.trim();
    if (text.isEmpty) {
      _toast(context, 'Informe a mensagem da notificacao.');
      return;
    }
    if (selectedPilotIds.isEmpty) {
      _toast(context, 'Selecione pelo menos um piloto.');
      return;
    }
    setState(() => sending = true);
    String? successMessage;
    await _guard(context, () async {
      final result = await ApiScope.of(context).sendNotification({
        'message': text,
        'allPilots': allPilots,
        'userIds': selectedPilotIds.toList(),
      });
      final recipientCount = result.data['recipientCount'];
      final deviceCount = result.data['deviceCount'];
      message.clear();
      successMessage =
          'Notificacao registrada para $recipientCount pilotos. Dispositivos: $deviceCount.';
    }, successMessage: null);
    if (!mounted) return;
    if (successMessage != null) _toast(context, successMessage!);
    setState(() => sending = false);
  }

  @override
  Widget build(BuildContext context) {
    return _AdminList(
      title: 'Notificacoes',
      subtitle:
          'Envie comunicados para pilotos. Emojis e acentos sao aceitos normalmente.',
      form: Column(
        children: [
          TextField(
            controller: message,
            minLines: 3,
            maxLines: 6,
            maxLength: 500,
            decoration: const InputDecoration(
              labelText: 'Mensagem',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: sending ? null : send,
              icon: sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_outlined),
              label: Text(sending ? 'Enviando...' : 'Enviar notificacao'),
            ),
          ),
        ],
      ),
      children: [
        if (loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (loadError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _AdminInlineError(message: loadError!, onRetry: loadPilots),
          ),
        if (!loading && pilots.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Text('Nenhum piloto ativo encontrado.',
                style: TextStyle(color: PotatosColors.smoke)),
          )
        else ...[
          Card(
            child: CheckboxListTile(
              value: allPilots,
              onChanged: (value) => toggleAll(value ?? false),
              title: const Text('Todos os pilotos',
                  style: TextStyle(fontWeight: FontWeight.w900)),
              subtitle: Text('${selectedPilotIds.length} selecionados'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
          for (final pilot in pilots)
            Card(
              child: CheckboxListTile(
                value: selectedPilotIds.contains(pilot['id']),
                onChanged: (value) =>
                    togglePilot(pilot['id'] as int, value ?? false),
                title: Text(pilot['name'] as String,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text(pilot['email'] as String? ?? ''),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
        ],
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

class _AdminInlineError extends StatelessWidget {
  const _AdminInlineError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PotatosColors.racingOrange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: PotatosColors.racingOrange.withValues(alpha: 0.32),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_outlined,
              color: PotatosColors.racingOrange),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
          IconButton(
            tooltip: 'Tentar novamente',
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
          ),
        ],
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
    _toast(context, _errorMessage(error, 'Nao foi possivel salvar.'));
  }
}

String _errorMessage(Object error, String fallback) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
  }
  return fallback;
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
