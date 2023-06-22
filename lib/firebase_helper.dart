import 'dart:convert';

import 'package:http/http.dart' as http;

class FirebaseHelper {
  final String firebaseHost;
  final String firebasePort;
  final String firebaseProjectId;

  FirebaseHelper({
    required this.firebaseHost,
    required this.firebasePort,
    required this.firebaseProjectId,
  });

  Future<List<dynamic>> getDocumentsByCollectionName(
      String? collectionName) async {
    final baseUrl =
        'http://$firebaseHost:$firebasePort/v1/projects/$firebaseProjectId/databases/(default)/documents/$collectionName';

    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (!jsonResponse.containsKey('documents')) return [];
      final documents = jsonResponse['documents'];

      return documents;
    } else {
      throw Exception(
          'Failed to retrieve collections. Error: ${response.statusCode}');
    }
  }

  /// Add a document to a collection.
  Future<dynamic> addDocument(
      {String? collectionName, dynamic fields, String? id}) async {
    var baseUrl =
        'http://$firebaseHost:$firebasePort/v1/projects/$firebaseProjectId/databases/(default)/documents/$collectionName';

    if (id != null && id.isNotEmpty) baseUrl = '$baseUrl?documentId=$id';

    final response = await http.post(
        Uri.parse(
          baseUrl,
        ),
        body: jsonEncode(fields),
        headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Failed to retrieve collections. Error: ${response.statusCode}');
    }
  }
}
