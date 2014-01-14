class ScheduledTask
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily }
  #Task to sent out Request recommendations to Experts
  def perform
    @requests = Request.find(:all, :conditions => ["DATE(created_at) = ?", Date.today])
    #Generate request mail for each Expert containing the 
    if @requests.size > 0 
      Expert.all.each do |e|
        @skills = e.subscription_list
        @req_ids = []
        @requests.each do |r|
          @tags = r.skill_list
          if (@tags & @skills).size > 0
            @req_ids.push(r)
          end
        end
        
        if @req_ids.size > 0
          UserMailer.delay.request_created_suggest_experts(@req_ids, e)  
        end

      end  
    end
    
  end
end