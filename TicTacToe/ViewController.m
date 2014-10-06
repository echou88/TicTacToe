//
//  ViewController.m
//  TicTacToe
//
//  Created by Fenling Chou on 10/5/14.
//  Copyright (c) 2014 Fenling Chou. All rights reserved.
//

#import "ViewController.h"
#import "UIKit/UIKit.h"
// Required import... Also need AudioToolbox.framework
#import <AudioToolbox/AudioToolbox.h>

static BOOL _gameEnded = NO;

@interface ViewController ()

@property (nonatomic) UIButton *turnIndicator;
@property (nonatomic) NSMutableArray *valueArray;
@property (nonatomic) NSMutableArray *buttonArray;

@end

@implementation ViewController

-(BOOL)shouldAutorotate{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect myView = self.view.frame;
    
    _turnIndicator = [[UIButton alloc] initWithFrame:CGRectMake(50.0, 40.0, myView.size.width - 100.0, 40.0)];
    [_turnIndicator setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_turnIndicator setTitle:@"Your Turn" forState:UIControlStateNormal];
    _turnIndicator.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:30];
    [_turnIndicator setBackgroundColor:[UIColor redColor]];
    _turnIndicator.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_turnIndicator.layer setCornerRadius:8.0];
    [self.view addSubview:_turnIndicator];
    
    float height = (myView.size.height - 2 * 100.0) / 3;
    float width = myView.size.width/3;
    _buttonArray = [[NSMutableArray alloc] initWithCapacity:9];
    for (int i = 0; i < 9; i++)
    {
        CGRect buttonFrame = CGRectMake(5.0 + (i%3) * width, 100.0 + (i/3) * height, width - 10.0, height - 10.0);
        UIButton *button = [[UIButton alloc] initWithFrame:buttonFrame];
        [button setTag:i];
        
        // Round button corners
        [button.layer setMasksToBounds:YES];
        [button.layer setCornerRadius:10.0f];
        
        // Set Text Color
        [button setTitle:@"" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        button.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 30.0];
        
        // Set the button Background Color
        [button setBackgroundColor:[UIColor darkGrayColor]];
        
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonArray addObject:button];
        [self.view addSubview:button];
    }
    
    // Start New Game button
    UIButton *startGame = [[UIButton alloc] initWithFrame:CGRectMake(30.0, myView.size.height - 100.0 + 10.0, myView.size.width - 60.0, 50.0)];
    [startGame.layer setMasksToBounds:YES];
    [startGame.layer setCornerRadius:10.0f];
    [startGame setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [startGame setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [startGame setTitle:@"Start New Game" forState:UIControlStateNormal];
    startGame.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:30];
    [startGame setBackgroundColor:[UIColor blueColor]];
    [startGame addTarget:self action:@selector(startClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startGame];
    
    // Initialize value array
    _valueArray = [[NSMutableArray alloc] initWithCapacity:9];
    for (int i = 0; i < 9; i++)
        [_valueArray addObject:@""];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buttonClicked:(id)sender
{
    if (_gameEnded)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game Ended" message:@"Click on Start New Game to start a new game." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [self playSystemSound:@"/System/Library/Audio/UISounds/Modern/sms_alert_bamboo.caf"];
        return;
    }
    
    // Update display by placing the mark.
    UIButton *button = (UIButton *)sender;
    int tag = (int)button.tag;
    if (![[_valueArray objectAtIndex:tag] isEqualToString:@""])
        return;
    
    NSString *mark = [_turnIndicator isHidden]? @"X" : @"O";
    [button setTitle:mark forState:UIControlStateNormal];
    [_valueArray replaceObjectAtIndex:tag withObject:mark];
    
    // Found winner yet?
    BOOL foundWinner = NO;
    int row = tag / 3;
    int col = tag % 3;
    
    // Check Row
    if ([[_valueArray objectAtIndex:(3*row+0)] isEqualToString:mark] &&
        [[_valueArray objectAtIndex:(3*row+1)] isEqualToString:mark] &&
        [[_valueArray objectAtIndex:(3*row+2)] isEqualToString:mark])
        foundWinner = YES;
    
    // Check Column
    if ([[_valueArray objectAtIndex:(col+3*0)] isEqualToString:mark] &&
        [[_valueArray objectAtIndex:(col+3*1)] isEqualToString:mark] &&
        [[_valueArray objectAtIndex:(col+3*2)] isEqualToString:mark])
        foundWinner = YES;
    
    // Check diagnol
    if ((row == col) &&
        [[_valueArray objectAtIndex:0] isEqualToString:mark] &&
        [[_valueArray objectAtIndex:4] isEqualToString:mark] &&
        [[_valueArray objectAtIndex:8] isEqualToString:mark])
        foundWinner = YES;
    
    if (((row + col) == 2) &&
        [[_valueArray objectAtIndex:2] isEqualToString:mark] &&
        [[_valueArray objectAtIndex:4] isEqualToString:mark] &&
        [[_valueArray objectAtIndex:6] isEqualToString:mark])
        foundWinner = YES;
    
    // Winner is found, popup message...
    if (foundWinner)
    {
        if (_turnIndicator.isHidden)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loss" message:@"You have lost this game! Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [self playSystemSound:@"/System/Library/Audio/UISounds/New/Ladder.caf"];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulations!" message:@"You have win this game." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [self playSystemSound:@"/System/Library/Audio/UISounds/Modern/sms_alert_circles.caf"];
        }
        
        // Play sound
        _gameEnded = YES;
        return;
    }
    
    _turnIndicator.hidden = !_turnIndicator.hidden;
    if (!_turnIndicator.hidden)
        return;
    
    // Now it is computer's turn.
    float delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        int foundNext = -1;
        
        // Try to see if computer will win...
        foundNext = [self findWinningSpot:@"X"];
        
        // Then block user from winning by finding his/her winning spot.
        if (foundNext == -1)
            foundNext = [self findWinningSpot:@"O"];
        
        if (foundNext == -1)
        {
            do {
                if ([[_valueArray objectAtIndex:4] isEqualToString:@""])
                {
                    foundNext = 4;
                    break;
                }
                
                for (int j = 0; j < 3; j++)
                {
                    if ([[_valueArray objectAtIndex:(col+j*3)] isEqualToString:@""])
                    {
                        foundNext = col+j*3;
                        break;
                    }
                }
                if (foundNext != -1)
                    break;
                
                for (int j = 0; j < 3; j++)
                {
                    if ([[_valueArray objectAtIndex:(row*3+j)] isEqualToString:@""])
                    {
                        foundNext = row*3+j;
                        break;
                    }
                }
                if (foundNext != -1)
                    break;
                
                for (int j = 0; j < 3; j++)
                {
                    if ([[_valueArray objectAtIndex:(j*3+j)] isEqualToString:@""])
                    {
                        foundNext = j*3+j;
                        break;
                    }
                }
                if (foundNext != -1)
                    break;
                
                for (int j = 0; j < 3; j++)
                {
                    if ([[_valueArray objectAtIndex:(j*3+(2-j))] isEqualToString:@""])
                    {
                        foundNext = j*3+2-j;
                        break;
                    }
                }
            } while (0);
        }
        if (foundNext == -1) // Draw
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Draw" message:@"There is no winner." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            _gameEnded = YES;
        } else
            [[_buttonArray objectAtIndex:foundNext] sendActionsForControlEvents:UIControlEventTouchUpInside];
    });
}

- (void)startClicked:(id)sender
{
    for (int i = 0; i < 9; i++)
    {
        [_valueArray replaceObjectAtIndex:i withObject:@""];
        UIButton *button = [_buttonArray objectAtIndex:i];
        [button setTitle:@"" forState:UIControlStateNormal];
    }
    _turnIndicator.hidden = NO;
    _gameEnded = NO;
}

- (int) findWinningSpot:(NSString *)mark
{
    int winningSpot = -1;
    int count;
    
    for (int i = 0; i < 3; i++)  // row
    {
        count = 0;
        for (int j = 0; j < 3; j++)  // col
        {
            if (![[_valueArray objectAtIndex:(i*3+j)] isEqualToString:mark])
                continue;
            count++;
        }
        if (count == 2)
        {
            for (int j = 0; j < 3; j++)
                if ([[_valueArray objectAtIndex:(i*3+j)] isEqualToString:@""])
                {
                    winningSpot = i*3+j;
                    return winningSpot;
                }
        }
    }
    
    for (int i = 0; i < 3; i++)  // col
    {
        count = 0;
        for (int j = 0; j < 3; j++)  // row
        {
            if (![[_valueArray objectAtIndex:(j*3+i)] isEqualToString:mark])
                continue;
            count++;
        }
        if (count == 2)
        {
            for (int j = 0; j < 3; j++)
                if ([[_valueArray objectAtIndex:(j*3+i)] isEqualToString:@""])
                {
                    winningSpot = j*3+i;
                    return winningSpot;
                }
        }
    }
    
    // Diagnol
    count = 0;
    for (int j = 0; j < 3; j++)
        if ([[_valueArray objectAtIndex:(j*3+j)] isEqualToString:mark])
            count++;
    if (count == 2)
    {
        for (int j = 0; j < 3; j++)
            if ([[_valueArray objectAtIndex:(j*3+j)] isEqualToString:@""])
            {
                winningSpot = j*3+j;
                return winningSpot;
            }
    }
    
    count = 0;
    for (int j = 0; j < 3; j++)
        if ([[_valueArray objectAtIndex:(j*3+(2-j))] isEqualToString:mark])
            count++;
    if (count == 2)
    {
        for (int j = 0; j < 3; j++)
            if ([[_valueArray objectAtIndex:(j*3+(2-j))] isEqualToString:@""])
            {
                winningSpot = j*3+(2-j);
                return winningSpot;
            }
    }
    return -1;
}

- (void) playSystemSound:(NSString *)soundURL
{
    //NSURL *fileURL = [NSURL URLWithString:@"/System/Library/Audio/UISounds/Modern/sms_alert_circles.caf"];
    NSURL *fileURL = [NSURL URLWithString:soundURL];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)fileURL,&soundID);
    AudioServicesPlaySystemSound(soundID);
}

@end
