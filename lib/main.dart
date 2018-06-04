import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:my_weight_tracker/model/weight_rec.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(new MyApp());

double _currentWeight = 90.3;
List<WeightRec> _data;
final DateFormat dateFormat = DateFormat('MM/dd/yyyy HH:mm:ss');
WeightRecProvider provider = WeightRecProvider();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context)  {

    return new MaterialApp(
      title: 'My Weight Tracker',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'My Weight Tracker'),
    );
  }
}


class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;



  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  initState() {
    super.initState();
    initDB();
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "demo.db");
    await provider.open(path);
    _data = await provider.get();
    provider.close();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: new Scaffold(
          appBar: new AppBar(
            title: Text(widget.title),
            bottom: TabBar(
              tabs: <Widget>[
                Tab(
                  icon: const Icon(Icons.track_changes),
                ),
                Tab(
                  icon: const Icon(Icons.history),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              Scaffold(
                body: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'kg',
                        style: TextStyle(
                          fontSize: 25.0,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Text(
                        _currentWeight.floor().toString(),
                        style: TextStyle(
                          fontSize: 35.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '.' + ((_currentWeight - _currentWeight.floor())*10).toInt().toString(),
                        style: TextStyle(fontSize: 25.0),
                      ),
                    ],
                  ),
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return NumberPickerDialog.decimal(
                          minValue: 0,
                          maxValue: 200,
                          initialDoubleValue: _currentWeight,
                          title: Text('Enter your weight'),
                        );
                      },
                    ).then((value) {
                      print('New weight added... $value kg');
                      if (value != null) {
                        setState(() {
                          _currentWeight = value;
                          //_weightAdded(context, value);
                        });
                      }
                    });
                  },
                  tooltip: 'Add new Weight entry',
                  child: Icon(Icons.add),
                ),
              ),
              ListView.builder(
                itemBuilder: (BuildContext context, int index) =>
                    HistoryWidget(_data[index]),
                itemCount: _data?.length,
              ),
            ],
          ),
        ));
  }
}

class HistoryWidget extends StatelessWidget {
  
  final WeightRec rec;

  HistoryWidget(this.rec);

  @override
  Widget build(BuildContext context) {
    bool loss = rec.diff <= 0;
    CircleAvatar icon = CircleAvatar(
      backgroundColor: (loss ? Colors.green : Colors.red),
      foregroundColor: Colors.white,
      child: Text((loss ? '' : '+') + rec.diff.toString()),
    );
    return ListTile(
      leading: icon,
      title: Text(
        rec.weight.toString(),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(dateFormat.format(rec.dateTime)),
    );
  }
}

