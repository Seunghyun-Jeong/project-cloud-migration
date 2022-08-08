'use strict'
const fp = require('fastify-plugin')

module.exports = fp(async function (fastify, opts) {
  fastify.register(require('fastify-dynamodb'), {
    endpoint: 'dynamodb.ap-northeast-2.amazonaws.com',
    region: "ap-northeast-2"
  })
})

// fastify.listen(3000, err => {
//   if (err) throw err
//   console.log(`server listening on ${fastify.server.address().port}`)
// })
