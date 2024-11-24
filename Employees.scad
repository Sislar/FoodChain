
$fn=40;

gWT = 1.4;          // Wall thickness

Lift = 24;          // Amount the rows lift for each layer
TopOpening = 25;    // How far down from the top to make the opening for cards
ConnThick = 2.1;

// 8mm is the thinnest it can go or not enough room for hinges. This is
// enough for all except the first management row needs 11 mm.
CardThickness = 8;

PinDepth = 4;       // distance of Pins from edge
InOutPinDiff = Lift/2;  // From outgoing pin to incoming pin height
ConnLength  = sqrt((PinDepth*2)*(PinDepth*2) + InOutPinDiff*InOutPinDiff);

TopPinOffset = 8;   // top pin from top edge
BotPinOffset = 8;   // bottom pin from bottom edge
// middle pin is always from center


echo ("conn length = ",ConnLength);

CardStack = CardThickness+2*gWT;

if (CardStack < 10.4)
    echo(CardStack, "CARD THICKNESS TOO SMALL FOR HINGES");


// with sleeves and walls
CardW = 61+2*gWT;
CardH = 96;

CardsPerRow = 4;



module RCube(x,y,z,ipR=4) {
    translate([-x/2,-y/2,0]) hull(){
      translate([ipR,ipR,ipR]) sphere(ipR);
      translate([x-ipR,ipR,ipR]) sphere(ipR);
      translate([ipR,y-ipR,ipR]) sphere(ipR);
      translate([x-ipR,y-ipR,ipR]) sphere(ipR);
      translate([ipR,ipR,z-ipR]) sphere(ipR);
      translate([x-ipR,ipR,z-ipR]) sphere(ipR);
      translate([ipR,y-ipR,z-ipR]) sphere(ipR);
      translate([x-ipR,y-ipR,z-ipR]) sphere(ipR);
      }  
} 

module pin(h=10, r=4, lh=3, lt=1) {
  // h = shaft height
  // r = shaft radius
  // lh = lip height
  // lt = lip thickness

  difference() {
      union() {
        // shaft
        cylinder(h=h-lh, r=r, $fn=30);
        translate([0, 0, h-lh]) cylinder(h=lh*0.25, r1=r, r2=r+(lt/2), $fn=30);
        translate([0, 0, h-lh+lh*0.25]) cylinder(h=lh*0.25, r=r+(lt/2), $fn=30);    
        translate([0, 0, h-lh+lh*0.50]) cylinder(h=lh*0.50, r1=r+(lt/2), r2=r-(lt/2), $fn=30);    
      }
    
    // center cut
    translate([-r*0.5/2, -(r*2+lt*2)/2, h/4]) cube([r*0.5, r*2+lt*2, h]);
    translate([0, 0, h/4]) cylinder(h=h+lh, r=r/2.5, $fn=20);
  
    // side cuts
    translate([-r*2, -lt-r*1.125, -1]) cube([r*4, lt*2, h+2]);
    translate([-r*2, -lt+r*1.125, -1]) cube([r*4, lt*2, h+2]);
  }
}

module connector(){
    difference(){
        union() {
           cylinder(r1=5,r2=5,h=ConnThick);
           translate([ConnLength,0,0]) cylinder(r1=5.2,r2=5.2,   h=ConnThick);
           translate([ConnLength/2,0,ConnThick/2])cube([ConnLength,5,ConnThick],center=true);
        }
        
       // drill the 2 holes (was 3.4 trying 3.3)
       translate([0,0,1])          cylinder(h=4, r=3.3, center =true);
       translate([ConnLength,0,1]) cylinder(h=4, r=3.3, center =true);
    }

}

module CardBox (width,thick,height){ 

      difference() {
        // create base box and hallow it out
        cube ([width,thick,height], center=true);
        translate([0,0,gWT]) cube ([width-2*gWT,thick-2*gWT,height], center=true);

        // Top access to grab card
        translate([0,0,height/2-TopOpening]) RCube(width-10,2*thick,2*TopOpening,15); 
        
         // Access to see Milstone text, 2 strectched cylinders hulled
        hull(){
            translate([0,10,4]) scale([1,1,0.5])
                 rotate([90,0,0])cylinder(h=40,r=(width/2)-10,center=true);
            translate([0,10,-30]) scale([1,1,0.5])
                 rotate([90,0,0])cylinder(h=40,r=(width/2)-10,center=true);
        }
        
    }
}

module CardRow(Type="Middle")
{
    difference(){
        union(){
           for (slot=[0:CardsPerRow-1])
               translate([CardW/2+CardW*slot-(gWT/2)*slot,0,0]) CardBox(CardW,CardStack,CardH);  
        }        
    }
    
    // Outgoing Pins for next row  Not needed for last row
    if (Type != "Last"){
        // TopOutPinLeft   10 mm from top , 5 mm from edge
        translate([CardW*CardsPerRow-(gWT/2)*(CardsPerRow-1),-CardStack/2 + PinDepth,CardH/2-TopPinOffset])rotate([90,0,90])
              pin(h=5, r=3, lh=3, lt=1);
        // MidOutPinLeft middle line so raise by half of InOutPinDiff
        translate([CardW*CardsPerRow-(gWT/2)*(CardsPerRow-1),-CardStack/2 + PinDepth, InOutPinDiff/2])rotate([90,0,90])
              pin(h=5, r=3, lh=3, lt=1);
        // BotOutPinLeft  match is 10mm from bot so this is 10mm + InOutPinDiff
        translate([CardW*CardsPerRow-(gWT/2)*(CardsPerRow-1),-CardStack/2 + PinDepth, -CardH/2+BotPinOffset+InOutPinDiff])rotate([90,0,90])
              pin(h=5, r=3, lh=3, lt=1);
            
        // TopOutPinRight  10 mm from top
        translate([0,-CardStack/2 + PinDepth,CardH/2-TopPinOffset])rotate([90,0,-90])
              pin(h=5, r=3, lh=3, lt=1);
        // MidOutPinRight middle line so raise by half of InOutPinDiff
        translate([0,-CardStack/2 + PinDepth, InOutPinDiff/2])rotate([90,0,-90])
              pin(h=5, r=3, lh=3, lt=1);
        // BotOutPinRight  match is 10mm from bot so this is 10mm + InOutPinDiff
        translate([0,-CardStack/2 + PinDepth, -CardH/2+BotPinOffset+InOutPinDiff])rotate([90,0,-90])
              pin(h=5, r=3, lh=3, lt=1);        
        
    }
    
        // incoming Pins for next row  3 pins per not for first row
    if (Type != "First") {
        // TopInPinLeft   10 + InOutPinDiff mm from top
        translate([CardW*CardsPerRow-(gWT/2)*(CardsPerRow-1), CardStack/2 - PinDepth,CardH/2-TopPinOffset-InOutPinDiff])rotate([90,0,90])
              pin(h=5, r=3, lh=3, lt=1);
        // MidInPinLeft middle line so raise by half of InOutPinDiff
        translate([CardW*CardsPerRow-(gWT/2)*(CardsPerRow-1), CardStack/2 - PinDepth, -InOutPinDiff/2])rotate([90,0,90])
              pin(h=5, r=3, lh=3, lt=1);
        // BotInPinLeft  10mm from bottom
        translate([CardW*CardsPerRow-(gWT/2)*(CardsPerRow-1), CardStack/2 - PinDepth, -CardH/2+BotPinOffset])rotate([90,0,90])
              pin(h=5, r=3, lh=3, lt=1);
        // TopInPinRight  10 mm from top
        translate([0,CardStack/2 - PinDepth,CardH/2-TopPinOffset-InOutPinDiff])rotate([90,0,-90])
              pin(h=5, r=3, lh=3, lt=1);
        // MidInPinRight middle line so raise by half of InOutPinDiff
        translate([0,CardStack/2 - PinDepth, -InOutPinDiff/2])rotate([90,0,-90])
              pin(h=5, r=3, lh=3, lt=1);
        // BotInPinRight  match is 10mm from bot so this is 10mm + InOutPinDiff
        translate([0,CardStack/2 - PinDepth, -CardH/2+BotPinOffset])rotate([90,0,-90])
              pin(h=5, r=3, lh=3, lt=1);             
    }    
        
}



//sCardRow("First");
//CardRow("Middle");
CardRow("Last");

//connector();

//rotate([65,0,0]) CardRow(3);        



