// const String domain = "http://localhost:5000";
const String domain = "https://auth-blond-three.vercel.app";

const String CHECK_TOKEN = "$domain/api/auth/check-admin";
const String PING = "$domain/ping";
const String BLOCK = "$domain/api/auth/block-user";
const String UNBLOCK = "$domain/api/auth/unblock-user";


const String UPLOAD_VIDEO_TO_SERVER ="http://localhost:3000/api/upload/upload-video-to-server";
const String CUT_VIDEO_HLS ="http://localhost:3000/api/video/cut-video-hls";
const String CLEAR_UPLOAD_VIDEO = "http://localhost:3000/api/upload/clear-upload-video";

const String UPLOAD_TRAILER_TO_SERVER ="http://localhost:3000/api/upload/upload-trailer-to-server";
const String CUT_TRAILER_HLS ="http://localhost:3000/api/video/cut-trailer-hls";
const String CLEAR_UPLOAD_TRAILER = "http://localhost:3000/api/upload/clear-upload-trailer";

const String UPLOAD_TRAILER_TO_R2 ="http://localhost:3000/api/upload/upload-trailer-hls";
const String UPLOAD_VIDEO_TO_R2 ="http://localhost:3000/api/upload/upload-video-hls";
const String CHECK_TRAILER_R2 ="$domain/api/get-url/get-trailer-url";
const String CHECK_VIDEO_R2 ="$domain/api/get-url/get-video-url";

const String CHECK_TRAILER_UPLOAD ="http://localhost:3000/api/upload/check-trailer-hls";
const String CHECK_VIDEO_UPLOAD ="http://localhost:3000/api/upload/check-video-hls";

const String DELETE_VIDEO ="http://localhost:3000/api/upload/delete-folder";
