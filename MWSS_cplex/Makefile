CXX = g++ 
CXXFLAGS = -c -O3 -DNDEBUG -std=c++0x -Wall -ldl -pipe -DIL_STD -I/trinity/shared/apps/cv-standard/ibm/ILOG/CPLEX_Studio1210/cplex/include -I/trinity/shared/apps/cv-standard/ibm/ILOG/CPLEX_Studio1210/concert/include
LFFLAGS = -L/trinity/shared/apps/cv-standard/ibm/ILOG/CPLEX_Studio1210/concert/lib/x86-64_linux/static_pic/ -L/trinity/shared/apps/cv-standard/ibm/ILOG/CPLEX_Studio1210/cplex/lib/x86-64_linux/static_pic/ -lilocplex -lconcert -lcplex -lm -lpthread -ldl

SRC_REP = src

SRC = $(wildcard $(SRC_REP)/*.cpp)

OBJ_REP = obj

OBJ = $(addprefix $(OBJ_REP)/,$(notdir $(patsubst %.cpp, %.o, $(SRC))))

print-%  : ; @echo $* = $($*)

DEP := $(OBJ:.o=.d)


cplex: $(OBJ) 
	$(CXX) $^ -o cplex $(LFFLAGS)
	rm -rf obj


clean:
	rm -rf obj
	rm -f core	
	rm -f cplex

$(OBJ_REP)/%.o: $(SRC_REP)/%.cpp
	@mkdir -p $(@D)
	$(CXX) $(INCLUDE) $(CXXFLAGS) $< -o $@

-include $(DEP)
