package sample.experiment;

import sample.Database;
import sample.MsSQLDb;
import sample.MySQLDb;
import sample.OracleDb;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

public class ExperimentPlanner {

    private Database[] databases;
    private String[] scriptTypes;
    private Map<String, String> scriptsPerDb = new HashMap<>();
    private int[] iterations;
    private int[] threadsNumbers;
    public static final String ORACLE = "oracle";
    public static final String MySQL = "mysql";
    public static final String MsSQL = "mssql";

    private List<Experiment> experiments = new LinkedList<>();

    public ExperimentPlanner() {
        setDatabases();
        setScripts();
        setIterations();
        setThreads();
        setExperimentsList();
    }

    private void setDatabases() {
        databases = new Database[3];
        int i = 0;
        databases[i++] = MsSQLDb.get();
        databases[i++] = MySQLDb.get();
        databases[i++] = OracleDb.get();
    }

    private void setIterations() {
        int i = 0;
        iterations = new int[3];
        iterations[i++] = 10;
        iterations[i++] = 100;
        iterations[i++] = 500;
    }

    private void setScripts() {
        //TODO ustawic wielkosc tablicy
        scriptTypes = new String[1];
        int i = 0;
        /*
        scriptTypes[i++] = "lowSelect";
        scriptTypes[i++] = "midSelect";
        scriptTypes[i++] = "highSelect";
        */
        scriptTypes[i++] = "procedure1";/*
        scriptTypes[i++] = "procedure2";

        scriptTypes[i++] = "insert";

        scriptTypes[i++] = "updateEasy";
        scriptTypes[i++] = "updateHard";*/

        //TODO tutaj 0 po odkomentowaniu
        i = -1;

        /*
        String selectCurrentProductList = "select * from CurrentProductList";
        scriptsPerDb.put(scriptTypes[i] + ORACLE, selectCurrentProductList);
        scriptsPerDb.put(scriptTypes[i] + MySQL, selectCurrentProductList);
        scriptsPerDb.put(scriptTypes[i] + MsSQL, selectCurrentProductList);

        String selectProductsByCategory = "select * from ProductsByCategory";
        scriptsPerDb.put(scriptTypes[++i] + ORACLE, selectProductsByCategory);
        scriptsPerDb.put(scriptTypes[i] + MySQL, selectProductsByCategory);
        scriptsPerDb.put(scriptTypes[i] + MsSQL, selectProductsByCategory);

        String selectInvoices = "select * from Invoices";
        scriptsPerDb.put(scriptTypes[++i] + ORACLE, selectInvoices);
        scriptsPerDb.put(scriptTypes[i] + MySQL, selectInvoices);
        scriptsPerDb.put(scriptTypes[i] + MsSQL, selectInvoices);
*/
        //procedure1
        scriptsPerDb.put(scriptTypes[++i] + ORACLE, "begin TenMostExpensiveProducts(); end;");
        scriptsPerDb.put(scriptTypes[i] + MySQL, "CALL `Ten Most Expensive Products`()");
        scriptsPerDb.put(scriptTypes[i] + MsSQL, "EXEC TenMostExpensiveProducts");
/*

        //procedure1
        scriptsPerDb.put(scriptTypes[++i] + ORACLE, selectInvoices);
        scriptsPerDb.put(scriptTypes[i] + MySQL, selectInvoices);
        scriptsPerDb.put(scriptTypes[i] + MsSQL, selectInvoices);

        //insert
        scriptsPerDb.put(scriptTypes[++i] + ORACLE, ScriptReader.read("sql/oracle_data.sql"));
        scriptsPerDb.put(scriptTypes[i] + MySQL, ScriptReader.read("sql/mysql_data.sql"));
        scriptsPerDb.put(scriptTypes[i] + MsSQL, ScriptReader.read("sql/mssql_data.sql"));

        scriptsPerDb.put(scriptTypes[++i] + ORACLE, "jakis updateEasy");
        scriptsPerDb.put(scriptTypes[i] + MySQL, "jakis updateEasy");
        scriptsPerDb.put(scriptTypes[i] + MsSQL, "jakis updateEasy");

        scriptsPerDb.put(scriptTypes[++i] + ORACLE, "delete tego co updated");
        scriptsPerDb.put(scriptTypes[i] + MySQL, "delete tego co updated");
        scriptsPerDb.put(scriptTypes[i] + MsSQL, "delete tego co updated");

        scriptsPerDb.put(scriptTypes[++i] + ORACLE, "jakis updateHard");
        scriptsPerDb.put(scriptTypes[i] + MySQL, "jakis updateHard");
        scriptsPerDb.put(scriptTypes[i] + MsSQL, "jakis updateHard");

        scriptsPerDb.put(scriptTypes[++i] + ORACLE, "delete tego co updated");
        scriptsPerDb.put(scriptTypes[i] + MySQL, "delete tego co updated");
        scriptsPerDb.put(scriptTypes[i] + MsSQL, "delete tego co updated");

*/

        // indeksy

        //triggery
    }


    private void setThreads() {
        int i = 0;
        threadsNumbers = new int[3];
        threadsNumbers[i++] = 1;
        threadsNumbers[i++] = 10;
        threadsNumbers[i++] = 100;
    }

    private void setExperimentsList() {
        for (Database database : databases) {
            for (String script : scriptTypes) {
                for (int threadsNumber : threadsNumbers) {
                    for (int iteration : iterations) {
                        if( ! (iteration == 500 && threadsNumber == 100))   //liczy sie 4 godziny, szkoda krzemu
                            experiments.add(new Experiment(iteration, scriptsPerDb.get(script+database), threadsNumber, database));
                    }
                }
            }
        }
    }

    public void executeExperiments(){
        for(Experiment experiment : experiments){
            String result = experiment.run();
            ResultWriter.save(result, experiment.getDbName());
        }
    }
}
