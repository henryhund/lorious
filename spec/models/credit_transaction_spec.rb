require 'spec_helper'

describe CreditTransaction do
  context "associations" do
    it { should belong_to :user }
  end
end
