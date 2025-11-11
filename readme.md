## To Returning Users

If you used this project prior to 2025-11-11, it's been redesigned. I realised that making this a library was over-engineered. The amount of code it took to invoke it was almost as much as the code in the project itself, and it still wasn't flexible enough for people's needs. It's now a template that's designed to be copied and fiddled with to make it work for your website.

# hakyll-flakes

This repo is a template that reflects how I build my hakyll website using Nix.

To use it, copy the `flake.nix` into your own project or adapt it to fit with what you already have in your `flake.nix`. There isn't much code, and I recommend you read through it to get an idea of what it does.

You can take inspiration also from the rest of the repository if it's helpful, though it was mostly just generated with `hakyll-init` so that it constituted a complete example.

If you want to start a fresh project, it may be useful to run `nix flake init -t github:radvendii/hakyll-flakes` in an empty directory, though it just copies the whole repo in there.

Before you start, you will probably want to change the name in `flake.nix` and `package.yaml` to something more personalized than `my-website`.

The outputs of flake.nix are designed to be used in the following ways:

- `nix build .#website` (or just `nix build`) goes through the whole process and produces a `result/` symlink with your compiled static website inside.
- `nix build .#builder` this builds the website *builder*, your hakyll-based `site.hs` file. `You can find it at result/bin/<project name>`.
- `nix run -- watch` This will compile and run your website builder, creating the `_site` directory and loading the website at `localhost:8000`. It will also rebuild the website if you change the files (but not if you change `site.hs`)
- `nix develop` - this will provide you with the inputs you need to build the website in your `$PATH`. Also gives you what you need to set up the haskell LSP for your editor with all of your haskell packages available.
