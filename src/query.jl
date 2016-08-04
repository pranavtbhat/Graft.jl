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

# include("query/exec.jl")

################################################# MACROS ####################################################################

macro query(x)
   x = Expr(:quote, x)
   quote
      parsequery($(esc(x)))
   end
end
