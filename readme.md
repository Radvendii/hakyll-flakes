# hakyll-flakes

I've realised that this project was super over-engineered. The new design is a template that reflects how I build my hakyll project. To use it, copy the `flake.nix` into your own project or adapt it to fit with what you already have in your `flake.nix`. You can take inspiration also from the rest of the repository if it's helpful, though it was mostly just generated with `hakyll-init`. If you want to start a fresh project, it may be useful to run `nix flake init -t github:radvendii/hakyll-flakes` in an empty directory.

From the top level directory you can run a few different commands:

- `nix build .#website` (or just `nix build`) this goes through the whole process for you and simply produces a `result/` symlink with your compiled website inside.
- `nix build .#builder` this builds the website *builder*, your hakyll-based `site.hs` file. `You can find it at result/bin/<project name>`.
- `nix run -- watch` This will compile and run your website builder, creating the `_site` directory and loading the website at `localhost:8000`. It will also rebuild the website if you change the files (but not if you change `site.hs`)
- `nix develop` - this will provide you with the inputs you need to build the website in your `$PATH`. Also gives you what you need to set up the haskell LSP for your editor with all of your packages available.
