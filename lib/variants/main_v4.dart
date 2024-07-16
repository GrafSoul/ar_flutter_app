import 'package:flutter/material.dart';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AR Flutter App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late ARKitController arkitController;
  ARKitNode? sphereNode;
  double sphereRadius = 0.1;
  final double _minRadius = 0.02;
  final double _maxRadius = 0.5;
  double _previousScale = 0.5;
  vector.Vector3 spherePosition = vector.Vector3(0, 0, -0.5);
  bool isScalingMode = false;

  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ARKit Flutter App'),
      ),
      body: Stack(
        children: [
          GestureDetector(
            onScaleStart: isScalingMode ? _onScaleStart : null,
            onScaleUpdate: isScalingMode ? _onScaleUpdate : null,
            onPanStart: !isScalingMode ? _onPanStart : null,
            onPanUpdate: !isScalingMode ? _onPanUpdate : null,
            onPanEnd: !isScalingMode ? _onPanEnd : null,
            child: ARKitSceneView(
              onARKitViewCreated: onARKitViewCreated,
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isScalingMode = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isScalingMode ? Colors.blue : Colors.grey,
                  ),
                  child: const Text('Scale'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isScalingMode = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !isScalingMode ? Colors.blue : Colors.grey,
                  ),
                  child: const Text('Move'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _resetSpherePosition,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Reset Position'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void onARKitViewCreated(ARKitController controller) {
    arkitController = controller;
    _addSphere();
  }

  void _addSphere() {
    final material = ARKitMaterial(
      diffuse: ARKitMaterialProperty.color(Colors.red),
      specular: ARKitMaterialProperty.color(Colors.white),
      shininess: 0.8,
    );
    final sphere = ARKitSphere(
      materials: [material],
      radius: sphereRadius,
    );
    sphereNode = ARKitNode(
      geometry: sphere,
      position: spherePosition,
    );
    arkitController.add(sphereNode!);
  }

  void _resetSpherePosition() async {
    final cameraTransform = await arkitController.pointOfViewTransform();
    if (cameraTransform != null && sphereNode != null) {
      final offset = vector.Vector3(0, 0, -0.5);
      final newPosition = cameraTransform.transform3(offset);
      setState(() {
        spherePosition = offset;
        sphereNode!.position = newPosition;
        arkitController.update(
          sphereNode!.name,
          node: sphereNode!,
        );
      });
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    _previousScale = sphereRadius;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      double newRadius = _previousScale * details.scale;
      newRadius = newRadius.clamp(_minRadius, _maxRadius);
      sphereRadius = newRadius;
      _updateSphereGeometry();
    });
  }

  void _onPanStart(DragStartDetails details) {}

  void _onPanUpdate(DragUpdateDetails details) {
    final delta = details.delta;
    setState(() {
      spherePosition += vector.Vector3(delta.dx * 0.001, -delta.dy * 0.001, 0);
      sphereNode!.position = spherePosition;
      arkitController.update(
        sphereNode!.name,
        node: sphereNode!,
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {}

  void _updateSphereGeometry() {
    if (sphereNode != null) {
      final materials = sphereNode!.geometry!.materials.value;
      final newSphere = ARKitSphere(radius: sphereRadius, materials: materials);
      final newNode = ARKitNode(
        geometry: newSphere,
        position: spherePosition,
      );
      arkitController.remove(sphereNode!.name);
      sphereNode = newNode;
      arkitController.add(sphereNode!);
    }
  }
}
