#!/bin/bash

#SBATCH -p gpu-mxian

#SBATCH --output=./logs/gen-%j.out
#SBATCH --error=./logs/gen-%j.err

## NOTE: vLLM does not work on node02 due to some weird bug related GPU arch not supporting V1 engine version
#SBATCH --nodelist=node01
#SBATCH --gpus 2

source ./openr1/bin/activate
source ~/.bashrc

export ACCELERATE_LOG_LEVEL=info

# start vLLM server in the background
nohup env CUDA_VISIBLE_DEVICES=0 trl vllm-serve --model Qwen/Qwen3-0.6B > vllm-serve-gen.log 2>&1 &VLLM_PID=$!; echo "vLLM server started with PID: $VLLM_PID"
             
# w/ accelerate (2 GPUs)
# CUDA_VISIBLE_DEVICES=1,2 accelerate launch --config_file recipes/accelerate_configs/zero3.yaml --num-processes=2 src/open_r1/gen.py --config recipes/Qwen3-0.6B/gen/config_demo.yaml --wandb_project open-r1 --run_name Qwen3-GEN-0.6B

# w/o accelerate (single GPU)
CUDA_VISIBLE_DEVICES=1 python src/open_r1/gen.py --config recipes/Qwen3-0.6B/gen/config_demo.yaml --wandb_project open-r1 --run_name Qwen3-GEN-0.6B

