import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:camera/camera.dart';

late List<CameraDescription> cameras;
Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print(e.code + " " + e.description.toString());
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'locket_flutter',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          color: Colors.purple.shade200,
        ),
        primarySwatch: Colors.purple,
        primaryColor: Colors.purple.shade200,
      ),
      home: const MyHomePage(title: 'locket_flutter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int id = 1;
  String ftp = "";
  int partnerID = 0;
  late CameraController controller;

  @override
  void initState() {
    super.initState();
    getID();
    getPartnerID();
    getFTP();
    controller = CameraController(cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void getID() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      id = (prefs.getInt('id') ?? Random().nextInt(8888) + 1111);
    });
  }

  void getPartnerID() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      partnerID = (prefs.getInt('partnerID') ?? Random().nextInt(8888) + 1111);
    });
  }

  void getFTP() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      ftp = prefs.getString('ftp') ?? "";
    });
  }

  void setPrefsInt(String key, int a) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, a);
  }

  void setPrefsString(String key, String a) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, a);
  }

  void _openSettings() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext builder) {
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        Widget settings = Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
              child: TextFormField(
                initialValue: ftp,
                onFieldSubmitted: (value) {
                  setPrefsString('ftp', value);
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter your FTP Server address',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
              child: TextFormField(
                initialValue: partnerID.toString(),
                onFieldSubmitted: (value) {
                  setPrefsInt('partnerID', int.parse(value));
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Enter your Partner's ID",
                ),
              ),
            ),
            Center(
              child: Text("Your ID is " + id.toString()),
            ),
            Center(
                child: ElevatedButton(
              onPressed: () {
                setState(() {
                  id = Random().nextInt(8888) + 1111;
                });
                setPrefsInt('id', id);
              },
              child: const Text("Generate ID"),
            )),
          ],
        );
        return Scaffold(
          appBar: AppBar(title: const Text("Settings")),
          body: settings,
        );
      });
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(onPressed: _openSettings, icon: const Icon(Icons.settings))
        ],
        title: Text(widget.title),
      ),
      body: Center(child: CameraPreview(controller)),
    );
  }
}
