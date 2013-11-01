class ApplicationController < PublishMyData::ApplicationController

  before_filter :check_maintenance_mode

  helper PublishMyData::Engine.helpers
  helper :all

  protected

  def check_maintenance_mode
    if Pathname.new(TsbProjectData::MAINTENANCE_FILE_PATH).exist?
      respond_to do |format|
        format.html { render(:template => "publish_my_data/errors/maintenance", :layout => 'publish_my_data/error', :status => 503) and return false }
        format.any { render(:text => 'Maintenance Mode', :status => 503, :content_type => 'text/plain') and return false }
      end
    end
  end

end