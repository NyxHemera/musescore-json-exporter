import QtQuick 2.0
import FileIO 1.0
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
		var noteObj = {};
		noteObj.notes = [];
		var numNotes = 0;

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
							//console.log(note.pitch + " - " + note.headType);
							//var name = "note" + numNotes++;
							if(note == null) {
								continue;
							}else {
								noteObj.notes[numNotes++] = {pitch:note.pitch, duration:cursor.element.durationType};
							}
						}
					}else if(cursor.element && cursor.element.type == Element.REST) {
						var rest = cursor.element;
						//console.log(rest.durationType);
						//var name = "note" + numNotes++;
						noteObj.notes[numNotes++] = {pitch:"REST", duration:rest.durationType};							
					}
					cursor.next();
				}
			}
		}
		console.log("numNotes" + numNotes);
		return noteObj;
	}

	function convertToWAD(noteObj) {
		for(var i=0; i<noteObj.notes.length; i++){
			noteObj.notes[i].pitch = convertPitch(noteObj.notes[i].pitch);
			noteObj.notes[i].duration = convertDuration(noteObj.notes[i].duration);
		}
		return noteObj;
	}

	function convertPitch(pitch) {
		if(pitch == "REST") return pitch;

		var octave = Math.floor(pitch/12) + 1;
		var note = pitch%12;
		switch(note) {
			case 0:
				note = 'C';
				break;
			case 1:
				note = 'C#';
				break;
			case 2:
				note = 'D';
				break;
			case 3:
				note = 'D#';
				break;
			case 4:
				note = 'E';
				break;
			case 5:
				note = 'F';
				break;
			case 6:
				note = 'F#';
				break;
			case 7:
				note = 'G';
				break;
			case 8:
				note = 'G#';
				break;
			case 9:
				note = 'A';
				break;
			case 10:
				note = 'A#';
				break;
			case 11:
				note = 'B';
				break;
		}
		return note + octave;
	}

	function convertDuration(duration) {
		if(duration == 0) {
			return 1;
		}else {
			return duration / 1920; //1920 is whole note
		}
	}

	FileIO {
		id: file
		onError: console.log("FileIO Error")
		source: file.tempPath() + "/song.json";
	}

	function writeToFile(noteObj) {
		console.log("Does file exist? " + file.exists());
		console.log("Did the file write successfully? " + file.write(JSON.stringify(noteObj))); //writes the file
		console.log("The file exists here: " + file.source);
	}


	onRun: {
		var select = grabSelection();
		var noteObj = grabNotes(select);
		noteObj = convertToWAD(noteObj);
		writeToFile(noteObj);
		Qt.quit();
	}




}