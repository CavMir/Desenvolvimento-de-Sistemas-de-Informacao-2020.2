import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: const RandomWords(),
    );
  }
}

class RandomWords extends StatefulWidget {
  const RandomWords({Key? key}) : super(key: key);
  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  var _saved = <String>[];
  final _biggerFont = const TextStyle(fontSize: 18);
  final myController = TextEditingController();
  CollectionReference<Map<String, dynamic>> get savedBandNames =>
      FirebaseFirestore.instance.collection('Saved Band Names');
  DocumentReference<Map<String, dynamic>> get docRef =>
      savedBandNames.doc('TrDMfZ0lg1Dhcw8Rqwug');

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  void _pushSaved() async {
    DocumentSnapshot docSnap = await docRef.get();
    _saved = docSnap.get('savedBandNames').cast<String>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          final tiles = _saved.map(
            (startupName) {
              return Dismissible(
                  key: Key(startupName.hashCode.toString()),
                  onDismissed: (direction) {
                    _removeSaved(startupName, context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('$startupName removed from saved')));
                  },
                  background: Container(color: Colors.red),
                  child: ListTile(
                    title: Text(
                      startupName,
                      style: _biggerFont,
                    ),
                    onTap: () {
                      _changeSavedName(startupName);
                    }
                  ));
            },
          );
          final divided = tiles.isNotEmpty
              ? ListTile.divideTiles(context: context, tiles: tiles).toList()
              : <Widget>[];
          return Scaffold(
            appBar: AppBar(
              title: const Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }

  void _removeSaved(String startupName, BuildContext context) async {
    DocumentSnapshot docSnap = await docRef.get();
    _saved = docSnap.get('savedBandNames').cast<String>();
    setState(() {
      _saved.remove(startupName);
    });
    await docRef.set(
      {'savedBandNames': _saved},
      SetOptions(merge: true),
    );
    setState(() {});
  }

  void _addSaved(String startupName, index, BuildContext context) async {
    DocumentSnapshot docSnap = await docRef.get();
    _saved = docSnap.get('savedBandNames').cast<String>();
    if (!_saved.contains(startupName.trim())) {
      setState(() {
        _saved.add(startupName.trim());
      });
    } else {
      setState(() {
        _suggestions.removeAt(index);
      });
    }
      await docRef.set(
        {'savedBandNames': _saved},
        SetOptions(merge: true),
      );
      setState(() {});
  }

  void _changeName(bool alreadySaved, index) {
    myController.clear();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Edit Startup Name'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  hintText: 'Enter new Startup Name',
                ),
                controller: myController,
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                _saveChanges(alreadySaved, index, context);
              },
              tooltip: 'Save',
              child: const Icon(Icons.check),
            ),
          );
        },
      ),
    );
  }

  void _saveChanges(bool alreadySaved, index, BuildContext context) async {
    if (alreadySaved) {
        String oldName;
        if (_suggestions[index].second == ' ') {
          oldName = _suggestions[index].first;
        } else {
          oldName = _suggestions[index].asPascalCase;
        }
        DocumentSnapshot docSnap = await docRef.get();
        _saved = docSnap.get('savedBandNames').cast<String>();
        setState(() {
          _saved.remove(oldName);
          if (!_saved.contains(myController.text.trim())) {
            _suggestions[index] = WordPair(myController.text, ' ');
            _saved.add(_suggestions[index].asString.trim());
          } else {
            _suggestions.removeAt(index);
          }
        });
        await docRef.set(
          {'savedBandNames': _saved},
          SetOptions(merge: true),
        );
        setState(() {});
    } else {
      setState(() {
        _suggestions[index] = WordPair(myController.text, ' ');
        _addSaved(_suggestions[index].asString, index, context);
      });
    }
    Navigator.pop(context);
  }

  void _changeSavedName(String startupName) {
      myController.clear();
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Edit Startup Name'),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: 'Enter new Startup Name',
                  ),
                  controller: myController,
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  _saveChangesToSaved(startupName, context);
                },
                tooltip: 'Save',
                child: const Icon(Icons.check),
              ),
            );
          },
        ),
      );
    }

  void _saveChangesToSaved(String startupName, BuildContext context) async {
      DocumentSnapshot docSnap = await docRef.get();
      _saved = docSnap.get('savedBandNames').cast<String>();
      setState(() {
        _saved.remove(startupName);
        if (!_saved.contains(myController.text.trim())) {
          _saved.add(myController.text.trim());
        }
      });
      await docRef.set(
        {'savedBandNames': _saved},
        SetOptions(merge: true),
      );
      setState(() {});
      Navigator.pop(context);
      Navigator.pop(context);
      _pushSaved();
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Startup Name Generator'),
        actions: [
          IconButton(icon: const Icon(Icons.list), onPressed: _pushSaved),
        ],
      ),
      body: _buildSuggestions(),
    );
  }

  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemBuilder: (BuildContext _context, int i) {
          if (i.isOdd) {
            return const Divider();
          }
          final int index = i ~/ 2;
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10));
          }
          return _buildRow(_suggestions[index], index);
        });
  }

  Widget _buildRow(WordPair pair, index) {
    String startupName;
    if (pair.second == ' ') {
      startupName = pair.first;
    } else {
      startupName = pair.asPascalCase;
    }
    final alreadySaved = _saved.contains(startupName.trim());
    return Dismissible(
        key: Key(pair.hashCode.toString()),
        onDismissed: (direction) {
          setState(() {
            _suggestions.removeAt(index);
            if (alreadySaved) {
              _removeSaved(startupName, context);
            }
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('$pair dismissed')));
        },
        background: Container(color: Colors.red),
        child: ListTile(
          title: Text(
            startupName,
            style: _biggerFont,
          ),
          trailing: IconButton(
              icon: Icon(alreadySaved ? Icons.favorite : Icons.favorite_border),
              color: alreadySaved ? Colors.red : null,
              onPressed: () {
                setState(() {
                  if (alreadySaved) {
                    _removeSaved(startupName, context);
                  } else {
                    _addSaved(startupName, index, context);
                  }
                });
              }),
          onTap: () {
            _changeName(alreadySaved, index);
          },
        ));
  }
}
