/* 
Author: Shih Chun Huang
conpile flags with gnu scienctific library (gsl) --> qmc integrator need it
g++ -std=c++11 -lgsl -lgslcblas arima.cc
g++ -std=c++11 ar_lag1.cc  -lgsl -lgslcblas # macos or msys2
g++ -std=c++11 ar_lag1.cc -I/usr/local/include/gsl -lgsl -lgslcblas -lpthread # wsl and linux need to add the suffix if build from source
g++ -std=c++11 ar_lag1.cc -lgsl -lgslcblas -lpthread # wsl and linux need -lpathread pahread.h
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
#include <gsl/gsl_statistics.h> // calculate the var and mean

// linspace 複製來的
template<typename T>
vector<float> linspace(T start_in, T end_in, int num_in)
{
  vector<float> linspaced;

  float start = static_cast<float>(start_in);
  float end = static_cast<float>(end_in);
  float num = static_cast<float>(num_in);

  if (num == 0) { return linspaced; }
  if (num == 1) 
    {
      linspaced.push_back(start);
      return linspaced;
    }

  float delta = (end - start) / (num - 1);

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
// vector<float> vec, vector<float> vcc......
void print_vector(vector<float> vec)
{
  cout << "size: " << vec.size() << endl;
  for (float d : vec)
    cout << d << " ";
  cout << endl;
}

// 預處理設定 只能為int, long
// AR(lag)
#define samples 200 // sample 數量 解析度 精度
#define endtime 100 // 時間長度
#define seq 100 // test seq length after predition
#define lag 1 // lag sample 數量
#define omega 326

typedef struct
{
  float const_a = 0.1; // constant gain
}parmeters; // 這是別名

int 
main()
{
  parmeters parms;
  // 產生 time [1,100] + seq length
  vector<float>  t = linspace(1,endtime+seq,samples);
  // 產生noise [-1,1]
  vector<float> noise;
  for (int i=0; i<= t.size()-1; i++){
    noise.push_back( (float) (rand()%200000-100000)/100000 ); 
  }
  // 產生 signal
  vector<float> xt;
  vector<float> x; // add noise
  for (int i=0; i<= t.size()-1; i++){
    xt.push_back( (float) (2*cos(omega*t[i])+sin(omega/5*t[i])+5) ); 
    // x = xt+noise;
    x.push_back( (float) (xt[i]+ noise[i]) );
  }
  // AR(lag) 事後預測 到endtime
  vector<float> ar;
  for (int i=0; i<= t.size()-1; i++){
    if(i<lag || t[i]>(endtime) ){
      ar.push_back(0); // 不存東西
    } else{ // i>0
      ar.push_back(parms.const_a*x[i-1]+x[i-1]);// parms.const_a*x[i-2]+parms.const_a*x[i-1]+x[i-1] if lag=2 ...etc
      cout<<"ar.size(): "<<i<<"/"<< ar.size()<<endl;
      // //calc variance // gsl不知道如何處理lag的問題，所以還是自己寫
      // float mean=0;
      // float variace=0;
      // float data[ar.size()]; 
      // copy(ar.begin(), ar.end(), data);
      // mean = gsl_stats_mean(data, 1, i);
      // variance = gsl_stats_variance(data, 1, i);
      // cout<< "mean: "<< mean<<endl<<"var: "<< variance<<endl;

      // calc mean
      float mean=0;
      for (i=lag; i<= ar.size()-1;i++){
        mean = ar[i] + mean;
      }
      mean=mean/(ar.size()-lag);
      // calc variance
      float variance =0;
      for (i=lag; i<= ar.size()-1;i++){
        variance = pow(ar[i]-mean,2) + variance;
      }
      variance= variance/(ar.size()-lag-1);
      cout<<"mean: "<< mean<<endl<<"var: "<< variance<<endl<<endl;
    }
  }
  print_vector(ar);
  // Mean squared prediction error(MSPE)
  // Stationarity 恆定性 期望值=mean val --> variance--> covariance gaussian distribution

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