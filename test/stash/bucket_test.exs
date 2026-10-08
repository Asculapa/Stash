defmodule Stash.BucketTest do
  use ExUnit.Case, async: true

  test "stores values by key" do
    {:ok, bucket} = start_supervised(Stash.Bucket)
    assert Stash.Bucket.get(bucket, "any value") == nil

    Stash.Bucket.put(bucket, "Alex", 26)
    assert Stash.Bucket.get(bucket, "Alex") == 26
  end

  test "stores values on named process", config do
    {:ok, _} = start_supervised({Stash.Bucket, name: config.test})
    assert Stash.Bucket.get(config.test, "") == nil

    Stash.Bucket.put(config.test, "Alex", 27)
    assert Stash.Bucket.get(config.test, "Alex") == 27
  end

  test "deletes values by key" do
    {:ok, bucket} = Stash.Bucket.start_link([])
    assert Stash.Bucket.delete(bucket, "any value") == nil

    Stash.Bucket.put(bucket, "Alex", 26)
    assert Stash.Bucket.get(bucket, "Alex") == 26
    assert Stash.Bucket.delete(bucket, "Alex") == 26
    assert Stash.Bucket.get(bucket, "Alex") == nil
  end
end
