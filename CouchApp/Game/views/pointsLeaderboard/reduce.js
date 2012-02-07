function (keys, values, rereduce) {

    if (rereduce) {
    
        var result = {
            points: 0,
            wins: 0,
            losses: 0,
            count: 0
        };

        for (var i=0; i<values.length; ++i) {
            result.points += values[i].points;
            result.count += values[i].count;
            result.wins += values[i].wins;
            result.losses += values[i].losses;
        }

        result.score = result.points / result.count;
        
        return result;
    }

    var result = {
        score: 0,    
        points: 0,
        wins: 0,
        losses: 0,
        count: 0
    };

    for (var i=0; i<values.length; ++i) {
        result.points += values[i];
        result.count += 1;
        if (values[i] > 0) {
            result.wins += 1;
        } else {
            result.losses += 1;
        }
    }
    
    result.score = result.wins / result.count;

    return result;
}