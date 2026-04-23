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
  SessionStatus? _lastStatus;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = Provider.of<SessionProvider>(context);
    
    if (session.status != SessionStatus.unknown && session.status != _lastStatus) {
      _lastStatus = session.status;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        
        FlutterNativeSplash.remove();
        
        final navigator = rootNavigatorKey.currentState;
        if (navigator == null) return;

        if (session.status == SessionStatus.authenticated) {
          navigator.pushReplacementNamed(AppRoutes.home);
        } else if (session.status == SessionStatus.unauthenticated) {
          navigator.pushReplacementNamed(AppRoutes.onboarding);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
