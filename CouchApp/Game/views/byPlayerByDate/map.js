function(doc) {
    if (doc.type == "Game") {
        for (var i=0; i<doc.breakingTeam.length; i++) {
            emit([doc.breakingTeam[i], doc.date], doc);
        }
        for (var j=0; j<doc.otherTeam.length; j++) {
            emit([doc.otherTeam[j], doc.date], doc);
        }
    }
}