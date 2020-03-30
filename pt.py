#!/bin/python3
import sys

def main():
    for arg in sys.argv[2:len(sys.argv)]:
        sr = sys.argv[1] + "/"+arg
        sys.stdout.write(sr)


main()
