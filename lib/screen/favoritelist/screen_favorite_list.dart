import 'package:cloud_firestore/cloud_firestore.dart';
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

  PublishSubject<DocumentSnapshot> _deleteIntent = PublishSubject();
  PublishSubject<DocumentSnapshot> _renameIntent = PublishSubject();

  @override
  void dispose() {
    super.dispose();
    _deleteIntent.close();
    _renameIntent.close();
  }

  @override
  void initState() {
    super.initState();
    _refreshFavoriteList();

    _deleteIntent.listen((document) {
      Observable.fromFuture(document.reference.delete()).listen((dynamic) {
        FavoriteList favoriteList;
        _favoriteList.forEach((item) {
          if (item.snapshot.documentID == document.documentID) {
            favoriteList = item;
          }
        });
        if (favoriteList != null) {
          setState(() {
            _favoriteList.remove(favoriteList);
          });
        }
      });
    });

    _renameIntent.listen((document) {
      Observable.fromFuture(_showDialog(context,
              "Rename ${document.data[FireStoreConstants.favoriteListName]}"))
          .listen((result) {
        if (result.isNotEmpty &&
            result != document.data[FireStoreConstants.favoriteListName]) {
          document.data[FireStoreConstants.favoriteListName] = result;
          Observable.fromFuture(
                  document.reference.setData(document.data, merge: true))
              .listen((dynamic) {
            setState(() {});
          });
        }
      });
    });
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
          renameIntent: _renameIntent,
          deleteIntent: _deleteIntent,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String result = await _showDialog(context, "New favorite list");
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

  Future<String> _showDialog(BuildContext context, String title) {
    TextEditingController controller = TextEditingController();

    return showDialog(
        context: context,
        builder: (context) {
          return new AlertDialog(
            title: Text(title),
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
  final PublishSubject<DocumentSnapshot> deleteIntent;
  final PublishSubject<DocumentSnapshot> renameIntent;

  _FavoriteListScreenContainerBranch(
      {@required this.isAddingNewList,
      @required this.favoriteList,
      @required this.isLoadingFavoriteList,
      @required this.deleteIntent,
      @required this.renameIntent});

  @override
  Widget build(BuildContext context) {
    if (isAddingNewList) {
      return CircularProgressBar(text: "Adding new favorite list...");
    } else if (isLoadingFavoriteList) {
      return CircularProgressBar(text: "Loading favorite list...");
    } else if (favoriteList != null && favoriteList.isNotEmpty) {
      return _FavoriteList(favoriteList, deleteIntent, renameIntent);
    } else {
      return Text("Let's try to create a new favorite list!");
    }
  }
}

class _FavoriteList extends StatelessWidget {
  final List<FavoriteList> favoriteList;
  final PublishSubject<DocumentSnapshot> _deleteIntent;
  final PublishSubject<DocumentSnapshot> _renameIntent;

  _FavoriteList(this.favoriteList, this._deleteIntent, this._renameIntent);

  Future<String> _showActionDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Favorite list action"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: FlatButton(
                        textColor: Colors.white,
                        color: Color.fromARGB(0xff, 0x42, 0x85, 0xF4),
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: Text(
                          "Rename",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop("rename");
                        },
                      ),
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: FlatButton(
                        textColor: Colors.white,
                        color: Color.fromARGB(0xff, 0xDB, 0x44, 0x37),
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: Text(
                          "Delete",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop("delete");
                        },
                      ),
                    )
                  ],
                ),
              ],
            ),
            actions: <Widget>[
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
          onLongPress: () async {
            String result = await _showActionDialog(context);
            if (result == "rename") {
              _renameIntent.add(favoriteList[position].snapshot);
            } else if (result == "delete") {
              _deleteIntent.add(favoriteList[position].snapshot);
            }
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
                            Text(favoriteList[position].snapshot.data[
                                FireStoreConstants.favoriteListCreateByName]),
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
        ));
      },
      itemCount: favoriteList.length,
    );
  }
}
