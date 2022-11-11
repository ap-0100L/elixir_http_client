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
    {:ok, pools} = get_app_env!(:pools)

    IO.inspect(pools)

    result = [
      {Finch, name: CommonFinch, pools: pools}
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
