import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/action_item.dart';
import '../controllers/action_item_service.dart';
import 'app_theme.dart';

class PillarDetailView extends StatefulWidget {
  final String category;
  final int currentScore;
  final Color color;

  const PillarDetailView({
    super.key,
    required this.category,
    required this.currentScore,
    required this.color,
  });

  @override
  State<PillarDetailView> createState() => _PillarDetailViewState();
}

class _PillarDetailViewState extends State<PillarDetailView> {
  final ActionItemService _service = ActionItemService.instance;
  List<ActionItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await _service.getActionItems(widget.category);
    if (mounted) {
      setState(() {
        _items = items;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleItem(ActionItem item) async {
    final updated = item.copyWith(isCompleted: !item.isCompleted);
    await _service.updateActionItem(updated);
    _loadItems();
  }

  Future<void> _deleteItem(String id) async {
    await _service.deleteActionItem(id);
    _loadItems();
  }

  Future<void> _showAddDialog() async {
    final titleController = TextEditingController();
    DateTime? selectedDate;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF2E335A),
            title: Text(
              "Add Goal for ${widget.category}",
              style: AppTheme.heading2.copyWith(fontSize: 20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
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
                  if (titleController.text.trim().isNotEmpty) {
                    final newItem = ActionItem(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: titleController.text.trim(),
                      pillarCategory: widget.category,
                      createdAt: DateTime.now(),
                      targetDate: selectedDate,
                    );
                    await _service.addActionItem(newItem);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: widget.color.withOpacity(0.2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.category, style: AppTheme.heading2),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: widget.color,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2E335A), Color(0xFF1C1B33)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Score Indicator
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      "${widget.currentScore}/10",
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: widget.color,
                      ),
                    ),
                    const Text(
                      "Current Score",
                      style: TextStyle(color: Colors.white54),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text(
                      "Action Plan",
                      style: AppTheme.heading2.copyWith(fontSize: 20),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _items.isEmpty
                        ? Center(
                            child: Text(
                              "No goals set yet.\nTap + to add one!",
                              textAlign: TextAlign.center,
                              style: AppTheme.bodyText.copyWith(color: Colors.white30),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _items.length,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              return Dismissible(
                                key: Key(item.id),
                                background: Container(
                                  color: Colors.red.withOpacity(0.8),
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: const Icon(Icons.delete, color: Colors.white),
                                ),
                                direction: DismissDirection.endToStart,
                                onDismissed: (_) => _deleteItem(item.id),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: item.isCompleted
                                        ? Border.all(color: Colors.white10)
                                        : Border.all(color: widget.color.withOpacity(0.3)),
                                  ),
                                  child: ListTile(
                                    leading: Checkbox(
                                      value: item.isCompleted,
                                      activeColor: widget.color,
                                      checkColor: Colors.black,
                                      side: BorderSide(color: widget.color.withOpacity(0.5)),
                                      onChanged: (_) => _toggleItem(item),
                                    ),
                                    title: Text(
                                      item.title,
                                      style: TextStyle(
                                        color: item.isCompleted ? Colors.white38 : Colors.white,
                                        decoration: item.isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    subtitle: item.targetDate != null
                                        ? Text(
                                            "Target: ${DateFormat('MMM d').format(item.targetDate!)}",
                                            style: TextStyle(
                                              color: item.isCompleted
                                                  ? Colors.white24
                                                  : widget.color.withOpacity(0.8),
                                              fontSize: 12,
                                            ),
                                          )
                                        : null,
                                    onTap: () => _showEditDialog(item),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEditDialog(ActionItem item) async {
    final titleController = TextEditingController(text: item.title);
    DateTime? selectedDate = item.targetDate;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF2E335A),
            title: Text(
              "Edit Goal",
              style: AppTheme.heading2.copyWith(fontSize: 20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
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
                  if (titleController.text.trim().isNotEmpty) {
                    final updatedItem = item.copyWith(
                      title: titleController.text.trim(),
                      targetDate: selectedDate,
                    );
                    await _service.updateActionItem(updatedItem);
                    if (mounted) Navigator.pop(context);
                    _loadItems();
                  }
                },
                child: const Text("Save"),
              ),
            ],
          );
        },
      ),
    );
  }
}
