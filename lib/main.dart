import 'package:flutter/material.dart';
import 'pages/my_animation_list1.dart';


/// 应用运行的主方法
void main() => runApp(MyApp());



/// 程序入口
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '动画列表',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyAnimationListPage(title: '首页'),
    );
  }
}
