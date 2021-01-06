let
  nixpkgs = builtins.fetchTarball {
    name = "nixpkgs-unstable-2021-01-06";
    url =
      "https://github.com/nixos/nixpkgs/archive/4445bb7284f43feb2f3253d8fb1964f901df5ba1.tar.gz";
    sha256 = "1rz782whlll5ckc85qzndk5klygbjvxwnsgpm8lqqwb85y02s9cs";
  };
  # nixpkgs = <nixpkgs>;
in (import nixpkgs) { overlays = [ (import ./overlay.nix) ]; }
