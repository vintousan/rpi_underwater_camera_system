#!/usr/bin/env python

# Underwater Visual Data Acquisition Algorithm
# Author: VJA
# 1 - Real-time Video Streaming (via HTTP) - Server Script 

import io
import picamera
import logging
import socketserver
from threading import Condition
from http import server
import time

PAGE="""\
<html>
<head>
<title>MJPEG streaming</title>
</head>
<body>
<h1>Underwater Real-time Streaming</h1>
<p>Resolution = 3280 x 2464<p>
<p>Frame Rate = 10 fps<p>
<img src="stream.mjpg" width="640" height="480" />
</body>
</html>
"""

class StreamingOutput(object):
    def __init__(self):
        self.frame = None
        self.buffer = io.BytesIO()
        self.condition = Condition()

    def write(self, buf):
        if buf.startswith(b'\xff\xd8'):
            # New frame, copy the existing buffer's content and notify all
            # clients it's available
            self.buffer.truncate()
            with self.condition:
                self.frame = self.buffer.getvalue()
                self.condition.notify_all()
            self.buffer.seek(0)
        return self.buffer.write(buf)

class StreamingHandler(server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            self.send_response(301)
            self.send_header('Location', '/index.html')
            self.end_headers()
        elif self.path == '/index.html':
            content = PAGE.encode('utf-8')
            self.send_response(200)
            self.send_header('Content-Type', 'text/html')
            self.send_header('Content-Length', len(content))
            self.end_headers()
            self.wfile.write(content)
        elif self.path == '/stream.mjpg':
            self.send_response(200)
            self.send_header('Age', 0)
            self.send_header('Cache-Control', 'no-cache, private')
            self.send_header('Pragma', 'no-cache')
            self.send_header('Content-Type', 'multipart/x-mixed-replace; boundary=FRAME')
            self.end_headers()
            try:
                while True:
                    with output.condition:
                        output.condition.wait()
                        frame = output.frame
                    self.wfile.write(b'--FRAME\r\n')
                    self.send_header('Content-Type', 'image/jpeg')
                    self.send_header('Content-Length', len(frame))
                    self.end_headers()
                    self.wfile.write(frame)
                    self.wfile.write(b'\r\n')
            except Exception as e:
                logging.warning(
                    'Removed streaming client %s: %s',
                    self.client_address, str(e))
        else:
            self.send_error(404)
            self.end_headers()

class StreamingServer(socketserver.ThreadingMixIn, server.HTTPServer):
    allow_reuse_address = True
    daemon_threads = True

def initVideoSettings():
    # Modified settings for localized application
    videoSettings = {
        'resolution': (3280,2464),    # Modified from (1600, 1200)
        'frameRate': 10,      
        'quality': 20,        
        'format': 'mjpeg',             # MJPEG since H264 encodes up to 1080p videos only
        'exposure': 'auto',  
        'AWB': 'auto',        
        'sharpness': 0,       
        'contrast': 0,        
        'brightness': 50,     
        'saturation': 0,       
        'ISO': 500,                    # Modified from 400 --> 500
        'vflip': False
        }
    return videoSettings

# Check camera function
def isCameraOperational():
    try:
        camera = PiCamera()
        camera.close()
        return True
    except BaseException as e:
        #logging.error(str(e))
        return False

#def main():

videoSettings = initVideoSettings()
camera_okay_flag = isCameraOperational()
    
with picamera.PiCamera(resolution = videoSettings['resolution'], framerate = videoSettings['frameRate']) as camera:
        
    camera.resolution = videoSettings['resolution']
    camera.exposure_mode = videoSettings['exposure']
    camera.awb_mode = videoSettings['AWB']
    camera.vflip = videoSettings['vflip']
    camera.sharpness = videoSettings['sharpness']
    camera.contrast = videoSettings['contrast']
    camera.brightness = videoSettings['brightness']
    camera.saturation = videoSettings['saturation']
    camera.iso = videoSettings['ISO'] 
    
    output = StreamingOutput()
    
    camera.start_recording(output, format=videoSettings['format'])
    try:
        address = ('', 8080) # Original 8000
        server = StreamingServer(address, StreamingHandler)
        server.serve_forever()
    finally:
        camera.stop_recording()
    
    # TASK: Status logging
    
#if __name__ == '__main__':   
 #   main()
