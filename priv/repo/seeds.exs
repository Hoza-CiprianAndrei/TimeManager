alias Tmanager.Repo
alias Tmanager.Role
alias Tmanager.Accounts.User

admin_role = Repo.insert!(%Role{name: "Administrator"})
user_role = Repo.insert!(%Role{name: "User"})

user_attrs = %{
  "email" => "admin@timemanager.com",
  "username" => "admin",
  "password" => "securepassword123",
  "role_id" => admin_role.id
}

%User{}
|> User.changeset(user_attrs)
|> Repo.insert!()
