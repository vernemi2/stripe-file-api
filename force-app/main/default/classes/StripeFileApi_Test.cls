@IsTest
private class StripeFileApi_Test {
    @IsTest
    static void createFile() {
        Test.setMock(HttpCalloutMock.class, new StripeFileApiCreateFileMock());

        Test.startTest();
        String fileId = StripeFileApi.createFile(
            Blob.valueOf('Test content'),
            'Test file.jpg',
            'image/jpeg',
            StripeFileApi.Purpose.identity_document
        );
        Test.stopTest();

        System.assertEquals('file_1FoTEiIoyWjpq5cW6oLK27Xt', fileId);
    }

    @IsTest
    static void createFile_Error() {
        Test.setMock(HttpCalloutMock.class, new StripeFileApiCreateFileMock(true));

        try {
            Test.startTest();
            String fileId = StripeFileApi.createFile(
                Blob.valueOf('Test content'),
                'Test file.11',
                null,
                StripeFileApi.Purpose.identity_document
            );
            Test.stopTest();
            System.assert(false, 'Exception should have been thrown');
        } catch (StripeFileApi.StripeFileApiException exc) {
            System.assertEquals(
                'We don\'t currently support that file type. Try uploading a file with one of the following mimetypes: application/pdf, image/jpeg, image/png',
                exc.getMessage()
            );
        }
    }
}
