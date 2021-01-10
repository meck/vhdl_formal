self: super:
let
  runChecks = false;
in
{

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

    doCheck = runChecks;
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

    doCheck = runChecks;

    # https://github.com/NixOS/nixpkgs/issues/97466
    propagatedBuildInputs = [ super.zlib ];

    # newer version has a extra space
    # between `version` and `7`
    preConfigure = ''
      # If llvm 7.0 works, 7.x releases should work too.
      sed -i 's/check_version  7.0/check_version 7/g' configure
    '';

  });

  symbiyosys = super.symbiyosys.overrideAttrs (old: rec {
    # Symbiysys checks not working atm.
    # https://github.com/YosysHQ/SymbiYosys/pull/115
    # doCheck = true;
    # checkInputs = old.checkInputs ++ [ self.super_prove super.avy super.btor2tools];
  });

  # Super Prove
  super_prove = super.stdenv.mkDerivation rec {
    name = "super_prove-${version}";
    version = "2017.10.07";
    src = super.fetchurl {
      url =
        "https://downloads.bvsrc.org/super_prove/super_prove-hwmcc17_final-2-d7b71160dddb-Ubuntu_14.04-Release.tar.gz";
      sha256 = "0ay4m5lvwlazdq21wfng4nvlbvjq264rzzdcpsk9cp381lvnv9fq";
    };

    nativeBuildInputs = with super; [
      autoPatchelfHook
      python27
      readline
      zlib
      stdenv.cc.cc.lib
    ];

    installPhase = ''
      mkdir -p $out/libexec $out/bin
      mv bin $out/libexec
      mv lib $out/libexec
      cat > $out/bin/suprove <<EOF
      #!${super.runtimeShell}
      # `+` option is engine name
      tool=super_prove
      if [[ "\$1" != "\''${1#+}" ]]; then tool="\''${1#+}"; shift; fi
      exec $out/libexec/bin/\''${tool}.sh "\$@"
      EOF
      chmod +x $out/bin/suprove
    '';

    checkPhase = "${super.stdenv.shell} -n $out/bin/suprove";
  };

}
