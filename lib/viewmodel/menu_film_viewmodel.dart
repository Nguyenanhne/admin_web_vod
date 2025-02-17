import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../model/film_model.dart';
import '../routes/routes_name.dart';
import '../service/film_service.dart';
import 'dart:html';

class MenuFilmViewModel extends ChangeNotifier{
  final FilmService _filmService = FilmService();
  final _limit = 10;
  List<FilmModel> _films = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  bool _hasMore = true;
  List<FilmModel> get films => _films;
  bool get isLoading => _isLoading;
  DocumentSnapshot? get lastDocument => _lastDocument;
  ScrollController scrollController = ScrollController();


  MenuFilmViewModel(){
    scrollController.addListener((){
      onScroll();
    });
  }
  void onScroll(){
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent && !isLoading && _hasMore) {
      fetchMoreFilms();
    }
  }
  void filmOnTap(BuildContext context,FilmModel film){
    window.sessionStorage['filmID'] = film.id;
    context.go(RoutesName.DETAILED_FILM);
  }

  Future<void> fetchFilms() async {
    reset();
    try {
      final result = await _filmService.fetchListFilm(
        limit: _limit,
        lastDocument: _lastDocument,
      );
      _films.addAll(result['films']);
      _lastDocument = result['lastDocument'];
      _hasMore = films.length == _limit;
    } catch (e) {
      print('Error fetching films: $e');
    }
  }
  Future<void> fetchMoreFilms({int limit = 5}) async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;
    notifyListeners();
    try {
      final result = await FilmService().fetchListFilm(
        limit: limit,
        lastDocument: _lastDocument,
      );
      final List<FilmModel> films = result['films'] as List<FilmModel>;
      final DocumentSnapshot? lastDocument = result['lastDocument'] as DocumentSnapshot?;

      if (films.isNotEmpty) {
        _films.addAll(films);

        _lastDocument = lastDocument;

        if (films.length < limit) {
          _hasMore = false;
        }
      } else {
        _hasMore = false;
      }
    } catch (e) {
      print('Failed to load more movies: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  // Future<void> fetchMoreFilms() async {
  //   if (_isLoading) return;
  //   _isLoading = true;
  //   notifyListeners();
  //   try {
  //     final result = await _filmService.fetchListFilm(
  //       limit: _limit,
  //       lastDocument: _lastDocument,
  //     );
  //     _films.addAll(result['films']);
  //     _lastDocument = result['lastDocument'];
  //   } catch (e) {
  //     print('Error fetching films: $e');
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }
  void reset(){
    _films.clear();
    _lastDocument = null;
  }
}