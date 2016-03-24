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

		return [startStaff, endStaff, endTick, fullScore, cursor];

	}

	function grabNotes(selectArr) {
		var startStaff = selectArr[0];
		var endStaff = selectArr[1];
		var endTick = selectArr[2];
		var fullScore = selectArr[3];
		var cursor = selectArr[4];
		for (var staff = startStaff; staff <= endStaff; staff++) {
			for (var voice = 0; voice < 4; voice++) {
				cursor.rewind(1); // sets voice to 0
				cursor.voice = voice; //voice has to be set after goTo
				cursor.staffIdx = staff;

				if (fullScore)
					cursor.rewind(0) // if no selection, beginning of score

				while (cursor.segment && (fullScore || cursor.tick < endTick)) {
					if (cursor.element && cursor.element.type == Element.CHORD) {
						var notes = cursor.element.notes;
						for (var i = 0; i < notes.length; i++) {
							var note = notes[i];
							//func(note);
							console.log(note.pitch + " - " + note.headType);
						}
					}else if(cursor.element && cursor.element.type == Element.REST) {
						var rest = cursor.element;
						console.log(rest.durationType);
					}
					cursor.next();
				}
			}
		}
	}


	onRun: {
		console.log("jsonexporter started");
		var select = grabSelection();
		console.log(select);
		grabNotes(select);
		console.log("About to Quit");
		Qt.quit();
	}




}