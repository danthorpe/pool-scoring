function (keys, values, rereduce) {
    var wins = 0;
    for (var i=0; i<values.length; i++) {
        wins += values[i][1];
    }
    return (wins / values.length) * 100.0;
}