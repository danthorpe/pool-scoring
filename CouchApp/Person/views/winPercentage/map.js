function(doc) {
    if (doc.type == "Game") {
        if (doc.breakingTeamWon) {
            for (var i = 0; i < doc.breakingTeam.length; i++) {
                emit(doc.breakingTeam[i], [1, 0]);
            }
            for (var i = 0; i < doc.otherTeam.length; i++) {
                emit(doc.otherTeam[i], [0, 1]);
            }
        } else {        
            for (var i = 0; i < doc.breakingTeam.length; i++) {
                emit(doc.breakingTeam[i], [0, 1]);
            }
            for (var i = 0; i < doc.otherTeam.length; i++) {
                emit(doc.otherTeam[i], [1, 0]);
            }
        }
    }
}