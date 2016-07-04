################################################# FILE DESCRIPTION #########################################################

# This file contains tests for queries.

############################################################################################################################

for PM in subtypes(PropertyModule)
   for typ in [Any,TestType]
      @testset "Query tests for Graph{SparseMatrixAM,$PM}" begin

      end
   end
end
