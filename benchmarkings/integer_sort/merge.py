import csv


def get_lines_from_file(filename):
    with open(filename, 'r') as file:
        data = file.read()
        return data.split("\n")


def cast_to_int(list):
    return [int(i) for i in list]


def cast_to_array(string):
    return string.split("\t")


filenames = ["50-mais-alpha_A549.csv", "50-mais-alpha_Calu.csv", "50-mais-alpha_H460.csv", "50-mais-alpha_H1299.csv", "50-menos-alpha_A549.csv", "50-menos-alpha_Calu.csv",
             "50-menos-alpha_H460.csv", "50-menos-alpha_H1299.csv", "probabilidade-alpha_A549.csv", "probabilidade-alpha_Calu.csv", "probabilidade-alpha_H460.csv", "probabilidade-alpha_H1299.csv"]

filename = "data.csv"

header = ["array_type", "config", "frequency", "array_size", "elapsed_time"]
data_lines = [cast_to_array(line) for line in get_lines_from_file(filename)]
data_lines = data_lines[1:]

rows = []

for i in range(0, len(data_lines), 5):
    sum = 0
    for j in range(i, i+5, 1):
        sum = float(data_lines[j][4]) + sum
    new_row = data_lines[i]
    new_row[4] = sum/5
    rows.append(new_row)

with open("data_processed.csv", 'w', newline='') as csvfile:
    csvwriter = csv.writer(csvfile, delimiter="\t")
    csvwriter.writerow(header)
    csvwriter.writerows(rows)
