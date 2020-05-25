import 'package:flutter/material.dart';
import 'dart:developer';
import 'dart:convert';
import 'package:splashscreen/splashscreen.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(MaterialApp(
  home: new MyApp(),
));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}
// AQUI VA LO DEL SPLASHSCREEN
class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
      image: Image.network(
        "https://i.pinimg.com/originals/a8/de/42/a8de4245126ceb6be68973079eff5b64.png", // URL DE LA IMAGEN
      ),
      photoSize: 200.0, //TAMAÑO DE LA IMAGEN
      seconds: 10, //SEGUNDOS DEL SPLASHSCREEN
      backgroundColor: Colors.grey, //COLOR DEL FONDO
      title: new Text(
        'Cargando...',
        style: new TextStyle(
            fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black),
      ),
      navigateAfterSeconds: new AfterSplash(),
    );
  }
}

class AfterSplash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
// TODO: implement build
    return MaterialApp(
      theme:
      ThemeData(brightness: Brightness.light, primarySwatch: Colors.red),
      darkTheme: ThemeData(
          brightness: Brightness.dark, primarySwatch: Colors.blueGrey),
      home: homePage(),
    );
  }
}

class homePage extends StatefulWidget {
  @override
  _myHomePageState createState() => new _myHomePageState();
}

class _myHomePageState extends State<homePage> {
  //Metodo Asincrono para leer JSON
  Future<String> _loadAsset() async {
    return await rootBundle.loadString('json_assets/marvel.json');
  }

  Future<List<heroes>> _getHeroes() async {
    String jsonString = await _loadAsset();
    var jsonData = json.decode(jsonString);
    print(jsonData.toString());

    List<heroes> heros = [];
    for (var h in jsonData) {
      heroes he = heroes(h["img"], h["nombre"], h["identidad"], h["edad"],
          h["altura"], h["genero"], h["descripcion"]);
      heros.add(he);
    }
    print("Numero de elementos");
    print(heros.length);
    return heros;
  }


  AudioPlayer audioPlayer;
  AudioCache audioCache;

  final audioname = "ironman.mp3";

  @override
  void initState() {
    super.initState();

    audioPlayer = AudioPlayer();
    audioCache = AudioCache();

    setState(() {
      audioCache.play(audioname);
    });
  }

  String searchbusqueda = "";
  bool _isSearching = false;
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        centerTitle: true,
        title: _isSearching
            ? TextField(
          onChanged: (value) {
            setState(() {
              searchbusqueda = value;
            });
          },
          controller: searchController,
        )
            : Text("VENGADORES"),
        actions: <Widget>[
          !_isSearching
              ? IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              setState(() {
                searchbusqueda = "";
                this._isSearching = !this._isSearching;
              });
            },
          )
              : IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              setState(() {
                this._isSearching = !this._isSearching;
              });
            },
          )
        ],
      ),
      body: Container(
        child: FutureBuilder(
          future: _getHeroes(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return Container(
                child: Center(
                  child: Text("Cargando...."),
                ),
              );
            } else {
              return ListView.builder(
                  scrollDirection: Axis.vertical, //ROTACION
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return snapshot.data[index].nombre.contains(searchbusqueda) //Realiza la busqueda
                        ? ListTile(
                      leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            snapshot.data[index].img
                                .toString(), //Linea de la imagen
                          )),
                      title: new Text(
                        snapshot.data[index].nombre.toString(),
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    Detail(snapshot.data[index])));
                      },
                    )
                        : Container();
                  });
            }
          },
        ),
      ),
    );
  }
}

class heroes {
  final String img;
  final String nombre;
  final String identidad;
  final String edad;
  final String altura;
  final String genero;
  final String descripcion;

  heroes(this.img, this.nombre, this.identidad, this.edad, this.altura,
      this.genero, this.descripcion);
}


class Detail extends StatelessWidget {
  final heroes hero;

  Detail(this.hero);
  //Declara  campo que contenga la clase

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(hero.nombre),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Stack(
        children: <Widget>[
          Positioned(
            top: MediaQuery
                .of(context)
                .size
                .height * 0.15,
            width: MediaQuery
                .of(context)
                .size
                .width - 12,
            left: 5.0,
            height: MediaQuery
                .of(context)
                .size
                .height / 1.4,
            child: Container(
              child: SingleChildScrollView(
                // ENCIERRA TODA LA CARTA, HACE QUE SE MUEVA LA TARJETA
                child: Card(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      new Padding(padding: EdgeInsets.all(10.0)),
                      SizedBox(
                        height: 30.0,
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Hero(
                            tag: hero.img,
                            child: Container(
                              height: 200.0, //TAMAÑO DE LA IMAGEN DEL SUPERHEROE
                              width: 200.0,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(hero.img),
                                ),
                              ),
                            )),
                      ),
                      new Padding(padding: EdgeInsets.all(20.0)),
                      new Text(
                          "Nombre:  ${hero.nombre}",
                          style: TextStyle(
                              fontSize: 25.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.red)),
                      new Padding(padding: EdgeInsets.all(10.0)),
                      new Text(
                          "Identidad Secreta:  ${hero.identidad} ",style: TextStyle(fontSize: 10.0,
                          fontWeight: FontWeight.bold)),
                      new Text(
                          "Edad:  ${hero.edad}",style: TextStyle(fontSize: 10.0,
                          fontWeight: FontWeight.bold)),
                      new Text(
                          "Altura:  ${hero.altura}",style: TextStyle(fontSize: 10.0,
                          fontWeight: FontWeight.bold)),
                      new Text(
                          "Genero:  ${hero.genero}",style: TextStyle(fontSize: 10.0,
                          fontWeight: FontWeight.bold)),
                      new Text(
                          "Descripcion:  ${hero.descripcion}",style: TextStyle(fontSize: 20.0,
                          color: Colors.black)),
                      new Padding(padding: EdgeInsets.all(20.0)),
                    ],
                  ),
                ),
                //ORIENTACION DEL MOVIMIENTO
scrollDirection: Axis.vertical,
//PARA QUE REGRESE
reverse: false,
),
),
),

],
),
);
}
}