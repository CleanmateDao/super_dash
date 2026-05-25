import 'package:cleanmate_rush/game/cleanmate_rush_game.dart';
import 'package:flame/components.dart';

class CameraBounds extends PositionComponent {
  CameraBounds({
    required this.reference,
    required this.bound,
  });

  final PositionComponent reference;
  final double bound;

  late final Vector2 referenceOffset;

  double translateValue = 0;
  double translatedValue = 0;

  void _updatePosition(double dt) {
    position.x = reference.position.x + referenceOffset.x;

    final playerPosition = reference.position.y + referenceOffset.y;
    final difference = playerPosition - position.y;
    if (difference.abs() > bound) {
      translateValue = difference;
    }

    if (translateValue.abs() > 0) {
      final translationDifference =
          (translateValue.abs() - translatedValue.abs()) / translateValue.abs();
      var speed = 1.0 - translationDifference;
      speed = 1 - speed * speed * speed * speed;

      final step = (800 * speed) * dt * translateValue.sign;

      position.y += step;
      translatedValue += step.abs();

      if (translateValue.abs() - translatedValue.abs() < 10) {
        translateValue = 0;
        translatedValue = 0;
      }
    }
  }

  @override
  void onMount() {
    super.onMount();

    referenceOffset = Vector2(
      reference.size.x,
      reference.size.y,
    );
    position.y = reference.position.y + referenceOffset.y;

    _updatePosition(0);
  }

  @override
  void update(double dt) {
    super.update(dt);

    _updatePosition(dt);
  }
}

class PlayerCameraAnchor extends Component
    with ParentIsA<PositionComponent>, HasGameRef<CleanmateRushGame>
    implements ReadOnlyPositionProvider {
  PlayerCameraAnchor({
    required this.levelSize,
    required this.cameraViewport,
  });

  final Vector2 levelSize;
  final Vector2 cameraViewport;
  final Vector2 _anchor = Vector2.zero();
  late final PositionComponent _bounds;

  late final Vector2 _cameraMin = Vector2(
    cameraViewport.x * .4,
    cameraViewport.y / 2,
  );

  late final Vector2 _cameraMax = Vector2(
    levelSize.x - cameraViewport.x / 2,
    levelSize.y - cameraViewport.y / 2,
  );

  late final _cameraXOffset = cameraViewport.x * .3;
  late final _cameraYOffset = cameraViewport.y * .2;

  @override
  Vector2 get position => _anchor;

  void _setAnchor(double x, double y) {
    _anchor
      ..x = x.clamp(_cameraMin.x, _cameraMax.x) + _cameraXOffset
      ..y = y.clamp(_cameraMin.y, _cameraMax.y) - _cameraYOffset;
  }

  @override
  void onMount() {
    super.onMount();

    _bounds = CameraBounds(
      reference: parent,
      bound: 128,
    );
    gameRef.world.add(_bounds);

    final value = parent.position.clone();
    _setAnchor(value.x, value.y);
  }

  @override
  void onRemove() {
    _bounds.removeFromParent();
    super.onRemove();
  }

  @override
  void update(double dt) {
    super.update(dt);

    _setAnchor(
      _bounds.position.x,
      _bounds.position.y,
    );
  }
}
