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
    };

  };

}
