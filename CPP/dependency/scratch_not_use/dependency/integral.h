#include <iostream>
#include <cmath>
#include <ctime>

using std::cout;
using std::endl;

class integral
{
private:
    struct info
    {
        //value表示积分值，error表示误差
        double value;
        double error;
    };
public:
    double definiteIntegral(double(*f)(double), double a, double b, double step = 0.01);
    double infiniteIntegral(double(*f)(double), double a, double step = 0.01, int N = 100, double precision = 0.01, int type = 1);
    info monteCarloDefiniteIntegral(double(*f)(double), double a, double b, double precision = 0.01);
}