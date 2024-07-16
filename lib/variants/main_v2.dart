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
  double _previousScale = 1.0;
  final double _minRadius = 0.02;
  final double _maxRadius = 0.5;
  vector.Vector3? lastPanPosition;
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  void onARKitViewCreated(ARKitController controller) {
    arkitController = controller;
    arkitController.updateAtTime = _updateSpherePosition;
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
      position: vector.Vector3(0, 0, -0.5),
    );
    arkitController.add(sphereNode!);
  }

  void _updateSpherePosition(double time) async {
    final cameraTransform = await arkitController.pointOfViewTransform();
    if (cameraTransform != null && sphereNode != null) {
      final cameraPosition = vector.Vector3(
        cameraTransform.getColumn(3).x,
        cameraTransform.getColumn(3).y,
        cameraTransform.getColumn(3).z,
      );
      final offset = vector.Vector3(0, 0, -0.5);
      final newPosition = cameraPosition + cameraTransform.transform3(offset);
      sphereNode!.position = newPosition;
      arkitController.update(
        sphereNode!.name,
        node: sphereNode!,
      );
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    _previousScale = sphereRadius;
    lastPanPosition = sphereNode!.position;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      double newRadius = _previousScale * details.scale;
      newRadius = newRadius.clamp(_minRadius, _maxRadius);
      sphereRadius = newRadius;
      _updateSphereGeometry();
    });
  }

  void _onPanStart(DragStartDetails details) {
    lastPanPosition = sphereNode!.position;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (lastPanPosition != null) {
      final delta = details.delta;
      final newPosition = lastPanPosition! +
          vector.Vector3(
            delta.dx * 0.001,
            -delta.dy * 0.001,
            0,
          );
      setState(() {
        sphereNode!.position = newPosition;
        arkitController.update(
          sphereNode!.name,
          node: sphereNode!,
        );
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    lastPanPosition = sphereNode!.position;
  }

  void _updateSphereGeometry() {
    if (sphereNode != null) {
      final materials = sphereNode!.geometry!.materials.value;
      final newSphere = ARKitSphere(radius: sphereRadius, materials: materials);
      final newNode = ARKitNode(
        geometry: newSphere,
        position: sphereNode!.position,
      );
      arkitController.remove(sphereNode!.name);
      sphereNode = newNode;
      arkitController.add(sphereNode!);
    }
  }
}
