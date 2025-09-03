import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

void main() {runApp(MyApp());
SemanticsBinding.instance.ensureSemantics();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartRefresher Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SimpleRefresherPage(),
    );
  }
}

class SimpleRefresherPage extends StatefulWidget {
  const SimpleRefresherPage({Key? key}) : super(key: key);

  @override
  State<SimpleRefresherPage> createState() => _SimpleRefresherPageState();
}

class _SimpleRefresherPageState extends State<SimpleRefresherPage> {
  final RefreshController _controller = RefreshController(initialRefresh: false);
  final List<int> _items = List<int>.generate(150, (i) => i);
  bool _noMore = false;

  Future<void> _onRefresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    setState(() {
      _items
        ..clear()
        ..addAll(List<int>.generate(45, (i) => i));
      _noMore = false;
    });
    _controller.refreshCompleted();
  }

  Future<void> _onLoading() async {
    if (_noMore) {
      _controller.loadNoData();
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 800));
    setState(() {
      final next = _items.length;
      _items.addAll(List<int>.generate(45, (i) => next + i));
      if (_items.length >= 1500) {
        _noMore = true;
      }
    });
    if (_noMore) {
      _controller.loadNoData();
    } else {
      _controller.loadComplete();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simple SmartRefresher')),
      body: SmartRefresher(
        controller: _controller,
        enablePullDown: true,
        enablePullUp: true,

        header: const ClassicHeader(),
        footer: const ClassicFooter(),
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: ListView.separated(
          itemBuilder: (_, index) => ListTile(title: Text('Item \'${_items[index]}\'')),
          separatorBuilder: (_, __) => const Divider(height: 0),
          itemCount: _items.length,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _controller.requestRefresh(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
