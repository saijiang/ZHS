//
//  PartnerConfig.h
//  AlipaySdkDemo
//
//  Created by ChaoGanYing on 13-5-3.
//  Copyright (c) 2013年 RenFei. All rights reserved.
//
//  提示：如何获取安全校验码和合作身份者id
//  1.用您的签约支付宝账号登录支付宝网站(www.alipay.com)
//  2.点击“商家服务”(https://b.alipay.com/order/myorder.htm)
//  3.点击“查询合作者身份(pid)”、“查询安全校验码(key)”
//

#ifndef MQPDemo_PartnerConfig_h
#define MQPDemo_PartnerConfig_h

//合作身份者id，以2088开头的16位纯数字
#define PartnerID @"2088021279474550"
//收款支付宝账号
#define SellerID  @"system@wudiniao.com"

//安全校验码（MD5）密钥，以数字和字母组成的32位字符
//#define MD5_KEY @"xc5ps6hljt6w05srl3f3d79rekki8flm"

//商户私钥，自助生成PartnerPrivKey
#define PartnerPrivKey @"MIICeAIBADANBgkqhkiG9w0BAQEFAASCAmIwggJeAgEAAoGBAMq7JicNr8UHeaPZHR5o28jFWSr3RtVJ2Z9mvwN/IvZF8P48Moj8idm+gOkDMAO8DlcMXDZqd6Z9UhecLzByHEo1n1IQ8oKasqWY3kwNmZJmsaxFiMhKsPabCPu9V+sXTGFMQZESUQcmZ0YqVbWRBNFGHQLxhxRiyfOyoDg+eUtbAgMBAAECgYEAptUUNJdCynW4WGnXWKsaE0K0enM7y1IW0OKQ1qPNdbVg+Rc4zxpjptjq5NZGsQwVEPWO/Qjopg4DfIJ/IvME62PI3OsJ0Kpsoyvh6PAJSdPraOwWOD7nf+EolmfQToY7SR7dDx80gBU8OxXqe5paWIeHTEam+6gfUiIVKmOmgWECQQD9zMdkUGjJ8yWRYf3ZQL5N4JI5R9oqTpL45VQGLkceX6/W7YH95q4cC3f9G7zGFPWC16x6ZLnKWUQztfAtEQ/nAkEAzH0KXI12qPu85hBEK5CCFj9pVuUlZFbtSPmGfI5pZ6DhtnZDigp3rVJKmz94iE2By0i8weOXYG8KvXE4DuWKbQJAEnH+j8jURNEaCt3fUBnHeut2VRlmvqplPheUqrpUSt3TbsBmMSjBwKIIv2lzp8XALhk0nNSTOCSSs1tmsC/MQwJBAIraGTARatKB5Zm+z9tZC8w5kLjNbh99GzCjJtvrA823I6z3DxNr2inZqAlVBu5e2tSDdpCdjwuPOxa6C1uqJ90CQQDBk80w5AZJZyS1gRmUaWd/fabChVWfHmU1nh0QI3jOcIYCi/TqOLnI9v0NyAOJhlrSJF/f7PSDN4dJWa78oT3F"

//支付宝公钥
#define AlipayPubKey   @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCnxj/9qwVfgoUh/y2W89L6BkRAFljhNhgPdyPuBV64bfQNN1PjbCzkIM6qRdKBoLPXmKKMiFYnkd6rAoprih3/PrQEB/VsW8OoM8fxn67UDYuyBTqA23MML9q1+ilIZwBC2AQ2UBVOrFXfFl75p6/B5KsiNG9zpgmLCUYuLkxpLQIDAQAB"


#define TELE @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCnxj/9qwVfgoUh/y2W89L6BkRAFljhNhgPdyPuBV64bfQNN1PjbCzkIM6qRdKBoLPXmKKMiFYnkd6rAoprih3/PrQEB/VsW8OoM8fxn67UDYuyBTqA23MML9q1+ilIZwBC2AQ2UBVOrFXfFl75p6/B5KsiNG9zpgmLCUYuLkxpLQIDAQAB"



#endif
