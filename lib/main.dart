import 'dart:io';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(MyApp());

class HYSizeFit {
  static MediaQueryData _mediaQueryData;
  static double screenWidth;
  static double screenHeight;
  static double rpx;
  static double px;

  static void initialize(BuildContext context, {double standardWidth = 750}) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    rpx = screenWidth / standardWidth;
    px = screenWidth / standardWidth * 2;
  }
  
  static double setPx(double size) {
    return HYSizeFit.rpx * size * 2;
  }
  
  static double setRpx(double size) {
    return HYSizeFit.rpx * size;
  }
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Album 571'),
    );
  }
}

List _imageFile = [];

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class DetailScreen extends StatelessWidget {
  final int title;

  DetailScreen({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HYSizeFit.initialize(context);

    Image image = new Image.asset(_imageFile[title]);
    Completer<ui.Image> completer = new Completer<ui.Image>();
    image.image.resolve(new ImageConfiguration()).addListener(
        ImageStreamListener(
            (ImageInfo info, bool _) => completer.complete(info.image)));

    return Scaffold(
      appBar: AppBar(
        title: Text("Album 571"),
      ),
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: ConstrainedBox(
          constraints: BoxConstraints.expand(height: HYSizeFit.setPx(650.0)),
          child: 
          Center(
            child: Container(
              child: Image.asset(
                _imageFile[title],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: FutureBuilder<ui.Image>(
          future: completer.future,
          builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
            if (snapshot.hasData) {
              return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("image width: ${snapshot.data.width} px",
                        style: TextStyle(fontSize: HYSizeFit.setPx(20.0))),
                    Text("image height: ${snapshot.data.height} px",
                        style: TextStyle(fontSize: HYSizeFit.setPx(20.0))),
                    Text("    "),
                  ]);
            } else {
              return new Text('Loading...');
            }
          }),
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  

  Future<void> captureImage(ImageSource imageSource) async {
    try {
      final imageFile = await ImagePicker.pickImage(source: imageSource);
      setState(() {
        _imageFile.addAll([imageFile.path]);
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    HYSizeFit.initialize(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        height: HYSizeFit.setPx(650.0),
        child: GridView.builder(
            itemCount: _imageFile?.length ?? 0,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.0,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DetailScreen(title: index)));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      _imageFile[index],
                      fit: BoxFit.cover,
                      width: 100,
                      height: 100,
                    ),
                  ));
            }),
      ),
      bottomNavigationBar: _buildButtons(),
    );
  }

  Widget _buildButtons() {
    return ConstrainedBox(
        constraints: BoxConstraints.expand(height: 80.0),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildActionButton(
                key: Key('retake'),
                text: " Add from Photo",
                onPressed: () => captureImage(ImageSource.gallery),
                data: Icons.perm_media,
              ),
              _buildActionButton(
                key: Key('upload'),
                text: " Use Camera",
                onPressed: () => captureImage(ImageSource.camera),
                data: Icons.camera_alt,
              ),
            ]));
  }

  Widget _buildActionButton(
      {Key key, String text, Function onPressed, IconData data}) {
    return Expanded(
      child: FlatButton(
          key: key,
          child: Row(children: [
            Text("   "),
            Icon(data),
            Text(text, style: TextStyle(fontSize: HYSizeFit.setPx(15)))
          ]),
          shape: RoundedRectangleBorder(),
          color: Colors.blueAccent,
          textColor: Colors.white,
          onPressed: onPressed),
    );
  }
}
