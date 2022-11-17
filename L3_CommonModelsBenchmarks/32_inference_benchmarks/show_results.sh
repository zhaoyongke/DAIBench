#!/bin/bash

if [ $# -lt 1 ]
then
  echo "Usage : $BASH_SOURCE logdir"
  exit
fi

WORKDIR=$1

echo -e "Model,Batch,FP32,TF32,FP32*,TF32*,FP16,INT8" > results.csv
for model in alexnet googlenet resnet18 resnet50 resnet101 resnet152 vgg16 vgg19
do
  echo -e "===================${model}===================="
  batch=1
  echo -e "Batch\tFP32\tTF32\tFP32*\tTF32*\tFP16\tINT8"
  while [ $batch -le 128 ]
  do
    fp32=`cat $WORKDIR/${model}_batch${batch}_fp32.log | grep "Throughput" | grep "qps" | awk '{print $4}'`
    tf32=`cat $WORKDIR/${model}_batch${batch}_tf32.log | grep "Throughput" | grep "qps" | awk '{print $4}'`
    fp32_g=`cat $WORKDIR/${model}_batch${batch}_fp32_g.log | grep "Throughput" | grep "qps" | awk '{print $4}'`
    tf32_g=`cat $WORKDIR/${model}_batch${batch}_tf32_g.log | grep "Throughput" | grep "qps" | awk '{print $4}'`
    fp16=`cat $WORKDIR/${model}_batch${batch}_fp16.log | grep "Throughput" | grep "qps" | awk '{print $4}'`
    int8=`cat $WORKDIR/${model}_batch${batch}_int8.log | grep "Throughput" | grep "qps" | awk '{print $4}'`
    echo -e "$batch\t$fp32\t$tf32\t$fp32_g\t$tf32_g\t$fp16\t$int8"
    echo -e "$model,$batch,$fp32,$tf32,$fp32_g,$tf32_g,$fp16,$int8" >> results.csv
    batch=`expr $batch \* 2`
  done
done
echo -e "\nNote: * means with cudagraph"
