class Expert < User
  acts_as_taggable
  acts_as_taggable_on :skills
end
