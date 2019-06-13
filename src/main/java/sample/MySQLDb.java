package sample;

import sample.experiment.ExperimentPlanner;

import java.util.LinkedList;

public class MySQLDb extends Database {
    private static MySQLDb instance;

    public static MySQLDb get() {
        if (instance == null) instance = new MySQLDb();
        return instance;
    }

    private MySQLDb () {
        dockerID = getDockerId("mysql");
        isRunning = getState("mysql");
    }

    @Override
    public void createThreads() {
        threadLinkedList = new LinkedList<>();
        for (int i =0; i < numberOfThreads; i++) {
            threadLinkedList.add(new Thread(new MySQLThread(dockerID, query, this)));
        }
    }

    @Override
    public String getName() {
        return ExperimentPlanner.MySQL;
    }
}
