#! /usr/bin/python
import os
import time

while (True):
   if os.fork()==0:
      os.system("python recomender.py")
      exit()
   else:
      time.sleep(5)
