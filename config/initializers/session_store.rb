Rails.application.config.session_store :active_record_store, :key => '_my_app_session', :expire_after => 60.minutes
