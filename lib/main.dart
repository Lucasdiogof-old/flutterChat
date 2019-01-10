import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  runApp(MyApp());
}

final ThemeData temaPadrao =
    new ThemeData(primarySwatch: Colors.green, accentColor: Colors.grey[400]);

final googleSignIn = GoogleSignIn();
final auth = FirebaseAuth.instance;

Future<Null> _estaLogado() async {
  GoogleSignInAccount usuario = googleSignIn.currentUser;

  if (usuario == null) await googleSignIn.signInSilently();

  if (usuario == null) await googleSignIn.signIn();

  if (await auth.currentUser() == null) {
    GoogleSignInAuthentication credentials =
        await googleSignIn.currentUser.authentication;
    await auth.signInWithGoogle(
        idToken: credentials.idToken, accessToken: credentials.accessToken);
  }
}

_salvarTexto(String text) async {
  await _estaLogado();
  _enviarMensagem(texto: text);
}

void _enviarMensagem({String texto, String imgUrl}) {
  Firestore.instance.collection("mensagens").add({
    "texto": texto,
    "imgUrl": imgUrl,
    "nomeRemetente": googleSignIn.currentUser.displayName,
    "imgRemetente": googleSignIn.currentUser.photoUrl
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Chat",
      debugShowCheckedModeBanner: false,
      theme: temaPadrao,
      home: telaChat(),
    );
  }
}

class telaChat extends StatefulWidget {
  @override
  _telaChatState createState() => _telaChatState();
}

class _telaChatState extends State<telaChat> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Chat"),
          centerTitle: true,
          elevation: 4.0,
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                children: <Widget>[
                  Mensagem(),
                  Mensagem(),
                  Mensagem(),
                ],
              ),
            ),
            Divider(
              height: 1.0,
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
              ),
              child: TextComposer(),
            )
          ],
        ),
      ),
    );
  }
}

class TextComposer extends StatefulWidget {
  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  final _controleTexto = TextEditingController();
  bool _digitou = false;

  void _limpar() {
    _controleTexto.clear();
    setState(() {
      _digitou = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey[200]))),
        child: Row(
          children: <Widget>[
            Container(
              child:
                  IconButton(icon: Icon(Icons.photo_camera), onPressed: () {}),
            ),
            Expanded(
              child: TextField(
                controller: _controleTexto,
                decoration:
                    InputDecoration.collapsed(hintText: "Enviar uma Mensagem"),
                onChanged: (text) {
                  setState(() {
                    _digitou = text.length > 0;
                  });
                },
                onSubmitted: (texto) {
                  _salvarTexto(texto);
                  _limpar();
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                  color: Colors.green,
                  icon: Icon(Icons.send),
                  onPressed: _digitou
                      ? () {
                          _salvarTexto(_controleTexto.text);
                          _limpar();
                        }
                      : null),
            )
          ],
        ),
      ),
    );
  }
}

class Mensagem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                  "http://1.bp.blogspot.com/-lfnJYZDHwVg/Vh5_HCK8W5I/AAAAAAAAAWQ/A0pdZP05DRo/s1600/tumblr_nde9uchenL1t52aheo1_1280.jpg"),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Lucas",
                  style: Theme.of(context).textTheme.subhead,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: Text("teste"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
