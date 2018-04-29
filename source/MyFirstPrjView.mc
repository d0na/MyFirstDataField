using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;

class MyFirstPrjView extends Ui.DataField {


    var arrayDistance = new [5];
    var arrayAltitude = new [5];
    var arrayIndex = 0;

    var currDistance = 0;
    var currAltitude = 0;


	var boxBmiddleFieldMode;
	var boxBmiddleField;
	var boxBmiddleFieldLabel;

	var boxCmiddleFieldMode;
	var boxCmiddleField;
	var boxCmiddleFieldLabel;

    var boxCtopLeftFieldMode;
	var boxCtopLeftField;
	var boxCtopLeftFieldLabel;

	var boxDtopRightFieldMode;
	var boxDtopRightField;
	var boxDtopRightFieldLabel;

	var boxDmiddleFieldMode;
    var boxDmiddleField;
    var boxDmiddleFieldLabel;

    var boxDtopLeftFieldMode;
    var boxDtopLeftField;
    var boxDtopLeftFieldLabel;

	var boxEmiddleFieldMode;
	var boxEmiddleField;
	var boxEmiddleFieldLabel;

	var boxFmiddleFieldMode;
	var boxFmiddleField;
	var boxFmiddleFieldLabel;

	var timerFieldMode;
	var batteryField;
	var batteryFieldOffset;

	var speed;
	var currentLap;
	var previousLapDist;
	var previousLapTime;
	var lapSplit;
	var split;

	var timer;
	var timerType;
	var timer_x;
	var timer_y;
	var timerLabel_y;

	var timeField;
	var timeFieldOffset;

	var invertMiddleBackground;
	var foregroundColour;
	var backgroundColour;


	function initialize() {

		DataField.initialize();

		var usePreferences = 0;
		
		var background = 0;  // 0=white; 1=black
		invertMiddleBackground = false;  // ... of the middle two fields only
		timerType = 0; // 0=timer, 1=total elapsed time
		lapSplit = 1.0; // lap split in km or miles

        /*
		        0=dist, 1=curPace, 2=lapPace, 3=avePace, 4=HR, 5=aveHR, 6=Cadence, 7=aveCadence
        	    8=grade, 9=totAscent, 10=lap distance, 11=maxHR , 12 = HR zone, 13 = Altitdue
        */

		boxBmiddleFieldMode = 13;
		boxCmiddleFieldMode = 8;
		boxDmiddleFieldMode = 1;
		boxDtopLeftFieldMode = 1;
		boxDtopRightFieldMode = 1;
		boxEmiddleFieldMode = 0;
		boxFmiddleFieldMode = 3;
		timerFieldMode = true;  // true=timer AND time+battery

		if (usePreferences == 1) {
			background = Application.getApp().getProperty("blackBackground");
			invertMiddleBackground = Application.getApp().getProperty("invertMiddleBackground");
			boxBmiddleFieldMode = Application.getApp().getProperty("boxBmiddleFieldMode");
			boxCmiddleFieldMode = Application.getApp().getProperty("boxCmiddleFieldMode");
			boxDmiddleFieldMode = Application.getApp().getProperty("boxDmiddleFieldMode");
			boxEmiddleFieldMode = Application.getApp().getProperty("boxEmiddleFieldMode");
			lapSplit = Application.getApp().getProperty("lapSplit");
			timerType = Application.getApp().getProperty("timerType");
			timerFieldMode = Application.getApp().getProperty("timerFieldMode");
		}

		if (background == 1) {
			foregroundColour = Gfx.COLOR_WHITE;
			backgroundColour = Gfx.COLOR_BLACK;
		} else {
			foregroundColour = Gfx.COLOR_BLACK;
			backgroundColour = Gfx.COLOR_WHITE;
		}

		timeFieldOffset = 0;
		batteryFieldOffset = 0;

		if (timerFieldMode == true) {
			timer_x = 77;
			timer_y = 143;
			timerLabel_y = 170;
		} else {
			timer_x = 107.5;
//			timer_y = 159;
			timer_y = 10;
			timerLabel_y = 133;
		}

		if (Sys.getDeviceSettings().distanceUnits == Sys.UNIT_METRIC) {
			split = 1000.0;
		} else {
			split = 1609.0;
		}

		if (lapSplit == null || lapSplit <= 0 || lapSplit > 100) {
			lapSplit = 1.0;
		}
		lapSplit = lapSplit * split;
		
		currentLap = 1;
		previousLapDist = 0.0;
		previousLapTime = 0.0;

	}


	function onLayout(dc) {
	}

	function onShow() {
	}

	function onHide() {
	}


	function onUpdate(dc) {

        /*
                -------------------------------     0
           A   | Aleft                  Aright |
               |           Amiddle             |
               A ------------- VA -------------
               | Btl       Btr |           Ctr |
               |     Bmid      |      Cmid     |
               | Bbl           |           Cbr |
               B ------------------------------
               |                               |
               |             Dmiddle           |
               |                               |
               C ------------- VC -------------
               |               |               |
               |      E        |      F        |
               |               |               |
               D ------------------------------
               |              G                |
                -------------------------------  264

            215x263
         */


        var HEIGHT =  70;
        var pHA = 20;    // horizontal point  A
        var pHB = pHA+HEIGHT;    // horizontal point  B
        var pHC = pHB+80;    // horizontal point  C
        var pHD = pHC+HEIGHT;    // horizontal point  C

        var CNT = 107;    // vertical point  A  (center of the screen)
        var Tkn = 1;    // thikness
        var SPC = 2;    // space btw


		dc.setColor(foregroundColour, backgroundColour);
		dc.clear();
		dc.setColor(foregroundColour, Gfx.COLOR_TRANSPARENT);

		// UPDATE FIELDS

		textC(dc, timer_x, timer_y, Gfx.FONT_TINY, timer);
//		textC(dc, timer_x, timerLabel_y, Gfx.FONT_XTINY,  "Timer");

		/*if (timerFieldMode == true) {
			textL(dc, 140 - timeFieldOffset, 138, Gfx.FONT_LARGE, timeField);
			textL(dc, 140 + batteryFieldOffset, 164, Gfx.FONT_LARGE, batteryField);
			var length = dc.getTextWidthInPixels(batteryField, Gfx.FONT_LARGE);
			textL(dc, 140 + length + batteryFieldOffset, 162, Gfx.FONT_MEDIUM, "%");
		}*/

        var hLineCB = 55;
        //box B
		textC(dc, 70, hLineCB, Gfx.FONT_NUMBER_MEDIUM, boxBmiddleField);
		textC(dc, 80, hLineCB-25, Gfx.FONT_XTINY, boxBmiddleFieldLabel);

        //box C
		textC(dc, 160, hLineCB, Gfx.FONT_NUMBER_MEDIUM, boxCmiddleField);
		textC(dc, 170, hLineCB-25, Gfx.FONT_XTINY, boxCmiddleFieldLabel);

		if (invertMiddleBackground == true) {
			// invert the colours of the middle two fields
			dc.setColor(foregroundColour, foregroundColour);	
			dc.fillRectangle(0, 57, 215, 65);
			dc.setColor(backgroundColour, Gfx.COLOR_TRANSPARENT);	
		}

        //box D middle
        var hLineD = 145;
        var endField = 165;
		textC(dc, 107, hLineD, Gfx.FONT_NUMBER_THAI_HOT, boxDmiddleField);
//		textC(dc, 137, hLineD-32, Gfx.FONT_XTINY,  boxDmiddleFieldLabel);
		        textC(dc, endField, 125, Gfx.FONT_SMALL,  'K');
            	textC(dc, endField+1, 135, Gfx.FONT_SMALL,  'm');
            	textC(dc, endField, 150, Gfx.FONT_SMALL,  'h');
        //box D top left
        var hTopLineEF = 100;
        textC(dc, 25, hTopLineEF, Gfx.FONT_SMALL, boxDtopLeftField);
        textC(dc, 6, 97, Gfx.FONT_XTINY,  '^');
        textC(dc, 6, 99, Gfx.FONT_XTINY,  '|');
        //box D top right
        textC(dc, 175, hTopLineEF, Gfx.FONT_MEDIUM, boxDtopRightField);
        textC(dc, 196, hTopLineEF-6, Gfx.FONT_XTINY,  "A");
        textC(dc, 196, hTopLineEF, Gfx.FONT_XTINY,  "V");
        textC(dc, 196, hTopLineEF+6, Gfx.FONT_XTINY,  "G");
//        textC(dc, 6, 97, Gfx.FONT_XTINY,  '^');


        //Box E
        var hLineEF = 210;
		textC(dc, 60, hLineEF, Gfx.FONT_NUMBER_HOT, boxEmiddleField);
		textC(dc, 70, hLineEF-25, Gfx.FONT_XTINY,  boxEmiddleFieldLabel);

		//Box F
        textC(dc, 160, hLineEF, Gfx.FONT_NUMBER_HOT, boxFmiddleField);
        textC(dc, 170, hLineEF-25, Gfx.FONT_XTINY,  boxFmiddleFieldLabel);

		// DRAW LINES

		dc.setColor(Gfx.COLOR_DK_GREEN, Gfx.COLOR_TRANSPARENT);



		// top horizontal A lines
		dc.drawLine(0, pHA, 215, pHA);
		dc.drawLine(0, pHA+Tkn, 215, pHA+Tkn);

		// bottom horizontal A lines
		dc.drawLine(0, pHB, 215, pHB);
		dc.drawLine(0, pHB+Tkn, 215, pHB+Tkn);

        // top horizontal B lines
        dc.drawLine(0, pHC, 215, pHC);
        dc.drawLine(0, pHC+Tkn, 215, pHC+Tkn);

        // bottom horizontal B lines
        dc.drawLine(0, pHD, 215, pHD);
        dc.drawLine(0, pHD+Tkn, 215, pHD+Tkn);

        // top vertical lines
		dc.drawLine(CNT, pHA+SPC+SPC, CNT, pHB-SPC);
		dc.drawLine(CNT+Tkn, pHA+SPC+SPC, CNT+Tkn, pHB-SPC);

        // top vertical lines
		dc.drawLine(CNT, pHC+SPC+SPC, CNT, pHD-SPC);
		dc.drawLine(CNT+Tkn, pHC+SPC+SPC, CNT+Tkn, pHD-SPC);

//		// bottom vertical lines
//		if (timerFieldMode == true) {
//			dc.drawLine(134, 124, 134, 180);
//			dc.drawLine(135, 124, 135, 180);
//		}

		return true;
	}


	function compute(info) {


		boxBmiddleFieldLabel = getFieldLabel(boxBmiddleFieldMode);
		boxCmiddleFieldLabel = getFieldLabel(boxCmiddleFieldMode);
		boxDmiddleFieldLabel = getFieldLabel(boxDmiddleFieldMode);
		boxDtopLeftField = getFieldLabel(boxDtopLeftFieldMode);
		boxDtopRightField = getFieldLabel(boxDtopRightFieldMode);
		boxEmiddleFieldLabel = getFieldLabel(boxEmiddleFieldMode);
		boxFmiddleFieldLabel = getFieldLabel(boxFmiddleFieldMode);
		
		boxBmiddleField = getFieldValue(info,boxBmiddleFieldMode);
		boxCmiddleField = getFieldValue(info,boxCmiddleFieldMode);
		boxDmiddleField = getFieldValue(info,boxDmiddleFieldMode);
		boxDtopLeftField = getFieldValue(info,boxDtopLeftFieldMode);
		boxDtopRightField = getFieldValue(info,boxDtopRightFieldMode);
		boxEmiddleField = getFieldValue(info,boxEmiddleFieldMode);
		boxFmiddleField = getFieldValue(info,boxFmiddleFieldMode);

		var time;
		if (timerType == 1) {
			time = info.elapsedTime;
		} else {
			time = info.timerTime;
		}

		if (time != null) {
			time /= 1000;
		} else {
			time = 0.0;
		}

		timer = fmtSecs(time);


//		if (timerFieldMode == true) {
//
//			timeField = fmtTime(Sys.getClockTime());
//			batteryField = Sys.getSystemStats().battery;
//			batteryFieldOffset = 0;
//
//			if (batteryField > 99) {
//				batteryField = 99;
//			} else {
//				if (batteryField < 10) {
//					batteryFieldOffset = 5;
//				}
//			}
//
//			batteryField = toStr(batteryField.toNumber());
//		}

	}


	function calculateLapPace(distance, time) {

		if (time != null) {
			time /= 1000;
		} else {
			time = 0.0;
		}

		if (time > 0 && distance != null && distance > 0) {

			if (distance - previousLapDist > 0 && time - previousLapTime > 0) {
				speed = (distance - previousLapDist) / (time - previousLapTime);

				if (speed < 0.5) {
					speed = 0;
				}

			} else {
				speed = speed;
			}

			if (distance > lapSplit * currentLap) {
				previousLapDist = distance;
				previousLapTime = time;
				currentLap += 1;
			}

		} else {
			speed = null;
		}
		
		//Sys.println(""+fmtSecs(toPace(speed))+" - "+fmtSecs(toPace(info.averageSpeed))+" - "+fmtSecs(toPace(info.currentSpeed)));

		return toPace(speed);

	}


	function toStr(o) {
		if (o != null && o > 0) {
			return "" + o;
		} else {
			return "---";
		}
	}


	function fmtTime(clock) {

		var h = clock.hour;
		timeFieldOffset = 0;

		if (!Sys.getDeviceSettings().is24Hour) {
			if (h > 12) {
				h -= 12;
			} else if (h == 0) {
				h += 12;
			}
		}

		if (h >= 10) {
			timeFieldOffset = 2;
		}

		return "" + h + ":" + clock.min.format("%02d");
	}

	function fmtSecs(secs) {

		if (secs == null) {
			return "---";
		}

		var s = secs.toLong();
		var hours = s / 3600;
		s -= hours * 3600;
		var minutes = s / 60;
		s -= minutes * 60;

		var fmt;
		if (hours > 0) {
			fmt = "" + hours + ":" + minutes.format("%02d") + ":" + s.format("%02d");
		} else {
			fmt = "" + minutes + ":" + s.format("%02d");
		}

		return fmt;
	}


	function toPace(speed) {
		if (speed == null || speed == 0) {
		return null;
		}

		return split / speed;
	}


	function toDist(dist) {
		if (dist == null) {
			return "0.00";
		}
		dist = dist / split;
		return dist.format("%.2f");
	}

	function toStr2Digit(val) {
		if (val == null) {
			return "0.00";
		}
		return val.format("%.2f");
	}

    function toMeters(value) {
		if (value == null) {
			return "0";
		}

		value = value / 100;
		return value.format("%.2f");
	}

	function textL(dc, x, y, font, s) {
		if (s != null) {
			dc.drawText(x, y, font, s, Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
		}
	}


	function textC(dc, x, y, font, s) {
		if (s != null) {
			dc.drawText(x, y, font, s, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
		}
	}


	/*
	    0=dist, 1=curPace, 2=lapPace, 3=avePace, 4=HR, 5=aveHR, 6=Cadence, 7=aveCadence
	    8=grade, 9=totAscent, 10=lap distance, 11=maxHR , 12 = HR zone
	 */

    function getFieldLabel(field){
            if (field == 0) {
    			return "DST";
    		} else if (field == 1) {
    			return "Speed";
    		} else if (field == 2) {
    			return  "Lap Pace";
    		} else if (field == 3) {
    			return "Ave Pace";
    		} else if (field == 4) {
    			return  "Heart";
    		} else if (field == 5) {
    			return "Ave HR";
    		} else if (field == 6) {
    			return "Cadence";
    		} else if (field == 7) {
    			return  "Ave Cad";
    		} else if (field == 8) {
    			return  "%";
    		} else if (field == 9) {
    			return  "TotAsc";
    		} else if (field == 10) {
    			return  "LapDst";
    		} else if (field == 11) {
    			return  "MaxHR";}
    		else if (field == 12) {
    			return  "zHr";

    		}else if (field == 13) {
    			return  "Altitude";

    		} else {
    			return "Heart";
    		}
    }
    
    function getFieldValue(info,field){
		if (field == 0) {
			return toDist(info.elapsedDistance);
		} else if (field == 1) {
			return toStr2Digit(info.currentSpeed);
		} else if (field == 2) {
			return fmtSecs(calculateLapPace(info.elapsedDistance, info.timerTime));
		} else if (field == 3) {
			return fmtSecs(toPace(info.averageSpeed));
		} else if (field == 4) {
			return toStr(info.currentHeartRate);
		} else if (field == 5) {
			return toStr(info.averageHeartRate);
		} else if (field == 6) {
			return toStr(info.currentCadence);
		} else if (field == 7) {
			return toStr(info.averageCadence);
		} else if (field == 8) {
			return toStr2Digit(grade(info));
		} else if (field == 9) {
			return toStr(info.averageCadence);
		} else if (field == 10) {
			return toStr(info.averageCadence);
		} else if (field == 11) {
			return toStr(info.maxHeartRate);
		} else if (field == 12) {
			return toStr(info.averageCadence);
		} else if (field == 13) {
			return toMeters(info.altitude);
		} else {
			return toPace(info.currentCadence);
		}


    }

    function mod(a, b) {
        return a % b;
    }

    function grade(info){

    //formula %grade = (H/distanza)*100

    var grade = 0;

    if (info.currentSpeed != null && info.elapsedDistance != null  && info.altitude != null){

//        if (currDistance+5 >= info.elapsedDistance  ){
//            var calcDistance = (info.altitude-currAltitude);
//            var calcAltitude = ( info.elapsedDistance-currDistance);
//
//            System.println( "ED"+ calcDistance+ "\n" );
//            System.println( "Alt"+ calcAltitude + "\n" );
//
//            grade = (calcAltitude/calcDistance);
//            System.println( "Grade"+grade+ "\n" );
//
//            currAltitude= info.altitude;
//            currDistance = info.elapsedDistance;
//        }
    }

    return grade;
//    if (info.altitude != null && info.currentSpeed != null) {
//    	// if we haven't got any data, fill with the current data
//    	if (arrayDistance[arrayIndex] == null) {
//    		for (var i = 0; i < arrayDistance.size(); ++i) {
//    			arrayDistance[i] = info.currentSpeed;
//    		}
//
//    		for (var i = 0; i < arrayAltitude.size(); ++i) {
//    			arrayAltitude[i] = info.altitude;
//    		}
//    	}
//    	// fill arrays
//    	arrayAltitude[arrayIndex] = info.altitude;
//    	arrayDistance[arrayIndex] = info.currentSpeed;
//
//    	// calculate altitude change over last 4 seconds
//    	var altitudeChange = (arrayAltitude[arrayIndex] - arrayAltitude[mod((arrayIndex + 1), arrayAltitude.size())]);
//
//    	// calculate horizontal displacement over last 4 seconds
//    	var distanceChange = 0;
//
//    	for (var i = arrayIndex; i > (arrayIndex - (arrayDistance.size() - 1)); --i) {
//    		var idx = mod(i, arrayDistance.size());
//    		distanceChange += arrayDistance[idx];
//    	}
//    	// calculate percent grade
//    	valueGrade = (altitudeChange * 100) / distanceChange;
//
//    	// advance to next array index
//    	arrayIndex = mod((arrayIndex + 1), arrayAltitude.size());
//    }
//    else {
//    	valueGrade = 0;
//    }
//    return valueGrade;
    }
}