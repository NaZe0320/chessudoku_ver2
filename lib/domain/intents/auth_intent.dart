import 'package:chessudoku/core/base/base_intent.dart';

abstract class AuthIntent extends BaseIntent {
  const AuthIntent();
}

class SignInWithGoogleIntent extends AuthIntent {
  const SignInWithGoogleIntent();
}

class SignInWithAppleIntent extends AuthIntent {
  const SignInWithAppleIntent();
}

class SignInAnonymouslyIntent extends AuthIntent {
  const SignInAnonymouslyIntent();
}

class LinkAnonymousWithGoogleIntent extends AuthIntent {
  const LinkAnonymousWithGoogleIntent();
}

class LinkAnonymousWithAppleIntent extends AuthIntent {
  const LinkAnonymousWithAppleIntent();
}

class SignOutIntent extends AuthIntent {
  const SignOutIntent();
}

class CheckAuthStatusIntent extends AuthIntent {
  const CheckAuthStatusIntent();
}
