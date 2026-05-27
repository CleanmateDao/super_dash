import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:app_ui/app_ui.dart';
import 'package:cleanmate_rush/analytics/analytics.dart';
import 'package:cleanmate_rush/audio/audio.dart';
import 'package:cleanmate_rush/game/game.dart';
import 'package:cleanmate_rush/user_session/user_session.dart';
import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/sprite.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leap/leap.dart';

bool _tsxPackingFilter(Tileset tileset) {
  return !(tileset.source ?? '').startsWith('anim');
}

Paint _layerPaintFactory(double opacity) {
  return Paint()
    ..color = Color.fromRGBO(255, 255, 255, opacity)
    ..isAntiAlias = false;
}

class CleanmateRushGame extends LeapGame
    with TapDetector, HasKeyboardHandlerComponents {
  CleanmateRushGame({
    required this.gameBloc,
    required this.audioController,
    RushAnalytics? rushAnalytics,
    this.onRunEnded,
  })  : rushAnalytics = rushAnalytics ?? RushAnalytics.noop(),
        super(
          tileSize: 64,
          configuration: const LeapConfiguration(
            tiled: TiledOptions(
              atlasMaxX: 4048,
              atlasMaxY: 4048,
              tsxPackingFilter: _tsxPackingFilter,
              layerPaintFactory: _layerPaintFactory,
              atlasPackingSpacingX: 4,
              atlasPackingSpacingY: 4,
            ),
          ),
        );

  static final _cameraViewport = Vector2(592, 1024);
  static const prefix = 'assets/map/';
  static const _sections = [
    'flutter_runnergame_map_A.tmx',
    'flutter_runnergame_map_B.tmx',
    'flutter_runnergame_map_C.tmx',
  ];
  static const _sectionsBackgroundColor = [
    (AppColors.background, AppColors.secondary),
    (AppColors.muted, AppColors.secondary),
    (AppColors.blueDark, AppColors.blue),
  ];

  final GameBloc gameBloc;
  final AudioController audioController;
  final RushAnalytics rushAnalytics;
  final void Function(double xp)? onRunEnded;
  final List<VoidCallback> _inputListener = [];

  late final SpriteSheet itemsSpritesheet;

  var _hasEndedRun = false;
  var _hasAwardedRunXp = false;
  var _loggedFirstInput = false;
  var _isAdvancingSection = false;
  Completer<void>? _gameOverCompleter;

  GameState get state => gameBloc.state;

  /// Whether the current run has ended (game over, completion, or quit).
  bool get hasEndedRun => _hasEndedRun;

  Player? get player => world.firstChild<Player>();

  List<Tileset> get tilesets => leapMap.tiledMap.tileMap.map.tilesets;

  Tileset get itemsTileset {
    return tilesets.firstWhere(
      (tileset) => tileset.name == 'tile_items_v2',
    );
  }

  Tileset get enemiesTileset {
    return tilesets.firstWhere(
      (tileset) => tileset.name == 'tile_enemies_v2',
    );
  }

  void addInputListener(VoidCallback listener) {
    _inputListener.add(listener);
  }

  void removeInputListener(VoidCallback listener) {
    _inputListener.remove(listener);
  }

  void _triggerInputListeners() {
    if (!_loggedFirstInput) {
      _loggedFirstInput = true;
      unawaited(rushAnalytics.logFirstInput());
    }
    audioController.notifyUserGesture();
    for (final listener in _inputListener) {
      listener();
    }
  }

  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);

    _triggerInputListeners();
    overlays.remove('tapToJump');
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    if (kIsWeb && audioController.isMusicEnabled) {
      audioController.startMusic();
    }

    camera = CameraComponent.withFixedResolution(
      width: _cameraViewport.x,
      height: _cameraViewport.y,
    )..world = world;

    images = Images(prefix: prefix);

    itemsSpritesheet = SpriteSheet(
      image: await images.load('objects/tile_items_v2.png'),
      srcSize: Vector2.all(tileSize),
    );

    await loadWorldAndMap(
      images: images,
      prefix: prefix,
      tiledMapPath: _sections.first,
    );
    _setSectionBackground();

    final player = Player(
      levelSize: leapMap.tiledMap.size.clone(),
      cameraViewport: _cameraViewport,
    );
    unawaited(
      world.addAll([player]),
    );

    await _addSpawners();
    _addTreeHouseFrontLayer();
    _addTreeHouseSign();

    add(
      KeyboardListenerComponent(
        keyDown: {
          LogicalKeyboardKey.space: (_) {
            _triggerInputListeners();
            overlays.remove('tapToJump');
            return false;
          },
        },
        keyUp: {
          LogicalKeyboardKey.space: (_) {
            return false;
          },
        },
      ),
    );
  }

  void _addTreeHouseSign() {
    world.add(
      TreeSign(
        position: Vector2(
          448,
          1862,
        ),
      ),
    );
  }

  void _addTreeHouseFrontLayer() {
    final layer = leapMap.tiledMap.tileMap.renderableLayers.last;
    world.add(TreeHouseFront(renderFront: layer.render));
  }

  void _setSectionBackground() {
    final colors = _sectionsBackgroundColor[state.currentSection];
    camera.backdrop = RectangleComponent(
      size: size.clone(),
      paint: Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(size.x, size.y),
          [
            colors.$1,
            colors.$2,
          ],
        ),
    );
  }

  void gameOver() {
    if (_hasEndedRun) {
      return;
    }
    _hasEndedRun = true;

    final xp = gameBloc.state.xp;
    onRunEnded?.call(xp);
    unawaited(_completeGameOver(xp));
  }

  Future<void> _completeGameOver(double xp) async {
    _gameOverCompleter = Completer<void>();
    try {
      pauseEngine();
      overlays.remove('tapToJump');

      await _awardRunXp(xp);

      gameBloc.add(const GameOver());

      _clearWorldRunActors();
      _resetEntities();

      if (onRunEnded == null) {
        unawaited(restartRun());
      }
    } finally {
      _gameOverCompleter?.complete();
      _gameOverCompleter = null;
    }
  }

  Future<void> restartRun() async {
    if (!_hasEndedRun) {
      return;
    }

    final gameOverCompleter = _gameOverCompleter;
    if (gameOverCompleter != null) {
      await gameOverCompleter.future;
    }

    gameBloc.add(const GameOver());

    _clearWorldRunActors();
    _resetEntities();

    await loadWorldAndMap(
      images: images,
      prefix: prefix,
      tiledMapPath: _sections.first,
    );
    if (isLastSection || isFirstSection) {
      _addTreeHouseFrontLayer();
    }

    if (isFirstSection) {
      _addTreeHouseSign();
    }
    await _spawnFreshPlayer();
    await _addSpawners();
    overlays.add('tapToJump');
    resumeEngine();
    _hasEndedRun = false;
    _hasAwardedRunXp = false;
    _loggedFirstInput = false;
  }

  /// Ends the run early when the player leaves gameplay and awards earned XP.
  Future<void> quitRun() async {
    if (_hasEndedRun) {
      return;
    }

    _hasEndedRun = true;
    pauseEngine();
    overlays.remove('tapToJump');

    final xp = gameBloc.state.xp;
    await _awardRunXp(xp);
    gameBloc.add(const GameOver());
  }

  Future<void> _awardRunXp(double xp) async {
    if (_hasAwardedRunXp || xp <= 0) {
      return;
    }

    _hasAwardedRunXp = true;
    await _postGameplayXp(xp);
  }

  Future<void> _postGameplayXp(double xp) async {
    if (xp <= 0 || buildContext == null) {
      return;
    }
    final context = buildContext!;
    final sessionRepository = context.read<UserSessionRepository>();
    final apiClient = context.read<RushApiClient>();
    final realtimeService = context.read<RushRealtimeService>();
    final session = await sessionRepository.readSession();
    if (session == null) {
      return;
    }
    try {
      final result = await apiClient.postGameplayXp(
        token: session.token,
        amount: xp,
        runId: _newRunId(xp),
      );
      realtimeService.notifyXpAwarded(result);
      unawaited(rushAnalytics.logXpPosted(xp: xp));
    } on RushApiException catch (error) {
      unawaited(
        rushAnalytics.logXpPostFailed(
          xp: xp,
          statusCode: error.statusCode,
        ),
      );
      if (error.statusCode == 401 || error.statusCode == 403) {
        await sessionRepository.clearSession();
      }
    } on Exception {
      unawaited(rushAnalytics.logXpPostFailed(xp: xp));
    }
  }

  String _newRunId(double xp) {
    final randomPart = Random().nextInt(1 << 32).toRadixString(16);
    return '${DateTime.now().microsecondsSinceEpoch}-$xp-$randomPart';
  }

  void _resetEntities() {
    children.whereType<ObjectGroupProximityBuilder<Player>>().forEach(
          (spawner) => spawner.removeFromParent(),
        );
    world.firstChild<TreeHouseFront>()?.removeFromParent();
    world.firstChild<TreeSign>()?.removeFromParent();

    leapMap.children
        .whereType<Enemy>()
        .forEach((enemy) => enemy.removeFromParent());
    leapMap.children
        .whereType<Item>()
        .forEach((enemy) => enemy.removeFromParent());
  }

  void _clearWorldRunActors() {
    for (final player in world.children.whereType<Player>().toList()) {
      player.removeFromParent();
    }
    for (final bounds in world.children.whereType<CameraBounds>().toList()) {
      bounds.removeFromParent();
    }
  }

  Future<void> _spawnFreshPlayer() async {
    final newPlayer = Player(
      levelSize: leapMap.tiledMap.size.clone(),
      cameraViewport: _cameraViewport,
    );
    await world.add(newPlayer);
    await newPlayer.mounted;
    newPlayer
      ..walking = true
      ..spritePaintColor(Colors.white)
      ..isPlayerTeleporting = false;
    newPlayer.stateBehavior.state = DashState.running;
    camera.follow(newPlayer.cameraAnchor);
  }

  Future<void> _addSpawners() async {
    await addAll([
      ObjectGroupProximityBuilder<Player>(
        proximity: _cameraViewport.x * 1.5,
        tileLayerName: 'items',
        tileset: itemsTileset,
        componentBuilder: Item.new,
      ),
      ObjectGroupProximityBuilder<Player>(
        proximity: _cameraViewport.x * 1.5,
        tileLayerName: 'enemies',
        tileset: enemiesTileset,
        componentBuilder: Enemy.new,
      ),
    ]);
  }

  Future<void> _loadNewSection(int sectionIndex) async {
    _resetEntities();
    _clearWorldRunActors();

    await loadWorldAndMap(
      images: images,
      prefix: prefix,
      tiledMapPath: _sections[sectionIndex],
    );

    if (sectionIndex == 0) {
      _addTreeHouseSign();
    }

    if (sectionIndex == 0 || sectionIndex == _sections.length - 1) {
      _addTreeHouseFrontLayer();
    }

    await _spawnFreshPlayer();
    await _addSpawners();
  }

  @override
  void onMapUnload(LeapMap map) {
    player?.velocity.setZero();
  }

  @override
  void onMapLoaded(LeapMap map) {
    player?.loadSpawnPoint();
    player?.loadRespawnPoints();
    player?.walking = true;
    player?.spritePaintColor(Colors.white);
    player?.isPlayerTeleporting = false;
    player?.stateBehavior.state = DashState.running;

    _setSectionBackground();
  }

  void sectionCleared() {
    if (_isAdvancingSection || _hasEndedRun) {
      return;
    }

    if (isLastSection) {
      player?.spritePaintColor(Colors.transparent);
      player?.walking = false;
      gameBloc.add(GameSectionCompleted(sectionCount: _sections.length));
      gameOver();
      return;
    }

    unawaited(_advanceToNextSection());
  }

  Future<void> _advanceToNextSection() async {
    if (_isAdvancingSection || _hasEndedRun) {
      return;
    }

    _isAdvancingSection = true;
    final completedSection = state.currentSection;
    final nextSectionIndex = completedSection + 1;

    if (nextSectionIndex >= _sections.length) {
      _isAdvancingSection = false;
      return;
    }

    try {
      await _loadNewSection(nextSectionIndex);
      gameBloc.add(GameSectionCompleted(sectionCount: _sections.length));
      _setSectionBackground();
    } on Exception {
      try {
        await _loadNewSection(completedSection);
      } on Exception {
        // Leave the run in a broken state if recovery also fails.
      }
      return;
    } finally {
      _isAdvancingSection = false;
    }

    unawaited(
      rushAnalytics.logSectionCompleted(
        sectionIndex: completedSection,
        level: state.currentLevel,
      ),
    );
  }

  bool get isLastSection => state.currentSection == _sections.length - 1;
  bool get isFirstSection => state.currentSection == 0;
}
