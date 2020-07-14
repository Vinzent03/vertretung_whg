///Informations about the selected news from NewsPage.dart
class NewsTransmitter {
  final String text;
  final String title;
  final bool isEditAction;
  final int index;
  NewsTransmitter(this.isEditAction, {this.text, this.title, this.index});
}