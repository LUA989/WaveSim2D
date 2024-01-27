float clamp(float x, float min, float max) {
  if(x < min) x = min;
  if(x > max) x = max;
  return x;
}

int clamp(int x, int min, int max) {
  if(x < min) x = min;
  if(x > max) x = max;
  return x;
}
