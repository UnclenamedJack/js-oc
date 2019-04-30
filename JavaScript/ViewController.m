//
//  ViewController.m
//  JavaScript
//
//  Created by tianbai on 16/6/8.
//  Copyright © 2016年 厦门乙科网络公司. All rights reserved.
//

#import "ViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>


@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    self.webView.delegate = self;
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSURL* url = [NSURL fileURLWithPath:path];
    NSURLRequest* request = [NSURLRequest requestWithURL:url] ;
    [self.webView loadRequest:request];
    
    [self.view addSubview:self.webView];
    
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"调JS" style:UIBarButtonItemStylePlain target:self action:@selector(rightAction)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.jsContext = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    //定义好JS要调用的方法, share就是调用的share方法名
    self.jsContext [@"share"] = ^() {
        NSLog(@"+++++++Begin Log+++++++");
        NSArray *args = [JSContext currentArguments];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"方式二" message:@"这是OC原生的弹出窗" delegate:self cancelButtonTitle:@"收到" otherButtonTitles:nil];
            [alertView show];
        });
        for (JSValue *jsVal in args) {
            NSLog(@"%@", jsVal.toString);
        }
        
        NSLog(@"-------End Log-------");
    };
    
    
    //    self.jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    self.jsContext[@"tianbai"] = self;
    self.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        context.exception = exception;
        NSLog(@"异常信息：%@",exception);
    };

}


- (void)rightAction
{
    // 不需要JavascriptCore.framwork OC直接调用JS
//    NSString *jsStr = [NSString stringWithFormat:@"showAlert('%@')",@"这里是JS中alert弹出的message"];
//    [_webView stringByEvaluatingJavaScriptFromString:jsStr];
    
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    NSString *textJS = @"showAlert('这里是JS中alert弹出的message')";
    [context evaluateScript:textJS];
    
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    return true;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    self.jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
//    self.jsContext[@"tianbai"] = self;
//    self.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
//        context.exception = exceptionValue;
//        NSLog(@"异常信息：%@", exceptionValue);
//    };
    
}


- (void)call{
    NSLog(@"call");
    // 之后在回调js的方法Callback把内容传出去
//    JSValue *Callback = self.jsContext[@"Callback"];
//    //传值给web端
//    [Callback callWithArguments:@[@"唤起本地OC回调完成"]];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [self presentViewController:picker animated:true completion:nil];
}


- (void)getCall:(NSString *)callString{
    NSLog(@"Get:%@", callString);
    // 成功回调js的方法Callback
    JSValue *Callback = self.jsContext[@"alerCallback"];
    [Callback callWithArguments:@[@"一哈"]];

    
//    直接添加提示框
//    NSString *str = @"alert('OC添加JS提示成功')";
//    [self.jsContext evaluateScript:str];

}

#pragma mark ----

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    
    UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
    NSData *imagedata = UIImageJPEGRepresentation(image, 1);
    NSString *imagedatastr = [imagedata base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    [self removeSpaceAndNewline:imagedatastr];
    NSString *imageString = [self removeSpaceAndNewline:imagedatastr];
    NSString *jsFunctStr = [NSString stringWithFormat:@"rtnCamera('%@')",imageString];
    [self.jsContext evaluateScript:jsFunctStr];
    
//                JSValue *Callback = self.jsContext[@"alerCallback"];
//                [Callback callWithArguments:@[imageString]];

    [picker dismissViewControllerAnimated:true completion:^{

    }];
}
// 图片转成base64字符串需要先取出所有空格和换行符
- (NSString *)removeSpaceAndNewline:(NSString *)str
{
    NSString *temp = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return temp;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
