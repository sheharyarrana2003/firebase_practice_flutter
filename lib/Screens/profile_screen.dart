import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_practice/Screens/image_screen.dart';
import 'package:firebase_practice/Screens/login_screen.dart';
import 'package:firebase_practice/modules/firebase_variables.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading=false;
  Future<void> LogOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLogin', false);
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();       
     await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Loginscreen()));
  }
  
  // Future<Map<String,dynamic>?> _getUserData() async{
  //   String uid=FirebaseAuth.instance.currentUser!.uid;
  //   DocumentSnapshot userDoc=await FirebaseVariables.userCollection.doc(uid).get();
  //   if(userDoc.exists){
  //     return userDoc.data() as Map<String,dynamic>;
  //   }
  //   return null;
  // }
  Stream<DocumentSnapshot> _getUserData(){
    String uid=FirebaseAuth.instance.currentUser!.uid;
    return FirebaseVariables.userCollection.doc(uid).snapshots();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade600,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Profile",
          style: TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>ImageScreen()));
          }, icon: Icon(Icons.arrow_forward_ios,color: Colors.white,))
        ],
      ),
      body: StreamBuilder(
        stream: _getUserData(),
        builder: (context,snapshot){
          if(snapshot.connectionState==ConnectionState.waiting){
            return Center(child: CircularProgressIndicator(),);
          }
          if(!snapshot.hasData || snapshot.data==null || !snapshot.data!.exists){
            return Center(child: Text("No Use Data Found",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),);
          }
          var userData=snapshot.data!.data() as Map<String,dynamic>;
        return Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade100, 
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Name",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(userData["user_name"], style: TextStyle(fontSize: 16)),
                        Icon(Icons.edit, color: Colors.blue)
                      ],
                    ),
                    SizedBox(height: 20),
                    Divider(thickness: 1, color: Colors.grey), 
                    SizedBox(height: 20),
                    Text(
                      "Email",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(userData["email"], style: TextStyle(fontSize: 16)),
                        Icon(Icons.edit, color: Colors.blue)
                      ],
                    ),
                    SizedBox(height: 30,),
                     InkWell(
                          onTap: LogOut,
                          child: Container(
                            width: 130,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade600,
                              borderRadius: BorderRadius.circular(21),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueGrey.withOpacity(0.8),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                )
                              ],
                            ),
                            child: Center(
                              child: isLoading
                                  ? CircularProgressIndicator()
                                  : Text(
                                      "Log Out",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),
          );
        }
      ),
      // body: FutureBuilder(
      //   future: _getUserData(),
      //   builder: (context,snapshot){
      //     if(snapshot.connectionState==ConnectionState.waiting){
      //       return Center(child: CircularProgressIndicator(),);
      //     }
      //     if(!snapshot.hasData || snapshot.data==null){
      //       return Center(child: Text("No User Data Found",style:TextStyle(fontSize: 24) ));
      //     }
      //   var userData=snapshot.data!;
      //   return Padding(
      //     padding: EdgeInsets.symmetric(horizontal: 14),
      //     child: Center(
      //       child: Container(
      //         padding: EdgeInsets.all(16),
      //         decoration: BoxDecoration(
      //           border: Border.all(color: Colors.red, width: 2),
      //           borderRadius: BorderRadius.circular(12),
      //           color: Colors.grey.shade100, 
      //         ),
      //         child: Column(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           mainAxisSize: MainAxisSize.min,
      //           children: [
      //             Text(
      //               "Name",
      //               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      //             ),
      //             SizedBox(height: 10),
      //             Row(
      //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //               children: [
      //                 Text(userData?["user_name"], style: TextStyle(fontSize: 16)),
      //                 Icon(Icons.edit, color: Colors.blue)
      //               ],
      //             ),
      //             SizedBox(height: 20),
      //             Divider(thickness: 1, color: Colors.grey), 
      //             SizedBox(height: 20),
      //             Text(
      //               "Email",
      //               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      //             ),
      //             SizedBox(height: 10),
      //             Row(
      //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //               children: [
      //                 Text(userData["email"], style: TextStyle(fontSize: 16)),
      //                 Icon(Icons.edit, color: Colors.blue)
      //               ],
      //             ),
      //             SizedBox(height: 30,),
      //              InkWell(
      //                   onTap: LogOut,
      //                   child: Container(
      //                     width: 130,
      //                     height: 60,
      //                     decoration: BoxDecoration(
      //                       color: Colors.blue.shade600,
      //                       borderRadius: BorderRadius.circular(21),
      //                       boxShadow: [
      //                         BoxShadow(
      //                           color: Colors.blueGrey.withOpacity(0.8),
      //                           blurRadius: 10,
      //                           spreadRadius: 2,
      //                         )
      //                       ],
      //                     ),
      //                     child: Center(
      //                       child: isLoading
      //                           ? CircularProgressIndicator(
      //                               backgroundColor: Colors.white.withOpacity(0.5),
      //                               color: Colors.white,
      //                               strokeWidth: 4.0,
      //                               strokeAlign: 0.0,
      //                               semanticsLabel: "Signing Up...",
      //                               semanticsValue: "Loading",
      //                               strokeCap: StrokeCap.round,
      //                               trackGap: 2.0,
      //                             )
      //                           : Text(
      //                               "Log Out",
      //                               style: TextStyle(
      //                                 color: Colors.white,
      //                                 fontSize: 25,
      //                                 fontWeight: FontWeight.bold,
      //                               ),
      //                             ),
      //                     ),
      //                   ),
      //                 ),
      //           ],
      //         ),
      //       ),
      //     ),
      //   );
      //   }
      // ),
    );
  }
}
