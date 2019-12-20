public inherited sharing class StripeFileApiCreateFileMock implements HttpCalloutMock {
    private Boolean hasError = false;

    public StripeFileApiCreateFileMock() {
    }

    public StripeFileApiCreateFileMock(Boolean hasError) {
        this.hasError = hasError;
    }

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');

        if (!hasError) {
            // prettier-ignore
            res.setBody(
                '{' +
                    '"id": "file_1FoTEiIoyWjpq5cW6oLK27Xt",' +
                    '"object": "file",' +
                    '"created": 1576063208,' +
                    '"filename": "DBS Certificate.JPG",' +
                    '"purpose": "identity_document",' +
                    '"size": 3900027,' +
                    '"title": null,' +
                    '"type": "jpg",' +
                    '"url": null' +
                '}'
            );
            res.setStatusCode(200);
        } else {
            // prettier-ignore
            res.setBody(
                '{' +
                    '"error": {' +
                        '"message": "We don\'t currently support that file type. Try uploading a file with one of the following mimetypes: application/pdf, image/jpeg, image/png",' +
                        '"param": "file",' +
                        '"type": "invalid_request_error"' +
                    '}' +
                '}'
            );
            res.setStatusCode(400);
        }

        return res;
    }
}
