function img = drawCell(embryo, t, z, c)

vcoords = embryo.getCellGraph(t, z).getCell(c).vertexCoords;
img = poly2mask(vcoords(:, 2), vcoords(:, 1), embryo.Ys, embryo.Xs);

%also check out roi2poly function?