import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: RandomWords(),
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
  final _saved = <WordPair>{};
  final _biggerFont = const TextStyle(fontSize: 18);
  final myController = TextEditingController();
  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }
  void _pushSaved() {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (BuildContext context) {
        final tiles = _saved.map(
              (WordPair pair) {
            String startupName;
            if (pair.second == ' ') {
              startupName = pair.asString;
            } else {
              startupName = pair.asPascalCase;
            }
            return ListTile(
              title: Text(
                startupName,
                style: _biggerFont,
              ),
            );
          },
        );
        final divided = tiles.isNotEmpty
            ? ListTile.divideTiles(context: context, tiles: tiles).toList()
            : <Widget>[];

        return Scaffold(
          appBar: AppBar(
            title: Text('Saved Suggestions'),
          ),
          body: ListView(children: divided),
        );
      },
    ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(
        title: Text('Startup Name Generator'),
        actions: [
          IconButton(icon: Icon(Icons.list), onPressed: _pushSaved),
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
            return Divider();
          }

          final int index = i ~/ 2;
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10));
          }
          return _buildRow(_suggestions[index], index);
        }
    );
  }

  Widget _buildRow(WordPair pair, index) {
    final alreadySaved = _saved.contains(pair);
    var startupName;
    if (pair.second == ' ') {
      startupName = pair.asString;
    } else {
      startupName = pair.asPascalCase;
    }

    return Dismissible(
        key: Key(pair.hashCode.toString()),
        onDismissed: (direction) {
          setState(() {
            _suggestions.removeAt(index);
            if (alreadySaved) {
              _saved.remove(pair);
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
                    _saved.remove(pair);
                  } else {
                    _saved.add(pair);
                  }
                });
              }
          ),

          onTap: () {
            myController.clear();
            Navigator.of(context).push(MaterialPageRoute<void>(
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
                      setState(() {
                        if (alreadySaved) {
                          _saved.remove(_suggestions[index]);
                        }
                        _suggestions[index] = WordPair(myController.text, ' ');
                        _saved.add(_suggestions[index]);
                      });
                      Navigator.pop(context);
                    },
                    tooltip: 'Save',
                    child: const Icon(Icons.check),
                  ),
                );
              },
            ),
            );
          },
        )
    );
  }
}
