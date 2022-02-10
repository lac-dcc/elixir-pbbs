integer_sort_type="expt_seq random_seq"
frequencies="1.6GHz 1.8GHz"
configs="0x09 0x60 0x69 0xf0 0x0f 0xff"

size=0
mix escript.build

header=$'array_type\tconfig\tfrequency\tarray_size\telapsed_time'
dir=benchmarkings/integer_sort

for type in $integer_sort_type; do
    for config in $configs; do
        for freq in $frequencies; do
            filedir=$dir/$type/$config/$freq
            mkdir -p $filedir
            filename=$filedir/$type-$config-$freq.csv
            rm $filename
            echo "$header" >> $filename
            freq_cmd="sudo cpufreq-set -c 4 -f $freq"
            echo $freq_cmd
            for exp in {1..6}; do
                size=$((10**exp))
                for round in {1..5}; do
                    # cmd="taskset $config escript pbbs RadixSort 10 https://monography.s3.us-east-2.amazonaws.com/integer_sort/$type/$size.txt"
                    cmd="taskset $config escript pbbs RadixSort 10 tests/integer_sort/$type/$size.txt"
                    echo $cmd
                    result=$($cmd)
                    echo $result
                    echo -e "$type\t$config\t$freq\t$size\t$result" >> $filename
                done
            done
        done
    done
done