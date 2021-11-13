
[![Get it on Packix](https://img.shields.io/badge/download-Get%20it%20from%20Packix-green?logo=Hack%20The%20Box)](https://repo.packix.com/package/com.jschiefner.advancedbrightnessslider/)
[![Donate on PayPal](https://img.shields.io/badge/paypal-donate-blue?logo=paypal)](https://paypal.me/JonasSchiefner)

# AdvancedBrightnessSlider Tweak

<img src="https://github.com/jschiefner/advanced-brightness-slider-tweak/blob/main/screenshots/explanation.png?raw=true" width="200" alt="Slider in Control Center" align="right">

This is an iOS Tweak that modifies the brightness slider in the Control Center. Even with dark mode toggled on, I found the display to be quite bright when reading in the dark. With this tweak, it becomes possible to dim the iPhone even below the regular minimum brightness allowed right from the control center. This tweak takes advantage of the `Reduce White Point` Setting usually found in `Settings > Accessibility > Display & Text Size > Reduce White Point`. When the brightness slider goes below a certain threshold, the brightness goes to zero and the `Reduce White Point` setting is activated. Sliding below that threshold then modifies the `Reduce White Point intensity`, instead of the usual brightness which is zero at that point. As well, the `Auto Brightness` feature of iOS is toggled off when the slider is below the threshold to prevent iOS from raising the brightness in that state.

### Support

Supports iOS 13 & 14!

Other Tweaks:
 - Prysm (Control Center alternative available on [Packix](https://repo.packix.com/package/com.laughingquoll.prysm/)), tested with version 1.9.1
 - BigSurCenter (Control Center alternative available on [Twickd](https://repo.twickd.com/get/com.twickd.nicho1asdev.bigsurcenter)), tested with version 1.2.1

### How it works

This tweak hooks into `CCUIContinuousSliderView` provided by `ControlCenterUIKit.framework`. This class represents the two sliders in the control center (brightness & volume). System API calls can be found in the [ABSManager Implementation File](ABSManager.xm).

### Credits
 - [@opa334](https://github.com/opa334) who created a similar tweak [WhitePointModule](https://github.com/opa334/WhitePointModule) where I found the [API]() to manipulate the `Reduce White Point intensity`
 - [@rpetrich](https://github.com/rpetrich) who helped made the [FlipSwitch](https://github.com/a3tweaks/Flipswitch) library where i found the API to manipulate the `Auto Brightness` Setting.
 - [@zaneh](https://github.com/zaneh) who made a great [Video Series](https://www.youtube.com/playlist?list=PLFWEDfSyl7h_K8Ew4rwTzlUPgWU7nKYri) on developing iOS Tweaks.
