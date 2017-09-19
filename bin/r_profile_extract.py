#!/usr/bin/env python
import argparse
import os
import sys
import re

parser = argparse.ArgumentParser()

parser.add_argument("-e", "--export-to", help="name of module to extract to", default="profile")
parser.add_argument("-x", "--extract", help="path to file to extract", required=True)

args = vars(parser.parse_args())

extract = args["extract"]
if os.path.isfile(extract):
  orig = open(extract, "r").read()

  # Transforms
  extracted = re.sub("r_profile", args["export_to"], orig)
  extracted = re.sub("R_profile", args["export_to"].capitalize(), extracted)

  print extracted

else:
  print "File not found: " + extract
  sys.exit(1)
