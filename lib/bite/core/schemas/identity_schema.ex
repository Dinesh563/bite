defmodule Bite.Schema.Identity do
  use Ecto.Schema

  schema "identity" do
    field(:phoneNumber, :string)
    field(:email, :string)
    # field(:linkedId, :integer)
    field(:linkPrecedence, :string)
    field(:deletedAt, :naive_datetime)
    # custom name for inserted_at
    timestamps(
      inserted_at: :createdAt,
      updated_at: :changedAt
    )

    belongs_to(:leader, __MODULE__,foreign_key: :linkedId, references: :id)
    has_many(:children, __MODULE__ , foreign_key: :id, references: :linkedId)
  end

  def changeset(attrs) do
    import Ecto.Changeset

    %__MODULE__{}
    |> cast(
      attrs,
      [
        :email,
        :phoneNumber,
        :linkedId,
        :linkPrecedence,
        :deletedAt
      ]
    )
    |> unique_constraint([:email, :phoneNumber])
  end
end
