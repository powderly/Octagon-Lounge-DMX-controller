  class Listener implements AudioListener {

  public void samples(float[] sample) {
    fft.forward(sample);
    float max = max(sample);
    if (max > level) {
      level = max;
    } 
    else {
      level = level * 0.8f;
    }
    leveldB = (float) (10 * Math.log(level));
    analyse();
  }

  public void samples(float[] sampleL, float[] sampleR) {
    if (sampleL != null && sampleR != null) {
      fft.forward(sum(sampleL, sampleR));
      float max = max(sum(sampleL, sampleR)) / 2;
      if (max > level) {
        level = max;
      } 
      else {
        level = level * 0.8f;
      }
      leveldB = (float) (10 * Math.log(level));
      analyse();
    }
  }
}
