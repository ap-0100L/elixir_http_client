defmodule HttpClient.Application do
  ##############################################################################
  ##############################################################################
  @moduledoc """

  """
  use Application
  use Utils

  ##############################################################################
  @doc """
  # get_opts.
  """
  defp get_opts do
    result = [
      strategy: :one_for_one,
      name: HttpClient.Supervisor
    ]

    {:ok, result}
  end

  ##############################################################################
  @doc """
  # get_children!
  """
  defp get_children! do
    result = [
      {Finch,
       name: CommonFinch,
       pools: %{
         :default => [
           protocol: :http1,
           size: 10,
           count: 5,
           conn_max_idle_time: 10_000,
           pool_max_idle_time: 10_000,
           conn_opts: [transport_opts: [verify: :verify_none]]
         ]
       }}
    ]

    {:ok, result}
  end

  ##############################################################################
  @doc """
  # Start application.
  """
  def start(_type, _args) do
    {:ok, children} = get_children!()
    {:ok, opts} = get_opts()

    Supervisor.start_link(children, opts)
  end

  ##############################################################################
  ##############################################################################
end
