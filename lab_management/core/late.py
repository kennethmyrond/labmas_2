import os
import time
import urllib.request as ur

while True:
    # os.system("start \"\" http://localhost:8000/late_borrow")

    
    s = ur.urlopen("http://localhost:8000/late_borrow")
    sl = s.read()
    print(sl)
    
    # Sleep for 1 hour (3600 seconds)
    time.sleep(10)