// create_chromo.cpp
// A program to generate the LAMMPS trajectory file for the chromatin-lamina
// simulation. The chromatin fibre is initialised as a random walk bead chain.

#include <iostream>
#include <iomanip>
#include <fstream>
#include <string>
#include <vector>
#include <random>
#include <cmath>
#include "data_reader.hpp"

using std::cout;
using std::endl;
using std::ifstream;
using std::ofstream;
using std::string;
using std::vector;

// Useful structures
struct Vec { 
  double x, y, z;
};

// Function declarations
vector<Vec>* createRandomWalk(int nbeads, double lx, double ly, double lz,
			      long seed);
void writeLAMMPSFile(const string& file, int ntypes, int beadLabel,
		     double lx, double ly, double lz,
		     const vector<Vec>& position, const vector<int>& type);

int main(int argc, char* argv[]) {

  if (argc != 10) {
    cout << "usage: create_chromo chromoLengthFile laminFile k9me3File chrNum "
	 << "lx ly lz seed lammpsFile" << endl;
    return 1;
  }

  // Read input arguments
  int argi {};
  string chromoLengthFile (argv[++argi]);
  string laminFile (argv[++argi]);
  string k9me3File (argv[++argi]);
  int chr = stoi(string(argv[++argi]), nullptr, 10);
  double lx = stod(string(argv[++argi]), nullptr);
  double ly = stod(string(argv[++argi]), nullptr);
  double lz = stod(string(argv[++argi]), nullptr);
  long seed = stol(string(argv[++argi]), nullptr, 10);
  string lammpsFile (argv[++argi]);

  const int numOfChromo {24}; // Including both sex chromosomes X and Y
  const int bpPerBead {10000}; // 10 kb resolution (i.e. 1 bead = 10 kb)
  const double buffer {5.0}; // Extra buffer from the boundary when generating
                             // the random walk polymer
  
  vector<long> chromoLength (numOfChromo);
  
  ifstream reader;
  reader.open(chromoLengthFile);
  if (!reader) {
    cout << "Problem with reading chromo length file!" << endl;
    return 1;
  }
  
  // Skip the header of the file
  string line;
  getline(reader, line);

  // Read the number of bp in each chromosome
  int index;
  long length;
  for (int i = 0; i < numOfChromo; i++) {
    reader >> index >> length;
    chromoLength[i] = length;
  }

  // Get the fraction score for each bead for the LaminB1 and K9me3 data
  vector<vector<double> >* fracScoreLamin;
  vector<vector<double> >* fracScoreK9me3;

  string prefix {};
  DataReader bedReader (bpPerBead, chromoLength);
  fracScoreLamin = bedReader.getFractionScore(prefix, laminFile, 0, 1, 2, 7);
  if (!fracScoreLamin) {
    cout << "Problem with reading the lamin file!" << endl;
    return 1;
  }
  fracScoreK9me3 = bedReader.getFractionScore(prefix, k9me3File, 0, 1, 2, 7);
  if (!fracScoreK9me3) {
    cout << "Problem with reading the K9me3 file!" << endl;
    return 1;
  }

  // Determine the total number of beads for the specific chromosome
  int nbeads = static_cast<int>
    (ceil(static_cast<double>(chromoLength[chr-1])/bpPerBead));

  // Generate a random walk conformation
  vector<Vec>* position = createRandomWalk(nbeads, lx-buffer, ly-buffer,
					   lz-buffer, seed);
  
  // Compute bead type
  const int ntypes = 4; // Number of bead types
                        // 1 = euchromatin (EC); 2 = heterochromatin (HC);
                        // 3 = lamina (NL)
  vector<int>* type = new vector<int>(nbeads);
  for (int i = 0; i < nbeads; i++) {
    if ((*fracScoreLamin)[chr-1][i] > 0.0 ||
	(*fracScoreK9me3)[chr-1][i] > 0.0) {
      (*type)[i] = 2;
    } else {
      (*type)[i] = 1;
    }
  }
  
  // Generate the LAMMPS input file
  writeLAMMPSFile(lammpsFile, ntypes, chr, lx, ly, lz, *position, *type);
  
  // Clean up resources
  delete position;
  delete type;
  delete fracScoreLamin;
  delete fracScoreK9me3;
}

// Function implementations
vector<Vec>* createRandomWalk(int nbeads, double lx, double ly, double lz,
			      long seed) {
  
  // Initialise the random number generator
  std::mt19937 mt(seed);
  std::uniform_real_distribution<double> rand(0, 1.0);

  // Create the position array
  vector<Vec>* position = new vector<Vec>(nbeads);
  
  double pi {M_PI};
  double x, y, z, r, costheta, sintheta, phi;
  
  // Set the initial bead position
  (*position)[0] = {0.0, 0.0, 0.0};

  for (int i = 1; i < nbeads; i++) {
    do {
      r = rand(mt);
      costheta = 1.0-2.0*r;
      sintheta = sqrt(1-costheta*costheta);
      r = rand(mt);
      phi = 2.0*pi*r;
      x = (*position)[i-1].x + sintheta * cos(phi);
      y = (*position)[i-1].y + sintheta * sin(phi);
      z = (*position)[i-1].z + costheta;
      // Check that the generated position is within the boundary
    } while (fabs(x) > lx/2.0 || fabs(y) > ly/2.0 || fabs(z) > lz/2.0);
    (*position)[i] = {x, y, z};
  }
  return position;
}

void writeLAMMPSFile(const string& lammpsFile, int ntypes,int beadLabel,
		     double lx, double ly, double lz,
		     const vector<Vec>& position, const vector<int>& type) {
  ofstream writer;
  writer.open(lammpsFile);
  if (!writer) {
    cout << "Problem with opening the LAMMPS output file!" << endl;
    return;
  }
  
  const int preci {15}; // Precision for printing floating point numbers

  // Write LAMMPS file header
  int nbeads = position.size();
  int nbonds = nbeads-1;
  int nangles = nbeads-2;
  string header =
    "LAMMPS data file from restart file: timestep = 0, \tprocs = 1";
  writer << header << endl;
  writer << endl;
  writer << nbeads << " atoms " << endl;
  writer << nbonds << " bonds " << endl;
  writer << nangles << " angles " << endl;
  writer << "\n";
  writer << ntypes << " atom types " << endl;
  writer << 1 << " bond types " << endl;
  writer << 1 << " angle types " << endl;
  writer << 0 << " ellipsoids " << endl;
  writer << "\n";
  writer << -lx/2.0 << " " << (lx-lx/2.0) << " xlo xhi" << endl;
  writer << -ly/2.0 << " " << (ly-ly/2.0) << " ylo yhi" << endl;
  writer << -lz/2.0 << " " << (lz-lz/2.0) << " zlo zhi" << endl;
  
  writer << "\nMasses\n" << endl;
  for (int i {1}; i <= ntypes; i++){
    writer << i << " " << 1 << endl;
  }
  writer << endl;
  
  // Write position
  writer << "\nAtoms # hybrid\n" << endl;
  writer.unsetf(std::ios_base::floatfield);
  for (int i = 0; i < nbeads; i++) {
    writer << i+1 << " " << type[i] << " ";
    writer << std::scientific;
    writer << std::setprecision(preci) << position[i].x << " "
	   << std::setprecision(preci) << position[i].y << " "
	   << std::setprecision(preci) << position[i].z << " ";
	writer << 0 << " "; // 	not ellipsoid   << " " << beadLabel 
    writer << 1 << " "; // arbitrary value
	writer << 1 << " "; // 	molecule ID  (using 1 instead of beadLabel)
    writer << 0 << " "; // charge
    writer.unsetf(std::ios_base::floatfield);
    // Write boundary count
    writer << 0 << " " << 0 << " " << 0 << endl;
  }
  writer << endl;
  
//   // Write velocity
//   writer << "\nVelocities\n" << endl;
//   writer.unsetf(std::ios_base::floatfield);
//   for (int i = 1; i <= nbeads; i++) {
//     writer << i << " ";
//     writer << std::scientific;
//     writer << std::setprecision(preci) << 0.0 << " "
// 	   << std::setprecision(preci) << 0.0 << " "
// 	   << std::setprecision(preci) << 0.0 << endl;
//     writer.unsetf(std::ios_base::floatfield);
//   }
//   writer << endl;

  // Write bond
  writer << "\nBonds\n" << endl;
  for (int i = 1; i <= nbonds; i++) {
    writer << i << " " << 1 << " " << i << " " << i+1 << endl;
  }
  writer << endl;

  // Write angle
  writer << "\nAngles\n" << endl;
  for (int i = 1; i <= nangles; i++) {
    writer << i << " " << 1 << " " << i << " " << i+1 << " " << i+2 << endl;
  }
  writer << endl;
  
  writer.close();
}
