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
from response_ui import Response
from classifiers import TFClassifier
from utilities import customize_report, export_to_pdf
from PyQt5.QtWidgets import QApplication, QWidget, QVBoxLayout, QPushButton, QFileDialog, QLabel, QDialog
from PyQt5.QtGui import QIcon, QPixmap
from PyQt5.QtCore import pyqtSlot, QThreadPool, QRunnable, QObject, pyqtSignal, Qt


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
        self.width = 320
        self.height = 180
        self.init_ui()

        self.threadpool = QThreadPool()
        self._dialogs = []
        self._relevant_fields = ['name']

    def init_ui(self):
        """
        Initialize the window and add content
        """

        self.setWindowTitle(self.title)
        self.setGeometry(self.left, self.top, self.width, self.height)

        # Create a layout and put the logo and a button into it
        layout = QVBoxLayout()
        
        image_label = QLabel("")
        pixmap = QPixmap('resources/logo_unitn.png')
        pixmap = pixmap.scaled(200, 80, Qt.KeepAspectRatio)
        image_label.setPixmap(pixmap)
        

        button = QPushButton("Select patient's folder")
        button.clicked.connect(self.choose_file)

        layout.addWidget(image_label, alignment=Qt.AlignRight)
        layout.addWidget(button)

        self.setLayout(layout)
        self.show()

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
        response = Response(html)
        self._dialogs.append(response)
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
            
            

if __name__ == '__main__':
    app = QApplication([""])
    ex = App()
    sys.exit(app.exec_())
