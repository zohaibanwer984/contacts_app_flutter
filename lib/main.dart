import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String searchText = '';
  List<Contact> _userContactsList = [];

  Future<void> _fetchContacts() async {
    var contacts = await ContactsService.getContacts();
    setState(() {
      _userContactsList = contacts;
    });
  }

  Future<void> _requestContact() async {
    var status = await Permission.contacts.status;

    if (status.isDenied || status.isPermanentlyDenied) {
      PermissionStatus perStatus = await Permission.contacts.request();
      if (perStatus.isGranted) {
        _fetchContacts();
      } else if (perStatus.isDenied) {
        return;
      } else if (perStatus.isPermanentlyDenied) {
        return;
      }
    } else if (status.isGranted) {
      _fetchContacts();
    }
  }

  List<Contact> _filterByName() {
    return _userContactsList.where((Contact c) {
      return c.displayName!.toLowerCase().contains(searchText.toLowerCase());
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _requestContact();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 0, 136, 11),
          brightness: Brightness.dark,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("MY CONTACTS"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: SearchBar(
                  leading: Icon(Icons.search),
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _filterByName().length,
                  itemBuilder: (context, index) {
                    Contact contact = _filterByName()[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 30,
                          child: Text(
                            "${contact.displayName?.substring(0, 1)}",
                            style: TextStyle(fontSize: 25),
                          ),
                        ),
                        title: Text("${contact.displayName}"),
                        subtitle: Text("${contact.phones?.single.value}"),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
