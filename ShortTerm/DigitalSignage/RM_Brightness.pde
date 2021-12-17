void drawBrightnessRModule(Area area) {
  RModule module = RModule.Brightness;
  Size size = moduleSize(module);
  
  int x = layoutGuideX(area);
  int y = layoutGuideY(area);
  int w = moduleWidth(size);
  int h = moduleHeight(size);
  
  // 影を描画する。
  image(rmoduleShadowImage(size), x-SHADOW_PADDING, y-SHADOW_PADDING);
  
  if (isUpdatedBrightness) {
    // 明るい／暗いによって、異なる背景画像を描画する。
    if (isBright) {
      image(brightnessBackgroundBright, x, y, w, h);
    } else {
      image(brightnessBackgroundNotBright, x, y, w, h);
    }
    drawText(LEFT, BASELINE, WHITE_COLOR, 32, "明るさ", x+50, y+50);
    // 温度表示
    drawText(CENTER, BASELINE, WHITE_COLOR, 96, int(brightnessRate)+"%", x+w/2, y+150);
  } else {
    // 値が取得できなかったとき、エラーメッセージを表示
    fill(0, 0, 0, 50);
    noStroke();
    rect(x, y, w, h, RMODULE_RECT_ROUND);
    
    drawText(CENTER, CENTER, WHITE_COLOR, 24, "BrightnessModule\nデータを取得できません", x+w/2, y+h/2);
  }
}

// 明るさを取得する。
boolean updateBrightness() {
  try {
    byte[] out = { byte(0x68), byte(0x00) };
    byte[] in = spi.transfer(out);
    int brightnessValue = ((in[0] << 8) + in[1]) & 0x3FF;
    isBright = (300 <= brightnessValue);
    brightnessRate = brightnessValue*100 / 1023.0;
    println("updateBrightness(): brightnessValue=" + brightnessValue,
            "brightnessRate=" + brightnessRate + "%",
            "isBright=" + isBright);
    println("updateBrightness(): 光センサから明るさを取得しました。brightnessRate = " + brightnessRate);
  } catch (Exception e) {
    println("updateBrightness(): 光センサから明るさを取得できませんでした。" + e);
    return false;
  }
  
  return true;
}
