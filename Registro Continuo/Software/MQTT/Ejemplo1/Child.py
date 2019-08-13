#!/usr/bin/env python3
import os
import sys

def main():
    r, w = map(int, sys.argv[1:])
    os.read(r, 12)
    os.close(r)
    os.write(w, b"This is a test")
    os.close(w)
    sys.exit(0)


if __name__ == '__main__':
    main()