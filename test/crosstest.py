#! /usr/bin/env python3

# See README.txt for information and build instructions.

import sys
import crosstest_pb2 as cross

encoding = False

if encoding :
  root = cross.Root()
  root.node1 = -2
  root.node2.extend(["1", "2", "3"])
  root.node3 = b"88889999"
  root.node4.node1.extend(['dfd', 'wwee'])
  root.node4.node2 = -1

  with open("sample.bin", "wb") as file:
    file.write(root.SerializeToString())
    file.close()
else:
  root = cross.Root()
  with open("sample.bin", "rb") as file:
    root.ParseFromString(file.read())
    file.close()

print(root.node1, root.node2, root.node3, sep=',', end='\n')
print(root.node5.ToJsonString(), sep=",", end="\n")
print(root.node4.node1, root.node4.node2, sep = ',', end='\n') 
