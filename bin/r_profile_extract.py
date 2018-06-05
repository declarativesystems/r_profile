#!/usr/bin/env python
import argparse
import argcomplete
import os
import sys
import re
import errno

parser = argparse.ArgumentParser()

parser.add_argument("-e", "--export-to", help="name of module to extract to", default="profile")
parser.add_argument("-d", "--directory", help="*module* dir to write classes to, eg ~/puppet-control/site/profile")
group = parser.add_mutually_exclusive_group()
group.add_argument("-x", "--extract", help="path to file to extract")
group.add_argument("-p", "--puppet-enterprise", action="store_true", help="extract the basic set of Puppet Enterprise profiles")


argcomplete.autocomplete(parser)
args = vars(parser.parse_args())

if args["puppet_enterprise"]:
    extracts = [
        "lib/facter/sysconf_dir.rb",
        "lib/facter/systemd_active.rb",
        "lib/puppet/functions/r_profile/list_agent_platforms.rb",
        "manifests/puppet/master.pp",
        "manifests/puppet/master/agent_installers.pp",
        "manifests/puppet/master/autosign.pp",
        "manifests/puppet/master/hiera5.pp",
        "manifests/puppet/master/hiera_eyaml.pp",
        "manifests/puppet/master/license.pp",
        "manifests/puppet/master/proxy.pp",
        "manifests/windows/puppet_agent.pp",
        "manifests/linux/puppet_agent.pp",
        "templates/autosign.sh.epp",
        "files/hiera.yaml",
    ]
elif args["extract"]:
    extracts = [args["extract"]]
else:
    print "Must choose class(es) to extract with -x or -p"
    sys.exit(1)

for extract in extracts:
    if extract[0] == '/':
      print("Must extract with path relative to top level directory")
      sys.exit(1)

    if os.path.isfile(extract):
        orig = open(extract, "r").read()

        # Transforms
        extracted = re.sub("r_profile", args["export_to"], orig)
        extracted = re.sub("R_profile", args["export_to"].capitalize(), extracted)


        if args["directory"]:
            # output to file
            output_file = os.path.join(args["directory"], extract)
            parent_dir = os.path.dirname(output_file)
            try:
                os.makedirs(parent_dir)
            except OSError as exc:
                if exc.errno == errno.EEXIST and os.path.isdir(parent_dir):
                    pass


            with open(output_file, "w") as f:
                f.write(extracted)
                print("Wrote: %s" % (output_file))
        else:
            # output to STDOUT
            print(extracted)

    else:
      print "File not found: " + extract
      sys.exit(1)
