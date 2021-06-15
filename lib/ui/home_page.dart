import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:links_favoritos/helpers/link_helper.dart';
import 'package:links_favoritos/ui/link_page.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions { orderaz, orderza }

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  LinkHelper helper = LinkHelper();
  List<Link> links = [];

  @override
  void initState() {
    super.initState();

    _getAllLinks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset("images/logo_horizontal_branco.png", height: 36,),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de A-Z"),
                value: OrderOptions.orderaz,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de Z-A"),
                value: OrderOptions.orderza,
              )
            ],
            onSelected: _orderList,
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showLinkPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10.0),
        itemCount: links.length,
        itemBuilder: (context, index) {
          return _linkCard(context, index);
        },
      ),
    );
  }

  Widget _linkCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                child: Text(links[index].title,
                    style:
                    TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                child: Text(links[index].obs ?? "sem observação", style: TextStyle(fontSize: 16.0)),
              ),
              Text(links[index].category ?? "sem categoria definida",
                  style: TextStyle(fontSize: 14.0, fontStyle: FontStyle.italic))
            ],
          ),
        ),
      ),
      onTap: () {
        _showDialog(context, index);
      },
    );
  }

  void _showDialog(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            onClosing: () {},
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(5.0),
                      child: TextButton(
                        child: Text(
                          "Abrir link",
                          style: TextStyle(
                              color: Colors.deepPurple, fontSize: 20.0),
                        ),
                        onPressed: () {
                          _launchURL(links[index].link);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5.0),
                      child: TextButton(
                        child: Text(
                          "Editar",
                          style: TextStyle(
                              color: Colors.deepPurple, fontSize: 20.0),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showLinkPage(link: links[index]);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5.0),
                      child: TextButton(
                        child: Text(
                          "Excluir",
                          style: TextStyle(
                              color: Colors.deepPurple, fontSize: 20.0),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showAlertDialog(context, index);
                        },
                      ),
                    )
                  ],
                ),
              );
            },
          );
        });
  }

  _showAlertDialog(BuildContext context, index) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: new Text("Excluir link"),
            content: new Text("Tem certeza que deseja excluir este link?"),
            actions: <Widget>[
              TextButton(
                child: Text('Cancelar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text("Sim"),
                onPressed: () {
                  Navigator.of(context).pop();
                  helper.deleteLink(links[index].id);

                  setState(() {
                    links.removeAt(index);
                  });
                },
              )
            ],
          );
        });
  }

  void _launchURL(url) async =>
      await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';

  void _showLinkPage({Link link}) async {
    final recLink = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => LinkPage(
                  link: link,
                )));

    if (recLink != null) {
      if (link != null) {
        await helper.updateLink(recLink);
      } else {
        await helper.saveLink(recLink);
      }

      _getAllLinks();
    }
  }

  void _getAllLinks() {
    helper.getAllLinks().then((list) {
      setState(() {
        links = list;
      });
    });
  }

  void _orderList(OrderOptions result) {
    switch (result) {
      case OrderOptions.orderaz:
        links.sort((a, b) {
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        links.sort((a, b) {
          return b.title.toLowerCase().compareTo(a.title.toLowerCase());
        });
        break;
    }
    setState(() {});
  }
}
