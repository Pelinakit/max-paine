#!/usr/bin/env python3

import http.server
import socketserver
import argparse
import logging
import ssl
import os
from typing import Optional, Tuple, Type

class CORSRequestHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        # Serve Max Paine.html for root requests
        if self.path == '/':
            self.path = '/Max Paine.html'
        return super().do_GET()

    def end_headers(self):
        # Add CORS headers
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', '*')
        super().end_headers()

    def do_OPTIONS(self):
        # Handle preflight requests
        self.send_response(200)
        self.end_headers()

def run_server(port: int = 8000, 
            handler_class: Type[http.server.SimpleHTTPRequestHandler] = CORSRequestHandler,
            certfile: Optional[str] = '/app/fullchain.pem',
            keyfile: Optional[str] = '/app/privkey.pem') -> None:
    try:
        if os.path.exists(certfile) and os.path.exists(keyfile):
            # HTTPS server
            httpd = http.server.HTTPServer(("", port), handler_class)
            ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
            ssl_context.load_cert_chain(certfile=certfile, keyfile=keyfile)
            httpd.socket = ssl_context.wrap_socket(httpd.socket, server_side=True)
            protocol = "HTTPS"
        else:
            # Fallback to HTTP server if certificates not found
            httpd = socketserver.TCPServer(("", port), handler_class)
            protocol = "HTTP"
            logging.warning("SSL certificates not found, falling back to HTTP")
            
        logging.info(f"Serving {protocol} at port {port}")
        httpd.serve_forever()
    except KeyboardInterrupt:
        logging.info("\nServer stopped by user")
    except Exception as e:
        logging.error(f"Server error: {e}")
        raise

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    
    parser = argparse.ArgumentParser(description='Run an HTTP/HTTPS server with CORS enabled')
    parser.add_argument('--port', type=int, default=8000,
                    help='Port to run the server on (default: 8000)')
    parser.add_argument('--certfile', type=str, help='Path to SSL certificate file for HTTPS')
    parser.add_argument('--keyfile', type=str, help='Path to SSL private key file for HTTPS')
    args = parser.parse_args()
    
    # Use command line args if provided, otherwise use defaults
    certfile = args.certfile or '/app/fullchain.pem'
    keyfile = args.keyfile or '/app/privkey.pem'
    run_server(args.port, certfile=certfile, keyfile=keyfile)
