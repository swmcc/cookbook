#!/usr/bin/env python

import json
import csv
import sys

## assumes first row is headers
def csv_to_json(filename):
    rows = []
    with open(filename, 'rb') as csvfile:
        reader = csv.reader(csvfile)
        headers = []
        for row in reader:
            if headers:
                rows.append(dict(zip(headers, row)))
            else:
                headers = row

    print json.dumps(rows, indent=4)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print "Usage %s <filename>" % (sys.argv[0])
        sys.exit(1)

    csv_to_json(sys.argv[1])
