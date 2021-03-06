#!/bin/bash

cate=test
vocab_dir=LDC2015-10000-60-5000
dev=0

model_dir=./workspace/LDC2015-0.1-0.01-1.0-integrated-0.1-0.4-0.5-2080Ti
base_dir=../data
train_test_data_dir=$base_dir/LDC2015
model_file=$model_dir/_step_550000.pt
reference=$train_test_data_dir/${cate}.sent
output_dir=$model_dir/translate-result
if [ ! -d "$output_dir" ]; then mkdir -p "$output_dir"; fi
hypothesis=$output_dir/${cate}.hyp
bleu_result=$model_dir/${cate}.log

if [ ! -d "$bleu_result" ]; then touch "$bleu_result"; fi
CUDA_VISIBLE_DEVICES=$dev python3  ./translate.py -model  $model_file \
                                                 -data ./workspace/$vocab_dir/LDC2015 \
                                                 -src        $train_test_data_dir/${cate}.concept.bpe \
                                                 -structure  $train_test_data_dir/${cate}.path  \
                                                 -output     $hypothesis \
                                                 -beam_size 5 \
                                                 -batch_size 20 \
                                                 -share_vocab  \
                                                 -gpu 0 \
                                                 -alpha 3.0 \
                                                 --integrated_node \
                                                 --integrated_edge \

python3 ../eval_utils/back_together.py -input $hypothesis -output $hypothesis
perl ../eval_utils/multi-bleu.perl $reference < $hypothesis | tee $bleu_result
