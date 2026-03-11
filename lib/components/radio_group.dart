import 'package:flutter/material.dart';

export 'package:flutter/material.dart' hide Radio;

/// Simple radio button wrapper for DNA63 app
/// Usage: RadioGroup<int>(
///   groupValue: selectedValue,
///   onChanged: (val) => setState(() => selectedValue = val),
///   child: Radio<int>(value: 1),  // only value, no groupValue
/// )
class RadioGroup<T> extends StatelessWidget {
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final _RadioPlaceholder<T> child;

  const RadioGroup({
    Key? key,
    required this.groupValue,
    required this.onChanged,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSelected = groupValue == child.value;
    return GestureDetector(
      onTap: () => onChanged?.call(child.value),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
            width: 2,
          ),
        ),
        child: isSelected
            ? Center(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

/// Radio placeholder - just holds the value
class _RadioPlaceholder<T> extends StatelessWidget {
  final T value;
  
  const _RadioPlaceholder({
    required this.value,
  });
  
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}


