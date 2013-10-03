#ThinkingSphinx::Index.define :user, :with => :active_record do
#  indexes subject, :sortable => true
#  indexes content
#  indexes author(:name), :as => :author, :sortable => true

#  has author_id, created_at, updated_at
#end


