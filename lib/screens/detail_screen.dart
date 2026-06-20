import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post_model.dart';

class DetailScreen extends StatefulWidget {
  final Post post;
  const DetailScreen({super.key, required this.post});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _mobileLoaded = false;
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Scaffold(
      appBar: AppBar(title: const Text('Post')),
      body: Column(
        children: [
          Hero(
            tag: 'post_image_${post.id}',  // ← fixed to match PostCard
            child: SizedBox(
              height: 400,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: post.thumbUrl,
                    fit: BoxFit.cover,
                  ),
                  AnimatedOpacity(
                    opacity: _mobileLoaded ? 1 : 0,
                    duration: const Duration(milliseconds: 350),
                    child: CachedNetworkImage(
                      imageUrl: post.mobileUrl,
                      fit: BoxFit.cover,
                      imageBuilder: (context, imageProvider) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!_mobileLoaded && mounted) {
                            setState(() => _mobileLoaded = true);
                          }
                        });
                        return Image(image: imageProvider, fit: BoxFit.cover);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _isDownloading ? null : _downloadRaw,
            icon: _isDownloading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
            label: Text(_isDownloading ? 'Downloading...' : 'Download High-Res'),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadRaw() async {
    setState(() => _isDownloading = true);
    try {
      final response = await http.get(Uri.parse(widget.post.rawUrl));
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/${widget.post.id}_raw.jpg');
      await file.writeAsBytes(response.bodyBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved to ${file.path}')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download failed. Check connection.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }
}