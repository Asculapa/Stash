defmodule Stash.Bucket do
  use Agent


  @doc """
  Starts a new bucket.

  All options are forwarded to `Agent.start_link/2`.
  """
  def start_link(opts) do
    Agent.start_link(fn -> %{} end, opts)
  end

  @doc """
  Gets a value from the `bucket` by `key`.
  """
  def put(bucket, key, value) do
    Agent.update(bucket, fn map -> Map.put(map, key, value) end)
  end

  @doc """
  Puts the `value` for the given `key` in the `bucket`.
  """
  def get(bucket, key) do
    Agent.get(bucket, fn map -> Map.get(map, key) end)
  end


  @doc """
  Deletes `key` from `bucket`.

  Returns the current value of `key`, if `key` exists.
  """
  def delete(bucket, key) do
    Agent.get_and_update(bucket, fn map -> Map.pop(map, key) end)
  end
end
