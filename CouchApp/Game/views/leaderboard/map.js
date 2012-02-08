function(doc) {
    if (doc.type == "Game") {
            
        if (doc.breakingTeamWon) {
            for (var i=0; i<doc.breakingTeam.length; i++) {
                emit([doc.date, doc.breakingTeam[i]], 1.0 / doc.breakingTeam.length);
            }
            for (var i=0; i<doc.otherTeam.length; i++) {
                emit([doc.date, doc.otherTeam[i]], -1.0 / doc.otherTeam.length);
            }
        } else {
            for (var i=0; i<doc.breakingTeam.length; i++) {
                emit([doc.date, doc.breakingTeam[i]], -1.0 / doc.breakingTeam.length);
            }
            for (var i=0; i<doc.otherTeam.length; i++) {
                emit([doc.date, doc.otherTeam[i]], 1.0 / doc.otherTeam.length);
            }
        }
    }
}