require 'spec_helper'

describe Availability do
  context "associations" do
    it { should belong_to :expert }
  end
end
