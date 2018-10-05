#!/usr/bin/env python
"""
Very simple HTTP server in python.

Usage::
    ./dummy-web-server.py [<port>]

Send a GET request::
    curl http://localhost

Send a HEAD request::
    curl -I http://localhost

Send a POST request::
    curl -d "foo=bar&bin=baz" http://localhost

"""
from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
import SocketServer
import logging
import cgi

class S(BaseHTTPRequestHandler):
    def _set_headers(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()

    def do_GET(self):
        self._set_headers()
        self.wfile.write("<html><body><h1>hi!</h1></body></html>")

    def do_HEAD(self):
        self._set_headers()
        
    def do_POST(self):
        # Doesn't do anything with posted data
        logging.debug('POST %s' % (self.path))

         # CITATION: http://stackoverflow.com/questions/4233218/python-basehttprequesthandler-post-variables
        ctype, pdict = cgi.parse_header(self.headers['content-type'])
        if ctype == 'multipart/form-data':
            postvars = cgi.parse_multipart(self.rfile, pdict)
        elif ctype == 'application/x-www-form-urlencoded':
            length = int(self.headers['content-length'])
            postvars = cgi.parse_qs(self.rfile.read(length), keep_blank_values=1)
        elif ctype == 'text/plain':
            length = int(self.headers['content-length'])
            post_body = self.rfile.read(length)
            logging.debug('PLAIN: %d, %s' % (length, post_body))
        else:
            postvars = {}

        # logging.debug('TYPE %s' % (ctype))
        # logging.debug('PATH %s' % (self.path))
        # logging.debug('ARGS %d' % (len(postvars)))
        # logging.debug('ARGS %s' % str(postvars))

        self._set_headers()
        self.wfile.write("<html>Ok</html>")
        
def run(server_class=HTTPServer, handler_class=S, port=8000):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    print 'Starting httpd...'
    httpd.serve_forever()

if __name__ == "__main__":
    from sys import argv

    logging.basicConfig(level=logging.DEBUG)
    if len(argv) == 2:
        run(port=int(argv[1]))
    else:
        run()
