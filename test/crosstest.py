#! /usr/bin/env python3

# See README.txt for information and build instructions.

import sys
import os;
import crosstest_pb2 as cross

filename = "crosstest.bin"
if not os.path.exists(filename) :
  root = cross.Root()
  root.node1 = -2
  root.node2.extend(["1", "2", "3"])
  root.node3 = b"88889999"
  root.node4.node1.extend(['dfd', 'wwee'])
  root.node4.node2 = -1
  root.node5.seconds = 122333
  root.node5.nanos = 1223
  root.node6.longitude = 12.56
  root.node6.latitude = 455.32
  root.node7.seconds = 444
  root.node7.nanos = 33

  with open(filename, "wb") as file:
    file.write(root.SerializeToString())
    file.close()
else:
  root = cross.Root()
  with open(filename, "rb") as file:
    root.ParseFromString(file.read())
    file.close()

print(root.node1, root.node2, root.node3, sep=',', end='\n')
print(root.node4.node1, root.node4.node2, sep = ',', end='\n') 
