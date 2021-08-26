@interface ABSBrightnessManager : NSObject
-(id)initWithAutoBrightnessEnabled:(BOOL)enabled;
-(void)setBrightness:(float)amount;
-(float)brightness;
-(BOOL)whitePointEnabled;
-(void)setWhitePointEnabled:(BOOL)enabled;
-(void)setWhitePointLevel:(float)amount;
-(float)whitePointLevel;
-(void)setAutoBrightnessEnabled:(BOOL)enabled;
@end
