import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../model/film_model.dart';
import '../routes/routes_name.dart';
import '../service/film_service.dart';
import 'dart:html';

class MenuFilmViewModel extends ChangeNotifier{
  final FilmService _filmService = FilmService();
  final _limit = 9;
  List<FilmModel> _films = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;

  List<FilmModel> get films => _films;
  bool get isLoading => _isLoading;
  DocumentSnapshot? get lastDocument => _lastDocument;

  void filmOnTap(BuildContext context,FilmModel film){
    window.sessionStorage['filmID'] = film.id;
    context.push(RoutesName.DETAILED_FILM);
    // Navigator.pushNamed(
    //   context,
    //   RoutesName.DETAILED_FILM,
    // );
  }

  Future<void> fetchFilms() async {
    _films = [];
    try {
      final result = await _filmService.fetchListFilm(
        limit: _limit,
        lastDocument: _lastDocument,
      );
      _films.addAll(result['films']);
      _lastDocument = result['lastDocument'];
    } catch (e) {
      print('Error fetching films: $e');
    }
  }
  Future<void> fetchMoreFilms() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _filmService.fetchListFilm(
        limit: _limit,
        lastDocument: _lastDocument,
      );
      _films.addAll(result['films']);
      _lastDocument = result['lastDocument'];
    } catch (e) {
      print('Error fetching films: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

}