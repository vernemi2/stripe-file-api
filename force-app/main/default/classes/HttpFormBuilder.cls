/**
 * Credits goes to: https://github.com/muenzpraeger/salesforce-einstein-platform-apex/blob/master/force-app/main/default/classes/Einstein_HttpBodyPart.cls
 * https://github.com/MetaMind/apex-utils/blob/master/Vision.apex
 * And to Michal Verner to stitching it up, will be in the repo hopefully soon as well :)
 */
public class HttpFormBuilder {
    private static final String LOGMARK = '** HttpFormBuilder ** ';

    //  The boundary is alligned so it doesn't produce padding characters when base64 encoded.
    private final static String Boundary = '1ff13444ed8140c7a32fc4e6451aa76d';

    /**
     *  Returns the request's content type for multipart/form-data requests.
     */
    public static String getContentType() {
        String out = 'multipart/form-data; boundary="' + Boundary + '"';

        System.debug(
            LoggingLevel.DEBUG,
            LOGMARK +
            'getContentType - out: ' +
            out
        );
        return out;
    }

    /**
     *  Base 64 encode value. If encoded value contains '=' at the end, add white space before the line breaks and encode again till all the '=' are removed.
     */
    public static String safelyEncode(String value, String lineBreaks) {
        String encodedValue = EncodingUtil.base64Encode(
            Blob.valueOf(value + lineBreaks)
        );

        while (encodedValue.endsWith('=')) {
            value += ' ';
            encodedValue = EncodingUtil.base64Encode(
                Blob.valueOf(value + lineBreaks)
            );
        }

        System.debug(
            LoggingLevel.DEBUG,
            LOGMARK +
            'safelyEncode - encodedValue: ' +
            encodedValue
        );
        return encodedValue;
    }

    /**
     *  Write a boundary between parameters to the form's body.
     */
    public static String writeBoundary() {
        string out = '--' + Boundary + '\r\n';

        System.debug(
            LoggingLevel.DEBUG,
            LOGMARK +
            'writeBoundary - out: ' +
            out
        );
        return out;
    }

    /**
     *  Write a boundary at the end of the form's body.
     */
    public static String writeEncBoundary(EndingType ending) {
        String value = '';

        if (ending == EndingType.Cr) {
            //  The file's base64 was padded with a single '=',
            //  so it was replaced with '\r'. Now we have to
            //  prepend the boundary with '\n' to complete
            //  the line break.
            value += '\n';
        } else if (ending == EndingType.None) {
            //  The file's base64 was not padded at all,
            //  so we have to prepend the boundary with
            //  '\r\n' to create the line break.
            value += '\r\n';
        }
        //  Else:
        //  The file's base64 was padded with a double '=',
        //  so they were replaced with '\r\n'. We don't have to
        //  do anything to the boundary because there's a complete
        //  line break before it.

        value += '--' + Boundary + '--';

        System.debug(
            LoggingLevel.DEBUG,
            LOGMARK +
            'writeEncBoundary - value: ' +
            value
        );

        return EncodingUtil.base64Encode(Blob.valueOf(value));
    }

    /**
     *  Write a key-value pair to the form's body.
     */
    public static string writeBodyParameter(string key, string value) {
        String contentDisposition =
            'Content-Disposition: form-data; name="' +
            key +
            '"';
        String out = contentDisposition + '\r\n\r\n' + value + '\r\n';

        System.debug(
            LoggingLevel.DEBUG,
            LOGMARK +
            'writeBodyParameter - out: ' +
            out
        );
        return out;
    }

    /**
     *  Write a blob header into the form's body part
     */
    public static String writeBlobDispositionPart(
        String name,
        String fileName,
        String contentType
    ) {
        String out =
            'Content-Disposition: form-data; name="' +
            name +
            '"; filename="' +
            fileName +
            '"' +
            '\r\n';

        out += 'Content-Type: ' + contentType;

        System.debug(
            LoggingLevel.DEBUG,
            LOGMARK +
            'writeBlobDispositionPart - out: ' +
            out
        );
        return out;
    }

    /**
     *  Write a blob content into the form's body part and append part boundary to the end
     */
    public static string writeBlobBodyWithBoundary(String file64) {
        Integer file64Length = file64.length();
        String last4Bytes = file64.substring(
            file64.length() - 4,
            file64.length()
        );

        // Avoid padding the file data with spaces, which SafelyPad does
        // http://salesforce.stackexchange.com/a/33326/102
        EndingType ending = EndingType.None;
        if (last4Bytes.endsWith('==')) {
            // The '==' sequence indicates that the last group contained only one 8 bit byte
            // 8 digit binary representation of CR is 00001101
            // 8 digit binary representation of LF is 00001010
            // Stitch them together and then from the right split them into 6 bit chunks
            // 0000110100001010 becomes 0000 110100 001010
            // Note the first 4 bits 0000 are identical to the padding used to encode the
            // second original 6 bit chunk, this is handy it means we can hard code the response in
            // The decimal values of 110100 001010 are 52 10
            // The base64 mapping values of 52 10 are 0 K
            // See http://en.wikipedia.org/wiki/Base64 for base64 mapping table
            // Therefore, we replace == with 0K
            // Note: if using \n\n instead of \r\n replace == with 'oK'
            last4Bytes = last4Bytes.substring(0, 2) + '0K';
            file64 = file64.substring(0, file64.length() - 4) + last4Bytes;
            // We have appended the \r\n to the Blob, so leave footer as it is.
            ending = EndingType.CrLf;
        } else if (last4Bytes.endsWith('=')) {
            // '=' indicates that encoded data already contained two out of 3x 8 bit bytes
            // We replace final 8 bit byte with a CR e.g. \r
            // 8 digit binary representation of CR is 00001101
            // Ignore the first 2 bits of 00 001101 they have already been used up as padding
            // for the existing data.
            // The Decimal value of 001101 is 13
            // The base64 value of 13 is N
            // Therefore, we replace = with N
            last4Bytes = last4Bytes.substring(0, 3) + 'N';
            file64 = file64.substring(0, file64.length() - 4) + last4Bytes;
            // We have appended the CR e.g. \r, still need to prepend the line feed to the footer
            ending = EndingType.Cr;
        }

        String content = file64;

        content += writeEncBoundary(ending);
        return content;
    }

    /**
     *  Helper enum indicating how a file's base64 padding was replaced.
     */
    public enum EndingType {
        Cr,
        CrLf,
        None
    }
}
