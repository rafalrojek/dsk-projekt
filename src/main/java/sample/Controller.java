package sample;

import javafx.scene.control.Button;
import javafx.scene.control.RadioButton;
import javafx.scene.control.Slider;
import javafx.scene.control.TextArea;
import javafx.scene.layout.GridPane;

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
        if (db.startstopDB()) mysqlStartButton.setText("Wyłącz");
        else mysqlStartButton.setText("Włącz");
    }

    public void MsSQLButtonClicked() {
        MsSQLDb db = MsSQLDb.get();
        if (db.startstopDB())  mssqlStartButton.setText("Wyłącz");
        else mssqlStartButton.setText("Włącz");
    }

    public void OracleButtonClicked() {
        OracleDb db = OracleDb.get();
        if (db.startstopDB())  OracleStartButton.setText("Wyłącz");
        else OracleStartButton.setText("Włącz");
    }

    public void LoadButtonClicked() {

    }

    public void startButtonClicked() {
        System.out.println((int) userSlider.getValue());
        Database database;
        if (oracleButton.isSelected())  database = OracleDb.get();
        else if (mysqlButton.isSelected()) database = MySQLDb.get();
        else if (mssqlButton.isSelected()) database = MsSQLDb.get();
        else return;

        database.setquery(scriptArea.getText());
        database.setNumberOfThreads((int) userSlider.getValue());
        database.createThreads();
        database.runThreads();

        logsArea.setText(database.getTimes());
        resultArea.setText(database.getAvg());
    }
}
