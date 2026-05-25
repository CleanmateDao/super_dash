{{flutter_js}}
{{flutter_build_config}}

function hideSplash() {
  document.querySelector('#progress-bar')?.remove();
  document.querySelector('#splash-logo')?.remove();
  document.querySelector('#splash-copy')?.remove();
  document.body.classList.remove('loading-mode');
}

_flutter.loader.load({
  onEntrypointLoaded: async function (engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    window.addEventListener('flutter-first-frame', hideSplash, { once: true });
    await appRunner.runApp();
  },
});
