function(doc) {
    if (doc.type == "Game") {
        emit(doc._id, doc);
    }
}