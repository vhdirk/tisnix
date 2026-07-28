{
  lib,
  buildNpmPackage,
  fetchurl,
}:

buildNpmPackage rec {
  pname = "inshellisense";
  version = "0.0.1";

  # 1. Grab the scoped pre-built tarball from the NPM registry
  src = fetchurl {
    url = "https://registry.npmjs.org/@microsoft/${pname}/-/${pname}-${version}.tgz";
    hash = "sha256-LRzi3fxzQPB5kLNLFLyRPTzPP1DEPgqevukyzgWRn5s=";
  };

  # 2. Fetch the exact lockfile for this version from GitHub
  lockfile = fetchurl {
    url = "https://raw.githubusercontent.com/microsoft/inshellisense/${version}/package-lock.json";
    hash = "sha256-y4yepN5Kgf2Ms2mq90so7kmoE0YZTcHUMBDZ0YAlu70=";
  };

  # 3. Inject the lockfile into the unpacked source before the NPM hook runs
  postPatch = ''
    cp ${lockfile} package-lock.json
  '';

  # Replace this with the actual deps hash after your first build attempt
  npmDepsHash = lib.fakeHash;

  # 4. Skip the build step since the NPM release is already transpiled JS
  dontNpmBuild = true;

  meta = {
    description = "IDE style command line auto complete";
    homepage = "https://github.com/microsoft/inshellisense";
    license = lib.licenses.mit;
    mainProgram = "is";
  };
}