//
//  UIWebView+FQWebViewJavaScript.m
//  FQBaseKitDemo
//
//  Created by mac on 2019/1/25.
//  Copyright © 2019年 mac. All rights reserved.
//

#import "UIWebView+FQWebViewJavaScript.h"
#import "UIColor+FQCustomColor.h"

@implementation UIWebView (FQWebViewJavaScript)

/**
 *  @brief  获取网页meta信息
 *
 *  @return meta信息
 */
-(NSArray *)fq_getMetaData
{
    NSString *string = [self stringByEvaluatingJavaScriptFromString:@""
                        "var json = '[';                                    "
                        "var a = document.getElementsByTagName('meta');     "
                        "for(var i=0;i<a.length;i++){                       "
                        "   json += '{';                                    "
                        "   var b = a[i].attributes;                        "
                        "   for(var j=0;j<b.length;j++){                    "
                        "       var name = b[j].name;                       "
                        "       var value = b[j].value;                     "
                        "                                                   "
                        "       json += '\"'+name+'\":';                    "
                        "       json += '\"'+value+'\"';                    "
                        "       if(b.length>j+1){                           "
                        "           json += ',';                            "
                        "       }                                           "
                        "   }                                               "
                        "   json += '}';                                    "
                        "   if(a.length>i+1){                               "
                        "       json += ',';                                "
                        "   }                                               "
                        "}                                                  "
                        "json += ']';                                       "];
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError*   error = nil;
    id array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    if(array==nil) NSLog(@"An error occured in meta parser.");
    return array;
}

#pragma mark -
#pragma mark 获取网页中的数据
/// 获取某个标签的结点个数
- (int)fq_nodeCountOfTag:(NSString *)tag
{
    NSString *jsString = [NSString stringWithFormat:@"document.getElementsByTagName('%@').length", tag];
    int len = [[self stringByEvaluatingJavaScriptFromString:jsString] intValue];
    return len;
}
/// 获取当前页面URL
- (NSString *)fq_getCurrentURL
{
    return [self stringByEvaluatingJavaScriptFromString:@"document.location.href"];
}
/// 获取标题
- (NSString *)fq_getTitle
{
    return [self stringByEvaluatingJavaScriptFromString:@"document.title"];
}
/// 获取所有图片链接
- (NSArray *)fq_getImgs
{
    NSMutableArray *arrImgURL = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self fq_nodeCountOfTag:@"img"]; i++) {
        NSString *jsString = [NSString stringWithFormat:@"document.getElementsByTagName('img')[%d].src", i];
        [arrImgURL addObject:[self stringByEvaluatingJavaScriptFromString:jsString]];
    }
    return arrImgURL;
}
/// 获取当前页面所有点击链接
- (NSArray *)fq_getOnClicks
{
    NSMutableArray *arrOnClicks = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self fq_nodeCountOfTag:@"a"]; i++) {
        NSString *jsString = [NSString stringWithFormat:@"document.getElementsByTagName('a')[%d].getAttribute('onclick')", i];
        NSString *clickString = [self stringByEvaluatingJavaScriptFromString:jsString];
        NSLog(@"%@", clickString);
        [arrOnClicks addObject:clickString];
    }
    return arrOnClicks;
}
#pragma mark -
#pragma mark 改变网页样式和行为
/// 改变背景颜色
- (void)fq_setBackgroundColor:(UIColor *)color
{
    NSString * jsString = [NSString stringWithFormat:@"document.body.style.backgroundColor = '%@'",[color fq_webColorString]];
    [self stringByEvaluatingJavaScriptFromString:jsString];
}
/// 为所有图片添加点击事件(网页中有些图片添加无效,需要协议方法配合截取)
- (void)fq_addClickEventOnImg
{
    for (int i = 0; i < [self fq_nodeCountOfTag:@"img"]; i++) {
        //利用重定向获取img.src，为区分，给url添加'img:'前缀
        NSString *jsString = [NSString stringWithFormat:
                              @"document.getElementsByTagName('img')[%d].onclick = \
                              function() { document.location.href = 'img' + this.src; }",i];
        [self stringByEvaluatingJavaScriptFromString:jsString];
    }
}
/// 改变所有图像的宽度
- (void)fq_setImgWidth:(int)size
{
    for (int i = 0; i < [self fq_nodeCountOfTag:@"img"]; i++) {
        NSString *jsString = [NSString stringWithFormat:@"document.getElementsByTagName('img')[%d].width = '%d'", i, size];
        [self stringByEvaluatingJavaScriptFromString:jsString];
        jsString = [NSString stringWithFormat:@"document.getElementsByTagName('img')[%d].style.width = '%dpx'", i, size];
        [self stringByEvaluatingJavaScriptFromString:jsString];
    }
}
/// 改变所有图像的高度
- (void)fq_setImgHeight:(int)size
{
    for (int i = 0; i < [self fq_nodeCountOfTag:@"img"]; i++) {
        NSString *jsString = [NSString stringWithFormat:@"document.getElementsByTagName('img')[%d].height = '%d'", i, size];
        [self stringByEvaluatingJavaScriptFromString:jsString];
        jsString = [NSString stringWithFormat:@"document.getElementsByTagName('img')[%d].style.height = '%dpx'", i, size];
        [self stringByEvaluatingJavaScriptFromString:jsString];
    }
}
/// 改变指定标签的字体颜色
- (void)fq_setFontColor:(UIColor *)color withTag:(NSString *)tagName
{
    NSString *jsString = [NSString stringWithFormat:
                          @"var nodes = document.getElementsByTagName('%@'); \
                          for(var i=0;i<nodes.length;i++){\
                          nodes[i].style.color = '%@';}", tagName, [color fq_webColorString]];
    [self stringByEvaluatingJavaScriptFromString:jsString];
}
/// 改变指定标签的字体大小
- (void)fq_setFontSize:(int)size withTag:(NSString *)tagName
{
    NSString *jsString = [NSString stringWithFormat:
                          @"var nodes = document.getElementsByTagName('%@'); \
                          for(var i=0;i<nodes.length;i++){\
                          nodes[i].style.fontSize = '%dpx';}", tagName, size];
    [self stringByEvaluatingJavaScriptFromString:jsString];
}

#pragma mark -
#pragma mark 删除
/**
 *  根据 ElementsID 删除WebView 中的节点
 */
- (void )fq_deleteNodeByElementID:(NSString *)elementID
{
    [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementById('%@').remove();",elementID]];
}
/**
 *  根据 ElementsClass 删除 WebView 中的节点
 */
- (void)fq_deleteNodeByElementClass:(NSString *)elementClass
{
    NSString *javaScriptString = [NSString stringWithFormat:@"\
                                  function getElementsByClassName(n) {\
                                  var classElements = [],allElements = document.getElementsByTagName('*');\
                                  for (var i=0; i< allElements.length; i++ )\
                                  {\
                                  if (allElements[i].className == n) {\
                                  classElements[classElements.length] = allElements[i];\
                                  }\
                                  }\
                                  for (var i=0; i<classElements.length; i++) {\
                                  classElements[i].style.display = \"none\";\
                                  }\
                                  }\
                                  getElementsByClassName('%@')",elementClass];
    [self stringByEvaluatingJavaScriptFromString:javaScriptString];
}
/**
 *  根据 ElementsClassTagName 删除 WebView 的节点
 */
- (void)fq_deleteNodeByTagName:(NSString *)elementTagName
{
    NSString *javaScritptString = [NSString stringWithFormat:@"document.getElementByTagName('%@').remove();",elementTagName];
    [self stringByEvaluatingJavaScriptFromString:javaScritptString];
}



@end
