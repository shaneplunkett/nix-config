{ ... }:
let
  secretFile = name: ../../../secrets/${name}.age;
in
{
  age.secrets = {
    openai.file = secretFile "openai";
    mcphub-bearer.file = secretFile "mcphub-bearer";
    context7.file = secretFile "context7";
    todoist.file = secretFile "todoist";
    github.file = secretFile "github";
    google-oauth-client-id.file = secretFile "google-oauth-client-id";
    google-oauth-client-secret.file = secretFile "google-oauth-client-secret";
    tailscale-api.file = secretFile "tailscale-api";
    tailscale-tailnet.file = secretFile "tailscale-tailnet";
    tailscale-authkey.file = secretFile "tailscale-authkey";
  };
}
