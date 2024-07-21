import 'package:fluent_ui/fluent_ui.dart';

class FluentCard extends StatelessWidget {
  final Widget child;
  const FluentCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(child: SizedBox(width: double.infinity, child: child));
  }
}
