import 'package:brew_crew/models/newuser.dart';
import 'package:brew_crew/services/database.dart';
import 'package:brew_crew/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:brew_crew/shared/constants.dart';
import 'package:provider/provider.dart';

class SettingsForm extends StatefulWidget {
  const SettingsForm({Key? key}) : super(key: key);

  @override
  _SettingsFormState createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  final _formkey = GlobalKey<FormState>();
  final List<String> sugars = ['0', '1', '2', '3', '4'];

  // form values

  String? _currentName;
  int? _currentStrenght;
  String? _currentSugars;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<NewUser?>(context);

    return StreamBuilder<UserData>(
        stream: DatabaseService(uid: user!.uid).userData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            UserData? userData = snapshot.data;

            return Form(
              key: _formkey,
              child: Column(children: <Widget>[
                Text(
                  'Update your brew setting',
                  style: TextStyle(fontSize: 18.0),
                ),
                SizedBox(
                  height: 20.0,
                ),
                TextFormField(
                  initialValue: userData!.name,
                  decoration: textInputDecoration,
                  validator: (val) =>
                      val!.isEmpty ? 'please enter a name' : null,
                  onChanged: (val) => setState(() {
                    _currentName = val;
                  }),
                ),
                SizedBox(
                  height: 20.0,
                ),
                //dropdown
                DropdownButtonFormField<String>(
                  decoration: textInputDecoration,
                  value: _currentSugars ?? userData.sugars,
                  items: sugars.map((sugar) {
                    return DropdownMenuItem(
                      value: sugar,
                      child: Text('$sugar sugars'),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() {
                    _currentSugars = val;
                  }),
                ),
                //slider
                Slider(
                    value: (_currentStrenght ?? userData.strength!).toDouble(),
                    activeColor:
                        Colors.brown[_currentStrenght ?? userData.strength!],
                    inactiveColor:
                        Colors.brown[_currentStrenght ?? userData.strength!],
                    min: 100.0,
                    max: 900.0,
                    divisions: 8,
                    onChanged: (val) => setState(() {
                          _currentStrenght = val.round();
                        })),

                RaisedButton(
                  color: Colors.pink[400],
                  child: Text(
                    'Update',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    if (_formkey.currentState!.validate()) {
                      await DatabaseService(uid: user.uid).updateUserData(
                          _currentSugars ?? userData.sugars!,
                          _currentName ?? userData.name!,
                          _currentStrenght ?? userData.strength!);
                      Navigator.pop(context);
                    }
                  },
                )
              ]),
            );
          } else {
            return Loading();
          }
        });
  }
}
