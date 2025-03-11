import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:video_player/video_player.dart';

class ImageScreen extends StatefulWidget {
  const ImageScreen({super.key});

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  File? videoFile;
  VideoPlayerController? videoController;

  File? decodedImageFile;
  File? pickedFile;
  String? fileName;

  final ImagePicker imagePicker = ImagePicker();

  Future<void> selectVideo() async {
    final XFile? pickedVideo = await imagePicker.pickVideo(source: ImageSource.gallery);
    if (pickedVideo != null) {
      videoFile = File(pickedVideo.path);
      videoController = VideoPlayerController.file(videoFile!)
        ..initialize().then((_) {
          setState(() {}); // Update UI when video is loaded
        });
    }
  }

  Future<void> _selectedImage() async {
    final XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      final img.Image? image = img.decodeImage(imageFile.readAsBytesSync());
      if (image != null) {
        img.Image resizedImage = img.copyResize(image, width: 400);
        final resizedFile = File(pickedFile.path)..writeAsBytesSync(img.encodeJpg(resizedImage));
        setState(() {
          decodedImageFile = resizedFile;
        });
      }
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      setState(() {
        pickedFile = file;
        fileName = result.files.single.name;
      });
    }
  }

  @override
  void dispose() {
    videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("File Upload"),
        centerTitle: true,
        
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // First Video Picker
            Stack(
              children: [
                CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.amber,
                  child: videoFile == null
                      ? const Icon(Icons.video_library, size: 100)
                      : ClipOval(
                          child: SizedBox(
                            width: 160,
                            height: 160,
                            child: videoController!.value.isInitialized
                                ? VideoPlayer(videoController!)
                                : const Center(child: CircularProgressIndicator()),
                          ),
                        ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton(
                    onPressed: selectVideo,
                    icon: const Icon(Icons.add_a_photo, size: 30),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Second Image Picker (With Decoding)
            Stack(
              children: [
                CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.amber,
                  backgroundImage: decodedImageFile != null ? FileImage(decodedImageFile!) : null,
                  child: decodedImageFile == null ? const Icon(Icons.person, size: 100) : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton(
                    onPressed: _selectedImage,
                    icon: const Icon(Icons.add_a_photo, size: 30),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // File Picker for PDFs/Documents
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                width: 300,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: pickedFile != null
                    ? Text(
                        fileName ?? "Selected File",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        textAlign: TextAlign.center,
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.file_copy, size: 40, color: Colors.white),
                          SizedBox(height: 10),
                          Text("Select a file", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Button to Preview File
            ElevatedButton(
              onPressed: () {
                if (pickedFile != null) {
                  OpenFile.open(pickedFile!.path);
                }
              },
              child: const Text("View Selected File"),
            ),
          ],
        ),
      ),
      floatingActionButton: videoController != null && videoController!.value.isInitialized
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  videoController!.value.isPlaying ? videoController!.pause() : videoController!.play();
                });
              },
              child: Icon(videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow),
            )
          : null,
    );
  }
}
