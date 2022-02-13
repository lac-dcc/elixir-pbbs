# comparison_sort_type="almost_sorted_seq expt_seq random_seq trigram_seq"
# comparison_sort_type="expt_seq random_seq"
comparison_sort_type="random_seq"
# frequencies="1.6GHz 1.8GHz"
frequencies="1.8GHz"
configs="0x09 0x60 0x69 0xf0 0x0f 0xff"
sizes="100000"
# sizes="10 100 1000 10000 20000 30000 40000 50000 60000 70000 80000 90000 100000"

header=$'array_type\tconfig\tfrequency\tarray_size\tprocess_limit\tlower_limit\telapsed_time'
dir=benchmarkings/comparison_sort

mix escript.build

for type in $comparison_sort_type; do
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
                lower_limit=1
                while : ; do
                    lower_limit=$((lower_limit*2))
                    if [ $lower_limit -gt $size ]; then
                        break
                    fi
                    for p in {1..8}; do
                        # for round in {1..5}; do
                        # cmd="taskset $config escript pbbs SampleSort 10 $lower_limit https://monography.s3.us-east-2.amazonaws.com/comparison_sort/$type/$size.txt"
                        cmd="taskset $config escript pbbs SampleSort $p $lower_limit tests/integer_sort/$type/$size.txt"
                        echo $cmd
                        result=$($cmd)
                        echo $result
                        echo -e "$type\t$config\t$freq\t$size\t$p\t$lower_limit\t$result" >> $filename
                        # done
                    done
                done
            done
        done
    done
done