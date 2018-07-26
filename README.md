# CachexSample

The idea is to backup the cache `:my_cache` using a `CachexSample.Worker` GenServer every 3 minutes.
Also if the process is terminated, it should create the backup.

Once the process is restarted, the backup should be loaded again.
```
iex -S mix

Erlang/OTP 20 [erts-9.3.1] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:10] [hipe] [kernel-poll:false] [dtrace]
Interactive Elixir (1.6.5) - press Ctrl+C to exit (type h() ENTER for help)
loading cache backup
iex(1)> {:error, :unreachable_file}
iex(1)> Cachex.size(:my_cache)
{:ok, 0}
iex(2)> CachexSample.Worker.set(:a, 1)
:ok
iex(3)> {:ok, true}
iex(3)> CachexSample.Worker.set(:b, 2)
{:ok, true}
:ok
iex(4)> Cachex.size(:my_cache)
{:ok, 2}
iex(5)> CachexSample.Worker.dump
:create_cache_backup
iex(6)> creating cache backup
{:ok, true}
iex(6)> Cachex.size(:my_cache)
{:ok, 2}
iex(7)> Cachex.clear(:my_cache)
{:ok, 2}
iex(8)> Cachex.size(:my_cache)
{:ok, 0}
iex(9)> CachexSample.Worker.load
:load_cache_backup
iex(10)> loading cache backup
{:ok, true}
iex(10)> Cachex.size(:my_cache)
{:ok, 2}
iex(11)> CachexSample.Worker.get(:a)
1
iex(12)> CachexSample.Worker.get(:b)
2
iex(13)> File.exists?(Path.join(System.cwd, "priv/cache_backup"))
true
```

Then if you exit the session and start a new one

```
iex -S mix
Erlang/OTP 20 [erts-9.3.1] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:10] [hipe] [kernel-poll:false] [dtrace]

loading cache backup
Interactive Elixir (1.6.5) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> {:error, :unreachable_file}
iex(1)> CachexSample.Worker.load
:load_cache_backup
loading cache backup
iex(2)> {:ok, true}
iex(2)> CachexSample.Worker.get(:a)
1
iex(3)> Cachex.size(:my_cache)
{:ok, 2}
```