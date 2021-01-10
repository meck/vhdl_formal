{ pkgs ? (import ./nixpkgs.nix) }:

pkgs.mkShell {

  buildInputs = with pkgs; [

    # Main attractions
    ghdl-llvm
    yosys

    # Proofing
    symbiyosys
    z3
    avy
    boolector
    yices
    super_prove

    # Misc
    graphviz
    gnumake

    # TODO symbiyosys shebangs
    # are not patched correctly
    python3

  ];
}
