require 'spec_helper'

describe Sidekiqjob do
  context "associations" do
    it { should belong_to(:workable) }
  end
end
