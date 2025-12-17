{
  user,
  ...
}:
{
  users.users = {
    root.initialPassword = "root";
    "${user.name}".initialPassword = "${user.name}";
  };
}
