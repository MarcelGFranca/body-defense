## Decisions

- Zoom is the Camera2D zoom of the 360 x 640 pixel-art viewport, so the art stays crisp (nearest filter) and the 2x upscale is unchanged. Tap radius grows when zoomed out so slots stay tappable. Verified on the Android emulator with the buttons; the pinch uses ScreenTouch/ScreenDrag and magnify gestures and needs a real phone to confirm.
