import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


/// 动画列表测试页面
class HomePage extends StatefulWidget {
  final String title;

  HomePage({Key key, this.title})
      : super(key: key);

  @override
  _HomePageState createState() {
    return _HomePageState();
  }

}


// state
class _HomePageState extends State<HomePage> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  ListModel<int> _list;
  int _selectedItem;
  int _nextItem;


  @override
  void initState() {
    super.initState();
    _list = ListModel<int>(
      listKey: _listKey,
      initialItems: <int>[0, 1, 2],
      removedItemBuilder: _buildRemovedItem
    );
    _nextItem = 3;
  }

  Widget _buildItem(BuildContext context, int index, Animation<double> animation) {
    return CardItem(
      animation: animation,
      item: _list[index],
      selected: _selectedItem == _list[index],
      onTap: () {
        setState(() {
          _selectedItem = _selectedItem == _list[index] ? null : _list[index];
        });
      },
    );
  }

  Widget _buildRemovedItem(int item, BuildContext context, Animation<double> animation) {
    return CardItem(animation: animation, item: item, selected: false,);
  }

  void _insert() {
    final int index = _selectedItem == null ? _list.length : _list.indexOf(_selectedItem);
    _list.insert(index, _nextItem++);
  }

  void _remove() {
    if (_selectedItem != null) {
      _list.removeAt(_list.indexOf(_selectedItem));
      setState(() {
        _selectedItem = null;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text('动画列表测试'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.add_circle),
              onPressed: _insert,
              tooltip: 'insert a new item',
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle),
              onPressed: _remove,
              tooltip: 'remove the selected item',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AnimatedList( // 在AnimatedList中key是一个很重新的角色
              initialItemCount: _list.length,
              key: _listKey,

              itemBuilder: _buildItem),
        )
    );
  }

}

// 定义一个数据类型
class ListModel<E> {
  final List<E> _items;
  final dynamic removedItemBuilder;

  // 这个是AnimatedList必需的
  final GlobalKey<AnimatedListState> listKey;

  ListModel({@required this.listKey, @required this.removedItemBuilder, List<
      E> initialItems})
      : assert(listKey != null),
        assert(removedItemBuilder != null),
        _items = List<E>.from(initialItems ?? <E>[]);

  AnimatedListState get _animatedList => listKey.currentState;

  void insert(int index, E item) {
    _items.insert(index, item);
    _animatedList.insertItem(index);
  }

  E removeAt(int index) {
    E removedItem = _items.removeAt(index);
    if (removedItem != null) {
      _animatedList.removeItem(index,
              (BuildContext context, Animation<double> animation) {
            return removedItemBuilder(removedItem, context, animation);
          });
    }
    return removedItem;
  }

  int get length => _items.length;

  E operator [](int index) => _items[index];

  int indexOf(E item) => _items.indexOf(item);

}

/// 定义每一项的视图
class CardItem extends StatelessWidget {

  const CardItem({
    Key key,
    @required this.animation,
    this.onTap,
    @required this.item,
    this.selected = false
  })
      : assert(animation != null),
        assert(item != null && item >= 0),
        assert(selected != null),
        super(key: key);

  final Animation<double> animation;
  final VoidCallback onTap;
  final int item;
  final bool selected;


  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme
        .of(context)
        .textTheme
        .display1;
    if (selected) {
      textStyle = textStyle.copyWith(color: Colors.lightGreenAccent[400]);
    }
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: SizeTransition(
        axis: Axis.vertical,
        sizeFactor: animation,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque, // 使整个区域都是命中区域
          onTap: onTap,
          child: SizedBox(
            height: 128,
            child: Card(
                color: Colors.primaries[item % Colors.primaries.length],
                child: Text('item: $item', style: textStyle,)),
          ),
        ),
      ),
    );
  }

}