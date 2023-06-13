defmodule Bite.Identity do
  alias Bite.Repo
  alias Bite.Schema.Identity
  import Ecto.Query

  def insert(%{email: email, phoneNumber: phone} = params) do
    IO.inspect(params)
    get_query()
    |> where([c], c.email == ^email or c.phoneNumber == ^phone)
    |> preload([:identity])
    |> order_by(asc: :linkPrecedence, asc: :createdAt)
    |> Repo.all()
    |> IO.inspect()
    |> case do
      [] ->
        insert_new(params, "primary") |> make_identity_response()

      # convert a primary
      [%{id: id, linkPrecedence: "primary"} = first, %{linkPrecedence: "primary"} = second] ->
        Ecto.Changeset.change(second, linkPrecedence: "secondary", linkedId: id)
        |> Repo.update()
        |> case do
          {:ok, changeset} -> make_identity_response([first, changeset])
          {:error, changeset} -> {:invalid, changeset}
        end

      [%{id: id, linkPrecedence: "primary"} | _] = list ->
        params = params |> Map.put(:linkedId, id)

        case insert_new(params, "secondary") do
          {:invalid, _changeset} -> make_identity_response(list)
          res -> make_identity_response(list ++ res)
        end

      list ->
        make_identity_response(list)
    end
  end

  def insert(%{email: email} = params) do
    get_query()
    |> where([c], c.email == ^email)
    |> order_by(asc: :linkPrecedence)
    |> Repo.all()
    |> case do
      [] ->
        insert_new(params, "primary")

      [%{id: id, linkPrecedence: "secondary", linkedId: id} = secondary | tail] ->
        Repo.get(Identity, id) |> IO.inspect()

      list ->
        make_identity_response(list)
    end
  end

  def insert(%{phoneNumber: phone} = params) do
    get_query()
    |> where([c], c.phoneNumber == ^phone)
    |> order_by(asc: :linkPrecedence, asc: :createdAt)
    |> Repo.all()
    |> case do
      [] -> insert_new(params, "primary")
      list -> make_identity_response(list)
    end
  end

  defp get_query() do
    from(c in Identity,
      select: c
    )
  end

  defp construct_email_phone_array(list) do
    %{email: emails, phone: phones} =
      list
      |> Enum.reduce(%{email: [], phone: []}, fn x, acc ->
        case {x.email, x.phoneNumber} do
          {nil, nil} ->
            acc

          {nil, phone} ->
            acc |> Map.put(:phone, [phone | acc.phone])

          {email, nil} ->
            acc |> Map.put(:email, [email | acc.email])

          {email, phone} ->
            acc |> Map.put(:phone, [phone | acc.phone]) |> Map.put(:email, [email | acc.email])
        end
      end)

    {Enum.reverse(emails) |> Enum.uniq(), Enum.reverse(phones) |> Enum.uniq()}
  end

  defp make_identity_response([%{id: id, linkPrecedence: "primary"} | tail] = list) do
    {emails, phones} = construct_email_phone_array(list)

    %{
      contact: %{
        primaryContatctId: id,
        emails: emails,
        phoneNumbers: phones,
        secondaryContactIds: tail |> Enum.map(fn x -> x.id end)
      }
    }
  end

  def insert_new(params, precedence) do
    params
    |> Map.put(:linkPrecedence, precedence)
    |> Identity.changeset()
    |> IO.inspect(label: "changeset")
    |> Repo.insert()
    |> case do
      {:ok, changeset} -> [changeset]
      {:error, changeset} -> {:invalid, changeset}
    end
  end

  # defp constrcut_final_response(changeset) do
  #   %{
  #     contact: %{

  #         primaryContatctId: 1,
  #         emails: ["lorraine@hillvalley.edu","mcfly@hillvalley.edu"],
  #         phoneNumbers: ["123456"]
  #         secondaryContactIds: [23]
  #     }
  #   }
  # end
  # def create_secondary_contact(params) do
  # end
end
