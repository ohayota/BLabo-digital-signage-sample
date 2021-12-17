void drawDateModule() {
  // 文字が画像と同化するのを避けるため、背景画像の色に応じて文字色反転。
  blendMode(EXCLUSION);
  
  String timeText = month + "月" + day + "日" + "（" + youbiString + "）" + nf(hour, 2) + ":" + nf(minute, 2) + ":" + nf(second, 2);
  drawText(LEFT, BASELINE, WHITE_COLOR, 36, timeText, 100, 30);
  
  // 他モジュールの描画時にも色が反転してしまうため、もとに戻す。
  blendMode(BLEND);
}

void updateDate() {
  year = year();
  month = month();
  day = day();
  hour = hour();
  minute = minute();
  second = second();
}

// Zellerの公式を使った曜日計算
Youbi calcYoubi(int year, int month, int day) {
  final Youbi[] youbi = Youbi.values();
  if (month < 3) {
    year--;
    month += 12;
  }
  return youbi[(year+year/4-year/100+year/400+(13*month+8)/5+day)%7];
}

// 曜日を日本語表記にする。月〜金でも祝日の場合は「月・祝」のように表示。
String youbiToString(Youbi youbi) {
  String str = "";
  switch (youbi) {
    case Sun:
      str = "日";
      break;
    case Mon:
      str = "月";
      if (isHoliday) str += "・祝";
      break;
    case Tue:
      str = "火";
      if (isHoliday) str += "・祝";
      break;
    case Wed:
      str = "水";
      if (isHoliday) str += "・祝";
      break;
    case Thu:
      str = "木";
      if (isHoliday) str += "・祝";
      break;
    case Fri:
      str = "金";
      if (isHoliday) str += "・祝";
      break;
    case Sat:
      str = "土";
      break;
  }
  return str;
}

// 祝日APIを使い、今日が土日祝のいずれかに当てはまるかを取得。
boolean updateIsHoliday() {
  try {
    URL url = new URL("http://s-proj.com/utils/checkHoliday.php");
    InputStream is = url.openStream();
    InputStreamReader isr = new InputStreamReader(is, "utf8");
    BufferedReader br = new BufferedReader(isr);
    isHoliday = br.readLine().equals("holiday");
  } catch (Exception e) {
    println("isHoliday(): 土日祝判定を取得できませんでした。" + e);
    return false;
  }
  
  print("isHoliday(): 土日祝判定を取得しました。");
  if (isHoliday) {
    println("今日は土日祝に含まれます。");
  } else {
    println("今日は平日です。");
  }
  
  return true;
}
