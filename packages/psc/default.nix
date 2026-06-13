{
  git,
  graphviz,
  installShellFiles,
  lib,
  python314Packages,
  stdenv,
  timg,
}:
let
  pyproject = builtins.fromTOML (builtins.readFile ./pyproject.toml);

  inherit (pyproject) project;
  inherit (pyproject.project) version;

  pyBuildDependencies = pyproject.build-system.requires;
  pyDependencies = project.dependencies;

  pname = project.name;
in

python314Packages.buildPythonApplication {
  inherit pname version;

  nativeBuildInputs = [
    installShellFiles
  ];

  propagatedBuildInputs = [
    git
    graphviz
    timg
  ];

  pyproject = true;

  src = ./.;

  build-system = builtins.map (dep: python314Packages.${dep}) pyBuildDependencies;

  dependencies = builtins.map (dep: python314Packages.${dep}) pyDependencies;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd ${pname} \
      --bash <($out/bin/${pname} --generate-completions bash)
  '';

  meta = {
    inherit (project) description;
    mainProgram = pname;
  };
}
