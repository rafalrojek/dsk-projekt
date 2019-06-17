package sample;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

public class MsSQLThread  extends DbThread {

    MsSQLThread(String dockerID, String command, Database database) {
        String CLI = " /opt/mssql-tools/bin/sqlcmd -U sa -P 'Alamako%%1' -Q \"use tst; set statistics time on; ";
        String linux = "docker exec " + dockerID + CLI + command + "\"";
        this.command = new String[] {"bash", "-c", linux};
        this.database = database;
    }

    @Override
    public void run() {
        try {
            String line;
            Process os = Runtime.getRuntime().exec(command);
            BufferedReader input = new BufferedReader(new InputStreamReader(os.getInputStream()));
            while ((line = input.readLine()) != null) {
                System.out.println(line);
                try {
                    if (line.contains("elapsed time = ")) {
                        System.out.println(line);
                        String[] l = line.split(" ms,");
                        database.addTime(Double.parseDouble(l[0].replace("CPU time = ", "").trim()));
                    }
                } catch (NumberFormatException ignored) { }
            }
            BufferedReader error = new BufferedReader(new InputStreamReader(os.getErrorStream()));
            while ((line = error.readLine()) != null) System.out.println(line);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}