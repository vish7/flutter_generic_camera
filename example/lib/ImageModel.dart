class ImageModel {
  final int id;
  final String? path;

  ImageModel({
    required this.id,
    this.path,
  });

  factory ImageModel.fromMap(Map<String, dynamic> map) {
    return ImageModel(
      id: map['id'],
      path: map['path'],
    );
  }
}