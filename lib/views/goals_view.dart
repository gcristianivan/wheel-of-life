import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/action_item.dart';
import '../controllers/action_item_service.dart';
import '../controllers/auth_controller.dart';
import 'app_theme.dart';
import 'paywall_view.dart';

class GoalsView extends StatefulWidget {
  const GoalsView({super.key});

  @override
  State<GoalsView> createState() => _GoalsViewState();
}

class _GoalsViewState extends State<GoalsView> {
  final ActionItemService _service = ActionItemService.instance;
  final AuthController _auth = AuthController();
  List<ActionItem> _activeItems = [];
  List<ActionItem> _completedItems = [];
  bool _isLoading = true;

  String _sortMethod = 'Deadline'; // 'Deadline' or 'Category'
  bool _isCompletedExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final allItems = await _service.getAllActionItems();

    if (mounted) {
      setState(() {
        _activeItems = allItems.where((i) => !i.isCompleted).toList();
        _completedItems = allItems.where((i) => i.isCompleted).toList();
        _sortItems();
        _isLoading = false;
      });
    }
  }

  void _sortItems() {
    if (_sortMethod == 'Deadline') {
      _activeItems.sort((a, b) {
        if (a.targetDate == null && b.targetDate == null) return 0;
        if (a.targetDate == null) return 1;
        if (b.targetDate == null) return -1;
        return a.targetDate!.compareTo(b.targetDate!);
      });
      _completedItems.sort((a, b) {
        if (a.targetDate == null && b.targetDate == null) return 0;
        if (a.targetDate == null) return 1;
        if (b.targetDate == null) return -1;
        return a.targetDate!.compareTo(b.targetDate!);
      });
    } else if (_sortMethod == 'Category') {
      _activeItems.sort((a, b) => a.pillarCategory.compareTo(b.pillarCategory));
      _completedItems
          .sort((a, b) => a.pillarCategory.compareTo(b.pillarCategory));
    }
  }

  Future<void> _toggleItem(ActionItem item) async {
    final updated = item.copyWith(isCompleted: !item.isCompleted);
    await _service.updateActionItem(updated);
    _loadItems();
  }

  Future<void> _deleteItem(ActionItem item) async {
    await _service.deleteActionItem(item.id);
    _loadItems();
  }

  Future<void> _deleteAllCompleted() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2E335A),
        title: Text("Delete All Completed", style: AppTheme.heading2),
        content: const Text(
          "Are you sure you want to permanently delete all completed goals?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      for (final item in _completedItems) {
        await _service.deleteActionItem(item.id);
      }
      if (mounted) _loadItems();
    }
  }

  Widget _buildItemCard(ActionItem item) {
    final categoryColor =
        AppTheme.categoryColors[item.pillarCategory] ?? Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: categoryColor.withOpacity(0.3)),
      ),
      child: ListTile(
        leading: Checkbox(
          value: item.isCompleted,
          activeColor: categoryColor,
          checkColor: Colors.black,
          side: BorderSide(color: categoryColor.withOpacity(0.5)),
          onChanged: (_) => _toggleItem(item),
        ),
        title: Text(
          item.title,
          style: TextStyle(
            color: item.isCompleted ? Colors.white38 : Colors.white,
            decoration: item.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.pillarCategory.toUpperCase(),
              style: TextStyle(
                color: categoryColor,
                fontSize: 10,
                letterSpacing: 1.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (item.targetDate != null)
              Text(
                "Target: ${DateFormat('MMM d').format(item.targetDate!)}",
                style: TextStyle(
                  color: item.isCompleted ? Colors.white24 : Colors.white54,
                  fontSize: 12,
                ),
              )
          ],
        ),
        trailing: item.isCompleted
            ? IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white38),
                onPressed: () => _deleteItem(item),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Goals', style: AppTheme.heading2),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Colors.white),
            tooltip: "Sort",
            onSelected: (value) {
              setState(() {
                _sortMethod = value;
                _sortItems();
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'Deadline',
                child: Text(
                  'Sort by Deadline',
                  style: TextStyle(
                    fontWeight: _sortMethod == 'Deadline'
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'Category',
                child: Text(
                  'Sort by Category',
                  style: TextStyle(
                    fontWeight: _sortMethod == 'Category'
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
          if (_completedItems.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                if (value == 'clear_completed') {
                  _deleteAllCompleted();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'clear_completed',
                  child: Text('Delete All Completed'),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: FloatingActionButton(
          backgroundColor: AppTheme.accentColor,
          onPressed: _showAddGoalDialog,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2E335A), Color(0xFF1C1B33)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    if (_activeItems.isEmpty && _completedItems.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 100.0),
                          child: Text(
                            "No goals found.\nTap the + button to add one!",
                            textAlign: TextAlign.center,
                            style: AppTheme.bodyText
                                .copyWith(color: Colors.white30),
                          ),
                        ),
                      )
                    else ...[
                      // Active Items
                      if (_activeItems.isNotEmpty)
                        ..._activeItems.map((item) => _buildItemCard(item)),

                      // Completed Items Expansion Tile
                      if (_completedItems.isNotEmpty)
                        Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            initiallyExpanded: _isCompletedExpanded,
                            onExpansionChanged: (val) {
                              setState(() => _isCompletedExpanded = val);
                            },
                            tilePadding: EdgeInsets.zero,
                            title: Text(
                              "Completed Goals (${_completedItems.length})",
                              style: const TextStyle(
                                color: Colors.white54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            iconColor: Colors.white54,
                            collapsedIconColor: Colors.white54,
                            children: _completedItems
                                .map((item) => _buildItemCard(item))
                                .toList(),
                          ),
                        ),
                    ],
                    const SizedBox(height: 100), // padding for bottom nav space
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _showAddGoalDialog() async {
    final isPremium = await _auth.isPremium;
    if (!isPremium && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PaywallView()),
      );
      return;
    }

    final titleController = TextEditingController();
    DateTime? selectedDate;
    String? selectedCategory = AppTheme.categoryColors.keys.first;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF2E335A),
            title: Text(
              "New Goal",
              style: AppTheme.heading2.copyWith(fontSize: 20),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    dropdownColor: const Color(0xFF1C1B33),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Category",
                      labelStyle: TextStyle(color: Colors.white54),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.accentColor),
                      ),
                    ),
                    items: AppTheme.categoryColors.keys.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "What do you want to achieve?",
                      hintStyle: TextStyle(color: Colors.white54),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.accentColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        selectedDate == null
                            ? "No Deadline"
                            : DateFormat('MMM d, yyyy').format(selectedDate!),
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now()
                                .subtract(const Duration(days: 365)),
                            lastDate: DateTime.now()
                                .add(const Duration(days: 365 * 5)),
                          );
                          if (date != null) {
                            setState(() {
                              selectedDate = date;
                            });
                          }
                        },
                        child: const Text("Set Date"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                ),
                onPressed: () async {
                  if (titleController.text.trim().isNotEmpty &&
                      selectedCategory != null) {
                    final newItem = ActionItem(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      pillarCategory: selectedCategory!,
                      title: titleController.text.trim(),
                      isCompleted: false,
                      targetDate: selectedDate,
                      createdAt: DateTime.now(),
                    );
                    await ActionItemService.instance.addActionItem(newItem);
                    if (mounted) Navigator.pop(context);
                    _loadItems();
                  }
                },
                child: const Text("Add"),
              ),
            ],
          );
        },
      ),
    );
  }
}
