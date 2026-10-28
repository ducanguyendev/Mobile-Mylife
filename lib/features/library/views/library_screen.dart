import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../../shared/api/api_error.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/mylife_design_tokens.dart';
import '../models/library_models.dart';
import '../providers/library_provider.dart';
import '../services/library_api_service.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});
  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  int? _selected;
  bool _busy = false;
  bool get _vi => Localizations.localeOf(context).languageCode == 'vi';
  Future<void> _albumDialog([LibraryAlbum? album]) async {
    final n = TextEditingController(text: album?.name ?? ''),
        d = TextEditingController(text: album?.description ?? '');
    final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
                title: Text(album == null
                    ? (_vi ? 'Tạo album' : 'Create album')
                    : (_vi ? 'Sửa album' : 'Edit album')),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(
                      controller: n,
                      decoration:
                          InputDecoration(labelText: _vi ? 'Tên' : 'Name')),
                  TextField(
                      controller: d,
                      maxLines: 3,
                      decoration: InputDecoration(
                          labelText: _vi ? 'Mô tả' : 'Description'))
                ]),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: Text(_vi ? 'Huỷ' : 'Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: Text(_vi ? 'Lưu' : 'Save'))
                ]));
    if (ok == true && n.text.trim().isNotEmpty) {
      try {
        await ref
            .read(libraryApiProvider)
            .saveAlbum(id: album?.id, name: n.text, description: d.text);
        await ref.read(libraryProvider.notifier).reload();
        if (album == null && mounted) {
          final list = ref.read(libraryProvider).valueOrNull ?? [];
          if (list.isNotEmpty) setState(() => _selected = list.first.id);
        }
      } catch (e) {
        _snack(ApiError.message(e));
      }
    }
    n.dispose();
    d.dispose();
  }

  Future<void> _deleteAlbum(LibraryAlbum a) async {
    final yes = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
                title: Text(_vi ? 'Xoá album?' : 'Delete album?'),
                content: Text(_vi
                    ? 'Ảnh trong album này cũng sẽ bị xoá.'
                    : 'Photos in this album will also be deleted.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: Text(_vi ? 'Huỷ' : 'Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: Text(_vi ? 'Xoá' : 'Delete'))
                ]));
    if (yes == true) {
      try {
        await ref.read(libraryApiProvider).deleteAlbum(a.id);
        setState(() => _selected = null);
        await ref.read(libraryProvider.notifier).reload();
      } catch (e) {
        _snack(ApiError.message(e));
      }
    }
  }

  Future<void> _upload() async {
    final id = _selected;
    if (id == null) return;
    final images = await ImagePicker().pickMultiImage(imageQuality: 88);
    if (!mounted || images.isEmpty) return;
    if (images.length > 20) {
      _snack(_vi
          ? 'Mỗi lần tải lên tối đa 20 ảnh.'
          : 'Upload up to 20 photos at a time.');
      return;
    }
    final title = TextEditingController(),
        date = TextEditingController(),
        description = TextEditingController(),
        author = TextEditingController();
    final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
                title: Text(_vi ? 'Thông tin ảnh' : 'Photo details'),
                content: SingleChildScrollView(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(
                      controller: title,
                      decoration: InputDecoration(
                          labelText: _vi ? 'Tiêu đề' : 'Title')),
                  TextField(
                      controller: date,
                      decoration: InputDecoration(
                          labelText: _vi ? 'Ngày hiển thị' : 'Display date')),
                  TextField(
                      controller: description,
                      decoration: InputDecoration(
                          labelText: _vi ? 'Mô tả' : 'Description')),
                  TextField(
                      controller: author,
                      decoration: InputDecoration(
                          labelText: _vi ? 'Tác giả' : 'Author'))
                ])),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: Text(_vi ? 'Huỷ' : 'Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: Text(_vi
                          ? 'Tải lên ${images.length} ảnh'
                          : 'Upload ${images.length} photos'))
                ]));
    if (ok == true) {
      setState(() => _busy = true);
      try {
        await ref.read(libraryApiProvider).upload(
            id, images.map((e) => e.path).toList(),
            title: title.text,
            displayDate: date.text,
            description: description.text,
            author: author.text);
        await ref.read(libraryProvider.notifier).reload();
      } catch (e) {
        _snack(ApiError.message(e));
      } finally {
        if (mounted) setState(() => _busy = false);
      }
    }
    title.dispose();
    date.dispose();
    description.dispose();
    author.dispose();
  }

  void _snack(String text) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }
  }

  Future<void> _editPhoto(LibraryPhoto p) async {
    final t = TextEditingController(text: p.title ?? ''),
        d = TextEditingController(text: p.displayDate ?? ''),
        desc = TextEditingController(text: p.description ?? ''),
        a = TextEditingController(text: p.author ?? '');
    final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
                title: Text(_vi ? 'Sửa thông tin ảnh' : 'Edit photo details'),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(
                      controller: t,
                      decoration: InputDecoration(
                          labelText: _vi ? 'Tiêu đề' : 'Title')),
                  TextField(
                      controller: d,
                      decoration: InputDecoration(
                          labelText: _vi ? 'Ngày hiển thị' : 'Display date')),
                  TextField(
                      controller: desc,
                      decoration: InputDecoration(
                          labelText: _vi ? 'Mô tả' : 'Description')),
                  TextField(
                      controller: a,
                      decoration: InputDecoration(
                          labelText: _vi ? 'Tác giả' : 'Author'))
                ]),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: Text(_vi ? 'Huỷ' : 'Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: Text(_vi ? 'Lưu' : 'Save'))
                ]));
    if (ok == true) {
      try {
        await ref.read(libraryApiProvider).updatePhoto(p.id, {
          'title': t.text,
          'displayDate': d.text,
          'description': desc.text,
          'author': a.text,
          'category': p.category
        });
        await ref.read(libraryProvider.notifier).reload();
      } catch (e) {
        _snack(ApiError.message(e));
      }
    }
    t.dispose();
    d.dispose();
    desc.dispose();
    a.dispose();
  }

  Future<void> _deletePhoto(LibraryPhoto p) async {
    final yes = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
                title: Text(_vi ? 'Xoá ảnh?' : 'Delete photo?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: Text(_vi ? 'Huỷ' : 'Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: Text(_vi ? 'Xoá' : 'Delete'))
                ]));
    if (yes == true) {
      try {
        await ref.read(libraryApiProvider).deletePhoto(p.id);
        await ref.read(libraryProvider.notifier).reload();
      } catch (e) {
        _snack(ApiError.message(e));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final albums = ref.watch(libraryProvider);
    final list = albums.valueOrNull ?? const <LibraryAlbum>[];
    final selected = list.where((a) => a.id == _selected).firstOrNull;
    return Scaffold(
        appBar: AppBar(title: Text(_vi ? 'Thư viện' : 'Library'), actions: [
          IconButton(
              onPressed: () => _albumDialog(),
              icon: const Icon(Icons.create_new_folder_outlined),
              tooltip: _vi ? 'Tạo album' : 'Create album')
        ]),
        body: albums.isLoading && list.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : albums.hasError && list.isEmpty
                ? Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(ApiError.message(albums.error!)),
                    TextButton(
                        onPressed: () =>
                            ref.read(libraryProvider.notifier).refresh(),
                        child: Text(_vi ? 'Thử lại' : 'Retry'))
                  ]))
                : RefreshIndicator(
                    onRefresh: () =>
                        ref.read(libraryProvider.notifier).refresh(),
                    child:
                        ListView(padding: const EdgeInsets.all(16), children: [
                      if (list.isEmpty)
                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 50),
                            child: Center(
                                child: Column(children: [
                              const Icon(Icons.photo_library_outlined,
                                  size: 56),
                              const SizedBox(height: 12),
                              Text(_vi
                                  ? 'Tạo album đầu tiên để lưu ảnh gia đình.'
                                  : 'Create your first album to keep family photos.'),
                              FilledButton.icon(
                                  onPressed: () => _albumDialog(),
                                  icon: const Icon(Icons.add),
                                  label:
                                      Text(_vi ? 'Tạo album' : 'Create album'))
                            ]))),
                      if (list.isNotEmpty) ...[
                        SizedBox(
                            height: 178,
                            child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: list
                                    .map((a) => _AlbumCoverCard(
                                          album: a,
                                          selected: _selected == a.id,
                                          onTap: () =>
                                              setState(() => _selected = a.id),
                                        ))
                                    .toList())),
                        const SizedBox(height: 16),
                      ],
                      if (selected != null) ...[
                        Row(children: [
                          Expanded(
                              child: Text(selected.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold))),
                          IconButton(
                              onPressed: () => _albumDialog(selected),
                              icon: const Icon(Icons.edit_outlined)),
                          IconButton(
                              onPressed: () => _deleteAlbum(selected),
                              icon: const Icon(Icons.delete_outline,
                                  color: AppColors.error))
                        ]),
                        if (selected.description?.isNotEmpty == true)
                          Text(selected.description!),
                        const SizedBox(height: 12),
                        FutureBuilder<LibraryAlbum>(
                            key: ValueKey(selected.id),
                            future:
                                ref.read(libraryApiProvider).album(selected.id),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: Padding(
                                        padding: EdgeInsets.all(28),
                                        child: CircularProgressIndicator()));
                              }
                              if (snapshot.hasError) {
                                return Text(ApiError.message(snapshot.error!));
                              }
                              final photos = snapshot.data?.photos ??
                                  const <LibraryPhoto>[];
                              if (photos.isEmpty) {
                                return Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Center(
                                        child: Text(_vi
                                            ? 'Album đang trống.'
                                            : 'This album is empty.')));
                              }
                              return GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 10,
                                          mainAxisSpacing: 10),
                                  itemCount: photos.length,
                                  itemBuilder: (context, i) {
                                    final p = photos[i];
                                    return _PhotoTile(
                                        photo: p,
                                        onTap: () => _preview(p),
                                        onEdit: () => _editPhoto(p),
                                        onDelete: () => _deletePhoto(p));
                                  });
                            }),
                      ],
                      if (_busy) const LinearProgressIndicator(),
                      if (selected != null)
                        Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: FilledButton.icon(
                                onPressed: _busy ? null : _upload,
                                icon: const Icon(
                                    Icons.add_photo_alternate_outlined),
                                label: Text(_vi ? 'Thêm ảnh' : 'Add photos'))),
                    ])));
  }

  Future<void> _preview(LibraryPhoto p) async {
    await showDialog<void>(
        context: context,
        builder: (ctx) => Dialog(
            child: FutureBuilder<Uint8List>(
                future: ref.read(libraryApiProvider).image(p.id),
                builder: (c, s) => s.connectionState == ConnectionState.waiting
                    ? const SizedBox(
                        height: 250,
                        child: Center(child: CircularProgressIndicator()))
                    : s.hasError
                        ? Center(child: Text('${s.error}'))
                        : InteractiveViewer(
                            minScale: .7,
                            maxScale: 5,
                            child:
                                Image.memory(s.data!, fit: BoxFit.contain)))));
  }
}

class _AlbumCoverCard extends StatelessWidget {
  const _AlbumCoverCard(
      {required this.album, required this.selected, required this.onTap});
  final LibraryAlbum album;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final cover = album.photos
            .where((photo) => photo.id == album.coverPhotoId)
            .firstOrNull ??
        album.photos.firstOrNull;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: SizedBox(
          width: 150,
          child: Material(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            clipBehavior: Clip.antiAlias,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(20),
                child: Stack(fit: StackFit.expand, children: [
                  if (cover?.url.isNotEmpty == true)
                    CachedNetworkImage(
                        imageUrl: cover!.url,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _fallback(context))
                  else
                    _fallback(context),
                  DecoratedBox(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: .78)
                      ]))),
                  Positioned(
                      left: 12,
                      right: 10,
                      bottom: 12,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(album.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800)),
                            Text(
                                '${album.photoCount} ${album.photoCount == 1 ? 'photo' : 'photos'}',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 11)),
                          ])),
                  if (selected)
                    Positioned.fill(
                        child: DecoratedBox(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: MyLifeDesign.amber, width: 3),
                                borderRadius: BorderRadius.circular(20)))),
                ])),
          )),
    );
  }

  Widget _fallback(BuildContext context) => Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(
          child: Icon(Icons.photo_outlined,
              size: 36, color: MyLifeDesign.violet)));
}

class _PhotoTile extends ConsumerWidget {
  const _PhotoTile(
      {required this.photo,
      required this.onTap,
      required this.onEdit,
      required this.onDelete});
  final LibraryPhoto photo;
  final VoidCallback onTap, onEdit, onDelete;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(fit: StackFit.expand, children: [
        InkWell(
            onTap: onTap,
            child: FutureBuilder<Uint8List>(
                future: ref.read(libraryApiProvider).image(photo.id),
                builder: (c, s) => s.connectionState == ConnectionState.waiting
                    ? const Center(child: CircularProgressIndicator())
                    : s.hasError
                        ? const Center(child: Icon(Icons.broken_image_outlined))
                        : Image.memory(s.data!, fit: BoxFit.cover))),
        Positioned(
            left: 6,
            right: 6,
            bottom: 6,
            child: DecoratedBox(
                decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .62),
                    borderRadius: BorderRadius.circular(8)),
                child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(photo.title ?? photo.fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12))))),
        Positioned(
            right: 0,
            top: 0,
            child: PopupMenuButton<String>(
                onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
                itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete'))
                    ]))
      ]));
}
