function(doc) {
    if (doc.type == "Game") {
            
        now = Date.now() / 1000.0;
        difference = now - doc.date;
                
        if (difference < 604800) {
            if (doc.breakingTeamWon) {
                for (var i=0; i<doc.breakingTeam.length; i++) {
                    emit(doc.breakingTeam[i], 1.0 / doc.breakingTeam.length);
                }
                for (var i=0; i<doc.otherTeam.length; i++) {
                    emit(doc.otherTeam[i], -1.0 / doc.otherTeam.length);
                }
            } else {
                for (var i=0; i<doc.breakingTeam.length; i++) {
                    emit(doc.breakingTeam[i], -1.0 / doc.breakingTeam.length);
                }
                for (var i=0; i<doc.otherTeam.length; i++) {
                    emit(doc.otherTeam[i], 1.0 / doc.otherTeam.length);
                }
            }        
        }    
    }
}