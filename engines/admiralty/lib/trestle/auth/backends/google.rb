module Trestle
  module Auth
    module Backends
      class Google < Base
        # Returns the current logged in user (after #authentication).
        attr_reader :user

        # Authenticates a user from a login form request.
        def authenticate!
          user = Trestle.config.auth.user_class.find_or_create_by(email: google_identity.email_address)

          login!(user)
          user
        end

        # Authenticates a user from the session or cookie. Called on each request via a before_action.
        def authenticate
          @user ||= find_authenticated_user || redirect_to_login
        end

        # Checks if there is a logged in user.
        def logged_in?
          !!user
        end

        # Stores the given user in the session as logged in.
        def login!(user)
          session[:trestle_user] = user.id
          @user = user
        end

        # Logs out the current user.
        def logout!
          session.delete(:trestle_user)
          @user = nil
        end

        protected

        def find_authenticated_user
          Trestle.config.auth.find_user(session[:trestle_user]) if session[:trestle_user]
        end

        def redirect_to_login
          controller.redirect_to login_url(scope: "openid profile email", state: state),
            flash: {proceed_to: controller.signin_url, state: state}
        end

        def login_params
          controller.params.require(:user).permit!
        end

        private

        def login_url(**params)
          client.auth_code.authorize_url(prompt: "login", **params)
        end

        def client
          @client ||= OAuth2::Client.new(
            GoogleSignIn.client_id,
            GoogleSignIn.client_secret,
            authorize_url: "https://accounts.google.com/o/oauth2/auth",
            token_url: "https://oauth2.googleapis.com/token",
            redirect_uri: controller.google_sign_in.callback_url
          )
        end

        def state
          @state ||= SecureRandom.base64(24)
        end

        def authenticate_with_google
          return false if flash[:google_sign_in_token].blank?

          %w[itsmycargo.com].include?(google_identity.hosted_domain)
        end

        def google_identity
          @google_identity ||= GoogleSignIn::Identity.new(controller.flash[:google_sign_in][:id_token])
        end
      end
    end
  end
end
