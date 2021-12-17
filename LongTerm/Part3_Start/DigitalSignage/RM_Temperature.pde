void drawTemperatureRModule(Area area) {
  RModule module = RModule.Brightness;
  Size size = moduleSize(module);

  int x = layoutGuideX(area);
  int y = layoutGuideY(area);
  int w = moduleWidth(size);
  int h = moduleHeight(size);

  image(loadImage(TEMPERATURE_PATH + "sample.jpg"), x, y);
}
