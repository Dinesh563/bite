defmodule Bite.Utils do
  def get_first_changeset_error(changeset) do
    [error | _] = changeset.errors
    {field, {message, opts}} = error

    message =
      try do
        Enum.reduce(opts, message, fn {key, value}, acc ->
          String.replace(acc, "%{#{key}}", to_string(value))
        end)
      rescue
        _ ->
          message
      end

    "`#{field}` #{message}"
  end

  def humanize_error(error_code, opts \\ []) do
    error_msg = Keyword.get(opts, :message)
    http_code = Keyword.get(opts, :http_status)
    error_desc = Map.get(@errors, error_code, %{})

    # http_code =
    #   if http_code == 500 do
    #     200
    #   else
    #     http_code
    #   end

    {
      error_code,
      error_msg || Map.get(error_desc, :message, "Something went wrong"),
      http_code || Map.get(error_desc, :http_code, 500)
    }
  end


end
