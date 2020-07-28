/* 繼承關係，查的到
ios
|
--istream --|
|           ---ifstream--|
|                        |
|                        |---iostream--|
--ostream --|            |             ---fstream
            ---ofstream--|
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
/*
參考，查詢使用方法學習
basic io stl
https://www.runoob.com/cprogramming/c-standard-library.html

vector
https://www.runoob.com/w3cnote/cpp-vector-container-analysis.html
*/

// 參數列舉 枚舉 erum，用在預處理執行在主程式之前
// #define lag  1 // 預處理寫法會太長
// #define a 0.1 // 會錯誤
// enum parameters // enum 只能給 int, long
// {
//       a=1, lag
// } parms;

// ==> 用 struct 用在主程式裏面
// public struct parms
// {
//         public const double Grams = 1;
//         public const double KiloGrams = 0.001;
//         public const double Milligram = 1000;
//         public const double Pounds = 0.00220462;
//         public const double Ounces = 0.035274;
//         public const double Tonnes = 0.000001;
//         // Add Remaining units / values
// }
// double d = Units.KiloGrams;

// 用typeof 的方式可以不設定 access contorl ACL
// 會根據設計自己選擇權限之類的樣子，具體要查
// typedef struct structtt //這是名字，名字別名可以只定義一個
// {
//     short level = 1;
//     unsigned flags;
//     char fd;
//     unsigned char hold;
//     short bsize;
//     unsigned char *buffer;
//     unsigned char *curp;
//     unsigned istemp;
//     short token;
// } struct_alias // 這是別名
// 初始一個struct
// structtt struct_name // 或是用struct_alias都可

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

typedef struct
{
  double a = 0.1; // gain
  int lag = 1; // lag time step
  vector<double>  t = linspace(1,8,100);
}parmeters; // 這是別名

int 
main()
{
  parmeters parms;
  cout<< "test struct： " << parms.a << endl;
  cout<< "time from parms struct"<<endl;
  print_vector(parms.t);
  // 寫入csv
  ofstream out("test.csv"); // sefl-define
  vector< int > arr; // 1d
  vector<double>  t = linspace(1,8,100);
  vector<double> x;
  // print_vector(t);
  out<< 't' << ',' << 'v' << endl;
  for (int i = 0; i <= t.size()-1; ++i){
    x.push_back( sin(t[i]) );
    if (i==t.size()-1 ){ // 最後行不用endl
      out<< t[i] << ',' << x[i];
    } else {
      out<< t[i] << ',' << x[i] << endl;
    }
  }
  // print_vector(x);
  out.close();
  return 0;
}
