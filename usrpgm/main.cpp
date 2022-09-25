#include <iostream>
#include <chrono>
#include <cmath>
#include <iostream>
#include <random>
#define COLUMN 100
#define ROW 100
using namespace std;

void add()
{
    double addarr[ROW][COLUMN];
    double addarr2[ROW][COLUMN];
    double sum[ROW][COLUMN];
    for(int i=0; i < ROW; ++i)
    {
        for(int j=0; j < COLUMN; ++j)
        {
            addarr[i][j]=((double) rand() / RAND_MAX) * (100 - 1);
            addarr2[i][j]=((double) rand() / RAND_MAX) * (100 - 1);
        }
    }
    //addition
    for(int i=0; i < ROW; ++i)
    {
        for(int j=0; j < COLUMN; ++j)
        {
            sum[i][j]=addarr[i][j]+addarr2[i][j];
        }
    }
}
void mult()
{
    double multarr[ROW][COLUMN];
    double multarr2[ROW][COLUMN];
    double product[ROW][COLUMN];
    for(int i=0; i < ROW; ++i)
    {
        for(int j=0; j < COLUMN; ++j)
        {
            multarr[i][j]=((double) rand() / RAND_MAX) * (100 - 1);
            multarr2[i][j]=((double) rand() / RAND_MAX) * (100 - 1);
        }
    }
    for(int i = 0; i < ROW; ++i)
    {
        for(int j = 0; j < COLUMN; ++j)
        {
            for(int k = 0; k < COLUMN; ++k)
            {
                product[i][j] += multarr[i][k] * multarr2[k][j];
            }
        }
    }
}
int main()
{
int repititions;
char func;
cout << "Enter function(a/m): \n";
cin >> func; 
cout << "Enter repititions: \n";
cin >> repititions;
    double results[repititions];
    if(func == 'a')
    {
        cout << "Matrix Addition(" << repititions << " repititions): \n";
        cout << "___________________________\n";
        for(int i=0; i < repititions; i++)
        {
            auto begin = chrono::steady_clock::now();
            add();
            auto end = chrono::steady_clock::now();
            results[i] =chrono::duration_cast<chrono::microseconds>(end-begin).count();
            cout << results[i] << "\n";
        }
        cout << "\n\n\n";
        double sumresults =0;
        double mean=0;
        double std=0;
        double median=0;
        for(int i=0; i < repititions; i++)
        {
            sumresults+=results[i];
        }
        mean=sumresults/repititions;
        for(int i=0; i < repititions; i++)
        {
            std+=pow(results[i]-mean, 2);
        }
	std=std/repititions;
	std=sqrt(std);
        for(int i=0; i < repititions-1; i++)
        {
                for(int j=0; j < repititions-i-1; j++)
                {
                    if(results[j] > results[j+1])
                    {
                        swap(results[j], results[j+1]);
                    }
                }
        }
        if(repititions%2 == 1)
        {
            median = results[repititions/2];
        }
        else
        {
            median = (results[repititions/2]+results[(repititions/2)+1])/2;
        }
        cout << "MEAN: " << mean << "\n";
        cout << "MEDIAN: " << median << "\n";
        cout << "STANDARD DEVIATION: " << std << "\n";
    }
    else if(func == 'm')
    {
        cout << "Matrix Multiplication(" << repititions << " repititions): \n";
        cout << "___________________________\n";
        for(int i=0; i < repititions; i++)
        {
            auto begin = chrono::steady_clock::now();
            mult();
            auto end = chrono::steady_clock::now();
            results[i] =chrono::duration_cast<chrono::microseconds>(end-begin).count();
            cout << results[i] << "\n";
        }
        cout << "\n\n\n";
        double sumresults =0;
        double mean=0;
        double std=0;
        double median=0;
        for(int i=0; i < repititions; i++)
        {
            sumresults=sumresults+results[i];
        }
        mean=sumresults/repititions;
        for(int i=0; i < repititions; i++)
        {
            std+=pow(results[i]-mean, 2);
        }
	std=std/repititions;
        std=sqrt(std);
        for(int i=0; i < repititions-1; i++)
        {
                for(int j=0; j < repititions-i-1; j++)
                {
                    if(results[j] > results[j+1])
                    {
                        swap(results[j], results[j+1]);
                    }
                }
        }
        if(repititions%2 == 1)
        {
            median = results[repititions/2];
        }
        else
        {
            median = (results[repititions/2]+results[(repititions/2)+1])/2;
        }
        cout << "MEAN: " << mean << "\n";
        cout << "MEDIAN: " << median << "\n";
        cout << "STANDARD DEVIATION: " << std << "\n";
    }
    else
    {
        cout << "Incorrect Function!\n";
    }
}
