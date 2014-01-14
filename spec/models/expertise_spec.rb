require 'spec_helper'

describe Expertise do
  context "associations" do
    it { should belong_to(:expert) }
  end
end