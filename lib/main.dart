import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(SkillSearchApp());

class SkillSearchApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SkillSearchPage(),
    );
  }
}

class SkillSearchPage extends StatefulWidget {
  @override
  _SkillSearchPageState createState() => _SkillSearchPageState();
}

class _SkillSearchPageState extends State<SkillSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List skills = [];
  String errorMessage = '';
  bool isLoading = false;

  Future<void> searchSkills(String keyword) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final url = Uri.parse('http://mobileproject2.atwebpages.com/index.php');

    try {
      final response = await http.post(
        url,
        body: {'action': 'searchSkill', 'keyword': keyword},
      );

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);

          if (data is List) {
            setState(() {
              skills = data;
              errorMessage = '';
            });
          } else {
            setState(() {
              skills = [];
              errorMessage = 'Unexpected response format.';
            });
          }
        } catch (e) {
          setState(() {
            skills = [];
            errorMessage = 'Failed to parse server response.';
          });
        }
      } else if (response.statusCode == 404) {
        setState(() {
          skills = [];
          errorMessage = 'Not found. Please check your search term.';
        });
      } else if (response.statusCode == 500) {
        setState(() {
          skills = [];
          errorMessage = 'Server error. Please try again later.';
        });
      } else {
        setState(() {
          skills = [];
          errorMessage = 'Error: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        skills = [];
        if (e is http.ClientException) {
          errorMessage = 'Network error. Please check your connection.';
        } else {
          errorMessage = 'Failed to connect to the server.';
        }
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Skill Search'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Skills',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                final keyword = _searchController.text.trim();
                if (keyword.isNotEmpty) {
                  searchSkills(keyword);
                } else {
                  setState(() {
                    errorMessage = 'Please enter a search term.';
                  });
                }
              },
              child: Text('Search'),
            ),
            SizedBox(height: 20),
            if (isLoading)
              Center(child: CircularProgressIndicator()),
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            Expanded(
              child: skills.isEmpty
                  ? Center(
                child: Text('No skills found. Try a different search.'),
              )
                  : ListView.builder(
                itemCount: skills.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.label),
                      title: Text(skills[index]['skill_name'] ?? 'Unknown Skill'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
