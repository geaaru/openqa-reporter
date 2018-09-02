# NAME

openqa-reporter - a openqa reporter files parser.

[![Build Status](https://travis-ci.org/geaaru/openqa-reporter.svg?branch=master)](https://travis-ci.org/geaaru/openqa-reporter)

# SYNOPSIS

  $ openqa-reporter parse --file <FILE.JSON> --ignore-errors -v
  $ openqa-reporter parse --dir <DIRECTORY>
  $ openqa-reporter parse --url <URL>
  $ openqa-reporter parse --url https://raw.githubusercontent.com/os-autoinst/openQA/master/t/testresults/00099/00099937-opensuse-13.1-DVD-i586-Build0091-kde/details-installer_desktopselection.json

  $ openqa-reporter mojo daemon --dir <DIRECTORY>

  # Help commands
  $ openqa-reporter help <command>
  $ openqa-reporter help|-h|--help

  # Global options
  -i --ignore-errors          Continue with errors.
  -l[=STR] --log_level[=STR]  Specify log level (debug, info, warn,
                              error). Default warn.
  -L[=STR] --log_file[=STR]   Specify a logfile instead of STDOUT.
  -v --verbose                Verbose output.


# DESCRIPTION

openqa-reporter is a parser of OpenQA platform Needles that return summary of single or multiple reports from CLI or Web UI.

# LICENSE

Copyright (C) Geaaru.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Geaaru <geaaru@gmail.com>
