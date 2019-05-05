package sample;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

public class OracleThread extends DbThread {
    OracleThread (String tmpFile, Database database) {
        String CLI = "echo exit | sqlplus64 system/alamakota123@//localhost:1521/XE @" + tmpFile;
        this.command = new String[] { "bash", "-c", CLI};
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
                    if (line.contains("Elapsed: ")) {
                        line = line.replace("Elapsed: ", "");
                        int hours = Integer.parseInt(line.substring(0,2));
                        int minutes = Integer.parseInt(line.substring(3,5));
                        int seconds = Integer.parseInt(line.substring(6,8));
                        int milliseconds = Integer.parseInt(line.substring(9,11));
                        double result = hours*3600.0 + minutes*60.0 + seconds + milliseconds/100.0;
                        database.addTime(result);
                    }
                } catch (NumberFormatException ignored) { }
            }

        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
