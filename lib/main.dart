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
  vector.Vector3? lastPanPosition;

  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ARKit Demo'),
      ),
      body: GestureDetector(
        onPanUpdate: _handlePan,
        child: ARKitSceneView(
          onARKitViewCreated: onARKitViewCreated,
        ),
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
      position: vector.Vector3(0, 0, -0.5),
    );
    arkitController.add(sphereNode!);
  }

  void _handlePan(DragUpdateDetails details) {
    if (sphereNode != null) {
      final dx = details.delta.dx;
      final dy = details.delta.dy;
      final currentPosition = sphereNode!.position;
      final newPosition = vector.Vector3(
        currentPosition.x + dx * 0.001,
        currentPosition.y - dy * 0.001,
        currentPosition.z,
      );

      arkitController.update(sphereNode!.name!, node: ARKitNode(position: newPosition));
    }
  }
}




// class _MyHomePageState extends State<MyHomePage> {
//   late ARKitController arkitController;
//   double sphereRadius = 0.1;
//   double positionX = 0.0;
//   double positionY = 0.0;
//   double positionZ = -0.5;
//   ARKitNode? sphereNode;

//   @override
//   void dispose() {
//     arkitController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('ARKit Flutter App'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ARKitSceneView(
//               onARKitViewCreated: onARKitViewCreated,
//             ),
//           ),
//           buildSlider('Radius', sphereRadius, 0.05, 0.5, (value) {
//             setState(() {
//               sphereRadius = value;
//               updateSphere();
//             });
//           }),
//           buildSlider('Position X', positionX, -1.0, 1.0, (value) {
//             setState(() {
//               positionX = value;
//               updateSphere();
//             });
//           }),
//           buildSlider('Position Y', positionY, -1.0, 1.0, (value) {
//             setState(() {
//               positionY = value;
//               updateSphere();
//             });
//           }),
//           buildSlider('Position Z', positionZ, -1.5, -0.1, (value) {
//             setState(() {
//               positionZ = value;
//               updateSphere();
//             });
//           }),
//         ],
//       ),
//     );
//   }

//   Widget buildSlider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
//     return Row(
//       children: [
//         Text(label),
//         Expanded(
//           child: Slider(
//             value: value,
//             min: min,
//             max: max,
//             onChanged: onChanged,
//           ),
//         ),
//       ],
//     );
//   }

//   void onARKitViewCreated(ARKitController controller) {
//     arkitController = controller;
//     _addSphere();
//   }

//   void _addSphere() {
//     final material = ARKitMaterial(
//       diffuse: ARKitMaterialProperty.color(Colors.red),
//       specular: ARKitMaterialProperty.color(Colors.white),
//       shininess: 0.8,
//     );
//     final sphere = ARKitSphere(
//       materials: [material],
//       radius: sphereRadius,
//     );
//     sphereNode = ARKitNode(
//       geometry: sphere,
//       position: vector.Vector3(positionX, positionY, positionZ),
//     );
//     arkitController.add(sphereNode!);
//   }

//   void updateSphere() {
//     if (sphereNode != null) {
//       arkitController.remove(sphereNode!.name);
//       final material = ARKitMaterial(
//         diffuse: ARKitMaterialProperty.color(Colors.red),
//         specular: ARKitMaterialProperty.color(Colors.white),
//         shininess: 0.8,
//       );
//       final sphere = ARKitSphere(
//         materials: [material],
//         radius: sphereRadius,
//       );
//       sphereNode = ARKitNode(
//         geometry: sphere,
//         position: vector.Vector3(positionX, positionY, positionZ),
//       );
//       arkitController.add(sphereNode!);
//     }
//   }
// }

// class _MyHomePageState extends State<MyHomePage> {
//   late ARKitController arkitController;

//   @override
//   void dispose() {
//     arkitController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('ARKit Flutter App'),
//       ),
//       body: ARKitSceneView(
//         onARKitViewCreated: onARKitViewCreated,
//       ),
//     );
//   }

//   void onARKitViewCreated(ARKitController controller) {
//     arkitController = controller;
//     _addSphere();
//   }

//   void _addSphere() {
//     final material = ARKitMaterial(
//       diffuse: ARKitMaterialProperty.color(Colors.red),
//       specular: ARKitMaterialProperty.color(Colors.white),
//       shininess: 0.8,
//     );
//     final sphere = ARKitSphere(
//       materials: [material],
//       radius: 0.2,
//     );
//     final node = ARKitNode(
//       geometry: sphere,
//       position: vector.Vector3(0, 0, -0.5),
//     );
//     arkitController.add(node);
//   }
// }


