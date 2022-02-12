comparison_sort_type="almost_sorted_seq expt_seq random_seq trigram_seq"
integer_sort_type="expt_seq random_seq"
sizes="10 100 1000 10000 20000 30000 40000 50000 60000 70000 80000 90000 100000 200000 300000 400000 500000 600000 700000 800000 900000 1000000"

for size in $sizes; do
    for type in $comparison_sort_type; do
        ./build/$type -t double $size comparison_sort/$type/$size.txt
    done
    for type in $integer_sort_type; do
        ./build/$type -t int $size integer_sort/$type/$size.txt
    done
done