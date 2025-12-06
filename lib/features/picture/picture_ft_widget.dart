import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logbloc/features/feature_widget.dart';
import 'package:logbloc/features/picture/picture_ft_class.dart';
import 'package:logbloc/widgets/design/button.dart';
import 'package:logbloc/widgets/design/txt_field.dart';

class PictureFtWidget extends StatelessWidget {
  final PictureFt ft;
  final FeatureLock lock;
  final bool detailed;
  final void Function()? dirt;
  PictureFtWidget({
    super.key,
    required this.ft,
    required this.lock,
    required this.detailed,
    this.dirt,
  });

  final picker = ImagePicker();

  void _showFullscreenImage(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    color: Colors.black,
                    child: FutureBuilder<Size>(
                      future: _getImageSize(File(ft.tmpFile?.path ?? ft.path!)),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final imageSize = snapshot.data!;
                          final screenWidth = MediaQuery.of(context).size.width;
                          final screenHeight = MediaQuery.of(
                            context,
                          ).size.height;

                          // Determine if image is vertical or horizontal
                          final isVertical = imageSize.height > imageSize.width;

                          return InteractiveViewer(
                            panEnabled: true,
                            boundaryMargin: EdgeInsets.all(20),
                            minScale: 0.5,
                            maxScale: 4.0,
                            child: Center(
                              child: SizedBox(
                                width: isVertical ? null : screenWidth,
                                height: isVertical ? screenHeight : null,
                                child: Image.file(
                                  File(ft.tmpFile?.path ?? ft.path!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        }

                        // Fallback while loading
                        return Center(
                          child: Image.file(
                            File(ft.tmpFile?.path ?? ft.path!),
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Size> _getImageSize(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return Size(frame.image.width.toDouble(), frame.image.height.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        pickImg(ImageSource source) async {
          final img = await picker.pickImage(source: source);
          if (img != null) {
            ft.setFile(img);
            dirt!();
            setState(() {});
          }
        }

        return Column(
          children: [
            if (!lock.model)
              TxtField(
                label: 'title',
                round: true,
                onChanged: (str) => ft.setTitle(str),
                validator: (str) =>
                    str?.isNotEmpty != true ? 'write a title' : null,
                initialValue: ft.title,
              ),

            if (ft.tmpFile != null || ft.path != null)
              Padding(
                padding: EdgeInsetsGeometry.only(top: 10),
                child: ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(20),
                  child: GestureDetector(
                    onTap: () => _showFullscreenImage(context),
                    child: Image.file(
                      File(ft.tmpFile?.path ?? ft.path!),
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      width: double.infinity,
                      height: lock.record ? 200 : null,
                    ),
                  ),
                ),
              ),

            if (!lock.record)
              Padding(
                padding: EdgeInsetsGeometry.all(10),
                child: Row(
                  children: [
                    Expanded(
                      child: Button(
                        'from gallery',
                        lead: MdiIcons.folderMultipleImage,
                        filled: false,
                        onPressed: () => pickImg(ImageSource.gallery),
                      ),
                    ),
                    Expanded(
                      child: Button(
                        'from camera',
                        filled: false,
                        lead: MdiIcons.camera,
                        onPressed: () => pickImg(ImageSource.camera),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
