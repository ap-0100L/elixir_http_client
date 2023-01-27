defmodule HttpClient.Application do
  ##############################################################################
  ##############################################################################
  @moduledoc """
  ## Module
  """
  use Application
  use Utils

  alias HttpClient.Services.HttpClientService, as: HttpClientService

  ##############################################################################
  @doc """
  ### get_opts.
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
  ### get_children!
  """
  defp get_children! do
    {:ok, from_db} = get_app_env!(:from_db)

    finch_name = HttpClientService.get_transport_name_()

    result =
      if from_db do
        []
      else
        {:ok, pools} = get_app_env!(:pools)

        [
          {Finch, name: finch_name, pools: pools}
        ]
      end

    {:ok, result}
  end

  ##############################################################################
  @doc """
  ### Start application.
  """
  def start(_type, _args) do
    {:ok, children} = get_children!()
    {:ok, opts} = get_opts()

    Supervisor.start_link(children, opts)
  end

  ##############################################################################
  ##############################################################################
end
