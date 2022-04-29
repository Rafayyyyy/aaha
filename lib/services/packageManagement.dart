import 'dart:io';

import 'package:aaha/AgHomeAgView.dart';
import 'package:aaha/Agency.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:aaha/MyBottomBarDemo.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'agencyManagement.dart';
import 'package:aaha/agencyhome.dart';

class packageManagement {
  static String Agencyid = '';
  static String Packid = '';
  static List<Package1> p1 = [];

  static CollectionReference Package =
      FirebaseFirestore.instance.collection('Packages');
  static storeNewPackage(
  user, name, desc, days, price, location, rating, context, ImgUrls,otherDetails,photoUrl) {
    final docp = FirebaseFirestore.instance.collection('Packages').doc();
    Packid = docp.id;

    docp.set({
      'Agency id': user.uid,
      'Agency Name': AgencyHomeState.Agencyname,
      'Package id': docp.id,
      'Package name': name,
      'description': desc,
      'days': days,
      'price': price,
      'Location': location,
      'Rating': rating,
      'ImgUrls': ImgUrls,
      'otherDetails': otherDetails,
      'photoUrl': photoUrl,
      'packageAddedDate':DateTime.now(),
      'sales':0
    }).then((value) {
      Package1 p = Package1(docp.id, name, AgencyHomeState.Agencyname, price,
          days, desc, location, rating, user.uid,photoUrl, ImgUrls,otherDetails);
      packageProvider.getList1().add(p);
      Navigator.of(context).pop();
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AgHomeAgView(),
      ));
    });
  }

  static UpdatePackage(Package1 p, user, name, desc, days, price, location,
      rating, context, ImgUrls) async {
    print(p.pid);
    await FirebaseFirestore.instance.collection('Packages').doc(p.pid).update({
      'Agency id': user.uid,
      'Agency Name': AgencyHomeState.Agencyname,
      'Package id': p.pid,
      'Package name': name,
      'description': desc,
      'days': days,
      'price': price,
      'Location': location,
      'Rating': rating,
      'ImgUrls': ImgUrls,
      'photoUrl': 'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8NXx8Ym9hdCUyMG9uJTIwd2F0ZXJ8ZW58MHx8MHx8&w=1000&q=80',
    }).then((value) {
      Navigator.of(context).pop();
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AgHomeAgView(),
      ));
    }).catchError((error) => print(error));
  }

  static removePackage(pid) {
    final docp = FirebaseFirestore.instance.collection('Packages').doc(pid);
    docp.delete();
  }

  static Package1 fromJson(Map<String, dynamic> json) {
    List<String>? imgUrls =
        (json['ImgUrls'] as List)?.map((item) => item as String)?.toList();
    List<String>? otherDetailsList =
    (json['otherDetails'] as List)?.map((item) => item as String)?.toList();
    Package1 p1 = Package1(
      json['Package id'],
      json['Package name'],
      json['Agency Name'],
      json['price'],
      json['days'],
      json['description'],
      json['Location'],
      json['Rating'],
      json['Agency id'],
      json['photoUrl'],
      imgUrls!,
      otherDetailsList!,
    );
    return p1;
  }

  static getPackages(AgencyId) async {
    await FirebaseFirestore.instance
        .collection('Packages')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        p1.add(packageManagement.fromJson(doc.data() as Map<String, dynamic>));
      });
    });
    for (var i = 0; i < p1.length; i++) {
      if (p1[i].agencyId == Agencyid) PackageList.add(p1[i]);
    }
  }

  static getPackagesTraveler() async {
    await FirebaseFirestore.instance
        .collection('Packages')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        p1.add(packageManagement.fromJson(doc.data() as Map<String, dynamic>));
      });
    });
  }

  updateSales(packageID){
    Package.doc(packageID).update({'sales': FieldValue.increment(1)});
  }
  
  
}

class packageProvider extends ChangeNotifier {
  String name = 'DummyName';
  String AgencyId = '111';
  String days = '00';
  String desc = 'About package';
  String price = '20';
  String photoUrl = 'https://flyclipart.com/thumb2/person-icon-137546.png';
  void updatePackage(Package1 p, name, desc, days, price, location, ImgUrls) {
    for (var i = 0; i < PackageList.length; i++) {
      if (PackageList[i].pid == p.pid) {
        PackageList[i].PName = name;
        PackageList[i].Desc = desc;
        PackageList[i].Days = days;
        PackageList[i].Price = price;
        PackageList[i].Location = location;
        PackageList[i].ImgUrls = ImgUrls;
      }
    }

    notifyListeners();
  }
  

  void setPackages(AgencyId) {
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await packageManagement.getPackages(AgencyId);
    });

    notifyListeners();
  }

  void setPackagesTraveler() {
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await packageManagement.getPackagesTraveler();
    });

    notifyListeners();
  }

  static List<Package1> getList1() {
    return PackageList;
  }

  List<Package1> getList() {
    return PackageList;
  }

  Future<String>? getName(var p) async {
    var document =
        await FirebaseFirestore.instance.collection('Packages').doc(p.pid);
    await document.get().then((document) {
      print(document['Package name']);
      name = document['Package name'];
      notifyListeners();
    });
    return name;
  }

  Future<String>? getAgencyId(var p) async {
    var document =
        await FirebaseFirestore.instance.collection('Packages').doc(p.pid);
    await document.get().then((document) {
      print(document['Agency Id']);
      AgencyId = document['Agency Id'];
      notifyListeners();
    });
    return AgencyId;
  }

  Future<String>? getDays(var p) async {
    var document =
        await FirebaseFirestore.instance.collection('Packages').doc(p.pid);
    await document.get().then((document) {
      print(document['days']);
      days = document['days'];
      notifyListeners();
    });
    return days;
  }

  Future<String>? getDescription(var p) async {
    var document =
        await FirebaseFirestore.instance.collection('Packages').doc(p.pid);
    await document.get().then((document) {
      print(document['description']);
      desc = document['description'];
      notifyListeners();
    });
    return desc;
  }

  Future<String>? getPrice(var p) async {
    var document =
        await FirebaseFirestore.instance.collection('Packages').doc(p.pid);
    await document.get().then((document) {
      print(document['price']);
      price = document['price'];
      notifyListeners();
    });
    return price;
  }

  Future<String>? getPhotoUrl(var p) async {
    var document =
        await FirebaseFirestore.instance.collection('Packages').doc(p.pid);
    await document.get().then((document) {
      print(document['photoUrl']);
      photoUrl = document['photoUrl'];
      notifyListeners();
    });
    return photoUrl;
  }

  void RemovePackage(Package1 p) {
    PackageList.remove(p);
    packageManagement.p1.remove(p);
    packageManagement.removePackage(p.pid);
    notifyListeners();
  }
}
