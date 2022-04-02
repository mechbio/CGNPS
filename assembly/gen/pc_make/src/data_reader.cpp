// data_reader.cpp

#include <iostream>
#include <string>
#include <vector>
#include <fstream>
#include <sstream>
#include <exception>
#include <cmath>
#include "data_reader.hpp"

using std::cout;
using std::endl;
using std::string;
using std::vector;
using std::ifstream;
using std::istringstream;

DataReader::DataReader(int res, const vector<long>& chrLen) {
  numOfChromo = chrLen.size();
  bpPerBin = res;
  // Find and store the number of bins for each chromosome
  chromoBinLength = vector<int>(numOfChromo);
  for (int i = 0; i < numOfChromo; i++) {
    chromoBinLength[i] = static_cast<int>
      (ceil(static_cast<double>(chrLen[i])/bpPerBin));
  }
}

vector<vector<double> >*
DataReader::getFractionScore(const string& chrPrefix, const string& file,
			     int chrCol, int startCol,int endCol,
			     int totalCol) {
  ifstream reader;
  reader.open(file);
  if (!reader) {
    cout << "Problem with reading the data file!" << endl;
    throw std::exception();
  }

  // Create the array for storing the fraction score
  vector<vector<double> >*fracData = new vector<vector<double> >();
  for (int i = 0; i < numOfChromo; i++) {
    fracData->push_back(vector<double>(chromoBinLength[i], 0.0));
  }
  
  string line, token;
  long start = -1;
  long end = -1;
  int chromo = -1;
  int startBin, endBin;
  double frac;
  double resolution = static_cast<double>(bpPerBin);
  istringstream iss;
  
  while (getline(reader,line)) {
    // Skip empty lines and comments
    if (line.size() == 0 || line[0] == '#') continue;
    iss.clear();
    iss.str(line);
    for (int j = 0; j < totalCol; j++) {
      iss >> token;
      if (j == chrCol) {
	// Remove prefix from chromosome identifier
	token.erase(0, chrPrefix.length());
	// Convert the sex chromosomes identifiers
	if (token == "X") {
	  chromo = numOfChromo-2;
	} else if (token == "Y") {
	  chromo = numOfChromo-1;
	} else {
	  chromo = stoi(token, nullptr, 10)-1;
	}
      } else if (j == startCol) {
	start = stol(token, nullptr, 10);
      } else if (j == endCol) {
	end = stol(token, nullptr, 10);
      }
    }

    startBin = start/resolution;
    endBin = end/resolution;

    // For signal that is within the same bin
    if (startBin == endBin) {
      frac = (end-start)/resolution;
      (*fracData)[chromo][startBin] += frac;
      if ((*fracData)[chromo][startBin] > 1.0)
	(*fracData)[chromo][startBin] = 1.0;
      
    } else { // For signal that spreads over multiple bins 
      // Signal in the start bin
      frac = 1.0-(start/resolution-startBin);
      (*fracData)[chromo][startBin] += frac;
      if ((*fracData)[chromo][startBin] > 1.0)
	(*fracData)[chromo][startBin] = 1.0;
      
      // Signal in the end bin
      frac = end/resolution-endBin;
      (*fracData)[chromo][endBin] += frac;
      if ((*fracData)[chromo][endBin] > 1.0)
	(*fracData)[chromo][endBin] = 1.0;
      
      // Signal eleswhere
      for (int i = startBin+1; i < endBin; i++) {
	(*fracData)[chromo][i] = 1.0;
      }
    }
  }
  reader.close();
  return fracData;
}
