"Triangular element"
struct Tri2D
    nodeIDs::Vector{Int32} # [nTri,3 uint32] node numbers
    x::Vector{Float64} # [nTri,3 double] x node locations
    y::Vector{Float64} # [nTri,3 double] y node locations
    invJ::Matrix{Float64} # [2,2,nTri Matrix3D] inverse of Jacobian matrix (constant inside elements)
    area::Float64 # [:,:,nTri double] element area
    dNdX::Matrix{Float64} # Physical shape function derivatives - constant inside the element
end

"""
    Tri2D(gmf::Gmf)

Construct array of Tri2D elements from mesh data
"""
function Tri2D(gmf::Gmf)
    
    # Process node IDs
    nTri,mTri = size(gmf.tri);
    if nTri < 1; error("No elements"); end
    if mTri !=3; error("mTri~=3");     end
    
    # Shape function derivatives are constant inside the element
    dNXi = Matrix{Float64}(undef,2,3);
    dNXi[1,:] = [-1, 1, 0]; # dNdxi  = [-1, 1, 0];
    dNXi[2,:] = [-1, 0, 1]; # dNdeta = [-1, 0, 1];

    # Process elements
    detJinvJ = Array{Float64}(undef,2,2);
    tri2d = Array{Tri2D}(undef,nTri); # this doesn't have enough information to allocate memory
    for i = 1:nTri
        nodeIDs = gmf.tri[i,:];
        x = [ gmf.nodes[nodeIDs[1],1], gmf.nodes[nodeIDs[2],1], gmf.nodes[nodeIDs[3],1]];
        y = [ gmf.nodes[nodeIDs[1],2], gmf.nodes[nodeIDs[2],2], gmf.nodes[nodeIDs[3],2]];
        detJ = (x[2]-x[1])*(y[3]-y[1]) - (x[3]-x[1])*(y[2]-y[1]);
        detJinvJ[1,1] = y[3]-y[1];
        detJinvJ[1,2] = y[1]-y[2];
        detJinvJ[2,1] = x[1]-x[3];
        detJinvJ[2,2] = x[2]-x[1];
        invJ = (1.0/detJ)*detJinvJ;
        area = 0.5*detJ;
        dNdX = invJ*dNXi;

        tri2d[i] = Tri2D(nodeIDs,x,y,invJ,area,dNdX);
    end
    return tri2d;
end

# function [r,s,w3]=gaussPointsAndWeights()
#     # 3-Point Gauss integration points & weight factor
#     r = [2/3 1/6 1/6];
#     s = [1/6 1/6 2/3];
#     w3 = 1/3;
# end
# function [N1,N2,N3]=vectorShapeFunValsAtIntPoints(r,s)
#     # 2D vector shape function values at integration points
#     # shapeFunctions = @(r,s) [1-r-s, r, s];
#     N1 = [1-r(1)-s(1),           0, r(1),    0, s(1),   0   ;
#         0, 1-r(1)-s(1),    0, r(1),    0, s(1) ];
#     N2 = [1-r(2)-s(2),           0, r(2),    0, s(2),   0   ;
#         0, 1-r(2)-s(2),    0, r(2),    0, s(2) ];
#     N3 = [1-r(3)-s(3),           0, r(3),    0, s(3),   0   ;
#         0, 1-r(3)-s(3),    0, r(3),    0, s(3) ];
# end
# function [N1,N2,N3]=scalarShapeFunValsAtIntPoints(r,s)
#     # Scalar shape function values at integration points
#     # shapeFunctions = @(r,s) [1-r-s, r, s];
#     N1 = [1-r(1)-s(1), r(1), s(1)];
#     N2 = [1-r(2)-s(2), r(2), s(2)];
#     N3 = [1-r(3)-s(3), r(3), s(3)];
# end
