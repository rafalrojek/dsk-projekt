package sample;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.LinkedList;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

public abstract class Database {

    boolean isRunning;
    String dockerID;
    String query;
    int numberOfThreads;
    LinkedList<Thread> threadLinkedList;
    LinkedList<Double> times = new LinkedList<>();

    String getDockerId(String dbName) {
        String s, result = null;
        try {
            Process p = Runtime.getRuntime().exec("docker ps -a");
            BufferedReader stdInput = new BufferedReader(new
                    InputStreamReader(p.getInputStream()));
            while ((s = stdInput.readLine()) != null) {
                if (s.contains(dbName)) {
                    result = s.substring(0,12);
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return result;
    }

    synchronized void addTime (double time) { times.add(time);}
    void setNumberOfThreads (int i) {numberOfThreads = i; }

    boolean getState(String dbName) {
        String s;
        try {
            Process p = Runtime.getRuntime().exec("docker ps -a");
            BufferedReader stdInput = new BufferedReader(new
                    InputStreamReader(p.getInputStream()));
            while ((s = stdInput.readLine()) != null) {
                if (s.contains(dbName)) {
                    return s.contains("Up");
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return false;
    }

    public abstract void createThreads ();

    void runThreads() {
        ExecutorService threads = Executors.newCachedThreadPool();
        for (Thread t: threadLinkedList) {
            threads.execute(t);
        }
        threads.shutdown();
        try {
            threads.awaitTermination(10, TimeUnit.MINUTES);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

    boolean startstopDB() {
        String command = "docker ";
        if (isRunning) command += "stop " + dockerID;
        else command+= "start " + dockerID;
        try {
            Runtime.getRuntime().exec(command);
        } catch (IOException e) {
            e.printStackTrace();
        }
        isRunning=!isRunning;
        return isRunning;
    }

    public void setquery (String query) { this.query = query; }

    public String getQuery () {return this.query;}

    public String getTimes() {
        StringBuilder sb = new StringBuilder();
        for (Double t : times) sb.append(String.format("%.12f",t)).append(" ");
        return sb.toString();
    }

    public String getAvg () {
        Double max = 0.0;
        for (Double t: times) if (t > max) max = t;

        Double min = Double.MAX_VALUE;
        for (Double t: times) if (t < min) min = t;

        Double avg = 0.0;
        for (Double t: times) avg+=t;
        avg/=times.size();

        Double variance = 0.0;
        for (Double t: times) variance += (t - avg) * (t- avg);
        variance/= times.size();
        return "Minimum: " + String.format("%.12f",min) + " Maksimum: " + String.format("%.12f",max) +
                " Średnia: " + String.format("%.12f",avg) + "Wariancja:" + String.format("%.12f", variance)
                + "Odchylenie standardowe:" + String.format("%.12f", Math.sqrt(variance));
    }
}
