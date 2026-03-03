{ pkgs, config, ... }:
{
  # Restic password secret (needs to be created: cd secrets && agenix -e restic-password.age)
  age.secrets.restic-password.file = ../../../secrets/restic-password.age;

  # Pre-backup database dumps
  systemd.services.mcphub-backup-prep = {
    description = "MCPHub pre-backup database dumps";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = let
        dumpScript = pkgs.writeShellScript "mcphub-backup-prep" ''
          set -euo pipefail
          DUMP_DIR="/var/lib/mcphub/backups"
          mkdir -p "$DUMP_DIR"

          # PostgreSQL dump
          ${config.services.postgresql.package}/bin/pg_dump \
            -U mcphub mcphub > "$DUMP_DIR/mcphub.sql"

          # Neo4j dump via cypher-shell export
          ${config.services.neo4j.package}/bin/cypher-shell \
            -u neo4j -p graphiti-poc \
            -a bolt://127.0.0.1:7687 \
            "CALL apoc.export.cypher.all(null, {streamStatements:true})" \
            > "$DUMP_DIR/neo4j-export.cypher" 2>/dev/null || true
        '';
      in dumpScript;
    };
  };

  # Restic backup
  services.restic.backups.mcphub = {
    paths = [
      "/var/lib/mcphub/memory"
      "/var/lib/mcphub/backups"
      "/var/lib/mcphub/mcphub-repo/mcp_settings.json"
    ];
    repository = "/var/lib/mcphub/restic-repo";
    passwordFile = config.age.secrets.restic-password.path;

    backupPrepareCommand = "${pkgs.systemd}/bin/systemctl start mcphub-backup-prep.service";

    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };

    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 6"
    ];
  };
}
