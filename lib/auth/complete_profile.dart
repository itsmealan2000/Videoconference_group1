import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:videoconference/pages/home_page.dart';

class CompleteProfile extends StatefulWidget {
  const CompleteProfile({super.key});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  TextEditingController fullnameController = TextEditingController();

  void checkValues(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage(),));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
                  Color.fromARGB(255, 169, 37, 240),
                Color.fromARGB(255, 51, 215, 227)
                ],
                )
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoButton(
                  onPressed: (){},
                  child: CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.amber.shade300,
                    child: Icon(Icons.person,size: 70,color: Colors.grey.shade50,),
                  ),
                ),
                const SizedBox(height: 20,),
                   Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.black),
                    borderRadius: BorderRadius.circular(15)),
                child: TextField(
                  style: TextStyle(color: Colors.grey.shade50),
                  obscureText: false,
                  controller: fullnameController,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      label: Text("Full Name"),
                      labelStyle: TextStyle(fontSize: 20, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20,),
                 Material(
                elevation: 5,
                shadowColor: Colors.black,
                borderRadius: BorderRadius.circular(15),
                child: CupertinoButton(
                  padding:const EdgeInsets.symmetric(horizontal: 140, vertical: 20),
                  borderRadius: BorderRadius.circular(15),
                  onPressed: checkValues,
                  color: Colors.yellow.shade400,
                  child: Text(
                    'Submit',
                    style: TextStyle(color: Colors.grey.shade900, fontSize: 22),
                  ),
                ),
              )
              ],
            )
          ],
        ),
      ),
    );
  }
}