defmodule Bite.Repo.Migrations.CreateIdentityTable do
  use Ecto.Migration

  def change do
    create table(:identity) do
      add(:phoneNumber, :string)
      add(:email, :string)
      add(:linkedId, :integer)
      add(:linkPrecedence, :string)
      add(:deletedAt, :naive_datetime)
      timestamps()
    end
    create unique_index(:identity, [:email, :phoneNumber])
  end
end
