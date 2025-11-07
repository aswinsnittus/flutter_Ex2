import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ASWIN SNITTU S Notes Taking App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const NotesHomePage(),
    );
  }
}

class NotesHomePage extends StatefulWidget {
  const NotesHomePage({super.key});
  @override
  State<NotesHomePage> createState() => _NotesHomePageState();
}

class _NotesHomePageState extends State<NotesHomePage> {
  final TextEditingController _controller = TextEditingController();
  // each note is a map with text and timestamp
  final List<Map<String, dynamic>> _notes = [
    {
      'text': 'Welcome note: Start typing below to add notes.',
      'time': DateTime.now().subtract(const Duration(minutes: 5))
    },
    {
      'text': 'Tip: Long-press a note to delete it.',
      'time': DateTime.now().subtract(const Duration(hours: 1, minutes: 12))
    }
  ];

  final DateFormat _fmt = DateFormat('dd MMM yyyy, hh:mm a');

  void _addNote() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some text to add a note')),
      );
      return;
    }
    setState(() {
      _notes.insert(0, {'text': text, 'time': DateTime.now()});
      _controller.clear();
    });
  }

  void _deleteNoteAt(int index) {
    final removed = _notes[index]['text'] as String;
    setState(() {
      _notes.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deleted: "$removed"'), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _confirmDelete(int index) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete note?'),
        content: Text('Delete this note:\n\n"${_notes[index]['text']}"'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (res == true) _deleteNoteAt(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ASWIN SNITTU S Notes Taking App'),
        centerTitle: true,
      ),
      backgroundColor: const Color.fromARGB(255, 240, 245, 255),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // input row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [BoxShadow(blurRadius: 3, color: Colors.black12)],
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Write a new note...',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _addNote(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(onPressed: _addNote, child: const Text('Add')),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 8),
            // Customized ListView using Card-based items (newest first)
            Expanded(
              child: _notes.isEmpty
                  ? const Center(child: Text('No notes yet. Add one above!'))
                  : ListView.separated(
                      itemCount: _notes.length,
                      separatorBuilder: (context, idx) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final note = _notes[index];
                        return GestureDetector(
                          onLongPress: () => _confirmDelete(index),
                          child: NoteListItem(
                            text: note['text'] as String,
                            time: _fmt.format(note['time'] as DateTime),
                            onDelete: () => _confirmDelete(index),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        tooltip: 'Add note',
        child: const Icon(Icons.note_add),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Customized list item widget (Card + layout) — uses Card styling approach from Exercise 2.
class NoteListItem extends StatelessWidget {
  final String text;
  final String time;
  final VoidCallback onDelete;

  const NoteListItem({super.key, required this.text, required this.time, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.grey, width: 0.5)),
      elevation: 1,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Left marker / icon
            Container(
              width: 8,
              height: 56,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: Colors.blueAccent),
            ),
            const SizedBox(width: 12),
            // Note content
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(time, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ]),
            ),
            // Delete button
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}
