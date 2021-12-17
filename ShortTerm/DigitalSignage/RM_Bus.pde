void drawBusRModule(Area area) {
  RModule module = RModule.Bus;
  Size size = moduleSize(module);
  
  int x = layoutGuideX(area);
  int y = layoutGuideY(area);
  int w = moduleWidth(size);
  int h = moduleHeight(size);
  
  // 影を描画する。
  image(rmoduleShadowImage(size), x-SHADOW_PADDING, y-SHADOW_PADDING);
  // 背景画像を描画する。
  image(busBackground, x, y, w, h);
  
  String title = "函館バス（平日ダイヤ）";
  if (isHoliday) title = "函館バス（土日祝ダイヤ）";
  drawText(LEFT, BASELINE, WHITE_COLOR, 32, title, x+50, y+50);
  
  if (isUpdatedBus) {
    noStroke();
    fill(GREEN_COLOR);
    rect(x+50, y+120, w/2-100, 60);
    rect(x+w/2+50, y+120, w/2-100, 60);
    
    // 始点と終点のバス停名を表示し、間に矢印
    drawText(CENTER, BASELINE, WHITE_COLOR, 32, BUSSTOP_START, x+50+(w/2-100)/2, y+130);
    drawText(CENTER, BASELINE, WHITE_COLOR, 32, BUSSTOP_END, x+w/2+50+(w/2-100)/2, y+130);
    drawText(CENTER, BASELINE, WHITE_COLOR, 32, "→", x+w/2, y+130);
  
    int count = 0;
    for (int i = 0; i < lineNames.length; i++) {
      if (hour == departureHours[i]) {
        // すでに出発した便は飛ばす
        if (departureMinutes[i] < minute) continue;
        // 「13:00」のように発車時刻表示
        String time = nf(departureHours[i], 2) + ":" + nf(departureMinutes[i], 2);
        drawText(CENTER, BASELINE, WHITE_COLOR, 48, time, x+50+(w/2-100)/2, y+220+70*count-16);
        // 「67系統」のように系統名表示
        drawText(CENTER, BASELINE, WHITE_COLOR, 32, lineNames[i], x+w/2+50+(w/2-100)/2, y+220+70*count);
        // 「30分後」のように発車までの時間（分）表示、「67系統」のように系統名表示
        int remainMinute = departureMinutes[i] - minute;
        drawText(CENTER, BASELINE, WHITE_COLOR, 32, remainMinute+"分後", x+w/2, y+220+70*count);
        // 文字の下に緑の線を表示
        stroke(WHITE_COLOR, 50);
        line(x+50, y+255+70*count, x+w-50, y+260+70*count);
        
        count++;
      }
      if (hour < departureHours[i]) {
        String time = nf(departureHours[i], 2) + ":" + nf(departureMinutes[i], 2);
        drawText(CENTER, BASELINE, WHITE_COLOR, 48, time, x+50+(w/2-100)/2, y+220+70*count-16);
        
        drawText(CENTER, BASELINE, WHITE_COLOR, 32, lineNames[i], x+w/2+50+(w/2-100)/2, y+220+70*count);
        
        int remainMinute = (departureHours[i] - hour)*60 + (departureMinutes[i] - minute);
        drawText(CENTER, BASELINE, WHITE_COLOR, 32, remainMinute+"分後", x+w/2, y+220+70*count);
        // 文字の下に緑の線を表示
        stroke(WHITE_COLOR, 50);
        line(x+50, y+255+70*count, x+w-50, y+260+70*count);
        
        count++;
      }
      // 表示する2件が揃ったらこれ以降のダイヤは見ない
      if (count == 2) break;
    }

    image(busMap, x+50, y+h-(w-100)*9.0/16.0-50, w-100, (w-100)*9.0/16.0);
  } else {
    // 値が取得できなかったとき、エラーメッセージを表示
    fill(0, 0, 0, 50);
    noStroke();
    rect(x, y, w, h, RMODULE_RECT_ROUND);
    
    drawText(CENTER, CENTER, WHITE_COLOR, 24, "BusModule\nデータを取得できません", x+w/2, y+h/2);
  }
}

boolean updateBus() {
  final String[] keys = {"line_name", "departure_hour", "departure_minute", "is_holiday"};
  
  try {
    processing.data.JSONArray json = loadJSONArray(BUS_API_URL);
    
    // 平日なら平日ダイヤ、土日祝なら土日祝ダイヤだけの数を数える。
    int dataCount = 0;
    for (int row = 0; row < json.size(); row++) {
      if (json.getJSONObject(row).getBoolean(keys[3]) == isHoliday) {
        dataCount++;
      }
    }
  
    lineNames = new String[dataCount];
    departureHours = new int[dataCount];
    departureMinutes = new int[dataCount];
    
    // JSONから系統名、時刻を取り出して保存。
    int i = 0;
    for (int row = 0; row < json.size(); row++) {
      processing.data.JSONObject obj = json.getJSONObject(row);
      if (obj.getBoolean(keys[3]) == isHoliday) {
        lineNames[i] = obj.getString(keys[0]);
        departureHours[i] = obj.getInt(keys[1]);
        departureMinutes[i] = obj.getInt(keys[2]);
        println("[" + lineNames[i] + "] " + nf(departureHours[i], 2) + ":" + nf(departureMinutes[i], 2));
        i++;
      }
    }
    
    println("updateBus(): バス時刻表を取得しました。");
  } catch (Exception e) {
    println("updateBus(): バス時刻表を取得できませんでした。" + e);
    return false;
  }
  
  return true;
}
