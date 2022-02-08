declare -a integer_sort_type=(
    "expt_seq"
    "random_seq"
)

size=0
mix escript.build

csv_output=$'array_type\tarray_size\tcpu_cores\telapsed_time'
# filename=benchmarkings/integer_sort/data_$(date +'%Y%m%d%H%M%S').csv
filename=benchmarkings/integer_sort/data.csv

rm $filename
echo "$csv_output" >> $filename

for type in "${integer_sort_type[@]}"; do
    for exp in {1..2}; do
        cores="0"
        for core in {0..7}; do
            if [ "$core" != "0" ]; then
                cores="$cores,$core"
            fi
            cores_number=$((core+1))
            for round in {1..5}; do
                size=$((10**exp))
                cmd="taskset -c $cores escript pbbs RadixSort 10 https://monography.s3.us-east-2.amazonaws.com/integer_sort/$type/$size.txt"
                echo $cmd
                result=$($cmd)
                echo $result
                echo -e "$type\t$size\t$cores_number\t$result" >> $filename
            done
        done
    done
done