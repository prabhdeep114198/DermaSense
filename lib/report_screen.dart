import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class DiseasePrediction extends StatefulWidget {
  const DiseasePrediction({Key? key}) : super(key: key);

  @override
  _DiseasePredictionState createState() => _DiseasePredictionState();
}

class _DiseasePredictionState extends State<DiseasePrediction> {
  File? _image;
  String? _error;
  bool _loading = false;
  late List<CameraDescription> cameras;
  CameraController? _cameraController;
  final TextEditingController _locationController = TextEditingController();
  bool _useManualLocation = false;

  @override
  void initState() {
    super.initState();
    _initCameras();
  }

  Future<void> _initCameras() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      cameras = await availableCameras();

      if (cameras.isNotEmpty) {
        _cameraController = CameraController(cameras[0], ResolutionPreset.high);
        await _cameraController!.initialize();
        setState(() {});
      } else {
        setState(() => _error = "No cameras found.");
      }
    } catch (e) {
      setState(() => _error = "Camera error: $e");
    }
  }

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.locationWhenInUse.request();
  }

  Future<void> _showImageSourceDialog() async {
    await _requestPermissions();
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera, color: Colors.blue),
              title: const Text("Take a Photo"),
              onTap: () {
                Navigator.pop(context);
                _capturePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _capturePhoto() async {
    try {
      if (_cameraController == null ||
          !_cameraController!.value.isInitialized) {
        setState(() => _error = "Camera not available.");
        return;
      }

      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _image = File(photo.path);
        _error = null;
      });
    } catch (e) {
      setState(() => _error = "Photo capture failed: $e");
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _error = null;
      });
    }
  }

  Future<void> _sendImageToModel() async {
    if (_image == null) {
      setState(() => _error = "No image selected.");
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.29.35:8501/predict'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('image', _image!.path),
      );
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final result = json.decode(responseBody);
        _showPredictionDialog(result);
      } else {
        setState(() => _error = "Prediction failed: ${response.reasonPhrase}");
      }
    } catch (e) {
      setState(() => _error = "Error sending image: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showPredictionDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Prediction Result"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  result.entries
                      .map(
                        (entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            "${entry.key}: ${entry.value}",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      )
                      .toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  Future<void> _findNearbyHospitals() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      Uri uri;

      if (_useManualLocation && _locationController.text.trim().isNotEmpty) {
        String query = Uri.encodeComponent(
          "hospital in ${_locationController.text.trim()}",
        );
        uri = Uri.parse(
          "https://nominatim.openstreetmap.org/search?format=json&q=$query&limit=5",
        );
      } else {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        double lat = position.latitude;
        double lon = position.longitude;

        uri = Uri.parse(
          "https://nominatim.openstreetmap.org/search?format=json&q=hospital&limit=5&bounded=1&viewbox=${lon - 0.05},${lat - 0.05},${lon + 0.05},${lat + 0.05}",
        );
      }

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          _showHospitalsDialog(data);
        } else {
          setState(() => _error = "No hospitals found.");
        }
      } else {
        setState(() => _error = "Failed to fetch hospital data.");
      }
    } catch (e) {
      setState(() => _error = "Error: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showHospitalsDialog(List<dynamic> hospitals) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Nearby Hospitals"),
          content: SizedBox(
            height: 300,
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: hospitals.length,
              itemBuilder: (context, index) {
                var place = hospitals[index];
                return ListTile(
                  leading: const Icon(Icons.local_hospital, color: Colors.red),
                  title: Text(place["display_name"] ?? "Hospital"),
                  subtitle:
                      place["lat"] != null
                          ? Text("Location: ${place["lat"]}, ${place["lon"]}")
                          : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.map),
                    onPressed: () {
                      String mapUrl =
                          "https://www.openstreetmap.org/?mlat=${place['lat']}&mlon=${place['lon']}#map=16/${place['lat']}/${place['lon']}";
                      launchUrl(
                        Uri.parse(mapUrl),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _showImageSourceDialog,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.teal, width: 1.5),
            ),
            child:
                _image == null
                    ? Column(
                      children: const [
                        Icon(Icons.upload_file, size: 60, color: Colors.grey),
                        SizedBox(height: 10),
                        Text(
                          'Tap to upload a skin image',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    )
                    : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _image!,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Checkbox(
              value: _useManualLocation,
              onChanged: (val) => setState(() => _useManualLocation = val!),
              activeColor: Colors.teal,
            ),
            const Text(
              "Enter location manually",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        if (_useManualLocation)
          TextField(
            controller: _locationController,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: 'Enter your city or area...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _sendImageToModel,
          icon: const Icon(Icons.analytics),
          label: const Text("Predict Disease"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: _findNearbyHospitals,
          icon: const Icon(Icons.local_hospital),
          label: const Text("Find Nearby Hospitals"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
        const SizedBox(height: 10),
        if (_loading)
          const Center(child: CircularProgressIndicator(color: Colors.teal)),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              _error!,
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        title: const Text('Skin Disease Prediction'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        automaticallyImplyLeading: false, // Remove the back button
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _buildImageUploadSection(),
      ),
    );
  }
}
