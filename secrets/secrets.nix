let
  shane = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINfq31bP+xQwlO/joZeGU6LaLYZXV2ql7TLSv5ToVUtJ";
  hetzvps = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO2+m4gXnLDvZ+3TLfM8PGu3RBOPZBTN59UngXNm+mjt";
in
{
  "context7.age".publicKeys = [ shane ];
  "github.age".publicKeys = [ shane ];
  "todoist.age".publicKeys = [ shane ];
  "openai.age".publicKeys = [ shane ];
  "mcphub-bearer.age".publicKeys = [ shane ];
  "google-oauth-client-id.age".publicKeys = [ shane ];
  "google-oauth-client-secret.age".publicKeys = [ shane ];
  "tailscale-api.age".publicKeys = [ shane ];
  "tailscale-tailnet.age".publicKeys = [ shane ];
  "tailscale-authkey.age".publicKeys = [ shane hetzvps ];
  "gemini.age".publicKeys = [ shane ];
  "posthog.age".publicKeys = [ shane ];
  "vex-core.age".publicKeys = [ shane ];
  "vex-interaction.age".publicKeys = [ shane ];
  "vex-protocols.age".publicKeys = [ shane ];
  "vex-session-start.age".publicKeys = [ shane ];
  "vex-compaction.age".publicKeys = [ shane ];
  "vex-session-reload.age".publicKeys = [ shane ];
  "langsmith-api.age".publicKeys = [ shane ];
  "restic-password.age".publicKeys = [ shane ];
}
