# Stripe File API

Provides wrapper around Stripe File Api for Apex. File upload is implemented using the Publishable key, see https://stripe.com/docs/file-upload.

## Setup

This project is using Salesforce DX. Run following commands to get your scratch org ready.

1. Create scratch org:
```sfdx force:org:create -f config/project-scratch-def.json --setalias stripe-file-api```

2. Push source:
```sfdx force:source:push```

3. Run tests:
```sfdx force:apex:test:run --synchronous```

4. Open scratch org:
```sfdx force:org:open```

## API testing

1. Replace `StripeFileApi.STRIPE_PUBLISHABLE_KEY` constant with a publishable key you got from Stripe. Preferably store this somewhere safe e.g. custom metadata and don't commit to source control.

2. Run following script to upload test file:

```
Blob file = [
    SELECT Id, VersionData 
    FROM ContentVersion WHERE ContentDocumentId = 'CONTENT DOC ID'
].VersionData;

String stripeId = StripeFileApi.createFile(
    file, 
    'test.png', 
    'image/jpg', 
    StripeFileApi.Purpose.identity_document
);
System.debug(stripeId);
```

Feel free to use this code and amend it as needed. If you would like to contribute, just submit a PR. If you find this useful please star this repo :)
