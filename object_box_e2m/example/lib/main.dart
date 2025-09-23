import 'package:example/database/dao/book_dao.dart';
import 'package:example/database/database.dart';
import 'package:example/models/book_model.dart';
import 'package:flutter/material.dart';
import 'package:object_box_e2m/object_box_e2m.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Database.initialize();
  runApp(const BookApp());
}

class BookApp extends StatelessWidget {
  const BookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book List',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const BookListPage(),
    );
  }
}

class BookListPage extends StatefulWidget {
  const BookListPage({super.key});

  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  final TextEditingController _controller = TextEditingController();
  BookDao dao = BookDao();

  void _addBook() {
    String bookName = _controller.text.trim();
    if (bookName.isNotEmpty) {
      BookModel model = BookModel(id: 0, name: bookName);
      dao.upsert(model);
      _controller.clear();
    }
  }

  void _deleteBook(BookModel model) {
    dao.delete(model.id);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Book List")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: "Enter book name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(onPressed: _addBook, child: const Text("Save")),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<ModelStream<List<BookModel>>>(
                future: dao.getAllWatcher(),
                builder: (context, streamSnapshot) {
                  if (streamSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(
                      child: SizedBox.square(
                        dimension: 30,
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    );
                  }
                  return StreamBuilder(
                    stream: streamSnapshot.data,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: SizedBox.square(
                            dimension: 30,
                            child: CircularProgressIndicator.adaptive(),
                          ),
                        );
                      }
                      if (!snapshot.hasData) {
                        return SizedBox.shrink();
                      }
                      if (!snapshot.data!.hasData) {
                        return SizedBox.shrink();
                      }
                      final bookList = snapshot.data?.data ?? [];
                      return bookList.isEmpty
                          ? const Center(child: Text("No books added yet."))
                          : ListView.builder(
                              itemCount: snapshot.data?.data.length ?? 0,
                              itemBuilder: (context, index) {
                                return Card(
                                  child: ListTile(
                                    title: Text(bookList[index].name),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () =>
                                          _deleteBook(bookList[index]),
                                    ),
                                  ),
                                );
                              },
                            );
                    },
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
