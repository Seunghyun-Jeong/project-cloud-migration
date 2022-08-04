'use strict'

module.exports = async function (fastify, opts) {
  fastify.post('/login', async function (request, reply) {
    const {loginname, password} = request.body
    const connection = await fastify.mysql.getConnection()

    const [rows, fields] = await connection.query(
      `SELECT * FROM users WHERE loginname = '${loginname}' and password='${password}'`, []
    )
    connection.release()

    const user = rows[0]
    console.log(user)
    if(rows.length > 0) {
      const {name, role} = rows[0]
      const token = fastify.jwt.sign({"id":user.id, "loginname": loginname, "name": name, "role": role})
      reply.send({ token })
    } else {
      reply.code(401).send({ 'message': "유효한 로그인네임과 패스워드가 아닙니다." })
    }
  })

  fastify.decorate("authenticate", async function(request, reply){
    try {
      await request.jwtVerify()
    } catch (err) {
      reply.code(401).send(err)
    }
  })

  fastify.get("/", {
    onRequest:[fastify.authenticate]
  },
  async function(request, reply) {
    console.log("request.user", request.user)

    return request.user
  })

  fastify.post("/signup", async function (request, reply){
    const {loginname, password, name} = request.body
    const connection = await fastify.mysql.getConnection()
    const [rows, fields] = await connection.query(`select * from users where loginname=? and name=?`, [loginname, name])
    if (rows.length === 0) {
      connection.query(`insert into users (loginname, password, name, role) values (?, ?, ?, ?)`, [loginname, password, name, 'member'])
    }
    else {
      return "중복된 회원가입입니다."
    }
    connection.release()
    reply.code(201).send({'message': 'ok'})
  })
}