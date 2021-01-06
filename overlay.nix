self: super: {

  # Yosys with plugin for synthesizing
  # GHDL output
  yosys = let

    ghdl-yosys-plugin = super.fetchFromGitHub {
      owner = "ghdl";
      repo = "ghdl-yosys-plugin";
      rev = "8b3e740fef9a653a20a838f1ade475960e1d379b";
      sha256 = "13kpcp37r11xgqd8aksddi40a5vpzqi7p8qgyjbs99lyscyli75x";
    };

  in super.yosys.overrideAttrs (old: rec {

    # Build Yosys with plugin
    # then `-m ghdl` is not needed
    patchPhase = old.patchPhase + ''
      mkdir -p frontends/ghdl
      cp -r ${ghdl-yosys-plugin}/src/* frontends/ghdl/
    '';

    makeFlags = old.makeFlags
      ++ [ "ENABLE_GHDL=1" "GHDL_PREFIX=${self.ghdl-llvm}" ];

    # Save some time
    # doCheck = false;
  });

  # GHDL
  ghdl-llvm = super.ghdl-llvm.overrideAttrs (old: rec {

    # Newer version then nixpkgs
    version = "HEAD";
    src = super.fetchFromGitHub {
      owner = "ghdl";
      repo = "ghdl";
      rev = "8ed352778368cfbff239bb2a89fc6a937c65fc26";
      sha256 = "1a3f2n6iryq7hnncd4maqzanknq92xqng4qw7dzn4327h6jxzqvk";
    };

    # Save some time
    # doCheck = false;

    # https://github.com/NixOS/nixpkgs/issues/97466
    propagatedBuildInputs = [ super.zlib ];

    # newer version has a extra space
    # between `version` and `7`
    preConfigure = ''
      # If llvm 7.0 works, 7.x releases should work too.
      sed -i 's/check_version  7.0/check_version 7/g' configure
    '';

  });

}
