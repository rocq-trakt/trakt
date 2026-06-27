{ lib }:

with lib;
{
  mkFmt = str: removePrefix "v" (replaceStrings [ "." ] [ "_" ] str);

  mkTrakt =
    pkgs:
    {
      rocq,
      stdlib,
      rocq-elpi,
      elpi ? null,
      trakt ? "dev",
    }:
    let
      pinnedRocqPackages =
        let
          version = concatStringsSep "_" (take 2 (splitVersion rocq));
          subset = "rocqPackages_${version}";
        in
        if hasAttr subset pkgs then
          pkgs.${subset}
        else
          pkgs.rocqPackages.overrideScope (
            _: prev: {
              rocq-core = prev.rocq-core.override { inherit version; };
              zify = null;
            }
          );
    in
    {
      name = "trakt-${mkFmt rocq}-${mkFmt stdlib}-${mkFmt rocq-elpi}-${mkFmt trakt}";
      value =
        (pinnedRocqPackages.overrideScope (
          _: prev: {
            stdlib = prev.stdlib.override { version = stdlib; };
            rocq-elpi = prev.rocq-elpi.override {
              version = rocq-elpi;
              elpi-version = elpi;
            };
            trakt = prev.trakt.override { version = trakt; };
          }
        )).trakt;
    };

  getVersions =
    rocqPackages:
    rocqPackages.overrideScope (
      final: prev: {
        lib = prev.lib // {
          switch = dependencies: cases: _: { inherit cases dependencies; };
        };

        mkRocqDerivation = fix (
          self:
          {
            defaultVersion ? "dev",
            pname,
            propagatedBuildInputs ? [ ],
            version,
            ...
          }@args:
          let
            applyOverride = f: self (args // (if isFunction f then f args else f));
            this = self args;
          in
          {
            inherit defaultVersion pname;

            override = applyOverride;
            overrideAttrs = applyOverride;

            # 'lib.switch' expects to recieve the version, using the 'version' field.
            # As we would like to retrieve the name instead, we overwrite this field.
            version = pname;

            # Get the transitive Rocq dependency closure
            rocqDependencies =
              let
                collectRocqDepsOf =
                  {
                    propagatedBuildInputs ? [ ],
                    ...
                  }@drv:
                  (if drv ? availableVersions then [ drv ] else [ ])
                  ++ concatMap collectRocqDepsOf (filter (hasAttr "rocqDependencies") propagatedBuildInputs);
              in
              unique (
                [
                  final.rocq-core
                  this
                ]
                ++ concatMap collectRocqDepsOf propagatedBuildInputs
              );
          }
          // (
            if builtins.isAttrs defaultVersion && hasAttr "cases" defaultVersion then
              {
                availableVersions = map (
                  { case, out }:
                  {
                    version = out;
                    clause =
                      attrs:
                      foldl' (x: y: x && y) (prev.lib.versions.isEq attrs.${args.pname} out) (
                        zipListsWith (cl: pname: cl attrs.${pname}) (final.lib.flatten [ case ]) (
                          final.lib.flatten [ defaultVersion.dependencies ]
                        )
                      );
                  }
                ) defaultVersion.cases;
              }
            else
              {
                availableVersions = [
                  {
                    version = defaultVersion;
                    clause = (_: true);
                  }
                ];
              }
          )
        );

        rocq-core = (prev.rocq-core.override { rocq-version = "rocq"; }) // {
          availableVersions =
            let
              mkCase = v: {
                version = v;
                clause = { rocq, ... }: prev.lib.versions.isEq rocq v;
              };
            in
            # TODO: Generate this matrix automatically
            map mkCase [
              "9.2.0"
              "9.1.1"
              "9.0.1"
            ];
        };
      }
    );

  getMatrix =
    rocqPackages: pkgName:
    with rocqPackages.lib;
    let
      rawMatrix =
        let
          pkg = (getVersions rocqPackages).${pkgName};
          extractVersions = { pname, availableVersions, ... }: nameValuePair pname availableVersions;
        in
        cartesianProduct (listToAttrs (map extractVersions pkg.rocqDependencies));

      buildConstraints =
        let
          init = {
            constraints = { };
            clauses = (_: true);
          };

          merge =
            { constraints, clauses }:
            { name, value }:
            {
              constraints = constraints // {
                ${name} = value.version;
              };
              clauses = (attrs: clauses attrs && value.clause attrs);
            };
        in
        map (elem: foldl' merge init (attrsToList elem));

      excludeIncompatibilities =
        matrix:
        map ({ constraints, ... }: constraints) (
          filter ({ clauses, constraints }: clauses constraints) matrix
        );
    in
    excludeIncompatibilities (buildConstraints rawMatrix);

  findRocqByName =
    pkgs: name:
    with pkgs.lib;
    let
      M = filter (hasAttr "pname") (
        filter (f: !isFunction f) (map ({ value, ... }: value) (attrsToList pkgs.rocqPackages))
      );
    in
    findFirst ({ pname, ... }: pname == name) null M;
}
