class ReportsController < ApplicationController
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::DateHelper

  #  require 'rubygems'
  #  require 'simple_xlsx'
  before_filter :require_admin
  before_filter { |c| c.active_tab=:reporting_tab }

  def index_old # TODO [11/23/10 12:22 AM] => EXTRA CODE
    return render :json => params
    @start_date = User.first(:order => 'created_at asc').created_at.to_date
    @end_date = Date.today - 1.month
    if params[:report] == 'registration'
      @type_heading = "REGISTRATION USER REPORT"
      @type_text_year = 'Wicked Start User Registration Report Year Ending'
      @type_text_month = 'Wicked Start User Registration Report Month Ending'
      @type = 'registration'
    elsif params[:report] == 'subscription'
      @type_heading = "SUBSCRIPTION USER REPORT"
      @type_text_year = 'Wicked Start User Subscription Report Year Ending'
      @type_text_month = 'Wicked Start User Subscription Report Month Ending'
      @path = ''
      @type = 'subscription'
    elsif params[:report] == 'search_term'
      @type_heading = "SEARCH TERM USER REPORT"
      @type_text_year = 'Wicked Start Search Term Report Year Ending'
      @type_text_month = 'Wicked Start Search Term Report Month Ending'
      @path = ''
      @type = 'search_term'
    elsif params[:report] == 'repository_usage'
      @type_heading = "REOISITORY USAGE REPORT"
      @type_text_year = 'Wicked Start Repository Usage  Report Year Ending'
      @type_text_month = 'Wicked Start Repository Usage  Report Month Ending'
      @path = ''
      @type = 'repository_usage'
    elsif params[:report] == 'checklist_usage'
      @type_heading = "CHECKLIST USAGE REPORT"
      @type_text_year = 'Wicked Start Check List Usage Report Year Ending'
      @type_text_month = 'Wicked Start Check List Usage Report Month Ending'
      @path = ''
      @type = 'checklist_usage'
    end
  end

  def index
    @report_category = params[:report_category]
    if(REPORTING_CATEGORIES.include?(@report_category))
      @title = REPORTING_TITLES[@report_category]
      @start_date = Date.parse(REPORTING_START_DATE_STRING)
      @end_date = Date.today - Date.today.day
      @dir = Rails.root.join("assets", "reports", @report_category, "standard")
    else
      @report_category = nil
      @report_titles = REPORTING_TITLES
    end
    #    return render :json => [params, "DON", @report_category, @dir]
  end

  def show
    #    return render :json => params
    year = params[:id].split("-")[0]
    month = Date::MONTHNAMES[params[:id].split("-")[1].to_i]
    file_name = "#{REPORTING_TITLES[params[:report_category]].split(" ").join("_")}_Report_#{year}_#{month}.xlsx"
    dir = Rails.root.join("assets", "reports", params[:report_category], "standard")
    if( REPORTING_CATEGORIES.include?(params[:report_category]) && File.file?(dir.join(year, "#{month}.xlsx")) )
      send_file(dir.join(year, "#{month}.xlsx"), :filename => file_name)
    else
      flash[:error] = "The file you requested could not be found on the server"
      return redirect_to :action => 'index'
    end
  end

  def adhoc
    start_date  = Date.civil(params[:report]['start_date(1i)'].to_i, params[:report]['start_date(2i)'].to_i, params[:report]['start_date(3i)'].to_i )
    end_date    = Date.civil(params[:report]['end_date(1i)'].to_i, params[:report]['end_date(2i)'].to_i, params[:report]['end_date(3i)'].to_i )
    #    return render :json => [params, start_date, end_date]
    @report_category = params[:report_category]
    #    if(['search_term', 'repository_usage', 'checklist_usage'].include?(params[:report_category]))
    if(REPORTING_CATEGORIES.include?(params[:report_category]))
      #      send_file(send("adhoc_"+@report_category, start_date, end_date))
      file_name = "#{REPORTING_TITLES[params[:report_category]].split(" ").join("_")}_Report_#{start_date.to_s}_to_#{end_date.to_s}.xlsx"
      tmp_file_path = Rails.root.join("tmp", "reports", file_name)
      adhoc_file_path = Rails.root.join("assets", "reports", params[:report_category], "adhoc", "#{start_date.to_s}_to_#{end_date.to_s}.xlsx")
      FileUtils.mkdir_p(adhoc_file_path.dirname) unless File.directory?(adhoc_file_path.dirname)
      FileUtils.mkdir_p(tmp_file_path.dirname) unless File.directory?(tmp_file_path.dirname)
      if File.file?(adhoc_file_path)
        FileUtils.cp(adhoc_file_path, tmp_file_path)
        send_file(tmp_file_path, :stream => false)
        FileUtils.rm(tmp_file_path)
      else
        send("adhoc_"+@report_category, start_date, end_date, tmp_file_path)
        #        FileUtils.cp(tmp_file_path, adhoc_file_path)   # DONOT SAVE ADHOC FOR RUNTIME RESULTS
        send_file(tmp_file_path, :stream => false)
        FileUtils.rm(tmp_file_path)
      end
      #    elsif(['registration', 'subscription'].include?(@report_category))
      #      params[:report][:"from(1i)"] = params[:report][:"start_date(1i)"]
      #      params[:report][:"from(2i)"] = params[:report][:"start_date(2i)"]
      #      params[:report][:"from(3i)"] = params[:report][:"start_date(3i)"]
      #      params[:report][:"to(1i)"] = params[:report][:"end_date(1i)"]
      #      params[:report][:"to(2i)"] = params[:report][:"end_date(2i)"]
      #      params[:report][:"to(3i)"] = params[:report][:"end_date(3i)"]
      #      send(params[:report_category])
    else
      flash[:error] = "The file you requested could not be found on the server"
      return redirect_to :action => 'index'
    end
  end

  # TODO [11/23/10 12:12 AM] => EXTRA CODE START
  def registration
    if params[:report].blank?
      if params[:year] == 0.to_s
        start_date = params[:date].to_date.last_month.end_of_month + 1.day
        end_date = start_date + 1.month - 1.day
      else
        start_date = Date.new(params[:date].to_date.year)
        end_date = start_date + 1.year - 1.day
      end
    else
      if (params[:report][:'to(1i)'].blank? || params[:report][:'to(2i)'].blank? || params[:report][:'to(3i)'].blank?) || (params[:report][:'from(1i)'].blank? || params[:report][:'from(2i)'].blank? || params[:report][:'from(3i)'].blank?)
        flash[:notice] = 'Day, month or year cant be blank'
        return redirect_to reports_path + '?report=registration' # TODO [11/6/10 4:17 PM] => CHECK_IT
      end
      start_date = Date.new(params[:report][:'from(1i)'].to_i,params[:report][:'from(2i)'].to_i,params[:report][:'from(3i)'].to_i)
      end_date = Date.new(params[:report][:'to(1i)'].to_i,params[:report][:'to(2i)'].to_i,params[:report][:'to(3i)'].to_i)
    end
    file_path = Rails.root.join("assets", "reports", "registration", "adhoc", "#{start_date.to_s}_to_#{end_date.to_s}.xlsx")
    adhoc_registration(start_date, end_date, file_path)
    send_file file_path
  end

  def subscription
    if params[:report].blank?
      if params[:year] == 0.to_s
        start_date = params[:date].to_date.last_month.end_of_month + 1.day
        end_date = start_date + 1.month - 1.day
      else
        start_date = Date.new(params[:date].to_date.year)
        end_date = start_date + 1.year - 1.day
      end
    else
      if (params[:report][:'to(1i)'].blank? || params[:report][:'to(2i)'].blank? || params[:report][:'to(3i)'].blank?) || (params[:report][:'from(1i)'].blank? || params[:report][:'from(2i)'].blank? || params[:report][:'from(3i)'].blank?)
        flash[:notice] = 'Day, month or year cant be blank'
        return redirect_to reports_path + '?report=subscription'  # TODO [11/6/10 4:16 PM] => CHECK_IT
      end
      start_date = Date.new(params[:report][:'from(1i)'].to_i,params[:report][:'from(2i)'].to_i,params[:report][:'from(3i)'].to_i)
      end_date = Date.new(params[:report][:'to(1i)'].to_i,params[:report][:'to(2i)'].to_i,params[:report][:'to(3i)'].to_i)
    end
    file_path = Rails.root.join("assets", "reports", "subscription", "adhoc", "#{start_date.to_s}_to_#{end_date.to_s}.xlsx")
    adhoc_subscription(start_date, end_date, file_path)
    send_file file_path
  end

  def search_term
    start_date  = Date.civil(params[:report]['start_date(1i)'].to_i, params[:report]['start_date(2i)'].to_i, params[:report]['start_date(3i)'].to_i )
    end_date    = Date.civil(params[:report]['end_date(1i)'].to_i, params[:report]['end_date(2i)'].to_i, params[:report]['end_date(3i)'].to_i )
    #    return render :json => [params, start_date, end_date]
    #    send_file(adhoc_search_terms(start_date, end_date))
    file_path = Rails.root.join("assets", "reports", "search_terms", "adhoc", "#{start_date.to_s}_to_#{end_date.to_s}.xlsx")
    adhoc_search_terms(start_date, end_date, file_path)
    send_file file_path
  end

  def checklist_usage
    start_date  = Date.civil(params[:report]['start_date(1i)'].to_i, params[:report]['start_date(2i)'].to_i, params[:report]['start_date(3i)'].to_i )
    end_date    = Date.civil(params[:report]['end_date(1i)'].to_i, params[:report]['end_date(2i)'].to_i, params[:report]['end_date(3i)'].to_i )
    file_path = Rails.root.join("assets", "reports", "checklist_usage", "adhoc", "#{start_date.to_s}_to_#{end_date.to_s}.xlsx")
    adhoc_checklist_usage(start_date, end_date, file_path)
    send_file file_path
  end

  def repository_usage
    start_date  = Date.civil(params[:report]['start_date(1i)'].to_i, params[:report]['start_date(2i)'].to_i, params[:report]['start_date(3i)'].to_i )
    end_date    = Date.civil(params[:report]['end_date(1i)'].to_i, params[:report]['end_date(2i)'].to_i, params[:report]['end_date(3i)'].to_i )
    #    return render :json => [params, start_date, end_date]
    #    send_file(adhoc_repository_usage(start_date, end_date))
    file_path = Rails.root.join("assets", "reports", "repository_usage", "adhoc", "#{start_date.to_s}_to_#{end_date.to_s}.xlsx")
    adhoc_repository_usage(start_date, end_date, file_path)
    send_file file_path
  end
  # TODO [11/23/10 12:12 AM] => EXTRA CODE END


  private
  def adhoc_registration(start_date, end_date, file_path)
    @users_time_span_dump = User.find(:all, :conditions => ["registration_date >= ? AND registration_date <= ?", start_date.beginning_of_day, end_date.end_of_day ])
    #    tim_stmp = Time.now
    start_date_ytd = Date.new(start_date.year)
    @users_all = User.all
    @users_time_span = User.find(:all, :conditions => ["created_at >= ? AND created_at < ?", start_date, end_date + 1.day ])
    @users_ytd = User.find(:all, :conditions => ["created_at >= ? AND created_at < ?", start_date_ytd, end_date + 1.day ])
    #    SimpleXlsx::Serializer.new("./temp/user_registration_summary_report#{tim_stmp}.xlsx") do |doc|
    SimpleXlsx::Serializer.new(file_path) do |doc|
      doc.add_sheet("Registered User Report") do |sheet|
        sheet.add_row(["Reporting Period From: #{start_date.strftime("%d %B, %Y")}   To: #{end_date.strftime("%d %B, %Y")}"])
        sheet.add_row(%w{ID FirstName LastName Email FirstTime BusinessName Industry UserName Wibo_Affiliation Registration_Date Is_Blocked Cancellation_Date ReactivationDate TotalPaid Last_Logged_In_At})
        @users_time_span_dump.each do |user|
          sheet.add_row([user.id,
              user.first_name,
              user.last_name,
              user.email,
              user.is_first_time,
              user.business_name,
              (user.industry)?user.industry.title : '',
              user.login,
              user.nyu_affiliation,
              user.registration_date.to_date,
              user.is_blocked,
              user.expire_date,
              user.reactivation_date,
              user.amount_paid,
              (user.current_login_at.to_date rescue '')
            ])
        end
      end
      #      Summary sheet
      doc.add_sheet("Registered User Summary Report") do |sheet|
        sheet.add_row(["Reporting Period From: #{start_date.strftime("%d %B, %Y")}   To: #{end_date.strftime("%d %B, %Y")}"])
        sheet.add_row(%w{Registered_Users Total Total Total YTD YTD YTD Reporting_period Reporting_period Reporting_period })

        usrs_all = @users_all.reject{|usr| !(usr.is_blocked == nil || usr.is_blocked == 0) }
        usrs_ytd = @users_ytd.reject{|usr| !(usr.is_blocked == nil || usr.is_blocked == 0) }
        usrs_time_span = @users_time_span.reject{|usr| !(usr.is_blocked == nil || usr.is_blocked == 0) }

        sum_percent_total = usrs_all.size.to_f/@users_all.size.to_f * 100
        sum_percent_ytd = usrs_ytd.size.to_f/@users_all.size.to_f * 100
        sum_percent_span = usrs_time_span.size.to_f/@users_all.size.to_f * 100

        sheet.add_row(['Users', usrs_all.size, usrs_all.size.to_f/@users_all.size.to_f * 100, usrs_all.collect{|usr| (usr.amount_paid)? usr.amount_paid : 0 }.sum,
            usrs_ytd.size, usrs_ytd.size.to_f/@users_all.size.to_f * 100, usrs_ytd.collect{|usr| (usr.amount_paid)? usr.amount_paid : 0 }.sum,
            usrs_time_span.size, usrs_time_span.size.to_f/@users_all.size.to_f * 100, usrs_time_span.collect{|usr| (usr.amount_paid)? usr.amount_paid : 0 }.sum
          ])

        usrs_all = @users_all.reject{|usr| (usr.is_blocked == nil || usr.is_blocked == 0) }
        usrs_ytd = @users_ytd.reject{|usr| (usr.is_blocked == nil || usr.is_blocked == 0) }
        usrs_time_span = @users_time_span.reject{|usr| (usr.is_blocked == nil || usr.is_blocked == 0) }

        sum_percent_total += usrs_all.size.to_f/@users_all.size.to_f * 100
        sum_percent_ytd += usrs_ytd.size.to_f/@users_all.size.to_f * 100
        sum_percent_span += usrs_time_span.size.to_f/@users_all.size.to_f * 100

        sheet.add_row(['InActive_Users', usrs_all.size, usrs_all.size.to_f/@users_all.size.to_f * 100, usrs_all.collect{|usr| (usr.amount_paid)? usr.amount_paid : 0 }.sum,
            usrs_ytd.size, usrs_ytd.size.to_f/@users_all.size.to_f * 100, usrs_ytd.collect{|usr| (usr.amount_paid)? usr.amount_paid : 0 }.sum,
            usrs_time_span.size, usrs_time_span.size.to_f/@users_all.size.to_f * 100, usrs_time_span.collect{|usr| (usr.amount_paid)? usr.amount_paid : 0 }.sum
          ])

        sheet.add_row(['Total', @users_all.size, sum_percent_total, @users_all.collect{|usr| (usr.amount_paid)? usr.amount_paid : 0 }.sum,
            @users_ytd.size, sum_percent_ytd, @users_ytd.collect{|usr| (usr.amount_paid)? usr.amount_paid : 0 }.sum,
            @users_time_span.size, sum_percent_span, @users_time_span.collect{|usr| (usr.amount_paid)? usr.amount_paid : 0 }.sum
          ])

        sum_percent_total = 0.0
        sum_percent_ytd = 0.0
        sum_percent_span = 0.0

        #        industry block
        sheet.add_row(%w{})
        sheet.add_row(%w{Registered_Users_By_industry Total Total Total YTD YTD YTD Reporting_period Reporting_period Reporting_period })

        industries = Industry.all
        industries.each do |industry|
          usrs_all = @users_all.reject{|usr| !(usr.industry_id == industry.id) }
          usrs_ytd = @users_ytd.reject{|usr| !(usr.industry_id == industry.id) }
          usrs_time_span = @users_time_span.reject{|usr| !(usr.industry_id == industry.id) }

          percent_total = usrs_all.size.to_f/@users_all.size.to_f * 100
          percent_ytd = usrs_ytd.size.to_f/@users_all.size.to_f * 100
          percent_span =  usrs_time_span.size.to_f/@users_all.size.to_f * 100

          sum_percent_total += percent_total
          sum_percent_ytd += percent_ytd
          sum_percent_span += percent_span

          sheet.add_row([industry.title,
              usrs_all.size,
              percent_total,
              usrs_all.collect{|usr| (usr.amount_paid)? usr.amount_paid : 0 }.sum,
              usrs_ytd.size,
              percent_ytd,
              usrs_ytd.collect{|usr| (usr.amount_paid)? usr.amount_paid : 0 }.sum,
              usrs_time_span.size,
              percent_span,
              usrs_time_span.collect{|usr| (usr.amount_paid)? usr.amount_paid : 0 }.sum
            ])
        end
        #        sheet.add_row(%w{Total N0. % Total_Value N0. % Total_Value N0. % Total_Value })
        sheet.add_row(['Total', @users_all.size, sum_percent_total, @users_all.collect{|usr| (usr.amount_paid)? usr.amount_paid : 0 }.sum,
            @users_ytd.size, sum_percent_ytd, @users_ytd.collect{|usr| (usr.amount_paid)? usr.amount_paid : 0 }.sum,
            @users_time_span.size, sum_percent_span, @users_time_span.collect{|usr| (usr.amount_paid)? usr.amount_paid : 0 }.sum
          ])

        sum_percent_total = 0.0
        sum_percent_ytd = 0.0
        sum_percent_span = 0.0
        #        gender block
        sheet.add_row(%w{})
        sheet.add_row(%w{Registered_Users_By_Gender Total Total Total YTD YTD YTD Reporting_period Reporting_period Reporting_period })
        #        sheet.add_row(%w{Industry N0. % Total_Value N0. % Total_Value N0. % Total_Value })

        genders = ['m','f']
        genders.each do |gender|
          usrs_all = @users_all.reject{|usr| !(usr.gender == gender) }
          usrs_ytd = @users_ytd.reject{|usr| !(usr.gender == gender) }
          usrs_time_span = @users_time_span.reject{|usr| !(usr.gender == gender) }

          percent_total = usrs_all.size.to_f/@users_all.size.to_f * 100
          percent_ytd = usrs_ytd.size.to_f/@users_all.size.to_f * 100
          percent_span =  usrs_time_span.size.to_f/@users_all.size.to_f * 100

          sum_percent_total += percent_total
          sum_percent_ytd += percent_ytd
          sum_percent_span += percent_span

          sheet.add_row([
              (gender == 'm')?'Male':'Female',
              usrs_all.size,
              percent_total,
              usrs_all.collect{|usr| (usr.amount_paid)? usr.amount_paid : 0 }.sum,
              usrs_ytd.size,
              percent_ytd,
              usrs_ytd.collect{|usr| (usr.amount_paid)? usr.amount_paid : 0 }.sum,
              usrs_time_span.size,
              percent_span,
              usrs_time_span.collect{|usr| (usr.amount_paid)? usr.amount_paid : 0 }.sum
            ])
        end

        #        sheet.add_row(%w{Total N0. % Total_Value N0. % Total_Value N0. % Total_Value })
        sheet.add_row(['Total', @users_all.size, sum_percent_total, @users_all.collect{|usr| (usr.amount_paid)? usr.amount_paid : 0 }.sum,
            @users_ytd.size, sum_percent_ytd, @users_ytd.collect{|usr| (usr.amount_paid)? usr.amount_paid : 0 }.sum,
            @users_time_span.size, sum_percent_span, @users_time_span.collect{|usr| (usr.amount_paid)? usr.amount_paid : 0 }.sum
          ])

        sum_percent_total = 0.0
        sum_percent_ytd = 0.0
        sum_percent_span = 0.0
        #        experience block
        sheet.add_row(%w{})
        sheet.add_row(%w{Registered_Users_By_Experience Total Total Total YTD YTD YTD Reporting_period Reporting_period Reporting_period })
        #        sheet.add_row(%w{Industry N0. % Total_Value N0. % Total_Value N0. % Total_Value })

        first_time = ['y','n']
        first_time.each do |first_time|
          usrs_all = @users_all.reject{|usr| !(usr.is_first_time == first_time) }
          usrs_ytd = @users_ytd.reject{|usr| !(usr.is_first_time == first_time) }
          usrs_time_span = @users_time_span.reject{|usr| !(usr.is_first_time == first_time) }

          percent_total = usrs_all.size.to_f/@users_all.size.to_f * 100
          percent_ytd = usrs_ytd.size.to_f/@users_all.size.to_f * 100
          percent_span =  usrs_time_span.size.to_f/@users_all.size.to_f * 100

          sum_percent_total += percent_total
          sum_percent_ytd += percent_ytd
          sum_percent_span += percent_span

          sheet.add_row([
              (first_time == 'y')?'Yes, this is first time':'No, not first time',
              usrs_all.size,
              percent_total,
              usrs_all.collect{|usr| (usr.amount_paid)? usr.amount_paid : 0 }.sum,
              usrs_ytd.size,
              percent_ytd,
              usrs_ytd.collect{|usr| (usr.amount_paid)? usr.amount_paid : 0 }.sum,
              usrs_time_span.size,
              percent_span,
              usrs_time_span.collect{|usr| (usr.amount_paid)? usr.amount_paid : 0 }.sum
            ])
        end

        #        sheet.add_row(%w{Total N0. % Total_Value N0. % Total_Value N0. % Total_Value })
        sheet.add_row(['Total', @users_all.size, sum_percent_total, @users_all.collect{|usr| (usr.amount_paid)? usr.amount_paid : 0 }.sum,
            @users_ytd.size, sum_percent_ytd, @users_ytd.collect{|usr| (usr.amount_paid)? usr.amount_paid : 0 }.sum,
            @users_time_span.size, sum_percent_span, @users_time_span.collect{|usr| (usr.amount_paid)? usr.amount_paid : 0 }.sum
          ])

      end
    end unless File.file?(file_path)
    #    send_file ("./temp/user_registration_summary_report#{tim_stmp}.xlsx")
  end
  
  def adhoc_mentor(start_date, end_date, file_path)
    @mentors_time_span_dump = Mentor.find(:all, :conditions => ["created_at >= ? AND created_at < ?", start_date, end_date + 1.day ])
    xl = SimpleXlsx::Serializer.new(file_path) do |doc|      
      doc.add_sheet("Mentors Report") do |sheet|
        sheet.add_row('')
        sheet.add_row('')
        sheet.add_row('')
        sheet.add_row('')
        sheet.add_row(["","","","","","","Mentor Last, First","Mentor Industry","Note","User (Enterpreneur) Last, First", "User Industry", "Date of Association"])
        sheet.add_row('')
        @mentors_time_span_dump.each do |mentor|
          users = User.find(:all, :select => "users.first_name, users.last_name, users.mentor_assignment_date, industries.title", :joins=>"INNER JOIN industries ON users.industry_id=industries.id", :conditions=>["users.mentor_id=?", mentor.id])
          unless users.blank?
            users.each_with_index do |user, index|
              if index==0
                sheet.add_row(["","","","","","",
                    "#{mentor.last_name}, #{mentor.first_name}",
                    mentor.industries.map(&:title).join(', '),                
                    mentor.note,
                    "#{user.last_name}, #{user.first_name}",
                    user.title,
                    user.mentor_assignment_date.to_date.to_s

                  ])
              else
                sheet.add_row(["","","","","","",
                    "",
                    "",                
                    "",
                    "#{user.last_name}, #{user.first_name}",
                    user.title,
                    user.mentor_assignment_date.to_date.to_s

                  ])
              end                           
            end    
          else
            sheet.add_row(["","","","","","",
                "#{mentor.last_name}, #{mentor.first_name}",
                mentor.industries.map(&:title),                
                mentor.note
              ])
          end
        end
      end
      #   unless File.file?(file_path)
    end
  end

  def adhoc_subscription(start_date, end_date, file_path)
    start_date_ytd = Date.new(start_date.year)
    @transactions_all = TransactionLog.all
    @transactions_time_span = TransactionLog.find(:all, :conditions => ["created_at >= ? AND created_at < ?", start_date, end_date + 1.day ])
    @transactions_ytd = TransactionLog.find(:all, :conditions => ["created_at >= ? AND created_at < ?", start_date_ytd, end_date + 1.day  ])
    @users_all = User.all
    @users_time_span = User.find(:all, :conditions => ["created_at >= ? AND created_at < ?", start_date, end_date + 1.day  ])
    @users_ytd = User.find(:all, :conditions => ["created_at >= ? AND created_at < ?", start_date_ytd, end_date + 1.day  ])
    @users_last_yr_span = User.find(:all, :conditions => ["created_at >= ? AND created_at < ?", start_date - 1.year, end_date + 1.day - 1.year ])
    @users_last_yr_ytd = User.find(:all, :conditions => ["created_at >= ? AND created_at < ?", start_date_ytd -1.year, end_date + 1.day - 1.year ])
    #    tim_stmp = Time.now
    #    SimpleXlsx::Serializer.new("./temp/user_subscription_report#{tim_stmp}.xlsx") do |doc|
    SimpleXlsx::Serializer.new(file_path) do |doc|
      doc.add_sheet("Subscription Detail") do |sheet|
        sheet.add_row(["Reporting Period From: #{start_date.strftime("%d %B, %Y")}   To: #{end_date.strftime("%d %B, %Y")}"])
        sheet.add_row(%w{ID Email Activity Activity_Date Package Start_Date End_Date Is_WickedStart SubscriptionID Status TransactionDate Amount})
        @transactions_all.each do |trnsaction|
          sheet.add_row([
              trnsaction.user_id,
              trnsaction.email,
              trnsaction.activity,
              trnsaction.activity_date,
              trnsaction.package_name,
              trnsaction.subscription_start_date,
              trnsaction.subscription_end_date,
              trnsaction.is_wickedstart,
              trnsaction.transaction_id,
              trnsaction.transaction_status,
              trnsaction.created_at.to_date,
              trnsaction.amount
            ])
        end
      end
      sum_reporting_period = 0.0
      sum_ytd = 0.0
      sum_all = 0.0

      amount_all = 0.0
      amount_ytd = 0.0
      amount_reporting_period = 0.0

      promo_codes = []
      PromoCode.all.collect do |pcode|
        promo_codes << [pcode.code]
      end

      codes_names = []
      codes_names << PromoCode.all(:select => :code).collect{|pcode| pcode.code}
      codes_names << 'New Accounts'
      codes_names.flatten!
      promo_codes << PromoCode.all(:select => :code).collect{|pcode| pcode.code}
      #      accounts_types = ['New Account', 'Existing Accounts', 'Cancelled Accounts']
      doc.add_sheet("Subscriptions") do |sheet|
        sheet.add_row(["Reporting Period From: #{start_date.strftime("%d %B, %Y")}   To: #{end_date.strftime("%d %B, %Y")}"])
        sheet.add_row(['', 'Reporting Period', 'Reporting Period', 'Reporting Period', 'YTD', 'YTD ', 'YTD', 'Total', 'Total'])
        counter = 0
        promo_codes.each do |code|
          sheet.add_row([codes_names[counter],
              temp = @users_time_span.select{ |usr| code.include?(usr.promo_code.code) }.size,
              amount_reporting_period = @transactions_time_span.select{ |trans| (trans.activity == 'registration_fee' && code.include?(trans.package_name))}.collect{ |tr| tr.amount}.sum,
              (@users_last_yr_span.size == 0)?'no past data' : (((temp - @users_last_yr_span.size)/@users_last_yr_span.size)*100).to_s + '%' ,
              @users_ytd.select{ |usr| code.include?(usr.promo_code.code) }.size,
              amount_ytd = @transactions_ytd.select{ |trans| (trans.activity == 'registration_fee' && code.include?(trans.package_name))}.collect{ |tr| tr.amount}.sum,
              (@users_last_yr_ytd.size == 0)?'no past data' : (((temp - @users_last_yr_ytd.size)/@users_last_yr_ytd.size)*100).to_s + '%' ,
              @users_all.select{ |usr| code.include?(usr.promo_code.code) }.size,
              amount_all = @transactions_all.select{ |trans| (trans.activity == 'registration_fee' && code.include?(trans.package_name))}.collect{ |tr| tr.amount}.sum
            ])
          counter += 1
        end
        counter = 0
        codes_names[-1] = 'Existing Accounts'
        sum_reporting_period += amount_reporting_period
        sum_ytd += amount_ytd
        sum_all += amount_all

        existing_acccounts_span = @users_all.reject{ |usr| !(usr.created_at < start_date - 1.year) }.size
        existing_acccounts_ytd = @users_all.reject{ |usr| !(usr.created_at < start_date_ytd - 1.year) }.size
        #        return render :text =>.inspect
        promo_codes.each do |code|
          sheet.add_row([codes_names[counter],
              temp = @users_all.select{ |usr| (usr.created_at < start_date) && code.include?(usr.promo_code.code) }.size,
              amount_reporting_period = @transactions_time_span.select{ |trans| (trans.activity != 'registration_fee' && code.include?(trans.package_name))}.collect{ |tr| tr.amount}.sum,
              (existing_acccounts_span == 0)?'no past data':(((temp - existing_acccounts_span)/existing_acccounts_span)*100).to_s + '%',
              temp = @users_all.select{ |usr| (usr.created_at < start_date_ytd) && code.include?(usr.promo_code.code) }.size,
              amount_ytd = @transactions_ytd.select{ |trans| (trans.activity != 'registration_fee' && code.include?(trans.package_name))}.collect{ |tr| tr.amount}.sum,
              (existing_acccounts_ytd == 0)?'no past data':(((temp - existing_acccounts_ytd)/existing_acccounts_ytd)*100).to_s + '%',
              @users_all.select{ |usr| (usr.is_blocked == 0) && code.include?(usr.promo_code.code) }.size,
              amount_all = @transactions_all.select{ |trans| (trans.activity != 'registration_fee' && code.include?(trans.package_name))}.collect{ |tr| tr.amount}.sum
            ])
          counter += 1
        end
        sum_reporting_period += amount_reporting_period
        sum_ytd += amount_ytd
        sum_all += amount_all

        counter = 0
        codes_names[-1] = 'Cancelled Accounts'
        promo_codes.each do |code|
          sum_cancelled_accounts_span = TransactionLog.find(:all, :conditions => ["(created_at >= ? AND created_at < ?) AND (activity =  ? ) AND (package_name IN (?))", start_date - 1.year, end_date + 1.month - 1.year, 'cancellation', code ]).size
          sum_cancelled_accounts_ytd = temp = TransactionLog.find(:all, :conditions => ["(created_at >= ? AND created_at < ?) AND (activity =  ? ) AND (package_name IN (?))", start_date_ytd - 1.year, end_date + 1.month - 1.year, 'cancellation', code ]).size
          sheet.add_row([codes_names[counter],
              temp = TransactionLog.find(:all, :conditions => ["(created_at >= ? AND created_at < ?) AND (activity =  ? ) AND (package_name IN (?) )", start_date, end_date + 1.month, 'cancellation', code ]).size,
              0,
              (sum_cancelled_accounts_span == 0)?'no past data':(((temp - sum_cancelled_accounts_span)/sum_cancelled_accounts_span)*100).to_s + '%',
              temp = TransactionLog.find(:all, :conditions => ["(created_at >= ? AND created_at < ?) AND (activity =  ? AND (package_name IN (?) ))", start_date_ytd, end_date + 1.month, 'cancellation', code ]).size,
              0,
              (sum_cancelled_accounts_ytd == 0)?'no past data':(((temp - sum_cancelled_accounts_ytd)/sum_cancelled_accounts_ytd)*100).to_s + '%',
              #            @users_all.reject{ |usr| !(usr.is_blocked == true) }.size,
              TransactionLog.find(:all, :conditions => ["activity =  ? AND (package_name IN (?))", 'cancellation', code]).size,
              0
            ])
          counter += 1
        end
        sheet.add_row([
            'Total', '', sum_reporting_period, '', '', sum_ytd, '', '', sum_all
          ])
        sheet.add_row(%w{})
        sheet.add_row(['Revenue', 'Jan', 'Feb', 'March', 'April', 'May', 'Jun', 'Jul' , 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', 'Total'])
        counter = 0
        codes_names[-1] = 'No. of New Accounts'
        new_accounts = []
        new_accounts_all = []
        promo_codes.each do |code|
          month_start = Date.new(Date.today.year)
          new_accounts = []
          (12).times do |i|
            new_accounts << User.find(:all, :conditions => ["created_at >= ? AND created_at < ? ", month_start, month_start + 1.month]).select{|usr| code.include?(usr.promo_code.code)}.size
            month_start += 1.month
          end
          sheet.add_row([codes_names[counter], new_accounts, new_accounts.sum].flatten)
          new_accounts_all << new_accounts
          counter += 1
        end

        counter = 0
        codes_names[-1] = 'No. of Renewed Accounts'
        renewed_accounts = []
        renewed_accounts_all = []
        promo_codes.each do |code|
          month_start = Date.new(Date.today.year)
          renewed_accounts = []
          (12).times do |i|
            renewed_accounts << TransactionLog.find(:all, :conditions => ["(created_at >= ? AND created_at < ?) AND (activity !=  ? || activity != ?) AND package_name IN (?)", month_start, month_start + 1.month, 'registration_fee', 'cancellation', code ]).size
            month_start += 1.month
          end
          sheet.add_row([codes_names[counter], renewed_accounts, renewed_accounts.sum].flatten)
          renewed_accounts_all << renewed_accounts

          counter += 1
        end

        counter = 0
        codes_names[-1] = 'No. of Cancelled Accounts'
        cancelled_accounts = []
        cancelled_accounts_all = []
        promo_codes.each do |code|
          month_start = Date.new(Date.today.year)
          cancelled_accounts = []
          (12).times do |i|
            cancelled_accounts << TransactionLog.find(:all, :conditions => ["(created_at >= ? AND created_at < ?) AND (activity =  ? ) AND package_name IN (?)", month_start, month_start + 1.month, 'cancellation', code ]).size
            month_start += 1.month
          end
          sheet.add_row([codes_names[counter], cancelled_accounts, cancelled_accounts.sum].flatten)
          cancelled_accounts_all << cancelled_accounts
          counter += 1
        end

        counter = 0
        codes_names[-1] = 'Revenue from New Accounts'
        revenue_new_accounts = []
        promo_codes.each do |code|
          month_start = Date.new(Date.today.year)
          revenue_new_accounts = []
          (12).times do |i|
            revenue_new_accounts << TransactionLog.find(:all, :conditions => ["(created_at >= ? AND created_at < ?) AND (activity =  ? ) AND package_name IN (?)", month_start, month_start + 1.month, 'registration_fee', code ]).collect{ |tr| tr.amount}.sum
            month_start += 1.month
          end
          sheet.add_row([codes_names[counter], revenue_new_accounts.collect{|amnt| amnt.to_s + '$'}, revenue_new_accounts.sum.to_s + '$'].flatten)
          counter += 1
        end

        counter = 0
        codes_names[-1] = 'Revenue from Renewed Accounts'
        revenue_renewed_accounts = []
        promo_codes.each do |code|
          month_start = Date.new(Date.today.year)
          revenue_renewed_accounts = []
          (12).times do |i|
            revenue_renewed_accounts << TransactionLog.find(:all, :conditions => ["(created_at >= ? AND created_at < ?) AND (activity !=  ? ) AND package_name IN (?)", month_start, month_start + 1.month, 'registration_fee', code ]).collect{ |tr| tr.amount}.sum
            month_start += 1.month
          end
          sheet.add_row([codes_names[counter], revenue_renewed_accounts.collect{|amnt| amnt.to_s + '$'}, revenue_renewed_accounts.sum.to_s + '$'].flatten)
          counter += 1
        end

        month_start = Date.new(Date.today.year)
        sum_revenue = []
        (12).times do |i|
          sum_revenue << revenue_new_accounts[i] + revenue_renewed_accounts[i]
          month_start += 1.month
        end
        sheet.add_row(['Total', sum_revenue.collect{|amnt| amnt.to_s + '$'}, sum_revenue.sum.to_s + '$'].flatten)
        #                sheet.add_row(['Total'])
        sheet.add_row(%w{})

        sheet.add_row(['Monthly Growth', 'Jan', 'Feb', 'March', 'April', 'May', 'Jun', 'Jul' , 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', 'Total'])

        codes_names[-1] = 'New Accounts'
        counter = 0
        promo_codes.each do |code|
          percent_new_accounts = []
          (12).times do |i|
            percent_new_accounts << ((new_accounts_all[counter][i-1].to_f == 0)?'' : (new_accounts_all[counter][i].to_f / new_accounts_all[counter][i-1].to_f) * 100).to_s + '%'
          end
          percent_new_accounts << ((new_accounts_all[counter][1].to_f == 0)?'' : (new_accounts_all[counter][12].to_f / new_accounts_all[counter][1].to_f) * 100).to_s + '%'
          sheet.add_row([codes_names[counter], percent_new_accounts].flatten)
          counter += 1
        end

        codes_names[-1] = 'Renewed Accounts'
        counter = 0
        promo_codes.each do |code|
          percent_renewed_accounts = []
          (12).times do |i|
            percent_renewed_accounts << ((renewed_accounts_all[counter][i-1].to_f == 0)?'' : (renewed_accounts_all[counter][i].to_f / renewed_accounts_all[counter][i-1].to_f) * 100).to_s + '%'
          end
          percent_renewed_accounts << ((renewed_accounts_all[counter][1].to_f == 0)?'' : (renewed_accounts_all[counter][12].to_f / renewed_accounts_all[counter][1].to_f) * 100).to_s + '%'
          sheet.add_row([codes_names[counter], percent_renewed_accounts].flatten)
          counter += 1
        end

        codes_names[-1] = 'Cancelled Accounts'
        counter = 0
        promo_codes.each do |code|
          percent_cancelled_accounts = []
          (12).times do |i|
            percent_cancelled_accounts << ((cancelled_accounts_all[counter][i-1].to_f)?'' : (cancelled_accounts_all[counter][i].to_f / cancelled_accounts_all[counter][i-1].to_f) * 100).to_s + '%'
          end
          percent_cancelled_accounts << ((cancelled_accounts_all[counter][1].to_f == 0)?'' : (cancelled_accounts_all[counter][12].to_f / cancelled_accounts_all[counter][1].to_f) * 100).to_s + '%'
          sheet.add_row([codes_names[counter], percent_cancelled_accounts].flatten)
          counter += 1
        end

        #        return render :text => cancelled_accounts.inspect
      end
    end unless File.file?(file_path)
    #    send_file ("./temp/user_subscription_report#{tim_stmp}.xlsx")
  end

  def adhoc_search_term(start_date, end_date, file_path)
    #    return render :json => [params, start_date, end_date]
    #    file_path = Rails.root.join("tmp", "reports", "search_terms", "Search_Term_Report_#{start_date.to_s}_to_#{end_date.to_s}.xlsx")
    #    FileUtils.mkdir_p(file_path.dirname) unless File.directory?(file_path.dirname)
    search_terms_total  = SearchTerm.sum(:count, :group => :term, :order => 'term ASC')
    search_terms_ytd    = SearchTerm.between(Date.new(start_date.year), end_date).sum(:count, :group => :term)
    search_terms_ytd    = SearchTerm.between(Date.new(Date.today.year), Date.today).sum(:count, :group => :term)
    search_terms_period = SearchTerm.between(start_date, end_date).sum(:count, :group => :term)
    SimpleXlsx::Serializer.new(file_path) do |xlsx|
      xlsx.add_sheet("Search Term") do |sheet|
        sheet.add_row(["Wicked Start Search Term Report"])
        sheet.add_row(["Reporting Period From: #{start_date.strftime("%d %B, %Y")}   To: #{end_date.strftime("%d %B, %Y")}"])
        sheet.add_row([])
        sheet.add_row([])
        sheet.add_row(["Search Terms", "Total", "YTD", "Reporting Period"])
        sheet.add_row([])
        search_terms_total.each do |term, total|
          sheet.add_row([
              term,
              total,
              (search_terms_ytd[term].nil?) ? 0 : search_terms_ytd[term],
              (search_terms_period[term].nil?) ? 0 : search_terms_period[term]
            ])
        end
        sheet.add_row([])
        sheet.add_row(["Total", SearchTerm.sum(:count), SearchTerm.between(Date.new(start_date.year), end_date).sum(:count), SearchTerm.between(start_date, end_date).sum(:count)])
      end
    end unless File.file?(file_path)
  end

  ###  New reports start ########
  def adhoc_checklist_project(start_date, end_date, file_path)
    SimpleXlsx::Serializer.new(file_path) do |xlsx|
      xlsx.add_sheet("Checklist Usage Summary") do |sheet|
        sheet.add_row(["WICKED START PROJECT REPORT"])
        sheet.add_row(["Reporting Period From: #{start_date.strftime("%d %B, %Y")}   To: #{end_date.strftime("%d %B, %Y")}"])
        sheet.add_row([])
        sheet.add_row(["PROJECT SUMMARY REPORT"])
        sheet.add_row(["Users","Number","Percentage"])

        table_one = {'total_users'=>'1'}
        sql = "SELECT COUNT(id) AS user_count FROM `users`"
        result = ActiveRecord::Base.connection.execute(sql)
        row = result.fetch_row
        result.free
        table_one['total_users'] = row.first.to_i
        sql = "SELECT COUNT(id) AS active_user_count FROM `users` WHERE last_login_at <='#{end_date.strftime("%Y-%m-%d 23:59:59")}' AND last_login_at >='#{(end_date-30.day).strftime("%Y-%m-%d 23:59:59")}'"
        result = ActiveRecord::Base.connection.execute(sql)
        row = result.fetch_row
        result.free
        table_one['active_user_count'] = row.first.to_i
        table_one['inactive_user_count'] = table_one['total_users'] - table_one['active_user_count']

        sql = "SELECT COUNT(id) AS cancelled_users FROM `users` WHERE is_blocked = '1'"
        result = ActiveRecord::Base.connection.execute(sql)
        row = result.fetch_row
        result.free
        table_one['cancelled_users'] = row.first.to_i

        active_percent = table_one['active_user_count']*100/table_one['total_users']
        cancelled_percent = table_one['cancelled_users']*100/table_one['total_users']

        sheet.add_row(["Total Users",table_one['total_users'],""])
        sheet.add_row(["  Active (logged in within 30 days)",table_one['active_user_count'],active_percent])
        sheet.add_row(["  Inactive (haven't logged in within 30 days) ",table_one['inactive_user_count'],100-active_percent])
        sheet.add_row(["  Cancelled",table_one['cancelled_users'],cancelled_percent])
        
        table_one = adhoc_checklist_usage_table_one_new
#        sheet.add_row(["Total Projects Created",table_one['all_projects'],table_one['all_projects_progress']])
        sheet.add_row(["Total Projects Created",table_one['all_projects'],""])
        sheet.add_row(["  Completed & Active",table_one['active_complete'],table_one['active_complete_percentage']])
        sheet.add_row(["  Completed & Inactive",table_one['inactive_complete'],table_one['inactive_complete_percentage']])
        #sheet.add_row(["  Completed & Closed","Number","Percentage"])
        sheet.add_row(["  In Progress & Active",table_one['active_incomplete'],table_one['active_incomplete_percentage']])
        sheet.add_row(["  In Progress & Inactive",table_one['inactive_incomplete'],table_one['inactive_incomplete_percentage']])
        #sheet.add_row(["  In Progress & Closed","Number","Percentage"])
      end

      xlsx.add_sheet("Checklist Usage Details") do |sheet|
        sheet.add_row(["Wicked Start Usage Detail Report: By Section"])
        sheet.add_row(Array.new(7, "") + ["SECTION PROGRESS"] + Array.new(9, "") + ["LOGIN INFORMATION", nil])
        section_templates = SectionTemplate.all(:order => "sequence_number ASC").map{|st| [st.id, st.name]}
        sheet.add_row(Array.new(7, nil) + section_templates.map{|id, name| "% Complete: Section #{name}"} + ["Last Login", "No. of Days Since Last Login"])
        #        sheet.add_row(Array.new(7, nil) + SectionTemplate.all.map{|st| "% Complete: Section #{st.name}"} + ["Last Login", "No. of Days Since Last Login"])
        sheet.add_row(Array.new(6, "") + ["Average"] + Array.new(10, "Average %") + ["", "Average #"])
        sheet.add_row(["ID", "First Name", "Last Name", "Email", "Active", "Registration Date", "Cancellation Date"])
        User.with_role(['moderator', 'customer']).each do |user|
          next if user.project.blank?
          percent_sections = section_templates.map do |id, name|
            if user.project.sections.find_by_section_template_id(id).blank?
              "N/A"
            else
              s = user.project.sections.find_by_section_template_id(id)
              s.items.ended.count * 100.0 / s.items.count
            end
          end
          sheet.add_row([user.id, user.first_name, user.last_name, user.email, (user.blocked?) ? "No" : "Yes", user.registration_date.strftime("%m/%d/%Y"),
              (user.expire_date.nil?) ? "N/A" : user.expire_date.strftime("%m/%d/%Y") ] + percent_sections +
              ((user.last_login_at.nil?) ? [ "N/A", "N/A" ] : [ user.last_login_at.strftime("%m/%d/%Y"), distance_of_time_in_words_to_now(user.last_login_at)]))
        end
        sheet.add_row([])
      end
    end unless File.file?(file_path)
  end
  def adhoc_checklist_usage_table_one_new
    sql = "SELECT COUNT(project_id) AS project_count, AVG(percent) AS avg_percent FROM `projects_view`"
    case_active = "((is_blocked IS NULL) OR (is_blocked = 0))"
    case_inactive = "(is_blocked = 1)"
    case_complete = "(item_count = ended_count)"
    case_incomplete = "((item_count <> ended_count) OR (ended_count IS NULL))"
    result = ActiveRecord::Base.connection.execute(sql)
    row = result.fetch_row
    result.free
    table_one = {'all_projects' => row.first.to_f, 'all_projects_progress' => row.last.to_f}
    
    result = ActiveRecord::Base.connection.execute(sql + "WHERE #{case_active} AND #{case_complete}")
    row = result.fetch_row
    result.free
    table_one['active_complete'] = row.first.to_f
    table_one['active_complete_progress'] = row.last.to_f

    result = ActiveRecord::Base.connection.execute(sql + "WHERE #{case_inactive} AND #{case_complete}")
    row = result.fetch_row
    result.free
    table_one['inactive_complete'] = row.first.to_f
    table_one['inactive_complete_progress'] = row.last.to_f

    result = ActiveRecord::Base.connection.execute(sql + "WHERE #{case_active} AND #{case_incomplete}")
    row = result.fetch_row
    result.free
    table_one['active_incomplete'] = row.first.to_f
    table_one['active_incomplete_progress'] = row.last.to_f

    result = ActiveRecord::Base.connection.execute(sql + "WHERE #{case_inactive} AND #{case_incomplete}")
    row = result.fetch_row
    result.free
    table_one['inactive_incomplete'] = row.first.to_f
    table_one['inactive_incomplete_progress'] = row.last.to_f

    table_one['active_complete_percentage'] = table_one['active_complete'] / table_one['all_projects'] * 100
    table_one['inactive_complete_percentage'] = table_one['inactive_complete'] / table_one['all_projects'] * 100
    table_one['active_incomplete_percentage'] = table_one['active_incomplete'] / table_one['all_projects'] * 100
    table_one['inactive_incomplete_percentage'] = table_one['inactive_incomplete'] / table_one['all_projects'] * 100
    logger.debug "table_one => #{table_one.inspect}"
    return table_one
  end
  def adhoc_checklist_section(start_date, end_date, file_path)
    SimpleXlsx::Serializer.new(file_path) do |xlsx|
      xlsx.add_sheet("Checklist Usage Summary") do |sheet|
        sheet.add_row(["WICKED START CHECKLIST USAGE REPORT - BY SECTION"])
        sheet.add_row(["Reporting Period From: #{start_date.strftime("%d %B, %Y")}   To: #{end_date.strftime("%d %B, %Y")}"])
        sheet.add_row([])
        sheet.add_row([])
        [["(is_blocked = 1)", "CANCELED"], ["((is_blocked IS NULL) OR (is_blocked = 0))", "ACTIVE"], ["(1)", "TOTAL"]].each do |condition, title|
          table_two = adhoc_checklist_usage_table_two(condition,start_date,end_date)
          sheet.add_row(["Usage by Section (#{title} ACCOUNTS)", "TOTAL", "TOTAL"])
          sheet.add_row(["", "", "Checklist Progress \n(Does not included those that have completed the entire checklist)"])
          sheet.add_row(["Users", "Total Users", "Completed %(w/ CL Completed)", "Completed %(CL In Progress Only)",
              "Avg Progress(w/ CL Completed)", "Avg Progress(CL In Progress Only)",
              "% Inactive(Not Viewed)", "% Viewed Only", "% Edited", "% All Complete", "% All Complete or N/A", "% All N/A"])
          table_two.sort_by{|key, value| value["sequence_number"].to_i }.each do |key, value|
            sheet.add_row([
                "Section #{value["name"]}: #{value["title"]}", value["section_count"],
                value["percent_ended"], value["percent_ended_pi_all"], value["average_progress"], value["average_progress_pi"],
                value["percent_inactive"], value["percent_viewed"], value["percent_edited"],
                value["percent_complete_pi"], value["percent_ended_pi"], value["percent_not_applicable_pi"]
              ])
          end
          sheet.add_row([])
          sheet.add_row([])
        end
      end
    end unless File.file?(file_path)
  end

  def adhoc_checklist_item(start_date, end_date, file_path)
    SimpleXlsx::Serializer.new(file_path) do |xlsx|
      xlsx.add_sheet("Checklist Usage Summary") do |sheet|
        sheet.add_row(["WICKED START CHECKLIST USAGE REPORT - BY ITEM"])
        sheet.add_row(["Reporting Period From: #{start_date.strftime("%d %B, %Y")}   To: #{end_date.strftime("%d %B, %Y")}"])
        sheet.add_row([])
        sheet.add_row([])
        [["(is_blocked = 1)", "CANCELED"], ["((is_blocked IS NULL) OR (is_blocked = 0))", "ACTIVE"], ["(1)", "TOTAL"]].each do |condition, title|
          table_three = adhoc_checklist_usage_table_three(condition,start_date, end_date)
          sheet.add_row(["Usage by CHECKLIST (#{title} ACCOUNTS)", "TOTAL", "TOTAL"])
          sheet.add_row(["", "", "Checklist Progress \n(Does not included those that have completed the entire checklist)"])
          sheet.add_row(["Users", "Total Users", "Completed %(w/ CL Completed)", "Completed %(CL In Progress Only)",
              "Avg Progress(w/ CL Completed)", "Avg Progress(CL In Progress Only)",
              "% Inactive(Not Viewed)", "% Viewed Only", "% Edited", "% Complete", "% Complete or N/A", "% N/A"])
          table_three.sort_by{|key, value| value["item_number"].to_i }.each do |key, value|
            sheet.add_row([
                "#{value["item_number"]}: #{value["title"]}", value["item_count"],
                value["percent_ended"], value["percent_ended_pi_all"],
                value["percent_ended"], value["percent_ended_pi_all"],
                #                  value["average_progress"], value["average_progress_pi"],
                value["percent_inactive"], value["percent_viewed"], value["percent_edited"],
                value["percent_complete_pi"], value["percent_ended_pi"], value["percent_not_applicable_pi"]
              ])
          end
          sheet.add_row([])
          sheet.add_row([])
        end
      end
    end unless File.file?(file_path)
  end


  ###  New reports end ########
  def adhoc_checklist_usage(start_date, end_date, file_path)
    #    file_path = Rails.root.join("tmp", "reports", "checklist_usage", "Checklist_Usage_Report_#{start_date.to_s}_to_#{end_date.to_s}.xlsx")
    #    FileUtils.mkdir_p(file_path.dirname) unless File.directory?(file_path.dirname)
    SimpleXlsx::Serializer.new(file_path) do |xlsx|
      xlsx.add_sheet("Checklist Usage Summary") do |sheet|
        sheet.add_row(["Wicked Start Checklist Usage Report"])
        sheet.add_row(["Reporting Period From: #{start_date.strftime("%d %B, %Y")}   To: #{end_date.strftime("%d %B, %Y")}"])
        sheet.add_row([])
        sheet.add_row([])
        table_one = adhoc_checklist_usage_table_one
        sheet.add_row(["Users Completed",	"TOTAL"])
        sheet.add_row(["Users",	"% Complete", "% Not Complete", "Avg Progress (w/ Completed)", "Avg Progress (In Progress Only)"])
        sheet.add_row(["Active", table_one['complete_active_percentage'], table_one['incomplete_active_percentage'], table_one['all_active_progress'], table_one['incomplete_active_progress']])
        sheet.add_row(["Canceled", table_one['complete_inactive_percentage'], table_one['incomplete_inactive_percentage'], table_one['all_inactive_progress'], table_one['incomplete_inactive_progress']])
        sheet.add_row([])
        [["(is_blocked = 1)", "CANCELED"], ["((is_blocked IS NULL) OR (is_blocked = 0))", "ACTIVE"], ["(1)", "TOTAL"]].each do |condition, title|
          table_two = adhoc_checklist_usage_table_two(condition)
          sheet.add_row(["Usage by Section (#{title} ACCOUNTS)", "TOTAL", "TOTAL"])
          sheet.add_row(["", "", "Checklist Progress \n(Does not included those that have completed the entire checklist)"])
          sheet.add_row(["Users", "Total Users", "Completed %(w/ CL Completed)", "Completed %(CL In Progress Only)",
              "Avg Progress(w/ CL Completed)", "Avg Progress(CL In Progress Only)",
              "% Inactive(Not Viewed)", "% Viewed Only", "% Edited", "% All Complete", "% All Complete or N/A", "% All N/A"])
          table_two.sort_by{|key, value| value["sequence_number"].to_i }.each do |key, value|
            sheet.add_row([
                "Section #{value["name"]}: #{value["title"]}", value["section_count"],
                value["percent_ended"], value["percent_ended_pi_all"], value["average_progress"], value["average_progress_pi"],
                value["percent_inactive"], value["percent_viewed"], value["percent_edited"],
                value["percent_complete_pi"], value["percent_ended_pi"], value["percent_not_applicable_pi"]
              ])
          end
          sheet.add_row([])
          sheet.add_row([])
        end
        #          [["(is_blocked = 1)", "CANCELED"], ["((is_blocked IS NULL) OR (is_blocked = 0))", "ACTIVE"], ["(1)", "TOTAL"]].each do |condition, title|
        #            sheet.add_row(["Usage by CHECKLIST (#{title} ACCOUNTS)", "TOTAL", "TOTAL"])
        #            sheet.add_row(["", "", "Checklist Progress \n(Does not included those that have completed the entire checklist)"])
        #            sheet.add_row(["Users", "Total Users", "Completed %(w/ CL Completed)", "Completed %(CL In Progress Only)",
        #                "Avg Progress(w/ CL Completed)", "Avg Progress(CL In Progress Only)",
        #                "% Inactive(Not Viewed)", "% Viewed Only", "% Edited", "% Complete", "% Complete or N/A", "% N/A"])
        #            table_two = adhoc_checklist_usage_table_two(condition)
        #            table_two.sort_by{|key, value| value["sequence_number"].to_i }.each do |key, value|
        #              sheet.add_row([
        #                  "Section #{value["name"]}: #{value["title"]}", value["section_count"],
        #                  value["percent_ended"], value["percent_ended_pi_all"], value["average_progress"], value["average_progress_pi"],
        #                  value["percent_inactive"], value["percent_viewed"], value["percent_edited"],
        #                  value["percent_complete_pi"], value["percent_ended_pi"], value["percent_not_applicable_pi"]
        #                ])
        #              condition_for_items = "((`sections`.section_template_id = #{value["section_template_id"]}) AND #{condition})"
        #              table_three = adhoc_checklist_usage_table_three(condition_for_items)
        #              table_three.sort_by{|key, value| value["sequence_number"].to_i }.each do |key, value|
        #                sheet.add_row([
        #                    "#{value["sequence_number"]}: #{value["title"]}", value["item_count"],
        #                    value["percent_ended"], value["percent_ended_pi_all"],
        #                    value["percent_ended"], value["percent_ended_pi_all"],
        #  #                  value["average_progress"], value["average_progress_pi"],
        #                    value["percent_inactive"], value["percent_viewed"], value["percent_edited"],
        #                    value["percent_complete_pi"], value["percent_ended_pi"], value["percent_not_applicable_pi"]
        #                  ])
        #              end
        #              sheet.add_row([])
        #            end
        #            sheet.add_row([])
        #            sheet.add_row([])
        #          end
        [["(is_blocked = 1)", "CANCELED"], ["((is_blocked IS NULL) OR (is_blocked = 0))", "ACTIVE"], ["(1)", "TOTAL"]].each do |condition, title|
          table_three = adhoc_checklist_usage_table_three(condition)
          sheet.add_row(["Usage by CHECKLIST (#{title} ACCOUNTS)", "TOTAL", "TOTAL"])
          sheet.add_row(["", "", "Checklist Progress \n(Does not included those that have completed the entire checklist)"])
          sheet.add_row(["Users", "Total Users", "Completed %(w/ CL Completed)", "Completed %(CL In Progress Only)",
              "Avg Progress(w/ CL Completed)", "Avg Progress(CL In Progress Only)",
              "% Inactive(Not Viewed)", "% Viewed Only", "% Edited", "% Complete", "% Complete or N/A", "% N/A"])
          table_three.sort_by{|key, value| value["item_number"].to_i }.each do |key, value|
            sheet.add_row([
                "#{value["item_number"]}: #{value["title"]}", value["item_count"],
                value["percent_ended"], value["percent_ended_pi_all"],
                value["percent_ended"], value["percent_ended_pi_all"],
                #                  value["average_progress"], value["average_progress_pi"],
                value["percent_inactive"], value["percent_viewed"], value["percent_edited"],
                value["percent_complete_pi"], value["percent_ended_pi"], value["percent_not_applicable_pi"]
              ])
          end
          sheet.add_row([])
          sheet.add_row([])
        end
      end
      xlsx.add_sheet("Checklist Usage Details") do |sheet|
        sheet.add_row(["Wicked Start Usage Detail Report: By Section"])
        sheet.add_row(Array.new(7, "") + ["SECTION PROGRESS"] + Array.new(9, "") + ["LOGIN INFORMATION", nil])
        section_templates = SectionTemplate.all(:order => "sequence_number ASC").map{|st| [st.id, st.name]}
        sheet.add_row(Array.new(7, nil) + section_templates.map{|id, name| "% Complete: Section #{name}"} + ["Last Login", "No. of Days Since Last Login"])
        #        sheet.add_row(Array.new(7, nil) + SectionTemplate.all.map{|st| "% Complete: Section #{st.name}"} + ["Last Login", "No. of Days Since Last Login"])
        sheet.add_row(Array.new(6, "") + ["Average"] + Array.new(10, "Average %") + ["", "Average #"])
        sheet.add_row(["ID", "First Name", "Last Name", "Email", "Active", "Registration Date", "Cancellation Date"])
        User.with_role(['moderator', 'customer']).each do |user|
          next if user.project.blank?
          percent_sections = section_templates.map do |id, name|
            if user.project.sections.find_by_section_template_id(id).blank?
              "N/A"
            else
              s = user.project.sections.find_by_section_template_id(id)
              s.items.ended.count * 100.0 / s.items.count
            end
          end
          sheet.add_row([user.id, user.first_name, user.last_name, user.email, (user.blocked?) ? "No" : "Yes", user.registration_date.strftime("%m/%d/%Y"),
              (user.expire_date.nil?) ? "N/A" : user.expire_date.strftime("%m/%d/%Y") ] + percent_sections +
              ((user.last_login_at.nil?) ? [ "N/A", "N/A" ] : [ user.last_login_at.strftime("%m/%d/%Y"), distance_of_time_in_words_to_now(user.last_login_at)]))
        end
        sheet.add_row([])
      end
    end unless File.file?(file_path)
  end

  def adhoc_repository_usage(start_date, end_date, file_path)
    #    file_path = Rails.root.join("tmp", "reports", "repository_usage", "Repository_Usage_Report_#{start_date.to_s}_to_#{end_date.to_s}.xlsx")
    #    FileUtils.mkdir_p(file_path.dirname) unless File.directory?(file_path.dirname)
    SimpleXlsx::Serializer.new(file_path) do |xlsx|
      xlsx.add_sheet("Repository Usage Summary") do |sheet|
        sheet.add_row(["Wicked Start Repository Usage Report"])
        sheet.add_row(["Reporting Period From: #{start_date.strftime("%d %B, %Y")}   To: #{end_date.strftime("%d %B, %Y")}"])
        sheet.add_row([])
        sheet.add_row([])
        table_one_ua = adhoc_repository_usage_table_one("((is_blocked IS NULL) OR (is_blocked = 0))")
        table_one_ui = adhoc_repository_usage_table_one("(is_blocked = 1)")
        sheet.add_row(["Total User Storage", "TOTAL"])
        sheet.add_row(["Users", "Total Documents", "Total Storage", "Average No. of Documents", "Average Document Size"])
        sheet.add_row(["Active", table_one_ua["doc_count"], table_one_ua["storage"], table_one_ua["avg_doc_count"], table_one_ua["avg_doc_size"]])
        sheet.add_row(["Canceled", table_one_ui["doc_count"], table_one_ui["storage"], table_one_ui["avg_doc_count"], table_one_ui["avg_doc_size"]])
        sheet.add_row([])
        sheet.add_row([])
        table_two_all = adhoc_repository_usage_table_two(nil, nil)
        table_two_ytd = adhoc_repository_usage_table_two(Date.new(Date.today.year), Date.today)
        table_two_rp  = adhoc_repository_usage_table_two(start_date, end_date)
        sheet.add_row(["Storage by Category", "TOTAL"] + Array.new(3, "") + ["YTD"] + Array.new(3, "") + ["REPORTING PERIOD"])
        sheet.add_row(["Users", "Total Documents", "Total Storage", "Average No. of Documents", "Average Document Size", "Total Documents", "Total Storage", "Average No. of Documents", "Average Document Size", "Total Documents", "Total Storage", "Average No. of Documents", "Average Document Size"])
        table_two_all.sort_by{|key, value| value["sequence_number"] }.each do |key, value|
          value_ytd = table_two_ytd[key]
          value_rp  = table_two_rp[key]
          sheet.add_row([value["title"], value["doc_count"], value["storage"], value["avg_doc_count"], value["avg_doc_size"],
              value_ytd["doc_count"], value_ytd["storage"], value_ytd["avg_doc_count"], value_ytd["avg_doc_size"],
              value_rp["doc_count"], value_rp["storage"], value_rp["avg_doc_count"], value_rp["avg_doc_size"]])
        end
        sheet.add_row([])
      end
      xlsx.add_sheet("Repository Usage Details") do |sheet|
        sheet.add_row(["Wicked Start Usage Detail Report: By Section"])
        sheet.add_row([])
        sheet.add_row([])
        section_templates = SectionTemplate.all(:order => "sequence_number ASC").map{|st| [st.id, st.title]}
        sheet.add_row(["DOCUMENT DETAILS", "NUMBER OF DOCUMENTS BY CATEGORY"])
        sheet.add_row(["ID", "First Name ", "Last Name", "Industry", "Email", "Active ", "Total Documents", "Total Storage", "Average No. of Documents", "Average Document Size"] + section_templates.map{|id, title| title})
        User.with_role(['moderator', 'customer']).each do |user|
          next if user.project.blank?
          user_table_one = adhoc_repository_usage_table_one("(`projects_view`.project_id = #{user.project.id})")
          sheet.add_row([user.id, user.first_name, user.last_name, (user.industry.blank?) ? "N/A" : user.industry.title, user.email, (user.blocked?) ? "No" : "Yes",
              user_table_one["doc_count"], user_table_one["storage"], user_table_one["avg_doc_count"], user_table_one["avg_doc_size"]] +
              #              section_templates.map {|id, title| user.project.sections.find_by_section_template_id(id).documents.count})
            section_templates.map {|id, title|
              if user.project.sections.find_by_section_template_id(id).blank?
                "N/A"
              else
                user.project.sections.find_by_section_template_id(id).documents.count
              end
            })
        end
        sheet.add_row([])
      end
    end unless File.file?(file_path)
  end

  def adhoc_checklist_usage_table_one
    sql = "SELECT COUNT(project_id) AS project_count, AVG(percent) AS avg_percent FROM `projects_view`"
    case_active = "((is_blocked IS NULL) OR (is_blocked = 0))"
    case_inactive = "(is_blocked = 1)"
    case_complete = "(item_count = ended_count)"
    case_incomplete = "((item_count <> ended_count) OR (ended_count IS NULL))"
    result = ActiveRecord::Base.connection.execute(sql + "WHERE #{case_active}")
    row = result.fetch_row
    result.free
    table_one = {'all_active' => row.first.to_f, 'all_active_progress' => row.last.to_f}
    result = ActiveRecord::Base.connection.execute(sql + "WHERE #{case_inactive}")
    row = result.fetch_row
    result.free
    table_one['all_inactive'] = row.first.to_f
    table_one['all_inactive_progress'] = row.last.to_f
    result = ActiveRecord::Base.connection.execute(sql + "WHERE (#{case_complete} AND #{case_active})")
    row = result.fetch_row
    result.free
    table_one['complete_active'] = row.first.to_f
    result = ActiveRecord::Base.connection.execute(sql + "WHERE (#{case_complete} AND #{case_inactive})")
    row = result.fetch_row
    result.free
    table_one['complete_inactive'] = row.first.to_f
    result = ActiveRecord::Base.connection.execute(sql + "WHERE (#{case_incomplete} AND #{case_active})")
    row = result.fetch_row
    result.free
    table_one['incomplete_active'] = row.first.to_f
    table_one['incomplete_active_progress'] = row.last.to_f
    result = ActiveRecord::Base.connection.execute(sql + "WHERE (#{case_incomplete} AND #{case_inactive})")
    row = result.fetch_row
    result.free
    table_one['incomplete_inactive'] = row.first.to_f
    table_one['incomplete_inactive_progress'] = row.last.to_f
    table_one['total'] = table_one['all_active'] + table_one['all_inactive']
    table_one['complete_active_percentage'] = table_one['complete_active'] / table_one['total'] * 100
    table_one['complete_inactive_percentage'] = table_one['complete_inactive'] / table_one['total'] * 100
    table_one['incomplete_active_percentage'] = table_one['incomplete_active'] / table_one['total'] * 100
    table_one['incomplete_inactive_percentage'] = table_one['incomplete_inactive'] / table_one['total'] * 100
    logger.debug "table_one => #{table_one.inspect}"
    return table_one
  end

  def adhoc_checklist_usage_table_two(user_condition,start_date=nil,end_date=nil)
    project_incomplete = "(#{user_condition} AND ((`projects_view`.item_count <> ended_count) OR (ended_count IS NULL)))"
    table_two     = adhoc_checklist_usage_table_two_sections(user_condition,start_date,end_date)
    table_two_pi  = adhoc_checklist_usage_table_two_sections(project_incomplete,start_date,end_date)
    table_two_sec = adhoc_checklist_usage_table_two_query("((is_complete = 1) OR (is_applicable = 0))", user_condition,start_date,end_date)
    table_two_ap  = adhoc_checklist_usage_table_two_averages(user_condition,start_date,end_date)
    table_two_api = adhoc_checklist_usage_table_two_averages(project_incomplete,start_date,end_date)
    table_two_sv  = adhoc_checklist_usage_table_two_viewed(project_incomplete,start_date,end_date)
    table_two_su  = adhoc_checklist_usage_table_two_three_edited(project_incomplete, true,start_date,end_date)
    table_two_sc  = adhoc_checklist_usage_table_two_query("(is_complete = 1)", project_incomplete,start_date,end_date)
    table_two_se  = adhoc_checklist_usage_table_two_query("((is_complete = 1) OR (is_applicable = 0))", project_incomplete,start_date,end_date)
    table_two_sna = adhoc_checklist_usage_table_two_query("(is_applicable = 0)", project_incomplete,start_date,end_date)
    table_two.each_key do |key|
      table_two[key]["section_count"] = table_two[key]["section_count"].to_f
      if(table_two_pi[key].blank? || table_two_pi[key]["section_count"].blank?)
        table_two[key]["section_count_pi"] = 0
      else
        table_two[key]["section_count_pi"] = table_two_pi[key]["section_count"].to_f
      end
      if table_two_sec[key].blank?
        table_two[key]["count_ended"] = 0
      else
        table_two[key]["count_ended"] = table_two_sec[key].to_f
      end
      if table_two_sv[key].blank?
        table_two[key]["count_viewed"] = 0
      else
        table_two[key]["count_viewed"] = table_two_sv[key].to_f
      end
      if table_two_su[key].blank?
        table_two[key]["count_edited"] = 0
      else
        table_two[key]["count_edited"] = table_two_su[key].to_f
      end
      if table_two_ap[key].blank?
        table_two[key]["average_progress"] = 0
      else
        table_two[key]["average_progress"] = table_two_ap[key].to_f
      end
      if table_two_api[key].blank?
        table_two[key]["average_progress_pi"] = 0
      else
        table_two[key]["average_progress_pi"] = table_two_api[key].to_f
      end
      if table_two_sc[key].blank?
        table_two[key]["count_complete_pi"] = 0
      else
        table_two[key]["count_complete_pi"] = table_two_sc[key].to_f
      end
      if table_two_se[key].blank?
        table_two[key]["count_ended_pi"] = 0
      else
        table_two[key]["count_ended_pi"] = table_two_se[key].to_f
      end
      if table_two_sna[key].blank?
        table_two[key]["count_not_applicable_pi"] = 0
      else
        table_two[key]["count_not_applicable_pi"] = table_two_sna[key].to_f
      end
      table_two[key]["percent_ended"] = table_two[key]["count_ended"] / table_two[key]["section_count"] * 100
      table_two[key]["percent_ended_pi_all"] = table_two[key]["count_ended_pi"] / table_two[key]["section_count"] * 100
      table_two[key]["percent_viewed"] = table_two[key]["count_viewed"] / table_two[key]["section_count_pi"] * 100
      table_two[key]["percent_inactive"] = 100.0 - table_two[key]["percent_viewed"]
      table_two[key]["percent_edited"] = table_two[key]["count_edited"] / table_two[key]["section_count_pi"] * 100
      table_two[key]["percent_complete_pi"] = table_two[key]["count_complete_pi"] / table_two[key]["section_count_pi"] * 100
      table_two[key]["percent_ended_pi"] = table_two[key]["count_ended_pi"] / table_two[key]["section_count_pi"] * 100
      table_two[key]["percent_not_applicable_pi"] = table_two[key]["count_not_applicable_pi"] / table_two[key]["section_count_pi"] * 100
    end
    logger.debug "table_two => #{table_two.inspect}"
    return table_two
  end

  def adhoc_checklist_usage_table_two_sections(project_where_condition,start_date=nil,end_date=nil)
    if(start_date!=nil)
      project_where_condition += " AND projects_view.start_date >= '#{start_date.strftime("%Y-%m-%d")}'"
    end
    if(end_date!=nil)
      project_where_condition += " AND projects_view.end_date <= '#{end_date.strftime("%Y-%m-%d")}'"
    end
    sql = <<-END_SQL
SELECT section_template_id, section_templates.sequence_number, section_templates.`name`, section_templates.title, section_templates.title_comment, COUNT( sections.id ) AS section_count
FROM `section_templates`
LEFT JOIN `sections` ON `sections`.section_template_id = `section_templates`.id
INNER JOIN `projects_view` ON `sections`.project_id = `projects_view`.project_id
WHERE #{project_where_condition}
GROUP BY section_template_id
ORDER BY sequence_number ASC
    END_SQL
    result = ActiveRecord::Base.connection.execute(sql)
    retval = {}
    while(row = result.fetch_hash)
      retval[row['section_template_id']] = row
    end
    result.free
    return retval
  end

  def adhoc_checklist_usage_table_two_query(finished_where_condition, project_where_condition,start_date=nil,end_date=nil)
    if(start_date!=nil)
      project_where_condition += " AND projects_view.start_date >= '#{start_date.strftime("%Y-%m-%d")}'"
    end
    if(end_date!=nil)
      project_where_condition += " AND projects_view.end_date <= '#{end_date.strftime("%Y-%m-%d")}'"
    end
    sql = <<-END_SQL
SELECT section_template_id, COUNT( section_id ) AS section_count
FROM
(
    SELECT section_id, COUNT(id) AS item_count
    FROM `items`
    GROUP BY section_id
) AS section_items
INNER JOIN
(
    SELECT section_id AS section_finished_id, COUNT(id) AS item_finished_count
    FROM `items`
    WHERE #{finished_where_condition}
    GROUP BY section_id
) AS section_finished_items
ON ((section_items.section_id = section_finished_items.section_finished_id)AND(item_count = item_finished_count))
INNER JOIN `sections` ON section_items.section_id = `sections`.id
INNER JOIN `projects_view` ON `sections`.project_id = `projects_view`.project_id
WHERE #{project_where_condition}
GROUP BY section_template_id
    END_SQL
    result = ActiveRecord::Base.connection.execute(sql)
    retval = {}
    while(row = result.fetch_hash)
      retval[row['section_template_id']] = row['section_count']
    end
    result.free
    return retval
  end

  def adhoc_checklist_usage_table_two_averages(project_where_condition,start_date=nil,end_date=nil)
    if(start_date!=nil)
      project_where_condition += " AND projects_view.start_date >= '#{start_date.strftime("%Y-%m-%d")}'"
    end
    if(end_date!=nil)
      project_where_condition += " AND projects_view.end_date <= '#{end_date.strftime("%Y-%m-%d")}'"
    end
    sql = <<-END_SQL
SELECT section_template_id, (SUM(item_finished_count) * 100 / SUM(section_items.item_count)) AS average
FROM
(
    SELECT section_id, COUNT(id) AS item_count
    FROM `items`
    GROUP BY section_id
) AS section_items
LEFT JOIN
(
    SELECT section_id AS section_finished_id, COUNT(id) AS item_finished_count
    FROM `items`
    WHERE ((is_complete = 1)OR(is_applicable = 0))
    GROUP BY section_id
) AS section_finished_items
ON (section_items.section_id = section_finished_items.section_finished_id)
INNER JOIN `sections` ON section_items.section_id = `sections`.id
INNER JOIN `projects_view` ON `sections`.project_id = `projects_view`.project_id
WHERE #{project_where_condition}
GROUP BY section_template_id
    END_SQL
    result = ActiveRecord::Base.connection.execute(sql)
    retval = {}
    while(row = result.fetch_hash)
      retval[row['section_template_id']] = row['average']
    end
    result.free
    return retval
  end

  def adhoc_checklist_usage_table_two_viewed(project_where_condition,start_date=nil,end_date=nil)
    if(start_date!=nil)
      project_where_condition += " AND projects_view.start_date >= '#{start_date.strftime("%Y-%m-%d")}'"
    end
    if(end_date!=nil)
      project_where_condition += " AND projects_view.end_date <= '#{end_date.strftime("%Y-%m-%d")}'"
    end
    sql = <<-END_SQL
SELECT section_template_id, COUNT( `sections`.id ) AS section_viewed_count
FROM `sections`
INNER JOIN `projects_view` ON `sections`.project_id = `projects_view`.project_id
WHERE ((is_intro_viewed = 1) AND #{project_where_condition})
GROUP BY section_template_id
    END_SQL
    result = ActiveRecord::Base.connection.execute(sql)
    retval = {}
    while(row = result.fetch_hash)
      retval[row['section_template_id']] = row['section_viewed_count']
    end
    result.free
    return retval
  end

  def adhoc_checklist_usage_table_two_three_edited(project_where_condition, for_sections,start_date=nil,end_date=nil)
    if(start_date!=nil)
      project_where_condition += " AND projects_view.start_date >= '#{start_date.strftime("%Y-%m-%d")}'"
    end
    if(end_date!=nil)
      project_where_condition += " AND projects_view.end_date <= '#{end_date.strftime("%Y-%m-%d")}'"
    end
    count_term = (for_sections) ? "`sections`.id" : "`items`.id"
    group_by_term = (for_sections) ? "section_template_id" : "item_template_id"
    sql = <<-END_SQL
SELECT #{group_by_term}, COUNT( DISTINCT(#{count_term}) ) AS edited_count
FROM `items`
LEFT JOIN `documents` ON ((`documents`.documentable_id = `items`.id) AND (`documents`.documentable_type = "Item"))
INNER JOIN `sections` ON `items`.section_id = `sections`.id
INNER JOIN `projects_view` ON `sections`.project_id = `projects_view`.project_id
WHERE ( (((sections.user_answer IS NOT NULL)AND(sections.user_answer != ''))OR(data_file_name IS NOT NULL)) AND #{project_where_condition})
GROUP BY #{group_by_term}
    END_SQL
    result = ActiveRecord::Base.connection.execute(sql)
    retval = {}
    while(row = result.fetch_hash)
      retval[row["#{group_by_term}"]] = row['edited_count']
    end
    result.free
    return retval
  end

  def adhoc_checklist_usage_table_three(user_condition,start_date=nil,end_date=nil)
    project_incomplete = "(#{user_condition}AND((`projects_view`.item_count <> ended_count) OR (ended_count IS NULL)))"
    table_three     = adhoc_checklist_usage_table_three_items(user_condition,start_date,end_date)
    table_three_pi  = adhoc_checklist_usage_table_three_items(project_incomplete,start_date,end_date)
    table_three_iec = adhoc_checklist_usage_table_three_query("(((is_complete = 1)OR(is_applicable = 0)) AND #{user_condition})",start_date,end_date)
    #    table_three_ap  = adhoc_checklist_usage_table_three_averages(user_condition)
    #    table_three_api = adhoc_checklist_usage_table_three_averages(project_incomplete)
    table_three_iv  = adhoc_checklist_usage_table_three_query("((is_viewed = 1) AND #{project_incomplete})",start_date,end_date)
    table_three_iu  = adhoc_checklist_usage_table_two_three_edited(project_incomplete, false,start_date,end_date)
    table_three_ic  = adhoc_checklist_usage_table_three_query("((is_complete = 1) AND #{project_incomplete})",start_date,end_date)
    table_three_ie  = adhoc_checklist_usage_table_three_query("(((is_complete = 1)OR(is_applicable = 0)) AND #{project_incomplete})",start_date,end_date)
    table_three_ina = adhoc_checklist_usage_table_three_query("((is_applicable = 0) AND #{project_incomplete})",start_date,end_date)
    table_three.each_key do |key|
      table_three[key]["item_count"] = table_three[key]["item_count"].to_f
      if(table_three_pi[key].blank? || table_three_pi[key]["item_count"].blank?)
        table_three[key]["item_count_pi"] = 0
      else
        table_three[key]["item_count_pi"] = table_three_pi[key]["item_count"].to_f
      end
      if table_three_iec[key].blank?
        table_three[key]["count_ended"] = 0
      else
        table_three[key]["count_ended"] = table_three_iec[key].to_f
      end
      if table_three_iv[key].blank?
        table_three[key]["count_viewed"] = 0
      else
        table_three[key]["count_viewed"] = table_three_iv[key].to_f
      end
      if table_three_iu[key].blank?
        table_three[key]["count_edited"] = 0
      else
        table_three[key]["count_edited"] = table_three_iu[key].to_f
      end
      if table_three_ic[key].blank?
        table_three[key]["count_complete_pi"] = 0
      else
        table_three[key]["count_complete_pi"] = table_three_ic[key].to_f
      end
      if table_three_ie[key].blank?
        table_three[key]["count_ended_pi"] = 0
      else
        table_three[key]["count_ended_pi"] = table_three_ie[key].to_f
      end
      if table_three_ina[key].blank?
        table_three[key]["count_not_applicable_pi"] = 0
      else
        table_three[key]["count_not_applicable_pi"] = table_three_ina[key].to_f
      end
      table_three[key]["percent_ended"] = table_three[key]["count_ended"] / table_three[key]["item_count"] * 100
      table_three[key]["percent_ended_pi_all"] = table_three[key]["count_ended_pi"] / table_three[key]["item_count"] * 100
      table_three[key]["percent_viewed"] = table_three[key]["count_viewed"] / table_three[key]["item_count_pi"] * 100
      table_three[key]["percent_inactive"] = 100.0 - table_three[key]["percent_viewed"]
      table_three[key]["percent_edited"] = table_three[key]["count_edited"] / table_three[key]["item_count_pi"] * 100
      table_three[key]["percent_complete_pi"] = table_three[key]["count_complete_pi"] / table_three[key]["item_count_pi"] * 100
      table_three[key]["percent_ended_pi"] = table_three[key]["count_ended_pi"] / table_three[key]["item_count_pi"] * 100
      table_three[key]["percent_not_applicable_pi"] = table_three[key]["count_not_applicable_pi"] / table_three[key]["item_count_pi"] * 100
    end
    logger.debug "table_three => #{table_three.inspect}"
    return table_three
  end

  def adhoc_checklist_usage_table_three_items(project_where_condition,start_date=nil,end_date=nil)
    if(start_date!=nil)
      project_where_condition += " AND projects_view.start_date >= '#{start_date.strftime("%Y-%m-%d")}'"
    end
    if(end_date!=nil)
      project_where_condition += " AND projects_view.end_date <= '#{end_date.strftime("%Y-%m-%d")}'"
    end
    sql = <<-END_SQL
SELECT item_template_id, COUNT(`items`.id) AS item_count, `item_templates`.item_number, `item_templates`.sequence_number, `item_templates`.percent, `item_templates`.title, `item_templates`.section_template_id
FROM `item_templates`
LEFT JOIN `items` ON `items`.item_template_id = `item_templates`.id
INNER JOIN `sections` ON `items`.section_id = `sections`.id
INNER JOIN `projects_view` ON `sections`.project_id = `projects_view`.project_id
WHERE #{project_where_condition}
GROUP BY item_template_id
    END_SQL
    result = ActiveRecord::Base.connection.execute(sql)
    retval = {}
    while(row = result.fetch_hash)
      retval[row['item_template_id']] = row
    end
    result.free
    return retval
  end

  def adhoc_checklist_usage_table_three_query(where_condition,start_date=nil,end_date=nil)
    if(start_date!=nil)
      where_condition += " AND projects_view.start_date >= '#{start_date.strftime("%Y-%m-%d")}'"
    end
    if(end_date!=nil)
      where_condition += " AND projects_view.end_date <= '#{end_date.strftime("%Y-%m-%d")}'"
    end
    sql = <<-END_SQL
SELECT item_template_id, COUNT(`items`.id) AS item_count
FROM `items`
INNER JOIN `sections` ON `items`.section_id = `sections`.id
INNER JOIN `projects_view` ON `sections`.project_id = `projects_view`.project_id
WHERE #{where_condition}
GROUP BY item_template_id
    END_SQL
    result = ActiveRecord::Base.connection.execute(sql)
    retval = {}
    while(row = result.fetch_hash)
      retval[row['item_template_id']] = row['item_count']
    end
    result.free
    return retval
  end

  def adhoc_repository_usage_table_one(project_where_condition)
    sql = <<-END_SQL
SELECT COUNT(DISTINCT `projects_view`.project_id) AS project_count, COUNT(s_docs.id) AS doc_count, SUM(data_file_size) AS folder_size
FROM
(
    SELECT `documents`.id, `documents`.data_file_size, section_id
    FROM `documents`
    INNER JOIN `items` ON ((`documents`.documentable_id = `items`.id) AND (`documents`.documentable_type = "Item"))
    UNION ALL
    SELECT `documents`.id, `documents`.data_file_size, documentable_id AS section_id
    FROM `documents`
    WHERE (`documents`.documentable_type = "Section")
) AS s_docs
INNER JOIN `sections` ON section_id = `sections`.id
INNER JOIN `projects_view` ON `sections`.project_id = `projects_view`.project_id
WHERE #{project_where_condition}
    END_SQL
    result = ActiveRecord::Base.connection.execute(sql)
    row = result.fetch_hash
    table_one = {"doc_count" => row["doc_count"].to_i, "storage" => number_to_human_size(row["folder_size"].to_i)}
    table_one["avg_doc_count"] = (row["project_count"].to_i > 0) ? (row["doc_count"].to_f / row["project_count"].to_f) : 0
    table_one["avg_doc_size"] = (row["doc_count"].to_i > 0) ? number_to_human_size(row["folder_size"].to_f / row["doc_count"].to_f) : 0
    result.free
    return table_one
  end

  def adhoc_repository_usage_table_two(start_date, end_date)
    join_condition = "(1)"
    join_condition = "(data_updated_at >= '#{start_date.strftime("%Y-%m-%d 00:00:00")}' AND data_updated_at <= '#{end_date.strftime("%Y-%m-%d 23:59:59")}')" unless start_date.nil?
    sql = <<-END_SQL
SELECT section_templates.sequence_number, section_templates.title, section_template_id, COUNT(DISTINCT section_id) AS section_count, COUNT(s_docs.id) AS doc_count, SUM(data_file_size) AS folder_size
FROM `section_templates`
LEFT JOIN `sections` ON `sections`.section_template_id = `section_templates`.id
LEFT JOIN
(
    SELECT `documents`.id, `documents`.data_file_size, `documents`.data_updated_at, section_id
    FROM `documents`
    INNER JOIN `items` ON ((`documents`.documentable_id = `items`.id) AND (`documents`.documentable_type = "Item"))
    UNION ALL
    SELECT `documents`.id, `documents`.data_file_size, `documents`.data_updated_at, documentable_id AS section_id
    FROM `documents`
    WHERE (`documents`.documentable_type = "Section")
) AS s_docs
ON ((section_id = `sections`.id) AND #{join_condition})
GROUP BY section_template_id
    END_SQL
    result = ActiveRecord::Base.connection.execute(sql)
    retval = {}
    while(row = result.fetch_hash)
      retval[row['section_template_id']] = {
        "doc_count" => row["doc_count"].to_i,
        "storage" => number_to_human_size(row["folder_size"].to_i),
        "avg_doc_count" => (row["section_count"].to_f > 0) ? (row["doc_count"].to_f / row["section_count"].to_f) : 0,
        "avg_doc_size" => (row["doc_count"].to_f > 0) ? number_to_human_size(row["folder_size"].to_f / row["doc_count"].to_f) : 0,
        "sequence_number" => row["sequence_number"].to_i,
        "title" => row["title"]
      }
    end
    result.free
    return retval
  end
  def adhoc_resource_usage(start_date, end_date, file_path)
    sql = <<-END_SQL
    Select count(resource_id) as click_count,resources.title as resource_title from user_resource_clicks
INNER JOIN resources ON resources.id=user_resource_clicks.resource_id
where Date(user_resource_clicks.created_at)>='#{start_date}' AND Date(user_resource_clicks.created_at)<='#{end_date}' group by resource_id
    END_SQL
    result = ActiveRecord::Base.connection.execute(sql)
    SimpleXlsx::Serializer.new(file_path) do |xlsx|
      xlsx.add_sheet("Resource Clicks") do |sheet|
        sheet.add_row(["Wicked Start Resource Clicks Report"])
        sheet.add_row(["Reporting Period From: #{start_date.strftime("%d %B, %Y")}   To: #{end_date.strftime("%d %B, %Y")}"])
        sheet.add_row([])
        sheet.add_row(["Resource Title", "Total Clicks"])
        while(row = result.fetch_hash)
          sheet.add_row([row["resource_title"],row["click_count"]])
        end
        result.free
      end
      sql = <<-END_SQL
Select users.first_name,users.last_name,count(resource_id) as click_count,resources.title as resource_title, ip_address from user_resource_clicks
INNER JOIN resources ON resources.id=user_resource_clicks.resource_id
LEFT JOIN users ON users.id=user_resource_clicks.user_id
where Date(user_resource_clicks.created_at) >= '#{start_date}' AND Date(user_resource_clicks.created_at) <='#{end_date}' group by resource_id,user_id
      END_SQL
      result = ActiveRecord::Base.connection.execute(sql)
      xlsx.add_sheet("User Resource Clicks") do |sheet|
        sheet.add_row(["Wicked Start User Resource Clicks Report"])
        sheet.add_row(["Reporting Period From: #{start_date.strftime("%d %B, %Y")}   To: #{end_date.strftime("%d %B, %Y")}"])
        sheet.add_row([])
        sheet.add_row([])
        sheet.add_row(["User Name", "IP Address", "Resource Title", "Total Clicks"])
        while(row = result.fetch_hash)
          sheet.add_row([(row["first_name"].blank? && row["last_name"].blank?)?"Not Authenticated":(row["first_name"]+" "+row["last_name"]),row["ip_address"],row["resource_title"],row["click_count"]])
        end
        result.free
      end

    end unless File.file?(file_path)
  end
end
