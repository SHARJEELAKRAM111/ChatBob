import 'package:chatbob/src/imports/core_imports.dart';
import 'package:chatbob/src/imports/packages_imports.dart';

import 'package:chatbob/src/ui/auth/providers/session_provider.dart';


class SessionListenerWrapper extends StatefulWidget {
  final Widget child;
  const SessionListenerWrapper({super.key, required this.child});

  @override
  State<SessionListenerWrapper> createState() => _SessionListenerWrapperState();
}

class _SessionListenerWrapperState extends State<SessionListenerWrapper> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = Provider.of<SessionProvider>(context);
    if (session.status != SessionStatus.unknown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        FlutterNativeSplash.remove();
        if (session.status == SessionStatus.authenticated) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
                  } else if (session.status == SessionStatus.unauthenticated) {
          Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
                  }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
