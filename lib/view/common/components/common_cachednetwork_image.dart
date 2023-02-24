import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:okoto/configs/styles.dart';
import 'package:shimmer/shimmer.dart';

class CommonCachedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double borderRadius;
  final double? height,width;

  const CommonCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.borderRadius=0,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ClipRRect(
        borderRadius:
        BorderRadius.circular(borderRadius),
        child: CachedNetworkImage(
          imageUrl:  imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, _) {
            return Shimmer.fromColors(
              baseColor: Styles.shimmerBaseColor,
              highlightColor: Styles.shimmerHighlightColor,
              child: Container(
                alignment: Alignment.center,
                color: Styles.shimmerContainerColor,
                child: const Icon(
                  Icons.image,
                  size: 20,
                ),
              ),
            );
          },
          errorWidget: (___, __, _) => Container(
            color: Colors.grey[200],
            child: Icon(
              Icons.image_outlined,
              color: Colors.grey[400],
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
