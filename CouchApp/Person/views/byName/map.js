function(doc) {
    if (doc.type == "Person") {
        emit(doc.name, doc);
    }
}