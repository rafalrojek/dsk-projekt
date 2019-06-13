package sample;

import javafx.scene.control.Button;
import javafx.scene.control.RadioButton;
import javafx.scene.control.Slider;
import javafx.scene.control.TextArea;
import javafx.scene.layout.GridPane;
import javafx.stage.FileChooser;
import javafx.stage.Stage;
import sample.experiment.ExperimentPlanner;

import java.io.*;

public class Controller {
    public GridPane grid;
    public RadioButton oracleButton;
    public RadioButton mssqlButton;
    public RadioButton mysqlButton;
    public Button scriptButton;
    public Button runButton;
    public TextArea resultArea;
    public Slider userSlider;
    public TextArea scriptArea;
    public TextArea logsArea;
    public Button OracleStartButton;
    public Button mssqlStartButton;
    public Button mysqlStartButton;

    private static Stage _stage;
    public Slider loopSlider;

    static void setStage(Stage stage) { _stage = stage;}

    public void OracleClicked() {
        disableOtherButtons(oracleButton);
    }

    public void mssqlClicked() {
        disableOtherButtons(mssqlButton);
    }

    public void mysqlClicked() {
        disableOtherButtons(mysqlButton);
    }

    private void disableOtherButtons(RadioButton skip) {
        if(skip != oracleButton) oracleButton.setSelected(false);
        if(skip != mssqlButton) mssqlButton.setSelected(false);
        if(skip != mysqlButton) mysqlButton.setSelected(false);
    }

    public void MySQLButtonClicked() {
        MySQLDb db = MySQLDb.get();
        if (db.startStopDB()) mysqlStartButton.setText("Wyłącz");
        else mysqlStartButton.setText("Włącz");
    }

    public void MsSQLButtonClicked() {
        MsSQLDb db = MsSQLDb.get();
        if (db.startStopDB())  mssqlStartButton.setText("Wyłącz");
        else mssqlStartButton.setText("Włącz");
    }

    public void OracleButtonClicked() {
        OracleDb db = OracleDb.get();
        if (db.startStopDB())  OracleStartButton.setText("Wyłącz");
        else OracleStartButton.setText("Włącz");
    }

    public void LoadButtonClicked() {
        FileChooser fileChooser = new FileChooser();
        fileChooser.setTitle("Wybierz plik do otwarcia");
        File file = fileChooser.showOpenDialog(_stage);
        if (file != null) {
            try {
                BufferedReader buf = new BufferedReader(new InputStreamReader(new FileInputStream(file)));
                String line = buf.readLine();
                StringBuilder sb = new StringBuilder();

                while(line != null){
                    sb.append(line).append("\n");
                    line = buf.readLine();
                }

                scriptArea.setText(sb.toString());
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

    }

    public void startButtonClicked() {
        /*
        System.out.println((int) userSlider.getValue());
        Database database;
        if (oracleButton.isSelected())  database = OracleDb.get();
        else if (mysqlButton.isSelected()) database = MySQLDb.get();
        else if (mssqlButton.isSelected()) database = MsSQLDb.get();
        else return;

        StringBuilder logs = new StringBuilder();
        StringBuilder result = new StringBuilder();

        for (int i = 0 ; i < loopSlider.getValue(); i++) {
            database.setQuery(scriptArea.getText());
            database.setNumberOfThreads((int) userSlider.getValue());
            database.createThreads();
            database.runThreads();

            logs.append("Proba ").append(i).append(": ").append(database.getTimes()).append("\n");
            result.append("Proba ").append(i).append(": ").append(database.getAvg());
            database.cleanTimes();
            System.out.println("Iteracja: " + i);
        }
        result.append("Wynik końcowy: ");
        result.append(database.getAllAvg());
        logsArea.setText(logs.toString());
        resultArea.setText(result.toString());
        */
        ExperimentPlanner experimentPlanner = new ExperimentPlanner();
        experimentPlanner.executeExperiments();
    }
}
