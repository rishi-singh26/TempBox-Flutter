import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/services/ui_service.dart';
import 'package:tempbox/shared/components/render_message.dart';

class IosMessageDetail extends StatelessWidget {
  final Message message;
  const IosMessageDetail({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      if (dataState.selectedMessage == null) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(middle: Text(UiService.getMessageFromName(message))),
          child: const SizedBox.shrink(),
        );
      }
      return PopScope(
        onPopInvoked: (didPop) {
          BlocProvider.of<DataBloc>(dataBlocContext).add(const ResetSelectedMessageEvent());
        },
        child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(middle: Text(UiService.getMessageFromName(dataState.selectedMessage!))),
          child: RenderMessage(message: dataState.selectedMessage!),
        ),
      );
    });
  }
}
