import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bi.dart';

class SearchBarWithFilter extends StatefulWidget {
  final TextEditingController controller;
  final Function(String)? onSearchChanged;
  final VoidCallback? onFilterTap;

  const SearchBarWithFilter({
    super.key,
    required this.controller,
    this.onSearchChanged,
    this.onFilterTap,
  });

  @override
  State<SearchBarWithFilter> createState() => _SearchBarWithFilterState();
}

class _SearchBarWithFilterState extends State<SearchBarWithFilter> {

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  void _onSearchTextChanged(String text) {
    if (widget.onSearchChanged != null) {
      widget.onSearchChanged!(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xfff0f1f1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextField(
              controller: widget.controller,
              onChanged: _onSearchTextChanged,
              textAlignVertical: TextAlignVertical.center,
              decoration: const InputDecoration(
                hintText: 'Search Folder...',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ),
        ),
        const SizedBox(width: 5),
        InkWell(
          onTap: widget.onFilterTap,
          child: const Iconify(
            Bi.sort_down,
            color: Color(0xffA9ABAC),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          "Name",
          style: TextStyle(color: Color(0xffA9ABAC)),
        ),
      ],
    );
  }
}
