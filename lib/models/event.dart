class Event {
  final String id;
  final String title;
  final String imageUrl;
  final String date;
  final String time;
  final String location;
  final String description;
  final String category; // Es. "Pulizia", "Incontro", "Workshop"

  Event({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.date,
    required this.time,
    required this.location,
    required this.description,
    required this.category,
  });
}