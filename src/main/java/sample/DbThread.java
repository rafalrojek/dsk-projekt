package sample;

public abstract class DbThread implements Runnable {
    String[] command;
    Database database;

    public abstract void run();


}
