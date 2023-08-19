defmodule HttpClient.Application do
  ##################################################################################################################
  ##################################################################################################################
  @moduledoc """
  ## Module
  """
  use Application
  use Utils

  alias HttpClient, as: HttpClientWorker

  @supervisor_name HttpClient.Supervisor
  @dynamic_supervisor_name HttpClient.DynamicSupervisor

  ##################################################################################################################
  @doc """
  ### get_opts.
  """
  defp get_opts do
    result = [
      strategy: :one_for_one,
      name: @supervisor_name
    ]

    {:ok, result}
  end

  ##################################################################################################################
  @doc """
  ### get_children!
  """
  defp get_children! do
    result = [
      {DynamicSupervisor, name: @dynamic_supervisor_name, strategy: :one_for_one, restart: :permanent},
      {HttpClientWorker, strategy: :one_for_one, restart: :permanent}
    ]

    {:ok, result}
  end

  ##################################################################################################################
  @doc """
  ### Start application.
  """
  @impl true
  def start(_type, _args) do
    {:ok, children} = get_children!()
    {:ok, opts} = get_opts()

    Supervisor.start_link(children, opts)
  end

  ##################################################################################################################
  @doc """
  # Function.
  """
  def get_dynamic_supervisor_name() do
    @dynamic_supervisor_name
  end

  ##################################################################################################################
  ##################################################################################################################
end
