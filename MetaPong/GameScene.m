//
//  SKPMyScene.m
//  Sprite Kit Pong
//
//  Created by Božidar Ševo on 10/05/14.
//  Copyright (c) 2014 Božidar Ševo. All rights reserved.
//

#import "GameScene.h"

@interface GameScene ()

@property (strong, nonatomic) SKShapeNode *ball;
@property (strong, nonatomic) NSMutableArray *paddles;
@property (strong, nonatomic) NSMutableArray *kiPaddles;

@property (nonatomic) BOOL ballNeedsReset;
@property (nonatomic) int nextPaddleStartingDirection;

@end

@implementation GameScene


static const uint32_t ballCategory = 0x1 << 0;
static const uint32_t edgeCategory = 0x1 << 1;
static const uint32_t paddleCategory = 0x1 << 2;

static int PADDLE_SIZE_WIDTH = 0;

#define BALL_RADIUS 10

#define PADDLE_SIZE_HEIGTH 10
#define PADDLE_DISTANCE_FROM_SCREEN 10

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.backgroundColor = [SKColor whiteColor];
        
        self.physicsWorld.contactDelegate = self;
        
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsBody.categoryBitMask = edgeCategory;
        self.physicsBody.contactTestBitMask = 0x1;
        self.physicsBody.friction = 0.0;
        self.physicsBody.restitution = 1.0;
        self.physicsBody.linearDamping = 0.0;
        self.physicsBody.angularDamping = 0.0;
        
        PADDLE_SIZE_WIDTH = self.size.width / 3;
        

        CGMutablePathRef circlePath = CGPathCreateMutable();
        CGPathAddArc(circlePath, NULL, 0, 0, BALL_RADIUS, 0, M_PI * 2, YES);
        
        self.ball = [[SKShapeNode alloc] init];
        self.ball.path = circlePath;
        self.ball.fillColor = [SKColor blackColor];
        self.ball.position = CGPointMake(self.size.width / 2, self.size.height / 2);
        
        self.ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:BALL_RADIUS];
        self.ball.physicsBody.categoryBitMask = ballCategory;
        self.ball.physicsBody.contactTestBitMask = 0x1;
        self.ball.physicsBody.friction = 0.0;
        self.ball.physicsBody.restitution = 1.0;
        self.ball.physicsBody.linearDamping = 0.0;
        self.ball.physicsBody.angularDamping = 0.0;
        
        [self addChild:self.ball];
        
        
        SKShapeNode *paddle_1 = [[SKShapeNode alloc] init];
        paddle_1.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, PADDLE_SIZE_WIDTH, PADDLE_SIZE_HEIGTH) cornerRadius:10].CGPath;
        paddle_1.fillColor = [SKColor whiteColor];
        paddle_1.position = CGPointMake(self.size.width / 2 - PADDLE_SIZE_WIDTH / 2, self.size.height - PADDLE_SIZE_HEIGTH - PADDLE_DISTANCE_FROM_SCREEN);
        paddle_1.lineWidth = 1.0;
        paddle_1.strokeColor = [SKColor blackColor];
        
        paddle_1.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(PADDLE_SIZE_WIDTH, PADDLE_SIZE_HEIGTH) center:CGPointMake(PADDLE_SIZE_WIDTH / 2, PADDLE_SIZE_HEIGTH / 2)];
        paddle_1.physicsBody.categoryBitMask = paddleCategory;
        paddle_1.physicsBody.contactTestBitMask = 0x1;
        paddle_1.physicsBody.dynamic = NO;
        paddle_1.physicsBody.friction = 0.0;
        paddle_1.physicsBody.restitution = 1.0;
        paddle_1.physicsBody.linearDamping = 0.0;
        paddle_1.physicsBody.angularDamping = 0.0;
        
        [self addChild:paddle_1];
        [self.paddles addObject:paddle_1];
        
        
        SKShapeNode *paddle_2 = [[SKShapeNode alloc] init];
        paddle_2.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, PADDLE_SIZE_WIDTH, PADDLE_SIZE_HEIGTH) cornerRadius:10].CGPath;
        paddle_2.fillColor = [SKColor whiteColor];
        paddle_2.position = CGPointMake(self.size.width / 2 - PADDLE_SIZE_WIDTH / 2, PADDLE_DISTANCE_FROM_SCREEN);
        paddle_2.lineWidth = 1.0;
        paddle_2.strokeColor = [SKColor blackColor];
        
        paddle_2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(PADDLE_SIZE_WIDTH, PADDLE_SIZE_HEIGTH) center:CGPointMake(PADDLE_SIZE_WIDTH / 2, PADDLE_SIZE_HEIGTH / 2)];
        paddle_2.physicsBody.categoryBitMask = paddleCategory;
        paddle_2.physicsBody.contactTestBitMask = 0x1;
        paddle_2.physicsBody.dynamic = NO;
        paddle_2.physicsBody.friction = 0.0;
        paddle_2.physicsBody.restitution = 1.0;
        paddle_2.physicsBody.linearDamping = 0.0;
        paddle_2.physicsBody.angularDamping = 0.0;

        [self addChild:paddle_2];
        [self.paddles addObject:paddle_2];
        
        [self inGameReset];
    }
    
    return self;
}

- (SKNode *)nodeNamed:(NSString *)name
{
    NSArray *nodes = [self objectForKeyedSubscript:name];
    
    if ([nodes count] == 1) {
        return nodes[0];
    } else if ([nodes count] > 1) {
        [[NSException exceptionWithName:@"MultipleNodeException" reason:@"Your name fits multiple nodes. Change them to unique ones." userInfo:nil] raise];
    }
    
    return nil;
}

- (NSMutableArray *)paddles
{
    if (!_paddles) _paddles = [NSMutableArray new];
    
    return _paddles;
}

- (NSMutableArray *)kiPaddles
{
    if (!_kiPaddles) _kiPaddles = [NSMutableArray new];
    
    return _kiPaddles;
}

- (void)setColor:(UIColor *)color forPaddleNumber:(int)paddleNumber
{
    ((SKShapeNode *)self.paddles[paddleNumber]).fillColor = color;
}

- (void)setPaddleKI:(int)paddleNumber
{
    if (![self.kiPaddles containsObject:self.paddles[paddleNumber]]) {
        [self.kiPaddles addObject:self.paddles[paddleNumber]];
    }
}

- (void)inGameReset
{
    self.ballNeedsReset = NO;
    self.running = NO;
    
    for (SKNode *paddle in self.paddles) {
        paddle.position = CGPointMake(self.size.width / 2 - PADDLE_SIZE_WIDTH / 2, paddle.position.y);
    }
    
    self.ball.position = CGPointMake(self.size.width / 2, self.size.height / 2);
    self.ball.physicsBody.velocity = CGVectorMake(0, 0);
    
    self.ball.alpha = 0.0;
    
    [self.gameSceneDelegate showStartControls];
}

- (void)startGame
{
    self.running = YES;
    
    SKAction *showBall = [SKAction fadeInWithDuration:1.0];
    [self.ball runAction:showBall];
    
    if (self.nextPaddleStartingDirection == 0) {
        self.ball.physicsBody.velocity = CGVectorMake(200, 400);
    } else {
        self.ball.physicsBody.velocity = CGVectorMake(-200, -400);
    }
    
    self.nextPaddleStartingDirection = (self.nextPaddleStartingDirection + 1) % 2;
}

#define BALL_MIN_MOVEMENT_SPEED_X 25
#define BALL_MIN_MOVEMENT_SPEED_Y 100
#define BALL_MAX_BOUNCE_SPEED_X 400

//react to contact between nodes/bodies
- (void)didBeginContact:(SKPhysicsContact *)contact
{
    //NSLog(@"contact");
    
    SKPhysicsBody *firstBody = contact.bodyA;
    SKPhysicsBody *secondBody = contact.bodyB;
    
    if (firstBody.categoryBitMask > secondBody.categoryBitMask) {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if (firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == edgeCategory) {
        if (firstBody.node.position.y + BALL_RADIUS - firstBody.velocity.dy / 60 >= secondBody.node.frame.size.height - 4) {
            //NSLog(@"oben");
            self.ballNeedsReset = YES;
        } else if (firstBody.node.position.y - BALL_RADIUS - firstBody.velocity.dy / 60 <= 4) {
            //NSLog(@"unten");
            self.ballNeedsReset = YES;
        }
        
        if (fabs(self.ball.physicsBody.velocity.dx) < BALL_MIN_MOVEMENT_SPEED_X) {
            if (self.ball.physicsBody.node.position.x > self.size.width / 2) {
                self.ball.physicsBody.velocity = CGVectorMake(-BALL_MIN_MOVEMENT_SPEED_X - (int)arc4random_uniform(BALL_MIN_MOVEMENT_SPEED_X / 2), self.ball.physicsBody.velocity.dy);
            } else {
                self.ball.physicsBody.velocity = CGVectorMake(BALL_MIN_MOVEMENT_SPEED_X + (int)arc4random_uniform(BALL_MIN_MOVEMENT_SPEED_X / 2), self.ball.physicsBody.velocity.dy);
            }
        }
    } else if (firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == paddleCategory) {
        self.ball.physicsBody.velocity = CGVectorMake(BALL_MAX_BOUNCE_SPEED_X * ((contact.contactPoint.x - (secondBody.node.position.x + (PADDLE_SIZE_WIDTH / 2))) / (PADDLE_SIZE_WIDTH / 2)), self.ball.physicsBody.velocity.dy);
    }
    
    if (fabs(self.ball.physicsBody.velocity.dy) < BALL_MIN_MOVEMENT_SPEED_Y) {
        if (self.ball.physicsBody.velocity.dy < -2) {
            self.ball.physicsBody.velocity = CGVectorMake(self.ball.physicsBody.velocity.dx, -BALL_MIN_MOVEMENT_SPEED_Y - (int)arc4random_uniform(BALL_MIN_MOVEMENT_SPEED_Y / 2));
        } else if (self.ball.physicsBody.velocity.dy > 2) {
            self.ball.physicsBody.velocity = CGVectorMake(self.ball.physicsBody.velocity.dx, BALL_MIN_MOVEMENT_SPEED_Y + (int)arc4random_uniform(BALL_MIN_MOVEMENT_SPEED_Y / 2));
        } else {
            if (self.ball.physicsBody.node.position.y > self.size.height / 2) {
                self.ball.physicsBody.velocity = CGVectorMake(self.ball.physicsBody.velocity.dx, -BALL_MIN_MOVEMENT_SPEED_Y - (int)arc4random_uniform(BALL_MIN_MOVEMENT_SPEED_Y / 2));
            } else {
                self.ball.physicsBody.velocity = CGVectorMake(self.ball.physicsBody.velocity.dx, BALL_MIN_MOVEMENT_SPEED_Y + (int)arc4random_uniform(BALL_MIN_MOVEMENT_SPEED_Y / 2));
            }
        }
    }
}

/*
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}
*/

- (void)movePaddleNumber:(int)number amount:(float)amount
{
    if (self.running) {
        SKNode *paddle = self.paddles[number];
        
        CGPoint newPosition = CGPointMake(paddle.position.x + amount, paddle.position.y);

        if (newPosition.x < 5) {
            newPosition.x = 5;
            
            paddle.position = newPosition;
        } else if (newPosition.x + PADDLE_SIZE_WIDTH + 5 > self.size.width) {
            newPosition.x = self.size.width - PADDLE_SIZE_WIDTH - 5;
            
            paddle.position = newPosition;
        } else {
            SKAction *movePaddle = [SKAction moveByX:newPosition.x - paddle.position.x y:0 duration:0.1];
            [paddle runAction:movePaddle];
        }
    }
}

#define KI_PADDLE_SPEED 4

- (void)update:(CFTimeInterval)currentTime
{
    if (self.ballNeedsReset) {
        [self inGameReset];
    }
    
    if (self.running) {
        for (SKNode *kiPaddle in self.kiPaddles) {
            if (fabs(kiPaddle.position.x + PADDLE_SIZE_WIDTH / 2 - self.ball.position.x) > KI_PADDLE_SPEED) {
                CGPoint newPosition;

                if (kiPaddle.position.x + PADDLE_SIZE_WIDTH / 2 < self.ball.position.x) {
                    newPosition = CGPointMake(kiPaddle.position.x + KI_PADDLE_SPEED, kiPaddle.position.y);
                } else {
                    newPosition = CGPointMake(kiPaddle.position.x - KI_PADDLE_SPEED, kiPaddle.position.y);
                }
                
                if (newPosition.x < 5) {
                    newPosition.x = 5;
                    
                    kiPaddle.position = newPosition;
                } else if (newPosition.x + PADDLE_SIZE_WIDTH + 5 > self.size.width) {
                    newPosition.x = self.size.width - PADDLE_SIZE_WIDTH - 5;
                    
                    kiPaddle.position = newPosition;
                } else {
                    SKAction *movePaddle = [SKAction moveByX:newPosition.x - kiPaddle.position.x y:0 duration:0.1];
                    [kiPaddle runAction:movePaddle];
                }
            }
        }
        
        self.ball.physicsBody.velocity = CGVectorMake(self.ball.physicsBody.velocity.dx * 1.001, self.ball.physicsBody.velocity.dy * 1.001);
    }
}

@end
