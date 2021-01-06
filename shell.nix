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

    gnumake
    # TODO symbiyosys shebangs
    # are not patched correctly
    python3

    # visualizing
    graphviz

  ];
}
