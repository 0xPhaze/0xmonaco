import os
import matplotlib.pyplot as plt
import numpy as np
import csv


def parse_file(csv_file):

    headers = []
    data = []

    # Read the csv file
    with open(csv_file, 'r') as f:
        reader = csv.reader(f)

        for i, row in enumerate(reader):
            if i == 0:
                headers = row
            else:
                data.append(row)

    # Create lists to store the data
    t_data = list(zip(*data))
    x_data, y_data = t_data[0], t_data[1:]

    x_data = np.array(x_data, dtype='int')
    y_data = np.array(y_data, dtype='int')

    # Process data (same x-values will be averaged)
    x_proc = []
    y_proc = []

    for x in np.unique(x_data):
        mask = x_data == x

        x_proc.append(x_data[mask].mean())
        y_proc.append(y_data[:, mask].mean(axis=1))

    x_proc = np.array(x_proc)
    y_proc = np.array(y_proc).transpose()

    return (headers[0], headers[1:]), (x_proc, y_proc)


files_stats = [
    # 'logs/prices.csv',
    # 'logs/sold.csv',
]

files_cars = [
    # 'logs/0x2e234DAe75C793f67A35089C9d99245E1C58470b.csv',
    # 'logs/0x5991A2dF15A8F6A256D3Ec51E99254Cd3fb576A9.csv',
    # 'logs/0xF62849F9A0B5Bf2913b396098F7c7019b51A820a.csv',
]

for file in os.listdir('logs'):
    if not file.endswith('.csv'):
        continue

    if file.startswith('0x'):
        files_cars.append('logs/' + file)
    else:
        files_stats.append('logs/' + file)


def plot(files):
    styles = ["-", "--", ":"]
    legend_lines = []
    legend1 = None

    all_headers = []
    all_data = []

    for csv_file in files:

        headers, data = parse_file(csv_file)

        all_headers.append(headers)
        all_data.append(data)

    is_cars = files[0].startswith('logs/0x')
    placings = None
    final_scores = None

    if is_cars:
        assert all([header[1][0] == 'y' for header in all_headers])
        final_scores = [data[1][0][-1] for data in all_data]
        final_scores_sorted = list(reversed(sorted(final_scores)))

        placings = [final_scores_sorted.index(y) + 1 for y in final_scores]

    def format_label(label, index):
        label = label.replace('logs/', '')
        label = label.replace('.csv', '')
        if (label.startswith('0x')):
            label = f'{label[:6]} #{placings[index]}: {final_scores[index]:0.0f}'
        return label

    legend_labels = [format_label(label, i) for i, label in enumerate(files)]
    legend_title = 'Cars' if legend_labels[0].startswith('0x') else None

    for i, _ in enumerate(all_headers):

        (x_label, y_label) = all_headers[i]
        (x_proc, y_proc) = all_data[i]

        color = None
        style_cycler = iter(styles)

        for t, y in zip(y_label, y_proc):
            line, = plt.plot(x_proc, y, next(style_cycler), label=t, c=color)

            if color is None:
                legend_lines.append(line)

            color = color or line.get_color()

        if i == 0:
            legend1 = plt.legend(loc='upper left')

        # plt.xlabel(x_label)

    plt.legend(legend_lines, legend_labels,
               title=legend_title, loc='upper right')
    plt.gca().add_artist(legend1)
    plt.yscale('log')


# Plot the data
plt.figure(figsize=(12, 10))

plt.subplot(2, 1, 1)
plot(files_cars)

plt.subplot(2, 1, 2)
plt.tight_layout()
plot(files_stats)

plt.savefig('logs/plot.png')
# plt.show()
