@IsTest
private class HttpFormBuilder_Test {
    @IsTest
    static void getContentType() {
        String contentType = HttpFormBuilder.getContentType();
        System.assertEquals(
            'multipart/form-data; boundary="1ff13444ed8140c7a32fc4e6451aa76d"',
            contentType
        );
    }

    @IsTest
    static void safelyEncode() {
        String safelyEncodedValue = HttpFormBuilder.safelyEncode('Test', '');
        System.assert(!safelyEncodedValue.contains('='));

        String originalValue = EncodingUtil.base64Decode(safelyEncodedValue)
            .toString();
        System.assertEquals('Test  ', originalValue);
    }

    @IsTest
    static void writeBoundary() {
        System.assertEquals(
            '--1ff13444ed8140c7a32fc4e6451aa76d\r\n',
            HttpFormBuilder.writeBoundary()
        );
    }

    @IsTest
    static void writeEncBoundary() {
        String encodedBoundary = HttpFormBuilder.writeEncBoundary(
            HttpFormBuilder.EndingType.CrLf
        );
        System.assertEquals(
            '--1ff13444ed8140c7a32fc4e6451aa76d--',
            EncodingUtil.base64Decode(encodedBoundary).toString()
        );
    }

    @IsTest
    static void writeBodyParameter() {
        System.assertEquals(
            'Content-Disposition: form-data; name="test"\r\n\r\ntest_value\r\n',
            HttpFormBuilder.writeBodyParameter('test', 'test_value')
        );
    }

    @IsTest
    static void writeBlobDispositionPart() {
        System.assertEquals(
            'Content-Disposition: form-data; name="test"; filename="test file name.jpg"\r\nContent-Type: image/jpeg',
            HttpFormBuilder.writeBlobDispositionPart(
                'test',
                'test file name.jpg',
                'image/jpeg'
            )
        );
    }

    @IsTest
    static void writeBlobBodyWithBoundary() {
        System.assert(
            !HttpFormBuilder.writeBlobBodyWithBoundary(
                    EncodingUtil.base64Encode(Blob.valueOf('Test'))
                )
                .contains('=')
        );
    }
}
