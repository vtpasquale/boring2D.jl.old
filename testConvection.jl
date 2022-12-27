include("Gmf.jl")
include("Tri2D.jl")
using SparseArrays

filename = joinpath("ldc2d-re400","5000NUcav.plt");
gmf = constructFromPltFile(filename);
tri2d = Tri2D(gmf);

# Conductivity
k = 1.0;

# Boundary temperatures (at four boundaries)
boundaryTemps = [100, 200, 300, 400];

# Number of elements and nodes
nElements = size(tri2d,1);
nNodes = size(gmf.nodes,1);

# One Temperature DOF per node
nDof = nNodes;

# Global matrices (update to sparse triplet assembly later)
K = spzeros(nDof,nDof);

# Assemble stiffness matrix
for i = 1:nElements
    dof = tri2d[i].nodeIDs;
    dNdX = tri2d[i].dNdX;
    k_e = transpose(dNdX)*k*dNdX*tri2d[i].area;
    K[dof,dof] = K[dof,dof] + k_e;
end

# Determine fixed and free dof
uniqueEdges = sort(unique(gmf.edges[:,3]));
edgeNodes = sort(unique(gmf.edges[:,1:2])); # Fixed dof
f = trues(nDof);
f[edgeNodes] .= false;
s = .!f

# Assemble boundary temperatures
u = zeros(nDof,1);
for i = 1:size(gmf.edges,1)
    # this will overwrite temperatures if nodes are on more than one edge
    u[gmf.edges[i,1:2]] .= boundaryTemps[gmf.edges[i,3]]; 
end

# Partition and solve
u[f] = K[f,f]\(-K[f,s]*u[s]);

# Write data to vtk format
vtkFilename = "test.vtk";
writeVTK(gmf,vtkFilename);
fid = open(vtkFilename,"a");
@printf(fid,"POINT_DATA %d\n",nNodes);
@printf(fid,"SCALARS Temp float\n");
@printf(fid,"LOOKUP_TABLE default\n");
for i = 1:nNodes
    @printf(fid,"%f\n",u[i]);
end
close(fid);