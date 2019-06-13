package sample;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

class MySQLThread extends DbThread {

    MySQLThread(String dockerID, String command, Database database) {
        String CLI = " mysql -hlocalhost -uala -pmakota --xml --execute='USE dsk; set profiling=1; ";
        String linux = "docker exec " + dockerID + CLI + command + " show profiles'";
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
                    if (line.contains("Duration")) {
                        System.out.println(line);
                        database.addTime(Double.parseDouble(line.substring(24, 34)));
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
