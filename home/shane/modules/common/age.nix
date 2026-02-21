{ ... }:
{
  age = {

    secrets = {
      context7 = {
        file = ../../../../secrets/context7.age;
      };
      gemini = {
        file = ../../../../secrets/gemini.age;
      };
      github = {
        file = ../../../../secrets/github.age;
      };
      todoist = {
        file = ../../../../secrets/todoist.age;
      };
      posthog = {
        file = ../../../../secrets/posthog.age;
      };
      google-oauth-client-id = {
        file = ../../../../secrets/google-oauth-client-id.age;
      };
      google-oauth-client-secret = {
        file = ../../../../secrets/google-oauth-client-secret.age;
      };
    };

  };

}
