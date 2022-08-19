import processing.io;
import java.net.*;
import java.io.*;
import twitter4j.*;
import twitter4j.api.*;
import twitter4j.auth.*;
import twitter4j.conf.*;
import twitter4j.json.*;
import twitter4j.management.*;
import twitter4j.util.*;
import twitter4j.util.function.*;
import twitter4j.Status;
import twitter4j.Twitter;
import twitter4j.TwitterException;
import twitter4j.TwitterFactory;

/* --- 用語 --- */
// RModule:
//   Replaceable Moduleの略。表示される場所が変わっても良いモジュール。
//   RModuleに分類されるモジュールは、
//   Brightness、Bus、Gomi、OpenClose、Temperature、Twitter、Weather。

// RModuleのサイズ3段階
enum Size {
  S, 
  M, 
  L
}

// RModule表示の基準となるエリア8つ
enum Area {
  area1, 
  area2, 
  area3, 
  area4, 
  area5, 
  area6, 
  area7, 
  area8
}

// 1週間に含まれる曜日7つ
enum Youbi {
  Sun, 
  Mon, 
  Tue, 
  Wed, 
  Thu, 
  Fri, 
  Sat
}

// RModuleに分類されるモジュールの名前
enum RModule {
  Weather,
  Bus,
  Gomi,
  Twitter,
  OpenClose,
  Temperature,
  Brightness
}

// ごみカレンダーに含まれるごみ種別。
// Moyaseru: 燃やせるごみ
// Moyasenai: 燃やせないごみ
// Plastic: プラスチック容器包装
// CanBinPet: カンビンペットボトル
// None: その他（本プログラムでは、回収対象がない曜日のときNoneを使う）
enum GomiTarget {
  Moyaseru, 
  Moyasenai, 
  Plastic, 
  CanBinPet, 
  None
}

// RModuleの背景画像の角をどれだけ丸めるかを示す変数
final int RMODULE_RECT_ROUND = 30;

// デジタルサイネージの背景画像
PImage background;

// ひとつの画面にとどまる秒数（スライドショーで次の画面に切り替わるまでにかかる秒数）
final int STAY_SECOND = 10;

final int PAGE_ALL_COUNT = 3; // 表示するすべての画面（ページ）の合計枚数
final int AD_IMAGE_COUNT = 1; // 表示する広告画像の合計枚数

// 全画面表示する広告画像（複数枚）
PImage[] adImage;

// 現在表示しているページの番号
int nowPageID = -1;

// 起動時に、どこまで初期化処理が完了したかを示す変数。起動画面で使う。
boolean isInitializedImages = false;
boolean isInitializedDates = false;
boolean isInitializedWeather = false;
boolean isInitializedBus = false;
boolean isInitializedGomi = false;
boolean isInitializedTwitter = false;

// 画像素材などが格納されている場所を示す定数パス。
// たとえば、"data/ad/ad0.jpg"を読み込みたい時、
// ディレクトリ"data/ad/"を示す定数パスAD_PATHを使い、
//   loadImage(AD_PATH + "ad0.jpg");
// のように書けるようになる。
final String AD_PATH = "ad/";
final String WEATHER_PATH = "weather/";
final String BUS_PATH = "bus/";
final String GOMI_PATH = "gomi/";
final String TWITTER_PATH = "twitter/";
final String OPENCLOSE_PATH = "openclose/";
final String TEMPERATURE_PATH = "temperature/";
final String BRIGHTNESS_PATH = "brightness/";
final String DUMMY_PATH = "dummy/";

// デジタルサイネージが設置されている場所や店舗などを書く。
final String LOCATION = "北海道函館市美原2丁目 / MIRAI BASE";

// デジタルサイネージ内で使用する色を定数化したもの。
// 今回はHSBを用いて色を指定するため、setup()でcolorModeを設定後に初期化する必要がある。
// setup()内で初期化が必要なため、ここでは定数であることを示すfinalをつけていない（代入できなくなるから）。
color WHITE_COLOR;
color NEARLY_WHITE_COLOR;
color NEARLY_GREEN_COLOR;
color BLACK_COLOR;
color LIGHT_COLOR;
color GRAY_COLOR;
color GREEN_COLOR;

// RModuleを描画する基準となる場所を示すグリッド（GridModule）
PGraphics grid;

// RModuleが表示されるべき場所に表示される角丸の四角（PlaceholderModule）
PGraphics placeholder;

// ProgressBarModuleで使う変数
final int PROGRESSBAR_HEIGHT = 20; // ProgressBarの高さを表す変数。

// DateModuleで使う変数
int year; // 現在の時間の「年」。
int month; // 現在の時間の「月」。
int day; // 現在の時間の「日」。
int hour; // 現在の時間の「時」。
int minute; // 現在の時間の「分」。
int second; // 現在の時間の「秒」。
int beforeDay = day(); // 1フレーム前の「日」
int beforeSecond = second(); // 1フレーム前の「秒」
Youbi youbi; // 曜日を示す値。Youbi.Sunなどが入る。
String youbiString; // youbiに入っている曜日を日本語表記にしたもの。"日"など。
boolean isHoliday; // 今日が土日祝ならtrue。

// APIを叩くときに使用する定数
final String WEATHER_API_KEY = "";
final String BUS_API_URL = "";
final String GOMI_API_URL = "";
final String CONSUMER_KEY = "";
final String CONSUMER_KEY_SECRET = "";
final String ACCESS_TOKEN = "";
final String ACCESS_TOKEN_SECRET = "";
final long TWEET_ID = Long.parseLong("0");

// 現在の天気を表示する、WeatherRModuleで使う変数
boolean isUpdatedWeather = false; // 天気が正しく取得できたかどうか。
final float LATITUDE = 41.81469; // 自分が天気を取得したい場所の緯度。
final float LONGITUDE = 140.75722; // 自分が天気を取得したい場所の経度。
PImage weatherIcon; // 取得した天気のアイコン。
float temperature = 0.0; // 現在の気温。
int humidity = 0; // 現在の湿度。
String weatherString = ""; // 現在の天気の説明。
PGraphics weatherBackground; // WeatherRModuleの背景。

// バス時刻表を表示する、BusRModuleで使う変数。
boolean isUpdatedBus = false; // バス時刻表が正しく取得できたかどうか。
PImage busMap; // バス停までのマップ画像。
String[] lineNames; // バスの系統名。「67系統」など。
int[] departureHours; // 取得した時刻表の中から取り出した、出発時刻の「時」。
int[] departureMinutes; // 取得した時刻表の中から取り出した、出発時刻の「分」。
final String BUSSTOP_START = "中央小学校前"; // 乗車バス停名。
final String BUSSTOP_END = "函館駅前"; // 降車バス停名。
PGraphics busBackground; // BusRModuleの背景。

// ごみカレンダーを表示する、GomiModuleで使う変数。
boolean isUpdatedGomi = false; //ごみカレンダーが正しく取得できたかどうか。
String[] gomiDows = new String[7]; // 今日から7日間の曜日（日本語表記で"日"など）。
GomiTarget[] gomiTargets = new GomiTarget[7]; // 今日から7日間の回収対象ごみ。
PGraphics gomiBackground; // GomiRModuleの背景。

// 自分のツイートを表示する、TwitterRModuleで使う変数。
boolean isUpdatedTwitter = false; // ツイートが正しく取得できたかどうか。
Status tweetStatus; // 「Status」は、取得したひとつのツイートのこと。
PImage twitterUserIcon; // アカウントのアイコン。
String twitterUserName = ""; // アカウントの表示名。
String twitterUserScreenName = ""; // アカウントの@がついたユーザ名。
String tweetText = ""; // ツイートの文章。
PImage[] tweetImages = new PImage[3]; // ツイートから取得できた画像たち（上限3枚）。
PImage dummy360x360; // Twitterから画像が取得できなかったときに表示するダミー画像。
PGraphics twitterBackground; // TwitterRModuleの背景。

// 開店／閉店を表示する、OpenCloseRModuleで使う変数。
boolean isUpdatedOpenClose = false; // スライドスイッチの状態が正しく取得できたかどうか。
boolean isOpen = false; // 開店しているか。
final int SWITCH_PIN = 23; // スライドスイッチからデータを受信するGPIOピン番号。
PGraphics openCloseBackgroundOpen; // 開店時に表示する、OpenCloseRModuleの背景。
PGraphics openCloseBackgroundClose; // 閉店時に表示する、OpenCloseRModuleの背景。

// 気温を表示する、TemperatureRModuleで使う変数。
boolean isUpdatedTemperature = false; // 温度センサの値が正しく取得できたかどうか。
I2C i2c; // 接続した温度センサに関連する情報（アドレスなど）の変数。
float roomTempValue = 0.0; // 温度（摂氏）。
PGraphics temperatureBackground; // TemperatureRModuleの背景。

// 明るさを表示する、BrightnessRModuleで使う変数。
boolean isUpdatedBrightness = false;
SPI spi; // 接続した明るさセンサに関連する情報（アドレスなど）の変数。
boolean isBright = true; // 一定の基準より明るいか。
float brightnessRate = 0.0; // 明るさを％で示したもの。
PGraphics brightnessBackgroundBright; // 明るいときに表示する、BrightnessRModuleの背景。
PGraphics brightnessBackgroundNotBright; // 暗いときに表示する、BrightnessRModuleの背景。

// RModuleのうしろに表示する影に使う変数。
final int SHADOW_ALPHA = 60; // 影の透明度。
final int SHADOW_PADDING = 20; // RModuleの背景にくらべてどれだけ大きい影にするか。
PGraphics moduleShadowS; // サイズがSize.SのRModule用の影。
PGraphics moduleShadowM; // サイズがSize.MのRModule用の影。
PGraphics moduleShadowL; // サイズがSize.LのRModule用の影。


void settings() {
  size(1920, 1080);
  //fullScreen();
  
  // 色の初期設定。
  WHITE_COLOR = color(0, 0, 100);
  NEARLY_WHITE_COLOR = color(100, 2, 98);
  NEARLY_GREEN_COLOR = color(100, 5, 98);
  BLACK_COLOR = color(0, 0, 0);
  LIGHT_COLOR = color(0, 0, 80);
  GRAY_COLOR = color(0, 0, 50);
  GREEN_COLOR = color(150, 100, 60);
}

void setup() {
  frameRate(1);
  noCursor();
  colorMode(HSB, 360, 100, 100, 100);
  
  // 初期化用関数initialize()を、draw()で画面が描画されているときに並行し実行（非同期処理）。
  thread("initialize");
}

void draw() {
  if (nowPageID == -1) {
    // データの初期化が完了するまで、起動画面を表示する。
  } else {
    // データを更新したあと、各モジュールを描画する。
  }
}
