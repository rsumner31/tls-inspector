//
//  ValueViewController.m
//  Certificate Inspector
//
//  MIT License
//
//  Copyright (c) 2016 Ian Spence
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "ValueViewController.h"

@interface ValueViewController () {
    UIHelper * uihelper;
}

@end

@implementation ValueViewController

- (void)viewDidLoad {
    self.textView.text = self.value;
    self.title = self.viewTitle;
    uihelper = [UIHelper withViewController:self];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                              target:self action:@selector(actionButton:)];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadValue:(NSString *)value title:(NSString *)title {
    _value = value;
    _viewTitle = title;
}

- (void)actionButton:(id)sender {
    [uihelper presentActionSheetWithTitle:self.title
                                 subtitle:langv(@"%lu characters", self.value.length)
                        cancelButtonTitle:lang(@"Cancel")
                                  choices:@[lang(@"Copy"), lang(@"Verify"), lang(@"Share")]
                                dismissed:^(NSInteger selectedIndex) {
        switch (selectedIndex) {
            case 0: { // Copy
                [[UIPasteboard generalPasteboard] setString:self.value];
                break;
            } case 1: { // Verify
                Class AlertControllerClass = NSClassFromString(@"UIAlertController");
                if(AlertControllerClass){
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:lang(@"Verify Value")
                                                                                             message:lang(@"Enter the value to verify")
                                                                                      preferredStyle:UIAlertControllerStyleAlert];
                    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                        textField.placeholder = lang(@"Value");
                    }];

                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:lang(@"Cancel")
                                                                           style:UIAlertActionStyleCancel handler:nil];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:lang(@"Verify")
                                                                       style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction *action) {
                        UITextField * inputField = alertController.textFields.firstObject;
                        [self verifyValue:inputField.text];
                    }];

                    [alertController addAction:cancelAction];
                    [alertController addAction:okAction];

                    [self presentViewController:alertController animated:YES completion:nil];
                } else {
                    UIAlertView * nameAlertView = [[UIAlertView alloc] initWithTitle:lang(@"Verify Value")
                                                                             message:lang(@"Enter the value to verify")
                                                                            delegate:self
                                                                   cancelButtonTitle:lang(@"Cancel")
                                                                   otherButtonTitles:lang(@"Verify"), nil];
                    nameAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                    [nameAlertView show];
                }
                break;
            } case 2: { // Share
                UIActivityViewController *activityController = [[UIActivityViewController alloc]
                                                                initWithActivityItems:@[self.value]
                                                                applicationActivities:nil];
                [self presentViewController:activityController animated:YES completion:nil];
                break;
            }
        }
    }];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        UITextField * inputField = [alertView textFieldAtIndex:0];
        [self verifyValue:inputField.text];
    }
}

- (void) verifyValue:(NSString *)value {
    NSString * (^formatValue)(NSString *) = ^NSString *(NSString * unformattedValue) {
        return [[unformattedValue lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    };
    NSString * formattedCurrentValue = formatValue(self.value);
    NSString * formattedExpectedValue = formatValue(value);
    if ([formattedExpectedValue isEqualToString:formattedCurrentValue]) {
        [uihelper presentAlertWithTitle:lang(@"Verified") body:lang(@"Both values matched.") dismissButtonTitle:lang(@"Dismiss") dismissed:^(NSInteger buttonIndex) {
            //
        }];
    } else {
        [uihelper presentAlertWithTitle:lang(@"Not Verified") body:lang(@"Values do not match.") dismissButtonTitle:lang(@"Dismiss") dismissed:^(NSInteger buttonIndex) {
            //
        }];
    }
}
@end
