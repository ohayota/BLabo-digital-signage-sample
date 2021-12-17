void drawProgressBarModule() {
  // 残り秒数を割合として算出（%）
  float progressRate = (second % STAY_SECOND) / float(STAY_SECOND-1);
  // 時間が経過したぶんだけ、白いバーが緑で塗りつぶされていく
  noStroke();
  fill(WHITE_COLOR);
  rect(0, height-PROGRESSBAR_HEIGHT, width, PROGRESSBAR_HEIGHT);
  fill(GREEN_COLOR);
  rect(0, height-PROGRESSBAR_HEIGHT, width * progressRate, PROGRESSBAR_HEIGHT);
}
