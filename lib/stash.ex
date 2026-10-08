defmodule Stash do
  use Application

  def start(_type, _args) do
    children = [
      {Registry, name: Stash, keys: :unique},
      {DynamicSupervisor, name: Stash.BucketSupervisor, strategy: :one_for_one}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  @doc """
  Creates a bucket with the given name.
  """
  def create_bucket(name) do
    DynamicSupervisor.start_child(Stash.BucketSupervisor, {Stash.Bucket, name: via(name)})
  end

  @doc """
  Looks up the given bucket.
  """
  def lookup_bucket(name) do
    GenServer.whereis(via(name))
  end

  defp via(name) do
    {:via, Registry, {Stash, name}}
  end
end
