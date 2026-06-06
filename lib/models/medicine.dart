class Medicine {
  final String id;
  final String name;
  final String generic;
  final String category;
  final String usage;
  final String dosage;
  final String warning;

  Medicine({
    required this.id,
    required this.name,
    required this.generic,
    required this.category,
    required this.usage,
    required this.dosage,
    required this.warning,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] ?? '',
      generic: json['generic'] ?? json['genericName'] ?? '',
      category: json['category'] ?? '',
      usage: json['usage'] ?? json['description'] ?? '',
      dosage: json['dosage'] ?? '',
      warning: json['warning'] ?? json['warnings'] ?? '',
    );
  }

  String toShareText() {
    return 'Medicine: $name\nGeneric: $generic\nCategory: $category\nUsage: $usage\nDosage: $dosage\nWarning: $warning';
  }
}