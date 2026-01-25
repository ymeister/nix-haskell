# TodoMVC in Reflex

All of the code lives in `src/Reflex/TodoMVC.hs`.
`static/style.css` is embedded into the application.

## Build Instructions

```bash
nix-build -A projectCross.wasi32.hsPkgs.reflex-todomvc.components.exes.reflex-todomvc
```

```bash
nix-build -A projectCross.ghcjs.hsPkgs.reflex-todomvc.components.exes.reflex-todomvc
```

Then open `index.html` in your browser!
