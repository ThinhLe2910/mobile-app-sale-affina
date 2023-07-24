#  Changelog
All notable changes to this project will be documented in this file.

## [2.7.3] - 2022-08-05
### Updated
- Updated validation expire date message in installment method.  
- Handled callback in case `invalidParams` & call API failed in Init View.
- Added toolBar for keyboard in Enter Card Info screen.
- Added `(optional)` to `Email` field.
- Fixed issue `Email` field is hidden by keyboard.
- Fixed issue don't dismiss SDK when count down time is timeout.
- Updated confirmation screen for installment method.
- Updated `paymentFee` api to v6.
- Updated `enroll` api to v7.

## [2.7.2] - 2022-07-28
### Updated
- Update confirm message to leave in QRBank screen.  

## [2.7.1] - 2022-07-11
### Updated
- Added 2 cases `partialPayment` & `overpayment` status for order in `QRBank` method.
- Updated `createPreOrder` api to v5.
- Updated `getOrderInfo` api to v2.
- Added callback when create PreOder failed.
- Fixed loading background view not show full screen
- Supported a phone number with format (+84)

## [2.7.0] - 2022-05-30
### Added
- Added `Recurring Payment` method.
- Added `Copy & Paste` option in the `PayTransfer` method.
- Allowed a partner to pass a specific period of an installment order via `supportedPeriod: Int?` parameter.
- Moved a `CVV` step to the enroll payment flow.

## [2.6.0] - 2022-05-05
### Added
- Added `PayTransfer` method

## [2.5.1] - 2022-04-12
### Changed
- Remove `authToken` property of `PaymentResponseData` model.

## [2.5.0] - 2022-03-30
### Changed
- Updated PayooCore v1.0.12 and defined the specific version in Payment SDK to decouple the marketing version of the framework and the version of Payment SDK.
- Moved the CVV dialog to the confirm screen.
- Re-open the token flow.
- Updated the validation rule of the email.

## [2.4.19] - 2021-11-25
### Changed
- Updated new Core version.
- Fixed GetOrderStatus API loop endlessly in case of app2app.
- Fixed a expiried date is not validated after selecting a period.

## [2.4.18] - 2021-10-15
### Changed
- Fixed issue can't switch merchant when starting a new flow payment.
- Fixed navigation bar is transparent at `QRCodeGuideLineViewController`, webView of `ConfirmViewController`.
- Fixed issue can't redirect another app when pay by `app2app` method.

## [2.4.17] - 2021-10-11
### Changed
- Fixed navigation bar is transparent on iOS 15.

## [2.4.16] - 2021-09-29
### Changed
- Fixed bug server trust policy.

## [2.4.15] - 2021-08-23
### Changed
- Enhanced enroll api and 3ds2 flow
- Supported Citi Bank installment on enroll api
- Enhanced internal/external flow by using `methodDelegateType`, `bankDelegateType`, `cardDelegateType` to detect internal/external flow when select a method, bank or card.
- Enhanced show `SFSafariViewController` instead of external browser when detected user in external flow  
- Fixed black background issue when present `OrderInfoHandlerViewController` in full screen mode

## [2.4.14] - 2021-04-20
### Changed
- Fixed issue showing "Warning Popup - Confirm Payment"
- Updated text in QR Code screen
- Fixed issue paste Card Number with installments method
- Fixed issue when payment failed but return unknow status
- Updated show bottom sheet when filter App2App method

## [2.4.13] - 2021-01-27
### Changed
- Fixed issue that SDK dose not return response to partner in case of cancel

## [2.4.12] - 2021-01-14
### Changed
- Support Exim bank with optional fields.

## [2.4.11] - 2020-12-30
### Fixed
- Fixed issue that SDK do not save token locally in case of payment with cards which bypass authentication (OTP, 3DS, ...)

## [2.4.10]
### Changed
- Allowed a partner to customize font and the style of modal presentation.
- Fixed some issues about saving tokens locally.

## [2.4.9]
### Changed
- Encrypt the authToken and save locally.
- Implement Remove AuthToken API.
- Update GetSupportedBank to v4.

## [2.4.8]
### Changed
- Filtered payment methods for SelectPaymentMethod2 scene.
- Updated Installment method's icon.
- Filtered PaymentToken for SelectPaymentMethod2 scene.
- Bypassed the SelectPaymentMethod2 scene if the PaymentToken and Token method is configured.

## [2.4.7]
### Changed
- Redesigned QRCode scene.
- Updated Payment Unit tests.
- Added appCode configuration.
- Enabled token payment for domestic cards.

## [2.4.6] - 2020-08-04
### Changed
- Added SelectPaymentMethod2.
- Updated EnterCardInfo validation logics.

## [2.4.5] - 2020-07-07
### Changed
- Added PaymentTokenClient.

## [2.4.4] - 2020-06-10
### Changed
- Supported paying via STB by handling post-form data in PaymentWebView.

## [2.4.3] - 2020-05-13
### Changed
- Moved `ImageService` from PayooPayment into PayooCore.

## [2.4.2] - 2020-04-28
### Changed
- Updated message of authentication error with code.

## [2.4.1] - 2020-04-21
### Changed
- Fixed UI element colors not same as configuration.

## [2.4.0] - 2020-04-16
### Changed
- Migrated `UIWebView` to `WKWebView`
- Added new environment configurations.
- Added accessiblity id to key elements on screen.
- Added `Vietjet` booking feature.
- Added `App2App` payment method.
- Updated `GetPaymentToken` api to v2.
- Updated `GetPaymentMethod` api to v2.
- Updated `SelectPaymentMethod` UI.
- Updated `GetOrderInfo` api to v1/order.
- Updated `QRCodeItem` model.

## [2.3.0] - 2019-11-15
### Changed
- Opened Tokenization.
- Added QRCode payment method.
- Configured showing `PoweredByPayoo` view and `PaymentResult` scene.
- Made email field optional.
- Updated createPreOrder Api with transactionTypeCode.
- Fixed connection error when executing a request in applicationWillEnterForeground
- Fixed some UI issues.
- Updated new UI.

## [2.2.0]
### Changed
- Handled cases that users get back from web browser abnormally.
- Handled opening wrong app link.
- Handled order status in OrderResult scene.
- Added `GetOrderInfo` api.
- Updated new UI.

## [2.1.1] - 2019-02-14
### Fixed
- Opened webview in case a URL string was encoded or not.

## [2.1.0] - 2019-01-25
### Changed
- Updated `GetPaymentFee` api.

### Fixed
- Fixed bugs related to payment via the card because the webview doesn't enable cookies in the production environment. 
- Fixed missing query items in the URL when open a browser.

### Added
- Supported to looking for the nearest stores. 

## [2.0.2] - 2018-12-12
### Fixed
- Fixed webview continue to load URL after received response data.

## [2.0.1] - 2018-11-28
### Changed, Fixed
- Fixed some UI bugs.
- Showed a loading view instead of a hub when calling to SDK.
- Changed `Int` to `PaymentMethodOption` type of `supportedPaymentMethods` parameter in `PaymentConfig`
- Changed `Int` to `NSNumber` type of  `supportedPaymentMethods` parameter in `Payoo.pay(orderRequest:paymentConfig:completionHandler:)` function.

## [2.0.0] - 2018-09-12
### Changed
- Added `bankCode` parameter to `PaymentConfig` class to payment with the specified bank. 

## [2.0.0] - 2018-06-14
### Changed
- Added `totalAmount` and `paymentFee` parameters in `ResponseObject` class.

## [2.0.0] - 2018-05-04
### Security, Fixed
- Verified received data to be sure that it can not be changed in the connection.
- Updated UI and fixed issues.

## [1.0.1] - 2018-01-29
### Changed
- Updated API

## [1.0.0] - 2017-11-17
### Added
- Supported payment via Domestic card, International card, eWallet and Pay at store. 

