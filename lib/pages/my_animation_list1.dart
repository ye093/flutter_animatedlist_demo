import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 纵然前路坎坷，也要勇往直前
class MyAnimationListPage extends StatefulWidget {
  MyAnimationListPage({@required this.title});

  final String title;

  @override
  State<StatefulWidget> createState() {
    return _MyAnimationListPageState();
  }
}

/// 来来来创建一个State
class _MyAnimationListPageState extends State<MyAnimationListPage> {
  final _listKey = GlobalKey<AnimatedListState>();

  _ListModel<int> _model;

  // 下一项要新增的数据
  int _nextItem;

  // 当前选择的项
  int _selectedItem;

  @override
  void initState() {
    super.initState();
    _model = _ListModel<int>(<int>[1, 2, 3], _listKey,
        removedBuilder: _buildRemovedItem);
    _nextItem = 4;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add_circle),
            onPressed: _actionAdd,
            tooltip: '新增',
          ),
          IconButton(
            icon: Icon(Icons.remove_circle),
            onPressed: _actionRemove,
            tooltip: '删除',
          )
        ],
      ),
      body: AnimatedList(
        initialItemCount: _model.length,
        key: _listKey,
        itemBuilder: _buildItem,
      ),
    );
  }

  // 这里是新增的方法
  void _actionAdd() {
    setState(() {
      int index =
      _selectedItem == null ? _model.length : _model.indexOf(_selectedItem);
      _model.insert(index, _nextItem++);
      _selectedItem = null;
    });
  }

  // 这里是移除的方法
  void _actionRemove() {
    if (_selectedItem != null) {
      int index = _model.indexOf(_selectedItem);
      setState(() {
        _model.removeAt(index);
        _selectedItem = null;
      });
    }
  }

  // 创建删除项
  Widget _buildRemovedItem<T>(
      {Animation<double> animation, int index, T item}) {
    return _ListItemView(
      animation: animation,
      index: index,
      item: item,
      isSelected: true,
    );
  }

  // 创建每一项
  Widget _buildItem(BuildContext context, int index,
      Animation<double> animation) {
    final item = _model[index];
    return _ListItemView<int>(
      animation: animation,
      index: index,
      item: item,
      isSelected: _selectedItem == item,
      onTap: () {
        setState(() {
          if (_selectedItem != item) _selectedItem = item;
        });
      },
    );
  }
}

/// 尽可能简单,定义一个数据模型，把多余的动作在这里执行
class _ListModel<E> {
  _ListModel(List<E> data, GlobalKey<AnimatedListState> key,
      {this.removedBuilder})
      : assert(data != null),
        assert(key != null),
        _data = List<E>.from(data ?? <E>[]),
        _globalKey = key;

  final List<E> _data;
  final GlobalKey<AnimatedListState> _globalKey;
  final dynamic removedBuilder;

  AnimatedListState get animatedList => _globalKey.currentState;

  int get length => _data.length;

  /// 新增
  void insert(int index, E item) {
    _data.insert(index, item);
    animatedList.insertItem(index);
  }

  /// 删除
  E removeAt(int index) {
    E item = _data.removeAt(index);
    if (item != null)
      animatedList.removeItem(index,
              (BuildContext context, Animation<double> animation) {
            return removedBuilder(
              animation: animation,
              index: index,
              item: item,
            );
          });
    return item;
  }

  int indexOf(E item) {
    return _data.indexOf(item);
  }

  /// 检索
  E operator [](int index) => _data[index];
}

/// 把列表项提取出来创建
class _ListItemView<T> extends StatelessWidget {
  _ListItemView({Key key,
    @required this.animation,
    @required this.index,
    @required this.item,
    this.isSelected,
    this.onTap})
      : assert(animation != null),
        assert(index >= 0),
        super(key: key);

  final Animation<double> animation;
  final int index;
  final T item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // 文本在选择和未选择状态的颜色是不一样的
    TextStyle textStyle = Theme
        .of(context)
        .textTheme
        .display3;
    if (isSelected)
      textStyle = textStyle.copyWith(color: Colors.lightGreenAccent);

    return SizeTransition(
        sizeFactor: animation,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque, // 包含大小区域
          child: Container(
              height: 80,
              margin: EdgeInsets.only(top: 5),
              color: Colors.primaries[index % Colors.primaries.length],
              child: Text(
                '第$item项',
                style: textStyle,
              )),
        ));
  }
}
