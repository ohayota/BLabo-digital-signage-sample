// デジタルサイネージの起動時のみ実行する関数。
void initialize() {
  initializeDate();
  isInitializedDates = true;
  
  initializeImage();
  initializeGrid();
  initializePlaceholder();
  initializeShadow();
  initializeRModuleBackground();
  isInitializedImages = true;
  
  //isUpdatedWeather = updateWeather();
  isInitializedWeather = true;
  
  //isUpdatedBus = updateBus();
  isInitializedBus = true;
  
  //isUpdatedGomi = updateGomi();
  isInitializedGomi = true;
  
  //isUpdatedTwitter = updateTwitter();
  isInitializedTwitter = true;
  
  //isUpdatedOpenClose = updateOpenClose();
  //isUpdatedTemperature = updateTemperature();
  //isUpdatedBrightness = updateBrightness();
  
  updateNowPageID(true);
}

// 日付関連を初期化する。
void initializeDate() {
  updateDate();
  // 祝日APIの値が取得できなければ、ネットワークかAPI側のどちらかの問題
  if (!updateIsHoliday()) println("initializeDate(): ネットワークに接続できているか確認してください。");
  youbi = calcYoubi(year(), month(), day());
  youbiString = youbiToString(youbi);
}

// 必要な画像素材を読み込む。
void initializeImage() {
  busMap = pImageCut(loadImage(BUS_PATH + "bus_map.jpg"), CENTER, CENTER, 1280, 720);
  adImage = new PImage[AD_IMAGE_COUNT];
  for (int i = 0; i < AD_IMAGE_COUNT; i++) {
    adImage[i] = loadImage(AD_PATH + "ad" + i + ".jpg");
  }
  dummy360x360 = loadImage(DUMMY_PATH + "360x360.jpg");
}

// RModuleを描画する基準となる場所を示すグリッドを生成。
void initializeGrid() {
  // 画面と同じサイズのPGraphicsを作成。
  grid = createGraphics(width, height);
  grid.beginDraw();
  grid.colorMode(HSB, 360, 100, 100, 100);
  grid.stroke(0, 0, 50); // グレーの線を描画するように設定。
  grid.strokeWeight(3); // 少し太めの線にする。
  // 垂直方向の基準線を描画。
  grid.line(layoutGuideX(Area.area1), 0, layoutGuideX(Area.area1), height);
  grid.line(layoutGuideX(Area.area2), 0, layoutGuideX(Area.area2), height);
  grid.line(layoutGuideX(Area.area3), 0, layoutGuideX(Area.area3), height);
  grid.line(layoutGuideX(Area.area4), 0, layoutGuideX(Area.area4), height);
  // 水平方向の基準線を描画。
  grid.line(0, layoutGuideY(Area.area1), width, layoutGuideY(Area.area1));
  grid.line(0, layoutGuideY(Area.area5), width, layoutGuideY(Area.area5));
  grid.endDraw();
}

// RModuleが表示されるべき場所に表示される角丸の四角を生成。
void initializePlaceholder() {
  placeholder = createGraphics(width, height);
  placeholder.beginDraw();
  placeholder.colorMode(HSB, 360, 100, 100, 100);
  for (Area area: Area.values()) {
    // モジュール配置エリアに角丸四角の枠を描く
    placeholder.noFill();
    placeholder.stroke(0, 0, 50);
    placeholder.strokeWeight(5);
    placeholder.rect(layoutGuideX(area), layoutGuideY(area),
                     moduleWidth(Size.S), moduleHeight(Size.S),
                     RMODULE_RECT_ROUND);
  }
  
  placeholder.endDraw();
}

// RModuleのうしろに描画する影を生成。
void initializeShadow() {
  Size size;
  int w;
  int h;
  
  // 影はモジュールよりも少し大きいサイズにする
  size = Size.S;
  w = moduleWidth(size) + SHADOW_PADDING * 2;
  h = moduleHeight(size) + SHADOW_PADDING * 2;
  
  // 影の画像を生成する
  moduleShadowS = createGraphics(w, h);
  moduleShadowS.beginDraw();
  moduleShadowS.colorMode(HSB, 360, 100, 100, 100);
  moduleShadowS.noStroke();
  moduleShadowS.fill(0, 0, 0, SHADOW_ALPHA);
  moduleShadowS.rect(SHADOW_PADDING, SHADOW_PADDING,
                     moduleWidth(size), moduleHeight(size),
                     RMODULE_RECT_ROUND);
  moduleShadowS.filter(BLUR, 8); // にじませる
  moduleShadowS.endDraw();
  
  // 影はモジュールよりも少し大きいサイズにする
  size = Size.M;
  w = moduleWidth(size) + SHADOW_PADDING * 2;
  h = moduleHeight(size) + SHADOW_PADDING * 2;
  
  // 影の画像を生成する
  moduleShadowM = createGraphics(w, h);
  moduleShadowM.beginDraw();
  moduleShadowM.colorMode(HSB, 360, 100, 100, 100);
  moduleShadowM.noStroke();
  moduleShadowM.fill(0, 0, 0, SHADOW_ALPHA);
  moduleShadowM.rect(SHADOW_PADDING, SHADOW_PADDING,
                     moduleWidth(size), moduleHeight(size),
                     RMODULE_RECT_ROUND);
  moduleShadowM.filter(BLUR, 8); // にじませる
  moduleShadowM.endDraw();
  
  // 影はモジュールよりも少し大きいサイズにする
  size = Size.L;
  w = moduleWidth(size) + SHADOW_PADDING * 2;
  h = moduleHeight(size) + SHADOW_PADDING * 2;
  
  // 影の画像を生成する
  moduleShadowL = createGraphics(w, h);
  moduleShadowL.beginDraw();
  moduleShadowL.colorMode(HSB, 360, 100, 100, 100);
  moduleShadowL.noStroke();
  moduleShadowL.fill(0, 0, 0, SHADOW_ALPHA);
  moduleShadowL.rect(SHADOW_PADDING, SHADOW_PADDING,
                     moduleWidth(size), moduleHeight(size),
                     RMODULE_RECT_ROUND);
  moduleShadowL.filter(BLUR, 8); // にじませる
  moduleShadowL.endDraw();
}

// 各RModuleの背景を作成。
void initializeRModuleBackground() {
  RModule module;
  int w;
  int h;
  PImage back;
  
  module = RModule.Weather;
  w = moduleWidth( moduleSize(module) );
  h = moduleHeight( moduleSize(module) );
  back = loadImage(WEATHER_PATH + "background.jpg");
  weatherBackground = createGraphics(w, h);
  weatherBackground.beginDraw();
  weatherBackground.colorMode(HSB, 360, 100, 100, 100);
  weatherBackground.image( pImageCut(back, CENTER, CENTER, w, h) , 0, 0);
  weatherBackground.fill(0, 0, 0, 40);
  weatherBackground.noStroke();
  weatherBackground.rect(0, 0, w, h);
  weatherBackground.endDraw();
  // 背景画像を角丸四角の形に合わせてくり抜く。
  weatherBackground.mask( sizeToModuleMask( moduleSize(module) ) );
  
  module = RModule.Bus;
  w = moduleWidth( moduleSize(module) );
  h = moduleHeight( moduleSize(module) );
  back = loadImage(BUS_PATH + "background.jpg");
  busBackground = createGraphics(w, h);
  busBackground.beginDraw();
  busBackground.colorMode(HSB, 360, 100, 100, 100);
  busBackground.image( pImageCut(back, CENTER, CENTER, w, h) , 0, 0);
  busBackground.fill(0, 0, 0, 40);
  busBackground.noStroke();
  busBackground.rect(0, 0, w, h);
  busBackground.endDraw();
  // 背景画像を角丸四角の形に合わせてくり抜く。
  busBackground.mask( sizeToModuleMask( moduleSize(module) ) );
  
  module = RModule.Gomi;
  w = moduleWidth( moduleSize(module) );
  h = moduleHeight( moduleSize(module) );
  back = loadImage(GOMI_PATH + "background.jpg");
  gomiBackground = createGraphics(w, h);
  gomiBackground.beginDraw();
  gomiBackground.colorMode(HSB, 360, 100, 100, 100);
  gomiBackground.image( pImageCut(back, CENTER, CENTER, w, h) , 0, 0);
  gomiBackground.fill(0, 0, 0, 40);
  gomiBackground.noStroke();
  gomiBackground.rect(0, 0, w, h);
  gomiBackground.endDraw();
  // 背景画像を角丸四角の形に合わせてくり抜く。
  gomiBackground.mask( sizeToModuleMask( moduleSize(module) ) );
  
  module = RModule.Twitter;
  w = moduleWidth( moduleSize(module) );
  h = moduleHeight( moduleSize(module) );
  twitterBackground = createGraphics(w, h);
  twitterBackground.beginDraw();
  twitterBackground.colorMode(HSB, 360, 100, 100, 100);
  PImage twitterLogo = loadImage(TWITTER_PATH + "2021 Twitter logo - blue.png");
  twitterBackground.background(0, 0, 100);
  // Twitterのロゴを縮小し、右上に表示。
  final float logoRatio = twitterLogo.height / float(twitterLogo.width); // 縦横比
  final float logoWidth = 80.0;
  final float logoHeight = logoWidth * logoRatio;
  twitterBackground.image(twitterLogo, w-logoWidth-50, 50, logoWidth, logoHeight);
  twitterBackground.endDraw();
  // 背景画像を角丸四角の形に合わせてくり抜く。
  twitterBackground.mask( sizeToModuleMask( moduleSize(module) ) );
  
  module = RModule.OpenClose;
  w = moduleWidth( moduleSize(module) );
  h = moduleHeight( moduleSize(module) );
  back = loadImage(OPENCLOSE_PATH + "background_open.jpg");
  openCloseBackgroundOpen = createGraphics(w, h);
  openCloseBackgroundOpen.beginDraw();
  openCloseBackgroundOpen.colorMode(HSB, 360, 100, 100, 100);
  openCloseBackgroundOpen.image( pImageCut(back, CENTER, CENTER, w, h) , 0, 0);
  openCloseBackgroundOpen.fill(0, 0, 0, 40);
  openCloseBackgroundOpen.noStroke();
  openCloseBackgroundOpen.rect(0, 0, w, h);
  openCloseBackgroundOpen.endDraw();
  // 背景画像を角丸四角の形に合わせてくり抜く。
  openCloseBackgroundOpen.mask( sizeToModuleMask( moduleSize(module) ) );
  
  back = loadImage(OPENCLOSE_PATH + "background_close.jpg");
  openCloseBackgroundClose = createGraphics(w, h);
  openCloseBackgroundClose.beginDraw();
  openCloseBackgroundClose.colorMode(HSB, 360, 100, 100, 100);
  openCloseBackgroundClose.image( pImageCut(back, CENTER, CENTER, w, h) , 0, 0);
  openCloseBackgroundClose.fill(0, 0, 0, 40);
  openCloseBackgroundClose.noStroke();
  openCloseBackgroundClose.rect(0, 0, w, h);
  openCloseBackgroundClose.endDraw();
  // 背景画像を角丸四角の形に合わせてくり抜く。
  openCloseBackgroundClose.mask( sizeToModuleMask( moduleSize(module) ) );
  
  module = RModule.Temperature;
  w = moduleWidth( moduleSize(module) );
  h = moduleHeight( moduleSize(module) );
  back = loadImage(TEMPERATURE_PATH + "background.jpg");
  temperatureBackground = createGraphics(w, h);
  temperatureBackground.beginDraw();
  temperatureBackground.colorMode(HSB, 360, 100, 100, 100);
  temperatureBackground.image( pImageCut(back, CENTER, CENTER, w, h) , 0, 0);
  temperatureBackground.fill(0, 0, 0, 40);
  temperatureBackground.noStroke();
  temperatureBackground.rect(0, 0, w, h);
  temperatureBackground.endDraw();
  // 背景画像を角丸四角の形に合わせてくり抜く。
  temperatureBackground.mask( sizeToModuleMask( moduleSize(module) ) );
  
  module = RModule.Brightness;
  w = moduleWidth( moduleSize(module) );
  h = moduleHeight( moduleSize(module) );
  back = loadImage(BRIGHTNESS_PATH + "background_bright.jpg");
  brightnessBackgroundBright = createGraphics(w, h);
  brightnessBackgroundBright.beginDraw();
  brightnessBackgroundBright.colorMode(HSB, 360, 100, 100, 100);
  brightnessBackgroundBright.image( pImageCut(back, CENTER, CENTER, w, h) , 0, 0);
  brightnessBackgroundBright.fill(0, 0, 0, 40);
  brightnessBackgroundBright.noStroke();
  brightnessBackgroundBright.rect(0, 0, w, h);
  brightnessBackgroundBright.endDraw();
  // 背景画像を角丸四角の形に合わせてくり抜く。
  brightnessBackgroundBright.mask( sizeToModuleMask( moduleSize(module) ) );
  
  back = loadImage(BRIGHTNESS_PATH + "background_not_bright.jpg");
  brightnessBackgroundNotBright = createGraphics(w, h);
  brightnessBackgroundNotBright.beginDraw();
  brightnessBackgroundNotBright.colorMode(HSB, 360, 100, 100, 100);
  brightnessBackgroundNotBright.image( pImageCut(back, CENTER, CENTER, w, h) , 0, 0);
  brightnessBackgroundNotBright.fill(0, 0, 0, 40);
  brightnessBackgroundNotBright.noStroke();
  brightnessBackgroundNotBright.rect(0, 0, w, h);
  brightnessBackgroundNotBright.endDraw();
  // 背景画像を角丸四角の形に合わせてくり抜く。
  brightnessBackgroundNotBright.mask( sizeToModuleMask( moduleSize(module) ) );
}
