import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:countdown_flutter/countdown_flutter.dart';
import 'dart:async';
import 'package:flutter_device_locale/flutter_device_locale.dart';
import 'package:dio/dio.dart';
import 'package:device_apps/device_apps.dart';
import 'package:open_appstore/open_appstore.dart';
import 'dart:io' show Platform;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fortnite Daily Store',
      debugShowCheckedModeBanner: false,
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

  _openFortnite() async {
    if (Platform.isAndroid) {
      bool isInstalled =
          await DeviceApps.isAppInstalled('com.epicgames.fortnite');
      if (isInstalled != false) {
        DeviceApps.openApp('com.epicgames.fortnite');
      } else {
        OpenAppstore.launch(androidAppId: 'com.epicgames.fortnite');
      }
    }
  }

  Future<void> _getFutureDados() async {
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
    for (Map<String, dynamic> item in response.data['daily']) {
      itensLoja.add(ItemLoja.fromJson(item));
    }
    for (Map<String, dynamic> item in response.data['specialFeatured']) {
      itensLoja.add(ItemLoja.fromJson(item));
    }
    for (Map<String, dynamic> item in response.data['specialDaily']) {
      itensLoja.add(ItemLoja.fromJson(item));
    }
    for (Map<String, dynamic> item in response.data['community']) {
      itensLoja.add(ItemLoja.fromJson(item));
    }

    List<Widget> listImages = new List<Widget>();

    itensLoja.forEach((element) {
      final cachedImage = new CachedNetworkImage(
        placeholder: (context, url) => new CircularProgressIndicator(),
        imageUrl: element.fullBackground,
      );
      listImages.add(
        cachedImage,
      );
    });

    setState(() {
      list = listImages;
    });
  }

  var list = new List<Widget>();

  @override
  void initState() {
    super.initState();
    _getFutureDados();
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
      // No appbar provided to the Scaffold, only a body with a
      // CustomScrollView.
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
        child: CustomScrollView(
          slivers: <Widget>[
            // Add the app bar to the CustomScrollView.
            SliverAppBar(
              // Provide a standard title.
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Row(
                      children: <Widget>[
                        Tooltip(
                          message: "Próxima atualização de loja",
                          child: Image.asset(
                            'assets/delivery-box.png',
                            fit: BoxFit.contain,
                            height: 32,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Contador(
                            onFinishAction: _getFutureDados,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _openFortnite,
                    icon: Icon(Icons.subdirectory_arrow_right),
                  ),
                ],
              ),
              // Allows the user to reveal the app bar if they begin scrolling
              backgroundColor: Colors.transparent,
              elevation: 0,
              // back up the list of items.
              floating: false,
              // Display a placeholder widget to visualize the shrinking size.
              // Make the initial height of the SliverAppBar larger than normal.
            ),
            // Next, create a SliverList

            SliverGrid(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200.0,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return list[index];
                },
                childCount: list.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Contador extends StatelessWidget {
  final horas = new DateTime.now().toUtc().hour;
  final minutos = new DateTime.now().toUtc().minute;
  final segundos = new DateTime.now().toUtc().second;

  final onFinishAction;

  Contador({this.onFinishAction});

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
          onFinishAction();
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
