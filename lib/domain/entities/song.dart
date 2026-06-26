class Song {
  final String id;
  final String title;
  final List<String> artists;
  final String? artistId;
  final String album;
  final String? albumId;
  final int durationSeconds;
  final String coverUrl;
  final String? mediaUrl;
  final String? downloadUrl96;
  final String? downloadUrl160;
  final String? downloadUrl320;
  final bool hasLyrics;
  final String? year;
  final String? language;
  final String? label;
  bool isFavorite;
  String? localFilePath;
  final String source;

  Song({
    required this.id,
    required this.title,
    required this.artists,
    this.artistId,
    required this.album,
    this.albumId,
    required this.durationSeconds,
    required this.coverUrl,
    this.mediaUrl,
    this.downloadUrl96,
    this.downloadUrl160,
    this.downloadUrl320,
    this.hasLyrics = false,
    this.year,
    this.language,
    this.label,
    this.isFavorite = false,
    this.localFilePath,
    this.source = 'JioSaavn',
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      artists: List<String>.from(json['artists'] as List? ?? []),
      artistId: json['artistId'] as String?,
      album: json['album'] as String? ?? '',
      albumId: json['albumId'] as String?,
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      coverUrl: json['coverUrl'] as String? ?? '',
      mediaUrl: json['mediaUrl'] as String?,
      downloadUrl96: json['downloadUrl96'] as String?,
      downloadUrl160: json['downloadUrl160'] as String?,
      downloadUrl320: json['downloadUrl320'] as String?,
      hasLyrics: json['hasLyrics'] as bool? ?? false,
      year: json['year'] as String?,
      language: json['language'] as String?,
      label: json['label'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      localFilePath: json['localFilePath'] as String?,
      source: json['source'] as String? ?? 'JioSaavn',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artists': artists,
        'artistId': artistId,
        'album': album,
        'albumId': albumId,
        'durationSeconds': durationSeconds,
        'coverUrl': coverUrl,
        'mediaUrl': mediaUrl,
        'downloadUrl96': downloadUrl96,
        'downloadUrl160': downloadUrl160,
        'downloadUrl320': downloadUrl320,
        'hasLyrics': hasLyrics,
        'year': year,
        'language': language,
        'label': label,
        'isFavorite': isFavorite,
        'localFilePath': localFilePath,
        'source': source,
      };

  String get primaryArtist => artists.isNotEmpty ? artists.first : 'Unknown';
  String get artistString => artists.join(', ');
  String get bestDownloadUrl =>
      downloadUrl320 ?? downloadUrl160 ?? downloadUrl96 ?? mediaUrl ?? '';

  Song copyWith({
    String? id,
    String? title,
    List<String>? artists,
    String? artistId,
    String? album,
    String? albumId,
    int? durationSeconds,
    String? coverUrl,
    String? mediaUrl,
    String? downloadUrl96,
    String? downloadUrl160,
    String? downloadUrl320,
    bool? hasLyrics,
    String? year,
    String? language,
    String? label,
    bool? isFavorite,
    String? localFilePath,
    String? source,
  }) =>
      Song(
        id: id ?? this.id,
        title: title ?? this.title,
        artists: artists ?? this.artists,
        artistId: artistId ?? this.artistId,
        album: album ?? this.album,
        albumId: albumId ?? this.albumId,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        coverUrl: coverUrl ?? this.coverUrl,
        mediaUrl: mediaUrl ?? this.mediaUrl,
        downloadUrl96: downloadUrl96 ?? this.downloadUrl96,
        downloadUrl160: downloadUrl160 ?? this.downloadUrl160,
        downloadUrl320: downloadUrl320 ?? this.downloadUrl320,
        hasLyrics: hasLyrics ?? this.hasLyrics,
        year: year ?? this.year,
        language: language ?? this.language,
        label: label ?? this.label,
        isFavorite: isFavorite ?? this.isFavorite,
        localFilePath: localFilePath ?? this.localFilePath,
        source: source ?? this.source,
      );
}
