#!/bin/python3
import sys

def main():
    for arg in sys.argv[2:len(sys.argv)]:
        sr = arg[0:2] + sys.argv[1][2:] + "/" + arg[2:] + " "
        sys.stdout.write(sr)


main()
