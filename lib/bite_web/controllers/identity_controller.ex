defmodule BiteWeb.IdentityController do
  import Ecto.Changeset

  use BiteWeb, :controller
  alias Bite.Identity
  import Bite.Utils

  def identity(conn, params) do
    with {:valid, params} <- validate_identity_params(params) do
      IO.inspect(params)
      res = Identity.insert(params)

      conn
      |> put_status(200)
      |> json(res)
    else
      {:invalid_params, error_message} ->
        conn
        |> put_status(400)
        |> json(%{
          status: "error",
          message: error_message,
          data: %{empty: "pockets"}
        })
    end
  end

  defp validate_identity_params(params) do
    import Ecto.Changeset

    types = %{
      email: :string,
      phoneNumber: :integer
    }

    changeset =
      {%{}, types}
      |> cast(params, Map.keys(types))
      |> validate_email()
      |> validate_either()
      |> type_cast_phone_number()

    case changeset.valid? do
      true -> {:valid, apply_changes(changeset)}
      false -> {:invalid_params, get_first_changeset_error(changeset)}
    end
  end

  defp type_cast_phone_number(changeset) do
    case get_field(changeset, :phoneNumber) do
      nil -> changeset
      phone -> changeset |> put_change(:phoneNumber, inspect(phone))
    end
  end

  defp validate_either(changeset) do
    email = get_field(changeset, :email)
    phone = get_field(changeset, :phoneNumber)

    if email == nil and phone == nil do
      add_error(changeset, :email, "or 'phoneNumber' is required")
    else
      changeset
    end
  end

  defp validate_email(changeset) do
    email = get_field(changeset, :email)

    if email != nil do
      Regex.match?(~r/^[A-Za-z0-9\._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}$/, email)
      |> case do
        true -> put_change(changeset, :email, email |> String.downcase())
        false -> add_error(changeset, :email, "Invalid")
      end
    else
      changeset
    end
  end
end
