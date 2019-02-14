# Copyright 2018 OmiseGO Pte Ltd
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

defmodule EWallet.Bouncer.TokenTarget do
  @moduledoc """
  A policy helper containing the actual authorization.
  """
  @behaviour EWallet.Bouncer.TargetBehaviour
  alias EWalletDB.Token

  def get_owner_uuids(%Token{account_uuid: uuid}), do: [uuid]

  def get_target_type(%Token{}), do: :tokens

  def get_target_accounts(%Token{account_uuid: uuid}), do: [uuid]
end
