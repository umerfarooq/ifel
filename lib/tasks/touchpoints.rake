namespace :touchpoint do

  desc "Validates all the touchpoints and activates if necessary"
  task :set_all => :environment do
    CUSTOM_LOGGER.info "__TP_SET_ALL_START__TP_OI__#{Touchpoint.opened.inactivated.count}__"
    Touchpoint.opened.inactivated.project_wise.each { |tp| tp.activate if tp.accurate? }
    CUSTOM_LOGGER.info "__TP_SET_ALL_END__TP_OI__#{Touchpoint.opened.inactivated.count}__"
  end

  desc "Runs all the touchpoints that are activated"
  task :run_all => :environment do
    CUSTOM_LOGGER.info "__TP_RUN_ALL_START__TP_OA__#{Touchpoint.opened.activated.count}__"
    tp_templates = YAML::load_file(Rails.root.join("config", "touchpoint_templates.yml"))
#    CUSTOM_LOGGER.debug "TP_templates_INSPECT => #{tp_templates.inspect}"
    Touchpoint.opened.activated.project_wise.each do |tp|
#      CUSTOM_LOGGER.debug "TP_INSPECT => #{tp.inspect}"
      next if tp_templates[tp.condition].blank?
      tp.deliver_touchpoint_email(
        tp_templates[tp.condition]["subject"],
        tp_templates[tp.condition]["quote"],
        tp_templates[tp.condition]["paragraphs"]
      )
      tp.close
    end
    CUSTOM_LOGGER.info "__TP_RUN_ALL_END__TP_OA__#{Touchpoint.opened.activated.count}__"
  end

  task :tp_test => :environment do
    test_project = User.find(3).project
    CUSTOM_LOGGER.debug "__TP_TP_TEST__P__#{test_project.inspect}__"
    tp_templates = YAML::load_file(Rails.root.join("config", "touchpoint_templates.yml"))
    test_project.touchpoints.opened.activated.each do |tp|
      puts tp.inspect
      next if tp_templates[tp.condition].blank?
      tp.deliver_touchpoint_email(
        tp_templates[tp.condition]["subject"],
        tp_templates[tp.condition]["quote"],
        tp_templates[tp.condition]["paragraphs"]
      )
#      tp.close
    end
  end

end
