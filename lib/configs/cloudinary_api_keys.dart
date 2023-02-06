//Cloudinary Api Credentials

class CloudinaryApiKeys {
  //Dev Api Keys
  static const String _devApiKey = "474835272926228";
  static const String _devApiSecret = "jMdoD_6ae1r8H5-mzI2wt30YGJE";
  static const String _devCloudName = "dxegfkhzd";

  //Prod Api Keys
  static const String _prodApiKey = "877567553366299";
  static const String _prodApiSecret = "0I6VTL6nAz9r67Huqjv3eFGC8uE";
  static const String _prodCloudName = "dgzhgnyuo";

  static String getCloudinaryApiKey({bool isDev = true}) {
    return isDev ? _devApiKey : _prodApiKey;
  }

  static String getCloudinaryApiSecret({bool isDev = true}) {
    return isDev ? _devApiSecret : _prodApiSecret;
  }

  static String getCloudinaryCloudName({bool isDev = true}) {
    return isDev ? _devCloudName : _prodCloudName;
  }
}