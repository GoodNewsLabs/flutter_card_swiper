import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_card_swiper/src/extensions.dart';

class CardAnimation {
  CardAnimation({
    required this.animationController,
    required this.maxAngle,
    required this.initialScale,
    required this.offset,
    required this.threshold,
    this.isHorizontalSwipingEnabled = true,
    this.isVerticalSwipingEnabled = true,
  })  : scale = initialScale,
        difference = offset;

  final double maxAngle;
  final double initialScale;
  final AnimationController animationController;
  final bool isHorizontalSwipingEnabled;
  final bool isVerticalSwipingEnabled;
  final double offset;
  final int threshold;

  double left = 0;
  double top = 0;
  double angle = 0;
  double scale;
  double difference;

  late Animation<double> _leftAnimation;
  late Animation<double> _topAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _differenceAnimation;

  double get _maxAngleInRadian => maxAngle * (pi / 180);

  double get maxMovingDistance => max(left, top);

  bool get isWithinTheShakingRange => left.abs() < threshold && top.abs() < threshold;

  void sync() {
    left = _leftAnimation.value;
    top = _topAnimation.value;
    scale = _scaleAnimation.value;
    difference = _differenceAnimation.value;
  }

  void reset() {
    animationController.reset();
    left = 0;
    top = 0;
    angle = 0;
    scale = initialScale;
    difference = offset;
  }

  void update(double dx, double dy, bool inverseAngle, Size size) {
    if (isHorizontalSwipingEnabled) {
      left += dx;
    }
    if (isVerticalSwipingEnabled) {
      top += dy;
    }
    final movingRatio = getMovingRatio(size);
    updateAngle(inverseAngle);
    updateScale(movingRatio);
    updateDifference(movingRatio);
  }

  void updateAngle(bool inverse) {
    if (angle.isBetween(-_maxAngleInRadian, _maxAngleInRadian)) {
      angle = _maxAngleInRadian * left / 1000;
      if (inverse) angle *= -1;
    }
  }

  double getMovingRatio(Size size) {
    final verticalRatio = (left.abs() - threshold) / (size.width / 2);
    final horizontalRatio = (top.abs() - threshold) / (size.height / 2);
    final ratio = max<double>(verticalRatio, horizontalRatio);
    return ratio >= 1 ? 1 : ratio;
  }

  void updateScale(double ratio) {
    if (!isWithinTheShakingRange) {
      scale = initialScale + (1 - initialScale) * ratio;
    }
  }

  void updateDifference(double ratio) {
    if (!isWithinTheShakingRange) {
      difference = offset * (1 - ratio);
    }
  }

  void animate(BuildContext context, CardSwiperDirection direction) {
    switch (direction) {
      case CardSwiperDirection.left:
        return animateHorizontally(context, false);
      case CardSwiperDirection.right:
        return animateHorizontally(context, true);
      case CardSwiperDirection.top:
        return animateVertically(context, false);
      case CardSwiperDirection.bottom:
        return animateVertically(context, true);
      default:
        return;
    }
  }

  void animateHorizontally(BuildContext context, bool isToRight) {
    final screenWidth = MediaQuery.of(context).size.width;

    _leftAnimation = Tween<double>(
      begin: left,
      end: isToRight ? screenWidth : -screenWidth,
    ).animate(animationController);
    _topAnimation = Tween<double>(
      begin: top,
      end: top + top,
    ).animate(animationController);
    _scaleAnimation = Tween<double>(
      begin: scale,
      end: 1.0,
    ).animate(animationController);
    _differenceAnimation = Tween<double>(
      begin: difference,
      end: 0,
    ).animate(animationController);
    animationController.forward();
  }

  void animateVertically(BuildContext context, bool isToBottom) {
    final screenHeight = MediaQuery.of(context).size.height;

    _leftAnimation = Tween<double>(
      begin: left,
      end: left + left,
    ).animate(animationController);
    _topAnimation = Tween<double>(
      begin: top,
      end: isToBottom ? screenHeight : -screenHeight,
    ).animate(animationController);
    _scaleAnimation = Tween<double>(
      begin: scale,
      end: 1.0,
    ).animate(animationController);
    _differenceAnimation = Tween<double>(
      begin: difference,
      end: 0,
    ).animate(animationController);
    animationController.forward();
  }

  void animateBack(BuildContext context) {
    _leftAnimation = Tween<double>(
      begin: left,
      end: 0,
    ).animate(animationController);
    _topAnimation = Tween<double>(
      begin: top,
      end: 0,
    ).animate(animationController);
    _scaleAnimation = Tween<double>(
      begin: scale,
      end: initialScale,
    ).animate(animationController);
    _differenceAnimation = Tween<double>(
      begin: difference,
      end: offset,
    ).animate(animationController);
    animationController.forward();
  }

  void animateUndo(BuildContext context, CardSwiperDirection direction) {
    switch (direction) {
      case CardSwiperDirection.left:
        return animateUndoHorizontally(context, false);
      case CardSwiperDirection.right:
        return animateUndoHorizontally(context, true);
      case CardSwiperDirection.top:
        return animateUndoVertically(context, false);
      case CardSwiperDirection.bottom:
        return animateUndoVertically(context, true);
      default:
        return;
    }
  }

  void animateUndoHorizontally(BuildContext context, bool isToRight) {
    final size = MediaQuery.of(context).size;

    _leftAnimation = Tween<double>(
      begin: isToRight ? size.width : -size.width,
      end: 0,
    ).animate(animationController);
    _topAnimation = Tween<double>(
      begin: top,
      end: top + top,
    ).animate(animationController);
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: scale,
    ).animate(animationController);
    _differenceAnimation = Tween<double>(
      begin: 0,
      end: difference,
    ).animate(animationController);
    animationController.forward();
  }

  void animateUndoVertically(BuildContext context, bool isToBottom) {
    final size = MediaQuery.of(context).size;

    _leftAnimation = Tween<double>(
      begin: left,
      end: left + left,
    ).animate(animationController);
    _topAnimation = Tween<double>(
      begin: isToBottom ? -size.height : size.height,
      end: 0,
    ).animate(animationController);
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: scale,
    ).animate(animationController);
    _differenceAnimation = Tween<double>(
      begin: 0,
      end: difference,
    ).animate(animationController);
    animationController.forward();
  }
}
