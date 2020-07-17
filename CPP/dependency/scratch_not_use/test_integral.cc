#include <iostream>
#include"integral/integral.h"

using namespace std;

double fun(double);

int main()
{
   integral caculate;
   double(*f)(double);
   double a = 0;        //积分上限
   double b = 10;        //积分下限
   double c = 0.01;        //精度
   double p;
   double p(double);
   auto A = caculate.monteCarloDefiniteIntegral(p, a, b, c);
   double B = caculate.definiteIntegral(p, a, b, c);
   cout << A.value << endl;
   cout << A.error << endl;
   cout << B << endl;

   system("pause");
   return 0;
}

double fun(double x)
{
   const double pi = 3.1415926;
   double y;
   y = sin(x);
   //y = cos(x);
   //y = x * x;
   //y = 2.0*sqrt(x) / ((x + 1.0)*(x + 1.0));
   //y = 0.2 / (pow((x - 6.0), 2.0) + 0.02);
   //y = x * cos(10.0*pow(x, 2.0)) / (pow(x, 2.0) + 1.0);
   //y = sqrt(x) / (x*x + 1.0);
   //y = sin(pi*x*x) / ((x - pi)*(x - pi) + 1);
   return y;
}