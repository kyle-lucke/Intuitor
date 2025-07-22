#!/bin/bash

#SBATCH -p gpu-mxian

## NOTE: vLLM does not work on node02 due to some weird bug related to V0 engine version
#SBATCH --nodelist=node01
#SBATCH --gpus 2

source ./openr1/bin/activate
source ~/.bashrc

export ACCELERATE_LOG_LEVEL=info

# Run vllm-serve in the background with nohup
nohup env CUDA_VISIBLE_DEVICES=0 trl vllm-serve --model "Qwen/Qwen3-0.6B" > vllm-serve.log 2>&1 &
VLLM_PID=$!
echo "vLLM server started with PID: $VLLM_PID"

## w/ accelerate
# # Run accelerate launch in the background with nohup
# CUDA_VISIBLE_DEVICES=1,2 \
#     accelerate launch --config_file recipes/accelerate_configs/zero2.yaml --num_processes=7 \
#     src/open_r1/intuitor.py --config recipes/Qwen3-0.6B/intuitor/config_demo.yaml --wandb_project open-r1 --run_name Qwen3-Intuitor-0.6B
# TRAINING_PID=$!

# w/o accelerate
CUDA_VISIBLE_DEVICES=1 \
    python src/open_r1/intuitor.py --config recipes/Qwen3-0.6B/intuitor/config_demo.yaml --wandb_project open-r1 --run_name Qwen3-Intuitor-0.6B

