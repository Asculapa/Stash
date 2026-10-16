# Stash

Tutorial project for getting hands-on with Elixir: a small in-memory
key-value store, served over TCP, built on OTP primitives.

## Overview

Data is stored in named **buckets**. Each bucket is an `Agent` holding a map,
started under a `DynamicSupervisor` and registered by name in a `Registry`.
A TCP server accepts client connections and hands each one off to its own
supervised task, so one misbehaving client cannot take down the others.

Supervision tree (started by `Stash`):

```
Stash (Supervisor, :one_for_one)
├── Registry               (name: Stash)               - bucket name → pid
├── DynamicSupervisor      (Stash.BucketSupervisor)    - bucket Agents
├── Task.Supervisor        (Stash.ServerSupervisor)    - one task per client
└── Task (permanent)       Stash.Server.accept/1       - TCP acceptor loop
```

Modules:

| Module           | Purpose                                              |
| ---------------- | ---------------------------------------------------- |
| `Stash`          | Application entry point; `create_bucket/1`, `lookup_bucket/1` |
| `Stash.Bucket`   | Agent-backed bucket: `get/2`, `put/3`, `delete/2`    |
| `Stash.Command`  | Parses text commands and runs them against buckets   |
| `Stash.Server`   | TCP acceptor and per-client read/serve loop          |

## Requirements

- Elixir `~> 1.17`
- Erlang/OTP compatible with your Elixir version

## Getting started

```sh
mix deps.get
mix compile
```

Start the server:

```sh
mix run --no-halt
# or, with an interactive shell:
iex -S mix
```

### Port

The listening port is set in `config/runtime.exs`:

| Condition            | Port   |
| -------------------- | ------ |
| `PORT` env var set   | `$PORT`|
| `MIX_ENV=test`       | `4040` |
| otherwise            | `4050` |

```sh
PORT=5000 mix run --no-halt
```

## Protocol

Commands are plain text, one per line, terminated by `\r\n`. Arguments are
separated by whitespace.

| Command                     | Response on success        |
| --------------------------- | -------------------------- |
| `CREATE <bucket>`           | `OK`                       |
| `PUT <bucket> <key> <value>`| `OK`                       |
| `GET <bucket> <key>`        | `<value>` then `OK`        |
| `DELETE <bucket> <key>`     | `OK`                       |

Errors:

| Response          | When                                                   |
| ----------------- | ------------------------------------------------------ |
| `NOT FOUND`       | The bucket does not exist                              |
| `UNKNOWN COMMAND` | Unrecognised command or wrong number of arguments      |
| `ERROR`           | Any other error; the server closes that connection     |

`GET` on a missing key returns an empty line followed by `OK`.

### Example session

```sh
$ telnet localhost 4050
CREATE shopping
OK
PUT shopping milk 1
OK
GET shopping milk
1
OK
DELETE shopping milk
OK
GET shopping milk

OK
GET groceries milk
NOT FOUND
FOO
UNKNOWN COMMAND
```

(`nc localhost 4050` works too; use `nc -C` if your netcat needs it to send `\r\n`.)

## Using it from Elixir

```elixir
iex> {:ok, _pid} = Stash.create_bucket("shopping")
iex> bucket = Stash.lookup_bucket("shopping")
iex> Stash.Bucket.put(bucket, "milk", 3)
:ok
iex> Stash.Bucket.get(bucket, "milk")
3
iex> Stash.Bucket.delete(bucket, "milk")
3
```

## Running tests

```sh
mix test
```

The test suite includes doctests for `Stash.Command` and integration tests in
`test/stash/server_test.exs` that connect to the running server on port `4040`.
Make sure nothing else is using that port while the tests run.

## Documentation

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc).
Add it to the deps in `mix.exs`:

```elixir
{:ex_doc, "~> 0.34", only: :dev, runtime: false}
```

then run:

```sh
mix deps.get
mix docs
```

and open `doc/index.html`.
