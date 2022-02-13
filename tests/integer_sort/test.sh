integer_sort_type="random_seq"
frequencies="1.8GHz"
# frequencies="1.6GHz 1.8GHz"
configs="0x09 0x60 0x69 0xf0 0x0f 0xff"
sizes="10 100 1000 10000 20000 30000 40000 50000 60000 70000 80000 90000 100000 200000 300000 400000 500000 600000 700000 800000 900000 1000000"

header=$'array_type\tconfig\tfrequency\tarray_size\tprocesses_number\telapsed_time'
dir=benchmarkings/integer_sort

mix escript.build

for type in $integer_sort_type; do
    filedir=$dir/$type
    mkdir -p $filedir
    filename=$filedir/$(date +'%Y-%m-%d-%H-%M-%S').csv
    rm $filename
    echo "$header" >> $filename
    for config in $configs; do
        for freq in $frequencies; do
            freq_cmd="sudo cpufreq-set -c 4 -f $freq"
            echo $freq_cmd
            for size in $sizes; do
                for p in {1..8}; do
                    # for round in {1..5}; do
                    # cmd="taskset $config escript pbbs RadixSort 10 https://monography.s3.us-east-2.amazonaws.com/integer_sort/$type/$size.txt"
                    cmd="taskset $config escript pbbs RadixSort $p tests/integer_sort/$type/$size.txt"
                    echo $cmd
                    result=$($cmd)
                    echo $result
                    echo -e "$type\t$config\t$freq\t$size\t$p\t$result" >> $filename
                    # done
                done
            done
        done
    done
done