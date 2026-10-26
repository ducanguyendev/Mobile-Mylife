import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/api/api_endpoints.dart';
import '../../../shared/api/dio_client.dart';
import '../models/library_models.dart';

final libraryApiProvider =
    Provider((ref) => LibraryApiService(ref.watch(dioClientProvider)));

class LibraryApiService {
  LibraryApiService(this._dio);
  final Dio _dio;
  Future<List<LibraryAlbum>> albums() async {
    final d = (await _dio.get(ApiEndpoints.libraryAlbums)).data;
    if (d is! List) throw const FormatException('Invalid album list');
    return d
        .whereType<Map>()
        .map((v) => LibraryAlbum.fromJson(Map<String, dynamic>.from(v)))
        .toList();
  }

  Future<LibraryAlbum> album(int id) async {
    final d = (await _dio.get(ApiEndpoints.libraryAlbum(id))).data;
    if (d is! Map) throw const FormatException('Invalid album response');
    return LibraryAlbum.fromJson(Map<String, dynamic>.from(d));
  }

  Future<void> saveAlbum(
      {int? id, required String name, String? description}) async {
    final data = {'name': name.trim(), 'description': description};
    if (id == null) {
      await _dio.post(ApiEndpoints.libraryAlbums, data: data);
    } else {
      await _dio.put(ApiEndpoints.libraryAlbum(id), data: data);
    }
  }

  Future<void> deleteAlbum(int id) async {
    await _dio.delete(ApiEndpoints.libraryAlbum(id));
  }

  Future<List<LibraryPhoto>> upload(int albumId, List<String> paths,
      {String? title,
      String? displayDate,
      String? description,
      String? author}) async {
    final files = <MultipartFile>[];
    for (final path in paths) {
      files.add(await MultipartFile.fromFile(path,
          filename: path.split(RegExp(r'[/\\]')).last));
    }
    final form = FormData();
    form.files.addAll(files.map((file) => MapEntry('files', file)));
    form.fields.addAll([
      MapEntry('title', title ?? ''),
      MapEntry('displayDate', displayDate ?? ''),
      MapEntry('description', description ?? ''),
      MapEntry('author', author ?? '')
    ]);
    final d =
        (await _dio.post(ApiEndpoints.libraryAlbumPhotos(albumId), data: form))
            .data;
    if (d is! List) throw const FormatException('Invalid upload response');
    return d
        .whereType<Map>()
        .map((v) => LibraryPhoto.fromJson(Map<String, dynamic>.from(v)))
        .toList();
  }

  Future<void> updatePhoto(int id, Map<String, Object?> metadata) async {
    await _dio.put(ApiEndpoints.libraryPhoto(id), data: metadata);
  }

  Future<void> deletePhoto(int id) async {
    await _dio.delete(ApiEndpoints.libraryPhoto(id));
  }

  Future<Uint8List> image(int id) async {
    final r = await _dio.get<List<int>>(ApiEndpoints.libraryPhotoImage(id),
        options: Options(responseType: ResponseType.bytes));
    return Uint8List.fromList(r.data ?? const []);
  }
}
