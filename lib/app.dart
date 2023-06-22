import 'package:firebase_barai/firebase_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _firebaseLocalUrlController = TextEditingController(text: 'localhost');
  final _firebaseProjectId = TextEditingController();
  final _firestoreLocalPortController = TextEditingController(text: '8080');

  FirebaseHelper? _firebaseHelper;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Firebase Barai'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: ListView(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _firebaseLocalUrlController,
                        decoration: const InputDecoration(
                            labelText: 'Firestore local URL'),
                      ),
                      TextField(
                        controller: _firestoreLocalPortController,
                        decoration: const InputDecoration(
                            labelText: 'Firestore local Port'),
                      ),
                      TextField(
                        controller: _firebaseProjectId,
                        decoration: const InputDecoration(
                            labelText: 'Firestore Project ID'),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            _firebaseHelper = FirebaseHelper(
                              firebaseHost: _firebaseLocalUrlController.text,
                              firebasePort: _firestoreLocalPortController.text,
                              firebaseProjectId: _firebaseProjectId.text,
                            );
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('OK')));
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ),
              ),
              if (_firebaseHelper != null) ...[
                const SizedBox(height: 16),
                CollectionCard(firebaseHelper: _firebaseHelper!),
              ],
            ],
          ),
        ));
  }
}

class CollectionCard extends StatefulWidget {
  const CollectionCard({super.key, required this.firebaseHelper});

  final FirebaseHelper firebaseHelper;

  @override
  State<CollectionCard> createState() => _CollectionCardState();
}

class _CollectionCardState extends State<CollectionCard> {
  final _firestoreCollectionName = TextEditingController();
  List<dynamic> _documents = [];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _firestoreCollectionName,
              decoration: const InputDecoration(labelText: 'Collection name'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: () async {
                  // TODO: do form validation
                  // get all collections
                  final collectionName = _firestoreCollectionName.text;

                  _documents = await widget.firebaseHelper
                      .getDocumentsByCollectionName(collectionName);
                  setState(() {});
                },
                child: const Text('List all documents')),
            if (_documents.isNotEmpty)
              ListView.builder(
                  itemCount: _documents.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final doc = _documents[index];
                    // final docName = doc['name']?.split('/').last;
                    final docName = doc['name'].toString();
                    // final docName = doc.containsKey('name').toString();
                    return ListTile(
                      title: Text(docName),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(
                            onPressed: () {
                              // copy the id
                              final docId = doc['name'];
                              Clipboard.setData(ClipboardData(text: docId));
                            },
                            tooltip: 'Copy ID',
                            icon: const Icon(Icons.copy)),
                        IconButton(
                            onPressed: () async {
                              var id = await showDialog(
                                  context: context,
                                  builder: (_) {
                                    return _DuplicateDialog();
                                  });

                              if (id == null) return;
                              final collectionName =
                                  _firestoreCollectionName.text;

                              final doc =
                                  Map.from(_documents[index]); //object clone
                              doc.remove('name');
                              var res = await widget.firebaseHelper.addDocument(
                                  collectionName: collectionName,
                                  fields: doc,
                                  id: id);

                              setState(() {
                                _documents.add(res);
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Document added at ${res['name']}')));
                            },
                            tooltip: 'Duplicate document',
                            icon: const Icon(Icons.copy_all)),
                      ]),
                    );
                  })
          ],
        ),
      ),
    );
  }
}

class _DuplicateDialog extends StatelessWidget {
  _DuplicateDialog({Key? key}) : super(key: key);
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Duplicate document'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
                labelText: 'ID (Leave blank to generate new ID)'),
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_controller.text);
          },
          child: const Text('Duplicate'),
        ),
      ],
    );
  }
}
