import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'locker_utils.dart';

const kBgP = Color(0xFF000000);
const kCardP = Color(0xFF1A1A1A);
const kCard2P = Color(0xFF262626);
const kRedP = Color(0xFFE63946);
const kTextWhiteP = Color(0xFFFFFFFF);
const kTextGreyP = Color(0xFF9B9B9B);

class PhotoLockerScreen extends StatefulWidget {
  const PhotoLockerScreen({super.key});
  @override
  State<PhotoLockerScreen> createState() => _PhotoLockerScreenState();
}

class _PhotoLockerScreenState extends State<PhotoLockerScreen> {
  List<Map<String, String>> _photos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final photos = await LockerUtils.getPhotos();
    if (!mounted) return;
    setState(() {
      _photos = photos;
      _loading = false;
    });
  }

  Future<void> _pickPhoto() async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: ImageSource.gallery);
      if (file == null) return;

      await LockerUtils.hidePhoto(file.path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo hide ho gayi!',
                style: GoogleFonts.poppins()),
            backgroundColor: const Color(0xFF00D09C),
          ),
        );
      }
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: GoogleFonts.poppins()),
            backgroundColor: kRedP,
          ),
        );
      }
    }
  }

  Future<void> _deletePhoto(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCardP,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Photo?',
            style: GoogleFonts.poppins(
                color: kTextWhiteP, fontWeight: FontWeight.bold)),
        content: Text('Yeh photo permanently delete ho jayegi.',
            style: GoogleFonts.poppins(color: kTextGreyP)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: kTextGreyP)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kRedP),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete',
                style: GoogleFonts.poppins(color: kTextWhiteP)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await LockerUtils.deletePhoto(_photos[index]['path']!);
      _load();
    }
  }

  void _viewPhoto(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PhotoViewerScreen(
          path: _photos[index]['path']!,
          onDelete: () {
            _deletePhoto(index);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgP,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kRedP))
          : _photos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library_outlined,
                          size: 80, color: kCard2P),
                      const SizedBox(height: 16),
                      Text('Koi hidden photo nahi',
                          style: GoogleFonts.poppins(
                              fontSize: 16, color: kTextGreyP)),
                      const SizedBox(height: 8),
                      Text('+ dabao photo hide karne ke liye',
                          style: GoogleFonts.poppins(
                              fontSize: 13, color: kTextGreyP)),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _photos.length,
                  itemBuilder: (ctx, i) {
                    return GestureDetector(
                      onTap: () => _viewPhoto(i),
                      onLongPress: () => _deletePhoto(i),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_photos[i]['path']!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: kCard2P,
                            child: const Icon(Icons.broken_image,
                                color: kTextGreyP),
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kRedP,
        onPressed: _pickPhoto,
        icon: const Icon(Icons.add_photo_alternate, color: kTextWhiteP),
        label: Text('Add Photo',
            style: GoogleFonts.poppins(
                color: kTextWhiteP, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ═══════ PHOTO VIEWER ═══════
class _PhotoViewerScreen extends StatelessWidget {
  final String path;
  final VoidCallback onDelete;
  const _PhotoViewerScreen({required this.path, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: kTextWhiteP),
        actions: [
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete, color: kRedP),
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.file(
            File(path),
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.broken_image,
              color: kTextGreyP,
              size: 60,
            ),
          ),
        ),
      ),
    );
  }
}
