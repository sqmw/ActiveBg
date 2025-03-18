import 'package:active_bg/demo/game.dart';
import 'package:active_bg/demo/resource_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_scene/camera.dart';
import 'package:flutter_scene/node.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart' as vm;
import 'package:logging/logging.dart';

final _logger = Logger('SpaceGallery');

class SpaceGallery extends StatefulWidget {
  const SpaceGallery({super.key});

  @override
  State<SpaceGallery> createState() => _SpaceGalleryState();
}

class _SpaceGalleryState extends State<SpaceGallery> {
  Scene scene = Scene();
  Camera camera = PerspectiveCamera(position: vm.Vector3(0, 5, 10), target: vm.Vector3(0, 0, 0));
  Node? currentModel;
  Ticker? tick;
  double time = 0;
  double deltaSeconds = 0;
  bool autoRotate = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    _initializeScene();
    _setupTicker();
  }

  Future<void> _initializeScene() async {
    try {
      _logger.info('Starting scene initialization');
      await Scene.initializeStaticResources();
      _logger.info('Scene initialized, loading resources');
      await ResourceCache.preloadAll();
      _logger.info('Resources loaded');
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadModel('coin');
        });
      }
    } catch (e) {
      _logger.warning('Error initializing scene: $e');
    }
  }

  void _setupTicker() {
    tick = Ticker((elapsed) {
      setState(() {
        double previousTime = time;
        time = elapsed.inMilliseconds / 1000.0;
        deltaSeconds = previousTime > 0 ? time - previousTime : 0;
        
        if (autoRotate && currentModel != null) {
          currentModel!.localTransform = vm.Matrix4.rotationY(time * 0.5);
        }
      });
    });
    tick!.start();
  }

  void _loadModel(String modelName) {
    if (!mounted) return;
    
    setState(() {
      _logger.info('Loading model: $modelName');
      if (currentModel != null) {
        try {
          scene.remove(currentModel!);
          _logger.info('Removed previous model');
        } catch (e) {
          _logger.warning('Error removing model: $e');
        }
      }

      try {
        currentModel = ResourceCache.getModel(modelName).clone();
        scene.add(currentModel!);
        _logger.info('Added new model: $modelName');
      } catch (e) {
        _logger.warning('Error loading model: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Row(
      children: [
        // 左侧模型列表
        SizedBox(
          width: 200,
          child: ListView(
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.view_in_ar),
                  title: const Text('Coin'),
                  onTap: () => _loadModel('coin'),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.view_in_ar),
                  title: const Text('Dash'),
                  onTap: () => _loadModel('dash'),
                ),
              ),
            ],
          ),
        ),
        
        // 右侧3D预览和控制面板
        Expanded(
          child: Column(
            children: [
              // 3D预览区域
              Expanded(
                child: CustomPaint(
                  painter: ScenePainter(scene: scene, camera: camera),
                ),
              ),
              
              // 控制面板
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 自动旋转开关
                    SwitchListTile(
                      title: const Text('自动旋转'),
                      value: autoRotate,
                      onChanged: (value) {
                        setState(() {
                          autoRotate = value;
                        });
                      },
                    ),
                    
                    // 操作按钮
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text('重置视角'),
                          onPressed: () {
                            setState(() {
                              camera = PerspectiveCamera(
                                position: vm.Vector3(0, 5, 10),
                                target: vm.Vector3(0, 0, 0)
                              );
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    tick?.dispose();
    super.dispose();
  }
}
