// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;
import 'dart:js_util' as js_util;

const _siteKey = '6Le6_SwtAAAAAfysahkMl04PLMEC4VBrtiOWUNFc';

Future<String?> executeRecaptcha(String action) async {
  try {
    final grecaptcha = js.context['grecaptcha'];
    if (grecaptcha == null) return null;
    final promise = grecaptcha.callMethod('execute', [
      _siteKey,
      js.JsObject.jsify({'action': action}),
    ]);
    return await js_util.promiseToFuture<String>(promise);
  } catch (_) {
    return null;
  }
}
