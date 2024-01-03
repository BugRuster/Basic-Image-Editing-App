import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Celebrare Assignment',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ImageEditorScreen(),
    );
  }
}

enum FontStyleOption {
  arial,
  timesNewRoman,
}

Map<FontStyleOption, String> fontStyleMap = {
  FontStyleOption.arial: 'Arial',
  FontStyleOption.timesNewRoman: 'Times New Roman',
};

class ImageEditorScreen extends StatefulWidget {
  @override
  _ImageEditorScreenState createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  File? _selectedImage;
  TextEditingController _textEditingController = TextEditingController();
  Offset _textOffset = Offset(50, 50); // Initial text position
  bool _isDragging = false;
  late Offset _lastPosition;
  Color _selectedColor = Colors.white; // Default color
  double _textSize = 24; // Default text size
  FontStyleOption _selectedFontStyle = FontStyleOption.arial; // Default font style

  Future<void> _selectImage() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedImage != null) {
        _selectedImage = File(pickedImage.path);
      }
    });
  }

  img.Image? _editImage(img.Image image) {
    if (_selectedImage == null) {
      return null;
    }

    final textStyle = _getTextStyle();
    img.drawString(
      image,
      img.arial_24,
      _textOffset.dx.toInt(),
      _textOffset.dy.toInt(),
      _textEditingController.text,
      color: img.getColor(
        textStyle.color!.red,
        textStyle.color!.green,
        textStyle.color!.blue,
      ),
    );

    return image;
  }

  TextStyle _getTextStyle() {
    switch (_selectedFontStyle) {
      case FontStyleOption.arial:
        return TextStyle(
          fontSize: _textSize,
          color: _selectedColor,
          fontFamily: 'Arial',
        );
      case FontStyleOption.timesNewRoman:
        return TextStyle(
          fontSize: _textSize,
          color: _selectedColor,
          fontFamily: 'Times New Roman',
        );
      default:
        return TextStyle(
          fontSize: _textSize,
          color: _selectedColor,
        );
    }
  }

  void _changeColor(Color color) {
    setState(() {
      _selectedColor = color;
    });
  }

  void _addTextToImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Text'),
          content: TextFormField(
            controller: _textEditingController,
            decoration: InputDecoration(
              labelText: 'Enter text',
              border: OutlineInputBorder(),
            ),
            onFieldSubmitted: (String value) {
              Navigator.of(context).pop();
              _applyTextToImage();
            },
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _applyTextToImage();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _applyTextToImage() {
    setState(() {
      // Add logic to apply text to the image
      final image = img.decodeImage(_selectedImage!.readAsBytesSync());
      final editedImage = _editImage(image!);
      if (editedImage != null) {
        Uint8List uint8list = Uint8List.fromList(img.encodeJpg(editedImage));
        // Display the edited image directly on the screen
        // Adjust the width and height as per your requirement
        Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.5,
          child: Image.memory(uint8list),
        );
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Celebrare Assignment'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: _selectImage,
                child: _selectedImage != null
                    ? Stack(
                  children: [
                    Container(
                      color: Colors.grey,
                      child: Image.file(_selectedImage!),
                    ),
                    Positioned(
                      left: _textOffset.dx,
                      top: _textOffset.dy,
                      child: GestureDetector(
                        onPanStart: (details) {
                          setState(() {
                            _isDragging = true;
                            _lastPosition = details.globalPosition - _textOffset;
                          });
                        },
                        onPanUpdate: (details) {
                          setState(() {
                            if (_isDragging) {
                              _textOffset = details.globalPosition - _lastPosition;
                            }
                          });
                        },
                        onPanEnd: (_) {
                          setState(() {
                            _isDragging = false;
                          });
                        },
                        child: Text(
                          _textEditingController.text,
                          style: _getTextStyle(),
                        ),
                      ),
                    ),
                  ],
                )
                    : Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey,
                  child: Icon(Icons.add_a_photo, size: 50),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: Slider(
                  value: _textSize,
                  min: 10,
                  max: 40,
                  divisions: 30,
                  label: _textSize.round().toString(),
                  onChanged: (double value) {
                    setState(() {
                      _textSize = value;
                    });
                  },
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                _addTextToImage(context);
              },
              child: Text('Add Text'),
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Pick a color'),
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: _selectedColor,
                          onColorChanged: _changeColor,
                          showLabel: true,
                          pickerAreaHeightPercent: 0.8,
                        ),
                      ),
                    );
                  },
                );
              },
              child: Text('Color'),
            ),
            DropdownButton<FontStyleOption>(
              value: _selectedFontStyle,
              onChanged: (FontStyleOption? newValue) {
                setState(() {
                  if (newValue != null) {
                    _selectedFontStyle = newValue;
                  }
                });
              },
              items: fontStyleMap.entries.map<DropdownMenuItem<FontStyleOption>>((entry) {
                return DropdownMenuItem<FontStyleOption>(
                  value: entry.key,
                  child: Text(fontStyleMap[entry.key]!),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
