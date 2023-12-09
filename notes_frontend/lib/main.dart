import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:notes_frontend/create.dart';
import 'package:notes_frontend/note.dart';
import 'package:notes_frontend/update.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Django demo app'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Note> notes = [];
  final client = http.Client();
  final retrieveUrl = Uri.parse('http://127.0.0.1:8000/notes/');

  deleteUrl(int noteId) {
    const baseUrl = 'http://127.0.0.1:8000/notes/';
    return (Uri.parse('$baseUrl$noteId/delete/'));
  }

  @override
  void initState() {
    _retrieveNotes();
    super.initState();
  }

  _retrieveNotes() async {
    notes = [];
    List response = json.decode((await client.get(retrieveUrl)).body);
    response.forEach((element) {
      notes.add(Note.fromMap(element));
    });

    setState(() {});
  }

  void _deleteNote(int id) {
    client.delete(deleteUrl(id));
    _retrieveNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _retrieveNotes();
        },
        child: ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(notes[index].note),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (
                      context,
                    ) =>
                        UpdatePage(
                            client: client,
                            id: notes[index].id,
                            note: notes[index].note),
                  ),
                );
              },
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteNote(notes[index].id),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CreatePage(
              client: client,
            ),
          ),
        ),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
