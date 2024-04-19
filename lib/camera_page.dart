import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image/preview_page.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key, required this.cameras}) : super(key: key);

  final List<CameraDescription>? cameras;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;
  bool _isRearCameraSelected = true;

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initCamera(widget.cameras![0]);
  }

  Future takePicture() async {
    if (!_cameraController.value.isInitialized) {
      return null;
    }
    if (_cameraController.value.isTakingPicture) {
      return null;
    }
    try {
      await _cameraController.setFlashMode(FlashMode.off);
      XFile picture = await _cameraController.takePicture();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PreviewPage(
                    picture: picture,
                  )));
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  Future initCamera(CameraDescription cameraDescription) async {
    _cameraController =
        CameraController(cameraDescription, ResolutionPreset.high);
    try {
      await _cameraController.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Stack(children: [
        (_cameraController.value.isInitialized)
            ? Container(
                color: Colors.amber,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.width / 8 * 5,
                          decoration: BoxDecoration(
                            color: Colors.black
                                .withOpacity(0), // Transparent background
                            borderRadius:
                                BorderRadius.circular(24), // Rounded corners
                          ),
                          // Clip the camera preview to the "window"
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: OverflowBox(
                              alignment: Alignment.center,
                              maxWidth: constraints.maxWidth,
                              maxHeight: constraints.maxHeight,
                              child: CameraPreview(
                                  _cameraController), // Scaled CameraPreview
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              )
            : Container(
                color: Colors.black,
                child: const Center(child: CircularProgressIndicator())),
        Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.15,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  color: Colors.black),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Expanded(
                    child: IconButton(
                  onPressed: takePicture,
                  iconSize: 50,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.circle, color: Colors.white),
                )),
                const Spacer(),
              ]),
            )),
      ]),
    ));
  }
}
