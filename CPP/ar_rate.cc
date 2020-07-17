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

// dependency only one file ! quasi montecarlo integrator qmc from github
#include "dependency/qmc.hpp" //for integral need gsl
// namespace is integrators (integrators::transforms::Korobov)
#include <gsl/gsl_statistics.h> // calculate the var and mean

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

// search maximum in vector array
double maxser(vector<double> vec){
  std::vector<double>::iterator it;
  it = std::max_element(std::begin(vec), std::end(vec));
  return *it;
  // std::distance(std::begin(v), biggest);
}
// copy vector to array
// double cpVec2Arr(vector<double> vec){
//   double arr[vec.size()]; 
//   copy(vec.begin(), vec.end(), arr);
//   return arr;
// }

// 預處理設定 只能為int, long
// AR(lag)
#define samples 100 // sample 數量 解析度
#define endtime 100 // 時間長度
#define lag 1 // lag sample 數量
#define omega 326

typedef struct
{
  double const_a = 0.1; // constant gain
  double theta = 0.1; // threshold of the integral parameter
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

// % g_struct = struct('lag_p',lag,'samples',N, 'varing_gain',a,...
// %        'predict',x,'noise',e, 'input',e );
  // AR(lag) 事後預測

  // 產生 r = t /N, N 是endtime
  vector<double> r;
  for (int i=0; i<= t.size()-1; i++){
    r.push_back(t[i]/endtime);
  }
  
  // 使用論文的TVAR 累加起來之後加上 "負號" ？
  // 由於zt noise的地方之前就先加入了-->x, xt是沒有加入的
  // 如果要模擬再多加入noise的話，可能要再產生一個noise矩陣，區間範圍要自定義，先沒有加入
  // 看需求noise再加在哪邊
  // varience 求法參照 gsl https://www.gnu.org/software/gsl/doc/html/statistics.html
  // vector 用的有點多了，這裏要傳入double array，但是vector的push_back 很好用，所以
  // 用arr[vec.size()];  std::copy(vec.begin(), vec.end(), arr)解決
  // gsl_stats_variance_m(const double data[], size_t stride, size_t n, double mean), 回傳double
  double mean;
  double variance;
  vector<double> tvar;
  vector<double> g; //g(r,w)
  vector<double> Distor; //D(theta)
  vector<double> Rate; //R(D(theta))
  for (int i=0; i<= t.size()-1; i++){
    if(i<=lag){
      tvar.push_back(0); // 不存東西
      g.push_back(0);
      Distor.push_back(0);
      Rate.push_back(0);
    } else{ // i>0
      tvar.push_back( (parms.const_a*x[i-2]+parms.const_a*x[i-1]+x[i-1]) );
      //calc variance
      double data[tvar.size()]; 
      copy(tvar.begin(), tvar.end(), data);
      mean = gsl_stats_mean(data, 1, i+1);
      variance = gsl_stats_variance(data, 1, i+1);
      // cout<< "mean: "<< mean<<endl<<"var: "<< variance<<endl<<endl;
      // compute rate distortion
      g.push_back( 0 );
      
    }
  }
  // cout<< "mean: "<< mean<<endl<<"var: "<< variance<<endl;
  print_vector(tvar);
  // 對照用的 ar(lag)
  vector<double> ar;
  for (int i=0; i<= t.size()-1; i++){
    if(i<lag){
      ar.push_back(0); // 不存東西
    } else { // i>0
      ar.push_back( (parms.const_a*x[i-1]+x[i-1]) );// parms.const_a*x[i-2]+parms.const_a*x[i-1]+x[i-1] if lag=2 ...etc
    }
  }
  
  // 寫入csv
  ofstream out("test.csv"); // sefl-define
  out<< 't' << ',' << "xt without noise" <<','<< 'x'<<','<<"lag("<<to_string(lag)<<") a="<< to_string(parms.const_a) <<',' << "noise" <<','<< "TVAR" <<endl;
  for (int i = 0; i <= t.size()-1; ++i){
      if (i==t.size()-1 ){ // 最後行不用endl
      out<< t[i] << ',' << xt[i]<<','<< x[i];
      } else {
      out<< t[i] << ',' << xt[i]<<',' << x[i]<<','<< ar[i]<< ','<<noise[i]<<','<< tvar[i] <<endl;
      }
  }
  out.close();
  return 0; // program end clear all
}