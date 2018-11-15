package cachet.sensors.noisemeter;

/**
 * A data object which calculates the decibel value given a volume value.
 */

public class NoiseLevel {

    private double decibel;

    public NoiseLevel(int volume) {
        /**
         * Volume reading needs to be greater than zero, since log(0) is undefined.
         */
        this.decibel = volume > 0 ? 20 * Math.log10(volume) : 0;
    }

    public double getDecibel() {
        return decibel;
    }
}
