// data_reader.hpp
// A class for reading genome data files (e.g. bed files) and finding the
// fractional amount of data signal in each bin at a specified resolution

#ifndef DATA_READER_HPP
#define DATA_READER_HPP

#include <string>
#include <vector>

class DataReader {

private:
  int numOfChromo; // Number of chromosomes
  int bpPerBin; // Resolution
  std::vector<int> chromoBinLength; // Number of bp in each chromosome

public:
  // Constructor
  DataReader(int bpPerBin, const std::vector<long>& chromoLength);

  // Find the amount of data signal in each bin for each chromosome
  std::vector<std::vector<double> >*
  getFractionScore(const std::string& chrPrefix, const std::string& file,
		   int chrCol, int startCol, int endCol, int totalCol);
};

#endif
