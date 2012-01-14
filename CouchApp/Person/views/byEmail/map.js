function(doc) {
    if (doc.type == "Person") {
        emit(doc.email, doc);
    }
}
