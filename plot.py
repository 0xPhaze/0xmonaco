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


def plot(files, is_cars):
    styles = ["-", "--", ":"]
    legend_lines = []
    legend1 = None

    all_headers = []
    all_data = []

    for csv_file in files:

        headers, data = parse_file(csv_file)

        all_headers.append(headers)
        all_data.append(data)

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
        label = label.replace('Cost', '')
        label = label.split('/')[-1].split('_')[-1]
        if index is not None and is_cars:
            # placing_label = ['W', ' ', 'L'][placings[index] - 1]
            placing_label = [' ', ' ', ' '][placings[index] - 1]
            label = f'{label}: {final_scores[index]:0.0f} {placing_label}'
            # label = label.replace('_', ' ')
        return label

    legend_labels = [format_label(label, i) for i, label in enumerate(files)]
    legend_title = 'Cars' if is_cars else None

    for i, _ in enumerate(all_headers):

        (x_label, y_label) = all_headers[i]
        (x_proc, y_proc) = all_data[i]

        color = None
        style_cycler = iter(styles)

        for t, y in zip(y_label, y_proc):
            line, = plt.plot(x_proc, y, next(style_cycler),
                             label=format_label(t, None), c=color)

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

    # max_y = max([max(line.get_ydata()[-50:]) for line in plt.gca().lines])
    # plt.ylim([0, max_y])


def parse_logs(dir):
    files_cars = sorted([
        f'{dir}/{file}' for file in os.listdir(dir) if file[0].isdigit() and file.endswith('.csv')
    ])

    files_stats = [
        f'{dir}/{file}' for file in os.listdir(dir) if not file[0].isdigit() and file.endswith('.csv')
    ]

    assert len(files_cars) == 3, "invalid number of cars"

    # print('files_stats', files_stats)
    # print('files_cars', files_cars)

    # Plot the data
    plt.figure(figsize=(12, 10))

    plt.subplot(2, 1, 1)
    plot(files_cars, True)

    plt.subplot(2, 1, 2)
    plt.tight_layout()
    plot(files_stats, False)

    plt.savefig(f'{dir}/plot.png')
    # plt.show()


if __name__ == '__main__':
    root = 'logs'

    all_dirs = [
        f'{root}/{dir}' for dir in os.listdir(root) if os.path.isdir(f'{root}/{dir}')]

    for dir in all_dirs:
        parse_logs(dir)
