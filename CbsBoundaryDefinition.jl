"CBS boundary definition"
struct CbsBoundaryDefinition
    "Boundary side ID number"
    flagList::Int32

    """
    Boundary type code. Options:\n
    500 - adiabatic with prescribed velocity\n
    501 - constant temperature with no-slip (T = 1)\n
    502 - constant temperature with no-slip(T = 0)\n
    503 - constant temperature (T = 0) prescribed velocity (u=1,v=0)\n
    504 - pressure boundary\n
    506 - velocity symmetry, no-flux energy\n
    507 - Backward Facing Step (Re=229) Parabolic Boundary (with v=0)\n
    """
    flagCode::Int32
end

"""
    CbsBoundaryDefinition(filename::String)

Contruct from .bco file.
"""
function CbsBoundaryDefinition(filename::String)
    # check extension
    fileBase, fileExtension = splitext(filename)
    if fileExtension != ".bco"
        error("Boundary definition file shold have extension '.bco'")
    end

    # open file
    fid = open(filename,"r");

    # read data
    fLine = readline(fid);
    nBoundaries = parse(Int32,strip(fLine));
    cbsBoundaryDefinition = Array{CbsBoundaryDefinition}(undef,nBoundaries)
    for i in 1:nBoundaries
        local fLine = split(strip(readline(fid)));
        local boundarySide = parse(Int32,strip(fLine[1]));
        local boundaryCode = parse(Int32,strip(fLine[2]));
        cbsBoundaryDefinition[i] = CbsBoundaryDefinition(boundarySide,boundaryCode);
    end

    # close file
    close(fid);

    return cbsBoundaryDefinition
end

# filename = joinpath("ldc2d-re400","5000NUcav.bco");
# cbsBoundaryDefinition = CbsBoundaryDefinition(filename);
# println(cbsBoundaryDefinition)