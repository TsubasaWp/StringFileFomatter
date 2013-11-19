//
//  main.m
//  StringFileFomatter
//
//  Created by tsubasa on 13-11-18.
//  Copyright (c) 2013年 tsubasa. All rights reserved.
//

#import <Foundation/Foundation.h>

void analysis(NSString *path);
void merge(NSString *path1, NSString *path2);

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        // insert code here...
        
        NSLog(@"*****************************************************************************");
        NSLog(@"ana <file>                Analysis a string file, with output on Desktop");
        NSLog(@"merge <file1> <file2>     Merge file2 to file1");
        NSLog(@"q                         Quit");
        NSLog(@"*****************************************************************************");
        
        char strCmd[100] = {0};
        char strPath1[100] = {0};
        char strPath2[100] = {0};
        NSString *command;
        
        while ( ![command isEqualToString:@"q"] ) {
            NSLog(@"Next Command:");
            scanf("%s", &strCmd);
            command = [NSString stringWithUTF8String:strCmd];
            
            
            // 分析
            if ( [command hasPrefix:@"ana"] ) {
                NSLog(@"Input filename:");
                scanf("%s", &strPath1);
                analysis([NSString stringWithUTF8String:strPath1]);
            }
            
            // 合并
            else if ( [command hasPrefix:@"merge"] ) {
                NSLog(@"Input filename1 and filename2, will merge file2 to file1:");
                scanf("%s%s",&strPath1, &strPath2);
                merge([NSString stringWithUTF8String:strPath1], [NSString stringWithUTF8String:strPath2]);
            }
            
            
            memset(strCmd, 0, sizeof(char)*100);
            memset(strPath1, 0, sizeof(char)*100);
            memset(strPath2, 0, sizeof(char)*100);
        }
    }
    return 0;
}


void analysis(NSString *path) {
    if ( ![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSLog(@"Invalied path !");
        return;
    }
    
    NSLog(@"begin analysis %@", path);
    NSString *fileContent =[ NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    NSArray *stringArray = [fileContent componentsSeparatedByString:@"\n"];
    NSMutableData *errorData = [[NSMutableData alloc] init];
    
    for ( int i = 0; i < [stringArray count]; i++ ) {
        NSString *s = [stringArray objectAtIndex:i];
        s = [s stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        if ( [s length] == 0 ) continue;
        if ( [s hasPrefix:@"//"] ) continue;
        s = [s stringByAppendingString:@"\n"];
        
        
        // Step 1: 替换全角字符
        s = [s stringByReplacingOccurrencesOfString:@"％" withString:@"%"];
        s = [s stringByReplacingOccurrencesOfString:@"% d" withString:@"%d"];
        s = [s stringByReplacingOccurrencesOfString:@"%D" withString:@"%d"];
        s = [s stringByReplacingOccurrencesOfString:@"% D" withString:@"%d"];
        s = [s stringByReplacingOccurrencesOfString:@"% u" withString:@"%u"];
        s = [s stringByReplacingOccurrencesOfString:@"% @" withString:@"%@"];
        s = [s stringByReplacingOccurrencesOfString:@"%は@" withString:@"%@"];
        s = [s stringByReplacingOccurrencesOfString:@"%の@" withString:@"%@"];
        s = [s stringByReplacingOccurrencesOfString:@"\";\";" withString:@"\";"];
        if ( ![s hasSuffix:@"=\"\";\n"] ) {
            s = [s stringByReplacingOccurrencesOfString:@"=\"\"" withString:@"=\""];
            s = [s stringByReplacingOccurrencesOfString:@"\"\";" withString:@"\";"];
        }
        
        // Step 2: 使用正则匹配, 若匹配不到说明格式可能有问题
        NSString *regulaStr = @"^[\042]+[^\042]+[\042]+[\\s]*=+[\\s]*[\042]+[^\042]*[\042];$";
        NSError *error;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        NSArray *arrayOfAllMatches = [regex matchesInString:s options:0 range:NSMakeRange(0, [s length])];
        
        if ( [arrayOfAllMatches count] == 0 ) {
            [errorData appendData:[s dataUsingEncoding:NSUTF8StringEncoding]];
            continue;
        }
        
        // Step 3: 匹配key和content中的占位符顺序和数量是否相等
    }
    
    NSString *logPath = [NSString stringWithFormat:@"%@/Desktop/StringFileFomatterLog.strings",NSHomeDirectory()];
    [errorData writeToFile:logPath atomically:YES];
    NSLog(@"Complate !");
}

void merge(NSString *path1, NSString *path2) {
    if ( ![[NSFileManager defaultManager] fileExistsAtPath:path1] || ![[NSFileManager defaultManager] fileExistsAtPath:path2]) {
        NSLog(@"Invalied path !");
        return;
    }
}
