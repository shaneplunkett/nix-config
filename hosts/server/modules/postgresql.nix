{ pkgs, ... }:
{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17;
    extensions = ps: [ ps.pgvector ];
    ensureDatabases = [ "mcphub" ];
    ensureUsers = [
      {
        name = "mcphub";
        ensureDBOwnership = true;
      }
    ];
    # Localhost-only (default), no TCP exposure needed
    enableTCPIP = false;
    initialScript = pkgs.writeText "init-pgvector.sql" ''
      CREATE EXTENSION IF NOT EXISTS vector;
    '';
  };
}
