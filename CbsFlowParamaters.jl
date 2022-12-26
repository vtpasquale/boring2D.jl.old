"CBS flow parameters from .par file."
mutable struct CbsFlowParameters
    # Line 2
    restart::Bool
    
    # Line 4
    energyCalculation::Bool
    
    # Line6
    Ux::Float64 # free stream value
    Uy::Float64 # free stream value
    P::Float64 # free stream value
    T::Float64 # free stream value
    
    # Line 8
    ntime::Int32 #  max number of pseudo time steps per real time step
    beta_opt::Bool #  controls whether a constant beta (EPSILON) is applied throughout the domain, or locally varying
    epsilon::Float64 # small constant to avoid zero beta
    dtfixed::Int32 # fix local time step flag: 1 = ON, 0 = local, -1 = Global minimum of local values
    dtfix::Float64 # fixed local time step size
    iwrite::Float64
    
    # Line 10
    nRealTimesteps::Float64
    realTimestepSize::Float64
    
    # Line 12
    csafm::Float64 # time step safety factor
    theta1::Float64 # time step parameter
    
    # Line 14
    Re::Float64 # Reynolds Number
    Pr::Float64 # Prandtl Number
    Ra::Float64 # Rayleigh Number
    Ri::Float64 # Richardson Number
    
    # Line 16
    convectionType::Int32 # (1 - Natural, 0 - Mixed/Forced)
    
    # Line 18 - steady state tolerances
    velocityFlag::Bool # (0 - OFF, 1 - ON)
    velocityTol::Float64 # tolerance
    pressureFlag::Bool # (0 - OFF, 1 - ON)
    pressureTol::Float64 # tolerance
    energyFlag::Bool # (0 - OFF, 1 - ON)
    energyTol::Float64 # tolerance
    
    # Line 20 - output control
    paraviewFlag::Bool # (0 - OFF, 1 - ON)
    tecplotFlag::Bool # (0 - OFF, 1 - ON)
    localNusseltFlag::Bool # (0 - OFF, 1 - ON)
    boundaryNusseltFlag::Int32 # Flag of Nusselt Calc Boundary ("Flag" usage is poor)
    
    # Line 22 - rumtime conrol updates
    runTimeControl::Bool # (0 - OFF, 1 - ON)

    # constructors
    CbsFlowParameters() = new()

end

"""
    CbsFlowParameters(filename::String)

Contruct from .par file.
"""
function CbsFlowParameters(filename::String)

    # check extension
    fileBase, fileExtension = splitext(filename)
    if fileExtension != ".par"
        error("Paramaters definition file shold have extension '.par'")
    end

    # Construct from ascii file
    fid = open(filename,"r");

    obj = CbsFlowParameters()
                
    skipLine = readline(fid);
    obj.restart = parse(Bool,strip(readline(fid))); 
    
    skipLine = readline(fid);
    obj.energyCalculation = parse(Bool,strip(readline(fid))); 
    
    skipLine = readline(fid);
    getLine = readline(fid);
    splitLine = split(strip(replace(getLine,"d"=>"E")));  
    obj.Ux = parse(Float64,splitLine[1]);
    obj.Uy = parse(Float64,splitLine[2]); 
    obj.P  = parse(Float64,splitLine[3]); 
    obj.T  = parse(Float64,splitLine[4]); 
    
    skipLine = readline(fid);
    getLine = readline(fid);
    splitLine = split(strip(replace(getLine,"d"=>"E")));
    obj.ntime = parse(Int32,splitLine[1]);
    obj.beta_opt = parse(Bool,splitLine[2]);
    obj.epsilon = parse(Float64,splitLine[3]);
    obj.dtfixed = parse(Int32,splitLine[4]);
    obj.dtfix = parse(Float64,splitLine[5]);
    obj.iwrite = parse(Float64,splitLine[6]);
    
    skipLine = readline(fid);
    getLine = readline(fid);
    splitLine = split(strip(replace(getLine,"d"=>"E")));  
    obj.nRealTimesteps = parse(Float64,splitLine[1]);
    obj.realTimestepSize = parse(Float64,splitLine[2]);

    skipLine = readline(fid);
    getLine = readline(fid);
    splitLine = split(strip(replace(getLine,"d"=>"E")));  
    obj.csafm = parse(Float64,splitLine[1]);
    obj.theta1 = parse(Float64,splitLine[2]);
    
    skipLine = readline(fid);
    getLine = readline(fid);
    splitLine = split(strip(replace(getLine,"d"=>"E")));  
    obj.Re = parse(Float64,splitLine[1]);
    obj.Pr = parse(Float64,splitLine[2]);
    obj.Ra = parse(Float64,splitLine[3]);
    obj.Ri = parse(Float64,splitLine[4]);
    
    skipLine = readline(fid);
    obj.convectionType = parse(Int32,strip(readline(fid))); 
    
    skipLine = readline(fid);
    getLine = readline(fid);
    splitLine = split(strip(replace(getLine,"d"=>"E")));  
    obj.velocityFlag  = parse(Bool,splitLine[1]);
    obj.velocityTol   = parse(Float64,splitLine[2]);
    obj.pressureFlag  = parse(Bool,splitLine[3]);
    obj.pressureTol   = parse(Float64,splitLine[4]);
    obj.energyFlag    = parse(Bool,splitLine[5]);
    obj.energyTol     = parse(Float64,splitLine[6]);
    
    skipLine = readline(fid);
    getLine = readline(fid);
    splitLine = split(strip(replace(getLine,"d"=>"E")));  
    obj.paraviewFlag        = parse(Bool,splitLine[1]);
    obj.tecplotFlag         = parse(Bool,splitLine[2]);
    obj.localNusseltFlag    = parse(Bool,splitLine[3]);
    obj.boundaryNusseltFlag = parse(Int32,splitLine[4]);
    
    skipLine = readline(fid);
    obj.runTimeControl = parse(Bool,strip(readline(fid))); 
    
    close(fid);

    return obj
end

# filename = joinpath("ldc2d-re400","5000NUcav.par");
# CbsFlowParameters = CbsFlowParameters(filename);
# println(CbsFlowParameters)