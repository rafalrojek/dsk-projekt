package sample.experiment;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;

public class ScriptReader {

    public static String read(String fileName){
        try {
            BufferedReader buf = new BufferedReader(new InputStreamReader(new FileInputStream(fileName)));
            String line = buf.readLine();
            StringBuilder sb = new StringBuilder();

            while(line != null){
                sb.append(line).append("\n");
                line = buf.readLine();
            }
            return sb.toString();
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }
}
