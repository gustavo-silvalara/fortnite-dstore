import 'package:flutter/material.dart';
import 'package:countdown_flutter/countdown_flutter.dart';
import 'dart:async';
import 'package:flutter_device_locale/flutter_device_locale.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: Contador()),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final Widget title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // int _counter = 0;

  // void _incrementCounter() {
  //   setState(() {
  //     // This call to setState tells the Flutter framework that something has
  //     // changed in this State, which causes it to rerun the build method below
  //     // so that the display can reflect the updated values. If we changed
  //     // _counter without calling setState(), then the build method would not be
  //     // called again, and so nothing would appear to happen.
  //     _counter++;
  //   });
  // }

  Future<Widget> getFutureDados() async {
    Locale locale = await DeviceLocale.getCurrentLocale();

    Uri url = Uri.parse('https://fortniteapi.io/shop?lang=' +
        ((locale.languageCode) == 'pt' ? 'pt-BR' : locale.languageCode));

    Response response = await Dio().request(url.toString(),
        options: Options(
            headers: {'Authorization': '645726c3-21a7bd9e-a8d44bae-5ddb9b37'}));

    List<ItemLoja> itensLoja = List<ItemLoja>();
    for (Map<String, dynamic> item in response.data['featured']) {
      itensLoja.add(ItemLoja.fromJson(item));
    }

    List<Widget> listImages = new List<Widget>();

    itensLoja.forEach((element) {
      listImages.add(
        Image.network(element.fullBackground),
      );
    });
    return GridView.count(
      crossAxisCount: 2,
      children: listImages,
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        elevation: 0.0,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              'assets/delivery-box.png',
              fit: BoxFit.contain,
              height: 32,
            ),
            Container(padding: const EdgeInsets.all(8.0), child: Contador())
          ],
        ),
        backgroundColor: Color(0xFF1E8AF4),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1E8AF4),
              const Color(0xFF001E6D)
            ], // whitish to gray
            tileMode: TileMode.repeated,
          ),
        ), // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: FutureBuilder(
            future: getFutureDados(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return snapshot.data;
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      ),
    );
  }
}

class Contador extends StatelessWidget {
  final horas = new DateTime.now().toUtc().hour;
  final minutos = new DateTime.now().toUtc().minute;
  final segundos = new DateTime.now().toUtc().second;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CountdownFormatted(
        duration: Duration(
          hours: 23 - horas,
          minutes: 59 - minutos,
          seconds: 60 - segundos,
        ),
        onFinish: () {
          print('finished!');
        },
        builder: (BuildContext ctx, String remaining) {
          return Text(remaining); // 01:00:00
        },
      ),
    );
  }
}

class ItemLoja {
  final String id;
  final String name;
  final String description;
  final String fullBackground;

  ItemLoja({this.id, this.name, this.description, this.fullBackground});

  ItemLoja.fromJson(Map<String, dynamic> jsonData)
      : id = jsonData['id'],
        name = jsonData['name'],
        description = jsonData['description'],
        fullBackground = jsonData['full_background'];
}
