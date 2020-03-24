#!/usr/bin/python3
"""
This file contains the implementation of the main interface for the program

Authors: Leonardo Lucio Custode and Luca Turchet
Copyright: University of Trento

Date: 13/3/2020
"""
import os
import sys
import time
import json
import threading
import traceback
from reportlab.pdfgen import canvas
from classifiers import TFClassifier
from utilities import customize_report, export_pdf, export_html, generate_output_html, Calendar, ClickableQLabel
from PyQt5.QtWidgets import QApplication, QWidget, QVBoxLayout, QPushButton, QFileDialog, QLabel, QDialog, QGridLayout, QFrame, QLineEdit, QTextEdit
from PyQt5.QtGui import QIcon, QPixmap
from PyQt5.QtCore import pyqtSlot, QThreadPool, QRunnable, QObject, pyqtSignal, Qt, QSize
from PyQt5.QtWebEngineWidgets import QWebEngineView


class WorkerSignals(QObject):
    result = pyqtSignal(str)


class Worker(QRunnable):
    '''
    Worker thread, used for the parallelization
    '''
    def __init__(self, dir_path, classifier):
        super(Worker, self).__init__()
        self.dir_path = dir_path
        self.signals = WorkerSignals()
        self.classifier = classifier()

    @pyqtSlot()
    def run(self):
        """ Runs the thread """
        input_ = {'working_dir': self.dir_path}

        try:
            result = self.classifier.predict(json.dumps(input_))
            self.signals.result.emit(result)  # Return the result of the processing
        except:
            traceback.print_exc()
            exctype, value = sys.exc_info()[:2]
            self.signals.result.emit(json.dumps({'exception type': str(exctype), 'value': str(value), 'traceback': str(traceback.format_exc())}))



        


class App(QWidget):
    """ GUI """
    def __init__(self):
        super().__init__()
        self.title = 'Application'
        self.left = 50
        self.top = 50
        self.width = 1024
        self.height = 600
        self.init_ui()

        self.threadpool = QThreadPool()
        self._dialogs = []
        self.html = ""

    def init_ui(self):
        """
        Initialize the window and add content
        """

        self.setWindowTitle(self.title)
        self.setGeometry(self.left, self.top, self.width, self.height)

        # Style
        white = "#fff"
        yellow = "#ff0"
        orange = "#fa0"
        red = "#f00"
        grey = "#7c7c7c"
        button_style = "background-color: #D7D7D7; border-style: solid; border-width: 2px; border-color: black; border-radius: 5px; font: bold; font-size: 17px"
        text_style = "font-size: 17px; color: black"
        header_style = "font-size: 17px; color: black; font-weight: bold"
        clickable_label_style = "font-size: 17px; color: black; background-color:#ffffff; padding-left: 20px"


        layout = QGridLayout()

        # Add elements to the ui
        left_column = QVBoxLayout()

        self.open_btn = QPushButton(text="OPEN")
        self.open_btn.setFixedHeight(40)
        self.open_btn.setStyleSheet(button_style)
        self.open_btn.clicked.connect(self.choose_file)

        left_column.addWidget(self.open_btn)
        
        registry_frame = QFrame()
        registry = QVBoxLayout()

        name_label = QLabel("Name")
        name_label.setStyleSheet(text_style)	
        registry.addWidget(name_label)
        self.name = QLineEdit()
        self.name.setStyleSheet(text_style)
        registry.addWidget(self.name)
        
        surname_label = QLabel("Last name")
        surname_label.setStyleSheet(text_style)
        registry.addWidget(surname_label)
        self.surname = QLineEdit()
        self.surname.setStyleSheet(text_style)
        registry.addWidget(self.surname)


        dob_label = QLabel("Date of birth")
        dob_label.setStyleSheet(text_style)
        registry.addWidget(dob_label)
        dob_grid = QGridLayout()
        dob_btn = QPushButton(icon=QIcon("resources/calendar_icon.png"))
        dob_btn.clicked.connect(self.set_date_of_birth)
        dob_btn.setFixedWidth(35)
        dob_btn.setFixedHeight(35)
        dob_btn.setIconSize(QSize(30, 30))
        dob_grid.addWidget(dob_btn, 0, 0)
        self.date_of_birth = ClickableQLabel(self)
        self.date_of_birth.clicked.connect(self.set_date_of_birth)
        self.date_of_birth.setFixedHeight(self.surname.sizeHint().height())
        self.date_of_birth.setStyleSheet(clickable_label_style)
        dob_grid.addWidget(self.date_of_birth, 0, 1)
        dob_frame = QFrame()
        dob_frame.setLayout(dob_grid)
        registry.addWidget(dob_frame)

        doa_label = QLabel("Date of acquisition")
        doa_label.setStyleSheet(text_style)
        registry.addWidget(doa_label)
        doa_grid = QGridLayout()
        doa = QPushButton(icon=QIcon("resources/calendar_icon.png"))
        doa.clicked.connect(self.set_date_of_acquisition)
        doa.setFixedWidth(35)
        doa.setFixedHeight(35)
        doa.setIconSize(QSize(30, 30))

        doa_grid.addWidget(doa, 0, 0)
        self.date_of_acquisition = ClickableQLabel(self)
        self.date_of_acquisition.clicked.connect(self.set_date_of_acquisition)
        self.date_of_acquisition.setFixedHeight(self.surname.sizeHint().height())
        self.date_of_acquisition.setStyleSheet(clickable_label_style)
        doa_grid.addWidget(self.date_of_acquisition, 0, 1)
        doa_frame = QFrame()
        doa_frame.setLayout(doa_grid)
        registry.addWidget(doa_frame)

        registry_frame.setFrameShape(QFrame.StyledPanel)
        registry_frame.setLineWidth(0.6)
        registry_frame.setLayout(registry)
        left_column.addWidget(registry_frame)
        
        legend = QGridLayout()
        header = QLabel("Legend")
        header.setStyleSheet(header_style)

        legend.addWidget(header)
        whitelabel = self.get_label(white)
        legend.addWidget(whitelabel, 1, 0)
        score0_label = QLabel("Score 0");
        score0_label.setStyleSheet(text_style)
        legend.addWidget(score0_label, 1, 1)
        yellowlabel = self.get_label(yellow)
        legend.addWidget(yellowlabel, 2, 0)
        score1_label = QLabel("Score 1");
        score1_label.setStyleSheet(text_style)
        legend.addWidget(score1_label, 2, 1)
        orangelabel = self.get_label(orange)
        legend.addWidget(orangelabel, 3, 0)
        score2_label = QLabel("Score 2");
        score2_label.setStyleSheet(text_style)
        legend.addWidget(score2_label, 3, 1)
        redlabel = self.get_label(red)
        legend.addWidget(redlabel, 4, 0)
        score3_label = QLabel("Score 3");
        score3_label.setStyleSheet(text_style)
        legend.addWidget(score3_label, 4, 1)
        greylabel = self.get_label(grey)
        legend.addWidget(greylabel, 5, 0)
        score_nm_label = QLabel("Not measured");
        score_nm_label.setStyleSheet(text_style)
        legend.addWidget(score_nm_label, 5, 1)

        legend_frame = QFrame()
        legend_frame.setFrameShape(QFrame.StyledPanel) 
        legend_frame.setLineWidth(0.6)
        legend_frame.setLayout(legend)
        left_column.addWidget(legend_frame)

        

        totals_box_layout = QVBoxLayout()
        t_header = QLabel("Totals")
        t_header.setStyleSheet(header_style)
        self.pathological_areas = QLabel("Pathological areas: ")
        self.pathological_areas.setStyleSheet(text_style)
        totals_box_layout.addWidget(t_header)
        totals_box_layout.addWidget(self.pathological_areas)
        totals = QGridLayout()
        totals.addWidget(self.get_label(white), 0, 0)
        self.number_whites = QLabel("")
        self.number_whites.setStyleSheet(header_style)
        totals.addWidget(self.number_whites, 0, 1)
        totals.addWidget(self.get_label(yellow), 1, 0)
        self.number_yellow = QLabel("")
        self.number_yellow.setStyleSheet(header_style)
        totals.addWidget(self.number_yellow, 1, 1)
        totals.addWidget(self.get_label(orange), 2, 0)
        self.number_orange = QLabel("")
        self.number_orange.setStyleSheet(header_style)
        totals.addWidget(self.number_orange, 2, 1)
        totals.addWidget(self.get_label(red), 3, 0)
        self.number_red = QLabel("")
        self.number_red.setStyleSheet(header_style)
        totals.addWidget(self.number_red, 3, 1)
        temp_frame = QFrame()
        temp_frame.setLayout(totals)
        totals_box_layout.addWidget(temp_frame)
    
        totals_frame = QFrame()
        totals_frame.setFrameShape(QFrame.StyledPanel)
        totals_frame.setLineWidth(0.6)
        totals_frame.setLayout(totals_box_layout)
        #layout.addWidget(totals_frame, 1, 0)
        left_column.addWidget(totals_frame)


        self.generate_report_btn = QPushButton(text="GENERATE REPORT")
        self.generate_report_btn.setFixedHeight(40)
        self.generate_report_btn.setStyleSheet(button_style)
        self.generate_report_btn.clicked.connect(self.generate_report)
        left_column.addWidget(self.generate_report_btn)









        left_column_frame = QFrame()
        left_column_frame.setLayout(left_column)
        layout.addWidget(left_column_frame, 0, 0)
        layout.setColumnMinimumWidth(0, 300)
        layout.setColumnMinimumWidth(1, 700)
        layout.setRowStretch(0, 5)
        layout.setRowStretch(1, 3)
        
        self.webview = QWebEngineView(None)
        # self.webview.setHtml(self.html)
        layout.addWidget(self.webview, 0, 1)
 





        note_layout = QVBoxLayout()
        n_header = QLabel("Notes of the clinician")
        n_header.setStyleSheet(header_style)
        self.clinician_notes = QTextEdit()
        self.clinician_notes.setPlainText("")
        note_layout.addWidget(n_header)
        note_layout.addWidget(self.clinician_notes)
        note_frame = QFrame()
        note_frame.setLayout(note_layout)
        layout.addWidget(note_frame, 1, 1)

        self.setLayout(layout)
        self.show()

    def select_date(self, label):
        widget = Calendar()
        widget.setWindowModality(Qt.ApplicationModal)
        widget.exec_()
        result = widget.selectedDate
        label.setText(result)

    def set_date_of_birth(self):
        self.select_date(self.date_of_birth)

    def set_date_of_acquisition(self):
        self.select_date(self.date_of_acquisition)

    @pyqtSlot()
    def choose_file(self):
        """ Opens the file chooser and starts processing in a separate thread """
        data_path = QFileDialog.getExistingDirectory(self, "Select folder")

        if len(data_path) == 0:
            return
        worker = Worker(data_path, TFClassifier)
        worker.signals.result.connect(self.process_result)
        self.threadpool.start(worker)

    def process_result(self, task):
        """ Retrieves the output of a task """
        task_dict = json.loads(task)
        html = customize_report(task)

        # Show output
        self.html = html
        self.webview.setHtml(self.html)
        self.pathological_areas.setText("Pathological areas: {}/14".format(task_dict['pathological_areas']))
        self.number_whites.setText(str(task_dict['n_score_0']))
        self.number_yellow.setText(str(task_dict['n_score_1']))
        self.number_orange.setText(str(task_dict['n_score_2']))
        self.number_red.setText(str(task_dict['n_score_3']))
        # Save to PDF

    def show_alert(self, task_dict, fields):
        """ Shows a generic alert. task_dict is a dictionary containing at least the "name" field and the one contained in fields """
        new_window = QDialog()
        new_window.setWindowTitle("{}".format(task_dict['name']))

        layout = QVBoxLayout()

        for field in fields:
            label = QLabel("{}: {}".format(field.capitalize(), task_dict[field]))
            layout.addWidget(label)

        new_window.setLayout(layout)
        self._dialogs.append(new_window)
        new_window.show()

        # Remove unused dialogs
        to_remove = []
        for d in self._dialogs:
            # Check if some dialogs have been closed
            if not d.isVisible():
                to_remove.append(d)

        for tr in to_remove:
            self._dialogs.remove(tr)
            
    def get_label(self, color):
        """ Returns a label of the color specified (in HTML) """
        tmp = QLabel()
        tmp.setStyleSheet("border: 1px solid #444;background-color:{};".format(color))
        tmp.setFixedWidth(50)
        tmp.setFixedHeight(20)
        return tmp

    def generate_report(self):
        output_dir = QFileDialog.getExistingDirectory(self, "Select folder")
        if len(output_dir) == 0:
            return
        html = self.html
        totals = [k.text() for k in [self.number_whites, self.number_yellow, self.number_orange, self.number_red]]

        html = generate_output_html(html, self.name.text(), self.surname.text(), self.date_of_birth.text(), 
                self.date_of_acquisition.text(), self.pathological_areas.text(), totals, self.clinician_notes.toPlainText())
        
        export_html(html, os.path.join(output_dir, "Report.html"))
        export_pdf(html, os.path.join(output_dir, "Report.pdf"))


if __name__ == '__main__':
    app = QApplication([""])
    ex = App()
    sys.exit(app.exec_())
