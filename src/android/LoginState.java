package rocks.festify;

import org.apache.cordova.CallbackContext;

public class LoginState {
    private CallbackContext loginCallbackContext = null;
    private String clientId = "";

    public LoginState(CallbackContext loginCallbackContext, String clientId) {
        this.loginCallbackContext = loginCallbackContext;
        this.clientId = clientId;
    }

    public CallbackContext getLoginCallbackContext() {
        return loginCallbackContext;
    }

    public String getClientId() {
        return clientId;
    }

    public static boolean isValid(LoginState state) {
        return state != null &&
                state.loginCallbackContext != null &&
                (state.clientId != null && state.clientId.length() > 0);
    }
}