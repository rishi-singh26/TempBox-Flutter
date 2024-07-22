import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show DefaultMaterialLocalizations;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/cup_ui/cup_addresses_list/cup_addresses_list.dart';

const String title = 'TempBox';

class CupView extends StatelessWidget {
  const CupView({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: title,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
      ],
      theme: const CupertinoThemeData(primaryColor: Color(0xFFBA1F33)),
      home: MultiBlocProvider(
        providers: [BlocProvider<DataBloc>(create: (BuildContext context) => DataBloc())],
        child: const CupAddressesList(),
      ),
    );
  }
}
