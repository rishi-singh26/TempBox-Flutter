import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/shared/components/render_message.dart';

class MessageDetail extends StatelessWidget {
  const MessageDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      if (dataState.selectedMessage == null) {
        return Scaffold(appBar: AppBar(), body: const Center(child: Text('No Message Selected!')));
      }
      return Scaffold(
        appBar: AppBar(title: Text(dataState.selectedMessage!.from['name'] ?? '')),
        body: RenderMessage(message: dataState.selectedMessage!, user: dataState.selectedAddress!.authenticatedUser),
      );
    });
  }
}
