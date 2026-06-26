import 'song.dart';

class Album {
  final String id;
  final String title;
  final List<String> artists;
  final String coverUrl;
  final String? year;
  final int? songCount;
  final List<Song> songs;
  final String? description;

  const Album({
    required this.id,
    required this.title,
    required this.artists,
    required this.coverUrl,
    this.year,
    this.songCount,
    this.songs = const [],
    this.description,
  });

  String get artistString => artists.join(', ');
}

class Artist {
  final String id;
  final String name;
  final String imageUrl;
  final String? bio;
  final int? followerCount;
  final List<Album> albums;
  final List<Song> topSongs;

  const Artist({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.bio,
    this.followerCount,
    this.albums = const [],
    this.topSongs = const [],
  });
}

class Playlist {
  final String id;
  final String name;
  final String? description;
  final String coverUrl;
  final List<Song> songs;
  final int? songCount;
  final String? username;

  const Playlist({
    required this.id,
    required this.name,
    this.description,
    required this.coverUrl,
    this.songs = const [],
    this.songCount,
    this.username,
  });
}
