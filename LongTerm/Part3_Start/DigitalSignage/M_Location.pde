void drawLocationModule() {
  // 文字が画像と同化するのを避けるため、背景画像の色に応じて文字色反転。
  blendMode(EXCLUSION);
  
  drawText(RIGHT, BASELINE, WHITE_COLOR, 36, LOCATION, width-100, 30);
  
  // 他モジュールの描画時にも色が反転してしまうため、もとに戻す。
  blendMode(BLEND);
}
