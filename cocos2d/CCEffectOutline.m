//
//  CCEffectOutline.m
//  cocos2d
//
//  Created by Oleg Osin on 12/3/14.
//
//

#import "CCEffectOutline.h"
#import "CCEffect_Private.h"
#import "CCSprite_Private.h"
#import "CCTexture.h"
#import "CCSpriteFrame.h"

@implementation CCEffectOutline

-(id)init
{
    return [self initWithOutlineColor:[CCColor redColor] outlineWidth:2 outlinePosition:kCCEffectOutlineInside];
}

-(id)initWithOutlineColor:(CCColor*)outlineColor outlineWidth:(int)outlineWidth outlinePosition:(CCEffectOutlinePosition)outlinePosition
{
    NSArray *uniforms = @[
                          [CCEffectUniform uniform:@"vec4" name:@"u_outlineColor" value:[NSValue valueWithGLKVector4:outlineColor.glkVector4]],
                          [CCEffectUniform uniform:@"vec2" name:@"u_stepSize" value:[NSValue valueWithGLKVector2:GLKVector2Make(0.01, 0.01)]],
                          [CCEffectUniform uniform:@"float" name:@"u_currentPass" value:[NSNumber numberWithFloat:0.0]],
                          [CCEffectUniform uniform:@"float" name:@"u_outlinePosition" value:[NSNumber numberWithFloat:outlinePosition]]
                          ];
    
    if((self = [super initWithFragmentUniforms:uniforms vertexUniforms:nil varyings:nil]))
    {
        self.outlineWidth = outlineWidth;
        _outlineColor = outlineColor;
        _outlinePosition = outlinePosition;
        
        self.debugName = @"CCEffectOutline";
    }
    return self;
}

+(id)effectWithOutlineColor:(CCColor*)outlineColor outlineWidth:(int)outlineWidth outlinePosition:(CCEffectOutlinePosition)outlinePosition
{
    return [[self alloc] initWithOutlineColor:outlineColor outlineWidth:outlineWidth outlinePosition:outlinePosition];
}

-(void)buildFragmentFunctions
{
    self.fragmentFunctions = [[NSMutableArray alloc] init];
    
    NSString* effectBody = CC_GLSL(
                                   
                                   // Use Laplacian matrix / filter to find the edges
                                   // Apply this kernel to each pixel
                                   /*
                                    0 -1  0
                                   -1  4 -1
                                    0 -1  0
                                    */
                                   
                                   // 5.2hrs of work so far
                                   
                                   vec2 uv = cc_FragTexCoord1;
                                   vec4 color = texture2D(cc_MainTexture, cc_FragTexCoord1);
                                   
                                   float alpha = 4.0 * color.a;
                                   alpha -= texture2D(cc_MainTexture, uv + vec2(u_stepSize.x, 0.0)).a;
                                   alpha -= texture2D(cc_MainTexture, uv + vec2(-u_stepSize.x, 0.0)).a;
                                   alpha -= texture2D(cc_MainTexture, uv + vec2(0.0, u_stepSize.y)).a;
                                   alpha -= texture2D(cc_MainTexture, uv + vec2(0.0, -u_stepSize.y)).a;
                                   
                                   // outside / center
                                   if(alpha < 0.0 && (u_outlinePosition == 2.0 || u_outlinePosition == 0.0))
                                   {
                                       alpha *= -1.0;
                                   }
                                   
                                   // outside
                                   if(color.a <= 0.0 && u_outlinePosition == 2.0)
                                   {
                                       color = mix(color, u_outlineColor, alpha);
                                   }
                                   else if(u_outlinePosition == 1.0 || u_outlinePosition == 0.0) // inside / center
                                   {
                                       color = mix(color, u_outlineColor, alpha);
                                   }
                                                                      
                                   return color;
                                   
                                   );
    
    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"outlineEffect"
                                                                           body:effectBody inputs:nil returnType:@"vec4"];
    [self.fragmentFunctions addObject:fragmentFunction];
}

-(void)buildVertexFunctions
{
    self.vertexFunctions = [[NSMutableArray alloc] init];
    
    NSString* effectBody = CC_GLSL(
                                   return cc_Position;
                                   );
    
    CCEffectFunction* vertexFunction = [[CCEffectFunction alloc] initWithName:@"outlineEffect"
                                                                           body:effectBody inputs:nil returnType:@"vec4"];
    [self.vertexFunctions addObject:vertexFunction];
}

-(void)buildRenderPasses
{
    __weak CCEffectOutline *weakSelf = self;
    
    CCEffectRenderPass *pass0 = [[CCEffectRenderPass alloc] init];
    pass0.debugLabel = @"CCEffectOutline pass 0";
    pass0.shader = self.shader;
    pass0.blendMode = [CCBlendMode premultipliedAlphaMode];
    pass0.beginBlocks = @[[^(CCEffectRenderPass *pass, CCEffectRenderPassInputs *passInputs) {
        
        passInputs.shaderUniforms[CCShaderUniformMainTexture] = passInputs.previousPassTexture;
        passInputs.shaderUniforms[CCShaderUniformPreviousPassTexture] = passInputs.previousPassTexture;
        passInputs.shaderUniforms[weakSelf.uniformTranslationTable[@"u_outlineColor"]] = [NSValue valueWithGLKVector4:weakSelf.outlineColor.glkVector4];

        float outlineWidth = (float)_outlineWidth;
        if(_outlinePosition == kCCEffectOutlineCenter)
        {
            outlineWidth *= 0.5f;
        }
        
        GLKVector2 stepSize = GLKVector2Make(outlineWidth / passInputs.previousPassTexture.contentSize.width,
                                             outlineWidth / passInputs.previousPassTexture.contentSize.height);
        
        passInputs.shaderUniforms[weakSelf.uniformTranslationTable[@"u_stepSize"]] = [NSValue valueWithGLKVector2:stepSize];
        passInputs.shaderUniforms[weakSelf.uniformTranslationTable[@"u_currentPass"]] = [NSNumber numberWithFloat:0.0f];
        passInputs.shaderUniforms[weakSelf.uniformTranslationTable[@"u_outlinePosition"]] = [NSNumber numberWithFloat:_outlinePosition];
        
    } copy]];
    
    self.renderPasses = @[pass0];
}

@end
