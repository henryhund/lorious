require 'spec_helper'

describe CreditTransaction do
  context "associations" do
    it { should belong_to(:transacter).class_name('User') }
    it { should belong_to(:transacted).class_name('User') }
  end
end
