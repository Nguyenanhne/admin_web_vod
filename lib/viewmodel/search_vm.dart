import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:html';
import '../model/film_model.dart';
import '../routes/routes_name.dart';
import '../service/film_service.dart';


class SearchViewModel extends ChangeNotifier {
  final FilmService filmService = FilmService();

  void searchOnTap(BuildContext context,FilmModel film){
    window.sessionStorage['filmID'] = film.id;
    context.go(RoutesName.DETAILED_FILM);
  }
}
