import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import 'media_attachment.dart';

class ChatBubble extends StatelessWidget {
  final Event event;
  final bool isMe;
  final bool showAvatar;

  const ChatBubble({
    super.key,
    required this.event,
    this.isMe = false,
    this.showAvatar = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final messageColor = isMe 
        ? Colors.blue.withOpacity(0.2)
        : Colors.white.withOpacity(0.2);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe && showAvatar)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.1),
                child: Text(
                  event.senderId.substring(1, 2).toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe && showAvatar)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      event.senderId,
                      style: GoogleFonts.lato(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ),
                GlassmorphicContainer(
                  width: double.infinity,
                  borderRadius: 40, // Increased for a more rounded effect
                  blur: 50, // Increased blur for a glass-like appearance
                  alignment: Alignment.center,
                  border: 1,
                  linearGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      messageColor,
                      messageColor.withOpacity(0.1), // Adjusted for transparency
                    ],
                  ),
                  borderGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.5),
                      Colors.white.withOpacity(0.3), // Adjusted for a softer border
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (event.messageType == MessageTypes.Image || 
                            event.messageType == MessageTypes.File)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: MediaAttachment(event: event, isMe: isMe),
                          ),
                        Text(
                          event.body,
                          style: GoogleFonts.lato(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event.originServerTs.toLocal().toString().substring(11, 16),
                          style: GoogleFonts.lato(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
