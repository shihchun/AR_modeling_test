#include <boost/python.hpp>
// 其他需要包含的头文件，与具体业务有关

namespace py = boost::python;

// 其他函数，可能包括一些用于类型转换和封装的

BOOST_PYTHON_MODULE(my_module_name)
{
    // 导出普通函数
    def("fun_name_in_python", &fun_name_in_c);
    
    // 导出类及部分成员
    class_<ClassNameInCpp>("ClassNameInPython", init<std::string>())               //类名，默认构造函数
        .def(init<double>())                                                       //其他构造函数
        .def("memberFunNameInPython", &ClassNameInCpp::memberFunNameInCpp)         //成员函数
        .def_readwrite("dataMemberInPython", &ClassNameInCpp::dataMemberInCpp)     //普通成员变量
        .def_readonly("dataMemberInPython_2", &ClassNameInCpp::dataMemberInCpp_2)  //只读成员变量
    ;
}