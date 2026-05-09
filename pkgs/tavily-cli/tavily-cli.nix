{
  lib,
  python3Packages,
  fetchPypi,
}:
let
  # tavily-python SDK is a runtime dep of tavily-cli but isn't in nixpkgs yet.
  # Vendor the build here so the CLI derivation stays self-contained.
  tavily-python = python3Packages.buildPythonPackage rec {
    pname = "tavily-python";
    version = "0.7.24";
    pyproject = true;

    src = fetchPypi {
      pname = "tavily_python";
      inherit version;
      sha256 = "6c8954193c6472231e813fe50cbd07806bd86c7228957675eb45875a44d58296";
    };

    build-system = with python3Packages; [ setuptools ];

    dependencies = with python3Packages; [
      requests
      tiktoken
      httpx
    ];

    pythonImportsCheck = [ "tavily" ];

    # Upstream ships no test suite in the sdist.
    doCheck = false;

    meta = {
      description = "Python SDK for the Tavily search/extract API";
      homepage = "https://github.com/tavily-ai/tavily-python";
      license = lib.licenses.mit;
    };
  };
in
python3Packages.buildPythonApplication rec {
  pname = "tavily-cli";
  version = "0.1.2";
  pyproject = true;

  src = fetchPypi {
    pname = "tavily_cli";
    inherit version;
    sha256 = "6f78e39551c4f82bb051d2d6f223e2ba303fe9b266cfe9d6bf4e2adcb93a1f53";
  };

  build-system = with python3Packages; [ hatchling ];

  dependencies = with python3Packages; [
    click
    httpx
    rich
    tavily-python
  ];

  pythonImportsCheck = [ "tavily_cli" ];

  doCheck = false;

  meta = {
    description = "Official Tavily CLI — search, extract, crawl, map, and research the web from the terminal (tvly)";
    homepage = "https://github.com/tavily-ai/tavily-cli";
    license = lib.licenses.mit;
    mainProgram = "tvly";
  };
}
