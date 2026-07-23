import 'package:flutter/material.dart';

class NotationResult {
  final int rating;
  final String comment;
  const NotationResult(this.rating, this.comment);
}

class NotationDialog {
  static Future<NotationResult?> show(BuildContext context, String providerName) {
    return showDialog<NotationResult>(
      context: context,
      builder: (_) => _NotationDialogContent(providerName: providerName),
    );
  }
}

class _NotationDialogContent extends StatefulWidget {
  final String providerName;
  const _NotationDialogContent({required this.providerName});

  @override
  State<_NotationDialogContent> createState() => _NotationDialogContentState();
}

class _NotationDialogContentState extends State<_NotationDialogContent> {
  int _rating = 0;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Noter ${widget.providerName}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Sora', color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 4),
              const Text(
                'Comment s\'est passée votre intervention ?',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontFamily: 'DM Sans'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final filled = i < _rating;
                  return IconButton(
                    onPressed: () => setState(() => _rating = i + 1),
                    icon: Icon(
                      filled ? Icons.star_rounded : Icons.star_border_rounded,
                      color: const Color(0xFFF59E0B),
                      size: 32,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Laissez un commentaire (optionnel)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _rating == 0
                          ? null
                          : () => Navigator.pop(context, NotationResult(_rating, _commentController.text.trim())),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                      child: const Text('Envoyer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
