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

    private final String selectNoJoinNoIndex = "selectNoJoinNoIndex";
    private final String selectNoJoinWithIndex = "selectNoJoinWithIndex";
    private final String selectWithJoinNoIndex = "selectWithJoinNoIndex";
    private final String selectWithJoinWithIndex = "selectWithJoinWithIndex";
    private final String procedure = "procedure";
    private final String update = "update";
    private final String delete = "delete";
    private final String insert = "insert";
    private final String index = "index";

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
        //iterations = new int[3];
        iterations = new int[1];
        iterations[i++] = 10;
        //iterations[i++] = 100;
        //iterations[i++] = 500;
    }

    private void setScripts() {
        //TODO ustawic wielkosc tablicy
        scriptTypes = new String[6];

        int i = 0;
        scriptTypes[i] = selectNoJoinNoIndex;
        scriptsPerDb.put(scriptTypes[i] + ORACLE, "select FirstName, LastName from Employees WHERE FirstName LIKE '%Dominik%';");
        scriptsPerDb.put(scriptTypes[i] + MySQL, "select FirstName, LastName from Employees WHERE FirstName LIKE \"%Dominik%\";");
        scriptsPerDb.put(scriptTypes[i] + MsSQL, "select FirstName, LastName from Employees WHERE FirstName LIKE '%Dominik%';");

        scriptTypes[++i] = "index1";
        scriptsPerDb.put(scriptTypes[i] + ORACLE, "ALTER TABLE Employees ADD INDEX (FirstName);");
        scriptsPerDb.put(scriptTypes[i] + MySQL, "ALTER TABLE Employees ADD INDEX (FirstName);");
        scriptsPerDb.put(scriptTypes[i] + MsSQL, "CREATE INDEX idx_empl_first_nm on Employees ([FirstName]);");

        scriptTypes[++i] = selectNoJoinWithIndex;
        scriptsPerDb.put(scriptTypes[i] + ORACLE, "select FirstName, LastName from Employees WHERE FirstName LIKE '%Dominik%';");
        scriptsPerDb.put(scriptTypes[i] + MySQL, "select FirstName, LastName from Employees WHERE FirstName LIKE \"%Dominik%\";");
        scriptsPerDb.put(scriptTypes[i] + MsSQL, "select FirstName, LastName from Employees WHERE FirstName LIKE '%Dominik%';");

        scriptTypes[++i] = selectWithJoinNoIndex;
        scriptsPerDb.put(scriptTypes[i] + ORACLE, "select * from Invoices WHERE ShipRegion LIKE 'IL%';");
        scriptsPerDb.put(scriptTypes[i] + MySQL, "select * from Invoices WHERE ShipRegion LIKE \"IL%\";");
        scriptsPerDb.put(scriptTypes[i] + MsSQL, "select * from Invoices WHERE ShipRegion LIKE 'IL%';");

        scriptTypes[++i] = "index2";
        scriptsPerDb.put(scriptTypes[i] + ORACLE, "ALTER TABLE Orders ADD INDEX (ShipRegion);");
        scriptsPerDb.put(scriptTypes[i] + MySQL, "ALTER TABLE Orders ADD INDEX (ShipRegion);");
        scriptsPerDb.put(scriptTypes[i] + MsSQL, "CREATE INDEX idx_ship_region on Orders ([ShipRegion]);");

        scriptTypes[++i] = selectWithJoinWithIndex;
        //procedure
        scriptsPerDb.put(scriptTypes[i] + ORACLE, "select * from Invoices WHERE ShipRegion LIKE 'IL%';");
        scriptsPerDb.put(scriptTypes[i] + MySQL, "select * from Invoices WHERE ShipRegion LIKE \"IL%\";");
        scriptsPerDb.put(scriptTypes[i] + MsSQL, "select * from Invoices WHERE ShipRegion LIKE 'IL%';");
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

/*
        scriptTypes[i++] = procedure;
        scriptTypes[i++] = update;
        scriptTypes[i++] = delete;
        scriptTypes[i++] = insert;
*/

    }


    private void setThreads() {
        int i = 0;
        //threadsNumbers = new int[3];
        threadsNumbers = new int[1];
        threadsNumbers[i++] = 1;
        //threadsNumbers[i++] = 10;
        //threadsNumbers[i++] = 100;
    }

    private void setExperimentsList() {
        for (Database database : databases) {
            for (String script : scriptTypes) {
                boolean indexChanged = false;
                for (int threadsNumber : threadsNumbers) {
                    for (int iteration : iterations) {
                        if( ! (iteration == 500 && threadsNumber == 100))   //liczy sie 4 godziny, szkoda krzemu
                        {
                            if (script.matches("index") && !indexChanged)
                            {
                                indexChanged = true;
                                System.out.println(scriptsPerDb.get(script + database.getName()));
                                experiments.add(new Experiment(iteration, scriptsPerDb.get(script + database.getName()), 1, database));
                            }
                            else
                            {
                                System.out.println(scriptsPerDb.get(script + database.getName()));
                                experiments.add(new Experiment(iteration, scriptsPerDb.get(script + database.getName()), threadsNumber, database));
                            }
                        }
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