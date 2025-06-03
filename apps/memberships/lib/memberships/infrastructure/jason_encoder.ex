# Find a better solution for this
defimpl Jason.Encoder, for: Memberships.Infrastructure.Db.Schema.MembershipReadModel do
  def encode(%{__struct__: _} = struct, opts) do
    struct
    |> Map.from_struct()
    |> sanitize_map()
    |> Jason.Encode.map(opts)
  end

  defp sanitize_map(map) do
    map
    |> Map.drop([:__meta__, :__struct__])
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      value =
        case value do
          %Ecto.Association.NotLoaded{} -> nil
          _ -> value
        end

      Map.put(acc, key, value)
    end)
  end
end
