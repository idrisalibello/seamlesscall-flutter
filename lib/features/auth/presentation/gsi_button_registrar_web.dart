import 'package:google_identity_services_web/id.dart' as id;
import 'dart:html' as html;
import 'dart:ui_web' as ui;

// This is the web-specific implementation.
// It registers a view factory that creates a <div> element, which the
// Google Identity Services (GSI) library can then target to render its button.
void registerGoogleSignInButtonViewFactory(String viewId) {
  // A try-catch block is used to prevent exceptions if the factory is
  // already registered, which can happen during hot reloads.
  try {
    ui.platformViewRegistry.registerViewFactory(
      viewId,
      (int internalViewId) {
        final html.DivElement element = html.DivElement()..id = 'gsi-button-$internalViewId';
        // The renderButton method must be called to actually display the GSI button.
        // It's called here immediately after the element is created.
        // The `element.id` will be used as the container ID.
        (id.id as dynamic).renderButton(element);
        return element;
      },
    );
  } catch (e) {
    // Ignore the error if it's already registered.
    // log('View factory for $viewId already registered: $e'); // Optionally log
  }
}
