import 'package:flutter/material.dart';

class Profilview extends StatelessWidget {
  const Profilview({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child : Column( children: [ CircleAvatar( radius : 150, backgroundImage: AssetImage("Images/among-us-amogus.gif"),
        ),
      SizedBox(height: 30),
      Text("Amogus Sus", style: Theme.of(context).textTheme.displayLarge),
      SizedBox(height : 30),
      Text("SusAmogus@SussyBAKA.com", style: Theme.of(context).textTheme.displayMedium),
      SizedBox(height: 30),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: BorderSide(color: Colors.green, width: 4),
      ),
    backgroundColor:  Colors.amberAccent,
    foregroundColor: Colors.pink,
    textStyle: TextStyle(fontSize: 20),
    elevation: 20),
    onPressed: () {},
    child: Text("Modifier le profil de l'utilisateur"))
        ],),
    );
  }
}