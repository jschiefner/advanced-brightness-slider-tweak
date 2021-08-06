@interface BrightnessManager : NSObject
-(id)init;
-(void)setBrightness:(float)amount;
-(float)brightness;
-(BOOL)whitePointEnabled;
-(void)setWhitePointEnabled:(BOOL)enabled;
-(void)setWhitePointLevel:(float)amount;
-(float)whitePointLevel;
-(void)setAutoBrightnessEnabled:(BOOL)enabled;
@end
