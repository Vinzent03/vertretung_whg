import 'package:Vertretung/models/news_model.dart';

///Informations about the selected news from NewsPage.dart
class NewsTransmitter {
  final NewsModel news;
  final bool isEditAction;
  NewsTransmitter(this.isEditAction, [this.news]);
}
