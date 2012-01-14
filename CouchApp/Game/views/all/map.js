function(doc) {
    if (doc.type == "Game") {
        emit(doc.date, doc);
    }
}