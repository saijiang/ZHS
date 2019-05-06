//
//  TNHttpStatusCode.h
//  TNAppLib
//
//  Created by kiri on 2013-10-14.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#ifndef TNAppLib_TNHttpStatusCode_h
#define TNAppLib_TNHttpStatusCode_h

/*!
 *  The list here is based on the description at Wikipedia.
 *  The initial version of this list was written on April 20, 2013.
 *
 *  @see [List of HTTP status codes](http://en.wikipedia.org/wiki/List_of_HTTP_status_codes)
 *  @see [HTTP/1.1: Status Code Definitions](http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html)
 */
typedef NS_ENUM(NSInteger, HTTPStatusCode) {
    
    /*!--------------------------------------------------
     * @name 1xx Informational
     *------------------------------------------------*/
    
    /*!
     * 100 Continue.
     */
    kHTTPStatusCodeContinue = 100,
    
    /*!
     * 101 Switching Protocols.
     */
    kHTTPStatusCodeSwitchingProtocols = 101,
    
    /*!
     * 103 Processing (WebDAV; RFC 2518).
     */
    kHTTPStatusCodeProcessing = 102,
    
    /*!--------------------------------------------------
     * @name 2xx Success
     *------------------------------------------------*/
    
    /*!
     * 200 OK.
     */
    kHTTPStatusCodeOK = 200,
    
    /*!
     * 201 Created.
     */
    kHTTPStatusCodeCreated = 201,
    
    /*!
     * 202 Accepted.
     */
    kHTTPStatusCodeAccepted = 202,
    
    /*!
     * 203 Non-Authoritative Information (since HTTP/1.1).
     */
    kHTTPStatusCodeNonAuthoritativeInformation = 203,
    
    /*!
     * 204 No Content.
     */
    kHTTPStatusCodeNoContent = 204,
    
    /*!
     * 205 Reset Content.
     */
    kHTTPStatusCodeResetContent = 205,
    
    /*!
     * 206 Partial Content.
     */
    kHTTPStatusCodePartialContent = 206,
    
    /*!
     * 207 Multi-Status (WebDAV; RFC 4918).
     */
    
    kHTTPStatusCodeMultiStatus = 207,
    /*!
     * 208 Already Reported (WebDAV; RFC 5842).
     */
    kHTTPStatusCodeAlreadyReported = 208,
    
    /*!
     * 226 IM Used (RFC 3229)
     */
    kHTTPStatusCodeIMUsed = 226,
    
    /*!
     * 250 Low on Storage Space (RTSP; RFC 2326).
     */
    kHTTPStatusCodeLowOnStorageSpace = 250,
    
    /*!-------------------------------------------------
     * @name 3xx Redirection
     *------------------------------------------------*/
    
    /*!
     * 300 Multiple Choices.
     */
    kHTTPStatusCodeMultipleChoices = 300,
    
    /*!
     * 301 Moved Permanently.
     */
    kHTTPStatusCodeMovedPermanently = 301,
    
    /*!
     * 302 Found.
     */
    kHTTPStatusCodeFound = 302,
    
    /*!
     * 303 See Other (since HTTP/1.1).
     */
    kHTTPStatusCodeSeeOther = 303,
    
    /*!
     * 304 Not Modified.
     */
    kHTTPStatusCodeNotModified = 304,
    
    /*!
     * 305 Use Proxy (since HTTP/1.1).
     */
    kHTTPStatusCodeUseProxy = 305,
    
    /*!
     * 306 Switch Proxy.
     */
    kHTTPStatusCodeSwitchProxy = 306,
    
    /*!
     * 307 Temporary Redirect (since HTTP/1.1).
     */
    kHTTPStatusCodeTemporaryRedirect = 307,
    
    /*!
     * 308 Permanent Redirect (approved as experimental RFC).
     */
    kHTTPStatusCodePermanentRedirect = 308,
    
    /*!-------------------------------------------------
     * @name 4xx Client Error
     *------------------------------------------------*/
    
    /*!
     * 400 Bad Request.
     */
    kHTTPStatusCodeBadRequest = 400,
    
    /*!
     * 401 Unauthorized.
     */
    kHTTPStatusCodeUnauthorized = 401,
    
    /*!
     * 402 Payment Required.
     */
    kHTTPStatusCodePaymentRequired = 402,
    
    /*!
     * 403 Forbidden.
     */
    kHTTPStatusCodeForbidden = 403,
    
    /*!
     * 404 Not Found.
     */
    kHTTPStatusCodeNotFound = 404,
    
    /*!
     * 405 Method Not Allowed.
     */
    kHTTPStatusCodeMethodNotAllowed = 405,
    
    /*!
     * 406 Not Acceptable.
     */
    kHTTPStatusCodeNotAcceptable = 406,
    
    /*!
     * 407 Proxy Authentication Required.
     */
    kHTTPStatusCodeProxyAuthenticationRequired = 407,
    
    /*!
     * 408 Request Timeout.
     */
    kHTTPStatusCodeRequestTimeout = 408,
    
    /*!
     * 409 Conflict.
     */
    kHTTPStatusCodeConflict = 409,
    
    /*!
     * 410 Gone.
     */
    kHTTPStatusCodeGone = 410,
    
    /*!
     * 411 Length Required.
     */
    kHTTPStatusCodeLengthRequired = 411,
    
    /*!
     * 412 Precondition Failed.
     */
    kHTTPStatusCodePreconditionFailed = 412,
    
    /*!
     * 413 Request Entity Too Large.
     */
    kHTTPStatusCodeRequestEntityTooLarge = 413,
    
    /*!
     * 414 Request-URI Too Long.
     */
    kHTTPStatusCodeRequestURITooLong = 414,
    
    /*!
     * 415 Unsupported Media Type.
     */
    kHTTPStatusCodeUnsupportedMediaType = 415,
    
    /*!
     * 416 Requested Range Not Satisfiable.
     */
    kHTTPStatusCodeRequestedRangeNotSatisfiable = 416,
    
    /*!
     * 417 Expectation Failed.
     */
    kHTTPStatusCodeExpectationFailed = 417,
    
    /*!
     * 418 I'm a teapot (RFC 2324).
     */
    kHTTPStatusCodeImATeapot = 418,
    
    /*!
     * 420 Enhance Your Calm (Twitter).
     */
    kHTTPStatusCodeEnhanceYourCalm = 420,
    
    /*!
     * 422 Unprocessable Entity (WebDAV; RFC 4918).
     */
    kHTTPStatusCodeUnprocessableEntity = 422,
    
    /*!
     * 423 Locked (WebDAV; RFC 4918).
     */
    kHTTPStatusCodeLocked = 423,
    
    /*!
     * 424 Failed Dependency (WebDAV; RFC 4918).
     */
    kHTTPStatusCodeFailedDependency = 424,
    
    /*!
     * 425 Unordered Collection (Internet draft).
     */
    kHTTPStatusCodeUnorderedCollection = 425,
    
    /*!
     * 426 Upgrade Required (RFC 2817).
     */
    kHTTPStatusCodeUpgradeRequired = 426,
    
    /*!
     * 428 Precondition Required (RFC 6585).
     */
    kHTTPStatusCodePreconditionRequired = 428,
    
    /*!
     * 429 Too Many Requests (RFC 6585).
     */
    kHTTPStatusCodeTooManyRequests = 429,
    
    /*!
     * 431 Request Header Fields Too Large (RFC 6585).
     */
    kHTTPStatusCodeRequestHeaderFieldsTooLarge = 431,
    
    /*!
     * 444 No Response (Nginx).
     */
    kHTTPStatusCodeNoResponse = 444,
    
    /*!
     * 449 Retry With (Microsoft).
     */
    kHTTPStatusCodeRetryWith = 449,
    
    /*!
     * 450 Blocked by Windows Parental Controls (Microsoft).
     */
    kHTTPStatusCodeBlockedByWindowsParentalControls = 450,
    
    /*!
     * 451 Parameter Not Understood (RTSP).
     */
    kHTTPStatusCodeParameterNotUnderstood = 451,
    
    /*!
     * 451 Unavailable For Legal Reasons (Internet draft).
     */
    kHTTPStatusCodeUnavailableForLegalReasons = 451,
    
    /*!
     * 451 Redirect (Microsoft).
     */
    kHTTPStatusCodeRedirect = 451,
    
    /*!
     * 452 Conference Not Found (RTSP).
     */
    kHTTPStatusCodeConferenceNotFound = 452,
    
    /*!
     * 453 Not Enough Bandwidth (RTSP).
     */
    kHTTPStatusCodeNotEnoughBandwidth = 453,
    
    /*!
     * 454 Session Not Found (RTSP).
     */
    kHTTPStatusCodeSessionNotFound = 454,
    
    /*!
     * 455 Method Not Valid in This State (RTSP).
     */
    kHTTPStatusCodeMethodNotValidInThisState = 455,
    
    /*!
     * 456 Header Field Not Valid for Resource (RTSP).
     */
    kHTTPStatusCodeHeaderFieldNotValidForResource = 456,
    
    /*!
     * 457 Invalid Range (RTSP).
     */
    kHTTPStatusCodeInvalidRange = 457,
    
    /*!
     * 458 Parameter Is Read-Only (RTSP).
     */
    kHTTPStatusCodeParameterIsReadOnly = 458,
    
    /*!
     * 459 Aggregate Operation Not Allowed (RTSP).
     */
    kHTTPStatusCodeAggregateOperationNotAllowed = 459,
    
    /*!
     * 460 Only Aggregate Operation Allowed (RTSP).
     */
    kHTTPStatusCodeOnlyAggregateOperationAllowed = 460,
    
    /*!
     * 461 Unsupported Transport (RTSP).
     */
    kHTTPStatusCodeUnsupportedTransport = 461,
    
    /*!
     * 462 Destination Unreachable (RTSP).
     */
    kHTTPStatusCodeDestinationUnreachable = 462,
    
    /*!
     * 494 Request Header Too Large (Nginx).
     */
    kHTTPStatusCodeRequestHeaderTooLarge = 494,
    
    /*!
     * 495 Cert Error (Nginx).
     */
    kHTTPStatusCodeCertError = 495,
    
    /*!
     * 496 No Cert (Nginx).
     */
    kHTTPStatusCodeNoCert = 496,
    
    /*!
     * 497 HTTP to HTTPS (Nginx).
     */
    kHTTPStatusCodeHTTPToHTTPS = 497,
    
    /*!
     * 499 Client Closed Request (Nginx).
     */
    kHTTPStatusCodeClientClosedRequest = 499,
    
    /*!-------------------------------------------------
     * @name 5xx Server Error
     *------------------------------------------------*/
    
    /*!
     * 500 Internal Server Error.
     */
    kHTTPStatusCodeInternalServerError = 500,
    
    /*!
     * 501 Not Implemented
     */
    kHTTPStatusCodeNotImplemented = 501,
    
    /*!
     * 502 Bad Gateway.
     */
    kHTTPStatusCodeBadGateway = 502,
    
    /*!
     * 503 Service Unavailable.
     */
    kHTTPStatusCodeServiceUnavailable = 503,
    
    /*!
     * 504 Gateway Timeout.
     */
    kHTTPStatusCodeGatewayTimeout = 504,
    
    /*!
     * 505 HTTP Version Not Supported.
     */
    kHTTPStatusCodeHTTPVersionNotSupported = 505,
    
    /*!
     * 506 Variant Also Negotiates (RFC 2295).
     */
    kHTTPStatusCodeVariantAlsoNegotiates = 506,
    
    /*!
     * 507 Insufficient Storage (WebDAV; RFC 4918).
     */
    kHTTPStatusCodeInsufficientStorage = 507,
    
    /*!
     * 508 Loop Detected (WebDAV; RFC 5842).
     */
    kHTTPStatusCodeLoopDetected = 508,
    
    /*!
     * 509 Bandwidth Limit Exceeded (Apache bw/limited extension).
     */
    kHTTPStatusCodeBandwidthLimitExceeded = 509,
    
    /*!
     * 510 Not Extended (RFC 2774).
     */
    kHTTPStatusCodeNotExtended = 510,
    
    /*!
     * 511 Network Authentication Required (RFC 6585).
     */
    kHTTPStatusCodeNetworkAuthenticationRequired = 511,
    
    /*!
     * 551 Option not supported (RTSP).
     */
    kHTTPStatusCodeOptionNotSupported = 551,
    
    /*!
     * 598 Network read timeout error (Unknown).
     */
    kHTTPStatusCodeNetworkReadTimeoutError = 598,
    
    /*!
     * 599 Network connect timeout error (Unknown).
     */
    kHTTPStatusCodeNetworkConnectTimeoutError = 599,
    
    
    /*!-------------------------------------------------
     * @name TTX Error
     *------------------------------------------------*/
    kHTTPStatusCodeBadArgument = 405,
    
    kHTTPStatusCodeBadVerifyCode = 408,
    
    kHTTPStatusCodeZoneAccessDenied = 430,
    
    kHTTPStatusCodeLoginFromOtherDevice = 433,
    
};

#endif
