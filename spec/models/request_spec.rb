require 'spec_helper'

describe Request do
  context "associations" do
    it { should belong_to(:requester).class_name('User') }
    it { should belong_to(:requested).class_name('User') }
  end
end
