defmodule Tmanager.Token do
  use Joken.Config

  @impl true
  def token_config do
    default_claims(default_exp: 60 * 60 * 24)
  end
end
