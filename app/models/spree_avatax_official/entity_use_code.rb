module SpreeAvataxOfficial
  class EntityUseCode < ApplicationRecord
    with_options presence: true do
      validates :code, :name, uniqueness: true
    end
  end
end
