integer_sort_type="expt_seq random_seq"
frequencies="1.6GHz 1.8GHz"
configs="0x09 0x60 0x69 0xf0 0x0f 0xff"

size=0
mix escript.build

csv_output=$'array_type\tarray_size\tfrequency\tconfig\telapsed_time'
filename=benchmarkings/integer_sort/data_$(date +'%Y-%m-%d').csv

rm -f $filename
echo "$csv_output" >> $filename

for type in $integer_sort_type; do
    for exp in {1..6}; do
        for freq in $frequencies; do
            freq_cmd="sudo cpufreq-set -c 4 -f $freq"
            echo $freq_cmd
            for config in $configs; do
                for round in {1..5}; do
                    size=$((10**exp))
                    cmd="taskset $config escript pbbs RadixSort 10 https://monography.s3.us-east-2.amazonaws.com/integer_sort/$type/$size.txt"
                    echo $cmd
                    result=$($cmd)
                    echo $result
                    echo -e "$type\t$size\t$freq\t$config\t$result" >> $filename
                done
            done
        done
    done
done