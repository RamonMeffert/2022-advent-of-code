import numpy as np

# input
forest: np.ndarray = np.genfromtxt("input", dtype=int, delimiter=1)

# array to mark visible trees
visible: np.ndarray = np.zeros_like(forest)

# edges are always visible
visible[0, :] = 1
visible[:, 0] = 1
visible[-1, :] = 1
visible[:, -1] = 1

# check tree visibility
for (_x, _y), e in np.ndenumerate(forest[1:-1, 1:-1]):
    x = _x + 1
    y = _y + 1
    hl = np.max(forest[x, :y]) # highest from left
    ht = np.max(forest[:x, y]) # highest from top
    hr = np.max(forest[x, y + 1:]) # highest from right
    hb = np.max(forest[x + 1:, y]) # highest from bottom

    visible[x, y] = visible[x, y] or np.any([ht, hl, hb, hr] < e)

# print output
print(np.sum(visible))
