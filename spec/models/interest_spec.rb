require 'spec_helper'

describe Interest do
  context "associations" do
    it { should belong_to(:user) }
  end
end