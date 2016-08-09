################################################# FILE DESCRIPTION #########################################################

# This file contains methods, macros and operators aimed at providing the user a convenient UI over the REPL

################################################# IMPORT/EXPORT ############################################################

export
# Types
Node,
# Methods
parsequery, queryexec,
# Macros
@query

###
# DAG DEFINITIONS
###
include("query/dag.jl")


###
# RECURSIVE DESCENT PARSER FOR QUERIES
###
include("query/parse.jl")


###
# BOTTOM UP EXECUTION FOR DAG
###

include("query/exec.jl")

################################################# MACROS ####################################################################

# Macro for Pipe schematics
macro query(x)
   cache = Dict()
   dag = parsequery(cache, x)

   ks = collect(keys(cache))
   syms = collect(keys(cache))

   quote
      local cache = $(esc(cache))
      local ks    = $(esc(ks))

      ###
      # TODO: This is a runtime hack to translate input symbol
      # into graph. Need something smoother
      ###
      cache[ks[1]] = Dict("OBJ"=>$(esc(syms[1].gs)), "VDATA"=>Dict(), "EDATA"=>Dict())

      exec(cache, $(esc(dag)))
   end
end
