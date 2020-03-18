#!/usr/bin/python3
"""
This file contains the implementation for the response

Author: Leonardo Lucio Custode
Date: 17/3/2020
"""
import os
import time
import traceback
from datetime import date
from functools import partial
from utilities import Calendar, export_to_pdf
from PyQt5.QtWidgets import QApplication, QWidget, QGridLayout, QPushButton, QFileDialog, QLabel, QDialog, QLineEdit, QVBoxLayout, QComboBox, QPlainTextEdit
from PyQt5.QtGui import QIcon, QPixmap
from PyQt5.QtCore import pyqtSlot, QThreadPool, QRunnable, QObject, pyqtSignal, Qt, QThread
from PyQt5.QtWebEngineWidgets import QWebEngineView


def change_text(text, button):
    button.setText(text)
    button.show()

class Response(QWidget):
    def __init__(self, html):
        super().__init__()
        self.html = html
        self.title = "Response"
        self.left = 50
        self.top = 50
        self.width = 1024
        self.height = 900
        self.init_ui()
        self.threadpool = QThreadPool()

    def init_ui(self):
        self.setWindowTitle(self.title)
        self.setGeometry(self.left, self.top, self.width, self.height)
    
        self.layout = QVBoxLayout()

        # Create rows with labels and input boxes
        gridlayout = QGridLayout()
        gridlayout.addWidget(QLabel("Name"), 0, 0)
        self.name = QLineEdit(self)
        gridlayout.addWidget(self.name, 0, 1)
        gridlayout.addWidget(QLabel("Surname"), 1, 0)
        self.surname = QLineEdit(self)
        gridlayout.addWidget(self.surname, 1, 1)
        gridlayout.addWidget(QLabel("ID"), 2, 0)
        self.id = QLineEdit(self)
        gridlayout.addWidget(self.id, 2, 1)
        gridlayout.addWidget(QLabel("Date of birth"), 3, 0)
        
        # Create date fields
        self.dateofbirth = Calendar()
        self.dob_btn = QPushButton("Select date")
        self.dob_btn.clicked.connect(self.select_date_of_birth)
        gridlayout.addWidget(self.dob_btn, 3, 1)

        gridlayout.addWidget(QLabel("Date of examination"), 4, 0)
        self.date = Calendar()
        self.d_btn = QPushButton("Select date")
        self.d_btn.clicked.connect(self.select_date_of_examination)
        gridlayout.addWidget(self.d_btn, 4, 1)
        
        grid_container = QWidget()
        grid_container.setLayout(gridlayout)

        self.layout.addWidget(grid_container)

        # Add the webview
        self.webview = QWebEngineView(None)
        self.webview.setHtml(self.html)
        # self.webview.resize(800, 500)
        self.layout.addWidget(self.webview)

        # Add the "notes" field
        self.notes = QPlainTextEdit("Here the clinician can add a general comment on the findings")
        self.layout.addWidget(self.notes)

        # Create a button in the window
        self.button = QPushButton('Save', self)
        self.button.clicked.connect(self.save_to_pdf)
        self.layout.addWidget(self.button)
        
        self.setLayout(self.layout)
        self.show() 

    def select_date(self, widget, button):
        widget.setWindowModality(Qt.ApplicationModal)
        widget.exec_()
        result = widget.selectedDate
        change_text(result, button)

    def select_date_of_birth(self):
        self.select_date(self.dateofbirth, self.dob_btn)

    def select_date_of_examination(self):
        self.select_date(self.date, self.d_btn)

    def save_to_pdf(self):
        """ Add new content and save the file """
        output_dir = QFileDialog.getExistingDirectory(self, "Select output folder")
        html = self.html

        html = html.replace("_name", str(self.name.text()))
        html = html.replace("_surname", self.surname.text())
        html = html.replace("_id", self.id.text())
        html = html.replace("_dob", self.dob_btn.text())
        html = html.replace("_date", self.d_btn.text())
        html = html.replace("_notes", self.notes.toPlainText())

        html = html.replace("<!--EDITME", "")
        html = html.replace("EDITME-->", "")

        with open(os.path.join(output_dir, "Referto.html"), "w") as file:
            file.write(html)

        export_to_pdf(html, os.path.join(output_dir, "Referto.pdf")) 
