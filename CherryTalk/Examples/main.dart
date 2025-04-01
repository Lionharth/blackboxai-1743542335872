import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

void main() async {
  runApp(const MatrixChatApp());
}

class MatrixChatApp extends StatelessWidget {
  const MatrixChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Matrix Chat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.latoTextTheme(),
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _homeserverController = TextEditingController(text: 'matrix.org');
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final client = Client(
        'Matrix Flutter Client',
        databaseBuilder: (client) => HiveCollectionsDatabase(client),
      );

      try {
        await client.checkHomeserver(_homeserverController.text);
        await client.login(
          LoginType.mLoginPassword,
          identifier: AuthenticationUserIdentifier(user: _usernameController.text),
          password: _passwordController.text,
        );
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ChatScreen(client: client)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blueAccent, Colors.purpleAccent],
          ),
        ),
        child: Center(
          child: GlassmorphicContainer(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 400,
            borderRadius: 20,
            blur: 20,
            alignment: Alignment.center,
            border: 2,
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
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const FaIcon(FontAwesomeIcons.comments, size: 50, color: Colors.white),
                    const SizedBox(height: 20),
                    Text(
                      'Matrix Chat',
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _homeserverController,
                      decoration: const InputDecoration(
                        labelText: 'Homeserver',
                        prefixIcon: Icon(Icons.dns, color: Colors.white70),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person, color: Colors.white70),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock, color: Colors.white70),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                      child: const Text('Login', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final Client client;

  const ChatScreen({super.key, required this.client});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  Room? _selectedRoom;

  Future<void> _sendMessage() async {
    if ((_messageController.text.isEmpty && _pendingAttachment == null) || 
        _selectedRoom == null) return;
    
    try {
      if (_pendingAttachment != null) {
        await _selectedRoom!.sendFile(
          _pendingAttachment!,
          name: _pendingAttachmentName,
          mimeType: _pendingMimeType,
        );
        setState(() {
          _pendingAttachment = null;
          _pendingAttachmentName = null;
          _pendingMimeType = null;
        });
      } else {
        await _selectedRoom!.sendTextMessage(_messageController.text);
        _messageController.clear();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: ${e.toString()}')),
      );
    }
  }

  Uint8List? _pendingAttachment;
  String? _pendingAttachmentName;
  String? _pendingMimeType;

  Future<void> _pickMedia() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _pendingAttachment = bytes;
        _pendingAttachmentName = pickedFile.name;
        _pendingMimeType = 'image/${pickedFile.path.split('.').last}';
      });
      _messageController.text = 'Sending ${pickedFile.name}...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedRoom?.getLocalizedDisplayname() ?? 'Rooms', 
          style: GoogleFonts.lato(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: GlassmorphicContainer(
          width: double.infinity,
          height: kToolbarHeight + MediaQuery.of(context).padding.top,
          borderRadius: 0,
          blur: 20,
          border: 0,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.2),
              Colors.white.withOpacity(0.05),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blueAccent, Colors.purpleAccent],
          ),
        ),
        child: _selectedRoom == null 
          ? _buildRoomList()
          : _buildChatInterface(),
      ),
    );
  }

  Widget _buildRoomList() {
    return StreamBuilder<List<Room>>(
      stream: widget.client.onSync.stream.map((sync) => widget.client.rooms),
      builder: (context, snapshot) {
        final rooms = snapshot.data ?? [];
        return ListView.builder(
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            final room = rooms[index];
            return GlassmorphicContainer(
              width: double.infinity,
              height: 80,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              child: ListTile(
                title: Text(
                  room.getLocalizedDisplayname(),
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  room.lastEvent?.body ?? 'No messages',
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                leading: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(
                    room.getLocalizedDisplayname().substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                onTap: () {
                  setState(() {
                    _selectedRoom = room;
                  });
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChatInterface() {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<Event>>(
            stream: _selectedRoom!.onUpdate.stream
                .map((_) => _selectedRoom!.timeline.events),
            builder: (context, snapshot) {
              final events = snapshot.data ?? [];
              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.only(bottom: 8),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return ChatBubble(
                    event: event,
                    isMe: event.senderId == widget.client.userID,
                    showAvatar: index == events.length - 1 || 
                      events[index + 1].senderId != event.senderId,
                  );
                },
              );
            },
          ),
        ),
        GlassmorphicContainer(
          width: double.infinity,
          height: 80,
          borderRadius: 0,
          blur: 20,
          border: 0,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.2),
              Colors.white.withOpacity(0.05),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.white),
                  onPressed: _pickMedia,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
