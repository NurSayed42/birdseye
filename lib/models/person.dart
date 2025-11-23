class Person {
  final String name;
  final String division;
  final String district;
  final String upazila;
  final String union;
  final String supporter;

  Person({
    required this.name,
    required this.division,
    required this.district,
    required this.upazila,
    required this.union,
    required this.supporter,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    final info = json['person_additional_info'] ?? {};
    final collection = json['person_collection_info'] ?? {};

    return Person(
      name: json['nameEn'] ?? json['nameBn'] ?? '',
      division: info['division'] ?? '',
      district: info['district'] ?? '',
      upazila: info['upazilla'] ?? info['upazila'] ?? '',
      union: info['union'] ?? '',
      supporter: collection['supporter'] ?? 'Unknown',
    );
  }
}
