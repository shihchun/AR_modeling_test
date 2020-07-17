/* 
Author: Shih Chun Huang
conpile flags with gnu scienctific library (gsl) --> qmc integrator need it
g++ -std=c++11 -lgsl -lgslcblas arima.cc
./a.out
if use linux, you can try GPU compute with cuda
*/
#include <iostream> // IO
#include <fstream> // 讀寫文件用 STL要多include
#include <vector> // 初始化矩陣方便
#include <cmath> // 數學計算用庫
#include <string>
#include <stdio.h> // sprintf, getchar, gets puts,scanf,erum
#include <stdlib.h> // 亂數相關函數
#include <time.h>   // 時間相關函數
using namespace std; // 把STL全部用到命名空間，不用sin()可以直接呼叫

#include "dependency/qmc.hpp" //for integral need gsl
// namespace is integrators (integrators::transforms::Korobov)

// linspace 複製來的
template<typename T>
vector<double> linspace(T start_in, T end_in, int num_in)
{
  vector<double> linspaced;

  double start = static_cast<double>(start_in);
  double end = static_cast<double>(end_in);
  double num = static_cast<double>(num_in);

  if (num == 0) { return linspaced; }
  if (num == 1) 
    {
      linspaced.push_back(start);
      return linspaced;
    }

  double delta = (end - start) / (num - 1);

  for(int i=0; i < num-1; ++i)
    {
      linspaced.push_back(start + delta * i);
    }
  linspaced.push_back(end); // I want to ensure that start and end
                            // are exactly the same as the input
  return linspaced;
}

// 列印1d vector 除錯用
// function定義方式 用vector, 可以簡單增加變數
// vector<double> vec, vector<double> vcc......
void print_vector(vector<double> vec)
{
  cout << "size: " << vec.size() << endl;
  for (double d : vec)
    cout << d << " ";
  cout << endl;
}

// 預處理設定 只能為int, long
// AR(lag)
#define samples 100 // sample 數量 解析度
#define endtime 100 // 時間長度
#define lag 1 // lag sample 數量
#define omega 326

typedef struct
{
  double const_a = 0.1; // constant gain
}parmeters; // 這是別名

int 
main()
{
  parmeters parms;
  // 產生 time [1,100]
  vector<double>  t = linspace(1,endtime,samples);
  // 產生noise [-1,1]
  vector<double> noise;
  for (int i=0; i<= t.size()-1; i++){
    noise.push_back( (double) (rand()%200000-100000)/100000 ); 
  }
  // 產生 signal
  vector<double> xt;
  vector<double> x; // add noise
  for (int i=0; i<= t.size()-1; i++){
    xt.push_back( (double) (2*cos(omega*t[i])+sin(omega/5*t[i])+5) ); 
    // x = xt+noise;
    x.push_back( (double) (xt[i]+ noise[i]) );
  }
  // AR(lag) 事後預測
  vector<double> ar;
  for (int i=0; i<= t.size()-1; i++){
    if(i<lag){
      ar.push_back(0); // 不存東西
    } else{ // i>0
      ar.push_back(parms.const_a*x[i-1]+x[i-1]);// parms.const_a*x[i-2]+parms.const_a*x[i-1]+x[i-1] if lag=2 ...etc
    }
  }
  print_vector(ar);

  // 寫入csv
  ofstream out("test.csv"); // sefl-define
  out<< 't' << ',' << "xt without noise" <<','<< 'x'<<','<<"lag("<<to_string(lag)<<") a=0.1" <<',' << "noise" <<endl;
  for (int i = 0; i <= t.size()-1; ++i){
      if (i==t.size()-1 ){ // 最後行不用endl
      out<< t[i] << ',' << xt[i]<<','<< x[i];
      } else {
      out<< t[i] << ',' << xt[i]<<',' << x[i]<<','<<ar[i]<< ','<<noise[i]<<endl;
      }
  }
  out.close();
}