#!/bin/bash
while read data; do
  echo $data
  dart --checked /home/gcrutchfield/mydart/stock/bin/onecompany.dart $data
done <  /home/gcrutchfield/mydart/stock/data/NASDAQ.txt
