require 'spec_helper'

describe SocialMedium do
  it { should belong_to :user }
  it { should validate_uniqueness_of(:provider_name) }
  it do
    should ensure_exclusion_of(:provider_name).in_array(['fakebook', 'tweeter'])
  end
end
