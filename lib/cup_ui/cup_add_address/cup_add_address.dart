import 'package:flutter/cupertino.dart';

class CupAddAddress extends StatelessWidget {
  const CupAddAddress({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          const CupertinoSliverNavigationBar(
            backgroundColor: Color(0X00000000),
            largeTitle: Text('Add Address'),
            stretch: true,
          ),
          SliverList.list(
            children: [
              CupertinoFormSection.insetGrouped(children: [
                CupertinoTextFormFieldRow(
                  placeholder: 'Account name (Optional)',
                  padding: EdgeInsetsDirectional.fromSTEB(10, 6, 10, 6),
                ),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}
