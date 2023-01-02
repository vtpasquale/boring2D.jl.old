#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jan  2 10:58:06 2023

@author: anthony
"""

import meshio
import numpy as np

m = meshio.read("plt2vtkNoEdges.vtu")

# assemble points
nPoints = np.size( m.points, 0 )
points  = np.zeros((nPoints,4))
points[:,0]   = np.linspace(0,nPoints-1,nPoints)
points[:,1:4] = m.points

# Index [bottom, right, top, left]
index = [points[:,2]==0, points[:,1]==1, points[:,2]==1, points[:,1]==0]
sortDim = [1,2,1,2];

# Create line elements on edges (Normals would need to be updated for natural boundary conditions)
edgeData = []
boundaryId = []
for i in range(0,4):
    edgePoints = points[index[i],:]
    sortedEdgeIndex = np.argsort(edgePoints[:,sortDim[i]])
    sortedEdgeIds = edgePoints[sortedEdgeIndex,0]
    nEdges = np.size(sortedEdgeIds)
    for e in range(0,nEdges-1):
        boundaryId.append(i+1)
        edgeData.append( [sortedEdgeIds[e],sortedEdgeIds[e+1]] )

# Append data to mesh object
edges = meshio.CellBlock("line", np.array(edgeData,dtype=int) )
m.cells.append(edges)

# Add boundary IDs as results data for
nTriData=len(m.cells[0]);
cell_data = {"bc": [np.zeros(nTriData,dtype=int), np.array(boundaryId,dtype=int)]}
m.cell_data = cell_data

# Write upated object to file
m.write("5000NUcav.vtu")