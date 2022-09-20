#include <iostream>
#include <ctime>
#include <cmath>
#define COLUMN 1000
#define ROW 1000
using namespace std;

int main()
{
    srand(time(NULL));
    double addarr[ROW][COLUMN];
    double addarr2[ROW][COLUMN];
    double multarr[ROW][COLUMN];
    double multarr2[ROW][COLUMN];
    double sum[ROW][COLUMN];
    double product[ROW][COLUMN];
    for(int i=0; i < ROW; ++i)
    {
        for(int j=0; j < COLUMN; ++j)
        {
            addarr[i][j]=((double) rand() / RAND_MAX) * (100 - 1);
            addarr2[i][j]=((double) rand() / RAND_MAX) * (100 - 1);
            multarr[i][j]=((double) rand() / RAND_MAX) * (100 - 1);
            multarr2[i][j]==((double) rand() / RAND_MAX) * (100 - 1);
        }
    }
    //addition
    clock_t time_add=clock();
    for(int i=0; i < ROW; ++i)
    {
        for(int j=0; j < COLUMN; ++j)
        {
            sum[i][j]=addarr[i][j]+addarr2[i][j];
        }
    }
    time_add=clock()-time_add;
    cout << "Matrix Addition Time:" << time_add << "\n";
    //multiplication
    clock_t time_mult=clock();
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
    time_mult=clock()-time_mult;
    cout << "Matrix Multiplication Time:" << time_mult << "\n";
}
