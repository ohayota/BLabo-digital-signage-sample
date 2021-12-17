void drawGomiRModule(Area area) {
  RModule module = RModule.Gomi;
  Size size = moduleSize(module);
  
  int x = layoutGuideX(area);
  int y = layoutGuideY(area);
  int w = moduleWidth(size);
  int h = moduleHeight(size);
  
  // 影を描画する。
  image(rmoduleShadowImage(size), x-SHADOW_PADDING, y-SHADOW_PADDING);
  // 背景画像を描画する。
  image(gomiBackground, x, y, w, h);
  
  drawText(LEFT, BASELINE, WHITE_COLOR, 32, "美原2丁目のごみカレンダー", x+50, y+50);
  drawText(LEFT, BASELINE, WHITE_COLOR, 16, "ごみカレンダー提供元: Code for Hakodate", x+50, y+100);
  
  if (isUpdatedGomi) {
    textAlign(LEFT, TOP);
    // 今日の回収ごみは大きく表示する。
    for (int i = 0; i <= 0; i++) {
      GomiTarget target = gomiTargets[i];
      fill(gomiTargetToColor(target));
      rect(x+50, y+150+(h-150)*i/7.0, w-100, 70);
      drawText(LEFT, BASELINE, BLACK_COLOR, 40, gomiDows[i]+"    "+gomiTargetToString(target), x+50+10, y+160+(h-150)*i/7);
    }
    // 1日後〜3日後までの回収ごみは小さく3行で左側に表示する。
    for (int i = 1; i <= 3; i++) {
      GomiTarget target = gomiTargets[i];
      fill(gomiTargetToColor(target));
      rect(x+50, y+240+(h-150)*(i-1)/7.0, (w-100)/2-20, 32);
      drawText(LEFT, BASELINE, BLACK_COLOR, 24, gomiDows[i]+"    "+gomiTargetToString(target), x+50+10, y+242+(h-150)*(i-1)/7);
    }
    // 4日後〜6日後までの回収ごみは小さく3行で右側に表示する。
    for (int i = 4; i <= 6; i++) {
      GomiTarget target = gomiTargets[i];
      fill(gomiTargetToColor(target));
      rect(x+50+(w-100)/2+20, y+240+(h-150)*(i-4)/7.0, (w-100)/2-20, 32);
      drawText(LEFT, BASELINE, BLACK_COLOR, 24, gomiDows[i]+"    "+gomiTargetToString(target), x+50+10+(w-100)/2+20, y+242+(h-150)*(i-4)/7);
    }
  } else {
    // 値が取得できなかったとき、エラーメッセージを表示。
    fill(0, 0, 0, 50);
    noStroke();
    rect(x, y, w, h, RMODULE_RECT_ROUND);
    
    drawText(CENTER, BASELINE, WHITE_COLOR, 24, "GomiModule\nデータを取得できません", x+w/2, y+h/2);
  }
}

boolean updateGomi() {
  final String[] keys = {"Date(YYYY/MM/DD)", "dow", "area:2"};
  
  gomiDows = new String[7];
  gomiTargets = new GomiTarget[7];

  String today = year + "/" + nf(month, 2) + "/" + nf(day, 2);
  println(today);

  try {
    processing.data.JSONArray json = loadJSONArray(GOMI_API_URL);

    int todayRowNum = Integer.MAX_VALUE;
    for (int row = 0; row < json.size(); row++) {
      processing.data.JSONObject obj = json.getJSONObject(row);
      if (obj.getString(keys[0]).equals(today)) {
        todayRowNum = row;
        break;
      }
    }

    if (todayRowNum == Integer.MAX_VALUE) throw new Exception();

    for (int i = 0; i < 7; i++) {
      int row = todayRowNum + i;
      processing.data.JSONObject obj = json.getJSONObject(row);
      String gomiTargetString = obj.getString(keys[2]);
      switch (gomiTargetString) {
      case "燃やせるごみ":
        gomiTargets[i] = GomiTarget.Moyaseru;
        break;
      case "燃やせないごみ":
        gomiTargets[i] = GomiTarget.Moyasenai;
        break;
      case "プラスチック容器包装":
        gomiTargets[i] = GomiTarget.Plastic;
        break;
      case "缶・びん・ペットボトル":
        gomiTargets[i] = GomiTarget.CanBinPet;
        break;
      default:
        gomiTargets[i] = GomiTarget.None;
      }
      String gomiDowString = obj.getString(keys[1]);
      gomiDows[i] = gomiDowString;
      println("[" + gomiDowString + "] " + gomiTargetString);
    }

    println("updateGomi(): ごみカレンダーを取得しました。");
  } 
  catch (Exception e) {
    println("updateGomi(): 本日分のごみカレンダーを取得できませんでした。" + e);
    return false;
  }
  
  return true;
}

String gomiTargetToString(GomiTarget target) {
  switch (target) {
  case Moyaseru:
    return "燃やせるごみ";
  case Moyasenai:
    return "燃やせないごみ";
  case Plastic:
    return "プラスチック容器包装";
  case CanBinPet:
    return "缶・びん・ペットボトル";
  default:
    return "";
  }
}

color gomiTargetToColor(GomiTarget target) {
  switch (target) {
  case Moyaseru:
    return color(340, 30, 100);
  case Moyasenai:
    return color(130, 30, 80);
  case Plastic:
    return color(30, 30, 100);
  case CanBinPet:
    return color(210, 30, 100);
  default:
    return color(0, 0, 90);
  }
}
