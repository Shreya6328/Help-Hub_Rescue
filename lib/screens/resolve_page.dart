import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResolvePage extends StatefulWidget {
  final int alertId;
  const ResolvePage({super.key, required this.alertId});

  @override
  State<ResolvePage> createState() => _ResolvePageState();
}

class _ResolvePageState extends State<ResolvePage> {
  final picker = ImagePicker();
  final supabase = Supabase.instance.client;

  List<File> images = [];
  bool loading = false;

  Future<void> pickImage() async {
    if (images.length >= 4) return;

    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => images.add(File(picked.path)));
    }
  }

  Future<void> submitResolution() async {
    if (images.isEmpty) return;

    setState(() => loading = true);

    try {
      List<String> imageUrls = [];

      for (int i = 0; i < images.length; i++) {
        final file = images[i];
        final path =
            'proofs/alert_${widget.alertId}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';

        await supabase.storage
            .from('sos_proofs')
            .upload(path, file, fileOptions: const FileOptions(upsert: true));

        final url = supabase.storage.from('sos_proofs').getPublicUrl(path);
        imageUrls.add(url);
      }

      await supabase.from('sos_alerts').update({
        'status': 'awaiting_user_confirmation',
        'resolved_photos': imageUrls,
        'resolved_at': DateTime.now().toIso8601String(),
      }).eq('id', widget.alertId);

      Navigator.popUntil(context, (r) => r.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Resolve Alert"),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: images
                  .map((img) => Image.file(img, height: 100, width: 100))
                  .toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: images.length >= 4 ? null : pickImage,
              child: Text("Upload Photo (${images.length}/4)"),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: images.isEmpty || loading ? null : submitResolution,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Mark as Completed"),
            ),
          ],
        ),
      ),
    );
  }
}
