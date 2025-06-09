class FilterOption<T> {
  final String id;
  final String label;
  final T value;
  final bool isSelected;

  const FilterOption({
    required this.id,
    required this.label,
    required this.value,
    this.isSelected = false,
  });

  FilterOption<T> copyWith({
    String? id,
    String? label,
    T? value,
    bool? isSelected,
  }) {
    return FilterOption<T>(
      id: id ?? this.id,
      label: label ?? this.label,
      value: value ?? this.value,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterOption &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}