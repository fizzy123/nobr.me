/**
 * A two player game by <a href="https://twitter.com/auxiliaryZaphos">Jimmy Andrews</a> and <a href="https://twitter.com/LorenSchmidt">Loren Schmidt</a>.  Hold the buttons (A Z UP DOWN) to start!
 * <br>
 * (For keyboards where A+Z is uncomfortable, you can alternatively use S+X) 
 */

/* // this html code might help avoid anti-aliasing if we put it on the webpage ...
canvas {
  image-rendering: optimizeSpeed;
  image-rendering: -moz-crisp-edges;
  image-rendering: -webkit-optimize-contrast;
  image-rendering: optimize-contrast;
  -ms-interpolation-mode: nearest-neighbor;
}
*/
KissStage stage;
TitleScreen title;
ConsentPhase consent;
EndScreen endscreen;

PFont f;

PGraphics pg;
boolean useBuffer = false; // if true, we render all our graphics to a buffer and the upscale; otherwise we render direct to canvas


int STATE_TITLE = 0, STATE_CONSENT = 1, STATE_KISS = 2, STATE_END = 3, NUM_STATES = 4;
int gameState = STATE_TITLE;
int lastGameState = gameState;

double transition = 0;

PVector playerColor[] = {new PVector(174,0,255),new PVector(38,119,136)};

void setup ()
{
  size( 640, 480 );
  
  stage  = new KissStage();
  title = new TitleScreen();
  consent = new ConsentPhase();
  endscreen = new EndScreen();
  
  f = createFont("Georgia", 34);
  textFont(f);
  frameRate(30);
  
  pg = createGraphics(320, 240);

}


void draw()
{
  background(0); stroke(255); fill(255);
  if (transition == 0 && gameState != lastGameState) { // begin a state transition
    transition = .01;
  }
  if (transition > 0) {
    if (transitionScreen()) {
      return;
    }
  }
  lastGameState = gameState;
  
  background(0); stroke(255); fill(255);
  
  drawStateWithUpdate(gameState);
}

void drawTitle() {
  title.update();
  title.render();
}

void drawConsent() {
  consent.update();
  consent.render();
}

void drawKiss() {
  stage.draw();
  stage.step();
}

void drawEnd() {
  endscreen.update();
  endscreen.render();
}

void resetPhase(int state) {
  if (state == STATE_TITLE) {
    title = new TitleScreen();
  } else if (state == STATE_CONSENT) {
    consent = new ConsentPhase();
  } else if (state == STATE_KISS) {
    stage  = new KissStage();
  } 
}

void drawStateWithUpdate(int state) {
  if (state == STATE_TITLE) {
    drawTitle();
  } else if (state == STATE_CONSENT) {
    drawConsent();
  } else if (state == STATE_KISS) {
    drawKiss();
  } else if (state == STATE_END) {
    drawEnd();
  }
}

void drawStateNoUpdate(int state) {
  if (state == STATE_TITLE) {
    title.render();
  } else if (state == STATE_CONSENT) {
    consent.render();
  } else if (state == STATE_KISS) {
    stage.draw();
  } else if (state == STATE_END) {
    endscreen.render();
  }
}

void heart(float x, float y, float w, float h) {
  ellipse(x-w/2+w*.05, y-h/4, w, w);//, PI, 2*PI);
  ellipse(x+w/2-w*.05, y-h/4, w, w);//, PI, 2*PI);
  //fill(50);
  quad(x-w*.81,y+.1*h,x,y-h/4,x+w*.81,y+.1*h,x,y+h);
}

// return false if the transition is done
boolean transitionScreen() {
  transition += .05;
  float scaleF = 1.2;
  if (transition > 1) {
    double t = (transition-1);
    drawStateWithUpdate(gameState);
    noStroke();
    fill(195,58,180);
    heart(width/2,height/2+(1-t)*height*.2,scaleF*width*(1-t),scaleF*width*(1-t));
  } else {
    double t = transition;
    drawStateNoUpdate(lastGameState);
    noStroke();
    fill(195,58,180);
    heart(width/2,height/2+height*.2*t,scaleF*width*t,scaleF*width*t);
  }
  if (transition > 2) {
    transition = 0;
    resetPhase(lastGameState);
    return false;
  } else {
    return true;
  }
}
/* @pjs preload="kissRequestPrompt.png, p1KissRequestText.png, p1KissResponseNo.png, p1KissResponseYes.png, p2ResponsePrompt.png, p1DialogueStemUp.png, p1DialogueStemDown.png, p2DialogueStemUp.png, p2DialogueStemDown.png"; */

float coollerp(float a, float b, float t) {
  return lerp(a, b, 1-(1-t)*(1-t));
} 


class ConsentPhase
{
  
  //PImage face1Placeholder;
  //PImage face2Placeholder;
  PImage kissRequestPrompt;
  PImage p1KissRequestPrompt;
  PImage p1KissRequestText;
  PImage p1KissResponseNo;
  PImage p1KissResponseYes;
  PImage p1DialogueStem;
  PImage p2KissRequestPrompt;
  PImage p1ResponsePrompt;
  PImage p2ResponsePrompt;
  PImage p2DialogueStemDown;
  int bubbleTimer[] = {0, 0};
  int state;
  final int CONSENT_NO_BUBBLE = 0;
  final int CONSENT_KISS_REQUEST = 1;
  final int KISS = 3;
  
  // dialogue
  final int REQUEST = 0;
  final int RESPONSE_YES = 1;
  final int RESPONSE_NO = 2;
  int stateTimer;
  int initialDelayTimer;
  boolean playerAsking[] = {false, false};
  int dialogueIndex[] = {0, 0};
  //PFont dialogueFont;
  
  ConsentPhase()
  {
    //face1Placeholder = loadImage("p1FacePlaceholder.png");
    //face2Placeholder = loadImage("p2FacePlaceholder.png");
    kissRequestPrompt = loadImage("kissRequestPrompt.png");
    //p1KissRequestPrompt = loadImage("p1KissRequestPrompt.png");
    p1KissRequestText = loadImage("p1KissRequestText.png");
    p1KissResponseNo = loadImage("p1KissResponseNo.png");
    p1KissResponseYes = loadImage("p1KissResponseYes.png");
    p1DialogueStemUp = loadImage("p1DialogueStemUp.png");
    p1DialogueStemDown = loadImage("p1DialogueStemDown.png");
    //p2KissRequestPrompt = loadImage("p2KissRequestPrompt.png");
    p1ResponsePrompt = loadImage("p1ResponsePrompt.png");
    p2ResponsePrompt = loadImage("p2ResponsePrompt.png");
    p2DialogueStemUp = loadImage("p2DialogueStemUp.png");
    p2DialogueStemDown = loadImage("p2DialogueStemDown.png");
    // start in the title state
    state = CONSENT_NO_BUBBLE;
    stateTimer = 0;
    initialDelayTimer = 0;
    //dialogueFont = loadFont("Tahoma-Bold-48.vlw");
  }
 
 
  void update()
  {  
    
    stage.step(true);
    eyeContact[0] += random(-.2,.2) + .2*sin(1298+millis()*.0017);
    eyeContact[1] += random(-.2,.2) + .2*sin(millis()*.001);
    eyeContact[0] = constrain(eyeContact[0], 0, 1);
    eyeContact[1] = constrain(eyeContact[1], 0, 1);
    
    overrideHeadMotion = false;
    headMotionVectorX = 0;
              
    // in this state, players can ask the other for a kiss
    if (state == CONSENT_NO_BUBBLE)
    {  
      stateTimer ++;
      initialDelayTimer ++;
      if (initialDelayTimer > 30)
      {
        for (int playerIndex = 0; playerIndex < 2; playerIndex ++)
        {
          if (key1Down[playerIndex] && key2Down[playerIndex])
          {
            playerAsking[playerIndex] = true;
            dialogueIndex[playerIndex] = 0;
            bubbleTimer[playerIndex] = min(consentFormTime, bubbleTimer[playerIndex] + 1);
            if (bubbleTimer[playerIndex] >= consentFormTime)
            {
              state = CONSENT_KISS_REQUEST;
              stateTimer = 0;
              playerAsking[1-playerIndex] = false;
              bubbleTimer[1-playerIndex] = 0;
              break;
            }
          }
          else
          {
            playerAsking[playerIndex] = false;
            bubbleTimer[playerIndex] = max(0, bubbleTimer[playerIndex] - 1);
          }
        }
      }
    }
    
    // in this state, the asker can withdraw the request
    // and the other player can respond
    if (state == CONSENT_KISS_REQUEST)
    {
      stateTimer ++;

      for (int playerIndex = 0; playerIndex < 2; playerIndex ++)
      {
        // if asking, they have the option to withdraw their request
        if (playerAsking[playerIndex])
        {
          if ((key1Down[playerIndex] == false) || (key2Down[playerIndex] == false))
          {
            playerAsking[playerIndex] = false;
            bubbleTimer[1-playerIndex] = 0;
            state = CONSENT_NO_BUBBLE;
            stateTimer = 0;
          }
        }
        
        // if not asking, they have the option to accept or decline
        else
        {
          // maybe
          if (key1Down[playerIndex] && key2Down[playerIndex]) {
            bubbleTimer[playerIndex] = max(0, bubbleTimer[playerIndex] - 1);          
          }
          // no
          else if (key1Down[playerIndex])
          {
            bubbleTimer[playerIndex] = min(consentResponseFormTime + holdAfterConsentResponse, bubbleTimer[playerIndex] + 1);
            dialogueIndex[playerIndex] = 1;
            if (bubbleTimer[playerIndex] >= consentResponseFormTime + holdAfterConsentResponse)
            {
              // NO, go back to the title screen
              gameState = STATE_END;
              overrideHeadMotion = false;
              //bubbleTimer[0] = 0;
              //bubbleTimer[1] = 0;
              //state = CONSENT_NO_BUBBLE;
            }
            else if (bubbleTimer[playerIndex] >= consentResponseFormTime) {
              overrideHeadMotion = true;
              headMotionVectorX = -1;
            }
          }
          // yes
          else if (key2Down[playerIndex])
          {
            bubbleTimer[playerIndex] = min(consentResponseFormTime + holdAfterConsentResponse, bubbleTimer[playerIndex] + 1);
            dialogueIndex[playerIndex] = 2;
            if (bubbleTimer[playerIndex] >= consentResponseFormTime + holdAfterConsentResponse)
            {
              overrideHeadMotion = false;
              // YES, start kissing state
              gameState = STATE_KISS;
            }
            else if (bubbleTimer[playerIndex] >= consentResponseFormTime) {
              overrideHeadMotion = true;
              headMotionVectorX = 1;
            }
          }
          else
          {
            bubbleTimer[playerIndex] = max(0, bubbleTimer[playerIndex] - 1);
          }
        }
      }
    }
  }
  
  
  void render()
  { 
    background(0); noTint();
    stage.draw();
      
    if (state == CONSENT_NO_BUBBLE)
    {
      // if we need to do any per-pixel operations
      
      //loadPixels();
      //int targetValue = stateTimer % 43;
      //for (int i = 0; i < width * height; i ++)
      //{
      //  pixels[i] = backgroundColor;
      //}
      //updatePixels();
      
      
      //text("CONSENT_NO_BUBBLE", 0, height - 64);    
      //text("p1BubbleTimer = " + bubbleTimer[0], 0, height - 48);    
      //text("p2BubbleTimer = " + bubbleTimer[1], 0, height - 32);    
      //drawKeyIndicators();
      
      // asker bubble
      for (int playerIndex = 0; playerIndex < 2; playerIndex ++)
      {
        float blend = min(1.0, bubbleTimer[playerIndex] / consentFormTime);
        int left = upperBubbleLeft + headOffset(playerIndex);
        int top = upperBubbleTop;
        int boxWidth = upperBubbleWidth;
        int boxHeight = upperBubbleHeight;
        // FIX: when transitioning from CONSENT_KISS_REQUEST to CONSENT_NO_BUBBLE the responding player's bubble pops upward
        // possibly store box positions per player and set only on state change?
        if (blend > 0.01)
          drawDialogueBoxWithContents(left, top, boxWidth, boxHeight, blend, playerIndex, dialogueIndex[playerIndex]);
     }
      
      // ADD: special case for simultaneous invitation
      
      // prompts
      // individual player kiss request prompts
      /*
      if (bubbleTimer[0] == 0)
        image(p1KissRequestPrompt, 0, height - p1KissRequestPrompt.height);
      if (bubbleTimer[1] == 0)
        image(p2KissRequestPrompt, width - p2KissRequestPrompt.width, height - p2KissRequestPrompt.height);
      */
      // joint prompt
      noTint();
      image(kissRequestPrompt, 0, height - kissRequestPrompt.height);
    }
    
    else if (state == CONSENT_KISS_REQUEST)
    {
      
      // asker bubble
      for (int playerIndex = 0; playerIndex < 2; playerIndex ++)
      {
        if (playerAsking[playerIndex])
        {
          float blend = min(1.0, bubbleTimer[playerIndex] / consentFormTime);
          int left = upperBubbleLeft + headOffset(playerIndex);
          int top = upperBubbleTop;
          int boxWidth = upperBubbleWidth;
          int boxHeight = upperBubbleHeight;
          if (blend > 0.01);
            drawDialogueBoxWithContents(left, top, boxWidth, boxHeight, blend, playerIndex, 0);
          
        }
        
        else
        {
          // response bubble
          float blend = min(1.0, bubbleTimer[playerIndex] / consentResponseFormTime);
          if (playerIndex == 0)
            left = upperBubbleLeft + headOffset(0);
          else
            left = upperBubbleLeft + upperBubbleWidth - lowerBubbleWidth + headOffset(1);
          top = lowerBubbleTop;
          boxWidth = lowerBubbleWidth;
          boxHeight = lowerBubbleHeight;
          // if nothing is pressed and the box is shrinking, use previous text?
          
          if (blend > 0.01)
            drawDialogueBoxWithContents(left, top, boxWidth, boxHeight, blend, playerIndex, dialogueIndex[playerIndex]);
        
         
          // response prompt
          if (bubbleTimer[0] == 0)
          {
            noTint();
            image(p1ResponsePrompt, 0, height - p1ResponsePrompt.height);
          }
          if (bubbleTimer[1] == 0)
          {
            noTint();
            image(p2ResponsePrompt, width - p2ResponsePrompt.width, height - p2ResponsePrompt.height);
          }
        }
      }
    }
    //drawTestBoxes();
  }
  
  float headOffset(int playerInd) {
    float o = -13*(playerInd*2-1);
    return (stage.faces.get(playerInd).headBody.GetPosition().x + o)*stage.worldScale.x;
  }
  

  // gets correct size, and calls the box and contents draw functions with that size
  void drawDialogueBoxWithContents(int left, int top, int boxWidth, int boxHeight, float blend, int playerIndex, int dialogue)
  {
    // size when newly formed
    int initialLeft, initialTop, initialHeight, initialWidth;
    int finalLeft, finalTop, finalHeight, finalWidth;
    
   	// change start height based on whether this is a high or low bubble
    if (top < mouthHeight - 32)
      initialTop = mouthHeight - 32;
    else
      initialTop = mouthHeight + 12;
    initialWidth = 60;
    initialHeight = 40;
    if (playerIndex == 0)
    {
      initialLeft = centerColumnLeft + headOffset(0);
    }
    else if (playerIndex == 1)
    {
      initialLeft = centerColumnLeft + centerColumnWidth - initialWidth + headOffset(1);
    } 
    drawDialogueBox(
      coollerp(initialLeft, left, blend),
      coollerp(initialTop, top, blend),
      coollerp(initialWidth, boxWidth, blend),
      coollerp(initialHeight, boxHeight, blend),
      playerIndex); 
   
    if (dialogue != -1)   
      drawDialogueBoxContents(
        coollerp(initialLeft, left, blend),
        coollerp(initialTop, top, blend),
        coollerp(initialWidth, boxWidth, blend),
        coollerp(initialHeight, boxHeight, blend),
        playerIndex,
        dialogue);
  }


  // draws just the contents of the box (all text is images)
  void drawDialogueBoxContents(int left, int top, int boxWidth, int boxHeight, int playerIndex, int dialogue)
  {
    if (playerIndex == 1) // if player 1 is asking
    {
      tint(p2Color);
    }
    if (playerIndex == 0) // if player 0 is asking
    {
      tint(p1Color);
    }
    PImage sourceImage = p1KissRequestText;
    if (dialogue == 1)
      sourceImage = p1KissResponseNo;
    else if (dialogue == 2)
      sourceImage = p1KissResponseYes;
    image(sourceImage, left, top, boxWidth, boxHeight);
  }
  
  
  void drawDialogueBox(int left, int top, int width, int height, int playerIndex)
  {
    noTint();
    if (playerIndex == 0)
    {
      if (top < 280)
        image(p1DialogueStemUp, 134 + headOffset(0), 279);
      else
        image(p1DialogueStemDown, 128 + headOffset(0), 314);
    }
    else if (playerIndex == 1)
    {
      if (top < 280)
        image(p2DialogueStemUp, 393 + headOffset(1), 279);
      else
        image(p2DialogueStemDown, 400 + headOffset(1), 314);
    }
    noStroke();
    fill(dialogueBoxColor);
    rect(left, top, width, height, 16); 
  }    
} 


void drawKeyIndicators()
{
  // key indicators (put in final game in some form?)
  int centerX = 320;
  int spacingX = 32;
  int radius = 24;
  noTint();
  fill(p1Color);
  if (key1Down[1])
    ellipse(centerX - 1.5 * spacingX, 32, radius, radius);
  if (key2Down[1])
    ellipse(centerX - 0.5 * spacingX, 32, radius, radius);
  fill(p2Color);
  if (key1Down[0])
    ellipse(centerX + 0.5 * spacingX, 32, radius, radius);
  if (key2Down[0])
    ellipse(centerX + 1.5 * spacingX, 32, radius, radius);
}


void drawTestBoxes()
{
  noFill();
  stroke(64);
  rect(upperBubbleLeft, upperBubbleTop, upperBubbleWidth, upperBubbleHeight);
  rect(upperBubbleLeft, lowerBubbleTop, lowerBubbleWidth, lowerBubbleHeight);
  rect(upperBubbleLeft + upperBubbleWidth - lowerBubbleWidth, lowerBubbleTop, lowerBubbleWidth, lowerBubbleHeight);
}
/* @pjs preload="end.jpg"; */

class EndScreen
{
  PImage endScreen;
  
  int timer;
  
  EndScreen() {
    timer = 0;
    endScreen = loadImage("end.jpg");
  }
  
  void update() {
    timer++;
    if (timer > 100) {
      gameState = STATE_TITLE;
      timer = 0;
    }
  }
  
  void render() {
    noTint();
    image(endScreen, 0, 0, width, height);
  }
}
/* @pjs preload="titleText.jpg, hand.png, titlePrompts.png"; */

class TitleScreen
{
  PImage titleText, titlePrompts;
  PImage hand;
  int timer;
  int handExtend[] = {0, 0};
  
  
  TitleScreen()
  {
    timer = 0;
    titleText = loadImage("titleText.jpg");
    hand = loadImage("hand.png");
    titlePrompts = loadImage("titlePrompts.png");
  }
  
  
 
 
  void update()
  {  
    
    
    int maxExtend = 90;
    
    
    for (int i = 0; i < 2; i++) {
      if (key1Down[i] && key2Down[i]) handExtend[i] += 3;
      else handExtend[i]--;
      handExtend[i] = max(0, handExtend[i]);
      handExtend[i] = min(maxExtend, handExtend[i]);
    }
    if (handExtend[0] > maxExtend-5 && handExtend[1] > maxExtend-5) {
      timer++;
      if (timer > 10) {   
        gameState = STATE_CONSENT;
      }
    } else {
      timer = 0;
    }
  }
  
  void drawButton(var t, vec3 c, int butW, int x, int y, int letterXoff, int letterYoff, boolean pressed) {
    fill(0);
    rect(x+2,y-30+2,butW,37);
    fill(255,224,162);
    int o = 0;
    if (pressed) o = 1;
    rect(x+o,y-30+o,butW,37);
    fill(c.x, c.y, c.z);
    text(t, x+2+o+letterXoff, y+o+letterYoff);
  }
  
  void render()
  {
    noTint();
    noStroke();
    image(titleText, 0, 0);
    
    
    // draw the first hand
    tint(playerColor[0].x, playerColor[0].y, playerColor[0].z);
    fill(playerColor[0].x, playerColor[0].y, playerColor[0].z);
    rect(0,height-hand.height,handExtend[0]*2,hand.height);
    image(hand, handExtend[0]*2, height-hand.height);
    
    // draw the second hand
    fill(playerColor[1].x, playerColor[1].y, playerColor[1].z);
    rect(width-handExtend[1]*2,height-hand.height,handExtend[1]*2,hand.height);
    pushMatrix();
    scale(-1,1);
    tint(playerColor[1].x, playerColor[1].y, playerColor[1].z);
    image(hand, -width+handExtend[1]*2, height-hand.height);
    popMatrix();
    
    
    //fill(playerColor[1].x, playerColor[1].y, playerColor[1].z);
    
    /*int h1 = height - 65;
    int h2 = height - 25;
    drawButton("A", playerColor[0], 27, 8, h1, 0, 0, key1Down[0]);
    drawButton("↑", playerColor[1], 27, width-8-30, h1, 1, -2, key1Down[1]);
    drawButton("Z", playerColor[0], 27, 8, h2, 0, 0, key2Down[0]);
    drawButton("↓", playerColor[1], 27, width-8-30, h2, 1, -2, key2Down[1]);
    */
    noTint();
    image(titlePrompts, 0, height-titlePrompts.height,width);
    
    
    
  }
} 
color backgroundColor = color(0, 0, 0);
color p1Color = color(132, 73, 160);
color p2Color = color(38, 119, 136);
color dialogueBoxColor = color(255, 229, 179);

int consentFormTime = 48;
int consentResponseFormTime = 64;
int holdAfterConsentResponse = 32;
int mouthHeight = 316; // height of center of mouth
int centerColumnLeft = 181;
int centerColumnWidth = 278;
int upperBubbleLeft = 181;
int upperBubbleTop = 58;
int upperBubbleWidth = 278;
int upperBubbleHeight = 252;
int lowerBubbleTop = 326;
int lowerBubbleWidth = 180;
int lowerBubbleHeight = 140;
char p1Key1 = 'q';
char p1Key2 = 'a';
char p2Key1 = 'p';
char p2Key2 = 'l';

// keys 1 and 2, for players 1 and 2; so if key2Down[0] is true, that means the first player (player 0) is pressing their second key.
boolean key1Down[] = { false, false };
boolean key2Down[] = { false, false };

void handleKey(boolean pressed) {
  
  if (key == CODED) {
    if (keyCode == UP) {
      key1Down[1] = pressed;
    } else if (keyCode == DOWN) {
      key2Down[1] = pressed;
    } 
  } else {
    if (key == 'a' || key == 'A' || key == 's' || key == 'S') {
      key1Down[0] = pressed;
    } else if (key == 'z' || key == 'Z' || key == 'x' || key == 'X') {
      key2Down[0] = pressed;
    }
    if (key == 'p' || key == 'P') {
      key1Down[1] = pressed;
    }
    if (key == 'l' || key == 'L') {
      key2Down[1] = pressed;
    }
  }
}

void handleMouse(boolean pressed) {
  // uncomment if you want mouse as an optional control method
  /*if (mouseButton == LEFT) {
    key1Down[0] = pressed;
  }
  if (mouseButton == RIGHT) {
    key2Down[0] = pressed;
  }*/
}

void keyPressed() {
  handleKey(true);
}

void keyReleased() {
  handleKey(false);
}

void mousePressed() {
  handleMouse(true);
}

void mouseReleased() {
  handleMouse(false);
}


// a debug/helper function that returns true if a key (was not pressed last time you called the function AND is now pressed) 
boolean pressedLast[] = new boolean[256];
boolean keyHit(char c) {
  //if (pressedLast == null) {
  //  pressedLast = new boolean[256];
  //}
  //println ("pressedLast[c] == " + pressedLast[c]);
  if (keyPressed && key == c) {
    //println("down");
    if (!pressedLast[c]) {
      pressedLast[c] = true;
      return true;
    } else {
      return false;
    }
  }
  pressedLast[c] = false;
  return false;
}
// shorthand for common box2d classes
var   b2Vec2 = Box2D.Common.Math.b2Vec2
,  b2Math = Box2D.Common.Math.b2Math
,  b2AABB = Box2D.Collision.b2AABB
,  b2BodyDef = Box2D.Dynamics.b2BodyDef
,  b2Body = Box2D.Dynamics.b2Body
,  b2FixtureDef = Box2D.Dynamics.b2FixtureDef
,  b2Fixture = Box2D.Dynamics.b2Fixture
,  b2Contact = Box2D.Dynamics.b2Contact
,  b2Shape = Box2D.Dynamics.b2Shape
,  b2World = Box2D.Dynamics.b2World
,  b2MassData = Box2D.Collision.Shapes.b2MassData
,  b2PolygonShape = Box2D.Collision.Shapes.b2PolygonShape
,  b2CircleShape = Box2D.Collision.Shapes.b2CircleShape
,  b2DebugDraw = Box2D.Dynamics.b2DebugDraw
,  b2MouseJointDef =  Box2D.Dynamics.Joints.b2MouseJointDef
,  b2DistanceJointDef = Box2D.Dynamics.Joints.b2DistanceJointDef
,  b2DistanceJoint = Box2D.Dynamics.Joints.b2DistanceJoint
,  b2PrismaticJointDef = Box2D.Dynamics.Joints.b2PrismaticJointDef
,  b2PrismaticJoint = Box2D.Dynamics.Joints.b2PrismaticJoint
,  b2WeldJointDef = Box2D.Dynamics.Joints.b2WeldJointDef
,  b2WeldJoint = Box2D.Dynamics.Joints.b2WeldJoint
,  b2RevoluteJointDef = Box2D.Dynamics.Joints.b2RevoluteJointDef
,  b2RevoluteJoint = Box2D.Dynamics.Joints.b2RevoluteJoint;


boolean overrideHeadMotion = false;
float headMotionVectorX = 0, headMotionVectorY = 0;

float eyeContact[] = {0,0};


// --- Parameters for tongue setup/behavior ---
// tweak controls, rendering, etc with these params
int tongueNumSegs = 15;
b2Vec2 tongueCurveRange = new b2Vec2(-.75*15.0/float(tongueNumSegs),.75*15.0/float(tongueNumSegs)); // the min/max angle at each revolute joint in the tongue
float tongueRestCurvature = .03 * (15.0/float(tongueNumSegs)); 
float tongueShortLengthFactor = .5; // control rest length of tongue (1->shortest, 0->least short)
float tongueLongLengthFactor = 2.5; // control max length of tongue (2->normal max len, longer creates gaps)
float tongueWidthAffectsNeighborWidth = .5; // 0 for no effect, 1 for width entirely follows nbrs

float headMoveForwardRange = 3; // amount head can move forward to follow tongue
float headMoveUpRange = .1; // amount head can move up to follow tongue motion (
float headXMoveSpeedFwd = .1;
float headXMoveSpeedBack = 2;
float headYMoveSpeed = .2;

float tongueSegSpacingX = .9;
float tongueSegSpacingY = .9;

float tongueCurvatureGainFactor = 2; // this just scales the value from a weird custom formula; search for this parameter to see/edit it below
float tongueLengthGain = 2.5;
float tongueWidthGain = 5;
float tongueWidthMotorStrength = 200;
float tongueLengthMotorStrength = 1500;
float tongueCurveMotorStrength = 120000;

float tongueFriction = .01;

float lipGain = 1.5;
float lipMotorTorqueFirstSeg = 5;
float lipMotorTorqueRestSegs = 10000;

int lipNumSegs = 3;
float lipRestCurve = .1; 

float lipTotalHeight = .7;
float lipWidth = .35;

float eyeRadius = 2.1;
float eyePupilRadius = .8;

// these determine what collides with what:
int LIP_GROUP_INDEX = -5;
int FACE_GROUP_INDEX_BASE = 1;
int NOSE_GROUP_INDEX = 27;
int EYE_GROUP_INDEX_BASE = 6;
int TONGUE_INDEX_BASE = -1;
int FACE_CATEGORY = 1, LIP_CATEGORY = 2, TONGUE_CATEGORY = 4, EYE_CATEGORY = 8;
int FACE_MASK = 1+4+8, LIP_MASK = 2+4+8, TONGUE_MASK = 1+2+4+8, EYE_MASK=1+2+4+8;

float mouthBottomYOffset = 0;

// global array to track whether tongue is hitting eye
// (sorry for the sloppy coding here; I didn't realize eye needed to know about tongue until too late / too lazy to refactor)
var eyeHit = {};


// the Box2D world that all the simulation uses:
var world;

// the images we build the faces out of:
/* @pjs preload="headbot.png"; */
/* @pjs preload="headtop.png"; */
/* @pjs preload="kissBackground.jpg"; */
PImage headTop, headBot;  // top and bottom parts of the head 
PImage kissBG;


void drawBody(b2Body b) {
  if (useBuffer) {
    b2Vec2 p = b.GetPosition();
    float a = b.GetAngle();
    
    pg.pushMatrix();
    pg.translate(p.x,p.y);
    pg.rotate(a);
    
    b2Fixture fix = b.GetFixtureList();
    while (fix) {
      if (fix.GetType() == 1) {
        b2PolygonShape s = fix.GetShape();
        pg.beginShape(QUADS);
        int n = s.GetVertexCount();
        for (int ii = 0; ii < n; ii++) {
          b2Vec2 v = s.m_vertices[ii];
          pg.vertex(v.x,v.y);
        }
        pg.endShape();
      } else {
        b2CircleShape s = fix.GetShape();
        b2Vec2 p = s.GetLocalPosition();
        float r = s.GetRadius();
        pg.ellipse(p.x,p.y,r*2,r*2);
      }
      fix = fix.GetNext();
    }
    
    pg.popMatrix();
  } else {
    b2Vec2 p = b.GetPosition();
    float a = b.GetAngle();
    
    pushMatrix();
    translate(p.x,p.y);
    rotate(a);
    
    b2Fixture fix = b.GetFixtureList();
    while (fix) {
      if (fix.GetType() == 1) {
        b2PolygonShape s = fix.GetShape();
        beginShape(QUADS);
        int n = s.GetVertexCount();
        for (int ii = 0; ii < n; ii++) {
          b2Vec2 v = s.m_vertices[ii];
          vertex(v.x,v.y);
        }
        endShape();
      } else {
        b2CircleShape s = fix.GetShape();
        b2Vec2 p = s.GetLocalPosition();
        float r = s.GetRadius();
        ellipse(p.x,p.y,r*2,r*2);
      }
      fix = fix.GetNext();
    }
    
    popMatrix();
  }
}

void drawBoxWorld(b2World w) {
  b2Body b = w.GetBodyList();
  while (b) {
    drawBody(b);
    b = b.GetNext();
  }
}


// KissStage sets up the Box2D world and manages both kissing faces
class KissStage {
  b2Vec2 worldCenter, worldScale;
  
  ArrayList tongues;
  ArrayList faces;
  
  boolean drawDebugToggle = false;
  
  float noInputTimeout;
  float fromStartTimer;
  boolean bothPlayersPressedKeys;
  
  KissStage() {
    headTop = loadImage("headtop.png");
    headBot = loadImage("headbot.png");
    kissBG = loadImage("kissBackground.jpg");
    
    world = new b2World(new b2Vec2(0, 10),  true);
    worldCenter = new b2Vec2(width*.5, height*.5);
    worldScale = new b2Vec2(width*.5*.1, width*.5*.1);
    
    faces = new ArrayList();
    faces.add(new Face(-11.5,2.5,1)); // first face, on the left side of the screen facing right
    faces.add(new Face(11.5,2.5,-1)); // second face, on the right side of the screen facing left
    
    noInputTimeout = 0;
    fromStartTimer = 0;
    p1Active = false;
    p2Active = false;
    
    eyeContact[0] = 0; eyeContact[1] = 0;
  }
  
  boolean noPauseMode = true;
  
  // do all the input and simulation stuff here
  void step(boolean ignoreInput) {
    
    if (!ignoreInput) {
      eyeContact[0] = 0; eyeContact[1] = 0;
    }
    
        pushMatrix();
    //rect(0,0,10,10);
    translate(worldCenter.x, worldCenter.y);
    scale(worldScale.x, worldScale.y);
    
    if (keyHit('0')) {
      noPauseMode = !noPauseMode;
    }
        
    // then step sim
    if (noPauseMode || keyHit('s')) {
      float timeStep = 1.0/30.0;
      int stepsPerStep = 4;
      timeStep /= stepsPerStep;
      for (int i = 0; i < stepsPerStep; i++) {
        
        for (int fi = 0; fi < faces.size(); fi++) {
          Face f = (Face)faces.get(fi);
          f.step(faces.get(faces.size()-1-fi).tongue, faces.get(faces.size()-1-fi).e, ignoreInput);
        }
        
        world.Step(timeStep, 25, 5);
      }
    }
    
    if (!ignoreInput) {
      fromStartTimer++;
    }
    
    if (key1Down[0] || key2Down[0])
      p1Active = true;
    if (key1Down[1] || key2Down[1])
      p2Active = true;
    
    // input is accepted but one of the players is not giving input
    if (!ignoreInput && fromStartTimer > 100 && p1Active && p2Active &&
        (  (!key1Down[0] && !key2Down[0])  ||  (!key1Down[1] && !key2Down[1])  ))
    {
      noInputTimeout ++;
      if (noInputTimeout > 200) {
        gameState = STATE_END;
      }
    } else {
      noInputTimeout = 0;
    }
    
    
    
    popMatrix();
  }
  
  void draw() {
    image(kissBG, 0, 0, width, height);
    
    if (useBuffer) {
      pg.pushMatrix();
      pg.translate(worldCenter.x*.5, worldCenter.y*.5);
      pg.scale(worldScale.x*.5, worldScale.y*.5);
      pg.noStroke();
    } else {
      pushMatrix();
      translate(worldCenter.x, worldCenter.y);
      scale(worldScale.x, worldScale.y);
      noStroke();
    }
    
    if (keyHit('d') || keyHit('D')) {
      drawDebugToggle = !drawDebugToggle;
    }
    if (drawDebugToggle) {
      drawBoxWorld(world);
    } else {
      for (int i = 0; i < faces.size(); i++) {
        Face f = (Face)faces.get(i);
        
        f.drawTongue();
      }
      for (int i = 0; i < faces.size(); i++) {
        Face f = (Face)faces.get(i);
        
        f.drawRest(1/worldScale.x);
      }
    }
    
    if (useBuffer) {
      pg.popMatrix();
    } else {
      popMatrix();
    }
    
  }
};

class Face {
  Tongue tongue;
  Lip lips[];
  b2Body headBody;
  Eye e;
  PVector skinColor;
  
  int xDir;
  int faceNum;
  float startX, startY;
  
  Face(float x, float y, int xfacing) {
    xDir = xfacing;
    faceNum = 0;
    if (xDir < 0) {
      faceNum = 1;
    }
    
    skinColor = new PVector(174,0,255);//(128,255,128);
    if (faceNum == 1) {
      skinColor = new PVector(38,119,136);
    }
    
    startX = x; startY = y;
    
    
    // create head
    var bodyDef = new b2BodyDef();
    bodyDef.type = b2Body.b2_kinematicBody;
    bodyDef.position.Set(x-1.5*xfacing, y);
    headBody = world.CreateBody(bodyDef);
    
    // fixtures definition for the head
    var fixDef = new b2FixtureDef();
    fixDef.filter.groupIndex = FACE_GROUP_INDEX_BASE + faceNum;
    fixDef.filter.maskBits = FACE_MASK;
    fixDef.filter.categoryBits = FACE_CATEGORY;
    fixDef.density = 1.0;
    fixDef.friction = 0.1;
    fixDef.restitution = 0.01;
    fixDef.shape = new b2PolygonShape();
    
    fixDef.shape.SetAsOrientedBox(1, 10, new b2Vec2(-xDir*2,0), 0);
    headFixtures = new ArrayList();
    headBody.CreateFixture(fixDef); // back of the head (tongue attaches here)
    
    fixDef.shape = new b2CircleShape();
    fixDef.shape.SetRadius(1);
    fixDef.shape.SetLocalPosition(new b2Vec2(6.45*xfacing,3.0+mouthBottomYOffset+.5));
    headBody.CreateFixture(fixDef); // lower jaw circle
    fixDef.shape = new b2PolygonShape();
    fixDef.shape.SetAsOrientedBox(6.95, 1.25, new b2Vec2(0,3.0+mouthBottomYOffset), 0);
    headBody.CreateFixture(fixDef); // lower jaw
    fixDef.shape.SetAsOrientedBox(6.5, .5, new b2Vec2(0,3.0+mouthBottomYOffset+1), 0);
    headBody.CreateFixture(fixDef); // lower jaw
    
    fixDef.shape.SetAsOrientedBox(6.95, 6, new b2Vec2(0,-6.95), 0);
    headBody.CreateFixture(fixDef); // upper jaw / rest of face
    
    fixDef.filter.groupIndex = NOSE_GROUP_INDEX;
    
    fixDef.shape.SetAsOrientedBox(.65, .5, new b2Vec2(7.17*xfacing,-5.4), .65*xfacing);
    headBody.CreateFixture(fixDef); // nose
    fixDef.shape.SetAsOrientedBox(.3, .5, new b2Vec2(7.7*xfacing,-4.9), 1.1*xfacing);
    headBody.CreateFixture(fixDef); // nose 2
    fixDef.shape = new b2CircleShape();
    fixDef.shape.SetRadius(.5);
    fixDef.shape.SetLocalPosition(new b2Vec2(7.85*xfacing,-4.6));
    headBody.CreateFixture(fixDef); // nose 3
    
    // add tongue 
    //start = new b2Vec2(-10,0);
    //spacing = new b2Vec2(.5, 1);
    tongue = new Tongue(headBody, new b2Vec2(x,y+.2+mouthBottomYOffset*.6), new b2Vec2(xfacing*tongueSegSpacingX, tongueSegSpacingY), skinColor);
    
    // add lips
    lips = new Lip[2];
    lips[0] = new Lip(headBody, new b2Vec2(x+5.1*xfacing, y-1.3), xfacing, 1);
    lips[1] = new Lip(headBody, new b2Vec2(x+5.1*xfacing, y+2.1+mouthBottomYOffset), xfacing, -1);
    
    e = new Eye(headBody, new b2Vec2(x+4*xfacing, y-8.25), faceNum);
  }
  
  void step(Tongue otherTongue, Eye otherEye, boolean ignoreInput) {
    
    e.step(otherTongue, otherEye);


    
    tongue.step(ignoreInput);
    
    float tongueExtendFactor =
      (tongue.actualLen-tongue.restLen()) / (tongue.longLen()-tongue.restLen());
    lips[0].step(tongueExtendFactor);
    lips[1].step(tongueExtendFactor);
    
    b2Vec p = headBody.GetWorldPoint(new b2Vec2(xDir*6.2,0));
    b2Vec2 target = tongue.tip;
    b2Vec2 xRange = new b2Vec2(startX+xDir*5-headMoveForwardRange*faceNum,startX+xDir*5+headMoveForwardRange*(1-faceNum));
    b2Vec2 yRange = new b2Vec2(startY-headMoveUpRange,startY);
    if (target.x < xRange.x) target.x = xRange.x;
    if (target.x > xRange.y) target.x = xRange.y;
    if (target.y < yRange.x) target.y = yRange.x;
    if (target.y > yRange.y) target.y = yRange.y;
    float xgain = headXMoveSpeedFwd, ygain = headYMoveSpeed;
    float dx = target.x-p.x, dy = target.y-p.y;
    //console.log("log: " + target.x +" "+ startX + " " +dx);
    if (abs(dx) < .3) dx = 0;
    if (abs(dy) < .3) dy = 0;
    
    if (dx*xDir < 0) xgain = headXMoveSpeedBack;
    
    if (overrideHeadMotion) {
      headBody.SetLinearVelocity( new b2Vec2(headMotionVectorX*xDir, headMotionVectorY) );
    } else {
      headBody.SetLinearVelocity( new b2Vec2( xgain*dx, ygain*dy));
    }
    
    
  }
  
  void drawTongue() {
    tongue.draw(skinColor);
  }
  
  void drawRest(float scaleFactor) {
    b2Vec2 p = headBody.GetPosition();
    float a = headBody.GetAngle();
    tint(skinColor.x,skinColor.y,skinColor.z);
    if (useBuffer) {
      // todo: rebuild this code when the below code is finished
    } else {
      pushMatrix();
      translate(p.x-1.6*xDir,p.y-10);
      rotate(a);
      if (xDir < 0)
        scale(-1,1);
      
      image(headTop,0,0,headTop.width*scaleFactor,headTop.height*scaleFactor);
      translate(0,373*scaleFactor+mouthBottomYOffset);
      image(headBot,0,0,headBot.width*scaleFactor,headBot.height*scaleFactor);
      popMatrix();
      
    }
    
    e.draw(skinColor);
    
    //tongue.draw(skinColor);
    lips[0].draw(skinColor);
    lips[1].draw(skinColor);
    
    noTint();
    
  }

}

class Eye {
  b2Body refBody;
  b2Body body;
  b2Vec2 pupil;
  b2WeldJoint joint; 
  float open;
  int faceNum;
  
  Eye(b2Body refBody, b2Vec2 pos, int faceNum) {
    float r = eyeRadius;
    this.faceNum = faceNum;
    
    pupil = new b2Vec2(0,0);
    
    // create lip body
    var bodyDef = new b2BodyDef();
    bodyDef.type = b2Body.b2_dynamicBody;
    bodyDef.position.Set(pos.x, pos.y);
    body = world.CreateBody(bodyDef);
    
    // fixtures definition for the head
    var boxDef = new b2FixtureDef();
    boxDef.filter.groupIndex = EYE_GROUP_INDEX_BASE+faceNum;
    boxDef.filter.maskBits = EYE_MASK;
    boxDef.filter.categoryBits = EYE_CATEGORY;
    boxDef.density = 0.001;
    boxDef.friction = 0.1;
    boxDef.restitution = 0.1;

    boxDef.shape = new b2CircleShape();
    boxDef.shape.SetRadius(r);
    
    body.CreateFixture(boxDef);
    
    b2WeldJointDef jointDef = new b2WeldJointDef();
    jointDef.Initialize(refBody, body, pos);
    jointDef.collideConnected = false;
    joint = world.CreateJoint(jointDef);
    
  }
  
  int flickerTimer = 0;
  
  b2Vec2 tip = new b2Vec2(0,0);
  void step(Tongue t, Eye otherEye) {
    b2Vec2 p = body.GetPosition();
    
    if (t) {
      b2Vec2 target = t.center.get(t.center.size()-1).GetPosition();
      target = new b2Vec2(target.x, target.y);
      if (otherEye) {
        b2Vec2 ep = otherEye.body.GetPosition();
        b2Vec2 epp = otherEye.pupil;
        target.x = lerp(target.x, ep.x+epp.x, eyeContact[faceNum]);
        target.y = lerp(target.y, ep.y+epp.y, eyeContact[faceNum]);
      }
      tip.x = target.x;
      tip.y = target.y;
      tip.Subtract(p);
      tip.Normalize();
      tip.Multiply(eyeRadius - eyePupilRadius*1.1);
      //target.Add(p);
      pupil.x = tip.x*.05 + pupil.x*.95;
      pupil.y = tip.y*.05 + pupil.y*.95;
      
    }
    float eyeOpenTarget=(20*abs(sin(steps*.0025)))-1;
    if (eyeHit[faceNum]) {
      eyeOpenTarget = -20;
      flickerTimer = 10;
      pupil.x *= .7; pupil.y *= .7;
    } else {
      flickerTimer--;
    }
    open = open*.95 + .05*eyeOpenTarget;
    steps += 1+random(.1);
    
  }
  int steps = random(2791);
  void draw(PVector skinColor) {
    b2Vec2 bp = body.GetPosition();
    
    // draw the skin of the eyelid
    if (useBuffer) {
      pg.noStroke();
      pg.noTint();
      pg.fill(skinColor.x,skinColor.y,skinColor.z);
    } else {
      noStroke();
      noTint();
      fill(skinColor.x,skinColor.y,skinColor.z);
    }
    drawBody(body);

    // draw the whites of the eye (clipped according to how open the eye is)    
    if (useBuffer) {
      pg.fill(255,224,164);
    } else {
      fill(255,224,164);
    }
    var c = externals.context;
    c.save();
    c.beginPath();
    float o = open;
    if (o < 0) {
      o = 0;
      if (flickerTimer > 0) {
        o = random(.01);
      }
    }
    c.rect(bp.x-3,bp.y-eyeRadius*o,6,eyeRadius*2*o);
    //c.stroke();
    c.clip();
    
    drawBody(body);
    
    // draw the pupil
    b2Vec2 pupilPos = new b2Vec2(pupil.x, pupil.y);
    pupilPos.Add(bp);
    if (useBuffer) {
      pg.fill(122,44,2);
      pg.ellipse(pupilPos.x,pupilPos.y,eyePupilRadius,eyePupilRadius);
    } else {
      fill(122,44,2);
      ellipse(pupilPos.x,pupilPos.y,eyePupilRadius,eyePupilRadius);
    }
    
    c.restore();
  }
}

class Lip {
  b2Body lipBody; // the first body in the lip
  b2RevoluteJoint joint; // the joint connecting the lip to the rest of the mouth
  float w, h;
  int xDir, yDir;
  
  // in progress: generalize lips to use chain of rigid bodies:
  ArrayList bodies, joints; // the rest of the bodies and joints defining the lip
  
  Lip(b2Body connectTo, b2Vec2 jointPos, int xDir, int yDir) {
    this.xDir = xDir;
    this.yDir = yDir;
    
    w = lipWidth;
    fullh = lipTotalHeight;
    
    float bh = fullh / lipNumSegs;
    
    // create lip body
    var bodyDef = new b2BodyDef();
    bodyDef.type = b2Body.b2_dynamicBody;
    bodyDef.position.Set(jointPos.x, jointPos.y);
    lipBody = world.CreateBody(bodyDef);
    
    // fixtures definition for the lips
    var boxDef = new b2FixtureDef();
    boxDef.filter.groupIndex = LIP_GROUP_INDEX;
    boxDef.filter.maskBits = LIP_MASK;
    boxDef.filter.categoryBits = LIP_CATEGORY;
    boxDef.density = 0.005;
    boxDef.friction = 0.1;
    boxDef.restitution = 0.1;
    boxDef.shape = new b2PolygonShape();
    
    
    boxDef.shape.SetAsOrientedBox(w, bh, new b2Vec2(0,bh*yDir), 0);
    lipBody.CreateFixture(boxDef);
    
    var circDef = new b2FixtureDef();
    circDef.filter.groupIndex = LIP_GROUP_INDEX;
    circDef.filter.maskBits = LIP_MASK;
    circDef.filter.categoryBits = LIP_CATEGORY;
    circDef.density = 0.005;
    circDef.friction = 0.1;
    circDef.restitution = 0.1;
    
    circDef.shape = new b2CircleShape();
    circDef.shape.SetRadius(w);
    circDef.shape.SetLocalPosition(new b2Vec2(0,bh*2*yDir));
    lipBody.CreateFixture(circDef);
    
    b2RevoluteJointDef jointDef = new b2RevoluteJointDef();
    jointDef.Initialize(connectTo, lipBody, jointPos);
    jointDef.enableMotor = true;
    jointDef.motorSpeed = 0;
    jointDef.maxMotorTorque = lipMotorTorqueFirstSeg;
    jointDef.lowerAngle = -PI*.5;
    jointDef.upperAngle = PI*.1;
    if (xDir*yDir < 0) {
      jointDef.lowerAngle = -PI*.1;
      jointDef.upperAngle = PI*.5;
    }
    jointDef.enableLimit = true;
    jointDef.collideConnected = false;
    joint = world.CreateJoint(jointDef);
    
    bodies = new ArrayList();
    joints = new ArrayList();
    b2Body lastLipBody = lipBody;
    for (int i = 1; i < lipNumSegs; i++) {
      jointPos.y += bh*2*yDir;
      
      bodyDef.position.Set(jointPos.x,jointPos.y);
      b2Body b = world.CreateBody(bodyDef);
      b.CreateFixture(boxDef);
      b.CreateFixture(circDef);
      bodies.add( b );
      
      b2RevoluteJointDef linkDef = new b2RevoluteJointDef();
      linkDef.Initialize(lastLipBody, b, jointPos);
      linkDef.enableMotor = true;
      linkDef.motorSpeed = 0;
      linkDef.maxMotorTorque = lipMotorTorqueRestSegs;
      linkDef.lowerAngle = -PI;
      linkDef.upperAngle = PI;
      linkDef.enableLimit = true;
      linkDef.collideConnected = false;
      
      joints.add( world.CreateJoint(linkDef) );
      
      lastLipBody = b;
    }
  }
  
  void step(float tongueLen) {
    float a = joint.GetJointAngle();
    float gain = lipGain;
    float target = (tongueLen) * -xDir*yDir*PI*.5;
    joint.SetMotorSpeed( gain*(target-a) );
    
    
    for (int i = 0; i < joints.size(); i++) {
      b2RevoluteJoint j = joints.get(i);
      float aa = j.GetJointAngle();
      float tt = -lipRestCurve*xDir*yDir;
      float gain2 = gain*5;
      j.SetMotorSpeed(gain2*(tt-aa) );
    }
    
  }
  
  void draw(PVector skinColor) {
    if (useBuffer) {
      pg.noStroke();
      pg.noTint();
      pg.fill(skinColor.x,skinColor.y,skinColor.z);
    } else {
      noStroke();
      noTint();
      fill(skinColor.x,skinColor.y,skinColor.z);
    }
    
    drawBody(lipBody);
    for (int i = 0; i < bodies.size(); i++) {
      drawBody(bodies.get(i));
    }
    ellipse(joint.GetAnchorA().x, joint.GetAnchorA().y, w*2, w*2); 
  }
}

class Tongue {
  
  // all the rigid bodies
  ArrayList center;
  ArrayList thickness[]; // bodies on the sides of the tongue, that push out from the center for thickness
  // all the joints
  ArrayList hinges; // rotational joints
  ArrayList extenders; // prismatic joints to extend the tongue
  ArrayList thickeners[][]; // prismatic joints to thicken the tongue
  // the body that the back of the tongue is attached to
  b2Body base; //the body that the base of the tongue gets attached to 
  PVector c;
  float thinThickeners[][];
  
  // parameters defining the location, length, etc of the tongue
  b2Vec2 start, spacing;
  b2Vec2 boxSize;
  int numSegs;
  
  // shape parameters, controlled by user input, that define how the tongue shape changes
  float curve; // target angle at each hinge joint
  b2Vec2 curveRange = tongueCurveRange;
  float len; // target length of the tongue
  float actualLen;
  
  // define which keys control this tongue
  int keyCodeUp, keyCodeDown;
  
  int flippedTongue;
  int tonguePlayer;
  
  float bodyMass = 1;
  
  b2Vec2 tip;
  
  Tongue(b2Body base, b2Vec2 st, b2Vec2 sp, PVector skinColor) {
    this.base = base;
    numSegs = tongueNumSegs;
    start = st;
    spacing = sp;
    boxSize = new b2Vec2(abs(sp.x*.5), sp.y*.5);
    flippedTongue = 1;
    tonguePlayer = 1;
    
    keyCodeUp = 'a';
    keyCodeDown = 'z';
    if (sp.x < 0) {
      flippedTongue = -1;
      tonguePlayer = 0;
    }
    
    c = new PVector(208,82,82);
    float skinColorWt = .2;
    
    c.add(PVector.mult(skinColor,skinColorWt));
    c.mult(1.0/(1+skinColorWt));
    //if (tonguePlayer == 1) {
    //  c = new PVector(208,82,191);
    //}
    
    build(numSegs, start, spacing);
  }
  
  void build(int segs, b2Vec2 st, b2Vec2 sp) {
    numSegs = segs;
    start = st;
    spacing = sp;
    
    center = new ArrayList();
    thickness = new ArrayList[2]; // bodies on the sides of the tongue, that push out from the center for thickness
    thickness[0] = new ArrayList(); 
    thickness[1] = new ArrayList();
    hinges = new ArrayList(); // rotational joints
    extenders = new ArrayList(); // prismatic joints to extend the tongue
    thickeners = new ArrayList[2]; // prismatic joints to thicken the tongue
    thickeners[0] = new ArrayList(); 
    thickeners[1] = new ArrayList(); 
    
    thinThickeners = new float[numSegs][2];
    for (int side = 0; side < 2; side++) {
      for (int i = 0; i < numSegs; i++) {
        thinThickeners[side][i] = 0;
      }
    }
    
    b2FixtureDef fix = new b2FixtureDef();
    fix.density = .1;
    fix.friction = tongueFriction;
    fix.restitution = 0.2;
    b2Shape midRect = new b2PolygonShape(); 
    fix.shape = midRect; fix.shape.SetAsBox(boxSize.x*(tongueLongLengthFactor-1), boxSize.y);
    b2Shape thinRect0 = new b2PolygonShape(), thinRect1 = new b2PolygonShape(); 
    float slopFactor = 4;
    thinRect1.SetAsOrientedBox(boxSize.x*(tongueLongLengthFactor-1)*1.2, boxSize.y-slopFactor*Box2D.Common.b2Settings.b2_linearSlop,
        new b2Vec2(0,slopFactor*Box2D.Common.b2Settings.b2_linearSlop), 0);
    thinRect0.SetAsOrientedBox(boxSize.x*(tongueLongLengthFactor-1)*1.2, boxSize.y-slopFactor*Box2D.Common.b2Settings.b2_linearSlop,
        new b2Vec2(0,-slopFactor*Box2D.Common.b2Settings.b2_linearSlop), 0);
    b2Shape thinRectOff = new b2PolygonShape();
    thinRectOff.SetAsOrientedBox(boxSize.x*(tongueLongLengthFactor-1)*1.2, boxSize.y-slopFactor*Box2D.Common.b2Settings.b2_linearSlop, 
        new b2Vec2(-flippedTongue*boxSize.x*(tongueLongLengthFactor-1)*.4,0), 0);
    //fixDef.shape = new b2CircleShape(); fixDef.shape.SetRadius(boxSize.x);
    fix.filter.groupIndex = TONGUE_INDEX_BASE - tonguePlayer;
    fix.filter.maskBits = TONGUE_MASK;
    fix.filter.categoryBits = TONGUE_CATEGORY;
    //fix.angularDamping = 1;
    //fix.linearDamping = 1;
    
    b2CircleShape endCircle1 = new b2CircleShape();
    b2CircleShape endCircle2 = new b2CircleShape();
    endCircle1.SetRadius(boxSize.y);
    endCircle2.SetRadius(boxSize.y);
    endCircle1.SetLocalPosition(new b2Vec2(-boxSize.x*1.5*flippedTongue));
    endCircle2.SetLocalPosition(new b2Vec2(boxSize.x*1.5*flippedTongue));
    
    
    bodyDef = new b2BodyDef();
    bodyDef.type = b2Body.b2_dynamicBody;
    
    
    boolean addEndCaps = false;
    
    float x = start.x;
    for (int i = 0; i < numSegs; i++) {
      
      bodyDef.position.Set(x, start.y);
      b2Body b = world.CreateBody(bodyDef);
      fix.density = .01;
      b.CreateFixture(fix);
      bodyMass = b.GetMass();
      center.add(b);
      
      for (int side = 0; side < 2; side++) {
        bodyDef.position.Set(x,start.y-2.5*boxSize.y*(side*2-1));
        b2Body thb = world.CreateBody(bodyDef);
        fix.density = .001;
        fix.shape = midRect;
        thb.CreateFixture(fix);
        if (i < numSegs) {
          fix.isSensor = true;
           
          
          if (i+1 == numSegs) {
            fix.shape = thinRectOff;
          } else if (side == 0) {
            fix.shape = thinRect0;
          } else {
            fix.shape = thinRect1;
          }
          fix.userData = (side*2-1)*(i+1) + 10000*tonguePlayer;
          thb.CreateFixture(fix);
          fix.userData = null;
          fix.isSensor = false;
        }
        if (addEndCaps && i > 0 && i + 1 < numSegs) {
          fix.shape = endCircle1;
          thb.CreateFixture(fix);
          fix.shape = endCircle2;
          thb.CreateFixture(fix);
        }
        thickness[side].add(thb);
        fix.shape = midRect;
      }
      
      if (i % 2 == 1) {
        x += spacing.x;
      } else {
        x -= spacing.x*tongueShortLengthFactor;
      }
    }

    b2Body connectTo = base;
    for (int i = 0; i < numSegs; i++) {
      b2Body b = (b2Body)center.get(i);
      if (i%2 == 0) { // rotation joints (for curving the tongue)
        b2RevoluteJointDef jointDef = new b2RevoluteJointDef();
        b2Vec2 bp = b.GetPosition();
        jointDef.Initialize(connectTo, b, new b2Vec2(bp.x-spacing.x,bp.y));
        jointDef.enableMotor = true;
        jointDef.motorSpeed = 0;
        jointDef.maxMotorTorque = tongueCurveMotorStrength;
        jointDef.lowerAngle = curveRange.x;
        jointDef.upperAngle = curveRange.y;
        jointDef.enableLimit = true;
        jointDef.collideConnected = false;
        hinges.add(world.CreateJoint(jointDef));
      } else { // extender joints (for lengthening the tongue)
        b2PrismaticJointDef prismDef = new b2PrismaticJointDef();
        b2Vec2 bp = b.GetPosition();
        prismDef.Initialize(connectTo, b, bp, new b2Vec2(1,0));
        prismDef.lowerTranslation = 0;
        prismDef.upperTranslation = spacing.x*2;
        if (prismDef.upperTranslation < prismDef.lowerTranslation) {
          prismDef.lowerTranslation = spacing.x*2;
          prismDef.upperTranslation = 0;
        } 
        prismDef.enableLimit = true;
        prismDef.maxMotorForce = tongueLengthMotorStrength*bodyMass;
        prismDef.motorSpeed = 0;
        prismDef.enableMotor = true;
        extenders.add(world.CreateJoint(prismDef));
      }
      for (int side = 0; side < 2; side++) { // thickening joints
        b2PrismaticJointDef prismDef = new b2PrismaticJointDef();
        b2Body th = (b2Body)thickness[side].get(i);
        b2Vec2 bp = b.GetPosition();
        prismDef.Initialize(th, b, bp, new b2Vec2(0,1));
        prismDef.lowerTranslation = 0;
        prismDef.upperTranslation = boxSize.y*2.5;
        prismDef.enableLimit = true;
        prismDef.maxMotorForce = tongueWidthMotorStrength*bodyMass;
        prismDef.motorSpeed = 0;
        if (side == 1) {
          prismDef.lowerTranslation = -boxSize.y*2.5;
          prismDef.upperTranslation = 0;
        }
        prismDef.enableMotor = true;
        thickeners[side].add(world.CreateJoint(prismDef));
      }
      connectTo = b;
    }

    
  }
  
  float floppiness = 0;
  
  int stepCount = 0;
  void step(boolean ignoreInput) {
    stepCount++;
    
    // gradually re-thicken tongue segments 
    for (int side = 0; side < 2; side++) {
      for (int i = 0; i < numSegs; i++) {
        thinThickeners[side][i] *= .99;
      }
    }
    
    // default eyeHit array to false; when we detect eye hits in the below loop we will set it back to true as needed
    eyeHit[0] = false; eyeHit[1] = false;
    
    // detect which segments of the tongue we should thin
    for (b2Contact c = world.GetContactList(); c; c = c.GetNext()) {
      if (c.IsTouching()) {
        b2Fixture a = c.GetFixtureA();
        b2Fixture b = c.GetFixtureB();
        
        int agi = a.GetFilterData().groupIndex;
        int bgi = b.GetFilterData().groupIndex;
        
        boolean tongueInvolved =  (agi == -1 || agi == -2
                                || bgi == -1 || bgi == -2);
        if (tongueInvolved) {
          //if (agi > 4 || bgi > 4) {
            //console.log("tongue eye " + agi + " " + bgi);
          //}
          int eh = -1;
          int uEye = agi - EYE_GROUP_INDEX_BASE;
          if (uEye < 2 && uEye >= 0) {
            eh = uEye;
          } else {
            uEye = bgi - EYE_GROUP_INDEX_BASE;
            if (uEye < 2 && uEye >= 0) {
              eh = uEye;
            }
          }
          if (eh > -1) {
            eyeHit[eh] = true;
          }
          
          
        }
        
        
        /*if (a.GetFilterData().groupIndex > 0 || b.GetFilterData().groupIndex > 0) {
          continue;
        }*/
        if (a.IsSensor() && b.IsSensor()) {
          continue;
        }
        if (a.IsSensor() || b.IsSensor()) { // it's a tongue thinner!
          int u = a.GetUserData();
          b2Fixture tongueFix = a, otherFix = b;
          if (b.IsSensor()) {
            u = b.GetUserData();
            tongueFix = b; otherFix = a;
          }
          int player = 0;
          if (u > 1000) {
            player = 1;
            u -= 10000;
          }
          
          
          
          if (player != tonguePlayer) {
            continue;
          }
          if ((1-tonguePlayer) == otherFix.GetFilterData().groupIndex-FACE_GROUP_INDEX_BASE) { // ignore tongue bits colliding with own face
            continue;
          }
        
        
          /* // debug vis. of where the collisions are that will thin the tongue
          b2Vec2 ap = a.GetBody().GetPosition();
          b2Vec2 bp = b.GetBody().GetPosition();
          stroke(255,0,255);
          strokeWeight(.1);
          fill(0,255,0);
          //line(ap.x,ap.y,bp.x,bp.y);
          ellipse(ap.x,ap.y,.6,.6);
          fill(0,255,255);
          ellipse(bp.x,bp.y,.6,.6);
          */
          
          int side = 1;
          if (u < 0) {
            u *= -1;
            side = 0;
          }
          u -= 1;
          thinThickeners[side][u] = thinThickeners[side][u]*.9 + .1;
        }
      }
    }
    
    
    boolean input = false;
    if (!ignoreInput) {
      if (key1Down[1-tonguePlayer]) {
        input = true;
        curve -= .025;
      }
      if (key2Down[1-tonguePlayer]) {
        input = true;
        curve += .025;
      }
      if (key1Down[1-tonguePlayer] && key2Down[1-tonguePlayer]) {
        if (curve > .025) curve -= .025;
        else if (curve < -.025) curve += .025;
        else curve *= .9;
      }
    }
    
    if (input) {
      len = len*.99 + .01*2;
      floppiness = floppiness*.95;
    } else {
      len = len*.99;
      curve += .01;
      float targetRestCurve = tongueRestCurvature;
      if (curve > targetRestCurve) { curve -= .02; } 
      if (abs(curve - targetRestCurve) < .01) curve = targetRestCurve;
      floppiness = floppiness*.9 + .1;
    }
    
    if (curve < curveRange.x) {
      curve = curveRange.x; 
    }
    if (curve > curveRange.y) {
      curve = curveRange.y;
    }
    
    // update box2d motors
    
      
    // tongue curvature
    for (int i = 0; i < hinges.size(); i++) {
      b2RevoluteJoint j = (b2RevoluteJoint)hinges.get(i);
      float a = j.GetJointAngle();
      float target = curve*flippedTongue;
      if (i == 0) target = 0;
      float gain = (1) * ((1-floppiness)*.5 + .5);
      if (i < 2) gain = 2;
      else if (i > 7) gain *= 100;
      else if (i > 6) gain *= 10;
      else if (i > 5) gain *= 3;
      else gain *= 1.2;
      float spd = (target-a)*gain*tongueCurvatureGainFactor;
      j.SetMotorSpeed(spd);
      if (i > 0) {
        float torqueBoost = (hinges.size()-i)*.5+1;
        j.SetMaxMotorTorque(((1-floppiness)*.8+.8) * bodyMass * 600 * torqueBoost);
      }
    }
    
    // tongue length
    for (int i = 0; i < extenders.size(); i++) {
      b2PrismaticJoint j = (b2PrismaticJoint)extenders.get(i);
      float jlen = j.GetJointTranslation();
      float target = len*flippedTongue;
      float gain = tongueLengthGain;
      j.SetMotorSpeed(gain * (target-jlen));
    }
    
    // tongue thickness
    float distAlong = 0;
    b2Vec2 lastbp;
    for (int i = 0; i < center.size(); i++) {
      b2Body b = (b2Body)center.get(i);
      b2Vec2 bp = b.GetPosition();
      
      if (i > 0) {
        b2Vec2 bd = new b2Vec2(lastbp.x-bp.x, lastbp.y-bp.y);
        distAlong += sqrt(bd.x*bd.x+bd.y*bd.y);
      }
      float targetWidth = heightAlongTongue(distAlong)*(tongueLongLengthFactor/2);
      

      for (int side = 0; side < 2; side++) {
        b2PrismaticJoint j = (b2PrismaticJoint)thickeners[side].get(i);
        float jt = j.GetJointTranslation();
        
        float nbrAvg = targetWidth;
        if (i > 2) {
          nbrAvg = thickeners[side].get(i-1).GetJointTranslation();
        }
        
        float target = targetWidth*(1-tongueWidthAffectsNeighborWidth)+nbrAvg*tongueWidthAffectsNeighborWidth;
        float thinTarget = -1*(side*2-1);
        float tt = thinThickeners[side][i];  
        target = (1-tt)*target + tt*thinTarget;
        
        float gain = tongueWidthGain;
        j.SetMotorSpeed(gain * (target-jt));
        
        
        targetWidth = -targetWidth;
      }
      lastbp = bp;
    }
    
    actualLen = distAlong;
    tip = center.get(numSegs-1).GetWorldPoint(new b2Vec2(spacing.x*.5, 0));
    
  }
  
  float restLen() {
    return boxSize.x * numSegs;
  }
  float longLen() {
    return boxSize.x * numSegs*tongueLongLengthFactor;
  }
  
  
  float heightAlongTongue(float distance) {
    float minDist = restLen();
    float maxDist = longLen();
    float curLen = (1+len)*minDist;
    float minH = .8-( (curLen-minDist)/(maxDist-minDist) )*.8;
    
    if (distance > curLen) return 1-minH;
    return ( distance/curLen )*(distance/curLen)*(1-minH); // linear shrinkage of tongue width along tongue length 
  }
  
  void drawFlesh() {
    
    float edgeSize = 1;
    float edgeSizeOffset = .5*edgeSize;
    float offsetX = edgeSize*.5;
    if (useBuffer) {
      pg.stroke(c.x,c.y,c.z);
      pg.strokeWeight(edgeSize);
      pg.strokeJoin(ROUND);
      pg.strokeCap(ROUND);
      pg.fill(c.x,c.y,c.z); // tongue color
    } else {
      stroke(c.x,c.y,c.z);
      strokeWeight(edgeSize);
      //strokeWeight(.05);
      strokeJoin(ROUND);
      strokeCap(ROUND);
      noFill();
      fill(c.x,c.y,c.z); // tongue color
    }
    
    
    // draw method 1:
    // no smoothing for now; just doing the obvious thing
    //texture(tongueImage); // note: texture only works in P3D mode; not sure if we want that
    /* 
    beginShape(TRIANGLE_STRIP);
    for (int i = 0; i < center.size(); i+=2) {
      for (int side = 0; side < 2; side++) {
        b2Vec2 local = new b2Vec2(spacing.x*.5,boxSize.y * (1-side*2) * -1);
        b2Body b = (b2Body)thickness[side].get(i);
        b2Vec2 bp = b.GetWorldPoint(local);
        vertex(bp.x,bp.y);//, tongueImage.width*i/(center.size()-1), tongueImage.height*side );
      }
    }
    endShape();
    */
    
    // draw method 2:
    
    // build arrays of control points and send them to smoothTube function
    ArrayList tongueSides[] = new ArrayList[2];
    tongueSides[0] = new ArrayList();
    tongueSides[1] = new ArrayList();
    for (int side = 0; side < 2; side++) {
      b2Vec2 local = new b2Vec2(-spacing.x*2,(boxSize.y-edgeSizeOffset) * (1-side*2) );
      b2Body b = (b2Body)thickness[side].get(0);
      b2Vec2 bp = b.GetWorldPoint(local);
      tongueSides[side].add(bp);
    }
    for (int i = 0; i < center.size(); i+=2) {
      for (int side = 0; side < 2; side++) {
        float offsetX = edgeSize*.5;
        b2Vec2 local = new b2Vec2(spacing.x*.75-offsetX*flippedTongue,(boxSize.y-edgeSizeOffset) * (1-side*2) );
        b2Body b = (b2Body)thickness[side].get(i);
        b2Vec2 bp = b.GetWorldPoint(local);
        tongueSides[side].add(bp);
      }
    }
    drawSmoothedTube(tongueSides[0], tongueSides[1], 5, 0);
    
    
    // draw method 3:
    // follow tongue curves & send vertices to drawShape
    
    /*
    ArrayList pts = new ArrayList();
    b2Vec2 incomingTangent = new b2Vec2(1,0);
    int side = 0;
    b2Vec2 local = new b2Vec2(spacing.x*.75-offsetX*flippedTongue,(boxSize.y-edgeSizeOffset) * (1-side*2) );
    b2Vec2 localMid = new b2Vec2(spacing.x*.25-offsetX*flippedTongue,(boxSize.y-edgeSizeOffset) * (1-side*2) );
    
    b2Vec2 incomingPt = thickness[side].get(0).GetWorldPoint(local);
    pts.add(new b2Vec2(incomingPt.x-flippedTongue*10, incomingPt.y));
    b2Vec2 lastPt = incomingPt;
    b2Vec2 lastTang = incomingTangent;
    for (side = 0; side < 2; side++) {
      local = new b2Vec2(spacing.x*.75-offsetX*flippedTongue,(boxSize.y-edgeSizeOffset) * (1-side*2) );
      localMid = new b2Vec2(spacing.x*0-offsetX*flippedTongue,(boxSize.y-edgeSizeOffset) * (1-side*2) );
      int idir = -1*(side*2-1);
      int istart = (side)*(center.size()-2);
      for (int i = istart; ((i+1) < center.size()) && ((i) >= 0); i += idir) {
        b2Vec2 p;
        if (i % 2 == 0) {
          p = thickness[side].get(i).GetWorldPoint(local);
        } else {

          p = thickness[side].get(i).GetWorldPoint(localMid);
          if (abs(extenders.get(int(i/2)).GetJointTranslation()) <abs(1.5*spacing.x)) {
            b2Vec2 interp = thickness[side].get(i-idir).GetWorldPoint(local);
            interp.Add(thickness[side].get(i+idir).GetWorldPoint(local));
            interp.Multiply(.5);
            float t = (abs(extenders.get(int(i/2)).GetJointTranslation())-abs(1.1*spacing.x)) / (abs(.4*spacing.x));
            if (t < 0) t = 0;
            p.x = p.x*t+interp.x*(1-t);
            p.y = p.y*t+interp.y*(1-t);
          }
        }
        pts.add(new b2Vec2(p.x,p.y));
        
        lastTang = b2Math.SubtractVV(p, lastPt);
        lastPt = p;
        
      }
      if (side == 0) { // draw mid tongue curve
        b2Vec2 localCenter = new b2Vec2(spacing.x*.75-offsetX*flippedTongue, 0);
        b2Vec2 p = center.get(center.size()-1).GetWorldPoint(localCenter);
        pts.add(new b2Vec2(p.x,p.y));
      }
    }
    b2Vec2 exitingPt = thickness[1].get(0).GetWorldPoint(local);
    pts.add(new b2Vec2(exitingPt.x-flippedTongue*10, exitingPt.y));
    spts = smoothPointList(pts, 5, 1);
    
    beginShape();
    for (int i = 0; i < spts.size(); i++) {
      b2Vec2 p = spts.get(i);
      vertex(p.x,p.y);
    }
    endShape();  
    */
    
    
    fill(255,255,255);
    
  }
  
  void draw() {
    
    
    drawFlesh();
    //drawDebug_Boxes();
    
  }
  
}


// functions to help draw smooth curves

// linear interp
b2Vec2 interp(b2Vec2 a, b2Vec2 b, float t) {
  return new b2Vec2(a.x*(1-t)+b.x*t, a.y*(1-t)+b.y*t);
}

// evaluate a cubic bezier of pts abcd at time t
b2Vec2 interpBez(b2Vec2 a, b2Vec2 b, b2Vec2 c, b2Vec2 d, float t) {
/*  b2Vec2 aa = interp(a,b,t);
  b2Vec2 bb = interp(b,c,t);
  b2Vec2 cc = interp(c,d,t);
  b2Vec2 aaa = interp(aa,bb,t);
  b2Vec2 bbb = interp(bb,cc,t);
  b2Vec2 aaaa = interp(aaa,bbb,t);
  */
  
  float t2 = t*t;
  float t3 = t2*t;
  float omt = 1-t;
  float omt2 = omt*omt;
  float omt3 = omt*omt2;
  
  return new b2Vec2( omt3*a.x + 3*omt2*t*b.x + 3*omt*t2*c.x + t3*d.x,
                     omt3*a.y + 3*omt2*t*b.y + 3*omt*t2*c.y + t3*d.y) ;
}

// smooth a point list; returns a catmull-rom splined version of the list
ArrayList smoothPointList(ArrayList pts, int samplesPerSeg, float bezTangentScale) {
  ArrayList toRet = new ArrayList();
  toRet.add(pts.get(0));
  int n = pts.size();
  for (int i = 0; i+1 < n; i++) {
    b2Vec2 a = pts.get(i);
    b2Vec2 d = pts.get(i+1);
    
    
    b2Vec2 a0 = a, d1 = d;
    float scalem1 = 1;
    if (i > 0) {
      scalem1 = .5;
      a0 = pts.get(i-1);
    }
    float scalem2 = 1;
    if (i < n-2) {
      scalem2 = .5;
      d1 = pts.get(i+2);
    }
    
    b2Vec2 m1 = b2Math.SubtractVV(d,a0);
    b2Vec2 m2 = b2Math.SubtractVV(d1,a);
    m1.Multiply(bezTangentScale*scalem1/3.0);
    m2.Multiply(bezTangentScale*scalem2/3.0);
    b2Vec2 b = b2Math.AddVV(m1,a);
    b2Vec2 c = b2Math.SubtractVV(d,m2);
    
    
    /* // debugging vis of control points
    stroke(50);
    ellipse(b.x,b.y,.1,.1);
    stroke(100,0,100);
    ellipse(c.x,c.y,.1,.1);
    noStroke();*/
    
    for (int ii = 1; ii < samplesPerSeg; ii++) {
      float t = ((float)ii) / ((float)samplesPerSeg);
      b2Vec2 p = interpBez(a,b,c,d,t);
      toRet.add(p);
    }
    //toRet.add(b);
    //toRet.add(c);
    toRet.add(d);
  }
  
  return toRet;
}

// draws a smooth tube by putting a spline through the top and bottom point arrays
void drawSmoothedTube(ArrayList top, ArrayList bot, int samplesPerSeg, int extraPointHack) {
  // if extraPointHack is not zero, adds extra points that are just useful for the tongue to extend back off-screen
  // (I no longer use / need extraPointHack; it is vestigial)
  ArrayList tsmooth = smoothPointList(top, samplesPerSeg, 1);
  ArrayList bsmooth = smoothPointList(bot, samplesPerSeg, 1);
  int n = tsmooth.size();
  /*beginShape(TRIANGLE_STRIP);
  //beginShape(LINES);
 
  
  for (int i = 0; i < n; i++) {
    b2Vec2 p = tsmooth.get(i);
    //ellipse(p.x,p.y,.2,.2);
    vertex(p.x,p.y);
    p = bsmooth.get(i);
    //ellipse(p.x,p.y,.2,.2);
    vertex(p.x,p.y);
  }
  endShape();
  //noFill();
  //stroke(255);
  */
  
  if (useBuffer) {
    pg.beginShape();
    b2Vec2 p;
    if (extraPointHack != 0) {
      p = tsmooth.get(0);
      pg.vertex(p.x+extraPointHack*10,p.y);
    }
    for (int i = 0; i < n; i++) {
      p = tsmooth.get(i);
      pg.vertex(p.x,p.y);
    }
    for (int i = n-1; i >= 0; i--) {
      p = bsmooth.get(i);
      pg.vertex(p.x,p.y);
    }
    if (extraPointHack != 0) {
      p = bsmooth.get(0);
      pg.vertex(p.x+extraPointHack*10,p.y);
    }
    pg.endShape(CLOSE);
  } else {
    beginShape();
    b2Vec2 p;
    if (extraPointHack != 0) {
      p = tsmooth.get(0);
      vertex(p.x+extraPointHack*10,p.y);
    }
    for (int i = 0; i < n; i++) {
      p = tsmooth.get(i);
      vertex(p.x,p.y);
    }
    for (int i = n-1; i >= 0; i--) {
      p = bsmooth.get(i);
      vertex(p.x,p.y);
    }
    if (extraPointHack != 0) {
      p = bsmooth.get(0);
      vertex(p.x+extraPointHack*10,p.y);
    }
    endShape(CLOSE);
  }
  
}

/*

planning file:

I don't know:
 - javascript anti-aliases everything it draws, I cannot make it stop :(
 so the only way I can see to get a pixel look is by drawing to a low res buffer and upscaling
 but then it's still anti-aliased, just at a lower res
 OR we could just embrace the fancy high resolution anti-aliased 640x480 future

to add:
 - back of mouth
 - properly import face images
 - color tinting of faces + tongues based on player selections
 - intro/player-select screen, consent screen
 
ideas:
 - tongues can fall out if kiss lasts more than a certain amount of time?  (they then explore world below)
 
blocked:
 - physics objects defining face don't match image of face (don't fix until face is more final) 
 
skipping for now:
 - to make the tongue smooth, I skip some details;
   this leads to imperfect-looking tongue physics, because the collisions in physics don't match the collisions the user sees
   in theory I could fix this in a couple of different ways (coming at it via rendering or physics) 
   for now it doesn't seem like a huge deal to me.
*/

