'use strict'

// const products = [
//   {id: 1, name: '2021년 달력', price: 6000, description: '최-신 2021년 달력'},
//   {id: 2, name: '외계어 번역기', price: 12000, description: '화성어과 금성어간의 통역이 가능합니다'},
// ]

module.exports = async function (fastify, opts) {
  fastify.decorate("authenticate", async function(request, reply){
    try {
      await request.jwtVerify()
    } catch (err) {
      reply.code(401).send(err)
    }
  })

  fastify.get(
    '/',
    async (request, reply) => {
      let data
      const params = {
        TableName: "product",
      };
      try {
        data = await fastify.dynamo.scan(params).promise();
      } catch (e) {
         reply.send(e)
      }
      return { data }
    },
  )

  fastify.get(
    '/:id',
    async (request, reply) => {
      let data
      console.log(request.params);
      const { id } = request.params;
      const params = {
        TableName: "product",
        Key: {
          id : parseInt(id)
        },
      };
      try {
        data = await fastify.dynamo.get(params).promise();
      } catch (e) {
         reply.send(e)
      }
      return { data }
    },
  )
  // fastify.get('/', {
  //   // onRequest:[fastify.authenticate]
  // }, async function (request, reply) {
  //   reply.send(products)
  // })

  fastify.post('/', {
    // onRequest:[fastify.authenticate]
  }, async function (request, reply) {
    const {id, name, price, description} = request.body
    console.log(request.body)
    const newItem = {
      TableName: "product",
      Item: {
        id,
        name,
        price,
        description
      }
    }
    console.log(newItem)
    try {
      const data = await fastify.dynamo.put(newItem).promise();
      return { data }
    } catch (e) {
       reply.send(e)
    }
  }
)
}
