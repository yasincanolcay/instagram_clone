// ignore_for_file: unused_local_variable

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';
import 'package:instagram_clone/screens/posts/photo_description_screen.dart';
import 'package:instagram_clone/screens/posts/reels_description_page.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/crop_page.dart';
import 'package:instagram_clone/widgets/export_service.dart';
import 'package:instagram_clone/widgets/postwidgets/sheet_touch_button.dart';
import 'package:instagram_clone/widgets/videowidgets/export_result.dart';
import 'package:video_editor/video_editor.dart';
/*
api: 957237589686648
APİ secret: FF7bOxVtNuvQHZsG9y-sz-p4eF4
cloud name: dyauibzig
upload preset: bwyx9qsv
 */

class PostShareSheet extends StatelessWidget {
  PostShareSheet({super.key});
  final ImagePicker _picker = ImagePicker();

  void _pickVideo(BuildContext context) async {
    final XFile? file = await _picker.pickVideo(
      source: ImageSource.gallery,
    );

    if (context.mounted && file != null) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => VideoEditor(file: File(file.path)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SheetTouchButton(),
        ListTile(
          onTap: () async {
            // set picker theme based on app theme primary color
            final theme =
                InstaAssetPicker.themeData(Theme.of(context).primaryColor);
            final images = await InstaAssetPicker.pickAssets(
              context,
              pickerTheme: theme.copyWith(
                canvasColor: Colors.black, // body background color
                splashColor: Colors.grey, // ontap splash color
                colorScheme: theme.colorScheme.copyWith(
                  background: Colors.black87, // albums list background color
                ),
                appBarTheme: theme.appBarTheme.copyWith(
                  backgroundColor: Colors.black, // app bar background color
                  titleTextStyle: Theme.of(context)
                      .appBarTheme
                      .titleTextStyle
                      ?.copyWith(
                          color: Colors
                              .white), // change app bar title text style to be like app theme
                ),
                // edit `confirm` button style
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                    disabledForegroundColor: Colors.red,
                  ),
                ),
              ),
              onCompleted: (_) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PhotoDescriptionScreen(
                      photoStream: _,
                      editMode: false,
                      snap: null,
                    ),
                  ),
                );
              },
              title: "Gönderi Paylaşın",
            );
          },
          title: const Text("Gönderi Paylaş"),
          leading: const Icon(
            Icons.photo,
            color: textColor,
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
          ),
        ),
        const Divider(),
        ListTile(
          onTap: () {
            _pickVideo(context);
          },
          title: const Text("Reels Paylaş"),
          leading: const Icon(
            Icons.movie_filter,
            color: textColor,
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
          ),
        ),
        const Divider(),
        ListTile(
          onTap: () {},
          title: const Text("Hikaye Paylaş"),
          leading: const Icon(
            Icons.auto_awesome_rounded,
            color: textColor,
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
      ],
    );
  }
}

//-------------------//
//VIDEO EDITOR SCREEN//
//-------------------//
class VideoEditor extends StatefulWidget {
  const VideoEditor({super.key, required this.file});

  final File file;

  @override
  State<VideoEditor> createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VideoEditor> {
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  final double height = 60;

  late final VideoEditorController _controller = VideoEditorController.file(
    widget.file,
    minDuration: const Duration(seconds: 1),
    maxDuration: const Duration(minutes: 1),
  );

  bool _exported = false;
  String _exportText = "";
  int maxRetryCount = 5;
  int retryCount = 0;
  String coverPath = "";

  @override
  void initState() {
    super.initState();
    _controller
        .initialize(aspectRatio: 9 / 16)
        .then((_) => setState(() {}))
        .catchError((error) {
      // handle minumum duration bigger than video duration error
      Navigator.pop(context);
    }, test: (e) => e is VideoMinDurationError);
  }

  @override
  void dispose() async {
    _exportingProgress.dispose();
    _isExporting.dispose();
    _controller.dispose();
    ExportService.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 1),
        ),
      );

  void _exportVideo() async {
    String coverPathget = "";
    while (retryCount < maxRetryCount && coverPath.isEmpty) {
      coverPathget = await _exportCover(false);
      retryCount++;
    }
    _exportingProgress.value = 0;
    _isExporting.value = true;

    final config = VideoFFmpegVideoEditorConfig(
      _controller,
      // format: VideoExportFormat.gif,
      // commandBuilder: (config, videoPath, outputPath) {
      //   final List<String> filters = config.getExportFilters();
      //   filters.add('hflip'); // add horizontal flip

      //   return '-i $videoPath ${config.filtersCmd(filters)} -preset ultrafast $outputPath';
      // },
    );

    await ExportService.runFFmpegCommand(
      await config.getExecuteConfig(),
      onProgress: (stats) {
        _exportingProgress.value =
            config.getFFmpegProgress(stats.getTime().toInt());
      },
      onError: (e, s) => _showErrorSnackBar("Error on export video :("),
      onCompleted: (file) {
        _isExporting.value = false;
        if (!mounted) return;
        _exportText = "Video kaydedildi!";
        setState(() => _exported = true);
        if (coverPath.isNotEmpty) {
          Utils().showSnackBar("Videonuz yüklendikten sonra gönderilecek.",
              context, backgroundColor);
          Future.delayed(const Duration(seconds: 2),
              () => setState(() => _exported = false));
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ReelsDescriptionScreen(
                videoFile: file,
                snap: null,
                editMode: false,
                thumbnail: coverPathget,
              ),
            ),
          );
        } else {
          Utils().showSnackBar(
              "Kapak fotoğrafı oluşturulamadı lütfen tekrar deneyin!",
              context,
              backgroundColor);
        }
      },
    );
  }

  Future<String> _exportCover(bool showImage) async {
    final config = CoverFFmpegVideoEditorConfig(_controller);
    final execute = await config.getExecuteConfig();
    if (execute == null) {
      _showErrorSnackBar("Error on cover exportation initialization.");
    }
    await ExportService.runFFmpegCommand(
      execute!,
      onError: (e, s) => _showErrorSnackBar("Error on cover exportation :("),
      onCompleted: (cover) {
        setState(() {
          final path = cover.path;
          coverPath = path;
        });
        if (!mounted) return;
        if (showImage) {
          showDialog(
            context: context,
            builder: (_) => Padding(
              padding: const EdgeInsets.all(30),
              child: Center(child: Image.memory(cover.readAsBytesSync())),
            ),
          );
        }

        setState(() => _exported = true);
        Future.delayed(
          const Duration(seconds: 2),
          () => setState(() => _exported = false),
        );
      },
    );
    return coverPath;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: _controller.initialized
            ? SafeArea(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        _topNavBar(),
                        Expanded(
                          child: DefaultTabController(
                            length: 2,
                            child: Column(
                              children: [
                                Expanded(
                                  child: TabBarView(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    children: [
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          CropGridViewer.preview(
                                              controller: _controller),
                                          AnimatedBuilder(
                                            animation: _controller.video,
                                            builder: (_, __) => AnimatedOpacity(
                                              opacity:
                                                  _controller.isPlaying ? 0 : 1,
                                              duration: kThemeAnimationDuration,
                                              child: GestureDetector(
                                                onTap: _controller.video.play,
                                                child: Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.play_arrow,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      CoverViewer(controller: _controller)
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 200,
                                  margin: const EdgeInsets.only(top: 10),
                                  child: Column(
                                    children: [
                                      const TabBar(
                                        tabs: [
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                    padding: EdgeInsets.all(5),
                                                    child: Icon(
                                                        Icons.content_cut)),
                                                Text('Kes')
                                              ]),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                  padding: EdgeInsets.all(5),
                                                  child:
                                                      Icon(Icons.video_label)),
                                              Text('Kapak')
                                            ],
                                          ),
                                        ],
                                      ),
                                      Expanded(
                                        child: TabBarView(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: _trimSlider(),
                                            ),
                                            _coverSelection(),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ValueListenableBuilder(
                                  valueListenable: _isExporting,
                                  builder: (_, bool export, Widget? child) =>
                                      AnimatedSize(
                                    duration: kThemeAnimationDuration,
                                    child: export ? child : null,
                                  ),
                                  child: AlertDialog(
                                    title: ValueListenableBuilder(
                                      valueListenable: _exportingProgress,
                                      builder: (_, double value, __) => Text(
                                        "Video işleniyor ${(value * 100).ceil()}%",
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _topNavBar() {
    return SafeArea(
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            Expanded(
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.exit_to_app),
                tooltip: 'Geri Git',
              ),
            ),
            const VerticalDivider(endIndent: 22, indent: 22),
            Expanded(
              child: IconButton(
                onPressed: () =>
                    _controller.rotate90Degrees(RotateDirection.left),
                icon: const Icon(Icons.rotate_left),
                tooltip: 'Sola Döndür',
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () =>
                    _controller.rotate90Degrees(RotateDirection.right),
                icon: const Icon(Icons.rotate_right),
                tooltip: 'Sağa Döndür',
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => CropPage(controller: _controller),
                  ),
                ),
                icon: const Icon(Icons.crop),
                tooltip: 'Kırp',
              ),
            ),
            const VerticalDivider(endIndent: 22, indent: 22),
            Expanded(
              child: PopupMenuButton(
                tooltip: 'Open export menu',
                icon: const Icon(Icons.send),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    onTap: () {
                      _exportCover(true);
                    },
                    child: const Text('Kapak Kaydet'),
                  ),
                  PopupMenuItem(
                    onTap: _exportVideo,
                    child: const Text('Paylaş'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatter(Duration duration) => [
        duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
        duration.inSeconds.remainder(60).toString().padLeft(2, '0')
      ].join(":");

  List<Widget> _trimSlider() {
    return [
      AnimatedBuilder(
        animation: Listenable.merge([
          _controller,
          _controller.video,
        ]),
        builder: (_, __) {
          final int duration = _controller.videoDuration.inSeconds;
          final double pos = _controller.trimPosition * duration;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: height / 4),
            child: Row(children: [
              Text(formatter(Duration(seconds: pos.toInt()))),
              const Expanded(child: SizedBox()),
              AnimatedOpacity(
                opacity: _controller.isTrimming ? 1 : 0,
                duration: kThemeAnimationDuration,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(formatter(_controller.startTrim)),
                  const SizedBox(width: 10),
                  Text(formatter(_controller.endTrim)),
                ]),
              ),
            ]),
          );
        },
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(vertical: height / 4),
        child: TrimSlider(
          controller: _controller,
          height: height,
          horizontalMargin: height / 4,
          child: TrimTimeline(
            controller: _controller,
            padding: const EdgeInsets.only(top: 10),
          ),
        ),
      )
    ];
  }

  Widget _coverSelection() {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(15),
          child: CoverSelection(
            controller: _controller,
            size: height + 10,
            quantity: 8,
            selectedCoverBuilder: (cover, size) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  cover,
                  Icon(
                    Icons.check_circle,
                    color: const CoverSelectionStyle().selectedBorderColor,
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
