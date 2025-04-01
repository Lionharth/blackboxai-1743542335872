import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MediaAttachment extends StatelessWidget {
  final Event event;
  final bool isMe;

  const MediaAttachment({
    super.key,
    required this.event,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final content = event.content;
    final mimeType = content.tryGet<String>('info.mimetype') ?? '';
    final thumbnailUrl = content.tryGet<String>('info.thumbnail_url') ?? '';
    final fileUrl = content.tryGet<String>('url') ?? '';

    return GlassmorphicContainer(
      width: 250,
      height: 200,
      borderRadius: 20,
      blur: 20,
      border: 1,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.2),
          Colors.white.withOpacity(0.05),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.5),
          Colors.white.withOpacity(0.2),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: mimeType.startsWith('image/')
            ? CachedNetworkImage(
                imageUrl: thumbnailUrl.isNotEmpty ? thumbnailUrl : fileUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              )
            : const Center(
                child: Icon(Icons.insert_drive_file, size: 50, color: Colors.white),
              ),
      ),
    );
  }
}