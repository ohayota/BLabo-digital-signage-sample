void drawTemperatureRModule(Area area) {
  RModule module = RModule.Temperature;
  Size size = moduleSize(module);
  
  int x = layoutGuideX(area);
  int y = layoutGuideY(area);
  int w = moduleWidth(size);
  int h = moduleHeight(size);
  
  // 影を描画する。
  image(rmoduleShadowImage(size), x-SHADOW_PADDING, y-SHADOW_PADDING);
  // 背景画像を描画する。
  image(temperatureBackground, x, y, w, h);
    
  // モジュールの名前表示
  drawText(LEFT, BASELINE, WHITE_COLOR, 32, "室温", x+50, y+50);
  
  if (isUpdatedTemperature) {
    // 温度表示
    drawText(CENTER, BASELINE, WHITE_COLOR, 96, nf(roomTempValue, 0, 1)+"℃", x+w/2, y+150);
  } else {
    // 値が取得できなかったとき、エラーメッセージを表示
    fill(0, 0, 0, 50);
    noStroke();
    rect(x, y, w, h, RMODULE_RECT_ROUND);
    
    drawText(CENTER, CENTER, WHITE_COLOR, 24, "TemperatureModule\nデータを取得できません", x+w/2, y+h/2);
  }
}

boolean updateTemperature() {
  try {
    i2c.beginTransmission(0x48);
    i2c.write(0xC0);
    byte[] v = i2c.read(2);
    i2c.endTransmission();
    
    int temp = ((v[0] & 0x1F) * 256 + (v[1] & 0xFF));
    if (4096 <= temp) {
      temp -= 8192;
    }
  
    roomTempValue = temp * 0.0078;
    
    println("updateTemperature(): 温度センサから気温を取得しました。roomTempValue = " + roomTempValue);
  } catch (Exception e) {
    roomTempValue = 0.0;
    println("updateTemperature(): 温度センサから気温を取得できませんでした。" + e);
    return false;
  }
  
  return true;
}
