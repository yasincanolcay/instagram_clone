import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/global_class.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class PostCard extends StatefulWidget {
  const PostCard({
    super.key,
    required this.snap,
  });
  final snap;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool showMore = false;
  double photoCurrentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            dense: true,
            leading: const CircleAvatar(),
            title: const Text("Username"),
            subtitle: const Text("Türkiye/İzmir 255 sk"),
            trailing: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.more_vert_rounded,
              ),
            ),
          ),
          ExpandablePageView(
            onPageChanged: (value) {
              setState(() {
                photoCurrentIndex = value.toDouble();
              });
            },
            children: List.generate(
              widget.snap["contentUrl"].length,
              (index) => CachedNetworkImage(
                cacheManager: GlobalClass.customCacheManager,
                key: UniqueKey(),
                memCacheHeight: 800,
                imageUrl: widget.snap['contentUrl'][index],
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                errorWidget: (context, error, stackTrace) {
                  return Center(
                    child: Image.asset(
                      'assets/images/error.png',
                      fit: BoxFit.cover,
                      width: 100,
                      height: 100,
                    ),
                  );
                },
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    Center(
                  child: CircularProgressIndicator(
                    value: downloadProgress.progress,
                  ),
                ),
              ),
            ),
          ),
          const Divider(
            thickness: 0.0,
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  CupertinoIcons.heart,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  CupertinoIcons.text_bubble,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Transform.rotate(
                  angle: -0.8,
                  child: const Icon(
                    Icons.send_rounded,
                  ),
                ),
              ),
              const Spacer(),
              SmoothIndicator(
                offset: photoCurrentIndex, //değişim yapıacagız
                count: widget.snap["contentUrl"].length,
                size: const Size(10, 10),
                effect: const ScrollingDotsEffect(
                    activeDotColor: textColor,
                    activeStrokeWidth: 0.5,
                    dotHeight: 8,
                    dotWidth: 8,
                    fixedCenter: true),
              ),
              const Spacer(
                flex: 2,
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  CupertinoIcons.bookmark,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              child: RichText(
                softWrap: true,
                overflow:
                    !showMore ? TextOverflow.ellipsis : TextOverflow.visible,
                maxLines: !showMore ? 3 : null,
                text: TextSpan(children: [
                  const TextSpan(
                    text: "Username ",
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: widget.snap['description'],
                    style: const TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ]),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: () {
                setState(() {
                  showMore = !showMore;
                });
              },
              child: Text(!showMore ? "Daha Fazla" : "Daha Az"),
            ),
          ),
          const Divider(
            thickness: 0.0,
          ),
        ],
      ),
    );
  }
}
