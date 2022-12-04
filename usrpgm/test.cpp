#include <iostream>
using namespace std;

int main() 
{
    int b=1;
    int c=2;
    for (int i = 0; i <= 10; i=i+2) 
    {
        cout << i+b << "\n";
        cout << i-b << "\n";
        cout << i*c << "\n";
        cout << i/c << "\n";
    }  
    b = 1000;
    c = 1456;
    cout << c+b << "\n";
    cout << c-b << "\n";
    cout << c*b << "\n";
    cout << c/b << "\n";

return 0;
}
