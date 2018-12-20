package de.kn.uni.smartact.movisenslibrary.model;

public class BluetoothData {
    public String date;
    public String steps;
    public String met;
    public String light;
    public String moderate;
    public String vigorous;
    public String count;
   // public String [] ecg; //ECG data

    public BluetoothData(String date, String steps, String met, String light, String moderate, String vigorous, String count){
        this.date = date;
        this.steps = steps;
        this.met = met;
        this.light = light;
        this.moderate = moderate;
        this.vigorous = vigorous;
        this.count = count;
       // this.ecg=ecg;
    }
}
