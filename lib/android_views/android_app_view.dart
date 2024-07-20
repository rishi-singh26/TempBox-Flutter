import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tempbox/android_views/address_list/address_list.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/messages/messages_bloc.dart';

const String title = 'TempBox';

class AndroidAppView extends StatelessWidget {
  const AndroidAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFBA1F33), brightness: Brightness.light),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFBA1F33), brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<DataBloc>(create: (BuildContext context) => DataBloc()),
          BlocProvider<MessagesBloc>(create: (BuildContext context) => MessagesBloc()),
        ],
        child: const AddressList(title: title),
      ),
    );
  }
}
