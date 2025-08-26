import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logize/features/feature_widget.dart';
import 'package:logize/features/picture/picture_ft_class.dart';
import 'package:logize/widgets/design/button.dart';
import 'package:logize/widgets/design/txt_field.dart';

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
                  child: Image.file(
                    File(ft.tmpFile?.path ?? ft.path!),
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    width: double.infinity,
                    height: lock.record ? 200 : null,
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
                        lead: MdiIcons.viewGallery,
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
