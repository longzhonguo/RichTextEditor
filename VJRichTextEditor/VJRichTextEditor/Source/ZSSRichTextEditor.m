//
//  ZSSRichTextEditorViewController.m
//  ZSSRichTextEditor
//
//  Created by Nicholas Hubbard on 11/30/13.
//  Copyright (c) 2013 Zed Said Studio. All rights reserved.
//


#import "ZSSRichTextEditor.h"
#import "KWEditorBar.h"
#import "KWFontStyleBar.h"
#import "DPCFontStyleBar.h"
#import "WKWebView+VJJSTool.h"
#import "WKWebView+HackishAccessoryHiding.h"
#import "NSString+VJUUID.h"
#import "DPCChooseCoverView.h"
#import "UIControl+KWButtonExtension.h"

#define EditorHeight 264
#define pDeviceWidth [UIScreen mainScreen].bounds.size.width
#define pDeviceHeight [UIScreen mainScreen].bounds.size.height
//状态栏高度
#define pStatusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height
//导航栏高度
#define pNavigationHeight self.navigationController.navigationBar.frame.size.height
//tabbar 高度
#define pTabbarHeight self.tabBarController.tabBar.frame.size.height

#define COLOR(r,g,b,a) ([UIColor colorWithRed:(float)r/255.f green:(float)g/255.f blue:(float)b/255.f alpha:a])

@import JavaScriptCore;


@interface ZSSRichTextEditor ()<KWEditorBarDelegate,KWFontStyleBarDelegate, DPCFontStyleBarDelegate, WKNavigationDelegate,WKUIDelegate, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate,WKScriptMessageHandler, UIScrollViewDelegate, UIWebViewDelegate>

/*
 *  BOOL for holding if the resources are loaded or not
 */
@property (nonatomic) BOOL resourcesLoaded;

/*
 *  Alert View used when inserting links/images
 */
@property (nonatomic, strong) UIAlertView *alertView;

/*
 *  NSString holding the html
 */
@property (nonatomic, strong) NSString *internalHTML;


/*
 *  BOOL for if the editor is loaded or not
 */
@property (nonatomic) BOOL editorLoaded;

/*
 *  Image Picker for selecting photos from users photo library
 */
@property (nonatomic, strong) UIImagePickerController *imagePicker;

/*
 *  Method for getting a version of the html without quotes
 */
- (NSString *)removeQuotesFromHTML:(NSString *)html;

/*
 *  Method for getting a tidied version of the html
 */
- (void)tidyHTML:(NSString *)html complete:(callBack)block;

@property (nonatomic,copy) NSString *vj_columnText;
@property (nonatomic, assign) CGFloat sjTime;// 键盘落下的时长
@property (nonatomic, assign) CGFloat jpHeight;//键盘的高
@property (nonatomic, strong) UILabel *numInputLab;
@property (nonatomic, strong) DPCChooseCoverView *coverView;
@property (nonatomic, strong) UIView *bottomBgV;
@property (nonatomic, assign) BOOL clickFontFlag;//区分键盘落下的原因: YES 点击字体按钮; NO 滚动页面
@end

/*
 
 ZSSRichTextEditor
 
 */
@implementation ZSSRichTextEditor

#pragma mark - liftcycle
- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.formatHTML = YES;
    self.isEditorScrollEnd = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    [self initConfig];
    
    [self addNotification];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self.editorView.configuration.userContentController addScriptMessageHandler:self name:@"column"];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    [self.editorView.configuration.userContentController removeScriptMessageHandlerForName:@"column"];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    CLog(@"webview的内容高度是%f",self.editorView.scrollView.contentSize.height);
}


-(void)dealloc{
    [self removeNotification];
    
    @try {
        [self.toolBarView removeObserver:self forKeyPath:@"transform"];
    } @catch (NSException *exception)
    {
        NSLog(@"Exception: %@", exception);
    } @finally {
        // Added to show finally works as well
    }
}

#pragma mark -editorbarDelegate
- (void)editorBar:(KWEditorBar *)editorBar didClickIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
//        case 0:{//键盘唤醒与隐藏
//            if (self.toolBarView.transform.ty < 0) {
//                [self.editorView hiddenKeyboard];
//            }else{
//                [self.editorView focusTextEditor];
//            }
//        }
//            break;
        case 0:{//字体
            editorBar.fontButton.selected = !editorBar.fontButton.selected;
            if (editorBar.fontButton.selected) {
                // 选中字体键
                self.fontBar.hidden = NO;
                if (editorBar.top == SCREEN_H - CL_iPhoneXBottomSafeHeight - KWEditorBar_Height) {
                    // 低位点选字体按钮
                    self.jpHeight = self.jpHeight==0?271:self.jpHeight;
                    editorBar.top = SCREEN_H - CL_iPhoneXBottomSafeHeight - KWEditorBar_Height - self.jpHeight;
                    self.fontBar.top = editorBar.bottom;
                }else{
                    // 高位点选字体按钮
                    self.clickFontFlag = YES;
                    [self.editorView hiddenKeyboard];
                }
            }else{
                // 取消字体键选中
                self.fontBar.hidden = YES;
                editorBar.top = SCREEN_H - CL_iPhoneXBottomSafeHeight - KWEditorBar_Height;
            }
        }
            break;
        case 1:{//H1
            [self.editorView heading1];
        }
            break;
        case 2:{//H2
            [self.editorView heading2];
        }
            break;
        case 3:{//无序列
            [self.editorView setUnorderedList];
        }
            break;
        case 4:{//有序列
            [self.editorView setOrderedList];
        }
            break;
        case 5:{//图片
            [self insertImage];
        }
            break;
        case 6:{//竖线
            
        }
            break;
        case 7:{//后退
            [self.editorView undo];
        }
            break;
        case 8:{//前进
            [self.editorView redo];
        }
            break;
        default:
            break;
    }
    
}

#pragma mark - fontbardelegate
- (void)fontBar:(DPCFontStyleBar *)fontBar didClickBtn:(UIButton *)button{
    if (self.toolBarView.transform.ty>=0) {
        [self.editorView showKeyboardContent];
    }
    [self.editorView focusTextEditor];
    
    CLog(@"点击了button %@", button.orderTag);
    if ([@"bold" isEqualToString:button.orderTag]) {
        //粗体
        [self.editorView setBold];
    } else if ([@"italic" isEqualToString:button.orderTag]) {
        //斜体
        [self.editorView setItalic];
    } else if ([@"underline" isEqualToString:button.orderTag]) {
        //下划线
        [self.editorView setUnderline];
    } else if ([button.orderTag hasPrefix:@"bjqcolor_"]) {
        NSString *cStr = [button.orderTag substringFromIndex:9];
        [self.editorView setTextColor:cStr];
    }
//    else if ([@"" isEqualToString:button.orderTag]) {
//
//    }
    
//    switch (button.tag) {
//        case 0:{
//            //粗体
//            [self.editorView setBold];
//        }
//            break;
//        case 1:{//下划线
//            [self.editorView setUnderline];
//        }
//            break;
//        case 2:{//斜体
//            [self.editorView setItalic];
//        }
//            break;
//        case 3:{//14号字体
//            [self.editorView setFontSize:@"2"];
//        }
//            break;
//        case 4:{//16号字体
//            [self.editorView setFontSize:@"3"];
//        }
//            break;
//        case 5:{//18号字体
//            [self.editorView setFontSize:@"4"];
//        }
//            break;
//        case 6:{//左对齐
//            [self.editorView alignLeft];
//        }
//            break;
//        case 7:{//居中对齐
//            [self.editorView alignCenter];
//        }
//            break;
//        case 8:{//右对齐
//            [self.editorView alignRight];
//        }
//            break;
//        case 9:{//无序
//            [self.editorView setUnorderedList];
//        }
//            break;
//        case 10:{
//            //缩进
//            button.selected = !button.selected;
//            if (button.selected) {
//                [self.editorView setIndent];
//            }else{
//                [self.editorView setOutdent];
//            }
//        }
//            break;
//        case 11:{
//
//        }
//            break;
//        default:
//            break;
//    }
    
}

#pragma mark - KWFontStyleBarDelegate
- (void)fontBarResetNormalFontSize{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.editorView setFontSize:@"3"];
    });
}

#pragma mark - notification
-(void)addNotification{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

-(void)removeNotification{
    [[NSNotificationCenter defaultCenter]removeObserver:self];;
}

#pragma mark - keyboard
- (void)keyBoardWillChangeFrame:(NSNotification*)notification{
    CGRect frame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    self.sjTime = duration;
    if (frame.origin.y == pDeviceHeight) {
        // 键盘落下
        self.bottomBgV.hidden = NO;
        
        [UIView animateWithDuration:duration animations:^{
//            self.toolBarView.keyboardButton.selected = NO;
            if (self.clickFontFlag) {
                // 点击字体键, 唤醒字体页面, 键盘落下
//                self.fontBar.hidden = NO;
                self.fontBar.top = self.toolBarView.bottom;
            }else{
                // 字体键未选中, 滚动时键盘落下
                self.toolBarView.top =  SCREEN_H - CL_iPhoneXBottomSafeHeight - KWEditorBar_Height;
                [self refreshEditorViewWithMaxHeight];
                self.fontBar.hidden = YES;
                self.clickFontFlag = NO;
            }
            
            static int a = 0;
            if (a != 0) {
                [self.editorView hiddenKeyboard];
            }
            a++;
            
        }];
    }else{
        // 键盘抬起
        float height = pDeviceHeight-pStatusBarHeight-pNavigationHeight-self.toolBarView.frame.size.height-frame.size.height;
        self.jpHeight = frame.size.height;
        [self.editorView setContentHeight: height];
        
        self.bottomBgV.hidden = YES;
        self.toolBarView.fontButton.selected = NO;
        self.fontBar.hidden = YES;
        
        [UIView animateWithDuration:duration animations:^{
//            self.toolBarView.transform = CGAffineTransformMakeTranslation(0, -frame.size.height+CL_iPhoneXBottomSafeHeight);
            self.toolBarView.top = SCREEN_H-frame.size.height-KWEditorBar_Height;
//            self.toolBarView.keyboardButton.selected = YES;
            if (self.editorView.scrollView.contentSize.height > EditorHeight) {
                self.isEditorScrollEnd = NO;
            }else{
                self.isEditorScrollEnd = YES;
            }
//            if (self.wakeupKeyboard) {
//                self.wakeupKeyboard();
//            }
//            self.editorView.frame = CGRectMake(0, 0, pDeviceWidth, SCREEN_H-KWEditorBar_Height-40-20-8-CL_iPhoneXBottomSafeHeight-LL_StatusBarAndNavigationBarHeight);
//            [self reloadBottomView];
            [self refreshEditorViewWithFixedHeight];
        } completion:^(BOOL finished) {
            CLog(@"偏移量%f", self.superScrollOffsetH);
            if (self.superScrollOffsetH > 0) {
    //            CGRect rect = self.editorView.frame;
    //            rect.origin.y = 0;
    //            self.editorView.frame = rect;
            }
        }];
    }
}

- (void)reloadBottomView{
    [UIView animateWithDuration:self.sjTime animations:^{
        CGRect rect = self.numInputLab.frame;
        rect.origin.y = self.editorView.bottom;
        self.numInputLab.frame = rect;
        
        CGRect rect1 = self.coverView.frame;
        rect1.origin.y = self.editorView.bottom+20+8;
        self.coverView.frame = rect1;
        
        self.view.height = self.editorView.height + 28 +self.coverView.height;
    }];
    
}

// 键盘弹起时, 展示editorview的固定高度
- (void)refreshEditorViewWithFixedHeight{
    CGRect rect = self.editorView.frame;
    rect.size.height = EditorHeight;
    self.editorView.frame = rect;
    
    [self reloadBottomView];
}

// 键盘落下时, 展示editorview的最大高度
- (void)refreshEditorViewWithMaxHeight{
    CGFloat maxheight = SCREEN_H-LL_StatusBarAndNavigationBarHeight-CL_iPhoneXBottomSafeHeight-44-12-24-8-20;
    CGRect rect = self.editorView.frame;
    if (self.editorView.scrollView.contentSize.height > maxheight) {
        rect.size.height = maxheight;
    }else if (self.editorView.scrollView.contentSize.height > EditorHeight) {
        rect.size.height = self.editorView.scrollView.contentSize.height;
    }else{
        rect.size.height = EditorHeight;
    }
    self.editorView.frame = rect;
    
    [self reloadBottomView];
}

//- (void)reloadEditorViewWithNewHeith:(CGFloat)newHeight{
//    if (newHeight<=0) {
//        return;
//    }
//    CGRect rect = self.editorView.frame;
////    rect.size.height = newHeight;
//    self.editorView.frame = rect;
//
//    [self reloadBottomView];
//}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    CLog(@"KVO的keyPath >>> %@",keyPath);
    if([keyPath isEqualToString:@"transform"]){
        if (!self.toolBarView.fontButton.selected) {
//            CGRect fontBarFrame = self.fontBar.frame;
//            fontBarFrame.origin.y = CGRectGetMaxY(self.toolBarView.frame);
//            self.fontBar.frame = fontBarFrame;
        }
        
    }else if([keyPath isEqualToString:@"URL"]){
        NSString *urlString = self.editorView.URL.absoluteString;
        NSLog(@"URL------%@",urlString);
        [self handleEvent:urlString];
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
    //根据内容的高重置webView视图的高度
//    NSLog(@"Height is changed! new=%@", [change valueForKey:NSKeyValueChangeNewKey]);
//    NSLog(@"tianxia :%@",NSStringFromCGSize(self.editorView.scrollView.contentSize));
//    CGFloat newHeight = self.editorView.scrollView.contentSize.height;
//    [self reloadEditorViewWithNewHeith:newHeight];
    
    WS(weakSelf);
    [self getText:^(NSString *html) {
        CLog(@"当前文本是:%@", html);
        [weakSelf refreshNumLableWithString:html];
    }];
    

}

- (void)refreshNumLableWithString:(NSString *)inputStr{
    NSString *str = @"最多可以输入2000个字哦";
    int num = (int)inputStr.length;
    if (num == 0) {
        self.numInputLab.text = str;
    }else if (num <= 200) {
        self.numInputLab.text = [NSString stringWithFormat:@"%d", num];
    }else{
        self.numInputLab.text = [NSString stringWithFormat:@"已超过%d个字", num-200];
    }
}

//处理键盘工具条显示与隐藏
- (void)handleEvent:(NSString *)urlString{
    
    if ([urlString hasPrefix:@"state-title://"] || [urlString hasPrefix:@"state-abstract-title://"]) {
        self.fontBar.hidden = YES;
        self.toolBarView.hidden = YES;
    }else if([urlString rangeOfString:@"callback://0/"].location != NSNotFound){
//        self.fontBar.hidden = NO;
        self.toolBarView.hidden = NO;
        //更新 toolbar
        NSString *className = [urlString stringByReplacingOccurrencesOfString:@"callback://0/" withString:@""];
        [self.fontBar updateFontBarWithButtonName:className];
    }
    
}

#pragma mark - Editor Interaction

- (void)setPlaceholderText {
    if (self.placeholder != NULL && [self.placeholder length] != 0) {
        [self.editorView setPlaceholderTextWith:self.placeholder];
    }
}

- (void)setHTML:(NSString *)html {
    
    self.internalHTML = html;
    
    if (self.editorLoaded) {
        [self updateHTML];
    }
    
}

- (void)updateHTML {
    NSString *html = self.internalHTML;
    //    self.sourceView.text = html;
    NSString *cleanedHTML = [self removeQuotesFromHTML:html];
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.setHTML(\"%@\");", cleanedHTML];
    [self.editorView evaluateJavaScript:trigger completionHandler:nil];

}

- (void)getHTML:(callBack)block {
    
    [self.editorView evaluateJavaScript:@"zss_editor.getHTML();" completionHandler:^(id _Nullable html, NSError * _Nullable error) {
        
        
        if (error != NULL) {
            NSLog(@"HTML Parsing Error: %@", error);
        }
               
        
        html = [self removeQuotesFromHTML:html];
        
        [self tidyHTML:html complete:^(NSString *html) {
            block(html);
        }];
        
    }];
    
}

- (void)insertHTML:(NSString *)html {
    
    NSString *cleanedHTML = [self removeQuotesFromHTML:html];
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.insertHTML(\"%@\");", cleanedHTML];
    [self.editorView evaluateJavaScript:trigger completionHandler:nil];
}

- (void)getText:(callBack)block {
    
    [self.editorView evaluateJavaScript:@"zss_editor.getText();" completionHandler:^(id _Nullable html, NSError * _Nullable error) {
        
        block(html);
    }];
    }

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)removeFormat {
    NSString *trigger = @"zss_editor.removeFormating();";
    [self.editorView evaluateJavaScript:trigger completionHandler:nil];
}


#pragma mark - 插入链接
- (void)insertLink {
    
    if (self.toolBarView.transform.ty >= 0) {
        [self.editorView focusTextEditor];
    }
    [self.editorView prepareInsertImage];
    [self showInsertLinkDialogWithLink:nil title:nil];
}


- (void)showInsertLinkDialogWithLink:(NSString *)url title:(NSString *)title {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"插入链接" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"URL (必填)";
        if (url) {
            textField.text = url;
        }
        textField.rightViewMode = UITextFieldViewModeAlways;
        textField.clearButtonMode = UITextFieldViewModeAlways;
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"名称";
        textField.clearButtonMode = UITextFieldViewModeAlways;
        textField.secureTextEntry = NO;
        if (title) {
            textField.text = title;
        }
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        UITextField *linkURL = [alertController.textFields objectAtIndex:0];
        UITextField *title = [alertController.textFields objectAtIndex:1];
        [self.editorView insertLink:linkURL.text title:title.text];
        
//      [self.editorView focusTextEditor];
    }]];
    [self presentViewController:alertController animated:YES completion:NULL];
    
}

#pragma mark - 插入图片

-(void)insertImage{
    
    
    [self.editorView prepareInsertImage];
    
    
    UIAlertController *con = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *device = [UIAlertAction actionWithTitle:@"本地相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self insertImageFromDevice];
        }];
    }];
    UIAlertAction *url = [UIAlertAction actionWithTitle:@"网络相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self insertImageFromUrl];
        }];
        
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [con addAction:device];
    [con addAction:url];
    [con addAction:cancel];
    [self presentViewController:con animated:YES completion:nil];
    
}

- (void)insertImageFromDevice {
    
    [self setUpImagePicker];
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

-(void)insertImageFromUrl{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"插入图片链接" message:nil preferredStyle:UIAlertControllerStyleAlert];
       
       [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
           textField.placeholder = @"URL (必填)";
           textField.rightViewMode = UITextFieldViewModeAlways;
           textField.clearButtonMode = UITextFieldViewModeAlways;
       }];
       [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
           textField.placeholder = @"名称";
           textField.clearButtonMode = UITextFieldViewModeAlways;
           textField.secureTextEntry = NO;
       }];
       
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        UITextField *linkURL = [alertController.textFields objectAtIndex:0];
        UITextField *title = [alertController.textFields objectAtIndex:1];
        
        
        
        if (self.toolBarView.transform.ty >= 0) {
            [self.editorView focusTextEditor];
        }
        
        [self.editorView prepareInsertImage];
        [self.editorView insertImage:linkURL.text alt:title.text];
        
    }]];
    [self presentViewController:alertController animated:YES completion:NULL];
    
    
}

- (void)updateImage:(NSString *)url alt:(NSString *)alt {
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.updateImage(\"%@\", \"%@\");", url, alt];
    [self.editorView evaluateJavaScript:trigger completionHandler:nil];
}

#pragma mark - Image Picker Delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info{
    
    UIImage *selectedImage = info[UIImagePickerControllerEditedImage]?:info[UIImagePickerControllerOriginalImage];
    
    //Scale the image
    CGSize targetSize = CGSizeMake(selectedImage.size.width * 0.5, selectedImage.size.height * 0.5);
    UIGraphicsBeginImageContext(targetSize);
    [selectedImage drawInRect:CGRectMake(0,0,targetSize.width,targetSize.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *scaledImageData = UIImageJPEGRepresentation(scaledImage, 0.8);
    
    //Encode the image data as a base64 string
    NSString *imageBase64String = [scaledImageData base64EncodedStringWithOptions:0];
    
    if (self.toolBarView.transform.ty >= 0) {
        [self.editorView focusTextEditor];
    }
    
    [self.editorView prepareInsertImage];
    [self.editorView insertImageBase64String:imageBase64String alt:@""];
//    [Utils showGlobleHud:nil];
//    [NetworkRequest mediaUploadImage:selectedImage complete:^(NSDictionary *resp, NSError *err) {
//        [Utils hideGlobleHud];
//        if (err) {
//            return ;
//        }
//
//        if (resp[@"url"]) {
//            [self insertImage:resp[@"url"] alt:nil];
//            [self.editorView focusTextEditor];
//        }
//
//    }];
    
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{

    decisionHandler(WKNavigationActionPolicyAllow);
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    
    
    self.editorLoaded = YES;

    if (!self.internalHTML) {
        self.internalHTML = @"";
    }
    [self updateHTML];
    
    if(self.placeholder) {
        [self setPlaceholderText];
    }
    
    
    if (self.vj_columnText) {
        [self setColumnTextWithText:self.vj_columnText];
    }
    
    if (self.vj_hideHTMLTitle) {
        [self.editorView hideHTMLTitle];
    }
    
    if (self.vj_hideHTMLAbstract) {
        [self.editorView hideHTMLAbstract];
    }
    
    if (self.vj_hideColumn) {
        [self.editorView hideColumn];
    }


}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    CGSize actualSize = [webView sizeThatFits:CGSizeZero];

    CGRect newFrame =  webView.frame;
    newFrame.size.height = actualSize.height;
    webView.frame = newFrame;
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSString *requestString = [[[request URL] absoluteString]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"requestString : %@",requestString);
    
    
    NSArray *components = [requestString componentsSeparatedByString:@"|"];
    NSLog(@"=components=====%@",components);
    
    
    NSString *str1 = [components objectAtIndex:0];
    NSLog(@"str1:::%@",str1);
    
    
    NSArray *array2 = [str1 componentsSeparatedByString:@"/"];
    NSLog(@"array2:====%@",array2);
    
    
    NSInteger coun = array2.count;
    NSString *method = array2[coun-1];
    NSLog(@"method:===%@",method);
    
    if ([method isEqualToString:@"InviteBtn1"])//查看详情，其中红色部分是HTML5跟咱们约定好的，相应H5上的按钮的点击事件后，H5发送超链接，客户端一旦收到这个超链接信号。把其中的点击按钮的约定的信号标示符截取出来跟本地的标示符来进行匹配，如果匹配成功，那么就执行相应的操作，详情见如下所示。
    {
//        UZGCustomAlertView *vc= [[UZGCustomAlertView alloc]initWithTitle:self.detailTitle];
//        vc.showImage = NO;
//        [vc show];
        return NO;
    }else if ([method isEqualToString:@"InviteBtn2"])
    {
        
//        _shareVw = [ShareView defaultShareView];
//        [_shareVw setShareContentWithTitle:self.title1 content:self.title2 shareImage:[UIImage imageNamed:@"share.jpg"]  shareURL:self.url2];
//        [_shareVw show];
//        [_shareVw setShareViewBlock:^(BOOL isSuccess) {
//            if (isSuccess) {
//                NSLog(@"分享成功");
//            }else {
//                NSLog(@"分享失败");
//            }
//        }];
//
//        [_shareVw setShareViewCopyBlock:^(BOOL isSuccess) {
//            if (isSuccess) {
//                NSLog(@"复制链接成功");
//            }else {
//                NSLog(@"复制链接失败");
//            }
//        }];
        return NO;
    }
    return YES;
}

#pragma mark - WKUIDelegate
// 显示一个按钮。点击后调用completionHandler回调
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

        completionHandler();
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 显示两个按钮，通过completionHandler回调判断用户点击的确定还是取消按钮
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

// 显示一个带有输入框和一个确定按钮的，通过completionHandler回调用户输入的内容
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        completionHandler(alertController.textFields.lastObject.text);
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    CLog(@"userContentController >> name = %@, body = %@", message.name, message.body);
    //在这里截取H5调用的本地方法
    if ([message.name isEqualToString:@"column"]){
        if (self.superScrollOffsetH > 0) {
            [self.superScrollView setContentOffset:CGPointZero animated:NO];
        }
    }
}

#pragma mark - scrollview的代理

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CLog(@"WebView滚动了>>>%f", scrollView.contentOffset.y);
    
    if (scrollView.contentOffset.y+self.editorView.height>=self.editorView.scrollView.contentSize.height || scrollView.contentOffset.y <= 0) {
        self.isEditorScrollEnd = YES;
    }else{
        self.isEditorScrollEnd = NO;
    }
    
    if (!self.fontBar.hidden) {
        self.fontBar.hidden = YES;
        self.toolBarView.fontButton.selected = NO;
        self.toolBarView.top = SCREEN_H - CL_iPhoneXBottomSafeHeight - KWEditorBar_Height;
    }
    
//    [self refreshEditorViewWithFixedHeight];
}

- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView willDecelerate:(BOOL)decelerate{
    [self dismissKeyboard];
    self.isEditorScrollEnd = YES;
    CLog(@">>>%f",scrollView.contentOffset.y);
    CLog(@">>>%f",self.editorView.frame.size.height);
    CLog(@">>>%f",scrollView.contentSize.height);
//    if (scrollView.contentOffset.y != 0 && scrollView.contentOffset.y + self.editorView.frame.size.height >= scrollView.contentSize.height) {
//        NSLog(@"======");
////        self.isEditorScrollEnd = YES;
//    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self dismissKeyboard];
    self.isEditorScrollEnd = YES;
    CLog(@"<<<%f",scrollView.contentOffset.y);
    CLog(@"<<<%f",self.editorView.frame.size.height);
    CLog(@"<<<%f",scrollView.contentSize.height);
//    // 判断scrollView是否已划到底了
//    if (scrollView.contentOffset.y != 0 && fabs(scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y) < scrollView.contentSize.height * 0.2) {
//          NSLog(@"++++++++++");
////        self.isEditorScrollEnd = YES;
////        [self smallEditorView];
//    }
//    if (scrollView.contentOffset.y != 0 && scrollView.contentOffset.y + self.editorView.frame.size.height >= scrollView.contentSize.height) {
//        NSLog(@"======");
//    }
}

- (void)smallEditorView{
//    // self.wkwebView 高度改变
//    [UIView animateWithDuration:self.sjTime animations:^{
//        CGRect rect = self.editorView.frame;
//        rect.size.height = EditorHeight;//EditorHeight是self.wkwebView的高度
//        self.editorView.frame = rect;
//        [self reloadBottomView];
//    } completion:^(BOOL finished) {
//        //self.wkwebView 高度改变后, 自动滚动到底部
//        [self.editorView.scrollView setContentOffset:CGPointMake(0, self.editorView.scrollView.contentSize.height-EditorHeight)]; //EditorHeight是self.wkwebView的高度
//    }];
}

//-(void)didSelectedColumn{
//    //需要重写
//    CLog(@"((((())))))");
//}

#pragma mark - methods

- (NSString *)removeQuotesFromHTML:(NSString *)html {
    html = [html stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    html = [html stringByReplacingOccurrencesOfString:@"“" withString:@"&quot;"];
    html = [html stringByReplacingOccurrencesOfString:@"”" withString:@"&quot;"];
    html = [html stringByReplacingOccurrencesOfString:@"\r"  withString:@"\\r"];
    html = [html stringByReplacingOccurrencesOfString:@"\n"  withString:@"\\n"];
    return html;
}


- (void)tidyHTML:(NSString *)html complete:(callBack)block{
    html = [html stringByReplacingOccurrencesOfString:@"<br>" withString:@"<br />"];
    html = [html stringByReplacingOccurrencesOfString:@"<hr>" withString:@"<hr />"];
    if (self.formatHTML) {
        NSString *str = [NSString stringWithFormat:@"style_html(\"%@\");", html];
        [self.editorView evaluateJavaScript:str completionHandler:^(id _Nullable returnHtml, NSError * _Nullable error) {
            
            block(returnHtml);
            
        }];
        
        
    }
}

- (NSString *)stringByDecodingURLFormat:(NSString *)string {
    NSString *result = [string stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}

#pragma mark - vj edit
- (void)vj_getHTMLTitle:(callBack)block {
    
    [self.editorView vj_getHTMLTitle:^(NSString * _Nonnull html) {
        block(html);
    }];
}

- (void)vj_getHTMLAbstract:(callBack)block{
    return [self.editorView vj_getHTMLAbstract:^(NSString * _Nonnull html) {
        block(html);
    }];
}

-(void)setColumnTextWithText:(NSString *)text{
    self.vj_columnText = text;
    [self.editorView setColumnTextWithText:text];
}


#pragma mark - 懒加载
// 底部区域, 包括选择封面, 添加学院, 添加标签
- (UIView *)bottomBgV{
    if (!_bottomBgV) {
        _bottomBgV = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-CL_iPhoneXBottomSafeHeight, SCREEN_W, CL_iPhoneXBottomSafeHeight)];
        _bottomBgV.backgroundColor = UIColor.whiteColor;
        _bottomBgV.hidden = NO;
    }
    return _bottomBgV;
}

// 输入区域的字数统计label
- (UILabel *)numInputLab{
    if (!_numInputLab) {
        _numInputLab = [[UILabel alloc] initWithFrame:CGRectMake(16, self.editorView.bottom, SCREEN_W-32, 20)];
        _numInputLab.font = [UIFont getPingFangSCFontRegularWithSize:14];
        _numInputLab.textColor = UIColorFromRGBA(0xD1D3D5, 1);
        _numInputLab.text = @"最多可以输入2000个字哦";
        _numInputLab.textAlignment = NSTextAlignmentRight;
    }
    return _numInputLab;
}

// 选择封面
- (DPCChooseCoverView *)coverView{
    if (!_coverView) {
        _coverView = [[DPCChooseCoverView alloc] initWithFrame:CGRectMake(0, self.numInputLab.bottom+8, SCREEN_W, SCREEN_H)];
        _coverView.userInteractionEnabled = YES;
        [_coverView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickCoverView)]];
    }
    return _coverView;
}

- (void)clickCoverView{
//    self.isEditorScrollEnd = YES;
//    [self dismissKeyboard];
//    [self smallEditorView];
}

-(void)initConfig{
    
    [self.view addSubview:self.editorView];
    [self.view addSubview:self.numInputLab];
    [self.view addSubview:self.coverView];
    [self.view addSubview:self.bottomBgV];
    
    //Load Resources
    if (!self.resourcesLoaded) {
        [self loadResources];
    }
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.toolBarView];
    [[UIApplication sharedApplication].keyWindow addSubview:self.fontBar];
    
    self.toolBarView.delegate = self;
    [self.toolBarView addObserver:self forKeyPath:@"transform" options:
     NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
}

// web富文本输入区域
-(WKWebView *)editorView{
    if (!_editorView) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc]init];
        WKUserContentController *userCon = [[WKUserContentController alloc]init];
        config.userContentController = userCon;
        //self.view.frame.size.height-KWEditorBar_Height-40
        _editorView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, pDeviceWidth, EditorHeight) configuration:config];
        [userCon addScriptMessageHandler:self name:@"column"];
        _editorView.navigationDelegate = self;
        _editorView.UIDelegate = self;
        _editorView.scrollView.delegate = self;
        _editorView.hidesInputAccessoryView = YES;
        _editorView.scrollView.bounces = NO;
        _editorView.backgroundColor = [UIColor whiteColor];
        [_editorView addObserver:self forKeyPath:@"URL" options:NSKeyValueObservingOptionNew context:nil];
        [_editorView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
//        [[_editorView configuration].userContentController addScriptMessageHandler:self name:@"getMessage"];
    }
    return _editorView;
}

// 富文本选择
- (KWEditorBar *)toolBarView{
    if (!_toolBarView) {
        _toolBarView = [KWEditorBar editorBar];
        _toolBarView.frame = CGRectMake(0,self.view.frame.size.height - KWEditorBar_Height-CL_iPhoneXBottomSafeHeight, self.view.frame.size.width, KWEditorBar_Height);
        _toolBarView.backgroundColor = COLOR(237, 237, 237, 1);
    }
    return _toolBarView;
}

- (DPCFontStyleBar *)fontBar{
    if (!_fontBar) {
        _fontBar = [[DPCFontStyleBar alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.toolBarView.frame), self.view.frame.size.width, DPCFontBar_Height)];
        _fontBar.delegate = self;
//        [_fontBar.heading2Item setSelected:YES];
        _fontBar.color_black.selected = YES;
        _fontBar.hidden = YES;
    }
    return _fontBar;
}

#pragma mark 图片选择器

- (void)setUpImagePicker {
    
    if (!self.imagePicker) {
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//        self.imagePicker.allowsEditing = YES;
    }
    
}

- (void)loadResources {
    
    //Create a string with the contents of editor.html
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"editor" ofType:@"html"];
    NSData *htmlData = [NSData dataWithContentsOfFile:filePath];
    NSString *htmlString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    
    //Add jQuery.js to the html file
    NSString *jquery = [[NSBundle mainBundle] pathForResource:@"jQuery" ofType:@"js"];
    NSString *jqueryString = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:jquery] encoding:NSUTF8StringEncoding];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<!-- jQuery -->" withString:jqueryString];
    
    //Add JSBeautifier.js to the html file
    NSString *beautifier = [[NSBundle mainBundle] pathForResource:@"JSBeautifier" ofType:@"js"];
    NSString *beautifierString = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:beautifier] encoding:NSUTF8StringEncoding];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<!-- jsbeautifier -->" withString:beautifierString];
    
    //Add ZSSRichTextEditor.js to the html file
    NSString *source = [[NSBundle mainBundle] pathForResource:@"ZSSRichTextEditor" ofType:@"js"];
    NSString *jsString = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:source] encoding:NSUTF8StringEncoding];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<!--editor-->" withString:jsString];
    
    
    NSString *basePath = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:basePath];
    [self.editorView loadHTMLString:htmlString baseURL:baseURL];
    
    self.resourcesLoaded = YES;
}

@end
