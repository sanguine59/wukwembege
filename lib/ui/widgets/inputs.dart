import 'package:flutter/material.dart';
import '../../theme.dart';
import 'app_icon.dart';

class Field extends StatelessWidget {
  final String? label;
  final String? hint;
  final Widget child;
  const Field({super.key, this.label, this.hint, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Text(label!, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: AppColors.text2, letterSpacing: 0.1)),
          ),
        child,
        if (hint != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 2),
            child: Text(hint!, style: const TextStyle(fontSize: 11.5, color: AppColors.text3, fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }
}

class AppTextInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final String? placeholder;
  final bool obscure;
  final String? leadIcon;
  final String? trailIcon;
  final VoidCallback? onTrail;
  final TextInputType keyboardType;
  final int? minLines;
  final int? maxLines;
  const AppTextInput({
    super.key,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.placeholder,
    this.obscure = false,
    this.leadIcon,
    this.trailIcon,
    this.onTrail,
    this.keyboardType = TextInputType.text,
    this.minLines,
    this.maxLines = 1,
  });

  @override
  State<AppTextInput> createState() => _AppTextInputState();
}

class _AppTextInputState extends State<AppTextInput> {
  late TextEditingController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = widget.controller ?? TextEditingController(text: widget.initialValue ?? '');
  }
  @override
  void dispose() {
    if (widget.controller == null) _ctrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          if (widget.leadIcon != null) ...[
            AppIcon(widget.leadIcon!, size: 18, color: AppColors.text3),
            const SizedBox(width: 9),
          ],
          Expanded(
            child: TextField(
              controller: _ctrl,
              onChanged: widget.onChanged,
              obscureText: widget.obscure,
              keyboardType: widget.keyboardType,
              minLines: widget.minLines,
              maxLines: widget.maxLines,
              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.ink),
              decoration: InputDecoration(
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: InputBorder.none,
                hintText: widget.placeholder,
                hintStyle: const TextStyle(color: AppColors.text4, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          if (widget.trailIcon != null)
            GestureDetector(
              onTap: widget.onTrail,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: AppIcon(widget.trailIcon!, size: 18, color: AppColors.text3),
              ),
            ),
        ],
      ),
    );
  }
}

class SearchInput extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final String placeholder;
  const SearchInput({super.key, required this.value, required this.onChanged, this.placeholder = 'Search events'});

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  late final TextEditingController _ctrl = TextEditingController(text: widget.value);
  @override
  void didUpdateWidget(covariant SearchInput old) {
    super.didUpdateWidget(old);
    if (widget.value != _ctrl.text) {
      _ctrl.text = widget.value;
      _ctrl.selection = TextSelection.collapsed(offset: widget.value.length);
    }
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const AppIcon('search', size: 18, color: AppColors.text3),
          const SizedBox(width: 9),
          Expanded(
            child: TextField(
              controller: _ctrl,
              onChanged: widget.onChanged,
              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: InputBorder.none,
                hintText: widget.placeholder,
                hintStyle: const TextStyle(color: AppColors.text4, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          if (widget.value.isNotEmpty)
            GestureDetector(
              onTap: () => widget.onChanged(''),
              child: const Padding(
                padding: EdgeInsets.only(left: 6),
                child: AppIcon('x', size: 17, color: AppColors.text3),
              ),
            ),
        ],
      ),
    );
  }
}
