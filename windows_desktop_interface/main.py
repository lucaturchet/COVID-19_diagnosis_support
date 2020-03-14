#!/usr/bin/python3
"""
This file contains the implementation of the main interface for the program

Author: Leonardo Lucio Custode
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
from PyQt5.QtWidgets import QApplication, QWidget, QVBoxLayout, QPushButton, QFileDialog, QLabel, QDialog
from PyQt5.QtGui import QIcon
from PyQt5.QtCore import pyqtSlot, QThreadPool, QRunnable, QObject, pyqtSignal


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
        input_ = {'avi_files': [], 'other_files':[]}

        try:
            for file in os.listdir(self.dir_path):
                if ".avi" in file:
                    input_['avi_files'].append(os.path.join(self.dir_path, file))
                else:
                    input_['other_files'].append(os.path.join(self.dir_path, file))

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
        self.left = 16
        self.top = 15
        self.width = 640
        self.height = 480
        self.init_ui()

        self.threadpool = QThreadPool()
        self._dialogs = []
        self._relevant_fields = ['paziente', 'esito classificazione', 'dettagli classificazione']

    def init_ui(self):
        """
        Initialize the window and add content
        """

        self.setWindowTitle(self.title)
        self.setGeometry(self.left, self.top, self.width, self.height)

        # Create a layout and put the button into it
        layout = QVBoxLayout()
        button = QPushButton("Seleziona cartella paziente")
        button.clicked.connect(self.choose_file)
        layout.addWidget(button)

        self.setLayout(layout)
        self.show()

    @pyqtSlot()
    def choose_file(self):
        """ Opens the file chooser and starts processing in a separate thread """
        data_path = QFileDialog.getExistingDirectory(self, "Seleziona cartella")

        if len(data_path) == 0:
            return
        worker = Worker(data_path, TFClassifier)
        worker.signals.result.connect(self.process_result)
        self.threadpool.start(worker)

    def process_result(self, task):
        """ Retrieves the output of a task """
        task_dict = json.loads(task)
        self.show_dialog(task_dict)
        self.create_pdf(task_dict)
    
    def create_pdf(self, task_dict):
        """ Creates a pdf file in the folder containing the AVI files """
        inch = 72
        title = "Referto {}".format(task_dict['paziente'])
        output_path = os.path.join(task_dict['avi_files'][0].split("\\")[0], title + ".pdf")

        try:
            # Delete the file if it exists
            if os.path.exists(output_path):
                os.remove(output_path)

            c = canvas.Canvas(output_path, pagesize=(8.5 * inch, 11 * inch))
            c.setStrokeColorRGB(0,0,0)
            c.setFillColorRGB(0,0,0)

            v = 10 * inch

            # Write the title
            c.setFont("Helvetica", 24)
            c.drawString(1 * inch, v, title)
            v -= 12 * 2

            # Write the details
            c.setFont("Helvetica", 12)

            fields = self._relevant_fields
            for field in fields:
                c.drawString(1 * inch, v, "{}: {}".format(field.capitalize(), task_dict[field]))
                v -= 12
            c.save()    
        except:
            self.show_alert({'paziente': task_dict['paziente'], 'errore': 'Si è verificato un errore durante il salvataggio del referto.' +
                              'Verificare che il file non sia già esistente ed aperto.'}, ['paziente', 'errore'])

    def show_alert(self, task_dict, fields):
        """ Shows a generic alert. task_dict is a dictionary containing at least the "paziente" field and the one contained in fields """
        new_window = QDialog()
        new_window.setWindowTitle("Esito paziente {}".format(task_dict['paziente']))

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
            
            
    def show_dialog(self, task_dict):
        """ Shows a summary (equal to the pdf) containing only the relevant fields """
        self.show_alert(task_dict, self._relevant_fields)


if __name__ == '__main__':
    app = QApplication([""])
    ex = App()
    sys.exit(app.exec_())
