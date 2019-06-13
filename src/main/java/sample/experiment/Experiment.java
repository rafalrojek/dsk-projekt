package sample.experiment;

import sample.Database;

public class Experiment {
    private int iterations;
    private String script;
    private int threadsNumber;
    private Database database;

    public Experiment(int iterations, String script, int threadsNumber, Database database) {
        this.iterations = iterations;
        this.script = script;
        this.threadsNumber = threadsNumber;
        this.database = database;
    }

    public String run(){
        StringBuilder result = new StringBuilder();

        int counter = 0;
        for (int i = 0 ; i < iterations; i++) {
            database.setQuery(script);
            database.setNumberOfThreads(threadsNumber);
            database.createThreads();
            database.runThreads();
            database.cleanTimes();
            counter++;
            if(counter%11 == 0) System.out.print("/");
            else if(counter % 2 == 0) System.out.print(",");
            else System.out.print(".");
        }
        result.append("\n\nWynik dla :")
                .append(database.getName())
                .append(" \nLiczba watkow = ")
                .append(threadsNumber)
                .append("\nLiczba iteracji = ")
                .append(iterations)
                .append("\nSkrypt:\n")
                .append(script)
                .append("\n")
                .append(database.getAllAvg());
        return result.toString();
    }

    public String getDbName(){
        return database.getName();
    }
}
