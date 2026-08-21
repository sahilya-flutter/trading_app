class Watchlist {
  final String id;
  final String name;
  final List<String> symbols;
  final DateTime createdAt;

  const Watchlist({
    required this.id,
    required this.name,
    required this.symbols,
    required this.createdAt,
  });

  Watchlist copyWith({
    String? id,
    String? name,
    List<String>? symbols,
    DateTime? createdAt,
  }) {
    return Watchlist(
      id: id ?? this.id,
      name: name ?? this.name,
      symbols: symbols ?? List.unmodifiable(this.symbols),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'symbols': symbols,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Watchlist.fromJson(Map<String, dynamic> json) => Watchlist(
        id: json['id'] as String,
        name: json['name'] as String,
        symbols: (json['symbols'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Watchlist && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
