void drawBusRModule(Area area) {
  RModule module = RModule.Bus;
  Size size = moduleSize(module);

  int x = layoutGuideX(area);
  int y = layoutGuideY(area);
  int w = moduleWidth(size);
  int h = moduleHeight(size);

  image(loadImage(BUS_PATH + "sample.jpg"), x, y);
}
