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
    private LinkedList<Double> times = new LinkedList<>();
    private LinkedList<Double> alltimes = new LinkedList<>();


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
    public void setNumberOfThreads(int i) {numberOfThreads = i; }

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

    public void runThreads() {
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

    boolean startStopDB() {
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

    public void setQuery(String query) { this.query = query; }

    String getTimes() {
        StringBuilder sb = new StringBuilder();
        for (Double t : times) sb.append(String.format("%.8f",t)).append(" ");
        return sb.toString();
    }

    String getAvg() {
        return getString(times);
    }

    public String getAllAvg() {
        return getString(alltimes);
    }

    private String getString(LinkedList<Double> alltimes) {
        Double max = 0.0;
        for (Double t: alltimes) if (t > max) max = t;

        Double min = Double.MAX_VALUE;
        for (Double t: alltimes) if (t < min) min = t;

        Double avg = 0.0;
        for (Double t: alltimes) avg+=t;
        avg/= alltimes.size();

        double variance = 0.0;
        for (Double t: alltimes) variance += (t - avg) * (t- avg);
        variance/= alltimes.size();
        return "Min: " + String.format("%.6f",min) + " Max: " + String.format("%.6f",max) +
                " Śr: " + String.format("%.6f",avg) + " War:" + String.format("%.6f", variance)
                + " Odch:" + String.format("%.6f", Math.sqrt(variance)) + "\n";
    }

    public void cleanTimes() {
        alltimes.addAll(times);
        times = new LinkedList<>();
    }

    public abstract String getName();
}
