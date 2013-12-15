SimpleHTTPServer
================

A simple web server written in Io language that serves the given directory contents over a given port, similar to `python -m SimpleHTTPServer`


----------
Instructions
------------

Script takes directory path to serve and port to serve on. To run use

`io SimpleHTTPServer 12345 /Users/abhilash/tmp`

or

`./SimpleHTTPServer 12345 /Users/abhilash/tmp`

The above will start serving entire `/Users/abhilash/tmp` directory on port 12345

Dependencies
------------
 - [Io language][1], obviously
 - Io `Socket` Addon



  [1]: http://iolanguage.org/
