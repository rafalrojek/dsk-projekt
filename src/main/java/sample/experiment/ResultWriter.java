package sample.experiment;

import sample.Database;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.PrintWriter;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class ResultWriter {
    public static void save(String results, String db){
        String filePath = "";
        PrintWriter writer = null;
        try {
            filePath = "./results/" + db + ".exp";
            String dateTime = LocalDateTime.now().format(DateTimeFormatter.ofPattern("uuuu-MM-dd_HH-mm-ss"));
            FileWriter fw = new FileWriter(filePath, true);
            BufferedWriter bw = new BufferedWriter(fw);
            bw.write("\n\n" + dateTime + results);
            bw.newLine();
            bw.close();
            System.out.println("\tResults printed in " + filePath);
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
        finally {
            if(writer!=null) writer.close();
        }
    }
}
