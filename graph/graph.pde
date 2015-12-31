Graph graph1 = new Graph(150, 80, 400, 200, color (200, 20, 20));
Graph graph2 = new Graph(150, 410, 400, 200, color (20, 20, 200));

PFont f; 

import processing.serial.*;

boolean p;

float lastPunch = 0;

String initialData [];

float lastIntensityPunch = 0;

int maxIntensityPunch = 0;

float maxi = 0;

float maxMS = 0;

int timeStart;

int currentXAxis;
int previousXAsxis;

int punches = 0;
int MPH = 0;
float force = 0;
float [] intesnity = {
  0
};


int [] data;

float[] time = {
  0
};       
float[] ax = {
  0
}; 
float[] ay = {
  0
};
float[] az = {
  0
};


int[] intervals = {
  5 * 60 * 60, 60 * 60, 0, 1
};
float[] avgs = {
  0, 0, 0, 0
};
float[] totals = {
  0, 0, 0, 0
};

int arrayElement;

String dataLine = "";

Serial myPort;  

String line;
void setup()
{
  frameRate(10);

  size(900, 800); 

  timeStart = millis();

  f = createFont("Helvetica", 16, true); 

  printArray(Serial.list());
  myPort = new Serial(this, Serial.list()[5], 9600);
  arrayElement = 0;
  dataLine = "";


  graph1.xLabel = " Time (s)";
  graph1.yLabel = "Acceleration (m/s^2)";
  graph1.Title = " Acceleration: (x, y, z) vs. t ";  
  graph1.yMin = 0;

  graph2.xLabel = " Averages ";
  graph2.yLabel = "Intensity (m/s^2)";
  graph2.Title = " Average Intensity ";  
  graph2.xDiv = 5;  
  graph2.yMin = 0;
}

float curAx = 0;
float curAy = 0;
float curAz = 0;
float curTime = 0;

float intensity = 0;

float offset = 0;
int count_test = 0;
void draw()
{

  DecimalCompare();

  int curAx = int(ax[arrayElement]);
  int curAy = int(ay[arrayElement]);
  int curAz = int(az[arrayElement]);

  curTime += 1;

  time = pushv(time, curTime, 20);
  ax = pushv(ax, curAx, 20);
  printArray(ax);
  ay = pushv(ay, curAy, 20);
  az = pushv(az, curAz, 20);
  
  

  updatePlots();

  /* compute magnitude of acceleration */
  float mag = sqrt(curAx * curAx + curAy * curAy + curAz * curAz);
  for (int j = 0; j < intervals.length; j++) {
    totals[j] += mag - avgs[j];
    avgs[j] = totals[j] / (intervals[j] == 0 ? curTime : intervals[j]);
  }

  /* update displays */
  punches();
  updatePlots();
  if ((int(curTime) % 100) == 0) {
    if (offset == 0) {
      offset = 6000;
    } else {
      offset = 0;
    }
  }
}

void updatePlots()
{
  background(0);



  graph1.xMax = max(time);
  graph1.xMin = min(time);
  graph1.yMax = max(max(max(az), max(ax), max(ay)), graph1.yMax);
  graph1.yMin = min(min(min(az), min(ax), min(ay)), graph1.yMin);


  /*  ====================================================================== 
   *  Arrays of any size can be placed into smoothLine([][]) and Bar([])
   *  If the function takes more than 1 array, both MUST be the same size 
   *  ======================================================================
   */
  graph1.DrawAxis();


  graph1.GraphColor = color(255, 0, 222);  
  graph1.smoothLine(time, ax);      

  graph1.GraphColor = color(68, 255, 0);   
  graph1.smoothLine(time, ay);

  graph1.GraphColor = color(0, 247, 255);   
  graph1.smoothLine(time, az);

  graph2.yMax = int (max(max(avgs), graph2.yMax));
  graph2.xMax = 60;
  graph2.DrawAxis();              
  graph2.Bar(avgs);                // This draws a bar graph of avgs

  fill(255, 0, 222);  // Set fill 
  rect(675, 25, 125, 125);  // Draw pink rect 

  fill(0);  
  rect(687, 42, 100, 100);  // Draw rect using CENTER mode*/

  textFont(f, 16);                 // STEP 4 Specify font to be used
  fill(255);                        // STEP 5 Specify font color 
  text("PUNCHES", 777, 40);  // STEP 6 Display Text
  punches();

  fill (68, 255, 0);
  rect(675, 225, 125, 125);

  fill(0);
  rect(687, 242, 100, 100);

  textFont(f, 16);                 // STEP 4 Specify font to be used
  fill(0);                        // STEP 5 Specify font color 
  text("MPH", 755, 240);  // STEP 6 Display Text
  mph();

  fill (0, 247, 255);
  rect(675, 425, 125, 125);

  fill(0);
  rect(687, 442, 100, 100);

  textFont(f, 16);                 // STEP 4 Specify font to be used
  fill(0);                        // STEP 5 Specify font color 
  text("FORCE (ft-lb)", 788, 440);  // STEP 6 Display Text
  force();

  fill (255);
  rect(675, 625, 125, 125);

  fill(0);
  rect(687, 642, 100, 100);

  textFont(f, 16);                 // STEP 4 Specify font to be used
  fill(0);                        // STEP 5 Specify font color 
  text("INTENSITY", 781, 640);  // STEP 6 Display Text
  intensity();
}

/*
 *  ======== pushv ========
 */
float[] pushv(float [] arr, float val, int maxLen)
{
  float [] tmp = append(arr, val);
  if (tmp.length > maxLen) {
    tmp = subset(tmp, 1);
  }
  return (tmp);
}



void punches()
{
  float m = 0;
  for (int i = 0; i <az.length; i++)
  {
    if (az[i] > m || ax[i] > m || ay[i] > m) // finds the axis that had the greatest amount of accelertaion
    {
      if(az[i] > m && az[i] > ay[i] && az[i] > ax[i])
      {
        m = az[i];
      }
      if(ax[i] > m && ax[i] > ay[i] && ax[i] > az[i])
      {
        m = ax[i];
      }
      if(ay[i] > m && ay[i] > az[i] && ay[i] > ax[i])
      {
        m = ay[i];
      }
      
    }
  }
  if (m > 150) // if the acceleration is greater than 150 m/s/s then is is a punch
  {
    if ( m != lastPunch) 
    {
      punches++;
    }

    lastPunch = m; 
  }

  textSize(64);
  text(int(punches), 781, 110 ); 
  fill(255);
}

void mph()
{
  float m =0;
  int l = 0; 
  int mph = 0;
  
  for (int i = 0; i < az.length; i++)
  {
    if ( az[i] <= ax[i] + 400)
    {   
      
      l++; //finds the length bellow the curve (the bast of the triange)
    }
  }
  for (int j = 0; j < ay.length; j++)
  {
    if ( ay[j] > m)
    {
      m = ay[j]; //finds the height of the curve
    }
    if (m > maxMS)
    {
      maxMS = m;
    }
    mph = (int)(((maxMS * l)/1000)*2.23694); //this does a rough integration of the accelertaion data and changes it into MPH
  }
  if (mph>MPH)
  {
    MPH = mph;
  }
  textFont(f, 64);                 
  fill(255);                        
  text(MPH, 781, 310);  
}


void force()
{

  for (int i = 0; i < ay.length; i++)
  {
    if ( ay[i] > maxi)
    {
      maxi = ay[i];
    }
  }
  if (maxi > force)
  {
    force = maxi;
  }
  textFont(f, 32);                 
  fill(255);                        
  text(int(force*(3.28084)*1.289704), 780, 500); //force multipied by average mass of a hand multipied again to conert into ft-lb 
}

void intensity()
{ 

  float TM = (millis()-timeStart)/10000;

  intensity = ((punches)/TM);


  textFont(f, 32);                 
  fill(255);                        
  text(intensity, 781, 710);  
}

void DecimalCompare()
{
  while (myPort.available() > 0)
  {
    char inByte = myPort.readChar();
    if (inByte == '\n') 
    {
      //print("found end of line\n");
      continue;
    }
    if (inByte == '\r') 
    { 
      //print("found carriage return\n");
      break;
    } else
    {
      //print("still looking " + inByte + " \n");
    }
    //print("read char "+ inByte + "\n");
    dataLine += inByte;
  }

  // check to make sure there is something in dataLine before calling the split function
  if ( dataLine.length() > 0 )
  {
    //print("Printing Dataline: " + dataLine + "\n");
    initialData = dataLine.split(",");

    if (initialData.length > 0)
    {
      if (initialData[0] != "")
      {
        //print("moving data from array" + initialData[0] + " " + initialData[1] + " " + initialData[2]  + "\n");
        int xVal = Integer.parseInt(initialData[0]);
        int yVal = Integer.parseInt(initialData[1]);
        int zVal = Integer.parseInt(initialData[2]);
        ax[arrayElement] = xVal;
        ay[arrayElement] = yVal;
        az[arrayElement] = zVal;
        // only increment "arrayElement" after it is used.  
        if(arrayElement < 19)
        {
        arrayElement++;
        }
        else 
        {
           arrayElement = 0; 
        }
        //printArray(ax);
        //print(dataLine);
      }
    }  // if initialData.length > 0
  }  // if dataLine.length > 0

  dataLine = "";
}