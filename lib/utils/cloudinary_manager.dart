import 'dart:io';
import 'dart:typed_data';

import 'package:cloudinary_sdk/cloudinary_sdk.dart';

import '../configs/cloudinary_api_keys.dart';
import '../configs/constants.dart';
import 'my_print.dart';
import 'my_utils.dart';

class CloudinaryManager {
  static final CloudinaryManager _instance = CloudinaryManager._();

  factory CloudinaryManager() => _instance;

  late Cloudinary cloudinary;

  CloudinaryManager._() {
    cloudinary = Cloudinary.full(
      apiKey: CloudinaryApiKeys.getCloudinaryApiKey(),
      apiSecret: CloudinaryApiKeys.getCloudinaryApiSecret(),
      cloudName: CloudinaryApiKeys.getCloudinaryCloudName(),
    );
  }

  Future<CloudinaryResponse?> uploadResource({required CloudinaryUploadResource resourceToUpload}) async {
    CloudinaryResponse? cloudinaryResponse;
    try {
      cloudinaryResponse = await cloudinary.uploadResource(resourceToUpload);
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in CloudinaryManager._uploadResource():$e");
      MyPrint.printOnConsole(s);
    }

    return cloudinaryResponse;
  }

  Future<List<CloudinaryResponse>> uploadResources({required List<CloudinaryUploadResource> resourcesToUpload}) async {
    List<CloudinaryResponse> cloudinaryResponse = [];
    try {
      cloudinaryResponse = await cloudinary.uploadResources(resourcesToUpload);
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in CloudinaryManager._uploadResources():$e");
      MyPrint.printOnConsole(s);
    }

    return cloudinaryResponse;
  }

  // Future<String> uploadBussinessImage({required String bussinessId, required File image}) async {
  //   Uint8List bytes = Uint8List(0);
  //
  //   try {
  //     bytes = await image.readAsBytes();
  //   }
  //   catch(e) {}
  //
  //   String name = MyUtils.getUniqueId();
  //
  //   CloudinaryResponse? response = await uploadResource(resourceToUpload: CloudinaryUploadResource(
  //     resourceType: CloudinaryResourceType.image,
  //     folder: CloudinaryFoldersName.bussinesses,
  //     fileName: "${bussinessId}_$name",
  //     fileBytes: bytes,
  //   ));
  //
  //   if(response != null && response.isSuccessful && response.isResultOk && (response.url ?? "").isNotEmpty) {
  //     return response.url!;
  //   }
  //
  //   return "";
  // }
  //
  // Future<bool> deleteImagesFromCloudinary({required List<String> images}) async {
  //   images.removeWhere((element) => element.isEmpty);
  //   if(images.isEmpty) {
  //     return true;
  //   }
  //
  //   try {
  //     CloudinaryResponse cloudinaryResponse = await cloudinary.deleteResources(cloudinaryImages: images.map((e) => CloudinaryImage(e)).toList());
  //     return cloudinaryResponse.isSuccessful && cloudinaryResponse.isResultOk;
  //   }
  //   catch(e, s) {
  //     MyPrint.printOnConsole("Error in Deleting images from cloudinary:$e");
  //     MyPrint.printOnConsole(s);
  //     return false;
  //   }
  // }
  //
  //
  // //region Transformations
  // static String transformImageUrlForWallpaperWidget(String imageUrl) {
  //   if(!isCloudinaryImage(imageUrl)) return imageUrl;
  //
  //   try {
  //     String transformedImage = CloudinaryImage(imageUrl)
  //         .transform()
  //         .height(CloudinaryImageResize.wallpaperSize)
  //         .scale()
  //         .generate() ?? imageUrl;
  //     transformedImage = CloudinaryManager.fixCloudinaryImageUrlIssue(imageUrl, transformedImage);
  //     return transformedImage;
  //   }
  //   catch(e, s) {
  //     MyPrint.printOnConsole("Error in Transforming image '$imageUrl' For Wallpaper Widget:$e");
  //     MyPrint.printOnConsole(s);
  //     // AnalyticsController().recordError(e, s, reason: "Error in Transforming image For Wallpaper Widget");
  //     return imageUrl;
  //   }
  // }
  //
  // static String transformImageUrlForSelectedWallpaperWidgetInWallpaperListScreen(String imageUrl) {
  //   return imageUrl;
  //   // try {
  //   //   String transformedImage = CloudinaryImage(imageUrl)
  //   //       .transform()
  //   //       .height(CloudinaryImageResize.selectedWallpaperSize)
  //   //       .scale()
  //   //       .generate() ?? imageUrl;
  //   //   transformedImage = CloudinaryManager.fixCloudinaryImageUrlIssue(imageUrl, transformedImage);
  //   //   return transformedImage;
  //   // }
  //   // catch(e, s) {
  //   //   MyPrint.printOnConsole("Error in Transforming image For Selected Wallpaper Widget in WallpaperListScreen:$e");
  //   //   MyPrint.printOnConsole(s);
  //   //   AnalyticsController().recordError(e, s, reason: "Error in Transforming image For Selected Wallpaper Widget in WallpaperListScreen");
  //   //   return imageUrl;
  //   // }
  // }
  //
  // static String transformImageUrlForFrameWidget(String imageUrl) {
  //   if(!isCloudinaryImage(imageUrl)) {
  //     MyPrint.printOnConsole("Frame Url is not a cloudinary image");
  //     return imageUrl;
  //   }
  //
  //   try {
  //     String transformedImage = CloudinaryImage(imageUrl)
  //         .transform()
  //         .height(CloudinaryImageResize.frameSize)
  //         .scale()
  //         .generate() ?? imageUrl;
  //     transformedImage = CloudinaryManager.fixCloudinaryImageUrlIssue(imageUrl, transformedImage);
  //     return transformedImage;
  //   }
  //   catch(e, s) {
  //     MyPrint.printOnConsole("Error in Transforming image '$imageUrl' For Wallpaper Widget:$e");
  //     MyPrint.printOnConsole(s);
  //     // AnalyticsController().recordError(e, s, reason: "Error in Transforming image For Wallpaper Widget");
  //     return imageUrl;
  //   }
  // }
  //
  // static String transformImageUrlForPlanWidget(String imageUrl) {
  //   if(!isCloudinaryImage(imageUrl)) return imageUrl;
  //
  //   try {
  //     String transformedImage = CloudinaryImage(imageUrl)
  //         .transform()
  //         .height(CloudinaryImageResize.planSizeHeight)
  //         .width(CloudinaryImageResize.planSizeWidth)
  //         .scale()
  //         .generate() ?? imageUrl;
  //     transformedImage = CloudinaryManager.fixCloudinaryImageUrlIssue(imageUrl, transformedImage);
  //     return transformedImage;
  //   }
  //   catch(e, s) {
  //     MyPrint.printOnConsole("Error in Transforming image '$imageUrl' For Wallpaper Widget:$e");
  //     MyPrint.printOnConsole(s);
  //     // AnalyticsController().recordError(e, s, reason: "Error in Transforming image For Wallpaper Widget");
  //     return imageUrl;
  //   }
  // }
  //
  // static String transformImageUrlForCategoryWidget(String imageUrl, {bool isLarge = false}) {
  //   if(!isCloudinaryImage(imageUrl)) return imageUrl;
  //
  //   int size = isLarge ? CloudinaryImageResize.categoryImageSizeBig : CloudinaryImageResize.categoryImageSize;
  //
  //   try {
  //     String transformedImage = CloudinaryImage(imageUrl)
  //         .transform()
  //         .height(size)
  //         .width(size)
  //         .scale()
  //         .generate() ?? imageUrl;
  //     transformedImage = CloudinaryManager.fixCloudinaryImageUrlIssue(imageUrl, transformedImage);
  //     return transformedImage;
  //   }
  //   catch(e, s) {
  //     MyPrint.printOnConsole("Error in Transforming image '$imageUrl' For Wallpaper Widget:$e");
  //     MyPrint.printOnConsole(s);
  //     // AnalyticsController().recordError(e, s, reason: "Error in Transforming image For Wallpaper Widget");
  //     return imageUrl;
  //   }
  // }
  //
  // static String transformImageUrlForSubcategoryWidget(String imageUrl, {bool isLarge = false}) {
  //   if(!isCloudinaryImage(imageUrl)) return imageUrl;
  //
  //   int size = isLarge ? CloudinaryImageResize.subcategoryImageSizeBig : CloudinaryImageResize.subcategoryImageSize;
  //
  //   try {
  //     String transformedImage = CloudinaryImage(imageUrl)
  //         .transform()
  //         .height(size)
  //         .width(size)
  //         .scale()
  //         .generate() ?? imageUrl;
  //     transformedImage = CloudinaryManager.fixCloudinaryImageUrlIssue(imageUrl, transformedImage);
  //     return transformedImage;
  //   }
  //   catch(e, s) {
  //     MyPrint.printOnConsole("Error in Transforming image '$imageUrl' For Wallpaper Widget:$e");
  //     MyPrint.printOnConsole(s);
  //     // AnalyticsController().recordError(e, s, reason: "Error in Transforming image For Wallpaper Widget");
  //     return imageUrl;
  //   }
  // }

  static String fixCloudinaryImageUrlIssue(String originalImageUrl, String newImageUrl) {
    String fileFullName = originalImageUrl.substring(originalImageUrl.lastIndexOf("/") + 1);
    // MyPrint.printOnConsole("fileFullName '$fileFullName'");
    String fileName = fileFullName.substring(0, fileFullName.lastIndexOf("."));
    // MyPrint.printOnConsole("Name '$fileName' Contains Dot:${fileName.contains(("."))}");
    // newImageUrl = newImageUrl.substring(0, newImageUrl.lastIndexOf(fileName));
    // newImageUrl = newImageUrl + fileFullName;
    if(fileName.contains(("."))) {
      newImageUrl = newImageUrl.substring(0, newImageUrl.lastIndexOf(fileName));
      newImageUrl = newImageUrl + fileFullName;
    }
    else {
      // newImageUrl = newImageUrl.substring(0, newImageUrl.lastIndexOf(fileName));
      // newImageUrl = newImageUrl + fileFullName;
    }

    return newImageUrl;
  }

  static bool isCloudinaryImage(String imageUrl) {
    return imageUrl.contains("res.cloudinary.com");
  }
  //endregion
}