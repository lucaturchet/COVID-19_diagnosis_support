#!/usr/bin/python3
"""
This file contains some utilities for the application

Author: Leonardo Lucio Custode
Date: 17/3/2020
"""
import re
import json
import pdfkit
import sys
from datetime import datetime
from PyQt5.QtCore import QEventLoop, QDate
from PyQt5.QtWidgets import QDialog, QVBoxLayout, QCalendarWidget, QWidget, QPushButton
from PyQt5.QtWebEngineWidgets import QWebEngineView

COLORS = {
    1: "white",
    2: "yellow",
    3: "orange",
    4: "red",
    5: "grey", 
}

KEYS = [
    'left-anterior-apical',
    'left-anterior-basal',
    'left-lateral-apical',
    'left-lateral-basal',
    'left-posterior-apical',
    'left-posterior-medial',
    'left-posterior-basal',
    'right-anterior-apical',
    'right-anterior-basal',
    'right-lateral-apical',
    'right-lateral-basal',
    'right-posterior-apical',
    'right-posterior-medial',
    'right-posterior-basal',
]


class Calendar(QDialog):
    currentDay = datetime.now().day
    currentMonth = datetime.now().month
    currentYear = datetime.now().year

    def __init__(self):
        super().__init__()
        self.setWindowTitle('Calendar')
        self.setGeometry(300, 300, 300, 300)
        self.initUI()

    def initUI(self):
        self.layout = QVBoxLayout()

        self.calendar = QCalendarWidget(self)
        self.calendar.setGridVisible(True)

        self.calendar.setMinimumDate(QDate(self.currentYear - 123, self.currentMonth, 1))
        self.calendar.setMaximumDate(QDate(self.currentYear, self.currentMonth, self.currentDay))

        self.calendar.setSelectedDate(QDate(self.currentYear, self.currentMonth, self.currentDay))
        self.setDate(self.calendar.selectedDate())
        self.calendar.clicked.connect(self.setDate)
        
        self.exit_button = QPushButton(text="Save", parent=self)
        self.exit_button.clicked.connect(self.close)
        
        self.layout.addWidget(self.calendar)
        self.layout.addWidget(self.exit_button)
        
        self.setLayout(self.layout)

    def printDateInfo(self, qDate):
        print('{0}/{1}/{2}'.format(qDate.day(), qDate.month(), qDate.year()))
        print(f'Day Number of the year: {qDate.dayOfYear()}')
        print(f'Day Number of the week: {qDate.dayOfWeek()}')

    def setDate(self, qDate):
        self.selectedDate = '{0}/{1}/{2}'.format(qDate.day(), qDate.month(), qDate.year())

    def getDate(self):
        return self.selectedDate


def customize_report(json_dict):
    """
    This function customizes the report with the values specified in the passed JSON.
    Returns a string containing the customized HTML source
    """
    html = ""

    with open("resources/report.html") as file:
        html = "".join(file.readlines())

    if len(html) == 0:
        raise RuntimeError("The HTML template must not be empty")

    patient = json.loads(json_dict)

    # Substitute the placeholders with the values
    for key in KEYS:
        value = patient[key]
        html = html.replace("_" + key, COLORS[value])
    
    return html
    

def export_to_pdf(html, output_name):
    """ This function exports a customized HTML to PDF """
    # FIXME: pdfkit does not support editable textareas
    # Also, it needs wkhtmltopdf and it must be added to PATH
    # pdfkit.from_string(html, output_name)

