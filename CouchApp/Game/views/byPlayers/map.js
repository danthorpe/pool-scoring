function(doc) {
    if (doc.type == "Game") {
        for (var i=0; i<doc.breakingTeam.length; i++) {
            for (var j=0; j<doc.otherTeam.length; j++) {
                emit([doc.breakingTeam[i], doc.otherTeam[j]], doc);
            }
        }
    }
}