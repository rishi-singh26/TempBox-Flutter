import 'package:flutter/cupertino.dart';

class IosMessagesList extends StatelessWidget {
  const IosMessagesList({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('data')),
      child: CustomScrollView(slivers: []),
    );
  }
}
