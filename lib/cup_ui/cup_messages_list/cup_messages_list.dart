import 'package:flutter/cupertino.dart';

class CupMessagesList extends StatelessWidget {
  const CupMessagesList({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('data')),
      child: CustomScrollView(slivers: []),
    );
  }
}
