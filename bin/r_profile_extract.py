#!/usr/bin/env python
import argparse
import argcomplete
import os
import sys
import re
import errno

parser = argparse.ArgumentParser()

parser.add_argument("-e", "--export-to", help="name of module to extract to", default="profile")
parser.add_argument("-x", "--extract", help="path to file to extract", required=True)
parser.add_argument("-d", "--directory", help="*module* dir to write classes to, eg ~/puppet-control/site/profile")

argcomplete.autocomplete(parser)
args = vars(parser.parse_args())

extract = args["extract"]
if os.path.isfile(extract):
  orig = open(extract, "r").read()

  # Transforms
  extracted = re.sub("r_profile", args["export_to"], orig)
  extracted = re.sub("R_profile", args["export_to"].capitalize(), extracted)

  if args["directory"]:
    # extract to the same file in target since only differ by module name
    if args["extract"][0] == '/':
      print("Must extract with path relative to top level directory when using --directory")
      sys.exit(1)
    else:
      output_file = os.path.join(args["directory"], args["extract"])
      directory_name = os.path.dirname(output_file)
      try:
        os.makedirs(directory_name)
      except OSError as exc:
        if exc.errno == errno.EEXIST and os.path.isdir(directory_name):
          pass
      with open(output_file, "w") as f:
        f.write(extracted)
        print("Wrote: %s" % (output_file))
  else:
    print(extracted)

else:
  print "File not found: " + extract
  sys.exit(1)
