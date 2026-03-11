import 'package:flutter/material.dart' hide Radio;
import 'package:flutter/material.dart' as material;

/// RadioPlaceholder - holds just the value for RadioGroup
class RadioPlaceholder<T> extends StatelessWidget {
  final T value;
  const RadioPlaceholder({Key? key, required this.value}) : super(key: key);
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// RadioGroup - wraps RadioPlaceholder with actual Radio functionality
class RadioGroup<T> extends StatelessWidget {
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final RadioPlaceholder<T> child;

  const RadioGroup({
    Key? key,
    required this.groupValue,
    required this.onChanged,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged?.call(child.value),
      child: material.Radio<T>(
        value: child.value,
        groupValue: groupValue,
        onChanged: onChanged,
      ),
    );
  }
}

/// Radio factory function - creates a RadioPlaceholder
/// Usage: child: RadioStub(value: GroupType.PUBLIC)
RadioPlaceholder<T> RadioStub<T>({required T value}) {
  return RadioPlaceholder<T>(value: value);
}
