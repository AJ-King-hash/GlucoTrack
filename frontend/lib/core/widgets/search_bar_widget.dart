import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onSearch;
  final VoidCallback? onClear;
  final Duration debounceDelay;

  const SearchBarWidget({
    super.key,
    this.hintText = 'Search...',
    this.onSearch,
    this.onClear,
    this.debounceDelay = const Duration(milliseconds: 500),
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _showClear = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {
      _showClear = value.isNotEmpty;
    });
  }

  void _onSubmitted(String value) {
    widget.onSearch?.call(value);
  }

  void _onClear() {
    _controller.clear();
    setState(() {
      _showClear = false;
    });
    widget.onClear?.call();
    widget.onSearch?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _onChanged,
      onSubmitted: _onSubmitted,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search),
        suffixIcon:
            _showClear
                ? IconButton(icon: const Icon(Icons.clear), onPressed: _onClear)
                : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
