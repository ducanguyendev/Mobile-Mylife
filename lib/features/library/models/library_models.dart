class LibraryPhoto {
  const LibraryPhoto(
      {required this.id,
      required this.url,
      required this.fileName,
      required this.title,
      required this.displayDate,
      required this.description,
      required this.author,
      required this.caption,
      required this.category,
      required this.createdAt});
  final int id;
  final String url, fileName, category;
  final String? title, displayDate, description, author, caption;
  final DateTime? createdAt;
  factory LibraryPhoto.fromJson(Map<String, dynamic> j) => LibraryPhoto(
      id: (j['id'] as num).toInt(),
      url: j['url'] as String? ?? '',
      fileName: j['fileName'] as String? ?? '',
      title: j['title'] as String?,
      displayDate: j['displayDate'] as String?,
      description: (j['description'] as String?) ?? (j['caption'] as String?),
      author: j['author'] as String?,
      caption: j['caption'] as String?,
      category: j['category'] as String? ?? '',
      createdAt: DateTime.tryParse(j['createdAt'] as String? ?? ''));
  Map<String, Object?> metadataJson(
          {String? title,
          String? displayDate,
          String? description,
          String? author}) =>
      {
        'title': title,
        'displayDate': displayDate,
        'description': description,
        'author': author,
        'category': category
      };
}

class LibraryAlbum {
  const LibraryAlbum(
      {required this.id,
      required this.name,
      required this.photoCount,
      this.description,
      this.coverPhotoId,
      this.photos = const []});
  final int id, photoCount;
  final String name;
  final String? description;
  final int? coverPhotoId;
  final List<LibraryPhoto> photos;
  factory LibraryAlbum.fromJson(Map<String, dynamic> j) => LibraryAlbum(
      id: (j['id'] as num).toInt(),
      name: j['name'] as String,
      description: j['description'] as String?,
      photoCount: (j['photoCount'] as num?)?.toInt() ?? 0,
      coverPhotoId: (j['coverPhotoId'] as num?)?.toInt(),
      photos: (j['photos'] as List? ?? const [])
          .whereType<Map>()
          .map((v) => LibraryPhoto.fromJson(Map<String, dynamic>.from(v)))
          .toList());
}
