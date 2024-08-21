import 'package:flutter/material.dart';

class ExpandableSection extends StatefulWidget {
  const ExpandableSection(
      {super.key,
      required this.title,
      required this.content,
      this.isExpanded = false});
  final Widget title;
  final Widget content;
  final bool isExpanded;

  @override
  State<ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late bool _isExpanded;

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      value: _isExpanded ? 1.0 : 0.0,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(8),
              topRight: const Radius.circular(8),
              bottomLeft:
                  _isExpanded ? Radius.zero : const Radius.circular(8.0),
              bottomRight:
                  _isExpanded ? Radius.zero : const Radius.circular(8.0),
            ),
          ),
          margin: const EdgeInsets.only(top: 8),
          child: InkWell(
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(8),
              topRight: const Radius.circular(8),
              bottomLeft:
                  !_isExpanded ? Radius.zero : const Radius.circular(8.0),
              bottomRight:
                  !_isExpanded ? Radius.zero : const Radius.circular(8.0),
            ),
            onTap: _toggleExpand,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  widget.title,
                  RotationTransition(
                    turns: Tween(begin: 0.0, end: 0.5).animate(_controller),
                    child: const Icon(Icons.arrow_drop_down),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizeTransition(
          axisAlignment: 1.0,
          sizeFactor: _expandAnimation,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.zero,
                  topRight: Radius.zero,
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                color: Theme.of(context).colorScheme.surfaceContainerLow),
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 0,
              top: 8,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 0),
            child: widget.content,
          ),
        ),
      ],
    );
  }
}
