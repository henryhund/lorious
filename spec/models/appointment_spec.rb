require 'spec_helper'

describe Appointment do
  context "associations" do
    it { should belong_to :expert }
    it { should belong_to :user }
  end
end
