import 'package:flutter/material.dart';
import 'package:room_calendar/schedule_view.dart';
import 'package:supabase/supabase.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Room Calendar',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(),
        useMaterial3: true,
      ),
      home: const Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final supabase = SupabaseClient(
    const String.fromEnvironment("SUPABASE_URL"),
    const String.fromEnvironment("SUPABASE_KEY"),
  );

  final searchController = TextEditingController();
  Future<dynamic> roomSearchFuture = Future.value(null);
  Future<dynamic> sectionsRequestFuture = Future.value([]);

  String formatRoom(String room) => room
      .toUpperCase()
      .replaceAll(RegExp(r"\s+"), "")
      .replaceAllMapped(RegExp(r'(?<!\d)(?=\d)'), (match) => ' ');

  @override
  void initState() {
    super.initState();

    searchController.addListener(() {
      setState(() {
        if (searchController.text.trim().isEmpty) {
          roomSearchFuture = Future.value(null);
          return;
        }
        roomSearchFuture = supabase.rpc("room_starts_with",
            params: {"room": formatRoom(searchController.text)});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Room Calendar"),
        scrolledUnderElevation: 0.0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                  hintText: "Enter a room code (e.g. S 113, S 305)",
                  suffixIcon: IconButton(
                      onPressed: () => searchController.clear(),
                      icon: const Icon(Icons.clear))),
            ),
          ),
          const Divider(),
          Expanded(
            child: FutureBuilder(
                future: roomSearchFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData) {
                    return const Center(
                        child: Text("No search has been performed"));
                  }
                  final rooms = List<Map<String, dynamic>>.from(snapshot.data!);
                  if (rooms.isEmpty) {
                    return const Center(child: Text("No rooms found"));
                  }
                  if (rooms.length == 1) {
                    sectionsRequestFuture = supabase.rpc("room_section",
                        params: {"room": formatRoom(searchController.text)});
                    return FutureBuilder(
                        future: sectionsRequestFuture,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          final sections =
                              List<Map<String, dynamic>>.from(snapshot.data!);
                          return ScheduleView(sections: sections);
                        });
                  }
                  return SingleChildScrollView(
                    child: Column(
                      children: rooms
                          .map((e) => Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                    onPressed: () {
                                      searchController.text = e["m_room"];
                                    },
                                    child: SizedBox(
                                        width: double.infinity,
                                        child:
                                            Center(child: Text(e["m_room"])))),
                              ))
                          .toList(),
                    ),
                  );
                }),
          )
        ],
      ),
    );
  }
}
