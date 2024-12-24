import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:image_picker/image_picker.dart';
import 'package:knkpanime/models/image_set.dart';
import 'package:knkpanime/pages/settings/settings_controller.dart';
import 'package:knkpanime/utils/storage.dart';

class ImageSetConfigPage extends StatefulWidget {
  const ImageSetConfigPage({super.key});

  @override
  State<ImageSetConfigPage> createState() => _ImageSetConfigPageState();
}

class _ImageSetConfigPageState extends State<ImageSetConfigPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择图片组'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Modular.to.pop();
          },
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Row(
              children: [
                const Text('默认图片组'),
                if (SettingsController().customImageSet == null)
                  const Icon(Icons.check),
              ],
            ),
            onTap: () {
              SettingsController().customImageSet = null;
              Modular.to.pop();
            },
          ),
          ...Storage.imageSets.keys.map((imageSetName) => ListTile(
                title: Row(
                  children: [
                    Text(imageSetName),
                    if (SettingsController().customImageSet == imageSetName)
                      const Icon(Icons.check),
                  ],
                ),
                onTap: () {
                  SettingsController().customImageSet = imageSetName;
                  Modular.to.pop();
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    Storage.imageSets.delete(imageSetName);
                    if (SettingsController().customImageSet == imageSetName) {
                      SettingsController().customImageSet = null;
                    }
                    setState(() {});
                  },
                ),
              )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _createImageSet(context);
          setState(() {
            // Refresh the list of image sets
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<List<File?>> _createImageSet(BuildContext context) async {
    final List<File?> selectedImages = [null, null, null];
    final titles = ['导航栏背景图', '封面加载占位图', '无封面占位图'];
    String? imageSetName;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            Future<void> pickImage(int index) async {
              final ImagePicker picker = ImagePicker();
              final XFile? image =
                  await picker.pickImage(source: ImageSource.gallery);

              if (image != null) {
                setState(() {
                  selectedImages[index] = File(image.path);
                });
              }
            }

            return Dialog(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height * 0.75,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    TextFormField(
                      onChanged: (value) =>
                          setState(() => imageSetName = value.trim()),
                      decoration: const InputDecoration(
                        labelText: "图片组名称",
                        border: InputBorder.none,
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: selectedImages[index] == null
                                ? const Icon(Icons.image, size: 40)
                                : Image.file(
                                    selectedImages[index]!,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  ),
                            title: Text(titles[index]),
                            trailing: ElevatedButton(
                              onPressed: () => pickImage(index),
                              child: const Text('选择图片'),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Modular.to.pop(context),
                          child: const Text('取消'),
                        ),
                        TextButton(
                          onPressed: selectedImages.contains(null) ||
                                  imageSetName == null ||
                                  Storage.imageSets.keys.contains(imageSetName!)
                              ? null
                              : () {
                                  final newImageSet = ImageSet(
                                      selectedImages[0]!.readAsBytesSync(),
                                      selectedImages[1]!.readAsBytesSync(),
                                      selectedImages[2]!.readAsBytesSync());
                                  Storage.imageSets
                                      .put(imageSetName!, newImageSet);
                                  Modular.to.pop(context);
                                },
                          child: const Text('确认'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    return selectedImages;
  }
}
