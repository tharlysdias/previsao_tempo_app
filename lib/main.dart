// Conjunto de componentes
// Material => Importar
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Metodo main
// O que o meu app vai fazer
void main() => runApp(MaterialApp(
      title: "Velho Sábio",
      home: PaginaInicial(),
    ));

// componente com estado ou sem estado
class PaginaInicial extends StatefulWidget {
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<PaginaInicial> {
  GlobalKey<FormState> _key = new GlobalKey();
  TextEditingController controller = TextEditingController();
  bool _validate = false;
  dynamic cep;
  var temperatura;
  var tempoDescricao;
  var umidadeAr;
  var vento;

  var logradouro;
  var bairro;
  var localidade;
  var estado;
  var ddd;

  Future getWeather(cidade) async {
    http.Response response = await http.get(
      "http://api.openweathermap.org/data/2.5/weather?q=$cidade&Brazil&appid=44185947ca3544e1860c1fc810deb997",
    );
    var results = jsonDecode(response.body);

    setState(() {
      this.temperatura = results['main']['temp'];
      this.tempoDescricao = results['weather'][0]['description'];
      this.umidadeAr = results['main']['humidity'];
      this.vento = results['wind']['speed'];
    });
  }

  Future getCep() async {
    http.Response response = await http.get(
      "https://viacep.com.br/ws/$cep/json/",
    );
    var results = jsonDecode(response.body);

    setState(() {
      this.logradouro = results['logradouro'];
      this.bairro = results['bairro'];
      this.localidade = results['localidade'];
      this.estado = results['uf'];
      this.ddd = results['ddd'];
    });

    this.getWeather(localidade);

    controller = localidade;
  }

  @override
  Widget build(BuildContext context) {
    var form = new Form(
      key: _key,
      autovalidate: _validate,
      child: _formUI(),
    );
    return MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Velho Sabio'),
        ),
        body: new SingleChildScrollView(
          child: new Container(
            margin: new EdgeInsets.all(15.0),
            child: form,
          ),
        ),
      ),
    );
  }

  Widget _formUI() {
    return new Column(
      children: <Widget>[
        new TextFormField(
          decoration: new InputDecoration(hintText: 'Digite seu CEP'),
          maxLength: 8,
          validator: _validarCep,
          onSaved: (String val) {
            cep = val;
          },
        ),
        new RaisedButton(
          onPressed: _sendForm,
          child: new Text('Consultar'),
          
        ),

        //Titulo do CEP
        Padding(
          padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
          child: Text(
            "Informações de Endereço",
            style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                fontWeight: FontWeight.w600),
          ),
        ),
        ListTile(
          leading: FaIcon(FontAwesomeIcons.road),
          title: Text("Logradouro"),
          trailing:
              Text(logradouro != null ? logradouro.toString() : "Loading"),
        ),
        ListTile(
          leading: FaIcon(FontAwesomeIcons.searchLocation),
          title: Text("Bairro"),
          trailing: Text(bairro != null ? bairro.toString() : "Loading"),
        ),
        ListTile(
          leading: FaIcon(FontAwesomeIcons.city),
          title: Text("Cidade"),
          trailing:
              Text(localidade != null ? localidade.toString() : "Loading"),
        ),
        ListTile(
          leading: FaIcon(FontAwesomeIcons.mapMarkedAlt),
          title: Text("Estado"),
          trailing: Text(estado != null ? estado.toString() : "Loading"),
        ),
        ListTile(
          leading: FaIcon(FontAwesomeIcons.phoneAlt),
          title: Text("DDD"),
          trailing: Text(ddd != null ? ddd.toString() : "Loading"),
        ),

        //Titulo previsão do tempo
        Padding(
          padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
          child: Text(
            "Previsão do Tempo",
            style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                fontWeight: FontWeight.w600),
          ),
        ),
        ListTile(
          leading: FaIcon(FontAwesomeIcons.cloud),
          title: Text("Clima"),
          trailing: Text(
              tempoDescricao != null ? tempoDescricao.toString() : "Loading"),
        ),
        ListTile(
          leading: FaIcon(FontAwesomeIcons.thermometerHalf),
          title: Text("Temperatura"),
          trailing: Text(temperatura != null
              ? temperatura.toString() + "\u00B0"
              : "Loading"),
        ),
        ListTile(
          leading: FaIcon(FontAwesomeIcons.sun),
          title: Text("Umidade"),
          trailing: Text(umidadeAr != null ? umidadeAr.toString() : "Loading"),
        ),
        ListTile(
          leading: FaIcon(FontAwesomeIcons.wind),
          title: Text("Velocidade do Vento"),
          trailing: Text(vento != null ? vento.toString() : "Loading"),
        ),
      ],
    );
  }

  String _validarCep(String value) {
    String patttern = r'(^[0-9 ]*$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "Informe o CEP";
    } else if (!regExp.hasMatch(value)) {
      return "O CEP deve conter somente números";
    }
    return null;
  }

  _sendForm() {
    if (_key.currentState.validate()) {
      _key.currentState.save();
      this.getCep();
    } else {
      setState(() {
        _validate = true;
      });
    }
  }
}
