import numpy as np

# input
forest: np.ndarray = np.genfromtxt("input", dtype=int, delimiter=1)

# array to mark scenic scores
scores: np.ndarray = np.zeros_like(forest)

# func to calculate viewing distance for a tree
def max_view(tree: int, view: np.ndarray):
    view_limits = np.argwhere(view >= tree)
    if len(view) > 0:
        if len(view_limits) > 0:
            # there is a higher tree
            return view_limits[0][0] + 1
        else:
            # all trees are lower
            return len(view)
    else:
        # we're at an edge
        return 0

# check tree scores
for (x, y), e in np.ndenumerate(forest):
    sl = max_view(e, np.flip(forest[x, :y])) # score from left
    st = max_view(e, np.flip(forest[:x, y])) # score from top
    sr = max_view(e, forest[x, y + 1:])      # score from right
    sb = max_view(e, forest[x + 1:, y])      # score from bottom

    scores[x, y] = sl * st * sr * sb

# print output
print(np.max(scores))
