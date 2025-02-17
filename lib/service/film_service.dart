import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../model/film_model.dart';

class FilmService{
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  Future<FilmModel?> getFilmByFilmID({required String filmID}) async{
    try {
      DocumentSnapshot doc = await firestore.collection('Film').doc(filmID).get();

      if (doc.exists) {
        FilmModel? film = FilmModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        if (film != null){
          final imageUrl = await getImageUrl(film.id);
          film.setUrl(imageUrl);
        }
        return film;
      } else {
        return null;
      }
    } catch (e) {
      print("Lỗi khi lấy phim: $e");
      return null;
    }
  }
  Future<List<FilmModel>> searchFilmNamesByName(String nameQuery) async {
    try {
      String upperCaseQuery = nameQuery.toUpperCase();
      QuerySnapshot querySnapshot = await firestore.collection('Film')
          .where('upperName', isGreaterThanOrEqualTo: upperCaseQuery)
          .where('upperName', isLessThanOrEqualTo: upperCaseQuery + '\uf8ff')
          .get();

      List<FilmModel> films = querySnapshot.docs.map((doc) {
        return FilmModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      return films;

    } catch (e) {
      print('Error searching film names: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> fetchListFilm({
    required int limit,
    required DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = firestore.collection('Film').limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();

      List<FilmModel> films = snapshot.docs.map((doc) {
        return FilmModel.fromMap(doc.data()! as Map<String, dynamic>, doc.id);
      }).toList();

      for (var film in films) {
        final imageUrl = await getImageUrl(film.id);
        film.setUrl(imageUrl);
      }

      return {
        'films': films,
        'lastDocument': snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      };
    } catch (e) {
      print('Error fetching films: $e');
      return {};
    }
  }

  Future<bool> updateFilm(FilmModel film) async {
    try {
      await firestore.collection('Film').doc(film.id).update(film.toMap());
      print("Film updated successfully!");
      return true;
    } catch (e) {
      print("Error updating film: $e");
      return false;
    }
  }
  Future<String?> addNewFilm(FilmModel film) async{
    try{
      DocumentReference docRef = await firestore.collection("Film").add(film.toMap());
      print("add film successfully");
      print(docRef.id);
      return docRef.id;
    }catch(e){
      print("Error adding film: $e");
      return null;
    }
  }
  Future<String> getImageUrl(String filmID) async {
    try {
      final ref = storage.ref().child('Poster/$filmID.jpg');
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      final defaultRef = storage.ref().child('test.jpg');
      final defaultUrl = await defaultRef.getDownloadURL();
      return defaultUrl;
    }
  }
  Future<bool> addNewImage(PlatformFile image, String filmID) async{
    String filePath = "Poster/$filmID.jpg";
    try{
      await storage.ref(filePath).putData(image.bytes!);
      print("Cap nhat anh thanh cong");
      return true;
    }
    catch(e){
      print(e);
      print("Cap nhat anh that bai");
      return false;
    }
  }
  Future<bool> deleteFilm(String filmID) async{
    try{
      await firestore.collection("Film").doc(filmID).delete();
      print("Xóa phim thành công");
      return true;
    }
    catch(e){
      print(e);
      print("Xóa phim thành công");
      return false;
    }
  }
  Future<bool> deleteImage(String filmID) async{
    try {
      final ref = storage.ref().child('Poster/$filmID.jpg');
      await ref.delete();
      print("Xóa ảnh thành công");
      return true;
    } catch (e) {
      print("Xóa ảnh thất bại");
      return false;
    }
  }
}