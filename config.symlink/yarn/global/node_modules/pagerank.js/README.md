pagerank.js
-----------
[![NPM Version](https://img.shields.io/npm/v/pagerank.js.svg)](https://www.npmjs.org/package/genex)
[![NPM Downloads](https://img.shields.io/npm/dm/pagerank.js.svg)](https://www.npmjs.org/package/pagerank.js)

Vanilla JavaScript implementation of the Weighted PageRank Algorithm

Usage
-----

```js
var graph = require('pagerank.js');

graph.link(1, 2, 1.0)
graph.link(1, 3, 2.0)
graph.link(2, 3, 3.0)
graph.link(2, 4, 4.0)
graph.link(3, 1, 5.0)

graph.rank(0.85, 0.000001, function (node, rank) {
    console.log("Node " + node + " has a rank of " + rank)
})
```

Output
------

```
Node 1 has a rank of 0.34983779905464363
Node 2 has a rank of 0.1688733284604475
Node 3 has a rank of 0.3295121849483849
Node 4 has a rank of 0.15177668753652385
```

Install
-------

    npm install pagerank.js --save

License
-------

MIT
