import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

// ✅ Import normal - on ne l'utilisera que sur mobile
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImagePickerUploader extends StatefulWidget {
  final Function(String) onImageUploaded;
  const ImagePickerUploader({super.key, required this.onImageUploaded});

  @override
  State<ImagePickerUploader> createState() => _ImagePickerUploaderState();
}

class _ImagePickerUploaderState extends State<ImagePickerUploader> {
  String? imageUrl;
  bool isUploading = false;

  Future<Uint8List> _compressImage(XFile picked) async {
    // ✅ Sur Web : pas de compression
    if (kIsWeb) {
      return await picked.readAsBytes();
    }

    // ✅ Sur mobile : compression
    try {
      final compressed = await FlutterImageCompress.compressWithFile(
        picked.path,
        quality: 70,
        minWidth: 800,
        minHeight: 800,
      );
      return compressed ?? await picked.readAsBytes();
    } catch (e) {
      debugPrint('Erreur compression : $e');
      return await picked.readAsBytes();
    }
  }

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    setState(() => isUploading = true);

    try {
      // ✅ Compression conditionnelle
      final imageBytes = await _compressImage(picked);

      // Upload Firebase Storage
      final fileName =
          'veggies/${DateTime.now().millisecondsSinceEpoch}_${picked.name}';
      final ref = FirebaseStorage.instance.ref().child(fileName);
      
      await ref.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final url = await ref.getDownloadURL();

      setState(() {
        imageUrl = url;
        isUploading = false;
      });

      widget.onImageUploaded(url);
      
    } on FirebaseException catch (e) {
      debugPrint('Erreur Firebase upload : ${e.code} - ${e.message}');
      setState(() => isUploading = false);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur upload : ${e.message}')),
        );
      }
    } catch (e) {
      debugPrint('Erreur générale upload : $e');
      setState(() => isUploading = false);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur pendant l\'upload')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: isUploading ? null : pickAndUploadImage,
          icon: const Icon(Icons.upload),
          label: Text(isUploading ? 'Chargement...' : 'Choisir une image'),
        ),
        if (isUploading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
        if (imageUrl != null) ...[
          const SizedBox(height: 16),
          Image.network(imageUrl!, height: 200),
        ],
      ],
    );
  }
}