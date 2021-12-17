void initialize() {
  initializeImage();
  
  updateNowPageID(true);
}

void initializeImage() {
  busMap = pImageCut(loadImage(BUS_PATH + "bus_map.jpg"), CENTER, CENTER, 1280, 720);
  adImage = new PImage[AD_IMAGE_COUNT];
  for (int i = 0; i < AD_IMAGE_COUNT; i++) {
    adImage[i] = loadImage(AD_PATH + "ad" + i + ".jpg");
  }
  dummy360x360 = loadImage(DUMMY_PATH + "360x360.jpg");
}
