let
  shane = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINfq31bP+xQwlO/joZeGU6LaLYZXV2ql7TLSv5ToVUtJ";
  server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJxopanPQqEtRB1p8B1BF8aeHG7DbZZUGWqvXS3aslbc";

  # Shared: decryptable by both desktop (shane) and server
  both = [
    shane
    server
  ];
in
{
  # Shared secrets (desktop + server)
  "context7.age".publicKeys = both;
  "github.age".publicKeys = both;
  "todoist.age".publicKeys = both;
  "openai.age".publicKeys = both;
  "mcphub-bearer.age".publicKeys = both;
  "google-oauth-client-id.age".publicKeys = both;
  "google-oauth-client-secret.age".publicKeys = both;
  "tailscale-api.age".publicKeys = both;
  "tailscale-tailnet.age".publicKeys = both;
  "tailscale-authkey.age".publicKeys = both;

  # Desktop-only secrets
  "gemini.age".publicKeys = [ shane ];
  "capacities.age".publicKeys = [ shane ];
  "posthog.age".publicKeys = [ shane ];
  "vex-core.age".publicKeys = [ shane ];
  "vex-interaction.age".publicKeys = [ shane ];
  "vex-protocols.age".publicKeys = [ shane ];
  "vex-compaction.age".publicKeys = [ shane ];
  "vex-session-reload.age".publicKeys = [ shane ];
  "postman-api.age".publicKeys = [ shane ];
  "langsmith-api.age".publicKeys = [ shane ];

  # Server-only secrets
  "restic-password.age".publicKeys = [
    server
    shane
  ];
}
