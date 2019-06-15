import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:george_flutter/screen/sign_in/util/auth.dart';
import 'package:george_flutter/util/firebase_helper.dart';
import 'package:george_flutter/util/view/loading.dart';
import 'package:toast/toast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart';

import '../route_paths.dart';

class FavoriteListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _FavoriteListScreenContainer();
  }
}

class _FavoriteListScreenContainer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FavoriteListScreenContainerState();
  }
}

class _FavoriteListScreenContainerState
    extends State<_FavoriteListScreenContainer> {
  FirebaseUser _firebaseUser = FirebaseUser.instance;

  bool _isAddingNewList = false;
  bool _isLoadingFavoriteList = false;
  List<FavoriteList> _favoriteList;

  @override
  void initState() {
    super.initState();
    _refreshFavoriteList();
  }

  void _refreshFavoriteList() {
    _firebaseUser.getFavoriteList().doOnListen(() {
      setState(() {
        _isAddingNewList = false;
        _isLoadingFavoriteList = true;
      });
    }).listen((favoriteList) {
      setState(() {
        _isLoadingFavoriteList = false;
        _isAddingNewList = false;
        _favoriteList = favoriteList;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite list'),
      ),
      body: Center(
        child: _FavoriteListScreenContainerBranch(
          isAddingNewList: _isAddingNewList,
          favoriteList: _favoriteList,
          isLoadingFavoriteList: _isLoadingFavoriteList,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String result = await _showDialog(context);
          if (result.isNotEmpty) {
            _firebaseUser.addNewFavoriteList(result).listen((dynamic) {
              _refreshFavoriteList();
            });
          }
        },
        tooltip: "Add new favorite list",
        child: Icon(Icons.add),
        backgroundColor: Colors.deepOrangeAccent,
      ),
    );
  }

  Future<String> _showDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();

    return showDialog(
        context: context,
        builder: (context) {
          return new AlertDialog(
            title: Text("New favorite list"),
            content: TextField(
              decoration: InputDecoration(hintText: "input favorite list name"),
              controller: controller,
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(controller.text);
                },
                child: Text("Ok"),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop("");
                },
                child: Text("Cancel"),
              ),
            ],
          );
        });
  }
}

class _FavoriteListScreenContainerBranch extends StatelessWidget {
  final bool isAddingNewList;
  final bool isLoadingFavoriteList;
  final List<FavoriteList> favoriteList;

  _FavoriteListScreenContainerBranch(
      {@required this.isAddingNewList,
      @required this.favoriteList,
      @required this.isLoadingFavoriteList});

  @override
  Widget build(BuildContext context) {
    if (isAddingNewList) {
      return CircularProgressBar(text: "Adding new favorite list...");
    } else if (isLoadingFavoriteList) {
      return CircularProgressBar(text: "Loading favorite list...");
    } else if (favoriteList != null && favoriteList.isNotEmpty) {
      return _FavoriteList(favoriteList);
    } else {
      return Text("Let's try to create a new favorite list!");
    }
  }
}

class _FavoriteList extends StatelessWidget {
  final List<FavoriteList> favoriteList;

  _FavoriteList(this.favoriteList);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemBuilder: (context, position) {
        return Card(
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                ScreenPath.favorite_item_screen,
                arguments: favoriteList[position],
              );
            },
            child: Column(
              children: <Widget>[
                Padding(padding: EdgeInsets.only(top: 16)),
                Row(
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(left: 16)),
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            favoriteList[position]
                                .snapshot
                                .data[FireStoreConstants.favoriteListName],
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text(favoriteList[position]
                                  .snapshot
                                  .data[FireStoreConstants.favoriteListCreateBy]),
                              Padding(padding: EdgeInsets.only(top: 4)),
                              Text(DateFormat('yyyy-MM-dd').format(
                                  DateTime.fromMillisecondsSinceEpoch(int.parse(
                                      favoriteList[position].snapshot.data[
                                      FireStoreConstants
                                          .favoriteListCreateTime])))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(left: 16)),
                  ],
                ),
                Padding(padding: EdgeInsets.only(top: 16)),
              ],
            ),
          )
        );
      },
      itemCount: favoriteList.length,
    );
  }
}
