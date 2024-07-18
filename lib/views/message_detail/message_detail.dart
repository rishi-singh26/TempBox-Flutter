import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_state.dart';

class MessageDetail extends StatelessWidget {
  const MessageDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(builder: (context, dataState) {
      if (dataState.selectedMessage == null) {
        return Scaffold(appBar: AppBar(), body: const Center(child: Text('No Message Selected!')));
      }
      return Scaffold(
        body: CustomScrollView(
          slivers: [SliverAppBar.large(title: Text(dataState.selectedMessage!.from['name'] ?? ''))],
        ),
      );
    });
  }
}
