/*
 Copyright 2017-present the Material Components for iOS authors. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "MDMAnimator.h"

const MDMMotionTiming MDMMotionTimingInstantaneous = {
  .duration = -2,
  .delay = 0,
  .controlPoints = {0.0f, 0.0f, 1.0f, 1.0f}
};

const MDMMotionTiming MDMMotionTimingNone = {
  .duration = -1,
  .delay = 0,
  .controlPoints = {0.0f, 0.0f, 1.0f, 1.0f}
};

#if TARGET_IPHONE_SIMULATOR
UIKIT_EXTERN float UIAnimationDragCoefficient(void); // UIKit private drag coefficient.
#endif

static CGFloat simulatorAnimationDragCoefficient(void) {
#if TARGET_IPHONE_SIMULATOR
  return UIAnimationDragCoefficient();
#else
  return 1.0;
#endif
}

static CAMediaTimingFunction* timingFunctionWithControlPoints(float controlPoints[4]) {
  return [CAMediaTimingFunction functionWithControlPoints:controlPoints[0]
                                                         :controlPoints[1]
                                                         :controlPoints[2]
                                                         :controlPoints[3]];
}

@interface MDMAnimatorStatesStorage : NSObject <MDMAnimatorStates>
@end

@implementation MDMAnimatorStatesStorage {
  NSMutableDictionary *_states;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _states = [NSMutableDictionary dictionary];
  }
  return self;
}

- (NSDictionary<NSString *, id> *)objectForKeyedSubscript:(NSString *)key {
  NSDictionary *state = _states[key];
  if (!state) {
    state = [NSMutableDictionary dictionary];
    _states[key] = state;
  }
  return state;
}

- (void)setObject:(NSDictionary<NSString *, id> *)obj forKeyedSubscript:(NSString *)key {
  [_states setObject:obj forKey:key];
}

@end

@interface MDMAnimatorOptionsStorage : NSObject <MDMAnimatorOptions>
@end

@implementation MDMAnimatorOptionsStorage {
  NSMutableDictionary *_states;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _states = [NSMutableDictionary dictionary];
  }
  return self;
}

- (id<MDMAnimationConfigurator>)objectForKeyedSubscript:(NSString *)key {
  return _states[key];
}

- (void)setObject:(id<MDMAnimationConfigurator>)obj forKeyedSubscript:(NSString *)key {
  [_states setObject:obj forKey:key];
}

@end

@protocol MDMPropertyAnimator

- (void)animateProperty:(MDMMotionProperty)property to:(id)value withTiming:(MDMMotionTiming)timing;

@end

@interface MDMLayerPropertyAnimator : NSObject <MDMPropertyAnimator>

- (instancetype)initWithLayer:(CALayer *)layer;

@end

@implementation MDMLayerPropertyAnimator {
  __weak CALayer *_layer;
}

- (instancetype)initWithLayer:(CALayer *)layer {
  self = [super init];
  if (self) {
    _layer = layer;
  }
  return self;
}

- (void)animateProperty:(MDMMotionProperty)property to:(id)value withTiming:(MDMMotionTiming)timing {
  CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:property];
  if (timing.delay != 0) {
    animation.beginTime = ([_layer convertTime:CACurrentMediaTime() fromLayer:nil]
                           + timing.delay * simulatorAnimationDragCoefficient());
    animation.fillMode = kCAFillModeBackwards;
  }
  animation.duration = timing.duration * simulatorAnimationDragCoefficient();
  animation.timingFunction = timingFunctionWithControlPoints(timing.controlPoints);

  // TODO(featherless): Support other numerical types.
  if ([value isKindOfClass:[NSNumber class]]) {
    CGFloat currentValue = [[_layer valueForKeyPath:property] doubleValue];
    animation.fromValue = @(currentValue - [value doubleValue]);
    animation.toValue = @0;
    animation.additive = true;

  } else {
    animation.toValue = value;
  }

  NSString *uniqueKey = [animation.keyPath stringByAppendingString:[NSUUID UUID].UUIDString];
  [_layer addAnimation:animation forKey:uniqueKey];

  [_layer setValue:value forKeyPath:animation.keyPath];
}

@end

@interface MDMViewPropertyAnimator : NSObject <MDMPropertyAnimator>

- (instancetype)initWithView:(UIView *)view;

@end

@implementation MDMViewPropertyAnimator {
  __weak UIView *_view;
}

- (instancetype)initWithView:(UIView *)view {
  self = [super init];
  if (self) {
    _view = view;
  }
  return self;
}

- (void)animateProperty:(MDMMotionProperty)property to:(id)value withTiming:(MDMMotionTiming)timing {
  [UIView animateWithDuration:timing.duration delay:timing.delay options:0 animations:^{
    // TODO: Route key paths somehow.

    if ([property isEqualToString:@"x"]) {
      [_view.layer setValue:value forKeyPath:@"position.x"];

    } else if ([property isEqualToString:@"size"]) {
      [_view.layer setValue:value forKeyPath:@"bounds.size"];

    } else {
      [_view setValue:value forKeyPath:property];
    }
  } completion: nil];
}

@end


@implementation MDMAnimator {
  MDMAnimatorStatesStorage *_states;
  MDMAnimatorOptionsStorage *_options;
  __weak id _object;
}

- (instancetype)initWithObject:(id)object {
  self = [super init];
  if (self) {
    _object = object;

    _states = [[MDMAnimatorStatesStorage alloc] init];
    _defaultTiming = (MDMMotionTiming){
      .delay = 0.000,
      .duration = 0.300,
      .controlPoints = {0.4f, 0.0f, 0.2f, 1.0f}
    };
  }
  return self;
}

- (id<MDMAnimatorStates>)states {
  return _states;
}

- (id<MDMAnimatorOptions>)configurationForState {
  return _options;
}

- (id<MDMPropertyAnimator>)propertyAnimatorForProperty:(MDMMotionProperty)property {
  if ([self layer] && [property isEqualToString:@"cornerRadius"]) {
    return [[MDMLayerPropertyAnimator alloc] initWithLayer:[self layer]];

  } else if ([_object isKindOfClass:[UIView class]]) {
    return [[MDMViewPropertyAnimator alloc] initWithView:_object];
  }
  return nil;
}

#pragma mark - Animate

- (void)animateToValues:(NSDictionary<NSString *, id> *)values timing:(MDMMotionTiming)timing {
  [UIView animateWithDuration:timing.duration delay:timing.delay options:0 animations:^{
    for (NSString *keyPath in values) {
      id value = values[keyPath];

      if ([keyPath isEqualToString:@"x"]) {
        [self.layer setValue:value forKeyPath:@"position.x"];

      } else {
        [self setValue:value forKeyPath:keyPath];
      }
    }

  } completion: nil];
}

- (void)animateToValues:(NSDictionary<NSString *, id> *)values options:(id<MDMAnimationConfigurator>)keyedOptions {
  for (NSString *property in values) {
    id value = values[property];
    MDMMotionTiming timing;
    if (keyedOptions) {
      timing = [keyedOptions timingForProperty:property];

      if (timing.duration == MDMMotionTimingNone.duration) {
        timing = self.defaultTiming;
      }

      // TODO: Check for MDMMotionTimingInstantaneous

    } else {
      timing = self.defaultTiming;
    }

    id<MDMPropertyAnimator> animator = [self propertyAnimatorForProperty:property];
    [animator animateProperty:property to:value withTiming:timing];
  }
}

- (void)animateToValues:(NSDictionary<NSString *, id> *)values {
  [self animateToValues:values timing:self.defaultTiming];
}

- (void)animateToState:(NSString *)name {
  NSDictionary *state = self.states[name];
  id<MDMAnimationConfigurator> options = self.configurationForState[name];
  [self animateToValues:state options:options];
}

#pragma mark - Private

- (CALayer *)layer {
  CALayer *layer = nil;
  if ([_object isKindOfClass:[UIView class]]) {
    layer = [(UIView *)_object layer];
  } else if ([_object isKindOfClass:[CALayer class]]) {
    layer = _object;
  }
  return layer;
}

@end
