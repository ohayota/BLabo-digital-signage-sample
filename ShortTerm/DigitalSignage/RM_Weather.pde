void drawWeatherRModule(Area area) {
  RModule module = RModule.Weather;
  Size size = moduleSize(module);
  
  int x = layoutGuideX(area);
  int y = layoutGuideY(area);
  int w = moduleWidth(size);
  int h = moduleHeight(size);
  
  // 影を描画する。
  image(rmoduleShadowImage(size), x-SHADOW_PADDING, y-SHADOW_PADDING);
  image(weatherBackground, x, y, w, h);
  
  drawText(LEFT, BASELINE, WHITE_COLOR, 32, "現在の天気", x+50, y+50);
  drawText(LEFT, BASELINE, WHITE_COLOR, 16, "気象データ提供元: OpenWeather(TM)", x+50, y+100);
  
  if (isUpdatedWeather) {
    drawText(LEFT, BASELINE, WHITE_COLOR, 64, int(temperature)+"℃ / "+humidity+"%", x+50, y+160);
    drawText(LEFT, BASELINE, WHITE_COLOR, 42, weatherString, x+50, y+260);
    image(weatherIcon, x+w-h, y+50, h, h);
  } else {
    // 値が取得できなかったとき、エラーメッセージを表示
    fill(0, 0, 0, 50);
    noStroke();
    rect(x, y, w, h, RMODULE_RECT_ROUND);
    
    drawText(CENTER, CENTER, WHITE_COLOR, 24, "WeatherRModule\nデータを取得できません", x+w/2, y+h/2);
  }
}


boolean updateWeather() {
  try {
    // 現在の天気を取得する
    final String url = openWeatherURL(LATITUDE, LONGITUDE, WEATHER_API_KEY);
    final processing.data.JSONObject json = loadJSONObject(url);
    final processing.data.JSONObject current = json.getJSONObject("current");
    final processing.data.JSONArray weather = current.getJSONArray("weather");
    
    // 天気の説明、温度、湿度を取得
    weatherString = weather.getJSONObject(0).getString("description");
    temperature = current.getFloat("temp");
    humidity = current.getInt("humidity");
    
    // 現在の天気に対応する画像を持ってくる
    final String iconCode = weather.getJSONObject(0).getString("icon");
    weatherIcon = loadImage("http://openweathermap.org/img/wn/" + iconCode + "@2x.png");

    println("updateWeather(): 天気情報を取得しました。");
    return true;
  } catch (Exception e) {
    println("updateWeather(): 天気情報を取得できませんでした。" + e);
    return false;
  }
}


String openWeatherURL(float latitude, float longitude, String apiKey) {
  return "https://api.openweathermap.org/data/2.5/onecall?" +
         "lat=" + latitude + "&lon=" + longitude +
         "&units=metric&lang=ja&appid=" + apiKey;
}
