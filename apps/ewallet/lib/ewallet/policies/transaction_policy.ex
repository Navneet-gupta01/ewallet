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

defmodule EWallet.TransactionPolicy do
  @moduledoc """
  The authorization policy for accounts.
  """
  @behaviour Bodyguard.Policy
  alias EWallet.Permissions

  def authorize(:all, attrs, nil) do
    Permissions.can?(attrs, %{action: :all, type: :transactions})
  end

  def authorize(:get, attrs, transaction) do
    Permissions.can?(attrs, %{action: :get, target: transaction})
  end

  def authorize(:create, attrs, transaction) do
    Permissions.can?(attrs, %{action: :create, target: transaction})
  end

  def authorize(:export, attrs, transaction) do
    Permissions.can?(attrs, %{action: :export, target: transaction})
  end

  def authorize(_, _, _), do: false
end
