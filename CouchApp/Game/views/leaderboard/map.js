function(doc) {
    if (doc.type == "Game") {
            
        if (doc.breakingTeamWon) {
            for (var i=0; i<doc.breakingTeam.length; i++) {
                emit([doc.breakingTeam[i], doc.date], 1.0 / doc.breakingTeam.length);
            }
            for (var i=0; i<doc.otherTeam.length; i++) {
                emit([doc.otherTeam[i], doc.date], -1.0 / doc.otherTeam.length);
            }
        } else {
            for (var i=0; i<doc.breakingTeam.length; i++) {
                emit([doc.breakingTeam[i], doc.date], -1.0 / doc.breakingTeam.length);
            }
            for (var i=0; i<doc.otherTeam.length; i++) {
                emit([doc.otherTeam[i], doc.date], 1.0 / doc.otherTeam.length);
            }
        }
    }
}