import QtQuick 2.0
import MuseScore 1.0

MuseScore {
	version: "0.1"
	description: "This plugin prints the score to a JSON Object."

	//Apply the given function to all notes in selection
	//or if nothing is selected, in the entire score

	function grabSelection() {
		var cursor = curScore.newCursor();
		cursor.rewind(1); //go to start of selection
		var startStaff;
		var endStaff;
		var endTick;
		var fullScore = false;
		if(!cursor.segment) { //no selection
			fullScore = true;
			startStaff = 0; //start with first staff
			endStaff = curScore.nstaves - 1; //end with last staff
		}else {
			startStaff = cursor.staffIdx;
			cursor.rewind(2); //go to end of selection
			if(cursor.tick == 0) {
				//this happens when the selection includes
				//the last measure of the score.
				//rewind(2) goes behing the last segment
				//where there is none and sets tick= 0
				endTick = curScore.lastSegment.tick + 1;
			}else {
				endTick = cursor.tick;
			}
			endStaff = cursor.staffIdx;
		}
		console.log(startStaff + " - " + endStaff + " - " + endTick);

		return [startStaff, endStaff, endTick, fullScore];

	}


	onRun: {
		console.log("jsonexporter started");
		var select = grabSelection();
		console.log(select);
		console.log("About to Quit");
		Qt.quit();
	}




}