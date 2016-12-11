package rocks.festify;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.spotify.sdk.android.authentication.AuthenticationClient;
import com.spotify.sdk.android.authentication.AuthenticationRequest;
import com.spotify.sdk.android.authentication.AuthenticationResponse;

public class CordovaSpotify extends CordovaPlugin {

    private static final int REQUEST_CODE = 1337;

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("authenticate")) {
            String redirectUrl = args.getString(0);
            String clientId = args.getString(1);
            this.authenticate(callbackContext, clientId, redirectUrl);
            return true;
        }
        return false;
    }

    private void authenticate(CallbackContext callbackContext, String clientId, String redirectUrl) {
        AuthenticationRequest.Builder builder = new AuthenticationRequest.Builder(
                clientId,
                AuthenticationResponse.Type.TOKEN,
                redirectUrl
        );
        builder.setScopes(new String[]{"user-read-private", "streaming"});
        AuthenticationRequest request = builder.build();

        AuthenticationClient.openLoginActivity(this.cordova.getActivity(), REQUEST_CODE, request);

        callbackContext.success();
    }
}