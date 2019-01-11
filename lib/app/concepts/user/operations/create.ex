defmodule App.User.Operations.Create do
  use Monad.Operators
  import Monad.Result
  alias App.User

  def call(user_params) do
    result = success(user_params)
             ~>> fn user_params -> encrypt_password_param(user_params) end
             ~>> fn updated_params -> create(updated_params) end

    if success?(result) do
      success(unwrap!(result))
    else
      error(result.error)
    end
  end

  def create(user_params) do
    changeset = User.changeset(%User{}, user_params)

    case App.Repo.insert(changeset) do
      {:ok, user} ->
        success(user)
      {:error, changeset} ->
        error(changeset)
    end
  end

  def encrypt_password_param(user_params) do
    success(Map.put(user_params, "password", Comeonin.Argon2.hashpwsalt(user_params["password"])))
  end
end