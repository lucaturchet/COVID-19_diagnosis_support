#!/usr/bin/python3
"""
This file contains the implementation of the main interface for the program

Authors: Leonardo Lucio Custode and Luca Turchet
Copyright: University of Trento

Date: 13/3/2020
"""
import os, shutil
import sys
import time
import json
import threading
import traceback
import subprocess
import re
import urllib.parse as urlparse
from pathlib import Path
from urllib.parse import parse_qs
from reportlab.pdfgen import canvas
from classifiers import TFClassifier
from utilities import customize_report, export_pdf, export_html, generate_output_html, Calendar, ClickableQLabel
from PyQt5.QtWidgets import QApplication, QSizePolicy, QWidget, QVBoxLayout, QPushButton, QFileDialog, QLabel, QDialog, QGridLayout, QFrame, QLineEdit, QTextEdit, QRubberBand, QMessageBox, QMainWindow
from PyQt5.QtGui import QIcon, QPixmap, QMovie
from PyQt5.QtCore import pyqtSlot, QThreadPool, QRunnable, QObject, pyqtSignal, Qt, QSize, QPoint, QRect, QUrl
from PyQt5.QtWebEngineWidgets import QWebEngineView, QWebEnginePage



class ClickableWebPage(QWebEnginePage):
    def __init__(self,parent=None):
        super(ClickableWebPage,self).__init__(parent)
        self.signals = AreaSignals()

    @pyqtSlot()
    def acceptNavigationRequest(self, url, type, isMainFrame):
        result = super(ClickableWebPage,self).acceptNavigationRequest(url, type, isMainFrame)
        #print("Clicked url: "+ url.toString())
        parsed = urlparse.urlparse(url.toString())
        valsDict = parse_qs(parsed.query)
        if 'id' in valsDict.keys():
            id = valsDict['id'][0]
            self.signals.id.emit(id)
            #print("Clicked area "+id)

        return result


class VideoCropWindow(QMainWindow):
    def __init__(self, parent=None):
        super(VideoCropWindow, self).__init__(parent)
        self.init_ui()

    def init_ui(self):
        self.setGeometry(50, 50, 100, 100)
        self.setWindowTitle('Crop Video') 
        self.setMaximumWidth(1280)
        self.setMaximumHeight(1280)


class AreaSignals(QObject):
    id = pyqtSignal(str)


class WorkerSignals(QObject):
    result = pyqtSignal(str)


class VideoView(QLabel):

    def __init__(self, parent = None):
    
        QLabel.__init__(self, parent)
        self.rubberBand = QRubberBand(QRubberBand.Rectangle, self)
        self.origin = QPoint()
        self.minSquareSide = 256
    
    def mousePressEvent(self, event):
    
        if event.button() == Qt.LeftButton:
            self.rubberBand.hide()

            self.origin = QPoint(event.pos())
            print(self.origin)
            self.rubberBand.setGeometry(QRect(self.origin, QSize()))
            self.rubberBand.show()
    
    def mouseMoveEvent(self, event):
    
        if not self.origin.isNull():
            newPoint = QPoint(event.pos())
            # get minimum side of selection to make square
            width = abs(newPoint.x() - self.origin.x())
            height = abs(newPoint.y() - self.origin.y())
            side = min(width,height)

            self.rubberBand.setGeometry(QRect(self.origin, QPoint(self.origin.x()+side, self.origin.y()+side)).normalized())

    
    def mouseReleaseEvent(self, event):
        newPoint = QPoint(event.pos())
        width = abs(newPoint.x() - self.origin.x())
        height = abs(newPoint.y() - self.origin.y())

        side = min(width,height)

        if(side < self.minSquareSide):
            side = self.minSquareSide
            self.rubberBand.setGeometry(QRect(self.origin, QPoint(self.origin.x()+side, self.origin.y()+side)).normalized())

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


class VideoWorker(QRunnable):
    '''
    Worker thread, used for the parallelization
    '''
    def __init__(self, commandStringList, successMessage, failureMessage):
        super(VideoWorker, self).__init__()
        self.commandStringList = commandStringList
        self.signals = WorkerSignals()
        self.failureMessage = failureMessage
        self.successMessage = successMessage

    @pyqtSlot()
    def run(self):
        """ Runs the thread """
        try:
            subprocess.call(self.commandStringList)
            self.signals.result.emit(json.dumps({'value': self.successMessage}))
        except:
            traceback.print_exc()
            exctype, value = sys.exc_info()[:2]
            #print(str(exctype))
            #print(str(value))
            self.signals.result.emit(json.dumps({'value': self.failureMessage}))


class App(QWidget):
    """ GUI """
    def __init__(self):
        super().__init__()
        self.title 				= 'Lung areas scoring'
        self.left 				= 50
        self.top 				= 50
        self.top_row_height		= 600 
        self.bottom_row_height	= 250
        self.left_column_width  = 250
        self.right_column_width = 800 
        self.width 				= self.left_column_width + self.right_column_width
        self.height 			= self.top_row_height + self.bottom_row_height
        self.video_label_width  = 600 # height computed automatically to preserve aspect ratio
        self.minImageCropSize   = 256 # min input size for neural network 

        self.tmp_dir = os.getcwd()+"/tmp"
        self.lungs_template_page_name = "image_webView.html"
        self.lungs_customized_page_name = "image_customized.html"
        self.lungs_template_page = os.getcwd()+"/resources/"+self.lungs_template_page_name
        self.lungs_customized_page = os.getcwd()+"/resources/"+self.lungs_customized_page_name
        # Mac
        self.ffmpeg_bin = os.getcwd()+"/bin/ffmpeg"
        # Windows
        #self.ffmpeg_bin = os.getcwd()+"/bin/ffmpeg.exe"

        self.init_ui()

        self.threadpool = QThreadPool()
        self._dialogs = []
        self.html = ""
        self.task = ""

        self.create_directory(self.tmp_dir)
        # used when user wants to reset everything. Needed to choose the image file page to load
        self.startNewSession = True
        self.clickedAreaName = ""


    def init_ui(self):
        """
        Initialize the window and add content
        """
        self.setFixedSize(self.width, self.height)
        self.setWindowTitle(self.title)
        self.setGeometry(self.left, self.top, self.width, self.height)

        # Set background color for Mac compatibility
        p = self.palette()
        p.setColor(self.backgroundRole(), Qt.white)
        self.setPalette(p)

        # Style
        white  = "#fff"
        yellow = "#ff0"
        orange = "#fa0"
        red    = "#f00"
        grey   = "#7c7c7c"
        #button_style          = "background-color: #D7D7D7; border-style: solid; border-width: 2px; border-color: black; border-radius: 5px; font: bold; font-size: 17px"
        # Mac compatibility
        button_style          = "color: black; background-color: #D7D7D7; border-style: solid; border-width: 2px; border-color: black; border-radius: 5px; font: bold; font-size: 17px"
        #text_style            = "font-size: 17px; color: black"
        # Mac compatibility
        text_style            = "font-size: 17px; color: black; background-color: rgb(255, 255, 255);"
        text_bold_style       = "font-size: 17px; color: black; font-weight: bold"
        text_totals_style     = "font-size: 17px; color: black; font-weight: bold; margin-left: 10px"
        header_style          = "font-size: 17px; color: black; font-weight: bold"
        clickable_label_style = "font-size: 17px; color: black; background-color:#ffffff; padding-left: 20px"
        button_height = 40

        self.int_to_color_map      = {0: "white", 1: "yellow", 2: "orange", 3: "red", 4: "grey"}

        layout = QGridLayout()

        panel_top_left = QVBoxLayout()

        self.reset_btn = QPushButton(text="RESTART")
        self.reset_btn.setFixedHeight(button_height)
        self.reset_btn.setStyleSheet(button_style)
        self.reset_btn.clicked.connect(self.reset_session)

        panel_top_left.addWidget(self.reset_btn)
       
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
        dob_btn.setFixedWidth(button_height)
        dob_btn.setFixedHeight(button_height)
        dob_btn.setIconSize(QSize(button_height, button_height))
        dob_btn.setStyleSheet("border:none")
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
        doa_btn = QPushButton(icon=QIcon("resources/calendar_icon.png"))
        doa_btn.clicked.connect(self.set_date_of_acquisition)
        doa_btn.setFixedWidth(button_height)
        doa_btn.setFixedHeight(button_height)
        doa_btn.setIconSize(QSize(button_height, button_height))
        doa_btn.setStyleSheet("border:none")

        doa_grid.addWidget(doa_btn, 0, 0)
        self.date_of_acquisition = ClickableQLabel(self)
        self.date_of_acquisition.clicked.connect(self.set_date_of_acquisition)
        self.date_of_acquisition.setFixedHeight(self.surname.sizeHint().height())
        self.date_of_acquisition.setStyleSheet(clickable_label_style)
        doa_grid.addWidget(self.date_of_acquisition, 0, 1)
        doa_frame = QFrame()
        doa_frame.setLayout(doa_grid)
        registry.addWidget(doa_frame)

        registry_frame = QFrame()
        registry_frame.setFrameShape(QFrame.StyledPanel)
        registry_frame.setLineWidth(0.6)
        registry_frame.setLayout(registry)
        panel_top_left.addWidget(registry_frame)
        
        legend = QVBoxLayout()
        header_legend = QLabel("Legend")
        header_legend.setStyleSheet(header_style)
        legend.addWidget(header_legend)

        legend_grid = QGridLayout()
        legend_grid.addWidget(header_legend)
        whitelabel = self.get_label(white)
        legend_grid.addWidget(whitelabel, 0, 0)
        score0_label = QLabel("Score 0");
        score0_label.setStyleSheet(text_style)
        legend_grid.addWidget(score0_label, 0, 1)
        yellowlabel = self.get_label(yellow)
        legend_grid.addWidget(yellowlabel, 1, 0)
        score1_label = QLabel("Score 1");
        score1_label.setStyleSheet(text_style)
        legend_grid.addWidget(score1_label, 1, 1)
        orangelabel = self.get_label(orange)
        legend_grid.addWidget(orangelabel, 2, 0)
        score2_label = QLabel("Score 2");
        score2_label.setStyleSheet(text_style)
        legend_grid.addWidget(score2_label, 2, 1)
        redlabel = self.get_label(red)
        legend_grid.addWidget(redlabel, 3, 0)
        score3_label = QLabel("Score 3");
        score3_label.setStyleSheet(text_style)
        legend_grid.addWidget(score3_label, 3, 1)
        greylabel = self.get_label(grey)
        legend_grid.addWidget(greylabel, 4, 0)
        score_nm_label = QLabel("Not measured");
        score_nm_label.setStyleSheet(text_style)
        legend_grid.addWidget(score_nm_label, 4, 1)
        legend.addLayout(legend_grid)

        legend_frame = QFrame()
        legend_frame.setFrameShape(QFrame.StyledPanel) 
        legend_frame.setLineWidth(0.6)
        legend_frame.setLayout(legend)
        panel_top_left.addWidget(legend_frame)


        panel_bottom_left = QVBoxLayout()

        totals = QVBoxLayout()
        header_totals = QLabel("Totals")
        header_totals.setStyleSheet(header_style)

        self.pathological_areas = QLabel("Pathological areas: ")
        self.pathological_areas.setStyleSheet(text_style)
        totals.addWidget(header_totals)
        totals.addWidget(self.pathological_areas)

        totals_grid = QGridLayout()
        totals_grid.addWidget(self.get_label(white), 0, 0)
        self.number_whites = QLabel("")
        self.number_whites.setStyleSheet(text_totals_style)
        totals_grid.addWidget(self.number_whites, 0, 1)
        totals_grid.addWidget(self.get_label(yellow), 1, 0)
        self.number_yellow = QLabel("")
        self.number_yellow.setStyleSheet(text_totals_style)
        totals_grid.addWidget(self.number_yellow, 1, 1)
        totals_grid.addWidget(self.get_label(orange), 2, 0)
        self.number_orange = QLabel("")
        self.number_orange.setStyleSheet(text_totals_style)
        totals_grid.addWidget(self.number_orange, 2, 1)
        totals_grid.addWidget(self.get_label(red), 3, 0)
        self.number_red = QLabel("")
        self.number_red.setStyleSheet(text_totals_style)
        totals_grid.addWidget(self.number_red, 3, 1)
        totals.addLayout(totals_grid)
       
        self.number_grey = QLabel("")
         
        totals_frame = QFrame()
        totals_frame.setFrameShape(QFrame.StyledPanel)
        totals_frame.setLineWidth(0.6)
        totals_frame.setLayout(totals)
        panel_bottom_left.addWidget(totals_frame)

        self.generate_report_btn = QPushButton(text="GENERATE REPORT")
        self.generate_report_btn.setFixedHeight(button_height)
        self.generate_report_btn.setStyleSheet(button_style)
        self.generate_report_btn.clicked.connect(self.generate_report)
        panel_bottom_left.addWidget(self.generate_report_btn)


        panel_top_left_frame = QFrame()
        panel_top_left_frame.setLayout(panel_top_left)
        panel_bottom_left_frame = QFrame()
        panel_bottom_left_frame.setLayout(panel_bottom_left)

        layout.addWidget(panel_top_left_frame, 0, 0)
        layout.addWidget(panel_bottom_left_frame, 1, 0)

        
        self.webview = QWebEngineView(None)
        self.webpage = ClickableWebPage()
        self.webview.setPage(self.webpage)

        self.webpage.load(QUrl(Path(self.lungs_template_page).absolute().as_uri()))
        self.webpage.signals.id.connect(self.choose_video_file)

        layout.addWidget(self.webview, 0, 1)
        self.webview.show()


        self.video_crop_window = VideoCropWindow(self)
        self.video_crop_window.layout = QVBoxLayout()

        # show video frame for cropping
        panel_video = QVBoxLayout()
        self.panel_video_frame = QFrame()
        self.panel_video_frame.setLayout(panel_video)

        self.video_crop_window.layout.addWidget(self.panel_video_frame)
        self.video_crop_window.setCentralWidget(self.panel_video_frame)
        self.video_crop_window.setLayout(self.video_crop_window.layout)

        self.video_label = VideoView()

        self.video_label.setScaledContents(True)
        self.video_label.setMinimumSize(1,1)
        panel_video.addWidget(self.video_label)

        self.crop_btn = QPushButton(text="CROP VIDEO")
        self.crop_btn.setFixedHeight(button_height)
        self.crop_btn.setStyleSheet(button_style)
        self.crop_btn.clicked.connect(self.crop_video)

        panel_video.addWidget(self.crop_btn)

        self.m_label_gif = QLabel()

        self.m_movie_gif = QMovie("resources/loadingGif.gif")
        self.m_label_gif.setMovie(self.m_movie_gif)
        #self.m_label_gif.setScaledContents(True)
        self.m_label_gif.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
        self.m_label_gif.setAlignment(Qt.AlignCenter)
        self.m_movie_gif.setScaledSize(QSize(75,75))

        gifLayout = QVBoxLayout()
        self.video_label.setLayout(gifLayout)
        gifLayout.addWidget(self.m_label_gif, alignment=Qt.AlignCenter)

        self.m_movie_gif.stop()
        self.m_label_gif.hide()


        note_layout = QVBoxLayout()
        n_header = QLabel("Notes of the clinician")
        n_header.setStyleSheet(header_style)
        self.clinician_notes = QTextEdit()
        self.clinician_notes.setPlainText("")
        self.clinician_notes.setStyleSheet(text_style)

        note_layout.addWidget(n_header)
        note_layout.addWidget(self.clinician_notes)
        note_frame = QFrame()
        note_frame.setLayout(note_layout)
        layout.addWidget(note_frame, 1, 1)

        layout.setRowStretch

        layout.setRowMinimumHeight(0, self.top_row_height)
        layout.setRowMinimumHeight(1, self.bottom_row_height)
        layout.setColumnMinimumWidth(0, self.left_column_width)
        layout.setColumnMinimumWidth(1, self.right_column_width)
        layout.setRowStretch(0, 5)
        layout.setRowStretch(1, 3)
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


    def choose_video_file(self, areaID):
        """ Opens the file chooser and starts processing in a separate thread """

        dialogResult = QFileDialog.getOpenFileName(self,"Open Video", "", "Video Files (*.MOV *.mov *.AVI *.avi)")

        if len(dialogResult[0]) == 0:
            return

        self.clickedAreaName = areaID # to be used later in HTML substitution
        self.video_file_path = dialogResult[0]
        self.frame_path = ""
        self.extract_video_frame(self.video_file_path)

    @pyqtSlot()
    def reset_session(self):
        """ In case user wants to start from scracth, template image webview page has to be loaded"""
        self.startNewSession = True
        # set the template page in the webView
        self.webpage.load(QUrl(Path(self.lungs_template_page).absolute().as_uri()))
        # delete the customized page if present
        if(os.path.exists(self.lungs_customized_page)):
            os.remove(self.lungs_customized_page)



    def process_result(self, task):
        """ Retrieves the output of a task """

        task_dict = json.loads(task)
        self.task = task
        #html = customize_report("resources/image.html", task)

        html = ""

        if(self.startNewSession):
            shutil.copy(self.lungs_template_page, self.lungs_customized_page)
            self.startNewSession = False

        with open(self.lungs_customized_page) as file:
            html = "".join(file.readlines())

        if len(html) == 0:
            raise RuntimeError("The HTML template must not be empty")

        if(self.clickedAreaName == ""):
            raise RuntimeError("Clicked area name must not be empty")

        newColorInt = task_dict[self.clickedAreaName[1:]]  # strip initial _ character
        newColorClass = self.int_to_color_map[newColorInt] # must be same as in html CSS color class name

        # find id attribute in HTML path tag to change color specifically for one area
        matches = re.findall(r'<path id=\"'+self.clickedAreaName+'\" class=\"(.+?)\"', html)
        
        oldPath = ""
        newPath = ""
        paths = re.findall(r'<path.+?</path>', html)
        for path in paths:
            if(self.clickedAreaName in path):
                oldPath = path
                matches = re.findall(r'class=\"(.+?)\"', path)
                if(len(matches) == 1):
                    newPath = path.replace(matches[0], newColorClass)

        if(oldPath != "" and newPath != ""):
            html = html.replace(oldPath, newPath)

            # replace in the template also the page name in the links
            # TODO: do it only if it is start of new session
            html = html.replace(self.lungs_template_page_name, self.lungs_customized_page_name)

            self.html = html

            export_html(html, self.lungs_customized_page)

            self.webpage.load(QUrl(Path(self.lungs_customized_page).absolute().as_uri()))

            self.pathological_areas.setText("Pathological areas: <b>{}/14</b>".format(task_dict['pathological_areas']))
            self.number_whites.setText(str(task_dict['n_score_0']))
            self.number_yellow.setText(str(task_dict['n_score_1']))
            self.number_orange.setText(str(task_dict['n_score_2']))
            self.number_red.setText(str(task_dict['n_score_3']))
            self.number_grey.setText(str(task_dict['n_not_measured']))

            self.video_crop_window.hide()
            self.m_movie_gif.stop()
            self.m_label_gif.hide()


        else:
            raise RuntimeError("Error while customizing html template")


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
        html = customize_report("resources/report.html", self.task)
        totals = [k.text() for k in [self.number_whites, self.number_yellow, self.number_orange, self.number_red, self.number_grey]]

        name = self.name.text()
        surname = self.surname.text()
        dob = self.date_of_birth.text()
        doa = self.date_of_acquisition.text()

        html = generate_output_html(html, name, surname, dob, 
                doa, self.pathological_areas.text(), totals, self.clinician_notes.toPlainText())
        
        export_html(html, os.path.join(output_dir, "Report.html"))
        export_pdf(html, os.path.join(output_dir, "{}{}_{}_{}.pdf".format(surname, name, dob, doa)))


    def extract_video_frame(self, file_name):
        """ Open video with ffmpeg and get file_number frame. Not efficient for multiple calls"""
        self.delete_folder_contents(self.tmp_dir)

        commandStringList = [
            self.ffmpeg_bin, '-i', file_name, '-vframes', '1' ,'-f','image2',
            self.tmp_dir + '/frame%03d.jpeg'
        ]

        videoworker = VideoWorker(commandStringList, "success", "fail")
        videoworker.signals.result.connect(self.process_video_frame_result)
        self.threadpool.start(videoworker)


    def process_video_frame_result(self, task):
        """ Async call to process frame extraction result """

        task_dict = json.loads(task)

        if(task_dict["value"] == "success"):
            frame_basenames = sorted(
                list(filter(re.compile(r'frame').search, os.listdir(self.tmp_dir))))

            self.frame_path = os.path.join(self.tmp_dir, frame_basenames[0])
        else:
            self.frame_path = ""
            QMessageBox.about(self, "Extraction Result", "Could not extract frame from video")


        if(self.frame_path != ""):

            pixmap = QPixmap(self.frame_path)
            # calculate a view that preserves aspect ratio of video frame
            video_aspect_ratio = pixmap.height() / pixmap.width()
            video_label_height = int((video_aspect_ratio*self.video_label_width))

            self.video_label.setFixedWidth(pixmap.width())
            self.video_label.setFixedHeight(pixmap.height())
            self.crop_btn.setFixedWidth(pixmap.width())
            # set window size too

            self.video_label.minSquareSide = int(self.video_label_width/(pixmap.width())*self.minImageCropSize)

            self.video_label.setPixmap(pixmap)
            self.panel_video_frame.setFocus()
            self.video_crop_window.show()


    def crop_video(self):
        """Crop from ffmpeg using scaled pixels of rubber band"""

        self.m_movie_gif.start()
        self.m_label_gif.show()

        labelX = self.video_label.rubberBand.geometry().x()
        labelY = self.video_label.rubberBand.geometry().y()
        labelRight = self.video_label.rubberBand.geometry().x()+self.video_label.rubberBand.geometry().width()
        labelBottom = self.video_label.rubberBand.geometry().y()+self.video_label.rubberBand.geometry().height()
        labelWidth = self.video_label.width
        labelHeight = self.video_label.height
        # need to compensate in case video view has aspect ratio different than the original video, for UI reasons
        # a scale factor has to be applied from label space to video space, asuming
        # that the aspect ratio of the label was the same of the video
        labelToVideoScaleWidth = self.video_label.pixmap().width() / self.video_label.width()
        labelToVideoScaleHeight = self.video_label.pixmap().height() / self.video_label.height()
        videoWidth = self.video_label.pixmap().width()
        videoHeight = self.video_label.pixmap().height()
        videoFrameSpaceX = int((labelToVideoScaleWidth*labelX))
        videoFrameSpaceY = int((labelToVideoScaleHeight*labelY))
        videoFrameSpaceRight = int((labelToVideoScaleWidth*labelRight))
        videoFrameSpaceBottom = int((labelToVideoScaleHeight*labelBottom))

        pre, ext = os.path.splitext(self.video_file_path)
        new_video_name = pre+"_cropped"+ext

        #note: -crf 15 is the quality of exported video. See ffmpeg doc
        commandStringList = [
            self.ffmpeg_bin, '-y','-i', self.video_file_path, 
            '-filter:v',
            'crop='+str(videoFrameSpaceRight-videoFrameSpaceX)+':'+str(videoFrameSpaceBottom-videoFrameSpaceY)+':'+str(videoFrameSpaceX)+':'+str(videoFrameSpaceY)+'' ,
            '-crf',
            '15', 
            new_video_name
        ]

        videoworker = VideoWorker(commandStringList, "success", "Error exporting cropped video")
        videoworker.signals.result.connect(self.process_video_crop_result)
        self.threadpool.start(videoworker)


    def process_video_crop_result(self, task):
        """ Retrieves the output of a task """
        task_dict = json.loads(task)
        if(task_dict["value"] != "success" ):
            QMessageBox.about(self, "Crop Result", task_dict["value"])

        # clean tmp folder 
        self.delete_folder_contents(self.tmp_dir)

        dir = os.path.dirname(self.video_file_path)
        worker = Worker(dir, TFClassifier)
        worker.signals.result.connect(self.process_result)
        self.threadpool.start(worker)


    #TODO put in utils    
    def create_directory(self, directory):
        if not os.path.exists(directory):
            os.makedirs(directory)


    def delete_folder_contents(self, directory):
        for filename in os.listdir(directory):
            file_path = os.path.join(directory, filename)
            try:
                if os.path.isfile(file_path) or os.path.islink(file_path):
                    os.unlink(file_path)
                elif os.path.isdir(file_path):
                    shutil.rmtree(file_path)
            except Exception as e:
                print('Failed to delete %s. Reason: %s' % (file_path, e))


if __name__ == '__main__':
    app = QApplication([""])
    ex = App()
    sys.exit(app.exec_())
