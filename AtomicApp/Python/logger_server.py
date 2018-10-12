#!/usr/bin/env python
"""
Simple server for the simpler logging swift utility

Usage::
    ./logger_server.py [<port>]

Send a GET request::
    curl http://localhost


"""
from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
import SocketServer
import logging
import cgi
import json

class S(BaseHTTPRequestHandler):
    def _set_headers(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()

    def send_json_response(self, response_code, response_dict):
        self.send_response(response_code)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps(response_dict))

    def error_response(self, msg):
        self.send_json_response(400, { "status": 400, "message": msg  } )

    def successful_response(self):
        self.send_json_response(200, { "status": 200, "message": "Ok"  } )

    def do_POST(self):

        #guards

        ctype, pdict = cgi.parse_header(self.headers['content-type'])

        if ctype != "text/plain":
            self.error_response("Invalid content type")
            return

        length = int(self.headers['content-length'])

        if length <= 0:
            self.error_response("Invalid body length")
            return

        post_body = self.rfile.read(length)
        logging.info(post_body)
        # self._set_headers()
        # self.wfile.write("<html>Ok</html>")

        self.successful_response()
        
def run(server_class=HTTPServer, handler_class=S, port=8000):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    print 'Starting httpd...'
    httpd.serve_forever()

if __name__ == "__main__":
    from sys import argv

    logging.basicConfig(level=logging.INFO, format="")
    # Enable the following instead if you want the log to be directed to a fila
    # logging.basicConfig(level=logging.INFO, format="", filename="applog.txt")
    if len(argv) == 2:
        run(port=int(argv[1]))
    else:
        run()
