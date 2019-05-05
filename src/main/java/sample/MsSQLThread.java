package sample;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

public class MsSQLThread  extends DbThread {

    MsSQLThread(String dockerID, String command, Database database) {
        String CLI = " /opt/mssql-tools/bin/sqlcmd -U sa -P 'Alamako%%1' -Q \"set statistics time on; ";
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
                try {
                    if (line.contains("elapsed time = ")) {
                        System.out.println(line);
                        String[] l = line.split("elapsed time = ");
                        database.addTime(Double.parseDouble(l[1].replace(" ms.", "")));
                    }
                } catch (NumberFormatException ignored) { }
            }

        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}