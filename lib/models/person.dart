class Person {
  final String name;
  final String division;
  final String district;
  final String upazila;
  final String union;

  Person({
    required this.name,
    required this.division,
    required this.district,
    required this.upazila,
    required this.union,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    final info = json['person_additional_info'] ?? {};

    return Person(
      name: json['nameEn'] ?? json['nameBn'] ?? '',
      division: info['division'] ?? '',
      district: info['district'] ?? '',
      upazila: info['upazilla'] ?? info['upazila'] ?? '',
      union: info['union'] ?? '',
    );
  }
}
