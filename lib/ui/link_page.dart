import 'package:flutter/material.dart';
import 'package:links_favoritos/helpers/link_helper.dart';
import 'package:links_favoritos/helpers/category_helper.dart';
import 'package:regexpattern/regexpattern.dart';
//import 'package:dropdownfield/dropdownfield.dart';

class LinkPage extends StatefulWidget {
  final Link link;

  LinkPage({this.link});

  @override
  _LinkPageState createState() => _LinkPageState();
}

class _LinkPageState extends State<LinkPage> {
  final _titleController = TextEditingController();
  final _linkController = TextEditingController();
  final _obsController = TextEditingController();
  final _categoryController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Link _editedLink;
  LinkHelper helper = LinkHelper();
  CategoryHelper categoryHelper = CategoryHelper();

  @override
  void initState() {
    super.initState();

    if (widget.link == null) {
      _editedLink = Link();
    } else {
      _editedLink = Link.fromMap(widget.link.toMap());

      _titleController.text = _editedLink.title;
      _linkController.text = _editedLink.link;
      _obsController.text = _editedLink.obs;
      _categoryController.text = _editedLink.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(_editedLink.title ?? "Adicionar Link"),
          backgroundColor: Colors.deepPurple,
          centerTitle: true),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState.validate()) {
            Navigator.of(context).pop(_editedLink);
          }
        },
        child: Icon(Icons.save),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                validator: (value) {
                  if (value.isEmpty) return "O campo é obrigatório.";
                  return null;
                },
                controller: _titleController,
                decoration: InputDecoration(labelText: "Título"),
                onChanged: (text) {
                  _editedLink.title = text;
                },
              ),
              TextFormField(
                validator: (value) {
                  if (value.isEmpty) return "O campo é obrigatório.";

                  bool isUrlChecked = value.isUrl();
                  if (!isUrlChecked) return "Url inválida";
                  return null;
                },
                controller: _linkController,
                decoration: InputDecoration(labelText: "Link"),
                onChanged: (text) {
                  if (!text.contains("http")) {
                    text = "http://" + text;
                  }
                  _editedLink.link = text;
                },
              ),
              TextFormField(
                validator: (value) {
                  if (value.length > 100)
                    return "Este campo não pode ter mais de 100 caracteres";
                  return null;
                },
                controller: _obsController,
                decoration: InputDecoration(labelText: "Observação"),
                onChanged: (text) {
                  _editedLink.obs = text;
                },
              ),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: "Categoria"),
                onChanged: (text) {
                  _editedLink.category = text;
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
