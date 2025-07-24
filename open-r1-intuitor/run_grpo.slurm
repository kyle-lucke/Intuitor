#!/bin/bash

#SBATCH -p gpu-mxian
#SBATCH --nodelist=node01
#SBATCH --gpus 2

source ./openr1/bin/activate
source ~/.bashrc

# export WANDB_API_KEY=YOUR_WANDB_API_KEY
export ACCELERATE_LOG_LEVEL=info

# Run vllm-serve in the background with nohup
# nohup env CUDA_VISIBLE_DEVICES=0 trl vllm-serve --model Qwen/Qwen3-0.6B > vllm-serve.log 2>&1 &

# srun --nodes=1 --ntasks=1 --nodelist=node01 trl vllm-serve --model Qwen/Qwen3-0.6B &

nohup env CUDA_VISIBLE_DEVICES=0 trl vllm-serve --model Qwen/Qwen3-0.6B > vllm-serve.log 2>&1 &
VLLM_PID=$!
echo "vLLM server started with PID: $VLLM_PID"

echo "vLLM server started in the background with PID: $VLLM_PID. Check vllm-serve.log for output."

# Run accelerate launch in the background with nohup
# nohup env CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7 ACCELERATE_LOG_LEVEL=info \
#     accelerate launch --config_file recipes/accelerate_configs/zero2.yaml --num_processes=7 \
#     src/open_r1/grpo.py --config recipes/Qwen2.5-3B/grpo/config_demo.yaml --wandb_project open-r1 --run_name Qwen2.5-GRPO-3B > run_grpo.log 2>&1 &

# w/ accelerate
# ACCELERATE_LOG_LEVEL=info \
#     accelerate launch --config_file recipes/accelerate_configs/zero2.yaml --num_processes=7 \
#     src/open_r1/grpo.py --config recipes/Qwen3-0.6B/grpo/config_demo.yaml --wandb_project open-r1 --run_name Qwen3-GRPO-0.6B 

# NOTE: need accelerate for colocated vLLM to work...
accelerate launch --config_file recipes/accelerate_configs/zero3.yaml --num-processes=1 src/open_r1/grpo.py --config recipes/Qwen3-0.6B/grpo/config_demo.yaml --wandb_project open-r1 --run_name Qwen3-GRPO-0.6B-debug

# TRAINING_PID=$!
# echo "Training process started with PID: $TRAINING_PID"

