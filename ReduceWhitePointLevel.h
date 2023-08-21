#if defined __cplusplus
extern "C" {
#endif

void MADisplayFilterPrefSetReduceWhitePointIntensity(CGFloat intenity);
CGFloat MADisplayFilterPrefGetReduceWhitePointIntensity();

typedef struct BKSDisplayBrightnessTransaction *BKSDisplayBrightnessTransactionRef;
BKSDisplayBrightnessTransactionRef BKSDisplayBrightnessTransactionCreate(CFAllocatorRef allocator);
void BKSDisplayBrightnessSet(float amount, int _unknown);

#if defined __cplusplus
};
#endif
