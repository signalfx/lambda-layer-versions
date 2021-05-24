const _ = require('lodash');

// Handler
exports.handler = async function(event, context) {
  event.Records.forEach(record => {
    console.log(record.body)
  })
  console.log('## ENVIRONMENT VARIABLES: ' + serialize(process.env))
  console.log('## CONTEXT: ' + serialize(context))
  console.log('## EVENT: ' + serialize(event))

  //just to demonstrate you can use a library
  console.log('## calling a library: ' + _.uniq([1, 2, 1, 3, 1]));

  return {response: "Yay!"};
}

var serialize = function(object) {
  return JSON.stringify(object, null, 2)
}
