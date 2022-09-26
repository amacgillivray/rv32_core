
#include "stdafx.h"
// C++ program to pass function as a
// pointer to any function

#include <iostream>
#include <chrono>
#include <bits/stdc++.h>
using namespace std;

#define COLUMN 1000
#define ROW 1000
#define ITERATIONS 10

double calculateMean(double data[],int size) {
  double sum = 0.0, mean = 0.0;
  int i;

  for(i = 0; i < size; ++i) {
    sum += data[i];
  }

  mean = sum / size;

  return mean;
}

//calculate median
double calculateMedian(double arr[], int size){
   sort(arr, arr+size);
   if (size % 2 != 0)
      return (double)arr[size/2];
   return (double)(arr[(size-1)/2] + arr[size/2])/2.0;
}

double calculateSD(double data[],int size) {
  double sum = 0.0, mean, variance  = 0.0;
  int i;

  for(i = 0; i < size; ++i) {
    sum += data[i];
  }

  mean = sum / size;

  for(i = 0; i < size; ++i) {
    variance  += pow(data[i] - mean, 2);
  }
  variance =variance/size; 	
  return sqrt(variance );
}

//Matrix Addition
void AddTestMatrix(double **mat1,double **mat2,double **matR,int rows, int cols)
{
	 for(int i=0; i < rows; ++i)
    {
        for(int j=0; j < cols; ++j)
        {
            matR[i][j]=mat1[i][j]+mat2[i][j];
        }
    }
}
//Matrix Multiplication
void MultiplyTestMatrix(double **mat1,double **mat2,double **matR,int rows, int cols)
{
	for(int i = 0; i < rows; ++i)
     {
        for(int j = 0; j < cols; ++j)
        {
            for(int k = 0; k < cols; ++k)
            {
                matR[i][j] += mat1[i][k] * mat2[k][j];
            }
        }
     }
}

// Function that takes a pointer to the function and the iteration count
// to a function
bool invoke(int iterationCount,double **mat1,double **mat2,double **matR,int rows, int cols,void(*funcToCall)(double **,double **,double **, int, int))
{
	bool res =true;
	double *itTmAr = new double[iterationCount];
	for(int i=0;i<iterationCount;i++)
	{
		auto start = std::chrono::high_resolution_clock::now();
		funcToCall(mat1,mat2,matR,rows,cols);
		auto end = std::chrono::high_resolution_clock::now();
		auto elapsed = end - start;
		std::chrono::duration<double> time_span = std::chrono::duration_cast<std::chrono::duration<double>>( end - start);
		cout << "It took " << time_span.count() << " seconds";
        //cout << " for the iteration no "<<i << ": " << elapsed.count() << '\n';
		cout << " for the iteration no "<<i+1 << '\n';
		itTmAr[i]=time_span.count();
	}
		cout << " for the all "<<iterationCount<< " iterations : mean="<<calculateMean(itTmAr,iterationCount);
		cout << " median="<<calculateMedian(itTmAr,iterationCount)<<" stddev=" << calculateSD(itTmAr,iterationCount) << '\n';
	delete[] itTmAr;
	return res;
}

// Driver Code
int main()
{


	double** addarr = new double*[ROW];
    for(int i=0; i<ROW; i++)
    {
    	 addarr[i] = new double[COLUMN];
	}

	double** addarr2 = new double*[ROW];
    for(int i=0; i<ROW; i++)
    {
    	 addarr2[i] = new double[COLUMN];
	}

	double** sum = new double*[ROW];
    for(int i=0; i<ROW; i++)
    {
    	 sum[i] = new double[COLUMN];
	}
	///----------------------------------
	double** multarr = new double*[ROW];
    for(int i=0; i<ROW; i++)
    {
    	 multarr[i] = new double[COLUMN];
	}

	double** multarr2 = new double*[ROW];
    for(int i=0; i<ROW; i++)
    {
    	 multarr2[i] = new double[COLUMN];
	}

	double** product = new double*[ROW];
    for(int i=0; i<ROW; i++)
    {
    	 product[i] = new double[COLUMN];
	}
	///-------------------------------


	//fill the test matrix with random values
	for(int i=0; i < ROW; ++i)
    {
        for(int j=0; j < COLUMN; ++j)
        {
            addarr[i][j]=((double) rand() / RAND_MAX) * (100 - 1);
            addarr2[i][j]=((double) rand() / RAND_MAX) * (100 - 1);
            multarr[i][j]=((double) rand() / RAND_MAX) * (100 - 1);
            multarr2[i][j]=((double) rand() / RAND_MAX) * (100 - 1);
			product[i][j]=0;
        }
    }

	cout << "\nAddition of two test matrix "<<ITERATIONS<<" times\n";
	invoke(ITERATIONS,addarr,addarr2,sum,ROW,COLUMN, &AddTestMatrix);
	cout << "\nMultiplication of two test matrix "<<ITERATIONS<<" times\n";
	invoke(ITERATIONS,multarr,multarr2,product,ROW,COLUMN, &MultiplyTestMatrix);
	

	//-----------------------------------------
    //Free each sub-array (row)
	for(int i = 0; i< ROW; ++i) {
		delete[] addarr[i];  
    }
	delete[] addarr;  //Free the array of pointers

	//Free each sub-array (row)
	for(int i = 0; i< ROW; ++i) {
		delete[] addarr2[i];  
    }
	delete[] addarr2;  //Free the array of pointers

	//Free each sub-array (row)
	for(int i = 0; i< ROW; ++i) {
		delete[] multarr[i];  
    }
	delete[] multarr;  //Free the array of pointers

	//Free each sub-array (row)
	for(int i = 0; i< ROW; ++i) {
		delete[] multarr2[i];  
    }
	delete[] multarr2;  //Free the array of pointers

	//Free each sub-array (row)
	for(int i = 0; i< ROW; ++i) {
		delete[] sum[i];  
    }
	delete[] sum;  //Free the array of pointers

	//Free each sub-array (row)
	for(int i = 0; i< ROW; ++i) {
		delete[] product[i];  
    }
	delete[] product;  //Free the array of pointers


	return 0;
}


