{
  stdenv,
  lib,
  documentation-highlighter,
  nmd,
  revision,
  outputPath ? "share/doc/neovim-flake",
  options,
  nixos-render-docs,
}:
stdenv.mkDerivation {
  name = "neovim-flake-manual";

  nativeBuildInputs = [nixos-render-docs];

  src = ./manual;

  buildPhase = ''
    mkdir -p out/media

    mkdir -p out/highlightjs
    cp -t out/highlightjs \
      ${documentation-highlighter}/highlight.pack.js \
      ${documentation-highlighter}/LICENSE \
      ${documentation-highlighter}/mono-blue.css \
      ${documentation-highlighter}/loader.js

    substituteInPlace ./options.md \
      --replace \
        '@OPTIONS_JSON@' \
        ${options.schizofox}/share/doc/nixos/options.json

    substituteInPlace ./manual.md \
      --replace \
        '@VERSION@' \
        ${revision}

    cp ${nmd}/static/style.css out/style.css
    cp -t out/highlightjs ${nmd}/static/highlightjs/tomorrow-night.min.css
    cp ${./highlight-style.css} out/highlightjs/highlight-style.css

    nixos-render-docs manual html \
      --manpage-urls ./manpage-urls.json \
      --revision ${lib.trivial.revisionWithDefault revision} \
      --stylesheet style.css \
      --stylesheet highlightjs/tomorrow-night.min.css \
      --stylesheet highlightjs/highlight-style.css \
      --script highlightjs/highlight.pack.js \
      --script highlightjs/loader.js \
      --toc-depth 1 \
      --section-toc-depth 1 \
      manual.md \
      out/index.xhtml
  '';

  installPhase = ''
    dest="$out/${outputPath}"
    mkdir -p "$(dirname "$dest")"
    mv out "$dest"

    mkdir -p $out/nix-support/
    echo "doc manual $dest index.html" >> $out/nix-support/hydra-build-products
  '';
}
