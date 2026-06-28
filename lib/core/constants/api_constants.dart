class ApiConstants {
  ApiConstants._();

  // JioSaavn public API (saavn.echomusic.fun)
  static const String jiosaavnBaseUrl = 'https://saavn.me';

  // Endpoints
  static const String searchSongs = '/search/songs';
  static const String searchAlbums = '/search/albums';
  static const String searchArtists = '/search/artists';
  static const String searchPlaylists = '/search/playlists';
  static const String searchAll = '/search';
  static const String songDetails = '/songs';
  static const String albumDetails = '/albums';
  static const String artistDetails = '/artists';
  static const String playlistDetails = '/playlists';
  static const String lyrics = '/lyrics';

  // Timeouts (milliseconds)
  static const int connectTimeout = 10000;
  static const int receiveTimeout = 15000;

  // Quality
  static const String quality96kbps = '96kbps';
  static const String quality160kbps = '160kbps';
  static const String quality320kbps = '320kbps';
}
