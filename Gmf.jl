using Printf

"Gamma and Plt mesh data"
struct Gmf
    " [nNodes,2 Float64] Node locations (X,Y)."
    nodes::Matrix{Float64}

    "[nNodes,3 Int32] Edge nodes numbers and boundary number."
    edges::Matrix{Int32}

    "[nSurfTrias,3 Int32] Node indices for triangular boundary surface faces."
    tri::Matrix{Int32}

    # "Internal constructor"
    # Gmf() = new()
end

# """
#     obj = Gmf(in::String)

# Construct from mesh file
# """
# function Gmf(filename::String)

#     # check extension
#     fileBase, fileExtension = splitext(filename)
#     if fileExtension != ".plt"
#         error("Mesh file shold have extension '.plt'")
#     end
#     obj = constructFromPltFile(filename);

#     return obj
# end

"""
    gmf::Gmf = constructFromPltFile(filename::String)

Construct Gmf from a .Plt file
"""
function constructFromPltFile(filename::String)
    # Construct from CBSFlow ascii file
    fid = open(filename,"r");
                
    # Process header
    getLine = readline(fid);
    splitLine = split(strip(getLine));  
    nTriangles = parse(Int32,splitLine[1]);
    nNodes = parse(Int32,splitLine[2]);
    nEdges = parse(Int32,splitLine[3]);

    # Read triangles
    tri = Array{Int32}(undef,nTriangles,3)
    for i = 1:nTriangles
        splitLine = split(strip(readline(fid)));
        tri[i,1] = parse(Int32,splitLine[2]);
        tri[i,2] = parse(Int32,splitLine[3]);
        tri[i,3] = parse(Int32,splitLine[4]);
    end
    
    # Read nodes
    nodes = Array{Float64}(undef,nNodes,2)
    for i = 1:nNodes
        splitLine = split(strip(readline(fid)));
        nodes[i,1] = parse(Float64,splitLine[2]);
        nodes[i,2] = parse(Float64,splitLine[3]);
    end

    # Read edges
    edges = Array{Int32}(undef,nEdges,3)
    for i = 1:nEdges
        splitLine = split(strip(readline(fid)));
        edges[i,1] = parse(Int32,splitLine[1]);
        edges[i,2] = parse(Int32,splitLine[2]);
        edges[i,3] = parse(Int32,splitLine[4]);
    end
    
    close(fid);

    return Gmf(nodes,edges,tri)
end
     
"""
    writeVTK(gmf::Gmf,,filename::String)

Write the mesh to a .vtk file. Format:
https://vtk.org/wp-content/uploads/2015/04/file-formats.pdf
"""
function writeVTK(gmf::Gmf,filename::String)
    fid = open(filename,"w");
    @printf(fid,"# vtk DataFile Version 3.0\n");
    @printf(fid,"My example\n");
    @printf(fid,"ASCII\n");

    nNodes = size(gmf.nodes,1);
    @printf(fid,"\nDATASET UNSTRUCTURED_GRID\n");
    @printf(fid,"POINTS %d float\n",nNodes);
    for i = 1:nNodes
        @printf(fid,"%f %f 0\n",gmf.nodes[i,1],gmf.nodes[i,2]);
    end

    nElements = size(gmf.tri,1);
    nCellData = 4*nElements;
    @printf(fid,"CELLS %d %d\n",nElements,nCellData);
    for i = 1:nElements
        @printf(fid,"3 %d %d %d\n",gmf.tri[i,1]-1,gmf.tri[i,2]-1,gmf.tri[i,3]-1);
    end

    @printf(fid,"CELL_TYPES %d\n",nElements);
    for i = 1:nElements
        @printf(fid,"%d\n",5);
    end

    close(fid);
end

filename = joinpath("ldc2d-re400","5000NUcav.plt");
gmf = constructFromPltFile(filename);
writeVTK(gmf,"test.vtk")

# filename = "test.vtk"