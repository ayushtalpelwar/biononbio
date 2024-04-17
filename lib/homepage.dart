import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:developer' as dev;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  File? filepath;
  String label='';
  double confidence=0.0;

  pickphoto() async{
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if(image==null) return;

    var imageMap = File(image.path);

    setState(() {
      filepath=imageMap;
    });

    var recognitions = await Tflite.runModelOnImage(
        path: image.path,   // required
        imageMean: 0.0,   // defaults to 117.0
        imageStd: 255.0,  // defaults to 1.0
        numResults: 2,    // defaults to 5
        threshold: 0.2,   // defaults to 0.1
        asynch: true      // defaults to true
    );

    if(recognitions==null){
      dev.log('recognitions is null');
    }
    dev.log(recognitions.toString());
    setState(() {
      confidence=(recognitions![0]['confidence'])*100;
      label=recognitions[0]['label'].toString();
    });
  }

  pickImageGallery() async{
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if(image==null) return;

    var imageMap = File(image.path);

    setState(() {
      filepath=imageMap;
    });

    var recognitions = await Tflite.runModelOnImage(
        path: image.path,   // required
        imageMean: 0.0,   // defaults to 117.0
        imageStd: 255.0,  // defaults to 1.0
        numResults: 2,    // defaults to 5
        threshold: 0.2,   // defaults to 0.1
        asynch: true      // defaults to true
    );

    if(recognitions==null){
      dev.log('recognitions is null');
    }
    dev.log(recognitions.toString());
    setState(() {
      confidence=(recognitions![0]['confidence'])*100;
      label=recognitions[0]['label'].toString();
    });
  }


  Future<void> _tfliteInit() async{
    String? res = await Tflite.loadModel(
        model: "assets/model_unquant.tflite",
        labels: "assets/labels.txt",
        numThreads: 1, // defaults to 1
        isAsset: true, // defaults to true, set to false to load resources outside assets
        useGpuDelegate: false // defaults to false, set to true to use GPU delegate
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tfliteInit();
  }

  @override
  void dispose() async{
    // TODO: implement dispose
    super.dispose();
    await Tflite.close();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 50,
            ),
            Text(
              'Detect Bio or NonBio',
              style: TextStyle(fontSize: 25),
            ),
            SizedBox(
              height: 20,
            ),
            Card(
              elevation: 20,
              child: SizedBox(
                width: 300,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 18,
                      ),
                      Container(
                        height: 250,
                        width: 250,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/file-upload.png'),
                          ),
                        ),
                        child: filepath==null?Text(''):Image.file(filepath!,fit: BoxFit.fill,),
                      ),
                      SizedBox(
                        height: 18,
                      ),
                      Text(
                        'Label: ${label.substring(2).toUpperCase()}',
                        style: TextStyle(
                          fontSize: 20,
                          color: label.substring(2)=='bio'?Colors.lightGreen:Colors.red,
                        ),
                      ),
                      Text(
                        'Accuracy: ${confidence}',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(
                        height: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 18,
            ),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  pickphoto();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_rounded),
                    SizedBox(width: 8,),
                    Text('Take a Photo',style: TextStyle(fontSize: 18),),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10,),
            SizedBox(
              width: 250,
              child: ElevatedButton(
                onPressed: () {
                  pickImageGallery();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_size_select_actual),
                    SizedBox(width: 8,),
                    Text('Upload from Gallery',style: TextStyle(fontSize: 18),),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
