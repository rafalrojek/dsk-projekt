package sample;

import java.util.LinkedList;

public class MsSQLDb  extends Database {
    private static MsSQLDb instance;

    public static MsSQLDb get() {
        if (instance == null) instance = new MsSQLDb();
        return instance;
    }

    private MsSQLDb () {
        dockerID = getDockerId("mssql");
        isRunning = getState("mssql");
    }

    @Override
    public void createThreads() {
        threadLinkedList = new LinkedList<>();
        for (int i =0; i < numberOfThreads; i++) {
            threadLinkedList.add(new Thread(new MsSQLThread(dockerID, query, this)));
        }
    }
}
