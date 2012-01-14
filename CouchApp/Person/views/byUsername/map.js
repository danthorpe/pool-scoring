function(doc) {
    if (doc.type == "Person") {
        emit(doc.username, doc);
    }
}