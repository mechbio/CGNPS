
CXX := g++
CXXFLAGS := -Wall -Wshadow -O3 -std=c++11

INC :=
LDFLAGS := -lm 

PRG_SUFFIX =

SDIR := ./src/
ODIR := ./bin/
EDIR := ./

SRC := data_reader.cpp
OBJ := $(patsubst $(SDIR)/%.cpp, $(ODIR)/%.o, $(SDIR)/$(SRC))
PRG_SRC := create_chromo.cpp
PRG_OBJ := $(patsubst $(SDIR)/%.cpp, $(ODIR)/%.o, $(SDIR)/$(PRG_SRC))
PRG := $(patsubst %.cpp, $(EDIR)/%$(PRG_SUFFIX), $(PRG_SRC))

all : $(OBJ) $(PRG_OBJ) $(PRG)

$(ODIR)/%.o : $(SDIR)/%.cpp $(SDIR)/%.hpp
	mkdir -p $(ODIR)
	$(CXX) $(CXXFLAGS) $(INC) -o $@ -c $<

$(ODIR)/%.o : $(SDIR)/%.cpp
	mkdir -p $(ODIR)
	$(CXX) $(CXXFLAGS) $(INC) -o $@ -c $<

$(PRG) : $(OBJ) $(OBJ) $(PRG_OBJ)
	mkdir -p $(EDIR)
	$(CXX) $(LDFLAGS) $^ -o $@

.PHONY : clean
clean :
	rm -rf $(OBJ) $(PRG_OBJ) $(PRG) $(ODIR)
