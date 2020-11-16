import 'package:Vertretung/models/newsModel.dart';

///Informations about the selected news from NewsPage.dart
class NewsTransmitter {
  final NewsModel news;
  final bool isEditAction;
  NewsTransmitter(this.isEditAction, [this.news]);
}
