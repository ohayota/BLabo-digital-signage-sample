void drawPageControlModule() {
  for (int page = 0; page < PAGE_ALL_COUNT; page++) {
    // ページ番号をもとに点を横に並べる
    float x = width/2 + 30 * (page-(PAGE_ALL_COUNT-1)/2.0);
    float y = 1020;
    // 現在のページだけは白の点（緑の枠線付き）、それ以外は緑の点を打つ
    if (page == nowPageID) {
      fill(WHITE_COLOR);
      stroke(GREEN_COLOR);
      strokeWeight(5);
      circle(x, y, 20);
    } else {
      fill(GREEN_COLOR);
      noStroke();
      circle(x, y, 15);
    }
  }
}
