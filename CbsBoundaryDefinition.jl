# Struct for reading and storing CBS boundary definition (.bco file extension)
#
#     Boundary Condition File
#     -------------------------
#     The 1st line defines how many boundary side types are present in the mesh (NFLAG). Following this will then be NFLAG
#     entries in the FLAG_LIST array. This array replaces boundary side numbers in the PLT file with boundary flag codes.
#     This procedure is to avoid regenerating the mesh each time you change the boundary conditions. Currently, The available
#     flag codes are:
#     
#     !     500 - adiabatic with prescribed velocity
#     !     501 - constant temperature with no-slip (T = 1)
#     !     502 - constant temperature with no-slip(T = 0)
#     !     503 - constant temperature (T = 0) prescribed velocity (u=1,v=0)
#     !     504 - pressure boundary
#     !     506 - velocity symmetry, no-flux energy
#     !     507 - Backward Facing Step (Re=229) Parabolic Boundary (with v=0)
    
struct CbsBoundaryDefinition
    flagList::Int32 # boundary side number in the mesh file
    flagCode::Int32 # boundary code
end

# Default constructor
#
#
# function CbsBoundaryDefinition(Int32::flagList,Int32::flagCode)


# Construct from file
# 
# filename = joinpath("ldc2d-re400","5000NUcav.bco");
#
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