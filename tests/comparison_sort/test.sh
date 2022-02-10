# comparison_sort_type="almost_sorted_seq expt_seq random_seq trigram_seq"
comparison_sort_type="expt_seq random_seq"
frequencies="1.6GHz 1.8GHz"
configs="0x09 0x60 0x69 0xf0 0x0f 0xff"

size=0
mix escript.build

header=$'array_type\tconfig\tfrequency\tarray_size\tlower_limit\telapsed_time'
dir=benchmarkings/comparison_sort

for type in $comparison_sort_type; do
    for config in $configs; do
        for freq in $frequencies; do
            filedir=$dir/$type/$config/$freq
            mkdir -p $filedir
            filename=$filedir/$type-$config-$freq.csv
            rm $filename
            echo "$header" >> $filename
            freq_cmd="sudo cpufreq-set -c 4 -f $freq"
            echo $freq_cmd
            for exp in {1..5}; do
                size=$((10**exp))
                lower_limit=1
                if [ $size = 1000000 ]; then
                    lower_limit=$((2**14))
                fi
                while : ; do
                    lower_limit=$((lower_limit*2))
                    if [ $lower_limit -gt $size ]; then
                        break
                    fi
                    for round in {1..5}; do
                        # cmd="taskset $config escript pbbs SampleSort 10 $lower_limit https://monography.s3.us-east-2.amazonaws.com/comparison_sort/$type/$size.txt"
                        cmd="taskset $config escript pbbs SampleSort 10 $lower_limit tests/integer_sort/$type/$size.txt"
                        echo $cmd
                        result=$($cmd)
                        echo $result
                        echo -e "$type\t$config\t$freq\t$size\t$lower_limit\t$result" >> $filename
                    done
                done
            done
        done
    done
done