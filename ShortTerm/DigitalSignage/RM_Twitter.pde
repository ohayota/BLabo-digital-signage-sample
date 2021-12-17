void drawTwitterRModule(Area area) {
  RModule module = RModule.Twitter;
  Size size = moduleSize(module);
  int x = layoutGuideX(area);
  int y = layoutGuideY(area);
  int w = moduleWidth(size);
  int h = moduleHeight(size);
  
  // 影を描画する。
  image(rmoduleShadowImage(size), x-SHADOW_PADDING, y-SHADOW_PADDING);
  image(twitterBackground, x, y, w, h);
  
  if (isUpdatedTwitter) {
    // Twitterアカウントのアイコン表示
    image(twitterUserIcon, x+50, y+50, 80, 80);
    
    // Twitterアカウントの表示名、アカウント名（@hogehoge）を表示
    drawText(LEFT, BASELINE, BLACK_COLOR, 32, twitterUserName, x+150, y+50);
    drawText(LEFT, BASELINE, GRAY_COLOR, 24, twitterUserScreenName, x+150, y+90);
    
    // ツイートのテキストを表示
    drawText(LEFT, BASELINE, BLACK_COLOR, 20, tweetText, x+50, y+150, w-100, h-50-((w-100)*2/3)-200);
    
    // ツイートから取得した画像を3枚表示
    image(tweetImages[0], x+50, y+h-50-((w-100)*2/3), (w-100)*2/3, (w-100)*2/3);
    image(tweetImages[1], x+50+(w-100)*2/3, y+h-50-((w-100)*2/3), (w-100)/3, (w-100)/3);
    image(tweetImages[2], x+50+(w-100)*2/3, y+h-50-((w-100)/3), (w-100)/3, (w-100)/3);
    strokeWeight(1);
    stroke(WHITE_COLOR);
    noFill();
    // 画像どうしの境界をわかりやすくするために白い枠をつける
    rect(x+50, y+h-50-((w-100)*2/3), (w-100)*2/3, (w-100)*2/3);
    rect(x+50+(w-100)*2/3, y+h-50-((w-100)*2/3), (w-100)/3, (w-100)/3);
    rect(x+50+(w-100)*2/3, y+h-50-((w-100)/3), (w-100)/3, (w-100)/3);
  } else {
    // 値が取得できなかったとき、エラーメッセージを表示
    fill(0, 0, 0, 50);
    noStroke();
    rect(x, y, w, h, RMODULE_RECT_ROUND);
    
    drawText(CENTER, CENTER, WHITE_COLOR, 24, "TwitterModule\nデータを取得できません", x+w/2, y+h/2);
  }
}

boolean updateTwitter() {
  tweetImages = new PImage[3];
  
  // API関連の設定
  ConfigurationBuilder cb = new ConfigurationBuilder();
  cb.setDebugEnabled(true)
    .setOAuthConsumerKey(CONSUMER_KEY)
    .setOAuthConsumerSecret(CONSUMER_KEY_SECRET)
    .setOAuthAccessToken(ACCESS_TOKEN)
    .setOAuthAccessTokenSecret(ACCESS_TOKEN_SECRET);
    
  // TwitterAPIインスタンス取得
  Twitter twitter = new TwitterFactory(cb.build()).getInstance();
  
  try {
    // 指定IDをもつツイートを取得する
    try {
      tweetStatus = twitter.showStatus(TWEET_ID);
      twitterUserName = tweetStatus.getUser().getName();
      twitterUserScreenName = "@" + tweetStatus.getUser().getScreenName();
      tweetText = tweetStatus.getText();
    } catch (Exception e) {
      println("updateTwitter(): 該当のツイート(id:" + TWEET_ID + ")を取得できませんでした。" + e);
      return false;
    }
    
    // 指定ツイートに含まれる画像を取得する（3枚まで）
    MediaEntity[] tweetMedias = tweetStatus.getMediaEntities();
    for (int i = 0; i < tweetImages.length; i++) {
      try {
        tweetImages[i] = pImageToSquare(loadImage(tweetMedias[i].getMediaURLHttps()), CENTER);
      } catch (Exception e) {
        tweetImages[i] = dummy360x360;
        println("updateTwitter(): ツイートに含まれる画像が3枚未満です。" + e);
      }
    }
    
    // ツイートからアカウント画像を取得する
    twitterUserIcon = loadImage(tweetStatus.getUser().get400x400ProfileImageURL());
    PGraphics maskLayer = createGraphics(twitterUserIcon.width, twitterUserIcon.width);
    maskLayer.beginDraw();
    maskLayer.noStroke();
    maskLayer.fill(255);
    maskLayer.circle(maskLayer.width/2, maskLayer.height/2, maskLayer.width);
    maskLayer.endDraw();
    // 画像を丸く切り抜く
    twitterUserIcon.mask(maskLayer);
    
    println("updateTwitter(): ツイートを取得しました。");
  } catch (Exception e) {
    println("updateTwitter(): ツイートを取得できませんでした。" + e);
    return false;
  }
  
  return true;
}
