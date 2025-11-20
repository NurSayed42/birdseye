class Person {
  final int id;
  final String serial;
  final String voterNo;
  final String nameBn;
  final String nameEn;
  final String fatherBn;
  final String fatherEn;
  final String mother;
  final String occupation;
  final String dob;
  final String address;
  final PersonAdditionalInfo additionalInfo;
  final PersonCollectionInfo collectionInfo;

  Person({
    required this.id,
    required this.serial,
    required this.voterNo,
    required this.nameBn,
    required this.nameEn,
    required this.fatherBn,
    required this.fatherEn,
    required this.mother,
    required this.occupation,
    required this.dob,
    required this.address,
    required this.additionalInfo,
    required this.collectionInfo,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'],
      serial: json['serial'],
      voterNo: json['voterNo'],
      nameBn: json['nameBn'],
      nameEn: json['nameEn'],
      fatherBn: json['fatherBn'],
      fatherEn: json['fatherEn'],
      mother: json['mother'],
      occupation: json['occupation'],
      dob: json['dob'],
      address: json['address'],
      additionalInfo: PersonAdditionalInfo.fromJson(json['person_additional_info']),
      collectionInfo: PersonCollectionInfo.fromJson(json['person_collection_info']),
    );
  }
}

class PersonAdditionalInfo {
  final String gender;
  final String division;
  final int constituencyNo;
  final String constituencyName;
  final String constituencyArea;
  final String areaZoneName;
  final String district;
  final String upazilla;
  final String thana;
  final String union;
  final int ward;
  final String post;
  final String postCode;

  PersonAdditionalInfo({
    required this.gender,
    required this.division,
    required this.constituencyNo,
    required this.constituencyName,
    required this.constituencyArea,
    required this.areaZoneName,
    required this.district,
    required this.upazilla,
    required this.thana,
    required this.union,
    required this.ward,
    required this.post,
    required this.postCode,
  });

  factory PersonAdditionalInfo.fromJson(Map<String, dynamic> json) {
    return PersonAdditionalInfo(
      gender: json['gender'] ?? '',
      division: json['division'] ?? '',
      constituencyNo: json['constituencyNo'] ?? 0,
      constituencyName: json['constituencyName'] ?? '',
      constituencyArea: json['constituencyArea'] ?? '',
      areaZoneName: json['areaZoneName'] ?? '',
      district: json['district'] ?? '',
      upazilla: json['upazilla'] ?? '',
      thana: json['thana'] ?? '',
      union: json['union'] ?? '',
      ward: json['ward'] ?? 0,
      post: json['post'] ?? '',
      postCode: json['postCode'] ?? '',
    );
  }
}

class PersonCollectionInfo {
  final String supporter;
  final String religion;
  final String ethnicity;
  final String bloodGroup;
  final String incomeRange;
  final String fitness;
  final String serviceStatus;
  final String maritalStatus;

  PersonCollectionInfo({
    required this.supporter,
    required this.religion,
    required this.ethnicity,
    required this.bloodGroup,
    required this.incomeRange,
    required this.fitness,
    required this.serviceStatus,
    required this.maritalStatus,
  });

  factory PersonCollectionInfo.fromJson(Map<String, dynamic> json) {
    return PersonCollectionInfo(
      supporter: json['supporter'] ?? '',
      religion: json['religion'] ?? '',
      ethnicity: json['ethnicity'] ?? '',
      bloodGroup: json['bloodGroup'] ?? '',
      incomeRange: json['incomeRange'] ?? '',
      fitness: json['fitness'] ?? '',
      serviceStatus: json['serviceStatus'] ?? '',
      maritalStatus: json['maritalStatus'] ?? '',
    );
  }
}