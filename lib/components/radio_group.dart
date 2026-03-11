import 'package:flutter/material.dart';

/// RadioGroup wrapper untuk kompatibilitas
class RadioGroup<T> extends StatefulWidget {
  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final Widget child;

  const RadioGroup({
    Key? key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.child,
  }) : super(key: key);

  @override
  State<RadioGroup<T>> createState() => _RadioGroupState<T>();
}

class _RadioGroupState<T> extends State<RadioGroup<T>> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onChanged?.call(widget.value);
      },
      child: Row(
        children: [
          Radio<T>(
            value: widget.value,
            groupValue: widget.groupValue,
            onChanged: widget.onChanged,
          ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}
