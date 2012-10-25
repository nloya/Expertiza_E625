class ResponseController < ApplicationController
  helper :wiki
  helper :submitted_content
  helper :file  
  
  def delete
    @response = Response.find(params[:id])
    return if redirect_when_disallowed(@response)

    map_id = @response.map.id
    @response.delete
    redirect_to :action => 'redirection', :id => map_id, :return => params[:return], :msg => "The response was deleted."
  end

  #Determining the current phase and check if a review is already existing for this stage.
  #If so, edit that version otherwise create a new version.

  def rereview
     @map=ResponseMap.find(params[:id])
     get_content
        array_not_empty=0
      @sorted_array=Array.new
      @prev=Response.all
         #get all versions and find the latest version
      for element in @prev
        if(element.map_id==@map.id)
          array_not_empty=1
          @sorted_array << element
        end
      end

     #sort all the available versions in descending order.
      if array_not_empty==1
         @sorted=@sorted_array.sort { |m1,m2|(m1.version_num and m2.version_num) ? m2.version_num <=> m1.version_num : (m1.version_num ? -1 : 1)}
         @largest_version_num=@sorted[0]
         @latest_phase=@largest_version_num.created_at
         due_dates = DueDate.find(:all, :conditions => ["assignment_id = ?", @assignment.id])
         @sorted_deadlines=Array.new
         @sorted_deadlines=due_dates.sort {|m1,m2|(m1.due_at and m2.due_at) ? m1.due_at <=> m2.due_at : (m1.due_at ? -1 : 1)}
         current_time=Time.new.getutc
         #get the highest version numbered review
         next_due_date=@sorted_deadlines[0]

         #check in which phase the latest review was done.
          for deadline_version in @sorted_deadlines
          if(@largest_version_num.created_at < deadline_version.due_at )
            break
          end
         end
         for deadline_time in @sorted_deadlines
           if(current_time < deadline_time.due_at)
             break
           end
         end
      end

         #check if the latest review is done in the current phase.
         #if latest review is in current phase then edit the latest one.
           #else create a new version and update it.

        # editing the latest review
     if(deadline_version.due_at== deadline_time.due_at)
         #send it to edit here
         @header = "Edit"
         @next_action = "update"
         @return = params[:return]
         @response = Response.find_by_map_id_and_version_num(params[:id],@largest_version_num.version_num)
         return if redirect_when_disallowed(@response)
         @modified_object = @response.id
         @map = @response.map
         get_content
         @review_scores = Array.new
         @questions.each{
         | question |
           @review_scores << Score.find_by_response_id_and_question_id(@response.id, question.id)
         }
    #**********************
    # Check whether this is Jen's assgt. & if so, use her rubric
    if (@assignment.instructor_id == User.find_by_name("jace_smith").id) && @title == "Review"
      if @assignment.id < 469
         @next_action = "custom_update"
         render :action => 'custom_response'
     else
         @next_action = "custom_update"
         render :action => 'custom_response_2011'
     end
    else
      # end of special code (except for the end below, to match the if above)
      #**********************

      render :action => 'response'

    end
           #   render :action => 'edit'
     else
        #else create a new version and update it.

          @header = "New"
          @next_action = "create"
          @feedback = params[:feedback]
          @map = ResponseMap.find(params[:id])
          @return = params[:return]
          @modified_object = @map.id
          get_content
          #**********************
          # Check whether this is Jen's assgt. & if so, use her rubric
          if (@assignment.instructor_id == User.find_by_name("jace_smith").id) && @title == "Review"
            if @assignment.id < 469
               @next_action = "custom_create"
               render :action => 'custom_response'
           else
               @next_action = "custom_create"
               render :action => 'custom_response_2011'
           end
          else
            # end of special code (except for the end below, to match the if above)
            #**********************
          render :action => 'response'
          end

       end
  end
  
  def edit
    @header = "Edit"
    @next_action = "update"
    @return = params[:return]

    @response = Response.find(params[:id]) 
    return if redirect_when_disallowed(@response)
    @map = @response.map 



    #********************* OSS CHANGE STARTS HERE ************************************************
    is_role_present = params[:role_info]
    if !is_role_present.nil?
      is_role_present = "YES"
      @role_response = Response.find(params[:review_role_id])
      @reviewed_role = TeamRole.find(params[:role_info])
    else
      is_role_present = "NO"
      @reviewed_role = nil
      @role_response = nil
    end
    @reviewed_student = User.find(params[:reviewed_member])
    #********************* OSS CHANGE ENDS HERE ************************************************



    return if redirect_when_disallowed(@response)
    @map = @response.map
#>>>>>>> 4c68f52a7464e968a722335cb6340efbf1c65b0a
    array_not_empty=0
    @sorted_array=Array.new
    @prev=Response.all
    for element in @prev
      if(element.map_id==@map.id)
        array_not_empty=1
        @sorted_array << element
      end
    end
    if array_not_empty==1
      @sorted=@sorted_array.sort { |m1,m2|(m1.version_num and m2.version_num) ? m2.version_num <=> m1.version_num : (m1.version_num ? -1 : 1)}
      @largest_version_num=@sorted[0]
    end
    @response = Response.find_by_map_id_and_version_num(@map.id,@largest_version_num.version_num)
    @modified_object = @response.id          
    get_content    
    @review_scores = Array.new
    @question_type = Array.new
    @questions.each{
      | question |
      @review_scores << Score.find_by_response_id_and_question_id(@response.id, question.id)
      @question_type << QuestionType.find_by_question_id(question.id)
    }

    #**************************** OSS CHANGE STARTS HERE ***************************************************************
    if !@role_response.nil?
          @role_map = @role_response.map
          role_array_not_empty = 0
          @role_sorted_array = Array.new
          @role_prev = Response.all
          for element in @role_prev
            if(element.map_id==@role_map.id)
              role_array_not_empty = 1
              @role_sorted_array << element
            end
          end
          if role_array_not_empty==1
            @role_sorted = @role_sorted_array.sort { |m1,m2|(m1.version_num and m2.version_num) ? m2.version_num <=> m1.version_num : (m1.version_num ? -1 : 1)}
            @role_largest_version_num = @role_sorted[0]
          end
          @role_response = Response.find_by_map_id_and_version_num(@role_map.id,@role_largest_version_num.version_num)
          @modified_role_object = @role_response.id
          @reviewed_role_ptr = TeamRole.find(params[:role_info].to_i)
          get_role_content
          @role_review_scores = Array.new
          @role_question_type = Array.new
          @role_questions.each{
              | question |
            @role_review_scores << Score.find_by_response_id_and_question_id(@role_response.id, question.id)
            @role_question_type << QuestionType.find_by_question_id(question.id)
          }
      end
    #**************************** OSS CHANGE ENDS HERE *****************************************************************



#>>>>>>> 4c68f52a7464e968a722335cb6340efbf1c65b0a
    # Check whether this is a custom rubric
    if @map.questionnaire.section.eql? "Custom"
      @next_action = "custom_update"
      render :action => 'custom_response'
    else
      # end of special code (except for the end below, to match the if above)
      #**********************
      render :action => 'response'
    end
  end
  
  def redirect_when_disallowed(response)
    # For author feedback, participants need to be able to read feedback submitted by other teammates.
    # If response is anything but author feedback, only the person who wrote feedback should be able to see it.
    if response.map.read_attribute(:type) == 'FeedbackResponseMap' && response.map.assignment.team_assignment
      team = response.map.reviewer.team
      unless team.has_user session[:user]
        redirect_to '/denied?reason=You are not on the team that wrote this feedback'
        return true
      end
    else
      return true unless current_user_id?(response.map.reviewer.user_id)
    end
    return false
  end
  
  def update
    @response = Response.find(params[:id])
    #********************************* OSS CHANGE STARTS HERE ********************************************************

     is_role_response_present = params[:role_map_id]
     if !is_role_response_present.nil?
      @role_response = Response.find(params[:role_map_id])
     else
       @role_response = nil
     end
    #********************************* OSS CHANGE ENDS HERE **********************************************************


    return if redirect_when_disallowed(@response)
    @myid = @response.id
    msg = ""
    begin 
      @myid = @response.id
      @map = @response.map
      @response.update_attribute('additional_comment',params[:review][:comments])
      
      @questionnaire = @map.questionnaire
      questions = @questionnaire.questions
     
     
      params[:responses].each_pair do |k,v|
      
        score = Score.find_by_response_id_and_question_id(@response.id, questions[k.to_i].id)
          if(score == nil)
           score = Score.create(:response_id => @response.id, :question_id => questions[k.to_i].id, :score => v[:score], :comments => v[:comment])
          end
        score.update_attribute('score',v[:score])
        score.update_attribute('comments',v[:comment])

       end

      #************************************ OSS CHANGE STARTS HERE ***********************************************
      if !@role_response.nil?

      @my_role_response_id = @role_response.id
      @map = @role_response.map
      @role_response.update_attribute('additional_comment',params[:review][:comments])

      #@questionnaire = @map.questionnaire
      #questions = @questionnaire.questions
      @reviewed_role = TeamRole.find(params[:role_reviewed_ptr])
      @role_questionnaire = Questionnaire.find(@reviewed_role.role_questionnaire_id)
      role_questions = Question.find_all_by_questionnaire_id(@role_questionnaire.id)


      params[:responses_role].each_pair do |k,v|

        role_score = Score.find_by_response_id_and_question_id(@role_response.id, role_questions[k.to_i].id)
        if(role_score == nil)
          role_score = Score.create(:response_id => @role_response.id, :question_id => role_questions[k.to_i].id, :score => v[:score], :comments => v[:comment])
        end
        role_score.update_attribute('score',v[:score])
        role_score.update_attribute('comments',v[:comment])
      end
     end
        #************************************ OSS CHANGE STARTS HERE ***********************************************

#>>>>>>> 4c68f52a7464e968a722335cb6340efbf1c65b0a
    rescue
      msg = "Your response was not saved. Cause: "+ $!
    end

    begin
       ResponseHelper.compare_scores(@response, @questionnaire)
       ScoreCache.update_cache(@response.id)
    
      msg = "Your response was successfully saved."
    rescue
      msg = "An error occurred while saving the response: "+$!
    end
    redirect_to :controller => 'response', :action => 'saving', :id => @map.id, :return => params[:return], :msg => msg
  end  
  
  def custom_update
    @response = Response.find(params[:id])
    @myid = @response.id
    msg = ""
    begin
      @myid = @response.id
      @map = @response.map
      @response.update_attribute('additional_comment',"")

      @questionnaire = @map.questionnaire
      questions = @questionnaire.questions

      for i in 0..questions.size-1
        score = Score.find_by_response_id_and_question_id(@response.id, questions[i.to_i].id)
        score.update_attribute('comments',params[:custom_response][i.to_s])
      end
    rescue
      msg = "#{@map.get_title} was not saved."
    end

    msg = "#{@map.get_title} was successfully saved."
    redirect_to :controller => 'response', :action => 'saving', :id => @map.id, :return => params[:return], :msg => msg
  end

  def new_feedback
    review = Response.find(params[:id])
    if review
      reviewer = AssignmentParticipant.find_by_user_id_and_parent_id(session[:user].id, review.map.assignment.id)
      map = FeedbackResponseMap.find_by_reviewed_object_id_and_reviewer_id(review.id, reviewer.id)
      if map.nil?
        map = FeedbackResponseMap.create(:reviewed_object_id => review.id, :reviewer_id => reviewer.id, :reviewee_id => review.map.reviewer.id)
      end
      redirect_to :action => 'new', :id => map.id, :return => "feedback"
    else
      redirect_to :back
    end
  end
  
  def view
    @response = Response.find(params[:id])

    return if redirect_when_disallowed(@response)
    @map = @response.map
    get_content


    #******************************** OSS CHANGE STARTS HERE **************************************************
    role_resp_var = params[:role_review_id]

    if !role_resp_var.nil?
       @role_response = Response.find(role_resp_var.to_i)
       @reviewed_role_ptr = TeamRole.find(params[:role_info].to_i)
    else
       @role_response = nil
    end
    #******************************** OSS CHANGE ENDS HERE ******************************************************

    return if redirect_when_disallowed(@response)
    @map = @response.map

    #******************************** OSS CHANGE STARTS HERE ***************************************************
    if !role_resp_var.nil?
      @role_map = @role_response.map
    end
    #******************************** OSS CHANGE ENDS HERE *****************************************************

    get_content

#>>>>>>> 4c68f52a7464e968a722335cb6340efbf1c65b0a
    @review_scores = Array.new
    @question_type = Array.new
    @questions.each{
      | question |
      @review_scores << Score.find_by_response_id_and_question_id(@response.id, question.id)
      @question_type << QuestionType.find_by_question_id(question.id)
    }
    #******************************** OSS CHANGE STARTS HERE ****************************************************
    if !role_resp_var.nil?
      get_role_content
      @role_review_scores = Array.new
      @role_question_type = Array.new
      @role_questions.each{
        | question |
      @role_review_scores << Score.find_by_response_id_and_question_id(@role_response.id, question.id)
      @role_question_type << QuestionType.find_by_question_id(question.id)
      }
    end
    #******************************** OSS CHANGE ENDS HERE ******************************************************

  end
  
  def new
    @header = "New"
    @next_action = "create"    
    @feedback = params[:feedback]
    @map = ResponseMap.find(params[:id])
    @return = params[:return]
    @modified_object = @map.id

    get_content  


#********************************* OSS CHANGE *******************************************************
    @modified_role_object = params[:rolemap_id]
    @reviewed_student = User.find(params[:reviewed_member])

    role_present = params[:role_info]

    if !role_present.nil?
      @reviewed_role = TeamRole.find(params[:role_info])
      @role_questionnaire = Questionnaire.find(@reviewed_role.role_questionnaire_id)
      @role_questions = Question.find_all_by_questionnaire_id(@role_questionnaire.id)
      @role_min = @role_questionnaire.min_question_score
      @role_max = @role_questionnaire.max_question_score
    else
      @reviewed_role = nil
    end
#********************************* OSS CHANGE *******************************************************

    get_content

#>>>>>>> 4c68f52a7464e968a722335cb6340efbf1c65b0a
    #**********************
    # Check whether this is a custom rubric
    if @map.questionnaire.section.eql? "Custom"
      @question_type = Array.new
      @questions.each{
        | question |
        @question_type << QuestionType.find_by_question_id(question.id)
      }
      if !@map.contributor.nil?
        if @map.assignment.team_assignment?
          team_member = TeamsUser.find_by_team_id(@map.contributor).user_id
          @topic_id = Participant.find_by_parent_id_and_user_id(@map.assignment.id,team_member).topic_id
        else
          @topic_id = Participant.find(@map.contributor).topic_id
        end
      end
      if !@topic_id.nil?
        @signedUpTopic = SignUpTopic.find(@topic_id).topic_name
      end
      @next_action = "custom_create"
      render :action => 'custom_response'
    else
      render :action => 'response'
    end
   end
  
  def create     
    @map = ResponseMap.find(params[:id])

    @res = 0
    msg = ""
    error_msg = ""
    begin

      #get all previous versions of responses for the response map.
      array_not_empty=0
      @sorted_array=Array.new

    is_role_based_review = params[:is_role_based]

    #*********************************** OSS CHANGE ********************************************
    if is_role_based_review == "YES"
      @role_map = ResponseMap.find(params[:role_map_id])
      @reviewed_role_ptr = TeamRole.find(params[:role_reviewed_ptr].to_i)
    end
    #*********************************** OSS CHANGE ********************************************

    @res = 0
    @role_res = 0
    msg = ""
    error_msg = ""

    begin
      #get all previous versions of responses for the response map.
      array_not_empty = 0
      role_array_not_empty = 0
      @sorted_array = Array.new
      @sorted_role_array = Array.new
#>>>>>>> 4c68f52a7464e968a722335cb6340efbf1c65b0a
      @prev=Response.all
      for element in @prev
        if(element.map_id==@map.id)
          array_not_empty=1
          @sorted_array << element
        end
      end

      #*********************************** OSS CHANGE STARTS HERE********************************************
      if is_role_based_review == "YES"
        for element in @prev
          if(element.map_id==@role_map.id)
            role_array_not_empty = 1
            @sorted_role_array << element
          end
        end
      end
      #*********************************** OSS CHANGE ENDS HERE ********************************************

      #if previous responses exist increment the version number.
      if array_not_empty==1
         @sorted=@sorted_array.sort { |m1,m2|(m1.version_num and m2.version_num) ? m2.version_num <=> m1.version_num : (m1.version_num ? -1 : 1)}
         @largest_version_num=@sorted[0]
         if(@largest_version_num.version_num==nil)
            @version=1
         else
            @version=@largest_version_num.version_num+1
         end

        #if no previous version is available then initial version number is 1
      else
          @version=1
      end
      #********************************** OSS CHANGE STARTS HERE *************************************************

      #if previous responses exist increment the version number.
      if is_role_based_review == "YES"
        if role_array_not_empty==1
          @sorted_role = @sorted_role_array.sort { |m1,m2|(m1.version_num and m2.version_num) ? m2.version_num <=> m1.version_num : (m1.version_num ? -1 : 1)}
          @largest_role_version_num=@sorted_role[0]
          if(@largest_role_version_num.version_num == nil)
            @role_version = 1
          else
            @role_version = @largest_role_version_num.version_num+1
          end

        #if no previous version is available then initial version number is 1
        else
          @role_version = 1
        end
      end

      #********************************** OSS CHANGE END HERE *************************************************



      @response = Response.create(:map_id => @map.id, :additional_comment => params[:review][:comments],:version_num=>@version)
      @res = @response.id
      @questionnaire = @map.questionnaire
      questions = @questionnaire.questions     
      params[:responses].each_pair do |k,v|
        score = Score.create(:response_id => @response.id, :question_id => questions[k.to_i].id, :score => v[:score], :comments => v[:comment])

      end  

      end

      #******************************** OSS CHANGE STARTS HERE************************************************
      if is_role_based_review == "YES"
        @role_response = Response.create(:map_id => @role_map.id, :additional_comment => params[:review_role][:comments],:version_num=>@role_version)
        @role_res = @role_response.id
        @role_questionnaire = Questionnaire.find(@reviewed_role_ptr.role_questionnaire_id)
        role_questions = Question.find_all_by_questionnaire_id(@role_questionnaire.id)
        params[:responses_role].each_pair do |k,v|
          score = Score.create(:response_id => @role_response.id, :question_id => role_questions[k.to_i].id, :score => v[:score], :comments => v[:comment])
        end
      end
        #******************************** OSS CHANGE ENDS HERE***************************************************

#>>>>>>> 4c68f52a7464e968a722335cb6340efbf1c65b0a
    rescue
      error_msg = "Your response was not saved. Cause: " + $!
    end
    
    begin
      ResponseHelper.compare_scores(@response, @questionnaire)
      ScoreCache.update_cache(@res)
      @map.save
      msg = "Your response was successfully saved."

    rescue
      @response.delete


    #*************************************** OSS CHANGE STARTS HERE *************************************************
      if is_role_based_review == "YES"
        ResponseHelper.compare_scores(@role_response, @role_questionnaire)
        ScoreCache.update_cache(@role_res)
        @role_map.save
        msg = "Your response was successfully saved."
      end
    #*************************************** OSS CHANGE ENDS HERE ***************************************************

    rescue
      @response.delete

    #************************************** OSS CHANGE STARTS HERE **************************************************
      if is_role_based_review == "YES"
        @role_response.delete
      end
    #************************************** OSS CHANGE ENDS HERE ***************************************************
#>>>>>>> 4c68f52a7464e968a722335cb6340efbf1c65b0a
      error_msg = "Your response was not saved. Cause: " + $!
    end
    redirect_to :controller => 'response', :action => 'saving', :id => @map.id, :return => params[:return], :msg => msg, :error_msg => error_msg
  end      
  
  def custom_create
    @map = ResponseMap.find(params[:id])
    @response = Response.create(:map_id => @map.id, :additional_comment => "")
    @res = @response.id
    @questionnaire = @map.questionnaire
    questions = @questionnaire.questions
    
    for i in 0..questions.size-1
        # Local variable score is unused; can it be removed?
        score = Score.create(:response_id => @response.id, :question_id => questions[i].id, :score => @questionnaire.max_question_score, :comments => params[:custom_response][i.to_s])
          

    end
    msg = "#{@map.get_title} was successfully saved."
    
    redirect_to :controller => 'response', :action => 'saving', :id => @map.id, :return => params[:return], :msg => msg
  end

  def saving   
    @map = ResponseMap.find(params[:id])
    @return = params[:return]
    @map.notification_accepted = false;
    puts("saving for me ")
    puts(params[:id]);
    @map.save
    
    redirect_to :action => 'redirection', :id => @map.id, :return => params[:return], :msg => params[:msg], :error_msg => params[:error_msg]
  end
  
  def redirection
    flash[:error] = params[:error_msg] unless params[:error_msg] and params[:error_msg].empty?
    flash[:note]  = params[:msg] unless params[:msg] and params[:msg].empty?
    
    @map = ResponseMap.find(params[:id])
    if params[:return] == "feedback"
      redirect_to :controller => 'grades', :action => 'view_my_scores', :id => @map.reviewer.id
    elsif params[:return] == "teammate"
      redirect_to :controller => 'student_team', :action => 'view', :id => @map.reviewer.id
    elsif params[:return] == "instructor"
      redirect_to :controller => 'grades', :action => 'view', :id => @map.assignment.id
    else
      redirect_to :controller => 'student_review', :action => 'list', :id => @map.reviewer.id
    end 
  end
  
  private
    
  def get_content    
    @title = @map.get_title 
    @assignment = @map.assignment
    @participant = @map.reviewer
    @contributor = @map.contributor
    @questionnaire = @map.questionnaire
    @questions = @questionnaire.questions
    @min = @questionnaire.min_question_score
    @max = @questionnaire.max_question_score     
  end


  #***************************** OSS CHANGE STARTS HERE ********************************************************
  def get_role_content
    @role_title = @role_map.get_title
    @role_assignment = @role_map.assignment
    @role_participant = @role_map.reviewer
    @role_contributor = @role_map.contributor
    #@role_questionnaire = @role_map.questionnaire
    #@role_questions = @role_questionnaire.questions
    @role_res = @role_response.id
    @role_questionnaire = Questionnaire.find(@reviewed_role_ptr.role_questionnaire_id)
    @role_questions = Question.find_all_by_questionnaire_id(@role_questionnaire.id)
    @role_min = @role_questionnaire.min_question_score
    @role_max = @role_questionnaire.max_question_score
  end
  #***************************** OSS CHANGE ENDS HERE ********************************************************

#>>>>>>> 4c68f52a7464e968a722335cb6340efbf1c65b0a
  
  def redirect_when_disallowed(response)
    # For author feedback, participants need to be able to read feedback submitted by other teammates.
    # If response is anything but author feedback, only the person who wrote feedback should be able to see it.
    if response.map.read_attribute(:type) == 'FeedbackResponseMap' && response.map.assignment.team_assignment
      team = response.map.reviewer.team
      unless team.has_user session[:user]
        redirect_to '/denied?reason=You are not on the team that wrote this feedback'
        return true
      end
    else
      return true unless current_user_id?(response.map.reviewer.user_id)
    end
    return false
  end
end
