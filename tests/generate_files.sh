declare -a comparison_sort_type=(
    "almost_sorted_seq"
    "expt_seq"
    "random_seq"
    "trigram_seq"
)

declare -a integer_sort_type=(
    "expt_seq"
    "random_seq"
)

for i in {1..7}; do
    for type in "${comparison_sort_type[@]}"; do
        ./build/$type -t double $((10**$i)) comparison_sort/$type/$((10**$i)).txt
    done
    for type in "${integer_sort_type[@]}"; do
        ./build/$type -t int $((10**$i)) integer_sort/$type/$((10**$i)).txt
    done
done