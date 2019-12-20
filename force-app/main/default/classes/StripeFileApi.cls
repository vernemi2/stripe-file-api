public inherited sharing class StripeFileApi {
    private static final String LOGMARK = '** StripeFileApi ** ';

    public static final String PUBLISHABLE_KEY_QA_SETTINGS = 'Stripe_Publishable_Key_QA';
    public static final String PUBLISHABLE_KEY_SETTINGS = 'Stripe_Publishable_Key';
    
    public static final String FILES_ENDPOINT = 'https://files.stripe.com/v1/files';
    public static final String STRIPE_PUBLISHABLE_KEY = 'test_key';

    public static String createFile(
        Blob fileContent,
        String fileName,
        String contentType
    ) {
        String formData = '';

        formData += HttpFormBuilder.writeBoundary();
        formData += HttpFormBuilder.writeBodyParameter(
            'purpose',
            'identity_document'
        );
        formData += HttpFormBuilder.writeBoundary();
        formData += HttpFormBuilder.writeBlobDispositionPart(
            'file',
            fileName,
            contentType
        );
        String formData64 = HttpFormBuilder.safelyEncode(formData, '\r\n\r\n');
        formData64 += HttpFormBuilder.writeBlobBodyWithBoundary(
            EncodingUtil.base64Encode(fileContent)
        );

        Blob formBlob = EncodingUtil.base64Decode(formData64);

        HttpRequest httpRequest = createAuthRequest();

        httpRequest.setBodyAsBlob(formBlob);

        httpRequest.setMethod('POST');
        httpRequest.setEndpoint(FILES_ENDPOINT);

        Http http = new Http();

        HTTPResponse res = http.send(httpRequest);
        System.debug(
            LoggingLevel.DEBUG,
            LOGMARK +
            'res.getStatusCode(): ' +
            res.getStatusCode()
        );
        System.debug(
            LoggingLevel.DEBUG,
            LOGMARK +
            'res.getBody(): ' +
            res.getBody()
        );

        CreateFileResponse out = (CreateFileResponse) JSON.deserialize(
            res.getBody(),
            CreateFileResponse.class
        );

        validateResponse(out, res);

        return out.id;
    }

    private static HttpRequest createAuthRequest() {
        String userName = STRIPE_PUBLISHABLE_KEY;

        Blob headerValue = Blob.valueOf(username + ':');
        String authorizationHeader =
            'Basic ' + EncodingUtil.base64Encode(headerValue);

        HttpRequest httpRequest = new HttpRequest();

        httpRequest.setHeader('Content-Type', HttpFormBuilder.getContentType());
        httpRequest.setHeader('Accept', 'application/json');
        httpRequest.setHeader('Authorization', authorizationHeader);

        System.debug(
            LoggingLevel.DEBUG,
            LOGMARK +
            'createAuthRequest - httpRequest: ' +
            httpRequest
        );
        return httpRequest;
    }

    private static void validateResponse(CreateFileResponse createFileResponse, HttpResponse res) {

        if (createFileResponse.id == null && res.getStatusCode() >= 400) {
            ResponseError error = (ResponseError) JSON.deserialize(
                res.getBody(),
                ResponseError.class
            );
            if (
                error != null &&
                error.error != null &&
                String.isNotBlank(error.error.message)
            ) {
                throw new StripeFileApiException(error.error.message);
            }
        }
    }

    public class CreateFileResponse {
        public String id;
    }

    public class ResponseError {
        Error error;
    }

    public class Error {
        public String message;
    }

    public class StripeFileApiException extends Exception {
    }
}
