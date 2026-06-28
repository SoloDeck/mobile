import 'package:flutter/material.dart';
import 'package:solodesk_mobile/modules/tasks/domain/entities/checklist_item.dart';

/// Read-only display of a task's checklist items with their done state.
class ChecklistWidget extends StatelessWidget {
  const ChecklistWidget({super.key, required this.items});

  final List<ChecklistItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Text('Chưa có mục checklist nào.');
    }

    final sorted = [...items]
      ..sort((a, b) => a.position.compareTo(b.position));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in sorted)
          Row(
            children: [
              Icon(
                item.isDone
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.text,
                  style: item.isDone
                      ? const TextStyle(
                          decoration: TextDecoration.lineThrough,
                        )
                      : null,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
