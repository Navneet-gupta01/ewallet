defmodule EWallet.TransactionConsumptionValidator do
  @moduledoc """
  Handles all validations for a transaction request, including amount and
  expiration.
  """
  alias EWallet.Web.V1.Event
  alias EWalletDB.{Repo, Balance, TransactionRequest, TransactionConsumption, MintedToken}

  @spec validate_before_consumption(TransactionRequest.t(), Balance.t(), Integer.t()) ::
          {:ok, TransactionRequest.t(), Integer.t()}
          | {:error, Atom.t()}
  def validate_before_consumption(request, balance, attrs) do
    with amount <- attrs["amount"],
         token_id <- attrs["token_id"],
         {:ok, request} <- TransactionRequest.expire_if_past_expiration_date(request),
         true <- TransactionRequest.valid?(request) || request.expiration_reason,
         {:ok, amount} <- validate_amount(request, amount),
         {:ok, _balance} <- validate_max_consumptions_per_user(request, balance),
         {:ok, token} <- get_and_validate_minted_token(request, token_id) do
      {:ok, request, token, amount}
    else
      error when is_binary(error) ->
        {:error, String.to_existing_atom(error)}

      error when is_atom(error) ->
        {:error, error}

      error ->
        error
    end
  end

  @spec validate_before_confirmation(TransactionConsumption.t(), Account.t() | User.t()) ::
          {:ok, TransactionConsumption.t()}
          | {:error, Atom.t()}
  def validate_before_confirmation(consumption, owner) do
    with {request, balance} <- {consumption.transaction_request, consumption.balance},
         true <-
           TransactionRequest.is_owned_by?(request, owner) || :not_transaction_request_owner,
         {:ok, request} <- TransactionRequest.expire_if_past_expiration_date(request),
         {:ok, _balance} <- validate_max_consumptions_per_user(request, balance),
         true <- TransactionRequest.valid?(request) || request.expiration_reason,
         {:ok, consumption} = TransactionConsumption.expire_if_past_expiration_date(consumption) do
      case TransactionConsumption.expired?(consumption) do
        false ->
          {:ok, consumption}

        true ->
          Event.dispatch(:transaction_consumption_finalized, %{consumption: consumption})
          {:error, :expired_transaction_consumption}
      end
    else
      error when is_binary(error) ->
        {:error, String.to_existing_atom(error)}

      error when is_atom(error) ->
        {:error, error}

      error ->
        error
    end
  end

  @spec validate_amount(TransactionRequest.t(), Integer.t()) ::
          {:ok, TransactionRequest.t()} | {:error, :unauthorized_amount_override}
  def validate_amount(request, amount) do
    case request.allow_amount_override do
      true ->
        {:ok, amount || request.amount}

      false ->
        case amount do
          nil -> {:ok, request, request.amount}
          _amount -> {:error, :unauthorized_amount_override}
        end
    end
  end

  @spec get_and_validate_minted_token(TransactionRequest.t(), UUID.t()) ::
          {:ok, MintedToken.t()}
          | {:error, Atom.t()}
  def get_and_validate_minted_token(request, token_id) do
    with request <- request |> Repo.preload(:minted_token),
         true <- !is_nil(token_id) || {:ok, request.minted_token},
         %MintedToken{} = token <- MintedToken.get(token_id) || :minted_token_not_found,
         true <- request.minted_token_uuid == token.uuid || :invalid_minted_token_provided do
      {:ok, token}
    else
      error when is_atom(error) ->
        {:error, error}

      res ->
        res
    end
  end

  def validate_max_consumptions_per_user(request, balance) do
    with max <- request.max_consumptions_per_user,
         # max has a value
         false <- is_nil(max),
         # The consumption is for a user
         false <- is_nil(balance.user_uuid),
         current_consumptions <-
           TransactionConsumption.all_active_for_user(balance.user_uuid, request.uuid),
         false <- length(current_consumptions) < max do
      {:error, :max_consumptions_per_user_reached}
    else
      _ -> {:ok, balance}
    end
  end
end
