//
//  CCEffectOutline.h
//  cocos2d
//
//  Created by Oleg Osin on 12/3/14.
//
//

#import "CCEffect.h"

typedef enum CCEffectOutlinePosition {
    kCCEffectOutlineCenter = 0,
    kCCEffectOutlineInside,
    kCCEffectOutlineOutside
} CCEffectOutlinePosition;


/**
 * CCEffectOutline create an outline around a sprite.
 *
 */

@interface CCEffectOutline : CCEffect

/// -----------------------------------------------------------------------
/// @name Accessing Effect Attributes
/// -----------------------------------------------------------------------

/** Color of the outline */
@property (nonatomic, strong) CCColor* outlineColor;

/** Outline pixel width of the outline */
@property (nonatomic) int outlineWidth;

/** Defines outline alignment */
@property (nonatomic) CCEffectOutlinePosition outlinePosition;

/// -----------------------------------------------------------------------
/// @name Initializing a CCEffectDFOutline object
/// -----------------------------------------------------------------------

/**
 *  Initializes a CCEffectDFOutline.
 *
 *  @return The CCEffectDFOutline object.
 */
-(id)init;

/**
 *  Initializes a CCEffectOutline object with the supplied parameters.
 *
 *  @param outlineColor Color of the outline, a [CCColor blackColor] will result in an opaque black outline.
 *  @param outlineWidth pixel width of the outline.
 *  @param outlinePosition defines where the outline alignment (center, inside, outside)
 *
 *  @return The CCEffectOutline object.
 */
-(id)initWithOutlineColor:(CCColor*)outlineColor outlineWidth:(int)outlineWidth outlinePosition:(CCEffectOutlinePosition)outlinePosition;
+(id)effectWithOutlineColor:(CCColor*)outlineColor outlineWidth:(int)outlineWidth outlinePosition:(CCEffectOutlinePosition)outlinePosition;

@end
