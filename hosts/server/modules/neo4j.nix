{ pkgs, config, ... }:
let
  neo4jPkg = config.services.neo4j.package;
in
{
  services.neo4j = {
    enable = true;

    # Localhost-only binding
    defaultListenAddress = "127.0.0.1";

    bolt = {
      enable = true;
      listenAddress = ":7687";
    };

    http = {
      enable = true;
      listenAddress = ":7474";
    };

    https.enable = false;

    extraServerConfig = ''
      # Memory tuning
      server.memory.heap.initial_size=1g
      server.memory.heap.max_size=2g
      server.memory.pagecache.size=1g

      # APOC Core procedures allowlist
      dbms.security.procedures.allowlist=apoc.*
      dbms.security.procedures.unrestricted=apoc.*
    '';
  };

  # Activate APOC Core: copy bundled JAR from labs/ to plugins/
  systemd.services.neo4j.preStart = ''
    mkdir -p ${config.services.neo4j.directories.home}/plugins
    for jar in ${neo4jPkg}/share/neo4j/labs/apoc-*.jar; do
      ln -sf "$jar" ${config.services.neo4j.directories.home}/plugins/
    done
  '';

  # Set initial password on first boot
  systemd.services.neo4j-init-password = {
    description = "Set Neo4j initial password";
    wantedBy = [ "neo4j.service" ];
    before = [ "neo4j.service" ];
    unitConfig.ConditionPathExists = "!${config.services.neo4j.directories.home}/data/dbms/auth.ini";
    serviceConfig = {
      Type = "oneshot";
      User = "neo4j";
      Group = "neo4j";
      ExecStart = "${neo4jPkg}/bin/neo4j-admin dbms set-initial-password graphiti-poc";
    };
  };
}
