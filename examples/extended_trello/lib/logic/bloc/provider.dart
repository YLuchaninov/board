import 'package:flutter/widgets.dart';

class Provider<B> extends InheritedWidget {
  final B bloc;

  const Provider({
    Key? key,
    required this.bloc,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(Provider<B> oldWidget) {
    return oldWidget.bloc != bloc;
  }

  static B? of<B>(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<Provider<B>>()?.bloc;
}

class BlocProvider<B> extends StatefulWidget {
  final void Function(BuildContext context, B bloc)? onDispose;
  final B Function(BuildContext context, B? bloc) builder;
  final Widget child;

  BlocProvider({
    Key? key,
    required this.child,
    required this.builder,
    this.onDispose,
  }) : super(key: key);

  @override
  _BlocProviderState<B> createState() => _BlocProviderState<B>();
}

class _BlocProviderState<B> extends State<BlocProvider<B>> {
  late B bloc;

  @override
  void initState() {
    super.initState();
    bloc = widget.builder(context, null);
  }

  @override
  void dispose() {
    widget.onDispose?.call(context, bloc);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Provider(
      bloc: bloc,
      child: widget.child,
    );
  }
}
