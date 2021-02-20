const functions = require("firebase-functions");
const uuid = require("uuid");

// optional settings
const regionName = "europe-west3";
const runtimeOpts = {
  timeoutSeconds: 300,
  memory: "128MB",
};

// --- generateCloudImageUrl via DO_SPACES ---
const AWS = require("aws-sdk");
const spacesEndpoint = new AWS.Endpoint(functions.config().do_spaces.url );
const s3 = new AWS.S3({
  endpoint: spacesEndpoint,
  accessKeyId: functions.config().do_spaces.key,
  secretAccessKey: functions.config().do_spaces.secret,
});

// using DigitalOcean spaces
exports.generateCloudImageUrl = functions
    .runWith(runtimeOpts)
    .region(regionName)
    .https.onCall((reqData, context) => {
      let fileType = reqData["fileType"];
      // disabled below-block to allow any file type
      /*
      if (fileType !== ".jpg" && fileType !== ".png" && fileType !== ".jpeg") {
        return {
          success: false,
          message: "Image format invalid"
        };
      }
      */

      let uid = "";
      if (context.auth !== undefined && context.auth.uid !== undefined) {
        uid = context.auth.uid;
      }
      fileType = fileType.substring(1, fileType.length);
      let fileName = "DEMO";
      if (uid !== "") {
        fileName += "-" + uid;
      }
      fileName += "-" + uuid.v4();

      const fileFullName = fileName + "." + fileType;
      const downloadUrl = "https://" + functions.config().do_spaces.cdn + "/" + fileFullName;

      // get signedUrl for uploading file to DO_SPACES
      const s3FileParams = {
        Bucket: functions.config().do_spaces.bucket, // "petcat",
        Key: fileFullName,
        ContentType: "image/" + fileType,
        Expires: 60 * 5, // seconds
        ACL: "public-read", // so that media can be loaded by the app!
        // ACL: "private"
      };

      const doResponse = s3.getSignedUrl("putObject", s3FileParams);
      if (doResponse.startsWith("https://") || doResponse.startsWith("http://")) {

        // NB! when uploading an image, you'll need to use `uploadUrl` and `uploadHeaders`
        // and after successful upload, your image will become available via downloadUrl
        const responseData = {
          success: true,
          message: "uploadUrl generated",
          downloadUrl: downloadUrl,
          uploadUrl: doResponse,
          uploadHeaders: { // used when uploading file to DO_SPACES
            "Content-Type": "image/" + fileType,
            "x-amz-acl": "public-read",
          },
        };
        console.log(responseData);
        return responseData;
      } else {
        return {
          success: false,
          message: "DO-Error: " + doResponse.toString(),
        };
      }
    });
