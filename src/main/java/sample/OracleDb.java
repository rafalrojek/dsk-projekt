package sample;

import sample.experiment.ExperimentPlanner;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.LinkedList;

public class OracleDb extends Database {

    private static OracleDb instance;

    public static OracleDb get() {
        if (instance == null) instance = new OracleDb();
        return instance;
    }

    private OracleDb () {
        dockerID = getDockerId("oracle");
        isRunning = getState("oracle");
    }

    private String whenWriteToTmpFile() {
        File tmpFile;
        try {
            tmpFile = File.createTempFile("test", ".tmp");
            FileWriter writer = new FileWriter(tmpFile);
            writer.write("set timing on \n");
            writer.write(query);
            writer.close();
            return tmpFile.getAbsolutePath();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public void createThreads() {
        String tmpFile = whenWriteToTmpFile();
        threadLinkedList = new LinkedList<>();
        for (int i =0; i < numberOfThreads; i++) {
            threadLinkedList.add(new Thread(new OracleThread(tmpFile, this)));
        }
    }

    @Override
    public String getName() {
        return ExperimentPlanner.ORACLE;
    }
}
