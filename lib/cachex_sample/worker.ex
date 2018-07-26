defmodule CachexSample.Worker do
  use GenServer

  @name CachexSample.Worker

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: @name)
  end

  def get(key) do
    GenServer.call(@name, { :get, key })
  end

  def set(key, value) do
    GenServer.cast(@name, { :set, key, value })
  end

  def load do
    send @name, :load_cache_backup
  end

  def dump do
    send @name, :create_cache_backup
  end

  def init(name) do
    {:ok, pid} = Cachex.start_link(name)
    # You can try passing a different delay
    Process.send_after(self(), :load_cache_backup, 0)
    schedule_cache_backup()
    Process.flag(:trap_exit, true) # trap exits so we can create backup on exit
    { :ok, {name, pid} }
  end

  def handle_call({:get, key}, _from, {name, _pid} = state) do
    {:ok, value} = Cachex.get(name, key)
    {:reply, value, state}
  end

  def handle_cast({:set, key, value}, {name, _pid} = state) do
    IO.puts inspect(Cachex.put(name, key, value))
    {:noreply, state}
  end

  def handle_info(:load_cache_backup, {name, pid} = state) do
    location = Path.join(System.cwd, "priv/cache_backup")
    IO.puts "loading cache backup"
    IO.puts inspect(Cachex.load(name, location))
    {:noreply, state}
  end

  def handle_info(:create_cache_backup, {name, _pid} = state) do
    {:ok, size} = Cachex.size(name)
    create_backup_if_present(name, size)
    schedule_cache_backup() # Reschedule once more
    {:noreply, state}
  end

  defp create_backup_if_present(name, size) when size > 0 do
    location = Path.join(System.cwd, "priv/cache_backup")
    IO.puts "creating cache backup"
    IO.puts inspect(Cachex.dump(name, location))
  end

  defp create_backup_if_present(_name, _size), do: {:ok, :empty_cache}

  defp schedule_cache_backup(delay \\:timer.minutes(3)) do
    Process.send_after(self(), :create_cache_backup, delay)
  end

  def terminate(_reason, {name, _pid}) do
    schedule_cache_backup(0)
  end
end